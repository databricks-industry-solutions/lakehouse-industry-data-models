-- Schema for Domain: sponsor | Business: Clinical_Trials | Version: v2_ecm
-- Generated on: 2026-11-20 10:03:01

CREATE DATABASE IF NOT EXISTS `clinical_trials_ecm`.`sponsor` COMMENT 'SSOT for pharmaceutical and biotech sponsor organizations that fund and own clinical trials. Manages sponsor organization profiles, contracted study portfolios, therapeutic areas, pipeline products, regulatory strategies, commercial relationships, contact';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`sponsor`.`organization` (
    `organization_id` BIGINT COMMENT 'Primary key for organization',
    `parent_org_organization_id` BIGINT COMMENT 'Self-referencing identifier pointing to the parent sponsor organization record for organizations that are subsidiaries or divisions of a larger corporate entity. Enables corporate hierarchy traversal for portfolio-level reporting.',
    `primary_ultimate_parent_org_organization_id` BIGINT COMMENT 'Identifier of the top-level ultimate parent organization in the corporate hierarchy. Enables consolidated portfolio analytics and enterprise-level sponsor relationship management without recursive hierarchy traversal.',
    `active_study_count` BIGINT COMMENT 'Number of currently active clinical studies contracted with this sponsor organization. Operational metric used for capacity planning, account management prioritization, and sponsor portfolio reporting.',
    `annual_rd_budget_usd_range` STRING COMMENT 'Approximate annual R&D investment band for the sponsor organization in USD. Used for sponsor capability assessment, portfolio sizing, and strategic account planning. Stored as a range to protect commercially sensitive data.',
    `contract_framework_type` STRING COMMENT 'Type of overarching contractual framework governing the CRO-sponsor relationship. Determines billing models, governance structures, and scope-of-work templates used in the source system accounting.. Valid values are `master_service_agreement|preferred_provider|project_based|functional_service_provider|none`',
    `corporate_tier` STRING COMMENT 'Business size classification of the sponsor organization used for portfolio segmentation, resource allocation, and strategic account management. Distinguishes Big Pharma from mid-size and emerging biotech sponsors.. Valid values are `big_pharma|mid_size|emerging_biotech|academic_institution|government_agency`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the sponsor organization record was first created in the system. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `cro_relationship_type` STRING COMMENT 'Classification of the engagement model between the CRO and this sponsor organization. Drives contract template selection, governance model, and service delivery framework.. Valid values are `full_service|functional_service|preferred|transactional|strategic_partner`',
    `ctms_account_code` STRING COMMENT 'the source system account record identifier for the sponsor organization. Serves as the cross-reference key for sponsor account data originating from the CTMS system of record.',
    `data_privacy_framework` STRING COMMENT 'Primary data privacy regulatory framework applicable to the sponsor organization based on its jurisdiction and operational scope. Governs patient data handling, consent management, and cross-border data transfer requirements.',
    `duns_number` STRING COMMENT 'Nine-digit Dun & Bradstreet Data Universal Numbering System identifier uniquely identifying the sponsor organization globally. Required for federal grant applications, the source system master, and procurement processes.. Valid values are `^[0-9]{9}$`',
    `ema_org_number` STRING COMMENT 'EMA-assigned organization identifier used in Marketing Authorization Applications (MAA) and EU Clinical Trials Regulation (EU CTR 536/2014) submissions. Links the sponsor to EudraCT and CTIS regulatory records.',
    `employee_count_range` STRING COMMENT 'Approximate employee headcount band for the sponsor organization. Used for corporate tier validation, resource planning, and sponsor capability assessment. Stored as a range to avoid precision sensitivity.. Valid values are `1_50|51_200|201_1000|1001_5000|5001_10000|10000_plus`',
    `fda_sponsor_number` STRING COMMENT 'FDA-assigned sponsor identifier used in Investigational New Drug (IND) applications, New Drug Applications (NDA), and Biologics License Applications (BLA). Links the organization to its regulatory submissions in FDA systems.',
    `first_study_start_date` DATE COMMENT 'Date on which the first clinical study with this sponsor organization was initiated. Establishes the tenure of the CRO-sponsor relationship and is used for loyalty segmentation and strategic account analytics.',
    `founding_year` BIGINT COMMENT 'Calendar year in which the sponsor organization was legally incorporated or founded. Used for organizational maturity assessment, due diligence, and sponsor profile analytics.',
    `gcp_audit_required` BOOLEAN COMMENT 'Indicates whether the sponsor organization requires GCP audits of CRO operations as part of their quality oversight obligations under ICH E6(R2). Triggers audit scheduling in MasterControl.',
    `headquarters_city` STRING COMMENT 'City where the sponsor organizations principal headquarters is located. Used for regulatory jurisdiction determination, site visit planning, and sponsor contact management.',
    `headquarters_country` STRING COMMENT 'ISO 3166-1 alpha-3 three-letter country code for the country where the sponsor organizations principal headquarters is located. Determines primary regulatory jurisdiction and applicable data privacy laws (GDPR, HIPAA).. Valid values are `^[A-Z]{3}$`',
    `headquarters_state_province` STRING COMMENT 'State or province of the sponsor organizations principal headquarters. Used for sub-national regulatory jurisdiction determination and tax compliance.',
    `ind_holder` BOOLEAN COMMENT 'Indicates whether the sponsor organization holds one or more active Investigational New Drug (IND) applications with the FDA. Key regulatory classification for study oversight and sponsor obligations under 21 CFR Part 312.',
    `is_publicly_traded` BOOLEAN COMMENT 'Indicates whether the sponsor organization is publicly traded on a stock exchange. Drives SOX compliance requirements, financial disclosure obligations, and investor relations considerations for study data.',
    `legal_name` STRING COMMENT 'Full legal registered name of the sponsor organization as it appears in official corporate filings and regulatory submissions (e.g., IND, NDA, BLA, MAA applications). Used as the authoritative identity label across all regulatory documents.',
    `master_agreement_expiry_date` DATE COMMENT 'Expiration date of the master service agreement or preferred provider agreement with the sponsor organization. Triggers contract renewal workflows and financial planning activities in the source system',
    `notes` STRING COMMENT 'Free-text field for capturing additional context about the sponsor organization including strategic relationship notes, special handling instructions, or historical background not captured in structured fields.',
    `org_status` STRING COMMENT 'Current lifecycle status of the sponsor organization record. Controls whether new studies can be initiated with this sponsor and whether existing engagements remain operationally active.. Valid values are `active|inactive|suspended|pending|terminated`',
    `org_type` STRING COMMENT 'Categorical classification of the sponsor organization by entity type. Drives regulatory pathway selection, contract templates, and reporting obligations. [ENUM-REF-CANDIDATE: pharmaceutical|biotech|academic|government|non_profit|medical_device — promote',
    `preferred_edc_system` STRING COMMENT 'Sponsors preferred Electronic Data Capture (EDC) platform for clinical data collection. Informs technology stack decisions for study setup in Medidata Rave or the source system and impacts eCRF build timelines.. Valid values are `medidata_rave|oracle_clinical_one|veeva_vault_edclinical|other|none`',
    `preferred_etmf_system` STRING COMMENT 'Sponsors preferred Electronic Trial Master File (eTMF) platform for document management and regulatory archival. Determines integration requirements with Veeva Vault eTMF and document exchange protocols.. Valid values are `veeva_vault|other|none`',
    `primary_contact_email` STRING COMMENT 'Primary operational email address for the sponsor organization used for study-related communications, regulatory notifications, and CRO engagement. Classified as confidential organizational contact data.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `primary_contact_phone` STRING COMMENT 'Primary telephone number for the sponsor organizations main point of contact. Used for urgent safety communications, regulatory escalations, and operational coordination.',
    `regulatory_strategy_region` STRING COMMENT 'Geographic regulatory strategy scope for the sponsors clinical development program. Determines which regulatory agencies (FDA, EMA, PMDA, TGA, Health Canada) are engaged and which submission pathways apply.. Valid values are `global|usa_only|eu_only|usa_eu|asia_pacific|multi_regional`',
    `safety_reporting_contact_email` STRING COMMENT 'Designated email address for the sponsors pharmacovigilance or drug safety unit. Used for Serious Adverse Event (SAE), Suspected Unexpected Serious Adverse Reaction (SUSAR), and expedited safety report submissions to the source system. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `sap_vendor_code` STRING COMMENT 'the source system master record identifier for the sponsor organization. Links the sponsor to financial transactions including accounts receivable (AR), invoicing, and project accounting in the ERP system.',
    `stock_exchange` STRING COMMENT 'Primary stock exchange on which the sponsor organizations shares are listed. Relevant for SOX compliance scope and financial reporting obligations.. Valid values are `NYSE|NASDAQ|LSE|TSX|ASX|OTHER`',
    `stock_ticker` STRING COMMENT 'Exchange-listed stock ticker symbol for publicly traded sponsor organizations. Used for financial monitoring, SOX compliance tracking, and market intelligence.. Valid values are `^[A-Z]{1,5}$`',
    `tax_number` STRING COMMENT 'Federal Employer Identification Number (EIN) or equivalent national tax identifier for the sponsor organization. Required for the source system transactions, contract execution, and regulatory filings.',
    `trade_name` STRING COMMENT 'Operating or brand name of the sponsor organization, which may differ from the legal name. Used in commercial communications, CTMS records, and sponsor-facing correspondence.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the sponsor organization record. Supports change tracking, data lineage, and audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `website_url` STRING COMMENT 'Official public website URL of the sponsor organization. Used for due diligence, pipeline research, and sponsor profile enrichment.',
    `who_universal_trial_number_prefix` STRING COMMENT 'WHO International Clinical Trials Registry Platform (ICTRP) assigned prefix for the sponsor organization, used to construct Universal Trial Numbers (UTN) for WHO-registered studies.',
    CONSTRAINT pk_organization PRIMARY KEY(`organization_id`)
) COMMENT 'Master record for pharmaceutical and biotech sponsor organizations that fund and own clinical trials. Captures the authoritative profile of each sponsor entity including legal name, organization type (pharma, biotech, academic, government), headquarters';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` (
    `org_hierarchy_id` BIGINT COMMENT 'Unique surrogate identifier for each parent-child corporate hierarchy relationship record within the sponsor organization structure.',
    `child_org_organization_id` BIGINT COMMENT 'Identifier of the child sponsor organization in this hierarchy relationship. References the subordinate entity (e.g., subsidiary, affiliate, regional division, or joint-venture partner).',
    `primary_organization_id` BIGINT COMMENT 'Identifier of the parent sponsor organization in this hierarchy relationship. References the superior entity in the corporate structure (e.g., ultimate parent, holding company, or intermediate parent).',
    `tertiary_workday_org_organization_id` BIGINT COMMENT 'Organization identifier in the source system to the child entity. Enables workforce planning, headcount roll-up, and talent management data to be aligned with the sponsor corporate hierarchy.',
    `approval_date` DATE COMMENT 'Date on which the organizational hierarchy relationship was formally approved by the designated authority. Distinct from the effective start date, which reflects when the relationship became operationally active.',
    `approved_by` STRING COMMENT 'Name or identifier of the individual or governance body that approved the establishment or modification of this organizational hierarchy relationship (e.g., Chief Legal Officer, Corporate Governance Committee).',
    `change_reason` STRING COMMENT 'Free-text description of the business reason for creating or modifying this hierarchy relationship record (e.g., Acquisition of regional affiliate, Corporate restructuring post-merger, Divestiture of oncology division).',
    `consolidation_scope` STRING COMMENT 'Indicates how the child organizations financials are consolidated into the parents financial statements per IFRS 10 / US GAAP ASC 810. Full = 100% consolidation; Proportional = pro-rata by ownership; Equity method = single-line investment; Excluded =. Valid values are `full|proportional|equity_method|excluded`',
    `contracting_entity_flag` BOOLEAN COMMENT 'Indicates whether the child organization is authorized to independently execute clinical trial contracts and CRO agreements on behalf of the sponsor corporate family. True = can contract independently; False = contracts flow through parent entity.',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the child organizations primary jurisdiction of incorporation or operation. Supports multi-national sponsor structure analysis and regulatory jurisdiction mapping (FDA, EMA, PMDA, TGA, Health Canada, MHRA).. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this organizational hierarchy relationship record was first created in the Silver Layer data product. Supports audit trail requirements under FDA 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `ctms_org_code` STRING COMMENT 'Organization identifier assigned to the child entity within the source system Used for cross-referencing sponsor hierarchy records with study portfolio, site management, and monitoring visit data in the CTMS.. Valid values are `^[A-Z0-9_-]{2,30}$`',
    `data_sharing_agreement_flag` BOOLEAN COMMENT 'Indicates whether a formal data sharing agreement exists between the parent and child organization governing the exchange of clinical trial data, safety data, and regulatory submissions. Relevant for GDPR, HIPAA, and ICH E6(R2) data governance compliance.',
    `effective_end_date` DATE COMMENT 'Calendar date on which the parent-child organizational relationship ceased to be effective. Null indicates an open-ended, currently active relationship. Supports bi-temporal modeling and historical hierarchy queries.',
    `effective_start_date` DATE COMMENT 'Calendar date on which the parent-child organizational relationship became legally or operationally effective. Used for temporal filtering and historical hierarchy reconstruction.',
    `gdpr_data_controller_role` STRING COMMENT 'Defines the GDPR data controller/processor role of the child organization relative to the parent for clinical trial subject data. Controller = determines purposes and means; Joint Controller = shared determination; Processor = processes on behalf of. Valid values are `controller|joint_controller|processor|not_applicable`',
    `hierarchy_level` BIGINT COMMENT 'Numeric depth level of the child organization within the corporate hierarchy tree. Level 1 represents a direct subsidiary of the ultimate parent; higher values indicate deeper nesting.',
    `hierarchy_path` STRING COMMENT 'Materialized path string representing the full ancestry chain from the ultimate parent to the child organization, using a delimiter-separated list of organization IDs (e.g., 1001/1045/1078).',
    `hierarchy_version` BIGINT COMMENT 'Monotonically incrementing version number for this hierarchy relationship record, supporting optimistic concurrency control and change history tracking. Incremented each time the relationship attributes are updated.',
    `ind_holder_flag` BOOLEAN COMMENT 'Indicates whether the child organization holds or co-holds an Investigational New Drug (IND) application or equivalent regulatory authorization (e.g., CTA in EU) in its own name. Relevant for regulatory accountability and submission ownership tracking.',
    `is_controlling_entity` BOOLEAN COMMENT 'Indicates whether the parent organization exercises control over the child organization as defined by IFRS 10 (power over investee, exposure to variable returns, ability to use power to affect returns). True = controlling; False = non-controlling interest.',
    `is_primary_path` BOOLEAN COMMENT 'Indicates whether this relationship represents the primary (canonical) reporting path for the child organization when multiple parent relationships exist (e.g., matrix structures or dual-reporting affiliates).',
    `notes` STRING COMMENT 'Free-text field for additional contextual information about the organizational hierarchy relationship not captured in structured fields (e.g., special contractual arrangements, regulatory carve-outs, transition notes during M&A activity).',
    `ownership_percentage` DECIMAL(5,2) COMMENT 'Percentage of equity ownership held by the parent organization in the child organization, expressed as a decimal value between 0.00 and 100.00. Critical for determining consolidation thresholds under IFRS 10 and for sponsor financial roll-up reporting.',
    `pipeline_scope` STRING COMMENT 'Defines the breadth of the sponsors drug development pipeline that the child organization is responsible for managing or contracting. Supports portfolio analytics and CRO engagement planning across the sponsor corporate family.. Valid values are `full_pipeline|regional_pipeline|single_asset|no_pipeline`',
    `regulatory_jurisdiction` STRING COMMENT 'Primary regulatory authority governing the child organizations clinical trial activities (e.g., FDA, EMA, PMDA, TGA, MHRA, Health Canada). Determines applicable regulatory submission requirements and GCP compliance frameworks for studies contracted',
    `relationship_basis` STRING COMMENT 'The legal or operational basis underpinning the parent-child relationship. Equity = share ownership; Contractual = agreement-based control without equity; Regulatory = regulatory-mandated grouping; Operational = functional reporting without legal. Valid values are `equity|contractual|regulatory|operational|statutory`',
    `relationship_code` STRING COMMENT 'Externally-known alphanumeric code uniquely identifying this hierarchy relationship, used for cross-system referencing in the source system the source system regulatory submissions. Follows the sponsor organizations internal coding convention.. Valid values are `^[A-Z0-9_]{2,20}$`',
    `relationship_status` STRING COMMENT 'Current lifecycle state of the parent-child organizational relationship. Drives whether the relationship is included in active roll-up reporting and sponsor portfolio consolidation.. Valid values are `active|inactive|pending|terminated|suspended`',
    `relationship_type` STRING COMMENT 'Categorical classification of the corporate relationship between the parent and child organization. Drives roll-up logic and reporting scope. [ENUM-REF-CANDIDATE: parent|subsidiary|affiliate|division|joint_venture|licensee|branch|representative_office —',
    `sap_company_code` STRING COMMENT 'Four-character the source system code assigned to the child organization for financial accounting, accounts payable/receivable, and project accounting. Enables direct linkage between the organizational hierarchy and financial ledger entries in the source. Valid values are `^[A-Z0-9]{4}$`',
    `source_record_reference` STRING COMMENT 'Native record identifier from the source operational system (e.g., Siebel CTMS account relationship ID, the source system pairing key). Enables reverse traceability from the Silver Layer back to the originating system record for reconciliation and audit.',
    `therapeutic_area_alignment` STRING COMMENT 'Primary therapeutic area(s) for which the child organization is responsible within the sponsor corporate family (e.g., Oncology, Cardiovascular, Neuroscience, Immunology).',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this organizational hierarchy relationship record was most recently modified in the Silver Layer data product. Supports change detection, incremental ETL processing, and audit trail requirements.',
    `veeva_account_code` STRING COMMENT 'Unique identifier for the child organizations account record in Veeva Vault, used for eTMF document ownership, regulatory submission tracking, and quality management linkage. Supports traceability between the corporate hierarchy and document management.',
    `voting_rights_percentage` DECIMAL(5,2) COMMENT 'Percentage of voting rights held by the parent organization in the child organization. May differ from ownership percentage in cases of dual-class share structures or contractual voting arrangements.',
    CONSTRAINT pk_org_hierarchy PRIMARY KEY(`org_hierarchy_id`)
) COMMENT 'Defines parent-child corporate hierarchy relationships among sponsor organizations, capturing subsidiary, affiliate, and division structures. Tracks relationship type (parent, subsidiary, affiliate, division, joint-venture), effective dates, ownership';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` (
    `organization_contact_id` BIGINT COMMENT 'Primary key for the canonical contact entity. Both sponsor-side and subject-side contacts reference this single source of truth for contact information.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization that this contact represents. Links the individual to their parent sponsor entity in the CRO relationship.',
    `academic_degree` STRING COMMENT 'Highest academic or professional degree held by the sponsor contact (e.g., MD, PhD, PharmD, MBA). Relevant for medical monitor qualification verification and regulatory submission authorship.',
    `contact_context` STRING COMMENT 'STRING',
    `contact_status` STRING COMMENT 'Current lifecycle status of the sponsor contact record within the CRO system. Active indicates current engagement; inactive indicates temporarily disengaged; departed indicates the individual has left the sponsor organization; on_leave indicates. Valid values are `active|inactive|departed|on_leave`',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code representing the country where the sponsor contact is primarily based. Used for regulatory jurisdiction mapping, time zone inference, and regional CRA assignment.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the sponsor contact record was first created in the system, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `ctms_contact_ref` STRING COMMENT 'The native contact record identifier from the source system the operational system of record for sponsor contact management. Used for system reconciliation and data lineage tracing.',
    `data_source` STRING COMMENT 'Identifies the originating operational system from which this sponsor contact record was sourced or last updated. Supports data lineage tracking and reconciliation across the CROs system landscape.. Valid values are `siebel_ctms|veeva_vault|manual_entry|sponsor_portal|workday_hcm`',
    `department` STRING COMMENT 'Organizational department within the sponsor company to which this contact belongs (e.g., Clinical Development, Regulatory Affairs, Medical Affairs, Business Development). Used for organizational mapping and escalation routing.',
    `do_not_contact` BOOLEAN COMMENT 'Indicates that this sponsor contact has requested to not be contacted directly, or has been flagged by the CRO as off-limits for direct outreach. Enforces communication suppression in CTMS and marketing workflows.',
    `first_name` STRING COMMENT 'Given (first) name of the sponsor contact individual. Used for formal correspondence, system display, and CRO-sponsor relationship management.',
    `gdpr_consent_date` DATE COMMENT 'Date on which GDPR data processing consent was last obtained or updated for this sponsor contact. Required for audit trail compliance under GDPR Article 7.',
    `gdpr_consent_status` STRING COMMENT 'Records the GDPR data processing consent status for this sponsor contacts personal data. Required for contacts based in EU/EEA jurisdictions. not_applicable for contacts outside GDPR scope.. Valid values are `granted|withdrawn|pending|not_applicable`',
    `is_financial_contact` BOOLEAN COMMENT 'Indicates whether this contact is authorized to receive financial communications including invoices, budget amendments, and payment notifications from the source system workflows.',
    `is_primary_contact` BOOLEAN COMMENT 'Indicates whether this individual is the designated primary point of contact for the sponsor organization in the CRO relationship. Only one contact per sponsor should hold this flag as True at any given time.',
    `is_regulatory_contact` BOOLEAN COMMENT 'Indicates whether this contact is designated to receive regulatory submission notifications, IND/NDA/BLA/MAA correspondence, and Health Authority query routing. Used by the regulatory affairs team for submission workflow management.',
    `is_safety_contact` BOOLEAN COMMENT 'Indicates whether this contact is designated to receive Serious Adverse Event (SAE) and Suspected Unexpected Serious Adverse Reaction (SUSAR) notifications. Drives automated safety reporting distribution in the source system',
    `language_preference` STRING COMMENT 'Preferred language for communications with this sponsor contact, expressed as an IETF BCP 47 language tag (e.g., en, fr, de, ja). Used for localized document delivery and meeting facilitation.. Valid values are `^[a-z]{2}(-[A-Z]{2})?$`',
    `last_interaction_date` DATE COMMENT 'Date of the most recent documented interaction between the CRO and this sponsor contact (e.g., meeting, email exchange, call). Used for relationship health monitoring and CRA engagement tracking.',
    `last_name` STRING COMMENT 'Family (last) name of the sponsor contact individual. Used in combination with first_name for full identity resolution and formal communications.',
    `linkedin_profile_url` STRING COMMENT 'URL to the sponsor contacts LinkedIn professional profile. Used by business development and CRA teams for relationship intelligence, background verification, and professional network mapping.. Valid values are `^https://(www.)?linkedin.com/in/[a-zA-Z0-9-_%]+/?$`',
    `middle_name` STRING COMMENT 'Middle name or initial of the sponsor contact, used for disambiguation when multiple contacts share the same first and last name within a sponsor organization.',
    `notes` STRING COMMENT 'Free-text field for CRA or CRO staff to record relationship context, communication preferences, background information, or other relevant notes about the sponsor contact. Not for clinical or safety data.',
    `office_location` STRING COMMENT 'Physical office location or site name where the sponsor contact is based (e.g., Pfizer - New York HQ, Roche - Basel Campus). Used for logistics, visit planning, and organizational mapping.',
    `preferred_communication_channel` STRING COMMENT 'The sponsor contacts preferred method for receiving communications from the CRO. Drives automated notification routing and meeting scheduling preferences within the CTMS.. Valid values are `email|phone|video_conference|secure_portal|instant_message`',
    `primary_email` STRING COMMENT 'Primary business email address for the sponsor contact. Used as the principal digital identifier for all CRO-sponsor communications, system notifications, and regulatory correspondence. SSOT for sponsor personnel identity.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `primary_phone` STRING COMMENT 'Primary business telephone number for the sponsor contact in E.164 international format. Used for direct voice communication, urgent safety escalations, and regulatory notifications.. Valid values are `^+?[1-9]d{1,14}$`',
    `professional_title` STRING COMMENT 'Job title or professional designation of the sponsor contact (e.g., Medical Monitor, Clinical Operations Director, Regulatory Affairs Lead, Project Manager). Reflects the contacts formal role within the sponsor organization.',
    `role_type` STRING COMMENT 'Functional role classification of the sponsor contact within the CRO engagement. Determines communication routing, escalation paths, and system access permissions.. Valid values are `medical_monitor|project_manager|regulatory_affairs|clinical_operations|business_development|pharmacovigilance`',
    `salutation` STRING COMMENT 'Formal salutation or honorific prefix for the sponsor contact (e.g., Dr., Mr., Ms., Prof.). Used in formal written correspondence, regulatory submissions, and meeting invitations.. Valid values are `Dr.|Mr.|Ms.|Mrs.|Prof.`',
    `secondary_email` STRING COMMENT 'Alternate email address for the sponsor contact, used when the primary email is unavailable or for routing specific communication types (e.g., personal email for urgent safety notifications).. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `secondary_phone` STRING COMMENT 'Alternate telephone number (e.g., mobile, home office) for the sponsor contact. Used as a backup contact channel when the primary phone is unreachable.. Valid values are `^+?[1-9]d{1,14}$`',
    `therapeutic_area_expertise` STRING COMMENT 'Primary therapeutic area(s) of expertise for this sponsor contact (e.g., Oncology, Cardiology, Neurology, Rare Disease). Used for study assignment matching, medical monitor qualification, and business development targeting.',
    `time_zone` STRING COMMENT 'IANA time zone identifier for the sponsor contacts primary work location (e.g., America/New_York, Europe/London). Used to schedule meetings, set notification delivery windows, and coordinate cross-regional communications.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the sponsor contact record, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Required for data lineage, change tracking, and ALCOA+ compliance.',
    `veeva_contact_ref` STRING COMMENT 'The contact record identifier from Veeva Vault, used when the sponsor contact is associated with eTMF document approvals, regulatory submissions, or quality management workflows.',
    CONSTRAINT pk_organization_contact PRIMARY KEY(`organization_contact_id`)
) COMMENT 'Canonical contact entity for sponsor organization personnel. Subject-related contacts reference subject.subject_contact; sponsor-related contacts use this entity.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` (
    `pipeline_asset_id` BIGINT COMMENT 'Unique surrogate identifier for the investigational pipeline asset record in the Clinical Trials lakehouse silver layer. Primary key for this master resource entity.',
    `application_id` BIGINT COMMENT 'Foreign key linking to regulatory.application. Business justification: Pipeline asset management requires linking to the master regulatory application record (which spans IND through NDA/BLA) for application status, clinical hold tracking, and lifecycle',
    `indication_id` BIGINT COMMENT 'Foreign key linking to program.indication. Business justification: Pipeline assets target a specific indication — this is a core drug development relationship.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization that owns and funds this pipeline asset.',
    `therapeutic_area_id` BIGINT COMMENT 'Foreign key linking to program.therapeutic_area. Business justification: Pipeline assets are classified by therapeutic area for development planning and regulatory strategy. pipeline_asset has therapeutic_area as a denormalized plain text field.',
    `accelerated_approval` BOOLEAN COMMENT 'Indicates whether the asset is being developed under the FDA Accelerated Approval pathway (Subpart H/E) or EMA conditional marketing authorization, allowing approval based on surrogate or intermediate endpoints for serious conditions.',
    `active_study_count` BIGINT COMMENT 'Number of currently active clinical studies (trials) running under this pipeline asset across all phases and indications. Provides a real-time view of the assets clinical activity footprint for portfolio management.',
    `approval_date` DATE COMMENT 'Date on which the primary regulatory authority granted marketing authorization or approval for the investigational asset. Null if not yet approved. Marks the transition from investigational to commercial product.',
    `asset_code` STRING COMMENT 'Sponsor-assigned internal development code or compound number for the investigational asset (e.g., ABC-1234, XYZ-001). Serves as the primary business identifier used across internal systems and regulatory submissions.. Valid values are `^[A-Z0-9-]{2,30}$`',
    `asset_description` STRING COMMENT 'Free-text narrative description of the investigational asset, summarizing its scientific rationale, differentiation from existing therapies, and strategic importance to the sponsors pipeline. Used in portfolio reviews and business development materials.',
    `asset_status` STRING COMMENT 'Current lifecycle status of the pipeline asset within the sponsors development portfolio. Drives pipeline reporting, resource planning, and regulatory strategy decisions.. Valid values are `active|on_hold|discontinued|approved|divested`',
    `atc_code` STRING COMMENT 'WHO Anatomical Therapeutic Chemical (ATC) classification code assigned to the investigational asset, classifying drugs by organ/system acted on and therapeutic, pharmacological, and chemical properties. Used for portfolio analytics and WHO-DD alignment.. Valid values are `^[A-Z][0-9]{2}[A-Z]{2}[0-9]{2}$`',
    `brand_name_candidate` STRING COMMENT 'Proposed proprietary/trade name candidate for the investigational product, subject to regulatory review and approval by FDA, EMA, or other health authorities. May change prior to marketing authorization.',
    `breakthrough_therapy_designation` BOOLEAN COMMENT 'Indicates whether the FDA has granted Breakthrough Therapy Designation (BTD) to this asset, providing intensive FDA guidance and organizational commitment to expedite development of drugs showing substantial improvement over available therapy.',
    `clinicaltrials_gov_number` STRING COMMENT 'Primary ClinicalTrials.gov registry identifier (NCT number) associated with the lead clinical study for this pipeline asset. Enables public registry linkage and WHO ICTRP compliance for trial transparency.. Valid values are `^NCT[0-9]{8}$`',
    `compound_name` STRING COMMENT 'The chemical or biological compound name assigned by the sponsor during discovery and early development. May be a systematic IUPAC name, a proprietary internal name, or a code name prior to INN assignment.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the pipeline asset record was first created in the system of record (Veeva Vault or the source system Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `cta_number` STRING COMMENT 'Regulatory authority-assigned Clinical Trial Authorisation (CTA) number for the investigational asset in the European Union or other jurisdictions (e.g., EMA, MHRA, Health Canada). Equivalent to IND for non-U.S. markets.',
    `development_phase` STRING COMMENT 'Current clinical development phase of the investigational asset per ICH E8 and FDA/EMA phase definitions. Drives portfolio prioritization, resource allocation, and regulatory strategy.',
    `discontinuation_date` DATE COMMENT 'Date on which development of the investigational asset was formally discontinued by the sponsor. Null if the asset is still active. Used for portfolio attrition analysis and lessons-learned reporting.',
    `discontinuation_reason` STRING COMMENT 'Primary reason for discontinuation of the investigational assets development program. Used for portfolio attrition analysis, R&D productivity reporting, and lessons-learned processes.',
    `dosage_form` STRING COMMENT 'The physical form of the investigational product as administered (e.g., tablet, capsule, solution for injection, lyophilized powder, patch, inhaler). Aligns with EDQM Standard Terms and FDA/EMA pharmaceutical form classifications.',
    `drug_class` STRING COMMENT 'Pharmacological or therapeutic drug class of the investigational asset (e.g., kinase inhibitor, monoclonal antibody, CAR-T, CRISPR-based therapy, PD-1 inhibitor). Aligns with WHO-DD and MedDRA classification conventions.',
    `eudract_number` STRING COMMENT 'European Union Drug Regulating Authorities Clinical Trials (EudraCT) number or EU Clinical Trials Information System (CTIS) identifier for the lead EU clinical study of this asset. Required for EU trial registration under EU CTR 536/2014.. Valid values are `^[0-9]{4}-[0-9]{6}-[0-9]{2}$`',
    `fast_track_designation` BOOLEAN COMMENT 'Indicates whether the FDA has granted Fast Track designation to this investigational asset, facilitating more frequent interactions with FDA and rolling review to expedite development of drugs treating serious conditions with unmet medical need.',
    `filing_status` STRING COMMENT 'Current status of the marketing authorization application (NDA/BLA/MAA) with the primary regulatory authority. Tracks the assets progression through the regulatory review lifecycle.',
    `first_in_human_date` DATE COMMENT 'Date on which the first-in-human (FIH) clinical study was initiated for this investigational asset, marking the transition from preclinical to clinical development. Key milestone for development timeline tracking.',
    `ind_submission_date` DATE COMMENT 'Date on which the Investigational New Drug (IND) application or Clinical Trial Authorisation (CTA) was first submitted to the primary regulatory authority. Key regulatory milestone for development timeline reporting.',
    `inn` STRING COMMENT 'The WHO-assigned International Nonproprietary Name (INN) for the active substance. Assigned by the WHO INN Programme and used in regulatory submissions, labeling, and scientific literature. May be null for assets not yet assigned an INN.',
    `market_exclusivity_expiry_date` DATE COMMENT 'Date on which regulatory market exclusivity (e.g., FDA 5-year NCE exclusivity, 12-year biologic exclusivity, 7-year orphan drug exclusivity, or EMA 10-year data exclusivity) expires. Distinct from patent expiry and drives commercial strategy.',
    `mechanism_of_action` STRING COMMENT 'Detailed description of the biochemical interaction through which the investigational asset produces its pharmacological effect (e.g., selective inhibition of EGFR tyrosine kinase, agonism of GLP-1 receptor).',
    `meddra_indication_code` STRING COMMENT 'MedDRA (Medical Dictionary for Regulatory Activities) Preferred Term (PT) code for the primary target indication. Enables standardized cross-study safety and efficacy reporting aligned with ICH E2 and regulatory submission requirements.. Valid values are `^[0-9]{8}$`',
    `modality` STRING COMMENT 'The therapeutic modality or platform technology of the investigational asset, classifying the fundamental nature of the compound. [ENUM-REF-CANDIDATE: small_molecule|biologic|gene_therapy|cell_therapy|medical_device|oligonucleotide|radiopharmaceutical —',
    `nda_bla_maa_submission_date` DATE COMMENT 'Date on which the marketing authorization application (NDA, BLA, or MAA) was submitted to the primary regulatory authority. Null if the asset has not yet reached the filing stage.',
    `orphan_drug_designation` BOOLEAN COMMENT 'Indicates whether the investigational asset has received Orphan Drug Designation (ODD) from FDA (under Orphan Drug Act) or EMA (under EC Regulation 141/2000), conferring market exclusivity, fee waivers, and development incentives for rare diseases.',
    `patent_expiry_date` DATE COMMENT 'Date on which the primary composition-of-matter or method-of-use patent for the investigational asset expires. Critical for commercial lifecycle planning, exclusivity strategy, and business development decisions.',
    `pediatric_investigation_plan` BOOLEAN COMMENT 'Indicates whether a Pediatric Investigation Plan (PIP, EMA) or Pediatric Study Plan (PSP, FDA) has been agreed with the regulatory authority for this asset. Required for most new medicines under PREA (FDA) and EU Pediatric Regulation.',
    `primary_regulatory_authority` STRING COMMENT 'The lead regulatory authority for the assets primary marketing authorization filing (e.g., FDA for U.S., EMA for EU, PMDA for Japan). Determines the regulatory strategy and submission format (eCTD).',
    `prime_designation` BOOLEAN COMMENT 'Indicates whether the EMA has granted PRIME (PRIority MEdicines) designation to this asset, providing enhanced support for development of medicines that target an unmet medical need in the EU.',
    `risk_management_plan_required` BOOLEAN COMMENT 'Indicates whether a Risk Management Plan (RMP) is required by EMA or other regulatory authorities for this investigational asset as part of the marketing authorization application or post-approval commitments.',
    `route_of_administration` STRING COMMENT 'The intended route by which the investigational product is administered to subjects (e.g., oral, intravenous, subcutaneous). Critical for formulation development, clinical protocol design, and regulatory submissions.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the pipeline asset record was most recently modified in the system of record. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    CONSTRAINT pk_pipeline_asset PRIMARY KEY(`pipeline_asset_id`)
) COMMENT 'Master record for investigational drug, biologic, or device assets in a sponsors development pipeline. Captures compound/molecule name, INN (International Nonproprietary Name), brand name candidate, drug class, mechanism of action, modality (small';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` (
    `pipeline_asset_phase_id` BIGINT COMMENT 'Unique surrogate identifier for each pipeline asset phase record. Primary key for the pipeline_asset_phase data product in the sponsor domain.',
    `ind_application_id` BIGINT COMMENT 'Foreign key linking to regulatory.ind_application. Business justification: Each development phase is covered by a specific IND. Phase-level regulatory tracking requires linking to the IND for clinical hold status, phase coverage scope, and annual report',
    `indication_id` BIGINT COMMENT 'Foreign key linking to program.indication. Business justification: Each phase of a pipeline asset targets a specific indication. pipeline_asset_phase has indication as a denormalized plain text field and meddra_indication_code.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization that owns and funds the pipeline asset and its associated clinical development program.',
    `pipeline_asset_id` BIGINT COMMENT 'Reference to the parent pipeline asset (drug, biologic, or device candidate) for which this phase record is being tracked. Links the phase history to the asset master.',
    `regulatory_program_milestone_id` BIGINT COMMENT 'Foreign key to the canonical regulatory milestone in regulatory domain',
    `therapeutic_area_id` BIGINT COMMENT 'Foreign key linking to program.therapeutic_area. Business justification: Pipeline asset phases are classified by therapeutic area for development planning. pipeline_asset_phase has therapeutic_area as a denormalized plain text field.',
    `accelerated_approval_pathway` BOOLEAN COMMENT 'Indicates whether the pipeline asset is being developed under an accelerated approval pathway (FDA Accelerated Approval, EMA Conditional Marketing Authorization, or equivalent) during this phase.',
    `actual_enrollment` BIGINT COMMENT 'Actual total number of subjects enrolled across all studies conducted during this development phase. Compared against estimated_enrollment to assess recruitment performance.',
    `actual_spend_usd` DECIMAL(18,2) COMMENT 'Total actual expenditure incurred by the sponsor for all clinical development activities within this phase to date, expressed in US Dollars. Used for budget variance analysis and portfolio financial reporting.',
    `breakthrough_designation` BOOLEAN COMMENT 'Indicates whether the FDA has granted Breakthrough Therapy Designation for this pipeline asset during this phase, enabling more intensive FDA guidance and expedited development.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this pipeline asset phase record was first created in the system. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `csr_submission_date` DATE COMMENT 'Date on which the Clinical Study Report (CSR) for the primary study in this phase was submitted to the regulatory authority. Key milestone for regulatory timeline tracking and eCTD compilation.',
    `data_cutoff_date` DATE COMMENT 'Date through which clinical data was collected and included in the primary analysis for this phase. Aligns with the Database Lock (DBL) date for the pivotal study in the phase.',
    `database_lock_date` DATE COMMENT 'Date on which the clinical database for the primary study in this phase was formally locked, preventing further data entry or modification. Marks the start of final statistical analysis.',
    `dsmb_review_required` BOOLEAN COMMENT 'Indicates whether a Data Safety Monitoring Board (DSMB) or Data Monitoring Committee (DMC) review is required for studies conducted during this phase. Driven by regulatory requirements and study risk profile.',
    `estimated_enrollment` BIGINT COMMENT 'Planned total number of subjects to be enrolled across all studies conducted during this development phase. Used for resource planning, site selection, and feasibility assessment.',
    `fast_track_designation` BOOLEAN COMMENT 'Indicates whether the FDA has granted Fast Track Designation for this pipeline asset during this phase, facilitating more frequent interactions with FDA and rolling review eligibility.',
    `geography_scope` STRING COMMENT 'Geographic scope of the clinical development activities conducted during this phase (e.g., USA, EU, Global, USA|EU|JPN). Drives regulatory strategy, submission planning, and site selection.',
    `go_no_go_decision` STRING COMMENT 'Sponsors portfolio governance decision to proceed to the next development phase, halt development, or proceed with conditions. Captured at phase completion gate review. Null if phase is still active.. Valid values are `go|no_go|conditional_go|pending`',
    `go_no_go_decision_date` DATE COMMENT 'Calendar date on which the sponsors portfolio governance committee formally issued the go/no-go decision for this phase. Used for development timeline tracking and portfolio reporting.',
    `lead_regulatory_agency` STRING COMMENT 'Primary regulatory agency overseeing the clinical development activities for this phase. Determines the applicable regulatory framework, submission requirements, and reporting obligations.',
    `meddra_indication_code` STRING COMMENT 'MedDRA Preferred Term (PT) code for the target indication studied during this phase. Enables standardized cross-study and cross-sponsor indication analysis aligned with regulatory submission requirements.. Valid values are `^[0-9]{8}$`',
    `orphan_drug_designation` BOOLEAN COMMENT 'Indicates whether the pipeline asset has received Orphan Drug Designation from the FDA (ODD) or EMA (OMP) for the indication studied in this phase, conferring regulatory incentives and market exclusivity benefits.',
    `phase_budget_usd` DECIMAL(18,2) COMMENT 'Total approved budget allocated by the sponsor for all clinical development activities within this phase, expressed in US Dollars. Classified as confidential due to commercially sensitive financial content.',
    `phase_code` STRING COMMENT 'Standardized code representing the clinical development phase of the pipeline asset. Covers the full continuum from preclinical research through post-marketing.',
    `phase_duration_days` BIGINT COMMENT 'Actual number of calendar days elapsed during this development phase, calculated from phase_start_date to phase_end_date. Null if the phase is still active. Used for benchmarking development timelines against industry standards.',
    `phase_end_date` DATE COMMENT 'Calendar date on which the pipeline asset completed or exited this development phase. Null if the phase is still active. Used to calculate phase duration and development timelines.',
    `phase_name` STRING COMMENT 'Human-readable display name for the clinical development phase (e.g., Phase I, Phase IIb, NDA/BLA Submission). Used in reports, dashboards, and regulatory documents.',
    `phase_sequence_number` BIGINT COMMENT 'Ordinal sequence number representing the chronological order of this phase record within the pipeline assets development history. Enables correct ordering of phase transitions for longitudinal analysis.',
    `phase_start_date` DATE COMMENT 'Calendar date on which the pipeline asset formally entered this development phase. For Phase I, this typically aligns with first-in-human (FIH) dosing; for NDA/BLA, with submission filing date.',
    `phase_status` STRING COMMENT 'Current operational status of the pipeline asset within this development phase. Indicates whether the phase is actively progressing, has been completed, is temporarily suspended, or has been terminated.. Valid values are `active|completed|on_hold|terminated|planned`',
    `planned_phase_end_date` DATE COMMENT 'Originally planned calendar date for the pipeline asset to complete this development phase. Used to measure schedule variance and forecast downstream phase timelines.',
    `planned_phase_start_date` DATE COMMENT 'Originally planned calendar date for the pipeline asset to enter this development phase, as defined in the integrated development plan. Used to measure schedule variance against actual start.',
    `previous_phase_code` STRING COMMENT 'Phase code of the immediately preceding development phase for this pipeline asset. Enables direct traversal of the phase history chain without requiring a self-join. Null for the first phase record.',
    `primary_endpoint_met` BOOLEAN COMMENT 'Indicates whether the primary efficacy or safety endpoint defined for this development phase was met upon phase completion. True = primary endpoint achieved; False = not achieved; Null = phase not yet completed or endpoint not yet evaluated.',
    `regulatory_milestone_achieved` STRING COMMENT 'Description of the key regulatory milestone achieved upon completion or during this phase (e.g., IND Clearance, End-of-Phase-II Meeting, NDA Acceptance, Breakthrough Therapy Designation). Null if no milestone was achieved.',
    `regulatory_milestone_date` DATE COMMENT 'Calendar date on which the regulatory milestone associated with this phase was formally achieved or received. Used for regulatory timeline tracking and submission planning.',
    `regulatory_strategy_notes` STRING COMMENT 'Free-text field capturing the sponsors regulatory strategy for this phase, including planned agency interactions, submission strategy, and any special regulatory considerations. Classified as confidential due to commercially sensitive strategic content.',
    `study_count` BIGINT COMMENT 'Number of clinical studies (protocols) conducted under this pipeline asset phase. Provides a measure of the breadth of evidence generation within the phase.',
    `termination_reason_category` STRING COMMENT 'Standardized category for the primary reason a phase was terminated. Enables portfolio-level analysis of attrition drivers across the development pipeline. Null if phase was not terminated.. Valid values are `safety|efficacy|commercial|regulatory|strategic|operational`',
    `transition_reason` STRING COMMENT 'Narrative explanation for why the pipeline asset transitioned into or out of this development phase. Captures scientific, regulatory, commercial, or safety rationale for phase progression, hold, or termination.',
    `transition_type` STRING COMMENT 'Categorical classification of the type of phase transition event. Distinguishes between forward progression, temporary hold, full termination, restart after hold, or protocol amendment-driven transition.. Valid values are `progression|hold|termination|restart|amendment`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this pipeline asset phase record was most recently modified. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    CONSTRAINT pk_pipeline_asset_phase PRIMARY KEY(`pipeline_asset_phase_id`)
) COMMENT 'Tracks the development phase history and transitions of a pipeline asset across its lifecycle. Captures phase (preclinical, Phase I, Phase Ib, Phase II, Phase IIa, Phase IIb, Phase III, Phase IV, NDA/BLA submission, approved), phase start date, phase end';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` (
    `study_portfolio_id` BIGINT COMMENT 'Unique surrogate identifier for the study portfolio record. Primary key for the sponsor.study_portfolio data product in the Databricks Silver Layer.',
    `employee_id` BIGINT COMMENT 'Reference to the CRO (Contract Research Organization) internal employee designated as the portfolio lead or executive sponsor for this sponsor relationship. Drives accountability and escalation routing.',
    `organization_contact_id` BIGINT COMMENT 'Reference to the primary sponsor-side contact person responsible for this portfolio (e.g., sponsors VP of Clinical Operations or Program Director). Used for escalation, governance meetings, and contract management.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization that owns and funds this study portfolio. Links to the sponsor master record.',
    `sponsor_engagement_id` BIGINT COMMENT 'Foreign key linking to sponsor.engagement. Business justification: A study portfolio represents the contracted study portfolio within a sponsor-CRO commercial engagement.',
    `therapeutic_area_id` BIGINT COMMENT 'Foreign key linking to program.therapeutic_area. Business justification: Study portfolios are organized by therapeutic area for strategic planning and resource allocation. study_portfolio has therapeutic_area as a denormalized plain text field.',
    `active_study_count` BIGINT COMMENT 'Number of clinical studies currently in active execution status within this portfolio. Key operational KPI for portfolio health monitoring and resource utilization.',
    `cdisc_compliance_required` BOOLEAN COMMENT 'Indicates whether the portfolio requires CDISC (Clinical Data Interchange Standards Consortium) compliant data submissions (SDTM/ADaM). Mandatory for FDA and EMA regulatory submissions; drives data management planning.',
    `country_count` BIGINT COMMENT 'Total number of countries in which studies under this portfolio are being or will be conducted. Used for regulatory complexity assessment and global operations planning.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the study portfolio record was first created in the system. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the portfolio budget and financial reporting (e.g., USD, EUR, GBP, JPY). Enables multi-currency portfolio reporting for global sponsors.. Valid values are `^[A-Z]{3}$`',
    `data_management_system` STRING COMMENT 'Primary Electronic Data Capture (EDC) or data management system used for clinical data collection across the portfolios studies (e.g., Medidata Rave, the source system Drives data integration and CDISC compliance planning.. Valid values are `medidata_rave|oracle_clinical_one|veeva_vault_edl|other`',
    `development_phase` STRING COMMENT 'Predominant clinical development phase of studies within the portfolio (Phase 1 through Phase 4, or Mixed for portfolios spanning multiple phases). Informs regulatory strategy and resource planning.. Valid values are `phase_1|phase_2|phase_3|phase_4|mixed`',
    `geographic_scope` STRING COMMENT 'Description of the geographic regions or countries covered by the portfolios studies (e.g., North America, EU, Asia-Pacific). Informs site selection strategy, regulatory planning, and resource deployment.',
    `icf_management_system` STRING COMMENT 'System used for Informed Consent Form (ICF) management and eConsent across the portfolios studies (e.g., Clinpal for eConsent, paper-based, Veeva Vault). Drives patient engagement and regulatory compliance for consent documentation.. Valid values are `clinpal|paper|veeva_vault|other`',
    `indication` STRING COMMENT 'Specific disease or medical condition targeted by the portfolios studies (e.g., Non-Small Cell Lung Cancer, Type 2 Diabetes Mellitus). Provides finer granularity than therapeutic area for portfolio analytics and regulatory alignment.',
    `irb_iec_oversight_model` STRING COMMENT 'Institutional Review Board (IRB) or Independent Ethics Committee (IEC) oversight model applied across the portfolio. central_irb uses a single central IRB; local_irb requires site-level IRB approvals; mixed combines both approaches.. Valid values are `central_irb|local_irb|iec|mixed`',
    `kpi_data_query_rate` DECIMAL(5,2) COMMENT 'Portfolio-level KPI target for the maximum acceptable data query rate (percentage of data points generating queries) across Electronic Data Capture (EDC) systems. Reflects data quality expectations set by the sponsor.',
    `kpi_enrollment_target` BIGINT COMMENT 'Portfolio-level Key Performance Indicator (KPI) target for total subject enrollment across all studies in the portfolio. Used for sponsor-level performance reporting and CRO accountability tracking.',
    `kpi_site_activation_days` BIGINT COMMENT 'Portfolio-level KPI target for the maximum number of days from site selection to site activation. Benchmarks CRO operational efficiency for the sponsor across all studies in the portfolio.',
    `notes` STRING COMMENT 'Operational notes, special instructions, or sponsor-specific requirements associated with the portfolio. Used by CRO project management and account management teams for day-to-day portfolio governance.',
    `portfolio_budget_usd` DECIMAL(18,2) COMMENT 'Total contracted budget value for the study portfolio in US Dollars, as agreed in the master service agreement. Serves as the financial ceiling for portfolio-level cost tracking and sponsor billing in the source system',
    `portfolio_code` STRING COMMENT 'Externally-known alphanumeric business identifier for the study portfolio, used in sponsor communications, CTMS references, and contract documentation. Unique per sponsor.. Valid values are `^[A-Z0-9_-]{3,30}$`',
    `portfolio_description` STRING COMMENT 'Free-text narrative description of the portfolios scientific rationale, business objectives, and scope. Provides context for CRO teams, governance committees, and sponsor relationship management.',
    `portfolio_end_date` DATE COMMENT 'Planned or actual date on which the portfolio relationship concludes. Null for open-ended portfolios. Used for contract lifecycle management and resource wind-down planning.',
    `portfolio_name` STRING COMMENT 'Human-readable name of the study portfolio as agreed with the sponsor, typically reflecting the therapeutic area or drug program (e.g., Oncology Phase II-III Pipeline 2024). Treated as confidential sponsor business information.',
    `portfolio_start_date` DATE COMMENT 'Date on which the study portfolio relationship became effective and the CRO began providing services under this portfolio grouping. Aligns with the master service agreement or first study contract activation.',
    `portfolio_status` STRING COMMENT 'Current lifecycle state of the study portfolio. active indicates studies are ongoing; wind_down indicates the portfolio is transitioning to close-out; completed indicates all studies are closed; suspended indicates operations are paused; pending. Valid values are `active|wind_down|completed|suspended|pending`',
    `primary_regulatory_agency` STRING COMMENT 'The lead regulatory authority governing the portfolios studies (e.g., FDA for US-centric programs, EMA for EU, PMDA for Japan). Drives submission format, timeline, and compliance requirements.',
    `rtsm_required` BOOLEAN COMMENT 'Indicates whether Randomization and Trial Supply Management (RTSM) / Interactive Response Technology (IRT) is required for studies in this portfolio. Drives Medidata Rave RTSM or equivalent system configuration.',
    `safety_reporting_standard` STRING COMMENT 'Applicable safety reporting standard governing Adverse Event (AE) and Serious Adverse Event (SAE) reporting for the portfolio (e.g., ICH E2A for expedited reporting, ICH E2B(R3) for electronic case safety reports, CTCAE v5 for grading).. Valid values are `ich_e2a|ich_e2b_r3|ctcae_v5|other`',
    `site_count_target` BIGINT COMMENT 'Planned total number of investigational sites to be activated across all studies in the portfolio. Used for feasibility planning, CRA (Clinical Research Associate) resource allocation, and sponsor reporting.',
    `source_system_record_reference` STRING COMMENT 'Native identifier of this portfolio record in the originating operational system (e.g., Siebel CTMS Portfolio ID, the source system Enables traceability from the Silver Layer back to the system of record.',
    `strategic_priority_tier` STRING COMMENT 'Sponsor-assigned strategic priority classification for the portfolio. Tier 1 = highest priority (flagship programs); Tier 2 = standard priority; Tier 3 = exploratory or lower-priority programs. Drives CRO resource allocation and executive attention.. Valid values are `tier_1|tier_2|tier_3`',
    `submission_type` STRING COMMENT 'Type of regulatory submission targeted by the portfolio (e.g., IND - Investigational New Drug, NDA - New Drug Application, BLA - Biologics License Application, MAA - Marketing Authorization Application). Determines regulatory deliverables and timelines.',
    `tmf_system` STRING COMMENT 'System used for Trial Master File (TMF) or electronic Trial Master File (eTMF) management across the portfolio (e.g., Veeva Vault eTMF). Ensures regulatory inspection readiness and document completeness per ICH E6(R2).. Valid values are `veeva_vault_etmf|paper_tmf|other`',
    `total_study_count` BIGINT COMMENT 'Total number of clinical studies contracted under this portfolio, including active, completed, and wind-down studies. Used for portfolio sizing and capacity planning.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the study portfolio record. Supports change tracking, audit trail compliance, and Silver Layer data freshness monitoring.',
    CONSTRAINT pk_study_portfolio PRIMARY KEY(`study_portfolio_id`)
) COMMENT 'Represents the contracted study portfolio relationship between a sponsor organization and the CRO, linking sponsor organizations to the clinical studies they have commissioned.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` (
    `sponsor_engagement_id` BIGINT COMMENT 'Unique system-generated identifier for the CRO-sponsor commercial engagement relationship record. Primary key for the engagement entity.',
    `clinical_program_id` BIGINT COMMENT 'Foreign key linking to program.clinical_program. Business justification: CRO account engagements are scoped to specific clinical programs for revenue forecasting and resource planning.',
    `master_agreement_id` BIGINT COMMENT 'Foreign key linking to sponsor.master_agreement. Business justification: An engagement is governed by a master service agreement (preferred provider agreement). The engagement table currently stores master_service_agreement_ref as a free-text string.',
    `master_service_agreement_id` BIGINT COMMENT 'Foreign key linking to agreement.master_service_agreement. Business justification: Engagements are governed by an executed MSA that defines legal terms, liability caps, and audit rights.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization that is the counterparty in this commercial engagement.',
    `therapeutic_area_id` BIGINT COMMENT 'Foreign key linking to program.therapeutic_area. Business justification: Engagements are scoped by therapeutic area for CRO capability alignment and account planning. engagement has therapeutic_area_focus as a denormalized plain text field.',
    `account_plan_period_end` DATE COMMENT 'End date of the strategic account planning period, marking the horizon for annual or multi-year objectives and revenue targets defined in the account plan.',
    `account_plan_period_start` DATE COMMENT 'Start date of the strategic account planning period (typically annual or multi-year) for which objectives, revenue targets, and relationship goals are defined.',
    `account_plan_status` STRING COMMENT 'Current workflow status of the strategic account plan associated with this engagement. Controls plan visibility, approval routing, and activation for account management execution.. Valid values are `draft|approved|active|closed`',
    `active_study_count` BIGINT COMMENT 'Number of clinical studies currently active under this engagement. Used for capacity planning, account management reporting, and portfolio performance dashboards.',
    `annual_revenue_target` DECIMAL(18,2) COMMENT 'CRO-defined annual revenue target for this sponsor engagement, used in strategic account planning and business development performance tracking.',
    `competitive_threats` STRING COMMENT 'Documented assessment of competing CROs or internal sponsor capabilities that pose a risk to retaining or growing this engagement. Used in strategic account planning and win/loss analysis.',
    `confidentiality_agreement_ref` STRING COMMENT 'Reference number or identifier of the Non-Disclosure Agreement (NDA) or Confidentiality Disclosure Agreement (CDA) executed between the CRO and sponsor for this engagement.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this engagement record was first created in the system, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Supports audit trail and data lineage requirements.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which the engagement financial values are denominated (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `data_privacy_framework` STRING COMMENT 'Applicable data privacy regulatory framework(s) governing the handling of sponsor and patient data within this engagement (e.g., GDPR for EU studies, HIPAA for US studies).. Valid values are `GDPR|HIPAA|PIPEDA|PDPA|combined|not_applicable`',
    `end_date` DATE COMMENT 'Calendar date on which the CRO-sponsor engagement relationship is scheduled to conclude or was terminated. Nullable for open-ended strategic relationships.',
    `engagement_code` STRING COMMENT 'Externally-known alphanumeric business identifier for the engagement, used in contracts, invoices, and cross-system references (e.g., ENG-2024-PFZ-001).. Valid values are `^[A-Z0-9-]{4,20}$`',
    `engagement_name` STRING COMMENT 'Human-readable business name for the CRO-sponsor engagement relationship, typically referencing the sponsor name and scope (e.g., Pfizer Oncology Full-Service CRO 2024).',
    `engagement_type` STRING COMMENT 'Classification of the commercial engagement model between the CRO and sponsor. Full-service CRO covers end-to-end trial management; Functional Service Provider (FSP) covers specific functions; co-development involves shared risk/reward; preferred provider. Valid values are `full_service_cro|functional_service_provider|co_development|preferred_provider|standalone`',
    `escalation_count_ytd` BIGINT COMMENT 'Number of formal escalations raised by the sponsor or CRO within the current calendar year for this engagement. Used as a relationship health indicator and input to CAPA tracking.',
    `governance_cadence` STRING COMMENT 'Planned frequency of formal governance touchpoints (joint steering committee, operational review meetings) between the CRO and sponsor for this engagement.. Valid values are `monthly|quarterly|semi_annual|annual|ad_hoc`',
    `key_sponsor_stakeholders` STRING COMMENT 'Documented list of key sponsor-side stakeholders to engage (e.g., VP Clinical Operations, Chief Medical Officer, Head of Procurement), including their roles and engagement priorities as part of the account plan.',
    `last_governance_date` DATE COMMENT 'Date of the most recently completed formal governance touchpoint between the CRO and sponsor, used to track cadence compliance and relationship engagement.',
    `next_governance_date` DATE COMMENT 'Scheduled date of the next formal governance touchpoint (e.g., joint steering committee or operational review) between the CRO and sponsor for this engagement.',
    `notes` STRING COMMENT 'Free-text field for account managers to capture strategic context, relationship nuances, sponsor preferences, or other qualitative information relevant to managing this engagement.',
    `pipeline_opportunity_value` DECIMAL(18,2) COMMENT 'Estimated monetary value of identified pipeline opportunities (new studies, expanded scope) within this sponsor engagement, used in business development forecasting.',
    `preferred_provider_flag` BOOLEAN COMMENT 'Indicates whether this engagement operates under a formal preferred provider or strategic alliance agreement, granting the CRO preferred access to the sponsors study pipeline.',
    `primary_geography` STRING COMMENT 'ISO 3166-1 alpha-3 country code representing the primary geographic market or regulatory jurisdiction for this engagement (e.g., USA, GBR, DEU).. Valid values are `^[A-Z]{3}$`',
    `regulatory_regions` STRING COMMENT 'Comma-delimited list of regulatory regions covered by this engagement (e.g., US, EU, Japan, Australia), determining applicable regulatory submission requirements and governing body oversight.',
    `relationship_development_goals` STRING COMMENT 'Documented goals for deepening the CRO-sponsor relationship, such as executive sponsor introductions, joint innovation initiatives, or expanding into new therapeutic areas.',
    `relationship_health_score` DECIMAL(5,2) COMMENT 'Quantitative score (0–100) reflecting the overall health and strength of the CRO-sponsor relationship, derived from sponsor satisfaction surveys, KPI performance, escalation frequency, and governance participation.',
    `revenue_target_biostatistics` DECIMAL(18,2) COMMENT 'Annual revenue target attributed to the Biostatistics and Statistical Programming service line (the source system, ADaM, CSR) within this engagement.',
    `revenue_target_clinical_ops` DECIMAL(18,2) COMMENT 'Annual revenue target attributed to the Clinical Operations service line within this engagement, used for service-line-level business development tracking and P&L reporting.',
    `revenue_target_data_management` DECIMAL(18,2) COMMENT 'Annual revenue target attributed to the Data Management service line (EDC, eCRF, CDISC transformation) within this engagement.',
    `revenue_target_regulatory` DECIMAL(18,2) COMMENT 'Annual revenue target attributed to the Regulatory Affairs service line (IND, NDA, BLA, MAA submissions) within this engagement.',
    `service_lines_in_scope` STRING COMMENT 'Comma-delimited list of CRO service lines included in this engagement (e.g., Clinical Operations, Biostatistics, Data Management, Regulatory Affairs, Safety). Defines the functional scope of the CRO-sponsor relationship.',
    `sponsor_satisfaction_score` DECIMAL(5,2) COMMENT 'Most recent sponsor satisfaction survey score (0–10 scale) for this engagement, collected through formal CRO quality management processes. Distinct from the internally-derived relationship health score.',
    `start_date` DATE COMMENT 'Calendar date on which the CRO-sponsor engagement relationship formally commenced, as defined in the master service agreement or preferred provider agreement.',
    `sponsor_engagement_status` STRING COMMENT 'Current lifecycle state of the CRO-sponsor commercial engagement. Drives pipeline reporting, account management workflows, and governance cadence. [ENUM-REF-CANDIDATE: prospect|active|on_hold|closed_won|closed_lost|terminated — promote to reference',
    `strategic_account_tier` STRING COMMENT 'CRO-assigned strategic segmentation tier for the sponsor account, reflecting revenue potential, relationship depth, and investment priority. Tier 1 represents the highest-value strategic accounts receiving maximum CRO resource allocation.. Valid values are `tier_1|tier_2|tier_3|tier_4`',
    `strategic_objectives` STRING COMMENT 'Free-text description of the annual or multi-year strategic objectives for this CRO-sponsor engagement, as documented in the strategic account plan (e.g., expand into Phase III oncology, achieve preferred provider status).',
    `total_contracted_value` DECIMAL(18,2) COMMENT 'Aggregate monetary value of all contracts and work orders executed under this engagement, expressed in the engagement currency. Represents the full financial scope of the CRO-sponsor relationship.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this engagement record, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Supports audit trail and change tracking per ALCOA+ principles.',
    CONSTRAINT pk_sponsor_engagement PRIMARY KEY(`sponsor_engagement_id`)
) COMMENT 'Master record for the commercial engagement relationship between a sponsor and the CRO, representing the overarching business relationship spanning multiple studies and contracts.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` (
    `master_agreement_id` BIGINT COMMENT 'Primary key for master_agreement',
    `master_service_agreement_id` BIGINT COMMENT 'Foreign key linking to agreement.master_service_agreement. Business justification: The CROs internal sponsor preferred provider agreement record must reference the executed MSA in the agreement domain for contract governance, legal audit trails, and',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization that is party to this master agreement.',
    `preferred_provider_agreement_id` BIGINT COMMENT 'Foreign key linking to agreement.preferred_provider_agreement. Business justification: The sponsor.master_agreement (CROs internal PPA record) must reference the formal executed preferred_provider_agreement for contract reconciliation, volume commitment',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — master agreements may govern specific studies',
    `therapeutic_area_id` BIGINT COMMENT 'Foreign key linking to program.therapeutic_area. Business justification: Master agreements are scoped to specific therapeutic areas defining CRO service capabilities. master_agreement has therapeutic_area_scope as a denormalized plain text field.',
    `agreement_name` STRING COMMENT 'Descriptive title of the master agreement (e.g., Global MSA — Sponsor XYZ 2024), used for identification in the Clinical Trial Management System (CTMS) and contract repositories.',
    `agreement_number` STRING COMMENT 'Externally-known unique reference number or code assigned to this master agreement, used in correspondence, invoicing, and regulatory documentation between the sponsor and CRO.',
    `agreement_status` STRING COMMENT 'Current lifecycle state of the master agreement. Tracks progression from drafting through execution, active operation, and eventual expiration or termination.',
    `agreement_type` STRING COMMENT 'Classification of the master agreement structure. MSA = Master Service Agreement (full-service framework); preferred_provider = preferred provider agreement; FSP_master = Functional Service Provider (FSP) master agreement; alliance = strategic alliance. Valid values are `MSA|preferred_provider|FSP_master|alliance|strategic_partnership`',
    `amendment_count` BIGINT COMMENT 'Total number of formal amendments executed against this master agreement since its original execution. Supports version tracking and audit trail requirements.',
    `audit_rights_flag` BOOLEAN COMMENT 'Indicates whether the sponsor retains the right to audit the CROs operations, records, and facilities under this master agreement, as required by GCP and regulatory guidelines.',
    `confidentiality_term_years` BIGINT COMMENT 'Number of years post-termination or expiration during which confidentiality obligations remain in force under this master agreement. Relevant for GDPR, HIPAA, and ICH data retention compliance.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this master agreement record was first created in the system, conforming to ALCOA+ data integrity principles for audit trail completeness.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for all financial terms expressed in this master agreement (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `data_privacy_framework` STRING COMMENT 'Primary data privacy regulatory framework governing personal and clinical data handling obligations under this master agreement.. Valid values are `GDPR|HIPAA|PIPEDA|PDPA|combined|not_applicable`',
    `dispute_resolution_mechanism` STRING COMMENT 'Contractually agreed mechanism for resolving disputes arising under this master agreement.. Valid values are `arbitration|mediation|litigation|expert_determination`',
    `effective_date` DATE COMMENT 'The date on which the master agreement becomes legally binding and commercially operative between the sponsor and the CRO.',
    `etmf_plan_reference` STRING COMMENT 'Reference identifier for the eTMF plan or agreement that governs document management responsibilities under studies executed within this master agreement framework. Stored in Veeva Vault eTMF.',
    `execution_date` DATE COMMENT 'The date on which all required parties formally signed and executed the master agreement, establishing legal enforceability.',
    `expiration_date` DATE COMMENT 'The date on which the master agreement is scheduled to expire unless renewed. Nullable for open-ended agreements. Drives renewal notifications and governance reviews.',
    `force_majeure_clause_flag` BOOLEAN COMMENT 'Indicates whether the master agreement includes a force majeure clause that suspends obligations in the event of extraordinary circumstances beyond the parties control.',
    `geographic_scope` STRING COMMENT 'Description of the geographic regions or countries in which this master agreement is operative (e.g., Global, North America, EU/EEA, APAC). Determines regulatory compliance obligations per jurisdiction.',
    `governance_committee_name` STRING COMMENT 'Name of the joint governance committee or steering committee established under this master agreement to oversee performance, escalations, and strategic alignment (e.g., Joint Steering Committee, Alliance Management Board).',
    `governance_review_frequency` STRING COMMENT 'Agreed frequency of formal governance committee meetings to review performance metrics, KPIs, and strategic alignment under this master agreement.. Valid values are `monthly|quarterly|semi_annual|annual`',
    `governing_law_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the jurisdiction whose laws govern interpretation and enforcement of this master agreement (e.g., USA, GBR, DEU).. Valid values are `^[A-Z]{3}$`',
    `indemnification_cap_usd` DECIMAL(18,2) COMMENT 'Maximum aggregate liability cap in US dollars for indemnification obligations under this master agreement, as negotiated between the sponsor and CRO.',
    `initial_term_months` BIGINT COMMENT 'Duration in months of the initial binding term of the master agreement from the effective date.',
    `invoicing_frequency` STRING COMMENT 'Agreed frequency at which the CRO issues invoices to the sponsor under this master agreement framework.. Valid values are `monthly|quarterly|milestone|annual|upon_completion`',
    `ip_ownership_terms` STRING COMMENT 'Defines the intellectual property ownership arrangement for data, methodologies, and deliverables generated under studies executed within this master agreement framework.. Valid values are `sponsor_owned|shared|cro_licensed|jointly_developed`',
    `last_amendment_date` DATE COMMENT 'Date of the most recent formal amendment to this master agreement. Used to track currency of agreement terms and trigger re-review workflows.',
    `minimum_volume_commitment_usd` DECIMAL(18,2) COMMENT 'Minimum annual or total contracted spend commitment in US dollars that the sponsor agrees to award to the CRO under this master agreement. Triggers volume-based pricing discounts.',
    `payment_terms` STRING COMMENT 'Standard payment terms applicable to all study-level invoices issued under this master agreement (e.g., Net 30, Net 45, milestone-based). Sourced from the source system configuration.',
    `preferred_pricing_discount_pct` DECIMAL(5,2) COMMENT 'Percentage discount applied to standard CRO service rates under the preferred pricing terms of this master agreement. Expressed as a percentage (e.g., 12.50 = 12.5%).',
    `quality_agreement_reference` STRING COMMENT 'Reference number or identifier of the associated Quality Agreement (QA) document that defines GCP responsibilities and quality obligations between the sponsor and CRO under this master agreement. Stored in Veeva Vault or MasterControl.',
    `renewal_notice_days` BIGINT COMMENT 'Number of calendar days prior to expiration by which either party must provide written notice of intent to renew or terminate the agreement. Drives automated renewal alerts in the CTMS.',
    `renewal_term_months` BIGINT COMMENT 'Duration in months of each automatic or negotiated renewal period for the master agreement.',
    `service_scope_description` STRING COMMENT 'Narrative description of the CRO service categories covered under this master agreement (e.g., full-service CRO, FSP data management, biostatistics, regulatory affairs, pharmacovigilance).',
    `sponsor_executive_owner` STRING COMMENT 'Name or title of the senior sponsor-side executive accountable for this master agreement relationship (e.g., VP Clinical Operations, Chief Medical Officer).',
    `strategic_partnership_level` STRING COMMENT 'Classification of the commercial and strategic relationship tier between the CRO and the sponsor. Determines access to preferred pricing, dedicated resources, and governance escalation paths.. Valid values are `preferred|strategic|alliance|standard|emerging`',
    `termination_date` DATE COMMENT 'Actual date on which the master agreement was terminated, if applicable. Null if the agreement is still active or expired naturally.',
    `termination_for_convenience_notice_days` BIGINT COMMENT 'Number of calendar days written notice required by either party to terminate the master agreement for convenience (without cause).',
    `termination_reason` STRING COMMENT 'Reason for early termination of the master agreement, if terminated before natural expiration.. Valid values are `convenience|breach|mutual_agreement|regulatory|sponsor_insolvency|cro_insolvency`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this master agreement record, supporting audit trail and data lineage requirements per ALCOA+ principles.',
    `volume_commitment_tier` STRING COMMENT 'Contracted volume commitment tier that determines pricing discounts and service level entitlements. Higher tiers reflect greater committed study volume or spend.. Valid values are `tier_1|tier_2|tier_3|tier_4`',
    CONSTRAINT pk_master_agreement PRIMARY KEY(`master_agreement_id`)
) COMMENT 'Captures the terms and conditions of preferred provider or master service framework agreements between a sponsor and the CRO at the enterprise level, distinct from individual study contracts (which live in the agreement domain).';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` (
    `regulatory_strategy_id` BIGINT COMMENT 'Primary key for regulatory_strategy',
    `application_id` BIGINT COMMENT 'Foreign key linking to regulatory.application. Business justification: Sponsor regulatory strategy governs a specific regulatory application (IND, NDA/BLA, MAA).',
    `clinical_program_id` BIGINT COMMENT 'Reference to the clinical study program (development program) associated with this regulatory strategy, linking strategy to the portfolio of studies.',
    `cro_regulatory_lead_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Regulatory submission accountability requires a proper FK to the CRO regulatory affairs employee leading the strategy for FDA/EMA inspection readiness, health authority meeting',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: Sponsor regulatory strategy targets a specific lead health authority. Strategy authoring requires HA-specific clock days, submission format requirements, and review procedures.',
    `ind_application_id` BIGINT COMMENT 'Foreign key linking to regulatory.ind_application. Business justification: Sponsor regulatory strategy is authored around a specific IND, governing phase coverage, clinical hold response, and annual reporting obligations.',
    `indication_id` BIGINT COMMENT 'Foreign key linking to program.indication. Business justification: Regulatory strategies are indication-specific — submission pathways, endpoints, and health authority guidance differ by indication.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization that owns this regulatory strategy and funds the associated clinical program.',
    `regulatory_regulatory_strategy_id` BIGINT COMMENT 'Foreign key linking to regulatory.strategy. Business justification: Sponsor regulatory strategy (sponsor-side view) must align with the CRO operational regulatory strategy.',
    `therapeutic_area_id` BIGINT COMMENT 'Foreign key linking to program.therapeutic_area. Business justification: Regulatory strategies are TA-specific (different regulatory pathways, guidelines, and precedents apply per TA).',
    `actual_ind_submission_date` DATE COMMENT 'Actual date on which the IND application was submitted to the FDA. Enables variance analysis against planned submission dates for program performance reporting.',
    `actual_nda_bla_submission_date` DATE COMMENT 'Actual date on which the NDA, BLA, or MAA was submitted to the primary health authority. Used for regulatory milestone tracking and PDUFA/review clock management.',
    `additional_health_authorities` STRING COMMENT 'Comma-separated list of secondary health authorities targeted under the global harmonization approach (e.g., EMA, PMDA, Health Canada). Supports multi-regional submission planning aligned with ICH CTD/eCTD global dossier strategy.',
    `advisory_committee_required` BOOLEAN COMMENT 'Indicates whether an FDA Advisory Committee meeting is anticipated or required for the review of this NDA/BLA. Drives sponsor and CRO preparation activities for public advisory committee presentations.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this regulatory strategy record was first created in the system, supporting audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `designation_granted_date` DATE COMMENT 'Date on which the health authority officially granted the requested regulatory designation (e.g., Fast Track, Orphan Drug). Null if designation has not yet been granted.',
    `designation_status` STRING COMMENT 'Current status of the regulatory designation request (e.g., Fast Track, Breakthrough Therapy). Tracks whether the designation has been requested, granted, denied, or withdrawn by the health authority.. Valid values are `not_requested|requested|granted|denied|withdrawn`',
    `ectd_sequence_number` STRING COMMENT 'The eCTD sequence number assigned to the most recent submission under this regulatory strategy, enabling tracking of the electronic dossier lifecycle and amendment history.. Valid values are `^[0-9]{4}$`',
    `effective_date` DATE COMMENT 'Date on which this version of the regulatory strategy becomes the operative, approved document guiding regulatory activities for the associated program.',
    `expiry_date` DATE COMMENT 'Date on which this regulatory strategy version is scheduled to expire or be superseded. Null for open-ended strategies that remain valid until explicitly replaced.',
    `global_harmonization_approach` STRING COMMENT 'Strategy for coordinating multi-regional regulatory submissions under the ICH CTD/eCTD framework. Defines whether a single global dossier, regional adaptations, or parallel/rolling submissions are planned across health authorities.. Valid values are `single_dossier|regional_adaptation|parallel_submission|rolling_submission|staggered_submission`',
    `last_pre_submission_meeting_date` DATE COMMENT 'Date of the most recently completed pre-submission meeting with the health authority. Used to track the history of regulatory interactions and inform the currency of agency alignment on the development program.',
    `lead_regulatory_contact` STRING COMMENT 'Name or identifier of the lead regulatory affairs professional (sponsor-side or CRO-side) responsible for executing this regulatory strategy. Serves as the primary point of contact for regulatory agency interactions.',
    `nda_bla_number` STRING COMMENT 'FDA-assigned NDA or BLA application number once the marketing application has been submitted. Null during pre-submission phases. Used for tracking FDA review status and correspondence.. Valid values are `^[0-9]{6}$`',
    `next_pre_submission_meeting_date` DATE COMMENT 'Planned date for the next scheduled pre-submission meeting with the health authority. Enables CRO regulatory teams to prepare briefing documents and align services with upcoming agency interactions.',
    `orphan_drug_designation_number` STRING COMMENT 'FDA or EMA-assigned orphan drug designation number if the investigational product has received orphan designation for the target indication. Null if no orphan designation has been granted.',
    `pdufa_target_date` DATE COMMENT 'FDA PDUFA target action date by which the FDA has committed to completing its review of the NDA or BLA. Drives sponsor and CRO preparation timelines for potential FDA advisory committee meetings and approval readiness.',
    `pediatric_plan_required` BOOLEAN COMMENT 'Indicates whether a Pediatric Study Plan (PSP) for FDA or Pediatric Investigation Plan (PIP) for EMA is required for this program under the Pediatric Research Equity Act (PREA) or EMA pediatric regulation.',
    `planned_ind_submission_date` DATE COMMENT 'Planned date for submitting the IND application to the FDA (or equivalent CTA to other health authorities). Used for program milestone tracking and CRO resource planning.',
    `planned_nda_bla_submission_date` DATE COMMENT 'Planned date for submitting the NDA or BLA to the FDA (or MAA to EMA). Critical milestone for sponsor program planning, CRO deliverable scheduling, and regulatory timeline commitments.',
    `pre_submission_meeting_type` STRING COMMENT 'Type of most recent or planned pre-submission meeting with the health authority (e.g., Type A, Type B, Type C for FDA; INTERACT for EMA). Captures the formal meeting category that governs FDA response timelines and agenda scope.',
    `regulatory_designation` STRING COMMENT 'Special regulatory designation sought from the health authority to expedite development or review (e.g., Fast Track, Breakthrough Therapy, Accelerated Approval, Priority Review, Orphan Drug, PRIME). Null if no special designation is pursued.',
    `regulatory_risk_level` STRING COMMENT 'Overall regulatory risk classification assigned to this strategy based on the risk assessment. Reflects the likelihood and impact of regulatory challenges (e.g., safety signals, CMC issues, clinical data gaps) that could delay or prevent approval.. Valid values are `low|medium|high|critical`',
    `regulatory_risk_summary` STRING COMMENT 'Narrative summary of the key regulatory risks identified for this program, including potential issues with clinical data package, safety profile, CMC, or labeling that could impact the submission or approval timeline.',
    `rems_required` BOOLEAN COMMENT 'Indicates whether a Risk Evaluation and Mitigation Strategy (REMS) is required or anticipated by the FDA as a condition of approval for this program. True if REMS is required or expected.',
    `risk_mitigation_strategy` STRING COMMENT 'Description of the planned mitigation actions to address identified regulatory risks, such as additional clinical studies, pre-submission meetings, REMS planning, or labeling negotiations.',
    `scientific_advice_requested` BOOLEAN COMMENT 'Indicates whether formal scientific advice has been requested from a health authority (e.g., EMA Scientific Advice, FDA Formal Meeting, PMDA Consultation) as part of the regulatory strategy.',
    `strategy_description` STRING COMMENT 'Comprehensive narrative description of the overall regulatory strategy, including the development rationale, key regulatory milestones, agency alignment approach, and any unique strategic considerations for the program.',
    `strategy_name` STRING COMMENT 'Human-readable name or title of the regulatory strategy, typically referencing the compound name, indication, and target market (e.g., Compound-X NDA Fast Track Strategy – US Oncology).',
    `strategy_status` STRING COMMENT 'Current lifecycle status of the regulatory strategy document. Tracks progression from initial drafting through sponsor approval and eventual archival or supersession by a revised strategy.. Valid values are `draft|active|under_review|approved|superseded|archived`',
    `strategy_version` STRING COMMENT 'Version identifier of the regulatory strategy document (e.g., v1.0, v2.1), enabling tracking of iterative revisions as the regulatory landscape or sponsor objectives evolve.. Valid values are `^vd+.d+$`',
    `submission_pathway` STRING COMMENT 'Regulatory submission pathway selected for the program (e.g., IND, NDA, BLA, MAA, 505(b)(2), biosimilar). Determines the regulatory dossier structure, data requirements, and review timelines applicable to the strategy.. Valid values are `IND|NDA|BLA|MAA|505(b)(2)|biosimilar|ANDA|CTD`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this regulatory strategy record, enabling change tracking and audit trail compliance per 21 CFR Part 11 and ALCOA+ data integrity standards.',
    CONSTRAINT pk_regulatory_strategy PRIMARY KEY(`regulatory_strategy_id`)
) COMMENT 'Documents the regulatory strategy and submission pathway planned by a sponsor for a pipeline asset or study program. Captures target health authority (FDA, EMA, PMDA, MHRA, Health Canada), submission pathway (IND, NDA, BLA, MAA, 505(b)(2), biosimilar)';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` (
    `delivery_preference_id` BIGINT COMMENT 'Primary key for delivery_preference',
    `governing_document_sop_id` BIGINT COMMENT 'Foreign key linking to document.document_sop. Business justification: Sponsor delivery preferences include sponsor_sop_alignment_required and GCP guideline version flags.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization for whom these delivery preferences apply. Links to the sponsor master record.',
    `preferred_provider_agreement_id` BIGINT COMMENT 'Foreign key linking to agreement.preferred_provider_agreement. Business justification: Delivery preferences under a PPA are PPA-specific (e.g., preferred EDC system, SDV requirements negotiated in the PPA).',
    `superseded_by_delivery_preference_id` BIGINT COMMENT 'Reference to the newer delivery preference record that replaces this one when preference_status is superseded. Enables version chain navigation for audit and compliance purposes.',
    `template_id` BIGINT COMMENT 'Foreign key linking to document.document_template. Business justification: Sponsor delivery preferences specify the CSR template and document standards to apply. Linking to document_template formalizes the versioned template for study setup.',
    `adam_version` STRING COMMENT 'Required version of the CDISC Analysis Data Model (ADaM) standard for analysis-ready datasets (e.g., ADaM 1.1, ADaM 1.3). Governs structure of analysis datasets supporting statistical analysis plans.',
    `approval_date` DATE COMMENT 'Date on which the sponsor formally approved this delivery preference configuration. Establishes the binding date for CRO compliance with stated preferences.',
    `approved_by` STRING COMMENT 'Name or identifier of the sponsor representative who formally approved this delivery preference configuration. Required for GCP compliance and audit trail per ALCOA+ principles.',
    `audit_trail_requirement` STRING COMMENT 'Regulatory standard governing electronic audit trail requirements for all sponsor study data and systems. 21 CFR Part 11 applies to FDA submissions; EU Annex 11 applies to EMA submissions.. Valid values are `21_cfr_part11|eu_annex11|both|sponsor_standard`',
    `biostatistics_software` STRING COMMENT 'Sponsors required statistical analysis software for biostatistical analysis, CDISC data transformation, and Clinical Study Report (CSR) generation. SAS is the regulatory gold standard; R is increasingly accepted.. Valid values are `sas|r|sas_drug_development|other`',
    `cdisc_define_xml_version` STRING COMMENT 'Required version of the CDISC Define-XML metadata standard for submission data package documentation (e.g., Define-XML 2.0, Define-XML 2.1). Mandatory for FDA and EMA electronic submissions.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this delivery preference record was first created in the system. Supports audit trail and data lineage requirements per 21 CFR Part 11 and ALCOA+ principles.',
    `ctms_preference` STRING COMMENT 'Sponsors preference for the Clinical Trial Management System (CTMS) to be used for site management, monitoring visit tracking, and study milestone management.. Valid values are `oracle_siebel_ctms|veeva_ctms|medidata_rave_ctms|sponsor_owned|cro_standard|other`',
    `data_privacy_framework` STRING COMMENT 'Applicable data privacy regulatory framework governing patient data handling for this sponsors studies. Determines data anonymization, pseudonymization, and cross-border transfer requirements.. Valid values are `gdpr|hipaa|gdpr_hipaa|pipeda|other`',
    `data_transfer_format` STRING COMMENT 'Sponsors required format for clinical data transfers between CRO and sponsor systems. SAS XPT is standard for regulatory submissions; ODM-XML is CDISC standard for EDC data exchange.. Valid values are `sas_xpt|csv|xml|json|odm_xml|other`',
    `data_transfer_frequency` STRING COMMENT 'Required cadence for clinical data transfers from CRO to sponsor. Governs data pipeline scheduling and interim analysis readiness. [ENUM-REF-CANDIDATE: weekly|biweekly|monthly|milestone_based|on_demand|continuous — promote to reference product]',
    `dsmb_reporting_required` BOOLEAN COMMENT 'Indicates whether the sponsor requires formal Data Safety Monitoring Board (DSMB) / Data Monitoring Committee (DMC) reporting packages to be prepared by the CRO as part of safety oversight deliverables.',
    `econsent_platform` STRING COMMENT 'Sponsors preferred eConsent platform for electronic Informed Consent Form (ICF) management and patient engagement. Applicable when econsent_required is True.. Valid values are `clinpal|veeva_vault|medidata_rave|docusign|other`',
    `econsent_required` BOOLEAN COMMENT 'Indicates whether the sponsor mandates the use of electronic Informed Consent Form (ICF) / eConsent technology (e.g., Clinpal) for patient enrollment across their studies. True = eConsent required; False = paper ICF acceptable.',
    `ectd_submission_required` BOOLEAN COMMENT 'Indicates whether the sponsor requires CRO deliverables to be formatted and packaged for Electronic Common Technical Document (eCTD) regulatory submission. Governs document formatting and submission readiness standards.',
    `edc_system_preference` STRING COMMENT 'Sponsors mandated or preferred Electronic Data Capture (EDC) platform for clinical data collection across their studies. Governs which EDC system the CRO must deploy for eCRF build and data management.. Valid values are `medidata_rave|oracle_clinical_one|oracle_inform|veeva_vault_edclinical|other`',
    `edc_system_version` STRING COMMENT 'Specific version or release of the sponsor-preferred EDC system that must be used (e.g., Medidata Rave 5.6.4). Ensures compatibility with sponsor validation environments and 21 CFR Part 11 compliance.',
    `effective_from_date` DATE COMMENT 'Date from which this delivery preference configuration becomes binding on CRO service delivery for the sponsor. Aligns with contract or SOP effective dates.',
    `effective_until_date` DATE COMMENT 'Date on which this delivery preference configuration expires or is superseded. Null indicates the preference is open-ended and currently active.',
    `etmf_system_preference` STRING COMMENT 'Sponsors mandated or preferred Electronic Trial Master File (eTMF) platform for trial documentation management. Governs where TMF documents are stored, indexed, and made inspection-ready.. Valid values are `veeva_vault|master_control|documentum|sharepoint|other`',
    `gcp_guideline_version` STRING COMMENT 'Version of the ICH Good Clinical Practice (GCP) guideline that governs CRO delivery standards for this sponsor. ICH E6(R2) is current standard; ICH E6(R3) is the emerging revision.. Valid values are `ich_e6_r1|ich_e6_r2|ich_e6_r3`',
    `interim_analysis_required` BOOLEAN COMMENT 'Indicates whether the sponsors Statistical Analysis Plan (the source system) requires one or more pre-specified interim analyses. Governs biostatistics deliverable scope and unblinding procedures.',
    `lab_data_standard` STRING COMMENT 'Sponsors required standard for central laboratory data integration and transfer into the EDC/data management system. Governs lab data mapping and CDISC LB domain compliance.. Valid values are `cdisc_lb|hl7_fhir|sponsor_format|other`',
    `meddra_version` STRING COMMENT 'Required version of the MedDRA coding dictionary for adverse event and medical history coding (e.g., MedDRA 26.0, MedDRA 26.1). Ensures consistent AE coding across sponsor studies.',
    `monitoring_strategy` STRING COMMENT 'Sponsors preferred clinical monitoring approach: on_site (traditional 100% SDV), remote (centralized monitoring only), hybrid (combination), or risk_based (RBM — Risk-Based Monitoring per ICH E6(R2) Addendum). Governs CRA deployment and SDV scope.. Valid values are `on_site|remote|hybrid|risk_based`',
    `notes` STRING COMMENT 'Free-text field for additional sponsor-specific delivery requirements, exceptions, or clarifications not captured in structured fields. Supports nuanced sponsor instructions to CRO delivery teams.',
    `patient_data_residency_region` STRING COMMENT 'Geographic region or jurisdiction where patient clinical data must be stored and processed per sponsor data residency requirements (e.g., EU, USA, Japan). Governs cloud infrastructure and data transfer agreements.',
    `preference_code` STRING COMMENT 'Externally-known unique business identifier for this sponsor delivery preference configuration, used in cross-system references and sponsor communications (e.g., SP-PREF-PFIZ0001).. Valid values are `^SP-PREF-[A-Z0-9]{4,12}$`',
    `preference_name` STRING COMMENT 'Human-readable label for this delivery preference configuration, typically reflecting the sponsor name and applicable scope (e.g., Pfizer Global Oncology Delivery Standards 2024).',
    `preference_status` STRING COMMENT 'Current lifecycle state of the delivery preference record. Draft indicates under review; active indicates currently governing CRO delivery; superseded indicates replaced by a newer version; retired indicates no longer applicable.. Valid values are `draft|active|superseded|retired`',
    `preference_type` STRING COMMENT 'Classification indicating the scope at which this preference configuration applies: global (all sponsor studies), therapeutic_area (specific TA), study_specific (single study), or program_level (drug development program).. Valid values are `global|therapeutic_area|study_specific|program_level`',
    `primary_regulatory_authority` STRING COMMENT 'The primary regulatory authority for which CRO deliverables must be prepared and compliant. Governs applicable data standards, submission formats, and reporting timelines (e.g., FDA for US IND/NDA, EMA for MAA).',
    `reporting_cadence` STRING COMMENT 'Required frequency for operational and safety reporting deliverables from CRO to sponsor (e.g., enrollment dashboards, safety listings, site performance reports). Governs report generation schedules.. Valid values are `weekly|biweekly|monthly|quarterly|milestone_based`',
    `rtsm_system_preference` STRING COMMENT 'Sponsors preferred Randomization and Trial Supply Management (RTSM) / Interactive Response Technology (IRT) system for patient randomization and investigational product supply management.. Valid values are `medidata_rave_rtsm|oracle_clinical_one|ivrs|ixrs|other`',
    `safety_system_preference` STRING COMMENT 'Sponsors mandated or preferred pharmacovigilance and adverse event reporting system. Governs the platform used for SAE/SUSAR case processing, regulatory submissions, and signal detection.. Valid values are `oracle_argus|oracle_aers|veeva_vault_safety|aris_g|other`',
    `sdtm_version` STRING COMMENT 'Required version of the CDISC Study Data Tabulation Model (SDTM) standard for submission-ready data packages (e.g., SDTM 3.3, SDTM 3.4). Governs data structure for FDA/EMA regulatory submissions.',
    `sdv_requirement_percent` DECIMAL(5,2) COMMENT 'Minimum percentage of critical data fields requiring Source Data Verification (SDV) per the sponsors monitoring SOP. Ranges from 0 (fully centralized/remote) to 100 (full SDV). Governs CRA monitoring workload and site visit frequency.',
    `sponsor_sop_alignment_required` BOOLEAN COMMENT 'Indicates whether the CRO must operate under sponsor Standard Operating Procedures (SOPs) rather than CRO SOPs. True = sponsor SOPs govern; False = CRO SOPs acceptable with sponsor approval.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this delivery preference record was last modified. Supports change tracking, audit trail, and version management per 21 CFR Part 11 and ALCOA+ principles.',
    `version_number` STRING COMMENT 'Version number of this delivery preference configuration, supporting change management and audit trail. Incremented when preferences are updated (e.g., 1.0, 2.1). Enables tracking of preference evolution over time.. Valid values are `^[0-9]+.[0-9]+(.[0-9]+)?$`',
    `whodd_version` STRING COMMENT 'Required version of the WHO Drug Dictionary (WHO-DD) for concomitant medication coding (e.g., WHO-DD March 2024). Ensures standardized drug coding across sponsor studies for regulatory submissions.',
    CONSTRAINT pk_delivery_preference PRIMARY KEY(`delivery_preference_id`)
) COMMENT 'Captures sponsor-specific operational preferences, standards, and requirements that govern how the CRO delivers services for that sponsor. Includes EDC system preference (Medidata Rave, the source system other), eTMF platform preference (Veeva Vault';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`sponsor`.`interaction` (
    `interaction_id` BIGINT COMMENT 'Unique system-generated identifier for each sponsor-CRO interaction or touchpoint record.',
    `account_plan_id` BIGINT COMMENT 'Foreign key linking to sponsor.account_plan. Business justification: The interaction table has an account_plan_linked boolean flag indicating whether an interaction is associated with an account plan.',
    `agency_meeting_id` BIGINT COMMENT 'Foreign key linking to regulatory.agency_meeting. Business justification: CRO-sponsor governance interactions are frequently convened to prepare for or debrief after agency meetings (pre-IND, end-of-phase, pre-NDA).',
    `clinical_program_id` BIGINT COMMENT 'Foreign key linking to program.clinical_program. Business justification: Program-level governance interactions (steering committee calls, program reviews) are tracked separately from study-level interactions.',
    `cro_lead_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Sponsor relationship management reporting requires a proper FK to the CRO employee leading each interaction for engagement health scoring, governance compliance tracking, and escalation',
    `minutes_tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Governance meeting interactions (JSC, PMT) produce minutes that are TMF-filed essential documents per ICH E6. minutes_reference is a denormalized text reference to the TMF document.',
    `organization_contact_id` BIGINT COMMENT 'Reference to the specific sponsor-side contact person who participated in or is the primary owner of this interaction.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization that is a party to this interaction.',
    `pipeline_asset_id` BIGINT COMMENT 'Foreign key linking to sponsor.pipeline_asset. Business justification: The interaction table stores pipeline_product_name as a free-text string for interactions related to a specific investigational product.',
    `sponsor_engagement_id` BIGINT COMMENT 'Foreign key linking to sponsor.engagement. Business justification: Business interactions and touchpoints with sponsor contacts occur within the context of a commercial engagement.',
    `study_contract_id` BIGINT COMMENT 'Reference to the master service agreement or work order under which this interaction occurs, linking the engagement to its commercial framework.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study or trial associated with this interaction, if the interaction is study-specific. Null for enterprise-level or portfolio-wide interactions.',
    `submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission. Business justification: Sponsor-CRO governance interactions are often convened specifically to review, approve, or debrief on a regulatory submission package.',
    `agenda_summary` STRING COMMENT 'Structured summary of agenda items discussed during the interaction. Captures the key topics covered to support meeting minutes and action item traceability.',
    `cadence_compliant` BOOLEAN COMMENT 'Indicates whether this interaction occurred within the required cadence window as defined by the governance plan or contract. True = compliant; False = cadence breach.',
    `channel` STRING COMMENT 'Medium through which the interaction was conducted: in-person (on-site), video conference (e.g., Teams, Zoom), telephone, or hybrid combination.. Valid values are `in_person|video_conference|telephone|hybrid`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this interaction record was first created in the system, including timezone offset. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `cro_participant_count` BIGINT COMMENT 'Number of CRO-side individuals who attended this interaction. Used for resource allocation analysis and engagement intensity reporting.',
    `cro_participant_names` STRING COMMENT 'Comma-separated list of CRO personnel who participated in this interaction. Stored as a denormalized text field; detailed participant records are managed in the interaction_participant association product.',
    `ctms_interaction_code` STRING COMMENT 'Source system identifier for this interaction record as assigned by the source system Enables bidirectional traceability between the lakehouse silver layer and the operational CTMS.',
    `interaction_date` DATE COMMENT 'Calendar date on which the interaction took place or is scheduled to take place. Principal real-world event date for this transaction.',
    `decisions_summary` STRING COMMENT 'Narrative summary of key decisions made during the interaction. Provides an auditable record of outcomes agreed upon by sponsor and CRO representatives.',
    `duration_minutes` BIGINT COMMENT 'Actual elapsed duration of the interaction in minutes as recorded in the meeting system. Stored as a business field from the source system (the source system rather than derived at query time.',
    `end_timestamp` TIMESTAMP COMMENT 'Precise date and time when the interaction concluded, including timezone offset. Used together with start_timestamp to compute actual meeting duration.',
    `escalation_flag` BOOLEAN COMMENT 'Indicates whether this interaction involved or triggered an escalation to senior management or executive governance. True = escalation involved; False = routine interaction.',
    `escalation_reason` STRING COMMENT 'Free-text description of the reason for escalation when escalation_flag is True. Captures the business issue or risk that necessitated senior management involvement.',
    `follow_up_due_date` DATE COMMENT 'Target date by which the required follow-up action or communication must be completed. Populated when follow_up_required is True.',
    `follow_up_required` BOOLEAN COMMENT 'Indicates whether a follow-up interaction or communication is required as a result of this interaction. True = follow-up needed; False = no follow-up required.',
    `governance_tier` STRING COMMENT 'Organizational governance level at which this interaction occurs: executive (EBR/QBR), operational (JOC), study-level (JSC), or site-level. Drives escalation routing and reporting hierarchy.. Valid values are `executive|operational|study_level|site_level`',
    `location` STRING COMMENT 'Physical or virtual location where the interaction took place, such as sponsor headquarters city, CRO office address, or virtual platform name (e.g., Pfizer HQ - New York, MS Teams).',
    `meeting_cadence` STRING COMMENT 'Scheduled recurrence frequency for this type of interaction as defined in the governance framework or contract. Used to assess cadence compliance against contractual obligations.',
    `minutes_approved` BOOLEAN COMMENT 'Indicates whether the meeting minutes for this interaction have been formally reviewed and approved by both sponsor and CRO representatives. True = approved; False = pending or not applicable.',
    `minutes_approved_date` DATE COMMENT 'Date on which the meeting minutes were formally approved by both parties. Used to measure minutes turnaround time against governance SLA targets.',
    `next_interaction_date` DATE COMMENT 'Agreed or planned date for the next scheduled interaction of the same type with this sponsor. Supports meeting cadence planning and account management follow-up.',
    `open_action_item_count` BIGINT COMMENT 'Number of action items generated from this interaction that remain open and unresolved at the time of record update. Supports governance compliance dashboards and follow-up tracking.',
    `outcome` STRING COMMENT 'Overall qualitative outcome of the interaction from a relationship management perspective: positive (objectives met, relationship strengthened), neutral, negative (concerns raised), escalated (issues requiring senior intervention), or deferred (key. Valid values are `positive|neutral|negative|escalated|deferred`',
    `reference_number` STRING COMMENT 'Externally visible, human-readable unique reference number for this interaction, used in meeting minutes, action item trackers, and governance logs. Format: INT-YYYY-NNNNNN.. Valid values are `^INT-[0-9]{4}-[0-9]{6}$`',
    `regulatory_agency` STRING COMMENT 'Primary regulatory agency relevant to the regulatory strategy discussion in this interaction, if applicable (e.g., FDA for IND/NDA strategy calls, EMA for MAA discussions).',
    `regulatory_submission_type` STRING COMMENT 'Type of regulatory submission discussed during a regulatory strategy call interaction, such as Investigational New Drug (IND), New Drug Application (NDA), Biologics License Application (BLA), or Marketing Authorization Application (MAA).. Valid values are `IND|NDA|BLA|MAA|eCTD|Other`',
    `sponsor_participant_count` BIGINT COMMENT 'Number of sponsor-side individuals who attended this interaction. Used for engagement intensity analysis and governance tier compliance.',
    `sponsor_participant_names` STRING COMMENT 'Comma-separated list of sponsor-side personnel who participated in this interaction. Stored as a denormalized text field for meeting minutes and engagement history reporting.',
    `start_timestamp` TIMESTAMP COMMENT 'Precise date and time when the interaction commenced, including timezone offset. Used for duration calculation and meeting cadence compliance tracking.',
    `interaction_status` STRING COMMENT 'Current lifecycle state of the interaction record: scheduled (confirmed on calendar), completed (held and minutes finalized), cancelled, rescheduled, or pending_minutes (held but minutes not yet approved).. Valid values are `scheduled|completed|cancelled|rescheduled|pending_minutes`',
    `subject` STRING COMMENT 'Brief title or subject line summarizing the purpose of the interaction, analogous to a meeting subject line in calendar systems.',
    `therapeutic_area` STRING COMMENT 'Therapeutic area or disease indication relevant to this interaction (e.g., Oncology, Cardiology, Neurology). Enables portfolio-level engagement analysis by therapeutic area.',
    `total_action_item_count` BIGINT COMMENT 'Total number of action items raised during this interaction, including both open and closed items. Used to assess meeting productivity and governance rigor.',
    `interaction_type` STRING COMMENT 'Classification of the interaction by its business purpose. Governance meetings include Joint Steering Committee (JSC), Joint Operations Committee (JOC), Executive Business Review (EBR), and Quarterly Business Review (QBR).. Valid values are `governance_meeting|business_review|bid_defense|regulatory_strategy_call|escalation_call|proposal_presentation`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this interaction record, including timezone offset. Required for change tracking and audit trail compliance under 21 CFR Part 11.',
    CONSTRAINT pk_interaction PRIMARY KEY(`interaction_id`)
) COMMENT 'Transactional record of all business interactions and touchpoints between CRO personnel and sponsor contacts, encompassing informal touchpoints, formal governance meetings (JSC, JOC, EBR, QBR), business reviews, bid defenses, and regulatory strategy';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` (
    `review_meeting_id` BIGINT COMMENT 'Unique surrogate identifier for the sponsor-CRO governance review meeting record in the Silver Layer lakehouse.',
    `clinical_program_id` BIGINT COMMENT 'Foreign key linking to program.clinical_program. Business justification: Sponsor review meetings occur at the program level (e.g., program steering committees, joint development committees).',
    `cro_chair_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Governance meeting records require a proper FK to the CRO employee chairing the meeting for minutes approval, action item ownership, audit trail completeness, and GCP inspection readiness.',
    `organization_contact_id` BIGINT COMMENT 'Foreign key linking to sponsor.sponsor_contact. Business justification: The sponsor_review_meeting table stores sponsor_chair as a free-text string. Adding sponsor_contact_id FK (nullable) normalizes the sponsor chair reference to the sponsor_contact',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization that funds and owns the clinical trial portfolio covered by this governance meeting.',
    `preferred_provider_agreement_id` BIGINT COMMENT 'Foreign key linking to agreement.preferred_provider_agreement. Business justification: Alliance governance review meetings (QBRs, annual reviews) are conducted at the PPA level to review volume attainment, service performance, and strategic alignment.',
    `sponsor_engagement_id` BIGINT COMMENT 'Foreign key linking to sponsor.engagement. Business justification: Formal governance meetings between sponsor and CRO occur within the context of a commercial engagement.',
    `study_contract_id` BIGINT COMMENT 'Reference to the governing contract (preferred provider agreement, FSP agreement, or master service agreement) under which this governance meeting cadence is required.',
    `study_id` BIGINT COMMENT 'Foreign key linking to study.study_study. Business justification: Sponsor governance review meetings (JSC, PMC, DSMB prep) are held for specific studies. Linking sponsor_review_meeting to study enables study-level governance tracking, meeting minutes',
    `submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission. Business justification: Formal sponsor review meetings are frequently convened to review regulatory submission readiness, submission status, and agency responses.',
    `tmf_document_id` BIGINT COMMENT 'Reference to the formal meeting minutes document stored in the eTMF or document management system (Veeva Vault). Links the governance meeting record to its official written record.',
    `action_item_count` BIGINT COMMENT 'Total number of action items raised during the governance meeting, each with an assigned owner and due date. Drives follow-up tracking and accountability reporting.',
    `actual_date` DATE COMMENT 'The date on which the governance meeting actually took place. May differ from scheduled_date if the meeting was rescheduled. Null if the meeting has not yet occurred or was cancelled.',
    `actual_end_time` TIMESTAMP COMMENT 'Precise date and time at which the governance meeting actually concluded. Used to calculate actual meeting duration and assess time management.',
    `actual_start_time` TIMESTAMP COMMENT 'Precise date and time at which the governance meeting actually commenced. Compared against scheduled_start_time to measure punctuality and governance discipline.',
    `agenda_distributed_date` DATE COMMENT 'Date on which the meeting agenda was formally distributed to all participants. Used to verify compliance with advance-notice requirements stipulated in the governance charter (e.g., 5 business days prior).',
    `agenda_item_count` BIGINT COMMENT 'Total number of formal agenda items included in the meeting. Provides a high-level measure of meeting scope and complexity.',
    `agreement_type` STRING COMMENT 'Type of commercial agreement under which this governance meeting is mandated. FSP = Functional Service Provider agreement; Preferred Provider = strategic preferred provider agreement; Full Service = end-to-end CRO engagement.. Valid values are `Preferred Provider|FSP|Full Service|Functional Service|Ad Hoc`',
    `cancellation_reason` STRING COMMENT 'Free-text explanation for why the meeting was cancelled or rescheduled. Populated only when meeting_status is Cancelled or Rescheduled. Required for governance audit trail.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this governance meeting record was first created in the system. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `cro_attendee_count` BIGINT COMMENT 'Total number of CRO-side participants who attended the governance meeting. Used for quorum validation and engagement analytics.',
    `decision_count` BIGINT COMMENT 'Total number of formal decisions recorded during the governance meeting. Supports governance effectiveness tracking and decision velocity analytics.',
    `escalation_count` BIGINT COMMENT 'Total number of formal escalations raised during the governance meeting. Null or zero when escalation_raised is False. Used for risk and relationship health analytics.',
    `escalation_description` STRING COMMENT 'Free-text summary of the escalation(s) raised during the meeting, including the nature of the issue, impacted studies or workstreams, and the escalation path. Null when no escalations were raised.',
    `escalation_raised` BOOLEAN COMMENT 'Indicates whether one or more formal escalations were raised during this governance meeting. True = at least one escalation was formally logged; False = no escalations raised. Triggers escalation management workflow.',
    `financial_review_included` BOOLEAN COMMENT 'Indicates whether a formal financial review (budget burn, pass-through reconciliation, change orders) was included as an agenda item in this governance meeting.',
    `governance_tier` STRING COMMENT 'Hierarchical tier of the governance meeting within the sponsor-CRO governance framework. Executive = C-suite/VP level (EBR); Operational = day-to-day operations (JOC); Quality = quality and compliance focus (QBR); Portfolio = cross-study strategic. Valid values are `Executive|Operational|Quality|Portfolio`',
    `kpi_review_included` BOOLEAN COMMENT 'Indicates whether a formal KPI dashboard review was included as an agenda item in this governance meeting. True = KPI review conducted; False = KPI review not included.',
    `meeting_format` STRING COMMENT 'Modality of the governance meeting: In-Person (all participants physically co-located), Virtual (fully remote via video/teleconference), or Hybrid (mix of in-person and remote participants).. Valid values are `In-Person|Virtual|Hybrid`',
    `meeting_frequency` STRING COMMENT 'Contractually defined recurrence frequency for this meeting type under the governing sponsor-CRO agreement. Drives automated scheduling and cadence compliance monitoring.',
    `meeting_location` STRING COMMENT 'Physical venue or virtual platform where the meeting was held (e.g., Sponsor HQ, New York — Conference Room A or Microsoft Teams). Null for fully virtual meetings where platform is captured separately.',
    `meeting_number` STRING COMMENT 'Externally-known, human-readable reference number assigned to the governance meeting (e.g., JSC-2024-007). Used in correspondence, agendas, and minutes to uniquely identify the meeting across systems.',
    `meeting_status` STRING COMMENT 'Current lifecycle state of the governance meeting. Tracks whether the meeting is upcoming (Scheduled), has occurred (Completed), was cancelled, rescheduled, or is currently in session (In Progress).. Valid values are `Scheduled|Completed|Cancelled|Rescheduled|In Progress`',
    `meeting_summary` STRING COMMENT 'High-level narrative summary of the key topics discussed, decisions reached, and outcomes of the governance meeting. Intended for executive stakeholders who require a concise overview without reading full minutes.',
    `meeting_title` STRING COMMENT 'Descriptive title of the governance meeting as it appears on the agenda and formal minutes (e.g., Q3 2024 Joint Steering Committee — Oncology Portfolio Review).',
    `meeting_type` STRING COMMENT 'Classification of the formal governance meeting. JSC = Joint Steering Committee; JOC = Joint Operations Committee; EBR = Executive Business Review; QBR = Quality Business Review; Ad Hoc = unscheduled governance session; Other = any other formal governance. Valid values are `JSC|JOC|EBR|QBR|Ad Hoc|Other`',
    `minutes_approved_date` DATE COMMENT 'Date on which the meeting minutes were formally approved by both sponsor and CRO representatives. Null until minutes reach Approved/Finalized status.',
    `minutes_status` STRING COMMENT 'Current approval lifecycle state of the formal meeting minutes. Tracks progression from initial draft through sponsor and CRO review to final approval and archival.. Valid values are `Draft|Under Review|Approved|Finalized`',
    `next_meeting_date` DATE COMMENT 'Date agreed upon during this meeting for the next occurrence of the same governance meeting type. Supports forward scheduling and cadence continuity tracking.',
    `open_action_item_count` BIGINT COMMENT 'Number of action items from this meeting that remain open (not yet completed or closed) at the time of last record update. Key KPI for governance health and accountability.',
    `quality_review_included` BOOLEAN COMMENT 'Indicates whether a formal quality metrics review (e.g., protocol deviations, CAPA status, audit findings) was included as an agenda item. Relevant for QBR meeting types.',
    `quorum_met` BOOLEAN COMMENT 'Indicates whether the minimum required number of attendees (quorum) as defined in the governance charter was present, making the meetings decisions formally binding. True = quorum achieved; False = quorum not met.',
    `scheduled_date` DATE COMMENT 'The originally planned calendar date on which the governance meeting was scheduled to occur. Used for cadence tracking and SLA compliance under preferred provider agreements.',
    `scheduled_end_time` TIMESTAMP COMMENT 'Precise date and time at which the governance meeting was scheduled to conclude. Used to calculate planned meeting duration and manage participant availability.',
    `scheduled_start_time` TIMESTAMP COMMENT 'Precise date and time (with timezone offset) at which the governance meeting was scheduled to begin. Supports calendar management and multi-timezone coordination between sponsor and CRO.',
    `sponsor_attendee_count` BIGINT COMMENT 'Total number of sponsor-side participants who attended the governance meeting. Used for quorum validation and engagement analytics.',
    `sponsor_chair` STRING COMMENT 'Full name of the sponsor-side individual who chairs or co-chairs the governance meeting. Typically a senior sponsor representative such as a VP Clinical Development or Alliance Manager.',
    `therapeutic_area` STRING COMMENT 'Primary therapeutic area or disease domain covered by the portfolio of studies reviewed in this governance meeting (e.g., Oncology, Cardiovascular, Neuroscience, Immunology). Enables portfolio-level analytics by therapeutic area.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this governance meeting record was most recently modified. Supports change tracking, data lineage, and audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    CONSTRAINT pk_review_meeting PRIMARY KEY(`review_meeting_id`)
) COMMENT 'Tracks formal governance meetings between sponsor and CRO organizations including Joint Steering Committee (JSC), Joint Operations Committee (JOC), Executive Business Reviews (EBR), and Quality Business Reviews (QBR).';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` (
    `bid_request_id` BIGINT COMMENT 'Unique surrogate identifier for the bid request record in the CROs business development pipeline. Primary key for this entity.',
    `clinical_program_id` BIGINT COMMENT 'Foreign key linking to program.clinical_program. Business justification: Bid requests are submitted for studies within a clinical program. Program-level bid aggregation drives win/loss analysis and CRO pipeline forecasting.',
    `confidentiality_agreement_id` BIGINT COMMENT 'Foreign key linking to agreement.confidentiality_agreement. Business justification: Before an RFP/bid package is shared with a CRO, a CDA must be executed.',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: Bid requests for regulatory affairs services must reference the target health authority to scope submission effort, clock days, fee estimates, and eCTD format requirements.',
    `indication_id` BIGINT COMMENT 'Foreign key linking to program.indication. Business justification: Bid requests are for studies targeting a specific indication. Standardized indication coding is required for win/loss analysis and CRO capability matching.',
    `master_service_agreement_id` BIGINT COMMENT 'Foreign key linking to agreement.master_service_agreement. Business justification: Bid requests submitted under an existing MSA framework reference the MSA for applicable terms, rate structures, and service scope.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization that submitted this bid request / Request for Proposal (RFP) to the CRO.',
    `parent_bid_request_id` BIGINT COMMENT 'Reference to the original bid request record if this is a resubmission or amendment. Enables lineage tracking across bid iterations for the same study opportunity.',
    `pipeline_asset_id` BIGINT COMMENT 'Foreign key linking to sponsor.pipeline_asset. Business justification: A bid request is typically submitted for a specific investigational product in the sponsors pipeline.',
    `primary_bid_employee_id` BIGINT COMMENT 'Reference to the CROs internal business development or proposal lead employee responsible for managing this bid request. Drives accountability and commission tracking.',
    `regulatory_procedure_id` BIGINT COMMENT 'Foreign key linking to regulatory.procedure. Business justification: Bid requests for regulatory affairs work are scoped against a specific regulatory procedure (e.g., FDA NDA standard review, EMA centralized procedure).',
    `sponsor_engagement_id` BIGINT COMMENT 'Foreign key linking to sponsor.engagement. Business justification: A bid request from a sponsor may be associated with an existing commercial engagement (expansion of scope) or may initiate a new engagement.',
    `template_id` BIGINT COMMENT 'Foreign key linking to document.document_template. Business justification: RFP/bid requests are generated from versioned proposal document templates. Linking ensures audit trail for which template version was used per bid.',
    `therapeutic_area_id` BIGINT COMMENT 'Foreign key linking to program.therapeutic_area. Business justification: Bid requests are categorized by therapeutic area for CRO capability matching and win/loss analysis. bid_request has therapeutic_area as a denormalized plain text field.',
    `award_date` DATE COMMENT 'Date on which the sponsor formally awarded the study contract to the CRO. Populated only when bid_status = awarded. Triggers transition to study start-up activities.',
    `bid_defense_date` DATE COMMENT 'Scheduled date for the bid defense meeting or presentation where the CRO presents its proposal to the sponsors evaluation team. A key milestone in the competitive selection process.',
    `bid_status` STRING COMMENT 'Current lifecycle state of the bid request within the CROs business development workflow. Drives pipeline reporting and revenue forecasting.. Valid values are `received|in_progress|submitted|awarded|lost|no_bid`',
    `budget_currency` STRING COMMENT 'ISO 4217 three-letter currency code for all monetary values in this bid request (e.g., USD, EUR, GBP). Ensures consistent financial reporting across multi-currency sponsor engagements.. Valid values are `^[A-Z]{3}$`',
    `competing_cro_count` BIGINT COMMENT 'Number of competing Contract Research Organizations (CROs) known to be invited to bid on this RFP. Used for competitive analysis and bid strategy calibration.',
    `competitive_context` STRING COMMENT 'Classification of the competitive environment for this bid: sole-source (only CRO invited), competitive (multiple CROs bidding), preferred provider (CRO has preferred status), or incumbent (CRO currently running the study). Influences bid strategy.. Valid values are `sole_source|competitive|preferred_provider|incumbent|unknown`',
    `country_scope` STRING COMMENT 'Comma-separated list of ISO 3166-1 alpha-3 country codes representing the geographic scope of the study as specified in the RFP (e.g., USA, GBR, DEU, JPN). Drives regulatory strategy and site feasibility.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this bid request record was first created in the system. Audit trail field aligned with ALCOA+ data integrity principles (Attributable, Legible, Contemporaneous, Original, Accurate).',
    `estimated_budget_amount` DECIMAL(18,2) COMMENT 'CROs internal gross estimated budget for the full scope of services requested in the RFP, expressed in the budget_currency. Used for revenue forecasting and bid pricing strategy.',
    `estimated_duration_months` BIGINT COMMENT 'Sponsor-estimated total duration of the study in months from first site initiation to database lock (DBL). Used for resource planning and revenue recognition scheduling.',
    `estimated_site_count` BIGINT COMMENT 'Sponsor-provided estimate of the total number of investigative sites to be activated globally. Drives site management, monitoring, and travel budget estimates.',
    `estimated_subject_count` BIGINT COMMENT 'Sponsor-provided estimate of the total number of study subjects (patients) to be enrolled across all sites and countries. Key driver of budget, resource, and timeline estimates.',
    `investigational_product_name` STRING COMMENT 'Name or code of the investigational drug, biologic, or device being studied as provided by the sponsor. May be a compound code prior to INN assignment.',
    `is_resubmission` BOOLEAN COMMENT 'Indicates whether this bid request is a resubmission or revision of a previously submitted proposal for the same study. True if resubmission; False if original submission.',
    `loss_reason` STRING COMMENT 'Reason code explaining why the CRO lost this bid to a competitor. Populated only when bid_status = lost. Used for win/loss analysis and continuous improvement of bid strategy.',
    `no_bid_date` DATE COMMENT 'Date on which the CRO formally decided not to submit a proposal for this bid request. Populated only when bid_status = no_bid. Used for pipeline and capacity analysis.',
    `no_bid_reason` STRING COMMENT 'Reason code explaining why the CRO elected not to submit a proposal for this bid request. Populated only when bid_status = no_bid. Used for strategic portfolio and capacity analysis.',
    `notes` STRING COMMENT 'Free-text field for capturing additional context, sponsor-specific requirements, strategic considerations, or internal commentary relevant to this bid request that is not captured in structured fields.',
    `proposal_due_date` DATE COMMENT 'Sponsor-mandated deadline by which the CRO must submit its formal proposal and budget in response to the RFP.',
    `receipt_date` DATE COMMENT 'Date on which the CRO formally received the sponsors Request for Proposal (RFP) or bid request document. Marks the start of the bid lifecycle and triggers internal timelines.',
    `region_scope` STRING COMMENT 'High-level geographic region classification for the study scope. Used for regional capacity planning and business development reporting.. Valid values are `global|north_america|europe|asia_pacific|latin_america|middle_east_africa`',
    `requested_services` STRING COMMENT 'Free-text or structured description of the specific CRO service modules requested by the sponsor (e.g., clinical monitoring, data management, biostatistics, regulatory affairs, pharmacovigilance). Informs scope-of-work development.',
    `rfp_document_ref` STRING COMMENT 'Reference identifier or URL to the sponsors RFP document stored in the eTMF or document management system (Veeva Vault). Enables traceability between the bid record and the source RFP document.',
    `rfp_number` STRING COMMENT 'Externally-assigned reference number provided by the sponsor on the Request for Proposal (RFP) document. Used to cross-reference the CROs bid with the sponsors procurement records.. Valid values are `^RFP-[A-Z0-9]{4,20}$`',
    `service_model` STRING COMMENT 'Type of CRO engagement requested by the sponsor: full-service (CRO manages all functions), Functional Service Provider (FSP) model (CRO provides specific functions), hybrid, or module-specific. Drives scope and pricing.. Valid values are `full_service|fsp|hybrid|module_specific`',
    `sponsor_budget_ceiling` DECIMAL(18,2) COMMENT 'Maximum budget amount disclosed by the sponsor in the RFP, if provided. Used to calibrate the CROs proposal and assess bid competitiveness.',
    `sponsor_contact_email` STRING COMMENT 'Email address of the primary sponsor contact for this bid request. Used for proposal submission and bid defense coordination.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `sponsor_contact_name` STRING COMMENT 'Full name of the primary sponsor contact person responsible for this RFP (e.g., outsourcing manager, clinical operations lead). Key relationship management field.',
    `study_code` STRING COMMENT 'Sponsor-assigned alphanumeric code or protocol number for the study referenced in the bid request. Used to link the bid to the sponsors internal study portfolio.',
    `study_phase` STRING COMMENT 'Clinical development phase of the study as defined by ICH and FDA guidelines (Phase I through Phase IV). Determines regulatory requirements, study complexity, and resource needs.. Valid values are `Phase I|Phase I/II|Phase II|Phase II/III|Phase III|Phase IV`',
    `study_title` STRING COMMENT 'Full descriptive title of the clinical study as provided by the sponsor in the RFP. Describes the investigational product, indication, and study design at a high level.',
    `study_type` STRING COMMENT 'Classification of the study design as interventional (subjects receive an investigational treatment) or observational (no intervention assigned). Drives regulatory pathway and operational model.. Valid values are `interventional|observational|expanded_access|registry`',
    `submitted_bid_amount` DECIMAL(18,2) COMMENT 'Final total bid amount submitted by the CRO to the sponsor in the formal proposal, expressed in budget_currency. Populated after proposal submission. Key metric for win/loss analysis.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this bid request record. Supports audit trail requirements and change tracking per ALCOA+ data integrity principles.',
    `win_probability_pct` DECIMAL(5,2) COMMENT 'Business development teams estimated probability (0.00–100.00%) of winning this bid, based on competitive intelligence, sponsor relationship, and capability fit. Used for weighted pipeline revenue forecasting.',
    CONSTRAINT pk_bid_request PRIMARY KEY(`bid_request_id`)
) COMMENT 'Captures sponsor requests for proposal (RFP) and bid requests submitted to the CRO for new study work. Tracks RFP reference number, sponsor name, study description, therapeutic area, indication, study phase, estimated subject count, site count, country';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`sponsor`.`proposal` (
    `proposal_id` BIGINT COMMENT 'Unique system-generated identifier for the CRO proposal record. Primary key for the proposal data product within the sponsor domain.',
    `bid_request_id` BIGINT COMMENT 'Reference to the sponsor bid request that triggered this proposal. Links the proposal back to the originating request for proposal (RFP) document.',
    `clinical_program_id` BIGINT COMMENT 'Foreign key linking to program.clinical_program. Business justification: Proposals are submitted for studies within a clinical program. Program-level financial forecasting and CRO revenue tracking require linking proposals to programs.',
    `indication_id` BIGINT COMMENT 'Foreign key linking to program.indication. Business justification: Proposals are submitted for studies targeting a specific indication. Standardized indication coding enables indication-level financial analysis and resource planning.',
    `manager_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Proposal management tracking requires a proper FK to the CRO employee managing the proposal for resource utilization reporting, win/loss analysis by proposal manager, and workload',
    `master_service_agreement_id` BIGINT COMMENT 'Foreign key linking to agreement.master_service_agreement. Business justification: Proposals submitted under an MSA must reference it for applicable terms, liability caps, and payment conditions.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization that issued the bid request and to whom this proposal is submitted.',
    `pipeline_asset_id` BIGINT COMMENT 'Foreign key linking to sponsor.pipeline_asset. Business justification: A CRO proposal is submitted for a specific investigational product. Linking proposal to pipeline_asset (nullable FK) enables tracking of which pipeline assets have active proposals and',
    `preferred_provider_agreement_id` BIGINT COMMENT 'Foreign key linking to agreement.preferred_provider_agreement. Business justification: Proposals under a PPA must reference it to apply preferred pricing, volume discounts, and rate cards.',
    `sponsor_engagement_id` BIGINT COMMENT 'Foreign key linking to sponsor.engagement. Business justification: A CRO proposal submitted in response to a sponsor bid request falls within the context of a commercial engagement (either an existing engagement being expanded or a new one being',
    `template_id` BIGINT COMMENT 'Foreign key linking to document.document_template. Business justification: Proposals are authored using versioned document templates (budget, scope-of-work). Linking ensures the correct template version is traceable for audit and re-bid scenarios.',
    `therapeutic_area_id` BIGINT COMMENT 'Foreign key linking to program.therapeutic_area. Business justification: Proposals are categorized by therapeutic area for pricing, resource planning, and capability matching. proposal has therapeutic_area as a denormalized plain text field.',
    `award_date` DATE COMMENT 'Date on which the sponsor formally awarded the study to the CRO based on this proposal. Populated only when proposal_status transitions to awarded.',
    `bd_owner` STRING COMMENT 'Name or employee identifier of the CRO business development lead responsible for managing the proposal process and sponsor relationship for this opportunity.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp recording when the proposal record was first created in the CTMS. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which the proposal budget is denominated (e.g., USD, EUR, GBP, JPY). Drives financial reporting and FX conversion in the source system. Valid values are `^[A-Z]{3}$`',
    `direct_cost_total` DECIMAL(18,2) COMMENT 'Sum of all direct CRO service costs within the proposal, excluding pass-through expenses. Represents the CROs own labor and operational costs billed to the sponsor.',
    `exclusions` STRING COMMENT 'Narrative description of services, activities, or costs explicitly excluded from the proposal scope. Protects the CRO from scope creep and forms the basis for change order proposals.',
    `expiry_date` DATE COMMENT 'Date after which the proposed budget and terms are no longer valid and the proposal must be revised. Typically 90 days from submission date per CRO commercial policy.',
    `investigational_product_name` STRING COMMENT 'Name or code of the sponsors investigational drug, biologic, or device that is the subject of the proposed clinical study. May be a compound code prior to INN assignment.',
    `is_competitive_bid` BOOLEAN COMMENT 'Indicates whether this proposal is submitted in a competitive bidding process (True) where multiple CROs are responding to the same bid request, or a sole-source opportunity (False).',
    `is_rebid` BOOLEAN COMMENT 'Indicates whether this proposal is a rebid (True) submitted after a prior version was rejected or returned for revision by the sponsor, or an original submission (False).',
    `key_assumptions` STRING COMMENT 'Narrative description of the critical assumptions underpinning the proposed budget and timeline (e.g., protocol amendment frequency, screen failure rate, site activation timeline). Contractually binding if included in the awarded contract.',
    `lost_reason` STRING COMMENT 'Categorized reason why the proposal was not awarded when proposal_status is lost. Used for win/loss analysis and competitive intelligence to improve future proposal quality.',
    `number` STRING COMMENT 'Externally visible, human-readable unique identifier for the proposal, used in all sponsor-facing communications and contract negotiations. Format: PRO-YYYY-NNNNNN.. Valid values are `^PRO-[0-9]{4}-[0-9]{6}$`',
    `pass_through_cost_total` DECIMAL(18,2) COMMENT 'Sum of all third-party pass-through costs included in the proposal (e.g., central lab fees, IRB/IEC fees, investigator grants, courier costs). Billed to sponsor at cost without CRO markup.',
    `payment_schedule_type` STRING COMMENT 'Structure of the proposed payment schedule defining when invoices will be issued to the sponsor. Drives accounts receivable forecasting in the source system. Valid values are `milestone|monthly|quarterly|upfront_plus_milestone`',
    `phase` STRING COMMENT 'Regulatory development phase of the proposed clinical study as defined by ICH and FDA guidelines. Drives complexity, site count, and budget magnitude.. Valid values are `phase_1|phase_1_2|phase_2|phase_2_3|phase_3|phase_4`',
    `pricing_model` STRING COMMENT 'Commercial pricing structure applied to this proposal. Unit-based prices per deliverable unit (e.g., per patient, per site visit); milestone-based ties payments to study milestones; fixed_fee is a lump sum; time_and_materials bills actuals; hybrid. Valid values are `unit_based|milestone_based|fixed_fee|time_and_materials|hybrid`',
    `proposed_country_count` BIGINT COMMENT 'Number of countries in which investigational sites are proposed to be activated. Impacts regulatory strategy complexity, translation requirements, and pass-through cost estimates.',
    `proposed_csr_date` DATE COMMENT 'Proposed date for delivery of the final Clinical Study Report (CSR) to the sponsor. Represents the end of the CROs primary deliverable obligation and is a key contractual milestone.',
    `proposed_dbl_date` DATE COMMENT 'Proposed date for database lock (DBL), after which no further data changes are permitted and the clean database is handed to biostatistics for final analysis. Critical milestone for regulatory submission planning.',
    `proposed_fpi_date` DATE COMMENT 'Proposed date for enrollment of the first study subject (First Patient In / First Subject In). Key milestone in the proposed study timeline used for sponsor planning and KPI tracking.',
    `proposed_lpo_date` DATE COMMENT 'Proposed date for the last study subject completing all protocol-required visits (Last Patient Out / Last Subject Out). Defines the end of the clinical phase in the proposed timeline.',
    `proposed_project_director` STRING COMMENT 'Name of the CRO project director proposed to lead the study if awarded. Sponsor may request specific named personnel as a condition of award.',
    `proposed_site_count` BIGINT COMMENT 'Total number of investigational sites proposed to be activated for the study. Drives monitoring resource planning, site management costs, and feasibility assumptions.',
    `proposed_subject_count` BIGINT COMMENT 'Total number of study subjects (patients) proposed to be enrolled across all sites. Derived from the protocol synopsis and drives sample size assumptions in the budget model.',
    `risk_factors` STRING COMMENT 'Narrative summary of identified risks that could impact the proposed budget, timeline, or deliverables (e.g., complex patient population, emerging market sites, novel endpoint technology).',
    `proposal_status` STRING COMMENT 'Current lifecycle state of the proposal in the CRO business development workflow. Drives downstream contract execution when status transitions to awarded.. Valid values are `draft|submitted|under_review|awarded|lost|withdrawn`',
    `study_duration_months` BIGINT COMMENT 'Total proposed duration of the study in months from study start (first site activation) to CSR delivery. Used for resource loading, timeline risk assessment, and contract term setting.',
    `study_title` STRING COMMENT 'Full descriptive title of the clinical study as referenced in the bid request and proposed protocol synopsis. Used for sponsor-facing communications and TMF indexing.',
    `submission_date` DATE COMMENT 'Calendar date on which the proposal was formally submitted to the sponsor. Represents the principal business event timestamp for this transaction.',
    `total_proposed_budget` DECIMAL(18,2) COMMENT 'Gross total budget amount proposed by the CRO for the full scope of services, inclusive of all direct costs, pass-through costs, and applicable fees. Expressed in the proposal currency.',
    `proposal_type` STRING COMMENT 'Classification of the proposal by service delivery model. Full-service covers end-to-end CRO delivery; FSP (Functional Service Provider) covers specific functional areas; change_order covers scope amendments to an existing contract; budget_amendment. Valid values are `full_service|fsp|change_order|budget_amendment|feasibility`',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp recording the most recent modification to the proposal record. Supports audit trail and data lineage requirements under 21 CFR Part 11.',
    `veeva_document_code` STRING COMMENT 'Identifier of the proposal document stored in Veeva Vault for controlled document management, version control, and audit trail. Enables traceability between the data record and the source document.',
    `version_number` STRING COMMENT 'Version identifier for this proposal document (e.g., 1.0, 2.0, 2.1). Incremented each time the proposal is revised and resubmitted to the sponsor.. Valid values are `^[0-9]+.[0-9]+$`',
    `win_probability_pct` DECIMAL(5,2) COMMENT 'Business development teams estimated probability (0.00–100.00%) that this proposal will be awarded. Used for pipeline forecasting, revenue recognition planning, and resource capacity management.',
    CONSTRAINT pk_proposal PRIMARY KEY(`proposal_id`)
) COMMENT 'Master record for CRO proposals submitted in response to sponsor bid requests, including full line-item cost and scope detail. Captures proposal number, version, type (full-service, FSP, change order), submission date, total proposed budget, proposed';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` (
    `proposal_line_id` BIGINT COMMENT 'Unique system-generated identifier for each proposal line item within the CRO proposal. Serves as the primary key for this entity.',
    `prior_version_line_proposal_line_id` BIGINT COMMENT 'Reference to the previous version of this proposal line item, enabling version chain traceability. Supports audit trail and change history analysis for scope and budget negotiations.',
    `proposal_id` BIGINT COMMENT 'Reference to the parent CRO proposal header to which this line item belongs. Establishes the header-detail relationship between the proposal and its individual cost/scope lines.',
    `rate_card_id` BIGINT COMMENT 'Foreign key linking to agreement.rate_card. Business justification: Proposal lines are priced using negotiated rate cards from the MSA or PPA. Linking proposal_line to the rate_card used provides a pricing audit trail, supports contract negotiation',
    `regulatory_procedure_id` BIGINT COMMENT 'Foreign key linking to regulatory.procedure. Business justification: Regulatory affairs proposal lines are priced based on specific regulatory procedures (standard vs. priority review, centralized vs. national procedure).',
    `approved_timestamp` TIMESTAMP COMMENT 'The date and time when this proposal line was formally approved by the sponsor or internal governance. Marks the transition from negotiation to contracted scope and triggers downstream contract and financial processes.',
    `assumptions` STRING COMMENT 'Narrative text capturing the specific protocol and operational assumptions underlying the quantity estimate and pricing for this line item (e.g., assumed number of sites, patient enrollment rate, visit frequency, country mix).',
    `billing_schedule_type` STRING COMMENT 'The invoicing cadence or trigger type for this line item, defining when the CRO will invoice the sponsor for this service (e.g., monthly pro-rata, quarterly, upon milestone achievement, upfront, upon completion). Drives accounts receivable planning.. Valid values are `monthly|quarterly|milestone|upfront|upon_completion`',
    `cdisc_domain` STRING COMMENT 'The CDISC SDTM or ADaM domain associated with this service line when applicable (e.g., DM, AE, LB, EX). Used to align data management and biostatistics proposal lines with CDISC submission deliverables for regulatory filings.',
    `contingency_pct` DECIMAL(5,2) COMMENT 'The contingency reserve percentage added to the base line amount to account for scope uncertainty, protocol amendments, or operational risk. Expressed as a percentage of the total line amount. Classified as confidential.',
    `cost_type` STRING COMMENT 'Indicates whether this line item represents a direct cost (CRO-provided service billed at negotiated rates) or a pass-through cost (third-party expense incurred on behalf of the sponsor and billed at actual cost, e.g., IRB fees, travel, laboratory. Valid values are `direct|pass_through`',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code identifying the specific country for which this line item is scoped, when the line is country-specific. Enables country-level budget breakdown for multi-national trials.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this proposal line record was first created in the system. Supports audit trail requirements and proposal timeline analysis.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which the unit price and total line amount are denominated (e.g., USD, EUR, GBP, JPY). Supports multi-currency proposal management for global clinical trials.. Valid values are `^[A-Z]{3}$`',
    `discount_pct` DECIMAL(5,2) COMMENT 'The negotiated discount percentage applied to the list price for this line item. Reflects sponsor relationship pricing, volume commitments, or strategic partnership terms. Classified as confidential due to commercially sensitive negotiation data.',
    `estimated_duration_months` BIGINT COMMENT 'The assumed study duration in months underlying the quantity estimate for time-based service lines (e.g., project management, medical monitoring). Changes to study timeline trigger scope change assessments for these lines.',
    `estimated_quantity` DECIMAL(18,4) COMMENT 'The projected number of units of measure anticipated for this service line over the study duration. Based on protocol assumptions such as number of sites, patients, visits, or months. Drives the total line amount calculation.',
    `estimated_site_count` BIGINT COMMENT 'The number of investigative sites assumed in the quantity estimate for this line item. A key driver for monitoring, site management, and start-up cost lines. Changes to site count trigger scope change assessments.',
    `estimated_subject_count` BIGINT COMMENT 'The number of study subjects (patients) assumed in the quantity estimate for this line item. A primary driver for patient-level service lines such as data management, safety reporting, and laboratory processing.',
    `gl_account_code` STRING COMMENT 'The the source system account code associated with this line item for revenue recognition and cost accounting purposes. Ensures proper financial classification upon contract execution and invoice generation.',
    `internal_cost_center` STRING COMMENT 'The CROs internal the source system code to which the revenue and costs for this line item will be allocated upon contract execution. Enables financial reporting and profitability analysis by organizational unit.',
    `is_milestone_based` BOOLEAN COMMENT 'Indicates whether payment for this line item is triggered by achievement of a defined study milestone (e.g., first patient enrolled, database lock, regulatory submission) rather than by unit consumption.',
    `is_optional` BOOLEAN COMMENT 'Indicates whether this line item represents an optional service that the sponsor may elect to include or exclude from the final contracted scope. Optional lines are excluded from the base budget total until confirmed by the sponsor.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'The date and time when this proposal line record was most recently updated. Tracks the recency of changes during the negotiation lifecycle and supports data lineage requirements.',
    `line_description` STRING COMMENT 'Detailed narrative description of the specific service, deliverable, or activity represented by this proposal line. Provides the scope context required for sponsor review and contract negotiation.',
    `line_number` BIGINT COMMENT 'Sequential ordering number of this line item within the parent proposal. Used to maintain the structured presentation of the proposal scope and facilitate line-level negotiations with sponsors.',
    `line_status` STRING COMMENT 'Current workflow state of this proposal line item in the negotiation and approval lifecycle. Tracks progression from initial draft through sponsor review, negotiation, and final approval or rejection.. Valid values are `draft|under_review|approved|rejected|negotiating|superseded`',
    `overhead_rate_pct` DECIMAL(5,2) COMMENT 'The overhead or indirect cost rate applied to this line item as a percentage of direct costs. Reflects the CROs internal cost allocation for facilities, infrastructure, and administrative support.',
    `payment_milestone` STRING COMMENT 'The specific study milestone event that triggers payment for this line item when is_milestone_based is true (e.g., study start-up completion, first patient first visit, last patient last visit, database lock, CSR delivery).',
    `region` STRING COMMENT 'The geographic region or country scope for which this line item is applicable (e.g., North America, Europe, Asia-Pacific, or specific country codes). Supports regional cost differentiation and multi-regional study budgeting.',
    `regulatory_submission_type` STRING COMMENT 'The type of regulatory submission deliverable associated with this line item when applicable (e.g., IND, NDA, BLA, MAA, eCTD package, SUSAR report, DSUR). Relevant for regulatory affairs and medical writing service lines.',
    `resource_type` STRING COMMENT 'Categorizes the primary resource type delivering this service line (internal CRO staff, subcontracted CRO, technology platform, facility, or third-party vendor). Informs make-vs-buy decisions and subcontractor management.. Valid values are `internal_staff|subcontractor|technology|facility|third_party_vendor`',
    `scope_change_reference` STRING COMMENT 'Reference identifier for the change order or scope amendment that introduced or modified this line item. Links the line to the formal change control process when the proposal is revised post-initial submission.',
    `service_category` STRING COMMENT 'High-level classification of the CRO service being proposed on this line. Defines the functional area of work (e.g., project management, clinical monitoring, data management, biostatistics, regulatory affairs, medical writing, laboratory services, supply',
    `service_subcategory` STRING COMMENT 'Granular classification within the service category, providing a more detailed breakdown of the specific activity or deliverable (e.g., within Clinical Monitoring: on-site monitoring visits, remote monitoring, SDV).',
    `sponsor_approved` BOOLEAN COMMENT 'Indicates whether the sponsor has formally approved this line item as part of the final contracted scope. Used to distinguish approved budget lines from those still under negotiation or pending sponsor confirmation.',
    `sponsor_comment` STRING COMMENT 'Free-text comments or feedback provided by the sponsor during the proposal review and negotiation process for this specific line item. Captures negotiation context and rationale for line-level changes.',
    `study_phase` STRING COMMENT 'The clinical development phase of the study for which this proposal line is scoped (Phase I through Phase IV). Influences pricing, resource requirements, and regulatory complexity for the service line.. Valid values are `Phase_I|Phase_II|Phase_III|Phase_IV|Phase_I/II`',
    `subcontractor_name` STRING COMMENT 'Name of the third-party subcontractor or vendor responsible for delivering this line item when resource_type is subcontractor or third_party_vendor. Required for sponsor transparency and regulatory oversight of delegated activities per ICH E6(R2).',
    `therapeutic_area` STRING COMMENT 'The clinical therapeutic area associated with this proposal line, used for resource planning and pricing benchmarking (e.g., oncology, cardiology, neurology, immunology). Enables therapeutic area-specific cost analysis across proposals.',
    `total_line_amount` DECIMAL(18,2) COMMENT 'The total proposed cost for this line item, calculated as unit price multiplied by estimated quantity. Represents the full financial commitment for this scope element. Classified as confidential due to commercially sensitive budget information.',
    `unit_of_measure` STRING COMMENT 'The unit by which the service or activity is quantified and priced (e.g., per visit, per site, per patient, per hour, per month, per report, per sample, lump sum). Defines the basis for unit price and quantity calculations.',
    `unit_price` DECIMAL(18,4) COMMENT 'The negotiated or proposed price per single unit of measure for this service line. Forms the basis for total line amount calculation. Classified as confidential due to commercially sensitive pricing information.',
    `version_number` BIGINT COMMENT 'The version iteration of this proposal line, incremented each time the line is revised during negotiation or scope change. Enables tracking of line-level changes across proposal versions and supports audit trail requirements.',
    `wbs_element` STRING COMMENT 'The the source system Structure element code that maps this proposal line to the project accounting hierarchy. Enables project-level cost tracking, earned value management, and financial reporting against the contracted scope.',
    CONSTRAINT pk_proposal_line PRIMARY KEY(`proposal_line_id`)
) COMMENT 'Line-item detail of a CRO proposal, capturing the granular cost and scope breakdown by service category. Each line captures service category (project management, clinical monitoring, data management, biostatistics, regulatory, medical writing, laboratory';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`sponsor`.`escalation` (
    `escalation_id` BIGINT COMMENT 'Unique system-generated identifier for the sponsor escalation record. Primary key for the escalation data product within the sponsor domain.',
    `clinical_program_id` BIGINT COMMENT 'Foreign key linking to program.clinical_program. Business justification: Program-level escalations (e.g., regulatory holds, safety signals affecting the whole program) must be tracked at the clinical program level, not just study or site level.',
    `cro_owner_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Escalation resolution management requires a proper FK to the CRO employee who owns the escalation for CAPA initiation, regulatory reportability decisions, and governance review',
    `disposition_id` BIGINT COMMENT 'Foreign key linking to subject.disposition. Business justification: Subject dispositions such as death or unexpected withdrawal trigger sponsor escalations requiring immediate notification.',
    `investigational_site_id` BIGINT COMMENT 'Reference to the investigational site associated with this escalation, if the escalation is site-specific. Null if the escalation is study-wide or sponsor-wide.',
    `organization_contact_id` BIGINT COMMENT 'Foreign key linking to sponsor.sponsor_contact. Business justification: The escalation table stores sponsor_contact_name and sponsor_contact_email as free-text strings for the sponsor-side contact on the escalation.',
    `organization_id` BIGINT COMMENT 'Reference to the sponsor organization that is the subject of or party to this escalation. Links to the sponsor.organization master record.',
    `parent_escalation_id` BIGINT COMMENT 'Self-referencing identifier linking this escalation to a parent escalation record, used when an escalation is a sub-issue or recurrence of a prior escalation. Supports hierarchical escalation tracking.',
    `regulatory_correspondence_id` BIGINT COMMENT 'Foreign key linking to regulatory.correspondence. Business justification: Regulatory-reportable escalations (clinical holds, safety signals, GCP deviations) generate or are resolved through formal health authority correspondence.',
    `regulatory_inspection_id` BIGINT COMMENT 'Foreign key linking to regulatory.regulatory_inspection. Business justification: Escalations flagged as `is_regulatory_reportable` are directly triggered by or result in regulatory inspections.',
    `service_level_agreement_id` BIGINT COMMENT 'Foreign key linking to agreement.service_level_agreement. Business justification: Escalations are frequently triggered by SLA breaches (enrollment rate, site activation, data query rate).',
    `sponsor_engagement_id` BIGINT COMMENT 'Foreign key linking to sponsor.engagement. Business justification: Escalations raised by or to sponsor organizations occur within the context of a commercial engagement.',
    `study_contract_id` BIGINT COMMENT 'Foreign key linking to agreement.study_contract. Business justification: Escalations related to contract disputes, payment delays, or scope disagreements must reference the governing study_contract for contract dispute resolution, SLA penalty assessment',
    `study_id` BIGINT COMMENT 'Reference to the clinical study associated with this escalation. Enables study-level escalation tracking and portfolio-level sponsor reporting.',
    `subject_deviation_id` BIGINT COMMENT 'Foreign key linking to subject.subject_deviation. Business justification: Sponsor escalations are formally raised in response to specific protocol deviations with regulatory or safety impact.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Escalations reference supporting TMF documents (protocol deviation records, audit findings, CAPA documentation).',
    `trial_subject_id` BIGINT COMMENT 'Foreign key linking to subject.trial_subject. Business justification: Subject-level sponsor escalations (e.g., serious safety events, unblinding requests, subject rights concerns) require direct reference to the specific trial subject.',
    `acknowledged_date` DATE COMMENT 'Date on which the receiving party (sponsor or CRO) formally acknowledged receipt of the escalation. Used for SLA compliance measurement and audit trail.',
    `actual_resolution_date` DATE COMMENT 'The calendar date on which the escalation was formally resolved. Compared against target_resolution_date to measure SLA compliance and CRO performance.',
    `capa_reference` STRING COMMENT 'Reference identifier of the associated CAPA record in MasterControl or equivalent quality management system, if a formal CAPA was initiated as a result of this escalation.',
    `channel` STRING COMMENT 'The communication channel or mechanism through which the escalation was formally raised (e.g., CTMS system entry, governance meeting, written notice). Supports audit trail and process compliance.. Valid values are `ctms|email|governance_meeting|phone|written_notice|audit_finding`',
    `closed_by` STRING COMMENT 'Name or user identifier of the individual who formally closed the escalation record. Required for audit trail and accountability per ALCOA+ and 21 CFR Part 11.',
    `closure_date` DATE COMMENT 'Date on which the escalation was formally closed after resolution verification and sponsor sign-off. Distinct from actual_resolution_date — closure may follow resolution after a verification period.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the escalation record was first created in the system. Supports audit trail, data lineage, and ALCOA+ compliance requirements.',
    `ctms_escalation_ref` STRING COMMENT 'Source system reference identifier from the source system for this escalation record. Enables traceability back to the operational system of record for data lineage and reconciliation.',
    `escalation_date` DATE COMMENT 'The calendar date on which the escalation was formally raised and entered into the system. Serves as the principal business event date for SLA and timeline calculations.',
    `escalation_description` STRING COMMENT 'Detailed narrative describing the issue, its context, observed impact, and any immediate actions taken at the time of escalation. Supports ALCOA+ documentation requirements.',
    `financial_impact_usd` DECIMAL(18,2) COMMENT 'Estimated or actual financial impact of the escalation in US dollars. Relevant for budget overrun escalations, contract amendment triggers, and sponsor financial reporting. Classified confidential as commercially sensitive.',
    `governance_review_date` DATE COMMENT 'Date on which the escalation was reviewed at a formal governance forum. Populated when governance_review_required is true and the review has occurred.',
    `governance_review_required` BOOLEAN COMMENT 'Indicates whether this escalation requires review at a formal governance forum (e.g., Joint Steering Committee, DSMB/DMC, Executive Sponsor Review). Triggers governance meeting agenda inclusion.',
    `impacted_functional_area` STRING COMMENT 'The primary business functional area impacted by this escalation. Used for cross-functional reporting, resource allocation, and trend analysis by department.',
    `irb_iec_notified` BOOLEAN COMMENT 'Indicates whether the relevant IRB or IEC has been formally notified of this escalation. Required for escalations involving protocol deviations, safety events, or consent issues.',
    `is_regulatory_reportable` BOOLEAN COMMENT 'Indicates whether this escalation requires formal notification to a regulatory authority (FDA, EMA, MHRA, PMDA, etc.) or ethics committee (IRB/IEC). Drives regulatory submission workflows.',
    `is_safety_related` BOOLEAN COMMENT 'Indicates whether this escalation involves a patient safety concern, adverse event, or safety signal. Triggers expedited review and mandatory safety reporting workflows.',
    `number` STRING COMMENT 'Human-readable, externally referenceable identifier for the escalation (e.g., ESC-2024-000123). Used in sponsor communications, governance meetings, and audit trails.. Valid values are `^ESC-[0-9]{4}-[0-9]{6}$`',
    `priority` STRING COMMENT 'Operational priority assigned to the escalation to guide response timing and resource allocation. Distinct from severity_level — priority reflects operational urgency while severity reflects impact magnitude.. Valid values are `immediate|urgent|standard|low`',
    `raised_by_contact_email` STRING COMMENT 'Email address of the individual who raised the escalation. Used for notification routing and audit trail. Classified as confidential PII per GDPR and HIPAA.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `raised_by_contact_name` STRING COMMENT 'Full name of the sponsor contact or CRO staff member who formally raised the escalation. Provides accountability and audit trail per ALCOA+ principles.',
    `raised_by_org_role` STRING COMMENT 'Functional role of the individual who raised the escalation within their organization. Supports governance reporting and escalation pattern analysis by role.',
    `recurrence_flag` BOOLEAN COMMENT 'Indicates whether this escalation represents a recurrence of a previously resolved issue. Triggers enhanced CAPA review and systemic risk assessment.',
    `regulatory_authority_notified` STRING COMMENT 'Name of the regulatory authority (e.g., FDA, EMA, MHRA, PMDA, TGA, Health Canada) formally notified of this escalation, if applicable. Populated when is_regulatory_reportable is true.',
    `resolution_description` STRING COMMENT 'Detailed narrative of the actions taken and outcome achieved to resolve the escalation. Required for audit trail completeness and regulatory inspection readiness per ALCOA+.',
    `resolution_type` STRING COMMENT 'Categorical classification of the resolution approach applied to close the escalation. Supports trend analysis and CAPA linkage. [ENUM-REF-CANDIDATE',
    `root_cause_category` STRING COMMENT 'High-level categorization of the identified root cause of the escalation. Populated upon investigation and used for systemic trend analysis and CAPA prioritization.',
    `root_cause_description` STRING COMMENT 'Detailed narrative of the identified root cause following investigation. Complements root_cause_category with specific findings. Required for CAPA initiation and regulatory inspection readiness.',
    `severity_level` STRING COMMENT 'Severity classification of the escalation indicating urgency and potential impact on study conduct, patient safety, data integrity, or regulatory compliance. Critical indicates immediate action required.. Valid values are `critical|high|medium|low`',
    `source` STRING COMMENT 'Identifies the originating party or function that raised the escalation. Distinguishes sponsor-initiated from CRO-initiated or site-initiated escalations for accountability tracking.',
    `escalation_status` STRING COMMENT 'Current lifecycle state of the escalation record. Tracks progression from initial identification through resolution and formal closure.. Valid values are `open|in_progress|resolved|closed`',
    `target_resolution_date` DATE COMMENT 'The agreed-upon or contractually committed date by which the escalation must be resolved. Used for SLA monitoring, KPI reporting, and sponsor governance dashboards.',
    `timeline_impact_days` BIGINT COMMENT 'Estimated or confirmed number of calendar days by which the escalation has delayed or is projected to delay the study timeline. Used for milestone impact assessment and sponsor reporting.',
    `title` STRING COMMENT 'Short, descriptive title summarizing the escalation issue. Used in dashboards, governance reports, and sponsor communication summaries.',
    `escalation_type` STRING COMMENT 'Categorical classification of the nature of the escalation. Drives routing, ownership assignment, and resolution workflows. [ENUM-REF-CANDIDATE: quality_issue|timeline_delay|budget_overrun|safety_concern|resource_issue|regulatory_risk|relationship_issue —',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the escalation record. Required for change tracking, audit trail, and Silver layer incremental processing in the Databricks Lakehouse.',
    CONSTRAINT pk_escalation PRIMARY KEY(`escalation_id`)
) COMMENT 'Tracks formal escalations raised by or to sponsor organizations during study execution. Captures escalation date, escalation type (quality issue, timeline delay, budget overrun, safety concern, resource issue, regulatory risk, relationship issue)';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` (
    `account_plan_id` BIGINT COMMENT 'Unique surrogate identifier for the strategic account plan record within the CROs sponsor account management system.',
    `clinical_program_id` BIGINT COMMENT 'Foreign key linking to program.clinical_program. Business justification: Account plans reference specific clinical programs as pipeline opportunities and strategic objectives. CRO account managers track program-level revenue targets within account plans.',
    `master_agreement_id` BIGINT COMMENT 'Foreign key linking to sponsor.master_agreement. Business justification: An account plan references the governing master agreement under which the sponsor relationship operates.',
    `master_service_agreement_id` BIGINT COMMENT 'Foreign key linking to agreement.master_service_agreement. Business justification: Account plans must reference the governing MSA for legal framework, audit rights, and compliance obligations tracked in annual planning cycles.',
    `organization_id` BIGINT COMMENT 'Reference to the sponsor organization (pharmaceutical or biotech company) for which this strategic account plan has been developed.',
    `preferred_provider_agreement_id` BIGINT COMMENT 'Foreign key linking to agreement.preferred_provider_agreement. Business justification: Annual account plans are built around PPA volume commitments, rate cards, and service scope.',
    `primary_account_employee_id` BIGINT COMMENT 'Reference to the CRO employee (typically a Global Account Director or VP of Business Development) who owns the primary sponsor relationship and is accountable for executing this account plan.',
    `prior_plan_account_plan_id` BIGINT COMMENT 'Reference to the preceding account plan for this sponsor, enabling year-over-year continuity tracking and performance comparison against prior period objectives.',
    `sponsor_engagement_id` BIGINT COMMENT 'Foreign key linking to sponsor.engagement. Business justification: An account plan is developed to support a specific commercial engagement with a sponsor.',
    `therapeutic_area_id` BIGINT COMMENT 'Foreign key linking to program.therapeutic_area. Business justification: Account plans are scoped by therapeutic area for CRO capability alignment and revenue targeting. account_plan has therapeutic_area_focus as a denormalized plain text field.',
    `account_tier` STRING COMMENT 'CRO-assigned tier classification for the sponsor account reflecting strategic importance, revenue contribution, and relationship depth. Strategic accounts receive the most intensive account management resources.. Valid values are `strategic|preferred|standard|emerging`',
    `active_study_count_target` BIGINT COMMENT 'Target number of concurrently active studies to be running for this sponsor by end of the account plan period. Key performance indicator for account growth and portfolio depth.',
    `approved_date` DATE COMMENT 'Date on which the account plan was formally approved by CRO leadership and authorized for execution. Marks the transition from planning to active account management.',
    `biostatistics_revenue_target_usd` DECIMAL(18,2) COMMENT 'Revenue target in USD for biostatistics and statistical programming service line (the source system CSR support) within this account plan period.',
    `clinical_ops_revenue_target_usd` DECIMAL(18,2) COMMENT 'Revenue target in USD for clinical operations service line (site management, monitoring, CRA services) within this account plan period.',
    `competitive_threats` STRING COMMENT 'Narrative description of identified competitive threats from other CROs or service providers targeting this sponsor account. Captures intelligence on competitor positioning, pricing pressure, and relationship risks to inform defensive account strategy.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this account plan record was first created in the system, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Supports audit trail and data lineage requirements.',
    `ctms_account_plan_ref` STRING COMMENT 'Native record identifier for this account plan in the source system the system of record for sponsor account management. Enables traceability back to the source operational system.',
    `data_management_revenue_target_usd` DECIMAL(18,2) COMMENT 'Revenue target in USD for data management service line (EDC, eCRF, CDISC/SDTM/ADaM transformation, DBL) within this account plan period.',
    `governance_meeting_frequency` STRING COMMENT 'Planned frequency of formal governance touchpoints (Joint Steering Committee, Executive Business Reviews, Operational Reviews) with the sponsor during this account plan period.. Valid values are `monthly|quarterly|semi_annual|annual|ad_hoc`',
    `innovation_initiatives` STRING COMMENT 'Description of joint innovation or technology initiatives planned with the sponsor during the account plan period, such as decentralized trial pilots, AI-driven patient recruitment, or integrated CTMS/EDC connectivity.',
    `key_sponsor_stakeholders` STRING COMMENT 'Narrative or structured summary of key sponsor-side stakeholders to engage during the plan period, including their roles (e.g., VP Clinical Operations, Head of Outsourcing, CMO) and engagement priorities. Supports relationship mapping and contact strategy.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this account plan record was most recently modified, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Supports change tracking and audit trail requirements.',
    `next_governance_meeting_date` DATE COMMENT 'Scheduled date of the next formal governance touchpoint with the sponsor (e.g., Joint Steering Committee or Executive Business Review). Drives proactive account management scheduling.',
    `pipeline_opportunity_count` BIGINT COMMENT 'Number of identified pipeline study opportunities from the sponsors drug development portfolio that the CRO is targeting for award during this account plan period. Drives business development prioritization.',
    `pipeline_opportunity_value_usd` DECIMAL(18,2) COMMENT 'Estimated total contract value in USD of all identified pipeline study opportunities targeted for award during this account plan period. Used for revenue forecasting and resource planning.',
    `plan_code` STRING COMMENT 'Externally-known alphanumeric code uniquely identifying this account plan, typically formatted as AP-{SponsorCode}-{Year}. Used in business development communications and governance reporting.. Valid values are `^AP-[A-Z0-9]{4,10}-[0-9]{4}$`',
    `plan_end_date` DATE COMMENT 'Date on which the account plan period formally closes. Nullable for open-ended strategic plans. Triggers plan review and renewal workflow when reached.',
    `plan_name` STRING COMMENT 'Descriptive name of the strategic account plan, typically including the sponsor name and plan period (e.g., Pfizer Strategic Account Plan FY2025).',
    `plan_start_date` DATE COMMENT 'Date on which the account plan period formally begins and strategic objectives become active. Aligns with the sponsor engagement cycle or CRO fiscal year.',
    `plan_status` STRING COMMENT 'Current lifecycle state of the account plan. Draft: being authored; Under Review: submitted for internal approval; Approved: signed off by leadership; Active: currently being executed; Closed: plan period ended or superseded.. Valid values are `draft|under_review|approved|active|closed`',
    `plan_type` STRING COMMENT 'Classification of the account plan by its temporal scope and purpose. Annual plans cover a single fiscal year; multi-year plans span two or more years; renewal plans are created at contract renewal; remediation plans address relationship recovery.. Valid values are `annual|multi_year|renewal|remediation`',
    `plan_version` BIGINT COMMENT 'Version number of this account plan document, incremented each time the plan is formally revised and re-approved. Supports plan lifecycle tracking and audit trail.',
    `plan_year` BIGINT COMMENT 'Primary fiscal or calendar year this account plan covers. For multi-year plans, this represents the starting year. Used for annual performance tracking and year-over-year comparison.',
    `preferred_provider_status` STRING COMMENT 'Current status of the CROs preferred or approved provider designation with this sponsor. Preferred status typically grants first-look rights on new study opportunities and streamlined contracting.. Valid values are `preferred|approved|non_preferred|in_negotiation`',
    `regulatory_affairs_revenue_target_usd` DECIMAL(18,2) COMMENT 'Revenue target in USD for regulatory affairs service line (IND/NDA/BLA/MAA submissions, eCTD preparation, agency interactions) within this account plan period.',
    `relationship_development_goals` STRING COMMENT 'Specific goals for deepening or broadening the CRO-sponsor relationship during the plan period, such as expanding into new divisions, achieving executive-level engagement, or establishing a joint innovation council.',
    `relationship_health_score` BIGINT COMMENT 'Numeric score (1-10) representing the assessed health and strength of the CRO-sponsor relationship at the time of plan creation or last review. Informed by sponsor satisfaction surveys, escalation history, and account manager assessment.',
    `revenue_target_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the revenue target amount (e.g., USD, EUR, GBP). Supports multi-currency sponsor relationships.. Valid values are `^[A-Z]{3}$`',
    `revenue_target_usd` DECIMAL(18,2) COMMENT 'Total CRO revenue target in US dollars for this account plan period across all service lines. Represents the gross contracted and pipeline revenue goal set during account planning.',
    `risk_summary` STRING COMMENT 'Summary of key risks to the account relationship or revenue targets identified during plan development, such as sponsor M&A activity, pipeline failures, budget cuts, or competitive displacement. Informs mitigation planning.',
    `sponsor_satisfaction_score` DECIMAL(4,2) COMMENT 'Most recent sponsor satisfaction survey score (e.g., on a 1.00–5.00 or 0.00–10.00 scale) captured from formal sponsor feedback mechanisms. Baseline metric for relationship development goals in the plan.',
    `strategic_objectives` STRING COMMENT 'Narrative description of the primary strategic objectives for this account plan period, such as expanding into new therapeutic areas, securing preferred provider status, or deepening data analytics partnerships.',
    CONSTRAINT pk_account_plan PRIMARY KEY(`account_plan_id`)
) COMMENT 'Strategic account plan developed by the CRO for key sponsor accounts, capturing the annual or multi-year relationship strategy. Tracks plan period, strategic objectives, revenue targets by service line, pipeline opportunities identified, relationship';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`sponsor`.`engagement_contact_assignment` (
    `engagement_contact_assignment_id` BIGINT COMMENT 'Primary key for the engagement_contact_assignment association',
    `organization_contact_id` BIGINT COMMENT 'Foreign key linking this assignment record to the specific sponsor contact individual being assigned to the engagement.',
    `sponsor_engagement_id` BIGINT COMMENT 'Foreign key linking this assignment record to the specific CRO-sponsor commercial engagement to which the contact is assigned.',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — engagement contact assignment should reference the study context',
    `assignment_status` STRING COMMENT 'Current lifecycle status of this contacts assignment within this specific engagement. Corresponds to contact_status_in_engagement identified in the detection phase. A contact may be active in one engagement and departed from another simultaneously.',
    `end_date` DATE COMMENT 'The date on which this sponsor contacts involvement in this specific engagement formally ended or is scheduled to end. Moved from sponsor_contact.engagement_end_date, where it was incorrectly scoped globally.',
    `engagement_end_date` DATE COMMENT 'The date on which this sponsor contacts engagement with the CRO formally ended (e.g., upon departure from sponsor, study close-out, or contract termination). Null for currently active contacts.',
    `engagement_start_date` DATE COMMENT 'The date on which this sponsor contact formally began their engagement with the CRO, typically aligned with contract execution or study assignment. Used for relationship tenure tracking and access provisioning.',
    `is_primary` BOOLEAN COMMENT 'Indicates whether this contact is the designated primary point of contact for this specific engagement. A contact may be primary in one engagement and secondary in another; this flag belongs to the assignment, not to the contact record globally.',
    `role_in_engagement` STRING COMMENT 'The functional role this sponsor contact holds within this specific engagement. A contact may hold different roles across different engagements (e.g., medical monitor in one, regulatory lead in another).',
    `start_date` DATE COMMENT 'The date on which this sponsor contact formally began their involvement in this specific engagement. Moved from sponsor_contact.engagement_start_date, where it was incorrectly scoped to the contact globally rather than per engagement assignment.',
    CONSTRAINT pk_engagement_contact_assignment PRIMARY KEY(`engagement_contact_assignment_id`)
) COMMENT 'This association product represents the formal Role assignment between a sponsor_contact and an engagement. It captures the operational record of which sponsor personnel are assigned to a CRO commercial engagement, in what functional capacity, and for';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`sponsor`.`engagement_scope` (
    `engagement_scope_id` BIGINT COMMENT 'Primary key for the engagement_scope association',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to the health authority that is in scope for this engagement',
    `sponsor_engagement_id` BIGINT COMMENT 'Foreign key linking to the CRO-sponsor commercial engagement that defines the scope context',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — engagement scope should reference the study when scoped at study level',
    `primary_contact_name` STRING COMMENT 'Name of the designated primary regulatory contact at this health authority for this specific engagement. Sourced from detection phase relationship data.',
    `regulatory_region` STRING COMMENT 'The specific regulatory region or jurisdiction agreed as in-scope for this engagement-HA pairing (e.g., North America, EU, Asia-Pacific). Sourced from detection phase relationship data.',
    `engagement_scope_status` STRING COMMENT 'Current lifecycle status of this health authoritys scope within the engagement (e.g., planned, active, suspended, closed). Sourced from detection phase relationship data as engagement_status.',
    `submission_volume_target` DECIMAL(18,2) COMMENT 'The planned number or volume of regulatory submissions to this health authority under this engagement for the planning period. Sourced from detection phase relationship data.',
    CONSTRAINT pk_engagement_scope PRIMARY KEY(`engagement_scope_id`)
) COMMENT 'This association product represents the Contract/Scope between a sponsor engagement and a health authority. It captures the formal designation of which health authorities are in scope for a given CRO-sponsor engagement, along with submission volume';

