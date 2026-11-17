-- Schema for Domain: shared | Business: Asset Management | Version: v1_ecm
-- Generated on: 2026-11-10 14:17:29

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `asset_management`.`shared` COMMENT 'Cross-domain shared reference entities (currency, UoM, calendar, classification) consolidated for Single Source of Truth (SSOT).';
ALTER SCHEMA `asset_management`.`shared` SET TAGS ('dbx_division' = 'corporate');
ALTER SCHEMA `asset_management`.`shared` SET TAGS ('dbx_domain' = 'shared');

-- ========= TABLES =========
CREATE OR REPLACE TABLE `asset_management`.`shared`.`actor` (
    `actor_id` BIGINT COMMENT 'Primary key for actor',
    `actor_status` STRING COMMENT 'Current lifecycle status of the actor.. Valid values are `active|inactive|pending|suspended`',
    `address_line1` STRING COMMENT 'Primary street address of the actor.',
    `address_line2` STRING COMMENT 'Secondary address information (e.g., suite, floor).',
    `aml_status` STRING COMMENT 'Anti-Money Laundering status of the actor.',
    `city` STRING COMMENT 'City of the actors address.',
    `compliance_status` STRING COMMENT 'Compliance status of the actor with regulatory requirements.',
    `country` STRING COMMENT 'Country of the actors address.',
    `created_at` TIMESTAMP COMMENT 'Timestamp when the actor record was first created.',
    `default_currency` STRING COMMENT 'Preferred currency for transactions.. Valid values are `USD|EUR|GBP|JPY|CHF|CAD`',
    `email` STRING COMMENT 'Primary email address of the actor.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `entity_subtype` STRING COMMENT 'Specific subtype of the actor (e.g., pension fund, private equity manager).',
    `entity_type` STRING COMMENT 'Category of the actor (e.g., individual, organization, fund).. Valid values are `individual|organization|fund|manager|counterparty|investor`',
    `external_system_code` STRING COMMENT 'Identifier used in external systems for the actor.',
    `family_name` STRING COMMENT 'Last name of the actor.',
    `given_name` STRING COMMENT 'First name of the actor.',
    `industry_code` STRING COMMENT 'Industry classification code of the actor.',
    `investment_profile` STRING COMMENT 'Investment style and preferences of the actor.',
    `kyc_status` STRING COMMENT 'Know Your Customer verification status.',
    `last_contact_date` DATE COMMENT 'Date of the most recent contact with the actor.',
    `legal_name` STRING COMMENT 'Full legal name of the actor.',
    `net_income` DECIMAL(18,2) COMMENT 'Annual net income of the actor.',
    `net_worth` DECIMAL(18,2) COMMENT 'Estimated net worth of the actor.',
    `phone` STRING COMMENT 'Primary contact phone number of the actor.. Valid values are `^[+]?d{10,15}$`',
    `postal_code` STRING COMMENT 'Postal code of the actors address.',
    `preferred_contact_method` STRING COMMENT 'Preferred method of contact for the actor.. Valid values are `email|phone|mail|online`',
    `preferred_language` STRING COMMENT 'Preferred language for communication.',
    `registration_number` STRING COMMENT 'Official registration number of the actor.. Valid values are `^[A-Z0-9]{5,20}$`',
    `risk_profile` STRING COMMENT 'Risk tolerance profile of the actor.',
    `sanctions_status` STRING COMMENT 'Sanctions list status of the actor.',
    `sector` STRING COMMENT 'Sector of the actors business activities.',
    `state` STRING COMMENT 'State or province of the actors address.',
    `tax_identifier` STRING COMMENT 'Government-issued tax ID for the actor.. Valid values are `^[0-9]{9}$`',
    `updated_at` TIMESTAMP COMMENT 'Timestamp when the actor record was last updated.',
    CONSTRAINT pk_actor PRIMARY KEY(`actor_id`)
) COMMENT 'Master reference table for actor. ';

CREATE OR REPLACE TABLE `asset_management`.`shared`.`employee` (
    `employee_id` BIGINT COMMENT 'Primary key for employee',
    `actor_id` BIGINT COMMENT 'Foreign key linking to shared.actor. Business justification: Employee is a type of actor; linking via actor_id provides a single source of truth for personal and contact details, enabling normalization and eliminating duplicate data.',
    `department_id` BIGINT COMMENT 'Identifier of the department the employee belongs to.',
    `manager_employee_id` BIGINT COMMENT 'Identifier of the employees direct manager.',
    `bonus` DECIMAL(15,2) COMMENT 'Annual bonus awarded to the employee.',
    `employee_code` STRING COMMENT 'Alphanumeric code used for employee identification in external systems.',
    `date_of_birth` DATE COMMENT 'Date of birth of the employee.',
    `emergency_contact_address_line1` STRING COMMENT 'First line of the emergency contacts address.',
    `emergency_contact_address_line2` STRING COMMENT 'Second line of the emergency contacts address.',
    `emergency_contact_city` STRING COMMENT 'City component of the emergency contacts address.',
    `emergency_contact_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the emergency contacts residence.. Valid values are `^[A-Z]{3}$`',
    `emergency_contact_email` STRING COMMENT 'Email address of the employees emergency contact.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `emergency_contact_name` STRING COMMENT 'Name of the employees emergency contact.',
    `emergency_contact_phone` STRING COMMENT 'Phone number of the employees emergency contact.. Valid values are `^+?[0-9]{7,15}$`',
    `emergency_contact_postal_code` STRING COMMENT 'Postal or ZIP code of the emergency contacts address.. Valid values are `^[A-Z0-9- ]{3,10}$`',
    `emergency_contact_relationship` STRING COMMENT 'Relationship of the emergency contact to the employee.. Valid values are `parent|spouse|sibling|friend|other`',
    `emergency_contact_state` STRING COMMENT 'State or province component of the emergency contacts address.',
    `employment_end_date` DATE COMMENT 'Date when the employees employment ended, if applicable.',
    `employment_start_date` DATE COMMENT 'Date when the employee commenced employment.',
    `employment_status` STRING COMMENT 'Current employment status of the employee.. Valid values are `active|inactive|terminated|on_leave|retired`',
    `employment_type` STRING COMMENT 'Classification of employment arrangement.. Valid values are `full_time|part_time|contractor|consultant|intern|temporary`',
    `gender` STRING COMMENT 'Gender of the employee.. Valid values are `male|female|non-binary|other`',
    `job_level` STRING COMMENT 'Hierarchical level of the employee within the organization. [ENUM-REF-CANDIDATE: junior|mid|senior|lead|director|vp|c-level — 7 candidates stripped; promote to reference product]',
    `job_title` STRING COMMENT 'Official job title of the employee.',
    `marital_status` STRING COMMENT 'Marital status of the employee.. Valid values are `single|married|divorced|widowed|separated`',
    `national_identifier` STRING COMMENT 'National identification number of the employee.',
    `number` STRING COMMENT 'Internal employee number assigned by the organization.',
    `payroll_account_number` STRING COMMENT 'Bank account number for direct deposit of employee salary.',
    `payroll_bank_bic` STRING COMMENT 'Bank Identifier Code for employee payroll account.',
    `payroll_bank_iban` STRING COMMENT 'International Bank Account Number for employee payroll account.',
    `payroll_bank_name` STRING COMMENT 'Name of the bank where the employees payroll account is held.',
    `payroll_frequency` STRING COMMENT 'Frequency of payroll disbursement.. Valid values are `weekly|biweekly|monthly|quarterly|annually`',
    `record_audit_created` TIMESTAMP COMMENT 'Timestamp when the employee record was first created.',
    `record_audit_updated` TIMESTAMP COMMENT 'Timestamp when the employee record was last updated.',
    `salary` DECIMAL(15,2) COMMENT 'Base annual salary of the employee.',
    `salary_currency` STRING COMMENT 'Currency code for the employees salary.. Valid values are `USD|EUR|GBP|CAD|AUD|JPY`',
    `ssn` STRING COMMENT 'Social Security Number of the employee.',
    CONSTRAINT pk_employee PRIMARY KEY(`employee_id`)
) COMMENT 'Master reference table for employee. ';

CREATE OR REPLACE TABLE `asset_management`.`shared`.`legal_entity` (
    `legal_entity_id` BIGINT COMMENT 'Primary key for legal_entity',
    `parent_entity_id` BIGINT COMMENT 'Reference to the immediate parent legal entity in the corporate ownership hierarchy.',
    `ultimate_parent_entity_id` BIGINT COMMENT 'Reference to the ultimate parent legal entity at the top of the corporate ownership chain.',
    `aml_risk_rating` STRING COMMENT 'Risk rating assigned for anti-money laundering compliance and monitoring purposes.',
    `base_currency_code` STRING COMMENT 'ISO 4217 three-letter code for the primary operating currency of the entity.',
    `counterparty_classification` STRING COMMENT 'Classification of the entity role in investment operations for risk management and reporting.',
    `credit_rating` STRING COMMENT 'Current credit rating assigned by major rating agencies for counterparty risk assessment.',
    `credit_rating_agency` STRING COMMENT 'Name of the rating agency that assigned the current credit rating.',
    `credit_rating_date` DATE COMMENT 'Date when the current credit rating was assigned or last updated.',
    `effective_from_date` DATE COMMENT 'Date from which this legal entity record becomes effective in the system.',
    `effective_to_date` DATE COMMENT 'Date until which this legal entity record remains effective, null if currently active.',
    `entity_status` STRING COMMENT 'Current operational status of the legal entity within the investment management ecosystem.',
    `entity_type` STRING COMMENT 'Classification of the legal structure of the entity for regulatory and operational purposes.',
    `esg_rating` STRING COMMENT 'Current ESG rating for responsible investment screening and sustainability assessment.',
    `esg_rating_provider` STRING COMMENT 'Name of the provider that assigned the current ESG rating.',
    `fiscal_year_end_month` BIGINT COMMENT 'Month number (1-12) when the entity fiscal year ends for financial reporting purposes.',
    `gics_code` STRING COMMENT 'Eight-digit GICS code for standardized industry classification in investment analysis.',
    `incorporation_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code where the entity is legally incorporated or registered.',
    `incorporation_date` DATE COMMENT 'Date when the legal entity was officially incorporated or registered with authorities.',
    `industry_sector` STRING COMMENT 'Primary industry sector classification of the entity for investment analysis and reporting.',
    `is_broker_dealer` BOOLEAN COMMENT 'Indicates whether the entity is registered as a broker-dealer for securities transactions.',
    `is_custodian` BOOLEAN COMMENT 'Indicates whether the entity provides custodial services for investment assets.',
    `is_internal_entity` BOOLEAN COMMENT 'Indicates whether the entity is part of the pension fund internal corporate structure.',
    `is_investment_manager` BOOLEAN COMMENT 'Indicates whether the entity operates as an investment manager or asset manager.',
    `is_issuer` BOOLEAN COMMENT 'Indicates whether the entity issues securities or investment instruments.',
    `kyc_expiry_date` DATE COMMENT 'Date when the current KYC verification expires and requires renewal.',
    `kyc_status` STRING COMMENT 'Current status of Know Your Customer due diligence verification for the entity.',
    `kyc_verification_date` DATE COMMENT 'Date when the most recent KYC verification was completed.',
    `legal_name` STRING COMMENT 'Official registered legal name of the entity as filed with regulatory authorities.',
    `lei_code` STRING COMMENT '20-character alphanumeric code assigned by GLEIF for global identification of legal entities in financial transactions.',
    `ownership_percentage` DECIMAL(5,2) COMMENT 'Percentage of ownership held by the parent entity, used for consolidation and control assessment.',
    `primary_contact_email` STRING COMMENT 'Primary email address for official communications with the legal entity.',
    `primary_contact_phone` STRING COMMENT 'Primary telephone number for official communications with the legal entity.',
    `primary_regulator` STRING COMMENT 'Name of the primary financial regulatory authority overseeing the entity.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this legal entity record was first created in the system.',
    `registered_address_line_1` STRING COMMENT 'First line of the official registered address of the legal entity.',
    `registered_address_line_2` STRING COMMENT 'Second line of the official registered address for additional location details.',
    `registered_city` STRING COMMENT 'City of the official registered address of the legal entity.',
    `registered_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the registered address location.',
    `registered_postal_code` STRING COMMENT 'Postal or ZIP code of the official registered address.',
    `registration_number` STRING COMMENT 'Official company registration number assigned by the incorporation authority.',
    `regulatory_status` STRING COMMENT 'Current regulatory standing of the entity with relevant financial supervisory authorities.',
    `short_name` STRING COMMENT 'Abbreviated or commonly used short name for the entity in internal systems and reports.',
    `tax_identification_number` STRING COMMENT 'Government-issued tax identification number for the entity in its primary tax jurisdiction.',
    `tax_jurisdiction_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the primary tax jurisdiction for the entity.',
    `trading_name` STRING COMMENT 'Commercial or trading name under which the entity conducts business, may differ from legal name.',
    `website_url` STRING COMMENT 'Official website address of the legal entity.',
    CONSTRAINT pk_legal_entity PRIMARY KEY(`legal_entity_id`)
) COMMENT 'Master reference table for legal_entity. Referenced by legal_entity_id.';

