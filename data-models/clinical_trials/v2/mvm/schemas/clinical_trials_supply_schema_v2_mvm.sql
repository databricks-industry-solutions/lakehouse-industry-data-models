-- Schema for Domain: supply | Business: Clinical_Trials | Version: v2_mvm
-- Generated on: 2026-11-20 12:39:49

CREATE DATABASE IF NOT EXISTS `clinical_trials_mvm`.`supply` COMMENT 'Manages investigational medicinal product (IMP) and clinical supply chain operations. Owns drug supply planning, depot and site inventory, randomization kits, dispensing records via RTSM (Medidata Rave), expiry management, returns and destruction';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`supply`.`imp_master` (
    `imp_master_id` BIGINT COMMENT 'Unique surrogate identifier for each investigational medicinal product master record within the supply domain. Serves as the primary key for all downstream supply chain, dispensing, and accountability references.',
    `application_id` BIGINT COMMENT 'Foreign key linking to regulatory.application. Business justification: IMP master records are the physical supply representation of a sponsors pipeline asset.',
    `audit_id` BIGINT COMMENT 'Foreign key linking to compliance.audit. Business justification: IMP-specific audits (manufacturer qualification audit, comparator sourcing audit, biological product audit) are conducted against specific investigational medicinal products.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.compliance_sop. Business justification: The current approved Investigators Brochure and IMP labeling document are directly associated with each investigational product.',
    `health_authority_id` BIGINT COMMENT 'Foreign key linking to regulatory.special_designation. Business justification: Orphan drug, breakthrough therapy, and fast-track designations directly affect IMP supply strategy — expedited supply timelines, special labeling requirements, and fee waivers.',
    `ind_application_id` BIGINT COMMENT 'Foreign key linking to regulatory.ind_application. Business justification: IND/IMPD covers the investigational product — regulatory affairs and supply teams must verify IND status before manufacturing and releasing IMP.',
    `investigational_product_id` BIGINT COMMENT 'Foreign key linking to study.investigational_product. Business justification: GMP/GCP batch release and IND/IMPD regulatory submissions require traceability from supply-domain IMP master records to the protocol-registered investigational product.',
    `regulatory_binder_id` BIGINT COMMENT 'Foreign key linking to document.regulatory_binder. Business justification: IMP master records are directly associated with regulatory submissions (IND/IMPD/CTA). imp_master has ind_impd_reference as plain text.',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: IMPD/IND dossiers and GMP certificates are ICH GCP essential TMF documents directly associated with each IMP master record.',
    `active_substance_name` STRING COMMENT 'International Nonproprietary Name (INN) or chemical name of the active pharmaceutical ingredient (API) contained in the IMP. Used for regulatory submissions, pharmacovigilance coding, and WHO-DD cross-referencing.',
    `atc_code` STRING COMMENT 'WHO Anatomical Therapeutic Chemical (ATC) classification code assigned to the active substance. Used for pharmacovigilance signal detection, WHO-DD cross-referencing, and regulatory reporting.. Valid values are `^[A-Z][0-9]{2}[A-Z]{2}[0-9]{2}$`',
    `blinding_type` STRING COMMENT 'Blinding configuration applicable to this IMP within the trial design: open-label (all parties know treatment), single-blind (subject blinded), double-blind (subject and investigator blinded), or triple-blind (subject, investigator, and sponsor blinded).. Valid values are `open_label|single_blind|double_blind|triple_blind`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the IMP master record was first created in the system. Supports audit trail requirements under ALCOA+ principles, 21 CFR Part 11 electronic records compliance, and data lineage tracking in the Databricks Silver layer.',
    `destruction_method` STRING COMMENT 'Approved method for destruction of unused, expired, or returned IMP. Required for accountability reconciliation, environmental compliance, and regulatory documentation of drug disposition.. Valid values are `incineration|chemical_neutralisation|landfill|return_to_sponsor|other`',
    `discontinuation_date` DATE COMMENT 'Date on which the IMP was formally discontinued from use in clinical trials. Populated when product_status transitions to discontinued. Used for supply chain close-out, accountability reconciliation, and regulatory reporting.',
    `dispensing_unit` STRING COMMENT 'The unit of measure used for dispensing the IMP to subjects at the site level (e.g., kit, vial, tablet, capsule). Aligns with RTSM dispensing records and site accountability logs.',
    `dosage_form` STRING COMMENT 'Physical form of the IMP as administered to subjects (e.g., tablet, capsule, injection, infusion, patch, oral solution). Drives dispensing instructions, packaging requirements, and cold-chain logistics.',
    `effective_date` DATE COMMENT 'Date from which this IMP master record version is considered authoritative and approved for use in supply planning and dispensing. Supports version control and regulatory compliance for product specification changes.',
    `formulation_description` STRING COMMENT 'Narrative description of the IMP formulation including excipients, concentration, and any special formulation characteristics (e.g., modified-release, lyophilised). Sourced from sponsor-provided specifications and IMPD.',
    `gmp_certificate_number` STRING COMMENT 'Reference number of the GMP certificate issued by the relevant regulatory authority for the manufacturing site producing this IMP. Required for regulatory submissions, batch release, and inspection readiness.',
    `impd_version` STRING COMMENT 'Version identifier of the IMPD or IND module that governs the current specifications for this IMP. Ensures traceability between the product master record and the regulatory submission version in effect. Supports inspection readiness and TMF completeness.',
    `is_biological` BOOLEAN COMMENT 'Indicates whether the IMP is a biological product (e.g., monoclonal antibody, vaccine, gene therapy, cell therapy) as opposed to a small-molecule chemical entity.',
    `is_cold_chain` BOOLEAN COMMENT 'Indicates whether the IMP requires cold-chain logistics (temperature-controlled storage and transport, typically 2–8°C or below). Drives cold-chain packaging selection, qualified shipper requirements, and temperature monitoring obligations.',
    `is_controlled_substance` BOOLEAN COMMENT 'Indicates whether the IMP is classified as a controlled substance under applicable national regulations (e.g., DEA Schedule in the US, Misuse of Drugs Act in the UK).',
    `is_orphan_designated` BOOLEAN COMMENT 'Indicates whether the IMP has received orphan drug designation from FDA (ODD) or EMA (OMP), conferring special regulatory incentives and obligations. Relevant for regulatory strategy, supply planning, and sponsor reporting.',
    `manufacturer_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the country where the IMP is manufactured. Used for import/export regulatory compliance, customs documentation, and supply chain risk assessment.. Valid values are `^[A-Z]{3}$`',
    `manufacturer_name` STRING COMMENT 'Name of the GMP-certified manufacturer responsible for producing the IMP. Required for regulatory submissions (IND/IMPD), batch release documentation, and supply chain traceability.',
    `max_storage_temp_c` DECIMAL(5,2) COMMENT 'Maximum permissible storage temperature in degrees Celsius for the IMP. Used to define temperature excursion thresholds, configure temperature monitoring devices, and assess cold-chain compliance at depots and sites.',
    `min_storage_temp_c` DECIMAL(5,2) COMMENT 'Minimum permissible storage temperature in degrees Celsius for the IMP. Used to define temperature excursion thresholds, configure temperature monitoring devices, and assess cold-chain compliance at depots and sites.',
    `ndc_code` STRING COMMENT 'FDA-assigned National Drug Code (NDC) for commercially procured comparators or approved products used in the trial. Applicable for US-sourced products. Used for procurement, accountability, and regulatory reporting.. Valid values are `^[0-9]{4,5}-[0-9]{3,4}-[0-9]{1,2}$`',
    `packaging_configuration` STRING COMMENT 'Description of the IMP packaging unit configuration as used in the trial (e.g., blister pack of 28 tablets, vial 10 mL, pre-filled syringe 1 mL). Drives kit assembly, labelling design, and RTSM dispensing unit definitions.',
    `product_code` STRING COMMENT 'Sponsor-assigned alphanumeric code uniquely identifying the IMP within the sponsors product catalogue. Used as the externally-known business identifier across RTSM, EDC, and regulatory submissions. Maps to the product code field in Medidata Rave RTSM.. Valid values are `^[A-Z0-9-]{3,30}$`',
    `product_name` STRING COMMENT 'Full human-readable name of the investigational medicinal product as defined by the sponsor. May be a code name, development compound name, or commercial name for comparators. Used in labelling, supply documentation, and regulatory submissions.',
    `product_status` STRING COMMENT 'Current lifecycle status of the IMP master record within the supply domain. Active records are eligible for supply planning and dispensing. Inactive or discontinued records are retained for audit and historical accountability.. Valid values are `active|inactive|discontinued|under_review`',
    `product_type` STRING COMMENT 'Classification of the product role within the clinical trial: IMP (the investigational compound under study), comparator (active reference product), placebo (inactive control), or auxiliary medicinal product (supportive agent not under investigation).. Valid values are `IMP|comparator|placebo|auxiliary_medicinal_product`',
    `regulatory_classification` STRING COMMENT 'Regulatory filing category under which the IMP is authorised for use in the clinical trial. Determines the applicable regulatory framework, submission requirements, and oversight obligations across jurisdictions (FDA IND, EMA IMPD/CTA, etc.).',
    `retest_period_months` BIGINT COMMENT 'Period in months after which the IMP must be retested before continued use, applicable where a formal expiry date is not assigned. Relevant for bulk drug substances and certain investigational compounds.',
    `route_of_administration` STRING COMMENT 'The path by which the IMP is delivered into the body (e.g., oral, intravenous, subcutaneous, intramuscular, topical). Required for eCRF design, SDTM CM domain mapping, and regulatory labelling.',
    `rtsm_product_code` STRING COMMENT 'The product identifier as configured in the Medidata Rave RTSM system. Used to reconcile the IMP master record with RTSM kit assignments, dispensing records, and inventory transactions. Source system reference for integration and lineage.',
    `shelf_life_months` BIGINT COMMENT 'Approved shelf life of the IMP in months from the date of manufacture, as established by stability studies and documented in the IMPD/IND. Used for expiry management, resupply planning, and depot/site inventory accountability.',
    `sourcing_strategy` STRING COMMENT 'Indicates how the IMP is obtained for the clinical trial: manufactured (custom GMP production), commercially procured (purchased from market), over-the-counter, or imported.. Valid values are `manufactured|commercially_procured|over_the_counter|imported`',
    `sponsor_product_code` STRING COMMENT 'The sponsors internal product code or compound number for the IMP (e.g., development compound identifier such as ABC-123). Distinct from the CROs product_code; used for sponsor-facing reporting, cross-study portfolio analytics, and regulatory',
    `storage_condition` STRING COMMENT 'Required storage conditions for the IMP as specified in the product dossier and labelling (e.g., Store at 2–8°C, Store below 25°C, protect from light).',
    `strength_unit` STRING COMMENT 'Unit of measure for the active substance strength (e.g., mg, g, mcg, mg/mL, IU). Combined with strength_value to fully define the IMP dose strength for labelling, dispensing, and regulatory submissions.',
    `strength_value` DECIMAL(18,4) COMMENT 'Numeric quantity of the active substance per dosage unit (e.g., 10, 500, 1.5). Must be interpreted in conjunction with strength_unit. Represents the principal quantitative fact about the IMP formulation.',
    `units_per_kit` BIGINT COMMENT 'Number of individual dosage units (tablets, vials, syringes, etc.) contained in one RTSM dispensing kit. Used for supply planning, kit assembly, and accountability reconciliation in Medidata Rave RTSM.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the IMP master record. Supports change tracking, audit trail requirements under ALCOA+ and 21 CFR Part 11, and incremental data loading in the Databricks Silver layer.',
    CONSTRAINT pk_imp_master PRIMARY KEY(`imp_master_id`)
) COMMENT 'Master record for all investigational and comparator products used in clinical trials, including sponsor IMPs, active comparators, and placebos. Captures product identity, product type (IMP/comparator/placebo), formulation details, dosage form, strength';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`supply`.`kit_definition` (
    `kit_definition_id` BIGINT COMMENT 'Unique surrogate identifier for the kit definition record in the RTSM (Randomization and Trial Supply Management) system. Primary key for this entity. Role: MASTER_RESOURCE.',
    `arm_id` BIGINT COMMENT 'Foreign key linking to study.arm. Business justification: Kit definitions are arm-specific (active vs. placebo vs. comparator arm). Supply planners and RTSM configuration teams must validate kit configurations against protocol-defined arms to ensure',
    `imp_master_id` BIGINT COMMENT 'Reference to the primary investigational medicinal product (IMP) component included in this kit definition. Represents the principal drug or biologic being studied.',
    `investigational_product_id` BIGINT COMMENT 'Foreign key linking to study.investigational_product. Business justification: Kit definitions must reference the study protocols investigational product definition for regulatory label approval (IND/IMPD number, strength, formulation).',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to.',
    `treatment_arm_id` BIGINT COMMENT 'Reference to the treatment arm (e.g., active drug, placebo, comparator) that this kit definition is associated with. Drives randomization assignment logic in RTSM.',
    `approval_date` DATE COMMENT 'The date on which this kit definition was formally approved for use in manufacturing and dispensing. Required for GCP compliance and audit trail documentation.',
    `blinding_level` STRING COMMENT 'Indicates the blinding configuration applied to this kit definition. Determines whether the subject, investigator, and/or sponsor are masked to treatment assignment. Critical for maintaining trial integrity and regulatory compliance.. Valid values are `open_label|single_blind|double_blind|triple_blind`',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this kit definition record was first created in the system. Supports ALCOA+ audit trail requirements and 21 CFR Part 11 electronic records compliance.',
    `destruction_method` STRING COMMENT 'The approved method for destruction of returned or expired kits of this definition type. Required for regulatory accountability documentation and environmental compliance.. Valid values are `incineration|chemical_neutralization|landfill|return_to_sponsor|site_disposal`',
    `dispensing_quantity` BIGINT COMMENT 'The standard number of dispensing units to be issued to a subject per dispensing event for this kit definition. Used by RTSM to automate dispensing recommendations at scheduled visits.',
    `dispensing_unit` STRING COMMENT 'The unit of dispensing for this kit definition as configured in the RTSM. Defines how the kit is dispensed to subjects at site visits (e.g., per kit, per bottle, per blister pack).. Valid values are `kit|bottle|blister|vial|syringe|sachet`',
    `dosage_form` STRING COMMENT 'The pharmaceutical dosage form of the IMP contained in this kit (e.g., tablet, capsule, injection, patch, oral solution). Aligns with the IMP manufacturing specification and label text.',
    `dose_strength` DECIMAL(10,4) COMMENT 'The numeric dose strength of the IMP per unit in this kit definition (e.g., 10.0000 for a 10 mg tablet). Serves as the principal MEASUREMENT_OR_VALUE for this MASTER_RESOURCE. Must be read in conjunction with dose_strength_unit.',
    `dose_strength_unit` STRING COMMENT 'Unit of measurement for the dose strength value (e.g., mg, mcg, g, mg/mL, IU). Required to fully interpret the dose_strength field. [ENUM-REF-CANDIDATE: mg|mcg|g|mg/mL|IU|mmol|mEq|% — 8 candidates stripped; promote to reference product]',
    `effective_from_date` DATE COMMENT 'The date from which this kit definition version becomes effective and may be used for manufacturing and dispensing. Supports protocol amendment versioning of kit configurations.',
    `is_blinded` BOOLEAN COMMENT 'Indicates whether kits of this definition are blinded (True) or open-label (False). A key flag for RTSM dispensing logic and unblinding procedures.',
    `is_comparator` BOOLEAN COMMENT 'Indicates whether this kit definition contains a comparator drug (True) rather than the investigational product or placebo. Used for supply chain sourcing differentiation and regulatory reporting.',
    `is_rescue_medication` BOOLEAN COMMENT 'Indicates whether this kit definition represents a rescue medication (True) rather than the primary study treatment. Rescue medication kits follow different dispensing and accountability rules.',
    `kit_description` STRING COMMENT 'Detailed narrative description of the kit definition including its intended use, contents summary, and any special handling instructions relevant to the kit template.',
    `kit_name` STRING COMMENT 'Human-readable descriptive name for the kit definition as configured in the RTSM system (e.g., Study XYZ Arm A 10mg Tablet 28-Day Supply). Serves as the IDENTITY_LABEL for this MASTER_RESOURCE.',
    `kit_number` STRING COMMENT 'The externally-known unique alphanumeric identifier assigned to this kit definition template in the RTSM system. Used by manufacturers, depots, and sites to reference the kit configuration. Serves as the BUSINESS_IDENTIFIER for this MASTER_RESOURCE.. Valid values are `^[A-Z0-9-]{3,30}$`',
    `kit_number_range_end` BIGINT COMMENT 'The last sequential kit number in the numeric range allocated to physical kits manufactured from this kit definition. Together with kit_number_range_start, defines the total pool of physical kits that can be generated from this definition.',
    `kit_number_range_start` BIGINT COMMENT 'The first sequential kit number in the numeric range allocated to physical kits manufactured from this kit definition. Used by RTSM to assign unique kit numbers to physical instances during manufacturing.',
    `kit_status` STRING COMMENT 'Current lifecycle state of the kit definition template. Draft indicates under development; approved indicates validated and ready for manufacture; active indicates in use for dispensing; superseded indicates replaced by a newer version; retired indicates. Valid values are `draft|approved|active|superseded|retired`',
    `kit_type` STRING COMMENT 'Classification of the kit by its therapeutic content category. Distinguishes between active drug kits, placebo kits, comparator kits, combination kits, device kits, and ancillary supply kits. Serves as the CLASSIFICATION_OR_TYPE for this MASTER_RESOURCE.. Valid values are `drug|placebo|comparator|combination|device|ancillary`',
    `label_language_code` STRING COMMENT 'ISO 639-1 language code (optionally with ISO 3166-1 country subtag) for the primary language of the kit label text (e.g., en, fr, de, ja). Required for multi-country studies with country-specific labeling.. Valid values are `^[a-z]{2}(-[A-Z]{2})?$`',
    `label_text` STRING COMMENT 'The regulatory-approved label text to be printed on physical kits manufactured from this definition. Must comply with applicable labeling regulations and may include study number, kit number, storage conditions, and investigational use statement.',
    `manufacturing_site_code` STRING COMMENT 'The code identifying the manufacturing or packaging site responsible for producing physical kits from this definition. Used for supply chain traceability and GMP compliance.. Valid values are `^[A-Z0-9-]{2,20}$`',
    `max_storage_temp_c` DECIMAL(5,2) COMMENT 'Maximum acceptable storage temperature in degrees Celsius for kits of this definition. Used for cold-chain monitoring alerts and excursion detection.',
    `min_storage_temp_c` DECIMAL(5,2) COMMENT 'Minimum acceptable storage temperature in degrees Celsius for kits of this definition. Used for cold-chain monitoring alerts and excursion detection.',
    `modified_timestamp` TIMESTAMP COMMENT 'The date and time when this kit definition record was last modified. Supports ALCOA+ audit trail requirements and change tracking for regulatory inspection readiness.',
    `pack_size` BIGINT COMMENT 'The number of individual dosage units (e.g., tablets, capsules, vials) contained in one physical kit of this definition. Used for supply planning, dispensing calculations, and accountability reconciliation.',
    `pack_size_unit` STRING COMMENT 'The unit descriptor for the pack size count (e.g., tablet, capsule, vial). Clarifies what each unit in the pack_size count represents. [ENUM-REF-CANDIDATE: tablet|capsule|vial|ampoule|syringe|patch|sachet|bottle — 8 candidates stripped; promote to',
    `randomization_scheme` STRING COMMENT 'The randomization methodology applied to kits of this definition type within the RTSM. Determines how kits are allocated to subjects during enrollment and randomization events.. Valid values are `stratified|blocked|minimization|adaptive|simple`',
    `retest_period_days` BIGINT COMMENT 'Number of days from manufacture after which kits of this definition must be retested before continued use. Applicable for IMP components with defined retest periods rather than fixed expiry dates.',
    `return_required` BOOLEAN COMMENT 'Indicates whether used or unused kits of this definition must be returned to the depot or sponsor for accountability reconciliation and destruction. Drives returns logistics workflows.',
    `rtsm_kit_type_code` STRING COMMENT 'The internal kit type code as configured in the Medidata Rave RTSM system. Used for system-to-system integration and reconciliation between the RTSM and downstream data systems.. Valid values are `^[A-Z0-9_]{1,50}$`',
    `shelf_life_days` BIGINT COMMENT 'The approved shelf life duration in days for kits manufactured from this definition, measured from the date of manufacture. Used to calculate expiry dates on physical kit instances and to trigger re-supply or destruction workflows.',
    `storage_condition` STRING COMMENT 'Required storage condition for kits of this definition type. Drives cold-chain logistics planning, depot storage allocation, and site storage compliance monitoring.. Valid values are `room_temperature|refrigerated|frozen|controlled_room_temp|protect_from_light`',
    `version_number` STRING COMMENT 'Version number of this kit definition (e.g., 1.0, 2.1). Incremented when the kit definition is amended due to protocol changes, labeling updates, or manufacturing changes. Supports audit trail and regulatory traceability.. Valid values are `^d+.d+$`',
    `visit_type` STRING COMMENT 'The type of study visit at which this kit definition is intended to be dispensed (e.g., baseline, treatment, follow-up, unscheduled). Drives RTSM dispensing schedule configuration.',
    CONSTRAINT pk_kit_definition PRIMARY KEY(`kit_definition_id`)
) COMMENT 'Defines randomization kit configurations used in RTSM (Medidata Rave). Captures kit type, treatment arm association, blinding level, component IMPs, pack size, label text, kit number range, and applicable study/protocol version.';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` (
    `kit_inventory_id` BIGINT COMMENT 'Unique surrogate identifier for each kit inventory record in the Databricks Silver Layer. Primary key for this data product.',
    `arm_id` BIGINT COMMENT 'Foreign key linking to study.study_arm. Business justification: Kit inventory is allocated by treatment arm for blinded and open-label studies. Linking kit_inventory to study.study_arm enables arm-level inventory accountability reporting, supports',
    `clinical_trial_authorization_id` BIGINT COMMENT 'Foreign key linking to regulatory.clinical_trial_authorization. Business justification: Individual kit inventory items must be traceable to the CTA authorizing their dispensing at a given site/country.',
    `depot_id` BIGINT COMMENT 'Reference to the supply depot or central warehouse currently holding this kit. Null when the kit has been shipped to a site.',
    `document_sop_id` BIGINT COMMENT 'Foreign key linking to document.document_sop. Business justification: Kit inventory management, storage, and handling procedures are governed by GCP SOPs. Linking kit_inventory to document_sop enables GCP compliance audits and inspection readiness',
    `dosing_regimen_id` BIGINT COMMENT 'Foreign key linking to study.dosing_regimen. Business justification: Kit inventory allocation is driven by the dosing regimen — the number of kits needed per subject per visit depends on dose frequency and duration.',
    `enrollment_id` BIGINT COMMENT 'Foreign key linking to subject.enrollment. Business justification: Kit allocation to a subject must be traceable to the specific enrollment episode for IMP accountability.',
    `kit_definition_id` BIGINT COMMENT 'Foreign key linking to supply.kit_definition. Business justification: Each physical kit instance (kit_inventory) is manufactured according to a specific kit definition (kit_definition).',
    `manufacture_batch_id` BIGINT COMMENT 'Foreign key linking to supply.manufacture_batch. Business justification: Each physical kit instance belongs to a specific manufacturing batch (kit_inventory.batch_number is denormalized).',
    `rand_code_id` BIGINT COMMENT 'Foreign key linking to randomization.rand_code. Business justification: rand_code is the authoritative RTSM record linking kit_code to treatment_arm and randomization slot.',
    `shipment_id` BIGINT COMMENT 'Reference to the inbound or outbound shipment record associated with the most recent logistics movement of this kit.',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site currently holding or assigned to receive this kit. Used for site-level inventory tracking and accountability.',
    `subject_randomization_id` BIGINT COMMENT 'Foreign key linking to randomization.subject_randomization. Business justification: IMP accountability regulations (ICH E6 GCP) require tracing each physical kit to the randomization event that triggered its dispensing.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the enrolled subject to whom this kit has been dispensed. Null when the kit has not yet been assigned or dispensed to a subject.',
    `accountability_reconciled` BOOLEAN COMMENT 'Indicates whether this kit has been fully reconciled in the drug accountability log, confirming that dispensed, returned, and destroyed quantities are accounted for. Required for study close-out and regulatory inspection readiness.',
    `batch_number` STRING COMMENT 'The manufacturing batch or lot number of the IMP contained in this kit. Essential for batch recall management, drug accountability, and regulatory submissions. Sourced from the Certificate of Analysis (CoA).. Valid values are `^[A-Z0-9-]{3,25}$`',
    `blinding_status` STRING COMMENT 'Indicates whether the kit identity (treatment assignment) is blinded, unblinded, or open-label for this record. Critical for maintaining study integrity and controlling access to treatment assignment information.. Valid values are `blinded|unblinded|open_label`',
    `cold_chain_compliant` BOOLEAN COMMENT 'Indicates whether the kit has maintained cold-chain compliance throughout its custody chain based on temperature monitoring data. A value of False triggers a quality investigation before dispensing.',
    `cold_chain_required` BOOLEAN COMMENT 'Indicates whether this kit requires cold-chain storage and transportation (e.g., 2–8°C refrigeration or frozen conditions). Drives logistics planning, temperature monitoring requirements, and qualified packaging selection.',
    `comments` STRING COMMENT 'Free-text field for site staff or supply chain personnel to record notes about this kit, such as reasons for quarantine, partial dispensing explanations, or deviation observations. Supports ALCOA+ documentation requirements.',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the country where this kit is currently located or was last recorded. Used for import/export compliance, country-specific labeling requirements, and regional supply planning.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time at which this kit inventory record was first created in the system. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `current_location_type` STRING COMMENT 'Categorical indicator of where the kit physically resides in the supply chain at the current point in time. Used in conjunction with depot_id or site_id to determine precise location.. Valid values are `depot|site|in_transit|destroyed|subject`',
    `depot_receipt_timestamp` TIMESTAMP COMMENT 'The date and time at which the kit was received at the supply depot from the manufacturer or another depot. Initiates the depot inventory record and chain-of-custody tracking.',
    `destroyed_timestamp` TIMESTAMP COMMENT 'The date and time at which the kit was confirmed destroyed per the destruction certificate. Required for drug accountability reconciliation and regulatory close-out documentation.',
    `destruction_certificate_number` STRING COMMENT 'The reference number of the official destruction certificate issued upon confirmed destruction of the kit. Required for drug accountability close-out and regulatory submission documentation.',
    `dispensed_quantity` BIGINT COMMENT 'The actual number of dosage units dispensed to the subject from this kit. Used for drug accountability reconciliation and compliance with protocol-specified dosing.',
    `dispensed_timestamp` TIMESTAMP COMMENT 'The date and time at which this kit was physically dispensed to the subject by site staff. Captured in RTSM (Medidata Rave) as part of the chain-of-custody audit trail. Conforms to ALCOA+ contemporaneous documentation requirements.',
    `dispensing_visit` STRING COMMENT 'The protocol-defined visit name or number at which this kit was dispensed to the subject (e.g., Visit 2 - Week 4). Used for protocol compliance verification and eCRF reconciliation.',
    `expiry_date` DATE COMMENT 'The expiration date of the investigational medicinal product within this kit as printed on the label. Kits must not be dispensed after this date. Used for expiry management, re-supply planning, and regulatory accountability.',
    `kit_number` STRING COMMENT 'Externally-known unique alphanumeric identifier assigned to the physical randomization kit by the RTSM (Medidata Rave). This is the primary business identifier used in drug accountability logs, dispensing records, and regulatory submissions.. Valid values are `^[A-Z0-9-]{4,30}$`',
    `kit_status` STRING COMMENT 'Current lifecycle status of the kit within the supply chain. available = at depot or site, ready for assignment; assigned = allocated to a subject via RTSM but not yet dispensed; dispensed = physically given to subject; expired = past expiry date',
    `label_version` STRING COMMENT 'The version identifier of the IMP label applied to this kit. Used to verify that the correct, IRB/IEC-approved label version was used at the time of dispensing and for regulatory label reconciliation.',
    `manufacture_date` DATE COMMENT 'Date on which the investigational medicinal product in this kit was manufactured. Used for shelf-life calculation, batch traceability, and regulatory accountability.',
    `protocol_version` STRING COMMENT 'The version of the study protocol under which this kit was dispensed or assigned. Ensures that kit dispensing is traceable to the correct protocol amendment for regulatory compliance.',
    `randomization_number` STRING COMMENT 'The unique randomization number assigned to the subject-kit pairing by the RTSM (IRT/IVRS) at the point of subject randomization. Links the kit to the randomization schedule for unblinding and accountability.. Valid values are `^[A-Z0-9-]{3,20}$`',
    `retest_date` DATE COMMENT 'Date by which the kit must be retested or re-evaluated for continued use, particularly for products with conditional shelf-life extensions. Distinct from expiry_date; used for stability management.',
    `returned_quantity` BIGINT COMMENT 'The number of dosage units returned by the subject or site for this kit. Used in drug accountability reconciliation to calculate compliance and account for unused medication.',
    `returned_timestamp` TIMESTAMP COMMENT 'The date and time at which the kit was returned by the subject or site to the depot or destruction facility. Part of the chain-of-custody audit trail for drug accountability.',
    `rtsm_kit_code` STRING COMMENT 'The source system identifier for this kit record as assigned by the RTSM module in Medidata Rave. Used for data lineage, reconciliation between the Silver Layer and the operational RTSM system, and audit trail traceability.',
    `site_receipt_timestamp` TIMESTAMP COMMENT 'The date and time at which the kit was received and confirmed at the investigational site. Marks the transfer of custody from depot/logistics to site. Used for site inventory reconciliation.',
    `storage_condition` STRING COMMENT 'Required storage condition for this kit as specified on the label and protocol. Drives warehouse and site storage assignment, cold-chain logistics, and temperature excursion monitoring.. Valid values are `room_temperature|refrigerated|frozen|ultra_frozen|controlled_room_temperature`',
    `temperature_excursion_flag` BOOLEAN COMMENT 'Indicates whether a temperature excursion event has been recorded for this kit during storage or transit. When True, the kit must be quarantined and assessed by QA before dispensing.',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time at which this kit inventory record was last modified. Supports audit trail requirements and change tracking under 21 CFR Part 11 and ALCOA+ principles.',
    CONSTRAINT pk_kit_inventory PRIMARY KEY(`kit_inventory_id`)
) COMMENT 'Tracks physical randomization kit instances across the supply chain — from manufacture through depot receipt, site shipment, dispensing, and destruction. Each record represents a unique kit number with current status (available, assigned, dispensed';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`supply`.`depot` (
    `depot_id` BIGINT COMMENT 'Unique system-generated identifier for the clinical supply depot. Primary key for the depot master record.',
    `clinical_trial_authorization_id` BIGINT COMMENT 'Foreign key linking to regulatory.clinical_trial_authorization. Business justification: Depots holding IMP in a given country must operate under a valid CTA for that jurisdiction.',
    `document_sop_id` BIGINT COMMENT 'Foreign key linking to document.document_sop. Business justification: Depot qualification, storage, and handling operations are governed by GMP/GCP SOPs. Linking depot to document_sop enables audit trail verification that the correct SOP version governed',
    `lab_facility_id` BIGINT COMMENT 'Foreign key linking to laboratory.lab_facility. Business justification: Depot 3PL providers are engaged via subcontracts that govern service obligations, GMP requirements, and liability.',
    `regulatory_binder_id` BIGINT COMMENT 'Foreign key linking to document.regulatory_binder. Business justification: Depot import licenses, wholesale distribution licenses, and GMP certificates are filed in regulatory binders.',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Depot qualification reports and GMP certificates are ICH GCP essential TMF documents (Zone 5). Each depot must link to its qualification/GMP certificate document in the eTMF.',
    `address_line1` STRING COMMENT 'Primary street address of the depot facility. Used for logistics routing, regulatory filings, and cold-chain shipment documentation.',
    `address_line2` STRING COMMENT 'Secondary address detail (suite, building, floor) for the depot facility.',
    `ambient_storage_capacity_m3` DECIMAL(10,3) COMMENT 'Total ambient temperature storage capacity of the depot measured in cubic metres. Ambient storage is typically 15–25°C. Used for supply planning and capacity allocation across studies.',
    `city` STRING COMMENT 'City in which the depot facility is located. Used for geographic distribution planning and regulatory jurisdiction determination.',
    `depot_code` STRING COMMENT 'Externally-known alphanumeric code uniquely identifying the depot within the clinical supply network. Used in RTSM (Randomization and Trial Supply Management) and CTMS for depot referencing across studies.. Valid values are `^[A-Z0-9_-]{2,20}$`',
    `cold_chain_qualified` BOOLEAN COMMENT 'Indicates whether the depot has been formally qualified for cold-chain IMP handling, including validated temperature monitoring, qualified packaging, and trained personnel per WHO and GDP guidelines.',
    `controlled_substance_licensed` BOOLEAN COMMENT 'Indicates whether the depot is licensed to store and handle controlled substances (narcotics, psychotropics) as defined by DEA Schedule (US), Home Office (UK), or equivalent national authority.',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 three-letter country code for the country in which the depot is located. Drives regulatory jurisdiction, import/export rules, and cold-chain routing logic.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the depot master record was first created in the system. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `ctms_depot_code` STRING COMMENT 'Depot identifier as recorded in the source system Enables cross-system reconciliation between the supply chain data product and clinical trial management records.',
    `decommission_date` DATE COMMENT 'Date on which the depot was or is scheduled to be decommissioned and removed from the active clinical supply network. Null for currently active depots.',
    `depot_status` STRING COMMENT 'Current operational lifecycle status of the depot. Active depots are approved for IMP storage and distribution. Suspended depots are temporarily halted pending investigation or re-qualification. Decommissioned depots are permanently closed.. Valid values are `active|inactive|qualified|suspended|decommissioned`',
    `depot_type` STRING COMMENT 'Classification of the depot within the clinical supply logistics network. Central depots serve as primary distribution hubs; regional depots serve geographic clusters; local depots are near investigational sites; satellite depots are temporary; returns. Valid values are `central|regional|local|satellite|returns`',
    `destruction_authorized` BOOLEAN COMMENT 'Indicates whether the depot is authorized to perform on-site destruction of expired, returned, or unusable IMPs in compliance with GMP and environmental regulations.',
    `erp_vendor_code` STRING COMMENT 'Vendor or supplier identifier for the depot as registered in the source system for purchase order processing, invoice matching, and financial reconciliation of depot service fees.',
    `frozen_storage_capacity_m3` DECIMAL(10,3) COMMENT 'Total frozen storage capacity (typically -20°C or -80°C) of the depot in cubic metres. Required for biologics, gene therapies, and other temperature-sensitive IMPs.',
    `gmp_certificate_expiry_date` DATE COMMENT 'Date on which the depots GMP certificate expires. Triggers re-qualification workflows and may suspend depot operations if not renewed prior to expiry.',
    `gmp_certificate_number` STRING COMMENT 'Official certificate number issued by the regulatory authority confirming GMP compliance for the depot. Referenced in regulatory submissions and audit documentation.',
    `gmp_certified` BOOLEAN COMMENT 'Indicates whether the depot holds a current Good Manufacturing Practice (GMP) certification as required for IMP storage and handling under ICH Q7/Q10 and applicable regional regulations.',
    `import_license_expiry_date` DATE COMMENT 'Expiry date of the depots import license for IMP receipt. Expired licenses block inbound international shipments.',
    `last_audit_date` DATE COMMENT 'Date of the most recent GMP/GDP audit conducted at the depot by the sponsor, CRO, or regulatory authority. Audit outcomes are tracked in the quality management system (MasterControl).',
    `last_qualification_date` DATE COMMENT 'Date on which the depot last completed a formal qualification or re-qualification exercise (IQ/OQ/PQ). Qualification records are maintained in the eTMF and are subject to regulatory inspection.',
    `depot_name` STRING COMMENT 'Full legal or operational name of the clinical supply depot as registered with regulatory authorities and used in the Trial Master File (TMF).',
    `next_audit_due_date` DATE COMMENT 'Scheduled date for the next GMP/GDP audit at the depot. Used for audit planning and compliance calendar management.',
    `next_qualification_due_date` DATE COMMENT 'Scheduled date for the next depot qualification or re-qualification. Drives preventive maintenance and compliance calendar in the CTMS and quality management system.',
    `notes` STRING COMMENT 'Free-text field for operational notes, special handling instructions, or depot-specific constraints relevant to clinical supply operations. Not intended for regulatory documentation.',
    `operational_start_date` DATE COMMENT 'Date on which the depot became operationally active for clinical supply activities. Used for lifecycle tracking and regulatory documentation.',
    `postal_code` STRING COMMENT 'Postal or ZIP code of the depot facility. Used for logistics routing and regulatory jurisdiction mapping.',
    `primary_contact_email` STRING COMMENT 'Email address of the primary operational contact at the depot. Used for shipment alerts, RTSM notifications, and supply chain communications.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `primary_contact_name` STRING COMMENT 'Full name of the primary operational contact person at the depot. Used for logistics coordination, shipment notifications, and regulatory correspondence.',
    `primary_contact_phone` STRING COMMENT 'Primary telephone number for the depot operational contact. Used for urgent logistics coordination and cold-chain incident escalation.. Valid values are `^+?[0-9s-().]{7,20}$`',
    `refrigerated_storage_capacity_m3` DECIMAL(10,3) COMMENT 'Total refrigerated storage capacity (typically 2–8°C) of the depot in cubic metres. Critical for IMPs requiring cold-chain management.',
    `returns_accepted` BOOLEAN COMMENT 'Indicates whether the depot is authorized to receive returned Investigational Medicinal Products (IMPs) from investigational sites. Required for accountability reconciliation and destruction workflows.',
    `rtsm_depot_code` STRING COMMENT 'Depot identifier as configured in the RTSM system (Medidata Rave RTSM). Used to link depot master records to RTSM dispensing, randomization kit assignment, and resupply trigger logic.',
    `state_province` STRING COMMENT 'State, province, or administrative region where the depot is located. Relevant for import/export licensing and regional regulatory compliance.',
    `temperature_monitoring_system` STRING COMMENT 'Name or model of the continuous temperature monitoring system installed at the depot (e.g., Sensitech TempTale, Berlinger ELPRO). Ensures 21 CFR Part 11 compliant electronic records of storage conditions.',
    `time_zone` STRING COMMENT 'IANA time zone identifier for the depot location (e.g., America/New_York, Europe/London). Used for scheduling shipment windows, expiry checks, and operational hours alignment.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the depot master record. Supports change tracking and audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `wholesale_license_expiry_date` DATE COMMENT 'Expiry date of the wholesale distribution license. Depot cannot legally distribute IMPs after this date without renewal.',
    CONSTRAINT pk_depot PRIMARY KEY(`depot_id`)
) COMMENT 'Master record for clinical supply depots (central and regional warehouses) that store and distribute IMPs. Captures depot name, geographic location, GMP certification status, temperature-controlled storage capabilities (ambient, refrigerated, frozen)';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`supply`.`site_inventory` (
    `site_inventory_id` BIGINT COMMENT 'Unique surrogate identifier for each site inventory record representing a stock position of an Investigational Medicinal Product (IMP) or kit type at a specific supply chain node (investigational site or depot).',
    `arm_id` BIGINT COMMENT 'Foreign key linking to study.arm. Business justification: Site-level IMP inventory is maintained per treatment arm; resupply triggers and accountability reconciliation are arm-specific.',
    `clinical_trial_authorization_id` BIGINT COMMENT 'Foreign key linking to regulatory.clinical_trial_authorization. Business justification: Site-level IMP inventory is authorized for holding and dispensing only under a valid country-specific CTA.',
    `depot_id` BIGINT COMMENT 'Foreign key linking to supply.depot. Business justification: site_inventory tracks IMP and kit stock positions at supply chain nodes including both investigational sites AND depots (the product description explicitly states supply chain nodes',
    `document_sop_id` BIGINT COMMENT 'Foreign key linking to document.document_sop. Business justification: Site inventory management, reconciliation, and storage procedures are governed by GCP SOPs.',
    `imp_master_id` BIGINT COMMENT 'Reference to the Investigational Medicinal Product (IMP) master record defining the drug substance, formulation, and dosage form tracked in this inventory position.',
    `kit_definition_id` BIGINT COMMENT 'Reference to the randomization kit type as defined in the RTSM (Randomization and Trial Supply Management) system (Medidata Rave). Identifies the specific kit configuration (e.g., treatment arm, dose level, pack size) tracked in this inventory record.',
    `manufacture_batch_id` BIGINT COMMENT 'Foreign key linking to supply.manufacture_batch. Business justification: Site inventory is tracked by batch (site_inventory.batch_number is denormalized). Each site inventory record represents stock of a specific manufacturing batch at a site.',
    `receipt_shipment_id` BIGINT COMMENT 'Foreign key linking to supply.shipment. Business justification: Site inventory records are created or updated when a shipment is received at the investigational site. Adding receipt_shipment_id links the site inventory record to the inbound shipment.',
    `site_file_id` BIGINT COMMENT 'Foreign key linking to document.site_file. Business justification: Site inventory accountability records are essential site file documents required for GCP inspection readiness.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this inventory is being tracked. Links inventory records to the sponsoring protocol and enables study-level accountability reconciliation.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site or depot location where this inventory is physically held. Enables site-level stock position reporting and resupply trigger management.',
    `treatment_arm_id` BIGINT COMMENT 'Foreign key linking to randomization.treatment_arm. Business justification: Site inventory is maintained per treatment arm to enforce arm-specific minimum/maximum stock thresholds and trigger resupply.',
    `accountability_reconciled` BOOLEAN COMMENT 'Indicates whether the IMP accountability reconciliation has been completed for this inventory position. Set to True when all received, dispensed, returned, expired, and destroyed quantities have been formally reconciled and signed off per GCP requirements.',
    `batch_number` STRING COMMENT 'Manufacturers batch or lot number for the IMP stock held at this location. Required for regulatory traceability, recall management, and accountability reconciliation. Corresponds to the batch/lot number on the IMP label.',
    `blinding_level` STRING COMMENT 'Blinding level applicable to this inventory position, indicating whether the IMP identity is masked at this location. Drives labeling requirements and access controls for inventory data to preserve study integrity.. Valid values are `open_label|single_blind|double_blind|triple_blind`',
    `destruction_authorized` BOOLEAN COMMENT 'Indicates whether destruction of expired, returned, or quarantined IMP stock at this location has been formally authorized by the sponsor or designee. Required before physical destruction can proceed per GCP and regulatory requirements.',
    `destruction_date` DATE COMMENT 'Date on which IMP units or kits were destroyed at or from this location. Required for regulatory accountability documentation and study close-out reporting.',
    `expiry_date` DATE COMMENT 'Expiry date of the IMP batch or kit stock held at this location, as stated on the product label. Used for expiry management, resupply planning, and to prevent dispensing of expired product to study subjects.',
    `imp_unit_of_measure` STRING COMMENT 'Unit of measure used to count IMP stock at this location (e.g., kit, vial, tablet, capsule, syringe, ampoule). Ensures consistent quantity reporting across different IMP formulations and packaging configurations.. Valid values are `kit|vial|tablet|capsule|syringe|ampoule`',
    `inventory_number` STRING COMMENT 'Externally-known, human-readable unique identifier for this inventory position record, typically generated by the RTSM or CTMS system. Used in regulatory accountability documentation and audit trails.',
    `inventory_status` STRING COMMENT 'Current lifecycle status of this inventory position. active indicates stock is available for dispensing; quarantined indicates stock is held pending investigation or quality review; depleted indicates zero usable stock; closed indicates the. Valid values are `active|quarantined|depleted|closed|suspended`',
    `last_dispensing_date` DATE COMMENT 'Date on which the most recent IMP or kit dispensing event occurred at this location. Used to monitor site dispensing activity and identify inactive sites that may require supply reallocation.',
    `last_physical_count_date` DATE COMMENT 'Date on which the most recent physical inventory count was conducted at this location for this IMP or kit type. Used to assess inventory data currency and schedule the next physical count per the accountability reconciliation plan.',
    `last_physical_count_qty` BIGINT COMMENT 'Actual physical count of IMP units or kits recorded during the most recent physical inventory count at this location. Compared against the system quantity to identify discrepancies requiring investigation.',
    `last_shipment_date` DATE COMMENT 'Date on which the most recent inbound IMP or kit shipment was received and confirmed at this location. Used to track supply chain activity and assess time since last replenishment.',
    `location_type` STRING COMMENT 'Classification of the supply chain node holding this inventory. Distinguishes between investigational sites (where IMP is dispensed to subjects), depots (regional or central storage), central pharmacies, and satellite depots.. Valid values are `site|depot|central_pharmacy|satellite_depot`',
    `maximum_stock_qty` BIGINT COMMENT 'Maximum number of IMP units or kits permitted at this location to prevent overstocking, minimize expiry risk, and comply with storage capacity constraints. Used in supply planning and RTSM configuration.',
    `minimum_stock_qty` BIGINT COMMENT 'Absolute minimum number of IMP units or kits that must be maintained at this location to ensure uninterrupted subject dosing. Falling below this level triggers an urgent resupply escalation.',
    `qty_adjusted` BIGINT COMMENT 'Net inventory adjustment quantity applied to this position due to physical count discrepancies, data corrections, or reconciliation differences. Positive values indicate upward adjustments; negative values indicate downward adjustments.',
    `qty_allocated` BIGINT COMMENT 'Number of IMP units or kits currently reserved or allocated to specific subjects or randomization slots via the RTSM but not yet physically dispensed. Reduces available-for-dispensing stock.',
    `qty_destroyed` BIGINT COMMENT 'Cumulative number of IMP units or kits that have been destroyed at or from this location, including expired, damaged, or returned-and-destroyed stock. Required for regulatory accountability reconciliation.',
    `qty_dispensed` BIGINT COMMENT 'Cumulative number of IMP units or kits dispensed to study subjects at this location since the study began or since the last accountability reconciliation period. Sourced from dispensing records in the RTSM.',
    `qty_expired` BIGINT COMMENT 'Number of IMP units or kits that have passed their expiry date at this location and are no longer eligible for dispensing. Tracked separately for regulatory accountability and waste reporting.',
    `qty_on_hand` BIGINT COMMENT 'Current physical count of IMP units or kits available at this location, excluding quarantined, allocated, and reserved stock. Represents the net usable inventory at the time of the last update. Used as the primary metric for resupply trigger evaluation.',
    `qty_quarantined` BIGINT COMMENT 'Number of IMP units or kits currently placed in quarantine at this location due to quality concerns, temperature excursions, damaged packaging, or pending investigation. These units are not available for dispensing.',
    `qty_received` BIGINT COMMENT 'Cumulative number of IMP units or kits received at this location since the study began or since the last accountability reconciliation period. Sourced from inbound shipment confirmations in the RTSM.',
    `qty_returned` BIGINT COMMENT 'Cumulative number of IMP units or kits returned from subjects or from this site to the depot or sponsor for destruction or reconciliation. Used in accountability reconciliation calculations.',
    `reconciliation_date` DATE COMMENT 'Date on which the most recent IMP accountability reconciliation was completed and approved for this inventory position. Required for regulatory inspection readiness and study close-out documentation.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this inventory record was first created in the system, conforming to ALCOA+ principles of contemporaneous data capture. Used for audit trail and data lineage purposes.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this inventory record was most recently modified. Supports audit trail requirements under ALCOA+ and 21 CFR Part 11, and enables change detection in the Databricks lakehouse silver layer.',
    `reorder_point` BIGINT COMMENT 'Minimum quantity threshold at which a resupply request should be triggered for this IMP or kit type at this location. When qty_on_hand falls at or below this value, the RTSM or supply planner initiates a replenishment shipment.',
    `reorder_qty` BIGINT COMMENT 'Standard replenishment quantity to be shipped when a resupply is triggered for this location and IMP/kit type. Defined in the supply plan and used by the RTSM to generate resupply orders automatically.',
    `resupply_request_date` DATE COMMENT 'Date on which the most recent resupply request was initiated for this inventory position. Used to track supply chain responsiveness and expected delivery timelines.',
    `resupply_triggered` BOOLEAN COMMENT 'Indicates whether an active resupply request has been triggered for this inventory position. Set to True when qty_on_hand falls at or below the reorder_point and a resupply order has been initiated in the RTSM or supply management system.',
    `retest_date` DATE COMMENT 'Date by which the IMP batch must be retested to confirm continued stability and suitability for use. Applicable for products with defined retest periods rather than fixed expiry dates. Triggers stability testing workflows.',
    `rtsm_location_code` STRING COMMENT 'The location identifier assigned to this site or depot within the RTSM system (Medidata Rave). Used to reconcile inventory records between the lakehouse silver layer and the operational RTSM source system.',
    `storage_condition` STRING COMMENT 'Required storage condition for the IMP or kit at this location, as specified in the Investigational Medicinal Product Dossier (IMPD) or protocol. Drives cold-chain logistics planning and compliance monitoring.. Valid values are `room_temperature|refrigerated|frozen|ultra_frozen|controlled_room_temperature`',
    `storage_condition_compliant` BOOLEAN COMMENT 'Indicates whether the current storage conditions at this location are compliant with the required storage condition specification for this IMP or kit type.',
    `temperature_excursion_count` BIGINT COMMENT 'Cumulative number of recorded temperature excursion events for this inventory position at this location. Used to assess cold-chain compliance history and inform quarantine or destruction decisions.',
    CONSTRAINT pk_site_inventory PRIMARY KEY(`site_inventory_id`)
) COMMENT 'Tracks IMP and kit stock positions at supply chain nodes (investigational sites and depots). Each record represents current inventory levels by IMP/kit type at a specific location, including quantity on-hand, received, dispensed, allocated, quarantined';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`supply`.`supply_plan` (
    `supply_plan_id` BIGINT COMMENT 'Unique surrogate identifier for the investigational medicinal product (IMP) supply plan record within the clinical trial supply chain management system.',
    `application_id` BIGINT COMMENT 'Foreign key linking to regulatory.application. Business justification: Supply plans are built around a specific investigational compounds development phase, enrollment projections, and manufacturing requirements.',
    `clinical_trial_authorization_id` BIGINT COMMENT 'Foreign key linking to regulatory.clinical_trial_authorization. Business justification: Supply plans are scoped to specific CTAs per country/region — IMP can only be supplied where a valid CTA exists.',
    `dosing_regimen_id` BIGINT COMMENT 'Foreign key linking to study.dosing_regimen. Business justification: Supply quantity forecasting is directly calculated from the dosing regimen (dose frequency, treatment duration, number of subjects per arm).',
    `imp_master_id` BIGINT COMMENT 'Reference to the investigational medicinal product (IMP) being planned, linking to the product master record that defines formulation, dosage form, and strength.',
    `ind_application_id` BIGINT COMMENT 'Foreign key linking to regulatory.ind_application. Business justification: Supply plans are scoped to an IND — the IND defines the protocol coverage, phase, and product authorization that drives manufacturing quantity planning.',
    `interim_analysis_id` BIGINT COMMENT 'Foreign key linking to biostatistics.interim_analysis. Business justification: In adaptive trials, interim analysis outcomes (sample size re-estimation, early stopping) directly trigger supply plan revisions.',
    `investigational_product_id` BIGINT COMMENT 'Foreign key linking to study.investigational_product. Business justification: Supply plans are built for a specific investigational product as defined in the study protocol (IND/IMPD reference, storage conditions, shelf life).',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: Supply plans are built against a specific protocol version — planned enrollment, dosing regimen, number of arms, and visit frequency all derive from the protocol.',
    `rand_list_id` BIGINT COMMENT 'Foreign key linking to randomization.rand_list. Business justification: Supply plans are built against a specific randomization list version; when a new rand_list is activated (e.g., post-amendment), the supply plan must reference that version for',
    `rand_scheme_id` BIGINT COMMENT 'Foreign key linking to randomization.rand_scheme. Business justification: Supply planning is directly driven by the randomization scheme — allocation ratios, treatment arm counts, block sizes, and stratification factors determine IMP quantities and',
    `regulatory_binder_id` BIGINT COMMENT 'Foreign key linking to document.regulatory_binder. Business justification: Supply plans are submitted as part of IND/CTA regulatory packages. Linking supply_plan to regulatory_binder enables tracking of which regulatory submission package contains the',
    `risk_assessment_id` BIGINT COMMENT 'Foreign key linking to compliance.risk_assessment. Business justification: Supply plans for clinical trials require a formal risk assessment (supply shortage risk, cold chain risk, expiry risk).',
    `sample_size_calc_id` BIGINT COMMENT 'Foreign key linking to biostatistics.sample_size_calc. Business justification: Supply plan quantities (forecasted_enrollment, dropout_rate_pct, total_units_planned) are derived directly from the approved sample size calculation.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this supply plan is created. Links the supply plan to the study protocol, enrollment projections, and dosing regimen.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Supply plans are essential TMF documents filed under DIA TMF Reference Model Section 11 (IP Management).',
    `accountability_reconciliation_required` BOOLEAN COMMENT 'Indicates whether drug accountability reconciliation is required under this supply plan, as mandated by GCP and regulatory requirements. Drives reconciliation workflow in RTSM and site monitoring activities.',
    `approval_date` DATE COMMENT 'Date on which the supply plan was formally approved by the sponsor supply team and/or CRO supply chain lead. Null if plan has not yet been approved.',
    `blinding_type` STRING COMMENT 'Blinding configuration of the study as it affects supply planning. Double-blind studies require matched placebo kits; open-label studies have simpler kit structures. Impacts kit design and labeling requirements.. Valid values are `open_label|single_blind|double_blind|triple_blind`',
    `buffer_stock_weeks` DECIMAL(5,1) COMMENT 'Target buffer stock expressed in weeks of supply to be maintained at depot and/or site level. Ensures continuity of supply during manufacturing lead times and logistics delays.',
    `cold_chain_required` BOOLEAN COMMENT 'Indicates whether the IMP requires cold-chain logistics (temperature-controlled storage and transport) throughout the supply chain. Drives depot selection, packaging specifications, and logistics provider requirements.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this supply plan record was first created in the system, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Supports audit trail and ALCOA+ compliance.',
    `destruction_plan_included` BOOLEAN COMMENT 'Indicates whether this supply plan version includes a returns and destruction plan for expired, unused, or damaged IMP. Required for GMP compliance and accountability reconciliation.',
    `dropout_rate_pct` DECIMAL(5,2) COMMENT 'Assumed subject dropout/discontinuation rate (as a percentage) applied in demand forecasting calculations. Accounts for subjects who withdraw consent, are lost to follow-up, or are discontinued per protocol.',
    `expiry_management_strategy` STRING COMMENT 'Strategy applied for managing IMP expiry at depot and site level. FIFO (First In First Out), FEFO (First Expired First Out), manual review, or RTSM-managed automated expiry tracking.. Valid values are `fifo|fefo|manual_review|rtsm_managed`',
    `forecasted_enrollment` BIGINT COMMENT 'Total number of subjects projected to be enrolled over the planning horizon, derived from enrollment projections and site feasibility assessments. Primary driver of IMP demand forecasting.',
    `geographic_scope` STRING COMMENT 'Description of the geographic coverage of this supply plan, specifying countries or regions included (e.g., USA, GBR, DEU). Drives country-level demand forecasting and depot assignment.',
    `horizon_end_date` DATE COMMENT 'End date of the planning horizon covered by this supply plan. Typically extends to study completion or database lock (DBL) plus a buffer for returns and destruction.',
    `horizon_start_date` DATE COMMENT 'Start date of the planning horizon covered by this supply plan. Defines the beginning of the forecasted demand and manufacturing schedule window.',
    `notes` STRING COMMENT 'Free-text field for supply chain planners to document assumptions, constraints, protocol amendment impacts, or sponsor-specific instructions relevant to this supply plan version.',
    `overage_pct` DECIMAL(5,2) COMMENT 'Planned overage percentage applied on top of net demand to account for wastage, damaged kits, protocol amendments, and supply chain uncertainties. Agreed with sponsor and documented in the supply agreement.',
    `plan_date` DATE COMMENT 'The principal business date on which this supply plan was formally prepared or issued. Represents the real-world event date distinct from system audit timestamps.',
    `plan_number` STRING COMMENT 'Externally-known, human-readable unique identifier for the supply plan, typically formatted as SP-{StudyCode}-{Year}-{Sequence}. Used in sponsor communications, RTSM configuration, and regulatory documentation.. Valid values are `^SP-[A-Z0-9]{3,10}-[0-9]{4}-[0-9]{3}$`',
    `planned_manufacturing_batches` BIGINT COMMENT 'Total number of manufacturing batches planned to fulfill the forecasted IMP demand over the planning horizon, including buffer and overage quantities.',
    `planning_cycle` STRING COMMENT 'Frequency or trigger basis for this supply plan update cycle. Typically monthly or per enrollment milestone as defined in the supply agreement with the sponsor.. Valid values are `monthly|quarterly|enrollment_milestone|ad_hoc`',
    `randomization_method` STRING COMMENT 'Randomization methodology used in the RTSM for kit assignment to subjects. Drives kit numbering, stratification factors, and supply allocation logic within Medidata Rave RTSM.. Valid values are `central|stratified|block|minimization|open_label`',
    `resupply_quantity` BIGINT COMMENT 'Standard quantity of kits or units to be shipped per resupply order when the resupply trigger threshold is reached. Defined per site tier and country in the supply plan.',
    `resupply_trigger_threshold` BIGINT COMMENT 'Minimum kit or unit quantity at depot or site level that triggers an automatic resupply order via RTSM (Interactive Response Technology). When inventory falls to or below this threshold, a resupply shipment is initiated.',
    `rtsm_plan_code` STRING COMMENT 'Identifier of the corresponding supply plan configuration record within the Medidata Rave RTSM system. Enables traceability between the lakehouse supply plan record and the operational RTSM configuration.',
    `shelf_life_months` BIGINT COMMENT 'Approved shelf life of the IMP in months from date of manufacture, as defined in the product specification and stability data. Critical for expiry management and resupply timing calculations.',
    `site_tier_scope` STRING COMMENT 'Site tier classification covered by this supply plan. Allows differentiated supply planning for high-enrolling versus low-enrolling sites, supporting optimized kit allocation and resupply strategies.. Valid values are `all|tier_1|tier_2|tier_3|high_enrolling|low_enrolling`',
    `storage_temperature_max_c` DECIMAL(5,1) COMMENT 'Maximum acceptable storage temperature in degrees Celsius for the IMP as specified in the product dossier. Defines upper bound for cold-chain and ambient storage qualification.',
    `storage_temperature_min_c` DECIMAL(5,1) COMMENT 'Minimum acceptable storage temperature in degrees Celsius for the IMP as specified in the product dossier. Used to define cold-chain logistics requirements and depot qualification criteria.',
    `supply_plan_status` STRING COMMENT 'Current lifecycle status of the supply plan. Draft indicates initial creation; under_review indicates sponsor/CRO review; approved indicates sign-off; active indicates currently governing supply operations; superseded indicates replaced by a newer. Valid values are `draft|under_review|approved|active|superseded|cancelled`',
    `total_units_planned` BIGINT COMMENT 'Total number of IMP units (e.g., tablets, vials, kits) planned for manufacture and distribution over the planning horizon, inclusive of overage and buffer stock.',
    `treatment_arms_count` BIGINT COMMENT 'Number of treatment arms (including placebo/comparator) in the study protocol that require separate IMP supply planning. Drives kit type differentiation in RTSM randomization configuration.',
    `unit_of_measure` STRING COMMENT 'The unit in which IMP supply quantities are expressed and tracked throughout the supply plan (e.g., kit, vial, tablet). Aligns with RTSM kit configuration and dispensing records.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this supply plan record, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Updated on every planning cycle revision or status change.',
    `version` STRING COMMENT 'Version identifier of the supply plan (e.g., v1.0, v2.3), incremented at each planning cycle or upon significant enrollment milestone updates. Supports version history and audit trail.. Valid values are `^v[0-9]+.[0-9]+$`',
    CONSTRAINT pk_supply_plan PRIMARY KEY(`supply_plan_id`)
) COMMENT 'Clinical supply plan - distinct concept, separate owner from monitoring_plan and program_plan.';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` (
    `manufacture_batch_id` BIGINT COMMENT 'Unique surrogate identifier for the IMP manufacturing batch record in the clinical supply chain. Primary key for all downstream kit, inventory, and accountability traceability.',
    `approval_id` BIGINT COMMENT 'Foreign key linking to regulatory.approval. Business justification: Batch release decisions require traceability to the regulatory approval authorizing the product.',
    `capa_id` BIGINT COMMENT 'Foreign key linking to compliance.compliance_capa. Business justification: CAPAs are frequently initiated against specific manufacture batches (batch release failure, GMP deviation on a specific batch). manufacture_batch has no compliance_capa_id.',
    `clinical_trial_authorization_id` BIGINT COMMENT 'Foreign key linking to regulatory.clinical_trial_authorization. Business justification: In EU/non-US jurisdictions, CTAs govern batch release and authorized use of IMP.',
    `imp_master_id` BIGINT COMMENT 'Foreign key linking to supply.imp_master. Business justification: Each manufacturing batch produces a specific IMP. manufacture_batch.imp_name and imp_code are denormalized from imp_master.product_name and product_code.',
    `ind_application_id` BIGINT COMMENT 'Foreign key linking to regulatory.ind_application. Business justification: IND applications govern which batches can be manufactured and used in US clinical trials.',
    `investigational_product_id` BIGINT COMMENT 'Foreign key linking to study.investigational_product. Business justification: Regulatory batch release and GMP compliance require traceability from each manufactured batch to the protocol-registered investigational product.',
    `rand_scheme_id` BIGINT COMMENT 'Foreign key linking to randomization.rand_scheme. Business justification: Batch release QA documentation must reference the randomization scheme to confirm blinding compliance and correct active/placebo/comparator quantities.',
    `regulatory_binder_id` BIGINT COMMENT 'Foreign key linking to document.regulatory_binder. Business justification: Batch records and CoAs are submitted as part of IND/CTA regulatory submissions. manufacture_batch has ind_number and cta_reference as plain text.',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to.',
    `supply_plan_id` BIGINT COMMENT 'Foreign key linking to supply.supply_plan. Business justification: Manufacturing batches are produced in accordance with a clinical supply plan. supply_plan has planned_manufacturing_batches count, indicating it governs batch production.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Batch release documents (Certificate of Analysis, GMP release certificates) are essential TMF documents per ICH E6 R2 Section 8.',
    `available_quantity` BIGINT COMMENT 'Current quantity of units from this batch that are available for allocation to depots or clinical sites, net of already allocated, dispensed, returned, and destroyed quantities. Used for supply planning and shortage risk monitoring.',
    `batch_number` STRING COMMENT 'Externally-known alphanumeric batch/lot number assigned by the manufacturing site, as printed on the IMP label and referenced in the Certificate of Analysis (CoA).. Valid values are `^[A-Z0-9-]{3,30}$`',
    `batch_size` BIGINT COMMENT 'Total number of units (e.g., tablets, vials, kits) manufactured in this batch. Used for supply planning, yield calculations, and accountability reconciliation against dispensed and returned quantities.',
    `batch_size_unit` STRING COMMENT 'Unit of measure for the batch size quantity (e.g., units, vials, tablets, kits). Required for unambiguous interpretation of batch_size in supply planning and accountability reports.',
    `batch_type` STRING COMMENT 'Classification of the batch purpose: clinical (intended for subject dosing), validation (process validation), stability (stability study samples), reference (retained reference samples), reserve (emergency reserve).. Valid values are `clinical|validation|stability|reference|reserve`',
    `blinding_type` STRING COMMENT 'Blinding classification of the IMP batch indicating whether the batch is open-label, single-blind, double-blind, or triple-blind. Determines labelling requirements, handling procedures, and unblinding protocols at clinical sites.. Valid values are `open_label|single_blind|double_blind|triple_blind`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this manufacture batch record was first created in the system, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Supports ALCOA+ audit trail requirements and data lineage tracking.',
    `cta_reference` STRING COMMENT 'Clinical Trial Authorisation (CTA) reference number issued by the relevant national competent authority (e.g., EMA, MHRA) under which this IMP batch is authorised for use in the clinical trial.',
    `destroyed_quantity` BIGINT COMMENT 'Total number of units from this batch that have been confirmed destroyed, including rejected units, expired returns, and reconciliation destructions. Required for GMP accountability reconciliation and regulatory reporting.',
    `destruction_certificate_ref` STRING COMMENT 'Reference number of the destruction certificate issued upon confirmed destruction of batch units. Required for GMP accountability reconciliation and regulatory audit trail. Links to document management system (Veeva Vault).',
    `dosage_form` STRING COMMENT 'Pharmaceutical dosage form of the IMP in this batch (e.g., tablet, capsule, injection). Determines storage, handling, and dispensing requirements at clinical sites.',
    `expiry_date` DATE COMMENT 'The date after which the IMP batch must not be used, as determined by stability studies and printed on the IMP label. Critical for expiry management, site recall, and RTSM kit assignment logic to prevent dispensing of expired product.',
    `gmp_certificate_number` STRING COMMENT 'Reference number of the GMP manufacturing authorisation or certificate issued by the relevant regulatory authority for the manufacturing site. Confirms the site is authorised to manufacture IMPs for clinical trials.',
    `is_comparator` BOOLEAN COMMENT 'Indicates whether this batch is a comparator (active control or placebo) product rather than the investigational drug. True = comparator/placebo; False = investigational drug. Used for supply planning, kit assembly, and RTSM randomization configuration.',
    `is_placebo` BOOLEAN COMMENT 'Indicates whether this batch contains placebo (no active ingredient). True = placebo batch; False = active drug batch. Distinct from is_comparator as a batch may be a comparator active drug. Used for blinded supply management and kit labelling.',
    `manufacture_date` DATE COMMENT 'The date on which manufacturing of this IMP batch was completed, as recorded in the batch manufacturing record. Used as the reference point for shelf-life and expiry date calculation.',
    `manufacturing_site_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the country where the manufacturing site is located. Used for import/export regulatory compliance and supply chain risk assessment.. Valid values are `^[A-Z]{3}$`',
    `manufacturing_site_name` STRING COMMENT 'Name of the GMP-certified facility where this IMP batch was manufactured. Used for regulatory traceability, site audit trails, and supply chain accountability.',
    `packaging_configuration` STRING COMMENT 'Description of the primary and secondary packaging configuration for this batch (e.g., 30-count HDPE bottle, 10-pack blister card, 1 mL pre-filled syringe). Used for kit assembly planning and site dispensing instructions.',
    `quarantine_quantity` BIGINT COMMENT 'Number of units from this batch currently held in quarantine pending QP release or investigation. Tracked separately from available quantity for GMP accountability.',
    `recall_date` DATE COMMENT 'Date on which the recall of this batch was initiated. Populated only when recall_flag is True. Used for regulatory reporting timelines and site notification tracking.',
    `recall_flag` BOOLEAN COMMENT 'Indicates whether this batch has been subject to a product recall. True = batch recalled; False = no recall. Triggers urgent site notification, return logistics, and regulatory reporting obligations.',
    `release_date` DATE COMMENT 'Date on which the Qualified Person (QP) or authorized release authority formally released this batch for clinical use. Marks the transition from quarantine to released status and triggers downstream supply chain activities.',
    `release_status` STRING COMMENT 'Current GMP release status of the batch as determined by the Qualified Person (QP) or authorized release authority. Controls whether the batch may be shipped to depots or dispensed to subjects.. Valid values are `quarantine|released|rejected|recalled|destroyed|under_review`',
    `retest_date` DATE COMMENT 'Date by which the batch must be retested to confirm continued compliance with specifications before further use. Applicable for APIs and some drug products where retest rather than expiry dating is used.',
    `shelf_life_months` BIGINT COMMENT 'Approved shelf life of the IMP batch in months, as determined by stability data and declared in the product specification. Used to calculate and validate the expiry date relative to the manufacture date.',
    `source_system_batch_key` STRING COMMENT 'Native batch record identifier from the originating source system (e.g., Medidata Rave RTSM batch record ID, sponsor ERP batch key from the source system for data lineage, reconciliation, and ETL traceability between the lakehouse silver layer and',
    `sponsor_batch_reference` STRING COMMENT 'Sponsor-assigned reference number for this batch as provided in the sponsor batch release documentation. May differ from the manufacturing site batch number. Used for sponsor reconciliation and regulatory submissions.',
    `stability_study_reference` STRING COMMENT 'Reference identifier for the ICH stability study protocol under which this batch is enrolled for ongoing stability monitoring. Used to track shelf-life extensions and expiry date updates.',
    `storage_condition` STRING COMMENT 'Required storage condition for this IMP batch as specified in the product dossier and CoA. Drives cold-chain logistics planning, depot and site storage requirements, and temperature excursion monitoring.. Valid values are `room_temperature|refrigerated|frozen|ultra_frozen|controlled_room_temperature|protect_from_light`',
    `storage_temp_max_c` DECIMAL(5,2) COMMENT 'Maximum acceptable storage temperature in degrees Celsius for this IMP batch, as specified in the product specification. Used for cold-chain monitoring, temperature excursion assessment, and depot/site compliance verification.',
    `storage_temp_min_c` DECIMAL(5,2) COMMENT 'Minimum acceptable storage temperature in degrees Celsius for this IMP batch, as specified in the product specification. Used for cold-chain monitoring, temperature excursion assessment, and depot/site compliance verification.',
    `strength` STRING COMMENT 'Declared strength or concentration of the active pharmaceutical ingredient (API) per unit dose in this batch (e.g., 100 mg, 5 mg/mL). Used for dose verification and dispensing accountability.',
    `units_per_kit` BIGINT COMMENT 'Number of IMP units (e.g., tablets, vials) contained in each randomization kit assembled from this batch. Used by RTSM for kit assembly configuration and dispensing accountability calculations.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this manufacture batch record, in ISO 8601 format (yyyy-MM-ddTHH:mm:ss.SSSXXX). Required for change tracking, audit trail compliance, and incremental data pipeline processing.',
    CONSTRAINT pk_manufacture_batch PRIMARY KEY(`manufacture_batch_id`)
) COMMENT 'Records IMP manufacturing batch details including batch number, manufacturing date, batch size, manufacturing site, GMP certificate of analysis reference, release status (quarantine, released, rejected), expiry date, and storage conditions.';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`supply`.`shipment` (
    `shipment_id` BIGINT COMMENT 'Unique surrogate identifier for each IMP/kit shipment record in the clinical supply chain. Primary key for the shipment data product.',
    `audit_finding_id` BIGINT COMMENT 'Foreign key linking to compliance.audit_finding. Business justification: GDP audits produce findings against specific IMP shipments (cold chain documentation deficiency, import permit non-compliance). audit_finding has study_site_id but no shipment_id.',
    `clinical_trial_authorization_id` BIGINT COMMENT 'Foreign key linking to regulatory.clinical_trial_authorization. Business justification: EU/EEA IMP shipments to sites require a valid CTA in the destination member state before dispatch.',
    `country_id` BIGINT COMMENT 'Foreign key linking to study.study_country. Business justification: Shipments must be blocked to countries under regulatory hold. Linking shipment to study.study_country enables automated regulatory hold checks before dispatch, supports country-level',
    `irb_iec_approval_id` BIGINT COMMENT 'Foreign key linking to site.irb_iec_approval. Business justification: IMP dispatch to a site requires valid, current IRB/IEC approval. Regulatory auditors and supply chain teams must confirm ethics approval status before authorizing shipment.',
    `origin_depot_id` BIGINT COMMENT 'Foreign key linking to supply.depot. Business justification: Shipments originate from depots (depot-to-site or depot-to-depot shipments). shipment.origin_node_name is a denormalized string.',
    `site_file_id` BIGINT COMMENT 'Foreign key linking to document.site_file. Business justification: Shipment delivery confirmations and temperature excursion records are essential site file documents.',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to.',
    `study_site_id` BIGINT COMMENT 'Reference to the destination clinical site receiving the IMP shipment. Used for site-level inventory accountability and regulatory reconciliation.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: IMP shipment records (import permits, temperature monitoring logs, customs clearance documents) are essential TMF documents per ICH E6 R2.',
    `actual_delivery_date` DATE COMMENT 'The confirmed date on which the IMP shipment was received at the destination node. Used for delivery performance measurement, accountability reconciliation, and regulatory documentation.',
    `actual_delivery_timestamp` TIMESTAMP COMMENT 'Precise date and time the IMP shipment was confirmed received at the destination. Supports cold-chain total transit time calculations and ALCOA+ audit trail requirements.',
    `batch_number` STRING COMMENT 'Investigational Medicinal Product (IMP) manufacturing batch or lot number included in this shipment. Critical for product traceability, recall management, and regulatory accountability.',
    `carrier_name` STRING COMMENT 'Name of the logistics carrier or courier responsible for transporting the IMP shipment (e.g., World Courier, Marken, DHL). Required for cold-chain accountability and deviation investigation.',
    `cold_chain_logger_code` STRING COMMENT 'Unique identifier of the temperature data logger device placed in the shipment. Used to retrieve detailed temperature profiles from the logistics provider system for excursion investigation and regulatory documentation.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the shipment record was first created in the source RTSM system or lakehouse. Supports ALCOA+ audit trail requirements and data lineage tracking per 21 CFR Part 11.',
    `customs_clearance_date` DATE COMMENT 'Date on which customs clearance was obtained for the international IMP shipment. Used for transit time analysis and regulatory import documentation.',
    `customs_clearance_required` BOOLEAN COMMENT 'Indicates whether the shipment requires customs clearance due to international cross-border transit. Drives import/export documentation requirements and regulatory import permits for IMP.',
    `destination_node_name` STRING COMMENT 'Human-readable name of the supply chain destination node (e.g., site name, depot name). Supports logistics documentation and regulatory accountability records.',
    `destination_node_type` STRING COMMENT 'Type of supply chain node to which the shipment is directed (e.g., clinical site, central depot, manufacturer). Supports supply chain network mapping and inventory accountability.. Valid values are `manufacturer|depot|site|cro_warehouse`',
    `destruction_certificate_number` STRING COMMENT 'Certificate number issued upon confirmed destruction of returned or expired IMP. Required for regulatory accountability reconciliation and GMP compliance documentation.',
    `direction` STRING COMMENT 'Indicates the directional flow of the shipment: outbound (manufacturer/depot to site), inbound (site to depot/returns), or lateral (site to site). Supports supply chain node mapping and accountability.. Valid values are `outbound|inbound|lateral`',
    `dispatch_date` DATE COMMENT 'The date on which the IMP shipment was physically dispatched from the origin node. Represents the principal business event timestamp for outbound shipments. Used for lead-time calculations and regulatory documentation.',
    `dispatch_timestamp` TIMESTAMP COMMENT 'Precise date and time the IMP shipment was dispatched from the origin node. Supports cold-chain elapsed time calculations and ALCOA+ data integrity requirements.',
    `excursion_duration_minutes` BIGINT COMMENT 'Total cumulative duration in minutes during which the shipment temperature was outside the specified storage condition range. Used for product impact assessment and quality disposition decisions.',
    `expected_delivery_date` DATE COMMENT 'The planned date on which the IMP shipment is expected to arrive at the destination node. Used for site inventory planning, expiry management, and supply chain KPI monitoring.',
    `expiry_date` DATE COMMENT 'Expiration date of the IMP batch included in this shipment. Used for expiry management, re-test date tracking, and prevention of expired product administration to subjects.',
    `imp_description` STRING COMMENT 'Description of the investigational medicinal product (IMP) or comparator included in the shipment (e.g., drug name, formulation, strength). Supports accountability documentation and regulatory submissions.',
    `import_permit_number` STRING COMMENT 'Regulatory import permit or authorization number issued by the receiving countrys health authority for the IMP shipment. Required for cross-border clinical supply and regulatory compliance documentation.',
    `incoterms_code` STRING COMMENT 'International Commercial Terms (Incoterms) code defining the transfer of risk and responsibility between shipper and receiver for the IMP shipment. Governs insurance, customs, and cost allocation.',
    `kit_count` BIGINT COMMENT 'Total number of randomization kits included in this shipment as recorded in the RTSM (Medidata Rave). Core quantity field for inventory accountability and reconciliation.',
    `max_recorded_temp_c` DECIMAL(5,2) COMMENT 'Maximum temperature in degrees Celsius recorded by the cold-chain data logger during transit. Used to assess whether the IMP was exposed to excessive heat or out-of-range conditions.',
    `min_recorded_temp_c` DECIMAL(5,2) COMMENT 'Minimum temperature in degrees Celsius recorded by the cold-chain data logger during transit. Used to assess whether the IMP was exposed to freezing or sub-optimal low temperatures.',
    `notes` STRING COMMENT 'Free-text field for additional operational notes, special handling instructions, or comments related to the shipment (e.g., fragile contents, priority handling, deviation observations).',
    `number` STRING COMMENT 'Externally-known, human-readable shipment reference number generated by the RTSM (Medidata Rave) or logistics provider. Used for cross-system reconciliation, carrier communication, and regulatory accountability documentation.',
    `origin_node_name` STRING COMMENT 'Human-readable name of the supply chain origin node (e.g., depot name, manufacturer facility name, or site name). Supports logistics documentation and regulatory accountability records.',
    `origin_node_type` STRING COMMENT 'Type of supply chain node from which the shipment originates (e.g., manufacturer, central depot, clinical site, CRO warehouse). Used for supply chain network mapping and accountability.. Valid values are `manufacturer|depot|site|cro_warehouse`',
    `quarantine_flag` BOOLEAN COMMENT 'Indicates whether the shipment or its contents have been placed under quarantine pending quality investigation (e.g., following a temperature excursion or damaged packaging). Prevents dispensing of affected kits to subjects.',
    `rtsm_shipment_ref` STRING COMMENT 'Source system shipment reference identifier from the RTSM module (Medidata Rave). Used for cross-system reconciliation between the lakehouse silver layer and the operational RTSM system.',
    `shipment_status` STRING COMMENT 'Current lifecycle state of the IMP shipment within the clinical supply chain workflow. Drives accountability reconciliation and RTSM inventory updates. [ENUM-REF-CANDIDATE: planned|dispatched|in_transit|delivered|returned|destroyed|cancelled — promote to',
    `shipment_type` STRING COMMENT 'Classification of the shipment purpose within the clinical supply chain. Distinguishes initial site supply, resupply, site-to-site transfer, returns to depot, and emergency shipments.. Valid values are `initial_supply|resupply|return|destruction|transfer|emergency`',
    `storage_condition` STRING COMMENT 'Required storage temperature condition for the IMP during transit and at the destination (e.g., refrigerated 2-8°C, frozen -20°C, ambient 15-25°C). Drives cold-chain logistics requirements and excursion assessment.. Valid values are `ambient|refrigerated|frozen|controlled_room_temp|ultra_low`',
    `temperature_excursion_flag` BOOLEAN COMMENT 'Indicates whether a temperature excursion (deviation from required storage condition) was detected during transit. Triggers quality investigation, product impact assessment, and potential quarantine of affected kits.',
    `tracking_number` STRING COMMENT 'Carrier-assigned tracking number for the shipment. Used to monitor real-time transit status, confirm delivery, and investigate temperature excursions or delays.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the shipment record. Supports ALCOA+ audit trail requirements, change tracking, and data integrity compliance per 21 CFR Part 11.',
    `waybill_number` STRING COMMENT 'Air waybill (AWB) or bill of lading number issued by the carrier for the shipment. Used for customs documentation, carrier liability, and logistics traceability.',
    CONSTRAINT pk_shipment PRIMARY KEY(`shipment_id`)
) COMMENT 'Transactional record of IMP/kit shipments between supply chain nodes (manufacturer to depot, depot to site, site to site, site to depot for returns). Captures shipment number, origin, destination, carrier, tracking number, shipment date, expected delivery';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`supply`.`shipment_line` (
    `shipment_line_id` BIGINT COMMENT 'Unique surrogate identifier for each shipment line record within the IMP supply chain. Primary key for the shipment_line data product in the Databricks Silver Layer.',
    `arm_id` BIGINT COMMENT 'Foreign key linking to study.arm. Business justification: Shipment lines carry arm-specific kits; supply chain accountability and blinding verification require linking shipped quantities to protocol-defined treatment arms.',
    `depot_id` BIGINT COMMENT 'Reference to the supply depot or distribution center from which this shipment line was dispatched. Used for depot-level inventory depletion tracking and supply chain analytics.',
    `kit_definition_id` BIGINT COMMENT 'Foreign key linking to supply.kit_definition. Business justification: Each shipment line ships a specific kit type defined in kit_definition. shipment_line has kit_type (STRING) and imp_product_code (STRING) as denormalized fields, but no FK to',
    `kit_inventory_id` BIGINT COMMENT 'Reference to the randomization kit or IMP package unit included on this shipment line. Enables kit-level traceability from depot to site. TRANSACTION_LINE role: RESOURCE_REFERENCE category.',
    `manufacture_batch_id` BIGINT COMMENT 'Foreign key linking to supply.manufacture_batch. Business justification: Each shipment line ships a specific manufacturing batch/lot. shipment_line.lot_number is a denormalized batch identifier (lot_number and batch_number are synonymous in pharmaceutical',
    `rand_code_id` BIGINT COMMENT 'Foreign key linking to randomization.rand_code. Business justification: Each shipment line carries kits pre-assigned to randomization codes in RTSM. IMP accountability and regulatory inspection require direct traceability from shipped kit line to its',
    `shipment_id` BIGINT COMMENT 'Reference to the parent shipment header record. Establishes the header/detail relationship linking this line to its parent IMP shipment transaction. TRANSACTION_LINE role: HEADER_REFERENCE category.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this IMP shipment line is associated. Enables study-level supply accountability reporting and cross-domain analytics.',
    `study_site_id` BIGINT COMMENT 'Reference to the clinical trial site (destination) for this shipment line. Used for site-level inventory management, accountability reconciliation, and monitoring visit preparation.',
    `blinded` BOOLEAN COMMENT 'Indicates whether the IMP kit on this shipment line is blinded (True) or unblinded/open-label (False). Supports blinding integrity controls and restricts access to treatment assignment information per ICH E9 and GCP requirements.',
    `certificate_of_analysis_number` STRING COMMENT 'Reference number of the Certificate of Analysis (CoA) issued by the manufacturer for the IMP lot/batch on this shipment line. Required for GMP compliance and regulatory inspection readiness.',
    `cold_chain_required` BOOLEAN COMMENT 'Indicates whether the IMP on this shipment line requires cold-chain logistics management (True) or can be shipped at ambient temperature (False). Drives carrier selection, packaging requirements, and temperature monitoring obligations.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this shipment line record was first created in the system. Supports ALCOA+ audit trail requirements and data lineage tracking per 21 CFR Part 11 and ICH E6(R2) GCP.',
    `customs_declaration_number` STRING COMMENT 'Customs or import/export declaration number associated with this shipment line for cross-border IMP shipments. Required for regulatory compliance with import/export regulations and trade documentation.',
    `discrepancy_reason` STRING COMMENT 'Free-text explanation for any quantity discrepancy between shipped and received amounts on this line. Captured during site receipt confirmation and used for drug accountability investigation and CAPA tracking.',
    `dosage_form` STRING COMMENT 'Pharmaceutical dosage form of the IMP on this shipment line (e.g., TABLET, CAPSULE, INJECTION, INFUSION, PATCH, LIQUID). Used for cold-chain handling classification and dispensing instructions.. Valid values are `TABLET|CAPSULE|INJECTION|INFUSION|PATCH|LIQUID`',
    `expiry_date` DATE COMMENT 'Expiration date of the IMP lot/batch on this shipment line. Used for expiry management, site dispensing eligibility checks, and regulatory compliance. IMP must not be dispensed to subjects after this date.',
    `imp_description` STRING COMMENT 'Descriptive name or label text for the IMP on this shipment line, including formulation, strength, and dosage form as defined in the study protocol and IMP dossier.',
    `imp_product_code` STRING COMMENT 'Sponsor-assigned product code or study drug identifier for the Investigational Medicinal Product (IMP) on this shipment line. Aligns with the study protocols IMP definition and supply catalog.',
    `import_license_number` STRING COMMENT 'Import license or permit number required for cross-border shipment of IMP to the destination country. Applicable for regulated markets including EU, Japan (PMDA), Australia (TGA), and Canada (Health Canada).',
    `kit_number` STRING COMMENT 'Human-readable kit identifier assigned by the RTSM (Randomization and Trial Supply Management) system, such as Medidata Rave RTSM. Used for physical label matching and kit-level accountability reconciliation.',
    `line_notes` STRING COMMENT 'Free-text notes or comments specific to this shipment line, capturing any special handling instructions, site-specific requirements, or operational remarks not captured in structured fields.',
    `line_number` BIGINT COMMENT 'Sequential line number within the parent shipment, used to order and uniquely identify each line within a shipment transaction. TRANSACTION_LINE role: LINE_SEQUENCE category.',
    `line_status` STRING COMMENT 'Current workflow status of this shipment line, tracking progression from dispatch through site receipt confirmation. TRANSACTION_LINE role: LINE_VALUE_OR_RESULT category (status outcome).. Valid values are `PENDING|SHIPPED|RECEIVED|PARTIALLY_RECEIVED|REJECTED|CANCELLED`',
    `lot_number` STRING COMMENT 'Manufacturers lot or batch number assigned to the IMP units on this shipment line. Critical for drug accountability, recall traceability, and regulatory compliance per GMP requirements.',
    `manufacture_date` DATE COMMENT 'Date on which the IMP lot/batch on this shipment line was manufactured. Used for shelf-life calculation, stability tracking, and GMP compliance documentation.',
    `quantity_discrepancy` DECIMAL(18,4) COMMENT 'Difference between quantity_shipped and quantity_received for this shipment line. A non-zero value triggers a discrepancy investigation per drug accountability SOPs. Positive value indicates shortage; negative indicates overage.',
    `quantity_received` DECIMAL(18,4) COMMENT 'Actual quantity of IMP units confirmed as received at the destination site for this shipment line. May differ from quantity_shipped in cases of partial receipt, damage, or discrepancy. Used for accountability reconciliation.',
    `quantity_shipped` DECIMAL(18,4) COMMENT 'Number of units, kits, or packs of IMP dispatched on this shipment line. TRANSACTION_LINE role: LINE_QUANTITY category. Used for inventory depletion, accountability reconciliation, and supply planning.',
    `quarantine_status` STRING COMMENT 'Current quarantine status of the IMP on this shipment line. Values: NOT_QUARANTINED (available for dispensing), QUARANTINED (held pending quality review), RELEASED (released from quarantine after investigation), DESTROYED (disposed of due to quality. Valid values are `NOT_QUARANTINED|QUARANTINED|RELEASED|DESTROYED`',
    `receipt_confirmed` BOOLEAN COMMENT 'Indicates whether the receiving site has confirmed receipt of the IMP units on this shipment line. True = receipt confirmed by site personnel; False = receipt not yet confirmed. Supports drug accountability reconciliation.',
    `receipt_date` DATE COMMENT 'Date on which the receiving site confirmed receipt of the IMP units on this shipment line. Used for cold-chain compliance verification, accountability records, and site inventory updates.',
    `retest_date` DATE COMMENT 'Date by which the IMP lot/batch must be retested to confirm continued potency and stability before further use or dispensing. Applicable for certain IMP formulations per ICH stability guidelines.',
    `source_system_line_ref` STRING COMMENT 'Original line identifier or reference number from the source operational system (e.g., Medidata Rave RTSM shipment line ID or the source system item number). Enables traceability back to the system of record for audit and reconciliation purposes.',
    `storage_condition_code` STRING COMMENT 'Required storage condition for the IMP on this shipment line as specified in the IMP dossier. Drives cold-chain logistics requirements and site storage compliance monitoring.. Valid values are `AMBIENT|REFRIGERATED|FROZEN|CONTROLLED_ROOM_TEMP|PROTECT_FROM_LIGHT`',
    `strength` STRING COMMENT 'Strength or concentration of the IMP on this shipment line (e.g., 10 mg, 100 mg/mL). Captured as a string to accommodate varied unit expressions. Used for dispensing verification and protocol compliance.',
    `temperature_excursion_details` STRING COMMENT 'Free-text description of any temperature excursion recorded during transit for this shipment line, including duration, temperature range observed, and initial impact assessment. Populated only when temperature_excursion_flag is True.',
    `temperature_excursion_flag` BOOLEAN COMMENT 'Indicates whether a temperature excursion was recorded during transit for the IMP on this shipment line (True = excursion detected). Triggers quality investigation and potential quarantine of affected IMP per GDP and GMP requirements.',
    `unit_of_measure` STRING COMMENT 'Unit of measure for the quantity shipped on this line (e.g., KIT, VIAL, TABLET, CAPSULE, SYRINGE, PACK). Aligns with the IMP supply catalog and RTSM configuration.. Valid values are `KIT|VIAL|TABLET|CAPSULE|SYRINGE|PACK`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this shipment line record was last modified. Supports audit trail requirements and change tracking per 21 CFR Part 11 and ALCOA+ principles.',
    CONSTRAINT pk_shipment_line PRIMARY KEY(`shipment_line_id`)
) COMMENT 'Line-level detail for each IMP shipment, capturing individual kit numbers or batch quantities included in a shipment. Each line records the IMP/kit reference, quantity shipped, unit of measure, lot/batch number, expiry date, and line-level receipt';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` (
    `dispensing_record_id` BIGINT COMMENT 'Unique surrogate identifier for each investigational medicinal product (IMP) dispensing event record in the Databricks Silver Layer. Primary key for this entity.',
    `clinical_trial_authorization_id` BIGINT COMMENT 'Foreign key linking to regulatory.clinical_trial_authorization. Business justification: Each IMP dispensing event must occur under a valid CTA for the sites country.',
    `consent_subject_consent_id` BIGINT COMMENT 'Foreign key linking to consent.subject_consent. Business justification: GCP requires verified informed consent before any IMP dispensing. Linking dispensing_record to subject_consent enables inspection-ready drug accountability reports confirming every',
    `document_sop_id` BIGINT COMMENT 'Foreign key linking to document.document_sop. Business justification: IMP dispensing at clinical sites must follow an approved dispensing SOP (ICH GCP requirement).',
    `dosing_regimen_id` BIGINT COMMENT 'Foreign key linking to study.dosing_regimen. Business justification: GCP source data verification requires CRAs to validate each dispensing event against the protocol-specified dosing regimen (dose level, frequency, duration).',
    `enrollment_id` BIGINT COMMENT 'Foreign key linking to subject.enrollment. Business justification: IMP drug accountability and dosing compliance reporting require dispensing events to be directly linked to the enrollment record.',
    `icf_version_id` BIGINT COMMENT 'Foreign key linking to consent.consent_icf_version. Business justification: GCP requires dispensing staff to verify the subjects consent is current under the active ICF version before dispensing IMP.',
    `irt_transaction_id` BIGINT COMMENT 'Foreign key linking to randomization.irt_transaction. Business justification: Every dispensing event is confirmed via an IRT/RTSM transaction; GCP compliance and regulatory inspection require direct audit trail from dispensing record to IRT transaction.',
    `kit_assignment_id` BIGINT COMMENT 'Foreign key linking to randomization.kit_assignment. Business justification: kit_assignment is the IRT-side record of what was assigned; dispensing_record is the site-side record of what was physically given.',
    `kit_definition_id` BIGINT COMMENT 'Reference to the kit definition record that specifies the IMP kit type, dose strength, pack size, and labeling configuration dispensed. Links to supply.kit_definition for full kit specification.',
    `kit_inventory_id` BIGINT COMMENT 'Foreign key linking to supply.kit_inventory. Business justification: Each dispensing event dispenses a specific physical kit instance. dispensing_record.kit_number is a denormalized string identifier for the kit; adding kit_inventory_id creates a proper',
    `manufacture_batch_id` BIGINT COMMENT 'Foreign key linking to supply.manufacture_batch. Business justification: Each dispensing event uses IMP from a specific manufacturing batch (dispensing_record.batch_number is denormalized).',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: GCP requires dispensing records to be traceable to the protocol version in effect at time of dispensing for regulatory inspection readiness and CSR preparation.',
    `site_file_id` BIGINT COMMENT 'Foreign key linking to document.site_file. Business justification: Dispensing records are essential site file documents. Linking dispensing_record to site_file enables site file completeness tracking and supports CRA verification during monitoring visits',
    `site_inventory_id` BIGINT COMMENT 'Foreign key linking to supply.site_inventory. Business justification: A dispensing event draws IMP/kits from site inventory. Linking dispensing_record to the site_inventory record it drew from enables accurate inventory depletion tracking and drug',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to.',
    `study_visit_schedule_id` BIGINT COMMENT 'Foreign key linking to study.study_visit_schedule. Business justification: GCP requires that IP dispensing is verified against the protocol-defined visit schedule.',
    `subject_visit_data_id` BIGINT COMMENT 'Foreign key linking to datamanagement.subject_visit_data. Business justification: CRAs performing source data verification must cross-reference IMP dispensing events against eCRF visit-level data completeness and SDV status.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: IMP dispensing records are essential TMF documents per ICH E6 R2 Section 8. Linking dispensing_record to tmf_document enables TMF completeness tracking for IP accountability',
    `trial_subject_id` BIGINT COMMENT 'Reference to the enrolled trial subject who received the IMP dispensing. Core party reference for subject-level drug accountability and compliance with GCP requirements.',
    `visit_id` BIGINT COMMENT 'Reference to the scheduled or unscheduled study visit during which the IMP was dispensed. Links dispensing to the visit schedule for protocol compliance tracking.',
    `accountability_reconciled` BOOLEAN COMMENT 'Indicates whether this dispensing record has been included in and reconciled as part of the site-level drug accountability reconciliation (True) or is pending reconciliation (False). Required for study close-out and regulatory inspection readiness.',
    `batch_number` STRING COMMENT 'The manufacturing batch (lot) number of the IMP dispensed, as printed on the kit label. Required for drug accountability, pharmacovigilance traceability, and regulatory recall management. Aligns with GMP and GCP requirements.',
    `cold_chain_maintained` BOOLEAN COMMENT 'Indicates whether the cold chain storage and transport requirements were maintained for this IMP dispensing event (True) or a temperature excursion was recorded (False). Critical for temperature-sensitive biologics and vaccines.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this dispensing record was first created in the source system (Medidata Rave RTSM). Supports ALCOA+ audit trail requirements for contemporaneous data capture and 21 CFR Part 11 electronic record compliance.',
    `dispensed_by_name` STRING COMMENT 'Full name of the site staff member who performed the IMP dispensing, captured at time of dispensing for GCP audit trail. Stored as a denormalized field to preserve the historical record per ALCOA+ enduring data requirements even if staff records change.',
    `dispensed_by_role` STRING COMMENT 'The professional role of the staff member who performed the IMP dispensing (e.g., pharmacist, Clinical Research Coordinator (CRC), Principal Investigator (PI)).. Valid values are `pharmacist|crc|pi|sub_investigator|nurse|delegate`',
    `dispensing_date` DATE COMMENT 'The calendar date on which the IMP was dispensed to the subject. Derived from dispensing_timestamp for day-level reporting, protocol visit window compliance checks, and CDISC SDTM EX domain mapping.',
    `dispensing_method` STRING COMMENT 'The method by which the IMP dispensing was executed — whether via automated RTSM assignment, manual override (with justification), emergency supply, or backup procedure. Used for quality oversight and GCP compliance monitoring.. Valid values are `rtsm_automated|manual_override|emergency_supply|backup_procedure`',
    `dispensing_notes` STRING COMMENT 'Free-text notes or comments recorded by site staff at the time of dispensing, capturing any relevant observations, deviations, or special circumstances associated with this IMP dispensing event. Supports GCP audit trail and query resolution.',
    `dispensing_status` STRING COMMENT 'Current lifecycle status of this dispensing record. Tracks the workflow state from initial dispensing through return, destruction, or reconciliation for GCP drug accountability compliance.. Valid values are `dispensed|returned|partially_returned|destroyed|lost|reconciled`',
    `dispensing_timestamp` TIMESTAMP COMMENT 'The date and time at which the IMP was dispensed to the subject at the investigational site. Principal business event timestamp for this transaction. Recorded in ISO 8601 format with timezone offset per ALCOA+ requirements for contemporaneous data capture.',
    `dosage_form` STRING COMMENT 'The pharmaceutical dosage form of the IMP dispensed (e.g., tablet, capsule, injection). Required for drug accountability records and regulatory submissions. Aligns with IMP labeling and CDISC controlled terminology.',
    `dose_amount` DECIMAL(18,4) COMMENT 'The numeric dose amount of IMP dispensed to the subject for this dispensing event, expressed in the unit specified by dose_unit. Core quantitative field for pharmacokinetic (PK) analysis and protocol compliance verification.',
    `dose_number` BIGINT COMMENT 'Sequential dose number for this subject within the study, indicating which administration in the subjects treatment sequence this dispensing event represents (e.g., Dose 1, Dose 2). Used for protocol compliance and exposure analysis.',
    `dose_unit` STRING COMMENT 'Unit of measure for the dose amount dispensed (e.g., mg, mcg, mL, IU). Required for unambiguous dose interpretation in drug accountability, PK analysis, and CDISC SDTM EX domain submission.',
    `expiry_date` DATE COMMENT 'The expiration date of the IMP kit dispensed, as printed on the kit label. Captured at dispensing to verify that no expired product was administered and to support expiry management and drug accountability reconciliation.',
    `imp_name` STRING COMMENT 'The name of the investigational medicinal product dispensed, as defined in the study protocol and IMP labeling. May be blinded (e.g., Study Drug A) for double-blind studies. Used for drug accountability and regulatory reporting.',
    `is_unblinded` BOOLEAN COMMENT 'Indicates whether the blinding for this dispensing record has been broken (True) or remains blinded (False). Set to True only upon authorized emergency unblinding or at database lock (DBL).',
    `kit_number` STRING COMMENT 'The unique kit number (barcode or label identifier) of the IMP kit dispensed to the subject. Core drug accountability field used to trace individual kit units from depot to subject. Sourced from Medidata Rave RTSM.',
    `protocol_deviation_flag` BOOLEAN COMMENT 'Indicates whether this dispensing event was associated with a protocol deviation (True) or was compliant with the protocol (False). Triggers linkage to the compliance.protocol_deviation record for regulatory reporting and CAPA management.',
    `quantity_dispensed` DECIMAL(18,4) COMMENT 'The number of units (e.g., tablets, capsules, vials, syringes) of IMP dispensed to the subject in this dispensing event. Used for inventory depletion tracking, drug accountability reconciliation, and return quantity verification.',
    `quantity_returned` DECIMAL(18,4) COMMENT 'The number of IMP units returned by the subject at a subsequent visit, as recorded against this dispensing event. Used for drug accountability reconciliation to calculate actual consumption and compliance with protocol dosing instructions.',
    `quantity_unit` STRING COMMENT 'Unit of measure for the quantity dispensed (e.g., tablet, capsule, vial, syringe). Distinguishes the dispensing unit from the dose unit for accurate drug accountability and inventory reconciliation.',
    `reconciliation_date` DATE COMMENT 'The date on which this dispensing record was formally reconciled as part of the drug accountability reconciliation process. Populated when accountability_reconciled is True. Used for study close-out documentation and regulatory inspection readiness.',
    `return_date` DATE COMMENT 'The date on which unused IMP units from this dispensing event were returned by the subject to the site. Used for drug accountability reconciliation and calculation of subject compliance with dosing regimen.',
    `route_of_administration` STRING COMMENT 'The route by which the IMP was administered to the subject (e.g., oral, intravenous, subcutaneous). Required for CDISC SDTM EX domain submission and pharmacokinetic (PK) analysis.. Valid values are `oral|intravenous|subcutaneous|intramuscular|topical|inhalation`',
    `source_system_record_code` STRING COMMENT 'The native record identifier from the Medidata Rave RTSM dispensing module that corresponds to this dispensing event. Enables traceability back to the operational system of record for audit, reconciliation, and data lineage purposes per ALCOA+ and 21 CFR',
    `subject_compliance_pct` DECIMAL(5,2) COMMENT 'The calculated medication compliance percentage for this dispensing event, derived from quantity dispensed minus quantity returned divided by expected consumption, expressed as a percentage.',
    `temperature_excursion_flag` BOOLEAN COMMENT 'Indicates whether a temperature excursion was recorded for the IMP kit at or prior to this dispensing event (True) or not (False). When True, requires sponsor/QA assessment of IMP usability before dispensing is confirmed.',
    `unblinding_reason` STRING COMMENT 'The reason for breaking the blind on this dispensing record, if applicable. Populated only when is_unblinded is True. Required for GCP audit trail and regulatory reporting of unblinding events. Null when blinding is intact.. Valid values are `emergency_safety|dsmb_review|database_lock|regulatory_request|other`',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time when this dispensing record was last modified in the source system. Required for ALCOA+ audit trail compliance, change tracking, and incremental data pipeline processing in the Databricks Silver Layer.',
    CONSTRAINT pk_dispensing_record PRIMARY KEY(`dispensing_record_id`)
) COMMENT 'Captures each IMP dispensing event at an investigational site, recording the subject identifier, visit reference, kit number dispensed, IMP name, dose, quantity dispensed, dispensing date and time, dispensing staff, and RTSM confirmation number.';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`supply`.`return_record` (
    `return_record_id` BIGINT COMMENT 'Unique surrogate identifier for each IMP/kit return record in the supply chain accountability system.',
    `depot_id` BIGINT COMMENT 'Reference to the supply depot that is the destination for site-to-depot returns or the originating depot for expired stock returns.',
    `deviation_id` BIGINT COMMENT 'Foreign key linking to subject.subject_deviation. Business justification: Return discrepancies (quantity mismatch, blinding breach, damaged IMP) that generate protocol deviations must be traceable to the specific return event for GCP audit and CAPA',
    `dispensing_record_id` BIGINT COMMENT 'Foreign key linking to supply.dispensing_record. Business justification: A return record documents IMP returned by a subject, which is always associated with a prior dispensing event.',
    `document_sop_id` BIGINT COMMENT 'Foreign key linking to document.document_sop. Business justification: IMP return procedures are governed by GCP SOPs covering return conditions, reconciliation, and disposition.',
    `enrollment_id` BIGINT COMMENT 'Foreign key linking to subject.enrollment. Business justification: Drug accountability reconciliation requires returned IMP to be attributed to a specific enrollment episode.',
    `kit_definition_id` BIGINT COMMENT 'Reference to the kit definition record describing the IMP kit type, dosage form, and pack configuration associated with this return.',
    `kit_inventory_id` BIGINT COMMENT 'Foreign key linking to supply.kit_inventory. Business justification: Each return event returns a specific physical kit instance. return_record.kit_number is a denormalized string identifier; adding kit_inventory_id creates a proper FK to the physical kit',
    `manufacture_batch_id` BIGINT COMMENT 'Foreign key linking to supply.manufacture_batch. Business justification: Return records reference a specific manufacturing batch (return_record.batch_number is denormalized).',
    `quality_event_id` BIGINT COMMENT 'Foreign key linking to compliance.quality_event. Business justification: IMP returns with temperature excursions, damaged packaging, or quantity discrepancies trigger quality events.',
    `rand_code_id` BIGINT COMMENT 'Foreign key linking to randomization.rand_code. Business justification: Returned kits must be traced to their randomization code assignment for IMP accountability and unblinding risk assessment.',
    `shipment_id` BIGINT COMMENT 'Foreign key linking to supply.shipment. Business justification: Return shipments (site-to-depot) are tracked in the shipment table. return_record.shipment_tracking_number is a denormalized string; adding shipment_id creates a proper FK to the return',
    `site_file_id` BIGINT COMMENT 'Foreign key linking to document.site_file. Business justification: IMP return records are essential site file documents. Linking return_record to site_file enables site file completeness tracking and supports CRA verification during monitoring visits that',
    `site_inventory_id` BIGINT COMMENT 'Foreign key linking to supply.site_inventory. Business justification: A return event (subject returning IMP to site, or site returning to depot) affects the site_inventory stock position.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this IMP return is being documented. Links the return to the sponsoring protocol.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site initiating or receiving the return. Used for site-level drug accountability reconciliation.',
    `subject_randomization_id` BIGINT COMMENT 'Foreign key linking to randomization.subject_randomization. Business justification: IMP return reconciliation requires calculating compliance (quantity_used vs. expected dose per treatment arm) per randomization number.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: IMP return records and return authorization documents are essential TMF documents per ICH E6 R2.',
    `trial_subject_id` BIGINT COMMENT 'Reference to the trial subject returning IMP to the site. Nullable for site-to-depot or expired stock returns where no subject is involved.',
    `visit_id` BIGINT COMMENT 'Reference to the subject visit at which the IMP return was collected from the subject. Links the return event to the clinical visit schedule for compliance tracking.',
    `visit_report_id` BIGINT COMMENT 'Foreign key linking to monitoring.visit_report. Business justification: CRAs verify IP return logs during monitoring visits as a mandatory GCP accountability activity, documented in visit reports via ip_accountability_reviewed flag.',
    `withdrawal_id` BIGINT COMMENT 'Foreign key linking to consent.consent_withdrawal. Business justification: Consent withdrawal triggers mandatory IMP return per GCP and protocol. Linking return_record to consent_withdrawal enables direct traceability from withdrawal event to drug',
    `batch_number` STRING COMMENT 'Manufacturing batch or lot number of the returned IMP. Required for drug accountability, quality investigations, and regulatory submissions.',
    `blinding_intact` BOOLEAN COMMENT 'Indicates whether the blinding of the returned IMP kit was maintained at the time of return (True = blinding preserved; False = unblinding occurred or suspected). Critical for double-blind study integrity.',
    `comments` STRING COMMENT 'Free-text field for additional observations, notes, or contextual information recorded by site staff, CRA, or depot personnel regarding this return event. Supports ALCOA+ completeness requirements.',
    `courier_name` STRING COMMENT 'Name of the logistics or courier company responsible for transporting the returned IMP from site to depot. Required for GDP-compliant cold-chain documentation.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp recording when this return record was first created in the data platform. Part of the mandatory ALCOA+ audit trail for electronic records under 21 CFR Part 11.',
    `destruction_authorization_ref` STRING COMMENT 'Reference number or document identifier for the sponsor or depot authorization to destroy the returned IMP. Links to the destruction certificate in the eTMF (Veeva Vault). Required before any IMP destruction can proceed.',
    `destruction_date` DATE COMMENT 'Date on which the returned IMP was physically destroyed per the authorized destruction method. Completes the drug accountability lifecycle for the returned units.',
    `destruction_method` STRING COMMENT 'Method used to destroy the returned IMP, as specified in the protocol or sponsor instructions. Must comply with local environmental and pharmaceutical waste regulations.. Valid values are `incineration|chemical_neutralization|landfill|autoclave|pharmaceutical_waste`',
    `discrepancy_explanation` STRING COMMENT 'Free-text explanation provided by the site or CRA to account for any quantity discrepancy between dispensed and returned IMP. Required for regulatory audit trail when discrepancy_quantity is non-zero.',
    `discrepancy_quantity` BIGINT COMMENT 'Numeric difference between the expected return quantity (dispensed minus used) and the actual quantity returned. A non-zero value triggers a drug accountability discrepancy investigation.',
    `dispensing_unit` STRING COMMENT 'Unit of measure for the returned IMP (e.g., tablet, vial, syringe). Required for accurate drug accountability reconciliation across different dosage forms.',
    `expiry_date` DATE COMMENT 'Expiration date of the returned IMP as printed on the label. Used to confirm whether the product was within shelf life at the time of dispensing and return.',
    `kit_number` STRING COMMENT 'The unique RTSM-assigned kit number or barcode identifier for the specific IMP kit being returned. Enables unit-level drug accountability traceability.',
    `quantity_dispensed` BIGINT COMMENT 'Number of dispensing units originally dispensed to the subject or site for the associated kit. Stored on the return record to enable direct accountability reconciliation without joining to dispensing records.',
    `quantity_returned` BIGINT COMMENT 'Number of dispensing units (tablets, vials, syringes, etc.) returned. Used in drug accountability reconciliation to verify compliance with dispensing records.',
    `quantity_used` BIGINT COMMENT 'Number of dispensing units confirmed as consumed by the subject, calculated or reported at the time of return. Supports compliance and adherence analysis.',
    `receipt_date` DATE COMMENT 'Date on which the returned IMP or kit was physically received at the destination (site or depot). Used to calculate transit time and confirm chain of custody.',
    `reconciliation_date` DATE COMMENT 'Date on which the drug accountability reconciliation for this return was completed and confirmed by the responsible party (CRA or site staff).',
    `reconciliation_status` STRING COMMENT 'Status of the drug accountability reconciliation process for this return, tracking whether dispensed vs. returned quantities have been verified and any discrepancies resolved.. Valid values are `pending|in_progress|reconciled|discrepancy_identified|closed`',
    `return_condition` STRING COMMENT 'Physical condition of the IMP or kit at the time of return, as assessed by the site or depot receiving staff. Critical for determining disposition (destruction vs. re-use) and identifying cold-chain or handling failures.. Valid values are `intact|partially_used|damaged|tampered|temperature_excursion|expired`',
    `return_date` DATE COMMENT 'The actual calendar date on which the IMP or kit was physically returned by the subject to the site, or dispatched from the site to the depot. Principal business event date for drug accountability.',
    `return_number` STRING COMMENT 'Externally-known, human-readable business identifier for this return transaction, typically generated by the RTSM (Medidata Rave) or CTMS. Used for cross-system traceability and regulatory audit.',
    `return_reason` STRING COMMENT 'Narrative or coded reason for the return, such as study completion, subject withdrawal, protocol deviation, product expiry, or damaged packaging. Supports root cause analysis and supply planning.',
    `return_status` STRING COMMENT 'Current lifecycle state of the return record, tracking progression from initiation through receipt, reconciliation, and final destruction or disposition.. Valid values are `pending|in_transit|received|reconciled|destroyed|cancelled`',
    `return_type` STRING COMMENT 'Classification of the return event indicating the reason and direction of the return: subject returning unused IMP to site, site returning stock to depot, expired stock return, damaged stock return, or return triggered by a protocol deviation.. Valid values are `subject_return|site_to_depot|expired_stock|damaged_stock|protocol_deviation_return`',
    `rtsm_return_code` STRING COMMENT 'Source system identifier for this return transaction as recorded in the RTSM (Medidata Rave). Enables bidirectional traceability between the lakehouse silver layer and the operational RTSM system.',
    `shipment_tracking_number` STRING COMMENT 'Courier or logistics provider tracking number for the return shipment from site to depot. Enables cold-chain monitoring and chain-of-custody verification during transit.',
    `sponsor_notified_flag` BOOLEAN COMMENT 'Indicates whether the sponsor has been formally notified of this return event, particularly relevant for returns involving temperature excursions, damaged product, or significant quantity discrepancies.',
    `temperature_excursion_flag` BOOLEAN COMMENT 'Indicates whether a cold-chain temperature excursion was recorded or reported for the returned IMP during storage or transit (True = excursion occurred). Triggers quality investigation and potential destruction.',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp recording the most recent modification to this return record. Required for audit trail integrity and change tracking under 21 CFR Part 11 and ALCOA+ principles.',
    `verification_date` DATE COMMENT 'Date on which the CRA or pharmacist completed Source Data Verification (SDV) of the return record against source documents at the site or depot.',
    `verified_by` STRING COMMENT 'Name or identifier of the Clinical Research Associate (CRA) or pharmacist who verified the return quantities and condition during a monitoring visit or depot check. Supports Source Data Verification (SDV).',
    CONSTRAINT pk_return_record PRIMARY KEY(`return_record_id`)
) COMMENT 'Documents IMP/kit returns from subjects to sites and from sites to depots. Captures return type (subject return, site-to-depot, expired stock), kit numbers or quantities returned, return date, condition on return (intact, partially used, damaged)';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`supply`.`destruction_record` (
    `destruction_record_id` BIGINT COMMENT 'Unique surrogate identifier for each IMP/kit destruction record in the clinical supply chain. Primary key for this entity.',
    `clinical_trial_authorization_id` BIGINT COMMENT 'Foreign key linking to regulatory.clinical_trial_authorization. Business justification: EU CTA conditions require IMP destruction to be authorized and documented in compliance with CTA-specific requirements.',
    `depot_id` BIGINT COMMENT 'Foreign key linking to supply.depot. Business justification: IMP destruction often occurs at authorized depot facilities (destruction_authorized flag on depot). destruction_record.facility_name is a denormalized string.',
    `document_sop_id` BIGINT COMMENT 'Foreign key linking to document.document_sop. Business justification: IMP destruction must be performed per an approved SOP under GCP/GMP requirements. Linking destruction_record to the governing document_sop provides audit trail evidence that destruction',
    `imp_master_id` BIGINT COMMENT 'Reference to the IMP master record defining the drug product being destroyed. Enables linkage to dosage form, strength, and storage condition specifications.',
    `ind_application_id` BIGINT COMMENT 'Foreign key linking to regulatory.ind_application. Business justification: IMP destruction must be reported and traceable to the IND under which the product was used.',
    `kit_inventory_id` BIGINT COMMENT 'Foreign key linking to supply.kit_inventory. Business justification: A destruction event destroys specific kit inventory instances. destruction_record has kit_count_destroyed and kit_number_list (STRING) but no FK to kit_inventory.',
    `manufacture_batch_id` BIGINT COMMENT 'Foreign key linking to supply.manufacture_batch. Business justification: Destruction records reference a specific manufacturing batch (destruction_record.batch_number is denormalized).',
    `monitoring_plan_id` BIGINT COMMENT 'Foreign key linking to monitoring.monitoring_visit. Business justification: CRAs verify and witness IMP destruction during or following monitoring visits as a GCP regulatory requirement.',
    `quality_event_id` BIGINT COMMENT 'Foreign key linking to compliance.quality_event. Business justification: Destruction events with discrepancies (quantity mismatch, unauthorized destruction, missing witness signature) trigger quality events.',
    `return_record_id` BIGINT COMMENT 'Reference to the inbound return shipment record that delivered the IMP/kits to the destruction facility. Provides traceability from site return to destruction.',
    `site_file_id` BIGINT COMMENT 'Foreign key linking to document.site_file. Business justification: Destruction certificates are essential site file documents required for GCP inspection readiness.',
    `site_inventory_id` BIGINT COMMENT 'Foreign key linking to supply.site_inventory. Business justification: A destruction event depletes the site or depot inventory position. destruction_record has depot_id and study_site_id but no direct FK to site_inventory.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which the IMP/kit destruction is being recorded. Links destruction activity to the sponsoring protocol.',
    `study_site_id` BIGINT COMMENT 'Reference to the clinical site or depot facility from which the IMP/kits were returned and subsequently destroyed.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Certificate of Destruction is an ICH GCP essential TMF document (Section 8.4). Destruction records must be directly traceable to their filed TMF document for inspection readiness and',
    `authorization_date` DATE COMMENT 'Date on which the destruction was formally authorized by the sponsor or designated authority. Must precede the destruction_date to confirm proper authorization workflow.',
    `authorization_number` STRING COMMENT 'Externally assigned or sponsor-issued authorization number approving the destruction of the IMP/kits. Required for GCP audit trail and regulatory inspection readiness. Serves as the primary business identifier for this destruction event.',
    `batch_number` STRING COMMENT 'Manufacturing batch or lot number of the IMP being destroyed. Required for pharmaceutical traceability and post-destruction accountability reconciliation.',
    `certificate_issue_date` DATE COMMENT 'Date on which the Certificate of Destruction was formally issued by the destruction facility. May differ from the actual destruction date; both are required for complete GCP documentation.',
    `certificate_of_destruction_ref` STRING COMMENT 'Document reference number or identifier for the official Certificate of Destruction issued by the destruction facility. This document is a mandatory GCP audit trail artifact and must be filed in the Trial Master File (TMF).',
    `cold_chain_maintained` BOOLEAN COMMENT 'Indicates whether cold-chain temperature requirements were maintained during transport to the destruction facility (True) or a cold-chain excursion occurred (False). Relevant for temperature-sensitive IMP products.',
    `comments` STRING COMMENT 'Free-text field for additional notes, observations, or contextual information related to the destruction event not captured in structured fields. Supports GCP audit trail completeness.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this destruction record was first created in the system. Required for ALCOA+ audit trail compliance and 21 CFR Part 11 electronic record integrity.',
    `destruction_date` DATE COMMENT 'The actual calendar date on which the IMP/kits were physically destroyed. This is the principal real-world event date for the destruction transaction, distinct from authorization or record creation dates.',
    `destruction_method` STRING COMMENT 'The physical or chemical method used to destroy the IMP/kits (e.g., incineration, chemical neutralization). Must comply with applicable environmental and pharmaceutical waste regulations.. Valid values are `incineration|chemical_neutralization|autoclaving|landfill|pharmaceutical_waste_disposal|other`',
    `destruction_reason` STRING COMMENT 'The business reason driving the destruction of the IMP/kits (e.g., expired product, returned unused, rejected due to quality failure). Required for accountability reconciliation and regulatory reporting.',
    `destruction_status` STRING COMMENT 'Current lifecycle status of the destruction record, tracking progression from authorization request through completion or cancellation.. Valid values are `pending_authorization|authorized|in_progress|completed|cancelled`',
    `discrepancy_notes` STRING COMMENT 'Free-text description of any discrepancies identified between the quantity/kits expected for destruction and those actually destroyed. Required when reconciliation_status is discrepancy_identified or discrepancy_resolved.',
    `expiry_date` DATE COMMENT 'Expiration date of the IMP batch being destroyed. Relevant when destruction_reason is expired; used to confirm that expired product has been appropriately removed from the supply chain.',
    `facility_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the country where the destruction facility is located. Used for jurisdiction-specific regulatory compliance tracking.. Valid values are `^[A-Z]{3}$`',
    `facility_license_number` STRING COMMENT 'Regulatory license or permit number of the destruction facility, confirming it is authorized to handle and destroy pharmaceutical/IMP waste.',
    `facility_name` STRING COMMENT 'Name of the licensed facility (depot, third-party destruction vendor, or site) where the physical destruction was carried out.',
    `imp_name` STRING COMMENT 'Name or description of the Investigational Medicinal Product (IMP) being destroyed. Provides human-readable identification of the drug substance for audit and reporting purposes.',
    `is_blinded_destruction` BOOLEAN COMMENT 'Indicates whether the destruction was performed under blinded conditions (True) to preserve study integrity, or unblinded (False). Relevant for double-blind studies where kit contents must not be revealed during destruction.',
    `kit_count_destroyed` BIGINT COMMENT 'Number of randomization kits destroyed in this event, as tracked by the RTSM system. Distinct from quantity_destroyed which counts individual IMP units; kit count is the RTSM-level accountability unit.',
    `kit_number_list` STRING COMMENT 'Comma-separated or range-notation list of RTSM kit numbers included in this destruction event (e.g., KIT-001,KIT-002 or KIT-001 to KIT-050). Provides granular kit-level traceability for GCP audit and regulatory inspection.',
    `quantity_destroyed` BIGINT COMMENT 'Total number of IMP units (e.g., tablets, vials, syringes) destroyed in this destruction event. Used for accountability reconciliation against dispensed and returned quantities.',
    `quantity_unit` STRING COMMENT 'Unit of measure for the quantity destroyed (e.g., kit, vial, tablet). Ensures consistent accountability reconciliation across different IMP dosage forms. [ENUM-REF-CANDIDATE: kit|vial|tablet|capsule|syringe|blister_pack|bottle — 7 candidates stripped',
    `reconciliation_date` DATE COMMENT 'Date on which the IMP accountability reconciliation for this destruction event was completed and confirmed. Marks closure of the destruction accountability cycle.',
    `reconciliation_status` STRING COMMENT 'Status of the IMP accountability reconciliation for this destruction event, confirming that quantities destroyed match quantities returned and recorded in the RTSM. Required for GCP accountability and regulatory inspection.. Valid values are `pending|reconciled|discrepancy_identified|discrepancy_resolved`',
    `regulatory_notification_date` DATE COMMENT 'Date on which the regulatory authority was formally notified of the destruction event. Populated only when regulatory_notification_required is True.',
    `regulatory_notification_required` BOOLEAN COMMENT 'Indicates whether the destruction event requires formal notification to a regulatory authority (e.g., FDA, EMA, PMDA) per applicable regulations or study protocol requirements.',
    `rtsm_destruction_confirmation_code` STRING COMMENT 'Confirmation or transaction identifier generated by the RTSM system (Medidata Rave) when kit destruction is recorded in the randomization and trial supply management system.',
    `sponsor_representative` STRING COMMENT 'Name of the sponsor or CRO representative who oversaw or confirmed the destruction on behalf of the study sponsor. Relevant for multi-party accountability in outsourced destruction activities.',
    `temperature_excursion_noted` BOOLEAN COMMENT 'Indicates whether a temperature excursion was documented for the IMP prior to or during transport to destruction. Provides additional context for destruction_reason when product integrity was compromised.',
    `tmf_filing_status` STRING COMMENT 'Status of the Certificate of Destruction and supporting documentation filing in the Trial Master File (TMF) or electronic TMF (eTMF). Required for inspection readiness per ICH E6(R2) and TMF Reference Model.. Valid values are `not_filed|filed|verified`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this destruction record. Required for ALCOA+ audit trail compliance and 21 CFR Part 11 electronic record integrity.',
    `weight_destroyed_kg` DECIMAL(10,3) COMMENT 'Total weight in kilograms of the IMP/pharmaceutical waste destroyed. Required by some environmental and waste management regulations for pharmaceutical destruction reporting.',
    `witness_name` STRING COMMENT 'Full name of the qualified witness present during the physical destruction of the IMP/kits. Witness attestation is a GCP requirement for IMP destruction events.',
    `witness_signature_date` DATE COMMENT 'Date on which the witness signed the destruction record or certificate, confirming their presence during the destruction event. Required for ALCOA+ compliance.',
    `witness_title` STRING COMMENT 'Professional title or role of the destruction witness (e.g., QA Manager, Pharmacist, CRA). Confirms the witness has appropriate qualifications per GCP requirements.',
    CONSTRAINT pk_destruction_record PRIMARY KEY(`destruction_record_id`)
) COMMENT 'Records the destruction of returned, expired, or rejected IMP/kits. Captures destruction authorization number, destruction date, destruction method (incineration, chemical neutralization), facility, quantity and kit numbers destroyed, witness details, and';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` (
    `temperature_excursion_id` BIGINT COMMENT 'Unique surrogate identifier for each cold-chain temperature excursion event record in the clinical supply domain.',
    `capa_id` BIGINT COMMENT 'Foreign key linking to compliance.capa. Business justification: Temperature excursions with adverse disposition decisions require a formal CAPA under GMP/GCP.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.compliance_sop. Business justification: Temperature excursions are assessed against SLA thresholds for cold-chain compliance; breaches trigger SLA penalties.',
    `depot_id` BIGINT COMMENT 'Foreign key linking to supply.depot. Business justification: Temperature excursions can occur at depot storage facilities, not just during transit or at sites.',
    `inspection_finding_id` BIGINT COMMENT 'Foreign key linking to compliance.inspection_finding. Business justification: Temperature excursions inadequately resolved can be cited in regulatory inspection findings (inspector cites a specific excursion event as evidence of GDP non-compliance).',
    `kit_inventory_id` BIGINT COMMENT 'Reference to the investigational medicinal product (IMP) kit definition affected by this excursion. Links to kit_definition for storage condition thresholds and product identity.',
    `manufacture_batch_id` BIGINT COMMENT 'Foreign key linking to supply.manufacture_batch. Business justification: A temperature excursion affects specific manufacturing batches (temperature_excursion has affected_batch_numbers as a STRING field listing multiple batch numbers).',
    `monitoring_plan_id` BIGINT COMMENT 'Foreign key linking to monitoring.monitoring_plan. Business justification: Temperature excursion handling, disposition decisions, and CAPA requirements are governed by the monitoring plans escalation criteria and IP accountability requirements.',
    `quality_event_id` BIGINT COMMENT 'Foreign key linking to compliance.quality_event. Business justification: Temperature excursions in IMP supply are a primary trigger for quality events. temperature_excursion already links to compliance_capa and compliance_sop but not to the quality_event',
    `safety_report_submission_id` BIGINT COMMENT 'Foreign key linking to regulatory.safety_report_submission. Business justification: Temperature excursions affecting IMP integrity may trigger expedited safety reporting obligations to health authorities.',
    `shipment_id` BIGINT COMMENT 'Reference to the supply chain shipment record if the excursion occurred during in-transit logistics. Null if the excursion occurred at a static storage location (depot or site).',
    `specimen_id` BIGINT COMMENT 'Foreign key linking to laboratory.specimen. Business justification: GCP requires direct traceability from a temperature excursion event to affected biological specimens for disposition decisions (use/reject).',
    `study_id` BIGINT COMMENT 'Reference to the clinical study during which this temperature excursion occurred. Links the excursion to the governing protocol and sponsor.',
    `study_site_id` BIGINT COMMENT 'Reference to the clinical site or depot where the excursion was detected or occurred. Null if the excursion occurred in-transit between locations.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: Temperature excursion reports and impact assessments are essential TMF documents per ICH E6 R2.',
    `affected_batch_numbers` STRING COMMENT 'Comma-separated list of IMP manufacturing batch/lot numbers affected by this excursion. Required for traceability to the Certificate of Analysis (CoA) and stability data package submitted to the sponsor and regulatory authorities.',
    `affected_kit_count` BIGINT COMMENT 'Total number of IMP kits exposed to the temperature excursion. Used for impact scoping, supply replacement planning, and regulatory reporting.',
    `affected_kit_numbers` STRING COMMENT 'Comma-separated list of IMP kit numbers (as assigned in the RTSM/IRT system, e.g., Medidata Rave) that were exposed to the temperature excursion. Captured as a denormalized string for audit readiness; detailed kit-level records are maintained in the',
    `capa_required` BOOLEAN COMMENT 'Indicates whether a Corrective and Preventive Action (CAPA) has been determined to be required as a result of this excursion event. True = CAPA required; False = no CAPA required. Drives workflow integration with MasterControl CAPA tracking.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this temperature excursion record was first created in the system. Supports ALCOA+ audit trail requirements and data lineage tracking in the Databricks Lakehouse silver layer.',
    `data_logger_code` STRING COMMENT 'Unique identifier of the electronic temperature data logger or continuous monitoring device that recorded the excursion. Used for equipment traceability, calibration verification, and audit trail per 21 CFR Part 11 and EU GMP Annex 11.',
    `detection_source` STRING COMMENT 'The mechanism or system that first detected the temperature excursion: data_logger (electronic temperature logger device), continuous_monitor (real-time monitoring system), manual_check (routine manual temperature check), irt_alert (Interactive Response. Valid values are `data_logger|continuous_monitor|manual_check|irt_alert|courier_report|site_report`',
    `disposition_date` DATE COMMENT 'The date on which the sponsor or QA team formally issued the disposition decision for the affected IMP kits. Required for regulatory audit trail and supply chain accountability reconciliation.',
    `disposition_decision` STRING COMMENT 'The final disposition decision made by the sponsor or QA team following the impact assessment. Distinct from impact_assessment_outcome in that this represents the formal, authorized decision (which may differ from the initial assessment recommendation).. Valid values are `approved_for_use|quarantined|destroyed|returned|pending_sponsor_review`',
    `duration_minutes` BIGINT COMMENT 'Total elapsed time in minutes from excursion start to excursion end. Populated once the excursion is closed. Used by QA and the sponsor to assess cumulative thermal exposure against stability data.',
    `excursion_end_timestamp` TIMESTAMP COMMENT 'The date and time (ISO 8601 with timezone) at which the temperature returned within the acceptable range, marking the end of the excursion event. Null if the excursion is still ongoing at time of record creation.',
    `excursion_narrative` STRING COMMENT 'Free-text narrative describing the circumstances of the temperature excursion, including any contextual information provided by the site, depot, or courier at the time of detection. Supports GCP audit readiness and regulatory inspection documentation.',
    `excursion_number` STRING COMMENT 'Externally-known, human-readable reference number assigned to this excursion event, used in sponsor communications, QA investigations, and regulatory audit trails. Typically generated by the RTSM or CTMS system (e.g., Medidata Rave or the source system. Valid values are `^EXC-[A-Z0-9]{3,10}-[0-9]{4,8}$`',
    `excursion_start_timestamp` TIMESTAMP COMMENT 'The date and time (ISO 8601 with timezone) at which the temperature excursion began — i.e., when the temperature first breached the defined threshold. This is the principal real-world event time for the excursion.',
    `excursion_status` STRING COMMENT 'Current lifecycle status of the excursion event record. Drives QA workflow: open (newly detected), under_investigation (impact assessment in progress), pending_disposition (awaiting sponsor/QA decision), closed (disposition finalized), voided (false alarm. Valid values are `open|under_investigation|pending_disposition|closed|voided`',
    `excursion_type` STRING COMMENT 'Classification of the excursion by the nature of the breach: high_temperature (exceeded upper limit), low_temperature (fell below lower limit), freeze_thaw (frozen product that should not be), humidity (relative humidity breach), combined (multiple. Valid values are `high_temperature|low_temperature|freeze_thaw|humidity|combined`',
    `impact_assessment_outcome` STRING COMMENT 'The outcome of the scientific/QA impact assessment determining the usability of the affected IMP: use (product confirmed acceptable for continued use), quarantine (product held pending further evaluation), destroy (product deemed unusable and scheduled. Valid values are `use|quarantine|destroy|pending|return_to_sponsor`',
    `location_type` STRING COMMENT 'Categorizes where in the cold-chain the excursion occurred: depot (central or regional IMP warehouse), site (investigational site pharmacy or storage), in_transit (during shipment between locations), courier_hub (third-party logistics hub), customs (held. Valid values are `depot|site|in_transit|courier_hub|customs`',
    `logger_calibration_date` DATE COMMENT 'The most recent calibration date of the temperature data logger at the time of the excursion. Required to validate the reliability of the recorded temperature data for GCP audit readiness and regulatory submissions.',
    `lower_threshold_c` DECIMAL(6,2) COMMENT 'The minimum acceptable storage temperature (in degrees Celsius) defined for the affected IMP, as specified in the kit definition or product stability data. Breach of this threshold constitutes a low-temperature excursion.',
    `max_temp_recorded_c` DECIMAL(6,2) COMMENT 'The highest temperature value (in degrees Celsius) recorded during the excursion event. Used to assess the severity of a high-temperature excursion against product stability specifications.',
    `mean_kinetic_temp_c` DECIMAL(6,2) COMMENT 'The Mean Kinetic Temperature (MKT) in degrees Celsius calculated for the excursion period. MKT is the single calculated temperature that, if maintained over the storage period, would produce the same thermal stress as the actual temperature fluctuations.',
    `min_temp_recorded_c` DECIMAL(6,2) COMMENT 'The lowest temperature value (in degrees Celsius) recorded during the excursion event. Used to assess the severity of a low-temperature or freeze-thaw excursion against product stability specifications.',
    `replacement_kits_required` BOOLEAN COMMENT 'Indicates whether replacement IMP kits need to be dispatched to the affected site or depot as a result of the disposition decision (e.g., quarantine or destroy outcome). Drives supply replenishment workflow in the RTSM (Medidata Rave).',
    `reported_by` STRING COMMENT 'Name or user identifier of the person (e.g., CRC, CRA, site pharmacist, depot manager) who first reported or logged the temperature excursion into the system. Supports ALCOA+ attributability requirements.',
    `reported_timestamp` TIMESTAMP COMMENT 'The date and time when the excursion was formally reported or entered into the system. May differ from excursion_start_timestamp if there was a delay in detection or reporting. Supports ALCOA+ contemporaneity assessment.',
    `root_cause_category` STRING COMMENT 'High-level categorization of the root cause identified during the CAPA or investigation process: equipment_failure (refrigeration/monitoring device malfunction), process_failure (SOP not followed), human_error (incorrect handling), logistics_failure. Valid values are `equipment_failure|process_failure|human_error|logistics_failure|environmental|unknown`',
    `root_cause_description` STRING COMMENT 'Detailed narrative description of the identified root cause of the temperature excursion, as documented during the QA investigation. Supports CAPA development and regulatory inspection readiness.',
    `rtsm_excursion_reference` STRING COMMENT 'The excursion or alert reference identifier as recorded in the RTSM system (Medidata Rave IRT/RTSM module). Used for cross-system traceability between the lakehouse silver layer and the operational source system.',
    `sponsor_notification_date` DATE COMMENT 'The date on which the sponsor was formally notified of the temperature excursion. Null if sponsor_notification_required is False or notification has not yet been sent. Used to track compliance with contractual and regulatory notification timelines.',
    `sponsor_notification_required` BOOLEAN COMMENT 'Indicates whether the sponsor must be formally notified of this excursion per the clinical supply agreement or protocol requirements. True = notification required; False = not required (e.g., minor excursion within pre-defined acceptable limits).',
    `stability_data_reviewed` BOOLEAN COMMENT 'Indicates whether the product stability data (from the Investigational Medicinal Product Dossier or stability package) was formally reviewed as part of the impact assessment for this excursion. True = reviewed; False = not yet reviewed.',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time when this temperature excursion record was most recently modified. Supports audit trail requirements and incremental data processing in the Databricks Lakehouse silver layer.',
    `upper_threshold_c` DECIMAL(6,2) COMMENT 'The maximum acceptable storage temperature (in degrees Celsius) defined for the affected IMP, as specified in the kit definition or product stability data. Breach of this threshold constitutes a high-temperature excursion.',
    CONSTRAINT pk_temperature_excursion PRIMARY KEY(`temperature_excursion_id`)
) COMMENT 'Records cold-chain temperature excursion events detected during IMP storage or transit. Captures excursion start and end timestamps, affected location (depot, site, in-transit), temperature range breached, duration, affected kit/batch numbers, impact';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` (
    `accountability_reconciliation_id` BIGINT COMMENT 'Unique surrogate identifier for the drug accountability reconciliation record. Primary key for this entity. Entity role: TRANSACTION_HEADER — periodic reconciliation event with a defined lifecycle (open → reconciled / discrepancy-flagged).',
    `application_id` BIGINT COMMENT 'Foreign key linking to regulatory.application. Business justification: IMP accountability reconciliation is a contractual obligation defined in the study contract.',
    `arm_id` BIGINT COMMENT 'Foreign key linking to study.arm. Business justification: GCP requires IMP accountability reconciliation at the treatment arm level — dispensed, returned, and destroyed quantities must balance per arm.',
    `clinical_trial_authorization_id` BIGINT COMMENT 'Foreign key linking to regulatory.clinical_trial_authorization. Business justification: IMP accountability reconciliation is a CTA-specific regulatory obligation.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.compliance_sop. Business justification: Accountability reconciliation reports are formal SOW deliverables with acceptance criteria, billing milestone linkage, and TMF filing requirements.',
    `imp_master_id` BIGINT COMMENT 'Reference to the investigational medicinal product (IMP) being reconciled. A single reconciliation record covers one IMP or comparator product at the site for the period.',
    `ind_application_id` BIGINT COMMENT 'Foreign key linking to regulatory.ind_application. Business justification: IND annual reports require IMP accountability data aggregated by IND. Reconciliation records must reference the IND to support annual report preparation and FDA inspection',
    `inspection_finding_id` BIGINT COMMENT 'Foreign key linking to compliance.inspection_finding. Business justification: Regulatory inspectors (FDA, EMA) routinely issue findings against IMP accountability records.',
    `kit_definition_id` BIGINT COMMENT 'Foreign key linking to supply.kit_definition. Business justification: Drug accountability reconciliation is performed at the kit type level — reconciling quantities dispensed, returned, and destroyed for a specific kit definition.',
    `monitoring_plan_id` BIGINT COMMENT 'Reference to the monitoring visit during which this drug accountability reconciliation was performed or reviewed by the Clinical Research Associate (CRA). Null if reconciliation is performed outside a scheduled monitoring visit (e.g., at Database Lock).',
    `monitoring_visit_schedule_id` BIGINT COMMENT 'Foreign key linking to monitoring.monitoring_visit_schedule. Business justification: IP accountability reconciliation is a scheduled CRA activity performed during monitoring visits per the monitoring visit schedule.',
    `protocol_deviation_id` BIGINT COMMENT 'Foreign key linking to compliance.protocol_deviation. Business justification: Accountability reconciliation discrepancies (missing kits, quantity mismatch) are a direct trigger for protocol deviation reporting under GCP.',
    `quality_event_id` BIGINT COMMENT 'Foreign key linking to compliance.quality_event. Business justification: Unresolved accountability reconciliation discrepancies are escalated as quality events under GCP.',
    `rand_scheme_id` BIGINT COMMENT 'Foreign key linking to randomization.rand_scheme. Business justification: IMP accountability reconciliation must validate that kit usage matches the allocation ratios and blinding rules defined in the randomization scheme.',
    `site_cra_assignment_id` BIGINT COMMENT 'Foreign key linking to site.site_cra_assignment. Business justification: Drug accountability reconciliation is performed by the assigned CRA during monitoring visits. The cra_name column is a denormalized reference to the CRA assignment.',
    `site_file_id` BIGINT COMMENT 'Foreign key linking to document.site_file. Business justification: IMP accountability reconciliation records are essential site file documents required for GCP inspection readiness.',
    `site_inventory_id` BIGINT COMMENT 'Foreign key linking to supply.site_inventory. Business justification: Drug accountability reconciliation is performed at the site level against the site inventory position.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this drug accountability reconciliation is performed. Links the reconciliation to the study protocol, IMP details, and regulatory submission context.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site at which this drug accountability reconciliation is conducted. Each reconciliation is site-specific and covers all IMP activity at that site for the defined period.',
    `tmf_document_id` BIGINT COMMENT 'Foreign key linking to document.tmf_document. Business justification: IMP accountability reconciliation is an ICH GCP essential TMF document (Section 8.3). The reconciliation record must link to its filed TMF document to support inspection readiness.',
    `actual_closing_balance_units` BIGINT COMMENT 'Physical count of IMP units on hand at the site at the end of the reconciliation period, as verified by the site staff and/or CRA during the monitoring visit. This is the ground-truth inventory count.',
    `adjusted_units` BIGINT COMMENT 'Net quantity adjustment applied to the reconciliation (positive or negative) to account for documented corrections such as data entry errors, kit relabeling, or sponsor-approved adjustments. Zero if no adjustments were made.',
    `comments` STRING COMMENT 'Free-text field for additional comments, observations, or contextual notes entered by the CRA, site staff, or data manager regarding this reconciliation. Supplements the discrepancy_detail field for general narrative.',
    `cra_signoff_date` DATE COMMENT 'The date on which the CRA / monitor signed off on this drug accountability reconciliation. Null if cra_signoff_flag is False.',
    `cra_signoff_flag` BOOLEAN COMMENT 'Indicates whether the Clinical Research Associate (CRA) / monitor has reviewed and signed off on this drug accountability reconciliation record. True = signed; False = pending. Required at every monitoring visit per ICH E6(R2).',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this drug accountability reconciliation record was first created in the system. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ (Attributable, Legible, Contemporaneous, Original, Accurate) principles.',
    `destroyed_units` BIGINT COMMENT 'Total quantity of IMP units destroyed at the site or returned to depot for destruction during the reconciliation period. Destruction must be documented per sponsor SOP and applicable regulations.',
    `discrepancy_count` BIGINT COMMENT 'Number of individual discrepancy line items identified during this reconciliation (e.g., missing kit, unaccounted return, dispensing record mismatch). Distinct from discrepancy_units which measures total quantity variance.',
    `discrepancy_detail` STRING COMMENT 'Free-text narrative describing the nature, root cause, and resolution status of identified discrepancies. Captured by the CRA or site staff. Required when discrepancy_count > 0. Supports regulatory inspection readiness and CAPA documentation.',
    `discrepancy_resolution_status` STRING COMMENT 'Current resolution status of identified discrepancies. not_applicable = no discrepancy found; open = discrepancy identified, investigation not started; under_investigation = root cause analysis in progress; resolved = discrepancy explained and. Valid values are `not_applicable|open|under_investigation|resolved|escalated`',
    `discrepancy_units` BIGINT COMMENT 'Quantity difference between expected_closing_balance_units and actual_closing_balance_units (actual minus expected). A non-zero value triggers discrepancy investigation. Positive = surplus; negative = shortage.',
    `dispensed_units` BIGINT COMMENT 'Total quantity of IMP units dispensed to subjects at the site during the reconciliation period. Sourced from dispensing records in Medidata Rave RTSM and eCRF dispensing logs.',
    `expected_closing_balance_units` BIGINT COMMENT 'Calculated expected closing balance: opening_balance_units + received_units - dispensed_units + returned_units - destroyed_units + adjusted_units. Used as the reference value against which the physical count is compared to identify discrepancies.',
    `expired_units_count` BIGINT COMMENT 'Number of IMP units that had expired as of the reconciliation period end date. Expired units must be quarantined and destroyed per sponsor SOP; their presence in usable inventory constitutes a protocol deviation.',
    `expiry_date_earliest` DATE COMMENT 'The earliest expiry date among all IMP units currently on hand at the site as of the reconciliation period end date. Used to flag impending expiry risk and trigger resupply or destruction actions.',
    `gcp_compliance_flag` BOOLEAN COMMENT 'Indicates whether this reconciliation record is fully compliant with GCP §8.3.13 requirements (both investigator and CRA sign-offs obtained, no unresolved discrepancies, all required fields populated). True = compliant; False = non-compliant or pending.',
    `inspection_ready_flag` BOOLEAN COMMENT 'Indicates whether this reconciliation record and its supporting documentation are complete and ready for regulatory inspection (FDA, EMA, MHRA, etc.). True = inspection-ready; False = documentation gaps exist. Supports eTMF completeness tracking.',
    `investigator_name` STRING COMMENT 'Full name of the Principal Investigator (PI) who signed off on this reconciliation. Captured at time of sign-off for audit trail integrity per ALCOA+ principles. Confidential as it identifies a named professional in a regulatory context.',
    `investigator_signoff_date` DATE COMMENT 'The date on which the Principal Investigator (PI) or delegated sub-investigator signed off on this drug accountability reconciliation. Null if investigator_signoff_flag is False.',
    `investigator_signoff_flag` BOOLEAN COMMENT 'Indicates whether the Principal Investigator (PI) or delegated sub-investigator has reviewed and signed off on this drug accountability reconciliation record. True = signed; False = pending. Required for GCP compliance and regulatory inspection readiness.',
    `next_reconciliation_due_date` DATE COMMENT 'The scheduled due date for the next drug accountability reconciliation at this site for this IMP. Derived from the monitoring visit schedule or protocol-defined reconciliation frequency. Used for proactive compliance tracking.',
    `opening_balance_units` BIGINT COMMENT 'The quantity of IMP units (e.g., tablets, vials, kits) on hand at the site at the start of the reconciliation period. Carried forward from the closing balance of the prior reconciliation period or from the initial receipt if this is the first period.',
    `period_end_date` DATE COMMENT 'The last calendar date of the reconciliation period covered by this record. Defines the closing boundary for all IMP transactions included in this reconciliation.',
    `period_start_date` DATE COMMENT 'The first calendar date of the reconciliation period covered by this record. Together with period_end_date, defines the window of IMP activity (receipts, dispensing, returns, destruction) being reconciled.',
    `protocol_deviation_flag` BOOLEAN COMMENT 'Indicates whether a protocol deviation was identified during this reconciliation (e.g., expired IMP dispensed, incorrect kit dispensed, dispensing outside visit window). True = deviation identified; False = no deviation.',
    `received_units` BIGINT COMMENT 'Total quantity of IMP units received at the site from the depot or sponsor during the reconciliation period. Sourced from shipment receipt records in Medidata Rave RTSM.',
    `reconciliation_date` DATE COMMENT 'The date on which the drug accountability reconciliation was physically performed (i.e., the date of the physical count and record review). This is the principal business event date for this transaction, distinct from sign-off dates.',
    `reconciliation_number` STRING COMMENT 'Externally-known, human-readable business identifier for this reconciliation record, typically generated by the RTSM or CTMS (e.g., RECON-SITE001-20240315). Used in monitoring reports, TMF filings, and regulatory inspection packages.. Valid values are `^RECON-[A-Z0-9]{3,10}-[0-9]{4,8}$`',
    `reconciliation_status` STRING COMMENT 'Current workflow status of the reconciliation record. open = in progress; reconciled = balances confirmed with no discrepancy; discrepancy_flagged = unresolved quantity mismatch requiring investigation; pending_review = awaiting CRA or. Valid values are `open|reconciled|discrepancy_flagged|pending_review|closed`',
    `reconciliation_type` STRING COMMENT 'Classification of the reconciliation trigger. routine_monitoring = performed at a scheduled CRA monitoring visit; pre_dbl = required prior to Database Lock (DBL); site_closeout = performed at study close-out; interim = ad hoc between visits. Valid values are `routine_monitoring|pre_dbl|site_closeout|interim|triggered`',
    `returned_units` BIGINT COMMENT 'Total quantity of IMP units returned from subjects to the site (unused or partially used) during the reconciliation period. Includes returns captured in Medidata Rave RTSM return logs.',
    `rtsm_reconciliation_ref` STRING COMMENT 'The reconciliation reference or transaction identifier assigned by the Randomization and Trial Supply Management (RTSM) system (Medidata Rave) for this accountability event. Enables traceability back to the source system record.',
    `source_document_ref` STRING COMMENT 'Reference identifier for the physical or electronic source document (e.g., drug accountability log, dispensing record binder, eTMF artifact ID in Veeva Vault) that supports this reconciliation record. Required for SDV and regulatory inspection.',
    `temperature_excursion_flag` BOOLEAN COMMENT 'Indicates whether any cold-chain temperature excursion was recorded for IMP stored at this site during the reconciliation period. True = at least one excursion event occurred; False = no excursion.',
    `unit_of_measure` STRING COMMENT 'The unit in which IMP quantities are counted and reconciled (e.g., kit, tablet, vial). Must be consistent with the dispensing unit defined in the kit definition and RTSM configuration.',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time when this drug accountability reconciliation record was most recently modified. Required for audit trail completeness under 21 CFR Part 11 and ALCOA+ principles. Tracks the last state change in the reconciliation lifecycle.',
    CONSTRAINT pk_accountability_reconciliation PRIMARY KEY(`accountability_reconciliation_id`)
) COMMENT 'Periodic drug accountability reconciliation record at the site level, capturing the reconciliation period, opening balance, receipts, dispensed quantities, returned quantities, destroyed quantities, closing balance, discrepancy count and detail';

