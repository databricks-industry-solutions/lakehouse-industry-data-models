-- Schema for Domain: program | Business: Clinical_Trials | Version: v2_ecm
-- Generated on: 2026-11-19 16:37:33

CREATE DATABASE IF NOT EXISTS `clinical_trials_ecm`.`program` COMMENT 'Manages clinical development programs spanning multiple studies for a therapeutic indication or pipeline asset. Owns program-level planning, portfolio governance, milestone tracking, and cross-study coordination.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`program`.`clinical_program` (
    `clinical_program_id` BIGINT COMMENT 'Unique surrogate identifier for the clinical development program. Primary key for the clinical_program entity across the enterprise data platform.',
    `indication_id` BIGINT COMMENT 'Foreign key linking to program.indication. Business justification: clinical_program carries disease_indication (STRING) and indication_meddra_code (STRING) as denormalized text fields.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization that owns and funds this clinical development program. Links to the sponsor master entity.',
    `parent_clinical_program_id` BIGINT COMMENT 'Self-referencing FK on clinical_program (parent_clinical_program_id)',
    `pipeline_asset_id` BIGINT COMMENT 'Foreign key linking to sponsor.pipeline_asset. Business justification: Every clinical program is built around a specific pipeline asset. This is a fundamental drug development relationship.',
    `therapeutic_area_id` BIGINT COMMENT 'Foreign key linking to program.therapeutic_area. Business justification: clinical_program.therapeutic_area is a free-text STRING denormalization of the therapeutic_area reference master that exists in this domain.',
    `actual_end_date` DATE COMMENT 'Actual date on which the clinical development program was completed or terminated. Populated upon program closure; null for active programs. Used for variance analysis against projected end date.',
    `breakthrough_therapy_designation` BOOLEAN COMMENT 'Indicates whether the FDA has granted Breakthrough Therapy Designation (BTD) to the investigational product under this program. BTD expedites development and review of drugs for serious conditions. True = designation granted.',
    `budget_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the program budget (e.g., USD, EUR, GBP). Required for multi-currency financial reporting and the source system. Valid values are `^[A-Z]{3}$`',
    `cost_center_code` STRING COMMENT 'the source system center code to which program expenditures are allocated for financial reporting and GL accounting. Enables program-level cost tracking and budget variance analysis.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the clinical program record was first created in the enterprise data platform. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `clinical_program_description` STRING COMMENT 'Free-text narrative description of the clinical development programs scientific rationale, strategic objectives, and key development hypotheses. Used in portfolio governance documents, regulatory strategy briefs, and sponsor communications.',
    `development_phase` STRING COMMENT 'Current or primary clinical development phase of the program per ICH E8 classification (Phase I through Phase IV). Drives regulatory strategy, resource planning, and portfolio governance decisions.. Valid values are `Phase I|Phase I/II|Phase II|Phase II/III|Phase III|Phase IV`',
    `dsmb_required` BOOLEAN COMMENT 'Indicates whether a Data Safety Monitoring Board (DSMB) or Data Monitoring Committee (DMC) is required for this clinical development program based on risk profile, study design, or regulatory requirements. True = DSMB/DMC required.',
    `fast_track_designation` BOOLEAN COMMENT 'Indicates whether the FDA has granted Fast Track Designation to the investigational product under this program, facilitating development and expediting review for serious conditions with unmet medical need. True = designation granted.',
    `global_study_count` BIGINT COMMENT 'Total number of individual clinical studies (trials) planned or active under this clinical development program. Provides a program-level scope indicator for portfolio governance and resource planning.',
    `modality` STRING COMMENT 'Scientific modality or drug class of the investigational product (e.g., Small Molecule, Biologic, Cell Therapy, Gene Therapy). Determines applicable regulatory guidelines, manufacturing requirements, and safety monitoring frameworks.',
    `orphan_drug_designation` BOOLEAN COMMENT 'Indicates whether the investigational product has received Orphan Drug Designation (ODD) from FDA or EMA for a rare disease indication under this program. Confers market exclusivity and development incentives. True = designation granted.',
    `pediatric_investigation_plan` BOOLEAN COMMENT 'Indicates whether a Pediatric Investigation Plan (PIP) has been agreed with EMA or a Pediatric Study Plan (PSP) with FDA for this program. Required for most new medicinal products under EU Pediatric Regulation and FDA PREA.',
    `portfolio_priority` STRING COMMENT 'Strategic priority ranking of the clinical development program within the sponsors pipeline portfolio. Used for resource allocation, investment decisions, and executive portfolio governance reviews.. Valid values are `Critical|High|Medium|Low`',
    `prime_designation` BOOLEAN COMMENT 'Indicates whether the EMA has granted PRIority MEdicines (PRIME) designation to the investigational product under this program, providing enhanced support for development of medicines that target unmet medical needs. True = designation granted.',
    `program_budget` DECIMAL(18,2) COMMENT 'Total approved budget allocated to the clinical development program across all studies and activities, expressed in the programs base currency. Used for financial governance, variance tracking, and portfolio investment reporting.',
    `program_code` STRING COMMENT 'Sponsor-assigned alphanumeric code uniquely identifying the clinical development program across all internal systems (CTMS, eTMF, EDC). Serves as the externally-known business identifier referenced in regulatory submissions and cross-system integrations.. Valid values are `^[A-Z0-9]{2,20}$`',
    `program_name` STRING COMMENT 'Full descriptive name of the clinical development program (e.g., XYZ-001 Oncology Phase II/III Program). Used in portfolio governance dashboards, regulatory strategy documents, and sponsor communications.',
    `program_short_name` STRING COMMENT 'Abbreviated or working title for the clinical development program used in internal communications, reports, and dashboards where space is limited.',
    `program_start_date` DATE COMMENT 'Official start date of the clinical development program, typically aligned with first IND/CTA filing or first-in-human study initiation. Used for program duration tracking and portfolio milestone reporting.',
    `program_status` STRING COMMENT 'Current lifecycle status of the clinical development program. Active indicates ongoing studies; On Hold indicates temporary suspension; Completed indicates all studies concluded; Terminated indicates early discontinuation; Planning indicates. Valid values are `Active|On Hold|Completed|Terminated|Planning`',
    `program_type` STRING COMMENT 'Classification of the program by disease area or regulatory pathway type (e.g., Oncology, Rare Disease, CNS, Cardiovascular, Infectious Disease, Pediatric, Biosimilar). Determines applicable regulatory frameworks and development strategies.',
    `projected_end_date` DATE COMMENT 'Anticipated completion date for the entire clinical development program, encompassing all studies through regulatory submission. Used for portfolio planning, resource forecasting, and milestone tracking.',
    `record_version` BIGINT COMMENT 'Incrementing version number for the clinical program record, supporting optimistic concurrency control and change history tracking in the Databricks Silver Layer. Incremented on each update.',
    `regulatory_strategy_summary` STRING COMMENT 'High-level narrative describing the regulatory development strategy for the program, including target submission pathways (NDA, BLA, MAA), key regulatory agency interactions, and any special designations (Breakthrough Therapy, Fast Track, Orphan Drug',
    `target_submission_date` DATE COMMENT 'Planned date for submission of the primary marketing authorization application (NDA/BLA/MAA) to the lead regulatory agency. Key portfolio milestone used for resource planning and executive reporting.',
    `target_submission_type` STRING COMMENT 'Type of regulatory marketing application targeted upon program completion (e.g., NDA - New Drug Application, BLA - Biologics License Application, MAA - Marketing Authorization Application). Drives regulatory strategy and submission planning.. Valid values are `NDA|BLA|MAA|sNDA|sBLA|sMAA|510(k)|PMA`',
    `termination_reason` STRING COMMENT 'Documented reason for early termination or discontinuation of the clinical development program (e.g., safety signal, lack of efficacy, strategic reprioritization, commercial decision). Populated only when program_status = Terminated.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the clinical program record. Supports change tracking, audit trail requirements under 21 CFR Part 11, and ALCOA+ data integrity principles.',
    `wbs_code` STRING COMMENT 'the source system Breakdown Structure (WBS) element code for the clinical program, enabling hierarchical project cost tracking, procurement, and financial reporting at the program level.',
    CONSTRAINT pk_clinical_program PRIMARY KEY(`clinical_program_id`)
) COMMENT 'Top-level master entity representing a clinical development program — a strategic grouping of one or more clinical studies targeting a specific therapeutic indication or pipeline asset.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` (
    `program_development_milestone_id` BIGINT COMMENT 'Unique surrogate identifier for a program-level milestone record in the clinical development lifecycle.',
    `clinical_program_id` BIGINT COMMENT 'add column clinical_program_id (BIGINT) with FK to program.clinical_program.clinical_program_id — program_development_milestone has only a self-ref and employee FK but no link to the clinical program it belongs to',
    `owner_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Milestone ownership is assigned to named employees for regulatory timeline accountability (e.g., IND submission, first patient in).',
    `primary_program_development_milestone_id` BIGINT COMMENT 'Reference to the program_milestone record that must be achieved before this milestone can begin. Captures sequential dependency relationships for critical path analysis and schedule management.',
    `study_milestone_id` BIGINT COMMENT 'Reference to study.study_milestone.study_milestone_id.',
    `actual_date` DATE COMMENT 'Calendar date on which the milestone was actually achieved. Populated only when milestone_status is achieved. Used to calculate schedule variance against planned and baseline dates.',
    `baseline_date` DATE COMMENT 'Formally approved baseline date for the milestone, which may differ from the original planned date following a formal re-baseline event. Used for earned value management and schedule performance tracking.',
    `completion_percentage` DECIMAL(5,2) COMMENT 'Estimated percentage of work completed toward achieving this milestone, expressed as a value between 0.00 and 100.00. Used for progress tracking in portfolio governance dashboards.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this program milestone record was first created in the system. Supports audit trail requirements per ALCOA+ principles and 21 CFR Part 11 electronic records compliance.',
    `decision_rationale` STRING COMMENT 'Narrative explanation of the rationale behind the go/no-go decision or milestone outcome, including key data readouts, safety findings, or strategic considerations that influenced the decision.',
    `delay_reason_code` STRING COMMENT 'Standardized categorical code classifying the primary root cause of a milestone delay. Enables trend analysis across programs and portfolio-level risk reporting. Populated only when milestone is delayed.',
    `dependency_type` STRING COMMENT 'Type of scheduling dependency relationship between this milestone and its predecessor. Follows standard project management dependency logic (e.g., finish-to-start means predecessor must finish before this milestone can start).. Valid values are `finish_to_start|start_to_start|finish_to_finish|start_to_finish`',
    `escalation_date` DATE COMMENT 'Date on which the milestone was formally escalated to senior management or the program governance committee. Populated only when escalation_flag is True.',
    `escalation_flag` BOOLEAN COMMENT 'Indicates whether this milestone has been formally escalated to senior management or the program governance committee due to delay risk or impact on the overall program timeline.',
    `evidence_document_ref` STRING COMMENT 'Reference identifier or hyperlink to the supporting evidence document in the eTMF or document management system (e.g., Veeva Vault) that confirms milestone achievement (e.g., IND approval letter, regulatory submission receipt, DSMB meeting minutes).',
    `forecast_date` DATE COMMENT 'Current best estimate of when the milestone will be achieved, updated as the program progresses. Reflects the most recent forecast based on operational data and risk assessments.',
    `go_no_go_date` DATE COMMENT 'Date on which the formal go/no-go decision was made by the program governance committee or sponsor. Populated only for decision-gate milestone types.',
    `go_no_go_decision` STRING COMMENT 'Formal program governance decision recorded at decision-gate milestones (e.g., Phase I/II transition, Phase II/III transition). Captures whether the program proceeds, is stopped, or advances with conditions.. Valid values are `go|no_go|conditional_go|deferred|not_applicable`',
    `governing_phase` STRING COMMENT 'The clinical development phase during which this milestone is expected to occur or to which it belongs. Enables phase-level portfolio analytics and cross-program benchmarking.',
    `is_active` BOOLEAN COMMENT 'Indicates whether this milestone record is currently active and in scope for portfolio governance reporting. Set to False for cancelled or superseded milestones that are retained for historical audit purposes.',
    `is_critical_path` BOOLEAN COMMENT 'Indicates whether this milestone lies on the critical path of the clinical development program. Critical path milestones directly impact the overall program timeline and receive heightened governance scrutiny.',
    `is_regulatory_commitment` BOOLEAN COMMENT 'Indicates whether this milestone represents a formal commitment made to a regulatory authority (e.g., FDA, EMA, PMDA) as part of an IND, NDA, BLA, or MAA submission. Regulatory commitment milestones require formal change control if dates slip.',
    `lag_days` BIGINT COMMENT 'Number of calendar days of lag or lead time applied to the dependency relationship with the predecessor milestone. Positive values indicate lag (waiting period); negative values indicate lead (overlap allowed).',
    `last_reviewed_date` DATE COMMENT 'Date on which this milestone record was last reviewed and confirmed by the responsible function or program governance team. Supports audit trail requirements and data quality assurance.',
    `milestone_code` STRING COMMENT 'Externally-known alphanumeric code uniquely identifying this milestone within the program (e.g., MS-IND-001, MS-PH1-START). Used as the business identifier in CTMS, portfolio dashboards, and regulatory submissions.. Valid values are `^[A-Z0-9_-]{2,30}$`',
    `milestone_description` STRING COMMENT 'Detailed narrative description of the milestone, including its definition of done, acceptance criteria, and business significance within the clinical development program.',
    `milestone_name` STRING COMMENT 'Human-readable name of the milestone (e.g., IND Filing, Phase I First Patient In, NDA Submission, Program Go/No-Go Decision). Used in executive dashboards and portfolio governance reports.',
    `milestone_status` STRING COMMENT 'Current lifecycle state of the milestone indicating whether it has been achieved, is on track, delayed, or cancelled. Drives portfolio governance escalation and executive reporting.. Valid values are `pending|achieved|delayed|at_risk|cancelled`',
    `milestone_type` STRING COMMENT 'Categorical classification of the milestone by its business function within the clinical development lifecycle. Drives portfolio analytics and governance reporting.. Valid values are `regulatory|clinical_phase|decision_gate|data_readout|submission|approval`',
    `mitigation_action` STRING COMMENT 'Description of the corrective or preventive action plan in place to address identified risks or delays for this milestone. Supports CAPA tracking and portfolio governance reporting.',
    `planned_date` DATE COMMENT 'Originally planned calendar date for achieving this milestone as defined in the program development plan. Serves as the baseline for variance analysis and portfolio governance reporting.',
    `priority_level` STRING COMMENT 'Business priority assigned to this milestone for resource allocation and escalation management. Critical and high priority milestones receive executive-level visibility in portfolio governance reviews.. Valid values are `critical|high|medium|low`',
    `record_version` BIGINT COMMENT 'Incrementing version number of this milestone record, updated each time the record is modified. Supports optimistic concurrency control and audit trail requirements per 21 CFR Part 11.',
    `regulatory_authority` STRING COMMENT 'The regulatory authority to which this milestone is relevant or committed (e.g., FDA for IND filing, EMA for MAA submission). Applicable when is_regulatory_commitment is True.',
    `responsible_function` STRING COMMENT 'Organizational function or department accountable for achieving this milestone (e.g., Regulatory Affairs, Clinical Operations, Biostatistics, Data Management, Medical Affairs). Used for accountability tracking and resource planning.',
    `review_cycle` STRING COMMENT 'Frequency at which this milestone is reviewed in program governance meetings. Drives scheduling of portfolio review cadences and reporting cycles.. Valid values are `weekly|bi_weekly|monthly|quarterly|ad_hoc`',
    `risk_rating` STRING COMMENT 'Current risk rating for on-time achievement of this milestone, based on the latest risk assessment. Drives portfolio-level risk reporting and proactive mitigation planning.. Valid values are `high|medium|low|not_assessed`',
    `schedule_variance_days` BIGINT COMMENT 'Difference in calendar days between the actual (or forecast) date and the baseline date. Positive values indicate delay; negative values indicate early achievement. Supports portfolio governance and KPI reporting.',
    `source_system_record_reference` STRING COMMENT 'Native record identifier of this milestone in the originating operational system (e.g., Siebel CTMS milestone ID). Enables traceability and reconciliation between the lakehouse Silver Layer and the system of record.',
    `subtype` STRING COMMENT 'Further granular classification within the milestone type (e.g., within regulatory: IND Filing, NDA Submission, BLA Submission, MAA Submission; within clinical_phase: Phase I Start, Phase II Start, Phase III Start, Phase IV Start).',
    `tmf_zone` STRING COMMENT 'The TMF zone or section in the eTMF (Electronic Trial Master File) where the milestone evidence document is filed, per the DIA TMF Reference Model (e.g., Zone 01 - Trial Management, Zone 04 - Regulatory).',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this program milestone record was last modified. Supports audit trail requirements per ALCOA+ principles and 21 CFR Part 11 electronic records compliance.',
    `variance_commentary` STRING COMMENT 'Free-text explanation of the root cause and impact of any schedule variance between planned and actual/forecast dates. Required when schedule_variance_days exceeds threshold. Supports portfolio governance escalation and executive reporting.',
    CONSTRAINT pk_program_development_milestone PRIMARY KEY(`program_development_milestone_id`)
) COMMENT 'Tracks key program-level milestones and their planned versus actual achievement dates across the clinical development lifecycle. Captures milestone name, milestone type (e.g., IND filing, Phase I start, Phase II start, Phase III start, NDA/BLA submission';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`program`.`program_study` (
    `program_study_id` BIGINT COMMENT 'Unique surrogate identifier for the program-study association record within the clinical development program portfolio.',
    `clinical_program_id` BIGINT COMMENT 'Reference to the parent clinical development program to which this study belongs. Enables program-level portfolio aggregation and cross-study coordination.',
    `dependent_program_study_id` BIGINT COMMENT 'Self-referencing FK on program_study (dependent_program_study_id)',
    `study_id` BIGINT COMMENT 'Reference to the individual clinical study (protocol) that is formally associated with the program. Represents the study entity within the program-study linkage.',
    `actual_completion_date` DATE COMMENT 'Actual date on which the study was completed (last patient last visit or database lock) as recorded in the CTMS. Enables planned vs. actual timeline variance analysis and program-level close-out tracking.',
    `actual_start_date` DATE COMMENT 'Actual date on which the study commenced (first patient first visit or first site activation) as recorded in the CTMS. Enables planned vs. actual timeline variance analysis at the program level.',
    `approved_by` STRING COMMENT 'Name or identifier of the governance body or individual (e.g., Chief Medical Officer, Portfolio Review Board) who approved the inclusion of this study in the program. Supports accountability and audit trail requirements.',
    `association_code` STRING COMMENT 'Externally-known business identifier code for this program-study linkage, used in CTMS, portfolio dashboards, and regulatory dossier cross-references (e.g., PRG-001-STU-003).. Valid values are `^[A-Z0-9_-]{3,30}$`',
    `association_status` STRING COMMENT 'Current lifecycle status of the program-study association. Active indicates the study is currently contributing to the program; removed indicates the study has been formally withdrawn from the program scope; pending indicates the association is under. Valid values are `active|inactive|pending|removed|suspended`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this program-study association record was first created in the system. Supports audit trail, data lineage, and ALCOA+ (Attributable, Legible, Contemporaneous, Original, Accurate) compliance requirements.',
    `cross_study_dependency` STRING COMMENT 'Free-text description of any formal dependencies between this study and other studies within the program (e.g., Requires completion of Study 001 dose-escalation before initiating, Shares DSMB charter with Study 003).',
    `csr_submission_date` DATE COMMENT 'Date on which the Clinical Study Report (CSR) for this study was submitted to the regulatory authority or included in the programs regulatory dossier. Supports eTMF completeness tracking and regulatory submission planning.',
    `ctd_module_reference` STRING COMMENT 'Reference to the CTD/eCTD module and section where this studys data will be submitted in the regulatory dossier (e.g., M5.3.5.1 for controlled clinical studies). Supports regulatory submission planning and dossier assembly.. Valid values are `^M[2-5](.[0-9]+)*$`',
    `data_readout_date` DATE COMMENT 'Date on which the studys primary analysis results (top-line data) were made available to the program team and sponsor. Critical for program-level go/no-go decision gates and portfolio governance reviews.',
    `eudract_number` STRING COMMENT 'Registry identifier (EU CT / EudraCT number). Implements USDM StudyIdentifier.text with issuing organization EMA/EudraCT.. Valid values are `^[0-9]{4}-[0-9]{6}-[0-9]{2}$`',
    `geographic_scope` STRING COMMENT 'Description of the geographic regions or countries in which this study is conducted as part of the program (e.g., global, US-only, EU, Asia-Pacific). Supports multi-regional regulatory strategy and program-level site distribution analysis.',
    `governance_approval_date` DATE COMMENT 'Date on which the program governance committee (e.g., Portfolio Review Board, Development Committee) formally approved the inclusion of this study in the program. Supports audit trail and governance compliance.',
    `ind_number` STRING COMMENT 'Registry identifier (FDA IND number). Implements USDM StudyIdentifier.text with issuing organization FDA.. Valid values are `^[0-9]{5,6}$`',
    `indication_meddra_code` STRING COMMENT 'Indication MedDRA code. Implements MedDRA PT code reference (terminology domain).. Valid values are `^[0-9]{8}$`',
    `integrated_analysis_flag` BOOLEAN COMMENT 'Indicates whether this studys data is included in a program-level integrated analysis (e.g., Integrated Summary of Safety (ISS) or Integrated Summary of Efficacy (ISE)) for the regulatory dossier. True = included in integrated analysis.',
    `is_gcp_compliant` BOOLEAN COMMENT 'Indicates whether this study is conducted in full compliance with ICH E6(R2) Good Clinical Practice (GCP) guidelines, as required for regulatory submission.',
    `is_registrational` BOOLEAN COMMENT 'Indicates whether this study is designated as a registrational study intended to support a marketing authorization application (NDA, BLA, MAA). True = registrational; False = non-registrational (e.g., exploratory, mechanistic).',
    `nct_number` STRING COMMENT 'Registry identifier (ClinicalTrials.gov NCT number). Implements USDM StudyIdentifier.text with issuing organization ClinicalTrials.gov; CDISC CT registry identifier type.. Valid values are `^NCT[0-9]{8}$`',
    `notes` STRING COMMENT 'Free-text field for capturing additional context, rationale, or operational notes about the program-study association that are not captured in structured fields (e.g., strategic rationale for study inclusion, regulatory agency feedback driving study',
    `phase` STRING COMMENT 'Study phase. Governed by CDISC CT codelist (Trial Phase, C66737).. Valid values are `Phase I|Phase I/II|Phase II|Phase IIa|Phase IIb|Phase III`',
    `planned_completion_date` DATE COMMENT 'Planned last patient last visit (LPLV) or database lock date as scheduled within the program timeline. Supports program-level milestone planning and regulatory submission timeline forecasting.',
    `planned_start_date` DATE COMMENT 'Planned first patient first visit (FPFV) or study initiation date as scheduled within the program timeline. Used for program-level Gantt chart planning and milestone dependency tracking.',
    `population_type` STRING COMMENT 'Characterizes the patient population targeted by this study within the program (e.g., adult, pediatric, geriatric, special population). Supports program-level population coverage and pediatric investigation plan (PIP) compliance tracking.. Valid values are `adult|pediatric|geriatric|special_population|all_ages`',
    `portfolio_priority` STRING COMMENT 'Strategic priority level assigned to this study within the program portfolio by the program governance committee. Critical = must-have for regulatory submission; High = important for program success; Medium = supportive; Low = optional/exploratory.. Valid values are `critical|high|medium|low`',
    `primary_endpoint_category` STRING COMMENT 'High-level category of the studys primary endpoint as it relates to the programs evidence generation strategy. Supports program-level endpoint coverage analysis and regulatory dossier planning.. Valid values are `efficacy|safety|PK/PD|biomarker|quality_of_life|other`',
    `program_milestone_dependency` STRING COMMENT 'Description of the program-level milestone or go/no-go decision gate that this studys results are expected to inform or unlock (e.g., Phase II readout gates Phase III initiation, Bridging study required before NDA submission).',
    `regulatory_dossier_contribution` BOOLEAN COMMENT 'Indicates whether this studys data is intended to contribute to the regulatory submission dossier (NDA, BLA, MAA, or CTD/eCTD package) for the programs therapeutic indication. True = study data will be included in the regulatory filing.',
    `removal_reason` STRING COMMENT 'Reason code explaining why the study was removed from the program. Completed indicates normal study conclusion; terminated indicates early discontinuation; superseded indicates replacement by a redesigned study; out_of_scope indicates strategic portfolio',
    `removed_from_program_date` DATE COMMENT 'Calendar date on which the study was formally removed or withdrawn from the clinical development program scope. Null if the study remains active within the program.',
    `sequence_number` BIGINT COMMENT 'Ordinal sequence number indicating the position of this study within the clinical development program timeline. Used for program-level ordering, milestone dependency mapping, and regulatory dossier sequencing.',
    `shared_dsmb_flag` BOOLEAN COMMENT 'Indicates whether this study shares a Data Safety Monitoring Board (DSMB) or Data Monitoring Committee (DMC) with other studies in the program. True = shared DSMB/DMC; False = study-specific DSMB/DMC or no DSMB required.',
    `shared_sap_flag` BOOLEAN COMMENT 'Indicates whether this studys Statistical Analysis Plan (the source system) is shared or integrated with other studies in the program (e.g., integrated summary of safety/efficacy). True = shared the source system; False = study-specific the source system.',
    `sponsor_protocol_number` STRING COMMENT 'Sponsor protocol number. Implements USDM StudyIdentifier.text with issuing organization = sponsor.',
    `study_role` STRING COMMENT 'Designates the functional role of the study within the clinical development program. Pivotal studies are designed to provide primary evidence for regulatory approval; supportive studies provide corroborating evidence; exploratory studies generate. Valid values are `pivotal|supportive|exploratory|bridging|PK/PD`',
    `therapeutic_indication` STRING COMMENT 'The disease, condition, or therapeutic indication that this study addresses within the program. Aligns with the programs target indication and supports cross-study indication consistency tracking.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this program-study association record was most recently modified. Supports audit trail, change tracking, and ALCOA+ compliance for regulatory inspection readiness.',
    CONSTRAINT pk_program_study PRIMARY KEY(`program_study_id`)
) COMMENT 'Association entity representing the formal relationship between a clinical development program and the individual clinical studies (protocols) that constitute it.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`program`.`indication` (
    `indication_id` BIGINT COMMENT 'Unique surrogate identifier for the therapeutic indication record. Primary key for the indication reference master. [ROLE: REFERENCE_LOOKUP — this entity is a reference master / code list for therapeutic indications used across program, study, and',
    `parent_indication_id` BIGINT COMMENT 'Self-referencing FK on indication (parent_indication_id)',
    `primary_superseded_by_indication_id` BIGINT COMMENT 'Reference to the indication_id of the record that replaces this indication when it is retired or split. Enables taxonomy lineage tracking and ensures downstream systems can migrate to the current indication record.',
    `therapeutic_area_id` BIGINT COMMENT 'Foreign key linking to program.therapeutic_area. Business justification: indication.therapeutic_area is a STRING field that duplicates the therapeutic_area reference master.',
    `accelerated_approval_flag` BOOLEAN COMMENT 'Indicates whether this indication is eligible for FDA Accelerated Approval or EMA Conditional Marketing Authorization based on surrogate or intermediate clinical endpoints. Drives endpoint selection strategy in study protocol design.',
    `approved_regions` STRING COMMENT 'Comma-separated list of three-letter ISO 3166-1 alpha-3 region/country codes where a product for this indication has received regulatory marketing approval (e.g., USA,EUE,JPN). Null if no approvals exist.',
    `biomarker_driven_flag` BOOLEAN COMMENT 'Indicates whether this indication requires biomarker-based patient selection or stratification (e.g., PD-L1 expression, EGFR mutation, HER2 amplification). True = biomarker-driven enrollment criteria apply.',
    `breakthrough_therapy_flag` BOOLEAN COMMENT 'Indicates whether any program targeting this indication has received or is eligible for FDA Breakthrough Therapy Designation (BTD). True = BTD granted or under consideration. Influences regulatory strategy, timeline planning, and sponsor communications.',
    `indication_code` STRING COMMENT 'Internally assigned alphanumeric code uniquely identifying the therapeutic indication within the organizations indication taxonomy. Used as the business-facing identifier across CTMS, EDC, and regulatory systems.. Valid values are `^IND-[A-Z0-9]{4,12}$`',
    `companion_diagnostic_required` BOOLEAN COMMENT 'Indicates whether a companion diagnostic (CDx) test is required for patient selection or treatment decisions in studies targeting this indication. True = CDx required.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this indication record was first created in the system. Supports audit trail requirements under 21 CFR Part 11, ALCOA+ principles, and GDPR data governance obligations.',
    `cta_filed_flag` BOOLEAN COMMENT 'Indicates whether a Clinical Trial Authorization (CTA) has been filed with the EMA or other ex-US health authorities for at least one program targeting this indication. True = CTA filed. Supports ex-US regulatory status tracking.',
    `ctcae_version` STRING COMMENT 'CTCAE version. Implements CTCAE code_system_version reference (terminology domain).. Valid values are `^[0-9]+.[0-9]+$`',
    `data_steward` STRING COMMENT 'Name or identifier of the business data steward responsible for maintaining the accuracy and governance of this indication record. Supports data ownership accountability under ALCOA+ and enterprise data governance frameworks.',
    `development_phase` STRING COMMENT 'Highest clinical development phase currently reached for this indication across the organizations portfolio. Reflects the maturity of the indication in the pipeline (e.g., phase_2 = at least one Phase 2 study active or completed).. Valid values are `preclinical|phase_1|phase_2|phase_3|phase_4|approved`',
    `disease_category` STRING COMMENT 'Sub-classification of the disease within the therapeutic area (e.g., Solid Tumors, Hematologic Malignancies, Autoimmune, Metabolic Syndrome). Provides a second level of indication taxonomy for portfolio segmentation and study grouping.',
    `disease_stage` STRING COMMENT 'Standard disease staging classification applicable to this indication (e.g., Stage III-IV, Relapsed/Refractory, Early Stage, Metastatic). Used for patient stratification, eligibility criteria design, and cross-study comparability.',
    `effective_end_date` DATE COMMENT 'Date on which this indication record was retired or superseded. Null for currently active indications. Enables historical validity queries and ensures retired indications are not used in new program or study assignments.',
    `effective_start_date` DATE COMMENT 'Date from which this indication record became effective and available for use in programs and studies. Supports temporal validity tracking and ensures studies reference the correct indication version at the time of protocol design.',
    `fast_track_flag` BOOLEAN COMMENT 'Indicates whether programs targeting this indication are eligible for or have received FDA Fast Track Designation. True = Fast Track applicable. Affects regulatory submission planning and FDA interaction frequency.',
    `first_approval_date` DATE COMMENT 'Date of the first regulatory marketing approval (NDA, BLA, MAA, or equivalent) granted for any product in this indication. Null if no approval has been granted. Used for competitive intelligence and portfolio milestone tracking.',
    `first_in_human_date` DATE COMMENT 'Date on which the first-in-human (FIH) clinical study for this indication was initiated. Marks the transition from preclinical to clinical development and is a key milestone in program lifecycle tracking.',
    `icd10_code` STRING COMMENT 'ICD-10 diagnosis code. Implements ICD-10 code reference (terminology domain).. Valid values are `^[A-Z][0-9]{2}(.[0-9A-Z]{1,4})?$`',
    `icd11_code` STRING COMMENT 'ICD-11 alphanumeric code assigned to this indication per the WHO International Classification of Diseases, 11th Revision. Supports forward compatibility with emerging regulatory and health authority requirements.. Valid values are `^[A-Z][A-Z0-9]{1,5}(.[A-Z0-9]{1,5})?$`',
    `ind_filed_flag` BOOLEAN COMMENT 'Indicates whether an Investigational New Drug (IND) application has been filed with the FDA for at least one program targeting this indication. True = IND filed. Relevant for US regulatory status tracking and program readiness assessment.',
    `is_orphan_disease` BOOLEAN COMMENT 'Indicates whether this indication qualifies as an orphan disease (rare disease) under applicable regulatory frameworks. True = orphan/rare disease designation applicable.',
    `is_pediatric_indication` BOOLEAN COMMENT 'Indicates whether this indication includes or is specifically targeted at a pediatric patient population. True = pediatric indication. Triggers compliance requirements under FDA Pediatric Research Equity Act (PREA), EMA Pediatric Investigation Plan (PIP)',
    `line_of_therapy` STRING COMMENT 'Standard line of therapy context for this indication (e.g., first_line, second_line, adjuvant). Defines the treatment setting and prior therapy requirements for patient eligibility across studies in this indication.',
    `meddra_pt_code` STRING COMMENT 'MedDRA Preferred Term code. Implements MedDRA PT.ptcode (terminology domain).. Valid values are `^[0-9]{8}$`',
    `meddra_pt_name` STRING COMMENT 'MedDRA Preferred Term name. Implements MedDRA PT.ptname (terminology domain).',
    `meddra_soc_code` STRING COMMENT 'MedDRA System Organ Class code. Implements MedDRA SOC.soccode (terminology domain).. Valid values are `^[0-9]{8}$`',
    `meddra_soc_name` STRING COMMENT 'MedDRA System Organ Class name. Implements MedDRA SOC.socname (terminology domain).',
    `meddra_version` STRING COMMENT 'MedDRA dictionary version. Implements MedDRA code_system_version reference (terminology domain).. Valid values are `^[0-9]{1,2}.[0-9]{1}$`',
    `indication_name` STRING COMMENT 'Full, standardized human-readable name of the therapeutic indication or disease area (e.g., Non-Small Cell Lung Cancer, Type 2 Diabetes Mellitus). Serves as the primary display label across all downstream systems.',
    `orphan_designation_number` STRING COMMENT 'Official regulatory designation number assigned by the FDA or EMA for orphan drug status for this indication (e.g., FDA ODD number or EMA EU/3/xx/xxx). Populated only when is_orphan_disease is True and a formal designation has been granted.',
    `patient_population_description` STRING COMMENT 'Narrative description of the target patient population for this indication, including key inclusion/exclusion criteria characteristics, disease stage, line of therapy, and biomarker requirements.',
    `prevalence_estimate` BIGINT COMMENT 'Estimated number of patients affected by this indication in the target population (absolute count). Used for feasibility assessments, patient recruitment planning, and orphan disease threshold determination (e.g., <200,000 in the US for FDA ODD).',
    `prevalence_population_region` STRING COMMENT 'Three-letter ISO 3166-1 alpha-3 country or region code for which the prevalence estimate applies (e.g., USA, EUE, GBR). Contextualizes the prevalence_estimate for regulatory and recruitment planning purposes.. Valid values are `^[A-Z]{3}$`',
    `primary_endpoint_type` STRING COMMENT 'Standard primary clinical endpoint type typically used in studies for this indication (e.g., overall_survival, progression_free_survival, objective_response_rate).',
    `regulatory_precedent_notes` STRING COMMENT 'Free-text field capturing known regulatory precedents, prior approvals, breakthrough therapy designations, fast track designations, or other regulatory history relevant to this indication.',
    `short_name` STRING COMMENT 'Abbreviated or commonly used short name for the indication (e.g., NSCLC, T2DM). Used in reports, dashboards, and UI labels where space is constrained.',
    `indication_status` STRING COMMENT 'Current lifecycle status of the indication record within the organizations indication taxonomy. active = currently used in programs/studies; retired = no longer in use, superseded; under_review = pending taxonomy committee review. Valid values are `active|retired|under_review|pending_approval`',
    `taxonomy_version` STRING COMMENT 'Version number of the internal indication taxonomy under which this record was classified (e.g., 2.1). Enables traceability of indication classification changes across taxonomy governance cycles and supports audit requirements.. Valid values are `^[0-9]+.[0-9]+$`',
    `unmet_medical_need_level` STRING COMMENT 'Level of unmet medical need for this indication, reflecting the gap between current treatment options and patient requirements.. Valid values are `high|moderate|low|not_assessed`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this indication record. Supports change tracking, audit trail compliance under 21 CFR Part 11, and data lineage requirements in the Databricks Silver Layer.',
    CONSTRAINT pk_indication PRIMARY KEY(`indication_id`)
) COMMENT 'Reference master for therapeutic indications and disease areas targeted by clinical development programs. Captures indication name, ICD-10/ICD-11 code, MedDRA preferred term mapping, therapeutic area classification, disease category, orphan disease flag';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` (
    `therapeutic_area_id` BIGINT COMMENT 'Unique surrogate identifier for the therapeutic area record. Primary key for the therapeutic_area reference master. [REFERENCE_LOOKUP role — canonical_skip_reason: This entity is a reference master / taxonomy code list defining therapeutic area',
    `organization_id` BIGINT COMMENT 'add column organization_id (BIGINT) with FK to sponsor.organization.organization_id — therapeutic areas are sponsor-defined',
    `parent_therapeutic_area_id` BIGINT COMMENT 'Self-referencing identifier pointing to the parent therapeutic area record, enabling a hierarchical taxonomy (e.g., Hematologic Oncology rolls up to Oncology). Null for top-level therapeutic areas.',
    `abbreviation` STRING COMMENT 'Commonly used abbreviation for the therapeutic area (e.g., ONCO, CNS, CV, ID). Used in report headers, KPI dashboards, and study identifiers where space is constrained.. Valid values are `^[A-Z]{2,10}$`',
    `active_program_count` BIGINT COMMENT 'Number of active clinical development programs currently classified under this therapeutic area. Provides a snapshot metric for portfolio governance dashboards and resource capacity planning.',
    `applicable_gcp_guideline` STRING COMMENT 'Specific GCP guideline or regulatory framework applicable to clinical trials in this therapeutic area (e.g., ICH E6(R2), ISO 14155 for medical devices, 21 CFR Part 11 for electronic records).',
    `approval_date` DATE COMMENT 'Date on which this therapeutic area record was formally approved by the governance owner for inclusion in the reference master. Required for audit trail compliance under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `approved_by` STRING COMMENT 'Name or user identifier of the individual who approved this therapeutic area record for use in the reference master. Supports audit trail requirements under 21 CFR Part 11 electronic signature standards and GCP data integrity (ALCOA+).',
    `biomarker_focus` STRING COMMENT 'Key biomarkers or biomarker categories relevant to clinical development programs in this therapeutic area (e.g., PD-L1 expression for Oncology, HbA1c for Diabetes, MMSE for CNS).',
    `cdisc_ta_standard` STRING COMMENT 'CDISC Therapeutic Area standard reference. Implements CDISC TA User Guide / standards catalog reference.',
    `therapeutic_area_code` STRING COMMENT 'Short, standardized alphanumeric code uniquely identifying the therapeutic area within the sponsor portfolio (e.g., ONCO, IMMUNO, CNS, CARDIO, INFECT, RARE). Used as a business key in CTMS, EDC study builds, and regulatory submissions.. Valid values are `^[A-Z0-9_]{2,20}$`',
    `competitive_landscape_summary` STRING COMMENT 'Summary of the competitive landscape within this therapeutic area, including key competitors and market dynamics.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this therapeutic area record was first created in the system. Supports audit trail requirements under 21 CFR Part 11, ALCOA+ data integrity principles, and data lineage tracking in the Databricks Silver Layer.',
    `ctms_ta_code` STRING COMMENT 'Therapeutic area code as configured in the source system for study classification, site feasibility assessment, and portfolio reporting. Serves as the cross-reference key between the enterprise data lakehouse and the operational CTMS system.',
    `data_privacy_classification` STRING COMMENT 'Data privacy classification level for patient data collected in clinical trials within this therapeutic area, reflecting sensitivity of health information (e.g., highly_sensitive for HIV, mental health, genetic data; sensitive for oncology; standard. Valid values are `standard|sensitive|highly_sensitive`',
    `therapeutic_area_description` STRING COMMENT 'Detailed narrative description of the therapeutic area, including the disease scope, patient population, and key biological mechanisms addressed. Used in regulatory submissions, portfolio governance documents, and sponsor-facing communications.',
    `disease_area` STRING COMMENT 'Specific disease area or indication cluster within the therapeutic area (e.g., within Oncology: Breast Cancer, Lung Cancer; within CNS: Alzheimers Disease, Parkinsons Disease).',
    `edc_ta_identifier` STRING COMMENT 'Therapeutic area identifier as configured in Medidata Rave EDC for study build classification and eCRF library alignment. Enables traceability between the reference master and EDC study configurations for CDISC SDTM mapping.',
    `effective_end_date` DATE COMMENT 'Date on which this therapeutic area classification ceased to be valid (null for currently active entries). Enables temporal validity management of the taxonomy, ensuring historical program classifications remain traceable after taxonomy updates.',
    `effective_start_date` DATE COMMENT 'Date from which this therapeutic area classification became effective and valid for use in program classification and regulatory submissions. Supports temporal validity tracking for the reference master taxonomy.',
    `global_disease_burden_rank` BIGINT COMMENT 'Relative ranking of this therapeutic area by global disease burden (e.g., based on WHO Global Burden of Disease data). Used in portfolio prioritization, business development decisions, and sponsor pipeline strategy assessments.',
    `governance_owner` STRING COMMENT 'Name or role of the business owner responsible for maintaining and governing this therapeutic area classification (e.g., VP Therapeutic Area Head, Chief Medical Officer). Accountable for taxonomy accuracy and alignment with sponsor portfolio strategy.',
    `hierarchy_level` BIGINT COMMENT 'Numeric depth of this therapeutic area within the taxonomy hierarchy. Level 1 represents the broadest classification (e.g., Oncology); higher levels represent sub-specialties (e.g., Level 2: Solid Tumors; Level 3: Non-Small Cell Lung Cancer).',
    `hierarchy_path` STRING COMMENT 'Full delimited path from the root therapeutic area to this node (e.g., Oncology > Solid Tumors > Non-Small Cell Lung Cancer). Facilitates breadcrumb navigation in portfolio governance tools and enables efficient subtree queries without recursive joins.',
    `icd11_code` STRING COMMENT 'ICD-11 classification code. Implements ICD classification code reference.. Valid values are `^[A-Z0-9]{1,7}(.[A-Z0-9]{1,6})?$`',
    `is_oncology` BOOLEAN COMMENT 'Indicates whether this therapeutic area is classified as oncology or hematology-oncology. Triggers specific regulatory considerations (FDA Oncology Center of Excellence, EMA oncology guidelines, CTCAE grading requirements) and specialized safety',
    `is_rare_disease` BOOLEAN COMMENT 'Indicates whether this therapeutic area is classified as a rare disease area (orphan disease), triggering specific regulatory designations (FDA Orphan Drug, EMA Orphan Medicinal Product), expedited review pathways, and specialized patient recruitment',
    `meddra_soc_code` STRING COMMENT 'MedDRA System Organ Class code. Implements MedDRA SOC.soccode (terminology domain).. Valid values are `^[0-9]{8}$`',
    `meddra_soc_name` STRING COMMENT 'MedDRA System Organ Class name. Implements MedDRA SOC.socname (terminology domain).',
    `therapeutic_area_name` STRING COMMENT 'Full human-readable name of the therapeutic area (e.g., Oncology, Immunology, Central Nervous System, Cardiovascular, Infectious Disease, Rare Disease). Used as the primary display label across portfolio governance dashboards and regulatory documents.',
    `patient_population_type` STRING COMMENT 'Primary patient population type targeted by clinical programs in this therapeutic area. Drives regulatory requirements (e.g., pediatric investigation plans under EMA PUMA, FDA PREA), protocol design, and IRB/IEC considerations.. Valid values are `adult|pediatric|geriatric|mixed|neonatal`',
    `portfolio_priority_tier` STRING COMMENT 'Sponsor-assigned portfolio priority tier for this therapeutic area, reflecting strategic investment level and resource allocation priority (e.g., Tier 1 = core franchise, Tier 2 = growth area, Tier 3 = exploratory).. Valid values are `tier_1|tier_2|tier_3|not_prioritized`',
    `primary_endpoint_type` STRING COMMENT 'Typical primary endpoint category used in clinical trials within this therapeutic area (e.g., Overall Survival for Oncology, ADAS-Cog for CNS/Alzheimers, ACR20 for Rheumatology, LVEF for Cardiovascular).',
    `primary_regulatory_agency` STRING COMMENT 'Primary health authority with jurisdiction over clinical development programs in this therapeutic area for the sponsors primary market. Determines applicable regulatory frameworks, submission formats (eCTD), and GCP inspection standards.',
    `primary_regulatory_pathway` STRING COMMENT 'Primary regulatory submission pathway most commonly associated with programs in this therapeutic area (e.g., NDA for small molecules, BLA for biologics, MAA for EU submissions). Guides regulatory strategy planning and submission resource allocation.',
    `regulatory_classification` STRING COMMENT 'Regulatory classification or designation relevant to this therapeutic area from applicable health authorities (e.g., Orphan Drug designation eligibility for Rare Disease, Breakthrough Therapy eligibility for Oncology, Priority Review eligibility).',
    `safety_system_ta_code` STRING COMMENT 'Therapeutic area code as configured in the source system for adverse event case routing, signal detection configuration, and regulatory case submission (ICSRs). Ensures consistent therapeutic area classification across safety reporting workflows.',
    `sponsor_portfolio_category` STRING COMMENT 'Sponsor-defined portfolio category or franchise label aligned to this therapeutic area (e.g., Oncology Franchise, Rare Disease Unit, Immunoscience). Maps the standardized therapeutic area taxonomy to the sponsors internal portfolio governance structure',
    `therapeutic_area_status` STRING COMMENT 'Current lifecycle status of the therapeutic area record within the reference master. active indicates the area is in use for program classification; deprecated indicates it has been superseded by a revised taxonomy entry; under_review indicates. Valid values are `active|inactive|deprecated|under_review`',
    `typical_trial_phase` STRING COMMENT 'Most common clinical trial phase(s) conducted within this therapeutic area, reflecting the maturity of the pipeline and typical development strategy (e.g., Phase III for established Oncology indications, Phase I/II for Rare Disease).. Valid values are `Phase I|Phase II|Phase III|Phase IV|Phase I/II|Phase II/III`',
    `unmet_medical_need_level` STRING COMMENT 'Level of unmet medical need within this therapeutic area, reflecting the gap between current treatment options and patient requirements.. Valid values are `high|moderate|low|not_assessed`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this therapeutic area record was last modified. Supports change tracking, audit trail compliance under 21 CFR Part 11, and incremental data pipeline processing in the Databricks Silver Layer.',
    `version_number` STRING COMMENT 'Version number of the therapeutic area taxonomy entry (e.g., 1.0, 2.1). Tracks changes to the classification definition over time, supporting audit trails required under 21 CFR Part 11 and GCP data integrity principles (ALCOA+).. Valid values are `^d+.d+(.d+)?$`',
    CONSTRAINT pk_therapeutic_area PRIMARY KEY(`therapeutic_area_id`)
) COMMENT 'Reference master defining the therapeutic area taxonomy used to classify clinical development programs and pipeline assets. Captures therapeutic area name, therapeutic area code, parent therapeutic area (for hierarchy), description, and alignment to';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` (
    `program_strategic_plan_id` BIGINT COMMENT 'Unique surrogate identifier for the program plan record in the Clinical Development Plan (CDP) or Integrated Development Plan (IDP) master table.',
    `author_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Development plan authorship is a regulatory document control requirement — the named author must be traceable for eTMF filing and regulatory submission.',
    `clinical_program_id` BIGINT COMMENT 'Reference to the parent clinical development program to which this plan belongs. Links the plan to the overarching therapeutic indication or pipeline asset.',
    `indication_id` BIGINT COMMENT 'Foreign key linking to program.indication. Business justification: program_plan.indication is a STRING field that denormalizes the indication reference master.',
    `master_agreement_id` BIGINT COMMENT 'Foreign key linking to sponsor.master_agreement. Business justification: Program plans are executed under the commercial framework of a master agreement. Linking program_plan to master_agreement enables financial and scope compliance checks against',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization funding and overseeing this clinical development program. Links the plan to the sponsor master record for contractual and regulatory accountability.',
    `superseded_program_plan_id` BIGINT COMMENT 'Self-referencing FK on program_plan (superseded_program_plan_id)',
    `therapeutic_area_id` BIGINT COMMENT 'Foreign key linking to program.therapeutic_area. Business justification: program_plan.therapeutic_area is a STRING field duplicating the therapeutic_area reference master.',
    `approval_date` DATE COMMENT 'The date on which this version of the Clinical Development Plan (CDP) received formal governance approval (e.g., from the Development Committee or Executive Sponsor). Marks the transition from draft/review to approved status.',
    `approval_target_date` DATE COMMENT 'Planned date for receipt of regulatory approval (e.g., FDA approval, EMA CHMP positive opinion) for the primary indication. Used for commercial launch planning and portfolio milestone reporting.',
    `breakthrough_designation` BOOLEAN COMMENT 'Indicates whether the investigational product has received FDA Breakthrough Therapy Designation (BTD) or EMA PRIME (PRIority MEdicines) designation for the target indication. Enables more intensive FDA/EMA guidance and rolling review.',
    `budget_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the planned program budget (e.g., USD, EUR, GBP). Enables multi-currency portfolio reporting and financial consolidation.. Valid values are `^[A-Z]{3}$`',
    `compound_code` STRING COMMENT 'The sponsors internal compound or asset code for the investigational product covered by this development plan (e.g., XYZ-001, ABC-123). Used as the primary asset identifier across portfolio management systems.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this program plan record was first created in the system, in ISO 8601 format with timezone offset. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `development_phase` STRING COMMENT 'The current or leading clinical development phase of the program at the time this plan was authored. Indicates the maturity of the asset and the scope of the CDP (e.g., phase_1 for first-in-human programs, phase_3 for pivotal programs).',
    `dsmb_required` BOOLEAN COMMENT 'Indicates whether a Data Safety Monitoring Board (DSMB) or Data Monitoring Committee (DMC) is required for the program based on the risk profile, study design, and regulatory requirements. Drives governance structure planning.',
    `end_date` DATE COMMENT 'The date on which this version of the Clinical Development Plan (CDP) is expected to conclude or be superseded. Null for open-ended plans. Used for planning horizon calculations and version lifecycle management.',
    `fih_target_date` DATE COMMENT 'Planned date for the first-in-human (FIH) dose administration for the program. A key program milestone used for portfolio milestone tracking and IND/CTA filing planning.',
    `go_no_go_criteria` STRING COMMENT 'Documented criteria that will be used to make go/no-go decisions at key program milestones (e.g., Phase II proof-of-concept readout, interim analysis results). Defines the evidence thresholds required to advance the program.',
    `inn_name` STRING COMMENT 'The International Nonproprietary Name (INN) or proposed INN (pINN) for the investigational product, as assigned or applied for from the WHO INN Programme. Used in regulatory submissions and scientific publications.',
    `key_assumptions` STRING COMMENT 'Key assumptions underlying the strategic plan, including scientific, regulatory, and operational premises.',
    `lead_regulatory_agency` STRING COMMENT 'The primary regulatory authority for the lead market submission under this development plan (e.g., FDA for US, EMA for EU, PMDA for Japan). Determines the primary regulatory strategy and submission format (eCTD).',
    `modality` STRING COMMENT 'The drug modality or product class of the investigational compound (e.g., small_molecule, biologic, cell_therapy, gene_therapy). Drives regulatory strategy, manufacturing requirements, and safety monitoring approach.',
    `nda_submission_target_date` DATE COMMENT 'Planned date for the primary regulatory submission (NDA/BLA/MAA) to the lead regulatory authority. A key program milestone driving backward planning for Phase III completion, Clinical Study Report (CSR) preparation, and eCTD assembly.',
    `orphan_drug_designation` BOOLEAN COMMENT 'Indicates whether the investigational product has received or is seeking Orphan Drug Designation (ODD) from FDA or EMA for the target indication. Orphan designation confers regulatory incentives including market exclusivity and fee waivers.',
    `owner_role` STRING COMMENT 'The organizational role or function responsible for owning and maintaining this Clinical Development Plan (CDP) (e.g., Global Program Director, Clinical Development Lead, VP Clinical Development). Supports governance accountability.',
    `plan_number` STRING COMMENT 'Externally-known, human-readable identifier for the Clinical Development Plan (CDP) or Integrated Development Plan (IDP). Follows the organizational naming convention (e.g., CDP-ONCO001-2024-v1). Used in regulatory submissions and governance documents.. Valid values are `^CDP-[A-Z0-9]{3,10}-[0-9]{4}-v[0-9]{1,3}$`',
    `planned_budget_usd` DECIMAL(18,2) COMMENT 'The total approved budget envelope for the entire clinical development program as defined in this plan version, expressed in US Dollars (USD). Represents the high-level financial commitment approved by governance.',
    `planned_study_count` BIGINT COMMENT 'The total number of clinical studies (Phase I through Phase III/IV) planned under this development program as defined in the CDP. Used for portfolio capacity planning and milestone tracking.',
    `planned_subject_count` BIGINT COMMENT 'The total number of subjects (patients or healthy volunteers) planned for enrollment across all studies within the program as defined in the CDP. Drives site selection, patient recruitment strategy, and budget planning.',
    `planning_horizon_years` BIGINT COMMENT 'The total number of years covered by this Clinical Development Plan (CDP), from first-in-human (FIH) or current phase through anticipated regulatory approval. Drives long-range resource planning and portfolio forecasting.',
    `poa_target_date` DATE COMMENT 'Planned date for the proof-of-concept (POC) or proof-of-activity (POA) readout, typically at the end of Phase II. A critical go/no-go decision milestone for program continuation and investment decisions.',
    `primary_endpoint_description` STRING COMMENT 'Description of the primary clinical endpoint(s) that the program is designed to demonstrate, as defined in the CDP. Aligns with the Target Product Profile (TPP) and regulatory agency expectations for the indication.',
    `program_plan_status` STRING COMMENT 'Current lifecycle status of the program plan record. Draft indicates work-in-progress; under_review indicates governance review in progress; approved indicates formal sign-off received; superseded indicates replaced by a newer version; retired indicates. Valid values are `draft|under_review|approved|superseded|retired`',
    `program_plan_type` STRING COMMENT 'Classification of the plan document indicating its stage in the approval lifecycle: initial (first draft), revised (updated after review), amended (post-approval change), approved (formally endorsed), or final (locked version submitted to regulatory. Valid values are `initial|revised|amended|approved|final`',
    `regulatory_pathway` STRING COMMENT 'The regulatory development pathway designated for the program asset. Drives planning assumptions for review timelines and submission strategy. [ENUM-REF-CANDIDATE: standard|accelerated|breakthrough|orphan|fast_track|priority_review|rolling_review —',
    `start_date` DATE COMMENT 'The date from which this version of the Clinical Development Plan (CDP) becomes effective and governs program activities. Corresponds to the plan approval date for approved versions.',
    `strategy_narrative` STRING COMMENT 'Narrative description of the development strategy, including rationale, approach, and expected outcomes.',
    `submission_type` STRING COMMENT 'The anticipated regulatory submission type targeted by this development plan. IND (Investigational New Drug), NDA (New Drug Application), BLA (Biologics License Application), MAA (Marketing Authorization Application), sNDA (supplemental NDA), or sBLA. Valid values are `IND|NDA|BLA|MAA|sNDA|sBLA`',
    `title` STRING COMMENT 'Full descriptive title of the Clinical Development Plan (CDP) or Integrated Development Plan (IDP), including the therapeutic indication and compound name (e.g., Integrated Development Plan for Compound XYZ in Relapsed/Refractory Multiple Myeloma).',
    `tpp_reference` STRING COMMENT 'Document identifier or version reference for the Target Product Profile (TPP) that defines the desired product characteristics (efficacy, safety, dosing) guiding the development plan.',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time when this program plan record was most recently modified, in ISO 8601 format with timezone offset. Supports change tracking, audit trail requirements, and Silver Layer incremental processing.',
    `version_number` STRING COMMENT 'Version identifier of the Clinical Development Plan (CDP) following the organizations document versioning convention (e.g., 1.0, 2.1, 3.0). Incremented with each approved revision to maintain a complete audit trail of plan evolution.. Valid values are `^[0-9]{1,3}.[0-9]{1,2}$`',
    CONSTRAINT pk_program_strategic_plan PRIMARY KEY(`program_strategic_plan_id`)
) COMMENT 'Strategic development plan for a clinical program, defining objectives, timelines, budget, regulatory pathway, and key assumptions. This is the canonical program-level plan entity; supply.supply_plan references this when a supply plan is linked to a';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`program`.`amendment` (
    `amendment_id` BIGINT COMMENT 'Unique surrogate identifier for each program amendment record in the clinical development plan version history.',
    `clinical_program_id` BIGINT COMMENT 'Reference to the clinical development program to which this amendment applies.',
    `initiated_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Program amendment initiation must be traceable to a named employee for regulatory change control compliance (ICH E6 GCP, 21 CFR Part 11).',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization that owns the clinical development program and must authorize the amendment.',
    `program_strategic_plan_id` BIGINT COMMENT 'Reference to the specific version of the Clinical Development Plan (CDP) that this amendment modifies.',
    `superseded_amendment_id` BIGINT COMMENT 'Self-referencing FK on amendment (superseded_amendment_id)',
    `tmf_document_id` BIGINT COMMENT 'Reference identifier for the amendment document stored in the Veeva Vault Electronic Trial Master File (eTMF), enabling traceability between the data record and the source document.',
    `affected_indication` STRING COMMENT 'The therapeutic indication or disease area within the program that is specifically affected by this amendment, using MedDRA terminology where applicable.',
    `affected_study_count` BIGINT COMMENT 'Number of individual clinical studies within the program that are impacted by this amendment, used for cross-study coordination and workload assessment.',
    `approval_date` DATE COMMENT 'The date on which the amendment received final governance approval from the designated approver(s), distinct from the effective date.',
    `approver_name` STRING COMMENT 'Full name of the individual (typically a Program Director, Chief Medical Officer, or Sponsor representative) who granted final governance approval for this amendment.',
    `approver_role` STRING COMMENT 'The organizational role or title of the individual who approved the amendment (e.g., Program Director, Chief Medical Officer, Sponsor VP Clinical Development).',
    `budget_impact_flag` BOOLEAN COMMENT 'Indicates whether this amendment results in a change to the program-level budget, triggering a financial change order process in the source system',
    `change_control_number` STRING COMMENT 'Formal change control tracking number assigned by the quality management system (MasterControl) for this amendment, linking it to the CAPA and quality event management process.',
    `change_description` STRING COMMENT 'Detailed narrative description of the specific changes being made to the Clinical Development Plan (CDP), including affected sections, study phases, or therapeutic areas.',
    `change_rationale` STRING COMMENT 'Scientific, regulatory, or operational justification for the amendment, documenting the business or clinical reason driving the change to the program plan.',
    `comments` STRING COMMENT 'Free-text field for additional governance notes, reviewer comments, or contextual information related to the amendment that does not fit structured fields.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp recording when this amendment record was first created in the data platform, supporting audit trail and ALCOA+ contemporaneous documentation requirements.',
    `amendment_date` DATE COMMENT 'The principal real-world date on which the amendment was formally initiated or submitted for review, representing the business event date.',
    `dsmb_notification_required` BOOLEAN COMMENT 'Indicates whether the Data Safety Monitoring Board (DSMB) or Data Monitoring Committee (DMC) must be notified of this amendment due to safety or study design implications.',
    `effective_date` DATE COMMENT 'The date on which the approved amendment becomes operationally binding and the revised Clinical Development Plan (CDP) takes effect across all affected studies and sites.',
    `impact_assessment_summary` STRING COMMENT 'Summary of the assessed impact of the amendment on program scope, timelines, budget, regulatory strategy, and affected studies, as evaluated during the governance review process.',
    `implementation_deadline` DATE COMMENT 'Target date by which the changes specified in the amendment must be fully implemented across all affected studies, sites, and operational systems.',
    `irb_iec_notification_required` BOOLEAN COMMENT 'Indicates whether the Institutional Review Board (IRB) or Independent Ethics Committee (IEC) must be notified or must approve this amendment before implementation.',
    `number` STRING COMMENT 'Externally-known sequential identifier for the amendment within the program, used for governance tracking and regulatory correspondence (e.g., AMD-2024-001).. Valid values are `^AMD-[0-9]{4}-[0-9]{3}$`',
    `previous_version_number` STRING COMMENT 'Version number of the Clinical Development Plan (CDP) that this amendment supersedes, enabling complete version chain reconstruction for audit and regulatory review.. Valid values are `^[0-9]+.[0-9]+$`',
    `priority_level` STRING COMMENT 'Business priority classification of the amendment, used to triage governance review timelines and resource allocation for implementation across affected studies.. Valid values are `critical|high|medium|low`',
    `regulatory_authority` STRING COMMENT 'The primary health authority to which a regulatory submission related to this amendment is directed (e.g., FDA, EMA, PMDA). [ENUM-REF-CANDIDATE: FDA|EMA|PMDA|MHRA|TGA|Health_Canada|WHO|ANVISA|CFDA — promote to reference product if multi-authority tracking',
    `regulatory_impact_flag` BOOLEAN COMMENT 'Indicates whether this amendment requires notification or submission to regulatory authorities such as FDA, EMA, PMDA, or MHRA, or triggers an IND amendment.',
    `regulatory_submission_date` DATE COMMENT 'The date on which the amendment-related regulatory submission (e.g., IND amendment) was filed with the applicable health authority.',
    `regulatory_submission_required` BOOLEAN COMMENT 'Indicates whether this amendment requires a formal regulatory submission (e.g., IND amendment, Clinical Trial Application variation) to one or more health authorities.',
    `review_deadline` DATE COMMENT 'Target date by which the governance review and approval of the amendment must be completed, used for escalation tracking and program milestone management.',
    `safety_impact_flag` BOOLEAN COMMENT 'Indicates whether this amendment has implications for subject safety, risk management, or Data Safety Monitoring Board (DSMB) / Data Monitoring Committee (DMC) review requirements.',
    `scope_impact_flag` BOOLEAN COMMENT 'Indicates whether this amendment results in a material change to the program scope, such as addition or removal of studies, indications, or patient populations.',
    `amendment_status` STRING COMMENT 'Current lifecycle state of the amendment through the governance and approval workflow (draft, under review, approved, rejected, or superseded by a later amendment).. Valid values are `draft|under_review|approved|rejected|superseded`',
    `superseded_date` DATE COMMENT 'The date on which this amendment was superseded by a subsequent amendment, enabling complete version history tracking of the Clinical Development Plan (CDP).',
    `timeline_impact_flag` BOOLEAN COMMENT 'Indicates whether this amendment results in a change to program-level milestone dates or study timelines within the Clinical Development Plan (CDP).',
    `title` STRING COMMENT 'Short human-readable title summarizing the primary purpose of the amendment, used for governance dashboards and portfolio reporting.',
    `amendment_type` STRING COMMENT 'Classification of the amendment by the nature of the change being made to the Clinical Development Plan (CDP). [ENUM-REF-CANDIDATE: scope_change|timeline_revision|budget_revision|regulatory_strategy_update|safety_update|protocol_design_change — promote to',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp recording when this amendment record was last modified in the data platform, supporting audit trail integrity and change tracking.',
    `version_number` STRING COMMENT 'Document version number of the amended Clinical Development Plan (CDP) resulting from this amendment (e.g., 2.0, 3.1), used for version control in the eTMF.. Valid values are `^[0-9]+.[0-9]+$`',
    CONSTRAINT pk_amendment PRIMARY KEY(`amendment_id`)
) COMMENT 'Tracks formal amendments and revisions to the clinical development plan (CDP) for a program. Captures amendment number, amendment date, amendment type (scope change, timeline revision, budget revision, regulatory strategy update), description of changes';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`program`.`governance` (
    `governance_id` BIGINT COMMENT 'Unique surrogate identifier for the program governance body record in the clinical development program. Primary key for this entity.',
    `agreement_preferred_provider_agreement_id` BIGINT COMMENT 'Foreign key linking to agreement.preferred_provider_agreement. Business justification: PPAs explicitly establish governance committees (governance_committee_name, governance_review_frequency in preferred_provider_agreement).',
    `chair_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Governance body chairs are named employees accountable for program oversight decisions. Regulatory inspections (ICH E6 GCP) require traceable governance accountability.',
    `master_agreement_id` BIGINT COMMENT 'Foreign key linking to sponsor.master_agreement. Business justification: Governance bodies (JDCs, steering committees) are established per master agreement terms. Charter references and governance structures are contractually defined.',
    `parent_governance_id` BIGINT COMMENT 'Self-referencing FK on governance (parent_governance_id)',
    `primary_escalation_body_governance_id` BIGINT COMMENT 'Reference to the higher-level governance body to which unresolved issues or decisions exceeding this bodys authority are escalated. Supports governance hierarchy modeling.',
    `sponsor_engagement_id` BIGINT COMMENT 'Foreign key linking to sponsor.engagement. Business justification: Governance bodies are established as part of the CRO-sponsor engagement framework. Joint development committees and steering committees are defined in engagement terms.',
    `applicable_regulations` STRING COMMENT 'Comma-separated list of regulatory frameworks and guidelines governing this bodys operations (e.g., ICH E6(R2), 21 CFR Part 312, EU CTR 536/2014, ISO 14155). Supports compliance tracking and inspection readiness.',
    `body_code` STRING COMMENT 'Short alphanumeric code uniquely identifying the governance body within the program portfolio, used in CTMS and reporting systems (e.g., JDC-ONC-001, PRB-CARD-002).. Valid values are `^[A-Z0-9_-]{2,30}$`',
    `body_name` STRING COMMENT 'Official name of the governance body or oversight committee established to manage the clinical development program (e.g., Oncology Program Steering Committee, Phase II/III Joint Development Committee).',
    `body_type` STRING COMMENT 'Classification of the governance body by its structural role and authority level within the program. [ENUM-REF-CANDIDATE: Joint Development Committee|Program Review Board|Portfolio Review Committee|Steering Committee|Data Monitoring Committee|Operating. Valid values are `Joint Development Committee|Program Review Board|Portfolio Review Committee|Steering Committee|Data Monitoring Committee|Operating Committee`',
    `charter_approval_date` DATE COMMENT 'Date on which the current version of the governance body charter was formally approved by authorized signatories.',
    `charter_reference` STRING COMMENT 'Document identifier or eTMF reference number for the formal charter that defines the governance bodys mandate, authority, and operating procedures. Typically stored in Veeva Vault eTMF.',
    `charter_version` STRING COMMENT 'Version number of the current approved governance charter document (e.g., v1.0, v2.3). Tracks charter amendments over the program lifecycle.. Valid values are `^v?d+.d+$`',
    `confidentiality_requirement` STRING COMMENT 'Level of confidentiality required for governance body deliberations, documents, and decisions. Full confidentiality is typically required for DMC/DSMB bodies with access to unblinded data.. Valid values are `Full Confidentiality|Partial Confidentiality|No Confidentiality Requirement`',
    `conflict_of_interest_policy` STRING COMMENT 'Reference to the conflict of interest policy or disclosure requirements applicable to governance body members, including the document identifier or policy version. Critical for independent committees such as DMC/DSMB.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this governance body record was first created in the system. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `cro_co_chair` STRING COMMENT 'Name or identifier of the CROs designated co-chair for the governance body. Represents the CROs senior leadership in sponsor-CRO governance structures such as Joint Development Committees.',
    `decision_authority_level` STRING COMMENT 'Classification of the governance bodys decision-making power: whether its decisions are advisory recommendations, binding resolutions, or require escalation to a higher authority.. Valid values are `Advisory|Recommendatory|Binding|Escalation Required`',
    `decision_authority_scope` STRING COMMENT 'Narrative description of the types of decisions the governance body is authorized to make, including escalation thresholds, budget authority limits, protocol amendment approvals, and go/no-go decision rights as defined in the charter.',
    `dissolution_date` DATE COMMENT 'Date on which the governance body was formally dissolved or disbanded. Null if the body is still active. Marks the end of the bodys authority and oversight responsibilities.',
    `formation_date` DATE COMMENT 'Date on which the governance body was formally established and constituted for the clinical development program. Marks the effective start of the bodys authority.',
    `geographic_scope` STRING COMMENT 'Geographic regions or countries covered by the governance bodys oversight mandate (e.g., Global, North America, EU, USA, GBR, DEU, JPN). Relevant for multi-regional programs with jurisdiction-specific governance requirements.',
    `independence_requirement` STRING COMMENT 'Classification of the independence requirement for governance body membership, particularly relevant for Data Monitoring Committees (DMC/DSMB) where regulatory guidance mandates independence from the sponsor and study team.. Valid values are `Fully Independent|Partially Independent|No Independence Requirement|Sponsor-CRO Joint`',
    `last_charter_review_date` DATE COMMENT 'Date of the most recent formal review of the governance body charter. Used to track compliance with the defined review cycle and flag overdue reviews.',
    `meeting_format` STRING COMMENT 'Standard format for governance body meetings as defined in the charter: in-person, virtual (teleconference/videoconference), or hybrid. Relevant for meeting logistics and quorum validation.. Valid values are `In-Person|Virtual|Hybrid`',
    `meeting_frequency` STRING COMMENT 'Scheduled cadence at which the governance body convenes for formal meetings, as defined in the charter. Drives meeting planning and calendar management in CTMS.',
    `member_composition_summary` STRING COMMENT 'Narrative summary describing the composition of the governance body membership, including functional roles represented (e.g., Clinical, Regulatory, Biostatistics, Finance, Medical Affairs, Sponsor, CRO) and any independence requirements.',
    `minutes_archival_location` STRING COMMENT 'System or repository location where governance body meeting minutes are archived (e.g., Veeva Vault eTMF folder path, document management system reference). Supports TMF completeness and inspection readiness.',
    `minutes_required` BOOLEAN COMMENT 'Indicates whether formal meeting minutes are required to be produced and archived for each governance body meeting, as mandated by the charter or regulatory requirements.',
    `next_charter_review_date` DATE COMMENT 'Scheduled date for the next formal review of the governance body charter. Calculated from last review date plus review cycle. Supports proactive compliance management.',
    `notes` STRING COMMENT 'Free-text field for additional context, special conditions, or operational notes about the governance body not captured in structured fields. Used by program managers for ad hoc documentation.',
    `operating_procedures_ref` STRING COMMENT 'Reference to the Standard Operating Procedures (SOPs) or working procedures that govern the governance bodys operations, meeting conduct, and decision-making processes. Links to MasterControl SOP repository.',
    `program_phase` STRING COMMENT 'Clinical development phase(s) covered by the program under this governance bodys oversight. Indicates the stage of drug development being governed. [ENUM-REF-CANDIDATE: Phase I|Phase I/II|Phase II|Phase II/III|Phase III|Phase IV|Pre-Clinical — 7',
    `quorum_percentage` DECIMAL(5,2) COMMENT 'Minimum percentage of total voting membership required for quorum, expressed as a decimal (e.g., 66.67 for two-thirds majority). Used when quorum is defined proportionally rather than by fixed count.',
    `quorum_requirement` BIGINT COMMENT 'Minimum number of voting members required to be present for a governance body meeting to be considered valid and decisions to be binding, as specified in the charter.',
    `regulatory_reporting_required` BOOLEAN COMMENT 'Indicates whether the governance bodys decisions or recommendations are subject to regulatory reporting obligations (e.g., DMC recommendations that trigger IND safety reports or protocol amendments).',
    `review_cycle_months` BIGINT COMMENT 'Frequency in months at which the governance body charter and membership composition are formally reviewed and reaffirmed or updated. Typically 12 or 24 months per GCP best practices.',
    `sponsor_co_chair` STRING COMMENT 'Name or identifier of the sponsor organizations designated co-chair for the governance body. Typically a senior sponsor representative in Joint Development Committee structures.',
    `sponsor_organization` STRING COMMENT 'The sponsor organization responsible for this governance body.',
    `governance_status` STRING COMMENT 'Current lifecycle status of the governance body, indicating whether it is actively operating, temporarily suspended, or formally dissolved.. Valid values are `Active|Inactive|Suspended|Dissolved|Pending Formation|Under Review`',
    `therapeutic_area` STRING COMMENT 'Therapeutic area or disease indication that the clinical development program and its governance body oversee (e.g., Oncology, Cardiovascular, Neurology, Immunology). Aligns with MedDRA System Organ Class taxonomy.',
    `tier` STRING COMMENT 'Hierarchical tier of the governance body within the programs governance framework. Strategic bodies set direction and approve major decisions; Operational bodies manage execution; Tactical bodies handle day-to-day coordination.. Valid values are `Strategic|Operational|Tactical`',
    `total_member_count` BIGINT COMMENT 'Total number of members constituting the governance body, including voting and non-voting members, as defined in the charter. Used for quorum calculation and composition reporting.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this governance body record. Supports audit trail and data lineage tracking per 21 CFR Part 11 and ALCOA+ principles.',
    `voting_member_count` BIGINT COMMENT 'Number of members with formal voting rights within the governance body. Distinct from total membership which may include non-voting observers or advisors.',
    CONSTRAINT pk_governance PRIMARY KEY(`governance_id`)
) COMMENT 'Master record for program-level governance bodies and oversight committees established to manage a clinical development program. Captures governance body name, type (Joint Development Committee, Program Review Board, Portfolio Review Committee, Steering';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`program`.`governance_meeting` (
    `governance_meeting_id` BIGINT COMMENT 'Unique surrogate identifier for each program governance meeting record in the lakehouse silver layer.',
    `chair_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Governance meeting chairs are named employees accountable for quorum, decision authority, and minutes approval. Regulatory inspections require traceable meeting governance.',
    `clinical_program_id` BIGINT COMMENT 'Reference to the clinical development program under whose governance structure this meeting was convened.',
    `governance_id` BIGINT COMMENT 'Reference to the program oversight committee (e.g., Program Review Board, Joint Steering Committee, Data Monitoring Committee) that convened this meeting.',
    `organization_contact_id` BIGINT COMMENT 'Foreign key linking to sponsor.sponsor_contact. Business justification: Governance meetings have a sponsor co-chair who is a specific sponsor contact. governance_meeting has chair_name as a denormalized plain text field.',
    `primary_prior_meeting_governance_meeting_id` BIGINT COMMENT 'Reference to the immediately preceding governance meeting in the same committee series. Enables meeting chain linkage for action item carry-forward tracking and minutes continuity.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Governance meeting minutes are TMF-essential documents (DIA TMF Reference Model Zone 1).',
    `action_item_count` BIGINT COMMENT 'Total number of action items raised during the governance meeting. Supports tracking of follow-up obligations and governance accountability metrics.',
    `agenda_distributed_date` DATE COMMENT 'Date on which the meeting agenda was formally distributed to attendees. Regulatory and governance best practice requires agenda distribution within a defined period before the meeting.',
    `agenda_topics` STRING COMMENT 'Structured summary or pipe-delimited list of the principal agenda items discussed at the meeting (e.g., Study Progress Review | Safety Data Review | Enrollment Update | Budget Review). Supports meeting content search and analytics.',
    `agenda_version` STRING COMMENT 'Version identifier of the final agenda document circulated prior to the meeting (e.g., v1.0, v2.1). Supports document control and traceability to the eTMF.. Valid values are `^vd+.d+$`',
    `attendee_count` BIGINT COMMENT 'Total number of individuals who attended the governance meeting, including voting members, non-voting observers, and invited guests. Used for quorum verification and minutes accuracy.',
    `chair_role` STRING COMMENT 'Organizational role or title of the meeting chair (e.g., Chief Medical Officer, Program Director, Independent Committee Chair). Provides governance accountability context.',
    `confidentiality_level` STRING COMMENT 'Confidentiality classification of the meeting and its outputs: open (no restrictions), restricted (internal program team only), closed (voting members only, e.g., DSMB closed session), strictly_confidential (blinded safety data, regulatory-sensitive).. Valid values are `open|restricted|closed|strictly_confidential`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this governance meeting record was first created in the system. Supports ALCOA+ audit trail and 21 CFR Part 11 electronic record compliance.',
    `decision_count` BIGINT COMMENT 'Total number of formal decisions recorded during the governance meeting. Used for governance KPI reporting and meeting productivity analytics.',
    `end_time` TIMESTAMP COMMENT 'Precise date and time (with timezone offset) at which the governance meeting concluded. Used to calculate meeting duration and for minutes accuracy.',
    `escalation_description` STRING COMMENT 'Narrative description of the issue or decision requiring escalation to a higher governance body. Populated only when escalation_required is True.',
    `escalation_required` BOOLEAN COMMENT 'Indicates whether any decision or issue arising from this meeting requires escalation to a higher governance body (e.g., Executive Steering Committee, Sponsor). True = escalation triggered; False = no escalation required.',
    `key_decisions` STRING COMMENT 'Narrative summary of the principal decisions made during the governance meeting (e.g., protocol amendment approval, site expansion authorization, budget reallocation). Extracted from approved minutes for analytics and reporting.',
    `location` STRING COMMENT 'Physical venue or virtual platform where the meeting was held (e.g., Conference Room A, Boston HQ or Microsoft Teams). Recorded in minutes for audit trail purposes.',
    `meeting_date` DATE COMMENT 'Calendar date on which the governance meeting was held or is scheduled to be held. Principal real-world event date for this transaction.',
    `meeting_format` STRING COMMENT 'Modality of the meeting: in_person (all attendees physically co-located), virtual (all attendees remote via teleconference/videoconference), or hybrid (mix of in-person and remote attendees).. Valid values are `in_person|virtual|hybrid`',
    `meeting_frequency` STRING COMMENT 'Cadence at which this type of governance meeting is regularly convened as defined in the committee charter. Used for scheduling compliance monitoring. [ENUM-REF-CANDIDATE: weekly|bi_weekly|monthly|quarterly|semi_annual|annual|as_needed — 7 candidates',
    `meeting_number` STRING COMMENT 'Externally-known sequential or structured identifier for the meeting (e.g., PRG-GOV-2024-007). Used as the business-facing reference in agendas, minutes, and action item logs.. Valid values are `^[A-Z0-9-]{3,30}$`',
    `meeting_status` STRING COMMENT 'Current lifecycle state of the governance meeting record. Drives workflow routing for agenda preparation, minutes approval, and action item follow-up.. Valid values are `scheduled|in_progress|completed|cancelled|postponed|rescheduled`',
    `meeting_title` STRING COMMENT 'Descriptive title of the governance meeting as it appears on the agenda and minutes document (e.g., Q3 2024 Program Review Board Meeting – PROG-001).',
    `meeting_type` STRING COMMENT 'Classification of the meeting by its scheduling basis: scheduled (routine calendar meeting), ad_hoc (convened outside the regular schedule), emergency (convened urgently for a safety or critical operational issue), or extraordinary (special purpose. Valid values are `scheduled|ad_hoc|emergency|extraordinary`',
    `minutes_approved_date` DATE COMMENT 'Date on which the meeting minutes were formally approved by the committee chair or designated approver. Required for regulatory audit trail and eTMF completeness.',
    `minutes_approver_name` STRING COMMENT 'Full name of the individual who formally approved the meeting minutes. Supports ALCOA+ compliance (Attributable, Legible, Contemporaneous, Original, Accurate) for regulatory audit readiness.',
    `minutes_status` STRING COMMENT 'Current approval lifecycle state of the meeting minutes document: draft (initial preparation), under_review (circulated for comment), approved (formally signed off by chair), final (distributed to all attendees), archived (filed in eTMF).. Valid values are `draft|under_review|approved|final|archived`',
    `next_meeting_date` DATE COMMENT 'Scheduled date of the next governance meeting as agreed at the close of this meeting. Supports forward planning and governance calendar management.',
    `open_action_items_from_prior` BIGINT COMMENT 'Number of action items from previous governance meetings that remained open and were reviewed at this meeting. Key governance health indicator.',
    `quorum_achieved` BOOLEAN COMMENT 'Indicates whether the required quorum of voting members was present at the meeting, making decisions and resolutions formally binding. True = quorum met; False = quorum not met.',
    `quorum_required` BIGINT COMMENT 'Minimum number of voting members required to be present for the meeting to be quorate and for decisions to be binding, as defined in the committee charter.',
    `regulatory_implication_flag` BOOLEAN COMMENT 'Indicates whether any decision or discussion item from this meeting has a direct regulatory implication (e.g., protocol amendment requiring IND/CTA update, safety signal requiring expedited reporting). True = regulatory action may be required.',
    `safety_topic_discussed` BOOLEAN COMMENT 'Indicates whether any safety-related topic (e.g., SAE review, SUSAR assessment, DSMB recommendation, risk-benefit evaluation) was discussed during the meeting. Supports safety governance audit trail.',
    `session_type` STRING COMMENT 'Indicates whether the meeting (or a portion thereof) was conducted as an open session (all attendees), closed session (voting members only, e.g., for unblinded safety review), or executive session (senior leadership only).. Valid values are `open|closed|executive`',
    `start_time` TIMESTAMP COMMENT 'Precise date and time (with timezone offset) at which the governance meeting commenced. Used for quorum determination and minutes accuracy.',
    `tmf_zone` STRING COMMENT 'Reference to the TMF zone and section under which the meeting minutes and agenda are filed in the eTMF (e.g., Zone 1 / Section 1.3 – Governance). Supports eTMF completeness and inspection readiness.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this governance meeting record was most recently modified. Supports change tracking, audit trail, and silver layer incremental processing.',
    `voting_member_count` BIGINT COMMENT 'Number of voting committee members who were present at the meeting. Used to confirm quorum achievement and validate the binding nature of decisions made.',
    CONSTRAINT pk_governance_meeting PRIMARY KEY(`governance_meeting_id`)
) COMMENT 'Transactional record for each formal program governance meeting held by a program oversight committee. Captures meeting date, meeting type (scheduled, ad hoc, emergency), agenda topics, attendees, quorum achieved flag, key decisions made, action items';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`program`.`decision` (
    `decision_id` BIGINT COMMENT 'Unique surrogate identifier for each formal program-level decision record in the clinical development portfolio.',
    `application_id` BIGINT COMMENT 'Foreign key linking to regulatory.application. Business justification: Go/no-go program decisions (e.g., proceed to NDA filing, terminate program) are made in the context of specific regulatory applications.',
    `clinical_program_id` BIGINT COMMENT 'Reference to the clinical development program against which this decision was made.',
    `dsmb_meeting_id` BIGINT COMMENT 'Foreign key linking to biostatistics.dsmb_meeting. Business justification: Program go/no-go decisions are directly triggered by DSMB meeting recommendations (program_decision.dsmb_recommendation is a text field).',
    `governance_id` BIGINT COMMENT 'Reference to the governance body or committee (e.g., Portfolio Review Board, Executive Committee, DSMB/DMC) that issued this decision.',
    `governance_meeting_id` BIGINT COMMENT 'Foreign key linking to program.governance_meeting. Business justification: program_decision.meeting_reference is a STRING field that informally references the governance meeting at which the decision was made.',
    `interim_analysis_id` BIGINT COMMENT 'Foreign key linking to biostatistics.interim_analysis. Business justification: Program decisions to stop, continue, or adapt a program are driven by interim analysis outcomes.',
    `maker_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Go/no-go decisions on clinical programs must be traceable to named employees for regulatory submissions and governance audit trails.',
    `organization_contact_id` BIGINT COMMENT 'Foreign key linking to sponsor.sponsor_contact. Business justification: Program decisions require sponsor concurrence (sponsor_concurrence_flag and sponsor_concurrence_date already exist).',
    `primary_superseded_by_decision_id` BIGINT COMMENT 'Self-referencing identifier pointing to the subsequent program_decision record that replaced or superseded this decision. Null if this decision is current and active. Enables decision lineage and version chain traceability.',
    `risk_assessment_id` BIGINT COMMENT 'Foreign key linking to compliance.risk_assessment. Business justification: Program go/no-go decisions (phase transitions, terminations) are formally supported by GCP risk assessments.',
    `signal_id` BIGINT COMMENT 'Foreign key linking to safety.safety_signal. Business justification: Program go/no-go decisions and phase transitions are frequently triggered by safety signals. program_decision has safety_signal_flag (boolean) but no FK to the specific signal.',
    `study_budget_id` BIGINT COMMENT 'Foreign key linking to finance.study_budget. Business justification: Go/no-go program decisions directly impact study budgets — a go decision releases budget, a no-go freezes or terminates it.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Program go/no-go decisions and phase transition decisions are TMF-filed documents per ICH E6 GCP.',
    `action_items_summary` STRING COMMENT 'Summary of follow-up action items, next steps, or deliverables assigned as a result of this decision (e.g., protocol amendment required, regulatory submission to be filed, additional safety data to be collected). Supports program execution tracking.',
    `authority_name` STRING COMMENT 'Name of the governance body, committee, or executive role that holds formal authority for this decision (e.g., Portfolio Review Committee, Chief Medical Officer, Executive Leadership Team).',
    `benefit_risk_assessment` STRING COMMENT 'Assessment of the benefit-risk profile that informed this decision, weighing therapeutic benefits against potential risks.',
    `conditions_of_approval` STRING COMMENT 'Conditions or requirements attached to the approval decision, including any post-approval commitments.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this program decision record was first created in the system. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `decision_date` DATE COMMENT 'The calendar date on which the formal decision was officially made and ratified by the decision authority. This is the principal real-world event date for the decision record.',
    `dissenting_opinion_flag` BOOLEAN COMMENT 'Indicates whether any member of the decision-making body formally recorded a dissenting opinion against the decision outcome. True if a dissent was registered. Supports governance transparency and audit trail integrity.',
    `dissenting_opinion_summary` STRING COMMENT 'Summary of any dissenting opinions expressed during the decision-making process.',
    `dsmb_recommendation` STRING COMMENT 'The formal recommendation issued by the Data Safety Monitoring Board (DSMB) or Data Monitoring Committee (DMC) that informed this decision, where applicable. Values: continue, modify, pause, terminate, not_applicable.. Valid values are `continue|modify|pause|terminate|not_applicable`',
    `effective_date` DATE COMMENT 'The date from which the decision becomes operationally binding and program activities must align with the decision outcome. May differ from decision_date if a transition period is granted.',
    `indication` STRING COMMENT 'Specific disease or medical condition targeted by the program at the time of this decision (e.g., Non-Small Cell Lung Cancer, Type 2 Diabetes). Supports indication-level portfolio governance and regulatory strategy tracking.',
    `investment_amount` DECIMAL(18,2) COMMENT 'The approved or committed financial investment amount associated with this decision (e.g., budget approved for next phase, termination cost). Expressed in the programs base currency. Business-confidential financial data.',
    `investment_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the investment_amount field (e.g., USD, EUR, GBP). Required for multi-currency portfolio financial reporting.. Valid values are `^[A-Z]{3}$`',
    `maker_role` STRING COMMENT 'Organizational role or title of the individual who made or ratified the decision (e.g., Chief Medical Officer, VP Clinical Development, Program Steering Committee Chair). Supports governance accountability reporting.',
    `number` STRING COMMENT 'Externally-known, human-readable unique reference number assigned to this program decision record, used in governance minutes, regulatory dossiers, and TMF cross-references.. Valid values are `^DEC-[A-Z0-9]{3,10}-[0-9]{4}-[0-9]{4}$`',
    `outcome` STRING COMMENT 'The formal result of the governance decision: approved (proceed), rejected (do not proceed), deferred (postponed pending additional data), conditional_approval (proceed with conditions), or withdrawn (decision request retracted prior to vote).. Valid values are `approved|rejected|deferred|conditional_approval|withdrawn`',
    `phase_from` STRING COMMENT 'The clinical development phase the program was in at the time of the decision (the originating phase). Relevant for phase transition decisions. [ENUM-REF-CANDIDATE',
    `phase_to` STRING COMMENT 'The target clinical development phase the program is transitioning into as a result of this decision. Null if the decision is not a phase transition. [ENUM-REF-CANDIDATE',
    `rationale` STRING COMMENT 'Rationale and justification for the decision, including supporting evidence and reasoning.',
    `regulatory_agency_consulted` STRING COMMENT 'Name(s) of regulatory agencies (e.g., FDA, EMA, PMDA, MHRA) that were formally consulted (e.g., via Type B meeting, scientific advice) prior to or as part of this decision. Supports regulatory strategy documentation.',
    `regulatory_submission_impact` STRING COMMENT 'Indicates the regulatory submission consequence of this decision (e.g., requires IND amendment, impacts NDA/BLA filing strategy, triggers MAA update, requires eCTD update, or no regulatory submission impact).',
    `review_due_date` DATE COMMENT 'Date by which a deferred or conditional decision must be reviewed or re-evaluated based on new data or milestone achievement. Supports governance calendar management and escalation tracking.',
    `risk_assessment_summary` STRING COMMENT 'Summary of the risk assessment that informed this decision, including identified risks and mitigation strategies.',
    `safety_signal_flag` BOOLEAN COMMENT 'Indicates whether a safety signal, serious adverse event (SAE), or suspected unexpected serious adverse reaction (SUSAR) was a contributing factor in this decision. True if safety data influenced the decision outcome.',
    `source_record_reference` STRING COMMENT 'The native record identifier from the originating operational system (e.g., Veeva Vault document ID, the source system record ID). Enables bidirectional traceability between the lakehouse Silver layer and the system of record.',
    `sponsor_concurrence_date` DATE COMMENT 'Date on which the sponsor formally concurred with or ratified this program decision. Null if sponsor_concurrence_flag is False or not applicable.',
    `sponsor_concurrence_flag` BOOLEAN COMMENT 'Indicates whether the pharmaceutical or biotech sponsor formally concurred with this program decision. True if sponsor sign-off was obtained. Relevant for CRO-managed programs where sponsor approval is a governance requirement.',
    `decision_status` STRING COMMENT 'Current lifecycle state of the decision record within the governance workflow: draft (being prepared), pending_review (submitted for ratification), ratified (formally approved and binding), superseded (replaced by a subsequent decision), or voided. Valid values are `draft|pending_review|ratified|superseded|voided`',
    `supporting_data_summary` STRING COMMENT 'Summary of the supporting data and evidence that informed this decision.',
    `therapeutic_area` STRING COMMENT 'The therapeutic area or disease indication relevant to this decision (e.g., Oncology, Cardiovascular, Neurology, Immunology). Enables portfolio-level analytics by therapeutic domain.',
    `title` STRING COMMENT 'Short, human-readable title summarizing the decision (e.g., Phase II Go Decision for PROG-001 in Oncology). Used in governance dashboards, TMF indexing, and regulatory dossier tables of contents.',
    `decision_type` STRING COMMENT 'Classification of the strategic decision category. Captures the nature of the governance action: go/no-go milestone, phase transition approval (e.g., Phase I to Phase II), indication expansion, program termination, regulatory strategy pivot, or portfolio. Valid values are `go_no_go|phase_transition|indication_expansion|program_termination|regulatory_strategy_pivot|portfolio_investment`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this program decision record. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    CONSTRAINT pk_decision PRIMARY KEY(`decision_id`)
) COMMENT 'Transactional record capturing formal go/no-go and key strategic decisions made at the program level, including portfolio investment decisions, phase transition approvals, and program termination decisions.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`program`.`timeline` (
    `timeline_id` BIGINT COMMENT 'Unique surrogate identifier for the program-level integrated timeline record. Primary key for this entity.',
    `clinical_program_id` BIGINT COMMENT 'Reference to the clinical development program this timeline governs. Links the timeline to its parent program entity.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization funding and overseeing the clinical development program. Links to the sponsor master record.',
    `owner_employee_id` BIGINT COMMENT 'FK to workforce.employee',
    `primary_timeline_employee_id` BIGINT COMMENT 'Reference to the individual (typically a Program Director or Program Manager) accountable for maintaining and updating the program timeline. Supports governance accountability and escalation routing.',
    `superseded_timeline_id` BIGINT COMMENT 'Self-referencing FK on timeline (superseded_timeline_id)',
    `approval_date` DATE COMMENT 'The date on which this version of the program timeline was formally approved by the program governance committee or sponsor. Marks the transition from draft to baseline.',
    `approved_by` STRING COMMENT 'Name or identifier of the governance authority (individual or committee) that formally approved this program timeline version, supporting audit trail and regulatory inspection readiness.',
    `baseline_end_date` DATE COMMENT 'The approved baseline end date for the clinical development program, representing the originally planned program completion date. Used as the denominator for schedule variance and milestone tracking.',
    `baseline_start_date` DATE COMMENT 'The approved baseline start date for the clinical development program, established at the time of initial timeline approval. Serves as the reference anchor for schedule variance calculations.',
    `timeline_code` STRING COMMENT 'Externally-known alphanumeric business identifier for this program timeline record, used in CTMS, eTMF, and sponsor communications to uniquely reference the schedule baseline.',
    `comments` STRING COMMENT 'Free-text field for additional context, notes, or clarifications regarding the program timeline status, assumptions, or constraints not captured in structured fields. Supports governance review documentation.',
    `created_timestamp` TIMESTAMP COMMENT 'The system timestamp when this program timeline record was first created in the data platform. Supports audit trail, data lineage, and ALCOA+ compliance requirements.',
    `critical_path_driver` STRING COMMENT 'The primary activity, milestone, or dependency currently driving the critical path (e.g., Last Patient Last Visit, Regulatory Submission, Database Lock). Used for targeted risk mitigation and escalation.',
    `critical_path_summary` STRING COMMENT 'Narrative or structured summary identifying the critical path activities and milestones that determine the programs minimum duration. Highlights the sequence of dependent tasks with zero float that drive the forecast end date.',
    `csr_target_date` DATE COMMENT 'The target date for completion of the Clinical Study Report (CSR) for the programs pivotal study or integrated summary. Required for regulatory submission planning per ICH E3 guidelines.',
    `forecast_end_date` DATE COMMENT 'The current forecast completion date for the program, updated based on rolling re-projections from study-level timelines, enrollment rates, and regulatory milestones. Key input to portfolio governance and submission planning.',
    `forecast_start_date` DATE COMMENT 'The current forecast start date for the program, reflecting the latest re-planning based on actual progress, site performance, and enrollment data. May differ from baseline if program initiation was delayed.',
    `governance_review_frequency` STRING COMMENT 'The cadence at which this program timeline is reviewed by the program governance committee or sponsor. Determines the expected update frequency for forecast dates and status fields.. Valid values are `weekly|bi-weekly|monthly|quarterly`',
    `indication` STRING COMMENT 'The specific disease or condition being studied within the program (e.g., Non-Small Cell Lung Cancer, Type 2 Diabetes Mellitus). Aligns with MedDRA coding and regulatory submission labeling.',
    `is_current_version` BOOLEAN COMMENT 'Boolean flag indicating whether this record represents the currently active and operative program timeline version. Exactly one record per program should have this set to True at any point in time.',
    `last_updated_date` DATE COMMENT 'The calendar date on which the program timeline record was most recently updated, reflecting the latest forecast refresh or status change. Used for data currency monitoring in portfolio dashboards.',
    `milestone_count_at_risk` BIGINT COMMENT 'Number of program-level milestones currently flagged as at-risk of missing their forecast date. Key input to program risk dashboards and DSMB/DMC reporting.',
    `milestone_count_completed` BIGINT COMMENT 'Number of program-level milestones that have been achieved as of the last timeline update. Used to calculate program completion percentage and track progress against the baseline.',
    `milestone_count_total` BIGINT COMMENT 'Total number of program-level milestones tracked within this timeline version. Provides a structural summary of timeline complexity for governance reporting.',
    `timeline_name` STRING COMMENT 'Human-readable descriptive name for the program timeline (e.g., Phase II/III Integrated Development Timeline v2), used in governance reports and portfolio dashboards.',
    `next_governance_review_date` DATE COMMENT 'The scheduled date of the next program governance committee review at which this timeline will be assessed and potentially updated. Drives workflow notifications and reporting preparation.',
    `program_phase` STRING COMMENT 'The clinical development phase(s) covered by this program timeline (e.g., Phase II/III). Determines regulatory requirements, timeline complexity, and governance oversight level.. Valid values are `Phase I|Phase II|Phase III|Phase IV|Phase I/II|Phase II/III`',
    `regulatory_submission_target_date` DATE COMMENT 'The target date for the primary regulatory submission (NDA/BLA/MAA) derived from this program timeline. Critical milestone for sponsor portfolio planning and regulatory agency interactions.',
    `revision_reason` STRING COMMENT 'Narrative explanation for why this timeline version was created or revised (e.g., Protocol amendment impact, Enrollment rate below target, Regulatory feedback on IND). Required for governance accountability.',
    `risk_level` STRING COMMENT 'Overall risk classification for the program timeline, reflecting the likelihood and impact of schedule delays based on current program status, enrollment performance, and regulatory interactions.. Valid values are `low|medium|high|critical`',
    `risk_summary` STRING COMMENT 'Narrative summary of the primary schedule risks and mitigation strategies for the program timeline, as assessed at the last governance review. Supports DSMB/DMC reporting and sponsor escalation.',
    `schedule_variance_days` BIGINT COMMENT 'The numeric difference in calendar days between the current forecast end date and the approved baseline end date. Positive values indicate delay; negative values indicate ahead-of-schedule performance. Core KPI for program governance.',
    `source_system_record_reference` STRING COMMENT 'The native identifier of this timeline record in the originating operational system (e.g., the source system internal ID). Enables traceability and reconciliation between the lakehouse and source systems.',
    `timeline_status` STRING COMMENT 'Current schedule health status of the program timeline, indicating whether the program is on-track, at-risk of delay, actively delayed, completed, or cancelled. Used in portfolio governance reporting and escalation workflows.. Valid values are `on-track|at-risk|delayed|completed|cancelled`',
    `study_count` BIGINT COMMENT 'Number of individual clinical studies (trials) included within this program timeline. Reflects the scope of the integrated development program.',
    `therapeutic_area` STRING COMMENT 'The therapeutic area or disease indication that the clinical development program targets (e.g., Oncology, Cardiology, Neurology). Used for portfolio segmentation and resource allocation.',
    `timeline_type` STRING COMMENT 'Classification of the timeline record indicating whether it represents the approved baseline, current forecast, a scenario plan, or an archived historical version.. Valid values are `baseline|forecast|scenario|approved|archived`',
    `updated_timestamp` TIMESTAMP COMMENT 'The system timestamp when this program timeline record was most recently modified. Enables change detection, incremental processing, and audit trail maintenance per ALCOA+ principles.',
    `version` STRING COMMENT 'Version identifier for this timeline record (e.g., v1.0, v2.3), enabling tracking of successive baseline revisions and forecast updates over the program lifecycle.. Valid values are `^vd+.d+$`',
    `version_effective_date` DATE COMMENT 'The date from which this timeline version became the operative schedule for the program. Enables point-in-time reconstruction of the program schedule for regulatory submissions and audits.',
    `version_superseded_date` DATE COMMENT 'The date on which this timeline version was superseded by a newer version. Null for the currently active version. Supports historical timeline reconstruction and version chain integrity.',
    CONSTRAINT pk_timeline PRIMARY KEY(`timeline_id`)
) COMMENT 'Master record for the integrated program-level timeline, capturing the overall schedule baseline and current forecast for a clinical development program. Captures timeline version, baseline start date, baseline end date, current forecast start date';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`program`.`timeline_event` (
    `timeline_event_id` BIGINT COMMENT 'Unique surrogate identifier for each timeline event record within a clinical development program. Primary key for the timeline_event data product.',
    `clinical_program_id` BIGINT COMMENT 'Reference to the clinical development program to which this timeline event belongs. Links the event to its parent program for portfolio-level schedule tracking.',
    `interim_analysis_id` BIGINT COMMENT 'Foreign key linking to biostatistics.interim_analysis. Business justification: Interim analyses are explicitly scheduled as critical-path timeline events in program planning (data cut date, IA results readout).',
    `primary_predecessor_event_timeline_event_id` BIGINT COMMENT 'Self-referencing identifier of the immediately preceding timeline event that must be completed before this event can begin. Supports critical path management and dependency chain analysis.',
    `program_development_milestone_id` BIGINT COMMENT 'Foreign key linking to program.program_milestone. Business justification: timeline_event has a milestone_flag (BOOLEAN) indicating when an event corresponds to a formal program milestone.',
    `study_id` BIGINT COMMENT 'Reference to the specific clinical study associated with this timeline event, where the event is study-scoped rather than program-wide. Nullable for program-level events not tied to a single study.',
    `timeline_id` BIGINT COMMENT 'Foreign key linking to program.program_timeline. Business justification: timeline_event is a transactional child record representing individual scheduled events within a program timeline.',
    `acceptance_criteria` STRING COMMENT 'Defined criteria that must be met for this timeline event to be formally marked as completed. Ensures objective, auditable completion standards aligned with GCP and sponsor requirements.',
    `actual_date` DATE COMMENT 'The confirmed date on which this timeline event was completed or occurred. Populated only upon event completion. Used to calculate schedule variance against the planned baseline.',
    `approved_by` STRING COMMENT 'Name or identifier of the program governance authority who approved this timeline event. Supports electronic signature audit trail requirements under 21 CFR Part 11.',
    `approved_date` DATE COMMENT 'The date on which this timeline event was formally approved by the program governance board. Populated when approved_flag is True. Supports audit trail and compliance documentation.',
    `approved_flag` BOOLEAN COMMENT 'Indicates whether this timeline event and its associated dates have been formally approved by the program governance board (True) or are still pending approval (False). Supports governance workflow controls.',
    `baseline_date` DATE COMMENT 'The date on which the current schedule baseline version was approved and locked. Used to track re-baselining history and assess cumulative schedule drift across program lifecycle.',
    `baseline_version` STRING COMMENT 'The version identifier of the program schedule baseline against which this events planned date is measured (e.g., BL-01, BL-02). Supports baseline comparison and re-baselining audit trails.. Valid values are `^BL-[0-9]{2}$`',
    `comments` STRING COMMENT 'Free-text field for program team notes, status updates, or contextual remarks related to this timeline event. Supports program review discussions and audit trail documentation.',
    `completion_percentage` DECIMAL(5,2) COMMENT 'The estimated percentage of work completed for this timeline event, expressed as a value between 0.00 and 100.00. Updated during program review cycles to reflect in-progress event progress.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this timeline event record was first created in the system. Supports audit trail, data lineage, and ALCOA+ compliance requirements.',
    `critical_path_flag` BOOLEAN COMMENT 'Indicates whether this event lies on the critical path of the program schedule (True). Critical path events directly impact the overall program completion date and receive heightened monitoring priority.',
    `delay_reason_code` STRING COMMENT 'Standardized code categorizing the root cause of a schedule delay when schedule_variance_days is positive. Supports CAPA tracking and program risk reporting.',
    `delay_reason_description` STRING COMMENT 'Free-text narrative providing additional context for the delay reason code, capturing specific circumstances contributing to the schedule variance. Supports root cause analysis and lessons learned.',
    `dependency_type` STRING COMMENT 'The logical dependency relationship between this event and its predecessor event, following standard project scheduling conventions (Finish-to-Start, Start-to-Start, Finish-to-Finish, Start-to-Finish). Used in critical path network construction.. Valid values are `finish_to_start|start_to_start|finish_to_finish|start_to_finish`',
    `duration_days` BIGINT COMMENT 'The planned number of calendar days allocated for the completion of this timeline event, from start to finish. Used in resource planning and Gantt chart construction.',
    `early_start_date` DATE COMMENT 'The earliest possible date this event can begin based on predecessor completion and resource availability, as calculated in the critical path network. Used for schedule optimization and float analysis.',
    `event_category` STRING COMMENT 'High-level functional category grouping the event for portfolio analytics and cross-domain reporting. Enables filtering by clinical, regulatory, safety, biostatistics, data management, or operational workstreams.. Valid values are `clinical|regulatory|safety|biostatistics|data_management|operational`',
    `event_code` STRING COMMENT 'Externally-known alphanumeric business identifier for the timeline event, used in program plans, Gantt charts, and regulatory submissions. Follows the EVT- prefix convention in the source system. Valid values are `^EVT-[A-Z0-9]{3,20}$`',
    `event_description` STRING COMMENT 'Detailed narrative description of the timeline event, including scope, acceptance criteria, and any special conditions. Provides context for program team members and governance reviewers.',
    `event_name` STRING COMMENT 'Human-readable name of the timeline event (e.g., First Patient First Visit, Database Lock, NDA Submission, Advisory Committee Meeting). Used in program dashboards and milestone reports.',
    `event_status` STRING COMMENT 'Current workflow state of the timeline event reflecting its execution progress. Drives program schedule performance dashboards and escalation workflows. Values: planned, in_progress, completed, delayed, cancelled.. Valid values are `planned|in_progress|completed|delayed|cancelled`',
    `event_type` STRING COMMENT 'Categorical classification of the timeline event indicating its business nature. Drives reporting groupings and critical path logic. Values: study_start, database_lock, regulatory_submission, advisory_committee_meeting, approval_decision, program_review.. Valid values are `study_start|database_lock|regulatory_submission|advisory_committee_meeting|approval_decision|program_review`',
    `float_days` BIGINT COMMENT 'The number of calendar days by which this event can be delayed without impacting the program critical path. Zero float indicates a critical path event. Supports proactive schedule risk management.',
    `forecast_date` DATE COMMENT 'The current best-estimate date on which this timeline event is expected to occur, updated as program conditions evolve. Reflects the most recent schedule projection used in program review meetings.',
    `lag_days` BIGINT COMMENT 'The number of calendar days of lag or lead time applied to the dependency relationship with the predecessor event. Positive values indicate a waiting period after predecessor completion; negative values indicate overlap.',
    `late_finish_date` DATE COMMENT 'The latest date by which this event must be completed without delaying the overall program end date. Used in critical path analysis to determine schedule float and prioritize risk mitigation.',
    `milestone_flag` BOOLEAN COMMENT 'Indicates whether this timeline event is designated as a key program milestone (True) versus a routine scheduled deliverable (False). Milestone events are tracked at the executive and sponsor governance level.',
    `owner_name` STRING COMMENT 'Name of the individual or team lead responsible for ensuring this timeline event is completed on schedule. Used in program status reports and escalation communications.',
    `planned_date` DATE COMMENT 'The originally baselined date on which this timeline event was scheduled to occur, as defined in the approved program plan. Serves as the baseline reference for schedule variance calculations.',
    `priority` STRING COMMENT 'Business priority assigned to this timeline event reflecting its strategic importance to the program. Used to triage resource allocation and escalation decisions during program reviews.. Valid values are `low|medium|high|critical`',
    `regulatory_agency` STRING COMMENT 'The regulatory authority to which a submission or approval decision event is directed (e.g., FDA, EMA, PMDA, MHRA, TGA, Health Canada). Nullable for non-regulatory events.',
    `regulatory_submission_type` STRING COMMENT 'For events of type regulatory_submission, specifies the submission dossier type (e.g., IND, NDA, BLA, MAA, eCTD). Nullable for non-regulatory event types. Aligns with FDA, EMA, PMDA submission classifications.',
    `responsible_role` STRING COMMENT 'The functional role or organizational unit accountable for delivering this timeline event (e.g., Clinical Operations, Biostatistics, Regulatory Affairs, Data Management). Used for workload planning and accountability tracking.',
    `risk_level` STRING COMMENT 'Assessed risk level for this timeline event based on schedule sensitivity, predecessor dependencies, and program impact. Drives escalation thresholds and program governance reporting.. Valid values are `low|medium|high|critical`',
    `schedule_variance_days` BIGINT COMMENT 'The difference in calendar days between the actual (or forecast) date and the planned baseline date. Positive values indicate delay; negative values indicate early completion. Key KPI for program schedule performance reporting.',
    `source_event_reference` STRING COMMENT 'The native identifier of this timeline event in the originating operational system (e.g., Siebel CTMS milestone ID, the source system event ID). Enables traceability back to the system of record.',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time when this timeline event record was most recently modified. Supports change tracking, audit trail, and data currency validation in the Silver Layer lakehouse.',
    CONSTRAINT pk_timeline_event PRIMARY KEY(`timeline_event_id`)
) COMMENT 'Transactional record for individual scheduled events and deliverables within a program timeline. Captures event name, event type (study start, database lock, regulatory submission, advisory committee meeting, approval decision, program review), planned';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`program`.`risk` (
    `risk_id` BIGINT COMMENT 'Unique surrogate identifier for the program-level risk record within the clinical development program risk register.',
    `clinical_program_id` BIGINT COMMENT 'Reference to the clinical development program to which this risk belongs, enabling portfolio-level risk aggregation and governance reporting.',
    `owner_employee_id` BIGINT COMMENT 'FK to workforce.employee',
    `parent_risk_id` BIGINT COMMENT 'Self-referencing FK on risk (parent_risk_id)',
    `primary_risk_employee_id` BIGINT COMMENT 'Reference to the workforce member (typically a Program Director, Clinical Lead, or Regulatory Affairs Lead) accountable for monitoring and managing this risk to resolution. Aligns with RACI accountability frameworks in GCP-compliant program governance.',
    `actual_resolution_date` DATE COMMENT 'Date on which the risk was actually resolved (mitigated, closed, or accepted). Null if the risk remains open. Used for cycle time analysis and governance performance reporting.',
    `affected_studies` STRING COMMENT 'Comma-separated list of study protocol numbers or identifiers within the program that are impacted by this risk. Supports cross-study impact analysis and portfolio governance reporting.',
    `capa_reference` STRING COMMENT 'Reference identifier of any associated CAPA record in MasterControl or the quality management system, linking this risk to formal corrective and preventive action processes where applicable.',
    `risk_category` STRING COMMENT 'High-level classification of the risk domain: scientific (e.g., efficacy uncertainty), regulatory (e.g., IND/NDA/BLA/MAA submission risk), operational (e.g., site activation delays), competitive (e.g., competitor trial results), financial (e.g., budget. Valid values are `scientific|regulatory|operational|competitive|financial|safety`',
    `comments` STRING COMMENT 'Free-text field for additional context, reviewer notes, governance meeting minutes excerpts, or supplementary information related to the risk that does not fit structured fields. Supports audit trail completeness per ALCOA+ principles.',
    `contingency_plan` STRING COMMENT 'Documented fallback actions to be executed if the risk materializes despite mitigation efforts (e.g., If IND placed on clinical hold, initiate Type B meeting with FDA within 30 days). Supports business continuity and regulatory response planning.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this risk record was first created in the system, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Supports audit trail, ALCOA+ compliance, and 21 CFR Part 11 electronic record requirements.',
    `risk_description` STRING COMMENT 'Detailed narrative describing the nature of the risk, its potential cause, and the business context in which it was identified. Supports risk review meetings, DSMB/DMC briefings, and regulatory submissions.',
    `escalation_date` DATE COMMENT 'Date on which the risk was formally escalated to a higher governance level (e.g., program steering committee, sponsor, DSMB/DMC). Null if escalation has not occurred.',
    `escalation_required` BOOLEAN COMMENT 'Indicates whether this risk requires escalation to program leadership, the sponsor, DSMB/DMC, or a regulatory authority based on its risk score or category. Drives governance workflow routing.',
    `escalation_target` STRING COMMENT 'The governance body or individual to whom the risk has been escalated (e.g., Program Steering Committee, Sponsor Medical Monitor, DSMB, FDA). Supports audit trail and governance accountability.',
    `financial_exposure_usd` DECIMAL(18,2) COMMENT 'Estimated financial exposure or potential cost impact if the risk materializes, expressed in US dollars. Used for financial risk quantification, budget contingency planning, and sponsor reporting. Classified as confidential due to commercial sensitivity.',
    `identified_date` DATE COMMENT 'Calendar date on which the risk was first formally identified and entered into the program risk register. Supports risk aging analysis and regulatory audit trails per ALCOA+ principles.',
    `identifier` STRING COMMENT 'Human-readable, externally-known unique code assigned to this risk record within the program risk register (e.g., PRSK-ONC-000123). Used in governance reports, DSMB/DMC submissions, and sponsor communications.. Valid values are `^PRSK-[A-Z0-9]{3,10}-[0-9]{4,6}$`',
    `impact_rating` STRING COMMENT 'Qualitative assessment of the severity of consequences if the risk materializes, considering impact on program timeline, patient safety, regulatory approval, and financial outcomes.. Valid values are `very_low|low|medium|high|very_high`',
    `impact_score` BIGINT COMMENT 'Numeric value corresponding to the impact rating (e.g., 1=very low, 2=low, 3=medium, 4=high, 5=very high). Combined with probability_score to compute the composite risk score.',
    `last_review_date` DATE COMMENT 'Date on which the risk was most recently reviewed and assessed by the risk owner or program governance committee. Supports overdue review identification and governance compliance tracking.',
    `mitigation_status` STRING COMMENT 'Current implementation status of the mitigation strategy: not_started, in_progress, completed, or on_hold. Enables tracking of mitigation execution progress separate from the overall risk status.. Valid values are `not_started|in_progress|completed|on_hold`',
    `mitigation_strategy` STRING COMMENT 'Detailed description of the planned or implemented actions to reduce the probability or impact of the risk (e.g., Engage additional regulatory consultant for IND submission review, Activate backup sites to offset enrollment shortfall).',
    `next_review_date` DATE COMMENT 'Planned date for the next formal review of this risk. Drives automated review reminders and governance calendar scheduling. Frequency is typically determined by risk priority (e.g., critical risks reviewed monthly).',
    `patient_safety_impact_flag` BOOLEAN COMMENT 'Indicates whether this risk has a direct or potential impact on patient safety, including SAE/SUSAR reporting obligations, DSMB/DMC review triggers, or clinical hold risk. Ensures safety risks receive mandatory expedited review.',
    `priority` STRING COMMENT 'Derived priority classification based on the risk score (e.g., critical: score 20–25, high: 12–19, medium: 6–11, low: 1–5). Used to drive escalation workflows, governance review frequency, and resource allocation decisions.. Valid values are `critical|high|medium|low`',
    `probability_rating` STRING COMMENT 'Qualitative likelihood rating that the risk event will materialize during the program lifecycle. Typically assessed on a 5-point scale (very low to very high) per the programs risk management framework. Used in risk scoring and prioritization.. Valid values are `very_low|low|medium|high|very_high`',
    `probability_score` BIGINT COMMENT 'Numeric value corresponding to the probability rating (e.g., 1=very low, 2=low, 3=medium, 4=high, 5=very high). Used in quantitative risk score calculation and portfolio-level risk heat map generation.',
    `regulatory_impact_flag` BOOLEAN COMMENT 'Indicates whether this risk has a direct potential impact on regulatory submissions (IND, NDA, BLA, MAA, eCTD) or regulatory agency interactions (FDA, EMA, PMDA, MHRA, TGA, Health Canada). Drives regulatory affairs team notification workflows.',
    `residual_impact_rating` STRING COMMENT 'Reassessed impact rating after mitigation controls have been applied. Used alongside residual_probability_rating to compute the residual risk score and confirm risk acceptability.. Valid values are `very_low|low|medium|high|very_high`',
    `residual_probability_rating` STRING COMMENT 'Reassessed probability rating after mitigation controls have been applied. Compared against the initial probability_rating to demonstrate risk reduction effectiveness.. Valid values are `very_low|low|medium|high|very_high`',
    `residual_risk_score` BIGINT COMMENT 'Composite risk score after mitigation (residual probability score × residual impact score). Compared to the pre-mitigation risk_score to quantify risk reduction and determine if the residual risk is within acceptable tolerance.',
    `score` BIGINT COMMENT 'Composite numeric risk score, typically calculated as probability_score × impact_score (range 1–25 on a 5×5 matrix). Drives risk prioritization, escalation thresholds, and portfolio risk heat map reporting.',
    `source_record_reference` STRING COMMENT 'Identifier of the corresponding record in the originating source system (e.g., CTMS risk ID, Veeva Vault document ID, MasterControl CAPA ID). Supports data lineage tracing and reconciliation between the lakehouse and operational systems.',
    `risk_status` STRING COMMENT 'Current lifecycle state of the risk record: open (active and unresolved), mitigated (controls applied and risk reduced), closed (risk no longer applicable or resolved), accepted (risk acknowledged and formally accepted by program leadership without. Valid values are `open|mitigated|closed|accepted`',
    `subcategory` STRING COMMENT 'More granular classification within the risk category (e.g., within regulatory: IND, NDA, BLA, MAA, PMDA, EMA; within safety: SAE signal, SUSAR reporting, DSMB review). Supports detailed risk analytics and reporting.',
    `target_resolution_date` DATE COMMENT 'Target date by which the risk is expected to be mitigated, closed, or formally accepted. Used for milestone tracking and program governance reporting.',
    `timeline_impact_days` BIGINT COMMENT 'Estimated number of calendar days by which the program or study timeline could be delayed if this risk materializes. Used for critical path analysis, milestone risk assessment, and sponsor portfolio reporting.',
    `title` STRING COMMENT 'Short, human-readable label summarizing the risk (e.g., Delayed IND approval due to CMC data gaps). Used as the primary display name in risk dashboards and portfolio governance reports.',
    `tolerance_threshold` BIGINT COMMENT 'Maximum acceptable risk score defined by the program governance framework. Risks with residual_risk_score exceeding this threshold require escalation to senior leadership or the sponsor. Supports risk acceptance decision-making.',
    `trigger_criteria` STRING COMMENT 'Defined conditions or early warning indicators that signal the risk is materializing or escalating (e.g., Enrollment rate falls below 60% of target for two consecutive months). Supports proactive risk monitoring and automated alerting.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this risk record, in ISO 8601 format. Supports change tracking, audit trail completeness, and incremental data pipeline processing in the Databricks Silver layer.',
    CONSTRAINT pk_risk PRIMARY KEY(`risk_id`)
) COMMENT 'Master record for program-level risks identified through risk management processes. Captures risk identifier, risk category (scientific, regulatory, operational, competitive, financial, safety), risk description, probability rating, impact rating, risk';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` (
    `risk_mitigation_id` BIGINT COMMENT 'Unique surrogate identifier for each risk mitigation action record within the program risk management framework. Primary key for this entity. Role: TRANSACTION_HEADER.',
    `clinical_program_id` BIGINT COMMENT 'Reference to the clinical development program to which this mitigation action belongs. Links the mitigation action to the overarching program risk management framework.',
    `compliance_capa_id` BIGINT COMMENT 'Reference to an associated CAPA record in the quality management system (MasterControl) when this mitigation action is formally linked to a CAPA. Enables traceability between risk mitigation and quality event management.',
    `escalated_risk_mitigation_id` BIGINT COMMENT 'Self-referencing FK on risk_mitigation (escalated_risk_mitigation_id)',
    `primary_risk_employee_id` BIGINT COMMENT 'Reference to the individual (employee or contractor) accountable for executing and completing this mitigation action. Serves as the PARTY_REFERENCE category for this TRANSACTION_HEADER entity. Typically a Program Manager, Risk Manager, or functional lead.',
    `protocol_deviation_id` BIGINT COMMENT 'Reference to a protocol deviation record that triggered or is associated with this mitigation action. Supports traceability between compliance events and risk response actions.',
    `risk_id` BIGINT COMMENT 'Reference to the parent program-level risk record that this mitigation action is designed to address. Establishes the parent-child relationship between a risk and its mitigation actions.',
    `tertiary_risk_effectiveness_reviewer_employee_id` BIGINT COMMENT 'Reference to the individual who conducted the formal effectiveness review of this mitigation action. Typically a QA lead, Program Manager, or independent reviewer per GCP requirements.',
    `action_description` STRING COMMENT 'Detailed narrative describing the specific mitigation action to be taken, including the approach, scope, and expected mechanism by which the action reduces the identified risk.',
    `action_owner_role` STRING COMMENT 'Functional role or job title of the mitigation action owner at the time of assignment (e.g., Program Manager, Clinical Operations Lead, Biostatistics Lead). Supports accountability reporting and escalation routing.',
    `action_status` STRING COMMENT 'Current execution lifecycle state of the mitigation action. Drives risk dashboard reporting and escalation workflows. overdue is set when planned_completion_date has passed without completion.. Valid values are `planned|in_progress|completed|overdue|cancelled|on_hold`',
    `action_title` STRING COMMENT 'Short, human-readable title summarizing the mitigation action (e.g., Implement enhanced site monitoring protocol). Used as the IDENTITY_LABEL in risk registers and dashboards.',
    `action_type` STRING COMMENT 'Classification of the mitigation action by its strategic intent: preventive (reduces likelihood), corrective (addresses root cause after occurrence), contingency (response plan if risk materializes), transfer (shifts risk to another party), or acceptance. Valid values are `preventive|corrective|contingency|transfer|acceptance`',
    `actual_completion_date` DATE COMMENT 'The date on which the mitigation action was fully executed and confirmed complete. Null if the action has not yet been completed. Used to calculate cycle time and assess timeliness of risk response.',
    `actual_start_date` DATE COMMENT 'The date on which execution of the mitigation action actually commenced. Compared against planned_start_date to assess schedule adherence and identify systemic delays in risk response.',
    `closure_justification` STRING COMMENT 'Narrative justification for formally closing this mitigation action, documenting the evidence that the action was completed, verified, and the residual risk accepted. Required for regulatory inspection readiness and TMF documentation.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this mitigation action record was first created in the system. Serves as the RECORD_AUDIT_CREATED category for this TRANSACTION_HEADER entity. Required for 21 CFR Part 11 audit trail compliance.',
    `data_integrity_impact_flag` BOOLEAN COMMENT 'Indicates whether the risk being mitigated has a direct or potential impact on clinical data integrity (ALCOA+ principles). True = data integrity is implicated; False = no direct data integrity impact. Relevant for EDC and CDISC compliance.',
    `due_date_revised` DATE COMMENT 'Updated target completion date if the original planned_completion_date was formally extended. Captures approved timeline changes and distinguishes legitimate extensions from overdue actions.',
    `effectiveness_notes` STRING COMMENT 'Free-text narrative from the effectiveness reviewer documenting the rationale for the effectiveness rating, evidence reviewed, and any observations about residual risk or further actions needed.',
    `effectiveness_rating` STRING COMMENT 'Post-execution assessment of how effectively the mitigation action reduced or eliminated the identified risk. Populated after action completion and formal effectiveness review. Drives decisions on whether additional mitigation is required.. Valid values are `highly_effective|effective|partially_effective|ineffective|not_assessed`',
    `effectiveness_review_date` DATE COMMENT 'The date on which the formal effectiveness assessment of the completed mitigation action was conducted. Required for CAPA closure and regulatory inspection readiness.',
    `implementation_approach` STRING COMMENT 'Narrative description of the specific method, process, or procedure to be used in executing the mitigation action. May reference SOPs, work instructions, or system configurations (e.g., EDC edit checks, RTSM alerts).',
    `last_updated_timestamp` TIMESTAMP COMMENT 'The date and time when this mitigation action record was most recently modified. Serves as the RECORD_AUDIT_UPDATED category for this TRANSACTION_HEADER entity. Required for 21 CFR Part 11 audit trail compliance.',
    `linked_milestone` STRING COMMENT 'Name or code of the program milestone (e.g., First Patient In, Database Lock, NDA Submission) to which this mitigation action is tied. Enables milestone-level risk tracking and critical path analysis.',
    `mitigation_action_code` STRING COMMENT 'Externally-known business identifier for the mitigation action, used in risk registers, audit trails, and regulatory submissions. Follows the pattern MIT-<PROGRAM_CODE>-<SEQUENCE>.. Valid values are `^MIT-[A-Z0-9]{3,10}-[0-9]{4,8}$`',
    `mitigation_strategy` STRING COMMENT 'High-level strategic approach applied to manage the risk, aligned with ICH Q9 risk management principles. Distinguishes the overarching strategy from the specific action_type.. Valid values are `risk_reduction|risk_avoidance|risk_transfer|risk_acceptance|contingency_planning`',
    `planned_completion_date` DATE COMMENT 'The target date by which the mitigation action is expected to be fully executed and closed. Used to calculate overdue status and drive risk dashboard KPI reporting. Serves as the BUSINESS_EVENT_TIMESTAMP (date-precision) for this entity.',
    `planned_start_date` DATE COMMENT 'The date on which execution of the mitigation action is planned to begin. Used for timeline planning, Gantt chart generation, and milestone tracking within the program risk management plan.',
    `priority_level` STRING COMMENT 'Business priority assigned to this mitigation action, reflecting the urgency of execution relative to the risk severity and program timeline. Drives resource allocation and escalation thresholds.. Valid values are `critical|high|medium|low`',
    `recurrence_prevention_notes` STRING COMMENT 'Free-text notes describing measures put in place to prevent recurrence of the risk after mitigation. Supports lessons-learned capture and cross-program knowledge transfer within the clinical development portfolio.',
    `regulatory_impact_flag` BOOLEAN COMMENT 'Indicates whether this mitigation action has direct implications for regulatory submissions (IND, NDA, BLA, MAA) or regulatory agency notifications. True = regulatory impact identified; False = no direct regulatory impact.',
    `residual_risk_acceptance_date` DATE COMMENT 'The date on which the residual risk was formally accepted by the authorized governance body. Null if residual risk has not yet been accepted or if further mitigation is required.',
    `residual_risk_accepted` BOOLEAN COMMENT 'Indicates whether the residual risk level after mitigation has been formally accepted by the program risk governance body (e.g., DSMB, DMC, or Sponsor). True = accepted; False = further mitigation required.',
    `residual_risk_level` STRING COMMENT 'The assessed level of risk remaining after the mitigation action has been fully implemented and its effectiveness confirmed. Used to determine whether the residual risk is acceptable or requires further mitigation per the program risk acceptance criteria.. Valid values are `critical|high|medium|low|negligible`',
    `responsible_function` STRING COMMENT 'The organizational function or department accountable for executing this mitigation action (e.g., Clinical Operations, Data Management, Pharmacovigilance, Regulatory Affairs, Biostatistics). Supports cross-functional risk governance reporting.',
    `risk_domain` STRING COMMENT 'The functional domain of the parent risk that this mitigation action addresses. Enables domain-specific risk reporting and cross-program benchmarking. [ENUM-REF-CANDIDATE',
    `subject_safety_impact_flag` BOOLEAN COMMENT 'Indicates whether the risk being mitigated has a direct or potential impact on subject safety. True = subject safety is implicated; False = no direct subject safety impact. Drives prioritization and DSMB/DMC notification requirements.',
    `supporting_systems` STRING COMMENT 'Comma-separated list of operational systems involved in executing or monitoring this mitigation action (e.g., Medidata Rave, the source system Veeva Vault). Supports system-level impact analysis and integration planning.',
    `verification_date` DATE COMMENT 'The date on which implementation of the mitigation action was formally verified as complete and effective. Distinct from actual_completion_date (when the action was done) and effectiveness_review_date (when effectiveness was assessed).',
    `verification_method` STRING COMMENT 'Description of the method used to verify that the mitigation action has been implemented as planned (e.g., site visit, SDV, EDC audit trail review, document review in Veeva Vault, monitoring report review). Supports GCP audit readiness.',
    `version_number` BIGINT COMMENT 'Incrementing version counter for this mitigation action record, supporting optimistic concurrency control and audit trail versioning in the Databricks Silver Layer. Incremented on each substantive update.',
    CONSTRAINT pk_risk_mitigation PRIMARY KEY(`risk_mitigation_id`)
) COMMENT 'Transactional record capturing individual risk mitigation actions and their execution status for program-level risks. Captures mitigation action description, action owner, planned completion date, actual completion date, action status (planned';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`program`.`assumption` (
    `assumption_id` BIGINT COMMENT 'Unique surrogate identifier for the program assumption record within the clinical development program planning framework.',
    `clinical_program_id` BIGINT COMMENT 'Reference to the clinical development program to which this assumption belongs. Links the assumption to its parent program for portfolio governance and milestone tracking.',
    `parent_assumption_id` BIGINT COMMENT 'Self-referencing identifier linking this assumption to a higher-level parent assumption, enabling hierarchical assumption structures within the clinical development plan (e.g., a site-level enrollment assumption nested under a program-level enrollment',
    `primary_assumption_owner_employee_id` BIGINT COMMENT 'FK to workforce.employee',
    `primary_revised_assumption_id` BIGINT COMMENT 'Self-referencing FK on assumption (revised_assumption_id)',
    `applicable_geography` STRING COMMENT 'Geographic scope to which this assumption applies, expressed as ISO 3166-1 alpha-3 country codes or regional designations (e.g., USA, GBR, JPN, Global). Relevant for enrollment rate, regulatory timeline, and site activation assumptions.',
    `applicable_phase` STRING COMMENT 'Clinical development phase(s) to which this assumption applies. Allows program planners to scope assumptions to specific phases of the development program (Phase 1 through Phase 4 or across all phases).. Valid values are `phase_1|phase_2|phase_3|phase_4|all_phases`',
    `assumption_category` STRING COMMENT 'Categorical classification of the planning assumption type that drives program timeline and resource planning. [ENUM-REF-CANDIDATE',
    `assumption_code` STRING COMMENT 'Externally-known, human-readable unique code assigned to this planning assumption for cross-referencing in clinical development plans, program governance documents, and regulatory submissions.. Valid values are `^ASM-[A-Z0-9]{4,12}$`',
    `confidence_level` STRING COMMENT 'Qualitative assessment of the degree of certainty in the planning assumption, based on available evidence, historical data, and expert judgment. Drives risk-adjusted program timeline and resource planning.. Valid values are `high|medium|low`',
    `confidence_rationale` STRING COMMENT 'Narrative explanation supporting the assigned confidence level, including references to historical study data, literature, competitive intelligence, or expert opinion used to substantiate the assumption.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this program assumption record was first created in the system, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Required for ALCOA+ audit trail compliance under 21 CFR Part 11.',
    `data_source` STRING COMMENT 'Primary source of data or evidence underpinning this assumption (e.g., Medidata Rave enrollment metrics, Published literature – NEJM 2022, FDA precedent database, Internal historical study database, Competitive intelligence report).',
    `dependency_description` STRING COMMENT 'Narrative description of the program plan elements, milestones, studies, or other assumptions that are dependent on this assumption. Identifies what would need to be revised if this assumption is invalidated.',
    `assumption_description` STRING COMMENT 'Full narrative description of the planning assumption, including the basis for the assumption, supporting evidence, and its role in the clinical development plan timeline and resource projections.',
    `effective_from_date` DATE COMMENT 'Date from which this assumption version is considered active and applicable to program planning. Supports temporal versioning of assumptions across the clinical development lifecycle.',
    `invalidation_trigger` STRING COMMENT 'Specific, pre-defined condition or threshold that, if observed, would constitute invalidation of this assumption and trigger a program plan revision (e.g., Enrollment rate falls below 1.0 patients/site/month for 3 consecutive months).',
    `is_dependency_trigger` BOOLEAN COMMENT 'Indicates whether invalidation of this assumption would trigger a mandatory revision of dependent program plan elements, milestones, or other assumptions. True = this is a critical dependency assumption requiring escalation upon invalidation.',
    `last_review_date` DATE COMMENT 'Date on which this assumption was most recently formally reviewed by the program governance committee or assumption owner, regardless of whether the assumption value was changed.',
    `lower_bound_value` DECIMAL(18,2) COMMENT 'Pessimistic or minimum plausible value for the assumption used in downside scenario planning and sensitivity analysis (e.g., 1.5 patients/site/month as the low-end enrollment rate estimate).',
    `next_review_date` DATE COMMENT 'Scheduled date for the next formal review of this assumption by the program governance committee or assumption owner. Drives automated review reminders in the CTMS and program planning tools.',
    `regulatory_agency` STRING COMMENT 'Primary regulatory agency relevant to this assumption, particularly for regulatory timeline and submission assumptions. Drives agency-specific planning parameters in the clinical development plan.',
    `review_frequency` STRING COMMENT 'Scheduled frequency at which this assumption must be reviewed and revalidated by the assumption owner or program governance committee to ensure continued relevance to the clinical development plan.. Valid values are `monthly|quarterly|semi_annually|annually|event_triggered|ad_hoc`',
    `risk_mitigation_plan` STRING COMMENT 'Description of the contingency or mitigation actions to be executed if this assumption is invalidated, including fallback strategies, alternative approaches, and escalation paths within the program governance framework.',
    `assumption_status` STRING COMMENT 'Current lifecycle state of the planning assumption within the program governance workflow. Drives whether the assumption is actively used in program planning or has been retired/replaced.. Valid values are `draft|active|under_review|validated|invalidated|superseded`',
    `subcategory` STRING COMMENT 'Further granular classification within the assumption category (e.g., within enrollment_rate: screen_failure_rate, site_activation_rate). Enables detailed segmentation for sensitivity analysis and program risk management.',
    `supporting_document_ref` STRING COMMENT 'Reference identifier or URL to supporting documentation in Veeva Vault eTMF or document management system (e.g., Clinical Development Plan version, Feasibility Report, Regulatory Intelligence Report) that substantiates this assumption.',
    `therapeutic_area` STRING COMMENT 'Therapeutic area or disease indication to which this assumption applies (e.g., Oncology, Cardiovascular, Rare Disease, Neuroscience). Enables cross-program benchmarking of assumptions within the same therapeutic area.',
    `title` STRING COMMENT 'Concise, human-readable title summarizing the planning assumption (e.g., Phase 3 Enrollment Rate – North America Sites). Used as the primary label in program governance dashboards and Clinical Development Plan (CDP) documents.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this program assumption record, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Required for ALCOA+ audit trail compliance under 21 CFR Part 11.',
    `upper_bound_value` DECIMAL(18,2) COMMENT 'Optimistic or maximum plausible value for the assumption used in upside scenario planning and sensitivity analysis (e.g., 4.0 patients/site/month as the high-end enrollment rate estimate).',
    `validation_date` DATE COMMENT 'Date on which the assumption was most recently validated or invalidated by the assumption owner or program governance committee. Used to assess currency of assumptions in program planning.',
    `validation_method` STRING COMMENT 'Description of the method or evidence source used to validate the assumption (e.g., Historical enrollment data from Phase 2 study, FDA precedent review, DSMB interim analysis, Competitive intelligence report).',
    `validation_status` STRING COMMENT 'Current validation state of the assumption, reflecting whether supporting evidence has been reviewed and confirmed. Validated assumptions are used as confirmed inputs to program planning; invalidated assumptions trigger plan revision workflows.. Valid values are `pending|validated|invalidated|partially_validated`',
    `value` DECIMAL(18,2) COMMENT 'The specific quantitative or qualitative value of the assumption (e.g., 2.5 patients/site/month, 18 months for FDA review, 15% screen failure rate). Stored as STRING to accommodate diverse assumption types across categories.',
    `value_unit` STRING COMMENT 'Unit of measure for the assumption value where applicable (e.g., patients/site/month, months, percentage, mg/kg). Ensures unambiguous interpretation of quantitative assumptions in program planning models.',
    `version_number` BIGINT COMMENT 'Sequential version number of this assumption record, incremented each time the assumption value, confidence level, or validation status is formally revised. Supports audit trail and change history requirements under 21 CFR Part 11.',
    `version_rationale` STRING COMMENT 'Narrative explanation for why this version of the assumption was created, including the trigger event (e.g., Updated based on Phase 2 interim enrollment data, Revised following FDA Type B meeting feedback, Adjusted per DSMB recommendation).',
    CONSTRAINT pk_assumption PRIMARY KEY(`assumption_id`)
) COMMENT 'Master record for key planning assumptions underlying the clinical development plan and program timeline. Captures assumption description, assumption category (enrollment rate, regulatory timeline, safety profile, competitive landscape, manufacturing';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`program`.`cross_study_dependency` (
    `cross_study_dependency_id` BIGINT COMMENT 'Unique surrogate identifier for the cross-study dependency record within the clinical development program. Primary key for this association entity.',
    `primary_cross_clinical_program_id` BIGINT COMMENT 'Reference to the clinical development program under which this cross-study dependency is governed. Links the dependency to its overarching portfolio governance context.',
    `primary_cross_predecessor_study_id` BIGINT COMMENT 'Reference to the study whose outcome, data, or completion gates the successor study. The predecessor study must reach a defined milestone or status before the successor can proceed.',
    `program_development_milestone_id` BIGINT COMMENT 'Reference to the specific program or study milestone record in the CTMS that represents the gating event in the predecessor study. Enables direct linkage between dependency tracking and milestone management.',
    `actual_resolution_date` DATE COMMENT 'Date on which the dependency was actually resolved, waived, or formally closed. Populated when dependency_status transitions to resolved or waived. Enables schedule variance analysis.',
    `comments` STRING COMMENT 'Free-text field for additional context, notes, or observations about this dependency that do not fit into structured fields. Used by program managers and clinical operations teams for ad hoc annotations.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this cross-study dependency record was first created in the data platform. Supports audit trail, data lineage, and ALCOA+ compliance requirements.',
    `cross_program_flag` BOOLEAN COMMENT 'Indicates whether this dependency spans studies in different clinical development programs (True) or is contained within a single program (False). Cross-program dependencies require portfolio-level governance escalation.',
    `data_package_required` STRING COMMENT 'Description of the specific data package, dataset, or analysis output from the predecessor study required to satisfy this dependency (e.g., Interim PK/PD analysis dataset in CDISC ADaM format, DSMB safety summary report, Dose-response modeling',
    `dependency_code` STRING COMMENT 'Externally-known alphanumeric business identifier for this dependency record, used in program planning documents, integrated development plans, and CTMS tracking. Format: DEP- followed by 4-12 alphanumeric characters.. Valid values are `^DEP-[A-Z0-9]{4,12}$`',
    `dependency_description` STRING COMMENT 'Detailed narrative describing the nature, rationale, and conditions of the dependency between the predecessor and successor studies. Captures what specific data, outcome, or event from the predecessor is required and why.',
    `dependency_direction` STRING COMMENT 'Indicates whether the dependency flows in one direction only (predecessor gates successor) or bidirectionally (studies mutually constrain each other, e.g., platform trials with shared safety data).. Valid values are `unidirectional|bidirectional`',
    `dependency_name` STRING COMMENT 'Short human-readable label for the dependency, used in program planning dashboards, integrated timelines, and governance reports (e.g., Phase 1 PK Data Required for Phase 2 Dose Selection).',
    `dependency_owner` STRING COMMENT 'Name or role of the individual or team accountable for monitoring and resolving this dependency (e.g., Program Director, Clinical Operations Lead, Regulatory Affairs Lead). Supports accountability in program governance.',
    `dependency_status` STRING COMMENT 'Current lifecycle state of the dependency. active = dependency is in force and being tracked; resolved = predecessor condition has been met and dependency is satisfied; waived = dependency formally waived by program governance with documented. Valid values are `active|resolved|waived|on_hold|pending_review`',
    `dependency_type` STRING COMMENT 'Classification of the nature of the dependency between studies. data = successor requires data outputs (e.g., PK/PD, biomarker) from predecessor; safety = successor requires safety review or DSMB/DMC clearance from predecessor; regulatory =. Valid values are `data|safety|regulatory|supply|sequential_design|operational`',
    `dsmb_review_required` BOOLEAN COMMENT 'Indicates whether resolution of this dependency requires a formal DSMB or DMC safety review of predecessor study data before the successor study may initiate. Particularly relevant for safety dependencies.',
    `effective_from_date` DATE COMMENT 'Date from which this dependency record is considered active and binding for program planning purposes. Supports temporal tracking of when dependencies were formally established.',
    `escalation_contact` STRING COMMENT 'Name or role of the senior stakeholder to whom this dependency is escalated if it is at risk of not being resolved by the planned resolution date. Supports risk escalation workflows in program governance.',
    `gating_condition_detail` STRING COMMENT 'Precise, measurable condition or threshold that must be met in the predecessor study to release the successor (e.g., Minimum 80% of Phase 1 subjects must complete PK sampling, No Grade 3+ DLTs observed at target dose level).',
    `gating_milestone` STRING COMMENT 'Specific milestone or event in the predecessor study that must be achieved to satisfy this dependency (e.g., Database Lock, DSMB Safety Review Completion, Regulatory Clearance of IND Amendment, Last Patient Last Visit).',
    `governance_review_required` BOOLEAN COMMENT 'Indicates whether this dependency requires formal review and sign-off by a program governance committee (e.g., Program Steering Committee, Joint Development Committee) before the successor study can proceed.',
    `impact_if_unmet` STRING COMMENT 'Narrative description of the business, regulatory, or patient safety impact if this dependency is not satisfied before the successor study proceeds. Used in risk management and program governance decision-making.',
    `last_review_date` DATE COMMENT 'Date on which this dependency record was most recently reviewed by the program governance team or dependency owner. Supports periodic dependency health checks in integrated program planning.',
    `mitigation_plan` STRING COMMENT 'Documented contingency or mitigation strategy to be executed if this dependency cannot be resolved by the planned date. Describes alternative approaches to allow the successor study to proceed with acceptable risk.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next formal review of this dependency by the program governance team. Drives governance calendar and ensures active dependencies are not overlooked.',
    `planned_resolution_date` DATE COMMENT 'Target date by which the dependency is expected to be resolved (i.e., the predecessor gating milestone is expected to be achieved). Used in integrated program timeline planning and critical path analysis.',
    `regulatory_agency_notification_required` BOOLEAN COMMENT 'Indicates whether resolution or waiver of this dependency requires notification to or approval from a regulatory agency (FDA, EMA, PMDA, etc.) before the successor study proceeds. Drives regulatory submission planning.',
    `regulatory_submission_reference` STRING COMMENT 'Reference number or identifier of the regulatory submission (IND amendment, CTA, protocol amendment) associated with the resolution or waiver of this dependency. Links to Veeva Vault regulatory submission records.',
    `risk_level` STRING COMMENT 'Assessed risk level associated with this dependency not being met on schedule. critical = program-stopping impact; high = significant delay or regulatory risk; medium = manageable delay with mitigation; low = minor impact with available. Valid values are `critical|high|medium|low`',
    `schedule_impact_days` BIGINT COMMENT 'Estimated number of calendar days by which the successor study initiation would be delayed if this dependency is not resolved by the planned resolution date. Used in critical path and scenario planning.',
    `source_system_record_reference` STRING COMMENT 'Native identifier of this dependency record in the originating operational system (e.g., the source system dependency object ID). Supports data lineage, reconciliation, and audit trail back to the system of record.',
    `successor_earliest_start_date` DATE COMMENT 'Earliest permissible initiation date for the successor study, derived from the expected resolution of this dependency. Drives integrated program scheduling and site activation planning.',
    `supply_dependency_detail` STRING COMMENT 'Specific description of the drug supply, manufacturing batch, or IRT/RTSM configuration requirement from the predecessor study that must be fulfilled before the successor study can be supplied. Relevant for supply dependencies.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this cross-study dependency record was most recently modified. Supports change detection, incremental data loading, and audit trail for regulatory inspection readiness.',
    `version_number` BIGINT COMMENT 'Sequential version number of this dependency record, incremented each time the dependency definition, gating condition, or resolution criteria is formally revised. Supports change history and audit trail.',
    `waiver_approval_date` DATE COMMENT 'Date on which the dependency waiver was formally approved by the designated governance authority. Required for audit trail completeness when dependency_status = waived.',
    `waiver_approved_by` STRING COMMENT 'Name or identifier of the governance body or senior authority (e.g., Program Steering Committee, Chief Medical Officer, DSMB) that approved the waiver of this dependency. Supports audit trail for regulatory inspection.',
    `waiver_rationale` STRING COMMENT 'Documented justification for formally waiving this dependency, including the scientific, regulatory, or operational basis for proceeding without satisfying the original gating condition. Required when dependency_status = waived.',
    CONSTRAINT pk_cross_study_dependency PRIMARY KEY(`cross_study_dependency_id`)
) COMMENT 'Association entity capturing formal dependencies between studies within a program or across programs where one studys outcome, data, or completion gates another studys initiation or design.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` (
    `program_resource_plan_id` BIGINT COMMENT 'Unique surrogate identifier for the program-level resource plan record in the Databricks Silver Layer.',
    `clinical_program_id` BIGINT COMMENT 'Reference to the clinical development program this resource plan belongs to, linking cross-study resource aggregation to the governing program entity.',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Resource plans drive cost center headcount and FTE cost allocations. program_resource_plan has planned_cost_usd and forecasted_cost_usd that must be allocated to finance cost centers for',
    `master_agreement_id` BIGINT COMMENT 'Foreign key linking to sponsor.master_agreement. Business justification: Resource plans under preferred provider agreements must be tied to contracted capacity commitments. program_resource_plan has cro_id(unlinked) but no master_agreement link.',
    `org_unit_id` BIGINT COMMENT 'Foreign key linking to workforce.org_unit. Business justification: Program resource plans are built for specific organizational units (e.g., Clinical Operations, Biostatistics) responsible for delivering FTE resources.',
    `plan_owner_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Resource plan ownership is assigned to named employees accountable for FTE demand forecasting and workforce planning governance.',
    `primary_predecessor_plan_program_resource_plan_id` BIGINT COMMENT 'Reference to the prior version of this resource plan that this record supersedes, enabling version lineage tracking across plan revisions.',
    `primary_program_cro_organization_id` BIGINT COMMENT 'Reference to the Contract Research Organization (CRO) responsible for delivering the planned resources, if applicable. Null for internally resourced programs.',
    `actual_fte_count` DECIMAL(10,2) COMMENT 'The actual number of FTEs currently assigned and active for this functional area and role within the program, sourced from the source system',
    `approval_date` DATE COMMENT 'Date on which the resource plan was formally approved by the program governance authority, marking the transition from draft/review to approved status.',
    `approved_by` STRING COMMENT 'Name or identifier of the program governance authority or individual who formally approved this resource plan, supporting audit trail requirements under GCP and 21 CFR Part 11.',
    `comments` STRING COMMENT 'Free-text field for additional context, assumptions, or notes related to this resource plan record, captured by the plan owner or reviewer.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this resource plan record was first created in the system, supporting audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for all monetary cost fields in this resource plan record (e.g., USD, EUR, GBP), enabling multi-currency program portfolio reporting.. Valid values are `^[A-Z]{3}$`',
    `development_phase` STRING COMMENT 'Clinical development phase of the program (Phase 1 through Phase 4 or Pre-Clinical), which drives resource intensity assumptions and regulatory compliance requirements.',
    `effective_end_date` DATE COMMENT 'Date on which this version of the resource plan ceases to be active, typically when superseded by a revised version or upon program close-out.',
    `effective_start_date` DATE COMMENT 'Date from which this version of the resource plan is considered binding and active for program execution and financial commitment purposes.',
    `escalation_flag` BOOLEAN COMMENT 'Indicates whether this resource plan record has been flagged for escalation to program leadership or the sponsor due to a significant resource gap or risk.',
    `forecasted_cost_usd` DECIMAL(18,2) COMMENT 'Current rolling forecast of total resource cost in US Dollars for this functional area and role, updated as FTE forecasts and rate assumptions change.',
    `forecasted_fte_count` DECIMAL(10,2) COMMENT 'The current rolling forecast of FTEs required for this functional area and role, updated as program scope, study timelines, or enrollment assumptions change.',
    `forecasted_hours` DECIMAL(12,2) COMMENT 'Current rolling forecast of total labor hours for this functional area and role, updated as program scope or study timelines evolve.',
    `functional_area` STRING COMMENT 'The organizational functional area whose resource requirements are captured in this plan row, such as Clinical Operations, Data Management, Biostatistics, Regulatory Affairs, or Medical Monitoring.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this resource plan record, enabling change detection and audit trail compliance under 21 CFR Part 11.',
    `mitigation_action` STRING COMMENT 'Description of the planned or in-progress action to address the resource gap or risk, such as CRO backfill, internal redeployment, or scope reduction.',
    `plan_code` STRING COMMENT 'Externally-known alphanumeric code uniquely identifying this resource plan within the program portfolio, used in CTMS and the source system planning references.. Valid values are `^[A-Z0-9_-]{3,30}$`',
    `plan_name` STRING COMMENT 'Human-readable name describing the program resource plan, e.g., PROG-2024-ONCOLOGY-RESOURCE-PLAN-v2.',
    `plan_status` STRING COMMENT 'Current lifecycle state of the resource plan, governing whether it is in authoring, review, approved for execution, actively being tracked, superseded by a newer version, or cancelled.. Valid values are `draft|under_review|approved|active|superseded|cancelled`',
    `plan_type` STRING COMMENT 'Classification of the resource plan indicating whether it represents the original baseline, a formal revision, a scenario/what-if analysis, or a contingency plan for risk mitigation.. Valid values are `baseline|revised|scenario|contingency`',
    `plan_version` STRING COMMENT 'Version identifier of the resource plan (e.g., v1.0, v2.0), enabling tracking of iterative revisions as program scope or study portfolio changes.. Valid values are `^vd+(.d+)?$`',
    `planned_cost_usd` DECIMAL(18,2) COMMENT 'Planned total resource cost in US Dollars for this functional area and role over the planning period, derived from planned FTE counts and applicable rate cards. Sourced from the source system accounting.',
    `planned_fte_count` DECIMAL(10,2) COMMENT 'The baseline planned number of Full-Time Equivalents (FTEs) required for this functional area and role over the planning period, as established at plan approval.',
    `planned_hours` DECIMAL(12,2) COMMENT 'Total planned labor hours for this functional area and role over the planning period, complementing FTE counts for granular capacity planning and budget alignment.',
    `planning_granularity` STRING COMMENT 'Time granularity at which the resource plan is structured — monthly, quarterly, or annual — determining the resolution of FTE and cost forecasts.. Valid values are `monthly|quarterly|annual`',
    `planning_period_end_date` DATE COMMENT 'End date of the resource planning horizon covered by this plan, defining the outer boundary of the workforce forecast window.',
    `planning_period_start_date` DATE COMMENT 'Start date of the resource planning horizon covered by this plan, typically aligned to the program fiscal year or study execution window.',
    `resource_category` STRING COMMENT 'Classification of the resource type indicating whether the planned workforce is internal full-time employees, contract staff, Contract Research Organization (CRO) staff, or other vendor-supplied resources.. Valid values are `internal_fte|contract_fte|cro_fte|vendor_fte`',
    `resource_gap_fte` DECIMAL(10,2) COMMENT 'The net difference between forecasted FTE demand and actual FTE supply (forecasted_fte_count minus actual_fte_count), indicating staffing shortfall (positive) or surplus (negative) for portfolio governance decisions.',
    `resource_role` STRING COMMENT 'Specific workforce role within the functional area being planned, e.g., Clinical Research Associate (CRA), Clinical Research Coordinator (CRC), Biostatistician, Data Manager, Regulatory Affairs Specialist, Medical Monitor.',
    `revision_reason` STRING COMMENT 'Narrative explanation for why this version of the resource plan was created or revised, e.g., protocol amendment, enrollment acceleration, scope change, or budget reforecast.',
    `risk_rating` STRING COMMENT 'Assessment of the risk level associated with the resource gap or plan assumptions, used to prioritize escalation and mitigation actions in program governance reviews.. Valid values are `low|medium|high|critical`',
    `site_count` BIGINT COMMENT 'Total number of investigational sites across all studies in the program contributing to the resource demand captured in this plan.',
    `source_system_record_reference` STRING COMMENT 'The native record identifier from the originating source system (e.g., the source system plan ID, the source system resource plan ID), supporting data lineage and reconciliation.',
    `study_count` BIGINT COMMENT 'Number of active studies within the program that are aggregated into this resource plan, providing context for the scale of cross-study resource demand.',
    `therapeutic_area` STRING COMMENT 'The therapeutic area or disease indication associated with the program (e.g., Oncology, Cardiovascular, Neurology), providing context for resource benchmarking across programs.',
    CONSTRAINT pk_program_resource_plan PRIMARY KEY(`program_resource_plan_id`)
) COMMENT 'Master record for program-level resource planning, capturing the aggregate workforce and functional resource requirements across all studies in a program. Captures resource plan version, planning period, functional area (clinical operations, data';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`program`.`budget` (
    `budget_id` BIGINT COMMENT 'Unique system-generated identifier for the program-level budget envelope record. Primary key for this entity.',
    `clinical_program_id` BIGINT COMMENT 'Reference to the parent clinical development program that this budget envelope governs. Links to program.clinical_program.',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Program budgets are managed under specific cost centers for financial control and the source system',
    `gl_account_id` BIGINT COMMENT 'Foreign key linking to finance.gl_account. Business justification: Program budget entries must be posted to GL accounts for financial reporting. program_budget has gl_account_code (denormalized); replacing with FK to finance.gl_account enables proper',
    `master_agreement_id` BIGINT COMMENT 'Foreign key linking to sponsor.master_agreement. Business justification: Program budgets are governed by master agreement financial terms (pricing, payment schedules, volume commitments).',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization funding this program budget. Relevant for CRO-managed programs where the budget is governed on behalf of an external sponsor.',
    `primary_budget_approved_by_employee_id` BIGINT COMMENT 'Reference to the individual or governance body representative who formally approved this budget version. Supports SOX audit trail and segregation of duties compliance.',
    `primary_prior_version_budget_id` BIGINT COMMENT 'Self-referencing identifier pointing to the immediately preceding budget version that this record supersedes. Enables full budget revision history chain traversal for audit and variance analysis.',
    `approval_date` DATE COMMENT 'Date on which this budget version received formal governance approval from the authorized approving body (e.g., Portfolio Review Committee, Finance Committee). Required for SOX compliance audit trail.',
    `approval_governance_body` STRING COMMENT 'Name of the governance committee or body that approved this budget version (e.g., Portfolio Review Committee, R&D Finance Committee, Executive Leadership Team). Supports audit trail and governance accountability.',
    `biostatistics_budget_amount` DECIMAL(18,2) COMMENT 'Budget allocation for the biostatistics functional area, covering Statistical Analysis Plan (the source system) development, analysis execution, TLF production, and Clinical Study Report (CSR) statistical sections.',
    `clinical_ops_budget_amount` DECIMAL(18,2) COMMENT 'Budget allocation for clinical operations functional area, covering site management, monitoring (CRA activities), patient recruitment, and site payments across the program.',
    `budget_code` STRING COMMENT 'Externally-known alphanumeric code uniquely identifying this budget envelope within the organizations financial management system (the source system for cross-system reconciliation and financial reporting.. Valid values are `^[A-Z0-9-]{3,30}$`',
    `contingency_amount` DECIMAL(18,2) COMMENT 'Portion of the total approved budget set aside as contingency reserve for unforeseen program costs, protocol amendments, or scope changes. Typically expressed as a percentage of total budget but stored as absolute value.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this program budget record was first created in the system. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `cro_budget_amount` DECIMAL(18,2) COMMENT 'Budget allocation for Contract Research Organization (CRO) services and outsourced activities across the program. Represents the total envelope for external CRO spend governed by master service agreements.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which the program budget is denominated (e.g., USD, EUR, GBP). All monetary fields in this record are expressed in this currency.. Valid values are `^[A-Z]{3}$`',
    `data_management_budget_amount` DECIMAL(18,2) COMMENT 'Budget allocation for the data management functional area, covering EDC setup (Medidata Rave), eCRF design, data cleaning, database lock (DBL), and CDISC/SDTM/ADaM transformation activities.',
    `effective_end_date` DATE COMMENT 'Date on which this budget version ceases to be the active governing envelope. Null for open-ended budgets. When a revised budget is approved, the prior versions effective_end_date is set to the day before the new versions effective_start_date.',
    `effective_start_date` DATE COMMENT 'Date from which this budget version becomes effective and authorizes financial commitments. Aligns with fiscal year planning cycles and program governance approval timelines.',
    `exchange_rate` DECIMAL(12,6) COMMENT 'Foreign exchange rate applied to convert budget amounts from the programs operating currency to the corporate reporting currency at the time of budget approval. Supports multi-currency program financial consolidation.',
    `fiscal_year` STRING COMMENT 'The primary fiscal year to which this budget version is aligned (e.g., 2024). Multi-year programs may span multiple fiscal years;. Valid values are `^[0-9]{4}$`',
    `is_locked` BOOLEAN COMMENT 'Indicates whether this budget version is locked against further modifications. A locked budget (True) has been formally approved and committed; changes require a formal revision process creating a new version.',
    `lab_budget_amount` DECIMAL(18,2) COMMENT 'Budget allocation for central and local laboratory services across the program, including sample analysis, biomarker testing, PK/PD assays, and laboratory kit supply.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this program budget record. Supports change tracking, audit trail compliance, and incremental data pipeline processing.',
    `budget_name` STRING COMMENT 'Human-readable descriptive name for this budget envelope (e.g., Phase II/III Oncology Program Budget FY2024). Used in financial reports and governance presentations.',
    `notes` STRING COMMENT 'Free-text field for additional context, assumptions, constraints, or governance commentary associated with this budget version. Captures information not accommodated by structured fields.',
    `phase1_budget_amount` DECIMAL(18,2) COMMENT 'Budget allocation designated for Phase I clinical studies within this program. Supports phase-level financial planning and portfolio governance reporting.',
    `phase2_budget_amount` DECIMAL(18,2) COMMENT 'Budget allocation designated for Phase II clinical studies within this program. Supports phase-level financial planning and portfolio governance reporting.',
    `phase3_budget_amount` DECIMAL(18,2) COMMENT 'Budget allocation designated for Phase III clinical studies within this program. Typically the largest phase allocation given pivotal trial scale and regulatory submission requirements.',
    `phase4_budget_amount` DECIMAL(18,2) COMMENT 'Budget allocation designated for Phase IV post-marketing studies and commitments within this program. Covers post-approval safety studies and label expansion activities.',
    `regulatory_budget_amount` DECIMAL(18,2) COMMENT 'Budget allocation for the regulatory affairs functional area, covering IND/NDA/BLA/MAA submission preparation, agency interactions, eCTD compilation, and regulatory strategy activities.',
    `reporting_currency_code` STRING COMMENT 'ISO 4217 three-letter code for the corporate reporting currency used for consolidated financial reporting (e.g., USD for a US-headquartered sponsor). Distinct from currency_code which is the budgets operating currency.. Valid values are `^[A-Z]{3}$`',
    `revision_reason` STRING COMMENT 'Narrative explanation for why this budget version was created as a revision of a prior version (e.g., protocol amendment, scope expansion, enrollment rate change, regulatory requirement). Required for revised and supplemental budget types.',
    `safety_budget_amount` DECIMAL(18,2) COMMENT 'Budget allocation for the safety and pharmacovigilance functional area, covering SAE/SUSAR reporting, signal detection, DSMB/DMC support, and the source system system operations.',
    `source_system_record_reference` STRING COMMENT 'The native identifier of this budget record in the originating source system (e.g., the source system document number). Enables bidirectional traceability between the lakehouse silver layer and the system of record.',
    `budget_status` STRING COMMENT 'Current lifecycle state of the program budget envelope. Controls whether the budget is active for financial commitments. [ENUM-REF-CANDIDATE: draft|under_review|approved|revised|superseded|closed — promote to reference product if additional states are',
    `submission_date` DATE COMMENT 'Date on which this budget version was formally submitted for governance review and approval. Distinct from approval_date; captures the review cycle duration for process analytics.',
    `supply_chain_budget_amount` DECIMAL(18,2) COMMENT 'Budget allocation for investigational product (IP) manufacturing, packaging, labeling, distribution, and RTSM/IRT system operations across the program.',
    `total_approved_amount` DECIMAL(18,2) COMMENT 'Total approved financial envelope for the entire clinical development program across all studies, phases, and functional areas. Represents the gross authorized spend ceiling approved by governance.',
    `budget_type` STRING COMMENT 'Classification of the budget envelope by its purpose: initial baseline, formal revision, supplemental addition, or contingency reserve allocation.. Valid values are `initial|revised|supplemental|contingency`',
    `version` STRING COMMENT 'Version identifier for this budget record (e.g., v1.0, v2.0, v3.1). Supports budget versioning and revision history tracking as budgets are revised through the program lifecycle.. Valid values are `^v[0-9]+.[0-9]+$`',
    `wbs_code` STRING COMMENT 'Work Breakdown Structure (WBS) element code from the source system Accounting that maps this program budget to the project hierarchy for cost tracking and financial reporting.',
    CONSTRAINT pk_budget PRIMARY KEY(`budget_id`)
) COMMENT 'Master record for the program-level budget envelope governing total financial investment across all studies and activities within a clinical development program.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`program`.`program_status_history` (
    `program_status_history_id` BIGINT COMMENT 'Unique surrogate identifier for each program status transition record in the lifecycle audit trail.',
    `clinical_program_id` BIGINT COMMENT 'Reference to the clinical development program whose status changed. Links this history record to the parent program entity.',
    `governance_meeting_id` BIGINT COMMENT 'Unique identifier of the governance or portfolio review meeting at which the status transition decision was made. Supports traceability to meeting minutes and decision records in the eTMF.',
    `previous_program_status_history_id` BIGINT COMMENT 'Self-referencing FK on program_status_history (previous_program_status_history_id)',
    `primary_program_employee_id` BIGINT COMMENT 'System user identifier of the person or automated process that recorded this status transition in the CTMS or data platform. Supports 21 CFR Part 11 electronic signature and audit trail requirements.',
    `approval_date` DATE COMMENT 'Date on which the status transition was formally approved by the authorized individual or governance body. Supports audit trail completeness and separation of recording vs. approval events.',
    `approved_by_name` STRING COMMENT 'Full name of the individual who approved this status transition. Required for regulatory inspection readiness. Classified confidential as it identifies internal personnel.',
    `comments` STRING COMMENT 'Additional free-text comments or contextual notes associated with this status transition, entered by the recorder or approver. Supplements the structured reason fields with qualitative context.',
    `compliance_inspection_code` BIGINT COMMENT 'Foreign key linking to compliance.inspection. Business justification: Program status changes (clinical holds, terminations) are frequently triggered by regulatory inspections with warning letters or critical findings.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this status history record was first created in the data platform. Supports audit trail completeness and data lineage tracking per 21 CFR Part 11 and ALCOA+ requirements.',
    `development_phase_at_transition` STRING COMMENT 'The clinical development phase of the program at the time of this status transition. Captures the phase context for historical analysis, as a program may span multiple phases over its lifecycle.',
    `effective_date` DATE COMMENT 'The date from which the new program status is operationally effective. May differ from transition_date when a decision is made in advance of the effective date (e.g., a planned hold effective next quarter).',
    `expected_resolution_date` DATE COMMENT 'Anticipated date by which the current status is expected to be resolved or transitioned again (e.g., expected lift of a clinical hold, expected resumption from On Hold). Supports program planning and portfolio forecasting.',
    `governance_body` STRING COMMENT 'The organizational body or committee that authorized or mandated the status transition. Examples include Portfolio Review Board, Executive Committee, Data Safety Monitoring Board (DSMB), Data Monitoring Committee (DMC), or a regulatory authority.',
    `hold_lift_conditions` STRING COMMENT 'Description of the conditions or actions required to lift the current hold and transition the program back to active status. Populated when hold_type is not null. Supports program planning and regulatory response management.',
    `hold_type` STRING COMMENT 'Specifies the type of hold applied when the new_status is On Hold or Suspended. Distinguishes between FDA clinical holds, partial clinical holds, voluntary sponsor holds, and internal program holds. Null when new_status is not a hold state.. Valid values are `CLINICAL_HOLD|PARTIAL_CLINICAL_HOLD|VOLUNTARY_HOLD|INTERNAL_HOLD`',
    `impacted_study_count` BIGINT COMMENT 'Number of individual clinical studies within the program that are directly impacted by this status transition. Supports portfolio impact assessment and resource planning.',
    `is_current` BOOLEAN COMMENT 'Indicates whether this record represents the most recent (current) status of the program (True) or is a historical record (False). Enables efficient querying of current program status without full history scan.',
    `is_system_generated` BOOLEAN COMMENT 'Indicates whether this status transition was automatically generated by a system process (True) or manually entered by a user (False). Supports audit trail integrity and distinguishes automated workflow transitions from human decisions.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this status history record in the data platform. Supports change tracking and data quality monitoring in the Databricks Silver layer.',
    `new_status` STRING COMMENT 'The program lifecycle status immediately after this transition. Captures the to state in the state-change pair. [ENUM-REF-CANDIDATE: Concept|Planning|Active|On Hold|Suspended|Terminated|Completed — promote to reference product]',
    `notification_required` BOOLEAN COMMENT 'Indicates whether this status transition requires formal notification to a regulatory authority (e.g., FDA, EMA). Drives regulatory affairs workflow and ensures compliance with reporting obligations.',
    `notification_submitted_date` DATE COMMENT 'Date on which the required regulatory notification for this status transition was submitted to the relevant authority. Populated when notification_required is True. Supports compliance tracking and submission timelines.',
    `previous_status` STRING COMMENT 'The program lifecycle status immediately before this transition. Captures the from state in the state-change pair. [ENUM-REF-CANDIDATE: Concept|Planning|Active|On Hold|Suspended|Terminated|Completed — promote to reference product]',
    `recorded_by_name` STRING COMMENT 'Full name of the individual who recorded this status transition. Required for regulatory inspection readiness and audit trail completeness per ALCOA+ principles. Classified confidential as it identifies internal personnel.',
    `recorded_by_role` STRING COMMENT 'Functional role of the individual or system that recorded the status transition. Supports accountability tracking and governance reporting. [ENUM-REF-CANDIDATE. Valid values are `PROGRAM_LEAD|MEDICAL_MONITOR|REGULATORY_AFFAIRS|PORTFOLIO_MANAGER|SYSTEM|SPONSOR_REPRESENTATIVE`',
    `regulatory_authority` STRING COMMENT 'The regulatory authority whose action or correspondence triggered or is associated with this status transition (e.g., FDA clinical hold, EMA referral). Populated when triggering_event_type is REGULATORY_ACTION.',
    `regulatory_correspondence_ref` STRING COMMENT 'Reference number or identifier of the regulatory correspondence (e.g., FDA clinical hold letter, EMA opinion reference) associated with this status transition. Enables direct linkage to regulatory submissions and responses.',
    `safety_signal_flag` BOOLEAN COMMENT 'Indicates whether this status transition was triggered by or associated with a safety signal or Serious Adverse Event (SAE) / Suspected Unexpected Serious Adverse Reaction (SUSAR). Supports pharmacovigilance reporting and DSMB oversight.',
    `source_system_record_reference` STRING COMMENT 'The native record identifier from the originating operational system (e.g., Siebel CTMS activity ID, Veeva Vault document version ID). Enables bidirectional traceability between the lakehouse and the system of record.',
    `tmf_document_ref` STRING COMMENT 'Reference to the Trial Master File (TMF) document or eTMF artifact (e.g., Veeva Vault document ID) that provides evidence for this status transition. Supports regulatory inspection readiness and TMF completeness.',
    `transition_date` DATE COMMENT 'The calendar date on which the program status formally changed. Used for milestone tracking, governance reporting, and regulatory inspection readiness.',
    `transition_reason_code` STRING COMMENT 'Standardized code categorizing the business reason for the status transition. Enables programmatic filtering and trend analysis across programs. [ENUM-REF-CANDIDATE',
    `transition_reason_description` STRING COMMENT 'Free-text narrative explaining the specific business rationale for the status transition. Provides context beyond the standardized reason code for governance review and regulatory inspection.',
    `transition_sequence` BIGINT COMMENT 'Ordinal sequence number of this status transition within the program lifecycle, starting at 1. Enables chronological ordering and gap detection in the audit trail.',
    `transition_timestamp` TIMESTAMP COMMENT 'Precise date and time (with timezone offset) at which the status transition was recorded in the system. Supports 21 CFR Part 11 audit trail requirements for electronic records.',
    `triggering_event_date` DATE COMMENT 'Date on which the triggering event (governance decision, regulatory action, sponsor directive) formally occurred. May differ from transition_date if there is a lag between the event and system recording.',
    `triggering_event_reference` STRING COMMENT 'External reference identifier for the event that triggered the transition (e.g., governance meeting number, regulatory correspondence reference, DSMB meeting ID, sponsor directive document number). Enables traceability to source documents.',
    `triggering_event_type` STRING COMMENT 'Classification of the event that triggered the status transition. Distinguishes between governance decisions, regulatory actions, sponsor directives, Data Safety Monitoring Board (DSMB) recommendations, and other formal triggers.',
    CONSTRAINT pk_program_status_history PRIMARY KEY(`program_status_history_id`)
) COMMENT 'Lifecycle history table tracking every formal status transition of a clinical development program from initiation through completion or termination. Captures previous status, new status, transition date, transition reason, triggering event (governance';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`program`.`team_member` (
    `team_member_id` BIGINT COMMENT 'Unique surrogate identifier for the program team member assignment record within the clinical development program.',
    `clinical_program_id` BIGINT COMMENT 'Reference to the clinical development program to which this team member is assigned. Links to the clinical_program master entity.',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Program team members are assigned to cost centers for headcount cost allocation and internal recharging.',
    `job_profile_id` BIGINT COMMENT 'Foreign key linking to workforce.job_profile. Business justification: Program staffing governance requires confirming each team member holds the correct job profile for their program role — including GCP training requirements, delegation eligibility, and',
    `primary_predecessor_member_team_member_id` BIGINT COMMENT 'Reference to the previous program team member assignment record that this assignment supersedes, enabling role transition tracking and continuity of program knowledge.',
    `primary_team_employee_id` BIGINT COMMENT 'Reference to the workforce member (employee or contractor) assigned to this program-level role. Sourced from the source system records.',
    `training_curriculum_id` BIGINT COMMENT 'Foreign key linking to workforce.training_curriculum. Business justification: Program team members must complete role-specific training curricula (GCP, protocol, system training) as a prerequisite for program participation.',
    `assignment_code` STRING COMMENT 'Externally-known unique business identifier for this program team member assignment, used in CTMS and program governance communications (e.g., PTM-PROG001-PD).. Valid values are `^PTM-[A-Z0-9]{4,12}$`',
    `assignment_end_date` DATE COMMENT 'The date on which the workforce members program-level role assignment is scheduled to end or was formally concluded. Null for open-ended assignments.',
    `assignment_notes` STRING COMMENT 'Free-text field capturing additional context, special conditions, or qualifications relevant to this team members program assignment (e.g., scope limitations, special responsibilities, interim coverage notes).',
    `assignment_start_date` DATE COMMENT 'The date on which the workforce member formally commenced their program-level role assignment. Used for tenure calculation and resource planning.',
    `assignment_status` STRING COMMENT 'Current lifecycle status of the team members assignment to the program. Drives active roster reporting and resource availability tracking.. Valid values are `Active|Pending|On Leave|Transitioning|Terminated`',
    `assignment_type` STRING COMMENT 'Classification of the nature of the team members assignment to the program (e.g., Permanent, Interim, Acting, Secondment, Advisory). Determines contractual obligations and succession planning needs.. Valid values are `Permanent|Interim|Acting|Secondment|Advisory`',
    `confidentiality_agreement_date` DATE COMMENT 'The date on which the team member signed the confidentiality or non-disclosure agreement for this program. Used for compliance tracking and audit purposes.',
    `confidentiality_agreement_signed` BOOLEAN COMMENT 'Indicates whether the team member has executed a confidentiality or non-disclosure agreement covering the clinical program. Required for access to sponsor proprietary data and investigational product information.',
    `conflict_of_interest_date` DATE COMMENT 'The date on which the team member completed their conflict of interest declaration for this program. Used for compliance audit trails and regulatory inspection readiness.',
    `conflict_of_interest_declared` BOOLEAN COMMENT 'Indicates whether the team member has completed a conflict of interest declaration for this program assignment, as required by GCP and sponsor governance policies.',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code representing the primary country of the team members base location, used for regulatory jurisdiction assignment and GDPR/HIPAA compliance scoping.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this program team member assignment record was first created in the data platform. Supports audit trail requirements per 21 CFR Part 11 and ALCOA+ principles.',
    `ctms_user_reference` STRING COMMENT 'The user identifier for this team member in the source system enabling system access traceability and audit trail linkage per 21 CFR Part 11 electronic records requirements.',
    `delegation_authority_level` STRING COMMENT 'The level of decision-making and approval authority delegated to this team member within the program. Governs sign-off rights on protocol amendments, regulatory submissions, and budget approvals.. Valid values are `Full|Limited|Read Only|None`',
    `department_code` STRING COMMENT 'The organizational department code of the team member as recorded in the source system for cost allocation and organizational reporting.',
    `employment_type` STRING COMMENT 'Classification of the workforce members employment relationship with the organization (e.g., Employee, Contractor, Consultant, Secondee). Impacts billing, compliance, and access rights.. Valid values are `Employee|Contractor|Consultant|Secondee`',
    `etmf_access_flag` BOOLEAN COMMENT 'Indicates whether this team member has been granted access to the programs Electronic Trial Master File (eTMF) in Veeva Vault for document review and regulatory submission activities.',
    `fte_allocation_percentage` DECIMAL(5,2) COMMENT 'The percentage of the workforce members full-time equivalent capacity allocated to this program. Used for resource planning, capacity management, and financial cost allocation. Valid range: 0.00 to 100.00.',
    `gcp_certification_expiry_date` DATE COMMENT 'The date on which the team members current GCP certification expires. Used to trigger recertification workflows and ensure ongoing regulatory compliance.',
    `gcp_certification_status` STRING COMMENT 'Current status of the team members Good Clinical Practice (GCP) training certification as required by ICH E6(R2). Mandatory for personnel involved in clinical trial conduct.. Valid values are `Current|Expired|Pending Renewal|Not Required`',
    `geographic_region` STRING COMMENT 'The primary geographic region of responsibility for this team members program role (e.g., North America, Europe, Asia-Pacific). Used for global program coordination and regulatory jurisdiction mapping.',
    `handover_document_ref` STRING COMMENT 'Reference identifier for the formal role handover or transition document stored in Veeva Vault eTMF, ensuring continuity of program knowledge and regulatory traceability.',
    `is_backup_contact` BOOLEAN COMMENT 'Indicates whether this team member serves as the designated backup contact for their program role, covering primary contact absences or transitions.',
    `is_primary_contact` BOOLEAN COMMENT 'Indicates whether this team member is the designated primary contact for their role on the program. Only one team member per role should be flagged as primary at any given time.',
    `program_role` STRING COMMENT 'The designated program-level leadership role held by this team member within the clinical development program. Governs accountability, decision rights, and cross-study coordination responsibilities.. Valid values are `Program Director|Medical Director|Regulatory Lead|Biostatistics Lead|Clinical Operations Lead|Data Management Lead`',
    `regulatory_authority_scope` STRING COMMENT 'The primary regulatory authority or authorities within whose jurisdiction this team members program role operates. Determines applicable GCP guidelines and submission responsibilities.',
    `role_category` STRING COMMENT 'Functional category grouping the program role for portfolio reporting and resource planning (e.g., Clinical, Medical, Regulatory, Biostatistics). [ENUM-REF-CANDIDATE: Clinical|Medical|Regulatory|Biostatistics|Data Management|Finance|Quality|Operations — 8',
    `source_system_record_reference` STRING COMMENT 'The native record identifier from the originating source system (the source system the source system for this assignment, enabling bidirectional traceability and reconciliation.',
    `therapeutic_area_expertise` STRING COMMENT 'The primary therapeutic area(s) of expertise for this team member relevant to the program (e.g., Oncology, Cardiology, Neurology). Used for competency matching and resource allocation decisions.',
    `transition_date` DATE COMMENT 'The date on which a formal role handover or transition was completed between the predecessor and current team member. Supports audit trail and knowledge transfer documentation.',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this program team member assignment record was most recently modified. Supports change tracking and audit trail requirements per 21 CFR Part 11 and ALCOA+ principles.',
    `wbs_code` STRING COMMENT 'The Work Breakdown Structure code from the source system the specific program work package to which this team members effort is allocated for financial tracking.',
    `work_email` STRING COMMENT 'The professional email address of the team member used for program communications, escalations, and regulatory correspondence. Classified as restricted PII per GDPR and HIPAA.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `work_phone` STRING COMMENT 'The professional phone number of the team member for program-level contact and escalation purposes. Classified as restricted PII per GDPR and HIPAA.. Valid values are `^+?[0-9s-().]{7,20}$`',
    `years_of_experience` BIGINT COMMENT 'Total years of clinical research experience for this team member, used for competency assessment, role eligibility validation, and regulatory inspection readiness.',
    CONSTRAINT pk_team_member PRIMARY KEY(`team_member_id`)
) COMMENT 'Association entity capturing the assignment of key personnel to a clinical development program in defined program-level roles. Captures the workforce member reference, program role (Program Director, Medical Director, Regulatory Lead, Biostatistics Lead';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`program`.`program_communication` (
    `program_communication_id` BIGINT COMMENT 'Unique surrogate identifier for each formal program-level communication record in the Clinical Trials Management System (CTMS). Primary key for this entity.',
    `clinical_program_id` BIGINT COMMENT 'Reference to the clinical development program for which this communication was issued. Links the communication to its parent program context.',
    `employee_id` BIGINT COMMENT 'Reference to the internal staff member (e.g., Program Director, Medical Monitor, Regulatory Affairs Lead) who authored and is accountable for this communication. Maps to the workforce entity in the source system',
    `governance_meeting_id` BIGINT COMMENT 'Reference to the governance meeting (e.g., Program Review Board, DSMB/DMC session, Steering Committee) during which this communication was formally presented or discussed. Null if communication was not delivered via a meeting.',
    `organization_contact_id` BIGINT COMMENT 'Foreign key linking to sponsor.sponsor_contact. Business justification: Program communications are sent to/from specific sponsor contacts. Regulatory correspondence audit trails require identifying the exact sponsor contact for each communication.',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization associated with this program communication. Required for sponsor-facing communications and regulatory submissions.',
    `program_development_milestone_id` BIGINT COMMENT 'Reference to the program milestone that triggered or is the subject of this communication (e.g., milestone notification, delay escalation). Supports milestone-to-communication traceability for portfolio governance.',
    `related_amendment_program_amendment_id` BIGINT COMMENT 'Reference to a program amendment that this communication was issued to announce, support, or respond to. Enables traceability between formal communications and protocol/CDP change control events.',
    `signal_id` BIGINT COMMENT 'Foreign key linking to safety.safety_signal. Business justification: Program-level safety communications (is_safety_related=true) about new safety signals to governance bodies, health authorities, and investigators require structured reference to the',
    `tmf_document_id` BIGINT COMMENT 'The document identifier assigned in Veeva Vault eTMF when this communication is filed as a Trial Master File (TMF) artifact. Enables bidirectional traceability between the CTMS communication record and the eTMF document repository.',
    `acknowledgement_date` DATE COMMENT 'The date on which the final required acknowledgement was received from the recipient audience, completing the communication loop. Null if acknowledgement is not yet received or not required.',
    `acknowledgement_deadline` DATE COMMENT 'The date by which acknowledgement from recipients must be received. Used to trigger overdue escalations and SLA monitoring. Derived from communication type SLA rules but stored as a business field for operational tracking.',
    `acknowledgement_required` BOOLEAN COMMENT 'Indicates whether formal acknowledgement from the recipient(s) is required for this communication. When True, the acknowledgement_status and acknowledgement_date fields must be populated to close the communication loop.',
    `acknowledgement_status` STRING COMMENT 'Current status of recipient acknowledgement for this communication. Tracks whether all required recipients have confirmed receipt and understanding. Overdue status triggers escalation workflows.. Valid values are `not_required|pending|partially_acknowledged|fully_acknowledged|overdue`',
    `body` STRING COMMENT 'Full narrative text or structured content of the communication. Captures the complete message transmitted to stakeholders, including context, decisions, actions required, and supporting rationale.',
    `channel` STRING COMMENT 'The medium or interface through which the communication was transmitted to recipients (e.g., email, formal letter, governance meeting presentation, regulatory authority portal submission). Supports audit trail and stakeholder management analytics.. Valid values are `email|formal_letter|governance_meeting|teleconference|regulatory_portal|secure_messaging`',
    `communication_date` DATE COMMENT 'The real-world date on which the communication was formally issued or transmitted to the intended recipient audience. This is the principal business event date, distinct from the record creation timestamp.',
    `communication_number` STRING COMMENT 'Externally-known, human-readable unique reference number assigned to this communication (e.g., COMM-ONC-2024-000123). Used for tracking, filing in the eTMF, and cross-referencing in governance meeting minutes.. Valid values are `^COMM-[A-Z0-9]{3,10}-[0-9]{4}-[0-9]{4,6}$`',
    `communication_status` STRING COMMENT 'Current lifecycle state of the program communication record. Tracks progression from authoring through issuance and stakeholder acknowledgement. [ENUM-REF-CANDIDATE: draft|pending_review|approved|issued|acknowledged|cancelled — promote to reference',
    `communication_type` STRING COMMENT 'Classification of the formal communication by its business purpose. Drives routing, escalation rules, and eTMF filing zone assignment. [ENUM-REF-CANDIDATE. Valid values are `program_update|milestone_notification|risk_escalation|regulatory_intelligence_update|program_termination_notice|safety_notification`',
    `confidentiality_level` STRING COMMENT 'Data classification level assigned to this communication, governing access controls, distribution restrictions, and eTMF filing permissions. Aligns with the enterprise data classification framework and GDPR/HIPAA obligations.. Valid values are `public|internal|confidential|restricted`',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp at which this program communication record was first created in the system. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `escalation_date` DATE COMMENT 'The date on which this communication was formally escalated to senior leadership or a governance committee. Null if no escalation has occurred.',
    `escalation_flag` BOOLEAN COMMENT 'Indicates whether this communication has been escalated to senior leadership or a governance committee due to urgency, regulatory risk, or unresolved acknowledgement. Triggers escalation workflow in the CTMS.',
    `follow_up_action_required` BOOLEAN COMMENT 'Indicates whether this communication has generated one or more follow-up actions (e.g., protocol amendment, CAPA, regulatory submission, governance escalation) that must be tracked to closure.',
    `follow_up_due_date` DATE COMMENT 'The date by which any follow-up actions arising from this communication must be completed. Drives action item tracking in the CTMS and governance meeting agendas.',
    `is_regulatory_required` BOOLEAN COMMENT 'Indicates whether this communication is mandated by a regulatory authority or applicable regulation (e.g., IND safety report, EMA transparency obligation, SUSAR notification). True = regulatory obligation; False = voluntary/internal.',
    `is_safety_related` BOOLEAN COMMENT 'Indicates whether this communication pertains to a safety matter, including SAE/SUSAR notifications, DSMB/DMC safety reviews, or risk escalations involving patient safety. Drives expedited processing and the source system cross-referencing.',
    `owner_name` STRING COMMENT 'Full name of the internal staff member accountable for authoring and issuing this communication. Retained as a denormalized field to preserve the historical record at time of issuance, independent of workforce system changes.',
    `owner_role` STRING COMMENT 'Job title or functional role of the communication owner at the time of issuance (e.g., Program Director, Global Medical Monitor, Regulatory Affairs Lead). Supports accountability reporting and regulatory audit.',
    `priority_level` STRING COMMENT 'Business priority classification of the communication, used to drive escalation timelines and response SLAs. Critical communications (e.g., SAE notifications, program termination) require immediate action.. Valid values are `critical|high|medium|low`',
    `recipient_audience` STRING COMMENT 'The intended audience or stakeholder group to whom the communication is addressed. Drives distribution list management and regulatory filing obligations. [ENUM-REF-CANDIDATE',
    `recipient_names` STRING COMMENT 'Comma-separated list of named individuals or organizational units who received this communication. Supports audit trail and acknowledgement tracking. Classified as confidential due to business-sensitive stakeholder identity.',
    `regulatory_authority` STRING COMMENT 'The health authority to which this communication is directed or which it concerns (e.g., FDA, EMA, MHRA). Applicable for regulatory intelligence updates, IND/CTA submissions, and health authority meeting notifications.',
    `regulatory_submission_reference` STRING COMMENT 'The IND number, CTA number, or regulatory dossier reference associated with this communication when it relates to a regulatory submission or health authority interaction (e.g., IND 12345, EudraCT 2024-000123-45).',
    `response_date` DATE COMMENT 'The date on which a substantive response was received from the recipient. Enables turnaround time measurement for health authority interactions and sponsor feedback cycles.',
    `response_received` BOOLEAN COMMENT 'Indicates whether a substantive response (beyond simple acknowledgement) has been received from the recipient, such as a health authority query response, sponsor feedback, or governance committee decision.',
    `response_summary` STRING COMMENT 'Brief narrative summary of the substantive response received from the recipient (e.g., health authority feedback, sponsor approval, governance committee decision). Supports program transparency and follow-up action tracking.',
    `safety_event_reference` STRING COMMENT 'Cross-reference to the SAE, SUSAR, or safety signal case number in the source system when this communication is safety-related. Enables traceability between program communications and the pharmacovigilance system.',
    `source_system_record_reference` STRING COMMENT 'The native primary key or document ID of this communication record in the originating operational system (e.g., Siebel CTMS activity ID, Veeva Vault document number). Enables reverse traceability from the lakehouse to the system of record.',
    `subject_summary` STRING COMMENT 'Concise subject line or title summarizing the content and purpose of the communication. Used for search, indexing, and eTMF filing. Equivalent to the subject field in formal correspondence.',
    `tmf_zone` STRING COMMENT 'The TMF Reference Model zone and section under which this communication is filed in the eTMF (e.g., Zone 01 - Trial Management, Zone 05 - Regulatory). Ensures compliant document organization per ICH E6(R2) and the DIA TMF Reference Model.',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp at which this program communication record was most recently modified. Required for change audit trail under 21 CFR Part 11 and ALCOA+ data integrity principles in the Databricks Silver Layer.',
    CONSTRAINT pk_program_communication PRIMARY KEY(`program_communication_id`)
) COMMENT 'Transactional record for formal program-level communications issued to stakeholders including sponsors, health authorities, and internal leadership. Captures communication date, communication type (program update, milestone notification, risk escalation';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` (
    `competitive_intelligence_id` BIGINT COMMENT 'Unique surrogate identifier for each competitive intelligence record tracked at the program level.',
    `analyst_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Competitive intelligence analysts are named employees whose assignments are tracked for portfolio strategy reporting and workload management.',
    `clinical_program_id` BIGINT COMMENT 'Reference to the clinical development program for which this competitive intelligence entry is tracked.',
    `indication_id` BIGINT COMMENT 'Reference to the therapeutic indication for which competitive overlap is being assessed.',
    `pipeline_asset_id` BIGINT COMMENT 'Foreign key linking to sponsor.pipeline_asset. Business justification: Competitive intelligence entries are evaluated against the sponsors own pipeline asset in the same indication.',
    `superseded_competitive_intelligence_id` BIGINT COMMENT 'Self-referencing FK on competitive_intelligence (superseded_competitive_intelligence_id)',
    `approval_date` DATE COMMENT 'Date on which the competing asset received marketing authorization from the primary regulatory authority. Null if not yet approved.',
    `approved_regions` STRING COMMENT 'Comma-separated list of ISO 3166-1 alpha-3 country or region codes where the competing asset has received marketing authorization (e.g., USA, GBR, JPN, AUS). Informs global competitive landscape assessment.',
    `biomarker_strategy` STRING COMMENT 'Description of the competitors biomarker selection or companion diagnostic strategy (e.g., PD-L1 expression, BRCA mutation, HER2 amplification). Informs the programs own biomarker-driven development strategy and TPP.',
    `clinical_trial_registry_code` STRING COMMENT 'Public clinical trial registry identifier for the competitors pivotal or key study (e.g., ClinicalTrials.gov NCT number, EudraCT/EUCTR number). Enables direct cross-referencing with public trial data.. Valid values are `^(NCT|EUCTR|ISRCTN|JPRN|ACTRN)[0-9A-Z-]+$`',
    `commercial_threat_level` STRING COMMENT 'Assessment of the commercial threat level posed by this competitive asset.. Valid values are `critical|high|medium|low|negligible`',
    `competitor_asset_code` STRING COMMENT 'Internal development code or compound identifier for the competing asset (e.g., sponsor compound code, CAS number, or WHO INN code) as referenced in public registries.',
    `competitor_asset_name` STRING COMMENT 'Name of the competitor asset or product being tracked.',
    `competitor_company_name` STRING COMMENT 'Name of the competitor company developing this asset.',
    `confidence_level` STRING COMMENT 'Assessed confidence level in the accuracy and completeness of this competitive intelligence entry, based on source quality and corroboration. Informs how heavily the data is weighted in program strategy decisions.. Valid values are `confirmed|high|medium|low|unverified`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this competitive intelligence record was first created in the system. Supports ALCOA+ audit trail requirements and data lineage tracking per 21 CFR Part 11.',
    `data_readout_date` DATE COMMENT 'Anticipated or actual date of key clinical data readout (e.g., pivotal trial top-line results, interim analysis) for the competing asset. Critical for program timeline planning and go/no-go decision windows.',
    `development_phase` STRING COMMENT 'Current clinical development phase of the competing asset as of the last intelligence update. Drives urgency assessment and go/no-go decision-making. [ENUM-REF-CANDIDATE',
    `entry_code` STRING COMMENT 'Unique business identifier code assigned to this competitive intelligence record, used for cross-referencing in program strategy documents and Target Product Profile (TPP) reviews.. Valid values are `^CI-[A-Z0-9]{4,12}$`',
    `entry_status` STRING COMMENT 'Current lifecycle status of this competitive intelligence record. Active = current and valid; Archived = no longer relevant; Under Review = pending validation; Superseded = replaced by a newer entry.. Valid values are `active|archived|under_review|superseded`',
    `go_no_go_relevance_flag` BOOLEAN COMMENT 'Indicates whether this competitive intelligence entry has been flagged as directly relevant to a program-level go/no-go decision. When True, the entry must be reviewed by the program governance committee.',
    `indication_overlap_description` STRING COMMENT 'Narrative description of the degree and nature of therapeutic indication overlap between the competing asset and the programs investigational product. Supports TPP differentiation and regulatory strategy.',
    `indication_overlap_level` STRING COMMENT 'Categorical assessment of how closely the competitors target indication overlaps with the programs indication. Full = same patient population; Partial = overlapping subpopulation; Adjacent = related but distinct indication; None = no overlap.. Valid values are `full|partial|adjacent|none`',
    `intelligence_source_name` STRING COMMENT 'Specific name of the source from which this competitive intelligence was obtained (e.g., ASCO 2024 Annual Meeting, FDA Approval Letter, PubMed PMID 12345678, Bloomberg Intelligence Report). Supports traceability and ALCOA+ compliance.',
    `intelligence_source_type` STRING COMMENT 'Category of the primary source from which this competitive intelligence was obtained. Supports source credibility assessment and ALCOA+ data provenance tracking.',
    `intelligence_source_url` STRING COMMENT 'URL or hyperlink to the primary source document or registry entry from which this competitive intelligence was obtained. Enables direct verification and audit trail.',
    `key_differentiators` STRING COMMENT 'Narrative summary of the key clinical, safety, or commercial differentiators of the competing asset relative to the programs investigational product. Directly informs TPP refinement and go/no-go decision rationale.',
    `last_reviewed_date` DATE COMMENT 'Date on which this competitive intelligence entry was last reviewed and validated by the responsible program team member or competitive intelligence analyst.',
    `last_updated_date` DATE COMMENT 'Date on which the content of this competitive intelligence record was last substantively updated with new information. Distinct from last_reviewed_date (which may confirm no change).',
    `line_of_therapy` STRING COMMENT 'Treatment line for which the competing asset is being developed or approved. Informs competitive positioning and TPP refinement. [ENUM-REF-CANDIDATE: first_line|second_line|third_line_plus|maintenance|adjuvant|neoadjuvant|any — 7 candidates stripped',
    `mechanism_of_action` STRING COMMENT 'Pharmacological mechanism by which the competing asset exerts its therapeutic effect (e.g., PD-1 inhibitor, VEGFR antagonist, CAR-T). Informs differentiation strategy and Target Product Profile (TPP) refinement.',
    `modality` STRING COMMENT 'Drug modality classification of the competing asset. Supports differentiation analysis and portfolio positioning. [ENUM-REF-CANDIDATE: small_molecule|biologic|cell_therapy|gene_therapy|oligonucleotide|vaccine|other — promote to reference product]',
    `partnership_licensing_notes` STRING COMMENT 'Notes on partnership and licensing arrangements related to this competitive asset.',
    `pricing_reimbursement_notes` STRING COMMENT 'Notes on pricing and reimbursement strategy for this competitive asset.',
    `primary_endpoint_type` STRING COMMENT 'Type of primary clinical endpoint used in the competitors pivotal trial (e.g., Overall Survival, Progression-Free Survival, HbA1c reduction). Informs endpoint strategy and the source system the program.',
    `regulatory_designations` STRING COMMENT 'Special regulatory designations granted to the competing asset (e.g., Breakthrough Therapy, Fast Track, Orphan Drug, PRIME, Accelerated Approval). Informs competitive regulatory strategy.',
    `regulatory_status` STRING COMMENT 'Current regulatory status of the competing asset across major health authorities. Tracks IND/CTA filing, NDA/BLA/MAA submission, and approval status. [ENUM-REF-CANDIDATE',
    `regulatory_submission_date` DATE COMMENT 'Anticipated or actual date of NDA/BLA/MAA or equivalent regulatory submission for the competing asset. Informs program urgency and submission timeline strategy.',
    `review_frequency` STRING COMMENT 'Scheduled frequency at which this competitive intelligence entry should be reviewed and updated. Drives operational cadence for the competitive intelligence monitoring process.. Valid values are `weekly|monthly|quarterly|semi_annual|annual|ad_hoc`',
    `safety_profile_summary` STRING COMMENT 'Narrative summary of the known or reported safety and tolerability profile of the competing asset, including key adverse events (AEs) and serious adverse events (SAEs). Informs the programs risk-benefit assessment and DSMB charter.',
    `target_patient_population` STRING COMMENT 'Description of the patient population targeted by the competing asset (e.g., biomarker-selected, line of therapy, disease stage). Used to assess competitive differentiation in patient recruitment and market positioning.',
    `tpp_impact_assessment` STRING COMMENT 'Assessment of the impact this competitive asset may have on the target product profile.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this competitive intelligence record was last modified in the system. Supports ALCOA+ audit trail and change tracking per 21 CFR Part 11.',
    `veeva_vault_document_reference` STRING COMMENT 'Reference identifier for the associated competitive intelligence report or source document stored in Veeva Vault eTMF or quality management module. Enables direct document traceability.',
    CONSTRAINT pk_competitive_intelligence PRIMARY KEY(`competitive_intelligence_id`)
) COMMENT 'Master record for competitive intelligence entries tracked at the program level, capturing the competitive landscape for the therapeutic indication being developed.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`program`.`kri` (
    `kri_id` BIGINT COMMENT 'Unique surrogate identifier for the program-level Key Risk Indicator or Key Performance Indicator definition record. Primary key for this master resource entity.',
    `clinical_program_id` BIGINT COMMENT 'Reference to the clinical development program for which this KRI/KPI is defined. Links the indicator to its governing program portfolio context.',
    `indicator_owner_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: KRI ownership is assigned to named employees accountable for monitoring and reporting in risk-based oversight frameworks.',
    `obligation_id` BIGINT COMMENT 'Foreign key linking to compliance.obligation. Business justification: KRIs are defined to monitor compliance with specific regulatory obligations (e.g., KRI tracking enrollment rate against a pediatric obligation timeline).',
    `parent_kri_id` BIGINT COMMENT 'Self-referencing FK on kri (parent_kri_id)',
    `primary_previous_version_kri_id` BIGINT COMMENT 'Reference to the prior version of this KRI/KPI definition record, enabling a full version history chain for audit and regulatory inspection purposes.',
    `applicable_development_phase` STRING COMMENT 'The clinical development phase(s) for which this indicator definition is applicable (e.g., Phase_I, Phase_II, Phase_III, Phase_IV, all_phases). Allows phase-specific KRI/KPI frameworks within the same program.. Valid values are `Phase_I|Phase_II|Phase_III|Phase_IV|all_phases`',
    `applicable_therapeutic_area` STRING COMMENT 'The therapeutic area for which this indicator is specifically calibrated (e.g., Oncology, Neurology, Cardiovascular). Some KRI thresholds are disease-area specific. Null if the indicator applies universally across all therapeutic areas.',
    `approval_date` DATE COMMENT 'Date on which this KRI/KPI definition was formally approved by the designated approver. Marks the transition from draft to active status and is required for regulatory audit trail.',
    `approved_by` STRING COMMENT 'Name or user identifier of the individual who formally approved this KRI/KPI definition or its most recent version change. Required for electronic signature compliance under 21 CFR Part 11.',
    `benchmark_source` STRING COMMENT 'The source of the industry benchmark or historical baseline used to set the target and warning thresholds (e.g., TransCelerate Industry Benchmark 2023, Internal Historical Average 2020-2023, FDA Guidance, Sponsor SOPs).',
    `benchmark_value` DECIMAL(18,4) COMMENT 'The industry or historical benchmark value for this indicator against which the target threshold was calibrated. Enables comparison of program performance against external standards.',
    `capa_required_on_breach` BOOLEAN COMMENT 'Indicates whether a Corrective and Preventive Action (CAPA) must be initiated in MasterControl when this indicator breaches its critical threshold. Supports GCP compliance and quality management workflows.',
    `change_rationale` STRING COMMENT 'Business justification for the most recent change to this indicator definition, including threshold adjustments, metric redefinition, or ownership transfers. Required for audit trail completeness under 21 CFR Part 11 and ALCOA+.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this KRI/KPI definition record was first created in the system. Required for audit trail completeness under 21 CFR Part 11 and ALCOA+ principles.',
    `critical_threshold` DECIMAL(18,4) COMMENT 'The threshold value at which the indicator triggers a red alert, indicating a critical risk or performance failure requiring immediate escalation to program governance or sponsor. Drives CAPA initiation.',
    `data_source_object` STRING COMMENT 'The specific module, dataset, form, or table within the source system from which indicator data is extracted (e.g., AE Form in Medidata Rave, Case Safety Report in the source system Visit Tracking in the source system',
    `data_source_system` STRING COMMENT 'The operational system of record from which the raw data for this indicator is sourced (e.g., Medidata Rave, the source system the source system the source system data lineage tracing and source system reconciliation.',
    `dsmb_reportable` BOOLEAN COMMENT 'Indicates whether a critical threshold breach for this indicator must be reported to the Data Safety Monitoring Board (DSMB) or Data Monitoring Committee (DMC). Drives automated DSMB notification workflows.',
    `effective_end_date` DATE COMMENT 'The date on which this KRI/KPI definition is retired or superseded. Null for currently active indicators. Enables temporal versioning of the program monitoring framework.',
    `effective_start_date` DATE COMMENT 'The date from which this KRI/KPI definition becomes active and measurements begin. Supports versioning and historical comparison of indicator definitions over the program lifecycle.',
    `escalation_owner` STRING COMMENT 'Name or role of the individual or committee to whom a critical threshold breach is escalated (e.g., Program Steering Committee, DSMB, Sponsor Medical Monitor). Distinct from the indicator owner who manages routine monitoring.',
    `governance_committee` STRING COMMENT 'The governance body (e.g., Program Review Board, Portfolio Governance Committee, DSMB/DMC, Joint Steering Committee) in whose meetings this indicator is reviewed. Links the KRI/KPI to the appropriate oversight forum.',
    `indicator_category` STRING COMMENT 'Business domain category grouping this indicator for portfolio governance reporting (e.g., safety, data_quality, enrollment, site_performance, regulatory, supply_chain, finance, operational). Enables domain-level roll-up in governance dashboards.',
    `indicator_code` STRING COMMENT 'Unique business-facing alphanumeric code identifying this KRI/KPI definition within the program portfolio (e.g., PRG-KRI-001, PRG-KPI-042). Used as the externally-known identifier in governance reports and portfolio dashboards.. Valid values are `^[A-Z]{2,6}-[A-Z]{2,6}-[0-9]{3,6}$`',
    `indicator_name` STRING COMMENT 'Human-readable name of the KRI or KPI (e.g., Protocol Deviation Rate, Site Activation Cycle Time, SAE Reporting Compliance Rate). Used as the display label in governance meetings and portfolio reviews.',
    `indicator_status` STRING COMMENT 'Current lifecycle status of this KRI/KPI definition. draft = under development; active = in use for governance monitoring; suspended = temporarily paused; retired = no longer monitored; under_review = being reassessed for threshold or definition. Valid values are `draft|active|suspended|retired|under_review`',
    `indicator_subtype` STRING COMMENT 'Further classification within the indicator category (e.g., SAE Reporting under safety, Protocol Deviation under data_quality, Screen Failure Rate under enrollment). Provides granular segmentation for drill-down analytics.',
    `indicator_type` STRING COMMENT 'Classifies whether this indicator is a Key Risk Indicator (KRI) — measuring risk exposure — or a Key Performance Indicator (KPI) — measuring operational performance. Drives how thresholds are interpreted and escalated in governance.. Valid values are `KRI|KPI`',
    `is_critical_path` BOOLEAN COMMENT 'Indicates whether this indicator is on the critical path for program delivery milestones. Critical path KRIs/KPIs receive priority escalation and are featured in executive portfolio dashboards.',
    `is_regulatory_commitment` BOOLEAN COMMENT 'Indicates whether this KRI/KPI is a formal regulatory commitment to a health authority (e.g., FDA, EMA) as part of a Risk Management Plan, IND, or study protocol.',
    `is_safety_indicator` BOOLEAN COMMENT 'Indicates whether this indicator is classified as a safety-related KRI (e.g., SAE reporting timeliness, SUSAR submission compliance, AE data completeness). Safety indicators receive heightened governance scrutiny and may trigger DSMB notification.',
    `last_reviewed_date` DATE COMMENT 'Date on which this indicator definition was most recently reviewed by the governance committee or indicator owner, even if no changes were made. Supports periodic review compliance and governance cadence tracking.',
    `measurement_direction` STRING COMMENT 'Indicates whether a higher value is favorable (e.g., consent rate), a lower value is favorable (e.g., protocol deviation rate), or the value should remain within a target range. Governs how threshold breaches are evaluated in governance logic.. Valid values are `higher_is_better|lower_is_better|target_range`',
    `measurement_frequency` STRING COMMENT 'How often this indicator is measured and reported (e.g., daily, weekly, monthly, quarterly). Determines the cadence of data collection and governance review cycles.',
    `measurement_unit` STRING COMMENT 'Unit of measure for the indicator value (e.g., percentage, days, count, rate per 100 patient-years, USD). Required for correct threshold interpretation and cross-program comparability.',
    `metric_definition` STRING COMMENT 'Precise business definition of what this indicator measures, including the numerator and denominator logic where applicable (e.g., Number of SAEs reported within 24 hours divided by total SAEs reported in the period, expressed as a percentage).',
    `reporting_period_type` STRING COMMENT 'Defines whether the indicator is measured over a rolling window (e.g., last 30 days), cumulatively from study start, at a specific point in time, or study-to-date. Critical for consistent interpretation of computed values.. Valid values are `rolling|cumulative|point_in_time|study_to_date`',
    `responsible_function` STRING COMMENT 'The organizational function or department accountable for monitoring and responding to this indicator (e.g., Clinical Operations, Biostatistics, Pharmacovigilance, Data Management, Regulatory Affairs).',
    `review_cycle` STRING COMMENT 'Frequency at which the indicator definition itself (thresholds, metric definition, ownership) is formally reviewed and potentially updated by the governance committee. Distinct from measurement_frequency which governs data collection cadence.. Valid values are `monthly|quarterly|semi_annual|annual|per_governance_meeting`',
    `source_system_record_reference` STRING COMMENT 'The native identifier of this KRI/KPI record in the originating source system (e.g., CTMS indicator ID, MasterControl document number). Enables bidirectional reconciliation between the lakehouse silver layer and operational systems.',
    `target_threshold` DECIMAL(18,4) COMMENT 'The desired or optimal value for this indicator representing expected performance under normal operating conditions. Serves as the baseline against which warning and critical thresholds are calibrated.',
    `threshold_operator` STRING COMMENT 'Logical operator defining how the measured value is compared to the warning and critical thresholds (e.g., gt = greater than triggers alert, lt = less than triggers alert, between = value must remain within a range).. Valid values are `gt|lt|gte|lte|eq|between`',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time when this KRI/KPI definition record was most recently modified. Required for change tracking and audit trail under 21 CFR Part 11 and ALCOA+ principles.',
    `version_number` STRING COMMENT 'Version identifier for this KRI/KPI definition (e.g., 1.0, 2.1). Incremented when metric definition, thresholds, or ownership changes are approved. Supports audit trail and regulatory inspection readiness.. Valid values are `^[0-9]+.[0-9]+$`',
    `warning_threshold` DECIMAL(18,4) COMMENT 'The threshold value at which the indicator triggers a yellow/amber alert, indicating early risk signal requiring heightened monitoring or investigation. Distinct from the critical threshold which triggers escalation.',
    CONSTRAINT pk_kri PRIMARY KEY(`kri_id`)
) COMMENT 'Master record defining Key Risk Indicators (KRIs) and Key Performance Indicators (KPIs) monitored at the program level for portfolio governance. Captures indicator name, indicator type (KRI or KPI), metric definition, measurement unit, target threshold';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`program`.`kri_reading` (
    `kri_reading_id` BIGINT COMMENT 'Unique surrogate identifier for each periodic KRI/KPI reading record captured at the program level. Serves as the primary key for this transactional observation event.',
    `clinical_program_id` BIGINT COMMENT 'Reference to the clinical development program for which this KRI reading was captured. Links the observation to the governing program entity.',
    `employee_id` BIGINT COMMENT 'Identifier of the user (program lead, medical monitor, or governance committee chair) who formally confirmed and accepted this KRI reading. Required for electronic signature compliance under 21 CFR Part 11 when reading_status transitions to confirmed.',
    `governance_meeting_id` BIGINT COMMENT 'Reference to the governance committee meeting (e.g., DSMB, PMC, Portfolio Review) during which this KRI reading was formally reviewed. Nullable when readings are generated outside a formal meeting cycle.',
    `kri_id` BIGINT COMMENT 'Reference to the KRI/KPI definition record that specifies the metric name, threshold configuration, and measurement methodology for this reading. Ensures each reading is traceable to its governing definition.',
    `primary_superseded_by_reading_kri_reading_id` BIGINT COMMENT 'Reference to the corrected KRI reading record that supersedes this one when reading_status is superseded. Enables full audit chain reconstruction for regulatory inspection, ensuring the history of corrections is traceable per ALCOA+ and 21 CFR Part 11',
    `action_required_flag` BOOLEAN COMMENT 'Indicates whether this KRI reading requires a documented corrective or mitigation action. True = a CAPA or risk mitigation action must be initiated; False = no action required beyond continued monitoring.',
    `amber_threshold_lower` DECIMAL(18,6) COMMENT 'The lower boundary of the caution (amber) performance range for this KRI at the time of reading. Values within the amber band trigger heightened monitoring and management attention without requiring immediate escalation.',
    `amber_threshold_upper` DECIMAL(18,6) COMMENT 'The upper boundary of the caution (amber) performance range for this KRI at the time of reading. Denormalized from the KRI definition to preserve the threshold configuration in effect at reading time.',
    `capa_reference` STRING COMMENT 'Reference identifier of the CAPA record initiated in response to this KRI threshold breach. Links the reading to the formal quality management response tracked in MasterControl. Null when no CAPA has been initiated.',
    `computation_method` STRING COMMENT 'Indicates whether the observed value was computed automatically by an analytics pipeline, entered manually by a data manager or CRA, or produced through a semi-automated process requiring human validation.. Valid values are `automated|manual|semi_automated`',
    `confirmed_timestamp` TIMESTAMP COMMENT 'The date and time at which this KRI reading was formally confirmed by the governance reviewer. Represents a distinct lifecycle event timestamp required for 21 CFR Part 11 electronic records compliance and audit trail completeness.',
    `consecutive_breach_count` BIGINT COMMENT 'Number of consecutive review cycles (including the current one) during which this KRI has been in amber or red status. Used by governance committees to assess persistence of risk signals and trigger escalation protocols when a defined breach duration',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time at which this KRI reading record was first created in the system. Serves as the audit creation timestamp for 21 CFR Part 11 electronic records compliance and data lineage tracking.',
    `data_quality_flag` BOOLEAN COMMENT 'Indicates whether a data quality concern was identified with the underlying source data used to compute this reading (e.g., incomplete EDC data, site data not yet reconciled, known system outage).',
    `data_quality_note` STRING COMMENT 'Free-text description of the specific data quality issue identified when data_quality_flag is True. Documents the nature of the concern (e.g., Site 007 data not yet entered in EDC, CTMS extract delayed by 3 days) to support audit review and reading',
    `data_snapshot_reference` STRING COMMENT 'Identifier or version label of the source data snapshot used to compute this KRI reading (e.g., EDC data extract version, CTMS report run ID, database lock reference).',
    `denominator_value` DECIMAL(18,6) COMMENT 'The denominator used in computing a rate or percentage KRI (e.g., total enrolled subjects for a protocol deviation rate, total expected visits for a visit completion rate).',
    `escalation_flag` BOOLEAN COMMENT 'Indicates whether this KRI reading has triggered a formal escalation to senior management, the sponsor, or a regulatory body based on threshold breach severity or consecutive breach count. True = escalation initiated; False = no escalation required.',
    `escalation_level` STRING COMMENT 'The organizational level to which this KRI reading has been escalated when escalation_flag is True. Determines the appropriate response protocol and notification recipients. Null when no escalation is required.. Valid values are `program_lead|medical_monitor|sponsor|dsmb|regulatory_authority`',
    `green_threshold_lower` DECIMAL(18,6) COMMENT 'The lower boundary of the acceptable (green) performance range for this KRI at the time of reading. Denormalized from the KRI definition to preserve the threshold configuration that was in effect at the time of this specific reading, supporting historical',
    `green_threshold_upper` DECIMAL(18,6) COMMENT 'The upper boundary of the acceptable (green) performance range for this KRI at the time of reading. Denormalized from the KRI definition to preserve the threshold configuration in effect at reading time.',
    `kri_category` STRING COMMENT 'High-level domain category classifying the KRI for portfolio-level aggregation and governance reporting. Enables committee members to filter and group indicators by risk domain.',
    `numerator_value` DECIMAL(18,6) COMMENT 'The numerator used in computing a rate or percentage KRI (e.g., number of protocol deviations, number of completed visits). Stored alongside the denominator to enable independent verification of the observed_value and full audit traceability per ALCOA+',
    `observed_value` DECIMAL(18,6) COMMENT 'The raw numeric value of the KRI/KPI as measured at the reading date. This is the principal quantitative fact of the observation event (e.g., 0.85 for 85% enrollment rate, 3.2 for 3.2 days average SAE reporting lag).',
    `prior_reading_value` DECIMAL(18,6) COMMENT 'The observed value from the immediately preceding review cycle for this KRI. Stored on the current reading record to enable direct trend comparison without requiring a self-join, supporting governance committee dashboards and period-over-period analysis.',
    `reading_date` DATE COMMENT 'The calendar date on which this KRI observation was captured or the data snapshot was taken. Represents the principal business event date for this measurement, distinct from the record creation timestamp.',
    `reading_reference_code` STRING COMMENT 'Human-readable business identifier for this KRI reading event, typically formatted as KRI-RDG-{PROGRAM_CODE}-{YYYYMMDD}. Used in governance reports, dashboards, and audit trails to uniquely reference a specific reading without exposing the surrogate key.. Valid values are `^KRI-RDG-[A-Z0-9]{4,20}-[0-9]{8}$`',
    `reading_status` STRING COMMENT 'Lifecycle status of this KRI reading record. draft = computed but not yet reviewed; under_review = submitted for governance committee review; confirmed = formally accepted by the governance body; superseded = replaced by a corrected reading. Valid values are `draft|under_review|confirmed|superseded|voided`',
    `review_cycle_period` STRING COMMENT 'The governance review period this reading belongs to, expressed as a standardized period label (e.g., 2024-Q1, 2024-W23, 2024-03). Enables time-series alignment across multiple KRIs within the same review cycle for governance committee reporting.',
    `review_cycle_type` STRING COMMENT 'Frequency classification of the review cycle during which this reading was generated. Determines the expected cadence for trend analysis and threshold breach escalation.. Valid values are `weekly|monthly|quarterly|ad_hoc|milestone_triggered`',
    `reviewer_commentary` STRING COMMENT 'Free-text narrative commentary provided by the governance committee reviewer or program lead explaining the context of the observed value, root cause of any threshold breach, mitigating factors, or planned actions. Captured at the time of formal review.',
    `target_value` DECIMAL(18,6) COMMENT 'The planned or aspirational target value for this KRI in the current review cycle, as defined in the program plan or Statistical Analysis Plan (the source system). Distinct from threshold boundaries — represents the desired performance level, enabling',
    `threshold_status` STRING COMMENT 'Red-Amber-Green (RAG) status classification of the observed value against the defined thresholds at the time of reading. green = within acceptable range; amber = caution zone requiring heightened monitoring; red = threshold breached requiring. Valid values are `green|amber|red|not_applicable|data_unavailable`',
    `trend_direction` STRING COMMENT 'Directional trend classification comparing the current observed value to the prior period reading. improving = moving toward green; worsening = moving toward or deeper into red; stable = no material change; insufficient_data = fewer than two data. Valid values are `improving|stable|worsening|insufficient_data|new_metric`',
    `trend_magnitude` DECIMAL(18,6) COMMENT 'The absolute numeric change between the current observed_value and the prior_reading_value, expressed in the same unit_of_measure. Positive values indicate increase; negative values indicate decrease.',
    `unit_of_measure` STRING COMMENT 'The unit in which the observed_value is expressed (e.g., percentage, days, count, rate_per_site, ratio). Essential for correct interpretation of the numeric reading across heterogeneous KRI types.',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time at which this KRI reading record was most recently modified. Required for audit trail completeness under 21 CFR Part 11 and ALCOA+ principles. Updated on any field change including status transitions and commentary additions.',
    `variance_from_target` DECIMAL(18,6) COMMENT 'The arithmetic difference between the observed_value and the target_value (observed minus target). Negative values indicate underperformance; positive values indicate overperformance relative to target.',
    CONSTRAINT pk_kri_reading PRIMARY KEY(`kri_reading_id`)
) COMMENT 'Transactional record capturing periodic observed readings of program-level KRIs and KPIs against their defined thresholds. Captures the KRI reference, reading date, observed value, threshold status (green/amber/red), trend direction, data source snapshot';

ALTER SCHEMA `clinical_trials_ecm`.`program` SET TAGS ('dbx_division' = 'business');

ALTER SCHEMA `clinical_trials_ecm`.`program` SET TAGS ('dbx_domain' = 'program');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ADD CONSTRAINT `fk_program_clinical_program_indication_id` FOREIGN KEY (`indication_id`) REFERENCES `clinical_trials_ecm`.`program`.`indication`(`indication_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ADD CONSTRAINT `fk_program_clinical_program_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ADD CONSTRAINT `fk_program_clinical_program_parent_clinical_program_id` FOREIGN KEY (`parent_clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ADD CONSTRAINT `fk_program_clinical_program_pipeline_asset_id` FOREIGN KEY (`pipeline_asset_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`pipeline_asset`(`pipeline_asset_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ADD CONSTRAINT `fk_program_clinical_program_therapeutic_area_id` FOREIGN KEY (`therapeutic_area_id`) REFERENCES `clinical_trials_ecm`.`program`.`therapeutic_area`(`therapeutic_area_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` SET TAGS ('dbx_domain' = 'program');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` SET TAGS ('dbx_subdomain' = 'portfolio_management');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `indication_id` SET TAGS ('dbx_business_glossary_term' = 'Indication Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Organization ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `parent_clinical_program_id` SET TAGS ('dbx_self_ref_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `pipeline_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Pipeline Asset Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `therapeutic_area_id` SET TAGS ('dbx_business_glossary_term' = 'Therapeutic Area Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `actual_end_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Clinical Program End Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `breakthrough_therapy_designation` SET TAGS ('dbx_business_glossary_term' = 'FDA Breakthrough Therapy Designation Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `budget_currency` SET TAGS ('dbx_business_glossary_term' = 'Budget Currency Code');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `budget_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `development_phase` SET TAGS ('dbx_business_glossary_term' = 'Clinical Development Phase');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `development_phase` SET TAGS ('dbx_value_regex' = 'Phase I|Phase I/II|Phase II|Phase II/III|Phase III|Phase IV');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `dsmb_required` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Required Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `fast_track_designation` SET TAGS ('dbx_business_glossary_term' = 'FDA Fast Track Designation Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `global_study_count` SET TAGS ('dbx_business_glossary_term' = 'Total Global Study Count');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `modality` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product Modality');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `orphan_drug_designation` SET TAGS ('dbx_business_glossary_term' = 'Orphan Drug Designation Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `pediatric_investigation_plan` SET TAGS ('dbx_business_glossary_term' = 'Pediatric Investigation Plan (PIP) Required Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `portfolio_priority` SET TAGS ('dbx_value_regex' = 'Critical|High|Medium|Low');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `prime_designation` SET TAGS ('dbx_business_glossary_term' = 'EMA PRIority MEdicines (PRIME) Designation Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `program_budget` SET TAGS ('dbx_business_glossary_term' = 'Clinical Program Total Budget');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `program_budget` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `program_code` SET TAGS ('dbx_business_glossary_term' = 'Clinical Program Code');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `program_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{2,20}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `program_name` SET TAGS ('dbx_business_glossary_term' = 'Clinical Program Name');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `program_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `program_short_name` SET TAGS ('dbx_business_glossary_term' = 'Clinical Program Short Name');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `program_short_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `program_start_date` SET TAGS ('dbx_business_glossary_term' = 'Clinical Program Start Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `program_status` SET TAGS ('dbx_business_glossary_term' = 'Clinical Program Status');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `program_status` SET TAGS ('dbx_value_regex' = 'Active|On Hold|Completed|Terminated|Planning');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `program_type` SET TAGS ('dbx_business_glossary_term' = 'Clinical Program Type');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `projected_end_date` SET TAGS ('dbx_business_glossary_term' = 'Projected Clinical Program End Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `record_version` SET TAGS ('dbx_business_glossary_term' = 'Record Version Number');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `regulatory_strategy_summary` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `target_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Target Regulatory Submission Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `target_submission_type` SET TAGS ('dbx_business_glossary_term' = 'Target Regulatory Submission Type');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `target_submission_type` SET TAGS ('dbx_value_regex' = 'NDA|BLA|MAA|sNDA|sBLA|sMAA|510(k)|PMA');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `termination_reason` SET TAGS ('dbx_business_glossary_term' = 'Program Termination Reason');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`clinical_program` ALTER COLUMN `wbs_code` SET TAGS ('dbx_business_glossary_term' = 'Work Breakdown Structure (WBS) Code');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ADD CONSTRAINT `fk_program_program_development_milestone_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ADD CONSTRAINT `fk_program_program_development_milestone_owner_employee_id` FOREIGN KEY (`owner_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ADD CONSTRAINT `fk_program_program_development_milestone_primary_program_development_milestone_id` FOREIGN KEY (`primary_program_development_milestone_id`) REFERENCES `clinical_trials_ecm`.`program`.`program_development_milestone`(`program_development_milestone_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ADD CONSTRAINT `fk_program_program_development_milestone_study_milestone_id` FOREIGN KEY (`study_milestone_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_milestone`(`study_milestone_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` SET TAGS ('dbx_domain' = 'program');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` SET TAGS ('dbx_subdomain' = 'portfolio_management');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` SET TAGS ('dbx_cross_domain_duplicate_resolution' = 'distinct');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` SET TAGS ('dbx_canonical_owner' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` SET TAGS ('dbx_milestone_scope' = 'program');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` SET TAGS ('dbx_distinct_concept' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `owner_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Milestone Owner Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `owner_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `owner_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `primary_program_development_milestone_id` SET TAGS ('dbx_business_glossary_term' = 'Predecessor Milestone ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `actual_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Milestone Achievement Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `baseline_date` SET TAGS ('dbx_business_glossary_term' = 'Baseline Milestone Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `completion_percentage` SET TAGS ('dbx_business_glossary_term' = 'Milestone Completion Percentage');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `completion_percentage` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `dependency_type` SET TAGS ('dbx_business_glossary_term' = 'Milestone Dependency Type');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `dependency_type` SET TAGS ('dbx_value_regex' = 'finish_to_start|start_to_start|finish_to_finish|start_to_finish');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `evidence_document_ref` SET TAGS ('dbx_business_glossary_term' = 'Evidence Document Reference');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `forecast_date` SET TAGS ('dbx_business_glossary_term' = 'Forecast Milestone Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `go_no_go_date` SET TAGS ('dbx_business_glossary_term' = 'Go/No-Go Decision Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `go_no_go_decision` SET TAGS ('dbx_business_glossary_term' = 'Go/No-Go Decision');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `go_no_go_decision` SET TAGS ('dbx_value_regex' = 'go|no_go|conditional_go|deferred|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `governing_phase` SET TAGS ('dbx_business_glossary_term' = 'Governing Clinical Phase');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `is_active` SET TAGS ('dbx_business_glossary_term' = 'Active Record Indicator');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `is_critical_path` SET TAGS ('dbx_business_glossary_term' = 'Critical Path Indicator');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `is_regulatory_commitment` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Commitment Indicator');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `milestone_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{2,30}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `milestone_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `milestone_status` SET TAGS ('dbx_value_regex' = 'pending|achieved|delayed|at_risk|cancelled');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `milestone_type` SET TAGS ('dbx_value_regex' = 'regulatory|clinical_phase|decision_gate|data_readout|submission|approval');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `planned_date` SET TAGS ('dbx_business_glossary_term' = 'Planned Milestone Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `priority_level` SET TAGS ('dbx_business_glossary_term' = 'Milestone Priority Level');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `priority_level` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `record_version` SET TAGS ('dbx_business_glossary_term' = 'Record Version Number');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `review_cycle` SET TAGS ('dbx_value_regex' = 'weekly|bi_weekly|monthly|quarterly|ad_hoc');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Milestone Risk Rating');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `risk_rating` SET TAGS ('dbx_value_regex' = 'high|medium|low|not_assessed');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `schedule_variance_days` SET TAGS ('dbx_business_glossary_term' = 'Schedule Variance (Days)');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `source_system_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `subtype` SET TAGS ('dbx_business_glossary_term' = 'Milestone Subtype');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `tmf_zone` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Zone');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_development_milestone` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ADD CONSTRAINT `fk_program_program_study_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ADD CONSTRAINT `fk_program_program_study_dependent_program_study_id` FOREIGN KEY (`dependent_program_study_id`) REFERENCES `clinical_trials_ecm`.`program`.`program_study`(`program_study_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ADD CONSTRAINT `fk_program_program_study_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` SET TAGS ('dbx_domain' = 'program');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` SET TAGS ('dbx_subdomain' = 'portfolio_management');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `program_study_id` SET TAGS ('dbx_business_glossary_term' = 'Program Study Association ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Development Program ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `dependent_program_study_id` SET TAGS ('dbx_self_ref_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `actual_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Study Completion Date Within Program');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `actual_start_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Study Start Date Within Program');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Governance Approval Authority');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `association_code` SET TAGS ('dbx_business_glossary_term' = 'Program-Study Association Code');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `association_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{3,30}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `association_status` SET TAGS ('dbx_business_glossary_term' = 'Program-Study Association Status');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `association_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|removed|suspended');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `cross_study_dependency` SET TAGS ('dbx_business_glossary_term' = 'Cross-Study Dependency Description');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `csr_submission_date` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study Report (CSR) Submission Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `ctd_module_reference` SET TAGS ('dbx_business_glossary_term' = 'Common Technical Document (CTD) Module Reference');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `ctd_module_reference` SET TAGS ('dbx_value_regex' = '^M[2-5](.[0-9]+)*$');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `data_readout_date` SET TAGS ('dbx_business_glossary_term' = 'Study Data Readout Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `eudract_number` SET TAGS ('dbx_business_glossary_term' = 'EudraCT (European Union Drug Regulating Authorities Clinical Trials) Number');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `eudract_number` SET TAGS ('dbx_value_regex' = '^[0-9]{4}-[0-9]{6}-[0-9]{2}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `eudract_number` SET TAGS ('dbx_standard_ref' = 'USDM.StudyIdentifier.text');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `geographic_scope` SET TAGS ('dbx_business_glossary_term' = 'Study Geographic Scope');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `governance_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Program Governance Approval Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `ind_number` SET TAGS ('dbx_business_glossary_term' = 'Investigational New Drug (IND) Application Number');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `ind_number` SET TAGS ('dbx_value_regex' = '^[0-9]{5,6}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `ind_number` SET TAGS ('dbx_standard_ref' = 'USDM.StudyIdentifier.text');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `indication_meddra_code` SET TAGS ('dbx_business_glossary_term' = 'Indication MedDRA (Medical Dictionary for Regulatory Activities) Code');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `indication_meddra_code` SET TAGS ('dbx_value_regex' = '^[0-9]{8}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `indication_meddra_code` SET TAGS ('dbx_standard_ref' = 'MedDRA.PT.ptcode');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `is_gcp_compliant` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Compliance Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `is_registrational` SET TAGS ('dbx_business_glossary_term' = 'Registrational Study Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `nct_number` SET TAGS ('dbx_business_glossary_term' = 'ClinicalTrials.gov NCT Number');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `nct_number` SET TAGS ('dbx_value_regex' = '^NCT[0-9]{8}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `nct_number` SET TAGS ('dbx_standard_ref' = 'USDM.StudyIdentifier.text');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Program-Study Association Notes');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `phase` SET TAGS ('dbx_business_glossary_term' = 'Clinical Development Phase');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `phase` SET TAGS ('dbx_value_regex' = 'Phase I|Phase I/II|Phase II|Phase IIa|Phase IIb|Phase III');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `phase` SET TAGS ('dbx_standard_ref' = 'CDISC.CT.C66737');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `planned_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Planned Study Completion Date Within Program');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `planned_start_date` SET TAGS ('dbx_business_glossary_term' = 'Planned Study Start Date Within Program');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `population_type` SET TAGS ('dbx_business_glossary_term' = 'Study Population Type');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `population_type` SET TAGS ('dbx_value_regex' = 'adult|pediatric|geriatric|special_population|all_ages');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `portfolio_priority` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Priority Level');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `portfolio_priority` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `primary_endpoint_category` SET TAGS ('dbx_value_regex' = 'efficacy|safety|PK/PD|biomarker|quality_of_life|other');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `regulatory_dossier_contribution` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Dossier Contribution Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `removal_reason` SET TAGS ('dbx_business_glossary_term' = 'Study Removal Reason');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `removed_from_program_date` SET TAGS ('dbx_business_glossary_term' = 'Study Removed from Program Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Study Sequence Number Within Program');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `shared_dsmb_flag` SET TAGS ('dbx_business_glossary_term' = 'Shared Data Safety Monitoring Board (DSMB) Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `shared_sap_flag` SET TAGS ('dbx_business_glossary_term' = 'Shared Statistical Analysis Plan (SAP) Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `sponsor_protocol_number` SET TAGS ('dbx_standard_ref' = 'USDM.StudyIdentifier.text');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `study_role` SET TAGS ('dbx_business_glossary_term' = 'Study Role Within Program');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `study_role` SET TAGS ('dbx_value_regex' = 'pivotal|supportive|exploratory|bridging|PK/PD');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_study` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ADD CONSTRAINT `fk_program_indication_parent_indication_id` FOREIGN KEY (`parent_indication_id`) REFERENCES `clinical_trials_ecm`.`program`.`indication`(`indication_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ADD CONSTRAINT `fk_program_indication_primary_superseded_by_indication_id` FOREIGN KEY (`primary_superseded_by_indication_id`) REFERENCES `clinical_trials_ecm`.`program`.`indication`(`indication_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ADD CONSTRAINT `fk_program_indication_therapeutic_area_id` FOREIGN KEY (`therapeutic_area_id`) REFERENCES `clinical_trials_ecm`.`program`.`therapeutic_area`(`therapeutic_area_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` SET TAGS ('dbx_domain' = 'program');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` SET TAGS ('dbx_subdomain' = 'portfolio_management');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `parent_indication_id` SET TAGS ('dbx_self_ref_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `primary_superseded_by_indication_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Indication ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `therapeutic_area_id` SET TAGS ('dbx_business_glossary_term' = 'Therapeutic Area Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `accelerated_approval_flag` SET TAGS ('dbx_business_glossary_term' = 'Accelerated Approval Pathway Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `approved_regions` SET TAGS ('dbx_business_glossary_term' = 'Approved Regulatory Regions');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `biomarker_driven_flag` SET TAGS ('dbx_business_glossary_term' = 'Biomarker-Driven Indication Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `breakthrough_therapy_flag` SET TAGS ('dbx_business_glossary_term' = 'Breakthrough Therapy Designation Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `indication_code` SET TAGS ('dbx_value_regex' = '^IND-[A-Z0-9]{4,12}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `companion_diagnostic_required` SET TAGS ('dbx_business_glossary_term' = 'Companion Diagnostic Required Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `cta_filed_flag` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization (CTA) Filed Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `ctcae_version` SET TAGS ('dbx_business_glossary_term' = 'Common Terminology Criteria for Adverse Events (CTCAE) Version');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `ctcae_version` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `ctcae_version` SET TAGS ('dbx_standard_ref' = 'CTCAE.version');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `development_phase` SET TAGS ('dbx_value_regex' = 'preclinical|phase_1|phase_2|phase_3|phase_4|approved');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `disease_stage` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Indication Effective End Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Indication Effective Start Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `fast_track_flag` SET TAGS ('dbx_business_glossary_term' = 'Fast Track Designation Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `first_approval_date` SET TAGS ('dbx_business_glossary_term' = 'First Regulatory Approval Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `first_in_human_date` SET TAGS ('dbx_business_glossary_term' = 'First-in-Human (FIH) Study Start Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `icd10_code` SET TAGS ('dbx_business_glossary_term' = 'International Classification of Diseases 10th Revision (ICD-10) Code');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `icd10_code` SET TAGS ('dbx_value_regex' = '^[A-Z][0-9]{2}(.[0-9A-Z]{1,4})?$');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `icd10_code` SET TAGS ('dbx_standard_ref' = 'ICD10.code');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `icd11_code` SET TAGS ('dbx_business_glossary_term' = 'International Classification of Diseases 11th Revision (ICD-11) Code');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `icd11_code` SET TAGS ('dbx_value_regex' = '^[A-Z][A-Z0-9]{1,5}(.[A-Z0-9]{1,5})?$');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `icd11_code` SET TAGS ('dbx_standard_ref' = 'ICD11.code');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `ind_filed_flag` SET TAGS ('dbx_business_glossary_term' = 'Investigational New Drug (IND) Application Filed Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `is_orphan_disease` SET TAGS ('dbx_business_glossary_term' = 'Orphan Disease Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `is_pediatric_indication` SET TAGS ('dbx_business_glossary_term' = 'Pediatric Indication Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `meddra_pt_code` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) Preferred Term (PT) Code');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `meddra_pt_code` SET TAGS ('dbx_value_regex' = '^[0-9]{8}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `meddra_pt_code` SET TAGS ('dbx_standard_ref' = 'MedDRA.PT.ptcode');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `meddra_pt_name` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) Preferred Term (PT) Name');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `meddra_pt_name` SET TAGS ('dbx_standard_ref' = 'MedDRA.PT.ptname');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `meddra_pt_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `meddra_soc_code` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) System Organ Class (SOC) Code');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `meddra_soc_code` SET TAGS ('dbx_value_regex' = '^[0-9]{8}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `meddra_soc_code` SET TAGS ('dbx_standard_ref' = 'MedDRA.SOC.soccode');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `meddra_soc_name` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) System Organ Class (SOC) Name');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `meddra_soc_name` SET TAGS ('dbx_standard_ref' = 'MedDRA.SOC.socname');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `meddra_soc_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `meddra_version` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) Version');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `meddra_version` SET TAGS ('dbx_value_regex' = '^[0-9]{1,2}.[0-9]{1}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `meddra_version` SET TAGS ('dbx_standard_ref' = 'MedDRA.version');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `indication_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `orphan_designation_number` SET TAGS ('dbx_business_glossary_term' = 'Orphan Drug Designation Number');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `patient_population_description` SET TAGS ('dbx_business_glossary_term' = 'Target Patient Population Description');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `prevalence_population_region` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `short_name` SET TAGS ('dbx_business_glossary_term' = 'Indication Short Name');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `short_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `indication_status` SET TAGS ('dbx_value_regex' = 'active|retired|under_review|pending_approval');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `taxonomy_version` SET TAGS ('dbx_business_glossary_term' = 'Indication Taxonomy Version');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `taxonomy_version` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `unmet_medical_need_level` SET TAGS ('dbx_value_regex' = 'high|moderate|low|not_assessed');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `unmet_medical_need_level` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `unmet_medical_need_level` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `unmet_medical_need_level` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`indication` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ADD CONSTRAINT `fk_program_therapeutic_area_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ADD CONSTRAINT `fk_program_therapeutic_area_parent_therapeutic_area_id` FOREIGN KEY (`parent_therapeutic_area_id`) REFERENCES `clinical_trials_ecm`.`program`.`therapeutic_area`(`therapeutic_area_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` SET TAGS ('dbx_domain' = 'program');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` SET TAGS ('dbx_subdomain' = 'portfolio_management');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `abbreviation` SET TAGS ('dbx_business_glossary_term' = 'Therapeutic Area Abbreviation');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `abbreviation` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,10}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `applicable_gcp_guideline` SET TAGS ('dbx_business_glossary_term' = 'Applicable Good Clinical Practice (GCP) Guideline');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `cdisc_ta_standard` SET TAGS ('dbx_business_glossary_term' = 'Clinical Data Interchange Standards Consortium (CDISC) Therapeutic Area (TA) Standard');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `cdisc_ta_standard` SET TAGS ('dbx_standard_ref' = 'CDISC.TAUG');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `therapeutic_area_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{2,20}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `competitive_landscape_summary` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `ctms_ta_code` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Therapeutic Area Code');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `data_privacy_classification` SET TAGS ('dbx_value_regex' = 'standard|sensitive|highly_sensitive');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `edc_ta_identifier` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) Therapeutic Area Identifier');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `hierarchy_level` SET TAGS ('dbx_business_glossary_term' = 'Therapeutic Area Hierarchy Level');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `hierarchy_path` SET TAGS ('dbx_business_glossary_term' = 'Therapeutic Area Hierarchy Path');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `icd11_code` SET TAGS ('dbx_business_glossary_term' = 'International Classification of Diseases 11th Revision (ICD-11) Code');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `icd11_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{1,7}(.[A-Z0-9]{1,6})?$');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `icd11_code` SET TAGS ('dbx_standard_ref' = 'ICD11.code');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `is_oncology` SET TAGS ('dbx_business_glossary_term' = 'Oncology Indicator');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `is_rare_disease` SET TAGS ('dbx_business_glossary_term' = 'Rare Disease Indicator');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `meddra_soc_code` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) System Organ Class (SOC) Code');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `meddra_soc_code` SET TAGS ('dbx_value_regex' = '^[0-9]{8}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `meddra_soc_code` SET TAGS ('dbx_standard_ref' = 'MedDRA.SOC.soccode');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `meddra_soc_name` SET TAGS ('dbx_business_glossary_term' = 'Medical Dictionary for Regulatory Activities (MedDRA) System Organ Class (SOC) Name');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `meddra_soc_name` SET TAGS ('dbx_standard_ref' = 'MedDRA.SOC.socname');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `meddra_soc_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `therapeutic_area_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `patient_population_type` SET TAGS ('dbx_value_regex' = 'adult|pediatric|geriatric|mixed|neonatal');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `portfolio_priority_tier` SET TAGS ('dbx_value_regex' = 'tier_1|tier_2|tier_3|not_prioritized');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `primary_regulatory_agency` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `safety_system_ta_code` SET TAGS ('dbx_business_glossary_term' = 'Safety System Therapeutic Area Code');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `therapeutic_area_status` SET TAGS ('dbx_value_regex' = 'active|inactive|deprecated|under_review');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `typical_trial_phase` SET TAGS ('dbx_value_regex' = 'Phase I|Phase II|Phase III|Phase IV|Phase I/II|Phase II/III');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `unmet_medical_need_level` SET TAGS ('dbx_value_regex' = 'high|moderate|low|not_assessed');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `unmet_medical_need_level` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `unmet_medical_need_level` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `unmet_medical_need_level` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Therapeutic Area Taxonomy Version Number');

ALTER TABLE `clinical_trials_ecm`.`program`.`therapeutic_area` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^d+.d+(.d+)?$');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ADD CONSTRAINT `fk_program_program_strategic_plan_author_employee_id` FOREIGN KEY (`author_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ADD CONSTRAINT `fk_program_program_strategic_plan_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ADD CONSTRAINT `fk_program_program_strategic_plan_indication_id` FOREIGN KEY (`indication_id`) REFERENCES `clinical_trials_ecm`.`program`.`indication`(`indication_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ADD CONSTRAINT `fk_program_program_strategic_plan_master_agreement_id` FOREIGN KEY (`master_agreement_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`master_agreement`(`master_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ADD CONSTRAINT `fk_program_program_strategic_plan_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ADD CONSTRAINT `fk_program_program_strategic_plan_superseded_program_plan_id` FOREIGN KEY (`superseded_program_plan_id`) REFERENCES `clinical_trials_ecm`.`program`.`program_strategic_plan`(`program_strategic_plan_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ADD CONSTRAINT `fk_program_program_strategic_plan_therapeutic_area_id` FOREIGN KEY (`therapeutic_area_id`) REFERENCES `clinical_trials_ecm`.`program`.`therapeutic_area`(`therapeutic_area_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` SET TAGS ('dbx_domain' = 'program');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` SET TAGS ('dbx_subdomain' = 'strategic_planning');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` SET TAGS ('dbx_cross_domain_duplicate_resolution' = 'distinct');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` SET TAGS ('dbx_canonical_owner' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` SET TAGS ('dbx_plan_scope' = 'program');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` SET TAGS ('dbx_distinct_product' = 'program_plan');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` SET TAGS ('dbx_distinct_concept' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `author_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Plan Author Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `author_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `author_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Program ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `indication_id` SET TAGS ('dbx_business_glossary_term' = 'Indication Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `master_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Preferred Provider Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `superseded_program_plan_id` SET TAGS ('dbx_self_ref_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `therapeutic_area_id` SET TAGS ('dbx_business_glossary_term' = 'Therapeutic Area Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Plan Approval Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `approval_target_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Approval Target Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `breakthrough_designation` SET TAGS ('dbx_business_glossary_term' = 'Breakthrough Therapy Designation Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `budget_currency` SET TAGS ('dbx_business_glossary_term' = 'Budget Currency Code');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `budget_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `compound_code` SET TAGS ('dbx_business_glossary_term' = 'Investigational Compound Code');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `development_phase` SET TAGS ('dbx_business_glossary_term' = 'Current Development Phase');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `dsmb_required` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Required Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `end_date` SET TAGS ('dbx_business_glossary_term' = 'Plan Effective End Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `fih_target_date` SET TAGS ('dbx_business_glossary_term' = 'First-in-Human (FIH) Target Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `go_no_go_criteria` SET TAGS ('dbx_business_glossary_term' = 'Go/No-Go Decision Criteria');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `inn_name` SET TAGS ('dbx_business_glossary_term' = 'International Nonproprietary Name (INN)');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `inn_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `key_assumptions` SET TAGS ('dbx_business_glossary_term' = 'Key Planning Assumptions');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `key_assumptions` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `lead_regulatory_agency` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `modality` SET TAGS ('dbx_business_glossary_term' = 'Drug Modality');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `nda_submission_target_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission Target Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `orphan_drug_designation` SET TAGS ('dbx_business_glossary_term' = 'Orphan Drug Designation Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `owner_role` SET TAGS ('dbx_business_glossary_term' = 'Plan Owner Role');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `plan_number` SET TAGS ('dbx_business_glossary_term' = 'Clinical Development Plan (CDP) Number');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `plan_number` SET TAGS ('dbx_value_regex' = '^CDP-[A-Z0-9]{3,10}-[0-9]{4}-v[0-9]{1,3}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `planned_budget_usd` SET TAGS ('dbx_business_glossary_term' = 'Planned Program Budget Envelope (USD)');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `planned_budget_usd` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `planned_study_count` SET TAGS ('dbx_business_glossary_term' = 'Planned Number of Studies');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `planned_subject_count` SET TAGS ('dbx_business_glossary_term' = 'Planned Total Subject Enrollment');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `planning_horizon_years` SET TAGS ('dbx_business_glossary_term' = 'Planning Horizon (Years)');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `poa_target_date` SET TAGS ('dbx_business_glossary_term' = 'Proof-of-Activity (POA) / Proof-of-Concept Target Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `program_plan_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|superseded|retired');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `program_plan_type` SET TAGS ('dbx_value_regex' = 'initial|revised|amended|approved|final');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `start_date` SET TAGS ('dbx_business_glossary_term' = 'Plan Effective Start Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `strategy_narrative` SET TAGS ('dbx_business_glossary_term' = 'Program Strategy Narrative');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `strategy_narrative` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `submission_type` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission Type');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `submission_type` SET TAGS ('dbx_value_regex' = 'IND|NDA|BLA|MAA|sNDA|sBLA');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Plan Title');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `tpp_reference` SET TAGS ('dbx_business_glossary_term' = 'Target Product Profile (TPP) Reference');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Plan Version Number');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_strategic_plan` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^[0-9]{1,3}.[0-9]{1,2}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` ADD CONSTRAINT `fk_program_amendment_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` ADD CONSTRAINT `fk_program_amendment_initiated_by_employee_id` FOREIGN KEY (`initiated_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` ADD CONSTRAINT `fk_program_amendment_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` ADD CONSTRAINT `fk_program_amendment_program_strategic_plan_id` FOREIGN KEY (`program_strategic_plan_id`) REFERENCES `clinical_trials_ecm`.`program`.`program_strategic_plan`(`program_strategic_plan_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` ADD CONSTRAINT `fk_program_amendment_superseded_amendment_id` FOREIGN KEY (`superseded_amendment_id`) REFERENCES `clinical_trials_ecm`.`program`.`amendment`(`amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` ADD CONSTRAINT `fk_program_amendment_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` SET TAGS ('dbx_domain' = 'program');

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` SET TAGS ('dbx_subdomain' = 'strategic_planning');

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` ALTER COLUMN `amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Program Amendment ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Program ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` ALTER COLUMN `initiated_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Initiated By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` ALTER COLUMN `initiated_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` ALTER COLUMN `initiated_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` ALTER COLUMN `program_strategic_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Development Plan (CDP) Version ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` ALTER COLUMN `superseded_amendment_id` SET TAGS ('dbx_self_ref_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Electronic Trial Master File (eTMF) Document ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` ALTER COLUMN `affected_indication` SET TAGS ('dbx_business_glossary_term' = 'Affected Therapeutic Indication');

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` ALTER COLUMN `approver_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` ALTER COLUMN `approver_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` ALTER COLUMN `approver_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Amendment Comments');

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` ALTER COLUMN `dsmb_notification_required` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Notification Required Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` ALTER COLUMN `irb_iec_notification_required` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board / Independent Ethics Committee (IRB/IEC) Notification Required Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` ALTER COLUMN `number` SET TAGS ('dbx_value_regex' = '^AMD-[0-9]{4}-[0-9]{3}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` ALTER COLUMN `previous_version_number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` ALTER COLUMN `priority_level` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` ALTER COLUMN `regulatory_submission_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission Required Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` ALTER COLUMN `amendment_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|rejected|superseded');

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Amendment Title');

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`amendment` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ADD CONSTRAINT `fk_program_governance_agreement_preferred_provider_agreement_id` FOREIGN KEY (`agreement_preferred_provider_agreement_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`preferred_provider_agreement`(`preferred_provider_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ADD CONSTRAINT `fk_program_governance_chair_employee_id` FOREIGN KEY (`chair_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ADD CONSTRAINT `fk_program_governance_master_agreement_id` FOREIGN KEY (`master_agreement_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`master_agreement`(`master_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ADD CONSTRAINT `fk_program_governance_parent_governance_id` FOREIGN KEY (`parent_governance_id`) REFERENCES `clinical_trials_ecm`.`program`.`governance`(`governance_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ADD CONSTRAINT `fk_program_governance_primary_escalation_body_governance_id` FOREIGN KEY (`primary_escalation_body_governance_id`) REFERENCES `clinical_trials_ecm`.`program`.`governance`(`governance_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ADD CONSTRAINT `fk_program_governance_sponsor_engagement_id` FOREIGN KEY (`sponsor_engagement_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`sponsor_engagement`(`sponsor_engagement_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` SET TAGS ('dbx_domain' = 'program');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` SET TAGS ('dbx_subdomain' = 'strategic_planning');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` SET TAGS ('dbx_ssot_owner' = 'program.governance');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` SET TAGS ('dbx_convergence_pass' = 'v2_to_v3');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` SET TAGS ('dbx_cleanup_pass' = 'v4_to_v5');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` SET TAGS ('dbx_model_version' = 'v5');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` SET TAGS ('dbx_cleanup_only_pass' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `governance_id` SET TAGS ('dbx_business_glossary_term' = 'Program Governance ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `agreement_preferred_provider_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Agreement Preferred Provider Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `chair_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Governance Chair Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `chair_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `chair_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `master_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Preferred Provider Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `parent_governance_id` SET TAGS ('dbx_self_ref_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `primary_escalation_body_governance_id` SET TAGS ('dbx_business_glossary_term' = 'Escalation Body ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Engagement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `sponsor_engagement_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `body_code` SET TAGS ('dbx_business_glossary_term' = 'Governance Body Code');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `body_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{2,30}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `body_name` SET TAGS ('dbx_business_glossary_term' = 'Governance Body Name');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `body_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `body_type` SET TAGS ('dbx_business_glossary_term' = 'Governance Body Type');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `body_type` SET TAGS ('dbx_value_regex' = 'Joint Development Committee|Program Review Board|Portfolio Review Committee|Steering Committee|Data Monitoring Committee|Operating Committee');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `charter_version` SET TAGS ('dbx_value_regex' = '^v?d+.d+$');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `confidentiality_requirement` SET TAGS ('dbx_value_regex' = 'Full Confidentiality|Partial Confidentiality|No Confidentiality Requirement');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `cro_co_chair` SET TAGS ('dbx_business_glossary_term' = 'Contract Research Organization (CRO) Co-Chair');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `cro_co_chair` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `cro_co_chair` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `cro_co_chair` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `decision_authority_level` SET TAGS ('dbx_value_regex' = 'Advisory|Recommendatory|Binding|Escalation Required');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `independence_requirement` SET TAGS ('dbx_value_regex' = 'Fully Independent|Partially Independent|No Independence Requirement|Sponsor-CRO Joint');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `meeting_format` SET TAGS ('dbx_value_regex' = 'In-Person|Virtual|Hybrid');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `minutes_required` SET TAGS ('dbx_business_glossary_term' = 'Minutes Required Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Governance Body Notes');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `operating_procedures_ref` SET TAGS ('dbx_business_glossary_term' = 'Operating Procedures Reference');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `quorum_percentage` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `regulatory_reporting_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Reporting Required Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `review_cycle_months` SET TAGS ('dbx_business_glossary_term' = 'Review Cycle (Months)');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `sponsor_co_chair` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Co-Chair');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `sponsor_co_chair` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `sponsor_co_chair` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `sponsor_co_chair` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `sponsor_organization` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `governance_status` SET TAGS ('dbx_business_glossary_term' = 'Governance Body Status');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `governance_status` SET TAGS ('dbx_value_regex' = 'Active|Inactive|Suspended|Dissolved|Pending Formation|Under Review');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `tier` SET TAGS ('dbx_business_glossary_term' = 'Governance Tier');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `tier` SET TAGS ('dbx_value_regex' = 'Strategic|Operational|Tactical');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ADD CONSTRAINT `fk_program_governance_meeting_chair_employee_id` FOREIGN KEY (`chair_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ADD CONSTRAINT `fk_program_governance_meeting_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ADD CONSTRAINT `fk_program_governance_meeting_governance_id` FOREIGN KEY (`governance_id`) REFERENCES `clinical_trials_ecm`.`program`.`governance`(`governance_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ADD CONSTRAINT `fk_program_governance_meeting_organization_contact_id` FOREIGN KEY (`organization_contact_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization_contact`(`organization_contact_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ADD CONSTRAINT `fk_program_governance_meeting_primary_prior_meeting_governance_meeting_id` FOREIGN KEY (`primary_prior_meeting_governance_meeting_id`) REFERENCES `clinical_trials_ecm`.`program`.`governance_meeting`(`governance_meeting_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ADD CONSTRAINT `fk_program_governance_meeting_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` SET TAGS ('dbx_domain' = 'program');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` SET TAGS ('dbx_subdomain' = 'strategic_planning');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `chair_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Chair Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `chair_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `chair_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Program ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `governance_id` SET TAGS ('dbx_business_glossary_term' = 'Oversight Committee ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Chair Sponsor Contact Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `primary_prior_meeting_governance_meeting_id` SET TAGS ('dbx_business_glossary_term' = 'Prior Governance Meeting ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `agenda_distributed_date` SET TAGS ('dbx_business_glossary_term' = 'Agenda Distribution Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `agenda_distributed_date` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `agenda_topics` SET TAGS ('dbx_business_glossary_term' = 'Agenda Topics Summary');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `agenda_topics` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `agenda_version` SET TAGS ('dbx_business_glossary_term' = 'Agenda Document Version');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `agenda_version` SET TAGS ('dbx_value_regex' = '^vd+.d+$');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `agenda_version` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `attendee_count` SET TAGS ('dbx_business_glossary_term' = 'Total Attendee Count');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `chair_role` SET TAGS ('dbx_business_glossary_term' = 'Meeting Chair Role');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_business_glossary_term' = 'Meeting Confidentiality Level');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_value_regex' = 'open|restricted|closed|strictly_confidential');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `end_time` SET TAGS ('dbx_business_glossary_term' = 'Meeting End Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `escalation_required` SET TAGS ('dbx_business_glossary_term' = 'Escalation Required Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `key_decisions` SET TAGS ('dbx_business_glossary_term' = 'Key Decisions Summary');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `location` SET TAGS ('dbx_business_glossary_term' = 'Meeting Location');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `meeting_date` SET TAGS ('dbx_business_glossary_term' = 'Governance Meeting Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `meeting_format` SET TAGS ('dbx_business_glossary_term' = 'Governance Meeting Format');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `meeting_format` SET TAGS ('dbx_value_regex' = 'in_person|virtual|hybrid');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `meeting_frequency` SET TAGS ('dbx_business_glossary_term' = 'Governance Meeting Frequency');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `meeting_number` SET TAGS ('dbx_business_glossary_term' = 'Governance Meeting Number');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `meeting_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{3,30}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `meeting_status` SET TAGS ('dbx_business_glossary_term' = 'Governance Meeting Status');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `meeting_status` SET TAGS ('dbx_value_regex' = 'scheduled|in_progress|completed|cancelled|postponed|rescheduled');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `meeting_title` SET TAGS ('dbx_business_glossary_term' = 'Governance Meeting Title');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `meeting_type` SET TAGS ('dbx_business_glossary_term' = 'Governance Meeting Type');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `meeting_type` SET TAGS ('dbx_value_regex' = 'scheduled|ad_hoc|emergency|extraordinary');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `minutes_approved_date` SET TAGS ('dbx_business_glossary_term' = 'Minutes Approval Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `minutes_approver_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `minutes_approver_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `minutes_approver_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `minutes_status` SET TAGS ('dbx_business_glossary_term' = 'Meeting Minutes Status');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `minutes_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|final|archived');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `next_meeting_date` SET TAGS ('dbx_business_glossary_term' = 'Next Governance Meeting Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `open_action_items_from_prior` SET TAGS ('dbx_business_glossary_term' = 'Open Action Items Carried Forward Count');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `quorum_achieved` SET TAGS ('dbx_business_glossary_term' = 'Quorum Achieved Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `quorum_required` SET TAGS ('dbx_business_glossary_term' = 'Quorum Required Count');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `safety_topic_discussed` SET TAGS ('dbx_business_glossary_term' = 'Safety Topic Discussed Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `session_type` SET TAGS ('dbx_business_glossary_term' = 'Meeting Session Type');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `session_type` SET TAGS ('dbx_value_regex' = 'open|closed|executive');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `start_time` SET TAGS ('dbx_business_glossary_term' = 'Meeting Start Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `tmf_zone` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Zone Reference');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`governance_meeting` ALTER COLUMN `voting_member_count` SET TAGS ('dbx_business_glossary_term' = 'Voting Member Attendance Count');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ADD CONSTRAINT `fk_program_decision_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ADD CONSTRAINT `fk_program_decision_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ADD CONSTRAINT `fk_program_decision_dsmb_meeting_id` FOREIGN KEY (`dsmb_meeting_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`dsmb_meeting`(`dsmb_meeting_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ADD CONSTRAINT `fk_program_decision_governance_id` FOREIGN KEY (`governance_id`) REFERENCES `clinical_trials_ecm`.`program`.`governance`(`governance_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ADD CONSTRAINT `fk_program_decision_governance_meeting_id` FOREIGN KEY (`governance_meeting_id`) REFERENCES `clinical_trials_ecm`.`program`.`governance_meeting`(`governance_meeting_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ADD CONSTRAINT `fk_program_decision_interim_analysis_id` FOREIGN KEY (`interim_analysis_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`interim_analysis`(`interim_analysis_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ADD CONSTRAINT `fk_program_decision_maker_employee_id` FOREIGN KEY (`maker_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ADD CONSTRAINT `fk_program_decision_organization_contact_id` FOREIGN KEY (`organization_contact_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization_contact`(`organization_contact_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ADD CONSTRAINT `fk_program_decision_primary_superseded_by_decision_id` FOREIGN KEY (`primary_superseded_by_decision_id`) REFERENCES `clinical_trials_ecm`.`program`.`decision`(`decision_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ADD CONSTRAINT `fk_program_decision_risk_assessment_id` FOREIGN KEY (`risk_assessment_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`risk_assessment`(`risk_assessment_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ADD CONSTRAINT `fk_program_decision_signal_id` FOREIGN KEY (`signal_id`) REFERENCES `clinical_trials_ecm`.`safety`.`signal`(`signal_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ADD CONSTRAINT `fk_program_decision_study_budget_id` FOREIGN KEY (`study_budget_id`) REFERENCES `clinical_trials_ecm`.`finance`.`study_budget`(`study_budget_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ADD CONSTRAINT `fk_program_decision_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` SET TAGS ('dbx_domain' = 'program');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` SET TAGS ('dbx_subdomain' = 'strategic_planning');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `decision_id` SET TAGS ('dbx_business_glossary_term' = 'Program Decision ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Program ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `dsmb_meeting_id` SET TAGS ('dbx_business_glossary_term' = 'Dsmb Meeting Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `governance_id` SET TAGS ('dbx_business_glossary_term' = 'Governance Body ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `governance_meeting_id` SET TAGS ('dbx_business_glossary_term' = 'Governance Meeting Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `interim_analysis_id` SET TAGS ('dbx_business_glossary_term' = 'Interim Analysis Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `maker_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Decision Maker Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `maker_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `maker_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Contact Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `primary_superseded_by_decision_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Decision ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `risk_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `signal_id` SET TAGS ('dbx_business_glossary_term' = 'Safety Signal Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `study_budget_id` SET TAGS ('dbx_business_glossary_term' = 'Study Budget Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `authority_name` SET TAGS ('dbx_business_glossary_term' = 'Decision Authority Name');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `authority_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `authority_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `authority_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `benefit_risk_assessment` SET TAGS ('dbx_business_glossary_term' = 'Benefit-Risk Assessment');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `benefit_risk_assessment` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `conditions_of_approval` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `dissenting_opinion_summary` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `dsmb_recommendation` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Recommendation');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `dsmb_recommendation` SET TAGS ('dbx_value_regex' = 'continue|modify|pause|terminate|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `investment_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `investment_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `maker_role` SET TAGS ('dbx_business_glossary_term' = 'Decision Maker Role');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `number` SET TAGS ('dbx_value_regex' = '^DEC-[A-Z0-9]{3,10}-[0-9]{4}-[0-9]{4}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `outcome` SET TAGS ('dbx_business_glossary_term' = 'Decision Outcome');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `outcome` SET TAGS ('dbx_value_regex' = 'approved|rejected|deferred|conditional_approval|withdrawn');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `rationale` SET TAGS ('dbx_business_glossary_term' = 'Decision Rationale');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `rationale` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `regulatory_agency_consulted` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `risk_assessment_summary` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `source_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Source Record ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `decision_status` SET TAGS ('dbx_value_regex' = 'draft|pending_review|ratified|superseded|voided');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `supporting_data_summary` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Decision Title');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `decision_type` SET TAGS ('dbx_value_regex' = 'go_no_go|phase_transition|indication_expansion|program_termination|regulatory_strategy_pivot|portfolio_investment');

ALTER TABLE `clinical_trials_ecm`.`program`.`decision` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ADD CONSTRAINT `fk_program_timeline_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ADD CONSTRAINT `fk_program_timeline_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ADD CONSTRAINT `fk_program_timeline_owner_employee_id` FOREIGN KEY (`owner_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ADD CONSTRAINT `fk_program_timeline_primary_timeline_employee_id` FOREIGN KEY (`primary_timeline_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ADD CONSTRAINT `fk_program_timeline_superseded_timeline_id` FOREIGN KEY (`superseded_timeline_id`) REFERENCES `clinical_trials_ecm`.`program`.`timeline`(`timeline_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` SET TAGS ('dbx_domain' = 'program');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` SET TAGS ('dbx_subdomain' = 'strategic_planning');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `timeline_id` SET TAGS ('dbx_business_glossary_term' = 'Program Timeline ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Program ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `owner_employee_id` SET TAGS ('dbx_internal' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `primary_timeline_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Timeline Owner ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `primary_timeline_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `primary_timeline_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `superseded_timeline_id` SET TAGS ('dbx_self_ref_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Timeline Approval Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `approved_by` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `approved_by` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `approved_by` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Timeline Comments');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `csr_target_date` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study Report (CSR) Target Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `forecast_end_date` SET TAGS ('dbx_business_glossary_term' = 'Current Forecast End Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `forecast_start_date` SET TAGS ('dbx_business_glossary_term' = 'Current Forecast Start Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `governance_review_frequency` SET TAGS ('dbx_value_regex' = 'weekly|bi-weekly|monthly|quarterly');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `indication` SET TAGS ('dbx_business_glossary_term' = 'Therapeutic Indication');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `is_current_version` SET TAGS ('dbx_business_glossary_term' = 'Is Current Version Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `milestone_count_at_risk` SET TAGS ('dbx_business_glossary_term' = 'At-Risk Milestone Count');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `milestone_count_completed` SET TAGS ('dbx_business_glossary_term' = 'Completed Milestone Count');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `milestone_count_total` SET TAGS ('dbx_business_glossary_term' = 'Total Milestone Count');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `timeline_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `program_phase` SET TAGS ('dbx_business_glossary_term' = 'Clinical Development Program Phase');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `program_phase` SET TAGS ('dbx_value_regex' = 'Phase I|Phase II|Phase III|Phase IV|Phase I/II|Phase II/III');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `risk_level` SET TAGS ('dbx_business_glossary_term' = 'Timeline Risk Level');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `risk_level` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `risk_summary` SET TAGS ('dbx_business_glossary_term' = 'Timeline Risk Summary');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `schedule_variance_days` SET TAGS ('dbx_business_glossary_term' = 'Schedule Variance (Days)');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `source_system_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `timeline_status` SET TAGS ('dbx_value_regex' = 'on-track|at-risk|delayed|completed|cancelled');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `timeline_type` SET TAGS ('dbx_value_regex' = 'baseline|forecast|scenario|approved|archived');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'Timeline Version');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline` ALTER COLUMN `version` SET TAGS ('dbx_value_regex' = '^vd+.d+$');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ADD CONSTRAINT `fk_program_timeline_event_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ADD CONSTRAINT `fk_program_timeline_event_interim_analysis_id` FOREIGN KEY (`interim_analysis_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`interim_analysis`(`interim_analysis_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ADD CONSTRAINT `fk_program_timeline_event_primary_predecessor_event_timeline_event_id` FOREIGN KEY (`primary_predecessor_event_timeline_event_id`) REFERENCES `clinical_trials_ecm`.`program`.`timeline_event`(`timeline_event_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ADD CONSTRAINT `fk_program_timeline_event_program_development_milestone_id` FOREIGN KEY (`program_development_milestone_id`) REFERENCES `clinical_trials_ecm`.`program`.`program_development_milestone`(`program_development_milestone_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ADD CONSTRAINT `fk_program_timeline_event_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ADD CONSTRAINT `fk_program_timeline_event_timeline_id` FOREIGN KEY (`timeline_id`) REFERENCES `clinical_trials_ecm`.`program`.`timeline`(`timeline_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` SET TAGS ('dbx_domain' = 'program');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` SET TAGS ('dbx_subdomain' = 'strategic_planning');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Program ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `interim_analysis_id` SET TAGS ('dbx_business_glossary_term' = 'Interim Analysis Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `primary_predecessor_event_timeline_event_id` SET TAGS ('dbx_business_glossary_term' = 'Predecessor Event ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `program_development_milestone_id` SET TAGS ('dbx_business_glossary_term' = 'Program Milestone Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `timeline_id` SET TAGS ('dbx_business_glossary_term' = 'Program Timeline Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `acceptance_criteria` SET TAGS ('dbx_business_glossary_term' = 'Event Acceptance Criteria');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `approved_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `baseline_version` SET TAGS ('dbx_value_regex' = '^BL-[0-9]{2}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Event Comments');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `completion_percentage` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `dependency_type` SET TAGS ('dbx_value_regex' = 'finish_to_start|start_to_start|finish_to_finish|start_to_finish');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `duration_days` SET TAGS ('dbx_business_glossary_term' = 'Event Duration (Days)');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `event_category` SET TAGS ('dbx_business_glossary_term' = 'Timeline Event Category');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `event_category` SET TAGS ('dbx_value_regex' = 'clinical|regulatory|safety|biostatistics|data_management|operational');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `event_code` SET TAGS ('dbx_business_glossary_term' = 'Timeline Event Code');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `event_code` SET TAGS ('dbx_value_regex' = '^EVT-[A-Z0-9]{3,20}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `event_description` SET TAGS ('dbx_business_glossary_term' = 'Timeline Event Description');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `event_name` SET TAGS ('dbx_business_glossary_term' = 'Timeline Event Name');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `event_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `event_status` SET TAGS ('dbx_business_glossary_term' = 'Timeline Event Status');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `event_status` SET TAGS ('dbx_value_regex' = 'planned|in_progress|completed|delayed|cancelled');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `event_type` SET TAGS ('dbx_business_glossary_term' = 'Timeline Event Type');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `event_type` SET TAGS ('dbx_value_regex' = 'study_start|database_lock|regulatory_submission|advisory_committee_meeting|approval_decision|program_review');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `float_days` SET TAGS ('dbx_business_glossary_term' = 'Schedule Float (Days)');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `lag_days` SET TAGS ('dbx_business_glossary_term' = 'Dependency Lag (Days)');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `owner_name` SET TAGS ('dbx_business_glossary_term' = 'Event Owner Name');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `owner_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `owner_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `owner_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `priority` SET TAGS ('dbx_business_glossary_term' = 'Event Priority');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `priority` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `regulatory_agency` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `risk_level` SET TAGS ('dbx_business_glossary_term' = 'Event Risk Level');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `risk_level` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `schedule_variance_days` SET TAGS ('dbx_business_glossary_term' = 'Schedule Variance (Days)');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `source_event_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Event ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`timeline_event` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ADD CONSTRAINT `fk_program_risk_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ADD CONSTRAINT `fk_program_risk_owner_employee_id` FOREIGN KEY (`owner_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ADD CONSTRAINT `fk_program_risk_parent_risk_id` FOREIGN KEY (`parent_risk_id`) REFERENCES `clinical_trials_ecm`.`program`.`risk`(`risk_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ADD CONSTRAINT `fk_program_risk_primary_risk_employee_id` FOREIGN KEY (`primary_risk_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` SET TAGS ('dbx_domain' = 'program');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` SET TAGS ('dbx_subdomain' = 'risk_oversight');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `risk_id` SET TAGS ('dbx_business_glossary_term' = 'Program Risk ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Program ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `owner_employee_id` SET TAGS ('dbx_internal' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `parent_risk_id` SET TAGS ('dbx_self_ref_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `primary_risk_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Owner ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `primary_risk_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `primary_risk_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `actual_resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Risk Resolution Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `affected_studies` SET TAGS ('dbx_business_glossary_term' = 'Affected Study Identifiers');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `capa_reference` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Reference');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `risk_category` SET TAGS ('dbx_value_regex' = 'scientific|regulatory|operational|competitive|financial|safety');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Risk Comments');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `contingency_plan` SET TAGS ('dbx_business_glossary_term' = 'Risk Contingency Plan');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `escalation_date` SET TAGS ('dbx_business_glossary_term' = 'Risk Escalation Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `escalation_required` SET TAGS ('dbx_business_glossary_term' = 'Escalation Required Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `financial_exposure_usd` SET TAGS ('dbx_business_glossary_term' = 'Financial Exposure (USD)');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `financial_exposure_usd` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `identified_date` SET TAGS ('dbx_business_glossary_term' = 'Risk Identification Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `identifier` SET TAGS ('dbx_business_glossary_term' = 'Program Risk Identifier');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `identifier` SET TAGS ('dbx_value_regex' = '^PRSK-[A-Z0-9]{3,10}-[0-9]{4,6}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `impact_rating` SET TAGS ('dbx_business_glossary_term' = 'Risk Impact Rating');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `impact_rating` SET TAGS ('dbx_value_regex' = 'very_low|low|medium|high|very_high');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `impact_score` SET TAGS ('dbx_business_glossary_term' = 'Risk Impact Score');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Risk Review Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `mitigation_status` SET TAGS ('dbx_business_glossary_term' = 'Mitigation Action Status');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `mitigation_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|completed|on_hold');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `mitigation_strategy` SET TAGS ('dbx_business_glossary_term' = 'Risk Mitigation Strategy');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Scheduled Risk Review Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `priority` SET TAGS ('dbx_business_glossary_term' = 'Risk Priority Level');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `priority` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `probability_rating` SET TAGS ('dbx_business_glossary_term' = 'Risk Probability Rating');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `probability_rating` SET TAGS ('dbx_value_regex' = 'very_low|low|medium|high|very_high');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `probability_score` SET TAGS ('dbx_business_glossary_term' = 'Risk Probability Score');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `residual_impact_rating` SET TAGS ('dbx_business_glossary_term' = 'Residual Risk Impact Rating');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `residual_impact_rating` SET TAGS ('dbx_value_regex' = 'very_low|low|medium|high|very_high');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `residual_probability_rating` SET TAGS ('dbx_business_glossary_term' = 'Residual Risk Probability Rating');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `residual_probability_rating` SET TAGS ('dbx_value_regex' = 'very_low|low|medium|high|very_high');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `score` SET TAGS ('dbx_business_glossary_term' = 'Risk Score');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `source_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `risk_status` SET TAGS ('dbx_value_regex' = 'open|mitigated|closed|accepted');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `subcategory` SET TAGS ('dbx_business_glossary_term' = 'Risk Subcategory');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `target_resolution_date` SET TAGS ('dbx_business_glossary_term' = 'Target Risk Resolution Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `timeline_impact_days` SET TAGS ('dbx_business_glossary_term' = 'Timeline Impact (Days)');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Risk Title');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `tolerance_threshold` SET TAGS ('dbx_business_glossary_term' = 'Risk Tolerance Threshold Score');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `trigger_criteria` SET TAGS ('dbx_business_glossary_term' = 'Risk Trigger Criteria');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ADD CONSTRAINT `fk_program_risk_mitigation_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ADD CONSTRAINT `fk_program_risk_mitigation_compliance_capa_id` FOREIGN KEY (`compliance_capa_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_capa`(`compliance_capa_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ADD CONSTRAINT `fk_program_risk_mitigation_escalated_risk_mitigation_id` FOREIGN KEY (`escalated_risk_mitigation_id`) REFERENCES `clinical_trials_ecm`.`program`.`risk_mitigation`(`risk_mitigation_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ADD CONSTRAINT `fk_program_risk_mitigation_primary_risk_employee_id` FOREIGN KEY (`primary_risk_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ADD CONSTRAINT `fk_program_risk_mitigation_protocol_deviation_id` FOREIGN KEY (`protocol_deviation_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`protocol_deviation`(`protocol_deviation_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ADD CONSTRAINT `fk_program_risk_mitigation_risk_id` FOREIGN KEY (`risk_id`) REFERENCES `clinical_trials_ecm`.`program`.`risk`(`risk_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ADD CONSTRAINT `fk_program_risk_mitigation_tertiary_risk_effectiveness_reviewer_employee_id` FOREIGN KEY (`tertiary_risk_effectiveness_reviewer_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` SET TAGS ('dbx_domain' = 'program');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` SET TAGS ('dbx_subdomain' = 'risk_oversight');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Program ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ALTER COLUMN `compliance_capa_id` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Reference ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ALTER COLUMN `escalated_risk_mitigation_id` SET TAGS ('dbx_self_ref_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ALTER COLUMN `primary_risk_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Mitigation Action Owner ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ALTER COLUMN `primary_risk_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ALTER COLUMN `primary_risk_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ALTER COLUMN `risk_id` SET TAGS ('dbx_business_glossary_term' = 'Program Risk ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ALTER COLUMN `tertiary_risk_effectiveness_reviewer_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Effectiveness Reviewer ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ALTER COLUMN `tertiary_risk_effectiveness_reviewer_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ALTER COLUMN `tertiary_risk_effectiveness_reviewer_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ALTER COLUMN `action_description` SET TAGS ('dbx_business_glossary_term' = 'Mitigation Action Description');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ALTER COLUMN `action_owner_role` SET TAGS ('dbx_business_glossary_term' = 'Mitigation Action Owner Role');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ALTER COLUMN `action_status` SET TAGS ('dbx_business_glossary_term' = 'Mitigation Action Status');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ALTER COLUMN `action_status` SET TAGS ('dbx_value_regex' = 'planned|in_progress|completed|overdue|cancelled|on_hold');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ALTER COLUMN `action_title` SET TAGS ('dbx_business_glossary_term' = 'Mitigation Action Title');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ALTER COLUMN `action_type` SET TAGS ('dbx_business_glossary_term' = 'Mitigation Action Type');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ALTER COLUMN `action_type` SET TAGS ('dbx_value_regex' = 'preventive|corrective|contingency|transfer|acceptance');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ALTER COLUMN `due_date_revised` SET TAGS ('dbx_business_glossary_term' = 'Revised Due Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ALTER COLUMN `effectiveness_notes` SET TAGS ('dbx_business_glossary_term' = 'Effectiveness Review Notes');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ALTER COLUMN `effectiveness_rating` SET TAGS ('dbx_business_glossary_term' = 'Mitigation Effectiveness Rating');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ALTER COLUMN `effectiveness_rating` SET TAGS ('dbx_value_regex' = 'highly_effective|effective|partially_effective|ineffective|not_assessed');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ALTER COLUMN `linked_milestone` SET TAGS ('dbx_business_glossary_term' = 'Linked Program Milestone');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ALTER COLUMN `mitigation_action_code` SET TAGS ('dbx_value_regex' = '^MIT-[A-Z0-9]{3,10}-[0-9]{4,8}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ALTER COLUMN `mitigation_strategy` SET TAGS ('dbx_value_regex' = 'risk_reduction|risk_avoidance|risk_transfer|risk_acceptance|contingency_planning');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ALTER COLUMN `priority_level` SET TAGS ('dbx_business_glossary_term' = 'Mitigation Action Priority Level');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ALTER COLUMN `priority_level` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ALTER COLUMN `residual_risk_accepted` SET TAGS ('dbx_business_glossary_term' = 'Residual Risk Accepted Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ALTER COLUMN `residual_risk_level` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low|negligible');

ALTER TABLE `clinical_trials_ecm`.`program`.`risk_mitigation` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Record Version Number');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ADD CONSTRAINT `fk_program_assumption_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ADD CONSTRAINT `fk_program_assumption_parent_assumption_id` FOREIGN KEY (`parent_assumption_id`) REFERENCES `clinical_trials_ecm`.`program`.`assumption`(`assumption_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ADD CONSTRAINT `fk_program_assumption_primary_assumption_owner_employee_id` FOREIGN KEY (`primary_assumption_owner_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ADD CONSTRAINT `fk_program_assumption_primary_revised_assumption_id` FOREIGN KEY (`primary_revised_assumption_id`) REFERENCES `clinical_trials_ecm`.`program`.`assumption`(`assumption_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` SET TAGS ('dbx_domain' = 'program');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` SET TAGS ('dbx_subdomain' = 'risk_oversight');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `assumption_id` SET TAGS ('dbx_business_glossary_term' = 'Program Assumption ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Program ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `primary_assumption_owner_employee_id` SET TAGS ('dbx_internal' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `primary_revised_assumption_id` SET TAGS ('dbx_business_glossary_term' = 'Revised Assumption Id');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `primary_revised_assumption_id` SET TAGS ('dbx_self_ref_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `applicable_phase` SET TAGS ('dbx_business_glossary_term' = 'Applicable Clinical Phase');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `applicable_phase` SET TAGS ('dbx_value_regex' = 'phase_1|phase_2|phase_3|phase_4|all_phases');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `assumption_code` SET TAGS ('dbx_value_regex' = '^ASM-[A-Z0-9]{4,12}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `confidence_level` SET TAGS ('dbx_value_regex' = 'high|medium|low');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `confidence_rationale` SET TAGS ('dbx_business_glossary_term' = 'Confidence Level Rationale');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Assumption Data Source');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `effective_from_date` SET TAGS ('dbx_business_glossary_term' = 'Assumption Effective From Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `invalidation_trigger` SET TAGS ('dbx_business_glossary_term' = 'Assumption Invalidation Trigger');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `is_dependency_trigger` SET TAGS ('dbx_business_glossary_term' = 'Is Dependency Trigger Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Assumption Review Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `lower_bound_value` SET TAGS ('dbx_business_glossary_term' = 'Assumption Lower Bound Value');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Assumption Review Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `regulatory_agency` SET TAGS ('dbx_business_glossary_term' = 'Applicable Regulatory Agency');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `regulatory_agency` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `review_frequency` SET TAGS ('dbx_business_glossary_term' = 'Assumption Review Frequency');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `review_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annually|annually|event_triggered|ad_hoc');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `assumption_status` SET TAGS ('dbx_value_regex' = 'draft|active|under_review|validated|invalidated|superseded');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `subcategory` SET TAGS ('dbx_business_glossary_term' = 'Assumption Subcategory');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `supporting_document_ref` SET TAGS ('dbx_business_glossary_term' = 'Supporting Document Reference');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Assumption Title');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `upper_bound_value` SET TAGS ('dbx_business_glossary_term' = 'Assumption Upper Bound Value');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `validation_date` SET TAGS ('dbx_business_glossary_term' = 'Assumption Validation Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `validation_method` SET TAGS ('dbx_business_glossary_term' = 'Assumption Validation Method');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `validation_status` SET TAGS ('dbx_value_regex' = 'pending|validated|invalidated|partially_validated');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `value` SET TAGS ('dbx_business_glossary_term' = 'Assumption Value');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `value_unit` SET TAGS ('dbx_business_glossary_term' = 'Assumption Value Unit of Measure');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Assumption Version Number');

ALTER TABLE `clinical_trials_ecm`.`program`.`assumption` ALTER COLUMN `version_rationale` SET TAGS ('dbx_business_glossary_term' = 'Version Change Rationale');

ALTER TABLE `clinical_trials_ecm`.`program`.`cross_study_dependency` ADD CONSTRAINT `fk_program_cross_study_dependency_primary_cross_clinical_program_id` FOREIGN KEY (`primary_cross_clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`cross_study_dependency` ADD CONSTRAINT `fk_program_cross_study_dependency_primary_cross_predecessor_study_id` FOREIGN KEY (`primary_cross_predecessor_study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`cross_study_dependency` ADD CONSTRAINT `fk_program_cross_study_dependency_program_development_milestone_id` FOREIGN KEY (`program_development_milestone_id`) REFERENCES `clinical_trials_ecm`.`program`.`program_development_milestone`(`program_development_milestone_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`cross_study_dependency` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`program`.`cross_study_dependency` SET TAGS ('dbx_domain' = 'program');

ALTER TABLE `clinical_trials_ecm`.`program`.`cross_study_dependency` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`program`.`cross_study_dependency` SET TAGS ('dbx_subdomain' = 'risk_oversight');

ALTER TABLE `clinical_trials_ecm`.`program`.`cross_study_dependency` ALTER COLUMN `cross_study_dependency_id` SET TAGS ('dbx_business_glossary_term' = 'Cross-Study Dependency ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`cross_study_dependency` ALTER COLUMN `primary_cross_clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Program ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`cross_study_dependency` ALTER COLUMN `primary_cross_predecessor_study_id` SET TAGS ('dbx_business_glossary_term' = 'Predecessor Study ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`cross_study_dependency` ALTER COLUMN `program_development_milestone_id` SET TAGS ('dbx_business_glossary_term' = 'Predecessor Milestone ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`cross_study_dependency` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`cross_study_dependency` ALTER COLUMN `cross_program_flag` SET TAGS ('dbx_business_glossary_term' = 'Cross-Program Dependency Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`cross_study_dependency` ALTER COLUMN `data_package_required` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`cross_study_dependency` ALTER COLUMN `dependency_code` SET TAGS ('dbx_value_regex' = '^DEP-[A-Z0-9]{4,12}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`cross_study_dependency` ALTER COLUMN `dependency_direction` SET TAGS ('dbx_value_regex' = 'unidirectional|bidirectional');

ALTER TABLE `clinical_trials_ecm`.`program`.`cross_study_dependency` ALTER COLUMN `dependency_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`cross_study_dependency` ALTER COLUMN `dependency_status` SET TAGS ('dbx_value_regex' = 'active|resolved|waived|on_hold|pending_review');

ALTER TABLE `clinical_trials_ecm`.`program`.`cross_study_dependency` ALTER COLUMN `dependency_type` SET TAGS ('dbx_value_regex' = 'data|safety|regulatory|supply|sequential_design|operational');

ALTER TABLE `clinical_trials_ecm`.`program`.`cross_study_dependency` ALTER COLUMN `dsmb_review_required` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Review Required Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`cross_study_dependency` ALTER COLUMN `escalation_contact` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`cross_study_dependency` ALTER COLUMN `governance_review_required` SET TAGS ('dbx_business_glossary_term' = 'Governance Review Required Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`cross_study_dependency` ALTER COLUMN `impact_if_unmet` SET TAGS ('dbx_business_glossary_term' = 'Impact If Dependency Unmet');

ALTER TABLE `clinical_trials_ecm`.`program`.`cross_study_dependency` ALTER COLUMN `regulatory_agency_notification_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Agency Notification Required Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`cross_study_dependency` ALTER COLUMN `regulatory_agency_notification_required` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`cross_study_dependency` ALTER COLUMN `risk_level` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');

ALTER TABLE `clinical_trials_ecm`.`program`.`cross_study_dependency` ALTER COLUMN `source_system_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`cross_study_dependency` ALTER COLUMN `successor_earliest_start_date` SET TAGS ('dbx_business_glossary_term' = 'Successor Study Earliest Start Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`cross_study_dependency` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ADD CONSTRAINT `fk_program_program_resource_plan_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ADD CONSTRAINT `fk_program_program_resource_plan_cost_center_id` FOREIGN KEY (`cost_center_id`) REFERENCES `clinical_trials_ecm`.`finance`.`cost_center`(`cost_center_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ADD CONSTRAINT `fk_program_program_resource_plan_master_agreement_id` FOREIGN KEY (`master_agreement_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`master_agreement`(`master_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ADD CONSTRAINT `fk_program_program_resource_plan_org_unit_id` FOREIGN KEY (`org_unit_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`org_unit`(`org_unit_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ADD CONSTRAINT `fk_program_program_resource_plan_plan_owner_employee_id` FOREIGN KEY (`plan_owner_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ADD CONSTRAINT `fk_program_program_resource_plan_primary_predecessor_plan_program_resource_plan_id` FOREIGN KEY (`primary_predecessor_plan_program_resource_plan_id`) REFERENCES `clinical_trials_ecm`.`program`.`program_resource_plan`(`program_resource_plan_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ADD CONSTRAINT `fk_program_program_resource_plan_primary_program_cro_organization_id` FOREIGN KEY (`primary_program_cro_organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` SET TAGS ('dbx_domain' = 'program');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` SET TAGS ('dbx_subdomain' = 'resource_allocation');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Program ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `master_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Preferred Provider Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `org_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Org Unit Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `plan_owner_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Plan Owner Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `plan_owner_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `plan_owner_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `primary_predecessor_plan_program_resource_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Predecessor Resource Plan ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `primary_program_cro_organization_id` SET TAGS ('dbx_business_glossary_term' = 'Contract Research Organization (CRO) ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `actual_fte_count` SET TAGS ('dbx_business_glossary_term' = 'Actual Full-Time Equivalent (FTE) Count');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Resource Plan Approval Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Resource Plan Comments');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `forecasted_cost_usd` SET TAGS ('dbx_business_glossary_term' = 'Forecasted Resource Cost (USD)');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `forecasted_cost_usd` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `forecasted_fte_count` SET TAGS ('dbx_business_glossary_term' = 'Forecasted Full-Time Equivalent (FTE) Count');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `mitigation_action` SET TAGS ('dbx_business_glossary_term' = 'Resource Mitigation Action');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `plan_code` SET TAGS ('dbx_business_glossary_term' = 'Resource Plan Code');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `plan_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{3,30}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `plan_name` SET TAGS ('dbx_business_glossary_term' = 'Resource Plan Name');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `plan_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `plan_status` SET TAGS ('dbx_business_glossary_term' = 'Resource Plan Status');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `plan_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|active|superseded|cancelled');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `plan_type` SET TAGS ('dbx_business_glossary_term' = 'Resource Plan Type');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `plan_type` SET TAGS ('dbx_value_regex' = 'baseline|revised|scenario|contingency');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `plan_version` SET TAGS ('dbx_business_glossary_term' = 'Resource Plan Version');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `plan_version` SET TAGS ('dbx_value_regex' = '^vd+(.d+)?$');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `planned_cost_usd` SET TAGS ('dbx_business_glossary_term' = 'Planned Resource Cost (USD)');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `planned_cost_usd` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `planned_fte_count` SET TAGS ('dbx_business_glossary_term' = 'Planned Full-Time Equivalent (FTE) Count');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `planning_granularity` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|annual');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `resource_category` SET TAGS ('dbx_value_regex' = 'internal_fte|contract_fte|cro_fte|vendor_fte');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `resource_gap_fte` SET TAGS ('dbx_business_glossary_term' = 'Resource Gap Full-Time Equivalent (FTE)');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Resource Risk Rating');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_resource_plan` ALTER COLUMN `source_system_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ADD CONSTRAINT `fk_program_budget_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ADD CONSTRAINT `fk_program_budget_cost_center_id` FOREIGN KEY (`cost_center_id`) REFERENCES `clinical_trials_ecm`.`finance`.`cost_center`(`cost_center_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ADD CONSTRAINT `fk_program_budget_gl_account_id` FOREIGN KEY (`gl_account_id`) REFERENCES `clinical_trials_ecm`.`finance`.`gl_account`(`gl_account_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ADD CONSTRAINT `fk_program_budget_master_agreement_id` FOREIGN KEY (`master_agreement_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`master_agreement`(`master_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ADD CONSTRAINT `fk_program_budget_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ADD CONSTRAINT `fk_program_budget_primary_budget_approved_by_employee_id` FOREIGN KEY (`primary_budget_approved_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ADD CONSTRAINT `fk_program_budget_primary_prior_version_budget_id` FOREIGN KEY (`primary_prior_version_budget_id`) REFERENCES `clinical_trials_ecm`.`program`.`budget`(`budget_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` SET TAGS ('dbx_domain' = 'program');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` SET TAGS ('dbx_subdomain' = 'resource_allocation');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `budget_id` SET TAGS ('dbx_business_glossary_term' = 'Program Budget ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `gl_account_id` SET TAGS ('dbx_business_glossary_term' = 'Gl Account Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `master_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Preferred Provider Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `primary_budget_approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Budget Approved By ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `primary_budget_approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `primary_budget_approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `primary_prior_version_budget_id` SET TAGS ('dbx_business_glossary_term' = 'Prior Budget Version ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Budget Approval Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `approval_governance_body` SET TAGS ('dbx_business_glossary_term' = 'Budget Approval Governance Body');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `biostatistics_budget_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `clinical_ops_budget_amount` SET TAGS ('dbx_business_glossary_term' = 'Clinical Operations Budget Amount');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `clinical_ops_budget_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `budget_code` SET TAGS ('dbx_business_glossary_term' = 'Program Budget Code');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `budget_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{3,30}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `contingency_amount` SET TAGS ('dbx_business_glossary_term' = 'Contingency Reserve Amount');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `contingency_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `cro_budget_amount` SET TAGS ('dbx_business_glossary_term' = 'Contract Research Organization (CRO) Budget Amount');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `cro_budget_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Budget Currency Code');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `data_management_budget_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `data_management_budget_amount` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Budget Effective End Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Budget Effective Start Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `exchange_rate` SET TAGS ('dbx_business_glossary_term' = 'Budget Exchange Rate');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `fiscal_year` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `is_locked` SET TAGS ('dbx_business_glossary_term' = 'Budget Locked Indicator');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `lab_budget_amount` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Services Budget Amount');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `lab_budget_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `budget_name` SET TAGS ('dbx_business_glossary_term' = 'Program Budget Name');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `budget_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Budget Notes');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `phase1_budget_amount` SET TAGS ('dbx_business_glossary_term' = 'Phase I Budget Amount');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `phase1_budget_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `phase2_budget_amount` SET TAGS ('dbx_business_glossary_term' = 'Phase II Budget Amount');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `phase2_budget_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `phase3_budget_amount` SET TAGS ('dbx_business_glossary_term' = 'Phase III Budget Amount');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `phase3_budget_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `phase4_budget_amount` SET TAGS ('dbx_business_glossary_term' = 'Phase IV Budget Amount');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `phase4_budget_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `regulatory_budget_amount` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Affairs Budget Amount');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `regulatory_budget_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `reporting_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `revision_reason` SET TAGS ('dbx_business_glossary_term' = 'Budget Revision Reason');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `safety_budget_amount` SET TAGS ('dbx_business_glossary_term' = 'Safety and Pharmacovigilance Budget Amount');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `safety_budget_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `source_system_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `budget_status` SET TAGS ('dbx_business_glossary_term' = 'Program Budget Status');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'Budget Submission Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `supply_chain_budget_amount` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product Supply Chain Budget Amount');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `supply_chain_budget_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `total_approved_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Approved Budget Amount');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `total_approved_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `budget_type` SET TAGS ('dbx_business_glossary_term' = 'Program Budget Type');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `budget_type` SET TAGS ('dbx_value_regex' = 'initial|revised|supplemental|contingency');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'Budget Version');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `version` SET TAGS ('dbx_value_regex' = '^v[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_ecm`.`program`.`budget` ALTER COLUMN `wbs_code` SET TAGS ('dbx_business_glossary_term' = 'Work Breakdown Structure (WBS) Code');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ADD CONSTRAINT `fk_program_program_status_history_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ADD CONSTRAINT `fk_program_program_status_history_governance_meeting_id` FOREIGN KEY (`governance_meeting_id`) REFERENCES `clinical_trials_ecm`.`program`.`governance_meeting`(`governance_meeting_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ADD CONSTRAINT `fk_program_program_status_history_previous_program_status_history_id` FOREIGN KEY (`previous_program_status_history_id`) REFERENCES `clinical_trials_ecm`.`program`.`program_status_history`(`program_status_history_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ADD CONSTRAINT `fk_program_program_status_history_primary_program_employee_id` FOREIGN KEY (`primary_program_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` SET TAGS ('dbx_domain' = 'program');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` SET TAGS ('dbx_subdomain' = 'resource_allocation');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Development Program ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `previous_program_status_history_id` SET TAGS ('dbx_self_ref_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `primary_program_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Recorded By User ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `primary_program_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `primary_program_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Status Transition Approval Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `approved_by_name` SET TAGS ('dbx_business_glossary_term' = 'Approved By Full Name');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `approved_by_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `approved_by_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `approved_by_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Status Transition Comments');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `compliance_inspection_code` SET TAGS ('dbx_business_glossary_term' = 'Inspection Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Status Effective Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `hold_type` SET TAGS ('dbx_value_regex' = 'CLINICAL_HOLD|PARTIAL_CLINICAL_HOLD|VOLUNTARY_HOLD|INTERNAL_HOLD');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `is_current` SET TAGS ('dbx_business_glossary_term' = 'Current Status Record Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `is_system_generated` SET TAGS ('dbx_business_glossary_term' = 'System Generated Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `new_status` SET TAGS ('dbx_business_glossary_term' = 'New Program Status');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `notification_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Notification Required Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `notification_submitted_date` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Notification Submitted Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `previous_status` SET TAGS ('dbx_business_glossary_term' = 'Previous Program Status');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `recorded_by_name` SET TAGS ('dbx_business_glossary_term' = 'Recorded By Full Name');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `recorded_by_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `recorded_by_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `recorded_by_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `recorded_by_role` SET TAGS ('dbx_value_regex' = 'PROGRAM_LEAD|MEDICAL_MONITOR|REGULATORY_AFFAIRS|PORTFOLIO_MANAGER|SYSTEM|SPONSOR_REPRESENTATIVE');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `regulatory_correspondence_ref` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Correspondence Reference');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `source_system_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `tmf_document_ref` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Document Reference');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `transition_date` SET TAGS ('dbx_business_glossary_term' = 'Status Transition Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `transition_reason_code` SET TAGS ('dbx_business_glossary_term' = 'Status Transition Reason Code');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `transition_reason_description` SET TAGS ('dbx_business_glossary_term' = 'Status Transition Reason Description');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `transition_sequence` SET TAGS ('dbx_business_glossary_term' = 'Status Transition Sequence Number');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `transition_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Status Transition Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_status_history` ALTER COLUMN `triggering_event_reference` SET TAGS ('dbx_business_glossary_term' = 'Triggering Event Reference Number');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ADD CONSTRAINT `fk_program_team_member_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ADD CONSTRAINT `fk_program_team_member_cost_center_id` FOREIGN KEY (`cost_center_id`) REFERENCES `clinical_trials_ecm`.`finance`.`cost_center`(`cost_center_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ADD CONSTRAINT `fk_program_team_member_job_profile_id` FOREIGN KEY (`job_profile_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`job_profile`(`job_profile_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ADD CONSTRAINT `fk_program_team_member_primary_predecessor_member_team_member_id` FOREIGN KEY (`primary_predecessor_member_team_member_id`) REFERENCES `clinical_trials_ecm`.`program`.`team_member`(`team_member_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ADD CONSTRAINT `fk_program_team_member_primary_team_employee_id` FOREIGN KEY (`primary_team_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ADD CONSTRAINT `fk_program_team_member_training_curriculum_id` FOREIGN KEY (`training_curriculum_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`training_curriculum`(`training_curriculum_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` SET TAGS ('dbx_domain' = 'program');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` SET TAGS ('dbx_subdomain' = 'resource_allocation');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `team_member_id` SET TAGS ('dbx_business_glossary_term' = 'Program Team Member ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `team_member_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `team_member_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Development Program ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `job_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Job Profile Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `primary_predecessor_member_team_member_id` SET TAGS ('dbx_business_glossary_term' = 'Predecessor Team Member ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `primary_predecessor_member_team_member_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `primary_predecessor_member_team_member_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `primary_team_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Workforce Member ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `primary_team_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `primary_team_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `training_curriculum_id` SET TAGS ('dbx_business_glossary_term' = 'Training Curriculum Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `assignment_code` SET TAGS ('dbx_business_glossary_term' = 'Program Team Member Assignment Code');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `assignment_code` SET TAGS ('dbx_value_regex' = '^PTM-[A-Z0-9]{4,12}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `assignment_status` SET TAGS ('dbx_value_regex' = 'Active|Pending|On Leave|Transitioning|Terminated');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `assignment_type` SET TAGS ('dbx_value_regex' = 'Permanent|Interim|Acting|Secondment|Advisory');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `confidentiality_agreement_date` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Agreement Execution Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `confidentiality_agreement_signed` SET TAGS ('dbx_business_glossary_term' = 'Confidentiality Agreement Signed Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `conflict_of_interest_date` SET TAGS ('dbx_business_glossary_term' = 'Conflict of Interest Declaration Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `conflict_of_interest_declared` SET TAGS ('dbx_business_glossary_term' = 'Conflict of Interest Declared Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `ctms_user_reference` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) User ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `ctms_user_reference` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `ctms_user_reference` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `delegation_authority_level` SET TAGS ('dbx_value_regex' = 'Full|Limited|Read Only|None');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `employment_type` SET TAGS ('dbx_value_regex' = 'Employee|Contractor|Consultant|Secondee');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `etmf_access_flag` SET TAGS ('dbx_business_glossary_term' = 'Electronic Trial Master File (eTMF) Access Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `fte_allocation_percentage` SET TAGS ('dbx_business_glossary_term' = 'Full-Time Equivalent (FTE) Allocation Percentage');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `fte_allocation_percentage` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `gcp_certification_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Certification Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `gcp_certification_status` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Certification Status');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `gcp_certification_status` SET TAGS ('dbx_value_regex' = 'Current|Expired|Pending Renewal|Not Required');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `handover_document_ref` SET TAGS ('dbx_business_glossary_term' = 'Handover Document Reference');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `is_backup_contact` SET TAGS ('dbx_business_glossary_term' = 'Backup Contact Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `is_backup_contact` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `is_primary_contact` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `is_primary_contact` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `program_role` SET TAGS ('dbx_business_glossary_term' = 'Program-Level Role');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `program_role` SET TAGS ('dbx_value_regex' = 'Program Director|Medical Director|Regulatory Lead|Biostatistics Lead|Clinical Operations Lead|Data Management Lead');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `role_category` SET TAGS ('dbx_business_glossary_term' = 'Program Role Category');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `source_system_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `transition_date` SET TAGS ('dbx_business_glossary_term' = 'Role Transition Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `wbs_code` SET TAGS ('dbx_business_glossary_term' = 'Work Breakdown Structure (WBS) Code');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `work_email` SET TAGS ('dbx_business_glossary_term' = 'Work Email Address');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `work_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `work_email` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `work_email` SET TAGS ('dbx_pii_email' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `work_email` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `work_phone` SET TAGS ('dbx_business_glossary_term' = 'Work Phone Number');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `work_phone` SET TAGS ('dbx_value_regex' = '^+?[0-9s-().]{7,20}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `work_phone` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `work_phone` SET TAGS ('dbx_pii_phone' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `work_phone` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`team_member` ALTER COLUMN `years_of_experience` SET TAGS ('dbx_business_glossary_term' = 'Years of Clinical Research Experience');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ADD CONSTRAINT `fk_program_program_communication_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ADD CONSTRAINT `fk_program_program_communication_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ADD CONSTRAINT `fk_program_program_communication_governance_meeting_id` FOREIGN KEY (`governance_meeting_id`) REFERENCES `clinical_trials_ecm`.`program`.`governance_meeting`(`governance_meeting_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ADD CONSTRAINT `fk_program_program_communication_organization_contact_id` FOREIGN KEY (`organization_contact_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization_contact`(`organization_contact_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ADD CONSTRAINT `fk_program_program_communication_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ADD CONSTRAINT `fk_program_program_communication_program_development_milestone_id` FOREIGN KEY (`program_development_milestone_id`) REFERENCES `clinical_trials_ecm`.`program`.`program_development_milestone`(`program_development_milestone_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ADD CONSTRAINT `fk_program_program_communication_related_amendment_program_amendment_id` FOREIGN KEY (`related_amendment_program_amendment_id`) REFERENCES `clinical_trials_ecm`.`program`.`amendment`(`amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ADD CONSTRAINT `fk_program_program_communication_signal_id` FOREIGN KEY (`signal_id`) REFERENCES `clinical_trials_ecm`.`safety`.`signal`(`signal_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ADD CONSTRAINT `fk_program_program_communication_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` SET TAGS ('dbx_domain' = 'program');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` SET TAGS ('dbx_subdomain' = 'stakeholder_intelligence');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Communication Owner ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Contact Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `organization_contact_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `program_development_milestone_id` SET TAGS ('dbx_business_glossary_term' = 'Related Program Milestone ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `related_amendment_program_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Related Program Amendment ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `signal_id` SET TAGS ('dbx_business_glossary_term' = 'Safety Signal Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Electronic Trial Master File (eTMF) Document ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `acknowledgement_deadline` SET TAGS ('dbx_business_glossary_term' = 'Acknowledgement Deadline Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `acknowledgement_required` SET TAGS ('dbx_business_glossary_term' = 'Acknowledgement Required Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `acknowledgement_status` SET TAGS ('dbx_value_regex' = 'not_required|pending|partially_acknowledged|fully_acknowledged|overdue');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `body` SET TAGS ('dbx_business_glossary_term' = 'Communication Body Text');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `channel` SET TAGS ('dbx_business_glossary_term' = 'Communication Channel');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `channel` SET TAGS ('dbx_value_regex' = 'email|formal_letter|governance_meeting|teleconference|regulatory_portal|secure_messaging');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `communication_number` SET TAGS ('dbx_business_glossary_term' = 'Communication Reference Number');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `communication_number` SET TAGS ('dbx_value_regex' = '^COMM-[A-Z0-9]{3,10}-[0-9]{4}-[0-9]{4,6}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `communication_type` SET TAGS ('dbx_value_regex' = 'program_update|milestone_notification|risk_escalation|regulatory_intelligence_update|program_termination_notice|safety_notification');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `confidentiality_level` SET TAGS ('dbx_value_regex' = 'public|internal|confidential|restricted');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `follow_up_action_required` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Action Required Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `follow_up_due_date` SET TAGS ('dbx_business_glossary_term' = 'Follow-Up Action Due Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `is_regulatory_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Required Communication Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `is_safety_related` SET TAGS ('dbx_business_glossary_term' = 'Safety-Related Communication Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `owner_name` SET TAGS ('dbx_business_glossary_term' = 'Communication Owner Name');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `owner_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `owner_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `owner_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `owner_role` SET TAGS ('dbx_business_glossary_term' = 'Communication Owner Role');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `priority_level` SET TAGS ('dbx_business_glossary_term' = 'Communication Priority Level');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `priority_level` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `recipient_names` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `recipient_names` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `recipient_names` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `regulatory_submission_reference` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission Reference Number');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `response_received` SET TAGS ('dbx_business_glossary_term' = 'Response Received Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `safety_event_reference` SET TAGS ('dbx_business_glossary_term' = 'Safety Event Reference Number');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `source_system_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `subject_summary` SET TAGS ('dbx_business_glossary_term' = 'Communication Subject Summary');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `tmf_zone` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Zone');

ALTER TABLE `clinical_trials_ecm`.`program`.`program_communication` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ADD CONSTRAINT `fk_program_competitive_intelligence_analyst_employee_id` FOREIGN KEY (`analyst_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ADD CONSTRAINT `fk_program_competitive_intelligence_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ADD CONSTRAINT `fk_program_competitive_intelligence_indication_id` FOREIGN KEY (`indication_id`) REFERENCES `clinical_trials_ecm`.`program`.`indication`(`indication_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ADD CONSTRAINT `fk_program_competitive_intelligence_pipeline_asset_id` FOREIGN KEY (`pipeline_asset_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`pipeline_asset`(`pipeline_asset_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ADD CONSTRAINT `fk_program_competitive_intelligence_superseded_competitive_intelligence_id` FOREIGN KEY (`superseded_competitive_intelligence_id`) REFERENCES `clinical_trials_ecm`.`program`.`competitive_intelligence`(`competitive_intelligence_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` SET TAGS ('dbx_domain' = 'program');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` SET TAGS ('dbx_subdomain' = 'stakeholder_intelligence');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `analyst_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Analyst Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `analyst_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `analyst_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `pipeline_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Pipeline Asset Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `superseded_competitive_intelligence_id` SET TAGS ('dbx_self_ref_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `clinical_trial_registry_code` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Registry ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `clinical_trial_registry_code` SET TAGS ('dbx_value_regex' = '^(NCT|EUCTR|ISRCTN|JPRN|ACTRN)[0-9A-Z-]+$');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `commercial_threat_level` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low|negligible');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `commercial_threat_level` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `competitor_asset_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `competitor_asset_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `competitor_company_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `competitor_company_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Intelligence Confidence Level');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `confidence_level` SET TAGS ('dbx_value_regex' = 'confirmed|high|medium|low|unverified');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `development_phase` SET TAGS ('dbx_business_glossary_term' = 'Competitor Development Phase');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `entry_code` SET TAGS ('dbx_business_glossary_term' = 'Competitive Intelligence Entry Code');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `entry_code` SET TAGS ('dbx_value_regex' = '^CI-[A-Z0-9]{4,12}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `entry_status` SET TAGS ('dbx_business_glossary_term' = 'Competitive Intelligence Entry Status');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `entry_status` SET TAGS ('dbx_value_regex' = 'active|archived|under_review|superseded');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `go_no_go_relevance_flag` SET TAGS ('dbx_business_glossary_term' = 'Go/No-Go Relevance Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `indication_overlap_level` SET TAGS ('dbx_value_regex' = 'full|partial|adjacent|none');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `intelligence_source_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `mechanism_of_action` SET TAGS ('dbx_business_glossary_term' = 'Mechanism of Action (MoA)');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `modality` SET TAGS ('dbx_business_glossary_term' = 'Therapeutic Modality');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `partnership_licensing_notes` SET TAGS ('dbx_business_glossary_term' = 'Partnership and Licensing Notes');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `partnership_licensing_notes` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `pricing_reimbursement_notes` SET TAGS ('dbx_business_glossary_term' = 'Pricing and Reimbursement Notes');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `pricing_reimbursement_notes` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `review_frequency` SET TAGS ('dbx_value_regex' = 'weekly|monthly|quarterly|semi_annual|annual|ad_hoc');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `tpp_impact_assessment` SET TAGS ('dbx_business_glossary_term' = 'Target Product Profile (TPP) Impact Assessment');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `tpp_impact_assessment` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`competitive_intelligence` ALTER COLUMN `veeva_vault_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault Document ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri` ADD CONSTRAINT `fk_program_kri_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`kri` ADD CONSTRAINT `fk_program_kri_indicator_owner_employee_id` FOREIGN KEY (`indicator_owner_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`kri` ADD CONSTRAINT `fk_program_kri_obligation_id` FOREIGN KEY (`obligation_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`obligation`(`obligation_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`kri` ADD CONSTRAINT `fk_program_kri_parent_kri_id` FOREIGN KEY (`parent_kri_id`) REFERENCES `clinical_trials_ecm`.`program`.`kri`(`kri_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`kri` ADD CONSTRAINT `fk_program_kri_primary_previous_version_kri_id` FOREIGN KEY (`primary_previous_version_kri_id`) REFERENCES `clinical_trials_ecm`.`program`.`kri`(`kri_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`kri` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri` SET TAGS ('dbx_domain' = 'program');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri` SET TAGS ('dbx_subdomain' = 'performance_monitoring');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri` ALTER COLUMN `kri_id` SET TAGS ('dbx_business_glossary_term' = 'Program Key Risk Indicator (KRI) ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri` ALTER COLUMN `indicator_owner_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Indicator Owner Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri` ALTER COLUMN `indicator_owner_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri` ALTER COLUMN `indicator_owner_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri` ALTER COLUMN `obligation_id` SET TAGS ('dbx_business_glossary_term' = 'Obligation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri` ALTER COLUMN `parent_kri_id` SET TAGS ('dbx_self_ref_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri` ALTER COLUMN `primary_previous_version_kri_id` SET TAGS ('dbx_business_glossary_term' = 'Previous Version ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri` ALTER COLUMN `applicable_development_phase` SET TAGS ('dbx_value_regex' = 'Phase_I|Phase_II|Phase_III|Phase_IV|all_phases');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri` ALTER COLUMN `capa_required_on_breach` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Required on Breach Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri` ALTER COLUMN `dsmb_reportable` SET TAGS ('dbx_business_glossary_term' = 'Data Safety Monitoring Board (DSMB) Reportable Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri` ALTER COLUMN `indicator_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{2,6}-[A-Z]{2,6}-[0-9]{3,6}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri` ALTER COLUMN `indicator_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri` ALTER COLUMN `indicator_status` SET TAGS ('dbx_value_regex' = 'draft|active|suspended|retired|under_review');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri` ALTER COLUMN `indicator_type` SET TAGS ('dbx_business_glossary_term' = 'Indicator Type (KRI/KPI)');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri` ALTER COLUMN `indicator_type` SET TAGS ('dbx_value_regex' = 'KRI|KPI');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri` ALTER COLUMN `is_critical_path` SET TAGS ('dbx_business_glossary_term' = 'Critical Path Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri` ALTER COLUMN `is_regulatory_commitment` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Commitment Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri` ALTER COLUMN `is_safety_indicator` SET TAGS ('dbx_business_glossary_term' = 'Safety Indicator Flag');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri` ALTER COLUMN `measurement_direction` SET TAGS ('dbx_value_regex' = 'higher_is_better|lower_is_better|target_range');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri` ALTER COLUMN `reporting_period_type` SET TAGS ('dbx_value_regex' = 'rolling|cumulative|point_in_time|study_to_date');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri` ALTER COLUMN `review_cycle` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual|per_governance_meeting');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri` ALTER COLUMN `source_system_record_reference` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri` ALTER COLUMN `threshold_operator` SET TAGS ('dbx_value_regex' = 'gt|lt|gte|lte|eq|between');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ADD CONSTRAINT `fk_program_kri_reading_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ADD CONSTRAINT `fk_program_kri_reading_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ADD CONSTRAINT `fk_program_kri_reading_governance_meeting_id` FOREIGN KEY (`governance_meeting_id`) REFERENCES `clinical_trials_ecm`.`program`.`governance_meeting`(`governance_meeting_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ADD CONSTRAINT `fk_program_kri_reading_kri_id` FOREIGN KEY (`kri_id`) REFERENCES `clinical_trials_ecm`.`program`.`kri`(`kri_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ADD CONSTRAINT `fk_program_kri_reading_primary_superseded_by_reading_kri_reading_id` FOREIGN KEY (`primary_superseded_by_reading_kri_reading_id`) REFERENCES `clinical_trials_ecm`.`program`.`kri_reading`(`kri_reading_id`);

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` SET TAGS ('dbx_domain' = 'program');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` SET TAGS ('dbx_division' = 'business');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` SET TAGS ('dbx_subdomain' = 'performance_monitoring');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `kri_reading_id` SET TAGS ('dbx_business_glossary_term' = 'Program Key Risk Indicator (KRI) Reading ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Confirmed By User ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `kri_id` SET TAGS ('dbx_business_glossary_term' = 'Key Risk Indicator (KRI) Definition ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `primary_superseded_by_reading_kri_reading_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Reading ID');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `amber_threshold_lower` SET TAGS ('dbx_business_glossary_term' = 'Amber Threshold Lower Bound');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `amber_threshold_upper` SET TAGS ('dbx_business_glossary_term' = 'Amber Threshold Upper Bound');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `capa_reference` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Reference');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `computation_method` SET TAGS ('dbx_business_glossary_term' = 'KRI Computation Method');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `computation_method` SET TAGS ('dbx_value_regex' = 'automated|manual|semi_automated');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `confirmed_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Confirmation Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `consecutive_breach_count` SET TAGS ('dbx_business_glossary_term' = 'Consecutive Threshold Breach Count');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `data_snapshot_reference` SET TAGS ('dbx_business_glossary_term' = 'Data Source Snapshot Reference');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `denominator_value` SET TAGS ('dbx_business_glossary_term' = 'KRI Denominator Value');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `escalation_level` SET TAGS ('dbx_value_regex' = 'program_lead|medical_monitor|sponsor|dsmb|regulatory_authority');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `green_threshold_lower` SET TAGS ('dbx_business_glossary_term' = 'Green Threshold Lower Bound');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `green_threshold_upper` SET TAGS ('dbx_business_glossary_term' = 'Green Threshold Upper Bound');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `numerator_value` SET TAGS ('dbx_business_glossary_term' = 'KRI Numerator Value');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `observed_value` SET TAGS ('dbx_business_glossary_term' = 'Observed KRI Value');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `prior_reading_value` SET TAGS ('dbx_business_glossary_term' = 'Prior Period KRI Reading Value');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `reading_date` SET TAGS ('dbx_business_glossary_term' = 'KRI Reading Date');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `reading_reference_code` SET TAGS ('dbx_business_glossary_term' = 'KRI Reading Reference Code');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `reading_reference_code` SET TAGS ('dbx_value_regex' = '^KRI-RDG-[A-Z0-9]{4,20}-[0-9]{8}$');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `reading_status` SET TAGS ('dbx_business_glossary_term' = 'KRI Reading Status');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `reading_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|confirmed|superseded|voided');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `review_cycle_type` SET TAGS ('dbx_value_regex' = 'weekly|monthly|quarterly|ad_hoc|milestone_triggered');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `target_value` SET TAGS ('dbx_business_glossary_term' = 'KRI Target Value');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `threshold_status` SET TAGS ('dbx_business_glossary_term' = 'KRI Threshold Status (RAG Status)');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `threshold_status` SET TAGS ('dbx_value_regex' = 'green|amber|red|not_applicable|data_unavailable');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `trend_direction` SET TAGS ('dbx_business_glossary_term' = 'KRI Trend Direction');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `trend_direction` SET TAGS ('dbx_value_regex' = 'improving|stable|worsening|insufficient_data|new_metric');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `trend_magnitude` SET TAGS ('dbx_business_glossary_term' = 'KRI Trend Magnitude');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`program`.`kri_reading` ALTER COLUMN `variance_from_target` SET TAGS ('dbx_business_glossary_term' = 'Variance from KRI Target');
