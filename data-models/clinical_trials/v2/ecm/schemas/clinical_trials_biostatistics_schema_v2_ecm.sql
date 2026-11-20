-- Schema for Domain: biostatistics | Business: Clinical_Trials | Version: v2_ecm
-- Generated on: 2026-11-20 10:02:57

CREATE DATABASE IF NOT EXISTS `clinical_trials_ecm`.`biostatistics` COMMENT 'Owns the statistical planning and analysis lifecycle for clinical trials. Manages the source system versioning, randomization scheme design, sample size calculations, ADaM dataset specifications, TLF production, interim and final analyses';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`biostatistics`.`sap` (
    `sap_id` BIGINT COMMENT 'Unique surrogate identifier for the Statistical Analysis Plan record in the Databricks Silver Layer. Primary key for this entity.',
    `application_id` BIGINT COMMENT 'Foreign key linking to regulatory.application. Business justification: The the source system under a specific regulatory application (IND/NDA/BLA). IND annual reports and NDA/BLA submissions require the current the source system associated with the',
    `blinding_config_id` BIGINT COMMENT 'Foreign key linking to randomization.blinding_config. Business justification: The the source system the blinding configuration governing statistician access, interim analysis unblinding procedures, and firewall requirements.',
    `clinical_program_id` BIGINT COMMENT 'Foreign key linking to program.clinical_program. Business justification: Integrated Summary of Safety/Efficacy (ISS/ISE) the source system at program level per ICH E3 regulatory requirements.',
    `lead_statistician_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Regulatory accountability requires the the source system to be a named, GCP-certified employee.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor who commissioned the study and owns the the source system. Supports sponsor-level reporting and access control.',
    `pipeline_asset_id` BIGINT COMMENT 'Foreign key linking to sponsor.pipeline_asset. Business justification: The the source system for a specific investigational product. Asset modality, mechanism of action, and development phase directly inform primary_endpoint_description, analysis_type, and',
    `rand_scheme_id` BIGINT COMMENT 'Foreign key linking to randomization.rand_scheme. Business justification: ICH E9 requires the the source system the randomization method. The the source system the exact rand_scheme version it was designed around for regulatory submission alignment.',
    `regulatory_strategy_id` BIGINT COMMENT 'Foreign key linking to regulatory.strategy. Business justification: The regulatory strategy defines the submission pathway, primary endpoint, and analysis population that the the source system with.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this Statistical Analysis Plan (the source system) was authored. Links the the source system parent study master record.',
    `submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission. Business justification: CTD Module 5 submission assembly requires knowing which the source system included in each NDA/BLA/MAA submission.',
    `tmf_document_id` BIGINT COMMENT 'Document identifier assigned by Veeva Vault eTMF for this the source system cross-system traceability between the Databricks Silver Layer and the Veeva Vault document management system.',
    `adam_dataset_specifications` STRING COMMENT 'Reference to or summary of the ADaM (Analysis Data Model) dataset specifications linked to this the source system, including key analysis datasets (ADSL, ADAE, ADTTE, ADLB, etc.) and their derivation rules.',
    `alpha_spending_function` STRING COMMENT 'Statistical alpha spending function used to allocate the overall significance level across planned interim and final analyses (e.g., OBrien-Fleming, Pocock, Lan-DeMets). Applicable only when interim analyses are planned.',
    `amendment_number` BIGINT COMMENT 'Sequential amendment counter for this the source system (0) for the original version; incremented by 1 for each formal amendment. Supports amendment history tracking required for regulatory submissions.',
    `amendment_rationale` STRING COMMENT 'Narrative justification for the the source system the business or scientific reason for changes (e.g., protocol amendment, regulatory feedback, updated endpoint definition). Required for regulatory audit trail per ICH E9.',
    `analysis_type` STRING COMMENT 'Classifies the type of statistical analysis governed by this the source system. interim for pre-specified interim analyses (e.g., DSMB/DMC reviews); final for the primary confirmatory analysis; post_hoc for unplanned analyses; exploratory for. Valid values are `interim|final|post_hoc|exploratory`',
    `approval_date` DATE COMMENT 'Date on which this the source system final approval from all required signatories (biostatistics lead, sponsor, and/or medical monitor). Must precede database lock (DBL) for confirmatory trials. Critical regulatory milestone.',
    `authoring_system` STRING COMMENT 'Name of the system used to author and manage this the source system SAS Drug Development, Veeva Vault). Supports system-of-record traceability and integration lineage.. Valid values are `SAS Drug Development|Veeva Vault|Word|other`',
    `blinding_status` STRING COMMENT 'Indicates the blinding state of the the source system time of authoring or approval. blinded means the the source system before unblinding; unblinded means finalized post-unblinding (e.g., for final CSR); partially_unblinded applies to interim. Valid values are `blinded|unblinded|partially_unblinded`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this the source system first created in the system. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles (Attributable, Legible, Contemporaneous, Original, Accurate).',
    `dbl_date` DATE COMMENT 'Date on which the clinical database was locked (DBL) for the analysis covered by this the source system. The the source system approved prior to or on this date for confirmatory analyses. Sourced from Medidata Rave EDC.',
    `dsmb_review_required` BOOLEAN COMMENT 'Indicates whether this the source system supports interim analyses to be reviewed by a Data Safety Monitoring Board (DSMB) or Data Monitoring Committee (DMC). Drives interim analysis planning and blinding procedures.',
    `effective_from` DATE COMMENT 'Date from which this the source system considered effective and binding for statistical analyses. Typically the approval date. Supports version history and regulatory audit trail.',
    `effective_until` DATE COMMENT 'Date on which this the source system superseded by a newer version or retired. Null for the currently active version. Supports version history management and regulatory audit trail.',
    `estimand_description` STRING COMMENT 'Detailed description of the estimand, including the treatment effect of interest, the population, the variable, the population-level summary, and the strategy for handling intercurrent events, aligned with ICH E9(R1) principles.',
    `interim_analysis_count` BIGINT COMMENT 'Number of pre-specified interim analyses planned for this study as defined in the the source system. Zero if no interim analyses are planned. Drives alpha spending function selection and DSMB/DMC meeting scheduling.',
    `is_current_version` BOOLEAN COMMENT 'Indicates whether this record represents the currently active and approved version of the the source system study. Only one version per study should have this flag set to True at any given time.',
    `itt_population_definition` STRING COMMENT 'Formal definition of the Intent-to-Treat (ITT) analysis population as specified in the the source system, including inclusion/exclusion criteria for subjects in this population.',
    `missing_data_strategy` STRING COMMENT 'Strategy for handling missing data and intercurrent events in the analysis, specifying the approach (e.g., treatment policy, hypothetical, composite, while-on-treatment, principal stratum) as defined in ICH E9(R1).',
    `multiplicity_adjustment_method` STRING COMMENT 'Statistical method used to control the family-wise error rate (FWER) or false discovery rate (FDR) when testing multiple hypotheses (e.g., Bonferroni, Holm, Hochberg, Dunnett, hierarchical testing, Benjamini-Hochberg).',
    `number` STRING COMMENT 'Externally-known, human-readable identifier for the the source system assigned by the sponsor or CRO (e.g., the source system-STUDY001-001). Used for regulatory submissions and cross-system referencing in Veeva Vault and SAS Drug Development.. Valid values are `^SAP-[A-Z0-9]{2,20}-[0-9]{3}$`',
    `power_percent` DECIMAL(5,2) COMMENT 'Pre-specified statistical power (1 - beta) expressed as a percentage (e.g., 80.00, 90.00) used in the sample size calculation. Represents the probability of detecting a true treatment effect of the assumed magnitude.',
    `pp_population_definition` STRING COMMENT 'Formal definition of the Per Protocol (PP) analysis population as specified in the the source system, including criteria for protocol deviations that would exclude subjects. Used as a sensitivity analysis population alongside ITT.',
    `primary_endpoint_description` STRING COMMENT 'Full narrative definition of the primary efficacy or safety endpoint as specified in the the source system, including the outcome measure, timepoint, and measurement scale. Aligned with the study protocol and regulatory submission.',
    `primary_statistical_method` STRING COMMENT 'Description of the primary statistical methodology applied to the primary endpoint analysis (e.g., ANCOVA, mixed-effects model for repeated measures (MMRM), Cox proportional hazards, logistic regression). Sourced from SAS Drug Development the source system',
    `regulatory_impact` STRING COMMENT 'Classification of the regulatory impact of this the source system amendment. none for administrative changes; minor for non-material updates; major for changes affecting primary analysis; requires_submission for changes requiring regulatory. Valid values are `none|minor|major|requires_submission`',
    `regulatory_submission_alignment` STRING COMMENT 'Identifies the regulatory submission type(s) this the source system to support (e.g., IND, NDA, BLA, MAA, eCTD). Ensures the the source system statistical requirements of the target regulatory agency.',
    `safety_population_definition` STRING COMMENT 'Formal definition of the safety analysis population as specified in the the source system, typically all randomized subjects who received at least one dose of study treatment. Used for all safety and adverse event analyses.',
    `sample_size` BIGINT COMMENT 'Total number of subjects planned for enrollment as specified in the the source system calculation section. Derived from power calculations and protocol-specified assumptions. Used for enrollment tracking and regulatory review.',
    `secondary_endpoint_description` STRING COMMENT 'Narrative description of all pre-specified secondary endpoints as defined in the the source system. May include multiple endpoints listed in priority order. Supports regulatory review and CSR statistical sections.',
    `sections_modified` STRING COMMENT 'Comma-separated list or narrative description of the source system were modified in this amendment (e.g., Section 3.1 Primary Endpoint, Section 5.2 Multiplicity Adjustment). Supports change impact assessment and regulatory review.',
    `sensitivity_analysis_description` STRING COMMENT 'Description of pre-specified sensitivity analyses designed to assess the robustness of primary analysis conclusions to key assumptions (e.g., missing data assumptions, outlier handling, covariate selection). Required per ICH E9(R1).',
    `significance_level` DECIMAL(5,4) COMMENT 'Pre-specified two-sided alpha level for hypothesis testing (e.g., 0.0500 for 5%). Defines the threshold for declaring statistical significance. May be adjusted for multiplicity. Stored as a decimal fraction.',
    `title` STRING COMMENT 'Full descriptive title of the Statistical Analysis Plan document, typically including the study name, indication, and phase (e.g., Statistical Analysis Plan for a Phase III Randomized Controlled Trial of Drug X in Indication Y).',
    `tlf_specifications` STRING COMMENT 'Reference to or summary of the Tables, Listings, and Figures (TLF) shells or specifications associated with this the source system. Defines the outputs to be produced by the statistical programming team in SAS Drug Development for the CSR.',
    `unblinding_date` DATE COMMENT 'Date on which the study blind was broken for the analysis covered by this the source system if the the source system while the study remained blinded. Supports regulatory audit trail for pre-specification of analyses.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this the source system audit trail requirements under 21 CFR Part 11 and ALCOA+ principles. Used for change detection in ETL pipelines.',
    `version_number` STRING COMMENT 'Version identifier of the the source system semantic versioning convention (e.g., 1.0, 1.1, 2.0). Incremented with each amendment. Supports version history tracking and regulatory audit trail.. Valid values are `^[0-9]+.[0-9]+(.[0-9]+)?$`',
    `version_status` STRING COMMENT 'Current lifecycle status of this the source system indicates authoring in progress; in_review indicates under biostatistics or sponsor review; approved indicates final sign-off obtained; superseded indicates replaced by a newer version; retired. Valid values are `draft|in_review|approved|superseded|retired`',
    CONSTRAINT pk_sap PRIMARY KEY(`sap_id`)
) COMMENT 'Statistical Analysis Plan master record for a clinical study. Captures the source system (including amendments with rationale, sections modified, and regulatory impact), authoring status, approval workflow, blinding status, primary/secondary endpoint';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` (
    `sap_amendment_id` BIGINT COMMENT 'Unique surrogate identifier for each the source system in the Databricks Silver Layer. Primary key for the the source system',
    `approver_employee_id` BIGINT COMMENT 'Reference to the responsible statistician or biostatistics director who formally approved this the source system for regulatory audit trail.',
    `audit_finding_id` BIGINT COMMENT 'Foreign key linking to compliance.audit_finding. Business justification: Audit findings (e.g., analysis method not pre-specified, population definition inconsistency) can mandate the source system',
    `change_order_id` BIGINT COMMENT 'Foreign key linking to agreement.change_order. Business justification: the source system by protocol amendments require contract change orders to cover additional biostatistics scope and cost. Both tables share protocol_amendment_ref.',
    `icf_amendment_id` BIGINT COMMENT 'Foreign key linking to consent.icf_amendment. Business justification: Protocol amendments co-trigger both the source system ICF amendments. Regulatory submissions and inspection readiness require direct traceability linking statistical plan changes to',
    `primary_sap_employee_id` BIGINT COMMENT 'Reference to the biostatistician or statistical programmer who authored this the source system ALCOA+ attributability requirements for audit trail.',
    `regulatory_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to regulatory.protocol_amendment. Business justification: the source system co-submitted with or triggered by protocol amendments. The the source system (plain text denormalization).',
    `reviewer_employee_id` BIGINT COMMENT 'Reference to the qualified statistician or biostatistics lead who performed the quality review of this the source system to approval.',
    `sap_id` BIGINT COMMENT 'Reference to the parent Statistical Analysis Plan document that this amendment revises. Links the amendment to the base the source system',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this the source system issued. Enables study-level traceability of all the source system',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: FDA/EMA expect the source system explicitly reference the protocol amendment that triggered them.',
    `submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission. Business justification: the source system regulatory impact must be submitted to health authorities as IND amendments.',
    `tmf_document_id` BIGINT COMMENT 'Reference to the approved the source system stored in the Veeva Vault eTMF or document management system. Provides direct linkage to the controlled document artifact.',
    `adam_dataset_impact` STRING COMMENT 'Comma-delimited list of ADaM datasets (e.g., ADSL, ADAE, ADTTE, ADLB) whose specifications are affected by this the source system downstream ADaM dataset re-specification and re-validation.',
    `amendment_rationale` STRING COMMENT 'Detailed narrative justification for why the the source system Must document the scientific, operational, or regulatory basis for each change to satisfy GCP audit trail requirements.',
    `amendment_status` STRING COMMENT 'Current lifecycle state of the the source system Tracks progression from authoring through approval and eventual supersession by a later amendment.. Valid values are `draft|under_review|approved|superseded|withdrawn`',
    `amendment_title` STRING COMMENT 'Descriptive title of the the source system the primary change (e.g., Amendment 1: Revised Primary Endpoint Analysis Population). Used in document headers and regulatory submissions.',
    `amendment_type` STRING COMMENT 'Classification of the amendment scope: major (changes to primary/key secondary endpoints, analysis populations, or statistical methods), minor (clarifications or secondary analysis changes), or administrative (formatting, typo corrections, contact. Valid values are `major|minor|administrative`',
    `amendment_version_code` STRING COMMENT 'Human-readable version label for the amended the source system v1.1, v2.0, v3.1). Aligns with document management versioning conventions in Veeva Vault eTMF.. Valid values are `^v[0-9]+.[0-9]+(.[0-9]+)?$`',
    `analysis_population_changed` BOOLEAN COMMENT 'Indicates whether this amendment modifies the definition of any analysis population (e.g., Intent-to-Treat (ITT), Per Protocol (PP), Safety population). Population changes affect the integrity of the statistical inference.',
    `approval_date` DATE COMMENT 'Date on which the the source system final approval from the responsible statistician and sponsor. This is the effective date from which the amended analysis plan governs study conduct.',
    `approver_name` STRING COMMENT 'Full name of the responsible statistician or biostatistics director who approved this the source system at time of approval for regulatory audit trail integrity.',
    `author_name` STRING COMMENT 'Full name of the biostatistician or statistical programmer who authored this the source system at time of authorship for audit trail integrity per ALCOA+ principles.',
    `authored_date` DATE COMMENT 'Date on which the the source system completed by the author and submitted for review. Establishes the contemporaneous authorship timestamp per ALCOA+ principles.',
    `blinding_impact` STRING COMMENT 'Assessment of whether this amendment has any impact on study blinding integrity. Amendments that require access to unblinded data must be documented and controlled to prevent bias.. Valid values are `none|potential_unblinding|unblinding_required`',
    `change_summary` STRING COMMENT 'Concise executive summary of all changes introduced by this amendment, suitable for inclusion in the Clinical Study Report (CSR) statistical section and regulatory submission cover letter.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this the source system was first created in the data platform. Supports ALCOA+ audit trail and 21 CFR Part 11 electronic record requirements.',
    `dbl_date` DATE COMMENT 'Date on which the clinical database was locked at the time this amendment was classified. Used to determine pre- vs. post-DBL status and regulatory impact.',
    `dsmb_notification_required` BOOLEAN COMMENT 'Indicates whether the DSMB/DMC must be notified of this the source system when interim analysis plans or stopping rules are modified.',
    `effective_date` DATE COMMENT 'Date from which this the source system operationally effective and supersedes the prior version. May differ from approval date if a transition period is required.',
    `interim_analysis_changed` BOOLEAN COMMENT 'Indicates whether this amendment modifies the interim analysis plan, including timing, stopping rules, alpha spending, or DSMB/DMC charter alignment.',
    `irb_iec_notification_required` BOOLEAN COMMENT 'Indicates whether this the source system notification or submission to the IRB/IEC overseeing the study. Relevant when the source system subject safety or consent.',
    `missing_data_method_changed` BOOLEAN COMMENT 'Indicates whether this amendment revises the strategy for handling missing data (e.g., Last Observation Carried Forward (LOCF), multiple imputation, mixed models). Missing data methodology is a key regulatory focus area.',
    `pre_dbl_flag` BOOLEAN COMMENT 'Indicates whether this amendment was issued before (True) or after (False) the Database Lock (DBL). Pre-DBL amendments are standard; post-DBL amendments require heightened regulatory scrutiny and justification.',
    `primary_endpoint_changed` BOOLEAN COMMENT 'Indicates whether this amendment includes a change to the primary efficacy endpoint definition or analysis. Primary endpoint changes post-DBL are subject to heightened regulatory scrutiny.',
    `randomization_scheme_changed` BOOLEAN COMMENT 'Indicates whether this amendment modifies the randomization scheme or stratification factors used in the statistical analysis. Changes to randomization factors require protocol-level review.',
    `regulatory_impact_assessment` STRING COMMENT 'Assessed level of regulatory impact of this the source system the studys regulatory submission package (IND, NDA, BLA, MAA). Drives escalation, notification, and documentation requirements.. Valid values are `none|low|medium|high|critical`',
    `regulatory_notification_required` BOOLEAN COMMENT 'Indicates whether this amendment requires formal notification to a regulatory authority (FDA, EMA, PMDA, etc.) as part of a protocol amendment or IND safety report.',
    `review_completed_date` DATE COMMENT 'Date on which the quality review of the the source system completed and the document was forwarded for approval.',
    `sample_size_changed` BOOLEAN COMMENT 'Indicates whether this amendment revises the planned sample size or power assumptions. Sample size changes typically require protocol amendment and regulatory notification.',
    `sas_program_reference` STRING COMMENT 'Reference path or identifier for the SAS Drug Development program(s) updated to implement this the source system traceability between the statistical plan and the analysis code.',
    `sections_modified` STRING COMMENT 'Comma-delimited list or narrative description of the the source system and titles that were changed in this amendment (e.g., 3.1 Primary Endpoint, 5.2 Analysis Population, 7.4 Missing Data Handling). Enables targeted review of changes.',
    `sponsor_signatory_name` STRING COMMENT 'Name of the sponsor representative who co-signed or endorsed this the source system sponsor sign-off is contractually or regulatorily required.',
    `superseded_date` DATE COMMENT 'Date on which this amendment was superseded by a subsequent amendment. Null if this is the current active version. Enables point-in-time reconstruction of the the source system',
    `tlf_impact` STRING COMMENT 'Description or list of Tables, Listings, and Figures (TLFs) in the Clinical Study Report (CSR) that are affected by this the source system to scope re-programming and QC activities.',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp of the most recent update to this the source system Used for change detection, incremental ETL processing, and audit trail completeness.',
    CONSTRAINT pk_sap_amendment PRIMARY KEY(`sap_amendment_id`)
) COMMENT 'Versioned amendment record for a Statistical Analysis Plan. Tracks each the source system amendment number, rationale for change, sections modified, pre- or post-database-lock classification, author, approver, approval date, and regulatory impact';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` (
    `analysis_population_id` BIGINT COMMENT 'Unique surrogate identifier for the analysis population record within the biostatistics data product. Primary key for the analysis_population entity.',
    `sap_id` BIGINT COMMENT 'Reference to the Statistical Analysis Plan (the source system) document version that formally defines and governs this analysis population. Ensures traceability from population definition to the authoritative the source system.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this analysis population is defined. Links the population definition to its parent study context.',
    `acronym` STRING COMMENT 'Standardized abbreviation for the analysis population (e.g., ITT, mITT, PP, SAF, PK, PD). Used in TLF titles, CSR statistical sections, and ADaM dataset variable labels.. Valid values are `^[A-Z]{2,10}$`',
    `adam_dataset_name` STRING COMMENT 'The CDISC ADaM dataset name where the ADSL flag variable for this population resides (typically ADSL). Used to locate the population flag in the ADaM submission package.. Valid values are `^[A-Z]{2,8}$`',
    `adsl_flag_variable` STRING COMMENT 'The CDISC ADaM ADSL dataset flag variable name (e.g., ITTFL, SAFFL, PPROTFL, MITTFL, PKFL) that identifies subjects belonging to this population. Must conform to CDISC ADaM naming convention ending in FL.. Valid values are `^[A-Z]{2,8}FL$`',
    `analysis_phase` STRING COMMENT 'Designates the analysis phase in which this population definition is applied: interim analysis, final analysis, post-hoc analysis, or exploratory analysis. Governs which TLF shells and CSR sections reference this population.. Valid values are `interim|final|post_hoc|exploratory`',
    `blinding_status` STRING COMMENT 'Indicates whether the analysis population is evaluated under blinded, unblinded, or open-label conditions at the time of analysis. Critical for DSMB/DMC interim reviews and final unblinding records.. Valid values are `blinded|unblinded|open_label`',
    `cdisc_standard_version` STRING COMMENT 'The version of the CDISC ADaM standard applied to the derivation of this analysis population (e.g., ADaM IG v1.3, ADSL v1.1). Required for FDA/EMA electronic submission conformance.',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this analysis population record was first created in the system, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `dbl_date` DATE COMMENT 'The date on which the study database was locked (DBL) for the analysis associated with this population. Subject counts and population assignments are finalized as of this date.',
    `dose_received_required_flag` BOOLEAN COMMENT 'Indicates whether receipt of at least one dose of investigational product is a mandatory inclusion criterion for this analysis population. Distinguishes ITT (randomized only) from Safety (randomized and dosed) populations.',
    `effective_from_date` DATE COMMENT 'The date from which this version of the analysis population definition became effective, supporting the source system Enables temporal tracking of population definition changes across the source system',
    `exclusion_criteria_description` STRING COMMENT 'Narrative description of the criteria that would exclude a subject from this analysis population despite meeting inclusion criteria (e.g., major protocol deviations, missing primary endpoint data). Defined in the the source system.',
    `inclusion_criteria_description` STRING COMMENT 'Narrative description of the criteria a subject must meet to be included in this analysis population, as defined in the the source system. Captures the logical rules (e.g., randomized and received at least one dose of study drug).',
    `missing_endpoint_handling` STRING COMMENT 'The pre-specified method for handling missing primary endpoint data for subjects in this population, as defined in the the source system - Last Observation Carried Forward, multiple imputation, observed cases only).. Valid values are `locf|bocf|wocf|multiple_imputation|observed_cases|none`',
    `notes` STRING COMMENT 'Free-text field for biostatistician notes, clarifications, or amendments related to this analysis population definition. May capture DSMB/DMC recommendations, protocol amendment impacts, or sponsor queries.',
    `planned_sample_size` BIGINT COMMENT 'The pre-specified planned number of subjects for this analysis population as determined by the sample size calculation in the the source system. Serves as the denominator benchmark for enrollment tracking and power calculations.',
    `population_code` STRING COMMENT 'Short, unique alphanumeric code identifying the analysis population within the study (e.g., ITT, PP, SAF, MITT, PK). Used as the CDISC ADaM ADSL flag variable name prefix and in TLF shell headers.. Valid values are `^[A-Z0-9_]{2,20}$`',
    `population_finalized_date` DATE COMMENT 'The date on which the analysis population definition was formally finalized and approved in the the source system, prior to unblinding. Supports pre-specification audit trail for regulatory compliance.',
    `population_logic_summary` STRING COMMENT 'Concise programmatic or pseudo-code summary of the population derivation logic used in SAS Drug Development ADaM programming (e.g., RANDFL=Y AND DOSEFL=Y). Bridges the narrative the source system the SAS implementation.',
    `population_name` STRING COMMENT 'Full descriptive name of the analysis population as defined in the the source system Population, Per Protocol Population, Safety Population, Modified Intent-to-Treat Population, Pharmacokinetic Population).',
    `population_rationale` STRING COMMENT 'Scientific and regulatory rationale for defining this analysis population, as documented in the the source system. Explains why this population is appropriate for the associated analysis objectives and how it aligns with regulatory guidance.',
    `population_status` STRING COMMENT 'Current lifecycle status of the analysis population definition. Tracks progression from initial the source system biostatistics review, approval, and potential supersession by an amended the source system. Valid values are `draft|under_review|approved|superseded|retired`',
    `population_type` STRING COMMENT 'Categorical classification of the analysis population by its primary analytical purpose. [ENUM-REF-CANDIDATE: efficacy|safety|pharmacokinetic|pharmacodynamic|per_protocol|modified_itt|other — promote to reference product]',
    `primary_population_flag` BOOLEAN COMMENT 'Indicates whether this population is designated as the primary analysis population for the study as specified in the the source system. The primary population drives the primary efficacy endpoint analysis and regulatory submission.',
    `protocol_deviation_exclusion_flag` BOOLEAN COMMENT 'Indicates whether subjects with major protocol deviations are excluded from this analysis population. Typically True for Per Protocol (PP) populations and False for ITT populations.',
    `randomization_required_flag` BOOLEAN COMMENT 'Indicates whether randomization is a mandatory inclusion criterion for subjects in this analysis population. True for ITT and most efficacy populations; may be False for screening failure or safety populations.',
    `regulatory_primary_flag` BOOLEAN COMMENT 'Indicates whether this population is the pre-specified primary population for regulatory submission purposes (NDA/BLA/MAA). Distinct from internal primary flag; reflects the population declared in the IND/protocol.',
    `sap_section_reference` STRING COMMENT 'The specific section number or identifier within the the source system formally defines this analysis population (e.g., Section 5.2.1). Enables direct traceability from the data product to the governing statistical document.',
    `sap_version` STRING COMMENT 'Version number of the the source system which this analysis population definition was introduced or last amended (e.g., v1.0, v2.1). Supports version-controlled traceability for regulatory audit.. Valid values are `^vd+.d+$`',
    `sas_program_name` STRING COMMENT 'Name of the SAS Drug Development program used to derive and validate the ADSL flag variable for this analysis population (e.g., adsl.sas). Enables traceability from population definition to the validated SAS code.',
    `sensitivity_analysis_flag` BOOLEAN COMMENT 'Indicates whether this population is designated as a sensitivity analysis population (as opposed to a primary or secondary analysis population). Sensitivity populations test the robustness of primary analysis conclusions.',
    `subject_count_at_dbl` BIGINT COMMENT 'The number of subjects assigned to this analysis population at the time of Database Lock (DBL). This is the final, locked count used in the Clinical Study Report (CSR) and regulatory submission.',
    `subject_count_interim` BIGINT COMMENT 'Number of subjects assigned to this analysis population at the most recent interim analysis cut, if applicable. Used by the DSMB/DMC for interim review and blinded/unblinded reporting.',
    `submission_population_flag` BOOLEAN COMMENT 'Indicates whether this analysis population is included in the regulatory submission package (NDA/BLA/MAA/eCTD). Populations marked True must have fully validated ADaM datasets and TLF outputs.',
    `tlf_shell_reference` STRING COMMENT 'Reference identifier(s) for the TLF shells that use this analysis population as their denominator or subject set. Links the population definition to the output specifications in the the source system/TLF shell document.',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this analysis population record was last modified, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `validation_status` STRING COMMENT 'Current validation status of the SAS programming for this analysis populations ADSL flag variable in SAS Drug Development. Tracks QC progress from initial programming through double-programming validation.. Valid values are `not_started|in_progress|validated|failed`',
    CONSTRAINT pk_analysis_population PRIMARY KEY(`analysis_population_id`)
) COMMENT 'Defines the analysis populations used in a study (e.g., Intent-to-Treat, Per Protocol, Safety, Modified ITT, Pharmacokinetic). Captures population name, acronym, inclusion/exclusion logic description, CDISC ADSL flag variable name, population size at DBL';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` (
    `sample_size_calc_id` BIGINT COMMENT 'Unique surrogate identifier for each sample size calculation record within the biostatistics domain.',
    `analysis_population_id` BIGINT COMMENT 'Foreign key linking to biostatistics.analysis_population. Business justification: sample_size_calc has analysis_population (STRING) indicating which population the sample size calculation targets.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Sample size calculations require a named approving statistician for protocol and regulatory submission documentation.',
    `pipeline_asset_id` BIGINT COMMENT 'Foreign key linking to sponsor.pipeline_asset. Business justification: Sample size assumptions (effect_size, dropout_rate, event_rate_control) are derived from the pipeline assets prior clinical data and development phase.',
    `protocol_id` BIGINT COMMENT 'Reference to the specific protocol version under which this sample size calculation was conducted, supporting traceability to protocol amendments.',
    `rand_scheme_id` BIGINT COMMENT 'Foreign key linking to randomization.rand_scheme. Business justification: Sample size calculations depend directly on the randomization schemes allocation_ratio, block structure, and stratification.',
    `sap_id` BIGINT COMMENT 'Reference to the Statistical Analysis Plan (the source system) document that governs or references this sample size calculation.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this sample size calculation was performed.',
    `accrual_period_months` BIGINT COMMENT 'The assumed patient accrual (enrollment) period in months, used in time-to-event sample size calculations to determine the number of events required.',
    `allocation_ratio` DECIMAL(18,2) COMMENT 'The randomization allocation ratio between treatment arms (e.g., 1:1, 2:1, 1:1:1), specifying the relative number of subjects assigned to each arm.',
    `alpha_level` DECIMAL(10,6) COMMENT 'The pre-specified Type I error rate (significance level, alpha) used in the sample size calculation, typically 0.05 for two-sided or 0.025 for one-sided tests.',
    `alpha_spending_method` STRING COMMENT 'The alpha-spending function applied to control Type I error across planned interim analyses (e.g., OBrien-Fleming, Pocock, Lan-DeMets). Null or none if no interim analysis is planned.. Valid values are `OBrien_Fleming|Pocock|Lan_DeMets|Haybittle_Peto|none`',
    `amendment_reason` STRING COMMENT 'Narrative justification for revising a prior version of the sample size calculation, such as updated assumptions from interim data, protocol amendment, or regulatory feedback.',
    `approval_date` DATE COMMENT 'The date on which the sample size calculation was formally approved by the responsible biostatistician, marking readiness for inclusion in regulatory submissions.',
    `calc_date` DATE COMMENT 'The date on which this sample size calculation was performed or finalized, serving as the principal business event date for regulatory traceability.',
    `calc_identifier` STRING COMMENT 'Externally-known alphanumeric code or reference number assigned to this sample size calculation, used in regulatory submissions and protocol documentation (e.g., SSC-2024-001).',
    `calc_status` STRING COMMENT 'Current lifecycle status of the sample size calculation record, from initial draft through regulatory approval to archival.. Valid values are `draft|under_review|approved|superseded|archived`',
    `calc_version` STRING COMMENT 'Version number of this sample size calculation (e.g., v1.0, v2.1), enabling tracking of revisions driven by protocol amendments or updated assumptions.. Valid values are `^vd+.d+$`',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this sample size calculation record was first created in the system, supporting audit trail requirements under 21 CFR Part 11.',
    `dropout_rate` DECIMAL(10,6) COMMENT 'The assumed proportion of enrolled subjects expected to discontinue or be lost to follow-up, used to inflate the calculated sample size to ensure adequate evaluable subjects.',
    `effect_size` DECIMAL(18,6) COMMENT 'The clinically meaningful difference or effect size assumed between treatment arms (e.g., mean difference, odds ratio, hazard ratio) used as the basis for the sample size calculation.',
    `effect_size_unit` STRING COMMENT 'Unit of measurement for the assumed effect size (e.g., mmHg, %, hazard ratio, odds ratio, mean difference), providing dimensional context for regulatory interpretation.',
    `event_rate_control` DECIMAL(10,6) COMMENT 'The assumed event rate or response rate in the control arm, applicable for binary or time-to-event endpoints. Null for continuous endpoints.',
    `event_rate_treatment` DECIMAL(10,6) COMMENT 'The assumed event rate or response rate in the treatment arm, applicable for binary or time-to-event endpoints. Null for continuous endpoints.',
    `follow_up_period_months` BIGINT COMMENT 'The assumed minimum follow-up period in months after the last patient enrolled, used in time-to-event calculations to ensure sufficient events are observed.',
    `hypothesis_type` STRING COMMENT 'The statistical hypothesis framework applied (superiority, non-inferiority, equivalence), which determines the directionality and margin used in the sample size formula.. Valid values are `superiority|non_inferiority|equivalence|one_sided|two_sided`',
    `interim_analysis_planned` BOOLEAN COMMENT 'Indicates whether one or more interim analyses are planned for this study, which may require alpha-spending adjustments to the sample size calculation.',
    `median_survival_control` DECIMAL(18,6) COMMENT 'The assumed median survival time in the control arm for time-to-event endpoints, used in log-rank or exponential model-based sample size calculations. Null for non-survival endpoints.',
    `non_inferiority_margin` DECIMAL(18,6) COMMENT 'The pre-specified non-inferiority or equivalence margin (delta) used in the hypothesis test, applicable when hypothesis_type is non_inferiority or equivalence. Null for superiority designs.',
    `number_of_arms` BIGINT COMMENT 'Total number of treatment arms (including control) in the study design, used to determine the allocation structure and multiplicity adjustments.',
    `number_of_events_required` BIGINT COMMENT 'The minimum number of primary endpoint events (e.g., deaths, progressions) required to achieve the specified power for time-to-event analyses. Null for non-event-driven endpoints.',
    `power` DECIMAL(10,6) COMMENT 'The pre-specified statistical power (1 minus Type II error rate, beta) used in the calculation, representing the probability of detecting the assumed effect size. Typically 0.80 or 0.90.',
    `primary_endpoint_description` STRING COMMENT 'Narrative description of the primary endpoint used in the sample size calculation (e.g., Change from baseline in HbA1c at Week 24), providing clinical context for regulatory reviewers.',
    `primary_endpoint_type` STRING COMMENT 'Statistical nature of the primary efficacy endpoint (e.g., continuous, binary, time-to-event, ordinal, count) that drives the choice of sample size formula.. Valid values are `continuous|binary|time_to_event|ordinal|count`',
    `reference_source` STRING COMMENT 'Citation or reference for the data source used to derive the assumed effect size, standard deviation, or event rate (e.g., published literature citation, prior Phase II study identifier, internal pilot data).',
    `sample_size_per_arm` BIGINT COMMENT 'The calculated number of subjects required per treatment arm to achieve the specified power at the given alpha level, accounting for the assumed effect size and standard deviation.',
    `software_name` STRING COMMENT 'Name of the validated statistical software used to perform the sample size calculation (e.g., PASS, nQuery Advisor, SAS PROC POWER, R), required for regulatory audit trail.',
    `software_version` STRING COMMENT 'Version number of the statistical software used (e.g., PASS 2023, nQuery 9.1), required for reproducibility and regulatory validation documentation.',
    `standard_deviation` DECIMAL(18,6) COMMENT 'The assumed population standard deviation for continuous endpoints, derived from prior studies or literature, used in the sample size formula. Null for non-continuous endpoints.',
    `statistical_method` STRING COMMENT 'The specific statistical formula or method used for the calculation (e.g., two-sample t-test, log-rank test, chi-square test, Kaplan-Meier), providing methodological traceability.',
    `study_design_type` STRING COMMENT 'The clinical trial design type (e.g., parallel group, crossover, factorial, adaptive) that determines the statistical methodology applied in the sample size calculation.. Valid values are `parallel|crossover|factorial|adaptive|basket|umbrella`',
    `study_phase` STRING COMMENT 'Clinical development phase of the study (Phase I through Phase IV) for which the sample size is being calculated, influencing regulatory expectations and statistical rigor.. Valid values are `Phase I|Phase II|Phase IIa|Phase IIb|Phase III|Phase IV`',
    `test_sidedness` STRING COMMENT 'Specifies whether the statistical test is one-sided or two-sided, directly affecting the critical value and resulting sample size.. Valid values are `one_sided|two_sided`',
    `total_enrollment_target` BIGINT COMMENT 'The total number of subjects to be enrolled (randomized) after inflating the total sample size by the assumed dropout rate, representing the actual recruitment target submitted in the protocol.',
    `total_sample_size` BIGINT COMMENT 'The total number of subjects required across all treatment arms before applying the dropout inflation, representing the minimum evaluable sample.',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time when this sample size calculation record was most recently modified, supporting version control and audit trail requirements.',
    CONSTRAINT pk_sample_size_calc PRIMARY KEY(`sample_size_calc_id`)
) COMMENT 'Records sample size calculations performed during study design and protocol development. Captures study phase, primary endpoint type, assumed effect size, standard deviation, alpha level, power, dropout rate, allocation ratio, calculated sample size per';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` (
    `adam_dataset_spec_id` BIGINT COMMENT 'Unique surrogate identifier for each ADaM dataset specification record. Primary key for this entity. Role: MASTER_RESOURCE.',
    `analysis_population_id` BIGINT COMMENT 'Foreign key linking to biostatistics.analysis_population. Business justification: adam_dataset_spec has analysis_population (STRING) indicating which analysis population the dataset serves.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: CDISC ADaM submission packages require named approvers whose qualifications are verifiable.',
    `sap_id` BIGINT COMMENT 'Reference to the Statistical Analysis Plan that governs the derivation rules and analysis objectives for this ADaM dataset. Ensures traceability from dataset design to the approved the source system.',
    `sdtm_dataset_id` BIGINT COMMENT 'Foreign key linking to datamanagement.sdtm_dataset. Business justification: ADaM dataset specs are derived from specific SDTM datasets. Biostatisticians and programmers reference the source SDTM dataset record for version, QC status, and data cut date',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this ADaM dataset specification is authored. Links the specification to its parent protocol and study context.',
    `adam_ig_version` STRING COMMENT 'Version of the CDISC ADaM Implementation Guide to which this dataset specification conforms (e.g., ADaM IG v1.3, ADSL v1.1, BDS v1.1). Required for regulatory submission conformance validation.',
    `analysis_variable_flag` BOOLEAN COMMENT 'Indicates whether this variable is a primary analysis variable (AVAL, AVALC, or equivalent) used directly in statistical analyses and TLF production. True = analysis variable; False = supporting/descriptive variable. Guides programmer prioritization.',
    `approval_date` DATE COMMENT 'Date on which this ADaM dataset specification was formally approved by the lead biostatistician and/or statistical programming lead. Marks the specification as ready for SAS programming implementation.',
    `authored_by` STRING COMMENT 'Name or user identifier of the biostatistician who authored this ADaM dataset specification. Establishes accountability and is referenced in the audit trail for regulatory inspection readiness.',
    `blinding_status` STRING COMMENT 'Indicates whether this ADaM dataset contains unblinded treatment assignment data. Blinded = treatment codes masked; Unblinded = actual treatment assignments visible (post-DBL or for open-label studies); Open-Label = study design is inherently unblinded.. Valid values are `Blinded|Unblinded|Open-Label`',
    `change_reason` STRING COMMENT 'Narrative justification for changes introduced in this version of the specification relative to the prior version (e.g., the source system added new secondary endpoint, Protocol amendment PA-003 added new visit).',
    `codelist_name` STRING COMMENT 'Name of the specific CDISC or sponsor-defined codelist associated with this variable (e.g., NY, SEX, RACE, DTYPE). Referenced in the define.xml ItemDef and used for PINNACLE 21 conformance validation.',
    `controlled_terminology` STRING COMMENT 'Reference to the controlled terminology codelist applicable to this variable (e.g., CDISC SDTM CT RACE, NCI Thesaurus C66742, MedDRA v26.0 PT, WHO-DD). Ensures standardized values for regulatory submission and cross-study comparability.',
    `core_designation` STRING COMMENT 'CDISC ADaM core designation indicating the requirement level for this variable. Required = must be present in all datasets of this class; Expected = should be present when applicable; Permissible = may be included at sponsor discretion.. Valid values are `Required|Expected|Permissible`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this ADaM dataset specification record was first created in the system. Supports audit trail and record lineage per 21 CFR Part 11 and ALCOA+ principles.',
    `dataset_class` STRING COMMENT 'CDISC ADaM structural class of the dataset. ADSL = Subject-Level Analysis Dataset (one record per subject); BDS = Basic Data Structure (one or more records per subject per analysis parameter per analysis timepoint); OCCDS = Occurrence Data Structure (one. Valid values are `ADSL|BDS|OCCDS|OTHER`',
    `dataset_label` STRING COMMENT 'Human-readable descriptive label for the dataset (e.g., Subject-Level Analysis Dataset, Adverse Events Analysis Dataset). Used in SAS PROC CONTENTS output and regulatory submission metadata.',
    `dataset_name` STRING COMMENT 'Short, uppercase dataset name conforming to CDISC ADaM naming conventions (e.g., ADSL, ADAE, ADTTE, ADLB, ADCM, ADEX, ADRS). Maximum 8 characters per CDISC standard.. Valid values are `^[A-Z]{2,8}$`',
    `dataset_purpose` STRING COMMENT 'The intended analytical purpose of the ADaM dataset (e.g., efficacy, safety, pharmacokinetics), describing how the dataset will be used in the statistical analysis and reporting.',
    `define_xml_version` STRING COMMENT 'Version of the CDISC Define-XML standard used to generate the define.xml metadata file for this dataset (e.g., Define-XML v2.0, Define-XML v2.1). Required for FDA and EMA electronic submission packages.',
    `derivation_algorithm` STRING COMMENT 'Detailed narrative or pseudocode describing the derivation logic for this variable, including source variables, transformation rules, imputation methods (e.g., LOCF), and conditional logic. The primary programming instruction for SAS programmers.',
    `effective_date` DATE COMMENT 'Date from which this version of the ADaM dataset specification is effective and authoritative for programming use. For superseded versions, this marks the start of the versions validity period.',
    `interim_analysis_flag` BOOLEAN COMMENT 'Indicates whether this dataset specification is intended for use in an interim analysis (True) or the final analysis (False). Interim analysis datasets may have restricted access and require DSMB/DMC review procedures.',
    `key_variables` STRING COMMENT 'Comma-separated list of variable names that form the unique record key for this dataset (e.g., USUBJID for ADSL; USUBJID, PARAMCD, ADT for BDS datasets). Defines the grain of the dataset and is critical for merge/join operations in SAS programming.',
    `pinnacle21_validation_status` STRING COMMENT 'Result of the Pinnacle 21 (formerly OpenCDISC) conformance validation run against this ADaM dataset. Pass = no errors; Pass with Warnings = minor issues noted; Fail = conformance errors requiring remediation; Not Run = validation pending.. Valid values are `Pass|Pass with Warnings|Fail|Not Run`',
    `programming_language` STRING COMMENT 'Statistical programming language used to implement this ADaM dataset specification. SAS is the regulatory standard; R and Python may be used for exploratory or supplemental analyses. Governs QC and validation approach.. Valid values are `SAS|R|Python|Other`',
    `qc_method` STRING COMMENT 'Quality control methodology applied to validate this ADaM dataset. Double Programming = independent programmer recreates dataset and compares; Peer Review = senior programmer reviews code and output; Independent QC = separate QC team validates; Not. Valid values are `Double Programming|Peer Review|Independent QC|Not Required`',
    `qc_status` STRING COMMENT 'Current QC completion status for this ADaM dataset. Not Started = QC not yet initiated; In Progress = QC underway; QC Complete = dataset passed QC validation; Failed QC = discrepancies found requiring programmer remediation.. Valid values are `Not Started|In Progress|QC Complete|Failed QC`',
    `sas_format` STRING COMMENT 'SAS display format assigned to this variable (e.g., DATE9., DATETIME20., $CHAR200., 8.2). Governs how values are displayed in SAS output and define.xml DisplayFormat attribute. Required for SAS Drug Development programming specifications.',
    `sas_informat` STRING COMMENT 'SAS informat used to read raw values into this variable (e.g., YYMMDD10., E8601DT., $CHAR200.). Required for date/datetime variables derived from ISO 8601 SDTM character dates. Specified in SAS Drug Development programming specs.',
    `sas_program_reference` STRING COMMENT 'File path or program name of the SAS program in SAS Drug Development that produces this ADaM dataset (e.g., /studies/STUDY001/adam/programs/adsl.sas). Links the specification to its implementing program for traceability and QC.',
    `source_variable` STRING COMMENT 'Name of the source SDTM or predecessor ADaM variable(s) from which this variable is derived (e.g., AE.AEDECOD, DM.RFSTDTC, ADSL.TRT01P). Supports CDISC traceability requirements and audit trail for regulatory submissions.',
    `spec_status` STRING COMMENT 'Current lifecycle status of the ADaM dataset specification. Draft = initial authoring; Under Review = submitted for biostatistics/programming review; Approved = formally signed off for programming use; Superseded = replaced by a newer version; Retired =. Valid values are `Draft|Under Review|Approved|Superseded|Retired`',
    `spec_version` STRING COMMENT 'Version number of this ADaM dataset specification document following major.minor versioning (e.g., 1.0, 1.1, 2.0). Incremented upon each approved revision to support change control and audit traceability.. Valid values are `^d+.d+$`',
    `submission_flag` BOOLEAN COMMENT 'Indicates whether this ADaM dataset is included in the regulatory submission package (NDA, BLA, MAA, or IND). True = included in eCTD submission; False = internal analysis only. Governs define.xml inclusion and FDA/EMA conformance validation requirements.',
    `superseded_date` DATE COMMENT 'Date on which this version of the specification was superseded by a newer version. Null for the current active version. Supports version history and audit trail for regulatory inspection.',
    `timing_variable_flag` BOOLEAN COMMENT 'Indicates whether this variable is a CDISC ADaM timing variable (e.g., ADT, ADTM, ADY, AVISIT, AVISITN). True = timing variable subject to ADaM timing variable conventions. Used for conformance checking and define.xml classification.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this ADaM dataset specification record. Supports change tracking and audit trail per 21 CFR Part 11 and ALCOA+ principles.',
    `variable_label` STRING COMMENT 'Descriptive SAS variable label (max 256 characters) providing a human-readable description of the variable (e.g., Unique Subject Identifier, Parameter Code, Analysis Value). Appears in SAS PROC CONTENTS and submission define.xml.',
    `variable_length` BIGINT COMMENT 'SAS variable length in bytes. For character variables, specifies maximum string length (e.g., 200 for USUBJID). For numeric variables, typically 8 (SAS default double precision). Required for SAS dataset creation and define.xml generation.',
    `variable_name` STRING COMMENT 'SAS-compliant variable name for this specification record (uppercase, max 8 characters per SAS/CDISC convention, e.g., USUBJID, PARAMCD, AVAL, DTYPE). Each row in. Valid values are `^[A-Z][A-Z0-9]{0,7}$`',
    `variable_type` STRING COMMENT 'SAS data type of the variable. Char = character/string variable; Num = numeric variable. Governs SAS dataset structure and informat/format assignments in programming specifications.. Valid values are `Char|Num`',
    CONSTRAINT pk_adam_dataset_spec PRIMARY KEY(`adam_dataset_spec_id`)
) COMMENT 'Specification record for each ADaM (Analysis Data Model) dataset produced for a study, including variable-level detail. Captures dataset name (e.g., ADSL, ADAE, ADTTE, ADLB), dataset class (ADSL, BDS, OCCDS, OTHER), purpose, key variables with derivation';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` (
    `adam_variable_spec_id` BIGINT COMMENT 'Unique surrogate identifier for each ADaM variable specification record within the Databricks Silver Layer. Primary key for this entity.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: ADaM variable-level specs require a named approver for regulatory submission accountability.',
    `lab_analyte_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_analyte. Business justification: ADaM variable specs for ADLB datasets map each variable to a source lab analyte (LOINC code, unit, CTCAE mapping). The source_variables plain-text field denormalizes this reference.',
    `primary_adam_dataset_spec_id` BIGINT COMMENT 'Reference to the parent ADaM dataset to which this variable specification belongs (e.g., ADSL, ADAE, ADLB). Links variable-level spec to its dataset container.',
    `sap_id` BIGINT COMMENT 'Reference to the Statistical Analysis Plan that governs the derivation rules and analytical intent for this variable specification.',
    `stratification_factor_id` BIGINT COMMENT 'Foreign key linking to randomization.stratification_factor. Business justification: ADaM ADSL stratification variables (STRAT1, STRAT2) must be derived from the randomization stratification factors.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this ADaM variable specification is defined. Scopes the variable spec to a specific protocol.',
    `adam_structure` STRING COMMENT 'CDISC ADaM structural classification of the parent dataset: ADSL (Subject-Level Analysis Dataset), BDS (Basic Data Structure — one record per subject per parameter per analysis timepoint), OCCDS (Occurrence Data Structure — for events like AEs and CMs). Valid values are `ADSL|BDS|OCCDS|OTHER`',
    `approval_date` DATE COMMENT 'Date on which the variable specification was formally approved by the responsible biostatistician or lead programmer. Marks the transition from draft to approved status in the specification lifecycle.',
    `baseline_flag` BOOLEAN COMMENT 'Name of the associated baseline flag variable (e.g., ABLFL) used to identify the baseline record for this analysis variable. Supports change-from-baseline derivations and is required for BDS datasets.',
    `change_from_baseline_var` STRING COMMENT 'Name of the corresponding change-from-baseline variable (CHG) or percent change-from-baseline variable (PCHG) derived from this analysis variable. Establishes the analytical linkage between AVAL and its change metrics.',
    `codelist_name` STRING COMMENT 'Name of the specific CDISC controlled terminology codelist associated with this variable (e.g., NY, DTYPE, PARAMCD, AVISIT). Used in DEFINE-XML generation and submission package validation.',
    `comments` STRING COMMENT 'Free-text field for additional notes, clarifications, or reviewer comments regarding the variable specification. May include sponsor-specific guidance, open questions, or cross-references to the source system',
    `controlled_terminology_ref` STRING COMMENT 'Reference to the applicable CDISC controlled terminology codelist, MedDRA dictionary, WHO-DD, or CTCAE version governing the permissible values for this variable. Example: CDISC CT DTYPE 2023-09-29, MedDRA v26.0 PT, CTCAE v5.0.',
    `core_designation` STRING COMMENT 'CDISC ADaM core classification indicating the mandatory status of the variable: Required (must be present), Expected (should be present unless not applicable), Permissible (optional, may be included), or Conditionally Required (required when specific. Valid values are `Required|Expected|Permissible|Conditionally Required`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this variable specification record was first created in the system. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `define_xml_display_format` STRING COMMENT 'Display format specification for this variable as it will appear in the DEFINE-XML submission metadata file (define.xml). Includes display format string and any associated decode mapping for coded values.',
    `derivation_algorithm` STRING COMMENT 'Detailed textual description of the derivation logic used to compute or assign the variables value. Includes source variable references, transformation rules, imputation methods (e.g., LOCF), and conditional logic.',
    `estimand_reference` STRING COMMENT 'Reference to the estimand that this variable supports or measures, linking the variable to the specific treatment effect and population-level summary defined in the estimand framework per ICH E9(R1).',
    `format_name` STRING COMMENT 'SAS format or informat name applied to this variable for display or input purposes (e.g., DATE9., DATETIME20., $CHAR200.). Used in SAS program generation and dataset creation.',
    `imputation_method` STRING COMMENT 'Description of the missing data imputation method applied to this variable as specified in the the source system. Examples: LOCF (Last Observation Carried Forward), BOCF (Baseline Observation Carried Forward), multiple imputation, worst-case, or none.',
    `is_analysis_variable` BOOLEAN COMMENT 'Indicates whether this variable is designated as a primary or secondary analysis variable (AVAL, AVALC, or equivalent) used directly in statistical analyses as defined in the the source system.',
    `is_key_variable` BOOLEAN COMMENT 'Indicates whether this variable is part of the datasets sort key (BY variables) as defined in the ADaM dataset specification. Key variables determine dataset sort order and are required for PROC SORT and merge operations in SAS.',
    `is_param_variable` BOOLEAN COMMENT 'Indicates whether this variable is a PARAM/PARAMCD/PARAMN grouping variable used in BDS (Basic Data Structure) or OCCDS datasets to identify the analysis parameter. Drives parameter-level filtering in TLF production.',
    `origin` STRING COMMENT 'CDISC-defined origin classification indicating how the variable value is obtained: Derived (computed from other variables), Assigned (set by sponsor/programmer per protocol), Collected (directly from eCRF/EDC), Protocol (defined in study protocol), or Not. Valid values are `Derived|Assigned|Collected|Protocol|Not Available`',
    `population_flag` BOOLEAN COMMENT 'Name of the analysis population flag variable this specification defines (e.g., ITTFL for Intent-to-Treat, SAFFL for Safety, PPROTFL for Per Protocol, FASFL for Full Analysis Set). Null if the variable is not a population flag.',
    `predecessor_variable` STRING COMMENT 'Name of the predecessor variable from which this variable is directly derived, as required in DEFINE-XML metadata. Establishes the data lineage chain from SDTM collected data through ADaM derived variables for regulatory traceability.',
    `qc_date` DATE COMMENT 'Date on which the independent QC programmer completed verification of this variables derivation. Recorded as part of the audit trail for regulatory submission readiness.',
    `qc_programmer` STRING COMMENT 'Name or identifier of the independent QC programmer responsible for verifying the derivation of this variable through independent programming. Required for dual-programming QC methodology compliance.',
    `qc_status` STRING COMMENT 'Current QC lifecycle status of this variable specification. Tracks progression from initial draft through independent QC programmer review to final approval. QC Passed indicates the derivation has been independently verified by a second programmer.. Valid values are `Draft|Under QC|QC Passed|QC Failed|Approved|Locked`',
    `sas_program_reference` STRING COMMENT 'Name or path of the SAS program in SAS Drug Development that implements the derivation for this variable. Enables direct linkage between the variable specification and its executable SAS code for QC and audit purposes.',
    `significant_digits` BIGINT COMMENT 'Number of significant digits to retain for numeric variables in analysis outputs and TLF displays. Defined in the the source system during SAS program generation to ensure consistent rounding across tables, listings, and figures.',
    `source_dataset` STRING COMMENT 'Primary SDTM or ADaM source dataset from which this variable is derived or mapped (e.g., AE, LB, VS, ADSL). Supports traceability from analysis results back to raw clinical data.',
    `source_variables` STRING COMMENT 'Comma-separated list of source variable names (from SDTM datasets or other ADaM datasets) used in the derivation of this variable. Supports data lineage tracing and ALCOA+ compliance. Example: SDTM.AE.AESTDTC, SDTM.DM.RFSTDTC.',
    `spec_status` STRING COMMENT 'Lifecycle status of this variable specification document. Draft indicates work in progress; In Review indicates under biostatistician or sponsor review; Approved indicates finalized and signed off; Superseded indicates replaced by a newer version; Retired. Valid values are `Draft|In Review|Approved|Superseded|Retired`',
    `spec_version` STRING COMMENT 'Version identifier for this variable specification record, following semantic versioning (e.g., v1.0, v1.1, v2.0). Incremented when derivation algorithm, source variables, or controlled terminology references are updated.. Valid values are `^vd+.d+$`',
    `therapeutic_area` STRING COMMENT 'Therapeutic area or disease indication for which this variable specification is designed (e.g., Oncology, Cardiology, Neurology). Relevant for CDISC Therapeutic Area User Guides (TAUGs) compliance and cross-study reuse.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this variable specification record. Required for change tracking and audit trail compliance under 21 CFR Part 11.',
    `variable_label` STRING COMMENT 'Human-readable SAS variable label (up to 40 characters) describing the variables business meaning. Used in SAS output headers, TLF footnotes, and reviewer documentation. Example: Analysis Value, Parameter Code.',
    `variable_length` BIGINT COMMENT 'SAS storage length for the variable. For Character variables, specifies maximum character width (e.g., 200). For Numeric variables, typically 8 (SAS default double-precision float). Used in SAS dataset creation and DEFINE-XML.',
    `variable_name` STRING COMMENT 'The SAS-compliant variable name as defined in the ADaM dataset specification. Must conform to CDISC ADaM naming conventions: uppercase, up to 8 characters, starting with a letter. Examples: USUBJID, AVAL, DTYPE, PARAMCD.. Valid values are `^[A-Z][A-Z0-9]{0,7}$`',
    `variable_order` BIGINT COMMENT 'Sequential position of this variable within the ADaM dataset column order as defined in the specification. Determines the column sequence in the SAS dataset and DEFINE-XML variable listing.',
    `variable_role` STRING COMMENT 'CDISC-defined role classification describing the variables functional purpose within the dataset structure. Drives DEFINE-XML metadata generation and reviewer interpretation.',
    `variable_type` STRING COMMENT 'SAS data type classification for the variable: Character (text/categorical values) or Numeric (continuous, date, or flag values). Drives SAS program generation and DEFINE-XML metadata.. Valid values are `Character|Numeric`',
    CONSTRAINT pk_adam_variable_spec PRIMARY KEY(`adam_variable_spec_id`)
) COMMENT 'Detailed variable-level specification within an ADaM dataset. Captures variable name, label, type (character/numeric), length, derivation algorithm, controlled terminology reference, CDISC ADaM core designation (Required/Expected/Permissible/Conditionally';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` (
    `tlf_shell_id` BIGINT COMMENT 'Unique surrogate identifier for each TLF shell specification record in the catalog. Primary key for the tlf_shell data product.',
    `adam_dataset_spec_id` BIGINT COMMENT 'Foreign key linking to biostatistics.adam_dataset_spec. Business justification: tlf_shell has adam_dataset_name (STRING) referencing the ADaM dataset that feeds the TLF shell.',
    `analysis_population_id` BIGINT COMMENT 'Foreign key linking to biostatistics.analysis_population. Business justification: tlf_shell has display_population (STRING) referencing the analysis population displayed in the TLF.',
    `arm_id` BIGINT COMMENT 'Foreign key linking to study.study_arm. Business justification: TLF shells are authored for specific treatment arms (e.g., Treatment A 100mg vs. Placebo). tlf_shell.treatment_arm is a denormalized text field.',
    `endpoint_id` BIGINT COMMENT 'Foreign key linking to study.study_endpoint. Business justification: TLF shells are authored for specific protocol endpoints (primary, secondary, exploratory).',
    `randomization_treatment_arm_id` BIGINT COMMENT 'Foreign key linking to randomization.treatment_arm. Business justification: TLF shells are produced by treatment arm — the treatment_arm plain text field is a denormalized reference to the treatment_arm entity.',
    `sap_id` BIGINT COMMENT 'Reference to the Statistical Analysis Plan version that governs this TLF output. Ensures traceability from output to the authorizing the source system',
    `shell_author_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: TLF shell authorship must be traceable to a named, qualified statistician/programmer for regulatory submission and inspection readiness.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this TLF shell is defined. Links the output specification to its parent study context.',
    `abbreviations` STRING COMMENT 'List of abbreviations and their definitions used within this TLF output (e.g., SD=Standard Deviation; CI=Confidence Interval; n=number of subjects). Required for regulatory submission readability per ICH E3.',
    `analysis_timepoint` STRING COMMENT 'Indicates whether this TLF output is produced for an interim analysis, the final analysis, or both. Governs blinding controls and DSMB/DMC reporting requirements in SAS Drug Development.. Valid values are `interim|final|both`',
    `analysis_visit` STRING COMMENT 'Study visit or visit window covered by this TLF output (e.g., Baseline, Week 12, End of Treatment, Follow-Up). Derived from the ADaM AVISIT variable and the source system definition.',
    `approved_by` STRING COMMENT 'Name or user identifier of the lead statistician or biostatistics manager who formally approved this TLF shell for programming. Required for regulatory audit trail and submission readiness.',
    `blinding_status` STRING COMMENT 'Indicates whether this TLF output is produced under blinded or unblinded conditions. Unblinded outputs are restricted to authorized personnel (e.g., DSMB/DMC, unblinded statistician) and require access controls per GCP and ICH E9.. Valid values are `blinded|unblinded|open_label`',
    `change_reason` STRING COMMENT 'Documented reason for the most recent revision to the TLF shell specification (e.g., the source system deviation, QC feedback, regulatory agency request). Required for audit trail integrity per ALCOA+ and 21 CFR Part 11.',
    `csr_section_reference` STRING COMMENT 'Section number within the Clinical Study Report (CSR) where this TLF output will be placed (e.g., Section 11.4.1, Appendix 16.1.1). Aligns with ICH E3 CSR structure for regulatory submission.',
    `ctcae_version` STRING COMMENT 'Version of the CTCAE grading scale applied in this TLF output for adverse event severity classification (e.g., CTCAE v5.0). Applicable to safety tables and listings presenting AE/SAE data.',
    `display_format` STRING COMMENT 'File format in which the TLF output is delivered (e.g., RTF for CSR word processing, PDF for regulatory submission, SAS7BDAT for data review). Drives output generation settings in SAS Drug Development.. Valid values are `rtf|pdf|sas7bdat|xlsx`',
    `footnotes` STRING COMMENT 'Footnote text to be displayed beneath the TLF output in the CSR and submission package. Captures abbreviation definitions, statistical notes, data source qualifications, and population clarifications as specified in the the source system.',
    `is_primary_endpoint` BOOLEAN COMMENT 'Indicates whether this TLF output presents results for a primary efficacy or safety endpoint as defined in the study protocol and the source system. Primary endpoint outputs receive highest priority and regulatory scrutiny.',
    `is_regulatory_submission` BOOLEAN COMMENT 'Indicates whether this TLF output is included in the regulatory submission package (NDA/BLA/MAA/eCTD). Submission outputs require additional QC validation and compliance with FDA/EMA/PMDA formatting standards.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the TLF shell specification record. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ contemporaneous documentation principles.',
    `locf_flag` BOOLEAN COMMENT 'Indicates whether the Last Observation Carried Forward (LOCF) imputation method is applied in this TLF output for handling missing data. Specified in the the source system handling section.',
    `meddra_soc` STRING COMMENT 'MedDRA System Organ Class (SOC) associated with this TLF output when the output presents safety or adverse event data. Enables standardized safety reporting alignment with MedDRA coding hierarchy.',
    `orientation` STRING COMMENT 'Page orientation for the TLF output display (portrait or landscape). Determined by the number of columns and display width requirements; specified in the TLF shell for SAS programmer implementation.. Valid values are `portrait|landscape`',
    `output_category` STRING COMMENT 'Functional grouping of the TLF output within the study (e.g., Demographics, Efficacy, Safety, Pharmacokinetics, Laboratory). Used to organize the TLF catalog and assign programming resources.',
    `output_file_name` STRING COMMENT 'Expected file name of the produced TLF output artifact (e.g., t_14_1_demog.rtf, f_05_1_km.pdf). Used for output delivery tracking and eCTD submission package assembly.',
    `output_finalized_date` DATE COMMENT 'Date on which the TLF output was finalized and locked for inclusion in the CSR or regulatory submission. Aligns with the Database Lock (DBL) milestone and submission timeline.',
    `output_number` STRING COMMENT 'Externally-known alphanumeric identifier for the TLF output (e.g., T-14.1, L-02.3, F-05.1). Used by SAS programmers and medical writers to reference outputs in the CSR and submission packages.. Valid values are `^[A-Z]{1,3}-[0-9]{1,3}(.[0-9]{1,3})?$`',
    `output_title` STRING COMMENT 'Full descriptive title of the table, listing, or figure as it will appear in the Clinical Study Report (CSR) and regulatory submission. Authored per ICH E3 display conventions.',
    `output_type` STRING COMMENT 'Classifies the output as a Table, Listing, or Figure (TLF). Drives program template selection, display formatting rules, and CSR section placement in SAS Drug Development.. Valid values are `table|listing|figure`',
    `page_size` STRING COMMENT 'Paper size specification for the TLF output (A4 for EMA/MHRA/TGA submissions; Letter for FDA submissions). Ensures regulatory submission formatting compliance across jurisdictions.. Valid values are `A4|letter|legal`',
    `priority_tier` STRING COMMENT 'Programming priority classification for this TLF output (Tier 1=primary efficacy/safety outputs required for DBL; Tier 2=secondary outputs; Tier 3=supportive/exploratory outputs). Drives resource allocation and delivery scheduling.. Valid values are `tier_1|tier_2|tier_3`',
    `production_status` STRING COMMENT 'Current lifecycle state of the TLF shell and its associated program in the production workflow. Tracks progression from initial shell authoring through QC review to final approved output for CSR inclusion.. Valid values are `draft|in_development|qc_review|approved|final|superseded`',
    `program_delivery_date` DATE COMMENT 'Planned or actual date by which the SAS program producing this TLF output is scheduled to be delivered for QC review. Used for project milestone tracking and CSR timeline management.',
    `program_name` STRING COMMENT 'Name of the SAS program file responsible for producing this TLF output (e.g., t_14_1_demog.sas). Used as the SSOT for program-to-output traceability in SAS Drug Development and the TLF catalog.',
    `program_path` STRING COMMENT 'Full directory path to the SAS program file within the study programming environment (e.g., /studies/STUDY001/programs/tables/). Enables automated program execution and audit trail in SAS Drug Development.',
    `qc_reviewer` STRING COMMENT 'Name or user identifier of the independent QC reviewer who validated the TLF shell specification and/or the produced output. Supports double-programming QC traceability per CDISC and GCP standards.',
    `sap_section_reference` STRING COMMENT 'Section number or identifier within the the source system the statistical methodology for this TLF output (e.g., Section 5.3.2). Provides direct traceability from the output shell to the governing statistical specification.',
    `shell_approved_date` DATE COMMENT 'Date on which the TLF shell specification was formally approved for programming. Marks the transition from specification to active development in the TLF production lifecycle.',
    `shell_created_date` DATE COMMENT 'Date on which the TLF shell specification was first created in the system. Establishes the start of the output lifecycle for audit and project tracking purposes.',
    `shell_notes` STRING COMMENT 'Free-text notes and instructions from the biostatistician to the SAS programmer regarding special handling, display requirements, or clarifications for this TLF output. Not displayed in the final output.',
    `shell_version` STRING COMMENT 'Version identifier of the TLF shell specification (e.g., v1.0, v2.1). Tracks revisions to the shell driven by the source system changes, or QC feedback. Enables version-controlled traceability.. Valid values are `^v[0-9]+.[0-9]+$`',
    `statistical_method` STRING COMMENT 'The statistical method or test to be applied in the analysis (e.g., ANCOVA, logistic regression, Kaplan-Meier, Cox proportional hazards), specifying the analytical technique used to generate the output.',
    CONSTRAINT pk_tlf_shell PRIMARY KEY(`tlf_shell_id`)
) COMMENT 'Table, Listing, and Figure (TLF) shell specification for a study. Captures output number, title, footnotes, display population, statistical method reference, program name, output type (table/listing/figure), the source system priority tier, and';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` (
    `tlf_output_id` BIGINT COMMENT 'Unique system-generated identifier for each produced TLF output instance. Serves as the primary key for the tlf_output data product within the biostatistics domain.',
    `adam_dataset_spec_id` BIGINT COMMENT 'Reference to the specific ADaM dataset version used as input for generating this TLF output, ensuring full traceability from output back to source analysis data.',
    `analysis_population_id` BIGINT COMMENT 'Foreign key linking to biostatistics.analysis_population. Business justification: tlf_output has analysis_population (STRING) indicating which population the output covers.',
    `approver_employee_id` BIGINT COMMENT 'Reference to the biostatistician or statistical lead who formally approved this TLF output for inclusion in the CSR or regulatory submission package.',
    `deliverable_id` BIGINT COMMENT 'Foreign key linking to agreement.deliverable. Business justification: TLF outputs (tables, listings, figures) are formal contractual deliverables with acceptance criteria and billing milestone triggers.',
    `interim_analysis_id` BIGINT COMMENT 'Foreign key linking to biostatistics.interim_analysis. Business justification: TLF outputs can be produced specifically for interim analyses (interim_analysis_flag exists on tlf_output).',
    `primary_tlf_employee_id` BIGINT COMMENT 'Reference to the statistical programmer responsible for authoring the SAS program that produced this TLF output.',
    `sap_id` BIGINT COMMENT 'Reference to the Statistical Analysis Plan (the source system) version that governs the analysis methodology, population definitions, and output specifications for this TLF.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this TLF output was produced. Links the output to the governing study protocol and sponsor context.',
    `submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission. Business justification: Finalized TLF outputs (tables, listings, figures) are included in CTD Module 5 of NDA/BLA/MAA submissions. The tlf_output has submission_package_ref (plain text denormalization).',
    `tlf_shell_id` BIGINT COMMENT 'Reference to the TLF shell specification that defines the structure, layout, and metadata template from which this output was produced.',
    `analysis_type` STRING COMMENT 'Classification of the analysis type this TLF output supports: primary (confirmatory), secondary, exploratory, interim (pre-specified), or sensitivity analysis. Determines the regulatory weight and reporting requirements for the output.. Valid values are `primary|secondary|exploratory|interim|sensitivity`',
    `approval_status` STRING COMMENT 'Final approval lifecycle status of this TLF output. Approved outputs are eligible for inclusion in the Clinical Study Report (CSR) and regulatory submissions. Superseded outputs have been replaced by a newer version.. Valid values are `draft|under_review|approved|rejected|superseded`',
    `approval_timestamp` TIMESTAMP COMMENT 'Date and time when the TLF output received formal approval, captured as an electronic signature event per 21 CFR Part 11 requirements. Null if not yet approved.',
    `blinding_status` STRING COMMENT 'Indicates whether this TLF output was produced from blinded or unblinded data. Unblinded outputs are restricted to authorized personnel only and are subject to strict access controls to preserve trial integrity prior to database lock.. Valid values are `blinded|unblinded`',
    `comments` STRING COMMENT 'Free-text field for capturing additional context, production notes, known limitations, or reviewer comments associated with this TLF output instance. Supports communication between programmers, biostatisticians, and medical writers.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this TLF output record was first created in the system, capturing the initial registration of the production run. Supports audit trail requirements per 21 CFR Part 11 and ALCOA+ principles.',
    `csr_section_reference` STRING COMMENT 'Reference to the specific section of the Clinical Study Report (CSR) where this TLF output is cited or embedded (e.g., Section 11.4.1, Appendix 16.1.9). Supports CSR authoring traceability per ICH E3 structure.',
    `dataset_lock_status` STRING COMMENT 'Indicates whether this TLF output was produced from a pre-database lock (DBL), post-database lock, or interim analysis dataset. Critical for distinguishing final regulatory submission outputs from exploratory or interim analyses.. Valid values are `pre_lock|post_lock|interim`',
    `dataset_version` STRING COMMENT 'Version label of the ADaM dataset used as input for this TLF production run (e.g., v1.0, v2.3-interim). Ensures traceability between the output and the exact data snapshot used, critical for database lock (DBL) compliance.',
    `delivery_date` DATE COMMENT 'Date on which this TLF output was formally delivered to the sponsor, regulatory team, or CSR authoring team. Used for milestone tracking and contractual deliverable compliance.',
    `discrepancy_count` BIGINT COMMENT 'Total number of discrepancies identified between the primary programmer output and the QC programmer output during validation. A count of zero indicates a clean validation pass. Non-zero counts require resolution before final approval.',
    `discrepancy_resolution_notes` STRING COMMENT 'Narrative description of how identified discrepancies between primary and QC programmer outputs were investigated and resolved. Required when discrepancy_count is greater than zero to support audit trail and regulatory inspection readiness.',
    `is_final_version` BOOLEAN COMMENT 'Indicates whether this TLF output instance is the final approved version intended for inclusion in the Clinical Study Report (CSR) or regulatory submission. Only one version per output_number should have this flag set to True.',
    `output_category` STRING COMMENT 'Functional category of the TLF output indicating the statistical domain it covers (e.g., demographics, efficacy, safety, pharmacokinetics, laboratory). Used for organizing outputs within the CSR and regulatory submission.',
    `output_file_format` STRING COMMENT 'File format of the produced TLF output (e.g., RTF for Word-compatible tables, PDF for final regulatory submissions, SAS7BDAT for dataset outputs). Determines compatibility with CSR authoring tools and eCTD submission requirements.. Valid values are `RTF|PDF|SAS7BDAT|CSV|HTML|XLSX`',
    `output_file_name` STRING COMMENT 'Name of the output file generated by the SAS program (e.g., t_14_1_1_demog.rtf, l_16_2_3_ae.pdf). Used for file management, eTMF archival, and regulatory submission packaging.',
    `output_file_path` STRING COMMENT 'Full repository or file system path to the stored TLF output file in SAS Drug Development or the eTMF system. Enables direct retrieval for CSR authoring, regulatory review, and inspection readiness.',
    `output_number` STRING COMMENT 'Externally-known alphanumeric identifier for this TLF output as defined in the the source system shell specification (e.g., T-14.1.1, L-16.2.3, F-11.4). Used for cross-referencing in the Clinical Study Report (CSR).. Valid values are `^[A-Z]{1,3}-[0-9]{1,4}(.[0-9]{1,3})?$`',
    `output_title` STRING COMMENT 'Full descriptive title of the TLF output as it appears in the header of the produced document (e.g., Summary of Adverse Events by System Organ Class and Preferred Term — Safety Population). Used for CSR cross-referencing and regulatory submission.',
    `output_type` STRING COMMENT 'Classification of the statistical output as a Table (T), Listing (L), or Figure (F), corresponding to the three standard output categories in clinical trial reporting per ICH E3 and CDISC conventions.. Valid values are `table|listing|figure`',
    `output_version` STRING COMMENT 'Version label of this TLF output instance (e.g., v1.0, v2.1, vFinal). Tracks the production history of the output across multiple runs, enabling identification of the current approved version versus superseded drafts.',
    `production_environment` STRING COMMENT 'Environment in which this TLF output was generated: development (exploratory/testing), validation (UAT), or production (regulatory-grade). Only production-environment outputs are eligible for regulatory submission.. Valid values are `development|validation|production`',
    `production_run_timestamp` TIMESTAMP COMMENT 'Date and time when the SAS program was executed to produce this TLF output instance. Serves as the principal business event timestamp for the production lifecycle, supporting ALCOA+ contemporaneous documentation requirements.',
    `qc_completion_timestamp` TIMESTAMP COMMENT 'Date and time when the QC validation process for this TLF output was completed and the qc_status was set to a terminal state (passed, failed, or waived). Supports milestone tracking and SLA compliance.',
    `qc_status` STRING COMMENT 'Current QC validation status of this TLF output. Indicates whether the output has passed independent validation, is pending review, is under active review, has failed validation, or has been formally waived per documented justification.. Valid values are `pending|in_progress|passed|failed|waived`',
    `run_number` BIGINT COMMENT 'Sequential run number for this TLF output, incremented each time the SAS program is executed for the same output_number. Enables tracking of the full production history from first run to final delivery.',
    `sas_program_name` STRING COMMENT 'Name of the SAS program file used to produce this TLF output in SAS Drug Development (e.g., t_14_1_1_demog.sas). Provides full program traceability for audit and replication purposes.',
    `sas_program_path` STRING COMMENT 'Full file system or repository path to the SAS program in SAS Drug Development used to produce this TLF output. Supports traceability and regulatory inspection readiness.',
    `sas_program_version` STRING COMMENT 'Version identifier of the SAS program used to generate this output, as tracked in SAS Drug Development version control. Enables exact reproduction of results and supports regulatory audit trails.',
    `unblinding_authorization_ref` STRING COMMENT 'Reference number or document identifier for the formal unblinding authorization (e.g., DSMB/DMC recommendation, sponsor authorization memo) that permitted production of this unblinded TLF output.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this TLF output record was last modified, tracking any updates to status, QC results, approval, or metadata. Required for audit trail completeness per 21 CFR Part 11.',
    `validation_method` STRING COMMENT 'Method used to validate the accuracy of this TLF output. Double programming involves an independent programmer replicating the output from scratch; peer review involves a qualified reviewer checking the program and output without independent replication.. Valid values are `double_programming|peer_review|independent_review`',
    CONSTRAINT pk_tlf_output PRIMARY KEY(`tlf_output_id`)
) COMMENT 'Produced TLF output instance generated from a TLF shell specification. Captures output file reference, production run date, SAS program name and version, dataset version used, programmer, QC programmer, validation method (double programming, peer review)';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` (
    `interim_analysis_id` BIGINT COMMENT 'Unique surrogate identifier for each interim analysis record within the clinical trial biostatistics domain.',
    `analysis_population_id` BIGINT COMMENT 'Foreign key linking to biostatistics.analysis_population. Business justification: interim_analysis has analysis_population (STRING) indicating which population was analyzed at the interim.',
    `audit_id` BIGINT COMMENT 'Foreign key linking to compliance.audit. Business justification: GCP audits specifically review interim analysis conduct — firewall integrity, unblinding authorization, alpha spending adherence.',
    `blinding_config_id` BIGINT COMMENT 'Foreign key linking to randomization.blinding_config. Business justification: Interim analyses must operate under a defined blinding configuration governing firewall maintenance, unblinding scope, and independent statistician access.',
    `database_lock_event_id` BIGINT COMMENT 'Foreign key linking to biostatistics.database_lock_event. Business justification: An interim analysis is performed on data that has been locked via a database lock event.',
    `epoch_id` BIGINT COMMENT 'Foreign key linking to study.study_epoch. Business justification: Interim analyses are planned at epoch boundaries (end of treatment epoch, end of follow-up).',
    `pipeline_asset_id` BIGINT COMMENT 'Foreign key linking to sponsor.pipeline_asset. Business justification: Interim analysis outcomes (stopping_rule_triggered, analysis_outcome, conditional_power) directly drive go/no-go decisions for the pipeline assets phase progression.',
    `rand_list_id` BIGINT COMMENT 'Foreign key linking to randomization.rand_list. Business justification: Interim analyses are conducted on subjects randomized under a specific rand_list version active at the data cutoff date.',
    `regulatory_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to regulatory.protocol_amendment. Business justification: Adaptive trial interim analyses (sample size re-estimation, population enrichment) directly trigger protocol amendments submitted to health authorities.',
    `sap_id` BIGINT COMMENT 'Reference to the Statistical Analysis Plan (the source system) version that governs the methodology and pre-specified rules for this interim analysis.',
    `sdtm_dataset_id` BIGINT COMMENT 'Foreign key linking to datamanagement.sdtm_dataset. Business justification: Each interim analysis uses a specific locked SDTM dataset version at the data cutoff date.',
    `study_id` BIGINT COMMENT 'Reference to the parent clinical study for which this interim analysis is conducted.',
    `study_protocol_milestone_id` BIGINT COMMENT 'Foreign key linking to study.study_milestone. Business justification: Interim analyses are tracked as critical-path milestones in CTMS. Linking interim_analysis to study_milestone enables integrated timeline management, contractual milestone reporting to',
    `submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission. Business justification: Interim efficacy/safety data from adaptive trials may be submitted to health authorities.',
    `actual_analysis_date` DATE COMMENT 'The actual calendar date on which the interim analysis was executed and results were produced. May differ from planned date due to enrollment pace or operational factors.',
    `adam_dataset_version` STRING COMMENT 'Version identifier of the CDISC ADaM datasets used as input to this interim analysis, ensuring traceability between the analysis results and the underlying data snapshot.',
    `adaptation_description` STRING COMMENT 'Description of any adaptive design features or modifications implemented at this interim analysis, such as sample size re-estimation, treatment arm selection, or enrichment strategies.',
    `alpha_allocated` DECIMAL(8,6) COMMENT 'The portion of the overall one-sided or two-sided alpha (Type I error rate) allocated to this specific interim look by the alpha spending function. Used to derive the efficacy stopping boundary.',
    `alpha_spending_function` STRING COMMENT 'The pre-specified alpha spending function used to allocate the overall Type I error rate across interim looks, as defined in the the source system. Common functions include OBrien-Fleming, Pocock, Lan-DeMets OBrien-Fleming approximation, Lan-DeMets. Valid values are `obrien_fleming|pocock|lan_demets_obf|lan_demets_pocock|hwang_shih_decani|custom`',
    `alpha_spending_parameter` DECIMAL(8,6) COMMENT 'Numeric parameter (gamma) for the selected alpha spending function, where applicable (e.g., the gamma parameter for Hwang-Shih-DeCani function). Null for functions that do not require a parameter.',
    `analysis_code` STRING COMMENT 'Externally-known alphanumeric business identifier for this interim analysis, used in regulatory submissions, DSMB/DMC charters, and TMF documentation (e.g., IA-STUDY001-001).. Valid values are `^IA-[A-Z0-9]{2,10}-[0-9]{3}$`',
    `analysis_number` BIGINT COMMENT 'Sequential ordinal number identifying this interim analysis within the study (e.g., 1 for first interim, 2 for second interim). Used to track the series of planned looks at accumulating data.',
    `analysis_outcome` STRING COMMENT 'The formal decision or recommendation resulting from the interim analysis: continue (study proceeds as planned), stop_efficacy (early termination for demonstrated benefit), stop_futility (early termination for lack of benefit), stop_safety (early. Valid values are `continue|stop_efficacy|stop_futility|stop_safety|adapt|pending`',
    `analysis_status` STRING COMMENT 'Current lifecycle state of the interim analysis: planned (scheduled but not yet initiated), in_progress (analysis underway), completed (results finalized), cancelled (analysis removed from plan), or on_hold (temporarily suspended).. Valid values are `planned|in_progress|completed|cancelled|on_hold`',
    `analysis_type` STRING COMMENT 'Classification of the interim analysis by its primary statistical purpose: efficacy (test for early stopping due to benefit), futility (test for early stopping due to lack of benefit), safety (review of accumulating safety data), adaptive (pre-specified. Valid values are `efficacy|futility|safety|adaptive|combined_efficacy_futility|administrative`',
    `conditional_power` DECIMAL(5,4) COMMENT 'Probability of achieving a statistically significant result at the final analysis, conditional on the data observed at this interim look and assuming the originally hypothesized treatment effect. Used in futility assessments.',
    `confidentiality_level` STRING COMMENT 'Data classification level assigned to the interim analysis results and associated outputs, controlling access and distribution. Interim analysis results are typically restricted to prevent unblinding of the broader study team.. Valid values are `restricted|confidential|internal|public`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this interim analysis record was first created in the system, supporting audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `data_cutoff_date` DATE COMMENT 'The date through which subject data was included in the interim analysis dataset. All data collected after this date is excluded from the analysis. Critical for regulatory traceability and blinding integrity.',
    `dsmb_involved` BOOLEAN COMMENT 'Indicates whether a Data Safety Monitoring Board (DSMB) or Data Monitoring Committee (DMC) reviewed the unblinded interim analysis results (True = DSMB/DMC reviewed; False = internal review only).',
    `dsmb_meeting_date` DATE COMMENT 'Date on which the Data Safety Monitoring Board (DSMB) or Data Monitoring Committee (DMC) convened to review the interim analysis results and issue a recommendation.',
    `efficacy_boundary_value` DECIMAL(10,6) COMMENT 'Pre-specified critical value (e.g., z-statistic or p-value threshold) for the efficacy stopping boundary at this interim look. If the observed test statistic exceeds this boundary, early stopping for efficacy is triggered.',
    `events_observed` BIGINT COMMENT 'Number of primary endpoint events (e.g., deaths, disease progression events) observed as of the data cutoff date. Applicable for event-driven trials; used to compute the actual information fraction.',
    `events_planned_total` BIGINT COMMENT 'Total number of primary endpoint events required for the final analysis as specified in the the source system size calculation. Used as the denominator for the information fraction in event-driven trials.',
    `firewall_maintained` BOOLEAN COMMENT 'Indicates whether a blinding firewall was maintained between the unblinded interim analysis team and the blinded study team (True = firewall in place; False = firewall not maintained or not applicable).',
    `futility_boundary_binding` BOOLEAN COMMENT 'Indicates whether the futility stopping boundary is binding (True = mandatory stop if crossed; False = non-binding/advisory only). Binding futility boundaries affect the overall Type I error calculation.',
    `futility_boundary_value` DECIMAL(10,6) COMMENT 'Pre-specified critical value for the futility stopping boundary at this interim look. If the observed test statistic falls below this boundary, early stopping for futility (lack of efficacy) may be triggered.',
    `information_fraction_actual` DECIMAL(5,4) COMMENT 'Observed proportion of total planned statistical information actually accumulated at the time of this interim analysis. May differ from planned fraction due to enrollment variability or event rate changes.',
    `information_fraction_planned` DECIMAL(5,4) COMMENT 'Pre-specified proportion of the total planned statistical information (e.g., events, subjects) accumulated at the time of this interim analysis, expressed as a decimal between 0 and 1 (e.g., 0.5000 = 50% of planned events).',
    `notes` STRING COMMENT 'Free-text field for capturing additional context, operational notes, deviations from the pre-specified plan, or DSMB/DMC commentary relevant to this interim analysis that is not captured in structured fields.',
    `observed_p_value` DECIMAL(10,8) COMMENT 'The nominal p-value from the primary hypothesis test at this interim analysis. Must be interpreted in the context of the alpha spending boundary, not as a standalone significance threshold.',
    `observed_test_statistic` DECIMAL(10,6) COMMENT 'The actual computed test statistic (e.g., z-score, chi-square, log-rank statistic) from the interim analysis dataset. Compared against efficacy and futility boundaries to determine the outcome.',
    `planned_analysis_date` DATE COMMENT 'Pre-specified calendar date on which the interim analysis is planned to be conducted, as documented in the the source system charter.',
    `regulatory_submission_required` BOOLEAN COMMENT 'Indicates whether the interim analysis results or the resulting design adaptation must be submitted to a regulatory authority (FDA, EMA, PMDA, etc.) as part of an IND, NDA, BLA, or MAA amendment (True = submission required; False = not required).',
    `results_disclosed_externally` BOOLEAN COMMENT 'Indicates whether the interim analysis results have been disclosed externally (e.g., to regulators, in a public registry, or in a publication) prior to study completion (True = disclosed; False = not disclosed).',
    `revised_sample_size` BIGINT COMMENT 'Updated total sample size determined through the pre-specified sample size re-estimation procedure at this interim analysis. Null if sample_size_reestimated is False.',
    `sample_size_reestimated` BOOLEAN COMMENT 'Indicates whether a pre-specified sample size re-estimation was performed as part of this interim analysis (True = sample size re-estimated; False = no re-estimation performed).',
    `sas_program_version` STRING COMMENT 'Version identifier of the SAS Drug Development program or analysis package used to execute this interim analysis, enabling reproducibility and audit traceability.',
    `stopping_rule_description` STRING COMMENT 'Narrative description of the specific stopping rule(s) triggered at this interim analysis, including the criterion crossed and the observed vs. boundary values. Populated only when stopping_rule_triggered is True.',
    `stopping_rule_triggered` BOOLEAN COMMENT 'Indicates whether any pre-specified stopping rule (efficacy, futility, or safety) was triggered by the results of this interim analysis (True = stopping rule crossed; False = no stopping rule triggered).',
    `subjects_enrolled_at_cutoff` BIGINT COMMENT 'Total number of subjects enrolled in the study as of the data cutoff date for this interim analysis. Provides context for the information fraction and statistical power.',
    `unblinding_authorization_date` DATE COMMENT 'Date on which formal authorization was granted to unblind the interim analysis data, as documented in the unblinding log. Required for audit trail and blinding integrity compliance.',
    `unblinding_scope` STRING COMMENT 'Defines the extent of treatment assignment unblinding performed for this interim analysis: full (all treatment assignments revealed to the analysis team), partial (only aggregate or summary-level unblinding), or none (blinded analysis only).. Valid values are `full|partial|none`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this interim analysis record was most recently modified, supporting audit trail requirements and data lineage tracking in the Databricks Silver Layer.',
    CONSTRAINT pk_interim_analysis PRIMARY KEY(`interim_analysis_id`)
) COMMENT 'Records planned and executed interim analyses for a study. Captures interim analysis number, type (efficacy, futility, safety, adaptive), planned information fraction, actual analysis date, DSMB/DMC involvement flag, unblinding scope (full/partial/none)';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` (
    `database_lock_event_id` BIGINT COMMENT 'Primary key for database_lock_event',
    `dmp_id` BIGINT COMMENT 'add column dmp_id (BIGINT) with FK to datamanagement.dmp.dmp_id — database lock event should reference the data management plan that governs the lock process',
    `primary_database_employee_id` BIGINT COMMENT 'Reference to the Data Management representative who authorized the database lock. One of the three required lock authorization approvers per GCP and the DMP. Approval is captured with electronic signature per 21 CFR Part 11.',
    `rand_list_id` BIGINT COMMENT 'Foreign key linking to randomization.rand_list. Business justification: Pre-lock QC checklists require reconciliation of all randomized subjects in the locked dataset against the active rand_list version.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this database lock event applies. Links the DBL event to the parent study master record.',
    `study_protocol_milestone_id` BIGINT COMMENT 'Foreign key linking to study.study_milestone. Business justification: Database lock is a named critical-path milestone tracked in CTMS. Linking the biostatistics DBL event to the CTMS study_milestone enables timeline variance reporting, contractual',
    `tertiary_database_medical_monitor_approver_employee_id` BIGINT COMMENT 'Reference to the Medical Monitor who authorized the database lock. Confirms clinical data completeness and medical review is satisfactory prior to lock.',
    `actual_lock_date` DATE COMMENT 'The calendar date on which the database was formally locked. This is the principal business event date for the DBL milestone and is recorded in the eTMF, regulatory submissions, and CSR statistical sections.',
    `amendment_number` BIGINT COMMENT 'Sequential amendment number for post-lock data corrections. Zero for the original lock; increments with each formal unlock and re-lock cycle. Tracks the amendment history of the locked database.',
    `amendment_reason` STRING COMMENT 'Formal description of the reason for unlocking and re-locking the database after the initial lock. Documents the nature of the data correction or update requiring the amendment. Null for the original lock (amendment_number = 0).',
    `analysis_type` STRING COMMENT 'The type of statistical analysis for which this database lock is being performed. Determines the downstream workflow: interim analyses feed DSMB/DMC reviews; final analyses feed CSR and regulatory submissions (NDA/BLA/MAA).. Valid values are `interim_analysis|final_analysis|safety_review|ad_hoc|regulatory_submission`',
    `biostatistics_approval_timestamp` TIMESTAMP COMMENT 'Date and time at which the Biostatistics representative provided electronic authorization for the database lock. Required for 21 CFR Part 11 audit trail.',
    `coding_complete` BOOLEAN COMMENT 'Indicates whether all medical coding assignments (MedDRA for adverse events/medical history, WHO-DD for concomitant medications) have been completed and verified in the EDC system prior to database lock.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time at which this database lock event record was first created in the lakehouse (Silver Layer). Supports audit trail and data lineage requirements per 21 CFR Part 11 and ALCOA+ standards.',
    `data_cut_date` DATE COMMENT 'The clinical data cut-off date defining which subject data and observations are included in this lock. All data with a collection date on or before this date is included in the locked dataset. Critical for interim and partial locks.',
    `dbl_event_number` STRING COMMENT 'Externally-known, human-readable unique identifier for this database lock event (e.g., DBL-2024-001). Used in regulatory submissions, TMF filings, and cross-system references in Medidata Rave and the source system',
    `dm_approval_timestamp` TIMESTAMP COMMENT 'Date and time at which the Data Management representative provided electronic authorization for the database lock. Required for 21 CFR Part 11 audit trail.',
    `dmp_version` STRING COMMENT 'Version identifier of the Data Management Plan (DMP) that governed the data collection and cleaning activities for this database lock event.',
    `dsmb_notification_date` DATE COMMENT 'The date on which the DSMB/DMC was formally notified of the database lock and provided access to the locked dataset for their review.',
    `dsmb_notification_required` BOOLEAN COMMENT 'Indicates whether the Data Safety Monitoring Board (DSMB) or Data Monitoring Committee (DMC) must be notified of this database lock event, typically for interim analysis locks where the DSMB reviews unblinded data.',
    `edc_system_lock_reference` STRING COMMENT 'The lock event reference number or identifier generated by the EDC system (Medidata Rave) at the time of lock execution. Used for cross-system traceability between the lakehouse and the source EDC system.',
    `lock_memo_reference` STRING COMMENT 'Document reference number for the formal database lock memo filed in the eTMF (Veeva Vault). The lock memo documents the lock rationale, approvals, outstanding items, and any deviations from the DMP.',
    `lock_scope` STRING COMMENT 'Defines the scope of data included in this lock event. Full study locks the entire study database; interim locks a defined data cut for interim analysis; partial locks a subset of data (e.g., specific sites or forms); cohort locks a defined patient. Valid values are `full_study|interim|partial|cohort|site_specific`',
    `lock_status` STRING COMMENT 'Current lifecycle status of the database lock event. Tracks progression from planning through execution and any subsequent unlock/re-lock cycles required for data corrections or amendments.. Valid values are `planned|in_progress|locked|unlocked|re_locked|cancelled`',
    `lock_timestamp` TIMESTAMP COMMENT 'Precise date and time (with timezone) at which the database lock was executed in the EDC system (Medidata Rave). Required for 21 CFR Part 11 audit trail compliance and ALCOA+ data integrity standards.',
    `lock_type` STRING COMMENT 'Indicates whether the lock is a hard lock (no further data changes permitted without formal unlock and re-lock procedure) or a soft lock (data is locked for analysis but minor corrections may still be applied under controlled conditions).. Valid values are `hard|soft`',
    `medical_monitor_approval_timestamp` TIMESTAMP COMMENT 'Date and time at which the Medical Monitor provided electronic authorization for the database lock. Required for 21 CFR Part 11 audit trail.',
    `notes` STRING COMMENT 'Free-text field for additional context, observations, or operational notes related to this database lock event that are not captured in structured fields. Includes deviations from planned timelines or special circumstances.',
    `outstanding_query_count` BIGINT COMMENT 'Number of open data queries (discrepancies) remaining unresolved in the EDC system (Medidata Rave) at the time of database lock. A non-zero count must be formally justified and documented per GCP and ALCOA+ requirements.',
    `outstanding_query_justification` STRING COMMENT 'Formal written justification for proceeding with database lock when outstanding queries remain unresolved. Required by GCP and ALCOA+ when outstanding_query_count is greater than zero. Documented in the DMP and lock memo.',
    `planned_lock_date` DATE COMMENT 'The originally scheduled calendar date for the database lock event as defined in the Data Management Plan (DMP) and study timeline. Used for milestone tracking in the source system and project planning.',
    `pre_lock_qc_checklist_complete` BOOLEAN COMMENT 'Indicates whether all items on the pre-database lock Quality Control (QC) checklist have been completed and signed off prior to lock execution. The checklist covers data cleaning, query resolution, coding completion, and SAE reconciliation.',
    `pre_lock_qc_completion_date` DATE COMMENT 'The date on which the pre-database lock QC checklist was formally completed and all items signed off. Must precede the actual lock date.',
    `sae_reconciliation_complete` BOOLEAN COMMENT 'Indicates whether the reconciliation between the EDC system (Medidata Rave) and the safety database (the source system for Serious Adverse Events (SAEs) has been completed and confirmed prior to database lock.',
    `sdv_complete` BOOLEAN COMMENT 'Indicates whether Source Data Verification (SDV) has been completed to the required percentage or scope across all sites prior to database lock. SDV confirms EDC data matches source documents per GCP requirements.',
    `sites_locked_count` BIGINT COMMENT 'Total number of investigative sites whose data is included in this database lock event. Relevant for partial and site-specific lock scopes.',
    `study_part` STRING COMMENT 'Identifies the specific study part, period, or epoch covered by this lock event (e.g., Part A, Part B, Period 1, Run-in, Treatment, Follow-up). Applicable for multi-part or adaptive study designs.',
    `subjects_locked_count` BIGINT COMMENT 'Total number of study subjects whose data is included in this database lock event. Used for completeness verification and comparison against enrollment targets defined in the the source system.',
    `unblinding_date` DATE COMMENT 'The date on which treatment assignment unblinding was performed following the database lock. Null if unblinding_required is false or unblinding has not yet occurred.',
    `unblinding_required` BOOLEAN COMMENT 'Indicates whether treatment unblinding is required as part of or immediately following this database lock event. Applicable for blinded studies where the lock precedes the formal unblinding procedure for final or interim analysis.',
    `unlock_timestamp` TIMESTAMP COMMENT 'Date and time at which the database was formally unlocked to permit post-lock data corrections. Null if the database has not been unlocked. Required for 21 CFR Part 11 audit trail.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time at which this database lock event record was last modified in the lakehouse (Silver Layer). Tracks record-level changes for audit trail and data lineage compliance.',
    CONSTRAINT pk_database_lock_event PRIMARY KEY(`database_lock_event_id`)
) COMMENT 'Database Lock (DBL) event record for a study or study part. Captures lock scope (full study, interim, partial), planned and actual lock date, pre-lock QC checklist completion status, outstanding query count at lock, lock authorization approvers (DM';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` (
    `statistical_endpoint_id` BIGINT COMMENT 'Unique surrogate identifier for each statistical endpoint record defined in the Statistical Analysis Plan (the source system). Primary key for the statistical_endpoint data product.',
    `adam_dataset_spec_id` BIGINT COMMENT 'Foreign key linking to biostatistics.adam_dataset_spec. Business justification: statistical_endpoint has adam_dataset_name (STRING) referencing the ADaM dataset used for the endpoint analysis.',
    `analysis_population_id` BIGINT COMMENT 'Foreign key linking to biostatistics.analysis_population. Business justification: statistical_endpoint has analysis_population as a STRING field referencing the population for the endpoint analysis.',
    `estimand_id` BIGINT COMMENT 'Foreign key linking to biostatistics.estimand. Business justification: Per ICH E9(R1), each statistical endpoint is defined in the context of an estimand. statistical_endpoint has estimand_treatment_policy (STRING) which is a partial reference to the',
    `lab_analyte_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_analyte. Business justification: Statistical endpoints (e.g., change from baseline in HbA1c, CTCAE grade for ALT) are defined in terms of specific lab analytes.',
    `protocol_endpoint_id` BIGINT COMMENT 'Foreign key linking to study.study_endpoint. Business justification: ICH E9(R1) and regulatory submissions require explicit traceability from the source system to protocol-defined endpoints.',
    `randomization_treatment_arm_id` BIGINT COMMENT 'Foreign key linking to randomization.treatment_arm. Business justification: Statistical endpoints are defined for specific treatment comparisons referencing the control arm and active arm.',
    `sap_id` BIGINT COMMENT 'Reference to the Statistical Analysis Plan (the source system) document version in which this endpoint is formally defined. Links endpoint traceability from the source system TLF production.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this statistical endpoint is defined. Enables endpoint-level traceability to the study protocol.',
    `tlf_shell_id` BIGINT COMMENT 'Foreign key linking to biostatistics.tlf_shell. Business justification: statistical_endpoint has tlf_reference (STRING) pointing to the TLF shell that displays the endpoint results.',
    `alpha_spending_function` STRING COMMENT 'Alpha spending function used to allocate Type I error across interim and final analyses for this endpoint when interim_analysis_flag is True: OBrien-Fleming, Pocock, Lan-DeMets, Hwang-Shih-DeCani, or none.. Valid values are `obrien_fleming|pocock|lan_demets|hwang_shih_decani|none`',
    `alternative_hypothesis` STRING COMMENT 'The alternative hypothesis being tested for this endpoint, specifying the expected direction and magnitude of the treatment effect, as defined in the statistical analysis plan per ICH E9.',
    `analysis_timepoint` STRING COMMENT 'Scheduled visit or time window at which the endpoint is measured or evaluated (e.g., Week 24, End of Treatment, Month 12). May represent a single timepoint or a range as defined in the the source system.',
    `approved_date` DATE COMMENT 'Date on which this endpoint definition was formally approved in the the source system biostatistics lead and sponsor. Must precede database lock (DBL) to satisfy pre-specification requirements for confirmatory endpoints.',
    `confidence_interval_level` DECIMAL(5,2) COMMENT 'Pre-specified confidence interval level for the treatment effect estimate (e.g., 95.00 for a 95% CI, 97.50 for a one-sided 97.5% CI). Defined in the the source system in TLFs and regulatory submissions.',
    `covariates` STRING COMMENT 'Comma-separated list of pre-specified covariates and stratification factors included in the statistical model for this endpoint (e.g., baseline_value, region, age_group). Defined in the the source system guideline on adjustment for baseline covariates.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this statistical endpoint record was first created in the system. Supports ALCOA+ audit trail and 21 CFR Part 11 electronic records compliance.',
    `csr_section_reference` STRING COMMENT 'Reference to the Clinical Study Report (CSR) section where this endpoints results are reported (e.g., Section 11.4.1). Supports traceability from the source system to the final regulatory submission document per ICH E3.',
    `effect_measure` STRING COMMENT 'The statistical measure used to quantify the treatment effect for this endpoint (e.g., Mean Difference, Hazard Ratio, Odds Ratio, Risk Difference, Least Squares Mean Difference). Specified in the the source system in TLFs and the CSR.',
    `endpoint_classification` STRING COMMENT 'Hierarchical classification of the endpoint within the studys inferential framework: primary (confirmatory, controls Type I error), secondary (supportive), exploratory (hypothesis-generating), or safety (adverse event-related).. Valid values are `primary|secondary|exploratory|safety`',
    `endpoint_description` STRING COMMENT 'Full narrative description of the statistical endpoint as stated in the the source system, including the precise definition of the outcome measure, population, and timeframe.',
    `endpoint_name` STRING COMMENT 'Short, human-readable name of the statistical endpoint as defined in the the source system Survival, Change from Baseline in HbA1c at Week 24). Used in TLF titles and regulatory submissions.',
    `endpoint_status` STRING COMMENT 'Current lifecycle status of the statistical endpoint definition within the the source system versioning workflow: draft (being authored), under_review (in statistical/medical review), approved (finalized in the source system), locked (post-database lock. Valid values are `draft|under_review|approved|locked|superseded|retired`',
    `endpoint_type` STRING COMMENT 'Scientific domain classification of the endpoint: efficacy (clinical benefit), pharmacokinetic (PK - drug exposure), pharmacodynamic (PD - drug effect), biomarker (biological marker), patient_reported_outcome (PRO - patient self-report), or safety.. Valid values are `efficacy|pharmacokinetic|pharmacodynamic|biomarker|patient_reported_outcome|safety`',
    `hypothesis_type` STRING COMMENT 'Type of statistical hypothesis being tested for this endpoint: superiority (treatment better than control), non-inferiority (treatment not worse by a defined margin), equivalence (treatment within bounds of control), or exploratory (no formal hypothesis).. Valid values are `superiority|non_inferiority|equivalence|exploratory`',
    `interim_analysis_flag` BOOLEAN COMMENT 'Indicates whether this endpoint is included in one or more pre-specified interim analyses (e.g., for Data Safety Monitoring Board (DSMB) review or adaptive design decision rules). True if the endpoint is evaluated at interim; False if final analysis only.',
    `locked_date` DATE COMMENT 'Date on which this endpoint definition was locked following database lock (DBL), rendering it immutable for regulatory submission purposes. Supports ALCOA+ audit trail requirements.',
    `measurement_scale` STRING COMMENT 'Statistical measurement scale of the endpoint variable: continuous (numeric), binary (two outcomes), categorical (nominal groups), ordinal (ranked categories), or time_to_event (survival/event-time). Determines the appropriate statistical test method.. Valid values are `continuous|binary|categorical|ordinal|time_to_event`',
    `missing_data_method` STRING COMMENT 'Pre-specified method for handling missing data for this endpoint (e.g., Multiple Imputation, Last Observation Carried Forward (LOCF), Baseline Observation Carried Forward (BOCF), Mixed Model for Repeated Measures (MMRM), Complete Case Analysis).',
    `multiplicity_adjustment_method` STRING COMMENT 'Statistical method applied to control the family-wise error rate (FWER) or false discovery rate (FDR) when testing multiple endpoints: Bonferroni, Hochberg, Holm, Benjamini-Hochberg, fixed-sequence, gatekeeping, or none.',
    `multiplicity_testing_family` STRING COMMENT 'Name or label of the multiplicity testing family or hierarchy to which this endpoint belongs (e.g., Primary Family, Secondary Family 1). Used to group endpoints within a gatekeeping or hierarchical testing procedure defined in the the source system.',
    `non_inferiority_margin` DECIMAL(18,6) COMMENT 'Pre-specified non-inferiority margin (delta) for non-inferiority or equivalence endpoints, representing the largest clinically acceptable difference between treatment and control. Required by FDA and EMA for non-inferiority trial designs.',
    `null_hypothesis` STRING COMMENT 'Formal statement of the null hypothesis (H0) for this endpoint as specified in the the source system is no difference in overall survival between treatment and control arms). Required for confirmatory endpoints per ICH E9.',
    `regulatory_designation` STRING COMMENT 'Regulatory authority-specific designation of this endpoint indicating its role in submissions to FDA, EMA, or both. Enables endpoint-level traceability for multi-regional regulatory submissions (IND, NDA, BLA, MAA).',
    `sap_version` STRING COMMENT 'Version number of the the source system which this endpoint was defined or last modified (e.g., v1.0, v2.1). Supports version-controlled traceability of endpoint definitions across the source system to database lock.. Valid values are `^v[0-9]+.[0-9]+$`',
    `sensitivity_analysis_flag` BOOLEAN COMMENT 'Indicates whether one or more pre-specified sensitivity analyses are defined for this endpoint in the the source system the robustness of the primary analysis results. True if sensitivity analyses are planned; False otherwise.',
    `significance_level` DECIMAL(6,4) COMMENT 'Pre-specified Type I error rate (alpha) for this endpoint, typically 0.05 for primary endpoints or adjusted values for multiplicity-controlled secondary endpoints. Defined in the the source system database lock.',
    `statistical_test_method` STRING COMMENT 'The primary statistical test or model used to analyze this endpoint (e.g., ANCOVA, Log-rank test, Cox proportional hazards model, Mixed Model for Repeated Measures (MMRM), Wilcoxon rank-sum test).',
    `subgroup_analysis_flag` BOOLEAN COMMENT 'Indicates whether pre-specified subgroup analyses are defined for this endpoint in the the source system age, sex, region, disease severity). True if subgroup analyses are planned; False otherwise. Relevant for FDA and EMA sub requirements.',
    `testing_sequence_order` BIGINT COMMENT 'Numeric position of this endpoint within the pre-specified hierarchical or fixed-sequence testing procedure. Determines the order in which endpoints are tested to control Type I error. Lower values are tested first.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this statistical endpoint record was last modified. Supports ALCOA+ audit trail and 21 CFR Part 11 electronic records compliance for the source system',
    CONSTRAINT pk_statistical_endpoint PRIMARY KEY(`statistical_endpoint_id`)
) COMMENT 'Master record for each statistical endpoint defined in the the source system study. Captures endpoint name, classification (primary, secondary, exploratory, safety), endpoint type (efficacy, PK, PD, biomarker, PRO), measurement scale, analysis timepoint(s)';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` (
    `pk_analysis_spec_id` BIGINT COMMENT 'Unique surrogate identifier for the PK analysis specification record. Primary key for this entity.',
    `adam_dataset_spec_id` BIGINT COMMENT 'Foreign key linking to biostatistics.adam_dataset_spec. Business justification: pk_analysis_spec has adam_dataset_name (STRING) referencing the ADaM dataset used for PK analysis.',
    `analysis_population_id` BIGINT COMMENT 'Foreign key linking to biostatistics.analysis_population. Business justification: pk_analysis_spec has analysis_population (STRING) referencing the population for PK analysis.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: PK analysis specs require a named approver (biostatistician or DMPK scientist) for regulatory submission and CDISC compliance.',
    `bioanalytical_assay_id` BIGINT COMMENT 'Foreign key linking to laboratory.bioanalytical_assay. Business justification: The PK analysis spec defines LLOQ handling, NCA method, and matrix-specific rules that are directly tied to the validated bioanalytical assay.',
    `dosing_regimen_id` BIGINT COMMENT 'Foreign key linking to study.dosing_regimen. Business justification: PK analysis specs reference specific dosing regimens for dose normalization (dose_normalization_flag/method) and steady-state determination.',
    `investigational_product_id` BIGINT COMMENT 'Foreign key linking to study.investigational_product. Business justification: PK analysis specs are authored per investigational product — dose normalization methods, compartmental model types, and BE bounds are IP-specific.',
    `pipeline_asset_id` BIGINT COMMENT 'Foreign key linking to sponsor.pipeline_asset. Business justification: PK analysis specifications (compartmental_model_type, nca_method, pk_parameters, dose_normalization_method) are defined for a specific investigational product.',
    `pk_sampling_schedule_id` BIGINT COMMENT 'Foreign key linking to study.pk_sampling_schedule. Business justification: DMPK teams author PK analysis specs against specific protocol sampling schedules.',
    `sap_id` BIGINT COMMENT 'Reference to the parent Statistical Analysis Plan (the source system) document under which this PK analysis specification is governed. Ensures traceability from PK parameters to the approved the source system',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this PK analysis specification is authored. Links the specification to the study protocol, the source system, and CTMS records.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: PK/PD analysis plans are filed as standalone essential TMF documents in Phase I/II studies and regulatory submissions (FDA/EMA guidance).',
    `analysis_type` STRING COMMENT 'Classification of the pharmacokinetic analysis methodology. Non-Compartmental Analysis (NCA) is standard for most Phase I studies; compartmental and population PK (PopPK) are used for Phase II/III. Bioequivalence (BE) applies to generic/biosimilar studies.. Valid values are `NCA|compartmental|population_pk|pk_pd|bioequivalence`',
    `approval_date` DATE COMMENT 'Date on which this PK analysis specification was formally approved. Marks the transition from draft to approved status and establishes the effective date for analysis execution.',
    `auc_extrapolation_pct_threshold` DECIMAL(5,2) COMMENT 'Maximum acceptable percentage of AUC0-inf attributable to extrapolation beyond the last measurable concentration (AUC_extrap%). Subjects exceeding this threshold (typically 20%) may have AUC0-inf excluded from analysis per regulatory guidance.',
    `be_lower_bound_pct` DECIMAL(5,2) COMMENT 'Lower bound of the bioequivalence acceptance range expressed as a percentage of the reference geometric mean ratio (e.g., 80.00 for the standard 80-125% BE window). Applies when bioequivalence_flag is True.',
    `be_upper_bound_pct` DECIMAL(5,2) COMMENT 'Upper bound of the bioequivalence acceptance range expressed as a percentage of the reference geometric mean ratio (e.g., 125.00 for the standard 80-125% BE window). Applies when bioequivalence_flag is True.',
    `bioequivalence_flag` BOOLEAN COMMENT 'Indicates whether this PK analysis specification includes a formal bioequivalence (BE) assessment. True = BE criteria and confidence interval (CI) testing apply. Relevant for generic drug applications (ANDA) and biosimilar submissions.',
    `blinding_status` STRING COMMENT 'Indicates whether the PK analysis is conducted under blinded, unblinded, or open-label conditions. Interim PK analyses for dose escalation decisions may be conducted unblinded by an independent DSMB/DMC while the main study remains blinded.. Valid values are `blinded|unblinded|open_label`',
    `ci_level_pct` DECIMAL(5,2) COMMENT 'Confidence level for the statistical interval estimate expressed as a percentage (e.g., 90.00 for 90% CI used in BE studies, 95.00 for standard efficacy analyses). Regulatory standard for BE is 90%.',
    `ci_method` STRING COMMENT 'Statistical method used to construct the confidence interval for the primary PK parameter comparison. The two one-sided t-test (TOST) / 90% CI using a linear mixed-effects model is the regulatory standard for bioequivalence.. Valid values are `two_one_sided_t_test|90pct_ci_lme|schuirmann|westlake|fieller`',
    `compartmental_model_type` STRING COMMENT 'Specifies the pharmacokinetic compartmental model structure used when compartmental or population PK analysis is selected. Drives model parameterization in Phoenix WinNonlin or NONMEM. Not applicable for pure NCA analyses.. Valid values are `one_compartment|two_compartment|three_compartment|non_compartmental|mixed_effects`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this PK analysis specification record was first created in the system. Supports ALCOA+ audit trail requirements and 21 CFR Part 11 electronic record integrity.',
    `dmpk_collaboration_ref` STRING COMMENT 'Reference identifier linking this PK analysis specification to the Drug Metabolism and Pharmacokinetics (DMPK) team collaboration record, preclinical PK data package, or DMPK study report. Supports integrated PK/PD and translational PK reporting.',
    `dose_normalization_flag` BOOLEAN COMMENT 'Indicates whether PK parameters are to be dose-normalized (divided by administered dose) to enable cross-dose comparisons in multiple ascending dose (MAD) or dose-proportionality studies. True = dose normalization applied.',
    `dose_normalization_method` STRING COMMENT 'Method used to normalize PK parameters by dose when dose_normalization_flag is True. Actual dose uses the recorded administered dose; nominal dose uses the protocol-specified dose.. Valid values are `actual_dose|nominal_dose|body_weight_normalized|bsa_normalized`',
    `effective_from_date` DATE COMMENT 'Date from which this version of the PK analysis specification is effective and governs analysis execution. For versioned specifications, this date determines which version applies to a given analysis run.',
    `interim_analysis_flag` BOOLEAN COMMENT 'Indicates whether this specification governs an interim PK analysis (e.g., for dose escalation decisions, DSMB review, or adaptive design triggers) as opposed to the final analysis. Interim analyses require additional blinding and data governance controls.',
    `lambda_z_method` STRING COMMENT 'Method for selecting the terminal log-linear phase data points used to estimate the terminal elimination rate constant (Lambda-z / Kel) and derived parameters (t½, AUC0-inf). Best-fit uses automated regression; manual selection allows analyst override.. Valid values are `best_fit|manual_selection|fixed_points`',
    `lambda_z_min_points` BIGINT COMMENT 'Minimum number of data points required in the terminal phase for Lambda-z estimation to be considered valid. Typically set to 3 per regulatory guidance. Specifications below this threshold result in flagged or excluded Lambda-z estimates.',
    `lloq_handling_method` STRING COMMENT 'Specifies how concentrations below the lower limit of quantification (LLOQ) are handled in the PK analysis dataset. Regulatory guidance typically requires setting pre-dose BLQ values to zero and post-dose BLQ values to zero or excluding them depending on. Valid values are `set_to_zero|set_to_half_lloq|exclude|set_to_lloq`',
    `log_transformation_flag` BOOLEAN COMMENT 'Indicates whether PK parameters are log-transformed prior to statistical analysis. Log-normal distribution is the regulatory default for AUC and Cmax in BE and PK studies per FDA and EMA guidance.',
    `missing_concentration_rule` STRING COMMENT 'Rule applied when scheduled PK concentration timepoints are missing. Defines whether the subject is excluded from analysis, the timepoint is excluded, or imputation is applied.. Valid values are `exclude_subject|exclude_timepoint|impute_locf|impute_linear|flag_only`',
    `nca_method` STRING COMMENT 'Specifies the trapezoidal integration rule applied during Non-Compartmental Analysis (NCA) for area-under-the-curve (AUC) estimation. Linear-up/log-down is the most common default in Phoenix WinNonlin for oral dosing studies.. Valid values are `linear_trapezoidal|log_linear_trapezoidal|linear_log_trapezoidal|linear_up_log_down`',
    `notes` STRING COMMENT 'Free-text field for biostatistician or DMPK analyst notes regarding special considerations, deviations from standard methodology, or sponsor-specific requirements for this PK analysis specification.',
    `pk_parameters` STRING COMMENT 'Comma-separated list of pharmacokinetic parameters to be estimated in this analysis (e.g., AUC0-t, AUC0-inf, Cmax, Tmax, t½, CL, Vd, Vss, MRT, Kel). Defines the scope of PK endpoints reported in the CSR and regulatory submission.',
    `pk_software` STRING COMMENT 'Software platform used to execute the PK analysis (e.g., Phoenix WinNonlin for NCA, NONMEM for population PK, SAS Drug Development for CDISC-compliant outputs). Documented for regulatory reproducibility per 21 CFR Part 11.. Valid values are `Phoenix_WinNonlin|SAS|NONMEM|R|Monolix|PKSolver`',
    `pk_software_version` STRING COMMENT 'Version of the PK analysis software used (e.g., Phoenix WinNonlin 8.3, SAS 9.4). Required for regulatory submission reproducibility and audit trail under 21 CFR Part 11 and GCP.',
    `primary_pk_parameter` STRING COMMENT 'The single primary pharmacokinetic parameter designated as the principal endpoint for this analysis (e.g., AUC0-inf for bioavailability studies, Cmax for peak exposure).',
    `r_squared_threshold` DECIMAL(5,4) COMMENT 'Minimum adjusted R-squared value required for the terminal phase regression used in Lambda-z estimation to be accepted (e.g., 0.8000). Estimates below this threshold are flagged for biostatistician review.',
    `regulatory_submission_flag` BOOLEAN COMMENT 'Indicates whether the PK analysis outputs from this specification are intended for inclusion in a regulatory submission (IND, NDA, BLA, MAA, or eCTD package). Triggers additional CDISC compliance validation and 21 CFR Part 11 audit requirements.',
    `sampling_schedule_type` STRING COMMENT 'Classifies the blood sampling schedule design for PK data collection. Intensive sampling (rich PK) is used in Phase I; sparse/population sampling is used in Phase II/III for population PK modeling. Trough-only is used for therapeutic drug monitoring.. Valid values are `intensive|sparse|population|trough_only`',
    `sdtm_pc_domain_ref` STRING COMMENT 'Reference to the CDISC SDTM Pharmacokinetics Concentrations (PC) domain dataset that serves as the source data for this PK analysis. Ensures traceability from raw concentration data through ADaM to TLF outputs per CDISC standards.',
    `spec_code` STRING COMMENT 'Externally-known, human-readable unique code assigned to this PK analysis specification (e.g., PK-SPEC-001). Used for cross-referencing in the Statistical Analysis Plan (the source system), Clinical Study Report (CSR), and regulatory submissions.. Valid values are `^PK-SPEC-[A-Z0-9]{3,20}$`',
    `spec_status` STRING COMMENT 'Current lifecycle status of the PK analysis specification. Controls which version is active for analysis execution. Transitions from draft through review to approved prior to database lock (DBL).. Valid values are `draft|under_review|approved|superseded|retired`',
    `spec_title` STRING COMMENT 'Descriptive title of the PK analysis specification (e.g., Non-Compartmental PK Analysis for Study XYZ Phase I Single Ascending Dose). Used for identification in SAS Drug Development and regulatory documentation.',
    `spec_version` STRING COMMENT 'Version number of this PK analysis specification (e.g., 1.0, 2.1). Supports versioning lifecycle as the specification evolves through the source system protocol updates.. Valid values are `^[0-9]+.[0-9]+$`',
    `study_design_type` STRING COMMENT 'Specifies the clinical study design relevant to PK analysis (e.g., crossover for BE studies, parallel for oncology PK, replicate crossover for highly variable drugs). Determines the statistical model structure for PK comparisons.. Valid values are `crossover|parallel|replicate_crossover|single_dose|multiple_dose`',
    `superseded_date` DATE COMMENT 'Date on which this version of the PK analysis specification was superseded by a newer version. Null if the specification is currently active. Supports version history and audit trail.',
    `tlf_program_name` STRING COMMENT 'Name of the SAS Drug Development program or script used to generate the Tables, Listings, and Figures (TLF) outputs for this PK analysis. Supports audit trail and reproducibility requirements for regulatory submissions.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this PK analysis specification record was last modified. Supports change tracking, audit trail, and version control requirements under 21 CFR Part 11 and GCP.',
    CONSTRAINT pk_pk_analysis_spec PRIMARY KEY(`pk_analysis_spec_id`)
) COMMENT 'Pharmacokinetic (PK) analysis specification record. Captures PK parameters to be estimated (AUC, Cmax, Tmax, t½, CL, Vd), compartmental model type, non-compartmental analysis (NCA) settings, software (Phoenix WinNonlin, SAS), dose normalization approach';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` (
    `estimand_id` BIGINT COMMENT 'Unique surrogate identifier for the estimand definition record within the biostatistics data product. Primary key for the estimand entity in the Databricks Silver Layer.',
    `adam_dataset_spec_id` BIGINT COMMENT 'Foreign key linking to biostatistics.adam_dataset_spec. Business justification: estimand has adam_dataset_name (STRING) referencing the ADaM dataset that implements the estimand analysis.',
    `analysis_population_id` BIGINT COMMENT 'Foreign key linking to biostatistics.analysis_population. Business justification: An estimand is defined for a specific analysis population (target population is a core component of the ICH E9(R1) estimand framework).',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: ICH E9(R1) estimands require formal approval by a named statistician for regulatory submission.',
    `endpoint_id` BIGINT COMMENT 'Foreign key linking to study.study_endpoint. Business justification: ICH E9(R1) defines estimands as operationalizations of specific clinical endpoints. Regulatory submissions require explicit estimand-to-endpoint traceability.',
    `sap_id` BIGINT COMMENT 'Reference to the Statistical Analysis Plan (the source system) document version in which this estimand is formally specified and aligned. Ensures traceability between the estimand definition and the governing the source system.',
    `sponsor_regulatory_strategy_id` BIGINT COMMENT 'Foreign key linking to sponsor.regulatory_strategy. Business justification: Estimands per ICH E9(R1) must align with the sponsors regulatory strategy (submission_pathway, regulatory_designation, target_health_authority).',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this estimand is defined. Links the estimand to its parent protocol and study-level metadata.',
    `adam_parameter_code` STRING COMMENT 'The CDISC ADaM PARAMCD value identifying the specific analysis parameter within the ADaM dataset that corresponds to this estimands endpoint variable. Enables direct linkage to TLF outputs and CDISC submission datasets.',
    `alpha_level` DECIMAL(6,5) COMMENT 'The pre-specified significance level (Type I error rate) allocated to this estimand in the confirmatory testing procedure (e.g., 0.05000, 0.02500 for two-sided tests). Null for exploratory estimands.',
    `analysis_timepoint` STRING COMMENT 'The primary timepoint or time window at which the endpoint variable is assessed for this estimand (e.g., Week 24, End of Treatment, Month 12, Event-driven at 300 events). Defines the temporal scope of the estimand.',
    `approved_date` DATE COMMENT 'Date on which this estimand definition was formally approved in the the source system Establishes the regulatory-effective date for the estimand specification.',
    `blinding_status` STRING COMMENT 'Indicates whether the estimand analysis is conducted under blinded, unblinded, or open-label conditions. Relevant for interim analyses and DSMB/DMC review packages where unblinding records must be maintained.. Valid values are `blinded|unblinded|open_label`',
    `estimand_code` STRING COMMENT 'Externally-known alphanumeric business identifier for the estimand, used in the source system submissions, and cross-functional communications. Follows the pattern EST-{STUDYCODE}{SEQ}.. Valid values are `^EST-[A-Z0-9]{2,20}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this estimand record was first created in the SAS Drug Development / biostatistics data system. Supports ALCOA+ audit trail and 21 CFR Part 11 electronic records compliance.',
    `csr_section_reference` STRING COMMENT 'Reference to the section of the Clinical Study Report (CSR) where results for this estimand are reported (e.g., Section 11.4.1). Supports ICH E3 CSR structure compliance and regulatory submission traceability.',
    `effect_direction` STRING COMMENT 'The inferential objective of the estimand — whether the analysis is designed to demonstrate superiority, non-inferiority, or equivalence of the treatment condition relative to the comparator.. Valid values are `superiority|non_inferiority|equivalence|exploratory`',
    `effective_from_date` DATE COMMENT 'Date from which this version of the estimand definition is operationally effective for analysis execution. Used for version control when estimands are amended mid-study.',
    `endpoint_type` STRING COMMENT 'Statistical nature of the endpoint variable. Determines the appropriate population-level summary measure and analysis methodology (e.g., continuous endpoints use mean difference; time-to-event use hazard ratio).. Valid values are `continuous|binary|time_to_event|ordinal|count`',
    `intercurrent_event_description` STRING COMMENT 'Description of the intercurrent events that may occur after treatment initiation and affect either the interpretation or the existence of the measurements associated with the clinical question of interest, as defined in ICH E9(R1).',
    `intercurrent_event_strategy` STRING COMMENT 'The strategy for handling intercurrent events in the estimand (e.g., treatment policy, hypothetical, composite, while-on-treatment, principal stratum), specifying how the estimand addresses events that affect the clinical question per ICH E9(R1).. Valid values are `treatment_policy|hypothetical|composite|while_on_treatment|principal_stratum`',
    `interim_analysis_flag` BOOLEAN COMMENT 'Flag indicating whether this estimand is evaluated at one or more pre-specified interim analyses (e.g., for DSMB/DMC review, adaptive design decision points, or early stopping rules).',
    `is_confirmatory` BOOLEAN COMMENT 'Flag indicating whether this estimand is part of the confirmatory (inferential) testing hierarchy, as opposed to exploratory or descriptive analyses. Confirmatory estimands are subject to multiplicity control procedures defined in the the source system.',
    `is_primary_endpoint` BOOLEAN COMMENT 'Flag indicating whether this estimand corresponds to the studys primary endpoint. Primary endpoint estimands carry the highest regulatory weight and drive sample size calculations and confirmatory testing procedures.',
    `label` STRING COMMENT 'Short human-readable label or title for the estimand (e.g., Primary Efficacy Estimand, Key Secondary Estimand 1). Used in TLF headers, CSR statistical sections, and regulatory submission narratives.',
    `missing_data_strategy` STRING COMMENT 'Strategy for handling missing data in the context of this estimand, specifying the approach for addressing data that are not observed due to intercurrent events or other reasons, aligned with the intercurrent event strategy per ICH E9(R1).. Valid values are `LOCF|BOCF|multiple_imputation|mixed_model|retrieved_dropout|none`',
    `multiplicity_adjustment_method` STRING COMMENT 'The statistical method used to control Type I error across multiple estimands or endpoints in the confirmatory testing hierarchy (e.g., Bonferroni, Hochberg, Hierarchical testing, Gatekeeping procedure). Null if estimand is exploratory.',
    `non_inferiority_margin` DECIMAL(18,6) COMMENT 'The pre-specified non-inferiority margin (delta) for this estimand, applicable when the effect direction is non-inferiority. Expressed in the units of the summary measure. Null for superiority or equivalence estimands.',
    `notes` STRING COMMENT 'Free-text field for additional biostatistician commentary, regulatory discussion points, or cross-references not captured in structured fields. Supports regulatory submission narrative preparation and internal review discussions.',
    `population_level_summary` STRING COMMENT 'The Summary Measure component of the ICH E9(R1) estimand framework — the statistical measure used to summarize the endpoint at the population level (e.g., Difference in means, Odds ratio, Hazard ratio, Difference in proportions).',
    `regulatory_framework` STRING COMMENT 'The primary regulatory framework or agency guideline under which this estimand is defined and will be submitted. Determines the specific regulatory expectations for estimand documentation in the Clinical Study Report (CSR).',
    `sap_alignment_status` STRING COMMENT 'Indicates whether this estimand definition is currently aligned with the approved the source system triggers a the source system Critical for regulatory inspection readiness and DBL (Database Lock) governance.. Valid values are `aligned|pending_alignment|misaligned|not_applicable`',
    `sap_section_reference` STRING COMMENT 'Specific section number or identifier within the the source system this estimand is formally defined and described (e.g., Section 4.2.1). Enables direct cross-referencing between the estimand record and the governing the source system.',
    `sensitivity_analysis_description` STRING COMMENT 'Description of the associated sensitivity analyses planned to assess the robustness of the primary estimand result to deviations from assumptions, per ICH E9(R1) Section 3.8. References specific the source system sensitivity analyses are detailed.',
    `estimand_status` STRING COMMENT 'Current lifecycle state of the estimand definition record within the the source system regulatory submission workflow. Drives version control and approval gating in SAS Drug Development.. Valid values are `draft|under_review|approved|superseded|retired`',
    `superseded_date` DATE COMMENT 'Date on which this estimand version was superseded by a newer version due to a the source system protocol change. Null for the current active version. Supports historical audit trail.',
    `supplementary_analysis_description` STRING COMMENT 'Description of supplementary analyses associated with this estimand that provide additional context or explore alternative assumptions beyond the primary and sensitivity analyses, per ICH E9(R1) Section 3.9.',
    `target_population_description` STRING COMMENT 'Narrative description of the Population component of the ICH E9(R1) estimand framework — the set of subjects to whom the question of interest applies (e.g., All randomized patients with Type 2 Diabetes and baseline HbA1c ≥ 7.5%).',
    `estimand_type` STRING COMMENT 'Classification of the estimand within the studys endpoint hierarchy. Determines regulatory weight and reporting obligations. [ENUM-REF-CANDIDATE: primary|key_secondary|secondary|exploratory|sensitivity — promote to reference product if additional types',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this estimand record. Used for change tracking, the source system and regulatory inspection readiness in the Databricks Silver Layer.',
    `version_number` STRING COMMENT 'Version identifier of the estimand definition (e.g., 1.0, 2.1). Incremented upon each approved amendment to the the source system that affects the estimand specification.. Valid values are `^d+.d+$`',
    CONSTRAINT pk_estimand PRIMARY KEY(`estimand_id`)
) COMMENT 'Estimand definition record per the ICH E9(R1) framework for a study endpoint. Captures treatment condition, target population, variable (endpoint), intercurrent event handling strategies (treatment policy, hypothetical, composite, while on treatment';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` (
    `dsmb_charter_id` BIGINT COMMENT 'Unique surrogate identifier for the DSMB/DMC charter record in the lakehouse silver layer.',
    `blinding_config_id` BIGINT COMMENT 'Foreign key linking to randomization.blinding_config. Business justification: DSMB charters define unblinding procedures, open/closed session scope, and blinding maintenance for the sponsor. These are operationally governed by the blinding_config.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.sop. Business justification: DSMB charters must reference governing SOPs for unblinding procedures, data handling, and confidentiality requirements.',
    `governance_id` BIGINT COMMENT 'Foreign key linking to program.program_governance. Business justification: The DSMB is a governance body registered in program_governance. The dsmb_charter is the governing document for that body.',
    `independent_statistician_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: ICH E9 and FDA guidance require the independent statisticians qualifications, GCP training, and independence to be verifiable.',
    `protocol_id` BIGINT COMMENT 'Reference to the specific protocol version under which this DSMB charter was authored, ensuring alignment between statistical stopping rules and the approved study protocol.',
    `rand_scheme_id` BIGINT COMMENT 'Foreign key linking to randomization.rand_scheme. Business justification: DSMB charters define stopping rules and interim analysis schedules that are directly tied to the randomization schemes alpha spending function and allocation structure.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this DSMB/DMC charter was established. Links the charter to the parent study record.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: DSMB charters are revised in response to protocol amendments (e.g., changes to stopping rules, interim analysis schedule).',
    `alpha_spending_function` STRING COMMENT 'Statistical alpha-spending function used to allocate the overall Type I error rate across planned interim analyses, as specified in the DSMB charter and the source system.. Valid values are `OBrien_Fleming|Pocock|Lan_DeMets|Hwang_Shih_DeCani|Haybittle_Peto|other`',
    `amendment_number` BIGINT COMMENT 'Sequential amendment counter for this charter. Zero (0) indicates the original charter; increments with each formal amendment. Supports version lineage tracking.',
    `amendment_reason` STRING COMMENT 'Narrative description of the business or scientific rationale for amending the DSMB/DMC charter (e.g., protocol amendment, change in stopping rules, new committee member). Null for original version.',
    `approval_date` DATE COMMENT 'Date on which the DSMB/DMC charter was formally approved by all required signatories (sponsor, committee chair, and independent statistician). Marks the effective start of the charter.',
    `approved_by` STRING COMMENT 'Name or identifier of the individual (typically the sponsors medical monitor or biostatistics lead) who formally approved this DSMB charter version in the document management system.',
    `blinding_maintained_for_sponsor` BOOLEAN COMMENT 'Indicates whether the sponsor remains blinded to unblinded interim analysis results during the study. True means the sponsor does not receive unblinded data; False means the sponsor has access (open-label or sponsor-unblinded design).',
    `charter_identifier` STRING COMMENT 'Externally-known alphanumeric code or document number assigned to this DSMB/DMC charter, used for cross-referencing in the eTMF, regulatory submissions, and sponsor communications (e.g., STUDY-001-DSMB-CHR-001).',
    `charter_scope_description` STRING COMMENT 'Narrative description of the DSMB/DMC mandate and scope, including the populations, endpoints, and study phases covered by the committees oversight responsibilities.',
    `charter_status` STRING COMMENT 'Current lifecycle status of the DSMB/DMC charter document. Drives which version is operationally active for interim analyses and stopping rule enforcement.. Valid values are `draft|under_review|approved|superseded|retired`',
    `charter_title` STRING COMMENT 'Full descriptive title of the DSMB/DMC charter document as it appears on the official document header, typically including study name and committee type.',
    `charter_version` STRING COMMENT 'Version number of the DSMB/DMC charter document (e.g., v1.0, v2.0). Tracks amendments and superseded versions throughout the study lifecycle.. Valid values are `^v?d+.d+$`',
    `closed_session_scope` STRING COMMENT 'Description of the agenda items and participants permitted in the closed (confidential) session of DSMB/DMC meetings, restricted to committee members and the independent statistician reviewing unblinded data.',
    `committee_chair_name` STRING COMMENT 'Full name of the independent physician or scientist designated as chair of the DSMB/DMC. The chair is responsible for convening meetings, managing deliberations, and communicating recommendations to the sponsor.',
    `committee_type` STRING COMMENT 'Classification of the independent monitoring committee type. DSMB (Data Safety Monitoring Board), DMC (Data Monitoring Committee), IDMC (Independent Data Monitoring Committee), ISMC (Independent Safety Monitoring Committee), and DSMC (Data and Safety. Valid values are `DSMB|DMC|IDMC|ISMC|DSMC`',
    `confidentiality_requirements` STRING COMMENT 'Narrative description of confidentiality obligations for DSMB/DMC members, including restrictions on disclosure of interim results, data firewall arrangements, and consequences of breach. Aligned with GDPR and HIPAA data protection requirements.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this DSMB charter record was first created in the system, supporting audit trail and ALCOA+ data integrity requirements.',
    `effective_date` DATE COMMENT 'Date from which this charter version becomes operationally binding for the DSMB/DMC. May differ from approval date if a transition period is specified.',
    `efficacy_stopping_rule_description` STRING COMMENT 'Narrative description of the pre-specified statistical criteria for early stopping of the study due to overwhelming efficacy (e.g., conditional power threshold, p-value boundary at each interim look). Authored by Biostatistics.',
    `expiry_date` DATE COMMENT 'Date on which this charter version ceases to be operative, typically upon supersession by an amended version or study close-out. Nullable for open-ended charters.',
    `futility_rule_binding` BOOLEAN COMMENT 'Indicates whether the futility stopping rule is binding (the DSMB recommendation to stop for futility is mandatory) or non-binding (advisory only). Binding rules have regulatory and operational implications.',
    `futility_stopping_rule_description` STRING COMMENT 'Narrative description of the pre-specified criteria for early stopping due to futility (e.g., conditional power below threshold, binding or non-binding futility boundary). Authored by Biostatistics.',
    `governing_regulatory_framework` STRING COMMENT 'Primary regulatory framework(s) under which the DSMB/DMC operates (e.g., FDA 21 CFR, EU CTR 536/2014, ICH E6(R2)). Determines applicable procedural and reporting requirements.',
    `independent_statistician_organization` STRING COMMENT 'Name of the organization or academic institution to which the independent DSMB statistician is affiliated, confirming independence from the sponsor and CRO.',
    `interim_analysis_schedule_description` STRING COMMENT 'Narrative description of the timing and triggers for each planned interim analysis (e.g., after 25%, 50%, 75% of events; after N subjects enrolled). Complements the structured interim analysis count.',
    `mastercontrol_document_reference` STRING COMMENT 'Document control identifier assigned to this DSMB charter in MasterControl, used for tracking approval workflows, training requirements, and audit trails associated with the charter.',
    `meeting_frequency` STRING COMMENT 'Scheduled frequency of DSMB/DMC meetings as defined in the charter. Governs the cadence of safety reviews and interim analyses. [ENUM-REF-CANDIDATE: monthly|quarterly|semi_annual|annual|per_interim_analysis|ad_hoc|other — promote to reference product]',
    `notes` STRING COMMENT 'Free-text field for additional operational notes, clarifications, or contextual information about this DSMB charter record not captured in structured fields.',
    `open_session_scope` STRING COMMENT 'Description of the agenda items and participants permitted in the open (non-confidential) session of DSMB/DMC meetings, typically including sponsor representatives and investigators reviewing blinded aggregate safety data.',
    `quorum_requirement` BIGINT COMMENT 'Minimum number of DSMB/DMC members required to be present for a meeting to be valid and for recommendations to be binding. Defined in the charter.',
    `recommendation_types_allowed` STRING COMMENT 'Enumeration of the formal recommendation categories the DSMB/DMC is empowered to issue per the charter (e.g., continue as planned, modify protocol, stop for efficacy, stop for futility, stop for safety, increase sample size).',
    `reporting_timeline_days` BIGINT COMMENT 'Maximum number of calendar days within which the DSMB/DMC must issue its written recommendation report to the sponsor following a meeting, as specified in the charter.',
    `safety_stopping_rule_description` STRING COMMENT 'Narrative description of the pre-specified criteria for early stopping or study modification due to unacceptable safety signals (e.g., excess SAE rate, SUSAR threshold, mortality imbalance). Aligned with the source system signal detection.',
    `sponsor_response_timeline_days` BIGINT COMMENT 'Maximum number of calendar days within which the sponsor must formally respond to a DSMB/DMC recommendation, as defined in the charter.',
    `total_interim_analyses_planned` BIGINT COMMENT 'Total number of formal interim analyses planned for the study as specified in the DSMB charter and aligned with the Statistical Analysis Plan (the source system). Drives alpha-spending allocation.',
    `total_member_count` BIGINT COMMENT 'Total number of voting members constituting the DSMB/DMC as defined in the charter. Typically an odd number (3–7) to enable majority voting on recommendations.',
    `unblinding_procedure_description` STRING COMMENT 'Narrative description of the procedures governing when and how unblinded data are provided to the DSMB/DMC independent statistician, including access controls, secure data transfer protocols, and firewall arrangements between the independent statistician',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this DSMB charter record, supporting audit trail and ALCOA+ data integrity requirements.',
    CONSTRAINT pk_dsmb_charter PRIMARY KEY(`dsmb_charter_id`)
) COMMENT 'Data Safety Monitoring Board (DSMB) / Data Monitoring Committee (DMC) charter record for a study. Captures committee composition, member roles (chair, statistician, clinician), meeting frequency, interim analysis schedule, stopping rules, unblinding';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` (
    `dsmb_meeting_id` BIGINT COMMENT 'Unique surrogate identifier for each DSMB/DMC meeting record in the biostatistics domain. Primary key for the dsmb_meeting entity.',
    `blinding_config_id` BIGINT COMMENT 'Foreign key linking to randomization.blinding_config. Business justification: DSMB meetings operate under a specific blinding configuration that governs what data is revealed in open vs. closed sessions.',
    `dsmb_charter_id` BIGINT COMMENT 'Foreign key linking to biostatistics.dsmb_charter. Business justification: A DSMB meeting is convened under a specific DSMB charter that governs its conduct, stopping rules, and procedures.',
    `interim_analysis_id` BIGINT COMMENT 'Foreign key linking to biostatistics.interim_analysis. Business justification: DSMB meetings are frequently convened to review interim analysis results. dsmb_meeting already has interim_analysis_number (a business display number), but lacks a proper FK to',
    `sap_id` BIGINT COMMENT 'Reference to the Statistical Analysis Plan version that governed the interim analysis reviewed at this DSMB meeting. Ensures traceability between the meeting and the applicable the source system',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this DSMB/DMC meeting was convened. Links the meeting to the parent study record.',
    `action_item_due_date` DATE COMMENT 'Target date by which the sponsor or study team must respond to or resolve the action items issued by the DSMB at this meeting. Drives follow-up tracking and regulatory compliance.',
    `action_items` STRING COMMENT 'Narrative description of specific action items assigned to the sponsor, CRO, or study team arising from the DSMB meeting. Includes responsible party and requested completion timeframe where specified.',
    `agenda_items` STRING COMMENT 'Structured list or narrative description of the agenda items reviewed during the DSMB meeting, including safety data review, efficacy data review, protocol deviations, SAE summaries, and any special topics. Stored as a delimited text field.',
    `charter_version` STRING COMMENT 'Version identifier of the DSMB/DMC charter that was in effect at the time of this meeting. The charter defines the committees mandate, operating procedures, and stopping rules.',
    `confidentiality_maintained` BOOLEAN COMMENT 'Confirms that the confidentiality of unblinded interim analysis data was maintained throughout the DSMB meeting process, with no unauthorized disclosure to sponsor or study team. Required attestation for blinding integrity audit trail.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this DSMB meeting record was first created in the system. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `data_cut_date` DATE COMMENT 'The date through which clinical data was included in the interim analysis data package reviewed at this meeting. Establishes the temporal boundary of the safety and efficacy data presented to the DSMB.',
    `etmf_document_reference` STRING COMMENT 'Reference identifier for the DSMB meeting minutes and associated documents as filed in the Veeva Vault eTMF system. Enables cross-system traceability between the biostatistics data product and the document management system.',
    `independent_statistician_present` BOOLEAN COMMENT 'Indicates whether the independent (unblinded) statistician was present at the closed session of this DSMB meeting. The independent statisticians presence is required for valid interim analysis review per the DSMB charter.',
    `interim_analysis_data_package_version` STRING COMMENT 'Version identifier of the unblinded interim analysis data package (ADaM datasets and TLFs) reviewed by the DSMB at this meeting. Ensures traceability to the exact data cut used for committee deliberations.',
    `meeting_date` DATE COMMENT 'The calendar date on which the DSMB/DMC meeting was held or is scheduled to be held. Principal real-world event date for this transaction record.',
    `meeting_duration_minutes` BIGINT COMMENT 'Total duration of the DSMB meeting in minutes, including both open and closed sessions. Used for meeting management reporting and resource planning.',
    `meeting_identifier` STRING COMMENT 'Externally-known alphanumeric code or reference number assigned to this DSMB/DMC meeting (e.g., STUDY001-DSMB-003). Used in regulatory correspondence, meeting minutes, and TMF filing.. Valid values are `^[A-Z0-9_-]{3,50}$`',
    `meeting_location` STRING COMMENT 'Physical location or virtual platform where the DSMB meeting was conducted (e.g., city and venue for in-person meetings, or platform name for teleconferences). Documented in meeting minutes for audit trail.',
    `meeting_number` BIGINT COMMENT 'Sequential ordinal number of this DSMB/DMC meeting within the study (e.g., 1st, 2nd, 3rd meeting). Used to track the cadence of oversight activities across the study lifecycle.',
    `meeting_status` STRING COMMENT 'Current lifecycle status of the DSMB/DMC meeting record. Tracks whether the meeting has been scheduled, is in progress, has been completed, cancelled, or postponed.. Valid values are `scheduled|completed|cancelled|postponed|in_progress`',
    `meeting_type` STRING COMMENT 'Classification of the meeting as a regularly scheduled review, an ad hoc convening triggered by a safety signal or sponsor request, or an emergency meeting. Drives agenda preparation and regulatory notification requirements.. Valid values are `scheduled|ad_hoc|emergency|teleconference|face_to_face`',
    `members_present_count` BIGINT COMMENT 'Number of DSMB/DMC voting members who attended this meeting. Used to verify quorum and document committee composition for regulatory audit trail.',
    `minutes_approval_date` DATE COMMENT 'Date on which the DSMB meeting minutes were formally approved by the committee chair. Required for eTMF filing and regulatory inspection readiness.',
    `minutes_status` STRING COMMENT 'Current approval status of the DSMB meeting minutes document. Tracks the lifecycle from draft through committee review to final approval. Finalized minutes are filed in the eTMF and are subject to regulatory inspection.. Valid values are `draft|under_review|approved|finalized`',
    `next_meeting_date` DATE COMMENT 'Tentative or confirmed date for the next scheduled DSMB meeting as agreed upon at the conclusion of this meeting. Supports study oversight planning and timeline management.',
    `protocol_amendment_triggered` BOOLEAN COMMENT 'Indicates whether the DSMB recommendation from this meeting resulted in a protocol amendment being initiated (e.g., dose modification, stopping rule revision, sample size re-estimation). Links to the protocol amendment workflow.',
    `quorum_met` BOOLEAN COMMENT 'Indicates whether the required quorum of DSMB/DMC members was present for the meeting to be considered valid per the DSMB charter. Meetings without quorum may require rescheduling or special procedures.',
    `recommendation` STRING COMMENT 'The formal recommendation issued by the DSMB/DMC following review of the interim data. Drives critical study-level decisions including continuation, modification, or termination. Regulatory agencies require documentation of all DSMB recommendations.. Valid values are `continue|pause|stop_efficacy|stop_futility|stop_safety|modify_protocol`',
    `recommendation_rationale` STRING COMMENT 'Narrative explanation of the scientific and safety basis for the DSMB recommendation. Captured in the closed session minutes and required for regulatory submissions and CSR documentation.',
    `regulatory_notification_date` DATE COMMENT 'Date on which the required regulatory notification (e.g., IND safety report to FDA) was submitted following this DSMB meeting. Null if no regulatory notification was required.',
    `regulatory_notification_required` BOOLEAN COMMENT 'Indicates whether the DSMB recommendation or findings from this meeting trigger a mandatory regulatory notification (e.g., IND safety report, SUSAR submission, protocol amendment). Drives regulatory affairs workflow.',
    `sae_count_reviewed` BIGINT COMMENT 'Total number of Serious Adverse Events (SAEs) included in the safety data package reviewed by the DSMB at this meeting. Provides a quantitative measure of the safety data scope presented.',
    `session_type` STRING COMMENT 'Indicates whether the meeting session was open (sponsor representatives present), closed (committee members and unblinded statistician only), or executive (committee deliberation only). Critical for blinding integrity and regulatory audit trail.. Valid values are `open|closed|executive`',
    `sponsor_notification_date` DATE COMMENT 'Date on which the sponsor was formally notified of the DSMB recommendation. Required for regulatory compliance tracking and audit trail. Must be within the timeframe specified in the DSMB charter.',
    `sponsor_notified` BOOLEAN COMMENT 'Indicates whether the sponsor has been formally notified of the DSMB recommendation following this meeting. Regulatory timelines for sponsor notification are defined in the DSMB charter and applicable regulations.',
    `statistical_report_version` STRING COMMENT 'Version identifier of the unblinded statistical report (produced in SAS Drug Development) submitted to the DSMB for this meeting. Distinct from the data package version; tracks the analysis output document.',
    `stopping_boundary_crossed` BOOLEAN COMMENT 'Indicates whether any pre-specified statistical stopping boundary (efficacy, futility, or safety) was crossed at this interim analysis. True triggers mandatory sponsor notification and potential protocol amendment.',
    `stopping_boundary_type` STRING COMMENT 'Specifies which type of pre-defined stopping boundary was crossed at this interim analysis, if any. Null or none when no boundary was crossed. Informs the recommendation and regulatory notification pathway.. Valid values are `efficacy|futility|safety|none`',
    `subjects_completed_at_review` BIGINT COMMENT 'Number of subjects who had completed the study treatment or observation period as of the data cut-off date. Used by the DSMB to assess study progress relative to the planned timeline.',
    `subjects_enrolled_at_review` BIGINT COMMENT 'Total number of subjects enrolled in the study as of the data cut-off date for this DSMB meeting. Provides context for the safety and efficacy data reviewed and supports sample size tracking.',
    `unblinding_occurred` BOOLEAN COMMENT 'Indicates whether treatment assignment unblinding occurred for the purposes of this DSMB meetings interim analysis. Critical for blinding integrity audit trail and regulatory compliance.',
    `unblinding_scope` STRING COMMENT 'Describes the extent of unblinding performed for this meeting: full (all treatment arms revealed), partial (aggregate or selected data only), or none (blinded review only). Supports blinding integrity documentation.. Valid values are `full|partial|none`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this DSMB meeting record was most recently modified. Supports audit trail requirements and data lineage tracking in the Databricks Silver Layer.',
    CONSTRAINT pk_dsmb_meeting PRIMARY KEY(`dsmb_meeting_id`)
) COMMENT 'DSMB/DMC meeting record capturing each scheduled or ad hoc committee meeting. Captures meeting date, type (open/closed session), agenda items, interim analysis data package version, statistical report version, recommendations issued';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` (
    `analysis_output_id` BIGINT COMMENT 'BIGINT',
    `adam_dataset_spec_id` BIGINT COMMENT 'description',
    `analysis_id` BIGINT COMMENT 'Analysis that produces this output.',
    `analysis_population_id` BIGINT COMMENT 'description',
    `analysis_set_id` BIGINT COMMENT 'Non-FK reference to analysis set identifier for documentation purposes only; does not create circular dependency',
    `parent_analysis_output_id` BIGINT COMMENT 'Self-reference for hierarchical output structure',
    `reporting_event_id` BIGINT COMMENT 'Owning reporting event.',
    `sap_id` BIGINT COMMENT 'the source system the output.',
    `study_id` BIGINT COMMENT 'Study the output belongs to.',
    `tlf_output_id` BIGINT COMMENT 'Realized TLF output file.',
    `tlf_shell_id` BIGINT COMMENT 'TLF shell describing the display.',
    `created_timestamp` TIMESTAMP COMMENT 'Record creation timestamp.',
    `display_identifier` STRING COMMENT 'Output/display number identifier.',
    `display_type` STRING COMMENT 'Table, listing or figure.',
    `file_specification` STRING COMMENT 'File specification / path.',
    `ordinal` BIGINT COMMENT 'Order of the output within the reporting event.',
    `output_description` STRING COMMENT 'Description of the output.',
    `output_file_name` STRING COMMENT 'File name of the rendered output.',
    `output_label` STRING COMMENT 'Output label.',
    `output_name` STRING COMMENT 'Output name.',
    `output_type` STRING COMMENT 'Type of display (table, listing, figure).',
    `output_version` STRING COMMENT 'Output version.',
    `updated_timestamp` TIMESTAMP COMMENT 'Record last-updated timestamp.',
    `version` STRING COMMENT 'Version of the output.',
    CONSTRAINT pk_analysis_output PRIMARY KEY(`analysis_output_id`)
) COMMENT 'CDISC Analysis Results Standard Output: a displayable table, listing or figure produced from one or more analyses, tied to the TLF shell and TLF output.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_method` (
    `analysis_method_id` BIGINT COMMENT 'BIGINT',
    `adam_dataset_spec_id` BIGINT COMMENT 'description',
    `analysis_id` BIGINT COMMENT 'description',
    `analysis_population_id` BIGINT COMMENT 'description',
    `reporting_event_id` BIGINT COMMENT 'Owning reporting event.',
    `sap_id` BIGINT COMMENT 'the source system this method.',
    `tlf_output_id` BIGINT COMMENT 'description',
    `tlf_shell_id` BIGINT COMMENT 'description',
    `analysis_set_id` BIGINT COMMENT 'Non-FK reference to analysis set identifier for documentation purposes only; does not create circular dependency',
    `created_timestamp` TIMESTAMP COMMENT 'Record creation timestamp.',
    `method_description` STRING COMMENT 'Statistical description of the method.',
    `method_label` STRING COMMENT 'Method label.',
    `method_name` STRING COMMENT 'Method name.',
    `operation_definition` STRING COMMENT 'Operations the method performs.',
    `programming_language` STRING COMMENT 'Language of the programming statement (SAS, R).',
    `programming_reference` STRING COMMENT 'SAS/R code template reference.',
    `programming_statement` STRING COMMENT 'Programming/code template implementing the method.',
    `statistical_method` STRING COMMENT 'Statistical technique (ANCOVA, MMRM, logistic regression, etc.).',
    `statistical_technique` STRING COMMENT 'Statistical technique (e.g. MMRM, ANCOVA).',
    `updated_timestamp` TIMESTAMP COMMENT 'Record last-updated timestamp.',
    CONSTRAINT pk_analysis_method PRIMARY KEY(`analysis_method_id`)
) COMMENT 'CDISC Analysis Results Standard AnalysisMethod: a reusable statistical method (operations/programming steps) referenced by analyses.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` (
    `analysis_set_id` BIGINT COMMENT 'BIGINT',
    `adam_dataset_spec_id` BIGINT COMMENT 'description',
    `analysis_population_id` BIGINT COMMENT 'Analysis population the set is derived from.',
    `reporting_event_id` BIGINT COMMENT 'Owning reporting event.',
    `sap_id` BIGINT COMMENT 'the source system the analysis set.',
    `study_id` BIGINT COMMENT 'Study the analysis set belongs to.',
    `tlf_output_id` BIGINT COMMENT 'description',
    `tlf_shell_id` BIGINT COMMENT 'description',
    `condition_expression` STRING COMMENT 'Logical condition defining membership in the set.',
    `created_timestamp` TIMESTAMP COMMENT 'Record creation timestamp.',
    `analysis_set_description` STRING COMMENT 'Description of the analysis set.',
    `label` STRING COMMENT 'Label of the analysis set.',
    `analysis_set_name` STRING COMMENT 'Name of the analysis set. Implements CDISC ARS AnalysisSet.name.',
    `ordinal` BIGINT COMMENT 'Order of the set within the reporting event.',
    `set_condition` STRING COMMENT 'Condition expression defining membership.',
    `set_label` STRING COMMENT 'Analysis set label.',
    `set_level` STRING COMMENT 'Hierarchy level of the set.',
    `set_name` STRING COMMENT 'Analysis set name.',
    `set_order` BIGINT COMMENT 'Ordering within reporting event.',
    `updated_timestamp` TIMESTAMP COMMENT 'Record last-updated timestamp.',
    CONSTRAINT pk_analysis_set PRIMARY KEY(`analysis_set_id`)
) COMMENT 'CDISC Analysis Results Standard AnalysisSet: the subject population condition applied in analyses, linked to the governing analysis_population.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` (
    `reporting_event_id` BIGINT COMMENT 'BIGINT',
    `adam_dataset_spec_id` BIGINT COMMENT 'description',
    `analysis_population_id` BIGINT COMMENT 'description',
    `sap_id` BIGINT COMMENT 'the source system this reporting event.',
    `study_id` BIGINT COMMENT 'Study the reporting event belongs to.',
    `tlf_output_id` BIGINT COMMENT 'description',
    `tlf_shell_id` BIGINT COMMENT 'description',
    `ars_version` STRING COMMENT 'CDISC Analysis Results Standard version.',
    `created_timestamp` TIMESTAMP COMMENT 'Record creation timestamp.',
    `reporting_event_description` STRING COMMENT 'Free-text description of the reporting event.',
    `event_status` STRING COMMENT 'Lifecycle status (draft, approved, final).',
    `label` STRING COMMENT 'Descriptive label.',
    `reporting_event_name` STRING COMMENT 'Name of the reporting event.',
    `reporting_event_status` STRING COMMENT 'Lifecycle status.',
    `reporting_event_type` STRING COMMENT 'Deliverable type (CSR, interim, DSMB).',
    `updated_timestamp` TIMESTAMP COMMENT 'Record last-updated timestamp.',
    `version` STRING COMMENT 'Version of the reporting event.',
    CONSTRAINT pk_reporting_event PRIMARY KEY(`reporting_event_id`)
) COMMENT 'CDISC Analysis Results Standard ReportingEvent: the top-level container tying a the source system to a planned set of analyses and outputs.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` (
    `grouping_factor_id` BIGINT COMMENT 'BIGINT',
    `adam_dataset_spec_id` BIGINT COMMENT 'description',
    `analysis_id` BIGINT COMMENT 'Analysis the grouping factor applies to.',
    `analysis_population_id` BIGINT COMMENT 'description',
    `reporting_event_id` BIGINT COMMENT 'Owning reporting event.',
    `sap_id` BIGINT COMMENT 'the source system the grouping factor.',
    `tlf_output_id` BIGINT COMMENT 'description',
    `tlf_shell_id` BIGINT COMMENT 'description',
    `created_timestamp` TIMESTAMP COMMENT 'Record creation timestamp.',
    `data_driven_flag` BOOLEAN COMMENT 'Whether groups are data-driven.',
    `group_value` DECIMAL(18,2) COMMENT 'Value/condition defining an individual group within the factor.',
    `group_values` STRING COMMENT 'Enumerated group values/levels.',
    `grouping_dataset` STRING COMMENT 'ADaM dataset carrying the grouping variable.',
    `grouping_description` STRING COMMENT 'Description of the grouping factor.',
    `grouping_label` STRING COMMENT 'Grouping factor label.',
    `grouping_name` STRING COMMENT 'Grouping factor name.',
    `grouping_variable` STRING COMMENT 'Variable used to group (e.g. TRT01P).',
    `ordinal` BIGINT COMMENT 'Order of the grouping factor.',
    `updated_timestamp` TIMESTAMP COMMENT 'Record last-updated timestamp.',
    CONSTRAINT pk_grouping_factor PRIMARY KEY(`grouping_factor_id`)
) COMMENT 'CDISC Analysis Results Standard AnalysisGrouping: a factor (treatment, subgroup) used to split analysis results into groups.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` (
    `analysis_id` BIGINT COMMENT 'BIGINT',
    `adam_dataset_spec_id` BIGINT COMMENT 'ADaM dataset spec the analysis sources from.',
    `analysis_population_id` BIGINT COMMENT 'Analysis population referenced by this analysis.',
    `analysis_set_id` BIGINT COMMENT 'The analysis set this analysis is performed on.',
    `estimand_id` BIGINT COMMENT 'add column estimand_id (BIGINT) with FK to biostatistics.estimand.estimand_id — per CDISC ARS, analysis should reference the estimand it addresses',
    `reporting_event_id` BIGINT COMMENT 'Owning reporting event.',
    `sap_id` BIGINT COMMENT 'the source system the analysis.',
    `study_id` BIGINT COMMENT 'Study the analysis belongs to.',
    `tlf_output_id` BIGINT COMMENT 'description',
    `tlf_shell_id` BIGINT COMMENT 'description',
    `parent_analysis_id` BIGINT COMMENT 'Self-reference for hierarchical analysis structure',
    `analysis_category` STRING COMMENT 'Category grouping of the analysis.',
    `created_timestamp` TIMESTAMP COMMENT 'Record creation timestamp.',
    `analysis_description` STRING COMMENT 'Description of the analysis.',
    `label` STRING COMMENT 'Analysis label.',
    `analysis_name` STRING COMMENT 'Analysis name.',
    `ordinal` BIGINT COMMENT 'Order of the analysis within the reporting event.',
    `purpose` STRING COMMENT 'Primary/secondary/exploratory purpose.',
    `reason` STRING COMMENT 'Reason for the analysis (prespecified, data-driven).',
    `updated_timestamp` TIMESTAMP COMMENT 'Record last-updated timestamp.',
    `variable` STRING COMMENT 'Analysis variable (e.g. parameter).',
    CONSTRAINT pk_analysis PRIMARY KEY(`analysis_id`)
) COMMENT 'CDISC Analysis Results Standard Analysis: a single planned statistical analysis within a reporting event, bound to a method, analysis set, dataset and endpoint.';

