-- Schema for Domain: datamanagement | Business: Clinical_Trials | Version: v2_mvm
-- Generated on: 2026-11-20 12:39:47

CREATE DATABASE IF NOT EXISTS `clinical_trials_mvm`.`datamanagement` COMMENT 'Governs clinical data collection, validation, and lock processes. Owns EDC/eCRF design and build (Medidata Rave), data validation rules, query management, discrepancy resolution, medical coding (MedDRA, WHO-DD), database lock (DBL) workflows, DMP, CDISC';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` (
    `ecrf_field_id` BIGINT COMMENT 'Unique surrogate identifier for each eCRF field definition record in Medidata Rave. Primary key for the ecrf_field data product.',
    `codelist_id` BIGINT COMMENT 'Foreign key linking to datamanagement.codelist. Business justification: ecrf_field references a CDISC Controlled Terminology codelist via codelist_name/codelist_oid STRINGs. The authoritative codelist table exists in-domain.',
    `ecrf_form_id` BIGINT COMMENT 'Reference to the parent eCRF form to which this field belongs. Links the field to its containing form within the study design hierarchy in Medidata Rave.',
    `endpoint_id` BIGINT COMMENT 'Foreign key linking to study.endpoint. Business justification: eCRF fields capturing primary/secondary endpoint data must be traceable to the endpoint definition for SAP alignment, SDTM mapping validation, and regulatory submission.',
    `imp_master_id` BIGINT COMMENT 'Foreign key linking to supply.imp_master. Business justification: eCRF fields for the SDTM Exposure (EX) domain are designed specifically for a given IMP — dose range min/max, route of administration, strength units, and dispensing unit constraints must',
    `lab_panel_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_analyte. Business justification: eCRF fields capturing lab values must reference the analyte master (LBTESTCD, LOINC, units) to validate SDTM variable assignments during EDC build and enable automated SDTM mapping.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this eCRF field is defined. Enables study-level governance and version control of field definitions.',
    `alcoa_attribute` STRING COMMENT 'Primary ALCOA+ data integrity attribute that this field is designed to support (e.g., contemporaneous for date/time fields, attributable for signature fields, accurate for validated numeric fields). Supports ALCOA+ compliance tracking at the field level.',
    `cdash_variable` STRING COMMENT 'CDISC CDASH variable name that this eCRF field implements, representing the standardized data collection variable. Ensures harmonized data collection aligned with CDISC CDASH standards for cross-study comparability.. Valid values are `^[A-Z][A-Z0-9]{1,7}$`',
    `cdashig_version` STRING COMMENT 'VARCHAR',
    `codelist_oid` STRING COMMENT 'Object identifier (OID) of the controlled terminology codelist bound to this field in Medidata Rave. Applicable for codelist-type fields; references CDISC Controlled Terminology or sponsor-defined codelists governing permissible values.',
    `coding_dictionary` STRING COMMENT 'Medical coding dictionary applied to this field for verbatim-to-coded term mapping (e.g., MedDRA for adverse events, WHO-DD for concomitant medications, CTCAE for toxicity grading). Drives the medical coding workflow in the Data Management process.. Valid values are `MedDRA|WHO-DD|CTCAE|ICD-10|SNOMED-CT|none`',
    `coding_dictionary_version` STRING COMMENT 'Version of the medical coding dictionary applied to this field (e.g., MedDRA 26.1, WHO-DD March 2024). Ensures reproducibility of coded terms across study lifecycle and regulatory submissions.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this eCRF field definition record was first created in the system. Supports audit trail and ALCOA+ compliance tracking for field-level configuration history.',
    `default_value` DECIMAL(18,2) COMMENT 'Pre-populated default value for this field as configured in Medidata Rave. Reduces data entry burden for fields with a common expected value while remaining editable by site staff.',
    `effective_end_date` DATE COMMENT 'Date on which this version of the eCRF field definition was superseded or retired. Null for currently active field definitions. Supports temporal versioning and audit trail for field-level changes.',
    `effective_start_date` DATE COMMENT 'Date from which this version of the eCRF field definition is effective and active for data collection. Used to manage field versioning across protocol amendments and study lifecycle.',
    `field_data_type` STRING COMMENT 'Data type of the field as configured in Medidata Rave, determining the kind of value that can be entered. Drives validation rule applicability and CDISC SDTM variable type mapping.',
    `field_label` STRING COMMENT 'Human-readable label displayed to the data entry user on the eCRF in Medidata Rave. Represents the question or prompt as seen by the Clinical Research Coordinator (CRC) or site staff.',
    `field_length` BIGINT COMMENT 'Maximum character length allowed for text entry in this field. Constrains free-text input to prevent data truncation during SDTM transformation and downstream database storage.',
    `field_name` STRING COMMENT 'Programmatic name of the eCRF field as configured in Medidata Rave. Must be unique within the form and conform to naming conventions for EDC build and CDISC mapping.. Valid values are `^[A-Za-z0-9_]{1,64}$`',
    `field_oid` STRING COMMENT 'Unique object identifier (OID) for the field as defined in Medidata Rave and conforming to ODM XML standards. Used for cross-system referencing and CDISC ODM data exchange.. Valid values are `^[A-Za-z0-9_-.]{1,128}$`',
    `field_order` BIGINT COMMENT 'Numeric sequence position of the field within its parent eCRF form, determining the display order presented to data entry users. Used for form layout and navigation.',
    `field_status` STRING COMMENT 'Current lifecycle status of the eCRF field definition. Controls whether the field is available for data entry in active studies. Draft fields are under design review; retired fields are no longer used in new study builds.. Valid values are `draft|active|inactive|retired`',
    `help_text` STRING COMMENT 'Instructional or contextual help text displayed to data entry users for this field in Medidata Rave. Provides guidance on how to complete the field, acceptable formats, and clinical definitions to ensure data quality.',
    `is_audit_trail_enabled` BOOLEAN COMMENT 'Indicates whether field-level audit trail tracking is enabled for this eCRF field, capturing all data entry, modification, and deletion events with user, timestamp, and reason for change. Mandatory for ALCOA+ and 21 CFR Part 11 compliance.',
    `is_key_field` BOOLEAN COMMENT 'Indicates whether this field is designated as a key field in Medidata Rave, used for record identification and deduplication within a log or repeating form. Key fields are critical for data integrity in multi-record forms.',
    `is_log_field` BOOLEAN COMMENT 'Indicates whether this field belongs to a log (repeating) form in Medidata Rave, allowing multiple rows of data entry per subject visit (e.g., concomitant medications log, adverse events log).',
    `is_read_only` BOOLEAN COMMENT 'Indicates whether the field is read-only and cannot be directly edited by site users. Read-only fields are typically auto-populated by the system or derived from other data points.',
    `is_required` BOOLEAN COMMENT 'Indicates whether data entry for this field is mandatory before the eCRF can be submitted. Required fields enforce ALCOA+ completeness compliance and are enforced by Medidata Rave validation.',
    `is_sdv_required` BOOLEAN COMMENT 'Indicates whether this field is designated for Source Data Verification (SDV) by the Clinical Research Associate (CRA) during monitoring visits. Drives risk-based monitoring plans and SDV scope configuration.',
    `is_sponsor_defined` BOOLEAN COMMENT 'Indicates whether this field is a sponsor-defined custom field beyond the standard CDISC CDASH variables. Sponsor-defined fields require additional SDTM mapping documentation for regulatory submissions.',
    `is_visible` BOOLEAN COMMENT 'Indicates whether the field is currently visible to data entry users on the eCRF. Invisible fields may be conditionally hidden by edit check logic or used for internal system calculations.',
    `max_value` DECIMAL(18,6) COMMENT 'Maximum permissible numeric value for this field as defined in the validation rules. Applicable to numeric and date fields; values above this threshold trigger a data query in Medidata Rave.',
    `min_value` DECIMAL(18,6) COMMENT 'Minimum permissible numeric value for this field as defined in the validation rules. Applicable to numeric and date fields; values below this threshold trigger a data query in Medidata Rave.',
    `modified_by` STRING COMMENT 'Username or user identifier of the individual who last modified this eCRF field definition in Medidata Rave. Supports ALCOA+ attributability and change control audit trail.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this eCRF field definition record. Tracks configuration changes for audit trail purposes and supports ALCOA+ compliance.',
    `query_generation_mode` STRING COMMENT 'Specifies how data queries (discrepancies) are generated for this field in Medidata Rave: automatic (system-generated by edit checks), manual (raised by data managers or monitors), or none (no query generation configured).. Valid values are `automatic|manual|none`',
    `rave_field_type` STRING COMMENT 'Medidata Rave-specific UI control type for this field, determining the data entry widget rendered on the eCRF (e.g., text box, radio button, dropdown list, checkbox). Distinct from the logical data type.',
    `sdtm_domain` STRING COMMENT 'CDISC SDTM domain code (e.g., DM, AE, LB, VS, CM) to which this eCRF field maps. Drives automated CDISC SDTM transformation in SAS Drug Development and regulatory submission dataset generation.. Valid values are `^[A-Z]{2}$`',
    `sdtm_variable` STRING COMMENT 'CDISC SDTM variable name (e.g., AEDECOD, LBSTRESN, VSORRES) to which this eCRF field is mapped. Enables automated CDISC SDTM dataset generation for regulatory submissions (IND, NDA, BLA, MAA).. Valid values are `^[A-Z][A-Z0-9]{1,7}$`',
    `significant_digits` BIGINT COMMENT 'Number of significant digits (decimal places) permitted for numeric fields. Ensures precision alignment with laboratory reporting standards and SDTM numeric variable specifications.',
    `source_system_field_reference` STRING COMMENT 'Native field identifier as assigned by Medidata Rave EDC. Enables traceability between the Silver Layer data product and the originating EDC system record for reconciliation and lineage purposes.',
    `unit_dictionary` STRING COMMENT 'Name of the unit dictionary or unit codelist bound to this field in Medidata Rave (e.g., SI units, lab units). Governs permissible units of measure for numeric fields and supports SDTM --ORRESU and --STRESU variable mapping.',
    `validation_rule_expression` STRING COMMENT 'Edit check or validation rule expression applied to this field in Medidata Rave (e.g., range checks, cross-field consistency checks, date logic). Defines the programmatic logic that triggers data queries when violated.',
    `version_number` STRING COMMENT 'Version number of this eCRF field definition, incremented when the field configuration is modified after study go-live. Supports amendment tracking and ensures traceability of field-level changes per protocol amendment.. Valid values are `^d+.d+(.d+)?$`',
    CONSTRAINT pk_ecrf_field PRIMARY KEY(`ecrf_field_id`)
) COMMENT 'Master definition of individual data fields within eCRF forms in Medidata Rave. Captures field name, label, data type (text, numeric, date, codelist), CDISC variable mapping (SDTM variable, domain), validation rules, required flag, controlled terminology';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` (
    `define_document_id` BIGINT COMMENT 'Surrogate primary key.',
    `audit_finding_id` BIGINT COMMENT 'Foreign key linking to compliance.audit_finding. Business justification: Define.xml documents are reviewed during regulatory inspections and GCP audits; findings citing missing or incorrect metadata in define documents must be traceable to the specific',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: The define.xml document is generated for a specific protocol version as part of the regulatory submission package.',
    `regulatory_binder_id` BIGINT COMMENT 'Foreign key linking to document.regulatory_binder. Business justification: The define.xml is submitted as part of a regulatory package tracked in the regulatory binder (eCTD Module 5).',
    `sap_id` BIGINT COMMENT 'Foreign key linking to biostatistics.sap. Business justification: The define.xml document is a regulatory submission artifact that must align with the SAP — variable definitions, controlled terminology, and dataset structure are reviewed against SAP',
    `study_id` BIGINT COMMENT 'Study this Define-XML document describes.',
    `submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission. Business justification: Define.xml is a mandatory eCTD submission artifact required by FDA and EMA. Each Define.xml document is created for a specific submission package.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: The define.xml is an essential TMF document (ICH E6, FDA 21 CFR Part 11). Data managers must link the define_document technical record to its TMF filing for regulatory inspection',
    `content` STRING COMMENT 'Serialized Define-XML content.',
    `created_timestamp` TIMESTAMP COMMENT 'Record creation timestamp.',
    `define_version` STRING COMMENT 'Define-XML version (e.g., 2.0, 2.1).',
    `define_xml_version` STRING COMMENT 'Define-XML version.',
    `document_status` STRING COMMENT 'Lifecycle status of the Define-XML document (draft, final, submitted).',
    `document_type` STRING COMMENT 'Whether the document covers SDTM, ADaM, or SEND metadata.',
    `file_path` STRING COMMENT 'Storage location of the generated Define-XML file.',
    `generation_date` DATE COMMENT 'Date the Define-XML document was generated.',
    `odm_file_oid` STRING COMMENT 'ODM FileOID identifier of the Define-XML document.',
    `odm_oid` STRING COMMENT 'ODM Study OID referenced by the Define-XML document.',
    `stylesheet_reference` STRING COMMENT 'Reference to the XSL stylesheet used to render the Define-XML.',
    `submission_package_reference` STRING COMMENT 'Reference to the regulatory submission package the document belongs to.',
    `updated_timestamp` TIMESTAMP COMMENT 'Record update timestamp.',
    CONSTRAINT pk_define_document PRIMARY KEY(`define_document_id`)
) COMMENT 'Define-XML document.';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_source_system` (
    `ehr_source_system_id` BIGINT COMMENT 'BIGINT',
    `study_id` BIGINT COMMENT 'Study this EHR source system supplies data for.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: EHR source system validation documentation and data transfer agreements are filed as TMF documents (DIA Reference Model).',
    `created_timestamp` TIMESTAMP COMMENT 'Record creation timestamp.',
    `ehr_source_system_description` STRING COMMENT 'STRING',
    `fhir_base_url` STRING COMMENT 'Base URL of the FHIR endpoint.',
    `fhir_version` STRING COMMENT 'HL7 FHIR version supported (e.g. R4).',
    `is_active` BOOLEAN COMMENT 'Whether the connection is active.',
    `source_system_name` STRING COMMENT 'Name of the EHR / eSource system.',
    `system_type` STRING COMMENT 'Type of source system (EHR, lab, device).',
    `system_vendor` STRING COMMENT 'description',
    `system_version` STRING COMMENT 'STRING',
    `updated_timestamp` TIMESTAMP COMMENT 'Record update timestamp.',
    `vendor` STRING COMMENT 'STRING',
    `version` STRING COMMENT 'STRING',
    CONSTRAINT pk_ehr_source_system PRIMARY KEY(`ehr_source_system_id`)
) COMMENT 'An external EHR / eSource system that supplies clinical data into the EDC via eSource flows.';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_data_transfer` (
    `ehr_data_transfer_id` BIGINT COMMENT 'BIGINT',
    `consent_subject_consent_id` BIGINT COMMENT 'Foreign key linking to consent.consent_subject_consent. Business justification: GDPR Article 9 and HIPAA require that each EHR data extraction for a clinical trial is authorized by a specific signed consent record.',
    `primary_ehr_source_system_id` BIGINT COMMENT 'EHR source system the data came from.',
    `source_ehr_source_system_id` BIGINT COMMENT 'BIGINT',
    `study_id` BIGINT COMMENT 'Study the transfer belongs to.',
    `study_visit_schedule_id` BIGINT COMMENT 'Foreign key linking to study.study_visit_schedule. Business justification: EHR data transfers are mapped to specific scheduled visits to populate eCRF data.',
    `trial_subject_id` BIGINT COMMENT 'add column ehr_fhir_crosswalk_id (BIGINT) with FK to datamanagement.ehr_fhir_crosswalk.ehr_fhir_crosswalk_id — ehr_data_transfer should link to crosswalk for mapping context',
    `created_timestamp` TIMESTAMP COMMENT 'Record creation timestamp.',
    `data_transfer_number` BIGINT COMMENT 'description',
    `data_type` STRING COMMENT 'STRING',
    `ehr_data_transfer_description` STRING COMMENT 'description',
    `ehr_data_transfer_status` STRING COMMENT 'Status of the data transfer',
    `error_message` STRING COMMENT 'Error detail if the transfer failed.',
    `fhir_bundle_reference` STRING COMMENT 'Identifier of the FHIR Bundle transferred.',
    `fhir_resource_reference` STRING COMMENT 'STRING',
    `fhir_resource_type` STRING COMMENT 'STRING',
    `payload_format` STRING COMMENT 'Format of the payload (FHIR JSON, CSV).',
    `record_count` BIGINT COMMENT 'BIGINT',
    `source_file_path` STRING COMMENT 'description',
    `target_system` STRING COMMENT 'STRING',
    `transfer_date` DATE COMMENT 'DATE',
    `transfer_method` STRING COMMENT 'description',
    `transfer_status` STRING COMMENT 'Status of the transfer (received, loaded, failed).',
    `transfer_timestamp` TIMESTAMP COMMENT 'TIMESTAMP',
    `transfer_type` STRING COMMENT 'description',
    `transferred_record_count` BIGINT COMMENT 'description',
    `updated_timestamp` TIMESTAMP COMMENT 'Record update timestamp.',
    CONSTRAINT pk_ehr_data_transfer PRIMARY KEY(`ehr_data_transfer_id`)
) COMMENT 'A single eSource data transfer batch from an EHR source system into the EDC.';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`datamanagement`.`codelist` (
    `codelist_id` BIGINT COMMENT 'surrogate key of the codelist',
    `codelist_description` STRING COMMENT 'CDISC definition of the codelist',
    `extensibility_flag` BOOLEAN COMMENT 'true when sponsors may add terms to the codelist',
    `codelist_name` STRING COMMENT 'CDISC codelist name, for example Sex',
    `nci_codelist_code` STRING COMMENT 'NCI Thesaurus C-code of the codelist, for example C66731 for SEX',
    `package_version` STRING COMMENT 'CDISC Controlled Terminology package the codelist was loaded from, for example 2024-03-29',
    `short_name` STRING COMMENT 'CDISC codelist short name, for example SEX, RACE or AGEU',
    CONSTRAINT pk_codelist PRIMARY KEY(`codelist_id`)
) COMMENT 'CDISC Controlled Terminology codelist reference table. Includes UNIT codelist (NCI C71620) for dose and age units, SEX (NCI C66731), RACE (NCI C74457), ETHNIC (NCI C66790), AGEU (NCI C66781), OUT (NCI C66768), ACN (NCI C66767), AESEV (NCI C66769), NCOMPLT';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` (
    `ecrf_form_id` BIGINT COMMENT 'Unique surrogate identifier for each eCRF form definition record in the Medidata Rave EDC system. Serves as the primary key for the ecrf_form product.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.sop. Business justification: eCRF design and annotation is governed by SOPs (e.g., SOP for CRF design, CDASH annotation). Audit findings cite the SOP version governing eCRF development.',
    `dmp_id` BIGINT COMMENT 'Foreign key linking to datamanagement.dmp. Business justification: ecrf_form has dmp_reference (STRING) indicating the governing Data Management Plan. dmp is the master DMP record.',
    `icf_version_id` BIGINT COMMENT 'Foreign key linking to consent.consent_icf_version. Business justification: ICF amendments drive eCRF form updates — new consent sections (biobanking, genetic testing) require corresponding eCRF forms.',
    `lab_panel_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_panel. Business justification: eCRF forms designed for lab data collection must formally reference the lab panel definition to ensure form fields match required analytes, SDTM domain assignments are consistent, and',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: eCRF forms are designed and versioned against a specific protocol version. Amendment impact assessment and regulatory inspection require direct traceability from form design to the governing',
    `study_id` BIGINT COMMENT 'Foreign key linking to study.study. Business justification: eCRF forms must be directly scoped to a study for access control, study-level form inventory reporting, and EDC system configuration.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: Protocol amendments drive eCRF form version updates (new fields, removed fields, ICF changes).',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: eCRF form specifications are essential TMF documents (DIA Reference Model Zone 11, Section 11.01).',
    `annotation_text` STRING COMMENT 'SDTM variable annotation text associated with this form, documenting the mapping between eCRF data fields and SDTM dataset variables. Used in annotated CRF (aCRF) generation for regulatory submissions.',
    `approved_date` DATE COMMENT 'Date on which this eCRF form design was formally approved (e.g., by the Data Management team or sponsor) for deployment in the study. Part of the form lifecycle governance and audit trail.',
    `cdash_domain` STRING COMMENT 'CDISC CDASH domain code that this eCRF form implements for standardized data collection (e.g., AE, CM, EX, MH). Ensures alignment with CDASH data collection standards for regulatory submissions.',
    `coding_dictionary` STRING COMMENT 'Standardized medical coding dictionary applied to verbatim terms collected on this form. MedDRA is used for adverse events and medical history; WHO-DD for drug names. Applicable when medical_coding_required is True.. Valid values are `MedDRA|WHO_DD|SNOMED_CT|ICD_10|none`',
    `completion_rule` STRING COMMENT 'Business rule governing what constitutes a complete eCRF form for database lock purposes. Defines whether all fields must be populated, partial completion is acceptable, or conditional logic applies.. Valid values are `all_fields_required|partial_allowed|conditional|not_applicable_allowed`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this eCRF form definition record was first created in the system. Supports ALCOA+ audit trail and data lineage requirements.',
    `data_entry_mode` STRING COMMENT 'Specifies whether data entry for this form requires single entry (one operator) or double entry (two independent operators for verification) as configured in Medidata Rave. Impacts data quality and ALCOA+ compliance.. Valid values are `single|double|no_entry`',
    `edit_check_count` BIGINT COMMENT 'Number of programmed edit checks (validation rules) associated with this eCRF form in the Medidata Rave study build. Indicates the complexity of data validation logic applied to the form.',
    `effective_end_date` DATE COMMENT 'Date on which this eCRF form version was retired or superseded by a newer version. Null for currently active forms. Supports audit trail and form version history.',
    `effective_start_date` DATE COMMENT 'Date from which this eCRF form version is effective and available for data collection in the deployed study. Supports form versioning and amendment tracking.',
    `field_count` BIGINT COMMENT 'Total number of data fields (eCRF fields) contained within this form definition. Used for form complexity assessment, UAT planning, and data management workload estimation.',
    `form_description` STRING COMMENT 'Detailed narrative description of the eCRF forms purpose, the clinical data it captures, and any special instructions for data entry personnel (CRCs/site staff).',
    `form_name` STRING COMMENT 'Human-readable name of the eCRF form as defined in Medidata Rave (e.g., Adverse Events, Vital Signs, Demographics). Used for display and navigation in the EDC system.',
    `form_oid` STRING COMMENT 'Unique object identifier (OID) for the eCRF form as defined in the ODM-compliant Medidata Rave study design. Used for CDISC ODM data exchange and SDTM mapping. Externally referenceable identifier.',
    `form_order` BIGINT COMMENT 'Numeric sequence position of this form within its assigned visit or folder in the Medidata Rave EDC navigation. Controls the order in which forms are presented to data entry personnel.',
    `form_status` STRING COMMENT 'Current lifecycle status of the eCRF form definition within the EDC system. Draft forms are under development; active forms are deployed for data collection; inactive/retired forms are no longer used.. Valid values are `draft|active|inactive|retired|under_review`',
    `form_type` STRING COMMENT 'Categorization of the eCRF form by its structural and scheduling behavior in Medidata Rave. Visit-based forms appear at scheduled visits; log/repeating forms allow multiple instances per subject; unscheduled forms capture ad hoc data; common forms are. Valid values are `visit_based|unscheduled|log|repeating|common`',
    `form_version` STRING COMMENT 'Version label of the eCRF form design (e.g., 1.0, 2.1, Draft). Tracks design iterations and amendments to the form across study lifecycle.',
    `help_text` STRING COMMENT 'Instructional text displayed to site staff when accessing this eCRF form in the EDC system. Provides guidance on data collection procedures, definitions, and completion requirements.',
    `is_mandatory` BOOLEAN COMMENT 'Indicates whether completion of this eCRF form is mandatory for all subjects at the assigned visit(s). Mandatory forms must be completed or explicitly marked as not applicable before database lock.',
    `is_repeating` BOOLEAN COMMENT 'Indicates whether this eCRF form supports multiple instances (log lines) per subject per visit, such as Adverse Events or Concomitant Medications forms. True for log/repeating forms in Medidata Rave.',
    `is_subject_level` BOOLEAN COMMENT 'Indicates whether this form is collected once per subject across the entire study (e.g., Demographics, Medical History) rather than at each visit. Drives form placement in the EDC navigation structure.',
    `language_code` STRING COMMENT 'ISO 639-1 two-letter language code for the language in which this eCRF form is presented to site staff (e.g., en for English, de for German). Supports multi-language global study deployments.',
    `medical_coding_required` BOOLEAN COMMENT 'Indicates whether data collected on this form requires medical coding using standardized dictionaries (MedDRA for adverse events/medical history, WHO-DD for concomitant medications). Drives coding workflow assignment.',
    `primary_endpoint_flag` BOOLEAN COMMENT 'Indicates whether this eCRF form captures data for the studys primary efficacy or safety endpoint. Primary endpoint forms receive heightened data quality scrutiny, 100% SDV, and priority query resolution.',
    `protocol_section_ref` STRING COMMENT 'Reference to the specific section(s) of the study protocol that this eCRF form supports (e.g., Section 8.2 - Safety Assessments). Ensures traceability between protocol requirements and data collection instruments.',
    `rave_form_reference` STRING COMMENT 'Native form identifier as assigned by the Medidata Rave EDC source system. Used for cross-referencing with the operational EDC system and data lineage tracking from source to lakehouse.',
    `requires_signature` BOOLEAN COMMENT 'Indicates whether this eCRF form requires an electronic signature (e.g., Principal Investigator sign-off) upon completion. Governs 21 CFR Part 11 compliant e-signature workflows in Medidata Rave.',
    `safety_form_flag` BOOLEAN COMMENT 'Indicates whether this eCRF form is designated as a safety data collection instrument (e.g., Adverse Events, Serious Adverse Events, Concomitant Medications). Safety forms are subject to expedited review and regulatory reporting timelines.',
    `sdtm_domain` STRING COMMENT 'CDISC SDTM domain code to which this eCRF form maps (e.g., AE for Adverse Events, VS for Vital Signs, DM for Demographics, LB for Laboratory). Drives SDTM transformation and regulatory submission dataset generation.',
    `sdv_percentage` DECIMAL(5,2) COMMENT 'Target percentage of data points on this form subject to Source Data Verification (SDV) as defined in the monitoring plan. Supports risk-based monitoring strategies (e.g., 100%, 50%, 10%).',
    `sdv_required` BOOLEAN COMMENT 'Indicates whether Source Data Verification (SDV) is required for data entered on this form. Critical forms (e.g., primary endpoints, safety data) typically require 100% SDV; others may be risk-based.',
    `signature_role` STRING COMMENT 'The role required to provide the electronic signature on this eCRF form (e.g., Principal Investigator). Applicable only when requires_signature is True.. Valid values are `principal_investigator|sub_investigator|data_manager|sponsor_representative|not_required`',
    `sponsor_form_number` STRING COMMENT 'Sponsor-assigned form number or code used in the paper CRF or sponsors internal document management system. Enables cross-referencing between the EDC form and sponsor documentation (e.g., annotated CRF).',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this eCRF form definition record. Supports change tracking, audit trail, and ALCOA+ compliance.',
    CONSTRAINT pk_ecrf_form PRIMARY KEY(`ecrf_form_id`)
) COMMENT 'Master definition of Electronic Case Report Form (eCRF) designs built in Medidata Rave EDC. Captures form name, version, study association, form type (visit-based, unscheduled, log/repeating), completion rules, CDISC SDTM domain mapping, data entry mode';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` (
    `subject_visit_data_id` BIGINT COMMENT 'Unique surrogate identifier for each subject visit data record in the Databricks Silver Layer. Primary key for this transactional entity representing one eCRF data collection event per subject per visit.',
    `codelist_id` BIGINT COMMENT 'Classification of the visit as defined in the protocol (e.g., scheduled per protocol, unscheduled/ad hoc, early termination, follow-up, telephone contact). Drives protocol deviation detection and data completeness expectations.',
    `consent_subject_consent_id` BIGINT COMMENT 'Foreign key linking to consent.subject_consent. Business justification: GCP/ICH E6 requires that data collection at each visit occurs under valid informed consent. Monitors and data managers verify consent status during SDV and data review.',
    `database_lock_event_id` BIGINT COMMENT 'Foreign key linking to biostatistics.database_lock_event. Business justification: Subject visit data records are locked as part of the database lock process.',
    `ecrf_form_id` BIGINT COMMENT 'Foreign key linking to datamanagement.ecrf_form. Business justification: subject_visit_data captures data collected for a specific eCRF form at a visit. ecrf_form is the master form definition.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site where the subject visit data was collected. Enables site-level data quality and monitoring analytics.',
    `study_visit_schedule_id` BIGINT COMMENT 'Foreign key linking to study.study_visit_schedule. Business justification: Protocol deviation detection and data completeness monitoring: linking actual subject visit data records to the protocol-defined visit schedule entry enables automated',
    `subject_randomization_id` BIGINT COMMENT 'Foreign key linking to randomization.subject_randomization. Business justification: Data lock and DBL processes require visit-level data records to be directly associated with the subjects randomization assignment for treatment-arm-stratified data',
    `treatment_arm_id` BIGINT COMMENT 'Foreign key linking to randomization.treatment_arm. Business justification: Subject visit data must be associated with the treatment arm to support arm-specific data review workflows, SDV planning, SDTM ARM variable population, and edit check application.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the enrolled trial subject (participant) whose clinical data is captured in this visit record. Core party reference for this transactional entity.',
    `visit_id` BIGINT COMMENT 'Foreign key linking to subject.subject_visit. Business justification: CRAs performing SDV and data managers reviewing visit-level data completeness must join subject_visit_data (EDC completeness/lock status) to the operational subject_visit record.',
    `alcoa_compliant` BOOLEAN COMMENT 'Indicates whether this subject visit data record meets all ALCOA+ data quality principles (Attributable, Legible, Contemporaneous, Original, Accurate, plus Complete, Consistent, Enduring, Available).',
    `cdisc_sdtm_domain` STRING COMMENT 'The CDISC SDTM domain code to which this eCRF form maps (e.g., DM for Demographics, VS for Vital Signs, AE for Adverse Events, LB for Laboratory). Used to drive SDTM transformation and regulatory submission packaging in SAS Drug Development.',
    `completion_status` STRING COMMENT 'Current lifecycle state of the eCRF form in Medidata Rave. Reflects the data entry and review workflow: incomplete (data entry in progress), complete (all required fields entered), frozen (data frozen pending review), locked (data locked post-database. Valid values are `incomplete|complete|frozen|locked|signed`',
    `data_completeness_pct` DECIMAL(5,2) COMMENT 'The percentage of required eCRF fields that have been populated for this subject visit form, calculated as (completed fields / total required fields) × 100. Key metric for data quality monitoring and site performance KPIs. Range: 0.00 to 100.00.',
    `data_entry_timestamp` TIMESTAMP COMMENT 'The date and time when data was first entered into this eCRF form in Medidata Rave. Represents the ALCOA+ Contemporaneous requirement — data must be recorded at the time of the observation. This is the record creation audit timestamp.',
    `data_review_status` STRING COMMENT 'Current status of the medical/data management review of this subject visit form. Tracks the review workflow from initial data entry through medical monitor approval. Values: not_started, in_review, reviewed, approved, requires_correction.. Valid values are `not_started|in_review|reviewed|approved|requires_correction`',
    `edc_record_reference` STRING COMMENT 'The native record identifier assigned by Medidata Rave EDC to this subject visit form instance. Used for traceability back to the source EDC system and for audit trail reconciliation.',
    `entered_by` STRING COMMENT 'The username of the Clinical Research Coordinator (CRC) or site staff member who initially entered data into this eCRF form in Medidata Rave. Satisfies ALCOA+ Attributable requirement — data must be traceable to the person who recorded it.',
    `freeze_status` BOOLEAN COMMENT 'Indicates whether this subject visit form has been frozen in Medidata Rave (True = frozen; False = not frozen). Freezing is a pre-lock step that prevents further data entry while allowing review. Distinct from lock_status.',
    `freeze_timestamp` TIMESTAMP COMMENT 'The date and time when this subject visit form was frozen in Medidata Rave. Null if the form has not been frozen. Supports the pre-database lock workflow audit trail.',
    `investigator_signature_status` STRING COMMENT 'Status of the Principal Investigator (PI) or sub-investigator electronic signature on this eCRF form. Required for regulatory compliance under 21 CFR Part 11 and ICH E6(R2). Values: not_required, pending, signed, rejected.. Valid values are `not_required|pending|signed|rejected`',
    `investigator_signature_timestamp` TIMESTAMP COMMENT 'The date and time when the Principal Investigator (PI) or sub-investigator applied their electronic signature to this eCRF form. Null if not yet signed. Required for 21 CFR Part 11 audit trail.',
    `last_modified_by` STRING COMMENT 'The username of the user who most recently modified this eCRF form record in Medidata Rave. Supports ALCOA+ Attributable requirement for all data changes.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'The date and time when this eCRF form record was most recently modified in Medidata Rave. Supports ALCOA+ audit trail and change tracking for data management workflows.',
    `lock_status` STRING COMMENT 'Indicates the database lock state of this subject visit form. Unlocked = data entry and editing permitted; locked = form locked as part of the database lock (DBL) workflow; hard_locked = irreversibly locked post-database lock for regulatory submission.. Valid values are `unlocked|locked|hard_locked`',
    `lock_timestamp` TIMESTAMP COMMENT 'The date and time when this subject visit form was locked in Medidata Rave as part of the database lock (DBL) workflow. Null if the form has not been locked. Critical for regulatory audit trail.',
    `locked_by` STRING COMMENT 'The username of the data management user who applied the lock to this subject visit form in Medidata Rave. Required for 21 CFR Part 11 electronic records audit trail.',
    `medical_coding_status` STRING COMMENT 'Status of medical coding for verbatim terms on this eCRF form using MedDRA (adverse events, medical history) or WHO Drug Dictionary (concomitant medications). Values: not_applicable (no codeable terms), pending, coded, approved, rejected.. Valid values are `not_applicable|pending|coded|approved|rejected`',
    `missing_data_flag` BOOLEAN COMMENT 'Indicates whether one or more required data fields are missing or unanswered on this eCRF form for the subject visit. True = missing data present; False = all required fields populated. Supports ALCOA+ compliance tracking.',
    `missing_field_count` BIGINT COMMENT 'The number of required eCRF fields that are currently unanswered or missing for this subject visit form. Provides granular data completeness tracking beyond the binary missing_data_flag.',
    `open_query_count` BIGINT COMMENT 'The number of currently open data queries (discrepancies) raised against this subject visit form in Medidata Rave. Used to track data cleaning progress and site responsiveness.',
    `protocol_deviation_flag` BOOLEAN COMMENT 'Indicates whether a protocol deviation has been identified in association with this subject visit data record (True = deviation present; False = no deviation). Supports compliance monitoring and regulatory reporting.',
    `rave_page_repeat_key` BIGINT COMMENT 'The repeat sequence key for repeating forms (log pages) in Medidata Rave, used when a subject has multiple instances of the same form within a single visit (e.g., multiple adverse event entries). Value is 1 for non-repeating forms.',
    `sdv_date` DATE COMMENT 'The date on which source data verification (SDV) was completed for this subject visit form by the Clinical Research Associate (CRA). Null if SDV has not been performed.',
    `sdv_status` STRING COMMENT 'Current status of source data verification (SDV) for this subject visit form. Reflects whether the CRA has verified the eCRF data against source documents at the site.. Valid values are `not_required|pending|partial|verified|overdue`',
    `subject_number` STRING COMMENT 'The externally-known alphanumeric identifier assigned to the subject within the study (e.g., site-subject number such as 001-0042). Used in eCRF, regulatory submissions, and CDISC SDTM USUBJID derivation. Directly identifies a trial participant.',
    `total_query_count` BIGINT COMMENT 'The total number of data queries (discrepancies) ever raised against this subject visit form, including open, answered, and closed queries. Supports data quality trend analysis.',
    `visit_date` DATE COMMENT 'The actual calendar date on which the subject attended the study visit and clinical data was collected. Represents the principal real-world event date. Maps to SVSTDTC in CDISC SDTM.',
    `visit_window_end_date` DATE COMMENT 'The latest acceptable calendar date for this protocol-defined visit per the study schedule of assessments. Used to assess whether the visit occurred within the protocol-specified window.',
    `visit_window_start_date` DATE COMMENT 'The earliest acceptable calendar date for this protocol-defined visit per the study schedule of assessments. Used to assess whether the visit occurred within the protocol-specified window.',
    `visit_within_window` BOOLEAN COMMENT 'Indicates whether the actual visit date falls within the protocol-defined visit window (visit_window_start_date to visit_window_end_date). True = within window; False = outside window (potential protocol deviation).',
    CONSTRAINT pk_subject_visit_data PRIMARY KEY(`subject_visit_data_id`)
) COMMENT 'Transactional record of all eCRF data collected for a subject at a specific study visit in Medidata Rave. Captures subject identifier, visit name/number, visit date, form completion status (incomplete, complete, frozen, locked), data completeness';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` (
    `field_entry_id` BIGINT COMMENT 'Unique surrogate identifier for each atomic field-level data entry record in the Electronic Data Capture (EDC) system. Primary key for the field_entry data product in the Databricks Silver Layer.',
    `demographic_id` BIGINT COMMENT 'Foreign key linking to subject.demographic. Business justification: Field entries capturing demographic data must link to demographic records for data lineage, source data verification, and SDTM DM domain traceability. Required for regulatory submissions.',
    `discrepancy_query_id` BIGINT COMMENT 'Reference to an open or resolved data query (discrepancy) raised against this field entry. A field entry may have an associated query requiring site clarification before database lock (DBL). Null if no query exists.',
    `dispensing_record_id` BIGINT COMMENT 'Foreign key linking to supply.dispensing_record. Business justification: EDC field entries for dispensing/accountability eCRF forms must be reconcilable against RTSM dispensing confirmations.',
    `ecrf_field_id` BIGINT COMMENT 'Foreign key linking to datamanagement.ecrf_field. Business justification: field_entry is an atomic data entry for a specific eCRF field. ecrf_field is the master field definition.',
    `ecrf_form_id` BIGINT COMMENT 'Reference to the electronic Case Report Form (eCRF) form definition that contains this field. Identifies the form context (e.g., Adverse Event form, Vital Signs form) within Medidata Rave.',
    `ehr_data_transfer_id` BIGINT COMMENT 'Foreign key linking to datamanagement.ehr_data_transfer. Business justification: A field_entry record can be populated via an eSource/EHR data transfer batch rather than manual EDC entry.',
    `enrollment_id` BIGINT COMMENT 'Foreign key linking to subject.enrollment. Business justification: Field entries require enrollment context for data lock scope, population flag determination, and protocol version-specific validation rules.',
    `irt_transaction_id` BIGINT COMMENT 'Foreign key linking to randomization.irt_transaction. Business justification: IRT-EDC reconciliation requires linking eCRF field entries for randomization/kit fields directly to the IRT transaction that triggered them.',
    `lab_result_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_result. Business justification: Source Data Verification (SDV) requires matching each eCRF field entry for lab values against the originating lab result from the LIMS.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) under which this field entry was captured. Links the field entry to its parent study context for filtering, reporting, and regulatory submission.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site at which this field entry was recorded. Supports site-level data quality monitoring and CRA (Clinical Research Associate) review workflows.',
    `subject_randomization_id` BIGINT COMMENT 'Foreign key linking to randomization.subject_randomization. Business justification: Individual eCRF field entries for randomization-related data points (randomization number, treatment assignment confirmation) must be traceable to the',
    `subject_visit_data_id` BIGINT COMMENT 'Foreign key linking to datamanagement.subject_visit_data. Business justification: field_entry is an atomic-level data entry that belongs to a subject visit data record.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the clinical trial subject (patient) whose data this field entry represents. Enables subject-level audit trail and source data verification (SDV) traceability.',
    `validation_rule_id` BIGINT COMMENT 'The identifier of the edit check or validation rule in Medidata Rave that was triggered by this field entry. Supports data validation rule management, discrepancy tracking, and DMP (Data Management Plan) compliance reporting.',
    `visit_id` BIGINT COMMENT 'Reference to the scheduled or unscheduled study visit during which this field entry was collected. Provides temporal context for the data point within the subjects study timeline.',
    `alcoa_accurate` BOOLEAN COMMENT 'ALCOA+ compliance flag indicating whether the field entry value has been verified as accurate against the source document or original observation. Set to true upon successful SDV or data review confirmation.',
    `alcoa_attributable` BOOLEAN COMMENT 'ALCOA+ compliance flag indicating whether the field entry is attributable to a specific, identified individual (i.e., the entered_by_user is known and authenticated). One of the core ALCOA+ data integrity principles required by FDA and ICH.',
    `alcoa_contemporaneous` BOOLEAN COMMENT 'ALCOA+ compliance flag indicating whether the field entry was recorded at the time the observation was made (i.e., entry_timestamp is within an acceptable window of the actual observation date). Supports data integrity and GCP compliance monitoring.',
    `alcoa_legible` BOOLEAN COMMENT 'ALCOA+ compliance flag indicating whether the field entry value is legible and readable. Particularly relevant for transcribed or scanned source data. Supports data integrity assessments during regulatory inspections.',
    `alcoa_original` BOOLEAN COMMENT 'ALCOA+ compliance flag indicating whether this field entry represents the original (first) recorded value, as opposed to a transcription or copy. Distinguishes primary source data from derived or transferred data.',
    `audit_trail_ref` STRING COMMENT 'The unique reference identifier linking this field entry to its corresponding audit trail record in Medidata Rave. Enables direct cross-referencing with the EDC systems immutable audit log for regulatory inspection and SDV activities.',
    `coded_term` STRING COMMENT 'The standardized dictionary term assigned to this field entry after medical coding (e.g., MedDRA Preferred Term (PT) for adverse events, WHO-DD drug name for medications). Null for fields not requiring coding.',
    `coding_dictionary` STRING COMMENT 'The standardized medical coding dictionary used to code this field entry (e.g., MedDRA for adverse events and medical history, WHO-DD for concomitant medications). Null or not_applicable for fields not requiring coding.. Valid values are `MedDRA|WHO-DD|SNOMED-CT|ICD-10|LOINC|not_applicable`',
    `data_entry_type` STRING COMMENT 'Classifies how the field value was populated in the EDC system. Distinguishes between manual site entry, system auto-population (e.g., calculated fields), data migration, or external data import (e.g., lab data transfer).. Valid values are `manual|auto_populated|derived|migrated|imported`',
    `entry_status` STRING COMMENT 'Current workflow status of the field entry within the EDC system lifecycle. Drives data review, query management, and database lock (DBL) readiness assessments.. Valid values are `entered|modified|deleted|frozen|locked|sdv_complete`',
    `entry_timestamp` TIMESTAMP COMMENT 'The date and time (with timezone) at which the field value was originally entered into the EDC system by the site user. Supports ALCOA+ contemporaneous data entry verification and audit trail analysis.',
    `entry_value` DECIMAL(18,2) COMMENT 'The actual data value entered into the eCRF field by the site user. Stored as STRING to accommodate all field types (numeric, text, date, coded). This is the primary clinical data payload and is classified as Protected Health Information (PHI) under HIPAA.',
    `field_data_type` STRING COMMENT 'The data type of the eCRF field as defined in the study build (e.g., text, numeric, date, coded list). Governs validation rules applied to the entry_value and supports downstream SDTM transformation logic.',
    `form_name` STRING COMMENT 'The name of the eCRF form (e.g., Adverse Events, Vital Signs, Laboratory Results) within which this field resides. Provides form-level context for data review and query management.',
    `has_open_query` BOOLEAN COMMENT 'Indicates whether this field entry currently has at least one open data query (discrepancy) requiring resolution. Supports real-time data cleaning dashboards and DBL readiness tracking.',
    `is_frozen` BOOLEAN COMMENT 'Indicates whether this field entry has been frozen, preventing further modification by site users. Freezing is a pre-lock step in the database lock (DBL) workflow to protect data integrity prior to statistical analysis.',
    `is_locked` BOOLEAN COMMENT 'Indicates whether this field entry has been locked as part of the Database Lock (DBL) process. Locked fields are immutable and represent the final, analysis-ready dataset. Supports ALCOA+ Enduring and Available principles.',
    `is_missing` BOOLEAN COMMENT 'Indicates whether this field entry represents a missing data point (i.e., the field was expected but no value was entered or a missing reason code was provided). Supports data completeness reporting and ALCOA+ compliance tracking.',
    `locked_timestamp` TIMESTAMP COMMENT 'The date and time at which this field entry was locked as part of the Database Lock (DBL) process. Null if the field has not yet been locked. Provides a precise audit record of the lock event for regulatory submissions.',
    `medical_coding_status` STRING COMMENT 'The medical coding status for fields requiring standardized coding (e.g., adverse event terms coded to MedDRA, concomitant medications coded to WHO-DD). Tracks whether the verbatim term has been coded to a standard dictionary term.. Valid values are `not_required|pending|coded|auto_coded|recoded`',
    `missing_reason_code` STRING COMMENT 'Standardized code explaining why a field value is missing (e.g., NOT_DONE, UNKNOWN, NA). Aligns with CDISC CDASH missing data handling conventions and supports statistical analysis plan (the source system) imputation strategies.. Valid values are `NOT_DONE|UNKNOWN|NA|NOT_APPLICABLE|TECHNICAL_FAILURE|SUBJECT_REFUSED`',
    `modified_by_user` STRING COMMENT 'The username or system identifier of the EDC user who last modified this field entry. Null if the field has never been modified. Required for complete audit trail attribution under 21 CFR Part 11.',
    `modified_timestamp` TIMESTAMP COMMENT 'The date and time of the most recent modification to this field entry. Null if the field has never been modified after initial entry. Part of the complete audit trail required under 21 CFR Part 11.',
    `previous_value` DECIMAL(18,2) COMMENT 'The value of the field prior to the most recent modification. Captured as part of the ALCOA+ (Attributable, Legible, Contemporaneous, Original, Accurate) audit trail to support source data verification (SDV) and regulatory inspection readiness.',
    `rave_record_reference` STRING COMMENT 'The native record identifier assigned by Medidata Rave EDC to the parent data record (row) containing this field entry. Used for cross-referencing with the source EDC system and audit trail reconciliation.',
    `reason_for_change` STRING COMMENT 'The free-text justification provided by the site user when modifying a previously entered field value. Mandatory for all post-entry modifications per GCP and 21 CFR Part 11 audit trail requirements. Supports ALCOA+ Accurate principle.',
    `sdtm_domain` STRING COMMENT 'The CDISC SDTM domain (two-letter code) to which this field belongs (e.g., AE for Adverse Events, VS for Vital Signs, LB for Laboratory). Supports SDTM dataset construction and regulatory submission packaging.',
    `sdtm_variable` STRING COMMENT 'The CDISC SDTM variable name to which this field maps (e.g., AESTDTC, VSORRES, LBSTRESC). Enables automated SDTM transformation and regulatory submission dataset generation via SAS Drug Development.',
    `sdv_by_user` STRING COMMENT 'The username of the CRA or authorized reviewer who performed Source Data Verification (SDV) on this field entry. Satisfies ALCOA+ Attributable requirement for the verification action.',
    `sdv_status` STRING COMMENT 'The current Source Data Verification (SDV) status of this field entry. Indicates whether a CRA has verified the entered value against the original source document (e.g., medical record). Critical for GCP compliance and monitoring visit reporting.. Valid values are `not_required|pending|verified|failed`',
    `sdv_timestamp` TIMESTAMP COMMENT 'The date and time at which the CRA completed Source Data Verification (SDV) for this field entry. Null if SDV has not been performed. Supports monitoring visit close-out and audit trail completeness.',
    `validation_result` STRING COMMENT 'The outcome of the edit check or validation rule applied to this field entry at the time of data entry. A fail result triggers a data query. Supports data quality monitoring and DMP compliance.. Valid values are `pass|fail|warning|not_evaluated`',
    CONSTRAINT pk_field_entry PRIMARY KEY(`field_entry_id`)
) COMMENT 'Atomic-level transactional record capturing a single field-level data entry in the EDC system (Medidata Rave). Stores the field value, entry timestamp, entered-by user, reason for change, previous value, audit trail reference, and ALCOA+ compliance flags';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` (
    `discrepancy_query_id` BIGINT COMMENT 'Unique surrogate identifier for each discrepancy query record in the Databricks Silver Layer. Primary key for the discrepancy_query data product.',
    `consent_subject_consent_id` BIGINT COMMENT 'Foreign key linking to consent.consent_subject_consent. Business justification: GCP (ICH E6 R2) and FDA 21 CFR Part 11 require that data queries are traceable to a valid subject consent record.',
    `demographic_id` BIGINT COMMENT 'Foreign key linking to subject.demographic. Business justification: Queries on demographic data must link to demographic records for data quality, regulatory submission accuracy, and SDTM DM domain validation. Essential for subject identification.',
    `dispensing_record_id` BIGINT COMMENT 'Foreign key linking to supply.dispensing_record. Business justification: Data queries raised against dispensing eCRF fields must be traceable to the RTSM dispensing record to enable query resolution and IMP accountability reconciliation.',
    `ecrf_field_id` BIGINT COMMENT 'Foreign key linking to datamanagement.ecrf_field. Business justification: discrepancy_query is raised against a specific eCRF field. ecrf_field is the master field definition.',
    `ecrf_form_id` BIGINT COMMENT 'Foreign key linking to datamanagement.ecrf_form. Business justification: discrepancy_query is raised against data in a specific eCRF form. ecrf_form is the master form definition.',
    `enrollment_id` BIGINT COMMENT 'Foreign key linking to subject.enrollment. Business justification: Queries must track enrollment context for protocol version applicability, population-specific validation rules, and enrollment status-dependent query resolution workflows.',
    `investigational_site_id` BIGINT COMMENT 'Reference to the investigative site where the subject data entry originated, enabling site-level query metrics and monitoring.',
    `lab_result_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_result. Business justification: EDC discrepancy queries raised against lab values (out-of-range, missing results, transcription errors) must reference the source lab result for data managers to compare EDC-entered',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Discrepancy queries must reference the protocol version in effect when raised — required for regulatory inspection and query trend analysis by protocol version.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) against which this discrepancy query was raised. Links the query to its parent study context.',
    `subject_visit_data_id` BIGINT COMMENT 'Foreign key linking to datamanagement.subject_visit_data. Business justification: A discrepancy query is raised against eCRF data collected at a specific subject visit.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial subject (patient) whose eCRF data entry triggered this discrepancy query. Central to subject-level data cleaning workflows.',
    `validation_rule_id` BIGINT COMMENT 'Foreign key linking to datamanagement.validation_rule. Business justification: discrepancy_query has edit_check_name indicating the validation rule (edit check) that triggered the query. validation_rule is the master definition of programmatic edit checks.',
    `cancellation_reason` STRING COMMENT 'Explanation for why the discrepancy query was cancelled (e.g., raised in error, duplicate query, data corrected via another mechanism). Required for audit trail integrity.',
    `cancelled_timestamp` TIMESTAMP COMMENT 'Date and time when the discrepancy query was cancelled (withdrawn) in Medidata Rave. Populated only when query_status = cancelled.',
    `closed_by_user` STRING COMMENT 'Username of the DM or reviewer who closed the discrepancy query after verifying the site response and confirming data correction in Medidata Rave.',
    `closed_timestamp` TIMESTAMP COMMENT 'Date and time when the discrepancy query was formally closed (resolved and accepted) by the data management team. Used to measure total query lifecycle duration and DBL readiness.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this discrepancy query record was first created in the Databricks Silver Layer data product. Audit trail field for data lineage and 21 CFR Part 11 compliance.',
    `data_value_corrected` STRING COMMENT 'The corrected data value entered in the eCRF field after query resolution. Populated when the site updates the data entry in response to the query. Supports data change audit trail.',
    `data_value_original` STRING COMMENT 'The original data value entered in the eCRF field at the time the query was raised. Preserved for audit trail and ALCOA+ compliance to document the pre-correction state.',
    `days_open` BIGINT COMMENT 'Number of calendar days the query has been in open or answered status since raised_timestamp. Operational metric used for site performance monitoring and query aging reports. Recalculated daily.',
    `escalation_timestamp` TIMESTAMP COMMENT 'Date and time when the query was escalated. Populated only when is_escalated = true. Used to track escalation response times and site performance.',
    `is_dbl_blocking` BOOLEAN COMMENT 'Indicates whether this open query is blocking the Database Lock (DBL) process. DBL-blocking queries must be resolved before the study database can be locked for statistical analysis.',
    `is_escalated` BOOLEAN COMMENT 'Indicates whether this discrepancy query has been escalated due to non-response, repeated failure to resolve, or critical data impact. Triggers escalation workflow in CTMS and monitoring processes.',
    `is_safety_related` BOOLEAN COMMENT 'Indicates whether the discrepancy query relates to safety data (e.g., Adverse Events, SAEs, concomitant medications). Safety-related queries require expedited resolution per GCP and regulatory requirements.',
    `priority` STRING COMMENT 'Business priority level assigned to the discrepancy query, indicating urgency of resolution. Critical queries may relate to safety data, primary endpoints, or DBL-blocking issues.. Valid values are `critical|high|medium|low`',
    `query_category` STRING COMMENT 'Business classification of the data issue driving the query (e.g., missing data, out-of-range value, inconsistency, protocol deviation, transcription error, coding discrepancy).',
    `query_number` STRING COMMENT 'Externally visible, human-readable identifier for the discrepancy query as assigned by Medidata Rave EDC (e.g., QRY-0001234). Used in site communications, monitoring reports, and audit trails.',
    `query_status` STRING COMMENT 'Current lifecycle state of the discrepancy query within the data cleaning workflow. Open = awaiting site response; Answered = site has responded, pending review; Closed = resolved and accepted; Cancelled = query withdrawn.. Valid values are `open|answered|closed|cancelled`',
    `query_text` STRING COMMENT 'Full text of the discrepancy query message as displayed to the site. Describes the data issue and requests specific corrective action or clarification from the investigator.',
    `query_type` STRING COMMENT 'Classification of the query origin: manual = CRA/DM-raised; system = g., lab, SAE reconciliation).. Valid values are `manual|system|review|reconciliation`',
    `raised_by_role` STRING COMMENT 'Functional role of the person or system that raised the query (e.g., CRA - Clinical Research Associate, DM - Data Manager, medical reviewer, system for automated edit checks). Supports workload and quality analytics by role.. Valid values are `CRA|DM|medical_reviewer|system|sponsor|other`',
    `raised_timestamp` TIMESTAMP COMMENT 'Date and time when the discrepancy query was first raised in Medidata Rave EDC. Represents the principal business event timestamp for this transaction. Critical for ALCOA+ contemporaneous documentation compliance.',
    `rave_query_reference` STRING COMMENT 'Native query identifier from Medidata Rave EDC source system. Enables traceability back to the originating system record for audit and reconciliation purposes.',
    `reopen_count` BIGINT COMMENT 'Number of times this query has been re-opened after being answered or closed, indicating iterative resolution cycles. High reopen counts signal site data quality issues or unclear query text.',
    `resolution_cycle_days` BIGINT COMMENT 'Number of calendar days between raised_timestamp and closed_timestamp. Measures end-to-end query resolution efficiency; key data management KPI for study performance dashboards.',
    `response_by_user` STRING COMMENT 'Username of the site staff member (CRC or PI) who submitted the query response in Medidata Rave. Required for ALCOA+ attributability.',
    `response_cycle_days` BIGINT COMMENT 'Number of calendar days between raised_timestamp and response_timestamp. Measures site responsiveness to data queries; used in site performance KPI reporting.',
    `response_text` STRING COMMENT 'Sites textual response to the discrepancy query, entered by the CRC or PI in Medidata Rave. Captures the explanation, correction, or clarification provided by the site.',
    `response_timestamp` TIMESTAMP COMMENT 'Date and time when the site submitted their response to the discrepancy query in Medidata Rave. Used to calculate query response cycle time KPIs.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this discrepancy query record was last modified in the Databricks Silver Layer data product. Supports incremental data processing and change detection.',
    `visit_name` STRING COMMENT 'Name of the study visit (e.g., Screening, Week 4, End of Treatment) associated with the eCRF data entry that triggered the query. Supports visit-level data quality reporting.',
    CONSTRAINT pk_discrepancy_query PRIMARY KEY(`discrepancy_query_id`)
) COMMENT 'Transactional record of ALL data queries (discrepancies) raised against eCRF data entries in Medidata Rave, serving as the single source of truth for data quality issues regardless of origin.';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` (
    `validation_rule_id` BIGINT COMMENT 'Unique surrogate identifier for each validation rule (edit check) record in the Medidata Rave EDC system. Primary key for the validation_rule data product.',
    `bioanalytical_assay_id` BIGINT COMMENT 'Foreign key linking to laboratory.bioanalytical_assay. Business justification: Edit checks for PK/bioanalytical data (LLOQ threshold checks, ULOQ flags, dilution factor validation, ISR flags) are assay-specific.',
    `dmp_id` BIGINT COMMENT 'Foreign key linking to datamanagement.dmp. Business justification: validation_rule has dmp_reference (STRING) indicating the governing Data Management Plan. dmp is the master DMP record.',
    `document_sop_id` BIGINT COMMENT 'Foreign key linking to document.document_sop. Business justification: Edit check / validation rules are created and maintained per a Data Validation or Edit Check SOP. GCP audit readiness requires traceability from each rule to its governing SOP.',
    `ecrf_field_id` BIGINT COMMENT 'Foreign key linking to datamanagement.ecrf_field. Business justification: validation_rule (edit check) is scoped to a specific eCRF field in Medidata Rave. ecrf_field is the master field definition.',
    `ecrf_form_id` BIGINT COMMENT 'Foreign key linking to datamanagement.ecrf_form. Business justification: validation_rule (edit check) is scoped to a specific eCRF form in Medidata Rave. ecrf_form is the master form definition.',
    `endpoint_id` BIGINT COMMENT 'Foreign key linking to study.endpoint. Business justification: Validation rules for primary endpoint fields require heightened scrutiny and are flagged in the DMP.',
    `lab_panel_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_analyte. Business justification: EDC edit checks for lab data (range checks, unit validations) are analyte-specific. Linking validation rules to the analyte definition enables automated consistency checks between EDC',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Edit checks and validation rules are authored against protocol-defined data collection requirements.',
    `rand_scheme_id` BIGINT COMMENT 'Foreign key linking to randomization.rand_scheme. Business justification: EDC validation rules (edit checks) for randomization data entry — validating entered randomization numbers against IRT-assigned values, stratification factor consistency — are',
    `reference_range_id` BIGINT COMMENT 'Foreign key linking to laboratory.reference_range. Business justification: EDC range-check validation rules must be derived from and linked to the lab facilitys reference ranges to ensure consistency.',
    `risk_assessment_id` BIGINT COMMENT 'Foreign key linking to compliance.risk_assessment. Business justification: ICH E6(R2) mandates risk-based data management: validation rules for critical data fields must be traceable to the risk assessment that identified them as critical.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this validation rule is configured. Links the edit check to its parent protocol context in Medidata Rave.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: EDC validation rule change control: when a protocol amendment alters data collection requirements, validation rules must be updated and versioned.',
    `activation_date` DATE COMMENT 'The date on which this validation rule was activated (deployed to production) in Medidata Rave EDC. Marks the start of the rules operational period. Used for change control documentation and audit trail.',
    `approved_timestamp` TIMESTAMP COMMENT 'Date and time when this validation rule was formally approved for deployment by the authorized Data Manager. Required for 21 CFR Part 11 electronic records compliance and change control audit trail.',
    `cdisc_domain` STRING COMMENT 'The CDISC SDTM domain abbreviation associated with the field targeted by this rule (e.g., AE, VS, CM, LB, EX). Supports CDISC compliance reporting and SDTM transformation traceability.',
    `cdisc_variable` STRING COMMENT 'The CDISC SDTM or CDASH variable name that this validation rule maps to (e.g., AESTDTC, VSVAL, CMTRT). Enables traceability from the edit check to the CDISC submission variable for regulatory compliance and SDTM transformation validation.',
    `change_reason` STRING COMMENT 'Documented business or regulatory justification for the most recent change to this validation rule (e.g., protocol amendment, data quality finding, regulatory feedback). Required for 21 CFR Part 11 audit trail and change control compliance.',
    `country_applicability` STRING COMMENT 'Comma-separated list of ISO 3166-1 alpha-3 country codes (e.g., USA,GBR,DEU) indicating the countries where this validation rule applies. Null if the rule applies globally.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this validation rule record was first created in the system. Supports ALCOA+ contemporaneous documentation requirements and 21 CFR Part 11 audit trail.',
    `deactivation_date` DATE COMMENT 'The date on which this validation rule was deactivated or retired in Medidata Rave EDC. Null if the rule is currently active. Required for version history tracking and regulatory audit trail per 21 CFR Part 11.',
    `effective_from` DATE COMMENT 'The date from which this version of the validation rule is considered effective for data collection purposes. May differ from activation_date if the rule was pre-configured before deployment. Supports temporal validity tracking.',
    `effective_until` DATE COMMENT 'The date until which this version of the validation rule is effective. Null for open-ended rules. Enables temporal validity management and supports retroactive data impact analysis when rules are superseded.',
    `generates_query` BOOLEAN COMMENT 'Indicates whether this validation rule automatically generates a data query (discrepancy) in Medidata Rave when triggered (True) or only performs a silent validation without raising a query (False). Drives query management workflow volume.',
    `is_cdisc_compliant` BOOLEAN COMMENT 'Indicates whether this validation rule has been verified as compliant with CDISC CDASH/SDTM data standards. True = rule aligns with CDISC requirements; False = rule is study-specific or non-standard. Used in regulatory submission readiness assessments.',
    `is_mandatory` BOOLEAN COMMENT 'Indicates whether this validation rule is mandatory per the study protocol or regulatory requirement (True) or optional/advisory (False). Mandatory rules cannot be waived without formal change control and regulatory justification.',
    `modified_by` STRING COMMENT 'Name or user identifier of the person who last modified this validation rule record. Required for ALCOA+ attributability and 21 CFR Part 11 audit trail compliance.',
    `modified_timestamp` TIMESTAMP COMMENT 'Date and time when this validation rule record was last updated. Supports ALCOA+ contemporaneous documentation and 21 CFR Part 11 audit trail for change history tracking.',
    `notes` STRING COMMENT 'Free-text field for additional operational notes, implementation guidance, known limitations, or contextual information about this validation rule. Supports Data Management team knowledge management and DMP documentation.',
    `previous_version` STRING COMMENT 'Version identifier of the immediately preceding version of this validation rule, enabling version chain traceability. Supports audit trail reconstruction and change impact analysis per 21 CFR Part 11.. Valid values are `^d+.d+(.d+)?$`',
    `query_text` STRING COMMENT 'The standardized query message text that is automatically generated and displayed to the site user (CRC/PI) in Medidata Rave when this validation rule fires. Instructs the site on the data discrepancy and required corrective action.',
    `rave_edit_check_reference` STRING COMMENT 'The native edit check identifier as assigned by Medidata Rave EDC (source system key). Enables direct traceability back to the source system record for reconciliation, UAT, and system integration purposes.',
    `rule_category` STRING COMMENT 'Classification of the validation rule by its logical type: range_check (numeric bounds), cross_form (inter-form consistency), date_logic (temporal relationships), required_field (mandatory data presence), consistency_check (intra-form logic), coding_check. Valid values are `range_check|cross_form|date_logic|required_field|consistency_check|coding_check`',
    `rule_code` STRING COMMENT 'Externally-known unique alphanumeric code assigned to the validation rule within the EDC system (e.g., EC_AESTDT_001). Used as the business identifier for cross-referencing in DMP, the source system, and audit documentation.. Valid values are `^[A-Z0-9_-]{2,50}$`',
    `rule_description` STRING COMMENT 'Detailed narrative description of the validation rules business purpose, the data quality condition it enforces, and the expected corrective action when triggered. Supports DMP documentation and regulatory audit readiness.',
    `rule_expression` STRING COMMENT 'The programmatic logic or expression defining the edit check condition as coded in Medidata Rave (e.g., OpenRave expression syntax or Rave Edit Check language). Captures the exact computational rule used to evaluate data validity.',
    `rule_name` STRING COMMENT 'Human-readable name or short title of the validation rule as configured in Medidata Rave EDC (e.g., AE Start Date Cannot Be After End Date). Used for display in query management and DMP documentation.',
    `rule_status` STRING COMMENT 'Current lifecycle status of the validation rule in Medidata Rave EDC: draft (in development, not yet deployed), active (deployed and executing), inactive (temporarily disabled), retired (permanently decommissioned), under_review (pending change control. Valid values are `draft|active|inactive|retired|under_review`',
    `rule_type` STRING COMMENT 'Classifies the technical implementation type of the validation rule in Medidata Rave: edit_check (standard Rave edit check), derivation (computed/derived field rule), custom_function (OpenRave custom function), system_check (system-level validation).. Valid values are `edit_check|derivation|custom_function|system_check`',
    `rule_version` STRING COMMENT 'Version identifier of the validation rule following semantic versioning (e.g., 1.0, 1.1, 2.0). Tracks the change history of the rule expression, severity, or configuration. Required for 21 CFR Part 11 audit trail and change control compliance.. Valid values are `^d+.d+(.d+)?$`',
    `scope` STRING COMMENT 'The level at which the validation rule operates within the Medidata Rave data hierarchy: field (single data point), form (entire eCRF page), folder (visit/event folder), study (cross-visit/global). Determines the breadth of data evaluated by the rule.. Valid values are `field|form|folder|study`',
    `severity_level` STRING COMMENT 'Severity classification of the validation rule determining how the EDC system responds when the rule fires: error (blocks data entry/save), warning (alerts user but allows save), informational (advisory only).. Valid values are `error|warning|informational`',
    `trigger_condition` STRING COMMENT 'The EDC system event that causes this validation rule to execute: on_save (when the eCRF page is saved), on_entry (during data entry), on_change (when a field value changes), on_activation (when a form is activated), on_signature (at electronic. Valid values are `on_save|on_entry|on_change|on_activation|on_signature|batch`',
    `uat_completion_date` DATE COMMENT 'Date on which UAT was completed for this validation rule. Required for computer system validation documentation per 21 CFR Part 11 and FDA/EMA GCP expectations prior to production deployment.',
    `uat_status` STRING COMMENT 'Current User Acceptance Testing (UAT) status of this validation rule: not_started, in_progress, passed, failed, waived. UAT must be completed before a rule can be activated in production per GCP and 21 CFR Part 11 validation requirements.. Valid values are `not_started|in_progress|passed|failed|waived`',
    `created_by` STRING COMMENT 'Name or user identifier of the Data Manager who originally authored and configured this validation rule in Medidata Rave EDC. Supports ALCOA+ attributability requirements and 21 CFR Part 11 audit trail.',
    CONSTRAINT pk_validation_rule PRIMARY KEY(`validation_rule_id`)
) COMMENT 'Master definition of programmatic data validation rules (edit checks) configured in Medidata Rave EDC. Captures rule name, rule expression/logic, trigger condition, associated form and field, severity level (error, warning), rule category (range check';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` (
    `dmp_id` BIGINT COMMENT 'Unique surrogate identifier for the Data Management Plan record in the lakehouse silver layer.',
    `audit_id` BIGINT COMMENT 'Foreign key linking to compliance.audit. Business justification: GCP auditors formally review the Data Management Plan as a key trial document. Linking dmp to the audit record (beyond the existing audit_finding_id) enables tracking which audit',
    `blinding_config_id` BIGINT COMMENT 'Foreign key linking to randomization.blinding_config. Business justification: The DMP must reference the blinding configuration to document EDC access restrictions, data review blinding rules, and unblinding procedures governing data management',
    `clinical_trial_authorization_id` BIGINT COMMENT 'Foreign key linking to regulatory.clinical_trial_authorization. Business justification: The Data Management Plan must reference the Clinical Trial Authorization governing data collection requirements in each authorized country.',
    `document_sop_id` BIGINT COMMENT 'Foreign key linking to document.document_sop. Business justification: The Data Management Plan is authored to satisfy the sponsors active delivery preferences (EDC system, SDV percentage, MedDRA version, monitoring strategy, CDISC compliance).',
    `ethics_approval_id` BIGINT COMMENT 'Foreign key linking to compliance.ethics_approval. Business justification: The DMP must align with ethics approval conditions governing data collection, privacy, and consent.',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.strategy. Business justification: The DMP must align with the regulatory strategy — submission timelines, SDTM/ADaM versions, and data collection approach are driven by the regulatory strategy.',
    `ind_application_id` BIGINT COMMENT 'Foreign key linking to regulatory.ind_application. Business justification: The DMP is developed in alignment with the IND application — data collection strategy, safety reporting obligations, and SDTM requirements must comply with IND commitments.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: The Data Management Plan is authored against a specific protocol version and must reference it for regulatory inspection.',
    `rand_scheme_id` BIGINT COMMENT 'Foreign key linking to randomization.rand_scheme. Business justification: The DMP must formally reference the randomization scheme it governs, defining blinding procedures, unblinding protocols, and data handling rules.',
    `regulatory_binder_id` BIGINT COMMENT 'Foreign key linking to document.regulatory_binder. Business justification: The Data Management Plan is submitted as part of regulatory packages and must be traceable to the regulatory binder containing it.',
    `regulatory_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to regulatory.protocol_amendment. Business justification: Protocol amendments trigger mandatory DMP revisions — changes to data collection strategy, eCRF design, or SDTM mapping must be documented.',
    `risk_assessment_id` BIGINT COMMENT 'Foreign key linking to compliance.risk_assessment. Business justification: The DMP documents the risk-based data review strategy, which is directly informed by the study risk assessment (ICH E6 R2 risk-based monitoring).',
    `sap_id` BIGINT COMMENT 'Foreign key linking to biostatistics.the source system. Business justification: The Data Management Plan must align with the Statistical Analysis Plan for data collection strategy, critical data fields, and DBL criteria.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this Data Management Plan governs all data management activities.',
    `tmf_artifact_id` BIGINT COMMENT 'Foreign key linking to document.document_template. Business justification: DMPs are authored from sponsor-standard DMP templates. Template governance requires traceability from each DMP to the template version used, ensuring consistency across studies and',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: The DMP is a TMF essential document (DIA TMF Zone 2). Regulators verify its eTMF filing during inspections.',
    `adam_ig_version` STRING COMMENT 'Version of the CDISC ADaM Implementation Guide used for this study. Governs the structure of analysis datasets produced from SDTM data for biostatistical reporting.',
    `alcoa_compliance_approach` STRING COMMENT 'Description of the approach and controls implemented to ensure ALCOA+ (Attributable, Legible, Contemporaneous, Original, Accurate, plus Complete, Consistent, Enduring, Available) data integrity compliance as defined in the DMP.',
    `amendment_reason` STRING COMMENT 'Narrative justification for the creation of a new version of the DMP. Null for the initial version (1.0). Documents the business or regulatory driver for the amendment.',
    `approval_date` DATE COMMENT 'Date on which this version of the DMP received final approval signature. Marks the transition from draft to approved status.',
    `approval_status` STRING COMMENT 'Current lifecycle approval state of the Data Management Plan. Controls whether the DMP is operationally active and governs data management activities for the study.. Valid values are `draft|under_review|approved|superseded|retired`',
    `autocoding_enabled` BOOLEAN COMMENT 'Indicates whether automated medical coding (auto-coding) is enabled for this study in the coding platform. When true, verbatim terms are automatically matched to dictionary terms without manual intervention.',
    `dmp_code` STRING COMMENT 'Externally-known alphanumeric identifier for the DMP, typically formatted as DMP-{StudyCode}-{SequenceNumber}. Used in regulatory submissions, TMF indexing, and cross-system references.. Valid values are `^DMP-[A-Z0-9]{3,20}-[0-9]{3}$`',
    `coding_platform` STRING COMMENT 'Software platform used to perform MedDRA and WHO-DD medical coding for this study as specified in the DMP.. Valid values are `Medidata Rave Coder|Oracle Argus|Relsys|Manual|Other`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this DMP record was first created in the system. Supports audit trail and ALCOA+ compliance requirements.',
    `critical_data_fields_defined` BOOLEAN COMMENT 'Indicates whether the DMP includes a defined list of critical data fields (primary and key secondary endpoints) subject to enhanced data review and 100% SDV requirements.',
    `data_collection_strategy` STRING COMMENT 'Primary strategy for clinical data collection as defined in the DMP. Specifies whether data is collected via eCRF only, eCRF supplemented by external data transfers, paper CRF, or a hybrid approach.. Valid values are `eCRF_only|eCRF_with_external_data|paper_CRF|hybrid`',
    `data_privacy_framework` STRING COMMENT 'Primary data privacy regulatory framework applicable to subject data collected in this study, as identified in the DMP. Determines pseudonymization, data transfer, and retention requirements.. Valid values are `GDPR|HIPAA|GDPR_and_HIPAA|PIPEDA|Other`',
    `data_retention_period_years` BIGINT COMMENT 'Number of years that clinical study data must be retained after study completion or database lock, as mandated by applicable regulations and specified in the DMP.',
    `data_review_plan_summary` STRING COMMENT 'Summary of the data review plan as defined in the DMP, describing the approach for central data review, medical review, and programmatic data checks prior to database lock.',
    `dbl_actual_date` DATE COMMENT 'Actual date on which the database was locked (DBL) for this study. Null until lock is achieved. Compared against target date for KPI reporting.',
    `dbl_criteria` STRING COMMENT 'Narrative description of the criteria that must be satisfied before the database can be locked (DBL), as defined in the DMP. Includes query resolution thresholds, outstanding discrepancy limits, and data review completion requirements.',
    `dbl_target_date` DATE COMMENT 'Planned target date for achieving database lock (DBL) as specified in the DMP. Used for study timeline planning and milestone tracking.',
    `edc_study_environment` STRING COMMENT 'Deployment environment of the EDC system for this study (production, UAT, training). Ensures data management operations reference the correct validated environment.. Valid values are `production|uat|training`',
    `edc_study_name` STRING COMMENT 'Name of the study as configured within the EDC system (e.g., Medidata Rave study name). Used to cross-reference DMP governance with the operational EDC configuration.',
    `edc_system` STRING COMMENT 'Name of the Electronic Data Capture (EDC) system configured for this study as specified in the DMP. Governs which system is the authoritative source for eCRF data collection.. Valid values are `Medidata Rave|Oracle Clinical One|Oracle RDC|Veeva Vault EDC|OpenClinica|Other`',
    `effective_date` DATE COMMENT 'Date on which this version of the Data Management Plan becomes operationally binding for the study. Aligns with the date of final approval signature.',
    `expiry_date` DATE COMMENT 'Date on which this version of the DMP is superseded or retired. Null for the currently active version. Used to manage version history and ensure the correct DMP governs active operations.',
    `external_data_sources` STRING COMMENT 'Comma-separated list or narrative description of external data sources feeding into the study database (e.g., central laboratory, ECG vendor, PK laboratory, ePRO, wearable devices) as specified in the DMP.',
    `external_data_transfer_required` BOOLEAN COMMENT 'Indicates whether the study requires ingestion of external data transfers (e.g., central lab, ECG, PK, imaging) as specified in the DMP. When true, external data transfer specifications must be documented.',
    `meddra_version` STRING COMMENT 'Version of the MedDRA coding dictionary mandated by this DMP for adverse event and medical history coding (e.g., 26.0). Ensures consistent regulatory coding across the study lifecycle.. Valid values are `^[0-9]{1,2}.[0-9]{1}$`',
    `part11_compliance_confirmed` BOOLEAN COMMENT 'Indicates whether the EDC system and data management processes for this study have been confirmed as compliant with FDA 21 CFR Part 11 requirements for electronic records and electronic signatures.',
    `pseudonymization_method` STRING COMMENT 'Method used to pseudonymize subject data in the EDC and downstream datasets as specified in the DMP, ensuring subject identity is protected in compliance with GDPR and HIPAA.. Valid values are `subject_number_only|one_way_hash|tokenization|other`',
    `query_management_convention` STRING COMMENT 'Narrative description of the query management approach defined in the DMP, including rules for raising, routing, escalating, and closing data queries in the EDC system.',
    `sdtm_ig_version` STRING COMMENT 'Version of the CDISC SDTM Implementation Guide (SDTM IG) used for this study (e.g., 3.3, 3.4). Determines the domain structures and controlled terminology applied in SDTM dataset generation.',
    `sdtm_mapping_version` STRING COMMENT 'Version of the CDISC SDTM mapping specification applied to this study as defined in the DMP. Governs the transformation of raw EDC data to SDTM-compliant datasets for regulatory submission.. Valid values are `^[0-9]+.[0-9]+$`',
    `study_phase` STRING COMMENT 'Regulatory phase of the clinical study governed by this DMP (e.g., Phase I, Phase II, Phase III, Phase IV). Determines the complexity and regulatory rigor of data management requirements.. Valid values are `Phase I|Phase II|Phase III|Phase IV|Phase I/II|Phase II/III`',
    `unblinding_procedure_documented` BOOLEAN COMMENT 'Indicates whether the DMP documents the procedure for emergency and planned unblinding of randomization codes, including roles, authorization levels, and audit trail requirements.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this DMP record was last modified in the system. Used for change tracking and audit trail compliance.',
    `validation_check_count` BIGINT COMMENT 'Total number of programmatic data validation checks (edit checks) defined in the EDC system for this study as documented in the DMP. Indicates the scope of automated data quality controls.',
    `version_number` STRING COMMENT 'Version identifier of the Data Management Plan document (e.g., 1.0, 2.1). Incremented upon each approved amendment to the DMP.. Valid values are `^[0-9]+.[0-9]+$`',
    `whodd_version` STRING COMMENT 'Version of the WHO Drug Dictionary (WHO-DD) mandated by this DMP for concomitant medication coding. Ensures standardized drug coding for regulatory submissions.',
    CONSTRAINT pk_dmp PRIMARY KEY(`dmp_id`)
) COMMENT 'Master record for the Data Management Plan (DMP) governing all data management activities for a clinical study. Captures DMP version, effective date, study phase, EDC system configuration, data collection strategy, coding dictionaries and versions';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` (
    `coding_assignment_id` BIGINT COMMENT 'Unique surrogate identifier for each medical coding assignment record in the Silver Layer lakehouse. Primary key for this transactional entity.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.sop. Business justification: Medical coding (MedDRA, WHO Drug) is governed by SOPs. Audit findings cite the coding SOP when coding errors are identified.',
    `discrepancy_query_id` BIGINT COMMENT 'Reference to an active or resolved data query raised against this coding assignment. Populated when the coding status is queried. Supports query management and discrepancy resolution workflows.',
    `ecrf_field_id` BIGINT COMMENT 'Reference to the specific eCRF field (data point) in Medidata Rave from which the verbatim term was collected. Provides traceability back to the source data capture point.',
    `endpoint_id` BIGINT COMMENT 'Foreign key linking to study.endpoint. Business justification: AE/medical coding assignments for primary safety endpoint terms must be traceable to the endpoint definition.',
    `enrollment_id` BIGINT COMMENT 'Foreign key linking to subject.enrollment. Business justification: Medical coding assignments require enrollment context for protocol version, blinding status, and population-specific coding conventions.',
    `field_entry_id` BIGINT COMMENT 'Foreign key linking to datamanagement.field_entry. Business justification: coding_assignment applies medical coding to a verbatim term collected in a specific eCRF field entry. field_entry is the atomic data entry record.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) under which this coding assignment was made. Links the coding record to its parent study context.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: Medical coding assignments may require revision when protocol amendments change the coding dictionary version or AE reporting scope.',
    `subject_visit_data_id` BIGINT COMMENT 'Foreign key linking to datamanagement.subject_visit_data. Business justification: A medical coding assignment is applied to a verbatim term collected in an eCRF at a specific subject visit.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial subject (patient) whose verbatim term is being coded. Enables subject-level safety and coding analytics.',
    `approval_date` DATE COMMENT 'The calendar date on which the coding assignment was formally approved by an authorized reviewer. Used for regulatory submission readiness tracking and coding cycle time analytics.',
    `approval_status` STRING COMMENT 'The regulatory approval state of the coding assignment, distinct from the workflow coding status. Indicates whether the coding has been formally approved by an authorized reviewer for inclusion in regulatory submissions and SDTM datasets.. Valid values are `pending|approved|rejected|superseded`',
    `approval_timestamp` TIMESTAMP COMMENT 'The precise date and time (with timezone) when the coding assignment was approved by an authorized reviewer. Provides granular audit trail for regulatory inspection readiness.',
    `assigned_code` STRING COMMENT 'The standardized dictionary code assigned to the verbatim term. For MedDRA, this is the numeric PT code (e.g., 10047700). For WHO-DD, this is the drug record number. This is the primary coded output used in regulatory submissions and safety analyses.',
    `autocoding_confidence_score` DECIMAL(5,4) COMMENT 'The algorithmic confidence score (0.0000 to 1.0000) returned by the autocoding engine when automatically matching the verbatim term to a dictionary code. Scores below a configured threshold require manual review. Null for manually coded terms.',
    `coding_date` DATE COMMENT 'The calendar date on which the verbatim term was coded (code assigned). Used for coding timeliness metrics, regulatory timelines, and ALCOA+ contemporaneity compliance.',
    `coding_dictionary` STRING COMMENT 'The medical coding dictionary used to assign the standardized code to the verbatim term. MedDRA (Medical Dictionary for Regulatory Activities) is used for adverse events and medical history; WHO-DD (WHO Drug Dictionary) is used for concomitant. Valid values are `MedDRA|WHO-DD|SNOMED-CT|ICD-10|CTCAE`',
    `coding_domain` STRING COMMENT 'The CDISC SDTM domain to which this coding assignment belongs. Determines the regulatory submission context. AE=Adverse Events, CM=Concomitant Medications, MH=Medical History, DS=Disposition, DV=Protocol Deviations, EX=Exposure.. Valid values are `AE|CM|MH|DS|DV|EX`',
    `coding_flag` BOOLEAN COMMENT 'A quality control flag applied to the coding assignment indicating its readiness for database lock (DBL) and regulatory submission. clean = no issues; flagged = requires attention; review_required = pending medical review; locked = included in',
    `coding_method` STRING COMMENT 'The method by which the coding assignment was made. autocoding indicates the EDC system (Medidata Rave) automatically matched the verbatim term; manual indicates a coder manually assigned the code; assisted indicates a system suggestion accepted by. Valid values are `autocoding|manual|assisted|recoded`',
    `coding_status` STRING COMMENT 'Current workflow status of the coding assignment. pending = awaiting coding; coded = code assigned but not yet approved; approved = coding reviewed and approved by authorized coder or supervisor; rejected = coding rejected and requires rework. Valid values are `pending|coded|approved|rejected|queried|recoded`',
    `coding_timestamp` TIMESTAMP COMMENT 'The precise date and time (with timezone) when the coding assignment was created or last modified in the source system. Supports ALCOA+ contemporaneity requirements and audit trail reconstruction.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this coding assignment record was first created in the source system. Supports ALCOA+ audit trail requirements and data lineage tracking in the Silver Layer.',
    `dbl_included` BOOLEAN COMMENT 'Indicates whether this coding assignment was included in the final database lock (DBL) snapshot for regulatory submission. True = included in DBL; False = excluded or post-lock amendment. Critical for submission integrity and audit trail.',
    `dictionary_version` STRING COMMENT 'The specific version of the coding dictionary applied at the time of coding (e.g., MedDRA 26.1, WHO-DD March 2024). Regulatory submissions require explicit dictionary version documentation to ensure reproducibility and consistency.. Valid values are `^[0-9]{1,3}.[0-9]{1,3}$`',
    `field_name` STRING COMMENT 'The specific eCRF field name within the form from which the verbatim term was captured (e.g., AETERM, CMTRT). Enables precise source data traceability per ALCOA+ and SDTM variable mapping.',
    `form_name` STRING COMMENT 'The name of the eCRF form (e.g., Adverse Events, Concomitant Medications) in Medidata Rave from which the verbatim term was collected. Supports data lineage and source data verification (SDV) traceability.',
    `high_level_group_term` STRING COMMENT 'The MedDRA High Level Group Term (HLGT) associated with the assigned Preferred Term. Second-highest level in the MedDRA hierarchy, used for broader safety signal grouping and regulatory tabulations.',
    `high_level_term` STRING COMMENT 'The MedDRA High Level Term (HLT) grouping the assigned Preferred Term. Intermediate level in the MedDRA hierarchy between PT and HLGT, used in aggregate safety analyses and signal detection.',
    `is_primary_soc` BOOLEAN COMMENT 'Indicates whether this coding assignment uses the primary SOC classification for the assigned Preferred Term. MedDRA allows a PT to belong to multiple SOCs; the primary SOC is used for regulatory safety tabulations.',
    `is_serious_ae` BOOLEAN COMMENT 'Indicates whether the verbatim term being coded is associated with a Serious Adverse Event (SAE). True = the source record is an SAE. Drives expedited regulatory reporting timelines (e.g., 7-day/15-day reporting per ICH E2A) and SUSAR assessment workflows.',
    `lowest_level_term` STRING COMMENT 'The MedDRA Lowest Level Term (LLT) that most closely matches the verbatim term. The LLT is the most granular level of the MedDRA hierarchy and is used to capture the precise clinical concept before mapping to the PT.',
    `medical_review_date` DATE COMMENT 'The date on which the medical reviewer completed their review of the coding assignment. Null if medical review is not required or not yet performed for this record.',
    `preferred_term` STRING COMMENT 'The MedDRA Preferred Term (PT) or WHO-DD preferred drug name assigned to the verbatim term. The PT is the primary level of the MedDRA hierarchy used in regulatory safety reporting and aggregate analyses.',
    `prior_assigned_code` STRING COMMENT 'The dictionary code that was previously assigned before a recoding event. Preserved for audit trail purposes to document the history of coding changes per ALCOA+ and 21 CFR Part 11 requirements. Null for initial coding assignments.',
    `prior_preferred_term` STRING COMMENT 'The MedDRA Preferred Term (PT) that was previously assigned before a recoding event. Preserved alongside prior_assigned_code for complete audit trail documentation of coding history changes.',
    `pt_code` STRING COMMENT 'The numeric MedDRA code for the Preferred Term (PT). Used in SDTM datasets (AEPTCD) and regulatory submissions. Distinct from the PT text label to support code-based lookups and dictionary version migrations.. Valid values are `^[0-9]{8}$`',
    `recoding_reason` STRING COMMENT 'Free-text justification provided by the coder when a previously approved coding assignment is revised (recoded). Required for audit trail integrity and regulatory inspection readiness. Null for initial coding assignments.',
    `sdtm_variable` STRING COMMENT 'The CDISC SDTM variable name to which this coding assignment maps (e.g., AEDECOD for AE Preferred Term, AEBODSYS for AE SOC, CMDECOD for CM decoded name). Supports automated SDTM dataset generation and regulatory submission preparation.',
    `soc_code` STRING COMMENT 'The numeric MedDRA code for the System Organ Class (SOC). Used in SDTM datasets (AESOCCD) and regulatory submissions to uniquely identify the SOC category.. Valid values are `^[0-9]{8}$`',
    `system_organ_class` STRING COMMENT 'The MedDRA System Organ Class (SOC) associated with the assigned Preferred Term. The SOC is the highest level of the MedDRA hierarchy and is used for aggregate safety tabulations in clinical study reports and regulatory submissions.',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time when this coding assignment record was last modified in the source system. Supports change detection, incremental ETL processing, and ALCOA+ audit trail requirements.',
    `verbatim_term` STRING COMMENT 'The exact, unmodified text as entered by the investigator or site staff in the eCRF prior to coding. Preserved verbatim per ALCOA+ principles to maintain data integrity and auditability. May contain patient-reported or clinician-reported language.',
    `visit_name` STRING COMMENT 'The name or label of the study visit during which the verbatim term was collected (e.g., Screening, Week 4, End of Treatment). Provides temporal context for the coded term within the study schedule.',
    CONSTRAINT pk_coding_assignment PRIMARY KEY(`coding_assignment_id`)
) COMMENT 'Transactional record of medical coding assignments applied to verbatim terms collected in eCRFs. Captures verbatim term, coding dictionary (MedDRA or WHO-DD), dictionary version, assigned code, preferred term (PT), system organ class (SOC), lowest level';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` (
    `sdtm_dataset_id` BIGINT COMMENT 'Unique surrogate identifier for each SDTM dataset record in the lakehouse silver layer. Primary key for this entity.',
    `define_document_id` BIGINT COMMENT 'Foreign key linking to datamanagement.define_document. Business justification: A Define-XML document governs one or more SDTM datasets in a submission package.',
    `dmp_id` BIGINT COMMENT 'Foreign key linking to datamanagement.dmp. Business justification: sdtm_dataset has dmp_version (STRING) indicating the governing DMP version. dmp is the master DMP record.',
    `lab_panel_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_panel. Business justification: SDTM LB/PC domain datasets are generated from specific lab panels. Data managers building submission datasets must trace which lab panel sourced the data for SDTM compliance review and',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: SDTM datasets are generated per protocol version for regulatory submission packages. FDA/EMA reviewers require dataset-to-protocol traceability.',
    `risk_assessment_id` BIGINT COMMENT 'Foreign key linking to compliance.risk_assessment. Business justification: Risk assessments classify data domains by criticality, directly governing QC intensity applied to SDTM datasets.',
    `sap_id` BIGINT COMMENT 'Foreign key linking to biostatistics.sap. Business justification: SDTM datasets are produced per SAP version; biostatisticians validate SDTM structure against the SAP before ADaM derivation.',
    `sdtm_domain_spec_sdtm_dataset_id` BIGINT COMMENT 'Foreign key linking to datamanagement.sdtm_domain_spec. Business justification: An SDTM dataset is an instantiation of an SDTM domain specification. sdtm_domain_spec defines the structural contract (domain_code, label, define_document linkage) while',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this SDTM dataset was generated. Links the dataset to its parent study protocol.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: Protocol amendments may require SDTM dataset regeneration (new domains, changed variables).',
    `submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission. Business justification: SDTM datasets are packaged as primary data deliverables for regulatory submissions (NDA/BLA/MAA).',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: SDTM datasets are essential TMF documents filed for regulatory inspection readiness (DIA Reference Model Zone 11).',
    `analysis_population` STRING COMMENT 'Clinical analysis population represented in this dataset where applicable (e.g., Intent-to-Treat (ITT), Per Protocol (PP), Safety Population, Full Analysis Set). Relevant for ADaM-linked SDTM datasets.',
    `controlled_terminology_version` STRING COMMENT 'Version of the CDISC Controlled Terminology package applied during dataset generation (e.g., 2023-09-29). Ensures consistent use of standardized code lists across the submission package.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this SDTM dataset record was first created in the system. Supports ALCOA+ audit trail and 21 CFR Part 11 electronic record requirements.',
    `data_cut_date` DATE COMMENT 'The clinical data cut-off date used for this dataset, representing the last date of data included in the analysis. May differ from the database lock date for interim analyses or rolling submissions.',
    `dataset_label` STRING COMMENT 'Full human-readable label for the SDTM dataset as it appears in the define.xml and submission package (e.g., Adverse Events, Concomitant Medications, Demographics). Must not exceed 40 characters per SAS transport file constraints.',
    `dataset_name` STRING COMMENT 'Two- to four-character CDISC SDTM domain abbreviation identifying the dataset (e.g., AE for Adverse Events, CM for Concomitant Medications, DM for Demographics, LB for Laboratory, VS for Vital Signs, EX for Exposure).. Valid values are `^[A-Z]{2,4}$`',
    `dataset_status` STRING COMMENT 'Current lifecycle status of the SDTM dataset within the data management and submission workflow. Progresses from Draft through QC Complete, Frozen, Locked, and Submitted. Superseded indicates a prior version replaced by a newer submission.',
    `dbl_date` DATE COMMENT 'Date on which the clinical database was locked prior to SDTM dataset generation. Establishes the data cut-off point for the submission dataset and is a critical regulatory milestone.',
    `define_xml_version` STRING COMMENT 'Version of the CDISC define.xml metadata standard used to describe this dataset within the submission package (e.g., 2.0, 2.1). The define.xml is a mandatory component of FDA and EMA electronic submissions.. Valid values are `2.0|2.1`',
    `domain_class` STRING COMMENT 'CDISC SDTM observation class to which this dataset belongs. Classifies the dataset into one of the standard SDTM domain classes: Events (e.g., AE, DS), Interventions (e.g., CM, EX), Findings (e.g., LB, VS, EG), Special Purpose (e.g., DM, CO), Relationship. Valid values are `Events|Interventions|Findings|Special Purpose|Relationship|Trial Design`',
    `domain_code` STRING COMMENT 'SDTM domain code (e.g. AE, DM, VS).',
    `generation_date` DATE COMMENT 'Calendar date on which this SDTM dataset was generated from source EDC data. Used for audit trail and submission package dating per ALCOA+ contemporaneous principle.',
    `generation_timestamp` TIMESTAMP COMMENT 'Precise date and time at which the SDTM dataset was generated, including timezone offset. Supports ALCOA+ contemporaneous documentation and 21 CFR Part 11 audit trail requirements.',
    `is_split_dataset` BOOLEAN COMMENT 'Indicates whether this dataset has been split into multiple physical files due to size constraints (e.g., LB domain split by lab panel). True = dataset is one part of a split; False = single complete dataset file.',
    `is_submission_ready` BOOLEAN COMMENT 'Indicates whether this SDTM dataset has passed all QC checks, Pinnacle 21 validation, and internal review gates and is approved for inclusion in a regulatory submission package. True = ready for submission; False = not yet approved.',
    `label` STRING COMMENT 'SDTM domain label.',
    `notes` STRING COMMENT 'Free-text field for capturing dataset-specific annotations, known issues, deviation justifications, or reviewer instructions that do not fit into structured fields. Supports ALCOA+ documentation completeness.',
    `pinnacle21_error_count` BIGINT COMMENT 'Number of errors (severity: Error) identified during the Pinnacle 21 validation run. Errors must be resolved or formally justified before regulatory submission.',
    `pinnacle21_run_date` DATE COMMENT 'Date on which the most recent Pinnacle 21 validation was executed against this dataset. Supports audit trail and ensures validation currency relative to dataset generation.',
    `pinnacle21_validation_status` STRING COMMENT 'Outcome of the Pinnacle 21 Community or Enterprise conformance validation run against this SDTM dataset. Regulatory agencies (FDA, PMDA) require Pinnacle 21 validation reports as part of the submission package.. Valid values are `Pass|Pass with Warnings|Fail|Not Run`',
    `pinnacle21_warning_count` BIGINT COMMENT 'Number of warnings identified during the Pinnacle 21 validation run. Warnings require documented justification in the Reviewers Guide or ADRG if not resolved.',
    `qc_completion_date` DATE COMMENT 'Date on which the QC review of this SDTM dataset was completed and signed off. Required for audit trail documentation per ALCOA+ and 21 CFR Part 11.',
    `qc_status` STRING COMMENT 'Current quality control review status for this SDTM dataset. Tracks progression through the double-programming or independent QC review process required before regulatory submission.. Valid values are `Not Started|In Progress|QC Pass|QC Fail|Waived`',
    `record_count` BIGINT COMMENT 'Total number of observation records contained in this SDTM dataset at the time of generation or last update. Used for reconciliation, QC verification, and submission package validation.',
    `reviewer_guide_reference` STRING COMMENT 'File path or document reference to the Analysis Data Reviewers Guide (ADRG) or Study Data Reviewers Guide (SDRG) section that documents dataset-specific conventions, deviations, and reviewer instructions for this SDTM domain.',
    `sas_dataset_path` STRING COMMENT 'File system path or storage location of the SAS transport file (XPT format) for this SDTM dataset. FDA requires submission datasets in SAS Version 5 transport format (.xpt).',
    `sdtm_ig_version` STRING COMMENT 'Version of the CDISC SDTM Implementation Guide used to generate this dataset (e.g., 3.3, 3.4). Critical for regulatory submission conformance validation and Pinnacle 21 checks.. Valid values are `^d+.d+(.d+)?$`',
    `split_sequence` BIGINT COMMENT 'Sequential number identifying the order of this file within a split dataset series (e.g., 1 for LB1, 2 for LB2). Null when is_split_dataset is False.',
    `sponsor_dataset_name` STRING COMMENT 'Sponsor-specific internal name or alias for this dataset, which may differ from the standard CDISC domain abbreviation in cases of custom or extended domains. Used for internal tracking and sponsor communication.',
    `subject_count` BIGINT COMMENT 'Number of unique study subjects (USUBJID) represented in this SDTM dataset. Supports population-level QC checks and reconciliation against the DM domain.',
    `submission_version` STRING COMMENT 'Version identifier for the regulatory submission package in which this dataset is included (e.g., v1.0, v2.1). Tracks dataset evolution across multiple submission cycles for the same study.',
    `suppqual_included` BOOLEAN COMMENT 'Indicates whether a supplemental qualifier dataset (SUPP--) accompanies this SDTM domain dataset to capture non-standard variables. True = a corresponding SUPP-- dataset exists; False = no supplemental dataset.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this SDTM dataset record. Supports change tracking, audit trail, and ALCOA+ contemporaneous documentation requirements.',
    `variable_count` BIGINT COMMENT 'Total number of variables (columns) in this SDTM dataset. Used for define.xml completeness verification and to ensure compliance with CDISC domain variable requirements.',
    `xpt_file_size_kb` DECIMAL(18,3) COMMENT 'Size of the SAS transport (.xpt) file in kilobytes. Used for submission package size management and to flag datasets approaching the 5GB FDA file size limit.',
    CONSTRAINT pk_sdtm_dataset PRIMARY KEY(`sdtm_dataset_id`)
) COMMENT 'Master record for CDISC SDTM (Study Data Tabulation Model) dataset definitions and their submission-ready outputs. Captures dataset name (e.g., AE, CM, DM, LB, VS), SDTM domain class (Events, Interventions, Findings), SDTM IG version, study identifier';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` (
    `sdtm_mapping_id` BIGINT COMMENT 'Unique surrogate identifier for a single source-to-target SDTM variable mapping rule record within the Clinical Trials data management system. Entity role: TRANSACTION_LINE — this record represents one variable-level mapping line within a parent SDTM',
    `bioanalytical_assay_id` BIGINT COMMENT 'Foreign key linking to laboratory.bioanalytical_assay. Business justification: SDTM PC domain mapping rules for PK concentration variables are assay-specific (analyte name, units, LLOQ derivation).',
    `codelist_id` BIGINT COMMENT 'Target SDTM variable specification this mapping produces (replaces free-text variable definition).',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.sop. Business justification: SDTM mapping activities are governed by SOPs (e.g., SOP for SDTM mapping, define.xml authoring). Regulatory submissions require SOP traceability for mapping decisions.',
    `endpoint_id` BIGINT COMMENT 'Foreign key linking to study.endpoint. Business justification: SDTM mappings for endpoint variables must be traceable to the endpoint definition for submission package completeness review.',
    `primary_sdtm_dataset_id` BIGINT COMMENT 'Reference to the parent SDTM dataset specification record that owns this mapping rule. Establishes the header/detail relationship between the dataset-level specification and this individual variable mapping line.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: SDTM mapping specifications are authored against a specific protocol version. Protocol amendments that change endpoints or visit schedules require mapping spec updates; direct protocol_id',
    `reference_range_id` BIGINT COMMENT 'Foreign key linking to laboratory.reference_range. Business justification: SDTM LB domain mapping rules for normal range variables (LBORNRLO, LBORNRHI, LBNRIND) must reference the applicable reference range definition.',
    `sap_id` BIGINT COMMENT 'Foreign key linking to biostatistics.the source system. Business justification: SDTM mapping specifications are governed by the the source system, which defines required SDTM domains, variables, and submission versions.',
    `source_ecrf_field_id` BIGINT COMMENT 'Foreign key linking to datamanagement.ecrf_field. Business justification: sdtm_mapping defines transformation rules from raw EDC eCRF fields to SDTM variables. source_field_name and source_field_label are denormalized references to the source eCRF field.',
    `source_ecrf_form_id` BIGINT COMMENT 'Foreign key linking to datamanagement.ecrf_form. Business justification: sdtm_mapping defines transformation rules from raw EDC eCRF fields to SDTM variables. source_form_name is a denormalized reference to the source eCRF form.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this SDTM mapping rule is defined. Enables study-scoped filtering and traceability of all mapping specifications back to the originating protocol.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: Protocol amendments that change data collection requirements trigger SDTM mapping specification updates.',
    `approved_timestamp` TIMESTAMP COMMENT 'Date and time when this mapping rule was formally approved and promoted to approved status by the authorized reviewer. Represents the principal business event timestamp for this mapping lifecycle transition.',
    `change_reason` STRING COMMENT 'Free-text justification for the most recent change to this mapping rule (e.g., Protocol Amendment 3 — new AE severity scale, Corrected derivation logic per QC review). Required when mapping_status transitions or derivation_algorithm is modified.',
    `coding_dictionary` STRING COMMENT 'Medical coding dictionary used for this mapping when derivation_type is coded. MedDRA (Medical Dictionary for Regulatory Activities) for adverse events and medical history; WHO-DD (WHO Drug Dictionary) for concomitant medications; CTCAE (Common. Valid values are `MedDRA|WHO-DD|CTCAE|SNOMED-CT|ICD-10|none`',
    `coding_dictionary_version` STRING COMMENT 'Version of the medical coding dictionary applied for this mapping (e.g., MedDRA v26.1, WHO-DD March 2023). Ensures reproducibility of coded terms across transformation runs and supports regulatory submission traceability.',
    `controlled_terminology_codelist` STRING COMMENT 'Name of the CDISC Controlled Terminology code list applied to this SDTM variable (e.g., AESEV, NCOMPLT, SEX, RACE). Null if no controlled terminology applies. Governs permissible values for the target variable in regulatory submissions.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this SDTM mapping rule record was first created in the system. Supports ALCOA+ audit trail requirements and 21 CFR Part 11 electronic records compliance. Immutable after initial record creation.',
    `ct_version` STRING COMMENT 'Version of the CDISC Controlled Terminology package applied for this mapping (e.g., 2023-09-29). Ensures reproducibility of coded values across transformation runs and regulatory submissions. Critical for FDA/EMA submission compliance.',
    `define_xml_comment` STRING COMMENT 'Supplementary comment text to be included in the CDISC Define-XML v2.1 submission package for this variable. Provides additional context for FDA/EMA reviewers about the derivation logic, data source, or special handling.',
    `define_xml_origin` STRING COMMENT 'Origin attribute value for this variable as it will appear in the CDISC Define-XML v2.1 submission metadata. Indicates the source of the data: CRF (collected on eCRF), Derived (algorithmically derived), Assigned (assigned by sponsor/CRO), Protocol. Valid values are `CRF|Derived|Assigned|Protocol|eDT|Predecessor`',
    `derivation_algorithm` STRING COMMENT 'Full specification of the transformation logic or derivation rule applied to produce the target SDTM variable value from the source field(s). Includes SAS code snippets, conditional logic, date calculations, concatenation rules, and multi-source merge',
    `derivation_type` STRING COMMENT 'Classification of the mapping derivation method: direct (verbatim copy from source), derived (computed from one or more source fields), assigned (constant or protocol-defined value), predecessor (derived from a previously mapped SDTM variable). Valid values are `direct|derived|assigned|predecessor|computed|coded`',
    `effective_end_date` DATE COMMENT 'Date after which this version of the mapping rule is no longer active and has been superseded or deprecated. Null for currently active mapping rules. Supports temporal versioning of mapping specifications across protocol amendments.',
    `effective_start_date` DATE COMMENT 'Date from which this version of the mapping rule is effective and applicable to SDTM transformation runs. Supports version-controlled mapping specifications where different versions apply to different data collection periods or protocol amendments.',
    `is_multi_source` BOOLEAN COMMENT 'Indicates whether this SDTM variable mapping requires data from more than one source field or form (True) or derives from a single source field (False). When True, the derivation_algorithm field documents all contributing source fields and the combination',
    `is_predecessor_required` BOOLEAN COMMENT 'Indicates whether the predecessor variable dependency documented in predecessor_variable is a hard requirement (True) that must be resolved before this mapping executes, or an informational dependency (False).',
    `is_sensitive_variable` BOOLEAN COMMENT 'Indicates whether the target SDTM variable contains sensitive subject data requiring special handling under GDPR, HIPAA, or sponsor data privacy agreements (True). Examples include subject identifiers, dates of birth, and geographic data.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time when this SDTM mapping rule record was most recently updated. Updated on every change to the mapping rule, derivation logic, or status. Supports change tracking and ALCOA+ audit trail requirements.',
    `mapping_rule_code` STRING COMMENT 'Externally-known, human-readable unique code identifying this mapping rule within the studys SDTM mapping specification document. Follows the pattern MAP-{DOMAIN}-{VARIABLE}-{SEQUENCE}. Used in Data Management Plans (DMP) and CDISC submission packages.. Valid values are `^MAP-[A-Z]{2,8}-[A-Z0-9]{2,10}-[0-9]{4}$`',
    `mapping_status` STRING COMMENT 'Current lifecycle state of this SDTM mapping rule. Controls which version is active for production CDISC transformation runs. approved rules are eligible for DBL and regulatory submission.. Valid values are `draft|in_review|approved|deprecated|superseded|on_hold`',
    `mapping_version` STRING COMMENT 'Version number of this mapping rule in major.minor format (e.g., 1.0, 2.3). Incremented when the transformation logic, source field, or controlled terminology mapping changes.. Valid values are `^[0-9]+.[0-9]+$`',
    `notes` STRING COMMENT 'Free-text field for additional programmer or reviewer notes about this mapping rule, including special handling instructions, known data quality issues, sponsor-specific requirements, or cross-references to related mapping rules.',
    `predecessor_variable` STRING COMMENT 'Name of the SDTM variable (within the same or a different domain) that must be derived before this mapping can be executed. Documents derivation dependencies for sequencing transformation programs. Format: {DOMAIN}.{VARIABLE} (e.g., AE.AEDECOD).',
    `reviewer_name` STRING COMMENT 'Name or employee identifier of the Data Management or Biostatistics reviewer who reviewed and approved this mapping rule. Supports dual-review traceability and ALCOA+ compliance for the SDTM mapping specification document.',
    `sdtm_domain` STRING COMMENT 'Two-letter CDISC SDTM domain code identifying the target dataset domain (e.g., DM, AE, LB, VS, CM, EX, MH, DS, SV, TU). Determines the SDTM class and required/expected variable set for this mapping.',
    `sdtm_ig_version` STRING COMMENT 'Version of the CDISC SDTM Implementation Guide that governs this mapping rule (e.g., SDTMIG v3.4, SDTMIG-AP v1.0). Ensures regulatory submission compliance with the correct CDISC standard version as required by FDA and EMA data submission guidelines.',
    `sdtm_variable_core` STRING COMMENT 'CDISC core designation indicating whether the target SDTM variable is Required (Req), Expected (Exp), or Permissible (Perm) for the domain. Required variables must be populated; Expected variables should be populated when data is collected; Permissible. Valid values are `Req|Exp|Perm`',
    `sdtm_variable_label` STRING COMMENT 'Human-readable descriptive label for the target SDTM variable as defined in the CDISC SDTM Implementation Guide (e.g., Dictionary-Derived Term, Numeric Result/Finding in Standard Units).',
    `sdtm_variable_name` STRING COMMENT 'Name of the target CDISC SDTM variable within the specified domain (e.g., AEDECOD, LBSTRESN, VSORRES). Must conform to CDISC SDTM naming conventions: uppercase, 2–8 characters, domain prefix for most variables.. Valid values are `^[A-Z]{2,8}$`',
    `sdtm_variable_role` STRING COMMENT 'CDISC-defined role of the target SDTM variable within its domain class (Identifier, Topic, Qualifier, Timing, Rule). Determines how the variable functions within the SDTM dataset structure and governs its position and usage in regulatory submissions.. Valid values are `Identifier|Topic|Qualifier|Timing|Rule`',
    `sdtm_variable_type` STRING COMMENT 'CDISC-defined data type of the target SDTM variable. Char for character/text variables and Num for numeric variables, as specified in the SDTM Implementation Guide and define.xml metadata. Governs SAS dataset column type in regulatory submissions.. Valid values are `Char|Num`',
    `sequence_number` BIGINT COMMENT 'Ordinal sequence number of this mapping rule within the parent SDTM dataset specification. Governs the order in which variables appear in the SDTM dataset and define.xml, and the execution order of transformation programs in SAS Drug Development.',
    `source_dataset_name` STRING COMMENT 'Name of the raw/staging dataset (SAS dataset or EDC extract table) that contains the source field prior to SDTM transformation (e.g., RAW_AE, RAW_VS). Used in SAS Drug Development transformation programs to identify the input dataset for each mapping',
    `suppqual_flag` BOOLEAN COMMENT 'Indicates whether this variable is mapped to a CDISC SDTM Supplemental Qualifier (SUPP--) dataset rather than the parent domain dataset (True). SUPPQUAL datasets hold non-standard variables that cannot be accommodated in the standard domain structure.',
    `suppqual_qnam` STRING COMMENT 'Short variable name (QNAM) used in the SUPPQUAL dataset for this non-standard variable. Populated only when suppqual_flag is True. Must be uppercase, 1–8 characters, and unique within the SUPPQUAL dataset for the domain.. Valid values are `^[A-Z]{1,8}$`',
    `validation_error_code` STRING COMMENT 'Pinnacle 21 / CDISC conformance rule error or warning code associated with the most recent validation failure for this mapping (e.g., SD0083, SD0006). Null when validation_status is passed or not_validated.',
    `validation_status` STRING COMMENT 'Current status of the CDISC Pinnacle 21 / OpenCDISC validation check result for this mapping rule. passed indicates no conformance errors; failed indicates outstanding validation errors requiring remediation before DBL; waived indicates a documented. Valid values are `not_validated|in_validation|passed|failed|waived`',
    CONSTRAINT pk_sdtm_mapping PRIMARY KEY(`sdtm_mapping_id`)
) COMMENT 'Detail-level record defining a single source-to-target transformation rule between a raw EDC eCRF field and a CDISC SDTM variable within a parent sdtm_dataset.';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` (
    `reconciliation_id` BIGINT COMMENT 'Unique surrogate identifier for each reconciliation activity record in the data management domain. Primary key for the reconciliation data product.',
    `accountability_reconciliation_id` BIGINT COMMENT 'Foreign key linking to supply.accountability_reconciliation. Business justification: Data managers reconcile EDC dispensing entries against IMP accountability records as a named GCP process.',
    `audit_finding_id` BIGINT COMMENT 'Foreign key linking to compliance.audit_finding. Business justification: Reconciliation activities (drug accountability, external data, lab data) are reviewed during GCP audits and can generate audit findings.',
    `consent_subject_consent_id` BIGINT COMMENT 'Foreign key linking to consent.subject_consent. Business justification: Consent status reconciliation is a named operational process: verifying that subject consent status in the EDC matches the consent management platform.',
    `database_lock_event_id` BIGINT COMMENT 'Foreign key linking to biostatistics.database_lock_event. Business justification: Reconciliations (SAE, lab, external data) are performed as mandatory pre-lock activities for a specific database lock event.',
    `destruction_record_id` BIGINT COMMENT 'Foreign key linking to supply.destruction_record. Business justification: GCP-mandated IMP accountability reconciliation requires reconciling dispensed quantities against returned AND destroyed quantities.',
    `dispensing_record_id` BIGINT COMMENT 'Foreign key linking to supply.dispensing_record. Business justification: Reconciliation activities are performed between EDC data and external data sources. The external_transfer product captures those external data transfers.',
    `dmp_id` BIGINT COMMENT 'Foreign key linking to datamanagement.dmp. Business justification: reconciliation has dmp_reference (STRING) indicating the governing Data Management Plan. dmp is the master DMP record.',
    `document_sop_id` BIGINT COMMENT 'Foreign key linking to document.document_sop. Business justification: Data reconciliation activities are governed by a Data Reconciliation SOP. GCP compliance requires that reconciliation procedures follow an approved SOP.',
    `ehr_data_transfer_id` BIGINT COMMENT 'Foreign key linking to datamanagement.ehr_data_transfer. Business justification: A reconciliation activity can be performed specifically against an EHR data transfer batch — comparing the data received in the transfer against what was entered in the EDC.',
    `lab_facility_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_facility. Business justification: EDC-to-LIMS data reconciliation is a named ICH E6 R2 process requiring identification of the specific lab facility whose LIMS is being reconciled against EDC.',
    `protocol_deviation_id` BIGINT COMMENT 'Foreign key linking to compliance.protocol_deviation. Business justification: Drug accountability reconciliation discrepancies (wrong tablet count, incorrect dispensing) constitute protocol deviations requiring formal regulatory reporting.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Reconciliation activities (external data source, lab, supply) are scoped to a protocol version.',
    `return_record_id` BIGINT COMMENT 'Foreign key linking to supply.return_record. Business justification: IMP accountability reconciliation (ICH E6 GCP requirement) must close the loop across dispensed, returned, and destroyed quantities.',
    `shipment_id` BIGINT COMMENT 'Foreign key linking to supply.shipment. Business justification: Data reconciliation exercises include reconciling EDC-entered shipment receipt data against shipment manifests.',
    `specimen_shipment_id` BIGINT COMMENT 'Foreign key linking to laboratory.specimen_shipment. Business justification: Specimen shipment reconciliation (verifying specimens shipped from site match specimens received and accessioned at lab) is a distinct named reconciliation type.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this reconciliation activity is performed. Links the reconciliation record to the parent study protocol.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: Protocol amendments may change reconciliation scope (new external data sources, changed visit schedules).',
    `study_site_id` BIGINT COMMENT 'Reference to the clinical site when the reconciliation is scoped to a specific investigational site. Null when reconciliation covers the full study or multiple sites.',
    `subject_randomization_id` BIGINT COMMENT 'Foreign key linking to randomization.subject_randomization. Business justification: Subject-level IRT-EDC reconciliation compares the IRT randomization record against EDC-captured data for each subject.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Data reconciliation reports (lab, external data, DBL) are TMF essential documents filed in the eTMF (DIA TMF Zone 2). Inspectors verify their presence.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the clinical trial subject when the reconciliation is scoped to an individual subject. Null when reconciliation covers site-level or study-level data.',
    `workflow_id` BIGINT COMMENT 'Foreign key linking to document.workflow. Business justification: Reconciliation sign-off is a formal document workflow process (review, approval, signoff by authorized roles).',
    `capa_reference` STRING COMMENT 'Reference identifier for any Corrective and Preventive Action (CAPA) initiated as a result of systemic discrepancies identified during this reconciliation. Links to the CAPA management system (MasterControl).',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this reconciliation record was first created in the system. Supports ALCOA+ audit trail requirements and data lineage tracking.',
    `critical_discrepancy_count` BIGINT COMMENT 'Number of discrepancies classified as critical (e.g., safety-impacting, primary endpoint data, regulatory submission data). Critical discrepancies require mandatory resolution before DBL.',
    `dataset_name` STRING COMMENT 'Name of the specific CDISC SDTM domain or dataset (e.g., AE, LB, CM, VS) being reconciled. Provides dataset-level traceability for SDTM submission readiness.',
    `dbl_required` BOOLEAN COMMENT 'Indicates whether this reconciliation is a mandatory prerequisite for Database Lock (DBL). When True, outstanding discrepancies must be resolved or formally waived before DBL can proceed.',
    `discrepancy_count` BIGINT COMMENT 'Total number of data discrepancies identified between the source and target systems during this reconciliation exercise. Includes all open, resolved, and outstanding discrepancies.',
    `discrepancy_rate_pct` DECIMAL(5,2) COMMENT 'Percentage of records with at least one discrepancy relative to total records compared (discrepancy_count / total_records_compared * 100). Key quality KPI for data management performance reporting and study risk assessment.',
    `escalation_notes` STRING COMMENT 'Free-text description of the reason for escalation, including the nature of critical discrepancies, impacted data domains, and recommended corrective actions. Populated only when escalation_required is True.',
    `escalation_required` BOOLEAN COMMENT 'Indicates whether the reconciliation outcome requires escalation to the study team, sponsor, or Data Safety Monitoring Board (DSMB) due to critical unresolved discrepancies or systemic data quality issues.',
    `frequency` STRING COMMENT 'Cadence at which this type of reconciliation is performed for the study, as defined in the DMP. Drives scheduling and resource planning for data management activities.. Valid values are `ad_hoc|weekly|monthly|quarterly|pre_dbl|milestone_based`',
    `method` STRING COMMENT 'Approach used to perform the reconciliation — fully manual review, automated system comparison, or a hybrid semi-automated process. Informs quality risk assessment and resource planning.. Valid values are `manual|automated|semi_automated`',
    `notes` STRING COMMENT 'Free-text field for data manager comments, observations, or contextual information about the reconciliation activity, including any known data transfer delays, system outages, or protocol amendments affecting the comparison.',
    `number` STRING COMMENT 'Externally-known, human-readable business identifier for the reconciliation activity, used in Data Management Plans (DMP), audit trails, and cross-system references. Typically formatted as REC-{StudyCode}-{Sequence}.. Valid values are `^REC-[A-Z0-9]{3,10}-[0-9]{4,8}$`',
    `outstanding_count` BIGINT COMMENT 'Number of discrepancies that remain unresolved at the time of the reconciliation record. A non-zero value blocks DBL (Database Lock) unless formally justified and documented.',
    `period_end` DATE COMMENT 'End date of the data window covered by this reconciliation activity. Defines the upper bound of the data extract or comparison period.',
    `period_start` DATE COMMENT 'Start date of the data window covered by this reconciliation activity. Defines the lower bound of the data extract or comparison period.',
    `planned_reconciliation_date` DATE COMMENT 'Scheduled date for the reconciliation activity as defined in the Data Management Plan (DMP) or study timeline. Enables variance tracking between planned and actual reconciliation dates.',
    `reconciliation_date` DATE COMMENT 'The calendar date on which the reconciliation activity was formally executed. Principal business event date used for scheduling, DMP milestone tracking, and pre-DBL (Database Lock) compliance verification.',
    `reconciliation_status` STRING COMMENT 'Current lifecycle state of the reconciliation activity, from initiation through sign-off. Drives workflow progression and DBL (Database Lock) readiness gates.. Valid values are `pending|in_progress|completed|signed_off|failed|cancelled`',
    `reconciliation_type` STRING COMMENT 'Classification of the reconciliation activity by the category of external data source being reconciled against the EDC (Electronic Data Capture) system. Drives workflow routing and DMP compliance checks.. Valid values are `central_lab|safety_database|irt_rtsm|epro|external_vendor|edc_internal`',
    `resolved_count` BIGINT COMMENT 'Number of discrepancies that have been investigated and resolved (closed) as of the reconciliation sign-off date. Used to assess reconciliation completeness.',
    `scope` STRING COMMENT 'Granularity level at which the reconciliation is performed — whether it covers the full study, a specific site, individual subjects, a visit window, or a specific dataset. Determines the breadth of the reconciliation exercise.. Valid values are `full_study|site_level|subject_level|visit_level|dataset_level`',
    `signoff_by` STRING COMMENT 'Name or user identifier of the individual who formally approved and signed off the reconciliation activity. Supports electronic signature audit trail per 21 CFR Part 11.',
    `signoff_status` STRING COMMENT 'Formal approval status of the reconciliation activity by the responsible data manager and/or study team. Approved sign-off is required before the reconciliation can be considered complete for DBL purposes.. Valid values are `not_started|pending_review|approved|rejected`',
    `signoff_timestamp` TIMESTAMP COMMENT 'Date and time at which the reconciliation was formally signed off. Provides the precise audit timestamp for regulatory inspection readiness per 21 CFR Part 11.',
    `source_data_extract_timestamp` TIMESTAMP COMMENT 'Date and time at which the data extract was pulled from the source system for reconciliation purposes. Critical for ALCOA+ contemporaneity and audit trail integrity.',
    `target_data_extract_timestamp` TIMESTAMP COMMENT 'Date and time at which the data extract was pulled from the target system for reconciliation comparison. Paired with source_data_extract_timestamp to establish the comparison window.',
    `target_system` STRING COMMENT 'Name of the receiving or comparison operational system against which source data is reconciled (e.g., Medidata Rave EDC, the source system SAS Drug Development). Identifies the system-of-record on the receiving side.',
    `tool` STRING COMMENT 'Name of the software tool or system used to perform the reconciliation (e.g., Medidata Rave, SAS macro, custom script, the source system Supports audit trail and reproducibility documentation.',
    `total_records_compared` BIGINT COMMENT 'Total count of data records (e.g., subject visits, lab results, AE entries) included in the reconciliation comparison between source and target systems. Denominator for discrepancy rate calculations.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this reconciliation record was last modified. Supports change tracking, audit trail integrity, and Silver Layer incremental load processing.',
    `version` BIGINT COMMENT 'Version number of the reconciliation activity, incremented when a reconciliation is re-executed (e.g., after additional data is received or discrepancies are resolved). Supports iterative reconciliation tracking.',
    `waived_count` BIGINT COMMENT 'Number of discrepancies formally waived with documented justification (e.g., clinically insignificant, data not required for analysis). Supports transparent DBL decision-making.',
    CONSTRAINT pk_reconciliation PRIMARY KEY(`reconciliation_id`)
) COMMENT 'Transactional record of reconciliation activities performed between EDC data and external data sources (central lab, safety database, IRT/RTSM, ePRO). Captures reconciliation type, source system, target system, reconciliation date, discrepancy count';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`datamanagement`.`codelist_term` (
    `codelist_term_id` BIGINT COMMENT 'Unique identifier for the codelist term record in the codelist_term entity.',
    `codelist_id` BIGINT COMMENT 'the codelist the term belongs to',
    `decoded_value` STRING COMMENT 'human-readable decode shown to reviewers',
    `definition` STRING COMMENT 'CDISC definition of the term',
    `nci_concept_code` STRING COMMENT 'NCI Thesaurus C-code, e.g. C20197',
    `preferred_term` STRING COMMENT 'NCI preferred term, e.g. Male',
    `submission_value` STRING COMMENT 'CDISC submission value used in SDTM/ADaM, e.g. M, F or HISPANIC OR LATINO',
    `synonyms` STRING COMMENT 'CDISC synonyms separated by semicolons',
    CONSTRAINT pk_codelist_term PRIMARY KEY(`codelist_term_id`)
) COMMENT 'One row per term of a CDISC codelist (Controlled Terminology).';

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`codelist_term` ADD CONSTRAINT `fk_datamanagement_codelist_term_codelist_id` FOREIGN KEY (`codelist_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`codelist`(`codelist_id`);

ALTER SCHEMA `clinical_trials_mvm`.`datamanagement` SET TAGS ('dbx_division' = 'operations');

ALTER SCHEMA `clinical_trials_mvm`.`datamanagement` SET TAGS ('dbx_domain' = 'datamanagement');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`codelist_term` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`codelist_term` SET TAGS ('dbx_domain' = 'datamanagement');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`codelist_term` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`codelist_term` SET TAGS ('dbx_subdomain' = 'capture_operations');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`codelist_term` ALTER COLUMN `codelist_term_id` SET TAGS ('dbx_is_primary_key' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ADD CONSTRAINT `fk_datamanagement_ecrf_field_codelist_id` FOREIGN KEY (`codelist_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`codelist`(`codelist_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ADD CONSTRAINT `fk_datamanagement_ecrf_field_ecrf_form_id` FOREIGN KEY (`ecrf_form_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`ecrf_form`(`ecrf_form_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` SET TAGS ('dbx_domain' = 'datamanagement');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` SET TAGS ('dbx_subdomain' = 'capture_operations');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `ecrf_field_id` SET TAGS ('dbx_business_glossary_term' = 'Electronic Case Report Form (eCRF) Field ID');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `codelist_id` SET TAGS ('dbx_business_glossary_term' = 'Codelist Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `ecrf_form_id` SET TAGS ('dbx_business_glossary_term' = 'Electronic Case Report Form (eCRF) Form ID');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `endpoint_id` SET TAGS ('dbx_business_glossary_term' = 'Endpoint Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `imp_master_id` SET TAGS ('dbx_business_glossary_term' = 'Imp Master Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `lab_panel_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Analyte Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study ID');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `alcoa_attribute` SET TAGS ('dbx_business_glossary_term' = 'ALCOA+ Data Integrity Attribute');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `cdash_variable` SET TAGS ('dbx_business_glossary_term' = 'Clinical Data Acquisition Standards Harmonization (CDASH) Variable Name');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `cdash_variable` SET TAGS ('dbx_value_regex' = '^[A-Z][A-Z0-9]{1,7}$');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `cdash_variable` SET TAGS ('dbx_implements' = 'CDASH variable name');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `cdash_variable` SET TAGS ('dbx_standard' = 'CDASH');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `cdashig_version` SET TAGS ('dbx_standard' = 'CDASH');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `cdashig_version` SET TAGS ('dbx_element' = 'CDASHIG.version');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `codelist_oid` SET TAGS ('dbx_business_glossary_term' = 'Controlled Terminology Codelist OID');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `coding_dictionary` SET TAGS ('dbx_business_glossary_term' = 'Medical Coding Dictionary');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `coding_dictionary` SET TAGS ('dbx_value_regex' = 'MedDRA|WHO-DD|CTCAE|ICD-10|SNOMED-CT|none');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `coding_dictionary` SET TAGS ('dbx_licensed_dictionary' = 'structure_only; dictionary_licensed_by_customer; model_defines_structure_only');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `coding_dictionary_version` SET TAGS ('dbx_business_glossary_term' = 'Medical Coding Dictionary Version');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `coding_dictionary_version` SET TAGS ('dbx_licensed_dictionary' = 'structure_only; dictionary_licensed_by_customer; model_defines_structure_only');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Field Definition Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `default_value` SET TAGS ('dbx_business_glossary_term' = 'eCRF Field Default Value');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Field Definition Effective End Date');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Field Definition Effective Start Date');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `field_data_type` SET TAGS ('dbx_business_glossary_term' = 'eCRF Field Data Type');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `field_label` SET TAGS ('dbx_business_glossary_term' = 'eCRF Field Label');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `field_length` SET TAGS ('dbx_business_glossary_term' = 'eCRF Field Maximum Length');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `field_name` SET TAGS ('dbx_business_glossary_term' = 'eCRF Field Name');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `field_name` SET TAGS ('dbx_value_regex' = '^[A-Za-z0-9_]{1,64}$');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `field_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `field_oid` SET TAGS ('dbx_business_glossary_term' = 'Field Object Identifier (OID)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `field_oid` SET TAGS ('dbx_value_regex' = '^[A-Za-z0-9_-.]{1,128}$');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `field_order` SET TAGS ('dbx_business_glossary_term' = 'eCRF Field Display Order');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `field_status` SET TAGS ('dbx_business_glossary_term' = 'eCRF Field Lifecycle Status');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `field_status` SET TAGS ('dbx_value_regex' = 'draft|active|inactive|retired');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `help_text` SET TAGS ('dbx_business_glossary_term' = 'eCRF Field Help Text');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `is_audit_trail_enabled` SET TAGS ('dbx_business_glossary_term' = 'Field Audit Trail Enabled Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `is_key_field` SET TAGS ('dbx_business_glossary_term' = 'Key Field Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `is_log_field` SET TAGS ('dbx_business_glossary_term' = 'Log Field Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `is_read_only` SET TAGS ('dbx_business_glossary_term' = 'Field Read-Only Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `is_required` SET TAGS ('dbx_business_glossary_term' = 'Field Required Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `is_sdv_required` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Required Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `is_sponsor_defined` SET TAGS ('dbx_business_glossary_term' = 'Sponsor-Defined Field Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `is_visible` SET TAGS ('dbx_business_glossary_term' = 'Field Visible Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `max_value` SET TAGS ('dbx_business_glossary_term' = 'Field Maximum Permissible Value');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `min_value` SET TAGS ('dbx_business_glossary_term' = 'Field Minimum Permissible Value');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `modified_by` SET TAGS ('dbx_business_glossary_term' = 'Field Definition Last Modified By User');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Field Definition Last Modified Timestamp');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `query_generation_mode` SET TAGS ('dbx_business_glossary_term' = 'Data Query Generation Mode');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `query_generation_mode` SET TAGS ('dbx_value_regex' = 'automatic|manual|none');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `rave_field_type` SET TAGS ('dbx_business_glossary_term' = 'Medidata Rave Field Control Type');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_business_glossary_term' = 'Study Data Tabulation Model (SDTM) Domain');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}$');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_implements' = 'SDTM.DOMAIN');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `sdtm_variable` SET TAGS ('dbx_business_glossary_term' = 'Study Data Tabulation Model (SDTM) Variable Name');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `sdtm_variable` SET TAGS ('dbx_value_regex' = '^[A-Z][A-Z0-9]{1,7}$');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `sdtm_variable` SET TAGS ('dbx_implements' = 'SDTM target variable');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `sdtm_variable` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `significant_digits` SET TAGS ('dbx_business_glossary_term' = 'Field Significant Digits');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `source_system_field_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Field Identifier');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `unit_dictionary` SET TAGS ('dbx_business_glossary_term' = 'Field Unit Dictionary');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `validation_rule_expression` SET TAGS ('dbx_business_glossary_term' = 'Field Validation Rule Expression');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'eCRF Field Version Number');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^d+.d+(.d+)?$');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `version_number` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ALTER COLUMN `version_number` SET TAGS ('dbx_implements' = 'USDM StudyVersion.versionIdentifier');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` SET TAGS ('dbx_domain' = 'datamanagement');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` SET TAGS ('dbx_subdomain' = 'source_integration');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ALTER COLUMN `define_document_id` SET TAGS ('dbx_pk' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ALTER COLUMN `audit_finding_id` SET TAGS ('dbx_business_glossary_term' = 'Audit Finding Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ALTER COLUMN `regulatory_binder_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Binder Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Sap Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Study');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ALTER COLUMN `study_id` SET TAGS ('dbx_fk' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ALTER COLUMN `content` SET TAGS ('dbx_cdisc' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ALTER COLUMN `content` SET TAGS ('dbx_implements' = 'ODM.Document');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ALTER COLUMN `content` SET TAGS ('dbx_standard' = 'Define-XML');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ALTER COLUMN `define_version` SET TAGS ('dbx_standard' = 'Define-XML');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ALTER COLUMN `define_version` SET TAGS ('dbx_element_ODM_def' = 'DefineVersion');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ALTER COLUMN `define_xml_version` SET TAGS ('dbx_cdisc' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ALTER COLUMN `define_xml_version` SET TAGS ('dbx_implements_ODM_def' = 'DefineVersion');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ALTER COLUMN `define_xml_version` SET TAGS ('dbx_standard' = 'Define-XML');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ALTER COLUMN `document_status` SET TAGS ('dbx_business_glossary_term' = 'Status');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ALTER COLUMN `document_type` SET TAGS ('dbx_standard' = 'Define-XML');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ALTER COLUMN `document_type` SET TAGS ('dbx_element' = 'ItemGroupDef.Purpose');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ALTER COLUMN `generation_date` SET TAGS ('dbx_standard' = 'Define-XML');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ALTER COLUMN `generation_date` SET TAGS ('dbx_element' = 'ODM.CreationDateTime');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ALTER COLUMN `odm_file_oid` SET TAGS ('dbx_business_glossary_term' = 'File OID');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ALTER COLUMN `odm_file_oid` SET TAGS ('dbx_standard' = 'Define-XML');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ALTER COLUMN `odm_file_oid` SET TAGS ('dbx_element' = 'ODM.FileOID');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ALTER COLUMN `odm_oid` SET TAGS ('dbx_business_glossary_term' = 'Study OID');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ALTER COLUMN `odm_oid` SET TAGS ('dbx_standard' = 'Define-XML');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ALTER COLUMN `odm_oid` SET TAGS ('dbx_element' = 'Study.OID');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ALTER COLUMN `stylesheet_reference` SET TAGS ('dbx_business_glossary_term' = 'Stylesheet');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ALTER COLUMN `stylesheet_reference` SET TAGS ('dbx_standard' = 'Define-XML');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ALTER COLUMN `stylesheet_reference` SET TAGS ('dbx_element' = 'xml-stylesheet');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ALTER COLUMN `submission_package_reference` SET TAGS ('dbx_business_glossary_term' = 'Submission Package');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ALTER COLUMN `submission_package_reference` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_source_system` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_source_system` SET TAGS ('dbx_domain' = 'datamanagement');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_source_system` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_source_system` SET TAGS ('dbx_subdomain' = 'source_integration');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_source_system` ALTER COLUMN `ehr_source_system_id` SET TAGS ('dbx_pk' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_source_system` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_source_system` ALTER COLUMN `fhir_base_url` SET TAGS ('dbx_implements' = 'CapabilityStatement.implementation.url');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_source_system` ALTER COLUMN `fhir_base_url` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_source_system` ALTER COLUMN `fhir_base_url` SET TAGS ('dbx_pii_system_identifier' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_source_system` ALTER COLUMN `fhir_base_url` SET TAGS ('dbx_standard' = 'HL7 FHIR');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_source_system` ALTER COLUMN `fhir_version` SET TAGS ('dbx_implements' = 'CapabilityStatement.fhirVersion');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_source_system` ALTER COLUMN `fhir_version` SET TAGS ('dbx_standard' = 'HL7 FHIR');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_source_system` ALTER COLUMN `source_system_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_data_transfer` ADD CONSTRAINT `fk_datamanagement_ehr_data_transfer_primary_ehr_source_system_id` FOREIGN KEY (`primary_ehr_source_system_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`ehr_source_system`(`ehr_source_system_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_data_transfer` ADD CONSTRAINT `fk_datamanagement_ehr_data_transfer_source_ehr_source_system_id` FOREIGN KEY (`source_ehr_source_system_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`ehr_source_system`(`ehr_source_system_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_data_transfer` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_data_transfer` SET TAGS ('dbx_domain' = 'datamanagement');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_data_transfer` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_data_transfer` SET TAGS ('dbx_subdomain' = 'source_integration');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_data_transfer` ALTER COLUMN `ehr_data_transfer_id` SET TAGS ('dbx_pk' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_data_transfer` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Consent Subject Consent Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_data_transfer` ALTER COLUMN `study_visit_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Study Visit Schedule Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_data_transfer` ALTER COLUMN `error_message` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_data_transfer` ALTER COLUMN `fhir_bundle_reference` SET TAGS ('dbx_implements' = 'Bundle.id');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_data_transfer` ALTER COLUMN `fhir_bundle_reference` SET TAGS ('dbx_standard' = 'HL7 FHIR');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_data_transfer` ALTER COLUMN `fhir_resource_reference` SET TAGS ('dbx_implements' = 'Resource.id');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_data_transfer` ALTER COLUMN `fhir_resource_reference` SET TAGS ('dbx_standard' = 'HL7 FHIR');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_data_transfer` ALTER COLUMN `fhir_resource_type` SET TAGS ('dbx_implements' = 'Resource.resourceType');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_data_transfer` ALTER COLUMN `fhir_resource_type` SET TAGS ('dbx_standard' = 'HL7 FHIR');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`codelist` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`codelist` SET TAGS ('dbx_domain' = 'datamanagement');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`codelist` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`codelist` SET TAGS ('dbx_subdomain' = 'source_integration');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`codelist` ALTER COLUMN `codelist_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`codelist` ALTER COLUMN `package_version` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`codelist` ALTER COLUMN `short_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ADD CONSTRAINT `fk_datamanagement_ecrf_form_dmp_id` FOREIGN KEY (`dmp_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`dmp`(`dmp_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` SET TAGS ('dbx_domain' = 'datamanagement');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` SET TAGS ('dbx_subdomain' = 'capture_operations');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `ecrf_form_id` SET TAGS ('dbx_business_glossary_term' = 'Electronic Case Report Form (eCRF) Form ID');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `dmp_id` SET TAGS ('dbx_business_glossary_term' = 'Dmp Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Consent Icf Version Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `lab_panel_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Panel Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Study Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Study Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `annotation_text` SET TAGS ('dbx_business_glossary_term' = 'eCRF Annotation Text');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `approved_date` SET TAGS ('dbx_business_glossary_term' = 'Form Approval Date');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `cdash_domain` SET TAGS ('dbx_business_glossary_term' = 'Clinical Data Acquisition Standards Harmonization (CDASH) Domain');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `cdash_domain` SET TAGS ('dbx_implements' = 'CDASHIG.Domain');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `cdash_domain` SET TAGS ('dbx_standard' = 'CDASH');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `coding_dictionary` SET TAGS ('dbx_business_glossary_term' = 'Medical Coding Dictionary');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `coding_dictionary` SET TAGS ('dbx_value_regex' = 'MedDRA|WHO_DD|SNOMED_CT|ICD_10|none');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `coding_dictionary` SET TAGS ('dbx_licensed_dictionary' = 'structure_only; dictionary_licensed_by_customer; model_defines_structure_only');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `completion_rule` SET TAGS ('dbx_business_glossary_term' = 'Form Completion Rule');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `completion_rule` SET TAGS ('dbx_value_regex' = 'all_fields_required|partial_allowed|conditional|not_applicable_allowed');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `data_entry_mode` SET TAGS ('dbx_value_regex' = 'single|double|no_entry');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Form Effective End Date');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Form Effective Start Date');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `field_count` SET TAGS ('dbx_business_glossary_term' = 'eCRF Field Count');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `form_description` SET TAGS ('dbx_business_glossary_term' = 'eCRF Form Description');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `form_name` SET TAGS ('dbx_business_glossary_term' = 'eCRF Form Name');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `form_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `form_oid` SET TAGS ('dbx_business_glossary_term' = 'eCRF Form Object Identifier (OID)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `form_order` SET TAGS ('dbx_business_glossary_term' = 'Form Display Order');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `form_status` SET TAGS ('dbx_business_glossary_term' = 'eCRF Form Status');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `form_status` SET TAGS ('dbx_value_regex' = 'draft|active|inactive|retired|under_review');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `form_type` SET TAGS ('dbx_business_glossary_term' = 'eCRF Form Type');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `form_type` SET TAGS ('dbx_value_regex' = 'visit_based|unscheduled|log|repeating|common');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `form_version` SET TAGS ('dbx_business_glossary_term' = 'eCRF Form Version');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `help_text` SET TAGS ('dbx_business_glossary_term' = 'Form Help Text');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `is_mandatory` SET TAGS ('dbx_business_glossary_term' = 'Is Mandatory Form Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `is_repeating` SET TAGS ('dbx_business_glossary_term' = 'Is Repeating Form Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `is_subject_level` SET TAGS ('dbx_business_glossary_term' = 'Is Subject-Level Form Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `language_code` SET TAGS ('dbx_business_glossary_term' = 'Form Language Code');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `language_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `medical_coding_required` SET TAGS ('dbx_business_glossary_term' = 'Medical Coding Required Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `medical_coding_required` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `medical_coding_required` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `medical_coding_required` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `primary_endpoint_flag` SET TAGS ('dbx_business_glossary_term' = 'Primary Endpoint Form Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `protocol_section_ref` SET TAGS ('dbx_business_glossary_term' = 'Protocol Section Reference');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `rave_form_reference` SET TAGS ('dbx_business_glossary_term' = 'Medidata Rave Form ID');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `requires_signature` SET TAGS ('dbx_business_glossary_term' = 'Requires Electronic Signature Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `requires_signature` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_business_glossary_term' = 'Study Data Tabulation Model (SDTM) Domain');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_implements' = 'SDTM.DOMAIN');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `sdv_percentage` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Percentage');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `sdv_percentage` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `sdv_required` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Required Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `signature_role` SET TAGS ('dbx_business_glossary_term' = 'Required Signature Role');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `signature_role` SET TAGS ('dbx_value_regex' = 'principal_investigator|sub_investigator|data_manager|sponsor_representative|not_required');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `signature_role` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ADD CONSTRAINT `fk_datamanagement_subject_visit_data_codelist_id` FOREIGN KEY (`codelist_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`codelist`(`codelist_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ADD CONSTRAINT `fk_datamanagement_subject_visit_data_ecrf_form_id` FOREIGN KEY (`ecrf_form_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`ecrf_form`(`ecrf_form_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` SET TAGS ('dbx_domain' = 'datamanagement');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` SET TAGS ('dbx_subdomain' = 'capture_operations');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `codelist_id` SET TAGS ('dbx_business_glossary_term' = 'Visit Type');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `codelist_id` SET TAGS ('dbx_codelist' = 'VISITYP');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `codelist_id` SET TAGS ('dbx_governing_standard' = 'CDISC CT');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `codelist_id` SET TAGS ('dbx_implements' = 'USDM Encounter.type');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `codelist_id` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Consent Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `database_lock_event_id` SET TAGS ('dbx_business_glossary_term' = 'Database Lock Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `ecrf_form_id` SET TAGS ('dbx_business_glossary_term' = 'Ecrf Form Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `study_visit_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Study Visit Schedule Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `subject_randomization_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Randomization Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_business_glossary_term' = 'Treatment Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `visit_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Visit Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `alcoa_compliant` SET TAGS ('dbx_business_glossary_term' = 'ALCOA+ Compliance Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `cdisc_sdtm_domain` SET TAGS ('dbx_business_glossary_term' = 'Clinical Data Interchange Standards Consortium (CDISC) Study Data Tabulation Model (SDTM) Domain');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `cdisc_sdtm_domain` SET TAGS ('dbx_implements' = 'SDTM.DOMAIN');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `cdisc_sdtm_domain` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `completion_status` SET TAGS ('dbx_business_glossary_term' = 'Form Completion Status');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `completion_status` SET TAGS ('dbx_value_regex' = 'incomplete|complete|frozen|locked|signed');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `data_completeness_pct` SET TAGS ('dbx_business_glossary_term' = 'Data Completeness Percentage');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `data_review_status` SET TAGS ('dbx_value_regex' = 'not_started|in_review|reviewed|approved|requires_correction');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `edc_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) Record ID');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `entered_by` SET TAGS ('dbx_business_glossary_term' = 'Data Entered By User');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `freeze_status` SET TAGS ('dbx_business_glossary_term' = 'Form Freeze Status');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `freeze_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Form Freeze Timestamp');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `investigator_signature_status` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Signature Status');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `investigator_signature_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|signed|rejected');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `investigator_signature_status` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `investigator_signature_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Signature Timestamp');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `investigator_signature_timestamp` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `last_modified_by` SET TAGS ('dbx_business_glossary_term' = 'Last Modified By User');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `lock_status` SET TAGS ('dbx_business_glossary_term' = 'Database Lock (DBL) Status');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `lock_status` SET TAGS ('dbx_value_regex' = 'unlocked|locked|hard_locked');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `locked_by` SET TAGS ('dbx_business_glossary_term' = 'Locked By User');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `medical_coding_status` SET TAGS ('dbx_value_regex' = 'not_applicable|pending|coded|approved|rejected');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `medical_coding_status` SET TAGS ('dbx_licensed_dictionary' = 'structure_only; dictionary_licensed_by_customer; model_defines_structure_only');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `medical_coding_status` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `medical_coding_status` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `medical_coding_status` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `rave_page_repeat_key` SET TAGS ('dbx_business_glossary_term' = 'Medidata Rave Page Repeat Key');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `rave_page_repeat_key` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `sdv_date` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Date');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `sdv_status` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Status');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `sdv_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|partial|verified|overdue');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `subject_number` SET TAGS ('dbx_implements' = 'SDTM DM.SUBJID');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `subject_number` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `subject_number` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `visit_date` SET TAGS ('dbx_implements' = 'SDTM SV.SVSTDTC');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `visit_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `visit_date` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ALTER COLUMN `visit_within_window` SET TAGS ('dbx_business_glossary_term' = 'Visit Within Window Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ADD CONSTRAINT `fk_datamanagement_field_entry_discrepancy_query_id` FOREIGN KEY (`discrepancy_query_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`discrepancy_query`(`discrepancy_query_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ADD CONSTRAINT `fk_datamanagement_field_entry_ecrf_field_id` FOREIGN KEY (`ecrf_field_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`ecrf_field`(`ecrf_field_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ADD CONSTRAINT `fk_datamanagement_field_entry_ecrf_form_id` FOREIGN KEY (`ecrf_form_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`ecrf_form`(`ecrf_form_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ADD CONSTRAINT `fk_datamanagement_field_entry_ehr_data_transfer_id` FOREIGN KEY (`ehr_data_transfer_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`ehr_data_transfer`(`ehr_data_transfer_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ADD CONSTRAINT `fk_datamanagement_field_entry_subject_visit_data_id` FOREIGN KEY (`subject_visit_data_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`subject_visit_data`(`subject_visit_data_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ADD CONSTRAINT `fk_datamanagement_field_entry_validation_rule_id` FOREIGN KEY (`validation_rule_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`validation_rule`(`validation_rule_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` SET TAGS ('dbx_domain' = 'datamanagement');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` SET TAGS ('dbx_subdomain' = 'capture_operations');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `demographic_id` SET TAGS ('dbx_business_glossary_term' = 'Demographic Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `discrepancy_query_id` SET TAGS ('dbx_business_glossary_term' = 'Data Query ID');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `dispensing_record_id` SET TAGS ('dbx_business_glossary_term' = 'Dispensing Record Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `ecrf_field_id` SET TAGS ('dbx_business_glossary_term' = 'Ecrf Field Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `ecrf_form_id` SET TAGS ('dbx_business_glossary_term' = 'Electronic Case Report Form (eCRF) ID');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `ehr_data_transfer_id` SET TAGS ('dbx_business_glossary_term' = 'Ehr Data Transfer Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `enrollment_id` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `irt_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Irt Transaction Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `lab_result_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Result Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `subject_randomization_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Randomization Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `subject_visit_data_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Visit Data Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `visit_id` SET TAGS ('dbx_business_glossary_term' = 'Visit ID');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `alcoa_accurate` SET TAGS ('dbx_business_glossary_term' = 'ALCOA+ Accurate Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `alcoa_attributable` SET TAGS ('dbx_business_glossary_term' = 'ALCOA+ Attributable Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `alcoa_contemporaneous` SET TAGS ('dbx_business_glossary_term' = 'ALCOA+ Contemporaneous Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `alcoa_legible` SET TAGS ('dbx_business_glossary_term' = 'ALCOA+ Legible Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `alcoa_original` SET TAGS ('dbx_business_glossary_term' = 'ALCOA+ Original Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `audit_trail_ref` SET TAGS ('dbx_business_glossary_term' = 'Audit Trail Reference');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `coded_term` SET TAGS ('dbx_licensed_dictionary' = 'structure_only; dictionary_licensed_by_customer; model_defines_structure_only');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `coding_dictionary` SET TAGS ('dbx_business_glossary_term' = 'Medical Coding Dictionary');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `coding_dictionary` SET TAGS ('dbx_value_regex' = 'MedDRA|WHO-DD|SNOMED-CT|ICD-10|LOINC|not_applicable');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `coding_dictionary` SET TAGS ('dbx_licensed_dictionary' = 'structure_only; dictionary_licensed_by_customer; model_defines_structure_only');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `data_entry_type` SET TAGS ('dbx_value_regex' = 'manual|auto_populated|derived|migrated|imported');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `entry_status` SET TAGS ('dbx_business_glossary_term' = 'Field Entry Status');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `entry_status` SET TAGS ('dbx_value_regex' = 'entered|modified|deleted|frozen|locked|sdv_complete');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `entry_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Field Entry Timestamp');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `entry_value` SET TAGS ('dbx_business_glossary_term' = 'Field Entry Value');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `entry_value` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `entry_value` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `form_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `has_open_query` SET TAGS ('dbx_business_glossary_term' = 'Has Open Query Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `is_frozen` SET TAGS ('dbx_business_glossary_term' = 'Field Frozen Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `is_locked` SET TAGS ('dbx_business_glossary_term' = 'Field Locked Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `is_missing` SET TAGS ('dbx_business_glossary_term' = 'Missing Data Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `locked_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Database Lock (DBL) Timestamp');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `medical_coding_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|coded|auto_coded|recoded');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `medical_coding_status` SET TAGS ('dbx_licensed_dictionary' = 'structure_only; dictionary_licensed_by_customer; model_defines_structure_only');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `medical_coding_status` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `medical_coding_status` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `medical_coding_status` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `missing_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Missing Data Reason Code');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `missing_reason_code` SET TAGS ('dbx_value_regex' = 'NOT_DONE|UNKNOWN|NA|NOT_APPLICABLE|TECHNICAL_FAILURE|SUBJECT_REFUSED');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Field Modification Timestamp');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `previous_value` SET TAGS ('dbx_business_glossary_term' = 'Previous Field Value');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `previous_value` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `previous_value` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `rave_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Medidata Rave Record ID');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_business_glossary_term' = 'Study Data Tabulation Model (SDTM) Domain');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_implements' = 'SDTM.DOMAIN');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `sdtm_variable` SET TAGS ('dbx_business_glossary_term' = 'Study Data Tabulation Model (SDTM) Variable');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `sdtm_variable` SET TAGS ('dbx_implements' = 'SDTM target variable');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `sdtm_variable` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `sdv_by_user` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Performed By');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `sdv_status` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Status');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `sdv_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|verified|failed');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `sdv_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Timestamp');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ALTER COLUMN `validation_result` SET TAGS ('dbx_value_regex' = 'pass|fail|warning|not_evaluated');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ADD CONSTRAINT `fk_datamanagement_discrepancy_query_ecrf_field_id` FOREIGN KEY (`ecrf_field_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`ecrf_field`(`ecrf_field_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ADD CONSTRAINT `fk_datamanagement_discrepancy_query_ecrf_form_id` FOREIGN KEY (`ecrf_form_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`ecrf_form`(`ecrf_form_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ADD CONSTRAINT `fk_datamanagement_discrepancy_query_subject_visit_data_id` FOREIGN KEY (`subject_visit_data_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`subject_visit_data`(`subject_visit_data_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ADD CONSTRAINT `fk_datamanagement_discrepancy_query_validation_rule_id` FOREIGN KEY (`validation_rule_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`validation_rule`(`validation_rule_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` SET TAGS ('dbx_domain' = 'datamanagement');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` SET TAGS ('dbx_subdomain' = 'capture_operations');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Consent Subject Consent Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `demographic_id` SET TAGS ('dbx_business_glossary_term' = 'Demographic Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `dispensing_record_id` SET TAGS ('dbx_business_glossary_term' = 'Dispensing Record Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `ecrf_field_id` SET TAGS ('dbx_business_glossary_term' = 'Ecrf Field Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `ecrf_form_id` SET TAGS ('dbx_business_glossary_term' = 'Ecrf Form Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `enrollment_id` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `lab_result_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Result Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `subject_visit_data_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Visit Data Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `validation_rule_id` SET TAGS ('dbx_business_glossary_term' = 'Validation Rule Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_business_glossary_term' = 'Query Cancellation Reason');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `cancelled_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Query Cancelled Timestamp');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `cancelled_timestamp` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `closed_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Query Closed Timestamp');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `data_value_corrected` SET TAGS ('dbx_business_glossary_term' = 'Corrected Data Value');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `data_value_original` SET TAGS ('dbx_business_glossary_term' = 'Original Data Value');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `is_dbl_blocking` SET TAGS ('dbx_business_glossary_term' = 'Database Lock (DBL) Blocking Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `is_escalated` SET TAGS ('dbx_business_glossary_term' = 'Escalation Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `is_safety_related` SET TAGS ('dbx_business_glossary_term' = 'Safety-Related Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `priority` SET TAGS ('dbx_business_glossary_term' = 'Query Priority');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `priority` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `query_status` SET TAGS ('dbx_value_regex' = 'open|answered|closed|cancelled');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `query_type` SET TAGS ('dbx_value_regex' = 'manual|system|review|reconciliation');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `raised_by_role` SET TAGS ('dbx_value_regex' = 'CRA|DM|medical_reviewer|system|sponsor|other');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `raised_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Query Raised Timestamp');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `rave_query_reference` SET TAGS ('dbx_business_glossary_term' = 'Medidata Rave Query ID');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `reopen_count` SET TAGS ('dbx_business_glossary_term' = 'Query Reopen Count');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `resolution_cycle_days` SET TAGS ('dbx_business_glossary_term' = 'Query Resolution Cycle Days');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `response_cycle_days` SET TAGS ('dbx_business_glossary_term' = 'Query Response Cycle Days');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `response_text` SET TAGS ('dbx_business_glossary_term' = 'Query Response Text');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `response_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Query Response Timestamp');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `visit_name` SET TAGS ('dbx_implements' = 'SDTM SV.VISIT');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `visit_name` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ALTER COLUMN `visit_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ADD CONSTRAINT `fk_datamanagement_validation_rule_dmp_id` FOREIGN KEY (`dmp_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`dmp`(`dmp_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ADD CONSTRAINT `fk_datamanagement_validation_rule_ecrf_field_id` FOREIGN KEY (`ecrf_field_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`ecrf_field`(`ecrf_field_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ADD CONSTRAINT `fk_datamanagement_validation_rule_ecrf_form_id` FOREIGN KEY (`ecrf_form_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`ecrf_form`(`ecrf_form_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` SET TAGS ('dbx_domain' = 'datamanagement');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` SET TAGS ('dbx_subdomain' = 'capture_operations');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `bioanalytical_assay_id` SET TAGS ('dbx_business_glossary_term' = 'Bioanalytical Assay Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `dmp_id` SET TAGS ('dbx_business_glossary_term' = 'Dmp Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `document_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Document Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `ecrf_field_id` SET TAGS ('dbx_business_glossary_term' = 'Ecrf Field Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `ecrf_form_id` SET TAGS ('dbx_business_glossary_term' = 'Ecrf Form Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `endpoint_id` SET TAGS ('dbx_business_glossary_term' = 'Endpoint Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `lab_panel_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Analyte Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `rand_scheme_id` SET TAGS ('dbx_business_glossary_term' = 'Rand Scheme Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `reference_range_id` SET TAGS ('dbx_business_glossary_term' = 'Reference Range Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `risk_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Study Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `activation_date` SET TAGS ('dbx_business_glossary_term' = 'Rule Activation Date');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `approved_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Rule Approval Timestamp');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `cdisc_domain` SET TAGS ('dbx_business_glossary_term' = 'Clinical Data Interchange Standards Consortium (CDISC) SDTM Domain');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `cdisc_domain` SET TAGS ('dbx_implements' = 'SDTM.DOMAIN');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `cdisc_domain` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `cdisc_variable` SET TAGS ('dbx_business_glossary_term' = 'Clinical Data Interchange Standards Consortium (CDISC) Variable Name');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `cdisc_variable` SET TAGS ('dbx_implements' = 'SDTM variable name');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `cdisc_variable` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `change_reason` SET TAGS ('dbx_business_glossary_term' = 'Rule Change Reason');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Rule Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `deactivation_date` SET TAGS ('dbx_business_glossary_term' = 'Rule Deactivation Date');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'Rule Effective From Date');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'Rule Effective Until Date');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `generates_query` SET TAGS ('dbx_business_glossary_term' = 'Automated Query Generation Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `is_cdisc_compliant` SET TAGS ('dbx_business_glossary_term' = 'Clinical Data Interchange Standards Consortium (CDISC) Compliance Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `is_mandatory` SET TAGS ('dbx_business_glossary_term' = 'Mandatory Rule Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `modified_by` SET TAGS ('dbx_business_glossary_term' = 'Rule Last Modified By');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Rule Last Modified Timestamp');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Validation Rule Notes');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `previous_version` SET TAGS ('dbx_business_glossary_term' = 'Previous Validation Rule Version');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `previous_version` SET TAGS ('dbx_value_regex' = '^d+.d+(.d+)?$');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `query_text` SET TAGS ('dbx_business_glossary_term' = 'Automated Query Text');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `rave_edit_check_reference` SET TAGS ('dbx_business_glossary_term' = 'Medidata Rave Edit Check Identifier');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `rule_category` SET TAGS ('dbx_business_glossary_term' = 'Validation Rule Category');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `rule_category` SET TAGS ('dbx_value_regex' = 'range_check|cross_form|date_logic|required_field|consistency_check|coding_check');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `rule_code` SET TAGS ('dbx_business_glossary_term' = 'Validation Rule Code');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `rule_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{2,50}$');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `rule_description` SET TAGS ('dbx_business_glossary_term' = 'Validation Rule Description');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `rule_expression` SET TAGS ('dbx_business_glossary_term' = 'Validation Rule Expression');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `rule_name` SET TAGS ('dbx_business_glossary_term' = 'Validation Rule Name');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `rule_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `rule_status` SET TAGS ('dbx_business_glossary_term' = 'Validation Rule Status');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `rule_status` SET TAGS ('dbx_value_regex' = 'draft|active|inactive|retired|under_review');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `rule_type` SET TAGS ('dbx_business_glossary_term' = 'Validation Rule Type');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `rule_type` SET TAGS ('dbx_value_regex' = 'edit_check|derivation|custom_function|system_check');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `rule_version` SET TAGS ('dbx_business_glossary_term' = 'Validation Rule Version');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `rule_version` SET TAGS ('dbx_value_regex' = '^d+.d+(.d+)?$');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `scope` SET TAGS ('dbx_business_glossary_term' = 'Validation Rule Scope');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `scope` SET TAGS ('dbx_value_regex' = 'field|form|folder|study');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `severity_level` SET TAGS ('dbx_business_glossary_term' = 'Validation Rule Severity Level');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `severity_level` SET TAGS ('dbx_value_regex' = 'error|warning|informational');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `trigger_condition` SET TAGS ('dbx_business_glossary_term' = 'Validation Rule Trigger Condition');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `trigger_condition` SET TAGS ('dbx_value_regex' = 'on_save|on_entry|on_change|on_activation|on_signature|batch');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `uat_completion_date` SET TAGS ('dbx_business_glossary_term' = 'User Acceptance Testing (UAT) Completion Date');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `uat_status` SET TAGS ('dbx_business_glossary_term' = 'User Acceptance Testing (UAT) Status');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `uat_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|passed|failed|waived');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Rule Created By');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` SET TAGS ('dbx_domain' = 'datamanagement');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` SET TAGS ('dbx_subdomain' = 'source_integration');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `dmp_id` SET TAGS ('dbx_business_glossary_term' = 'Data Management Plan (DMP) ID');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `audit_id` SET TAGS ('dbx_business_glossary_term' = 'Audit Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `blinding_config_id` SET TAGS ('dbx_business_glossary_term' = 'Blinding Config Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `document_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Preference Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `ethics_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Ethics Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Regulatory Strategy Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `ind_application_id` SET TAGS ('dbx_business_glossary_term' = 'Ind Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `rand_scheme_id` SET TAGS ('dbx_business_glossary_term' = 'Rand Scheme Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `regulatory_binder_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Binder Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `regulatory_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Triggering Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `risk_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Sap Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `tmf_artifact_id` SET TAGS ('dbx_business_glossary_term' = 'Document Template Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `adam_ig_version` SET TAGS ('dbx_business_glossary_term' = 'Analysis Data Model Implementation Guide (ADaM IG) Version');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `adam_ig_version` SET TAGS ('dbx_implements' = 'ADaMIG.version');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `adam_ig_version` SET TAGS ('dbx_standard' = 'ADaM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `alcoa_compliance_approach` SET TAGS ('dbx_business_glossary_term' = 'ALCOA+ Compliance Approach');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `amendment_reason` SET TAGS ('dbx_business_glossary_term' = 'DMP Amendment Reason');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'DMP Approval Date');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'DMP Approval Status');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|superseded|retired');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `autocoding_enabled` SET TAGS ('dbx_business_glossary_term' = 'Auto-Coding Enabled Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `autocoding_enabled` SET TAGS ('dbx_licensed_dictionary' = 'structure_only; dictionary_licensed_by_customer; model_defines_structure_only');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `dmp_code` SET TAGS ('dbx_business_glossary_term' = 'Data Management Plan (DMP) Code');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `dmp_code` SET TAGS ('dbx_value_regex' = '^DMP-[A-Z0-9]{3,20}-[0-9]{3}$');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `coding_platform` SET TAGS ('dbx_business_glossary_term' = 'Medical Coding Platform');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `coding_platform` SET TAGS ('dbx_value_regex' = 'Medidata Rave Coder|Oracle Argus|Relsys|Manual|Other');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `coding_platform` SET TAGS ('dbx_licensed_dictionary' = 'structure_only; dictionary_licensed_by_customer; model_defines_structure_only');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'DMP Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `critical_data_fields_defined` SET TAGS ('dbx_business_glossary_term' = 'Critical Data Fields Defined Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `data_collection_strategy` SET TAGS ('dbx_value_regex' = 'eCRF_only|eCRF_with_external_data|paper_CRF|hybrid');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `data_privacy_framework` SET TAGS ('dbx_value_regex' = 'GDPR|HIPAA|GDPR_and_HIPAA|PIPEDA|Other');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `data_retention_period_years` SET TAGS ('dbx_business_glossary_term' = 'Data Retention Period (Years)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `dbl_actual_date` SET TAGS ('dbx_business_glossary_term' = 'Database Lock (DBL) Actual Date');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `dbl_criteria` SET TAGS ('dbx_business_glossary_term' = 'Database Lock (DBL) Criteria');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `dbl_target_date` SET TAGS ('dbx_business_glossary_term' = 'Database Lock (DBL) Target Date');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `edc_study_environment` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) Study Environment');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `edc_study_environment` SET TAGS ('dbx_value_regex' = 'production|uat|training');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `edc_study_name` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) Study Name');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `edc_study_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `edc_system` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) System');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `edc_system` SET TAGS ('dbx_value_regex' = 'Medidata Rave|Oracle Clinical One|Oracle RDC|Veeva Vault EDC|OpenClinica|Other');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'DMP Effective Date');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'DMP Expiry Date');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `external_data_transfer_required` SET TAGS ('dbx_business_glossary_term' = 'External Data Transfer Required Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `meddra_version` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) Version');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `meddra_version` SET TAGS ('dbx_value_regex' = '^[0-9]{1,2}.[0-9]{1}$');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `meddra_version` SET TAGS ('dbx_licensed_dictionary' = 'structure_only; dictionary_licensed_by_customer; model_defines_structure_only');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `part11_compliance_confirmed` SET TAGS ('dbx_business_glossary_term' = '21 CFR Part 11 Compliance Confirmed Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `pseudonymization_method` SET TAGS ('dbx_business_glossary_term' = 'Subject Pseudonymization Method');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `pseudonymization_method` SET TAGS ('dbx_value_regex' = 'subject_number_only|one_way_hash|tokenization|other');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `query_management_convention` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `sdtm_ig_version` SET TAGS ('dbx_business_glossary_term' = 'Study Data Tabulation Model Implementation Guide (SDTM IG) Version');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `sdtm_ig_version` SET TAGS ('dbx_implements' = 'SDTMIG.version');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `sdtm_ig_version` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `sdtm_mapping_version` SET TAGS ('dbx_business_glossary_term' = 'Study Data Tabulation Model (SDTM) Mapping Version');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `sdtm_mapping_version` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `sdtm_mapping_version` SET TAGS ('dbx_implements' = 'SDTM mapping version');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `sdtm_mapping_version` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `study_phase` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study Phase');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `study_phase` SET TAGS ('dbx_value_regex' = 'Phase I|Phase II|Phase III|Phase IV|Phase I/II|Phase II/III');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `study_phase` SET TAGS ('dbx_implements' = 'USDM StudyDesign.studyPhase');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `study_phase` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `unblinding_procedure_documented` SET TAGS ('dbx_business_glossary_term' = 'Unblinding Procedure Documented Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'DMP Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'DMP Version Number');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `version_number` SET TAGS ('dbx_implements' = 'USDM StudyVersion.versionIdentifier');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `version_number` SET TAGS ('dbx_standard' = 'USDM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `whodd_version` SET TAGS ('dbx_business_glossary_term' = 'WHO Drug Dictionary (WHO-DD) Version');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ALTER COLUMN `whodd_version` SET TAGS ('dbx_licensed_dictionary' = 'structure_only; dictionary_licensed_by_customer; model_defines_structure_only');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ADD CONSTRAINT `fk_datamanagement_coding_assignment_discrepancy_query_id` FOREIGN KEY (`discrepancy_query_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`discrepancy_query`(`discrepancy_query_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ADD CONSTRAINT `fk_datamanagement_coding_assignment_ecrf_field_id` FOREIGN KEY (`ecrf_field_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`ecrf_field`(`ecrf_field_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ADD CONSTRAINT `fk_datamanagement_coding_assignment_field_entry_id` FOREIGN KEY (`field_entry_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`field_entry`(`field_entry_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ADD CONSTRAINT `fk_datamanagement_coding_assignment_subject_visit_data_id` FOREIGN KEY (`subject_visit_data_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`subject_visit_data`(`subject_visit_data_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` SET TAGS ('dbx_domain' = 'datamanagement');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` SET TAGS ('dbx_subdomain' = 'capture_operations');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `discrepancy_query_id` SET TAGS ('dbx_business_glossary_term' = 'Query ID');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `ecrf_field_id` SET TAGS ('dbx_business_glossary_term' = 'Electronic Case Report Form (eCRF) Field ID');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `endpoint_id` SET TAGS ('dbx_business_glossary_term' = 'Endpoint Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `enrollment_id` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `field_entry_id` SET TAGS ('dbx_business_glossary_term' = 'Field Entry Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Study Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `subject_visit_data_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Visit Data Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected|superseded');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `assigned_code` SET TAGS ('dbx_licensed_dictionary' = 'structure_only; dictionary_licensed_by_customer; model_defines_structure_only');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `autocoding_confidence_score` SET TAGS ('dbx_licensed_dictionary' = 'structure_only; dictionary_licensed_by_customer; model_defines_structure_only');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `coding_dictionary` SET TAGS ('dbx_value_regex' = 'MedDRA|WHO-DD|SNOMED-CT|ICD-10|CTCAE');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `coding_dictionary` SET TAGS ('dbx_licensed_dictionary' = 'structure_only; dictionary_licensed_by_customer; model_defines_structure_only');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `coding_domain` SET TAGS ('dbx_value_regex' = 'AE|CM|MH|DS|DV|EX');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `coding_domain` SET TAGS ('dbx_licensed_dictionary' = 'structure_only; dictionary_licensed_by_customer; model_defines_structure_only');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `coding_flag` SET TAGS ('dbx_licensed_dictionary' = 'structure_only; dictionary_licensed_by_customer; model_defines_structure_only');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `coding_method` SET TAGS ('dbx_value_regex' = 'autocoding|manual|assisted|recoded');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `coding_method` SET TAGS ('dbx_licensed_dictionary' = 'structure_only; dictionary_licensed_by_customer; model_defines_structure_only');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `coding_status` SET TAGS ('dbx_value_regex' = 'pending|coded|approved|rejected|queried|recoded');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `coding_status` SET TAGS ('dbx_licensed_dictionary' = 'structure_only; dictionary_licensed_by_customer; model_defines_structure_only');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `dbl_included` SET TAGS ('dbx_business_glossary_term' = 'Database Lock (DBL) Included Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `dictionary_version` SET TAGS ('dbx_value_regex' = '^[0-9]{1,3}.[0-9]{1,3}$');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `dictionary_version` SET TAGS ('dbx_licensed_dictionary' = 'structure_only; dictionary_licensed_by_customer; model_defines_structure_only');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `field_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `form_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `high_level_group_term` SET TAGS ('dbx_business_glossary_term' = 'High Level Group Term (HLGT)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `high_level_group_term` SET TAGS ('dbx_licensed_dictionary' = 'structure_only; dictionary_licensed_by_customer; model_defines_structure_only');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `high_level_term` SET TAGS ('dbx_business_glossary_term' = 'High Level Term (HLT)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `high_level_term` SET TAGS ('dbx_licensed_dictionary' = 'structure_only; dictionary_licensed_by_customer; model_defines_structure_only');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `is_primary_soc` SET TAGS ('dbx_business_glossary_term' = 'Is Primary System Organ Class (SOC) Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `is_serious_ae` SET TAGS ('dbx_business_glossary_term' = 'Is Serious Adverse Event (SAE) Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `lowest_level_term` SET TAGS ('dbx_business_glossary_term' = 'Lowest Level Term (LLT)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `lowest_level_term` SET TAGS ('dbx_licensed_dictionary' = 'structure_only; dictionary_licensed_by_customer; model_defines_structure_only');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `medical_review_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `medical_review_date` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `medical_review_date` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `preferred_term` SET TAGS ('dbx_business_glossary_term' = 'Preferred Term (PT)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `preferred_term` SET TAGS ('dbx_licensed_dictionary' = 'structure_only; dictionary_licensed_by_customer; model_defines_structure_only');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `prior_assigned_code` SET TAGS ('dbx_licensed_dictionary' = 'structure_only; dictionary_licensed_by_customer; model_defines_structure_only');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `prior_preferred_term` SET TAGS ('dbx_business_glossary_term' = 'Prior Preferred Term (PT)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `prior_preferred_term` SET TAGS ('dbx_licensed_dictionary' = 'structure_only; dictionary_licensed_by_customer; model_defines_structure_only');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `pt_code` SET TAGS ('dbx_business_glossary_term' = 'Preferred Term (PT) Code');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `pt_code` SET TAGS ('dbx_value_regex' = '^[0-9]{8}$');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `pt_code` SET TAGS ('dbx_licensed_dictionary' = 'structure_only; dictionary_licensed_by_customer; model_defines_structure_only');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `sdtm_variable` SET TAGS ('dbx_business_glossary_term' = 'Study Data Tabulation Model (SDTM) Variable');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `sdtm_variable` SET TAGS ('dbx_implements' = 'SDTM variable name');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `sdtm_variable` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `soc_code` SET TAGS ('dbx_business_glossary_term' = 'System Organ Class (SOC) Code');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `soc_code` SET TAGS ('dbx_value_regex' = '^[0-9]{8}$');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `soc_code` SET TAGS ('dbx_licensed_dictionary' = 'structure_only; dictionary_licensed_by_customer; model_defines_structure_only');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `system_organ_class` SET TAGS ('dbx_business_glossary_term' = 'System Organ Class (SOC)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `system_organ_class` SET TAGS ('dbx_licensed_dictionary' = 'structure_only; dictionary_licensed_by_customer; model_defines_structure_only');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `verbatim_term` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `verbatim_term` SET TAGS ('dbx_implements' = 'SDTM AE.AETERM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `verbatim_term` SET TAGS ('dbx_licensed_dictionary' = 'structure_only');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `verbatim_term` SET TAGS ('dbx_pii_health' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `verbatim_term` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `visit_name` SET TAGS ('dbx_implements' = 'SDTM SV.VISIT');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `visit_name` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ALTER COLUMN `visit_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ADD CONSTRAINT `fk_datamanagement_sdtm_dataset_define_document_id` FOREIGN KEY (`define_document_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`define_document`(`define_document_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ADD CONSTRAINT `fk_datamanagement_sdtm_dataset_dmp_id` FOREIGN KEY (`dmp_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`dmp`(`dmp_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ADD CONSTRAINT `fk_datamanagement_sdtm_dataset_sdtm_domain_spec_sdtm_dataset_id` FOREIGN KEY (`sdtm_domain_spec_sdtm_dataset_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset`(`sdtm_dataset_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` SET TAGS ('dbx_domain' = 'datamanagement');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` SET TAGS ('dbx_subdomain' = 'source_integration');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `sdtm_dataset_id` SET TAGS ('dbx_business_glossary_term' = 'Study Data Tabulation Model (SDTM) Dataset ID');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `sdtm_dataset_id` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `sdtm_dataset_id` SET TAGS ('dbx_implements' = 'SDTM.DOMAIN');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `define_document_id` SET TAGS ('dbx_business_glossary_term' = 'Define Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `dmp_id` SET TAGS ('dbx_business_glossary_term' = 'Dmp Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `lab_panel_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Panel Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `risk_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Sap Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `sdtm_domain_spec_sdtm_dataset_id` SET TAGS ('dbx_business_glossary_term' = 'Sdtm Domain Spec Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Study Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `controlled_terminology_version` SET TAGS ('dbx_business_glossary_term' = 'CDISC Controlled Terminology Version');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `data_cut_date` SET TAGS ('dbx_business_glossary_term' = 'Data Cut-Off Date');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `dataset_label` SET TAGS ('dbx_business_glossary_term' = 'SDTM Dataset Label');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `dataset_name` SET TAGS ('dbx_business_glossary_term' = 'SDTM Dataset Name');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `dataset_name` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,4}$');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `dataset_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `dataset_status` SET TAGS ('dbx_business_glossary_term' = 'SDTM Dataset Status');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `dbl_date` SET TAGS ('dbx_business_glossary_term' = 'Database Lock (DBL) Date');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `define_xml_version` SET TAGS ('dbx_business_glossary_term' = 'Define.xml Version');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `define_xml_version` SET TAGS ('dbx_value_regex' = '2.0|2.1');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `domain_class` SET TAGS ('dbx_business_glossary_term' = 'SDTM Domain Class');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `domain_class` SET TAGS ('dbx_value_regex' = 'Events|Interventions|Findings|Special Purpose|Relationship|Trial Design');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `domain_code` SET TAGS ('dbx_cdisc' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `domain_code` SET TAGS ('dbx_implements' = 'SDTM.DOMAIN');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `domain_code` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `generation_date` SET TAGS ('dbx_business_glossary_term' = 'Dataset Generation Date');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `generation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Dataset Generation Timestamp');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `is_split_dataset` SET TAGS ('dbx_business_glossary_term' = 'Split Dataset Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `is_submission_ready` SET TAGS ('dbx_business_glossary_term' = 'Submission-Ready Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `label` SET TAGS ('dbx_cdisc' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `label` SET TAGS ('dbx_implements' = 'SDTMIG.DomainLabel');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `label` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Dataset Notes');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `pinnacle21_run_date` SET TAGS ('dbx_business_glossary_term' = 'Pinnacle 21 Validation Run Date');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `pinnacle21_validation_status` SET TAGS ('dbx_value_regex' = 'Pass|Pass with Warnings|Fail|Not Run');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `qc_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Quality Control (QC) Completion Date');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `qc_status` SET TAGS ('dbx_business_glossary_term' = 'Quality Control (QC) Status');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `qc_status` SET TAGS ('dbx_value_regex' = 'Not Started|In Progress|QC Pass|QC Fail|Waived');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `record_count` SET TAGS ('dbx_business_glossary_term' = 'Dataset Record Count');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `reviewer_guide_reference` SET TAGS ('dbx_business_glossary_term' = 'Analysis Data Reviewers Guide (ADRG) Reference');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `sas_dataset_path` SET TAGS ('dbx_business_glossary_term' = 'SAS Transport Dataset File Path');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `sdtm_ig_version` SET TAGS ('dbx_business_glossary_term' = 'SDTM Implementation Guide (IG) Version');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `sdtm_ig_version` SET TAGS ('dbx_value_regex' = '^d+.d+(.d+)?$');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `sdtm_ig_version` SET TAGS ('dbx_implements' = 'SDTMIG.version');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `sdtm_ig_version` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `split_sequence` SET TAGS ('dbx_business_glossary_term' = 'Split Dataset Sequence Number');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `sponsor_dataset_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `suppqual_included` SET TAGS ('dbx_business_glossary_term' = 'Supplemental Qualifier (SUPPQUAL) Included Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ALTER COLUMN `xpt_file_size_kb` SET TAGS ('dbx_business_glossary_term' = 'XPT File Size (Kilobytes)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ADD CONSTRAINT `fk_datamanagement_sdtm_mapping_codelist_id` FOREIGN KEY (`codelist_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`codelist`(`codelist_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ADD CONSTRAINT `fk_datamanagement_sdtm_mapping_primary_sdtm_dataset_id` FOREIGN KEY (`primary_sdtm_dataset_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset`(`sdtm_dataset_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ADD CONSTRAINT `fk_datamanagement_sdtm_mapping_source_ecrf_field_id` FOREIGN KEY (`source_ecrf_field_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`ecrf_field`(`ecrf_field_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ADD CONSTRAINT `fk_datamanagement_sdtm_mapping_source_ecrf_form_id` FOREIGN KEY (`source_ecrf_form_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`ecrf_form`(`ecrf_form_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` SET TAGS ('dbx_domain' = 'datamanagement');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` SET TAGS ('dbx_subdomain' = 'source_integration');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `sdtm_mapping_id` SET TAGS ('dbx_business_glossary_term' = 'Study Data Tabulation Model (SDTM) Mapping ID');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `sdtm_mapping_id` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `sdtm_mapping_id` SET TAGS ('dbx_implements' = 'SDTM.DOMAIN');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `bioanalytical_assay_id` SET TAGS ('dbx_business_glossary_term' = 'Bioanalytical Assay Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `codelist_id` SET TAGS ('dbx_standard' = 'CDISC');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `endpoint_id` SET TAGS ('dbx_business_glossary_term' = 'Endpoint Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `primary_sdtm_dataset_id` SET TAGS ('dbx_business_glossary_term' = 'SDTM Dataset Specification ID');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `primary_sdtm_dataset_id` SET TAGS ('dbx_implements' = 'SDTM.DOMAIN');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `primary_sdtm_dataset_id` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `reference_range_id` SET TAGS ('dbx_business_glossary_term' = 'Reference Range Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Sap Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `source_ecrf_field_id` SET TAGS ('dbx_business_glossary_term' = 'Source Ecrf Field Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `source_ecrf_form_id` SET TAGS ('dbx_business_glossary_term' = 'Source Ecrf Form Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study ID');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Study Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `approved_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Mapping Approval Timestamp');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `change_reason` SET TAGS ('dbx_business_glossary_term' = 'Mapping Change Reason');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `coding_dictionary` SET TAGS ('dbx_business_glossary_term' = 'Medical Coding Dictionary');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `coding_dictionary` SET TAGS ('dbx_value_regex' = 'MedDRA|WHO-DD|CTCAE|SNOMED-CT|ICD-10|none');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `coding_dictionary` SET TAGS ('dbx_licensed_dictionary' = 'structure_only; dictionary_licensed_by_customer; model_defines_structure_only');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `coding_dictionary_version` SET TAGS ('dbx_business_glossary_term' = 'Medical Coding Dictionary Version');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `coding_dictionary_version` SET TAGS ('dbx_licensed_dictionary' = 'structure_only; dictionary_licensed_by_customer; model_defines_structure_only');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `controlled_terminology_codelist` SET TAGS ('dbx_business_glossary_term' = 'CDISC Controlled Terminology Code List Name');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `ct_version` SET TAGS ('dbx_business_glossary_term' = 'Controlled Terminology (CT) Version');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `define_xml_comment` SET TAGS ('dbx_business_glossary_term' = 'Define-XML Comment');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `define_xml_origin` SET TAGS ('dbx_business_glossary_term' = 'Define-XML Origin');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `define_xml_origin` SET TAGS ('dbx_value_regex' = 'CRF|Derived|Assigned|Protocol|eDT|Predecessor');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `derivation_algorithm` SET TAGS ('dbx_business_glossary_term' = 'Derivation Algorithm / Transformation Logic');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `derivation_type` SET TAGS ('dbx_value_regex' = 'direct|derived|assigned|predecessor|computed|coded');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Mapping Effective End Date');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Mapping Effective Start Date');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `is_multi_source` SET TAGS ('dbx_business_glossary_term' = 'Multi-Source Derivation Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `is_predecessor_required` SET TAGS ('dbx_business_glossary_term' = 'Predecessor Dependency Required Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `is_sensitive_variable` SET TAGS ('dbx_business_glossary_term' = 'Sensitive Variable Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `mapping_rule_code` SET TAGS ('dbx_value_regex' = '^MAP-[A-Z]{2,8}-[A-Z0-9]{2,10}-[0-9]{4}$');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `mapping_status` SET TAGS ('dbx_business_glossary_term' = 'Mapping Rule Status');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `mapping_status` SET TAGS ('dbx_value_regex' = 'draft|in_review|approved|deprecated|superseded|on_hold');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `mapping_version` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Mapping Notes');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `predecessor_variable` SET TAGS ('dbx_business_glossary_term' = 'Predecessor SDTM Variable Dependency');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `reviewer_name` SET TAGS ('dbx_business_glossary_term' = 'Mapping Reviewer Name');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `reviewer_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_business_glossary_term' = 'SDTM Domain Code');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_implements' = 'SDTM.DOMAIN');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `sdtm_ig_version` SET TAGS ('dbx_business_glossary_term' = 'SDTM Implementation Guide (IG) Version');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `sdtm_ig_version` SET TAGS ('dbx_implements' = 'SDTMIG.version');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `sdtm_ig_version` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `sdtm_variable_core` SET TAGS ('dbx_business_glossary_term' = 'SDTM Variable Core Designation');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `sdtm_variable_core` SET TAGS ('dbx_value_regex' = 'Req|Exp|Perm');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `sdtm_variable_core` SET TAGS ('dbx_implements' = 'SDTMIG.Core');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `sdtm_variable_core` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `sdtm_variable_label` SET TAGS ('dbx_business_glossary_term' = 'SDTM Target Variable Label');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `sdtm_variable_label` SET TAGS ('dbx_implements' = 'SDTMIG.VariableLabel');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `sdtm_variable_label` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `sdtm_variable_name` SET TAGS ('dbx_business_glossary_term' = 'SDTM Target Variable Name');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `sdtm_variable_name` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,8}$');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `sdtm_variable_name` SET TAGS ('dbx_implements' = 'SDTMIG.VariableName');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `sdtm_variable_name` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `sdtm_variable_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `sdtm_variable_role` SET TAGS ('dbx_value_regex' = 'Identifier|Topic|Qualifier|Timing|Rule');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `sdtm_variable_role` SET TAGS ('dbx_implements' = 'SDTMIG.Role');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `sdtm_variable_role` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `sdtm_variable_type` SET TAGS ('dbx_business_glossary_term' = 'SDTM Variable Data Type');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `sdtm_variable_type` SET TAGS ('dbx_value_regex' = 'Char|Num');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `sdtm_variable_type` SET TAGS ('dbx_implements' = 'SDTMIG.Type');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `sdtm_variable_type` SET TAGS ('dbx_standard' = 'SDTM');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Mapping Sequence Number');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `source_dataset_name` SET TAGS ('dbx_business_glossary_term' = 'Source Raw Dataset Name');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `source_dataset_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `suppqual_flag` SET TAGS ('dbx_business_glossary_term' = 'Supplemental Qualifier (SUPPQUAL) Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `suppqual_qnam` SET TAGS ('dbx_business_glossary_term' = 'Supplemental Qualifier Variable Name (QNAM)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `suppqual_qnam` SET TAGS ('dbx_value_regex' = '^[A-Z]{1,8}$');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `validation_status` SET TAGS ('dbx_business_glossary_term' = 'Mapping Validation Status');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ALTER COLUMN `validation_status` SET TAGS ('dbx_value_regex' = 'not_validated|in_validation|passed|failed|waived');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ADD CONSTRAINT `fk_datamanagement_reconciliation_dmp_id` FOREIGN KEY (`dmp_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`dmp`(`dmp_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ADD CONSTRAINT `fk_datamanagement_reconciliation_ehr_data_transfer_id` FOREIGN KEY (`ehr_data_transfer_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`ehr_data_transfer`(`ehr_data_transfer_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` SET TAGS ('dbx_domain' = 'datamanagement');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` SET TAGS ('dbx_subdomain' = 'source_integration');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `accountability_reconciliation_id` SET TAGS ('dbx_business_glossary_term' = 'Accountability Reconciliation Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `audit_finding_id` SET TAGS ('dbx_business_glossary_term' = 'Audit Finding Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Consent Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `database_lock_event_id` SET TAGS ('dbx_business_glossary_term' = 'Biostatistics Dbl Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `destruction_record_id` SET TAGS ('dbx_business_glossary_term' = 'Destruction Record Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `dispensing_record_id` SET TAGS ('dbx_business_glossary_term' = 'External Transfer Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `dmp_id` SET TAGS ('dbx_business_glossary_term' = 'Dmp Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `document_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Document Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `ehr_data_transfer_id` SET TAGS ('dbx_business_glossary_term' = 'Ehr Data Transfer Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `lab_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Facility Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `protocol_deviation_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `return_record_id` SET TAGS ('dbx_business_glossary_term' = 'Return Record Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `shipment_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `specimen_shipment_id` SET TAGS ('dbx_business_glossary_term' = 'Specimen Shipment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Study Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `subject_randomization_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Randomization Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `workflow_id` SET TAGS ('dbx_business_glossary_term' = 'Workflow Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `capa_reference` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Reference');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `dataset_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `dbl_required` SET TAGS ('dbx_business_glossary_term' = 'Database Lock (DBL) Required Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `discrepancy_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Discrepancy Rate Percentage');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `escalation_required` SET TAGS ('dbx_business_glossary_term' = 'Escalation Required Flag');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `frequency` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Frequency');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `frequency` SET TAGS ('dbx_value_regex' = 'ad_hoc|weekly|monthly|quarterly|pre_dbl|milestone_based');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `method` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Method');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `method` SET TAGS ('dbx_value_regex' = 'manual|automated|semi_automated');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Notes');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `number` SET TAGS ('dbx_value_regex' = '^REC-[A-Z0-9]{3,10}-[0-9]{4,8}$');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `outstanding_count` SET TAGS ('dbx_business_glossary_term' = 'Outstanding Discrepancy Count');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `period_end` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Period End Date');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `period_start` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Period Start Date');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_value_regex' = 'pending|in_progress|completed|signed_off|failed|cancelled');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `reconciliation_type` SET TAGS ('dbx_value_regex' = 'central_lab|safety_database|irt_rtsm|epro|external_vendor|edc_internal');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `resolved_count` SET TAGS ('dbx_business_glossary_term' = 'Resolved Discrepancy Count');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `scope` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Scope');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `scope` SET TAGS ('dbx_value_regex' = 'full_study|site_level|subject_level|visit_level|dataset_level');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `signoff_by` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Sign-Off By');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `signoff_status` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Sign-Off Status');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `signoff_status` SET TAGS ('dbx_value_regex' = 'not_started|pending_review|approved|rejected');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `signoff_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Sign-Off Timestamp');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `tool` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Tool');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Version');

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ALTER COLUMN `waived_count` SET TAGS ('dbx_business_glossary_term' = 'Waived Discrepancy Count');