CREATE OR REPLACE TABLE `clinical_trials_mvm`.`supply`.`resupply_order` (
    `resupply_order_id` BIGINT COMMENT 'Unique surrogate identifier for the resupply order record in the lakehouse silver layer. Primary key for this entity.',
    `application_id` BIGINT COMMENT 'Foreign key linking to regulatory.application. Business justification: Resupply orders are executed under the study contracts supply scope and purchase order terms.',
    `arm_id` BIGINT COMMENT 'Foreign key linking to study.arm. Business justification: Resupply orders are triggered per treatment arm when arm-specific stock falls below threshold. Supply managers must validate resupply quantities against arm-specific enrollment targets and dosing',
    `clinical_trial_authorization_id` BIGINT COMMENT 'Foreign key linking to regulatory.clinical_trial_authorization. Business justification: Resupply orders to EU/EEA sites require confirmation of valid CTA status in the destination member state before order approval and dispatch.',
    `ind_application_id` BIGINT COMMENT 'Foreign key linking to regulatory.ind_application. Business justification: Resupply orders for US-based studies must be traceable to the governing IND. FDA inspections require that all IMP supply activities reference the IND — resupply orders without IND',
    `kit_definition_id` BIGINT COMMENT 'Reference to the IMP kit type or kit definition being requested in this resupply order, as defined in the RTSM kit catalogue.',
    `protocol_id` BIGINT COMMENT 'Reference to the specific protocol version in effect at the time the resupply order was generated. Ensures supply is aligned with the current approved protocol and dosing schedule.',
    `shipment_id` BIGINT COMMENT 'Reference to the outbound shipment record created to fulfill this resupply order. Populated once the order transitions to a dispatched or fulfilled state.',
    `site_inventory_id` BIGINT COMMENT 'Foreign key linking to supply.site_inventory. Business justification: A resupply order is triggered when site inventory falls below the minimum stock threshold (stock_at_trigger, min_stock_threshold attributes on resupply_order).',
    `source_depot_id` BIGINT COMMENT 'Reference to the depot or distribution center from which the IMP kits will be dispatched to fulfill this resupply order. Supports depot-to-site and depot-to-depot supply chain tracking.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which the resupply order was generated. Links the order to the sponsoring protocol and IMP supply plan.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site or depot that triggered or is the destination of the resupply order. Identifies the requesting or receiving location in the supply chain.',
    `supply_plan_id` BIGINT COMMENT 'Reference to the IMP supply plan or forecast that this resupply order is fulfilling. Links operational orders back to strategic supply planning for variance analysis.',
    `treatment_arm_id` BIGINT COMMENT 'Reference to the study treatment arm for which the IMP kits are being resupplied. Ensures blinded or unblinded supply allocation aligns with randomization scheme.',
    `accountability_reconciled` BOOLEAN COMMENT 'Indicates whether the IMP kits in this resupply order have been reconciled in the drug accountability log at the receiving site or depot. Required for GCP compliance and regulatory inspection readiness.',
    `actual_delivery_date` DATE COMMENT 'Date on which the resupply shipment was confirmed as received at the destination site or depot. Used to calculate fulfillment lead time and identify supply delays.',
    `approval_date` DATE COMMENT 'Date on which the resupply order was reviewed and approved by the supply manager or depot coordinator prior to dispatch.',
    `blinding_level` STRING COMMENT 'Blinding status of the IMP kits in this resupply order. Determines handling, labelling, and access control requirements during supply chain operations.. Valid values are `open_label|single_blind|double_blind|triple_blind`',
    `cancellation_reason` STRING COMMENT 'Free-text explanation for why the resupply order was cancelled. Populated only when order_status is cancelled. Required for supply accountability and audit trail.',
    `cold_chain_required` BOOLEAN COMMENT 'Indicates whether the IMP kits in this resupply order require cold-chain logistics (temperature-controlled transport and storage). Drives courier selection and packaging requirements.',
    `courier_name` STRING COMMENT 'Name of the logistics provider or courier company assigned to transport the resupply shipment. Used for tracking, accountability, and vendor performance monitoring.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this resupply order record was first captured in the system of record. Supports audit trail and ALCOA+ data integrity requirements.',
    `expected_fulfillment_date` DATE COMMENT 'Target date by which the resupply order is expected to be delivered to the requesting site or depot, based on standard lead times and courier schedules.',
    `expiry_date_earliest` DATE COMMENT 'The earliest expiry date among the IMP kits included in this resupply order. Critical for expiry management to ensure kits will remain within shelf life for the expected dispensing window.',
    `is_emergency_override` BOOLEAN COMMENT 'Indicates whether this resupply order was processed as an emergency override, bypassing standard approval workflows due to critical patient supply risk. Triggers mandatory post-hoc documentation.',
    `min_stock_threshold` BIGINT COMMENT 'The minimum stock level (in units/kits) at the requesting site or depot that triggered the resupply order. Captured at the time of order creation for audit and analytics.',
    `order_comments` STRING COMMENT 'Free-text field for supply manager notes, special handling instructions, or contextual information related to this resupply order. Supports operational communication between depots and sites.',
    `order_date` TIMESTAMP COMMENT 'The date and time at which the resupply order was formally placed or triggered, either by the RTSM resupply algorithm or by a supply manager. This is the principal business event timestamp for the order.',
    `order_number` STRING COMMENT 'Human-readable, externally-known business identifier for the resupply order, typically generated by the RTSM (Medidata Rave) or supply management system. Used in communications with depots, couriers, and sponsors.. Valid values are `^RSO-[A-Z0-9]{3,10}-[0-9]{6,10}$`',
    `order_status` STRING COMMENT 'Current lifecycle state of the resupply order workflow, from initial trigger through fulfillment or cancellation. Drives operational dashboards and escalation logic.. Valid values are `draft|submitted|approved|dispatched|delivered|cancelled`',
    `quantity_approved` BIGINT COMMENT 'Number of IMP kits or units approved for dispatch after supply manager or depot review. May differ from quantity_requested due to stock availability or protocol constraints.',
    `quantity_requested` BIGINT COMMENT 'Number of IMP kits or units requested in this resupply order, as specified at the time of order creation by the RTSM algorithm or supply manager.',
    `quantity_shipped` BIGINT COMMENT 'Actual number of IMP kits or units included in the outbound shipment fulfilling this resupply order. Populated at dispatch and used for accountability reconciliation.',
    `quantity_unit` STRING COMMENT 'Unit of measure for the quantities specified in this resupply order (e.g., kit, vial, blister pack). Ensures consistent interpretation across depots and sites.. Valid values are `kit|vial|blister|bottle|syringe|sachet`',
    `reconciliation_date` DATE COMMENT 'Date on which the drug accountability reconciliation was completed for the IMP kits delivered under this resupply order. Populated when accountability_reconciled is True.',
    `requesting_location_type` STRING COMMENT 'Classifies whether the resupply order was initiated by an investigational site, a regional depot, or a central pharmacy. Determines routing and fulfillment logic.. Valid values are `site|depot|central_pharmacy`',
    `rtsm_order_reference` STRING COMMENT 'The native order reference or transaction ID assigned by the RTSM system (Medidata Rave) when the resupply order was generated. Used for cross-system reconciliation and audit.',
    `rtsm_trigger_rule` STRING COMMENT 'Identifier or name of the RTSM resupply algorithm rule that triggered this order (e.g., minimum stock level rule, days-of-supply threshold rule). Null for manually initiated orders.',
    `source_system_order_code` STRING COMMENT 'The native primary key or unique identifier of this resupply order in the originating source system (e.g., Medidata Rave RTSM internal order ID). Enables cross-system traceability and reconciliation.',
    `stock_at_trigger` BIGINT COMMENT 'Actual inventory count at the requesting site or depot at the moment the resupply order was triggered. Used to validate trigger logic and support supply accountability reconciliation.',
    `storage_condition` STRING COMMENT 'Required storage condition for the IMP kits in this resupply order during transit and at the destination. Determines packaging, courier, and handling instructions.. Valid values are `room_temperature|refrigerated|frozen|controlled_room_temperature`',
    `tracking_number` STRING COMMENT 'Courier-assigned tracking number for the shipment fulfilling this resupply order. Enables real-time shipment tracking and delivery confirmation.',
    `trigger_type` STRING COMMENT 'Indicates whether the resupply order was automatically triggered by the RTSM resupply algorithm (e.g., minimum stock threshold breach) or initiated manually by a supply manager or other authorized personnel.. Valid values are `rtsm_algorithm|manual_supply_manager|emergency_request|protocol_amendment`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this resupply order record. Used for change detection, ETL incremental loads, and audit compliance.',
    `urgency_level` STRING COMMENT 'Priority classification of the resupply order indicating the speed of fulfillment required. Emergency orders may trigger expedited cold-chain logistics and override standard lead times.. Valid values are `routine|urgent|emergency`',
    CONSTRAINT pk_resupply_order PRIMARY KEY(`resupply_order_id`)
) COMMENT 'Captures resupply order requests triggered by RTSM resupply algorithms or manual supply manager intervention. Records the requesting site or depot, IMP/kit type requested, quantity requested, urgency level, order date, expected fulfillment date';