ALTER SCHEMA `clinical_trials_ecm`.`biostatistics` SET TAGS ('dbx_division' = 'operations');

ALTER SCHEMA `clinical_trials_ecm`.`biostatistics` SET TAGS ('dbx_domain' = 'biostatistics');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ADD CONSTRAINT `fk_biostatistics_sap_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ADD CONSTRAINT `fk_biostatistics_sap_blinding_config_id` FOREIGN KEY (`blinding_config_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`blinding_config`(`blinding_config_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ADD CONSTRAINT `fk_biostatistics_sap_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ADD CONSTRAINT `fk_biostatistics_sap_lead_statistician_employee_id` FOREIGN KEY (`lead_statistician_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ADD CONSTRAINT `fk_biostatistics_sap_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ADD CONSTRAINT `fk_biostatistics_sap_pipeline_asset_id` FOREIGN KEY (`pipeline_asset_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`pipeline_asset`(`pipeline_asset_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ADD CONSTRAINT `fk_biostatistics_sap_rand_scheme_id` FOREIGN KEY (`rand_scheme_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`rand_scheme`(`rand_scheme_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ADD CONSTRAINT `fk_biostatistics_sap_regulatory_strategy_id` FOREIGN KEY (`regulatory_strategy_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`strategy`(`strategy_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ADD CONSTRAINT `fk_biostatistics_sap_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ADD CONSTRAINT `fk_biostatistics_sap_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ADD CONSTRAINT `fk_biostatistics_sap_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` SET TAGS ('dbx_domain' = 'biostatistics');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` SET TAGS ('dbx_subdomain' = 'analysis_planning');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `blinding_config_id` SET TAGS ('dbx_business_glossary_term' = 'Blinding Config Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Program Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `lead_statistician_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Lead Statistician Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `lead_statistician_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `lead_statistician_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `lead_statistician_employee_id` SET TAGS ('dbx_pii_employee' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `pipeline_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Pipeline Asset Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `rand_scheme_id` SET TAGS ('dbx_business_glossary_term' = 'Rand Scheme Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `regulatory_strategy_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Regulatory Strategy Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `adam_dataset_specifications` SET TAGS ('dbx_business_glossary_term' = 'Analysis Data Model (ADaM) Dataset Specifications');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `amendment_number` SET TAGS ('dbx_business_glossary_term' = 'SAP Amendment Number');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `amendment_rationale` SET TAGS ('dbx_business_glossary_term' = 'SAP Amendment Rationale');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `analysis_type` SET TAGS ('dbx_business_glossary_term' = 'SAP Analysis Type');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `analysis_type` SET TAGS ('dbx_value_regex' = 'interim|final|post_hoc|exploratory');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'SAP Approval Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `authoring_system` SET TAGS ('dbx_business_glossary_term' = 'SAP Authoring System');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `authoring_system` SET TAGS ('dbx_value_regex' = 'SAS Drug Development|Veeva Vault|Word|other');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `blinding_status` SET TAGS ('dbx_business_glossary_term' = 'SAP Blinding Status');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `blinding_status` SET TAGS ('dbx_value_regex' = 'blinded|unblinded|partially_unblinded');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `blinding_status` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'SAP Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `dbl_date` SET TAGS ('dbx_business_glossary_term' = 'Database Lock (DBL) Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `dsmb_review_required` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Review Required Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'SAP Effective From Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'SAP Effective Until Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `estimand_description` SET TAGS ('dbx_implements' = 'ICH_E9(R1).Estimand');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `estimand_description` SET TAGS ('dbx_standard' = 'ICH_E9R1');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `interim_analysis_count` SET TAGS ('dbx_business_glossary_term' = 'Planned Interim Analysis Count');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `is_current_version` SET TAGS ('dbx_business_glossary_term' = 'Is Current Version Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `itt_population_definition` SET TAGS ('dbx_business_glossary_term' = 'Intent-to-Treat (ITT) Population Definition');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `itt_population_definition` SET TAGS ('dbx_implements' = 'ICH_E9.ITT');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `itt_population_definition` SET TAGS ('dbx_standard' = 'ICH_E9');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `missing_data_strategy` SET TAGS ('dbx_business_glossary_term' = 'Missing Data Handling Strategy');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `missing_data_strategy` SET TAGS ('dbx_implements' = 'ICH_E9(R1).IntercurrentEventStrategy');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `missing_data_strategy` SET TAGS ('dbx_standard' = 'ICH_E9R1');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `multiplicity_adjustment_method` SET TAGS ('dbx_implements' = 'ICH_E9.MultiplicityAdjustment');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `multiplicity_adjustment_method` SET TAGS ('dbx_standard' = 'ICH_E9');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `multiplicity_adjustment_method` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) Number');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `number` SET TAGS ('dbx_value_regex' = '^SAP-[A-Z0-9]{2,20}-[0-9]{3}$');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `power_percent` SET TAGS ('dbx_business_glossary_term' = 'Statistical Power Percentage');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `pp_population_definition` SET TAGS ('dbx_business_glossary_term' = 'Per Protocol (PP) Population Definition');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `pp_population_definition` SET TAGS ('dbx_implements' = 'ICH_E9.PerProtocol');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `pp_population_definition` SET TAGS ('dbx_standard' = 'ICH_E9');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `regulatory_impact` SET TAGS ('dbx_business_glossary_term' = 'SAP Regulatory Impact Classification');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `regulatory_impact` SET TAGS ('dbx_value_regex' = 'none|minor|major|requires_submission');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `safety_population_definition` SET TAGS ('dbx_business_glossary_term' = 'Safety Analysis Population Definition');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `safety_population_definition` SET TAGS ('dbx_implements' = 'ICH_E9.SafetyPopulation');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `safety_population_definition` SET TAGS ('dbx_standard' = 'ICH_E9');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `sample_size` SET TAGS ('dbx_business_glossary_term' = 'Planned Sample Size');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `sections_modified` SET TAGS ('dbx_business_glossary_term' = 'SAP Sections Modified');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `significance_level` SET TAGS ('dbx_business_glossary_term' = 'Statistical Significance Level (Alpha)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `significance_level` SET TAGS ('dbx_implements' = 'ICH_E9.SignificanceLevel');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `significance_level` SET TAGS ('dbx_standard' = 'ICH_E9');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'SAP Title');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `tlf_specifications` SET TAGS ('dbx_business_glossary_term' = 'Tables, Listings, and Figures (TLF) Specifications');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `unblinding_date` SET TAGS ('dbx_business_glossary_term' = 'SAP Unblinding Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `unblinding_date` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'SAP Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'SAP Version Number');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+(.[0-9]+)?$');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `version_status` SET TAGS ('dbx_business_glossary_term' = 'SAP Version Status');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap` ALTER COLUMN `version_status` SET TAGS ('dbx_value_regex' = 'draft|in_review|approved|superseded|retired');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ADD CONSTRAINT `fk_biostatistics_sap_amendment_approver_employee_id` FOREIGN KEY (`approver_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ADD CONSTRAINT `fk_biostatistics_sap_amendment_audit_finding_id` FOREIGN KEY (`audit_finding_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`audit_finding`(`audit_finding_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ADD CONSTRAINT `fk_biostatistics_sap_amendment_change_order_id` FOREIGN KEY (`change_order_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`change_order`(`change_order_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ADD CONSTRAINT `fk_biostatistics_sap_amendment_icf_amendment_id` FOREIGN KEY (`icf_amendment_id`) REFERENCES `clinical_trials_ecm`.`consent`.`icf_amendment`(`icf_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ADD CONSTRAINT `fk_biostatistics_sap_amendment_primary_sap_employee_id` FOREIGN KEY (`primary_sap_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ADD CONSTRAINT `fk_biostatistics_sap_amendment_regulatory_protocol_amendment_id` FOREIGN KEY (`regulatory_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment`(`regulatory_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ADD CONSTRAINT `fk_biostatistics_sap_amendment_reviewer_employee_id` FOREIGN KEY (`reviewer_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ADD CONSTRAINT `fk_biostatistics_sap_amendment_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ADD CONSTRAINT `fk_biostatistics_sap_amendment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ADD CONSTRAINT `fk_biostatistics_sap_amendment_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ADD CONSTRAINT `fk_biostatistics_sap_amendment_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ADD CONSTRAINT `fk_biostatistics_sap_amendment_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` SET TAGS ('dbx_domain' = 'biostatistics');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` SET TAGS ('dbx_subdomain' = 'analysis_planning');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `sap_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) Amendment ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `approver_employee_id` SET TAGS ('dbx_business_glossary_term' = 'SAP Amendment Approver ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `approver_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `approver_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `approver_employee_id` SET TAGS ('dbx_pii_employee' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `audit_finding_id` SET TAGS ('dbx_business_glossary_term' = 'Audit Finding Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `change_order_id` SET TAGS ('dbx_business_glossary_term' = 'Change Order Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `icf_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Icf Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `primary_sap_employee_id` SET TAGS ('dbx_business_glossary_term' = 'SAP Amendment Author ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `primary_sap_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `primary_sap_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `primary_sap_employee_id` SET TAGS ('dbx_pii_employee' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `regulatory_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `reviewer_employee_id` SET TAGS ('dbx_business_glossary_term' = 'SAP Amendment Reviewer ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `reviewer_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `reviewer_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `reviewer_employee_id` SET TAGS ('dbx_pii_employee' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Study Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'eTMF Document ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `adam_dataset_impact` SET TAGS ('dbx_business_glossary_term' = 'Analysis Data Model (ADaM) Dataset Impact');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `amendment_rationale` SET TAGS ('dbx_business_glossary_term' = 'SAP Amendment Rationale');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `amendment_status` SET TAGS ('dbx_business_glossary_term' = 'SAP Amendment Status');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `amendment_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|superseded|withdrawn');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `amendment_title` SET TAGS ('dbx_business_glossary_term' = 'SAP Amendment Title');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `amendment_type` SET TAGS ('dbx_business_glossary_term' = 'SAP Amendment Type');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `amendment_type` SET TAGS ('dbx_value_regex' = 'major|minor|administrative');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `amendment_version_code` SET TAGS ('dbx_business_glossary_term' = 'SAP Amendment Version Code');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `amendment_version_code` SET TAGS ('dbx_value_regex' = '^v[0-9]+.[0-9]+(.[0-9]+)?$');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `analysis_population_changed` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Changed Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'SAP Amendment Approval Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `approver_name` SET TAGS ('dbx_business_glossary_term' = 'SAP Amendment Approver Name');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `approver_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `approver_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `author_name` SET TAGS ('dbx_business_glossary_term' = 'SAP Amendment Author Name');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `author_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `author_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `authored_date` SET TAGS ('dbx_business_glossary_term' = 'SAP Amendment Authored Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `blinding_impact` SET TAGS ('dbx_business_glossary_term' = 'Blinding Impact Classification');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `blinding_impact` SET TAGS ('dbx_value_regex' = 'none|potential_unblinding|unblinding_required');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `change_summary` SET TAGS ('dbx_business_glossary_term' = 'SAP Amendment Change Summary');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `dbl_date` SET TAGS ('dbx_business_glossary_term' = 'Database Lock (DBL) Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `dsmb_notification_required` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Notification Required Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'SAP Amendment Effective Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `interim_analysis_changed` SET TAGS ('dbx_business_glossary_term' = 'Interim Analysis Changed Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `irb_iec_notification_required` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Notification Required Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `missing_data_method_changed` SET TAGS ('dbx_business_glossary_term' = 'Missing Data Handling Method Changed Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `pre_dbl_flag` SET TAGS ('dbx_business_glossary_term' = 'Pre-Database Lock (DBL) Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `primary_endpoint_changed` SET TAGS ('dbx_business_glossary_term' = 'Primary Endpoint Changed Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `randomization_scheme_changed` SET TAGS ('dbx_business_glossary_term' = 'Randomization Scheme Changed Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `regulatory_impact_assessment` SET TAGS ('dbx_value_regex' = 'none|low|medium|high|critical');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `regulatory_notification_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Notification Required Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `review_completed_date` SET TAGS ('dbx_business_glossary_term' = 'SAP Amendment Review Completed Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `sample_size_changed` SET TAGS ('dbx_business_glossary_term' = 'Sample Size Changed Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `sas_program_reference` SET TAGS ('dbx_business_glossary_term' = 'SAS Drug Development Program Reference');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `sections_modified` SET TAGS ('dbx_business_glossary_term' = 'SAP Sections Modified');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `sponsor_signatory_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `sponsor_signatory_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `superseded_date` SET TAGS ('dbx_business_glossary_term' = 'SAP Amendment Superseded Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `tlf_impact` SET TAGS ('dbx_business_glossary_term' = 'Tables, Listings, and Figures (TLF) Impact');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sap_amendment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ADD CONSTRAINT `fk_biostatistics_analysis_population_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ADD CONSTRAINT `fk_biostatistics_analysis_population_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` SET TAGS ('dbx_domain' = 'biostatistics');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` SET TAGS ('dbx_subdomain' = 'analysis_planning');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `acronym` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Acronym');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `acronym` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,10}$');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `adam_dataset_name` SET TAGS ('dbx_business_glossary_term' = 'Analysis Data Model (ADaM) Dataset Name');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `adam_dataset_name` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,8}$');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `adam_dataset_name` SET TAGS ('dbx_implements' = 'ADaMIG.DatasetName');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `adam_dataset_name` SET TAGS ('dbx_standard' = 'CDISC_ADaM');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `adam_dataset_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `adsl_flag_variable` SET TAGS ('dbx_business_glossary_term' = 'Analysis Data Subject-Level (ADSL) Flag Variable Name');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `adsl_flag_variable` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,8}FL$');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `adsl_flag_variable` SET TAGS ('dbx_implements' = 'ADaMIG.ADSL.PopulationFlag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `adsl_flag_variable` SET TAGS ('dbx_standard' = 'CDISC_ADaM');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `analysis_phase` SET TAGS ('dbx_value_regex' = 'interim|final|post_hoc|exploratory');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `blinding_status` SET TAGS ('dbx_value_regex' = 'blinded|unblinded|open_label');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `cdisc_standard_version` SET TAGS ('dbx_business_glossary_term' = 'Clinical Data Interchange Standards Consortium (CDISC) Standard Version');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `cdisc_standard_version` SET TAGS ('dbx_implements' = 'ADaMIG.Version');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `cdisc_standard_version` SET TAGS ('dbx_standard' = 'CDISC_ADaM');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `dbl_date` SET TAGS ('dbx_business_glossary_term' = 'Database Lock (DBL) Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `effective_from_date` SET TAGS ('dbx_business_glossary_term' = 'Population Definition Effective From Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `exclusion_criteria_description` SET TAGS ('dbx_business_glossary_term' = 'Population Exclusion Criteria Description');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `inclusion_criteria_description` SET TAGS ('dbx_business_glossary_term' = 'Population Inclusion Criteria Description');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `missing_endpoint_handling` SET TAGS ('dbx_business_glossary_term' = 'Missing Endpoint Handling Method');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `missing_endpoint_handling` SET TAGS ('dbx_value_regex' = 'locf|bocf|wocf|multiple_imputation|observed_cases|none');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Notes');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `population_code` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Code');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `population_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,20}$');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `population_finalized_date` SET TAGS ('dbx_business_glossary_term' = 'Population Definition Finalized Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `population_name` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Name');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `population_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `population_rationale` SET TAGS ('dbx_business_glossary_term' = 'Population Definition Rationale');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `population_status` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Status');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `population_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|superseded|retired');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `population_type` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Type');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `population_type` SET TAGS ('dbx_implements' = 'ICH_E9.AnalysisPopulation');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `population_type` SET TAGS ('dbx_standard' = 'ICH_E9');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `primary_population_flag` SET TAGS ('dbx_business_glossary_term' = 'Primary Analysis Population Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `regulatory_primary_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Primary Population Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `sap_section_reference` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) Section Reference');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `sap_version` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) Version');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `sap_version` SET TAGS ('dbx_value_regex' = '^vd+.d+$');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `sas_program_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `sensitivity_analysis_flag` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Analysis Population Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `subject_count_at_dbl` SET TAGS ('dbx_business_glossary_term' = 'Subject Count at Database Lock (DBL)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `subject_count_interim` SET TAGS ('dbx_business_glossary_term' = 'Subject Count at Interim Analysis');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `submission_population_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission Population Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `tlf_shell_reference` SET TAGS ('dbx_business_glossary_term' = 'Tables, Listings, and Figures (TLF) Shell Reference');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `validation_status` SET TAGS ('dbx_business_glossary_term' = 'ADaM Validation Status');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_population` ALTER COLUMN `validation_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|validated|failed');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ADD CONSTRAINT `fk_biostatistics_sample_size_calc_analysis_population_id` FOREIGN KEY (`analysis_population_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`analysis_population`(`analysis_population_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ADD CONSTRAINT `fk_biostatistics_sample_size_calc_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ADD CONSTRAINT `fk_biostatistics_sample_size_calc_pipeline_asset_id` FOREIGN KEY (`pipeline_asset_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`pipeline_asset`(`pipeline_asset_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ADD CONSTRAINT `fk_biostatistics_sample_size_calc_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ADD CONSTRAINT `fk_biostatistics_sample_size_calc_rand_scheme_id` FOREIGN KEY (`rand_scheme_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`rand_scheme`(`rand_scheme_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ADD CONSTRAINT `fk_biostatistics_sample_size_calc_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ADD CONSTRAINT `fk_biostatistics_sample_size_calc_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` SET TAGS ('dbx_domain' = 'biostatistics');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` SET TAGS ('dbx_subdomain' = 'analysis_planning');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `sample_size_calc_id` SET TAGS ('dbx_business_glossary_term' = 'Sample Size Calculation ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `analysis_population_id` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii_employee' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `pipeline_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Pipeline Asset Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `rand_scheme_id` SET TAGS ('dbx_business_glossary_term' = 'Rand Scheme Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `accrual_period_months` SET TAGS ('dbx_business_glossary_term' = 'Assumed Accrual Period (Months)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `alpha_level` SET TAGS ('dbx_business_glossary_term' = 'Alpha Level (Type I Error Rate)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `alpha_spending_method` SET TAGS ('dbx_value_regex' = 'OBrien_Fleming|Pocock|Lan_DeMets|Haybittle_Peto|none');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `calc_date` SET TAGS ('dbx_business_glossary_term' = 'Calculation Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `calc_identifier` SET TAGS ('dbx_business_glossary_term' = 'Calculation Identifier');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `calc_status` SET TAGS ('dbx_business_glossary_term' = 'Calculation Status');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `calc_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|superseded|archived');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `calc_version` SET TAGS ('dbx_business_glossary_term' = 'Calculation Version');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `calc_version` SET TAGS ('dbx_value_regex' = '^vd+.d+$');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `dropout_rate` SET TAGS ('dbx_business_glossary_term' = 'Assumed Dropout Rate');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `effect_size` SET TAGS ('dbx_business_glossary_term' = 'Assumed Effect Size');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `event_rate_control` SET TAGS ('dbx_business_glossary_term' = 'Assumed Event Rate (Control Arm)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `event_rate_treatment` SET TAGS ('dbx_business_glossary_term' = 'Assumed Event Rate (Treatment Arm)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `event_rate_treatment` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `event_rate_treatment` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `follow_up_period_months` SET TAGS ('dbx_business_glossary_term' = 'Assumed Follow-Up Period (Months)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `hypothesis_type` SET TAGS ('dbx_value_regex' = 'superiority|non_inferiority|equivalence|one_sided|two_sided');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `interim_analysis_planned` SET TAGS ('dbx_business_glossary_term' = 'Interim Analysis Planned Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `median_survival_control` SET TAGS ('dbx_business_glossary_term' = 'Assumed Median Survival (Control Arm)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `non_inferiority_margin` SET TAGS ('dbx_business_glossary_term' = 'Non-Inferiority Margin');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `number_of_arms` SET TAGS ('dbx_business_glossary_term' = 'Number of Treatment Arms');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `power` SET TAGS ('dbx_business_glossary_term' = 'Statistical Power (1 - Beta)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `primary_endpoint_type` SET TAGS ('dbx_value_regex' = 'continuous|binary|time_to_event|ordinal|count');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `reference_source` SET TAGS ('dbx_business_glossary_term' = 'Assumption Reference Source');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `sample_size_per_arm` SET TAGS ('dbx_business_glossary_term' = 'Calculated Sample Size Per Arm');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `software_name` SET TAGS ('dbx_business_glossary_term' = 'Statistical Software Name');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `software_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `software_version` SET TAGS ('dbx_business_glossary_term' = 'Statistical Software Version');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `standard_deviation` SET TAGS ('dbx_business_glossary_term' = 'Assumed Standard Deviation');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `statistical_method` SET TAGS ('dbx_business_glossary_term' = 'Statistical Method Applied');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `study_design_type` SET TAGS ('dbx_value_regex' = 'parallel|crossover|factorial|adaptive|basket|umbrella');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `study_phase` SET TAGS ('dbx_value_regex' = 'Phase I|Phase II|Phase IIa|Phase IIb|Phase III|Phase IV');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `test_sidedness` SET TAGS ('dbx_value_regex' = 'one_sided|two_sided');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `total_sample_size` SET TAGS ('dbx_business_glossary_term' = 'Total Calculated Sample Size');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ADD CONSTRAINT `fk_biostatistics_adam_dataset_spec_analysis_population_id` FOREIGN KEY (`analysis_population_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`analysis_population`(`analysis_population_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ADD CONSTRAINT `fk_biostatistics_adam_dataset_spec_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ADD CONSTRAINT `fk_biostatistics_adam_dataset_spec_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ADD CONSTRAINT `fk_biostatistics_adam_dataset_spec_sdtm_dataset_id` FOREIGN KEY (`sdtm_dataset_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`sdtm_dataset`(`sdtm_dataset_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ADD CONSTRAINT `fk_biostatistics_adam_dataset_spec_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` SET TAGS ('dbx_domain' = 'biostatistics');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` SET TAGS ('dbx_subdomain' = 'dataset_specification');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `adam_dataset_spec_id` SET TAGS ('dbx_business_glossary_term' = 'Analysis Data Model (ADaM) Dataset Specification ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `analysis_population_id` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii_employee' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `sdtm_dataset_id` SET TAGS ('dbx_business_glossary_term' = 'Sdtm Dataset Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `adam_ig_version` SET TAGS ('dbx_business_glossary_term' = 'ADaM Implementation Guide (IG) Version');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `adam_ig_version` SET TAGS ('dbx_implements' = 'ADaMIG.Version');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `adam_ig_version` SET TAGS ('dbx_standard' = 'CDISC_ADaM');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Specification Approval Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `authored_by` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `authored_by` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `blinding_status` SET TAGS ('dbx_value_regex' = 'Blinded|Unblinded|Open-Label');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `blinding_status` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `codelist_name` SET TAGS ('dbx_implements' = 'CDISC_CT.CodelistName');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `codelist_name` SET TAGS ('dbx_standard' = 'CDISC_CT');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `codelist_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `controlled_terminology` SET TAGS ('dbx_business_glossary_term' = 'Controlled Terminology Reference');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `controlled_terminology` SET TAGS ('dbx_implements' = 'CDISC_CT.Codelist');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `controlled_terminology` SET TAGS ('dbx_standard' = 'CDISC_CT');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `core_designation` SET TAGS ('dbx_business_glossary_term' = 'CDISC ADaM Core Designation');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `core_designation` SET TAGS ('dbx_value_regex' = 'Required|Expected|Permissible');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `core_designation` SET TAGS ('dbx_implements' = 'ADaMIG.Core');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `core_designation` SET TAGS ('dbx_standard' = 'CDISC_ADaM');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `dataset_class` SET TAGS ('dbx_business_glossary_term' = 'ADaM Dataset Class');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `dataset_class` SET TAGS ('dbx_value_regex' = 'ADSL|BDS|OCCDS|OTHER');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `dataset_class` SET TAGS ('dbx_implements' = 'ADaMIG.DatasetClass');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `dataset_class` SET TAGS ('dbx_standard' = 'CDISC_ADaM');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `dataset_label` SET TAGS ('dbx_business_glossary_term' = 'ADaM Dataset Label');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `dataset_label` SET TAGS ('dbx_implements' = 'ADaMIG.DatasetLabel');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `dataset_label` SET TAGS ('dbx_standard' = 'CDISC_ADaM');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `dataset_name` SET TAGS ('dbx_business_glossary_term' = 'ADaM Dataset Name');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `dataset_name` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,8}$');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `dataset_name` SET TAGS ('dbx_implements' = 'ADaMIG.DatasetName');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `dataset_name` SET TAGS ('dbx_standard' = 'CDISC_ADaM');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `dataset_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `dataset_purpose` SET TAGS ('dbx_business_glossary_term' = 'ADaM Dataset Purpose');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `define_xml_version` SET TAGS ('dbx_business_glossary_term' = 'Define-XML Version');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `define_xml_version` SET TAGS ('dbx_implements' = 'DefineXML.Version');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `define_xml_version` SET TAGS ('dbx_standard' = 'CDISC_DefineXML');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `derivation_algorithm` SET TAGS ('dbx_business_glossary_term' = 'Variable Derivation Algorithm');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `pinnacle21_validation_status` SET TAGS ('dbx_value_regex' = 'Pass|Pass with Warnings|Fail|Not Run');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `programming_language` SET TAGS ('dbx_value_regex' = 'SAS|R|Python|Other');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `programming_language` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `qc_method` SET TAGS ('dbx_business_glossary_term' = 'Quality Control (QC) Method');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `qc_method` SET TAGS ('dbx_value_regex' = 'Double Programming|Peer Review|Independent QC|Not Required');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `qc_status` SET TAGS ('dbx_business_glossary_term' = 'Quality Control (QC) Status');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `qc_status` SET TAGS ('dbx_value_regex' = 'Not Started|In Progress|QC Complete|Failed QC');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `spec_status` SET TAGS ('dbx_business_glossary_term' = 'Specification Lifecycle Status');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `spec_status` SET TAGS ('dbx_value_regex' = 'Draft|Under Review|Approved|Superseded|Retired');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `spec_version` SET TAGS ('dbx_business_glossary_term' = 'Specification Version');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `spec_version` SET TAGS ('dbx_value_regex' = '^d+.d+$');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `submission_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `variable_label` SET TAGS ('dbx_business_glossary_term' = 'ADaM Variable Label');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `variable_label` SET TAGS ('dbx_implements' = 'ADaMIG.VariableLabel');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `variable_label` SET TAGS ('dbx_standard' = 'CDISC_ADaM');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `variable_length` SET TAGS ('dbx_business_glossary_term' = 'ADaM Variable Length');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `variable_name` SET TAGS ('dbx_business_glossary_term' = 'ADaM Variable Name');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `variable_name` SET TAGS ('dbx_value_regex' = '^[A-Z][A-Z0-9]{0,7}$');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `variable_name` SET TAGS ('dbx_implements' = 'ADaMIG.VariableName');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `variable_name` SET TAGS ('dbx_standard' = 'CDISC_ADaM');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `variable_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `variable_type` SET TAGS ('dbx_business_glossary_term' = 'ADaM Variable Type');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `variable_type` SET TAGS ('dbx_value_regex' = 'Char|Num');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `variable_type` SET TAGS ('dbx_implements' = 'ADaMIG.VariableType');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `variable_type` SET TAGS ('dbx_standard' = 'CDISC_ADaM');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ADD CONSTRAINT `fk_biostatistics_adam_variable_spec_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ADD CONSTRAINT `fk_biostatistics_adam_variable_spec_lab_analyte_id` FOREIGN KEY (`lab_analyte_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_analyte`(`lab_analyte_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ADD CONSTRAINT `fk_biostatistics_adam_variable_spec_primary_adam_dataset_spec_id` FOREIGN KEY (`primary_adam_dataset_spec_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec`(`adam_dataset_spec_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ADD CONSTRAINT `fk_biostatistics_adam_variable_spec_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ADD CONSTRAINT `fk_biostatistics_adam_variable_spec_stratification_factor_id` FOREIGN KEY (`stratification_factor_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`stratification_factor`(`stratification_factor_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ADD CONSTRAINT `fk_biostatistics_adam_variable_spec_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` SET TAGS ('dbx_domain' = 'biostatistics');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` SET TAGS ('dbx_subdomain' = 'dataset_specification');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `adam_variable_spec_id` SET TAGS ('dbx_business_glossary_term' = 'Analysis Data Model (ADaM) Variable Specification ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii_employee' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `lab_analyte_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Analyte Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `primary_adam_dataset_spec_id` SET TAGS ('dbx_business_glossary_term' = 'Analysis Data Model (ADaM) Dataset ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `stratification_factor_id` SET TAGS ('dbx_business_glossary_term' = 'Stratification Factor Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `adam_structure` SET TAGS ('dbx_business_glossary_term' = 'ADaM Dataset Structure');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `adam_structure` SET TAGS ('dbx_value_regex' = 'ADSL|BDS|OCCDS|OTHER');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `adam_structure` SET TAGS ('dbx_implements' = 'ADaMIG.Structure');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `adam_structure` SET TAGS ('dbx_standard' = 'CDISC_ADaM');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Specification Approval Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `baseline_flag` SET TAGS ('dbx_business_glossary_term' = 'Baseline Flag Variable Reference');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `baseline_flag` SET TAGS ('dbx_implements' = 'ADaMIG.ABLFL');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `baseline_flag` SET TAGS ('dbx_standard' = 'CDISC_ADaM');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `change_from_baseline_var` SET TAGS ('dbx_business_glossary_term' = 'Change from Baseline Variable Name');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `change_from_baseline_var` SET TAGS ('dbx_implements' = 'ADaMIG.CHG');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `change_from_baseline_var` SET TAGS ('dbx_standard' = 'CDISC_ADaM');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `codelist_name` SET TAGS ('dbx_business_glossary_term' = 'CDISC Codelist Name');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `codelist_name` SET TAGS ('dbx_implements' = 'CDISC_CT.CodelistName');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `codelist_name` SET TAGS ('dbx_standard' = 'CDISC_CT');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `codelist_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Variable Specification Comments');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `controlled_terminology_ref` SET TAGS ('dbx_business_glossary_term' = 'Controlled Terminology Reference');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `controlled_terminology_ref` SET TAGS ('dbx_implements' = 'CDISC_CT.Codelist');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `controlled_terminology_ref` SET TAGS ('dbx_standard' = 'CDISC_CT');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `core_designation` SET TAGS ('dbx_business_glossary_term' = 'CDISC ADaM Core Designation');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `core_designation` SET TAGS ('dbx_value_regex' = 'Required|Expected|Permissible|Conditionally Required');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `core_designation` SET TAGS ('dbx_implements' = 'ADaMIG.Core');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `core_designation` SET TAGS ('dbx_standard' = 'CDISC_ADaM');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `define_xml_display_format` SET TAGS ('dbx_business_glossary_term' = 'DEFINE-XML Display Format');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `derivation_algorithm` SET TAGS ('dbx_business_glossary_term' = 'ADaM Variable Derivation Algorithm');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `estimand_reference` SET TAGS ('dbx_implements' = 'ICH_E9(R1).Estimand');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `estimand_reference` SET TAGS ('dbx_standard' = 'ICH_E9R1');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `format_name` SET TAGS ('dbx_business_glossary_term' = 'SAS Format Name');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `format_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `is_analysis_variable` SET TAGS ('dbx_business_glossary_term' = 'Analysis Variable Indicator');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `is_key_variable` SET TAGS ('dbx_business_glossary_term' = 'Key Variable Indicator');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `is_param_variable` SET TAGS ('dbx_business_glossary_term' = 'Parameter Variable Indicator');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `origin` SET TAGS ('dbx_business_glossary_term' = 'Variable Origin');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `origin` SET TAGS ('dbx_value_regex' = 'Derived|Assigned|Collected|Protocol|Not Available');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `population_flag` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `predecessor_variable` SET TAGS ('dbx_business_glossary_term' = 'Predecessor Variable Name');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `qc_date` SET TAGS ('dbx_business_glossary_term' = 'Quality Control (QC) Completion Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `qc_programmer` SET TAGS ('dbx_business_glossary_term' = 'Quality Control (QC) Programmer');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `qc_programmer` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `qc_programmer` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `qc_status` SET TAGS ('dbx_business_glossary_term' = 'Quality Control (QC) Status');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `qc_status` SET TAGS ('dbx_value_regex' = 'Draft|Under QC|QC Passed|QC Failed|Approved|Locked');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `source_dataset` SET TAGS ('dbx_business_glossary_term' = 'ADaM Source Dataset Name');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `source_variables` SET TAGS ('dbx_business_glossary_term' = 'ADaM Source Variable(s)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `spec_status` SET TAGS ('dbx_business_glossary_term' = 'Variable Specification Status');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `spec_status` SET TAGS ('dbx_value_regex' = 'Draft|In Review|Approved|Superseded|Retired');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `spec_version` SET TAGS ('dbx_business_glossary_term' = 'Variable Specification Version');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `spec_version` SET TAGS ('dbx_value_regex' = '^vd+.d+$');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `variable_label` SET TAGS ('dbx_business_glossary_term' = 'ADaM Variable Label');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `variable_label` SET TAGS ('dbx_implements' = 'ADaMIG.VariableLabel');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `variable_label` SET TAGS ('dbx_standard' = 'CDISC_ADaM');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `variable_length` SET TAGS ('dbx_business_glossary_term' = 'ADaM Variable Length');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `variable_name` SET TAGS ('dbx_business_glossary_term' = 'ADaM Variable Name');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `variable_name` SET TAGS ('dbx_value_regex' = '^[A-Z][A-Z0-9]{0,7}$');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `variable_name` SET TAGS ('dbx_implements' = 'ADaMIG.VariableName');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `variable_name` SET TAGS ('dbx_standard' = 'CDISC_ADaM');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `variable_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `variable_order` SET TAGS ('dbx_business_glossary_term' = 'Variable Order in Dataset');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `variable_role` SET TAGS ('dbx_business_glossary_term' = 'ADaM Variable Role');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `variable_role` SET TAGS ('dbx_implements' = 'ADaMIG.VariableRole');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `variable_role` SET TAGS ('dbx_standard' = 'CDISC_ADaM');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `variable_type` SET TAGS ('dbx_business_glossary_term' = 'ADaM Variable Data Type');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `variable_type` SET TAGS ('dbx_value_regex' = 'Character|Numeric');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `variable_type` SET TAGS ('dbx_implements' = 'ADaMIG.VariableType');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`adam_variable_spec` ALTER COLUMN `variable_type` SET TAGS ('dbx_standard' = 'CDISC_ADaM');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ADD CONSTRAINT `fk_biostatistics_tlf_shell_adam_dataset_spec_id` FOREIGN KEY (`adam_dataset_spec_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec`(`adam_dataset_spec_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ADD CONSTRAINT `fk_biostatistics_tlf_shell_analysis_population_id` FOREIGN KEY (`analysis_population_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`analysis_population`(`analysis_population_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ADD CONSTRAINT `fk_biostatistics_tlf_shell_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_ecm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ADD CONSTRAINT `fk_biostatistics_tlf_shell_endpoint_id` FOREIGN KEY (`endpoint_id`) REFERENCES `clinical_trials_ecm`.`study`.`endpoint`(`endpoint_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ADD CONSTRAINT `fk_biostatistics_tlf_shell_randomization_treatment_arm_id` FOREIGN KEY (`randomization_treatment_arm_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`treatment_arm`(`treatment_arm_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ADD CONSTRAINT `fk_biostatistics_tlf_shell_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ADD CONSTRAINT `fk_biostatistics_tlf_shell_shell_author_employee_id` FOREIGN KEY (`shell_author_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ADD CONSTRAINT `fk_biostatistics_tlf_shell_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` SET TAGS ('dbx_domain' = 'biostatistics');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` SET TAGS ('dbx_subdomain' = 'dataset_specification');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `tlf_shell_id` SET TAGS ('dbx_business_glossary_term' = 'Table Listing Figure (TLF) Shell ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `adam_dataset_spec_id` SET TAGS ('dbx_business_glossary_term' = 'Adam Dataset Spec Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `analysis_population_id` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `arm_id` SET TAGS ('dbx_business_glossary_term' = 'Study Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `endpoint_id` SET TAGS ('dbx_business_glossary_term' = 'Study Endpoint Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `randomization_treatment_arm_id` SET TAGS ('dbx_business_glossary_term' = 'Randomization Treatment Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `randomization_treatment_arm_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `randomization_treatment_arm_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `shell_author_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Shell Author Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `shell_author_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `shell_author_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `shell_author_employee_id` SET TAGS ('dbx_pii_employee' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `abbreviations` SET TAGS ('dbx_business_glossary_term' = 'TLF Abbreviations List');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `analysis_timepoint` SET TAGS ('dbx_value_regex' = 'interim|final|both');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `analysis_visit` SET TAGS ('dbx_business_glossary_term' = 'Analysis Visit Window');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `approved_by` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `approved_by` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `blinding_status` SET TAGS ('dbx_business_glossary_term' = 'TLF Blinding Status');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `blinding_status` SET TAGS ('dbx_value_regex' = 'blinded|unblinded|open_label');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `blinding_status` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `change_reason` SET TAGS ('dbx_business_glossary_term' = 'Shell Change Reason');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `csr_section_reference` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study Report (CSR) Section Reference');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `ctcae_version` SET TAGS ('dbx_business_glossary_term' = 'Common Terminology Criteria for Adverse Events (CTCAE) Version');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `ctcae_version` SET TAGS ('dbx_implements' = 'CTCAE.Version');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `ctcae_version` SET TAGS ('dbx_standard' = 'NCI_CTCAE');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `display_format` SET TAGS ('dbx_business_glossary_term' = 'TLF Display Format');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `display_format` SET TAGS ('dbx_value_regex' = 'rtf|pdf|sas7bdat|xlsx');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `footnotes` SET TAGS ('dbx_business_glossary_term' = 'TLF Footnotes');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `is_primary_endpoint` SET TAGS ('dbx_business_glossary_term' = 'Primary Endpoint Indicator');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `is_regulatory_submission` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission Indicator');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `locf_flag` SET TAGS ('dbx_business_glossary_term' = 'Last Observation Carried Forward (LOCF) Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `meddra_soc` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) System Organ Class (SOC)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `meddra_soc` SET TAGS ('dbx_implements' = 'MedDRA.SOC');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `meddra_soc` SET TAGS ('dbx_standard' = 'MedDRA');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `orientation` SET TAGS ('dbx_business_glossary_term' = 'Page Orientation');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `orientation` SET TAGS ('dbx_value_regex' = 'portrait|landscape');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `output_category` SET TAGS ('dbx_business_glossary_term' = 'TLF Output Category');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `output_file_name` SET TAGS ('dbx_business_glossary_term' = 'TLF Output File Name');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `output_file_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `output_finalized_date` SET TAGS ('dbx_business_glossary_term' = 'TLF Output Finalized Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `output_number` SET TAGS ('dbx_business_glossary_term' = 'TLF Output Number');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `output_number` SET TAGS ('dbx_value_regex' = '^[A-Z]{1,3}-[0-9]{1,3}(.[0-9]{1,3})?$');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `output_title` SET TAGS ('dbx_business_glossary_term' = 'TLF Output Title');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `output_type` SET TAGS ('dbx_business_glossary_term' = 'TLF Output Type');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `output_type` SET TAGS ('dbx_value_regex' = 'table|listing|figure');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `page_size` SET TAGS ('dbx_value_regex' = 'A4|letter|legal');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `page_size` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `priority_tier` SET TAGS ('dbx_business_glossary_term' = 'TLF Priority Tier');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `priority_tier` SET TAGS ('dbx_value_regex' = 'tier_1|tier_2|tier_3');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `production_status` SET TAGS ('dbx_business_glossary_term' = 'TLF Production Status');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `production_status` SET TAGS ('dbx_value_regex' = 'draft|in_development|qc_review|approved|final|superseded');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `program_name` SET TAGS ('dbx_business_glossary_term' = 'SAS Program Name');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `program_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `program_path` SET TAGS ('dbx_business_glossary_term' = 'SAS Program File Path');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `qc_reviewer` SET TAGS ('dbx_business_glossary_term' = 'Quality Control (QC) Reviewer');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `qc_reviewer` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `qc_reviewer` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `sap_section_reference` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) Section Reference');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `shell_approved_date` SET TAGS ('dbx_business_glossary_term' = 'TLF Shell Approved Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `shell_created_date` SET TAGS ('dbx_business_glossary_term' = 'TLF Shell Created Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `shell_notes` SET TAGS ('dbx_business_glossary_term' = 'TLF Shell Notes');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `shell_version` SET TAGS ('dbx_business_glossary_term' = 'TLF Shell Version');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `shell_version` SET TAGS ('dbx_value_regex' = '^v[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_shell` ALTER COLUMN `statistical_method` SET TAGS ('dbx_business_glossary_term' = 'Statistical Method Description');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ADD CONSTRAINT `fk_biostatistics_tlf_output_adam_dataset_spec_id` FOREIGN KEY (`adam_dataset_spec_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec`(`adam_dataset_spec_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ADD CONSTRAINT `fk_biostatistics_tlf_output_analysis_population_id` FOREIGN KEY (`analysis_population_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`analysis_population`(`analysis_population_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ADD CONSTRAINT `fk_biostatistics_tlf_output_approver_employee_id` FOREIGN KEY (`approver_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ADD CONSTRAINT `fk_biostatistics_tlf_output_deliverable_id` FOREIGN KEY (`deliverable_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`deliverable`(`deliverable_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ADD CONSTRAINT `fk_biostatistics_tlf_output_interim_analysis_id` FOREIGN KEY (`interim_analysis_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`interim_analysis`(`interim_analysis_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ADD CONSTRAINT `fk_biostatistics_tlf_output_primary_tlf_employee_id` FOREIGN KEY (`primary_tlf_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ADD CONSTRAINT `fk_biostatistics_tlf_output_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ADD CONSTRAINT `fk_biostatistics_tlf_output_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ADD CONSTRAINT `fk_biostatistics_tlf_output_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ADD CONSTRAINT `fk_biostatistics_tlf_output_tlf_shell_id` FOREIGN KEY (`tlf_shell_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`tlf_shell`(`tlf_shell_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` SET TAGS ('dbx_domain' = 'biostatistics');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` SET TAGS ('dbx_subdomain' = 'results_production');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `tlf_output_id` SET TAGS ('dbx_business_glossary_term' = 'Table Listing Figure (TLF) Output ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `adam_dataset_spec_id` SET TAGS ('dbx_business_glossary_term' = 'Analysis Data Model (ADaM) Dataset ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `analysis_population_id` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `approver_employee_id` SET TAGS ('dbx_business_glossary_term' = 'TLF Approver ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `approver_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `approver_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `approver_employee_id` SET TAGS ('dbx_pii_employee' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `deliverable_id` SET TAGS ('dbx_business_glossary_term' = 'Deliverable Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `interim_analysis_id` SET TAGS ('dbx_business_glossary_term' = 'Interim Analysis Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `primary_tlf_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Statistical Programmer ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `primary_tlf_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `primary_tlf_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `primary_tlf_employee_id` SET TAGS ('dbx_pii_employee' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `tlf_shell_id` SET TAGS ('dbx_business_glossary_term' = 'Table Listing Figure (TLF) Shell ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `analysis_type` SET TAGS ('dbx_value_regex' = 'primary|secondary|exploratory|interim|sensitivity');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'TLF Approval Status');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|rejected|superseded');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'TLF Approval Timestamp');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `blinding_status` SET TAGS ('dbx_value_regex' = 'blinded|unblinded');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `blinding_status` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'TLF Output Comments');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `csr_section_reference` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study Report (CSR) Section Reference');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `dataset_lock_status` SET TAGS ('dbx_value_regex' = 'pre_lock|post_lock|interim');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `dataset_version` SET TAGS ('dbx_business_glossary_term' = 'ADaM Dataset Version');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `delivery_date` SET TAGS ('dbx_business_glossary_term' = 'TLF Delivery Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `discrepancy_count` SET TAGS ('dbx_business_glossary_term' = 'TLF Discrepancy Count');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `is_final_version` SET TAGS ('dbx_business_glossary_term' = 'Is Final Version Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `output_category` SET TAGS ('dbx_business_glossary_term' = 'TLF Output Category');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `output_file_format` SET TAGS ('dbx_business_glossary_term' = 'TLF Output File Format');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `output_file_format` SET TAGS ('dbx_value_regex' = 'RTF|PDF|SAS7BDAT|CSV|HTML|XLSX');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `output_file_name` SET TAGS ('dbx_business_glossary_term' = 'TLF Output File Name');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `output_file_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `output_file_path` SET TAGS ('dbx_business_glossary_term' = 'TLF Output File Path');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `output_number` SET TAGS ('dbx_business_glossary_term' = 'TLF Output Number');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `output_number` SET TAGS ('dbx_value_regex' = '^[A-Z]{1,3}-[0-9]{1,4}(.[0-9]{1,3})?$');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `output_title` SET TAGS ('dbx_business_glossary_term' = 'TLF Output Title');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `output_type` SET TAGS ('dbx_business_glossary_term' = 'TLF Output Type');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `output_type` SET TAGS ('dbx_value_regex' = 'table|listing|figure');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `output_version` SET TAGS ('dbx_business_glossary_term' = 'TLF Output Version');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `production_environment` SET TAGS ('dbx_value_regex' = 'development|validation|production');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `production_run_timestamp` SET TAGS ('dbx_business_glossary_term' = 'TLF Production Run Timestamp');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `qc_completion_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Quality Control (QC) Completion Timestamp');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `qc_status` SET TAGS ('dbx_business_glossary_term' = 'Quality Control (QC) Status');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `qc_status` SET TAGS ('dbx_value_regex' = 'pending|in_progress|passed|failed|waived');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `run_number` SET TAGS ('dbx_business_glossary_term' = 'Production Run Number');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `sas_program_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `sas_program_path` SET TAGS ('dbx_business_glossary_term' = 'SAS Program File Path');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `unblinding_authorization_ref` SET TAGS ('dbx_business_glossary_term' = 'Unblinding Authorization Reference');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `unblinding_authorization_ref` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `validation_method` SET TAGS ('dbx_business_glossary_term' = 'TLF Validation Method');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`tlf_output` ALTER COLUMN `validation_method` SET TAGS ('dbx_value_regex' = 'double_programming|peer_review|independent_review');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ADD CONSTRAINT `fk_biostatistics_interim_analysis_analysis_population_id` FOREIGN KEY (`analysis_population_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`analysis_population`(`analysis_population_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ADD CONSTRAINT `fk_biostatistics_interim_analysis_audit_id` FOREIGN KEY (`audit_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`audit`(`audit_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ADD CONSTRAINT `fk_biostatistics_interim_analysis_blinding_config_id` FOREIGN KEY (`blinding_config_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`blinding_config`(`blinding_config_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ADD CONSTRAINT `fk_biostatistics_interim_analysis_database_lock_event_id` FOREIGN KEY (`database_lock_event_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`database_lock_event`(`database_lock_event_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ADD CONSTRAINT `fk_biostatistics_interim_analysis_epoch_id` FOREIGN KEY (`epoch_id`) REFERENCES `clinical_trials_ecm`.`study`.`epoch`(`epoch_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ADD CONSTRAINT `fk_biostatistics_interim_analysis_pipeline_asset_id` FOREIGN KEY (`pipeline_asset_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`pipeline_asset`(`pipeline_asset_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ADD CONSTRAINT `fk_biostatistics_interim_analysis_rand_list_id` FOREIGN KEY (`rand_list_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`rand_list`(`rand_list_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ADD CONSTRAINT `fk_biostatistics_interim_analysis_regulatory_protocol_amendment_id` FOREIGN KEY (`regulatory_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment`(`regulatory_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ADD CONSTRAINT `fk_biostatistics_interim_analysis_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ADD CONSTRAINT `fk_biostatistics_interim_analysis_sdtm_dataset_id` FOREIGN KEY (`sdtm_dataset_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`sdtm_dataset`(`sdtm_dataset_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ADD CONSTRAINT `fk_biostatistics_interim_analysis_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ADD CONSTRAINT `fk_biostatistics_interim_analysis_study_protocol_milestone_id` FOREIGN KEY (`study_protocol_milestone_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_milestone`(`study_protocol_milestone_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ADD CONSTRAINT `fk_biostatistics_interim_analysis_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` SET TAGS ('dbx_domain' = 'biostatistics');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` SET TAGS ('dbx_subdomain' = 'results_production');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `analysis_population_id` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `audit_id` SET TAGS ('dbx_business_glossary_term' = 'Audit Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `blinding_config_id` SET TAGS ('dbx_business_glossary_term' = 'Blinding Config Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `database_lock_event_id` SET TAGS ('dbx_business_glossary_term' = 'Biostatistics Dbl Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `epoch_id` SET TAGS ('dbx_business_glossary_term' = 'Study Epoch Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `pipeline_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Pipeline Asset Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `rand_list_id` SET TAGS ('dbx_business_glossary_term' = 'Rand List Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `regulatory_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `sdtm_dataset_id` SET TAGS ('dbx_business_glossary_term' = 'Sdtm Dataset Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `study_protocol_milestone_id` SET TAGS ('dbx_business_glossary_term' = 'Study Milestone Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `actual_analysis_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Interim Analysis Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `adam_dataset_version` SET TAGS ('dbx_business_glossary_term' = 'Analysis Data Model (ADaM) Dataset Version');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `alpha_allocated` SET TAGS ('dbx_business_glossary_term' = 'Allocated Alpha (Type I Error)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `alpha_spending_function` SET TAGS ('dbx_value_regex' = 'obrien_fleming|pocock|lan_demets_obf|lan_demets_pocock|hwang_shih_decani|custom');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `alpha_spending_parameter` SET TAGS ('dbx_business_glossary_term' = 'Alpha Spending Function Parameter (Gamma)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `analysis_code` SET TAGS ('dbx_business_glossary_term' = 'Interim Analysis Code');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `analysis_code` SET TAGS ('dbx_value_regex' = '^IA-[A-Z0-9]{2,10}-[0-9]{3}$');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `analysis_number` SET TAGS ('dbx_business_glossary_term' = 'Interim Analysis Number');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `analysis_outcome` SET TAGS ('dbx_business_glossary_term' = 'Interim Analysis Outcome');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `analysis_outcome` SET TAGS ('dbx_value_regex' = 'continue|stop_efficacy|stop_futility|stop_safety|adapt|pending');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `analysis_status` SET TAGS ('dbx_business_glossary_term' = 'Interim Analysis Status');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `analysis_status` SET TAGS ('dbx_value_regex' = 'planned|in_progress|completed|cancelled|on_hold');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `analysis_type` SET TAGS ('dbx_business_glossary_term' = 'Interim Analysis Type');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `analysis_type` SET TAGS ('dbx_value_regex' = 'efficacy|futility|safety|adaptive|combined_efficacy_futility|administrative');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_value_regex' = 'restricted|confidential|internal|public');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `dsmb_involved` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) / Data Monitoring Committee (DMC) Involvement Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `dsmb_meeting_date` SET TAGS ('dbx_business_glossary_term' = 'DSMB/DMC Meeting Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `efficacy_boundary_value` SET TAGS ('dbx_business_glossary_term' = 'Efficacy Stopping Boundary Value');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `events_observed` SET TAGS ('dbx_business_glossary_term' = 'Events Observed at Interim');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `events_planned_total` SET TAGS ('dbx_business_glossary_term' = 'Total Planned Events');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `firewall_maintained` SET TAGS ('dbx_business_glossary_term' = 'Blinding Firewall Maintained Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `futility_boundary_binding` SET TAGS ('dbx_business_glossary_term' = 'Futility Boundary Binding Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `futility_boundary_value` SET TAGS ('dbx_business_glossary_term' = 'Futility Stopping Boundary Value');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `information_fraction_actual` SET TAGS ('dbx_business_glossary_term' = 'Actual Information Fraction');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `information_fraction_planned` SET TAGS ('dbx_business_glossary_term' = 'Planned Information Fraction');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Interim Analysis Notes');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `observed_p_value` SET TAGS ('dbx_business_glossary_term' = 'Observed P-Value');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `planned_analysis_date` SET TAGS ('dbx_business_glossary_term' = 'Planned Interim Analysis Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `regulatory_submission_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission Required Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `results_disclosed_externally` SET TAGS ('dbx_business_glossary_term' = 'External Results Disclosure Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `sample_size_reestimated` SET TAGS ('dbx_business_glossary_term' = 'Sample Size Re-estimation Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `sas_program_version` SET TAGS ('dbx_business_glossary_term' = 'SAS Drug Development Program Version');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `stopping_rule_triggered` SET TAGS ('dbx_business_glossary_term' = 'Stopping Rule Triggered Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `subjects_enrolled_at_cutoff` SET TAGS ('dbx_business_glossary_term' = 'Subjects Enrolled at Data Cutoff');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `unblinding_authorization_date` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `unblinding_scope` SET TAGS ('dbx_value_regex' = 'full|partial|none');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `unblinding_scope` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`interim_analysis` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ADD CONSTRAINT `fk_biostatistics_database_lock_event_dmp_id` FOREIGN KEY (`dmp_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`dmp`(`dmp_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ADD CONSTRAINT `fk_biostatistics_database_lock_event_primary_database_employee_id` FOREIGN KEY (`primary_database_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ADD CONSTRAINT `fk_biostatistics_database_lock_event_rand_list_id` FOREIGN KEY (`rand_list_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`rand_list`(`rand_list_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ADD CONSTRAINT `fk_biostatistics_database_lock_event_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ADD CONSTRAINT `fk_biostatistics_database_lock_event_study_protocol_milestone_id` FOREIGN KEY (`study_protocol_milestone_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_milestone`(`study_protocol_milestone_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ADD CONSTRAINT `fk_biostatistics_database_lock_event_tertiary_database_medical_monitor_approver_employee_id` FOREIGN KEY (`tertiary_database_medical_monitor_approver_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` SET TAGS ('dbx_domain' = 'biostatistics');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` SET TAGS ('dbx_subdomain' = 'results_production');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `database_lock_event_id` SET TAGS ('dbx_business_glossary_term' = 'Database Lock Event Identifier');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `primary_database_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Data Management (DM) Approver ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `primary_database_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `primary_database_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `primary_database_employee_id` SET TAGS ('dbx_pii_employee' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `rand_list_id` SET TAGS ('dbx_business_glossary_term' = 'Rand List Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `study_protocol_milestone_id` SET TAGS ('dbx_business_glossary_term' = 'Study Milestone Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `tertiary_database_medical_monitor_approver_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Medical Monitor Approver ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `tertiary_database_medical_monitor_approver_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `tertiary_database_medical_monitor_approver_employee_id` SET TAGS ('dbx_pii_employee' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `tertiary_database_medical_monitor_approver_employee_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `actual_lock_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Database Lock Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `amendment_number` SET TAGS ('dbx_business_glossary_term' = 'Post-Lock Amendment Number');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `amendment_reason` SET TAGS ('dbx_business_glossary_term' = 'Post-Lock Amendment Reason');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `analysis_type` SET TAGS ('dbx_value_regex' = 'interim_analysis|final_analysis|safety_review|ad_hoc|regulatory_submission');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `coding_complete` SET TAGS ('dbx_business_glossary_term' = 'Medical Coding Completion Status');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `data_cut_date` SET TAGS ('dbx_business_glossary_term' = 'Data Cut-Off Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `dbl_event_number` SET TAGS ('dbx_business_glossary_term' = 'Database Lock (DBL) Event Number');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `dm_approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Data Management (DM) Approval Timestamp');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `dmp_version` SET TAGS ('dbx_business_glossary_term' = 'Data Management Plan (DMP) Version');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `dsmb_notification_date` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Notification Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `dsmb_notification_required` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Notification Required Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `edc_system_lock_reference` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) System Lock Reference');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `lock_memo_reference` SET TAGS ('dbx_business_glossary_term' = 'Database Lock Memo Reference');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `lock_scope` SET TAGS ('dbx_business_glossary_term' = 'Database Lock Scope');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `lock_scope` SET TAGS ('dbx_value_regex' = 'full_study|interim|partial|cohort|site_specific');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `lock_status` SET TAGS ('dbx_business_glossary_term' = 'Database Lock Status');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `lock_status` SET TAGS ('dbx_value_regex' = 'planned|in_progress|locked|unlocked|re_locked|cancelled');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `lock_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Database Lock Timestamp');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `lock_type` SET TAGS ('dbx_business_glossary_term' = 'Database Lock Type');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `lock_type` SET TAGS ('dbx_value_regex' = 'hard|soft');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `medical_monitor_approval_timestamp` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `medical_monitor_approval_timestamp` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Database Lock Event Notes');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `outstanding_query_count` SET TAGS ('dbx_business_glossary_term' = 'Outstanding Query Count at Lock');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `planned_lock_date` SET TAGS ('dbx_business_glossary_term' = 'Planned Database Lock Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `pre_lock_qc_checklist_complete` SET TAGS ('dbx_business_glossary_term' = 'Pre-Lock Quality Control (QC) Checklist Completion Status');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `pre_lock_qc_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Pre-Lock Quality Control (QC) Checklist Completion Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `sae_reconciliation_complete` SET TAGS ('dbx_business_glossary_term' = 'Serious Adverse Event (SAE) Reconciliation Completion Status');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `sdv_complete` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Completion Status');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `study_part` SET TAGS ('dbx_business_glossary_term' = 'Study Part / Period');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `unblinding_required` SET TAGS ('dbx_business_glossary_term' = 'Unblinding Required Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `unlock_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Database Unlock Timestamp');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`database_lock_event` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ADD CONSTRAINT `fk_biostatistics_statistical_endpoint_adam_dataset_spec_id` FOREIGN KEY (`adam_dataset_spec_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec`(`adam_dataset_spec_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ADD CONSTRAINT `fk_biostatistics_statistical_endpoint_analysis_population_id` FOREIGN KEY (`analysis_population_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`analysis_population`(`analysis_population_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ADD CONSTRAINT `fk_biostatistics_statistical_endpoint_estimand_id` FOREIGN KEY (`estimand_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`estimand`(`estimand_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ADD CONSTRAINT `fk_biostatistics_statistical_endpoint_lab_analyte_id` FOREIGN KEY (`lab_analyte_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_analyte`(`lab_analyte_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ADD CONSTRAINT `fk_biostatistics_statistical_endpoint_protocol_endpoint_id` FOREIGN KEY (`protocol_endpoint_id`) REFERENCES `clinical_trials_ecm`.`study`.`endpoint`(`endpoint_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ADD CONSTRAINT `fk_biostatistics_statistical_endpoint_randomization_treatment_arm_id` FOREIGN KEY (`randomization_treatment_arm_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`treatment_arm`(`treatment_arm_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ADD CONSTRAINT `fk_biostatistics_statistical_endpoint_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ADD CONSTRAINT `fk_biostatistics_statistical_endpoint_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ADD CONSTRAINT `fk_biostatistics_statistical_endpoint_tlf_shell_id` FOREIGN KEY (`tlf_shell_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`tlf_shell`(`tlf_shell_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` SET TAGS ('dbx_domain' = 'biostatistics');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` SET TAGS ('dbx_subdomain' = 'analysis_planning');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `adam_dataset_spec_id` SET TAGS ('dbx_business_glossary_term' = 'Adam Dataset Spec Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `analysis_population_id` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `estimand_id` SET TAGS ('dbx_business_glossary_term' = 'Estimand Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `lab_analyte_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Analyte Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `protocol_endpoint_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Endpoint Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `randomization_treatment_arm_id` SET TAGS ('dbx_business_glossary_term' = 'Randomization Treatment Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `randomization_treatment_arm_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `randomization_treatment_arm_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `tlf_shell_id` SET TAGS ('dbx_business_glossary_term' = 'Tlf Shell Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `alpha_spending_function` SET TAGS ('dbx_value_regex' = 'obrien_fleming|pocock|lan_demets|hwang_shih_decani|none');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `alternative_hypothesis` SET TAGS ('dbx_implements' = 'ICH_E9.AlternativeHypothesis');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `alternative_hypothesis` SET TAGS ('dbx_standard' = 'ICH_E9');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `approved_date` SET TAGS ('dbx_business_glossary_term' = 'Endpoint Approved Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `confidence_interval_level` SET TAGS ('dbx_business_glossary_term' = 'Confidence Interval (CI) Level');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `covariates` SET TAGS ('dbx_business_glossary_term' = 'Analysis Covariates');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `csr_section_reference` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study Report (CSR) Section Reference');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `endpoint_classification` SET TAGS ('dbx_value_regex' = 'primary|secondary|exploratory|safety');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `endpoint_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `endpoint_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|locked|superseded|retired');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `endpoint_type` SET TAGS ('dbx_value_regex' = 'efficacy|pharmacokinetic|pharmacodynamic|biomarker|patient_reported_outcome|safety');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `hypothesis_type` SET TAGS ('dbx_value_regex' = 'superiority|non_inferiority|equivalence|exploratory');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `locked_date` SET TAGS ('dbx_business_glossary_term' = 'Endpoint Locked Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `measurement_scale` SET TAGS ('dbx_value_regex' = 'continuous|binary|categorical|ordinal|time_to_event');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `missing_data_method` SET TAGS ('dbx_business_glossary_term' = 'Missing Data Handling Method');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `missing_data_method` SET TAGS ('dbx_implements' = 'ICH_E9(R1).IntercurrentEventStrategy');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `missing_data_method` SET TAGS ('dbx_standard' = 'ICH_E9R1');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `multiplicity_adjustment_method` SET TAGS ('dbx_implements' = 'ICH_E9.MultiplicityAdjustment');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `multiplicity_adjustment_method` SET TAGS ('dbx_standard' = 'ICH_E9');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `multiplicity_adjustment_method` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `multiplicity_testing_family` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `non_inferiority_margin` SET TAGS ('dbx_business_glossary_term' = 'Non-Inferiority (NI) Margin');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `null_hypothesis` SET TAGS ('dbx_implements' = 'ICH_E9.NullHypothesis');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `null_hypothesis` SET TAGS ('dbx_standard' = 'ICH_E9');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `sap_version` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) Version');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `sap_version` SET TAGS ('dbx_value_regex' = '^v[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `significance_level` SET TAGS ('dbx_business_glossary_term' = 'Significance Level (Alpha)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `significance_level` SET TAGS ('dbx_implements' = 'ICH_E9.SignificanceLevel');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `significance_level` SET TAGS ('dbx_standard' = 'ICH_E9');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ADD CONSTRAINT `fk_biostatistics_pk_analysis_spec_adam_dataset_spec_id` FOREIGN KEY (`adam_dataset_spec_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec`(`adam_dataset_spec_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ADD CONSTRAINT `fk_biostatistics_pk_analysis_spec_analysis_population_id` FOREIGN KEY (`analysis_population_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`analysis_population`(`analysis_population_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ADD CONSTRAINT `fk_biostatistics_pk_analysis_spec_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ADD CONSTRAINT `fk_biostatistics_pk_analysis_spec_bioanalytical_assay_id` FOREIGN KEY (`bioanalytical_assay_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay`(`bioanalytical_assay_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ADD CONSTRAINT `fk_biostatistics_pk_analysis_spec_dosing_regimen_id` FOREIGN KEY (`dosing_regimen_id`) REFERENCES `clinical_trials_ecm`.`study`.`dosing_regimen`(`dosing_regimen_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ADD CONSTRAINT `fk_biostatistics_pk_analysis_spec_investigational_product_id` FOREIGN KEY (`investigational_product_id`) REFERENCES `clinical_trials_ecm`.`study`.`investigational_product`(`investigational_product_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ADD CONSTRAINT `fk_biostatistics_pk_analysis_spec_pipeline_asset_id` FOREIGN KEY (`pipeline_asset_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`pipeline_asset`(`pipeline_asset_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ADD CONSTRAINT `fk_biostatistics_pk_analysis_spec_pk_sampling_schedule_id` FOREIGN KEY (`pk_sampling_schedule_id`) REFERENCES `clinical_trials_ecm`.`study`.`pk_sampling_schedule`(`pk_sampling_schedule_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ADD CONSTRAINT `fk_biostatistics_pk_analysis_spec_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ADD CONSTRAINT `fk_biostatistics_pk_analysis_spec_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ADD CONSTRAINT `fk_biostatistics_pk_analysis_spec_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` SET TAGS ('dbx_domain' = 'biostatistics');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` SET TAGS ('dbx_subdomain' = 'dataset_specification');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `pk_analysis_spec_id` SET TAGS ('dbx_business_glossary_term' = 'Pharmacokinetic (PK) Analysis Specification ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `adam_dataset_spec_id` SET TAGS ('dbx_business_glossary_term' = 'Adam Dataset Spec Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `analysis_population_id` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii_employee' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `bioanalytical_assay_id` SET TAGS ('dbx_business_glossary_term' = 'Bioanalytical Assay Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `dosing_regimen_id` SET TAGS ('dbx_business_glossary_term' = 'Dosing Regimen Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `investigational_product_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `pipeline_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Pipeline Asset Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `pk_sampling_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Pk Sampling Schedule Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `analysis_type` SET TAGS ('dbx_business_glossary_term' = 'PK Analysis Type');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `analysis_type` SET TAGS ('dbx_value_regex' = 'NCA|compartmental|population_pk|pk_pd|bioequivalence');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Specification Approval Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `auc_extrapolation_pct_threshold` SET TAGS ('dbx_business_glossary_term' = 'AUC Extrapolation Percentage Threshold');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `be_lower_bound_pct` SET TAGS ('dbx_business_glossary_term' = 'Bioequivalence (BE) Lower Acceptance Bound Percentage');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `be_upper_bound_pct` SET TAGS ('dbx_business_glossary_term' = 'Bioequivalence (BE) Upper Acceptance Bound Percentage');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `bioequivalence_flag` SET TAGS ('dbx_business_glossary_term' = 'Bioequivalence (BE) Assessment Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `blinding_status` SET TAGS ('dbx_business_glossary_term' = 'Analysis Blinding Status');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `blinding_status` SET TAGS ('dbx_value_regex' = 'blinded|unblinded|open_label');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `ci_level_pct` SET TAGS ('dbx_business_glossary_term' = 'Confidence Interval (CI) Level Percentage');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `ci_method` SET TAGS ('dbx_business_glossary_term' = 'Confidence Interval (CI) Method');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `ci_method` SET TAGS ('dbx_value_regex' = 'two_one_sided_t_test|90pct_ci_lme|schuirmann|westlake|fieller');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `compartmental_model_type` SET TAGS ('dbx_value_regex' = 'one_compartment|two_compartment|three_compartment|non_compartmental|mixed_effects');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `dmpk_collaboration_ref` SET TAGS ('dbx_business_glossary_term' = 'Drug Metabolism and Pharmacokinetics (DMPK) Collaboration Reference');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `dose_normalization_method` SET TAGS ('dbx_value_regex' = 'actual_dose|nominal_dose|body_weight_normalized|bsa_normalized');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `effective_from_date` SET TAGS ('dbx_business_glossary_term' = 'Specification Effective From Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `interim_analysis_flag` SET TAGS ('dbx_business_glossary_term' = 'Interim PK Analysis Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `lambda_z_method` SET TAGS ('dbx_business_glossary_term' = 'Terminal Elimination Rate Constant (Lambda-z) Estimation Method');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `lambda_z_method` SET TAGS ('dbx_value_regex' = 'best_fit|manual_selection|fixed_points');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `lambda_z_min_points` SET TAGS ('dbx_business_glossary_term' = 'Lambda-z Minimum Data Points');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `lloq_handling_method` SET TAGS ('dbx_business_glossary_term' = 'Lower Limit of Quantification (LLOQ) Handling Method');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `lloq_handling_method` SET TAGS ('dbx_value_regex' = 'set_to_zero|set_to_half_lloq|exclude|set_to_lloq');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `missing_concentration_rule` SET TAGS ('dbx_business_glossary_term' = 'Missing Concentration Handling Rule');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `missing_concentration_rule` SET TAGS ('dbx_value_regex' = 'exclude_subject|exclude_timepoint|impute_locf|impute_linear|flag_only');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `nca_method` SET TAGS ('dbx_business_glossary_term' = 'Non-Compartmental Analysis (NCA) Method');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `nca_method` SET TAGS ('dbx_value_regex' = 'linear_trapezoidal|log_linear_trapezoidal|linear_log_trapezoidal|linear_up_log_down');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'PK Analysis Specification Notes');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `pk_parameters` SET TAGS ('dbx_business_glossary_term' = 'PK Parameters List');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `pk_software` SET TAGS ('dbx_business_glossary_term' = 'PK Analysis Software');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `pk_software` SET TAGS ('dbx_value_regex' = 'Phoenix_WinNonlin|SAS|NONMEM|R|Monolix|PKSolver');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `pk_software_version` SET TAGS ('dbx_business_glossary_term' = 'PK Analysis Software Version');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `r_squared_threshold` SET TAGS ('dbx_business_glossary_term' = 'Lambda-z R-Squared Threshold');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `sampling_schedule_type` SET TAGS ('dbx_business_glossary_term' = 'PK Sampling Schedule Type');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `sampling_schedule_type` SET TAGS ('dbx_value_regex' = 'intensive|sparse|population|trough_only');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `sdtm_pc_domain_ref` SET TAGS ('dbx_business_glossary_term' = 'Study Data Tabulation Model (SDTM) PC Domain Reference');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `spec_code` SET TAGS ('dbx_business_glossary_term' = 'PK Analysis Specification Code');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `spec_code` SET TAGS ('dbx_value_regex' = '^PK-SPEC-[A-Z0-9]{3,20}$');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `spec_status` SET TAGS ('dbx_business_glossary_term' = 'PK Analysis Specification Status');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `spec_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|superseded|retired');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `spec_title` SET TAGS ('dbx_business_glossary_term' = 'PK Analysis Specification Title');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `spec_version` SET TAGS ('dbx_business_glossary_term' = 'PK Analysis Specification Version');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `spec_version` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `study_design_type` SET TAGS ('dbx_business_glossary_term' = 'PK Study Design Type');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `study_design_type` SET TAGS ('dbx_value_regex' = 'crossover|parallel|replicate_crossover|single_dose|multiple_dose');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `superseded_date` SET TAGS ('dbx_business_glossary_term' = 'Specification Superseded Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `tlf_program_name` SET TAGS ('dbx_business_glossary_term' = 'Tables, Listings, and Figures (TLF) Program Name');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `tlf_program_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ADD CONSTRAINT `fk_biostatistics_estimand_adam_dataset_spec_id` FOREIGN KEY (`adam_dataset_spec_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec`(`adam_dataset_spec_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ADD CONSTRAINT `fk_biostatistics_estimand_analysis_population_id` FOREIGN KEY (`analysis_population_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`analysis_population`(`analysis_population_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ADD CONSTRAINT `fk_biostatistics_estimand_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ADD CONSTRAINT `fk_biostatistics_estimand_endpoint_id` FOREIGN KEY (`endpoint_id`) REFERENCES `clinical_trials_ecm`.`study`.`endpoint`(`endpoint_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ADD CONSTRAINT `fk_biostatistics_estimand_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ADD CONSTRAINT `fk_biostatistics_estimand_sponsor_regulatory_strategy_id` FOREIGN KEY (`sponsor_regulatory_strategy_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`regulatory_strategy`(`regulatory_strategy_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ADD CONSTRAINT `fk_biostatistics_estimand_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` SET TAGS ('dbx_domain' = 'biostatistics');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` SET TAGS ('dbx_subdomain' = 'analysis_planning');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `adam_dataset_spec_id` SET TAGS ('dbx_business_glossary_term' = 'Adam Dataset Spec Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `analysis_population_id` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii_employee' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `endpoint_id` SET TAGS ('dbx_business_glossary_term' = 'Study Endpoint Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `sponsor_regulatory_strategy_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Regulatory Strategy Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `adam_parameter_code` SET TAGS ('dbx_business_glossary_term' = 'Analysis Data Model (ADaM) Parameter Code (PARAMCD)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `adam_parameter_code` SET TAGS ('dbx_implements' = 'ADaMIG.PARAMCD');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `adam_parameter_code` SET TAGS ('dbx_standard' = 'CDISC_ADaM');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `alpha_level` SET TAGS ('dbx_business_glossary_term' = 'Alpha Level (Type I Error Rate)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `approved_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `blinding_status` SET TAGS ('dbx_value_regex' = 'blinded|unblinded|open_label');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `estimand_code` SET TAGS ('dbx_value_regex' = '^EST-[A-Z0-9]{2,20}$');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `csr_section_reference` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study Report (CSR) Section Reference');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `effect_direction` SET TAGS ('dbx_business_glossary_term' = 'Effect Direction / Trial Objective');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `effect_direction` SET TAGS ('dbx_value_regex' = 'superiority|non_inferiority|equivalence|exploratory');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `effect_direction` SET TAGS ('dbx_implements' = 'ICH_E9(R1).Estimand.variableOfInterest');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `effect_direction` SET TAGS ('dbx_standard' = 'ICH_E9R1');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `endpoint_type` SET TAGS ('dbx_value_regex' = 'continuous|binary|time_to_event|ordinal|count');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `intercurrent_event_description` SET TAGS ('dbx_business_glossary_term' = 'Intercurrent Event (ICE) Description');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `intercurrent_event_description` SET TAGS ('dbx_implements' = 'ICH_E9(R1).IntercurrentEvent');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `intercurrent_event_description` SET TAGS ('dbx_standard' = 'ICH_E9R1');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `intercurrent_event_strategy` SET TAGS ('dbx_business_glossary_term' = 'Intercurrent Event (ICE) Handling Strategy');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `intercurrent_event_strategy` SET TAGS ('dbx_value_regex' = 'treatment_policy|hypothetical|composite|while_on_treatment|principal_stratum');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `intercurrent_event_strategy` SET TAGS ('dbx_implements' = 'ICH_E9(R1).IntercurrentEvent.strategy');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `intercurrent_event_strategy` SET TAGS ('dbx_standard' = 'ICH_E9R1');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `interim_analysis_flag` SET TAGS ('dbx_business_glossary_term' = 'Interim Analysis Indicator');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `is_confirmatory` SET TAGS ('dbx_business_glossary_term' = 'Confirmatory Analysis Indicator');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `is_primary_endpoint` SET TAGS ('dbx_business_glossary_term' = 'Primary Endpoint Indicator');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `label` SET TAGS ('dbx_business_glossary_term' = 'Estimand Label');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `missing_data_strategy` SET TAGS ('dbx_business_glossary_term' = 'Missing Data Handling Strategy');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `missing_data_strategy` SET TAGS ('dbx_value_regex' = 'LOCF|BOCF|multiple_imputation|mixed_model|retrieved_dropout|none');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `missing_data_strategy` SET TAGS ('dbx_implements' = 'ICH_E9(R1).IntercurrentEventStrategy');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `missing_data_strategy` SET TAGS ('dbx_standard' = 'ICH_E9R1');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `multiplicity_adjustment_method` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `non_inferiority_margin` SET TAGS ('dbx_business_glossary_term' = 'Non-Inferiority (NI) Margin');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Estimand Notes');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `population_level_summary` SET TAGS ('dbx_business_glossary_term' = 'Population-Level Summary Measure');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `population_level_summary` SET TAGS ('dbx_implements' = 'ICH_E9(R1).Estimand.populationLevelSummary');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `population_level_summary` SET TAGS ('dbx_standard' = 'ICH_E9R1');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `sap_alignment_status` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) Alignment Status');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `sap_alignment_status` SET TAGS ('dbx_value_regex' = 'aligned|pending_alignment|misaligned|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `sap_section_reference` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) Section Reference');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `estimand_status` SET TAGS ('dbx_business_glossary_term' = 'Estimand Lifecycle Status');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `estimand_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|superseded|retired');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `target_population_description` SET TAGS ('dbx_implements' = 'ICH_E9(R1).Estimand.population');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `target_population_description` SET TAGS ('dbx_standard' = 'ICH_E9R1');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `estimand_type` SET TAGS ('dbx_implements' = 'ICH_E9(R1).Estimand.type');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `estimand_type` SET TAGS ('dbx_standard' = 'ICH_E9R1');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Estimand Version Number');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`estimand` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^d+.d+$');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ADD CONSTRAINT `fk_biostatistics_dsmb_charter_blinding_config_id` FOREIGN KEY (`blinding_config_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`blinding_config`(`blinding_config_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ADD CONSTRAINT `fk_biostatistics_dsmb_charter_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ADD CONSTRAINT `fk_biostatistics_dsmb_charter_governance_id` FOREIGN KEY (`governance_id`) REFERENCES `clinical_trials_ecm`.`program`.`governance`(`governance_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ADD CONSTRAINT `fk_biostatistics_dsmb_charter_independent_statistician_employee_id` FOREIGN KEY (`independent_statistician_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ADD CONSTRAINT `fk_biostatistics_dsmb_charter_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ADD CONSTRAINT `fk_biostatistics_dsmb_charter_rand_scheme_id` FOREIGN KEY (`rand_scheme_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`rand_scheme`(`rand_scheme_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ADD CONSTRAINT `fk_biostatistics_dsmb_charter_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ADD CONSTRAINT `fk_biostatistics_dsmb_charter_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` SET TAGS ('dbx_domain' = 'biostatistics');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` SET TAGS ('dbx_subdomain' = 'safety_oversight');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `dsmb_charter_id` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Charter ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `blinding_config_id` SET TAGS ('dbx_business_glossary_term' = 'Blinding Config Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `governance_id` SET TAGS ('dbx_business_glossary_term' = 'Program Governance Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `independent_statistician_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Independent Statistician Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `independent_statistician_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `independent_statistician_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `independent_statistician_employee_id` SET TAGS ('dbx_pii_employee' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `rand_scheme_id` SET TAGS ('dbx_business_glossary_term' = 'Rand Scheme Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Study Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `alpha_spending_function` SET TAGS ('dbx_value_regex' = 'OBrien_Fleming|Pocock|Lan_DeMets|Hwang_Shih_DeCani|Haybittle_Peto|other');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `amendment_number` SET TAGS ('dbx_business_glossary_term' = 'Charter Amendment Number');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `amendment_reason` SET TAGS ('dbx_business_glossary_term' = 'Charter Amendment Reason');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Charter Approval Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Charter Approved By');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `approved_by` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `approved_by` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `blinding_maintained_for_sponsor` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Blinding Maintained Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `charter_identifier` SET TAGS ('dbx_business_glossary_term' = 'DSMB Charter Identifier');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `charter_scope_description` SET TAGS ('dbx_business_glossary_term' = 'DSMB Charter Scope Description');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `charter_status` SET TAGS ('dbx_business_glossary_term' = 'DSMB Charter Status');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `charter_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|superseded|retired');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `charter_title` SET TAGS ('dbx_business_glossary_term' = 'DSMB Charter Title');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `charter_version` SET TAGS ('dbx_business_glossary_term' = 'DSMB Charter Version');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `charter_version` SET TAGS ('dbx_value_regex' = '^v?d+.d+$');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `closed_session_scope` SET TAGS ('dbx_business_glossary_term' = 'DSMB Closed Session Scope');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `committee_chair_name` SET TAGS ('dbx_business_glossary_term' = 'DSMB Committee Chair Name');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `committee_chair_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `committee_chair_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `committee_chair_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `committee_type` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Committee Type');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `committee_type` SET TAGS ('dbx_value_regex' = 'DSMB|DMC|IDMC|ISMC|DSMC');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `confidentiality_requirements` SET TAGS ('dbx_business_glossary_term' = 'DSMB Confidentiality Requirements');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Charter Effective Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Charter Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `futility_rule_binding` SET TAGS ('dbx_business_glossary_term' = 'Futility Rule Binding Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `mastercontrol_document_reference` SET TAGS ('dbx_business_glossary_term' = 'MasterControl Document ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `meeting_frequency` SET TAGS ('dbx_business_glossary_term' = 'DSMB Meeting Frequency');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'DSMB Charter Notes');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `open_session_scope` SET TAGS ('dbx_business_glossary_term' = 'DSMB Open Session Scope');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `quorum_requirement` SET TAGS ('dbx_business_glossary_term' = 'DSMB Quorum Requirement');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `recommendation_types_allowed` SET TAGS ('dbx_business_glossary_term' = 'DSMB Allowed Recommendation Types');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `reporting_timeline_days` SET TAGS ('dbx_business_glossary_term' = 'DSMB Reporting Timeline (Days)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `sponsor_response_timeline_days` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Response Timeline (Days)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `total_interim_analyses_planned` SET TAGS ('dbx_business_glossary_term' = 'Total Planned Interim Analyses Count');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `total_member_count` SET TAGS ('dbx_business_glossary_term' = 'DSMB Total Member Count');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_charter` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ADD CONSTRAINT `fk_biostatistics_dsmb_meeting_blinding_config_id` FOREIGN KEY (`blinding_config_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`blinding_config`(`blinding_config_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ADD CONSTRAINT `fk_biostatistics_dsmb_meeting_dsmb_charter_id` FOREIGN KEY (`dsmb_charter_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`dsmb_charter`(`dsmb_charter_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ADD CONSTRAINT `fk_biostatistics_dsmb_meeting_interim_analysis_id` FOREIGN KEY (`interim_analysis_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`interim_analysis`(`interim_analysis_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ADD CONSTRAINT `fk_biostatistics_dsmb_meeting_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ADD CONSTRAINT `fk_biostatistics_dsmb_meeting_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` SET TAGS ('dbx_domain' = 'biostatistics');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` SET TAGS ('dbx_subdomain' = 'safety_oversight');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `dsmb_meeting_id` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Meeting ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `blinding_config_id` SET TAGS ('dbx_business_glossary_term' = 'Blinding Config Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `dsmb_charter_id` SET TAGS ('dbx_business_glossary_term' = 'Dsmb Charter Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `interim_analysis_id` SET TAGS ('dbx_business_glossary_term' = 'Interim Analysis Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) ID');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `action_items` SET TAGS ('dbx_business_glossary_term' = 'DSMB Action Items');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `agenda_items` SET TAGS ('dbx_business_glossary_term' = 'DSMB Meeting Agenda Items');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `agenda_items` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `charter_version` SET TAGS ('dbx_business_glossary_term' = 'DSMB Charter Version');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `confidentiality_maintained` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Maintained Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `data_cut_date` SET TAGS ('dbx_business_glossary_term' = 'Data Cut-Off Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `etmf_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Electronic Trial Master File (eTMF) Document Reference');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `independent_statistician_present` SET TAGS ('dbx_business_glossary_term' = 'Independent Statistician Present Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `interim_analysis_data_package_version` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `meeting_date` SET TAGS ('dbx_business_glossary_term' = 'DSMB Meeting Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `meeting_duration_minutes` SET TAGS ('dbx_business_glossary_term' = 'DSMB Meeting Duration (Minutes)');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `meeting_identifier` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Meeting Identifier');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `meeting_identifier` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{3,50}$');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `meeting_location` SET TAGS ('dbx_business_glossary_term' = 'DSMB Meeting Location');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `meeting_number` SET TAGS ('dbx_business_glossary_term' = 'DSMB Meeting Sequence Number');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `meeting_status` SET TAGS ('dbx_business_glossary_term' = 'DSMB Meeting Status');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `meeting_status` SET TAGS ('dbx_value_regex' = 'scheduled|completed|cancelled|postponed|in_progress');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `meeting_type` SET TAGS ('dbx_business_glossary_term' = 'DSMB Meeting Type');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `meeting_type` SET TAGS ('dbx_value_regex' = 'scheduled|ad_hoc|emergency|teleconference|face_to_face');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `members_present_count` SET TAGS ('dbx_business_glossary_term' = 'DSMB Members Present Count');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `minutes_approval_date` SET TAGS ('dbx_business_glossary_term' = 'DSMB Meeting Minutes Approval Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `minutes_status` SET TAGS ('dbx_business_glossary_term' = 'DSMB Meeting Minutes Approval Status');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `minutes_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|finalized');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `next_meeting_date` SET TAGS ('dbx_business_glossary_term' = 'Next DSMB Meeting Scheduled Date');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `protocol_amendment_triggered` SET TAGS ('dbx_business_glossary_term' = 'Protocol Amendment Triggered Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `quorum_met` SET TAGS ('dbx_business_glossary_term' = 'DSMB Quorum Met Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `recommendation` SET TAGS ('dbx_business_glossary_term' = 'DSMB Recommendation');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `recommendation` SET TAGS ('dbx_value_regex' = 'continue|pause|stop_efficacy|stop_futility|stop_safety|modify_protocol');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `recommendation_rationale` SET TAGS ('dbx_business_glossary_term' = 'DSMB Recommendation Rationale');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `regulatory_notification_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Notification Required Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `sae_count_reviewed` SET TAGS ('dbx_business_glossary_term' = 'Serious Adverse Event (SAE) Count Reviewed');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `session_type` SET TAGS ('dbx_business_glossary_term' = 'DSMB Session Type');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `session_type` SET TAGS ('dbx_value_regex' = 'open|closed|executive');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `sponsor_notified` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Notified Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `stopping_boundary_crossed` SET TAGS ('dbx_business_glossary_term' = 'Stopping Boundary Crossed Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `stopping_boundary_type` SET TAGS ('dbx_value_regex' = 'efficacy|futility|safety|none');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `subjects_completed_at_review` SET TAGS ('dbx_business_glossary_term' = 'Subjects Completed at Data Review');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `subjects_enrolled_at_review` SET TAGS ('dbx_business_glossary_term' = 'Subjects Enrolled at Data Review');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `unblinding_occurred` SET TAGS ('dbx_business_glossary_term' = 'Unblinding Occurred Flag');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `unblinding_scope` SET TAGS ('dbx_value_regex' = 'full|partial|none');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ADD CONSTRAINT `fk_biostatistics_analysis_output_adam_dataset_spec_id` FOREIGN KEY (`adam_dataset_spec_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec`(`adam_dataset_spec_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ADD CONSTRAINT `fk_biostatistics_analysis_output_analysis_id` FOREIGN KEY (`analysis_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`analysis`(`analysis_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ADD CONSTRAINT `fk_biostatistics_analysis_output_analysis_population_id` FOREIGN KEY (`analysis_population_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`analysis_population`(`analysis_population_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ADD CONSTRAINT `fk_biostatistics_analysis_output_analysis_set_id` FOREIGN KEY (`analysis_set_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`analysis_set`(`analysis_set_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ADD CONSTRAINT `fk_biostatistics_analysis_output_parent_analysis_output_id` FOREIGN KEY (`parent_analysis_output_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`analysis_output`(`analysis_output_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ADD CONSTRAINT `fk_biostatistics_analysis_output_reporting_event_id` FOREIGN KEY (`reporting_event_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`reporting_event`(`reporting_event_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ADD CONSTRAINT `fk_biostatistics_analysis_output_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ADD CONSTRAINT `fk_biostatistics_analysis_output_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ADD CONSTRAINT `fk_biostatistics_analysis_output_tlf_output_id` FOREIGN KEY (`tlf_output_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`tlf_output`(`tlf_output_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ADD CONSTRAINT `fk_biostatistics_analysis_output_tlf_shell_id` FOREIGN KEY (`tlf_shell_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`tlf_shell`(`tlf_shell_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` SET TAGS ('dbx_domain' = 'biostatistics');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` SET TAGS ('dbx_subdomain' = 'results_production');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` SET TAGS ('dbx_cdisc' = 'ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` SET TAGS ('dbx_standard' = 'ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` SET TAGS ('dbx_layer' = 'silver');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ALTER COLUMN `analysis_id` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ALTER COLUMN `analysis_id` SET TAGS ('dbx_element' = 'Output.analysis');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ALTER COLUMN `reporting_event_id` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ALTER COLUMN `reporting_event_id` SET TAGS ('dbx_element' = 'Output.reportingEvent');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Study');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ALTER COLUMN `tlf_output_id` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ALTER COLUMN `tlf_output_id` SET TAGS ('dbx_element' = 'Output.outputFile');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ALTER COLUMN `tlf_shell_id` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ALTER COLUMN `tlf_shell_id` SET TAGS ('dbx_element' = 'Output.displaySection');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ALTER COLUMN `display_identifier` SET TAGS ('dbx_standard' = 'ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ALTER COLUMN `display_identifier` SET TAGS ('dbx_implements' = 'ARS.Output.displayIdentifier');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ALTER COLUMN `display_type` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ALTER COLUMN `display_type` SET TAGS ('dbx_element' = 'Output.displayType');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ALTER COLUMN `file_specification` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ALTER COLUMN `file_specification` SET TAGS ('dbx_element' = 'Output.fileSpecification');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ALTER COLUMN `ordinal` SET TAGS ('dbx_business_glossary_term' = 'Output Order');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ALTER COLUMN `ordinal` SET TAGS ('dbx_standard' = 'ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ALTER COLUMN `ordinal` SET TAGS ('dbx_implements' = 'ARS.Output.order');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ALTER COLUMN `output_description` SET TAGS ('dbx_standard' = 'ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ALTER COLUMN `output_description` SET TAGS ('dbx_implements' = 'ARS.Output.description');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ALTER COLUMN `output_file_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ALTER COLUMN `output_label` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ALTER COLUMN `output_label` SET TAGS ('dbx_element' = 'Output.label');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ALTER COLUMN `output_name` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ALTER COLUMN `output_name` SET TAGS ('dbx_element' = 'Output.name');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ALTER COLUMN `output_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ALTER COLUMN `output_type` SET TAGS ('dbx_standard' = 'ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ALTER COLUMN `output_type` SET TAGS ('dbx_implements' = 'ARS.Output.displayType');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ALTER COLUMN `output_version` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ALTER COLUMN `output_version` SET TAGS ('dbx_element' = 'Output.version');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'Output Version');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ALTER COLUMN `version` SET TAGS ('dbx_standard' = 'ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_output` ALTER COLUMN `version` SET TAGS ('dbx_implements' = 'ARS.Output.version');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_method` ADD CONSTRAINT `fk_biostatistics_analysis_method_adam_dataset_spec_id` FOREIGN KEY (`adam_dataset_spec_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec`(`adam_dataset_spec_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_method` ADD CONSTRAINT `fk_biostatistics_analysis_method_analysis_id` FOREIGN KEY (`analysis_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`analysis`(`analysis_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_method` ADD CONSTRAINT `fk_biostatistics_analysis_method_analysis_population_id` FOREIGN KEY (`analysis_population_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`analysis_population`(`analysis_population_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_method` ADD CONSTRAINT `fk_biostatistics_analysis_method_reporting_event_id` FOREIGN KEY (`reporting_event_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`reporting_event`(`reporting_event_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_method` ADD CONSTRAINT `fk_biostatistics_analysis_method_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_method` ADD CONSTRAINT `fk_biostatistics_analysis_method_tlf_output_id` FOREIGN KEY (`tlf_output_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`tlf_output`(`tlf_output_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_method` ADD CONSTRAINT `fk_biostatistics_analysis_method_tlf_shell_id` FOREIGN KEY (`tlf_shell_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`tlf_shell`(`tlf_shell_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_method` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_method` SET TAGS ('dbx_domain' = 'biostatistics');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_method` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_method` SET TAGS ('dbx_subdomain' = 'results_production');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_method` SET TAGS ('dbx_cdisc' = 'ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_method` SET TAGS ('dbx_standard' = 'ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_method` SET TAGS ('dbx_layer' = 'silver');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_method` ALTER COLUMN `reporting_event_id` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_method` ALTER COLUMN `reporting_event_id` SET TAGS ('dbx_element' = 'AnalysisMethod.reportingEvent');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_method` ALTER COLUMN `sap_id` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_method` ALTER COLUMN `sap_id` SET TAGS ('dbx_element' = 'AnalysisMethod.analysisPlan');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_method` ALTER COLUMN `method_description` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_method` ALTER COLUMN `method_description` SET TAGS ('dbx_element' = 'AnalysisMethod.description');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_method` ALTER COLUMN `method_label` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_method` ALTER COLUMN `method_label` SET TAGS ('dbx_element' = 'AnalysisMethod.label');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_method` ALTER COLUMN `method_name` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_method` ALTER COLUMN `method_name` SET TAGS ('dbx_element' = 'AnalysisMethod.name');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_method` ALTER COLUMN `method_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_method` ALTER COLUMN `operation_definition` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_method` ALTER COLUMN `operation_definition` SET TAGS ('dbx_element' = 'AnalysisMethod.operation');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_method` ALTER COLUMN `programming_language` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_method` ALTER COLUMN `programming_reference` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_method` ALTER COLUMN `programming_reference` SET TAGS ('dbx_element' = 'AnalysisMethod.codeTemplate');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_method` ALTER COLUMN `programming_statement` SET TAGS ('dbx_standard' = 'ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_method` ALTER COLUMN `programming_statement` SET TAGS ('dbx_implements' = 'ARS.AnalysisMethod.codeTemplate');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ADD CONSTRAINT `fk_biostatistics_analysis_set_adam_dataset_spec_id` FOREIGN KEY (`adam_dataset_spec_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec`(`adam_dataset_spec_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ADD CONSTRAINT `fk_biostatistics_analysis_set_analysis_population_id` FOREIGN KEY (`analysis_population_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`analysis_population`(`analysis_population_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ADD CONSTRAINT `fk_biostatistics_analysis_set_reporting_event_id` FOREIGN KEY (`reporting_event_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`reporting_event`(`reporting_event_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ADD CONSTRAINT `fk_biostatistics_analysis_set_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ADD CONSTRAINT `fk_biostatistics_analysis_set_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ADD CONSTRAINT `fk_biostatistics_analysis_set_tlf_output_id` FOREIGN KEY (`tlf_output_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`tlf_output`(`tlf_output_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ADD CONSTRAINT `fk_biostatistics_analysis_set_tlf_shell_id` FOREIGN KEY (`tlf_shell_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`tlf_shell`(`tlf_shell_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` SET TAGS ('dbx_domain' = 'biostatistics');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` SET TAGS ('dbx_subdomain' = 'results_production');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` SET TAGS ('dbx_cdisc' = 'ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` SET TAGS ('dbx_standard' = 'ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` SET TAGS ('dbx_layer' = 'silver');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ALTER COLUMN `analysis_population_id` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ALTER COLUMN `analysis_population_id` SET TAGS ('dbx_element' = 'AnalysisSet.population');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ALTER COLUMN `reporting_event_id` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ALTER COLUMN `reporting_event_id` SET TAGS ('dbx_element' = 'AnalysisSet.reportingEvent');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Study');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ALTER COLUMN `condition_expression` SET TAGS ('dbx_standard' = 'ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ALTER COLUMN `condition_expression` SET TAGS ('dbx_implements' = 'ARS.AnalysisSet.condition');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ALTER COLUMN `analysis_set_description` SET TAGS ('dbx_standard' = 'ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ALTER COLUMN `analysis_set_description` SET TAGS ('dbx_implements' = 'ARS.AnalysisSet.description');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ALTER COLUMN `label` SET TAGS ('dbx_business_glossary_term' = 'Analysis Set Label');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ALTER COLUMN `label` SET TAGS ('dbx_standard' = 'ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ALTER COLUMN `label` SET TAGS ('dbx_implements' = 'ARS.AnalysisSet.label');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ALTER COLUMN `analysis_set_name` SET TAGS ('dbx_standard' = 'ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ALTER COLUMN `analysis_set_name` SET TAGS ('dbx_implements' = 'ARS.AnalysisSet.name');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ALTER COLUMN `analysis_set_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ALTER COLUMN `ordinal` SET TAGS ('dbx_business_glossary_term' = 'Analysis Set Order');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ALTER COLUMN `ordinal` SET TAGS ('dbx_standard' = 'ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ALTER COLUMN `ordinal` SET TAGS ('dbx_implements' = 'ARS.AnalysisSet.order');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ALTER COLUMN `set_condition` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ALTER COLUMN `set_condition` SET TAGS ('dbx_element' = 'AnalysisSet.condition');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ALTER COLUMN `set_label` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ALTER COLUMN `set_label` SET TAGS ('dbx_element' = 'AnalysisSet.label');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ALTER COLUMN `set_level` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ALTER COLUMN `set_level` SET TAGS ('dbx_element' = 'AnalysisSet.level');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ALTER COLUMN `set_name` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ALTER COLUMN `set_name` SET TAGS ('dbx_element' = 'AnalysisSet.label');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ALTER COLUMN `set_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ALTER COLUMN `set_order` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis_set` ALTER COLUMN `set_order` SET TAGS ('dbx_element' = 'AnalysisSet.order');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` ADD CONSTRAINT `fk_biostatistics_reporting_event_adam_dataset_spec_id` FOREIGN KEY (`adam_dataset_spec_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec`(`adam_dataset_spec_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` ADD CONSTRAINT `fk_biostatistics_reporting_event_analysis_population_id` FOREIGN KEY (`analysis_population_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`analysis_population`(`analysis_population_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` ADD CONSTRAINT `fk_biostatistics_reporting_event_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` ADD CONSTRAINT `fk_biostatistics_reporting_event_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` ADD CONSTRAINT `fk_biostatistics_reporting_event_tlf_output_id` FOREIGN KEY (`tlf_output_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`tlf_output`(`tlf_output_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` ADD CONSTRAINT `fk_biostatistics_reporting_event_tlf_shell_id` FOREIGN KEY (`tlf_shell_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`tlf_shell`(`tlf_shell_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` SET TAGS ('dbx_domain' = 'biostatistics');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` SET TAGS ('dbx_subdomain' = 'results_production');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` SET TAGS ('dbx_cdisc' = 'ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` SET TAGS ('dbx_standard' = 'ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` SET TAGS ('dbx_layer' = 'silver');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` ALTER COLUMN `sap_id` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` ALTER COLUMN `sap_id` SET TAGS ('dbx_element' = 'ReportingEvent.analysisPlan');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` ALTER COLUMN `study_id` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` ALTER COLUMN `study_id` SET TAGS ('dbx_element' = 'ReportingEvent.study');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` ALTER COLUMN `ars_version` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` ALTER COLUMN `ars_version` SET TAGS ('dbx_element' = 'ReportingEvent.version');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` ALTER COLUMN `reporting_event_description` SET TAGS ('dbx_standard' = 'ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` ALTER COLUMN `reporting_event_description` SET TAGS ('dbx_implements' = 'ARS.ReportingEvent.description');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` ALTER COLUMN `event_status` SET TAGS ('dbx_business_glossary_term' = 'Reporting Event Status');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` ALTER COLUMN `label` SET TAGS ('dbx_element' = 'ReportingEvent.label');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` ALTER COLUMN `label` SET TAGS ('dbx_implements' = 'ARS.ReportingEvent.label');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` ALTER COLUMN `label` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` ALTER COLUMN `reporting_event_name` SET TAGS ('dbx_element' = 'ReportingEvent.name');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` ALTER COLUMN `reporting_event_name` SET TAGS ('dbx_implements' = 'ARS.ReportingEvent.name');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` ALTER COLUMN `reporting_event_name` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` ALTER COLUMN `reporting_event_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` ALTER COLUMN `reporting_event_type` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` ALTER COLUMN `reporting_event_type` SET TAGS ('dbx_element' = 'ReportingEvent.type');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` ALTER COLUMN `version` SET TAGS ('dbx_element' = 'ReportingEvent.version');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` ALTER COLUMN `version` SET TAGS ('dbx_implements' = 'ARS.ReportingEvent.version');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`reporting_event` ALTER COLUMN `version` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` ADD CONSTRAINT `fk_biostatistics_grouping_factor_adam_dataset_spec_id` FOREIGN KEY (`adam_dataset_spec_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec`(`adam_dataset_spec_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` ADD CONSTRAINT `fk_biostatistics_grouping_factor_analysis_id` FOREIGN KEY (`analysis_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`analysis`(`analysis_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` ADD CONSTRAINT `fk_biostatistics_grouping_factor_analysis_population_id` FOREIGN KEY (`analysis_population_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`analysis_population`(`analysis_population_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` ADD CONSTRAINT `fk_biostatistics_grouping_factor_reporting_event_id` FOREIGN KEY (`reporting_event_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`reporting_event`(`reporting_event_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` ADD CONSTRAINT `fk_biostatistics_grouping_factor_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` ADD CONSTRAINT `fk_biostatistics_grouping_factor_tlf_output_id` FOREIGN KEY (`tlf_output_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`tlf_output`(`tlf_output_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` ADD CONSTRAINT `fk_biostatistics_grouping_factor_tlf_shell_id` FOREIGN KEY (`tlf_shell_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`tlf_shell`(`tlf_shell_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` SET TAGS ('dbx_domain' = 'biostatistics');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` SET TAGS ('dbx_subdomain' = 'results_production');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` SET TAGS ('dbx_cdisc' = 'ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` SET TAGS ('dbx_standard' = 'ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` SET TAGS ('dbx_layer' = 'silver');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` ALTER COLUMN `analysis_id` SET TAGS ('dbx_business_glossary_term' = 'Analysis');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` ALTER COLUMN `reporting_event_id` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` ALTER COLUMN `reporting_event_id` SET TAGS ('dbx_element' = 'AnalysisGrouping.reportingEvent');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` ALTER COLUMN `data_driven_flag` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` ALTER COLUMN `data_driven_flag` SET TAGS ('dbx_element' = 'AnalysisGrouping.dataDriven');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` ALTER COLUMN `group_value` SET TAGS ('dbx_standard' = 'ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` ALTER COLUMN `group_value` SET TAGS ('dbx_implements' = 'ARS.AnalysisGrouping.group.condition');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` ALTER COLUMN `group_values` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` ALTER COLUMN `group_values` SET TAGS ('dbx_element' = 'AnalysisGrouping.group');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` ALTER COLUMN `grouping_dataset` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` ALTER COLUMN `grouping_dataset` SET TAGS ('dbx_element' = 'AnalysisGrouping.groupingDataset');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` ALTER COLUMN `grouping_description` SET TAGS ('dbx_standard' = 'ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` ALTER COLUMN `grouping_description` SET TAGS ('dbx_implements' = 'ARS.AnalysisGrouping.description');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` ALTER COLUMN `grouping_label` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` ALTER COLUMN `grouping_label` SET TAGS ('dbx_element' = 'AnalysisGrouping.label');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` ALTER COLUMN `grouping_name` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` ALTER COLUMN `grouping_name` SET TAGS ('dbx_element' = 'AnalysisGrouping.name');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` ALTER COLUMN `grouping_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` ALTER COLUMN `grouping_variable` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` ALTER COLUMN `grouping_variable` SET TAGS ('dbx_element' = 'AnalysisGrouping.groupingVariable');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` ALTER COLUMN `ordinal` SET TAGS ('dbx_business_glossary_term' = 'Grouping Order');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` ALTER COLUMN `ordinal` SET TAGS ('dbx_standard' = 'ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`grouping_factor` ALTER COLUMN `ordinal` SET TAGS ('dbx_implements' = 'ARS.AnalysisGrouping.order');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` ADD CONSTRAINT `fk_biostatistics_analysis_adam_dataset_spec_id` FOREIGN KEY (`adam_dataset_spec_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`adam_dataset_spec`(`adam_dataset_spec_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` ADD CONSTRAINT `fk_biostatistics_analysis_analysis_population_id` FOREIGN KEY (`analysis_population_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`analysis_population`(`analysis_population_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` ADD CONSTRAINT `fk_biostatistics_analysis_analysis_set_id` FOREIGN KEY (`analysis_set_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`analysis_set`(`analysis_set_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` ADD CONSTRAINT `fk_biostatistics_analysis_estimand_id` FOREIGN KEY (`estimand_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`estimand`(`estimand_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` ADD CONSTRAINT `fk_biostatistics_analysis_reporting_event_id` FOREIGN KEY (`reporting_event_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`reporting_event`(`reporting_event_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` ADD CONSTRAINT `fk_biostatistics_analysis_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` ADD CONSTRAINT `fk_biostatistics_analysis_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` ADD CONSTRAINT `fk_biostatistics_analysis_tlf_output_id` FOREIGN KEY (`tlf_output_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`tlf_output`(`tlf_output_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` ADD CONSTRAINT `fk_biostatistics_analysis_tlf_shell_id` FOREIGN KEY (`tlf_shell_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`tlf_shell`(`tlf_shell_id`);

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` SET TAGS ('dbx_domain' = 'biostatistics');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` SET TAGS ('dbx_subdomain' = 'results_production');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` SET TAGS ('dbx_cdisc' = 'ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` SET TAGS ('dbx_standard' = 'ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` SET TAGS ('dbx_layer' = 'silver');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` ALTER COLUMN `adam_dataset_spec_id` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` ALTER COLUMN `adam_dataset_spec_id` SET TAGS ('dbx_element' = 'Analysis.dataset');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` ALTER COLUMN `analysis_population_id` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` ALTER COLUMN `reporting_event_id` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` ALTER COLUMN `reporting_event_id` SET TAGS ('dbx_element' = 'Analysis.reportingEvent');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` ALTER COLUMN `sap_id` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` ALTER COLUMN `sap_id` SET TAGS ('dbx_element' = 'Analysis.analysisPlan');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` ALTER COLUMN `study_id` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` ALTER COLUMN `study_id` SET TAGS ('dbx_element' = 'Analysis.study');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` ALTER COLUMN `analysis_description` SET TAGS ('dbx_standard' = 'ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` ALTER COLUMN `analysis_description` SET TAGS ('dbx_implements' = 'ARS.Analysis.description');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` ALTER COLUMN `label` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` ALTER COLUMN `label` SET TAGS ('dbx_element' = 'Analysis.label');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` ALTER COLUMN `analysis_name` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` ALTER COLUMN `analysis_name` SET TAGS ('dbx_element' = 'Analysis.name');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` ALTER COLUMN `analysis_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` ALTER COLUMN `ordinal` SET TAGS ('dbx_business_glossary_term' = 'Analysis Order');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` ALTER COLUMN `ordinal` SET TAGS ('dbx_standard' = 'ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` ALTER COLUMN `ordinal` SET TAGS ('dbx_implements' = 'ARS.Analysis.order');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` ALTER COLUMN `purpose` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` ALTER COLUMN `purpose` SET TAGS ('dbx_element' = 'Analysis.purpose');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` ALTER COLUMN `reason` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` ALTER COLUMN `reason` SET TAGS ('dbx_element' = 'Analysis.reason');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` ALTER COLUMN `variable` SET TAGS ('dbx_standard' = 'CDISC_ARS');

ALTER TABLE `clinical_trials_ecm`.`biostatistics`.`analysis` ALTER COLUMN `variable` SET TAGS ('dbx_element' = 'Analysis.variable');
