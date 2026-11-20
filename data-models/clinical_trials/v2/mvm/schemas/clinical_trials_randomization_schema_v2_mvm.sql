-- Schema for Domain: randomization | Business: Clinical_Trials | Version: v2_mvm
-- Generated on: 2026-11-20 12:39:48

CREATE DATABASE IF NOT EXISTS `clinical_trials_mvm`.`randomization` COMMENT 'Manages subject allocation algorithms, stratification factors, randomization codes, blinding integrity, and unblinding procedures. Integrated with eCRF and supply domains for kit assignment and treatment arm allocation via IRT/IVRS/RTSM systems.';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` (
    `rand_scheme_id` BIGINT COMMENT 'Unique surrogate identifier for the randomization scheme record in the lakehouse silver layer. Primary key for this entity.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.compliance_sop. Business justification: GCP requires randomization scheme generation and validation to be governed by a specific compliance SOP. Regulatory inspectors verify SOP compliance for randomization procedures.',
    `ind_application_id` BIGINT COMMENT 'Foreign key linking to regulatory.ind_application. Business justification: A randomization scheme is designed and authorized under a specific IND application.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Randomization schemes are designed against a specific protocol version per ICH E9(R1) and GCP requirements.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this randomization scheme is defined. Links the scheme to its parent protocol.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: The randomization scheme is an essential TMF document per ICH E6 and DIA Reference Model.',
    `activation_date` DATE COMMENT 'Date on which the randomization scheme was activated in the IRT/RTSM system and made available for subject allocation. Marks transition to active status.',
    `allocation_algorithm` STRING COMMENT 'The statistical randomization algorithm used to assign subjects to treatment arms. simple = unrestricted random; block = fixed block sizes; stratified_block = blocks within strata; minimization = dynamic balancing; adaptive = response-adaptive. Valid values are `simple|block|stratified_block|minimization|adaptive|covariate_adaptive`',
    `allocation_ratio` DECIMAL(18,2) COMMENT 'Randomization allocation ratio; implements CDISC SDTM TS parameter RANDQT / trial design allocation ratio.',
    `approval_date` DATE COMMENT 'Date on which the randomization scheme received formal biostatistics and QA approval, authorizing its use in the study. Marks transition from draft to approved status.',
    `approved_by` STRING COMMENT 'Name or user identifier of the individual (QA or biostatistics lead) who formally approved the randomization scheme. Supports 21 CFR Part 11 electronic signature audit trail.',
    `blinding_type` STRING COMMENT 'Blinding type; implements CDISC SDTM TS parameter BLIND (TSVAL where TSPARMCD=BLIND).. Valid values are `open_label|single_blind|double_blind|triple_blind`',
    `block_size_list` STRING COMMENT 'Comma-separated list of permissible block sizes used in block or stratified-block randomization (e.g., 4,6,8). Variable block sizes reduce predictability. Null for non-block algorithms.',
    `cdisc_sdtm_domain` STRING COMMENT 'Target CDISC SDTM domain for randomization data (e.g., DM.ARM/ACTARM, TA); implements SDTM domain reference.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this randomization scheme record was first created in the lakehouse. Supports ALCOA+ audit trail requirements and 21 CFR Part 11 compliance.',
    `generation_method_description` STRING COMMENT 'Narrative description of the randomization list generation methodology, including algorithm parameters, SAS/R procedure used, and any special considerations. Included in the Randomization Plan and CSR.',
    `generation_software` STRING COMMENT 'Name and version of the software used to generate the randomization list (e.g., SAS 9.4, R 4.2.1, the source system 21.3). Required for regulatory submission and reproducibility validation.',
    `geographic_scope` STRING COMMENT 'Comma-separated list of 3-letter ISO country codes where this randomization scheme is applicable (e.g., USA,GBR,DEU). Relevant for multi-regional trials with country-specific regulatory requirements.',
    `irb_iec_approval_required` BOOLEAN COMMENT 'Indicates whether a scheme amendment requires re-submission to the Institutional Review Board (IRB) or Independent Ethics Committee (IEC). Relevant when stratification factors or allocation ratios change.',
    `irt_scheme_reference` STRING COMMENT 'The scheme identifier or configuration reference as recorded in the IRT/RTSM system (e.g., the source system scheme ID or Medidata Rave RTSM list ID). Enables cross-system traceability.',
    `irt_system_name` STRING COMMENT 'Name of the IRT/IVRS/RTSM system used to execute this randomization scheme (e.g., the source system Medidata Rave RTSM, Almac IXRS). Identifies the operational system of record for subject allocation.',
    `is_centralized` BOOLEAN COMMENT 'Indicates whether randomization is performed centrally via IRT/IVRS/RTSM (True) or locally at the site (False). Centralized randomization is the standard for GCP-compliant multi-center trials.',
    `is_stratified_by_site` BOOLEAN COMMENT 'Indicates whether randomization is stratified by investigative site. Site stratification is common in multi-center trials to ensure balance across sites.',
    `is_variable_block` BOOLEAN COMMENT 'Indicates whether variable (random) block sizes are used rather than a fixed block size. Variable blocks reduce the ability to predict upcoming assignments and are preferred for double-blind studies.',
    `list_generation_date` DATE COMMENT 'Date on which the randomization list was generated using the specified software and seed. Required for audit trail and regulatory submission documentation.',
    `minimization_objective_function` STRING COMMENT 'For minimization or covariate-adaptive algorithms, the mathematical objective function used to minimize imbalance across covariates (e.g., range, variance, weighted_range). Null for non-minimization schemes.',
    `minimization_probability` DECIMAL(5,4) COMMENT 'For minimization algorithms, the probability (0.0–1.0) of assigning a subject to the arm that minimizes imbalance (e.g., 0.8000 = 80% biased coin). Null for non-minimization schemes.',
    `notes` STRING COMMENT 'Free-text field for additional operational notes, amendment rationale, or special instructions related to this randomization scheme. Not intended for structured data.',
    `random_seed` BIGINT COMMENT 'Numeric seed value used to initialize the pseudo-random number generator for reproducible list generation. Classified confidential to protect blinding integrity; disclosed only at database lock (DBL) or unblinding.',
    `regulatory_submission_flag` BOOLEAN COMMENT 'Indicates whether this randomization scheme version has been included in a regulatory submission (IND, NDA, BLA, MAA, or eCTD package). Triggers additional change-control requirements.',
    `retirement_date` DATE COMMENT 'Date on which the randomization scheme was retired or superseded. Null if the scheme is still active. Used for version lifecycle management and TMF archival.',
    `sap_version_reference` STRING COMMENT 'Version identifier of the Statistical Analysis Plan (the source system) that specifies this randomization scheme. Ensures traceability between the scheme implementation and the approved statistical methodology.',
    `scheme_code` STRING COMMENT 'Externally-known alphanumeric code uniquely identifying this randomization scheme within the RTSM/IRT system (e.g., the source system or Medidata Rave RTSM). Used as the business key for cross-system reference.. Valid values are `^[A-Z0-9_-]{3,30}$`',
    `scheme_name` STRING COMMENT 'Human-readable descriptive name of the randomization scheme (e.g., Phase III Stratified Block Randomization v2). Used in reports, TMF documentation, and biostatistics deliverables.',
    `scheme_status` STRING COMMENT 'Current lifecycle status of the randomization scheme. draft = under development; approved = biostatistics/QA sign-off obtained; active = in use for subject allocation; suspended = temporarily halted (e.g., DSMB hold); retired = superseded or. Valid values are `draft|approved|active|suspended|retired`',
    `scheme_version` STRING COMMENT 'Version identifier of the randomization scheme (e.g., 1.0, 2.1). Incremented when the scheme is amended post-approval. Supports audit trail and regulatory submission traceability.. Valid values are `^[0-9]+.[0-9]+(.[0-9]+)?$`',
    `strata_count` BIGINT COMMENT 'Total number of distinct strata defined by the combination of stratification factors. Used to validate that the randomization list covers all strata and to monitor enrollment balance.',
    `stratification_factors` STRING COMMENT 'Semicolon-separated list of stratification factors used to define strata for stratified randomization (e.g., site;gender;disease_severity). Defined in the protocol and the source system. Null for non-stratified schemes.',
    `total_randomization_slots` BIGINT COMMENT 'Total number of randomization positions (slots) generated in the scheme list. Represents the maximum number of subjects that can be randomized under this scheme version.',
    `treatment_arm_count` BIGINT COMMENT 'Number of treatment arms (including placebo/control) defined in this randomization scheme. Must align with the protocol and allocation ratio.',
    `unblinding_procedure` STRING COMMENT 'Defines the authorized unblinding procedure for this scheme. emergency_only = individual subject emergency unblinding; dsmb_only = unblinding restricted to DSMB/DMC; dbk_full = full unblinding at database lock; partial_sponsor = sponsor. Valid values are `emergency_only|dsmb_only|dbk_full|partial_sponsor`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this randomization scheme record. Supports change tracking, audit trail, and version control in the silver layer.',
    CONSTRAINT pk_rand_scheme PRIMARY KEY(`rand_scheme_id`)
) COMMENT 'Master definition of a randomization scheme for a clinical study. Captures the allocation algorithm type (simple, block, stratified, minimization, adaptive), block sizes, allocation ratio, seed values, and scheme version.';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`randomization`.`rand_list` (
    `rand_list_id` BIGINT COMMENT 'Unique surrogate identifier for the randomization list record in the Silver Layer lakehouse. Primary key for this entity.',
    `document_sop_id` BIGINT COMMENT 'Foreign key linking to document.document_sop. Business justification: Randomization list generation and validation must follow a documented SOP per GCP requirements. Regulatory inspectors verify which SOP version governed each lists creation.',
    `epoch_id` BIGINT COMMENT 'Foreign key linking to study.study_epoch. Business justification: Randomization lists are epoch-specific per CDISC SDTM TE domain mapping requirements. The epoch in which randomization occurs must be formally linked for SDTM submission datasets and',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Randomization lists are generated for a specific protocol version; when a protocol amendment changes allocation, a new list version is required.',
    `rand_scheme_id` BIGINT COMMENT 'Reference to the randomization scheme (algorithm configuration, block sizes, stratification factors) from which this list was generated.',
    `regulatory_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to regulatory.protocol_amendment. Business justification: Protocol amendments that change randomization trigger generation of a new rand_list version.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this randomization list was generated. Links the list to its parent protocol.',
    `superseded_by_list_rand_list_id` BIGINT COMMENT 'Reference to the newer randomization list that supersedes this one. Null if this is the current active version. Supports version chain traceability.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Randomization lists are essential TMF documents per DIA Reference Model (Zone 5, randomization section).',
    `activation_timestamp` TIMESTAMP COMMENT 'Date and time when the randomization list was activated in the IRT/IVRS/RTSM system and made available for subject assignment.',
    `allocated_slots` BIGINT COMMENT 'Number of randomization slots that have been assigned to subjects at the time of record. Used to monitor enrollment capacity and list utilization.',
    `allocation_ratio` DECIMAL(18,2) COMMENT 'Ratio of subject allocation across treatment arms (e.g., 1:1, 2:1:1). Defined in the protocol and the source system; must match the generated list structure.',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time when the randomization list was formally approved for use in the study by the authorized statistician or delegate. Required for regulatory compliance.',
    `blinding_level` STRING COMMENT 'Blinding level; implements CDISC SDTM TS parameter BLIND.. Valid values are `open_label|single_blind|double_blind|triple_blind`',
    `block_size_sequence` STRING COMMENT 'Encoded representation of the block sizes used in permuted block randomization (e.g., 2,4,4,2). Classified as confidential to protect blinding integrity during the study.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this randomization list record was first captured in the data platform. Supports ALCOA+ audit trail requirements.',
    `dsmb_access_granted` BOOLEAN COMMENT 'Indicates whether the Data Safety Monitoring Board (DSMB) / Data Monitoring Committee (DMC) has been granted access to the unblinded version of this randomization list for interim safety reviews.',
    `generated_by` STRING COMMENT 'Name or user identifier of the biostatistician or system process that generated the randomization list. Supports ALCOA+ attributability requirement.',
    `generation_method` STRING COMMENT 'Algorithm or statistical method used to generate the randomization list (e.g., permuted block, minimization, stratified). Documented in the the source system. Valid values are `permuted_block|minimization|stratified|adaptive|dynamic|simple`',
    `generation_timestamp` TIMESTAMP COMMENT 'Date and time when the randomization list was computationally generated by the IRT/IVRS/RTSM system. Serves as the principal business event timestamp for this artifact.',
    `geographic_scope` STRING COMMENT 'Country or region code(s) for which this randomization list is applicable (ISO 3166-1 alpha-3 codes, comma-separated). Relevant for multi-regional trials with country-specific lists.',
    `irb_iec_approval_required` BOOLEAN COMMENT 'Indicates whether IRB/IEC approval is required before activating this randomization list (e.g., for protocol amendments that change the randomization scheme).',
    `irt_list_type` STRING COMMENT 'Scope of the randomization list as configured in the IRT/IVRS/RTSM system — whether it applies globally across all sites, to specific sites, strata, or countries.. Valid values are `global|site_specific|stratum_specific|country_specific`',
    `is_blinded` BOOLEAN COMMENT 'Indicates whether treatment assignments in this list are masked (True) or open-label (False). Drives access control and unblinding procedures in the IRT/IVRS/RTSM system.',
    `is_stratified` BOOLEAN COMMENT 'Indicates whether this randomization list uses stratified randomization (True) or unstratified simple/block randomization (False).',
    `kit_assignment_enabled` BOOLEAN COMMENT 'Indicates whether this randomization list is linked to investigational product kit assignment in the RTSM/supply chain module. When True, kit numbers are assigned at the point of randomization.',
    `list_description` STRING COMMENT 'Free-text description of the randomization list, including any special conditions, amendments, or notes relevant to its use in the study.',
    `list_number` STRING COMMENT 'Externally-known unique identifier or code for this randomization list as referenced in the IRT/IVRS/RTSM system and the Statistical Analysis Plan (the source system). Used for regulatory traceability.',
    `list_status` STRING COMMENT 'Current lifecycle status of the randomization list. Controls whether the list is available for subject assignment in the IRT/IVRS/RTSM system. [ENUM-REF-CANDIDATE: draft|pending_approval|approved|active|superseded|retired — promote to reference product if',
    `list_version` STRING COMMENT 'Version identifier of the randomization list (e.g., v1.0, v2.0). Incremented when the list is regenerated or amended, supporting audit trail and regulatory traceability.',
    `notes` STRING COMMENT 'Free-text field for additional operational notes, amendment rationale, or regulatory comments associated with this randomization list.',
    `randomization_seed` STRING COMMENT 'The random number generator seed value used to produce this list. Classified as confidential to protect blinding integrity. Required for reproducibility validation and regulatory inspection.',
    `sap_reference` STRING COMMENT 'Document identifier or section reference in the Statistical Analysis Plan (the source system) that specifies the randomization methodology for this list. Ensures traceability to the approved statistical methodology.',
    `source_system_list_reference` STRING COMMENT 'Native identifier of this randomization list in the originating IRT/IVRS/RTSM system (Medidata Rave RTSM or the source system Used for cross-system reconciliation.',
    `stratification_factors` STRING COMMENT 'Comma-separated list of stratification factors applied when generating this randomization list (e.g., site, disease_severity, age_group). Reflects the protocol-defined stratification variables.',
    `superseded_timestamp` TIMESTAMP COMMENT 'Date and time when this randomization list was superseded by a newer version. Null if the list is still active. Supports version lifecycle audit trail.',
    `total_slots` BIGINT COMMENT 'Total number of randomization positions (slots) in this list, representing the maximum number of subjects that can be assigned using this list.',
    `treatment_arm_count` BIGINT COMMENT 'Number of distinct treatment arms (including placebo/control) covered by this randomization list. Validates alignment with the protocol-defined study design.',
    `unblinding_procedure` STRING COMMENT 'Defined procedure type for unblinding this randomization list. Governs when and how treatment assignments may be revealed (e.g., emergency unblinding, post-DBL unblinding).. Valid values are `emergency_unblinding|scheduled_dbl_unblinding|dsmb_unblinding|regulatory_unblinding`',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this randomization list record was last modified in the data platform. Supports change tracking and audit trail.',
    `validation_status` STRING COMMENT 'Status of the User Acceptance Testing (UAT) and quality control validation performed on this randomization list prior to activation. Ensures the list meets protocol specifications before use.. Valid values are `not_validated|validated|validation_failed`',
    `validation_timestamp` TIMESTAMP COMMENT 'Date and time when the randomization list completed User Acceptance Testing (UAT) validation. Null if validation has not yet been performed.',
    CONSTRAINT pk_rand_list PRIMARY KEY(`rand_list_id`)
) COMMENT 'The generated randomization list produced from a randomization scheme. Stores the ordered sequence of treatment assignments, list version, generation timestamp, generation method, blinding level, and approval status.';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`randomization`.`rand_code` (
    `rand_code_id` BIGINT COMMENT 'Unique surrogate identifier for each randomization code (slot) record in the Silver layer. Primary key for this data product.',
    `clinical_trial_authorization_id` BIGINT COMMENT 'Foreign key linking to regulatory.clinical_trial_authorization. Business justification: Each randomization code is assigned in a specific country under an active CTA.',
    `investigational_site_id` BIGINT COMMENT 'Reference to the investigational site to which this randomization code is allocated. Site-specific lists restrict code consumption to the assigned site.',
    `irt_transaction_id` BIGINT COMMENT 'Unique transaction identifier generated by the IRT/IVRS/RTSM system at the moment of code assignment. Used for reconciliation between the EDC and RTSM systems.',
    `rand_list_id` BIGINT COMMENT 'Reference to the parent randomization list from which this code slot was generated. A study may have multiple lists (e.g., per stratum or per site).',
    `rand_scheme_id` BIGINT COMMENT 'Foreign key linking to randomization.stratification_cell. Business justification: Each rand_code slot belongs to a specific stratification cell that determines its allocation.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) to which this randomization code belongs. Links the code to its parent study context.',
    `study_site_id` BIGINT COMMENT 'Foreign key linking to site.study_site. Business justification: IRT systems allocate randomization codes to specific study sites for dispensing control. Code allocation reports and drug accountability reconciliation require study-site-level tracking.',
    `treatment_arm_id` BIGINT COMMENT 'Foreign key linking to randomization.treatment_arm. Business justification: Each rand_code slot is allocated to exactly one treatment arm. rand_code currently stores treatment_arm_code (STRING) and treatment_arm_label (STRING) as denormalized references.',
    `allocation_ratio_denominator` BIGINT COMMENT 'Denominator of the randomization allocation ratio (e.g., 3 in a 2:1 ratio, representing total parts). Together with the numerator, documents the intended allocation balance.',
    `allocation_ratio_numerator` BIGINT COMMENT 'Numerator of the randomization allocation ratio for the treatment arm assigned to this code (e.g., 2 in a 2:1 ratio). Used to verify list balance and document the randomization scheme.',
    `assigned_timestamp` TIMESTAMP COMMENT 'Date and time when this randomization code was consumed and assigned to a subject via the IRT/RTSM system. The principal business event timestamp for this entity. Null if not yet assigned.',
    `assignment_status` STRING COMMENT 'Current lifecycle status of this randomization code slot: available (not yet consumed), assigned (linked to a subject), cancelled (voided without assignment), replaced (superseded by a new code), reserved (held for a specific site/stratum), expired (past. Valid values are `available|assigned|cancelled|replaced|reserved|expired`',
    `blinding_type` STRING COMMENT 'Blinding type; implements CDISC SDTM TS parameter BLIND.. Valid values are `double_blind|single_blind|open_label|triple_blind`',
    `block_number` BIGINT COMMENT 'Block identifier within the randomization list to which this code belongs. Used for permuted-block randomization schemes to verify block completeness and balance.',
    `block_size` BIGINT COMMENT 'Number of randomization slots in the block containing this code. For variable block size designs, records the actual block size assigned to this slot.',
    `cancellation_reason` STRING COMMENT 'Free-text or coded reason for cancellation of this randomization code (e.g., subject screen failure, site closure, protocol amendment). Required for regulatory audit trail.',
    `cancelled_timestamp` TIMESTAMP COMMENT 'Date and time when this randomization code was cancelled or voided in the IRT/RTSM system. Null if the code was not cancelled.',
    `code_number` STRING COMMENT 'The externally-known alphanumeric randomization code identifier as generated by the RTSM/IRT system (e.g., RC-0042). This is the business-facing code printed on the randomization schedule and referenced in regulatory submissions.. Valid values are `^[A-Z0-9-]{1,20}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this randomization code record was first created in the source IRT/RTSM system. Supports ALCOA+ audit trail and 21 CFR Part 11 compliance.',
    `dispensing_visit_number` BIGINT COMMENT 'Protocol-defined visit number at which the IMP kit linked to this randomization code is to be dispensed to the subject. Aligns with the study schedule of assessments.',
    `expiry_date` DATE COMMENT 'Date after which this randomization code is no longer valid for assignment. Codes past expiry are automatically set to expired status by the IRT/RTSM system.',
    `irt_system_source` STRING COMMENT 'Identifies the IRT/RTSM system that generated and managed this randomization code (e.g., Medidata Rave RTSM, the source system Supports multi-system reconciliation and data lineage.. Valid values are `medidata_rave_rtsm|oracle_clinical_one|ivrs|other`',
    `is_emergency_unblinding_eligible` BOOLEAN COMMENT 'Indicates whether this randomization code is eligible for emergency unblinding by site staff via the IRT system (True) or requires sponsor/DSMB authorization (False). Governs site-level unblinding access controls.',
    `is_rescue_medication_eligible` BOOLEAN COMMENT 'Indicates whether the treatment arm assigned to this code permits rescue medication dispensing (True) or not (False). Drives IRT/RTSM dispensing logic for rescue kits.',
    `is_unblinded` BOOLEAN COMMENT 'Indicates whether the treatment arm assignment for this code has been formally unblinded (True) or remains blinded (False). Set to True upon emergency or end-of-study unblinding events.',
    `kit_code` STRING COMMENT 'Pre-assigned IMP kit code linked to this randomization slot for dispensing via IRT/RTSM. Connects the randomization event to the supply chain kit that must be dispensed to the subject.. Valid values are `^[A-Z0-9-]{1,30}$`',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time of the most recent modification to this randomization code record in the source system. Required for change tracking and ALCOA+ audit trail compliance.',
    `list_version_number` STRING COMMENT 'Version number of the randomization list from which this code was generated (e.g., 1.0, 2.1). Tracks list amendments due to protocol changes and supports regulatory audit trail.. Valid values are `^[0-9]+.[0-9]+$`',
    `notes` STRING COMMENT 'Free-text field for operational notes or comments entered by the IRT/RTSM administrator regarding this randomization code (e.g., manual override justification, reconciliation notes).',
    `protocol_amendment_number` STRING COMMENT 'Protocol amendment version under which this randomization code was generated or last modified. Tracks list changes driven by protocol amendments for regulatory traceability.. Valid values are `^[A-Z0-9.]{1,10}$`',
    `randomization_method` STRING COMMENT 'Statistical algorithm used to generate this randomization code (e.g., permuted_block, minimization, adaptive). Documented for regulatory submission and biostatistical validation.. Valid values are `permuted_block|minimization|stratified|adaptive|simple|dynamic`',
    `randomization_seed` STRING COMMENT 'Cryptographic seed value used by the randomization algorithm to generate this code list. Classified as confidential to protect blinding integrity. Required for regulatory reproducibility validation.',
    `region_code` STRING COMMENT 'Sponsor-defined geographic region code (e.g., NA, EU, APAC) associated with the site for this code. Used as a stratification factor in multi-regional trials.. Valid values are `^[A-Z0-9_]{1,20}$`',
    `replacement_code_number` STRING COMMENT 'Code number of the replacement randomization slot issued when this code was cancelled or replaced. Enables traceability of code replacement chains in the audit trail.. Valid values are `^[A-Z0-9-]{1,20}$`',
    `sequence_position` BIGINT COMMENT 'Sequential ordinal position of this code within its randomization list. Determines the order in which codes are consumed during subject enrollment.',
    `source_system_code_reference` STRING COMMENT 'Native primary key or unique identifier of this randomization code record in the originating IRT/RTSM source system (Medidata Rave RTSM or the source system Enables reconciliation and data lineage tracing back to the system of record.',
    `unblinding_reason` STRING COMMENT 'Documented reason for unblinding this randomization code, required for regulatory audit trail. Null if the code has not been unblinded.. Valid values are `emergency_medical|end_of_study|dsmb_request|regulatory_request|protocol_deviation`',
    `unblinding_timestamp` TIMESTAMP COMMENT 'Date and time when the treatment arm assignment was formally unblinded. Null if the code remains blinded. Captured per ALCOA+ principles for regulatory audit trail.',
    CONSTRAINT pk_rand_code PRIMARY KEY(`rand_code_id`)
) COMMENT 'Individual randomization code (slot) within a randomization list. Each code represents a single subject allocation slot with its sequential position number, pre-assigned treatment arm, stratification cell membership, kit code linkage for IMP dispensing';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` (
    `treatment_arm_id` BIGINT COMMENT 'Primary key for treatment_arm',
    `arm_id` BIGINT COMMENT 'Foreign key linking to study.study_arm. Business justification: randomization.treatment_arm is the operational implementation of study.study_arm (the protocol-defined arm).',
    `ind_application_id` BIGINT COMMENT 'Foreign key linking to regulatory.ind_application. Business justification: Treatment arms are defined in the IND protocol submission. FDA inspections and CDISC SDTM datasets require traceability from each treatment arm to the IND application that',
    `investigational_product_id` BIGINT COMMENT 'FK to study.investigational_product',
    `study_id` BIGINT COMMENT 'Reference to the clinical study to which this treatment arm belongs. Links the arm definition to its parent study protocol.',
    `allocation_ratio_denominator` BIGINT COMMENT 'Denominator component of the randomization allocation ratio for this arm (e.g., 3 in a 2:1 ratio where total parts = 3). Together with the numerator, defines the proportional allocation of subjects to this arm.',
    `allocation_ratio_numerator` BIGINT COMMENT 'Numerator component of the randomization allocation ratio for this arm (e.g., 2 in a 2:1 ratio). Used with the denominator to compute the target allocation percentage and configure the randomization schedule in IRT/RTSM systems.',
    `analysis_population` STRING COMMENT 'Primary analysis population associated with this treatment arm for statistical reporting (e.g., Intent-to-Treat (ITT), Modified ITT (mITT), Per Protocol (PP), Safety). Drives CDISC ADaM ADSL population flags and SAS Drug Development analysis programs.. Valid values are `ITT|mITT|PP|safety|PK|PD`',
    `approved_timestamp` TIMESTAMP COMMENT 'Timestamp when this treatment arm definition received formal approval (e.g., sponsor sign-off, protocol approval, IRT/RTSM UAT sign-off). Required for GCP compliance and regulatory inspection readiness. Managed via MasterControl or Veeva Vault workflow.',
    `arm_end_date` DATE COMMENT 'Date on which this treatment arm was closed to new randomizations or formally ended per protocol or protocol amendment. Nullable for arms that remain open. Used for enrollment closure tracking and database lock (DBL) preparation.',
    `arm_sequence_number` BIGINT COMMENT 'Ordinal sequence number defining the display order of this treatment arm in study reports, listings, and tables. Used for consistent ordering in CSR outputs, SDTM datasets, and regulatory submission documents.',
    `arm_start_date` DATE COMMENT 'Date on which this treatment arm became active and eligible for subject randomization, as defined in the protocol or IRT/RTSM configuration. Used for enrollment timeline tracking and regulatory reporting.',
    `arm_status` STRING COMMENT 'Current lifecycle status of the treatment arm. Controls whether subjects can be randomized to this arm, whether supply kits can be assigned, and whether the arm is available for data entry in the EDC. Managed in the source system and Medidata Rave RTSM.. Valid values are `draft|active|suspended|closed|cancelled`',
    `arm_type` STRING COMMENT 'Arm type; implements SDTM TA.ARM/ARMCD classification and USDM StudyArm.type; governed by CDISC CT arm type codelist.. Valid values are `experimental|active_comparator|placebo|open_label_extension|run_in|follow_up`',
    `blinding_role` STRING COMMENT 'Blinding designation for this treatment arm indicating the level of masking applied. Critical for maintaining blinding integrity in the study. Restricted access to prevent unblinding of sponsor, investigator, or subject.. Valid values are `blinded|open_label|single_blind|double_blind|triple_blind`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this treatment arm record was first created in the system, conforming to ALCOA+ principles (Attributable, Legible, Contemporaneous, Original, Accurate). Required for audit trail compliance under 21 CFR Part 11 and GCP.',
    `crossover_sequence` STRING COMMENT 'For crossover study designs, defines the treatment sequence this arm represents (e.g., AB, BA, ABC). Used in CDISC SDTM SEARM (Sequence Arm) variable and period-specific analysis in ADaM datasets.',
    `dose_level` STRING COMMENT 'Dose level designation for the investigational product in this arm (e.g., 10mg, 50mg, 100mg, High Dose, Low Dose). Used in dose-escalation studies, PK/PD analyses, and CDISC SDTM EX domain mapping.',
    `dosing_frequency` STRING COMMENT 'Frequency of investigational product administration for subjects in this arm (e.g., QD - Once Daily, BID - Twice Daily, QW - Once Weekly). Mapped to CDISC Controlled Terminology FREQ variable in the EX domain.',
    `edc_arm_code` STRING COMMENT 'Treatment arm code as configured in the Electronic Data Capture (EDC) system (Medidata Rave EDC or the source system Used for eCRF field population, data validation rules, and SDTM mapping. Ensures consistency between EDC and IRT arm definitions.',
    `irt_arm_code` STRING COMMENT 'Treatment arm code as configured in the Interactive Response Technology (IRT) / Interactive Voice Response System (IVRS) / Randomization and Trial Supply Management (RTSM) system (Medidata Rave RTSM).. Valid values are `^[A-Z0-9_-]{1,30}$`',
    `is_control_arm` BOOLEAN COMMENT 'Indicates whether this treatment arm serves as the control arm (placebo or active comparator) in the study. Used in statistical analysis to define the reference group for primary and secondary endpoint comparisons.',
    `max_subject_count` BIGINT COMMENT 'Maximum number of subjects permitted in this treatment arm. Enforced by IRT/RTSM to prevent over-enrollment. May be set for adaptive designs or safety-driven enrollment caps.',
    `min_subject_count` BIGINT COMMENT 'Minimum number of subjects required in this treatment arm to maintain statistical validity and meet protocol-defined endpoints. Used by DSMB/DMC for interim analysis decisions and by biostatistics for power calculations.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this treatment arm record. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles. Updated on every change to the record.',
    `notes` STRING COMMENT 'Free-text field for additional operational notes, clarifications, or sponsor-specific instructions related to this treatment arm definition. Not used for regulatory submissions; intended for internal data management and CTMS operational use.',
    `planned_subject_count` BIGINT COMMENT 'Target number of subjects planned for enrollment and randomization into this treatment arm as defined in the study protocol and sample size calculation. Used for enrollment tracking, site feasibility, and supply planning.',
    `protocol_section_reference` STRING COMMENT 'Reference to the specific section(s) of the study protocol document that defines this treatment arm (e.g., Section 5.2 - Treatment Arms and Dosing Regimen).',
    `randomization_method` STRING COMMENT 'Statistical randomization method used to allocate subjects to this treatment arm. Drives IRT/RTSM algorithm configuration in Medidata Rave RTSM and the source system Documented in the the source system. Valid values are `simple|block|stratified|minimization|adaptive|covariate_adaptive`',
    `regulatory_submission_flag` BOOLEAN COMMENT 'Indicates whether this treatment arm definition has been included in a regulatory submission (IND, NDA, BLA, MAA, or CTD). Used for submission readiness tracking and eCTD package assembly in Veeva Vault.',
    `route_of_administration` STRING COMMENT 'Route of administration; implements SDTM --ROUTE (e.g., EX.EXROUTE) / USDM AdministrableProduct route; governed by CDISC CT ROUTE codelist.',
    `sap_section_reference` STRING COMMENT 'Reference to the Statistical Analysis Plan (the source system) section that defines the analysis methodology for this treatment arm. Ensures traceability between arm definitions and the pre-specified statistical analysis approach used in SAS Drug',
    `sdtm_arm_value` DECIMAL(18,2) COMMENT 'SDTM ARM value reference; implements SDTM DM.ARM/ARMCD.',
    `stratification_factors` STRING COMMENT 'Comma-separated list of stratification factors applied during randomization to this arm (e.g., region, disease severity, prior treatment). Defined in the protocol and the source system.',
    `suspension_reason` STRING COMMENT 'Reason for temporary suspension of randomization to this treatment arm (e.g., safety signal, supply shortage, protocol amendment). Documented for regulatory compliance and DSMB/DMC review. Populated only when arm_status is suspended.',
    `target_allocation_pct` DECIMAL(5,2) COMMENT 'Target percentage of randomized subjects to be allocated to this treatment arm as specified in the Statistical Analysis Plan (the source system) and protocol. Used for enrollment monitoring, supply forecasting, and IRT/RTSM configuration.',
    `treatment_description` STRING COMMENT 'Free-text treatment description; implements USDM StudyArm.description / SDTM TA.ETCD element description.',
    `unblinding_procedure` STRING COMMENT 'Description of the emergency unblinding procedure applicable to this treatment arm, including authorized personnel, system access method (e.g., IRT/IVRS emergency unblinding), and documentation requirements.',
    `washout_period_days` BIGINT COMMENT 'Number of days required for washout between treatment periods for this arm in crossover or multi-period study designs. Defined in the protocol based on pharmacokinetic (PK) half-life data. Used for visit scheduling and IRT/RTSM period management.',
    CONSTRAINT pk_treatment_arm PRIMARY KEY(`treatment_arm_id`)
) COMMENT 'Master definition of each treatment arm within a clinical study. Captures arm name, arm code, arm type (experimental, active comparator, placebo, open-label extension), blinding role, target allocation percentage, and arm status.';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` (
    `stratification_factor_id` BIGINT COMMENT 'Unique surrogate identifier for the stratification factor record within the randomization scheme. Primary key for this entity.',
    `rand_scheme_id` BIGINT COMMENT 'Reference to the parent randomization scheme to which this stratification factor belongs. Each factor is owned by exactly one scheme.',
    `regulatory_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to regulatory.regulatory_protocol_amendment. Business justification: Stratification factors are frequently added, modified, or removed via protocol amendments.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this stratification factor is defined. Enables direct study-level filtering without joining through the scheme.',
    `adam_variable` STRING COMMENT 'Target ADaM variable name for this stratification factor; implements ADaM variable reference (e.g., ADaM STRATxxx).',
    `approval_date` DATE COMMENT 'The date on which this stratification factor configuration was formally approved by the biostatistics or RTSM team. Required for regulatory audit trail and TMF documentation.',
    `covariate_adjustment_method` STRING COMMENT 'Statistical method used to adjust for this stratification factor in the primary analysis: ancova for Analysis of Covariance, cmh for Cochran-Mantel-Haenszel test, logistic_regression for binary endpoints, none if not used as a covariate in. Valid values are `ancova|cmh|logistic_regression|none`',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this stratification factor record was first created in the data platform, in ISO 8601 format with timezone offset. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `data_source_type` STRING COMMENT 'Identifies the system or method from which the stratification factor value is captured at randomization: ecrf from the EDC eCRF, ivrs from Interactive Voice Response System, irt from IRT/RTSM, central_lab from laboratory results, manual_entry. Valid values are `ecrf|ivrs|irt|central_lab|manual_entry`',
    `ecrf_field_reference` STRING COMMENT 'The eCRF form and field identifier in the EDC system (e.g., Medidata Rave) from which the stratification factor value is sourced at the time of randomization (e.g., SCREENING.DISVSEV). Enables traceability from randomization to source data.',
    `effective_end_date` DATE COMMENT 'The date on which this stratification factor ceased to be effective for new randomizations, typically due to protocol amendment or study close-out. Null for currently active factors.',
    `effective_start_date` DATE COMMENT 'The date from which this stratification factor became effective for subject randomization, typically aligned with protocol approval or amendment effective date. Subjects randomized on or after this date are stratified using this factor.',
    `factor_code` STRING COMMENT 'Short, system-level alphanumeric code uniquely identifying the stratification factor within the scheme (e.g., REGION, DISEASE_STAGE, GENDER). Used as the programmatic key in RTSM/IRT configuration and SDTM mapping.. Valid values are `^[A-Z][A-Z0-9_]{1,29}$`',
    `factor_description` STRING COMMENT 'Detailed narrative description of the stratification factor, including its clinical rationale, how it is assessed, and its role in balancing treatment arms as documented in the Statistical Analysis Plan.',
    `factor_name` STRING COMMENT 'Human-readable name of the stratification factor as displayed in the RTSM/IRT interface and statistical analysis plan (e.g., Geographic Region, Baseline Disease Severity, Prior Treatment Status).',
    `factor_status` STRING COMMENT 'Lifecycle status of the stratification factor within the scheme design workflow: draft during initial configuration, approved after biostatistics/RTSM sign-off, active when live in the IRT system, suspended during protocol amendment review. Valid values are `draft|approved|active|suspended|retired`',
    `factor_type` STRING COMMENT 'Classification of the factors measurement scale: categorical for nominal groupings (e.g., region), continuous_binned for numeric ranges converted to categories (e.g., age groups), ordinal for ranked categories (e.g., disease severity), binary for. Valid values are `categorical|continuous_binned|ordinal|binary`',
    `irt_parameter_name` STRING COMMENT 'The exact parameter name as configured in the IRT/IVRS/RTSM system (e.g., Medidata Rave RTSM or the source system for this stratification factor. Used for system integration and UAT validation.',
    `is_active` BOOLEAN COMMENT 'Indicates whether this stratification factor is currently active and in use for subject randomization (True) or has been deactivated via protocol amendment (False). Inactive factors are retained for historical traceability.',
    `is_blinded` BOOLEAN COMMENT 'Indicates whether the stratification factor value is masked from unblinded personnel (True) or visible to all study team members (False). Relevant for double-blind studies where certain stratification criteria could reveal treatment assignment.',
    `is_primary_factor` BOOLEAN COMMENT 'Indicates whether this factor is designated as a primary stratification factor (True) versus a secondary or exploratory factor (False) in the Statistical Analysis Plan. Primary factors are used in the primary efficacy analysis.',
    `is_used_in_primary_analysis` BOOLEAN COMMENT 'Indicates whether this stratification factor is included as a covariate in the primary statistical analysis model (True) or is used only for randomization balance without inclusion in the primary analysis (False).',
    `level_count` BIGINT COMMENT 'Total number of enumerated levels (strata) defined for this stratification factor. Drives the dimensionality of the stratification matrix and the number of randomization lists required. For example, a 3-region factor has level_count = 3.',
    `max_imbalance_threshold` DECIMAL(5,2) COMMENT 'The maximum allowable imbalance (as a percentage or absolute count, per unit_of_imbalance) between treatment arms within any stratum defined by this factor before a balancing action is triggered in the minimization algorithm.',
    `minimization_variant` STRING COMMENT 'Specific variant of the minimization algorithm applied for this factor: pocock_simon for the Pocock-Simon method, weighted_minimization for factor-weighted minimization, biased_coin for biased-coin minimization, deterministic for deterministic. Valid values are `pocock_simon|weighted_minimization|biased_coin|deterministic|none`',
    `minimization_weight` DECIMAL(5,4) COMMENT 'Numeric weight assigned to this stratification factor in a minimization or weighted minimization algorithm (e.g., Pocock-Simon). Values typically range from 0.0 to 1.0, with higher weights indicating greater influence on treatment allocation balance.',
    `missing_value_handling` STRING COMMENT 'Defines the RTSM system behavior when the stratification factor value is missing or unknown at the time of randomization: block_randomization to prevent randomization, assign_default_level to use a pre-specified default level, flag_and_hold to alert. Valid values are `block_randomization|assign_default_level|flag_and_hold|exclude_from_minimization`',
    `notes` STRING COMMENT 'Free-text field for additional operational notes, biostatistician comments, or RTSM configuration remarks related to this stratification factor that do not fit into structured fields. Not used for regulatory submissions.',
    `protocol_section_reference` STRING COMMENT 'Reference to the specific section of the study protocol document that defines this stratification factor (e.g., Section 8.2.1 Stratification Factors). Enables traceability from the data model to the governing protocol.',
    `randomization_algorithm` STRING COMMENT 'The randomization algorithm applied in conjunction with this stratification factor: permuted_block for block randomization within strata, minimization for adaptive minimization, stratified_block for stratified permuted block, dynamic_allocation. Valid values are `permuted_block|minimization|stratified_block|dynamic_allocation`',
    `rtsm_factor_code` STRING COMMENT 'The native identifier assigned to this stratification factor within the source RTSM/IRT system (e.g., Medidata Rave RTSM internal factor ID or the source system factor GUID). Used for system integration, reconciliation, and audit trail linkage.',
    `rtsm_system` STRING COMMENT 'Identifies the RTSM/IRT/IVRS system in which this stratification factor is configured and operationalized for subject randomization and kit assignment.. Valid values are `medidata_rave_rtsm|oracle_clinical_one|ivrs|other`',
    `sap_section_reference` STRING COMMENT 'Reference to the specific section of the Statistical Analysis Plan that describes the use of this stratification factor in primary and sensitivity analyses (e.g., the source system Stratification). Supports regulatory audit traceability.',
    `sdtm_variable` STRING COMMENT 'Target SDTM variable name for this stratification factor; implements SDTM variable reference.',
    `sort_order` BIGINT COMMENT 'Integer defining the display and processing sequence of this stratification factor within the randomization scheme. Lower values appear first in RTSM screens, the source system stratification matrix axes.',
    `unit_of_imbalance` STRING COMMENT 'Specifies whether the max_imbalance_threshold is expressed as a percentage of subjects within the stratum or as an absolute subject_count. Determines how the RTSM system evaluates balance during randomization.. Valid values are `percentage|subject_count`',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time when this stratification factor record was last modified in the data platform. Tracks configuration changes and supports change control audit trail under 21 CFR Part 11.',
    `validation_rule` STRING COMMENT 'Business rule or logical expression applied to validate the stratification factor value at the time of randomization (e.g., BMIBL >= 18 AND BMIBL < 30). Prevents invalid factor assignments and ensures data integrity per ALCOA+ principles.',
    `version_number` STRING COMMENT 'Version identifier of this stratification factor definition, incremented with each protocol amendment or RTSM configuration change (e.g., 1.0, 2.0). Supports change control and audit trail requirements under 21 CFR Part 11.. Valid values are `^d+.d+$`',
    CONSTRAINT pk_stratification_factor PRIMARY KEY(`stratification_factor_id`)
) COMMENT 'Defines the stratification factors used in a randomization scheme, including factor name, factor code, data source (eCRF field reference), factor type (categorical, continuous-binned), enumerated levels (level code, label, sort order, active status), and';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` (
    `subject_randomization_id` BIGINT COMMENT 'Unique surrogate primary key for each subject randomization or re-randomization event record in the Silver layer lakehouse.',
    `blinding_config_id` BIGINT COMMENT 'Foreign key linking to randomization.blinding_config. Business justification: A subject randomization event is governed by a specific blinding configuration that determines what information is masked.',
    `consent_subject_consent_id` BIGINT COMMENT 'Foreign key linking to consent.subject_consent. Business justification: GCP requires randomization to occur only after documented informed consent. Linking subject_randomization to the specific subject_consent record that authorized randomization supports',
    `icf_version_id` BIGINT COMMENT 'Reference to the version of the Informed Consent Form (ICF) that was in effect and signed by the subject prior to this randomization event. Ensures regulatory compliance that valid consent preceded randomization.',
    `investigational_site_id` BIGINT COMMENT 'Foreign key linking to site.investigational_site. Business justification: GCP requires that the person performing randomization is formally assigned to the study with an authorized role.',
    `irt_transaction_id` BIGINT COMMENT 'The unique transaction reference number generated by the IRT/IVRS/RTSM system (Medidata Rave RTSM or the source system at the time of the randomization call. Used for audit trail reconciliation between the EDC and RTSM systems.',
    `original_randomization_subject_randomization_id` BIGINT COMMENT 'For re-randomization events, the subject_randomization_id of the original randomization record that this event supersedes. Null for initial randomization events. Enables lineage tracing across re-randomization chains.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Each randomization event is performed under a specific protocol version; when a subject is randomized after a protocol amendment, the applicable version must be recorded for GCP compliance',
    `rand_code_id` BIGINT COMMENT 'Foreign key linking to randomization.rand_code. Business justification: A subject randomization event consumes exactly one rand_code slot from the randomization list.',
    `rand_list_id` BIGINT COMMENT 'Foreign key linking to randomization.rand_list. Business justification: A subject randomization event is performed against a specific randomization list version.',
    `rand_scheme_id` BIGINT COMMENT 'Foreign key linking to randomization.stratification_cell. Business justification: A subject is randomized into a specific stratification cell based on their baseline characteristics.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study under which this randomization event occurred. Links to the study master record.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site at which the subject was randomized.',
    `study_visit_schedule_id` BIGINT COMMENT 'Foreign key linking to study.study_visit_schedule. Business justification: Randomization occurs at a specific protocol-defined visit (flagged is_randomization_visit in study_visit_schedule).',
    `treatment_arm_id` BIGINT COMMENT 'Foreign key linking to randomization.treatment_arm. Business justification: A subject randomization event assigns the subject to exactly one treatment arm.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the clinical trial subject (participant) who is being randomized.',
    `blinding_type` STRING COMMENT 'Blinding type; implements CDISC SDTM TS parameter BLIND.. Valid values are `open_label|single_blind|double_blind|triple_blind`',
    `block_number` BIGINT COMMENT 'The block number within the randomization schedule from which this subjects allocation was drawn. Confidential to preserve blinding integrity during the study. Used for post-DBL stratification balance verification.',
    `cancellation_reason` STRING COMMENT 'The documented reason for cancellation of the randomization event. Null for non-cancelled records. Required for audit trail completeness and IRT reconciliation.. Valid values are `irt_error|screen_failure|duplicate_entry|sponsor_request|other`',
    `cancellation_timestamp` TIMESTAMP COMMENT 'The date and time at which a randomization event was cancelled or voided in the IRT/RTSM system. Null for active or completed randomizations. Format: yyyy-MM-ddTHH:mm:ss.SSSXXX.',
    `comments` STRING COMMENT 'Free-text field for site staff or sponsor to document any notable circumstances surrounding the randomization event (e.g., IRT system downtime, manual override justification, protocol deviation context). Supports audit trail narrative.',
    `country_code` STRING COMMENT 'Country code; implements SDTM DM.COUNTRY (ISO 3166).. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time at which this randomization record was first captured in the Silver layer lakehouse. Supports audit trail and data lineage requirements per ALCOA+ and 21 CFR Part 11. Format: yyyy-MM-ddTHH:mm:ss.SSSXXX.',
    `eligibility_confirmed` BOOLEAN COMMENT 'Indicates whether all inclusion/exclusion criteria were confirmed as met prior to this randomization event (True = confirmed eligible; False = eligibility not confirmed or waived). Supports protocol deviation detection and ITT/PP population analysis.',
    `irt_system_name` STRING COMMENT 'Name of the IRT/IVRS/RTSM system that processed the randomization transaction. Supports multi-system audit trails and source data verification (SDV) activities.. Valid values are `Medidata Rave RTSM|Oracle Clinical One|IVRS|Other`',
    `is_unblinded` BOOLEAN COMMENT 'Indicates whether the blinding for this subjects randomization has been broken (True = unblinded; False = still blinded). Critical for blinding integrity monitoring and DSMB/DMC reporting. Triggers downstream safety and regulatory workflows when True.',
    `kit_number` STRING COMMENT 'The investigational product kit number assigned to the subject at randomization by the RTSM system. Links the randomization event to the supply chain dispensing record. Sourced from Medidata Rave RTSM kit assignment transaction.',
    `randomization_date` DATE COMMENT 'Randomization date; implements SDTM DS.DSSTDTC (RANDOMIZED) / DM.RFSTDTC-related date.',
    `randomization_method` STRING COMMENT 'The statistical randomization algorithm applied to generate this allocation (e.g., permuted block, minimization, stratified block). Defined in the Statistical Analysis Plan (the source system) and randomization specification document.. Valid values are `permuted_block|minimization|stratified_block|dynamic|simple`',
    `randomization_number` STRING COMMENT 'Subject randomization number; implements SDTM DM.SUBJID-linked randomization identifier; person-identifying.',
    `randomization_status` STRING COMMENT 'Current lifecycle status of this randomization event. randomized indicates a successful initial allocation; re-randomized indicates a subsequent allocation event; cancelled indicates the randomization was voided; pending indicates the IRT. Valid values are `randomized|cancelled|re-randomized|pending|failed`',
    `randomization_timestamp` TIMESTAMP COMMENT 'The exact date and time (with timezone offset) at which the subject was randomized by the IRT/IVRS/RTSM system. This is the principal business event timestamp and the ALCOA+ contemporaneous record of the allocation event.',
    `randomization_type` STRING COMMENT 'Classifies whether this record represents an initial randomization event, a re-randomization (subject re-entering the study), or a replacement randomization (e.g., IRT error correction). Drives downstream analysis population flags (ITT, PP).. Valid values are `initial|re-randomization|replacement`',
    `randomizing_user_role` STRING COMMENT 'The role of the user or system that performed the randomization (e.g., CRC - Clinical Research Coordinator, PI - Principal Investigator, IRT_system for automated randomizations). Supports delegation log compliance and audit trail.. Valid values are `CRC|CRA|PI|IRT_system|sponsor_user|other`',
    `rerandomization_reason` STRING COMMENT 'The documented reason for re-randomizing the subject. Null for initial randomization events. Required for protocol deviation tracking and regulatory submission narratives.. Valid values are `screen_failure_reentry|protocol_deviation|irt_error|investigator_request|other`',
    `sequence_within_block` BIGINT COMMENT 'The position of this subjects allocation within the randomization block. Confidential to preserve blinding integrity. Used post-DBL for randomization quality review and biostatistical verification.',
    `source_record_reference` STRING COMMENT 'The native primary key or record identifier of this randomization event in the originating source system (Medidata Rave RTSM or the source system Enables bidirectional traceability between the lakehouse Silver layer and the operational system.',
    `stratification_factor_1_value` DECIMAL(18,2) COMMENT 'The value of the first protocol-defined stratification factor captured at the time of randomization (e.g., disease severity: mild/moderate/severe). Stored individually to support stratification balance analytics and CDISC SDTM SUPPRAND dataset generation.',
    `stratification_factor_2_value` DECIMAL(18,2) COMMENT 'The value of the second protocol-defined stratification factor captured at the time of randomization (e.g., geographic region: North America/Europe/Asia-Pacific). Supports stratification balance reporting and CDISC SDTM SUPPRAND.',
    `stratification_factor_3_value` DECIMAL(18,2) COMMENT 'The value of the third protocol-defined stratification factor captured at the time of randomization (e.g., prior treatment: yes/no). Nullable when fewer than three stratification factors are defined in the protocol.',
    `subject_number` STRING COMMENT 'Subject identifier; implements SDTM DM.SUBJID; person-identifying (PII).',
    `unblinding_reason` STRING COMMENT 'The documented reason for breaking the blind for this subjects randomization. Null if still blinded. Required for regulatory audit trail and DSMB/DMC reporting.. Valid values are `safety_emergency|dsmb_review|regulatory_request|study_completion|other`',
    `unblinding_timestamp` TIMESTAMP COMMENT 'The date and time at which the blinding was broken for this subjects randomization. Null if the subject remains blinded. Format: yyyy-MM-ddTHH:mm:ss.SSSXXX.',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time at which this randomization record was last modified in the Silver layer lakehouse. Tracks data corrections, status transitions, and unblinding events. Format: yyyy-MM-ddTHH:mm:ss.SSSXXX.',
    CONSTRAINT pk_subject_randomization PRIMARY KEY(`subject_randomization_id`)
) COMMENT 'Transactional record of a subjects randomization or re-randomization event. Captures the subject identifier, study site, randomization number assigned, treatment arm allocated, stratification cell, randomization timestamp, IRT/IVRS transaction reference';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` (
    `irt_transaction_id` BIGINT COMMENT 'Unique surrogate identifier for each IRT/IVRS/RTSM transaction record in the silver layer lakehouse. Primary key for this data product.',
    `clinical_trial_authorization_id` BIGINT COMMENT 'Foreign key linking to regulatory.clinical_trial_authorization. Business justification: IRT dispensing and randomization transactions occur under a country-specific CTA. Regulatory compliance requires confirming the CTA was active at transaction time.',
    `depot_id` BIGINT COMMENT 'The identifier of the supply depot or pharmacy from which the investigational product kit was sourced for this transaction. Supports supply chain traceability and depot-level inventory reconciliation.',
    `investigational_site_id` BIGINT COMMENT 'Foreign key linking to site.investigational_site. Business justification: IRT system integration logs and site facility audit trails require physical site tracking independent of study context.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study under which this IRT transaction was executed. Links the transaction to the parent protocol and sponsor.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site at which the IRT transaction was initiated. Used for site-level monitoring and SDV reconciliation.',
    `study_visit_schedule_id` BIGINT COMMENT 'Foreign key linking to study.study_visit_schedule. Business justification: IRT transactions (randomization, dispensing, return) are triggered at specific protocol visits.',
    `treatment_arm_id` BIGINT COMMENT 'Foreign key linking to randomization.treatment_arm. Business justification: IRT transactions record the treatment arm code assigned or dispensed during the transaction.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial subject (patient) involved in this IRT transaction, such as the subject being randomized or receiving a kit dispensing.',
    `blinding_status` STRING COMMENT 'Indicates the blinding state of the transaction at the time of execution. Tracks whether the treatment assignment was revealed (unblinded) as part of an emergency unblinding or DSMB/DMC review.. Valid values are `blinded|unblinded|partially_unblinded`',
    `cancellation_reason` STRING COMMENT 'The documented reason for cancellation of a randomization, kit assignment, or other IRT transaction. Required for GCP audit trail when transaction_type is cancellation or transaction_status is cancelled.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this IRT transaction record was first captured and persisted in the data platform (silver layer). Supports ALCOA+ attributability and audit trail requirements.',
    `dispensing_date` DATE COMMENT 'The calendar date on which the investigational product kit was dispensed to the subject. Relevant for kit_assignment transaction types. Used for supply chain reconciliation and compliance with protocol dispensing windows.',
    `dose_level` STRING COMMENT 'The dose level assigned or changed during this IRT transaction (e.g., 10mg, 20mg, 40mg). Relevant for dose-change and titration transaction types. Captured as a string to accommodate protocol-defined dose descriptors.',
    `electronic_signature_flag` BOOLEAN COMMENT 'Indicates whether the IRT transaction was executed with a valid electronic signature as required by 21 CFR Part 11 and EU Annex 11. True if an e-signature was captured; False if not applicable or not captured.',
    `expiry_date` DATE COMMENT 'The expiration date of the investigational product kit assigned during this transaction. Critical for supply chain compliance to ensure no expired kits are dispensed to subjects.',
    `failure_reason` STRING COMMENT 'Free-text or coded reason describing why the IRT transaction failed or was cancelled. Populated only when transaction_outcome is failure or transaction_status is cancelled/failed. Supports root cause analysis and CAPA.',
    `irt_config_version` STRING COMMENT 'The validated configuration version of the IRT/RTSM system build active at the time of the transaction. Required for regulatory audit trail to confirm the correct randomization schedule and supply rules were applied.',
    `irt_system_name` STRING COMMENT 'The name of the IRT/IVRS/RTSM system that generated this transaction (e.g., Medidata Rave RTSM, the source system IXRS). Supports multi-system study environments and source system traceability.',
    `irt_system_reference_number` STRING COMMENT 'The externally-known unique transaction reference number assigned by the IRT/IVRS/RTSM system (e.g., Medidata Rave RTSM transaction ID). Used for cross-system reconciliation and audit trail.',
    `irt_system_version` STRING COMMENT 'The validated version of the IRT/RTSM system at the time the transaction was executed. Required for regulatory submission traceability and system validation documentation per 21 CFR Part 11.',
    `kit_number` STRING COMMENT 'The unique identifier of the investigational product kit assigned to the subject during this IRT transaction. Links to the supply chain domain for kit tracking, expiry management, and depot reconciliation.',
    `kit_type` STRING COMMENT 'Classification of the investigational product kit assigned (e.g., active, placebo, rescue medication, titration pack). Supports supply chain analytics and blinding verification.',
    `notes` STRING COMMENT 'Free-text field for additional comments or annotations entered by the operator at the time of the IRT transaction. Captures contextual information not covered by structured fields, such as site-specific circumstances.',
    `operator_role` STRING COMMENT 'The functional role of the operator who performed the IRT transaction (e.g., Clinical Research Coordinator (CRC), Clinical Research Associate (CRA), Principal Investigator (PI), pharmacist). Supports access control auditing and GCP compliance.. Valid values are `CRC|CRA|PI|pharmacist|sponsor_user|system`',
    `protocol_version` STRING COMMENT 'The version of the study protocol that was in effect at the time this IRT transaction was executed. Ensures traceability of randomization and dispensing decisions to the applicable protocol amendment.',
    `query_flag` BOOLEAN COMMENT 'Indicates whether an open data discrepancy query exists against this IRT transaction record in the EDC system. Supports data management workflows and database lock readiness assessment.',
    `randomization_method` STRING COMMENT 'The algorithm or method used to generate the randomization assignment for this transaction (e.g., stratified block, minimization, dynamic). Captured from the RTSM configuration at the time of the transaction.. Valid values are `minimization|block|stratified_block|dynamic|simple`',
    `randomization_number` STRING COMMENT 'The unique randomization code assigned to the subject by the RTSM system at the time of randomization. Determines treatment arm allocation and links to the randomization schedule. Central to blinding integrity.',
    `sdv_date` DATE COMMENT 'The date on which Source Data Verification (SDV) was completed for this IRT transaction record. Populated only when sdv_flag is True.',
    `sdv_flag` BOOLEAN COMMENT 'Indicates whether this IRT transaction record has been subject to Source Data Verification (SDV) by a Clinical Research Associate (CRA). True if SDV has been completed; False if pending.',
    `source_system_record_code` STRING COMMENT 'The native primary key or record identifier of this transaction as stored in the originating IRT/RTSM source system (e.g., Medidata Rave RTSM internal record ID). Enables lineage tracing from the silver layer back to the operational system.',
    `stratification_factor_1` STRING COMMENT 'The value of the first stratification factor used in the randomization algorithm at the time of this transaction (e.g., disease severity, geographic region, age group). Captured from the RTSM at the point of randomization.',
    `stratification_factor_2` STRING COMMENT 'The value of the second stratification factor used in the randomization algorithm at the time of this transaction (e.g., prior therapy, biomarker status). Nullable if the study uses fewer than two stratification factors.',
    `stratification_factor_3` STRING COMMENT 'The value of the third stratification factor used in the randomization algorithm at the time of this transaction. Nullable if the study uses fewer than three stratification factors.',
    `subject_number` STRING COMMENT 'Subject identifier; implements SDTM DM.SUBJID; person-identifying (PII).',
    `transaction_outcome` STRING COMMENT 'The technical outcome of the IRT transaction as reported by the RTSM system, indicating whether the transaction was successfully processed or encountered an error condition. Distinct from transaction_status which reflects the business lifecycle state.. Valid values are `success|failure|partial|timeout|error`',
    `transaction_status` STRING COMMENT 'Current lifecycle state of the IRT transaction indicating whether it was successfully processed, failed, cancelled, or is pending confirmation in the RTSM system.. Valid values are `completed|failed|cancelled|pending|reversed`',
    `transaction_timestamp` TIMESTAMP COMMENT 'The precise date and time (with timezone offset) at which the IRT/IVRS/RTSM transaction event occurred in the source system. This is the principal real-world business event time, distinct from record audit timestamps.',
    `transaction_type` STRING COMMENT 'Classification of the IRT transaction indicating the business event performed. Drives downstream processing logic for supply management and randomization audit.. Valid values are `randomization|re_randomization|kit_assignment|dose_change|titration|cancellation`',
    `unblinding_reason` STRING COMMENT 'The documented reason for emergency unblinding of a subjects treatment assignment (e.g., SAE requiring knowledge of treatment, DSMB review). Populated only when blinding_status is unblinded.',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time when this IRT transaction record was last modified in the data platform. Tracks corrections, reversals, or status updates applied after initial capture.',
    CONSTRAINT pk_irt_transaction PRIMARY KEY(`irt_transaction_id`)
) COMMENT 'Detailed log of all IRT/IVRS/RTSM system transactions related to randomization and kit dispensing. Captures transaction type (randomization, re-randomization, cancellation, kit assignment, dose change, titration), transaction timestamp, IRT system';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` (
    `kit_assignment_id` BIGINT COMMENT 'Primary key for kit_assignment',
    `irt_transaction_id` BIGINT COMMENT 'The unique transaction identifier generated by the IRT/IVRS/RTSM system (e.g., Medidata Rave RTSM) at the time of kit assignment. Serves as the business key for cross-system reconciliation and audit trail.',
    `kit_inventory_id` BIGINT COMMENT 'Foreign key linking to supply.kit_inventory. Business justification: kit_assignment (RTSM-driven) must reference the physical kit_inventory record to close the loop between RTSM assignment and physical IMP stock.',
    `rand_code_id` BIGINT COMMENT 'Foreign key linking to randomization.rand_code. Business justification: A kit assignment corresponds to a specific randomization code slot. kit_assignment currently stores randomization_number (STRING) as a denormalized reference to the rand_code.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study under which this kit assignment was made. Links the kit assignment to the parent study protocol.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site where the kit was dispensed to the subject. Identifies the dispensing site for IMP accountability and supply chain tracking.',
    `study_visit_schedule_id` BIGINT COMMENT 'Foreign key linking to study.study_visit_schedule. Business justification: Kit dispensing occurs at protocol-defined visits (is_dosing_visit flag in study_visit_schedule).',
    `subject_randomization_id` BIGINT COMMENT 'Reference to the subjects randomization event that triggered this kit assignment. Establishes the link between the randomization domain and the supply/kit dispensing domain.',
    `treatment_arm_id` BIGINT COMMENT 'Foreign key linking to randomization.treatment_arm. Business justification: A kit assignment is made to a subject in a specific treatment arm. kit_assignment currently stores treatment_arm_code (STRING) and treatment_arm_description (STRING) as',
    `trial_subject_id` BIGINT COMMENT 'Reference to the enrolled study subject who received the IMP kit. Links the kit assignment to the subject randomization record for IMP accountability.',
    `visit_id` BIGINT COMMENT 'Reference to the scheduled or unscheduled study visit at which the IMP kit was dispensed to the subject.',
    `assignment_status` STRING COMMENT 'Current lifecycle status of the kit assignment record, tracking the kit from initial assignment through dispensing, return, destruction, or loss. Essential for IMP accountability and regulatory compliance.. Valid values are `Assigned|Dispensed|Returned|Destroyed|Lost|Recalled`',
    `assignment_type` STRING COMMENT 'Categorizes the reason for the kit assignment: initial dispensing at randomization, resupply at a subsequent visit, replacement of a damaged/lost kit, dose titration, or rescue medication dispensing.. Valid values are `Initial|Resupply|Replacement|Titration|Rescue`',
    `blinding_status` STRING COMMENT 'Indicates whether the kit assignment is blinded (treatment identity concealed), unblinded (treatment identity revealed, e.g., after emergency unblinding or study completion), or open-label.. Valid values are `Blinded|Unblinded|Open-Label`',
    `comments` STRING COMMENT 'Free-text field for site staff or data management to record additional notes or observations related to the kit assignment event (e.g., reason for kit replacement, notes on subject compliance, dispensing anomalies).',
    `compliance_flag` BOOLEAN COMMENT 'Indicates whether the subject demonstrated acceptable dosing compliance for this kit assignment based on the quantity dispensed versus quantity returned. True if compliance meets protocol-defined threshold; False if a compliance issue is identified.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this kit assignment record was first created in the data system. Supports ALCOA+ audit trail requirements and data lineage tracking per 21 CFR Part 11 and ICH E6(R2) GCP.',
    `dispensing_confirmed` BOOLEAN COMMENT 'Indicates whether the kit dispensing has been confirmed and acknowledged in the IRT/RTSM system by the site staff. True when confirmed; False when pending confirmation. Supports site monitoring and data quality checks.',
    `dispensing_date` DATE COMMENT 'The calendar date on which the IMP kit was physically dispensed to the subject at the investigational site. Corresponds to the CDISC SDTM EXSTDTC (Exposure Start Date) and is critical for dosing compliance and PK/PD analysis.',
    `dispensing_timestamp` TIMESTAMP COMMENT 'The precise date and time at which the IMP kit dispensing transaction was recorded in the IRT/RTSM system. Supports ALCOA+ compliance (Attributable, Legible, Contemporaneous, Original, Accurate) for audit trail purposes.',
    `dosage_form` STRING COMMENT 'Dose form; implements SDTM EC.ECDOSFRM/EX.EXDOSFRM; governed by CDISC CT dose form codelist.',
    `dose_level` STRING COMMENT 'The protocol-defined dose level associated with the kit (e.g., Low Dose, High Dose, 10mg, 50mg). Supports dose-response analysis and PK/PD modeling. May differ from treatment arm in dose-escalation or titration studies.',
    `irt_system_name` STRING COMMENT 'Name of the IRT/IVRS/RTSM system that generated and recorded the kit assignment transaction. Important for multi-system studies and audit trail traceability.. Valid values are `Medidata Rave RTSM|Oracle Clinical One|IVRS|Other`',
    `kit_batch_number` STRING COMMENT 'The manufacturing batch or lot number of the IMP kit. Required for IMP accountability, pharmacovigilance investigations, and regulatory submissions. Enables traceability from subject exposure back to the manufacturing batch.',
    `kit_expiry_date` DATE COMMENT 'The expiration date of the IMP kit as labeled by the manufacturer or packaging facility. Ensures that expired kits are not dispensed to subjects and supports IMP accountability and supply chain management.',
    `kit_number` STRING COMMENT 'The unique alphanumeric identifier assigned to the investigational medicinal product (IMP) kit by the RTSM/IRT system or packaging facility. Used for IMP accountability and reconciliation across the supply chain.',
    `kit_type` STRING COMMENT 'Classification of the investigational medicinal product kit indicating whether it contains active IMP, placebo, comparator drug, rescue medication, or is open-label or blinded. Critical for treatment arm integrity and blinding management.. Valid values are `IMP|Placebo|Comparator|Rescue Medication|Open-Label|Blinded`',
    `protocol_deviation_flag` BOOLEAN COMMENT 'Indicates whether a protocol deviation was associated with this kit assignment event (e.g., wrong kit dispensed, kit dispensed outside the protocol visit window, expired kit dispensed). True if a deviation is linked; False otherwise.',
    `quantity_dispensed` BIGINT COMMENT 'The number of IMP units (e.g., tablets, vials, patches) dispensed to the subject as part of this kit assignment. Used for dosing compliance calculations and IMP accountability reconciliation.',
    `quantity_returned` BIGINT COMMENT 'The number of IMP units returned by the subject from this kit assignment. Used to calculate compliance (quantity dispensed minus quantity returned) and for IMP accountability at site level.',
    `randomization_number` STRING COMMENT 'The unique randomization number assigned to the subject by the IRT/IVRS/RTSM system at the time of randomization. Serves as the primary cross-reference between the randomization event and the kit dispensing record.',
    `return_date` DATE COMMENT 'The date on which the subject returned unused IMP units from this kit assignment to the investigational site. Null if no return has occurred or is not applicable.',
    `return_status` STRING COMMENT 'Indicates the current return status of the IMP kit: whether return is pending, the kit has been returned, the return requirement has been waived, or return is not applicable (e.g., fully consumed). Supports IMP accountability and site monitoring.. Valid values are `Pending|Returned|Waived|Not Applicable`',
    `route_of_administration` STRING COMMENT 'Route of administration; implements SDTM EC.ECROUTE/EX.EXROUTE; governed by CDISC CT ROUTE codelist.',
    `stratification_factor_1` STRING COMMENT 'The value of the first stratification factor applied at randomization for this subject (e.g., Disease Severity: Mild, Region: North America). Captured at the time of kit assignment to preserve the randomization context for statistical analysis.',
    `stratification_factor_2` STRING COMMENT 'The value of the second stratification factor applied at randomization for this subject (e.g., Prior Treatment: Yes/No, Age Group: <65/≥65). Null if fewer than two stratification factors are defined in the protocol.',
    `subject_number` STRING COMMENT 'Subject identifier; implements SDTM DM.SUBJID; person-identifying (PII).',
    `temperature_excursion_flag` BOOLEAN COMMENT 'Indicates whether a temperature excursion was reported for this kit prior to or during dispensing. True if a temperature excursion was recorded; False otherwise. Relevant for temperature-sensitive IMPs and IMP accountability.',
    `unblinding_date` DATE COMMENT 'The date on which the kit assignment was unblinded, revealing the treatment arm identity. Populated only when blinding_status transitions to Unblinded. Null for blinded or open-label assignments.',
    `unblinding_reason` STRING COMMENT 'The documented reason for emergency or planned unblinding of the kit assignment, if applicable (e.g., SAE requiring treatment knowledge, Study completion, DSMB review). Null if the kit remains blinded.',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time when this kit assignment record was last modified. Supports ALCOA+ audit trail requirements and change tracking per 21 CFR Part 11 electronic records regulations.',
    CONSTRAINT pk_kit_assignment PRIMARY KEY(`kit_assignment_id`)
) COMMENT 'Records the assignment of an investigational medicinal product (IMP) kit to a subject at a specific visit, as triggered by the IRT/RTSM system following randomization or resupply.';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` (
    `blinding_config_id` BIGINT COMMENT 'Unique surrogate identifier for the blinding configuration record within the randomization domain.',
    `document_sop_id` BIGINT COMMENT 'Foreign key linking to document.document_sop. Business justification: Blinding configurations are governed by a blinding maintenance SOP. GCP requires traceability between the blinding plan and the SOP defining how blinding is maintained and broken; this',
    `icf_version_id` BIGINT COMMENT 'Foreign key linking to consent.consent_icf_version. Business justification: ICF-blinding consistency review: regulators require that the ICF version disclosed to subjects accurately reflects the approved blinding methodology.',
    `previous_version_blinding_config_id` BIGINT COMMENT 'Reference to the immediately preceding version of this blinding configuration, enabling version chain traceability for regulatory audit and TMF completeness.',
    `rand_scheme_id` BIGINT COMMENT 'Reference to the parent randomization scheme to which this blinding configuration belongs, linking blinding rules to the allocation algorithm.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Blinding procedures are essential TMF documents per ICH E6 R2 and DIA Reference Model. blinding_config has document_sop_id but no tmf_document_id.',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time at which this blinding configuration was formally approved, captured as an auditable electronic record per 21 CFR Part 11 and ALCOA+ principles.',
    `blinding_method` STRING COMMENT 'Physical or procedural technique used to maintain blinding integrity: identical_packaging (active and placebo packaged identically), dummy_tablets (inert tablets matching active), double_dummy (two sets of dummy treatments for crossover). Valid values are `identical_packaging|dummy_tablets|double_dummy|over_encapsulation|matching_placebo|other`',
    `blinding_rationale` STRING COMMENT 'Narrative justification for the selected blinding type and method as documented in the study protocol, explaining why the chosen approach is scientifically and ethically appropriate.',
    `blinding_type` STRING COMMENT 'Classification of the blinding design applied to the study: open_label (all parties aware of treatment), single_blind (subject unaware), double_blind (subject and investigator unaware), triple_blind (subject, investigator, and sponsor/CRA unaware).. Valid values are `open_label|single_blind|double_blind|triple_blind`',
    `config_code` STRING COMMENT 'Externally-known alphanumeric code uniquely identifying this blinding configuration, used in RTSM/IRT system references and regulatory documentation (e.g., BLIND-001, BC-STUDY-A-DBL).. Valid values are `^[A-Z0-9_-]{3,30}$`',
    `config_name` STRING COMMENT 'Human-readable name describing this blinding configuration, used in CTMS and study documentation (e.g., Double-Blind Double-Dummy Phase III Config).',
    `config_status` STRING COMMENT 'Current lifecycle state of the blinding configuration: draft (under development), active (in use for the study), superseded (replaced by a newer version), retired (no longer applicable).. Valid values are `draft|active|superseded|retired`',
    `cra_blinded` BOOLEAN COMMENT 'Indicates whether Clinical Research Associates (CRAs) performing site monitoring are blinded to treatment assignment. True = CRA cannot see treatment arm during Source Data Verification (SDV).',
    `created_timestamp` TIMESTAMP COMMENT 'System-generated timestamp recording when this blinding configuration record was first created in the data platform, supporting audit trail and ALCOA+ compliance.',
    `dsmb_unblinded` BOOLEAN COMMENT 'Indicates whether the Data Safety Monitoring Board (DSMB) / Data Monitoring Committee (DMC) has access to unblinded treatment data for interim safety reviews. True = DSMB operates with unblinded data.',
    `edc_access_restricted` BOOLEAN COMMENT 'Indicates whether the EDC system (e.g., Medidata Rave) enforces field-level or form-level access restrictions to prevent blinded users from viewing treatment assignment data in the eCRF.',
    `effective_from_date` DATE COMMENT 'Date from which this blinding configuration becomes binding and operationally enforced for the study, aligned with protocol version effective date.',
    `effective_until_date` DATE COMMENT 'Date on which this blinding configuration ceases to be binding. Null indicates the configuration remains in effect indefinitely or until superseded.',
    `emergency_unblinding_allowed` BOOLEAN COMMENT 'Indicates whether emergency unblinding is permitted at the site level for individual subjects in life-threatening situations, as governed by the protocol and IRB/IEC approval.',
    `gdpr_applicable` BOOLEAN COMMENT 'Indicates whether GDPR data protection requirements apply to the blinding configuration and associated treatment assignment data, relevant for EU-based studies or EU subject data.',
    `hipaa_applicable` BOOLEAN COMMENT 'Indicates whether HIPAA privacy and security rules apply to the blinding configuration and associated treatment data, relevant for US-based studies involving protected health information (PHI).',
    `interim_analysis_unblinding` BOOLEAN COMMENT 'Indicates whether treatment assignment data is unblinded for interim analysis purposes (e.g., for DSMB/DMC review or adaptive design decisions). True = unblinded interim analysis is planned.',
    `investigator_blinded` BOOLEAN COMMENT 'Indicates whether the Principal Investigator (PI) and site staff are blinded to treatment assignment. True = investigator does not know the subjects treatment arm.',
    `irb_iec_approval_date` DATE COMMENT 'Date on which the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) approved this blinding configuration as part of the study protocol review.',
    `irb_iec_approval_required` BOOLEAN COMMENT 'Indicates whether changes to this blinding configuration require prior approval from the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) before implementation.',
    `irt_system_enforced` BOOLEAN COMMENT 'Indicates whether blinding access controls are enforced programmatically within the IRT/IVRS/RTSM system (e.g., Medidata Rave RTSM). True = system prevents unauthorized access to treatment codes.',
    `kit_label_blinded` BOOLEAN COMMENT 'Indicates whether investigational product kit labels are blinded (i.e., do not reveal treatment assignment). True = kit labels show only kit number and dispensing instructions, not treatment identity.',
    `modified_timestamp` TIMESTAMP COMMENT 'System-generated timestamp recording the most recent modification to this blinding configuration record, supporting change audit trail and ALCOA+ compliance.',
    `notes` STRING COMMENT 'Free-text field for additional operational notes, special instructions, or clarifications regarding this blinding configuration not captured in structured fields (e.g., site-specific blinding exceptions, packaging vendor notes).',
    `randomization_code_masked` BOOLEAN COMMENT 'Indicates whether the randomization code (treatment arm identifier) is masked/encrypted in the RTSM and EDC systems for blinded users. True = treatment codes are not visible to blinded roles.',
    `sae_unblinding_policy` STRING COMMENT 'Policy governing whether treatment assignment is unblinded when a Serious Adverse Event (SAE) or Suspected Unexpected Serious Adverse Reaction (SUSAR) is reported: always_unblind, unblind_if_susar (only for SUSARs), maintain_blind (blinding maintained for. Valid values are `always_unblind|unblind_if_susar|maintain_blind|case_by_case`',
    `sponsor_blinded` BOOLEAN COMMENT 'Indicates whether sponsor personnel are blinded to treatment assignment. True = sponsor staff cannot access unblinded treatment data during the study.',
    `statistician_blinded` BOOLEAN COMMENT 'Indicates whether the biostatistician is blinded to treatment assignment during analysis. True = statistician works with blinded data until Database Lock (DBL) and unblinding per the Statistical Analysis Plan (the source system).',
    `subject_blinded` BOOLEAN COMMENT 'Indicates whether the study subject (patient) is blinded to their treatment assignment. True = subject does not know their treatment arm.',
    `unblinding_authorization_roles` STRING COMMENT 'Comma-separated list of organizational roles authorized to initiate or approve unblinding (e.g., Medical Monitor, Pharmacovigilance Lead, DSMB Chair). Governs system-enforced access controls in RTSM/IRT.',
    `unblinding_documentation_required` BOOLEAN COMMENT 'Indicates whether each unblinding event must be formally documented with reason, date, and authorizing personnel, as required for regulatory audit trail and TMF completeness.',
    `unblinding_procedure` STRING COMMENT 'Defined procedure by which treatment assignment may be revealed: emergency_envelope (physical sealed envelope at site), irt_system (automated unblinding via IRT/IVRS/RTSM), sponsor_pharmacovigilance (unblinding for SAE/SUSAR reporting), dsmb_request. Valid values are `emergency_envelope|irt_system|sponsor_pharmacovigilance|dsmb_request|study_completion`',
    `version_number` STRING COMMENT 'Version identifier for this blinding configuration record, supporting change control and audit trail requirements (e.g., 1.0, 2.1). Incremented upon each approved amendment.. Valid values are `^d+.d+$`',
    CONSTRAINT pk_blinding_config PRIMARY KEY(`blinding_config_id`)
) COMMENT 'Defines the blinding configuration for a randomization scheme, including blinding type (open-label, single-blind, double-blind, triple-blind), blinded roles (subject, investigator, sponsor, CRA, statistician), blinding method (identical packaging, dummy';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` (
    `unblinding_request_id` BIGINT COMMENT 'Unique surrogate identifier for the unblinding request record in the lakehouse silver layer. Primary key for this transactional entity.',
    `blinding_config_id` BIGINT COMMENT 'Foreign key linking to randomization.blinding_config. Business justification: An unblinding request is made to break the blinding defined in a specific blinding configuration.',
    `clinical_trial_authorization_id` BIGINT COMMENT 'Foreign key linking to regulatory.clinical_trial_authorization. Business justification: EU CTR requires health authority notification when unblinding occurs for SAEs in CTA-governed trials.',
    `document_sop_id` BIGINT COMMENT 'Foreign key linking to document.document_sop. Business justification: Unblinding procedures must follow a defined SOP (emergency unblinding SOP). GCP requires that each unblinding request be traceable to the SOP version in effect at the time; this FK',
    `ind_application_id` BIGINT COMMENT 'Foreign key linking to regulatory.ind_application. Business justification: Unblinding for SAEs triggers IND expedited safety reporting obligations (15-day IND safety reports).',
    `investigational_site_id` BIGINT COMMENT 'Foreign key linking to site.investigational_site. Business justification: Unblinding requests must originate from authorized study team members. Linking to study_assignment confirms the requestors active, authorized role on the study — a GCP and',
    `lab_result_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_result. Business justification: Emergency unblinding requests triggered by critical lab findings (e.g., severe hepatotoxicity, critical hematology values) must document the specific lab result that justified',
    `principal_investigator_id` BIGINT COMMENT 'Foreign key linking to site.principal_investigator. Business justification: GCP requires PI accountability for emergency unblinding requests. Regulatory documentation mandates PI signature on unblinding forms.',
    `protocol_deviation_id` BIGINT COMMENT 'Foreign key linking to compliance.protocol_deviation. Business justification: Unblinding events outside of emergency criteria or pre-specified procedures constitute protocol deviations.',
    `quality_event_id` BIGINT COMMENT 'Foreign key linking to compliance.quality_event. Business justification: Unplanned or procedurally non-compliant unblinding events are captured as quality events in the QMS regardless of whether they constitute protocol deviations.',
    `serious_adverse_event_id` BIGINT COMMENT 'Reference to the Serious Adverse Event record that triggered an emergency unblinding request. Null when the unblinding reason is not SAE-driven (e.g., planned DBL unblinding or interim analysis).',
    `sop_version_id` BIGINT COMMENT 'Foreign key linking to document.version. Business justification: GCP requires audit trails capturing which specific SOP version governed each unblinding request at the time of submission.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) for which the unblinding request was raised. Links to the study master record.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site where the subject is enrolled and where the unblinding request originated.',
    `subject_randomization_id` BIGINT COMMENT 'Reference to the randomization record (allocation event) for the subject whose treatment assignment is being unblinded. Links to the randomization domain master record.',
    `susar_id` BIGINT COMMENT 'Foreign key linking to safety.susar. Business justification: SUSARs are a distinct regulatory trigger for emergency unblinding under ICH E2B and EudraVigilance rules, separate from general SAEs.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Emergency and non-emergency unblinding requests with their outcomes are GCP-required records that must be filed in the eTMF as essential documents.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial subject (patient) whose treatment assignment is being unblinded. Applicable for single-subject emergency unblinding events; may be null for planned study-level unblinding (e.g., DBL or interim analysis).',
    `approval_level_count` BIGINT COMMENT 'Total number of approval levels required for this unblinding request based on the study protocol and urgency classification. Drives the multi-step approval workflow routing in the RTSM system.',
    `approver_1_decision` STRING COMMENT 'Decision rendered by the first-level approver on the unblinding request. Approved advances the request; rejected terminates it; escalated routes to a higher authority; deferred postpones pending additional information.. Valid values are `approved|rejected|escalated|deferred`',
    `approver_1_rationale` STRING COMMENT 'Free-text rationale provided by the first-level approver explaining their decision. Required for GCP compliance and regulatory audit trail, particularly for rejections and escalations.',
    `approver_1_role` STRING COMMENT 'Clinical or organizational role of the first-level approver at the time of their decision. Captured at decision time for audit trail integrity. [ENUM-REF-CANDIDATE: medical_monitor|sponsor_representative|cro_medical_director|irb_chair|dsmb_member|other —',
    `approver_1_timestamp` TIMESTAMP COMMENT 'Date and time when the first-level approver rendered their decision. Used to calculate approval cycle time and assess compliance with urgency SLAs.',
    `approver_2_decision` STRING COMMENT 'Decision rendered by the second-level approver on the unblinding request. Follows the same decision taxonomy as level 1. Null when a second approval level is not required.. Valid values are `approved|rejected|escalated|deferred`',
    `approver_2_timestamp` TIMESTAMP COMMENT 'Date and time when the second-level approver rendered their decision. Null when a second approval level is not required.',
    `blinding_broken_flag` BOOLEAN COMMENT 'Indicates whether the blinding was actually broken as a result of this request (True) or whether the request was resolved without revealing the treatment assignment (False). Used for protocol deviation tracking and blinding integrity reporting.',
    `clinical_justification` STRING COMMENT 'Free-text narrative provided by the requestor describing the clinical rationale for unblinding. For SAE-driven requests, includes the nature of the adverse event, patient condition, and why knowledge of treatment assignment is medically necessary.',
    `conditions_of_approval` STRING COMMENT 'Any conditions or restrictions imposed by the approver(s) on the approved unblinding (e.g., information to be shared only with treating physician, subject must be discontinued from study).',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this unblinding request record was first created in the lakehouse silver layer. Supports data lineage, audit trail, and 21 CFR Part 11 electronic record requirements.',
    `current_approval_level` BIGINT COMMENT 'The approval step currently pending action within the multi-level approval chain. Increments as each approver completes their review. Used for workflow routing and escalation monitoring.',
    `dsmb_dmc_referral_flag` BOOLEAN COMMENT 'Indicates whether this unblinding request was referred to or reviewed by the DSMB/DMC (True) or not (False). Applicable for interim analysis unblinding or escalated emergency cases requiring independent oversight.',
    `final_outcome` STRING COMMENT 'The definitive resolution of the unblinding request after all approval levels have been completed. Approved means the treatment assignment was revealed; rejected means the request was denied; withdrawn means the requestor retracted the request; escalated. Valid values are `approved|rejected|withdrawn|escalated`',
    `irb_iec_notification_required` BOOLEAN COMMENT 'Indicates whether the IRB/IEC must be notified of this unblinding event per the study protocol or applicable regulations (True) or not (False). Drives regulatory notification workflow.',
    `irb_iec_notification_timestamp` TIMESTAMP COMMENT 'Date and time when the IRB/IEC was formally notified of the unblinding event. Null if notification is not required or has not yet been sent. Used for regulatory compliance tracking.',
    `protocol_deviation_raised` BOOLEAN COMMENT 'Indicates whether an unplanned or unauthorized unblinding event associated with this request resulted in a protocol deviation being raised (True) or not (False). Links to the compliance domain for deviation tracking.',
    `request_number` STRING COMMENT 'Human-readable, externally-known business identifier for the unblinding request, typically generated by the RTSM/IRT system (e.g., the source system or Medidata Rave). Used in regulatory correspondence, audit trails, and DSMB/DMC communications.. Valid values are `^UBR-[A-Z0-9]{3,10}-[0-9]{6}$`',
    `request_status` STRING COMMENT 'Current lifecycle state of the unblinding request workflow. Tracks progression from initial submission through multi-level approval to final resolution. Drives GCP audit trail and DSMB/DMC oversight reporting.. Valid values are `pending|under_review|approved|rejected|escalated|withdrawn`',
    `requestor_name` STRING COMMENT 'Full name of the individual who submitted the unblinding request, captured at the time of submission for audit trail integrity per 21 CFR Part 11 and ALCOA+ requirements. Preserved even if the workforce record is later modified.',
    `requestor_role` STRING COMMENT 'Clinical role of the individual who submitted the unblinding request at the time of submission. Captured at request time to preserve audit integrity even if the persons role changes later.. Valid values are `pi|sub_investigator|crc|sponsor_medical_monitor|cra|other`',
    `required_by_timestamp` TIMESTAMP COMMENT 'Date and time by which the unblinding decision is clinically required, as specified by the requestor. Used to enforce urgency SLAs and escalation triggers. For emergency requests, this may be within hours of submission.',
    `source_system_request_code` STRING COMMENT 'The native identifier of this unblinding request in the originating operational system (the source system or Medidata Rave RTSM). Used for cross-system reconciliation and data lineage tracing in the lakehouse.',
    `sponsor_notification_timestamp` TIMESTAMP COMMENT 'Date and time when the study sponsor was formally notified of the unblinding event. Required for emergency unblinding events per GCP and sponsor agreements. Null if not yet notified.',
    `submitted_timestamp` TIMESTAMP COMMENT 'Date and time when the unblinding request was formally submitted by the requestor in the RTSM/IRT system. This is the principal business event timestamp for this transaction.',
    `treatment_arm_revealed` STRING COMMENT 'The treatment arm or randomization code revealed upon approved unblinding (e.g., Active Drug A 10mg, Placebo, Comparator B). Populated only when final_outcome is approved. Highly sensitive as it compromises blinding integrity for the subject.',
    `unblinding_reason` STRING COMMENT 'Categorical classification of the clinical or regulatory justification for the unblinding request. Drives urgency classification and approval routing. [ENUM-REF-CANDIDATE. Valid values are `sae_medical_emergency|regulatory_requirement|dsmb_interim_analysis|database_lock|planned_unblinding|other`',
    `unblinding_scope` STRING COMMENT 'Indicates whether the unblinding request pertains to a single subject (emergency or medical necessity) or to the entire study (planned events such as Database Lock, interim analysis, or final analysis).. Valid values are `single_subject|study_level`',
    `unblinding_timestamp` TIMESTAMP COMMENT 'Date and time when the treatment assignment was actually revealed to the authorized recipient. Null if the request was rejected or withdrawn. Critical for GCP audit trail and regulatory reporting timelines.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this unblinding request record was most recently modified in the lakehouse silver layer. Tracks the latest state change for audit trail and data quality monitoring.',
    `urgency_level` STRING COMMENT 'Clinical urgency classification of the unblinding request. Emergency indicates immediate patient safety risk requiring unblinding within hours; urgent indicates within 24 hours; routine indicates planned/scheduled unblinding with no immediate safety. Valid values are `emergency|urgent|routine`',
    `withdrawal_reason` STRING COMMENT 'Free-text explanation provided by the requestor when withdrawing an unblinding request before final resolution. Null when the request was not withdrawn. Required for audit trail completeness.',
    CONSTRAINT pk_unblinding_request PRIMARY KEY(`unblinding_request_id`)
) COMMENT 'Transactional record of a request to unblind a subjects treatment assignment, encompassing the full request-through-resolution lifecycle including multi-level approval steps.';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` (
    `unblinding_approval_id` BIGINT COMMENT 'Unique surrogate identifier for each unblinding approval record in the randomization domain. Primary key for this entity.',
    `document_sop_id` BIGINT COMMENT 'Foreign key linking to document.document_sop. Business justification: Unblinding approvals must follow a documented SOP per GCP and sponsor SOPs. unblinding_approval has no document_sop_id despite having gcp_compliance_confirmed and',
    `electronic_signature_id` BIGINT COMMENT 'Unique identifier of the 21 CFR Part 11-compliant electronic signature applied by the approver at the time of decision. Links to the electronic signature audit record in the eTMF or EDC system for regulatory submission readiness.',
    `ind_application_id` BIGINT COMMENT 'Foreign key linking to regulatory.ind_application. Business justification: Approved unblinding events for SAEs must be documented in IND annual reports and expedited safety submissions.',
    `investigational_site_id` BIGINT COMMENT 'Foreign key linking to site.investigational_site. Business justification: Unblinding approvers must be formally authorized study team members. Linking to study_assignment confirms the approvers active, authorized role on the study at time of approval —',
    `serious_adverse_event_id` BIGINT COMMENT 'Reference to the Serious Adverse Event (SAE) record that triggered the unblinding request, when applicable. Links the approval to the safety event in the source system for integrated safety reporting and SUSAR assessment.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which the unblinding approval is being recorded. Enables study-level audit trail and regulatory reporting.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site where the subject is enrolled and where the unblinding event is occurring.',
    `subject_randomization_id` BIGINT COMMENT 'Reference to the subjects randomization record whose treatment arm assignment is the subject of the unblinding request. Links to the randomization domain for treatment arm and kit assignment context.',
    `susar_id` BIGINT COMMENT 'Foreign key linking to safety.susar. Business justification: When unblinding is approved due to a SUSAR, the approval record must reference the specific SUSAR for EudraVigilance and FDA regulatory audit trail.',
    `tmf_document_id` BIGINT COMMENT 'Reference to the Trial Master File (TMF) document record in Veeva Vault eTMF where the signed unblinding approval form is archived. Required for inspection readiness and regulatory submission completeness.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial subject (patient) whose treatment assignment blinding is being reviewed for unblinding. Classified as restricted PII as it can be linked to an individual participant.',
    `unblinding_request_id` BIGINT COMMENT 'Reference to the parent unblinding request that this approval decision is associated with. Links the approval record to the originating request in the multi-level approval workflow.',
    `approval_conditions` STRING COMMENT 'Free-text description of any conditions or restrictions attached to a conditional approval decision (e.g., Unblinding permitted only to treating physician; sponsor team remains blinded). Populated only when approval_status is conditionally_approved.',
    `approval_level` BIGINT COMMENT 'Numeric level within the multi-tier approval hierarchy (e.g., 1 = first-line approver such as PI, 2 = second-line such as Medical Monitor, 3 = final authority such as Sponsor Medical Officer).',
    `approval_number` STRING COMMENT 'Externally-known, human-readable unique identifier for this approval record, used in regulatory submissions, audit trails, and cross-system references (e.g., UBA-STUDY01-202401). Serves as the BUSINESS_IDENTIFIER for this transaction.. Valid values are `^UBA-[A-Z0-9]{4,10}-[0-9]{6}$`',
    `approval_status` STRING COMMENT 'Current lifecycle status of the unblinding approval decision. Reflects the outcome of the approvers review: approved (unblinding authorized), rejected (unblinding denied), escalated (referred to higher authority), pending (awaiting decision), withdrawn. Valid values are `approved|rejected|escalated|pending|withdrawn|conditionally_approved`',
    `approver_name` STRING COMMENT 'Full name of the individual who rendered the approval or rejection decision. Required for GCP audit trail and 21 CFR Part 11 electronic signature attribution. Classified as confidential as it identifies a study personnel member.',
    `approver_role` STRING COMMENT 'The functional role of the individual who rendered the approval decision. Defines the authority level within the multi-level unblinding approval hierarchy.. Valid values are `medical_monitor|pi|sponsor_medical_officer|dsmb_chair|irb_representative|cro_medical_director`',
    `blinding_maintained` BOOLEAN COMMENT 'Indicates whether the overall study blinding integrity was maintained following this unblinding event (True = blinding maintained for the broader study population; False = blinding compromised at study level).',
    `comments` STRING COMMENT 'Additional free-text comments or observations recorded by the approver beyond the formal decision rationale. May include follow-up actions required, safety observations, or cross-references to related records.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this unblinding approval record was first created in the system. Used for audit trail completeness per ALCOA+ principles.',
    `decision_rationale` STRING COMMENT 'Free-text narrative explanation provided by the approver justifying the approval, rejection, escalation, or conditional approval decision. Required for GCP compliance and regulatory audit trail to demonstrate that the decision was medically and',
    `decision_timestamp` TIMESTAMP COMMENT 'The exact date and time (with timezone) at which the approver rendered their decision on the unblinding request. This is the principal business event timestamp for this transaction, critical for GCP audit trail and 21 CFR Part 11 electronic signature',
    `delegation_of_authority` BOOLEAN COMMENT 'Indicates whether the approver was acting under a formal delegation of authority (True = delegated authority; False = primary role holder). Relevant when a PI delegates unblinding approval authority to a sub-investigator or designee.',
    `emergency_unblinding` BOOLEAN COMMENT 'Indicates whether this unblinding approval was processed under emergency procedures (True = emergency unblinding bypassing standard multi-level approval; False = standard approval workflow).',
    `escalation_reason` STRING COMMENT 'Free-text explanation of why the approval decision was escalated to a higher authority rather than resolved at the current approval level. Populated only when approval_status is escalated.',
    `escalation_target_role` STRING COMMENT 'The role to which the unblinding decision has been escalated when approval_status is escalated. Identifies the next authority in the approval chain. [ENUM-REF-CANDIDATE. Valid values are `sponsor_medical_officer|dsmb_chair|irb_chair|regulatory_authority|cro_medical_director`',
    `gcp_compliance_confirmed` BOOLEAN COMMENT 'Indicates whether the approver explicitly confirmed that the unblinding procedure was conducted in accordance with Good Clinical Practice (GCP) guidelines and the applicable protocol SOP (True = confirmed; False = not confirmed or exception noted).',
    `irb_iec_notification_required` BOOLEAN COMMENT 'Indicates whether the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) must be notified of this unblinding event per protocol or regulatory requirements (True = notification required; False = not required).',
    `irb_iec_notified_date` DATE COMMENT 'The date on which the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) was formally notified of the unblinding event. Populated when irb_iec_notification_required is True and notification has been completed.',
    `notification_sent` BOOLEAN COMMENT 'Indicates whether the required regulatory and sponsor notifications were dispatched following this approval decision (True = notifications sent; False = pending notification). Supports compliance tracking for expedited safety reporting timelines.',
    `notification_timestamp` TIMESTAMP COMMENT 'The date and time at which regulatory and sponsor notifications were dispatched following the approval decision. Populated when notification_sent is True. Used to verify compliance with expedited reporting timelines (e.g., 7-day/15-day SAE reporting).',
    `protocol_version` STRING COMMENT 'The version of the study protocol that was in effect at the time of the unblinding approval decision. Required to confirm that the unblinding procedure followed the correct protocol versions unblinding SOP.',
    `response_time_hours` DECIMAL(10,2) COMMENT 'Elapsed time in hours between the submission of the unblinding request and the rendering of this approval decision. Used for KPI monitoring of emergency unblinding response times and SOP compliance.',
    `signature_timestamp` TIMESTAMP COMMENT 'The exact date and time at which the approver applied their 21 CFR Part 11-compliant electronic signature to the approval decision. May differ from decision_timestamp if signature was applied after the verbal/written decision.',
    `source_system_record_code` STRING COMMENT 'The native record identifier from the originating operational system (e.g., Medidata Rave workflow ID, the source system approval reference). Enables traceability from the Silver layer back to the system of record for audit and reconciliation.',
    `treatment_arm_revealed` STRING COMMENT 'The treatment arm or randomization code that was disclosed to the approver upon approval of the unblinding request (e.g., Active Drug A 10mg, Placebo). Populated only after approval is granted and unblinding is executed.',
    `unblinding_reason_category` STRING COMMENT 'Categorical classification of the reason driving the unblinding request being reviewed. Supports regulatory reporting and trend analysis of unblinding events.. Valid values are `emergency_medical|sae_reporting|regulatory_requirement|dsmb_review|study_completion|protocol_deviation`',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time when this unblinding approval record was last modified. Supports audit trail integrity and change detection per 21 CFR Part 11.',
    CONSTRAINT pk_unblinding_approval PRIMARY KEY(`unblinding_approval_id`)
) COMMENT 'Records the approval or rejection decision for an unblinding request. Captures the approver role (medical monitor, PI, sponsor medical officer), decision (approved, rejected, escalated), decision rationale, decision timestamp, and any conditions attached';

ALTER SCHEMA `clinical_trials_mvm`.`randomization` SET TAGS ('dbx_division' = 'operations');

ALTER SCHEMA `clinical_trials_mvm`.`randomization` SET TAGS ('dbx_domain' = 'randomization');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` SET TAGS ('dbx_domain' = 'randomization');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` SET TAGS ('dbx_subdomain' = 'randomization_design');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `rand_scheme_id` SET TAGS ('dbx_business_glossary_term' = 'Randomization Scheme ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `ind_application_id` SET TAGS ('dbx_business_glossary_term' = 'Ind Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `activation_date` SET TAGS ('dbx_business_glossary_term' = 'Scheme Activation Date');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `allocation_algorithm` SET TAGS ('dbx_business_glossary_term' = 'Allocation Algorithm Type');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `allocation_algorithm` SET TAGS ('dbx_value_regex' = 'simple|block|stratified_block|minimization|adaptive|covariate_adaptive');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `allocation_ratio` SET TAGS ('dbx_business_glossary_term' = 'Treatment Allocation Ratio');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Scheme Approval Date');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Scheme Approver Name');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `blinding_type` SET TAGS ('dbx_value_regex' = 'open_label|single_blind|double_blind|triple_blind');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `cdisc_sdtm_domain` SET TAGS ('dbx_business_glossary_term' = 'CDISC SDTM Domain Reference');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `generation_software` SET TAGS ('dbx_business_glossary_term' = 'List Generation Software');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `irb_iec_approval_required` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Approval Required Indicator');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `irt_scheme_reference` SET TAGS ('dbx_business_glossary_term' = 'IRT System Scheme Reference');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `irt_system_name` SET TAGS ('dbx_business_glossary_term' = 'Interactive Response Technology (IRT) System Name');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `irt_system_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `is_centralized` SET TAGS ('dbx_business_glossary_term' = 'Centralized Randomization Indicator');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `is_stratified_by_site` SET TAGS ('dbx_business_glossary_term' = 'Site Stratification Indicator');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `is_variable_block` SET TAGS ('dbx_business_glossary_term' = 'Variable Block Size Indicator');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `list_generation_date` SET TAGS ('dbx_business_glossary_term' = 'Randomization List Generation Date');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `minimization_probability` SET TAGS ('dbx_business_glossary_term' = 'Minimization Allocation Probability');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Randomization Scheme Notes');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `random_seed` SET TAGS ('dbx_business_glossary_term' = 'Randomization Seed Value');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `random_seed` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `retirement_date` SET TAGS ('dbx_business_glossary_term' = 'Scheme Retirement Date');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `sap_version_reference` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) Version Reference');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `scheme_code` SET TAGS ('dbx_business_glossary_term' = 'Randomization Scheme Code');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `scheme_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{3,30}$');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `scheme_name` SET TAGS ('dbx_business_glossary_term' = 'Randomization Scheme Name');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `scheme_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `scheme_status` SET TAGS ('dbx_business_glossary_term' = 'Randomization Scheme Status');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `scheme_status` SET TAGS ('dbx_value_regex' = 'draft|approved|active|suspended|retired');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `scheme_version` SET TAGS ('dbx_business_glossary_term' = 'Randomization Scheme Version');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `scheme_version` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+(.[0-9]+)?$');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `treatment_arm_count` SET TAGS ('dbx_internal' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `treatment_arm_count` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `treatment_arm_count` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `unblinding_procedure` SET TAGS ('dbx_business_glossary_term' = 'Unblinding Procedure Type');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `unblinding_procedure` SET TAGS ('dbx_value_regex' = 'emergency_only|dsmb_only|dbk_full|partial_sponsor');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ADD CONSTRAINT `fk_randomization_rand_list_rand_scheme_id` FOREIGN KEY (`rand_scheme_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_scheme`(`rand_scheme_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ADD CONSTRAINT `fk_randomization_rand_list_superseded_by_list_rand_list_id` FOREIGN KEY (`superseded_by_list_rand_list_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_list`(`rand_list_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` SET TAGS ('dbx_domain' = 'randomization');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` SET TAGS ('dbx_subdomain' = 'randomization_design');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `rand_list_id` SET TAGS ('dbx_business_glossary_term' = 'Randomization List ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `document_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Document Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `epoch_id` SET TAGS ('dbx_business_glossary_term' = 'Epoch Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `rand_scheme_id` SET TAGS ('dbx_business_glossary_term' = 'Randomization Scheme ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `regulatory_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `superseded_by_list_rand_list_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Randomization List ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `activation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'List Activation Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `allocated_slots` SET TAGS ('dbx_business_glossary_term' = 'Allocated Randomization Slots');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `allocation_ratio` SET TAGS ('dbx_business_glossary_term' = 'Treatment Allocation Ratio');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'List Approval Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `blinding_level` SET TAGS ('dbx_value_regex' = 'open_label|single_blind|double_blind|triple_blind');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `block_size_sequence` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `dsmb_access_granted` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Access Granted');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `dsmb_access_granted` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `generation_method` SET TAGS ('dbx_business_glossary_term' = 'Randomization Generation Method');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `generation_method` SET TAGS ('dbx_value_regex' = 'permuted_block|minimization|stratified|adaptive|dynamic|simple');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `generation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'List Generation Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `irb_iec_approval_required` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Approval Required');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `irt_list_type` SET TAGS ('dbx_business_glossary_term' = 'Interactive Response Technology (IRT) List Type');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `irt_list_type` SET TAGS ('dbx_value_regex' = 'global|site_specific|stratum_specific|country_specific');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `is_stratified` SET TAGS ('dbx_business_glossary_term' = 'Is Stratified Randomization');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `list_description` SET TAGS ('dbx_business_glossary_term' = 'Randomization List Description');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `list_number` SET TAGS ('dbx_business_glossary_term' = 'Randomization List Number');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `list_status` SET TAGS ('dbx_business_glossary_term' = 'Randomization List Status');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `list_version` SET TAGS ('dbx_business_glossary_term' = 'Randomization List Version');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Randomization List Notes');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `randomization_seed` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `sap_reference` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) Reference');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `source_system_list_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System List ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `superseded_timestamp` SET TAGS ('dbx_business_glossary_term' = 'List Superseded Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `total_slots` SET TAGS ('dbx_business_glossary_term' = 'Total Randomization Slots');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `treatment_arm_count` SET TAGS ('dbx_internal' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `treatment_arm_count` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `treatment_arm_count` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `unblinding_procedure` SET TAGS ('dbx_value_regex' = 'emergency_unblinding|scheduled_dbl_unblinding|dsmb_unblinding|regulatory_unblinding');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `validation_status` SET TAGS ('dbx_business_glossary_term' = 'List Validation Status');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `validation_status` SET TAGS ('dbx_value_regex' = 'not_validated|validated|validation_failed');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ALTER COLUMN `validation_timestamp` SET TAGS ('dbx_business_glossary_term' = 'List Validation Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ADD CONSTRAINT `fk_randomization_rand_code_irt_transaction_id` FOREIGN KEY (`irt_transaction_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`irt_transaction`(`irt_transaction_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ADD CONSTRAINT `fk_randomization_rand_code_rand_list_id` FOREIGN KEY (`rand_list_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_list`(`rand_list_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ADD CONSTRAINT `fk_randomization_rand_code_rand_scheme_id` FOREIGN KEY (`rand_scheme_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_scheme`(`rand_scheme_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ADD CONSTRAINT `fk_randomization_rand_code_treatment_arm_id` FOREIGN KEY (`treatment_arm_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`treatment_arm`(`treatment_arm_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` SET TAGS ('dbx_domain' = 'randomization');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` SET TAGS ('dbx_subdomain' = 'randomization_design');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `rand_code_id` SET TAGS ('dbx_business_glossary_term' = 'Randomization Code ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `irt_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Interactive Response Technology (IRT) Transaction ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `rand_list_id` SET TAGS ('dbx_business_glossary_term' = 'Randomization List ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `rand_scheme_id` SET TAGS ('dbx_business_glossary_term' = 'Stratification Cell Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `rand_scheme_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Study Site Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_business_glossary_term' = 'Treatment Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `assigned_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Assignment Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `assignment_status` SET TAGS ('dbx_business_glossary_term' = 'Randomization Code Assignment Status');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `assignment_status` SET TAGS ('dbx_value_regex' = 'available|assigned|cancelled|replaced|reserved|expired');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `blinding_type` SET TAGS ('dbx_value_regex' = 'double_blind|single_blind|open_label|triple_blind');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `block_number` SET TAGS ('dbx_business_glossary_term' = 'Randomization Block Number');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `block_size` SET TAGS ('dbx_business_glossary_term' = 'Randomization Block Size');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `cancelled_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `cancelled_timestamp` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `code_number` SET TAGS ('dbx_business_glossary_term' = 'Randomization Code Number');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `code_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{1,20}$');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Randomization Code Expiry Date');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `irt_system_source` SET TAGS ('dbx_business_glossary_term' = 'Interactive Response Technology (IRT) System Source');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `irt_system_source` SET TAGS ('dbx_value_regex' = 'medidata_rave_rtsm|oracle_clinical_one|ivrs|other');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `is_emergency_unblinding_eligible` SET TAGS ('dbx_business_glossary_term' = 'Emergency Unblinding Eligibility Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `is_rescue_medication_eligible` SET TAGS ('dbx_business_glossary_term' = 'Rescue Medication Eligibility Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `is_unblinded` SET TAGS ('dbx_business_glossary_term' = 'Unblinded Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `kit_code` SET TAGS ('dbx_business_glossary_term' = 'Investigational Medicinal Product (IMP) Kit Code');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `kit_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{1,30}$');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `list_version_number` SET TAGS ('dbx_business_glossary_term' = 'Randomization List Version Number');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `list_version_number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Randomization Code Notes');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `protocol_amendment_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9.]{1,10}$');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `randomization_method` SET TAGS ('dbx_value_regex' = 'permuted_block|minimization|stratified|adaptive|simple|dynamic');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `randomization_seed` SET TAGS ('dbx_business_glossary_term' = 'Randomization Seed Value');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `randomization_seed` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `region_code` SET TAGS ('dbx_business_glossary_term' = 'Geographic Region Code');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `region_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{1,20}$');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `replacement_code_number` SET TAGS ('dbx_business_glossary_term' = 'Replacement Randomization Code Number');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `replacement_code_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{1,20}$');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `sequence_position` SET TAGS ('dbx_business_glossary_term' = 'Sequence Position Number');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `source_system_code_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Randomization Code Identifier');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ALTER COLUMN `unblinding_reason` SET TAGS ('dbx_value_regex' = 'emergency_medical|end_of_study|dsmb_request|regulatory_request|protocol_deviation');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` SET TAGS ('dbx_domain' = 'randomization');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` SET TAGS ('dbx_subdomain' = 'treatment_allocation');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_business_glossary_term' = 'Treatment Arm Identifier');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ALTER COLUMN `arm_id` SET TAGS ('dbx_business_glossary_term' = 'Study Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ALTER COLUMN `ind_application_id` SET TAGS ('dbx_business_glossary_term' = 'Ind Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ALTER COLUMN `investigational_product_id` SET TAGS ('dbx_internal' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ALTER COLUMN `analysis_population` SET TAGS ('dbx_value_regex' = 'ITT|mITT|PP|safety|PK|PD');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ALTER COLUMN `approved_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Arm Definition Approved Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ALTER COLUMN `arm_status` SET TAGS ('dbx_business_glossary_term' = 'Treatment Arm Status');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ALTER COLUMN `arm_status` SET TAGS ('dbx_value_regex' = 'draft|active|suspended|closed|cancelled');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ALTER COLUMN `arm_type` SET TAGS ('dbx_business_glossary_term' = 'Treatment Arm Type');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ALTER COLUMN `arm_type` SET TAGS ('dbx_value_regex' = 'experimental|active_comparator|placebo|open_label_extension|run_in|follow_up');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ALTER COLUMN `blinding_role` SET TAGS ('dbx_value_regex' = 'blinded|open_label|single_blind|double_blind|triple_blind');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ALTER COLUMN `blinding_role` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ALTER COLUMN `edc_arm_code` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) Arm Code');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ALTER COLUMN `irt_arm_code` SET TAGS ('dbx_business_glossary_term' = 'Interactive Response Technology (IRT) Arm Code');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ALTER COLUMN `irt_arm_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{1,30}$');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ALTER COLUMN `is_control_arm` SET TAGS ('dbx_business_glossary_term' = 'Is Control Arm Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ALTER COLUMN `max_subject_count` SET TAGS ('dbx_business_glossary_term' = 'Maximum Subject Count');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ALTER COLUMN `min_subject_count` SET TAGS ('dbx_business_glossary_term' = 'Minimum Subject Count');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Treatment Arm Notes');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ALTER COLUMN `randomization_method` SET TAGS ('dbx_value_regex' = 'simple|block|stratified|minimization|adaptive|covariate_adaptive');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ALTER COLUMN `sap_section_reference` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) Section Reference');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ALTER COLUMN `sdtm_arm_value` SET TAGS ('dbx_business_glossary_term' = 'Study Data Tabulation Model (SDTM) ARM Value');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ALTER COLUMN `suspension_reason` SET TAGS ('dbx_business_glossary_term' = 'Arm Suspension Reason');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ALTER COLUMN `target_allocation_pct` SET TAGS ('dbx_business_glossary_term' = 'Target Allocation Percentage');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ALTER COLUMN `treatment_description` SET TAGS ('dbx_internal' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ALTER COLUMN `treatment_description` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ALTER COLUMN `treatment_description` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ALTER COLUMN `unblinding_procedure` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ADD CONSTRAINT `fk_randomization_stratification_factor_rand_scheme_id` FOREIGN KEY (`rand_scheme_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_scheme`(`rand_scheme_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` SET TAGS ('dbx_domain' = 'randomization');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` SET TAGS ('dbx_subdomain' = 'randomization_design');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `rand_scheme_id` SET TAGS ('dbx_business_glossary_term' = 'Randomization Scheme ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `regulatory_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `adam_variable` SET TAGS ('dbx_business_glossary_term' = 'Analysis Data Model (ADaM) Variable');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `covariate_adjustment_method` SET TAGS ('dbx_value_regex' = 'ancova|cmh|logistic_regression|none');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `data_source_type` SET TAGS ('dbx_business_glossary_term' = 'Factor Data Source Type');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `data_source_type` SET TAGS ('dbx_value_regex' = 'ecrf|ivrs|irt|central_lab|manual_entry');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `ecrf_field_reference` SET TAGS ('dbx_business_glossary_term' = 'Electronic Case Report Form (eCRF) Field Reference');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `factor_code` SET TAGS ('dbx_business_glossary_term' = 'Stratification Factor Code');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `factor_code` SET TAGS ('dbx_value_regex' = '^[A-Z][A-Z0-9_]{1,29}$');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `factor_description` SET TAGS ('dbx_business_glossary_term' = 'Stratification Factor Description');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `factor_name` SET TAGS ('dbx_business_glossary_term' = 'Stratification Factor Name');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `factor_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `factor_status` SET TAGS ('dbx_business_glossary_term' = 'Stratification Factor Status');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `factor_status` SET TAGS ('dbx_value_regex' = 'draft|approved|active|suspended|retired');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `factor_type` SET TAGS ('dbx_business_glossary_term' = 'Stratification Factor Type');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `factor_type` SET TAGS ('dbx_value_regex' = 'categorical|continuous_binned|ordinal|binary');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `irt_parameter_name` SET TAGS ('dbx_business_glossary_term' = 'Interactive Response Technology (IRT) Parameter Name');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `irt_parameter_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Active Factor Indicator');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `is_blinded` SET TAGS ('dbx_business_glossary_term' = 'Blinded Factor Indicator');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `is_primary_factor` SET TAGS ('dbx_business_glossary_term' = 'Primary Stratification Factor Indicator');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `is_used_in_primary_analysis` SET TAGS ('dbx_business_glossary_term' = 'Used in Primary Analysis Indicator');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `level_count` SET TAGS ('dbx_business_glossary_term' = 'Factor Level Count');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `max_imbalance_threshold` SET TAGS ('dbx_business_glossary_term' = 'Maximum Imbalance Threshold');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `minimization_variant` SET TAGS ('dbx_business_glossary_term' = 'Minimization Algorithm Variant');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `minimization_variant` SET TAGS ('dbx_value_regex' = 'pocock_simon|weighted_minimization|biased_coin|deterministic|none');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `missing_value_handling` SET TAGS ('dbx_business_glossary_term' = 'Missing Value Handling Strategy');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `missing_value_handling` SET TAGS ('dbx_value_regex' = 'block_randomization|assign_default_level|flag_and_hold|exclude_from_minimization');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Factor Notes');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `randomization_algorithm` SET TAGS ('dbx_value_regex' = 'permuted_block|minimization|stratified_block|dynamic_allocation');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `rtsm_factor_code` SET TAGS ('dbx_business_glossary_term' = 'RTSM System Factor Identifier');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `rtsm_system` SET TAGS ('dbx_business_glossary_term' = 'Randomization and Trial Supply Management (RTSM) System');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `rtsm_system` SET TAGS ('dbx_value_regex' = 'medidata_rave_rtsm|oracle_clinical_one|ivrs|other');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `sap_section_reference` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) Section Reference');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `sdtm_variable` SET TAGS ('dbx_business_glossary_term' = 'Study Data Tabulation Model (SDTM) Variable');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `unit_of_imbalance` SET TAGS ('dbx_business_glossary_term' = 'Unit of Imbalance Measurement');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `unit_of_imbalance` SET TAGS ('dbx_value_regex' = 'percentage|subject_count');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `validation_rule` SET TAGS ('dbx_business_glossary_term' = 'Factor Validation Rule');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^d+.d+$');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ADD CONSTRAINT `fk_randomization_subject_randomization_blinding_config_id` FOREIGN KEY (`blinding_config_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`blinding_config`(`blinding_config_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ADD CONSTRAINT `fk_randomization_subject_randomization_irt_transaction_id` FOREIGN KEY (`irt_transaction_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`irt_transaction`(`irt_transaction_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ADD CONSTRAINT `fk_randomization_subject_randomization_original_randomization_subject_randomization_id` FOREIGN KEY (`original_randomization_subject_randomization_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ADD CONSTRAINT `fk_randomization_subject_randomization_rand_code_id` FOREIGN KEY (`rand_code_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_code`(`rand_code_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ADD CONSTRAINT `fk_randomization_subject_randomization_rand_list_id` FOREIGN KEY (`rand_list_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_list`(`rand_list_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ADD CONSTRAINT `fk_randomization_subject_randomization_rand_scheme_id` FOREIGN KEY (`rand_scheme_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_scheme`(`rand_scheme_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ADD CONSTRAINT `fk_randomization_subject_randomization_treatment_arm_id` FOREIGN KEY (`treatment_arm_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`treatment_arm`(`treatment_arm_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` SET TAGS ('dbx_domain' = 'randomization');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` SET TAGS ('dbx_subdomain' = 'treatment_allocation');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `blinding_config_id` SET TAGS ('dbx_business_glossary_term' = 'Blinding Config Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Consent Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Informed Consent Form (ICF) Version ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Randomizing Study Assignment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `irt_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Interactive Response Technology (IRT) Transaction ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `original_randomization_subject_randomization_id` SET TAGS ('dbx_business_glossary_term' = 'Original Randomization ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `rand_code_id` SET TAGS ('dbx_business_glossary_term' = 'Rand Code Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `rand_list_id` SET TAGS ('dbx_business_glossary_term' = 'Rand List Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `rand_scheme_id` SET TAGS ('dbx_business_glossary_term' = 'Stratification Cell Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `rand_scheme_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `study_visit_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Randomization Visit Schedule Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_business_glossary_term' = 'Treatment Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_internal' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `blinding_type` SET TAGS ('dbx_value_regex' = 'open_label|single_blind|double_blind|triple_blind');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `block_number` SET TAGS ('dbx_business_glossary_term' = 'Randomization Block Number');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `block_number` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_value_regex' = 'irt_error|screen_failure|duplicate_entry|sponsor_request|other');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `cancellation_timestamp` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Randomization Comments');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `eligibility_confirmed` SET TAGS ('dbx_business_glossary_term' = 'Eligibility Confirmed Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `irt_system_name` SET TAGS ('dbx_business_glossary_term' = 'Interactive Response Technology (IRT) System Name');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `irt_system_name` SET TAGS ('dbx_value_regex' = 'Medidata Rave RTSM|Oracle Clinical One|IVRS|Other');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `irt_system_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `is_unblinded` SET TAGS ('dbx_business_glossary_term' = 'Is Unblinded Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `is_unblinded` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `randomization_method` SET TAGS ('dbx_value_regex' = 'permuted_block|minimization|stratified_block|dynamic|simple');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `randomization_number` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `randomization_number` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `randomization_status` SET TAGS ('dbx_value_regex' = 'randomized|cancelled|re-randomized|pending|failed');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `randomization_type` SET TAGS ('dbx_value_regex' = 'initial|re-randomization|replacement');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `randomizing_user_role` SET TAGS ('dbx_value_regex' = 'CRC|CRA|PI|IRT_system|sponsor_user|other');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `rerandomization_reason` SET TAGS ('dbx_business_glossary_term' = 'Re-randomization Reason');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `rerandomization_reason` SET TAGS ('dbx_value_regex' = 'screen_failure_reentry|protocol_deviation|irt_error|investigator_request|other');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `sequence_within_block` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `source_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Source Record ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `subject_number` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `unblinding_reason` SET TAGS ('dbx_value_regex' = 'safety_emergency|dsmb_review|regulatory_request|study_completion|other');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `unblinding_reason` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `unblinding_timestamp` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ADD CONSTRAINT `fk_randomization_irt_transaction_treatment_arm_id` FOREIGN KEY (`treatment_arm_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`treatment_arm`(`treatment_arm_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` SET TAGS ('dbx_domain' = 'randomization');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` SET TAGS ('dbx_subdomain' = 'randomization_design');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `irt_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Interactive Response Technology (IRT) Transaction ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Site Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `study_visit_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Study Visit Schedule Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_business_glossary_term' = 'Treatment Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_internal' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `blinding_status` SET TAGS ('dbx_value_regex' = 'blinded|unblinded|partially_unblinded');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `electronic_signature_flag` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Kit Expiry Date');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `failure_reason` SET TAGS ('dbx_business_glossary_term' = 'Transaction Failure Reason');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `irt_config_version` SET TAGS ('dbx_business_glossary_term' = 'IRT Configuration Version');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `irt_system_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `irt_system_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Interactive Response Technology (IRT) System Reference Number');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Transaction Notes');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `operator_role` SET TAGS ('dbx_value_regex' = 'CRC|CRA|PI|pharmacist|sponsor_user|system');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `query_flag` SET TAGS ('dbx_business_glossary_term' = 'Data Query Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `randomization_method` SET TAGS ('dbx_value_regex' = 'minimization|block|stratified_block|dynamic|simple');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `randomization_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `sdv_date` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Date');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `sdv_flag` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `source_system_record_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `subject_number` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `transaction_outcome` SET TAGS ('dbx_business_glossary_term' = 'IRT Transaction Outcome');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `transaction_outcome` SET TAGS ('dbx_value_regex' = 'success|failure|partial|timeout|error');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `transaction_status` SET TAGS ('dbx_business_glossary_term' = 'IRT Transaction Status');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `transaction_status` SET TAGS ('dbx_value_regex' = 'completed|failed|cancelled|pending|reversed');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `transaction_timestamp` SET TAGS ('dbx_business_glossary_term' = 'IRT Transaction Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `transaction_type` SET TAGS ('dbx_business_glossary_term' = 'IRT Transaction Type');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `transaction_type` SET TAGS ('dbx_value_regex' = 'randomization|re_randomization|kit_assignment|dose_change|titration|cancellation');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ADD CONSTRAINT `fk_randomization_kit_assignment_irt_transaction_id` FOREIGN KEY (`irt_transaction_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`irt_transaction`(`irt_transaction_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ADD CONSTRAINT `fk_randomization_kit_assignment_rand_code_id` FOREIGN KEY (`rand_code_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_code`(`rand_code_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ADD CONSTRAINT `fk_randomization_kit_assignment_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ADD CONSTRAINT `fk_randomization_kit_assignment_treatment_arm_id` FOREIGN KEY (`treatment_arm_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`treatment_arm`(`treatment_arm_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` SET TAGS ('dbx_domain' = 'randomization');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` SET TAGS ('dbx_subdomain' = 'treatment_allocation');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `kit_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Kit Assignment Identifier');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `irt_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Interactive Response Technology (IRT) Transaction ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `kit_inventory_id` SET TAGS ('dbx_business_glossary_term' = 'Kit Inventory Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `rand_code_id` SET TAGS ('dbx_business_glossary_term' = 'Rand Code Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `study_visit_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Study Visit Schedule Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `subject_randomization_id` SET TAGS ('dbx_business_glossary_term' = 'Randomization ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_business_glossary_term' = 'Treatment Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_internal' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `visit_id` SET TAGS ('dbx_business_glossary_term' = 'Visit ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `assignment_status` SET TAGS ('dbx_business_glossary_term' = 'Kit Assignment Status');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `assignment_status` SET TAGS ('dbx_value_regex' = 'Assigned|Dispensed|Returned|Destroyed|Lost|Recalled');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `assignment_type` SET TAGS ('dbx_business_glossary_term' = 'Kit Assignment Type');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `assignment_type` SET TAGS ('dbx_value_regex' = 'Initial|Resupply|Replacement|Titration|Rescue');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `blinding_status` SET TAGS ('dbx_value_regex' = 'Blinded|Unblinded|Open-Label');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Kit Assignment Comments');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `compliance_flag` SET TAGS ('dbx_business_glossary_term' = 'Subject Compliance Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `dispensing_confirmed` SET TAGS ('dbx_business_glossary_term' = 'Dispensing Confirmed Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `dosage_form` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `irt_system_name` SET TAGS ('dbx_business_glossary_term' = 'Interactive Response Technology (IRT) System Name');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `irt_system_name` SET TAGS ('dbx_value_regex' = 'Medidata Rave RTSM|Oracle Clinical One|IVRS|Other');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `irt_system_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `kit_type` SET TAGS ('dbx_value_regex' = 'IMP|Placebo|Comparator|Rescue Medication|Open-Label|Blinded');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `randomization_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `return_date` SET TAGS ('dbx_business_glossary_term' = 'Kit Return Date');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `return_status` SET TAGS ('dbx_business_glossary_term' = 'Kit Return Status');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `return_status` SET TAGS ('dbx_value_regex' = 'Pending|Returned|Waived|Not Applicable');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `subject_number` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ADD CONSTRAINT `fk_randomization_blinding_config_previous_version_blinding_config_id` FOREIGN KEY (`previous_version_blinding_config_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`blinding_config`(`blinding_config_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ADD CONSTRAINT `fk_randomization_blinding_config_rand_scheme_id` FOREIGN KEY (`rand_scheme_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_scheme`(`rand_scheme_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` SET TAGS ('dbx_domain' = 'randomization');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` SET TAGS ('dbx_subdomain' = 'randomization_design');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `blinding_config_id` SET TAGS ('dbx_business_glossary_term' = 'Blinding Configuration ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `document_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Document Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Consent Icf Version Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `previous_version_blinding_config_id` SET TAGS ('dbx_business_glossary_term' = 'Previous Version ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `rand_scheme_id` SET TAGS ('dbx_business_glossary_term' = 'Randomization Scheme ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `blinding_method` SET TAGS ('dbx_value_regex' = 'identical_packaging|dummy_tablets|double_dummy|over_encapsulation|matching_placebo|other');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `blinding_type` SET TAGS ('dbx_value_regex' = 'open_label|single_blind|double_blind|triple_blind');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `config_code` SET TAGS ('dbx_business_glossary_term' = 'Blinding Configuration Code');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `config_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{3,30}$');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `config_name` SET TAGS ('dbx_business_glossary_term' = 'Blinding Configuration Name');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `config_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `config_status` SET TAGS ('dbx_business_glossary_term' = 'Blinding Configuration Status');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `config_status` SET TAGS ('dbx_value_regex' = 'draft|active|superseded|retired');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `cra_blinded` SET TAGS ('dbx_business_glossary_term' = 'Clinical Research Associate (CRA) Blinded Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `dsmb_unblinded` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Unblinded Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `edc_access_restricted` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) Access Restricted Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `emergency_unblinding_allowed` SET TAGS ('dbx_business_glossary_term' = 'Emergency Unblinding Allowed Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `gdpr_applicable` SET TAGS ('dbx_business_glossary_term' = 'General Data Protection Regulation (GDPR) Applicable Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `hipaa_applicable` SET TAGS ('dbx_business_glossary_term' = 'Health Insurance Portability and Accountability Act (HIPAA) Applicable Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `interim_analysis_unblinding` SET TAGS ('dbx_business_glossary_term' = 'Interim Analysis Unblinding Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `investigator_blinded` SET TAGS ('dbx_business_glossary_term' = 'Investigator Blinded Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `irb_iec_approval_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Approval Date');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `irb_iec_approval_required` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Approval Required Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `irt_system_enforced` SET TAGS ('dbx_business_glossary_term' = 'Interactive Response Technology (IRT) System Enforced Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `kit_label_blinded` SET TAGS ('dbx_business_glossary_term' = 'Kit Label Blinded Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Blinding Configuration Notes');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `randomization_code_masked` SET TAGS ('dbx_business_glossary_term' = 'Randomization Code Masked Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `sae_unblinding_policy` SET TAGS ('dbx_business_glossary_term' = 'Serious Adverse Event (SAE) Unblinding Policy');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `sae_unblinding_policy` SET TAGS ('dbx_value_regex' = 'always_unblind|unblind_if_susar|maintain_blind|case_by_case');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `sponsor_blinded` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Blinded Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `statistician_blinded` SET TAGS ('dbx_business_glossary_term' = 'Statistician Blinded Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `subject_blinded` SET TAGS ('dbx_business_glossary_term' = 'Subject Blinded Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `unblinding_documentation_required` SET TAGS ('dbx_business_glossary_term' = 'Unblinding Documentation Required Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `unblinding_procedure` SET TAGS ('dbx_value_regex' = 'emergency_envelope|irt_system|sponsor_pharmacovigilance|dsmb_request|study_completion');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Blinding Configuration Version Number');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^d+.d+$');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ADD CONSTRAINT `fk_randomization_unblinding_request_blinding_config_id` FOREIGN KEY (`blinding_config_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`blinding_config`(`blinding_config_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ADD CONSTRAINT `fk_randomization_unblinding_request_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` SET TAGS ('dbx_domain' = 'randomization');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` SET TAGS ('dbx_subdomain' = 'unblinding_management');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `blinding_config_id` SET TAGS ('dbx_business_glossary_term' = 'Blinding Config Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `document_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Document Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `ind_application_id` SET TAGS ('dbx_business_glossary_term' = 'Ind Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Requestor Study Assignment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `lab_result_id` SET TAGS ('dbx_business_glossary_term' = 'Triggering Lab Result Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `principal_investigator_id` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `protocol_deviation_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `quality_event_id` SET TAGS ('dbx_business_glossary_term' = 'Quality Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `serious_adverse_event_id` SET TAGS ('dbx_business_glossary_term' = 'Serious Adverse Event (SAE) ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `sop_version_id` SET TAGS ('dbx_business_glossary_term' = 'Sop Version Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `subject_randomization_id` SET TAGS ('dbx_business_glossary_term' = 'Randomization ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `susar_id` SET TAGS ('dbx_business_glossary_term' = 'Susar Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `approver_1_decision` SET TAGS ('dbx_business_glossary_term' = 'Approver Level 1 Decision');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `approver_1_decision` SET TAGS ('dbx_value_regex' = 'approved|rejected|escalated|deferred');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `approver_1_rationale` SET TAGS ('dbx_business_glossary_term' = 'Approver Level 1 Decision Rationale');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `approver_1_rationale` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `approver_1_role` SET TAGS ('dbx_business_glossary_term' = 'Approver Level 1 Role');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `approver_1_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approver Level 1 Decision Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `approver_2_decision` SET TAGS ('dbx_business_glossary_term' = 'Approver Level 2 Decision');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `approver_2_decision` SET TAGS ('dbx_value_regex' = 'approved|rejected|escalated|deferred');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `approver_2_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approver Level 2 Decision Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `clinical_justification` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `conditions_of_approval` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `dsmb_dmc_referral_flag` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board / Data Monitoring Committee (DSMB/DMC) Referral Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `final_outcome` SET TAGS ('dbx_value_regex' = 'approved|rejected|withdrawn|escalated');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `irb_iec_notification_required` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Notification Required Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `irb_iec_notification_timestamp` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Notification Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `protocol_deviation_raised` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Raised Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `request_number` SET TAGS ('dbx_business_glossary_term' = 'Unblinding Request Number');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `request_number` SET TAGS ('dbx_value_regex' = '^UBR-[A-Z0-9]{3,10}-[0-9]{6}$');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `request_status` SET TAGS ('dbx_business_glossary_term' = 'Unblinding Request Status');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `request_status` SET TAGS ('dbx_value_regex' = 'pending|under_review|approved|rejected|escalated|withdrawn');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `requestor_name` SET TAGS ('dbx_business_glossary_term' = 'Requestor Full Name');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `requestor_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `requestor_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `requestor_role` SET TAGS ('dbx_value_regex' = 'pi|sub_investigator|crc|sponsor_medical_monitor|cra|other');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `source_system_request_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Request ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `submitted_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Request Submitted Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `treatment_arm_revealed` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `unblinding_reason` SET TAGS ('dbx_value_regex' = 'sae_medical_emergency|regulatory_requirement|dsmb_interim_analysis|database_lock|planned_unblinding|other');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `unblinding_scope` SET TAGS ('dbx_value_regex' = 'single_subject|study_level');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ALTER COLUMN `urgency_level` SET TAGS ('dbx_value_regex' = 'emergency|urgent|routine');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ADD CONSTRAINT `fk_randomization_unblinding_approval_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ADD CONSTRAINT `fk_randomization_unblinding_approval_unblinding_request_id` FOREIGN KEY (`unblinding_request_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`unblinding_request`(`unblinding_request_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` SET TAGS ('dbx_domain' = 'randomization');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` SET TAGS ('dbx_subdomain' = 'unblinding_management');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `document_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Document Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `electronic_signature_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `ind_application_id` SET TAGS ('dbx_business_glossary_term' = 'Ind Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Approver Study Assignment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `serious_adverse_event_id` SET TAGS ('dbx_business_glossary_term' = 'Serious Adverse Event (SAE) ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `subject_randomization_id` SET TAGS ('dbx_business_glossary_term' = 'Randomization ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `susar_id` SET TAGS ('dbx_business_glossary_term' = 'Susar Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Document ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_internal' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `approval_number` SET TAGS ('dbx_business_glossary_term' = 'Unblinding Approval Number');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `approval_number` SET TAGS ('dbx_value_regex' = '^UBA-[A-Z0-9]{4,10}-[0-9]{6}$');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'approved|rejected|escalated|pending|withdrawn|conditionally_approved');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `approver_name` SET TAGS ('dbx_business_glossary_term' = 'Approver Full Name');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `approver_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `approver_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `approver_role` SET TAGS ('dbx_value_regex' = 'medical_monitor|pi|sponsor_medical_officer|dsmb_chair|irb_representative|cro_medical_director');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `blinding_maintained` SET TAGS ('dbx_business_glossary_term' = 'Blinding Maintained Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Approver Comments');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `delegation_of_authority` SET TAGS ('dbx_business_glossary_term' = 'Delegation of Authority Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `emergency_unblinding` SET TAGS ('dbx_business_glossary_term' = 'Emergency Unblinding Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `escalation_target_role` SET TAGS ('dbx_value_regex' = 'sponsor_medical_officer|dsmb_chair|irb_chair|regulatory_authority|cro_medical_director');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `gcp_compliance_confirmed` SET TAGS ('dbx_business_glossary_term' = 'GCP Compliance Confirmed Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `irb_iec_notification_required` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Notification Required Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `irb_iec_notified_date` SET TAGS ('dbx_business_glossary_term' = 'IRB/IEC Notified Date');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `notification_sent` SET TAGS ('dbx_business_glossary_term' = 'Notification Sent Flag');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `notification_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Notification Sent Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `response_time_hours` SET TAGS ('dbx_business_glossary_term' = 'Response Time (Hours)');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `signature_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Electronic Signature Timestamp');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `signature_timestamp` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `source_system_record_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `treatment_arm_revealed` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `unblinding_reason_category` SET TAGS ('dbx_value_regex' = 'emergency_medical|sae_reporting|regulatory_requirement|dsmb_review|study_completion|protocol_deviation');

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
