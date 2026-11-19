-- Schema for Domain: terminology | Business: Clinical_Trials | Version: v2_ecm
-- Generated on: 2026-11-19 16:37:36

CREATE DATABASE IF NOT EXISTS `clinical_trials_ecm`.`terminology` COMMENT 'The terminology domain.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`terminology`.`code_system` (
    `code_system_id` BIGINT COMMENT 'Surrogate primary key for the code system table.',
    `regulatory_health_authority_id` BIGINT COMMENT 'Reference to regulatory.health_authority.health_authority_id.',
    `code_system_description` STRING COMMENT 'Description of the code system.',
    `effective_date` DATE COMMENT 'DATE - The date this code system version became effective or was published.',
    `code_system_name` STRING COMMENT 'Name of the coding dictionary.',
    `oid` STRING COMMENT 'OID / canonical URI of the code system.',
    `publisher` STRING COMMENT 'Organization publishing the dictionary.',
    CONSTRAINT pk_code_system PRIMARY KEY(`code_system_id`)
) COMMENT 'CDISC terminology code system registry entry (MedDRA, WHODrug, LOINC, SNOMED CT, CTCAE, ICD-10).';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`terminology`.`code_system_version` (
    `code_system_version_id` BIGINT COMMENT 'Surrogate primary key for the code system version table.',
    `code_system_id` BIGINT COMMENT 'Reference to terminology.code_system.code_system_id.',
    `package_identifier` STRING COMMENT 'Package identifier for the versioned release.',
    `package_version` STRING COMMENT 'Package / release identifier.',
    `release_date` DATE COMMENT 'Release date of this version.',
    `version_label` STRING COMMENT 'Version string e.g. MedDRA 26.1.',
    CONSTRAINT pk_code_system_version PRIMARY KEY(`code_system_version_id`)
) COMMENT 'Released version of a coding dictionary.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`terminology`.`meddra_soc` (
    `meddra_soc_id` BIGINT COMMENT 'Surrogate primary key for the meddra soc table.',
    `code_system_version_id` BIGINT COMMENT 'Reference to terminology.code_system_version.code_system_version_id.',
    `parent_meddra_soc_id` BIGINT COMMENT 'Reference to terminology.meddra_soc.meddra_soc_id.',
    `hierarchy_level` STRING COMMENT 'MedDRA hierarchy level = SOC.',
    `meddra_code` STRING COMMENT 'SOC numeric code.',
    `soc_code` STRING COMMENT 'MedDRA SOC code.',
    `soc_name` STRING COMMENT 'MedDRA System Organ Class name.',
    `term_name` STRING COMMENT 'SOC term name.',
    CONSTRAINT pk_meddra_soc PRIMARY KEY(`meddra_soc_id`)
) COMMENT 'System Organ Class - top level of the MedDRA hierarchy.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlgt` (
    `meddra_hlgt_id` BIGINT COMMENT 'Surrogate primary key for the meddra hlgt table.',
    `code_system_version_id` BIGINT COMMENT 'Reference to terminology.code_system_version.code_system_version_id.',
    `parent_meddra_soc_id` BIGINT COMMENT 'Parent MedDRA term.',
    `primary_meddra_soc_id` BIGINT COMMENT 'Parent SOC.',
    `hierarchy_level` STRING COMMENT 'MedDRA hierarchy level = HLGT.',
    `hlgt_code` STRING COMMENT 'MedDRA HLGT code.',
    `hlgt_name` STRING COMMENT 'MedDRA High Level Group Term name.',
    `meddra_code` STRING COMMENT 'HLGT numeric code.',
    `term_name` STRING COMMENT 'HLGT term name.',
    CONSTRAINT pk_meddra_hlgt PRIMARY KEY(`meddra_hlgt_id`)
) COMMENT 'High Level Group Term in the MedDRA hierarchy.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlt` (
    `meddra_hlt_id` BIGINT COMMENT 'Surrogate primary key for the meddra hlt table.',
    `code_system_version_id` BIGINT COMMENT 'Reference to terminology.code_system_version.code_system_version_id.',
    `parent_meddra_hlgt_id` BIGINT COMMENT 'Parent MedDRA term.',
    `primary_meddra_hlgt_id` BIGINT COMMENT 'Parent HLGT.',
    `hierarchy_level` STRING COMMENT 'MedDRA hierarchy level = HLT.',
    `hlt_code` STRING COMMENT 'MedDRA HLT code.',
    `hlt_name` STRING COMMENT 'MedDRA High Level Term name.',
    `meddra_code` STRING COMMENT 'HLT numeric code.',
    `term_name` STRING COMMENT 'HLT term name.',
    CONSTRAINT pk_meddra_hlt PRIMARY KEY(`meddra_hlt_id`)
) COMMENT 'High Level Term in the MedDRA hierarchy.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`terminology`.`meddra_pt` (
    `meddra_pt_id` BIGINT COMMENT 'Surrogate primary key for the meddra pt table.',
    `code_system_version_id` BIGINT COMMENT 'Reference to terminology.code_system_version.code_system_version_id.',
    `parent_meddra_hlt_id` BIGINT COMMENT 'Parent MedDRA term.',
    `primary_meddra_hlt_id` BIGINT COMMENT 'Parent HLT.',
    `primary_meddra_soc_id` BIGINT COMMENT 'Reference to terminology.meddra_soc.meddra_soc_id.',
    `hierarchy_level` STRING COMMENT 'MedDRA hierarchy level = PT.',
    `meddra_code` STRING COMMENT 'PT numeric code.',
    `pt_code` STRING COMMENT 'MedDRA PT code.',
    `pt_name` STRING COMMENT 'MedDRA Preferred Term name.',
    `term_name` STRING COMMENT 'PT term name.',
    CONSTRAINT pk_meddra_pt PRIMARY KEY(`meddra_pt_id`)
) COMMENT 'Preferred Term in the MedDRA hierarchy.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`terminology`.`meddra_llt` (
    `meddra_llt_id` BIGINT COMMENT 'Surrogate primary key for the meddra llt table.',
    `code_system_version_id` BIGINT COMMENT 'Reference to terminology.code_system_version.code_system_version_id.',
    `meddra_term_id` BIGINT COMMENT 'Reference to terminology.meddra_term.meddra_term_id.',
    `parent_meddra_pt_id` BIGINT COMMENT 'Parent MedDRA term.',
    `primary_meddra_pt_id` BIGINT COMMENT 'Parent PT.',
    `current_flag` BOOLEAN COMMENT 'Whether the LLT is current.',
    `hierarchy_level` STRING COMMENT 'MedDRA hierarchy level = LLT.',
    `llt_code` STRING COMMENT 'MedDRA LLT code.',
    `llt_name` STRING COMMENT 'MedDRA Lowest Level Term name.',
    `meddra_code` STRING COMMENT 'LLT numeric code.',
    `term_name` STRING COMMENT 'LLT term name.',
    CONSTRAINT pk_meddra_llt PRIMARY KEY(`meddra_llt_id`)
) COMMENT 'Lowest Level Term in the MedDRA hierarchy.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`terminology`.`meddra_smq` (
    `meddra_smq_id` BIGINT COMMENT 'Surrogate primary key for the meddra smq table.',
    `code_system_version_id` BIGINT COMMENT 'Reference to terminology.code_system_version.code_system_version_id.',
    `meddra_pt_id` BIGINT COMMENT 'Associated preferred term.',
    `parent_meddra_smq_alt_id` BIGINT COMMENT 'Alternate parent SMQ reference for hierarchical relationships (duplicate of parent_meddra_smq_id)',
    `parent_meddra_smq_id` BIGINT COMMENT 'Hierarchical parent SMQ reference',
    `smq_code` STRING COMMENT 'SMQ code.',
    `smq_level` STRING COMMENT 'SMQ level.',
    `smq_name` STRING COMMENT 'SMQ name.',
    `smq_scope` STRING COMMENT 'Narrow / broad scope.',
    CONSTRAINT pk_meddra_smq PRIMARY KEY(`meddra_smq_id`)
) COMMENT 'Standardised MedDRA Query (SMQ).';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`terminology`.`whodrug_drug_record` (
    `whodrug_drug_record_id` BIGINT COMMENT 'Surrogate primary key for the whodrug drug record table.',
    `code_system_version_id` BIGINT COMMENT 'Reference to terminology.code_system_version.code_system_version_id.',
    `primary_whodrug_atc_level4_id` BIGINT COMMENT 'description',
    `whodrug_preferred_name_id` BIGINT COMMENT 'Reference to terminology.whodrug_preferred_name.whodrug_preferred_name_id.',
    `whodrug_atc_level4_id` BIGINT COMMENT 'Reference to terminology.whodrug_atc_level4.whodrug_atc_level4_id.',
    `drug_record_number` STRING COMMENT 'WHODrug drug record number (DRN).',
    `ingredient` STRING COMMENT 'Active ingredient.',
    `trade_name` STRING COMMENT 'Trade / proprietary name.',
    CONSTRAINT pk_whodrug_drug_record PRIMARY KEY(`whodrug_drug_record_id`)
) COMMENT 'WHODrug Global drug record.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`terminology`.`whodrug_preferred_name` (
    `whodrug_preferred_name_id` BIGINT COMMENT 'Surrogate primary key for the whodrug preferred name table.',
    `code_system_version_id` BIGINT COMMENT 'Reference to terminology.code_system_version.code_system_version_id.',
    `whodrug_atc_id` BIGINT COMMENT 'ATC classification.',
    `whodrug_atc_level4_id` BIGINT COMMENT 'Reference to terminology.whodrug_atc_level4.whodrug_atc_level4_id.',
    `preferred_name` STRING COMMENT 'WHODrug preferred name.',
    `preferred_name_code` STRING COMMENT 'Preferred name code.',
    CONSTRAINT pk_whodrug_preferred_name PRIMARY KEY(`whodrug_preferred_name_id`)
) COMMENT 'WHODrug Global preferred name.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc` (
    `whodrug_atc_id` BIGINT COMMENT 'Surrogate primary key for the whodrug atc table.',
    `code_system_version_id` BIGINT COMMENT 'Reference to terminology.code_system_version.code_system_version_id.',
    `whodrug_atc_level1_id` BIGINT COMMENT 'Reference to terminology.whodrug_atc_level1.whodrug_atc_level1_id.',
    `atc_code` STRING COMMENT 'ATC code.',
    `atc_level1_code` STRING COMMENT 'ATC level 1 code.',
    `atc_level1_text` STRING COMMENT 'ATC level 1 text.',
    `atc_level2_code` STRING COMMENT 'ATC level 2 code.',
    `atc_level2_text` STRING COMMENT 'ATC level 2 text.',
    `atc_level3_code` STRING COMMENT 'ATC level 3 code.',
    `atc_level3_text` STRING COMMENT 'ATC level 3 text.',
    `atc_level4_code` STRING COMMENT 'ATC level 4 code.',
    `atc_level4_text` STRING COMMENT 'ATC level 4 text.',
    CONSTRAINT pk_whodrug_atc PRIMARY KEY(`whodrug_atc_id`)
) COMMENT 'WHODrug ATC classification levels 1-4.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`terminology`.`loinc` (
    `loinc_id` BIGINT COMMENT 'Surrogate primary key for the loinc table.',
    `code_system_version_id` BIGINT COMMENT 'Reference to terminology.code_system_version.code_system_version_id.',
    `loinc_code` STRING COMMENT 'LOINC code.',
    `component` STRING COMMENT 'LOINC component.',
    `long_common_name` STRING COMMENT 'LOINC long common name.',
    CONSTRAINT pk_loinc PRIMARY KEY(`loinc_id`)
) COMMENT 'LOINC laboratory and clinical observation codes.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`terminology`.`snomed_ct` (
    `snomed_ct_id` BIGINT COMMENT 'Surrogate primary key for the snomed ct table.',
    `code_system_version_id` BIGINT COMMENT 'Reference to terminology.code_system_version.code_system_version_id.',
    `parent_snomed_ct_alt_id` BIGINT COMMENT 'Alternate parent SNOMED CT concept for secondary hierarchy relationships',
    `parent_snomed_ct_id` BIGINT COMMENT 'Hierarchical parent SNOMED CT concept reference',
    `primary_snomed_ct_concept_id` BIGINT COMMENT 'SNOMED CT concept identifier.',
    `fully_specified_name` STRING COMMENT 'Fully specified name.',
    `preferred_term` STRING COMMENT 'Preferred term.',
    CONSTRAINT pk_snomed_ct PRIMARY KEY(`snomed_ct_id`)
) COMMENT 'SNOMED CT concepts.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`terminology`.`ctcae` (
    `ctcae_id` BIGINT COMMENT 'Surrogate primary key for the ctcae table.',
    `code_system_version_id` BIGINT COMMENT 'Reference to terminology.code_system_version.code_system_version_id.',
    `ctcae_grade_id` BIGINT COMMENT 'add column ctcae_grade_id (BIGINT) with FK to terminology.ctcae_grade.ctcae_grade_id — ctcae term should link to its grade definitions',
    `meddra_pt_id` BIGINT COMMENT 'Associated MedDRA PT.',
    `meddra_soc_id` BIGINT COMMENT 'MedDRA SOC the CTCAE term maps to.',
    `ctcae_code` STRING COMMENT 'CTCAE code.',
    `grade` BIGINT COMMENT 'CTCAE grade 1-5.',
    `grade_description` STRING COMMENT 'Grade description.',
    `term` STRING COMMENT 'CTCAE term.',
    CONSTRAINT pk_ctcae PRIMARY KEY(`ctcae_id`)
) COMMENT 'CTCAE adverse event terms and grades.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`terminology`.`whodrug_record` (
    `whodrug_record_id` BIGINT COMMENT 'Surrogate key for the WHODrug record.',
    `code_system_version_id` BIGINT COMMENT 'WHODrug version.',
    `primary_whodrug_atc_level4_id` BIGINT COMMENT 'add column whodrug_atc_level4_id (BIGINT) with FK to terminology.whodrug_atc_level4.whodrug_atc_level4_id — whodrug_record should link to most specific ATC level',
    `tertiary_whodrug_atc_level4_id` BIGINT COMMENT 'Foreign key to ATC level 4 classification',
    `whodrug_drug_record_id` BIGINT COMMENT 'WHODrug medicinal product identifier.',
    `whodrug_preferred_name_id` BIGINT COMMENT 'Associated preferred name.',
    `secondary_whodrug_atc_level4_id` BIGINT COMMENT 'Reference to terminology.whodrug_atc_level4.whodrug_atc_level4_id.',
    `drug_record_number` STRING COMMENT 'WHODrug drug record number.',
    `trade_name` STRING COMMENT 'WHODrug trade name.',
    CONSTRAINT pk_whodrug_record PRIMARY KEY(`whodrug_record_id`)
) COMMENT 'WHODrug Global drug record.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`terminology`.`meddra_term` (
    `meddra_term_id` BIGINT COMMENT 'Surrogate key for MedDRA term.',
    `code_system_version_id` BIGINT COMMENT 'MedDRA version used.',
    `meddra_pt_id` BIGINT COMMENT 'Reference to terminology.meddra_pt.meddra_pt_id.',
    `meddra_code` STRING COMMENT 'MedDRA code.',
    `preferred_term` STRING COMMENT 'MedDRA preferred term.',
    CONSTRAINT pk_meddra_term PRIMARY KEY(`meddra_term_id`)
) COMMENT 'MedDRA term (relocated from safety; terminology is the single owner).';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`terminology`.`ctcae_grade` (
    `ctcae_grade_id` BIGINT COMMENT 'Surrogate key for CTCAE grade.',
    `code_system_version_id` BIGINT COMMENT 'CTCAE version.',
    `ctcae_term` STRING COMMENT 'CTCAE term.',
    `grade` BIGINT COMMENT 'CTCAE grade value.',
    CONSTRAINT pk_ctcae_grade PRIMARY KEY(`ctcae_grade_id`)
) COMMENT 'CTCAE grade (relocated from safety; terminology is the single owner).';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_classification` (
    `whodrug_atc_classification_id` BIGINT COMMENT 'Surrogate key.',
    `whodrug_atc_level4_id` BIGINT COMMENT 'Reference to terminology.whodrug_atc_level4.whodrug_atc_level4_id.',
    `whodrug_drug_record_id` BIGINT COMMENT 'Parent drug record.',
    `atc_level_1_code` STRING COMMENT 'ATC level 1 code.',
    `atc_level_2_code` STRING COMMENT 'ATC level 2 code.',
    `atc_level_3_code` STRING COMMENT 'ATC level 3 code.',
    `atc_level_4_code` STRING COMMENT 'ATC level 4 code.',
    CONSTRAINT pk_whodrug_atc_classification PRIMARY KEY(`whodrug_atc_classification_id`)
) COMMENT 'WHODrug ATC classification levels 1 to 4.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`terminology`.`loinc_code` (
    `loinc_code_id` BIGINT COMMENT 'Surrogate key.',
    `code_system_version_id` BIGINT COMMENT 'Dictionary version.',
    `loinc_id` BIGINT COMMENT 'add column loinc_id (BIGINT) with FK to terminology.loinc.loinc_id — loinc_code should link to loinc for consistency',
    `loinc_code_code` STRING COMMENT 'Code value.',
    `term_name` STRING COMMENT 'Term/description.',
    CONSTRAINT pk_loinc_code PRIMARY KEY(`loinc_code_id`)
) COMMENT 'LOINC code.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`terminology`.`snomed_ct_concept` (
    `snomed_ct_concept_id` BIGINT COMMENT 'Surrogate key.',
    `code_system_version_id` BIGINT COMMENT 'Dictionary version.',
    `snomed_ct_concept_code` STRING COMMENT 'Code value.',
    `term_name` STRING COMMENT 'Term/description.',
    CONSTRAINT pk_snomed_ct_concept PRIMARY KEY(`snomed_ct_concept_id`)
) COMMENT 'SNOMED CT concept.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`terminology`.`ctcae_term_catalog` (
    `ctcae_term_catalog_id` BIGINT COMMENT 'Surrogate key.',
    `code_system_version_id` BIGINT COMMENT 'Dictionary version.',
    `ctcae_id` BIGINT COMMENT 'add column ctcae_id (BIGINT) with FK to terminology.ctcae.ctcae_id — ctcae_term_catalog should reference the main ctcae product',
    `ctcae_term_catalog_code` STRING COMMENT 'Code value.',
    `term_name` STRING COMMENT 'Term/description.',
    CONSTRAINT pk_ctcae_term_catalog PRIMARY KEY(`ctcae_term_catalog_id`)
) COMMENT 'CTCAE term catalog entry.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`terminology`.`icd10_code` (
    `icd10_code_id` BIGINT COMMENT 'Surrogate key.',
    `code_system_version_id` BIGINT COMMENT 'Dictionary version.',
    `icd_id` BIGINT COMMENT 'Foreign key to ICD-10 terminology system',
    `parent_icd10_code_alt_id` BIGINT COMMENT 'Alternate parent ICD-10 code reference for hierarchical relationships (duplicate of parent_icd10_code_id)',
    `parent_icd10_code_id` BIGINT COMMENT 'Foreign key to parent ICD-10 code for hierarchical classification',
    `icd10_code_code` STRING COMMENT 'Code value.',
    `term_name` STRING COMMENT 'Term/description.',
    CONSTRAINT pk_icd10_code PRIMARY KEY(`icd10_code_id`)
) COMMENT 'ICD-10 code.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`terminology`.`terminology_codelist` (
    `terminology_codelist_id` BIGINT COMMENT 'Primary key for terminology_codelist',
    `code_system_id` BIGINT COMMENT 'add column code_system_id (BIGINT) with FK to terminology.code_system.code_system_id — terminology.terminology_codelist has zero outbound FKs and only inbound from terminology_codelist_term; it should reference the code_system it belongs to',
    `codelist_description` STRING COMMENT 'STRING',
    `codelist_oid` STRING COMMENT 'STRING',
    `codelist_version` STRING COMMENT 'STRING',
    `terminology_codelist_description` STRING COMMENT 'STRING',
    `submission_value` DECIMAL(18,2) COMMENT 'STRING',
    `version` STRING COMMENT 'STRING',
    CONSTRAINT pk_terminology_codelist PRIMARY KEY(`terminology_codelist_id`)
) COMMENT 'CDISC Controlled Terminology codelist';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`terminology`.`terminology_codelist_term` (
    `terminology_codelist_term_id` BIGINT COMMENT 'Primary key for terminology_codelist_term',
    `parent_terminology_codelist_id` BIGINT COMMENT 'Reference to terminology.terminology_codelist.terminology_codelist_id.',
    `primary_terminology_codelist_id` BIGINT COMMENT 'BIGINT',
    `c_code` STRING COMMENT 'STRING',
    `terminology_codelist_term_description` STRING COMMENT 'STRING',
    `preferred_term` STRING COMMENT 'STRING',
    `submission_value` DECIMAL(18,2) COMMENT 'STRING',
    `synonym` STRING COMMENT 'STRING',
    `synonyms` STRING COMMENT 'STRING',
    `term_code` BIGINT COMMENT 'BIGINT',
    `term_description` STRING COMMENT 'STRING',
    CONSTRAINT pk_terminology_codelist_term PRIMARY KEY(`terminology_codelist_term_id`)
) COMMENT 'CDISC Controlled Terminology codelist term';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level1` (
    `whodrug_atc_level1_id` BIGINT COMMENT 'Primary key for whodrug_atc_level1',
    `code_system_version_id` BIGINT COMMENT 'Foreign key linking to terminology.code_system_version. Business justification: Like every other coding-dictionary table in this domain (loinc, snomed_ct, ctcae, meddra_*, etc.), the top ATC level belongs to a released dictionary version.',
    `anatomical_main_group` STRING COMMENT 'Descriptive label of the anatomical main group (organ or system on which the drug acts) that this ATC level 1 classification represents.',
    `atc_classification_system` STRING COMMENT 'Name of the classification system that governs this term, identifying it as the WHO Anatomical Therapeutic Chemical classification.',
    `atc_level1_code` STRING COMMENT 'Single-letter code representing the anatomical main group in the WHO Anatomical Therapeutic Chemical classification (e.g., A, B, C).',
    `atc_level1_name` STRING COMMENT 'Official textual name of the anatomical main group corresponding to the ATC level 1 code (e.g., Alimentary tract and metabolism).',
    `code_description` STRING COMMENT 'Extended descriptive text explaining the scope and therapeutic grouping covered by this ATC level 1 anatomical main group.',
    `effective_from_date` DATE COMMENT 'Date on which this ATC level 1 classification term became effective in the referenced dictionary version.',
    `effective_until_date` DATE COMMENT 'Date on which this ATC level 1 classification term ceased to be effective; null for currently active terms.',
    `language_code` STRING COMMENT 'ISO 639-1 two-letter language code indicating the language of the ATC level 1 name and description text.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this ATC level 1 terminology record was first captured into the clinical data repository.',
    `record_status` STRING COMMENT 'Lifecycle status of this ATC level 1 terminology record within the maintained dictionary.',
    `source_authority` STRING COMMENT 'Organization responsible for assigning and maintaining this ATC classification term, typically the WHO Collaborating Centre for Drug Statistics Methodology.',
    `whodrug_dictionary_version` STRING COMMENT 'Version of the WHODrug Global dictionary release from which this ATC level 1 term was sourced (e.g., WHODrug B3 format March 2024).',
    CONSTRAINT pk_whodrug_atc_level1 PRIMARY KEY(`whodrug_atc_level1_id`)
) COMMENT 'WHODrug ATC classification level 1';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level2` (
    `whodrug_atc_level2_id` BIGINT COMMENT 'Primary key for whodrug_atc_level2',
    `whodrug_atc_level1_id` BIGINT COMMENT 'Foreign key linking to terminology.whodrug_atc_level1. Business justification: ATC level 2 (therapeutic subgroup) rolls up to one ATC level 1 (anatomical main group). Child-to-parent FK connects the siloed whodrug_atc_level1 and whodrug_atc_level2 tables.',
    `atc_classification_hierarchy_level` BIGINT COMMENT 'Numeric depth of this record within the five-level ATC hierarchy; fixed at 2 for therapeutic subgroup entries.',
    `atc_language_code` STRING COMMENT 'ISO 639-1 two-letter language code indicating the language of the therapeutic subgroup name and description (e.g., en).',
    `atc_level2_code` STRING COMMENT 'The official three-character ATC Level 2 code denoting the therapeutic subgroup (one anatomical main group letter followed by two therapeutic digits, e.g., C03).',
    `atc_level2_name` STRING COMMENT 'Human-readable name/description of the ATC Level 2 therapeutic subgroup (e.g., Diuretics).',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this ATC Level 2 classification record was first captured in the terminology repository.',
    `effective_from_date` DATE COMMENT 'Date from which this ATC Level 2 classification entry becomes valid and usable for drug coding.',
    `effective_until_date` DATE COMMENT 'Date on which this ATC Level 2 classification entry ceases to be valid; null for currently active entries.',
    `is_official_who_assigned` BOOLEAN COMMENT 'Indicates whether this ATC Level 2 code was officially assigned by the WHO Collaborating Centre (true) versus a provisional or sponsor-assigned classification (false).',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this ATC Level 2 classification record was last updated in the terminology repository.',
    `record_status` STRING COMMENT 'Current lifecycle status of this ATC Level 2 classification entry within the dictionary version.',
    `revision_note` STRING COMMENT 'Free-text note describing changes applied to this ATC Level 2 entry in the current dictionary release (e.g., name change, code reclassification).',
    `sort_order` BIGINT COMMENT 'Numeric ordering value used to present ATC Level 2 subgroups in canonical sequence within their parent anatomical main group.',
    `superseded_by_atc_level2_code` STRING COMMENT 'The ATC Level 2 code that replaces this entry when it has been reclassified or merged; null if not superseded.',
    `therapeutic_subgroup_description` STRING COMMENT 'Extended descriptive text explaining the scope and intended therapeutic use of medicinal products classified under this ATC Level 2 subgroup.',
    `whodrug_dictionary_version` STRING COMMENT 'The WHODrug Global dictionary release version in which this ATC Level 2 classification entry is valid (e.g., GLB202401 / version/date identifier).',
    CONSTRAINT pk_whodrug_atc_level2 PRIMARY KEY(`whodrug_atc_level2_id`)
) COMMENT 'WHODrug ATC classification level 2';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level3` (
    `whodrug_atc_level3_id` BIGINT COMMENT 'Primary key for whodrug_atc_level3',
    `whodrug_atc_level2_id` BIGINT COMMENT 'Foreign key linking to terminology.whodrug_atc_level2. Business justification: ATC level 3 (pharmacological subgroup) rolls up to one ATC level 2. Child-to-parent FK.',
    `atc_code_hierarchy_path` STRING COMMENT 'The concatenated ancestry path of ATC codes from level 1 through level 3 (e.g., A>A01>A01A) enabling hierarchical navigation.',
    `atc_level3_code` STRING COMMENT 'The externally recognized Anatomical Therapeutic Chemical (ATC) level 3 code identifying the therapeutic/pharmacological subgroup (e.g., A01A).',
    `atc_level3_name` STRING COMMENT 'The human-readable textual description of the therapeutic/pharmacological subgroup represented by the ATC level 3 code.',
    `atc_level_number` BIGINT COMMENT 'The numeric depth of this record within the ATC hierarchy; fixed to 3 for the therapeutic/pharmacological subgroup level.',
    `coding_notes` STRING COMMENT 'Free-text guidance or usage notes supporting consistent coding and interpretation of this ATC level 3 therapeutic subgroup.',
    `dictionary_format_type` STRING COMMENT 'The WHODrug dictionary format in which the ATC classification is distributed, such as the B2, B3, or C3 format.',
    `dictionary_version` STRING COMMENT 'The WHODrug Global dictionary release version (e.g., WHODrug B3 Mar 1, 2024) under which this ATC level 3 entry is published.',
    `language_code` STRING COMMENT 'The ISO 639-1 two-letter language code in which the ATC level 3 name is expressed, supporting multilingual dictionary variants.',
    `medicinal_product_count` BIGINT COMMENT 'The number of WHODrug medicinal products classified under this ATC level 3 subgroup within the current dictionary version.',
    `record_created_timestamp` TIMESTAMP COMMENT 'The timestamp when this ATC level 3 classification record was first captured in the terminology reference store.',
    `record_status` STRING COMMENT 'The lifecycle state of this ATC level 3 classification entry within the terminology store, indicating whether it is current, retired, or provisional.',
    `valid_from_date` DATE COMMENT 'The date from which this ATC level 3 classification entry becomes effective within the referenced dictionary version.',
    `valid_until_date` DATE COMMENT 'The date on which this ATC level 3 classification entry ceases to be effective; null when the entry remains current.',
    CONSTRAINT pk_whodrug_atc_level3 PRIMARY KEY(`whodrug_atc_level3_id`)
) COMMENT 'WHODrug ATC classification level 3';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level4` (
    `whodrug_atc_level4_id` BIGINT COMMENT 'Primary key for whodrug_atc_level4',
    `whodrug_atc_level3_id` BIGINT COMMENT 'Foreign key linking to terminology.whodrug_atc_level3. Business justification: ATC level 4 (chemical subgroup) rolls up to one ATC level 3. Child-to-parent FK completes the ATC hierarchy ladder.',
    `atc_code` STRING COMMENT 'The 5-character ATC classification level 4 (chemical/therapeutic/pharmacological subgroup) code assigned by the WHO Collaborating Centre, e.g. C09AA.',
    `atc_level_number` BIGINT COMMENT 'Numeric depth of this classification node within the ATC hierarchy; constant value of 4 for level 4 chemical/pharmacological subgroups.',
    `cdisc_submission_value` DECIMAL(18,2) COMMENT 'CDISC-aligned submission value or mapping used when the ATC level 4 term is referenced in regulatory CDISC SDTM concomitant medication datasets.',
    `classification_source` STRING COMMENT 'Authoritative source that assigned or maintains this ATC level 4 classification entry.',
    `deprecated_flag` BOOLEAN COMMENT 'Indicates whether this ATC level 4 classification code has been deprecated and should no longer be used for new coding.',
    `dictionary_format` STRING COMMENT 'WHODrug file format in which the dictionary was delivered, such as B3 or C3, affecting the structure of the ATC hierarchy records.',
    `dictionary_name` STRING COMMENT 'Name of the WHODrug dictionary product/edition from which this ATC level 4 classification record was sourced.',
    `dictionary_version` STRING COMMENT 'Version identifier of the WHODrug dictionary release (e.g. biannual version such as MAR2024) that this ATC level 4 record belongs to.',
    `drug_record_number` STRING COMMENT 'WHODrug drug record number (DRN) association reference used to connect medicinal products to this ATC level 4 classification node.',
    `effective_from_date` DATE COMMENT 'Date from which this ATC level 4 classification entry becomes valid for use in medication coding within clinical trials.',
    `effective_until_date` DATE COMMENT 'Date on which this ATC level 4 classification entry ceases to be valid; null for currently active entries.',
    `level4_name` STRING COMMENT 'Human-readable name/text of the ATC level 4 chemical, therapeutic or pharmacological subgroup associated with the ATC code.',
    `record_status` STRING COMMENT 'Lifecycle status of the ATC level 4 terminology record indicating whether it is currently valid for coding or has been retired/superseded.',
    `source_release_date` DATE COMMENT 'Official release date of the WHODrug dictionary version from which this ATC level 4 record was ingested.',
    `whodrug_code` STRING COMMENT 'The WHODrug Global internal code linking the ATC level 4 subgroup to the WHODrug dictionary structure for coded medication data in clinical trials.',
    CONSTRAINT pk_whodrug_atc_level4 PRIMARY KEY(`whodrug_atc_level4_id`)
) COMMENT 'WHODrug ATC classification level 4';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`terminology`.`plus` (
    `plus_id` BIGINT COMMENT 'Surrogate primary key for the plus table.',
    `code_system_version_id` BIGINT COMMENT 'Reference to terminology.code_system_version.code_system_version_id.',
    `loinc_id` BIGINT COMMENT 'add column loinc_id (BIGINT) with FK to terminology.loinc.loinc_id — terminology.plus has only one outbound FK to code_system_version and zero inbound FKs, making it effectively isolated; it should reference the LOINC concept it extends',
    `effective_date` DATE COMMENT 'Business-effective date for this plus record.',
    `notes` STRING COMMENT 'Free-text notes.',
    `plus_status` STRING COMMENT 'Lifecycle status of this plus record.',
    CONSTRAINT pk_plus PRIMARY KEY(`plus_id`)
) COMMENT 'Reviewer-directed plus table.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`terminology`.`whodrug` (
    `whodrug_id` BIGINT COMMENT 'Surrogate primary key for the whodrug table.',
    `code_system_version_id` BIGINT COMMENT 'add column code_system_version_id (BIGINT) with FK to terminology.code_system_version.code_system_version_id — terminology.whodrug references whodrug_drug_record and whodrug_preferred_name but has zero inbound FKs, making it effectively iso',
    `whodrug_drug_record_id` BIGINT COMMENT 'Reference to terminology.whodrug_drug_record.whodrug_drug_record_id.',
    `whodrug_preferred_name_id` BIGINT COMMENT 'Reference to terminology.whodrug_preferred_name.whodrug_preferred_name_id.',
    `effective_date` DATE COMMENT 'Business-effective date for this whodrug record.',
    `notes` STRING COMMENT 'Free-text notes.',
    `whodrug_status` STRING COMMENT 'Lifecycle status of this whodrug record.',
    CONSTRAINT pk_whodrug PRIMARY KEY(`whodrug_id`)
) COMMENT 'Reviewer-directed whodrug table.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`terminology`.`snomed` (
    `snomed_id` BIGINT COMMENT 'Surrogate primary key for the snomed table.',
    `code_system_version_id` BIGINT COMMENT 'add column code_system_version_id (BIGINT) with FK to terminology.code_system_version.code_system_version_id — terminology.snomed references snomed_ct and snomed_ct_concept but has zero inbound FKs, making it effectively isolated',
    `snomed_ct_concept_id` BIGINT COMMENT 'Reference to terminology.snomed_ct_concept.snomed_ct_concept_id.',
    `snomed_ct_id` BIGINT COMMENT 'Reference to terminology.snomed_ct.snomed_ct_id.',
    `effective_date` DATE COMMENT 'Business-effective date for this snomed record.',
    `notes` STRING COMMENT 'Free-text notes.',
    `snomed_status` STRING COMMENT 'Lifecycle status of this snomed record.',
    CONSTRAINT pk_snomed PRIMARY KEY(`snomed_id`)
) COMMENT 'Reviewer-directed snomed table.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`terminology`.`icd` (
    `icd_id` BIGINT COMMENT 'Surrogate primary key for the icd table.',
    `code_system_version_id` BIGINT COMMENT 'add column code_system_version_id (BIGINT) with FK to terminology.code_system_version.code_system_version_id — terminology.icd is isolated with zero outbound and zero inbound FKs (icd10_code references terminology.icd but the listing shows',
    `effective_date` DATE COMMENT 'Business-effective date for this icd record.',
    `notes` STRING COMMENT 'Free-text notes.',
    `icd_status` STRING COMMENT 'Lifecycle status of this icd record.',
    CONSTRAINT pk_icd PRIMARY KEY(`icd_id`)
) COMMENT 'Reviewer-directed icd table.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`terminology`.`anything` (
    `anything_id` BIGINT COMMENT 'Surrogate primary key for the anything table.',
    `code_system_version_id` BIGINT COMMENT 'add column code_system_version_id (BIGINT) with FK to terminology.code_system_version.code_system_version_id — terminology.anything references only code_system but has zero inbound FKs, making it isolated; needs a version reference or shoul',
    `effective_date` DATE COMMENT 'Business-effective date for this anything record.',
    `notes` STRING COMMENT 'Free-text notes.',
    `anything_status` STRING COMMENT 'Lifecycle status of this anything record.',
    CONSTRAINT pk_anything PRIMARY KEY(`anything_id`)
) COMMENT 'Reviewer-directed anything table.';

ALTER SCHEMA `clinical_trials_ecm`.`terminology` SET TAGS ('dbx_division' = 'business');

ALTER SCHEMA `clinical_trials_ecm`.`terminology` SET TAGS ('dbx_domain' = 'terminology');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`code_system` ADD CONSTRAINT `fk_terminology_code_system_regulatory_health_authority_id` FOREIGN KEY (`regulatory_health_authority_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`code_system` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`code_system` SET TAGS ('dbx_domain' = 'terminology');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`code_system` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`code_system` SET TAGS ('dbx_subdomain' = 'dictionary_registry');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`code_system` ALTER COLUMN `code_system_id` SET TAGS ('dbx_pk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`code_system` ALTER COLUMN `code_system_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`code_system` ALTER COLUMN `oid` SET TAGS ('dbx_standard' = 'CDISC Define-XML; element:CodeSystem.oid');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`code_system_version` ADD CONSTRAINT `fk_terminology_code_system_version_code_system_id` FOREIGN KEY (`code_system_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system`(`code_system_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`code_system_version` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`code_system_version` SET TAGS ('dbx_domain' = 'terminology');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`code_system_version` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`code_system_version` SET TAGS ('dbx_subdomain' = 'dictionary_registry');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`code_system_version` ALTER COLUMN `code_system_version_id` SET TAGS ('dbx_pk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`code_system_version` ALTER COLUMN `code_system_id` SET TAGS ('dbx_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`code_system_version` ALTER COLUMN `package_identifier` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`code_system_version` ALTER COLUMN `package_version` SET TAGS ('dbx_standard' = 'CDISC CT; element:CodeSystemVersion.packageVersion');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`code_system_version` ALTER COLUMN `package_version` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`code_system_version` ALTER COLUMN `release_date` SET TAGS ('dbx_standard' = 'CDISC CT; element:CodeSystemVersion.releaseDate');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_soc` ADD CONSTRAINT `fk_terminology_meddra_soc_code_system_version_id` FOREIGN KEY (`code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_soc` ADD CONSTRAINT `fk_terminology_meddra_soc_parent_meddra_soc_id` FOREIGN KEY (`parent_meddra_soc_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`meddra_soc`(`meddra_soc_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_soc` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_soc` SET TAGS ('dbx_domain' = 'terminology');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_soc` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_soc` SET TAGS ('dbx_subdomain' = 'medical_coding');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_soc` ALTER COLUMN `meddra_soc_id` SET TAGS ('dbx_pk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_soc` ALTER COLUMN `code_system_version_id` SET TAGS ('dbx_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_soc` ALTER COLUMN `parent_meddra_soc_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_soc` ALTER COLUMN `parent_meddra_soc_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_soc` ALTER COLUMN `meddra_code` SET TAGS ('dbx_standard' = 'MedDRA; element:SOC.code');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_soc` ALTER COLUMN `soc_code` SET TAGS ('dbx_standard' = 'MedDRA; element:SOC.socCode');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_soc` ALTER COLUMN `soc_name` SET TAGS ('dbx_standard' = 'MedDRA; element:SOC.socName');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_soc` ALTER COLUMN `soc_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_soc` ALTER COLUMN `term_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlgt` ADD CONSTRAINT `fk_terminology_meddra_hlgt_code_system_version_id` FOREIGN KEY (`code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlgt` ADD CONSTRAINT `fk_terminology_meddra_hlgt_parent_meddra_soc_id` FOREIGN KEY (`parent_meddra_soc_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`meddra_soc`(`meddra_soc_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlgt` ADD CONSTRAINT `fk_terminology_meddra_hlgt_primary_meddra_soc_id` FOREIGN KEY (`primary_meddra_soc_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`meddra_soc`(`meddra_soc_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlgt` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlgt` SET TAGS ('dbx_domain' = 'terminology');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlgt` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlgt` SET TAGS ('dbx_subdomain' = 'medical_coding');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlgt` ALTER COLUMN `meddra_hlgt_id` SET TAGS ('dbx_pk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlgt` ALTER COLUMN `code_system_version_id` SET TAGS ('dbx_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlgt` ALTER COLUMN `parent_meddra_soc_id` SET TAGS ('dbx_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlgt` ALTER COLUMN `parent_meddra_soc_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlgt` ALTER COLUMN `parent_meddra_soc_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlgt` ALTER COLUMN `primary_meddra_soc_id` SET TAGS ('dbx_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlgt` ALTER COLUMN `primary_meddra_soc_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlgt` ALTER COLUMN `primary_meddra_soc_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlgt` ALTER COLUMN `hlgt_code` SET TAGS ('dbx_standard' = 'MedDRA; element:HLGT.hlgtCode');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlgt` ALTER COLUMN `hlgt_name` SET TAGS ('dbx_standard' = 'MedDRA; element:HLGT.hlgtName');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlgt` ALTER COLUMN `hlgt_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlgt` ALTER COLUMN `term_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlt` ADD CONSTRAINT `fk_terminology_meddra_hlt_code_system_version_id` FOREIGN KEY (`code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlt` ADD CONSTRAINT `fk_terminology_meddra_hlt_parent_meddra_hlgt_id` FOREIGN KEY (`parent_meddra_hlgt_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`meddra_hlgt`(`meddra_hlgt_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlt` ADD CONSTRAINT `fk_terminology_meddra_hlt_primary_meddra_hlgt_id` FOREIGN KEY (`primary_meddra_hlgt_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`meddra_hlgt`(`meddra_hlgt_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlt` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlt` SET TAGS ('dbx_domain' = 'terminology');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlt` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlt` SET TAGS ('dbx_subdomain' = 'medical_coding');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlt` ALTER COLUMN `meddra_hlt_id` SET TAGS ('dbx_pk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlt` ALTER COLUMN `code_system_version_id` SET TAGS ('dbx_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlt` ALTER COLUMN `parent_meddra_hlgt_id` SET TAGS ('dbx_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlt` ALTER COLUMN `parent_meddra_hlgt_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlt` ALTER COLUMN `parent_meddra_hlgt_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlt` ALTER COLUMN `primary_meddra_hlgt_id` SET TAGS ('dbx_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlt` ALTER COLUMN `primary_meddra_hlgt_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlt` ALTER COLUMN `primary_meddra_hlgt_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlt` ALTER COLUMN `hlt_code` SET TAGS ('dbx_standard' = 'MedDRA; element:HLT.hltCode');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlt` ALTER COLUMN `hlt_name` SET TAGS ('dbx_standard' = 'MedDRA; element:HLT.hltName');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlt` ALTER COLUMN `hlt_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_hlt` ALTER COLUMN `term_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_pt` ADD CONSTRAINT `fk_terminology_meddra_pt_code_system_version_id` FOREIGN KEY (`code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_pt` ADD CONSTRAINT `fk_terminology_meddra_pt_parent_meddra_hlt_id` FOREIGN KEY (`parent_meddra_hlt_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`meddra_hlt`(`meddra_hlt_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_pt` ADD CONSTRAINT `fk_terminology_meddra_pt_primary_meddra_hlt_id` FOREIGN KEY (`primary_meddra_hlt_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`meddra_hlt`(`meddra_hlt_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_pt` ADD CONSTRAINT `fk_terminology_meddra_pt_primary_meddra_soc_id` FOREIGN KEY (`primary_meddra_soc_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`meddra_soc`(`meddra_soc_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_pt` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_pt` SET TAGS ('dbx_domain' = 'terminology');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_pt` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_pt` SET TAGS ('dbx_subdomain' = 'medical_coding');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_pt` ALTER COLUMN `meddra_pt_id` SET TAGS ('dbx_pk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_pt` ALTER COLUMN `code_system_version_id` SET TAGS ('dbx_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_pt` ALTER COLUMN `parent_meddra_hlt_id` SET TAGS ('dbx_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_pt` ALTER COLUMN `parent_meddra_hlt_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_pt` ALTER COLUMN `parent_meddra_hlt_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_pt` ALTER COLUMN `primary_meddra_hlt_id` SET TAGS ('dbx_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_pt` ALTER COLUMN `primary_meddra_hlt_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_pt` ALTER COLUMN `primary_meddra_hlt_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_pt` ALTER COLUMN `primary_meddra_soc_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_pt` ALTER COLUMN `primary_meddra_soc_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_pt` ALTER COLUMN `pt_code` SET TAGS ('dbx_standard' = 'MedDRA; element:PT.ptCode');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_pt` ALTER COLUMN `pt_name` SET TAGS ('dbx_standard' = 'MedDRA; element:PT.ptName');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_pt` ALTER COLUMN `pt_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_pt` ALTER COLUMN `term_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_llt` ADD CONSTRAINT `fk_terminology_meddra_llt_code_system_version_id` FOREIGN KEY (`code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_llt` ADD CONSTRAINT `fk_terminology_meddra_llt_meddra_term_id` FOREIGN KEY (`meddra_term_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`meddra_term`(`meddra_term_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_llt` ADD CONSTRAINT `fk_terminology_meddra_llt_parent_meddra_pt_id` FOREIGN KEY (`parent_meddra_pt_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`meddra_pt`(`meddra_pt_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_llt` ADD CONSTRAINT `fk_terminology_meddra_llt_primary_meddra_pt_id` FOREIGN KEY (`primary_meddra_pt_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`meddra_pt`(`meddra_pt_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_llt` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_llt` SET TAGS ('dbx_domain' = 'terminology');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_llt` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_llt` SET TAGS ('dbx_subdomain' = 'medical_coding');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_llt` ALTER COLUMN `meddra_llt_id` SET TAGS ('dbx_pk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_llt` ALTER COLUMN `code_system_version_id` SET TAGS ('dbx_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_llt` ALTER COLUMN `meddra_term_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_llt` ALTER COLUMN `meddra_term_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_llt` ALTER COLUMN `parent_meddra_pt_id` SET TAGS ('dbx_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_llt` ALTER COLUMN `parent_meddra_pt_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_llt` ALTER COLUMN `parent_meddra_pt_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_llt` ALTER COLUMN `primary_meddra_pt_id` SET TAGS ('dbx_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_llt` ALTER COLUMN `primary_meddra_pt_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_llt` ALTER COLUMN `primary_meddra_pt_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_llt` ALTER COLUMN `current_flag` SET TAGS ('dbx_standard' = 'MedDRA; element:LLT.lltCurrency');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_llt` ALTER COLUMN `llt_code` SET TAGS ('dbx_standard' = 'MedDRA; element:LLT.lltCode');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_llt` ALTER COLUMN `llt_name` SET TAGS ('dbx_standard' = 'MedDRA; element:LLT.lltName');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_llt` ALTER COLUMN `llt_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_llt` ALTER COLUMN `term_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_smq` ADD CONSTRAINT `fk_terminology_meddra_smq_code_system_version_id` FOREIGN KEY (`code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_smq` ADD CONSTRAINT `fk_terminology_meddra_smq_meddra_pt_id` FOREIGN KEY (`meddra_pt_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`meddra_pt`(`meddra_pt_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_smq` ADD CONSTRAINT `fk_terminology_meddra_smq_parent_meddra_smq_alt_id` FOREIGN KEY (`parent_meddra_smq_alt_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`meddra_smq`(`meddra_smq_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_smq` ADD CONSTRAINT `fk_terminology_meddra_smq_parent_meddra_smq_id` FOREIGN KEY (`parent_meddra_smq_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`meddra_smq`(`meddra_smq_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_smq` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_smq` SET TAGS ('dbx_domain' = 'terminology');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_smq` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_smq` SET TAGS ('dbx_subdomain' = 'medical_coding');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_smq` ALTER COLUMN `meddra_smq_id` SET TAGS ('dbx_pk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_smq` ALTER COLUMN `code_system_version_id` SET TAGS ('dbx_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_smq` ALTER COLUMN `meddra_pt_id` SET TAGS ('dbx_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_smq` ALTER COLUMN `meddra_pt_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_smq` ALTER COLUMN `meddra_pt_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_smq` ALTER COLUMN `parent_meddra_smq_alt_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_smq` ALTER COLUMN `parent_meddra_smq_alt_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_smq` ALTER COLUMN `parent_meddra_smq_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_smq` ALTER COLUMN `parent_meddra_smq_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_smq` ALTER COLUMN `smq_code` SET TAGS ('dbx_standard' = 'MedDRA; element:SMQ.smqCode');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_smq` ALTER COLUMN `smq_level` SET TAGS ('dbx_standard' = 'MedDRA; element:SMQ.smqLevel');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_smq` ALTER COLUMN `smq_name` SET TAGS ('dbx_standard' = 'MedDRA; element:SMQ.smqName');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_smq` ALTER COLUMN `smq_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_smq` ALTER COLUMN `smq_scope` SET TAGS ('dbx_standard' = 'MedDRA; element:SMQ.smqScope');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_drug_record` ADD CONSTRAINT `fk_terminology_whodrug_drug_record_code_system_version_id` FOREIGN KEY (`code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_drug_record` ADD CONSTRAINT `fk_terminology_whodrug_drug_record_primary_whodrug_atc_level4_id` FOREIGN KEY (`primary_whodrug_atc_level4_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`whodrug_atc_level4`(`whodrug_atc_level4_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_drug_record` ADD CONSTRAINT `fk_terminology_whodrug_drug_record_whodrug_preferred_name_id` FOREIGN KEY (`whodrug_preferred_name_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`whodrug_preferred_name`(`whodrug_preferred_name_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_drug_record` ADD CONSTRAINT `fk_terminology_whodrug_drug_record_whodrug_atc_level4_id` FOREIGN KEY (`whodrug_atc_level4_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`whodrug_atc_level4`(`whodrug_atc_level4_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_drug_record` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_drug_record` SET TAGS ('dbx_domain' = 'terminology');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_drug_record` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_drug_record` SET TAGS ('dbx_subdomain' = 'pharmaceutical_classification');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_drug_record` ALTER COLUMN `whodrug_drug_record_id` SET TAGS ('dbx_pk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_drug_record` ALTER COLUMN `code_system_version_id` SET TAGS ('dbx_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_drug_record` ALTER COLUMN `primary_whodrug_atc_level4_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_drug_record` ALTER COLUMN `primary_whodrug_atc_level4_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_drug_record` ALTER COLUMN `whodrug_preferred_name_id` SET TAGS ('dbx_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_drug_record` ALTER COLUMN `whodrug_preferred_name_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_drug_record` ALTER COLUMN `whodrug_preferred_name_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_drug_record` ALTER COLUMN `whodrug_preferred_name_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_drug_record` ALTER COLUMN `whodrug_atc_level4_id` SET TAGS ('dbx_renamed_from' = 'secondary_whodrug_atc_level4_id');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_drug_record` ALTER COLUMN `whodrug_atc_level4_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_drug_record` ALTER COLUMN `drug_record_number` SET TAGS ('dbx_standard' = 'WHODrug Global; element:DrugRecord.drugRecordNumber');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_drug_record` ALTER COLUMN `ingredient` SET TAGS ('dbx_standard' = 'WHODrug Global; element:DrugRecord.ingredient');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_drug_record` ALTER COLUMN `trade_name` SET TAGS ('dbx_standard' = 'WHODrug Global; element:DrugRecord.tradeName');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_drug_record` ALTER COLUMN `trade_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_preferred_name` ADD CONSTRAINT `fk_terminology_whodrug_preferred_name_code_system_version_id` FOREIGN KEY (`code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_preferred_name` ADD CONSTRAINT `fk_terminology_whodrug_preferred_name_whodrug_atc_id` FOREIGN KEY (`whodrug_atc_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`whodrug_atc`(`whodrug_atc_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_preferred_name` ADD CONSTRAINT `fk_terminology_whodrug_preferred_name_whodrug_atc_level4_id` FOREIGN KEY (`whodrug_atc_level4_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`whodrug_atc_level4`(`whodrug_atc_level4_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_preferred_name` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_preferred_name` SET TAGS ('dbx_domain' = 'terminology');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_preferred_name` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_preferred_name` SET TAGS ('dbx_subdomain' = 'pharmaceutical_classification');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_preferred_name` ALTER COLUMN `whodrug_preferred_name_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_preferred_name` ALTER COLUMN `whodrug_preferred_name_id` SET TAGS ('dbx_pk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_preferred_name` ALTER COLUMN `code_system_version_id` SET TAGS ('dbx_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_preferred_name` ALTER COLUMN `whodrug_atc_id` SET TAGS ('dbx_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_preferred_name` ALTER COLUMN `whodrug_atc_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_preferred_name` ALTER COLUMN `whodrug_atc_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_preferred_name` ALTER COLUMN `whodrug_atc_level4_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_preferred_name` ALTER COLUMN `whodrug_atc_level4_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_preferred_name` ALTER COLUMN `preferred_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_preferred_name` ALTER COLUMN `preferred_name` SET TAGS ('dbx_standard' = 'WHODrug Global; element:PreferredName.preferredName');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_preferred_name` ALTER COLUMN `preferred_name_code` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_preferred_name` ALTER COLUMN `preferred_name_code` SET TAGS ('dbx_standard' = 'WHODrug Global; element:PreferredName.code');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc` ADD CONSTRAINT `fk_terminology_whodrug_atc_code_system_version_id` FOREIGN KEY (`code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc` ADD CONSTRAINT `fk_terminology_whodrug_atc_whodrug_atc_level1_id` FOREIGN KEY (`whodrug_atc_level1_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`whodrug_atc_level1`(`whodrug_atc_level1_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc` SET TAGS ('dbx_domain' = 'terminology');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc` SET TAGS ('dbx_subdomain' = 'pharmaceutical_classification');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc` ALTER COLUMN `whodrug_atc_id` SET TAGS ('dbx_pk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc` ALTER COLUMN `code_system_version_id` SET TAGS ('dbx_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc` ALTER COLUMN `whodrug_atc_level1_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc` ALTER COLUMN `whodrug_atc_level1_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc` ALTER COLUMN `atc_code` SET TAGS ('dbx_standard' = 'WHODrug Global ATC; element:ATC.atcCode');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc` ALTER COLUMN `atc_level1_code` SET TAGS ('dbx_standard' = 'WHODrug Global ATC; element:ATC.level1Code');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc` ALTER COLUMN `atc_level2_code` SET TAGS ('dbx_standard' = 'WHODrug Global ATC; element:ATC.level2Code');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc` ALTER COLUMN `atc_level3_code` SET TAGS ('dbx_standard' = 'WHODrug Global ATC; element:ATC.level3Code');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc` ALTER COLUMN `atc_level4_code` SET TAGS ('dbx_standard' = 'WHODrug Global ATC; element:ATC.level4Code');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`loinc` ADD CONSTRAINT `fk_terminology_loinc_code_system_version_id` FOREIGN KEY (`code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`loinc` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`loinc` SET TAGS ('dbx_domain' = 'terminology');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`loinc` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`loinc` SET TAGS ('dbx_subdomain' = 'laboratory_standards');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`loinc` ALTER COLUMN `loinc_id` SET TAGS ('dbx_pk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`loinc` ALTER COLUMN `code_system_version_id` SET TAGS ('dbx_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`loinc` ALTER COLUMN `loinc_code` SET TAGS ('dbx_standard' = 'LOINC; element:LOINC.LOINC_NUM');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`loinc` ALTER COLUMN `component` SET TAGS ('dbx_standard' = 'LOINC; element:LOINC.COMPONENT');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`loinc` ALTER COLUMN `long_common_name` SET TAGS ('dbx_standard' = 'LOINC; element:LOINC.LONG_COMMON_NAME');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`loinc` ALTER COLUMN `long_common_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`snomed_ct` ADD CONSTRAINT `fk_terminology_snomed_ct_code_system_version_id` FOREIGN KEY (`code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`snomed_ct` ADD CONSTRAINT `fk_terminology_snomed_ct_parent_snomed_ct_alt_id` FOREIGN KEY (`parent_snomed_ct_alt_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`snomed_ct`(`snomed_ct_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`snomed_ct` ADD CONSTRAINT `fk_terminology_snomed_ct_parent_snomed_ct_id` FOREIGN KEY (`parent_snomed_ct_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`snomed_ct`(`snomed_ct_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`snomed_ct` ADD CONSTRAINT `fk_terminology_snomed_ct_primary_snomed_ct_concept_id` FOREIGN KEY (`primary_snomed_ct_concept_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`snomed_ct_concept`(`snomed_ct_concept_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`snomed_ct` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`snomed_ct` SET TAGS ('dbx_domain' = 'terminology');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`snomed_ct` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`snomed_ct` SET TAGS ('dbx_subdomain' = 'clinical_vocabulary');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`snomed_ct` ALTER COLUMN `snomed_ct_id` SET TAGS ('dbx_pk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`snomed_ct` ALTER COLUMN `code_system_version_id` SET TAGS ('dbx_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`snomed_ct` ALTER COLUMN `primary_snomed_ct_concept_id` SET TAGS ('dbx_standard' = 'SNOMED CT; element:Concept.conceptId');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`snomed_ct` ALTER COLUMN `fully_specified_name` SET TAGS ('dbx_standard' = 'SNOMED CT; element:Description.fullySpecifiedName');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`snomed_ct` ALTER COLUMN `fully_specified_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`snomed_ct` ALTER COLUMN `preferred_term` SET TAGS ('dbx_standard' = 'SNOMED CT; element:Description.preferredTerm');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae` ADD CONSTRAINT `fk_terminology_ctcae_code_system_version_id` FOREIGN KEY (`code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae` ADD CONSTRAINT `fk_terminology_ctcae_ctcae_grade_id` FOREIGN KEY (`ctcae_grade_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`ctcae_grade`(`ctcae_grade_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae` ADD CONSTRAINT `fk_terminology_ctcae_meddra_pt_id` FOREIGN KEY (`meddra_pt_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`meddra_pt`(`meddra_pt_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae` ADD CONSTRAINT `fk_terminology_ctcae_meddra_soc_id` FOREIGN KEY (`meddra_soc_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`meddra_soc`(`meddra_soc_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae` SET TAGS ('dbx_domain' = 'terminology');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae` SET TAGS ('dbx_subdomain' = 'toxicity_grading');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae` ALTER COLUMN `ctcae_id` SET TAGS ('dbx_pk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae` ALTER COLUMN `code_system_version_id` SET TAGS ('dbx_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae` ALTER COLUMN `ctcae_grade_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae` ALTER COLUMN `ctcae_grade_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae` ALTER COLUMN `meddra_pt_id` SET TAGS ('dbx_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae` ALTER COLUMN `meddra_pt_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae` ALTER COLUMN `meddra_pt_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae` ALTER COLUMN `meddra_soc_id` SET TAGS ('dbx_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae` ALTER COLUMN `meddra_soc_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae` ALTER COLUMN `meddra_soc_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae` ALTER COLUMN `ctcae_code` SET TAGS ('dbx_standard' = 'CTCAE; element:CTCAE.code');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae` ALTER COLUMN `grade` SET TAGS ('dbx_standard' = 'CTCAE; element:CTCAE.grade');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae` ALTER COLUMN `grade_description` SET TAGS ('dbx_standard' = 'CTCAE; element:CTCAE.gradeDescription');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae` ALTER COLUMN `term` SET TAGS ('dbx_standard' = 'CTCAE; element:CTCAE.term');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_record` ADD CONSTRAINT `fk_terminology_whodrug_record_code_system_version_id` FOREIGN KEY (`code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_record` ADD CONSTRAINT `fk_terminology_whodrug_record_primary_whodrug_atc_level4_id` FOREIGN KEY (`primary_whodrug_atc_level4_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`whodrug_atc_level4`(`whodrug_atc_level4_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_record` ADD CONSTRAINT `fk_terminology_whodrug_record_tertiary_whodrug_atc_level4_id` FOREIGN KEY (`tertiary_whodrug_atc_level4_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`whodrug_atc_level4`(`whodrug_atc_level4_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_record` ADD CONSTRAINT `fk_terminology_whodrug_record_whodrug_drug_record_id` FOREIGN KEY (`whodrug_drug_record_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`whodrug_drug_record`(`whodrug_drug_record_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_record` ADD CONSTRAINT `fk_terminology_whodrug_record_whodrug_preferred_name_id` FOREIGN KEY (`whodrug_preferred_name_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`whodrug_preferred_name`(`whodrug_preferred_name_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_record` ADD CONSTRAINT `fk_terminology_whodrug_record_secondary_whodrug_atc_level4_id` FOREIGN KEY (`secondary_whodrug_atc_level4_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`whodrug_atc_level4`(`whodrug_atc_level4_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_record` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_record` SET TAGS ('dbx_domain' = 'terminology');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_record` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_record` SET TAGS ('dbx_subdomain' = 'pharmaceutical_classification');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_record` SET TAGS ('dbx_layer' = 'silver');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_record` SET TAGS ('dbx_coding_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_record` ALTER COLUMN `whodrug_record_id` SET TAGS ('dbx_pk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_record` ALTER COLUMN `code_system_version_id` SET TAGS ('dbx_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_record` ALTER COLUMN `primary_whodrug_atc_level4_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_record` ALTER COLUMN `primary_whodrug_atc_level4_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_record` ALTER COLUMN `tertiary_whodrug_atc_level4_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_record` ALTER COLUMN `tertiary_whodrug_atc_level4_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_record` ALTER COLUMN `whodrug_drug_record_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_record` ALTER COLUMN `whodrug_drug_record_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_record` ALTER COLUMN `whodrug_preferred_name_id` SET TAGS ('dbx_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_record` ALTER COLUMN `whodrug_preferred_name_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_record` ALTER COLUMN `whodrug_preferred_name_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_record` ALTER COLUMN `whodrug_preferred_name_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_record` ALTER COLUMN `secondary_whodrug_atc_level4_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_record` ALTER COLUMN `trade_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_term` ADD CONSTRAINT `fk_terminology_meddra_term_code_system_version_id` FOREIGN KEY (`code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_term` ADD CONSTRAINT `fk_terminology_meddra_term_meddra_pt_id` FOREIGN KEY (`meddra_pt_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`meddra_pt`(`meddra_pt_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_term` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_term` SET TAGS ('dbx_domain' = 'terminology');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_term` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_term` SET TAGS ('dbx_subdomain' = 'medical_coding');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_term` ALTER COLUMN `meddra_pt_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_term` ALTER COLUMN `meddra_pt_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_term` ALTER COLUMN `meddra_code` SET TAGS ('dbx_standard' = 'MedDRA; element:PT.code');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`meddra_term` ALTER COLUMN `preferred_term` SET TAGS ('dbx_standard' = 'MedDRA; element:PT.ptName');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae_grade` ADD CONSTRAINT `fk_terminology_ctcae_grade_code_system_version_id` FOREIGN KEY (`code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae_grade` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae_grade` SET TAGS ('dbx_domain' = 'terminology');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae_grade` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae_grade` SET TAGS ('dbx_subdomain' = 'toxicity_grading');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae_grade` ALTER COLUMN `ctcae_term` SET TAGS ('dbx_standard' = 'CTCAE; element:CTCAE.term');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae_grade` ALTER COLUMN `grade` SET TAGS ('dbx_standard' = 'CTCAE; element:CTCAE.grade');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_classification` ADD CONSTRAINT `fk_terminology_whodrug_atc_classification_whodrug_atc_level4_id` FOREIGN KEY (`whodrug_atc_level4_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`whodrug_atc_level4`(`whodrug_atc_level4_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_classification` ADD CONSTRAINT `fk_terminology_whodrug_atc_classification_whodrug_drug_record_id` FOREIGN KEY (`whodrug_drug_record_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`whodrug_drug_record`(`whodrug_drug_record_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_classification` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_classification` SET TAGS ('dbx_domain' = 'terminology');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_classification` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_classification` SET TAGS ('dbx_subdomain' = 'pharmaceutical_classification');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_classification` ALTER COLUMN `whodrug_atc_level4_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_classification` ALTER COLUMN `whodrug_atc_level4_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_classification` ALTER COLUMN `whodrug_drug_record_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_classification` ALTER COLUMN `whodrug_drug_record_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`loinc_code` ADD CONSTRAINT `fk_terminology_loinc_code_code_system_version_id` FOREIGN KEY (`code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`loinc_code` ADD CONSTRAINT `fk_terminology_loinc_code_loinc_id` FOREIGN KEY (`loinc_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`loinc`(`loinc_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`loinc_code` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`loinc_code` SET TAGS ('dbx_domain' = 'terminology');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`loinc_code` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`loinc_code` SET TAGS ('dbx_subdomain' = 'laboratory_standards');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`loinc_code` ALTER COLUMN `loinc_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`loinc_code` ALTER COLUMN `loinc_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`loinc_code` ALTER COLUMN `term_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`snomed_ct_concept` ADD CONSTRAINT `fk_terminology_snomed_ct_concept_code_system_version_id` FOREIGN KEY (`code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`snomed_ct_concept` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`snomed_ct_concept` SET TAGS ('dbx_domain' = 'terminology');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`snomed_ct_concept` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`snomed_ct_concept` SET TAGS ('dbx_subdomain' = 'clinical_vocabulary');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`snomed_ct_concept` ALTER COLUMN `term_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae_term_catalog` ADD CONSTRAINT `fk_terminology_ctcae_term_catalog_code_system_version_id` FOREIGN KEY (`code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae_term_catalog` ADD CONSTRAINT `fk_terminology_ctcae_term_catalog_ctcae_id` FOREIGN KEY (`ctcae_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`ctcae`(`ctcae_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae_term_catalog` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae_term_catalog` SET TAGS ('dbx_domain' = 'terminology');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae_term_catalog` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae_term_catalog` SET TAGS ('dbx_subdomain' = 'toxicity_grading');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae_term_catalog` ALTER COLUMN `ctcae_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae_term_catalog` ALTER COLUMN `ctcae_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`ctcae_term_catalog` ALTER COLUMN `term_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`icd10_code` ADD CONSTRAINT `fk_terminology_icd10_code_code_system_version_id` FOREIGN KEY (`code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`icd10_code` ADD CONSTRAINT `fk_terminology_icd10_code_icd_id` FOREIGN KEY (`icd_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`icd`(`icd_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`icd10_code` ADD CONSTRAINT `fk_terminology_icd10_code_parent_icd10_code_alt_id` FOREIGN KEY (`parent_icd10_code_alt_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`icd10_code`(`icd10_code_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`icd10_code` ADD CONSTRAINT `fk_terminology_icd10_code_parent_icd10_code_id` FOREIGN KEY (`parent_icd10_code_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`icd10_code`(`icd10_code_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`icd10_code` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`icd10_code` SET TAGS ('dbx_domain' = 'terminology');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`icd10_code` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`icd10_code` SET TAGS ('dbx_subdomain' = 'medical_coding');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`icd10_code` ALTER COLUMN `term_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`terminology_codelist` ADD CONSTRAINT `fk_terminology_terminology_codelist_code_system_id` FOREIGN KEY (`code_system_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system`(`code_system_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`terminology_codelist` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`terminology_codelist` SET TAGS ('dbx_domain' = 'terminology');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`terminology_codelist` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`terminology_codelist` SET TAGS ('dbx_subdomain' = 'dictionary_registry');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`terminology_codelist` ALTER COLUMN `terminology_codelist_id` SET TAGS ('dbx_business_glossary_term' = 'terminology_codelist Identifier');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`terminology_codelist` ALTER COLUMN `submission_value` SET TAGS ('dbx_standard' = 'CDISC CT; element:CodeList.submissionValue');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`terminology_codelist_term` ADD CONSTRAINT `fk_terminology_terminology_codelist_term_parent_terminology_codelist_id` FOREIGN KEY (`parent_terminology_codelist_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`terminology_codelist`(`terminology_codelist_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`terminology_codelist_term` ADD CONSTRAINT `fk_terminology_terminology_codelist_term_primary_terminology_codelist_id` FOREIGN KEY (`primary_terminology_codelist_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`terminology_codelist`(`terminology_codelist_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`terminology_codelist_term` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`terminology_codelist_term` SET TAGS ('dbx_domain' = 'terminology');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`terminology_codelist_term` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`terminology_codelist_term` SET TAGS ('dbx_subdomain' = 'dictionary_registry');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`terminology_codelist_term` ALTER COLUMN `terminology_codelist_term_id` SET TAGS ('dbx_business_glossary_term' = 'terminology_codelist_term Identifier');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`terminology_codelist_term` ALTER COLUMN `preferred_term` SET TAGS ('dbx_standard' = 'CDISC CT; element:CodeListItem.preferredTerm');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`terminology_codelist_term` ALTER COLUMN `submission_value` SET TAGS ('dbx_standard' = 'CDISC CT; element:CodeListItem.submissionValue');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`terminology_codelist_term` ALTER COLUMN `synonyms` SET TAGS ('dbx_standard' = 'CDISC CT; element:CodeListItem.synonym');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level1` ADD CONSTRAINT `fk_terminology_whodrug_atc_level1_code_system_version_id` FOREIGN KEY (`code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level1` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level1` SET TAGS ('dbx_domain' = 'terminology');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level1` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level1` SET TAGS ('dbx_subdomain' = 'pharmaceutical_classification');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level1` ALTER COLUMN `whodrug_atc_level1_id` SET TAGS ('dbx_business_glossary_term' = 'whodrug_atc_level1 Identifier');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level1` ALTER COLUMN `code_system_version_id` SET TAGS ('dbx_business_glossary_term' = 'Code System Version Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level1` ALTER COLUMN `atc_level1_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level1` ALTER COLUMN `language_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level2` ADD CONSTRAINT `fk_terminology_whodrug_atc_level2_whodrug_atc_level1_id` FOREIGN KEY (`whodrug_atc_level1_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`whodrug_atc_level1`(`whodrug_atc_level1_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level2` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level2` SET TAGS ('dbx_domain' = 'terminology');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level2` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level2` SET TAGS ('dbx_subdomain' = 'pharmaceutical_classification');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level2` ALTER COLUMN `whodrug_atc_level2_id` SET TAGS ('dbx_business_glossary_term' = 'whodrug_atc_level2 Identifier');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level2` ALTER COLUMN `whodrug_atc_level1_id` SET TAGS ('dbx_business_glossary_term' = 'Whodrug Atc Level1 Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level2` ALTER COLUMN `whodrug_atc_level1_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level2` ALTER COLUMN `whodrug_atc_level1_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level2` ALTER COLUMN `atc_language_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level2` ALTER COLUMN `atc_level2_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level3` ADD CONSTRAINT `fk_terminology_whodrug_atc_level3_whodrug_atc_level2_id` FOREIGN KEY (`whodrug_atc_level2_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`whodrug_atc_level2`(`whodrug_atc_level2_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level3` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level3` SET TAGS ('dbx_domain' = 'terminology');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level3` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level3` SET TAGS ('dbx_subdomain' = 'pharmaceutical_classification');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level3` ALTER COLUMN `whodrug_atc_level3_id` SET TAGS ('dbx_business_glossary_term' = 'whodrug_atc_level3 Identifier');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level3` ALTER COLUMN `whodrug_atc_level2_id` SET TAGS ('dbx_business_glossary_term' = 'Whodrug Atc Level2 Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level3` ALTER COLUMN `whodrug_atc_level2_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level3` ALTER COLUMN `whodrug_atc_level2_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level3` ALTER COLUMN `atc_level3_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level3` ALTER COLUMN `language_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level4` ADD CONSTRAINT `fk_terminology_whodrug_atc_level4_whodrug_atc_level3_id` FOREIGN KEY (`whodrug_atc_level3_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`whodrug_atc_level3`(`whodrug_atc_level3_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level4` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level4` SET TAGS ('dbx_domain' = 'terminology');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level4` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level4` SET TAGS ('dbx_subdomain' = 'pharmaceutical_classification');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level4` ALTER COLUMN `whodrug_atc_level4_id` SET TAGS ('dbx_business_glossary_term' = 'whodrug_atc_level4 Identifier');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level4` ALTER COLUMN `whodrug_atc_level3_id` SET TAGS ('dbx_business_glossary_term' = 'Whodrug Atc Level3 Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level4` ALTER COLUMN `whodrug_atc_level3_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level4` ALTER COLUMN `whodrug_atc_level3_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level4` ALTER COLUMN `dictionary_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug_atc_level4` ALTER COLUMN `level4_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`plus` ADD CONSTRAINT `fk_terminology_plus_code_system_version_id` FOREIGN KEY (`code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`plus` ADD CONSTRAINT `fk_terminology_plus_loinc_id` FOREIGN KEY (`loinc_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`loinc`(`loinc_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`plus` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`plus` SET TAGS ('dbx_domain' = 'terminology');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`plus` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`plus` SET TAGS ('dbx_subdomain' = 'dictionary_registry');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`plus` ALTER COLUMN `loinc_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`plus` ALTER COLUMN `loinc_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug` ADD CONSTRAINT `fk_terminology_whodrug_code_system_version_id` FOREIGN KEY (`code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug` ADD CONSTRAINT `fk_terminology_whodrug_whodrug_drug_record_id` FOREIGN KEY (`whodrug_drug_record_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`whodrug_drug_record`(`whodrug_drug_record_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug` ADD CONSTRAINT `fk_terminology_whodrug_whodrug_preferred_name_id` FOREIGN KEY (`whodrug_preferred_name_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`whodrug_preferred_name`(`whodrug_preferred_name_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug` SET TAGS ('dbx_domain' = 'terminology');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug` SET TAGS ('dbx_subdomain' = 'pharmaceutical_classification');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug` ALTER COLUMN `whodrug_drug_record_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug` ALTER COLUMN `whodrug_drug_record_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug` ALTER COLUMN `whodrug_preferred_name_id` SET TAGS ('dbx_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug` ALTER COLUMN `whodrug_preferred_name_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug` ALTER COLUMN `whodrug_preferred_name_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`whodrug` ALTER COLUMN `whodrug_preferred_name_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`snomed` ADD CONSTRAINT `fk_terminology_snomed_code_system_version_id` FOREIGN KEY (`code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`snomed` ADD CONSTRAINT `fk_terminology_snomed_snomed_ct_concept_id` FOREIGN KEY (`snomed_ct_concept_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`snomed_ct_concept`(`snomed_ct_concept_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`snomed` ADD CONSTRAINT `fk_terminology_snomed_snomed_ct_id` FOREIGN KEY (`snomed_ct_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`snomed_ct`(`snomed_ct_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`snomed` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`snomed` SET TAGS ('dbx_domain' = 'terminology');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`snomed` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`snomed` SET TAGS ('dbx_subdomain' = 'clinical_vocabulary');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`icd` ADD CONSTRAINT `fk_terminology_icd_code_system_version_id` FOREIGN KEY (`code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`icd` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`icd` SET TAGS ('dbx_domain' = 'terminology');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`icd` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`icd` SET TAGS ('dbx_subdomain' = 'medical_coding');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`anything` ADD CONSTRAINT `fk_terminology_anything_code_system_version_id` FOREIGN KEY (`code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`terminology`.`anything` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`anything` SET TAGS ('dbx_domain' = 'terminology');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`anything` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`terminology`.`anything` SET TAGS ('dbx_subdomain' = 'dictionary_registry');
