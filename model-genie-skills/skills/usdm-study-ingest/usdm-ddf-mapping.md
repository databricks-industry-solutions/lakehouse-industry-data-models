# USDM-to-Clinical Trials Model Mapping Reference

This document defines the canonical mapping from CDISC Unified Study Definitions Model (USDM), as encoded in DDF Reference Architecture v4.0 JSON, to the clinical_trials model's study domain products (v2).

## Mapping Principles

- Each USDM class maps to one or more study domain products (typically 1:1, sometimes 1:many for normalized decomposition).
- All attributes are mapped; if a clinical_trials product lacks a column for a USDM attribute, it is captured in a JSON/text column (e.g. `supplemental_metadata`).
- Foreign keys are resolved by (study_version_id, logical_id) pairs; all USDM ids become natural keys in the study domain.
- Type and enum attributes from USDM map to CDISC Controlled Terminology codelists (populated separately by `cdisc-terminology-load`).
- Dates and timestamps follow ISO 8601; relative times (e.g. "Day 1 relative to enrollment") are stored as numeric offset + reference point.

## Class-by-Class Mapping

### StudyVersion

| USDM Attribute | Target Product | Target Column | Type | Notes |
|---|---|---|---|---|
| studyVersionId | `study_version` | study_version_id | string (natural key) | Immutable; combined with study identifies unique protocol version |
| version | `study_version` | `version_identifier` | integer | Incrementing version within a study (v1, v2, ...) |
| title | `study` | `title` | string | Full protocol title |
| rationale | `study_version` | `rationale` | text | Why the study is needed |
| briefSummary | `study_version` | *(no v2 column)* | text | High-level study objective for lay audience |
| sponsorName | `study_version` | *(no v2 column)* | string | Organization sponsoring the study (may differ from study_organization in biostatistics domain) |
| studyType | `study` | `study_type` | string (enum) | Interventional, Observational, Expanded Access, etc.; links to CDISC CT |
| designType | `study_design` (via study_design_id) | design_type | string (enum) | Maps to USDM StudyDesign.designType; Interventional or Observational |
| isMasterProtocol | `study_version` | *(no v2 column)* | boolean | If true, this is an umbrella/master protocol with sub-studies |
| businessTherapeuticAreas | `study` | `therapeutic_area_id` | string (delimited or JSON) | Therapeutic indications (oncology, cardiology, etc.); free text or coded |
| studyPhase | `study` | `development_phase` | string (enum) | Phase 1/2/3/4; links to CDISC CT |
| informedConsentForm | `study_version` | *(no v2 column)* | string | Version identifier of informed consent form |
| studyStartDate | `governance_date` | date_value | date | Gates to link with dateType = 'protocol_start' |
| studyEndDate | `governance_date` | date_value | date | Gates to link with dateType = 'protocol_end' |

### StudyDesign

Extracted from StudyVersion.studyDesign object; populates `study_design` table (may be 1:1 with study_version or shared across versions).

| USDM Attribute | Target Product | Target Column | Type | Notes |
|---|---|---|---|---|
| designType | `study_design` | design_type | string (enum) | Interventional or Observational; CDISC CT link |
| masterProtocolType | `study_design` | *(no v2 column)* | string (enum) | Umbrella, Basket, Platform (if isMasterProtocol = true); CDISC CT link |
| studyDesignId | `study_design` | study_design_id | string (natural key) | Immutable identifier |
| label | `study_design` | `design_name` | string | Short human-readable label |
| description | `study_design` | *(no v2 column)* | text | Narrative description of the design |
| therapeuticAreas | `study_design` | *(no v2 column)* | string (delimited or JSON) | Inherits from study_version if not overridden |

### StudyArm

| USDM Attribute | Target Product | Target Column | Type | Notes |
|---|---|---|---|---|
| studyArmId | `arm` | arm_id | string (natural key) | Unique within study; combined with study_version_id forms (study_version_id, arm_id) |
| armType | `arm` | arm_type | string (enum) | Treatment, Control, Comparator, Placebo, Active Comparator, etc.; CDISC CT link |
| label | `arm` | `arm_name` | string | Human-readable arm label (e.g. "Treatment A: 100mg") |
| description | `arm` | `intervention_description` | text | Detailed description of the arm (population, interventions, duration) |
| studyEpochRefs | `study_cell` | `epoch_id` | string (JSON array of epoch_id) | Which epochs this arm participates in; may be all or a subset |
| plannedSubjectCount | `arm` | `planned_subjects_count` | integer | Target enrollment for this arm |
| studyVersionId (FK) | `arm` | `study_design_id` | bigint (FK) | Links to study_version |