CREATE OR REPLACE TABLE `asset_management`.`shared`.`document` (
    `document_id` BIGINT COMMENT 'Primary key for document',
    `approval_date` DATE COMMENT 'Date when the document received formal approval for publication or distribution.',
    `approver_name` STRING COMMENT 'Name of the individual who approved the document for publication or distribution.',
    `archive_date` DATE COMMENT 'Date when the document was moved to archival storage.',
    `author_name` STRING COMMENT 'Name of the individual or team who authored or created the document.',
    `document_category` STRING COMMENT 'Business domain category indicating the functional area to which the document relates.',
    `checksum_hash` STRING COMMENT 'SHA-256 hash value of the document content for integrity verification and tamper detection.',
    `document_description` STRING COMMENT 'Detailed narrative description of the document content, purpose, and context for discovery and retrieval.',
    `effective_date` DATE COMMENT 'Date from which the document becomes effective or binding for business purposes.',
    `expiration_date` DATE COMMENT 'Date on which the document expires or is no longer valid for business use. Null for documents with no expiration.',
    `external_reference_code` STRING COMMENT 'External system reference identifier used to link the document to counterparty or third-party systems.',
    `file_format` STRING COMMENT 'File format or extension indicating the technical format of the stored document.',
    `file_size_bytes` BIGINT COMMENT 'Size of the document file in bytes for storage management and transfer planning.',
    `is_archived` BOOLEAN COMMENT 'Boolean flag indicating whether the document has been moved to archival storage.',
    `is_confidential` BOOLEAN COMMENT 'Boolean flag indicating whether the document contains confidential or sensitive information requiring restricted access.',
    `is_legally_binding` BOOLEAN COMMENT 'Boolean flag indicating whether the document has legal or contractual binding effect.',
    `is_regulatory_required` BOOLEAN COMMENT 'Boolean flag indicating whether the document is required for regulatory compliance or reporting purposes.',
    `keywords` STRING COMMENT 'Comma-separated list of keywords or tags for document search and discovery purposes.',
    `language_code` STRING COMMENT 'ISO 639-1 language code indicating the primary language of the document content.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the document content or metadata.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next periodic review of the document content and applicability.',
    `owner_department` STRING COMMENT 'Business department or organizational unit responsible for maintaining and governing the document.',
    `reference_number` STRING COMMENT 'Externally-known business reference number used to identify the document across systems and in correspondence with counterparties.',
    `retention_end_date` DATE COMMENT 'Calculated date when the document retention period expires and the document may be disposed.',
    `retention_period_years` BIGINT COMMENT 'Number of years the document must be retained per regulatory or business retention policies.',
    `review_frequency_months` BIGINT COMMENT 'Number of months between required periodic reviews of the document for accuracy and relevance.',
    `security_classification` STRING COMMENT 'Data classification level indicating the sensitivity and access restrictions for the document.',
    `source_system` STRING COMMENT 'Name or identifier of the originating system from which the document was ingested or created.',
    `document_status` STRING COMMENT 'Current state of the document within its lifecycle from creation through archival or supersession.',
    `storage_location` STRING COMMENT 'Logical or physical storage path indicating where the document is stored in the document management system.',
    `title` STRING COMMENT 'Human-readable title or name of the document describing its content or purpose.',
    `document_type` STRING COMMENT 'Primary classification of the document by its functional purpose within the organization.',
    `version_number` STRING COMMENT 'Version identifier indicating the revision level of the document in major.minor format.',
    `creation_date` DATE COMMENT 'Date when the document was originally created or authored.',
    CONSTRAINT pk_document PRIMARY KEY(`document_id`)
) COMMENT 'Master reference table for document. Referenced by confirmation_document_id.';

