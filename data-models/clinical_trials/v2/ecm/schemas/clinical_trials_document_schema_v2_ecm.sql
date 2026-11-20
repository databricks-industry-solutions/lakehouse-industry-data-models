-- Schema for Domain: document | Business: Clinical_Trials | Version: v2_ecm
-- Generated on: 2026-11-20 10:02:58

CREATE DATABASE IF NOT EXISTS `clinical_trials_ecm`.`document` COMMENT 'SSOT for Trial Master File (TMF/eTMF) essential documents, SOP library, regulatory binders, site files, controlled document versioning, document workflows, DIA TMF Reference Model compliance, inspection readiness, and archival per ICH GCP requirements.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`document`.`tmf_document` (
    `tmf_document_id` BIGINT COMMENT 'Unique surrogate identifier for each logical TMF document record in the Silver Layer lakehouse. This is the primary key for the tmf_document entity. Role: MASTER_RESOURCE.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: TMF document approval is a GCP-critical activity — the approving employees qualifications and authority must be verifiable at inspection.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) to which this TMF document belongs. A TMF is organized per study per ICH GCP requirements.',
    `tmf_artifact_id` BIGINT COMMENT 'Foreign key linking to document.tmf_artifact. Business justification: Every TMF document is classified under a specific DIA TMF Reference Model artifact. The tmf_artifact STRING column in tmf_document is a denormalized reference to the tmf_artifact',
    `approval_date` DATE COMMENT 'The date on which the document was formally approved by the authorized approver(s) within the document control workflow in Veeva Vault. Distinct from the effective date and the version date.',
    `archive_date` DATE COMMENT 'The date on which this document was formally transferred to the long-term archive. Null if the document has not yet been archived.',
    `archive_location` STRING COMMENT 'The physical or electronic location identifier where the archived document is stored (e.g., archive facility name, vault path, or storage reference code). Required for document retrieval during regulatory inspections.',
    `comments` STRING COMMENT 'Free-text field for operational notes, filing instructions, quality review findings, or other contextual remarks associated with this document record. Not part of the document content itself.',
    `confidentiality_classification` STRING COMMENT 'Data classification level assigned to this document per the organizations information security policy. Restricted = highest sensitivity (e.g., patient data, proprietary formulations); Confidential = sponsor/CRO sensitive; Internal = internal use only. Valid values are `restricted|confidential|internal|public`',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 three-letter country code indicating the country for which this document is applicable (e.g., USA, GBR, JPN). Relevant for country-specific regulatory submissions, IRB/IEC approvals, and site-level documents.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this TMF document record was first created in the source system (Veeva Vault). Represents the audit trail creation event per 21 CFR Part 11 and ALCOA+ requirements.',
    `tmf_document_description` STRING COMMENT 'Free-text narrative description of the documents content, purpose, or scope. Provides additional context beyond the document title for search, classification, and review purposes.',
    `document_number` STRING COMMENT 'The externally-known, human-readable unique document identifier assigned within the eTMF or document control system (e.g., DOC-2024-00123). Used for cross-referencing in regulatory submissions and inspections.',
    `document_origin` STRING COMMENT 'Identifies the originating party or organization type that produced this document (e.g., Sponsor, CRO, Site, Regulatory Authority, Laboratory, Vendor). Used for document provenance tracking and TMF completeness analysis.',
    `document_type` STRING COMMENT 'The functional category of the document as defined by the DIA TMF Reference Model artifact taxonomy (e.g., Protocol, Informed Consent Form, Investigator Brochure, Site Initiation Visit Report, SAE Report).',
    `effective_date` DATE COMMENT 'The date from which this document version is considered operative and binding for the study. For regulatory documents, this is the date the document enters force (e.g., protocol amendment effective date, IB effective date).',
    `expiry_date` DATE COMMENT 'The date on which this document expires or is no longer valid (e.g., IRB/IEC approval expiry, laboratory accreditation certificate expiry, financial disclosure expiry). Null for documents with no defined expiry.',
    `file_format` STRING COMMENT 'The electronic file format of the document (e.g., PDF, DOCX, XLSX, XML). PDF is the standard for finalized TMF documents per eCTD and regulatory submission requirements.',
    `filing_status` STRING COMMENT 'Indicates the current filing completeness status of this document against its expected TMF artifact placeholder. Expected = document is anticipated but not yet received; Filed = document has been received and filed; Overdue = document is past its expected. Valid values are `expected|filed|overdue|not_applicable|placeholder`',
    `is_archived` BOOLEAN COMMENT 'Indicates whether this document has been formally transferred to long-term archival storage per the study close-out and archival process. Archived documents are read-only and subject to retention period controls.',
    `is_essential_document` BOOLEAN COMMENT 'Indicates whether this document is classified as an essential document per ICH E6(R2) GCP Section 8 (Trial Master File). Essential documents are those that individually and collectively permit evaluation of the conduct of a trial and the quality of the',
    `is_gcp_required` BOOLEAN COMMENT 'Indicates whether this document is mandated by ICH GCP guidelines as a required TMF document. Used for TMF completeness assessment and inspection readiness reporting.',
    `is_inspection_ready` BOOLEAN COMMENT 'Indicates whether this document has been reviewed and confirmed as inspection-ready (complete, legible, attributable, and filed correctly per ALCOA+ principles). Used for regulatory inspection readiness dashboards.',
    `language_code` STRING COMMENT 'ISO 639-1 two-letter language code (optionally with ISO 3166-1 country subtag) indicating the language in which the document is written (e.g., en, fr, de, ja, zh-CN). Required for multi-country studies with translated documents.. Valid values are `^[a-z]{2}(-[A-Z]{2})?$`',
    `lifecycle_status` STRING COMMENT 'Current state of the document within its controlled lifecycle as managed in Veeva Vault. Drives document control workflows: draft → in_review → approved → effective → superseded/archived.',
    `page_count` BIGINT COMMENT 'The total number of pages in the document. Used for document completeness verification, quality control checks, and archival metadata.',
    `quality_review_date` DATE COMMENT 'The date on which the most recent quality control review of this document was completed. Used for tracking QC cycle times and scheduling periodic re-reviews.',
    `quality_review_status` STRING COMMENT 'The outcome of the quality control review performed on this document to verify completeness, accuracy, and compliance with ALCOA+ principles and GCP requirements. Drives inspection readiness and CAPA workflows.. Valid values are `not_reviewed|in_review|passed|failed|waived`',
    `quality_reviewer` STRING COMMENT 'Name or user identifier of the individual who performed the most recent quality control review of this document. Supports audit trail requirements under GCP and 21 CFR Part 11.',
    `retention_end_date` DATE COMMENT 'The calculated date on which the mandatory retention period for this document expires, after which the document may be eligible for destruction per the approved destruction authorization process.',
    `retention_period_years` BIGINT COMMENT 'The mandatory retention period in years for this document as required by applicable regulations and sponsor policy (e.g., 15 years post-study completion per ICH E6(R2), or as specified by the sponsor).',
    `sponsor_document_reference` STRING COMMENT 'The sponsors own document reference number or identifier for this document, as assigned by the pharmaceutical or biotech sponsor. Used for cross-referencing between CRO eTMF and sponsor document management systems.',
    `title` STRING COMMENT 'The full descriptive title of the TMF document as it appears in the eTMF system (e.g., Protocol Amendment 2 - Study XYZ-001). Primary human-readable identifier for the document.',
    `tmf_section` STRING COMMENT 'The DIA TMF Reference Model Section code within the assigned Zone (e.g., 01.01, 03.02). Provides the second level of the TMF hierarchical classification for document filing and retrieval.',
    `tmf_zone` STRING COMMENT 'The DIA TMF Reference Model Zone classification for this document. Zone 01 = Trial Management; Zone 02 = Central Trial Documents; Zone 03 = Regulatory; Zone 04 = IRB/IEC and Other Approvals; Zone 05 = Site Management; Zone 06 = IP and Trial Supplies.. Valid values are `01|02|03|04|05|06`',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this TMF document record was most recently modified in the source system. Supports change detection, incremental ETL processing, and audit trail completeness.',
    `vault_document_reference` STRING COMMENT 'The native document identifier assigned by Veeva Vault (eTMF system of record). Used to trace the Silver Layer record back to its source system object for reconciliation and lineage purposes.',
    `vault_library` STRING COMMENT 'The Veeva Vault library or vault name where this document is stored (e.g., eTMF Vault, RIM Vault, QMS Vault). Relevant for organizations using multiple Vault instances across eTMF, regulatory, and quality domains.',
    `version_date` DATE COMMENT 'The date on which the current version of the document was authored or formally dated, as stated on the document itself. Distinct from the approval date or effective date.',
    `version_number` STRING COMMENT 'The current approved version label of this logical document (e.g., 1.0, 2.1, 3.0). Represents the version of the document as a business entity; full version history is tracked in the document_version product.. Valid values are `^[0-9]+.[0-9]+(.[0-9]+)?$`',
    CONSTRAINT pk_tmf_document PRIMARY KEY(`tmf_document_id`)
) COMMENT 'Core master entity representing an essential document within the Trial Master File (TMF/eTMF) as defined by the DIA TMF Reference Model. Captures document identity, TMF zone/section/artifact classification, title, version, lifecycle status (draft';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` (
    `tmf_artifact_id` BIGINT COMMENT 'Unique surrogate identifier for each TMF artifact taxonomy record in the DIA TMF Reference Model. This is the primary key for the tmf_artifact reference entity.',
    `applicability_phase` STRING COMMENT 'Clinical trial phase(s) for which this artifact is applicable per the DIA TMF Reference Model (e.g., Phase I, Phase II, Phase III, Phase IV, All Phases, Phase I/II). Enables phase-specific TMF completeness assessments and filing guidance.',
    `archival_trigger` STRING COMMENT 'The regulatory or business event that triggers the start of the retention period countdown for this artifact type (e.g., Database Lock, Marketing Authorization Approval, Study Termination, Last Patient Last Visit).',
    `artifact_abbreviation` STRING COMMENT 'Short-form abbreviation or acronym for the artifact type as used in the DIA TMF Reference Model and industry practice (e.g., IB for Investigator Brochure, ICF for Informed Consent Form, the source system for Statistical Analysis Plan).',
    `artifact_code` STRING COMMENT 'Standardized DIA TMF Reference Model artifact code in Zone.Section.Artifact format (e.g., 01.01.01 for Zone 1, Section 1, Artifact 1 — Protocol). Serves as the externally-recognized business identifier for the artifact type across sponsors, CROs, and. Valid values are `^[0-9]{2}.[0-9]{2}.[0-9]{2}$`',
    `artifact_description` STRING COMMENT 'Detailed narrative description of the artifact type, its purpose within the TMF, and the business context in which it is generated or collected. Provides filing guidance to Clinical Research Associates (CRAs), Clinical Research Coordinators (CRCs), and',
    `artifact_name` STRING COMMENT 'Official DIA TMF Reference Model name for the artifact type (e.g., Protocol, Investigator Brochure, Informed Consent Form). This is the human-readable identity label used in TMF completeness reports, inspection readiness dashboards, and eTMF system',
    `artifact_number` BIGINT COMMENT 'Sequential numeric identifier of the artifact within its section per the DIA TMF Reference Model (e.g., Artifact 01 within Section 1.1). Provides the third and most granular level of the TMF hierarchy.',
    `artifact_status` STRING COMMENT 'Current lifecycle status of this artifact taxonomy record within the DIA TMF Reference Model (Active = currently in use, Deprecated = removed from the model, Superseded = replaced by a newer artifact definition, Draft = under review for inclusion).. Valid values are `Active|Deprecated|Superseded|Draft`',
    `cdisc_controlled_term` STRING COMMENT 'CDISC Controlled Terminology value for the TMF artifact; implements CDISC CT codelist reference.',
    `completeness_weight` DECIMAL(5,2) COMMENT 'Numeric weight assigned to this artifact type for TMF completeness index calculation (expressed as a percentage or score contribution). Required artifacts typically carry higher weights than Recommended or Optional.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this artifact taxonomy record was first created in the data platform. Provides the audit trail creation timestamp per ALCOA+ principles and supports data lineage tracking for the TMF reference taxonomy.',
    `dia_reference_model_version` STRING COMMENT 'Version of the DIA TMF Reference Model from which this artifact definition is sourced (e.g., v3.2, v3.1). Enables version-controlled TMF taxonomy management and supports migration assessments when the DIA releases updated Reference Model versions.',
    `document_owner_role` STRING COMMENT 'Standard organizational role responsible for generating, maintaining, and filing documents of this artifact type (e.g., Sponsor, Principal Investigator, CRA, CRC, Biostatistician, Regulatory Affairs).',
    `effective_date` DATE COMMENT 'The date from which this artifact definition became effective and applicable for use in TMF filing and completeness assessments. Aligns with the release date of the DIA TMF Reference Model version referenced by dia_reference_model_version.',
    `expected_timing` STRING COMMENT 'Describes the expected timing for filing this artifact relative to trial milestones (e.g., Before First Patient First Visit, Within 30 days of site initiation, At study close-out, Ongoing throughout trial).',
    `filing_guidance` STRING COMMENT 'Operational instructions for TMF staff on how, when, and where to file documents of this artifact type within the eTMF system (Veeva Vault). Includes guidance on acceptable document formats, naming conventions, version control expectations, and timing',
    `ich_gcp_reference` STRING COMMENT 'Specific ICH E6(R2) GCP guideline section(s) that mandate or reference this artifact type (e.g., ICH E6(R2) Section 8.2.1, ICH E6(R2) Section 8.3.6). Provides the regulatory basis for the artifacts required status and supports inspection readiness',
    `is_country_specific` BOOLEAN COMMENT 'Indicates whether this artifact type requires a separate instance per country in which the trial is conducted (True) or is filed at the global trial level (False).',
    `is_essential_document` BOOLEAN COMMENT 'Indicates whether this artifact type is classified as an Essential Document per ICH E6(R2) Section 8 (True). Essential documents are those that individually and collectively permit evaluation of the conduct of a trial and the quality of the data produced.',
    `is_inspection_critical` BOOLEAN COMMENT 'Indicates whether this artifact type is considered critical during regulatory inspections by FDA, EMA, MHRA, PMDA, or other health authorities (True). Inspection-critical artifacts are prioritized in pre-inspection TMF readiness reviews and gap',
    `is_investigator_held` BOOLEAN COMMENT 'Indicates whether this artifact type is held in the Investigator Site File (ISF) at the investigational site (True). Supports site file completeness assessments during monitoring visits (SDV/SIV/COV) and regulatory inspections.',
    `is_site_specific` BOOLEAN COMMENT 'Indicates whether this artifact type requires a separate instance per investigational site (True) or is filed once at the trial or country level (False). Drives the expected document count calculation in TMF completeness metrics — site-specific artifacts',
    `is_sponsor_held` BOOLEAN COMMENT 'Indicates whether this artifact type is held in the Sponsors TMF (True) as opposed to the Investigator Site File (ISF) or a shared location. Supports TMF structure design, responsibility allocation between sponsor and investigator, and completeness',
    `notes` STRING COMMENT 'Free-text field for additional clarifications, implementation guidance, or sponsor-specific customizations applied to this artifact definition. May include notes on jurisdictional variations, therapeutic area-specific applicability, or deviations from the',
    `regulatory_reference` STRING COMMENT 'Additional regulatory citations beyond ICH GCP that reference or mandate this artifact type, including FDA 21 CFR Part 312, EU CTR 536/2014, EMA GCP Guideline, MHRA GCP Guidance, or PMDA requirements.',
    `requirement_classification` STRING COMMENT 'DIA TMF Reference Model classification indicating whether this artifact is Required (mandatory per ICH GCP), Recommended (best practice), or Optional (situational) for a compliant TMF.. Valid values are `Required|Recommended|Optional`',
    `requires_electronic_signature` BOOLEAN COMMENT 'Indicates whether documents of this artifact type require a compliant electronic signature per 21 CFR Part 11 or EU eIDAS standards (True). Drives e-signature workflow configuration in Veeva Vault eTMF and ensures compliance with electronic records and',
    `requires_wet_signature` BOOLEAN COMMENT 'Indicates whether documents of this artifact type require a handwritten (wet) signature as opposed to an electronic signature (True). Relevant for jurisdictions or document types where electronic signatures are not accepted.',
    `retention_period_years` BIGINT COMMENT 'Minimum regulatory retention period in years for documents of this artifact type after trial completion or product approval/discontinuation. Drives archival scheduling and destruction authorization workflows.',
    `retirement_date` DATE COMMENT 'The date on which this artifact definition was retired, deprecated, or superseded and is no longer applicable for new TMF filings. Null for currently active artifact definitions.',
    `section_name` STRING COMMENT 'Descriptive name of the TMF section within its zone per the DIA TMF Reference Model (e.g., Trial Oversight, Central Monitoring, Protocol and Amendments). Used in TMF index navigation, filing guidance, and inspection readiness dashboards.',
    `section_number` STRING COMMENT 'Numeric section identifier within the TMF zone per the DIA TMF Reference Model (e.g., 1.1 for Trial Management — Trial Oversight). Provides the second level of the three-tier TMF hierarchy (Zone > Section > Artifact) used for document filing and. Valid values are `^[0-9]{1,2}.[0-9]{1,2}$`',
    `superseded_by_code` STRING COMMENT 'The artifact_code of the newer artifact definition that supersedes this record when artifact_status is Superseded. Enables forward navigation in the artifact taxonomy version history and supports TMF system migration mapping when DIA Reference Model. Valid values are `^[0-9]{2}.[0-9]{2}.[0-9]{2}$`',
    `tmf_level` STRING COMMENT 'Indicates the organizational level at which this artifact is filed within the TMF structure: Trial-level (applies to the entire study), Country-level (applies to a specific country), or Site-level (applies to an individual investigational site).. Valid values are `Trial|Country|Site`',
    `trial_phase_end` STRING COMMENT 'The trial lifecycle phase by which this artifact should be finalized and filed (Pre-Trial, Start-Up, Conduct, Close-Out, Post-Trial). Defines the closing boundary of the filing window for this artifact type and supports overdue document identification in. Valid values are `Pre-Trial|Start-Up|Conduct|Close-Out|Post-Trial`',
    `trial_phase_start` STRING COMMENT 'The trial lifecycle phase during which this artifact is first expected to be filed (Pre-Trial, Start-Up, Conduct, Close-Out, Post-Trial). Used in conjunction with trial_phase_end to define the filing window for this artifact type and to drive. Valid values are `Pre-Trial|Start-Up|Conduct|Close-Out|Post-Trial`',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time when this artifact taxonomy record was last modified in the data platform. Supports change tracking, audit trail requirements, and incremental data pipeline processing for the TMF reference taxonomy. Required for ALCOA+ compliance.',
    `veeva_vault_document_subtype` STRING COMMENT 'The corresponding document subtype classification as configured in Veeva Vault eTMF. Provides the second level of the Veeva Vault document type hierarchy, enabling precise mapping from DIA TMF Reference Model artifacts to the eTMF systems document',
    `veeva_vault_document_type` STRING COMMENT 'The corresponding document type classification as configured in Veeva Vault eTMF, the operational system of record for TMF management. Enables direct mapping between the DIA TMF Reference Model taxonomy and the Veeva Vault document type hierarchy for',
    `zone_name` STRING COMMENT 'Descriptive name of the TMF zone as defined in the DIA TMF Reference Model (e.g., Trial Management, Central Trial Documents, Regulatory, IRB/IEC and Other Approvals, Site Management, Investigational Product, Safety Reporting).',
    `zone_number` BIGINT COMMENT 'Numeric identifier of the TMF zone to which this artifact belongs per the DIA TMF Reference Model (e.g., Zone 1 = Trial Management, Zone 2 = Central Trial Documents, Zone 3 = Regulatory, Zone 4 = IRB/IEC and Other Approvals, Zone 5 = Site Management, Zone',
    CONSTRAINT pk_tmf_artifact PRIMARY KEY(`tmf_artifact_id`)
) COMMENT 'Reference entity defining the DIA TMF Reference Model artifact taxonomy — the standardized classification of document types by Zone, Section, and Artifact number (e.g., Zone 1 Section 1.1 Artifact 01 - Protocol).';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`document`.`version` (
    `version_id` BIGINT COMMENT 'Unique surrogate identifier for each discrete version record of a controlled document in the Trial Master File (TMF) or Standard Operating Procedure (SOP) library. Primary key of this table.',
    `approver_employee_id` BIGINT COMMENT 'Reference to the the source system record of the individual who approved this document version. Supports electronic signature traceability per 21 CFR Part 11.',
    `controlled_terminology_codelist_id` BIGINT COMMENT 'Optional CDISC CT codelist governing categorical values on this record.',
    `primary_version_author_employee_id` BIGINT COMMENT 'Reference to the the source system record of the individual who authored this document version. Enables workforce analytics and training compliance linkage.',
    `tmf_document_id` BIGINT COMMENT 'Reference to the parent document record for which this version was created. All versions of the same document share this identifier, enabling full version lineage reconstruction.',
    `approved_date` DATE COMMENT 'The date on which this document version received final approval and was authorized for use. Null if the version has not yet been approved. Supports 21 CFR Part 11 and EU CTR audit trail requirements.',
    `approver_name` STRING COMMENT 'Full name of the individual who granted final approval for this document version. Required for 21 CFR Part 11 electronic signature audit trail and GCP inspection readiness.',
    `archival_status` STRING COMMENT 'The archival lifecycle state of this document version. active = in current use; archived = moved to long-term archival storage per ICH GCP retention requirements; pending_archival = scheduled for archival; destroyed = permanently deleted per. Valid values are `active|archived|pending_archival|destroyed`',
    `author_name` STRING COMMENT 'Full name of the individual who authored this document version. Captured as part of the ALCOA+ attributable audit trail. Typically a CRA, CRC, Regulatory Affairs specialist, or Biostatistician depending on document type.',
    `authored_date` DATE COMMENT 'The date on which authorship of this document version was completed and the document was submitted for review. Part of the ALCOA+ audit trail for controlled document lifecycle.',
    `capa_reference` STRING COMMENT 'The CAPA identifier from MasterControl that triggered or is associated with this document version update. Null if the version was not CAPA-driven. Enables traceability between quality events and document changes.',
    `change_reason` STRING COMMENT 'The documented business or regulatory reason that triggered the creation of this new version (e.g., protocol amendment, regulatory agency feedback, CAPA-driven update, periodic review). Supports change control traceability.',
    `change_summary` STRING COMMENT 'A concise narrative description of the changes made in this version relative to the immediately preceding version. Required for controlled document change control and regulatory inspection readiness.',
    `change_type` STRING COMMENT 'Classification of the nature of changes in this version. major = substantive content changes requiring re-training; minor = non-substantive content updates; administrative = formatting, typo, or metadata corrections only; initial = first version. Valid values are `major|minor|administrative|initial`',
    `checksum_hash` STRING COMMENT 'The SHA-256 cryptographic hash of the document file content at the time of this versions creation. Used to verify document integrity and detect unauthorized alterations, supporting 21 CFR Part 11 audit trail and ALCOA+ integrity requirements.. Valid values are `^[a-fA-F0-9]{64}$`',
    `confidentiality_level` STRING COMMENT 'The data classification level assigned to this document version, governing access controls and distribution restrictions within Veeva Vault. Aligns with the organizations data classification policy and GDPR/HIPAA requirements.. Valid values are `public|internal|confidential|restricted`',
    `country_code` STRING COMMENT 'The ISO 3166-1 alpha-3 country code indicating the regulatory jurisdiction for which this document version was prepared or filed (e.g., USA, GBR, DEU, JPN). Null for globally applicable documents.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this document version record was first created in the source system (Veeva Vault). Part of the ALCOA+ contemporaneous audit trail. Stored in ISO 8601 format with timezone offset.',
    `document_number` STRING COMMENT 'The externally-known controlled document number or identifier (e.g., SOP-CLN-0042, TMF-PROT-001). Serves as the business-facing identifier used in regulatory submissions, audit trails, and cross-references within the Trial Master File.',
    `document_title` STRING COMMENT 'The full official title of the document as it appears on the controlled document itself. Used for display, search, and regulatory binder indexing within the eTMF.',
    `document_type` STRING COMMENT 'Classification of the document by its functional type within the TMF or SOP library (e.g., Protocol, Informed Consent Form, Investigator Brochure, SOP, Regulatory Submission, Site Agreement, Safety Report).',
    `effective_date` DATE COMMENT 'The date on which this document version becomes officially effective and binding for use. For SOPs, this is the date from which staff must comply with the procedure. For regulatory documents, this is the date of regulatory approval or acknowledgement.',
    `expiry_date` DATE COMMENT 'The date on which this document version expires and must be reviewed, renewed, or superseded. Null indicates no scheduled expiry. Critical for SOP periodic review cycles and regulatory document validity tracking.',
    `file_format` STRING COMMENT 'The electronic file format of the document version as stored in Veeva Vault (e.g., PDF, DOCX, XLSX, XML). PDF is the standard for approved controlled documents per eCTD and 21 CFR Part 11 requirements.',
    `file_size_kb` BIGINT COMMENT 'The size of the document version file in kilobytes as stored in Veeva Vault. Used for storage management, eTMF completeness validation, and detecting potentially corrupt or empty document uploads.',
    `inspection_readiness_status` STRING COMMENT 'Assessment of whether this document version is ready for regulatory inspection. ready = document is complete, approved, and filed correctly; gap_identified = a filing or completeness gap has been identified; remediation_in_progress = gap is being. Valid values are `ready|gap_identified|remediation_in_progress|not_applicable`',
    `language_code` STRING COMMENT 'The ISO 639-1 language code of the document version (e.g., en, fr, de, ja). Critical for multi-country trials where documents must be translated and filed in local languages per regulatory requirements.. Valid values are `^[a-z]{2}(-[A-Z]{2})?$`',
    `last_modified_timestamp` TIMESTAMP COMMENT 'The timestamp of the most recent modification to this document version record in the source system. Supports audit trail completeness and change detection in the Silver Layer ETL pipeline.',
    `number` STRING COMMENT 'The human-readable version label for this document version (e.g., 1.0, 2.1, 3.0). Follows the organizations controlled document versioning convention. Major increments typically indicate substantive content changes; minor increments indicate. Valid values are `^[0-9]+.[0-9]+(.[0-9]+)?$`',
    `regulatory_authority` STRING COMMENT 'The regulatory authority to which this document version is relevant or was submitted (e.g., FDA, EMA, PMDA, MHRA, TGA, Health Canada). Supports regulatory submission tracking and jurisdiction-specific compliance reporting.',
    `retention_expiry_date` DATE COMMENT 'The date after which this document version may be destroyed per the applicable regulatory retention schedule. Calculated based on study completion date plus the required retention period (e.g., 15 years post-study for ICH GCP, 2 years post-NDA approval',
    `reviewer_name` STRING COMMENT 'Full name of the quality reviewer or subject matter expert who reviewed this document version prior to approval. Supports the QA review step in the controlled document workflow.',
    `version_status` STRING COMMENT 'Current lifecycle state of this document version within the controlled document workflow. draft = under authorship; in_review = circulated for review/approval; approved = effective and in use; superseded = replaced by a newer approved version. Valid values are `draft|in_review|approved|superseded|obsolete|withdrawn`',
    `study_protocol_number` STRING COMMENT 'The sponsor-assigned protocol number of the clinical study to which this document version is associated, if applicable. Null for enterprise-level SOPs not tied to a specific study. Enables study-level TMF completeness reporting.',
    `superseded_date` DATE COMMENT 'The date on which this document version was superseded by a newer approved version. Null if the version is still current or was never approved. Used to determine the active version at any point in time for historical audit queries.',
    `tmf_section` STRING COMMENT 'The specific section or artifact number within the DIA TMF Reference Model zone (e.g., 01.01, 02.03, 05.07). Used for precise eTMF filing, completeness tracking, and inspection readiness reporting.',
    `tmf_zone` STRING COMMENT 'The DIA TMF Reference Model zone to which this document belongs. Zone 1 = Trial Management; Zone 2 = Central Trial Documents; Zone 3 = Regulatory; Zone 4 = Investigational Product; Zone 5 = Site Management.. Valid values are `zone_1|zone_2|zone_3|zone_4|zone_5`',
    `training_completion_deadline` DATE COMMENT 'The date by which all required staff must complete training on this document version. Null if training is not required. Used to monitor training compliance and flag overdue training in MasterControl.',
    `training_required` BOOLEAN COMMENT 'Indicates whether staff training is required upon approval of this document version. True for major version changes to SOPs and GCP-critical documents. Drives training assignment workflows in MasterControl.',
    `vault_document_version_reference` STRING COMMENT 'The native document version identifier assigned by Veeva Vault (eTMF/QMS module). Used to trace this Silver Layer record back to its source system record for reconciliation and audit purposes.',
    `vault_lifecycle_state` STRING COMMENT 'The native lifecycle state label as recorded in Veeva Vault for this document version (e.g., Draft, In Review, Approved, Superseded). Preserved from the source system to enable reconciliation between the Silver Layer and Veeva Vault.',
    CONSTRAINT pk_version PRIMARY KEY(`version_id`)
) COMMENT 'Tracks the full version history of every controlled document in the TMF and SOP library. Each record represents a discrete version of a document, capturing version number, effective date, expiry date, version status (draft, in-review, approved';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`document`.`document_sop` (
    `document_sop_id` BIGINT COMMENT 'Unique surrogate identifier for each SOP record in the controlled document library. Primary key for the document_sop entity. Role: MASTER_RESOURCE.',
    `owning_org_unit_id` BIGINT COMMENT 'Foreign key linking to workforce.org_unit. Business justification: SOP organizational ownership determines training scope, distribution lists, and CAPA routing in clinical operations.',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — SOPs may be study-specific',
    `therapeutic_area_id` BIGINT COMMENT 'Foreign key linking to program.therapeutic_area. Business justification: SOPs in clinical research are frequently scoped to therapeutic areas (e.g., oncology-specific safety reporting SOPs, CNS-specific consent procedures).',
    `training_curriculum_id` BIGINT COMMENT 'Foreign key linking to workforce.training_curriculum. Business justification: Each SOP is governed by a training curriculum that determines who must be trained and at what frequency — a core GCP compliance process.',
    `applicable_region` STRING COMMENT 'Geographic region(s) or jurisdiction(s) for which this SOP is applicable (e.g., USA, EU, GLOBAL, JPN). Supports multi-regional regulatory compliance and site-level applicability determination.',
    `approval_date` DATE COMMENT 'Date on which the SOP version received final authorized approval from the designated approver(s) in the document management workflow. Distinct from effective date; approval may precede effectivity.',
    `approver` STRING COMMENT 'Name or employee identifier of the authorized individual who provided final approval for the current SOP version. Required for 21 CFR Part 11 electronic signature compliance.',
    `author` STRING COMMENT 'Name or employee identifier of the individual who drafted or last revised the SOP content. Supports ALCOA+ attributability requirements for controlled documents.',
    `capa_reference` STRING COMMENT 'Reference number of the CAPA that triggered the creation or revision of this SOP, if applicable. Links document changes to quality events and supports CAPA effectiveness verification.',
    `change_summary` STRING COMMENT 'Narrative summary of the key changes made in this version compared to the previous version. Supports change control documentation and enables reviewers to quickly identify what was modified.',
    `confidentiality_level` STRING COMMENT 'Data classification level assigned to the SOP document indicating its sensitivity and access control requirements (e.g., internal, confidential). Governs who may access, distribute, or reference the document.. Valid values are `public|internal|confidential|restricted`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the SOP record was first created in the controlled document management system (MasterControl). Supports ALCOA+ audit trail requirements for contemporaneous documentation.',
    `deviation_triggered` BOOLEAN COMMENT 'Indicates whether this SOP version was created or revised as a direct result of a protocol deviation or quality event. When True, the capa_reference field should be populated. Supports quality trend analysis.',
    `document_format` STRING COMMENT 'File format of the controlled SOP document as stored in MasterControl (e.g., pdf, word). PDF is the standard format for approved/effective SOPs to prevent unauthorized modification per 21 CFR Part 11.. Valid values are `pdf|word|excel|html|xml`',
    `document_location_url` STRING COMMENT 'URL or system path to the controlled SOP document in MasterControl or the designated document management repository. Enables direct navigation to the source document for review and compliance verification.',
    `effective_date` DATE COMMENT 'Date on which the current approved version of the SOP becomes mandatory for use across the organization. Staff must comply with this version from this date forward. Aligns with EFFECTIVE_FROM category.',
    `electronic_signature_required` BOOLEAN COMMENT 'Indicates whether the SOP approval and acknowledgment workflow requires electronic signatures compliant with 21 CFR Part 11. When True, all approvals and training acknowledgments must be captured as validated e-signatures.',
    `expiry_date` DATE COMMENT 'Date on which the SOP is scheduled to expire and must be reviewed, revised, or retired. Typically set at a fixed review cycle (e.g., 2–3 years from effective date). Aligns with EFFECTIVE_UNTIL category.',
    `gcp_applicable` BOOLEAN COMMENT 'Indicates whether this SOP is directly applicable to GCP-regulated clinical trial activities. When True, the SOP is subject to GCP inspection and must comply with ICH E6(R2) requirements.',
    `gdpr_applicable` BOOLEAN COMMENT 'Indicates whether this SOP governs activities subject to GDPR requirements for patient data privacy and protection. Relevant for SOPs covering data collection, consent, data transfer, and subject data management.',
    `hipaa_applicable` BOOLEAN COMMENT 'Indicates whether this SOP governs activities subject to HIPAA requirements for protected health information (PHI) in U.S.-based clinical trial operations.',
    `inspection_ready` BOOLEAN COMMENT 'Indicates whether this SOP has been verified as inspection-ready, meaning it is current, approved, accessible, and all required training records are complete. Supports regulatory inspection preparedness tracking.',
    `language` STRING COMMENT 'ISO 639-1/639-2 language code of the SOP document (e.g., en, fr, de, ja). Supports multi-language SOP libraries for global clinical trial operations across multiple regulatory jurisdictions.. Valid values are `^[a-z]{2,3}(-[A-Z]{2})?$`',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the SOP record in the document management system. Supports audit trail integrity and change tracking per 21 CFR Part 11 and ALCOA+ requirements.',
    `mastercontrol_doc_reference` STRING COMMENT 'Native document identifier assigned by MasterControl (the system of record for controlled documents). Used for cross-system traceability and integration with MasterControl training, CAPA, and audit modules.',
    `process_area` STRING COMMENT 'Specific business process area governed by this SOP within its category (e.g., Informed Consent Management, SAE Reporting, Database Lock, Site Initiation Visit). Enables granular process-level filtering and gap analysis.',
    `purpose` STRING COMMENT 'Brief narrative describing the business purpose and objective of the SOP — why it exists and what regulatory or operational requirement it fulfills. Sourced from the SOP documents purpose/objective section.',
    `regulatory_framework` STRING COMMENT 'Comma-separated list of regulatory frameworks and standards to which this SOP applies (e.g., FDA 21 CFR Part 312, ICH E6(R2), EU CTR 536/2014, GCP). Supports regulatory compliance mapping and inspection readiness.',
    `related_sop_numbers` STRING COMMENT 'Comma-separated list of SOP numbers that are related to or referenced by this SOP (e.g., parent SOPs, companion procedures, referenced work instructions). Supports document cross-referencing and impact analysis.',
    `review_cycle_months` BIGINT COMMENT 'Defined periodic review interval in months for this SOP (e.g., 24 or 36 months). Determines the frequency at which the SOP must be reviewed for continued accuracy and regulatory alignment. Drives review_due_date calculation.',
    `review_due_date` DATE COMMENT 'Scheduled date by which the SOP must undergo its next periodic review to confirm continued applicability and accuracy. Drives inspection readiness and document control compliance.',
    `scope` STRING COMMENT 'Narrative description of the scope of the SOP, defining which activities, processes, personnel, systems, or organizational units are covered. Typically drawn directly from the SOP documents scope section.',
    `sop_category` STRING COMMENT 'Functional category classifying the SOP by the business domain it governs (e.g., clinical_operations, data_management, safety). Enables domain-based filtering and reporting. Aligns with CLASSIFICATION_OR_TYPE category for MASTER_RESOURCE role.',
    `sop_number` STRING COMMENT 'Externally-known, organization-assigned unique document number for the SOP (e.g., QA-SOP-00123). Serves as the business identifier used in regulatory submissions, audit trails, and cross-references.. Valid values are `^[A-Z]{2,10}-SOP-[0-9]{3,6}$`',
    `sop_status` STRING COMMENT 'Current lifecycle state of the SOP within the controlled document management workflow. Governs whether the SOP is actionable for clinical trial operations. Aligns with LIFECYCLE_STATUS category for MASTER_RESOURCE role.',
    `sop_type` STRING COMMENT 'Type of controlled document within the quality management system hierarchy. Distinguishes SOPs from work instructions, policies, guidance documents, templates, and forms. Supports document hierarchy management.. Valid values are `sop|work_instruction|policy|guidance|template|form`',
    `superseded_sop_number` STRING COMMENT 'SOP number of the prior version or predecessor document that this SOP replaces. Enables document lineage tracing and ensures retired versions are properly cross-referenced. Null if this is the inaugural version.',
    `superseded_version_number` STRING COMMENT 'Version number of the specific SOP version that this current version supersedes. Complements superseded_sop_number to fully identify the predecessor document version.. Valid values are `^[0-9]+.[0-9]+$`',
    `title` STRING COMMENT 'Full descriptive title of the SOP as it appears on the controlled document (e.g., Adverse Event Reporting and Expedited Notification Procedure). Serves as the human-readable IDENTITY_LABEL for the MASTER_RESOURCE role.',
    `tmf_reference_model_section` STRING COMMENT 'DIA TMF Reference Model zone/section identifier to which this SOP is mapped, if applicable (e.g., 01.01 - Trial Management). Supports eTMF filing and inspection readiness alignment with the DIA TMF Reference Model.',
    `training_completion_deadline_days` BIGINT COMMENT 'Number of calendar days from the SOP effective date within which all applicable personnel must complete the required training. Drives training assignment deadlines in MasterControl.',
    `training_required` BOOLEAN COMMENT 'Indicates whether staff must complete mandatory training on this SOP before performing the governed activities. When True, a training record must be created in MasterControl for all applicable personnel. Supports GCP training compliance.',
    `version_number` STRING COMMENT 'Current approved version of the SOP in major.minor format (e.g., 3.0, 2.1). Incremented upon each approved revision cycle. Critical for ALCOA+ compliance and audit trail integrity.. Valid values are `^[0-9]+.[0-9]+$`',
    CONSTRAINT pk_document_sop PRIMARY KEY(`document_sop_id`)
) COMMENT 'Master entity for Standard Operating Procedures (SOPs) in the controlled document library (MasterControl). Each record represents one SOP with: SOP number, title, current version, effective/expiry dates, category (clinical operations, data management';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`document`.`workflow` (
    `workflow_id` BIGINT COMMENT 'Unique surrogate identifier for each document workflow instance in the Databricks Silver Layer. Primary key for the document_workflow data product.',
    `document_sop_id` BIGINT COMMENT 'Foreign key linking to document.document_sop. Business justification: SOPs undergo formal review, approval, and distribution workflows governed by the document_workflow entity.',
    `primary_workflow_employee_id` BIGINT COMMENT 'Veeva Vault user identifier of the individual currently assigned to complete the active workflow step. Required for 21 CFR Part 11 electronic signature audit trail and accountability under ALCOA+ principles.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study associated with this document workflow. Enables study-level aggregation of document control activities for inspection readiness and TMF completeness reporting.',
    `tmf_document_id` BIGINT COMMENT 'Reference to the controlled document record that this workflow instance governs. Links the workflow to the specific Trial Master File (TMF) or SOP document undergoing review, approval, or distribution.',
    `version_id` BIGINT COMMENT 'Foreign key linking to document.document_version. Business justification: Document workflows govern a specific version of a document through its review and approval lifecycle.',
    `actual_completion_date` DATE COMMENT 'Date on which the entire document workflow reached a terminal state (approved, rejected, or cancelled). Used to calculate total workflow cycle time and measure against target_completion_date for SLA performance reporting.',
    `archival_date` DATE COMMENT 'Date on which the document was formally archived in the eTMF system following workflow completion. Null until archival is executed. Used to confirm compliance with ICH GCP and regulatory retention period requirements.',
    `archival_required` BOOLEAN COMMENT 'Indicates whether the document must be archived upon workflow completion per ICH GCP retention requirements. Drives post-approval archival workflow initiation in Veeva Vault for long-term TMF retention compliance.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this document_workflow record was first created in the Databricks Silver Layer. Serves as the system audit creation timestamp for data lineage and ETL traceability.',
    `current_step_name` STRING COMMENT 'Name of the active step within the workflow at the time of record capture (e.g., Quality Review, Medical Review, Regulatory Approval, Final Sign-Off). Identifies where in the process the document currently resides.',
    `current_step_sequence` BIGINT COMMENT 'Ordinal position of the current workflow step within the overall workflow template sequence. Enables progress tracking and percentage-complete calculations across multi-step document approval processes.',
    `distribution_date` DATE COMMENT 'Date on which the approved document was distributed to all designated recipients. Populated upon completion of the distribution step. Used to confirm timely dissemination per GCP requirements.',
    `distribution_required` BOOLEAN COMMENT 'Indicates whether the approved document must be distributed to designated recipients (sites, investigators, sponsors) upon workflow completion. Triggers the distribution workflow step in Veeva Vault upon approval.',
    `document_type` STRING COMMENT 'Classification of the document being processed (e.g., Protocol, Informed Consent Form (ICF), Investigator Brochure, SOP, Regulatory Submission, Site File). Aligns with DIA TMF Reference Model artifact taxonomy.',
    `electronic_signature_required` BOOLEAN COMMENT 'Indicates whether one or more steps in this workflow require a 21 CFR Part 11 compliant electronic signature. Drives system enforcement of e-signature capture and audit trail requirements in Veeva Vault.',
    `electronic_signature_timestamp` TIMESTAMP COMMENT 'Date and time when the final binding electronic signature was applied to the document within this workflow. Required for 21 CFR Part 11 compliance. Null if electronic_signature_required is False or signature has not yet been applied.',
    `escalation_flag` BOOLEAN COMMENT 'Indicates whether this workflow instance has been formally escalated due to non-response, SLA breach, or rejection requiring management intervention. True triggers escalation notifications to supervisory roles per the workflow escalation policy.',
    `escalation_reason` STRING COMMENT 'Categorized reason for workflow escalation. Supports root cause analysis of document control bottlenecks and informs process improvement initiatives for GCP-compliant document management.. Valid values are `sla-breach|non-response|rejection-loop|resource-unavailable|other`',
    `escalation_timestamp` TIMESTAMP COMMENT 'Date and time when the workflow was formally escalated. Populated only when escalation_flag is True. Used to measure escalation response time and track resolution of escalated document control issues.',
    `gcp_critical_document_flag` BOOLEAN COMMENT 'Indicates whether the document is classified as a GCP essential document per ICH E6(R2) Section 8. Critical documents require mandatory workflow completion before study activities can proceed and are prioritized in inspection readiness reviews.',
    `initiated_timestamp` TIMESTAMP COMMENT 'Date and time when the document workflow instance was first created and launched in Veeva Vault. Serves as the principal business event timestamp for the workflow lifecycle and the start point for overall cycle time measurement.',
    `inspection_readiness_flag` BOOLEAN COMMENT 'Indicates whether this workflow and its associated document have been reviewed and confirmed as inspection-ready per GCP and regulatory authority standards. Supports pre-inspection TMF completeness assessments by FDA, EMA, MHRA, or other regulatory bodies.',
    `instance_reference` STRING COMMENT 'Externally-known unique identifier assigned by Veeva Vault to this specific workflow instance. Used for cross-system traceability and audit trail correlation with the source eTMF system.',
    `priority_level` STRING COMMENT 'Business priority assigned to this workflow instance, reflecting urgency of document review and approval. Critical priority is assigned to GCP essential documents, regulatory submissions with imminent deadlines, and safety-related documents.. Valid values are `critical|high|medium|low`',
    `regulatory_submission_flag` BOOLEAN COMMENT 'Indicates whether the document being processed through this workflow is intended for regulatory submission (e.g., IND, NDA, BLA, MAA, eCTD). True triggers additional compliance checks and approval requirements per FDA/EMA submission standards.',
    `rejection_count` BIGINT COMMENT 'Number of times the document has been rejected and returned for revision within this workflow instance. High rejection counts indicate document quality issues and are tracked for quality metrics and CAPA (Corrective and Preventive Action) analysis.',
    `rejection_reason` STRING COMMENT 'Free-text or categorized reason provided when a workflow step is rejected. Documents the specific deficiency identified by the reviewer, supporting document quality improvement and GCP audit trail requirements.',
    `sla_breach_indicator` BOOLEAN COMMENT 'Flag indicating whether the workflow or any of its steps has exceeded the defined Service Level Agreement (SLA) timeframe. True when step_completion_date or actual_completion_date exceeds the corresponding due date. Drives escalation and KPI reporting.',
    `workflow_status` STRING COMMENT 'Current lifecycle state of the document workflow instance within Veeva Vault. Tracks progression from initiation through review, approval decision, and terminal states. Supports GCP-compliant document control audit trails.. Valid values are `initiated|in-review|pending-approval|approved|rejected|cancelled`',
    `step_action_taken` STRING COMMENT 'The specific action performed by the assignee at the current or last completed workflow step. Captures the decision outcome (approved, rejected) or process action (delegated, escalated) for audit trail completeness.. Valid values are `approved|rejected|reviewed|delegated|reassigned|escalated`',
    `step_assignee_name` STRING COMMENT 'Full name of the individual assigned to the current workflow step. Captured at time of assignment for audit trail integrity per ALCOA+ (Attributable, Legible, Contemporaneous, Original, Accurate) requirements.',
    `step_assignee_role` STRING COMMENT 'Business role responsible for completing the current workflow step (e.g., Principal Investigator (PI), Clinical Research Associate (CRA), Regulatory Affairs Manager, Quality Assurance (QA) Reviewer).',
    `step_comment` STRING COMMENT 'Free-text comment or rationale provided by the step assignee when completing, rejecting, or escalating the workflow step. Supports GCP documentation requirements and provides context for rejection decisions.',
    `step_completion_date` DATE COMMENT 'Actual date on which the current or most recently completed workflow step was actioned and closed. Compared against step_due_date to determine SLA compliance and cycle time analytics.',
    `step_completion_timestamp` TIMESTAMP COMMENT 'Precise date and time at which the workflow step action was recorded in Veeva Vault. Provides sub-day granularity required for 21 CFR Part 11 electronic audit trail and time-stamped electronic signature records.',
    `step_due_date` DATE COMMENT 'Target completion date for the current workflow step as defined by the workflow SLA configuration. Used to calculate SLA breach status and trigger escalation notifications for overdue document reviews.',
    `target_completion_date` DATE COMMENT 'Overall target date by which the entire document workflow (all steps) must be completed. Derived from workflow SLA rules and used for inspection readiness tracking and TMF completeness KPI reporting.',
    `template_name` STRING COMMENT 'Name of the Veeva Vault workflow template used to instantiate this workflow (e.g., SOP Review and Approval, Regulatory Document Approval, ICF Review Workflow). Identifies the standard process blueprint applied.',
    `template_version` STRING COMMENT 'Version identifier of the workflow template at the time this workflow instance was initiated. Ensures reproducibility and audit traceability when templates are updated over time.',
    `tmf_zone` STRING COMMENT 'DIA TMF Reference Model zone classification for the document being processed. Categorizes the document into the appropriate TMF structural zone to support inspection readiness and TMF completeness assessments.',
    `total_steps` BIGINT COMMENT 'Total number of steps defined in the workflow template for this workflow instance. Used in conjunction with current_step_sequence to calculate workflow completion percentage for inspection readiness dashboards.',
    `workflow_type` STRING COMMENT 'Classification of the workflow by its primary business purpose within the document lifecycle. Distinguishes review-only workflows from approval workflows, distribution workflows, archival workflows, and amendment workflows.. Valid values are `review|approval|distribution|archival|cancellation|amendment`',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this document_workflow record was last modified in the Databricks Silver Layer. Tracks the most recent state change for incremental processing and audit trail completeness.',
    CONSTRAINT pk_workflow PRIMARY KEY(`workflow_id`)
) COMMENT 'Tracks the lifecycle workflow state of a document through its review, approval, and distribution process within Veeva Vault. Captures workflow instance ID, workflow template name, current workflow step, step assignee role, step due date, step completion';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`document`.`signature` (
    `signature_id` BIGINT COMMENT 'Unique surrogate identifier for each electronic signature record applied to a controlled document. Primary key for the document_signature data product in the Databricks Silver Layer.',
    `delegation_of_authority_id` BIGINT COMMENT 'Reference to the delegation of authority record when the signer is acting on behalf of another party (e.g., a sub-investigator signing on behalf of the Principal Investigator). Supports sponsor oversight and GCP compliance verification.',
    `organization_contact_id` BIGINT COMMENT 'Foreign key linking to sponsor.sponsor_contact. Business justification: Sponsor contacts are signatories on key TMF documents (protocol approvals, ICF approvals, regulatory submissions).',
    `primary_signature_employee_id` BIGINT COMMENT 'Reference to the authenticated user record of the individual who applied the electronic signature. Satisfies the ALCOA+ principle of Attributability — every signature must be traceable to a unique individual.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) with which the signed document is associated. Enables study-level signature completeness reporting and TMF inspection readiness tracking.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site associated with the signed document, where applicable (e.g., site-level ICF, site initiation documents). Supports site-level TMF completeness and inspection readiness metrics.',
    `tmf_document_id` BIGINT COMMENT 'Reference to the controlled document record in the document master that this signature was applied to. Links the signature to its parent TMF/eTMF document.',
    `version_id` BIGINT COMMENT 'Reference to the specific version of the document at the time the signature was applied. Ensures the signature is bound to an immutable document version, satisfying 21 CFR Part 11 integrity requirements.',
    `workflow_id` BIGINT COMMENT 'Foreign key linking to document.document_workflow. Business justification: Electronic signatures are applied within the context of a document workflow step (review, approval, distribution).',
    `audit_hash` STRING COMMENT 'Cryptographic hash (e.g., SHA-256) of the signed document content and signature metadata at the time of signing. Provides tamper-evidence and integrity verification for the electronic signature record, satisfying 21 CFR Part 11 §11.10(a) data integrity',
    `comments` STRING COMMENT 'Free-text comments or notes entered by the signer at the time of signing. May capture the signers attestation statement, conditional approval notes, or reviewer observations. Stored as part of the immutable signature audit trail.',
    `created_timestamp` TIMESTAMP COMMENT 'System-generated timestamp when the signature request record was first created in the source system (Veeva Vault). Supports audit trail completeness and ALCOA+ compliance.',
    `device_identifier` STRING COMMENT 'Unique identifier of the device (workstation, tablet, or mobile device) used to apply the electronic signature. Supports forensic audit trail and 21 CFR Part 11 system access controls validation.',
    `digital_certificate_serial` STRING COMMENT 'Serial number of the digital certificate used when the signature method is digital_certificate or smart_card. Enables certificate chain validation and revocation checking for PKI-based electronic signatures.',
    `due_date` DATE COMMENT 'The deadline by which the signer must apply their electronic signature, as defined in the document workflow configuration. Used for SLA tracking, escalation triggering, and inspection readiness reporting.',
    `hash_algorithm` STRING COMMENT 'Cryptographic algorithm used to generate the audit hash for this signature record (e.g., SHA-256, SHA-512). Required to enable future hash verification and to document the cryptographic standard applied at the time of signing.. Valid values are `SHA-256|SHA-512|SHA-3|RSA-SHA256`',
    `inspection_readiness_flag` BOOLEAN COMMENT 'Indicates whether this signature record has been reviewed and confirmed as complete and compliant for regulatory inspection purposes. Used in TMF inspection readiness dashboards and GCP audit preparation.',
    `ip_address` STRING COMMENT 'IP address of the device from which the electronic signature was applied. Captured as part of the 21 CFR Part 11 audit trail to support identity verification and forensic investigation. May be considered PII under GDPR.',
    `is_regulatory_submission_applicable` BOOLEAN COMMENT 'Indicates whether this signature is part of a document package intended for regulatory submission (e.g., IND, NDA, BLA, MAA, eCTD). When True, the signature record is subject to heightened integrity and retention requirements.',
    `last_reminder_timestamp` TIMESTAMP COMMENT 'Date and time of the most recent automated reminder notification sent to the signer. Supports escalation management and overdue signature tracking.',
    `locale` STRING COMMENT 'IETF BCP 47 locale code representing the language and regional settings active at the time of signing (e.g., en-US, de-DE, ja-JP). Relevant for multi-national trials to confirm the signer viewed the document in their preferred language.',
    `meaning` STRING COMMENT 'The legally defined meaning associated with the electronic signature, as required by 21 CFR Part 11. Specifies the intent of the signer (e.g., reviewed = content reviewed for accuracy; approved = authorized for release; acknowledged = receipt confirmed).. Valid values are `reviewed|approved|acknowledged|authored|certified|witnessed`',
    `method` STRING COMMENT 'Authentication method used to apply the electronic signature. Determines the technical compliance pathway under 21 CFR Part 11 (biometric vs. non-biometric). Required for regulatory inspection to demonstrate identity verification rigor.. Valid values are `username_password|biometric|digital_certificate|smart_card|two_factor_auth`',
    `reference_number` STRING COMMENT 'Externally-known unique business identifier for the electronic signature event, as assigned by Veeva Vault or the controlling eTMF system. Used for cross-system traceability and regulatory inspection referencing.',
    `reminder_sent_count` BIGINT COMMENT 'Number of automated reminder notifications sent to the signer for a pending signature request. Used to track escalation activity and measure signature workflow efficiency in TMF completeness dashboards.',
    `requested_timestamp` TIMESTAMP COMMENT 'Date and time when the signature request was initiated and sent to the signer. Used to calculate signature turnaround time and to track overdue signature tasks in inspection readiness dashboards.',
    `signed_timestamp` TIMESTAMP COMMENT 'The precise date and time (with timezone offset) at which the electronic signature was applied by the signer. This is the principal real-world event timestamp for the signature transaction.',
    `signer_full_name` STRING COMMENT 'Full legal name of the individual who applied the electronic signature, captured at the time of signing. Stored as a point-in-time snapshot to preserve the audit trail even if the user record changes.',
    `signer_organization` STRING COMMENT 'Name of the organization or company the signer represents at the time of signing (e.g., sponsor company name, CRO name, investigative site institution). Supports multi-party trial agreements and sponsor delegation tracking.',
    `signer_role` STRING COMMENT 'Functional role of the signer within the document workflow at the time of signing. Determines the legal weight and workflow position of the signature. [ENUM-REF-CANDIDATE. Valid values are `author|reviewer|approver|sponsor_representative|quality_assurance|investigator`',
    `signer_title` STRING COMMENT 'Professional title or job designation of the signer at the time of signing (e.g., Principal Investigator, Medical Monitor, Sponsor Representative, Biostatistician). Captured as a point-in-time snapshot for regulatory inspection readiness.',
    `source_system_signature_reference` STRING COMMENT 'Native identifier of the signature record in the originating source system (e.g., Veeva Vault internal signature object ID). Enables bidirectional traceability between the Silver Layer and the operational system for reconciliation and audit.',
    `signature_status` STRING COMMENT 'Current lifecycle status of the electronic signature record. Pending = awaiting signer action; Applied = successfully executed; Voided = invalidated due to document revision or administrative action; Superseded = replaced by a newer signature; Rejected =. Valid values are `pending|applied|voided|superseded|rejected`',
    `timezone` STRING COMMENT 'IANA timezone identifier representing the local timezone of the signer at the time of signing (e.g., America/New_York, Europe/London). Required to accurately interpret the signed_timestamp in multi-national trial contexts and for regulatory inspection.',
    `tmf_artifact_number` STRING COMMENT 'DIA TMF Reference Model artifact number identifying the document type being signed (e.g., 01.01.01 for Protocol, 06.02.01 for Informed Consent Form). Enables artifact-level signature completeness tracking.',
    `tmf_zone` STRING COMMENT 'DIA TMF Reference Model Zone classification of the document to which this signature belongs (e.g., Zone 01 - Trial Management, Zone 02 - Central Trial Documents, Zone 03 - Regulatory). Supports TMF completeness metrics and inspection readiness reporting.',
    `signature_type` STRING COMMENT 'Classification of the signature type per applicable regulatory framework. Electronic = standard 21 CFR Part 11 e-signature; Wet Ink Scanned = paper signature digitized; Advanced Electronic = eIDAS AES; Qualified Electronic = eIDAS QES with qualified. Valid values are `electronic|wet_ink_scanned|advanced_electronic|qualified_electronic`',
    `updated_timestamp` TIMESTAMP COMMENT 'System-generated timestamp of the most recent modification to the signature record (e.g., status change, void action). Required for audit trail completeness and change detection in the Silver Layer ETL pipeline.',
    `void_reason` STRING COMMENT 'Free-text explanation for why the signature was voided or invalidated. Required when signature_status = voided to maintain a complete and auditable record of signature lifecycle events per 21 CFR Part 11.',
    `voided_timestamp` TIMESTAMP COMMENT 'Date and time when the signature was voided or invalidated. Supports the complete lifecycle audit trail for the signature record and regulatory inspection readiness.',
    `workflow_step_name` STRING COMMENT 'Name of the document workflow step within which this signature was collected (e.g., Author Review, QA Approval, Sponsor Sign-Off). Maps to the Veeva Vault workflow configuration and supports workflow analytics and bottleneck identification.',
    `workflow_step_sequence` BIGINT COMMENT 'Numeric sequence position of this signature step within the overall document approval workflow. Enables ordered reconstruction of the full signature chain for regulatory inspection and audit trail review.',
    CONSTRAINT pk_signature PRIMARY KEY(`signature_id`)
) COMMENT 'Records electronic signatures applied to controlled documents per 21 CFR Part 11 requirements. Captures signer identity, signer role (author, reviewer, approver, sponsor representative), signature date and timestamp, signature meaning (reviewed, approved';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`document`.`site_file` (
    `site_file_id` BIGINT COMMENT 'Unique surrogate identifier for the Investigator Site File (ISF) or Regulatory Binder record in the lakehouse. Primary key for this entity.',
    `employee_id` BIGINT COMMENT 'Reference to the individual (Principal Investigator or Clinical Research Coordinator) who is the designated custodian responsible for maintaining the completeness and accuracy of the site file.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study with which this site file is associated. Links the ISF to its parent protocol.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site at which this site file is maintained. Ties the ISF to a specific site entity.',
    `activation_date` DATE COMMENT 'Date on which the site file was formally activated and made available for document filing, coinciding with or following site initiation. Marks the start of the files active lifecycle.',
    `applicable_gcp_guideline` STRING COMMENT 'The specific GCP guideline version or regulation that governs the conduct of this site file. Determines essential document requirements, retention obligations, and inspection readiness criteria.. Valid values are `ICH E6(R2)|ICH E6(R3)|21 CFR Part 312|EU CTR 536/2014|ISO 14155`',
    `archival_date` DATE COMMENT 'Date on which the site file was transferred to long-term archival storage per ICH GCP and sponsor retention requirements. Typically 15 years post-study completion for IND studies.',
    `archival_location` STRING COMMENT 'Physical or electronic location where the site file has been archived post-study closure (e.g., sponsor archive facility name, Veeva Vault archive vault path, or third-party archive vendor name).',
    `closure_date` DATE COMMENT 'Date on which the site file was formally closed following site close-out activities. After this date, no new documents should be filed except for archival or regulatory response purposes.',
    `completeness_percentage` DECIMAL(5,2) COMMENT 'Numeric percentage (0.00–100.00) representing the proportion of expected essential documents that are present and current in the site file. Calculated at the time of the last completeness review. Used for KPI reporting and inspection readiness dashboards.',
    `completeness_status` STRING COMMENT 'Overall completeness assessment of the site file relative to the expected essential documents per ICH GCP Section 8 and the DIA TMF Reference Model. Drives inspection readiness scoring and CRA monitoring activities.. Valid values are `Complete|Incomplete|Overdue|Not Applicable`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the site file record was first created in the system of record (Veeva Vault or CTMS). Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `custodian_role` STRING COMMENT 'Role of the designated custodian responsible for the site file. PI (Principal Investigator) is the accountable party per GCP; CRC (Clinical Research Coordinator) typically manages day-to-day file maintenance.. Valid values are `PI|CRC|Sub-Investigator|Regulatory Affairs Coordinator|Site Manager`',
    `delegation_log_on_file` BOOLEAN COMMENT 'Indicates whether a current, signed Delegation of Authority (DoA) log is present in the site file, documenting all site staff authorized to perform study-related tasks and their qualifications.',
    `electronic_vault_path` STRING COMMENT 'Folder path or document library location within Veeva Vault eTMF where the electronic site file is stored. Used for direct navigation and audit trail purposes.',
    `file_format` STRING COMMENT 'Indicates whether the site file is maintained electronically (eTMF via Veeva Vault), in paper form at the site, or as a hybrid of both. Drives inspection readiness procedures and retrieval workflows.. Valid values are `Electronic|Paper|Hybrid`',
    `file_reference_number` STRING COMMENT 'Externally-known alphanumeric identifier assigned to this site file, used in regulatory correspondence, inspection readiness tracking, and eTMF cross-referencing. Typically generated by the CTMS or Veeva Vault.',
    `file_status` STRING COMMENT 'Current lifecycle state of the site file. Active indicates the file is in use during the study; Under Review indicates a quality or completeness review is in progress; Archived indicates post-study archival; Closed indicates the site has been closed out. Valid values are `Active|Under Review|Archived|Closed|Pending Activation`',
    `file_type` STRING COMMENT 'Classification of the site file by its regulatory and operational purpose. ISF (Investigator Site File) is the primary site-level essential document collection; Regulatory Binder holds IRB/IEC submissions and approvals; Pharmacy Binder tracks. Valid values are `ISF|Regulatory Binder|Pharmacy Binder|Laboratory Binder|Investigator Binder`',
    `financial_disclosure_on_file` BOOLEAN COMMENT 'Indicates whether signed financial disclosure forms for the investigator and sub-investigators are present in the site file, as required by FDA regulations to identify potential conflicts of interest.',
    `icf_on_file` BOOLEAN COMMENT 'Indicates whether the current, IRB/IEC-approved Informed Consent Form (ICF) is present in the site file. A mandatory essential document per ICH GCP Section 8.2.',
    `inspection_readiness_status` STRING COMMENT 'Assessment of the site files readiness for regulatory inspection by authorities such as FDA, EMA, or MHRA. Ready indicates the file meets all GCP and regulatory requirements; Needs Remediation indicates minor gaps requiring correction; Critical Gaps. Valid values are `Ready|Needs Remediation|Critical Gaps|Not Assessed`',
    `investigator_cv_on_file` BOOLEAN COMMENT 'Indicates whether a current, signed curriculum vitae (CV) for the Principal Investigator and all sub-investigators is present in the site file. A mandatory essential document per ICH GCP Section 8.2.',
    `irb_iec_approval_on_file` BOOLEAN COMMENT 'Indicates whether the current, valid IRB (Institutional Review Board) or IEC (Independent Ethics Committee) approval letter is present in the site file. A mandatory essential document per ICH GCP Section 8.2.',
    `lab_certification_on_file` BOOLEAN COMMENT 'Indicates whether current laboratory certifications (e.g., CLIA, CAP) and normal reference ranges for the sites clinical laboratory are present in the site file, as required by ICH GCP Section 8.',
    `last_inspection_date` DATE COMMENT 'Date of the most recent regulatory inspection (FDA, EMA, MHRA, or other authority) at which this site file was reviewed. Used for inspection history tracking and readiness planning.',
    `last_inspection_outcome` STRING COMMENT 'Outcome classification of the most recent regulatory inspection of the site file. NAI (No Action Indicated), VAI (Voluntary Action Indicated), and OAI (Official Action Indicated) are standard FDA classification categories.. Valid values are `No Action Indicated|Voluntary Action Indicated|Official Action Indicated|Pending|Not Applicable`',
    `last_review_date` DATE COMMENT 'Date on which the most recent completeness review or quality check of the site file was performed, typically by a CRA (Clinical Research Associate) during a monitoring visit or central review.',
    `missing_document_count` BIGINT COMMENT 'Number of essential documents identified as missing or outstanding from the site file at the time of the last review. Drives follow-up actions and inspection readiness remediation.',
    `next_review_date` DATE COMMENT 'Planned date for the next completeness review or quality check of the site file. Used for scheduling CRA monitoring visits and proactive inspection readiness management.',
    `notes` STRING COMMENT 'Free-text field for capturing additional context, special instructions, or observations related to the site file that are not captured in structured fields.',
    `open_action_item_count` BIGINT COMMENT 'Number of outstanding action items or findings related to the site file that have not yet been resolved. Derived from monitoring visit findings and quality reviews. Used for inspection readiness and site risk assessment.',
    `physical_location` STRING COMMENT 'Description of the physical storage location of the site file at the investigational site (e.g., room number, cabinet, shelf). Applicable for paper or hybrid files. Required for inspection readiness and retrieval.',
    `protocol_on_file` BOOLEAN COMMENT 'Indicates whether the signed and dated study protocol (and all applicable amendments) is present in the site file. A mandatory essential document per ICH GCP Section 8.',
    `regulatory_authority` STRING COMMENT 'Primary regulatory authority with jurisdiction over the investigational site and its site file requirements. Determines applicable GCP guidelines, retention periods, and inspection standards.',
    `retention_expiry_date` DATE COMMENT 'Date on which the mandatory regulatory retention period for the site file expires, after which the file may be destroyed per applicable regulations. Calculated based on study completion date and jurisdiction-specific retention requirements.',
    `sponsor_review_completed` BOOLEAN COMMENT 'Indicates whether the sponsor or CRO has completed a formal review of the site file for completeness and GCP compliance. Required as part of sponsor oversight obligations under ICH GCP Section 5.',
    `sponsor_review_date` DATE COMMENT 'Date on which the sponsor or CRO completed the most recent formal review of the site file. Supports audit trail and oversight documentation requirements.',
    `tmf_section` STRING COMMENT 'DIA TMF Reference Model section code within the assigned zone (e.g., 06.01 for Site Initiation). Provides granular classification for document filing and completeness tracking.',
    `tmf_zone` STRING COMMENT 'DIA TMF Reference Model zone classification under which this site files documents are organized. Zones provide a standardized taxonomy for essential document categorization across the TMF.. Valid values are `Trial Management|Investigational Product|Site Management|Subject Information and Consent|Study Procedures`',
    `total_expected_documents` BIGINT COMMENT 'Total count of essential documents expected to be present in the site file based on the study protocol, applicable regulations, and DIA TMF Reference Model requirements for this site and study phase.',
    `total_filed_documents` BIGINT COMMENT 'Actual count of documents currently filed and verified within the site file. Used in conjunction with total_expected_documents to derive completeness metrics.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the site file record. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles for data integrity.',
    `veeva_vault_document_reference` STRING COMMENT 'Unique document identifier assigned by Veeva Vault eTMF to the site file container or root document object. Enables direct cross-system traceability between the lakehouse record and the source eTMF system.',
    CONSTRAINT pk_site_file PRIMARY KEY(`site_file_id`)
) COMMENT 'Master entity representing the Investigator Site File (ISF) or Regulatory Binder maintained at each investigational site. Captures site file ID, associated study, associated site, file type (ISF, regulatory binder, pharmacy binder), physical or electronic';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`document`.`site_file_document` (
    `site_file_document_id` BIGINT COMMENT 'Unique surrogate identifier for each site file document association record in the Investigator Site File (ISF). Primary key for this entity.',
    `employee_id` BIGINT COMMENT 'Reference to the Clinical Research Associate (CRA) who verified the document filing during the monitoring visit or Source Data Verification (SDV) activity.',
    `site_file_id` BIGINT COMMENT 'Reference to the Investigator Site File (ISF) to which this document belongs. Links the document filing to a specific sites master file.',
    `study_site_id` BIGINT COMMENT 'Reference to the study site (investigational site) associated with this ISF document filing, enabling per-site document completeness tracking.',
    `superseded_by_document_site_file_document_id` BIGINT COMMENT 'Reference to the newer document record that supersedes this filing when filing_status is superseded. Enables version chain traceability within the ISF.',
    `tmf_artifact_id` BIGINT COMMENT 'Foreign key linking to document.tmf_artifact. Business justification: Each document filed in the ISF/regulatory binder corresponds to a specific DIA TMF Reference Model artifact.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Site file documents filed in the ISF often correspond to TMF master documents. Adding tmf_document_id enables traceability from the site-level filed copy back to the authoritative TMF',
    `archival_date` DATE COMMENT 'The date this document filing was archived in the eTMF system following study close-out. Supports ICH GCP archival retention requirements (minimum 15 years for IND studies).',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the site where this document is filed. Supports multi-country study document completeness reporting.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this site file document association record was first created in the system. Supports audit trail and ALCOA+ compliance.',
    `discrepancy_description` STRING COMMENT 'Description of any discrepancy identified during SDV or document review for this ISF filing (e.g., incorrect version on file, missing signature, illegible copy). Populated when sdv_status is discrepancy_found.',
    `discrepancy_resolution_date` DATE COMMENT 'The date on which a previously identified document discrepancy was resolved and the ISF filing was corrected or updated.',
    `document_date` DATE COMMENT 'The date the document was authored, issued, or approved, as stated on the document itself. Distinct from the filing date. Used to confirm the document is the current effective version.',
    `document_source_type` STRING COMMENT 'Indicates the nature of the document copy filed in the ISF: original document, certified copy, scanned copy, fax copy, or electronic original. Critical for GCP compliance and inspection readiness per ALCOA+ principles.. Valid values are `original|certified_copy|scanned_copy|fax_copy|electronic`',
    `document_title` STRING COMMENT 'The official title of the document as filed in the Investigator Site File, matching the title recorded in Veeva Vault eTMF.',
    `document_type` STRING COMMENT 'Classification of the document type as defined in the TMF/ISF taxonomy (e.g., Informed Consent Form, IRB Approval, Protocol, Delegation Log, CV). [ENUM-REF-CANDIDATE: promote to reference product given large number of TMF artifact types]',
    `expected_filing_date` DATE COMMENT 'The target or deadline date by which a missing or pending document is expected to be filed in the ISF. Used for follow-up tracking and monitoring visit preparation.',
    `expiry_date` DATE COMMENT 'The date on which this document expires or requires renewal (e.g., IRB/IEC approval expiry, investigator CV update due date, insurance certificate expiry). Null if the document does not have an expiry.',
    `filing_date` DATE COMMENT 'The date the document was physically or electronically filed into the Investigator Site File (ISF). Supports timeliness tracking and inspection readiness assessment.',
    `filing_method` STRING COMMENT 'Indicates whether the document was filed electronically (eTMF via Veeva Vault), in paper form, or as a hybrid (paper original with electronic scan). Relevant for 21 CFR Part 11 compliance.. Valid values are `electronic|paper|hybrid`',
    `filing_notes` STRING COMMENT 'Free-text notes or comments recorded by the CRA or document controller regarding this specific document filing, such as special circumstances, follow-up instructions, or contextual observations.',
    `filing_status` STRING COMMENT 'Current filing status of the document within the ISF. Indicates whether the document has been filed, is missing, is not applicable for this site, is overdue, has been superseded by a newer version, or is pending review.. Valid values are `filed|missing|not_applicable|overdue|superseded|pending_review`',
    `is_inspection_ready` BOOLEAN COMMENT 'Indicates whether this document filing is considered inspection-ready, meaning it is complete, verified, and meets all GCP and regulatory requirements for regulatory authority review.',
    `is_required` BOOLEAN COMMENT 'Indicates whether this document is mandatory for the ISF based on the study protocol, regulatory requirements, and DIA TMF Reference Model. True = required; False = optional or conditional.',
    `isf_section_code` STRING COMMENT 'The DIA TMF Reference Model section/zone code designating where this document is filed within the Investigator Site File (ISF) structure (e.g., 05.001 for Protocol and Amendments).',
    `isf_section_name` STRING COMMENT 'Human-readable name of the ISF section or tab where this document is filed, corresponding to the DIA TMF Reference Model artifact classification (e.g., Informed Consent Forms, IRB/IEC Approvals).',
    `language_code` STRING COMMENT 'ISO 639-1 two-letter language code of the document (e.g., EN, DE, JA). Relevant for multi-regional studies where documents may be in local languages.. Valid values are `^[A-Z]{2}$`',
    `missing_document_reason` STRING COMMENT 'Explanation for why a required document is currently missing from the ISF. Captured to support follow-up actions and inspection readiness tracking.',
    `not_applicable_reason` STRING COMMENT 'Justification text explaining why a document is marked as not_applicable for this site. Required when filing_status is not_applicable to support inspection readiness and audit trail.',
    `regulatory_authority` STRING COMMENT 'The regulatory authority jurisdiction under which this document filing requirement applies (e.g., FDA, EMA, MHRA). Relevant for multi-regional studies where document requirements may differ by jurisdiction.',
    `retention_end_date` DATE COMMENT 'The calculated date until which this document must be retained per applicable regulatory requirements. Based on study close-out date plus jurisdiction-specific retention period.',
    `sdv_date` DATE COMMENT 'The date on which the CRA completed Source Data Verification (SDV) for this document filing during a monitoring visit.',
    `sdv_status` STRING COMMENT 'Status of Source Data Verification (SDV) performed by the CRA for this document filing. Indicates whether the document has been verified against source, a discrepancy was found, verification is not yet performed, or SDV is not required for this document. Valid values are `not_verified|verified|discrepancy_found|not_required`',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this site file document association record was last modified. Supports audit trail, change tracking, and ALCOA+ compliance.',
    `vault_document_number` STRING COMMENT 'The externally-known unique document number assigned by Veeva Vault eTMF system to this document filing record. Serves as the business identifier for cross-system traceability.',
    `vault_document_reference` STRING COMMENT 'The unique document identifier assigned by Veeva Vault eTMF system for this specific document version. Enables direct cross-reference to the source system record for audit and traceability.',
    `vault_lifecycle_state` STRING COMMENT 'The document lifecycle state as recorded in Veeva Vault eTMF (e.g., Draft, In Review, Approved, Obsolete, Archived). Reflects the document workflow state in the source system.. Valid values are `draft|in_review|approved|obsolete|archived`',
    CONSTRAINT pk_site_file_document PRIMARY KEY(`site_file_document_id`)
) COMMENT 'Association entity linking specific TMF documents to their corresponding Investigator Site File (ISF). Captures the site file, the document, the ISF section/tab, filing date, filing status (filed, missing, not-applicable), source (original, certified';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` (
    `tmf_completeness_id` BIGINT COMMENT 'Unique surrogate identifier for each point-in-time TMF completeness assessment record. Primary key of this product.',
    `assessed_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: TMF completeness assessments must be traceable to qualified employees for regulatory inspection. The assessors GCP certification and role must be verifiable.',
    `master_agreement_id` BIGINT COMMENT 'Foreign key linking to sponsor.master_agreement. Business justification: TMF completeness assessments are contractually required under master agreements (eTMF plan reference). Linking enables tracking whether TMF obligations under the MSA are being met.',
    `prior_assessment_tmf_completeness_id` BIGINT COMMENT 'Reference to the immediately preceding TMF completeness assessment record for this study, enabling trend analysis and completeness trajectory tracking over time.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this TMF completeness assessment was conducted. Links to the study master record.',
    `study_site_id` BIGINT COMMENT 'Foreign key linking to site.study_site. Business justification: TMF completeness assessments are conducted at the site level (per DIA TMF Reference Model).',
    `assessed_by_role` STRING COMMENT 'Functional role of the individual who performed the TMF completeness assessment, such as TMF Manager, QA Specialist, Clinical Research Associate (CRA), Study Manager, or Regulatory Affairs.. Valid values are `tmf_manager|qa_specialist|cra|study_manager|regulatory_affairs`',
    `assessment_date` DATE COMMENT 'The calendar date on which the TMF completeness assessment was performed. Represents the point-in-time snapshot date for this record.',
    `assessment_period_end_date` DATE COMMENT 'The end date of the period covered by this TMF completeness assessment. For periodic assessments, this defines the end of the reporting window.',
    `assessment_period_start_date` DATE COMMENT 'The start date of the period covered by this TMF completeness assessment. For periodic assessments, this defines the beginning of the reporting window.',
    `assessment_reference` STRING COMMENT 'Externally-known unique reference number or code assigned to this completeness assessment, used for tracking and cross-referencing in Veeva Vault eTMF and inspection-readiness reports.',
    `assessment_status` STRING COMMENT 'Current workflow state of the completeness assessment record within Veeva Vault: draft (initiated but not yet submitted), in_progress (actively being assessed), completed (assessment data entry finished), reviewed (QA review completed), approved (formally. Valid values are `draft|in_progress|completed|reviewed|approved`',
    `assessment_type` STRING COMMENT 'Classification of the assessment trigger: scheduled (routine periodic), ad_hoc (unplanned), pre_inspection (triggered by regulatory inspection notice), milestone (triggered by a study milestone such as first patient in or database lock), or close_out. Valid values are `scheduled|ad_hoc|pre_inspection|milestone|close_out`',
    `capa_reference` STRING COMMENT 'Reference number of the CAPA record initiated in MasterControl as a result of critical TMF completeness gaps identified in this assessment. Null if no CAPA was required.',
    `completeness_target_pct` DECIMAL(5,2) COMMENT 'The minimum completeness percentage threshold required for this study at this point in time, as defined in the TMF plan or sponsor SOP. Used to determine whether the study is inspection-ready.',
    `completeness_trend` STRING COMMENT 'Directional trend of TMF completeness compared to the prior assessment: improving (percentage increased), stable (no significant change), declining (percentage decreased), or not_applicable (first assessment for this study).. Valid values are `improving|stable|declining|not_applicable`',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this TMF completeness assessment record was first created in the data platform. Audit trail field per ALCOA+ and 21 CFR Part 11 requirements.',
    `critical_document_gap_count` BIGINT COMMENT 'Number of missing or overdue artifacts classified as critical per the DIA TMF Reference Model or sponsor TMF plan (e.g., protocol, ethics approval, signed ICF). Critical gaps pose the highest inspection risk.',
    `etmf_system_snapshot_reference` STRING COMMENT 'The unique identifier of the eTMF system snapshot or report generated in Veeva Vault at the time of this assessment. Enables traceability back to the source system record for audit purposes.',
    `expected_artifact_count` BIGINT COMMENT 'Total number of TMF artifacts (documents) expected to be filed for this study at the time of assessment, based on the applicable DIA TMF Reference Model zones and study-specific TMF plan.',
    `filed_artifact_count` BIGINT COMMENT 'Total number of TMF artifacts that have been filed (uploaded and indexed) in the eTMF system (Veeva Vault) at the time of assessment.',
    `findings_summary` STRING COMMENT 'Free-text narrative summarizing the key findings, gaps, and observations identified during this TMF completeness assessment. Supports inspection-readiness reporting and CAPA initiation.',
    `inspection_readiness_risk` STRING COMMENT 'Qualitative risk rating for inspection readiness based on completeness gaps, overdue artifacts, and zone-level deficiencies. Supports risk-based TMF monitoring and escalation decisions.. Valid values are `low|medium|high|critical`',
    `is_inspection_ready` BOOLEAN COMMENT 'Indicates whether the TMF is deemed inspection-ready based on the overall completeness percentage meeting or exceeding the completeness target. True = inspection-ready; False = not inspection-ready.',
    `missing_artifact_count` BIGINT COMMENT 'Number of expected TMF artifacts that have not yet been filed at the time of assessment. Calculated as expected_artifact_count minus filed_artifact_count, excluding overdue artifacts.',
    `next_assessment_due_date` DATE COMMENT 'The scheduled due date for the next TMF completeness assessment for this study, based on the TMF plan frequency (e.g., monthly, quarterly). Supports proactive inspection readiness monitoring.',
    `overall_completeness_pct` DECIMAL(5,2) COMMENT 'The overall TMF completeness percentage calculated as (number of filed artifacts / number of expected artifacts) × 100. Principal quantitative KPI for inspection readiness monitoring. Expressed as a percentage with two decimal places.',
    `overdue_artifact_count` BIGINT COMMENT 'Number of TMF artifacts that are past their required filing deadline (per the TMF plan or DIA TMF Reference Model timelines) and have not yet been filed. A key inspection-readiness risk indicator.',
    `pending_review_artifact_count` BIGINT COMMENT 'Number of TMF artifacts that have been filed but are awaiting QC review or approval in Veeva Vault. These are filed but not yet finalized, and may affect the effective completeness rate.',
    `rejected_artifact_count` BIGINT COMMENT 'Number of TMF artifacts that were filed but subsequently rejected during QC review (e.g., wrong version, illegible, incorrect metadata). Rejected artifacts are not counted as filed for completeness purposes.',
    `remediation_action_required` BOOLEAN COMMENT 'Indicates whether this assessment identified gaps requiring formal remediation actions (e.g., CAPA initiation, escalation to study team). True = remediation required; False = no remediation required.',
    `review_date` DATE COMMENT 'The calendar date on which the QA reviewer completed their review of this completeness assessment.',
    `reviewed_by` STRING COMMENT 'Full name of the QA reviewer or TMF lead who reviewed and approved the completeness assessment. Required for inspection-readiness documentation.',
    `study_phase` STRING COMMENT 'The clinical development phase of the study at the time of assessment (Phase 1, 2, 3, 4, or combined phases). Contextualizes completeness expectations against phase-specific TMF requirements.. Valid values are `phase_1|phase_2|phase_3|phase_4|phase_1_2|phase_2_3`',
    `study_status_at_assessment` STRING COMMENT 'The operational status of the clinical study at the time this TMF completeness assessment was conducted. Used to contextualize completeness expectations — e.g., a study in close-out has higher completeness requirements than one in start-up.. Valid values are `start_up|enrolling|on_hold|completed|close_out`',
    `tmf_scope` STRING COMMENT 'Defines the scope of the TMF assessed: full_study (entire sponsor TMF), sponsor_tmf (sponsor-held documents only), site_tmf (site-held documents only), or investigator_site_file (ISF at a specific site).. Valid values are `full_study|sponsor_tmf|site_tmf|investigator_site_file`',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time when this TMF completeness assessment record was last modified in the data platform. Supports audit trail and change tracking per 21 CFR Part 11.',
    `zone_1_completeness_pct` DECIMAL(5,2) COMMENT 'Completeness percentage for DIA TMF Reference Model Zone 1 (Trial Management), covering documents related to trial management, oversight, and administration.',
    `zone_2_completeness_pct` DECIMAL(5,2) COMMENT 'Completeness percentage for DIA TMF Reference Model Zone 2 (Central Trial Documents), covering the protocol, amendments, investigator brochure, and other central study documents.',
    `zone_3_completeness_pct` DECIMAL(5,2) COMMENT 'Completeness percentage for DIA TMF Reference Model Zone 3 (Regulatory), covering regulatory submissions, approvals, and correspondence with health authorities such as FDA, EMA, and PMDA.',
    `zone_4_completeness_pct` DECIMAL(5,2) COMMENT 'Completeness percentage for DIA TMF Reference Model Zone 4 (IRB/IEC and Other Approvals), covering ethics committee approvals, informed consent forms (ICF), and other site-level approvals.',
    `zone_5_completeness_pct` DECIMAL(5,2) COMMENT 'Completeness percentage for DIA TMF Reference Model Zone 5 (Site Management), covering site selection, initiation, monitoring, and close-out documents.',
    `zone_6_completeness_pct` DECIMAL(5,2) COMMENT 'Completeness percentage for DIA TMF Reference Model Zone 6 (Investigational Product), covering IP manufacturing, labelling, shipping, accountability, and destruction records.',
    `zone_7_completeness_pct` DECIMAL(5,2) COMMENT 'Completeness percentage for DIA TMF Reference Model Zone 7 (Safety Reporting), covering SAE reports, SUSARs, DSURs, and safety communications filed in the TMF.',
    `zone_8_completeness_pct` DECIMAL(5,2) COMMENT 'Completeness percentage for DIA TMF Reference Model Zone 8 (Statistics and Data Management), covering the Statistical Analysis Plan (the source system), Data Management Plan (DMP), randomization documentation, and database lock records.',
    CONSTRAINT pk_tmf_completeness PRIMARY KEY(`tmf_completeness_id`)
) COMMENT 'Transactional record capturing a point-in-time TMF completeness assessment for a study, capturing the assessment date, assessed by (QA or TMF manager), overall completeness percentage, number of expected artifacts, number of filed artifacts, number of';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` (
    `inspection_readiness_id` BIGINT COMMENT 'Unique surrogate identifier for the document inspection readiness record. Primary key for this entity in the Databricks Silver Layer.',
    `compliance_capa_id` BIGINT COMMENT 'Reference to the formal CAPA record created in MasterControl to address inspection findings. Links this inspection readiness record to the quality management CAPA workflow.',
    `employee_id` BIGINT COMMENT 'Reference to the workforce member designated as the responsible TMF Manager accountable for maintaining inspection readiness for this studys TMF.',
    `primary_inspection_etmf_vault_study_id` BIGINT COMMENT 'The Veeva Vault eTMF system identifier for the studys TMF vault, enabling direct cross-reference to the source system of record for document completeness metrics and readiness scores.',
    `primary_regulatory_inspection_id` BIGINT COMMENT 'Foreign key linking to regulatory.regulatory_inspection. Business justification: Inspection readiness records are prepared for a specific regulatory inspection.',
    `site_file_id` BIGINT COMMENT 'Foreign key linking to document.site_file. Business justification: Inspection readiness assessments are conducted at the site file level — the ISF/regulatory binder maintained at each investigator site is the primary artifact reviewed during GCP',
    `sponsor_regulatory_strategy_id` BIGINT COMMENT 'Foreign key linking to sponsor.regulatory_strategy. Business justification: Inspection readiness assessments are scoped to specific regulatory authority inspections driven by the sponsors regulatory strategy (target health authority, submission pathway).',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site when the TMF inspection readiness record is scoped to a specific site file (tmf_scope = site-specific). Null for full-study or sponsor-section scoped records.',
    `tmf_completeness_id` BIGINT COMMENT 'Foreign key linking to document.tmf_completeness. Business justification: Inspection readiness assessments are directly informed by TMF completeness assessments.',
    `actual_inspection_end_date` DATE COMMENT 'The actual date on which the regulatory authority or sponsor inspection concluded. Used to calculate inspection duration and trigger post-inspection response workflows.',
    `actual_inspection_start_date` DATE COMMENT 'The actual date on which the regulatory authority or sponsor inspection commenced. Populated once the inspection begins; used to measure planning accuracy against target inspection date.',
    `capa_required` BOOLEAN COMMENT 'Indicates whether a formal Corrective and Preventive Action (CAPA) plan is required as a result of inspection findings. True when critical or major findings necessitate a structured CAPA response per GCP quality management requirements.',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this inspection readiness record was first created in the system. Supports audit trail requirements per 21 CFR Part 11 and ICH E6(R2) ALCOA+ principles.',
    `critical_gaps_count` BIGINT COMMENT 'Number of critical-severity document gaps or deficiencies that could result in a regulatory finding or inspection observation if not remediated prior to inspection. Subset of open_findings_count.',
    `dia_tmf_zone_coverage` STRING COMMENT 'Comma-separated list of DIA TMF Reference Model zones (e.g., Zone 1-Trial Management, Zone 2-Central Trial Documents, Zone 3-Regulatory, Zone 4-IRB/IEC, Zone 5-Site Management, Zone 6-IP, Zone 7-Safety Reporting, Zone 8-Statistics) included in the scope',
    `inspecting_authority` STRING COMMENT 'The regulatory authority or organization conducting or expected to conduct the inspection (e.g., FDA, EMA, MHRA, PMDA). Drives jurisdiction-specific readiness requirements and document standards.',
    `inspection_notification_date` DATE COMMENT 'The date on which the regulatory authority formally notified the sponsor or CRO of the upcoming inspection. Triggers the formal inspection preparation timeline and escalation procedures.',
    `inspection_outcome` STRING COMMENT 'The formal outcome classification issued by the regulatory authority following inspection closure. FDA classifications: No Action Indicated (NAI), Voluntary Action Indicated (VAI), Official Action Indicated (OAI).. Valid values are `no-action-indicated|voluntary-action-indicated|official-action-indicated|pending|not-applicable`',
    `inspection_report_date` DATE COMMENT 'The date on which the regulatory authority issued the formal inspection report or Form FDA 483 (for FDA inspections). Triggers the response timeline for addressing inspection observations.',
    `inspection_type` STRING COMMENT 'Classification of the regulatory or sponsor inspection for which readiness is being tracked. GCP inspections are conducted by regulatory authorities (FDA, EMA, MHRA, PMDA); TMF inspections focus on document completeness; sponsor inspections are internal. Valid values are `gcp|tmf|sponsor|regulatory-authority|for-cause|routine`',
    `last_readiness_review_date` DATE COMMENT 'The date on which the most recent internal TMF readiness review was conducted. Used to assess currency of the readiness assessment and trigger periodic re-reviews per SOP.',
    `major_gaps_count` BIGINT COMMENT 'Number of major-severity document gaps identified during TMF readiness review. Major gaps are significant deficiencies that require remediation but are less severe than critical gaps.',
    `minor_gaps_count` BIGINT COMMENT 'Number of minor-severity document gaps or observations identified during TMF readiness review. Minor gaps are low-risk deficiencies that should be addressed but do not pose immediate inspection risk.',
    `missing_documents_count` BIGINT COMMENT 'Number of expected TMF artifacts per the DIA TMF Reference Model that are entirely absent from the eTMF system. Distinct from overdue documents which are expected but not yet filed.',
    `next_readiness_review_date` DATE COMMENT 'The date on which the next scheduled internal TMF readiness review is planned. Supports proactive inspection readiness management and escalation when overdue.',
    `notes` STRING COMMENT 'Free-text field for the TMF Manager to document key observations, risk factors, remediation priorities, or contextual information relevant to the inspection readiness status of this studys TMF.',
    `open_findings_count` BIGINT COMMENT 'Total number of unresolved inspection readiness findings (gaps, deficiencies, or observations) identified during internal TMF reviews. A key KPI for inspection readiness dashboards.',
    `overdue_documents_count` BIGINT COMMENT 'Number of TMF documents that are past their expected filing deadline per the TMF filing timeline or DIA TMF Reference Model expectations. Indicates timeliness risk for inspection readiness.',
    `previous_inspection_date` DATE COMMENT 'Date of the most recent prior regulatory inspection for this study, if applicable. Used to assess inspection history, recurrence risk, and whether prior findings have been adequately remediated.',
    `previous_inspection_outcome` STRING COMMENT 'The formal outcome of the most recent prior regulatory inspection for this study. Provides historical context for current readiness planning and risk assessment.. Valid values are `no-action-indicated|voluntary-action-indicated|official-action-indicated|not-applicable`',
    `readiness_reference_code` STRING COMMENT 'Externally-known business identifier for this inspection readiness record, used in communications with sponsors, regulatory authorities, and internal tracking systems (e.g., Veeva Vault eTMF). Format: IR-{StudyCode}-{Sequence}.. Valid values are `^IR-[A-Z0-9]{3,10}-[0-9]{4,8}$`',
    `readiness_score` DECIMAL(5,2) COMMENT 'Quantitative score (0.00–100.00) representing the overall inspection readiness of the studys TMF, calculated based on document completeness, quality metrics, and open findings.',
    `readiness_status` STRING COMMENT 'Current lifecycle state of the TMF inspection readiness process for this study. not-started indicates no preparation has begun; in-preparation indicates active remediation; ready indicates the TMF has passed internal review; under-inspection. Valid values are `not-started|in-preparation|ready|under-inspection|closed`',
    `response_due_date` DATE COMMENT 'The deadline by which the sponsor or CRO must submit a formal written response to the regulatory authoritys inspection observations or findings. Typically 15 business days for FDA Form 483 responses.',
    `sponsor_notification_date` DATE COMMENT 'The date on which the sponsor was formally notified of the upcoming regulatory inspection. Populated when sponsor_notified is True.',
    `sponsor_notified` BOOLEAN COMMENT 'Indicates whether the study sponsor has been formally notified of the upcoming regulatory inspection. Required for sponsor oversight and co-inspection preparation per GCP obligations.',
    `study_protocol_number` STRING COMMENT 'The sponsor-assigned protocol number for the clinical study associated with this TMF inspection readiness record. Enables cross-referencing with regulatory submissions and sponsor systems.',
    `target_inspection_date` DATE COMMENT 'The anticipated or scheduled date on which the regulatory authority or sponsor inspection is expected to commence. Used for readiness planning and milestone tracking.',
    `tier` STRING COMMENT 'Red-Amber-Green (RAG) traffic-light classification of overall inspection readiness. green indicates ready for inspection; amber indicates preparation in progress with manageable gaps; red indicates significant deficiencies requiring urgent. Valid values are `red|amber|green`',
    `tmf_scope` STRING COMMENT 'Defines the scope of the TMF covered by this inspection readiness record. full-study covers the entire TMF; site-specific covers a single investigator site file; sponsor-section covers sponsor-held documents only; investigator-section covers. Valid values are `full-study|site-specific|sponsor-section|investigator-section`',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this inspection readiness record was most recently modified. Supports audit trail requirements per 21 CFR Part 11 and ICH E6(R2) ALCOA+ principles.',
    `version` BIGINT COMMENT 'Version number of this inspection readiness record, incremented each time a formal readiness review is conducted and the record is updated. Supports audit trail and version history tracking per 21 CFR Part 11.',
    CONSTRAINT pk_inspection_readiness PRIMARY KEY(`inspection_readiness_id`)
) COMMENT 'Master record tracking the inspection readiness status of a studys TMF for regulatory authority inspections (FDA, EMA, MHRA, PMDA). Captures study reference, inspection type (GCP, TMF, sponsor), target inspection date, readiness status (not-started';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`document`.`distribution` (
    `distribution_id` BIGINT COMMENT 'Unique surrogate identifier for each document distribution record in the controlled distribution log.',
    `distributed_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Document distribution accountability is a GCP audit trail requirement — the distributing employee must be identifiable for inspection.',
    `document_sop_id` BIGINT COMMENT 'Foreign key linking to document.document_sop. Business justification: SOPs are formally distributed to staff as controlled documents requiring acknowledgement and training completion.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this document distribution was performed. Enables study-level distribution tracking and inspection readiness.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site that received the document, if the distribution is site-specific. Null for sponsor-level or CRO-level distributions.',
    `tmf_document_id` BIGINT COMMENT 'Reference to the controlled document (SOP, protocol, amendment, ICF, etc.) that was distributed. Links to the document master record in the Trial Master File (TMF).',
    `version_id` BIGINT COMMENT 'Reference to the specific approved version of the document that was distributed. Ensures traceability to the exact version received by each recipient.',
    `acknowledgement_date` DATE COMMENT 'The date on which the recipient formally acknowledged receipt of the distributed document. Null if acknowledgement has not yet been received or is not required.',
    `acknowledgement_due_date` DATE COMMENT 'The deadline by which the recipient must acknowledge receipt of the document, as defined by the distribution plan or SOP. Used to identify overdue acknowledgements and trigger escalation workflows.',
    `acknowledgement_method` STRING COMMENT 'The mechanism by which the recipient acknowledged receipt of the document (e.g., electronic signature in Veeva Vault, email reply, physical signature on distribution log). Required for 21 CFR Part 11 compliance.. Valid values are `Electronic Signature|Email Reply|Physical Signature|System Confirmation`',
    `acknowledgement_required` BOOLEAN COMMENT 'Indicates whether the recipient is required to formally acknowledge receipt of the document. Mandatory for GCP-critical documents such as protocols, amendments, and Informed Consent Forms (ICFs). Drives overdue acknowledgement tracking.',
    `acknowledgement_timestamp` TIMESTAMP COMMENT 'Precise date and time at which the recipients acknowledgement was recorded in the system. Supports 21 CFR Part 11 electronic signature and audit trail requirements.',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the recipients location. Used for country-level distribution compliance tracking and regulatory reporting to authorities such as FDA, EMA, and PMDA.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time at which this distribution record was first created in the system. Supports 21 CFR Part 11 audit trail and ALCOA+ contemporaneous documentation requirements.',
    `distribution_date` DATE COMMENT 'The calendar date on which the document was formally distributed to the recipient. This is the principal business event date for the distribution record, used for GCP compliance timelines and inspection readiness.',
    `document_number` STRING COMMENT 'Controlled document number (e.g., SOP-0042, PROT-2024-001) as assigned by the document control system. Denormalized for audit trail completeness.',
    `document_title` STRING COMMENT 'Title of the document as it appeared at the time of distribution. Captured as a denormalized field to support audit trail completeness per ALCOA+ principles without requiring a join.',
    `document_type` STRING COMMENT 'Classification of the document type distributed. Drives distribution requirements, acknowledgement obligations, and regulatory filing rules. [ENUM-REF-CANDIDATE: Protocol|Amendment|ICF|SOP|Investigator Brochure|Regulatory Submission|Safety Letter|Lab',
    `effective_date` DATE COMMENT 'The date from which the distributed document version becomes effective and must be implemented by the recipient. Distinct from distribution date; critical for protocol amendments and SOP updates.',
    `method` STRING COMMENT 'The channel or mechanism used to distribute the document to the recipient (e.g., Veeva Vault system notification, email, physical courier, CTMS portal). Relevant for GCP-compliant controlled distribution audit trails.. Valid values are `Veeva Vault Notification|Email|Physical|Fax|CTMS Portal`',
    `notes` STRING COMMENT 'Free-text field for capturing additional context about the distribution event, such as special instructions, delivery exceptions, or reasons for delayed distribution.',
    `number` STRING COMMENT 'Externally-known unique business identifier for this distribution event, typically generated by the document management system (e.g., Veeva Vault). Used for audit trail references and regulatory inspection queries.',
    `recipient_email` STRING COMMENT 'Email address of the document recipient at the time of distribution. Used for electronic distribution audit trail and follow-up communications. Classified as confidential PII.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `recipient_name` STRING COMMENT 'Full name of the individual who received the document. Captured as a denormalized field to preserve the audit trail at the time of distribution, as required by ALCOA+ principles.',
    `recipient_organization` STRING COMMENT 'Name of the organization to which the recipient belongs (e.g., investigational site name, sponsor company, CRO (Contract Research Organization) name, IRB/IEC name). Supports organization-level distribution tracking.',
    `recipient_organization_type` STRING COMMENT 'Classification of the recipients organization type. Enables segmentation of distribution records by stakeholder category for compliance reporting and inspection readiness.. Valid values are `Site|Sponsor|CRO|IRB/IEC|Regulatory Authority|Laboratory`',
    `recipient_role` STRING COMMENT 'The functional role of the document recipient within the clinical trial (e.g., Principal Investigator (PI), Clinical Research Coordinator (CRC), Clinical Research Associate (CRA), Sponsor representative).',
    `reminder_date` DATE COMMENT 'The date on which the most recent acknowledgement reminder was sent to the recipient. Null if no reminder has been sent.',
    `reminder_sent` BOOLEAN COMMENT 'Indicates whether an acknowledgement reminder notification has been sent to the recipient for this distribution. Used to track follow-up actions for overdue acknowledgements.',
    `scope` STRING COMMENT 'The organizational scope of this distribution event, indicating whether the document was distributed globally, by country, to a specific site, department, or individual recipient.. Valid values are `Global|Country|Site|Department|Individual`',
    `distribution_status` STRING COMMENT 'Current lifecycle state of the document distribution record. Tracks progression from initiation through delivery and acknowledgement. Used for inspection readiness dashboards and overdue acknowledgement tracking.. Valid values are `Pending|Sent|Delivered|Acknowledged|Overdue|Cancelled`',
    `superseded_version_number` STRING COMMENT 'The version number of the previously distributed document that this distribution supersedes. Enables tracking of version transitions and ensures recipients are aware of obsolete versions.',
    `timestamp` TIMESTAMP COMMENT 'Precise date and time at which the document distribution was initiated or completed in the system (e.g., Veeva Vault notification sent). Supports 21 CFR Part 11 electronic audit trail requirements.',
    `tmf_artifact_number` STRING COMMENT 'The DIA TMF Reference Model artifact number associated with the distributed document (e.g., 01.01.01 for Study Plan). Enables structured TMF completeness tracking and regulatory inspection readiness.',
    `tmf_zone` STRING COMMENT 'The TMF zone classification under the DIA TMF Reference Model where this distribution record is filed (e.g., Zone 01 - Trial Management, Zone 04 - Investigational Sites). Supports eTMF completeness and inspection readiness.',
    `training_completion_date` DATE COMMENT 'Date on which the recipient completed the required training associated with the distributed document. Null if training is not required or not yet completed. Supports GCP training compliance tracking.',
    `training_required` BOOLEAN COMMENT 'Indicates whether the recipient is required to complete associated training upon receipt of this document (e.g., SOP training, protocol training). Links to training acknowledgement tracking in MasterControl.',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time at which this distribution record was most recently modified. Supports change tracking and 21 CFR Part 11 audit trail requirements.',
    `veeva_vault_distribution_reference` STRING COMMENT 'The native distribution event identifier assigned by Veeva Vault for this distribution record. Supports reconciliation between the lakehouse silver layer and the Veeva Vault source system.',
    `veeva_vault_document_reference` STRING COMMENT 'The native document identifier assigned by Veeva Vault eTMF for the distributed document. Enables direct traceability back to the source system record for audit and inspection purposes.',
    CONSTRAINT pk_distribution PRIMARY KEY(`distribution_id`)
) COMMENT 'Tracks the controlled distribution of approved documents (SOPs, protocols, amendments, ICFs) to recipients. Captures distribution date, document version distributed, recipient name, recipient role, recipient organization (site, sponsor, CRO), distribution';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` (
    `regulatory_binder_id` BIGINT COMMENT 'Unique surrogate identifier for the regulatory binder record in the lakehouse. Primary key for this entity.',
    `indication_id` BIGINT COMMENT 'Foreign key linking to program.indication. Business justification: regulatory_binder has indication as a plain text column — a denormalization of the indication entity. Regulatory submissions (NDA, BLA, MAA) are filed for specific indications.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization responsible for this regulatory submission. The sponsor is the legal entity accountable to the health authority for the submission content.',
    `program_strategic_plan_id` BIGINT COMMENT 'Foreign key linking to program.program_plan. Business justification: A regulatory binder implements the submission strategy defined in a program plan (NDA, BLA, MAA).',
    `regulatory_lead_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: The regulatory lead is the named accountable employee for submission management — a critical role in regulatory operations.',
    `submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission. Business justification: A regulatory binder is assembled to package a specific submission (IND, NDA, annual report).',
    `agency_action_date` DATE COMMENT 'The date on which the health authority issued its formal regulatory action (approval, complete response letter, refusal to file, withdrawal, etc.) on this submission. Marks the end of the primary review cycle.',
    `agency_action_type` STRING COMMENT 'The type of regulatory action taken by the health authority on this submission (e.g., approval, complete response letter (CRL), refuse to file (RTF), withdrawal). Captures the outcome of the regulatory review cycle.. Valid values are `approval|complete_response|refuse_to_file|withdrawal|approvable|not_approvable`',
    `agency_receipt_date` DATE COMMENT 'The date on which the health authority officially acknowledged receipt of the submission. Marks the start of the regulatory review clock (e.g., PDUFA clock for FDA, Day 0 for EMA). Distinct from submission_date which is the date filed by the sponsor.',
    `approval_date` DATE COMMENT 'The date on which the health authority granted marketing authorization, IND clearance, or equivalent regulatory approval for this submission. Null if not yet approved or if submission was withdrawn.',
    `archival_date` DATE COMMENT 'The date on which this regulatory binder was transferred to long-term archival storage per ICH GCP retention requirements. Null if not yet archived. ICH E6(R2) requires retention for at least 2 years after marketing authorization or study discontinuation.',
    `binder_number` STRING COMMENT 'Externally-known, human-readable unique identifier assigned to the regulatory binder or eCTD sequence package (e.g., IND-2024-001, NDA-125678-SEQ003). Used for cross-system reference and health authority correspondence.',
    `binder_status` STRING COMMENT 'Current lifecycle status of the regulatory binder. Tracks progression from document assembly through health authority review to final disposition. Values: in_preparation (being assembled), submitted (filed with agency), under_review (agency review in. Valid values are `in_preparation|submitted|under_review|approved|withdrawn`',
    `binder_title` STRING COMMENT 'Descriptive title of the regulatory binder or submission package (e.g., Initial IND Application for Compound XYZ, NDA Module 5 Clinical Study Reports). Used for identification and document management.',
    `binder_type` STRING COMMENT 'Classification of the regulatory binder by submission type. Determines the applicable regulatory framework and required document set. [ENUM-REF-CANDIDATE: IND|NDA|BLA|MAA|CTA|annual_report|IND_amendment|NDA_supplement|BLA_supplement|CTA_amendment —',
    `completeness_percentage` DECIMAL(5,2) COMMENT 'The percentage of required documents that have been collected and filed in this regulatory binder relative to the expected document set per DIA TMF Reference Model. Used for inspection readiness dashboards and regulatory milestone tracking.',
    `confidentiality_level` STRING COMMENT 'Data classification level assigned to this regulatory binder per the organizations information security policy. Regulatory submissions typically contain commercially sensitive and proprietary data.. Valid values are `restricted|confidential|internal|public`',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this regulatory binder record was first created in the system. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles (Attributable, Legible, Contemporaneous, Original, Accurate).',
    `ctd_module` STRING COMMENT 'Identifies which CTD module(s) are included in this binder (M1=Administrative/Regional, M2=Summaries, M3=Quality, M4=Nonclinical, M5=Clinical, full=complete dossier). Aligns with ICH M4 CTD structure for eCTD submissions.. Valid values are `M1|M2|M3|M4|M5|full`',
    `document_count` BIGINT COMMENT 'Total number of documents included in this regulatory binder at the time of submission. Used for completeness verification, inspection readiness, and DIA TMF Reference Model compliance tracking.',
    `ectd_version` STRING COMMENT 'The eCTD specification version used to structure and validate this submission (e.g., 3.2.2 for legacy eCTD, 4.0 for next-generation eCTD). Determines the XML backbone schema and validation rules applied during submission compilation.. Valid values are `3.2.2|4.0`',
    `expiry_date` DATE COMMENT 'The date on which the regulatory authorization or IND/CTA clearance expires and requires renewal. Applicable for conditional approvals, time-limited authorizations, and annual IND renewals. Null for permanent approvals.',
    `is_ectd_format` BOOLEAN COMMENT 'Indicates whether this regulatory binder is assembled and submitted in eCTD (Electronic Common Technical Document) format as required by ICH M8. True = eCTD format; False = non-eCTD (e.g., paper or NeeS format for legacy submissions).',
    `is_inspection_ready` BOOLEAN COMMENT 'Indicates whether this regulatory binder has been reviewed and certified as inspection-ready per GCP and DIA TMF Reference Model standards. True = inspection-ready; False = not yet certified. Critical for regulatory inspection preparedness programs.',
    `notes` STRING COMMENT 'Free-text field for capturing additional context, regulatory strategy notes, agency feedback summaries, or operational comments related to this regulatory binder.',
    `pdufa_target_date` DATE COMMENT 'The FDA PDUFA goal date by which the agency commits to completing its review and taking action on the submission. Applicable to NDA/BLA submissions to FDA. Used for regulatory timeline management and commercial launch planning.',
    `planned_submission_date` DATE COMMENT 'The internally planned or target date for submitting the regulatory binder to the health authority. Used for project planning, resource allocation, and regulatory milestone tracking. Compared against actual submission_date to measure submission timeliness.',
    `retention_expiry_date` DATE COMMENT 'The date on which the mandatory regulatory retention period for this binder expires, after which the documents may be destroyed per applicable regulations.',
    `review_pathway` STRING COMMENT 'The regulatory review designation or pathway applicable to this submission (e.g., standard, priority review, accelerated approval, breakthrough therapy, orphan drug, conditional marketing authorization). Determines review timelines and agency commitments.. Valid values are `standard|priority|accelerated|breakthrough|orphan|conditional`',
    `submission_category` STRING COMMENT 'Categorizes the submission as an original filing, amendment, supplement, annual report, or response to agency queries. Determines the review pathway and applicable regulatory timelines.. Valid values are `original|amendment|supplement|annual_report|response`',
    `submission_date` DATE COMMENT 'The date on which the regulatory binder was formally submitted to the target health authority. This is the principal business event date for the submission lifecycle and is used for regulatory timeline tracking and PDUFA/review clock calculations.',
    `submission_medium` STRING COMMENT 'The physical or electronic medium used to deliver the submission to the health authority (electronic = eCTD gateway/portal, paper = physical binders, hybrid = combination). FDA mandates electronic submission for most NDA/BLA/IND filings.. Valid values are `electronic|paper|hybrid`',
    `submission_portal` STRING COMMENT 'The electronic gateway or portal used to transmit the submission to the health authority (e.g., FDA ESG - Electronic Submissions Gateway, EMA eSubmission Gateway, PMDA eCTD Gateway). Used for submission tracking and technical troubleshooting.',
    `submission_sequence_number` STRING COMMENT 'Four-digit eCTD sequence number assigned to this submission package (e.g., 0000 for initial submission, 0001 for first amendment). Conforms to ICH M8 eCTD specification and is used by health authorities to track submission history.. Valid values are `^[0-9]{4}$`',
    `target_agency` STRING COMMENT 'The regulatory health authority to which this binder is submitted (e.g., FDA, EMA, PMDA, MHRA). Determines applicable regulatory requirements, submission format, and review timelines.',
    `therapeutic_area` STRING COMMENT 'The clinical therapeutic area or disease indication covered by this regulatory submission (e.g., Oncology, Cardiology, Neurology, Infectious Disease). Used for portfolio management, regulatory strategy, and agency routing.',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this regulatory binder record was last modified. Required for audit trail compliance under 21 CFR Part 11 and ALCOA+ data integrity principles. Used to detect stale records and track binder lifecycle changes.',
    `veeva_vault_binder_reference` STRING COMMENT 'The unique document or binder object identifier in Veeva Vault (eTMF/Regulatory module) that corresponds to this regulatory binder record. Enables cross-system traceability between the lakehouse silver layer and the operational system of record.',
    `withdrawal_date` DATE COMMENT 'The date on which the sponsor formally withdrew the regulatory submission from health authority review. Null if not withdrawn. Used for regulatory portfolio tracking and lessons-learned analysis.',
    `withdrawal_reason` STRING COMMENT 'Free-text description of the reason for withdrawing the regulatory submission (e.g., safety concerns, commercial decision, insufficient efficacy data). Populated only when withdrawal_date is set. Required for regulatory portfolio governance.',
    CONSTRAINT pk_regulatory_binder PRIMARY KEY(`regulatory_binder_id`)
) COMMENT 'Master entity representing a regulatory submission binder or eCTD sequence package assembled for health authority submissions (IND, NDA, BLA, MAA, CTA). Captures binder ID, binder type (IND, NDA, BLA, MAA, CTA, annual report), submission sequence number';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`document`.`binder_document` (
    `binder_document_id` BIGINT COMMENT 'Unique surrogate identifier for each binder-document association record in the silver layer lakehouse. Primary key for this entity.',
    `qc_reviewer_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Regulatory submission binder QC review requires traceable employee accountability — the reviewers qualifications are verified during regulatory agency inspections.',
    `regulatory_binder_id` BIGINT COMMENT 'Reference to the regulatory binder or eCTD sequence to which this document is associated. Links the document to its parent binder container.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: binder_document is the association entity linking documents to regulatory binders. It already has document_version_id -> document_version, but lacks a direct FK to the master',
    `version_id` BIGINT COMMENT 'Reference to the specific version of the document included in this binder. Ensures traceability of exactly which document version was submitted in each regulatory package.',
    `added_by_user` STRING COMMENT 'Username or system identifier of the Veeva Vault user who added this document to the binder. Required for 21 CFR Part 11 electronic records audit trail.',
    `added_date` DATE COMMENT 'The calendar date on which this document version was formally added to the regulatory binder or eCTD sequence. Supports submission timeline tracking and ALCOA+ compliance.',
    `added_timestamp` TIMESTAMP COMMENT 'Precise date and time (with timezone) when this document version was added to the binder, captured from Veeva Vault for audit trail and 21 CFR Part 11 compliance.',
    `approval_date` DATE COMMENT 'Date on which this binder-document association was formally approved within the Veeva Vault workflow. Supports submission readiness and inspection timelines.',
    `approval_status` STRING COMMENT 'Lifecycle approval status of this binder-document association within Veeva Vault workflow: draft, pending_approval, approved (ready for submission), superseded (replaced by newer version), or withdrawn.. Valid values are `draft|pending_approval|approved|superseded|withdrawn`',
    `approved_by_user` STRING COMMENT 'Username of the Veeva Vault user who granted final approval for this documents inclusion in the binder. Required for 21 CFR Part 11 electronic signature audit trail.',
    `confidentiality_level` STRING COMMENT 'Confidentiality classification of the document as included in the binder, per sponsor and regulatory requirements (e.g., public for published CSRs, confidential for IB, restricted for patient-level data). Governs access controls and redaction requirements.. Valid values are `public|confidential|restricted|highly_restricted`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this binder-document association record was first created in the system. Supports audit trail, ALCOA+ compliance, and 21 CFR Part 11 electronic records requirements.',
    `ctd_section_code` STRING COMMENT 'The CTD module and section code designating where this document is placed within the eCTD structure (e.g., Module 1.2, Module 5.3.5.1). Aligns with ICH M4 CTD table of contents.. Valid values are `^[1-5](.[0-9]+(.[0-9]+(.[0-9]+)?)?)?$`',
    `ctd_section_title` STRING COMMENT 'Human-readable title of the CTD section corresponding to the ctd_section_code (e.g., Tabular Listing of All Clinical Studies, Clinical Overview). Supports navigation and inspection readiness.',
    `document_effective_date` DATE COMMENT 'The effective date of the document version included in this binder, as recorded at the time of inclusion. Supports regulatory review of document currency and applicability.',
    `document_role` STRING COMMENT 'The operational role of this document within the binder or eCTD sequence lifecycle: original (first inclusion), replacement (supersedes prior version), withdrawal (removes prior document), amendment, or addendum.. Valid values are `original|replacement|withdrawal|amendment|addendum`',
    `document_title` STRING COMMENT 'Title of the document as it appears in the binder or regulatory submission, captured at the time of inclusion. Provides human-readable identification without requiring a join to the document version table.',
    `document_version_number` STRING COMMENT 'Version number of the document at the time it was included in the binder (e.g., v1.0, v2.3, FINAL). Captured as a denormalized field to support point-in-time submission traceability without requiring a join.',
    `inclusion_rationale` STRING COMMENT 'Narrative explanation of why this specific document version was included in the binder or regulatory submission package. Supports regulatory justification and inspection readiness.',
    `inclusion_type` STRING COMMENT 'Classification of how the document is included in the binder: primary (core submission document), supporting (supplementary evidence), reference (cross-reference only), appendix, or cover (cover letter/page).. Valid values are `primary|supporting|reference|appendix|cover`',
    `inspection_readiness_status` STRING COMMENT 'Assessment of whether this documents binder inclusion meets inspection readiness standards: ready (fully compliant), gap_identified (deficiency noted), remediation_in_progress (corrective action underway), or not_assessed.. Valid values are `ready|gap_identified|remediation_in_progress|not_assessed`',
    `is_mandatory` BOOLEAN COMMENT 'Indicates whether this document is mandatory for the binder or regulatory submission per applicable guidelines (e.g., ICH E6 essential documents list, DIA TMF Reference Model required artifacts). True = mandatory; False = optional/supplementary.',
    `is_placeholder` BOOLEAN COMMENT 'Indicates whether this binder-document entry is a placeholder (document expected but not yet filed). True = placeholder awaiting document; False = actual document filed. Supports eTMF completeness tracking and inspection readiness.',
    `language_code` STRING COMMENT 'ISO 639-1 language code (optionally with ISO 3166-1 country subtag) of the document included in the binder (e.g., en, en-US, fr, ja). Relevant for multi-regional submissions to EMA, PMDA, Health Canada.. Valid values are `^[a-z]{2}(-[A-Z]{2})?$`',
    `notes` STRING COMMENT 'Free-text field for additional operational notes, cross-references, or contextual information about this documents inclusion in the binder that does not fit other structured fields.',
    `placeholder_due_date` DATE COMMENT 'Expected date by which the actual document must be filed to replace this placeholder entry. Applicable only when is_placeholder = True. Drives eTMF completeness alerts and inspection readiness dashboards.',
    `qc_comments` STRING COMMENT 'Free-text comments entered by the QC reviewer regarding the documents inclusion, any findings, or justification for waiver. Supports audit trail and CAPA tracking.',
    `qc_review_date` DATE COMMENT 'Date on which the QC review of this documents binder inclusion was completed. Used for inspection readiness reporting and submission timeline management.',
    `qc_review_status` STRING COMMENT 'Current QC review status of this documents inclusion in the binder: pending (awaiting review), in_review (actively being reviewed), approved (QC passed), rejected (QC failed, requires remediation), or waived (QC formally waived with justification).. Valid values are `pending|in_review|approved|rejected|waived`',
    `redaction_required` BOOLEAN COMMENT 'Indicates whether this document requires redaction of personally identifiable or commercially sensitive information before inclusion in a public or semi-public regulatory submission. True = redaction required; False = no redaction needed.',
    `regulatory_authority` STRING COMMENT 'The regulatory authority to which this binder or eCTD submission is directed (e.g., FDA, EMA, MHRA, PMDA). Determines applicable submission format and content requirements.',
    `removal_reason` STRING COMMENT 'Narrative explanation for why this document was removed or withdrawn from the binder (e.g., superseded by updated version, filed in error, regulatory authority request). Required when removed_date is populated.',
    `removed_date` DATE COMMENT 'Date on which this document was formally removed or withdrawn from the binder. Null if the document remains active in the binder. Supports full lifecycle traceability.',
    `sequence_order` BIGINT COMMENT 'Numeric position of this document within the binder or eCTD section, defining the presentation order for regulatory reviewers and inspection readiness.',
    `submission_sequence_number` STRING COMMENT 'The four-digit eCTD sequence number (e.g., 0000, 0001) identifying the specific regulatory submission sequence in which this document was included. Aligns with FDA and EMA eCTD technical specifications.. Valid values are `^[0-9]{4}$`',
    `submission_type` STRING COMMENT 'Type of regulatory submission this binder supports: IND (Investigational New Drug), NDA (New Drug Application), BLA (Biologics License Application), MAA (Marketing Authorization Application), CTA (Clinical Trial Authorization), or amendment/supplement',
    `tmf_reference_model_artifact` STRING COMMENT 'The specific DIA TMF Reference Model artifact identifier (e.g., 01.01.01 - Protocol) assigned to this document within the eTMF structure. Enables artifact-level completeness tracking.',
    `tmf_reference_model_zone` STRING COMMENT 'The DIA TMF Reference Model zone classification for this document (e.g., Zone 01 - Trial Management, Zone 04 - Investigational Product). Supports eTMF completeness and inspection readiness tracking.',
    `translation_required` BOOLEAN COMMENT 'Indicates whether a translation of this document is required for the target regulatory authoritys submission. True = translation required; False = no translation needed. Supports multi-regional submission planning.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this binder-document association record. Supports change tracking, audit trail, and silver layer incremental load processing.',
    `vault_binder_reference` STRING COMMENT 'The native binder identifier assigned by Veeva Vault to the parent binder record. Enables reconciliation between the lakehouse silver layer and the Veeva Vault system of record.',
    `vault_document_reference` STRING COMMENT 'The native document identifier assigned by Veeva Vault to the source document record. Enables direct traceability back to the system of record for audit and reconciliation purposes.',
    CONSTRAINT pk_binder_document PRIMARY KEY(`binder_document_id`)
) COMMENT 'Association entity linking individual documents to a regulatory binder or eCTD sequence. Captures the binder, the document version included, the CTD section (e.g., Module 1.2, Module 5.3.5.1), sequence order, inclusion rationale, QC review status, and the';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`document`.`archival_record` (
    `archival_record_id` BIGINT COMMENT 'Unique system-generated identifier for each archival record entry tracking the disposition of a TMF document or study file at study close-out.',
    `archival_authorized_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Archival authorization must be traceable to a qualified employee under ICH E6 and 21 CFR Part 11 — inspectors verify authorization authority.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this archival record applies. Enables study-level archival compliance reporting.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site whose documents are being archived, if applicable. Null for sponsor-level TMF documents.',
    `tmf_artifact_id` BIGINT COMMENT 'Foreign key linking to document.tmf_artifact. Business justification: Archival records reference the DIA TMF Reference Model artifact classification for retention period determination and regulatory compliance.',
    `tmf_document_id` BIGINT COMMENT 'Reference to the TMF document or study file record being archived. Links to the source document entity in the document management domain.',
    `version_id` BIGINT COMMENT 'Foreign key linking to document.document_version. Business justification: Archival records capture the disposition of a specific document version at study close-out. The document_version STRING column is a denormalized reference.',
    `archival_date` DATE COMMENT 'The date on which the document or study file was formally transferred to the archive. This is the principal business event date for the archival transaction, distinct from the record creation timestamp.',
    `archival_location` STRING COMMENT 'Physical or electronic location where the archived document is stored. For physical archives, this includes the facility name, building, room, shelf, and box reference.',
    `archival_notes` STRING COMMENT 'Free-text field for recording additional context, exceptions, or special instructions related to the archival record (e.g., partial document archival, known deviations from standard archival procedures, special handling instructions).',
    `archival_status` STRING COMMENT 'Current lifecycle status of the archival record. pending = awaiting archival; archived = successfully archived; retrieved = temporarily retrieved from archive; destroyed = permanently destroyed per retention schedule; on_hold = destruction or. Valid values are `pending|archived|retrieved|destroyed|on_hold`',
    `archival_type` STRING COMMENT 'Indicates whether the document is archived electronically (eTMF/long-term electronic archive), physically (paper-based archive facility), or as a hybrid (both electronic and physical copies retained).. Valid values are `electronic|physical|hybrid`',
    `archive_facility_name` STRING COMMENT 'Name of the physical or electronic archive facility or vendor responsible for storing the archived documents (e.g., Iron Mountain, sponsor internal archive, Veeva Vault long-term archive). Supports vendor management and retrieval logistics.',
    `archive_reference_number` STRING COMMENT 'Externally-known unique reference number assigned to the archived document or file by the archive facility or eTMF system (e.g., Veeva Vault document ID or physical archive box/folder reference). Used for retrieval and audit trail purposes.',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the jurisdiction whose regulatory requirements govern the retention and archival of this document (e.g., USA, GBR, DEU, JPN). Determines applicable retention regulations.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this archival record was first created in the system. Supports audit trail requirements per 21 CFR Part 11 and ALCOA+ principles (Attributable, Legible, Contemporaneous, Original, Accurate).',
    `custodian_name` STRING COMMENT 'Name of the organization or individual currently responsible for the custody and safekeeping of the archived documents (e.g., sponsor name, CRO name, third-party archive vendor). Supports accountability and retrieval logistics.',
    `custody_transfer_date` DATE COMMENT 'Date on which formal custody of the archived documents was transferred to the sponsor or designated archive custodian. Null if transfer has not occurred. Supports chain of custody documentation.',
    `database_lock_date` DATE COMMENT 'The date on which the clinical database was locked for the study, which may serve as the reference date for calculating retention periods for certain document categories per sponsor SOPs.',
    `destruction_authorization_number` STRING COMMENT 'Unique reference number of the formal destruction authorization document or approval record that sanctioned the permanent destruction of the archived file. Provides the audit trail required by GCP and regulatory agencies.',
    `destruction_authorized_by` STRING COMMENT 'Name or identifier of the authorized individual (e.g., sponsor representative, QA director) who formally approved the destruction of the archived document. Required for GCP compliance and regulatory inspection readiness.',
    `destruction_date` DATE COMMENT 'The actual date on which the archived document was permanently destroyed following expiry of the retention period and completion of the destruction authorization process. Null if document has not been destroyed.',
    `destruction_method` STRING COMMENT 'The method used to permanently destroy the archived document upon expiry of the retention period (e.g., shredding for physical documents, secure digital deletion or degaussing for electronic records). Required for GCP compliance audit trail.. Valid values are `shredding|incineration|secure_digital_deletion|degaussing|other`',
    `document_classification` STRING COMMENT 'Classification of the archived document per ICH GCP essential document categories (e.g., essential document, non-essential, regulatory submission document, site file, sponsor file). Determines applicable retention requirements.. Valid values are `essential_document|non_essential|regulatory_submission|site_file|sponsor_file`',
    `document_title` STRING COMMENT 'Human-readable title or name of the document or study file being archived, as recorded in the eTMF (Veeva Vault) or physical archive index.',
    `etmf_vault_document_reference` STRING COMMENT 'The unique document identifier assigned by Veeva Vault eTMF to the archived document. Enables direct traceability between the archival record in the lakehouse and the source document in the operational eTMF system.',
    `inspection_readiness_flag` BOOLEAN COMMENT 'Indicates whether this archival record and its associated document have been verified as inspection-ready (True) or require remediation before a regulatory inspection (False). Supports FDA, EMA, MHRA, and PMDA inspection preparation.',
    `litigation_hold_flag` BOOLEAN COMMENT 'Indicates whether a litigation hold (legal hold) has been placed on this archived document, preventing destruction regardless of retention expiry. True = document is under legal hold; False = no hold in effect.',
    `regulatory_authority` STRING COMMENT 'The primary regulatory authority whose requirements govern the archival and retention of this document (e.g., FDA, EMA, MHRA, PMDA, TGA, Health Canada). Drives jurisdiction-specific retention period and destruction rules.',
    `retention_basis` STRING COMMENT 'The regulatory or contractual basis that determines the retention period for this document. [ENUM-REF-CANDIDATE: ICH_GCP_15yr|FDA_21CFR_312.62|EMA_EU_CTR|sponsor_requirement|PMDA_requirement|MHRA_requirement|other — promote to reference product]',
    `retention_expiry_date` DATE COMMENT 'The calculated date on which the mandatory retention period expires and the document becomes eligible for destruction, based on the archival date plus the retention period. Drives destruction scheduling workflows.',
    `retention_period_years` BIGINT COMMENT 'The required retention period in years for the archived document, as determined by the applicable regulatory requirement or sponsor policy (e.g., 15 years per ICH GCP, 2 years post-NDA approval per 21 CFR 312.62, or longer per sponsor requirement).',
    `retrieval_date` DATE COMMENT 'Actual date on which the archived document was physically or electronically retrieved from the archive. Null if not yet retrieved. Distinct from retrieval_request_date to track turnaround time.',
    `retrieval_reason` STRING COMMENT 'The business reason for retrieving the archived document from the archive (e.g., regulatory inspection, audit, litigation, study amendment, sponsor request). Supports access control and audit trail requirements.. Valid values are `regulatory_inspection|audit|litigation|study_amendment|sponsor_request|other`',
    `retrieval_request_date` DATE COMMENT 'Date on which a formal request was made to retrieve the archived document from the archive facility. Null if no retrieval has been requested. Supports archive access tracking and SLA monitoring.',
    `sponsor_notification_date` DATE COMMENT 'Date on which the sponsor was formally notified of the archival or destruction of the document, as required by ICH GCP and applicable regulations. Null if notification is not required or not yet sent.',
    `study_closeout_date` DATE COMMENT 'The date on which the clinical study was formally closed out, triggering the archival obligations for TMF documents. Used to calculate retention period start dates and compliance deadlines.',
    `tmf_reference_model_zone` STRING COMMENT 'The DIA TMF Reference Model zone classification of the archived document (e.g., Zone 01 - Trial Management, Zone 02 - Central Trial Documents, Zone 03 - Regulatory, Zone 04 - IRB/IEC, Zone 05 - Site Management).',
    `transfer_of_custody_flag` BOOLEAN COMMENT 'Indicates whether custody of the archived documents has been formally transferred to the sponsor or a designated third-party archive (True) or remains with the CRO (False). Relevant for CRO-managed studies at close-out.',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time when this archival record was last modified. Supports audit trail requirements per 21 CFR Part 11 and ALCOA+ principles, enabling detection of unauthorized or unexpected record changes.',
    CONSTRAINT pk_archival_record PRIMARY KEY(`archival_record_id`)
) COMMENT 'Master entity tracking the archival disposition of TMF documents and study files at study close-out per ICH GCP requirements. Captures archival date, archival location (physical archive, long-term electronic archive), archive reference number, retention';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`document`.`access_log` (
    `access_log_id` BIGINT COMMENT 'Unique surrogate identifier for each document access event record in the audit trail. Primary key for the document_access_log table.',
    `electronic_signature_id` BIGINT COMMENT 'The unique identifier of the electronic signature applied during this access event, if the action required a signature (e.g., document approval, attestation). Links to the 21 CFR Part 11 compliant e-signature record in Veeva Vault.',
    `employee_id` BIGINT COMMENT 'The unique system identifier of the user who performed the access event, as recorded in Veeva Vault. Supports attribution requirement under ALCOA+ (Attributable) and 21 CFR Part 11 audit trail requirements.',
    `regulatory_inspection_id` BIGINT COMMENT 'regulatory',
    `study_id` BIGINT COMMENT 'Identifier of the clinical study (protocol) to which the accessed document belongs. Enables study-level access audit reporting and supports regulatory inspection queries by study.',
    `study_site_id` BIGINT COMMENT 'Identifier of the investigative site associated with the accessed document, if the document is site-specific (e.g., site regulatory binder, site file document). Null for central/sponsor-level documents.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: The document access log records access events to controlled documents. vault_document_id (STRING) is a Veeva Vault system reference, but there is no integer FK to tmf_document.',
    `vault_document_version_id` BIGINT COMMENT 'The specific version identifier of the document in Veeva Vault that was accessed (e.g., 1.0, 2.1, DRAFT). Ensures the audit trail captures exactly which version was viewed, downloaded, or modified, supporting ALCOA+ traceability.',
    `access_action` STRING COMMENT 'The type of action performed on the document during this access event. Enumerated values: view (read-only display), download (file retrieved to local device), print (document sent to printer), edit (document content modified), delete (document removed or. Valid values are `view|download|print|edit|delete`',
    `access_channel` STRING COMMENT 'The interface or channel through which the document was accessed in Veeva Vault: web_browser (standard UI), vault_api (programmatic API access), mobile_app (Veeva Vault mobile), integration (system-to-system integration).. Valid values are `web_browser|vault_api|mobile_app|integration`',
    `access_device_type` STRING COMMENT 'The category of device used to access the document (desktop, laptop, tablet, mobile, server). Supports security monitoring and access pattern analysis for GCP inspection readiness.. Valid values are `desktop|laptop|tablet|mobile|server`',
    `access_justification` STRING COMMENT 'The business reason provided by the user for accessing a restricted or confidential document, as required by document confidentiality policy. Mandatory for restricted-level documents; optional for confidential.',
    `access_result` STRING COMMENT 'The outcome of the access attempt: success (access granted and action completed), denied (access refused due to permissions), error (system error prevented completion), timeout (session expired before completion).. Valid values are `success|denied|error|timeout`',
    `access_timestamp` TIMESTAMP COMMENT 'The exact date and time (with timezone) when the document access event occurred, as recorded by Veeva Vault. Satisfies the ALCOA+ Contemporaneous requirement and 21 CFR Part 11 audit trail timestamp mandate. Format: yyyy-MM-ddTHH:mm:ss.SSSXXX.',
    `anomaly_reason` STRING COMMENT 'A description of why this access event was flagged as anomalous, populated when is_anomalous_access is True. Examples: Access outside business hours, Bulk download detected, Access from unrecognized IP, Access to superseded document version.',
    `data_extract_timestamp` TIMESTAMP COMMENT 'The timestamp when this audit record was extracted from Veeva Vault and loaded into the Databricks Silver Layer. Supports data lineage tracking and ETL reconciliation for the lakehouse pipeline.',
    `document_confidentiality_level` STRING COMMENT 'The data classification level of the document at the time of access. Determines whether an access justification is required (restricted and confidential documents require justification per policy). Aligns with the business data classification levels.. Valid values are `restricted|confidential|internal|public`',
    `document_name` STRING COMMENT 'The title or name of the controlled document at the time of access, captured as a denormalized snapshot. Ensures the audit record remains interpretable even if the document is renamed or archived.',
    `document_status_at_access` STRING COMMENT 'The lifecycle status of the document at the exact moment of access. Captures whether the user accessed a draft, approved, superseded, or archived version, which is critical for GCP compliance and inspection readiness.. Valid values are `draft|in_review|approved|superseded|obsolete|archived`',
    `document_type` STRING COMMENT 'The classification of the document accessed per the DIA TMF Reference Model or Veeva Vault document type taxonomy (e.g., Protocol, Informed Consent Form, Investigator Brochure, Site Initiation Visit Report, Regulatory Submission).',
    `document_version_number` STRING COMMENT 'The human-readable version label of the document accessed (e.g., 1.0, 2.3, DRAFT, FINAL). Captured as a denormalized snapshot for audit readability without requiring a join to the document version table.',
    `download_file_format` STRING COMMENT 'The file format in which the document was downloaded, applicable only when access_action is download. Null for non-download actions. Supports data leakage monitoring and controlled document distribution tracking.. Valid values are `PDF|DOCX|XLSX|CSV|XML|other`',
    `inspection_context` BOOLEAN COMMENT 'Indicates whether this access event occurred in the context of a regulatory inspection (e.g., FDA, EMA, MHRA audit). True when the access was performed to support an active regulatory inspection. Enables inspection-specific access pattern reporting.',
    `is_anomalous_access` BOOLEAN COMMENT 'Indicates whether this access event has been flagged as anomalous by automated monitoring rules (e.g., access outside business hours, access from unusual IP, bulk download, access to superseded documents).',
    `justification_provided` BOOLEAN COMMENT 'Indicates whether the user actually provided an access justification when one was required. Used in conjunction with justification_required to identify compliance gaps where justification was mandated but not supplied.',
    `justification_required` BOOLEAN COMMENT 'Indicates whether an access justification was required for this access event based on the documents confidentiality level and access action. True when justification was mandated by policy; False otherwise. Supports compliance gap detection.',
    `print_copy_count` BIGINT COMMENT 'The number of copies printed during a print access event. Applicable only when access_action is print. Null for non-print actions. Supports controlled document print tracking per GCP requirements.',
    `prior_access_timestamp` TIMESTAMP COMMENT 'The timestamp of the immediately preceding access event by the same user on the same document version. Enables detection of unusual access frequency patterns and supports forensic audit analysis.',
    `record_created_timestamp` TIMESTAMP COMMENT 'The timestamp when this record was first created in the Silver Layer data product. Supports data lineage and audit trail for the lakehouse record itself, distinct from the access_timestamp which records the business event time.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this record was last updated in the Silver Layer data product. Supports data lineage tracking and identifies records that have been corrected or enriched post-initial load.',
    `regulatory_authority` STRING COMMENT 'The regulatory authority under whose jurisdiction this access event is most relevant, particularly for inspection-context accesses. Supports multi-jurisdictional regulatory reporting (FDA, EMA, MHRA, PMDA, TGA, Health Canada).',
    `retention_expiry_date` DATE COMMENT 'The date on which this audit log record is eligible for archival or deletion, aligned with the retention period of the parent document. Per ICH E6(R2), TMF records must be retained for at least 2 years after the last marketing approval or study',
    `signature_meaning` STRING COMMENT 'The meaning associated with the electronic signature applied during this access event, per 21 CFR Part 11 requirements (e.g., approved, reviewed, authored, witnessed). Null if no signature was applied.. Valid values are `approved|reviewed|authored|witnessed`',
    `source_ip_address` STRING COMMENT 'The IP address of the device from which the document access event originated. Required for 21 CFR Part 11 audit trail completeness and cybersecurity monitoring. May be considered PII under GDPR in some jurisdictions.',
    `study_protocol_number` STRING COMMENT 'The sponsor-assigned protocol number of the clinical study associated with the accessed document, captured as a denormalized snapshot. Enables direct audit trail readability without requiring a join to the study table.',
    `tmf_section` STRING COMMENT 'The specific section identifier within the TMF zone for the accessed document per the DIA TMF Reference Model (e.g., 01.01 Trial Oversight, 03.01 Regulatory Approvals). Enables granular TMF access pattern analysis.',
    `tmf_zone` STRING COMMENT 'The TMF zone classification of the accessed document per the DIA TMF Reference Model (e.g., Zone 01 - Trial Management, Zone 02 - Central Trial Documents, Zone 03 - Regulatory, Zone 04 - IRB/IEC, Zone 05 - Site Management).',
    `user_full_name` STRING COMMENT 'The full name of the user who performed the access event at the time of the event. Captured as a denormalized field to preserve the audit record even if the user record changes, per ALCOA+ contemporaneous and enduring requirements.',
    `user_organization` STRING COMMENT 'The organization or company affiliation of the user at the time of access (e.g., sponsor name, CRO name, investigative site name). Supports multi-sponsor and multi-site access auditing.',
    `user_role` STRING COMMENT 'The business role of the user at the time of the access event (e.g., Principal Investigator, Clinical Research Associate, Data Manager, Regulatory Affairs Specialist, Sponsor Representative).',
    `vault_audit_trail_reference` STRING COMMENT 'The native audit trail record identifier generated by Veeva Vault for this access event. Serves as the source system reference key enabling traceability back to the original immutable audit record in Veeva Vault for regulatory inspection purposes.',
    `vault_document_reference` STRING COMMENT 'The native document identifier assigned by Veeva Vault to the controlled document that was accessed. Serves as the primary reference to the source document record in the eTMF/regulatory system.',
    `vault_session_reference` STRING COMMENT 'The Veeva Vault session identifier associated with this access event. Enables correlation of multiple access events within a single user session for forensic audit analysis and inspection support.',
    CONSTRAINT pk_access_log PRIMARY KEY(`access_log_id`)
) COMMENT 'Business compliance audit trail recording access events to controlled documents in Veeva Vault per 21 CFR Part 11 requirements. Each record captures: user identity, user role, access action (view, download, print, edit, delete), document version accessed';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` (
    `etmf_exchange_id` BIGINT COMMENT 'Unique surrogate identifier for each eTMF document exchange transaction record in the Databricks Silver Layer. Primary key for this entity. Role: TRANSACTION_HEADER.',
    `clinical_program_id` BIGINT COMMENT 'Foreign key linking to program.clinical_program. Business justification: Program-level eTMF transfers occur at program closeout or partnership handover (e.g., full program TMF transfer from CRO to sponsor).',
    `master_agreement_id` BIGINT COMMENT 'Foreign key linking to sponsor.master_agreement. Business justification: eTMF exchange protocols between sponsor and CRO are governed by master agreements (eTMF plan reference in MSA). Linking enables tracking which MSA governs each exchange.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization involved in this eTMF exchange. Represents the primary counterparty in the exchange transaction. Satisfies TRANSACTION_HEADER PARTY_REFERENCE category.',
    `resubmission_of_exchange_id` BIGINT COMMENT 'Reference to document.etmf_exchange.etmf_exchange_id.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) for which eTMF documents are being exchanged. Links the exchange transaction to the governing study protocol.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking this exchange document item to the specific TMF document included in the exchange',
    `acknowledgement_timestamp` TIMESTAMP COMMENT 'Timestamp when the receiving party (typically the sponsor) formally acknowledged receipt of the eTMF document package. Critical for demonstrating sponsor oversight obligations under ICH GCP 5.0 and for regulatory inspection readiness.',
    `archival_flag` BOOLEAN COMMENT 'Indicates whether this eTMF exchange represents a final archival transfer of study documents at study close-out. True = archival transfer per ICH GCP retention requirements.',
    `checksum_algorithm` STRING COMMENT 'The cryptographic hash algorithm used to generate the package integrity checksum (e.g., MD5, SHA-256). Supports data integrity verification per 21 CFR Part 11 and ALCOA+ requirements.. Valid values are `MD5|SHA-1|SHA-256|SHA-512`',
    `checksum_value` DECIMAL(18,2) COMMENT 'The computed cryptographic hash value of the eTMF document package used to verify data integrity upon receipt. Enables detection of data corruption or tampering during transfer.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this eTMF exchange record was first captured in the system. Supports audit trail and ALCOA+ compliance requirements. Satisfies TRANSACTION_HEADER RECORD_AUDIT_CREATED category.',
    `dmp_version` STRING COMMENT 'The version of the Data Management Plan (DMP) governing the eTMF exchange procedures at the time of this transaction. Ensures traceability to the applicable procedural document.',
    `document_count` BIGINT COMMENT 'Total number of individual documents included in the eTMF exchange package. Used for completeness verification and reconciliation upon receipt.',
    `encryption_method` STRING COMMENT 'The encryption standard applied to the eTMF document package during transfer. Ensures confidentiality of trial documents in transit per regulatory data security requirements.. Valid values are `AES-256|PGP|TLS_1_2|TLS_1_3|none`',
    `exchange_date` TIMESTAMP COMMENT 'The principal real-world timestamp when the eTMF document exchange was initiated or executed. Represents the business event time of the transfer, distinct from system audit timestamps. Satisfies TRANSACTION_HEADER BUSINESS_EVENT_TIMESTAMP category.',
    `exchange_direction` STRING COMMENT 'Indicates the direction of the eTMF document transfer: from the Contract Research Organization (CRO) to the sponsor, or from the sponsor to the CRO. Critical for demonstrating sponsor oversight obligations under ICH GCP 5.0.. Valid values are `cro_to_sponsor|sponsor_to_cro`',
    `exchange_frequency` STRING COMMENT 'The agreed cadence for eTMF document exchanges between CRO and sponsor as defined in the eTMF exchange agreement. Used for scheduling and compliance monitoring.. Valid values are `weekly|monthly|quarterly|milestone|ad_hoc`',
    `exchange_manifest_reference` STRING COMMENT 'Identifier of the exchange manifest file accompanying the document package. The manifest lists all documents, metadata, and checksums included in the transfer per DIA eTMF Exchange Mechanism Standard.',
    `exchange_notes` STRING COMMENT 'Free-text field for additional context, instructions, or comments associated with this eTMF exchange transaction. May include special handling instructions or regulatory context.',
    `exchange_reference_number` STRING COMMENT 'Externally-known business identifier for the exchange transaction, typically generated by Veeva Vault or the initiating system. Used for cross-system reconciliation between CRO and sponsor. Satisfies TRANSACTION_HEADER BUSINESS_IDENTIFIER category.',
    `exchange_type` STRING COMMENT 'Classification of the exchange transaction by business purpose: routine scheduled transfer, ad hoc request, inspection-driven transfer, study close-out package, or interim milestone transfer.. Valid values are `routine|ad_hoc|inspection|closeout|interim`',
    `inclusion_reason` STRING COMMENT 'The business reason why this specific document was included in this exchange transaction. Supports audit trail requirements and sponsor oversight documentation under ICH GCP 5.0.',
    `initiating_party` STRING COMMENT 'Identifies whether the CRO or the sponsor organization initiated this eTMF exchange transaction. Distinct from exchange direction — captures who triggered the transfer.. Valid values are `cro|sponsor`',
    `inspection_readiness_flag` BOOLEAN COMMENT 'Indicates whether this eTMF exchange was executed as part of an inspection readiness activity (e.g., pre-FDA inspection TMF transfer to sponsor). True = inspection-driven exchange.',
    `integrity_verified` BOOLEAN COMMENT 'Indicates whether the receiving party has verified the cryptographic checksum of the received package matches the senders declared checksum. True = integrity confirmed; False = mismatch detected.',
    `package_name` STRING COMMENT 'Human-readable name or label assigned to the document package included in this exchange transaction. Used for identification and tracking of the transferred document bundle.',
    `package_size_mb` DECIMAL(10,3) COMMENT 'Total file size of the eTMF document exchange package in megabytes. Used for transfer capacity planning, SLA monitoring, and troubleshooting failed transfers.',
    `protocol_version` STRING COMMENT 'The version of the study protocol applicable to the documents included in this eTMF exchange package. Ensures documents are associated with the correct protocol amendment.',
    `received_timestamp` TIMESTAMP COMMENT 'Timestamp when the receiving system confirmed technical receipt of the eTMF document package. Distinct from acknowledgement_timestamp which represents formal business acknowledgement.',
    `receiver_contact_name` STRING COMMENT 'Name of the responsible individual at the receiving organization who acknowledged or processed the eTMF exchange. Used for accountability and follow-up communications.',
    `receiver_vault_reference` STRING COMMENT 'The Veeva Vault instance identifier of the receiving organization (sponsor or CRO). Used for cross-account transfer reconciliation and confirmation of receipt in Veeva Vault eTMF.',
    `regulatory_region` STRING COMMENT 'The regulatory jurisdiction(s) applicable to the documents in this eTMF exchange (e.g., US, EU, JP). Determines applicable regulatory standards for document format and retention requirements.',
    `rejection_code` STRING COMMENT 'Standardized code categorizing the reason for rejection of the eTMF document package (e.g., MISSING_DOCS, WRONG_VERSION, METADATA_ERROR). Enables systematic tracking and trending of rejection causes.',
    `rejection_reason` STRING COMMENT 'Free-text or coded reason provided when the receiving party rejects the eTMF document package. Populated only when transfer_status is rejected. Supports CAPA and resubmission workflows.',
    `scheduled_exchange_date` DATE COMMENT 'The planned date on which the eTMF document exchange was scheduled to occur per the eTMF exchange agreement or data management plan. Used for SLA monitoring and deviation tracking.',
    `sender_contact_name` STRING COMMENT 'Name of the responsible individual at the sending organization who initiated or authorized the eTMF exchange. Used for accountability and follow-up communications.',
    `sender_vault_reference` STRING COMMENT 'The Veeva Vault instance identifier of the sending organization (CRO or sponsor). Used for cross-account transfer reconciliation and audit trail in Veeva Vault eTMF.',
    `sequence_order` BIGINT COMMENT 'The ordinal position of this document within the exchange package manifest. Used for package integrity verification and reconciliation against the exchange manifest file.',
    `study_phase` STRING COMMENT 'The clinical development phase of the study associated with this eTMF exchange. Used for regulatory reporting stratification and TMF completeness benchmarking.. Valid values are `Phase I|Phase II|Phase III|Phase IV|Phase I/II`',
    `tmf_artifact_type` STRING COMMENT 'The DIA TMF Reference Model artifact type designation for the primary document type in this exchange package (e.g., Protocol, Informed Consent Form, Investigator Brochure). Supports TMF completeness tracking.',
    `tmf_section` STRING COMMENT 'The DIA TMF Reference Model section identifier for the documents included in this exchange (e.g., 01, 02, 03). Provides granular classification within the TMF zone for inspection readiness.',
    `tmf_zone` STRING COMMENT 'The DIA TMF Reference Model zone classification of the documents included in this exchange package. Zones include Trial Management, Site Management, and Investigational Product (IP) Management.. Valid values are `trial_management|site_management|ip_management`',
    `transfer_method` STRING COMMENT 'The technical mechanism used to transfer the eTMF document package between CRO and sponsor. Includes Veeva Vault cross-account transfer, SFTP, API integration, manual upload, or secure email.. Valid values are `veeva_vault_cross_account|sftp|api|manual_upload|secure_email`',
    `transfer_status` STRING COMMENT 'Current workflow state of the eTMF document exchange transaction. Tracks the lifecycle from initiation through sponsor acknowledgement or rejection. Satisfies TRANSACTION_HEADER LIFECYCLE_STATUS category.. Valid values are `initiated|in_transit|received|acknowledged|rejected`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this eTMF exchange record was last modified. Supports audit trail and change tracking for regulatory inspection readiness. Satisfies TRANSACTION_HEADER RECORD_AUDIT_UPDATED category.',
    `veeva_vault_job_reference` STRING COMMENT 'The job or transaction identifier assigned by Veeva Vault for the cross-account eTMF transfer operation. Used for technical reconciliation and support troubleshooting with Veeva.',
    `version_at_exchange` STRING COMMENT 'The version label of the TMF document that was actually included and transferred in this exchange. Critical for regulatory traceability — the document may have been updated since the exchange, so the version transferred must be recorded on the',
    CONSTRAINT pk_etmf_exchange PRIMARY KEY(`etmf_exchange_id`)
) COMMENT 'Tracks eTMF document exchange transactions between CRO and sponsor organizations per the DIA eTMF Exchange Mechanism Standard. Each record represents a discrete transfer event: exchange direction (CRO-to-sponsor, sponsor-to-CRO), document package';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`document`.`document_icf_version` (
    `document_icf_version_id` BIGINT COMMENT 'Unique surrogate identifier for each Informed Consent Form (ICF) document version record in the Trial Master File (TMF). Primary key for this entity.',
    `prepared_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: ICF preparation must be traceable to a qualified employee — IRBs and regulatory inspectors verify preparer qualifications and GCP training.',
    `regulatory_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to regulatory.protocol_amendment. Business justification: ICF versions are created in response to protocol amendments (reconsent_required_flag).',
    `superseded_by_version_document_icf_version_id` BIGINT COMMENT 'Self-referencing identifier pointing to the newer ICF version that replaced this one. Enables version chain traceability for audit and inspection readiness.',
    `tmf_artifact_id` BIGINT COMMENT 'Foreign key linking to document.tmf_artifact. Business justification: ICF versions are classified under specific DIA TMF Reference Model artifacts (e.g., Zone 1, Section 1.3 - Informed Consent Forms).',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: An ICF version is a specific controlled document filed in the TMF. Linking document_icf_version to its master tmf_document record enables TMF completeness tracking, inspection readiness',
    `version_id` BIGINT COMMENT 'Foreign key linking to document.document_version. Business justification: Each ICF version corresponds to a controlled document version in the version history table.',
    `amendment_reason` STRING COMMENT 'Narrative description of the reason this ICF version was created or amended (e.g., new safety information, protocol change, regulatory request). Required for audit trail and inspection readiness.',
    `approval_timestamp` TIMESTAMP COMMENT 'The date and time at which this ICF version received final document control approval in Veeva Vault or MasterControl. Distinct from IRB approval date; this is the internal sponsor/CRO approval.',
    `approved_by` STRING COMMENT 'Name or user identifier of the individual (typically Medical Monitor or Sponsor representative) who provided final approval for this ICF version in the document control system. Supports ALCOA+ attributability.',
    `archival_date` DATE COMMENT 'The date on which this ICF version document was formally archived in the eTMF following study close-out. Marks the transition to long-term retention storage.',
    `cdisc_domain` STRING COMMENT 'The CDISC SDTM domain code associated with consent data derived from this ICF version (typically DS for Disposition or IC for Informed Consent domain per SDTM IG). Supports regulatory submission data mapping.. Valid values are `^[A-Z]{2}$`',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code indicating the country for which this ICF version is applicable. Supports country-specific regulatory and language requirements.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time at which this ICF version record was first created in the data system. Supports audit trail and ALCOA+ contemporaneous documentation requirements.',
    `document_status` STRING COMMENT 'Current lifecycle status of this ICF version within the document control system: draft (in preparation), under_review (pending IRB/IEC review), approved (authorized for use), superseded (replaced by newer version), retired (withdrawn), archived. Valid values are `draft|under_review|approved|superseded|retired|archived`',
    `document_title` STRING COMMENT 'The full official title of the ICF document as it appears in the Veeva Vault eTMF and on the consent form itself (e.g., Informed Consent Form for Study XYZ — Adult Population — Version 2.0).',
    `econsent_enabled` BOOLEAN COMMENT 'Indicates whether this ICF version is configured for electronic consent (eConsent) delivery via Clinpal or equivalent eConsent platform, as opposed to paper-based consent.',
    `econsent_platform` STRING COMMENT 'The eConsent platform used to deliver this ICF version electronically (e.g., Clinpal, Medidata Rave, the source system Null or paper if consent is obtained via traditional paper process.. Valid values are `clinpal|medidata_rave|oracle_clinical_one|paper|other`',
    `effective_date` DATE COMMENT 'The date from which this ICF version is authorized for use in subject enrollment and re-consent activities. May differ from the IRB approval date if a site-specific activation step is required.',
    `gdpr_applicable` BOOLEAN COMMENT 'Indicates whether GDPR data privacy provisions apply to this ICF version (i.e., the ICF covers subjects in EU/EEA countries). Drives inclusion of GDPR-specific consent language.',
    `hipaa_applicable` BOOLEAN COMMENT 'Indicates whether HIPAA authorization provisions apply to this ICF version (i.e., the ICF covers subjects at U.S. sites). Drives inclusion of HIPAA-specific authorization language.',
    `icf_type` STRING COMMENT 'Categorizes the ICF document by its consent purpose: main_consent (primary study consent), assent (pediatric assent form), hipaa_authorization (HIPAA privacy authorization), optional_procedures (consent for optional study procedures), lar_consent (Legally. Valid values are `main_consent|assent|hipaa_authorization|optional_procedures|lar_consent|short_form`',
    `irb_approval_date` DATE COMMENT 'The date on which the IRB or IEC formally approved this ICF version for use. No subject may be consented using this version prior to this date.',
    `irb_expiry_date` DATE COMMENT 'The date on which the IRB/IEC approval for this ICF version expires. After this date, the ICF version is no longer valid for obtaining new consents unless renewed.',
    `is_current_version` BOOLEAN COMMENT 'Indicates whether this is the currently active and approved ICF version for the applicable study, population, language, and country combination. Only one version per combination should be True at any time.',
    `is_inspection_ready` BOOLEAN COMMENT 'Indicates whether this ICF version record and its associated Vault document are confirmed as inspection-ready (complete, filed, and verified). Used for regulatory inspection preparedness tracking.',
    `language_code` STRING COMMENT 'ISO 639-1/639-2 language code indicating the language in which this ICF version is written (e.g., en, fr, es, zh-CN). Ensures subjects receive consent in their primary language per GCP requirements.. Valid values are `^[a-z]{2,3}(-[A-Z]{2})?$`',
    `protocol_version_number` STRING COMMENT 'The protocol version number (e.g., 3.0, Amendment 2) that this ICF version is aligned with. Ensures the consent document reflects the current study procedures and risks.. Valid values are `^[A-Za-z0-9._-]{1,20}$`',
    `reconsent_deadline` DATE COMMENT 'The date by which all applicable enrolled subjects must be re-consented using this ICF version. Applicable only when reconsent_required is True.',
    `reconsent_required` BOOLEAN COMMENT 'Indicates whether subjects previously enrolled under an earlier ICF version must be re-consented using this version. Driven by the nature of the amendment (e.g., new safety risks).',
    `retention_end_date` DATE COMMENT 'The date after which this ICF document record may be destroyed per applicable regulatory retention requirements (typically 2 years after last marketing approval or 15 years per ICH E6). Supports records management compliance.',
    `sponsor_provided` BOOLEAN COMMENT 'Indicates whether this ICF version was provided by the sponsor as a template (True) or was independently developed by the site/CRO (False). Relevant for sponsor oversight and TMF filing responsibilities.',
    `subject_population` STRING COMMENT 'Identifies the target subject population for which this ICF version is applicable: adult, pediatric, lar (Legally Authorized Representative), adolescent, or geriatric. Drives which consent form is presented during enrollment.. Valid values are `adult|pediatric|lar|adolescent|geriatric`',
    `superseded_date` DATE COMMENT 'The date on which this ICF version was superseded by a newer version. After this date, new consents must use the replacement version; existing consented subjects may require re-consent.',
    `tmf_zone` STRING COMMENT 'The DIA TMF Reference Model zone under which this ICF document is filed (typically site_management for ICF documents). Supports TMF structure compliance and inspection readiness.',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time at which this ICF version record was last modified. Supports audit trail integrity and change tracking per ALCOA+ requirements.',
    `vault_document_number` STRING COMMENT 'The human-readable document number assigned by Veeva Vault, used for cross-referencing in regulatory binders and inspection readiness activities.',
    `vault_document_reference` STRING COMMENT 'The unique document identifier assigned by Veeva Vault (eTMF system) to this ICF version. Used to retrieve the source document from the electronic Trial Master File (eTMF).',
    `vault_lifecycle_state` STRING COMMENT 'The specific lifecycle state label as defined in Veeva Vaults document lifecycle configuration (e.g., Draft, In Review, Approved, Superseded). Distinct from document_status as it reflects the exact Vault workflow state.',
    CONSTRAINT pk_document_icf_version PRIMARY KEY(`document_icf_version_id`)
) COMMENT 'Master entity for Informed Consent Form (ICF) document versions managed within the TMF and document control system. Captures ICF version number, version date, IRB/IEC approval date, applicable subject population (adult, pediatric, LAR), language';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`document`.`template` (
    `template_id` BIGINT COMMENT 'Unique surrogate identifier for the document template record in the Clinical Trials data lakehouse. Primary key for the document_template entity.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.sop. Business justification: Document templates are created, maintained, and used per governing SOPs. The QMS SOP dictates template format, approval requirements, and usage rules.',
    `owner_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Document template ownership is a GCP-required accountability — the owner is responsible for template currency, review cycles, and retirement.',
    `primary_superseded_by_template_id` BIGINT COMMENT 'Reference to the document_template_id of the newer template version that supersedes this one. Null if this is the current active version. Enables version chain traceability for audit and inspection readiness purposes.',
    `tmf_artifact_id` BIGINT COMMENT 'Foreign key linking to document.tmf_artifact. Business justification: Document templates are designed for specific DIA TMF Reference Model artifact types. Linking document_template to tmf_artifact normalizes the artifact classification and enables queries',
    `applicability_scope` STRING COMMENT 'Defines the geographic or organizational scope for which this template is applicable. GLOBAL=all studies worldwide, REGIONAL=specific regulatory region (e.g., EU, US), COUNTRY_SPECIFIC=single country, SPONSOR_SPECIFIC=for a particular sponsor. Valid values are `GLOBAL|REGIONAL|COUNTRY_SPECIFIC|SPONSOR_SPECIFIC|THERAPEUTIC_AREA_SPECIFIC|PHASE_SPECIFIC`',
    `applicable_study_phase` STRING COMMENT 'Clinical development phase(s) for which this template is designed and approved. Ensures phase-appropriate content and regulatory requirements are embedded in the template (e.g., Phase I first-in-human ICF templates differ from Phase III pivotal trial. Valid values are `PHASE_I|PHASE_II|PHASE_III|PHASE_IV|ALL_PHASES`',
    `applicable_therapeutic_area` STRING COMMENT 'Therapeutic area or disease indication for which this template is specifically designed (e.g., Oncology, Cardiology, Neurology, Rare Disease, Infectious Disease, ALL). Null or ALL indicates a cross-therapeutic template.',
    `approval_date` DATE COMMENT 'Date on which this template version received final QA/regulatory approval and was authorized for use. Distinct from effective_date (when it becomes active for use). Required for GCP-compliant controlled document audit trail per ALCOA+ principles.',
    `approved_by` STRING COMMENT 'Name or employee identifier of the individual who provided final approval for this template version (typically QA Director, Head of Regulatory Affairs, or designated approver per SOP).',
    `archival_date` DATE COMMENT 'Date on which this template was moved to archival status in Veeva Vault following retirement or supersession. Archived templates are retained for the regulatory retention period but are no longer available for active use.',
    `cdisc_standard_reference` STRING COMMENT 'Reference to the applicable CDISC standard that this template supports or implements (e.g., SDTM v1.8, ADaM v1.3, CDASH v2.0, Protocol Representation Model).',
    `change_description` STRING COMMENT 'Summary of changes made in this version compared to the prior version (e.g., Updated ICF language to reflect FDA guidance on electronic consent; added GDPR data transfer clause).',
    `change_reason` STRING COMMENT 'Categorized reason driving the creation of this template version. REGULATORY_UPDATE=new or revised regulatory guidance, PROCESS_IMPROVEMENT=internal process optimization, ERROR_CORRECTION=correction of errors in prior version. Valid values are `REGULATORY_UPDATE|PROCESS_IMPROVEMENT|ERROR_CORRECTION|SPONSOR_REQUIREMENT|PERIODIC_REVIEW|INITIAL_CREATION`',
    `template_code` STRING COMMENT 'Externally-known, human-readable unique code assigned to the template (e.g., ICF-TMPL-00042). Used as the business identifier across systems including Veeva Vault and MasterControl for cross-system referencing and audit trails.. Valid values are `^[A-Z]{2,10}-TMPL-[0-9]{4,8}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this document template record was first created in the system, in ISO 8601 format with timezone offset. Supports ALCOA+ audit trail requirements and data lineage tracking per 21 CFR Part 11 electronic records requirements.',
    `template_description` STRING COMMENT 'Detailed narrative description of the templates purpose, intended use, key sections, and any special instructions for document creators. Provides context for study teams selecting the appropriate template for their document creation needs.',
    `document_category` STRING COMMENT 'High-level TMF zone or business category to which documents created from this template belong. Aligns with DIA TMF Reference Model zones: REGULATORY (submissions, approvals), CLINICAL (protocols, ICFs, CRFs), SAFETY (SAE reports, IB), QUALITY (SOPs',
    `ectd_section_reference` STRING COMMENT 'Reference to the eCTD module and section where documents created from this template are submitted (e.g., Module 5.3.5.1 for clinical study reports, Module 2.7.4 for summary of clinical safety). Applicable for regulatory submission templates.',
    `effective_date` DATE COMMENT 'Date from which this template version is approved and authorized for use in creating clinical trial documents. Documents created before this date must use the prior effective version. Mandatory for GCP-compliant controlled document management.',
    `file_format` STRING COMMENT 'Electronic file format of the template document (e.g., DOCX for editable Word templates, PDF for locked reference templates, XLSX for data collection templates, XML for structured eCTD submission templates).. Valid values are `DOCX|PDF|XLSX|PDF_FORM|XML|RTF`',
    `inspection_readiness_status` STRING COMMENT 'Current inspection readiness classification for this template as assessed against regulatory authority inspection standards (FDA, EMA, MHRA). READY=template is current, approved, and compliant; NEEDS_REVIEW=review overdue or issues identified. Valid values are `READY|NEEDS_REVIEW|NOT_APPLICABLE|OVERDUE`',
    `is_econsent_compatible` BOOLEAN COMMENT 'Indicates whether this template is designed and validated for use in electronic consent (eConsent) workflows via Clinpal or equivalent eConsent platforms (True), or is intended for paper-based consent only (False).',
    `is_mandatory` BOOLEAN COMMENT 'Indicates whether use of this template is mandatory (True) or optional (False) for applicable study types. Mandatory templates must be used for all studies meeting the applicability criteria; optional templates may be used at the discretion of the study',
    `language_code` STRING COMMENT 'ISO 639-1 language code (optionally with ISO 3166-1 country subtag) of the template content (e.g., en, en-US, fr-FR, de-DE, ja-JP). Supports multilingual template management for global clinical trials and country-specific regulatory submissions.. Valid values are `^[a-z]{2}(-[A-Z]{2})?$`',
    `lifecycle_status` STRING COMMENT 'Current state of the template in its controlled document lifecycle as managed in Veeva Vault. DRAFT=under authoring, IN_REVIEW=under QA/regulatory review, APPROVED=approved but not yet effective, EFFECTIVE=currently in use for document creation',
    `mastercontrol_document_reference` STRING COMMENT 'Document identifier in MasterControl quality management system where the template is managed under controlled document procedures including training requirements, CAPA linkage, and SOP compliance tracking.',
    `template_name` STRING COMMENT 'Human-readable name of the document template (e.g., Phase III Oncology Informed Consent Form Template, Clinical Study Report Shell). Serves as the primary identity label for business users in Veeva Vault and CTMS.',
    `next_review_date` DATE COMMENT 'Date by which the next periodic review of this template must be completed. Calculated from approval_date plus review_frequency_months. Supports inspection readiness by ensuring templates are current and not overdue for review.',
    `owning_department` STRING COMMENT 'Name of the business department responsible for authoring, maintaining, and approving this template (e.g., Regulatory Affairs, Clinical Operations, Biostatistics, Data Management, Medical Writing, Quality Assurance).',
    `regulatory_authority` STRING COMMENT 'Regulatory authority or jurisdiction for which this template is designed to meet submission requirements (e.g., FDA, EMA, PMDA, MHRA, TGA, HEALTH_CANADA, ALL).',
    `retention_end_date` DATE COMMENT 'Date after which this template record may be destroyed per applicable regulatory retention schedules. Calculated based on the last study using this template plus the required retention period (typically 15 years post-study completion per ICH GCP).',
    `retirement_date` DATE COMMENT 'Date on which this template version was retired or superseded and is no longer available for new document creation. Null if the template is still active. Supports lifecycle management and ensures only current templates are used.',
    `review_frequency_months` BIGINT COMMENT 'Scheduled frequency in months at which this template must undergo periodic review to ensure continued regulatory compliance and business relevance (e.g., 12 for annual review, 24 for biennial).',
    `training_curriculum_code` STRING COMMENT 'Code referencing the MasterControl training curriculum or course that must be completed before using this template. Applicable when training_required is True. Links template usage to the training management system for compliance tracking.',
    `training_required` BOOLEAN COMMENT 'Indicates whether staff must complete training on this template before using it to create documents (True) or whether no formal training is required (False).',
    `template_type` STRING COMMENT 'Classification of the template by its functional document type within clinical trial operations (e.g., ICF_TEMPLATE, PROTOCOL_TEMPLATE, CSR_SHELL, the source system, CRF_ANNOTATION, REGULATORY_COVER_LETTER, DSMB_CHARTER, SITE_AGREEMENT).',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this document template record, in ISO 8601 format with timezone offset. Required for audit trail completeness under 21 CFR Part 11 and ICH GCP ALCOA+ principles. Updated on every change to any attribute.',
    `veeva_vault_document_number` STRING COMMENT 'Human-readable document number assigned by Veeva Vault (distinct from the internal document ID). Used for cross-referencing in regulatory submissions, audit trails, and TMF filing. Follows Veeva Vault document numbering conventions.',
    `veeva_vault_document_reference` STRING COMMENT 'Unique document identifier assigned by Veeva Vault eTMF/QMS system for this template record. Serves as the cross-system reference key linking the lakehouse silver layer record back to the authoritative source-of-record in Veeva Vault for audit trail and',
    `version_number` STRING COMMENT 'Current approved version number of the template following major.minor versioning convention (e.g., 1.0, 2.3). Controlled versioning is mandatory under GCP and 21 CFR Part 11 to ensure only approved template versions are used for document creation.. Valid values are `^[0-9]+.[0-9]+$`',
    CONSTRAINT pk_template PRIMARY KEY(`template_id`)
) COMMENT 'Master entity for approved document templates used to create standardized clinical trial documents (protocol templates, ICF templates, CSR shells, the source system annotation templates).';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`document`.`delegation_of_authority` (
    `delegation_of_authority_id` BIGINT COMMENT 'Primary key for delegation_of_authority',
    `principal_investigator_id` BIGINT COMMENT 'Reference to the principal investigator who delegates authority and retains overall responsibility for the trial at the site.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study or trial to which this delegation of authority applies.',
    `study_site_id` BIGINT COMMENT 'Reference to the clinical trial site where the delegated responsibilities are performed.',
    `superseded_delegation_of_authority_id` BIGINT COMMENT 'Self-referencing FK on delegation_of_authority (superseded_delegation_of_authority_id)',
    `tmf_artifact_id` BIGINT COMMENT 'Foreign key linking to document.tmf_artifact. Business justification: Normalizes the text-based tmf_artifact_number field to a proper FK to the tmf_artifact reference entity, enabling standardized DIA TMF Reference Model classification.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: A Delegation of Authority log is a GCP-essential TMF document (Zone 8 artifact). Linking it to its tmf_document master record enables TMF completeness tracking, inspection readiness',
    `approval_date` DATE COMMENT 'Date on which the delegation of authority document was formally approved and signed.',
    `approved_by` STRING COMMENT 'Name of the individual (typically the PI or authorized delegate) who approved the current version of the delegation of authority document.',
    `archival_date` DATE COMMENT 'Date on which the delegation of authority document was archived following study closure, per ICH GCP retention requirements.',
    `confidentiality_level` STRING COMMENT 'Data classification level assigned to the delegation of authority document based on the sensitivity of its contents.',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the site location where the delegation of authority applies, relevant for jurisdiction-specific regulatory requirements.',
    `created_date` TIMESTAMP COMMENT 'Timestamp when the delegation of authority record was first created in the document management system.',
    `delegated_tasks_summary` STRING COMMENT 'Summary description of the trial-related duties and tasks that have been delegated, such as informed consent, dispensing IP, CRF completion, and SAE reporting.',
    `document_number` STRING COMMENT 'Externally-known unique document number assigned to the delegation of authority log, used for regulatory tracking and TMF filing.',
    `document_type` STRING COMMENT 'Classification of the delegation document type, distinguishing between full delegation logs, sub-delegations, and task-specific delegations.',
    `effective_date` DATE COMMENT 'Date from which the delegation of authority becomes active and delegated tasks may be performed by authorized personnel.',
    `electronic_signature_applied` BOOLEAN COMMENT 'Indicates whether a 21 CFR Part 11 compliant electronic signature has been applied to this delegation of authority document.',
    `expiration_date` DATE COMMENT 'Date on which the delegation of authority expires or is no longer valid. Nullable for open-ended delegations that remain active until explicitly revoked.',
    `finding_count` BIGINT COMMENT 'Number of audit or quality findings identified against this delegation of authority document during inspections or internal reviews.',
    `inspection_readiness_flag` BOOLEAN COMMENT 'Indicates whether this delegation of authority document has been reviewed and confirmed as inspection-ready for regulatory audits.',
    `language` STRING COMMENT 'ISO 639-1 language code indicating the language in which the delegation of authority document is written.',
    `last_modified_date` TIMESTAMP COMMENT 'Timestamp when the delegation of authority record was last modified, supporting audit trail requirements.',
    `last_review_date` DATE COMMENT 'Date of the most recent periodic review of the delegation of authority to ensure it remains current and accurate.',
    `next_review_date` DATE COMMENT 'Date by which the next periodic review of the delegation of authority must be completed to maintain compliance.',
    `notes` STRING COMMENT 'Free-text notes or comments related to the delegation of authority document, including any special conditions or exceptions.',
    `number_of_delegates` BIGINT COMMENT 'Total count of individuals listed on the delegation of authority log who have been delegated specific trial-related responsibilities.',
    `pi_signature_date` DATE COMMENT 'Date on which the principal investigator signed the delegation of authority log, confirming delegation of trial-related duties.',
    `protocol_number` STRING COMMENT 'The protocol number of the clinical trial associated with this delegation, used for cross-referencing with regulatory submissions.',
    `quality_check_status` STRING COMMENT 'Status of the quality control review performed on the delegation of authority document to ensure completeness and accuracy.',
    `regulatory_authority` STRING COMMENT 'Name of the regulatory authority with jurisdiction over the site (e.g., FDA, EMA, MHRA, PMDA) relevant to inspection readiness.',
    `retention_period_years` BIGINT COMMENT 'Number of years the delegation of authority document must be retained after study completion per regulatory requirements (typically 15-25 years).',
    `review_frequency_days` BIGINT COMMENT 'Number of days between required periodic reviews of the delegation of authority document.',
    `sop_reference` STRING COMMENT 'Reference to the governing SOP that defines the process for creating, maintaining, and archiving delegation of authority logs.',
    `sponsor_name` STRING COMMENT 'Name of the pharmaceutical or biotech sponsor organization funding the clinical trial to which this delegation applies.',
    `delegation_of_authority_status` STRING COMMENT 'Current lifecycle status of the delegation of authority document within the document workflow.',
    `storage_location` STRING COMMENT 'Physical or electronic storage location of the delegation of authority document (e.g., Veeva Vault document ID, site investigator file binder section).',
    `superseded_by_document_number` STRING COMMENT 'Document number of the newer version that supersedes this delegation of authority, enabling version chain traceability.',
    `therapeutic_area` STRING COMMENT 'The therapeutic area or disease indication of the clinical trial associated with this delegation of authority.',
    `title` STRING COMMENT 'Human-readable title or name of the delegation of authority document, typically including the study identifier and site reference.',
    `tmf_zone` STRING COMMENT 'The TMF Reference Model zone classification where this document is filed, typically Zone 8 (Site Management) for delegation logs.',
    `training_confirmation_required` BOOLEAN COMMENT 'Indicates whether delegates listed on this document must provide evidence of training completion before performing delegated tasks.',
    `version_number` STRING COMMENT 'Current version number of the delegation of authority document, following controlled document versioning practices.',
    CONSTRAINT pk_delegation_of_authority PRIMARY KEY(`delegation_of_authority_id`)
) COMMENT 'Master reference table for delegation_of_authority. Referenced by delegation_of_authority_id.';

ALTER SCHEMA `clinical_trials_ecm`.`document` SET TAGS ('dbx_division' = 'corporate');

ALTER SCHEMA `clinical_trials_ecm`.`document` SET TAGS ('dbx_domain' = 'document');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ADD CONSTRAINT `fk_document_tmf_document_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ADD CONSTRAINT `fk_document_tmf_document_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ADD CONSTRAINT `fk_document_tmf_document_tmf_artifact_id` FOREIGN KEY (`tmf_artifact_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_artifact`(`tmf_artifact_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` SET TAGS ('dbx_domain' = 'document');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` SET TAGS ('dbx_subdomain' = 'trial_master');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Document ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `tmf_artifact_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Artifact Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Document Approval Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Document Comments');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `confidentiality_classification` SET TAGS ('dbx_value_regex' = 'restricted|confidential|internal|public');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `confidentiality_classification` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `tmf_document_description` SET TAGS ('dbx_business_glossary_term' = 'Document Description');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Document Effective Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Document Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `filing_status` SET TAGS ('dbx_business_glossary_term' = 'Document Filing Status');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `filing_status` SET TAGS ('dbx_value_regex' = 'expected|filed|overdue|not_applicable|placeholder');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `is_archived` SET TAGS ('dbx_business_glossary_term' = 'Is Archived Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `is_essential_document` SET TAGS ('dbx_business_glossary_term' = 'Is Essential Document Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `is_gcp_required` SET TAGS ('dbx_business_glossary_term' = 'Is Good Clinical Practice (GCP) Required Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `is_inspection_ready` SET TAGS ('dbx_business_glossary_term' = 'Is Inspection Ready Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `language_code` SET TAGS ('dbx_business_glossary_term' = 'Document Language Code');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `language_code` SET TAGS ('dbx_value_regex' = '^[a-z]{2}(-[A-Z]{2})?$');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `language_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `lifecycle_status` SET TAGS ('dbx_business_glossary_term' = 'Document Lifecycle Status');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `page_count` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `quality_review_status` SET TAGS ('dbx_value_regex' = 'not_reviewed|in_review|passed|failed|waived');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `retention_period_years` SET TAGS ('dbx_business_glossary_term' = 'Retention Period (Years)');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Document Title');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `tmf_section` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Section');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `tmf_zone` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Zone');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `tmf_zone` SET TAGS ('dbx_value_regex' = '01|02|03|04|05|06');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `vault_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `vault_library` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Library');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `version_date` SET TAGS ('dbx_business_glossary_term' = 'Document Version Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Document Version Number');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_document` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+(.[0-9]+)?$');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` SET TAGS ('dbx_domain' = 'document');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` SET TAGS ('dbx_subdomain' = 'trial_master');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `tmf_artifact_id` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Artifact ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `applicability_phase` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Applicable Trial Phase');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `archival_trigger` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Archival Trigger');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `artifact_abbreviation` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Abbreviation');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `artifact_code` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Code');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `artifact_code` SET TAGS ('dbx_value_regex' = '^[0-9]{2}.[0-9]{2}.[0-9]{2}$');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `artifact_description` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Description');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `artifact_name` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Name');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `artifact_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `artifact_number` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Number');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `artifact_status` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Status');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `artifact_status` SET TAGS ('dbx_value_regex' = 'Active|Deprecated|Superseded|Draft');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `cdisc_controlled_term` SET TAGS ('dbx_business_glossary_term' = 'Clinical Data Interchange Standards Consortium (CDISC) Controlled Terminology');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `cdisc_controlled_term` SET TAGS ('dbx_standard_ref' = 'CDISC CT TMF Artifact');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `completeness_weight` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Completeness Weight');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `dia_reference_model_version` SET TAGS ('dbx_business_glossary_term' = 'Document Information Association (DIA) TMF Reference Model Version');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `dia_reference_model_version` SET TAGS ('dbx_standard_ref' = 'DIA TMF Reference Model');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `document_owner_role` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Document Owner Role');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Effective Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `expected_timing` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Expected Filing Timing');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `filing_guidance` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Filing Guidance');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `ich_gcp_reference` SET TAGS ('dbx_business_glossary_term' = 'International Council for Harmonisation Good Clinical Practice (ICH GCP) Reference');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `ich_gcp_reference` SET TAGS ('dbx_standard_ref' = 'ICH E6(R2) GCP');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `is_country_specific` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Country-Specific Indicator');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `is_essential_document` SET TAGS ('dbx_business_glossary_term' = 'TMF Essential Document Indicator');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `is_inspection_critical` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Inspection Critical Indicator');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `is_investigator_held` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Investigator Site File (ISF) Held Indicator');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `is_site_specific` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Site-Specific Indicator');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `is_sponsor_held` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Sponsor-Held Indicator');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Notes');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `requirement_classification` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Requirement Classification');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `requirement_classification` SET TAGS ('dbx_value_regex' = 'Required|Recommended|Optional');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `requires_electronic_signature` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Electronic Signature Required Indicator');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `requires_electronic_signature` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `requires_electronic_signature` SET TAGS ('dbx_pii_signature' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `requires_wet_signature` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Wet Signature Required Indicator');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `requires_wet_signature` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `requires_wet_signature` SET TAGS ('dbx_pii_signature' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `retention_period_years` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Retention Period (Years)');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `retirement_date` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Retirement Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `section_name` SET TAGS ('dbx_business_glossary_term' = 'TMF Section Name');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `section_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `section_number` SET TAGS ('dbx_business_glossary_term' = 'TMF Section Number');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `section_number` SET TAGS ('dbx_value_regex' = '^[0-9]{1,2}.[0-9]{1,2}$');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `superseded_by_code` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Superseded By Code');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `superseded_by_code` SET TAGS ('dbx_value_regex' = '^[0-9]{2}.[0-9]{2}.[0-9]{2}$');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `tmf_level` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Level');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `tmf_level` SET TAGS ('dbx_value_regex' = 'Trial|Country|Site');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `trial_phase_end` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Trial Phase End');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `trial_phase_end` SET TAGS ('dbx_value_regex' = 'Pre-Trial|Start-Up|Conduct|Close-Out|Post-Trial');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `trial_phase_start` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Trial Phase Start');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `trial_phase_start` SET TAGS ('dbx_value_regex' = 'Pre-Trial|Start-Up|Conduct|Close-Out|Post-Trial');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `veeva_vault_document_subtype` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault eTMF Document Subtype');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `veeva_vault_document_type` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault eTMF Document Type');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `zone_name` SET TAGS ('dbx_business_glossary_term' = 'TMF Zone Name');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `zone_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_artifact` ALTER COLUMN `zone_number` SET TAGS ('dbx_business_glossary_term' = 'TMF Zone Number');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ADD CONSTRAINT `fk_document_version_approver_employee_id` FOREIGN KEY (`approver_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ADD CONSTRAINT `fk_document_version_controlled_terminology_codelist_id` FOREIGN KEY (`controlled_terminology_codelist_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`codelist`(`codelist_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ADD CONSTRAINT `fk_document_version_primary_version_author_employee_id` FOREIGN KEY (`primary_version_author_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ADD CONSTRAINT `fk_document_version_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`version` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` SET TAGS ('dbx_domain' = 'document');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` SET TAGS ('dbx_subdomain' = 'control_lifecycle');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `version_id` SET TAGS ('dbx_business_glossary_term' = 'Document Version ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `approver_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `approver_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `approver_employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `controlled_terminology_codelist_id` SET TAGS ('dbx_standard_ref' = 'CDISC CT Codelist');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `primary_version_author_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Author Employee ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `primary_version_author_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `primary_version_author_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `primary_version_author_employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Document ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `approver_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `approver_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `approver_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `archival_status` SET TAGS ('dbx_value_regex' = 'active|archived|pending_archival|destroyed');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `author_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `author_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `author_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `capa_reference` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Reference');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `change_type` SET TAGS ('dbx_value_regex' = 'major|minor|administrative|initial');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `checksum_hash` SET TAGS ('dbx_business_glossary_term' = 'Checksum Hash (SHA-256)');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `checksum_hash` SET TAGS ('dbx_value_regex' = '^[a-fA-F0-9]{64}$');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_value_regex' = 'public|internal|confidential|restricted');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `file_size_kb` SET TAGS ('dbx_business_glossary_term' = 'File Size (KB)');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `inspection_readiness_status` SET TAGS ('dbx_value_regex' = 'ready|gap_identified|remediation_in_progress|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `language_code` SET TAGS ('dbx_value_regex' = '^[a-z]{2}(-[A-Z]{2})?$');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `language_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+(.[0-9]+)?$');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `reviewer_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `reviewer_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `reviewer_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `version_status` SET TAGS ('dbx_value_regex' = 'draft|in_review|approved|superseded|obsolete|withdrawn');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `tmf_section` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Section');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `tmf_zone` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Zone');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `tmf_zone` SET TAGS ('dbx_value_regex' = 'zone_1|zone_2|zone_3|zone_4|zone_5');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `training_required` SET TAGS ('dbx_business_glossary_term' = 'Training Required Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `vault_document_version_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document Version ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`version` ALTER COLUMN `vault_lifecycle_state` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Lifecycle State');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ADD CONSTRAINT `fk_document_document_sop_owning_org_unit_id` FOREIGN KEY (`owning_org_unit_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`org_unit`(`org_unit_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ADD CONSTRAINT `fk_document_document_sop_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ADD CONSTRAINT `fk_document_document_sop_therapeutic_area_id` FOREIGN KEY (`therapeutic_area_id`) REFERENCES `clinical_trials_ecm`.`program`.`therapeutic_area`(`therapeutic_area_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ADD CONSTRAINT `fk_document_document_sop_training_curriculum_id` FOREIGN KEY (`training_curriculum_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`training_curriculum`(`training_curriculum_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` SET TAGS ('dbx_domain' = 'document');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` SET TAGS ('dbx_subdomain' = 'control_lifecycle');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `document_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Standard Operating Procedure (SOP) Document ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `owning_org_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Owning Org Unit Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `therapeutic_area_id` SET TAGS ('dbx_business_glossary_term' = 'Therapeutic Area Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `training_curriculum_id` SET TAGS ('dbx_business_glossary_term' = 'Training Curriculum Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `applicable_region` SET TAGS ('dbx_business_glossary_term' = 'SOP Applicable Geographic Region');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'SOP Approval Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `approver` SET TAGS ('dbx_business_glossary_term' = 'SOP Approver');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `approver` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `approver` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `approver` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `author` SET TAGS ('dbx_business_glossary_term' = 'SOP Author');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `author` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `author` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `author` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `capa_reference` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Reference');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `change_summary` SET TAGS ('dbx_business_glossary_term' = 'SOP Version Change Summary');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_business_glossary_term' = 'SOP Confidentiality Classification Level');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_value_regex' = 'public|internal|confidential|restricted');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'SOP Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `deviation_triggered` SET TAGS ('dbx_business_glossary_term' = 'SOP Deviation-Triggered Revision Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `document_format` SET TAGS ('dbx_business_glossary_term' = 'SOP Document Format');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `document_format` SET TAGS ('dbx_value_regex' = 'pdf|word|excel|html|xml');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `document_location_url` SET TAGS ('dbx_business_glossary_term' = 'SOP Document Storage Location URL');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'SOP Effective Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `electronic_signature_required` SET TAGS ('dbx_business_glossary_term' = 'Electronic Signature Required Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `electronic_signature_required` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `electronic_signature_required` SET TAGS ('dbx_pii_signature' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'SOP Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `gcp_applicable` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Applicable Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `gdpr_applicable` SET TAGS ('dbx_business_glossary_term' = 'General Data Protection Regulation (GDPR) Applicable Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `hipaa_applicable` SET TAGS ('dbx_business_glossary_term' = 'Health Insurance Portability and Accountability Act (HIPAA) Applicable Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `inspection_ready` SET TAGS ('dbx_business_glossary_term' = 'SOP Inspection Readiness Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `language` SET TAGS ('dbx_business_glossary_term' = 'SOP Document Language');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `language` SET TAGS ('dbx_value_regex' = '^[a-z]{2,3}(-[A-Z]{2})?$');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `language` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'SOP Record Last Modified Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `mastercontrol_doc_reference` SET TAGS ('dbx_business_glossary_term' = 'MasterControl Document ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `process_area` SET TAGS ('dbx_business_glossary_term' = 'SOP Process Area');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `purpose` SET TAGS ('dbx_business_glossary_term' = 'SOP Purpose Statement');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `regulatory_framework` SET TAGS ('dbx_business_glossary_term' = 'Applicable Regulatory Framework');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `review_cycle_months` SET TAGS ('dbx_business_glossary_term' = 'SOP Periodic Review Cycle (Months)');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `review_due_date` SET TAGS ('dbx_business_glossary_term' = 'SOP Periodic Review Due Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `scope` SET TAGS ('dbx_business_glossary_term' = 'SOP Scope Statement');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `sop_number` SET TAGS ('dbx_business_glossary_term' = 'Standard Operating Procedure (SOP) Number');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `sop_number` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,10}-SOP-[0-9]{3,6}$');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `sop_status` SET TAGS ('dbx_business_glossary_term' = 'SOP Lifecycle Status');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `sop_type` SET TAGS ('dbx_business_glossary_term' = 'SOP Document Type');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `sop_type` SET TAGS ('dbx_value_regex' = 'sop|work_instruction|policy|guidance|template|form');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `superseded_version_number` SET TAGS ('dbx_business_glossary_term' = 'Superseded SOP Version Number');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `superseded_version_number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'SOP Title');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `tmf_reference_model_section` SET TAGS ('dbx_business_glossary_term' = 'DIA Trial Master File (TMF) Reference Model Section');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `training_completion_deadline_days` SET TAGS ('dbx_business_glossary_term' = 'SOP Training Completion Deadline (Days)');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `training_required` SET TAGS ('dbx_business_glossary_term' = 'SOP Training Required Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'SOP Version Number');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_sop` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ADD CONSTRAINT `fk_document_workflow_document_sop_id` FOREIGN KEY (`document_sop_id`) REFERENCES `clinical_trials_ecm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ADD CONSTRAINT `fk_document_workflow_primary_workflow_employee_id` FOREIGN KEY (`primary_workflow_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ADD CONSTRAINT `fk_document_workflow_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ADD CONSTRAINT `fk_document_workflow_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ADD CONSTRAINT `fk_document_workflow_version_id` FOREIGN KEY (`version_id`) REFERENCES `clinical_trials_ecm`.`document`.`version`(`version_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` SET TAGS ('dbx_domain' = 'document');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` SET TAGS ('dbx_subdomain' = 'control_lifecycle');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `workflow_id` SET TAGS ('dbx_business_glossary_term' = 'Document Workflow ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `document_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Document Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `primary_workflow_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Step Assignee User ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `primary_workflow_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `primary_workflow_employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Document ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `version_id` SET TAGS ('dbx_business_glossary_term' = 'Document Version Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `actual_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Workflow Actual Completion Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `archival_date` SET TAGS ('dbx_business_glossary_term' = 'Document Archival Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `archival_required` SET TAGS ('dbx_business_glossary_term' = 'Archival Required Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `current_step_name` SET TAGS ('dbx_business_glossary_term' = 'Current Workflow Step Name');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `current_step_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `current_step_sequence` SET TAGS ('dbx_business_glossary_term' = 'Current Step Sequence Number');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `distribution_date` SET TAGS ('dbx_business_glossary_term' = 'Document Distribution Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `distribution_required` SET TAGS ('dbx_business_glossary_term' = 'Distribution Required Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `electronic_signature_required` SET TAGS ('dbx_business_glossary_term' = 'Electronic Signature Required Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `electronic_signature_required` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `electronic_signature_required` SET TAGS ('dbx_pii_signature' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `electronic_signature_timestamp` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `electronic_signature_timestamp` SET TAGS ('dbx_pii_signature' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `escalation_reason` SET TAGS ('dbx_value_regex' = 'sla-breach|non-response|rejection-loop|resource-unavailable|other');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `gcp_critical_document_flag` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Critical Document Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `initiated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Workflow Initiated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `instance_reference` SET TAGS ('dbx_business_glossary_term' = 'Workflow Instance ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `priority_level` SET TAGS ('dbx_business_glossary_term' = 'Workflow Priority Level');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `priority_level` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `sla_breach_indicator` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Breach Indicator');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `workflow_status` SET TAGS ('dbx_value_regex' = 'initiated|in-review|pending-approval|approved|rejected|cancelled');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `step_action_taken` SET TAGS ('dbx_value_regex' = 'approved|rejected|reviewed|delegated|reassigned|escalated');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `step_assignee_name` SET TAGS ('dbx_business_glossary_term' = 'Step Assignee Full Name');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `step_assignee_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `step_assignee_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `step_assignee_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `step_comment` SET TAGS ('dbx_business_glossary_term' = 'Step Reviewer Comment');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `target_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Workflow Target Completion Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `template_name` SET TAGS ('dbx_business_glossary_term' = 'Workflow Template Name');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `template_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `template_version` SET TAGS ('dbx_business_glossary_term' = 'Workflow Template Version');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `tmf_zone` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Zone');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `total_steps` SET TAGS ('dbx_business_glossary_term' = 'Total Workflow Steps');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `workflow_type` SET TAGS ('dbx_value_regex' = 'review|approval|distribution|archival|cancellation|amendment');

ALTER TABLE `clinical_trials_ecm`.`document`.`workflow` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ADD CONSTRAINT `fk_document_signature_delegation_of_authority_id` FOREIGN KEY (`delegation_of_authority_id`) REFERENCES `clinical_trials_ecm`.`document`.`delegation_of_authority`(`delegation_of_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ADD CONSTRAINT `fk_document_signature_organization_contact_id` FOREIGN KEY (`organization_contact_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization_contact`(`organization_contact_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ADD CONSTRAINT `fk_document_signature_primary_signature_employee_id` FOREIGN KEY (`primary_signature_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ADD CONSTRAINT `fk_document_signature_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ADD CONSTRAINT `fk_document_signature_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ADD CONSTRAINT `fk_document_signature_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ADD CONSTRAINT `fk_document_signature_version_id` FOREIGN KEY (`version_id`) REFERENCES `clinical_trials_ecm`.`document`.`version`(`version_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ADD CONSTRAINT `fk_document_signature_workflow_id` FOREIGN KEY (`workflow_id`) REFERENCES `clinical_trials_ecm`.`document`.`workflow`(`workflow_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` SET TAGS ('dbx_domain' = 'document');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` SET TAGS ('dbx_subdomain' = 'control_lifecycle');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `signature_id` SET TAGS ('dbx_business_glossary_term' = 'Document Signature ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `signature_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `signature_id` SET TAGS ('dbx_pii_signature' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Contact Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `primary_signature_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Signer User ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `primary_signature_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `primary_signature_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `primary_signature_employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Document ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `version_id` SET TAGS ('dbx_business_glossary_term' = 'Document Version ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `workflow_id` SET TAGS ('dbx_business_glossary_term' = 'Document Workflow Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Signature Comments');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `device_identifier` SET TAGS ('dbx_business_glossary_term' = 'Signing Device Identifier');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `device_identifier` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `device_identifier` SET TAGS ('dbx_pii_device' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `digital_certificate_serial` SET TAGS ('dbx_business_glossary_term' = 'Digital Certificate Serial Number');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Signature Due Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `hash_algorithm` SET TAGS ('dbx_value_regex' = 'SHA-256|SHA-512|SHA-3|RSA-SHA256');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `ip_address` SET TAGS ('dbx_business_glossary_term' = 'Signer IP Address');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `ip_address` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `ip_address` SET TAGS ('dbx_pii_ip' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `is_regulatory_submission_applicable` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission Applicable Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `locale` SET TAGS ('dbx_business_glossary_term' = 'Signing Locale');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `meaning` SET TAGS ('dbx_business_glossary_term' = 'Signature Meaning');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `meaning` SET TAGS ('dbx_value_regex' = 'reviewed|approved|acknowledged|authored|certified|witnessed');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `meaning` SET TAGS ('dbx_standard_ref' = '21 CFR Part 11 Electronic Signature meaning');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `method` SET TAGS ('dbx_business_glossary_term' = 'Signature Method');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `method` SET TAGS ('dbx_value_regex' = 'username_password|biometric|digital_certificate|smart_card|two_factor_auth');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `method` SET TAGS ('dbx_standard_ref' = '21 CFR Part 11 Electronic Signature');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `reference_number` SET TAGS ('dbx_business_glossary_term' = 'Signature Reference Number');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `requested_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Signature Requested Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `signed_timestamp` SET TAGS ('dbx_standard_ref' = '21 CFR Part 11 Electronic Signature');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `signer_full_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `signer_full_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `signer_full_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `signer_role` SET TAGS ('dbx_value_regex' = 'author|reviewer|approver|sponsor_representative|quality_assurance|investigator');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `source_system_signature_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Signature ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `source_system_signature_reference` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `source_system_signature_reference` SET TAGS ('dbx_pii_signature' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `signature_status` SET TAGS ('dbx_value_regex' = 'pending|applied|voided|superseded|rejected');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `signature_status` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `signature_status` SET TAGS ('dbx_pii_signature' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `timezone` SET TAGS ('dbx_business_glossary_term' = 'Signing Timezone');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `tmf_artifact_number` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Artifact Number');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `tmf_zone` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Zone');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `signature_type` SET TAGS ('dbx_value_regex' = 'electronic|wet_ink_scanned|advanced_electronic|qualified_electronic');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `signature_type` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `signature_type` SET TAGS ('dbx_pii_signature' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`signature` ALTER COLUMN `workflow_step_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ADD CONSTRAINT `fk_document_site_file_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ADD CONSTRAINT `fk_document_site_file_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ADD CONSTRAINT `fk_document_site_file_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` SET TAGS ('dbx_domain' = 'document');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` SET TAGS ('dbx_subdomain' = 'trial_master');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Site File Custodian ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `activation_date` SET TAGS ('dbx_business_glossary_term' = 'Site File Activation Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `applicable_gcp_guideline` SET TAGS ('dbx_business_glossary_term' = 'Applicable Good Clinical Practice (GCP) Guideline');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `applicable_gcp_guideline` SET TAGS ('dbx_value_regex' = 'ICH E6(R2)|ICH E6(R3)|21 CFR Part 312|EU CTR 536/2014|ISO 14155');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `archival_date` SET TAGS ('dbx_business_glossary_term' = 'Site File Archival Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `closure_date` SET TAGS ('dbx_business_glossary_term' = 'Site File Closure Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `completeness_percentage` SET TAGS ('dbx_business_glossary_term' = 'Site File Completeness Percentage');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `completeness_percentage` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `completeness_status` SET TAGS ('dbx_business_glossary_term' = 'Site File Completeness Status');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `completeness_status` SET TAGS ('dbx_value_regex' = 'Complete|Incomplete|Overdue|Not Applicable');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `custodian_role` SET TAGS ('dbx_business_glossary_term' = 'Site File Custodian Role');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `custodian_role` SET TAGS ('dbx_value_regex' = 'PI|CRC|Sub-Investigator|Regulatory Affairs Coordinator|Site Manager');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `delegation_log_on_file` SET TAGS ('dbx_business_glossary_term' = 'Delegation of Authority Log On File Indicator');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `file_format` SET TAGS ('dbx_business_glossary_term' = 'Site File Format');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `file_format` SET TAGS ('dbx_value_regex' = 'Electronic|Paper|Hybrid');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `file_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Site File Reference Number');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `file_status` SET TAGS ('dbx_business_glossary_term' = 'Site File Status');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `file_status` SET TAGS ('dbx_value_regex' = 'Active|Under Review|Archived|Closed|Pending Activation');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `file_type` SET TAGS ('dbx_business_glossary_term' = 'Site File Type');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `file_type` SET TAGS ('dbx_value_regex' = 'ISF|Regulatory Binder|Pharmacy Binder|Laboratory Binder|Investigator Binder');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `financial_disclosure_on_file` SET TAGS ('dbx_business_glossary_term' = 'Financial Disclosure On File Indicator');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `icf_on_file` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) On File Indicator');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `inspection_readiness_status` SET TAGS ('dbx_value_regex' = 'Ready|Needs Remediation|Critical Gaps|Not Assessed');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `investigator_cv_on_file` SET TAGS ('dbx_business_glossary_term' = 'Investigator Curriculum Vitae (CV) On File Indicator');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `irb_iec_approval_on_file` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Approval On File Indicator');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `lab_certification_on_file` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Certification On File Indicator');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `last_inspection_date` SET TAGS ('dbx_business_glossary_term' = 'Last Regulatory Inspection Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `last_inspection_outcome` SET TAGS ('dbx_business_glossary_term' = 'Last Regulatory Inspection Outcome');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `last_inspection_outcome` SET TAGS ('dbx_value_regex' = 'No Action Indicated|Voluntary Action Indicated|Official Action Indicated|Pending|Not Applicable');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Site File Review Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Scheduled Site File Review Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Site File Notes');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `physical_location` SET TAGS ('dbx_business_glossary_term' = 'Physical File Location');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `protocol_on_file` SET TAGS ('dbx_business_glossary_term' = 'Protocol On File Indicator');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `sponsor_review_completed` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Review Completed Indicator');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `tmf_section` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Section');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `tmf_zone` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Zone');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `tmf_zone` SET TAGS ('dbx_value_regex' = 'Trial Management|Investigational Product|Site Management|Subject Information and Consent|Study Procedures');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file` ALTER COLUMN `veeva_vault_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ADD CONSTRAINT `fk_document_site_file_document_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ADD CONSTRAINT `fk_document_site_file_document_site_file_id` FOREIGN KEY (`site_file_id`) REFERENCES `clinical_trials_ecm`.`document`.`site_file`(`site_file_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ADD CONSTRAINT `fk_document_site_file_document_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ADD CONSTRAINT `fk_document_site_file_document_superseded_by_document_site_file_document_id` FOREIGN KEY (`superseded_by_document_site_file_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`site_file_document`(`site_file_document_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ADD CONSTRAINT `fk_document_site_file_document_tmf_artifact_id` FOREIGN KEY (`tmf_artifact_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_artifact`(`tmf_artifact_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ADD CONSTRAINT `fk_document_site_file_document_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` SET TAGS ('dbx_domain' = 'document');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` SET TAGS ('dbx_subdomain' = 'trial_master');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Research Associate (CRA) ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ALTER COLUMN `superseded_by_document_site_file_document_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Document ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ALTER COLUMN `tmf_artifact_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Artifact Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ALTER COLUMN `document_source_type` SET TAGS ('dbx_value_regex' = 'original|certified_copy|scanned_copy|fax_copy|electronic');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Document Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ALTER COLUMN `filing_method` SET TAGS ('dbx_value_regex' = 'electronic|paper|hybrid');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ALTER COLUMN `filing_status` SET TAGS ('dbx_value_regex' = 'filed|missing|not_applicable|overdue|superseded|pending_review');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ALTER COLUMN `is_inspection_ready` SET TAGS ('dbx_business_glossary_term' = 'Is Inspection Ready Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ALTER COLUMN `is_required` SET TAGS ('dbx_business_glossary_term' = 'Is Required Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ALTER COLUMN `isf_section_code` SET TAGS ('dbx_business_glossary_term' = 'Investigator Site File (ISF) Section Code');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ALTER COLUMN `isf_section_name` SET TAGS ('dbx_business_glossary_term' = 'Investigator Site File (ISF) Section Name');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ALTER COLUMN `isf_section_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ALTER COLUMN `language_code` SET TAGS ('dbx_business_glossary_term' = 'Document Language Code');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ALTER COLUMN `language_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ALTER COLUMN `language_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ALTER COLUMN `sdv_date` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ALTER COLUMN `sdv_status` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Status');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ALTER COLUMN `sdv_status` SET TAGS ('dbx_value_regex' = 'not_verified|verified|discrepancy_found|not_required');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ALTER COLUMN `vault_document_number` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document Number');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ALTER COLUMN `vault_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ALTER COLUMN `vault_lifecycle_state` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Lifecycle State');

ALTER TABLE `clinical_trials_ecm`.`document`.`site_file_document` ALTER COLUMN `vault_lifecycle_state` SET TAGS ('dbx_value_regex' = 'draft|in_review|approved|obsolete|archived');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ADD CONSTRAINT `fk_document_tmf_completeness_assessed_by_employee_id` FOREIGN KEY (`assessed_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ADD CONSTRAINT `fk_document_tmf_completeness_master_agreement_id` FOREIGN KEY (`master_agreement_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`master_agreement`(`master_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ADD CONSTRAINT `fk_document_tmf_completeness_prior_assessment_tmf_completeness_id` FOREIGN KEY (`prior_assessment_tmf_completeness_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_completeness`(`tmf_completeness_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ADD CONSTRAINT `fk_document_tmf_completeness_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ADD CONSTRAINT `fk_document_tmf_completeness_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` SET TAGS ('dbx_domain' = 'document');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` SET TAGS ('dbx_subdomain' = 'trial_master');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `tmf_completeness_id` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Completeness Assessment ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `assessed_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Assessed By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `assessed_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `assessed_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `assessed_by_employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `master_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Preferred Provider Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `prior_assessment_tmf_completeness_id` SET TAGS ('dbx_business_glossary_term' = 'Prior TMF Completeness Assessment ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Study Site Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `assessed_by_role` SET TAGS ('dbx_value_regex' = 'tmf_manager|qa_specialist|cra|study_manager|regulatory_affairs');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `assessment_date` SET TAGS ('dbx_business_glossary_term' = 'TMF Completeness Assessment Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `assessment_reference` SET TAGS ('dbx_business_glossary_term' = 'TMF Completeness Assessment Reference Number');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `assessment_status` SET TAGS ('dbx_business_glossary_term' = 'TMF Completeness Assessment Status');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `assessment_status` SET TAGS ('dbx_value_regex' = 'draft|in_progress|completed|reviewed|approved');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `assessment_type` SET TAGS ('dbx_business_glossary_term' = 'TMF Completeness Assessment Type');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `assessment_type` SET TAGS ('dbx_value_regex' = 'scheduled|ad_hoc|pre_inspection|milestone|close_out');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `capa_reference` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Reference');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `completeness_target_pct` SET TAGS ('dbx_business_glossary_term' = 'TMF Completeness Target Percentage');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `completeness_trend` SET TAGS ('dbx_business_glossary_term' = 'TMF Completeness Trend');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `completeness_trend` SET TAGS ('dbx_value_regex' = 'improving|stable|declining|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `critical_document_gap_count` SET TAGS ('dbx_business_glossary_term' = 'Critical TMF Document Gap Count');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `etmf_system_snapshot_reference` SET TAGS ('dbx_business_glossary_term' = 'Electronic Trial Master File (eTMF) System Snapshot ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `expected_artifact_count` SET TAGS ('dbx_business_glossary_term' = 'Expected TMF Artifact Count');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `filed_artifact_count` SET TAGS ('dbx_business_glossary_term' = 'Filed TMF Artifact Count');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `findings_summary` SET TAGS ('dbx_business_glossary_term' = 'TMF Assessment Findings Summary');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `inspection_readiness_risk` SET TAGS ('dbx_business_glossary_term' = 'Inspection Readiness Risk Level');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `inspection_readiness_risk` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `is_inspection_ready` SET TAGS ('dbx_business_glossary_term' = 'Inspection Readiness Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `missing_artifact_count` SET TAGS ('dbx_business_glossary_term' = 'Missing TMF Artifact Count');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `next_assessment_due_date` SET TAGS ('dbx_business_glossary_term' = 'Next TMF Completeness Assessment Due Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `overall_completeness_pct` SET TAGS ('dbx_business_glossary_term' = 'Overall TMF Completeness Percentage');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `overdue_artifact_count` SET TAGS ('dbx_business_glossary_term' = 'Overdue TMF Artifact Count');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `pending_review_artifact_count` SET TAGS ('dbx_business_glossary_term' = 'Pending Review TMF Artifact Count');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `rejected_artifact_count` SET TAGS ('dbx_business_glossary_term' = 'Rejected TMF Artifact Count');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `remediation_action_required` SET TAGS ('dbx_business_glossary_term' = 'Remediation Action Required Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `review_date` SET TAGS ('dbx_business_glossary_term' = 'TMF Assessment Review Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `reviewed_by` SET TAGS ('dbx_business_glossary_term' = 'Reviewed By (QA Reviewer Name)');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `study_phase` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study Phase');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `study_phase` SET TAGS ('dbx_value_regex' = 'phase_1|phase_2|phase_3|phase_4|phase_1_2|phase_2_3');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `study_status_at_assessment` SET TAGS ('dbx_value_regex' = 'start_up|enrolling|on_hold|completed|close_out');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `tmf_scope` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Scope');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `tmf_scope` SET TAGS ('dbx_value_regex' = 'full_study|sponsor_tmf|site_tmf|investigator_site_file');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `zone_1_completeness_pct` SET TAGS ('dbx_business_glossary_term' = 'TMF Zone 1 (Trial Management) Completeness Percentage');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `zone_2_completeness_pct` SET TAGS ('dbx_business_glossary_term' = 'TMF Zone 2 (Central Trial Documents) Completeness Percentage');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `zone_3_completeness_pct` SET TAGS ('dbx_business_glossary_term' = 'TMF Zone 3 (Regulatory) Completeness Percentage');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `zone_4_completeness_pct` SET TAGS ('dbx_business_glossary_term' = 'TMF Zone 4 (IRB/IEC and Other Approvals) Completeness Percentage');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `zone_5_completeness_pct` SET TAGS ('dbx_business_glossary_term' = 'TMF Zone 5 (Site Management) Completeness Percentage');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `zone_6_completeness_pct` SET TAGS ('dbx_business_glossary_term' = 'TMF Zone 6 (Investigational Product) Completeness Percentage');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `zone_7_completeness_pct` SET TAGS ('dbx_business_glossary_term' = 'TMF Zone 7 (Safety Reporting) Completeness Percentage');

ALTER TABLE `clinical_trials_ecm`.`document`.`tmf_completeness` ALTER COLUMN `zone_8_completeness_pct` SET TAGS ('dbx_business_glossary_term' = 'TMF Zone 8 (Statistics and Data Management) Completeness Percentage');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ADD CONSTRAINT `fk_document_inspection_readiness_compliance_capa_id` FOREIGN KEY (`compliance_capa_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_capa`(`compliance_capa_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ADD CONSTRAINT `fk_document_inspection_readiness_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ADD CONSTRAINT `fk_document_inspection_readiness_primary_inspection_etmf_vault_study_id` FOREIGN KEY (`primary_inspection_etmf_vault_study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ADD CONSTRAINT `fk_document_inspection_readiness_primary_regulatory_inspection_id` FOREIGN KEY (`primary_regulatory_inspection_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`regulatory_inspection`(`regulatory_inspection_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ADD CONSTRAINT `fk_document_inspection_readiness_site_file_id` FOREIGN KEY (`site_file_id`) REFERENCES `clinical_trials_ecm`.`document`.`site_file`(`site_file_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ADD CONSTRAINT `fk_document_inspection_readiness_sponsor_regulatory_strategy_id` FOREIGN KEY (`sponsor_regulatory_strategy_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`regulatory_strategy`(`regulatory_strategy_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ADD CONSTRAINT `fk_document_inspection_readiness_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ADD CONSTRAINT `fk_document_inspection_readiness_tmf_completeness_id` FOREIGN KEY (`tmf_completeness_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_completeness`(`tmf_completeness_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` SET TAGS ('dbx_domain' = 'document');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` SET TAGS ('dbx_subdomain' = 'regulatory_submission');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ALTER COLUMN `inspection_readiness_id` SET TAGS ('dbx_business_glossary_term' = 'Document Inspection Readiness ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ALTER COLUMN `compliance_capa_id` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Manager ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ALTER COLUMN `primary_inspection_etmf_vault_study_id` SET TAGS ('dbx_business_glossary_term' = 'Electronic Trial Master File (eTMF) Vault Study ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ALTER COLUMN `primary_regulatory_inspection_id` SET TAGS ('dbx_business_glossary_term' = 'Inspection Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ALTER COLUMN `site_file_id` SET TAGS ('dbx_business_glossary_term' = 'Site File Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ALTER COLUMN `sponsor_regulatory_strategy_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Regulatory Strategy Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Site ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ALTER COLUMN `tmf_completeness_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Completeness Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ALTER COLUMN `capa_required` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Required');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ALTER COLUMN `dia_tmf_zone_coverage` SET TAGS ('dbx_business_glossary_term' = 'DIA TMF Reference Model Zone Coverage');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ALTER COLUMN `dia_tmf_zone_coverage` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ALTER COLUMN `inspection_outcome` SET TAGS ('dbx_value_regex' = 'no-action-indicated|voluntary-action-indicated|official-action-indicated|pending|not-applicable');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ALTER COLUMN `inspection_type` SET TAGS ('dbx_value_regex' = 'gcp|tmf|sponsor|regulatory-authority|for-cause|routine');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ALTER COLUMN `next_readiness_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Scheduled Readiness Review Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Inspection Readiness Notes');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ALTER COLUMN `previous_inspection_outcome` SET TAGS ('dbx_value_regex' = 'no-action-indicated|voluntary-action-indicated|official-action-indicated|not-applicable');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ALTER COLUMN `readiness_reference_code` SET TAGS ('dbx_business_glossary_term' = 'Inspection Readiness Reference Code');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ALTER COLUMN `readiness_reference_code` SET TAGS ('dbx_value_regex' = '^IR-[A-Z0-9]{3,10}-[0-9]{4,8}$');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ALTER COLUMN `readiness_score` SET TAGS ('dbx_business_glossary_term' = 'TMF Inspection Readiness Score');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ALTER COLUMN `readiness_status` SET TAGS ('dbx_business_glossary_term' = 'Inspection Readiness Status');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ALTER COLUMN `readiness_status` SET TAGS ('dbx_value_regex' = 'not-started|in-preparation|ready|under-inspection|closed');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ALTER COLUMN `response_due_date` SET TAGS ('dbx_business_glossary_term' = 'Inspection Response Due Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ALTER COLUMN `sponsor_notified` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Notified Indicator');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ALTER COLUMN `tier` SET TAGS ('dbx_business_glossary_term' = 'Inspection Readiness Tier (RAG Status)');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ALTER COLUMN `tier` SET TAGS ('dbx_value_regex' = 'red|amber|green');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ALTER COLUMN `tmf_scope` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Scope');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ALTER COLUMN `tmf_scope` SET TAGS ('dbx_value_regex' = 'full-study|site-specific|sponsor-section|investigator-section');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`inspection_readiness` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'Inspection Readiness Record Version');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ADD CONSTRAINT `fk_document_distribution_distributed_by_employee_id` FOREIGN KEY (`distributed_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ADD CONSTRAINT `fk_document_distribution_document_sop_id` FOREIGN KEY (`document_sop_id`) REFERENCES `clinical_trials_ecm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ADD CONSTRAINT `fk_document_distribution_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ADD CONSTRAINT `fk_document_distribution_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ADD CONSTRAINT `fk_document_distribution_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ADD CONSTRAINT `fk_document_distribution_version_id` FOREIGN KEY (`version_id`) REFERENCES `clinical_trials_ecm`.`document`.`version`(`version_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` SET TAGS ('dbx_domain' = 'document');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` SET TAGS ('dbx_subdomain' = 'control_lifecycle');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `distribution_id` SET TAGS ('dbx_business_glossary_term' = 'Document Distribution ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `distributed_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Distributed By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `distributed_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `distributed_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `distributed_by_employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `document_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Document Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Document ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `version_id` SET TAGS ('dbx_business_glossary_term' = 'Document Version ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `acknowledgement_method` SET TAGS ('dbx_value_regex' = 'Electronic Signature|Email Reply|Physical Signature|System Confirmation');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `acknowledgement_required` SET TAGS ('dbx_business_glossary_term' = 'Acknowledgement Required Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Document Effective Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `method` SET TAGS ('dbx_business_glossary_term' = 'Distribution Method');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `method` SET TAGS ('dbx_value_regex' = 'Veeva Vault Notification|Email|Physical|Fax|CTMS Portal');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Distribution Notes');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `recipient_email` SET TAGS ('dbx_business_glossary_term' = 'Recipient Email Address');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `recipient_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `recipient_email` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `recipient_email` SET TAGS ('dbx_pii_email' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `recipient_email` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `recipient_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `recipient_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `recipient_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `recipient_organization_type` SET TAGS ('dbx_value_regex' = 'Site|Sponsor|CRO|IRB/IEC|Regulatory Authority|Laboratory');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `reminder_sent` SET TAGS ('dbx_business_glossary_term' = 'Reminder Sent Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `scope` SET TAGS ('dbx_business_glossary_term' = 'Distribution Scope');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `scope` SET TAGS ('dbx_value_regex' = 'Global|Country|Site|Department|Individual');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `distribution_status` SET TAGS ('dbx_value_regex' = 'Pending|Sent|Delivered|Acknowledged|Overdue|Cancelled');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `tmf_artifact_number` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Artifact Number');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `tmf_zone` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Zone');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `training_required` SET TAGS ('dbx_business_glossary_term' = 'Training Required Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `veeva_vault_distribution_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Distribution ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`distribution` ALTER COLUMN `veeva_vault_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ADD CONSTRAINT `fk_document_regulatory_binder_indication_id` FOREIGN KEY (`indication_id`) REFERENCES `clinical_trials_ecm`.`program`.`indication`(`indication_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ADD CONSTRAINT `fk_document_regulatory_binder_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ADD CONSTRAINT `fk_document_regulatory_binder_program_strategic_plan_id` FOREIGN KEY (`program_strategic_plan_id`) REFERENCES `clinical_trials_ecm`.`program`.`program_strategic_plan`(`program_strategic_plan_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ADD CONSTRAINT `fk_document_regulatory_binder_regulatory_lead_employee_id` FOREIGN KEY (`regulatory_lead_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ADD CONSTRAINT `fk_document_regulatory_binder_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` SET TAGS ('dbx_domain' = 'document');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` SET TAGS ('dbx_subdomain' = 'regulatory_submission');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `indication_id` SET TAGS ('dbx_business_glossary_term' = 'Indication Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `program_strategic_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Program Plan Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `regulatory_lead_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Lead Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `regulatory_lead_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `regulatory_lead_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `regulatory_lead_employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `agency_action_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `agency_action_type` SET TAGS ('dbx_value_regex' = 'approval|complete_response|refuse_to_file|withdrawal|approvable|not_approvable');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `agency_action_type` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `agency_receipt_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `binder_number` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Binder Number');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `binder_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Binder Status');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `binder_status` SET TAGS ('dbx_value_regex' = 'in_preparation|submitted|under_review|approved|withdrawn');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `binder_title` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Binder Title');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `binder_type` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Binder Type');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `completeness_percentage` SET TAGS ('dbx_business_glossary_term' = 'Binder Completeness Percentage');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `completeness_percentage` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_value_regex' = 'restricted|confidential|internal|public');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `ctd_module` SET TAGS ('dbx_business_glossary_term' = 'Common Technical Document (CTD) Module');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `ctd_module` SET TAGS ('dbx_value_regex' = 'M1|M2|M3|M4|M5|full');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `ectd_version` SET TAGS ('dbx_business_glossary_term' = 'Electronic Common Technical Document (eCTD) Version');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `ectd_version` SET TAGS ('dbx_value_regex' = '3.2.2|4.0');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authorization Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `is_ectd_format` SET TAGS ('dbx_business_glossary_term' = 'Electronic Common Technical Document (eCTD) Format Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `is_inspection_ready` SET TAGS ('dbx_business_glossary_term' = 'Inspection Readiness Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Binder Notes');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `pdufa_target_date` SET TAGS ('dbx_business_glossary_term' = 'Prescription Drug User Fee Act (PDUFA) Target Action Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `review_pathway` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Review Pathway');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `review_pathway` SET TAGS ('dbx_value_regex' = 'standard|priority|accelerated|breakthrough|orphan|conditional');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `submission_category` SET TAGS ('dbx_value_regex' = 'original|amendment|supplement|annual_report|response');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `submission_medium` SET TAGS ('dbx_value_regex' = 'electronic|paper|hybrid');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `submission_sequence_number` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `target_agency` SET TAGS ('dbx_business_glossary_term' = 'Target Health Authority Agency');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `target_agency` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `veeva_vault_binder_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Regulatory Binder Reference ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `withdrawal_date` SET TAGS ('dbx_business_glossary_term' = 'Submission Withdrawal Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`regulatory_binder` ALTER COLUMN `withdrawal_reason` SET TAGS ('dbx_business_glossary_term' = 'Submission Withdrawal Reason');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ADD CONSTRAINT `fk_document_binder_document_qc_reviewer_employee_id` FOREIGN KEY (`qc_reviewer_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ADD CONSTRAINT `fk_document_binder_document_regulatory_binder_id` FOREIGN KEY (`regulatory_binder_id`) REFERENCES `clinical_trials_ecm`.`document`.`regulatory_binder`(`regulatory_binder_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ADD CONSTRAINT `fk_document_binder_document_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ADD CONSTRAINT `fk_document_binder_document_version_id` FOREIGN KEY (`version_id`) REFERENCES `clinical_trials_ecm`.`document`.`version`(`version_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` SET TAGS ('dbx_domain' = 'document');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` SET TAGS ('dbx_subdomain' = 'regulatory_submission');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `qc_reviewer_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Qc Reviewer Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `qc_reviewer_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `qc_reviewer_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `qc_reviewer_employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `version_id` SET TAGS ('dbx_business_glossary_term' = 'Document Version ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `added_date` SET TAGS ('dbx_business_glossary_term' = 'Date Added to Binder');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `added_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Timestamp Added to Binder');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Binder Document Approval Status');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'draft|pending_approval|approved|superseded|withdrawn');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_business_glossary_term' = 'Document Confidentiality Level');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_value_regex' = 'public|confidential|restricted|highly_restricted');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `ctd_section_code` SET TAGS ('dbx_business_glossary_term' = 'Common Technical Document (CTD) Section Code');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `ctd_section_code` SET TAGS ('dbx_value_regex' = '^[1-5](.[0-9]+(.[0-9]+(.[0-9]+)?)?)?$');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `ctd_section_title` SET TAGS ('dbx_business_glossary_term' = 'Common Technical Document (CTD) Section Title');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `document_role` SET TAGS ('dbx_business_glossary_term' = 'Document Role in Submission');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `document_role` SET TAGS ('dbx_value_regex' = 'original|replacement|withdrawal|amendment|addendum');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `inclusion_type` SET TAGS ('dbx_business_glossary_term' = 'Document Inclusion Type');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `inclusion_type` SET TAGS ('dbx_value_regex' = 'primary|supporting|reference|appendix|cover');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `inspection_readiness_status` SET TAGS ('dbx_value_regex' = 'ready|gap_identified|remediation_in_progress|not_assessed');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `is_mandatory` SET TAGS ('dbx_business_glossary_term' = 'Is Mandatory Document Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `is_placeholder` SET TAGS ('dbx_business_glossary_term' = 'Is Placeholder Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `language_code` SET TAGS ('dbx_business_glossary_term' = 'Document Language Code');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `language_code` SET TAGS ('dbx_value_regex' = '^[a-z]{2}(-[A-Z]{2})?$');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `language_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Binder Document Notes');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `qc_comments` SET TAGS ('dbx_business_glossary_term' = 'Quality Control (QC) Review Comments');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `qc_review_date` SET TAGS ('dbx_business_glossary_term' = 'Quality Control (QC) Review Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `qc_review_status` SET TAGS ('dbx_business_glossary_term' = 'Quality Control (QC) Review Status');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `qc_review_status` SET TAGS ('dbx_value_regex' = 'pending|in_review|approved|rejected|waived');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `redaction_required` SET TAGS ('dbx_business_glossary_term' = 'Redaction Required Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `removed_date` SET TAGS ('dbx_business_glossary_term' = 'Date Removed from Binder');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `submission_sequence_number` SET TAGS ('dbx_business_glossary_term' = 'eCTD Submission Sequence Number');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `submission_sequence_number` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `submission_type` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission Type');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `tmf_reference_model_artifact` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Reference Model Artifact Code');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `tmf_reference_model_zone` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Reference Model Zone');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `translation_required` SET TAGS ('dbx_business_glossary_term' = 'Translation Required Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `vault_binder_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Binder ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`binder_document` ALTER COLUMN `vault_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` ADD CONSTRAINT `fk_document_archival_record_archival_authorized_by_employee_id` FOREIGN KEY (`archival_authorized_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` ADD CONSTRAINT `fk_document_archival_record_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` ADD CONSTRAINT `fk_document_archival_record_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` ADD CONSTRAINT `fk_document_archival_record_tmf_artifact_id` FOREIGN KEY (`tmf_artifact_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_artifact`(`tmf_artifact_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` ADD CONSTRAINT `fk_document_archival_record_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` ADD CONSTRAINT `fk_document_archival_record_version_id` FOREIGN KEY (`version_id`) REFERENCES `clinical_trials_ecm`.`document`.`version`(`version_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` SET TAGS ('dbx_domain' = 'document');

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` SET TAGS ('dbx_subdomain' = 'regulatory_submission');

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` ALTER COLUMN `archival_authorized_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Archival Authorized By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` ALTER COLUMN `archival_authorized_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` ALTER COLUMN `archival_authorized_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` ALTER COLUMN `archival_authorized_by_employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` ALTER COLUMN `tmf_artifact_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Artifact Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Document ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` ALTER COLUMN `version_id` SET TAGS ('dbx_business_glossary_term' = 'Document Version Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` ALTER COLUMN `archival_status` SET TAGS ('dbx_value_regex' = 'pending|archived|retrieved|destroyed|on_hold');

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` ALTER COLUMN `archival_type` SET TAGS ('dbx_value_regex' = 'electronic|physical|hybrid');

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` ALTER COLUMN `archive_facility_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` ALTER COLUMN `custodian_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` ALTER COLUMN `custodian_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` ALTER COLUMN `custodian_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` ALTER COLUMN `database_lock_date` SET TAGS ('dbx_business_glossary_term' = 'Database Lock (DBL) Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` ALTER COLUMN `destruction_method` SET TAGS ('dbx_value_regex' = 'shredding|incineration|secure_digital_deletion|degaussing|other');

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` ALTER COLUMN `document_classification` SET TAGS ('dbx_value_regex' = 'essential_document|non_essential|regulatory_submission|site_file|sponsor_file');

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` ALTER COLUMN `etmf_vault_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Electronic Trial Master File (eTMF) Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` ALTER COLUMN `retention_period_years` SET TAGS ('dbx_business_glossary_term' = 'Retention Period (Years)');

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` ALTER COLUMN `retrieval_reason` SET TAGS ('dbx_value_regex' = 'regulatory_inspection|audit|litigation|study_amendment|sponsor_request|other');

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` ALTER COLUMN `study_closeout_date` SET TAGS ('dbx_business_glossary_term' = 'Study Close-Out Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` ALTER COLUMN `tmf_reference_model_zone` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Reference Model Zone');

ALTER TABLE `clinical_trials_ecm`.`document`.`archival_record` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ADD CONSTRAINT `fk_document_access_log_electronic_signature_id` FOREIGN KEY (`electronic_signature_id`) REFERENCES `clinical_trials_ecm`.`document`.`signature`(`signature_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ADD CONSTRAINT `fk_document_access_log_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ADD CONSTRAINT `fk_document_access_log_regulatory_inspection_id` FOREIGN KEY (`regulatory_inspection_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`regulatory_inspection`(`regulatory_inspection_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ADD CONSTRAINT `fk_document_access_log_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ADD CONSTRAINT `fk_document_access_log_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ADD CONSTRAINT `fk_document_access_log_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ADD CONSTRAINT `fk_document_access_log_vault_document_version_id` FOREIGN KEY (`vault_document_version_id`) REFERENCES `clinical_trials_ecm`.`document`.`version`(`version_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` SET TAGS ('dbx_domain' = 'document');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` SET TAGS ('dbx_subdomain' = 'control_lifecycle');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `access_log_id` SET TAGS ('dbx_business_glossary_term' = 'Document Access Log ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `electronic_signature_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `electronic_signature_id` SET TAGS ('dbx_pii_signature' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'User ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `regulatory_inspection_id` SET TAGS ('dbx_business_glossary_term' = 'Inspection ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `vault_document_version_id` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document Version ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `access_action` SET TAGS ('dbx_value_regex' = 'view|download|print|edit|delete');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `access_channel` SET TAGS ('dbx_value_regex' = 'web_browser|vault_api|mobile_app|integration');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `access_device_type` SET TAGS ('dbx_value_regex' = 'desktop|laptop|tablet|mobile|server');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `access_result` SET TAGS ('dbx_value_regex' = 'success|denied|error|timeout');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `document_confidentiality_level` SET TAGS ('dbx_value_regex' = 'restricted|confidential|internal|public');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `document_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `document_status_at_access` SET TAGS ('dbx_business_glossary_term' = 'Document Status at Time of Access');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `document_status_at_access` SET TAGS ('dbx_value_regex' = 'draft|in_review|approved|superseded|obsolete|archived');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `download_file_format` SET TAGS ('dbx_value_regex' = 'PDF|DOCX|XLSX|CSV|XML|other');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `inspection_context` SET TAGS ('dbx_business_glossary_term' = 'Inspection Context Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `is_anomalous_access` SET TAGS ('dbx_business_glossary_term' = 'Anomalous Access Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `justification_provided` SET TAGS ('dbx_business_glossary_term' = 'Justification Provided Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `justification_required` SET TAGS ('dbx_business_glossary_term' = 'Justification Required Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `signature_meaning` SET TAGS ('dbx_business_glossary_term' = 'Electronic Signature Meaning');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `signature_meaning` SET TAGS ('dbx_value_regex' = 'approved|reviewed|authored|witnessed');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `signature_meaning` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `signature_meaning` SET TAGS ('dbx_pii_signature' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `source_ip_address` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `source_ip_address` SET TAGS ('dbx_pii_ip' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `tmf_section` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Section');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `tmf_zone` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Zone');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `user_full_name` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `user_full_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `user_full_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `user_full_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `vault_audit_trail_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Audit Trail ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `vault_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`access_log` ALTER COLUMN `vault_session_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Session ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ADD CONSTRAINT `fk_document_etmf_exchange_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ADD CONSTRAINT `fk_document_etmf_exchange_master_agreement_id` FOREIGN KEY (`master_agreement_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`master_agreement`(`master_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ADD CONSTRAINT `fk_document_etmf_exchange_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ADD CONSTRAINT `fk_document_etmf_exchange_resubmission_of_exchange_id` FOREIGN KEY (`resubmission_of_exchange_id`) REFERENCES `clinical_trials_ecm`.`document`.`etmf_exchange`(`etmf_exchange_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ADD CONSTRAINT `fk_document_etmf_exchange_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ADD CONSTRAINT `fk_document_etmf_exchange_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` SET TAGS ('dbx_domain' = 'document');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` SET TAGS ('dbx_subdomain' = 'trial_master');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `etmf_exchange_id` SET TAGS ('dbx_business_glossary_term' = 'Electronic Trial Master File (eTMF) Exchange ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Program Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `master_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Preferred Provider Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Organization ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Exchange Document Item - Tmf Document Id');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `acknowledgement_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Acknowledgement Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `archival_flag` SET TAGS ('dbx_business_glossary_term' = 'Archival Exchange Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `checksum_algorithm` SET TAGS ('dbx_value_regex' = 'MD5|SHA-1|SHA-256|SHA-512');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `checksum_value` SET TAGS ('dbx_business_glossary_term' = 'Package Checksum Value');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `dmp_version` SET TAGS ('dbx_business_glossary_term' = 'Data Management Plan (DMP) Version');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `encryption_method` SET TAGS ('dbx_value_regex' = 'AES-256|PGP|TLS_1_2|TLS_1_3|none');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `exchange_date` SET TAGS ('dbx_business_glossary_term' = 'eTMF Exchange Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `exchange_direction` SET TAGS ('dbx_business_glossary_term' = 'eTMF Exchange Direction');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `exchange_direction` SET TAGS ('dbx_value_regex' = 'cro_to_sponsor|sponsor_to_cro');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `exchange_frequency` SET TAGS ('dbx_business_glossary_term' = 'eTMF Exchange Frequency');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `exchange_frequency` SET TAGS ('dbx_value_regex' = 'weekly|monthly|quarterly|milestone|ad_hoc');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `exchange_manifest_reference` SET TAGS ('dbx_business_glossary_term' = 'eTMF Exchange Manifest ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `exchange_notes` SET TAGS ('dbx_business_glossary_term' = 'eTMF Exchange Notes');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `exchange_reference_number` SET TAGS ('dbx_business_glossary_term' = 'eTMF Exchange Reference Number');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `exchange_type` SET TAGS ('dbx_business_glossary_term' = 'eTMF Exchange Type');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `exchange_type` SET TAGS ('dbx_value_regex' = 'routine|ad_hoc|inspection|closeout|interim');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `initiating_party` SET TAGS ('dbx_value_regex' = 'cro|sponsor');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `integrity_verified` SET TAGS ('dbx_business_glossary_term' = 'Package Integrity Verified Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `package_name` SET TAGS ('dbx_business_glossary_term' = 'eTMF Document Package Name');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `package_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `package_size_mb` SET TAGS ('dbx_business_glossary_term' = 'Document Package Size (MB)');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `package_size_mb` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `received_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Package Received Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `receiver_contact_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `receiver_contact_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `receiver_contact_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `receiver_vault_reference` SET TAGS ('dbx_business_glossary_term' = 'Receiver Veeva Vault ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `rejection_code` SET TAGS ('dbx_business_glossary_term' = 'Exchange Rejection Code');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `rejection_reason` SET TAGS ('dbx_business_glossary_term' = 'Exchange Rejection Reason');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `sender_contact_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `sender_contact_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `sender_contact_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `sender_vault_reference` SET TAGS ('dbx_business_glossary_term' = 'Sender Veeva Vault ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `sequence_order` SET TAGS ('dbx_business_glossary_term' = 'Package Sequence Order');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `study_phase` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study Phase');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `study_phase` SET TAGS ('dbx_value_regex' = 'Phase I|Phase II|Phase III|Phase IV|Phase I/II');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `tmf_artifact_type` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Artifact Type');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `tmf_section` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Section');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `tmf_zone` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Zone');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `tmf_zone` SET TAGS ('dbx_value_regex' = 'trial_management|site_management|ip_management');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `transfer_method` SET TAGS ('dbx_business_glossary_term' = 'eTMF Transfer Method');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `transfer_method` SET TAGS ('dbx_value_regex' = 'veeva_vault_cross_account|sftp|api|manual_upload|secure_email');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `transfer_status` SET TAGS ('dbx_business_glossary_term' = 'eTMF Transfer Status');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `transfer_status` SET TAGS ('dbx_value_regex' = 'initiated|in_transit|received|acknowledged|rejected');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`etmf_exchange` ALTER COLUMN `veeva_vault_job_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Job ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ADD CONSTRAINT `fk_document_document_icf_version_prepared_by_employee_id` FOREIGN KEY (`prepared_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ADD CONSTRAINT `fk_document_document_icf_version_regulatory_protocol_amendment_id` FOREIGN KEY (`regulatory_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment`(`regulatory_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ADD CONSTRAINT `fk_document_document_icf_version_superseded_by_version_document_icf_version_id` FOREIGN KEY (`superseded_by_version_document_icf_version_id`) REFERENCES `clinical_trials_ecm`.`document`.`document_icf_version`(`document_icf_version_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ADD CONSTRAINT `fk_document_document_icf_version_tmf_artifact_id` FOREIGN KEY (`tmf_artifact_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_artifact`(`tmf_artifact_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ADD CONSTRAINT `fk_document_document_icf_version_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ADD CONSTRAINT `fk_document_document_icf_version_version_id` FOREIGN KEY (`version_id`) REFERENCES `clinical_trials_ecm`.`document`.`version`(`version_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` SET TAGS ('dbx_domain' = 'document');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` SET TAGS ('dbx_subdomain' = 'control_lifecycle');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `document_icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Version ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `prepared_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Prepared By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `prepared_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `prepared_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `prepared_by_employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `regulatory_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `superseded_by_version_document_icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By ICF Version ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `tmf_artifact_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Artifact Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `version_id` SET TAGS ('dbx_business_glossary_term' = 'Document Version Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Document Approval Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `cdisc_domain` SET TAGS ('dbx_business_glossary_term' = 'Clinical Data Interchange Standards Consortium (CDISC) Domain Code');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `cdisc_domain` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `cdisc_domain` SET TAGS ('dbx_standard_ref' = 'SDISC CDISC Domain');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `document_status` SET TAGS ('dbx_business_glossary_term' = 'ICF Document Status');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `document_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|superseded|retired|archived');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `document_title` SET TAGS ('dbx_business_glossary_term' = 'ICF Document Title');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `econsent_enabled` SET TAGS ('dbx_business_glossary_term' = 'Electronic Consent (eConsent) Enabled Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `econsent_platform` SET TAGS ('dbx_business_glossary_term' = 'Electronic Consent (eConsent) Platform');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `econsent_platform` SET TAGS ('dbx_value_regex' = 'clinpal|medidata_rave|oracle_clinical_one|paper|other');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'ICF Version Effective Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `gdpr_applicable` SET TAGS ('dbx_business_glossary_term' = 'General Data Protection Regulation (GDPR) Applicable Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `hipaa_applicable` SET TAGS ('dbx_business_glossary_term' = 'Health Insurance Portability and Accountability Act (HIPAA) Applicable Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `icf_type` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Type');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `icf_type` SET TAGS ('dbx_value_regex' = 'main_consent|assent|hipaa_authorization|optional_procedures|lar_consent|short_form');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `irb_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Approval Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `irb_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Approval Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `is_current_version` SET TAGS ('dbx_business_glossary_term' = 'Current Version Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `is_inspection_ready` SET TAGS ('dbx_business_glossary_term' = 'Inspection Readiness Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `language_code` SET TAGS ('dbx_value_regex' = '^[a-z]{2,3}(-[A-Z]{2})?$');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `language_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `protocol_version_number` SET TAGS ('dbx_value_regex' = '^[A-Za-z0-9._-]{1,20}$');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `reconsent_deadline` SET TAGS ('dbx_business_glossary_term' = 'Re-consent Deadline Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `reconsent_required` SET TAGS ('dbx_business_glossary_term' = 'Re-consent Required Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `sponsor_provided` SET TAGS ('dbx_business_glossary_term' = 'Sponsor-Provided ICF Flag');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `subject_population` SET TAGS ('dbx_value_regex' = 'adult|pediatric|lar|adolescent|geriatric');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `superseded_date` SET TAGS ('dbx_business_glossary_term' = 'ICF Version Superseded Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `tmf_zone` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Zone');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `vault_document_number` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document Number');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `vault_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`document_icf_version` ALTER COLUMN `vault_lifecycle_state` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Lifecycle State');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ADD CONSTRAINT `fk_document_template_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ADD CONSTRAINT `fk_document_template_owner_employee_id` FOREIGN KEY (`owner_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ADD CONSTRAINT `fk_document_template_primary_superseded_by_template_id` FOREIGN KEY (`primary_superseded_by_template_id`) REFERENCES `clinical_trials_ecm`.`document`.`template`(`template_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ADD CONSTRAINT `fk_document_template_tmf_artifact_id` FOREIGN KEY (`tmf_artifact_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_artifact`(`tmf_artifact_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`template` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` SET TAGS ('dbx_domain' = 'document');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` SET TAGS ('dbx_subdomain' = 'control_lifecycle');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `template_id` SET TAGS ('dbx_business_glossary_term' = 'Document Template ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `owner_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Template Owner Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `owner_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `owner_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `owner_employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `primary_superseded_by_template_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Template ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `tmf_artifact_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Artifact Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `applicability_scope` SET TAGS ('dbx_business_glossary_term' = 'Template Applicability Scope');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `applicability_scope` SET TAGS ('dbx_value_regex' = 'GLOBAL|REGIONAL|COUNTRY_SPECIFIC|SPONSOR_SPECIFIC|THERAPEUTIC_AREA_SPECIFIC|PHASE_SPECIFIC');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `applicable_study_phase` SET TAGS ('dbx_business_glossary_term' = 'Applicable Clinical Study Phase');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `applicable_study_phase` SET TAGS ('dbx_value_regex' = 'PHASE_I|PHASE_II|PHASE_III|PHASE_IV|ALL_PHASES');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Template Approval Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `archival_date` SET TAGS ('dbx_business_glossary_term' = 'Template Archival Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `cdisc_standard_reference` SET TAGS ('dbx_business_glossary_term' = 'Clinical Data Interchange Standards Consortium (CDISC) Standard Reference');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `cdisc_standard_reference` SET TAGS ('dbx_standard_ref' = 'CDISC Standard Reference');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `change_description` SET TAGS ('dbx_business_glossary_term' = 'Version Change Description');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `change_reason` SET TAGS ('dbx_business_glossary_term' = 'Version Change Reason');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `change_reason` SET TAGS ('dbx_value_regex' = 'REGULATORY_UPDATE|PROCESS_IMPROVEMENT|ERROR_CORRECTION|SPONSOR_REQUIREMENT|PERIODIC_REVIEW|INITIAL_CREATION');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `template_code` SET TAGS ('dbx_business_glossary_term' = 'Document Template Code');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `template_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,10}-TMPL-[0-9]{4,8}$');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `ectd_section_reference` SET TAGS ('dbx_business_glossary_term' = 'Electronic Common Technical Document (eCTD) Section Reference');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Template Effective Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `file_format` SET TAGS ('dbx_business_glossary_term' = 'Template File Format');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `file_format` SET TAGS ('dbx_value_regex' = 'DOCX|PDF|XLSX|PDF_FORM|XML|RTF');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `inspection_readiness_status` SET TAGS ('dbx_value_regex' = 'READY|NEEDS_REVIEW|NOT_APPLICABLE|OVERDUE');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `is_econsent_compatible` SET TAGS ('dbx_business_glossary_term' = 'Electronic Consent (eConsent) Compatible Indicator');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `is_mandatory` SET TAGS ('dbx_business_glossary_term' = 'Mandatory Template Indicator');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `language_code` SET TAGS ('dbx_business_glossary_term' = 'Template Language Code');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `language_code` SET TAGS ('dbx_value_regex' = '^[a-z]{2}(-[A-Z]{2})?$');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `language_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `lifecycle_status` SET TAGS ('dbx_business_glossary_term' = 'Template Lifecycle Status');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `mastercontrol_document_reference` SET TAGS ('dbx_business_glossary_term' = 'MasterControl Document ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `template_name` SET TAGS ('dbx_business_glossary_term' = 'Document Template Name');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `template_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Scheduled Review Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `regulatory_authority` SET TAGS ('dbx_business_glossary_term' = 'Applicable Regulatory Authority');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `retirement_date` SET TAGS ('dbx_business_glossary_term' = 'Template Retirement Date');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `review_frequency_months` SET TAGS ('dbx_business_glossary_term' = 'Periodic Review Frequency (Months)');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `training_required` SET TAGS ('dbx_business_glossary_term' = 'Training Required Indicator');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `template_type` SET TAGS ('dbx_business_glossary_term' = 'Document Template Type');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `veeva_vault_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Template Version Number');

ALTER TABLE `clinical_trials_ecm`.`document`.`template` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_ecm`.`document`.`delegation_of_authority` ADD CONSTRAINT `fk_document_delegation_of_authority_principal_investigator_id` FOREIGN KEY (`principal_investigator_id`) REFERENCES `clinical_trials_ecm`.`site`.`principal_investigator`(`principal_investigator_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`delegation_of_authority` ADD CONSTRAINT `fk_document_delegation_of_authority_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`delegation_of_authority` ADD CONSTRAINT `fk_document_delegation_of_authority_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`delegation_of_authority` ADD CONSTRAINT `fk_document_delegation_of_authority_superseded_delegation_of_authority_id` FOREIGN KEY (`superseded_delegation_of_authority_id`) REFERENCES `clinical_trials_ecm`.`document`.`delegation_of_authority`(`delegation_of_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`delegation_of_authority` ADD CONSTRAINT `fk_document_delegation_of_authority_tmf_artifact_id` FOREIGN KEY (`tmf_artifact_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_artifact`(`tmf_artifact_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`delegation_of_authority` ADD CONSTRAINT `fk_document_delegation_of_authority_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`document`.`delegation_of_authority` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`document`.`delegation_of_authority` SET TAGS ('dbx_domain' = 'document');

ALTER TABLE `clinical_trials_ecm`.`document`.`delegation_of_authority` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`document`.`delegation_of_authority` SET TAGS ('dbx_subdomain' = 'trial_master');

ALTER TABLE `clinical_trials_ecm`.`document`.`delegation_of_authority` ALTER COLUMN `delegation_of_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Delegation Of Authority Identifier');

ALTER TABLE `clinical_trials_ecm`.`document`.`delegation_of_authority` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site Id');

ALTER TABLE `clinical_trials_ecm`.`document`.`delegation_of_authority` ALTER COLUMN `superseded_delegation_of_authority_id` SET TAGS ('dbx_self_ref_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`delegation_of_authority` ALTER COLUMN `tmf_artifact_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Artifact Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`delegation_of_authority` ALTER COLUMN `tmf_artifact_id` SET TAGS ('dbx_standard_ref' = 'DIA TMF Reference Model Artifact');

ALTER TABLE `clinical_trials_ecm`.`document`.`delegation_of_authority` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`document`.`delegation_of_authority` ALTER COLUMN `approved_by` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`delegation_of_authority` ALTER COLUMN `approved_by` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`delegation_of_authority` ALTER COLUMN `approved_by` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`delegation_of_authority` ALTER COLUMN `electronic_signature_applied` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`delegation_of_authority` ALTER COLUMN `electronic_signature_applied` SET TAGS ('dbx_pii_signature' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`delegation_of_authority` ALTER COLUMN `language` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`delegation_of_authority` ALTER COLUMN `pi_signature_date` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`delegation_of_authority` ALTER COLUMN `pi_signature_date` SET TAGS ('dbx_pii_signature' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`delegation_of_authority` ALTER COLUMN `sponsor_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`document`.`delegation_of_authority` ALTER COLUMN `delegation_of_authority_status` SET TAGS ('dbx_business_glossary_term' = 'Status');

ALTER TABLE `clinical_trials_ecm`.`document`.`delegation_of_authority` ALTER COLUMN `storage_location` SET TAGS ('dbx_pii' = 'true');
