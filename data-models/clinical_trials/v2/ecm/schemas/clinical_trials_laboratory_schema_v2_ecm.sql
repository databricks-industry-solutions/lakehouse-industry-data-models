-- Schema for Domain: laboratory | Business: Clinical_Trials | Version: v2_ecm
-- Generated on: 2026-11-19 16:37:32

CREATE DATABASE IF NOT EXISTS `clinical_trials_ecm`.`laboratory` COMMENT 'Manages central and local laboratory operations for clinical trials. Owns lab panel definitions, specimen collection and processing workflows, lab results (including PK/PD and DMPK data), reference ranges, critical values, sample chain of custody';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` (
    `lab_panel_id` BIGINT COMMENT 'Unique surrogate identifier for the laboratory test panel or battery record in the clinical trials lab catalog.',
    `document_sop_id` BIGINT COMMENT 'Foreign key linking to document.document_sop. Business justification: GCP-compliant labs must reference the governing SOP for each panels collection, processing, and analysis procedures.',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to, for study context and traceability.',
    `adam_dataset_mapping` STRING COMMENT 'ADaM dataset mapping; implements ADaM dataset metadata. Valid values are `^[A-Z]{4,8}$`',
    `applicable_study_phases` STRING COMMENT 'Pipe-separated list of clinical trial phases for which this panel is applicable (e.g., Phase I|Phase II|Phase III). Guides protocol designers in selecting appropriate panels for the study phase.',
    `assay_method` STRING COMMENT 'Primary analytical method or technology platform used to perform the panel (e.g., LC-MS/MS, ELISA, Flow Cytometry, Immunoturbidimetry, PCR, Automated Hematology Analyzer). Relevant for bioanalytical method validation per ICH M10.',
    `cdisc_lbcat_code` STRING COMMENT 'CDISC CT LBCAT category code; implements SDTM LB.LBCAT. Valid values are `^[A-Z0-9 ]{1,40}$`',
    `container_type` STRING COMMENT 'Type of collection tube or container required for specimen collection (e.g., EDTA tube, SST tube, Lithium Heparin tube, Urine cup). Critical for pre-analytical quality and chain of custody.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this lab panel definition record was first created in the system. Supports audit trail requirements per 21 CFR Part 11 and ALCOA+ principles.',
    `critical_value_flag` BOOLEAN COMMENT 'Indicates whether any analyte in this panel has defined critical (panic) values that require immediate notification to the investigator or site per laboratory SOP. Drives alert workflows in the EDC and CTMS.',
    `effective_end_date` DATE COMMENT 'Date after which this version of the lab panel definition is no longer valid for new protocol inclusions. Null for currently active panel versions. Supports panel retirement and version management.',
    `effective_start_date` DATE COMMENT 'Date from which this version of the lab panel definition is valid and available for protocol inclusion. Supports temporal validity management of the panel catalog.',
    `fasting_duration_hours` DECIMAL(4,1) COMMENT 'Minimum number of hours the subject must fast before specimen collection when fasting is required. Null when fasting_required is False.',
    `fasting_required` BOOLEAN COMMENT 'Indicates whether the subject must be in a fasted state (typically ≥8 hours) prior to specimen collection for this panel. Relevant for lipid panels, glucose, and insulin assays. Drives patient instructions and visit scheduling.',
    `is_biomarker_panel` BOOLEAN COMMENT 'Indicates whether this panel includes exploratory or validated biomarker assessments (e.g., genomic, proteomic, or metabolomic markers). Biomarker panels may require additional consent and specialized sample handling.',
    `is_pd_panel` BOOLEAN COMMENT 'Indicates whether this panel is a Pharmacodynamics (PD) panel measuring the biological effect of the drug. PD panels may map to CDISC SDTM LB or FA domains depending on the analyte type.',
    `is_pk_panel` BOOLEAN COMMENT 'Indicates whether this panel is a Pharmacokinetics (PK) panel used to measure drug concentration over time. PK panels map to CDISC SDTM PC domain and require specialized bioanalytical assay management.',
    `is_safety_panel` BOOLEAN COMMENT 'Indicates whether this panel is designated as a safety monitoring panel (e.g., liver function, renal function, hematology) required for adverse event assessment and DSMB/DMC review.',
    `lab_certification_standard` STRING COMMENT 'Accreditation or certification standard under which the performing laboratory is certified for this panel (e.g., CAP, ISO 15189, CLIA, GLP, GCLP). Required for regulatory submission credibility.',
    `lab_type` STRING COMMENT 'Indicates whether this panel is performed at a central laboratory (single reference lab processing all specimens), a local laboratory (site-level lab), or both.. Valid values are `central|local|both`',
    `method_validation_status` STRING COMMENT 'Validation status of the analytical method used for this panel per ICH M10 and FDA/EMA guidance. validated methods have full regulatory-grade validation; qualified methods have partial validation; exploratory methods are research-grade only.. Valid values are `validated|qualified|exploratory|not_required`',
    `panel_category` STRING COMMENT 'High-level classification of the panel by clinical discipline or analyte group (e.g., Hematology, Clinical Chemistry, Coagulation, Urinalysis, Immunology, Pharmacokinetics, Biomarker).',
    `panel_code` STRING COMMENT 'Externally-known, sponsor- or CRO-assigned alphanumeric code uniquely identifying the lab panel within the study catalog (e.g., CHEM20, CBC, LFT). Used as the business key for cross-system reference and CDISC SDTM LBTESTCD mapping.. Valid values are `^[A-Z0-9_-]{2,30}$`',
    `panel_name` STRING COMMENT 'Full human-readable name of the laboratory test panel or battery (e.g., Complete Blood Count, Comprehensive Metabolic Panel, Liver Function Tests). Maps to CDISC SDTM LBTEST.',
    `panel_short_name` STRING COMMENT 'Abbreviated display name for the panel used in eCRF headers, reports, and dashboards where space is constrained (e.g., CBC, CMP, LFT).. Valid values are `^[A-Za-z0-9 /()-]{1,40}$`',
    `panel_status` STRING COMMENT 'Current lifecycle status of the lab panel definition in the catalog. active panels are available for protocol inclusion; retired panels are no longer used in new studies; draft panels are pending validation.. Valid values are `active|inactive|draft|retired|under_review`',
    `panel_subcategory` STRING COMMENT 'Secondary classification within the panel category providing finer granularity (e.g., within Clinical Chemistry: Liver Function, Renal Function, Lipid Panel). Maps to CDISC SDTM LBSCAT.',
    `reference_range_source` STRING COMMENT 'Source of the normal reference ranges applied to results from this panel. Central lab-derived ranges are preferred for regulatory submissions; sponsor-defined ranges may be used for novel biomarkers.. Valid values are `central_lab|local_lab|sponsor_defined|literature|regulatory_guidance`',
    `regulatory_submission_required` BOOLEAN COMMENT 'Indicates whether results from this panel must be included in regulatory submissions (IND, NDA, BLA, MAA). Drives data management and CDISC SDTM/ADaM transformation requirements.',
    `sdtm_domain` STRING COMMENT 'Target SDTM domain for this panel; implements SDTM Dataset.DOMAIN. Valid values are `LB|PC|PP|FA|MB|MI`',
    `shipping_condition` STRING COMMENT 'Required temperature condition for shipping specimens from the clinical site to the central laboratory. Governs cold chain logistics, packaging requirements, and IATA compliance for biological specimens.. Valid values are `ambient|refrigerated|dry_ice|liquid_nitrogen|frozen`',
    `source_system_code` STRING COMMENT 'Code identifying the operational system of record from which this lab panel definition was sourced (e.g., Medidata Rave, the source system LIMS). Supports data lineage and Silver Layer provenance tracking.. Valid values are `medidata_rave|oracle_clinical_one|ctms|manual|lims`',
    `specimen_collection_method` STRING COMMENT 'Standardized method used to collect the specimen (e.g., Venipuncture, Finger Stick, Midstream Catch, Lumbar Puncture). Maps to CDISC SDTM LBMETHOD. [ENUM-REF-CANDIDATE: venipuncture|finger_stick|midstream_catch|lumbar_puncture|biopsy|swab|catheterization',
    `specimen_type` STRING COMMENT 'Primary biological specimen type required for this panel (e.g., Whole Blood, Serum, Plasma, Urine, CSF, Tissue Biopsy). Maps to CDISC SDTM LBSPEC. [ENUM-REF-CANDIDATE: whole_blood|serum|plasma|urine|csf|tissue|saliva|stool|bone_marrow|synovial_fluid —',
    `specimen_volume_ml` DECIMAL(8,3) COMMENT 'Minimum volume of specimen required in millilitres to perform all analytes in the panel. Used for phlebotomy planning, patient burden assessment, and paediatric study feasibility.',
    `stability_hours_ambient` DECIMAL(8,2) COMMENT 'Maximum number of hours the collected specimen remains analytically stable at ambient temperature (15–25°C) before processing or freezing is required. Critical for chain of custody and pre-analytical quality management.',
    `stability_hours_refrigerated` DECIMAL(8,2) COMMENT 'Maximum number of hours the collected specimen remains analytically stable when stored refrigerated (2–8°C). Used to define shipping and processing windows for central lab specimens.',
    `stat_turnaround_time_hours` DECIMAL(6,2) COMMENT 'Expedited turnaround time in hours for urgent (STAT) requests, typically triggered by safety events or critical value alerts. Distinct from standard SLA turnaround time.',
    `storage_temperature` STRING COMMENT 'Required storage temperature condition for the specimen prior to analysis (e.g., ambient, refrigerated 2–8°C, frozen –20°C, frozen –80°C). Governs cold chain logistics and sample chain of custody.. Valid values are `ambient|refrigerated|frozen_minus20|frozen_minus80|dry_ice|liquid_nitrogen`',
    `turnaround_time_hours` DECIMAL(6,2) COMMENT 'Contracted or target turnaround time in hours from specimen receipt at the laboratory to result reporting. Used for SLA monitoring, site management, and safety decision timelines. Critical for SAE-related panels.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this lab panel definition record was most recently modified. Supports change tracking, audit trail requirements, and data lineage in the Databricks Silver Layer.',
    `version_number` STRING COMMENT 'Version number of the lab panel definition (e.g., 1.0, 2.1). Tracks changes to panel specifications over time to support audit trails and protocol amendment management.. Valid values are `^d+.d+$`',
    `visit_timepoints` STRING COMMENT 'Comma-separated list of protocol visit names or codes at which this panel is scheduled (e.g., Screening, Day 1, Week 4, Week 8, End of Treatment, Follow-Up). Supports protocol schedule of assessments design and EDC form configuration.',
    CONSTRAINT pk_lab_panel PRIMARY KEY(`lab_panel_id`)
) COMMENT 'Master definition of a laboratory test panel or battery used in clinical trials. Captures panel code, name, specimen type requirements, analyte list, applicable study phases, CDISC SDTM domain mapping (LB), turnaround time SLA, and whether the panel is';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` (
    `lab_facility_id` BIGINT COMMENT 'Unique surrogate identifier for the laboratory facility record. Primary key for the lab_facility data product. Role: MASTER_RESOURCE.',
    `organization_id` BIGINT COMMENT 'add column organization_id (BIGINT) with FK to sponsor.organization.organization_id — lab facilities are operated by organizations',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to, for study context and traceability.',
    `address_line1` STRING COMMENT 'Primary street address line of the laboratory facility. Used for specimen shipment labels, regulatory correspondence, and audit documentation.',
    `address_line2` STRING COMMENT 'Secondary address line (suite, floor, building) for the laboratory facility. Supplements address_line1 for complete mailing and shipment address.',
    `biobanking_capable` BOOLEAN COMMENT 'Indicates whether the laboratory facility has certified long-term specimen storage (biobanking) capabilities, including controlled-temperature archival storage. Relevant for studies requiring retained samples for future exploratory analyses.',
    `cap_accreditation_number` STRING COMMENT 'Accreditation number issued by the College of American Pathologists (CAP) confirming the laboratory meets rigorous quality standards. Widely recognized by sponsors and regulatory agencies as evidence of laboratory quality. Null if not CAP-accredited.',
    `city` STRING COMMENT 'City in which the laboratory facility is physically located. Used for geographic reporting, logistics planning, and specimen shipment routing.',
    `clia_number` STRING COMMENT 'Federal CLIA certificate number issued by CMS to U.S. clinical laboratories authorizing them to perform testing on human specimens. Required for regulatory compliance and sponsor qualification audits. Null for non-U.S. facilities.. Valid values are `^[0-9]{2}D[0-9]{7}$`',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 three-letter country code for the country in which the laboratory facility is physically located (e.g., USA, GBR, DEU). Drives regulatory jurisdiction determination and applicable accreditation standards.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the laboratory facility record was first created in the system. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `dmpk_analysis_capable` BOOLEAN COMMENT 'Indicates whether the laboratory facility is equipped and validated to perform Drug Metabolism and Pharmacokinetics (DMPK) analyses, including metabolite profiling and enzyme characterization studies.',
    `edi_lab_code` STRING COMMENT 'Standardized laboratory code used in electronic data interchange (EDI) transmissions between the laboratory and EDC/CTMS systems. Aligns with CDISC LAB data standards for lab results transfer.',
    `facility_code` STRING COMMENT 'Externally-known, human-readable unique business identifier for the laboratory facility (e.g., LAB-CENT-001). Used in study protocols, eCRFs, and regulatory submissions to reference the facility.. Valid values are `^[A-Z0-9_-]{3,20}$`',
    `facility_name` STRING COMMENT 'Official legal or operating name of the laboratory facility as registered with accreditation bodies and regulatory authorities. Serves as the IDENTITY_LABEL per MASTER_RESOURCE canonical requirements.',
    `facility_type` STRING COMMENT 'Classification of the laboratory facility by its operational role in clinical trials. Central labs process specimens from multiple sites; local labs are site-affiliated; bioanalytical labs perform assay development and sample analysis; PK/DMPK labs focus. Valid values are `central|local|bioanalytical|pk_dmpk|specialty|reference`',
    `flow_cytometry_capable` BOOLEAN COMMENT 'Indicates whether the laboratory facility has validated flow cytometry capabilities for immunophenotyping and cell-based assays, commonly required in oncology and immunology trials.',
    `gcp_certified` BOOLEAN COMMENT 'Indicates whether the laboratory facility holds a current Good Clinical Practice (GCP) certification or has been qualified under GCP guidelines by the sponsor or CRO. Required for laboratories participating in regulated clinical trials.',
    `genomics_capable` BOOLEAN COMMENT 'Indicates whether the laboratory facility is equipped to perform genomic analyses (e.g., PCR, NGS, genotyping) relevant to pharmacogenomics endpoints in clinical trials.',
    `glp_certified` BOOLEAN COMMENT 'Indicates whether the laboratory facility is certified under Good Laboratory Practice (GLP) regulations, required for non-clinical safety studies and certain bioanalytical work supporting regulatory submissions.',
    `iso_15189_certificate_number` STRING COMMENT 'Certificate number issued by a national accreditation body (e.g., UKAS, DAkkS, COFRAC) confirming the laboratory conforms to ISO 15189 requirements for medical laboratories. Recognized internationally for cross-border clinical trial operations.',
    `lims_system_code` STRING COMMENT 'Unique identifier for this facility within its Laboratory Information Management System (LIMS). Used for electronic data exchange, specimen tracking, and results transmission to EDC systems such as Medidata Rave.',
    `lims_vendor` STRING COMMENT 'Name of the LIMS software vendor used by the facility (e.g., LabVantage, STARLIMS, LabWare). Relevant for EDC integration planning and data transfer agreement scoping.',
    `medical_director_name` STRING COMMENT 'Full name of the licensed physician or doctoral scientist serving as the laboratorys Medical Director, as required by CLIA and CAP accreditation. Accountable for overall laboratory quality and regulatory compliance.',
    `network_affiliation` STRING COMMENT 'Name of the central laboratory network or parent organization to which this facility belongs (e.g., Covance, Q2 Solutions, BioReference, PPD). Used for contract management, network-level performance reporting, and escalation routing.',
    `normal_hours_of_operation` STRING COMMENT 'Description of the laboratory facilitys standard operating hours (e.g., Mon-Fri 07:00-19:00 EST). Used for specimen shipment scheduling, turnaround time SLA definition, and site coordinator guidance.',
    `operational_status` STRING COMMENT 'Current lifecycle state of the laboratory facility indicating whether it is actively accepting specimens for clinical trial studies. Drives eligibility for new study assignments and site qualification workflows.. Valid values are `active|inactive|suspended|pending_qualification|decommissioned`',
    `pk_analysis_capable` BOOLEAN COMMENT 'Indicates whether the laboratory facility is equipped and validated to perform pharmacokinetic (PK) sample analysis, including bioanalytical assays for drug concentration measurement.',
    `postal_code` STRING COMMENT 'Postal or ZIP code of the laboratory facilitys physical address. Used for specimen shipment logistics and geographic analysis.',
    `preferred_courier` STRING COMMENT 'Name of the preferred or contracted courier service for specimen shipment to this facility (e.g., World Courier, Marken, FedEx Custom Critical). Used for logistics planning and chain-of-custody documentation.',
    `primary_contact_email` STRING COMMENT 'Email address of the primary operational contact at the laboratory facility. Used for study coordination communications, specimen shipment notifications, and results transmission alerts.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `primary_contact_name` STRING COMMENT 'Full name of the primary operational contact person at the laboratory facility (e.g., Laboratory Director or Operations Manager). Used for study coordination, issue escalation, and regulatory correspondence.',
    `primary_contact_phone` STRING COMMENT 'Primary telephone number for the laboratory facilitys operational contact. Used for urgent specimen handling queries, critical value notifications, and logistics coordination.. Valid values are `^+?[0-9s-().]{7,20}$`',
    `qualification_expiry_date` DATE COMMENT 'Date on which the sponsor or CRO qualification of the laboratory facility expires, requiring re-qualification before the facility can be assigned to new studies.',
    `qualification_status` STRING COMMENT 'Sponsor or CRO qualification status of the laboratory facility, reflecting the outcome of vendor qualification audits and ongoing performance reviews. Determines whether the facility may be assigned to new studies.. Valid values are `qualified|conditionally_qualified|not_qualified|qualification_expired|under_review`',
    `regulatory_certifications` STRING COMMENT 'Comma-separated list of additional regulatory certifications held by the facility beyond primary accreditation (e.g., FDA-registered, EMA-compliant, PMDA-approved, NY State DOH). Supports multi-jurisdictional study eligibility assessment.',
    `specimen_capacity_per_day` BIGINT COMMENT 'Maximum number of specimens the facility can process per business day under normal operating conditions. Used for capacity planning, site feasibility assessments, and study logistics.',
    `specimen_receipt_cutoff_time` TIMESTAMP COMMENT 'Latest time of day (HH:MM, 24-hour format, local facility time) by which specimens must be received to be processed on the same business day. Critical for study protocol logistics and turnaround time commitments.',
    `state_province` STRING COMMENT 'State, province, or region in which the laboratory facility is physically located. Used for regulatory jurisdiction mapping and logistics.',
    `time_zone` STRING COMMENT 'IANA time zone identifier for the laboratory facilitys local time (e.g., America/New_York, Europe/London). Used for specimen receipt timestamp normalization, turnaround time calculations, and critical value notification SLA tracking.',
    `turnaround_time_standard_hours` BIGINT COMMENT 'Standard turnaround time in hours from specimen receipt to results availability for routine panels. Used in study feasibility assessments and service level agreement (SLA) monitoring.',
    `turnaround_time_stat_hours` BIGINT COMMENT 'Turnaround time in hours for STAT (urgent) specimen processing. Used for safety monitoring protocols where rapid results are required for subject safety decisions.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the laboratory facility record was most recently modified. Supports audit trail requirements and change tracking per 21 CFR Part 11 and ALCOA+ data integrity principles.',
    CONSTRAINT pk_lab_facility PRIMARY KEY(`lab_facility_id`)
) COMMENT 'Master record for central and local laboratory facilities performing specimen analysis for clinical trials. Captures facility name, type (central/local/bioanalytical/PK), CLIA/CAP/ISO 15189 accreditation status, accreditation expiry, regulatory';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`laboratory`.`specimen` (
    `specimen_id` BIGINT COMMENT 'Unique surrogate identifier for each biological specimen record in the laboratory data product. Primary key for the specimen entity.',
    `employee_id` BIGINT COMMENT 'Reference to the clinical staff member (e.g., Clinical Research Coordinator (CRC), nurse, phlebotomist) who performed the specimen collection. Required for ALCOA+ attributability and GCP audit trail.',
    `lab_facility_id` BIGINT COMMENT 'Reference to the central or local laboratory responsible for analyzing this specimen. Used for lab-level quality monitoring, accreditation tracking, and result attribution.',
    `lab_panel_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_panel. Business justification: A specimen is collected for a specific laboratory panel (e.g., a CBC panel, chemistry panel). The assay_panel_code STRING column on specimen is a denormalized reference to lab_panel.',
    `parent_specimen_id` BIGINT COMMENT 'Reference to the parent specimen from which this aliquot was derived. Null for primary specimens. Enables full chain-of-custody traceability from primary collection through all downstream aliquots.',
    `shipment_id` BIGINT COMMENT 'Reference to the shipment record under which this specimen was transported to the central laboratory or biorepository. Enables chain-of-custody tracking and cold-chain compliance verification.',
    `specimen_collection_id` BIGINT COMMENT 'Foreign key linking to laboratory.specimen_collection. Business justification: A specimen is produced by a specimen collection event. The specimen_collection table records the scheduled or unscheduled collection event, while specimen records the physical',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to, for study context and traceability.',
    `study_site_id` BIGINT COMMENT 'Reference to the clinical site where the specimen was collected. Used for site-level quality monitoring and logistics.',
    `study_visit_schedule_id` BIGINT COMMENT 'Foreign key linking to study.study_visit_schedule. Business justification: Specimens are collected at protocol-defined visits; linking to the visit schedule enables deviation detection (collection outside visit window), SDTM domain mapping, and protocol',
    `subject_visit_id` BIGINT COMMENT 'Reference to the scheduled or unscheduled study visit during which this specimen was collected. Enables visit-level specimen tracking.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial subject (participant) from whom this specimen was collected. Core linkage for subject-level traceability.',
    `actual_timepoint_hours` DECIMAL(10,4) COMMENT 'Actual elapsed time in hours from the reference event (e.g., dose administration) to specimen collection. Critical for pharmacokinetic (PK) and pharmacodynamic (PD) analysis and nominal time deviation assessment.',
    `aliquot_sequence_number` BIGINT COMMENT 'Sequential number identifying the order of this aliquot within the set of aliquots derived from the same parent specimen (e.g., 1, 2, 3). Null for primary specimens. Used for aliquot management and laboratory workflow.',
    `barcode` STRING COMMENT 'Unique barcode or label identifier affixed to the specimen container at the point of collection. Used for physical tracking and LIMS accession matching. Serves as the primary operational identifier in the laboratory.',
    `chain_of_custody_status` STRING COMMENT 'Current status of the specimens chain of custody documentation. Intact indicates unbroken custody from collection to current location; broken indicates a gap requiring investigation. Critical for regulatory and legal defensibility of specimen data.. Valid values are `intact|broken|under_investigation`',
    `collection_body_site` STRING COMMENT 'Anatomical collection location; implements SDTM --LOC',
    `collection_datetime` TIMESTAMP COMMENT 'Date and time at which the specimen was collected from the subject. Principal real-world event timestamp for the specimen. Used for PK/PD time-point calculations, protocol compliance, and ALCOA+ data integrity requirements.',
    `collection_deviation_description` STRING COMMENT 'Free-text description of the collection deviation when collection_deviation_flag is True (e.g., incorrect tube used, delayed processing, missed time window). Supports protocol deviation reporting and CAPA.',
    `collection_deviation_flag` BOOLEAN COMMENT 'Indicates whether a protocol deviation occurred during specimen collection (True) or not (False). Triggers deviation documentation workflow and may affect specimen usability for primary analysis.',
    `collection_kit_lot_number` STRING COMMENT 'Lot number of the collection kit used for specimen collection. Required for traceability of kit materials, deviation investigation, and supply chain accountability.',
    `collection_method` STRING COMMENT 'Procedure or technique used to collect the specimen (e.g., venipuncture, fingerstick, lumbar puncture, biopsy, swab). Affects pre-analytical processing and result interpretation.',
    `collection_tube_type` STRING COMMENT 'Type of collection tube or container used (e.g., EDTA, SST, lithium heparin, sodium citrate, PAXgene). Critical for pre-analytical integrity and analyte stability. Aligns with laboratory manual specifications.',
    `condition_on_arrival` STRING COMMENT 'Assessment of the specimens physical condition upon receipt at the laboratory (e.g., acceptable, hemolyzed, lipemic, temperature excursion). Determines whether the specimen is suitable for analysis or requires rejection/re-collection.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time at which this specimen record was first created in the system. Required for ALCOA+ audit trail, 21 CFR Part 11 compliance, and data lineage tracking.',
    `destruction_date` DATE COMMENT 'Date on which the specimen was destroyed or disposed of, in accordance with the protocol-defined retention period and applicable regulations. Required for regulatory accountability and chain-of-custody closure.',
    `disposition_status` STRING COMMENT 'Current lifecycle status of the specimen within the laboratory workflow. Drives operational actions and regulatory accountability. [ENUM-REF-CANDIDATE: pending_receipt|received|in_analysis|analyzed|stored|shipped|destroyed|rejected|lost — promote to',
    `expiry_date` DATE COMMENT 'Date after which the specimen is no longer considered analytically valid for its intended assay(s). Determined by specimen type, storage conditions, and analyte stability data. Used to flag specimens requiring re-collection or exclusion.',
    `fasting_status` STRING COMMENT 'Fasting status of the subject at the time of specimen collection (fasted, non-fasted, unknown). Required for metabolic panels, lipid profiles, and glucose assays where fasting state affects reference ranges.. Valid values are `fasted|non_fasted|unknown`',
    `freeze_thaw_cycles` BIGINT COMMENT 'Number of freeze-thaw cycles the specimen has undergone. Excessive freeze-thaw cycles can degrade analyte integrity; this field is used to assess specimen quality and flag specimens that may yield unreliable results.',
    `is_primary` BOOLEAN COMMENT 'Indicates whether this specimen record represents the primary (original) specimen (True) or an aliquot derived from a parent specimen (False). Drives chain-of-custody logic and parent-child specimen relationships.',
    `lims_accession_number` STRING COMMENT 'Accession number assigned by the Laboratory Information Management System (LIMS) upon receipt of the specimen at the central or local laboratory. Used for laboratory workflow tracking and result linkage.',
    `pre_analytical_processing` STRING COMMENT 'Description of pre-analytical processing steps performed on the specimen prior to analysis or storage (e.g., centrifugation speed/duration, temperature, time to processing). Critical for result interpretation and protocol compliance.',
    `processing_datetime` TIMESTAMP COMMENT 'Date and time at which pre-analytical processing of the specimen was completed. Used to calculate time-from-collection-to-processing, a key pre-analytical quality metric per laboratory manual requirements.',
    `receipt_datetime` TIMESTAMP COMMENT 'Date and time at which the specimen was received at the central or local laboratory. Used to calculate transit time, assess cold-chain compliance, and trigger LIMS accession workflows.',
    `rejection_reason` STRING COMMENT 'Reason for specimen rejection when disposition_status is rejected (e.g., insufficient volume, wrong tube type, temperature excursion, unlabelled, clotted). Required for deviation tracking and re-collection decisions.',
    `storage_location` STRING COMMENT 'Physical storage location of the specimen within the laboratory or biorepository (e.g., freezer ID, rack, box, position). Required for specimen retrieval, inventory management, and chain-of-custody documentation.',
    `storage_temperature_c` DECIMAL(5,2) COMMENT 'Required storage temperature for this specimen in degrees Celsius (e.g., -80, -20, 2-8, ambient). Used to verify cold-chain compliance and specimen integrity throughout the chain of custody.',
    `subject_number` STRING COMMENT 'Human-readable subject identifier (e.g., site-subject number) as assigned in the clinical trial management system. Used for cross-system reconciliation and regulatory reporting. Classified as restricted PII as it can identify a trial participant.',
    `specimen_type` STRING COMMENT 'Biological matrix type of the specimen collected from the subject (e.g., blood, urine, plasma, serum, cerebrospinal fluid (CSF), tissue). Drives pre-analytical processing rules and reference range selection.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time at which this specimen record was most recently modified. Required for ALCOA+ audit trail, 21 CFR Part 11 compliance, and data lineage tracking in the Databricks Silver layer.',
    `volume_collected_ml` DECIMAL(10,4) COMMENT 'Volume of biological material collected from the subject, expressed in millilitres (mL). Used to verify adequacy for planned assays, assess protocol compliance, and support chain-of-custody documentation.',
    CONSTRAINT pk_specimen PRIMARY KEY(`specimen_id`)
) COMMENT 'Master record for each biological specimen collected from a trial subject, including collection event details. Captures specimen barcode/ID, subject ID, visit reference, collection date/time, specimen type (blood, urine, CSF, tissue), collection tube';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` (
    `laboratory_lab_result_id` BIGINT COMMENT 'Unique surrogate identifier for each laboratory test result record in the Silver Layer lakehouse. Primary key for the lab_result data product.',
    `arm_id` BIGINT COMMENT 'Foreign key linking to study.study_arm. Business justification: Safety lab results must be analyzed by treatment arm for DSMB safety reviews, regulatory submissions, and ADaM ADLB dataset generation.',
    `critical_value_id` BIGINT COMMENT 'Foreign key linking to laboratory.critical_value. Business justification: When a lab result triggers a critical value alert (critical_value_flag = TRUE), it should reference the specific critical_value threshold definition that was breached.',
    `ctcae_grade_id` BIGINT COMMENT 'Foreign key linking to terminology.ctcae_grade. Business justification: Lab results are graded per CTCAE criteria to determine AE reporting obligations. Formalizing lab_result→ctcae_grade supports the regulatory process of identifying reportable lab-based',
    `epoch_id` BIGINT COMMENT 'Foreign key linking to study.study_epoch. Business justification: SDTM LB domain requires epoch assignment for all lab results. Safety monitoring by epoch (screening vs treatment vs follow-up) is standard in DSMB reports and regulatory submissions.',
    `lab_analyte_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_analyte. Business justification: A lab result is for a specific analyte. The lbtestcd, lbtest, and loinc_code columns on lab_result are denormalized from the lab_analyte reference master.',
    `lab_facility_id` BIGINT COMMENT 'Reference to the central or local laboratory that performed the analysis and reported this result. Supports lab certification and accreditation tracking.',
    `lab_panel_id` BIGINT COMMENT 'Reference to the laboratory panel definition that groups this analyte test within a scheduled assessment (e.g., hematology panel, chemistry panel, urinalysis).',
    `loinc_id` BIGINT COMMENT 'add column loinc_id (BIGINT) with FK to terminology.loinc.loinc_id — per user vibes instruction 6, lab results received through eSource must record their LOINC code',
    `primary_laboratory_ehr_source_system_id` BIGINT COMMENT 'add column ehr_source_system_id (BIGINT) with FK to datamanagement.ehr_source_system.ehr_source_system_id — per user vibes instruction 6, lab results from eSource must record source system',
    `primary_laboratory_primary_code_system_version_id` BIGINT COMMENT 'Foreign key to code system version for LOINC dictionary version applied',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Lab results must be evaluated against protocol-defined CTCAE grading rules and reference ranges for the specific protocol version. SDTM LB domain submissions require protocol traceability.',
    `reference_range_id` BIGINT COMMENT 'Foreign key linking to laboratory.reference_range. Business justification: A lab result is evaluated against a specific reference range definition. The reference_range_source STRING column is a denormalized pointer to the reference_range master.',
    `source_ehr_source_system_id` BIGINT COMMENT 'laboratory.ehr_source_system.ehr_source_system_id',
    `specimen_id` BIGINT COMMENT 'Reference to the biological specimen from which this laboratory result was derived. Links to the specimen/sample chain-of-custody record.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) under which this laboratory result was generated. Enables study-level aggregation and regulatory submission.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site where the specimen was collected or the local laboratory is located.',
    `study_visit_schedule_id` BIGINT COMMENT 'Foreign key linking to study.study_visit_schedule. Business justification: Lab results must be mapped to protocol-defined visit definitions for SDTM LB domain generation, visit-window compliance reporting, and primary endpoint analysis.',
    `subject_randomization_id` BIGINT COMMENT 'Foreign key linking to randomization.subject_randomization. Business justification: SDTM LB domain and ADaM safety analysis require lab results linked to treatment arm assignment.',
    `subject_visit_id` BIGINT COMMENT 'Reference to the scheduled or unscheduled study visit during which the specimen was collected. Supports visit-level data review and SDTM VISITNUM mapping.',
    `tertiary_laboratory_lab_code_system_version_id` BIGINT COMMENT 'Foreign key to code system version for LOINC dictionary version applied to this lab result',
    `tertiary_quaternary_laboratory_loinc_code_system_version_id` BIGINT COMMENT 'LOINC dictionary version applied to this laboratory result',
    `trial_subject_id` BIGINT COMMENT 'Reference to the clinical trial subject (patient) from whom the specimen was collected. Core linkage for subject-level safety and efficacy analysis.',
    `collection_datetime` TIMESTAMP COMMENT 'Date/time of specimen collection; implements SDTM LB.LBDTC',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this laboratory result record was first created in the data management system. Audit trail field required for 21 CFR Part 11 compliance and ALCOA+ data integrity principles.',
    `critical_value_flag` BOOLEAN COMMENT 'Indicates whether this result meets the laboratorys critical (panic) value threshold requiring immediate clinical notification. True triggers safety review workflow and potential SAE/AE assessment per protocol.',
    `data_origin` STRING COMMENT 'Source system or method by which this laboratory result was entered into the data management system. EDC: entered via Medidata Rave eCRF; LAB_DIRECT: electronic lab data transfer; MANUAL: manual data entry; MIGRATION: legacy data migration; BIOANALYTICAL. Valid values are `EDC|LAB_DIRECT|MANUAL|MIGRATION|BIOANALYTICAL`',
    `dbl_included_flag` BOOLEAN COMMENT 'Indicates whether this result was included in the locked database at the time of Database Lock (DBL). False indicates the result was added or modified post-lock (requires formal database unlock procedure). Critical for regulatory submission integrity.',
    `fasting_status` STRING COMMENT 'Fasting status; implements SDTM LB.LBFAST. Valid values are `FASTING|NON-FASTING|UNKNOWN`',
    `fhir_resource_reference` STRING COMMENT 'FHIR resource reference to source Observation; implements FHIR Reference.reference',
    `fhir_resource_type` STRING COMMENT 'FHIR resource type; implements FHIR Resource.resourceType',
    `lbcat` STRING COMMENT 'Lab category; implements SDTM LB.LBCAT. Valid values are `HEMATOLOGY|CHEMISTRY|URINALYSIS|COAGULATION|IMMUNOLOGY|OTHER`',
    `lbscat` STRING COMMENT 'Lab subcategory; implements SDTM LB.LBSCAT',
    `method` STRING COMMENT 'Test method; implements SDTM LB.LBMETHOD',
    `normal_range_lower` DECIMAL(18,6) COMMENT 'Reference range lower limit; implements SDTM LB.LBORNRLO',
    `normal_range_upper` DECIMAL(18,6) COMMENT 'Reference range upper limit; implements SDTM LB.LBORNRHI',
    `out_of_range_flag` BOOLEAN COMMENT 'Out-of-range indicator; implements SDTM LB.LBNRIND',
    `query_open_flag` BOOLEAN COMMENT 'Indicates whether there is at least one open data query (discrepancy) associated with this laboratory result in the EDC system (Medidata Rave). Supports data management workflow and DBL readiness tracking.',
    `result_comment` STRING COMMENT 'Free-text comment from the laboratory or data manager regarding this result (e.g., hemolyzed sample, lipemic specimen, instrument flag, repeat analysis note). Supports data review and query resolution.',
    `result_received_datetime` TIMESTAMP COMMENT 'Date and time when the laboratory result was received by the sponsor/CRO data management system (EDC or CTMS). Used for turnaround time monitoring and critical value notification tracking.',
    `result_reported_datetime` TIMESTAMP COMMENT 'Date and time when the laboratory formally reported and released the result. Distinct from collection and receipt timestamps. Used for lab turnaround time KPI calculation and audit trail.',
    `result_seq_num` BIGINT COMMENT 'Sequential number identifying the order of this result record within the subjects laboratory data. Maps to CDISC SDTM LBSEQ variable for dataset generation.',
    `result_standard_unit` STRING COMMENT 'Standardized unit; implements SDTM LB.LBSTRESU (CDISC CT UNIT codelist)',
    `result_status` STRING COMMENT 'Current lifecycle status of the laboratory result indicating its data quality and review state. PRELIMINARY: initial unverified result; FINAL: verified and released; CORRECTED: amended after final release; CANCELLED: voided result; AMENDED: modified with. Valid values are `PRELIMINARY|FINAL|CORRECTED|CANCELLED|AMENDED`',
    `result_unit` STRING COMMENT 'Original result unit; implements SDTM LB.LBORRESU (CDISC CT UNIT codelist)',
    `result_value` DECIMAL(18,2) COMMENT 'Original result value; implements SDTM LB.LBORRES',
    `result_value_numeric` DECIMAL(18,6) COMMENT 'Standardized numeric result; implements SDTM LB.LBSTRESN',
    `sdv_status` STRING COMMENT 'Status of source data verification (SDV) for this laboratory result, performed by the Clinical Research Associate (CRA) against source documents. Supports risk-based monitoring and GCP compliance.. Valid values are `NOT REQUIRED|PENDING|VERIFIED|DISCREPANT`',
    `source_fhir_resource` STRING COMMENT 'Source eSource FHIR resource; implements FHIR Observation',
    `source_system_code` BIGINT COMMENT 'Foreign key to the source system reference that supplied this record',
    `study_day` BIGINT COMMENT 'Study day of collection; implements SDTM LB.LBDY',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this laboratory result record was last modified. Audit trail field required for 21 CFR Part 11 compliance. Tracks corrections, amendments, and status changes throughout the data lifecycle.',
    `usubjid` STRING COMMENT 'Globally unique subject identifier in the format STUDYID-SITEID-SUBJID, as defined by CDISC SDTM. Required for regulatory submission datasets and cross-study subject traceability.',
    `esource_record_id` STRING COMMENT 'The esource record id of the laboratory lab result.',
    `esource_capture_datetime` TIMESTAMP COMMENT 'The esource capture datetime of the laboratory lab result.',
    `esource_system_name` STRING COMMENT 'The esource system name of the laboratory lab result.',
    `esource_verified_flag` BOOLEAN COMMENT 'Indicator for esource verified flag on the laboratory lab result.',
    CONSTRAINT pk_laboratory_lab_result PRIMARY KEY(`laboratory_lab_result_id`)
) COMMENT 'Transactional record of a laboratory test result for a specific analyte from a subject specimen. Captures analyte name, LOINC code, result value, result unit, normal range lower/upper bound, reference range source, result status';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` (
    `specimen_collection_id` BIGINT COMMENT 'Unique surrogate identifier for each specimen collection event record in the clinical trial laboratory domain. Primary key for this transactional entity.',
    `adverse_event_id` BIGINT COMMENT 'Foreign key linking to safety.adverse_event. Business justification: Unscheduled specimen collections are triggered by AEs (is_unscheduled flag exists). Linking specimen_collection to the triggering adverse_event supports AE-driven collection',
    `arm_id` BIGINT COMMENT 'Foreign key linking to study.study_arm. Business justification: Safety and PD specimen collections are arm-specific in randomized trials. Arm-level collection compliance reporting, DSMB safety reviews, and SDTM LB domain generation require linking',
    `consent_icf_version_id` BIGINT COMMENT 'Foreign key linking to consent.consent_icf_version. Business justification: GCP monitoring requires verification that each collection event was covered by the then-current IRB/IEC-approved ICF version.',
    `consent_subject_consent_id` BIGINT COMMENT 'Foreign key linking to consent.subject_consent. Business justification: GCP monitoring requires proof that each specimen collection event occurred under a valid, active informed consent.',
    `ecrf_form_id` BIGINT COMMENT 'Reference to the eCRF (Electronic Case Report Form) form in the EDC system (Medidata Rave) where this specimen collection event was recorded. Supports data lineage and source data verification (SDV).',
    `employee_id` BIGINT COMMENT 'Reference to the Clinical Research Coordinator (CRC), phlebotomist, or other qualified personnel who performed the specimen collection. Required for ALCOA+ attributability and GCP compliance.',
    `lab_kit_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_kit. Business justification: A specimen collection event uses a specific laboratory collection kit supplied to the site.',
    `lab_panel_id` BIGINT COMMENT 'Reference to the protocol-defined laboratory panel or test battery that this specimen collection is intended to fulfill.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Specimen collections must be evaluated against the protocol version in effect at time of collection for protocol deviation assessment and regulatory audit.',
    `protocol_lab_schedule_id` BIGINT COMMENT 'Foreign key linking to laboratory.protocol_lab_schedule. Business justification: A specimen collection event is the operational execution of a protocol-mandated lab assessment schedule.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study under which this specimen collection event occurred. Links the collection to the governing protocol.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: When protocol amendments change specimen collection requirements, collections after the amendment effective date follow new rules.',
    `study_site_id` BIGINT COMMENT 'Reference to the clinical site (investigative site) where the specimen collection event took place.',
    `study_visit_schedule_id` BIGINT COMMENT 'Foreign key linking to study.study_visit_schedule. Business justification: Specimen collections are planned against protocol-defined visit schedules. Linking actual collections to the scheduled visit definition enables visit-window deviation detection',
    `subject_randomization_id` BIGINT COMMENT 'Foreign key linking to randomization.subject_randomization. Business justification: Specimen collection compliance requires confirming subjects randomization status and treatment arm at collection time — especially for PK/PD assessments where collection',
    `subject_visit_id` BIGINT COMMENT 'Reference to the scheduled or unscheduled study visit during which the specimen was collected. Links collection to the visit schedule.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial subject (patient) from whom the specimen was collected. Core party reference for this transactional event.',
    `barcode` STRING COMMENT 'Barcode or unique label identifier affixed to the specimen tube or container at the time of collection. Used for automated specimen tracking and laboratory information system (LIS) integration.',
    `chain_of_custody_number` STRING COMMENT 'Unique tracking number assigned to document the chain of custody for the specimen from collection through laboratory receipt. Ensures specimen integrity and traceability for regulatory and legal purposes.',
    `collection_method` STRING COMMENT 'The clinical method or procedure used to collect the specimen from the subject (e.g., venipuncture, fingerstick, lumbar puncture, biopsy). Corresponds to CDISC SDTM LBMETHOD.',
    `collection_number` STRING COMMENT 'Externally-known, human-readable business identifier for this specimen collection event, typically generated by the EDC or CTMS (e.g., SC-0042-001). Used for cross-system traceability and chain-of-custody documentation.',
    `collection_site_anatomy` STRING COMMENT 'The anatomical location on the subjects body from which the specimen was collected (e.g., Left Antecubital Vein, Right Arm, Lumbar Region). Corresponds to CDISC SDTM LBLOC.',
    `collection_status` STRING COMMENT 'Current lifecycle status of the specimen collection event. Indicates whether the collection was completed as planned, partially completed, missed, or cancelled.. Valid values are `scheduled|collected|missed|cancelled|partial|failed`',
    `collection_timestamp` TIMESTAMP COMMENT 'Specimen collection date/time; implements SDTM --DTC',
    `collector_name` STRING COMMENT 'Full name of the CRC or phlebotomist who performed the specimen collection. Denormalized for audit trail and regulatory inspection readiness. Classified as confidential as it identifies site personnel.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this specimen collection record was first created in the system. Required for audit trail compliance under 21 CFR Part 11 and ALCOA+ principles.',
    `deviation_description` STRING COMMENT 'Free-text description of any deviation from the protocol-specified collection procedure, including wrong tube type, incorrect volume, missed time window, or improper storage. Populated when has_deviation = True.',
    `deviation_type` STRING COMMENT 'Categorical classification of the type of collection deviation observed. Used for trending and CAPA (Corrective and Preventive Action) analysis. [ENUM-REF-CANDIDATE: timing|volume|tube_type|storage|labeling|processing|other — promote to reference product]',
    `fasting_status` STRING COMMENT 'Fasting status at collection; implements SDTM --FAST (CDISC CT NY codelist). Valid values are `fasted|non_fasted|unknown`',
    `has_deviation` BOOLEAN COMMENT 'Indicates whether a protocol deviation or collection irregularity was recorded for this specimen collection event. True = deviation present; False = no deviation. Triggers downstream deviation management workflow.',
    `hemolysis_grade` STRING COMMENT 'Visual or instrument-assessed grade of hemolysis (red blood cell rupture) in the collected blood specimen. Hemolysis can interfere with laboratory assay results and may require recollection.. Valid values are `none|mild|moderate|severe`',
    `is_unscheduled` BOOLEAN COMMENT 'Indicates whether this specimen collection was an unscheduled (ad hoc) event not defined in the original study protocol visit schedule. True = unscheduled; False = protocol-scheduled.',
    `lipemia_grade` STRING COMMENT 'Visual or instrument-assessed grade of lipemia (excess lipids causing turbidity) in the collected specimen. Lipemia can interfere with photometric assay results.. Valid values are `none|mild|moderate|severe`',
    `nominal_time_point` STRING COMMENT 'Protocol-defined nominal time point label for PK/PD sample collection (e.g., Pre-dose, 0.5h, 1h, 2h, 4h, 8h, 24h). Used to align actual collection times to protocol-scheduled PK sampling windows.',
    `processing_completed_timestamp` TIMESTAMP COMMENT 'Date and time at which pre-analytical processing of the specimen was completed at the collection site (e.g., centrifugation, aliquoting). Used to calculate processing turnaround time and assess sample integrity.',
    `recollection_reason` STRING COMMENT 'Reason why a repeat specimen collection is required. Populated when recollection_required = True. [ENUM-REF-CANDIDATE: insufficient_volume|hemolysis|lipemia|clotted|mislabeled|lost_in_transit|expired_kit|other — promote to reference product]',
    `recollection_required` BOOLEAN COMMENT 'Indicates whether a repeat specimen collection is required due to inadequate sample, collection deviation, or laboratory rejection. True = recollection needed; False = no recollection required.',
    `sample_adequacy` STRING COMMENT 'Assessment of whether the collected specimen volume and quality are sufficient to perform all protocol-required laboratory analyses. Determined at the time of collection or upon receipt at the laboratory.. Valid values are `adequate|inadequate|borderline`',
    `scheduled_collection_timestamp` TIMESTAMP COMMENT 'The protocol-defined date and time at which the specimen collection was planned to occur per the study visit schedule. Used to calculate collection timing deviations.',
    `specimen_type` STRING COMMENT 'Specimen type; implements SDTM --SPEC (CDISC CT SPECTYPE codelist)',
    `storage_temperature_c` DECIMAL(5,1) COMMENT 'Temperature in degrees Celsius at which the specimen was stored at the collection site prior to shipment to the central laboratory. Deviations from protocol-specified storage conditions may compromise sample integrity.',
    `time_from_dose_hours` DECIMAL(8,2) COMMENT 'Elapsed time in hours between the subjects most recent investigational product dose and the specimen collection. Critical for PK (Pharmacokinetics) and DMPK (Drug Metabolism and Pharmacokinetics) sample timing analysis.',
    `tube_count` BIGINT COMMENT 'The total number of tubes, vials, or containers collected during this specimen collection event. Used for chain-of-custody tracking and sample accountability.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this specimen collection record was last modified. Required for audit trail compliance under 21 CFR Part 11 and ALCOA+ principles.',
    `volume_collected_ml` DECIMAL(10,3) COMMENT 'Total volume of specimen collected from the subject, expressed in millilitres (mL). Critical for PK/PD studies and for verifying adequacy of sample for planned assays.',
    `volume_unit` STRING COMMENT 'Unit of measure for the volume collected. Typically mL for blood/urine, but may be µL for microsampling or g for tissue. Ensures unambiguous interpretation of volume_collected_ml.. Valid values are `mL|uL|g|mg`',
    CONSTRAINT pk_specimen_collection PRIMARY KEY(`specimen_collection_id`)
) COMMENT 'Transactional record of a scheduled or unscheduled specimen collection event at a clinical site or subject visit. Captures collection event date/time, study visit reference, protocol-scheduled vs.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` (
    `specimen_shipment_id` BIGINT COMMENT 'Unique surrogate identifier for the specimen shipment record in the lakehouse silver layer. Primary key for this transactional entity.',
    `lab_facility_id` BIGINT COMMENT 'Reference to the destination central or reference laboratory facility receiving the shipment. Supports routing and receipt confirmation.',
    `service_level_agreement_id` BIGINT COMMENT 'Foreign key linking to agreement.service_level_agreement. Business justification: Specimen shipment SLAs govern receipt confirmation turnaround, temperature excursion notification, and rejection reporting timelines.',
    `shipment_manifest_id` BIGINT COMMENT 'Externally assigned manifest identifier accompanying the shipment package, used to reconcile specimens at the receiving laboratory. Typically generated by the CTMS or laboratory information system.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study under which the specimens were collected and shipped. Links shipment to the sponsoring protocol.',
    `study_site_id` BIGINT COMMENT 'Reference to the clinical site (origin) from which the specimens were dispatched. Supports chain-of-custody traceability back to the collecting site.',
    `actual_receipt_date` TIMESTAMP COMMENT 'Date and time at which the receiving laboratory confirmed physical receipt of the shipment. Used to calculate transit duration and assess specimen integrity against stability windows.',
    `airbill_number` STRING COMMENT 'Air waybill or bill of lading number issued by the carrier for international or air freight shipments. Required for customs clearance and IATA dangerous goods documentation.',
    `collection_date` DATE COMMENT 'Date on which the specimens included in this shipment were collected from study subjects. Used to calculate specimen age at receipt and assess stability compliance.',
    `comments` STRING COMMENT 'Free-text field for additional notes or observations recorded by site staff, courier, or laboratory personnel regarding the shipment (e.g., packaging condition on arrival, partial delivery notes).',
    `courier_name` STRING COMMENT 'Name of the logistics carrier or courier service responsible for transporting the shipment (e.g., World Courier, FedEx Clinical, Marken). Supports vendor performance tracking.',
    `courier_service_level` STRING COMMENT 'Service tier selected for the shipment (e.g., overnight, two-day, international priority). Determines expected transit time and cost classification.. Valid values are `overnight|two_day|ground|international_priority|same_day`',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time at which this specimen shipment record was first created in the system. Supports audit trail and data lineage requirements per 21 CFR Part 11 and ALCOA+ principles.',
    `customs_declaration_number` STRING COMMENT 'Reference number of the customs or import/export declaration filed for international specimen shipments. Required for cross-border regulatory compliance and specimen release at destination.',
    `destination_lab_code` STRING COMMENT 'Alphanumeric code identifying the receiving central or reference laboratory. Denormalized for manifest documentation and rapid chain-of-custody reporting.',
    `dry_ice_weight_kg` DECIMAL(6,3) COMMENT 'Weight of dry ice (in kilograms) included in the shipment package. Required for IATA dangerous goods declaration when dry ice is used as a refrigerant. Applicable only when temperature_condition = dry_ice.',
    `excursion_duration_minutes` BIGINT COMMENT 'Total duration in minutes during which the shipment temperature was outside the acceptable range. Used by the laboratory to assess specimen viability and document deviation impact.',
    `excursion_max_temp_c` DECIMAL(5,2) COMMENT 'Highest temperature (in degrees Celsius) recorded by the temperature monitor/data logger during transit. Populated only when a temperature excursion is detected. Supports specimen impact assessment.',
    `excursion_min_temp_c` DECIMAL(5,2) COMMENT 'Lowest temperature (in degrees Celsius) recorded by the temperature monitor/data logger during transit. Populated only when a temperature excursion is detected. Supports specimen impact assessment.',
    `expected_arrival_date` DATE COMMENT 'Planned date on which the shipment is expected to arrive at the destination laboratory, as agreed with the courier at time of dispatch. Used to trigger overdue alerts.',
    `hazardous_material_flag` BOOLEAN COMMENT 'Indicates whether the shipment contains materials classified as hazardous (e.g., Category B biological substances, dry ice). True = hazardous declaration required; False = non-hazardous. Drives IATA dangerous goods documentation requirements.',
    `import_permit_number` STRING COMMENT 'Regulatory import permit or authorization number required for cross-border shipment of biological specimens in certain jurisdictions. Ensures compliance with national biosafety and import regulations.',
    `lab_contact_name` STRING COMMENT 'Name of the designated contact person at the receiving laboratory responsible for accepting and processing the shipment. Used for courier delivery confirmation and discrepancy resolution.',
    `origin_site_number` STRING COMMENT 'Sponsor-assigned or regulatory site number of the clinical site dispatching the specimens. Denormalized for chain-of-custody documentation and regulatory audit trail without requiring a join.',
    `packaging_type` STRING COMMENT 'Type of packaging used for the shipment, indicating the thermal protection and containment method. Relevant for regulatory compliance with IATA P650 and specimen integrity documentation.. Valid values are `triple_pack|insulated_box|cryogenic_shipper|ambient_box|validated_shipper`',
    `protocol_visit_name` STRING COMMENT 'Name or label of the study protocol visit (e.g., Day 1, Week 4, End of Treatment) associated with the specimen collection event. Supports SDTM domain mapping and visit-level reconciliation.',
    `receipt_confirmed_by` STRING COMMENT 'Name or user identifier of the laboratory staff member who confirmed receipt of the shipment. Part of the chain-of-custody audit trail per ALCOA+ principles.',
    `received_specimen_count` BIGINT COMMENT 'Actual number of specimens confirmed by the receiving laboratory upon opening the shipment. Compared against specimen_count to identify discrepancies or missing specimens.',
    `rejection_reason` STRING COMMENT 'Free-text description of the reason the shipment was rejected at the receiving laboratory (e.g., temperature excursion, broken specimens, incorrect labeling, missing manifest). Populated only when shipment_status = rejected.',
    `shipment_date` TIMESTAMP COMMENT 'Date and time at which the shipment was handed over to the courier at the originating clinical site. Principal business event timestamp for this transaction. Recorded in ISO 8601 format with timezone offset.',
    `shipment_status` STRING COMMENT 'Current lifecycle state of the specimen shipment. Drives chain-of-custody workflow and exception management. Values: pending (prepared, not yet dispatched), in_transit (with courier), delivered (courier confirmed delivery), received (lab confirmed. Valid values are `pending|in_transit|delivered|received|rejected|cancelled`',
    `shipment_type` STRING COMMENT 'Classification of the shipment by its clinical purpose. Values: routine (standard scheduled collection), urgent (expedited for safety or protocol reasons), pk_sample (Pharmacokinetics samples requiring strict timing), biomarker (exploratory biomarker. Valid values are `routine|urgent|pk_sample|biomarker|backup|reshipment`',
    `specimen_count` BIGINT COMMENT 'Total number of individual specimen tubes, aliquots, or containers included in this shipment as declared on the manifest. Used for reconciliation at receipt.',
    `subject_count` BIGINT COMMENT 'Number of distinct study subjects whose specimens are included in this shipment. Supports subject-level reconciliation and enrollment tracking at the laboratory.',
    `temperature_condition` STRING COMMENT 'Required temperature storage and transport condition for the shipment as specified in the laboratory manual. Critical for specimen integrity. Values: ambient (15–25°C), refrigerated (2–8°C), frozen (-20°C), dry_ice (-78°C), liquid_nitrogen (-196°C).. Valid values are `ambient|refrigerated|frozen|dry_ice|liquid_nitrogen`',
    `temperature_excursion_flag` BOOLEAN COMMENT 'Indicates whether a temperature excursion (deviation outside the acceptable range) was detected during transit. True = excursion occurred; False = no excursion. Triggers specimen usability assessment workflow.',
    `temperature_max_c` DECIMAL(5,2) COMMENT 'Upper bound of the acceptable temperature range (in degrees Celsius) for this shipment as defined in the study laboratory manual. Used to evaluate temperature excursion severity.',
    `temperature_min_c` DECIMAL(5,2) COMMENT 'Lower bound of the acceptable temperature range (in degrees Celsius) for this shipment as defined in the study laboratory manual. Used to evaluate temperature excursion severity.',
    `temperature_monitor_code` STRING COMMENT 'Serial number or identifier of the temperature data logger or indicator device placed in the shipment. Enables retrieval of the full temperature log for excursion investigation and regulatory documentation.',
    `temperature_monitor_type` STRING COMMENT 'Type of temperature monitoring device included in the shipment. Data_logger provides continuous electronic recording; indicator_card provides a visual pass/fail indicator; none indicates no monitoring device was used.. Valid values are `data_logger|indicator_card|none`',
    `tracking_number` STRING COMMENT 'Carrier-assigned tracking number for the shipment package, enabling real-time logistics monitoring and proof-of-delivery confirmation.',
    `un_number` STRING COMMENT 'United Nations dangerous goods classification number for the shipment contents (e.g., UN3373 for Category B biological substances, UN1845 for dry ice). Required on shipping labels and documentation when hazardous_material_flag is True.. Valid values are `^UN[0-9]{4}$`',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time at which this specimen shipment record was most recently modified. Supports audit trail, data lineage, and incremental ETL processing in the Databricks lakehouse.',
    CONSTRAINT pk_specimen_shipment PRIMARY KEY(`specimen_shipment_id`)
) COMMENT 'Transactional record tracking the shipment of specimens from a clinical site to a central or reference laboratory. Captures shipment manifest ID, origin site, destination lab facility, courier name, tracking number, shipment date/time, expected arrival';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` (
    `reference_range_id` BIGINT COMMENT 'Unique surrogate identifier for each reference range record in the laboratory master. Primary key for the reference_range data product.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Sponsor or medical monitor approval of reference ranges is required for CDISC/SDTM submissions and safety data review.',
    `lab_analyte_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_analyte. Business justification: A reference range is defined for a specific laboratory analyte. The analyte_code and analyte_name on reference_range are denormalized from the lab_analyte reference master.',
    `lab_facility_id` BIGINT COMMENT 'Identifier of the central or local laboratory facility that owns and applies this reference range. Links to the lab facility master.',
    `lab_panel_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_panel. Business justification: Reference ranges are often defined in the context of a specific lab panel (e.g., a chemistry panel has specific normal ranges for its analytes).',
    `organization_id` BIGINT COMMENT 'Foreign key linking to sponsor.organization. Business justification: reference_range has is_sponsor_defined boolean indicating sponsor-specific ranges used in protocol assessments and regulatory submissions.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Sponsor-defined reference ranges are specified per protocol version for SDTM/ADaM dataset generation.',
    `sap_id` BIGINT COMMENT 'Foreign key linking to biostatistics.the source system. Business justification: FDA/EMA submissions require that reference ranges used for out-of-range flagging and CTCAE grading match those specified in the the source system.',
    `study_id` BIGINT COMMENT 'Identifier of the clinical study for which this reference range is specifically applicable. Null indicates a lab-standard range applicable across all studies at the facility.',
    `submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission. Business justification: Sponsor-defined reference ranges used in clinical trials must be documented and submitted to regulatory agencies for safety assessment review.',
    `age_max` DECIMAL(5,2) COMMENT 'Maximum age in years of the subject population for which this reference range applies. Null indicates no upper age bound.',
    `age_min` DECIMAL(5,2) COMMENT 'Minimum age in years of the subject population for which this reference range applies. Used to stratify ranges by pediatric, adult, or geriatric populations.',
    `age_unit` STRING COMMENT 'Unit of measurement for the age range fields (age_min, age_max). Defaults to years for adults; may be months, weeks, or days for neonatal or pediatric populations.. Valid values are `years|months|weeks|days`',
    `approval_status` STRING COMMENT 'Current approval lifecycle status of this reference range version. Only approved ranges are used for out-of-range flagging and CTCAE grading in clinical trial lab results.. Valid values are `draft|pending_review|approved|superseded|retired`',
    `approved_timestamp` TIMESTAMP COMMENT 'Date and time when this reference range version was formally approved by the authorized laboratory or sponsor personnel. Part of the GCP-required audit trail.',
    `change_reason` STRING COMMENT 'Coded reason explaining why this reference range version was created or updated. Required for GCP audit trail. [ENUM-REF-CANDIDATE',
    `change_reason_detail` STRING COMMENT 'Free-text narrative providing additional detail on the reason for the reference range update. Supplements the coded change_reason field for regulatory audit trail documentation.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this reference range record was first created in the system. Part of the mandatory GCP audit trail for laboratory data per ALCOA+ principles.',
    `critical_high` DECIMAL(18,6) COMMENT 'The critical (panic) high threshold for the analyte. Results at or above this value require immediate clinical notification per laboratory SOP and GCP safety reporting requirements.',
    `critical_low` DECIMAL(18,6) COMMENT 'The critical (panic) low threshold for the analyte. Results at or below this value require immediate clinical notification per laboratory SOP and GCP safety reporting requirements.',
    `ctcae_grade1_upper` DECIMAL(18,6) COMMENT 'Upper boundary value corresponding to CTCAE Grade 1 toxicity for this analyte. Used for automated CTCAE grading of laboratory results in safety and adverse event reporting.',
    `ctcae_grade2_upper` DECIMAL(18,6) COMMENT 'Upper boundary value corresponding to CTCAE Grade 2 toxicity for this analyte. Used for automated CTCAE grading of laboratory results in safety and adverse event reporting.',
    `ctcae_grade3_upper` DECIMAL(18,6) COMMENT 'Upper boundary value corresponding to CTCAE Grade 3 toxicity for this analyte. Used for automated CTCAE grading of laboratory results in safety and adverse event reporting.',
    `ctcae_grade4_upper` DECIMAL(18,6) COMMENT 'Upper boundary value corresponding to CTCAE Grade 4 toxicity for this analyte. Used for automated CTCAE grading of laboratory results in safety and adverse event reporting.',
    `ctcae_version` STRING COMMENT 'CTCAE version; implements CTCAE version metadata',
    `effective_end_date` DATE COMMENT 'Date on which this reference range version ceased to be effective. Null indicates the range is currently active. Populated when a new version supersedes this record.',
    `effective_start_date` DATE COMMENT 'Date from which this reference range version became or becomes effective for use in clinical trial lab result evaluation and out-of-range flagging.',
    `ethnicity_applicability` STRING COMMENT 'Ethnic or racial population for which this reference range is specifically calibrated (e.g., ALL for universal, or specific population codes per CDISC). Null or ALL indicates the range applies universally regardless of ethnicity.',
    `instrument_code` STRING COMMENT 'Identifier of the specific laboratory instrument or analyzer for which this reference range was established. Instrument-specific ranges are required when different analyzers produce systematically different results.',
    `is_current_version` BOOLEAN COMMENT 'Indicates whether this record represents the currently active version of the reference range for the given analyte, lab, and stratification combination. True = current; False = historical version.',
    `is_sponsor_defined` BOOLEAN COMMENT 'Boolean flag indicating whether this reference range was explicitly defined or mandated by the clinical trial sponsor, as opposed to being the laboratorys standard range. Sponsor-defined ranges take precedence for trial-specific out-of-range flagging.',
    `lab_accreditation_standard` STRING COMMENT 'Accreditation standard under which the laboratory facility that established this reference range is certified (e.g., CAP, CLIA, ISO 15189). Relevant for regulatory submissions and sponsor qualification of central labs.. Valid values are `CAP|CLIA|ISO_15189|UKAS|DAkkS|other`',
    `loinc_code` STRING COMMENT 'LOINC code of the analyte; implements LOINC code. Valid values are `^[0-9]{1,5}-[0-9]$`',
    `lower_limit` DECIMAL(18,6) COMMENT 'The lower boundary of the normal reference range for the analyte. Values below this threshold are flagged as abnormally low. Corresponds to LBORNRLO in CDISC SDTM.',
    `method_code` STRING COMMENT 'Code identifying the analytical method or instrument platform used to generate results evaluated against this reference range (e.g., colorimetric, immunoassay, HPLC). Reference ranges may differ by method.',
    `modified_timestamp` TIMESTAMP COMMENT 'Date and time when this reference range record was last modified. Part of the mandatory GCP audit trail for laboratory data per ALCOA+ principles.',
    `prior_lower_limit` DECIMAL(18,6) COMMENT 'The lower normal limit value from the immediately preceding version of this reference range. Retained for audit trail and regulatory inspection readiness per GCP requirements.',
    `prior_upper_limit` DECIMAL(18,6) COMMENT 'The upper normal limit value from the immediately preceding version of this reference range. Retained for audit trail and regulatory inspection readiness per GCP requirements.',
    `range_source` STRING COMMENT 'Indicates whether this reference range is sponsor-defined (provided by the clinical trial sponsor), lab-standard (established by the laboratory facility), derived from a regulatory guideline, or from published literature.. Valid values are `sponsor_defined|lab_standard|regulatory_guideline|published_literature`',
    `reagent_lot_number` STRING COMMENT 'Lot number of the reagent kit or calibrator associated with this reference range version. Captured when a reagent lot change triggers a reference range update per laboratory SOPs.',
    `sex_applicability` STRING COMMENT 'Sex applicability; implements SDTM SEX (CDISC CT SEX codelist). Valid values are `M|F|BOTH|UNKNOWN`',
    `specimen_type` STRING COMMENT 'Type of biological specimen for which this reference range is applicable (e.g., serum, plasma, whole blood, urine). Corresponds to LBSPEC in CDISC SDTM. [ENUM-REF-CANDIDATE: serum|plasma|whole_blood|urine|csf|tissue|saliva|other — promote to reference',
    `unit_of_measure` STRING COMMENT 'Unit of measure; implements CDISC CT UNIT codelist',
    `upper_limit` DECIMAL(18,6) COMMENT 'The upper boundary of the normal reference range for the analyte. Values above this threshold are flagged as abnormally high. Corresponds to LBORNRHI in CDISC SDTM.',
    `version_number` BIGINT COMMENT 'Sequential integer version number of this reference range definition. Incremented each time the range is updated. Supports full version history and audit trail per GCP requirements.',
    CONSTRAINT pk_reference_range PRIMARY KEY(`reference_range_id`)
) COMMENT 'Master definition of laboratory reference ranges (normal ranges) for analytes, with full version history. Captures analyte/LOINC code, lower and upper normal limits, unit of measure, sex, age range, ethnicity applicability, specimen type, lab facility';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` (
    `critical_value_id` BIGINT COMMENT 'Unique surrogate identifier for each critical (panic) value threshold record in the laboratory reference master.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Critical value thresholds require medical/scientific approval per GCP and AE reporting requirements. The existing approved_by plain-text column is a denormalized employee reference.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.sop. Business justification: Critical value notification procedures are operationalized through SOPs defining escalation pathways and SLA timelines. critical_value has escalation_pathway and notification_sla_minutes.',
    `ctcae_grade_id` BIGINT COMMENT 'Foreign key linking to terminology.ctcae_grade. Business justification: Critical value thresholds are defined in terms of CTCAE grades to determine AE reporting requirements (ae_reporting_required flag).',
    `lab_analyte_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_analyte. Business justification: A critical value threshold is defined for a specific laboratory analyte. The analyte_code and analyte_name on critical_value are denormalized from the lab_analyte reference master.',
    `lab_facility_id` BIGINT COMMENT 'Reference identifier for the specific laboratory facility to which this critical value threshold applies, when lab_facility_scope is specific_facility. Null when the threshold applies globally or to a facility class.',
    `meddra_term_id` BIGINT COMMENT 'Foreign key linking to terminology.meddra_term. Business justification: Critical lab values trigger AE reporting; the MedDRA coding of the lab finding is required for ICSR and expedited report submissions.',
    `organization_id` BIGINT COMMENT 'Foreign key linking to sponsor.organization. Business justification: Sponsors define critical value thresholds and AE reporting rules applied across their study portfolio.',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to, for study context and traceability.',
    `superseded_by_critical_value_id` BIGINT COMMENT 'Reference to the critical_value_id of the newer threshold record that replaces this one when threshold_status is superseded. Enables version chain traceability for audit and regulatory inspection.',
    `ae_reporting_required` BOOLEAN COMMENT 'Indicates whether a critical value breach automatically triggers an Adverse Event (AE) or Serious Adverse Event (SAE) report in the source system True = AE/SAE workflow initiated; False = clinical notification only.',
    `age_group_applicability` STRING COMMENT 'Specifies the patient age group for which this critical value threshold applies. Different thresholds may be defined for pediatric, adult, and geriatric populations.. Valid values are `all|pediatric|adult|geriatric`',
    `analyte_category` STRING COMMENT 'Clinical category of the analyte (e.g., Hematology, Chemistry, Coagulation, PK/PD, DMPK). Used for grouping critical value alerts by clinical domain and routing to appropriate clinical reviewers.',
    `approval_date` DATE COMMENT 'Date on which this critical value threshold was formally approved by the designated clinical reviewer. Required for GCP audit trail and regulatory inspection readiness.',
    `argus_safety_rule_code` STRING COMMENT 'Identifier of the corresponding automated safety rule configured in the source system that is triggered when this critical value threshold is breached. Enables bidirectional traceability between the lab threshold master and the safety system.',
    `bioanalytical_method` STRING COMMENT 'Name or code of the validated bioanalytical method used to measure the analyte (e.g., LC-MS/MS, ELISA, flow cytometry). Relevant for PK/PD and DMPK analytes where method-specific critical thresholds may apply.',
    `clinical_rationale` STRING COMMENT 'Free-text description of the clinical or scientific rationale for the defined critical value thresholds. Documents the medical justification for regulatory inspection readiness and protocol defense.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this critical value threshold record was first created in the system. Required for ALCOA+ data integrity and 21 CFR Part 11 audit trail compliance.',
    `critical_high` DECIMAL(18,6) COMMENT 'The upper critical (panic) value threshold for the analyte. A result at or above this value triggers an immediate clinical notification workflow per the defined notification SLA.',
    `critical_low` DECIMAL(18,6) COMMENT 'The lower critical (panic) value threshold for the analyte. A result at or below this value triggers an immediate clinical notification workflow per the defined notification SLA.',
    `edc_alert_rule_code` STRING COMMENT 'Identifier of the automated edit check or alert rule configured in Medidata Rave EDC that fires when a lab result breaches this critical value threshold. Supports automated critical value flagging at point of data entry.',
    `effective_end_date` DATE COMMENT 'Date on which this critical value threshold ceases to be effective. Null indicates the threshold is currently active with no defined expiry. Supports temporal versioning and audit trail.',
    `effective_start_date` DATE COMMENT 'Date from which this critical value threshold becomes effective and is applied in automated alerting workflows. Supports temporal versioning of threshold definitions.',
    `escalation_pathway` STRING COMMENT 'Defined escalation route for communicating a critical value to the appropriate clinical personnel (e.g., PI direct, CRC then PI, Medical Monitor, Sponsor Safety team, DSMB). Governs the automated notification routing logic.',
    `escalation_tier_2_minutes` BIGINT COMMENT 'Number of minutes after initial notification attempt before escalating to the secondary contact in the escalation pathway if no acknowledgement is received.',
    `fasting_state_required` BOOLEAN COMMENT 'Indicates whether this critical value threshold applies only to specimens collected under fasting conditions. True = fasting required for threshold applicability; False = non-fasting or state-independent.',
    `lab_facility_scope` STRING COMMENT 'Defines the applicability of this critical value threshold to laboratory facilities: all facilities, central lab only, local lab only, or a specific named facility. Drives which lab facilities apply this threshold in automated alerting workflows.. Valid values are `all|central_lab|local_lab|specific_facility`',
    `loinc_code` STRING COMMENT 'LOINC code of the analyte; implements LOINC code. Valid values are `^[0-9]{1,5}-[0-9]$`',
    `notification_sla_minutes` BIGINT COMMENT 'Maximum allowable time in minutes from critical value detection to confirmed clinical notification. Drives automated alerting SLA monitoring and compliance reporting. Typical values range from 15 to 60 minutes per CAP and CLIA requirements.',
    `regulatory_authority_basis` STRING COMMENT 'Regulatory authority or guideline that mandates or informs this critical value threshold definition (e.g., FDA, EMA, PMDA, CAP, CLIA). Supports multi-jurisdictional compliance documentation.',
    `requires_repeat_confirmation` BOOLEAN COMMENT 'Indicates whether a repeat specimen analysis is required to confirm the critical value before initiating the notification workflow. True = repeat confirmation required; False = single result triggers notification.',
    `sex_applicability` STRING COMMENT 'Sex applicability; implements SDTM SEX (CDISC CT SEX codelist). Valid values are `all|male|female`',
    `source_reference_document` STRING COMMENT 'Citation or document reference (e.g., protocol section, lab manual version, CAP guideline) from which this critical value threshold was derived. Supports traceability and regulatory inspection readiness.',
    `specimen_type` STRING COMMENT 'Type of biological specimen from which the analyte is measured (e.g., blood, urine, plasma, serum). Critical value thresholds may differ by specimen type. [ENUM-REF-CANDIDATE: blood|urine|plasma|serum|csf|tissue|saliva|other — promote to reference product]',
    `test_system_code` STRING COMMENT 'Internal or sponsor-defined code for the specific laboratory test or panel within the clinical trial management system (e.g., Medidata Rave EDC lab test code). Used for system-to-system mapping.',
    `threshold_status` STRING COMMENT 'Current lifecycle status of the critical value threshold record. Active = in use for alerting; Inactive = retired; Superseded = replaced by a newer version; Under Review = pending clinical or regulatory review.. Valid values are `active|inactive|superseded|under_review`',
    `threshold_type` STRING COMMENT 'Defines whether the critical value threshold is an absolute numeric value, a delta change from baseline, or a percent change from a prior result. Determines the comparison logic applied during automated alerting.. Valid values are `absolute|delta|percent_change`',
    `unit_of_measure` STRING COMMENT 'Unit of measure; implements CDISC CT UNIT codelist',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this critical value threshold record. Required for ALCOA+ data integrity and 21 CFR Part 11 audit trail compliance.',
    `version_number` STRING COMMENT 'Version identifier for this critical value threshold record (e.g., 1.0, 2.1). Incremented when threshold values, SLA, or escalation pathway are modified. Supports ALCOA+ data integrity requirements.. Valid values are `^[0-9]+.[0-9]+$`',
    CONSTRAINT pk_critical_value PRIMARY KEY(`critical_value_id`)
) COMMENT 'Reference master defining critical (panic) value thresholds for laboratory analytes that require immediate clinical notification. Captures analyte, LOINC code, critical low threshold, critical high threshold, unit, notification SLA (minutes), escalation';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` (
    `pk_sample_id` BIGINT COMMENT 'Unique surrogate identifier for each pharmacokinetic (PK) or pharmacodynamic (PD) sample record in the master PK sampling registry. Entity role: TRANSACTION_HEADER — represents a discrete, time-critical biological sample collection event tied to a dosing',
    `adverse_event_id` BIGINT COMMENT 'Foreign key linking to safety.adverse_event. Business justification: PK samples are collected during AE investigations to measure drug concentration at time of reaction (exposure-response analysis for causality).',
    `arm_id` BIGINT COMMENT 'Foreign key linking to study.study_arm. Business justification: PK sample analysis requires arm-level stratification for exposure comparisons and dose-response modeling.',
    `bioanalytical_assay_id` BIGINT COMMENT 'Reference to the bioanalytical assay assigned to analyze this PK sample. Links to the assay definition record containing the validated method, analyte(s), LLOQ, ULOQ, and laboratory performing the analysis.',
    `collector_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: PK sample collection requires a qualified, delegated staff member per GCP delegation logs. The existing collected_by plain-text column is a denormalized employee reference.',
    `epoch_id` BIGINT COMMENT 'Foreign key linking to study.study_epoch. Business justification: PK sampling is epoch-specific (single-dose, multiple-dose, steady-state epochs); NCA and compartmental modeling require epoch-level stratification. SDTM PC domain requires epoch assignment.',
    `manufacture_batch_id` BIGINT COMMENT 'Foreign key linking to supply.manufacture_batch. Business justification: DMPK analysts require direct traceability from PK samples to the IMP manufacture batch administered.',
    `pk_sampling_schedule_id` BIGINT COMMENT 'Reference to the protocol-defined PK sampling schedule that governs this sample collection event. Links to the schedule definition containing all nominal time points, required volumes, and acceptable windows for the study arm and period.',
    `shipment_id` BIGINT COMMENT 'Reference to the shipment record under which this PK sample was transported to the central or bioanalytical laboratory. Enables chain-of-custody tracking and temperature excursion investigation at the shipment level.',
    `specimen_id` BIGINT COMMENT 'The internal sample identifier assigned by the bioanalytical or central laboratory upon receipt. Used for cross-referencing between the clinical trial management system and the laboratory information management system (LIMS).',
    `study_id` BIGINT COMMENT 'Reference to the clinical study under whose protocol this PK sample was collected. Links the sample to the governing study protocol, sponsor, and regulatory submission context.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site where the PK sample was collected. Used for site-level PK compliance monitoring and logistics tracking.',
    `subject_randomization_id` BIGINT COMMENT 'Foreign key linking to randomization.subject_randomization. Business justification: PK sampling schedules are treatment-arm-specific (dose level, nominal timepoints).',
    `subject_visit_id` BIGINT COMMENT 'Reference to the scheduled or unscheduled clinical visit during which this PK sample was collected. Enables linkage to visit-level data including dosing records and clinical assessments.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial subject (patient) from whom this PK sample was collected. Core party reference linking the sample to the enrolled participant record.',
    `actual_time_post_dose_hours` DECIMAL(10,4) COMMENT 'Calculated elapsed time in hours between the actual dose administration time and the actual sample collection time. Distinct from nominal_time_hours; used as the primary time variable in PK concentration-time profiles and non-compartmental analysis (NCA).',
    `analyte_name` STRING COMMENT 'The name of the drug compound, metabolite, or biomarker being measured in this PK sample (e.g., parent compound, active metabolite, total drug). Corresponds to CDISC SDTM PC.PCTEST.',
    `collection_method` STRING COMMENT 'The method used to collect the biological sample from the subject. Relevant for bioanalytical method validation and potential pre-analytical variability assessment.',
    `collection_timestamp` TIMESTAMP COMMENT 'PK sample collection date/time; implements SDTM PC.PCDTC',
    `container_type` STRING COMMENT 'The type of collection container or tube used for the PK sample. Determines anticoagulant/additive present, which affects matrix type (plasma vs serum) and bioanalytical method compatibility. Critical for pre-analytical quality control.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time this PK sample record was first created in the source system (EDC or LIMS). Required for audit trail compliance under 21 CFR Part 11 and ICH E6(R2). Represents the ALCOA+ contemporaneous requirement.',
    `dose_administration_timestamp` TIMESTAMP COMMENT 'The actual date and time of the reference dose administration used to calculate actual time post-dose for this sample. Sourced from the dosing record in the EDC (Medidata Rave). Required for accurate ATPT calculation per CDISC SDTM PC domain conventions.',
    `dose_number` BIGINT COMMENT 'The sequential dose number relative to which this PK sample was collected (e.g., 1 for first dose, steady-state dose number). Critical for distinguishing single-dose PK from multiple-dose/steady-state PK profiles in DMPK analysis.',
    `edc_form_reference` STRING COMMENT 'The reference identifier of the eCRF form in the EDC system (Medidata Rave) where this PK sample collection event was recorded. Enables direct traceability from the silver-layer data product back to the source EDC record for SDV and audit purposes.',
    `exclusion_reason` STRING COMMENT 'Free-text or coded reason for excluding this PK sample from the primary analysis dataset. Populated only when sample_exclusion_flag is True. Examples include Outside sampling window, Haemolysed sample, Vomiting within 2h of dose, Bioanalytical',
    `freeze_thaw_cycles` BIGINT COMMENT 'The number of freeze-thaw cycles the PK sample has undergone. Excessive freeze-thaw cycles can degrade analyte stability and invalidate bioanalytical results.',
    `lab_receipt_timestamp` TIMESTAMP COMMENT 'The date and time the PK sample was received and logged at the bioanalytical or central laboratory. Used to calculate total sample transit time and to verify cold-chain compliance. Part of the chain-of-custody audit trail.',
    `nominal_time_hours` DECIMAL(10,4) COMMENT 'Numeric representation of the nominal time point in hours relative to dose administration (e.g., -0.0833 for pre-dose, 0.5, 1.0, 2.0). Negative values indicate pre-dose collections.',
    `nominal_time_point` STRING COMMENT 'The protocol-specified nominal time point for sample collection relative to dose administration (e.g., Pre-dose, 0.5h, 1h, 2h, 4h, 8h, 24h). Used as the planned time point label in PK analysis and SDTM PC domain mapping.',
    `pre_dose_flag` BOOLEAN COMMENT 'Indicates whether this sample is a pre-dose (trough/baseline) collection. True = pre-dose sample; False = post-dose sample. Pre-dose samples are used to assess trough concentrations, baseline drug levels, and accumulation ratios in multiple-dose PK',
    `processing_status` STRING COMMENT 'Current processing stage of the PK sample from collection through shipment to the bioanalytical laboratory. Distinct from sample_status (overall lifecycle); this tracks the physical processing workflow.',
    `processing_timestamp` TIMESTAMP COMMENT 'The date and time the sample was processed (e.g., centrifuged and aliquoted) after collection. Time from collection to processing is a critical pre-analytical variable that can affect analyte stability and bioanalytical results.',
    `protocol_deviation_flag` BOOLEAN COMMENT 'Indicates whether a protocol deviation was associated with this PK sample collection event (e.g., collection outside the acceptable sampling window, incorrect tube used, missed collection). True = deviation present; False = no deviation.',
    `sample_code` STRING COMMENT 'Externally-known, human-readable unique identifier for the PK sample, typically printed on the sample tube label and used across CTMS, LIMS, and bioanalytical systems for chain-of-custody tracking. Corresponds to the specimen barcode or accession number.. Valid values are `^[A-Z0-9-]{3,30}$`',
    `sample_condition_on_receipt` STRING COMMENT 'Assessment of the physical condition of the PK sample upon receipt at the bioanalytical laboratory. Conditions such as haemolysis, lipaemia, or temperature excursion may affect analyte measurement and trigger sample rejection or result flagging.',
    `sample_exclusion_flag` BOOLEAN COMMENT 'Indicates whether this PK sample has been excluded from the primary PK analysis dataset. True = excluded; False = included. Exclusions may be due to protocol deviations, sample integrity issues, or bioanalytical failures.',
    `sample_status` STRING COMMENT 'Current lifecycle status of the PK sample from scheduled collection through bioanalytical reporting. Drives workflow routing in LIMS and CTMS. [ENUM-REF-CANDIDATE',
    `sample_type` STRING COMMENT 'The biological matrix type of the PK sample. Determines the bioanalytical method applied and the reference range for analyte concentration. Plasma and serum are most common for small molecule PK; urine for renal clearance studies; CSF for CNS penetration. Valid values are `plasma|serum|whole_blood|urine|csf|saliva`',
    `sampling_window_end_hours` DECIMAL(8,4) COMMENT 'The protocol-defined acceptable latest collection time in hours relative to dose for this nominal time point. Together with sampling_window_start_hours, defines the acceptable window for protocol compliance assessment.',
    `sampling_window_start_hours` DECIMAL(8,4) COMMENT 'The protocol-defined acceptable earliest collection time in hours relative to dose for this nominal time point. Used to assess whether the actual collection time falls within the acceptable PK sampling window for protocol compliance determination.',
    `sdtm_domain` STRING COMMENT 'Target SDTM domain (PC/PP); implements SDTM Dataset.DOMAIN. Valid values are `PC|PP`',
    `storage_temperature_c` DECIMAL(6,2) COMMENT 'The temperature in degrees Celsius at which the PK sample is stored prior to shipment or analysis. Critical for analyte stability monitoring; deviations from protocol-specified storage conditions (e.g., -70°C, -20°C) must be documented and assessed for',
    `subject_number` STRING COMMENT 'The protocol-assigned subject number (e.g., site-subject identifier such as 001-001) used to identify the participant in regulatory submissions and PK analysis datasets.',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time this PK sample record was most recently modified. Required for audit trail and data integrity monitoring under 21 CFR Part 11 and ICH E6(R2). Used to detect unauthorized or unexplained data changes.',
    `volume_collected_ml` DECIMAL(8,3) COMMENT 'The actual volume of biological sample collected from the subject, expressed in millilitres. Used for sample sufficiency assessment, bioanalytical aliquoting planning, and protocol compliance verification against the required volume specified in the PK',
    `volume_required_ml` DECIMAL(8,3) COMMENT 'The protocol-specified minimum volume of sample required for the PK assay at this time point, expressed in millilitres. Used to assess whether the collected volume meets protocol requirements and to flag insufficient sample events.',
    `within_sampling_window` BOOLEAN COMMENT 'Indicates whether the actual sample collection time falls within the protocol-defined acceptable PK sampling window for this nominal time point. True = within window (compliant); False = outside window (potential protocol deviation).',
    CONSTRAINT pk_pk_sample PRIMARY KEY(`pk_sample_id`)
) COMMENT 'Master record for pharmacokinetic (PK) and pharmacodynamic (PD) samples collected per the study PK sampling schedule. Captures nominal and actual collection time relative to dose (pre-dose, post-dose hours), dose number, PK sampling window compliance';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` (
    `bioanalytical_assay_id` BIGINT COMMENT 'Unique surrogate identifier for the bioanalytical assay record in the lakehouse. Primary key. Entity role: MASTER_RESOURCE — represents a validated analytical method owned and managed by the bioanalytical laboratory.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Bioanalytical method validation requires a qualified scientists approval per 21 CFR Part 58 and EMA bioanalytical guidelines.',
    `clinical_program_id` BIGINT COMMENT 'Foreign key linking to program.clinical_program. Business justification: Bioanalytical assays are developed, validated, and owned at the program level for a specific investigational compound.',
    `document_sop_id` BIGINT COMMENT 'Foreign key linking to document.document_sop. Business justification: GLP/GCP bioanalytical assays must reference their validated method SOP. Regulatory submissions (NDA/BLA bioanalytical section) and FDA/EMA inspections require direct traceability from',
    `imp_master_id` BIGINT COMMENT 'Foreign key linking to supply.imp_master. Business justification: FDA/EMA bioanalytical method validation guidance requires each validated assay to be linked to the specific IMP it measures.',
    `investigational_product_id` BIGINT COMMENT 'Foreign key linking to study.investigational_product. Business justification: Bioanalytical assays are validated to measure specific investigational products.',
    `lab_facility_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_facility. Business justification: A bioanalytical assay is validated and performed at a specific laboratory facility.',
    `master_service_agreement_id` BIGINT COMMENT 'Foreign key linking to agreement.master_service_agreement. Business justification: Bioanalytical assays are performed by contract labs under MSAs specifying validated method requirements, LLOQ/ULOQ standards, GLP compliance, and regulatory submission',
    `organization_id` BIGINT COMMENT 'Foreign key linking to sponsor.organization. Business justification: Bioanalytical assays are sponsor-commissioned and sponsor-owned; method validation reports are regulatory submissions tied to a specific sponsors IND/NDA.',
    `pipeline_asset_id` BIGINT COMMENT 'Foreign key linking to sponsor.pipeline_asset. Business justification: A bioanalytical assay is developed and validated to measure a specific investigational compound or metabolite (pipeline asset).',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to, for study context and traceability.',
    `validation_tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Bioanalytical validation reports are TMF documents (DIA TMF Reference Model Zone 3, Section 3.2).',
    `accuracy_percent` DECIMAL(6,3) COMMENT 'Mean accuracy of the assay expressed as percent of nominal concentration (%Nominal) at QC levels during validation. Regulatory acceptance criterion is typically 85–115% (80–120% at LLOQ). Stored as the worst-case value across QC levels.',
    `analyte_category` STRING COMMENT 'Broad classification of the analyte type measured by the assay. Distinguishes small molecule drugs (PK), large molecule biologics, biomarkers (PD), immunogenicity (anti-drug antibodies), metabolites, and endogenous compounds.. Valid values are `Small Molecule|Large Molecule|Biomarker|Immunogenicity|Metabolite|Endogenous`',
    `analyte_name` STRING COMMENT 'Name of the substance being measured by the assay (e.g., drug compound, metabolite, biomarker, anti-drug antibody). Directly links the assay to the pharmacokinetic (PK), pharmacodynamic (PD), or immunogenicity endpoint it supports.',
    `assay_code` STRING COMMENT 'Externally-known unique alphanumeric code assigned to the assay by the bioanalytical laboratory or sponsor (e.g., BA-LC-001, ELISA-TNF-003). Used as the business identifier across CTMS, EDC, and regulatory submissions.. Valid values are `^[A-Z0-9_-]{3,30}$`',
    `assay_name` STRING COMMENT 'Full descriptive name of the bioanalytical assay as used in study protocols, validation reports, and regulatory submissions (e.g., LC-MS/MS Assay for Compound XYZ in Human Plasma). Satisfies MASTER_RESOURCE IDENTITY_LABEL category.',
    `assay_purpose` STRING COMMENT 'Primary scientific purpose the assay serves within the clinical or nonclinical program. PK (Pharmacokinetics) assays measure drug concentration over time; PD (Pharmacodynamics) assays measure biological effect; Immunogenicity assays detect anti-drug',
    `assay_type` STRING COMMENT 'Analytical technology platform used to perform the assay. Common types include LC-MS/MS (Liquid Chromatography-Tandem Mass Spectrometry), ELISA (Enzyme-Linked Immunosorbent Assay), ECL (Electrochemiluminescence), PCR (Polymerase Chain Reaction), Flow',
    `calibration_curve_model` STRING COMMENT 'Mathematical regression model used to fit the calibration curve for back-calculation of analyte concentrations from instrument response. Common models include Linear (1/x or 1/x² weighting), Quadratic, 4-Parameter Logistic (4PL), and 5-Parameter Logistic. Valid values are `Linear|Quadratic|Power|Logarithmic|4PL|5PL`',
    `cdisc_test_code` STRING COMMENT 'CDISC test code; implements SDTM PC.PCTESTCD',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the bioanalytical assay record was first created in the system. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ (Attributable, Legible, Contemporaneous, Original, Accurate) data integrity principles.',
    `cut_point_method` STRING COMMENT 'Statistical method used to establish the screening and confirmatory cut points for immunogenicity (anti-drug antibody) assays (e.g., Parametric 5th percentile, Non-parametric 5th percentile).',
    `dilution_integrity_factor` DECIMAL(10,3) COMMENT 'Maximum validated dilution factor that can be applied to samples exceeding the ULOQ while maintaining assay accuracy and precision within acceptance criteria. Samples requiring dilution beyond this factor must be flagged.',
    `expiry_date` DATE COMMENT 'Date after which the assay validation is no longer considered current and re-validation or re-qualification is required. Relevant for long-running studies where assay reagents, reference standards, or critical reagents may expire.',
    `gcp_compliant` BOOLEAN COMMENT 'Indicates whether the assay is performed under Good Clinical Practice (GCP) standards as required for clinical trial sample analysis. True = GCP-compliant; False = non-GCP.',
    `glp_compliant` BOOLEAN COMMENT 'Indicates whether the assay was validated and is performed under Good Laboratory Practice (GLP) regulations. GLP compliance is required for nonclinical safety studies submitted to regulatory agencies. True = GLP-compliant; False = non-GLP.',
    `inter_run_precision_cv` DECIMAL(6,3) COMMENT 'Between-run precision expressed as percent coefficient of variation (%CV) across multiple analytical runs during validation. Regulatory acceptance criterion is typically ≤15% (%CV). Stored as the worst-case value across QC levels.',
    `internal_standard` STRING COMMENT 'Name or identifier of the internal standard (IS) used in the assay for quantification normalization (e.g., stable isotope-labeled analog, structural analog).',
    `intra_run_precision_cv` DECIMAL(6,3) COMMENT 'Within-run precision expressed as percent coefficient of variation (%CV) at the QC concentration levels, as determined during validation. Regulatory acceptance criterion is typically ≤15% (%CV), or ≤20% at LLOQ.',
    `lloq` DECIMAL(18,6) COMMENT 'Lower Limit of Quantification — the lowest analyte concentration that can be reliably quantified with acceptable accuracy and precision per the validated method. Expressed in the unit defined by lloq_uloq_unit.',
    `lloq_uloq_unit` STRING COMMENT 'Unit of measurement for the LLOQ and ULOQ values (e.g., ng/mL, pg/mL, µg/mL, nM). Must be consistent with the unit reported in PK/PD concentration data submitted to regulatory agencies.',
    `long_term_stability_days` BIGINT COMMENT 'Number of days for which analyte stability in the biological matrix at long-term storage conditions (typically -20°C or -70°C) has been validated. Samples stored beyond this period require re-validation of stability before results can be reported.',
    `matrix_effect_assessed` BOOLEAN COMMENT 'Indicates whether matrix effect (ion suppression/enhancement for LC-MS/MS; non-specific binding for LBA) was formally evaluated during validation. True = matrix effect experiments conducted; False = not assessed.',
    `matrix_type` STRING COMMENT 'Specimen matrix type; implements SDTM PC.PCSPEC (CDISC CT SPECTYPE codelist)',
    `parallelism_assessed` BOOLEAN COMMENT 'Indicates whether parallelism (serial dilution of incurred samples producing results parallel to the calibration curve) was assessed. Relevant primarily for LBA and immunogenicity assays. True = parallelism assessed; False = not assessed.',
    `reference_standard_lot` STRING COMMENT 'Lot number of the certified reference standard used to prepare calibration standards and quality control (QC) samples. Traceability of the reference standard lot is required for regulatory submissions and audit purposes.',
    `sample_volume_required_ul` DECIMAL(10,3) COMMENT 'Minimum volume of biological matrix (in microliters) required per sample aliquot for a single assay run. Used for specimen collection planning, biobank management, and feasibility assessment of retrospective analyses.',
    `selectivity_assessed` BOOLEAN COMMENT 'Indicates whether selectivity (absence of interference from endogenous matrix components) was formally assessed during validation. True = selectivity experiments conducted and documented; False = not assessed.',
    `species` STRING COMMENT 'Biological species for which the assay has been validated. Assays validated in human matrices may differ from those validated in preclinical animal species used in DMPK studies. Drives applicability to clinical vs. nonclinical programs.',
    `sponsor_assay_code` STRING COMMENT 'Sponsor-assigned identifier for the assay as referenced in the study protocol, the source system, or regulatory submission. May differ from the CROs internal assay code. Required for cross-referencing sponsor documents with CRO laboratory records.',
    `stability_freeze_thaw_cycles` BIGINT COMMENT 'Number of freeze-thaw cycles for which analyte stability in the biological matrix has been validated. Samples subjected to more freeze-thaw cycles than validated must be flagged or excluded from analysis.',
    `storage_condition` STRING COMMENT 'Required storage temperature and conditions for samples analyzed by this assay (e.g., -70°C ± 10°C, -20°C, 2–8°C). Defines the chain-of-custody storage requirement for clinical samples to maintain analyte integrity.',
    `superseded_by_assay_code` STRING COMMENT 'Assay code of the newer version that replaces this assay when it is retired or superseded. Supports version lineage tracking and ensures historical sample results can be linked to the correct assay version.',
    `uloq` DECIMAL(18,6) COMMENT 'Upper Limit of Quantification — the highest analyte concentration that can be reliably quantified within the validated dynamic range. Samples above ULOQ must be diluted and re-assayed. Expressed in the unit defined by lloq_uloq_unit.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to the bioanalytical assay record. Required for audit trail compliance under 21 CFR Part 11 and ALCOA+ data integrity principles. Tracks when assay parameters, validation status, or metadata were last changed.',
    `validation_date` DATE COMMENT 'Date on which the bioanalytical method validation was formally completed and the validation report was approved. Marks the point from which the assay is considered fit for regulated use in clinical sample analysis.',
    `validation_status` STRING COMMENT 'Current regulatory validation tier of the assay. Validated indicates full GLP/GCP-compliant validation per FDA/EMA/ICH M10 guidelines; Qualified indicates fit-for-purpose qualification; Exploratory indicates early-phase research use only; In. Valid values are `Validated|Qualified|Exploratory|In Validation|Retired`',
    `version_number` STRING COMMENT 'Version identifier of the assay method (e.g., v1.0, v2.1). Incremented when the assay undergoes method changes requiring partial or full re-validation. Enables traceability of which assay version was used for each studys sample analysis.. Valid values are `^vd+.d+$`',
    `weighting_factor` STRING COMMENT 'Statistical weighting factor applied to the calibration curve regression to minimize heteroscedasticity (e.g., 1/x, 1/x², none). Documented in the validation report and applied consistently during sample analysis.',
    CONSTRAINT pk_bioanalytical_assay PRIMARY KEY(`bioanalytical_assay_id`)
) COMMENT 'Master definition of a validated bioanalytical assay used to quantify drug concentrations, biomarkers, or immunogenicity in clinical trial samples. Captures assay name, analyte measured, assay type (LC-MS/MS, ELISA, ECL, PCR, flow cytometry), validation';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` (
    `bioanalytical_result_id` BIGINT COMMENT 'Unique surrogate identifier for each bioanalytical or biomarker assay result record in the clinical trial laboratory data product. Serves as the primary key for the silver-layer lakehouse table.',
    `arm_id` BIGINT COMMENT 'Foreign key linking to study.study_arm. Business justification: PK/PD exposure analysis by treatment arm is a core pharmacokinetic reporting requirement. Arm-level PK parameter comparisons (e.g., AUC, Cmax by dose group) are required for regulatory',
    `bioanalytical_assay_id` BIGINT COMMENT 'Foreign key linking to laboratory.bioanalytical_assay. Business justification: A bioanalytical result is produced by executing a specific validated bioanalytical assay.',
    `blinding_config_id` BIGINT COMMENT 'Foreign key linking to randomization.blinding_config. Business justification: Bioanalytical/PK concentration results directly reveal treatment assignment in blinded studies. Blinding_config governs access restrictions for unblinded statisticians vs.',
    `consent_subject_consent_id` BIGINT COMMENT 'Foreign key linking to consent.subject_consent. Business justification: Bioanalytical data sharing with third parties (CROs, partners, regulators) requires subject consent verification.',
    `epoch_id` BIGINT COMMENT 'Foreign key linking to study.study_epoch. Business justification: PK/PD results must be epoch-stratified for NCA (single-dose vs steady-state epochs) and SDTM PC domain mapping.',
    `lab_facility_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_facility. Business justification: A bioanalytical result is generated at a specific laboratory facility. The existing laboratory_code STRING column is a denormalized reference to lab_facility.',
    `manufacture_batch_id` BIGINT COMMENT 'Foreign key linking to supply.manufacture_batch. Business justification: FDA/EMA bioanalytical method validation guidance requires traceability from drug concentration results to the specific IMP manufacture batch.',
    `pk_analysis_spec_id` BIGINT COMMENT 'Foreign key linking to biostatistics.pk_analysis_spec. Business justification: Bioanalytical results are processed into PK parameters according to a specific PK analysis spec (LLOQ handling, NCA rules, exclusion criteria).',
    `pk_sample_id` BIGINT COMMENT 'Reference to the biological specimen record from which this assay result was derived. Supports chain-of-custody traceability from collection through analysis.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) under which this bioanalytical result was generated. Links the result to the governing protocol, sponsor, and regulatory context.',
    `study_visit_schedule_id` BIGINT COMMENT 'Foreign key linking to study.study_visit_schedule. Business justification: PK/PD bioanalytical results must be mapped to protocol-defined sampling visits for SDTM PC/PP domain generation and NCA analysis.',
    `subject_randomization_id` BIGINT COMMENT 'Foreign key linking to randomization.subject_randomization. Business justification: PK/bioanalytical analysis (NCA, population PK, exposure-response) requires treatment arm and dose level from randomization.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial subject (participant) from whom the bioanalytical sample was collected. Enables subject-level PK/PD profiling and safety linkage.',
    `actual_time_point` DECIMAL(10,4) COMMENT 'The actual elapsed time (in hours post-dose) at which the sample was collected, calculated from the dose administration timestamp and sample collection timestamp. Used in non-compartmental and compartmental PK analysis.',
    `analysis_timestamp` TIMESTAMP COMMENT 'Date and time when the bioanalytical assay was performed and the result was generated by the laboratory instrument or system. Distinct from collection timestamp; used for audit trail and turnaround time tracking.',
    `assay_platform` STRING COMMENT 'Analytical technology platform used to generate this result. Determines method-specific acceptance criteria and regulatory validation requirements. Values include LC-MS/MS (liquid chromatography-tandem mass spectrometry), ELISA, ECL. Valid values are `LC-MS/MS|ELISA|ECL|PCR|FLOW_CYTOMETRY|NGS`',
    `assay_run_number` STRING COMMENT 'Unique identifier assigned by the bioanalytical laboratory to the analytical run (batch) in which this sample was processed. Used to link results to calibration curve and QC sample performance for the run. Maps to PCRUNID in CDISC SDTM PC domain.',
    `calibration_curve_accepted` BOOLEAN COMMENT 'Indicates whether the calibration curve for the analytical run met pre-defined acceptance criteria (e.g., ≥75% of calibrators within ±15% of nominal, ±20% at LLOQ). A failed calibration curve invalidates all results from the run.',
    `categorical_result` STRING COMMENT 'Qualitative or categorical result for assays that produce non-numeric outcomes (e.g., POSITIVE/NEGATIVE for immunogenicity, BELOW_LLOQ for concentrations below the lower limit of quantification). Null when numeric_result is populated.. Valid values are `POSITIVE|NEGATIVE|INDETERMINATE|BELOW_LLOQ|ABOVE_ULOQ`',
    `collection_timestamp` TIMESTAMP COMMENT 'Date and time when the biological sample was collected from the subject. The principal real-world event time for this bioanalytical result record. Maps to PCDTC in CDISC SDTM PC domain. Conforms to ISO 8601 format.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this bioanalytical result record was first created in the system of record. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `dilution_factor` DECIMAL(10,4) COMMENT 'The dilution factor applied to the sample prior to analysis when the original concentration exceeded the ULOQ. The reported result incorporates this factor. Maps to PCDILIND/PCDILUTN in CDISC SDTM PC domain.',
    `exclusion_flag` BOOLEAN COMMENT 'Indicates whether this result has been excluded from the primary PK/PD analysis dataset (e.g., due to protocol deviation, sample integrity issue, or statistical outlier determination per the Statistical Analysis Plan).',
    `exclusion_reason` STRING COMMENT 'Free-text or coded reason for excluding this result from the PK/PD analysis dataset. Required when exclusion_flag is true. Examples: Sample collected outside protocol window, Hemolyzed sample, Calibration curve failure, Subject vomited within 2',
    `freeze_thaw_cycles` BIGINT COMMENT 'Number of freeze-thaw cycles the sample underwent prior to analysis. Stability data from method validation defines the maximum allowable cycles; exceedance may invalidate the result.',
    `isr_flag` BOOLEAN COMMENT 'Indicates whether this sample was selected for Incurred Sample Reanalysis (ISR), a regulatory requirement to demonstrate reproducibility of results in authentic study samples. ISR is mandatory for pivotal PK studies submitted to FDA and EMA.',
    `isr_result` STRING COMMENT 'Outcome of the Incurred Sample Reanalysis (ISR) assessment. PASS indicates the original and repeat results agree within ±20% of their mean for ≥67% of ISR samples. FAIL triggers investigation. NOT_APPLICABLE when isr_flag is false.. Valid values are `PASS|FAIL|NOT_APPLICABLE`',
    `lloq` DECIMAL(18,6) COMMENT 'The lowest concentration of analyte in a sample that can be quantitatively determined with acceptable precision and accuracy for this validated method and run. Used to flag results as BLQ (below limit of quantification).',
    `matrix_type` STRING COMMENT 'Type of biological matrix from which the sample was derived and analyzed. Determines applicable method validation parameters and reference ranges. Maps to PCSPEC in CDISC SDTM PC domain.. Valid values are `PLASMA|SERUM|WHOLE_BLOOD|URINE|CSF|TISSUE`',
    `nominal_time_point` DECIMAL(10,4) COMMENT 'The protocol-specified time point (in hours post-dose) at which the sample was scheduled to be collected (e.g., 0.5, 1.0, 2.0, 4.0, 8.0, 24.0). Used as the reference for PK modeling and deviation calculation. Maps to PCTPTNUM in CDISC SDTM PC domain.',
    `numeric_result` DECIMAL(18,6) COMMENT 'Numeric result; implements SDTM PC.PCSTRESN',
    `qc_sample_performance` STRING COMMENT 'Overall acceptance outcome for the QC samples (low, medium, high QC) within the analytical run. PASS indicates ≥67% of QC samples within ±15% of nominal with at least 50% at each level passing. FAIL invalidates the run. MARGINAL triggers scientific review.. Valid values are `PASS|FAIL|MARGINAL`',
    `result_category` STRING COMMENT 'High-level classification of the bioanalytical result type: PK_CONCENTRATION (pharmacokinetic drug/metabolite concentration), BIOMARKER (pharmacodynamic or disease biomarker), IMMUNOGENICITY (anti-drug antibody or neutralizing antibody), EXPLORATORY. Valid values are `PK_CONCENTRATION|BIOMARKER|IMMUNOGENICITY|EXPLORATORY|PD_MARKER`',
    `result_comment` STRING COMMENT 'Free-text comment entered by the bioanalytical scientist or laboratory reviewer providing additional context for the result (e.g., instrument flags, unusual chromatography, sample appearance notes). Maps to PCORRES or PCCOMMENT in CDISC SDTM PC domain.',
    `result_reported_timestamp` TIMESTAMP COMMENT 'Date and time when the validated bioanalytical result was formally reported and released by the laboratory to the sponsor or data management team. Marks the transition from laboratory-internal to reportable status.',
    `result_status` STRING COMMENT 'Current disposition status of the bioanalytical result indicating whether it is reportable for inclusion in the clinical database, requires repeat analysis, or has been invalidated. Drives data flow into EDC and CDISC SDTM datasets.. Valid values are `REPORTABLE|NON_REPORTABLE|REPEAT_REQUIRED|PENDING|CANCELLED`',
    `result_unit` STRING COMMENT 'Result unit; implements SDTM PC.PCSTRESU (CDISC CT UNIT codelist)',
    `sample_stability_flag` BOOLEAN COMMENT 'Indicates whether the sample met stability criteria at the time of analysis based on validated short-term, long-term, and freeze-thaw stability data. False indicates a potential stability failure that may affect result validity.',
    `sdtm_domain` STRING COMMENT 'Target SDTM domain (PC); implements SDTM Dataset.DOMAIN. Valid values are `PC|PP|MB|IS`',
    `subject_number` STRING COMMENT 'Human-readable subject identifier (e.g., site-subject number such as 001-001) used in the clinical trial. Distinct from the surrogate subject_id; used for cross-system reconciliation and regulatory reporting.',
    `time_deviation_hours` DECIMAL(10,4) COMMENT 'Deviation of the actual sample collection time from the nominal protocol-specified time point, expressed in hours (actual minus nominal). Positive values indicate late collection; negative values indicate early collection.',
    `uloq` DECIMAL(18,6) COMMENT 'The highest concentration of analyte in a sample that can be quantitatively determined with acceptable precision and accuracy for this validated method and run. Results above ULOQ require dilution and re-analysis.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this bioanalytical result record. Required for audit trail compliance and incremental data pipeline processing in the Databricks silver layer.',
    CONSTRAINT pk_bioanalytical_result PRIMARY KEY(`bioanalytical_result_id`)
) COMMENT 'Transactional record of a bioanalytical or biomarker assay result from a clinical trial PK/PD, DMPK, or exploratory biomarker sample. Captures assay run ID, sample ID, analyte/biomarker measured, concentration or categorical result value, unit/scale';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` (
    `lab_accreditation_id` BIGINT COMMENT 'Unique surrogate identifier for the laboratory accreditation record in the Silver Layer lakehouse. Primary key for this entity.',
    `compliance_capa_id` BIGINT COMMENT 'Foreign key linking to compliance.capa. Business justification: When a lab accreditation inspection identifies deficiencies, a formal CAPA is initiated. lab_accreditation has capa_status, capa_due_date, capa_closure_date as denormalized text fields —',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: Lab accreditations are recognized by specific health authorities (FDA recognizes CAP/CLIA, EMA requires ISO 15189/GLP).',
    `primary_lab_facility_id` BIGINT COMMENT 'Reference to the laboratory facility for which this accreditation record applies. Links to the laboratory master record.',
    `qualifier_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Sponsor lab qualification assessments (ICH E6(R2)) require a named sponsor employee to perform and approve the qualification.',
    `regulatory_inspection_id` BIGINT COMMENT 'Foreign key linking to regulatory.inspection. Business justification: Lab accreditation status is directly reviewed during regulatory inspections. lab_accreditation has last_inspection_date, inspection_outcome, findings_summary as denormalized fields from',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to, for study context and traceability.',
    `submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission. Business justification: Lab accreditation certificates are required documentation in regulatory submissions (CTD Module 1).',
    `tertiary_lab_facility_id` BIGINT COMMENT 'FK to laboratory.lab_facility',
    `accreditation_body` STRING COMMENT 'Name of the accrediting or certifying organization that issued the accreditation (e.g., CAP - College of American Pathologists, CLIA - Clinical Laboratory Improvement Amendments, ISO 15189, UKAS - UK Accreditation Service, DAkkS - Deutsche',
    `accreditation_expiry_date` DATE COMMENT 'Date on which the primary laboratory accreditation (CLIA, CAP, or ISO 15189) expires. Used to trigger renewal workflows and to validate facility eligibility for ongoing and new study assignments. Critical for regulatory compliance monitoring.',
    `accreditation_scope` STRING COMMENT 'Narrative or structured description of the test menu and analytical disciplines covered by the accreditation (e.g., clinical chemistry, hematology, microbiology, PK/PD bioanalysis, DMPK assays, flow cytometry).',
    `accreditation_standard_version` STRING COMMENT 'Version or edition of the accreditation standard under which the certificate was issued (e.g., ISO 15189:2022, ISO 15189:2012, CAP 2023 Checklist). Relevant for regulatory submissions and gap assessments when standards are updated.',
    `accreditation_status` STRING COMMENT 'Current lifecycle status of the accreditation certificate. Drives eligibility of the laboratory for use in regulated clinical trials. Active status is required for regulatory submission documentation.. Valid values are `active|expired|suspended|withdrawn|pending|revoked`',
    `accreditation_type` STRING COMMENT 'Classification of the accreditation grant indicating the scope and conditions of the award (e.g., full accreditation, provisional, conditional, limited scope, renewal).. Valid values are `full|provisional|conditional|limited|renewal`',
    `certificate_number` STRING COMMENT 'Externally-issued certificate or accreditation number assigned by the accrediting body (e.g., CAP number, CLIA ID, ISO certificate number). This is the primary business identifier used in regulatory submissions and audit documentation.',
    `certification_status` STRING COMMENT 'Current lifecycle state of the accreditation as maintained by the issuing health authority. Drives facility eligibility for use in trials subject to that authoritys jurisdiction. Sourced directly from detection-phase relationship_data.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this accreditation record was first created in the system. Supports audit trail and data lineage requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `effective_date` DATE COMMENT 'Date on which the health authoritys certification or recognition of this facility became valid. Sourced directly from detection-phase relationship_data.',
    `expiry_date` DATE COMMENT 'Date on which the accreditation certificate expires and the laboratory must have completed renewal to remain qualified for use in regulated clinical trials. Critical for trial eligibility monitoring.',
    `gcp_compliant` BOOLEAN COMMENT 'Indicates whether the laboratory has been assessed and confirmed as compliant with Good Clinical Practice (GCP) requirements for clinical laboratory operations supporting regulated clinical trials.',
    `glp_compliant` BOOLEAN COMMENT 'Indicates whether the laboratory operates under Good Laboratory Practice (GLP) principles as required for non-clinical safety studies submitted to regulatory agencies. GLP compliance is distinct from ISO/CAP accreditation.',
    `inspection_outcome` STRING COMMENT 'Result of the most recent inspection conducted by this health authority at this facility. Authority-specific — the same facility may receive different outcomes from different authorities. Sourced directly from detection-phase relationship_data.',
    `issue_date` DATE COMMENT 'Date on which the accreditation certificate was formally issued or granted by the accrediting body. Represents the effective start of the accreditation period.',
    `lab_director_name` STRING COMMENT 'Full name of the qualified laboratory director responsible for the accredited laboratory facility. Required for regulatory submissions and accreditation documentation. Classified as confidential business data.',
    `lab_director_qualification` STRING COMMENT 'Professional qualifications, credentials, or certifications held by the laboratory director (e.g., MD, PhD, FACB, FRCPA). Required to verify director eligibility under CLIA and accrediting body requirements.',
    `lab_type` STRING COMMENT 'Classification of the laboratory by operational role in the clinical trial (central laboratory, local/site laboratory, reference laboratory, bioanalytical laboratory, specialty laboratory).. Valid values are `central|local|reference|bioanalytical|specialty`',
    `last_inspection_date` DATE COMMENT 'Date of the most recent regulatory or accreditation body inspection of the laboratory facility. Used to assess compliance currency and to schedule re-inspections per regulatory requirements.',
    `last_inspection_outcome` STRING COMMENT 'Result of the most recent regulatory or accreditation inspection. Drives risk-based monitoring decisions, sponsor qualification status, and CAPA initiation for the facility.. Valid values are `satisfactory|minor_findings|major_findings|critical_findings|pending_review`',
    `notes` STRING COMMENT 'Free-text field for additional operational notes, context, or clarifications related to the accreditation record that do not fit structured fields (e.g., special conditions, interim arrangements, liaison contact details).',
    `previous_certificate_number` STRING COMMENT 'Certificate number from the immediately preceding accreditation cycle. Supports continuity tracking and audit trail for regulatory submissions requiring historical accreditation evidence.',
    `proficiency_testing_program` STRING COMMENT 'Name of the external proficiency testing or external quality assessment (EQA) program in which the laboratory participates (e.g., CAP PT, UKNEQAS, EQAS, RCPA QAP). Supports accreditation body verification.',
    `proficiency_testing_status` STRING COMMENT 'Current status of the laboratorys external proficiency testing (PT) or external quality assessment (EQA) program participation. Proficiency testing is a mandatory component of CLIA and CAP accreditation and demonstrates ongoing analytical competency.. Valid values are `satisfactory|unsatisfactory|pending|not_applicable`',
    `qualification_assessment_date` DATE COMMENT 'Date on which the CRO or sponsor conducted an internal laboratory qualification assessment (distinct from the accrediting body inspection). Supports vendor qualification and oversight requirements under GCP.',
    `qualification_assessment_outcome` STRING COMMENT 'Outcome of the internal CRO or sponsor laboratory qualification assessment. Determines whether the laboratory may be activated for use in clinical trials managed by the organization.. Valid values are `qualified|conditionally_qualified|not_qualified|pending`',
    `recognition_type` STRING COMMENT 'The specific type of certification or regulatory recognition granted by this health authority to the facility (e.g., CLIA for FDA, GLP for EMA, GCP for PMDA). Sourced directly from detection-phase relationship_data.',
    `regulatory_submission_eligible` BOOLEAN COMMENT 'Indicates whether this laboratorys accreditation record is currently eligible to be cited in regulatory submissions (IND, NDA, BLA, MAA, CTD/eCTD). Derived from accreditation status, expiry, and CAPA closure but stored as an explicit business flag for',
    `renewal_due_date` DATE COMMENT 'Target date by which the renewal application must be submitted to the accrediting body to avoid a lapse in accreditation status. May differ from expiry_date based on accrediting body lead-time requirements.',
    `renewal_status` STRING COMMENT 'Current status of the accreditation renewal process. Tracks whether the laboratory has initiated, submitted, or completed renewal prior to certificate expiry to ensure uninterrupted trial eligibility.. Valid values are `not_started|in_progress|submitted|approved|lapsed`',
    `scope_includes_dmpk` BOOLEAN COMMENT 'Indicates whether the accreditation scope explicitly covers drug metabolism and pharmacokinetics (DMPK) assays, relevant for early-phase and ADME studies.',
    `scope_includes_pk_pd` BOOLEAN COMMENT 'Indicates whether the accreditation scope explicitly covers pharmacokinetic (PK) and pharmacodynamic (PD) bioanalytical testing, which is required for studies with PK/PD endpoints.',
    `sponsor_approval_date` DATE COMMENT 'Date on which the clinical trial sponsor formally approved the laboratory for use in their studies. Required for audit trail and regulatory submission documentation.',
    `sponsor_approved` BOOLEAN COMMENT 'Indicates whether the laboratory has been formally approved by the clinical trial sponsor for use in their studies. Sponsor approval is a prerequisite for laboratory qualification in addition to regulatory accreditation.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this accreditation record was most recently modified. Supports audit trail and change tracking requirements under 21 CFR Part 11 and ALCOA+ principles.',
    CONSTRAINT pk_lab_accreditation PRIMARY KEY(`lab_accreditation_id`)
) COMMENT 'Master record tracking laboratory facility accreditation and certification status. Captures accreditation body (CAP, CLIA, ISO 15189, UKAS, DAkkS), certificate number, accreditation scope (test menu), issue date, expiry date, renewal status, inspection';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` (
    `lab_kit_id` BIGINT COMMENT 'Unique surrogate identifier for the laboratory collection kit master record. Primary key for the lab_kit entity.',
    `approved_by_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Lab kit approval by a sponsor employee is a required step before kit deployment to sites, supporting regulatory inspection readiness.',
    `lab_facility_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_facility. Business justification: A laboratory collection kit is supplied by and associated with a specific central laboratory facility. The central_lab_code STRING column is a denormalized reference to lab_facility.',
    `lab_panel_id` BIGINT COMMENT 'Reference to the laboratory panel definition that this kit is designed to support. Ensures correct collection materials are used per protocol-specified assays.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Lab kits are designed and versioned per protocol specification (tube types, volumes, handling instructions).',
    `scope_of_work_id` BIGINT COMMENT 'Foreign key linking to agreement.scope_of_work. Business justification: The SOW specifies lab kit types, quantities per visit, and per-site supply requirements.',
    `study_contract_id` BIGINT COMMENT 'Foreign key linking to agreement.study_contract. Business justification: Lab kit procurement and supply is governed by the study contract as a pass-through cost item.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this kit is designated. Links the kit to a specific protocol and sponsor.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: Protocol amendments that change specimen collection requirements trigger new kit versions.',
    `study_site_id` BIGINT COMMENT 'Reference to the clinical site to which this kit is assigned or shipped. Supports site-level inventory tracking.',
    `approved_date` DATE COMMENT 'Date on which the kit design and components list was formally approved by the sponsor or quality team for use in the study. Supports audit trail and regulatory inspection readiness.',
    `biohazard_classification` STRING COMMENT 'IATA/UN biohazard classification for shipping the collected specimen (Category A UN2814, Category B UN3373, Exempt). Determines packaging and shipping documentation requirements for specimen transport.. Valid values are `category_a|category_b|exempt|not_applicable`',
    `cdisc_lbspec_code` STRING COMMENT 'CDISC specimen type code; implements SDTM LB.LBSPEC (CDISC CT SPECTYPE codelist). Valid values are `^[A-Z0-9 ]{1,40}$`',
    `collection_timepoint` STRING COMMENT 'Specific timepoint within a visit at which the specimen should be collected (e.g., pre-dose, 1h post-dose, 4h post-dose). Particularly relevant for PK/PD sampling schedules.',
    `components_description` STRING COMMENT 'Free-text or structured description of all components included in the kit (e.g., EDTA tubes, serum separator tubes, cryovials, dry ice packs, biohazard bags, requisition forms, instruction leaflets). Supports site training and deviation investigation.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the lab kit master record was first created in the system. Part of the mandatory audit trail for GCP compliance and 21 CFR Part 11 electronic records requirements.',
    `expiry_date` DATE COMMENT 'Date after which the kit must not be used for specimen collection. Expiry is driven by the stability of collection tubes, preservatives, and reagents. Sites must discard or return kits past this date.',
    `fasting_required` BOOLEAN COMMENT 'Indicates whether the subject must be fasting prior to specimen collection using this kit. Fasting status affects reference ranges and result interpretation for metabolic and lipid panels.',
    `is_ancillary_kit` BOOLEAN COMMENT 'Indicates whether this kit is an ancillary/backup kit (True) rather than a primary protocol-required kit (False). Ancillary kits are used for repeat collections or unscheduled assessments.',
    `kit_category` STRING COMMENT 'Functional category of the kit indicating the scientific purpose of the specimen collection (e.g., Pharmacokinetics (PK), Pharmacodynamics (PD), safety labs, biomarker, genetic). Aligns kit to the studys analytical objectives.',
    `kit_label_language` STRING COMMENT 'ISO 639 language code for the primary language of the kit label and instruction leaflet (e.g., en, fr, de, ja). Ensures regulatory compliance for multi-country trials requiring local language labelling.. Valid values are `^[a-z]{2,3}(-[A-Z]{2})?$`',
    `kit_number` STRING COMMENT 'Externally-known unique alphanumeric identifier assigned to the kit, typically printed on the kit label and used for chain-of-custody tracking. Corresponds to the kit barcode or label ID in RTSM/IRT systems such as Medidata Rave RTSM.. Valid values are `^[A-Z0-9-]{4,30}$`',
    `kit_status` STRING COMMENT 'Current lifecycle status of the kit. Drives inventory management workflows and ensures expired or quarantined kits are not used for specimen collection. [ENUM-REF-CANDIDATE: available|assigned|shipped|received|used|expired|quarantined|destroyed|returned —',
    `kit_type` STRING COMMENT 'Classification of the kit by specimen matrix type (e.g., blood, urine, tissue). Determines the collection containers and preservatives included. [ENUM-REF-CANDIDATE: blood|urine|saliva|tissue|csf|stool|buccal_swab|plasma|serum|other — promote to reference',
    `kit_version` STRING COMMENT 'Version identifier of the kit design or configuration. Used to track protocol amendments that change collection requirements, ensuring sites use the correct kit version per the current protocol.. Valid values are `^[A-Za-z0-9.-]{1,20}$`',
    `lab_accreditation_standard` STRING COMMENT 'Accreditation standard under which the central laboratory processing specimens from this kit is certified (e.g., ISO 15189, CAP, CLIA, GCLP). Required for regulatory submissions and sponsor quality oversight.. Valid values are `iso_15189|cap|clia|gclp|other`',
    `lot_number` STRING COMMENT 'Manufacturing lot number assigned by the kit supplier or central laboratory. Enables traceability for quality investigations, recalls, and regulatory inspections. Critical for ALCOA+ compliance.. Valid values are `^[A-Z0-9-]{2,30}$`',
    `manufacture_date` DATE COMMENT 'Date on which the kit was manufactured or assembled by the supplier. Used in conjunction with expiry date to calculate shelf life and manage inventory rotation.',
    `preservative_type` STRING COMMENT 'Type of preservative or additive included in the kit (e.g., EDTA, heparin, sodium fluoride, formalin, RNAlater). Critical for specimen stability and downstream analytical method compatibility.',
    `protocol_visit_reference` STRING COMMENT 'Protocol-defined visit name or visit window for which this kit is intended (e.g., Screening, Day 1, Week 4). Ensures the correct kit type is used at the correct study visit per the protocol schedule of assessments.',
    `quantity_per_shipment` BIGINT COMMENT 'Standard number of kits included in a single shipment to a site. Used for supply planning, purchase order generation, and site inventory management.',
    `reorder_threshold` BIGINT COMMENT 'Minimum quantity of kits at a site below which a resupply order should be triggered. Supports proactive inventory management to prevent site stock-outs.',
    `requisition_form_included` BOOLEAN COMMENT 'Indicates whether a laboratory requisition form (paper or pre-printed label) is included in the kit. Requisition forms are required by central labs for specimen processing and chain-of-custody documentation.',
    `return_kit_required` BOOLEAN COMMENT 'Indicates whether the used kit or residual materials must be returned to the central laboratory or sponsor after specimen collection. Relevant for chain-of-custody and waste management compliance.',
    `storage_condition` STRING COMMENT 'Categorical storage condition required for the kit (e.g., refrigerated 2–8°C, frozen −20°C, room temperature). Complements the numeric temperature range with a human-readable label for site staff.. Valid values are `room_temperature|refrigerated|frozen|dry_ice|protect_from_light|other`',
    `storage_temperature_max_c` DECIMAL(5,2) COMMENT 'Maximum allowable storage temperature in degrees Celsius for the kit. Used alongside minimum temperature to define the acceptable storage range and trigger excursion alerts.',
    `storage_temperature_min_c` DECIMAL(5,2) COMMENT 'Minimum allowable storage temperature in degrees Celsius for the kit. Ensures cold-chain integrity and preservative efficacy. Deviations must be documented per GCP.',
    `supplier_kit_catalog_number` STRING COMMENT 'Suppliers own catalog or part number for this kit configuration. Used for reordering, purchase orders in the source system supplier quality documentation.. Valid values are `^[A-Z0-9-.]{2,40}$`',
    `supplier_name` STRING COMMENT 'Name of the vendor or central laboratory that manufactured and supplied the kit. Used for procurement, quality investigations, and supplier qualification tracking.',
    `tube_count` BIGINT COMMENT 'Total number of collection tubes included in the kit. Used for inventory reconciliation and to verify completeness of kit contents upon receipt at the site.',
    `tube_type` STRING COMMENT 'Type of collection tube(s) included in the kit (e.g., EDTA K2, SST, lithium heparin, sodium citrate, PAXgene). Determines anticoagulant or additive present, which is critical for assay validity.',
    `tube_volume_ml` DECIMAL(6,2) COMMENT 'Nominal volume in millilitres of each collection tube in the kit. Used to confirm adequate sample volume for the required assays and to flag insufficient sample at processing.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the lab kit master record was last modified. Supports change tracking, audit trail requirements, and incremental data loading in the Databricks Silver layer.',
    CONSTRAINT pk_lab_kit PRIMARY KEY(`lab_kit_id`)
) COMMENT 'Master record for laboratory collection kits supplied to clinical sites for specimen collection. Captures kit type, kit lot number, components list (tubes, containers, preservatives, requisition forms), storage requirements, expiry date, kit version, and';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` (
    `lab_query_id` BIGINT COMMENT 'Unique surrogate identifier for the laboratory data query record in the Databricks Silver Layer. Primary key for this entity.',
    `adverse_event_id` BIGINT COMMENT 'Foreign key linking to safety.adverse_event. Business justification: Lab queries with safety_relevance_flag=true are raised to resolve data discrepancies that affect AE reporting.',
    `bioanalytical_result_id` BIGINT COMMENT 'Foreign key linking to laboratory.bioanalytical_result. Business justification: Data queries in clinical trials can be raised against bioanalytical results (PK/PD, DMPK data) in the EDC, not only against standard lab results.',
    `lab_analyte_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_analyte. Business justification: A lab query is raised against a specific analyte result. The lbtestcd STRING column on lab_query is a denormalized reference to the analyte tested.',
    `laboratory_lab_result_id` BIGINT COMMENT 'Reference to the specific laboratory result record in the lab_result product that this query was raised against. Core linkage between the query and the underlying data point.',
    `primary_lab_employee_id` BIGINT COMMENT 'Reference to the workforce/user record of the individual (data manager, medical monitor, CRA, or system process) who raised this query. Supports ALCOA+ attributability and audit trail requirements.',
    `quality_event_id` BIGINT COMMENT 'Foreign key linking to compliance.quality_event. Business justification: Lab queries that reveal systematic data issues (e.g., multiple sites with same anomaly, instrument calibration failure) escalate to formal quality events.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study under which this laboratory query was raised. Links the query to the parent protocol and sponsor context.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site associated with the subject whose laboratory result triggered this query. Used for site-level query metrics and monitoring.',
    `subject_visit_id` BIGINT COMMENT 'Reference to the scheduled or unscheduled study visit during which the specimen was collected and the lab result was generated, providing temporal context for the query.',
    `tertiary_lab_responded_by_user_employee_id` BIGINT COMMENT 'Reference to the user who submitted the query response on behalf of the site or laboratory. Supports ALCOA+ attributability and electronic signature audit trail per 21 CFR Part 11.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial subject (patient) whose laboratory result is the subject of this query. Supports subject-level data quality tracking.',
    `cancellation_reason` STRING COMMENT 'Free-text explanation of why the query was cancelled, if applicable (e.g., query raised in error, duplicate query, data issue resolved through another mechanism). Required for cancelled queries to maintain ALCOA+ audit trail integrity.',
    `corrected_value` DECIMAL(18,2) COMMENT 'The laboratory result value after correction, if a data change was made as a result of this query. Null if no correction was applied. Provides after-state for audit trail per ALCOA+ and 21 CFR Part 11 requirements.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this lab_query record was first created in the Databricks Silver Layer. Audit trail field for data lineage and ALCOA+ compliance. Distinct from raised_datetime which captures the business event time.',
    `data_correction_flag` BOOLEAN COMMENT 'Indicates whether the resolution of this query resulted in a data value change in the source EDC or LIMS record. True = a data correction was made; False = original data confirmed or query cancelled without change. Key metric for data quality reporting.',
    `dbl_blocking_flag` BOOLEAN COMMENT 'Indicates whether this open query is blocking the Database Lock (DBL) for the study or subject. True = must be resolved before DBL can proceed; False = non-blocking. Critical for study close-out planning and timeline management.',
    `ecrf_field_name` STRING COMMENT 'Specific field name within the eCRF form that contains the queried laboratory data value (e.g., LBORRES, LBORRESU). Enables precise identification of the data point in question for site response and EDC correction.',
    `ecrf_form_name` STRING COMMENT 'Name of the eCRF form in the EDC (Medidata Rave) on which the queried laboratory data field resides (e.g., Laboratory Results, Hematology). Supports EDC navigation and query routing to the correct data entry form.',
    `edc_query_code` STRING COMMENT 'Native query identifier assigned by the source EDC system (Medidata Rave) or LIMS. Enables bidirectional traceability between the lakehouse Silver Layer record and the operational system of record for reconciliation and audit.',
    `escalation_datetime` TIMESTAMP COMMENT 'Date and time when the query was formally escalated. Null if no escalation has occurred. Used for escalation cycle time analytics and regulatory inspection readiness.',
    `escalation_flag` BOOLEAN COMMENT 'Indicates whether this query has been formally escalated to a higher authority (e.g., from CRA to Clinical Lead, or from site to sponsor medical monitor) due to non-response, SLA breach, or data criticality. Triggers escalation workflow in CTMS.',
    `original_value` DECIMAL(18,2) COMMENT 'The laboratory result value as it existed at the time the query was raised, captured as a string to accommodate numeric, text, and coded values. Provides before-state for audit trail and data lineage per ALCOA+ requirements.',
    `query_category` STRING COMMENT 'Functional category indicating which business process or team initiated the query — data management programmatic check, medical monitor review, safety review, statistical review, or site-initiated clarification.. Valid values are `data_management|medical_review|safety_review|statistical_review|site_initiated`',
    `query_iteration_count` BIGINT COMMENT 'Number of times this query has been re-opened or re-issued against the same laboratory result field, indicating the number of response-review cycles. A high iteration count signals persistent data quality issues at the site or lab.',
    `query_number` STRING COMMENT 'Human-readable, externally visible query identifier assigned by the EDC (Medidata Rave) or LIMS system at the time of query creation. Used for cross-system tracking and communication with sites and labs (e.g., QRY-2024-00123).',
    `query_priority` STRING COMMENT 'Business priority assigned to the query indicating urgency of resolution. Critical queries (e.g., those linked to SAE data or DBL-blocking issues) require immediate attention. Drives escalation and SLA enforcement.. Valid values are `critical|high|medium|low`',
    `query_source_system` STRING COMMENT 'Identifies the operational system of record in which this query originated — EDC (Medidata Rave), a Laboratory Information Management System (LIMS), the source system or a manually entered query. Supports multi-system data quality governance.. Valid values are `Medidata Rave|LIMS|Oracle Clinical One|Manual`',
    `query_status` STRING COMMENT 'Current lifecycle state of the laboratory data query. Drives workflow routing, SLA monitoring, and DBL readiness assessment. Open = awaiting response; Answered = response received, pending DM review; Closed = resolved and accepted; Cancelled = withdrawn.. Valid values are `open|answered|closed|cancelled`',
    `query_text` STRING COMMENT 'Full narrative text of the query as raised by the data manager or medical monitor, describing the data issue, the specific concern, and the action requested from the site or laboratory. Core ALCOA+ documentation field.',
    `query_type` STRING COMMENT 'Classification of the reason the query was raised against the laboratory result. Drives triage, routing, and resolution workflows. [ENUM-REF-CANDIDATE. Valid values are `missing_value|implausible_result|unit_mismatch|collection_time_deviation|reference_range_deviation|transcription_error`',
    `raised_by_role` STRING COMMENT 'Functional role of the person or process that raised the query (e.g., Data Manager, Medical Monitor, Clinical Research Associate (CRA), Statistician, or automated system check). Denormalized for reporting without requiring a user-role join.. Valid values are `data_manager|medical_monitor|cra|statistician|system_auto`',
    `raised_datetime` TIMESTAMP COMMENT 'Date and time (ISO 8601 with timezone) when the query was formally raised and entered into the EDC or LIMS. Principal business event timestamp for the query lifecycle. Required for SLA calculation and ALCOA+ contemporaneity compliance.',
    `resolution_action` STRING COMMENT 'Outcome action taken to resolve the query: data value was corrected in the EDC/LIMS, original data was confirmed as correct, query was withdrawn by the raiser, or no action was required. Critical for data audit trail and regulatory inspection readiness.. Valid values are `data_corrected|data_confirmed|query_withdrawn|no_action_required`',
    `resolution_datetime` TIMESTAMP COMMENT 'Date and time (ISO 8601 with timezone) when the query was formally closed or cancelled by the data manager after reviewing the site/lab response. Marks the end of the query lifecycle. Used for cycle time analytics and DBL readiness.',
    `response_datetime` TIMESTAMP COMMENT 'Date and time (ISO 8601 with timezone) when the site or laboratory submitted their response to the query. Used for SLA compliance measurement and ALCOA+ contemporaneity tracking.',
    `response_text` STRING COMMENT 'Full narrative response provided by the site or laboratory in reply to the query, explaining the data discrepancy, confirming the value, or documenting a correction. Core ALCOA+ documentation field for audit trail.',
    `safety_relevance_flag` BOOLEAN COMMENT 'Indicates whether the queried laboratory result is associated with a safety event (SAE, AE, or SUSAR) or a critical value, requiring expedited resolution. True = safety-relevant; False = routine data quality query.',
    `sla_breach_flag` BOOLEAN COMMENT 'Indicates whether the query response or resolution exceeded the defined SLA target days. True = SLA was breached; False = responded within SLA. Drives escalation workflows and site performance KPI reporting.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this lab_query record was last modified in the Databricks Silver Layer. Supports incremental data processing, change detection, and audit trail requirements per 21 CFR Part 11.',
    `usubjid` STRING COMMENT 'CDISC SDTM-compliant unique subject identifier (sponsor-study-subject concatenation) denormalized onto the query record for direct regulatory submission traceability and ALCOA+ audit compliance without requiring a join.',
    `visit_name` STRING COMMENT 'Protocol-defined visit name (e.g., Screening, Week 4, End of Treatment) during which the queried laboratory specimen was collected. Denormalized for query analytics and reporting without requiring a visit join.',
    CONSTRAINT pk_lab_query PRIMARY KEY(`lab_query_id`)
) COMMENT 'Transactional record of a data query raised against a laboratory result in the EDC (Medidata Rave) or LIMS. Captures query ID, query type (missing value/implausible result/unit mismatch/collection time deviation), query text, raised by (data';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` (
    `specimen_aliquot_id` BIGINT COMMENT 'Unique surrogate identifier for the specimen aliquot record in the lakehouse silver layer. Primary key for this entity.',
    `bioanalytical_assay_id` BIGINT COMMENT 'Reference to the validated bioanalytical assay method assigned to test this aliquot. Applicable for PK, PD, and biomarker aliquots.',
    `consent_subject_consent_id` BIGINT COMMENT 'Foreign key linking to consent.subject_consent. Business justification: Biorepository operations require that each stored aliquot is traceable to the consent version authorizing its use (biobanking, genetic testing, secondary research).',
    `lab_facility_id` BIGINT COMMENT 'Reference to the central or local laboratory responsible for receiving, storing, or testing this aliquot.',
    `parent_specimen_id` BIGINT COMMENT 'Reference to the primary specimen from which this aliquot was derived. Establishes the parent-child chain of custody lineage.',
    `shipment_id` BIGINT COMMENT 'Reference to the shipment manifest under which this aliquot was transported to a testing or storage laboratory. Supports chain of custody and logistics tracking.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study (protocol) under which this aliquot was collected and is being managed.',
    `study_site_id` BIGINT COMMENT 'Reference to the clinical site where the parent specimen was collected and the aliquot originated.',
    `subject_visit_id` BIGINT COMMENT 'Reference to the subject study visit at which the parent specimen was collected. Links aliquot to the clinical event context.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial subject (patient) from whom the parent specimen was collected. Supports subject-level sample accountability.',
    `aliquot_code` STRING COMMENT 'Human-readable, externally-known unique barcode or label identifier assigned to this aliquot at the time of processing. Used for physical tracking and chain of custody.. Valid values are `^[A-Z0-9_-]{3,40}$`',
    `aliquot_purpose` STRING COMMENT 'Designated analytical or storage purpose for this aliquot. Drives routing to the appropriate laboratory or storage tier. [ENUM-REF-CANDIDATE: clinical_testing|pk_analysis|biomarker|backup|archive|exploratory — promote to reference product if additional',
    `aliquot_seq_num` BIGINT COMMENT 'Sequential integer identifying the order in which this aliquot was derived from the parent specimen (e.g., 1, 2, 3). Supports multi-aliquot tracking per specimen.',
    `aliquot_status` STRING COMMENT 'Current lifecycle status of the aliquot. Drives chain of custody accountability and biorepository management workflows. [ENUM-REF-CANDIDATE: pending|in_storage|in_transit|in_testing|consumed|destroyed|lost — promote to reference product]',
    `blinded_flag` BOOLEAN COMMENT 'Indicates whether this aliquot is subject to study blinding (i.e., treatment assignment is masked). Governs access controls and prevents unblinding during active study phases.',
    `box_code` STRING COMMENT 'Identifier of the box or tray within the rack where this aliquot is placed. Part of the three-dimensional storage coordinate system.. Valid values are `^[A-Z0-9_-]{1,20}$`',
    `chain_of_custody_flag` BOOLEAN COMMENT 'Indicates whether a complete, unbroken chain of custody record exists for this aliquot from collection through current status. A value of False triggers a compliance review.',
    `collection_datetime` TIMESTAMP COMMENT 'Date and time the parent specimen was collected from the subject. Inherited from the parent specimen for chain of custody and stability calculations.',
    `comments` STRING COMMENT 'Free-text field for laboratory technician or data manager notes regarding this aliquot (e.g., visible hemolysis, lipemia, unusual appearance, processing deviations).',
    `container_type` STRING COMMENT 'Type of physical container used to store the aliquot (e.g., cryovial, EDTA tube, serum separator tube, microcentrifuge tube). Affects stability and compatibility with analytical methods.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this aliquot record was first created in the system. Supports audit trail and ALCOA+ data integrity requirements.',
    `data_origin` STRING COMMENT 'Source system from which this aliquot record was ingested (e.g., Medidata Rave RTSM, the source system laboratory information management system). Supports data lineage and reconciliation.. Valid values are `medidata_rave|oracle_clinical_one|manual_entry|lab_system|import`',
    `destruction_date` DATE COMMENT 'Date on which the aliquot was destroyed or discarded, if applicable. Required for chain of custody closure and regulatory accountability.',
    `destruction_reason` STRING COMMENT 'Reason for aliquot destruction or discard. Required for regulatory accountability and chain of custody documentation. [ENUM-REF-CANDIDATE: stability_expired|volume_insufficient|testing_complete|sponsor_request|protocol_deviation|lost|contaminated —',
    `freeze_thaw_count` BIGINT COMMENT 'Cumulative number of freeze-thaw cycles this aliquot has undergone. Exceeding the validated limit may compromise analyte integrity and render the aliquot unsuitable for testing.',
    `max_freeze_thaw_allowed` BIGINT COMMENT 'Validated maximum number of freeze-thaw cycles permitted for this aliquot type before analyte stability is compromised. Defined in the bioanalytical method validation plan.',
    `position_code` STRING COMMENT 'Alphanumeric position coordinate within the box (e.g., A1, B12, H08) identifying the exact slot where the aliquot is stored. Enables precise physical retrieval.. Valid values are `^[A-Z]{1,2}[0-9]{1,3}$`',
    `processing_datetime` TIMESTAMP COMMENT 'Date and time the aliquot was separated from the parent specimen and prepared for storage or shipment. Critical for stability and pre-analytical variable tracking.',
    `protocol_num` STRING COMMENT 'Sponsor-assigned protocol number for the clinical study. Denormalized for direct regulatory reporting and specimen labeling without requiring a study join.. Valid values are `^[A-Z0-9_-]{3,30}$`',
    `rack_code` STRING COMMENT 'Identifier of the rack within the storage unit where this aliquot is placed. Part of the three-dimensional storage coordinate system (rack/box/position).. Valid values are `^[A-Z0-9_-]{1,20}$`',
    `stability_expiry_date` DATE COMMENT 'Date beyond which the aliquot is considered analytically unstable based on validated long-term stability data. Triggers discard or re-evaluation workflows.',
    `storage_temperature_c` DECIMAL(6,2) COMMENT 'Nominal storage temperature in degrees Celsius for this aliquot (e.g., -80, -20, 4, 25). Used for stability monitoring and deviation assessment.',
    `storage_unit_code` BIGINT COMMENT 'Reference to the physical storage unit (freezer, refrigerator, liquid nitrogen tank) where this aliquot is currently placed. Supports biorepository location management.',
    `storage_unit_type` STRING COMMENT 'Classification of the storage unit housing this aliquot (e.g., -80°C freezer, -20°C freezer, refrigerator, liquid nitrogen vapor phase). Determines stability expectations.',
    `temperature_excursion_flag` BOOLEAN COMMENT 'Indicates whether this aliquot has experienced a documented temperature excursion outside the validated storage range. Triggers stability impact assessment.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when this aliquot record was last modified. Supports audit trail, change detection, and incremental data pipeline processing.',
    `usubjid` STRING COMMENT 'CDISC SDTM-compliant unique subject identifier (sponsor-subject-site concatenation). Required for regulatory submission datasets and cross-domain subject traceability.. Valid values are `^[A-Z0-9_-]{1,50}$`',
    `volume_ml` DECIMAL(10,4) COMMENT 'Volume of the aliquot in millilitres at the time of processing. Used for sufficiency assessment and inventory management.',
    `volume_sufficient_flag` BOOLEAN COMMENT 'Indicates whether the remaining aliquot volume is sufficient to complete the assigned assay or testing requirement. Drives re-collection or backup aliquot retrieval workflows.',
    `volume_unit` STRING COMMENT 'Unit of measure for the aliquot volume. Typically mL for liquid specimens; mg or g for tissue aliquots.. Valid values are `mL|uL|mg|g`',
    CONSTRAINT pk_specimen_aliquot PRIMARY KEY(`specimen_aliquot_id`)
) COMMENT 'Master record for aliquots derived from a primary specimen for distribution to multiple testing labs or long-term storage, including storage placement tracking.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` (
    `protocol_lab_schedule_id` BIGINT COMMENT 'Unique surrogate identifier for each protocol-mandated laboratory assessment schedule record in the Databricks Silver Layer. Primary key for this entity.',
    `epoch_id` BIGINT COMMENT 'Foreign key linking to study.study_epoch. Business justification: Lab schedules are organized by study epoch (screening, treatment, follow-up); linking to epoch enables epoch-level lab requirement reporting, SDTM TE domain mapping, and protocol schedule',
    `lab_panel_id` BIGINT COMMENT 'Reference to the laboratory panel (e.g., hematology, chemistry, urinalysis, PK/PD, DMPK) required or optionally collected at this visit per the protocol schedule.',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Protocol lab schedules are defined per protocol version; regulatory submissions and protocol compliance audits require tracing which lab panels were mandated by which protocol version.',
    `regulatory_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to regulatory.protocol_amendment. Business justification: Protocol amendments frequently change lab assessment schedules (adding/removing panels, changing timepoints).',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this laboratory assessment schedule is defined. Links to the master study record.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: When protocol amendments change visit or specimen requirements, new lab schedule versions are issued.',
    `backup_sample_required` BOOLEAN COMMENT 'Indicates whether a backup or reserve aliquot must be collected and stored alongside the primary specimen for potential future analysis (e.g., for biomarker or pharmacogenomics research).',
    `central_lab_required` BOOLEAN COMMENT 'Indicates whether this laboratory assessment must be performed at the central laboratory (as opposed to a local laboratory). Drives specimen shipment logistics and result routing.',
    `collection_time_constraint` STRING COMMENT 'Time-of-day or dose-relative constraint for specimen collection at this visit (e.g., pre-dose, post-dose, morning only, timed serial PK sampling). Critical for PK/PD and DMPK assessments.. Valid values are `pre_dose|post_dose|morning_only|timed_serial|any_time|within_window`',
    `collection_time_offset_hours` DECIMAL(6,2) COMMENT 'Nominal time offset in hours relative to dose administration for post-dose or timed serial specimen collection (e.g., 0.5, 1, 2, 4, 8, 24 hours post-dose). Applicable primarily to PK/PD and DMPK assessments.',
    `collection_time_window_minutes` BIGINT COMMENT 'Acceptable deviation window in minutes around the nominal collection time offset for timed specimen collection. Used to assess protocol deviations for PK/PD sampling.',
    `collection_tube_type` STRING COMMENT 'Type of collection tube or container required for specimen collection (e.g., EDTA, SST, lithium heparin, sodium citrate, PAXgene). Drives specimen collection kit configuration and laboratory processing instructions.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this protocol laboratory schedule record was first created in the system. Supports audit trail requirements under 21 CFR Part 11 and ICH E6(R2) GCP.',
    `critical_result_review_required` BOOLEAN COMMENT 'Indicates whether results from this laboratory assessment require expedited medical review upon receipt of a critical or panic value. Triggers safety review workflows and potential SAE/SUSAR reporting obligations.',
    `edc_form_name` STRING COMMENT 'Name of the eCRF form in Medidata Rave that corresponds to this laboratory assessment at this visit. Used to drive EDC study build configuration and eCRF lab page activation.',
    `effective_date` DATE COMMENT 'Date from which this laboratory schedule entry is effective, typically aligned with the protocol version approval date or protocol amendment effective date.',
    `fasting_duration_hours_min` DECIMAL(4,1) COMMENT 'Minimum number of hours the subject must fast prior to specimen collection when fasting is required. Null when fasting_required is false.',
    `fasting_required` BOOLEAN COMMENT 'Indicates whether the subject must be in a fasted state prior to specimen collection for this laboratory assessment at this visit. Drives subject instructions and site collection procedures.',
    `is_exploratory` BOOLEAN COMMENT 'Indicates whether this laboratory assessment is an exploratory or research-use-only endpoint not included in the primary or secondary efficacy analyses. Supports data management and the source system',
    `is_pd_assessment` BOOLEAN COMMENT 'Indicates whether this laboratory assessment is a pharmacodynamic (PD) biomarker collection. Supports differentiation of PD endpoints from standard safety laboratory panels.',
    `is_pk_assessment` BOOLEAN COMMENT 'Indicates whether this laboratory assessment is a pharmacokinetic (PK) or DMPK sample collection. When true, timed serial collection rules and PK-specific processing instructions apply.',
    `is_safety_assessment` BOOLEAN COMMENT 'Indicates whether this laboratory assessment is designated as a safety laboratory panel per the protocol. Safety assessments trigger critical value review workflows and DSMB/DMC reporting obligations.',
    `local_lab_allowed` BOOLEAN COMMENT 'Indicates whether results from a local (site) laboratory are acceptable for this assessment, either as a primary result or as a backup when central lab results are unavailable.',
    `panel_requirement` STRING COMMENT 'Indicates whether the laboratory panel is mandatory (required), optional, conditional on a clinical trigger, restricted to the PK cohort, or applicable only to a defined subject subset per the protocol schedule of assessments.. Valid values are `required|optional|conditional|pk_cohort_only|subset_only`',
    `processing_required` BOOLEAN COMMENT 'Indicates whether the specimen requires on-site processing (e.g., centrifugation, aliquoting) prior to shipment to the central laboratory. Drives site laboratory capability requirements.',
    `repeat_allowed` BOOLEAN COMMENT 'Indicates whether a repeat specimen collection is permitted at this visit if the initial sample is insufficient, haemolysed, or otherwise unacceptable. Drives site instructions and EDC query management.',
    `result_turnaround_days` BIGINT COMMENT 'Expected number of calendar days from specimen receipt at the laboratory to result reporting. Used for monitoring visit planning, data management timelines, and SLA tracking with the central laboratory.',
    `schedule_notes` STRING COMMENT 'Free-text notes or footnotes from the protocol schedule of assessments providing additional instructions, conditional collection rules, or clarifications for this laboratory assessment at this visit.',
    `schedule_status` STRING COMMENT 'Current lifecycle status of this protocol laboratory schedule entry. Reflects whether the schedule is in draft, active per the current protocol version, amended, superseded by a protocol amendment, or retired.. Valid values are `draft|active|amended|superseded|retired`',
    `sdtm_domain` STRING COMMENT 'Target SDTM domain; implements SDTM Dataset.DOMAIN',
    `shipment_frequency` STRING COMMENT 'Frequency at which specimens collected at this visit should be shipped to the central laboratory (e.g., immediate same-day shipment for PK samples, weekly batch shipment for routine safety labs).. Valid values are `immediate|daily|weekly|per_visit|batch`',
    `source_system_record_code` STRING COMMENT 'Native identifier of this laboratory schedule record in the originating operational system (e.g., the source system assessment ID, Medidata Rave form OID). Supports data lineage, reconciliation, and audit traceability in the Silver Layer.',
    `specimen_type` STRING COMMENT 'Type of biological specimen required for this laboratory panel at this visit (e.g., blood, urine, plasma, serum, CSF). Drives specimen collection kit configuration and chain of custody planning.',
    `specimen_volume_ml` DECIMAL(8,3) COMMENT 'Volume of biological specimen in millilitres required for this laboratory panel assessment. Used for specimen collection planning, blood volume burden calculations, and supply chain management.',
    `storage_temperature` STRING COMMENT 'Required storage temperature condition for the specimen prior to shipment or analysis (e.g., ambient, refrigerated 2-8°C, frozen -20°C, frozen -80°C, liquid nitrogen). Drives cold chain logistics and supply chain management.. Valid values are `ambient|refrigerated|frozen_minus20|frozen_minus80|liquid_nitrogen`',
    `study_day_target` BIGINT COMMENT 'The nominal study day on which this visit and laboratory assessment is scheduled relative to the reference start date (Day 1 = first dose). Negative values indicate pre-dose screening days. Aligns with CDISC SDTM study day conventions.',
    `subject_population` STRING COMMENT 'Defines which subject population is required to undergo this laboratory assessment at the specified visit. Supports PK cohort-specific sampling, sentinel cohort rules, and expansion cohort differentiation as defined in the protocol.. Valid values are `all_subjects|pk_cohort|subset|sentinel_cohort|expansion_cohort`',
    `superseded_date` DATE COMMENT 'Date on which this laboratory schedule entry was superseded by a protocol amendment or replaced by a new schedule version. Null for currently active entries.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this protocol laboratory schedule record was last modified. Supports change tracking, audit trail requirements, and Silver Layer incremental load processing.',
    `visit_name` STRING COMMENT 'Visit name; implements SDTM --VISIT',
    `visit_num` DECIMAL(6,1) COMMENT 'Visit number; implements SDTM --VISITNUM',
    `visit_type` STRING COMMENT 'Visit type; implements SDTM TV/SV visit metadata (CDISC CT visit-type codelist)',
    `visit_window_day_max` BIGINT COMMENT 'Latest allowable study day (relative to target study day) for the visit window, defining the acceptable upper bound for specimen collection. Used for protocol deviation assessment and site monitoring.',
    `visit_window_day_min` BIGINT COMMENT 'Earliest allowable study day (relative to target study day) for the visit window, defining the acceptable lower bound for specimen collection. Used for protocol deviation assessment and site monitoring.',
    CONSTRAINT pk_protocol_lab_schedule PRIMARY KEY(`protocol_lab_schedule_id`)
) COMMENT 'Master definition of the protocol-mandated laboratory assessment schedule for a study, mapping each study visit to required lab panels. Captures study ID, visit name/number, visit window (day range), required lab panels, optional panels, fasting';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` (
    `lab_certification_id` BIGINT COMMENT 'Primary key for lab_certification',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.health_authority. Business justification: Lab certifications (GCP, GLP, CLIA) are issued or recognized by specific health authorities.',
    `lab_facility_id` BIGINT COMMENT 'Reference to the laboratory facility that holds this certification. Links to the laboratory master record.',
    `reviewer_employee_id` BIGINT COMMENT 'Foreign key linking to workforce.employee. Business justification: Sponsor staff review lab certifications for regulatory submission eligibility and TMF filing. ICH E6(R2) requires sponsor oversight of lab qualification documents.',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to, for study context and traceability.',
    `submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.submission. Business justification: Lab certification documents are included in regulatory submissions as part of the administrative/quality section (CTD Module 1).',
    `tmf_artifact_id` BIGINT COMMENT 'Reference to the corresponding TMF artifact record in the document management system (Veeva Vault eTMF) where the certificate document is filed. Supports TMF completeness tracking and inspection readiness.',
    `applicable_study_phases` STRING COMMENT 'Clinical trial phases for which this certification qualifies the laboratory to perform testing (e.g., Phase I, Phase II, Phase III, All Phases, Phase I only). Supports site feasibility and lab qualification assessments.',
    `capa_reference` STRING COMMENT 'Reference identifier for any open or closed Corrective and Preventive Action (CAPA) record associated with inspection findings or certification deficiencies. Links to the CAPA tracking system (MasterControl).',
    `certificate_number` STRING COMMENT 'Official certificate or registration number assigned by the issuing authority. Used for regulatory verification and audit trail. Serves as the externally-known business identifier for this certification.',
    `certification_name` STRING COMMENT 'Human-readable name or title of the certification program as designated by the issuing authority (e.g., CLIA Certificate of Compliance – Hematology, CAP Proficiency Testing – Chemistry). Serves as the identity label for this certification record.',
    `certification_notes` STRING COMMENT 'Free-text field for additional remarks, conditions, limitations, or special requirements associated with this certification (e.g., Limited to in-house testing only, Conditional approval pending equipment validation).',
    `certification_scope` STRING COMMENT 'Detailed description of the specific test competencies, analyte categories, methodologies, or regulatory compliance programs covered by this certification (e.g., Hematology, Coagulation, Clinical Chemistry, GLP compliance for in vitro toxicology',
    `certification_status` STRING COMMENT 'Current lifecycle status of the certification. ACTIVE = valid and in force; EXPIRED = past expiry date without renewal; SUSPENDED = temporarily halted by issuing authority; REVOKED = permanently cancelled; PENDING_RENEWAL = renewal application submitted. Valid values are `ACTIVE|EXPIRED|SUSPENDED|REVOKED|PENDING_RENEWAL|WITHDRAWN`',
    `certification_type` STRING COMMENT 'Classification of the certification program. GLP = Good Laboratory Practice; GCP_LAB_QUALIFICATION = laboratory qualification under Good Clinical Practice; CAP_PROFICIENCY = College of American Pathologists proficiency testing; CLIA_SPECIALTY = Clinical',
    `eqa_participation_cycle` STRING COMMENT 'Identifier for the specific EQA participation cycle or survey period (e.g., 2024-Q1, 2024-CYCLE-2). Applicable when certification_type = EQA_SCHEME. Supports tracking of periodic proficiency testing compliance.',
    `eqa_scheme_name` STRING COMMENT 'Name of the External Quality Assurance scheme in which the laboratory participates under this certification (e.g., UKNEQAS, RIQAS, EQAS, CAP PT). Applicable only when certification_type = EQA_SCHEME.',
    `expiry_date` DATE COMMENT 'Date on which the certification expires and is no longer valid unless renewed. Null for certifications with indefinite validity. Critical for renewal workflow triggering and regulatory compliance monitoring.',
    `glp_compliance_flag` BOOLEAN COMMENT 'Indicates whether this certification specifically confers or requires Good Laboratory Practice (GLP) compliance as defined by FDA 21 CFR Part 58 or OECD GLP Principles. True = GLP-compliant certification; False = non-GLP certification.',
    `is_primary_certification` BOOLEAN COMMENT 'Indicates whether this is the primary or principal certification for the laboratorys participation in clinical trials. True = primary certification; False = supplementary or specialty certification. Supports lab qualification assessments.',
    `issue_date` DATE COMMENT 'Date on which the certification was formally issued or granted by the issuing authority. Represents the effective start date of the certifications validity period.',
    `issuing_authority` STRING COMMENT 'Name of the regulatory body, accreditation organization, or competent authority that issued the certification (e.g., CMS/CLIA, College of American Pathologists, FDA, EMA, MHRA, COFRAC, DAKKS, UKAS, INAB).',
    `issuing_authority_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the jurisdiction under which the certification was issued (e.g., USA, GBR, DEU, JPN, AUS). Supports multi-jurisdictional regulatory compliance tracking.. Valid values are `^[A-Z]{3}$`',
    `lab_director_name` STRING COMMENT 'Full name of the laboratory director or responsible person named on the certification at the time of issuance. Required for regulatory submissions and GCP/GLP compliance documentation.',
    `mutual_recognition_flag` BOOLEAN COMMENT 'Indicates whether this certification is recognized under a mutual recognition agreement between regulatory authorities (e.g., FDA-EMA, OECD GLP MAD). True = recognized under MRA; False = jurisdiction-specific only.',
    `notification_lead_days` BIGINT COMMENT 'Number of calendar days before the expiry date at which automated renewal notifications should be triggered. Configurable per certification type and issuing authority requirements (e.g., 90 days for CLIA, 180 days for GLP).',
    `previous_certificate_number` STRING COMMENT 'Certificate number of the immediately preceding certification record that this record renews or supersedes. Enables chain-of-custody traceability across certification renewal cycles.',
    `proficiency_test_result` STRING COMMENT 'Outcome of the most recent proficiency testing or EQA survey associated with this certification. SATISFACTORY = passed; UNSATISFACTORY = failed one or more analytes; UNSUCCESSFUL = failed to meet minimum passing threshold; PENDING = results not yet. Valid values are `SATISFACTORY|UNSATISFACTORY|UNSUCCESSFUL|PENDING|NOT_APPLICABLE`',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this certification record was first created in the data platform. Supports audit trail and data lineage requirements per 21 CFR Part 11 and ALCOA+ principles.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this certification record in the data platform. Supports change tracking, audit trail, and data currency monitoring per 21 CFR Part 11 and ALCOA+ principles.',
    `regulatory_submission_reference` STRING COMMENT 'Reference number or dossier identifier for any regulatory submission (IND, NDA, BLA, MAA, CTD/eCTD) in which this laboratory certification was included as supporting documentation.',
    `reinstatement_date` DATE COMMENT 'Date on which a previously suspended certification was reinstated by the issuing authority following successful corrective action. Null if the certification has never been suspended or has not yet been reinstated.',
    `renewal_due_date` DATE COMMENT 'Target date by which the renewal application must be submitted to the issuing authority to maintain uninterrupted certification status. Typically calculated as a fixed lead time before the expiry date per issuing authority requirements.',
    `renewal_status` STRING COMMENT 'Current status of the certification renewal process. Tracks the renewal workflow from initiation through approval or rejection. NOT_REQUIRED applies to certifications that do not have a periodic renewal cycle.. Valid values are `NOT_STARTED|IN_PROGRESS|SUBMITTED|APPROVED|REJECTED|NOT_REQUIRED`',
    `renewal_submitted_date` DATE COMMENT 'Actual date on which the renewal application was submitted to the issuing authority. Used to confirm timely submission and support audit trail requirements.',
    `signatory_name` STRING COMMENT 'Name of the authorized signatory from the issuing authority who signed or approved the certificate. Supports audit trail and certificate authenticity verification.',
    `source_system_record_code` STRING COMMENT 'Native record identifier from the originating operational system (MasterControl, Veeva Vault, CTMS). Enables traceability back to the source system for reconciliation and audit purposes per ALCOA+ principles.',
    `specialty_code` STRING COMMENT 'Standardized code identifying the laboratory specialty or discipline covered by this certification, aligned with CLIA specialty categories or equivalent regulatory classification (e.g., HEMATOLOGY, CHEMISTRY, MICROBIOLOGY, IMMUNOLOGY, TOXICOLOGY',
    `suspension_date` DATE COMMENT 'Date on which the certification was suspended, revoked, or withdrawn. Populated only when certification_status is SUSPENDED, REVOKED, or WITHDRAWN. Supports regulatory compliance and audit trail.',
    `suspension_reason` STRING COMMENT 'Reason provided by the issuing authority or the laboratory for suspension, revocation, or withdrawal of the certification. Populated only when certification_status is SUSPENDED, REVOKED, or WITHDRAWN.',
    CONSTRAINT pk_lab_certification PRIMARY KEY(`lab_certification_id`)
) COMMENT 'Reference master for laboratory regulatory certifications and qualifications required for clinical trial participation. Captures certification type (GLP, GCP lab qualification, CAP proficiency, CLIA specialty, EQA scheme participation), issuing authority';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` (
    `lab_analyte_id` BIGINT COMMENT 'Unique surrogate identifier for a laboratory analyte record in the enterprise reference master. Primary key for the lab_analyte entity. [_canonical_skip_reason: Role classified as MASTER_RESOURCE — a controlled vocabulary reference entity representing a',
    `lab_panel_id` BIGINT COMMENT 'add column lab_panel_id (BIGINT) with FK to laboratory.lab_panel.lab_panel_id — analytes belong to panels',
    `meddra_term_id` BIGINT COMMENT 'Foreign key linking to terminology.meddra_term. Business justification: Lab analytes are mapped to MedDRA preferred terms for AE coding when lab abnormalities are reported as adverse events.',
    `adam_param_code` STRING COMMENT 'ADaM parameter code; implements ADaM PARAMCD. Valid values are `^[A-Z0-9_]{1,8}$`',
    `adam_param_label` STRING COMMENT 'ADaM parameter label; implements ADaM PARAM',
    `analyte_category` STRING COMMENT 'High-level classification of the analyte by laboratory discipline or scientific domain. Corresponds to CDISC LBCAT variable. [ENUM-REF-CANDIDATE',
    `analyte_code` STRING COMMENT 'Internal enterprise-assigned short code uniquely identifying the analyte within the controlled vocabulary. Used as the primary business key for cross-system referencing and data integration.. Valid values are `^[A-Z0-9_]{1,8}$`',
    `analyte_name` STRING COMMENT 'Full human-readable name of the laboratory analyte (e.g., Hemoglobin, Alanine Aminotransferase, Creatinine). Serves as the display label in reports, eCRFs, and regulatory submissions. Corresponds to CDISC LBTEST label.',
    `analyte_status` STRING COMMENT 'Current lifecycle status of the analyte in the enterprise reference master. ACTIVE: approved for use in studies; INACTIVE: no longer used in new studies; DEPRECATED: superseded by another analyte code; PENDING_VALIDATION: under review for addition. Valid values are `ACTIVE|INACTIVE|DEPRECATED|PENDING_VALIDATION|RESTRICTED`',
    `analyte_subcategory` STRING COMMENT 'More granular classification within the analyte category. Corresponds to CDISC LBSCAT variable (e.g., LIVER FUNCTION, RENAL FUNCTION, LIPID PANEL, COMPLETE BLOOD COUNT within CHEMISTRY or HEMATOLOGY).',
    `analyte_type` STRING COMMENT 'Classification of the analyte result type: QUANTITATIVE (numeric value with unit), QUALITATIVE (categorical result such as Positive/Negative), SEMI_QUANTITATIVE (e.g., 1+/2+/3+), or ORDINAL (ranked scale).. Valid values are `QUANTITATIVE|QUALITATIVE|SEMI_QUANTITATIVE|ORDINAL`',
    `analyte_version` STRING COMMENT 'Version number of the analyte definition record (e.g., 1.0, 2.3). Incremented when material changes are made to the analyte specification (unit, LOINC code, CDISC mapping, reference ranges).. Valid values are `^[0-9]+.[0-9]+$`',
    `assay_method` STRING COMMENT 'The analytical method or technology platform used to measure this analyte (e.g., ELISA, LC-MS/MS, Flow Cytometry, Immunoturbidimetry, Colorimetric, PCR, Electrochemiluminescence).',
    `biomarker_flag` BOOLEAN COMMENT 'Indicates whether this analyte is classified as a biomarker (safety, efficacy, predictive, prognostic, or pharmacodynamic). Biomarker analytes require additional regulatory documentation per FDA Biomarker Qualification Program and EMA qualification',
    `biomarker_type` STRING COMMENT 'When biomarker_flag is true, classifies the biomarker by its regulatory and scientific role per FDA BEST framework: SAFETY (organ toxicity monitoring), EFFICACY (treatment response), PREDICTIVE (patient selection), PROGNOSTIC (disease outcome)',
    `collection_tube_type` STRING COMMENT 'Required blood collection tube type or container for this analyte (e.g., EDTA, SST, LITHIUM HEPARIN, CITRATE, FLUORIDE OXALATE). Drives specimen collection kit configuration in RTSM and lab manuals.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this analyte record was first created in the enterprise reference master. Supports audit trail requirements under 21 CFR Part 11, ALCOA+ data integrity principles, and GDPR data governance.',
    `critical_value_lower` DECIMAL(18,4) COMMENT 'The lower critical (panic) value threshold for this analyte below which an immediate clinical notification is required per laboratory protocol. Results below this threshold trigger critical_value_flag in lab_result and require expedited reporting to the',
    `critical_value_upper` DECIMAL(18,4) COMMENT 'The upper critical (panic) value threshold for this analyte above which an immediate clinical notification is required per laboratory protocol. Results above this threshold trigger critical_value_flag in lab_result and require expedited reporting to the',
    `ctcae_grade_mapping` STRING COMMENT 'Describes the CTCAE grading rule or reference for this analyte (e.g., CTCAE v5.0 — Anemia: Grade 1 <LLN–10.0 g/dL; Grade 2 8.0–<10.0 g/dL; Grade 3 <8.0 g/dL).',
    `ctcae_version` STRING COMMENT 'CTCAE version; implements CTCAE version metadata. Valid values are `^CTCAE v[0-9]+.[0-9]+$`',
    `default_unit` STRING COMMENT 'Default result unit; implements CDISC CT UNIT codelist',
    `detection_limit_lower` DECIMAL(18,6) COMMENT 'The lowest concentration or value that can be reliably detected by the analytical method for this analyte (Lower Limit of Detection, LLOD). Values below this threshold are reported as <LLOD.',
    `detection_limit_upper` DECIMAL(18,6) COMMENT 'The highest concentration or value that can be reliably quantified by the analytical method for this analyte (Upper Limit of Quantitation, ULOQ). Values above this threshold require dilution or are reported as >ULOQ.',
    `effective_end_date` DATE COMMENT 'The date on which this analyte definition was retired or superseded. Null indicates the analyte is currently active. Used to enforce temporal validity checks when mapping historical study data and to prevent use of deprecated analytes in new study builds.',
    `effective_start_date` DATE COMMENT 'The date from which this analyte definition became effective and approved for use in clinical trial data collection. Supports temporal versioning of the controlled vocabulary and ensures studies use the correct analyte definition at the time of data',
    `lbtest` STRING COMMENT 'Lab test name; implements SDTM LB.LBTEST (CDISC CT LBTEST codelist)',
    `lbtestcd` STRING COMMENT 'Lab test code; implements SDTM LB.LBTESTCD (CDISC CT LBTESTCD codelist). Valid values are `^[A-Z0-9_]{1,8}$`',
    `loinc_code` STRING COMMENT 'LOINC code of the analyte; implements LOINC code. Valid values are `^[0-9]{1,5}-[0-9]$`',
    `max_freeze_thaw_cycles` BIGINT COMMENT 'Maximum number of freeze-thaw cycles permitted for specimens used to measure this analyte before result validity is compromised. Enforced during specimen chain-of-custody tracking to flag specimens that have exceeded the allowable cycle count',
    `minimum_volume_ml` DECIMAL(8,3) COMMENT 'Minimum volume of specimen in milliliters required to perform the assay for this analyte. Used to validate specimen adequacy upon receipt at the central laboratory and to configure collection volume requirements in the lab manual and RTSM kit',
    `pk_pd_flag` BOOLEAN COMMENT 'Indicates whether this analyte is used in pharmacokinetic (PK) or pharmacodynamic (PD) analyses. When true, the analyte is subject to DMPK bioanalytical method validation requirements and results are processed through the PC/PP SDTM domains and',
    `preferred_volume_ml` DECIMAL(8,3) COMMENT 'Optimal/preferred volume of specimen in milliliters for reliable analyte measurement, accounting for repeat testing and QC requirements. Drives collection kit tube size selection and subject blood volume burden calculations in protocol feasibility',
    `reporting_precision` BIGINT COMMENT 'Number of decimal places to which results for this analyte should be reported and stored. Ensures consistent numeric precision across EDC data entry in Medidata Rave, SDTM dataset generation, and statistical analysis outputs in SAS Drug Development.',
    `requires_fasting` BOOLEAN COMMENT 'Indicates whether specimen collection for this analyte requires the subject to be in a fasting state. When true, the eCRF in Medidata Rave will prompt collection of fasting status (LBFAST in SDTM) and the collection instructions in the lab manual will',
    `sdtm_domain` STRING COMMENT 'Target SDTM domain; implements SDTM Dataset.DOMAIN. Valid values are `LB|PC|PP|FA|MB|MS`',
    `specimen_type` STRING COMMENT 'Primary specimen type required or accepted for this analyte (e.g., BLOOD, SERUM, PLASMA, URINE, CSF, TISSUE). Corresponds to CDISC LBSPEC variable.',
    `stability_hours_ambient` BIGINT COMMENT 'Maximum number of hours the collected specimen remains stable for this analyte at ambient (room) temperature before processing or refrigeration is required.',
    `stability_hours_frozen` BIGINT COMMENT 'Maximum number of hours (or equivalent duration) the collected specimen remains stable for this analyte when stored frozen (typically -20°C or -80°C). Governs long-term biobanking, re-analysis eligibility, and sample expiry management in the specimen',
    `stability_hours_refrigerated` BIGINT COMMENT 'Maximum number of hours the collected specimen remains stable for this analyte when stored refrigerated (2–8°C). Used to define specimen handling windows in the lab manual, RTSM kit instructions, and central lab processing SOPs.',
    `standard_unit` STRING COMMENT 'Standardized unit; implements SDTM LB.LBSTRESU (CDISC CT UNIT codelist)',
    `unit_conversion_factor` DECIMAL(18,8) COMMENT 'Numeric multiplier applied to convert a result from the default_unit to the standard_unit (e.g., 0.0555 to convert glucose from mg/dL to mmol/L). Used by the data transformation layer in SAS Drug Development and Medidata Rave to auto-standardize incoming',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this analyte record was most recently modified. Used for change detection in downstream ETL pipelines, audit trail compliance under 21 CFR Part 11, and data lineage tracking in the Databricks Silver Layer.',
    `who_dd_code` STRING COMMENT 'WHODrug dictionary code; implements WHODrug Drug Record Number',
    CONSTRAINT pk_lab_analyte PRIMARY KEY(`lab_analyte_id`)
) COMMENT 'Reference master for individual laboratory analytes (measurable substances or properties) used across all lab panels and assays. Captures analyte name, LOINC code, MedDRA PT mapping, CDISC LBTESTCD/LBTEST standardized code and label, default unit of';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`laboratory`.`lab_qualification` (
    `lab_qualification_id` BIGINT COMMENT 'Primary key for the lab_qualification association',
    `clinical_program_id` BIGINT COMMENT 'Foreign key linking to the clinical development program for which this laboratory facility is qualified.',
    `lab_facility_id` BIGINT COMMENT 'Foreign key linking to the laboratory facility being qualified for this clinical program.',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — lab qualification should reference the study context',
    `contract_reference` STRING COMMENT 'Reference identifier for the vendor contract or master service agreement governing the laboratory facilitys engagement for this clinical program. Links to the procurement or legal contract management system.',
    `primary_lab_flag` BOOLEAN COMMENT 'Indicates whether this laboratory facility is designated as the primary (central) laboratory for this clinical program. A program may have one primary lab and multiple specialty or backup labs.',
    `qualification_date` DATE COMMENT 'Date on which the laboratory facility was formally qualified to perform specimen analysis for this clinical program. Marks the start of the approved engagement for regulatory audit trail purposes.',
    `qualification_status` STRING COMMENT 'Current sponsor or CRO qualification status of the laboratory facility for this specific clinical program. Reflects the outcome of the qualification assessment and drives whether the lab may receive specimens for this program.',
    `scope_of_services` STRING COMMENT 'Narrative or structured description of the specific assay panels, specimen types, and analytical services this laboratory facility is approved to perform for this clinical program (e.g., hematology, PK assays, biomarker panels).',
    `sponsor_approval_date` DATE COMMENT 'Date on which the pharmaceutical or biotech sponsor formally approved this laboratory facility for use in this clinical program. May differ from qualification_date when sponsor review follows CRO qualification.',
    CONSTRAINT pk_lab_qualification PRIMARY KEY(`lab_qualification_id`)
) COMMENT 'This association product represents the formal qualification and engagement contract between a lab_facility and a clinical_program. It captures the sponsor-approved, program-specific qualification of a laboratory facility to perform defined specimen';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`laboratory`.`panel_composition` (
    `panel_composition_id` BIGINT COMMENT 'Primary key for the panel_composition association',
    `lab_analyte_id` BIGINT COMMENT 'Foreign key linking to the constituent analyte included in this panel composition',
    `lab_panel_id` BIGINT COMMENT 'Foreign key linking to the parent lab panel whose composition this record defines',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — panel composition should reference the study if study-specific panels exist',
    `analyte_count` BIGINT COMMENT 'Total number of individual analytes (tests) included in this panel. Provides a quick reference for panel complexity and is used in turnaround time estimation and cost modelling.',
    `analyte_list` STRING COMMENT 'Comma-separated list of analyte names or LBTESTCD codes included in this panel (e.g., ALT, AST, ALP, TBILI, DBILI, GGT). Provides a human-readable summary of panel content for protocol review and eCRF design.',
    `effective_end_date` DATE COMMENT 'The date on which this analyte was removed from this panels composition. A null value indicates the analyte is currently active in the panel. Used to reconstruct historical panel composition at any point in time for audit and regulatory purposes.',
    `effective_start_date` DATE COMMENT 'The date from which this analyte was included in this panels composition. Supports version-controlled panel composition tracking across protocol amendments. A null value indicates the analyte has been part of the panel since the panels inception.',
    `is_required_analyte` BOOLEAN COMMENT 'Indicates whether this analyte is mandatory for the panel to be considered complete and reportable. When false, the analyte is optional or conditionally performed.',
    `minimum_volume_contribution_ml` DECIMAL(18,2) COMMENT 'The minimum specimen volume in millilitres required specifically for this analytes performance within this panel. Used to calculate total panel specimen volume requirements.',
    `reporting_flag` BOOLEAN COMMENT 'Indicates whether this analytes result is included in the panels standard report output. Some analytes may be performed internally for QC or calculation purposes but not reported to the sponsor or investigator site.',
    `sequence_order` BIGINT COMMENT 'The ordered display/reporting position of this analyte within the panel. Determines the sequence in which analyte results appear on lab reports and eCRF panels. Belongs to the composition relationship, not to the analyte or panel alone.',
    CONSTRAINT pk_panel_composition PRIMARY KEY(`panel_composition_id`)
) COMMENT 'This association product represents the formal composition contract between a lab_panel and its constituent lab_analytes. It captures the version-controlled membership of each analyte within a panel as actively managed by lab directors and protocol teams.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`laboratory`.`sow_lab_panel_requirement` (
    `sow_lab_panel_requirement_id` BIGINT COMMENT 'Primary key for the sow_lab_panel_requirement association',
    `lab_panel_id` BIGINT COMMENT 'Foreign key linking to the laboratory test panel catalog entry that is contractually included in this SOW',
    `scope_of_work_id` BIGINT COMMENT 'Foreign key linking to the Scope of Work document under which this lab panel is contracted',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — SOW lab panel requirement should reference the study',
    `central_lab_required_flag` BOOLEAN COMMENT 'Indicates whether this SOW mandates that this panel be performed at a central laboratory. Overrides or confirms the lab_type attribute on the panel catalog for the purposes of this specific contractual engagement.',
    `contracted_turnaround_days` DECIMAL(18,2) COMMENT 'Negotiated turnaround time in days from specimen receipt to result delivery, as agreed in this specific SOW. May differ from the catalog turnaround_time_hours on lab_panel, which represents a general SLA target.',
    `panel_requirement_type` STRING COMMENT 'Classification of why this lab panel is included in the SOW — e.g., safety monitoring, pharmacokinetics, biomarker assessment. The same panel may serve different purposes in different SOWs.',
    `specimen_volume_contracted_ml` DECIMAL(18,2) COMMENT 'Contracted specimen volume in millilitres agreed for this panel under this SOW. May differ from the catalog minimum (specimen_volume_ml on lab_panel) due to sponsor-specific protocol requirements or pooling arrangements.',
    `unit_price` DECIMAL(18,2) COMMENT 'Per-panel unit price negotiated between the sponsor and CRO under this SOW. Pricing is specific to the SOW-panel combination and is not a property of the panel catalog or the SOW header.',
    `visit_applicability` STRING COMMENT 'Specification of which study visit timepoints (e.g., Screening, Day 1, Week 4, End of Treatment) require this panel under this SOW. Encoded as a pipe-separated list of visit codes or a free-text schedule description.',
    CONSTRAINT pk_sow_lab_panel_requirement PRIMARY KEY(`sow_lab_panel_requirement_id`)
) COMMENT 'This association product represents the Contract between scope_of_work and lab_panel in clinical research operations. It captures the formal contractual inclusion of a specific laboratory test panel within a Scope of Work, recording the negotiated terms';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`laboratory`.`lab_service_contract` (
    `lab_service_contract_id` BIGINT COMMENT 'Primary key for the lab_service_contract association',
    `lab_facility_id` BIGINT COMMENT 'Foreign key linking to the laboratory facility engaged under this service contract.',
    `study_budget_id` BIGINT COMMENT 'Foreign key linking to the study budget under which this lab facility is contracted.',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — lab service contract should reference the study it supports',
    `amendment_number` BIGINT COMMENT 'Sequential integer tracking the number of amendments applied to this lab service contract record. Incremented each time contracted_rate, service_scope, or terms are formally revised. Supports audit trail for SOX-compliant budget change management.',
    `contract_status` STRING COMMENT 'Current lifecycle state of this lab service contract record. Drives workflow approvals and determines whether the facility is authorized to invoice against this study budget.',
    `contracted_rate` DECIMAL(18,2) COMMENT 'The negotiated unit rate agreed with the lab facility for specimen processing services under this specific study budget. Varies per facility-study combination and cannot reside on either the facility master or the budget master alone.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the contracted_rate. May differ from the study budgets base currency when the lab facility is in a different country.',
    `effective_date` DATE COMMENT 'The date from which the contracted terms between this lab facility and this study budget become financially binding. Used for cost accrual timing and sponsor invoicing alignment.',
    `expiry_date` DATE COMMENT 'The date on which the contracted terms expire or are superseded by an amendment. Supports contract lifecycle management and budget re-forecasting.',
    `service_scope` STRING COMMENT 'Narrative or structured description of the assay panels, specimen types, and analytical services covered under this facility-budget contract. Defines what the lab is authorized and budgeted to perform for this study.',
    CONSTRAINT pk_lab_service_contract PRIMARY KEY(`lab_service_contract_id`)
) COMMENT 'This association product represents the Contract between lab_facility and study_budget. It captures the facility-specific financial and operational terms under which a laboratory facility is engaged to perform specimen analysis services for a specific';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`laboratory`.`shipment_manifest` (
    `shipment_manifest_id` BIGINT COMMENT 'Primary key for shipment_manifest',
    `consolidated_shipment_manifest_id` BIGINT COMMENT 'Self-referencing FK on shipment_manifest (consolidated_shipment_manifest_id)',
    `lab_facility_id` BIGINT COMMENT 'Identifier of the central or local laboratory associated with this shipment manifest.',
    `study_id` BIGINT COMMENT 'Identifier of the clinical study or trial associated with this shipment manifest.',
    `study_site_id` BIGINT COMMENT 'Identifier of the clinical trial site originating or receiving this shipment.',
    `actual_delivery_date` DATE COMMENT 'Confirmed date when the shipment was physically received at the destination.',
    `carrier_name` STRING COMMENT 'Name of the courier or logistics carrier responsible for transporting the shipment.',
    `chain_of_custody_intact` BOOLEAN COMMENT 'Indicates whether the chain of custody was maintained without interruption throughout the shipment lifecycle.',
    `condition_on_receipt` STRING COMMENT 'Assessment of the shipment condition upon arrival at the destination, documenting any visible damage or compromise.',
    `container_count` BIGINT COMMENT 'Total number of shipping containers (boxes, cryoshippers, coolers) in this manifest.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when the shipment manifest record was initially created in the system.',
    `customs_declaration_number` STRING COMMENT 'Customs declaration or import/export permit number required for cross-border biological specimen shipments.',
    `destination_address` STRING COMMENT 'Full street address of the shipment destination location.',
    `destination_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the shipment destination.',
    `destination_facility_name` STRING COMMENT 'Name of the receiving facility (central lab, biorepository, or analytical lab).',
    `expected_delivery_date` DATE COMMENT 'Anticipated date of arrival at the destination facility based on carrier transit time estimates.',
    `hazardous_goods_class` STRING COMMENT 'UN hazardous goods classification for the shipment contents (e.g., UN3373 Category B biological substance).',
    `import_permit_number` STRING COMMENT 'Government-issued import permit number required for biological materials entering the destination country.',
    `is_international` BOOLEAN COMMENT 'Indicates whether the shipment crosses international borders, triggering additional regulatory and customs requirements.',
    `is_temperature_excursion` BOOLEAN COMMENT 'Indicates whether a temperature excursion (deviation outside acceptable range) was detected during transit.',
    `manifest_number` STRING COMMENT 'Externally-visible business identifier for the shipment manifest, used for tracking and regulatory documentation of specimen shipments.',
    `manifest_type` STRING COMMENT 'Classification of the shipment manifest indicating the nature of contents being shipped (specimens, reagents, supplies, returns, or items for destruction).',
    `notes` STRING COMMENT 'General free-text notes or comments related to the shipment manifest for operational documentation.',
    `origin_address` STRING COMMENT 'Full street address of the shipment origin location.',
    `origin_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the shipment origin.',
    `origin_facility_name` STRING COMMENT 'Name of the facility from which the shipment originates (clinical site, lab, or depot).',
    `protocol_number` STRING COMMENT 'Clinical trial protocol number associated with the specimens in this shipment, linking to the study protocol.',
    `receipt_confirmed_timestamp` TIMESTAMP COMMENT 'Exact date and time when the shipment receipt was confirmed at the destination facility.',
    `receiver_name` STRING COMMENT 'Full name of the individual who received and acknowledged the shipment at the destination.',
    `shipment_date` DATE COMMENT 'Date when the shipment was dispatched from the origin location.',
    `shipper_name` STRING COMMENT 'Full name of the individual who prepared and dispatched the shipment, required for chain of custody.',
    `shipping_priority` STRING COMMENT 'Priority level assigned to the shipment based on specimen stability, study timelines, or regulatory deadlines.',
    `specimen_count` BIGINT COMMENT 'Total number of individual specimens or samples included in this shipment manifest.',
    `shipment_manifest_status` STRING COMMENT 'Current lifecycle status of the shipment manifest within the shipping workflow.',
    `temperature_condition` STRING COMMENT 'Required temperature storage condition for the shipment contents during transit.',
    `temperature_max_c` DECIMAL(5,2) COMMENT 'Upper bound of the acceptable temperature range in degrees Celsius during transit.',
    `temperature_min_c` DECIMAL(5,2) COMMENT 'Lower bound of the acceptable temperature range in degrees Celsius during transit.',
    `tracking_number` STRING COMMENT 'Carrier-assigned tracking number for real-time shipment monitoring and chain of custody documentation.',
    `updated_timestamp` TIMESTAMP COMMENT 'Date and time when the shipment manifest record was last modified.',
    `visit_window` STRING COMMENT 'Study visit or timepoint window associated with the specimens in this manifest (e.g., Week 4, Screening).',
    `waybill_number` STRING COMMENT 'Air waybill or bill of lading number for international shipments, required for customs clearance.',
    `weight_kg` DECIMAL(8,3) COMMENT 'Total gross weight of the shipment in kilograms, required for carrier documentation and customs.',
    CONSTRAINT pk_shipment_manifest PRIMARY KEY(`shipment_manifest_id`)
) COMMENT 'Master reference table for shipment_manifest. Referenced by manifest_id.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_vital_sign` (
    `laboratory_vital_sign_id` BIGINT COMMENT 'Primary key for laboratory_vital_sign',
    `laboratory_lab_result_id` BIGINT COMMENT 'Reference to laboratory.laboratory_lab_result.laboratory_lab_result_id.',
    `loinc_id` BIGINT COMMENT 'add column loinc_id (BIGINT) with FK to terminology.loinc.loinc_id — vital signs should reference LOINC for standardization',
    `primary_laboratory_ehr_source_system_id` BIGINT COMMENT 'foreign key to EHR source system',
    `primary_laboratory_vs_primary_code_system_version_id` BIGINT COMMENT 'Foreign key to code system version for LOINC dictionary version applied',
    `site_study_site_id` BIGINT COMMENT 'add column site_study_site_id (BIGINT) with FK to site.study_site.study_site_id — vital signs should reference the study site where they were collected',
    `source_ehr_source_system_id` BIGINT COMMENT 'laboratory.ehr_source_system.ehr_source_system_id',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — laboratory_vital_sign only links to trial_subject, missing study context',
    `study_visit_schedule_id` BIGINT COMMENT 'add column study_visit_schedule_id (BIGINT) with FK to study.study_visit_schedule.study_visit_schedule_id — vital signs should reference the visit schedule timepoint at which they were collected, aligning with the lab result pattern',
    `subject_visit_id` BIGINT COMMENT 'add column subject_visit_id (BIGINT) with FK to subject.subject_visit.subject_visit_id — vital signs should reference the subject visit at which they were collected',
    `tertiary_laboratory_loinc_code_system_version_id` BIGINT COMMENT 'LOINC dictionary version applied to this vital sign record',
    `tertiary_quaternary_laboratory_vs_code_system_version_id` BIGINT COMMENT 'Foreign key to code system version for LOINC dictionary version applied to this vital sign',
    `trial_subject_id` BIGINT COMMENT 'add column trial_subject_id (BIGINT) with FK to subject.trial_subject.trial_subject_id — vital signs should reference the trial subject they belong to',
    `fhir_resource_reference` STRING COMMENT 'FHIR resource id of the source Observation; implements FHIR Resource.id',
    `fhir_resource_type` STRING COMMENT 'FHIR resource type; implements FHIR Resource.resourceType',
    `source_fhir_resource` STRING COMMENT 'source FHIR resource reference (HL7 FHIR Observation)',
    `source_system_code` BIGINT COMMENT 'Foreign key to the source system reference that supplied this record',
    `esource_record_id` STRING COMMENT 'The esource record id of the laboratory vital sign.',
    `esource_capture_datetime` TIMESTAMP COMMENT 'The esource capture datetime of the laboratory vital sign.',
    `esource_system_name` STRING COMMENT 'The esource system name of the laboratory vital sign.',
    `esource_verified_flag` BOOLEAN COMMENT 'Indicator for esource verified flag on the laboratory vital sign.',
    CONSTRAINT pk_laboratory_vital_sign PRIMARY KEY(`laboratory_vital_sign_id`)
) COMMENT 'Vital signs captured via eSource';

ALTER SCHEMA `clinical_trials_ecm`.`laboratory` SET TAGS ('dbx_division' = 'operations');

ALTER SCHEMA `clinical_trials_ecm`.`laboratory` SET TAGS ('dbx_domain' = 'laboratory');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ADD CONSTRAINT `fk_laboratory_lab_panel_document_sop_id` FOREIGN KEY (`document_sop_id`) REFERENCES `clinical_trials_ecm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ADD CONSTRAINT `fk_laboratory_lab_panel_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` SET TAGS ('dbx_domain' = 'laboratory');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` SET TAGS ('dbx_subdomain' = 'test_definition');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `lab_panel_id` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Panel Identifier');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `document_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Document Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `adam_dataset_mapping` SET TAGS ('dbx_business_glossary_term' = 'Analysis Data Model (ADaM) Dataset Mapping');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `adam_dataset_mapping` SET TAGS ('dbx_value_regex' = '^[A-Z]{4,8}$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `assay_method` SET TAGS ('dbx_business_glossary_term' = 'Bioanalytical Assay Method');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `cdisc_lbcat_code` SET TAGS ('dbx_business_glossary_term' = 'Clinical Data Interchange Standards Consortium (CDISC) Laboratory Category (LBCAT) Code');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `cdisc_lbcat_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9 ]{1,40}$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `container_type` SET TAGS ('dbx_business_glossary_term' = 'Specimen Container Type');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `critical_value_flag` SET TAGS ('dbx_business_glossary_term' = 'Critical Value Alert Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Panel Effective End Date');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Panel Effective Start Date');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `fasting_duration_hours` SET TAGS ('dbx_business_glossary_term' = 'Required Fasting Duration Hours');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `fasting_required` SET TAGS ('dbx_business_glossary_term' = 'Fasting Required Indicator');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `is_biomarker_panel` SET TAGS ('dbx_business_glossary_term' = 'Biomarker Panel Indicator');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `is_pd_panel` SET TAGS ('dbx_business_glossary_term' = 'Pharmacodynamics (PD) Panel Indicator');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `is_pk_panel` SET TAGS ('dbx_business_glossary_term' = 'Pharmacokinetics (PK) Panel Indicator');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `is_safety_panel` SET TAGS ('dbx_business_glossary_term' = 'Safety Monitoring Panel Indicator');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `lab_certification_standard` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Certification Standard');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `lab_type` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Type');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `lab_type` SET TAGS ('dbx_value_regex' = 'central|local|both');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `method_validation_status` SET TAGS ('dbx_business_glossary_term' = 'Bioanalytical Method Validation Status');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `method_validation_status` SET TAGS ('dbx_value_regex' = 'validated|qualified|exploratory|not_required');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `panel_category` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Panel Category');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `panel_code` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Panel Code');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `panel_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{2,30}$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `panel_name` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Panel Name');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `panel_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `panel_short_name` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Panel Short Name');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `panel_short_name` SET TAGS ('dbx_value_regex' = '^[A-Za-z0-9 /()-]{1,40}$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `panel_short_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `panel_status` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Panel Status');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `panel_status` SET TAGS ('dbx_value_regex' = 'active|inactive|draft|retired|under_review');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `panel_subcategory` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Panel Subcategory');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `reference_range_source` SET TAGS ('dbx_value_regex' = 'central_lab|local_lab|sponsor_defined|literature|regulatory_guidance');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `regulatory_submission_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission Required Indicator');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_business_glossary_term' = 'Clinical Data Interchange Standards Consortium (CDISC) Study Data Tabulation Model (SDTM) Domain');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_value_regex' = 'LB|PC|PP|FA|MB|MI');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `shipping_condition` SET TAGS ('dbx_business_glossary_term' = 'Specimen Shipping Condition');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `shipping_condition` SET TAGS ('dbx_value_regex' = 'ambient|refrigerated|dry_ice|liquid_nitrogen|frozen');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `source_system_code` SET TAGS ('dbx_value_regex' = 'medidata_rave|oracle_clinical_one|ctms|manual|lims');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `specimen_volume_ml` SET TAGS ('dbx_business_glossary_term' = 'Required Specimen Volume (mL)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `stability_hours_ambient` SET TAGS ('dbx_business_glossary_term' = 'Specimen Stability Hours at Ambient Temperature');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `stability_hours_refrigerated` SET TAGS ('dbx_business_glossary_term' = 'Specimen Stability Hours Refrigerated');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `stat_turnaround_time_hours` SET TAGS ('dbx_business_glossary_term' = 'STAT (Urgent) Turnaround Time Hours');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `storage_temperature` SET TAGS ('dbx_business_glossary_term' = 'Specimen Storage Temperature Condition');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `storage_temperature` SET TAGS ('dbx_value_regex' = 'ambient|refrigerated|frozen_minus20|frozen_minus80|dry_ice|liquid_nitrogen');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `storage_temperature` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `turnaround_time_hours` SET TAGS ('dbx_business_glossary_term' = 'Turnaround Time Service Level Agreement (SLA) Hours');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Panel Definition Version Number');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^d+.d+$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_panel` ALTER COLUMN `visit_timepoints` SET TAGS ('dbx_business_glossary_term' = 'Applicable Visit Timepoints');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ADD CONSTRAINT `fk_laboratory_lab_facility_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ADD CONSTRAINT `fk_laboratory_lab_facility_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` SET TAGS ('dbx_domain' = 'laboratory');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` SET TAGS ('dbx_subdomain' = 'facility_management');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `lab_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Facility ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `address_line1` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Facility Address Line 1');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `address_line1` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `address_line1` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `address_line1` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `address_line2` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Facility Address Line 2');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `address_line2` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `address_line2` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `address_line2` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `biobanking_capable` SET TAGS ('dbx_business_glossary_term' = 'Biobanking Capability Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `cap_accreditation_number` SET TAGS ('dbx_business_glossary_term' = 'College of American Pathologists (CAP) Accreditation Number');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `city` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Facility City');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `city` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `city` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `city` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `clia_number` SET TAGS ('dbx_business_glossary_term' = 'Clinical Laboratory Improvement Amendments (CLIA) Certificate Number');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `clia_number` SET TAGS ('dbx_value_regex' = '^[0-9]{2}D[0-9]{7}$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `dmpk_analysis_capable` SET TAGS ('dbx_business_glossary_term' = 'Drug Metabolism and Pharmacokinetics (DMPK) Analysis Capability Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `edi_lab_code` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Interchange (EDI) Laboratory Code');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `facility_code` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Facility Code');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `facility_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{3,20}$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `facility_name` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Facility Name');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `facility_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `facility_type` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Facility Type');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `facility_type` SET TAGS ('dbx_value_regex' = 'central|local|bioanalytical|pk_dmpk|specialty|reference');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `flow_cytometry_capable` SET TAGS ('dbx_business_glossary_term' = 'Flow Cytometry Capability Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `gcp_certified` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Certified Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `genomics_capable` SET TAGS ('dbx_business_glossary_term' = 'Genomics Analysis Capability Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `glp_certified` SET TAGS ('dbx_business_glossary_term' = 'Good Laboratory Practice (GLP) Certified Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `iso_15189_certificate_number` SET TAGS ('dbx_business_glossary_term' = 'ISO 15189 Accreditation Certificate Number');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `lims_system_code` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Information Management System (LIMS) Identifier');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `lims_vendor` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Information Management System (LIMS) Vendor');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `medical_director_name` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Medical Director Name');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `medical_director_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `medical_director_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `medical_director_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `network_affiliation` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Network Affiliation');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `operational_status` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Facility Operational Status');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `operational_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|pending_qualification|decommissioned');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `pk_analysis_capable` SET TAGS ('dbx_business_glossary_term' = 'Pharmacokinetics (PK) Analysis Capability Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `postal_code` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Facility Postal Code');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `postal_code` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `preferred_courier` SET TAGS ('dbx_business_glossary_term' = 'Preferred Specimen Courier');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Facility Primary Contact Email');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_pii_email' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Facility Primary Contact Name');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Facility Primary Contact Phone');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_value_regex' = '^+?[0-9s-().]{7,20}$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `qualification_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Qualification Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `qualification_status` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Qualification Status');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `qualification_status` SET TAGS ('dbx_value_regex' = 'qualified|conditionally_qualified|not_qualified|qualification_expired|under_review');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `specimen_capacity_per_day` SET TAGS ('dbx_business_glossary_term' = 'Specimen Processing Capacity Per Day');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `specimen_capacity_per_day` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `state_province` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Facility State or Province');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `state_province` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `state_province` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `state_province` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `time_zone` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Facility Time Zone');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `turnaround_time_standard_hours` SET TAGS ('dbx_business_glossary_term' = 'Standard Turnaround Time (Hours)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `turnaround_time_stat_hours` SET TAGS ('dbx_business_glossary_term' = 'STAT Turnaround Time (Hours)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_facility` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ADD CONSTRAINT `fk_laboratory_specimen_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ADD CONSTRAINT `fk_laboratory_specimen_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ADD CONSTRAINT `fk_laboratory_specimen_lab_panel_id` FOREIGN KEY (`lab_panel_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_panel`(`lab_panel_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ADD CONSTRAINT `fk_laboratory_specimen_parent_specimen_id` FOREIGN KEY (`parent_specimen_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`specimen`(`specimen_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ADD CONSTRAINT `fk_laboratory_specimen_shipment_id` FOREIGN KEY (`shipment_id`) REFERENCES `clinical_trials_ecm`.`supply`.`shipment`(`shipment_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ADD CONSTRAINT `fk_laboratory_specimen_specimen_collection_id` FOREIGN KEY (`specimen_collection_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`specimen_collection`(`specimen_collection_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ADD CONSTRAINT `fk_laboratory_specimen_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ADD CONSTRAINT `fk_laboratory_specimen_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ADD CONSTRAINT `fk_laboratory_specimen_study_visit_schedule_id` FOREIGN KEY (`study_visit_schedule_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_visit_schedule`(`study_visit_schedule_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ADD CONSTRAINT `fk_laboratory_specimen_subject_visit_id` FOREIGN KEY (`subject_visit_id`) REFERENCES `clinical_trials_ecm`.`subject`.`subject_visit`(`subject_visit_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ADD CONSTRAINT `fk_laboratory_specimen_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` SET TAGS ('dbx_domain' = 'laboratory');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` SET TAGS ('dbx_subdomain' = 'sample_processing');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Collector ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `lab_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Laboratory ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `lab_panel_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Panel Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `specimen_collection_id` SET TAGS ('dbx_business_glossary_term' = 'Specimen Collection Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `study_visit_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Study Visit Schedule Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `subject_visit_id` SET TAGS ('dbx_business_glossary_term' = 'Visit ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `actual_timepoint_hours` SET TAGS ('dbx_business_glossary_term' = 'Actual Timepoint (Hours from Dose)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `barcode` SET TAGS ('dbx_business_glossary_term' = 'Specimen Barcode');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `chain_of_custody_status` SET TAGS ('dbx_value_regex' = 'intact|broken|under_investigation');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `collection_body_site` SET TAGS ('dbx_business_glossary_term' = 'Collection Body Site (Location)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `collection_datetime` SET TAGS ('dbx_business_glossary_term' = 'Collection Date and Time');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `destruction_date` SET TAGS ('dbx_business_glossary_term' = 'Specimen Destruction Date');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `disposition_status` SET TAGS ('dbx_business_glossary_term' = 'Specimen Disposition Status');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Specimen Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `fasting_status` SET TAGS ('dbx_value_regex' = 'fasted|non_fasted|unknown');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `freeze_thaw_cycles` SET TAGS ('dbx_business_glossary_term' = 'Freeze-Thaw Cycles Count');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `is_primary` SET TAGS ('dbx_business_glossary_term' = 'Primary Specimen Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `lims_accession_number` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Information Management System (LIMS) Accession Number');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `pre_analytical_processing` SET TAGS ('dbx_business_glossary_term' = 'Pre-Analytical Processing Description');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `processing_datetime` SET TAGS ('dbx_business_glossary_term' = 'Processing Date and Time');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `receipt_datetime` SET TAGS ('dbx_business_glossary_term' = 'Receipt Date and Time');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `rejection_reason` SET TAGS ('dbx_business_glossary_term' = 'Specimen Rejection Reason');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `storage_location` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `storage_temperature_c` SET TAGS ('dbx_business_glossary_term' = 'Storage Temperature (°C)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `storage_temperature_c` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `subject_number` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen` ALTER COLUMN `volume_collected_ml` SET TAGS ('dbx_business_glossary_term' = 'Volume Collected (mL)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ADD CONSTRAINT `fk_laboratory_laboratory_lab_result_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_ecm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ADD CONSTRAINT `fk_laboratory_laboratory_lab_result_critical_value_id` FOREIGN KEY (`critical_value_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`critical_value`(`critical_value_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ADD CONSTRAINT `fk_laboratory_laboratory_lab_result_ctcae_grade_id` FOREIGN KEY (`ctcae_grade_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`ctcae_grade`(`ctcae_grade_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ADD CONSTRAINT `fk_laboratory_laboratory_lab_result_epoch_id` FOREIGN KEY (`epoch_id`) REFERENCES `clinical_trials_ecm`.`study`.`epoch`(`epoch_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ADD CONSTRAINT `fk_laboratory_laboratory_lab_result_lab_analyte_id` FOREIGN KEY (`lab_analyte_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_analyte`(`lab_analyte_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ADD CONSTRAINT `fk_laboratory_laboratory_lab_result_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ADD CONSTRAINT `fk_laboratory_laboratory_lab_result_lab_panel_id` FOREIGN KEY (`lab_panel_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_panel`(`lab_panel_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ADD CONSTRAINT `fk_laboratory_laboratory_lab_result_loinc_id` FOREIGN KEY (`loinc_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`loinc`(`loinc_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ADD CONSTRAINT `fk_laboratory_laboratory_lab_result_primary_laboratory_ehr_source_system_id` FOREIGN KEY (`primary_laboratory_ehr_source_system_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`ehr_source_system`(`ehr_source_system_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ADD CONSTRAINT `fk_laboratory_laboratory_lab_result_primary_laboratory_primary_code_system_version_id` FOREIGN KEY (`primary_laboratory_primary_code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ADD CONSTRAINT `fk_laboratory_laboratory_lab_result_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ADD CONSTRAINT `fk_laboratory_laboratory_lab_result_reference_range_id` FOREIGN KEY (`reference_range_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`reference_range`(`reference_range_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ADD CONSTRAINT `fk_laboratory_laboratory_lab_result_source_ehr_source_system_id` FOREIGN KEY (`source_ehr_source_system_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`ehr_source_system`(`ehr_source_system_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ADD CONSTRAINT `fk_laboratory_laboratory_lab_result_specimen_id` FOREIGN KEY (`specimen_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`specimen`(`specimen_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ADD CONSTRAINT `fk_laboratory_laboratory_lab_result_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ADD CONSTRAINT `fk_laboratory_laboratory_lab_result_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ADD CONSTRAINT `fk_laboratory_laboratory_lab_result_study_visit_schedule_id` FOREIGN KEY (`study_visit_schedule_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_visit_schedule`(`study_visit_schedule_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ADD CONSTRAINT `fk_laboratory_laboratory_lab_result_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ADD CONSTRAINT `fk_laboratory_laboratory_lab_result_subject_visit_id` FOREIGN KEY (`subject_visit_id`) REFERENCES `clinical_trials_ecm`.`subject`.`subject_visit`(`subject_visit_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ADD CONSTRAINT `fk_laboratory_laboratory_lab_result_tertiary_laboratory_lab_code_system_version_id` FOREIGN KEY (`tertiary_laboratory_lab_code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ADD CONSTRAINT `fk_laboratory_laboratory_lab_result_tertiary_quaternary_laboratory_loinc_code_system_version_id` FOREIGN KEY (`tertiary_quaternary_laboratory_loinc_code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ADD CONSTRAINT `fk_laboratory_laboratory_lab_result_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` SET TAGS ('dbx_domain' = 'laboratory');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` SET TAGS ('dbx_subdomain' = 'result_reporting');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `laboratory_lab_result_id` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Result ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `arm_id` SET TAGS ('dbx_business_glossary_term' = 'Study Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `critical_value_id` SET TAGS ('dbx_business_glossary_term' = 'Critical Value Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `ctcae_grade_id` SET TAGS ('dbx_business_glossary_term' = 'Ctcae Grade Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `ctcae_grade_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `ctcae_grade_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `epoch_id` SET TAGS ('dbx_business_glossary_term' = 'Study Epoch Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `lab_analyte_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Analyte Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `lab_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Reporting Laboratory ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `lab_panel_id` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Panel ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `loinc_id` SET TAGS ('dbx_dictionary_fk' = 'preserved');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `loinc_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `loinc_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `reference_range_id` SET TAGS ('dbx_business_glossary_term' = 'Reference Range Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `study_visit_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Study Visit Schedule Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `subject_randomization_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Randomization Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `subject_visit_id` SET TAGS ('dbx_business_glossary_term' = 'Visit ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `collection_datetime` SET TAGS ('dbx_business_glossary_term' = 'Specimen Collection Date and Time (LBDTC)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `data_origin` SET TAGS ('dbx_business_glossary_term' = 'Data Origin Source');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `data_origin` SET TAGS ('dbx_value_regex' = 'EDC|LAB_DIRECT|MANUAL|MIGRATION|BIOANALYTICAL');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `dbl_included_flag` SET TAGS ('dbx_business_glossary_term' = 'Database Lock (DBL) Included Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `fasting_status` SET TAGS ('dbx_business_glossary_term' = 'Fasting Status (LBFAST)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `fasting_status` SET TAGS ('dbx_value_regex' = 'FASTING|NON-FASTING|UNKNOWN');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `lbcat` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Test Category (LBCAT)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `lbcat` SET TAGS ('dbx_value_regex' = 'HEMATOLOGY|CHEMISTRY|URINALYSIS|COAGULATION|IMMUNOLOGY|OTHER');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `lbscat` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Test Subcategory (LBSCAT)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `method` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Test Method (LBMETHOD)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `normal_range_lower` SET TAGS ('dbx_business_glossary_term' = 'Normal Range Lower Bound (LBSTNRLO)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `normal_range_upper` SET TAGS ('dbx_business_glossary_term' = 'Normal Range Upper Bound (LBSTNRHI)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `out_of_range_flag` SET TAGS ('dbx_business_glossary_term' = 'Out-of-Range Flag (LBNRIND)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `query_open_flag` SET TAGS ('dbx_business_glossary_term' = 'Data Query Open Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `result_comment` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Result Comment');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `result_received_datetime` SET TAGS ('dbx_business_glossary_term' = 'Result Received Date and Time');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `result_reported_datetime` SET TAGS ('dbx_business_glossary_term' = 'Result Reported Date and Time');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `result_seq_num` SET TAGS ('dbx_business_glossary_term' = 'Result Sequence Number');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `result_standard_unit` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Result Standard Unit (LBSTRESU)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `result_status` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Result Status');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `result_status` SET TAGS ('dbx_value_regex' = 'PRELIMINARY|FINAL|CORRECTED|CANCELLED|AMENDED');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `result_unit` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Result Original Unit (LBORRESU)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `result_value` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Result Value (LBORRES)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `result_value_numeric` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Result Numeric Value (LBSTRESN)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `sdv_status` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Status');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `sdv_status` SET TAGS ('dbx_value_regex' = 'NOT REQUIRED|PENDING|VERIFIED|DISCREPANT');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `study_day` SET TAGS ('dbx_business_glossary_term' = 'Study Day (LBDY)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `usubjid` SET TAGS ('dbx_business_glossary_term' = 'Unique Subject Identifier (USUBJID)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `usubjid` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `usubjid` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `usubjid` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `esource_record_id` SET TAGS ('dbx_content_type' = 'eSource');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `esource_record_id` SET TAGS ('dbx_source_domain' = 'laboratory');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `esource_capture_datetime` SET TAGS ('dbx_content_type' = 'eSource');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `esource_capture_datetime` SET TAGS ('dbx_source_domain' = 'laboratory');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `esource_system_name` SET TAGS ('dbx_content_type' = 'eSource');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `esource_system_name` SET TAGS ('dbx_source_domain' = 'laboratory');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `esource_verified_flag` SET TAGS ('dbx_content_type' = 'eSource');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result` ALTER COLUMN `esource_verified_flag` SET TAGS ('dbx_source_domain' = 'laboratory');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ADD CONSTRAINT `fk_laboratory_specimen_collection_adverse_event_id` FOREIGN KEY (`adverse_event_id`) REFERENCES `clinical_trials_ecm`.`safety`.`adverse_event`(`adverse_event_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ADD CONSTRAINT `fk_laboratory_specimen_collection_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_ecm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ADD CONSTRAINT `fk_laboratory_specimen_collection_consent_icf_version_id` FOREIGN KEY (`consent_icf_version_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_icf_version`(`consent_icf_version_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ADD CONSTRAINT `fk_laboratory_specimen_collection_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ADD CONSTRAINT `fk_laboratory_specimen_collection_ecrf_form_id` FOREIGN KEY (`ecrf_form_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`ecrf_form`(`ecrf_form_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ADD CONSTRAINT `fk_laboratory_specimen_collection_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ADD CONSTRAINT `fk_laboratory_specimen_collection_lab_kit_id` FOREIGN KEY (`lab_kit_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_kit`(`lab_kit_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ADD CONSTRAINT `fk_laboratory_specimen_collection_lab_panel_id` FOREIGN KEY (`lab_panel_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_panel`(`lab_panel_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ADD CONSTRAINT `fk_laboratory_specimen_collection_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ADD CONSTRAINT `fk_laboratory_specimen_collection_protocol_lab_schedule_id` FOREIGN KEY (`protocol_lab_schedule_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule`(`protocol_lab_schedule_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ADD CONSTRAINT `fk_laboratory_specimen_collection_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ADD CONSTRAINT `fk_laboratory_specimen_collection_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ADD CONSTRAINT `fk_laboratory_specimen_collection_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ADD CONSTRAINT `fk_laboratory_specimen_collection_study_visit_schedule_id` FOREIGN KEY (`study_visit_schedule_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_visit_schedule`(`study_visit_schedule_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ADD CONSTRAINT `fk_laboratory_specimen_collection_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ADD CONSTRAINT `fk_laboratory_specimen_collection_subject_visit_id` FOREIGN KEY (`subject_visit_id`) REFERENCES `clinical_trials_ecm`.`subject`.`subject_visit`(`subject_visit_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ADD CONSTRAINT `fk_laboratory_specimen_collection_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` SET TAGS ('dbx_domain' = 'laboratory');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` SET TAGS ('dbx_subdomain' = 'sample_processing');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `adverse_event_id` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `arm_id` SET TAGS ('dbx_business_glossary_term' = 'Study Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `consent_icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Consent Icf Version Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Consent Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `ecrf_form_id` SET TAGS ('dbx_business_glossary_term' = 'Electronic Case Report Form (eCRF) Form ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Collector (CRC / Phlebotomist) ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `lab_kit_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Kit Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `lab_panel_id` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Panel ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `protocol_lab_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Lab Schedule Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Study Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `study_visit_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Study Visit Schedule Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `subject_randomization_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Randomization Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `subject_visit_id` SET TAGS ('dbx_business_glossary_term' = 'Visit ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `barcode` SET TAGS ('dbx_business_glossary_term' = 'Specimen Barcode');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `collection_method` SET TAGS ('dbx_business_glossary_term' = 'Specimen Collection Method');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `collection_number` SET TAGS ('dbx_business_glossary_term' = 'Specimen Collection Number');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `collection_site_anatomy` SET TAGS ('dbx_business_glossary_term' = 'Anatomical Collection Site');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `collection_status` SET TAGS ('dbx_business_glossary_term' = 'Specimen Collection Status');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `collection_status` SET TAGS ('dbx_value_regex' = 'scheduled|collected|missed|cancelled|partial|failed');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `collection_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Specimen Collection Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `collector_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `collector_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `collector_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `deviation_description` SET TAGS ('dbx_business_glossary_term' = 'Collection Deviation Description');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `deviation_type` SET TAGS ('dbx_business_glossary_term' = 'Collection Deviation Type');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `fasting_status` SET TAGS ('dbx_business_glossary_term' = 'Subject Fasting Status');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `fasting_status` SET TAGS ('dbx_value_regex' = 'fasted|non_fasted|unknown');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `has_deviation` SET TAGS ('dbx_business_glossary_term' = 'Collection Deviation Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `hemolysis_grade` SET TAGS ('dbx_value_regex' = 'none|mild|moderate|severe');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `is_unscheduled` SET TAGS ('dbx_business_glossary_term' = 'Unscheduled Collection Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `lipemia_grade` SET TAGS ('dbx_value_regex' = 'none|mild|moderate|severe');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `nominal_time_point` SET TAGS ('dbx_business_glossary_term' = 'Nominal PK Time Point');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `processing_completed_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Pre-Analytical Processing Completed Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `recollection_required` SET TAGS ('dbx_business_glossary_term' = 'Recollection Required Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `sample_adequacy` SET TAGS ('dbx_business_glossary_term' = 'Sample Adequacy Assessment');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `sample_adequacy` SET TAGS ('dbx_value_regex' = 'adequate|inadequate|borderline');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `scheduled_collection_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Scheduled Specimen Collection Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `storage_temperature_c` SET TAGS ('dbx_business_glossary_term' = 'Storage Temperature (°C)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `storage_temperature_c` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `time_from_dose_hours` SET TAGS ('dbx_business_glossary_term' = 'Time from Dose (Hours)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `tube_count` SET TAGS ('dbx_business_glossary_term' = 'Tube / Container Count');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `volume_collected_ml` SET TAGS ('dbx_business_glossary_term' = 'Volume Collected (mL)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `volume_unit` SET TAGS ('dbx_business_glossary_term' = 'Volume Unit of Measure');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_collection` ALTER COLUMN `volume_unit` SET TAGS ('dbx_value_regex' = 'mL|uL|g|mg');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ADD CONSTRAINT `fk_laboratory_specimen_shipment_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ADD CONSTRAINT `fk_laboratory_specimen_shipment_service_level_agreement_id` FOREIGN KEY (`service_level_agreement_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`service_level_agreement`(`service_level_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ADD CONSTRAINT `fk_laboratory_specimen_shipment_shipment_manifest_id` FOREIGN KEY (`shipment_manifest_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`shipment_manifest`(`shipment_manifest_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ADD CONSTRAINT `fk_laboratory_specimen_shipment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ADD CONSTRAINT `fk_laboratory_specimen_shipment_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` SET TAGS ('dbx_domain' = 'laboratory');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` SET TAGS ('dbx_subdomain' = 'sample_processing');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ALTER COLUMN `lab_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Facility ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ALTER COLUMN `service_level_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Site ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ALTER COLUMN `actual_receipt_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Receipt Date and Time');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ALTER COLUMN `airbill_number` SET TAGS ('dbx_business_glossary_term' = 'Airbill / Waybill Number');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ALTER COLUMN `collection_date` SET TAGS ('dbx_business_glossary_term' = 'Specimen Collection Date');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Shipment Comments');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ALTER COLUMN `courier_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ALTER COLUMN `courier_service_level` SET TAGS ('dbx_value_regex' = 'overnight|two_day|ground|international_priority|same_day');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ALTER COLUMN `destination_lab_code` SET TAGS ('dbx_business_glossary_term' = 'Destination Laboratory Code');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ALTER COLUMN `dry_ice_weight_kg` SET TAGS ('dbx_business_glossary_term' = 'Dry Ice Weight (Kilograms)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ALTER COLUMN `excursion_duration_minutes` SET TAGS ('dbx_business_glossary_term' = 'Temperature Excursion Duration (Minutes)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ALTER COLUMN `excursion_max_temp_c` SET TAGS ('dbx_business_glossary_term' = 'Excursion Maximum Recorded Temperature (Celsius)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ALTER COLUMN `excursion_min_temp_c` SET TAGS ('dbx_business_glossary_term' = 'Excursion Minimum Recorded Temperature (Celsius)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ALTER COLUMN `lab_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Contact Name');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ALTER COLUMN `lab_contact_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ALTER COLUMN `lab_contact_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ALTER COLUMN `lab_contact_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ALTER COLUMN `packaging_type` SET TAGS ('dbx_value_regex' = 'triple_pack|insulated_box|cryogenic_shipper|ambient_box|validated_shipper');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ALTER COLUMN `protocol_visit_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ALTER COLUMN `rejection_reason` SET TAGS ('dbx_business_glossary_term' = 'Shipment Rejection Reason');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ALTER COLUMN `shipment_date` SET TAGS ('dbx_business_glossary_term' = 'Shipment Dispatch Date and Time');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ALTER COLUMN `shipment_status` SET TAGS ('dbx_value_regex' = 'pending|in_transit|delivered|received|rejected|cancelled');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ALTER COLUMN `shipment_type` SET TAGS ('dbx_value_regex' = 'routine|urgent|pk_sample|biomarker|backup|reshipment');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ALTER COLUMN `temperature_condition` SET TAGS ('dbx_value_regex' = 'ambient|refrigerated|frozen|dry_ice|liquid_nitrogen');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ALTER COLUMN `temperature_max_c` SET TAGS ('dbx_business_glossary_term' = 'Maximum Required Temperature (Celsius)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ALTER COLUMN `temperature_min_c` SET TAGS ('dbx_business_glossary_term' = 'Minimum Required Temperature (Celsius)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ALTER COLUMN `temperature_monitor_code` SET TAGS ('dbx_business_glossary_term' = 'Temperature Monitor Device ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ALTER COLUMN `temperature_monitor_type` SET TAGS ('dbx_value_regex' = 'data_logger|indicator_card|none');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ALTER COLUMN `tracking_number` SET TAGS ('dbx_business_glossary_term' = 'Courier Tracking Number');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ALTER COLUMN `un_number` SET TAGS ('dbx_business_glossary_term' = 'UN Dangerous Goods Number');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ALTER COLUMN `un_number` SET TAGS ('dbx_value_regex' = '^UN[0-9]{4}$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_shipment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ADD CONSTRAINT `fk_laboratory_reference_range_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ADD CONSTRAINT `fk_laboratory_reference_range_lab_analyte_id` FOREIGN KEY (`lab_analyte_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_analyte`(`lab_analyte_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ADD CONSTRAINT `fk_laboratory_reference_range_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ADD CONSTRAINT `fk_laboratory_reference_range_lab_panel_id` FOREIGN KEY (`lab_panel_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_panel`(`lab_panel_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ADD CONSTRAINT `fk_laboratory_reference_range_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ADD CONSTRAINT `fk_laboratory_reference_range_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ADD CONSTRAINT `fk_laboratory_reference_range_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ADD CONSTRAINT `fk_laboratory_reference_range_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ADD CONSTRAINT `fk_laboratory_reference_range_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` SET TAGS ('dbx_domain' = 'laboratory');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` SET TAGS ('dbx_subdomain' = 'test_definition');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `lab_analyte_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Analyte Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `lab_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Facility ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `lab_panel_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Panel Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Org Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `sap_id` SET TAGS ('dbx_business_glossary_term' = 'Sap Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `age_max` SET TAGS ('dbx_business_glossary_term' = 'Maximum Age (Years)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `age_max` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `age_max` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `age_min` SET TAGS ('dbx_business_glossary_term' = 'Minimum Age (Years)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `age_min` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `age_min` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `age_unit` SET TAGS ('dbx_value_regex' = 'years|months|weeks|days');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `age_unit` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `age_unit` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'draft|pending_review|approved|superseded|retired');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `approved_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approval Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `change_reason` SET TAGS ('dbx_business_glossary_term' = 'Reference Range Change Reason');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `change_reason_detail` SET TAGS ('dbx_business_glossary_term' = 'Reference Range Change Reason Detail');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `critical_high` SET TAGS ('dbx_business_glossary_term' = 'Critical High Value');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `critical_low` SET TAGS ('dbx_business_glossary_term' = 'Critical Low Value');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `ctcae_grade1_upper` SET TAGS ('dbx_business_glossary_term' = 'Common Terminology Criteria for Adverse Events (CTCAE) Grade 1 Upper Threshold');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `ctcae_grade2_upper` SET TAGS ('dbx_business_glossary_term' = 'Common Terminology Criteria for Adverse Events (CTCAE) Grade 2 Upper Threshold');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `ctcae_grade3_upper` SET TAGS ('dbx_business_glossary_term' = 'Common Terminology Criteria for Adverse Events (CTCAE) Grade 3 Upper Threshold');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `ctcae_grade4_upper` SET TAGS ('dbx_business_glossary_term' = 'Common Terminology Criteria for Adverse Events (CTCAE) Grade 4 Upper Threshold');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `ctcae_version` SET TAGS ('dbx_business_glossary_term' = 'Common Terminology Criteria for Adverse Events (CTCAE) Version');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `ethnicity_applicability` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `ethnicity_applicability` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `ethnicity_applicability` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `instrument_code` SET TAGS ('dbx_business_glossary_term' = 'Instrument ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `is_current_version` SET TAGS ('dbx_business_glossary_term' = 'Is Current Version Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `is_sponsor_defined` SET TAGS ('dbx_business_glossary_term' = 'Is Sponsor-Defined Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `lab_accreditation_standard` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Accreditation Standard');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `lab_accreditation_standard` SET TAGS ('dbx_value_regex' = 'CAP|CLIA|ISO_15189|UKAS|DAkkS|other');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `loinc_code` SET TAGS ('dbx_business_glossary_term' = 'Logical Observation Identifiers Names and Codes (LOINC) Code');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `loinc_code` SET TAGS ('dbx_value_regex' = '^[0-9]{1,5}-[0-9]$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `lower_limit` SET TAGS ('dbx_business_glossary_term' = 'Lower Normal Limit');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `method_code` SET TAGS ('dbx_business_glossary_term' = 'Analytical Method Code');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `prior_lower_limit` SET TAGS ('dbx_business_glossary_term' = 'Prior Lower Normal Limit');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `prior_upper_limit` SET TAGS ('dbx_business_glossary_term' = 'Prior Upper Normal Limit');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `range_source` SET TAGS ('dbx_business_glossary_term' = 'Reference Range Source');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `range_source` SET TAGS ('dbx_value_regex' = 'sponsor_defined|lab_standard|regulatory_guideline|published_literature');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `reagent_lot_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `sex_applicability` SET TAGS ('dbx_value_regex' = 'M|F|BOTH|UNKNOWN');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `sex_applicability` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `sex_applicability` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`reference_range` ALTER COLUMN `upper_limit` SET TAGS ('dbx_business_glossary_term' = 'Upper Normal Limit');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ADD CONSTRAINT `fk_laboratory_critical_value_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ADD CONSTRAINT `fk_laboratory_critical_value_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ADD CONSTRAINT `fk_laboratory_critical_value_ctcae_grade_id` FOREIGN KEY (`ctcae_grade_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`ctcae_grade`(`ctcae_grade_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ADD CONSTRAINT `fk_laboratory_critical_value_lab_analyte_id` FOREIGN KEY (`lab_analyte_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_analyte`(`lab_analyte_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ADD CONSTRAINT `fk_laboratory_critical_value_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ADD CONSTRAINT `fk_laboratory_critical_value_meddra_term_id` FOREIGN KEY (`meddra_term_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`meddra_term`(`meddra_term_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ADD CONSTRAINT `fk_laboratory_critical_value_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ADD CONSTRAINT `fk_laboratory_critical_value_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ADD CONSTRAINT `fk_laboratory_critical_value_superseded_by_critical_value_id` FOREIGN KEY (`superseded_by_critical_value_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`critical_value`(`critical_value_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` SET TAGS ('dbx_domain' = 'laboratory');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` SET TAGS ('dbx_subdomain' = 'test_definition');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `ctcae_grade_id` SET TAGS ('dbx_business_glossary_term' = 'Ctcae Grade Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `ctcae_grade_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `ctcae_grade_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `lab_analyte_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Analyte Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `lab_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Facility ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `meddra_term_id` SET TAGS ('dbx_business_glossary_term' = 'Meddra Term Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `meddra_term_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `meddra_term_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Org Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `ae_reporting_required` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event (AE) Reporting Required Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `age_group_applicability` SET TAGS ('dbx_value_regex' = 'all|pediatric|adult|geriatric');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `age_group_applicability` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `age_group_applicability` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `argus_safety_rule_code` SET TAGS ('dbx_business_glossary_term' = 'Oracle Argus Safety Rule ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `critical_high` SET TAGS ('dbx_business_glossary_term' = 'Critical High Threshold');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `critical_low` SET TAGS ('dbx_business_glossary_term' = 'Critical Low Threshold');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `edc_alert_rule_code` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) Alert Rule ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `escalation_tier_2_minutes` SET TAGS ('dbx_business_glossary_term' = 'Escalation Tier 2 Timeout Minutes');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `fasting_state_required` SET TAGS ('dbx_business_glossary_term' = 'Fasting State Required Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `lab_facility_scope` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Facility Scope');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `lab_facility_scope` SET TAGS ('dbx_value_regex' = 'all|central_lab|local_lab|specific_facility');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `loinc_code` SET TAGS ('dbx_business_glossary_term' = 'Logical Observation Identifiers Names and Codes (LOINC) Code');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `loinc_code` SET TAGS ('dbx_value_regex' = '^[0-9]{1,5}-[0-9]$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `notification_sla_minutes` SET TAGS ('dbx_business_glossary_term' = 'Notification Service Level Agreement (SLA) Minutes');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `requires_repeat_confirmation` SET TAGS ('dbx_business_glossary_term' = 'Requires Repeat Confirmation Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `sex_applicability` SET TAGS ('dbx_value_regex' = 'all|male|female');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `sex_applicability` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `sex_applicability` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `test_system_code` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Test System Code');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `threshold_status` SET TAGS ('dbx_value_regex' = 'active|inactive|superseded|under_review');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `threshold_type` SET TAGS ('dbx_value_regex' = 'absolute|delta|percent_change');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`critical_value` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ADD CONSTRAINT `fk_laboratory_pk_sample_adverse_event_id` FOREIGN KEY (`adverse_event_id`) REFERENCES `clinical_trials_ecm`.`safety`.`adverse_event`(`adverse_event_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ADD CONSTRAINT `fk_laboratory_pk_sample_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_ecm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ADD CONSTRAINT `fk_laboratory_pk_sample_bioanalytical_assay_id` FOREIGN KEY (`bioanalytical_assay_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay`(`bioanalytical_assay_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ADD CONSTRAINT `fk_laboratory_pk_sample_collector_employee_id` FOREIGN KEY (`collector_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ADD CONSTRAINT `fk_laboratory_pk_sample_epoch_id` FOREIGN KEY (`epoch_id`) REFERENCES `clinical_trials_ecm`.`study`.`epoch`(`epoch_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ADD CONSTRAINT `fk_laboratory_pk_sample_manufacture_batch_id` FOREIGN KEY (`manufacture_batch_id`) REFERENCES `clinical_trials_ecm`.`supply`.`manufacture_batch`(`manufacture_batch_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ADD CONSTRAINT `fk_laboratory_pk_sample_pk_sampling_schedule_id` FOREIGN KEY (`pk_sampling_schedule_id`) REFERENCES `clinical_trials_ecm`.`study`.`pk_sampling_schedule`(`pk_sampling_schedule_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ADD CONSTRAINT `fk_laboratory_pk_sample_shipment_id` FOREIGN KEY (`shipment_id`) REFERENCES `clinical_trials_ecm`.`supply`.`shipment`(`shipment_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ADD CONSTRAINT `fk_laboratory_pk_sample_specimen_id` FOREIGN KEY (`specimen_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`specimen`(`specimen_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ADD CONSTRAINT `fk_laboratory_pk_sample_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ADD CONSTRAINT `fk_laboratory_pk_sample_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ADD CONSTRAINT `fk_laboratory_pk_sample_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ADD CONSTRAINT `fk_laboratory_pk_sample_subject_visit_id` FOREIGN KEY (`subject_visit_id`) REFERENCES `clinical_trials_ecm`.`subject`.`subject_visit`(`subject_visit_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ADD CONSTRAINT `fk_laboratory_pk_sample_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` SET TAGS ('dbx_domain' = 'laboratory');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` SET TAGS ('dbx_subdomain' = 'sample_processing');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `pk_sample_id` SET TAGS ('dbx_business_glossary_term' = 'Pharmacokinetic (PK) Sample ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `adverse_event_id` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `arm_id` SET TAGS ('dbx_business_glossary_term' = 'Study Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `bioanalytical_assay_id` SET TAGS ('dbx_business_glossary_term' = 'Drug Metabolism and Pharmacokinetics (DMPK) Assay ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `collector_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Collector Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `collector_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `collector_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `epoch_id` SET TAGS ('dbx_business_glossary_term' = 'Study Epoch Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `manufacture_batch_id` SET TAGS ('dbx_business_glossary_term' = 'Manufacture Batch Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `shipment_id` SET TAGS ('dbx_business_glossary_term' = 'Sample Shipment ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `specimen_id` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Sample ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `subject_randomization_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Randomization Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `subject_visit_id` SET TAGS ('dbx_business_glossary_term' = 'Visit ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `actual_time_post_dose_hours` SET TAGS ('dbx_business_glossary_term' = 'Actual Time Post-Dose (Hours)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `analyte_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `collection_method` SET TAGS ('dbx_business_glossary_term' = 'Sample Collection Method');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `collection_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Actual Sample Collection Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `container_type` SET TAGS ('dbx_business_glossary_term' = 'Sample Container Type');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `dose_administration_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Reference Dose Administration Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `edc_form_reference` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) Form Reference');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `exclusion_reason` SET TAGS ('dbx_business_glossary_term' = 'PK Sample Exclusion Reason');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `freeze_thaw_cycles` SET TAGS ('dbx_business_glossary_term' = 'Freeze-Thaw Cycle Count');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `lab_receipt_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Receipt Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `nominal_time_hours` SET TAGS ('dbx_business_glossary_term' = 'Nominal Time Post-Dose (Hours)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `pre_dose_flag` SET TAGS ('dbx_business_glossary_term' = 'Pre-Dose Sample Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `processing_status` SET TAGS ('dbx_business_glossary_term' = 'Sample Processing Status');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `processing_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Sample Processing Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `sample_code` SET TAGS ('dbx_business_glossary_term' = 'PK Sample Code');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `sample_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{3,30}$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `sample_condition_on_receipt` SET TAGS ('dbx_business_glossary_term' = 'Sample Condition on Laboratory Receipt');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `sample_exclusion_flag` SET TAGS ('dbx_business_glossary_term' = 'PK Sample Exclusion Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `sample_status` SET TAGS ('dbx_business_glossary_term' = 'PK Sample Status');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `sample_type` SET TAGS ('dbx_business_glossary_term' = 'PK Sample Type');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `sample_type` SET TAGS ('dbx_value_regex' = 'plasma|serum|whole_blood|urine|csf|saliva');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `sampling_window_end_hours` SET TAGS ('dbx_business_glossary_term' = 'PK Sampling Window End (Hours)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `sampling_window_start_hours` SET TAGS ('dbx_business_glossary_term' = 'PK Sampling Window Start (Hours)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_business_glossary_term' = 'CDISC Study Data Tabulation Model (SDTM) Domain');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_value_regex' = 'PC|PP');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `storage_temperature_c` SET TAGS ('dbx_business_glossary_term' = 'Storage Temperature (°C)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `storage_temperature_c` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `subject_number` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `volume_collected_ml` SET TAGS ('dbx_business_glossary_term' = 'Volume Collected (mL)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `volume_required_ml` SET TAGS ('dbx_business_glossary_term' = 'Protocol-Required Volume (mL)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`pk_sample` ALTER COLUMN `within_sampling_window` SET TAGS ('dbx_business_glossary_term' = 'Within PK Sampling Window Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ADD CONSTRAINT `fk_laboratory_bioanalytical_assay_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ADD CONSTRAINT `fk_laboratory_bioanalytical_assay_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ADD CONSTRAINT `fk_laboratory_bioanalytical_assay_document_sop_id` FOREIGN KEY (`document_sop_id`) REFERENCES `clinical_trials_ecm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ADD CONSTRAINT `fk_laboratory_bioanalytical_assay_imp_master_id` FOREIGN KEY (`imp_master_id`) REFERENCES `clinical_trials_ecm`.`supply`.`imp_master`(`imp_master_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ADD CONSTRAINT `fk_laboratory_bioanalytical_assay_investigational_product_id` FOREIGN KEY (`investigational_product_id`) REFERENCES `clinical_trials_ecm`.`study`.`investigational_product`(`investigational_product_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ADD CONSTRAINT `fk_laboratory_bioanalytical_assay_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ADD CONSTRAINT `fk_laboratory_bioanalytical_assay_master_service_agreement_id` FOREIGN KEY (`master_service_agreement_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`master_service_agreement`(`master_service_agreement_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ADD CONSTRAINT `fk_laboratory_bioanalytical_assay_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ADD CONSTRAINT `fk_laboratory_bioanalytical_assay_pipeline_asset_id` FOREIGN KEY (`pipeline_asset_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`pipeline_asset`(`pipeline_asset_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ADD CONSTRAINT `fk_laboratory_bioanalytical_assay_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ADD CONSTRAINT `fk_laboratory_bioanalytical_assay_validation_tmf_document_id` FOREIGN KEY (`validation_tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` SET TAGS ('dbx_domain' = 'laboratory');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` SET TAGS ('dbx_subdomain' = 'test_definition');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Program Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `document_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Document Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `imp_master_id` SET TAGS ('dbx_business_glossary_term' = 'Imp Master Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `investigational_product_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `lab_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Facility Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `master_service_agreement_id` SET TAGS ('dbx_business_glossary_term' = 'Master Service Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Org Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `pipeline_asset_id` SET TAGS ('dbx_business_glossary_term' = 'Pipeline Asset Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `validation_tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Validation Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `accuracy_percent` SET TAGS ('dbx_business_glossary_term' = 'Assay Accuracy (%)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `analyte_category` SET TAGS ('dbx_value_regex' = 'Small Molecule|Large Molecule|Biomarker|Immunogenicity|Metabolite|Endogenous');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `analyte_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `assay_code` SET TAGS ('dbx_business_glossary_term' = 'Bioanalytical Assay Code');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `assay_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{3,30}$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `assay_name` SET TAGS ('dbx_business_glossary_term' = 'Bioanalytical Assay Name');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `assay_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `assay_type` SET TAGS ('dbx_business_glossary_term' = 'Bioanalytical Assay Type');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `calibration_curve_model` SET TAGS ('dbx_value_regex' = 'Linear|Quadratic|Power|Logarithmic|4PL|5PL');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `cut_point_method` SET TAGS ('dbx_business_glossary_term' = 'Immunogenicity Cut Point Method');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Assay Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `gcp_compliant` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Compliant Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `glp_compliant` SET TAGS ('dbx_business_glossary_term' = 'Good Laboratory Practice (GLP) Compliant Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `inter_run_precision_cv` SET TAGS ('dbx_business_glossary_term' = 'Inter-Run Precision Coefficient of Variation (%CV)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `intra_run_precision_cv` SET TAGS ('dbx_business_glossary_term' = 'Intra-Run Precision Coefficient of Variation (%CV)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `lloq` SET TAGS ('dbx_business_glossary_term' = 'Lower Limit of Quantification (LLOQ)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `lloq_uloq_unit` SET TAGS ('dbx_business_glossary_term' = 'LLOQ/ULOQ Concentration Unit');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `long_term_stability_days` SET TAGS ('dbx_business_glossary_term' = 'Long-Term Stability Duration (Days)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `matrix_effect_assessed` SET TAGS ('dbx_business_glossary_term' = 'Matrix Effect Assessed Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `matrix_type` SET TAGS ('dbx_business_glossary_term' = 'Biological Matrix Type');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `parallelism_assessed` SET TAGS ('dbx_business_glossary_term' = 'Parallelism Assessed Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `reference_standard_lot` SET TAGS ('dbx_business_glossary_term' = 'Reference Standard Lot Number');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `sample_volume_required_ul` SET TAGS ('dbx_business_glossary_term' = 'Required Sample Volume (µL)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `selectivity_assessed` SET TAGS ('dbx_business_glossary_term' = 'Selectivity Assessed Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `sponsor_assay_code` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Assay Identifier');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `stability_freeze_thaw_cycles` SET TAGS ('dbx_business_glossary_term' = 'Stability Freeze-Thaw Cycles Validated');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `storage_condition` SET TAGS ('dbx_business_glossary_term' = 'Sample Storage Condition');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `storage_condition` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `uloq` SET TAGS ('dbx_business_glossary_term' = 'Upper Limit of Quantification (ULOQ)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `validation_date` SET TAGS ('dbx_business_glossary_term' = 'Assay Validation Date');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `validation_status` SET TAGS ('dbx_business_glossary_term' = 'Assay Validation Status');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `validation_status` SET TAGS ('dbx_value_regex' = 'Validated|Qualified|Exploratory|In Validation|Retired');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Assay Version Number');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^vd+.d+$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay` ALTER COLUMN `weighting_factor` SET TAGS ('dbx_business_glossary_term' = 'Calibration Curve Weighting Factor');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ADD CONSTRAINT `fk_laboratory_bioanalytical_result_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_ecm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ADD CONSTRAINT `fk_laboratory_bioanalytical_result_bioanalytical_assay_id` FOREIGN KEY (`bioanalytical_assay_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay`(`bioanalytical_assay_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ADD CONSTRAINT `fk_laboratory_bioanalytical_result_blinding_config_id` FOREIGN KEY (`blinding_config_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`blinding_config`(`blinding_config_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ADD CONSTRAINT `fk_laboratory_bioanalytical_result_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ADD CONSTRAINT `fk_laboratory_bioanalytical_result_epoch_id` FOREIGN KEY (`epoch_id`) REFERENCES `clinical_trials_ecm`.`study`.`epoch`(`epoch_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ADD CONSTRAINT `fk_laboratory_bioanalytical_result_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ADD CONSTRAINT `fk_laboratory_bioanalytical_result_manufacture_batch_id` FOREIGN KEY (`manufacture_batch_id`) REFERENCES `clinical_trials_ecm`.`supply`.`manufacture_batch`(`manufacture_batch_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ADD CONSTRAINT `fk_laboratory_bioanalytical_result_pk_analysis_spec_id` FOREIGN KEY (`pk_analysis_spec_id`) REFERENCES `clinical_trials_ecm`.`biostatistics`.`pk_analysis_spec`(`pk_analysis_spec_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ADD CONSTRAINT `fk_laboratory_bioanalytical_result_pk_sample_id` FOREIGN KEY (`pk_sample_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`pk_sample`(`pk_sample_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ADD CONSTRAINT `fk_laboratory_bioanalytical_result_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ADD CONSTRAINT `fk_laboratory_bioanalytical_result_study_visit_schedule_id` FOREIGN KEY (`study_visit_schedule_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_visit_schedule`(`study_visit_schedule_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ADD CONSTRAINT `fk_laboratory_bioanalytical_result_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_ecm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ADD CONSTRAINT `fk_laboratory_bioanalytical_result_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` SET TAGS ('dbx_domain' = 'laboratory');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` SET TAGS ('dbx_subdomain' = 'result_reporting');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `arm_id` SET TAGS ('dbx_business_glossary_term' = 'Study Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `bioanalytical_assay_id` SET TAGS ('dbx_business_glossary_term' = 'Bioanalytical Assay Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `blinding_config_id` SET TAGS ('dbx_business_glossary_term' = 'Blinding Config Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Consent Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `epoch_id` SET TAGS ('dbx_business_glossary_term' = 'Study Epoch Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `lab_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Facility Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `manufacture_batch_id` SET TAGS ('dbx_business_glossary_term' = 'Manufacture Batch Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `pk_analysis_spec_id` SET TAGS ('dbx_business_glossary_term' = 'Pk Analysis Spec Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `pk_sample_id` SET TAGS ('dbx_business_glossary_term' = 'Sample ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `study_visit_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Study Visit Schedule Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `subject_randomization_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Randomization Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `assay_platform` SET TAGS ('dbx_value_regex' = 'LC-MS/MS|ELISA|ECL|PCR|FLOW_CYTOMETRY|NGS');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `assay_run_number` SET TAGS ('dbx_business_glossary_term' = 'Assay Run ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `calibration_curve_accepted` SET TAGS ('dbx_business_glossary_term' = 'Calibration Curve Acceptance Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `categorical_result` SET TAGS ('dbx_business_glossary_term' = 'Categorical Result Value');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `categorical_result` SET TAGS ('dbx_value_regex' = 'POSITIVE|NEGATIVE|INDETERMINATE|BELOW_LLOQ|ABOVE_ULOQ');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `collection_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Sample Collection Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `exclusion_flag` SET TAGS ('dbx_business_glossary_term' = 'PK/PD Analysis Exclusion Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `freeze_thaw_cycles` SET TAGS ('dbx_business_glossary_term' = 'Freeze-Thaw Cycles');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `isr_flag` SET TAGS ('dbx_business_glossary_term' = 'Incurred Sample Reanalysis (ISR) Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `isr_result` SET TAGS ('dbx_business_glossary_term' = 'Incurred Sample Reanalysis (ISR) Result');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `isr_result` SET TAGS ('dbx_value_regex' = 'PASS|FAIL|NOT_APPLICABLE');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `lloq` SET TAGS ('dbx_business_glossary_term' = 'Lower Limit of Quantification (LLOQ)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `matrix_type` SET TAGS ('dbx_business_glossary_term' = 'Biological Matrix Type');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `matrix_type` SET TAGS ('dbx_value_regex' = 'PLASMA|SERUM|WHOLE_BLOOD|URINE|CSF|TISSUE');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `numeric_result` SET TAGS ('dbx_business_glossary_term' = 'Numeric Result Value');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `qc_sample_performance` SET TAGS ('dbx_business_glossary_term' = 'Quality Control (QC) Sample Performance');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `qc_sample_performance` SET TAGS ('dbx_value_regex' = 'PASS|FAIL|MARGINAL');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `result_category` SET TAGS ('dbx_value_regex' = 'PK_CONCENTRATION|BIOMARKER|IMMUNOGENICITY|EXPLORATORY|PD_MARKER');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `result_status` SET TAGS ('dbx_value_regex' = 'REPORTABLE|NON_REPORTABLE|REPEAT_REQUIRED|PENDING|CANCELLED');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_business_glossary_term' = 'CDISC SDTM Domain');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_value_regex' = 'PC|PP|MB|IS');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `subject_number` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `subject_number` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `time_deviation_hours` SET TAGS ('dbx_business_glossary_term' = 'Time Point Deviation (Hours)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `uloq` SET TAGS ('dbx_business_glossary_term' = 'Upper Limit of Quantification (ULOQ)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`bioanalytical_result` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ADD CONSTRAINT `fk_laboratory_lab_accreditation_compliance_capa_id` FOREIGN KEY (`compliance_capa_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_capa`(`compliance_capa_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ADD CONSTRAINT `fk_laboratory_lab_accreditation_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ADD CONSTRAINT `fk_laboratory_lab_accreditation_primary_lab_facility_id` FOREIGN KEY (`primary_lab_facility_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ADD CONSTRAINT `fk_laboratory_lab_accreditation_qualifier_employee_id` FOREIGN KEY (`qualifier_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ADD CONSTRAINT `fk_laboratory_lab_accreditation_regulatory_inspection_id` FOREIGN KEY (`regulatory_inspection_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`regulatory_inspection`(`regulatory_inspection_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ADD CONSTRAINT `fk_laboratory_lab_accreditation_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ADD CONSTRAINT `fk_laboratory_lab_accreditation_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ADD CONSTRAINT `fk_laboratory_lab_accreditation_tertiary_lab_facility_id` FOREIGN KEY (`tertiary_lab_facility_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` SET TAGS ('dbx_domain' = 'laboratory');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` SET TAGS ('dbx_subdomain' = 'facility_management');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `lab_accreditation_id` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Accreditation ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `compliance_capa_id` SET TAGS ('dbx_business_glossary_term' = 'Capa Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `primary_lab_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Laboratory ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `qualifier_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Qualifier Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `qualifier_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `qualifier_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `regulatory_inspection_id` SET TAGS ('dbx_business_glossary_term' = 'Inspection Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `tertiary_lab_facility_id` SET TAGS ('dbx_internal' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `accreditation_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Accreditation Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `accreditation_scope` SET TAGS ('dbx_business_glossary_term' = 'Accreditation Scope (Test Menu)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `accreditation_status` SET TAGS ('dbx_value_regex' = 'active|expired|suspended|withdrawn|pending|revoked');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `accreditation_type` SET TAGS ('dbx_value_regex' = 'full|provisional|conditional|limited|renewal');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `certificate_number` SET TAGS ('dbx_business_glossary_term' = 'Accreditation Certificate Number');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Accreditation Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `gcp_compliant` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Compliance Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `glp_compliant` SET TAGS ('dbx_business_glossary_term' = 'Good Laboratory Practice (GLP) Compliance Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `issue_date` SET TAGS ('dbx_business_glossary_term' = 'Accreditation Issue Date');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `lab_director_name` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Director Name');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `lab_director_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `lab_director_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `lab_director_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `lab_director_qualification` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Director Qualification');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `lab_type` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Type');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `lab_type` SET TAGS ('dbx_value_regex' = 'central|local|reference|bioanalytical|specialty');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `last_inspection_date` SET TAGS ('dbx_business_glossary_term' = 'Last Regulatory Inspection Date');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `last_inspection_outcome` SET TAGS ('dbx_business_glossary_term' = 'Last Regulatory Inspection Outcome');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `last_inspection_outcome` SET TAGS ('dbx_value_regex' = 'satisfactory|minor_findings|major_findings|critical_findings|pending_review');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Accreditation Record Notes');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `previous_certificate_number` SET TAGS ('dbx_business_glossary_term' = 'Previous Accreditation Certificate Number');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `proficiency_testing_program` SET TAGS ('dbx_business_glossary_term' = 'Proficiency Testing (PT) Program Name');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `proficiency_testing_status` SET TAGS ('dbx_business_glossary_term' = 'Proficiency Testing (PT) Status');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `proficiency_testing_status` SET TAGS ('dbx_value_regex' = 'satisfactory|unsatisfactory|pending|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `qualification_assessment_date` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Qualification Assessment Date');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `qualification_assessment_outcome` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Qualification Assessment Outcome');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `qualification_assessment_outcome` SET TAGS ('dbx_value_regex' = 'qualified|conditionally_qualified|not_qualified|pending');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `regulatory_submission_eligible` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission Eligibility Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `renewal_due_date` SET TAGS ('dbx_business_glossary_term' = 'Accreditation Renewal Due Date');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `renewal_status` SET TAGS ('dbx_business_glossary_term' = 'Accreditation Renewal Status');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `renewal_status` SET TAGS ('dbx_value_regex' = 'not_started|in_progress|submitted|approved|lapsed');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `scope_includes_dmpk` SET TAGS ('dbx_business_glossary_term' = 'Scope Includes Drug Metabolism and Pharmacokinetics (DMPK)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `scope_includes_pk_pd` SET TAGS ('dbx_business_glossary_term' = 'Scope Includes Pharmacokinetics/Pharmacodynamics (PK/PD)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `sponsor_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Laboratory Approval Date');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `sponsor_approved` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Approved Laboratory Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_accreditation` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ADD CONSTRAINT `fk_laboratory_lab_kit_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ADD CONSTRAINT `fk_laboratory_lab_kit_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ADD CONSTRAINT `fk_laboratory_lab_kit_lab_panel_id` FOREIGN KEY (`lab_panel_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_panel`(`lab_panel_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ADD CONSTRAINT `fk_laboratory_lab_kit_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ADD CONSTRAINT `fk_laboratory_lab_kit_scope_of_work_id` FOREIGN KEY (`scope_of_work_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`scope_of_work`(`scope_of_work_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ADD CONSTRAINT `fk_laboratory_lab_kit_study_contract_id` FOREIGN KEY (`study_contract_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`study_contract`(`study_contract_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ADD CONSTRAINT `fk_laboratory_lab_kit_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ADD CONSTRAINT `fk_laboratory_lab_kit_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ADD CONSTRAINT `fk_laboratory_lab_kit_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` SET TAGS ('dbx_domain' = 'laboratory');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` SET TAGS ('dbx_subdomain' = 'sample_processing');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `lab_kit_id` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Kit ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approved By Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `approved_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `lab_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Facility Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `lab_panel_id` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Panel ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `scope_of_work_id` SET TAGS ('dbx_business_glossary_term' = 'Scope Of Work Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `study_contract_id` SET TAGS ('dbx_business_glossary_term' = 'Study Contract Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Study Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `approved_date` SET TAGS ('dbx_business_glossary_term' = 'Kit Approval Date');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `biohazard_classification` SET TAGS ('dbx_value_regex' = 'category_a|category_b|exempt|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `cdisc_lbspec_code` SET TAGS ('dbx_business_glossary_term' = 'CDISC Specimen Type Code (LBSPEC)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `cdisc_lbspec_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9 ]{1,40}$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `components_description` SET TAGS ('dbx_business_glossary_term' = 'Kit Components Description');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Kit Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `fasting_required` SET TAGS ('dbx_business_glossary_term' = 'Fasting Required Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `is_ancillary_kit` SET TAGS ('dbx_business_glossary_term' = 'Ancillary Kit Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `kit_label_language` SET TAGS ('dbx_value_regex' = '^[a-z]{2,3}(-[A-Z]{2})?$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `kit_label_language` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `kit_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{4,30}$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `kit_version` SET TAGS ('dbx_value_regex' = '^[A-Za-z0-9.-]{1,20}$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `lab_accreditation_standard` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Accreditation Standard');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `lab_accreditation_standard` SET TAGS ('dbx_value_regex' = 'iso_15189|cap|clia|gclp|other');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `lot_number` SET TAGS ('dbx_business_glossary_term' = 'Kit Lot Number');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `lot_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{2,30}$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `manufacture_date` SET TAGS ('dbx_business_glossary_term' = 'Kit Manufacture Date');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `requisition_form_included` SET TAGS ('dbx_business_glossary_term' = 'Requisition Form Included Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `return_kit_required` SET TAGS ('dbx_business_glossary_term' = 'Return Kit Required Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `storage_condition` SET TAGS ('dbx_business_glossary_term' = 'Kit Storage Condition');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `storage_condition` SET TAGS ('dbx_value_regex' = 'room_temperature|refrigerated|frozen|dry_ice|protect_from_light|other');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `storage_condition` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `storage_temperature_max_c` SET TAGS ('dbx_business_glossary_term' = 'Maximum Storage Temperature (Celsius)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `storage_temperature_max_c` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `storage_temperature_min_c` SET TAGS ('dbx_business_glossary_term' = 'Minimum Storage Temperature (Celsius)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `storage_temperature_min_c` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `supplier_kit_catalog_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-.]{2,40}$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `supplier_name` SET TAGS ('dbx_business_glossary_term' = 'Kit Supplier Name');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `supplier_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `tube_volume_ml` SET TAGS ('dbx_business_glossary_term' = 'Tube Volume (mL)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_kit` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ADD CONSTRAINT `fk_laboratory_lab_query_adverse_event_id` FOREIGN KEY (`adverse_event_id`) REFERENCES `clinical_trials_ecm`.`safety`.`adverse_event`(`adverse_event_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ADD CONSTRAINT `fk_laboratory_lab_query_bioanalytical_result_id` FOREIGN KEY (`bioanalytical_result_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`bioanalytical_result`(`bioanalytical_result_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ADD CONSTRAINT `fk_laboratory_lab_query_lab_analyte_id` FOREIGN KEY (`lab_analyte_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_analyte`(`lab_analyte_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ADD CONSTRAINT `fk_laboratory_lab_query_laboratory_lab_result_id` FOREIGN KEY (`laboratory_lab_result_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result`(`laboratory_lab_result_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ADD CONSTRAINT `fk_laboratory_lab_query_primary_lab_employee_id` FOREIGN KEY (`primary_lab_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ADD CONSTRAINT `fk_laboratory_lab_query_quality_event_id` FOREIGN KEY (`quality_event_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`quality_event`(`quality_event_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ADD CONSTRAINT `fk_laboratory_lab_query_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ADD CONSTRAINT `fk_laboratory_lab_query_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ADD CONSTRAINT `fk_laboratory_lab_query_subject_visit_id` FOREIGN KEY (`subject_visit_id`) REFERENCES `clinical_trials_ecm`.`subject`.`subject_visit`(`subject_visit_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ADD CONSTRAINT `fk_laboratory_lab_query_tertiary_lab_responded_by_user_employee_id` FOREIGN KEY (`tertiary_lab_responded_by_user_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ADD CONSTRAINT `fk_laboratory_lab_query_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` SET TAGS ('dbx_domain' = 'laboratory');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` SET TAGS ('dbx_subdomain' = 'result_reporting');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `lab_query_id` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Query ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `adverse_event_id` SET TAGS ('dbx_business_glossary_term' = 'Adverse Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `bioanalytical_result_id` SET TAGS ('dbx_business_glossary_term' = 'Bioanalytical Result Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `lab_analyte_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Analyte Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `laboratory_lab_result_id` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Result ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `primary_lab_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Raised By User ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `primary_lab_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `primary_lab_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `quality_event_id` SET TAGS ('dbx_business_glossary_term' = 'Quality Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `subject_visit_id` SET TAGS ('dbx_business_glossary_term' = 'Visit ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `tertiary_lab_responded_by_user_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Responded By User ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `tertiary_lab_responded_by_user_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `tertiary_lab_responded_by_user_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_business_glossary_term' = 'Query Cancellation Reason');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `corrected_value` SET TAGS ('dbx_business_glossary_term' = 'Corrected Laboratory Result Value');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `dbl_blocking_flag` SET TAGS ('dbx_business_glossary_term' = 'Database Lock (DBL) Blocking Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `ecrf_field_name` SET TAGS ('dbx_business_glossary_term' = 'Electronic Case Report Form (eCRF) Field Name');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `ecrf_field_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `ecrf_form_name` SET TAGS ('dbx_business_glossary_term' = 'Electronic Case Report Form (eCRF) Form Name');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `ecrf_form_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `edc_query_code` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) Query ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `escalation_datetime` SET TAGS ('dbx_business_glossary_term' = 'Escalation Date and Time');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `original_value` SET TAGS ('dbx_business_glossary_term' = 'Original Laboratory Result Value');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `query_category` SET TAGS ('dbx_value_regex' = 'data_management|medical_review|safety_review|statistical_review|site_initiated');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `query_priority` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `query_source_system` SET TAGS ('dbx_value_regex' = 'Medidata Rave|LIMS|Oracle Clinical One|Manual');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `query_status` SET TAGS ('dbx_value_regex' = 'open|answered|closed|cancelled');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `query_type` SET TAGS ('dbx_value_regex' = 'missing_value|implausible_result|unit_mismatch|collection_time_deviation|reference_range_deviation|transcription_error');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `raised_by_role` SET TAGS ('dbx_value_regex' = 'data_manager|medical_monitor|cra|statistician|system_auto');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `raised_datetime` SET TAGS ('dbx_business_glossary_term' = 'Query Raised Date and Time');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `resolution_action` SET TAGS ('dbx_value_regex' = 'data_corrected|data_confirmed|query_withdrawn|no_action_required');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `resolution_datetime` SET TAGS ('dbx_business_glossary_term' = 'Query Resolution Date and Time');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `response_datetime` SET TAGS ('dbx_business_glossary_term' = 'Query Response Date and Time');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `response_text` SET TAGS ('dbx_business_glossary_term' = 'Query Response Text');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `sla_breach_flag` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement (SLA) Breach Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `usubjid` SET TAGS ('dbx_business_glossary_term' = 'Unique Subject Identifier (USUBJID)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `usubjid` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `usubjid` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `usubjid` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_query` ALTER COLUMN `visit_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ADD CONSTRAINT `fk_laboratory_specimen_aliquot_bioanalytical_assay_id` FOREIGN KEY (`bioanalytical_assay_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`bioanalytical_assay`(`bioanalytical_assay_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ADD CONSTRAINT `fk_laboratory_specimen_aliquot_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_ecm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ADD CONSTRAINT `fk_laboratory_specimen_aliquot_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ADD CONSTRAINT `fk_laboratory_specimen_aliquot_parent_specimen_id` FOREIGN KEY (`parent_specimen_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`specimen`(`specimen_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ADD CONSTRAINT `fk_laboratory_specimen_aliquot_shipment_id` FOREIGN KEY (`shipment_id`) REFERENCES `clinical_trials_ecm`.`supply`.`shipment`(`shipment_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ADD CONSTRAINT `fk_laboratory_specimen_aliquot_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ADD CONSTRAINT `fk_laboratory_specimen_aliquot_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ADD CONSTRAINT `fk_laboratory_specimen_aliquot_subject_visit_id` FOREIGN KEY (`subject_visit_id`) REFERENCES `clinical_trials_ecm`.`subject`.`subject_visit`(`subject_visit_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ADD CONSTRAINT `fk_laboratory_specimen_aliquot_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` SET TAGS ('dbx_domain' = 'laboratory');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` SET TAGS ('dbx_subdomain' = 'sample_processing');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Consent Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `lab_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Laboratory ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `subject_visit_id` SET TAGS ('dbx_business_glossary_term' = 'Visit ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `aliquot_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{3,40}$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `aliquot_seq_num` SET TAGS ('dbx_business_glossary_term' = 'Aliquot Sequence Number');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `box_code` SET TAGS ('dbx_business_glossary_term' = 'Box Identifier');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `box_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{1,20}$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `collection_datetime` SET TAGS ('dbx_business_glossary_term' = 'Collection Date and Time');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Aliquot Comments');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `data_origin` SET TAGS ('dbx_business_glossary_term' = 'Data Origin System');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `data_origin` SET TAGS ('dbx_value_regex' = 'medidata_rave|oracle_clinical_one|manual_entry|lab_system|import');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `freeze_thaw_count` SET TAGS ('dbx_business_glossary_term' = 'Freeze-Thaw Cycle Count');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `max_freeze_thaw_allowed` SET TAGS ('dbx_business_glossary_term' = 'Maximum Freeze-Thaw Cycles Allowed');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `position_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{1,2}[0-9]{1,3}$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `processing_datetime` SET TAGS ('dbx_business_glossary_term' = 'Aliquot Processing Date and Time');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `protocol_num` SET TAGS ('dbx_business_glossary_term' = 'Protocol Number');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `protocol_num` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{3,30}$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `rack_code` SET TAGS ('dbx_business_glossary_term' = 'Rack Identifier');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `rack_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{1,20}$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `storage_temperature_c` SET TAGS ('dbx_business_glossary_term' = 'Storage Temperature (°C)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `storage_temperature_c` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `storage_unit_code` SET TAGS ('dbx_business_glossary_term' = 'Storage Unit ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `storage_unit_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `storage_unit_type` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `usubjid` SET TAGS ('dbx_business_glossary_term' = 'Unique Subject Identifier (USUBJID)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `usubjid` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{1,50}$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `usubjid` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `usubjid` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `usubjid` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `volume_ml` SET TAGS ('dbx_business_glossary_term' = 'Aliquot Volume (mL)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `volume_unit` SET TAGS ('dbx_business_glossary_term' = 'Volume Unit of Measure');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`specimen_aliquot` ALTER COLUMN `volume_unit` SET TAGS ('dbx_value_regex' = 'mL|uL|mg|g');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ADD CONSTRAINT `fk_laboratory_protocol_lab_schedule_epoch_id` FOREIGN KEY (`epoch_id`) REFERENCES `clinical_trials_ecm`.`study`.`epoch`(`epoch_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ADD CONSTRAINT `fk_laboratory_protocol_lab_schedule_lab_panel_id` FOREIGN KEY (`lab_panel_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_panel`(`lab_panel_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ADD CONSTRAINT `fk_laboratory_protocol_lab_schedule_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ADD CONSTRAINT `fk_laboratory_protocol_lab_schedule_regulatory_protocol_amendment_id` FOREIGN KEY (`regulatory_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`regulatory_protocol_amendment`(`regulatory_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ADD CONSTRAINT `fk_laboratory_protocol_lab_schedule_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ADD CONSTRAINT `fk_laboratory_protocol_lab_schedule_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` SET TAGS ('dbx_domain' = 'laboratory');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` SET TAGS ('dbx_subdomain' = 'test_definition');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `protocol_lab_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Laboratory Schedule ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `epoch_id` SET TAGS ('dbx_business_glossary_term' = 'Study Epoch Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `lab_panel_id` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Panel ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `regulatory_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Study Protocol Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `backup_sample_required` SET TAGS ('dbx_business_glossary_term' = 'Backup Sample Required Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `central_lab_required` SET TAGS ('dbx_business_glossary_term' = 'Central Laboratory Required Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `collection_time_constraint` SET TAGS ('dbx_value_regex' = 'pre_dose|post_dose|morning_only|timed_serial|any_time|within_window');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `collection_time_offset_hours` SET TAGS ('dbx_business_glossary_term' = 'Collection Time Offset (Hours)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `collection_time_window_minutes` SET TAGS ('dbx_business_glossary_term' = 'Collection Time Window (Minutes)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `critical_result_review_required` SET TAGS ('dbx_business_glossary_term' = 'Critical Result Review Required Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `edc_form_name` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) Form Name');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `edc_form_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `fasting_duration_hours_min` SET TAGS ('dbx_business_glossary_term' = 'Minimum Fasting Duration (Hours)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `fasting_required` SET TAGS ('dbx_business_glossary_term' = 'Fasting Required Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `is_exploratory` SET TAGS ('dbx_business_glossary_term' = 'Exploratory Assessment Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `is_pd_assessment` SET TAGS ('dbx_business_glossary_term' = 'Pharmacodynamics (PD) Assessment Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `is_pk_assessment` SET TAGS ('dbx_business_glossary_term' = 'Pharmacokinetics (PK) Assessment Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `is_safety_assessment` SET TAGS ('dbx_business_glossary_term' = 'Safety Assessment Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `local_lab_allowed` SET TAGS ('dbx_business_glossary_term' = 'Local Laboratory Allowed Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `panel_requirement` SET TAGS ('dbx_business_glossary_term' = 'Panel Requirement Status');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `panel_requirement` SET TAGS ('dbx_value_regex' = 'required|optional|conditional|pk_cohort_only|subset_only');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `processing_required` SET TAGS ('dbx_business_glossary_term' = 'On-Site Processing Required Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `repeat_allowed` SET TAGS ('dbx_business_glossary_term' = 'Repeat Collection Allowed Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `result_turnaround_days` SET TAGS ('dbx_business_glossary_term' = 'Expected Result Turnaround Time (Days)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `schedule_status` SET TAGS ('dbx_value_regex' = 'draft|active|amended|superseded|retired');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_business_glossary_term' = 'Study Data Tabulation Model (SDTM) Domain');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `shipment_frequency` SET TAGS ('dbx_business_glossary_term' = 'Specimen Shipment Frequency');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `shipment_frequency` SET TAGS ('dbx_value_regex' = 'immediate|daily|weekly|per_visit|batch');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `source_system_record_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `specimen_volume_ml` SET TAGS ('dbx_business_glossary_term' = 'Required Specimen Volume (mL)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `storage_temperature` SET TAGS ('dbx_business_glossary_term' = 'Specimen Storage Temperature');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `storage_temperature` SET TAGS ('dbx_value_regex' = 'ambient|refrigerated|frozen_minus20|frozen_minus80|liquid_nitrogen');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `storage_temperature` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `study_day_target` SET TAGS ('dbx_business_glossary_term' = 'Target Study Day');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `subject_population` SET TAGS ('dbx_business_glossary_term' = 'Applicable Subject Population');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `subject_population` SET TAGS ('dbx_value_regex' = 'all_subjects|pk_cohort|subset|sentinel_cohort|expansion_cohort');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `visit_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `visit_num` SET TAGS ('dbx_business_glossary_term' = 'Visit Number');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `visit_window_day_max` SET TAGS ('dbx_business_glossary_term' = 'Visit Window Maximum Day');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`protocol_lab_schedule` ALTER COLUMN `visit_window_day_min` SET TAGS ('dbx_business_glossary_term' = 'Visit Window Minimum Day');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ADD CONSTRAINT `fk_laboratory_lab_certification_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ADD CONSTRAINT `fk_laboratory_lab_certification_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ADD CONSTRAINT `fk_laboratory_lab_certification_reviewer_employee_id` FOREIGN KEY (`reviewer_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ADD CONSTRAINT `fk_laboratory_lab_certification_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ADD CONSTRAINT `fk_laboratory_lab_certification_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_ecm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ADD CONSTRAINT `fk_laboratory_lab_certification_tmf_artifact_id` FOREIGN KEY (`tmf_artifact_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_artifact`(`tmf_artifact_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` SET TAGS ('dbx_domain' = 'laboratory');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` SET TAGS ('dbx_subdomain' = 'facility_management');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `lab_certification_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Certification Identifier');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Health Authority Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `lab_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Laboratory ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `reviewer_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Reviewer Employee Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `reviewer_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `reviewer_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `submission_id` SET TAGS ('dbx_business_glossary_term' = 'Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `tmf_artifact_id` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Artifact ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `applicable_study_phases` SET TAGS ('dbx_business_glossary_term' = 'Applicable Clinical Study Phases');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `capa_reference` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Reference');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `certification_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `certification_status` SET TAGS ('dbx_value_regex' = 'ACTIVE|EXPIRED|SUSPENDED|REVOKED|PENDING_RENEWAL|WITHDRAWN');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `eqa_participation_cycle` SET TAGS ('dbx_business_glossary_term' = 'External Quality Assurance (EQA) Participation Cycle');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `eqa_scheme_name` SET TAGS ('dbx_business_glossary_term' = 'External Quality Assurance (EQA) Scheme Name');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `eqa_scheme_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Certificate Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `glp_compliance_flag` SET TAGS ('dbx_business_glossary_term' = 'Good Laboratory Practice (GLP) Compliance Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `is_primary_certification` SET TAGS ('dbx_business_glossary_term' = 'Primary Certification Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `issue_date` SET TAGS ('dbx_business_glossary_term' = 'Certificate Issue Date');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `issuing_authority_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `lab_director_name` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Director Name');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `lab_director_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `lab_director_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `lab_director_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `mutual_recognition_flag` SET TAGS ('dbx_business_glossary_term' = 'Mutual Recognition Agreement (MRA) Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `notification_lead_days` SET TAGS ('dbx_business_glossary_term' = 'Renewal Notification Lead Days');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `proficiency_test_result` SET TAGS ('dbx_business_glossary_term' = 'Proficiency Testing Result');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `proficiency_test_result` SET TAGS ('dbx_value_regex' = 'SATISFACTORY|UNSATISFACTORY|UNSUCCESSFUL|PENDING|NOT_APPLICABLE');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `reinstatement_date` SET TAGS ('dbx_business_glossary_term' = 'Certification Reinstatement Date');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `renewal_status` SET TAGS ('dbx_business_glossary_term' = 'Renewal Workflow Status');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `renewal_status` SET TAGS ('dbx_value_regex' = 'NOT_STARTED|IN_PROGRESS|SUBMITTED|APPROVED|REJECTED|NOT_REQUIRED');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `renewal_submitted_date` SET TAGS ('dbx_business_glossary_term' = 'Renewal Submission Date');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `signatory_name` SET TAGS ('dbx_business_glossary_term' = 'Issuing Authority Signatory Name');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `signatory_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `signatory_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `signatory_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `source_system_record_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `specialty_code` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Specialty Code');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `suspension_date` SET TAGS ('dbx_business_glossary_term' = 'Suspension or Revocation Date');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_certification` ALTER COLUMN `suspension_reason` SET TAGS ('dbx_business_glossary_term' = 'Suspension or Revocation Reason');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ADD CONSTRAINT `fk_laboratory_lab_analyte_lab_panel_id` FOREIGN KEY (`lab_panel_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_panel`(`lab_panel_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ADD CONSTRAINT `fk_laboratory_lab_analyte_meddra_term_id` FOREIGN KEY (`meddra_term_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`meddra_term`(`meddra_term_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` SET TAGS ('dbx_domain' = 'laboratory');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` SET TAGS ('dbx_subdomain' = 'test_definition');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `lab_analyte_id` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Analyte ID');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `meddra_term_id` SET TAGS ('dbx_business_glossary_term' = 'Meddra Term Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `meddra_term_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `meddra_term_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `adam_param_code` SET TAGS ('dbx_business_glossary_term' = 'Analysis Data Model (ADaM) Parameter Code (PARAMCD)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `adam_param_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{1,8}$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `adam_param_label` SET TAGS ('dbx_business_glossary_term' = 'Analysis Data Model (ADaM) Parameter Label (PARAM)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `analyte_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{1,8}$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `analyte_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `analyte_status` SET TAGS ('dbx_business_glossary_term' = 'Analyte Lifecycle Status');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `analyte_status` SET TAGS ('dbx_value_regex' = 'ACTIVE|INACTIVE|DEPRECATED|PENDING_VALIDATION|RESTRICTED');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `analyte_type` SET TAGS ('dbx_business_glossary_term' = 'Analyte Result Type');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `analyte_type` SET TAGS ('dbx_value_regex' = 'QUANTITATIVE|QUALITATIVE|SEMI_QUANTITATIVE|ORDINAL');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `analyte_version` SET TAGS ('dbx_business_glossary_term' = 'Analyte Definition Version');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `analyte_version` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `assay_method` SET TAGS ('dbx_business_glossary_term' = 'Analytical Assay Method');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `biomarker_flag` SET TAGS ('dbx_business_glossary_term' = 'Biomarker Analyte Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `biomarker_type` SET TAGS ('dbx_business_glossary_term' = 'Biomarker Type Classification');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `critical_value_lower` SET TAGS ('dbx_business_glossary_term' = 'Critical Value Lower Limit');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `critical_value_upper` SET TAGS ('dbx_business_glossary_term' = 'Critical Value Upper Limit');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `ctcae_grade_mapping` SET TAGS ('dbx_business_glossary_term' = 'Common Terminology Criteria for Adverse Events (CTCAE) Grade Mapping Rule');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `ctcae_version` SET TAGS ('dbx_business_glossary_term' = 'Common Terminology Criteria for Adverse Events (CTCAE) Version');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `ctcae_version` SET TAGS ('dbx_value_regex' = '^CTCAE v[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `default_unit` SET TAGS ('dbx_business_glossary_term' = 'Default Unit of Measure');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `detection_limit_lower` SET TAGS ('dbx_business_glossary_term' = 'Lower Limit of Detection (LLOD)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `detection_limit_upper` SET TAGS ('dbx_business_glossary_term' = 'Upper Limit of Quantitation (ULOQ)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `lbtest` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Test Name (LBTEST)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `lbtestcd` SET TAGS ('dbx_business_glossary_term' = 'Laboratory Test Code (LBTESTCD)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `lbtestcd` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{1,8}$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `loinc_code` SET TAGS ('dbx_business_glossary_term' = 'Logical Observation Identifiers Names and Codes (LOINC) Code');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `loinc_code` SET TAGS ('dbx_value_regex' = '^[0-9]{1,5}-[0-9]$');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `max_freeze_thaw_cycles` SET TAGS ('dbx_business_glossary_term' = 'Maximum Freeze-Thaw Cycles Allowed');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `minimum_volume_ml` SET TAGS ('dbx_business_glossary_term' = 'Minimum Specimen Volume (mL)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `pk_pd_flag` SET TAGS ('dbx_business_glossary_term' = 'Pharmacokinetics/Pharmacodynamics (PK/PD) Analyte Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `preferred_volume_ml` SET TAGS ('dbx_business_glossary_term' = 'Preferred Specimen Volume (mL)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `reporting_precision` SET TAGS ('dbx_business_glossary_term' = 'Reporting Precision (Decimal Places)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `requires_fasting` SET TAGS ('dbx_business_glossary_term' = 'Fasting Requirement Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_business_glossary_term' = 'Study Data Tabulation Model (SDTM) Domain Assignment');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `sdtm_domain` SET TAGS ('dbx_value_regex' = 'LB|PC|PP|FA|MB|MS');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `specimen_type` SET TAGS ('dbx_business_glossary_term' = 'Specimen Type Compatibility');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `stability_hours_ambient` SET TAGS ('dbx_business_glossary_term' = 'Specimen Stability at Ambient Temperature (Hours)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `stability_hours_frozen` SET TAGS ('dbx_business_glossary_term' = 'Specimen Stability Frozen (Hours)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `stability_hours_refrigerated` SET TAGS ('dbx_business_glossary_term' = 'Specimen Stability Refrigerated (Hours)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `standard_unit` SET TAGS ('dbx_business_glossary_term' = 'Standard Unit of Measure (SI Unit)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_analyte` ALTER COLUMN `who_dd_code` SET TAGS ('dbx_business_glossary_term' = 'WHO Drug Dictionary (WHO-DD) Code');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_qualification` ADD CONSTRAINT `fk_laboratory_lab_qualification_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_qualification` ADD CONSTRAINT `fk_laboratory_lab_qualification_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_qualification` ADD CONSTRAINT `fk_laboratory_lab_qualification_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_qualification` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_qualification` SET TAGS ('dbx_domain' = 'laboratory');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_qualification` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_qualification` SET TAGS ('dbx_subdomain' = 'facility_management');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_qualification` SET TAGS ('dbx_association_edges' = 'laboratory.lab_facility,program.clinical_program');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_qualification` ALTER COLUMN `lab_qualification_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Qualification - Lab Qualification Id');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_qualification` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Qualification - Clinical Program Id');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_qualification` ALTER COLUMN `lab_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Qualification - Lab Facility Id');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`panel_composition` ADD CONSTRAINT `fk_laboratory_panel_composition_lab_analyte_id` FOREIGN KEY (`lab_analyte_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_analyte`(`lab_analyte_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`panel_composition` ADD CONSTRAINT `fk_laboratory_panel_composition_lab_panel_id` FOREIGN KEY (`lab_panel_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_panel`(`lab_panel_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`panel_composition` ADD CONSTRAINT `fk_laboratory_panel_composition_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`panel_composition` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`panel_composition` SET TAGS ('dbx_domain' = 'laboratory');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`panel_composition` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`panel_composition` SET TAGS ('dbx_subdomain' = 'test_definition');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`panel_composition` SET TAGS ('dbx_association_edges' = 'laboratory.lab_panel,laboratory.lab_analyte');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`panel_composition` ALTER COLUMN `panel_composition_id` SET TAGS ('dbx_business_glossary_term' = 'Panel Composition - Panel Composition Id');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`panel_composition` ALTER COLUMN `lab_analyte_id` SET TAGS ('dbx_business_glossary_term' = 'Panel Composition - Lab Analyte Id');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`panel_composition` ALTER COLUMN `lab_panel_id` SET TAGS ('dbx_business_glossary_term' = 'Panel Composition - Lab Panel Id');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`panel_composition` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Composition Effective End Date');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`panel_composition` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Composition Effective Start Date');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`panel_composition` ALTER COLUMN `is_required_analyte` SET TAGS ('dbx_business_glossary_term' = 'Required Analyte Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`panel_composition` ALTER COLUMN `minimum_volume_contribution_ml` SET TAGS ('dbx_business_glossary_term' = 'Analyte Minimum Volume Contribution (mL)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`panel_composition` ALTER COLUMN `reporting_flag` SET TAGS ('dbx_business_glossary_term' = 'Analyte Reporting Flag');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`panel_composition` ALTER COLUMN `sequence_order` SET TAGS ('dbx_business_glossary_term' = 'Analyte Sequence Order');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`sow_lab_panel_requirement` ADD CONSTRAINT `fk_laboratory_sow_lab_panel_requirement_lab_panel_id` FOREIGN KEY (`lab_panel_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_panel`(`lab_panel_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`sow_lab_panel_requirement` ADD CONSTRAINT `fk_laboratory_sow_lab_panel_requirement_scope_of_work_id` FOREIGN KEY (`scope_of_work_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`scope_of_work`(`scope_of_work_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`sow_lab_panel_requirement` ADD CONSTRAINT `fk_laboratory_sow_lab_panel_requirement_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`sow_lab_panel_requirement` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`sow_lab_panel_requirement` SET TAGS ('dbx_domain' = 'laboratory');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`sow_lab_panel_requirement` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`sow_lab_panel_requirement` SET TAGS ('dbx_subdomain' = 'test_definition');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`sow_lab_panel_requirement` SET TAGS ('dbx_association_edges' = 'laboratory.lab_panel,agreement.scope_of_work');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`sow_lab_panel_requirement` ALTER COLUMN `sow_lab_panel_requirement_id` SET TAGS ('dbx_business_glossary_term' = 'Sow Lab Panel Requirement - Sow Lab Panel Requirement Id');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`sow_lab_panel_requirement` ALTER COLUMN `lab_panel_id` SET TAGS ('dbx_business_glossary_term' = 'Sow Lab Panel Requirement - Lab Panel Id');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`sow_lab_panel_requirement` ALTER COLUMN `scope_of_work_id` SET TAGS ('dbx_business_glossary_term' = 'Sow Lab Panel Requirement - Scope Of Work Id');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`sow_lab_panel_requirement` ALTER COLUMN `specimen_volume_contracted_ml` SET TAGS ('dbx_business_glossary_term' = 'Contracted Specimen Volume (mL)');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`sow_lab_panel_requirement` ALTER COLUMN `unit_price` SET TAGS ('dbx_financial_sensitive' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_service_contract` ADD CONSTRAINT `fk_laboratory_lab_service_contract_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_service_contract` ADD CONSTRAINT `fk_laboratory_lab_service_contract_study_budget_id` FOREIGN KEY (`study_budget_id`) REFERENCES `clinical_trials_ecm`.`finance`.`study_budget`(`study_budget_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_service_contract` ADD CONSTRAINT `fk_laboratory_lab_service_contract_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_service_contract` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_service_contract` SET TAGS ('dbx_domain' = 'laboratory');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_service_contract` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_service_contract` SET TAGS ('dbx_subdomain' = 'facility_management');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_service_contract` SET TAGS ('dbx_association_edges' = 'laboratory.lab_facility,finance.study_budget');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_service_contract` ALTER COLUMN `lab_service_contract_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Service Contract - Lab Service Contract Id');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_service_contract` ALTER COLUMN `lab_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Service Contract - Lab Facility Id');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_service_contract` ALTER COLUMN `study_budget_id` SET TAGS ('dbx_business_glossary_term' = 'Lab Service Contract - Study Budget Id');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_service_contract` ALTER COLUMN `amendment_number` SET TAGS ('dbx_business_glossary_term' = 'Contract Amendment Number');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_service_contract` ALTER COLUMN `contracted_rate` SET TAGS ('dbx_business_glossary_term' = 'Contracted Lab Rate');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_service_contract` ALTER COLUMN `contracted_rate` SET TAGS ('dbx_financial_sensitive' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_service_contract` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Contract Currency');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_service_contract` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Contract Effective Date');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_service_contract` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Contract Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`lab_service_contract` ALTER COLUMN `service_scope` SET TAGS ('dbx_business_glossary_term' = 'Lab Service Scope');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`shipment_manifest` ADD CONSTRAINT `fk_laboratory_shipment_manifest_consolidated_shipment_manifest_id` FOREIGN KEY (`consolidated_shipment_manifest_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`shipment_manifest`(`shipment_manifest_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`shipment_manifest` ADD CONSTRAINT `fk_laboratory_shipment_manifest_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`shipment_manifest` ADD CONSTRAINT `fk_laboratory_shipment_manifest_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`shipment_manifest` ADD CONSTRAINT `fk_laboratory_shipment_manifest_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`shipment_manifest` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`shipment_manifest` SET TAGS ('dbx_domain' = 'laboratory');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`shipment_manifest` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`shipment_manifest` SET TAGS ('dbx_subdomain' = 'sample_processing');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`shipment_manifest` ALTER COLUMN `shipment_manifest_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment Manifest Identifier');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`shipment_manifest` ALTER COLUMN `consolidated_shipment_manifest_id` SET TAGS ('dbx_self_ref_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`shipment_manifest` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site Id');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`shipment_manifest` ALTER COLUMN `carrier_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`shipment_manifest` ALTER COLUMN `destination_address` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`shipment_manifest` ALTER COLUMN `destination_address` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`shipment_manifest` ALTER COLUMN `destination_address` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`shipment_manifest` ALTER COLUMN `destination_facility_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`shipment_manifest` ALTER COLUMN `origin_address` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`shipment_manifest` ALTER COLUMN `origin_address` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`shipment_manifest` ALTER COLUMN `origin_address` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`shipment_manifest` ALTER COLUMN `origin_facility_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`shipment_manifest` ALTER COLUMN `receiver_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`shipment_manifest` ALTER COLUMN `receiver_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`shipment_manifest` ALTER COLUMN `receiver_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`shipment_manifest` ALTER COLUMN `shipper_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`shipment_manifest` ALTER COLUMN `shipper_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`shipment_manifest` ALTER COLUMN `shipper_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`shipment_manifest` ALTER COLUMN `shipment_manifest_status` SET TAGS ('dbx_business_glossary_term' = 'Status');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_vital_sign` ADD CONSTRAINT `fk_laboratory_laboratory_vital_sign_laboratory_lab_result_id` FOREIGN KEY (`laboratory_lab_result_id`) REFERENCES `clinical_trials_ecm`.`laboratory`.`laboratory_lab_result`(`laboratory_lab_result_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_vital_sign` ADD CONSTRAINT `fk_laboratory_laboratory_vital_sign_loinc_id` FOREIGN KEY (`loinc_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`loinc`(`loinc_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_vital_sign` ADD CONSTRAINT `fk_laboratory_laboratory_vital_sign_primary_laboratory_ehr_source_system_id` FOREIGN KEY (`primary_laboratory_ehr_source_system_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`ehr_source_system`(`ehr_source_system_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_vital_sign` ADD CONSTRAINT `fk_laboratory_laboratory_vital_sign_primary_laboratory_vs_primary_code_system_version_id` FOREIGN KEY (`primary_laboratory_vs_primary_code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_vital_sign` ADD CONSTRAINT `fk_laboratory_laboratory_vital_sign_site_study_site_id` FOREIGN KEY (`site_study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_vital_sign` ADD CONSTRAINT `fk_laboratory_laboratory_vital_sign_source_ehr_source_system_id` FOREIGN KEY (`source_ehr_source_system_id`) REFERENCES `clinical_trials_ecm`.`datamanagement`.`ehr_source_system`(`ehr_source_system_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_vital_sign` ADD CONSTRAINT `fk_laboratory_laboratory_vital_sign_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_vital_sign` ADD CONSTRAINT `fk_laboratory_laboratory_vital_sign_study_visit_schedule_id` FOREIGN KEY (`study_visit_schedule_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_visit_schedule`(`study_visit_schedule_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_vital_sign` ADD CONSTRAINT `fk_laboratory_laboratory_vital_sign_subject_visit_id` FOREIGN KEY (`subject_visit_id`) REFERENCES `clinical_trials_ecm`.`subject`.`subject_visit`(`subject_visit_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_vital_sign` ADD CONSTRAINT `fk_laboratory_laboratory_vital_sign_tertiary_laboratory_loinc_code_system_version_id` FOREIGN KEY (`tertiary_laboratory_loinc_code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_vital_sign` ADD CONSTRAINT `fk_laboratory_laboratory_vital_sign_tertiary_quaternary_laboratory_vs_code_system_version_id` FOREIGN KEY (`tertiary_quaternary_laboratory_vs_code_system_version_id`) REFERENCES `clinical_trials_ecm`.`terminology`.`code_system_version`(`code_system_version_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_vital_sign` ADD CONSTRAINT `fk_laboratory_laboratory_vital_sign_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_ecm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_vital_sign` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_vital_sign` SET TAGS ('dbx_domain' = 'laboratory');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_vital_sign` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_vital_sign` SET TAGS ('dbx_subdomain' = 'result_reporting');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_vital_sign` ALTER COLUMN `laboratory_vital_sign_id` SET TAGS ('dbx_business_glossary_term' = 'laboratory_vital_sign Identifier');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_vital_sign` ALTER COLUMN `loinc_id` SET TAGS ('dbx_dictionary_fk' = 'preserved');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_vital_sign` ALTER COLUMN `loinc_id` SET TAGS ('dbx_licensed_dictionary' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_vital_sign` ALTER COLUMN `loinc_id` SET TAGS ('dbx_dictionary_preserved' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_vital_sign` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_vital_sign` ALTER COLUMN `esource_record_id` SET TAGS ('dbx_content_type' = 'eSource');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_vital_sign` ALTER COLUMN `esource_record_id` SET TAGS ('dbx_source_domain' = 'laboratory');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_vital_sign` ALTER COLUMN `esource_capture_datetime` SET TAGS ('dbx_content_type' = 'eSource');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_vital_sign` ALTER COLUMN `esource_capture_datetime` SET TAGS ('dbx_source_domain' = 'laboratory');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_vital_sign` ALTER COLUMN `esource_system_name` SET TAGS ('dbx_content_type' = 'eSource');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_vital_sign` ALTER COLUMN `esource_system_name` SET TAGS ('dbx_source_domain' = 'laboratory');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_vital_sign` ALTER COLUMN `esource_verified_flag` SET TAGS ('dbx_content_type' = 'eSource');

ALTER TABLE `clinical_trials_ecm`.`laboratory`.`laboratory_vital_sign` ALTER COLUMN `esource_verified_flag` SET TAGS ('dbx_source_domain' = 'laboratory');