### StudyEpoch

| USDM Attribute | Target Product | Target Column | Type | Notes |
|---|---|---|---|---|
| studyEpochId | `epoch` | epoch_id | string (natural key) | Unique within study; (study_version_id, epoch_id) is the natural key |
| epochType | `epoch` | epoch_type | string (enum) | Screening, Enrollment, Treatment, Follow-up, etc.; CDISC CT link |
| label | `epoch` | `epoch_name` | string | Human-readable label (e.g. "Treatment") |
| description | `epoch` | `epoch_description` | text | Detailed description of what happens in this epoch |
| studyVersionId (FK) | `epoch` | `study_design_id` | bigint (FK) | Links to study_version |

### StudyCell (Normalized: Arm x Epoch)

StudyCell is NOT an explicit USDM class; it is the Cartesian product of Study Arms x Study Epochs, computed to capture which arms appear in which epochs. The clinical_trials model captures this explicitly.

| USDM Derivation | Target Product | Target Column | Type | Notes |
|---|---|---|---|---|
| (arm_id, epoch_id) | `study_cell` | study_cell_id (surrogate) | integer (surrogate PK) | Computed as hash(study_version_id, arm_id, epoch_id) or assigned on load |
| arm reference | `study_cell` | arm_id | string (FK) | Foreign key to arm |
| epoch reference | `study_cell` | epoch_id | string (FK) | Foreign key to epoch |
| study version | `study_cell` | `study_design_id` | bigint (FK) | Propagated from arm and epoch (redundant for query optimization) |
| cardinality check | - | - | - | # study_cells = # study_arms x # study_epochs (assuming complete cross-product) |

### StudyElement

Represents the activities/interventions/procedures that occur in a study cell (arm x epoch combination).

| USDM Attribute | Target Product | Target Column | Type | Notes |
|---|---|---|---|---|
| studyElementId | `study_element` | study_element_id | string (natural key) | Unique within study; (study_version_id, study_element_id) is the natural key |
| elementType | `study_element` | element_type | string (enum) | Treatment, Washout, Follow-up, Screening Activity, etc.; CDISC CT link |
| label | `study_element` | `element_name` | string | Short label (e.g. "Treatment Period") |
| description | `study_element` | `element_description` | text | What happens in this element |
| studyCellRefs | `study_element` | study_cell_id (FK) | integer (FK) | Which cells this element applies to; may be 1 or many |
| interventionRefs | `study_element` | intervention_ids (JSON array) | string (FK array to study_intervention) | Interventions applied in this element |
| studyVersionId (FK) | `study_element` | `study_design_id` | bigint (FK) | Propagated for query optimization |

### ScheduleTimeline

Defines when activities/encounters occur relative to epoch boundaries.

| USDM Attribute | Target Product | Target Column | Type | Notes |
|---|---|---|---|---|
| timelineId | `schedule_timeline` | `schedule_timeline_id` | bigint (natural key) | Unique within study element; (study_version_id, study_element_id, timeline_id) is the natural key |
| description | `schedule_timeline` | `timeline_description` | text | Narrative description of the timeline (e.g. "Days 1-28 of treatment") |
| studyElementId (FK) | `schedule_timeline` | *(no v2 column)* | string (FK) | Links to study_element |
| studyVersionId (FK) | `schedule_timeline` | `study_design_id` | bigint (FK) | Propagated for query optimization |

### ScheduledActivityInstance

Represents a planned occurrence of an activity within a timeline.

| USDM Attribute | Target Product | Target Column | Type | Notes |
|---|---|---|---|---|
| activityId | `scheduled_activity_instance` | activity_id | string (natural key) | Unique within timeline; (study_version_id, timeline_id, activity_id) is the natural key |
| activityType | `activity` | `activity_type` | string (enum) | Assessment, Treatment, Lab Collection, Visit, etc.; CDISC CT link |
| plannedStartRelativeToEpoch | `scheduled_activity_instance` | `scheduled_time_point` | integer (days) | Offset from epoch start; may be negative (before epoch) |
| plannedEndRelativeToEpoch | `scheduled_activity_instance` | *(no v2 column)* | integer (days) | Offset from epoch start; may be null if punctual |
| repeatPattern | `scheduled_activity_instance` | *(no v2 column)* | string (enum or JSON) | Once, Daily, Weekly, Monthly, etc. (if repeated within timeline) |
| referenceBiomedicalConceptId | `scheduled_activity_instance` | biomedical_concept_id (FK) | string (FK) | Links to biomedical_concept if this activity measures/assesses a specific concept |
| timelineId (FK) | `scheduled_activity_instance` | timeline_id (FK) | string (FK) | Links to schedule_timeline |
| studyVersionId (FK) | `scheduled_activity_instance` | study_version_id (FK) | string (FK) | Propagated for query optimization |

