-- Schema for Domain: document | Business: Clinical_Trials | Version: v2_mvm
-- Generated on: 2026-11-20 12:39:47

CREATE DATABASE IF NOT EXISTS `clinical_trials_mvm`.`document` COMMENT 'SSOT for Trial Master File (TMF/eTMF) essential documents, SOP library, regulatory binders, site files, controlled document versioning, document workflows, DIA TMF Reference Model compliance, inspection readiness, and archival per ICH GCP requirements.';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`document`.`tmf_document` (
    `tmf_document_id` BIGINT COMMENT 'Unique surrogate identifier for each logical TMF document record in the Silver Layer lakehouse. This is the primary key for the tmf_document entity. Role: MASTER_RESOURCE.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.compliance_sop. Business justification: GCP inspection readiness requires knowing which SOP governs each TMF documents creation, filing, and retention.',
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

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` (
    `tmf_artifact_id` BIGINT COMMENT 'Unique surrogate identifier for each TMF artifact taxonomy record in the DIA TMF Reference Model. This is the primary key for the tmf_artifact reference entity.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.compliance_sop. Business justification: Each TMF artifact type (e.g., IB, ICF, protocol) is governed by a specific document control SOP defining its creation, review, and filing requirements.',
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

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`document`.`version` (
    `version_id` BIGINT COMMENT 'Unique surrogate identifier for each discrete version record of a controlled document in the Trial Master File (TMF) or Standard Operating Procedure (SOP) library. Primary key of this table.',
    `controlled_terminology_codelist_id` BIGINT COMMENT 'Optional CDISC CT codelist governing categorical values on this record.',
    `document_sop_id` BIGINT COMMENT 'Foreign key linking to document.document_sop. Business justification: The version table description explicitly states it tracks the full version history of every controlled document in the TMF and SOP library. Currently version only has tmf_document_id',
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
    `study_protocol_number` STRING COMMENT 'The sponsor-assigned protocol number of the clinical study to which this document version is associated, if applicable. Null for enterprise-level SOPs not tied to a specific study. Enables study-level TMF completeness reporting.',
    `superseded_date` DATE COMMENT 'The date on which this document version was superseded by a newer approved version. Null if the version is still current or was never approved. Used to determine the active version at any point in time for historical audit queries.',
    `tmf_section` STRING COMMENT 'The specific section or artifact number within the DIA TMF Reference Model zone (e.g., 01.01, 02.03, 05.07). Used for precise eTMF filing, completeness tracking, and inspection readiness reporting.',
    `tmf_zone` STRING COMMENT 'The DIA TMF Reference Model zone to which this document belongs. Zone 1 = Trial Management; Zone 2 = Central Trial Documents; Zone 3 = Regulatory; Zone 4 = Investigational Product; Zone 5 = Site Management.. Valid values are `zone_1|zone_2|zone_3|zone_4|zone_5`',
    `training_completion_deadline` DATE COMMENT 'The date by which all required staff must complete training on this document version. Null if training is not required. Used to monitor training compliance and flag overdue training in MasterControl.',
    `training_required` BOOLEAN COMMENT 'Indicates whether staff training is required upon approval of this document version. True for major version changes to SOPs and GCP-critical documents. Drives training assignment workflows in MasterControl.',
    `vault_document_version_reference` STRING COMMENT 'The native document version identifier assigned by Veeva Vault (eTMF/QMS module). Used to trace this Silver Layer record back to its source system record for reconciliation and audit purposes.',
    `vault_lifecycle_state` STRING COMMENT 'The native lifecycle state label as recorded in Veeva Vault for this document version (e.g., Draft, In Review, Approved, Superseded). Preserved from the source system to enable reconciliation between the Silver Layer and Veeva Vault.',
    `version_status` STRING COMMENT 'Current lifecycle state of this document version within the controlled document workflow. draft = under authorship; in_review = circulated for review/approval; approved = effective and in use; superseded = replaced by a newer approved version. Valid values are `draft|in_review|approved|superseded|obsolete|withdrawn`',
    CONSTRAINT pk_version PRIMARY KEY(`version_id`)
) COMMENT 'Tracks the full version history of every controlled document in the TMF and SOP library. Each record represents a discrete version of a document, capturing version number, effective date, expiry date, version status (draft, in-review, approved';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`document`.`document_sop` (
    `document_sop_id` BIGINT COMMENT 'Unique surrogate identifier for each SOP record in the controlled document library. Primary key for the document_sop entity. Role: MASTER_RESOURCE.',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — SOPs may be study-specific',
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

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`document`.`workflow` (
    `workflow_id` BIGINT COMMENT 'Unique surrogate identifier for each document workflow instance in the Databricks Silver Layer. Primary key for the document_workflow data product.',
    `audit_id` BIGINT COMMENT 'Foreign key linking to compliance.audit. Business justification: Audit reports require formal document review and approval workflows before issuance (QA review, sponsor sign-off).',
    `document_sop_id` BIGINT COMMENT 'Foreign key linking to document.document_sop. Business justification: SOPs undergo formal review, approval, and distribution workflows governed by the document_workflow entity.',
    `regulatory_binder_id` BIGINT COMMENT 'Foreign key linking to document.regulatory_binder. Business justification: Workflow tracks the lifecycle of documents through review, approval, and distribution processes.',
    `site_file_id` BIGINT COMMENT 'Foreign key linking to document.site_file. Business justification: Workflow tracks document lifecycle including site file review, completeness assessment, and inspection readiness workflows.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study associated with this document workflow. Enables study-level aggregation of document control activities for inspection readiness and TMF completeness reporting.',
    `study_site_id` BIGINT COMMENT 'Foreign key linking to site.study_site. Business justification: Many document workflows are site-specific: site file reviews, site-level regulatory submissions, site activation document packages, and closeout document processing.',
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
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this document_workflow record was last modified in the Databricks Silver Layer. Tracks the most recent state change for incremental processing and audit trail completeness.',
    `workflow_status` STRING COMMENT 'Current lifecycle state of the document workflow instance within Veeva Vault. Tracks progression from initiation through review, approval decision, and terminal states. Supports GCP-compliant document control audit trails.. Valid values are `initiated|in-review|pending-approval|approved|rejected|cancelled`',
    `workflow_type` STRING COMMENT 'Classification of the workflow by its primary business purpose within the document lifecycle. Distinguishes review-only workflows from approval workflows, distribution workflows, archival workflows, and amendment workflows.. Valid values are `review|approval|distribution|archival|cancellation|amendment`',
    CONSTRAINT pk_workflow PRIMARY KEY(`workflow_id`)
) COMMENT 'Tracks the lifecycle workflow state of a document through its review, approval, and distribution process within Veeva Vault. Captures workflow instance ID, workflow template name, current workflow step, step assignee role, step due date, step completion';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`document`.`signature` (
    `signature_id` BIGINT COMMENT 'Unique surrogate identifier for each electronic signature record applied to a controlled document. Primary key for the document_signature data product in the Databricks Silver Layer.',
    `principal_investigator_id` BIGINT COMMENT 'Reference to the delegation of authority record when the signer is acting on behalf of another party (e.g., a sub-investigator signing on behalf of the Principal Investigator). Supports sponsor oversight and GCP compliance verification.',
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
    `signature_status` STRING COMMENT 'Current lifecycle status of the electronic signature record. Pending = awaiting signer action; Applied = successfully executed; Voided = invalidated due to document revision or administrative action; Superseded = replaced by a newer signature; Rejected =. Valid values are `pending|applied|voided|superseded|rejected`',
    `signature_type` STRING COMMENT 'Classification of the signature type per applicable regulatory framework. Electronic = standard 21 CFR Part 11 e-signature; Wet Ink Scanned = paper signature digitized; Advanced Electronic = eIDAS AES; Qualified Electronic = eIDAS QES with qualified. Valid values are `electronic|wet_ink_scanned|advanced_electronic|qualified_electronic`',
    `signed_timestamp` TIMESTAMP COMMENT 'The precise date and time (with timezone offset) at which the electronic signature was applied by the signer. This is the principal real-world event timestamp for the signature transaction.',
    `signer_full_name` STRING COMMENT 'Full legal name of the individual who applied the electronic signature, captured at the time of signing. Stored as a point-in-time snapshot to preserve the audit trail even if the user record changes.',
    `signer_organization` STRING COMMENT 'Name of the organization or company the signer represents at the time of signing (e.g., sponsor company name, CRO name, investigative site institution). Supports multi-party trial agreements and sponsor delegation tracking.',
    `signer_role` STRING COMMENT 'Functional role of the signer within the document workflow at the time of signing. Determines the legal weight and workflow position of the signature. [ENUM-REF-CANDIDATE. Valid values are `author|reviewer|approver|sponsor_representative|quality_assurance|investigator`',
    `signer_title` STRING COMMENT 'Professional title or job designation of the signer at the time of signing (e.g., Principal Investigator, Medical Monitor, Sponsor Representative, Biostatistician). Captured as a point-in-time snapshot for regulatory inspection readiness.',
    `source_system_signature_reference` STRING COMMENT 'Native identifier of the signature record in the originating source system (e.g., Veeva Vault internal signature object ID). Enables bidirectional traceability between the Silver Layer and the operational system for reconciliation and audit.',
    `timezone` STRING COMMENT 'IANA timezone identifier representing the local timezone of the signer at the time of signing (e.g., America/New_York, Europe/London). Required to accurately interpret the signed_timestamp in multi-national trial contexts and for regulatory inspection.',
    `tmf_artifact_number` STRING COMMENT 'DIA TMF Reference Model artifact number identifying the document type being signed (e.g., 01.01.01 for Protocol, 06.02.01 for Informed Consent Form). Enables artifact-level signature completeness tracking.',
    `tmf_zone` STRING COMMENT 'DIA TMF Reference Model Zone classification of the document to which this signature belongs (e.g., Zone 01 - Trial Management, Zone 02 - Central Trial Documents, Zone 03 - Regulatory). Supports TMF completeness metrics and inspection readiness reporting.',
    `updated_timestamp` TIMESTAMP COMMENT 'System-generated timestamp of the most recent modification to the signature record (e.g., status change, void action). Required for audit trail completeness and change detection in the Silver Layer ETL pipeline.',
    `void_reason` STRING COMMENT 'Free-text explanation for why the signature was voided or invalidated. Required when signature_status = voided to maintain a complete and auditable record of signature lifecycle events per 21 CFR Part 11.',
    `voided_timestamp` TIMESTAMP COMMENT 'Date and time when the signature was voided or invalidated. Supports the complete lifecycle audit trail for the signature record and regulatory inspection readiness.',
    `workflow_step_name` STRING COMMENT 'Name of the document workflow step within which this signature was collected (e.g., Author Review, QA Approval, Sponsor Sign-Off). Maps to the Veeva Vault workflow configuration and supports workflow analytics and bottleneck identification.',
    `workflow_step_sequence` BIGINT COMMENT 'Numeric sequence position of this signature step within the overall document approval workflow. Enables ordered reconstruction of the full signature chain for regulatory inspection and audit trail review.',
    CONSTRAINT pk_signature PRIMARY KEY(`signature_id`)
) COMMENT 'Records electronic signatures applied to controlled documents per 21 CFR Part 11 requirements. Captures signer identity, signer role (author, reviewer, approver, sponsor representative), signature date and timestamp, signature meaning (reviewed, approved';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`document`.`site_file` (
    `site_file_id` BIGINT COMMENT 'Unique surrogate identifier for the Investigator Site File (ISF) or Regulatory Binder record in the lakehouse. Primary key for this entity.',
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

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` (
    `regulatory_binder_id` BIGINT COMMENT 'Unique surrogate identifier for the regulatory binder record in the lakehouse. Primary key for this entity.',
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

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`document`.`regulatory_filing` (
    `regulatory_filing_id` BIGINT COMMENT 'Unique surrogate identifier for each regulatory filing record representing the inclusion of a specific TMF document in a specific regulatory binder',
    `regulatory_binder_id` BIGINT COMMENT 'Foreign key linking to the regulatory submission binder that contains this document filing',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to the TMF document that is filed in this regulatory submission',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this regulatory filing record was first created in the system.',
    `ctd_section` STRING COMMENT 'The specific CTD module and section number where this document is filed within the eCTD structure (e.g., M1.2.1, M5.3.5.1). This is relationship-specific because the same document may be filed in different CTD sections across different submissions.',
    `document_role_in_submission` STRING COMMENT 'The functional role or purpose this document serves within this specific regulatory submission (e.g., primary evidence, supporting document, reference material, superseded version). The same document may have different roles in different submissions.',
    `filing_date` DATE COMMENT 'The date on which this specific document was incorporated into this specific regulatory binder. Tracks when the document was added to the submission package, which may differ from the documents creation or approval date.',
    `filing_notes` STRING COMMENT 'Free-text field for capturing regulatory affairs team notes specific to this filing, such as agency-specific requirements, filing rationale, or cross-reference instructions.',
    `filing_status` STRING COMMENT 'The current status of this document filing within the regulatory binder lifecycle (planned, included, submitted, withdrawn, superseded). Tracks the progression of the filing relationship through the submission process.',
    `hyperlink_location` STRING COMMENT 'The relative file path or hyperlink reference to this document within the eCTD submission structure. Required for eCTD validation and regulatory gateway submission.',
    `is_cross_referenced` BOOLEAN COMMENT 'Indicates whether this document is cross-referenced from another CTD section within the same binder. True when the document appears in multiple sections via hyperlink rather than duplication.',
    `sequence_number` STRING COMMENT 'The four-digit eCTD sequence number within which this document filing occurs (e.g., 0000, 0001). Links the filing to a specific submission sequence for version control and regulatory tracking.',
    CONSTRAINT pk_regulatory_filing PRIMARY KEY(`regulatory_filing_id`)
) COMMENT 'This association product represents the filing relationship between a regulatory submission binder and a TMF document. It captures the regulatory context in which a specific TMF document is included in a specific regulatory submission package.';

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_filing` ADD CONSTRAINT `fk_document_regulatory_filing_regulatory_binder_id` FOREIGN KEY (`regulatory_binder_id`) REFERENCES `clinical_trials_mvm`.`document`.`regulatory_binder`(`regulatory_binder_id`);

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_filing` ADD CONSTRAINT `fk_document_regulatory_filing_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER SCHEMA `clinical_trials_mvm`.`document` SET TAGS ('dbx_division' = 'corporate');

ALTER SCHEMA `clinical_trials_mvm`.`document` SET TAGS ('dbx_domain' = 'document');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_filing` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_filing` SET TAGS ('dbx_domain' = 'document');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_filing` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_filing` SET TAGS ('dbx_subdomain' = 'regulatory_management');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_filing` SET TAGS ('dbx_association_edges' = 'document.regulatory_binder,document.tmf_document');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_filing` ALTER COLUMN `regulatory_filing_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Filing Identifier');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_filing` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_filing` ALTER COLUMN `ctd_section` SET TAGS ('dbx_business_glossary_term' = 'Common Technical Document Section');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_filing` ALTER COLUMN `document_role_in_submission` SET TAGS ('dbx_business_glossary_term' = 'Document Role in Submission');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_filing` ALTER COLUMN `filing_date` SET TAGS ('dbx_business_glossary_term' = 'Document Filing Date');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_filing` ALTER COLUMN `filing_notes` SET TAGS ('dbx_business_glossary_term' = 'Filing Notes');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_filing` ALTER COLUMN `filing_status` SET TAGS ('dbx_business_glossary_term' = 'Filing Status');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_filing` ALTER COLUMN `hyperlink_location` SET TAGS ('dbx_business_glossary_term' = 'eCTD Hyperlink Location');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_filing` ALTER COLUMN `is_cross_referenced` SET TAGS ('dbx_business_glossary_term' = 'Cross-Referenced Document Flag');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_filing` ALTER COLUMN `sequence_number` SET TAGS ('dbx_business_glossary_term' = 'eCTD Sequence Number');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ADD CONSTRAINT `fk_document_tmf_document_tmf_artifact_id` FOREIGN KEY (`tmf_artifact_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_artifact`(`tmf_artifact_id`);

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` SET TAGS ('dbx_domain' = 'document');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` SET TAGS ('dbx_subdomain' = 'document_lifecycle');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Document ID');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `tmf_artifact_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Artifact Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Document Approval Date');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Document Comments');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `confidentiality_classification` SET TAGS ('dbx_value_regex' = 'restricted|confidential|internal|public');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `confidentiality_classification` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `tmf_document_description` SET TAGS ('dbx_business_glossary_term' = 'Document Description');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Document Effective Date');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Document Expiry Date');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `filing_status` SET TAGS ('dbx_business_glossary_term' = 'Document Filing Status');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `filing_status` SET TAGS ('dbx_value_regex' = 'expected|filed|overdue|not_applicable|placeholder');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `is_archived` SET TAGS ('dbx_business_glossary_term' = 'Is Archived Flag');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `is_essential_document` SET TAGS ('dbx_business_glossary_term' = 'Is Essential Document Flag');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `is_gcp_required` SET TAGS ('dbx_business_glossary_term' = 'Is Good Clinical Practice (GCP) Required Flag');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `is_inspection_ready` SET TAGS ('dbx_business_glossary_term' = 'Is Inspection Ready Flag');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `language_code` SET TAGS ('dbx_business_glossary_term' = 'Document Language Code');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `language_code` SET TAGS ('dbx_value_regex' = '^[a-z]{2}(-[A-Z]{2})?$');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `language_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `lifecycle_status` SET TAGS ('dbx_business_glossary_term' = 'Document Lifecycle Status');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `page_count` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `quality_review_status` SET TAGS ('dbx_value_regex' = 'not_reviewed|in_review|passed|failed|waived');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `retention_period_years` SET TAGS ('dbx_business_glossary_term' = 'Retention Period (Years)');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Document Title');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `tmf_section` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Section');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `tmf_zone` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Zone');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `tmf_zone` SET TAGS ('dbx_value_regex' = '01|02|03|04|05|06');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `vault_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `vault_library` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Library');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `version_date` SET TAGS ('dbx_business_glossary_term' = 'Document Version Date');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Document Version Number');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+(.[0-9]+)?$');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` SET TAGS ('dbx_domain' = 'document');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` SET TAGS ('dbx_subdomain' = 'operating_procedures');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `tmf_artifact_id` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Artifact ID');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `applicability_phase` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Applicable Trial Phase');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `archival_trigger` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Archival Trigger');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `artifact_abbreviation` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Abbreviation');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `artifact_code` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Code');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `artifact_code` SET TAGS ('dbx_value_regex' = '^[0-9]{2}.[0-9]{2}.[0-9]{2}$');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `artifact_description` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Description');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `artifact_name` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Name');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `artifact_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `artifact_number` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Number');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `artifact_status` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Status');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `artifact_status` SET TAGS ('dbx_value_regex' = 'Active|Deprecated|Superseded|Draft');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `cdisc_controlled_term` SET TAGS ('dbx_business_glossary_term' = 'Clinical Data Interchange Standards Consortium (CDISC) Controlled Terminology');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `cdisc_controlled_term` SET TAGS ('dbx_standard_ref' = 'CDISC CT TMF Artifact');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `completeness_weight` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Completeness Weight');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `dia_reference_model_version` SET TAGS ('dbx_business_glossary_term' = 'Document Information Association (DIA) TMF Reference Model Version');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `dia_reference_model_version` SET TAGS ('dbx_standard_ref' = 'DIA TMF Reference Model');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `document_owner_role` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Document Owner Role');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Effective Date');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `expected_timing` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Expected Filing Timing');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `filing_guidance` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Filing Guidance');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `ich_gcp_reference` SET TAGS ('dbx_business_glossary_term' = 'International Council for Harmonisation Good Clinical Practice (ICH GCP) Reference');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `ich_gcp_reference` SET TAGS ('dbx_standard_ref' = 'ICH E6(R2) GCP');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `is_country_specific` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Country-Specific Indicator');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `is_essential_document` SET TAGS ('dbx_business_glossary_term' = 'TMF Essential Document Indicator');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `is_inspection_critical` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Inspection Critical Indicator');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `is_investigator_held` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Investigator Site File (ISF) Held Indicator');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `is_site_specific` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Site-Specific Indicator');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `is_sponsor_held` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Sponsor-Held Indicator');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Notes');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `requirement_classification` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Requirement Classification');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `requirement_classification` SET TAGS ('dbx_value_regex' = 'Required|Recommended|Optional');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `requires_electronic_signature` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Electronic Signature Required Indicator');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `requires_electronic_signature` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `requires_electronic_signature` SET TAGS ('dbx_pii_signature' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `requires_wet_signature` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Wet Signature Required Indicator');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `requires_wet_signature` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `requires_wet_signature` SET TAGS ('dbx_pii_signature' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `retention_period_years` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Retention Period (Years)');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `retirement_date` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Retirement Date');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `section_name` SET TAGS ('dbx_business_glossary_term' = 'TMF Section Name');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `section_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `section_number` SET TAGS ('dbx_business_glossary_term' = 'TMF Section Number');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `section_number` SET TAGS ('dbx_value_regex' = '^[0-9]{1,2}.[0-9]{1,2}$');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `superseded_by_code` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Superseded By Code');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `superseded_by_code` SET TAGS ('dbx_value_regex' = '^[0-9]{2}.[0-9]{2}.[0-9]{2}$');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `tmf_level` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Level');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `tmf_level` SET TAGS ('dbx_value_regex' = 'Trial|Country|Site');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `trial_phase_end` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Trial Phase End');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `trial_phase_end` SET TAGS ('dbx_value_regex' = 'Pre-Trial|Start-Up|Conduct|Close-Out|Post-Trial');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `trial_phase_start` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Trial Phase Start');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `trial_phase_start` SET TAGS ('dbx_value_regex' = 'Pre-Trial|Start-Up|Conduct|Close-Out|Post-Trial');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'TMF Artifact Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `veeva_vault_document_subtype` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault eTMF Document Subtype');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `veeva_vault_document_type` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault eTMF Document Type');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `zone_name` SET TAGS ('dbx_business_glossary_term' = 'TMF Zone Name');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `zone_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ALTER COLUMN `zone_number` SET TAGS ('dbx_business_glossary_term' = 'TMF Zone Number');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ADD CONSTRAINT `fk_document_version_document_sop_id` FOREIGN KEY (`document_sop_id`) REFERENCES `clinical_trials_mvm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ADD CONSTRAINT `fk_document_version_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`document`.`version` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` SET TAGS ('dbx_domain' = 'document');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` SET TAGS ('dbx_subdomain' = 'document_lifecycle');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ALTER COLUMN `version_id` SET TAGS ('dbx_business_glossary_term' = 'Document Version ID');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ALTER COLUMN `controlled_terminology_codelist_id` SET TAGS ('dbx_standard_ref' = 'CDISC CT Codelist');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ALTER COLUMN `document_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Document Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Document ID');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ALTER COLUMN `approver_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ALTER COLUMN `approver_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ALTER COLUMN `approver_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ALTER COLUMN `archival_status` SET TAGS ('dbx_value_regex' = 'active|archived|pending_archival|destroyed');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ALTER COLUMN `author_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ALTER COLUMN `author_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ALTER COLUMN `author_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ALTER COLUMN `capa_reference` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Reference');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ALTER COLUMN `change_type` SET TAGS ('dbx_value_regex' = 'major|minor|administrative|initial');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ALTER COLUMN `checksum_hash` SET TAGS ('dbx_business_glossary_term' = 'Checksum Hash (SHA-256)');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ALTER COLUMN `checksum_hash` SET TAGS ('dbx_value_regex' = '^[a-fA-F0-9]{64}$');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_value_regex' = 'public|internal|confidential|restricted');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ALTER COLUMN `file_size_kb` SET TAGS ('dbx_business_glossary_term' = 'File Size (KB)');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ALTER COLUMN `inspection_readiness_status` SET TAGS ('dbx_value_regex' = 'ready|gap_identified|remediation_in_progress|not_applicable');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ALTER COLUMN `language_code` SET TAGS ('dbx_value_regex' = '^[a-z]{2}(-[A-Z]{2})?$');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ALTER COLUMN `language_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ALTER COLUMN `number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+(.[0-9]+)?$');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ALTER COLUMN `reviewer_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ALTER COLUMN `reviewer_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ALTER COLUMN `reviewer_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ALTER COLUMN `tmf_section` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Section');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ALTER COLUMN `tmf_zone` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Zone');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ALTER COLUMN `tmf_zone` SET TAGS ('dbx_value_regex' = 'zone_1|zone_2|zone_3|zone_4|zone_5');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ALTER COLUMN `training_required` SET TAGS ('dbx_business_glossary_term' = 'Training Required Flag');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ALTER COLUMN `vault_document_version_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document Version ID');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ALTER COLUMN `vault_lifecycle_state` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Lifecycle State');

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ALTER COLUMN `version_status` SET TAGS ('dbx_value_regex' = 'draft|in_review|approved|superseded|obsolete|withdrawn');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` SET TAGS ('dbx_domain' = 'document');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` SET TAGS ('dbx_subdomain' = 'operating_procedures');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `document_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Standard Operating Procedure (SOP) Document ID');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `applicable_region` SET TAGS ('dbx_business_glossary_term' = 'SOP Applicable Geographic Region');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'SOP Approval Date');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `approver` SET TAGS ('dbx_business_glossary_term' = 'SOP Approver');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `approver` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `approver` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `approver` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `author` SET TAGS ('dbx_business_glossary_term' = 'SOP Author');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `author` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `author` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `author` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `capa_reference` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Reference');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `change_summary` SET TAGS ('dbx_business_glossary_term' = 'SOP Version Change Summary');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_business_glossary_term' = 'SOP Confidentiality Classification Level');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_value_regex' = 'public|internal|confidential|restricted');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'SOP Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `deviation_triggered` SET TAGS ('dbx_business_glossary_term' = 'SOP Deviation-Triggered Revision Flag');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `document_format` SET TAGS ('dbx_business_glossary_term' = 'SOP Document Format');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `document_format` SET TAGS ('dbx_value_regex' = 'pdf|word|excel|html|xml');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `document_location_url` SET TAGS ('dbx_business_glossary_term' = 'SOP Document Storage Location URL');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'SOP Effective Date');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `electronic_signature_required` SET TAGS ('dbx_business_glossary_term' = 'Electronic Signature Required Flag');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `electronic_signature_required` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `electronic_signature_required` SET TAGS ('dbx_pii_signature' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'SOP Expiry Date');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `gcp_applicable` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Applicable Flag');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `gdpr_applicable` SET TAGS ('dbx_business_glossary_term' = 'General Data Protection Regulation (GDPR) Applicable Flag');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `hipaa_applicable` SET TAGS ('dbx_business_glossary_term' = 'Health Insurance Portability and Accountability Act (HIPAA) Applicable Flag');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `inspection_ready` SET TAGS ('dbx_business_glossary_term' = 'SOP Inspection Readiness Flag');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `language` SET TAGS ('dbx_business_glossary_term' = 'SOP Document Language');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `language` SET TAGS ('dbx_value_regex' = '^[a-z]{2,3}(-[A-Z]{2})?$');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `language` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'SOP Record Last Modified Timestamp');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `mastercontrol_doc_reference` SET TAGS ('dbx_business_glossary_term' = 'MasterControl Document ID');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `process_area` SET TAGS ('dbx_business_glossary_term' = 'SOP Process Area');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `purpose` SET TAGS ('dbx_business_glossary_term' = 'SOP Purpose Statement');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `regulatory_framework` SET TAGS ('dbx_business_glossary_term' = 'Applicable Regulatory Framework');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `review_cycle_months` SET TAGS ('dbx_business_glossary_term' = 'SOP Periodic Review Cycle (Months)');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `review_due_date` SET TAGS ('dbx_business_glossary_term' = 'SOP Periodic Review Due Date');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `scope` SET TAGS ('dbx_business_glossary_term' = 'SOP Scope Statement');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `sop_number` SET TAGS ('dbx_business_glossary_term' = 'Standard Operating Procedure (SOP) Number');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `sop_number` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,10}-SOP-[0-9]{3,6}$');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `sop_status` SET TAGS ('dbx_business_glossary_term' = 'SOP Lifecycle Status');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `sop_type` SET TAGS ('dbx_business_glossary_term' = 'SOP Document Type');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `sop_type` SET TAGS ('dbx_value_regex' = 'sop|work_instruction|policy|guidance|template|form');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `superseded_version_number` SET TAGS ('dbx_business_glossary_term' = 'Superseded SOP Version Number');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `superseded_version_number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'SOP Title');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `tmf_reference_model_section` SET TAGS ('dbx_business_glossary_term' = 'DIA Trial Master File (TMF) Reference Model Section');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `training_completion_deadline_days` SET TAGS ('dbx_business_glossary_term' = 'SOP Training Completion Deadline (Days)');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `training_required` SET TAGS ('dbx_business_glossary_term' = 'SOP Training Required Flag');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'SOP Version Number');

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ADD CONSTRAINT `fk_document_workflow_document_sop_id` FOREIGN KEY (`document_sop_id`) REFERENCES `clinical_trials_mvm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ADD CONSTRAINT `fk_document_workflow_regulatory_binder_id` FOREIGN KEY (`regulatory_binder_id`) REFERENCES `clinical_trials_mvm`.`document`.`regulatory_binder`(`regulatory_binder_id`);

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ADD CONSTRAINT `fk_document_workflow_site_file_id` FOREIGN KEY (`site_file_id`) REFERENCES `clinical_trials_mvm`.`document`.`site_file`(`site_file_id`);

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ADD CONSTRAINT `fk_document_workflow_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ADD CONSTRAINT `fk_document_workflow_version_id` FOREIGN KEY (`version_id`) REFERENCES `clinical_trials_mvm`.`document`.`version`(`version_id`);

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` SET TAGS ('dbx_domain' = 'document');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` SET TAGS ('dbx_subdomain' = 'document_lifecycle');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `workflow_id` SET TAGS ('dbx_business_glossary_term' = 'Document Workflow ID');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `audit_id` SET TAGS ('dbx_business_glossary_term' = 'Audit Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `document_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Document Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `regulatory_binder_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Binder Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `site_file_id` SET TAGS ('dbx_business_glossary_term' = 'Site File Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Study Site Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Document ID');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `version_id` SET TAGS ('dbx_business_glossary_term' = 'Document Version Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `actual_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Workflow Actual Completion Date');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `archival_date` SET TAGS ('dbx_business_glossary_term' = 'Document Archival Date');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `archival_required` SET TAGS ('dbx_business_glossary_term' = 'Archival Required Flag');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `current_step_name` SET TAGS ('dbx_business_glossary_term' = 'Current Workflow Step Name');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `current_step_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `current_step_sequence` SET TAGS ('dbx_business_glossary_term' = 'Current Step Sequence Number');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `distribution_date` SET TAGS ('dbx_business_glossary_term' = 'Document Distribution Date');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `distribution_required` SET TAGS ('dbx_business_glossary_term' = 'Distribution Required Flag');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `electronic_signature_required` SET TAGS ('dbx_business_glossary_term' = 'Electronic Signature Required Flag');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `electronic_signature_required` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `electronic_signature_required` SET TAGS ('dbx_pii_signature' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `electronic_signature_timestamp` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `electronic_signature_timestamp` SET TAGS ('dbx_pii_signature' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `escalation_reason` SET TAGS ('dbx_value_regex' = 'sla-breach|non-response|rejection-loop|resource-unavailable|other');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `gcp_critical_document_flag` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Critical Document Flag');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `initiated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Workflow Initiated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `instance_reference` SET TAGS ('dbx_business_glossary_term' = 'Workflow Instance ID');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `priority_level` SET TAGS ('dbx_business_glossary_term' = 'Workflow Priority Level');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `priority_level` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `sla_breach_indicator` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Breach Indicator');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `step_action_taken` SET TAGS ('dbx_value_regex' = 'approved|rejected|reviewed|delegated|reassigned|escalated');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `step_assignee_name` SET TAGS ('dbx_business_glossary_term' = 'Step Assignee Full Name');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `step_assignee_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `step_assignee_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `step_assignee_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `step_comment` SET TAGS ('dbx_business_glossary_term' = 'Step Reviewer Comment');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `target_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Workflow Target Completion Date');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `template_name` SET TAGS ('dbx_business_glossary_term' = 'Workflow Template Name');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `template_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `template_version` SET TAGS ('dbx_business_glossary_term' = 'Workflow Template Version');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `tmf_zone` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Zone');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `total_steps` SET TAGS ('dbx_business_glossary_term' = 'Total Workflow Steps');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `workflow_status` SET TAGS ('dbx_value_regex' = 'initiated|in-review|pending-approval|approved|rejected|cancelled');

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ALTER COLUMN `workflow_type` SET TAGS ('dbx_value_regex' = 'review|approval|distribution|archival|cancellation|amendment');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ADD CONSTRAINT `fk_document_signature_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ADD CONSTRAINT `fk_document_signature_version_id` FOREIGN KEY (`version_id`) REFERENCES `clinical_trials_mvm`.`document`.`version`(`version_id`);

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ADD CONSTRAINT `fk_document_signature_workflow_id` FOREIGN KEY (`workflow_id`) REFERENCES `clinical_trials_mvm`.`document`.`workflow`(`workflow_id`);

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` SET TAGS ('dbx_domain' = 'document');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` SET TAGS ('dbx_subdomain' = 'document_lifecycle');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `signature_id` SET TAGS ('dbx_business_glossary_term' = 'Document Signature ID');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `signature_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `signature_id` SET TAGS ('dbx_pii_signature' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Document ID');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `version_id` SET TAGS ('dbx_business_glossary_term' = 'Document Version ID');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `workflow_id` SET TAGS ('dbx_business_glossary_term' = 'Document Workflow Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Signature Comments');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `device_identifier` SET TAGS ('dbx_business_glossary_term' = 'Signing Device Identifier');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `device_identifier` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `device_identifier` SET TAGS ('dbx_pii_device' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `digital_certificate_serial` SET TAGS ('dbx_business_glossary_term' = 'Digital Certificate Serial Number');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Signature Due Date');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `hash_algorithm` SET TAGS ('dbx_value_regex' = 'SHA-256|SHA-512|SHA-3|RSA-SHA256');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `ip_address` SET TAGS ('dbx_business_glossary_term' = 'Signer IP Address');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `ip_address` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `ip_address` SET TAGS ('dbx_pii_ip' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `is_regulatory_submission_applicable` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission Applicable Flag');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `locale` SET TAGS ('dbx_business_glossary_term' = 'Signing Locale');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `meaning` SET TAGS ('dbx_business_glossary_term' = 'Signature Meaning');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `meaning` SET TAGS ('dbx_value_regex' = 'reviewed|approved|acknowledged|authored|certified|witnessed');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `meaning` SET TAGS ('dbx_standard_ref' = '21 CFR Part 11 Electronic Signature meaning');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `method` SET TAGS ('dbx_business_glossary_term' = 'Signature Method');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `method` SET TAGS ('dbx_value_regex' = 'username_password|biometric|digital_certificate|smart_card|two_factor_auth');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `method` SET TAGS ('dbx_standard_ref' = '21 CFR Part 11 Electronic Signature');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `reference_number` SET TAGS ('dbx_business_glossary_term' = 'Signature Reference Number');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `requested_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Signature Requested Timestamp');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `signature_status` SET TAGS ('dbx_value_regex' = 'pending|applied|voided|superseded|rejected');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `signature_status` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `signature_status` SET TAGS ('dbx_pii_signature' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `signature_type` SET TAGS ('dbx_value_regex' = 'electronic|wet_ink_scanned|advanced_electronic|qualified_electronic');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `signature_type` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `signature_type` SET TAGS ('dbx_pii_signature' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `signed_timestamp` SET TAGS ('dbx_standard_ref' = '21 CFR Part 11 Electronic Signature');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `signer_full_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `signer_full_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `signer_full_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `signer_role` SET TAGS ('dbx_value_regex' = 'author|reviewer|approver|sponsor_representative|quality_assurance|investigator');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `source_system_signature_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Signature ID');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `source_system_signature_reference` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `source_system_signature_reference` SET TAGS ('dbx_pii_signature' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `timezone` SET TAGS ('dbx_business_glossary_term' = 'Signing Timezone');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `tmf_artifact_number` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Artifact Number');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `tmf_zone` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Zone');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ALTER COLUMN `workflow_step_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` SET TAGS ('dbx_domain' = 'document');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` SET TAGS ('dbx_subdomain' = 'regulatory_management');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `activation_date` SET TAGS ('dbx_business_glossary_term' = 'Site File Activation Date');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `applicable_gcp_guideline` SET TAGS ('dbx_business_glossary_term' = 'Applicable Good Clinical Practice (GCP) Guideline');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `applicable_gcp_guideline` SET TAGS ('dbx_value_regex' = 'ICH E6(R2)|ICH E6(R3)|21 CFR Part 312|EU CTR 536/2014|ISO 14155');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `archival_date` SET TAGS ('dbx_business_glossary_term' = 'Site File Archival Date');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `closure_date` SET TAGS ('dbx_business_glossary_term' = 'Site File Closure Date');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `completeness_percentage` SET TAGS ('dbx_business_glossary_term' = 'Site File Completeness Percentage');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `completeness_percentage` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `completeness_status` SET TAGS ('dbx_business_glossary_term' = 'Site File Completeness Status');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `completeness_status` SET TAGS ('dbx_value_regex' = 'Complete|Incomplete|Overdue|Not Applicable');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `custodian_role` SET TAGS ('dbx_business_glossary_term' = 'Site File Custodian Role');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `custodian_role` SET TAGS ('dbx_value_regex' = 'PI|CRC|Sub-Investigator|Regulatory Affairs Coordinator|Site Manager');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `delegation_log_on_file` SET TAGS ('dbx_business_glossary_term' = 'Delegation of Authority Log On File Indicator');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `file_format` SET TAGS ('dbx_business_glossary_term' = 'Site File Format');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `file_format` SET TAGS ('dbx_value_regex' = 'Electronic|Paper|Hybrid');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `file_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Site File Reference Number');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `file_status` SET TAGS ('dbx_business_glossary_term' = 'Site File Status');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `file_status` SET TAGS ('dbx_value_regex' = 'Active|Under Review|Archived|Closed|Pending Activation');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `file_type` SET TAGS ('dbx_business_glossary_term' = 'Site File Type');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `file_type` SET TAGS ('dbx_value_regex' = 'ISF|Regulatory Binder|Pharmacy Binder|Laboratory Binder|Investigator Binder');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `financial_disclosure_on_file` SET TAGS ('dbx_business_glossary_term' = 'Financial Disclosure On File Indicator');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `icf_on_file` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) On File Indicator');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `inspection_readiness_status` SET TAGS ('dbx_value_regex' = 'Ready|Needs Remediation|Critical Gaps|Not Assessed');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `investigator_cv_on_file` SET TAGS ('dbx_business_glossary_term' = 'Investigator Curriculum Vitae (CV) On File Indicator');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `irb_iec_approval_on_file` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Approval On File Indicator');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `lab_certification_on_file` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Certification On File Indicator');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `last_inspection_date` SET TAGS ('dbx_business_glossary_term' = 'Last Regulatory Inspection Date');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `last_inspection_outcome` SET TAGS ('dbx_business_glossary_term' = 'Last Regulatory Inspection Outcome');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `last_inspection_outcome` SET TAGS ('dbx_value_regex' = 'No Action Indicated|Voluntary Action Indicated|Official Action Indicated|Pending|Not Applicable');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Site File Review Date');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Scheduled Site File Review Date');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Site File Notes');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `physical_location` SET TAGS ('dbx_business_glossary_term' = 'Physical File Location');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `protocol_on_file` SET TAGS ('dbx_business_glossary_term' = 'Protocol On File Indicator');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `sponsor_review_completed` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Review Completed Indicator');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `tmf_section` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Section');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `tmf_zone` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Zone');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `tmf_zone` SET TAGS ('dbx_value_regex' = 'Trial Management|Investigational Product|Site Management|Subject Information and Consent|Study Procedures');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ALTER COLUMN `veeva_vault_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` SET TAGS ('dbx_domain' = 'document');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` SET TAGS ('dbx_subdomain' = 'regulatory_management');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `agency_action_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `agency_action_type` SET TAGS ('dbx_value_regex' = 'approval|complete_response|refuse_to_file|withdrawal|approvable|not_approvable');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `agency_action_type` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `agency_receipt_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Date');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `binder_number` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Binder Number');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `binder_status` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Binder Status');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `binder_status` SET TAGS ('dbx_value_regex' = 'in_preparation|submitted|under_review|approved|withdrawn');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `binder_title` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Binder Title');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `binder_type` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Binder Type');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `completeness_percentage` SET TAGS ('dbx_business_glossary_term' = 'Binder Completeness Percentage');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `completeness_percentage` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_value_regex' = 'restricted|confidential|internal|public');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `ctd_module` SET TAGS ('dbx_business_glossary_term' = 'Common Technical Document (CTD) Module');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `ctd_module` SET TAGS ('dbx_value_regex' = 'M1|M2|M3|M4|M5|full');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `ectd_version` SET TAGS ('dbx_business_glossary_term' = 'Electronic Common Technical Document (eCTD) Version');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `ectd_version` SET TAGS ('dbx_value_regex' = '3.2.2|4.0');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authorization Expiry Date');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `is_ectd_format` SET TAGS ('dbx_business_glossary_term' = 'Electronic Common Technical Document (eCTD) Format Flag');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `is_inspection_ready` SET TAGS ('dbx_business_glossary_term' = 'Inspection Readiness Flag');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Binder Notes');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `pdufa_target_date` SET TAGS ('dbx_business_glossary_term' = 'Prescription Drug User Fee Act (PDUFA) Target Action Date');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `review_pathway` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Review Pathway');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `review_pathway` SET TAGS ('dbx_value_regex' = 'standard|priority|accelerated|breakthrough|orphan|conditional');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `submission_category` SET TAGS ('dbx_value_regex' = 'original|amendment|supplement|annual_report|response');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `submission_medium` SET TAGS ('dbx_value_regex' = 'electronic|paper|hybrid');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `submission_sequence_number` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `target_agency` SET TAGS ('dbx_business_glossary_term' = 'Target Health Authority Agency');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `target_agency` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `veeva_vault_binder_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Regulatory Binder Reference ID');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `withdrawal_date` SET TAGS ('dbx_business_glossary_term' = 'Submission Withdrawal Date');

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ALTER COLUMN `withdrawal_reason` SET TAGS ('dbx_business_glossary_term' = 'Submission Withdrawal Reason');