CREATE OR REPLACE TABLE `asset_management`.`shared`.`fund_administrator` (
    `fund_administrator_id` BIGINT COMMENT 'Primary key for fund_administrator',
    `administrator_type` STRING COMMENT 'Classification of the fund administrator based on the scope of services provided to investment funds.',
    `aum_reporting_date` DATE COMMENT 'The as-of date for the reported assets under administration figure.',
    `aum_usd` DECIMAL(18,2) COMMENT 'Total assets under administration by the fund administrator, expressed in US dollars for comparability.',
    `credit_rating` STRING COMMENT 'The current credit rating assigned by major rating agencies to the fund administrator or parent company.',
    `credit_rating_agency` STRING COMMENT 'The name of the credit rating agency that assigned the current credit rating.',
    `domicile_country_code` STRING COMMENT 'The ISO 3166-1 alpha-3 country code representing the legal domicile jurisdiction of the fund administrator.',
    `due_diligence_rating` STRING COMMENT 'The overall rating assigned following the most recent operational due diligence review.',
    `employee_count` BIGINT COMMENT 'The total number of employees at the fund administrator organization.',
    `giin` STRING COMMENT 'The 19-character identifier assigned by the IRS for FATCA reporting purposes to identify participating foreign financial institutions.',
    `headquarters_address` STRING COMMENT 'The full street address of the fund administrators global headquarters location.',
    `headquarters_city` STRING COMMENT 'The city where the fund administrators global headquarters is located.',
    `headquarters_country_code` STRING COMMENT 'The ISO 3166-1 alpha-3 country code for the fund administrators headquarters location.',
    `incorporation_date` DATE COMMENT 'The date when the fund administrator entity was legally incorporated or established.',
    `is_publicly_traded` BOOLEAN COMMENT 'Indicates whether the fund administrator or its parent company is publicly traded on a stock exchange.',
    `isae3402_certified` BOOLEAN COMMENT 'Indicates whether the fund administrator holds current ISAE 3402 Type II certification for service organizations.',
    `iso27001_certified` BOOLEAN COMMENT 'Indicates whether the fund administrator holds current ISO 27001 certification for information security management.',
    `last_due_diligence_date` DATE COMMENT 'The date of the most recent operational due diligence review conducted by the pension fund on this administrator.',
    `legal_name` STRING COMMENT 'The official registered legal name of the fund administrator as it appears in regulatory filings and contracts.',
    `lei_code` STRING COMMENT 'The 20-character alphanumeric Legal Entity Identifier assigned by a Local Operating Unit under the Global LEI System.',
    `next_due_diligence_date` DATE COMMENT 'The scheduled date for the next operational due diligence review of this fund administrator.',
    `notes` STRING COMMENT 'Free-text field for additional notes or comments about the fund administrator relationship.',
    `number_of_funds_serviced` BIGINT COMMENT 'The total count of investment funds currently serviced by the fund administrator globally.',
    `parent_company_name` STRING COMMENT 'The name of the parent company or ultimate holding company if the fund administrator is a subsidiary.',
    `primary_contact_email` STRING COMMENT 'The email address of the primary relationship contact at the fund administrator.',
    `primary_contact_name` STRING COMMENT 'The name of the primary relationship contact person at the fund administrator for the pension fund.',
    `primary_contact_phone` STRING COMMENT 'The direct phone number of the primary relationship contact at the fund administrator.',
    `primary_regulator` STRING COMMENT 'Name of the primary financial regulatory authority that oversees the fund administrators operations.',
    `record_created_timestamp` TIMESTAMP COMMENT 'The timestamp when this fund administrator record was first created in the system.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this fund administrator record was last modified in the system.',
    `registration_date` DATE COMMENT 'The date when the fund administrator was officially registered with the primary regulatory authority.',
    `registration_number` STRING COMMENT 'The official registration or license number assigned by the primary regulatory authority.',
    `regulatory_jurisdiction` STRING COMMENT 'The primary regulatory jurisdiction under which the fund administrator operates and is licensed.',
    `relationship_end_date` DATE COMMENT 'The date when the relationship with this fund administrator was terminated, if applicable.',
    `relationship_start_date` DATE COMMENT 'The date when the pension fund first engaged this fund administrator for services.',
    `service_tier` STRING COMMENT 'Classification of the administrator based on assets under administration, global reach, and service capabilities.',
    `soc1_certified` BOOLEAN COMMENT 'Indicates whether the fund administrator holds a current SOC 1 Type II certification for internal controls.',
    `soc2_certified` BOOLEAN COMMENT 'Indicates whether the fund administrator holds a current SOC 2 Type II certification for security controls.',
    `fund_administrator_status` STRING COMMENT 'Current operational status of the fund administrator relationship with the pension fund.',
    `stock_ticker` STRING COMMENT 'The stock exchange ticker symbol if the fund administrator or parent company is publicly traded.',
    `termination_reason` STRING COMMENT 'The reason for terminating the relationship with the fund administrator, if the relationship has ended.',
    `trading_name` STRING COMMENT 'The commercial or trading name under which the fund administrator operates in the market, may differ from legal name.',
    `website_url` STRING COMMENT 'The official corporate website URL of the fund administrator.',
    `year_established` BIGINT COMMENT 'The calendar year when the fund administrator commenced operations in the fund administration business.',
    CONSTRAINT pk_fund_administrator PRIMARY KEY(`fund_administrator_id`)
) COMMENT 'Master reference table for fund_administrator. Referenced by administrator_id.';

CREATE OR REPLACE TABLE `asset_management`.`shared`.`vendor` (
    `vendor_id` BIGINT COMMENT 'Primary key for vendor',
    `bank_account_name` STRING COMMENT 'The name on the vendors bank account used for receiving payments.',
    `bank_account_number` STRING COMMENT 'The vendors bank account number for payment processing purposes.',
    `bank_swift_code` STRING COMMENT 'The SWIFT/BIC code identifying the vendors bank for international wire transfers.',
    `vendor_category` STRING COMMENT 'Broad functional category indicating the business area the vendor primarily supports.',
    `country_of_incorporation` STRING COMMENT 'The ISO 3166-1 alpha-3 country code where the vendor is legally incorporated or registered.',
    `criticality_tier` STRING COMMENT 'Risk-based classification indicating the vendors importance to business operations and continuity.',
    `diversity_certification_type` STRING COMMENT 'The type of diversity certification held by the vendor, if any, such as MBE, WBE, DVBE, or similar.',
    `due_diligence_status` STRING COMMENT 'Current status of the vendor due diligence review process required for onboarding and periodic renewal.',
    `esg_rating` STRING COMMENT 'The ESG rating assigned to the vendor based on environmental, social, and governance assessment criteria.',
    `headquarters_address` STRING COMMENT 'The full street address of the vendors principal place of business or corporate headquarters.',
    `headquarters_city` STRING COMMENT 'The city where the vendors corporate headquarters is located.',
    `headquarters_country` STRING COMMENT 'The ISO 3166-1 alpha-3 country code where the vendors headquarters is physically located.',
    `is_minority_owned` BOOLEAN COMMENT 'Indicates whether the vendor is certified as a minority-owned business enterprise for diversity tracking.',
    `is_women_owned` BOOLEAN COMMENT 'Indicates whether the vendor is certified as a women-owned business enterprise for diversity tracking.',
    `last_due_diligence_date` DATE COMMENT 'The date when the most recent due diligence review of the vendor was completed.',
    `legal_entity_identifier` STRING COMMENT 'The 20-character ISO 17442 Legal Entity Identifier assigned to the vendor for regulatory reporting purposes.',
    `vendor_name` STRING COMMENT 'The official registered legal name of the vendor organization as it appears on contracts and legal documents.',
    `next_due_diligence_date` DATE COMMENT 'The scheduled date for the next periodic due diligence review of the vendor.',
    `notes` STRING COMMENT 'Free-form notes and comments about the vendor for internal reference and relationship management.',
    `onboarding_date` DATE COMMENT 'The date when the vendor was formally onboarded and approved for use by the organization.',
    `payment_currency` STRING COMMENT 'The ISO 4217 three-letter currency code in which the vendor prefers to receive payments.',
    `payment_terms_days` BIGINT COMMENT 'The standard number of days from invoice date within which payment is due to the vendor.',
    `postal_code` STRING COMMENT 'The postal or ZIP code for the vendors headquarters address.',
    `primary_contact_email` STRING COMMENT 'The email address of the designated primary contact person at the vendor.',
    `primary_contact_name` STRING COMMENT 'The name of the designated primary contact person at the vendor organization for relationship management.',
    `primary_contact_phone` STRING COMMENT 'The direct telephone number of the designated primary contact person at the vendor.',
    `primary_email` STRING COMMENT 'The main email address for general business correspondence with the vendor organization.',
    `primary_phone` STRING COMMENT 'The main telephone number for contacting the vendor organization.',
    `registration_number` STRING COMMENT 'The official company registration or incorporation number issued by the vendors home jurisdiction.',
    `risk_rating` STRING COMMENT 'Overall risk assessment rating assigned to the vendor based on due diligence and ongoing monitoring.',
    `vendor_status` STRING COMMENT 'Current operational status of the vendor relationship indicating whether they can be engaged for services.',
    `tax_identification_number` STRING COMMENT 'The tax registration number assigned by the relevant tax authority in the vendors jurisdiction of incorporation.',
    `termination_date` DATE COMMENT 'The date when the vendor relationship was terminated, if applicable.',
    `termination_reason` STRING COMMENT 'The documented reason for terminating the vendor relationship, if applicable.',
    `trading_name` STRING COMMENT 'The commercial or trading name under which the vendor conducts business, if different from the legal name.',
    `vendor_type` STRING COMMENT 'Classification of the vendor by the nature of goods or services provided to the pension fund.',
    `website_url` STRING COMMENT 'The official corporate website address of the vendor.',
    CONSTRAINT pk_vendor PRIMARY KEY(`vendor_id`)
) COMMENT 'Master reference table for vendor. Referenced by vendor_id.';