### Encounter (Study Visits)

Represents protocol-defined encounters/visits when study subjects interact with the study.

| USDM Attribute | Target Product | Target Column | Type | Notes |
|---|---|---|---|---|
| encounterId | `encounter` | encounter_id | string (natural key) | Unique within study; (study_version_id, encounter_id) is the natural key |
| encounterType | `encounter` | encounter_type | string (enum) | Screening Visit, Baseline Visit, Treatment Visit, Follow-up Visit, Telephone Visit, etc.; CDISC CT link |
| label | `encounter` | `encounter_name` | string | Short label (e.g. "Week 1 Visit") |
| description | `encounter` | `encounter_description` | text | What happens at this encounter |
| scheduledTimelineId (FK) | `encounter` | timeline_id (FK) | string (FK) | Links to schedule_timeline when this encounter occurs |
| studyVersionId (FK) | `encounter` | study_version_id (FK) | string (FK) | Links to study_version |

### Activity (Procedures/Assessments at Encounters)

Represents specific procedures or assessments that occur at an encounter.

| USDM Attribute | Target Product | Target Column | Type | Notes |
|---|---|---|---|---|
| activityId | `activity` | activity_id | string (natural key) | Unique within study; (study_version_id, activity_id) is the natural key; may match scheduled_activity_instance.activity_id if activity is scheduled, or be a one-off activity |
| activityType | `activity` | activity_type | string (enum) | Vital Signs Assessment, Lab Collection, ECG, Physical Exam, Questionnaire, Drug Administration, etc.; CDISC CT link |
| label | `activity` | `activity_name` | string | Short label (e.g. "Blood Pressure") |
| description | `activity` | `activity_description` | text | Detailed description of the activity |
| encounterId (FK) | `activity` | encounter_id (FK) | string (FK) | Which encounter(s) this activity typically occurs at; may be all encounters or specific ones |
| referenceBiomedicalConceptId (FK) | `activity` | biomedical_concept_id (FK) | string (FK) | Links to biomedical_concept if the activity measures a specific concept |
| studyVersionId (FK) | `activity` | study_version_id (FK) | string (FK) | Propagated for query optimization |

### BiomedicalConcept

Represents clinical/biological concepts measured or assessed by the study (lab analytes, vital signs, clinical outcomes, etc.).

| USDM Attribute | Target Product | Target Column | Type | Notes |
|---|---|---|---|---|
| biomedicalConceptId | `biomedical_concept` | biomedical_concept_id | string (natural key) | Unique within study; (study_version_id, biomedical_concept_id) is the natural key |
| conceptType | `biomedical_concept` | *(no v2 column)* | string (enum) | Laboratory Test, Vital Sign, Clinical Assessment, Patient-Reported Outcome, Composite, etc.; CDISC CT link |
| label | `biomedical_concept` | `concept_name` | string | Short label (e.g. "Hemoglobin") |
| definition | `biomedical_concept` | `concept_description` | text | Clinical/scientific definition |
| sourceConceptId | `biomedical_concept` | `concept_code` | string | If mapped to LOINC, SNOMED, MedDRA, record the source code here |
| sourceConceptSystem | `biomedical_concept` | `code_system_version_id` | string | Name of coding system (LOINC, SNOMED CT, MedDRA, etc.) |
| studyVersionId (FK) | `biomedical_concept` | study_version_id (FK) | string (FK) | Links to study_version |

### StudyIdentifier

| USDM Attribute | Target Product | Target Column | Type | Notes |
|---|---|---|---|---|
| studyIdentifierId | `study_identifier` | study_identifier_id | string (natural key) | Unique identifier for this registry entry; (study_version_id, study_identifier_id) is the natural key |
| identifierValue | `study_identifier` | identifier_value | string | The actual registry ID (e.g. "NCT04123456", "2020-001234-56") |
| studyIdentifierType | `study_identifier` | identifier_type | string (enum) | NCT, EU CT Number, IND, EUDRA Number, etc.; CDISC CT link |
| organizationIdentifier | `study_identifier` | issuing_organization | string | Organization that issued the identifier (e.g. "ClinicalTrials.gov", "EudraCT") |
| studyVersionId (FK) | `study_identifier` | study_version_id (FK) | string (FK) | Links to study_version |

