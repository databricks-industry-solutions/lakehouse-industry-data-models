-- Schema for Domain: biostatistics | Business: Clinical_Trials | Version: v2_mvm
-- Generated on: 2026-11-20 12:39:46

CREATE DATABASE IF NOT EXISTS `clinical_trials_mvm`.`biostatistics` COMMENT 'Owns the statistical planning and analysis lifecycle for clinical trials. Manages the source system versioning, randomization scheme design, sample size calculations, ADaM dataset specifications, TLF production, interim and final analyses';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`biostatistics`.`sap` (
    `sap_id` BIGINT COMMENT 'Unique surrogate identifier for the Statistical Analysis Plan record in the Databricks Silver Layer. Primary key for this entity.',
    `application_id` BIGINT COMMENT 'Foreign key linking to regulatory.application. Business justification: The the source system under a specific regulatory application (IND/NDA/BLA). IND annual reports and NDA/BLA submissions require the current the source system associated with the',
    `audit_finding_id` BIGINT COMMENT 'Foreign key linking to compliance.audit_finding. Business justification: Audit findings can be raised directly against the base SAP (not just amendments). FDA/EMA inspections frequently cite SAP deficiencies as findings.',
    `blinding_config_id` BIGINT COMMENT 'Foreign key linking to randomization.blinding_config. Business justification: The the source system the blinding configuration governing statistician access, interim analysis unblinding procedures, and firewall requirements.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.compliance_sop. Business justification: SAP authoring, review, and approval are governed by a specific biostatistics SOP. GCP requires traceability between the SAP document and the SOP under which it was produced.',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.strategy. Business justification: The regulatory strategy defines the submission pathway, primary endpoint, and analysis population that the the source system with.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: SAPs are authored against a specific protocol version — regulatory submissions require direct SAP-to-protocol traceability.',
    `rand_scheme_id` BIGINT COMMENT 'Foreign key linking to randomization.rand_scheme. Business justification: ICH E9 requires the the source system the randomization method. The the source system the exact rand_scheme version it was designed around for regulatory submission alignment.',
    `regulatory_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to regulatory.regulatory_protocol_amendment. Business justification: SAPs must be written against a specific protocol amendment version per ICH E6 and FDA guidance.',
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

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` (
    `sap_amendment_id` BIGINT COMMENT 'Unique surrogate identifier for each the source system in the Databricks Silver Layer. Primary key for the the source system',
    `audit_finding_id` BIGINT COMMENT 'Foreign key linking to compliance.audit_finding. Business justification: Audit findings (e.g., analysis method not pre-specified, population definition inconsistency) can mandate the source system',
    `blinding_config_id` BIGINT COMMENT 'Foreign key linking to randomization.blinding_config. Business justification: SAP amendments with blinding_impact must reference the specific blinding_config affected.',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: SAP amendments with regulatory_notification_required=true must be tracked per health authority for compliance. Different HAs (FDA, EMA) have distinct notification timelines.',
    `icf_amendment_id` BIGINT COMMENT 'Foreign key linking to consent.icf_amendment. Business justification: Protocol amendments co-trigger both the source system ICF amendments. Regulatory submissions and inspection readiness require direct traceability linking statistical plan changes to',
    `inspection_finding_id` BIGINT COMMENT 'Foreign key linking to compliance.inspection_finding. Business justification: SAP amendments are frequently triggered by regulatory authority inspection findings that identify deficiencies in statistical methodology.',
    `rand_scheme_id` BIGINT COMMENT 'Foreign key linking to randomization.rand_scheme. Business justification: SAP amendments triggered by randomization scheme changes (randomization_scheme_changed flag) must trace to the specific rand_scheme version that drove the amendment.',
    `regulatory_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to regulatory.protocol_amendment. Business justification: the source system co-submitted with or triggered by protocol amendments. The the source system (plain text denormalization).',
    `sap_id` BIGINT COMMENT 'Reference to the parent Statistical Analysis Plan document that this amendment revises. Links the amendment to the base the source system',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this the source system issued. Enables study-level traceability of all the source system',
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

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` (
    `analysis_population_id` BIGINT COMMENT 'Unique surrogate identifier for the analysis population record within the biostatistics data product. Primary key for the analysis_population entity.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Analysis populations (ITT, PP, Safety) are formally defined in the protocol. Regulatory submissions (ICH E9, FDA guidance) require direct traceability from population definitions to the',
    `rand_scheme_id` BIGINT COMMENT 'Foreign key linking to randomization.rand_scheme. Business justification: Analysis populations (ITT, PP, Safety) are defined relative to a randomization scheme — randomization_required_flag and population_logic_summary depend on scheme-specific allocation',
    `regulatory_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to regulatory.regulatory_protocol_amendment. Business justification: Protocol amendments frequently change population definitions (inclusion/exclusion criteria).',
    `sap_id` BIGINT COMMENT 'Reference to the Statistical Analysis Plan (the source system) document version that formally defines and governs this analysis population. Ensures traceability from population definition to the authoritative the source system.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this analysis population is defined. Links the population definition to its parent study context.',
    `submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission. Business justification: analysis_population has submission_population_flag and regulatory_primary_flag attributes confirming direct submission relevance.',
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

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` (
    `sample_size_calc_id` BIGINT COMMENT 'Unique surrogate identifier for each sample size calculation record within the biostatistics domain.',
    `analysis_population_id` BIGINT COMMENT 'Foreign key linking to biostatistics.analysis_population. Business justification: sample_size_calc has analysis_population (STRING) indicating which population the sample size calculation targets.',
    `arm_id` BIGINT COMMENT 'Foreign key linking to study.arm. Business justification: Sample size calculations are performed per treatment arm (sample_size_per_arm is a key attribute).',
    `endpoint_id` BIGINT COMMENT 'Foreign key linking to study.endpoint. Business justification: Sample size calculations are driven by the primary endpoints effect size and variability assumptions.',
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

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` (
    `adam_dataset_spec_id` BIGINT COMMENT 'Unique surrogate identifier for each ADaM dataset specification record. Primary key for this entity. Role: MASTER_RESOURCE.',
    `analysis_population_id` BIGINT COMMENT 'Foreign key linking to biostatistics.analysis_population. Business justification: adam_dataset_spec has analysis_population (STRING) indicating which analysis population the dataset serves.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.compliance_sop. Business justification: ADaM dataset programming and validation are governed by specific programming SOPs distinct from TLF output SOPs.',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: ADaM specifications are HA-specific: FDA requires CDISC ADaM IG compliance while EMA has distinct requirements.',
    `sap_id` BIGINT COMMENT 'Reference to the Statistical Analysis Plan that governs the derivation rules and analysis objectives for this ADaM dataset. Ensures traceability from dataset design to the approved the source system.',
    `sdtm_dataset_id` BIGINT COMMENT 'Foreign key linking to datamanagement.sdtm_dataset. Business justification: ADaM dataset specs are derived from specific SDTM datasets. Biostatisticians and programmers reference the source SDTM dataset record for version, QC status, and data cut date',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this ADaM dataset specification is authored. Links the specification to its parent protocol and study context.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: ADaM dataset specifications are versioned against protocol amendments — CDISC standards and FDA/EMA submission requirements mandate traceability between dataset specs and the',
    `submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission. Business justification: adam_dataset_spec has submission_flag attribute confirming datasets are submitted to health authorities.',
    `treatment_arm_id` BIGINT COMMENT 'Foreign key linking to randomization.treatment_arm. Business justification: ADaM dataset specs define ARM variables (ACTARM, TRTPN) that map directly to randomization treatment arms.',
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

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` (
    `tlf_shell_id` BIGINT COMMENT 'Unique surrogate identifier for each TLF shell specification record in the catalog. Primary key for the tlf_shell data product.',
    `adam_dataset_spec_id` BIGINT COMMENT 'Foreign key linking to biostatistics.adam_dataset_spec. Business justification: tlf_shell has adam_dataset_name (STRING) referencing the ADaM dataset that feeds the TLF shell.',
    `analysis_population_id` BIGINT COMMENT 'Foreign key linking to biostatistics.analysis_population. Business justification: tlf_shell has display_population (STRING) referencing the analysis population displayed in the TLF.',
    `arm_id` BIGINT COMMENT 'Foreign key linking to study.study_arm. Business justification: TLF shells are authored for specific treatment arms (e.g., Treatment A 100mg vs. Placebo). tlf_shell.treatment_arm is a denormalized text field.',
    `blinding_config_id` BIGINT COMMENT 'Foreign key linking to randomization.blinding_config. Business justification: tlf_shell.blinding_status controls which statisticians can access each shell.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.compliance_sop. Business justification: TLF shell design and approval follow a specific SOP governing output shell standards, formatting, and review.',
    `endpoint_id` BIGINT COMMENT 'Foreign key linking to study.study_endpoint. Business justification: TLF shells are authored for specific protocol endpoints (primary, secondary, exploratory).',
    `randomization_treatment_arm_id` BIGINT COMMENT 'Foreign key linking to randomization.treatment_arm. Business justification: TLF shells are produced by treatment arm — the treatment_arm plain text field is a denormalized reference to the treatment_arm entity.',
    `sap_id` BIGINT COMMENT 'Reference to the Statistical Analysis Plan version that governs this TLF output. Ensures traceability from output to the authorizing the source system',
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

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` (
    `tlf_output_id` BIGINT COMMENT 'Unique system-generated identifier for each produced TLF output instance. Serves as the primary key for the tlf_output data product within the biostatistics domain.',
    `adam_dataset_spec_id` BIGINT COMMENT 'Reference to the specific ADaM dataset version used as input for generating this TLF output, ensuring full traceability from output back to source analysis data.',
    `analysis_population_id` BIGINT COMMENT 'Foreign key linking to biostatistics.analysis_population. Business justification: tlf_output has analysis_population (STRING) indicating which population the output covers.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.compliance_sop. Business justification: TLF outputs (tables, listings, figures) are formal contractual deliverables with acceptance criteria and billing milestone triggers.',
    `interim_analysis_id` BIGINT COMMENT 'Foreign key linking to biostatistics.interim_analysis. Business justification: TLF outputs can be produced specifically for interim analyses (interim_analysis_flag exists on tlf_output).',
    `sap_id` BIGINT COMMENT 'Reference to the Statistical Analysis Plan (the source system) version that governs the analysis methodology, population definitions, and output specifications for this TLF.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this TLF output was produced. Links the output to the governing study protocol and sponsor context.',
    `tlf_shell_id` BIGINT COMMENT 'Reference to the TLF shell specification that defines the structure, layout, and metadata template from which this output was produced.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Final TLF outputs (tables, listings, figures) are filed as TMF essential documents and referenced in CSRs and regulatory submissions.',
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

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` (
    `interim_analysis_id` BIGINT COMMENT 'Unique surrogate identifier for each interim analysis record within the clinical trial biostatistics domain.',
    `analysis_population_id` BIGINT COMMENT 'Foreign key linking to biostatistics.analysis_population. Business justification: interim_analysis has analysis_population (STRING) indicating which population was analyzed at the interim.',
    `application_id` BIGINT COMMENT 'Foreign key linking to regulatory.application. Business justification: Interim analysis outcomes (stopping_rule_triggered, analysis_outcome, conditional_power) directly drive go/no-go decisions for the pipeline assets phase progression.',
    `blinding_config_id` BIGINT COMMENT 'Foreign key linking to randomization.blinding_config. Business justification: Interim analyses must operate under a defined blinding configuration governing firewall maintenance, unblinding scope, and independent statistician access.',
    `clinical_trial_authorization_id` BIGINT COMMENT 'Foreign key linking to regulatory.clinical_trial_authorization. Business justification: Under EU CTR, interim analyses in adaptive designs may trigger substantial CTA modifications.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.compliance_sop. Business justification: Interim analyses are governed by specific SOPs covering unblinding procedures, firewall maintenance, DSMB interaction, and alpha spending.',
    `database_lock_event_id` BIGINT COMMENT 'Foreign key linking to biostatistics.database_lock_event. Business justification: An interim analysis is performed on data that has been locked via a database lock event.',
    `epoch_id` BIGINT COMMENT 'Foreign key linking to study.study_epoch. Business justification: Interim analyses are planned at epoch boundaries (end of treatment epoch, end of follow-up).',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.study_milestone. Business justification: Interim analyses are tracked as critical-path milestones in CTMS. Linking interim_analysis to study_milestone enables integrated timeline management, contractual milestone reporting to',
    `rand_list_id` BIGINT COMMENT 'Foreign key linking to randomization.rand_list. Business justification: Interim analyses are conducted on subjects randomized under a specific rand_list version active at the data cutoff date.',
    `sap_id` BIGINT COMMENT 'Reference to the Statistical Analysis Plan (the source system) version that governs the methodology and pre-specified rules for this interim analysis.',
    `sdtm_dataset_id` BIGINT COMMENT 'Foreign key linking to datamanagement.sdtm_dataset. Business justification: Each interim analysis uses a specific locked SDTM dataset version at the data cutoff date.',
    `stratification_factor_id` BIGINT COMMENT 'Foreign key linking to randomization.stratification_factor. Business justification: Interim analyses use stratification factors as covariates in statistical models.',
    `study_id` BIGINT COMMENT 'Reference to the parent clinical study for which this interim analysis is conducted.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: Interim analyses in adaptive trials are frequently triggered by or associated with protocol amendments (safety-driven adaptations, sample size re-estimation).',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Interim analysis reports, DSMB packages, and unblinding memos are ICH E6 R2 essential TMF documents. Regulatory inspectors verify these filings.',
    `treatment_arm_id` BIGINT COMMENT 'Foreign key linking to randomization.treatment_arm. Business justification: Interim analyses compute arm-specific statistics (conditional_power, efficacy_boundary_value, events_observed per arm).',
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

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` (
    `database_lock_event_id` BIGINT COMMENT 'Primary key for database_lock_event',
    `audit_id` BIGINT COMMENT 'Foreign key linking to compliance.audit. Business justification: Database lock events are subject to dedicated GCP audits reviewing lock documentation, query resolution completeness, and SAE reconciliation.',
    `blinding_config_id` BIGINT COMMENT 'Foreign key linking to randomization.blinding_config. Business justification: At database lock, the active blinding_config determines data access permissions and unblinding_required status.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.compliance_sop. Business justification: Database lock procedures are governed by a specific DBL SOP that defines pre-lock QC checklists, query resolution requirements, and lock authorization.',
    `dmp_id` BIGINT COMMENT 'add column dmp_id (BIGINT) with FK to datamanagement.dmp.dmp_id — database lock event should reference the data management plan that governs the lock process',
    `monitoring_plan_id` BIGINT COMMENT 'Foreign key linking to monitoring.monitoring_plan. Business justification: The database lock event must confirm that the monitoring plans SDV percentage threshold and visit completion requirements have been satisfied.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.study_milestone. Business justification: Database lock is a named critical-path milestone tracked in CTMS. Linking the biostatistics DBL event to the CTMS study_milestone enables timeline variance reporting, contractual',
    `rand_list_id` BIGINT COMMENT 'Foreign key linking to randomization.rand_list. Business justification: Pre-lock QC checklists require reconciliation of all randomized subjects in the locked dataset against the active rand_list version.',
    `sap_id` BIGINT COMMENT 'Foreign key linking to biostatistics.sap. Business justification: A database lock event is executed in the context of a specific Statistical Analysis Plan.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this database lock event applies. Links the DBL event to the parent study master record.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: Database lock events are associated with specific protocol amendment versions — regulatory agencies require traceability between data locks and the protocol version in effect',
    `submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission. Business justification: Database lock date is the critical data cutoff milestone that determines submission readiness for NDA/BLA packages.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Database lock memos are essential TMF documents per ICH E6 R2. The existing lock_memo_reference is a denormalized text reference; replacing it with a proper FK to tmf_document enforces',
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

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` (
    `statistical_endpoint_id` BIGINT COMMENT 'Unique surrogate identifier for each statistical endpoint record defined in the Statistical Analysis Plan (the source system). Primary key for the statistical_endpoint data product.',
    `adam_dataset_spec_id` BIGINT COMMENT 'Foreign key linking to biostatistics.adam_dataset_spec. Business justification: statistical_endpoint has adam_dataset_name (STRING) referencing the ADaM dataset used for the endpoint analysis.',
    `analysis_population_id` BIGINT COMMENT 'Foreign key linking to biostatistics.analysis_population. Business justification: statistical_endpoint has analysis_population as a STRING field referencing the population for the endpoint analysis.',
    `lab_panel_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_analyte. Business justification: Statistical endpoints (e.g., change from baseline in HbA1c, CTCAE grade for ALT) are defined in terms of specific lab analytes.',
    `protocol_endpoint_id` BIGINT COMMENT 'Foreign key linking to study.study_endpoint. Business justification: ICH E9(R1) and regulatory submissions require explicit traceability from the source system to protocol-defined endpoints.',
    `sap_id` BIGINT COMMENT 'Reference to the Statistical Analysis Plan (the source system) document version in which this endpoint is formally defined. Links endpoint traceability from the source system TLF production.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this statistical endpoint is defined. Enables endpoint-level traceability to the study protocol.',
    `submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission. Business justification: statistical_endpoint has regulatory_designation field (primary, key secondary) confirming endpoints are submitted to health authorities.',
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

ALTER SCHEMA `clinical_trials_mvm`.`biostatistics` SET TAGS ('dbx_division' = 'operations');

ALTER SCHEMA `clinical_trials_mvm`.`biostatistics` SET TAGS ('dbx_domain' = 'biostatistics');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` SET TAGS ('dbx_domain' = 'biostatistics');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` SET TAGS ('dbx_subdomain' = 'analysis_planning');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) ID');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `audit_finding_id` SET TAGS ('dbx_business_glossary_term' = 'Audit Finding Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `blinding_config_id` SET TAGS ('dbx_business_glossary_term' = 'Blinding Config Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Regulatory Strategy Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `rand_scheme_id` SET TAGS ('dbx_business_glossary_term' = 'Rand Scheme Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `regulatory_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `adam_dataset_specifications` SET TAGS ('dbx_business_glossary_term' = 'Analysis Data Model (ADaM) Dataset Specifications');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `amendment_number` SET TAGS ('dbx_business_glossary_term' = 'SAP Amendment Number');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `amendment_rationale` SET TAGS ('dbx_business_glossary_term' = 'SAP Amendment Rationale');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `analysis_type` SET TAGS ('dbx_business_glossary_term' = 'SAP Analysis Type');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `analysis_type` SET TAGS ('dbx_value_regex' = 'interim|final|post_hoc|exploratory');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'SAP Approval Date');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `authoring_system` SET TAGS ('dbx_business_glossary_term' = 'SAP Authoring System');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `authoring_system` SET TAGS ('dbx_value_regex' = 'SAS Drug Development|Veeva Vault|Word|other');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `blinding_status` SET TAGS ('dbx_business_glossary_term' = 'SAP Blinding Status');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `blinding_status` SET TAGS ('dbx_value_regex' = 'blinded|unblinded|partially_unblinded');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `blinding_status` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'SAP Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `dbl_date` SET TAGS ('dbx_business_glossary_term' = 'Database Lock (DBL) Date');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `dsmb_review_required` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Review Required Flag');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `effective_from` SET TAGS ('dbx_business_glossary_term' = 'SAP Effective From Date');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `effective_until` SET TAGS ('dbx_business_glossary_term' = 'SAP Effective Until Date');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `estimand_description` SET TAGS ('dbx_implements' = 'ICH_E9(R1).Estimand');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `estimand_description` SET TAGS ('dbx_standard' = 'ICH_E9R1');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `interim_analysis_count` SET TAGS ('dbx_business_glossary_term' = 'Planned Interim Analysis Count');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `is_current_version` SET TAGS ('dbx_business_glossary_term' = 'Is Current Version Flag');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `itt_population_definition` SET TAGS ('dbx_business_glossary_term' = 'Intent-to-Treat (ITT) Population Definition');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `itt_population_definition` SET TAGS ('dbx_implements' = 'ICH_E9.ITT');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `itt_population_definition` SET TAGS ('dbx_standard' = 'ICH_E9');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `missing_data_strategy` SET TAGS ('dbx_business_glossary_term' = 'Missing Data Handling Strategy');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `missing_data_strategy` SET TAGS ('dbx_implements' = 'ICH_E9(R1).IntercurrentEventStrategy');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `missing_data_strategy` SET TAGS ('dbx_standard' = 'ICH_E9R1');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `multiplicity_adjustment_method` SET TAGS ('dbx_implements' = 'ICH_E9.MultiplicityAdjustment');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `multiplicity_adjustment_method` SET TAGS ('dbx_standard' = 'ICH_E9');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `multiplicity_adjustment_method` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) Number');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `number` SET TAGS ('dbx_value_regex' = '^SAP-[A-Z0-9]{2,20}-[0-9]{3}$');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `power_percent` SET TAGS ('dbx_business_glossary_term' = 'Statistical Power Percentage');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `pp_population_definition` SET TAGS ('dbx_business_glossary_term' = 'Per Protocol (PP) Population Definition');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `pp_population_definition` SET TAGS ('dbx_implements' = 'ICH_E9.PerProtocol');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `pp_population_definition` SET TAGS ('dbx_standard' = 'ICH_E9');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `regulatory_impact` SET TAGS ('dbx_business_glossary_term' = 'SAP Regulatory Impact Classification');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `regulatory_impact` SET TAGS ('dbx_value_regex' = 'none|minor|major|requires_submission');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `safety_population_definition` SET TAGS ('dbx_business_glossary_term' = 'Safety Analysis Population Definition');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `safety_population_definition` SET TAGS ('dbx_implements' = 'ICH_E9.SafetyPopulation');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `safety_population_definition` SET TAGS ('dbx_standard' = 'ICH_E9');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `sample_size` SET TAGS ('dbx_business_glossary_term' = 'Planned Sample Size');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `sections_modified` SET TAGS ('dbx_business_glossary_term' = 'SAP Sections Modified');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `significance_level` SET TAGS ('dbx_business_glossary_term' = 'Statistical Significance Level (Alpha)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `significance_level` SET TAGS ('dbx_implements' = 'ICH_E9.SignificanceLevel');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `significance_level` SET TAGS ('dbx_standard' = 'ICH_E9');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'SAP Title');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `tlf_specifications` SET TAGS ('dbx_business_glossary_term' = 'Tables, Listings, and Figures (TLF) Specifications');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `unblinding_date` SET TAGS ('dbx_business_glossary_term' = 'SAP Unblinding Date');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `unblinding_date` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'SAP Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'SAP Version Number');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+(.[0-9]+)?$');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `version_status` SET TAGS ('dbx_business_glossary_term' = 'SAP Version Status');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ALTER COLUMN `version_status` SET TAGS ('dbx_value_regex' = 'draft|in_review|approved|superseded|retired');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ADD CONSTRAINT `fk_biostatistics_sap_amendment_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` SET TAGS ('dbx_domain' = 'biostatistics');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` SET TAGS ('dbx_subdomain' = 'analysis_planning');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `sap_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) Amendment ID');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `audit_finding_id` SET TAGS ('dbx_business_glossary_term' = 'Audit Finding Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `blinding_config_id` SET TAGS ('dbx_business_glossary_term' = 'Blinding Config Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `icf_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Icf Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `inspection_finding_id` SET TAGS ('dbx_business_glossary_term' = 'Inspection Finding Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `rand_scheme_id` SET TAGS ('dbx_business_glossary_term' = 'Rand Scheme Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `regulatory_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) ID');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study ID');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'eTMF Document ID');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `adam_dataset_impact` SET TAGS ('dbx_business_glossary_term' = 'Analysis Data Model (ADaM) Dataset Impact');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `amendment_rationale` SET TAGS ('dbx_business_glossary_term' = 'SAP Amendment Rationale');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `amendment_status` SET TAGS ('dbx_business_glossary_term' = 'SAP Amendment Status');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `amendment_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|superseded|withdrawn');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `amendment_title` SET TAGS ('dbx_business_glossary_term' = 'SAP Amendment Title');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `amendment_type` SET TAGS ('dbx_business_glossary_term' = 'SAP Amendment Type');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `amendment_type` SET TAGS ('dbx_value_regex' = 'major|minor|administrative');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `amendment_version_code` SET TAGS ('dbx_business_glossary_term' = 'SAP Amendment Version Code');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `amendment_version_code` SET TAGS ('dbx_value_regex' = '^v[0-9]+.[0-9]+(.[0-9]+)?$');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `analysis_population_changed` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Changed Flag');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'SAP Amendment Approval Date');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `approver_name` SET TAGS ('dbx_business_glossary_term' = 'SAP Amendment Approver Name');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `approver_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `approver_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `author_name` SET TAGS ('dbx_business_glossary_term' = 'SAP Amendment Author Name');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `author_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `author_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `authored_date` SET TAGS ('dbx_business_glossary_term' = 'SAP Amendment Authored Date');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `blinding_impact` SET TAGS ('dbx_business_glossary_term' = 'Blinding Impact Classification');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `blinding_impact` SET TAGS ('dbx_value_regex' = 'none|potential_unblinding|unblinding_required');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `change_summary` SET TAGS ('dbx_business_glossary_term' = 'SAP Amendment Change Summary');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `dbl_date` SET TAGS ('dbx_business_glossary_term' = 'Database Lock (DBL) Date');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `dsmb_notification_required` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Notification Required Flag');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'SAP Amendment Effective Date');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `interim_analysis_changed` SET TAGS ('dbx_business_glossary_term' = 'Interim Analysis Changed Flag');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `irb_iec_notification_required` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Notification Required Flag');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `missing_data_method_changed` SET TAGS ('dbx_business_glossary_term' = 'Missing Data Handling Method Changed Flag');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `pre_dbl_flag` SET TAGS ('dbx_business_glossary_term' = 'Pre-Database Lock (DBL) Flag');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `primary_endpoint_changed` SET TAGS ('dbx_business_glossary_term' = 'Primary Endpoint Changed Flag');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `randomization_scheme_changed` SET TAGS ('dbx_business_glossary_term' = 'Randomization Scheme Changed Flag');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `regulatory_impact_assessment` SET TAGS ('dbx_value_regex' = 'none|low|medium|high|critical');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `regulatory_notification_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Notification Required Flag');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `review_completed_date` SET TAGS ('dbx_business_glossary_term' = 'SAP Amendment Review Completed Date');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `sample_size_changed` SET TAGS ('dbx_business_glossary_term' = 'Sample Size Changed Flag');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `sas_program_reference` SET TAGS ('dbx_business_glossary_term' = 'SAS Drug Development Program Reference');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `sections_modified` SET TAGS ('dbx_business_glossary_term' = 'SAP Sections Modified');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `sponsor_signatory_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `sponsor_signatory_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `superseded_date` SET TAGS ('dbx_business_glossary_term' = 'SAP Amendment Superseded Date');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `tlf_impact` SET TAGS ('dbx_business_glossary_term' = 'Tables, Listings, and Figures (TLF) Impact');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ADD CONSTRAINT `fk_biostatistics_analysis_population_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` SET TAGS ('dbx_domain' = 'biostatistics');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` SET TAGS ('dbx_subdomain' = 'analysis_planning');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `rand_scheme_id` SET TAGS ('dbx_business_glossary_term' = 'Rand Scheme Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `regulatory_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) ID');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `acronym` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Acronym');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `acronym` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,10}$');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `adam_dataset_name` SET TAGS ('dbx_business_glossary_term' = 'Analysis Data Model (ADaM) Dataset Name');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `adam_dataset_name` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,8}$');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `adam_dataset_name` SET TAGS ('dbx_implements' = 'ADaMIG.DatasetName');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `adam_dataset_name` SET TAGS ('dbx_standard' = 'CDISC_ADaM');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `adam_dataset_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `adsl_flag_variable` SET TAGS ('dbx_business_glossary_term' = 'Analysis Data Subject-Level (ADSL) Flag Variable Name');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `adsl_flag_variable` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,8}FL$');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `adsl_flag_variable` SET TAGS ('dbx_implements' = 'ADaMIG.ADSL.PopulationFlag');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `adsl_flag_variable` SET TAGS ('dbx_standard' = 'CDISC_ADaM');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `analysis_phase` SET TAGS ('dbx_value_regex' = 'interim|final|post_hoc|exploratory');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `blinding_status` SET TAGS ('dbx_value_regex' = 'blinded|unblinded|open_label');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `cdisc_standard_version` SET TAGS ('dbx_business_glossary_term' = 'Clinical Data Interchange Standards Consortium (CDISC) Standard Version');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `cdisc_standard_version` SET TAGS ('dbx_implements' = 'ADaMIG.Version');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `cdisc_standard_version` SET TAGS ('dbx_standard' = 'CDISC_ADaM');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `dbl_date` SET TAGS ('dbx_business_glossary_term' = 'Database Lock (DBL) Date');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `effective_from_date` SET TAGS ('dbx_business_glossary_term' = 'Population Definition Effective From Date');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `exclusion_criteria_description` SET TAGS ('dbx_business_glossary_term' = 'Population Exclusion Criteria Description');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `inclusion_criteria_description` SET TAGS ('dbx_business_glossary_term' = 'Population Inclusion Criteria Description');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `missing_endpoint_handling` SET TAGS ('dbx_business_glossary_term' = 'Missing Endpoint Handling Method');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `missing_endpoint_handling` SET TAGS ('dbx_value_regex' = 'locf|bocf|wocf|multiple_imputation|observed_cases|none');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Notes');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `population_code` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Code');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `population_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,20}$');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `population_finalized_date` SET TAGS ('dbx_business_glossary_term' = 'Population Definition Finalized Date');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `population_name` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Name');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `population_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `population_rationale` SET TAGS ('dbx_business_glossary_term' = 'Population Definition Rationale');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `population_status` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Status');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `population_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|superseded|retired');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `population_type` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Type');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `population_type` SET TAGS ('dbx_implements' = 'ICH_E9.AnalysisPopulation');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `population_type` SET TAGS ('dbx_standard' = 'ICH_E9');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `primary_population_flag` SET TAGS ('dbx_business_glossary_term' = 'Primary Analysis Population Flag');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `regulatory_primary_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Primary Population Flag');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `sap_section_reference` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) Section Reference');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `sap_version` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) Version');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `sap_version` SET TAGS ('dbx_value_regex' = '^vd+.d+$');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `sas_program_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `sensitivity_analysis_flag` SET TAGS ('dbx_business_glossary_term' = 'Sensitivity Analysis Population Flag');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `subject_count_at_dbl` SET TAGS ('dbx_business_glossary_term' = 'Subject Count at Database Lock (DBL)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `subject_count_interim` SET TAGS ('dbx_business_glossary_term' = 'Subject Count at Interim Analysis');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `submission_population_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission Population Flag');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `tlf_shell_reference` SET TAGS ('dbx_business_glossary_term' = 'Tables, Listings, and Figures (TLF) Shell Reference');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `validation_status` SET TAGS ('dbx_business_glossary_term' = 'ADaM Validation Status');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ALTER COLUMN `validation_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|validated|failed');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ADD CONSTRAINT `fk_biostatistics_sample_size_calc_analysis_population_id` FOREIGN KEY (`analysis_population_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`analysis_population`(`analysis_population_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ADD CONSTRAINT `fk_biostatistics_sample_size_calc_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` SET TAGS ('dbx_domain' = 'biostatistics');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` SET TAGS ('dbx_subdomain' = 'analysis_planning');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `sample_size_calc_id` SET TAGS ('dbx_business_glossary_term' = 'Sample Size Calculation ID');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `analysis_population_id` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `arm_id` SET TAGS ('dbx_business_glossary_term' = 'Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `endpoint_id` SET TAGS ('dbx_business_glossary_term' = 'Endpoint Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `rand_scheme_id` SET TAGS ('dbx_business_glossary_term' = 'Rand Scheme Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) ID');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `accrual_period_months` SET TAGS ('dbx_business_glossary_term' = 'Assumed Accrual Period (Months)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `alpha_level` SET TAGS ('dbx_business_glossary_term' = 'Alpha Level (Type I Error Rate)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `alpha_spending_method` SET TAGS ('dbx_value_regex' = 'OBrien_Fleming|Pocock|Lan_DeMets|Haybittle_Peto|none');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `calc_date` SET TAGS ('dbx_business_glossary_term' = 'Calculation Date');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `calc_identifier` SET TAGS ('dbx_business_glossary_term' = 'Calculation Identifier');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `calc_status` SET TAGS ('dbx_business_glossary_term' = 'Calculation Status');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `calc_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|superseded|archived');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `calc_version` SET TAGS ('dbx_business_glossary_term' = 'Calculation Version');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `calc_version` SET TAGS ('dbx_value_regex' = '^vd+.d+$');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `dropout_rate` SET TAGS ('dbx_business_glossary_term' = 'Assumed Dropout Rate');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `effect_size` SET TAGS ('dbx_business_glossary_term' = 'Assumed Effect Size');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `event_rate_control` SET TAGS ('dbx_business_glossary_term' = 'Assumed Event Rate (Control Arm)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `event_rate_treatment` SET TAGS ('dbx_business_glossary_term' = 'Assumed Event Rate (Treatment Arm)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `event_rate_treatment` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `event_rate_treatment` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `follow_up_period_months` SET TAGS ('dbx_business_glossary_term' = 'Assumed Follow-Up Period (Months)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `hypothesis_type` SET TAGS ('dbx_value_regex' = 'superiority|non_inferiority|equivalence|one_sided|two_sided');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `interim_analysis_planned` SET TAGS ('dbx_business_glossary_term' = 'Interim Analysis Planned Flag');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `median_survival_control` SET TAGS ('dbx_business_glossary_term' = 'Assumed Median Survival (Control Arm)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `non_inferiority_margin` SET TAGS ('dbx_business_glossary_term' = 'Non-Inferiority Margin');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `number_of_arms` SET TAGS ('dbx_business_glossary_term' = 'Number of Treatment Arms');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `power` SET TAGS ('dbx_business_glossary_term' = 'Statistical Power (1 - Beta)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `primary_endpoint_type` SET TAGS ('dbx_value_regex' = 'continuous|binary|time_to_event|ordinal|count');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `reference_source` SET TAGS ('dbx_business_glossary_term' = 'Assumption Reference Source');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `sample_size_per_arm` SET TAGS ('dbx_business_glossary_term' = 'Calculated Sample Size Per Arm');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `software_name` SET TAGS ('dbx_business_glossary_term' = 'Statistical Software Name');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `software_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `software_version` SET TAGS ('dbx_business_glossary_term' = 'Statistical Software Version');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `standard_deviation` SET TAGS ('dbx_business_glossary_term' = 'Assumed Standard Deviation');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `statistical_method` SET TAGS ('dbx_business_glossary_term' = 'Statistical Method Applied');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `study_design_type` SET TAGS ('dbx_value_regex' = 'parallel|crossover|factorial|adaptive|basket|umbrella');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `study_phase` SET TAGS ('dbx_value_regex' = 'Phase I|Phase II|Phase IIa|Phase IIb|Phase III|Phase IV');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `test_sidedness` SET TAGS ('dbx_value_regex' = 'one_sided|two_sided');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `total_sample_size` SET TAGS ('dbx_business_glossary_term' = 'Total Calculated Sample Size');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ADD CONSTRAINT `fk_biostatistics_adam_dataset_spec_analysis_population_id` FOREIGN KEY (`analysis_population_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`analysis_population`(`analysis_population_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ADD CONSTRAINT `fk_biostatistics_adam_dataset_spec_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` SET TAGS ('dbx_domain' = 'biostatistics');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` SET TAGS ('dbx_subdomain' = 'results_reporting');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `adam_dataset_spec_id` SET TAGS ('dbx_business_glossary_term' = 'Analysis Data Model (ADaM) Dataset Specification ID');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `analysis_population_id` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) ID');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `sdtm_dataset_id` SET TAGS ('dbx_business_glossary_term' = 'Sdtm Dataset Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Study Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_business_glossary_term' = 'Treatment Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `adam_ig_version` SET TAGS ('dbx_business_glossary_term' = 'ADaM Implementation Guide (IG) Version');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `adam_ig_version` SET TAGS ('dbx_implements' = 'ADaMIG.Version');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `adam_ig_version` SET TAGS ('dbx_standard' = 'CDISC_ADaM');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Specification Approval Date');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `authored_by` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `authored_by` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `blinding_status` SET TAGS ('dbx_value_regex' = 'Blinded|Unblinded|Open-Label');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `blinding_status` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `codelist_name` SET TAGS ('dbx_implements' = 'CDISC_CT.CodelistName');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `codelist_name` SET TAGS ('dbx_standard' = 'CDISC_CT');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `codelist_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `controlled_terminology` SET TAGS ('dbx_business_glossary_term' = 'Controlled Terminology Reference');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `controlled_terminology` SET TAGS ('dbx_implements' = 'CDISC_CT.Codelist');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `controlled_terminology` SET TAGS ('dbx_standard' = 'CDISC_CT');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `core_designation` SET TAGS ('dbx_business_glossary_term' = 'CDISC ADaM Core Designation');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `core_designation` SET TAGS ('dbx_value_regex' = 'Required|Expected|Permissible');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `core_designation` SET TAGS ('dbx_implements' = 'ADaMIG.Core');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `core_designation` SET TAGS ('dbx_standard' = 'CDISC_ADaM');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `dataset_class` SET TAGS ('dbx_business_glossary_term' = 'ADaM Dataset Class');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `dataset_class` SET TAGS ('dbx_value_regex' = 'ADSL|BDS|OCCDS|OTHER');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `dataset_class` SET TAGS ('dbx_implements' = 'ADaMIG.DatasetClass');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `dataset_class` SET TAGS ('dbx_standard' = 'CDISC_ADaM');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `dataset_label` SET TAGS ('dbx_business_glossary_term' = 'ADaM Dataset Label');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `dataset_label` SET TAGS ('dbx_implements' = 'ADaMIG.DatasetLabel');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `dataset_label` SET TAGS ('dbx_standard' = 'CDISC_ADaM');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `dataset_name` SET TAGS ('dbx_business_glossary_term' = 'ADaM Dataset Name');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `dataset_name` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,8}$');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `dataset_name` SET TAGS ('dbx_implements' = 'ADaMIG.DatasetName');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `dataset_name` SET TAGS ('dbx_standard' = 'CDISC_ADaM');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `dataset_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `dataset_purpose` SET TAGS ('dbx_business_glossary_term' = 'ADaM Dataset Purpose');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `define_xml_version` SET TAGS ('dbx_business_glossary_term' = 'Define-XML Version');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `define_xml_version` SET TAGS ('dbx_implements' = 'DefineXML.Version');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `define_xml_version` SET TAGS ('dbx_standard' = 'CDISC_DefineXML');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `derivation_algorithm` SET TAGS ('dbx_business_glossary_term' = 'Variable Derivation Algorithm');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `pinnacle21_validation_status` SET TAGS ('dbx_value_regex' = 'Pass|Pass with Warnings|Fail|Not Run');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `programming_language` SET TAGS ('dbx_value_regex' = 'SAS|R|Python|Other');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `programming_language` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `qc_method` SET TAGS ('dbx_business_glossary_term' = 'Quality Control (QC) Method');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `qc_method` SET TAGS ('dbx_value_regex' = 'Double Programming|Peer Review|Independent QC|Not Required');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `qc_status` SET TAGS ('dbx_business_glossary_term' = 'Quality Control (QC) Status');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `qc_status` SET TAGS ('dbx_value_regex' = 'Not Started|In Progress|QC Complete|Failed QC');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `spec_status` SET TAGS ('dbx_business_glossary_term' = 'Specification Lifecycle Status');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `spec_status` SET TAGS ('dbx_value_regex' = 'Draft|Under Review|Approved|Superseded|Retired');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `spec_version` SET TAGS ('dbx_business_glossary_term' = 'Specification Version');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `spec_version` SET TAGS ('dbx_value_regex' = '^d+.d+$');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `submission_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission Flag');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `variable_label` SET TAGS ('dbx_business_glossary_term' = 'ADaM Variable Label');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `variable_label` SET TAGS ('dbx_implements' = 'ADaMIG.VariableLabel');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `variable_label` SET TAGS ('dbx_standard' = 'CDISC_ADaM');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `variable_length` SET TAGS ('dbx_business_glossary_term' = 'ADaM Variable Length');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `variable_name` SET TAGS ('dbx_business_glossary_term' = 'ADaM Variable Name');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `variable_name` SET TAGS ('dbx_value_regex' = '^[A-Z][A-Z0-9]{0,7}$');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `variable_name` SET TAGS ('dbx_implements' = 'ADaMIG.VariableName');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `variable_name` SET TAGS ('dbx_standard' = 'CDISC_ADaM');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `variable_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `variable_type` SET TAGS ('dbx_business_glossary_term' = 'ADaM Variable Type');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `variable_type` SET TAGS ('dbx_value_regex' = 'Char|Num');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `variable_type` SET TAGS ('dbx_implements' = 'ADaMIG.VariableType');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ALTER COLUMN `variable_type` SET TAGS ('dbx_standard' = 'CDISC_ADaM');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ADD CONSTRAINT `fk_biostatistics_tlf_shell_adam_dataset_spec_id` FOREIGN KEY (`adam_dataset_spec_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec`(`adam_dataset_spec_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ADD CONSTRAINT `fk_biostatistics_tlf_shell_analysis_population_id` FOREIGN KEY (`analysis_population_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`analysis_population`(`analysis_population_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ADD CONSTRAINT `fk_biostatistics_tlf_shell_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` SET TAGS ('dbx_domain' = 'biostatistics');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` SET TAGS ('dbx_subdomain' = 'results_reporting');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `tlf_shell_id` SET TAGS ('dbx_business_glossary_term' = 'Table Listing Figure (TLF) Shell ID');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `adam_dataset_spec_id` SET TAGS ('dbx_business_glossary_term' = 'Adam Dataset Spec Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `analysis_population_id` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `arm_id` SET TAGS ('dbx_business_glossary_term' = 'Study Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `blinding_config_id` SET TAGS ('dbx_business_glossary_term' = 'Blinding Config Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `endpoint_id` SET TAGS ('dbx_business_glossary_term' = 'Study Endpoint Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `randomization_treatment_arm_id` SET TAGS ('dbx_business_glossary_term' = 'Randomization Treatment Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `randomization_treatment_arm_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `randomization_treatment_arm_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) ID');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `abbreviations` SET TAGS ('dbx_business_glossary_term' = 'TLF Abbreviations List');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `analysis_timepoint` SET TAGS ('dbx_value_regex' = 'interim|final|both');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `analysis_visit` SET TAGS ('dbx_business_glossary_term' = 'Analysis Visit Window');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `approved_by` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `approved_by` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `blinding_status` SET TAGS ('dbx_business_glossary_term' = 'TLF Blinding Status');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `blinding_status` SET TAGS ('dbx_value_regex' = 'blinded|unblinded|open_label');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `blinding_status` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `change_reason` SET TAGS ('dbx_business_glossary_term' = 'Shell Change Reason');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `csr_section_reference` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study Report (CSR) Section Reference');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `ctcae_version` SET TAGS ('dbx_business_glossary_term' = 'Common Terminology Criteria for Adverse Events (CTCAE) Version');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `ctcae_version` SET TAGS ('dbx_implements' = 'CTCAE.Version');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `ctcae_version` SET TAGS ('dbx_standard' = 'NCI_CTCAE');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `display_format` SET TAGS ('dbx_business_glossary_term' = 'TLF Display Format');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `display_format` SET TAGS ('dbx_value_regex' = 'rtf|pdf|sas7bdat|xlsx');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `footnotes` SET TAGS ('dbx_business_glossary_term' = 'TLF Footnotes');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `is_primary_endpoint` SET TAGS ('dbx_business_glossary_term' = 'Primary Endpoint Indicator');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `is_regulatory_submission` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission Indicator');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `locf_flag` SET TAGS ('dbx_business_glossary_term' = 'Last Observation Carried Forward (LOCF) Flag');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `meddra_soc` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) System Organ Class (SOC)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `meddra_soc` SET TAGS ('dbx_implements' = 'MedDRA.SOC');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `meddra_soc` SET TAGS ('dbx_standard' = 'MedDRA');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `orientation` SET TAGS ('dbx_business_glossary_term' = 'Page Orientation');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `orientation` SET TAGS ('dbx_value_regex' = 'portrait|landscape');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `output_category` SET TAGS ('dbx_business_glossary_term' = 'TLF Output Category');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `output_file_name` SET TAGS ('dbx_business_glossary_term' = 'TLF Output File Name');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `output_file_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `output_finalized_date` SET TAGS ('dbx_business_glossary_term' = 'TLF Output Finalized Date');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `output_number` SET TAGS ('dbx_business_glossary_term' = 'TLF Output Number');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `output_number` SET TAGS ('dbx_value_regex' = '^[A-Z]{1,3}-[0-9]{1,3}(.[0-9]{1,3})?$');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `output_title` SET TAGS ('dbx_business_glossary_term' = 'TLF Output Title');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `output_type` SET TAGS ('dbx_business_glossary_term' = 'TLF Output Type');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `output_type` SET TAGS ('dbx_value_regex' = 'table|listing|figure');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `page_size` SET TAGS ('dbx_value_regex' = 'A4|letter|legal');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `page_size` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `priority_tier` SET TAGS ('dbx_business_glossary_term' = 'TLF Priority Tier');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `priority_tier` SET TAGS ('dbx_value_regex' = 'tier_1|tier_2|tier_3');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `production_status` SET TAGS ('dbx_business_glossary_term' = 'TLF Production Status');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `production_status` SET TAGS ('dbx_value_regex' = 'draft|in_development|qc_review|approved|final|superseded');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `program_name` SET TAGS ('dbx_business_glossary_term' = 'SAS Program Name');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `program_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `program_path` SET TAGS ('dbx_business_glossary_term' = 'SAS Program File Path');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `qc_reviewer` SET TAGS ('dbx_business_glossary_term' = 'Quality Control (QC) Reviewer');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `qc_reviewer` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `qc_reviewer` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `sap_section_reference` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) Section Reference');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `shell_approved_date` SET TAGS ('dbx_business_glossary_term' = 'TLF Shell Approved Date');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `shell_created_date` SET TAGS ('dbx_business_glossary_term' = 'TLF Shell Created Date');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `shell_notes` SET TAGS ('dbx_business_glossary_term' = 'TLF Shell Notes');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `shell_version` SET TAGS ('dbx_business_glossary_term' = 'TLF Shell Version');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `shell_version` SET TAGS ('dbx_value_regex' = '^v[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ALTER COLUMN `statistical_method` SET TAGS ('dbx_business_glossary_term' = 'Statistical Method Description');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ADD CONSTRAINT `fk_biostatistics_tlf_output_adam_dataset_spec_id` FOREIGN KEY (`adam_dataset_spec_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec`(`adam_dataset_spec_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ADD CONSTRAINT `fk_biostatistics_tlf_output_analysis_population_id` FOREIGN KEY (`analysis_population_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`analysis_population`(`analysis_population_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ADD CONSTRAINT `fk_biostatistics_tlf_output_interim_analysis_id` FOREIGN KEY (`interim_analysis_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`interim_analysis`(`interim_analysis_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ADD CONSTRAINT `fk_biostatistics_tlf_output_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ADD CONSTRAINT `fk_biostatistics_tlf_output_tlf_shell_id` FOREIGN KEY (`tlf_shell_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`tlf_shell`(`tlf_shell_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` SET TAGS ('dbx_domain' = 'biostatistics');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` SET TAGS ('dbx_subdomain' = 'results_reporting');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `tlf_output_id` SET TAGS ('dbx_business_glossary_term' = 'Table Listing Figure (TLF) Output ID');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `adam_dataset_spec_id` SET TAGS ('dbx_business_glossary_term' = 'Analysis Data Model (ADaM) Dataset ID');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `analysis_population_id` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Deliverable Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `interim_analysis_id` SET TAGS ('dbx_business_glossary_term' = 'Interim Analysis Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) ID');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study ID');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `tlf_shell_id` SET TAGS ('dbx_business_glossary_term' = 'Table Listing Figure (TLF) Shell ID');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `analysis_type` SET TAGS ('dbx_value_regex' = 'primary|secondary|exploratory|interim|sensitivity');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'TLF Approval Status');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|rejected|superseded');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'TLF Approval Timestamp');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `blinding_status` SET TAGS ('dbx_value_regex' = 'blinded|unblinded');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `blinding_status` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'TLF Output Comments');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `csr_section_reference` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study Report (CSR) Section Reference');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `dataset_lock_status` SET TAGS ('dbx_value_regex' = 'pre_lock|post_lock|interim');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `dataset_version` SET TAGS ('dbx_business_glossary_term' = 'ADaM Dataset Version');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `delivery_date` SET TAGS ('dbx_business_glossary_term' = 'TLF Delivery Date');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `discrepancy_count` SET TAGS ('dbx_business_glossary_term' = 'TLF Discrepancy Count');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `is_final_version` SET TAGS ('dbx_business_glossary_term' = 'Is Final Version Flag');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `output_category` SET TAGS ('dbx_business_glossary_term' = 'TLF Output Category');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `output_file_format` SET TAGS ('dbx_business_glossary_term' = 'TLF Output File Format');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `output_file_format` SET TAGS ('dbx_value_regex' = 'RTF|PDF|SAS7BDAT|CSV|HTML|XLSX');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `output_file_name` SET TAGS ('dbx_business_glossary_term' = 'TLF Output File Name');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `output_file_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `output_file_path` SET TAGS ('dbx_business_glossary_term' = 'TLF Output File Path');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `output_number` SET TAGS ('dbx_business_glossary_term' = 'TLF Output Number');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `output_number` SET TAGS ('dbx_value_regex' = '^[A-Z]{1,3}-[0-9]{1,4}(.[0-9]{1,3})?$');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `output_title` SET TAGS ('dbx_business_glossary_term' = 'TLF Output Title');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `output_type` SET TAGS ('dbx_business_glossary_term' = 'TLF Output Type');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `output_type` SET TAGS ('dbx_value_regex' = 'table|listing|figure');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `output_version` SET TAGS ('dbx_business_glossary_term' = 'TLF Output Version');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `production_environment` SET TAGS ('dbx_value_regex' = 'development|validation|production');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `production_run_timestamp` SET TAGS ('dbx_business_glossary_term' = 'TLF Production Run Timestamp');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `qc_completion_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Quality Control (QC) Completion Timestamp');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `qc_status` SET TAGS ('dbx_business_glossary_term' = 'Quality Control (QC) Status');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `qc_status` SET TAGS ('dbx_value_regex' = 'pending|in_progress|passed|failed|waived');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `run_number` SET TAGS ('dbx_business_glossary_term' = 'Production Run Number');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `sas_program_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `sas_program_path` SET TAGS ('dbx_business_glossary_term' = 'SAS Program File Path');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `unblinding_authorization_ref` SET TAGS ('dbx_business_glossary_term' = 'Unblinding Authorization Reference');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `unblinding_authorization_ref` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `validation_method` SET TAGS ('dbx_business_glossary_term' = 'TLF Validation Method');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ALTER COLUMN `validation_method` SET TAGS ('dbx_value_regex' = 'double_programming|peer_review|independent_review');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ADD CONSTRAINT `fk_biostatistics_interim_analysis_analysis_population_id` FOREIGN KEY (`analysis_population_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`analysis_population`(`analysis_population_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ADD CONSTRAINT `fk_biostatistics_interim_analysis_database_lock_event_id` FOREIGN KEY (`database_lock_event_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`database_lock_event`(`database_lock_event_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ADD CONSTRAINT `fk_biostatistics_interim_analysis_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` SET TAGS ('dbx_domain' = 'biostatistics');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` SET TAGS ('dbx_subdomain' = 'results_reporting');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `analysis_population_id` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Pipeline Asset Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `blinding_config_id` SET TAGS ('dbx_business_glossary_term' = 'Blinding Config Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `database_lock_event_id` SET TAGS ('dbx_business_glossary_term' = 'Biostatistics Dbl Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `epoch_id` SET TAGS ('dbx_business_glossary_term' = 'Study Epoch Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Study Milestone Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `rand_list_id` SET TAGS ('dbx_business_glossary_term' = 'Rand List Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) ID');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `sdtm_dataset_id` SET TAGS ('dbx_business_glossary_term' = 'Sdtm Dataset Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `stratification_factor_id` SET TAGS ('dbx_business_glossary_term' = 'Stratification Factor Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Study Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_business_glossary_term' = 'Treatment Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `actual_analysis_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Interim Analysis Date');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `adam_dataset_version` SET TAGS ('dbx_business_glossary_term' = 'Analysis Data Model (ADaM) Dataset Version');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `alpha_allocated` SET TAGS ('dbx_business_glossary_term' = 'Allocated Alpha (Type I Error)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `alpha_spending_function` SET TAGS ('dbx_value_regex' = 'obrien_fleming|pocock|lan_demets_obf|lan_demets_pocock|hwang_shih_decani|custom');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `alpha_spending_parameter` SET TAGS ('dbx_business_glossary_term' = 'Alpha Spending Function Parameter (Gamma)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `analysis_code` SET TAGS ('dbx_business_glossary_term' = 'Interim Analysis Code');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `analysis_code` SET TAGS ('dbx_value_regex' = '^IA-[A-Z0-9]{2,10}-[0-9]{3}$');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `analysis_number` SET TAGS ('dbx_business_glossary_term' = 'Interim Analysis Number');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `analysis_outcome` SET TAGS ('dbx_business_glossary_term' = 'Interim Analysis Outcome');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `analysis_outcome` SET TAGS ('dbx_value_regex' = 'continue|stop_efficacy|stop_futility|stop_safety|adapt|pending');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `analysis_status` SET TAGS ('dbx_business_glossary_term' = 'Interim Analysis Status');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `analysis_status` SET TAGS ('dbx_value_regex' = 'planned|in_progress|completed|cancelled|on_hold');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `analysis_type` SET TAGS ('dbx_business_glossary_term' = 'Interim Analysis Type');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `analysis_type` SET TAGS ('dbx_value_regex' = 'efficacy|futility|safety|adaptive|combined_efficacy_futility|administrative');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_value_regex' = 'restricted|confidential|internal|public');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `dsmb_involved` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) / Data Monitoring Committee (DMC) Involvement Flag');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `dsmb_meeting_date` SET TAGS ('dbx_business_glossary_term' = 'DSMB/DMC Meeting Date');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `efficacy_boundary_value` SET TAGS ('dbx_business_glossary_term' = 'Efficacy Stopping Boundary Value');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `events_observed` SET TAGS ('dbx_business_glossary_term' = 'Events Observed at Interim');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `events_planned_total` SET TAGS ('dbx_business_glossary_term' = 'Total Planned Events');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `firewall_maintained` SET TAGS ('dbx_business_glossary_term' = 'Blinding Firewall Maintained Flag');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `futility_boundary_binding` SET TAGS ('dbx_business_glossary_term' = 'Futility Boundary Binding Flag');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `futility_boundary_value` SET TAGS ('dbx_business_glossary_term' = 'Futility Stopping Boundary Value');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `information_fraction_actual` SET TAGS ('dbx_business_glossary_term' = 'Actual Information Fraction');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `information_fraction_planned` SET TAGS ('dbx_business_glossary_term' = 'Planned Information Fraction');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Interim Analysis Notes');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `observed_p_value` SET TAGS ('dbx_business_glossary_term' = 'Observed P-Value');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `planned_analysis_date` SET TAGS ('dbx_business_glossary_term' = 'Planned Interim Analysis Date');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `regulatory_submission_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission Required Flag');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `results_disclosed_externally` SET TAGS ('dbx_business_glossary_term' = 'External Results Disclosure Flag');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `sample_size_reestimated` SET TAGS ('dbx_business_glossary_term' = 'Sample Size Re-estimation Flag');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `sas_program_version` SET TAGS ('dbx_business_glossary_term' = 'SAS Drug Development Program Version');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `stopping_rule_triggered` SET TAGS ('dbx_business_glossary_term' = 'Stopping Rule Triggered Flag');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `subjects_enrolled_at_cutoff` SET TAGS ('dbx_business_glossary_term' = 'Subjects Enrolled at Data Cutoff');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `unblinding_authorization_date` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `unblinding_scope` SET TAGS ('dbx_value_regex' = 'full|partial|none');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `unblinding_scope` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ADD CONSTRAINT `fk_biostatistics_database_lock_event_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` SET TAGS ('dbx_domain' = 'biostatistics');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` SET TAGS ('dbx_subdomain' = 'results_reporting');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `database_lock_event_id` SET TAGS ('dbx_business_glossary_term' = 'Database Lock Event Identifier');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `audit_id` SET TAGS ('dbx_business_glossary_term' = 'Audit Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `blinding_config_id` SET TAGS ('dbx_business_glossary_term' = 'Blinding Config Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `monitoring_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Plan Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Study Milestone Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `rand_list_id` SET TAGS ('dbx_business_glossary_term' = 'Rand List Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Sap Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Study Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `actual_lock_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Database Lock Date');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `amendment_number` SET TAGS ('dbx_business_glossary_term' = 'Post-Lock Amendment Number');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `amendment_reason` SET TAGS ('dbx_business_glossary_term' = 'Post-Lock Amendment Reason');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `analysis_type` SET TAGS ('dbx_value_regex' = 'interim_analysis|final_analysis|safety_review|ad_hoc|regulatory_submission');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `coding_complete` SET TAGS ('dbx_business_glossary_term' = 'Medical Coding Completion Status');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `data_cut_date` SET TAGS ('dbx_business_glossary_term' = 'Data Cut-Off Date');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `dbl_event_number` SET TAGS ('dbx_business_glossary_term' = 'Database Lock (DBL) Event Number');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `dm_approval_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Data Management (DM) Approval Timestamp');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `dmp_version` SET TAGS ('dbx_business_glossary_term' = 'Data Management Plan (DMP) Version');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `dsmb_notification_date` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Notification Date');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `dsmb_notification_required` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Notification Required Flag');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `edc_system_lock_reference` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) System Lock Reference');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `lock_scope` SET TAGS ('dbx_business_glossary_term' = 'Database Lock Scope');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `lock_scope` SET TAGS ('dbx_value_regex' = 'full_study|interim|partial|cohort|site_specific');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `lock_status` SET TAGS ('dbx_business_glossary_term' = 'Database Lock Status');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `lock_status` SET TAGS ('dbx_value_regex' = 'planned|in_progress|locked|unlocked|re_locked|cancelled');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `lock_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Database Lock Timestamp');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `lock_type` SET TAGS ('dbx_business_glossary_term' = 'Database Lock Type');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `lock_type` SET TAGS ('dbx_value_regex' = 'hard|soft');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `medical_monitor_approval_timestamp` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `medical_monitor_approval_timestamp` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Database Lock Event Notes');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `outstanding_query_count` SET TAGS ('dbx_business_glossary_term' = 'Outstanding Query Count at Lock');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `planned_lock_date` SET TAGS ('dbx_business_glossary_term' = 'Planned Database Lock Date');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `pre_lock_qc_checklist_complete` SET TAGS ('dbx_business_glossary_term' = 'Pre-Lock Quality Control (QC) Checklist Completion Status');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `pre_lock_qc_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Pre-Lock Quality Control (QC) Checklist Completion Date');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `sae_reconciliation_complete` SET TAGS ('dbx_business_glossary_term' = 'Serious Adverse Event (SAE) Reconciliation Completion Status');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `sdv_complete` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Completion Status');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `study_part` SET TAGS ('dbx_business_glossary_term' = 'Study Part / Period');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `unblinding_required` SET TAGS ('dbx_business_glossary_term' = 'Unblinding Required Flag');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `unlock_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Database Unlock Timestamp');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ADD CONSTRAINT `fk_biostatistics_statistical_endpoint_adam_dataset_spec_id` FOREIGN KEY (`adam_dataset_spec_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec`(`adam_dataset_spec_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ADD CONSTRAINT `fk_biostatistics_statistical_endpoint_analysis_population_id` FOREIGN KEY (`analysis_population_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`analysis_population`(`analysis_population_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ADD CONSTRAINT `fk_biostatistics_statistical_endpoint_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ADD CONSTRAINT `fk_biostatistics_statistical_endpoint_tlf_shell_id` FOREIGN KEY (`tlf_shell_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`tlf_shell`(`tlf_shell_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` SET TAGS ('dbx_domain' = 'biostatistics');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` SET TAGS ('dbx_subdomain' = 'analysis_planning');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `adam_dataset_spec_id` SET TAGS ('dbx_business_glossary_term' = 'Adam Dataset Spec Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `analysis_population_id` SET TAGS ('dbx_business_glossary_term' = 'Analysis Population Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `lab_panel_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Analyte Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `protocol_endpoint_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Endpoint Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) ID');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `tlf_shell_id` SET TAGS ('dbx_business_glossary_term' = 'Tlf Shell Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `alpha_spending_function` SET TAGS ('dbx_value_regex' = 'obrien_fleming|pocock|lan_demets|hwang_shih_decani|none');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `alternative_hypothesis` SET TAGS ('dbx_implements' = 'ICH_E9.AlternativeHypothesis');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `alternative_hypothesis` SET TAGS ('dbx_standard' = 'ICH_E9');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `approved_date` SET TAGS ('dbx_business_glossary_term' = 'Endpoint Approved Date');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `confidence_interval_level` SET TAGS ('dbx_business_glossary_term' = 'Confidence Interval (CI) Level');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `covariates` SET TAGS ('dbx_business_glossary_term' = 'Analysis Covariates');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `csr_section_reference` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study Report (CSR) Section Reference');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `endpoint_classification` SET TAGS ('dbx_value_regex' = 'primary|secondary|exploratory|safety');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `endpoint_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `endpoint_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|locked|superseded|retired');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `endpoint_type` SET TAGS ('dbx_value_regex' = 'efficacy|pharmacokinetic|pharmacodynamic|biomarker|patient_reported_outcome|safety');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `hypothesis_type` SET TAGS ('dbx_value_regex' = 'superiority|non_inferiority|equivalence|exploratory');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `locked_date` SET TAGS ('dbx_business_glossary_term' = 'Endpoint Locked Date');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `measurement_scale` SET TAGS ('dbx_value_regex' = 'continuous|binary|categorical|ordinal|time_to_event');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `missing_data_method` SET TAGS ('dbx_business_glossary_term' = 'Missing Data Handling Method');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `missing_data_method` SET TAGS ('dbx_implements' = 'ICH_E9(R1).IntercurrentEventStrategy');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `missing_data_method` SET TAGS ('dbx_standard' = 'ICH_E9R1');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `multiplicity_adjustment_method` SET TAGS ('dbx_implements' = 'ICH_E9.MultiplicityAdjustment');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `multiplicity_adjustment_method` SET TAGS ('dbx_standard' = 'ICH_E9');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `multiplicity_adjustment_method` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `multiplicity_testing_family` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `non_inferiority_margin` SET TAGS ('dbx_business_glossary_term' = 'Non-Inferiority (NI) Margin');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `null_hypothesis` SET TAGS ('dbx_implements' = 'ICH_E9.NullHypothesis');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `null_hypothesis` SET TAGS ('dbx_standard' = 'ICH_E9');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `sap_version` SET TAGS ('dbx_business_glossary_term' = 'Statistical Analysis Plan (SAP) Version');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `sap_version` SET TAGS ('dbx_value_regex' = '^v[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `significance_level` SET TAGS ('dbx_business_glossary_term' = 'Significance Level (Alpha)');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `significance_level` SET TAGS ('dbx_implements' = 'ICH_E9.SignificanceLevel');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `significance_level` SET TAGS ('dbx_standard' = 'ICH_E9');

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
