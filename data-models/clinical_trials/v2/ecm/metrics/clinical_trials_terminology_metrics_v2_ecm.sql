-- Metric views for domain: terminology | Business: Clinical_Trials | Version: 13 | Generated on: 2026-11-19 16:37:37

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`terminology_code_system_version`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Tracks adoption, currency, and lifecycle of terminology code system versions (MedDRA, LOINC, WHODrug, SNOMED CT, ICD-10, CTCAE) across clinical trials, enabling governance of dictionary version compliance and migration planning."
  source: "`clinical_trials_ecm`.`terminology`.`code_system_version`"
  dimensions:
    - name: "Code System"
      display_name: "Code System"
      expr: code_system_id
      comment: "The terminology standard (MedDRA, LOINC, WHODrug, SNOMED CT, ICD-10, CTCAE) being versioned."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Version Label"
      display_name: "Version Label"
      expr: version_label
      comment: "Human-readable version identifier (e.g., MedDRA 26.0, LOINC 2.76)."
    - name: "Package Version"
      display_name: "Package Version"
      expr: package_version
      comment: "Technical package version string for the code system release."
    - name: "Release Year"
      display_name: "Release Year"
      expr: YEAR(release_date)
      comment: "Year the code system version was released, for trend analysis."
      format:
        type: date
        date_format: year
        leading_zeros: true
    - name: "Release Quarter"
      display_name: "Release Quarter"
      expr: DATE_TRUNC('quarter', release_date)
      comment: "Quarter the code system version was released, for quarterly adoption tracking."
      format:
        type: date
        date_format: year_quarter
        leading_zeros: true
    - name: "Release Month"
      display_name: "Release Month"
      expr: DATE_TRUNC('month', release_date)
      comment: "Month the code system version was released, for monthly adoption tracking."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Active Code System Versions"
      display_name: "Active Code System Versions"
      expr: COUNT(DISTINCT code_system_version_id)
      comment: "Count of distinct code system versions in use, indicating version sprawl and migration complexity."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Code Systems Managed"
      display_name: "Code Systems Managed"
      expr: COUNT(DISTINCT code_system_id)
      comment: "Count of distinct terminology standards managed, indicating governance scope."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`terminology_code_system_version_currency`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Code system version currency and release cadence metrics for terminology governance and regulatory compliance"
  source: "`clinical_trials_ecm`.`terminology`.`code_system_version`"
  dimensions:
    - name: "Version Label"
      display_name: "Version Label"
      expr: version_label
      comment: "Code system version label for version-specific terminology tracking"
    - name: "Package Identifier"
      display_name: "Package Identifier"
      expr: package_identifier
      comment: "Code system package identifier for distribution and deployment tracking"
    - name: "Package Version"
      display_name: "Package Version"
      expr: package_version
      comment: "Code system package version for granular version control"
    - name: "Release Year"
      display_name: "Release Year"
      expr: YEAR(release_date)
      comment: "Year of code system version release for temporal version analysis"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Release Month"
      display_name: "Release Month"
      expr: DATE_TRUNC('month', release_date)
      comment: "Month of code system version release for release cadence tracking"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Code System Versions"
      display_name: "Total Code System Versions"
      expr: COUNT(1)
      comment: "Total count of code system versions available for terminology version management"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Code Systems"
      display_name: "Distinct Code Systems"
      expr: COUNT(DISTINCT code_system_id)
      comment: "Unique code systems with versioned releases, indicating terminology portfolio breadth"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Version Labels"
      display_name: "Distinct Version Labels"
      expr: COUNT(DISTINCT version_label)
      comment: "Unique version labels across all code systems, measuring version diversity"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`terminology_ctcae`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Tracks CTCAE term and grade usage for adverse event severity grading, enabling safety signal detection, grade distribution analysis, and regulatory submission readiness."
  source: "`clinical_trials_ecm`.`terminology`.`ctcae`"
  dimensions:
    - name: "CTCAE Version"
      display_name: "CTCAE Version"
      expr: code_system_version_id
      comment: "The CTCAE version used for this term, critical for regulatory submission consistency."
      format:
        type: number
        decimal_places:
          type: all
    - name: "CTCAE Term"
      display_name: "CTCAE Term"
      expr: term
      comment: "The CTCAE term describing the adverse event."
    - name: "CTCAE Grade"
      display_name: "CTCAE Grade"
      expr: grade
      comment: "The CTCAE grade (1-5) indicating adverse event severity."
      format:
        type: number
        decimal_places:
          type: all
    - name: "MedDRA PT"
      display_name: "MedDRA PT"
      expr: meddra_pt_id
      comment: "The MedDRA preferred term linked to this CTCAE term, enabling cross-dictionary analysis."
      format:
        type: number
        decimal_places:
          type: all
    - name: "MedDRA SOC"
      display_name: "MedDRA SOC"
      expr: meddra_soc_id
      comment: "The MedDRA system organ class linked to this CTCAE term, enabling SOC-level safety analysis."
      format:
        type: number
        decimal_places:
          type: all
  measures:
    - name: "Distinct CTCAE Terms Used"
      display_name: "Distinct CTCAE Terms Used"
      expr: COUNT(DISTINCT ctcae_id)
      comment: "Count of distinct CTCAE terms in use, indicating adverse event type diversity."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct CTCAE Term Names"
      display_name: "Distinct CTCAE Term Names"
      expr: COUNT(DISTINCT term)
      comment: "Count of distinct CTCAE term names, enabling term usage frequency analysis."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Average CTCAE Grade"
      display_name: "Average CTCAE Grade"
      expr: AVG(CAST(grade AS DOUBLE))
      comment: "Average CTCAE grade across all terms, indicating overall adverse event severity."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total CTCAE Grade Points"
      display_name: "Total CTCAE Grade Points"
      expr: SUM(CAST(grade AS DOUBLE))
      comment: "Sum of CTCAE grades, enabling severity burden calculation."
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`terminology_ctcae_severity_grading`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "CTCAE adverse event severity grading distribution and grade utilization metrics for oncology safety reporting"
  source: "`clinical_trials_ecm`.`terminology`.`ctcae`"
  dimensions:
    - name: "CTCAE Code"
      display_name: "CTCAE Code"
      expr: ctcae_code
      comment: "CTCAE term code for standardized adverse event severity classification"
    - name: "Term"
      display_name: "CTCAE Term"
      expr: term
      comment: "CTCAE adverse event term name for human-readable severity grading"
    - name: "Grade"
      display_name: "CTCAE Grade"
      expr: grade
      comment: "CTCAE severity grade (1-5) for adverse event intensity classification"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Grade Description"
      display_name: "Grade Description"
      expr: grade_description
      comment: "CTCAE grade description for clinical interpretation of adverse event severity"
  measures:
    - name: "Total CTCAE Terms"
      display_name: "Total CTCAE Terms"
      expr: COUNT(1)
      comment: "Total count of CTCAE terms available for adverse event severity grading"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct CTCAE Codes"
      display_name: "Distinct CTCAE Codes"
      expr: COUNT(DISTINCT ctcae_code)
      comment: "Unique CTCAE codes in use, indicating severity grading vocabulary breadth"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Average Grade"
      display_name: "Average CTCAE Grade"
      expr: AVG(CAST(grade AS DOUBLE))
      comment: "Average CTCAE severity grade across all terms, indicating overall adverse event intensity profile"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Grade 3 Plus Count"
      display_name: "Grade 3+ Terms Count"
      expr: SUM(CAST(CASE WHEN grade >= 3 THEN 1 ELSE 0 END AS INT))
      comment: "Count of CTCAE terms with grade 3 or higher, indicating serious adverse event potential"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`terminology_ctcae_toxicity_grading`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "CTCAE toxicity grading and adverse event severity assessment metrics for oncology safety reporting"
  source: "`clinical_trials_ecm`.`terminology`.`ctcae`"
  dimensions:
    - name: "Dictionary Version"
      display_name: "CTCAE Version"
      expr: code_system_version_id
      comment: "CTCAE dictionary version used for toxicity grading"
      format:
        type: number
        decimal_places:
          type: all
    - name: "CTCAE Code"
      display_name: "CTCAE Code"
      expr: ctcae_code
      comment: "Unique CTCAE code identifier for adverse event term"
    - name: "Term"
      display_name: "CTCAE Term"
      expr: term
      comment: "CTCAE adverse event term"
    - name: "Grade"
      display_name: "Toxicity Grade"
      expr: grade
      comment: "CTCAE toxicity grade (1-5) for severity assessment"
      format:
        type: number
        decimal_places:
          type: all
    - name: "MedDRA SOC"
      display_name: "MedDRA SOC ID"
      expr: meddra_soc_id
      comment: "MedDRA System Organ Class for CTCAE term mapping"
      format:
        type: number
        decimal_places:
          type: all
  measures:
    - name: "Total CTCAE Terms"
      display_name: "Total CTCAE Terms"
      expr: COUNT(1)
      comment: "Total number of CTCAE terms available for toxicity grading"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct CTCAE Codes"
      display_name: "Unique CTCAE Codes"
      expr: COUNT(DISTINCT ctcae_code)
      comment: "Count of unique CTCAE codes for adverse event standardization"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Terms"
      display_name: "Unique CTCAE Terms"
      expr: COUNT(DISTINCT term)
      comment: "Count of unique CTCAE terms, indicating toxicity assessment coverage"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Average Grade"
      display_name: "Average Toxicity Grade"
      expr: AVG(CAST(grade AS DOUBLE))
      comment: "Average toxicity grade across CTCAE terms, indicating severity distribution"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`terminology_icd10_diagnosis_coding`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "ICD-10 diagnosis code utilization and hierarchy coverage metrics for medical history and comorbidity coding"
  source: "`clinical_trials_ecm`.`terminology`.`icd10_code`"
  dimensions:
    - name: "ICD10 Code"
      display_name: "ICD-10 Code"
      expr: icd10_code_code
      comment: "ICD-10 diagnosis code for standardized disease and condition classification"
    - name: "Term Name"
      display_name: "Diagnosis Term"
      expr: term_name
      comment: "ICD-10 term name for human-readable diagnosis description"
  measures:
    - name: "Total ICD10 Codes"
      display_name: "Total ICD-10 Codes"
      expr: COUNT(1)
      comment: "Total count of ICD-10 codes available for diagnosis and medical history coding"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct ICD10 Codes"
      display_name: "Distinct ICD-10 Codes"
      expr: COUNT(DISTINCT icd10_code_code)
      comment: "Unique ICD-10 codes in use, indicating diagnosis vocabulary coverage"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Codes With Parent"
      display_name: "Codes With Parent"
      expr: SUM(CAST(CASE WHEN parent_icd10_code_id IS NOT NULL THEN 1 ELSE 0 END AS INT))
      comment: "Count of ICD-10 codes with parent hierarchy linkage, indicating hierarchical coding depth"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`terminology_loinc`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Tracks LOINC code usage for laboratory results and vital signs, enabling test standardization, interoperability assessment, and eCRF-to-SDTM mapping validation."
  source: "`clinical_trials_ecm`.`terminology`.`loinc`"
  dimensions:
    - name: "LOINC Version"
      display_name: "LOINC Version"
      expr: code_system_version_id
      comment: "The LOINC version used for this code, critical for interoperability and FHIR mapping consistency."
      format:
        type: number
        decimal_places:
          type: all
    - name: "LOINC Code"
      display_name: "LOINC Code"
      expr: loinc_code
      comment: "The LOINC code identifier for the laboratory test or vital sign."
    - name: "Component"
      display_name: "Component"
      expr: component
      comment: "The component (analyte) being measured, enabling component-level analysis."
    - name: "Long Common Name"
      display_name: "Long Common Name"
      expr: long_common_name
      comment: "The human-readable long common name for the LOINC code."
  measures:
    - name: "Distinct LOINC Codes Used"
      display_name: "Distinct LOINC Codes Used"
      expr: COUNT(DISTINCT loinc_id)
      comment: "Count of distinct LOINC codes in use, indicating laboratory test standardization coverage."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Components Measured"
      display_name: "Distinct Components Measured"
      expr: COUNT(DISTINCT component)
      comment: "Count of distinct components (analytes) measured, indicating the breadth of laboratory testing."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct LOINC Code Strings"
      display_name: "Distinct LOINC Code Strings"
      expr: COUNT(DISTINCT loinc_code)
      comment: "Count of distinct LOINC code strings, enabling duplicate detection and mapping validation."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`terminology_loinc_lab_test_coding`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "LOINC laboratory test coding activity and standardization metrics for lab results and vital signs interoperability"
  source: "`clinical_trials_ecm`.`terminology`.`loinc`"
  dimensions:
    - name: "Dictionary Version"
      display_name: "LOINC Version"
      expr: code_system_version_id
      comment: "LOINC dictionary version used for lab test coding"
      format:
        type: number
        decimal_places:
          type: all
    - name: "LOINC Code"
      display_name: "LOINC Code"
      expr: loinc_code
      comment: "Unique LOINC code identifier for lab test or observation"
    - name: "Component"
      display_name: "Component"
      expr: component
      comment: "Analyte or component being measured"
    - name: "Long Common Name"
      display_name: "Long Common Name"
      expr: long_common_name
      comment: "Fully specified LOINC long common name for the test"
  measures:
    - name: "Total LOINC Codes"
      display_name: "Total LOINC Codes"
      expr: COUNT(1)
      comment: "Total number of LOINC codes available for lab test and vital sign coding"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Components"
      display_name: "Unique Components"
      expr: COUNT(DISTINCT component)
      comment: "Count of unique analyte components, indicating lab test coverage breadth"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct LOINC Codes"
      display_name: "Unique LOINC Codes"
      expr: COUNT(DISTINCT loinc_code)
      comment: "Count of unique LOINC codes for lab test standardization and interoperability"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`terminology_loinc_lab_test_coverage`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "LOINC laboratory test code coverage and component utilization metrics for clinical lab data standardization"
  source: "`clinical_trials_ecm`.`terminology`.`loinc`"
  dimensions:
    - name: "LOINC Code"
      display_name: "LOINC Code"
      expr: loinc_code
      comment: "LOINC code for standardized laboratory test identification"
    - name: "Component"
      display_name: "Lab Component"
      expr: component
      comment: "LOINC component (analyte) being measured in the laboratory test"
    - name: "Long Common Name"
      display_name: "Long Common Name"
      expr: long_common_name
      comment: "LOINC long common name for human-readable laboratory test description"
  measures:
    - name: "Total LOINC Codes"
      display_name: "Total LOINC Codes"
      expr: COUNT(1)
      comment: "Total count of LOINC codes available for laboratory test standardization"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct LOINC Codes"
      display_name: "Distinct LOINC Codes"
      expr: COUNT(DISTINCT loinc_code)
      comment: "Unique LOINC codes in use, indicating laboratory test vocabulary coverage"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Components"
      display_name: "Distinct Lab Components"
      expr: COUNT(DISTINCT component)
      comment: "Unique laboratory components (analytes) covered by LOINC codes"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`terminology_meddra_adverse_event_coding`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "MedDRA adverse event coding activity and hierarchy utilization metrics for safety reporting and regulatory submissions"
  source: "`clinical_trials_ecm`.`terminology`.`meddra_llt`"
  dimensions:
    - name: "Hierarchy Level"
      display_name: "MedDRA Hierarchy Level"
      expr: hierarchy_level
      comment: "MedDRA hierarchy level (LLT, PT, HLT, HLGT, SOC) for stratified coding analysis"
    - name: "Current Flag"
      display_name: "Current Term Flag"
      expr: current_flag
      comment: "Whether the LLT term is current or deprecated in the active MedDRA version"
    - name: "LLT Code"
      display_name: "LLT Code"
      expr: llt_code
      comment: "MedDRA Lowest Level Term code for granular adverse event coding"
    - name: "Term Name"
      display_name: "Term Name"
      expr: term_name
      comment: "MedDRA term name for human-readable adverse event classification"
  measures:
    - name: "Total LLT Terms"
      display_name: "Total LLT Terms"
      expr: COUNT(1)
      comment: "Total count of MedDRA Lowest Level Terms available for adverse event coding"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct LLT Codes"
      display_name: "Distinct LLT Codes"
      expr: COUNT(DISTINCT llt_code)
      comment: "Unique MedDRA LLT codes in use, indicating coding vocabulary breadth"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Current Terms Count"
      display_name: "Current Terms Count"
      expr: SUM(CAST(CASE WHEN current_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of current (non-deprecated) MedDRA LLT terms available for coding"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Deprecated Terms Count"
      display_name: "Deprecated Terms Count"
      expr: SUM(CAST(CASE WHEN current_flag = FALSE THEN 1 ELSE 0 END AS INT))
      comment: "Count of deprecated MedDRA LLT terms requiring recoding or version migration"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`terminology_meddra_hierarchy_coverage`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "MedDRA preferred term hierarchy coverage and SOC distribution metrics for safety signal detection and regulatory reporting"
  source: "`clinical_trials_ecm`.`terminology`.`meddra_pt`"
  dimensions:
    - name: "Dictionary Version"
      display_name: "MedDRA Version"
      expr: code_system_version_id
      comment: "MedDRA dictionary version for hierarchy analysis"
      format:
        type: number
        decimal_places:
          type: all
    - name: "PT Code"
      display_name: "PT Code"
      expr: pt_code
      comment: "MedDRA preferred term code"
    - name: "PT Name"
      display_name: "PT Name"
      expr: pt_name
      comment: "MedDRA preferred term name"
    - name: "Primary SOC"
      display_name: "Primary SOC ID"
      expr: primary_meddra_soc_id
      comment: "Primary System Organ Class for the preferred term"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Hierarchy Level"
      display_name: "Hierarchy Level"
      expr: hierarchy_level
      comment: "MedDRA hierarchy level indicator"
  measures:
    - name: "Total Preferred Terms"
      display_name: "Total PTs"
      expr: COUNT(1)
      comment: "Total number of MedDRA preferred terms in the hierarchy"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct PT Codes"
      display_name: "Unique PT Codes"
      expr: COUNT(DISTINCT pt_code)
      comment: "Count of unique PT codes, indicating adverse event coding granularity"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct SOCs"
      display_name: "Unique SOCs"
      expr: COUNT(DISTINCT primary_meddra_soc_id)
      comment: "Count of unique System Organ Classes, measuring safety domain coverage"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct HLTs"
      display_name: "Unique HLTs"
      expr: COUNT(DISTINCT primary_meddra_hlt_id)
      comment: "Count of unique High Level Terms, indicating mid-level hierarchy breadth"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`terminology_meddra_pt`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Tracks MedDRA preferred term (PT) hierarchy and usage for adverse event coding, enabling SOC/HLGT/HLT rollup analysis, safety signal detection, and regulatory submission readiness."
  source: "`clinical_trials_ecm`.`terminology`.`meddra_pt`"
  dimensions:
    - name: "MedDRA Version"
      display_name: "MedDRA Version"
      expr: code_system_version_id
      comment: "The MedDRA version used for this preferred term, critical for regulatory submission consistency."
      format:
        type: number
        decimal_places:
          type: all
    - name: "PT Code"
      display_name: "PT Code"
      expr: pt_code
      comment: "The MedDRA preferred term code."
    - name: "PT Name"
      display_name: "PT Name"
      expr: pt_name
      comment: "The MedDRA preferred term name."
    - name: "Primary SOC"
      display_name: "Primary SOC"
      expr: primary_meddra_soc_id
      comment: "The primary MedDRA system organ class for this PT, enabling SOC-level safety analysis."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Parent HLT"
      display_name: "Parent HLT"
      expr: parent_meddra_hlt_id
      comment: "The parent MedDRA high level term for this PT, enabling HLT-level rollup."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Primary HLT"
      display_name: "Primary HLT"
      expr: primary_meddra_hlt_id
      comment: "The primary MedDRA high level term for this PT when multiple HLTs apply."
      format:
        type: number
        decimal_places:
          type: all
  measures:
    - name: "Distinct MedDRA PTs"
      display_name: "Distinct MedDRA PTs"
      expr: COUNT(DISTINCT meddra_pt_id)
      comment: "Count of distinct MedDRA preferred terms, indicating adverse event type diversity."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct PT Names"
      display_name: "Distinct PT Names"
      expr: COUNT(DISTINCT pt_name)
      comment: "Count of distinct PT names, enabling PT usage frequency analysis."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Primary SOCs"
      display_name: "Distinct Primary SOCs"
      expr: COUNT(DISTINCT primary_meddra_soc_id)
      comment: "Count of distinct primary SOCs, indicating the breadth of organ systems affected."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`terminology_meddra_term`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Tracks MedDRA term usage and preferred term distribution for adverse event coding, enabling safety signal detection, coding quality assessment, and regulatory submission readiness."
  source: "`clinical_trials_ecm`.`terminology`.`meddra_term`"
  dimensions:
    - name: "MedDRA Version"
      display_name: "MedDRA Version"
      expr: code_system_version_id
      comment: "The MedDRA version used for this term, critical for regulatory submission consistency."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Preferred Term"
      display_name: "Preferred Term"
      expr: preferred_term
      comment: "The MedDRA preferred term (PT) used for adverse event coding."
    - name: "MedDRA PT ID"
      display_name: "MedDRA PT ID"
      expr: meddra_pt_id
      comment: "Foreign key to the MedDRA preferred term hierarchy, enabling SOC and HLGT rollup."
      format:
        type: number
        decimal_places:
          type: all
  measures:
    - name: "Distinct MedDRA Terms Used"
      display_name: "Distinct MedDRA Terms Used"
      expr: COUNT(DISTINCT meddra_term_id)
      comment: "Count of distinct MedDRA terms in use, indicating coding diversity and potential over-coding."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Preferred Terms"
      display_name: "Distinct Preferred Terms"
      expr: COUNT(DISTINCT preferred_term)
      comment: "Count of distinct preferred terms, indicating the breadth of adverse event types captured."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct MedDRA PTs Referenced"
      display_name: "Distinct MedDRA PTs Referenced"
      expr: COUNT(DISTINCT meddra_pt_id)
      comment: "Count of distinct MedDRA PT IDs referenced, enabling hierarchy rollup validation."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`terminology_snomed_ct`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Tracks SNOMED CT concept usage and hierarchy for medical history and condition coding, enabling interoperability, EHR integration, and FHIR mapping validation."
  source: "`clinical_trials_ecm`.`terminology`.`snomed_ct`"
  dimensions:
    - name: "SNOMED CT Version"
      display_name: "SNOMED CT Version"
      expr: code_system_version_id
      comment: "The SNOMED CT version used for this concept, critical for interoperability and FHIR mapping consistency."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Preferred Term"
      display_name: "Preferred Term"
      expr: preferred_term
      comment: "The SNOMED CT preferred term for the concept."
    - name: "Fully Specified Name"
      display_name: "Fully Specified Name"
      expr: fully_specified_name
      comment: "The SNOMED CT fully specified name, providing unambiguous concept identification."
    - name: "Parent Concept"
      display_name: "Parent Concept"
      expr: parent_snomed_ct_id
      comment: "The parent SNOMED CT concept in the hierarchy, enabling rollup analysis."
      format:
        type: number
        decimal_places:
          type: all
  measures:
    - name: "Distinct SNOMED CT Concepts"
      display_name: "Distinct SNOMED CT Concepts"
      expr: COUNT(DISTINCT snomed_ct_id)
      comment: "Count of distinct SNOMED CT concepts in use, indicating medical history coding diversity."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Preferred Terms"
      display_name: "Distinct Preferred Terms"
      expr: COUNT(DISTINCT preferred_term)
      comment: "Count of distinct preferred terms, enabling term usage frequency analysis."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Concepts with Parent"
      display_name: "Concepts with Parent"
      expr: COUNT(DISTINCT CASE WHEN parent_snomed_ct_id IS NOT NULL THEN snomed_ct_id END)
      comment: "Count of concepts with a parent in the hierarchy, indicating hierarchy completeness."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`terminology_snomed_ct_clinical_terminology`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "SNOMED CT clinical terminology coverage and hierarchy utilization metrics for comprehensive clinical data standardization"
  source: "`clinical_trials_ecm`.`terminology`.`snomed_ct`"
  dimensions:
    - name: "Preferred Term"
      display_name: "Preferred Term"
      expr: preferred_term
      comment: "SNOMED CT preferred term for standardized clinical concept representation"
    - name: "Fully Specified Name"
      display_name: "Fully Specified Name"
      expr: fully_specified_name
      comment: "SNOMED CT fully specified name for unambiguous clinical concept identification"
  measures:
    - name: "Total SNOMED CT Concepts"
      display_name: "Total SNOMED CT Concepts"
      expr: COUNT(1)
      comment: "Total count of SNOMED CT concepts available for clinical terminology standardization"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Preferred Terms"
      display_name: "Distinct Preferred Terms"
      expr: COUNT(DISTINCT preferred_term)
      comment: "Unique SNOMED CT preferred terms, indicating clinical vocabulary breadth"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Concepts With Parent"
      display_name: "Concepts With Parent"
      expr: SUM(CAST(CASE WHEN parent_snomed_ct_id IS NOT NULL THEN 1 ELSE 0 END AS INT))
      comment: "Count of SNOMED CT concepts with parent hierarchy linkage, indicating hierarchical terminology depth"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`terminology_codelist_submission`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "CDISC controlled terminology codelist submission readiness and standards compliance metrics for regulatory data exchange"
  source: "`clinical_trials_ecm`.`terminology`.`terminology_codelist`"
  dimensions:
    - name: "Code System"
      display_name: "Code System ID"
      expr: code_system_id
      comment: "CDISC code system for the controlled terminology codelist"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Codelist OID"
      display_name: "Codelist OID"
      expr: codelist_oid
      comment: "Object identifier for the CDISC codelist"
    - name: "Codelist Version"
      display_name: "Codelist Version"
      expr: codelist_version
      comment: "Version of the CDISC controlled terminology codelist"
    - name: "Version"
      display_name: "Version"
      expr: version
      comment: "Overall version identifier for the codelist package"
  measures:
    - name: "Total Codelists"
      display_name: "Total Codelists"
      expr: COUNT(1)
      comment: "Total number of CDISC controlled terminology codelists available for submission"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Codelist OIDs"
      display_name: "Unique Codelist OIDs"
      expr: COUNT(DISTINCT codelist_oid)
      comment: "Count of unique codelist OIDs, indicating CDISC standards coverage"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Codelist Versions"
      display_name: "Unique Codelist Versions"
      expr: COUNT(DISTINCT codelist_version)
      comment: "Count of unique codelist versions, measuring terminology currency"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Submission Value"
      display_name: "Total Submission Value"
      expr: SUM(CAST(submission_value AS DOUBLE))
      comment: "Sum of submission values across codelists for regulatory package completeness"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`terminology_whodrug_atc_classification`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "WHODrug ATC Level 4 classification coverage and therapeutic category utilization metrics for drug safety and pharmacovigilance"
  source: "`clinical_trials_ecm`.`terminology`.`whodrug_atc_level4`"
  dimensions:
    - name: "ATC Code"
      display_name: "ATC Code"
      expr: atc_code
      comment: "ATC Level 4 code for therapeutic/pharmacological drug classification"
    - name: "Level4 Name"
      display_name: "ATC Level 4 Name"
      expr: level4_name
      comment: "ATC Level 4 name for human-readable therapeutic category description"
    - name: "Dictionary Version"
      display_name: "Dictionary Version"
      expr: dictionary_version
      comment: "WHODrug dictionary version for ATC classification version tracking"
    - name: "Record Status"
      display_name: "Record Status"
      expr: record_status
      comment: "ATC record status (active/deprecated) for classification currency tracking"
    - name: "Deprecated Flag"
      display_name: "Deprecated Flag"
      expr: deprecated_flag
      comment: "Whether the ATC Level 4 code is deprecated, requiring reclassification"
  measures:
    - name: "Total ATC Level4 Codes"
      display_name: "Total ATC Level 4 Codes"
      expr: COUNT(1)
      comment: "Total count of ATC Level 4 codes available for drug therapeutic classification"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct ATC Codes"
      display_name: "Distinct ATC Codes"
      expr: COUNT(DISTINCT atc_code)
      comment: "Unique ATC Level 4 codes in use, indicating therapeutic classification coverage"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Active ATC Codes Count"
      display_name: "Active ATC Codes"
      expr: SUM(CAST(CASE WHEN deprecated_flag = FALSE THEN 1 ELSE 0 END AS INT))
      comment: "Count of active (non-deprecated) ATC Level 4 codes available for current drug classification"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Deprecated ATC Codes Count"
      display_name: "Deprecated ATC Codes"
      expr: SUM(CAST(CASE WHEN deprecated_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of deprecated ATC Level 4 codes requiring drug reclassification or version migration"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Average CDISC Submission Value"
      display_name: "Avg CDISC Submission Value"
      expr: AVG(CAST(cdisc_submission_value AS DOUBLE))
      comment: "Average CDISC submission value across ATC Level 4 codes for regulatory submission analysis"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`terminology_whodrug_atc_level4`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Tracks ATC Level 4 (chemical subgroup) usage for concomitant medication classification, enabling therapeutic class analysis, drug interaction assessment, and regulatory submission readiness."
  source: "`clinical_trials_ecm`.`terminology`.`whodrug_atc_level4`"
  dimensions:
    - name: "ATC Level 4 Code"
      display_name: "ATC Level 4 Code"
      expr: atc_code
      comment: "The ATC Level 4 code (chemical subgroup) for the drug."
    - name: "Level 4 Name"
      display_name: "Level 4 Name"
      expr: level4_name
      comment: "The human-readable name for the ATC Level 4 classification."
    - name: "Dictionary Version"
      display_name: "Dictionary Version"
      expr: dictionary_version
      comment: "The WHODrug dictionary version for this ATC Level 4 code."
    - name: "ATC Level 3 Parent"
      display_name: "ATC Level 3 Parent"
      expr: whodrug_atc_level3_id
      comment: "The parent ATC Level 3 (pharmacological subgroup) for this Level 4 code, enabling rollup analysis."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Deprecated Flag"
      display_name: "Deprecated Flag"
      expr: deprecated_flag
      comment: "Indicates whether this ATC Level 4 code has been deprecated, enabling version migration tracking."
    - name: "Effective From Year"
      display_name: "Effective From Year"
      expr: YEAR(effective_from_date)
      comment: "Year the ATC Level 4 code became effective, for trend analysis."
      format:
        type: date
        date_format: year
        leading_zeros: true
  measures:
    - name: "Distinct ATC Level 4 Codes"
      display_name: "Distinct ATC Level 4 Codes"
      expr: COUNT(DISTINCT whodrug_atc_level4_id)
      comment: "Count of distinct ATC Level 4 codes in use, indicating therapeutic class diversity."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct ATC Code Strings"
      display_name: "Distinct ATC Code Strings"
      expr: COUNT(DISTINCT atc_code)
      comment: "Count of distinct ATC code strings, enabling duplicate detection and mapping validation."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Deprecated ATC Codes"
      display_name: "Deprecated ATC Codes"
      expr: COUNT(DISTINCT CASE WHEN deprecated_flag = TRUE THEN whodrug_atc_level4_id END)
      comment: "Count of deprecated ATC Level 4 codes, indicating version migration risk."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Active ATC Codes"
      display_name: "Active ATC Codes"
      expr: COUNT(DISTINCT CASE WHEN deprecated_flag = FALSE THEN whodrug_atc_level4_id END)
      comment: "Count of active (non-deprecated) ATC Level 4 codes, indicating current therapeutic class coverage."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`terminology_whodrug_drug_record`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Tracks WHODrug drug record usage and ATC classification for concomitant medication coding, enabling drug interaction analysis, ATC-based safety reporting, and regulatory submission readiness."
  source: "`clinical_trials_ecm`.`terminology`.`whodrug_drug_record`"
  dimensions:
    - name: "WHODrug Version"
      display_name: "WHODrug Version"
      expr: code_system_version_id
      comment: "The WHODrug version used for this drug record, critical for regulatory submission consistency."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Trade Name"
      display_name: "Trade Name"
      expr: trade_name
      comment: "The trade name of the drug product, as coded in WHODrug."
    - name: "Ingredient"
      display_name: "Ingredient"
      expr: ingredient
      comment: "The active ingredient of the drug product, enabling ingredient-level analysis."
    - name: "ATC Level 4"
      display_name: "ATC Level 4"
      expr: whodrug_atc_level4_id
      comment: "The ATC Level 4 classification (chemical subgroup) for the drug, enabling therapeutic class analysis."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Primary ATC Level 4"
      display_name: "Primary ATC Level 4"
      expr: primary_whodrug_atc_level4_id
      comment: "The primary ATC Level 4 classification when a drug has multiple ATC codes."
      format:
        type: number
        decimal_places:
          type: all
  measures:
    - name: "Distinct WHODrug Records"
      display_name: "Distinct WHODrug Records"
      expr: COUNT(DISTINCT whodrug_drug_record_id)
      comment: "Count of distinct WHODrug drug records in use, indicating concomitant medication diversity."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Trade Names"
      display_name: "Distinct Trade Names"
      expr: COUNT(DISTINCT trade_name)
      comment: "Count of distinct trade names, indicating the breadth of concomitant medications captured."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Ingredients"
      display_name: "Distinct Ingredients"
      expr: COUNT(DISTINCT ingredient)
      comment: "Count of distinct active ingredients, enabling ingredient-level drug interaction analysis."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct ATC Level 4 Classes"
      display_name: "Distinct ATC Level 4 Classes"
      expr: COUNT(DISTINCT whodrug_atc_level4_id)
      comment: "Count of distinct ATC Level 4 classifications, indicating therapeutic class diversity."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`terminology_whodrug_medication_coding`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "WHODrug medication coding coverage and ATC classification metrics for concomitant medication and drug safety analysis"
  source: "`clinical_trials_ecm`.`terminology`.`whodrug_drug_record`"
  dimensions:
    - name: "Drug Record Number"
      display_name: "Drug Record Number"
      expr: drug_record_number
      comment: "WHODrug unique drug record identifier for medication coding traceability"
    - name: "Trade Name"
      display_name: "Trade Name"
      expr: trade_name
      comment: "Commercial trade name of the drug product for market-specific medication coding"
    - name: "Ingredient"
      display_name: "Active Ingredient"
      expr: ingredient
      comment: "Active pharmaceutical ingredient for substance-level medication analysis"
  measures:
    - name: "Total Drug Records"
      display_name: "Total Drug Records"
      expr: COUNT(1)
      comment: "Total count of WHODrug drug records available for medication coding and safety reporting"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Drug Record Numbers"
      display_name: "Distinct Drug Records"
      expr: COUNT(DISTINCT drug_record_number)
      comment: "Unique WHODrug drug record numbers, indicating medication vocabulary coverage"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Trade Names"
      display_name: "Distinct Trade Names"
      expr: COUNT(DISTINCT trade_name)
      comment: "Unique trade names in WHODrug, measuring commercial drug product diversity"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Ingredients"
      display_name: "Distinct Ingredients"
      expr: COUNT(DISTINCT ingredient)
      comment: "Unique active pharmaceutical ingredients, indicating substance-level medication coverage"
      format:
        type: number
        decimal_places:
          type: all
$$;