### GovernanceDate

Captures protocol-level governance events (versions, approvals, amendments).

| USDM Attribute | Target Product | Target Column | Type | Notes |
|---|---|---|---|---|
| dateId | `governance_date` | `governance_date_id` | bigint (natural key) | Unique identifier; (study_version_id, date_id) is the natural key |
| dateValue | `governance_date` | date_value | date | The date of the event |
| dateType | `governance_date` | date_type | string (enum) | Protocol Effective Date, Protocol Amendment Date, Ethics Committee Approval Date, Regulatory Approval Date, etc.; CDISC CT link |
| description | `governance_date` | `governance_date_description` | text | Context (e.g. "Amendment 1: safety update") |
| studyVersionId (FK) | `governance_date` | study_version_id (FK) | string (FK) | Links to study_version |

### Population (Study-Level Population Definition)

| USDM Attribute | Target Product | Target Column | Type | Notes |
|---|---|---|---|---|
| populationId | `population` | population_id | string (natural key) | Unique within study; (study_version_id, population_id) is the natural key |
| label | `population` | `population_name` | string | Short label (e.g. "All Randomized Subjects") |
| description | `population` | `population_description` | text | Narrative description of the population |
| populationType | `population` | *(no v2 column)* | string (enum) | Enrolled, Screened, Randomized, Intent-to-Treat, Per-Protocol, Safety, etc.; CDISC CT link |
| studyVersionId (FK) | `population` | study_version_id (FK) | string (FK) | Links to study_version |

### Cohort (Subgroup of a Population)

| USDM Attribute | Target Product | Target Column | Type | Notes |
|---|---|---|---|---|
| cohortId | `cohort` | cohort_id | string (natural key) | Unique within population; (study_version_id, population_id, cohort_id) is the natural key |
| label | `cohort` | `cohort_name` | string | Short label (e.g. "Males") |
| description | `cohort` | `cohort_description` | text | Narrative description (e.g. "Subjects of male gender") |
| populationId (FK) | `cohort` | population_id (FK) | string (FK) | Links to population |
| studyVersionId (FK) | `cohort` | study_version_id (FK) | string (FK) | Propagated for query optimization |

### StudyIntervention

| USDM Attribute | Target Product | Target Column | Type | Notes |
|---|---|---|---|---|
| interventionId | `study_intervention` | `study_intervention_id` | bigint (natural key) | Unique within study; (study_version_id, intervention_id) is the natural key |
| interventionType | `study_intervention` | intervention_type | string (enum) | Drug, Device, Procedure, Behavioral, Dietary Supplement, Biological, etc.; CDISC CT link |
| label | `study_intervention` | `intervention_name` | string | Short label (e.g. "Investigational Drug A 100mg") |
| description | `study_intervention` | `intervention_description` | text | Detailed description (active ingredient, dose, route, frequency, duration) |
| doseDescription | `study_intervention` | *(no v2 column)* | text | Free-text or structured dose (if structured, may reference codelist for dose_unit from CDISC CT) |
| routeOfAdministration | `study_intervention` | route_of_administration | string | Intravenous, Oral, Subcutaneous, etc.; CDISC CT link (WHO-Drug route classification) |
| studyVersionId (FK) | `study_intervention` | study_version_id (FK) | string (FK) | Links to study_version |

### Estimand

| USDM Attribute | Target Product | Target Column | Type | Notes |
|---|---|---|---|---|
| estimandId | `estimand` | estimand_id | string (natural key) | Unique within study; (study_version_id, estimand_id) is the natural key |
| label | `estimand` | label | string | Short label (e.g. "Primary Efficacy ITT") |
| description | `estimand` | description | text | Full estimand definition (target population, treatment, intercurrent-event strategy) |
| populationId (FK) | `estimand` | population_id (FK) | string (FK) | Links to population (target population for the estimand) |
| intercurrentEventStrategies | `estimand` | intercurrent_event_ids (JSON array) | string (FK array) | Foreign keys to intercurrent_event(s) defining how to handle deviations (may be multiple) |
| analysisSetId | `estimand` | analysis_set_id (FK) | string (FK) | Links to `biostatistics.analysis_set` if v2 model includes it |
| studyVersionId (FK) | `estimand` | study_version_id (FK) | string (FK) | Propagated for query optimization |

