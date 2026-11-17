-- Schema for Domain: beneficiary | Business: Asset Management | Version: v1_ecm
-- Generated on: 2026-11-10 14:17:24

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `asset_management`.`beneficiary` COMMENT 'Single source of truth for all pension plan members and contributor pools, one per participating plan. Owns beneficiary identity, contribution history, entitlement records, demographic data, and member lifecycle from active';
ALTER SCHEMA `asset_management`.`beneficiary` SET TAGS ('dbx_division' = 'business');
ALTER SCHEMA `asset_management`.`beneficiary` SET TAGS ('dbx_domain' = 'beneficiary');

-- ========= TABLES =========
CREATE OR REPLACE TABLE `asset_management`.`beneficiary`.`member` (
    `member_id` BIGINT COMMENT 'Globally unique identifier for the member record.',
    `actor_id` BIGINT COMMENT 'Foreign key linking to shared.actor. Business justification: Members are pension beneficiaries (plan members and participating employers) who are actors in the system.',
    `contributor_pool_id` BIGINT COMMENT 'Foreign key linking to beneficiary.contributor_pool. Business justification: Member has denormalized contributor_pool STRING field. Adding FK to contributor_pool table normalizes this relationship.',
    `employee_id` BIGINT COMMENT 'Identifier of the user who created the record.',
    `membership_status_updated_by_user_employee_id` BIGINT COMMENT 'Identifier of the user who updated the membership status.',
    `pension_plan_id` BIGINT COMMENT 'Identifier of the investment plan the member is enrolled in.',
    `updated_by_user_employee_id` BIGINT COMMENT 'Identifier of the user who last updated the record.',
    `address_line_1` STRING COMMENT 'Primary address line.',
    `address_line_2` STRING COMMENT 'Secondary address line.',
    `city` STRING COMMENT 'City of residence.',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code.. Valid values are `^[A-Z]{3}$`',
    `created_by_user_department` STRING COMMENT 'Department of the user who created the record.. Valid values are `HR|Finance|Operations|Compliance`',
    `created_by_user_email` STRING COMMENT 'Email of the user who created the record.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `created_by_user_location` STRING COMMENT 'Physical location of the user who created the record.. Valid values are `HQ|Branch|Remote`',
    `created_by_user_name` STRING COMMENT 'Name of the user who created the record.',
    `created_by_user_role` STRING COMMENT 'Role of the user who created the record.. Valid values are `admin|user|auditor`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the record was first created.',
    `date_of_birth` DATE COMMENT 'Members date of birth.',
    `email` STRING COMMENT 'Primary email address for communication.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `full_name` STRING COMMENT 'Full legal name of the member.',
    `gender` STRING COMMENT 'Members gender.. Valid values are `male|female|non_binary|other`',
    `membership_end_date` DATE COMMENT 'Date the membership ended or is scheduled to end.',
    `membership_start_date` DATE COMMENT 'Date the member joined the plan.',
    `membership_status` STRING COMMENT 'Current lifecycle status of the member.. Valid values are `active|inactive|terminated|pending`',
    `membership_status_effective_date` DATE COMMENT 'Date the current status became effective.',
    `membership_status_expiry_date` DATE COMMENT 'Date the current status will expire.',
    `membership_status_reason` STRING COMMENT 'Reason for the current membership status.',
    `membership_status_updated_by_user_department` STRING COMMENT 'Department of the user who updated the membership status.. Valid values are `HR|Finance|Operations|Compliance`',
    `membership_status_updated_by_user_email` STRING COMMENT 'Email of the user who updated the membership status.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `membership_status_updated_by_user_location` STRING COMMENT 'Physical location of the user who updated the membership status.. Valid values are `HQ|Branch|Remote`',
    `membership_status_updated_by_user_name` STRING COMMENT 'Name of the user who updated the membership status.',
    `membership_status_updated_by_user_role` STRING COMMENT 'Role of the user who updated the membership status.. Valid values are `admin|user|auditor`',
    `membership_status_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the membership status was last updated.',
    `national_identifier` STRING COMMENT 'Government issued national ID number.. Valid values are `^[A-Z0-9]{5,20}$`',
    `number` BIGINT COMMENT 'Unique member number assigned by the pension fund.',
    `phone_number` STRING COMMENT 'Primary contact phone number.. Valid values are `^+?[0-9]{7,15}$`',
    `plan_status` STRING COMMENT 'Current status of the investment plan.. Valid values are `active|suspended|terminated|pending`',
    `plan_type` STRING COMMENT 'Type of investment plan.. Valid values are `public_equities|private_equity|real_estate|infrastructure|natural_resources|credit`',
    `postal_code` STRING COMMENT 'Postal or ZIP code.. Valid values are `^[A-Z0-9]{3,10}$`',
    `province_state` STRING COMMENT 'Province or state of residence.',
    `updated_by_user_department` STRING COMMENT 'Department of the user who last updated the record.. Valid values are `HR|Finance|Operations|Compliance`',
    `updated_by_user_email` STRING COMMENT 'Email of the user who last updated the record.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `updated_by_user_location` STRING COMMENT 'Physical location of the user who last updated the record.. Valid values are `HQ|Branch|Remote`',
    `updated_by_user_name` STRING COMMENT 'Name of the user who last updated the record.',
    `updated_by_user_role` STRING COMMENT 'Role of the user who last updated the record.. Valid values are `admin|user|auditor`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent record update.',
    CONSTRAINT pk_member PRIMARY KEY(`member_id`)
) COMMENT 'Core master record and single source of truth for every pension plan member across all four contributor pools (one per participating plan).';

CREATE OR REPLACE TABLE `asset_management`.`beneficiary`.`contributor_pool` (
    `contributor_pool_id` BIGINT COMMENT 'Unique identifier for the contributor pool.',
    `portfolio_id` BIGINT COMMENT 'Foreign key linking to portfolio.portfolio. Business justification: Contributor pools represent plan-level contribution structures; linking to portfolio associates the pool with its investment portfolio.',
    `actuarial_assumptions` STRING COMMENT 'Actuarial assumptions used for the contributor pool.',
    `approval_date` DATE COMMENT 'Date when the contributor pool was approved.',
    `approved_by` STRING COMMENT 'Identifier of the approver for the pool.',
    `benefit_formula` STRING COMMENT 'Benefit calculation formula for the pool.',
    `contributor_pool_code` STRING COMMENT 'Alphanumeric code that uniquely identifies the contributor pool.. Valid values are `CP[0-9]{4}`',
    `contribution_frequency` STRING COMMENT 'Frequency of contributions for the pool.. Valid values are `monthly|quarterly|annual`',
    `contribution_rate` DECIMAL(10,4) COMMENT 'Standard contribution rate applied to the pool.',
    `contribution_rate_structure` STRING COMMENT 'Structure of contribution rates applied to the pool.',
    `contributor_pool_status` STRING COMMENT 'Current lifecycle status of the contributor pool.. Valid values are `active|inactive|terminated|pending`',
    `contributor_pool_type` STRING COMMENT 'Classification of the contributor pool (e.g., one of the participating plans).. Valid values are `plan_1|plan_2|plan_3|plan_4`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the record was created.',
    `currency_code` STRING COMMENT 'ISO 4217 currency code for the pool.. Valid values are `^[A-Z]{3}$`',
    `contributor_pool_description` STRING COMMENT 'Narrative description of the contributor pool.',
    `effective_from` DATE COMMENT 'Date when the contributor pool becomes effective.',
    `effective_until` DATE COMMENT 'Date when the contributor pool ceases to be effective.',
    `employment_category` STRING COMMENT 'Employment category of contributors in the pool.',
    `gazette_reference` STRING COMMENT 'Gazette reference for the contributor pool.',
    `indexation_basis` STRING COMMENT 'Basis for indexation adjustments.',
    `indexation_rate` DECIMAL(10,4) COMMENT 'Rate applied for indexation adjustments.',
    `is_mandatory` BOOLEAN COMMENT 'Indicates if contributions are mandatory.',
    `is_tax_deductible` BOOLEAN COMMENT 'Indicates if contributions are tax deductible.',
    `jurisdiction_code` STRING COMMENT 'ISO 3166-1 alpha-3 code of the jurisdiction.. Valid values are `^[A-Z]{3}$`',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the record.',
    `legislative_authority` STRING COMMENT 'Authority responsible for the legislative framework.',
    `legislative_framework` STRING COMMENT 'Legislative framework governing the contributor pool.',
    `max_pensionable_earnings` DECIMAL(15,2) COMMENT 'Maximum earnings subject to pension contributions.',
    `min_pensionable_earnings` DECIMAL(15,2) COMMENT 'Minimum earnings subject to pension contributions.',
    `contributor_pool_name` STRING COMMENT 'Human-readable name of the contributor pool.',
    `notes` STRING COMMENT 'Additional notes or remarks about the pool.',
    `plan_type` STRING COMMENT 'Type of plan associated with the pool.',
    `rate_description` STRING COMMENT 'Description of the contribution rate applied.',
    `regulatory_basis` STRING COMMENT 'Regulatory basis for the contributor pool.',
    `service_category` STRING COMMENT 'Service category of contributors in the pool.',
    `version_number` BIGINT COMMENT 'Version number for the contributor pool record.',
    CONSTRAINT pk_contributor_pool PRIMARY KEY(`contributor_pool_id`)
) COMMENT 'Reference entity defining the four distinct contributor pools managed by the fund: the participating plans. Each pool has its own legislative framework, benefit formula, contribution rate structure, actuarial assumptions';

CREATE OR REPLACE TABLE `asset_management`.`beneficiary`.`member_enrollment` (
    `member_enrollment_id` BIGINT COMMENT 'Unique identifier for the member enrollment transaction.',
    `contributor_pool_id` BIGINT COMMENT 'Foreign key linking to beneficiary.contributor_pool. Business justification: Member enrollment has contributor_pool_code STRING but no FK. Enrollment is into a specific contributor pool. Adding FK normalizes this.',
    `member_id` BIGINT COMMENT 'Identifier of the member being enrolled.',
    `pension_plan_id` BIGINT COMMENT 'Identifier of the contributor pool or plan associated with the enrollment.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the enrollment record was first created.',
    `eligibility_verification_outcome` STRING COMMENT 'Result of the eligibility verification process for the enrollment.. Valid values are `verified|unverified|pending`',
    `enrollment_date` DATE COMMENT 'Date when the member enrollment was initiated.',
    `enrollment_fee_amount` DECIMAL(18,2) COMMENT 'Monetary amount charged for the enrollment process.',
    `enrollment_reference_number` STRING COMMENT 'External reference number assigned to the enrollment event.',
    `enrollment_source_system_code` STRING COMMENT 'Code identifying the system that captured the enrollment. [ENUM-REF-CANDIDATE: SimCorp|Aladdin|Bloomberg|StateStreet|eFront|DealCloud|MSCI|CharlesRiver|Oracle|SAP|Diligent|Preqin|PitchBook|FactSet — promote to reference product]',
    `enrollment_source_system_device` STRING COMMENT 'Device identifier used to capture the enrollment record.',
    `enrollment_source_system_ip` STRING COMMENT 'IP address of the system or user that captured the enrollment.. Valid values are `^(?:[0-9]{1,3}.){3}[0-9]{1,3}$`',
    `enrollment_source_system_location` STRING COMMENT 'Geographic location of the system or user that captured the enrollment.',
    `enrollment_source_system_name` STRING COMMENT 'Human-readable name of the source system that captured the enrollment.',
    `enrollment_source_system_reference_code` STRING COMMENT 'Unique identifier within the source system for the enrollment record.',
    `enrollment_source_system_reference_date` DATE COMMENT 'Date associated with the source system reference for the enrollment.',
    `enrollment_source_system_reference_description` STRING COMMENT 'Description of the source system reference for the enrollment.',
    `enrollment_source_system_reference_status` STRING COMMENT 'Status of the source system reference for the enrollment.',
    `enrollment_source_system_reference_type` STRING COMMENT 'Type of reference used within the source system for the enrollment record.',
    `enrollment_source_system_reference_value` DECIMAL(18,2) COMMENT 'Value of the reference within the source system for the enrollment record.',
    `enrollment_source_system_user` STRING COMMENT 'Identifier of the user or process that created the enrollment record.',
    `enrollment_source_system_version` STRING COMMENT 'Version of the source system used to capture the enrollment.',
    `enrollment_status` STRING COMMENT 'Current status of the enrollment process.. Valid values are `draft|pending|completed|cancelled`',
    `enrollment_type` STRING COMMENT 'Type of enrollment event: new hire, transfer in, or re-enrollment.. Valid values are `new_hire|transfer_in|re_enrollment`',
    `fee_currency` STRING COMMENT 'ISO 4217 currency code for the enrollment fee.. Valid values are `USD|EUR|GBP|JPY|CAD|AUD`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the enrollment record.',
    CONSTRAINT pk_member_enrollment PRIMARY KEY(`member_enrollment_id`)
) COMMENT 'Transactional record capturing the formal enrollment event when an individual joins a contributor pool as an active pension plan member. Records enrollment date, plan entry type (new hire, transfer-in, re-enrollment), eligibility verification outcome';

CREATE OR REPLACE TABLE `asset_management`.`beneficiary`.`contribution_record` (
    `contribution_record_id` BIGINT COMMENT 'Unique identifier for the contribution record.',
    `contributor_pool_id` BIGINT COMMENT 'Identifier for the contributor pool (e.g., one of the participating plans) associated with the contribution.',
    `member_id` BIGINT COMMENT 'Identifier for the plan member associated with the contribution.',
    `net_contribution_inflow_id` BIGINT COMMENT 'Foreign key linking to treasury.net_contribution_inflow. Business justification: Links each contribution record to the treasury inflow for audit and reconciliation of member contributions.',
    `pension_plan_id` BIGINT COMMENT 'Identifier for the investment plan under which the contribution is made.',
    `approval_date` DATE COMMENT 'Date when the contribution was approved.',
    `approved_by` STRING COMMENT 'Identifier of the user who approved the contribution.',
    `contribution_approval_status` STRING COMMENT 'Approval status of the contribution record.. Valid values are `pending|approved|rejected|cancelled`',
    `contribution_batch_code` STRING COMMENT 'Identifier for the batch in which the contribution was processed.',
    `contribution_created_timestamp` TIMESTAMP COMMENT 'Timestamp when the contribution record was first created.',
    `contribution_currency_code` STRING COMMENT 'ISO 4217 currency code for the contribution amounts.',
    `contribution_date` TIMESTAMP COMMENT 'Timestamp when the contribution was recorded.',
    `contribution_fee_amount` DECIMAL(18,2) COMMENT 'Fee charged for processing the contribution.',
    `contribution_fee_currency_code` STRING COMMENT 'ISO 4217 currency code for the fee amounts.',
    `contribution_fee_rate` DECIMAL(5,4) COMMENT 'Rate applied to calculate the contribution fee.',
    `contribution_fee_type` STRING COMMENT 'Classification of the fee applied to the contribution.. Valid values are `service_fee|processing_fee|administrative_fee`',
    `contribution_frequency` STRING COMMENT 'Frequency at which the contribution is made.. Valid values are `weekly|biweekly|monthly|quarterly|annual`',
    `contribution_method` STRING COMMENT 'Mechanism used to transfer the contribution funds.. Valid values are `payroll|direct_deposit|manual|wire_transfer`',
    `contribution_period_end_date` DATE COMMENT 'End date of the contribution period (pay period).',
    `contribution_period_start_date` DATE COMMENT 'Start date of the contribution period (pay period).',
    `contribution_reference_number` STRING COMMENT 'External reference number for the contribution transaction.',
    `contribution_source` STRING COMMENT 'Originating system or channel for the contribution.. Valid values are `payroll_system|bank_transfer|manual_entry|third_party`',
    `contribution_source_system_code` STRING COMMENT 'Code of the system that originated the contribution record.',
    `contribution_source_system_name` STRING COMMENT 'Name of the system that originated the contribution record.',
    `contribution_source_system_reference_code` STRING COMMENT 'Reference ID in the source system for the contribution record.',
    `contribution_source_system_user` STRING COMMENT 'User in the source system who created the contribution record.',
    `contribution_source_system_version` STRING COMMENT 'Version of the source system that created the contribution record.',
    `contribution_status` STRING COMMENT 'Current lifecycle status of the contribution record.. Valid values are `pending|posted|reversed|cancelled|failed`',
    `contribution_tax_amount` DECIMAL(18,2) COMMENT 'Tax amount applied to the contribution.',
    `contribution_tax_code` STRING COMMENT 'Tax code used for the contribution.',
    `contribution_tax_rate` DECIMAL(5,4) COMMENT 'Tax rate applied to the contribution.',
    `contribution_type` STRING COMMENT 'Classification of the contribution (e.g., regular, catch‑up).. Valid values are `regular|catch-up|voluntary|employer_match`',
    `contribution_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the contribution record was last updated.',
    `employee_contribution_amount` DECIMAL(18,2) COMMENT 'Amount contributed by the employee for the period.',
    `employer_contribution_amount` DECIMAL(18,2) COMMENT 'Amount contributed by the employer for the period.',
    `total_contribution_amount` DECIMAL(18,2) COMMENT 'Sum of employee and employer contributions for the period.',
    CONSTRAINT pk_contribution_record PRIMARY KEY(`contribution_record_id`)
) COMMENT 'Transactional record of each periodic pension contribution made on behalf of or by a plan member. Captures employee contribution amount, employer contribution amount, contribution period (pay period), contribution type (regular, catch-up, voluntary';

CREATE OR REPLACE TABLE `asset_management`.`beneficiary`.`pensionable_service` (
    `pensionable_service_id` BIGINT COMMENT 'Unique identifier for the pensionable service record.',
    `contributor_pool_id` BIGINT COMMENT 'Foreign key linking to beneficiary.contributor_pool. Business justification: Pensionable service records have contributor_pool STRING. Service credits are accrued under a specific contributor pools rules. FK normalizes this.',
    `indexation_policy_id` BIGINT COMMENT 'Unique identifier for the pension plan.',
    `member_id` BIGINT COMMENT 'Unique identifier for the member in the pension fund.',
    `pension_plan_id` BIGINT COMMENT 'Unique identifier for the pension plan.',
    `portfolio_id` BIGINT COMMENT 'Foreign key linking to portfolio.portfolio. Business justification: Service years are calculated per plan; linking to portfolio ensures correct service year attribution for pension calculations.',
    `cumulative_service_months` BIGINT COMMENT 'Total months of service credited to date.',
    `cumulative_service_years` BIGINT COMMENT 'Total years of service credited to date.',
    `period_service_months` BIGINT COMMENT 'Months of service credited in the current period.',
    `period_service_years` BIGINT COMMENT 'Years of service credited in the current period.',
    `service_credits_approval_by` STRING COMMENT 'Identifier of the approver for the service credits.',
    `service_credits_approval_date` DATE COMMENT 'Date when the service credits were approved.',
    `service_credits_contributor_pool_code` STRING COMMENT 'Code of the contributor pool for the service credits.',
    `service_credits_created_by_user` STRING COMMENT 'User who created the service credit record.',
    `service_credits_created_timestamp` TIMESTAMP COMMENT 'Timestamp when the service credit record was created.',
    `service_credits_effective_from` DATE COMMENT 'Effective start date of the service credits.',
    `service_credits_effective_until` DATE COMMENT 'Effective end date of the service credits.',
    `service_credits_lifetime_status` STRING COMMENT 'Lifetime status of the service credits.',
    `service_credits_months` BIGINT COMMENT 'Months of service credits recorded for the period.',
    `service_credits_notes` STRING COMMENT 'Additional notes regarding the service credits.',
    `service_credits_plan_type` STRING COMMENT 'Type of plan associated with the service credits.',
    `service_credits_reason` STRING COMMENT 'Reason for the service credit entry.',
    `service_credits_source_system` STRING COMMENT 'System that originated the service credit record.',
    `service_credits_source_system_device` STRING COMMENT 'Device used to enter the record in the source system.',
    `service_credits_source_system_ip` STRING COMMENT 'IP address of the source system at record entry.',
    `service_credits_source_system_location` STRING COMMENT 'Physical location of the source system at record entry.',
    `service_credits_source_system_name` STRING COMMENT 'Name of the source system for the service credit.',
    `service_credits_source_system_reference` STRING COMMENT 'Description of the reference in the source system.',
    `service_credits_source_system_reference_code` BIGINT COMMENT 'Reference ID in the source system for the service credit.',
    `service_credits_source_system_reference_date` DATE COMMENT 'Date of the reference in the source system.',
    `service_credits_source_system_reference_status` STRING COMMENT 'Status of the reference in the source system.',
    `service_credits_source_system_reference_type` STRING COMMENT 'Type of reference in the source system.',
    `service_credits_source_system_reference_value` DECIMAL(18,2) COMMENT 'Value of the reference in the source system.',
    `service_credits_source_system_user` STRING COMMENT 'User who entered the record in the source system.',
    `service_credits_source_system_version` STRING COMMENT 'Version of the source system used.',
    `service_credits_status` STRING COMMENT 'Lifecycle status of the service credits.. Valid values are `active|inactive|terminated|pending`',
    `service_credits_updated_by_user` STRING COMMENT 'User who last updated the service credit record.',
    `service_credits_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the service credit record was last updated.',
    `service_credits_years` BIGINT COMMENT 'Years of service credits recorded for the period.',
    `service_end_date` DATE COMMENT 'Date when the pensionable service period ends.',
    `service_start_date` DATE COMMENT 'Date when the pensionable service period begins.',
    `service_status` STRING COMMENT 'Current lifecycle status of the service record.. Valid values are `active|inactive|terminated|pending`',
    `service_type` STRING COMMENT 'Category of pensionable service credit.. Valid values are `regular|buyback|transferred_in|military_service_credit`',
    CONSTRAINT pk_pensionable_service PRIMARY KEY(`pensionable_service_id`)
) COMMENT 'Master record tracking the cumulative and period-level pensionable service credits accrued by a member. Records credited service years and months, service type (regular, buyback, transferred-in, military service credit), service period start and end';

CREATE OR REPLACE TABLE `asset_management`.`beneficiary`.`entitlement` (
    `entitlement_id` BIGINT COMMENT 'Unique identifier for the entitlement record.',
    `benefit_option_id` BIGINT COMMENT 'Identifier of the benefit option selected.',
    `contributor_pool_id` BIGINT COMMENT 'Identifier linking the entitlement to the contributor pool.',
    `designated_beneficiary_id` BIGINT COMMENT 'Identifier of the survivor receiving the benefit.',
    `entitlement_member_id` BIGINT COMMENT 'Identifier linking the entitlement to the member.',
    `entitlement_survivor_member_id` BIGINT COMMENT 'Identifier of the survivor receiving the benefit.',
    `pension_plan_id` BIGINT COMMENT 'Identifier linking the entitlement to the investment plan.',
    `portfolio_id` BIGINT COMMENT 'Foreign key linking to portfolio.portfolio. Business justification: Entitlement calculations depend on plan parameters; linking to portfolio provides the necessary plan context for benefit determination.',
    `actuarial_basis` STRING COMMENT 'Actuarial basis applied to the entitlement calculation.',
    `benefit_amount` DECIMAL(18,2) COMMENT 'Gross monetary amount of the entitlement.',
    `benefit_currency` STRING COMMENT 'Currency of the benefit amount.. Valid values are `USD|EUR|GBP|JPY|CAD|AUD`',
    `benefit_end_date` DATE COMMENT 'Date when benefit payments cease.',
    `benefit_frequency` STRING COMMENT 'Payment frequency of the entitlement.. Valid values are `monthly|quarterly|annually|lump_sum`',
    `benefit_start_date` DATE COMMENT 'Date when benefit payments commence.',
    `calculation_method_code` STRING COMMENT 'Code indicating the calculation methodology used.. Valid values are `actuarial|statistical|market_based`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the entitlement record was created.',
    `effective_from` DATE COMMENT 'Date when the entitlement becomes effective.',
    `effective_until` DATE COMMENT 'Date when the entitlement expires or ends.',
    `entitlement_status` STRING COMMENT 'Current status of the entitlement.. Valid values are `active|terminated|pending|canceled`',
    `entitlement_type` STRING COMMENT 'Type of entitlement trigger.. Valid values are `retirement|death|termination|early_retirement`',
    `guarantee_period_months` BIGINT COMMENT 'Number of months the benefit is guaranteed.',
    `indexation_rate` DECIMAL(5,4) COMMENT 'Annual indexation rate applied to the benefit.',
    `indexation_type` STRING COMMENT 'Method used for indexation.. Valid values are `cpi|fixed|none`',
    `number` STRING COMMENT 'External reference number for the entitlement.',
    `survivor_benefit_percentage` DECIMAL(5,2) COMMENT 'Percentage of the benefit allocated to the survivor.',
    `survivor_relationship` STRING COMMENT 'Relationship of the survivor to the member.. Valid values are `spouse|child|parent|other`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the entitlement record was last updated.',
    CONSTRAINT pk_entitlement PRIMARY KEY(`entitlement_id`)
) COMMENT 'Master record and authoritative source for the calculated pension entitlement owed to a member at a given point in time or benefit trigger (retirement, death, termination).';

CREATE OR REPLACE TABLE `asset_management`.`beneficiary`.`benefit_payment` (
    `benefit_payment_id` BIGINT COMMENT 'Unique identifier for the benefit payment transaction.',
    `designated_beneficiary_id` BIGINT COMMENT 'Identifier linking the payment to the pension plan member.',
    `cash_transfer_id` BIGINT COMMENT 'Foreign key linking to treasury.cash_transfer. Business justification: Associates each benefit payment with the actual cash transfer for settlement and reporting.',
    `entitlement_id` BIGINT COMMENT 'Foreign key linking to beneficiary.entitlement. Business justification: Benefit payments are disbursed against a calculated entitlement. This FK links the payment to the specific entitlement record it satisfies.',
    `member_id` BIGINT COMMENT 'Identifier linking the payment to the pension plan member.',
    `clawback_amount` DECIMAL(18,2) COMMENT 'Amount recovered due to overpayment or error.',
    `currency_code` STRING COMMENT 'ISO 4217 currency code for the payment amounts.',
    `gross_amount` DECIMAL(18,2) COMMENT 'Total payment amount before deductions.',
    `net_amount` DECIMAL(18,2) COMMENT 'Net amount paid to the beneficiary after deductions.',
    `overpayment_recovery_amount` DECIMAL(18,2) COMMENT 'Amount recovered from an overpayment event.',
    `payment_approval_by` STRING COMMENT 'Identifier of the approver of the payment.',
    `payment_approval_date` TIMESTAMP COMMENT 'Timestamp when the payment was approved.',
    `payment_approval_status` STRING COMMENT 'Approval status of the payment transaction.. Valid values are `approved|pending|rejected`',
    `payment_channel` STRING COMMENT 'Interface through which the payment was processed.. Valid values are `online|branch|mobile`',
    `payment_date` DATE COMMENT 'Date the payment was issued to the beneficiary.',
    `payment_dispute_amount` DECIMAL(18,2) COMMENT 'Amount involved in the dispute.',
    `payment_dispute_currency` STRING COMMENT 'Currency of the disputed amount.',
    `payment_dispute_date` DATE COMMENT 'Date the dispute was raised.',
    `payment_dispute_reason` STRING COMMENT 'Reason for the payment dispute.',
    `payment_dispute_status` STRING COMMENT 'Status of any dispute related to the payment.. Valid values are `none|raised|resolved`',
    `payment_frequency` STRING COMMENT 'Frequency of recurring payments.. Valid values are `monthly|quarterly|annual|lump_sum`',
    `payment_frequency_end_date` DATE COMMENT 'End date of the payment frequency schedule.',
    `payment_frequency_interval` BIGINT COMMENT 'Number of units between recurring payments.',
    `payment_frequency_last_paid_date` DATE COMMENT 'Date of the most recent payment in the frequency schedule.',
    `payment_frequency_next_due_amount` DECIMAL(18,2) COMMENT 'Amount scheduled for the next recurring payment.',
    `payment_frequency_next_due_channel` STRING COMMENT 'Interface for the next scheduled payment.',
    `payment_frequency_next_due_date` DATE COMMENT 'Next scheduled payment date in the frequency schedule.',
    `payment_frequency_next_due_method` STRING COMMENT 'Instrument for the next scheduled payment.',
    `payment_frequency_next_due_status` STRING COMMENT 'Status of the next scheduled payment.. Valid values are `due|paid|overdue`',
    `payment_frequency_start_date` DATE COMMENT 'Start date of the payment frequency schedule.',
    `payment_method` STRING COMMENT 'Instrument used to deliver the payment.. Valid values are `direct_deposit|cheque|cash|wire_transfer`',
    `payment_notes` STRING COMMENT 'Free text notes related to the payment transaction.',
    `payment_reference_number` STRING COMMENT 'Internal reference used to track the payment transaction.. Valid values are `^[A-Z0-9]{8,20}$`',
    `payment_settlement_amount` DECIMAL(18,2) COMMENT 'Amount settled to the beneficiary.',
    `payment_settlement_channel` STRING COMMENT 'Interface used for settlement.. Valid values are `online|branch`',
    `payment_settlement_date` DATE COMMENT 'Date the payment was settled.',
    `payment_settlement_method` STRING COMMENT 'Instrument used for settlement.. Valid values are `bank_transfer|cheque|cash`',
    `payment_settlement_notes` STRING COMMENT 'Free text notes related to settlement.',
    `payment_settlement_reference` STRING COMMENT 'Reference for the settlement transaction.',
    `payment_settlement_status` STRING COMMENT 'Status of the payment settlement process.. Valid values are `settled|pending|failed`',
    `payment_status` STRING COMMENT 'Current status of the payment transaction.. Valid values are `pending|processed|failed|cancelled|reversed`',
    `payment_time` TIMESTAMP COMMENT 'Timestamp of the payment issuance.',
    `record_audit_created` TIMESTAMP COMMENT 'Timestamp when the record was first created.',
    `record_audit_updated` TIMESTAMP COMMENT 'Timestamp when the record was last updated.',
    `tax_withholding_amount` DECIMAL(18,2) COMMENT 'Amount withheld for taxes from the gross payment.',
    CONSTRAINT pk_benefit_payment PRIMARY KEY(`benefit_payment_id`)
) COMMENT 'Transactional record of each pension benefit payment disbursed to a member or beneficiary. Captures gross pension amount, applicable deductions (tax withholding, clawbacks, overpayment recovery), net payment amount, payment method (direct deposit';

CREATE OR REPLACE TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` (
    `member_lifecycle_event_id` BIGINT COMMENT 'Unique identifier for the member lifecycle event record.',
    `contributor_pool_id` BIGINT COMMENT 'Foreign key linking to beneficiary.contributor_pool. Business justification: Lifecycle events occur within a contributor pool context. Normalizing event_contributor_pool_code STRING to FK.',
    `member_id` BIGINT COMMENT 'Identifier linking the event to the member (beneficiary) record.',
    `pension_plan_id` BIGINT COMMENT 'Identifier linking the event to the investment plan record.',
    `portfolio_id` BIGINT COMMENT 'Foreign key linking to portfolio.portfolio. Business justification: Lifecycle events such as retirement or transfer are plan-specific; linking to portfolio supports event-driven plan updates.',
    `event_approval_by` STRING COMMENT 'Identifier of the approver.',
    `event_approval_date` TIMESTAMP COMMENT 'Timestamp when the event was approved.',
    `event_approval_document_reference` STRING COMMENT 'Reference to the approval documentation.',
    `event_approval_status` STRING COMMENT 'Approval status of the event (if applicable).. Valid values are `pending|approved|rejected|cancelled`',
    `event_created_by_user` STRING COMMENT 'User who created the event record.',
    `event_created_timestamp` TIMESTAMP COMMENT 'Timestamp when the event record was first created.',
    `event_description` STRING COMMENT 'Detailed narrative describing the event.',
    `event_end_date` DATE COMMENT 'Date when the lifecycle event concluded or is expected to conclude.',
    `event_member_age_at_event` BIGINT COMMENT 'Age of the member at the time of the event.',
    `event_member_service_years` BIGINT COMMENT 'Total service years of the member at the time of the event.',
    `event_notes` STRING COMMENT 'Additional notes or remarks about the event.',
    `event_plan_type` STRING COMMENT 'Type of investment plan associated with the event.. Valid values are `public_equities|private_equities|real_estate|infrastructure|natural_resources|credit`',
    `event_reason_code` STRING COMMENT 'Code representing the reason for the event.',
    `event_reason_description` STRING COMMENT 'Narrative description of the event reason.',
    `event_source_system_code` STRING COMMENT 'Code of the system that originated the event record.',
    `event_source_system_device` STRING COMMENT 'Device used in the source system during event creation.',
    `event_source_system_ip` STRING COMMENT 'IP address of the source system during event creation.',
    `event_source_system_location` STRING COMMENT 'Physical location of the source system during event creation.',
    `event_source_system_name` STRING COMMENT 'Name of the originating system.',
    `event_source_system_reference_code` STRING COMMENT 'Identifier of the referenced object in the source system.',
    `event_source_system_reference_date` DATE COMMENT 'Date of the referenced object in the source system.',
    `event_source_system_reference_description` STRING COMMENT 'Description of the referenced object in the source system.',
    `event_source_system_reference_status` STRING COMMENT 'Status of the referenced object in the source system.',
    `event_source_system_reference_type` STRING COMMENT 'Type of the referenced object in the source system.',
    `event_source_system_reference_value` DECIMAL(18,2) COMMENT 'Value of the referenced object in the source system.',
    `event_source_system_user` STRING COMMENT 'User who performed the action in the source system.',
    `event_source_system_version` STRING COMMENT 'Version of the originating system.',
    `event_start_date` DATE COMMENT 'Date when the lifecycle event commenced.',
    `event_status` STRING COMMENT 'Current status of the event in its lifecycle.. Valid values are `pending|draft|completed|cancelled|approved|rejected`',
    `event_subtype` STRING COMMENT 'Specific subtype of the event for finer granularity.',
    `event_type` STRING COMMENT 'Category of lifecycle event (e.g., enrollment, retirement, death). [ENUM-REF-CANDIDATE: enrollment|active_service|leave_of_absence|disability|deferred_vesting|retirement_commencement|death|plan_termination — promote to reference product]',
    `event_updated_by_user` STRING COMMENT 'User who last updated the event record.',
    `event_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the event record was last updated.',
    CONSTRAINT pk_member_lifecycle_event PRIMARY KEY(`member_lifecycle_event_id`)
) COMMENT 'Transactional record capturing significant lifecycle state transitions for a plan member: enrollment, active service, leave of absence, disability, deferred vesting, retirement commencement, death, and plan termination.';

CREATE OR REPLACE TABLE `asset_management`.`beneficiary`.`designated_beneficiary` (
    `designated_beneficiary_id` BIGINT COMMENT 'Unique identifier for the designated beneficiary record.',
    `actor_id` BIGINT COMMENT 'Foreign key linking to shared.actor. Business justification: Designated beneficiaries (survivors, dependents) receiving death/survivor benefits are actors requiring KYC verification, tax reporting (annual tax slips), and payment processing.',
    `member_id` BIGINT COMMENT 'Identifier of the plan member who designated the beneficiary.',
    `address_line_1` STRING COMMENT 'Primary address line of the beneficiary.',
    `address_line_2` STRING COMMENT 'Secondary address line of the beneficiary.',
    `bank_account_number` STRING COMMENT 'Beneficiarys bank account number for payments.',
    `beneficiary_fraction_pct` DECIMAL(5,2) COMMENT 'Fraction of benefit allocated to the beneficiary.',
    `beneficiary_name` STRING COMMENT 'Full legal name of the designated beneficiary.',
    `beneficiary_status` STRING COMMENT 'Current lifecycle status of the beneficiary record.. Valid values are `active|inactive|terminated|pending`',
    `benefit_amount` DECIMAL(18,2) COMMENT 'Monetary amount of the benefit payment.',
    `benefit_commencement_date` DATE COMMENT 'Date when benefit payments commence.',
    `benefit_termination_date` DATE COMMENT 'Date when benefit payments terminate.',
    `benefit_type` STRING COMMENT 'Type of benefit payment to the beneficiary.. Valid values are `lump_sum|periodic`',
    `children_benefit_age_limit` BIGINT COMMENT 'Maximum age for child beneficiaries to receive benefits.',
    `city` STRING COMMENT 'City of the beneficiarys address.',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the beneficiarys address.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the record was created.',
    `currency_code` STRING COMMENT 'ISO 4217 currency code for the benefit amount.. Valid values are `^[A-Z]{3}$`',
    `date_of_birth` DATE COMMENT 'Date of birth of the designated beneficiary.',
    `death_cause_category` STRING COMMENT 'Category of cause of death.. Valid values are `natural|accident|suicide|other`',
    `death_certificate_reference` STRING COMMENT 'Reference to the death certificate document.',
    `death_date` DATE COMMENT 'Date of death of the beneficiary, if applicable.',
    `designation_date` DATE COMMENT 'Date the beneficiary was designated by the member.',
    `email_address` STRING COMMENT 'Primary email address of the beneficiary.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `gender` STRING COMMENT 'Gender of the beneficiary.. Valid values are `male|female|non-binary|other`',
    `guarantee_period_months` BIGINT COMMENT 'Guarantee period in months for the benefit.',
    `is_disabled_dependent` BOOLEAN COMMENT 'Indicates if beneficiary is a disabled dependent.',
    `is_full_time_student` BOOLEAN COMMENT 'Indicates if beneficiary is a full-time student.',
    `kyc_verification_date` DATE COMMENT 'Date when KYC verification was completed.',
    `kyc_verified` BOOLEAN COMMENT 'Flag indicating if beneficiary has passed KYC checks.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the last update to the record.',
    `lump_sum_amount` DECIMAL(18,2) COMMENT 'One-time lump sum payment amount to the beneficiary.',
    `marital_status` STRING COMMENT 'Marital status of the beneficiary.. Valid values are `single|married|divorced|widowed|separated`',
    `national_identifier` STRING COMMENT 'Government issued national identification number.',
    `payment_end_date` DATE COMMENT 'End date of benefit payments.',
    `payment_frequency` STRING COMMENT 'Frequency of benefit payments.. Valid values are `monthly|quarterly|annually|lump_sum`',
    `payment_method` STRING COMMENT 'Method used to disburse benefit payments.. Valid values are `bank_transfer|cheque|cash|mobile_wallet`',
    `payment_start_date` DATE COMMENT 'Start date of benefit payments.',
    `phone_number` STRING COMMENT 'Primary phone number of the beneficiary.. Valid values are `^+?[1-9]d{1,14}$`',
    `postal_code` STRING COMMENT 'Postal code of the beneficiarys address.. Valid values are `^[A-Z0-9 ]{3,10}$`',
    `province_state` STRING COMMENT 'Province or state of the beneficiarys address.',
    `relationship_type` STRING COMMENT 'Nature of the beneficiarys relationship to the plan member.. Valid values are `spouse|common_law_partner|dependent_child|estate`',
    `remarriage_termination_flag` BOOLEAN COMMENT 'Flag indicating termination due to remarriage.',
    `spouse_dob` DATE COMMENT 'Date of birth of the beneficiarys spouse.',
    `spouse_name` STRING COMMENT 'Full name of the beneficiarys spouse, if applicable.',
    `spouse_national_identifier` STRING COMMENT 'National ID of the beneficiarys spouse.',
    `tax_withholding_rate` DECIMAL(5,2) COMMENT 'Rate of tax withheld from benefit payments.',
    CONSTRAINT pk_designated_beneficiary PRIMARY KEY(`designated_beneficiary_id`)
) COMMENT 'Master record of the individuals designated by a plan member to receive survivor pension benefits or death-in-service lump sum payments. Stores beneficiary name, relationship to member (spouse, common-law partner, dependent child, estate), designation';

CREATE OR REPLACE TABLE `asset_management`.`beneficiary`.`member_address` (
    `member_address_id` BIGINT COMMENT 'Unique surrogate identifier for each member address record within the pension fund member address master.',
    `member_id` BIGINT COMMENT 'Reference to the pension plan member to whom this address belongs. Links address to the beneficiary master record.',
    `address_format_type` STRING COMMENT 'Identifies the address format convention applied to this record, enabling correct rendering of address components for correspondence in different countries.. Valid values are `north_american|european|uk|australian|international`',
    `address_line_1` STRING COMMENT 'Primary street address line including street number, street name, and street type (e.g., 123 Main Street). First line of the civic address.',
    `address_line_2` STRING COMMENT 'Secondary address line for suite, apartment, unit, floor, or building designator supplementing the primary street address line.',
    `address_line_3` STRING COMMENT 'Tertiary address line used for additional delivery instructions, care-of designations, or rural route information where required.',
    `address_notes` STRING COMMENT 'Free-text field for additional address delivery instructions, special handling notes, or contextual information not captured in structured address fields.',
    `address_source` STRING COMMENT 'Identifies the originating channel or system through which this address was captured (e.g., member self-service portal, employer HR submission, plan administrator entry).. Valid values are `member_self_service|employer_submission|plan_administrator|correspondence_return|third_party|migration`',
    `address_status` STRING COMMENT 'Current lifecycle status of the address record. Active indicates the address is in use; undeliverable indicates returned mail; superseded indicates replaced by a newer record.. Valid values are `active|inactive|undeliverable|pending_verification|superseded`',
    `address_type` STRING COMMENT 'Classifies the functional purpose of the address record (e.g., residential home address, mailing/correspondence address, employer workplace address). [ENUM-REF-CANDIDATE: residential|mailing|employer|temporary|seasonal|overseas — promote to reference. Valid values are `residential|mailing|employer|temporary|seasonal|overseas`',
    `care_of_name` STRING COMMENT 'Name of the individual or entity at the address to whom correspondence should be directed on behalf of the member (e.g., legal guardian, power of attorney, estate trustee).',
    `city` STRING COMMENT 'Municipality or city name component of the address. Used for geographic segmentation, regional reporting, and correspondence routing.',
    `consent_recorded_date` DATE COMMENT 'Date on which the members consent to use this address for correspondence and data processing was recorded. Supports GDPR and applicable privacy law consent management obligations.',
    `contributor_pool` STRING COMMENT 'Identifies the pension contributor pool to which the member belongs (one per participating plan). Supports pool-specific correspondence and regulatory reporting.. Valid values are `plan_1|plan_2|plan_3|plan_4`',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 three-letter country code for the address (e.g., CAN, USA, GBR). Supports international member correspondence and regulatory jurisdiction determination.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this address record was first created in the system. Supports audit trail, data lineage, and regulatory record-keeping requirements.',
    `delivery_point_barcode` STRING COMMENT 'Standardized postal delivery point barcode assigned by postal authority (USPS DPBC) to uniquely identify the physical delivery point. Supports automated mail sorting.',
    `do_not_mail` BOOLEAN COMMENT 'Indicates that physical correspondence must not be sent to this address per member instruction, legal order, or returned mail policy. Overrides standard mailing workflows.',
    `do_not_mail_reason` STRING COMMENT 'Reason code explaining why physical correspondence is suppressed for this address. Supports compliance audit trails and member communication management.. Valid values are `member_request|legal_order|undeliverable|deceased|address_unknown|privacy_concern`',
    `effective_from` DATE COMMENT 'Date from which this address record is considered valid and active for the member. Supports temporal address history and point-in-time reporting.',
    `effective_to` DATE COMMENT 'Date on which this address record ceases to be valid. Null indicates the address is currently active. Enables historical address tracking for audit and compliance.',
    `employer_department` STRING COMMENT 'Government department, ministry, or organizational unit within the employer associated with the employer address. Supports employer-level reporting and contribution reconciliation.',
    `employer_name` STRING COMMENT 'Name of the employer associated with an employer address type. Applicable when address_type is employer; identifies the government department or agency where the member is employed.',
    `foreign_address_flag` BOOLEAN COMMENT 'Indicates whether this address is located outside the home country. Triggers additional regulatory, tax withholding, and foreign pension payment processing requirements.',
    `is_mailing_preferred` BOOLEAN COMMENT 'Indicates whether this address is the members preferred address for all pension correspondence, benefit statements, and regulatory notices.',
    `is_primary` BOOLEAN COMMENT 'Indicates whether this address is the primary address of its type for the member. Only one address per address type per member should be flagged as primary at any time.',
    `language_preference` STRING COMMENT 'Preferred official language for correspondence sent to this address (for example English or French). Supports language-of-correspondence obligations.. Valid values are `EN|FR`',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this address record. Supports change tracking, audit compliance, and data freshness monitoring.',
    `latitude` DOUBLE COMMENT 'Geographic latitude coordinate of the address in decimal degrees (WGS 84). Supports geospatial analytics, regional benefit distribution analysis, and member demographic mapping.',
    `longitude` DOUBLE COMMENT 'Geographic longitude coordinate of the address in decimal degrees (WGS 84). Supports geospatial analytics, regional benefit distribution analysis, and member demographic mapping.',
    `po_box` STRING COMMENT 'Post office box number for members who receive mail at a PO Box rather than a civic street address. Used as an alternative delivery point.',
    `postal_code` STRING COMMENT 'Postal or ZIP code component of the address. Format varies by country (e.g., UK SW1A 1AA, US 12345). Used for mail delivery and geographic analysis.. Valid values are `^[A-Za-z0-9 -]{3,10}$`',
    `province_state` STRING COMMENT 'Province, state, or territory component of the address using standard two-letter postal abbreviation (e.g., ON, BC, NY). Supports regional liability and regulatory reporting.',
    `rural_route` STRING COMMENT 'Rural route or rural delivery route designator for members residing in rural areas not served by standard civic addressing (e.g., RR 2, SS 1).',
    `source_system_code` STRING COMMENT 'Identifies the operational system of record from which this address record originated (e.g., SimCorp Dimension, SAP SuccessFactors, member self-service portal). Supports data lineage.',
    `source_system_ref` STRING COMMENT 'The native identifier or record key assigned to this address in the originating source system (e.g., SimCorp party address ID, SAP SuccessFactors address sequence). Supports reconciliation.',
    `standardized_address` STRING COMMENT 'Full address formatted according to postal authority standards (e.g., USPS or Royal Mail) as a single concatenated string. Generated post-verification for mail production and deduplication.',
    `tax_jurisdiction_code` STRING COMMENT 'Tax jurisdiction code derived from the address location, used to determine applicable withholding tax rates and reporting obligations for pension benefit payments.',
    `undeliverable_date` DATE COMMENT 'Date on which correspondence sent to this address was returned as undeliverable. Triggers member address update workflow and suppresses further mailings.',
    `undeliverable_reason` STRING COMMENT 'Reason code from postal authority or courier indicating why correspondence was returned undeliverable. Supports member tracing and address remediation workflows.. Valid values are `moved_no_forwarding|unknown_address|insufficient_address|refused|vacant|deceased`',
    `verification_date` DATE COMMENT 'Date on which the address was last validated against a postal authority or third-party address verification service. Supports data quality monitoring.',
    `verification_source` STRING COMMENT 'Identifies the system or method used to verify the address (e.g., USPS CASS, Royal Mail PAF, manual review). [ENUM-REF-CANDIDATE: usps_cass|royal_mail_paf|manual|member_self_service|employer_submission|third_party — promote to reference',
    `verification_status` STRING COMMENT 'Indicates the outcome of address validation against postal authority databases (e.g., USPS CASS, Royal Mail PAF). Supports data quality management and undeliverable mail reduction.. Valid values are `verified|unverified|failed|pending|override`',
    CONSTRAINT pk_member_address PRIMARY KEY(`member_address_id`)
) COMMENT 'Master record of all physical and mailing addresses associated with a plan member, including residential address, mailing address, and employer address. Tracks address type, full address components (street, city, province/state, postal code, country)';

CREATE OR REPLACE TABLE `asset_management`.`beneficiary`.`member_contact` (
    `member_contact_id` BIGINT COMMENT 'Unique surrogate identifier for each member contact record within the pension fund member contact master.',
    `member_id` BIGINT COMMENT 'Reference to the pension plan member to whom this contact record belongs. Links contact details to the beneficiary master.',
    `bounce_count` BIGINT COMMENT 'Cumulative number of delivery failures or bounces recorded against this contact record. Used to determine when to deactivate or flag a contact for re-verification.',
    `communication_frequency_pref` STRING COMMENT 'Members stated preference for how frequently they wish to receive communications via this contact channel. Governs outbound notification scheduling.. Valid values are `immediate|daily_digest|weekly|monthly|annual_only|none`',
    `consent_evidence_ref` STRING COMMENT 'Reference identifier or document locator for the consent evidence record (e.g., form ID, call recording reference) supporting the opt-in or opt-out decision.',
    `consent_source` STRING COMMENT 'Channel or mechanism through which the members communication consent was captured (e.g., member portal, paper form, call centre, employer submission).. Valid values are `member_portal|paper_form|call_centre|employer_submission|third_party`',
    `contact_status` STRING COMMENT 'Current lifecycle status of the contact record indicating whether it is active, inactive, unverified, bounced (for email), or opted out by the member.. Valid values are `active|inactive|unverified|bounced|opted_out`',
    `contact_subtype` STRING COMMENT 'Further classification of the contact record indicating its relationship context such as personal, business, emergency, legal guardian, or power of attorney.. Valid values are `personal|business|emergency|legal_guardian|power_of_attorney`',
    `contact_type` STRING COMMENT 'Classification of the contact channel or medium (e.g., mobile, home phone, work phone, email, fax, postal address). [ENUM-REF-CANDIDATE: mobile|home_phone|work_phone|email|fax|postal_address — promote to reference product]. Valid values are `mobile|home_phone|work_phone|email|fax|postal_address`',
    `contact_value` DECIMAL(18,2) COMMENT 'The actual contact detail for the given contact type (e.g., phone number, email address, or postal address string). Classified as restricted PII.',
    `contributor_pool` STRING COMMENT 'Pension contributor pool to which the member belongs (one per participating plan). Drives communication regulatory requirements and plan rules.. Valid values are `plan_1|plan_2|plan_3|plan_4`',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code associated with this contact record, used for international dialling prefix resolution and regulatory jurisdiction determination.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this contact record was first created in the system. Supports audit trail and data lineage requirements per GDPR.',
    `data_retention_category` STRING COMMENT 'Retention classification applied to this contact record determining the applicable data retention schedule per regulatory and pension plan rules.. Valid values are `active_member|deferred_member|pensioner|deceased|purge_eligible`',
    `do_not_contact` BOOLEAN COMMENT 'Hard suppression flag indicating the member has explicitly requested no communications via this contact channel. Overrides all other opt-in preferences.',
    `do_not_contact_reason` STRING COMMENT 'Reason code explaining why the do-not-contact flag has been set (e.g., member request, legal hold, deceased, regulatory order). Required for compliance audit.. Valid values are `member_request|legal_hold|deceased|incapacitated|regulatory_order|fraud_flag`',
    `effective_from_date` DATE COMMENT 'Date from which this contact record is considered valid and active for the member. Supports bi-temporal modelling of contact history for regulatory audit.',
    `effective_to_date` DATE COMMENT 'Date on which this contact record ceased to be valid. Null for currently active records. Supports bi-temporal history and superseded contact tracking.',
    `email_domain` STRING COMMENT 'Domain portion of the email address (e.g., gmail.com, gov.uk) extracted for deliverability analytics and employer affiliation inference. Null for non-email contact types.',
    `gdpr_lawful_basis` STRING COMMENT 'GDPR Article 6 lawful basis under which this contact data is processed. Required for members subject to GDPR jurisdiction (e.g., UK, EU residents).. Valid values are `consent|legal_obligation|legitimate_interest|vital_interest|public_task|contract`',
    `is_primary` BOOLEAN COMMENT 'Indicates whether this contact record is the primary contact method for the member within its contact type. Only one record per contact type per member should be flagged true.',
    `is_verified` BOOLEAN COMMENT 'Indicates whether this contact detail has been verified through a formal verification process (e.g., email confirmation link, phone OTP, postal confirmation letter).',
    `language_preference` STRING COMMENT 'Members preferred language for communications via this contact channel, expressed as a BCP 47 language tag (e.g., en-US, fr-FR). Supports multilingual regulatory obligations.. Valid values are `^[a-z]{2}(-[A-Z]{2})?$`',
    `last_bounce_date` DATE COMMENT 'Most recent date on which a communication attempt via this contact channel resulted in a delivery failure or bounce. Used to trigger contact re-verification workflows.',
    `last_used_date` DATE COMMENT 'Most recent date on which this contact channel was used to successfully communicate with the member (e.g., statement delivered, notification sent). Supports contact hygiene.',
    `notes` STRING COMMENT 'Free-text operational notes recorded by pension administration staff regarding this contact record (e.g., member requested contact update via call centre on specific date).',
    `opt_in_date` DATE COMMENT 'Date on which the member provided explicit consent to receive digital communications via this contact channel. Required for regulatory consent audit trail.',
    `opt_in_digital` BOOLEAN COMMENT 'Indicates whether the member has opted in to receive digital communications (email, SMS) via this contact. Required for CASL and GDPR consent tracking.',
    `opt_out_date` DATE COMMENT 'Date on which the member withdrew consent or opted out of digital communications via this contact channel. Null if the member has not opted out.',
    `phone_country_dial_code` STRING COMMENT 'International telephone country dialling prefix (e.g., +1, +44) applicable when contact_type is a phone-based channel. Null for non-phone contact types.. Valid values are `^+[0-9]{1,4}$`',
    `phone_extension` STRING COMMENT 'Internal telephone extension number appended to the main phone number for work phone contact types. Null for mobile, home, or non-phone contact types.. Valid values are `^[0-9]{1,10}$`',
    `preferred_channel` BOOLEAN COMMENT 'Indicates whether this contact record represents the members preferred communication channel across all contact types for outbound member communications.',
    `purge_eligible_date` DATE COMMENT 'Date on or after which this contact record is eligible for deletion or anonymisation under the applicable data retention schedule. Null if retention period has not elapsed.',
    `source_system_ref` STRING COMMENT 'Unique identifier of this contact record in the originating source system (e.g., SAP SuccessFactors person contact ID). Enables lineage tracing and reconciliation.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this contact record. Used for change detection, audit trail, and incremental data pipeline processing.',
    `verification_date` DATE COMMENT 'Date on which the contact detail was successfully verified. Null if the contact has not been verified or verification is pending.',
    `verification_method` STRING COMMENT 'Method used to verify the contact detail (e.g., email confirmation link, SMS one-time password, postal letter, call centre agent confirmation). Null if not yet verified.. Valid values are `email_link|sms_otp|postal_letter|call_centre|employer_confirmed|not_verified`',
    CONSTRAINT pk_member_contact PRIMARY KEY(`member_contact_id`)
) COMMENT 'Master record of contact information for a plan member including phone numbers, email addresses, and preferred communication channel. Stores contact type (mobile, home, work, email), contact value, is_primary flag, opt-in/opt-out preferences for digital';

CREATE OR REPLACE TABLE `asset_management`.`beneficiary`.`contribution_rate` (
    `contribution_rate_id` BIGINT COMMENT 'Unique surrogate identifier for a contribution rate schedule record within the pension fund system.',
    `contributor_pool_id` BIGINT COMMENT 'Foreign key linking to beneficiary.contributor_pool. Business justification: Contribution_rate defines a rate for a specific contributor pool; linking to contributor_pool ensures referential integrity and removes the redundant contributor_pool string',
    `actuarial_valuation_year` BIGINT COMMENT 'The year of the actuarial valuation report that determined or last confirmed this contribution rate, linking the rate to its actuarial basis.',
    `approval_date` DATE COMMENT 'The date on which this contribution rate schedule was formally approved by the relevant governing authority or Investment Committee.',
    `approved_by` STRING COMMENT 'Name or identifier of the authority, committee, or official who approved this contribution rate schedule (e.g., plan sponsor resolution, IC Resolution 2024-07).',
    `contribution_frequency` STRING COMMENT 'The payroll frequency at which contributions are deducted and remitted under this rate schedule (e.g., bi-weekly, monthly).. Valid values are `bi_weekly|monthly|semi_monthly|weekly`',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this contribution rate record was first created in the system, used for audit trail and data lineage.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the earnings thresholds and monetary fields on this rate schedule (e.g., USD).. Valid values are `^[A-Z]{3}$`',
    `earnings_threshold_lower` DECIMAL(18,2) COMMENT 'The lower bound of the pensionable earnings band (in the plan currency) to which this rate tier applies. Null or zero indicates no lower bound.',
    `earnings_threshold_upper` DECIMAL(18,2) COMMENT 'The upper bound of the pensionable earnings band (in the plan currency) to which this rate tier applies. Null indicates no upper cap (top tier).',
    `effective_from` DATE COMMENT 'The date from which this contribution rate schedule becomes binding and applicable to member payroll deductions.',
    `effective_until` DATE COMMENT 'The date on which this contribution rate schedule ceases to be applicable. Null indicates the schedule is open-ended and currently in force.',
    `employment_category` STRING COMMENT 'The employment category of members to which this rate applies, as different employment categories may attract different contribution rates.. Valid values are `full_time|part_time|casual|contract`',
    `gazette_reference` STRING COMMENT 'The official government gazette or regulatory publication reference number where this rate was published or enacted (e.g., Federal Register Vol. 89 No. 12).',
    `indexation_basis` STRING COMMENT 'The basis on which this contribution rate is indexed or adjusted over time: CPI (Consumer Price Index), fixed increment, negotiated, or none.. Valid values are `cpi|fixed|none|negotiated`',
    `indexation_rate` DECIMAL(8,6) COMMENT 'The annual indexation rate applied to adjust the contribution rate or earnings thresholds, expressed as a decimal (e.g., 0.02 = 2%). Null if indexation_basis is none.',
    `is_mandatory` BOOLEAN COMMENT 'Indicates whether participation and contribution at this rate is mandatory (True) or voluntary/optional (False) for eligible members.',
    `is_tax_deductible` BOOLEAN COMMENT 'Indicates whether contributions made at this rate are tax-deductible for the member under applicable income tax legislation.',
    `jurisdiction_code` STRING COMMENT 'ISO 3166-1 alpha-2 or alpha-3 country/province code identifying the jurisdiction under whose laws this contribution rate is governed (e.g., CAN).. Valid values are `^[A-Z]{2,3}$`',
    `last_updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this contribution rate record was most recently modified, supporting change tracking and audit compliance.',
    `legislative_authority` STRING COMMENT 'The specific act, regulation, or statutory instrument that mandates or authorises this contribution rate (e.g., the governing plan statute).',
    `max_pensionable_earnings` DECIMAL(18,2) COMMENT 'The annual maximum pensionable earnings cap (in currency_code) above which contributions are not required under this rate schedule.',
    `min_pensionable_earnings` DECIMAL(18,2) COMMENT 'The annual minimum pensionable earnings floor (in currency_code) below which contributions are not required under this rate schedule.',
    `plan_type` STRING COMMENT 'The type of pension plan to which this rate schedule applies: defined benefit (DB), defined contribution (DC), or hybrid.. Valid values are `defined_benefit|defined_contribution|hybrid`',
    `rate_code` STRING COMMENT 'Externally-known alphanumeric code uniquely identifying this contribution rate schedule, used in regulatory filings and system integrations.. Valid values are `^[A-Z0-9_-]{3,30}$`',
    `rate_description` STRING COMMENT 'Free-text description providing additional context about the rate schedule, including any special conditions, exceptions, or transitional provisions.',
    `rate_name` STRING COMMENT 'Human-readable name describing the contribution rate schedule (e.g., Plan 1 Tier 1 Employee Rate 2024).',
    `rate_percent` DECIMAL(8,6) COMMENT 'The contribution rate expressed as a decimal percentage of pensionable earnings (e.g., 0.0895 = 8.95%). This is the principal quantitative fact of the rate schedule.',
    `rate_status` STRING COMMENT 'Current lifecycle status of the rate schedule: active (in force), pending (approved but not yet effective), superseded (replaced by a newer schedule), or withdrawn.. Valid values are `active|superseded|pending|withdrawn`',
    `rate_tier` STRING COMMENT 'Tier label or band designation within a tiered rate structure (e.g., Tier 1, Tier 2, Tier 3) based on pensionable earnings thresholds. [ENUM-REF-CANDIDATE: tier_1|tier_2|tier_3|tier_4|tier_5|tier_6|tier_7 — promote to reference product]',
    `rate_type` STRING COMMENT 'Indicates whether this rate applies to the employee (member) contribution, the employer  contribution, or a combined rate.. Valid values are `employee|employer|combined`',
    `regulatory_basis` STRING COMMENT 'The regulatory framework, actuarial valuation report, or government directive that provides the basis for setting this rate (e.g., Actuarial Report 2022 — the national pension regulator).',
    `service_category` STRING COMMENT 'The service category applicable to this rate (e.g., regular service, reserve service, secondment, leave without pay), which may affect the applicable rate.. Valid values are `regular|reserve|secondment|leave_without_pay`',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record from which this rate schedule was sourced (e.g., SIMCORP, ORACLE_FIN, MANUAL).',
    `superseded_by_rate_code` STRING COMMENT 'The rate_code of the successor contribution rate schedule that replaced this record when rate_status is superseded. Null if not superseded.. Valid values are `^[A-Z0-9_-]{3,30}$`',
    `version_number` BIGINT COMMENT 'Monotonically increasing version number for this rate schedule record, supporting audit trail and temporal versioning of rate changes.',
    CONSTRAINT pk_contribution_rate PRIMARY KEY(`contribution_rate_id`)
) COMMENT 'Reference entity defining the contribution rate schedules applicable to each contributor pool, including employee and employer rate tiers, effective date ranges, pensionable earnings thresholds, and the legislative or regulatory basis for each rate.';

CREATE OR REPLACE TABLE `asset_management`.`beneficiary`.`service_buyback` (
    `service_buyback_id` BIGINT COMMENT 'Unique surrogate identifier for a service buyback election record. Primary key for this transactional entity.',
    `assumption_set_id` BIGINT COMMENT 'Foreign key linking to actuarial.assumption_set. Business justification: Service buyback actuarial costs are calculated using specific discount rates and mortality assumptions.',
    `contributor_pool_id` BIGINT COMMENT 'Reference to the contributor pool (one per participating plan) under which this buyback election is filed.',
    `member_id` BIGINT COMMENT 'Reference to the pension plan member who elected to purchase additional pensionable service credits via this buyback transaction.',
    `pension_plan_id` BIGINT COMMENT 'Reference to the specific pension plan under which the service buyback is being processed.',
    `actuarial_cost_amount` DECIMAL(18,2) COMMENT 'Total actuarially determined cost for the member to purchase the specified service credits, calculated by the pension funds actuaries based on age, salary, and service factors.',
    `actuarial_cost_basis` STRING COMMENT 'Actuarial methodology used to calculate the buyback cost: prospective (future benefit cost), retrospective (past contributions with interest), or blended.. Valid values are `prospective|retrospective|blended`',
    `actuarial_cost_currency` STRING COMMENT 'ISO 4217 three-letter currency code in which the actuarial cost amount is denominated (e.g., USD, GBP).. Valid values are `^[A-Z]{3}$`',
    `actuarial_valuation_date` DATE COMMENT 'The reference date used by the actuary to calculate the cost of the buyback, reflecting salary and demographic assumptions as of that date.',
    `application_received_timestamp` TIMESTAMP COMMENT 'Exact date and time the members buyback application was received and recorded in the pension administration system.',
    `approval_date` DATE COMMENT 'Date on which the buyback election was formally approved by the pension administration authority following eligibility and actuarial review.',
    `approved_by` STRING COMMENT 'Name or identifier of the pension administration officer who approved the buyback election after eligibility verification and actuarial costing.',
    `buyback_reference_number` STRING COMMENT 'Externally-known unique alphanumeric reference number assigned to this buyback election, used in member correspondence and administrative processing.. Valid values are `^SBB-[0-9]{4}-[0-9]{8}$`',
    `buyback_status` STRING COMMENT 'Current lifecycle status of the buyback election, tracking progression from member application through actuarial costing, payment, and credit posting. [ENUM-REF-CANDIDATE: pending|approved|in_progress|completed|cancelled|rejected — promote to reference. Valid values are `pending|approved|in_progress|completed|cancelled|rejected`',
    `cancellation_date` DATE COMMENT 'Date on which the buyback election was cancelled, either by member withdrawal or administrative rejection. Null if not cancelled.',
    `cancellation_reason` STRING COMMENT 'Reason code for cancellation of the buyback election, used for administrative reporting and member communication. [ENUM-REF-CANDIDATE: member_withdrawal|payment_default|ineligibility_determined|plan_rule_change|administrative_error|other — promote to. Valid values are `member_withdrawal|payment_default|ineligibility_determined|plan_rule_change|administrative_error|other`',
    `completion_date` DATE COMMENT 'Date on which all buyback payments were received in full and the pensionable service credits were formally posted to the members record.',
    `election_date` DATE COMMENT 'The date on which the member formally elected to purchase additional pensionable service credits, establishing the effective date for actuarial cost calculation.',
    `eligibility_verification_date` DATE COMMENT 'Date on which the members eligibility for the buyback was formally verified and confirmed by the pension administration team.',
    `eligibility_verified` BOOLEAN COMMENT 'Indicates whether the members eligibility for this buyback has been formally verified by the pension administration team against plan rules and service records.',
    `employer_contribution_amount` DECIMAL(18,2) COMMENT 'Employers share of the buyback cost, if applicable under the plan rules or collective agreement, credited alongside the members own contribution.',
    `gl_account_code` STRING COMMENT 'Oracle Financials GL account code to which the buyback contribution receipts are posted for pension fund accounting and financial reporting purposes.',
    `installment_amount` DECIMAL(18,2) COMMENT 'Amount of each periodic installment payment when the member elects an installment payment plan for the buyback.',
    `installment_count` BIGINT COMMENT 'Total number of installment payments agreed upon when the member elects an installment payment method for the buyback. Null if lump sum.',
    `installment_frequency` STRING COMMENT 'Frequency of installment payments when the member elects a periodic payment plan for the buyback cost.. Valid values are `weekly|bi_weekly|monthly|quarterly|annually`',
    `interest_accrued_amount` DECIMAL(18,2) COMMENT 'Total interest accrued on the outstanding buyback balance to date, added to the members obligation when payment is deferred beyond the election date.',
    `interest_rate` DECIMAL(8,6) COMMENT 'Annual interest rate applied to deferred or installment buyback payments, as prescribed by plan rules or actuarial assumptions (e.g., based on SOFR or plan-specific rate).',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this buyback record, supporting audit trail and change tracking requirements.',
    `member_age_at_election` DECIMAL(5,2) COMMENT 'Members age in years (to two decimal places) at the time of the buyback election, a key actuarial input for cost determination.',
    `member_contribution_amount` DECIMAL(18,2) COMMENT 'Total amount the member is required to contribute (employee share) toward the buyback cost, net of any employer or government subsidy.',
    `notes` STRING COMMENT 'Free-text field for pension administration staff to record relevant notes, exceptions, or special circumstances related to this buyback election.',
    `outstanding_balance_amount` DECIMAL(18,2) COMMENT 'Remaining unpaid balance on the buyback cost, calculated as actuarial cost minus total paid amount. Drives collection and reminder workflows.',
    `payment_deadline_date` DATE COMMENT 'Final date by which the member must complete all buyback payments to secure the pensionable service credits, as stipulated in the buyback agreement.',
    `payment_method` STRING COMMENT 'Method elected by the member to fund the buyback cost, such as lump sum, installment plan, payroll deduction, retirement account transfer, or pension transfer.. Valid values are `lump_sum|installment|payroll_deduction|retirement_account_transfer|pension_transfer`',
    `pension_adjustment_amount` DECIMAL(18,2) COMMENT 'Pension Adjustment amount reported to tax authorities reflecting the value of the pension benefit accrued through the buyback, reducing the members tax-advantaged contribution room.',
    `prior_service_end_date` DATE COMMENT 'End date of the prior non-contributory service period being purchased as pensionable service credits.',
    `prior_service_start_date` DATE COMMENT 'Start date of the prior non-contributory service period being purchased as pensionable service credits.',
    `prior_service_type` STRING COMMENT 'Classification of the non-contributory prior service period being purchased, determining eligibility rules and actuarial cost methodology. [ENUM-REF-CANDIDATE',
    `salary_used_for_costing` DECIMAL(18,2) COMMENT 'Annual salary figure used as the basis for actuarial cost calculation of the buyback, typically the members salary at the election date or a plan-defined reference salary.',
    `service_credit_posted_date` DATE COMMENT 'Date on which the purchased pensionable service credits were officially recorded in the members service history, updating entitlement calculations.',
    `service_credits_purchased_years` DECIMAL(6,4) COMMENT 'Total number of pensionable service years being purchased through this buyback election, expressed as a decimal fraction of a year.',
    `source_system_reference` STRING COMMENT 'Identifier of the originating pension administration system record (e.g., SimCorp Dimension member record ID) from which this buyback data was sourced.',
    `supporting_document_reference` STRING COMMENT 'Reference identifier for supporting documentation (e.g., leave records, prior employment verification, military service records) submitted with the buyback application.',
    `tax_receipt_issued` BOOLEAN COMMENT 'Indicates whether a tax receipt (e.g., pension adjustment or retirement contribution receipt) has been issued to the member for the buyback payment.',
    `tax_receipt_year` BIGINT COMMENT 'Tax year for which the buyback tax receipt was issued to the member, used for annual tax reporting and reconciliation.',
    `total_paid_amount` DECIMAL(18,2) COMMENT 'Cumulative amount received from the member to date against the total buyback cost, used to track payment progress and outstanding balance.',
    CONSTRAINT pk_service_buyback PRIMARY KEY(`service_buyback_id`)
) COMMENT 'Transactional record of a members election to purchase additional pensionable service credits for prior periods of non-contributory service (e.g., maternity/parental leave, prior public-sector employment, military service).';

CREATE OR REPLACE TABLE `asset_management`.`beneficiary`.`transfer_in` (
    `transfer_in_id` BIGINT COMMENT 'Unique surrogate identifier for each pension transfer-in transaction record within the fund.',
    `designated_beneficiary_id` BIGINT COMMENT 'Reference to the pension plan member on whose behalf the transfer-in is being received.',
    `cash_transfer_id` BIGINT COMMENT 'Foreign key linking to treasury.cash_transfer. Business justification: Links member transfer‑in records to the treasury transfer for reconciliation of incoming cash.',
    `contributor_pool_id` BIGINT COMMENT 'Foreign key linking to beneficiary.contributor_pool. Business justification: Transfer-in records specify which contributor pool the member is joining. Normalizing STRING to FK.',
    `member_id` BIGINT COMMENT 'Reference to the pension plan member on whose behalf the transfer-in is being received.',
    `pension_plan_id` BIGINT COMMENT 'Foreign key linking to beneficiary.pension_plan. Business justification: Transfer-in records represent pension assets transferred INTO a specific pension plan. The plan_id FK is essential for tracking which plan receives the transfer.',
    `portfolio_id` BIGINT COMMENT 'Foreign key linking to portfolio.portfolio. Business justification: Transfers into a plan require portfolio context for valuation and accounting.',
    `actuarial_basis` STRING COMMENT 'Description of the actuarial assumptions and methodology used to calculate the commuted value, including discount rate, mortality table, and projection basis.',
    `aml_screened` BOOLEAN COMMENT 'Indicates whether the transfer-in has been screened against AML/CTF watchlists and sanctions lists as required by the financial intelligence unit and FATF standards.',
    `commuted_value` DECIMAL(20,4) COMMENT 'Actuarially determined lump-sum present value of the members accrued pension entitlement from the source plan, as calculated per actuarial standards body standards.',
    `tax_authority_approval_date` DATE COMMENT 'Date on which the tax authority granted approval for the transfer-in, where such approval was required.',
    `tax_authority_approval_reference` STRING COMMENT 'Reference number issued by the tax authority confirming approval of the transfer-in transaction.',
    `tax_authority_approval_required` BOOLEAN COMMENT 'Indicates whether the tax authority approval is required for this transfer-in, typically applicable for past service pension adjustments exceeding thresholds.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this transfer-in record was first created in the system, used for audit trail and data lineage purposes.',
    `custodian_reference` STRING COMMENT 'Reference number assigned by the funds custodian (State Street / Northern Trust) to the settlement of the transfer-in receipt.',
    `discount_rate` DECIMAL(8,6) COMMENT 'Annualized discount rate applied by the source plan actuary to calculate the commuted value of the members accrued pension benefit.',
    `effective_date` DATE COMMENT 'The date from which the transferred service credits or assets are recognized as effective within the receiving pension plan for benefit entitlement purposes.',
    `employer_contribution_amount` DECIMAL(20,4) COMMENT 'Portion of the transferred amount attributable to employer contributions in the source plan, relevant for vesting and tax treatment determination.',
    `fx_rate` DECIMAL(18,8) COMMENT 'Exchange rate applied to convert the transfer amount from the transfer currency to the base currency on the valuation date.',
    `gl_posting_reference` STRING COMMENT 'Reference to the General Ledger (GL) journal entry in Oracle Financials recording the receipt of the transfer-in assets in the funds accounting books.',
    `investment_earnings_amount` DECIMAL(20,4) COMMENT 'Portion of the transferred amount attributable to accumulated investment earnings on contributions in the source plan.',
    `kyc_verified` BOOLEAN COMMENT 'Indicates whether KYC identity verification has been completed for the member in connection with this transfer-in, per AML/CTF obligations.',
    `locked_in_flag` BOOLEAN COMMENT 'Indicates whether the transferred assets are subject to locked-in restrictions under applicable pension legislation, preventing early withdrawal.',
    `member_consent_date` DATE COMMENT 'Date on which the member provided written consent authorizing the transfer-in from the source plan to the receiving fund.',
    `member_contribution_amount` DECIMAL(20,4) COMMENT 'Portion of the transferred amount attributable to the members own contributions in the source plan, used for tax and benefit entitlement calculations.',
    `notes` STRING COMMENT 'Free-text field for additional administrative notes, exceptions, or special handling instructions related to this transfer-in transaction.',
    `past_service_pension_adjustment` DECIMAL(20,4) COMMENT 'Past Service Pension Adjustment amount arising from the recognition of prior service credits, reducing the members available tax-advantaged contribution room.',
    `pension_adjustment_reversal` DECIMAL(20,4) COMMENT 'Pension Adjustment Reversal amount reported to the tax authority when a member terminates from the source DB plan, restoring tax-advantaged contribution room.',
    `portability_election_type` STRING COMMENT 'Indicates whether the member elected to transfer the full commuted value or only a partial amount from the source plan.. Valid values are `full_transfer|partial_transfer`',
    `prior_service_end_date` DATE COMMENT 'End date of the prior service period being recognized through this transfer-in, marking the boundary of the credited service block.',
    `prior_service_start_date` DATE COMMENT 'Start date of the prior service period being recognized through this transfer-in, used to establish the members pensionable service history.',
    `receipt_date` DATE COMMENT 'The date on which the fund physically received the transferred assets or funds from the source plan, as confirmed by the custodian.',
    `reference_number` STRING COMMENT 'Externally-known unique reference number assigned to this transfer-in transaction, used for reconciliation with the source plan and custodian.. Valid values are `^TRF-IN-[0-9]{8,12}$`',
    `rejection_reason` STRING COMMENT 'Reason code or description explaining why the transfer-in was rejected or cancelled, populated only when transfer_status is rejected or cancelled.',
    `service_credit_years` DECIMAL(8,4) COMMENT 'Number of years of pensionable service credited to the member in the receiving plan as a result of this transfer-in, expressed as a decimal.',
    `simcorp_transaction_reference` STRING COMMENT 'Transaction identifier assigned by SimCorp Dimension (ABOR/Investment Accounting module) upon posting of the transfer-in receipt.',
    `source_plan_administrator` STRING COMMENT 'Name of the plan administrator or financial institution responsible for the source pension plan from which assets are being transferred.',
    `source_plan_confirmation_ref` STRING COMMENT 'Reference number or document identifier from the source plan administrator confirming the release and transfer of the members pension entitlement.',
    `source_plan_jurisdiction` STRING COMMENT 'Regulatory jurisdiction governing the source pension plan (e.g., CAN, ON, BC, FED) under which the transfer is being executed.. Valid values are `^[A-Z]{2,3}$`',
    `source_plan_name` STRING COMMENT 'Full legal name of the pension plan or retirement account from which the assets or service credits are being transferred.',
    `source_plan_registration_number` STRING COMMENT 'Government-issued registration number of the source pension plan as assigned by the tax authority or applicable regulator.',
    `source_plan_type` STRING COMMENT 'Classification of the originating plan: Defined Benefit (DB), Defined Contribution (DC), individual retirement account, group retirement savings plan, or profit-sharing plan.. Valid values are `defined_benefit|defined_contribution|individual_retirement_account|group_retirement_plan|profit_sharing_plan`',
    `tax_withheld_amount` DECIMAL(20,4) COMMENT 'Amount of withholding tax deducted from the transfer by the source plan administrator prior to remittance, if applicable.',
    `transfer_amount` DECIMAL(20,4) COMMENT 'Gross monetary value of the assets transferred into the fund from the source plan, expressed in the transfer currency.',
    `transfer_amount_base_equivalent` DECIMAL(20,4) COMMENT 'Gross monetary value of the transfer-in converted to national Dollars (Base Currency) at the applicable FX rate on the valuation date, used for fund-level reporting.',
    `transfer_currency` STRING COMMENT 'ISO 4217 three-letter currency code of the currency in which the transfer amount is denominated (e.g., USD).. Valid values are `^[A-Z]{3}$`',
    `transfer_date` DATE COMMENT 'The date on which the transfer-in transaction was formally initiated and submitted by the source plan administrator.',
    `transfer_method` STRING COMMENT 'Mechanism by which the transfer assets were physically remitted to the fund: wire transfer, cheque, in-kind asset transfer, or electronic funds transfer (EFT).. Valid values are `wire_transfer|cheque|in_kind|electronic_funds_transfer`',
    `transfer_status` STRING COMMENT 'Current lifecycle state of the transfer-in transaction from initiation through to final receipt and posting.. Valid values are `pending|in_progress|completed|rejected|cancelled`',
    `transfer_type` STRING COMMENT 'Classification of the transfer-in by mechanism: commuted value from a defined benefit plan, service credit recognition, retirement savings account conversion, direct plan-to-plan transfer, or group transfer.. Valid values are `commuted_value|service_credit|rrsp_conversion|direct_transfer|group_transfer`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this transfer-in record, supporting audit trail, change tracking, and incremental data loading.',
    `valuation_date` DATE COMMENT 'The date used to determine the commuted value or asset value of the transferred pension entitlement from the source plan.',
    `vesting_status` STRING COMMENT 'Vesting status of the members entitlement in the source plan at the time of transfer, determining the transferable benefit amount.. Valid values are `fully_vested|partially_vested|unvested`',
    CONSTRAINT pk_transfer_in PRIMARY KEY(`transfer_in_id`)
) COMMENT 'Transactional record of pension assets or service credits transferred into the fund from another pension plan or retirement account on behalf of a member. Records the source plan name, transfer type (commuted value, service credit recognition), transfer';

CREATE OR REPLACE TABLE `asset_management`.`beneficiary`.`transfer_out` (
    `transfer_out_id` BIGINT COMMENT 'Unique surrogate identifier for each pension transfer-out transaction record within the funds IBOR/ABOR system.',
    `assumption_set_id` BIGINT COMMENT 'Foreign key linking to actuarial.assumption_set. Business justification: Commuted value calculations for pension transfers require specific actuarial assumptions (discount rate, mortality table).',
    `cash_transfer_id` BIGINT COMMENT 'Foreign key linking to treasury.cash_transfer. Business justification: Links member transfer‑out records to the treasury transfer for reconciliation of outgoing cash.',
    `contributor_pool_id` BIGINT COMMENT 'Foreign key linking to beneficiary.contributor_pool. Business justification: Transfer-out records specify which contributor pool the member is leaving. Normalizing STRING to FK.',
    `member_id` BIGINT COMMENT 'Reference to the pension plan member (beneficiary) initiating the transfer-out of their accrued entitlement upon termination of employment.',
    `pension_plan_id` BIGINT COMMENT 'Reference to the pension plan (one per participating plan) from which the transfer-out is being processed.',
    `portfolio_id` BIGINT COMMENT 'Foreign key linking to portfolio.portfolio. Business justification: Transfers out of a plan need portfolio context for tax and settlement calculations.',
    `accrued_service_years` DECIMAL(8,4) COMMENT 'The total years of pensionable service accrued by the member as at the termination date, used as the basis for the commuted value actuarial calculation.',
    `aml_cleared` BOOLEAN COMMENT 'Indicates whether the transfer-out transaction has passed the required Anti-Money Laundering (AML) and Know Your Customer (KYC) screening prior to fund disbursement.',
    `aml_review_date` DATE COMMENT 'The date on which the Anti-Money Laundering (AML) and KYC review was completed for this transfer-out transaction.',
    `approval_date` DATE COMMENT 'The date on which the transfer-out was formally approved by the pension administration team following actuarial valuation and compliance review.',
    `approved_by` STRING COMMENT 'The identifier or name of the pension administration officer who approved the transfer-out transaction, supporting governance and audit trail requirements.',
    `base_currency_amount` DECIMAL(20,4) COMMENT 'The total commuted value transfer amount expressed in the funds base currency (Base Currency), after applying the applicable FX rate for cross-currency transfers.',
    `best_average_salary` DECIMAL(18,4) COMMENT 'The members best average salary figure used in the defined benefit formula to determine the accrued pension entitlement underlying the commuted value calculation.',
    `commuted_value_amount` DECIMAL(20,4) COMMENT 'The actuarially determined commuted value (CV) of the members accrued pension entitlement as at the valuation date, representing the lump-sum equivalent of the deferred pension.',
    `currency_code` STRING COMMENT 'The ISO 4217 three-letter currency code in which the commuted value and transfer amounts are denominated (e.g., USD).. Valid values are `^[A-Z]{3}$`',
    `discount_rate` DECIMAL(10,6) COMMENT 'The actuarial discount rate (as a decimal) applied in the commuted value calculation to present-value the projected pension cash flows, per actuarial standards.',
    `election_date` DATE COMMENT 'The date on which the member formally elected to transfer their commuted value or pension credit out of the fund rather than defer or take an annuity.',
    `election_deadline_date` DATE COMMENT 'The statutory or plan-rule deadline by which the member must elect the transfer-out option; failure to elect by this date may result in a deferred pension default.',
    `fx_rate` DECIMAL(18,8) COMMENT 'The FX rate applied to convert the transfer amount to the funds base currency where the receiving plan is denominated in a foreign currency.',
    `gl_account_code` STRING COMMENT 'The General Ledger (GL) account code in Oracle Financials to which the commuted value transfer disbursement is posted for fund accounting and liability reduction.',
    `initiated_timestamp` TIMESTAMP COMMENT 'The date and time when the transfer-out transaction was first created in the pension administration system, serving as the primary audit creation timestamp.',
    `is_cross_border` BOOLEAN COMMENT 'Indicates whether the transfer-out involves a cross-border remittance to a foreign registered pension plan, triggering additional regulatory and FX requirements.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'The date and time when the transfer-out record was most recently modified, supporting audit trail and data lineage requirements.',
    `member_consent_ref` STRING COMMENT 'Reference to the signed member consent or election form authorizing the transfer-out, stored in the document management system for audit and compliance purposes.',
    `mortality_table_code` STRING COMMENT 'The actuarial mortality table code (e.g., RP-2014, UP-94) used in the commuted value calculation to project member life expectancy.',
    `notes` STRING COMMENT 'Free-text field for pension administration officers to record exceptions, special circumstances, or supplementary information relevant to this transfer-out transaction.',
    `payment_method` STRING COMMENT 'The method by which the commuted value funds are remitted to the receiving institution or directly to the member for the taxable portion.. Valid values are `wire_transfer|direct_deposit|cheque|electronic_funds_transfer`',
    `receiving_country_code` STRING COMMENT 'The ISO 3166-1 alpha-3 country code of the jurisdiction where the receiving registered plan is domiciled, required for cross-border transfer regulatory reporting.. Valid values are `^[A-Z]{3}$`',
    `receiving_institution_lei` STRING COMMENT 'The 20-character ISO 17442 Legal Entity Identifier (LEI) of the receiving financial institution, used for counterparty identification and regulatory reporting.. Valid values are `^[A-Z0-9]{18}[0-9]{2}$`',
    `receiving_institution_name` STRING COMMENT 'The name of the financial institution or pension plan administrator receiving the transferred commuted value funds on behalf of the member.',
    `receiving_plan_number` STRING COMMENT 'The account or plan registration number at the receiving institution to which the commuted value funds are directed. Classified as confidential financial data.',
    `receiving_plan_type` STRING COMMENT 'Type of registered plan or account to which the commuted value is being transferred (e.g., locked-in retirement account, another pension plan). [ENUM-REF-CANDIDATE: IRA|locked_in_account|DC_PLAN|DB_PLAN|foreign_pension — promote to reference product]',
    `reference_number` STRING COMMENT 'Externally-known unique business reference number assigned to this transfer-out transaction, used in member correspondence and regulatory filings.. Valid values are `^TO-[0-9]{4}-[0-9]{8}$`',
    `registered_transfer_amount` DECIMAL(20,4) COMMENT 'The portion of the commuted value transferred on a tax-sheltered basis directly into the members registered receiving plan (locked-in account, another pension plan, etc.), net of any taxable portion.',
    `regulatory_filing_ref` STRING COMMENT 'The reference number of the regulatory filing or notification submitted to the applicable pension regulator (e.g., the national pension regulator) in connection with this transfer-out.',
    `settlement_instructions_ref` STRING COMMENT 'Reference to the Standard Settlement Instructions (SSI) on file for the receiving institution, used to route the wire transfer or EFT payment accurately.',
    `source_system_ref` STRING COMMENT 'The unique transaction identifier assigned by the originating pension administration or ABOR system (e.g., SimCorp Dimension) for reconciliation and data lineage tracing.',
    `tax_slip_issued` BOOLEAN COMMENT 'Indicates whether the required tax reporting slip (e.g., an annual pension income slip) has been issued to the member for the taxable portion of the commuted value transfer.',
    `tax_slip_year` BIGINT COMMENT 'The tax year for which the tax reporting slip is issued to the member, corresponding to the calendar year in which the commuted value transfer was executed.',
    `taxable_portion_amount` DECIMAL(20,4) COMMENT 'The portion of the commuted value that exceeds the registered plan contribution room and is subject to withholding tax, payable directly to the member.',
    `termination_date` DATE COMMENT 'The date on which the members pensionable employment ended, triggering eligibility for the transfer-out option under the plan rules.',
    `transfer_date` DATE COMMENT 'The actual date on which the commuted value funds were transferred out of the fund to the receiving registered plan or locked-in retirement account.',
    `transfer_reason` STRING COMMENT 'The reason code for the transfer-out, indicating whether the member voluntarily resigned, was involuntarily terminated, or is transferring between registered plans.. Valid values are `voluntary_resignation|involuntary_termination|retirement_ineligible|inter_plan_transfer|death_survivor`',
    `transfer_status` STRING COMMENT 'Current lifecycle state of the transfer-out transaction from initiation through to completion or cancellation. [ENUM-REF-CANDIDATE: initiated|pending_valuation|approved|funds_transferred|completed|cancelled|on_hold — promote to reference product]',
    `transfer_type` STRING COMMENT 'Classification of the transfer-out by the nature of the entitlement being transferred: commuted value of accrued pension, pension credit portability, or lump-sum commuted value.. Valid values are `commuted_value|pension_credit|lump_sum_cv|partial_transfer`',
    `valuation_date` DATE COMMENT 'The actuarial valuation date used to calculate the commuted value (CV) of the members accrued pension entitlement for transfer purposes.',
    `withholding_tax_amount` DECIMAL(20,4) COMMENT 'The amount of income tax withheld at source on the taxable portion of the commuted value transfer, remitted to the relevant tax authority on behalf of the member.',
    CONSTRAINT pk_transfer_out PRIMARY KEY(`transfer_out_id`)
) COMMENT 'Transactional record of commuted value or pension credit transfers out of the fund when a member terminates employment before retirement and elects to transfer their accrued entitlement to another registered plan or locked-in retirement account.';

CREATE OR REPLACE TABLE `asset_management`.`beneficiary`.`retirement_election` (
    `retirement_election_id` BIGINT COMMENT 'Unique surrogate identifier for the retirement election record. Primary key for the retirement_election data product in the beneficiary domain.',
    `beneficiary_id` BIGINT COMMENT 'Reference to the pension plan member (beneficiary) who submitted this retirement election. Links to the beneficiary master record.',
    `benefit_option_id` BIGINT COMMENT 'Foreign key linking to beneficiary.benefit_option. Business justification: Retirement election captures the members chosen pension option. The pension_option STRING should be normalized to FK to benefit_option table which defines available options.',
    `contributor_pool_id` BIGINT COMMENT 'Foreign key linking to beneficiary.contributor_pool. Business justification: Retirement elections are made under a specific contributor pool. The STRING field should be normalized to FK.',
    `designated_beneficiary_id` BIGINT COMMENT 'Reference to the designated survivor or beneficiary record who will receive survivor pension benefits upon the members death under the elected pension option.',
    `member_id` BIGINT COMMENT 'Reference to the pension plan member (beneficiary) who submitted this retirement election. Links to the beneficiary master record.',
    `pension_plan_id` BIGINT COMMENT 'Reference to the pension plan under which this retirement election is made (e.g., the participating plans plan).',
    `portfolio_id` BIGINT COMMENT 'Foreign key linking to portfolio.portfolio. Business justification: Retirement elections are plan-specific; linking to portfolio supports election processing and benefit payout.',
    `survivor_designated_beneficiary_id` BIGINT COMMENT 'Reference to the designated survivor or beneficiary record who will receive survivor pension benefits upon the members death under the elected pension option.',
    `administrator_notes` STRING COMMENT 'Free-text notes entered by the pension administrator during review and processing of the retirement election, capturing exceptions, clarifications, or special circumstances.',
    `approved_date` DATE COMMENT 'The date on which the retirement election was formally approved by the pension administrator, triggering commencement of benefit payment processing.',
    `bank_account_reference` STRING COMMENT 'Masked or tokenized reference to the members bank account designated for direct deposit of pension payments. Full account details held in secure payment system.',
    `best_average_earnings` DECIMAL(18,2) COMMENT 'The members highest average pensionable earnings over the defined averaging period (typically best 5 years), used as the salary base in the defined benefit pension formula.',
    `bridge_benefit_amount` DECIMAL(18,2) COMMENT 'Annual amount of the bridge benefit payable to the member until state pension eligibility, if bridge benefit was elected. Ceases at the bridge benefit end date.',
    `bridge_benefit_elected` BOOLEAN COMMENT 'Indicates whether the member elected to receive a bridge benefit (temporary supplement payable until state pension eligibility age) as part of their retirement package.',
    `bridge_benefit_end_date` DATE COMMENT 'The date on which the bridge benefit ceases, typically when the member reaches state pension eligibility age (age 65) or upon earlier death.',
    `commutation_amount` DECIMAL(18,2) COMMENT 'The lump-sum transfer value amount elected by the member for commutation of a portion of their defined benefit pension entitlement.',
    `commutation_elected` BOOLEAN COMMENT 'Indicates whether the member elected to commute a portion of their pension to a lump-sum transfer value, reducing the ongoing annuity amount.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this retirement election record was first created in the system of record.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for all monetary amounts on this retirement election record (e.g., USD, GBP).. Valid values are `^[A-Z]{3}$`',
    `disability_certification_date` DATE COMMENT 'The date on which the members disability was formally certified by a qualified medical authority, required for disability retirement type elections.',
    `early_retirement_reduction_rate` DECIMAL(7,4) COMMENT 'The actuarial reduction rate applied per year of early retirement before the normal retirement age, expressed as a decimal (e.g., 0.0300 for 3% per year).',
    `effective_retirement_date` DATE COMMENT 'The date on which the members active service ends and pension drawdown commences. Used as the anchor date for actuarial liability calculations and first payment determination.',
    `election_channel` STRING COMMENT 'The channel through which the member submitted the retirement election: online member portal, paper form, in-person at a service centre, or telephone.. Valid values are `online_portal|paper_form|in_person|telephone`',
    `election_form_version` STRING COMMENT 'Version identifier of the retirement election form used by the member, ensuring the correct plan rules and options were presented at the time of election.',
    `election_received_date` DATE COMMENT 'The date the pension administrator physically or electronically received the completed retirement election form from the member.',
    `election_reference_number` STRING COMMENT 'Externally-known unique business reference number assigned to this retirement election, used in member correspondence and administrative processing.. Valid values are `^RE-[0-9]{4}-[0-9]{8}$`',
    `election_status` STRING COMMENT 'Current workflow lifecycle state of the retirement election from initial submission through administrative approval or rejection.. Valid values are `draft|submitted|under_review|approved|rejected|cancelled`',
    `election_submitted_timestamp` TIMESTAMP COMMENT 'Date and time when the member formally submitted the retirement election to the pension administrator. Principal business event timestamp for this transaction.',
    `first_payment_date` DATE COMMENT 'The scheduled date of the first pension benefit payment to the member following retirement election approval.',
    `gross_annual_pension` DECIMAL(18,2) COMMENT 'The calculated gross annual pension benefit payable to the member before any reductions, indexation, or survivor benefit adjustments.',
    `guaranteed_period_years` BIGINT COMMENT 'Number of years for which pension payments are guaranteed regardless of the members death, applicable when the guaranteed period pension option is elected (e.g., 5, 10, 15 years).',
    `indexation_type` STRING COMMENT 'The type of cost-of-living indexation applied to the pension: full CPI, partial CPI, fixed rate, or none. Determines how the pension is adjusted annually for inflation.. Valid values are `full_cpi|partial_cpi|fixed_rate|none`',
    `is_irrevocable` BOOLEAN COMMENT 'Indicates whether the retirement election has been finalized and is irrevocable. Once set to true, the pension option and retirement date cannot be changed.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Date and time when this retirement election record was most recently modified, supporting audit trail and change tracking requirements.',
    `member_age_at_retirement` BIGINT COMMENT 'The members age in whole years as of the effective retirement date. Used for actuarial factor selection and early retirement penalty determination.',
    `member_consent_obtained` BOOLEAN COMMENT 'Indicates whether the member provided informed consent to the pension option elected, including acknowledgement of irrevocability and survivor benefit implications.',
    `member_date_of_birth` DATE COMMENT 'The members date of birth, required for actuarial age verification, normal retirement age eligibility determination, and benefit calculation.',
    `payment_frequency` STRING COMMENT 'The frequency at which pension benefit payments are disbursed to the member (typically monthly for defined benefit pension plans).. Valid values are `monthly|quarterly|semi_annual|annual`',
    `payment_method` STRING COMMENT 'The method by which pension benefit payments are disbursed to the member: direct deposit (EFT), cheque, or wire transfer.. Valid values are `direct_deposit|cheque|wire_transfer`',
    `pensionable_service_years` DECIMAL(6,4) COMMENT 'Total years of pensionable service credited to the member at the time of retirement election, including any purchased or transferred service. Core input to benefit formula.',
    `reduced_annual_pension` DECIMAL(18,2) COMMENT 'The annual pension amount after applying any early retirement actuarial reduction factors or pension option reduction for survivor benefits.',
    `rejection_reason` STRING COMMENT 'The reason code or description explaining why a retirement election was rejected, required for member communication and resubmission guidance.',
    `retirement_type` STRING COMMENT 'Classification of the retirement basis: normal age retirement, early retirement, deferred retirement, disability retirement, or involuntary separation. Drives entitlement calculation rules.. Valid values are `normal|early|deferred|disability|involuntary`',
    `spousal_consent_obtained` BOOLEAN COMMENT 'Indicates whether spousal or common-law partner consent was obtained for the pension option elected, as required by pension legislation when waiving survivor benefits.',
    `survivor_benefit_percentage` DECIMAL(5,2) COMMENT 'The percentage of the members pension payable to the designated survivor upon the members death, as elected under the joint and survivor or guaranteed period option (e.g., 50%, 60%, 66.67%).',
    `survivor_date_of_birth` DATE COMMENT 'Date of birth of the designated survivor, required for actuarial reduction factor calculation when a joint and survivor pension option is elected.',
    `survivor_relationship` STRING COMMENT 'The legal relationship of the designated survivor to the retiring member, determining eligibility for survivor pension benefits under plan rules.. Valid values are `spouse|common_law_partner|dependent_child|other`',
    `tax_withholding_code` STRING COMMENT 'The tax withholding instruction code applied to pension payments, reflecting the members elected withholding rate or exemption status for income tax purposes.',
    `transfer_destination` STRING COMMENT 'The registered account or vehicle to which the commuted lump-sum transfer value is directed (e.g., retirement savings account, locked-in account, retirement income fund). Applicable only when commutation is elected.. Valid values are `retirement_savings_account|locked_in_retirement_account|retirement_income_fund|locked_in_account|cash|other`',
    CONSTRAINT pk_retirement_election PRIMARY KEY(`retirement_election_id`)
) COMMENT 'Transactional record capturing a members formal election to commence pension drawdown, including retirement date, retirement type (normal, early, deferred, disability), pension option elected (single life, joint and survivor, guaranteed period), survivor';

CREATE OR REPLACE TABLE `asset_management`.`beneficiary`.`indexation_adjustment` (
    `indexation_adjustment_id` BIGINT COMMENT 'Unique surrogate identifier for each indexation adjustment record applied to a pension benefit payment. Primary key for this transactional entity.',
    `designated_beneficiary_id` BIGINT COMMENT 'Reference to the pension plan member whose benefit payment is subject to this indexation adjustment. Links to the beneficiary master record.',
    `benefit_payment_id` BIGINT COMMENT 'Reference to the specific pension benefit payment record to which this indexation adjustment is applied. Links to the benefit payment transactional entity.',
    `indexation_policy_id` BIGINT COMMENT 'Foreign key linking to actuarial.indexation_policy. Business justification: Indexation adjustments apply specific indexation policies to adjust pension benefits.',
    `macro_indicator_id` BIGINT COMMENT 'Foreign key linking to research.macro_indicator. Business justification: Annual pension indexation process requires linking adjustments to the specific CPI/inflation macro indicator used.',
    `member_id` BIGINT COMMENT 'Reference to the pension plan member whose benefit payment is subject to this indexation adjustment. Links to the beneficiary master record.',
    `pension_plan_id` BIGINT COMMENT 'Reference to the pension plan (e.g., one of the participating plans) under which this indexation adjustment is processed.',
    `portfolio_id` BIGINT COMMENT 'Foreign key linking to portfolio.portfolio. Business justification: Indexation adjustments are applied per plan; linking to portfolio ensures correct adjustment application.',
    `superseded_by_adjustment_id` BIGINT COMMENT 'Reference to the replacement indexation adjustment record that supersedes this one in the event of a correction or recalculation. Null if this record is current and active.',
    `actuarial_basis_code` STRING COMMENT 'Code identifying the actuarial valuation basis or methodology under which this indexation adjustment was calculated, linking to the applicable actuarial assumptions set. [ENUM-REF-CANDIDATE: promote to reference product]',
    `adjusted_benefit_amount` DECIMAL(18,2) COMMENT 'The gross annual or monthly pension benefit amount payable to the beneficiary after this indexation adjustment is applied. Represents the new benefit entitlement post-adjustment.',
    `adjustment_amount` DECIMAL(18,2) COMMENT 'The absolute monetary increase (or decrease) in the benefit payment resulting from this indexation adjustment. Equals adjusted_benefit_amount minus prior_benefit_amount.',
    `adjustment_reference_number` STRING COMMENT 'Externally-known unique business reference number assigned to this indexation adjustment event, used for audit trails, member communications, and regulatory reporting.. Valid values are `^IDX-[0-9]{4}-[0-9]{8}$`',
    `adjustment_status` STRING COMMENT 'Current lifecycle state of the indexation adjustment record, tracking workflow from initial calculation through approval, application, and any subsequent reversal.. Valid values are `pending|approved|applied|reversed|cancelled`',
    `adjustment_year` BIGINT COMMENT 'The calendar year for which this indexation adjustment is applicable (e.g., 2024). Used for annual reporting, actuarial valuations, and regulatory submissions.',
    `announcement_date` DATE COMMENT 'The date on which the indexation rate for the applicable period was officially announced or published by the plan administrator or governing authority.',
    `applied_timestamp` TIMESTAMP COMMENT 'The precise date and time at which the indexation adjustment was applied to the beneficiarys benefit payment record in the system of record (SimCorp Dimension).',
    `approval_date` DATE COMMENT 'The date on which the indexation adjustment was formally approved by the plan administrator or governing authority prior to application to beneficiary payments.',
    `approved_by` STRING COMMENT 'The name or identifier of the plan administrator, governance body, or authorized officer who approved this indexation adjustment for application.',
    `benefit_frequency` STRING COMMENT 'The payment frequency of the pension benefit to which this indexation adjustment applies, determining whether the amounts represent monthly, quarterly, or annual figures.. Valid values are `monthly|quarterly|annual`',
    `cost_centre_code` STRING COMMENT 'The organizational cost centre code to which the incremental pension liability cost from this indexation adjustment is allocated for management accounting and budget reporting.',
    `cpi_measure_used` STRING COMMENT 'The specific Consumer Price Index (CPI) measure used to derive the indexation rate, as defined in the plan rules (e.g., All-Items CPI, Core CPI). Determines the inflation benchmark.. Valid values are `all_items_cpi|core_cpi|trimmed_mean_cpi|weighted_median_cpi|plan_specific`',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this indexation adjustment record was first created in the system, supporting audit trail and data lineage requirements.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which the benefit amounts are denominated (e.g., USD for US Dollar). Supports multi-currency beneficiary scenarios.. Valid values are `^[A-Z]{3}$`',
    `effective_date` DATE COMMENT 'The date on which the indexation adjustment takes effect and the adjusted benefit amount becomes payable to the beneficiary. Typically January 1 of the adjustment year.',
    `gl_account_code` STRING COMMENT 'The General Ledger (GL) account code in Oracle Financials to which the incremental benefit cost from this indexation adjustment is posted for corporate accounting and financial reporting.',
    `indexation_cap_rate` DECIMAL(10,6) COMMENT 'The maximum indexation rate permitted under the plan rules for this adjustment cycle, expressed as a decimal. Constrains the applied rate when CPI exceeds the plan-defined ceiling.',
    `indexation_floor_rate` DECIMAL(10,6) COMMENT 'The minimum indexation rate permitted under the plan rules for this adjustment cycle, expressed as a decimal. Protects beneficiaries from negative adjustments in deflationary periods.',
    `indexation_rate` DECIMAL(10,6) COMMENT 'The annual cost-of-living indexation rate applied to the benefit payment, expressed as a decimal (e.g., 0.032100 for 3.21%). Typically derived from the applicable CPI measure per plan rules.',
    `indexation_type` STRING COMMENT 'Classification of the indexation mechanism applied, indicating whether the adjustment is fully CPI-linked, partially CPI-linked, a fixed rate, an ad hoc adjustment, or nil.. Valid values are `full_cpi|partial_cpi|fixed_rate|ad_hoc|nil`',
    `is_rate_capped` BOOLEAN COMMENT 'Indicates whether the applied indexation rate was constrained by the plan-defined cap (True) or reflects the full CPI-derived rate (False). Supports actuarial and regulatory analysis.',
    `is_rate_floored` BOOLEAN COMMENT 'Indicates whether the applied indexation rate was constrained by the plan-defined floor (True) or reflects the full CPI-derived rate (False). Supports actuarial and regulatory analysis.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'The date and time when this indexation adjustment record was most recently modified, supporting audit trail and change management requirements.',
    `liability_impact_amount` DECIMAL(18,2) COMMENT 'The estimated change in the present value of the defined benefit obligation (DBO) attributable to this indexation adjustment, used for actuarial liability matching and ALM reporting.',
    `notes` STRING COMMENT 'Free-text field for additional commentary, exceptions, or contextual information related to this indexation adjustment, recorded by the plan administrator or actuary.',
    `notification_date` DATE COMMENT 'The date on which the beneficiary was formally notified of this indexation adjustment. Null if notification has not yet been sent.',
    `notification_sent` BOOLEAN COMMENT 'Indicates whether a formal notification of this indexation adjustment has been sent to the beneficiary (True) or is pending (False). Supports member communication compliance.',
    `plan_type` STRING COMMENT 'The contributor pool or pension plan type to which the beneficiary belongs, identifying the applicable indexation rules and CPI linkage formula for the adjustment.. Valid values are `plan_1|plan_2|plan_3|plan_4`',
    `prior_benefit_amount` DECIMAL(18,2) COMMENT 'The gross annual or monthly pension benefit amount payable to the beneficiary immediately before this indexation adjustment is applied. Denominated in the plans base currency.',
    `prior_cpi_value` DECIMAL(12,4) COMMENT 'The CPI index value from the prior reference period used as the base for computing the year-over-year indexation rate. Enables rate derivation validation.',
    `reference_cpi_period_end` DATE COMMENT 'The end date of the CPI measurement period used to calculate the indexation rate, as specified in the plan rules (e.g., September of the current year).',
    `reference_cpi_period_start` DATE COMMENT 'The start date of the CPI measurement period used to calculate the indexation rate, as specified in the plan rules (e.g., October of the prior year).',
    `reference_cpi_value` DECIMAL(12,4) COMMENT 'The actual CPI index value for the reference period used to compute the indexation rate. Provides the inflation input for audit and actuarial validation purposes.',
    `regulatory_reporting_flag` BOOLEAN COMMENT 'Indicates whether this indexation adjustment record is required to be included in regulatory submissions to the national pension regulator or other applicable pension regulators (True) or is excluded (False).',
    `reversal_date` DATE COMMENT 'The date on which this indexation adjustment was reversed or cancelled, if applicable. Null for adjustments that have not been reversed.',
    `reversal_reason` STRING COMMENT 'Free-text description of the reason for reversing or cancelling this indexation adjustment, populated only when adjustment_status is reversed or cancelled. Supports audit and compliance.',
    `source_system_code` STRING COMMENT 'Identifies the operational system of record from which this indexation adjustment record originated (e.g., SimCorp Dimension, State Street Administration Platform, Oracle Financials, or manual entry).. Valid values are `SIMCORP|STATE_STREET|ORACLE|MANUAL`',
    `source_system_reference_code` STRING COMMENT 'The native identifier of this indexation adjustment record in the originating source system (e.g., SimCorp Dimension transaction ID), enabling lineage tracing and reconciliation.',
    CONSTRAINT pk_indexation_adjustment PRIMARY KEY(`indexation_adjustment_id`)
) COMMENT 'Transactional record of annual cost-of-living indexation adjustments applied to pension benefit payments. Captures the indexation rate applied (typically CPI-linked per plan rules), effective date, prior benefit amount, adjusted benefit amount, and the';

CREATE OR REPLACE TABLE `asset_management`.`beneficiary`.`survivor_benefit` (
    `survivor_benefit_id` BIGINT COMMENT 'Unique system-generated identifier for the survivor benefit record. Primary key for this entity.',
    `contributor_pool_id` BIGINT COMMENT 'Foreign key linking to beneficiary.contributor_pool. Business justification: Survivor benefits are governed by contributor pool rules. Normalizing the STRING field to FK.',
    `designated_beneficiary_id` BIGINT COMMENT 'Reference to the surviving beneficiary (spouse, dependent, or child) who is entitled to receive this benefit.',
    `member_id` BIGINT COMMENT 'Reference to the deceased plan member or retiree whose death triggered this survivor benefit entitlement.',
    `pension_plan_id` BIGINT COMMENT 'Foreign key linking to beneficiary.pension_plan. Business justification: Survivor benefits are established under a specific pension plan with its own rules. Adding plan_id FK links the benefit to its governing plan.',
    `survivor_designated_beneficiary_id` BIGINT COMMENT 'Reference to the surviving beneficiary (spouse, dependent, or child) who is entitled to receive this benefit.',
    `actuarial_present_value` DECIMAL(22,4) COMMENT 'Actuarially calculated present value of the total projected survivor benefit obligation, used for LDI, ALM, and IFRS IAS 19 defined benefit liability reporting.',
    `approval_date` DATE COMMENT 'Date on which the survivor benefit was formally approved by the pension administration team or Investment Committee governance process.',
    `approved_by` STRING COMMENT 'Name or identifier of the pension administrator or governance authority who approved the survivor benefit entitlement.',
    `bank_account_reference` STRING COMMENT 'Masked or tokenized reference to the survivors bank account used for direct deposit payments. Full account details held in the secure payment system (State Street/Northern Trust).',
    `benefit_commencement_date` DATE COMMENT 'The date on which the survivor benefit payments commence. Marks the effective start of the benefit obligation for actuarial and liability-matching purposes.',
    `benefit_fraction` DECIMAL(6,4) COMMENT 'The fraction of the members pension entitlement payable to the survivor (e.g., 0.60 for 60% survivor pension). Defined by plan rules and LPA terms.',
    `benefit_reference_number` STRING COMMENT 'Externally-known unique alphanumeric reference number assigned to this survivor benefit record, used in member correspondence and regulatory reporting.. Valid values are `^SB-[A-Z]{2,4}-[0-9]{8,12}$`',
    `benefit_status` STRING COMMENT 'Current lifecycle status of the survivor benefit: pending (awaiting approval), active (in payment), suspended, terminated, or expired.. Valid values are `pending|active|suspended|terminated|expired`',
    `benefit_termination_date` DATE COMMENT 'The date on which the survivor benefit ceases (e.g., upon remarriage, death of survivor, or age-out of childrens benefit). Null if benefit is open-ended.',
    `benefit_type` STRING COMMENT 'Classification of the survivor benefit: survivor pension (ongoing annuity to spouse), death-in-service lump sum, childrens benefit, dependent pension, or continuation pension.. Valid values are `survivor_pension|death_in_service_lump_sum|childrens_benefit|dependent_pension|continuation_pension`',
    `children_benefit_age_limit` BIGINT COMMENT 'Maximum age (in years) up to which a dependent child is eligible to receive the childrens benefit. Typically 18 or 25 if in full-time education. Null for non-children benefit types.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which the survivor benefit is denominated and paid (e.g., GBP, USD).. Valid values are `^[A-Z]{3}$`',
    `death_cause_category` STRING COMMENT 'Broad categorization of the cause of death, which may affect benefit type, amount, or eligibility (e.g., service-related death may trigger enhanced lump sum for some member categories).. Valid values are `natural|accidental|service_related|occupational_illness|other`',
    `death_certificate_reference` STRING COMMENT 'Reference number of the official death certificate submitted to substantiate the survivor benefit claim. Required for KYC/AML compliance and benefit eligibility verification.',
    `discount_rate` DECIMAL(8,6) COMMENT 'The discount rate (expressed as a decimal) used in the actuarial present value calculation of the survivor benefit obligation, per IAS 19 high-quality corporate bond yield methodology.',
    `gross_annual_benefit_amount` DECIMAL(18,4) COMMENT 'The gross annual survivor pension or benefit amount payable before any deductions, expressed in the plans base currency. Core financial obligation for LDI and ALM.',
    `guarantee_period_months` BIGINT COMMENT 'Number of months for which the survivor benefit is guaranteed to be paid regardless of the survivors death. Relevant for actuarial valuation of minimum payment obligations.',
    `indexation_rate` DECIMAL(8,6) COMMENT 'Annual indexation rate applied to the survivor benefit where a fixed rate applies (expressed as a decimal, e.g., 0.02 for 2%). Null if CPI-linked or no indexation.',
    `indexation_type` STRING COMMENT 'Type of cost-of-living indexation applied to the survivor benefit: full CPI, partial CPI, fixed annual rate, or none. Critical for actuarial liability projection.. Valid values are `cpi_full|cpi_partial|fixed_rate|none`',
    `is_disabled_dependent` BOOLEAN COMMENT 'Indicates whether the surviving beneficiary qualifies as a disabled dependent, which may result in lifetime benefit eligibility regardless of age limits.',
    `is_full_time_student` BOOLEAN COMMENT 'Indicates whether the surviving dependent child is enrolled as a full-time student, which may extend the childrens benefit eligibility beyond the standard age limit.',
    `kyc_verification_date` DATE COMMENT 'Date on which the KYC identity verification for the surviving beneficiary was completed and confirmed.',
    `kyc_verified` BOOLEAN COMMENT 'Indicates whether the surviving beneficiary has completed the required KYC identity verification process prior to benefit payment commencement.',
    `last_payment_date` DATE COMMENT 'Date of the most recent survivor benefit payment made to the beneficiary. Used for payment reconciliation and cash management monitoring.',
    `lump_sum_amount` DECIMAL(18,4) COMMENT 'One-time lump sum death-in-service payment amount, if applicable. Null for ongoing pension-type benefits. Relevant for death-in-service and certain service-related benefit types.',
    `member_death_date` DATE COMMENT 'The date of death of the plan member or retiree that triggered the survivor benefit entitlement. Principal business event date for this record.',
    `net_annual_benefit_amount` DECIMAL(18,4) COMMENT 'The net annual survivor benefit amount payable after applicable deductions (e.g., tax withholding, offsets). Used for cash flow planning and beneficiary payment processing.',
    `next_payment_date` DATE COMMENT 'Date of the next scheduled survivor benefit payment. Used for liquidity planning, cash management, and treasury forecasting.',
    `notes` STRING COMMENT 'Free-text administrative notes recorded by pension administrators regarding special circumstances, exceptions, or case-specific details for this survivor benefit.',
    `payment_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the country to which survivor benefit payments are remitted. Relevant for FX hedging, withholding tax, and cross-border regulatory compliance.. Valid values are `^[A-Z]{3}$`',
    `payment_frequency` STRING COMMENT 'Frequency at which the survivor benefit is paid to the beneficiary: monthly, quarterly, semi-annual, annual, or one-time (for lump sum).. Valid values are `monthly|quarterly|semi_annual|annual|one_time`',
    `payment_method` STRING COMMENT 'Method by which the survivor benefit is disbursed to the beneficiary: direct deposit (EFT), cheque, or wire transfer. Drives treasury and cash management operations.. Valid values are `direct_deposit|cheque|wire_transfer|eft`',
    `plan_document_reference` STRING COMMENT 'Reference to the governing pension plan document, LPA, or trust deed that defines the survivor benefit rules applicable to this record.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this survivor benefit record was first created in the data platform. Audit trail for data lineage and regulatory compliance.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this survivor benefit record was most recently modified in the data platform. Supports audit trail, change tracking, and data quality monitoring.',
    `remarriage_termination_flag` BOOLEAN COMMENT 'Indicates whether the survivor benefit is subject to termination upon the surviving spouses remarriage, as defined by the applicable plan rules.',
    `source_system_code` STRING COMMENT 'Identifier of this survivor benefit record in the originating pension administration system (e.g., SimCorp Dimension or State Street fund administration platform).',
    `survivor_date_of_birth` DATE COMMENT 'Date of birth of the surviving beneficiary. Used for actuarial life expectancy calculations, benefit duration estimation, and childrens benefit age-out determination.',
    `survivor_full_name` STRING COMMENT 'Full legal name of the surviving beneficiary as recorded on official documentation. Used for payment processing, correspondence, and regulatory reporting.',
    `survivor_national_identifier` STRING COMMENT 'Government-issued national identification number (e.g., SSN in the US, NI number in the UK) of the surviving beneficiary. Required for tax reporting and KYC compliance.',
    `survivor_relationship_type` STRING COMMENT 'The legal relationship of the surviving beneficiary to the deceased member: spouse, common-law partner, dependent child, disabled dependent, or other dependent. Determines eligibility rules.. Valid values are `spouse|common_law_partner|dependent_child|disabled_dependent|other_dependent`',
    `tax_withholding_rate` DECIMAL(6,4) COMMENT 'Applicable income tax withholding rate applied to the survivor benefit payments (expressed as a decimal). Determined by jurisdiction and survivors tax elections.',
    `total_paid_to_date` DECIMAL(22,4) COMMENT 'Cumulative gross amount of survivor benefit payments disbursed to the beneficiary from commencement to the most recent payment date. Used for liability tracking and audit.',
    `valuation_date` DATE COMMENT 'The date as of which the actuarial present value of the survivor benefit was last calculated. Required for IFRS IAS 19 and regulatory actuarial reporting.',
    CONSTRAINT pk_survivor_benefit PRIMARY KEY(`survivor_benefit_id`)
) COMMENT 'Master record of survivor pension benefits established upon the death of a plan member or retiree. Stores the surviving beneficiary identity, survivor benefit type (survivor pension, death-in-service lump sum, childrens benefit), benefit amount';

CREATE OR REPLACE TABLE `asset_management`.`beneficiary`.`member_statement` (
    `member_statement_id` BIGINT COMMENT 'Unique surrogate identifier for each pension member statement record in the Silver layer lakehouse.',
    `contributor_pool_id` BIGINT COMMENT 'Foreign key linking to beneficiary.contributor_pool. Business justification: Member statements are issued per contributor pool. Normalizing STRING to FK.',
    `member_id` BIGINT COMMENT 'Reference to the pension plan member for whom this statement is issued. Links to the beneficiary master record.',
    `pension_plan_id` BIGINT COMMENT 'Reference to the pension plan (e.g., one of the participating plans) under which this statement is generated.',
    `portfolio_id` BIGINT COMMENT 'Foreign key linking to portfolio.portfolio. Business justification: Statements are generated per plan; linking to portfolio ensures accurate portfolio-level statement generation.',
    `accrual_rate` DECIMAL(8,6) COMMENT 'The annual benefit accrual rate applied to the members pensionable salary per year of service (e.g., 0.020000 = 2% per year of service).',
    `accrued_pension_annual_amount` DECIMAL(18,2) COMMENT 'The annual pension entitlement accrued by the member as at the statement period end date, expressed in the plan currency.',
    `acknowledgement_date` DATE COMMENT 'The date on which the member formally acknowledged receipt of this pension statement, if applicable.',
    `actuarial_valuation_date` DATE COMMENT 'The reference date of the actuarial valuation used to derive projected pension amounts and transfer values on this statement.',
    `benefit_formula_type` STRING COMMENT 'The type of pension benefit formula applicable to this members plan, determining how the accrued entitlement is calculated.. Valid values are `defined_benefit|defined_contribution|hybrid|cash_balance`',
    `best_average_salary` DECIMAL(18,2) COMMENT 'The highest average pensionable salary over the qualifying period (typically best 5 consecutive years) used in the defined benefit pension formula.',
    `buyback_service_years` DECIMAL(6,4) COMMENT 'Total years of prior service purchased (bought back) by the member to increase pensionable service, as at the statement period end date.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which all monetary amounts on this statement are denominated (e.g., USD, GBP).. Valid values are `^[A-Z]{3}$`',
    `date_of_birth` DATE COMMENT 'Date of birth of the pension plan member, used for actuarial calculations, normal retirement age determination, and benefit projections.',
    `delivery_channel` STRING COMMENT 'The channel through which this pension statement was delivered to the member (e.g., postal mail, secure member portal, email).. Valid values are `postal_mail|member_portal|email|in_person|employer_portal`',
    `delivery_date` DATE COMMENT 'The date on which the pension statement was successfully delivered to the member via the designated delivery channel.',
    `disability_benefit_eligible` BOOLEAN COMMENT 'Indicates whether the member is eligible for disability pension benefits under the applicable plan rules at the time of statement generation.',
    `discount_rate` DECIMAL(8,6) COMMENT 'The actuarial discount rate applied in the present value calculation of projected pension benefits and transfer value on this statement.',
    `early_retirement_eligible_date` DATE COMMENT 'The earliest date on which the member becomes eligible for unreduced early retirement benefits under the plan rules.',
    `employer_contributions_cumulative` DECIMAL(18,2) COMMENT 'Total cumulative employer pension contributions credited on behalf of the member since plan entry date.',
    `employer_contributions_ytd` DECIMAL(18,2) COMMENT 'Total employer pension contributions credited on behalf of the member during the current statement period.',
    `generated_timestamp` TIMESTAMP COMMENT 'The exact date and time when this statement record was first created in the system, serving as the audit creation timestamp.',
    `indexation_rate` DECIMAL(8,6) COMMENT 'The annual cost-of-living adjustment (COLA) or indexation rate applied to the members pension entitlement for the statement period.',
    `issue_date` DATE COMMENT 'The date on which the pension statement was formally issued and made available to the member.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'The date and time when this statement record was most recently modified, supporting audit trail and change tracking.',
    `leave_without_pay_service_years` DECIMAL(6,4) COMMENT 'Total years of leave without pay periods that are excluded from or included in pensionable service, as determined by plan rules.',
    `member_acknowledged` BOOLEAN COMMENT 'Indicates whether the member has formally acknowledged receipt of this pension statement via the member portal or written confirmation.',
    `member_contributions_cumulative` DECIMAL(18,2) COMMENT 'Total cumulative employee pension contributions made by the member since plan entry date, used for benefit entitlement and transfer value calculations.',
    `member_contributions_ytd` DECIMAL(18,2) COMMENT 'Total employee pension contributions made by the member during the current statement period.',
    `member_lifecycle_status` STRING COMMENT 'Current status of the member within the pension plan lifecycle at the time of statement generation.. Valid values are `active_contributor|deferred|retired|deceased|transferred_out`',
    `normal_retirement_date` DATE COMMENT 'The projected date at which the member reaches normal retirement age under the applicable plan rules, used for benefit projection calculations.',
    `pensionable_salary` DECIMAL(18,2) COMMENT 'The members annual pensionable salary as at the statement period end date, used as the basis for benefit accrual and contribution calculations.',
    `pensionable_service_years` DECIMAL(6,4) COMMENT 'Total years of pensionable service accrued by the member as at the statement period end date, expressed as a decimal (e.g., 15.5000 years).',
    `pensionable_service_ytd_years` DECIMAL(6,4) COMMENT 'Pensionable service accrued during the current statement period only, used to reconcile annual service increments.',
    `period_end_date` DATE COMMENT 'The last day of the reporting period covered by this pension statement (e.g., December 31 of the statement year).',
    `period_start_date` DATE COMMENT 'The first day of the reporting period covered by this pension statement (e.g., January 1 of the statement year).',
    `plan_entry_date` DATE COMMENT 'The date on which the member first enrolled in the pension plan, used as the anchor for pensionable service calculations.',
    `projected_pension_at_nra` DECIMAL(18,2) COMMENT 'Estimated annual pension benefit the member is projected to receive at normal retirement age, based on current service and salary assumptions.',
    `regulatory_disclosure_flag` BOOLEAN COMMENT 'Indicates whether this statement satisfies a mandatory regulatory disclosure obligation under applicable pension legislation or the national pension regulator guidance.',
    `source_system_reference` STRING COMMENT 'The originating system identifier for this statement record (e.g., SimCorp Dimension statement batch reference or State Street administration platform ID).',
    `statement_number` STRING COMMENT 'Externally visible unique reference number assigned to this pension statement, used for member correspondence and audit trail.. Valid values are `^STMT-[A-Z0-9]{4,10}-[0-9]{4}$`',
    `statement_status` STRING COMMENT 'Current lifecycle state of the statement from draft generation through member delivery and acknowledgement.. Valid values are `draft|generated|issued|delivered|acknowledged|superseded`',
    `statement_type` STRING COMMENT 'Classifies the nature of the statement issued to the member. [ENUM-REF-CANDIDATE: annual|on_demand|retirement_estimate|termination|death_benefit — promote to reference product]. Valid values are `annual|on_demand|retirement_estimate|termination|death_benefit`',
    `survivor_benefit_eligible` BOOLEAN COMMENT 'Indicates whether the member has a designated beneficiary eligible for survivor pension benefits under the plan rules.',
    `survivor_pension_annual_amount` DECIMAL(18,2) COMMENT 'The estimated annual survivor pension payable to the designated beneficiary upon the members death, based on accrued entitlement.',
    `transfer_value` DECIMAL(18,2) COMMENT 'The commuted or actuarial transfer value of the members accrued pension entitlement as at the statement date, used for portability and termination scenarios.',
    `voluntary_additional_contributions_ytd` DECIMAL(18,2) COMMENT 'Total voluntary additional contributions (VACs) made by the member during the statement period to purchase additional pensionable service.',
    CONSTRAINT pk_member_statement PRIMARY KEY(`member_statement_id`)
) COMMENT 'Transactional record representing the annual or on-demand pension statement issued to a plan member. Captures statement period, total pensionable service to date, projected pension at normal retirement age, accrued entitlement value, total contributions';

CREATE OR REPLACE TABLE `asset_management`.`beneficiary`.`employer_remittance` (
    `employer_remittance_id` BIGINT COMMENT 'Unique surrogate identifier for each employer remittance record in the pension fund system. Primary key for the employer_remittance data product.',
    `contributor_pool_id` BIGINT COMMENT 'Identifier of the beneficiary contributor pool (one per participating plan) to which this remittance applies. Links remittance to the correct liability pool.',
    `cash_account_id` BIGINT COMMENT 'Identifier of the employers bank account from which the remittance funds were transferred. Links to the counterparty bank account registry for settlement and KYC/AML compliance.',
    `fund_bank_account_id` BIGINT COMMENT 'Identifier of the pension funds designated bank account into which the remittance was received. Supports cash management, treasury reconciliation, and NAV determination.',
    `participating_employer_id` BIGINT COMMENT 'Identifier of the participating employer (government department, public agencies, other participating employers) submitting the bulk contribution remittance on behalf of their employees.',
    `pension_plan_id` BIGINT COMMENT 'Identifier of the specific pension plan under which this remittance is submitted. Supports multi-plan fund structures covering distinct beneficiary groups.',
    `portfolio_id` BIGINT COMMENT 'Foreign key linking to portfolio.portfolio. Business justification: Remittances are submitted to a specific plan; linking to portfolio enables correct remittance allocation and reconciliation.',
    `reversal_reference_employer_remittance_id` BIGINT COMMENT 'Identifier of the original remittance record that this record reverses or corrects. Populated only for remittance_type = reversal or adjustment. Supports audit trail and double-entry accounting.',
    `rule_breach_id` BIGINT COMMENT 'Foreign key linking to compliance.rule_breach. Business justification: Late or incorrect employer remittances trigger compliance breaches per pension legislation. Funds must track remittance violations for regulatory reporting.',
    `adjustment_amount` DECIMAL(20,4) COMMENT 'Net adjustment amount applied to this remittance to correct prior period over- or under-remittances. May be positive (top-up) or negative (credit/refund). Supports reconciliation workflows.',
    `approved_by` STRING COMMENT 'Name or identifier of the fund operations staff member who approved the acceptance of this remittance after review. Supports governance and four-eyes control requirements.',
    `approved_timestamp` TIMESTAMP COMMENT 'Date and time at which the remittance was formally approved and accepted by the pension fund operations team. Marks the transition from under_review to accepted status.',
    `arrears_amount` DECIMAL(20,4) COMMENT 'Amount included in this remittance to cover contributions that were due in prior periods but not previously remitted. Supports arrears tracking and actuarial liability reconciliation.',
    `bank_reference_number` STRING COMMENT 'Reference number assigned by the employers bank or payment processor for the funds transfer associated with this remittance. Used for bank reconciliation and settlement confirmation.',
    `cost_centre_code` STRING COMMENT 'Oracle Financials cost centre code associated with the employer or contributor pool for internal fund accounting and expense allocation purposes.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this remittance record was first created in the pension fund data system. Supports audit trail and data lineage requirements.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the remittance amounts (e.g., USD, GBP). Required for multi-currency fund operations and FX hedging reconciliation.. Valid values are `^[A-Z]{3}$`',
    `days_late` BIGINT COMMENT 'Number of calendar days by which the remittance submission exceeded the due date. Used to calculate interest on arrears and late penalties per plan rules.',
    `due_date` DATE COMMENT 'Contractual or regulatory deadline by which the employer was required to submit the remittance. Used to calculate late submission penalties and interest charges.',
    `employee_contribution_amount` DECIMAL(20,4) COMMENT 'Gross total of all employee (member) contributions included in this remittance batch, in the remittance currency. Represents the aggregate deducted from member salaries for the payroll period.',
    `employer_contact_email` STRING COMMENT 'Email address of the employers designated contact for this remittance submission. Used for automated acknowledgement, rejection notices, and reconciliation exception communications.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `employer_contact_name` STRING COMMENT 'Name of the primary contact person at the employer responsible for submitting and managing this remittance. Used for exception follow-up and operational communications.',
    `employer_contribution_amount` DECIMAL(20,4) COMMENT 'Gross total of employer-side contributions included in this remittance batch, in the remittance currency. Represents the employers matching or defined contribution obligation for the payroll period.',
    `file_reference_number` STRING COMMENT 'Reference number of the source data file or batch upload submitted by the employer containing the remittance details. Supports data lineage, reprocessing, and dispute resolution.',
    `gl_account_code` STRING COMMENT 'Oracle Financials General Ledger account code to which this remittance is posted. Ensures correct accounting treatment of contribution receipts in the funds ABOR (Accounting Book of Record).',
    `interest_on_arrears_amount` DECIMAL(20,4) COMMENT 'Interest charges levied on late or arrears contributions included in this remittance. Calculated per plan rules or regulatory prescribed rates on overdue contribution balances.',
    `is_late_submission` BOOLEAN COMMENT 'Flag indicating whether the remittance was submitted after the regulatory or plan-mandated due date. Triggers late penalty assessment and regulatory reporting obligations.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this remittance record. Tracks changes through the review, acceptance, and reconciliation lifecycle.',
    `late_penalty_amount` DECIMAL(20,4) COMMENT 'Monetary penalty assessed against the employer for late submission of the remittance, calculated per plan rules or regulatory prescribed rates. Tracked separately from interest on arrears.',
    `member_count` BIGINT COMMENT 'Number of active plan members (beneficiaries) covered by this remittance batch. Used to validate completeness of the submission against employer headcount records.',
    `notes` STRING COMMENT 'Free-text operational notes recorded by fund staff regarding this remittance, such as special handling instructions, employer communications, or exception context not captured in structured fields.',
    `payment_method` STRING COMMENT 'Mechanism used by the employer to transfer the remittance funds to the pension fund. Determines settlement timing, reconciliation process, and applicable SSI (Standard Settlement Instructions).. Valid values are `wire_transfer|eft|cheque|direct_debit|internal_transfer`',
    `payroll_period_end_date` DATE COMMENT 'End date of the payroll period covered by this remittance. Together with payroll_period_start_date, defines the contribution window for liability matching and actuarial calculations.',
    `payroll_period_start_date` DATE COMMENT 'Start date of the payroll period covered by this remittance. Defines the contribution window for which employee and employer contributions are being remitted.',
    `received_timestamp` TIMESTAMP COMMENT 'Exact date and time the remittance was received and recorded by the pension fund system. Serves as the principal business event timestamp for audit and SLA tracking.',
    `reconciliation_date` DATE COMMENT 'Date on which the remittance was successfully reconciled against bank receipts and member contribution records. Null if reconciliation is pending or in exception.',
    `reconciliation_status` STRING COMMENT 'Status of the cash and contribution reconciliation process for this remittance. Tracks whether the received funds have been matched to the employers submission data and member-level records.. Valid values are `unreconciled|in_progress|reconciled|exception|written_off`',
    `rejection_reason_code` STRING COMMENT 'Standardized code indicating the reason for rejection or partial acceptance of the remittance submission. Populated when remittance_status is rejected or partially_accepted.',
    `rejection_reason_description` STRING COMMENT 'Free-text description providing additional context for the rejection or exception raised against this remittance. Supports employer communication and dispute resolution workflows.',
    `remittance_channel` STRING COMMENT 'Channel through which the employer submitted the remittance data to the fund. Supports operational analytics on submission quality, SLA compliance, and digital adoption tracking.. Valid values are `employer_portal|api|manual_upload|paper_form|payroll_integration`',
    `remittance_reference_number` STRING COMMENT 'Externally-known unique reference number assigned to the remittance submission by the employer or payroll system. Used for reconciliation and audit trail across fund and employer records.. Valid values are `^REM-[A-Z0-9]{4,20}$`',
    `remittance_status` STRING COMMENT 'Current lifecycle status of the remittance submission. Tracks workflow from initial submission through fund acceptance, rejection, or reversal. [ENUM-REF-CANDIDATE: submitted|under_review|accepted|rejected|partially_accepted|reversed — promote to. Valid values are `submitted|under_review|accepted|rejected|partially_accepted|reversed`',
    `remittance_type` STRING COMMENT 'Classification of the remittance submission. Regular denotes scheduled payroll-cycle contributions; supplemental covers off-cycle top-ups; adjustment corrects prior submissions; arrears covers late contributions; reversal cancels a prior remittance.. Valid values are `regular|supplemental|adjustment|arrears|reversal`',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record from which this remittance record originated (e.g., SimCorp Dimension, Oracle Financials, Employer Portal). Supports data lineage and ABOR/IBOR reconciliation.. Valid values are `SIMCORP|ORACLE_FIN|EMPLOYER_PORTAL|STATE_STREET|MANUAL`',
    `submission_date` DATE COMMENT 'The date on which the employer formally submitted the remittance to the pension fund. Used to assess timeliness against regulatory and plan deadlines.',
    `total_remittance_amount` DECIMAL(20,4) COMMENT 'Net total amount remitted in this submission, equal to the sum of employee contributions, employer contributions, voluntary contributions, arrears, interest on arrears, and adjustments. Primary monetary fact for the transaction.',
    `value_date` DATE COMMENT 'The date on which the remitted funds are credited to the pension fund account and become available for investment. Aligns with settlement conventions (e.g., T+2) and cash management.',
    `variance_amount` DECIMAL(20,4) COMMENT 'Difference between the expected contribution amount (per member records) and the actual amount remitted by the employer. Non-zero values trigger exception handling and employer follow-up.',
    `voluntary_contribution_amount` DECIMAL(20,4) COMMENT 'Total of any additional voluntary contributions (AVCs) included in this remittance batch beyond mandatory contribution rates. Supports member-level benefit entitlement calculations.',
    CONSTRAINT pk_employer_remittance PRIMARY KEY(`employer_remittance_id`)
) COMMENT 'Transactional record of bulk contribution remittances submitted by participating employers (government departments, public agencies, other participating employers) to the fund on behalf of their employees.';

CREATE OR REPLACE TABLE `asset_management`.`beneficiary`.`participating_employer` (
    `participating_employer_id` BIGINT COMMENT 'Unique surrogate identifier for the participating employer record within the pension plan. Primary key for this master party entity.',
    `actor_id` BIGINT COMMENT 'Foreign key linking to shared.actor. Business justification: Participating employers (government departments, public agencies) are organizational actors.',
    `contributor_pool_id` BIGINT COMMENT 'Foreign key linking to beneficiary.contributor_pool. Business justification: Participating employers belong to a specific contributor pool (one per participating plan). Normalizing STRING to FK.',
    `kyc_record_id` BIGINT COMMENT 'Foreign key linking to compliance.kyc_record. Business justification: Pension funds must perform KYC due diligence on participating employers per AML/CFT regulations. Employer verification is mandatory before accepting contributions.',
    `regulatory_authority_id` BIGINT COMMENT 'Foreign key linking to compliance.regulatory_authority. Business justification: Employers operate under jurisdiction-specific pension regulators. Multi-jurisdictional pension funds must track which authority governs each employer for compliance reporting',
    `active_member_count` BIGINT COMMENT 'Current number of active contributing members employed by this employer and enrolled in the pension plan. Used for actuarial liability estimation and contribution forecasting.',
    `aml_risk_rating` STRING COMMENT 'AML/CTF risk classification assigned to this employer based on KYC due diligence. Governs enhanced due diligence requirements and monitoring frequency.. Valid values are `low|medium|high`',
    `bank_account_reference` STRING COMMENT 'Masked or tokenized reference to the employers designated bank account used for contribution remittances. Full account details held in the treasury system.',
    `benefit_formula_code` STRING COMMENT 'Code referencing the specific benefit accrual formula applicable to members of this employer. Links to the plan rules governing final average earnings, accrual rates, and indexation.. Valid values are `^[A-Z0-9_]{2,20}$`',
    `bic_code` STRING COMMENT 'ISO 9362 Bank Identifier Code (BIC/SWIFT) of the employers remittance bank. Used for settlement routing and Standard Settlement Instructions (SSI) validation.. Valid values are `^[A-Z]{4}[A-Z]{2}[A-Z0-9]{2}([A-Z0-9]{3})?$`',
    `collective_agreement_reference` STRING COMMENT 'Reference number or identifier of the collective bargaining agreement governing employment terms for this employers pension-eligible members. Impacts benefit entitlements.',
    `contribution_remittance_frequency` STRING COMMENT 'Frequency at which this employer remits pension contributions to the fund. Governs cash flow forecasting, reconciliation schedules, and late payment monitoring.. Valid values are `weekly|bi_weekly|semi_monthly|monthly|quarterly`',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the employers primary operating country. Used for regulatory reporting and cross-border contribution tracking.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this participating employer record was first created in the system. Supports audit trail, data lineage, and regulatory record-keeping requirements.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the employers contribution and payroll amounts (e.g., USD, GBP). Supports multi-currency contribution reconciliation.. Valid values are `^[A-Z]{3}$`',
    `data_sharing_agreement` BOOLEAN COMMENT 'Indicates whether a formal data sharing agreement is in place between the pension fund and this employer, governing the exchange of member and payroll data.',
    `data_sharing_agreement_date` DATE COMMENT 'Date on which the current data sharing agreement between the pension fund and this employer was executed. Used for agreement renewal tracking and compliance audits.',
    `effective_date` DATE COMMENT 'Date from which the current participation terms, contribution rates, and plan rules became effective for this employer.',
    `employee_contribution_rate` DECIMAL(8,6) COMMENT 'Standard employee contribution rate applicable to members employed by this employer, expressed as a decimal fraction of pensionable earnings. May vary by member tier.',
    `employer_code` STRING COMMENT 'Unique alphanumeric code assigned to the participating employer by the pension plan administrator. Used as the primary operational identifier across payroll and contribution systems.. Valid values are `^[A-Z0-9]{2,20}$`',
    `employer_contribution_rate` DECIMAL(8,6) COMMENT 'Contractual employer contribution rate expressed as a decimal fraction of pensionable earnings (e.g., 0.095000 = 9.5%). Defined in the plan participation agreement.',
    `employer_type` STRING COMMENT 'Classification of the participating employer by organizational category within the pension framework. [ENUM-REF-CANDIDATE: government_department|public_agency|municipal_employer|other_employer|municipal_entity|other —',
    `enrollment_date` DATE COMMENT 'Date on which the employer was formally enrolled as a participating employer in the pension plan. Marks the start of contribution and reporting obligations.',
    `esg_policy_compliant` BOOLEAN COMMENT 'Indicates whether the employer has acknowledged and complies with the pension funds ESG and responsible investment policy requirements for participating employers.',
    `jurisdiction_code` STRING COMMENT 'ISO 3166-2 subdivision code (or 3-letter country code) representing the primary regulatory jurisdiction governing this employers pension obligations.. Valid values are `^[A-Z]{2,3}$`',
    `kyc_review_date` DATE COMMENT 'Date of the most recent KYC/AML review completed for this employer. Drives periodic refresh scheduling per FATF requirements.',
    `kyc_verified` BOOLEAN COMMENT 'Indicates whether the employer has completed the required KYC/AML verification process. Mandatory for onboarding and ongoing regulatory compliance.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this participating employer record. Used for change tracking, data freshness monitoring, and audit compliance.',
    `late_remittance_count` BIGINT COMMENT 'Cumulative count of late contribution remittances recorded for this employer in the current plan year. Used for SLA monitoring, penalty assessment, and compliance reporting.',
    `legal_name` STRING COMMENT 'Full legal registered name of the participating employer organization (e.g., government department, public agency, or other participating employer).',
    `lei` STRING COMMENT '20-character ISO 17442 Legal Entity Identifier assigned to the employer for regulatory reporting and counterparty identification purposes.. Valid values are `^[A-Z0-9]{18}[0-9]{2}$`',
    `normal_retirement_age` BIGINT COMMENT 'Standard retirement age applicable to members employed by this employer under the plan rules. Used for actuarial liability projections and LDI/ALM modeling.',
    `notes` STRING COMMENT 'Free-text field for plan administrators to record material observations, exceptions, or contextual information about this employers participation that is not captured in structured fields.',
    `outstanding_contribution_amount` DECIMAL(20,2) COMMENT 'Total value of pension contributions currently outstanding (unpaid or unreconciled) from this employer. Critical for cash management, actuarial funding, and regulatory compliance.',
    `participation_agreement_date` DATE COMMENT 'Date on which the participation agreement was signed by both the employer and the pension fund. Establishes the legal basis for contribution obligations.',
    `participation_agreement_number` STRING COMMENT 'Unique reference number of the formal participation agreement executed between the pension fund and this employer. Governs all rights and obligations of plan participation.. Valid values are `^[A-Z0-9-]{4,30}$`',
    `participation_status` STRING COMMENT 'Current lifecycle status of the employers participation in the pension plan. Drives contribution processing, reporting obligations, and member enrollment eligibility.. Valid values are `active|suspended|terminated|pending_enrollment|pending_termination`',
    `payroll_system_code` STRING COMMENT 'Identifier used by the employers payroll system to reference this employer entity. Enables automated reconciliation of contribution remittances from payroll source systems.. Valid values are `^[A-Z0-9_]{2,30}$`',
    `pensionable_payroll_amount` DECIMAL(20,2) COMMENT 'Total annual pensionable payroll (in plan currency) for this employer as of the most recent reporting period. Basis for contribution rate application and actuarial valuation.',
    `plan_type` STRING COMMENT 'Type of pension plan applicable to this employers members. Determines benefit calculation methodology, actuarial assumptions, and LDI/ALM treatment.. Valid values are `defined_benefit|defined_contribution|hybrid|supplemental`',
    `primary_contact_email` STRING COMMENT 'Official email address of the employers primary pension plan contact. Used for contribution notices, capital call communications, and regulatory correspondence.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `primary_contact_name` STRING COMMENT 'Full name of the designated primary contact person at the employer responsible for pension plan administration and contribution remittance.',
    `primary_contact_phone` STRING COMMENT 'Primary telephone number for the employers pension plan contact. Used for urgent contribution and member enrollment communications.. Valid values are `^+?[0-9s-().]{7,20}$`',
    `registered_address_line1` STRING COMMENT 'First line of the employers official registered address. Used for regulatory correspondence, contribution notices, and KYC/AML verification.',
    `registered_address_line2` STRING COMMENT 'Second line of the employers official registered address (suite, floor, unit). Supplements the primary address line for complete postal identification.',
    `registered_city` STRING COMMENT 'City of the employers official registered address. Used for geographic segmentation, regulatory reporting, and contribution remittance routing.',
    `registered_postal_code` STRING COMMENT 'Postal or ZIP code of the employers official registered address. Required for contribution remittance and regulatory correspondence.',
    `remittance_due_day` BIGINT COMMENT 'Calendar day of the month (1–31) by which contribution remittances must be received from this employer. Used for SLA monitoring and late payment penalty calculations.',
    `short_name` STRING COMMENT 'Abbreviated or commonly used operating name of the participating employer, used in reports and system displays where full legal name is impractical.',
    `termination_date` DATE COMMENT 'Date on which the employers participation in the pension plan was formally terminated. Null if participation is still active.',
    `vesting_period_years` DECIMAL(5,2) COMMENT 'Minimum years of service required for members of this employer to become fully vested in the pension benefit. Governs entitlement calculations and member lifecycle management.',
    CONSTRAINT pk_participating_employer PRIMARY KEY(`participating_employer_id`)
) COMMENT 'Master record of all government departments, public agencies, and other participating employers.';

CREATE OR REPLACE TABLE `asset_management`.`beneficiary`.`benefit_option` (
    `benefit_option_id` BIGINT COMMENT 'Unique surrogate identifier for a pension benefit option available to members at retirement. Primary key for the benefit_option reference entity.',
    `contributor_pool_id` BIGINT COMMENT 'Foreign key linking to beneficiary.contributor_pool. Business justification: Benefit options are defined per contributor pool. The contributor_pool_code STRING should be normalized to a FK.',
    `actuarial_basis_code` STRING COMMENT 'Code identifying the actuarial assumptions basis (mortality table, discount rate set, and valuation methodology) used to calculate reduction factors and transfer values for this option (e.g., RP2014_SCALE_MP_2021).',
    `actuarial_basis_effective_date` DATE COMMENT 'Date from which the current actuarial basis (mortality table and assumptions) referenced by actuarial_basis_code became effective for this benefit option. Supports liability valuation versioning.',
    `benefit_option_status` STRING COMMENT 'Current lifecycle status of the benefit option. Inactive or deprecated options may still apply to members who elected them historically. Grandfathered options are closed to new elections.. Valid values are `active|inactive|deprecated|pending_approval|grandfathered`',
    `bridge_benefit_eligible` BOOLEAN COMMENT 'Indicates whether this benefit option includes a bridge benefit component, which supplements pension income until the member reaches the state pension eligibility age.',
    `bridge_benefit_end_age` DECIMAL(4,1) COMMENT 'Age at which the bridge benefit component ceases (typically 65, aligned with state pension eligibility). Null if bridge_benefit_eligible is false.',
    `commutation_allowed` BOOLEAN COMMENT 'Indicates whether a lump-sum commutation (partial or full conversion of the annuity to a present value cash payment) is permitted under this benefit option. Subject to applicable tax law limits.',
    `commutation_max_pct` DECIMAL(5,4) COMMENT 'Maximum percentage of the pensions actuarial present value that may be commuted to a lump sum under this option (e.g., 0.2500 = 25%). Null if commutation_allowed is false.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this benefit option record was first created in the system of record. Supports data lineage, audit trail, and regulatory record-keeping requirements.',
    `death_benefit_type` STRING COMMENT 'Type of death benefit payable if the member dies before or after pension commencement under this option. Drives beneficiary designation requirements and actuarial reserve calculations.. Valid values are `return_of_contributions|continuation_to_survivor|guaranteed_period_balance|none`',
    `default_option` BOOLEAN COMMENT 'Indicates whether this benefit option is the plan default applied when a member does not make an explicit election within the election window. Typically the joint and survivor annuity for married members.',
    `early_retirement_reduction` BOOLEAN COMMENT 'Indicates whether an actuarial reduction applies to the pension amount when this option is elected before the members unreduced retirement age. Relevant for early retirement planning analytics.',
    `early_retirement_reduction_rate` DECIMAL(6,5) COMMENT 'Annual actuarial reduction rate applied per year of early retirement before the unreduced retirement age (e.g., 0.03000 = 3% per year). Null if early_retirement_reduction is false.',
    `effective_date` DATE COMMENT 'Date from which this benefit option became available for member election within the applicable contributor pool. Used for eligibility determination and actuarial liability calculations.',
    `election_irrevocable` BOOLEAN COMMENT 'Indicates whether the members election of this benefit option is irrevocable once made. True for most annuity forms post-commencement. Drives member counselling and governance requirements.',
    `election_window_days` BIGINT COMMENT 'Number of days prior to the members retirement date within which this benefit option must be elected. Governs member communication timelines and plan administration workflows.',
    `expiry_date` DATE COMMENT 'Date on which this benefit option was closed to new elections. Null if the option remains open. Supports grandfathering logic and liability-driven investment (LDI) horizon analysis.',
    `guaranteed_period_years` BIGINT COMMENT 'Number of years for which pension payments are guaranteed regardless of the members survival (e.g., 5, 10, 15 years). Applicable only to guaranteed period options. Null for non-guaranteed options.',
    `indexation_cap_pct` DECIMAL(5,4) COMMENT 'Maximum annual indexation rate applied to pension payments under this option (e.g., 0.0800 = 8% cap). Null if indexation_type is full_cpi or none. Used in actuarial liability modelling and LDI stress testing.',
    `indexation_floor_pct` DECIMAL(5,4) COMMENT 'Minimum annual indexation rate guaranteed under this option (e.g., 0.0000 = no negative indexation). Null if indexation_type is none. Relevant for liability-driven investment (LDI) and actuarial liability matching.',
    `indexation_type` STRING COMMENT 'Type of cost-of-living indexation applied to pension payments under this option. Full CPI = 100% of Consumer Price Index; Partial CPI = capped or floored CPI; Fixed Rate = predetermined annual increase; None = flat payment.. Valid values are `full_cpi|partial_cpi|fixed_rate|none`',
    `ldi_liability_category` STRING COMMENT 'Classification of the pension liability stream generated by this benefit option for liability-driven investment (LDI) and asset-liability management (ALM) purposes. Drives duration matching and hedging strategy.. Valid values are `indexed_deferred|indexed_in_payment|non_indexed|bridge|contingent`',
    `max_retirement_age` DECIMAL(4,1) COMMENT 'Maximum age by which a member must commence this benefit option. Typically aligned with tax-law mandatory commencement rules (e.g., a statutory maximum age). Null if no upper bound applies.',
    `member_facing_description` STRING COMMENT 'Plain-language description of this benefit option as presented in member communications, pension statements, and retirement counselling materials. Supports member education and disclosure obligations.',
    `min_retirement_age` DECIMAL(4,1) COMMENT 'Minimum age at which a member is eligible to elect this benefit option. Varies by contributor pool and option type (e.g., early retirement options may have different thresholds).',
    `min_service_years` DECIMAL(5,2) COMMENT 'Minimum years of pensionable service required for a member to be eligible to elect this benefit option. Used in eligibility screening during retirement counselling.',
    `option_code` STRING COMMENT 'Externally-known alphanumeric code uniquely identifying the benefit option within the pension plan (e.g., SLA, JSA_50, JSA_100, GP5, BRIDGE). Used in member communications and plan documents.. Valid values are `^[A-Z0-9_]{2,30}$`',
    `option_name` STRING COMMENT 'Human-readable name of the benefit option as presented to plan members (e.g., Single Life Annuity, Joint and Survivor 60% Annuity, Bridge Benefit, Guaranteed Period 10-Year).',
    `option_type` STRING COMMENT 'High-level classification of the benefit option structure. Drives actuarial valuation methodology and member eligibility rules. [ENUM-REF-CANDIDATE: promote to reference product if additional types are added]. Valid values are `single_life_annuity|joint_and_survivor_annuity|guaranteed_period|bridge_benefit|indexed_annuity|combination`',
    `payment_frequency` STRING COMMENT 'Frequency at which pension payments are disbursed to the member under this option. Monthly is standard for most pension plans.. Valid values are `monthly|quarterly|semi_annual|annual`',
    `payment_timing` STRING COMMENT 'Indicates whether pension payments under this option are made at the beginning (in advance) or end (in arrears) of each payment period. Affects actuarial present value calculations.. Valid values are `in_advance|in_arrears`',
    `pension_adjustment_applicable` BOOLEAN COMMENT 'Indicates whether a Pension Adjustment (PA) must be reported on the members annual tax slip for years in which this benefit option accrues. Relevant for registered pension plan tax compliance reporting.',
    `plan_text_reference` STRING COMMENT 'Reference to the specific section or clause in the pension plan text or legislation that governs this benefit option (e.g., a section of the governing plan statute). Supports regulatory audit.',
    `reduction_factor_pct` DECIMAL(7,6) COMMENT 'Actuarially determined reduction applied to the members base pension amount when electing this option, expressed as a decimal (e.g., 0.050000 = 5% reduction for joint and survivor coverage). Derived from actuarial tables.',
    `regulatory_approval_ref` STRING COMMENT 'Reference number or identifier for the regulatory approval or registration of this benefit option with the applicable pension regulator (e.g. registration number). Supports compliance and audit trails.',
    `sort_order` BIGINT COMMENT 'Integer controlling the display sequence of benefit options in member-facing portals, retirement counselling tools, and administrative systems. Lower values appear first.',
    `spousal_consent_required` BOOLEAN COMMENT 'Indicates whether spousal or common-law partner consent is required for the member to elect this option. Typically required when waiving joint and survivor coverage. Regulatory compliance field.',
    `survivor_fraction_pct` DECIMAL(5,4) COMMENT 'For joint and survivor annuity options, the fraction of the members pension payable to the surviving spouse or beneficiary upon the members death (e.g., 0.5000, 0.6000, 0.6667, 1.0000). Null for non-joint options.',
    `tax_treatment_code` STRING COMMENT 'Code identifying the income tax treatment applicable to pension payments under this option (e.g., REGISTERED_PENSION_PLAN_RPP, retirement_account_transfer). Aligns with tax authority reporting requirements.',
    `transfer_value_eligible` BOOLEAN COMMENT 'Indicates whether a member electing this option is eligible to receive a transfer value (commuted value transferred to a locked-in retirement account) instead of the annuity. Typically available before pension commencement.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this benefit option record. Used for change detection, data synchronisation, and audit trail maintenance across the lakehouse silver layer.',
    CONSTRAINT pk_benefit_option PRIMARY KEY(`benefit_option_id`)
) COMMENT 'Reference entity defining the menu of pension benefit options available to members at retirement within each contributor pool: single life annuity, joint and survivor annuity (50%, 60%, 66.67%, 100% survivor fractions), guaranteed period options, bridge';

CREATE OR REPLACE TABLE `asset_management`.`beneficiary`.`overpayment_recovery` (
    `overpayment_recovery_id` BIGINT COMMENT 'Unique surrogate identifier for each overpayment recovery record in the pension fund beneficiary domain.',
    `designated_beneficiary_id` BIGINT COMMENT 'Reference to the pension plan member who received the overpayment. Links to the beneficiary master record.',
    `benefit_payment_id` BIGINT COMMENT 'Reference to the original benefit payment transaction that resulted in the overpayment.',
    `contributor_pool_id` BIGINT COMMENT 'Foreign key linking to beneficiary.contributor_pool. Business justification: Overpayment recovery records have contributor_pool STRING. Recovery rules may vary by pool. Normalizing to FK.',
    `member_id` BIGINT COMMENT 'Reference to the pension plan member who received the overpayment. Links to the beneficiary master record.',
    `rule_breach_id` BIGINT COMMENT 'Foreign key linking to compliance.rule_breach. Business justification: Overpayments often constitute compliance breaches requiring formal tracking. Pension regulators require breach documentation for overpayment incidents.',
    `actual_recovery_end_date` DATE COMMENT 'Date on which the recovery was fully completed or formally closed, whether through full repayment, write-off, or legal settlement.',
    `amount_recovered_to_date` DECIMAL(18,2) COMMENT 'Cumulative amount successfully recovered from the beneficiary or their estate as of the most recent update to this record.',
    `case_notes` STRING COMMENT 'Free-text notes recorded by the case owner documenting key events, member communications, and decisions throughout the recovery lifecycle.',
    `case_owner` STRING COMMENT 'Name or employee identifier of the pension administration officer assigned as the primary owner of this recovery case.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this overpayment recovery record was first created in the system, used for audit trail and data lineage.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for all monetary amounts on this overpayment recovery record (e.g., USD, GBP).. Valid values are `^[A-Z]{3}$`',
    `detection_date` DATE COMMENT 'Date on which the overpayment was first identified, either through system reconciliation, audit, or member notification.',
    `dispute_date` DATE COMMENT 'Date on which the beneficiary formally raised a dispute against the overpayment recovery claim.',
    `dispute_outcome` STRING COMMENT 'Outcome of the formal dispute process, indicating whether the recovery claim was upheld, partially upheld, dismissed, or withdrawn.. Valid values are `upheld|partially_upheld|dismissed|withdrawn`',
    `dispute_raised` BOOLEAN COMMENT 'Indicates whether the beneficiary or their estate has formally disputed the overpayment claim or the recovery amount.',
    `dispute_resolution_date` DATE COMMENT 'Date on which the dispute was formally resolved, either in favour of the fund or the beneficiary.',
    `estate_claim_reference` STRING COMMENT 'Reference number for the claim filed against the deceased beneficiarys estate for recovery of overpaid pension benefits.',
    `expected_recovery_end_date` DATE COMMENT 'Projected date by which the full net recoverable amount is expected to be collected based on the agreed recovery plan.',
    `gl_account_code` STRING COMMENT 'Oracle Financials GL account code to which the overpayment recovery transaction is posted for accounting and financial reporting.',
    `gross_overpayment_amount` DECIMAL(18,2) COMMENT 'Total gross amount paid to the beneficiary in excess of their entitlement over the overpayment period, before any adjustments or recoveries.',
    `hardship_waiver_amount` DECIMAL(18,2) COMMENT 'Amount of the overpayment formally waived due to the beneficiarys demonstrated financial hardship, reducing the net recoverable balance.',
    `hardship_waiver_granted` BOOLEAN COMMENT 'Indicates whether a financial hardship waiver has been granted to the beneficiary, reducing or suspending the recovery obligation.',
    `instalment_amount` DECIMAL(18,2) COMMENT 'Periodic instalment amount agreed with the beneficiary for repayment of the overpayment, applicable when recovery method is instalment plan.',
    `instalment_frequency` STRING COMMENT 'Frequency at which recovery instalments are scheduled to be deducted or received from the beneficiary.. Valid values are `monthly|quarterly|annually|one_time`',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this overpayment recovery record, supporting audit trail and change tracking requirements.',
    `legal_action_date` DATE COMMENT 'Date on which formal legal proceedings were initiated to recover the outstanding overpayment balance.',
    `legal_action_initiated` BOOLEAN COMMENT 'Indicates whether formal legal proceedings have been initiated to recover the overpayment from the beneficiary or their estate.',
    `member_notification_date` DATE COMMENT 'Date on which the beneficiary was formally notified of the overpayment and the funds intent to recover the amount.',
    `net_recoverable_amount` DECIMAL(18,2) COMMENT 'Net amount the fund is entitled to recover from the beneficiary after tax adjustments, representing the actual recovery target.',
    `notification_channel` STRING COMMENT 'Channel through which the overpayment notification was communicated to the beneficiary or their legal representative.. Valid values are `letter|email|phone|portal|in_person`',
    `outstanding_balance` DECIMAL(18,2) COMMENT 'Remaining amount yet to be recovered, calculated as net recoverable amount minus amount recovered to date.',
    `overpayment_cause` STRING COMMENT 'Root cause category explaining why the benefit was paid in excess of entitlement. [ENUM-REF-CANDIDATE: death_notification_delay|calculation_error|eligibility_change|duplicate_payment|rate_error|other — promote to reference product]. Valid values are `death_notification_delay|calculation_error|eligibility_change|duplicate_payment|rate_error|other`',
    `overpayment_end_date` DATE COMMENT 'Date on which the overpayment ceased, either because the benefit was corrected, suspended, or the members entitlement was updated.',
    `overpayment_start_date` DATE COMMENT 'Date from which the benefit payments began to exceed the members entitlement, marking the beginning of the overpayment period.',
    `overpayment_type` STRING COMMENT 'Classification of the benefit type that was overpaid, distinguishing pension, survivor, disability, or lump-sum payments.. Valid values are `pension_benefit|survivor_benefit|disability_benefit|lump_sum|other`',
    `recovery_method` STRING COMMENT 'Mechanism by which the overpayment is being recovered, such as deduction from ongoing benefit, lump-sum repayment, or estate claim.. Valid values are `benefit_deduction|lump_sum_repayment|estate_claim|legal_action|write_off|instalment_plan`',
    `recovery_reference_number` STRING COMMENT 'Externally-visible unique reference number assigned to this overpayment recovery case, used in member correspondence and audit trails.. Valid values are `^OPR-[0-9]{4}-[0-9]{6}$`',
    `recovery_start_date` DATE COMMENT 'Date on which the recovery process formally commenced, i.e., when the first deduction or repayment was initiated.',
    `recovery_status` STRING COMMENT 'Current lifecycle state of the overpayment recovery case. [ENUM-REF-CANDIDATE: identified|notified|in_recovery|disputed|recovered|written_off|suspended — promote to reference product]',
    `regulatory_report_date` DATE COMMENT 'Date on which this overpayment recovery case was reported to the relevant regulatory authority, where reporting is required.',
    `regulatory_reporting_required` BOOLEAN COMMENT 'Indicates whether this overpayment recovery case must be reported to a regulatory body such as Pension regulator or a local pension regulator.',
    `responsible_team` STRING COMMENT 'Internal team or department responsible for managing and progressing this overpayment recovery case.. Valid values are `pension_admin|member_services|legal|finance|actuarial`',
    `simcorp_case_reference` STRING COMMENT 'Reference identifier for this overpayment recovery case as recorded in SimCorp Dimension ABOR/Investment Accounting module.',
    `tax_adjustment_amount` DECIMAL(18,2) COMMENT 'Tax withheld or adjustments applied to the gross overpayment amount, reflecting net recoverable amount after tax treatment.',
    `write_off_amount` DECIMAL(18,2) COMMENT 'Portion of the net recoverable amount formally written off as irrecoverable, approved per the funds write-off policy.',
    `write_off_date` DATE COMMENT 'Date on which the write-off of the irrecoverable overpayment amount was formally approved and recorded.',
    `write_off_reason` STRING COMMENT 'Reason for writing off the irrecoverable balance, such as deceased with no estate, financial hardship, or statute-barred debt.. Valid values are `deceased_no_estate|hardship|statute_barred|legal_settlement|de_minimis|other`',
    CONSTRAINT pk_overpayment_recovery PRIMARY KEY(`overpayment_recovery_id`)
) COMMENT 'Transactional record tracking instances where benefit payments were made in excess of entitlement (due to death notification delays, calculation errors, or eligibility changes) and the subsequent recovery process.';

CREATE OR REPLACE TABLE `asset_management`.`beneficiary`.`member_document` (
    `member_document_id` BIGINT COMMENT 'Unique surrogate identifier for each member document record in the pension file management system. Primary key for the member_document entity.',
    `member_id` BIGINT COMMENT 'Reference to the pension plan member whose file this document belongs to. Links the document to the beneficiary master record.',
    `pension_plan_id` BIGINT COMMENT 'Reference to the pension plan (one per participating plan) under which this document was filed.',
    `superseded_by_document_id` BIGINT COMMENT 'Reference to the newer member_document record that replaces this document when a member submits an updated version (e.g., revised beneficiary designation). Null if not superseded.',
    `access_restriction_level` STRING COMMENT 'Operational access control level specifying which staff roles may view or process this document. Enforced by the document management systems role-based access control (RBAC) configuration.. Valid values are `unrestricted|plan_admin_only|legal_team_only|medical_officer_only|executive_only`',
    `beneficiary_designation_flag` BOOLEAN COMMENT 'Indicates whether this document constitutes or amends a beneficiary designation for death benefit purposes. Triggers update of the beneficiary entitlement record upon acceptance.',
    `certified_copy_flag` BOOLEAN COMMENT 'Indicates whether the document is a certified true copy authenticated by a notary, commissioner of oaths, or equivalent authority. Relevant for legal admissibility in pension division proceedings.',
    `contains_phi_flag` BOOLEAN COMMENT 'Indicates whether the document contains protected health information (PHI) such as medical diagnoses or disability assessments. Triggers enhanced access restrictions and audit logging.',
    `contains_pii_flag` BOOLEAN COMMENT 'Indicates whether the document contains personally identifiable information (PII) subject to privacy legislation. Drives access controls, masking requirements, and breach notification obligations.',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this member document record was first created in the pension administration system. Serves as the audit trail creation marker per data governance standards.',
    `data_classification` STRING COMMENT 'Information security classification of the document content per the funds data governance policy: restricted (PII/PHI), confidential (sensitive business), internal, or public.. Valid values are `restricted|confidential|internal|public`',
    `digital_repository_path` STRING COMMENT 'Logical path or URI to the documents digital file in the pension funds secure document management system or content repository. Confidential due to system access sensitivity.',
    `disability_certification_type` STRING COMMENT 'For disability-related documents, classifies whether this is an initial certification, a periodic renewal, or a termination of disability status. Not applicable for non-disability documents.. Valid values are `initial|renewal|termination|not_applicable`',
    `document_category` STRING COMMENT 'Broad grouping of the document for records management and retrieval: identity (ID proofs), entitlement (benefit rights), legal_order (court orders), medical (disability/death), financial (contribution/payment), administrative (forms/applications).. Valid values are `identity|entitlement|legal_order|medical|financial|administrative`',
    `document_date` DATE COMMENT 'The official date appearing on the document itself (e.g., date of signing, date of issuance by a court or authority). Distinct from the date the document was received by the fund.',
    `document_description` STRING COMMENT 'Free-text narrative describing the content, purpose, or special circumstances of the document, used by pension administrators for context during file review.',
    `document_language` STRING COMMENT 'ISO 639-1 or 639-2 language code of the documents primary language (e.g., en for English, fr for French). Determines translation requirements for multilingual pension administration.. Valid values are `^[a-z]{2,3}$`',
    `document_reference_number` STRING COMMENT 'Externally-known unique alphanumeric reference number assigned to the document upon receipt or generation, used for correspondence and audit trail purposes.. Valid values are `^DOC-[A-Z]{2,6}-[0-9]{8,12}$`',
    `document_status` STRING COMMENT 'Current lifecycle state of the document within the pension file workflow: received upon intake, under_review during verification, verified/accepted once validated, rejected if invalid, superseded if replaced, archived for closed files.',
    `document_title` STRING COMMENT 'Human-readable title or name of the document as it appears on the physical or digital record (e.g., Retirement Application Form – Plan 1).',
    `document_type` STRING COMMENT 'Classification of the document by its business purpose (e.g., enrollment_form, beneficiary_designation, retirement_application, marriage_certificate, divorce_order, disability_certification, death_certificate, power_of_attorney, transfer_request).',
    `effective_date` DATE COMMENT 'The date from which the documents instructions or legal effect become operative for pension entitlement purposes (e.g., effective date of a beneficiary designation change or pension division order).',
    `expiry_date` DATE COMMENT 'The date on which the document ceases to be valid or requires renewal (e.g., a temporary disability certification or a power of attorney with a defined term). Null for permanent documents.',
    `file_format` STRING COMMENT 'Digital file format of the stored document (e.g., PDF, TIFF, JPEG). Relevant for long-term preservation standards and accessibility compliance in pension records management.',
    `file_size_kb` BIGINT COMMENT 'Size of the digital document file in kilobytes. Used for storage capacity planning and to flag unusually large or small files that may indicate scanning quality issues.',
    `issuing_authority` STRING COMMENT 'Name of the government body, court, institution, or organization that issued or certified the document (e.g., a family court, the plan administrator, a participating employer).',
    `issuing_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the jurisdiction that issued the document. Required for foreign documents subject to apostille or notarization requirements.. Valid values are `^[A-Z]{3}$`',
    `issuing_jurisdiction` STRING COMMENT 'Province, state, or sub-national jurisdiction of the issuing authority where applicable (e.g., New York, California). Relevant for pension division orders and legal documents.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'The timestamp of the most recent modification to this member document record. Used for change data capture (CDC), audit trails, and data lineage in the Databricks Silver layer.',
    `member_notification_date` DATE COMMENT 'The date on which the member was formally notified of the document processing outcome. Used to measure compliance with regulatory notification timelines.',
    `member_notified_flag` BOOLEAN COMMENT 'Indicates whether the member has been formally notified of the documents acceptance, rejection, or any required follow-up action. Supports SLA compliance and member communication tracking.',
    `notarized_flag` BOOLEAN COMMENT 'Indicates whether the document has been notarized or certified by a commissioner of oaths. Must be True before processing for document types where requires_notarization is True.',
    `original_document_flag` BOOLEAN COMMENT 'Indicates whether the document on file is the original (True) or a certified copy, notarized copy, or digital scan (False). Originals may be required for certain legal proceedings.',
    `page_count` BIGINT COMMENT 'Total number of pages in the document. Used for completeness verification during intake — a document with fewer pages than expected may be flagged as incomplete.',
    `pension_division_flag` BOOLEAN COMMENT 'Indicates whether this document relates to a pension division order (e.g., divorce decree or domestic relations order splitting pension entitlement). Triggers actuarial recalculation workflows.',
    `received_date` DATE COMMENT 'The date on which the pension fund received the document from the member, legal authority, or third party. Used for SLA tracking and regulatory timeliness compliance.',
    `rejection_reason` STRING COMMENT 'Standardized reason code or description explaining why a document was rejected (e.g., illegible scan, missing signature, expired certification). Populated only when document_status is rejected.',
    `requires_notarization` BOOLEAN COMMENT 'Indicates whether the document type requires notarization or commissioner of oaths certification per plan rules or regulatory requirements before it can be actioned.',
    `retention_category` STRING COMMENT 'Records retention classification determining how long the document must be kept per regulatory and plan rules: permanent (e.g., death certificates), long_term (e.g., retirement applications), standard, or short_term.. Valid values are `permanent|long_term|standard|short_term`',
    `retention_expiry_date` DATE COMMENT 'The date after which the document may be destroyed or anonymized in accordance with the funds records retention schedule and applicable privacy regulations. Null for permanent records.',
    `review_notes` STRING COMMENT 'Free-text notes recorded by the pension administrator during document review, capturing deficiencies, follow-up actions required, or rationale for rejection. Confidential internal record.',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record from which this document record was ingested into the Databricks Silver layer (e.g., SimCorp Dimension, eFront, Oracle Financials, member portal).. Valid values are `SIMCORP|EFRONT|ORACLE|MANUAL|PORTAL|OTHER`',
    `storage_medium` STRING COMMENT 'Indicates whether the document is stored as a physical paper record, a digital file, or both. Drives records management, retention scheduling, and disaster recovery procedures.. Valid values are `physical|digital|both`',
    `submission_channel` STRING COMMENT 'The channel through which the member or authorized party submitted the document to the pension fund (e.g., mail, in-person at a service centre, secure member portal, fax).. Valid values are `mail|in_person|secure_portal|email|fax|third_party_agent`',
    `translated_flag` BOOLEAN COMMENT 'Indicates whether a certified translation of the document exists on file (True). Required when the original document is in a language other than the plans official administrative languages.',
    `verified_date` DATE COMMENT 'The date on which a pension administrator or authorized officer completed verification and authentication of the documents authenticity and completeness.',
    `version_number` STRING COMMENT 'Version identifier for the document, incremented when a new version supersedes a prior one (e.g., updated beneficiary designation form). Supports document lineage tracking.. Valid values are `^[0-9]+.[0-9]+$`',
    CONSTRAINT pk_member_document PRIMARY KEY(`member_document_id`)
) COMMENT 'Master record of official documents associated with a plan members pension file: enrollment forms, beneficiary designation forms, retirement applications, marriage certificates, divorce orders (for pension division), disability certifications, death';

CREATE OR REPLACE TABLE `asset_management`.`beneficiary`.`pension_division_order` (
    `pension_division_order_id` BIGINT COMMENT 'Unique surrogate identifier for the pension division order record within the pension fund system.',
    `designated_beneficiary_id` BIGINT COMMENT 'Reference to the pension plan member (contributor) whose pension entitlement is subject to the court-ordered division.',
    `contributor_pool_id` BIGINT COMMENT 'Foreign key linking to beneficiary.contributor_pool. Business justification: Pension division orders apply to benefits under a specific contributor pool. Normalizing STRING to FK.',
    `member_id` BIGINT COMMENT 'Reference to the pension plan member (contributor) whose pension entitlement is subject to the court-ordered division.',
    `pension_plan_id` BIGINT COMMENT 'Foreign key linking to beneficiary.pension_plan. Business justification: Pension division orders divide benefits under a specific pension plan. Adding plan_id FK for proper linkage.',
    `actuarial_commuted_value` DECIMAL(18,4) COMMENT 'The actuarially determined present value (commuted value) of the pension entitlement subject to division as at the actuarial valuation date.',
    `actuarial_report_reference` STRING COMMENT 'Reference number or identifier of the actuarial valuation report supporting the commuted value calculation used in the division order.',
    `actuarial_valuation_date` DATE COMMENT 'The reference date used by the actuary to calculate the commuted value or present value of the pension entitlement subject to division.',
    `appeal_flag` BOOLEAN COMMENT 'Indicates whether the pension division order is currently under appeal or subject to a legal challenge that may affect its implementation.',
    `appeal_resolution_date` DATE COMMENT 'The date on which any appeal or legal challenge to the pension division order was resolved, enabling final implementation to proceed.',
    `court_jurisdiction` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the jurisdiction in which the court order was issued, governing applicable family law and pension division legislation.. Valid values are `^[A-Z]{3}$`',
    `court_name` STRING COMMENT 'Name of the court or tribunal that issued the pension division order (e.g., a family court, Family Division).',
    `court_order_date` DATE COMMENT 'The date on which the court issued the pension division order, representing the principal real-world event date of the legal instrument.',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp at which this pension division order record was first created in the data platform, providing the audit trail creation marker.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code applicable to the division amount or equalization payment (e.g., USD, GBP).. Valid values are `^[A-Z]{3}$`',
    `division_amount` DECIMAL(18,4) COMMENT 'The fixed monetary amount of the pension entitlement or equalization payment allocated to the former spouse where a fixed-amount division method is specified.',
    `division_method` STRING COMMENT 'The method by which the pension entitlement is divided: percentage of pension credit, fixed monetary amount, actuarial present value, or pension credit split.. Valid values are `percentage|fixed_amount|actuarial_value|credit_split`',
    `division_percentage` DECIMAL(8,6) COMMENT 'The percentage of the pension credit or pension benefit allocated to the former spouse under the division order, expressed as a decimal (e.g., 0.500000 = 50%).',
    `effective_date` DATE COMMENT 'The date from which the pension division order takes operational effect on the members pension entitlement and benefit calculations.',
    `expiry_date` DATE COMMENT 'The date on which the pension division order ceases to have effect, if applicable (e.g., upon death of former spouse or full equalization payment).',
    `former_spouse_date_of_birth` DATE COMMENT 'Date of birth of the former spouse, required for actuarial valuation of the divided pension entitlement and survivor benefit calculations.',
    `former_spouse_full_name` STRING COMMENT 'Full legal name of the former spouse or domestic partner who is the beneficiary of the pension division order as identified in the court instrument.',
    `former_spouse_gender` STRING COMMENT 'Gender of the former spouse as recorded for actuarial mortality table selection and survivor benefit entitlement determination.. Valid values are `male|female|non_binary|not_disclosed`',
    `former_spouse_national_identifier` STRING COMMENT 'Government-issued national identification number (e.g., SSN, NIN) of the former spouse for identity verification and tax reporting purposes.',
    `implementation_date` DATE COMMENT 'The date on which the pension division order was operationally implemented in the pension administration system, adjusting the members benefit entitlement.',
    `is_indexation_shared` BOOLEAN COMMENT 'Indicates whether the pension indexation (cost-of-living adjustment) applicable to the divided pension benefit is shared with the former spouse.',
    `is_survivor_benefit_affected` BOOLEAN COMMENT 'Indicates whether the pension division order affects the survivor benefit entitlement of the former spouse under the plan rules.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'The timestamp at which this pension division order record was most recently modified in the data platform, supporting audit trail and change tracking.',
    `legal_counsel_reference` STRING COMMENT 'Reference identifier or name of the legal counsel or law firm representing the pension fund in the division proceedings, for case management purposes.',
    `marriage_breakdown_date` DATE COMMENT 'The date of marriage breakdown or separation as legally established, used to determine the pension credit accrued during the marriage period for division purposes.',
    `marriage_date` DATE COMMENT 'The date of marriage or commencement of domestic partnership, establishing the start of the period over which pension credits are subject to division.',
    `order_notes` STRING COMMENT 'Free-text notes capturing special conditions, legal qualifications, or administrative remarks associated with the pension division order.',
    `order_reference_number` STRING COMMENT 'Externally assigned court order reference number or file number uniquely identifying the legal instrument governing the pension division.',
    `order_status` STRING COMMENT 'Current lifecycle status of the pension division order, tracking progression from receipt through implementation or cancellation.. Valid values are `pending|active|implemented|suspended|cancelled|expired`',
    `order_type` STRING COMMENT 'Classification of the court-ordered pension division mechanism: equalization payment, pension sharing, deferred division, lump-sum transfer, or annuity split.. Valid values are `equalization_payment|pension_sharing|deferred_division|lump_sum_transfer|annuity_split`',
    `payment_transfer_date` DATE COMMENT 'The date on which the equalization payment or lump-sum transfer was executed to the former spouses designated account or retirement savings account/locked-in account.',
    `pension_credit_end_date` DATE COMMENT 'The end date of the pension credit accrual period subject to division, typically aligned with the marriage breakdown date.',
    `pension_credit_start_date` DATE COMMENT 'The start date of the pension credit accrual period subject to division, typically aligned with the marriage date or plan membership commencement.',
    `plan_type` STRING COMMENT 'The type of pension plan governing the members entitlement subject to division, determining the applicable actuarial methodology.. Valid values are `defined_benefit|defined_contribution|hybrid`',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record from which this pension division order record was sourced (e.g., pension administration platform).',
    `source_system_record_code` STRING COMMENT 'The native record identifier assigned by the source pension administration system, enabling lineage tracing and reconciliation with the system of record.',
    `transfer_account_reference` STRING COMMENT 'Masked or tokenized account reference at the destination financial institution to which the equalization payment or pension credit transfer is directed.',
    `transfer_destination_type` STRING COMMENT 'The type of vehicle to which the divided pension entitlement or equalization payment is transferred (e.g., individual retirement account, locked-in account, cash, another pension plan).. Valid values are `retirement_savings_account|locked_in_retirement_account|locked_in_savings_account|cash_payment|another_pension_plan|other`',
    `transfer_institution_name` STRING COMMENT 'Name of the financial institution or pension plan to which the divided entitlement or equalization payment is transferred on behalf of the former spouse.',
    `withholding_tax_amount` DECIMAL(18,4) COMMENT 'The amount of income tax withheld at source on the equalization payment or lump-sum transfer as required by applicable tax legislation.',
    CONSTRAINT pk_pension_division_order PRIMARY KEY(`pension_division_order_id`)
) COMMENT 'Transactional record of court-ordered pension division upon marriage breakdown, capturing the division order type (equalization payment, pension sharing, deferred division), effective date, division percentage or amount, former spouse identity, actuarial';

CREATE OR REPLACE TABLE `asset_management`.`beneficiary`.`pension_plan` (
    `pension_plan_id` BIGINT COMMENT 'Primary key for pension_plan',
    `accrual_rate_pct` DECIMAL(5,4) COMMENT 'Annual rate at which pension benefits accrue per year of credited service for defined benefit plans.',
    `actuarial_valuation_frequency` STRING COMMENT 'How often the plan undergoes formal actuarial valuation for funding assessment.',
    `benefit_formula_type` STRING COMMENT 'Method used to calculate pension benefits based on salary and service history.',
    `cola_cap_pct` DECIMAL(5,4) COMMENT 'Maximum annual percentage increase allowed for cost of living adjustments.',
    `cost_of_living_adjustment_type` STRING COMMENT 'Method for adjusting pension benefits to account for inflation post-retirement.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the pension plan record was first created in the system.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the plans base reporting currency.',
    `custodian_name` STRING COMMENT 'Name of the financial institution providing custody services for plan assets.',
    `pension_plan_description` STRING COMMENT 'Detailed narrative description of the pension plan terms, features, and provisions.',
    `disability_benefit_eligible` BOOLEAN COMMENT 'Indicates whether the plan provides disability pension benefits to eligible members.',
    `early_retirement_age` BIGINT COMMENT 'Minimum age at which members may elect early retirement with reduced benefits.',
    `effective_date` DATE COMMENT 'Date when the pension plan became legally effective and binding for participants.',
    `employee_contribution_rate_pct` DECIMAL(5,4) COMMENT 'Standard percentage of salary that employees contribute to the pension plan.',
    `employer_contribution_rate_pct` DECIMAL(5,4) COMMENT 'Standard percentage of salary that the employer contributes to the pension plan.',
    `esg_integration_level` STRING COMMENT 'Degree to which ESG factors are incorporated into investment decision-making.',
    `funding_policy` STRING COMMENT 'Approach used to fund pension liabilities and maintain plan solvency.',
    `investment_strategy` STRING COMMENT 'Overall investment approach governing asset allocation for the pension fund.',
    `jurisdiction_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code indicating the legal jurisdiction governing the plan.',
    `last_actuarial_valuation_date` DATE COMMENT 'Date of the most recent completed actuarial valuation of the pension plan.',
    `lump_sum_option_available` BOOLEAN COMMENT 'Indicates whether members can elect a lump sum payment instead of annuity at retirement.',
    `maximum_pensionable_earnings` DECIMAL(18,2) COMMENT 'Annual earnings cap above which contributions and benefits do not accrue.',
    `maximum_service_years` BIGINT COMMENT 'Maximum years of service that can be credited toward pension benefit calculation.',
    `minimum_service_years` BIGINT COMMENT 'Minimum years of credited service required to qualify for pension benefits.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the pension plan record was last updated in the system.',
    `pension_plan_name` STRING COMMENT 'Official registered name of the pension plan as filed with regulatory authorities.',
    `next_actuarial_valuation_date` DATE COMMENT 'Scheduled date for the next actuarial valuation of the pension plan.',
    `normal_retirement_age` BIGINT COMMENT 'Standard age at which members can retire with full unreduced benefits under the plan.',
    `plan_administrator_name` STRING COMMENT 'Name of the organization or individual responsible for plan administration.',
    `plan_code` STRING COMMENT 'External business identifier code for the pension plan used in regulatory filings and member communications.',
    `portability_allowed` BOOLEAN COMMENT 'Indicates whether members can transfer accrued benefits to another pension plan.',
    `record_keeper_name` STRING COMMENT 'Name of the service provider maintaining participant records and account balances.',
    `registration_number` STRING COMMENT 'Official registration number assigned by the pension regulatory authority.',
    `salary_averaging_period_years` BIGINT COMMENT 'Number of years used to calculate average salary for benefit determination.',
    `sponsor_type` STRING COMMENT 'Category of employer or organization sponsoring the pension plan.',
    `pension_plan_status` STRING COMMENT 'Current lifecycle status of the pension plan indicating operational state.',
    `survivor_benefit_pct` DECIMAL(5,4) COMMENT 'Percentage of pension benefit payable to surviving spouse or beneficiary.',
    `target_funding_ratio_pct` DECIMAL(5,4) COMMENT 'Target ratio of plan assets to liabilities as defined by funding policy.',
    `termination_date` DATE COMMENT 'Date when the pension plan was or will be terminated. Null for active open-ended plans.',
    `total_active_members` BIGINT COMMENT 'Current count of active contributing members enrolled in the pension plan.',
    `total_deferred_members` BIGINT COMMENT 'Count of members with deferred benefits who are no longer actively contributing.',
    `total_pensioners` BIGINT COMMENT 'Count of retired members currently receiving pension benefit payments.',
    `trustee_name` STRING COMMENT 'Name of the trustee or trust company holding plan assets in fiduciary capacity.',
    `pension_plan_type` STRING COMMENT 'Classification of the pension plan structure determining benefit calculation methodology.',
    `vesting_period_months` BIGINT COMMENT 'Number of months of service required for members to become fully vested in employer contributions.',
    CONSTRAINT pk_pension_plan PRIMARY KEY(`pension_plan_id`)
) COMMENT 'Master reference table for pension_plan. Referenced by plan_id.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `asset_management`.`beneficiary`.`member` ADD CONSTRAINT `fk_beneficiary_member_contributor_pool_id` FOREIGN KEY (`contributor_pool_id`) REFERENCES `asset_management`.`beneficiary`.`contributor_pool`(`contributor_pool_id`);
ALTER TABLE `asset_management`.`beneficiary`.`member` ADD CONSTRAINT `fk_beneficiary_member_pension_plan_id` FOREIGN KEY (`pension_plan_id`) REFERENCES `asset_management`.`beneficiary`.`pension_plan`(`pension_plan_id`);
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ADD CONSTRAINT `fk_beneficiary_member_enrollment_contributor_pool_id` FOREIGN KEY (`contributor_pool_id`) REFERENCES `asset_management`.`beneficiary`.`contributor_pool`(`contributor_pool_id`);
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ADD CONSTRAINT `fk_beneficiary_member_enrollment_member_id` FOREIGN KEY (`member_id`) REFERENCES `asset_management`.`beneficiary`.`member`(`member_id`);
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ADD CONSTRAINT `fk_beneficiary_member_enrollment_pension_plan_id` FOREIGN KEY (`pension_plan_id`) REFERENCES `asset_management`.`beneficiary`.`pension_plan`(`pension_plan_id`);
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ADD CONSTRAINT `fk_beneficiary_contribution_record_contributor_pool_id` FOREIGN KEY (`contributor_pool_id`) REFERENCES `asset_management`.`beneficiary`.`contributor_pool`(`contributor_pool_id`);
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ADD CONSTRAINT `fk_beneficiary_contribution_record_member_id` FOREIGN KEY (`member_id`) REFERENCES `asset_management`.`beneficiary`.`member`(`member_id`);
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ADD CONSTRAINT `fk_beneficiary_contribution_record_pension_plan_id` FOREIGN KEY (`pension_plan_id`) REFERENCES `asset_management`.`beneficiary`.`pension_plan`(`pension_plan_id`);
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ADD CONSTRAINT `fk_beneficiary_pensionable_service_contributor_pool_id` FOREIGN KEY (`contributor_pool_id`) REFERENCES `asset_management`.`beneficiary`.`contributor_pool`(`contributor_pool_id`);
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ADD CONSTRAINT `fk_beneficiary_pensionable_service_member_id` FOREIGN KEY (`member_id`) REFERENCES `asset_management`.`beneficiary`.`member`(`member_id`);
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ADD CONSTRAINT `fk_beneficiary_pensionable_service_pension_plan_id` FOREIGN KEY (`pension_plan_id`) REFERENCES `asset_management`.`beneficiary`.`pension_plan`(`pension_plan_id`);
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ADD CONSTRAINT `fk_beneficiary_entitlement_benefit_option_id` FOREIGN KEY (`benefit_option_id`) REFERENCES `asset_management`.`beneficiary`.`benefit_option`(`benefit_option_id`);
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ADD CONSTRAINT `fk_beneficiary_entitlement_contributor_pool_id` FOREIGN KEY (`contributor_pool_id`) REFERENCES `asset_management`.`beneficiary`.`contributor_pool`(`contributor_pool_id`);
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ADD CONSTRAINT `fk_beneficiary_entitlement_designated_beneficiary_id` FOREIGN KEY (`designated_beneficiary_id`) REFERENCES `asset_management`.`beneficiary`.`designated_beneficiary`(`designated_beneficiary_id`);
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ADD CONSTRAINT `fk_beneficiary_entitlement_entitlement_member_id` FOREIGN KEY (`entitlement_member_id`) REFERENCES `asset_management`.`beneficiary`.`member`(`member_id`);
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ADD CONSTRAINT `fk_beneficiary_entitlement_entitlement_survivor_member_id` FOREIGN KEY (`entitlement_survivor_member_id`) REFERENCES `asset_management`.`beneficiary`.`member`(`member_id`);
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ADD CONSTRAINT `fk_beneficiary_entitlement_pension_plan_id` FOREIGN KEY (`pension_plan_id`) REFERENCES `asset_management`.`beneficiary`.`pension_plan`(`pension_plan_id`);
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ADD CONSTRAINT `fk_beneficiary_benefit_payment_designated_beneficiary_id` FOREIGN KEY (`designated_beneficiary_id`) REFERENCES `asset_management`.`beneficiary`.`designated_beneficiary`(`designated_beneficiary_id`);
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ADD CONSTRAINT `fk_beneficiary_benefit_payment_entitlement_id` FOREIGN KEY (`entitlement_id`) REFERENCES `asset_management`.`beneficiary`.`entitlement`(`entitlement_id`);
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ADD CONSTRAINT `fk_beneficiary_benefit_payment_member_id` FOREIGN KEY (`member_id`) REFERENCES `asset_management`.`beneficiary`.`member`(`member_id`);
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ADD CONSTRAINT `fk_beneficiary_member_lifecycle_event_contributor_pool_id` FOREIGN KEY (`contributor_pool_id`) REFERENCES `asset_management`.`beneficiary`.`contributor_pool`(`contributor_pool_id`);
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ADD CONSTRAINT `fk_beneficiary_member_lifecycle_event_member_id` FOREIGN KEY (`member_id`) REFERENCES `asset_management`.`beneficiary`.`member`(`member_id`);
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ADD CONSTRAINT `fk_beneficiary_member_lifecycle_event_pension_plan_id` FOREIGN KEY (`pension_plan_id`) REFERENCES `asset_management`.`beneficiary`.`pension_plan`(`pension_plan_id`);
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ADD CONSTRAINT `fk_beneficiary_designated_beneficiary_member_id` FOREIGN KEY (`member_id`) REFERENCES `asset_management`.`beneficiary`.`member`(`member_id`);
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ADD CONSTRAINT `fk_beneficiary_member_address_member_id` FOREIGN KEY (`member_id`) REFERENCES `asset_management`.`beneficiary`.`member`(`member_id`);
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ADD CONSTRAINT `fk_beneficiary_member_contact_member_id` FOREIGN KEY (`member_id`) REFERENCES `asset_management`.`beneficiary`.`member`(`member_id`);
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ADD CONSTRAINT `fk_beneficiary_contribution_rate_contributor_pool_id` FOREIGN KEY (`contributor_pool_id`) REFERENCES `asset_management`.`beneficiary`.`contributor_pool`(`contributor_pool_id`);
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ADD CONSTRAINT `fk_beneficiary_service_buyback_contributor_pool_id` FOREIGN KEY (`contributor_pool_id`) REFERENCES `asset_management`.`beneficiary`.`contributor_pool`(`contributor_pool_id`);
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ADD CONSTRAINT `fk_beneficiary_service_buyback_member_id` FOREIGN KEY (`member_id`) REFERENCES `asset_management`.`beneficiary`.`member`(`member_id`);
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ADD CONSTRAINT `fk_beneficiary_service_buyback_pension_plan_id` FOREIGN KEY (`pension_plan_id`) REFERENCES `asset_management`.`beneficiary`.`pension_plan`(`pension_plan_id`);
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ADD CONSTRAINT `fk_beneficiary_transfer_in_designated_beneficiary_id` FOREIGN KEY (`designated_beneficiary_id`) REFERENCES `asset_management`.`beneficiary`.`designated_beneficiary`(`designated_beneficiary_id`);
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ADD CONSTRAINT `fk_beneficiary_transfer_in_contributor_pool_id` FOREIGN KEY (`contributor_pool_id`) REFERENCES `asset_management`.`beneficiary`.`contributor_pool`(`contributor_pool_id`);
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ADD CONSTRAINT `fk_beneficiary_transfer_in_member_id` FOREIGN KEY (`member_id`) REFERENCES `asset_management`.`beneficiary`.`member`(`member_id`);
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ADD CONSTRAINT `fk_beneficiary_transfer_in_pension_plan_id` FOREIGN KEY (`pension_plan_id`) REFERENCES `asset_management`.`beneficiary`.`pension_plan`(`pension_plan_id`);
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ADD CONSTRAINT `fk_beneficiary_transfer_out_contributor_pool_id` FOREIGN KEY (`contributor_pool_id`) REFERENCES `asset_management`.`beneficiary`.`contributor_pool`(`contributor_pool_id`);
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ADD CONSTRAINT `fk_beneficiary_transfer_out_member_id` FOREIGN KEY (`member_id`) REFERENCES `asset_management`.`beneficiary`.`member`(`member_id`);
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ADD CONSTRAINT `fk_beneficiary_transfer_out_pension_plan_id` FOREIGN KEY (`pension_plan_id`) REFERENCES `asset_management`.`beneficiary`.`pension_plan`(`pension_plan_id`);
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ADD CONSTRAINT `fk_beneficiary_retirement_election_beneficiary_id` FOREIGN KEY (`beneficiary_id`) REFERENCES `asset_management`.`beneficiary`.`designated_beneficiary`(`designated_beneficiary_id`);
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ADD CONSTRAINT `fk_beneficiary_retirement_election_benefit_option_id` FOREIGN KEY (`benefit_option_id`) REFERENCES `asset_management`.`beneficiary`.`benefit_option`(`benefit_option_id`);
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ADD CONSTRAINT `fk_beneficiary_retirement_election_contributor_pool_id` FOREIGN KEY (`contributor_pool_id`) REFERENCES `asset_management`.`beneficiary`.`contributor_pool`(`contributor_pool_id`);
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ADD CONSTRAINT `fk_beneficiary_retirement_election_designated_beneficiary_id` FOREIGN KEY (`designated_beneficiary_id`) REFERENCES `asset_management`.`beneficiary`.`designated_beneficiary`(`designated_beneficiary_id`);
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ADD CONSTRAINT `fk_beneficiary_retirement_election_member_id` FOREIGN KEY (`member_id`) REFERENCES `asset_management`.`beneficiary`.`member`(`member_id`);
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ADD CONSTRAINT `fk_beneficiary_retirement_election_pension_plan_id` FOREIGN KEY (`pension_plan_id`) REFERENCES `asset_management`.`beneficiary`.`pension_plan`(`pension_plan_id`);
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ADD CONSTRAINT `fk_beneficiary_retirement_election_survivor_designated_beneficiary_id` FOREIGN KEY (`survivor_designated_beneficiary_id`) REFERENCES `asset_management`.`beneficiary`.`designated_beneficiary`(`designated_beneficiary_id`);
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ADD CONSTRAINT `fk_beneficiary_indexation_adjustment_designated_beneficiary_id` FOREIGN KEY (`designated_beneficiary_id`) REFERENCES `asset_management`.`beneficiary`.`designated_beneficiary`(`designated_beneficiary_id`);
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ADD CONSTRAINT `fk_beneficiary_indexation_adjustment_benefit_payment_id` FOREIGN KEY (`benefit_payment_id`) REFERENCES `asset_management`.`beneficiary`.`benefit_payment`(`benefit_payment_id`);
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ADD CONSTRAINT `fk_beneficiary_indexation_adjustment_member_id` FOREIGN KEY (`member_id`) REFERENCES `asset_management`.`beneficiary`.`member`(`member_id`);
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ADD CONSTRAINT `fk_beneficiary_indexation_adjustment_pension_plan_id` FOREIGN KEY (`pension_plan_id`) REFERENCES `asset_management`.`beneficiary`.`pension_plan`(`pension_plan_id`);
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ADD CONSTRAINT `fk_beneficiary_survivor_benefit_contributor_pool_id` FOREIGN KEY (`contributor_pool_id`) REFERENCES `asset_management`.`beneficiary`.`contributor_pool`(`contributor_pool_id`);
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ADD CONSTRAINT `fk_beneficiary_survivor_benefit_designated_beneficiary_id` FOREIGN KEY (`designated_beneficiary_id`) REFERENCES `asset_management`.`beneficiary`.`designated_beneficiary`(`designated_beneficiary_id`);
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ADD CONSTRAINT `fk_beneficiary_survivor_benefit_member_id` FOREIGN KEY (`member_id`) REFERENCES `asset_management`.`beneficiary`.`member`(`member_id`);
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ADD CONSTRAINT `fk_beneficiary_survivor_benefit_pension_plan_id` FOREIGN KEY (`pension_plan_id`) REFERENCES `asset_management`.`beneficiary`.`pension_plan`(`pension_plan_id`);
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ADD CONSTRAINT `fk_beneficiary_survivor_benefit_survivor_designated_beneficiary_id` FOREIGN KEY (`survivor_designated_beneficiary_id`) REFERENCES `asset_management`.`beneficiary`.`designated_beneficiary`(`designated_beneficiary_id`);
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ADD CONSTRAINT `fk_beneficiary_member_statement_contributor_pool_id` FOREIGN KEY (`contributor_pool_id`) REFERENCES `asset_management`.`beneficiary`.`contributor_pool`(`contributor_pool_id`);
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ADD CONSTRAINT `fk_beneficiary_member_statement_member_id` FOREIGN KEY (`member_id`) REFERENCES `asset_management`.`beneficiary`.`member`(`member_id`);
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ADD CONSTRAINT `fk_beneficiary_member_statement_pension_plan_id` FOREIGN KEY (`pension_plan_id`) REFERENCES `asset_management`.`beneficiary`.`pension_plan`(`pension_plan_id`);
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ADD CONSTRAINT `fk_beneficiary_employer_remittance_contributor_pool_id` FOREIGN KEY (`contributor_pool_id`) REFERENCES `asset_management`.`beneficiary`.`contributor_pool`(`contributor_pool_id`);
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ADD CONSTRAINT `fk_beneficiary_employer_remittance_participating_employer_id` FOREIGN KEY (`participating_employer_id`) REFERENCES `asset_management`.`beneficiary`.`participating_employer`(`participating_employer_id`);
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ADD CONSTRAINT `fk_beneficiary_employer_remittance_pension_plan_id` FOREIGN KEY (`pension_plan_id`) REFERENCES `asset_management`.`beneficiary`.`pension_plan`(`pension_plan_id`);
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ADD CONSTRAINT `fk_beneficiary_employer_remittance_reversal_reference_employer_remittance_id` FOREIGN KEY (`reversal_reference_employer_remittance_id`) REFERENCES `asset_management`.`beneficiary`.`employer_remittance`(`employer_remittance_id`);
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ADD CONSTRAINT `fk_beneficiary_participating_employer_contributor_pool_id` FOREIGN KEY (`contributor_pool_id`) REFERENCES `asset_management`.`beneficiary`.`contributor_pool`(`contributor_pool_id`);
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ADD CONSTRAINT `fk_beneficiary_benefit_option_contributor_pool_id` FOREIGN KEY (`contributor_pool_id`) REFERENCES `asset_management`.`beneficiary`.`contributor_pool`(`contributor_pool_id`);
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ADD CONSTRAINT `fk_beneficiary_overpayment_recovery_designated_beneficiary_id` FOREIGN KEY (`designated_beneficiary_id`) REFERENCES `asset_management`.`beneficiary`.`designated_beneficiary`(`designated_beneficiary_id`);
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ADD CONSTRAINT `fk_beneficiary_overpayment_recovery_benefit_payment_id` FOREIGN KEY (`benefit_payment_id`) REFERENCES `asset_management`.`beneficiary`.`benefit_payment`(`benefit_payment_id`);
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ADD CONSTRAINT `fk_beneficiary_overpayment_recovery_contributor_pool_id` FOREIGN KEY (`contributor_pool_id`) REFERENCES `asset_management`.`beneficiary`.`contributor_pool`(`contributor_pool_id`);
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ADD CONSTRAINT `fk_beneficiary_overpayment_recovery_member_id` FOREIGN KEY (`member_id`) REFERENCES `asset_management`.`beneficiary`.`member`(`member_id`);
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ADD CONSTRAINT `fk_beneficiary_member_document_member_id` FOREIGN KEY (`member_id`) REFERENCES `asset_management`.`beneficiary`.`member`(`member_id`);
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ADD CONSTRAINT `fk_beneficiary_member_document_pension_plan_id` FOREIGN KEY (`pension_plan_id`) REFERENCES `asset_management`.`beneficiary`.`pension_plan`(`pension_plan_id`);
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ADD CONSTRAINT `fk_beneficiary_member_document_superseded_by_document_id` FOREIGN KEY (`superseded_by_document_id`) REFERENCES `asset_management`.`beneficiary`.`member_document`(`member_document_id`);
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ADD CONSTRAINT `fk_beneficiary_pension_division_order_designated_beneficiary_id` FOREIGN KEY (`designated_beneficiary_id`) REFERENCES `asset_management`.`beneficiary`.`designated_beneficiary`(`designated_beneficiary_id`);
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ADD CONSTRAINT `fk_beneficiary_pension_division_order_contributor_pool_id` FOREIGN KEY (`contributor_pool_id`) REFERENCES `asset_management`.`beneficiary`.`contributor_pool`(`contributor_pool_id`);
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ADD CONSTRAINT `fk_beneficiary_pension_division_order_member_id` FOREIGN KEY (`member_id`) REFERENCES `asset_management`.`beneficiary`.`member`(`member_id`);
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ADD CONSTRAINT `fk_beneficiary_pension_division_order_pension_plan_id` FOREIGN KEY (`pension_plan_id`) REFERENCES `asset_management`.`beneficiary`.`pension_plan`(`pension_plan_id`);

-- ========= TAGS =========
ALTER TABLE `asset_management`.`beneficiary`.`member` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`beneficiary`.`member` SET TAGS ('dbx_domain' = 'beneficiary');
ALTER TABLE `asset_management`.`beneficiary`.`member` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`beneficiary`.`member` SET TAGS ('dbx_subdomain' = 'member_administration');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `member_id` SET TAGS ('dbx_business_glossary_term' = 'Member ID (MEMBER_ID)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `member_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `member_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `actor_id` SET TAGS ('dbx_business_glossary_term' = 'Actor Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `contributor_pool_id` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Created By User ID (CREATED_BY_USER_ID)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `membership_status_updated_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Membership Status Updated By User ID (MEM_STATUS_UPD_BY_USER_ID)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `membership_status_updated_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `membership_status_updated_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `pension_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Plan ID (PLAN_ID)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `updated_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Updated By User ID (UPDATED_BY_USER_ID)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `updated_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `updated_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `address_line_1` SET TAGS ('dbx_business_glossary_term' = 'Address Line 1 (ADDR_LINE1)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `address_line_1` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `address_line_1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `address_line_2` SET TAGS ('dbx_business_glossary_term' = 'Address Line 2 (ADDR_LINE2)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `address_line_2` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `address_line_2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `city` SET TAGS ('dbx_business_glossary_term' = 'City (CITY)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `city` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code (COUNTRY_CODE)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `country_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `country_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `created_by_user_department` SET TAGS ('dbx_business_glossary_term' = 'Created By User Department (CREATED_BY_USER_DEPT)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `created_by_user_department` SET TAGS ('dbx_value_regex' = 'HR|Finance|Operations|Compliance');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `created_by_user_email` SET TAGS ('dbx_business_glossary_term' = 'Created By User Email (CREATED_BY_USER_EMAIL)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `created_by_user_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `created_by_user_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `created_by_user_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `created_by_user_location` SET TAGS ('dbx_business_glossary_term' = 'Created By User Location (CREATED_BY_USER_LOC)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `created_by_user_location` SET TAGS ('dbx_value_regex' = 'HQ|Branch|Remote');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `created_by_user_name` SET TAGS ('dbx_business_glossary_term' = 'Created By User Name (CREATED_BY_USER_NAME)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `created_by_user_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `created_by_user_name` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `created_by_user_role` SET TAGS ('dbx_business_glossary_term' = 'Created By User Role (CREATED_BY_USER_ROLE)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `created_by_user_role` SET TAGS ('dbx_value_regex' = 'admin|user|auditor');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp (CREATED_TS)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_business_glossary_term' = 'Date of Birth (DOB)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_pii_dob' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `email` SET TAGS ('dbx_business_glossary_term' = 'Email Address (EML)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `full_name` SET TAGS ('dbx_business_glossary_term' = 'Full Legal Name (NAME)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `full_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `full_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `gender` SET TAGS ('dbx_business_glossary_term' = 'Gender (GENDER)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `gender` SET TAGS ('dbx_value_regex' = 'male|female|non_binary|other');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `gender` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `gender` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `membership_end_date` SET TAGS ('dbx_business_glossary_term' = 'Membership End Date (MEM_END_DATE)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `membership_start_date` SET TAGS ('dbx_business_glossary_term' = 'Membership Start Date (MEM_START_DATE)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `membership_status` SET TAGS ('dbx_business_glossary_term' = 'Membership Status (MEM_STATUS)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `membership_status` SET TAGS ('dbx_value_regex' = 'active|inactive|terminated|pending');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `membership_status_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Membership Status Effective Date (MEM_STATUS_EFF_DATE)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `membership_status_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Membership Status Expiry Date (MEM_STATUS_EXP_DATE)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `membership_status_reason` SET TAGS ('dbx_business_glossary_term' = 'Membership Status Reason (MEM_STATUS_REASON)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `membership_status_updated_by_user_department` SET TAGS ('dbx_business_glossary_term' = 'Membership Status Updated By User Department (MEM_STATUS_UPD_BY_USER_DEPT)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `membership_status_updated_by_user_department` SET TAGS ('dbx_value_regex' = 'HR|Finance|Operations|Compliance');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `membership_status_updated_by_user_email` SET TAGS ('dbx_business_glossary_term' = 'Membership Status Updated By User Email (MEM_STATUS_UPD_BY_USER_EMAIL)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `membership_status_updated_by_user_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `membership_status_updated_by_user_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `membership_status_updated_by_user_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `membership_status_updated_by_user_location` SET TAGS ('dbx_business_glossary_term' = 'Membership Status Updated By User Location (MEM_STATUS_UPD_BY_USER_LOC)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `membership_status_updated_by_user_location` SET TAGS ('dbx_value_regex' = 'HQ|Branch|Remote');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `membership_status_updated_by_user_name` SET TAGS ('dbx_business_glossary_term' = 'Membership Status Updated By User Name (MEM_STATUS_UPD_BY_USER_NAME)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `membership_status_updated_by_user_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `membership_status_updated_by_user_name` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `membership_status_updated_by_user_role` SET TAGS ('dbx_business_glossary_term' = 'Membership Status Updated By User Role (MEM_STATUS_UPD_BY_USER_ROLE)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `membership_status_updated_by_user_role` SET TAGS ('dbx_value_regex' = 'admin|user|auditor');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `membership_status_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Membership Status Updated Timestamp (MEM_STATUS_UPD_TS)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `national_identifier` SET TAGS ('dbx_business_glossary_term' = 'National Identification Number (NIN)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `national_identifier` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{5,20}$');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `national_identifier` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `national_identifier` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Member Number (MEMBER_NO)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `phone_number` SET TAGS ('dbx_business_glossary_term' = 'Phone Number (PHN)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `phone_number` SET TAGS ('dbx_value_regex' = '^+?[0-9]{7,15}$');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `phone_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `phone_number` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `plan_status` SET TAGS ('dbx_business_glossary_term' = 'Plan Status (PLAN_STATUS)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `plan_status` SET TAGS ('dbx_value_regex' = 'active|suspended|terminated|pending');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `plan_type` SET TAGS ('dbx_business_glossary_term' = 'Plan Type (PLAN_TYPE)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `plan_type` SET TAGS ('dbx_value_regex' = 'public_equities|private_equity|real_estate|infrastructure|natural_resources|credit');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `postal_code` SET TAGS ('dbx_business_glossary_term' = 'Postal Code (POSTAL_CODE)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `postal_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{3,10}$');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `postal_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `province_state` SET TAGS ('dbx_business_glossary_term' = 'Province/State (PROV_STATE)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `province_state` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `province_state` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `updated_by_user_department` SET TAGS ('dbx_business_glossary_term' = 'Updated By User Department (UPDATED_BY_USER_DEPT)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `updated_by_user_department` SET TAGS ('dbx_value_regex' = 'HR|Finance|Operations|Compliance');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `updated_by_user_email` SET TAGS ('dbx_business_glossary_term' = 'Updated By User Email (UPDATED_BY_USER_EMAIL)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `updated_by_user_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `updated_by_user_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `updated_by_user_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `updated_by_user_location` SET TAGS ('dbx_business_glossary_term' = 'Updated By User Location (UPDATED_BY_USER_LOC)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `updated_by_user_location` SET TAGS ('dbx_value_regex' = 'HQ|Branch|Remote');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `updated_by_user_name` SET TAGS ('dbx_business_glossary_term' = 'Updated By User Name (UPDATED_BY_USER_NAME)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `updated_by_user_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `updated_by_user_name` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `updated_by_user_role` SET TAGS ('dbx_business_glossary_term' = 'Updated By User Role (UPDATED_BY_USER_ROLE)');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `updated_by_user_role` SET TAGS ('dbx_value_regex' = 'admin|user|auditor');
ALTER TABLE `asset_management`.`beneficiary`.`member` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp (UPDATED_TS)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` SET TAGS ('dbx_domain' = 'beneficiary');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` SET TAGS ('dbx_subdomain' = 'member_administration');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `contributor_pool_id` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool ID (CP_ID)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `actuarial_assumptions` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Actuarial Assumptions (CP_ACTUARIAL_ASSUMPTIONS)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Approval Date (CP_APPROVAL_DATE)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Approved By (CP_APPROVED_BY)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `benefit_formula` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Benefit Formula (CP_BENEFIT_FORMULA)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `contributor_pool_code` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Code (CP_CODE)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `contributor_pool_code` SET TAGS ('dbx_value_regex' = 'CP[0-9]{4}');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `contribution_frequency` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Contribution Frequency (CP_CONTRIBUTION_FREQUENCY)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `contribution_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|annual');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `contribution_rate` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Contribution Rate (CP_CONTRIBUTION_RATE)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `contribution_rate_structure` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Contribution Rate Structure (CP_CONTRIBUTION_RATE_STRUCTURE)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `contributor_pool_status` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Status (CP_STATUS)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `contributor_pool_status` SET TAGS ('dbx_value_regex' = 'active|inactive|terminated|pending');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `contributor_pool_type` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Type (CP_TYPE)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `contributor_pool_type` SET TAGS ('dbx_value_regex' = 'plan_1|plan_2|plan_3|plan_4');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Created Timestamp (CP_CREATED_TIMESTAMP)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Currency Code (CP_CURRENCY_CODE)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `contributor_pool_description` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Description (CP_DESCRIPTION)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Effective From Date (CP_EFFECTIVE_FROM)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Effective Until Date (CP_EFFECTIVE_UNTIL)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `employment_category` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Employment Category (CP_EMPLOYMENT_CATEGORY)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `gazette_reference` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Gazette Reference (CP_GAZETTE_REFERENCE)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `indexation_basis` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Indexation Basis (CP_INDEXATION_BASIS)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `indexation_rate` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Indexation Rate (CP_INDEXATION_RATE)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `is_mandatory` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Is Mandatory (CP_IS_MANDATORY)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `is_tax_deductible` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Is Tax Deductible (CP_IS_TAX_DEDUCTIBLE)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `jurisdiction_code` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Jurisdiction Code (CP_JURISDICTION_CODE)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `jurisdiction_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Last Updated Timestamp (CP_LAST_UPDATED_TIMESTAMP)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `legislative_authority` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Legislative Authority (CP_LEGISLATIVE_AUTHORITY)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `legislative_framework` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Legislative Framework (CP_LEGISLATIVE_FRAMEWORK)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `max_pensionable_earnings` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Max Pensionable Earnings (CP_MAX_PENSIONABLE_EARNINGS)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `min_pensionable_earnings` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Min Pensionable Earnings (CP_MIN_PENSIONABLE_EARNINGS)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `contributor_pool_name` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Name (CP_NAME)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Notes (CP_NOTES)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `plan_type` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Plan Type (CP_PLAN_TYPE)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `rate_description` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Rate Description (CP_RATE_DESCRIPTION)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `regulatory_basis` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Regulatory Basis (CP_REGULATORY_BASIS)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `service_category` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Service Category (CP_SERVICE_CATEGORY)');
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Version Number (CP_VERSION_NUMBER)');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` SET TAGS ('dbx_domain' = 'beneficiary');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` SET TAGS ('dbx_subdomain' = 'member_administration');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `member_enrollment_id` SET TAGS ('dbx_business_glossary_term' = 'Member Enrollment ID (MEMBER_ENROLLMENT_ID)');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `contributor_pool_id` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `member_id` SET TAGS ('dbx_business_glossary_term' = 'Member ID (MEMBER_ID)');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `member_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `member_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `pension_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Plan ID (PLAN_ID)');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp (CREATED_TIMESTAMP)');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `eligibility_verification_outcome` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Verification Outcome (ELIGIBILITY_VERIFICATION_OUTCOME)');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `eligibility_verification_outcome` SET TAGS ('dbx_value_regex' = 'verified|unverified|pending');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `enrollment_date` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Date (ENROLLMENT_DATE)');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `enrollment_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Fee Amount (ENROLLMENT_FEE_AMOUNT)');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `enrollment_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Reference Number (ENROLLMENT_REFERENCE_NUMBER)');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `enrollment_source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Source System Code (ENROLLMENT_SOURCE_SYSTEM_CODE)');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `enrollment_source_system_device` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Source System Device (ENROLLMENT_SOURCE_SYSTEM_DEVICE)');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `enrollment_source_system_device` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `enrollment_source_system_device` SET TAGS ('dbx_pii_device' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `enrollment_source_system_ip` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Source System IP Address (ENROLLMENT_SOURCE_SYSTEM_IP)');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `enrollment_source_system_ip` SET TAGS ('dbx_value_regex' = '^(?:[0-9]{1,3}.){3}[0-9]{1,3}$');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `enrollment_source_system_ip` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `enrollment_source_system_ip` SET TAGS ('dbx_pii_ip' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `enrollment_source_system_location` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Source System Location (ENROLLMENT_SOURCE_SYSTEM_LOCATION)');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `enrollment_source_system_name` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Source System Name (ENROLLMENT_SOURCE_SYSTEM_NAME)');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `enrollment_source_system_reference_code` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Source System Reference ID (ENROLLMENT_SOURCE_SYSTEM_REFERENCE_ID)');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `enrollment_source_system_reference_date` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Source System Reference Date (ENROLLMENT_SOURCE_SYSTEM_REFERENCE_DATE)');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `enrollment_source_system_reference_description` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Source System Reference Description (ENROLLMENT_SOURCE_SYSTEM_REFERENCE_DESCRIPTION)');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `enrollment_source_system_reference_status` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Source System Reference Status (ENROLLMENT_SOURCE_SYSTEM_REFERENCE_STATUS)');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `enrollment_source_system_reference_type` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Source System Reference Type (ENROLLMENT_SOURCE_SYSTEM_REFERENCE_TYPE)');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `enrollment_source_system_reference_value` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Source System Reference Value (ENROLLMENT_SOURCE_SYSTEM_REFERENCE_VALUE)');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `enrollment_source_system_user` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Source System User (ENROLLMENT_SOURCE_SYSTEM_USER)');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `enrollment_source_system_version` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Source System Version (ENROLLMENT_SOURCE_SYSTEM_VERSION)');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `enrollment_status` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Status (ENROLLMENT_STATUS)');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `enrollment_status` SET TAGS ('dbx_value_regex' = 'draft|pending|completed|cancelled');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `enrollment_type` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Type (ENROLLMENT_TYPE)');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `enrollment_type` SET TAGS ('dbx_value_regex' = 'new_hire|transfer_in|re_enrollment');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `fee_currency` SET TAGS ('dbx_business_glossary_term' = 'Fee Currency (FEE_CURRENCY)');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `fee_currency` SET TAGS ('dbx_value_regex' = 'USD|EUR|GBP|JPY|CAD|AUD');
ALTER TABLE `asset_management`.`beneficiary`.`member_enrollment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp (UPDATED_TIMESTAMP)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` SET TAGS ('dbx_domain' = 'beneficiary');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` SET TAGS ('dbx_subdomain' = 'contribution_management');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contribution_record_id` SET TAGS ('dbx_business_glossary_term' = 'Contribution Record ID (CRID)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contributor_pool_id` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool ID (CPID)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `member_id` SET TAGS ('dbx_business_glossary_term' = 'Member ID (MID)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `member_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `member_id` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `net_contribution_inflow_id` SET TAGS ('dbx_business_glossary_term' = 'Contribution Inflow Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `pension_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Plan ID (PID)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Contribution Approval Date (CAPP_DATE)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Contribution Approved By (CAPP_BY)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contribution_approval_status` SET TAGS ('dbx_business_glossary_term' = 'Contribution Approval Status (CAPP_STAT)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contribution_approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected|cancelled');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contribution_batch_code` SET TAGS ('dbx_business_glossary_term' = 'Contribution Batch ID (CBATCH_ID)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contribution_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Contribution Created Timestamp (CCREATED_TS)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contribution_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Contribution Currency Code (CCY)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contribution_date` SET TAGS ('dbx_business_glossary_term' = 'Contribution Date (CDATE)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contribution_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Contribution Fee Amount (CFEES)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contribution_fee_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Contribution Fee Currency Code (CFEES_CCY)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contribution_fee_rate` SET TAGS ('dbx_business_glossary_term' = 'Contribution Fee Rate (CFEES_RATE)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contribution_fee_type` SET TAGS ('dbx_business_glossary_term' = 'Contribution Fee Type (CFEES_TYPE)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contribution_fee_type` SET TAGS ('dbx_value_regex' = 'service_fee|processing_fee|administrative_fee');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contribution_frequency` SET TAGS ('dbx_business_glossary_term' = 'Contribution Frequency (CFREQ)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contribution_frequency` SET TAGS ('dbx_value_regex' = 'weekly|biweekly|monthly|quarterly|annual');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contribution_method` SET TAGS ('dbx_business_glossary_term' = 'Contribution Method (CMETHOD)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contribution_method` SET TAGS ('dbx_value_regex' = 'payroll|direct_deposit|manual|wire_transfer');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contribution_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Contribution Period End Date (CPED)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contribution_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Contribution Period Start Date (CPSD)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contribution_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Contribution Reference Number (CRN)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contribution_source` SET TAGS ('dbx_business_glossary_term' = 'Contribution Source (CSRC)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contribution_source` SET TAGS ('dbx_value_regex' = 'payroll_system|bank_transfer|manual_entry|third_party');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contribution_source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Contribution Source System Code (CSYS_CODE)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contribution_source_system_name` SET TAGS ('dbx_business_glossary_term' = 'Contribution Source System Name (CSYS_NAME)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contribution_source_system_reference_code` SET TAGS ('dbx_business_glossary_term' = 'Contribution Source System Reference ID (CSYS_REF_ID)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contribution_source_system_user` SET TAGS ('dbx_business_glossary_term' = 'Contribution Source System User (CSYS_USER)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contribution_source_system_version` SET TAGS ('dbx_business_glossary_term' = 'Contribution Source System Version (CSYS_VER)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contribution_status` SET TAGS ('dbx_business_glossary_term' = 'Contribution Status (CSTAT)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contribution_status` SET TAGS ('dbx_value_regex' = 'pending|posted|reversed|cancelled|failed');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contribution_tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Contribution Tax Amount (CTAX)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contribution_tax_code` SET TAGS ('dbx_business_glossary_term' = 'Contribution Tax Code (CTAX_CODE)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contribution_tax_rate` SET TAGS ('dbx_business_glossary_term' = 'Contribution Tax Rate (CTAX_RATE)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contribution_type` SET TAGS ('dbx_business_glossary_term' = 'Contribution Type (CTYPE)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contribution_type` SET TAGS ('dbx_value_regex' = 'regular|catch-up|voluntary|employer_match');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `contribution_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Contribution Updated Timestamp (CUPDATED_TS)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `employee_contribution_amount` SET TAGS ('dbx_business_glossary_term' = 'Employee Contribution Amount (ECA)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `employer_contribution_amount` SET TAGS ('dbx_business_glossary_term' = 'Employer Contribution Amount (ECA)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ALTER COLUMN `total_contribution_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Contribution Amount (TCA)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` SET TAGS ('dbx_domain' = 'beneficiary');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` SET TAGS ('dbx_subdomain' = 'contribution_management');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `pensionable_service_id` SET TAGS ('dbx_business_glossary_term' = 'Pensionable Service ID (PSID)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `contributor_pool_id` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `indexation_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Plan Identifier (PLAN_ID)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `member_id` SET TAGS ('dbx_business_glossary_term' = 'Member Identifier (MEM_ID)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `member_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `member_id` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `pension_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Plan Identifier (PLAN_ID)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `cumulative_service_months` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Service Months (CSM)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `cumulative_service_years` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Service Years (CSY)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `period_service_months` SET TAGS ('dbx_business_glossary_term' = 'Period Service Months (PSM)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `period_service_years` SET TAGS ('dbx_business_glossary_term' = 'Period Service Years (PSY)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_credits_approval_by` SET TAGS ('dbx_business_glossary_term' = 'Service Credits Approval By (SCAB)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_credits_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Service Credits Approval Date (SCAD)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_credits_contributor_pool_code` SET TAGS ('dbx_business_glossary_term' = 'Service Credits Contributor Pool Code (SCCPC)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_credits_created_by_user` SET TAGS ('dbx_business_glossary_term' = 'Service Credits Created By User (SCCBU)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_credits_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Service Credits Created Timestamp (SCCT)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_credits_effective_from` SET TAGS ('dbx_business_glossary_term' = 'Service Credits Effective From (SCEF)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_credits_effective_until` SET TAGS ('dbx_business_glossary_term' = 'Service Credits Effective Until (SCEU)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_credits_lifetime_status` SET TAGS ('dbx_business_glossary_term' = 'Service Credits Lifetime Status (SCLS)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_credits_months` SET TAGS ('dbx_business_glossary_term' = 'Service Credits Months (SCM)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_credits_notes` SET TAGS ('dbx_business_glossary_term' = 'Service Credits Notes (SCN)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_credits_plan_type` SET TAGS ('dbx_business_glossary_term' = 'Service Credits Plan Type (SCPT)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_credits_reason` SET TAGS ('dbx_business_glossary_term' = 'Service Credits Reason (SCR)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_credits_source_system` SET TAGS ('dbx_business_glossary_term' = 'Service Credits Source System (SCSS)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_credits_source_system_device` SET TAGS ('dbx_business_glossary_term' = 'Service Credits Source System Device (SCSSD)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_credits_source_system_ip` SET TAGS ('dbx_business_glossary_term' = 'Service Credits Source System IP (SCSSIP)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_credits_source_system_location` SET TAGS ('dbx_business_glossary_term' = 'Service Credits Source System Location (SCSSL)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_credits_source_system_name` SET TAGS ('dbx_business_glossary_term' = 'Service Credits Source System Name (SCSSN)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_credits_source_system_reference` SET TAGS ('dbx_business_glossary_term' = 'Service Credits Source System Reference Description (SCSSRD)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_credits_source_system_reference_code` SET TAGS ('dbx_business_glossary_term' = 'Service Credits Source System Reference ID (SCSSRID)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_credits_source_system_reference_date` SET TAGS ('dbx_business_glossary_term' = 'Service Credits Source System Reference Date (SCSSRD)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_credits_source_system_reference_status` SET TAGS ('dbx_business_glossary_term' = 'Service Credits Source System Reference Status (SCSSRS)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_credits_source_system_reference_type` SET TAGS ('dbx_business_glossary_term' = 'Service Credits Source System Reference Type (SCSSRT)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_credits_source_system_reference_value` SET TAGS ('dbx_business_glossary_term' = 'Service Credits Source System Reference Value (SCSSRV)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_credits_source_system_user` SET TAGS ('dbx_business_glossary_term' = 'Service Credits Source System User (SCSSU)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_credits_source_system_version` SET TAGS ('dbx_business_glossary_term' = 'Service Credits Source System Version (SCSSV)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_credits_status` SET TAGS ('dbx_business_glossary_term' = 'Service Credits Status (SCS)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_credits_status` SET TAGS ('dbx_value_regex' = 'active|inactive|terminated|pending');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_credits_updated_by_user` SET TAGS ('dbx_business_glossary_term' = 'Service Credits Updated By User (SCUBU)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_credits_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Service Credits Updated Timestamp (SCUT)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_credits_years` SET TAGS ('dbx_business_glossary_term' = 'Service Credits Years (SCY)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_end_date` SET TAGS ('dbx_business_glossary_term' = 'Service End Date (SEDATE)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_start_date` SET TAGS ('dbx_business_glossary_term' = 'Service Start Date (SSDATE)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_status` SET TAGS ('dbx_business_glossary_term' = 'Service Status (SSTATUS)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_status` SET TAGS ('dbx_value_regex' = 'active|inactive|terminated|pending');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_type` SET TAGS ('dbx_business_glossary_term' = 'Service Type (STYPE)');
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ALTER COLUMN `service_type` SET TAGS ('dbx_value_regex' = 'regular|buyback|transferred_in|military_service_credit');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` SET TAGS ('dbx_domain' = 'beneficiary');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` SET TAGS ('dbx_subdomain' = 'benefit_disbursement');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `entitlement_id` SET TAGS ('dbx_business_glossary_term' = 'Entitlement ID (ENT_ID)');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `benefit_option_id` SET TAGS ('dbx_business_glossary_term' = 'Benefit Option Identifier (BEN_OPT_ID)');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `contributor_pool_id` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Identifier (CP_ID)');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `designated_beneficiary_id` SET TAGS ('dbx_business_glossary_term' = 'Survivor Identifier (SURV_ID)');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `designated_beneficiary_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `designated_beneficiary_id` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `entitlement_member_id` SET TAGS ('dbx_business_glossary_term' = 'Member Identifier (MEM_ID)');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `entitlement_member_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `entitlement_member_id` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `entitlement_survivor_member_id` SET TAGS ('dbx_business_glossary_term' = 'Survivor Identifier (SURV_ID)');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `entitlement_survivor_member_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `entitlement_survivor_member_id` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `pension_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Plan Identifier (PLAN_ID)');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `actuarial_basis` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Basis (ACTUARIAL_BASIS)');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `benefit_amount` SET TAGS ('dbx_business_glossary_term' = 'Benefit Amount (BEN_AMT)');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `benefit_currency` SET TAGS ('dbx_business_glossary_term' = 'Benefit Currency (BEN_CURR)');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `benefit_currency` SET TAGS ('dbx_value_regex' = 'USD|EUR|GBP|JPY|CAD|AUD');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `benefit_end_date` SET TAGS ('dbx_business_glossary_term' = 'Benefit End Date (BEN_END)');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `benefit_frequency` SET TAGS ('dbx_business_glossary_term' = 'Benefit Frequency (BEN_FREQ)');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `benefit_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|annually|lump_sum');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `benefit_start_date` SET TAGS ('dbx_business_glossary_term' = 'Benefit Start Date (BEN_START)');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `calculation_method_code` SET TAGS ('dbx_business_glossary_term' = 'Calculation Method Code (CALC_CODE)');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `calculation_method_code` SET TAGS ('dbx_value_regex' = 'actuarial|statistical|market_based');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp (CREATED_TS)');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Effective From Date (EFF_FROM)');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Effective Until Date (EFF_UNTIL)');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `entitlement_status` SET TAGS ('dbx_business_glossary_term' = 'Entitlement Status (ENT_STATUS)');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `entitlement_status` SET TAGS ('dbx_value_regex' = 'active|terminated|pending|canceled');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `entitlement_type` SET TAGS ('dbx_business_glossary_term' = 'Entitlement Type (ENT_TYPE)');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `entitlement_type` SET TAGS ('dbx_value_regex' = 'retirement|death|termination|early_retirement');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `guarantee_period_months` SET TAGS ('dbx_business_glossary_term' = 'Guarantee Period (Months) (GUARANTEE_PERIOD)');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `indexation_rate` SET TAGS ('dbx_business_glossary_term' = 'Indexation Rate (IDX_RATE)');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `indexation_type` SET TAGS ('dbx_business_glossary_term' = 'Indexation Type (IDX_TYPE)');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `indexation_type` SET TAGS ('dbx_value_regex' = 'cpi|fixed|none');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Entitlement Number (ENT_NUM)');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `survivor_benefit_percentage` SET TAGS ('dbx_business_glossary_term' = 'Survivor Benefit Percentage (SURV_BEN_PCT)');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `survivor_relationship` SET TAGS ('dbx_business_glossary_term' = 'Survivor Relationship (SURV_REL)');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `survivor_relationship` SET TAGS ('dbx_value_regex' = 'spouse|child|parent|other');
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp (UPDATED_TS)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` SET TAGS ('dbx_domain' = 'beneficiary');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` SET TAGS ('dbx_subdomain' = 'benefit_disbursement');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `benefit_payment_id` SET TAGS ('dbx_business_glossary_term' = 'Benefit Payment ID (BPAY_ID)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `designated_beneficiary_id` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary ID (BEN_ID)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `designated_beneficiary_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `designated_beneficiary_id` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `cash_transfer_id` SET TAGS ('dbx_business_glossary_term' = 'Cash Transfer Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `entitlement_id` SET TAGS ('dbx_business_glossary_term' = 'Entitlement Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `member_id` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary ID (BEN_ID)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `member_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `member_id` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `clawback_amount` SET TAGS ('dbx_business_glossary_term' = 'Clawback Amount (CLAWBACK_AMT)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `clawback_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `clawback_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (CURR_CODE)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `gross_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Payment Amount (GROSS_AMT)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `gross_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `gross_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `net_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Payment Amount (NET_AMT)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `net_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `net_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `overpayment_recovery_amount` SET TAGS ('dbx_business_glossary_term' = 'Overpayment Recovery Amount (OVERPAY_REC_AMT)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `overpayment_recovery_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `overpayment_recovery_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_approval_by` SET TAGS ('dbx_business_glossary_term' = 'Payment Approval By (PAY_APP_BY)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Approval Date (PAY_APP_DATE)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_approval_status` SET TAGS ('dbx_business_glossary_term' = 'Payment Approval Status (PAY_APP_STATUS)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_approval_status` SET TAGS ('dbx_value_regex' = 'approved|pending|rejected');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_channel` SET TAGS ('dbx_business_glossary_term' = 'Payment Channel (PAY_CHANNEL)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_channel` SET TAGS ('dbx_value_regex' = 'online|branch|mobile');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Date (PAY_DATE)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_dispute_amount` SET TAGS ('dbx_business_glossary_term' = 'Payment Dispute Amount (PAY_DISP_AMT)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_dispute_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_dispute_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_dispute_currency` SET TAGS ('dbx_business_glossary_term' = 'Payment Dispute Currency (PAY_DISP_CURR)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_dispute_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Dispute Date (PAY_DISP_DATE)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_dispute_reason` SET TAGS ('dbx_business_glossary_term' = 'Payment Dispute Reason (PAY_DISP_REASON)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_dispute_status` SET TAGS ('dbx_business_glossary_term' = 'Payment Dispute Status (PAY_DISP_STATUS)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_dispute_status` SET TAGS ('dbx_value_regex' = 'none|raised|resolved');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_business_glossary_term' = 'Payment Frequency (PAY_FREQ)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|annual|lump_sum');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_frequency_end_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Frequency End Date (PAY_FREQ_END)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_frequency_interval` SET TAGS ('dbx_business_glossary_term' = 'Payment Frequency Interval (PAY_FREQ_INT)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_frequency_last_paid_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Frequency Last Paid Date (PAY_FREQ_LAST_PAID)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_frequency_next_due_amount` SET TAGS ('dbx_business_glossary_term' = 'Payment Frequency Next Due Amount (PAY_FREQ_NEXT_AMT)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_frequency_next_due_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_frequency_next_due_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_frequency_next_due_channel` SET TAGS ('dbx_business_glossary_term' = 'Payment Frequency Next Due Channel (PAY_FREQ_NEXT_CHANNEL)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_frequency_next_due_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Frequency Next Due Date (PAY_FREQ_NEXT_DUE)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_frequency_next_due_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Frequency Next Due Method (PAY_FREQ_NEXT_METHOD)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_frequency_next_due_status` SET TAGS ('dbx_business_glossary_term' = 'Payment Frequency Next Due Status (PAY_FREQ_NEXT_STATUS)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_frequency_next_due_status` SET TAGS ('dbx_value_regex' = 'due|paid|overdue');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_frequency_start_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Frequency Start Date (PAY_FREQ_START)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method (PAY_METHOD)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'direct_deposit|cheque|cash|wire_transfer');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_notes` SET TAGS ('dbx_business_glossary_term' = 'Payment Notes (PAY_NOTES)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Payment Reference Number (PAY_REF_NO)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_reference_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{8,20}$');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_settlement_amount` SET TAGS ('dbx_business_glossary_term' = 'Payment Settlement Amount (PAY_SET_AMT)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_settlement_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_settlement_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_settlement_channel` SET TAGS ('dbx_business_glossary_term' = 'Payment Settlement Channel (PAY_SET_CHANNEL)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_settlement_channel` SET TAGS ('dbx_value_regex' = 'online|branch');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Settlement Date (PAY_SET_DATE)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_settlement_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Settlement Method (PAY_SET_METHOD)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_settlement_method` SET TAGS ('dbx_value_regex' = 'bank_transfer|cheque|cash');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_settlement_notes` SET TAGS ('dbx_business_glossary_term' = 'Payment Settlement Notes (PAY_SET_NOTES)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_settlement_reference` SET TAGS ('dbx_business_glossary_term' = 'Payment Settlement Reference (PAY_SET_REF)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_settlement_status` SET TAGS ('dbx_business_glossary_term' = 'Payment Settlement Status (PAY_SET_STATUS)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_settlement_status` SET TAGS ('dbx_value_regex' = 'settled|pending|failed');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_status` SET TAGS ('dbx_business_glossary_term' = 'Payment Status (PAY_STATUS)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_status` SET TAGS ('dbx_value_regex' = 'pending|processed|failed|cancelled|reversed');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `payment_time` SET TAGS ('dbx_business_glossary_term' = 'Payment Time (PAY_TIME)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `record_audit_created` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp (REC_CREATED_TS)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `record_audit_updated` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp (REC_UPDATED_TS)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `tax_withholding_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Withholding Amount (TAX_WTHD_AMT)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `tax_withholding_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ALTER COLUMN `tax_withholding_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` SET TAGS ('dbx_domain' = 'beneficiary');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` SET TAGS ('dbx_subdomain' = 'member_administration');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `member_lifecycle_event_id` SET TAGS ('dbx_business_glossary_term' = 'Member Lifecycle Event ID (MLE_ID)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `contributor_pool_id` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `member_id` SET TAGS ('dbx_business_glossary_term' = 'Member ID (MEM_ID)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `member_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `member_id` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `pension_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Plan ID (PLAN_ID)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_approval_by` SET TAGS ('dbx_business_glossary_term' = 'Event Approval By (EVT_APP_BY)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Event Approval Date (EVT_APP_DT)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_approval_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Event Approval Document Reference (EVT_APP_DOC_REF)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_approval_status` SET TAGS ('dbx_business_glossary_term' = 'Event Approval Status (EVT_APP_STAT)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected|cancelled');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_created_by_user` SET TAGS ('dbx_business_glossary_term' = 'Event Created By User (EVT_CRT_BY)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_created_by_user` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_created_by_user` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Event Created Timestamp (EVT_CRT_TS)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_description` SET TAGS ('dbx_business_glossary_term' = 'Event Description (EVT_DESC)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_end_date` SET TAGS ('dbx_business_glossary_term' = 'Event End Date (EVT_END_DT)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_member_age_at_event` SET TAGS ('dbx_business_glossary_term' = 'Member Age at Event (MEM_AGE_EVT)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_member_service_years` SET TAGS ('dbx_business_glossary_term' = 'Member Service Years (MEM_SVC_YRS)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_notes` SET TAGS ('dbx_business_glossary_term' = 'Event Notes (EVT_NOTES)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_plan_type` SET TAGS ('dbx_business_glossary_term' = 'Plan Type (PLAN_TYP)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_plan_type` SET TAGS ('dbx_value_regex' = 'public_equities|private_equities|real_estate|infrastructure|natural_resources|credit');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Event Reason Code (EVT_RSN_CD)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Event Reason Description (EVT_RSN_DESC)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Event Source System Code (EVT_SRC_SYS_CD)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_source_system_device` SET TAGS ('dbx_business_glossary_term' = 'Event Source System Device (EVT_SRC_SYS_DEV)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_source_system_device` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_source_system_device` SET TAGS ('dbx_pii_device' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_source_system_ip` SET TAGS ('dbx_business_glossary_term' = 'Event Source System IP Address (EVT_SRC_SYS_IP)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_source_system_ip` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_source_system_ip` SET TAGS ('dbx_pii_ip' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_source_system_location` SET TAGS ('dbx_business_glossary_term' = 'Event Source System Location (EVT_SRC_SYS_LOC)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_source_system_name` SET TAGS ('dbx_business_glossary_term' = 'Event Source System Name (EVT_SRC_SYS_NM)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_source_system_reference_code` SET TAGS ('dbx_business_glossary_term' = 'Event Source System Reference ID (EVT_SRC_SYS_REF_ID)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_source_system_reference_date` SET TAGS ('dbx_business_glossary_term' = 'Event Source System Reference Date (EVT_SRC_SYS_REF_DT)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_source_system_reference_description` SET TAGS ('dbx_business_glossary_term' = 'Event Source System Reference Description (EVT_SRC_SYS_REF_DESC)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_source_system_reference_status` SET TAGS ('dbx_business_glossary_term' = 'Event Source System Reference Status (EVT_SRC_SYS_REF_STAT)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_source_system_reference_type` SET TAGS ('dbx_business_glossary_term' = 'Event Source System Reference Type (EVT_SRC_SYS_REF_TP)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_source_system_reference_value` SET TAGS ('dbx_business_glossary_term' = 'Event Source System Reference Value (EVT_SRC_SYS_REF_VAL)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_source_system_user` SET TAGS ('dbx_business_glossary_term' = 'Event Source System User (EVT_SRC_SYS_USR)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_source_system_user` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_source_system_user` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_source_system_version` SET TAGS ('dbx_business_glossary_term' = 'Event Source System Version (EVT_SRC_SYS_VER)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_start_date` SET TAGS ('dbx_business_glossary_term' = 'Event Start Date (EVT_START_DT)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_status` SET TAGS ('dbx_business_glossary_term' = 'Event Status (EVT_STAT)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_status` SET TAGS ('dbx_value_regex' = 'pending|draft|completed|cancelled|approved|rejected');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_subtype` SET TAGS ('dbx_business_glossary_term' = 'Event Subtype (EVT_SUB_TYP)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_type` SET TAGS ('dbx_business_glossary_term' = 'Event Type (EVT_TYP)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_updated_by_user` SET TAGS ('dbx_business_glossary_term' = 'Event Updated By User (EVT_UPD_BY)');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_updated_by_user` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_updated_by_user` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ALTER COLUMN `event_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Event Updated Timestamp (EVT_UPD_TS)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` SET TAGS ('dbx_domain' = 'beneficiary');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` SET TAGS ('dbx_subdomain' = 'member_administration');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `designated_beneficiary_id` SET TAGS ('dbx_business_glossary_term' = 'Designated Beneficiary ID (DESIGNATED_BENEFICIARY_ID)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `actor_id` SET TAGS ('dbx_business_glossary_term' = 'Actor Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `member_id` SET TAGS ('dbx_business_glossary_term' = 'Member ID (MEMBER_ID)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `member_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `member_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `address_line_1` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary Address Line 1 (ADDR_LINE_1)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `address_line_1` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `address_line_1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `address_line_2` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary Address Line 2 (ADDR_LINE_2)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `address_line_2` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `address_line_2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `bank_account_number` SET TAGS ('dbx_business_glossary_term' = 'Bank Account Number (BANK_ACC_NUM)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `bank_account_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `bank_account_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `beneficiary_fraction_pct` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary Fraction Percentage (BENEFICIARY_FRAC_PCT)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `beneficiary_name` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary Full Name (BENEFICIARY_NAME)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `beneficiary_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `beneficiary_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `beneficiary_status` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary Status (STATUS)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `beneficiary_status` SET TAGS ('dbx_value_regex' = 'active|inactive|terminated|pending');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `benefit_amount` SET TAGS ('dbx_business_glossary_term' = 'Benefit Amount (BENEFIT_AMOUNT)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `benefit_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `benefit_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `benefit_commencement_date` SET TAGS ('dbx_business_glossary_term' = 'Benefit Commencement Date (BENEFIT_COMM_DATE)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `benefit_termination_date` SET TAGS ('dbx_business_glossary_term' = 'Benefit Termination Date (BENEFIT_TERM_DATE)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `benefit_type` SET TAGS ('dbx_business_glossary_term' = 'Benefit Type (BENEFIT_TYPE)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `benefit_type` SET TAGS ('dbx_value_regex' = 'lump_sum|periodic');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `children_benefit_age_limit` SET TAGS ('dbx_business_glossary_term' = 'Children Benefit Age Limit (CHILD_AGE_LIMIT)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `city` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary City (CITY)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `city` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary Country Code (COUNTRY_CODE)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `country_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `country_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp (CREATED_TIMESTAMP)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (CURRENCY_CODE)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary Date of Birth (DOB)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_pii_dob' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `death_cause_category` SET TAGS ('dbx_business_glossary_term' = 'Death Cause Category (DEATH_CAUSE_CAT)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `death_cause_category` SET TAGS ('dbx_value_regex' = 'natural|accident|suicide|other');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `death_certificate_reference` SET TAGS ('dbx_business_glossary_term' = 'Death Certificate Reference (DEATH_CERT_REF)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `death_date` SET TAGS ('dbx_business_glossary_term' = 'Death Date (DEATH_DATE)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `designation_date` SET TAGS ('dbx_business_glossary_term' = 'Designation Date (DESIGNATION_DATE)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `email_address` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary Email Address (EMAIL_ADDRESS)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `email_address` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `email_address` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `email_address` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `gender` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary Gender (GENDER)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `gender` SET TAGS ('dbx_value_regex' = 'male|female|non-binary|other');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `gender` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `gender` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `guarantee_period_months` SET TAGS ('dbx_business_glossary_term' = 'Guarantee Period (MONTHS) (GUARANTEE_PERIOD_MONTHS)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `is_disabled_dependent` SET TAGS ('dbx_business_glossary_term' = 'Disabled Dependent Flag (DISABLED_DEPENDENT)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `is_full_time_student` SET TAGS ('dbx_business_glossary_term' = 'Full Time Student Flag (FULL_TIME_STUDENT)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `kyc_verification_date` SET TAGS ('dbx_business_glossary_term' = 'KYC Verification Date (KYC_VERIF_DATE)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `kyc_verified` SET TAGS ('dbx_business_glossary_term' = 'KYC Verified (KYC_VERIFIED)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp (LAST_UPDATED_TIMESTAMP)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `lump_sum_amount` SET TAGS ('dbx_business_glossary_term' = 'Lump Sum Amount (LUMP_SUM_AMOUNT)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `marital_status` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary Marital Status (MARITAL_STATUS)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `marital_status` SET TAGS ('dbx_value_regex' = 'single|married|divorced|widowed|separated');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `marital_status` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `marital_status` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `national_identifier` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary National ID (NATIONAL_ID)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `national_identifier` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `national_identifier` SET TAGS ('dbx_pii_national_id' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `payment_end_date` SET TAGS ('dbx_business_glossary_term' = 'Payment End Date (PAYMENT_END_DATE)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_business_glossary_term' = 'Payment Frequency (PAYMENT_FREQ)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|annually|lump_sum');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method (PAYMENT_METHOD)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'bank_transfer|cheque|cash|mobile_wallet');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `payment_start_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Start Date (PAYMENT_START_DATE)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `phone_number` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary Phone Number (PHONE_NUMBER)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `phone_number` SET TAGS ('dbx_value_regex' = '^+?[1-9]d{1,14}$');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `phone_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `phone_number` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `postal_code` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary Postal Code (POSTAL_CODE)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `postal_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9 ]{3,10}$');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `postal_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `province_state` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary Province/State (PROVINCE_STATE)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `province_state` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `province_state` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `relationship_type` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary Relationship Type (RELATIONSHIP_TYPE)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `relationship_type` SET TAGS ('dbx_value_regex' = 'spouse|common_law_partner|dependent_child|estate');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `remarriage_termination_flag` SET TAGS ('dbx_business_glossary_term' = 'Remarriage Termination Flag (REMARREAGE_TERMINATION)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `spouse_dob` SET TAGS ('dbx_business_glossary_term' = 'Spouse Date of Birth (SPOUSE_DOB)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `spouse_dob` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `spouse_dob` SET TAGS ('dbx_pii_dob' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `spouse_name` SET TAGS ('dbx_business_glossary_term' = 'Spouse Name (SPOUSE_NAME)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `spouse_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `spouse_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `spouse_national_identifier` SET TAGS ('dbx_business_glossary_term' = 'Spouse National ID (SPOUSE_NATIONAL_ID)');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `spouse_national_identifier` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `spouse_national_identifier` SET TAGS ('dbx_pii_national_id' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ALTER COLUMN `tax_withholding_rate` SET TAGS ('dbx_business_glossary_term' = 'Tax Withholding Rate (TAX_WITHHOLD_RATE)');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` SET TAGS ('dbx_domain' = 'beneficiary');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` SET TAGS ('dbx_subdomain' = 'member_administration');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `member_address_id` SET TAGS ('dbx_business_glossary_term' = 'Member Address ID');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `member_address_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `member_address_id` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `member_id` SET TAGS ('dbx_business_glossary_term' = 'Member ID');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `member_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `member_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `address_format_type` SET TAGS ('dbx_business_glossary_term' = 'Address Format Type');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `address_format_type` SET TAGS ('dbx_value_regex' = 'north_american|european|uk|australian|international');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `address_line_1` SET TAGS ('dbx_business_glossary_term' = 'Address Line 1');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `address_line_1` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `address_line_1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `address_line_2` SET TAGS ('dbx_business_glossary_term' = 'Address Line 2');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `address_line_2` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `address_line_2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `address_line_3` SET TAGS ('dbx_business_glossary_term' = 'Address Line 3');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `address_line_3` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `address_line_3` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `address_notes` SET TAGS ('dbx_business_glossary_term' = 'Address Notes');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `address_notes` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `address_notes` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `address_source` SET TAGS ('dbx_business_glossary_term' = 'Address Source');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `address_source` SET TAGS ('dbx_value_regex' = 'member_self_service|employer_submission|plan_administrator|correspondence_return|third_party|migration');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `address_source` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `address_source` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `address_status` SET TAGS ('dbx_business_glossary_term' = 'Address Status');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `address_status` SET TAGS ('dbx_value_regex' = 'active|inactive|undeliverable|pending_verification|superseded');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `address_status` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `address_status` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `address_type` SET TAGS ('dbx_business_glossary_term' = 'Address Type');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `address_type` SET TAGS ('dbx_value_regex' = 'residential|mailing|employer|temporary|seasonal|overseas');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `care_of_name` SET TAGS ('dbx_business_glossary_term' = 'Care Of Name');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `care_of_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `care_of_name` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `city` SET TAGS ('dbx_business_glossary_term' = 'City');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `city` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `consent_recorded_date` SET TAGS ('dbx_business_glossary_term' = 'Consent Recorded Date');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `contributor_pool` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `contributor_pool` SET TAGS ('dbx_value_regex' = 'plan_1|plan_2|plan_3|plan_4');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `country_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `country_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `delivery_point_barcode` SET TAGS ('dbx_business_glossary_term' = 'Delivery Point Barcode');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `do_not_mail` SET TAGS ('dbx_business_glossary_term' = 'Do Not Mail Flag');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `do_not_mail_reason` SET TAGS ('dbx_business_glossary_term' = 'Do Not Mail Reason');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `do_not_mail_reason` SET TAGS ('dbx_value_regex' = 'member_request|legal_order|undeliverable|deceased|address_unknown|privacy_concern');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Effective From Date');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `effective_to` SET TAGS ('dbx_business_glossary_term' = 'Effective To Date');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `employer_department` SET TAGS ('dbx_business_glossary_term' = 'Employer Department');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `employer_name` SET TAGS ('dbx_business_glossary_term' = 'Employer Name');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `foreign_address_flag` SET TAGS ('dbx_business_glossary_term' = 'Foreign Address Flag');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `foreign_address_flag` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `foreign_address_flag` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `is_mailing_preferred` SET TAGS ('dbx_business_glossary_term' = 'Is Mailing Preferred Flag');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `is_primary` SET TAGS ('dbx_business_glossary_term' = 'Is Primary Address Flag');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `language_preference` SET TAGS ('dbx_business_glossary_term' = 'Language Preference');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `language_preference` SET TAGS ('dbx_value_regex' = 'EN|FR');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `latitude` SET TAGS ('dbx_business_glossary_term' = 'Latitude');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `latitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `latitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `longitude` SET TAGS ('dbx_business_glossary_term' = 'Longitude');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `longitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `longitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `po_box` SET TAGS ('dbx_business_glossary_term' = 'Post Office Box');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `po_box` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `po_box` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `postal_code` SET TAGS ('dbx_business_glossary_term' = 'Postal Code');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `postal_code` SET TAGS ('dbx_value_regex' = '^[A-Za-z0-9 -]{3,10}$');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `postal_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `province_state` SET TAGS ('dbx_business_glossary_term' = 'Province or State');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `province_state` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `province_state` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `rural_route` SET TAGS ('dbx_business_glossary_term' = 'Rural Route');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `rural_route` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `rural_route` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `source_system_ref` SET TAGS ('dbx_business_glossary_term' = 'Source System Reference');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `standardized_address` SET TAGS ('dbx_business_glossary_term' = 'Standardized Address');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `standardized_address` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `standardized_address` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `tax_jurisdiction_code` SET TAGS ('dbx_business_glossary_term' = 'Tax Jurisdiction Code');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `undeliverable_date` SET TAGS ('dbx_business_glossary_term' = 'Undeliverable Date');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `undeliverable_reason` SET TAGS ('dbx_business_glossary_term' = 'Undeliverable Reason');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `undeliverable_reason` SET TAGS ('dbx_value_regex' = 'moved_no_forwarding|unknown_address|insufficient_address|refused|vacant|deceased');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `verification_date` SET TAGS ('dbx_business_glossary_term' = 'Address Verification Date');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `verification_source` SET TAGS ('dbx_business_glossary_term' = 'Address Verification Source');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `verification_status` SET TAGS ('dbx_business_glossary_term' = 'Address Verification Status');
ALTER TABLE `asset_management`.`beneficiary`.`member_address` ALTER COLUMN `verification_status` SET TAGS ('dbx_value_regex' = 'verified|unverified|failed|pending|override');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` SET TAGS ('dbx_domain' = 'beneficiary');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` SET TAGS ('dbx_subdomain' = 'member_administration');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `member_contact_id` SET TAGS ('dbx_business_glossary_term' = 'Member Contact ID');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `member_id` SET TAGS ('dbx_business_glossary_term' = 'Member ID');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `member_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `member_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `bounce_count` SET TAGS ('dbx_business_glossary_term' = 'Bounce Count');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `communication_frequency_pref` SET TAGS ('dbx_business_glossary_term' = 'Communication Frequency Preference');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `communication_frequency_pref` SET TAGS ('dbx_value_regex' = 'immediate|daily_digest|weekly|monthly|annual_only|none');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `consent_evidence_ref` SET TAGS ('dbx_business_glossary_term' = 'Consent Evidence Reference');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `consent_source` SET TAGS ('dbx_business_glossary_term' = 'Consent Source');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `consent_source` SET TAGS ('dbx_value_regex' = 'member_portal|paper_form|call_centre|employer_submission|third_party');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `contact_status` SET TAGS ('dbx_business_glossary_term' = 'Contact Status');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `contact_status` SET TAGS ('dbx_value_regex' = 'active|inactive|unverified|bounced|opted_out');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `contact_subtype` SET TAGS ('dbx_business_glossary_term' = 'Contact Subtype');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `contact_subtype` SET TAGS ('dbx_value_regex' = 'personal|business|emergency|legal_guardian|power_of_attorney');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `contact_type` SET TAGS ('dbx_business_glossary_term' = 'Contact Type');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `contact_type` SET TAGS ('dbx_value_regex' = 'mobile|home_phone|work_phone|email|fax|postal_address');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `contact_value` SET TAGS ('dbx_business_glossary_term' = 'Contact Value');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `contact_value` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `contact_value` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `contributor_pool` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `contributor_pool` SET TAGS ('dbx_value_regex' = 'plan_1|plan_2|plan_3|plan_4');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `data_retention_category` SET TAGS ('dbx_business_glossary_term' = 'Data Retention Category');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `data_retention_category` SET TAGS ('dbx_value_regex' = 'active_member|deferred_member|pensioner|deceased|purge_eligible');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `do_not_contact` SET TAGS ('dbx_business_glossary_term' = 'Do Not Contact Flag');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `do_not_contact_reason` SET TAGS ('dbx_business_glossary_term' = 'Do Not Contact Reason');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `do_not_contact_reason` SET TAGS ('dbx_value_regex' = 'member_request|legal_hold|deceased|incapacitated|regulatory_order|fraud_flag');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `effective_from_date` SET TAGS ('dbx_business_glossary_term' = 'Effective From Date');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `effective_to_date` SET TAGS ('dbx_business_glossary_term' = 'Effective To Date');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `email_domain` SET TAGS ('dbx_business_glossary_term' = 'Email Domain');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `email_domain` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `email_domain` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `gdpr_lawful_basis` SET TAGS ('dbx_business_glossary_term' = 'General Data Protection Regulation (GDPR) Lawful Basis');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `gdpr_lawful_basis` SET TAGS ('dbx_value_regex' = 'consent|legal_obligation|legitimate_interest|vital_interest|public_task|contract');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `is_primary` SET TAGS ('dbx_business_glossary_term' = 'Is Primary Contact Flag');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `is_verified` SET TAGS ('dbx_business_glossary_term' = 'Contact Verified Flag');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `language_preference` SET TAGS ('dbx_business_glossary_term' = 'Language Preference');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `language_preference` SET TAGS ('dbx_value_regex' = '^[a-z]{2}(-[A-Z]{2})?$');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `last_bounce_date` SET TAGS ('dbx_business_glossary_term' = 'Last Bounce Date');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `last_used_date` SET TAGS ('dbx_business_glossary_term' = 'Last Used Date');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Contact Notes');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `opt_in_date` SET TAGS ('dbx_business_glossary_term' = 'Digital Opt-In Date');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `opt_in_digital` SET TAGS ('dbx_business_glossary_term' = 'Digital Communication Opt-In Flag');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `opt_out_date` SET TAGS ('dbx_business_glossary_term' = 'Digital Opt-Out Date');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `phone_country_dial_code` SET TAGS ('dbx_business_glossary_term' = 'Phone Country Dial Code');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `phone_country_dial_code` SET TAGS ('dbx_value_regex' = '^+[0-9]{1,4}$');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `phone_country_dial_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `phone_country_dial_code` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `phone_extension` SET TAGS ('dbx_business_glossary_term' = 'Phone Extension');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `phone_extension` SET TAGS ('dbx_value_regex' = '^[0-9]{1,10}$');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `phone_extension` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `phone_extension` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `preferred_channel` SET TAGS ('dbx_business_glossary_term' = 'Preferred Communication Channel Flag');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `purge_eligible_date` SET TAGS ('dbx_business_glossary_term' = 'Purge Eligible Date');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `source_system_ref` SET TAGS ('dbx_business_glossary_term' = 'Source System Reference');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `verification_date` SET TAGS ('dbx_business_glossary_term' = 'Verification Date');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `verification_method` SET TAGS ('dbx_business_glossary_term' = 'Verification Method');
ALTER TABLE `asset_management`.`beneficiary`.`member_contact` ALTER COLUMN `verification_method` SET TAGS ('dbx_value_regex' = 'email_link|sms_otp|postal_letter|call_centre|employer_confirmed|not_verified');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` SET TAGS ('dbx_domain' = 'beneficiary');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` SET TAGS ('dbx_subdomain' = 'contribution_management');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `contribution_rate_id` SET TAGS ('dbx_business_glossary_term' = 'Contribution Rate ID');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `contributor_pool_id` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `actuarial_valuation_year` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Valuation Year');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Rate Approval Date');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `contribution_frequency` SET TAGS ('dbx_business_glossary_term' = 'Contribution Frequency');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `contribution_frequency` SET TAGS ('dbx_value_regex' = 'bi_weekly|monthly|semi_monthly|weekly');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `earnings_threshold_lower` SET TAGS ('dbx_business_glossary_term' = 'Pensionable Earnings Lower Threshold');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `earnings_threshold_upper` SET TAGS ('dbx_business_glossary_term' = 'Pensionable Earnings Upper Threshold');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Effective From Date');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Effective Until Date');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `employment_category` SET TAGS ('dbx_business_glossary_term' = 'Employment Category');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `employment_category` SET TAGS ('dbx_value_regex' = 'full_time|part_time|casual|contract');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `gazette_reference` SET TAGS ('dbx_business_glossary_term' = 'Official Gazette Reference');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `indexation_basis` SET TAGS ('dbx_business_glossary_term' = 'Indexation Basis');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `indexation_basis` SET TAGS ('dbx_value_regex' = 'cpi|fixed|none|negotiated');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `indexation_rate` SET TAGS ('dbx_business_glossary_term' = 'Indexation Rate');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `is_mandatory` SET TAGS ('dbx_business_glossary_term' = 'Mandatory Contribution Flag');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `is_tax_deductible` SET TAGS ('dbx_business_glossary_term' = 'Tax Deductible Contribution Flag');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `jurisdiction_code` SET TAGS ('dbx_business_glossary_term' = 'Jurisdiction Code');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `jurisdiction_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,3}$');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `legislative_authority` SET TAGS ('dbx_business_glossary_term' = 'Legislative Authority');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `max_pensionable_earnings` SET TAGS ('dbx_business_glossary_term' = 'Maximum Pensionable Earnings');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `min_pensionable_earnings` SET TAGS ('dbx_business_glossary_term' = 'Minimum Pensionable Earnings');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `plan_type` SET TAGS ('dbx_business_glossary_term' = 'Pension Plan Type');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `plan_type` SET TAGS ('dbx_value_regex' = 'defined_benefit|defined_contribution|hybrid');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `rate_code` SET TAGS ('dbx_business_glossary_term' = 'Contribution Rate Code');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `rate_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{3,30}$');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `rate_description` SET TAGS ('dbx_business_glossary_term' = 'Contribution Rate Description');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `rate_name` SET TAGS ('dbx_business_glossary_term' = 'Contribution Rate Schedule Name');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Contribution Rate Percentage');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `rate_percent` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `rate_status` SET TAGS ('dbx_business_glossary_term' = 'Contribution Rate Status');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `rate_status` SET TAGS ('dbx_value_regex' = 'active|superseded|pending|withdrawn');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `rate_tier` SET TAGS ('dbx_business_glossary_term' = 'Contribution Rate Tier');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `rate_type` SET TAGS ('dbx_business_glossary_term' = 'Contribution Rate Type');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `rate_type` SET TAGS ('dbx_value_regex' = 'employee|employer|combined');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `regulatory_basis` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Basis');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `service_category` SET TAGS ('dbx_business_glossary_term' = 'Service Category');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `service_category` SET TAGS ('dbx_value_regex' = 'regular|reserve|secondment|leave_without_pay');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `superseded_by_rate_code` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Rate Code');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `superseded_by_rate_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{3,30}$');
ALTER TABLE `asset_management`.`beneficiary`.`contribution_rate` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Rate Schedule Version Number');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` SET TAGS ('dbx_domain' = 'beneficiary');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` SET TAGS ('dbx_subdomain' = 'contribution_management');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `service_buyback_id` SET TAGS ('dbx_business_glossary_term' = 'Service Buyback ID');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `assumption_set_id` SET TAGS ('dbx_business_glossary_term' = 'Assumption Set Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `contributor_pool_id` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool ID');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `member_id` SET TAGS ('dbx_business_glossary_term' = 'Member ID');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `member_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `member_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `pension_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Pension Plan ID');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `actuarial_cost_amount` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Cost Amount');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `actuarial_cost_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `actuarial_cost_basis` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Cost Basis');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `actuarial_cost_basis` SET TAGS ('dbx_value_regex' = 'prospective|retrospective|blended');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `actuarial_cost_currency` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Cost Currency');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `actuarial_cost_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `actuarial_valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Valuation Date');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `application_received_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Application Received Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `buyback_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Service Buyback Reference Number');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `buyback_reference_number` SET TAGS ('dbx_value_regex' = '^SBB-[0-9]{4}-[0-9]{8}$');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `buyback_status` SET TAGS ('dbx_business_glossary_term' = 'Service Buyback Status');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `buyback_status` SET TAGS ('dbx_value_regex' = 'pending|approved|in_progress|completed|cancelled|rejected');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `cancellation_date` SET TAGS ('dbx_business_glossary_term' = 'Buyback Cancellation Date');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_business_glossary_term' = 'Buyback Cancellation Reason');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_value_regex' = 'member_withdrawal|payment_default|ineligibility_determined|plan_rule_change|administrative_error|other');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `completion_date` SET TAGS ('dbx_business_glossary_term' = 'Buyback Completion Date');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `election_date` SET TAGS ('dbx_business_glossary_term' = 'Buyback Election Date');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `eligibility_verification_date` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Verification Date');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `eligibility_verified` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Verified Flag');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `employer_contribution_amount` SET TAGS ('dbx_business_glossary_term' = 'Employer Contribution Amount');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `employer_contribution_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `installment_amount` SET TAGS ('dbx_business_glossary_term' = 'Installment Payment Amount');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `installment_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `installment_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `installment_count` SET TAGS ('dbx_business_glossary_term' = 'Installment Count');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `installment_frequency` SET TAGS ('dbx_business_glossary_term' = 'Installment Frequency');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `installment_frequency` SET TAGS ('dbx_value_regex' = 'weekly|bi_weekly|monthly|quarterly|annually');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `interest_accrued_amount` SET TAGS ('dbx_business_glossary_term' = 'Interest Accrued Amount');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `interest_accrued_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `interest_accrued_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `interest_rate` SET TAGS ('dbx_business_glossary_term' = 'Buyback Interest Rate');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Updated Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `member_age_at_election` SET TAGS ('dbx_business_glossary_term' = 'Member Age at Election');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `member_contribution_amount` SET TAGS ('dbx_business_glossary_term' = 'Member Contribution Amount');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `member_contribution_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `member_contribution_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Administrative Notes');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `outstanding_balance_amount` SET TAGS ('dbx_business_glossary_term' = 'Outstanding Balance Amount');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `outstanding_balance_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `outstanding_balance_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `payment_deadline_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Deadline Date');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Buyback Payment Method');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'lump_sum|installment|payroll_deduction|retirement_account_transfer|pension_transfer');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `pension_adjustment_amount` SET TAGS ('dbx_business_glossary_term' = 'Pension Adjustment (PA) Amount');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `pension_adjustment_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `pension_adjustment_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `prior_service_end_date` SET TAGS ('dbx_business_glossary_term' = 'Prior Service End Date');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `prior_service_start_date` SET TAGS ('dbx_business_glossary_term' = 'Prior Service Start Date');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `prior_service_type` SET TAGS ('dbx_business_glossary_term' = 'Prior Service Type');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `salary_used_for_costing` SET TAGS ('dbx_business_glossary_term' = 'Salary Used for Actuarial Costing');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `salary_used_for_costing` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `salary_used_for_costing` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `service_credit_posted_date` SET TAGS ('dbx_business_glossary_term' = 'Service Credit Posted Date');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `service_credits_purchased_years` SET TAGS ('dbx_business_glossary_term' = 'Service Credits Purchased (Years)');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `source_system_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Reference');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `supporting_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Supporting Document Reference');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `tax_receipt_issued` SET TAGS ('dbx_business_glossary_term' = 'Tax Receipt Issued Flag');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `tax_receipt_year` SET TAGS ('dbx_business_glossary_term' = 'Tax Receipt Year');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `total_paid_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Paid-In Capital (PIC) Amount');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `total_paid_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ALTER COLUMN `total_paid_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` SET TAGS ('dbx_domain' = 'beneficiary');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` SET TAGS ('dbx_subdomain' = 'contribution_management');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `transfer_in_id` SET TAGS ('dbx_business_glossary_term' = 'Transfer-In ID');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `designated_beneficiary_id` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary ID');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `cash_transfer_id` SET TAGS ('dbx_business_glossary_term' = 'Cash Transfer Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `contributor_pool_id` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `member_id` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary ID');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `member_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `member_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `pension_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Plan Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `actuarial_basis` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Basis Description');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `aml_screened` SET TAGS ('dbx_business_glossary_term' = 'Anti-Money Laundering (AML) Screened Flag');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `commuted_value` SET TAGS ('dbx_business_glossary_term' = 'Commuted Value (CV)');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `commuted_value` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `commuted_value` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `tax_authority_approval_date` SET TAGS ('dbx_business_glossary_term' = 'tax authority Approval Date');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `tax_authority_approval_reference` SET TAGS ('dbx_business_glossary_term' = 'tax authority Approval Reference Number');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `tax_authority_approval_required` SET TAGS ('dbx_business_glossary_term' = 'tax authority Approval Required Flag');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `custodian_reference` SET TAGS ('dbx_business_glossary_term' = 'Custodian Settlement Reference');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `discount_rate` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Discount Rate');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Transfer Effective Date');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `employer_contribution_amount` SET TAGS ('dbx_business_glossary_term' = 'Employer Contribution Amount');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `employer_contribution_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `employer_contribution_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `fx_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `gl_posting_reference` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Posting Reference');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `investment_earnings_amount` SET TAGS ('dbx_business_glossary_term' = 'Investment Earnings Amount');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `investment_earnings_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `investment_earnings_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `kyc_verified` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Verified Flag');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `locked_in_flag` SET TAGS ('dbx_business_glossary_term' = 'Locked-In Flag');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `member_consent_date` SET TAGS ('dbx_business_glossary_term' = 'Member Consent Date');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `member_contribution_amount` SET TAGS ('dbx_business_glossary_term' = 'Member Contribution Amount');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `member_contribution_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `member_contribution_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Transfer-In Notes');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `past_service_pension_adjustment` SET TAGS ('dbx_business_glossary_term' = 'Past Service Pension Adjustment');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `past_service_pension_adjustment` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `past_service_pension_adjustment` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `pension_adjustment_reversal` SET TAGS ('dbx_business_glossary_term' = 'Pension Adjustment Reversal (PAR)');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `pension_adjustment_reversal` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `pension_adjustment_reversal` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `portability_election_type` SET TAGS ('dbx_business_glossary_term' = 'Portability Election Type');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `portability_election_type` SET TAGS ('dbx_value_regex' = 'full_transfer|partial_transfer');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `prior_service_end_date` SET TAGS ('dbx_business_glossary_term' = 'Prior Service End Date');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `prior_service_start_date` SET TAGS ('dbx_business_glossary_term' = 'Prior Service Start Date');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `receipt_date` SET TAGS ('dbx_business_glossary_term' = 'Transfer Receipt Date');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `reference_number` SET TAGS ('dbx_business_glossary_term' = 'Transfer-In Reference Number');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `reference_number` SET TAGS ('dbx_value_regex' = '^TRF-IN-[0-9]{8,12}$');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `rejection_reason` SET TAGS ('dbx_business_glossary_term' = 'Transfer Rejection Reason');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `service_credit_years` SET TAGS ('dbx_business_glossary_term' = 'Recognized Service Credit (Years)');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `simcorp_transaction_reference` SET TAGS ('dbx_business_glossary_term' = 'SimCorp Dimension Transaction ID');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `source_plan_administrator` SET TAGS ('dbx_business_glossary_term' = 'Source Plan Administrator Name');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `source_plan_confirmation_ref` SET TAGS ('dbx_business_glossary_term' = 'Source Plan Confirmation Reference');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `source_plan_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Source Plan Jurisdiction');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `source_plan_jurisdiction` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,3}$');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `source_plan_name` SET TAGS ('dbx_business_glossary_term' = 'Source Pension Plan Name');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `source_plan_registration_number` SET TAGS ('dbx_business_glossary_term' = 'Source Plan Registration Number');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `source_plan_type` SET TAGS ('dbx_business_glossary_term' = 'Source Plan Type');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `source_plan_type` SET TAGS ('dbx_value_regex' = 'defined_benefit|defined_contribution|individual_retirement_account|group_retirement_plan|profit_sharing_plan');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `tax_withheld_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Withheld Amount');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `tax_withheld_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `tax_withheld_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `transfer_amount` SET TAGS ('dbx_business_glossary_term' = 'Transfer-In Amount');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `transfer_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `transfer_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `transfer_amount_base_equivalent` SET TAGS ('dbx_business_glossary_term' = 'Transfer-In Amount (Base Currency)');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `transfer_amount_base_equivalent` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `transfer_amount_base_equivalent` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `transfer_currency` SET TAGS ('dbx_business_glossary_term' = 'Transfer Currency Code');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `transfer_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `transfer_date` SET TAGS ('dbx_business_glossary_term' = 'Transfer Date');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `transfer_method` SET TAGS ('dbx_business_glossary_term' = 'Transfer Method');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `transfer_method` SET TAGS ('dbx_value_regex' = 'wire_transfer|cheque|in_kind|electronic_funds_transfer');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `transfer_status` SET TAGS ('dbx_business_glossary_term' = 'Transfer-In Status');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `transfer_status` SET TAGS ('dbx_value_regex' = 'pending|in_progress|completed|rejected|cancelled');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `transfer_type` SET TAGS ('dbx_business_glossary_term' = 'Transfer-In Type');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `transfer_type` SET TAGS ('dbx_value_regex' = 'commuted_value|service_credit|rrsp_conversion|direct_transfer|group_transfer');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Transfer Valuation Date');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `vesting_status` SET TAGS ('dbx_business_glossary_term' = 'Vesting Status');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ALTER COLUMN `vesting_status` SET TAGS ('dbx_value_regex' = 'fully_vested|partially_vested|unvested');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` SET TAGS ('dbx_domain' = 'beneficiary');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` SET TAGS ('dbx_subdomain' = 'contribution_management');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `transfer_out_id` SET TAGS ('dbx_business_glossary_term' = 'Transfer Out ID');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `assumption_set_id` SET TAGS ('dbx_business_glossary_term' = 'Assumption Set Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `cash_transfer_id` SET TAGS ('dbx_business_glossary_term' = 'Cash Transfer Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `contributor_pool_id` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `member_id` SET TAGS ('dbx_business_glossary_term' = 'Member ID');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `member_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `member_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `pension_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Pension Plan ID');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `accrued_service_years` SET TAGS ('dbx_business_glossary_term' = 'Accrued Pensionable Service Years');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `aml_cleared` SET TAGS ('dbx_business_glossary_term' = 'Anti-Money Laundering (AML) Cleared Indicator');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `aml_review_date` SET TAGS ('dbx_business_glossary_term' = 'AML Review Date');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Transfer Approval Date');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By (Staff ID or Name)');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `base_currency_amount` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Transfer Amount');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `base_currency_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `base_currency_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `best_average_salary` SET TAGS ('dbx_business_glossary_term' = 'Best Average Salary (BAS)');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `best_average_salary` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `best_average_salary` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `commuted_value_amount` SET TAGS ('dbx_business_glossary_term' = 'Commuted Value (CV) Amount');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `commuted_value_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `commuted_value_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `discount_rate` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Discount Rate');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `election_date` SET TAGS ('dbx_business_glossary_term' = 'Member Transfer Election Date');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `election_deadline_date` SET TAGS ('dbx_business_glossary_term' = 'Transfer Election Deadline Date');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `fx_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `initiated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Transfer Initiation Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `is_cross_border` SET TAGS ('dbx_business_glossary_term' = 'Cross-Border Transfer Indicator');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Updated Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `member_consent_ref` SET TAGS ('dbx_business_glossary_term' = 'Member Consent Reference');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `mortality_table_code` SET TAGS ('dbx_business_glossary_term' = 'Mortality Table Code');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Transfer Out Notes');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'wire_transfer|direct_deposit|cheque|electronic_funds_transfer');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `receiving_country_code` SET TAGS ('dbx_business_glossary_term' = 'Receiving Country Code (ISO 3166-1 Alpha-3)');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `receiving_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `receiving_institution_lei` SET TAGS ('dbx_business_glossary_term' = 'Receiving Institution Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `receiving_institution_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{18}[0-9]{2}$');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `receiving_institution_name` SET TAGS ('dbx_business_glossary_term' = 'Receiving Financial Institution Name');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `receiving_plan_number` SET TAGS ('dbx_business_glossary_term' = 'Receiving Plan Account Number');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `receiving_plan_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `receiving_plan_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `receiving_plan_type` SET TAGS ('dbx_business_glossary_term' = 'Receiving Plan Type');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `reference_number` SET TAGS ('dbx_business_glossary_term' = 'Transfer Out Reference Number');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `reference_number` SET TAGS ('dbx_value_regex' = '^TO-[0-9]{4}-[0-9]{8}$');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `registered_transfer_amount` SET TAGS ('dbx_business_glossary_term' = 'Registered Transfer Amount');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `registered_transfer_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `registered_transfer_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `regulatory_filing_ref` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Reference');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `settlement_instructions_ref` SET TAGS ('dbx_business_glossary_term' = 'Standard Settlement Instructions (SSI) Reference');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `source_system_ref` SET TAGS ('dbx_business_glossary_term' = 'Source System Reference');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `tax_slip_issued` SET TAGS ('dbx_business_glossary_term' = 'Tax Slip Issued Indicator');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `tax_slip_year` SET TAGS ('dbx_business_glossary_term' = 'Tax Slip Reporting Year');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `taxable_portion_amount` SET TAGS ('dbx_business_glossary_term' = 'Taxable Portion Amount');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `taxable_portion_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `taxable_portion_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Employment Termination Date');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `transfer_date` SET TAGS ('dbx_business_glossary_term' = 'Transfer Execution Date');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `transfer_reason` SET TAGS ('dbx_business_glossary_term' = 'Transfer Out Reason');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `transfer_reason` SET TAGS ('dbx_value_regex' = 'voluntary_resignation|involuntary_termination|retirement_ineligible|inter_plan_transfer|death_survivor');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `transfer_status` SET TAGS ('dbx_business_glossary_term' = 'Transfer Out Status');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `transfer_type` SET TAGS ('dbx_business_glossary_term' = 'Transfer Out Type');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `transfer_type` SET TAGS ('dbx_value_regex' = 'commuted_value|pension_credit|lump_sum_cv|partial_transfer');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Commuted Value Valuation Date');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `withholding_tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Withholding Tax Amount');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `withholding_tax_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ALTER COLUMN `withholding_tax_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` SET TAGS ('dbx_domain' = 'beneficiary');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` SET TAGS ('dbx_subdomain' = 'benefit_disbursement');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `retirement_election_id` SET TAGS ('dbx_business_glossary_term' = 'Retirement Election ID');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `beneficiary_id` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary ID');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `benefit_option_id` SET TAGS ('dbx_business_glossary_term' = 'Benefit Option Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `contributor_pool_id` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `designated_beneficiary_id` SET TAGS ('dbx_business_glossary_term' = 'Designated Survivor ID');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `member_id` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary ID');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `member_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `member_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `pension_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Pension Plan ID');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `survivor_designated_beneficiary_id` SET TAGS ('dbx_business_glossary_term' = 'Designated Survivor ID');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `administrator_notes` SET TAGS ('dbx_business_glossary_term' = 'Administrator Notes');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `approved_date` SET TAGS ('dbx_business_glossary_term' = 'Election Approved Date');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `bank_account_reference` SET TAGS ('dbx_business_glossary_term' = 'Bank Account Reference');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `bank_account_reference` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `bank_account_reference` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `best_average_earnings` SET TAGS ('dbx_business_glossary_term' = 'Best Average Earnings');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `best_average_earnings` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `best_average_earnings` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `bridge_benefit_amount` SET TAGS ('dbx_business_glossary_term' = 'Bridge Benefit Annual Amount');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `bridge_benefit_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `bridge_benefit_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `bridge_benefit_elected` SET TAGS ('dbx_business_glossary_term' = 'Bridge Benefit Elected Flag');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `bridge_benefit_end_date` SET TAGS ('dbx_business_glossary_term' = 'Bridge Benefit End Date');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `commutation_amount` SET TAGS ('dbx_business_glossary_term' = 'Commutation Lump Sum Amount');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `commutation_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `commutation_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `commutation_elected` SET TAGS ('dbx_business_glossary_term' = 'Commutation Elected Flag');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `disability_certification_date` SET TAGS ('dbx_business_glossary_term' = 'Disability Certification Date');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `disability_certification_date` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `disability_certification_date` SET TAGS ('dbx_pii_health' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `early_retirement_reduction_rate` SET TAGS ('dbx_business_glossary_term' = 'Early Retirement Actuarial Reduction Rate');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `effective_retirement_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Retirement Date');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `election_channel` SET TAGS ('dbx_business_glossary_term' = 'Election Submission Channel');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `election_channel` SET TAGS ('dbx_value_regex' = 'online_portal|paper_form|in_person|telephone');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `election_form_version` SET TAGS ('dbx_business_glossary_term' = 'Election Form Version');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `election_received_date` SET TAGS ('dbx_business_glossary_term' = 'Election Received Date');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `election_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Retirement Election Reference Number');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `election_reference_number` SET TAGS ('dbx_value_regex' = '^RE-[0-9]{4}-[0-9]{8}$');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `election_status` SET TAGS ('dbx_business_glossary_term' = 'Retirement Election Status');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `election_status` SET TAGS ('dbx_value_regex' = 'draft|submitted|under_review|approved|rejected|cancelled');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `election_submitted_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Retirement Election Submitted Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `first_payment_date` SET TAGS ('dbx_business_glossary_term' = 'First Pension Payment Date');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `gross_annual_pension` SET TAGS ('dbx_business_glossary_term' = 'Gross Annual Pension Amount');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `gross_annual_pension` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `gross_annual_pension` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `guaranteed_period_years` SET TAGS ('dbx_business_glossary_term' = 'Guaranteed Period Years');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `indexation_type` SET TAGS ('dbx_business_glossary_term' = 'Pension Indexation Type');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `indexation_type` SET TAGS ('dbx_value_regex' = 'full_cpi|partial_cpi|fixed_rate|none');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `is_irrevocable` SET TAGS ('dbx_business_glossary_term' = 'Election Irrevocable Flag');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `member_age_at_retirement` SET TAGS ('dbx_business_glossary_term' = 'Member Age at Retirement');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `member_consent_obtained` SET TAGS ('dbx_business_glossary_term' = 'Member Consent Obtained Flag');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `member_date_of_birth` SET TAGS ('dbx_business_glossary_term' = 'Member Date of Birth');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `member_date_of_birth` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `member_date_of_birth` SET TAGS ('dbx_pii_dob' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_business_glossary_term' = 'Pension Payment Frequency');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Pension Payment Method');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'direct_deposit|cheque|wire_transfer');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `pensionable_service_years` SET TAGS ('dbx_business_glossary_term' = 'Pensionable Service Years');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `reduced_annual_pension` SET TAGS ('dbx_business_glossary_term' = 'Reduced Annual Pension Amount');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `reduced_annual_pension` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `reduced_annual_pension` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `rejection_reason` SET TAGS ('dbx_business_glossary_term' = 'Election Rejection Reason');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `retirement_type` SET TAGS ('dbx_business_glossary_term' = 'Retirement Type');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `retirement_type` SET TAGS ('dbx_value_regex' = 'normal|early|deferred|disability|involuntary');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `spousal_consent_obtained` SET TAGS ('dbx_business_glossary_term' = 'Spousal Consent Obtained Flag');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `survivor_benefit_percentage` SET TAGS ('dbx_business_glossary_term' = 'Survivor Benefit Percentage');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `survivor_date_of_birth` SET TAGS ('dbx_business_glossary_term' = 'Survivor Date of Birth');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `survivor_date_of_birth` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `survivor_date_of_birth` SET TAGS ('dbx_pii_dob' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `survivor_relationship` SET TAGS ('dbx_business_glossary_term' = 'Survivor Relationship to Member');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `survivor_relationship` SET TAGS ('dbx_value_regex' = 'spouse|common_law_partner|dependent_child|other');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `tax_withholding_code` SET TAGS ('dbx_business_glossary_term' = 'Tax Withholding Code');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `transfer_destination` SET TAGS ('dbx_business_glossary_term' = 'Commutation Transfer Destination');
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ALTER COLUMN `transfer_destination` SET TAGS ('dbx_value_regex' = 'retirement_savings_account|locked_in_retirement_account|retirement_income_fund|locked_in_account|cash|other');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` SET TAGS ('dbx_domain' = 'beneficiary');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` SET TAGS ('dbx_subdomain' = 'benefit_disbursement');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `indexation_adjustment_id` SET TAGS ('dbx_business_glossary_term' = 'Indexation Adjustment ID');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `designated_beneficiary_id` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary ID');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `designated_beneficiary_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `designated_beneficiary_id` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `benefit_payment_id` SET TAGS ('dbx_business_glossary_term' = 'Benefit Payment ID');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `indexation_policy_id` SET TAGS ('dbx_business_glossary_term' = 'Indexation Policy Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `macro_indicator_id` SET TAGS ('dbx_business_glossary_term' = 'Macro Indicator Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `member_id` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary ID');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `member_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `member_id` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `pension_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Pension Plan ID');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `superseded_by_adjustment_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Adjustment ID');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `actuarial_basis_code` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Basis Code');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `adjusted_benefit_amount` SET TAGS ('dbx_business_glossary_term' = 'Adjusted Benefit Amount');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `adjusted_benefit_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `adjusted_benefit_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `adjustment_amount` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Amount');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `adjustment_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `adjustment_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `adjustment_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Indexation Adjustment Reference Number');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `adjustment_reference_number` SET TAGS ('dbx_value_regex' = '^IDX-[0-9]{4}-[0-9]{8}$');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `adjustment_status` SET TAGS ('dbx_business_glossary_term' = 'Indexation Adjustment Status');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `adjustment_status` SET TAGS ('dbx_value_regex' = 'pending|approved|applied|reversed|cancelled');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `adjustment_year` SET TAGS ('dbx_business_glossary_term' = 'Indexation Adjustment Year');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `announcement_date` SET TAGS ('dbx_business_glossary_term' = 'Announcement Date');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `applied_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Applied Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `benefit_frequency` SET TAGS ('dbx_business_glossary_term' = 'Benefit Payment Frequency');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `benefit_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|annual');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `cost_centre_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Centre Code');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `cpi_measure_used` SET TAGS ('dbx_business_glossary_term' = 'Consumer Price Index (CPI) Measure Used');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `cpi_measure_used` SET TAGS ('dbx_value_regex' = 'all_items_cpi|core_cpi|trimmed_mean_cpi|weighted_median_cpi|plan_specific');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `indexation_cap_rate` SET TAGS ('dbx_business_glossary_term' = 'Indexation Cap Rate');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `indexation_floor_rate` SET TAGS ('dbx_business_glossary_term' = 'Indexation Floor Rate');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `indexation_rate` SET TAGS ('dbx_business_glossary_term' = 'Indexation Rate');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `indexation_type` SET TAGS ('dbx_business_glossary_term' = 'Indexation Type');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `indexation_type` SET TAGS ('dbx_value_regex' = 'full_cpi|partial_cpi|fixed_rate|ad_hoc|nil');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `is_rate_capped` SET TAGS ('dbx_business_glossary_term' = 'Is Rate Capped Indicator');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `is_rate_floored` SET TAGS ('dbx_business_glossary_term' = 'Is Rate Floored Indicator');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Last Updated Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `liability_impact_amount` SET TAGS ('dbx_business_glossary_term' = 'Liability Impact Amount');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `liability_impact_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Notes');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `notification_date` SET TAGS ('dbx_business_glossary_term' = 'Notification Date');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `notification_sent` SET TAGS ('dbx_business_glossary_term' = 'Notification Sent Indicator');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `plan_type` SET TAGS ('dbx_business_glossary_term' = 'Pension Plan Type');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `plan_type` SET TAGS ('dbx_value_regex' = 'plan_1|plan_2|plan_3|plan_4');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `prior_benefit_amount` SET TAGS ('dbx_business_glossary_term' = 'Prior Benefit Amount');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `prior_benefit_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `prior_benefit_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `prior_cpi_value` SET TAGS ('dbx_business_glossary_term' = 'Prior Consumer Price Index (CPI) Value');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `reference_cpi_period_end` SET TAGS ('dbx_business_glossary_term' = 'Reference Consumer Price Index (CPI) Period End Date');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `reference_cpi_period_start` SET TAGS ('dbx_business_glossary_term' = 'Reference Consumer Price Index (CPI) Period Start Date');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `reference_cpi_value` SET TAGS ('dbx_business_glossary_term' = 'Reference Consumer Price Index (CPI) Value');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `regulatory_reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Flag');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `reversal_date` SET TAGS ('dbx_business_glossary_term' = 'Reversal Date');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `reversal_reason` SET TAGS ('dbx_business_glossary_term' = 'Reversal Reason');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'SIMCORP|STATE_STREET|ORACLE|MANUAL');
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ALTER COLUMN `source_system_reference_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Reference ID');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` SET TAGS ('dbx_domain' = 'beneficiary');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` SET TAGS ('dbx_subdomain' = 'benefit_disbursement');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `survivor_benefit_id` SET TAGS ('dbx_business_glossary_term' = 'Survivor Benefit ID');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `contributor_pool_id` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `designated_beneficiary_id` SET TAGS ('dbx_business_glossary_term' = 'Survivor Beneficiary ID');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `member_id` SET TAGS ('dbx_business_glossary_term' = 'Plan Member ID');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `member_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `member_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `pension_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Plan Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `survivor_designated_beneficiary_id` SET TAGS ('dbx_business_glossary_term' = 'Survivor Beneficiary ID');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `actuarial_present_value` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Present Value of Survivor Benefit');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `actuarial_present_value` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Benefit Approval Date');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Benefit Approved By');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `bank_account_reference` SET TAGS ('dbx_business_glossary_term' = 'Survivor Bank Account Reference');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `bank_account_reference` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `bank_account_reference` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `benefit_commencement_date` SET TAGS ('dbx_business_glossary_term' = 'Benefit Commencement Date');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `benefit_fraction` SET TAGS ('dbx_business_glossary_term' = 'Survivor Benefit Fraction');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `benefit_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Survivor Benefit Reference Number');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `benefit_reference_number` SET TAGS ('dbx_value_regex' = '^SB-[A-Z]{2,4}-[0-9]{8,12}$');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `benefit_status` SET TAGS ('dbx_business_glossary_term' = 'Survivor Benefit Status');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `benefit_status` SET TAGS ('dbx_value_regex' = 'pending|active|suspended|terminated|expired');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `benefit_termination_date` SET TAGS ('dbx_business_glossary_term' = 'Benefit Termination Date');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `benefit_type` SET TAGS ('dbx_business_glossary_term' = 'Survivor Benefit Type');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `benefit_type` SET TAGS ('dbx_value_regex' = 'survivor_pension|death_in_service_lump_sum|childrens_benefit|dependent_pension|continuation_pension');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `children_benefit_age_limit` SET TAGS ('dbx_business_glossary_term' = 'Childrens Benefit Age Limit');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Benefit Currency Code');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `death_cause_category` SET TAGS ('dbx_business_glossary_term' = 'Death Cause Category');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `death_cause_category` SET TAGS ('dbx_value_regex' = 'natural|accidental|service_related|occupational_illness|other');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `death_certificate_reference` SET TAGS ('dbx_business_glossary_term' = 'Death Certificate Reference Number');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `death_certificate_reference` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `discount_rate` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Discount Rate');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `gross_annual_benefit_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Annual Benefit Amount');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `gross_annual_benefit_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `gross_annual_benefit_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `guarantee_period_months` SET TAGS ('dbx_business_glossary_term' = 'Benefit Guarantee Period (Months)');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `indexation_rate` SET TAGS ('dbx_business_glossary_term' = 'Benefit Indexation Rate');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `indexation_type` SET TAGS ('dbx_business_glossary_term' = 'Benefit Indexation Type');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `indexation_type` SET TAGS ('dbx_value_regex' = 'cpi_full|cpi_partial|fixed_rate|none');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `is_disabled_dependent` SET TAGS ('dbx_business_glossary_term' = 'Disabled Dependent Indicator');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `is_full_time_student` SET TAGS ('dbx_business_glossary_term' = 'Full-Time Student Indicator');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `kyc_verification_date` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Verification Date');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `kyc_verified` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Verified Indicator');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `last_payment_date` SET TAGS ('dbx_business_glossary_term' = 'Last Benefit Payment Date');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `lump_sum_amount` SET TAGS ('dbx_business_glossary_term' = 'Lump Sum Death Benefit Amount');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `lump_sum_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `lump_sum_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `member_death_date` SET TAGS ('dbx_business_glossary_term' = 'Member Death Date');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `net_annual_benefit_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Annual Benefit Amount');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `net_annual_benefit_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `net_annual_benefit_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `next_payment_date` SET TAGS ('dbx_business_glossary_term' = 'Next Scheduled Benefit Payment Date');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Survivor Benefit Administrative Notes');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `payment_country_code` SET TAGS ('dbx_business_glossary_term' = 'Payment Destination Country Code');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `payment_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_business_glossary_term' = 'Benefit Payment Frequency');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual|one_time');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Benefit Payment Method');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'direct_deposit|cheque|wire_transfer|eft');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `plan_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Plan Document Reference');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `remarriage_termination_flag` SET TAGS ('dbx_business_glossary_term' = 'Remarriage Termination Flag');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Record Identifier');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `survivor_date_of_birth` SET TAGS ('dbx_business_glossary_term' = 'Survivor Date of Birth');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `survivor_date_of_birth` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `survivor_date_of_birth` SET TAGS ('dbx_pii_dob' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `survivor_full_name` SET TAGS ('dbx_business_glossary_term' = 'Survivor Full Legal Name');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `survivor_full_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `survivor_full_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `survivor_national_identifier` SET TAGS ('dbx_business_glossary_term' = 'Survivor National Identification Number');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `survivor_national_identifier` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `survivor_national_identifier` SET TAGS ('dbx_pii_national_id' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `survivor_relationship_type` SET TAGS ('dbx_business_glossary_term' = 'Survivor Relationship Type');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `survivor_relationship_type` SET TAGS ('dbx_value_regex' = 'spouse|common_law_partner|dependent_child|disabled_dependent|other_dependent');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `tax_withholding_rate` SET TAGS ('dbx_business_glossary_term' = 'Tax Withholding Rate');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `tax_withholding_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `total_paid_to_date` SET TAGS ('dbx_business_glossary_term' = 'Total Survivor Benefit Paid to Date');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `total_paid_to_date` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `total_paid_to_date` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`survivor_benefit` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Valuation Date');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` SET TAGS ('dbx_domain' = 'beneficiary');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` SET TAGS ('dbx_subdomain' = 'benefit_disbursement');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `member_statement_id` SET TAGS ('dbx_business_glossary_term' = 'Member Statement ID');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `contributor_pool_id` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `member_id` SET TAGS ('dbx_business_glossary_term' = 'Member ID');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `member_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `member_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `pension_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Pension Plan ID');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `accrual_rate` SET TAGS ('dbx_business_glossary_term' = 'Pension Accrual Rate');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `accrued_pension_annual_amount` SET TAGS ('dbx_business_glossary_term' = 'Accrued Pension Annual Amount');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `accrued_pension_annual_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `accrued_pension_annual_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `acknowledgement_date` SET TAGS ('dbx_business_glossary_term' = 'Member Acknowledgement Date');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `actuarial_valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Valuation Date');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `benefit_formula_type` SET TAGS ('dbx_business_glossary_term' = 'Benefit Formula Type');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `benefit_formula_type` SET TAGS ('dbx_value_regex' = 'defined_benefit|defined_contribution|hybrid|cash_balance');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `best_average_salary` SET TAGS ('dbx_business_glossary_term' = 'Best Average Salary');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `best_average_salary` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `best_average_salary` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `buyback_service_years` SET TAGS ('dbx_business_glossary_term' = 'Buyback Service Years');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_business_glossary_term' = 'Member Date of Birth');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_pii_dob' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `delivery_channel` SET TAGS ('dbx_business_glossary_term' = 'Statement Delivery Channel');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `delivery_channel` SET TAGS ('dbx_value_regex' = 'postal_mail|member_portal|email|in_person|employer_portal');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `delivery_date` SET TAGS ('dbx_business_glossary_term' = 'Statement Delivery Date');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `disability_benefit_eligible` SET TAGS ('dbx_business_glossary_term' = 'Disability Benefit Eligible');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `disability_benefit_eligible` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `disability_benefit_eligible` SET TAGS ('dbx_pii_health' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `discount_rate` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Discount Rate');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `early_retirement_eligible_date` SET TAGS ('dbx_business_glossary_term' = 'Early Retirement Eligible Date');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `employer_contributions_cumulative` SET TAGS ('dbx_business_glossary_term' = 'Employer Contributions Cumulative');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `employer_contributions_cumulative` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `employer_contributions_cumulative` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `employer_contributions_ytd` SET TAGS ('dbx_business_glossary_term' = 'Employer Contributions Year-to-Date (YTD)');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `employer_contributions_ytd` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `employer_contributions_ytd` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `generated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Statement Generated Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `indexation_rate` SET TAGS ('dbx_business_glossary_term' = 'Pension Indexation Rate');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `issue_date` SET TAGS ('dbx_business_glossary_term' = 'Statement Issue Date');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Statement Last Updated Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `leave_without_pay_service_years` SET TAGS ('dbx_business_glossary_term' = 'Leave Without Pay (LWOP) Service Years');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `member_acknowledged` SET TAGS ('dbx_business_glossary_term' = 'Member Acknowledged');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `member_contributions_cumulative` SET TAGS ('dbx_business_glossary_term' = 'Member Contributions Cumulative');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `member_contributions_cumulative` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `member_contributions_cumulative` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `member_contributions_ytd` SET TAGS ('dbx_business_glossary_term' = 'Member Contributions Year-to-Date (YTD)');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `member_contributions_ytd` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `member_contributions_ytd` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `member_lifecycle_status` SET TAGS ('dbx_business_glossary_term' = 'Member Lifecycle Status');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `member_lifecycle_status` SET TAGS ('dbx_value_regex' = 'active_contributor|deferred|retired|deceased|transferred_out');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `normal_retirement_date` SET TAGS ('dbx_business_glossary_term' = 'Normal Retirement Date');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `pensionable_salary` SET TAGS ('dbx_business_glossary_term' = 'Pensionable Salary');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `pensionable_salary` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `pensionable_salary` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `pensionable_service_years` SET TAGS ('dbx_business_glossary_term' = 'Pensionable Service Years');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `pensionable_service_ytd_years` SET TAGS ('dbx_business_glossary_term' = 'Pensionable Service Year-to-Date (YTD) Years');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Statement Period End Date');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Statement Period Start Date');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `plan_entry_date` SET TAGS ('dbx_business_glossary_term' = 'Plan Entry Date');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `projected_pension_at_nra` SET TAGS ('dbx_business_glossary_term' = 'Projected Pension at Normal Retirement Age (NRA)');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `projected_pension_at_nra` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `projected_pension_at_nra` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `regulatory_disclosure_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Disclosure Flag');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `source_system_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Reference');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `statement_number` SET TAGS ('dbx_business_glossary_term' = 'Statement Number');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `statement_number` SET TAGS ('dbx_value_regex' = '^STMT-[A-Z0-9]{4,10}-[0-9]{4}$');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `statement_status` SET TAGS ('dbx_business_glossary_term' = 'Statement Status');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `statement_status` SET TAGS ('dbx_value_regex' = 'draft|generated|issued|delivered|acknowledged|superseded');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `statement_type` SET TAGS ('dbx_business_glossary_term' = 'Statement Type');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `statement_type` SET TAGS ('dbx_value_regex' = 'annual|on_demand|retirement_estimate|termination|death_benefit');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `survivor_benefit_eligible` SET TAGS ('dbx_business_glossary_term' = 'Survivor Benefit Eligible');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `survivor_pension_annual_amount` SET TAGS ('dbx_business_glossary_term' = 'Survivor Pension Annual Amount');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `survivor_pension_annual_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `survivor_pension_annual_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `transfer_value` SET TAGS ('dbx_business_glossary_term' = 'Transfer Value');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `transfer_value` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `transfer_value` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `voluntary_additional_contributions_ytd` SET TAGS ('dbx_business_glossary_term' = 'Voluntary Additional Contributions Year-to-Date (YTD)');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `voluntary_additional_contributions_ytd` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ALTER COLUMN `voluntary_additional_contributions_ytd` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` SET TAGS ('dbx_domain' = 'beneficiary');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` SET TAGS ('dbx_subdomain' = 'contribution_management');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `employer_remittance_id` SET TAGS ('dbx_business_glossary_term' = 'Employer Remittance ID');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `contributor_pool_id` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool ID');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Employer Bank Account ID');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `cash_account_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `cash_account_id` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `fund_bank_account_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Bank Account ID');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `fund_bank_account_id` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `fund_bank_account_id` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `participating_employer_id` SET TAGS ('dbx_business_glossary_term' = 'Employer ID');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `pension_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Pension Plan ID');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `reversal_reference_employer_remittance_id` SET TAGS ('dbx_business_glossary_term' = 'Reversal Reference ID');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `rule_breach_id` SET TAGS ('dbx_business_glossary_term' = 'Rule Breach Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `adjustment_amount` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Amount');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `adjustment_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `adjustment_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `approved_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `arrears_amount` SET TAGS ('dbx_business_glossary_term' = 'Arrears Amount');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `arrears_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `arrears_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `bank_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Bank Reference Number');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `bank_reference_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `cost_centre_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Centre Code');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `days_late` SET TAGS ('dbx_business_glossary_term' = 'Days Late');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Remittance Due Date');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `employee_contribution_amount` SET TAGS ('dbx_business_glossary_term' = 'Employee Contribution Amount');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `employee_contribution_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `employee_contribution_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `employer_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Employer Contact Email Address');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `employer_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `employer_contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `employer_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `employer_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Employer Contact Name');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `employer_contact_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `employer_contribution_amount` SET TAGS ('dbx_business_glossary_term' = 'Employer Contribution Amount');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `employer_contribution_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `employer_contribution_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `file_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Remittance File Reference Number');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `interest_on_arrears_amount` SET TAGS ('dbx_business_glossary_term' = 'Interest on Arrears Amount');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `interest_on_arrears_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `interest_on_arrears_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `is_late_submission` SET TAGS ('dbx_business_glossary_term' = 'Late Submission Indicator');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `late_penalty_amount` SET TAGS ('dbx_business_glossary_term' = 'Late Penalty Amount');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `late_penalty_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `member_count` SET TAGS ('dbx_business_glossary_term' = 'Member Count');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Remittance Notes');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'wire_transfer|eft|cheque|direct_debit|internal_transfer');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `payroll_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Payroll Period End Date');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `payroll_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Payroll Period Start Date');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `received_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Received Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `reconciliation_date` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Date');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Status');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_value_regex' = 'unreconciled|in_progress|reconciled|exception|written_off');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `rejection_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Rejection Reason Code');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `rejection_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Rejection Reason Description');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `remittance_channel` SET TAGS ('dbx_business_glossary_term' = 'Remittance Submission Channel');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `remittance_channel` SET TAGS ('dbx_value_regex' = 'employer_portal|api|manual_upload|paper_form|payroll_integration');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `remittance_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Remittance Reference Number');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `remittance_reference_number` SET TAGS ('dbx_value_regex' = '^REM-[A-Z0-9]{4,20}$');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `remittance_status` SET TAGS ('dbx_business_glossary_term' = 'Remittance Status');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `remittance_status` SET TAGS ('dbx_value_regex' = 'submitted|under_review|accepted|rejected|partially_accepted|reversed');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `remittance_type` SET TAGS ('dbx_business_glossary_term' = 'Remittance Type');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `remittance_type` SET TAGS ('dbx_value_regex' = 'regular|supplemental|adjustment|arrears|reversal');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'SIMCORP|ORACLE_FIN|EMPLOYER_PORTAL|STATE_STREET|MANUAL');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'Remittance Submission Date');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `total_remittance_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Remittance Amount');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `total_remittance_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `total_remittance_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `value_date` SET TAGS ('dbx_business_glossary_term' = 'Value Date');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `variance_amount` SET TAGS ('dbx_business_glossary_term' = 'Remittance Variance Amount');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `variance_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `voluntary_contribution_amount` SET TAGS ('dbx_business_glossary_term' = 'Voluntary Contribution Amount');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `voluntary_contribution_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ALTER COLUMN `voluntary_contribution_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` SET TAGS ('dbx_domain' = 'beneficiary');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` SET TAGS ('dbx_subdomain' = 'member_administration');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `participating_employer_id` SET TAGS ('dbx_business_glossary_term' = 'Participating Employer ID');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `actor_id` SET TAGS ('dbx_business_glossary_term' = 'Actor Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `contributor_pool_id` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `kyc_record_id` SET TAGS ('dbx_business_glossary_term' = 'Kyc Record Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `regulatory_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `active_member_count` SET TAGS ('dbx_business_glossary_term' = 'Active Member Count');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `aml_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Anti-Money Laundering (AML) Risk Rating');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `aml_risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `bank_account_reference` SET TAGS ('dbx_business_glossary_term' = 'Bank Account Reference');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `bank_account_reference` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `bank_account_reference` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `benefit_formula_code` SET TAGS ('dbx_business_glossary_term' = 'Benefit Formula Code');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `benefit_formula_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,20}$');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `bic_code` SET TAGS ('dbx_business_glossary_term' = 'Bank Identifier Code (BIC)');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `bic_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{4}[A-Z]{2}[A-Z0-9]{2}([A-Z0-9]{3})?$');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `collective_agreement_reference` SET TAGS ('dbx_business_glossary_term' = 'Collective Agreement Reference');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `contribution_remittance_frequency` SET TAGS ('dbx_business_glossary_term' = 'Contribution Remittance Frequency');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `contribution_remittance_frequency` SET TAGS ('dbx_value_regex' = 'weekly|bi_weekly|semi_monthly|monthly|quarterly');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `data_sharing_agreement` SET TAGS ('dbx_business_glossary_term' = 'Data Sharing Agreement Flag');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `data_sharing_agreement_date` SET TAGS ('dbx_business_glossary_term' = 'Data Sharing Agreement Date');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `employee_contribution_rate` SET TAGS ('dbx_business_glossary_term' = 'Employee Contribution Rate');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `employee_contribution_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `employer_code` SET TAGS ('dbx_business_glossary_term' = 'Employer Code');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `employer_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,20}$');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `employer_contribution_rate` SET TAGS ('dbx_business_glossary_term' = 'Employer Contribution Rate');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `employer_contribution_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `employer_type` SET TAGS ('dbx_business_glossary_term' = 'Employer Type');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `enrollment_date` SET TAGS ('dbx_business_glossary_term' = 'Plan Enrollment Date');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `esg_policy_compliant` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social Governance (ESG) Policy Compliant Flag');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `jurisdiction_code` SET TAGS ('dbx_business_glossary_term' = 'Jurisdiction Code');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `jurisdiction_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,3}$');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `kyc_review_date` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Review Date');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `kyc_verified` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Verified Flag');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `late_remittance_count` SET TAGS ('dbx_business_glossary_term' = 'Late Remittance Count');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `legal_name` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Name');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `lei` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{18}[0-9]{2}$');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `normal_retirement_age` SET TAGS ('dbx_business_glossary_term' = 'Normal Retirement Age');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Employer Notes');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `outstanding_contribution_amount` SET TAGS ('dbx_business_glossary_term' = 'Outstanding Contribution Amount');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `outstanding_contribution_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `participation_agreement_date` SET TAGS ('dbx_business_glossary_term' = 'Participation Agreement Date');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `participation_agreement_number` SET TAGS ('dbx_business_glossary_term' = 'Participation Agreement Number');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `participation_agreement_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{4,30}$');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `participation_status` SET TAGS ('dbx_business_glossary_term' = 'Participation Status');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `participation_status` SET TAGS ('dbx_value_regex' = 'active|suspended|terminated|pending_enrollment|pending_termination');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `payroll_system_code` SET TAGS ('dbx_business_glossary_term' = 'Payroll System Code');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `payroll_system_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,30}$');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `pensionable_payroll_amount` SET TAGS ('dbx_business_glossary_term' = 'Pensionable Payroll Amount');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `pensionable_payroll_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `plan_type` SET TAGS ('dbx_business_glossary_term' = 'Pension Plan Type');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `plan_type` SET TAGS ('dbx_value_regex' = 'defined_benefit|defined_contribution|hybrid|supplemental');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Email Address');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Name');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Phone Number');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_value_regex' = '^+?[0-9s-().]{7,20}$');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `registered_address_line1` SET TAGS ('dbx_business_glossary_term' = 'Registered Address Line 1');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `registered_address_line1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `registered_address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `registered_address_line2` SET TAGS ('dbx_business_glossary_term' = 'Registered Address Line 2');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `registered_address_line2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `registered_address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `registered_city` SET TAGS ('dbx_business_glossary_term' = 'Registered City');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `registered_city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `registered_city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `registered_postal_code` SET TAGS ('dbx_business_glossary_term' = 'Registered Postal Code');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `registered_postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `registered_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `remittance_due_day` SET TAGS ('dbx_business_glossary_term' = 'Remittance Due Day');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `short_name` SET TAGS ('dbx_business_glossary_term' = 'Employer Short Name');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Plan Termination Date');
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ALTER COLUMN `vesting_period_years` SET TAGS ('dbx_business_glossary_term' = 'Vesting Period (Years)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` SET TAGS ('dbx_data_type' = 'reference_data');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` SET TAGS ('dbx_domain' = 'beneficiary');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` SET TAGS ('dbx_subdomain' = 'benefit_disbursement');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `benefit_option_id` SET TAGS ('dbx_business_glossary_term' = 'Benefit Option ID');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `contributor_pool_id` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `actuarial_basis_code` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Basis Code');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `actuarial_basis_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Basis Effective Date');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `benefit_option_status` SET TAGS ('dbx_business_glossary_term' = 'Benefit Option Status');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `benefit_option_status` SET TAGS ('dbx_value_regex' = 'active|inactive|deprecated|pending_approval|grandfathered');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `bridge_benefit_eligible` SET TAGS ('dbx_business_glossary_term' = 'Bridge Benefit Eligible Flag');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `bridge_benefit_end_age` SET TAGS ('dbx_business_glossary_term' = 'Bridge Benefit End Age');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `commutation_allowed` SET TAGS ('dbx_business_glossary_term' = 'Commutation Allowed Flag');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `commutation_max_pct` SET TAGS ('dbx_business_glossary_term' = 'Maximum Commutation Percentage');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `death_benefit_type` SET TAGS ('dbx_business_glossary_term' = 'Death Benefit Type');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `death_benefit_type` SET TAGS ('dbx_value_regex' = 'return_of_contributions|continuation_to_survivor|guaranteed_period_balance|none');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `default_option` SET TAGS ('dbx_business_glossary_term' = 'Default Option Flag');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `early_retirement_reduction` SET TAGS ('dbx_business_glossary_term' = 'Early Retirement Reduction Flag');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `early_retirement_reduction_rate` SET TAGS ('dbx_business_glossary_term' = 'Early Retirement Reduction Rate (Per Year)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `election_irrevocable` SET TAGS ('dbx_business_glossary_term' = 'Election Irrevocable Flag');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `election_window_days` SET TAGS ('dbx_business_glossary_term' = 'Election Window (Days)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Expiry Date');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `guaranteed_period_years` SET TAGS ('dbx_business_glossary_term' = 'Guaranteed Period (Years)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `indexation_cap_pct` SET TAGS ('dbx_business_glossary_term' = 'Indexation Cap Percentage');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `indexation_floor_pct` SET TAGS ('dbx_business_glossary_term' = 'Indexation Floor Percentage');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `indexation_type` SET TAGS ('dbx_business_glossary_term' = 'Indexation Type');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `indexation_type` SET TAGS ('dbx_value_regex' = 'full_cpi|partial_cpi|fixed_rate|none');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `ldi_liability_category` SET TAGS ('dbx_business_glossary_term' = 'Liability-Driven Investment (LDI) Liability Category');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `ldi_liability_category` SET TAGS ('dbx_value_regex' = 'indexed_deferred|indexed_in_payment|non_indexed|bridge|contingent');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `max_retirement_age` SET TAGS ('dbx_business_glossary_term' = 'Maximum Retirement Age');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `member_facing_description` SET TAGS ('dbx_business_glossary_term' = 'Member-Facing Description');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `min_retirement_age` SET TAGS ('dbx_business_glossary_term' = 'Minimum Retirement Age');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `min_service_years` SET TAGS ('dbx_business_glossary_term' = 'Minimum Pensionable Service (Years)');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `option_code` SET TAGS ('dbx_business_glossary_term' = 'Benefit Option Code');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `option_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,30}$');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `option_name` SET TAGS ('dbx_business_glossary_term' = 'Benefit Option Name');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `option_type` SET TAGS ('dbx_business_glossary_term' = 'Benefit Option Type');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `option_type` SET TAGS ('dbx_value_regex' = 'single_life_annuity|joint_and_survivor_annuity|guaranteed_period|bridge_benefit|indexed_annuity|combination');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_business_glossary_term' = 'Payment Frequency');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `payment_timing` SET TAGS ('dbx_business_glossary_term' = 'Payment Timing');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `payment_timing` SET TAGS ('dbx_value_regex' = 'in_advance|in_arrears');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `pension_adjustment_applicable` SET TAGS ('dbx_business_glossary_term' = 'Pension Adjustment (PA) Applicable Flag');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `plan_text_reference` SET TAGS ('dbx_business_glossary_term' = 'Plan Text Reference');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `reduction_factor_pct` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Reduction Factor Percentage');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `regulatory_approval_ref` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Reference');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `sort_order` SET TAGS ('dbx_business_glossary_term' = 'Display Sort Order');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `spousal_consent_required` SET TAGS ('dbx_business_glossary_term' = 'Spousal Consent Required Flag');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `survivor_fraction_pct` SET TAGS ('dbx_business_glossary_term' = 'Survivor Fraction Percentage');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `tax_treatment_code` SET TAGS ('dbx_business_glossary_term' = 'Tax Treatment Code');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `tax_treatment_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `tax_treatment_code` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `transfer_value_eligible` SET TAGS ('dbx_business_glossary_term' = 'Transfer Value Eligible Flag');
ALTER TABLE `asset_management`.`beneficiary`.`benefit_option` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` SET TAGS ('dbx_domain' = 'beneficiary');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` SET TAGS ('dbx_subdomain' = 'benefit_disbursement');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `overpayment_recovery_id` SET TAGS ('dbx_business_glossary_term' = 'Overpayment Recovery ID');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `designated_beneficiary_id` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary ID');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `benefit_payment_id` SET TAGS ('dbx_business_glossary_term' = 'Benefit Payment ID');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `contributor_pool_id` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `member_id` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary ID');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `member_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `member_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `rule_breach_id` SET TAGS ('dbx_business_glossary_term' = 'Rule Breach Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `actual_recovery_end_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Recovery End Date');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `amount_recovered_to_date` SET TAGS ('dbx_business_glossary_term' = 'Amount Recovered to Date');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `amount_recovered_to_date` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `amount_recovered_to_date` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `case_notes` SET TAGS ('dbx_business_glossary_term' = 'Case Notes');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `case_owner` SET TAGS ('dbx_business_glossary_term' = 'Case Owner');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `detection_date` SET TAGS ('dbx_business_glossary_term' = 'Overpayment Detection Date');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `dispute_date` SET TAGS ('dbx_business_glossary_term' = 'Dispute Date');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `dispute_outcome` SET TAGS ('dbx_business_glossary_term' = 'Dispute Outcome');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `dispute_outcome` SET TAGS ('dbx_value_regex' = 'upheld|partially_upheld|dismissed|withdrawn');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `dispute_raised` SET TAGS ('dbx_business_glossary_term' = 'Dispute Raised Indicator');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `dispute_resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Dispute Resolution Date');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `estate_claim_reference` SET TAGS ('dbx_business_glossary_term' = 'Estate Claim Reference');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `expected_recovery_end_date` SET TAGS ('dbx_business_glossary_term' = 'Expected Recovery End Date');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `gross_overpayment_amount` SET TAGS ('dbx_business_glossary_term' = 'Gross Overpayment Amount');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `gross_overpayment_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `gross_overpayment_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `hardship_waiver_amount` SET TAGS ('dbx_business_glossary_term' = 'Hardship Waiver Amount');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `hardship_waiver_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `hardship_waiver_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `hardship_waiver_granted` SET TAGS ('dbx_business_glossary_term' = 'Hardship Waiver Granted Indicator');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `instalment_amount` SET TAGS ('dbx_business_glossary_term' = 'Recovery Instalment Amount');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `instalment_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `instalment_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `instalment_frequency` SET TAGS ('dbx_business_glossary_term' = 'Recovery Instalment Frequency');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `instalment_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|annually|one_time');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `legal_action_date` SET TAGS ('dbx_business_glossary_term' = 'Legal Action Initiation Date');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `legal_action_initiated` SET TAGS ('dbx_business_glossary_term' = 'Legal Action Initiated Indicator');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `member_notification_date` SET TAGS ('dbx_business_glossary_term' = 'Member Notification Date');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `net_recoverable_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Recoverable Amount');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `net_recoverable_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `net_recoverable_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `notification_channel` SET TAGS ('dbx_business_glossary_term' = 'Member Notification Channel');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `notification_channel` SET TAGS ('dbx_value_regex' = 'letter|email|phone|portal|in_person');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `outstanding_balance` SET TAGS ('dbx_business_glossary_term' = 'Outstanding Recovery Balance');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `outstanding_balance` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `outstanding_balance` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `overpayment_cause` SET TAGS ('dbx_business_glossary_term' = 'Overpayment Cause');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `overpayment_cause` SET TAGS ('dbx_value_regex' = 'death_notification_delay|calculation_error|eligibility_change|duplicate_payment|rate_error|other');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `overpayment_end_date` SET TAGS ('dbx_business_glossary_term' = 'Overpayment End Date');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `overpayment_start_date` SET TAGS ('dbx_business_glossary_term' = 'Overpayment Start Date');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `overpayment_type` SET TAGS ('dbx_business_glossary_term' = 'Overpayment Type');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `overpayment_type` SET TAGS ('dbx_value_regex' = 'pension_benefit|survivor_benefit|disability_benefit|lump_sum|other');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `recovery_method` SET TAGS ('dbx_business_glossary_term' = 'Recovery Method');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `recovery_method` SET TAGS ('dbx_value_regex' = 'benefit_deduction|lump_sum_repayment|estate_claim|legal_action|write_off|instalment_plan');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `recovery_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Overpayment Recovery Reference Number');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `recovery_reference_number` SET TAGS ('dbx_value_regex' = '^OPR-[0-9]{4}-[0-9]{6}$');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `recovery_start_date` SET TAGS ('dbx_business_glossary_term' = 'Recovery Start Date');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `recovery_status` SET TAGS ('dbx_business_glossary_term' = 'Recovery Status');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `regulatory_report_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Report Date');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `regulatory_reporting_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Required Indicator');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `responsible_team` SET TAGS ('dbx_business_glossary_term' = 'Responsible Team');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `responsible_team` SET TAGS ('dbx_value_regex' = 'pension_admin|member_services|legal|finance|actuarial');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `simcorp_case_reference` SET TAGS ('dbx_business_glossary_term' = 'SimCorp Dimension Case Reference');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `tax_adjustment_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Adjustment Amount');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `tax_adjustment_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `tax_adjustment_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `write_off_amount` SET TAGS ('dbx_business_glossary_term' = 'Write-Off Amount');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `write_off_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `write_off_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `write_off_date` SET TAGS ('dbx_business_glossary_term' = 'Write-Off Date');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `write_off_reason` SET TAGS ('dbx_business_glossary_term' = 'Write-Off Reason');
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ALTER COLUMN `write_off_reason` SET TAGS ('dbx_value_regex' = 'deceased_no_estate|hardship|statute_barred|legal_settlement|de_minimis|other');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` SET TAGS ('dbx_domain' = 'beneficiary');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` SET TAGS ('dbx_subdomain' = 'member_administration');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `member_document_id` SET TAGS ('dbx_business_glossary_term' = 'Member Document ID');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `member_id` SET TAGS ('dbx_business_glossary_term' = 'Member ID');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `member_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `member_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `pension_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Pension Plan ID');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `superseded_by_document_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Document ID');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `access_restriction_level` SET TAGS ('dbx_business_glossary_term' = 'Document Access Restriction Level');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `access_restriction_level` SET TAGS ('dbx_value_regex' = 'unrestricted|plan_admin_only|legal_team_only|medical_officer_only|executive_only');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `beneficiary_designation_flag` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary Designation Flag');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `certified_copy_flag` SET TAGS ('dbx_business_glossary_term' = 'Certified Copy Flag');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `contains_phi_flag` SET TAGS ('dbx_business_glossary_term' = 'Contains Protected Health Information Flag');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `contains_pii_flag` SET TAGS ('dbx_business_glossary_term' = 'Contains Personal Information Flag');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `data_classification` SET TAGS ('dbx_business_glossary_term' = 'Data Classification Level');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `data_classification` SET TAGS ('dbx_value_regex' = 'restricted|confidential|internal|public');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `digital_repository_path` SET TAGS ('dbx_business_glossary_term' = 'Digital Repository Path');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `digital_repository_path` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `disability_certification_type` SET TAGS ('dbx_business_glossary_term' = 'Disability Certification Type');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `disability_certification_type` SET TAGS ('dbx_value_regex' = 'initial|renewal|termination|not_applicable');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `disability_certification_type` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `disability_certification_type` SET TAGS ('dbx_pii_health' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `document_category` SET TAGS ('dbx_business_glossary_term' = 'Document Category');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `document_category` SET TAGS ('dbx_value_regex' = 'identity|entitlement|legal_order|medical|financial|administrative');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `document_date` SET TAGS ('dbx_business_glossary_term' = 'Document Date');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `document_description` SET TAGS ('dbx_business_glossary_term' = 'Document Description');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `document_language` SET TAGS ('dbx_business_glossary_term' = 'Document Language');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `document_language` SET TAGS ('dbx_value_regex' = '^[a-z]{2,3}$');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `document_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Document Reference Number');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `document_reference_number` SET TAGS ('dbx_value_regex' = '^DOC-[A-Z]{2,6}-[0-9]{8,12}$');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `document_status` SET TAGS ('dbx_business_glossary_term' = 'Document Status');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `document_title` SET TAGS ('dbx_business_glossary_term' = 'Document Title');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `document_type` SET TAGS ('dbx_business_glossary_term' = 'Document Type');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Document Effective Date');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Document Expiry Date');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `file_format` SET TAGS ('dbx_business_glossary_term' = 'Document File Format');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `file_size_kb` SET TAGS ('dbx_business_glossary_term' = 'Document File Size (KB)');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `issuing_authority` SET TAGS ('dbx_business_glossary_term' = 'Issuing Authority');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `issuing_country` SET TAGS ('dbx_business_glossary_term' = 'Issuing Country');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `issuing_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `issuing_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Issuing Jurisdiction');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `member_notification_date` SET TAGS ('dbx_business_glossary_term' = 'Member Notification Date');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `member_notified_flag` SET TAGS ('dbx_business_glossary_term' = 'Member Notified Flag');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `notarized_flag` SET TAGS ('dbx_business_glossary_term' = 'Notarized Flag');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `original_document_flag` SET TAGS ('dbx_business_glossary_term' = 'Original Document Flag');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `page_count` SET TAGS ('dbx_business_glossary_term' = 'Document Page Count');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `pension_division_flag` SET TAGS ('dbx_business_glossary_term' = 'Pension Division Flag');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `received_date` SET TAGS ('dbx_business_glossary_term' = 'Document Received Date');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `rejection_reason` SET TAGS ('dbx_business_glossary_term' = 'Document Rejection Reason');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `requires_notarization` SET TAGS ('dbx_business_glossary_term' = 'Notarization Required Flag');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `retention_category` SET TAGS ('dbx_business_glossary_term' = 'Document Retention Category');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `retention_category` SET TAGS ('dbx_value_regex' = 'permanent|long_term|standard|short_term');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `retention_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Retention Expiry Date');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `review_notes` SET TAGS ('dbx_business_glossary_term' = 'Document Review Notes');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `review_notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'SIMCORP|EFRONT|ORACLE|MANUAL|PORTAL|OTHER');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `storage_medium` SET TAGS ('dbx_business_glossary_term' = 'Document Storage Medium');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `storage_medium` SET TAGS ('dbx_value_regex' = 'physical|digital|both');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `submission_channel` SET TAGS ('dbx_business_glossary_term' = 'Document Submission Channel');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `submission_channel` SET TAGS ('dbx_value_regex' = 'mail|in_person|secure_portal|email|fax|third_party_agent');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `translated_flag` SET TAGS ('dbx_business_glossary_term' = 'Translated Document Flag');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `verified_date` SET TAGS ('dbx_business_glossary_term' = 'Document Verified Date');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Document Version Number');
ALTER TABLE `asset_management`.`beneficiary`.`member_document` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` SET TAGS ('dbx_domain' = 'beneficiary');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` SET TAGS ('dbx_subdomain' = 'benefit_disbursement');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `pension_division_order_id` SET TAGS ('dbx_business_glossary_term' = 'Pension Division Order ID');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `designated_beneficiary_id` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary ID');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `contributor_pool_id` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `member_id` SET TAGS ('dbx_business_glossary_term' = 'Beneficiary ID');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `member_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `member_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `pension_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Plan Id (Foreign Key)');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `actuarial_commuted_value` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Commuted Value');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `actuarial_commuted_value` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `actuarial_report_reference` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Report Reference');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `actuarial_valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Actuarial Valuation Date');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `appeal_flag` SET TAGS ('dbx_business_glossary_term' = 'Division Order Appeal Flag');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `appeal_resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Appeal Resolution Date');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `court_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Court Jurisdiction');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `court_jurisdiction` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `court_name` SET TAGS ('dbx_business_glossary_term' = 'Issuing Court Name');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `court_order_date` SET TAGS ('dbx_business_glossary_term' = 'Court Order Date');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `division_amount` SET TAGS ('dbx_business_glossary_term' = 'Division Amount');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `division_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `division_amount` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `division_method` SET TAGS ('dbx_business_glossary_term' = 'Division Method');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `division_method` SET TAGS ('dbx_value_regex' = 'percentage|fixed_amount|actuarial_value|credit_split');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `division_percentage` SET TAGS ('dbx_business_glossary_term' = 'Division Percentage');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `division_percentage` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Division Effective Date');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Division Order Expiry Date');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `former_spouse_date_of_birth` SET TAGS ('dbx_business_glossary_term' = 'Former Spouse Date of Birth');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `former_spouse_date_of_birth` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `former_spouse_date_of_birth` SET TAGS ('dbx_pii_dob' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `former_spouse_full_name` SET TAGS ('dbx_business_glossary_term' = 'Former Spouse Full Legal Name');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `former_spouse_full_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `former_spouse_full_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `former_spouse_gender` SET TAGS ('dbx_business_glossary_term' = 'Former Spouse Gender');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `former_spouse_gender` SET TAGS ('dbx_value_regex' = 'male|female|non_binary|not_disclosed');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `former_spouse_gender` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `former_spouse_gender` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `former_spouse_national_identifier` SET TAGS ('dbx_business_glossary_term' = 'Former Spouse National Identification Number');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `former_spouse_national_identifier` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `former_spouse_national_identifier` SET TAGS ('dbx_pii_national_id' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `implementation_date` SET TAGS ('dbx_business_glossary_term' = 'Implementation Date');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `is_indexation_shared` SET TAGS ('dbx_business_glossary_term' = 'Indexation Shared Indicator');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `is_survivor_benefit_affected` SET TAGS ('dbx_business_glossary_term' = 'Survivor Benefit Affected Indicator');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `legal_counsel_reference` SET TAGS ('dbx_business_glossary_term' = 'Legal Counsel Reference');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `marriage_breakdown_date` SET TAGS ('dbx_business_glossary_term' = 'Marriage Breakdown Date');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `marriage_date` SET TAGS ('dbx_business_glossary_term' = 'Marriage Date');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `order_notes` SET TAGS ('dbx_business_glossary_term' = 'Division Order Notes');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `order_notes` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `order_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Division Order Reference Number');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `order_reference_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `order_status` SET TAGS ('dbx_business_glossary_term' = 'Division Order Status');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `order_status` SET TAGS ('dbx_value_regex' = 'pending|active|implemented|suspended|cancelled|expired');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `order_type` SET TAGS ('dbx_business_glossary_term' = 'Division Order Type');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `order_type` SET TAGS ('dbx_value_regex' = 'equalization_payment|pension_sharing|deferred_division|lump_sum_transfer|annuity_split');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `payment_transfer_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Transfer Date');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `pension_credit_end_date` SET TAGS ('dbx_business_glossary_term' = 'Pension Credit End Date');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `pension_credit_start_date` SET TAGS ('dbx_business_glossary_term' = 'Pension Credit Start Date');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `plan_type` SET TAGS ('dbx_business_glossary_term' = 'Pension Plan Type');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `plan_type` SET TAGS ('dbx_value_regex' = 'defined_benefit|defined_contribution|hybrid');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `source_system_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Code');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `source_system_record_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `transfer_account_reference` SET TAGS ('dbx_business_glossary_term' = 'Transfer Destination Account Reference');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `transfer_account_reference` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `transfer_account_reference` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `transfer_destination_type` SET TAGS ('dbx_business_glossary_term' = 'Transfer Destination Type');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `transfer_destination_type` SET TAGS ('dbx_value_regex' = 'retirement_savings_account|locked_in_retirement_account|locked_in_savings_account|cash_payment|another_pension_plan|other');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `transfer_institution_name` SET TAGS ('dbx_business_glossary_term' = 'Transfer Destination Institution Name');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `transfer_institution_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `withholding_tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Withholding Tax Amount');
ALTER TABLE `asset_management`.`beneficiary`.`pension_division_order` ALTER COLUMN `withholding_tax_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`beneficiary`.`pension_plan` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`beneficiary`.`pension_plan` SET TAGS ('dbx_domain' = 'beneficiary');
ALTER TABLE `asset_management`.`beneficiary`.`pension_plan` SET TAGS ('dbx_division' = 'business');
ALTER TABLE `asset_management`.`beneficiary`.`pension_plan` SET TAGS ('dbx_subdomain' = 'member_administration');
ALTER TABLE `asset_management`.`beneficiary`.`pension_plan` ALTER COLUMN `pension_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Pension Plan Identifier');