CREATE OR REPLACE TABLE `asset_management`.`shared`.`auditor` (
    `auditor_id` BIGINT COMMENT 'Primary key for auditor',
    `approved_for_fund_audit_flag` BOOLEAN COMMENT 'Indicates whether the auditor is approved to conduct audits of the pension funds investment vehicles.',
    `approved_for_manager_audit_flag` BOOLEAN COMMENT 'Indicates whether the auditor is approved to audit external fund managers on behalf of the pension fund.',
    `auditor_type` STRING COMMENT 'Classification of the auditor based on firm size and market position within the audit industry.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the auditor record was first created in the system.',
    `employee_count` BIGINT COMMENT 'Total number of employees at the auditing firm, indicating firm capacity and scale.',
    `engagement_end_date` DATE COMMENT 'Date when the auditor relationship with the pension fund ended or is scheduled to end.',
    `engagement_start_date` DATE COMMENT 'Date when the auditor relationship with the pension fund commenced.',
    `esg_audit_capability_flag` BOOLEAN COMMENT 'Indicates whether the auditor has capability to perform ESG-related assurance engagements.',
    `global_network_affiliation` STRING COMMENT 'Name of the global audit network or alliance the auditor is affiliated with (e.g., Deloitte, PwC, BDO).',
    `headquarters_address` STRING COMMENT 'Full street address of the auditor firms headquarters or principal place of business.',
    `headquarters_city` STRING COMMENT 'City where the auditor firms headquarters is located.',
    `headquarters_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code for the auditor firms headquarters location.',
    `independence_review_date` DATE COMMENT 'Date of the most recent independence assessment conducted for this auditor relationship.',
    `independence_status` STRING COMMENT 'Current independence status of the auditor with respect to the pension fund per regulatory requirements.',
    `inspection_result` STRING COMMENT 'Outcome of the most recent regulatory inspection of the auditor.',
    `insurance_expiry_date` DATE COMMENT 'Expiration date of the auditors professional liability insurance policy.',
    `jurisdiction_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the primary regulatory jurisdiction governing the auditor.',
    `last_inspection_date` DATE COMMENT 'Date of the most recent regulatory inspection of the auditor by oversight bodies.',
    `legal_entity_name` STRING COMMENT 'The full legal entity name as registered with regulatory authorities and corporate registries.',
    `lei_code` STRING COMMENT 'The 20-character Legal Entity Identifier assigned by a Local Operating Unit for global identification.',
    `auditor_name` STRING COMMENT 'The official registered name of the auditing firm or individual auditor.',
    `notes` STRING COMMENT 'Free-text notes and comments regarding the auditor relationship or special considerations.',
    `partner_count` BIGINT COMMENT 'Number of partners at the auditing firm, indicating firm seniority depth.',
    `pcaob_registered_flag` BOOLEAN COMMENT 'Indicates whether the auditor is registered with the PCAOB for US public company audits.',
    `primary_contact_email` STRING COMMENT 'Email address of the primary contact person for audit-related communications.',
    `primary_contact_name` STRING COMMENT 'Name of the primary contact person at the auditing firm responsible for the pension fund engagement.',
    `primary_contact_phone` STRING COMMENT 'Phone number of the primary contact person at the auditing firm.',
    `professional_liability_coverage_amount` DECIMAL(18,2) COMMENT 'Amount of professional liability insurance coverage maintained by the auditor in base currency.',
    `professional_liability_currency_code` STRING COMMENT 'ISO 4217 currency code for the professional liability coverage amount.',
    `quality_rating` STRING COMMENT 'Internal quality rating assigned to the auditor based on performance assessments.',
    `registration_number` STRING COMMENT 'The unique registration number assigned by the primary regulatory body (e.g., PCAOB, FRC).',
    `regulatory_body` STRING COMMENT 'Name of the primary regulatory body overseeing the auditor (e.g., PCAOB, FRC, ASIC).',
    `rotation_due_date` DATE COMMENT 'Date by which mandatory auditor rotation must occur per regulatory requirements.',
    `service_offering` STRING COMMENT 'Types of audit and assurance services offered (e.g., financial statement audit, SOC 1, SOC 2, ISAE 3402).',
    `specialization_area` STRING COMMENT 'Primary area of audit specialization relevant to institutional asset management (e.g., pension funds, investment management, financial services).',
    `auditor_status` STRING COMMENT 'Current operational status of the auditor relationship with the pension fund.',
    `tax_identification_number` STRING COMMENT 'Tax identification number of the auditing firm for invoicing and regulatory purposes.',
    `tenure_years` BIGINT COMMENT 'Number of consecutive years the auditor has served the pension fund, relevant for rotation compliance.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the auditor record was last modified.',
    `website_url` STRING COMMENT 'Official website URL of the auditing firm.',
    CONSTRAINT pk_auditor PRIMARY KEY(`auditor_id`)
) COMMENT 'Master reference table for auditor. Referenced by auditor_id.';

CREATE OR REPLACE TABLE `asset_management`.`shared`.`contract` (
    `contract_id` BIGINT COMMENT 'Primary key for contract',
    `counterparty_legal_entity_id` BIGINT COMMENT 'Reference to the external party (fund manager, custodian, broker) with whom the contract is established.',
    `fund_id` BIGINT COMMENT 'Reference to the specific investment fund or portfolio governed by this contract.',
    `legal_entity_id` BIGINT COMMENT 'Reference to the internal legal entity that is party to this contract on behalf of the pension fund.',
    `parent_contract_id` BIGINT COMMENT 'Reference to the master or parent contract if this is a sub-agreement, amendment, or schedule.',
    `arbitration_venue` STRING COMMENT 'City or institution designated for arbitration proceedings if disputes arise.',
    `audit_rights_indicator` BOOLEAN COMMENT 'Indicates whether the contract grants the pension fund rights to audit the counterparty.',
    `contract_category` STRING COMMENT 'Hierarchical classification indicating whether this is a master agreement, sub-agreement, or supporting document.',
    `co_investment_rights` STRING COMMENT 'Type of co-investment rights granted to the investor under this contract.',
    `confidentiality_level` STRING COMMENT 'Level of confidentiality obligations imposed by the contract on information sharing.',
    `contract_number` STRING COMMENT 'Externally-facing unique business identifier assigned to the contract for reference in correspondence and legal documents.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when the contract record was first created in the database.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for monetary values and fee calculations under this contract.',
    `dispute_resolution_method` STRING COMMENT 'Contractually agreed mechanism for resolving disputes between parties.',
    `document_storage_path` STRING COMMENT 'File system or document management system path where the executed contract document is stored.',
    `effective_date` DATE COMMENT 'Date on which the contract terms become legally binding and enforceable.',
    `esg_compliance_required` BOOLEAN COMMENT 'Indicates whether the contract mandates adherence to ESG investment principles and reporting.',
    `execution_date` DATE COMMENT 'Date on which all parties formally signed and executed the contract.',
    `expiration_date` DATE COMMENT 'Date on which the contract naturally expires unless renewed or terminated earlier. Null for evergreen contracts.',
    `fee_calculation_basis` STRING COMMENT 'Basis on which management fees are calculated under the contract terms.',
    `governing_law_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code indicating the jurisdiction whose laws govern contract interpretation.',
    `hurdle_rate` DECIMAL(8,6) COMMENT 'Minimum return threshold that must be achieved before performance fees are payable.',
    `internal_owner_name` STRING COMMENT 'Name of the internal team member or department responsible for managing this contract.',
    `is_auto_renewal` BOOLEAN COMMENT 'Indicates whether the contract includes automatic renewal provisions for successive terms.',
    `is_evergreen` BOOLEAN COMMENT 'Indicates whether the contract automatically renews unless explicitly terminated by either party.',
    `management_fee_rate` DECIMAL(8,6) COMMENT 'Annual management fee rate expressed as a decimal (e.g., 0.015 for 1.5%) charged under this contract.',
    `mfn_clause_indicator` BOOLEAN COMMENT 'Indicates whether the contract includes a most favored nation clause entitling the investor to best terms.',
    `contract_name` STRING COMMENT 'Descriptive name or title of the contract used for identification and reporting purposes.',
    `notes` STRING COMMENT 'Free-text field for additional context, special provisions, or internal commentary about the contract.',
    `notice_period_days` BIGINT COMMENT 'Number of days advance notice required for termination or non-renewal of the contract.',
    `performance_fee_rate` DECIMAL(8,6) COMMENT 'Carried interest or performance fee rate expressed as a decimal charged on returns above hurdle.',
    `renewal_date` DATE COMMENT 'Date by which renewal notice must be provided or automatic renewal occurs.',
    `reporting_frequency` STRING COMMENT 'Frequency at which the counterparty must provide performance and financial reports.',
    `contract_status` STRING COMMENT 'Current lifecycle state of the contract indicating its operational validity and enforceability.',
    `termination_date` DATE COMMENT 'Actual date the contract was terminated, if applicable. Distinct from scheduled expiration.',
    `total_commitment_amount` DECIMAL(18,2) COMMENT 'Total capital commitment or notional value governed by this contract in the contract currency.',
    `contract_type` STRING COMMENT 'Classification of the contract by its primary purpose and legal structure within institutional asset management.',
    `version_number` BIGINT COMMENT 'Sequential version number tracking amendments and revisions to the contract terms.',
    CONSTRAINT pk_contract PRIMARY KEY(`contract_id`)
) COMMENT 'Master reference table for contract. Referenced by contract_id.';

CREATE OR REPLACE TABLE `asset_management`.`shared`.`contractor` (
    `contractor_id` BIGINT COMMENT 'Primary key for contractor',
    `address_line_1` STRING COMMENT 'Primary street address or first line of the contractors registered address.',
    `address_line_2` STRING COMMENT 'Secondary address line for suite, unit, or additional location details.',
    `bank_account_number` STRING COMMENT 'Bank account number for contractor payment disbursements.',
    `bank_routing_code` STRING COMMENT 'Bank routing number, SWIFT code, or sort code for payment processing.',
    `city` STRING COMMENT 'City or municipality of the contractors registered address.',
    `country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the contractors registered address.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the contractor record was first created in the system.',
    `engagement_end_date` DATE COMMENT 'Date when the contractor relationship ended or is scheduled to end. Null if ongoing.',
    `engagement_start_date` DATE COMMENT 'Date when the contractor relationship was first established with the organization.',
    `esg_compliance_certified` BOOLEAN COMMENT 'Indicates whether the contractor meets ESG compliance standards required by the pension fund.',
    `external_reference_code` STRING COMMENT 'External or legacy system identifier for the contractor used for cross-system reconciliation.',
    `insurance_expiry_date` DATE COMMENT 'Expiration date of the contractors professional liability insurance coverage.',
    `insurance_policy_number` STRING COMMENT 'Professional liability or indemnity insurance policy number held by the contractor.',
    `is_approved_for_sensitive_work` BOOLEAN COMMENT 'Indicates whether the contractor has been vetted and approved for sensitive or confidential work.',
    `is_preferred_vendor` BOOLEAN COMMENT 'Indicates whether the contractor is designated as a preferred vendor for procurement.',
    `kyc_verification_date` DATE COMMENT 'Date when the most recent KYC verification was completed.',
    `kyc_verification_status` STRING COMMENT 'Status of Know Your Customer verification for anti-money laundering compliance.',
    `legal_entity_name` STRING COMMENT 'Official corporate or business entity name as registered with authorities.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the contractor record was last modified.',
    `contractor_name` STRING COMMENT 'Legal registered name of the contractor individual or entity.',
    `notes` STRING COMMENT 'Free-text notes or comments about the contractor for internal reference.',
    `payment_currency` STRING COMMENT 'ISO 4217 three-letter currency code for contractor payments.',
    `payment_terms_days` BIGINT COMMENT 'Standard payment terms in days from invoice date for contractor payments.',
    `postal_code` STRING COMMENT 'Postal or ZIP code of the contractors registered address.',
    `primary_email` STRING COMMENT 'Primary email address for contractor communications and notifications.',
    `primary_phone` STRING COMMENT 'Primary contact phone number for the contractor.',
    `registration_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code where the contractor is legally registered.',
    `registration_number` STRING COMMENT 'Official business or company registration number issued by incorporation authority.',
    `security_clearance_level` STRING COMMENT 'Level of security clearance held by the contractor for accessing sensitive information.',
    `service_category` STRING COMMENT 'Primary category of services provided by the contractor (e.g., consulting, technology, legal).',
    `specialization` STRING COMMENT 'Specific area of expertise or specialization within the contractors service category.',
    `state_province` STRING COMMENT 'State, province, or administrative region of the contractors address.',
    `contractor_status` STRING COMMENT 'Current lifecycle status of the contractor relationship.',
    `tax_identification_number` STRING COMMENT 'Government-issued tax identification number for the contractor.',
    `tax_jurisdiction_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the contractors primary tax jurisdiction.',
    `trading_name` STRING COMMENT 'Business trading name or doing-business-as (DBA) name if different from legal name.',
    `contractor_type` STRING COMMENT 'Classification of the contractor entity structure.',
    CONSTRAINT pk_contractor PRIMARY KEY(`contractor_id`)
) COMMENT 'Master reference table for contractor. Referenced by contractor_id.';