### IntercurrentEvent

| USDM Attribute | Target Product | Target Column | Type | Notes |
|---|---|---|---|---|
| intercurrentEventId | `intercurrent_event` | intercurrent_event_id | string (natural key) | Unique within study; (study_version_id, intercurrent_event_id) is the natural key |
| description | `intercurrent_event` | `event_description` | text | What the intercurrent event is (e.g. "Death from any cause") |
| intercurrentEventType | `intercurrent_event` | `event_name` | string (enum) | Death, Permanent Discontinuation, Serious Adverse Event, Protocol Deviation, etc.; CDISC CT link |
| populationId (FK) | `intercurrent_event` | population_id (FK) | string (FK) | Links to population that may experience the event (may be all subjects or a subset) |
| strategy | `intercurrent_event` | `handling_strategy` | string (enum) | How to handle: Discontinue, Exclude, Censor, Population Adjustment, Conditional, etc.; CDISC CT link |
| studyVersionId (FK) | `intercurrent_event` | study_version_id (FK) | string (FK) | Propagated for query optimization |

### Objective

| USDM Attribute | Target Product | Target Column | Type | Notes |
|---|---|---|---|---|
| objectiveId | `objective` | objective_id | string (natural key) | Unique within study; (study_version_id, objective_id) is the natural key |
| label | `objective` | `short_title` | string | Short label (e.g. "Primary Efficacy") |
| description | `objective` | `text` | text | Narrative description of the study objective |
| objectiveType | `objective` | objective_type | string (enum) | Primary, Secondary, Exploratory, Safety, etc.; CDISC CT link |
| endpointIds | `objective` | endpoint_ids (JSON array) | string (FK array) | Foreign keys to endpoint(s) that measure this objective |
| studyVersionId (FK) | `objective` | study_version_id (FK) | string (FK) | Links to study_version |

### Endpoint

| USDM Attribute | Target Product | Target Column | Type | Notes |
|---|---|---|---|---|
| endpointId | `endpoint` | endpoint_id | string (natural key) | Unique within study; (study_version_id, endpoint_id) is the natural key |
| label | `endpoint` | `endpoint_name` | string | Short label (e.g. "Change in Lab Value X") |
| description | `endpoint` | `endpoint_description` | text | Full definition of the endpoint (population, timing, measurement method) |
| endpointType | `endpoint` | endpoint_type | string (enum) | Primary, Secondary, Exploratory, Safety, Pharmacokinetic, Pharmacodynamic, etc.; CDISC CT link |
| biomedicalConceptIds | `endpoint` | biomedical_concept_ids (JSON array) | string (FK array) | Foreign keys to biomedical_concept(s) underlying the endpoint |
| studyVersionId (FK) | `endpoint` | study_version_id (FK) | string (FK) | Links to study_version |

### EligibilityCriterion

| USDM Attribute | Target Product | Target Column | Type | Notes |
|---|---|---|---|---|
| criterionId | `eligibility_criterion` | `eligibility_criterion_id` | bigint (natural key) | Unique within study; (study_version_id, criterion_id) is the natural key |
| label | `eligibility_criterion` | `criterion_short_name` | string | Short label (e.g. "Age >= 18") |
| description | `eligibility_criterion` | `criterion_text` | text | Narrative description of the criterion |
| criterionType | `eligibility_criterion` | criterion_type | string (enum) | Inclusion, Exclusion |
| populationId (FK) | `eligibility_criterion` | population_id (FK) | string (FK) | Links to population (which population the criterion applies to) |
| studyVersionId (FK) | `eligibility_criterion` | study_version_id (FK) | string (FK) | Propagated for query optimization |

---

## Notes

- All dates are ISO 8601 format (YYYY-MM-DD).
- All text fields (description, label, etc.) preserve verbatim content from the USDM JSON; no truncation.
- JSON arrays are stored as array columns where supported, or delimited strings (pipe `|` separator) if not.
- Enums are always mapped to CDISC Controlled Terminology; the enum value name from USDM becomes the submission value.
- Surrogate keys (e.g. study_cell_id, study_version surrogate PK) are generated on load using SHA2 hashing or assigned by the database (if IDENTITY/AUTOINCREMENT is configured).
- All FK relationships must be checked post-load for orphans.
- Audit trail metadata (_audit_usdm_ingest) includes load timestamp, source file path and hash, USDM package version, and DDF-RA version.