ALTER SCHEMA `clinical_trials_ecm`.`sponsor` SET TAGS ('dbx_division' = 'business');

ALTER SCHEMA `clinical_trials_ecm`.`sponsor` SET TAGS ('dbx_domain' = 'sponsor');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ADD CONSTRAINT `fk_sponsor_organization_parent_org_organization_id` FOREIGN KEY (`parent_org_organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ADD CONSTRAINT `fk_sponsor_organization_primary_ultimate_parent_org_organization_id` FOREIGN KEY (`primary_ultimate_parent_org_organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` SET TAGS ('dbx_domain' = 'sponsor');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` SET TAGS ('dbx_subdomain' = 'enterprise_management');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` SET TAGS ('dbx_v2_expansion' = 'additive');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` SET TAGS ('dbx_v1_preserve' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Organization Identifier');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `parent_org_organization_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Organization ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `primary_ultimate_parent_org_organization_id` SET TAGS ('dbx_business_glossary_term' = 'Ultimate Parent Organization ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `annual_rd_budget_usd_range` SET TAGS ('dbx_business_glossary_term' = 'Annual Research and Development (R&D) Budget Range (USD)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `annual_rd_budget_usd_range` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `contract_framework_type` SET TAGS ('dbx_value_regex' = 'master_service_agreement|preferred_provider|project_based|functional_service_provider|none');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `contract_framework_type` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `corporate_tier` SET TAGS ('dbx_value_regex' = 'big_pharma|mid_size|emerging_biotech|academic_institution|government_agency');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `cro_relationship_type` SET TAGS ('dbx_business_glossary_term' = 'Contract Research Organization (CRO) Relationship Type');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `cro_relationship_type` SET TAGS ('dbx_value_regex' = 'full_service|functional_service|preferred|transactional|strategic_partner');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `ctms_account_code` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Account ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `duns_number` SET TAGS ('dbx_business_glossary_term' = 'Data Universal Numbering System (DUNS) Number');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `duns_number` SET TAGS ('dbx_value_regex' = '^[0-9]{9}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `duns_number` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `ema_org_number` SET TAGS ('dbx_business_glossary_term' = 'European Medicines Agency (EMA) Organization ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `employee_count_range` SET TAGS ('dbx_value_regex' = '1_50|51_200|201_1000|1001_5000|5001_10000|10000_plus');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `fda_sponsor_number` SET TAGS ('dbx_business_glossary_term' = 'Food and Drug Administration (FDA) Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `gcp_audit_required` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Audit Required Indicator');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `headquarters_city` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `headquarters_city` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `headquarters_city` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `headquarters_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `headquarters_state_province` SET TAGS ('dbx_business_glossary_term' = 'Headquarters State or Province');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `headquarters_state_province` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `headquarters_state_province` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `headquarters_state_province` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `ind_holder` SET TAGS ('dbx_business_glossary_term' = 'Investigational New Drug (IND) Holder Indicator');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `is_publicly_traded` SET TAGS ('dbx_business_glossary_term' = 'Publicly Traded Indicator');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `legal_name` SET TAGS ('dbx_business_glossary_term' = 'Legal Organization Name');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `legal_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `legal_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `master_agreement_expiry_date` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Organization Notes');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `notes` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `org_status` SET TAGS ('dbx_business_glossary_term' = 'Organization Status');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `org_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|pending|terminated');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `org_type` SET TAGS ('dbx_business_glossary_term' = 'Organization Type');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `preferred_edc_system` SET TAGS ('dbx_business_glossary_term' = 'Preferred Electronic Data Capture (EDC) System');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `preferred_edc_system` SET TAGS ('dbx_value_regex' = 'medidata_rave|oracle_clinical_one|veeva_vault_edclinical|other|none');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `preferred_etmf_system` SET TAGS ('dbx_business_glossary_term' = 'Preferred Electronic Trial Master File (eTMF) System');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `preferred_etmf_system` SET TAGS ('dbx_value_regex' = 'veeva_vault|other|none');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Email Address');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_pii_email' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Phone Number');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `regulatory_strategy_region` SET TAGS ('dbx_value_regex' = 'global|usa_only|eu_only|usa_eu|asia_pacific|multi_regional');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `safety_reporting_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Safety Reporting Contact Email Address');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `safety_reporting_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `safety_reporting_contact_email` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `safety_reporting_contact_email` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `safety_reporting_contact_email` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `safety_reporting_contact_email` SET TAGS ('dbx_pii_email' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `sap_vendor_code` SET TAGS ('dbx_business_glossary_term' = 'SAP Vendor ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `sap_vendor_code` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `stock_exchange` SET TAGS ('dbx_value_regex' = 'NYSE|NASDAQ|LSE|TSX|ASX|OTHER');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `stock_ticker` SET TAGS ('dbx_business_glossary_term' = 'Stock Ticker Symbol');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `stock_ticker` SET TAGS ('dbx_value_regex' = '^[A-Z]{1,5}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `tax_number` SET TAGS ('dbx_business_glossary_term' = 'Tax Identification Number');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `tax_number` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `tax_number` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `tax_number` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `trade_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `website_url` SET TAGS ('dbx_business_glossary_term' = 'Organization Website URL');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization` ALTER COLUMN `who_universal_trial_number_prefix` SET TAGS ('dbx_business_glossary_term' = 'World Health Organization (WHO) Universal Trial Number Prefix');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ADD CONSTRAINT `fk_sponsor_org_hierarchy_child_org_organization_id` FOREIGN KEY (`child_org_organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ADD CONSTRAINT `fk_sponsor_org_hierarchy_primary_organization_id` FOREIGN KEY (`primary_organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ADD CONSTRAINT `fk_sponsor_org_hierarchy_tertiary_workday_org_organization_id` FOREIGN KEY (`tertiary_workday_org_organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` SET TAGS ('dbx_domain' = 'sponsor');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` SET TAGS ('dbx_subdomain' = 'enterprise_management');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` SET TAGS ('dbx_v2_expansion' = 'additive');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` SET TAGS ('dbx_v1_preserve' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `org_hierarchy_id` SET TAGS ('dbx_business_glossary_term' = 'Organization Hierarchy ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `child_org_organization_id` SET TAGS ('dbx_business_glossary_term' = 'Child Organization ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `primary_organization_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Organization ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `tertiary_workday_org_organization_id` SET TAGS ('dbx_business_glossary_term' = 'Workday HCM Organization ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Hierarchy Approval Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Hierarchy Approval Authority');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `change_reason` SET TAGS ('dbx_business_glossary_term' = 'Hierarchy Change Reason');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `consolidation_scope` SET TAGS ('dbx_business_glossary_term' = 'Financial Consolidation Scope');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `consolidation_scope` SET TAGS ('dbx_value_regex' = 'full|proportional|equity_method|excluded');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Child Organization Country Code');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `ctms_org_code` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Organization Code');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `ctms_org_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{2,30}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Relationship Effective End Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Relationship Effective Start Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `gdpr_data_controller_role` SET TAGS ('dbx_value_regex' = 'controller|joint_controller|processor|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `hierarchy_level` SET TAGS ('dbx_business_glossary_term' = 'Hierarchy Depth Level');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `hierarchy_path` SET TAGS ('dbx_business_glossary_term' = 'Hierarchy Path String');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `hierarchy_version` SET TAGS ('dbx_business_glossary_term' = 'Hierarchy Record Version');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `ind_holder_flag` SET TAGS ('dbx_business_glossary_term' = 'Investigational New Drug (IND) Holder Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `is_controlling_entity` SET TAGS ('dbx_business_glossary_term' = 'Controlling Entity Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `is_primary_path` SET TAGS ('dbx_business_glossary_term' = 'Primary Hierarchy Path Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Hierarchy Relationship Notes');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `ownership_percentage` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `ownership_percentage` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `pipeline_scope` SET TAGS ('dbx_value_regex' = 'full_pipeline|regional_pipeline|single_asset|no_pipeline');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `relationship_basis` SET TAGS ('dbx_value_regex' = 'equity|contractual|regulatory|operational|statutory');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `relationship_code` SET TAGS ('dbx_business_glossary_term' = 'Hierarchy Relationship Code');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `relationship_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,20}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `relationship_status` SET TAGS ('dbx_business_glossary_term' = 'Hierarchy Relationship Status');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `relationship_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|terminated|suspended');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `relationship_type` SET TAGS ('dbx_business_glossary_term' = 'Organization Relationship Type');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `sap_company_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{4}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `source_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `veeva_account_code` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Account ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `voting_rights_percentage` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`org_hierarchy` ALTER COLUMN `voting_rights_percentage` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ADD CONSTRAINT `fk_sponsor_organization_contact_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` SET TAGS ('dbx_domain' = 'sponsor');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` SET TAGS ('dbx_subdomain' = 'enterprise_management');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` SET TAGS ('dbx_cross_domain_duplicate_resolution' = 'distinct');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` SET TAGS ('dbx_ownership' = 'self_owned');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` SET TAGS ('dbx_cross_domain_duplicate_resolved' = 'distinct_contact');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` SET TAGS ('dbx_owner_domain' = 'sponsor');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` SET TAGS ('dbx_v2_expansion' = 'additive');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` SET TAGS ('dbx_v1_preserve' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Organization ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `contact_context` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `contact_status` SET TAGS ('dbx_value_regex' = 'active|inactive|departed|on_leave');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `contact_status` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `ctms_contact_ref` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Contact Reference');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `ctms_contact_ref` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `data_source` SET TAGS ('dbx_value_regex' = 'siebel_ctms|veeva_vault|manual_entry|sponsor_portal|workday_hcm');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `do_not_contact` SET TAGS ('dbx_business_glossary_term' = 'Do Not Contact Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `do_not_contact` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `first_name` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `first_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `first_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `gdpr_consent_date` SET TAGS ('dbx_business_glossary_term' = 'General Data Protection Regulation (GDPR) Consent Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `gdpr_consent_date` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `gdpr_consent_date` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `gdpr_consent_date` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `gdpr_consent_status` SET TAGS ('dbx_business_glossary_term' = 'General Data Protection Regulation (GDPR) Consent Status');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `gdpr_consent_status` SET TAGS ('dbx_value_regex' = 'granted|withdrawn|pending|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `gdpr_consent_status` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `gdpr_consent_status` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `gdpr_consent_status` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `is_financial_contact` SET TAGS ('dbx_business_glossary_term' = 'Is Financial Contact Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `is_financial_contact` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `is_primary_contact` SET TAGS ('dbx_business_glossary_term' = 'Is Primary Contact Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `is_primary_contact` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `is_regulatory_contact` SET TAGS ('dbx_business_glossary_term' = 'Is Regulatory Contact Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `is_regulatory_contact` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `is_safety_contact` SET TAGS ('dbx_business_glossary_term' = 'Is Safety Contact Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `is_safety_contact` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `language_preference` SET TAGS ('dbx_value_regex' = '^[a-z]{2}(-[A-Z]{2})?$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `language_preference` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `last_name` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `last_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `last_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `linkedin_profile_url` SET TAGS ('dbx_value_regex' = '^https://(www.)?linkedin.com/in/[a-zA-Z0-9-_%]+/?$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `linkedin_profile_url` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `linkedin_profile_url` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `linkedin_profile_url` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `middle_name` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `middle_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `middle_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Contact Notes');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `notes` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `office_location` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `office_location` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `office_location` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `preferred_communication_channel` SET TAGS ('dbx_value_regex' = 'email|phone|video_conference|secure_portal|instant_message');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `primary_email` SET TAGS ('dbx_business_glossary_term' = 'Primary Email Address');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `primary_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `primary_email` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `primary_email` SET TAGS ('dbx_pii_email' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `primary_email` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `primary_phone` SET TAGS ('dbx_business_glossary_term' = 'Primary Phone Number');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `primary_phone` SET TAGS ('dbx_value_regex' = '^+?[1-9]d{1,14}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `primary_phone` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `primary_phone` SET TAGS ('dbx_pii_phone' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `primary_phone` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `role_type` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Contact Role Type');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `role_type` SET TAGS ('dbx_value_regex' = 'medical_monitor|project_manager|regulatory_affairs|clinical_operations|business_development|pharmacovigilance');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `salutation` SET TAGS ('dbx_value_regex' = 'Dr.|Mr.|Ms.|Mrs.|Prof.');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `secondary_email` SET TAGS ('dbx_business_glossary_term' = 'Secondary Email Address');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `secondary_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `secondary_email` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `secondary_email` SET TAGS ('dbx_pii_email' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `secondary_email` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `secondary_phone` SET TAGS ('dbx_business_glossary_term' = 'Secondary Phone Number');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `secondary_phone` SET TAGS ('dbx_value_regex' = '^+?[1-9]d{1,14}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `secondary_phone` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `secondary_phone` SET TAGS ('dbx_pii_phone' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `secondary_phone` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `veeva_contact_ref` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Contact Reference');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`organization_contact` ALTER COLUMN `veeva_contact_ref` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ADD CONSTRAINT `fk_sponsor_pipeline_asset_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ADD CONSTRAINT `fk_sponsor_pipeline_asset_indication_id` FOREIGN KEY (`indication_id`) REFERENCES `clinical_trials_ecm`.`program`.`indication`(`indication_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ADD CONSTRAINT `fk_sponsor_pipeline_asset_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ADD CONSTRAINT `fk_sponsor_pipeline_asset_therapeutic_area_id` FOREIGN KEY (`therapeutic_area_id`) REFERENCES `clinical_trials_ecm`.`program`.`therapeutic_area`(`therapeutic_area_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` SET TAGS ('dbx_domain' = 'sponsor');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` SET TAGS ('dbx_subdomain' = 'portfolio_development');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` SET TAGS ('dbx_v2_expansion' = 'additive');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` SET TAGS ('dbx_v1_preserve' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `indication_id` SET TAGS ('dbx_business_glossary_term' = 'Indication Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `therapeutic_area_id` SET TAGS ('dbx_business_glossary_term' = 'Therapeutic Area Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `accelerated_approval` SET TAGS ('dbx_business_glossary_term' = 'Accelerated Approval Pathway Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `active_study_count` SET TAGS ('dbx_business_glossary_term' = 'Active Clinical Study Count');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `asset_code` SET TAGS ('dbx_business_glossary_term' = 'Pipeline Asset Code');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `asset_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{2,30}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `asset_description` SET TAGS ('dbx_business_glossary_term' = 'Pipeline Asset Description');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `asset_description` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `asset_status` SET TAGS ('dbx_business_glossary_term' = 'Pipeline Asset Status');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `asset_status` SET TAGS ('dbx_value_regex' = 'active|on_hold|discontinued|approved|divested');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `atc_code` SET TAGS ('dbx_business_glossary_term' = 'Anatomical Therapeutic Chemical (ATC) Classification Code');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `atc_code` SET TAGS ('dbx_value_regex' = '^[A-Z][0-9]{2}[A-Z]{2}[0-9]{2}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `brand_name_candidate` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `brand_name_candidate` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `breakthrough_therapy_designation` SET TAGS ('dbx_business_glossary_term' = 'Breakthrough Therapy Designation (BTD) Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `clinicaltrials_gov_number` SET TAGS ('dbx_business_glossary_term' = 'ClinicalTrials.gov Registry Identifier (NCT Number)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `clinicaltrials_gov_number` SET TAGS ('dbx_value_regex' = '^NCT[0-9]{8}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `compound_name` SET TAGS ('dbx_business_glossary_term' = 'Compound / Molecule Name');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `compound_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `compound_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `cta_number` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorisation (CTA) Number');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `discontinuation_date` SET TAGS ('dbx_business_glossary_term' = 'Development Discontinuation Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `discontinuation_reason` SET TAGS ('dbx_business_glossary_term' = 'Development Discontinuation Reason');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `dosage_form` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `eudract_number` SET TAGS ('dbx_business_glossary_term' = 'EudraCT / CTIS Number');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `eudract_number` SET TAGS ('dbx_value_regex' = '^[0-9]{4}-[0-9]{6}-[0-9]{2}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `fast_track_designation` SET TAGS ('dbx_business_glossary_term' = 'Fast Track Designation Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `filing_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Status (NDA/BLA/MAA)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `first_in_human_date` SET TAGS ('dbx_business_glossary_term' = 'First-in-Human (FIH) Study Start Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `ind_submission_date` SET TAGS ('dbx_business_glossary_term' = 'IND/CTA Submission Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `inn` SET TAGS ('dbx_business_glossary_term' = 'International Nonproprietary Name (INN)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `market_exclusivity_expiry_date` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `mechanism_of_action` SET TAGS ('dbx_business_glossary_term' = 'Mechanism of Action (MoA)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `meddra_indication_code` SET TAGS ('dbx_business_glossary_term' = 'MedDRA Indication Code (Preferred Term)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `meddra_indication_code` SET TAGS ('dbx_value_regex' = '^[0-9]{8}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `modality` SET TAGS ('dbx_business_glossary_term' = 'Drug Modality');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `nda_bla_maa_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Marketing Application (NDA/BLA/MAA) Submission Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `orphan_drug_designation` SET TAGS ('dbx_business_glossary_term' = 'Orphan Drug Designation (ODD) Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `patent_expiry_date` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `pediatric_investigation_plan` SET TAGS ('dbx_business_glossary_term' = 'Pediatric Investigation Plan (PIP) / Pediatric Study Plan (PSP) Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `prime_designation` SET TAGS ('dbx_business_glossary_term' = 'EMA PRIority MEdicines (PRIME) Designation Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `risk_management_plan_required` SET TAGS ('dbx_business_glossary_term' = 'Risk Management Plan (RMP) Required Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `risk_management_plan_required` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ADD CONSTRAINT `fk_sponsor_pipeline_asset_phase_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ADD CONSTRAINT `fk_sponsor_pipeline_asset_phase_indication_id` FOREIGN KEY (`indication_id`) REFERENCES `clinical_trials_ecm`.`program`.`indication`(`indication_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ADD CONSTRAINT `fk_sponsor_pipeline_asset_phase_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ADD CONSTRAINT `fk_sponsor_pipeline_asset_phase_pipeline_asset_id` FOREIGN KEY (`pipeline_asset_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`pipeline_asset`(`pipeline_asset_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ADD CONSTRAINT `fk_sponsor_pipeline_asset_phase_regulatory_program_milestone_id` FOREIGN KEY (`regulatory_program_milestone_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`regulatory_program_milestone`(`regulatory_program_milestone_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ADD CONSTRAINT `fk_sponsor_pipeline_asset_phase_therapeutic_area_id` FOREIGN KEY (`therapeutic_area_id`) REFERENCES `clinical_trials_ecm`.`program`.`therapeutic_area`(`therapeutic_area_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` SET TAGS ('dbx_domain' = 'sponsor');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` SET TAGS ('dbx_subdomain' = 'portfolio_development');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` SET TAGS ('dbx_v2_expansion' = 'additive');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` SET TAGS ('dbx_v1_preserve' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `ind_application_id` SET TAGS ('dbx_business_glossary_term' = 'Ind Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `indication_id` SET TAGS ('dbx_business_glossary_term' = 'Indication Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `regulatory_program_milestone_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Milestone Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `therapeutic_area_id` SET TAGS ('dbx_business_glossary_term' = 'Therapeutic Area Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `accelerated_approval_pathway` SET TAGS ('dbx_business_glossary_term' = 'Accelerated Approval Pathway Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `actual_enrollment` SET TAGS ('dbx_business_glossary_term' = 'Actual Enrollment (Subjects)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `actual_spend_usd` SET TAGS ('dbx_business_glossary_term' = 'Actual Phase Spend (USD)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `actual_spend_usd` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `breakthrough_designation` SET TAGS ('dbx_business_glossary_term' = 'Breakthrough Therapy Designation Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `csr_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study Report (CSR) Submission Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `database_lock_date` SET TAGS ('dbx_business_glossary_term' = 'Database Lock (DBL) Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `dsmb_review_required` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Review Required Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `estimated_enrollment` SET TAGS ('dbx_business_glossary_term' = 'Estimated Enrollment (Subjects)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `fast_track_designation` SET TAGS ('dbx_business_glossary_term' = 'Fast Track Designation Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `go_no_go_decision` SET TAGS ('dbx_business_glossary_term' = 'Go/No-Go Decision');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `go_no_go_decision` SET TAGS ('dbx_value_regex' = 'go|no_go|conditional_go|pending');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `go_no_go_decision_date` SET TAGS ('dbx_business_glossary_term' = 'Go/No-Go Decision Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `lead_regulatory_agency` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `meddra_indication_code` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) Indication Code');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `meddra_indication_code` SET TAGS ('dbx_value_regex' = '^[0-9]{8}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `orphan_drug_designation` SET TAGS ('dbx_business_glossary_term' = 'Orphan Drug Designation Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `phase_budget_usd` SET TAGS ('dbx_business_glossary_term' = 'Phase Budget (USD)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `phase_budget_usd` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `phase_code` SET TAGS ('dbx_business_glossary_term' = 'Clinical Development Phase Code');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `phase_duration_days` SET TAGS ('dbx_business_glossary_term' = 'Phase Duration (Days)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `phase_name` SET TAGS ('dbx_business_glossary_term' = 'Clinical Development Phase Name');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `phase_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `phase_status` SET TAGS ('dbx_value_regex' = 'active|completed|on_hold|terminated|planned');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `previous_phase_code` SET TAGS ('dbx_business_glossary_term' = 'Previous Clinical Development Phase Code');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `primary_endpoint_met` SET TAGS ('dbx_business_glossary_term' = 'Primary Endpoint Met Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `regulatory_strategy_notes` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `termination_reason_category` SET TAGS ('dbx_value_regex' = 'safety|efficacy|commercial|regulatory|strategic|operational');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `transition_reason` SET TAGS ('dbx_business_glossary_term' = 'Phase Transition Reason');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `transition_type` SET TAGS ('dbx_business_glossary_term' = 'Phase Transition Type');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `transition_type` SET TAGS ('dbx_value_regex' = 'progression|hold|termination|restart|amendment');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`pipeline_asset_phase` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ADD CONSTRAINT `fk_sponsor_study_portfolio_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ADD CONSTRAINT `fk_sponsor_study_portfolio_organization_contact_id` FOREIGN KEY (`organization_contact_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization_contact`(`organization_contact_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ADD CONSTRAINT `fk_sponsor_study_portfolio_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ADD CONSTRAINT `fk_sponsor_study_portfolio_sponsor_engagement_id` FOREIGN KEY (`sponsor_engagement_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`sponsor_engagement`(`sponsor_engagement_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ADD CONSTRAINT `fk_sponsor_study_portfolio_therapeutic_area_id` FOREIGN KEY (`therapeutic_area_id`) REFERENCES `clinical_trials_ecm`.`program`.`therapeutic_area`(`therapeutic_area_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` SET TAGS ('dbx_domain' = 'sponsor');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` SET TAGS ('dbx_subdomain' = 'portfolio_development');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` SET TAGS ('dbx_v2_expansion' = 'additive');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` SET TAGS ('dbx_v1_preserve' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'CRO Portfolio Lead ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `employee_id` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Primary Contact ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Engagement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `therapeutic_area_id` SET TAGS ('dbx_business_glossary_term' = 'Therapeutic Area Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `cdisc_compliance_required` SET TAGS ('dbx_business_glossary_term' = 'CDISC Compliance Required Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `data_management_system` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) System');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `data_management_system` SET TAGS ('dbx_value_regex' = 'medidata_rave|oracle_clinical_one|veeva_vault_edl|other');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `data_management_system` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `development_phase` SET TAGS ('dbx_business_glossary_term' = 'Clinical Development Phase');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `development_phase` SET TAGS ('dbx_value_regex' = 'phase_1|phase_2|phase_3|phase_4|mixed');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `icf_management_system` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Management System');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `icf_management_system` SET TAGS ('dbx_value_regex' = 'clinpal|paper|veeva_vault|other');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `icf_management_system` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `indication` SET TAGS ('dbx_business_glossary_term' = 'Clinical Indication');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `irb_iec_oversight_model` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Oversight Model');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `irb_iec_oversight_model` SET TAGS ('dbx_value_regex' = 'central_irb|local_irb|iec|mixed');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `kpi_data_query_rate` SET TAGS ('dbx_business_glossary_term' = 'Data Query Rate KPI Target (Percentage)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `kpi_enrollment_target` SET TAGS ('dbx_business_glossary_term' = 'Portfolio-Level Enrollment Target (KPI)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `kpi_site_activation_days` SET TAGS ('dbx_business_glossary_term' = 'Site Activation KPI Target (Days)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Notes');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `portfolio_budget_usd` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Budget (USD)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `portfolio_budget_usd` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `portfolio_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{3,30}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `portfolio_description` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `portfolio_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `portfolio_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `portfolio_status` SET TAGS ('dbx_value_regex' = 'active|wind_down|completed|suspended|pending');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `primary_regulatory_agency` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `rtsm_required` SET TAGS ('dbx_business_glossary_term' = 'Randomization and Trial Supply Management (RTSM) Required Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `safety_reporting_standard` SET TAGS ('dbx_value_regex' = 'ich_e2a|ich_e2b_r3|ctcae_v5|other');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `site_count_target` SET TAGS ('dbx_business_glossary_term' = 'Target Site Count');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `source_system_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `strategic_priority_tier` SET TAGS ('dbx_value_regex' = 'tier_1|tier_2|tier_3');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `strategic_priority_tier` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `submission_type` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission Type');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `tmf_system` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) System');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `tmf_system` SET TAGS ('dbx_value_regex' = 'veeva_vault_etmf|paper_tmf|other');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`study_portfolio` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ADD CONSTRAINT `fk_sponsor_sponsor_engagement_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ADD CONSTRAINT `fk_sponsor_sponsor_engagement_master_agreement_id` FOREIGN KEY (`master_agreement_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`master_agreement`(`master_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ADD CONSTRAINT `fk_sponsor_sponsor_engagement_master_service_agreement_id` FOREIGN KEY (`master_service_agreement_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`master_service_agreement`(`master_service_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ADD CONSTRAINT `fk_sponsor_sponsor_engagement_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ADD CONSTRAINT `fk_sponsor_sponsor_engagement_therapeutic_area_id` FOREIGN KEY (`therapeutic_area_id`) REFERENCES `clinical_trials_ecm`.`program`.`therapeutic_area`(`therapeutic_area_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` SET TAGS ('dbx_domain' = 'sponsor');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` SET TAGS ('dbx_subdomain' = 'relationship_governance');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` SET TAGS ('dbx_v2_expansion' = 'additive');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` SET TAGS ('dbx_v1_preserve' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Engagement ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Program Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `master_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Master Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `master_service_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Master Service Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `therapeutic_area_id` SET TAGS ('dbx_business_glossary_term' = 'Therapeutic Area Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `account_plan_period_end` SET TAGS ('dbx_business_glossary_term' = 'Account Plan Period End Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `account_plan_period_start` SET TAGS ('dbx_business_glossary_term' = 'Account Plan Period Start Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `account_plan_status` SET TAGS ('dbx_business_glossary_term' = 'Strategic Account Plan Status');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `account_plan_status` SET TAGS ('dbx_value_regex' = 'draft|approved|active|closed');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `annual_revenue_target` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `competitive_threats` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `confidentiality_agreement_ref` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Agreement Reference');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `confidentiality_agreement_ref` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `data_privacy_framework` SET TAGS ('dbx_value_regex' = 'GDPR|HIPAA|PIPEDA|PDPA|combined|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `end_date` SET TAGS ('dbx_business_glossary_term' = 'Engagement End Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `engagement_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{4,20}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `engagement_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `engagement_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `engagement_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `engagement_type` SET TAGS ('dbx_value_regex' = 'full_service_cro|functional_service_provider|co_development|preferred_provider|standalone');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `engagement_type` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `escalation_count_ytd` SET TAGS ('dbx_business_glossary_term' = 'Escalation Count Year-to-Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `governance_cadence` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual|ad_hoc');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `key_sponsor_stakeholders` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `last_governance_date` SET TAGS ('dbx_business_glossary_term' = 'Last Governance Meeting Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `next_governance_date` SET TAGS ('dbx_business_glossary_term' = 'Next Governance Meeting Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Engagement Notes');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `notes` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `pipeline_opportunity_value` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `preferred_provider_flag` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `primary_geography` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `relationship_development_goals` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `relationship_health_score` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `revenue_target_biostatistics` SET TAGS ('dbx_business_glossary_term' = 'Revenue Target - Biostatistics Service Line');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `revenue_target_biostatistics` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `revenue_target_clinical_ops` SET TAGS ('dbx_business_glossary_term' = 'Revenue Target - Clinical Operations Service Line');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `revenue_target_clinical_ops` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `revenue_target_data_management` SET TAGS ('dbx_business_glossary_term' = 'Revenue Target - Data Management Service Line');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `revenue_target_data_management` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `revenue_target_data_management` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `revenue_target_regulatory` SET TAGS ('dbx_business_glossary_term' = 'Revenue Target - Regulatory Affairs Service Line');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `revenue_target_regulatory` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `sponsor_satisfaction_score` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `start_date` SET TAGS ('dbx_business_glossary_term' = 'Engagement Start Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `sponsor_engagement_status` SET TAGS ('dbx_business_glossary_term' = 'Engagement Status');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `sponsor_engagement_status` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `strategic_account_tier` SET TAGS ('dbx_value_regex' = 'tier_1|tier_2|tier_3|tier_4');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `strategic_account_tier` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `strategic_objectives` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `total_contracted_value` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`sponsor_engagement` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ADD CONSTRAINT `fk_sponsor_master_agreement_master_service_agreement_id` FOREIGN KEY (`master_service_agreement_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`master_service_agreement`(`master_service_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ADD CONSTRAINT `fk_sponsor_master_agreement_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ADD CONSTRAINT `fk_sponsor_master_agreement_preferred_provider_agreement_id` FOREIGN KEY (`preferred_provider_agreement_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement`(`preferred_provider_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ADD CONSTRAINT `fk_sponsor_master_agreement_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ADD CONSTRAINT `fk_sponsor_master_agreement_therapeutic_area_id` FOREIGN KEY (`therapeutic_area_id`) REFERENCES `clinical_trials_ecm`.`program`.`therapeutic_area`(`therapeutic_area_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` SET TAGS ('dbx_domain' = 'sponsor');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` SET TAGS ('dbx_subdomain' = 'relationship_governance');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` SET TAGS ('dbx_v2_expansion' = 'additive');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` SET TAGS ('dbx_v1_preserve' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `master_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Master Agreement Identifier');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `master_service_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Master Service Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `preferred_provider_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Preferred Provider Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `therapeutic_area_id` SET TAGS ('dbx_business_glossary_term' = 'Therapeutic Area Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `agreement_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `agreement_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `agreement_number` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `agreement_type` SET TAGS ('dbx_value_regex' = 'MSA|preferred_provider|FSP_master|alliance|strategic_partnership');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `agreement_type` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `confidentiality_term_years` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Term (Years)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `data_privacy_framework` SET TAGS ('dbx_value_regex' = 'GDPR|HIPAA|PIPEDA|PDPA|combined|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `dispute_resolution_mechanism` SET TAGS ('dbx_value_regex' = 'arbitration|mediation|litigation|expert_determination');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `dispute_resolution_mechanism` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `effective_date` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `etmf_plan_reference` SET TAGS ('dbx_business_glossary_term' = 'Electronic Trial Master File (eTMF) Plan Reference');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `execution_date` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `expiration_date` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `governance_committee_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `governance_review_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `governing_law_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `indemnification_cap_usd` SET TAGS ('dbx_business_glossary_term' = 'Indemnification Cap (USD)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `indemnification_cap_usd` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `initial_term_months` SET TAGS ('dbx_business_glossary_term' = 'Initial Term (Months)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `invoicing_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|milestone|annual|upon_completion');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `ip_ownership_terms` SET TAGS ('dbx_business_glossary_term' = 'Intellectual Property (IP) Ownership Terms');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `ip_ownership_terms` SET TAGS ('dbx_value_regex' = 'sponsor_owned|shared|cro_licensed|jointly_developed');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `ip_ownership_terms` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `minimum_volume_commitment_usd` SET TAGS ('dbx_business_glossary_term' = 'Minimum Volume Commitment (USD)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `minimum_volume_commitment_usd` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `payment_terms` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `preferred_pricing_discount_pct` SET TAGS ('dbx_business_glossary_term' = 'Preferred Pricing Discount Percentage');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `preferred_pricing_discount_pct` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `renewal_notice_days` SET TAGS ('dbx_business_glossary_term' = 'Renewal Notice Period (Days)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `renewal_term_months` SET TAGS ('dbx_business_glossary_term' = 'Renewal Term (Months)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `service_scope_description` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `sponsor_executive_owner` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `sponsor_executive_owner` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `sponsor_executive_owner` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `strategic_partnership_level` SET TAGS ('dbx_value_regex' = 'preferred|strategic|alliance|standard|emerging');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `strategic_partnership_level` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `termination_date` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `termination_for_convenience_notice_days` SET TAGS ('dbx_business_glossary_term' = 'Termination for Convenience Notice Period (Days)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `termination_reason` SET TAGS ('dbx_value_regex' = 'convenience|breach|mutual_agreement|regulatory|sponsor_insolvency|cro_insolvency');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `termination_reason` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `volume_commitment_tier` SET TAGS ('dbx_value_regex' = 'tier_1|tier_2|tier_3|tier_4');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`master_agreement` ALTER COLUMN `volume_commitment_tier` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ADD CONSTRAINT `fk_sponsor_regulatory_strategy_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ADD CONSTRAINT `fk_sponsor_regulatory_strategy_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ADD CONSTRAINT `fk_sponsor_regulatory_strategy_cro_regulatory_lead_employee_id` FOREIGN KEY (`cro_regulatory_lead_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ADD CONSTRAINT `fk_sponsor_regulatory_strategy_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ADD CONSTRAINT `fk_sponsor_regulatory_strategy_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ADD CONSTRAINT `fk_sponsor_regulatory_strategy_indication_id` FOREIGN KEY (`indication_id`) REFERENCES `clinical_trials_ecm`.`program`.`indication`(`indication_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ADD CONSTRAINT `fk_sponsor_regulatory_strategy_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ADD CONSTRAINT `fk_sponsor_regulatory_strategy_regulatory_regulatory_strategy_id` FOREIGN KEY (`regulatory_regulatory_strategy_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`strategy`(`strategy_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ADD CONSTRAINT `fk_sponsor_regulatory_strategy_therapeutic_area_id` FOREIGN KEY (`therapeutic_area_id`) REFERENCES `clinical_trials_ecm`.`program`.`therapeutic_area`(`therapeutic_area_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` SET TAGS ('dbx_domain' = 'sponsor');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` SET TAGS ('dbx_subdomain' = 'portfolio_development');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` SET TAGS ('dbx_v2_expansion' = 'additive');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` SET TAGS ('dbx_v1_preserve' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `regulatory_strategy_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Strategy Identifier');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Study Program ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `cro_regulatory_lead_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Cro Regulatory Lead Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `cro_regulatory_lead_employee_id` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `cro_regulatory_lead_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `ind_application_id` SET TAGS ('dbx_business_glossary_term' = 'Ind Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `indication_id` SET TAGS ('dbx_business_glossary_term' = 'Indication Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `regulatory_regulatory_strategy_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Regulatory Strategy Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `therapeutic_area_id` SET TAGS ('dbx_business_glossary_term' = 'Therapeutic Area Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `actual_ind_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Investigational New Drug (IND) Submission Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `actual_nda_bla_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Actual New Drug Application (NDA) / Biologics License Application (BLA) Submission Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `additional_health_authorities` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `additional_health_authorities` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `advisory_committee_required` SET TAGS ('dbx_business_glossary_term' = 'Advisory Committee Meeting Required');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `designation_granted_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Designation Granted Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `designation_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Designation Status');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `designation_status` SET TAGS ('dbx_value_regex' = 'not_requested|requested|granted|denied|withdrawn');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `ectd_sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Electronic Common Technical Document (eCTD) Sequence Number');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `ectd_sequence_number` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Strategy Effective Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Strategy Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `global_harmonization_approach` SET TAGS ('dbx_value_regex' = 'single_dossier|regional_adaptation|parallel_submission|rolling_submission|staggered_submission');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `last_pre_submission_meeting_date` SET TAGS ('dbx_business_glossary_term' = 'Last Pre-Submission Meeting Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `lead_regulatory_contact` SET TAGS ('dbx_business_glossary_term' = 'Lead Regulatory Affairs Contact');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `lead_regulatory_contact` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `lead_regulatory_contact` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `lead_regulatory_contact` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `nda_bla_number` SET TAGS ('dbx_business_glossary_term' = 'New Drug Application (NDA) / Biologics License Application (BLA) Number');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `nda_bla_number` SET TAGS ('dbx_value_regex' = '^[0-9]{6}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `next_pre_submission_meeting_date` SET TAGS ('dbx_business_glossary_term' = 'Next Pre-Submission Meeting Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `pdufa_target_date` SET TAGS ('dbx_business_glossary_term' = 'Prescription Drug User Fee Act (PDUFA) Target Action Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `pediatric_plan_required` SET TAGS ('dbx_business_glossary_term' = 'Pediatric Study Plan Required');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `planned_ind_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Planned Investigational New Drug (IND) Submission Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `planned_nda_bla_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Planned New Drug Application (NDA) / Biologics License Application (BLA) Submission Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `pre_submission_meeting_type` SET TAGS ('dbx_business_glossary_term' = 'Pre-Submission Meeting Type');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `regulatory_risk_level` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `rems_required` SET TAGS ('dbx_business_glossary_term' = 'Risk Evaluation and Mitigation Strategy (REMS) Required');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `risk_mitigation_strategy` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Risk Mitigation Strategy');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `strategy_description` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Strategy Description');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `strategy_name` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Strategy Name');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `strategy_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `strategy_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Strategy Status');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `strategy_status` SET TAGS ('dbx_value_regex' = 'draft|active|under_review|approved|superseded|archived');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `strategy_version` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Strategy Version');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `strategy_version` SET TAGS ('dbx_value_regex' = '^vd+.d+$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `submission_pathway` SET TAGS ('dbx_value_regex' = 'IND|NDA|BLA|MAA|505(b)(2)|biosimilar|ANDA|CTD');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`regulatory_strategy` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ADD CONSTRAINT `fk_sponsor_delivery_preference_governing_document_sop_id` FOREIGN KEY (`governing_document_sop_id`) REFERENCES `clinical_trials_ecm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ADD CONSTRAINT `fk_sponsor_delivery_preference_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ADD CONSTRAINT `fk_sponsor_delivery_preference_preferred_provider_agreement_id` FOREIGN KEY (`preferred_provider_agreement_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement`(`preferred_provider_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ADD CONSTRAINT `fk_sponsor_delivery_preference_superseded_by_delivery_preference_id` FOREIGN KEY (`superseded_by_delivery_preference_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`delivery_preference`(`delivery_preference_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ADD CONSTRAINT `fk_sponsor_delivery_preference_template_id` FOREIGN KEY (`template_id`) REFERENCES `clinical_trials_ecm`.`document`.`template`(`template_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` SET TAGS ('dbx_domain' = 'sponsor');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` SET TAGS ('dbx_subdomain' = 'relationship_governance');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` SET TAGS ('dbx_v2_expansion' = 'additive');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` SET TAGS ('dbx_v1_preserve' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `delivery_preference_id` SET TAGS ('dbx_business_glossary_term' = 'Delivery Preference Identifier');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `governing_document_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Governing Document Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `preferred_provider_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Preferred Provider Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `superseded_by_delivery_preference_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Preference ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `template_id` SET TAGS ('dbx_business_glossary_term' = 'Document Template Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `adam_version` SET TAGS ('dbx_business_glossary_term' = 'Analysis Data Model (ADaM) Version');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `audit_trail_requirement` SET TAGS ('dbx_business_glossary_term' = 'Audit Trail Requirement Standard');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `audit_trail_requirement` SET TAGS ('dbx_value_regex' = '21_cfr_part11|eu_annex11|both|sponsor_standard');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `biostatistics_software` SET TAGS ('dbx_business_glossary_term' = 'Biostatistics Software Preference');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `biostatistics_software` SET TAGS ('dbx_value_regex' = 'sas|r|sas_drug_development|other');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `cdisc_define_xml_version` SET TAGS ('dbx_business_glossary_term' = 'CDISC Define-XML Version');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `ctms_preference` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Preference');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `ctms_preference` SET TAGS ('dbx_value_regex' = 'oracle_siebel_ctms|veeva_ctms|medidata_rave_ctms|sponsor_owned|cro_standard|other');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `data_privacy_framework` SET TAGS ('dbx_value_regex' = 'gdpr|hipaa|gdpr_hipaa|pipeda|other');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `data_transfer_format` SET TAGS ('dbx_business_glossary_term' = 'Data Transfer Format Preference');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `data_transfer_format` SET TAGS ('dbx_value_regex' = 'sas_xpt|csv|xml|json|odm_xml|other');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `dsmb_reporting_required` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Reporting Required Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `econsent_platform` SET TAGS ('dbx_business_glossary_term' = 'Electronic Consent (eConsent) Platform Preference');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `econsent_platform` SET TAGS ('dbx_value_regex' = 'clinpal|veeva_vault|medidata_rave|docusign|other');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `econsent_required` SET TAGS ('dbx_business_glossary_term' = 'Electronic Consent (eConsent) Required Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `ectd_submission_required` SET TAGS ('dbx_business_glossary_term' = 'Electronic Common Technical Document (eCTD) Submission Required Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `edc_system_preference` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) System Preference');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `edc_system_preference` SET TAGS ('dbx_value_regex' = 'medidata_rave|oracle_clinical_one|oracle_inform|veeva_vault_edclinical|other');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `edc_system_version` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) System Version');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `etmf_system_preference` SET TAGS ('dbx_business_glossary_term' = 'Electronic Trial Master File (eTMF) System Preference');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `etmf_system_preference` SET TAGS ('dbx_value_regex' = 'veeva_vault|master_control|documentum|sharepoint|other');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `gcp_guideline_version` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Guideline Version');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `gcp_guideline_version` SET TAGS ('dbx_value_regex' = 'ich_e6_r1|ich_e6_r2|ich_e6_r3');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `interim_analysis_required` SET TAGS ('dbx_business_glossary_term' = 'Interim Analysis Required Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `lab_data_standard` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Data Standard');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `lab_data_standard` SET TAGS ('dbx_value_regex' = 'cdisc_lb|hl7_fhir|sponsor_format|other');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `meddra_version` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) Version');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `monitoring_strategy` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Strategy Preference');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `monitoring_strategy` SET TAGS ('dbx_value_regex' = 'on_site|remote|hybrid|risk_based');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Preference Notes');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `preference_code` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Preference Code');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `preference_code` SET TAGS ('dbx_value_regex' = '^SP-PREF-[A-Z0-9]{4,12}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `preference_name` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Preference Name');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `preference_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `preference_status` SET TAGS ('dbx_value_regex' = 'draft|active|superseded|retired');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `preference_type` SET TAGS ('dbx_value_regex' = 'global|therapeutic_area|study_specific|program_level');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `reporting_cadence` SET TAGS ('dbx_business_glossary_term' = 'Reporting Cadence Requirement');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `reporting_cadence` SET TAGS ('dbx_value_regex' = 'weekly|biweekly|monthly|quarterly|milestone_based');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `rtsm_system_preference` SET TAGS ('dbx_business_glossary_term' = 'Randomization and Trial Supply Management (RTSM) System Preference');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `rtsm_system_preference` SET TAGS ('dbx_value_regex' = 'medidata_rave_rtsm|oracle_clinical_one|ivrs|ixrs|other');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `safety_system_preference` SET TAGS ('dbx_business_glossary_term' = 'Safety Reporting System Preference');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `safety_system_preference` SET TAGS ('dbx_value_regex' = 'oracle_argus|oracle_aers|veeva_vault_safety|aris_g|other');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `sdtm_version` SET TAGS ('dbx_business_glossary_term' = 'Study Data Tabulation Model (SDTM) Version');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `sdv_requirement_percent` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Requirement Percentage');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `sponsor_sop_alignment_required` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Standard Operating Procedure (SOP) Alignment Required Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Preference Version Number');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+(.[0-9]+)?$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`delivery_preference` ALTER COLUMN `whodd_version` SET TAGS ('dbx_business_glossary_term' = 'WHO Drug Dictionary (WHO-DD) Version');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ADD CONSTRAINT `fk_sponsor_interaction_account_plan_id` FOREIGN KEY (`account_plan_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`account_plan`(`account_plan_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ADD CONSTRAINT `fk_sponsor_interaction_agency_meeting_id` FOREIGN KEY (`agency_meeting_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`agency_meeting`(`agency_meeting_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ADD CONSTRAINT `fk_sponsor_interaction_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ADD CONSTRAINT `fk_sponsor_interaction_cro_lead_employee_id` FOREIGN KEY (`cro_lead_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ADD CONSTRAINT `fk_sponsor_interaction_minutes_tmf_document_id` FOREIGN KEY (`minutes_tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ADD CONSTRAINT `fk_sponsor_interaction_organization_contact_id` FOREIGN KEY (`organization_contact_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization_contact`(`organization_contact_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ADD CONSTRAINT `fk_sponsor_interaction_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ADD CONSTRAINT `fk_sponsor_interaction_pipeline_asset_id` FOREIGN KEY (`pipeline_asset_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`pipeline_asset`(`pipeline_asset_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ADD CONSTRAINT `fk_sponsor_interaction_sponsor_engagement_id` FOREIGN KEY (`sponsor_engagement_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`sponsor_engagement`(`sponsor_engagement_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ADD CONSTRAINT `fk_sponsor_interaction_study_contract_id` FOREIGN KEY (`study_contract_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`study_contract`(`study_contract_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ADD CONSTRAINT `fk_sponsor_interaction_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ADD CONSTRAINT `fk_sponsor_interaction_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` SET TAGS ('dbx_domain' = 'sponsor');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` SET TAGS ('dbx_subdomain' = 'relationship_governance');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` SET TAGS ('dbx_v2_expansion' = 'additive');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` SET TAGS ('dbx_v1_preserve' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `account_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Account Plan Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `agency_meeting_id` SET TAGS ('dbx_business_glossary_term' = 'Agency Meeting Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `agency_meeting_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Program Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `cro_lead_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Cro Lead Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `cro_lead_employee_id` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `cro_lead_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `minutes_tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Minutes Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `pipeline_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Pipeline Asset Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Engagement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `study_contract_id` SET TAGS ('dbx_business_glossary_term' = 'Contract ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `agenda_summary` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `cadence_compliant` SET TAGS ('dbx_business_glossary_term' = 'Meeting Cadence Compliance Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `channel` SET TAGS ('dbx_business_glossary_term' = 'Interaction Channel');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `channel` SET TAGS ('dbx_value_regex' = 'in_person|video_conference|telephone|hybrid');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `cro_participant_count` SET TAGS ('dbx_business_glossary_term' = 'Contract Research Organization (CRO) Participant Count');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `cro_participant_count` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `cro_participant_names` SET TAGS ('dbx_business_glossary_term' = 'Contract Research Organization (CRO) Participant Names');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `cro_participant_names` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `cro_participant_names` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `cro_participant_names` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `ctms_interaction_code` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Interaction ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `duration_minutes` SET TAGS ('dbx_business_glossary_term' = 'Interaction Duration (Minutes)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `end_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Interaction End Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `follow_up_due_date` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Due Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `follow_up_required` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Required Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `governance_tier` SET TAGS ('dbx_value_regex' = 'executive|operational|study_level|site_level');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `location` SET TAGS ('dbx_business_glossary_term' = 'Interaction Location');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `minutes_approved` SET TAGS ('dbx_business_glossary_term' = 'Meeting Minutes Approved Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `minutes_approved_date` SET TAGS ('dbx_business_glossary_term' = 'Meeting Minutes Approved Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `outcome` SET TAGS ('dbx_business_glossary_term' = 'Interaction Outcome');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `outcome` SET TAGS ('dbx_value_regex' = 'positive|neutral|negative|escalated|deferred');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `reference_number` SET TAGS ('dbx_business_glossary_term' = 'Interaction Reference Number');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `reference_number` SET TAGS ('dbx_value_regex' = '^INT-[0-9]{4}-[0-9]{6}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `regulatory_agency` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `regulatory_submission_type` SET TAGS ('dbx_value_regex' = 'IND|NDA|BLA|MAA|eCTD|Other');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `sponsor_participant_count` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `sponsor_participant_names` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `sponsor_participant_names` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `sponsor_participant_names` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `start_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Interaction Start Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `interaction_status` SET TAGS ('dbx_value_regex' = 'scheduled|completed|cancelled|rescheduled|pending_minutes');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `subject` SET TAGS ('dbx_business_glossary_term' = 'Interaction Subject');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `interaction_type` SET TAGS ('dbx_value_regex' = 'governance_meeting|business_review|bid_defense|regulatory_strategy_call|escalation_call|proposal_presentation');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`interaction` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ADD CONSTRAINT `fk_sponsor_review_meeting_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ADD CONSTRAINT `fk_sponsor_review_meeting_cro_chair_employee_id` FOREIGN KEY (`cro_chair_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ADD CONSTRAINT `fk_sponsor_review_meeting_organization_contact_id` FOREIGN KEY (`organization_contact_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization_contact`(`organization_contact_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ADD CONSTRAINT `fk_sponsor_review_meeting_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ADD CONSTRAINT `fk_sponsor_review_meeting_preferred_provider_agreement_id` FOREIGN KEY (`preferred_provider_agreement_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement`(`preferred_provider_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ADD CONSTRAINT `fk_sponsor_review_meeting_sponsor_engagement_id` FOREIGN KEY (`sponsor_engagement_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`sponsor_engagement`(`sponsor_engagement_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ADD CONSTRAINT `fk_sponsor_review_meeting_study_contract_id` FOREIGN KEY (`study_contract_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`study_contract`(`study_contract_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ADD CONSTRAINT `fk_sponsor_review_meeting_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ADD CONSTRAINT `fk_sponsor_review_meeting_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ADD CONSTRAINT `fk_sponsor_review_meeting_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` SET TAGS ('dbx_domain' = 'sponsor');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` SET TAGS ('dbx_subdomain' = 'relationship_governance');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` SET TAGS ('dbx_v2_expansion' = 'additive');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` SET TAGS ('dbx_v1_preserve' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `review_meeting_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Review Meeting ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Program Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `cro_chair_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Cro Chair Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `cro_chair_employee_id` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `cro_chair_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Contact Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Organization ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `preferred_provider_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Preferred Provider Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Engagement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `study_contract_id` SET TAGS ('dbx_business_glossary_term' = 'Master Service Agreement / Contract ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Study Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Meeting Minutes Document ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `action_item_count` SET TAGS ('dbx_business_glossary_term' = 'Action Items Count');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `actual_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Meeting Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `actual_end_time` SET TAGS ('dbx_business_glossary_term' = 'Actual End Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `actual_start_time` SET TAGS ('dbx_business_glossary_term' = 'Actual Start Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `agenda_distributed_date` SET TAGS ('dbx_business_glossary_term' = 'Agenda Distribution Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `agenda_distributed_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `agenda_item_count` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `agreement_type` SET TAGS ('dbx_business_glossary_term' = 'Sponsor-CRO Agreement Type');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `agreement_type` SET TAGS ('dbx_value_regex' = 'Preferred Provider|FSP|Full Service|Functional Service|Ad Hoc');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `cro_attendee_count` SET TAGS ('dbx_business_glossary_term' = 'CRO (Contract Research Organization) Attendee Count');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `decision_count` SET TAGS ('dbx_business_glossary_term' = 'Decisions Made Count');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `escalation_raised` SET TAGS ('dbx_business_glossary_term' = 'Escalation Raised Indicator');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `financial_review_included` SET TAGS ('dbx_business_glossary_term' = 'Financial Review Included Indicator');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `governance_tier` SET TAGS ('dbx_value_regex' = 'Executive|Operational|Quality|Portfolio');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `kpi_review_included` SET TAGS ('dbx_business_glossary_term' = 'KPI (Key Performance Indicator) Review Included');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `meeting_format` SET TAGS ('dbx_value_regex' = 'In-Person|Virtual|Hybrid');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `meeting_frequency` SET TAGS ('dbx_business_glossary_term' = 'Meeting Cadence Frequency');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `meeting_number` SET TAGS ('dbx_business_glossary_term' = 'Meeting Reference Number');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `meeting_status` SET TAGS ('dbx_value_regex' = 'Scheduled|Completed|Cancelled|Rescheduled|In Progress');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `meeting_summary` SET TAGS ('dbx_business_glossary_term' = 'Meeting Executive Summary');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `meeting_type` SET TAGS ('dbx_business_glossary_term' = 'Governance Meeting Type');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `meeting_type` SET TAGS ('dbx_value_regex' = 'JSC|JOC|EBR|QBR|Ad Hoc|Other');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `minutes_approved_date` SET TAGS ('dbx_business_glossary_term' = 'Meeting Minutes Approved Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `minutes_status` SET TAGS ('dbx_business_glossary_term' = 'Meeting Minutes Status');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `minutes_status` SET TAGS ('dbx_value_regex' = 'Draft|Under Review|Approved|Finalized');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `next_meeting_date` SET TAGS ('dbx_business_glossary_term' = 'Next Scheduled Meeting Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `open_action_item_count` SET TAGS ('dbx_business_glossary_term' = 'Open Action Items Count');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `quality_review_included` SET TAGS ('dbx_business_glossary_term' = 'Quality Review Included Indicator');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `quorum_met` SET TAGS ('dbx_business_glossary_term' = 'Quorum Met Indicator');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `scheduled_date` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Meeting Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `scheduled_end_time` SET TAGS ('dbx_business_glossary_term' = 'Scheduled End Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `scheduled_start_time` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Start Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `sponsor_chair` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Meeting Chair');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `sponsor_chair` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `sponsor_chair` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `sponsor_chair` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`review_meeting` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ADD CONSTRAINT `fk_sponsor_bid_request_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ADD CONSTRAINT `fk_sponsor_bid_request_confidentiality_agreement_id` FOREIGN KEY (`confidentiality_agreement_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`confidentiality_agreement`(`confidentiality_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ADD CONSTRAINT `fk_sponsor_bid_request_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ADD CONSTRAINT `fk_sponsor_bid_request_indication_id` FOREIGN KEY (`indication_id`) REFERENCES `clinical_trials_ecm`.`program`.`indication`(`indication_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ADD CONSTRAINT `fk_sponsor_bid_request_master_service_agreement_id` FOREIGN KEY (`master_service_agreement_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`master_service_agreement`(`master_service_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ADD CONSTRAINT `fk_sponsor_bid_request_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ADD CONSTRAINT `fk_sponsor_bid_request_parent_bid_request_id` FOREIGN KEY (`parent_bid_request_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`bid_request`(`bid_request_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ADD CONSTRAINT `fk_sponsor_bid_request_pipeline_asset_id` FOREIGN KEY (`pipeline_asset_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`pipeline_asset`(`pipeline_asset_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ADD CONSTRAINT `fk_sponsor_bid_request_primary_bid_employee_id` FOREIGN KEY (`primary_bid_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ADD CONSTRAINT `fk_sponsor_bid_request_regulatory_procedure_id` FOREIGN KEY (`regulatory_procedure_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`procedure`(`procedure_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ADD CONSTRAINT `fk_sponsor_bid_request_sponsor_engagement_id` FOREIGN KEY (`sponsor_engagement_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`sponsor_engagement`(`sponsor_engagement_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ADD CONSTRAINT `fk_sponsor_bid_request_template_id` FOREIGN KEY (`template_id`) REFERENCES `clinical_trials_ecm`.`document`.`template`(`template_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ADD CONSTRAINT `fk_sponsor_bid_request_therapeutic_area_id` FOREIGN KEY (`therapeutic_area_id`) REFERENCES `clinical_trials_ecm`.`program`.`therapeutic_area`(`therapeutic_area_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` SET TAGS ('dbx_domain' = 'sponsor');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` SET TAGS ('dbx_subdomain' = 'commercial_operations');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` SET TAGS ('dbx_v2_expansion' = 'additive');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` SET TAGS ('dbx_v1_preserve' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Program Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `confidentiality_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `indication_id` SET TAGS ('dbx_business_glossary_term' = 'Indication Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `master_service_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Master Service Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `pipeline_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Pipeline Asset Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `primary_bid_employee_id` SET TAGS ('dbx_business_glossary_term' = 'CRO Business Development Lead ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `primary_bid_employee_id` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `primary_bid_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `regulatory_procedure_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Procedure Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Engagement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `template_id` SET TAGS ('dbx_business_glossary_term' = 'Document Template Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `therapeutic_area_id` SET TAGS ('dbx_business_glossary_term' = 'Therapeutic Area Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `bid_status` SET TAGS ('dbx_value_regex' = 'received|in_progress|submitted|awarded|lost|no_bid');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `budget_currency` SET TAGS ('dbx_business_glossary_term' = 'Budget Currency Code');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `budget_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `competitive_context` SET TAGS ('dbx_value_regex' = 'sole_source|competitive|preferred_provider|incumbent|unknown');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `competitive_context` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `estimated_budget_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `estimated_duration_months` SET TAGS ('dbx_business_glossary_term' = 'Estimated Study Duration (Months)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `investigational_product_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `investigational_product_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `is_resubmission` SET TAGS ('dbx_business_glossary_term' = 'Is Resubmission Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `no_bid_date` SET TAGS ('dbx_business_glossary_term' = 'No-Bid Decision Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `no_bid_reason` SET TAGS ('dbx_business_glossary_term' = 'No-Bid Reason');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Bid Request Notes');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `receipt_date` SET TAGS ('dbx_business_glossary_term' = 'RFP Receipt Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `region_scope` SET TAGS ('dbx_value_regex' = 'global|north_america|europe|asia_pacific|latin_america|middle_east_africa');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `rfp_document_ref` SET TAGS ('dbx_business_glossary_term' = 'RFP Document Reference');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `rfp_document_ref` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `rfp_number` SET TAGS ('dbx_business_glossary_term' = 'Request for Proposal (RFP) Reference Number');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `rfp_number` SET TAGS ('dbx_value_regex' = '^RFP-[A-Z0-9]{4,20}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `rfp_number` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `service_model` SET TAGS ('dbx_value_regex' = 'full_service|fsp|hybrid|module_specific');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `sponsor_budget_ceiling` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `sponsor_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Contact Email Address');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `sponsor_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `sponsor_contact_email` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `sponsor_contact_email` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `sponsor_contact_email` SET TAGS ('dbx_pii_email' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `sponsor_contact_name` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `sponsor_contact_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `sponsor_contact_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `study_code` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Study Code');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `study_code` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `study_phase` SET TAGS ('dbx_value_regex' = 'Phase I|Phase I/II|Phase II|Phase II/III|Phase III|Phase IV');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `study_title` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `study_type` SET TAGS ('dbx_value_regex' = 'interventional|observational|expanded_access|registry');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `submitted_bid_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`bid_request` ALTER COLUMN `win_probability_pct` SET TAGS ('dbx_business_glossary_term' = 'Win Probability Percentage');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ADD CONSTRAINT `fk_sponsor_proposal_bid_request_id` FOREIGN KEY (`bid_request_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`bid_request`(`bid_request_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ADD CONSTRAINT `fk_sponsor_proposal_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ADD CONSTRAINT `fk_sponsor_proposal_indication_id` FOREIGN KEY (`indication_id`) REFERENCES `clinical_trials_ecm`.`program`.`indication`(`indication_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ADD CONSTRAINT `fk_sponsor_proposal_manager_employee_id` FOREIGN KEY (`manager_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ADD CONSTRAINT `fk_sponsor_proposal_master_service_agreement_id` FOREIGN KEY (`master_service_agreement_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`master_service_agreement`(`master_service_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ADD CONSTRAINT `fk_sponsor_proposal_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ADD CONSTRAINT `fk_sponsor_proposal_pipeline_asset_id` FOREIGN KEY (`pipeline_asset_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`pipeline_asset`(`pipeline_asset_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ADD CONSTRAINT `fk_sponsor_proposal_preferred_provider_agreement_id` FOREIGN KEY (`preferred_provider_agreement_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement`(`preferred_provider_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ADD CONSTRAINT `fk_sponsor_proposal_sponsor_engagement_id` FOREIGN KEY (`sponsor_engagement_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`sponsor_engagement`(`sponsor_engagement_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ADD CONSTRAINT `fk_sponsor_proposal_template_id` FOREIGN KEY (`template_id`) REFERENCES `clinical_trials_ecm`.`document`.`template`(`template_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ADD CONSTRAINT `fk_sponsor_proposal_therapeutic_area_id` FOREIGN KEY (`therapeutic_area_id`) REFERENCES `clinical_trials_ecm`.`program`.`therapeutic_area`(`therapeutic_area_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` SET TAGS ('dbx_domain' = 'sponsor');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` SET TAGS ('dbx_subdomain' = 'commercial_operations');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` SET TAGS ('dbx_v2_expansion' = 'additive');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` SET TAGS ('dbx_v1_preserve' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Program Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `indication_id` SET TAGS ('dbx_business_glossary_term' = 'Indication Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `manager_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Proposal Manager Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `manager_employee_id` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `manager_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `master_service_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Master Service Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `pipeline_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Pipeline Asset Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `preferred_provider_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Preferred Provider Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Engagement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `template_id` SET TAGS ('dbx_business_glossary_term' = 'Document Template Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `therapeutic_area_id` SET TAGS ('dbx_business_glossary_term' = 'Therapeutic Area Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `award_date` SET TAGS ('dbx_business_glossary_term' = 'Proposal Award Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `bd_owner` SET TAGS ('dbx_business_glossary_term' = 'Business Development Owner');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `bd_owner` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `bd_owner` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `bd_owner` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Proposal Currency Code');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `direct_cost_total` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `exclusions` SET TAGS ('dbx_business_glossary_term' = 'Proposal Exclusions');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Proposal Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `investigational_product_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `is_competitive_bid` SET TAGS ('dbx_business_glossary_term' = 'Competitive Bid Indicator');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `is_rebid` SET TAGS ('dbx_business_glossary_term' = 'Rebid Indicator');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `key_assumptions` SET TAGS ('dbx_business_glossary_term' = 'Key Proposal Assumptions');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `lost_reason` SET TAGS ('dbx_business_glossary_term' = 'Proposal Lost Reason');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `number` SET TAGS ('dbx_value_regex' = '^PRO-[0-9]{4}-[0-9]{6}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `pass_through_cost_total` SET TAGS ('dbx_business_glossary_term' = 'Pass-Through Cost Total');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `pass_through_cost_total` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `payment_schedule_type` SET TAGS ('dbx_value_regex' = 'milestone|monthly|quarterly|upfront_plus_milestone');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `phase` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Phase');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `phase` SET TAGS ('dbx_value_regex' = 'phase_1|phase_1_2|phase_2|phase_2_3|phase_3|phase_4');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `pricing_model` SET TAGS ('dbx_value_regex' = 'unit_based|milestone_based|fixed_fee|time_and_materials|hybrid');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `pricing_model` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `proposed_csr_date` SET TAGS ('dbx_business_glossary_term' = 'Proposed Clinical Study Report (CSR) Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `proposed_dbl_date` SET TAGS ('dbx_business_glossary_term' = 'Proposed Database Lock (DBL) Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `proposed_fpi_date` SET TAGS ('dbx_business_glossary_term' = 'Proposed First Patient In (FPI) Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `proposed_lpo_date` SET TAGS ('dbx_business_glossary_term' = 'Proposed Last Patient Out (LPO) Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `proposed_project_director` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `proposed_project_director` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `proposed_project_director` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `risk_factors` SET TAGS ('dbx_business_glossary_term' = 'Proposal Risk Factors');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `proposal_status` SET TAGS ('dbx_value_regex' = 'draft|submitted|under_review|awarded|lost|withdrawn');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `study_duration_months` SET TAGS ('dbx_business_glossary_term' = 'Proposed Study Duration (Months)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `study_title` SET TAGS ('dbx_business_glossary_term' = 'Proposed Study Title');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'Proposal Submission Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `total_proposed_budget` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `proposal_type` SET TAGS ('dbx_value_regex' = 'full_service|fsp|change_order|budget_amendment|feasibility');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `veeva_document_code` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Proposal Version Number');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `win_probability_pct` SET TAGS ('dbx_business_glossary_term' = 'Win Probability Percentage');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal` ALTER COLUMN `win_probability_pct` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ADD CONSTRAINT `fk_sponsor_proposal_line_prior_version_line_proposal_line_id` FOREIGN KEY (`prior_version_line_proposal_line_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`proposal_line`(`proposal_line_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ADD CONSTRAINT `fk_sponsor_proposal_line_proposal_id` FOREIGN KEY (`proposal_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`proposal`(`proposal_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ADD CONSTRAINT `fk_sponsor_proposal_line_rate_card_id` FOREIGN KEY (`rate_card_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`rate_card`(`rate_card_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ADD CONSTRAINT `fk_sponsor_proposal_line_regulatory_procedure_id` FOREIGN KEY (`regulatory_procedure_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`procedure`(`procedure_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` SET TAGS ('dbx_domain' = 'sponsor');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` SET TAGS ('dbx_subdomain' = 'commercial_operations');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` SET TAGS ('dbx_v2_expansion' = 'additive');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` SET TAGS ('dbx_v1_preserve' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ALTER COLUMN `prior_version_line_proposal_line_id` SET TAGS ('dbx_business_glossary_term' = 'Prior Version Line ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ALTER COLUMN `rate_card_id` SET TAGS ('dbx_business_glossary_term' = 'Rate Card Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ALTER COLUMN `regulatory_procedure_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Procedure Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ALTER COLUMN `assumptions` SET TAGS ('dbx_business_glossary_term' = 'Line Item Assumptions');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ALTER COLUMN `billing_schedule_type` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|milestone|upfront|upon_completion');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ALTER COLUMN `cdisc_domain` SET TAGS ('dbx_business_glossary_term' = 'Clinical Data Interchange Standards Consortium (CDISC) Domain');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ALTER COLUMN `contingency_pct` SET TAGS ('dbx_business_glossary_term' = 'Contingency Percentage');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ALTER COLUMN `contingency_pct` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ALTER COLUMN `cost_type` SET TAGS ('dbx_value_regex' = 'direct|pass_through');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ALTER COLUMN `discount_pct` SET TAGS ('dbx_business_glossary_term' = 'Discount Percentage');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ALTER COLUMN `discount_pct` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ALTER COLUMN `estimated_duration_months` SET TAGS ('dbx_business_glossary_term' = 'Estimated Duration (Months)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ALTER COLUMN `is_milestone_based` SET TAGS ('dbx_business_glossary_term' = 'Milestone-Based Billing Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ALTER COLUMN `is_optional` SET TAGS ('dbx_business_glossary_term' = 'Optional Line Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ALTER COLUMN `line_description` SET TAGS ('dbx_business_glossary_term' = 'Line Item Description');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ALTER COLUMN `line_status` SET TAGS ('dbx_business_glossary_term' = 'Line Item Status');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ALTER COLUMN `line_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|rejected|negotiating|superseded');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ALTER COLUMN `overhead_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Overhead Rate Percentage');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ALTER COLUMN `overhead_rate_pct` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ALTER COLUMN `region` SET TAGS ('dbx_business_glossary_term' = 'Geographic Region');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ALTER COLUMN `resource_type` SET TAGS ('dbx_value_regex' = 'internal_staff|subcontractor|technology|facility|third_party_vendor');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ALTER COLUMN `sponsor_approved` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Approved Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ALTER COLUMN `study_phase` SET TAGS ('dbx_value_regex' = 'Phase_I|Phase_II|Phase_III|Phase_IV|Phase_I/II');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ALTER COLUMN `subcontractor_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ALTER COLUMN `total_line_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'Unit of Measure (UOM)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ALTER COLUMN `unit_price` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`proposal_line` ALTER COLUMN `wbs_element` SET TAGS ('dbx_business_glossary_term' = 'Work Breakdown Structure (WBS) Element');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ADD CONSTRAINT `fk_sponsor_escalation_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ADD CONSTRAINT `fk_sponsor_escalation_cro_owner_employee_id` FOREIGN KEY (`cro_owner_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ADD CONSTRAINT `fk_sponsor_escalation_disposition_id` FOREIGN KEY (`disposition_id`) REFERENCES `clinical_trials_ecm`.`subject`.`disposition`(`disposition_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ADD CONSTRAINT `fk_sponsor_escalation_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ADD CONSTRAINT `fk_sponsor_escalation_organization_contact_id` FOREIGN KEY (`organization_contact_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization_contact`(`organization_contact_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ADD CONSTRAINT `fk_sponsor_escalation_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ADD CONSTRAINT `fk_sponsor_escalation_parent_escalation_id` FOREIGN KEY (`parent_escalation_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`escalation`(`escalation_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ADD CONSTRAINT `fk_sponsor_escalation_regulatory_correspondence_id` FOREIGN KEY (`regulatory_correspondence_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`correspondence`(`correspondence_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ADD CONSTRAINT `fk_sponsor_escalation_regulatory_inspection_id` FOREIGN KEY (`regulatory_inspection_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`regulatory_inspection`(`regulatory_inspection_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ADD CONSTRAINT `fk_sponsor_escalation_service_level_agreement_id` FOREIGN KEY (`service_level_agreement_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`service_level_agreement`(`service_level_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ADD CONSTRAINT `fk_sponsor_escalation_sponsor_engagement_id` FOREIGN KEY (`sponsor_engagement_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`sponsor_engagement`(`sponsor_engagement_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ADD CONSTRAINT `fk_sponsor_escalation_study_contract_id` FOREIGN KEY (`study_contract_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`study_contract`(`study_contract_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ADD CONSTRAINT `fk_sponsor_escalation_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ADD CONSTRAINT `fk_sponsor_escalation_subject_deviation_id` FOREIGN KEY (`subject_deviation_id`) REFERENCES `clinical_trials_ecm`.`subject`.`subject_deviation`(`subject_deviation_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ADD CONSTRAINT `fk_sponsor_escalation_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ADD CONSTRAINT `fk_sponsor_escalation_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` SET TAGS ('dbx_domain' = 'sponsor');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` SET TAGS ('dbx_subdomain' = 'relationship_governance');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` SET TAGS ('dbx_v2_expansion' = 'additive');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` SET TAGS ('dbx_v1_preserve' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Program Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `cro_owner_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Cro Owner Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `cro_owner_employee_id` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `cro_owner_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `disposition_id` SET TAGS ('dbx_business_glossary_term' = 'Disposition Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Contact Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Organization ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `regulatory_correspondence_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Correspondence Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `regulatory_inspection_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Inspection Readiness Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `service_level_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Engagement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `study_contract_id` SET TAGS ('dbx_business_glossary_term' = 'Study Contract Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `subject_deviation_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Deviation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Trial Subject Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `acknowledged_date` SET TAGS ('dbx_business_glossary_term' = 'Escalation Acknowledged Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `capa_reference` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Reference');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `channel` SET TAGS ('dbx_business_glossary_term' = 'Escalation Channel');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `channel` SET TAGS ('dbx_value_regex' = 'ctms|email|governance_meeting|phone|written_notice|audit_finding');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `closed_by` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `closed_by` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `closed_by` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `closure_date` SET TAGS ('dbx_business_glossary_term' = 'Escalation Closure Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `ctms_escalation_ref` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Escalation Reference');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `financial_impact_usd` SET TAGS ('dbx_business_glossary_term' = 'Financial Impact (USD)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `financial_impact_usd` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `governance_review_required` SET TAGS ('dbx_business_glossary_term' = 'Governance Review Required Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `irb_iec_notified` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Notified Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `is_regulatory_reportable` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reportable Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `is_safety_related` SET TAGS ('dbx_business_glossary_term' = 'Safety-Related Escalation Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Escalation Reference Number');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `number` SET TAGS ('dbx_value_regex' = '^ESC-[0-9]{4}-[0-9]{6}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `priority` SET TAGS ('dbx_business_glossary_term' = 'Escalation Priority');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `priority` SET TAGS ('dbx_value_regex' = 'immediate|urgent|standard|low');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `raised_by_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `raised_by_contact_email` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `raised_by_contact_email` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `raised_by_contact_email` SET TAGS ('dbx_pii_email' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `raised_by_contact_name` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `raised_by_contact_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `raised_by_contact_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `raised_by_org_role` SET TAGS ('dbx_business_glossary_term' = 'Raised By Organizational Role');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `severity_level` SET TAGS ('dbx_business_glossary_term' = 'Escalation Severity Level');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `severity_level` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `source` SET TAGS ('dbx_business_glossary_term' = 'Escalation Source');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `escalation_status` SET TAGS ('dbx_value_regex' = 'open|in_progress|resolved|closed');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `timeline_impact_days` SET TAGS ('dbx_business_glossary_term' = 'Timeline Impact (Days)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Escalation Title');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`escalation` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ADD CONSTRAINT `fk_sponsor_account_plan_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ADD CONSTRAINT `fk_sponsor_account_plan_master_agreement_id` FOREIGN KEY (`master_agreement_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`master_agreement`(`master_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ADD CONSTRAINT `fk_sponsor_account_plan_master_service_agreement_id` FOREIGN KEY (`master_service_agreement_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`master_service_agreement`(`master_service_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ADD CONSTRAINT `fk_sponsor_account_plan_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ADD CONSTRAINT `fk_sponsor_account_plan_preferred_provider_agreement_id` FOREIGN KEY (`preferred_provider_agreement_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement`(`preferred_provider_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ADD CONSTRAINT `fk_sponsor_account_plan_primary_account_employee_id` FOREIGN KEY (`primary_account_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ADD CONSTRAINT `fk_sponsor_account_plan_prior_plan_account_plan_id` FOREIGN KEY (`prior_plan_account_plan_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`account_plan`(`account_plan_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ADD CONSTRAINT `fk_sponsor_account_plan_sponsor_engagement_id` FOREIGN KEY (`sponsor_engagement_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`sponsor_engagement`(`sponsor_engagement_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ADD CONSTRAINT `fk_sponsor_account_plan_therapeutic_area_id` FOREIGN KEY (`therapeutic_area_id`) REFERENCES `clinical_trials_ecm`.`program`.`therapeutic_area`(`therapeutic_area_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` SET TAGS ('dbx_domain' = 'sponsor');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` SET TAGS ('dbx_subdomain' = 'commercial_operations');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` SET TAGS ('dbx_v2_expansion' = 'additive');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` SET TAGS ('dbx_v1_preserve' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Program Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `master_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Master Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `master_service_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Master Service Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Organization ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `preferred_provider_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Preferred Provider Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `primary_account_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Relationship Owner Employee ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `primary_account_employee_id` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `primary_account_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `prior_plan_account_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Prior Account Plan ID');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Engagement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `therapeutic_area_id` SET TAGS ('dbx_business_glossary_term' = 'Therapeutic Area Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `account_tier` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Account Tier');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `account_tier` SET TAGS ('dbx_value_regex' = 'strategic|preferred|standard|emerging');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `approved_date` SET TAGS ('dbx_business_glossary_term' = 'Account Plan Approved Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `biostatistics_revenue_target_usd` SET TAGS ('dbx_business_glossary_term' = 'Biostatistics Revenue Target (USD)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `biostatistics_revenue_target_usd` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `clinical_ops_revenue_target_usd` SET TAGS ('dbx_business_glossary_term' = 'Clinical Operations Revenue Target (USD)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `clinical_ops_revenue_target_usd` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `competitive_threats` SET TAGS ('dbx_business_glossary_term' = 'Competitive Threat Assessment');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `competitive_threats` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `ctms_account_plan_ref` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Account Plan Reference');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `data_management_revenue_target_usd` SET TAGS ('dbx_business_glossary_term' = 'Data Management Revenue Target (USD)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `data_management_revenue_target_usd` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `data_management_revenue_target_usd` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `governance_meeting_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual|ad_hoc');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `innovation_initiatives` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `key_sponsor_stakeholders` SET TAGS ('dbx_business_glossary_term' = 'Key Sponsor Stakeholder Summary');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `key_sponsor_stakeholders` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `key_sponsor_stakeholders` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `key_sponsor_stakeholders` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `pipeline_opportunity_count` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `pipeline_opportunity_value_usd` SET TAGS ('dbx_business_glossary_term' = 'Pipeline Opportunity Value (USD)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `pipeline_opportunity_value_usd` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `plan_code` SET TAGS ('dbx_business_glossary_term' = 'Account Plan Code');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `plan_code` SET TAGS ('dbx_value_regex' = '^AP-[A-Z0-9]{4,10}-[0-9]{4}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `plan_end_date` SET TAGS ('dbx_business_glossary_term' = 'Account Plan End Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `plan_name` SET TAGS ('dbx_business_glossary_term' = 'Account Plan Name');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `plan_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `plan_start_date` SET TAGS ('dbx_business_glossary_term' = 'Account Plan Start Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `plan_status` SET TAGS ('dbx_business_glossary_term' = 'Account Plan Status');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `plan_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|active|closed');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `plan_type` SET TAGS ('dbx_business_glossary_term' = 'Account Plan Type');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `plan_type` SET TAGS ('dbx_value_regex' = 'annual|multi_year|renewal|remediation');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `plan_version` SET TAGS ('dbx_business_glossary_term' = 'Account Plan Version Number');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `plan_year` SET TAGS ('dbx_business_glossary_term' = 'Account Plan Year');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `preferred_provider_status` SET TAGS ('dbx_value_regex' = 'preferred|approved|non_preferred|in_negotiation');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `preferred_provider_status` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `regulatory_affairs_revenue_target_usd` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Affairs Revenue Target (USD)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `regulatory_affairs_revenue_target_usd` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `relationship_development_goals` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `relationship_health_score` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Relationship Health Score');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `relationship_health_score` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `revenue_target_currency` SET TAGS ('dbx_business_glossary_term' = 'Revenue Target Currency Code');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `revenue_target_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `revenue_target_usd` SET TAGS ('dbx_business_glossary_term' = 'Total Revenue Target (USD)');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `revenue_target_usd` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `risk_summary` SET TAGS ('dbx_business_glossary_term' = 'Account Risk Summary');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `risk_summary` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `sponsor_satisfaction_score` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `strategic_objectives` SET TAGS ('dbx_business_glossary_term' = 'Strategic Account Objectives');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`account_plan` ALTER COLUMN `strategic_objectives` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_contact_assignment` ADD CONSTRAINT `fk_sponsor_engagement_contact_assignment_organization_contact_id` FOREIGN KEY (`organization_contact_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization_contact`(`organization_contact_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_contact_assignment` ADD CONSTRAINT `fk_sponsor_engagement_contact_assignment_sponsor_engagement_id` FOREIGN KEY (`sponsor_engagement_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`sponsor_engagement`(`sponsor_engagement_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_contact_assignment` ADD CONSTRAINT `fk_sponsor_engagement_contact_assignment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_contact_assignment` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_contact_assignment` SET TAGS ('dbx_domain' = 'sponsor');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_contact_assignment` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_contact_assignment` SET TAGS ('dbx_subdomain' = 'relationship_governance');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_contact_assignment` SET TAGS ('dbx_association_edges' = 'sponsor.sponsor_contact,sponsor.engagement');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_contact_assignment` SET TAGS ('dbx_v2_expansion' = 'additive');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_contact_assignment` SET TAGS ('dbx_v1_preserve' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_contact_assignment` ALTER COLUMN `engagement_contact_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Engagement Contact Assignment - Engagement Contact Assignment Id');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_contact_assignment` ALTER COLUMN `engagement_contact_assignment_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_contact_assignment` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_business_glossary_term' = 'Engagement Contact Assignment - Sponsor Contact Id');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_contact_assignment` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_contact_assignment` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Engagement Contact Assignment - Engagement Id');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_contact_assignment` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_contact_assignment` ALTER COLUMN `end_date` SET TAGS ('dbx_business_glossary_term' = 'Assignment End Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_contact_assignment` ALTER COLUMN `engagement_end_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_contact_assignment` ALTER COLUMN `engagement_start_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_contact_assignment` ALTER COLUMN `is_primary` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Flag');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_contact_assignment` ALTER COLUMN `role_in_engagement` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_contact_assignment` ALTER COLUMN `start_date` SET TAGS ('dbx_business_glossary_term' = 'Assignment Start Date');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_scope` ADD CONSTRAINT `fk_sponsor_engagement_scope_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_scope` ADD CONSTRAINT `fk_sponsor_engagement_scope_sponsor_engagement_id` FOREIGN KEY (`sponsor_engagement_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`sponsor_engagement`(`sponsor_engagement_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_scope` ADD CONSTRAINT `fk_sponsor_engagement_scope_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_scope` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_scope` SET TAGS ('dbx_domain' = 'sponsor');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_scope` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_scope` SET TAGS ('dbx_subdomain' = 'relationship_governance');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_scope` SET TAGS ('dbx_association_edges' = 'sponsor.engagement,regulatory.health_authority');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_scope` SET TAGS ('dbx_v2_expansion' = 'additive');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_scope` SET TAGS ('dbx_v1_preserve' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_scope` ALTER COLUMN `engagement_scope_id` SET TAGS ('dbx_business_glossary_term' = 'Engagement Scope - Engagement Scope Id');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_scope` ALTER COLUMN `engagement_scope_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_scope` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Engagement Scope - Health Authority Id');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_scope` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_scope` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_scope` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Engagement Scope - Engagement Id');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_scope` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_scope` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Primary HA Contact');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_scope` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_PII' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_scope` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_scope` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_scope` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_scope` ALTER COLUMN `engagement_scope_status` SET TAGS ('dbx_business_glossary_term' = 'Scope Status');

ALTER TABLE `clinical_trials_ecm`.`sponsor`.`engagement_scope` ALTER COLUMN `engagement_scope_status` SET TAGS ('dbx_pii' = 'true');