ALTER SCHEMA `clinical_trials_mvm`.`supply` SET TAGS ('dbx_division' = 'operations');

ALTER SCHEMA `clinical_trials_mvm`.`supply` SET TAGS ('dbx_domain' = 'supply');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` SET TAGS ('dbx_domain' = 'supply');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` SET TAGS ('dbx_subdomain' = 'product_management');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `imp_master_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Medicinal Product (IMP) Master ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Pipeline Asset Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `audit_id` SET TAGS ('dbx_business_glossary_term' = 'Audit Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Labeling Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_business_glossary_term' = 'Special Designation Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `health_authority_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `ind_application_id` SET TAGS ('dbx_business_glossary_term' = 'Ind Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `investigational_product_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `regulatory_binder_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Binder Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `active_substance_name` SET TAGS ('dbx_business_glossary_term' = 'Active Substance Name (INN)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `active_substance_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `atc_code` SET TAGS ('dbx_business_glossary_term' = 'Anatomical Therapeutic Chemical (ATC) Classification Code');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `atc_code` SET TAGS ('dbx_value_regex' = '^[A-Z][0-9]{2}[A-Z]{2}[0-9]{2}$');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `blinding_type` SET TAGS ('dbx_value_regex' = 'open_label|single_blind|double_blind|triple_blind');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `destruction_method` SET TAGS ('dbx_business_glossary_term' = 'IMP Destruction Method');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `destruction_method` SET TAGS ('dbx_value_regex' = 'incineration|chemical_neutralisation|landfill|return_to_sponsor|other');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `dosage_form` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `gmp_certificate_number` SET TAGS ('dbx_business_glossary_term' = 'Good Manufacturing Practice (GMP) Certificate Number');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `impd_version` SET TAGS ('dbx_business_glossary_term' = 'Investigational Medicinal Product Dossier (IMPD) Version');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `is_biological` SET TAGS ('dbx_business_glossary_term' = 'Biological Product Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `is_cold_chain` SET TAGS ('dbx_business_glossary_term' = 'Cold-Chain Required Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `is_controlled_substance` SET TAGS ('dbx_business_glossary_term' = 'Controlled Substance Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `is_orphan_designated` SET TAGS ('dbx_business_glossary_term' = 'Orphan Drug Designation Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `manufacturer_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `manufacturer_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `max_storage_temp_c` SET TAGS ('dbx_business_glossary_term' = 'Maximum Storage Temperature (Celsius)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `max_storage_temp_c` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `min_storage_temp_c` SET TAGS ('dbx_business_glossary_term' = 'Minimum Storage Temperature (Celsius)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `min_storage_temp_c` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `ndc_code` SET TAGS ('dbx_business_glossary_term' = 'National Drug Code (NDC)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `ndc_code` SET TAGS ('dbx_value_regex' = '^[0-9]{4,5}-[0-9]{3,4}-[0-9]{1,2}$');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `product_code` SET TAGS ('dbx_business_glossary_term' = 'Investigational Medicinal Product (IMP) Product Code');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `product_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{3,30}$');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `product_name` SET TAGS ('dbx_business_glossary_term' = 'Investigational Medicinal Product (IMP) Product Name');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `product_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `product_status` SET TAGS ('dbx_business_glossary_term' = 'Investigational Medicinal Product (IMP) Product Status');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `product_status` SET TAGS ('dbx_value_regex' = 'active|inactive|discontinued|under_review');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `product_type` SET TAGS ('dbx_business_glossary_term' = 'Investigational Medicinal Product (IMP) Product Type');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `product_type` SET TAGS ('dbx_value_regex' = 'IMP|comparator|placebo|auxiliary_medicinal_product');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `retest_period_months` SET TAGS ('dbx_business_glossary_term' = 'Retest Period (Months)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `rtsm_product_code` SET TAGS ('dbx_business_glossary_term' = 'Randomization and Trial Supply Management (RTSM) Product Identifier');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `shelf_life_months` SET TAGS ('dbx_business_glossary_term' = 'Shelf Life (Months)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `sourcing_strategy` SET TAGS ('dbx_business_glossary_term' = 'IMP Sourcing Strategy');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `sourcing_strategy` SET TAGS ('dbx_value_regex' = 'manufactured|commercially_procured|over_the_counter|imported');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `storage_condition` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `strength_unit` SET TAGS ('dbx_business_glossary_term' = 'Strength Unit of Measure');

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ADD CONSTRAINT `fk_supply_kit_definition_imp_master_id` FOREIGN KEY (`imp_master_id`) REFERENCES `clinical_trials_mvm`.`supply`.`imp_master`(`imp_master_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` SET TAGS ('dbx_domain' = 'supply');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` SET TAGS ('dbx_subdomain' = 'product_management');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `arm_id` SET TAGS ('dbx_business_glossary_term' = 'Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `imp_master_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Medicinal Product (IMP) ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `investigational_product_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_blinding' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Kit Definition Approval Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `blinding_level` SET TAGS ('dbx_value_regex' = 'open_label|single_blind|double_blind|triple_blind');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `destruction_method` SET TAGS ('dbx_value_regex' = 'incineration|chemical_neutralization|landfill|return_to_sponsor|site_disposal');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `dispensing_unit` SET TAGS ('dbx_value_regex' = 'kit|bottle|blister|vial|syringe|sachet');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `dosage_form` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `is_blinded` SET TAGS ('dbx_business_glossary_term' = 'Is Blinded Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `is_comparator` SET TAGS ('dbx_business_glossary_term' = 'Is Comparator Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `is_rescue_medication` SET TAGS ('dbx_business_glossary_term' = 'Is Rescue Medication Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `kit_description` SET TAGS ('dbx_business_glossary_term' = 'Kit Definition Description');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `kit_name` SET TAGS ('dbx_business_glossary_term' = 'Kit Definition Name');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `kit_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `kit_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{3,30}$');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `kit_status` SET TAGS ('dbx_business_glossary_term' = 'Kit Definition Status');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `kit_status` SET TAGS ('dbx_value_regex' = 'draft|approved|active|superseded|retired');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `kit_type` SET TAGS ('dbx_value_regex' = 'drug|placebo|comparator|combination|device|ancillary');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `label_language_code` SET TAGS ('dbx_value_regex' = '^[a-z]{2}(-[A-Z]{2})?$');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `label_language_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `label_text` SET TAGS ('dbx_business_glossary_term' = 'Kit Label Text');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `manufacturing_site_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{2,20}$');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `max_storage_temp_c` SET TAGS ('dbx_business_glossary_term' = 'Maximum Storage Temperature (Celsius)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `max_storage_temp_c` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `min_storage_temp_c` SET TAGS ('dbx_business_glossary_term' = 'Minimum Storage Temperature (Celsius)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `min_storage_temp_c` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Modified Timestamp');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `randomization_scheme` SET TAGS ('dbx_value_regex' = 'stratified|blocked|minimization|adaptive|simple');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `retest_period_days` SET TAGS ('dbx_business_glossary_term' = 'Retest Period (Days)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `return_required` SET TAGS ('dbx_business_glossary_term' = 'Return Required Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `rtsm_kit_type_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_]{1,50}$');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `shelf_life_days` SET TAGS ('dbx_business_glossary_term' = 'Shelf Life (Days)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `storage_condition` SET TAGS ('dbx_value_regex' = 'room_temperature|refrigerated|frozen|controlled_room_temp|protect_from_light');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `storage_condition` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Kit Definition Version Number');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^d+.d+$');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ADD CONSTRAINT `fk_supply_kit_inventory_depot_id` FOREIGN KEY (`depot_id`) REFERENCES `clinical_trials_mvm`.`supply`.`depot`(`depot_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ADD CONSTRAINT `fk_supply_kit_inventory_kit_definition_id` FOREIGN KEY (`kit_definition_id`) REFERENCES `clinical_trials_mvm`.`supply`.`kit_definition`(`kit_definition_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ADD CONSTRAINT `fk_supply_kit_inventory_manufacture_batch_id` FOREIGN KEY (`manufacture_batch_id`) REFERENCES `clinical_trials_mvm`.`supply`.`manufacture_batch`(`manufacture_batch_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ADD CONSTRAINT `fk_supply_kit_inventory_shipment_id` FOREIGN KEY (`shipment_id`) REFERENCES `clinical_trials_mvm`.`supply`.`shipment`(`shipment_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` SET TAGS ('dbx_domain' = 'supply');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` SET TAGS ('dbx_subdomain' = 'inventory_control');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ALTER COLUMN `arm_id` SET TAGS ('dbx_business_glossary_term' = 'Study Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ALTER COLUMN `document_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Document Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ALTER COLUMN `dosing_regimen_id` SET TAGS ('dbx_business_glossary_term' = 'Dosing Regimen Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ALTER COLUMN `enrollment_id` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ALTER COLUMN `kit_definition_id` SET TAGS ('dbx_business_glossary_term' = 'Kit Definition Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ALTER COLUMN `manufacture_batch_id` SET TAGS ('dbx_business_glossary_term' = 'Manufacture Batch Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ALTER COLUMN `rand_code_id` SET TAGS ('dbx_business_glossary_term' = 'Rand Code Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ALTER COLUMN `subject_randomization_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Randomization Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ALTER COLUMN `accountability_reconciled` SET TAGS ('dbx_business_glossary_term' = 'Accountability Reconciled Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ALTER COLUMN `batch_number` SET TAGS ('dbx_business_glossary_term' = 'Batch Number (Lot Number)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ALTER COLUMN `batch_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{3,25}$');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ALTER COLUMN `blinding_status` SET TAGS ('dbx_value_regex' = 'blinded|unblinded|open_label');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ALTER COLUMN `cold_chain_compliant` SET TAGS ('dbx_business_glossary_term' = 'Cold Chain Compliant Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ALTER COLUMN `cold_chain_required` SET TAGS ('dbx_business_glossary_term' = 'Cold Chain Required Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Kit Comments');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ALTER COLUMN `current_location_type` SET TAGS ('dbx_value_regex' = 'depot|site|in_transit|destroyed|subject');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Kit Expiry Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ALTER COLUMN `kit_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{4,30}$');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ALTER COLUMN `randomization_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{3,20}$');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ALTER COLUMN `randomization_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ALTER COLUMN `rtsm_kit_code` SET TAGS ('dbx_business_glossary_term' = 'RTSM (Randomization and Trial Supply Management) Kit ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ALTER COLUMN `storage_condition` SET TAGS ('dbx_value_regex' = 'room_temperature|refrigerated|frozen|ultra_frozen|controlled_room_temperature');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ALTER COLUMN `storage_condition` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` SET TAGS ('dbx_domain' = 'supply');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` SET TAGS ('dbx_subdomain' = 'inventory_control');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `document_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Document Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `lab_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Subcontract Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `regulatory_binder_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Binder Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `address_line1` SET TAGS ('dbx_business_glossary_term' = 'Depot Address Line 1');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `address_line1` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `address_line1` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `address_line1` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `address_line2` SET TAGS ('dbx_business_glossary_term' = 'Depot Address Line 2');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `address_line2` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `address_line2` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `address_line2` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `ambient_storage_capacity_m3` SET TAGS ('dbx_business_glossary_term' = 'Ambient Storage Capacity (Cubic Metres)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `ambient_storage_capacity_m3` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `city` SET TAGS ('dbx_business_glossary_term' = 'Depot City');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `city` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `city` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `city` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `depot_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{2,20}$');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `cold_chain_qualified` SET TAGS ('dbx_business_glossary_term' = 'Cold Chain Qualified Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `controlled_substance_licensed` SET TAGS ('dbx_business_glossary_term' = 'Controlled Substance Licensed Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Depot Country Code');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `ctms_depot_code` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Depot ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `decommission_date` SET TAGS ('dbx_business_glossary_term' = 'Depot Decommission Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `depot_status` SET TAGS ('dbx_business_glossary_term' = 'Depot Operational Status');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `depot_status` SET TAGS ('dbx_value_regex' = 'active|inactive|qualified|suspended|decommissioned');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `depot_type` SET TAGS ('dbx_value_regex' = 'central|regional|local|satellite|returns');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `destruction_authorized` SET TAGS ('dbx_business_glossary_term' = 'IMP Destruction Authorized Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `erp_vendor_code` SET TAGS ('dbx_business_glossary_term' = 'Enterprise Resource Planning (ERP) Vendor ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `frozen_storage_capacity_m3` SET TAGS ('dbx_business_glossary_term' = 'Frozen Storage Capacity (Cubic Metres)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `frozen_storage_capacity_m3` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `gmp_certificate_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Good Manufacturing Practice (GMP) Certificate Expiry Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `gmp_certificate_number` SET TAGS ('dbx_business_glossary_term' = 'Good Manufacturing Practice (GMP) Certificate Number');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `gmp_certified` SET TAGS ('dbx_business_glossary_term' = 'Good Manufacturing Practice (GMP) Certified Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `last_audit_date` SET TAGS ('dbx_business_glossary_term' = 'Last Depot Audit Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `last_qualification_date` SET TAGS ('dbx_business_glossary_term' = 'Last Depot Qualification Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `depot_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `next_audit_due_date` SET TAGS ('dbx_business_glossary_term' = 'Next Depot Audit Due Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `next_qualification_due_date` SET TAGS ('dbx_business_glossary_term' = 'Next Depot Qualification Due Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Depot Notes');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `operational_start_date` SET TAGS ('dbx_business_glossary_term' = 'Depot Operational Start Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `postal_code` SET TAGS ('dbx_business_glossary_term' = 'Depot Postal Code');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `postal_code` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Depot Primary Contact Email');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Depot Primary Contact Name');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Depot Primary Contact Phone');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_value_regex' = '^+?[0-9s-().]{7,20}$');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `refrigerated_storage_capacity_m3` SET TAGS ('dbx_business_glossary_term' = 'Refrigerated Storage Capacity (Cubic Metres)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `refrigerated_storage_capacity_m3` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `returns_accepted` SET TAGS ('dbx_business_glossary_term' = 'IMP Returns Accepted Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `rtsm_depot_code` SET TAGS ('dbx_business_glossary_term' = 'Randomization and Trial Supply Management (RTSM) Depot Code');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `state_province` SET TAGS ('dbx_business_glossary_term' = 'Depot State or Province');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `state_province` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `state_province` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `state_province` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `time_zone` SET TAGS ('dbx_business_glossary_term' = 'Depot Time Zone');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ALTER COLUMN `wholesale_license_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Wholesale Distribution License Expiry Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ADD CONSTRAINT `fk_supply_site_inventory_depot_id` FOREIGN KEY (`depot_id`) REFERENCES `clinical_trials_mvm`.`supply`.`depot`(`depot_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ADD CONSTRAINT `fk_supply_site_inventory_imp_master_id` FOREIGN KEY (`imp_master_id`) REFERENCES `clinical_trials_mvm`.`supply`.`imp_master`(`imp_master_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ADD CONSTRAINT `fk_supply_site_inventory_kit_definition_id` FOREIGN KEY (`kit_definition_id`) REFERENCES `clinical_trials_mvm`.`supply`.`kit_definition`(`kit_definition_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ADD CONSTRAINT `fk_supply_site_inventory_manufacture_batch_id` FOREIGN KEY (`manufacture_batch_id`) REFERENCES `clinical_trials_mvm`.`supply`.`manufacture_batch`(`manufacture_batch_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ADD CONSTRAINT `fk_supply_site_inventory_receipt_shipment_id` FOREIGN KEY (`receipt_shipment_id`) REFERENCES `clinical_trials_mvm`.`supply`.`shipment`(`shipment_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` SET TAGS ('dbx_domain' = 'supply');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` SET TAGS ('dbx_subdomain' = 'inventory_control');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `arm_id` SET TAGS ('dbx_business_glossary_term' = 'Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `depot_id` SET TAGS ('dbx_business_glossary_term' = 'Depot Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `document_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Document Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `imp_master_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Medicinal Product (IMP) ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `kit_definition_id` SET TAGS ('dbx_business_glossary_term' = 'Kit Type ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `manufacture_batch_id` SET TAGS ('dbx_business_glossary_term' = 'Manufacture Batch Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `receipt_shipment_id` SET TAGS ('dbx_business_glossary_term' = 'Receipt Shipment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `site_file_id` SET TAGS ('dbx_business_glossary_term' = 'Site File Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_business_glossary_term' = 'Treatment Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `accountability_reconciled` SET TAGS ('dbx_business_glossary_term' = 'Accountability Reconciliation Completed Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `batch_number` SET TAGS ('dbx_business_glossary_term' = 'IMP Batch Number');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `blinding_level` SET TAGS ('dbx_business_glossary_term' = 'Study Blinding Level');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `blinding_level` SET TAGS ('dbx_value_regex' = 'open_label|single_blind|double_blind|triple_blind');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `destruction_authorized` SET TAGS ('dbx_business_glossary_term' = 'Destruction Authorization Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `destruction_date` SET TAGS ('dbx_business_glossary_term' = 'IMP Destruction Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'IMP Expiry Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `imp_unit_of_measure` SET TAGS ('dbx_value_regex' = 'kit|vial|tablet|capsule|syringe|ampoule');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `inventory_number` SET TAGS ('dbx_business_glossary_term' = 'Inventory Record Number');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `inventory_status` SET TAGS ('dbx_business_glossary_term' = 'Inventory Position Status');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `inventory_status` SET TAGS ('dbx_value_regex' = 'active|quarantined|depleted|closed|suspended');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `last_physical_count_qty` SET TAGS ('dbx_business_glossary_term' = 'Last Physical Count Quantity');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `last_shipment_date` SET TAGS ('dbx_business_glossary_term' = 'Last Shipment Receipt Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `location_type` SET TAGS ('dbx_business_glossary_term' = 'Supply Chain Location Type');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `location_type` SET TAGS ('dbx_value_regex' = 'site|depot|central_pharmacy|satellite_depot');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `maximum_stock_qty` SET TAGS ('dbx_business_glossary_term' = 'Maximum Stock Quantity');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `minimum_stock_qty` SET TAGS ('dbx_business_glossary_term' = 'Minimum Stock Quantity');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `qty_adjusted` SET TAGS ('dbx_business_glossary_term' = 'Quantity Adjusted');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `qty_allocated` SET TAGS ('dbx_business_glossary_term' = 'Quantity Allocated');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `qty_destroyed` SET TAGS ('dbx_business_glossary_term' = 'Quantity Destroyed');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `qty_dispensed` SET TAGS ('dbx_business_glossary_term' = 'Quantity Dispensed');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `qty_expired` SET TAGS ('dbx_business_glossary_term' = 'Quantity Expired');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `qty_on_hand` SET TAGS ('dbx_business_glossary_term' = 'Quantity On Hand');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `qty_quarantined` SET TAGS ('dbx_business_glossary_term' = 'Quantity Quarantined');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `qty_received` SET TAGS ('dbx_business_glossary_term' = 'Quantity Received');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `qty_returned` SET TAGS ('dbx_business_glossary_term' = 'Quantity Returned');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `reconciliation_date` SET TAGS ('dbx_business_glossary_term' = 'Accountability Reconciliation Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `reorder_point` SET TAGS ('dbx_business_glossary_term' = 'Reorder Point Quantity');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `reorder_qty` SET TAGS ('dbx_business_glossary_term' = 'Reorder Quantity');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `resupply_triggered` SET TAGS ('dbx_business_glossary_term' = 'Resupply Triggered Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `retest_date` SET TAGS ('dbx_business_glossary_term' = 'IMP Retest Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `rtsm_location_code` SET TAGS ('dbx_business_glossary_term' = 'Randomization and Trial Supply Management (RTSM) Location Code');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `storage_condition` SET TAGS ('dbx_business_glossary_term' = 'Storage Condition Requirement');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `storage_condition` SET TAGS ('dbx_value_regex' = 'room_temperature|refrigerated|frozen|ultra_frozen|controlled_room_temperature');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `storage_condition` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `storage_condition_compliant` SET TAGS ('dbx_business_glossary_term' = 'Storage Condition Compliance Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ALTER COLUMN `storage_condition_compliant` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ADD CONSTRAINT `fk_supply_supply_plan_imp_master_id` FOREIGN KEY (`imp_master_id`) REFERENCES `clinical_trials_mvm`.`supply`.`imp_master`(`imp_master_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` SET TAGS ('dbx_domain' = 'supply');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` SET TAGS ('dbx_subdomain' = 'site_operations');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Pipeline Asset Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `dosing_regimen_id` SET TAGS ('dbx_business_glossary_term' = 'Dosing Regimen Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `imp_master_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Medicinal Product (IMP) ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `ind_application_id` SET TAGS ('dbx_business_glossary_term' = 'Ind Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `interim_analysis_id` SET TAGS ('dbx_business_glossary_term' = 'Interim Analysis Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `investigational_product_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `rand_list_id` SET TAGS ('dbx_business_glossary_term' = 'Rand List Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `rand_scheme_id` SET TAGS ('dbx_business_glossary_term' = 'Rand Scheme Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `regulatory_binder_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Binder Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `risk_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Risk Assessment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `sample_size_calc_id` SET TAGS ('dbx_business_glossary_term' = 'Sample Size Calc Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `accountability_reconciliation_required` SET TAGS ('dbx_business_glossary_term' = 'Accountability Reconciliation Required Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Supply Plan Approval Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `blinding_type` SET TAGS ('dbx_value_regex' = 'open_label|single_blind|double_blind|triple_blind');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `cold_chain_required` SET TAGS ('dbx_business_glossary_term' = 'Cold Chain Required Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `destruction_plan_included` SET TAGS ('dbx_business_glossary_term' = 'Destruction Plan Included Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `dropout_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Dropout Rate Percentage');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `expiry_management_strategy` SET TAGS ('dbx_value_regex' = 'fifo|fefo|manual_review|rtsm_managed');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `expiry_management_strategy` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `forecasted_enrollment` SET TAGS ('dbx_business_glossary_term' = 'Forecasted Enrollment Count');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `horizon_end_date` SET TAGS ('dbx_business_glossary_term' = 'Plan Horizon End Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `horizon_start_date` SET TAGS ('dbx_business_glossary_term' = 'Plan Horizon Start Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Supply Plan Notes');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `overage_pct` SET TAGS ('dbx_business_glossary_term' = 'Overage Percentage');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `overage_pct` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `plan_number` SET TAGS ('dbx_business_glossary_term' = 'Supply Plan Number');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `plan_number` SET TAGS ('dbx_value_regex' = '^SP-[A-Z0-9]{3,10}-[0-9]{4}-[0-9]{3}$');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `planning_cycle` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|enrollment_milestone|ad_hoc');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `randomization_method` SET TAGS ('dbx_value_regex' = 'central|stratified|block|minimization|open_label');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `rtsm_plan_code` SET TAGS ('dbx_business_glossary_term' = 'Randomization and Trial Supply Management (RTSM) Plan ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `site_tier_scope` SET TAGS ('dbx_value_regex' = 'all|tier_1|tier_2|tier_3|high_enrolling|low_enrolling');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `storage_temperature_max_c` SET TAGS ('dbx_business_glossary_term' = 'Storage Temperature Maximum (Celsius)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `storage_temperature_max_c` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `storage_temperature_min_c` SET TAGS ('dbx_business_glossary_term' = 'Storage Temperature Minimum (Celsius)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `storage_temperature_min_c` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `supply_plan_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|active|superseded|cancelled');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `treatment_arms_count` SET TAGS ('dbx_blinding' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `treatment_arms_count` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `treatment_arms_count` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `treatment_arms_count` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `version` SET TAGS ('dbx_business_glossary_term' = 'Supply Plan Version');

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ALTER COLUMN `version` SET TAGS ('dbx_value_regex' = '^v[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ADD CONSTRAINT `fk_supply_manufacture_batch_imp_master_id` FOREIGN KEY (`imp_master_id`) REFERENCES `clinical_trials_mvm`.`supply`.`imp_master`(`imp_master_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ADD CONSTRAINT `fk_supply_manufacture_batch_supply_plan_id` FOREIGN KEY (`supply_plan_id`) REFERENCES `clinical_trials_mvm`.`supply`.`supply_plan`(`supply_plan_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` SET TAGS ('dbx_domain' = 'supply');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` SET TAGS ('dbx_subdomain' = 'product_management');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `manufacture_batch_id` SET TAGS ('dbx_business_glossary_term' = 'Manufacturing Batch ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `approval_id` SET TAGS ('dbx_business_glossary_term' = 'Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `capa_id` SET TAGS ('dbx_business_glossary_term' = 'Compliance Capa Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `imp_master_id` SET TAGS ('dbx_business_glossary_term' = 'Imp Master Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `ind_application_id` SET TAGS ('dbx_business_glossary_term' = 'Ind Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `investigational_product_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Product Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `rand_scheme_id` SET TAGS ('dbx_business_glossary_term' = 'Rand Scheme Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `regulatory_binder_id` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Binder Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `supply_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Supply Plan Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `batch_number` SET TAGS ('dbx_value_regex' = '^[A-Z0-9-]{3,30}$');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `batch_size_unit` SET TAGS ('dbx_business_glossary_term' = 'Batch Size Unit of Measure');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `batch_type` SET TAGS ('dbx_value_regex' = 'clinical|validation|stability|reference|reserve');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `blinding_type` SET TAGS ('dbx_value_regex' = 'open_label|single_blind|double_blind|triple_blind');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `cta_reference` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorisation (CTA) Reference');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `destruction_certificate_ref` SET TAGS ('dbx_business_glossary_term' = 'Destruction Certificate Reference');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `dosage_form` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `gmp_certificate_number` SET TAGS ('dbx_business_glossary_term' = 'Good Manufacturing Practice (GMP) Certificate Number');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `is_comparator` SET TAGS ('dbx_business_glossary_term' = 'Comparator Product Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `is_placebo` SET TAGS ('dbx_business_glossary_term' = 'Placebo Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `manufacture_date` SET TAGS ('dbx_business_glossary_term' = 'Manufacturing Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `manufacturing_site_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `manufacturing_site_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `release_date` SET TAGS ('dbx_business_glossary_term' = 'Batch Release Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `release_status` SET TAGS ('dbx_business_glossary_term' = 'Batch Release Status');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `release_status` SET TAGS ('dbx_value_regex' = 'quarantine|released|rejected|recalled|destroyed|under_review');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `shelf_life_months` SET TAGS ('dbx_business_glossary_term' = 'Shelf Life (Months)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `storage_condition` SET TAGS ('dbx_value_regex' = 'room_temperature|refrigerated|frozen|ultra_frozen|controlled_room_temperature|protect_from_light');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `storage_condition` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `storage_temp_max_c` SET TAGS ('dbx_business_glossary_term' = 'Maximum Storage Temperature (Celsius)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `storage_temp_max_c` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `storage_temp_min_c` SET TAGS ('dbx_business_glossary_term' = 'Minimum Storage Temperature (Celsius)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `storage_temp_min_c` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `strength` SET TAGS ('dbx_business_glossary_term' = 'IMP Strength');

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ADD CONSTRAINT `fk_supply_shipment_origin_depot_id` FOREIGN KEY (`origin_depot_id`) REFERENCES `clinical_trials_mvm`.`supply`.`depot`(`depot_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` SET TAGS ('dbx_domain' = 'supply');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` SET TAGS ('dbx_subdomain' = 'supply_logistics');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ALTER COLUMN `audit_finding_id` SET TAGS ('dbx_business_glossary_term' = 'Audit Finding Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ALTER COLUMN `country_id` SET TAGS ('dbx_business_glossary_term' = 'Study Country Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ALTER COLUMN `irb_iec_approval_id` SET TAGS ('dbx_business_glossary_term' = 'Irb Iec Approval Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ALTER COLUMN `origin_depot_id` SET TAGS ('dbx_business_glossary_term' = 'Origin Depot Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ALTER COLUMN `site_file_id` SET TAGS ('dbx_business_glossary_term' = 'Site File Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ALTER COLUMN `batch_number` SET TAGS ('dbx_business_glossary_term' = 'IMP Batch Number');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ALTER COLUMN `carrier_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ALTER COLUMN `cold_chain_logger_code` SET TAGS ('dbx_business_glossary_term' = 'Cold-Chain Data Logger ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ALTER COLUMN `customs_clearance_required` SET TAGS ('dbx_business_glossary_term' = 'Customs Clearance Required Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ALTER COLUMN `destination_node_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ALTER COLUMN `destination_node_type` SET TAGS ('dbx_value_regex' = 'manufacturer|depot|site|cro_warehouse');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ALTER COLUMN `direction` SET TAGS ('dbx_business_glossary_term' = 'Shipment Direction');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ALTER COLUMN `direction` SET TAGS ('dbx_value_regex' = 'outbound|inbound|lateral');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ALTER COLUMN `excursion_duration_minutes` SET TAGS ('dbx_business_glossary_term' = 'Temperature Excursion Duration (Minutes)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'IMP Expiry Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ALTER COLUMN `imp_description` SET TAGS ('dbx_business_glossary_term' = 'Investigational Medicinal Product (IMP) Description');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ALTER COLUMN `max_recorded_temp_c` SET TAGS ('dbx_business_glossary_term' = 'Maximum Recorded Temperature (Celsius)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ALTER COLUMN `min_recorded_temp_c` SET TAGS ('dbx_business_glossary_term' = 'Minimum Recorded Temperature (Celsius)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Shipment Notes');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ALTER COLUMN `origin_node_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ALTER COLUMN `origin_node_type` SET TAGS ('dbx_value_regex' = 'manufacturer|depot|site|cro_warehouse');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ALTER COLUMN `rtsm_shipment_ref` SET TAGS ('dbx_business_glossary_term' = 'Randomization and Trial Supply Management (RTSM) Shipment Reference');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ALTER COLUMN `shipment_type` SET TAGS ('dbx_value_regex' = 'initial_supply|resupply|return|destruction|transfer|emergency');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ALTER COLUMN `storage_condition` SET TAGS ('dbx_value_regex' = 'ambient|refrigerated|frozen|controlled_room_temp|ultra_low');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ALTER COLUMN `storage_condition` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ALTER COLUMN `tracking_number` SET TAGS ('dbx_business_glossary_term' = 'Carrier Tracking Number');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ALTER COLUMN `waybill_number` SET TAGS ('dbx_business_glossary_term' = 'Air Waybill / Bill of Lading Number');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` ADD CONSTRAINT `fk_supply_shipment_line_depot_id` FOREIGN KEY (`depot_id`) REFERENCES `clinical_trials_mvm`.`supply`.`depot`(`depot_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` ADD CONSTRAINT `fk_supply_shipment_line_kit_definition_id` FOREIGN KEY (`kit_definition_id`) REFERENCES `clinical_trials_mvm`.`supply`.`kit_definition`(`kit_definition_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` ADD CONSTRAINT `fk_supply_shipment_line_kit_inventory_id` FOREIGN KEY (`kit_inventory_id`) REFERENCES `clinical_trials_mvm`.`supply`.`kit_inventory`(`kit_inventory_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` ADD CONSTRAINT `fk_supply_shipment_line_manufacture_batch_id` FOREIGN KEY (`manufacture_batch_id`) REFERENCES `clinical_trials_mvm`.`supply`.`manufacture_batch`(`manufacture_batch_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` ADD CONSTRAINT `fk_supply_shipment_line_shipment_id` FOREIGN KEY (`shipment_id`) REFERENCES `clinical_trials_mvm`.`supply`.`shipment`(`shipment_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` SET TAGS ('dbx_domain' = 'supply');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` SET TAGS ('dbx_subdomain' = 'supply_logistics');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` ALTER COLUMN `arm_id` SET TAGS ('dbx_business_glossary_term' = 'Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` ALTER COLUMN `kit_definition_id` SET TAGS ('dbx_business_glossary_term' = 'Kit Definition Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` ALTER COLUMN `kit_inventory_id` SET TAGS ('dbx_business_glossary_term' = 'Kit ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` ALTER COLUMN `manufacture_batch_id` SET TAGS ('dbx_business_glossary_term' = 'Manufacture Batch Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` ALTER COLUMN `rand_code_id` SET TAGS ('dbx_business_glossary_term' = 'Rand Code Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` ALTER COLUMN `blinded` SET TAGS ('dbx_business_glossary_term' = 'Blinded Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` ALTER COLUMN `certificate_of_analysis_number` SET TAGS ('dbx_business_glossary_term' = 'Certificate of Analysis (CoA) Number');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` ALTER COLUMN `cold_chain_required` SET TAGS ('dbx_business_glossary_term' = 'Cold Chain Required Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` ALTER COLUMN `dosage_form` SET TAGS ('dbx_value_regex' = 'TABLET|CAPSULE|INJECTION|INFUSION|PATCH|LIQUID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` ALTER COLUMN `dosage_form` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` ALTER COLUMN `imp_description` SET TAGS ('dbx_business_glossary_term' = 'Investigational Medicinal Product (IMP) Description');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` ALTER COLUMN `imp_product_code` SET TAGS ('dbx_business_glossary_term' = 'Investigational Medicinal Product (IMP) Product Code');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` ALTER COLUMN `line_status` SET TAGS ('dbx_business_glossary_term' = 'Shipment Line Status');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` ALTER COLUMN `line_status` SET TAGS ('dbx_value_regex' = 'PENDING|SHIPPED|RECEIVED|PARTIALLY_RECEIVED|REJECTED|CANCELLED');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` ALTER COLUMN `lot_number` SET TAGS ('dbx_business_glossary_term' = 'Lot/Batch Number');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` ALTER COLUMN `quarantine_status` SET TAGS ('dbx_value_regex' = 'NOT_QUARANTINED|QUARANTINED|RELEASED|DESTROYED');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` ALTER COLUMN `receipt_confirmed` SET TAGS ('dbx_business_glossary_term' = 'Receipt Confirmed Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` ALTER COLUMN `source_system_line_ref` SET TAGS ('dbx_business_glossary_term' = 'Source System Line Reference');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` ALTER COLUMN `storage_condition_code` SET TAGS ('dbx_value_regex' = 'AMBIENT|REFRIGERATED|FROZEN|CONTROLLED_ROOM_TEMP|PROTECT_FROM_LIGHT');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` ALTER COLUMN `storage_condition_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` ALTER COLUMN `strength` SET TAGS ('dbx_business_glossary_term' = 'IMP Strength');

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_value_regex' = 'KIT|VIAL|TABLET|CAPSULE|SYRINGE|PACK');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ADD CONSTRAINT `fk_supply_dispensing_record_kit_definition_id` FOREIGN KEY (`kit_definition_id`) REFERENCES `clinical_trials_mvm`.`supply`.`kit_definition`(`kit_definition_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ADD CONSTRAINT `fk_supply_dispensing_record_kit_inventory_id` FOREIGN KEY (`kit_inventory_id`) REFERENCES `clinical_trials_mvm`.`supply`.`kit_inventory`(`kit_inventory_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ADD CONSTRAINT `fk_supply_dispensing_record_manufacture_batch_id` FOREIGN KEY (`manufacture_batch_id`) REFERENCES `clinical_trials_mvm`.`supply`.`manufacture_batch`(`manufacture_batch_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ADD CONSTRAINT `fk_supply_dispensing_record_site_inventory_id` FOREIGN KEY (`site_inventory_id`) REFERENCES `clinical_trials_mvm`.`supply`.`site_inventory`(`site_inventory_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` SET TAGS ('dbx_domain' = 'supply');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` SET TAGS ('dbx_subdomain' = 'site_operations');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `consent_subject_consent_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Consent Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `document_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Document Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `dosing_regimen_id` SET TAGS ('dbx_business_glossary_term' = 'Dosing Regimen Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `enrollment_id` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `icf_version_id` SET TAGS ('dbx_business_glossary_term' = 'Consent Icf Version Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `irt_transaction_id` SET TAGS ('dbx_business_glossary_term' = 'Irt Transaction Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `kit_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Kit Assignment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `kit_inventory_id` SET TAGS ('dbx_business_glossary_term' = 'Kit Inventory Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `manufacture_batch_id` SET TAGS ('dbx_business_glossary_term' = 'Manufacture Batch Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `site_file_id` SET TAGS ('dbx_business_glossary_term' = 'Site File Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `site_inventory_id` SET TAGS ('dbx_business_glossary_term' = 'Site Inventory Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `study_visit_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Study Visit Schedule Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `subject_visit_data_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Visit Data Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `visit_id` SET TAGS ('dbx_business_glossary_term' = 'Visit ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `accountability_reconciled` SET TAGS ('dbx_business_glossary_term' = 'Accountability Reconciled Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `cold_chain_maintained` SET TAGS ('dbx_business_glossary_term' = 'Cold Chain Maintained Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `dispensed_by_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `dispensed_by_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `dispensed_by_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `dispensed_by_role` SET TAGS ('dbx_value_regex' = 'pharmacist|crc|pi|sub_investigator|nurse|delegate');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `dispensing_method` SET TAGS ('dbx_value_regex' = 'rtsm_automated|manual_override|emergency_supply|backup_procedure');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `dispensing_status` SET TAGS ('dbx_value_regex' = 'dispensed|returned|partially_returned|destroyed|lost|reconciled');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `dosage_form` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `imp_name` SET TAGS ('dbx_business_glossary_term' = 'Investigational Medicinal Product (IMP) Name');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `imp_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `is_unblinded` SET TAGS ('dbx_business_glossary_term' = 'Is Unblinded Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `is_unblinded` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `route_of_administration` SET TAGS ('dbx_value_regex' = 'oral|intravenous|subcutaneous|intramuscular|topical|inhalation');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `source_system_record_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `subject_compliance_pct` SET TAGS ('dbx_business_glossary_term' = 'Subject Compliance Percentage');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `unblinding_reason` SET TAGS ('dbx_value_regex' = 'emergency_safety|dsmb_review|database_lock|regulatory_request|other');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `unblinding_reason` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ADD CONSTRAINT `fk_supply_return_record_depot_id` FOREIGN KEY (`depot_id`) REFERENCES `clinical_trials_mvm`.`supply`.`depot`(`depot_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ADD CONSTRAINT `fk_supply_return_record_dispensing_record_id` FOREIGN KEY (`dispensing_record_id`) REFERENCES `clinical_trials_mvm`.`supply`.`dispensing_record`(`dispensing_record_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ADD CONSTRAINT `fk_supply_return_record_kit_definition_id` FOREIGN KEY (`kit_definition_id`) REFERENCES `clinical_trials_mvm`.`supply`.`kit_definition`(`kit_definition_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ADD CONSTRAINT `fk_supply_return_record_kit_inventory_id` FOREIGN KEY (`kit_inventory_id`) REFERENCES `clinical_trials_mvm`.`supply`.`kit_inventory`(`kit_inventory_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ADD CONSTRAINT `fk_supply_return_record_manufacture_batch_id` FOREIGN KEY (`manufacture_batch_id`) REFERENCES `clinical_trials_mvm`.`supply`.`manufacture_batch`(`manufacture_batch_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ADD CONSTRAINT `fk_supply_return_record_shipment_id` FOREIGN KEY (`shipment_id`) REFERENCES `clinical_trials_mvm`.`supply`.`shipment`(`shipment_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ADD CONSTRAINT `fk_supply_return_record_site_inventory_id` FOREIGN KEY (`site_inventory_id`) REFERENCES `clinical_trials_mvm`.`supply`.`site_inventory`(`site_inventory_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` SET TAGS ('dbx_domain' = 'supply');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` SET TAGS ('dbx_subdomain' = 'site_operations');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ALTER COLUMN `deviation_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Deviation Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ALTER COLUMN `dispensing_record_id` SET TAGS ('dbx_business_glossary_term' = 'Dispensing Record Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ALTER COLUMN `document_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Document Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ALTER COLUMN `enrollment_id` SET TAGS ('dbx_business_glossary_term' = 'Enrollment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ALTER COLUMN `kit_inventory_id` SET TAGS ('dbx_business_glossary_term' = 'Kit Inventory Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ALTER COLUMN `manufacture_batch_id` SET TAGS ('dbx_business_glossary_term' = 'Manufacture Batch Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ALTER COLUMN `quality_event_id` SET TAGS ('dbx_business_glossary_term' = 'Quality Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ALTER COLUMN `rand_code_id` SET TAGS ('dbx_business_glossary_term' = 'Rand Code Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ALTER COLUMN `shipment_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ALTER COLUMN `site_file_id` SET TAGS ('dbx_business_glossary_term' = 'Site File Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ALTER COLUMN `site_inventory_id` SET TAGS ('dbx_business_glossary_term' = 'Site Inventory Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ALTER COLUMN `subject_randomization_id` SET TAGS ('dbx_business_glossary_term' = 'Subject Randomization Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_business_glossary_term' = 'Subject ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ALTER COLUMN `trial_subject_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ALTER COLUMN `visit_id` SET TAGS ('dbx_business_glossary_term' = 'Visit ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ALTER COLUMN `visit_report_id` SET TAGS ('dbx_business_glossary_term' = 'Visit Report Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ALTER COLUMN `withdrawal_id` SET TAGS ('dbx_business_glossary_term' = 'Consent Withdrawal Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ALTER COLUMN `blinding_intact` SET TAGS ('dbx_business_glossary_term' = 'Blinding Intact Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ALTER COLUMN `courier_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ALTER COLUMN `destruction_authorization_ref` SET TAGS ('dbx_business_glossary_term' = 'Destruction Authorization Reference');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ALTER COLUMN `destruction_method` SET TAGS ('dbx_value_regex' = 'incineration|chemical_neutralization|landfill|autoclave|pharmaceutical_waste');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_value_regex' = 'pending|in_progress|reconciled|discrepancy_identified|closed');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ALTER COLUMN `return_condition` SET TAGS ('dbx_value_regex' = 'intact|partially_used|damaged|tampered|temperature_excursion|expired');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ALTER COLUMN `return_status` SET TAGS ('dbx_value_regex' = 'pending|in_transit|received|reconciled|destroyed|cancelled');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ALTER COLUMN `return_type` SET TAGS ('dbx_value_regex' = 'subject_return|site_to_depot|expired_stock|damaged_stock|protocol_deviation_return');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ALTER COLUMN `rtsm_return_code` SET TAGS ('dbx_business_glossary_term' = 'Randomization and Trial Supply Management (RTSM) Return ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ALTER COLUMN `verified_by` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ALTER COLUMN `verified_by` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ALTER COLUMN `verified_by` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ADD CONSTRAINT `fk_supply_destruction_record_depot_id` FOREIGN KEY (`depot_id`) REFERENCES `clinical_trials_mvm`.`supply`.`depot`(`depot_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ADD CONSTRAINT `fk_supply_destruction_record_imp_master_id` FOREIGN KEY (`imp_master_id`) REFERENCES `clinical_trials_mvm`.`supply`.`imp_master`(`imp_master_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ADD CONSTRAINT `fk_supply_destruction_record_kit_inventory_id` FOREIGN KEY (`kit_inventory_id`) REFERENCES `clinical_trials_mvm`.`supply`.`kit_inventory`(`kit_inventory_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ADD CONSTRAINT `fk_supply_destruction_record_manufacture_batch_id` FOREIGN KEY (`manufacture_batch_id`) REFERENCES `clinical_trials_mvm`.`supply`.`manufacture_batch`(`manufacture_batch_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ADD CONSTRAINT `fk_supply_destruction_record_return_record_id` FOREIGN KEY (`return_record_id`) REFERENCES `clinical_trials_mvm`.`supply`.`return_record`(`return_record_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ADD CONSTRAINT `fk_supply_destruction_record_site_inventory_id` FOREIGN KEY (`site_inventory_id`) REFERENCES `clinical_trials_mvm`.`supply`.`site_inventory`(`site_inventory_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` SET TAGS ('dbx_domain' = 'supply');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` SET TAGS ('dbx_subdomain' = 'site_operations');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `depot_id` SET TAGS ('dbx_business_glossary_term' = 'Depot Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `document_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Document Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `imp_master_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Medicinal Product (IMP) ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `ind_application_id` SET TAGS ('dbx_business_glossary_term' = 'Ind Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `kit_inventory_id` SET TAGS ('dbx_business_glossary_term' = 'Kit Inventory Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `manufacture_batch_id` SET TAGS ('dbx_business_glossary_term' = 'Manufacture Batch Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `monitoring_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Visit Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `quality_event_id` SET TAGS ('dbx_business_glossary_term' = 'Quality Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `return_record_id` SET TAGS ('dbx_business_glossary_term' = 'Shipment Return ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `site_file_id` SET TAGS ('dbx_business_glossary_term' = 'Site File Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `site_inventory_id` SET TAGS ('dbx_business_glossary_term' = 'Site Inventory Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `authorization_date` SET TAGS ('dbx_business_glossary_term' = 'Destruction Authorization Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `authorization_number` SET TAGS ('dbx_business_glossary_term' = 'Destruction Authorization Number');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `batch_number` SET TAGS ('dbx_business_glossary_term' = 'IMP Batch Number');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `certificate_issue_date` SET TAGS ('dbx_business_glossary_term' = 'Certificate of Destruction Issue Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `certificate_of_destruction_ref` SET TAGS ('dbx_business_glossary_term' = 'Certificate of Destruction Reference');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `cold_chain_maintained` SET TAGS ('dbx_business_glossary_term' = 'Cold Chain Maintained Indicator');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Destruction Record Comments');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `destruction_method` SET TAGS ('dbx_value_regex' = 'incineration|chemical_neutralization|autoclaving|landfill|pharmaceutical_waste_disposal|other');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `destruction_status` SET TAGS ('dbx_business_glossary_term' = 'Destruction Record Status');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `destruction_status` SET TAGS ('dbx_value_regex' = 'pending_authorization|authorized|in_progress|completed|cancelled');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'IMP Expiry Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `facility_country_code` SET TAGS ('dbx_business_glossary_term' = 'Destruction Facility Country Code');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `facility_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `facility_license_number` SET TAGS ('dbx_business_glossary_term' = 'Destruction Facility License Number');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `facility_name` SET TAGS ('dbx_business_glossary_term' = 'Destruction Facility Name');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `facility_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `imp_name` SET TAGS ('dbx_business_glossary_term' = 'Investigational Medicinal Product (IMP) Name');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `imp_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `is_blinded_destruction` SET TAGS ('dbx_business_glossary_term' = 'Blinded Destruction Indicator');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `kit_number_list` SET TAGS ('dbx_business_glossary_term' = 'Destroyed Kit Number List');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `quantity_unit` SET TAGS ('dbx_business_glossary_term' = 'Quantity Unit of Measure');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `reconciliation_date` SET TAGS ('dbx_business_glossary_term' = 'Accountability Reconciliation Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_business_glossary_term' = 'Accountability Reconciliation Status');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_value_regex' = 'pending|reconciled|discrepancy_identified|discrepancy_resolved');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `regulatory_notification_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Notification Required Indicator');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `rtsm_destruction_confirmation_code` SET TAGS ('dbx_business_glossary_term' = 'RTSM Destruction Confirmation ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `sponsor_representative` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `sponsor_representative` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `sponsor_representative` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `temperature_excursion_noted` SET TAGS ('dbx_business_glossary_term' = 'Temperature Excursion Noted Indicator');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `tmf_filing_status` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Filing Status');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `tmf_filing_status` SET TAGS ('dbx_value_regex' = 'not_filed|filed|verified');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `weight_destroyed_kg` SET TAGS ('dbx_business_glossary_term' = 'Weight Destroyed (kg)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `witness_name` SET TAGS ('dbx_business_glossary_term' = 'Destruction Witness Name');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `witness_name` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `witness_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `witness_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `witness_signature_date` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `witness_title` SET TAGS ('dbx_business_glossary_term' = 'Destruction Witness Title');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `witness_title` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `witness_title` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ALTER COLUMN `witness_title` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ADD CONSTRAINT `fk_supply_temperature_excursion_depot_id` FOREIGN KEY (`depot_id`) REFERENCES `clinical_trials_mvm`.`supply`.`depot`(`depot_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ADD CONSTRAINT `fk_supply_temperature_excursion_kit_inventory_id` FOREIGN KEY (`kit_inventory_id`) REFERENCES `clinical_trials_mvm`.`supply`.`kit_inventory`(`kit_inventory_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ADD CONSTRAINT `fk_supply_temperature_excursion_manufacture_batch_id` FOREIGN KEY (`manufacture_batch_id`) REFERENCES `clinical_trials_mvm`.`supply`.`manufacture_batch`(`manufacture_batch_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ADD CONSTRAINT `fk_supply_temperature_excursion_shipment_id` FOREIGN KEY (`shipment_id`) REFERENCES `clinical_trials_mvm`.`supply`.`shipment`(`shipment_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` SET TAGS ('dbx_domain' = 'supply');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` SET TAGS ('dbx_subdomain' = 'site_operations');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `capa_id` SET TAGS ('dbx_business_glossary_term' = 'Capa Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Service Level Agreement Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `depot_id` SET TAGS ('dbx_business_glossary_term' = 'Depot Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `inspection_finding_id` SET TAGS ('dbx_business_glossary_term' = 'Inspection Finding Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `kit_inventory_id` SET TAGS ('dbx_business_glossary_term' = 'Kit ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `manufacture_batch_id` SET TAGS ('dbx_business_glossary_term' = 'Manufacture Batch Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `monitoring_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Plan Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `quality_event_id` SET TAGS ('dbx_business_glossary_term' = 'Quality Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `safety_report_submission_id` SET TAGS ('dbx_business_glossary_term' = 'Safety Report Submission Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `specimen_id` SET TAGS ('dbx_business_glossary_term' = 'Specimen Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `capa_required` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Required Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `data_logger_code` SET TAGS ('dbx_business_glossary_term' = 'Data Logger Device ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `detection_source` SET TAGS ('dbx_business_glossary_term' = 'Excursion Detection Source');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `detection_source` SET TAGS ('dbx_value_regex' = 'data_logger|continuous_monitor|manual_check|irt_alert|courier_report|site_report');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `disposition_date` SET TAGS ('dbx_business_glossary_term' = 'Disposition Decision Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `disposition_decision` SET TAGS ('dbx_business_glossary_term' = 'Sponsor/QA Disposition Decision');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `disposition_decision` SET TAGS ('dbx_value_regex' = 'approved_for_use|quarantined|destroyed|returned|pending_sponsor_review');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `duration_minutes` SET TAGS ('dbx_business_glossary_term' = 'Excursion Duration (Minutes)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `excursion_number` SET TAGS ('dbx_business_glossary_term' = 'Temperature Excursion Number');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `excursion_number` SET TAGS ('dbx_value_regex' = '^EXC-[A-Z0-9]{3,10}-[0-9]{4,8}$');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `excursion_status` SET TAGS ('dbx_business_glossary_term' = 'Temperature Excursion Status');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `excursion_status` SET TAGS ('dbx_value_regex' = 'open|under_investigation|pending_disposition|closed|voided');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `excursion_type` SET TAGS ('dbx_business_glossary_term' = 'Temperature Excursion Type');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `excursion_type` SET TAGS ('dbx_value_regex' = 'high_temperature|low_temperature|freeze_thaw|humidity|combined');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `impact_assessment_outcome` SET TAGS ('dbx_value_regex' = 'use|quarantine|destroy|pending|return_to_sponsor');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `location_type` SET TAGS ('dbx_business_glossary_term' = 'Excursion Location Type');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `location_type` SET TAGS ('dbx_value_regex' = 'depot|site|in_transit|courier_hub|customs');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `logger_calibration_date` SET TAGS ('dbx_business_glossary_term' = 'Data Logger Calibration Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `lower_threshold_c` SET TAGS ('dbx_business_glossary_term' = 'Lower Temperature Threshold (Celsius)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `max_temp_recorded_c` SET TAGS ('dbx_business_glossary_term' = 'Maximum Temperature Recorded (Celsius)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `mean_kinetic_temp_c` SET TAGS ('dbx_business_glossary_term' = 'Mean Kinetic Temperature (MKT) (Celsius)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `min_temp_recorded_c` SET TAGS ('dbx_business_glossary_term' = 'Minimum Temperature Recorded (Celsius)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `replacement_kits_required` SET TAGS ('dbx_business_glossary_term' = 'Replacement Kits Required Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `reported_by` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `reported_by` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `reported_by` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `root_cause_category` SET TAGS ('dbx_value_regex' = 'equipment_failure|process_failure|human_error|logistics_failure|environmental|unknown');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `rtsm_excursion_reference` SET TAGS ('dbx_business_glossary_term' = 'Randomization and Trial Supply Management (RTSM) Excursion Reference');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `sponsor_notification_required` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Notification Required Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `stability_data_reviewed` SET TAGS ('dbx_business_glossary_term' = 'Stability Data Reviewed Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ALTER COLUMN `upper_threshold_c` SET TAGS ('dbx_business_glossary_term' = 'Upper Temperature Threshold (Celsius)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ADD CONSTRAINT `fk_supply_accountability_reconciliation_imp_master_id` FOREIGN KEY (`imp_master_id`) REFERENCES `clinical_trials_mvm`.`supply`.`imp_master`(`imp_master_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ADD CONSTRAINT `fk_supply_accountability_reconciliation_kit_definition_id` FOREIGN KEY (`kit_definition_id`) REFERENCES `clinical_trials_mvm`.`supply`.`kit_definition`(`kit_definition_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ADD CONSTRAINT `fk_supply_accountability_reconciliation_site_inventory_id` FOREIGN KEY (`site_inventory_id`) REFERENCES `clinical_trials_mvm`.`supply`.`site_inventory`(`site_inventory_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` SET TAGS ('dbx_domain' = 'supply');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` SET TAGS ('dbx_subdomain' = 'site_operations');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `accountability_reconciliation_id` SET TAGS ('dbx_business_glossary_term' = 'Drug Accountability Reconciliation ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Study Contract Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `arm_id` SET TAGS ('dbx_business_glossary_term' = 'Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Deliverable Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `imp_master_id` SET TAGS ('dbx_business_glossary_term' = 'Investigational Medicinal Product (IMP) ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `ind_application_id` SET TAGS ('dbx_business_glossary_term' = 'Ind Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `inspection_finding_id` SET TAGS ('dbx_business_glossary_term' = 'Inspection Finding Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `kit_definition_id` SET TAGS ('dbx_business_glossary_term' = 'Kit Definition Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `monitoring_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Visit ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `monitoring_visit_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Visit Schedule Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `protocol_deviation_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Deviation Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `quality_event_id` SET TAGS ('dbx_business_glossary_term' = 'Quality Event Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `rand_scheme_id` SET TAGS ('dbx_business_glossary_term' = 'Rand Scheme Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `site_cra_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Site Cra Assignment Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `site_file_id` SET TAGS ('dbx_business_glossary_term' = 'Site File Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `site_inventory_id` SET TAGS ('dbx_business_glossary_term' = 'Site Inventory Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `study_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Site ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Tmf Document Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `adjusted_units` SET TAGS ('dbx_business_glossary_term' = 'IMP Units Adjusted');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Comments');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `cra_signoff_date` SET TAGS ('dbx_business_glossary_term' = 'Clinical Research Associate (CRA) Sign-Off Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `cra_signoff_flag` SET TAGS ('dbx_business_glossary_term' = 'Clinical Research Associate (CRA) Monitor Sign-Off Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `destroyed_units` SET TAGS ('dbx_business_glossary_term' = 'IMP Units Destroyed');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `discrepancy_detail` SET TAGS ('dbx_business_glossary_term' = 'Discrepancy Detail Description');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `discrepancy_resolution_status` SET TAGS ('dbx_value_regex' = 'not_applicable|open|under_investigation|resolved|escalated');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `discrepancy_units` SET TAGS ('dbx_business_glossary_term' = 'IMP Discrepancy Units');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `dispensed_units` SET TAGS ('dbx_business_glossary_term' = 'IMP Units Dispensed');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `expired_units_count` SET TAGS ('dbx_business_glossary_term' = 'Expired IMP Units Count');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `expiry_date_earliest` SET TAGS ('dbx_business_glossary_term' = 'Earliest IMP Expiry Date on Site');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `gcp_compliance_flag` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Compliance Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `inspection_ready_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Inspection Readiness Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `investigator_name` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Name');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `investigator_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `investigator_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `investigator_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `investigator_signoff_date` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Sign-Off Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `investigator_signoff_flag` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Sign-Off Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Period End Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Period Start Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `received_units` SET TAGS ('dbx_business_glossary_term' = 'IMP Units Received');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `reconciliation_date` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Performed Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `reconciliation_number` SET TAGS ('dbx_business_glossary_term' = 'Drug Accountability Reconciliation Number');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `reconciliation_number` SET TAGS ('dbx_value_regex' = '^RECON-[A-Z0-9]{3,10}-[0-9]{4,8}$');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_business_glossary_term' = 'Drug Accountability Reconciliation Status');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_value_regex' = 'open|reconciled|discrepancy_flagged|pending_review|closed');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `reconciliation_type` SET TAGS ('dbx_business_glossary_term' = 'Drug Accountability Reconciliation Type');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `reconciliation_type` SET TAGS ('dbx_value_regex' = 'routine_monitoring|pre_dbl|site_closeout|interim|triggered');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `returned_units` SET TAGS ('dbx_business_glossary_term' = 'IMP Units Returned');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `rtsm_reconciliation_ref` SET TAGS ('dbx_business_glossary_term' = 'RTSM Reconciliation Reference Number');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `source_document_ref` SET TAGS ('dbx_business_glossary_term' = 'Source Document Reference');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `temperature_excursion_flag` SET TAGS ('dbx_business_glossary_term' = 'Cold-Chain Temperature Excursion Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `unit_of_measure` SET TAGS ('dbx_business_glossary_term' = 'IMP Unit of Measure');

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ADD CONSTRAINT `fk_supply_resupply_order_kit_definition_id` FOREIGN KEY (`kit_definition_id`) REFERENCES `clinical_trials_mvm`.`supply`.`kit_definition`(`kit_definition_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ADD CONSTRAINT `fk_supply_resupply_order_shipment_id` FOREIGN KEY (`shipment_id`) REFERENCES `clinical_trials_mvm`.`supply`.`shipment`(`shipment_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ADD CONSTRAINT `fk_supply_resupply_order_site_inventory_id` FOREIGN KEY (`site_inventory_id`) REFERENCES `clinical_trials_mvm`.`supply`.`site_inventory`(`site_inventory_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ADD CONSTRAINT `fk_supply_resupply_order_source_depot_id` FOREIGN KEY (`source_depot_id`) REFERENCES `clinical_trials_mvm`.`supply`.`depot`(`depot_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ADD CONSTRAINT `fk_supply_resupply_order_supply_plan_id` FOREIGN KEY (`supply_plan_id`) REFERENCES `clinical_trials_mvm`.`supply`.`supply_plan`(`supply_plan_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` SET TAGS ('dbx_domain' = 'supply');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` SET TAGS ('dbx_division' = 'operations');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` SET TAGS ('dbx_subdomain' = 'supply_logistics');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `application_id` SET TAGS ('dbx_business_glossary_term' = 'Study Contract Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `arm_id` SET TAGS ('dbx_business_glossary_term' = 'Arm Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `clinical_trial_authorization_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Authorization Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `ind_application_id` SET TAGS ('dbx_business_glossary_term' = 'Ind Application Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Version ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `site_inventory_id` SET TAGS ('dbx_business_glossary_term' = 'Site Inventory Id (Foreign Key)');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_blinding' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `treatment_arm_id` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `accountability_reconciled` SET TAGS ('dbx_business_glossary_term' = 'Accountability Reconciled Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Order Approval Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `blinding_level` SET TAGS ('dbx_value_regex' = 'open_label|single_blind|double_blind|triple_blind');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `courier_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `expiry_date_earliest` SET TAGS ('dbx_business_glossary_term' = 'Earliest Kit Expiry Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `is_emergency_override` SET TAGS ('dbx_business_glossary_term' = 'Emergency Override Flag');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `min_stock_threshold` SET TAGS ('dbx_business_glossary_term' = 'Minimum Stock Threshold');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `order_number` SET TAGS ('dbx_business_glossary_term' = 'Resupply Order Number');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `order_number` SET TAGS ('dbx_value_regex' = '^RSO-[A-Z0-9]{3,10}-[0-9]{6,10}$');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `order_status` SET TAGS ('dbx_business_glossary_term' = 'Resupply Order Status');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `order_status` SET TAGS ('dbx_value_regex' = 'draft|submitted|approved|dispatched|delivered|cancelled');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `quantity_unit` SET TAGS ('dbx_business_glossary_term' = 'Quantity Unit of Measure');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `quantity_unit` SET TAGS ('dbx_value_regex' = 'kit|vial|blister|bottle|syringe|sachet');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `reconciliation_date` SET TAGS ('dbx_business_glossary_term' = 'Accountability Reconciliation Date');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `requesting_location_type` SET TAGS ('dbx_value_regex' = 'site|depot|central_pharmacy');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `source_system_order_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Order ID');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `stock_at_trigger` SET TAGS ('dbx_business_glossary_term' = 'Stock Level at Trigger');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `storage_condition` SET TAGS ('dbx_value_regex' = 'room_temperature|refrigerated|frozen|controlled_room_temperature');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `storage_condition` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `tracking_number` SET TAGS ('dbx_business_glossary_term' = 'Shipment Tracking Number');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `trigger_type` SET TAGS ('dbx_business_glossary_term' = 'Resupply Trigger Type');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `trigger_type` SET TAGS ('dbx_value_regex' = 'rtsm_algorithm|manual_supply_manager|emergency_request|protocol_amendment');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ALTER COLUMN `urgency_level` SET TAGS ('dbx_value_regex' = 'routine|urgent|emergency');