CREATE OR REPLACE TABLE `asset_management`.`shared`.`department` (
    `department_id` BIGINT COMMENT 'Primary key for department',
    `legal_entity_id` BIGINT COMMENT 'Reference to the legal entity under which this department operates for regulatory and reporting purposes.',
    `parent_department_id` BIGINT COMMENT 'Reference to the parent department in the organizational hierarchy. Null for top-level departments.',
    `annual_operating_budget` DECIMAL(18,2) COMMENT 'Total annual operating budget allocated to the department in the base reporting currency.',
    `asset_class_focus` STRING COMMENT 'Primary asset class focus for investment-related departments. Null for non-investment departments.',
    `budget_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the departments budget denomination.',
    `department_code` STRING COMMENT 'Short alphanumeric code uniquely identifying the department for internal reference and system integration.',
    `cost_center_code` STRING COMMENT 'Financial cost center code assigned to the department for budget allocation and expense tracking.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the department record was first created in the system.',
    `department_description` STRING COMMENT 'Detailed description of the departments purpose, responsibilities, and scope within the organization.',
    `dissolution_date` DATE COMMENT 'Date when the department was dissolved or merged. Null if the department is still active.',
    `effective_from_date` DATE COMMENT 'Date from which the current department configuration became effective.',
    `effective_to_date` DATE COMMENT 'Date until which the current department configuration is effective. Null for currently active configurations.',
    `establishment_date` DATE COMMENT 'Date when the department was officially established or created within the organization.',
    `external_reporting_code` STRING COMMENT 'Code used for external regulatory or statutory reporting purposes to identify the department.',
    `functional_area` STRING COMMENT 'Primary functional area the department belongs to within the pension fund organization. [ENUM-REF-CANDIDATE: investments|operations|risk|compliance|finance|technology|hr|legal|audit|strategy — promote to reference product]',
    `gl_account_segment` STRING COMMENT 'General ledger account segment code used for financial reporting and journal entry allocation.',
    `head_employee_id` BIGINT COMMENT 'Reference to the employee who serves as the head or director of the department.',
    `headcount_budget` BIGINT COMMENT 'Approved number of full-time equivalent positions budgeted for the department.',
    `hierarchy_level` BIGINT COMMENT 'Numeric level in the organizational hierarchy where 1 represents the top-level department.',
    `hierarchy_path` STRING COMMENT 'Full path from root to this department in the organizational tree, typically slash-delimited.',
    `is_active` BOOLEAN COMMENT 'Indicates whether the department is currently active and operational.',
    `is_investment_team` BOOLEAN COMMENT 'Indicates whether the department is directly involved in investment decision-making activities.',
    `is_regulated` BOOLEAN COMMENT 'Indicates whether the department is subject to specific regulatory oversight or licensing requirements.',
    `is_revenue_generating` BOOLEAN COMMENT 'Indicates whether the department directly contributes to revenue generation or investment returns.',
    `location_code` BIGINT COMMENT 'Reference to the primary physical location or office where the department is headquartered.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the department record was last modified.',
    `department_name` STRING COMMENT 'Official name of the department as recognized within the organization.',
    `profit_center_code` STRING COMMENT 'Financial profit center code for departments that generate revenue or manage investment returns.',
    `regulatory_jurisdiction` STRING COMMENT 'Primary regulatory jurisdiction governing the departments activities if subject to regulation.',
    `sort_order` BIGINT COMMENT 'Numeric value determining the display order of the department in reports and user interfaces.',
    `department_status` STRING COMMENT 'Current operational status of the department indicating whether it is actively functioning.',
    `department_type` STRING COMMENT 'Classification of the department by functional area within the institutional asset management structure.',
    CONSTRAINT pk_department PRIMARY KEY(`department_id`)
) COMMENT 'Master reference table for department. Referenced by department_id.';

CREATE OR REPLACE TABLE `asset_management`.`shared`.`loan_servicer` (
    `loan_servicer_id` BIGINT COMMENT 'Primary key for loan_servicer',
    `asset_class_specialization` STRING COMMENT 'Primary asset classes the servicer specializes in (e.g., residential mortgage, commercial mortgage, consumer loans, CLO).',
    `contract_effective_date` DATE COMMENT 'Date when the current servicing agreement with this servicer became effective.',
    `contract_termination_date` DATE COMMENT 'Date when the current servicing agreement is scheduled to terminate or was terminated.',
    `current_portfolio_upb_usd` DECIMAL(18,2) COMMENT 'Total unpaid principal balance of loans currently being serviced, expressed in USD.',
    `esg_rating` STRING COMMENT 'ESG rating assigned to the servicer reflecting environmental, social, and governance practices.',
    `esg_rating_provider` STRING COMMENT 'Name of the organization that provided the ESG rating (e.g., MSCI, Sustainalytics, ISS).',
    `headquarters_address` STRING COMMENT 'Full street address of the loan servicers corporate headquarters or principal place of business.',
    `headquarters_city` STRING COMMENT 'City where the loan servicers corporate headquarters is located.',
    `headquarters_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code for the loan servicers headquarters location.',
    `is_approved_servicer` BOOLEAN COMMENT 'Indicates whether the servicer has been approved through the funds due diligence and counterparty approval process.',
    `is_fha_approved` BOOLEAN COMMENT 'Indicates whether the servicer is approved by FHA to service government-insured mortgage loans.',
    `is_gse_approved` BOOLEAN COMMENT 'Indicates whether the servicer is approved by GSEs such as Fannie Mae or Freddie Mac for agency loan servicing.',
    `jurisdiction_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code indicating the primary regulatory jurisdiction of the loan servicer.',
    `last_due_diligence_date` DATE COMMENT 'Date when the most recent operational due diligence review of the servicer was completed.',
    `legal_name` STRING COMMENT 'Official registered legal name of the loan servicing organization as filed with regulatory authorities.',
    `lei_code` STRING COMMENT '20-character alphanumeric Legal Entity Identifier assigned by GLEIF for global counterparty identification.',
    `license_expiry_date` DATE COMMENT 'Date when the loan servicers operating license expires and requires renewal.',
    `license_number` STRING COMMENT 'Regulatory license number authorizing the entity to perform loan servicing activities in applicable jurisdictions.',
    `loan_count` BIGINT COMMENT 'Total number of individual loans currently being serviced by this servicer.',
    `next_due_diligence_date` DATE COMMENT 'Scheduled date for the next operational due diligence review of the servicer.',
    `notes` STRING COMMENT 'Free-text field for additional notes, observations, or comments about the loan servicer.',
    `onboarding_date` DATE COMMENT 'Date when the loan servicer was initially onboarded and approved as an authorized servicing counterparty.',
    `parent_company_name` STRING COMMENT 'Name of the parent company or ultimate beneficial owner if the servicer is a subsidiary.',
    `primary_contact_email` STRING COMMENT 'Email address of the primary business contact for operational communications and notifications.',
    `primary_contact_name` STRING COMMENT 'Name of the primary business contact person at the loan servicer for relationship management purposes.',
    `primary_contact_phone` STRING COMMENT 'Phone number of the primary business contact for urgent communications and escalations.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this loan servicer record was first created in the system.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this loan servicer record was last modified or updated.',
    `registration_number` STRING COMMENT 'Official corporate registration or incorporation number assigned by the jurisdiction of incorporation.',
    `regulatory_rating` STRING COMMENT 'Rating assigned by regulatory bodies or rating agencies reflecting the servicers operational and financial soundness.',
    `servicer_code` STRING COMMENT 'Unique alphanumeric business code assigned to the loan servicer for external identification and reporting purposes.',
    `servicer_rating_agency` STRING COMMENT 'Name of the rating agency that assigned the servicer rating (e.g., S&P, Moodys, Fitch).',
    `servicer_status` STRING COMMENT 'Current operational status of the loan servicer indicating their ability to perform servicing activities.',
    `servicer_type` STRING COMMENT 'Classification of the servicer role in the loan servicing hierarchy (primary, master, sub-servicer, special servicer, backup, interim).',
    `servicing_capacity_usd` DECIMAL(18,2) COMMENT 'Maximum unpaid principal balance in USD that the servicer can effectively manage based on operational capacity.',
    `servicing_fee_rate_bps` DECIMAL(8,4) COMMENT 'Standard servicing fee rate charged by the servicer expressed in basis points of outstanding principal balance.',
    `soc_report_date` DATE COMMENT 'Date of the most recent SOC report issued for the servicers internal controls.',
    `soc_report_type` STRING COMMENT 'Type of SOC report the servicer maintains for internal control attestation (SOC1, SOC2, SOC3, or none).',
    `special_servicing_fee_rate_bps` DECIMAL(8,4) COMMENT 'Fee rate charged for special servicing activities on distressed or non-performing loans, in basis points.',
    `tax_identification_number` STRING COMMENT 'Government-issued tax identification number for the loan servicer entity used for regulatory and tax reporting.',
    `trading_name` STRING COMMENT 'Commercial or trading name under which the loan servicer conducts business, may differ from legal name.',
    `website_url` STRING COMMENT 'Official website URL of the loan servicer for reference and verification purposes.',
    CONSTRAINT pk_loan_servicer PRIMARY KEY(`loan_servicer_id`)
) COMMENT 'Master reference table for loan_servicer. Referenced by servicer_id.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `asset_management`.`shared`.`employee` ADD CONSTRAINT `fk_shared_employee_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`shared`.`employee` ADD CONSTRAINT `fk_shared_employee_department_id` FOREIGN KEY (`department_id`) REFERENCES `asset_management`.`shared`.`department`(`department_id`);
ALTER TABLE `asset_management`.`shared`.`employee` ADD CONSTRAINT `fk_shared_employee_manager_employee_id` FOREIGN KEY (`manager_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`shared`.`legal_entity` ADD CONSTRAINT `fk_shared_legal_entity_parent_entity_id` FOREIGN KEY (`parent_entity_id`) REFERENCES `asset_management`.`shared`.`legal_entity`(`legal_entity_id`);
ALTER TABLE `asset_management`.`shared`.`legal_entity` ADD CONSTRAINT `fk_shared_legal_entity_ultimate_parent_entity_id` FOREIGN KEY (`ultimate_parent_entity_id`) REFERENCES `asset_management`.`shared`.`legal_entity`(`legal_entity_id`);
ALTER TABLE `asset_management`.`shared`.`contract` ADD CONSTRAINT `fk_shared_contract_counterparty_legal_entity_id` FOREIGN KEY (`counterparty_legal_entity_id`) REFERENCES `asset_management`.`shared`.`legal_entity`(`legal_entity_id`);
ALTER TABLE `asset_management`.`shared`.`contract` ADD CONSTRAINT `fk_shared_contract_legal_entity_id` FOREIGN KEY (`legal_entity_id`) REFERENCES `asset_management`.`shared`.`legal_entity`(`legal_entity_id`);
ALTER TABLE `asset_management`.`shared`.`contract` ADD CONSTRAINT `fk_shared_contract_parent_contract_id` FOREIGN KEY (`parent_contract_id`) REFERENCES `asset_management`.`shared`.`contract`(`contract_id`);
ALTER TABLE `asset_management`.`shared`.`department` ADD CONSTRAINT `fk_shared_department_legal_entity_id` FOREIGN KEY (`legal_entity_id`) REFERENCES `asset_management`.`shared`.`legal_entity`(`legal_entity_id`);
ALTER TABLE `asset_management`.`shared`.`department` ADD CONSTRAINT `fk_shared_department_parent_department_id` FOREIGN KEY (`parent_department_id`) REFERENCES `asset_management`.`shared`.`department`(`department_id`);

-- ========= TAGS =========
ALTER TABLE `asset_management`.`shared`.`actor` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`shared`.`actor` SET TAGS ('dbx_domain' = 'shared');
ALTER TABLE `asset_management`.`shared`.`actor` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`shared`.`actor` SET TAGS ('dbx_subdomain' = 'organizational_parties');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `actor_id` SET TAGS ('dbx_business_glossary_term' = 'Actor Identifier');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `actor_status` SET TAGS ('dbx_business_glossary_term' = 'Lifecycle Status (STATUS)');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `actor_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|suspended');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `address_line1` SET TAGS ('dbx_business_glossary_term' = 'Address Line 1 (ADDR_LINE1)');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `address_line1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `address_line2` SET TAGS ('dbx_business_glossary_term' = 'Address Line 2 (ADDR_LINE2)');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `address_line2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `aml_status` SET TAGS ('dbx_business_glossary_term' = 'AML Status (AML_STATUS)');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `city` SET TAGS ('dbx_business_glossary_term' = 'City (CITY)');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `compliance_status` SET TAGS ('dbx_business_glossary_term' = 'Compliance Status (COMPLIANCE_STATUS)');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `country` SET TAGS ('dbx_business_glossary_term' = 'Country (COUNTRY)');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `country` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `country` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `created_at` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp (CREATED_AT)');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `default_currency` SET TAGS ('dbx_business_glossary_term' = 'Default Currency (DEFAULT_CURRENCY)');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `default_currency` SET TAGS ('dbx_value_regex' = 'USD|EUR|GBP|JPY|CHF|CAD');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `email` SET TAGS ('dbx_business_glossary_term' = 'Email Address (EMAIL)');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `entity_subtype` SET TAGS ('dbx_business_glossary_term' = 'Entity Subtype (ENTITY_SUBTYPE)');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `entity_type` SET TAGS ('dbx_business_glossary_term' = 'Entity Type (ENTITY_TYPE)');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `entity_type` SET TAGS ('dbx_value_regex' = 'individual|organization|fund|manager|counterparty|investor');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `external_system_code` SET TAGS ('dbx_business_glossary_term' = 'External System ID (EXTERNAL_SYSTEM_ID)');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `family_name` SET TAGS ('dbx_business_glossary_term' = 'Family Name (FAMILY_NAME)');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `family_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `family_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `given_name` SET TAGS ('dbx_business_glossary_term' = 'Given Name (GIVEN_NAME)');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `given_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `given_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `industry_code` SET TAGS ('dbx_business_glossary_term' = 'Industry Code (INDUSTRY_CODE)');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `investment_profile` SET TAGS ('dbx_business_glossary_term' = 'Investment Profile (INVESTMENT_PROFILE)');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `kyc_status` SET TAGS ('dbx_business_glossary_term' = 'KYC Status (KYC_STATUS)');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `last_contact_date` SET TAGS ('dbx_business_glossary_term' = 'Last Contact Date (LAST_CONTACT_DATE)');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `legal_name` SET TAGS ('dbx_business_glossary_term' = 'Legal Name (LEGAL_NAME)');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `legal_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `legal_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `net_income` SET TAGS ('dbx_business_glossary_term' = 'Net Income (NET_INCOME)');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `net_income` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `net_income` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `net_worth` SET TAGS ('dbx_business_glossary_term' = 'Net Worth (NET_WORTH)');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `net_worth` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `net_worth` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `phone` SET TAGS ('dbx_business_glossary_term' = 'Phone Number (PHONE)');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `phone` SET TAGS ('dbx_value_regex' = '^[+]?d{10,15}$');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `postal_code` SET TAGS ('dbx_business_glossary_term' = 'Postal Code (POSTAL_CODE)');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `preferred_contact_method` SET TAGS ('dbx_business_glossary_term' = 'Preferred Contact Method (PREFERRED_CONTACT_METHOD)');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `preferred_contact_method` SET TAGS ('dbx_value_regex' = 'email|phone|mail|online');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `preferred_language` SET TAGS ('dbx_business_glossary_term' = 'Preferred Language (PREFERRED_LANGUAGE)');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `registration_number` SET TAGS ('dbx_business_glossary_term' = 'Registration Number (REG_NUMBER)');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `registration_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{5,20}$');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `registration_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `registration_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `risk_profile` SET TAGS ('dbx_business_glossary_term' = 'Risk Profile (RISK_PROFILE)');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `sanctions_status` SET TAGS ('dbx_business_glossary_term' = 'Sanctions Status (SANCTIONS_STATUS)');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `sector` SET TAGS ('dbx_business_glossary_term' = 'Sector (SECTOR)');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `state` SET TAGS ('dbx_business_glossary_term' = 'State/Province (STATE)');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `state` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `state` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `tax_identifier` SET TAGS ('dbx_business_glossary_term' = 'Tax Identification Number (TAX_ID)');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `tax_identifier` SET TAGS ('dbx_value_regex' = '^[0-9]{9}$');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `tax_identifier` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `tax_identifier` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`shared`.`actor` ALTER COLUMN `updated_at` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp (UPDATED_AT)');
ALTER TABLE `asset_management`.`shared`.`employee` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`shared`.`employee` SET TAGS ('dbx_domain' = 'shared');
ALTER TABLE `asset_management`.`shared`.`employee` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`shared`.`employee` SET TAGS ('dbx_subdomain' = 'organizational_parties');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Employee Identifier');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `actor_id` SET TAGS ('dbx_business_glossary_term' = 'Actor Id (Foreign Key)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `department_id` SET TAGS ('dbx_business_glossary_term' = 'Employee Department ID (EMP_DEPT_ID)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `manager_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Employee Manager ID (EMP_MANAGER_ID)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `bonus` SET TAGS ('dbx_business_glossary_term' = 'Employee Bonus (EMP_BONUS)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `bonus` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `bonus` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `employee_code` SET TAGS ('dbx_business_glossary_term' = 'Employee Code (EMP_CODE)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_business_glossary_term' = 'Employee Date of Birth (EMP_DOB)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `date_of_birth` SET TAGS ('dbx_pii_dob' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `emergency_contact_address_line1` SET TAGS ('dbx_business_glossary_term' = 'Employee Emergency Contact Address Line 1 (EMP_EMG_CONTACT_ADDR_LINE1)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `emergency_contact_address_line1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `emergency_contact_address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `emergency_contact_address_line2` SET TAGS ('dbx_business_glossary_term' = 'Employee Emergency Contact Address Line 2 (EMP_EMG_CONTACT_ADDR_LINE2)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `emergency_contact_address_line2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `emergency_contact_address_line2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `emergency_contact_city` SET TAGS ('dbx_business_glossary_term' = 'Employee Emergency Contact City (EMP_EMG_CONTACT_CITY)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `emergency_contact_city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `emergency_contact_city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `emergency_contact_country` SET TAGS ('dbx_business_glossary_term' = 'Employee Emergency Contact Country (EMP_EMG_CONTACT_COUNTRY)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `emergency_contact_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `emergency_contact_country` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `emergency_contact_country` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `emergency_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Employee Emergency Contact Email (EMP_EMG_CONTACT_EMAIL)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `emergency_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `emergency_contact_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `emergency_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `emergency_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Employee Emergency Contact Name (EMP_EMG_CONTACT_NAME)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `emergency_contact_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `emergency_contact_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `emergency_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Employee Emergency Contact Phone (EMP_EMG_CONTACT_PHONE)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `emergency_contact_phone` SET TAGS ('dbx_value_regex' = '^+?[0-9]{7,15}$');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `emergency_contact_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `emergency_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `emergency_contact_postal_code` SET TAGS ('dbx_business_glossary_term' = 'Employee Emergency Contact Postal Code (EMP_EMG_CONTACT_POSTAL)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `emergency_contact_postal_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9- ]{3,10}$');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `emergency_contact_postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `emergency_contact_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `emergency_contact_relationship` SET TAGS ('dbx_business_glossary_term' = 'Employee Emergency Contact Relationship (EMP_EMG_CONTACT_REL)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `emergency_contact_relationship` SET TAGS ('dbx_value_regex' = 'parent|spouse|sibling|friend|other');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `emergency_contact_state` SET TAGS ('dbx_business_glossary_term' = 'Employee Emergency Contact State (EMP_EMG_CONTACT_STATE)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `emergency_contact_state` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `emergency_contact_state` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `employment_end_date` SET TAGS ('dbx_business_glossary_term' = 'Employee Employment End Date (EMP_END_DATE)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `employment_start_date` SET TAGS ('dbx_business_glossary_term' = 'Employee Employment Start Date (EMP_START_DATE)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `employment_status` SET TAGS ('dbx_business_glossary_term' = 'Employee Employment Status (EMP_STATUS)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `employment_status` SET TAGS ('dbx_value_regex' = 'active|inactive|terminated|on_leave|retired');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `employment_type` SET TAGS ('dbx_business_glossary_term' = 'Employee Employment Type (EMP_TYPE)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `employment_type` SET TAGS ('dbx_value_regex' = 'full_time|part_time|contractor|consultant|intern|temporary');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `gender` SET TAGS ('dbx_business_glossary_term' = 'Employee Gender (EMP_GENDER)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `gender` SET TAGS ('dbx_value_regex' = 'male|female|non-binary|other');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `gender` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `gender` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `job_level` SET TAGS ('dbx_business_glossary_term' = 'Employee Job Level (EMP_JOB_LEVEL)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `job_title` SET TAGS ('dbx_business_glossary_term' = 'Employee Job Title (EMP_JOB_TITLE)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `marital_status` SET TAGS ('dbx_business_glossary_term' = 'Employee Marital Status (EMP_MARITAL_STATUS)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `marital_status` SET TAGS ('dbx_value_regex' = 'single|married|divorced|widowed|separated');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `marital_status` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `marital_status` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `national_identifier` SET TAGS ('dbx_business_glossary_term' = 'Employee National ID (EMP_NATIONAL_ID)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `national_identifier` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `national_identifier` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Employee Number (EMP_NUMBER)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `payroll_account_number` SET TAGS ('dbx_business_glossary_term' = 'Employee Payroll Account Number (EMP_PAYROLL_ACC_NUM)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `payroll_account_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `payroll_account_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `payroll_bank_bic` SET TAGS ('dbx_business_glossary_term' = 'Employee Payroll BIC (EMP_PAYROLL_BIC)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `payroll_bank_bic` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `payroll_bank_bic` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `payroll_bank_iban` SET TAGS ('dbx_business_glossary_term' = 'Employee Payroll IBAN (EMP_PAYROLL_IBAN)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `payroll_bank_iban` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `payroll_bank_iban` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `payroll_bank_name` SET TAGS ('dbx_business_glossary_term' = 'Employee Payroll Bank Name (EMP_PAYROLL_BANK_NAME)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `payroll_frequency` SET TAGS ('dbx_business_glossary_term' = 'Employee Payroll Frequency (EMP_PAYROLL_FREQ)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `payroll_frequency` SET TAGS ('dbx_value_regex' = 'weekly|biweekly|monthly|quarterly|annually');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `record_audit_created` SET TAGS ('dbx_business_glossary_term' = 'Employee Record Created Timestamp (EMP_RECORD_CREATED_TS)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `record_audit_updated` SET TAGS ('dbx_business_glossary_term' = 'Employee Record Updated Timestamp (EMP_RECORD_UPDATED_TS)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `salary` SET TAGS ('dbx_business_glossary_term' = 'Employee Salary (EMP_SALARY)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `salary` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `salary` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `salary_currency` SET TAGS ('dbx_business_glossary_term' = 'Employee Salary Currency (EMP_SALARY_CURRENCY)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `salary_currency` SET TAGS ('dbx_value_regex' = 'USD|EUR|GBP|CAD|AUD|JPY');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `salary_currency` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `salary_currency` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `ssn` SET TAGS ('dbx_business_glossary_term' = 'Employee Social Security Number (EMP_SSN)');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `ssn` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`employee` ALTER COLUMN `ssn` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`shared`.`legal_entity` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`shared`.`legal_entity` SET TAGS ('dbx_domain' = 'shared');
ALTER TABLE `asset_management`.`shared`.`legal_entity` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`shared`.`legal_entity` SET TAGS ('dbx_subdomain' = 'organizational_parties');
ALTER TABLE `asset_management`.`shared`.`legal_entity` ALTER COLUMN `legal_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier');
ALTER TABLE `asset_management`.`shared`.`legal_entity` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`legal_entity` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`shared`.`legal_entity` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`legal_entity` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`shared`.`legal_entity` ALTER COLUMN `registered_address_line_1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`legal_entity` ALTER COLUMN `registered_address_line_1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`shared`.`legal_entity` ALTER COLUMN `registered_address_line_2` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`legal_entity` ALTER COLUMN `registered_address_line_2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`shared`.`legal_entity` ALTER COLUMN `registered_city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`legal_entity` ALTER COLUMN `registered_city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`shared`.`legal_entity` ALTER COLUMN `registered_postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`legal_entity` ALTER COLUMN `registered_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`shared`.`legal_entity` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`legal_entity` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`shared`.`document` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`shared`.`document` SET TAGS ('dbx_domain' = 'shared');
ALTER TABLE `asset_management`.`shared`.`document` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`shared`.`document` SET TAGS ('dbx_subdomain' = 'contractual_documentation');
ALTER TABLE `asset_management`.`shared`.`document` ALTER COLUMN `document_id` SET TAGS ('dbx_business_glossary_term' = 'Document Identifier');
ALTER TABLE `asset_management`.`shared`.`document` ALTER COLUMN `approver_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`document` ALTER COLUMN `approver_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`shared`.`document` ALTER COLUMN `author_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`document` ALTER COLUMN `author_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`shared`.`fund_administrator` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`shared`.`fund_administrator` SET TAGS ('dbx_domain' = 'shared');
ALTER TABLE `asset_management`.`shared`.`fund_administrator` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`shared`.`fund_administrator` SET TAGS ('dbx_subdomain' = 'external_counterparties');
ALTER TABLE `asset_management`.`shared`.`fund_administrator` ALTER COLUMN `fund_administrator_id` SET TAGS ('dbx_business_glossary_term' = 'Fund Administrator Identifier');
ALTER TABLE `asset_management`.`shared`.`fund_administrator` ALTER COLUMN `headquarters_address` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`fund_administrator` ALTER COLUMN `headquarters_address` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`shared`.`fund_administrator` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`fund_administrator` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`shared`.`fund_administrator` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`fund_administrator` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`shared`.`fund_administrator` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`fund_administrator` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`shared`.`vendor` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`shared`.`vendor` SET TAGS ('dbx_domain' = 'shared');
ALTER TABLE `asset_management`.`shared`.`vendor` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`shared`.`vendor` SET TAGS ('dbx_subdomain' = 'external_counterparties');
ALTER TABLE `asset_management`.`shared`.`vendor` ALTER COLUMN `vendor_id` SET TAGS ('dbx_business_glossary_term' = 'Vendor Identifier');
ALTER TABLE `asset_management`.`shared`.`vendor` ALTER COLUMN `bank_account_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`vendor` ALTER COLUMN `bank_account_name` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`shared`.`vendor` ALTER COLUMN `bank_account_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`vendor` ALTER COLUMN `bank_account_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`shared`.`vendor` ALTER COLUMN `bank_swift_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`vendor` ALTER COLUMN `bank_swift_code` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`shared`.`vendor` ALTER COLUMN `headquarters_address` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`vendor` ALTER COLUMN `headquarters_address` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`shared`.`vendor` ALTER COLUMN `headquarters_city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`vendor` ALTER COLUMN `headquarters_city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`shared`.`vendor` ALTER COLUMN `postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`vendor` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`shared`.`vendor` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`vendor` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`shared`.`vendor` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`vendor` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`shared`.`vendor` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`vendor` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`shared`.`vendor` ALTER COLUMN `primary_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`vendor` ALTER COLUMN `primary_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`shared`.`vendor` ALTER COLUMN `primary_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`vendor` ALTER COLUMN `primary_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`shared`.`vendor` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`vendor` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`shared`.`auditor` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`shared`.`auditor` SET TAGS ('dbx_domain' = 'shared');
ALTER TABLE `asset_management`.`shared`.`auditor` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`shared`.`auditor` SET TAGS ('dbx_subdomain' = 'external_counterparties');
ALTER TABLE `asset_management`.`shared`.`auditor` ALTER COLUMN `auditor_id` SET TAGS ('dbx_business_glossary_term' = 'Auditor Identifier');
ALTER TABLE `asset_management`.`shared`.`auditor` ALTER COLUMN `headquarters_address` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`auditor` ALTER COLUMN `headquarters_address` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`shared`.`auditor` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`auditor` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`shared`.`auditor` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`auditor` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`shared`.`auditor` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`auditor` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`shared`.`auditor` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`contract` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`shared`.`contract` SET TAGS ('dbx_domain' = 'shared');
ALTER TABLE `asset_management`.`shared`.`contract` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`shared`.`contract` SET TAGS ('dbx_subdomain' = 'contractual_documentation');
ALTER TABLE `asset_management`.`shared`.`contract` ALTER COLUMN `contract_id` SET TAGS ('dbx_business_glossary_term' = 'Contract Identifier');
ALTER TABLE `asset_management`.`shared`.`contract` ALTER COLUMN `hurdle_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`contract` ALTER COLUMN `management_fee_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`contract` ALTER COLUMN `performance_fee_rate` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`contract` ALTER COLUMN `total_commitment_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`contractor` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`shared`.`contractor` SET TAGS ('dbx_domain' = 'shared');
ALTER TABLE `asset_management`.`shared`.`contractor` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`shared`.`contractor` SET TAGS ('dbx_subdomain' = 'external_counterparties');
ALTER TABLE `asset_management`.`shared`.`contractor` ALTER COLUMN `contractor_id` SET TAGS ('dbx_business_glossary_term' = 'Contractor Identifier');
ALTER TABLE `asset_management`.`shared`.`contractor` ALTER COLUMN `address_line_1` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`contractor` ALTER COLUMN `address_line_1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`shared`.`contractor` ALTER COLUMN `address_line_2` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`contractor` ALTER COLUMN `address_line_2` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`shared`.`contractor` ALTER COLUMN `bank_account_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`contractor` ALTER COLUMN `bank_account_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`shared`.`contractor` ALTER COLUMN `bank_routing_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`contractor` ALTER COLUMN `bank_routing_code` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`shared`.`contractor` ALTER COLUMN `city` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`contractor` ALTER COLUMN `city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`shared`.`contractor` ALTER COLUMN `contractor_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`contractor` ALTER COLUMN `contractor_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`shared`.`contractor` ALTER COLUMN `postal_code` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`contractor` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`shared`.`contractor` ALTER COLUMN `primary_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`contractor` ALTER COLUMN `primary_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`shared`.`contractor` ALTER COLUMN `primary_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`contractor` ALTER COLUMN `primary_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`shared`.`contractor` ALTER COLUMN `state_province` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`contractor` ALTER COLUMN `state_province` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`shared`.`contractor` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`contractor` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`shared`.`department` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`shared`.`department` SET TAGS ('dbx_domain' = 'shared');
ALTER TABLE `asset_management`.`shared`.`department` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`shared`.`department` SET TAGS ('dbx_subdomain' = 'organizational_parties');
ALTER TABLE `asset_management`.`shared`.`department` ALTER COLUMN `department_id` SET TAGS ('dbx_business_glossary_term' = 'Department Identifier');
ALTER TABLE `asset_management`.`shared`.`department` ALTER COLUMN `annual_operating_budget` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`loan_servicer` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`shared`.`loan_servicer` SET TAGS ('dbx_domain' = 'shared');
ALTER TABLE `asset_management`.`shared`.`loan_servicer` SET TAGS ('dbx_division' = 'corporate');
ALTER TABLE `asset_management`.`shared`.`loan_servicer` SET TAGS ('dbx_subdomain' = 'external_counterparties');
ALTER TABLE `asset_management`.`shared`.`loan_servicer` ALTER COLUMN `loan_servicer_id` SET TAGS ('dbx_business_glossary_term' = 'Loan Servicer Identifier');
ALTER TABLE `asset_management`.`shared`.`loan_servicer` ALTER COLUMN `headquarters_address` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`loan_servicer` ALTER COLUMN `headquarters_address` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`shared`.`loan_servicer` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`loan_servicer` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`shared`.`loan_servicer` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`loan_servicer` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_pii_name' = 'true');
ALTER TABLE `asset_management`.`shared`.`loan_servicer` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`shared`.`loan_servicer` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`shared`.`loan_servicer` ALTER COLUMN `servicing_fee_rate_bps` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`loan_servicer` ALTER COLUMN `special_servicing_fee_rate_bps` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`loan_servicer` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`shared`.`loan_servicer` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_pii_identifier' = 'true');
