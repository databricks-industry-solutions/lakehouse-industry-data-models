-- Schema for Domain: workforce | Business: Clinical_Trials | Version: v2_ecm
-- Generated on: 2026-11-20 10:03:02

CREATE DATABASE IF NOT EXISTS `clinical_trials_ecm`.`workforce` COMMENT 'Manages the clinical research workforce including CRAs, CRCs, biostatisticians, data managers, medical monitors, and regulatory specialists. Owns employee profiles, GCP training and certification records, delegation logs, resource allocation to studies';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`workforce`.`employee` (
    `employee_id` BIGINT COMMENT 'Unique surrogate identifier for each workforce member in the Clinical Trials organization. Primary key for the employee master record and the single source of truth (SSOT) for workforce identity referenced by training records, study assignments',
    `job_profile_id` BIGINT COMMENT 'Foreign key linking to workforce.job_profile. Business justification: employee.job_profile_code is a denormalized STRING reference to job_profile. Adding a proper FK employee.job_profile_id → job_profile.job_profile_id normalizes this relationship.',
    `manager_employee_id` BIGINT COMMENT 'Employee ID of the direct reporting manager for this workforce member, establishing the organizational hierarchy. Used for approval workflows in MasterControl (CAPA, training sign-off), delegation authority chains, and workforce planning.',
    `billing_rate_usd` DECIMAL(10,2) COMMENT 'The standard hourly or daily billing rate for this workforce member in US dollars, used for sponsor invoicing, study budget calculations, and scope-of-work costing. Confidential financial data managed in the source system',
    `cdisc_certified` BOOLEAN COMMENT 'Indicates whether the workforce member holds a current CDISC certification (e.g., CDISC SDTM, ADaM). Relevant for Data Managers and Biostatisticians assigned to CDISC-compliant submission deliverables.',
    `cost_center_code` STRING COMMENT 'the source system center to which the employees labor costs are charged. Enables project accounting, study-level cost allocation, and financial reporting for sponsor invoicing and internal P&L analysis.',
    `ctms_user_code` STRING COMMENT 'The user account identifier for this workforce member in the source system Used to link employee records to site monitoring visits, study assignments, and delegation log entries within the CTMS.',
    `department_code` STRING COMMENT 'Organizational department code from the source system which the workforce member is assigned (e.g., Clinical Operations, Biostatistics, Data Management, Regulatory Affairs). Used for resource allocation reporting and capacity planning.',
    `department_name` STRING COMMENT 'Human-readable name of the organizational department to which the workforce member belongs. Complements department_code for reporting and display purposes in CTMS and workforce dashboards.',
    `edc_user_code` STRING COMMENT 'The user account identifier for this workforce member in Medidata Rave EDC. Required for audit trail attribution of data entry, query management, and SDV activities per 21 CFR Part 11 and ALCOA+ principles.',
    `employment_status` STRING COMMENT 'Current lifecycle state of the workforce members employment. Controls access to EDC systems (Medidata Rave), CTMS (the source system (Veeva Vault), and determines eligibility for new study assignments.. Valid values are `active|on_leave|terminated|suspended|pending_start`',
    `employment_type` STRING COMMENT 'Classification of the workforce members engagement model with the CRO. Drives payroll processing rules in the source system allocation in the source system eligibility for study assignment roles under GCP.. Valid values are `full_time|part_time|contractor|consultant|intern`',
    `etmf_user_code` STRING COMMENT 'The user account identifier for this workforce member in Veeva Vault eTMF. Used to attribute document uploads, approvals, and access events in the trial master file audit trail per ICH E6(R2) and 21 CFR Part 11.',
    `first_name` STRING COMMENT 'Legal given name of the workforce member as recorded in the source system for identity verification, delegation logs, and regulatory documentation including GCP training certificates.',
    `fte_percentage` DECIMAL(5,2) COMMENT 'The proportion of a full-time equivalent that this workforce member represents, expressed as a percentage (e.g., 100.00 for full-time, 50.00 for half-time).',
    `gcp_certification_expiry_date` DATE COMMENT 'The date on which the workforce members current GCP certification expires. Used to trigger renewal training workflows in MasterControl and to flag employees approaching expiry for study assignment eligibility checks.',
    `gcp_certified` BOOLEAN COMMENT 'Indicates whether the workforce member currently holds a valid GCP certification as required by ICH E6(R2). A value of True is a prerequisite for assignment to study roles involving direct patient data or site oversight.',
    `gcp_role` STRING COMMENT 'The primary GCP-defined functional role of the workforce member within clinical research operations. Determines which study activities the employee may be delegated to perform, which training curricula apply in MasterControl, and which CTMS access',
    `highest_education_level` STRING COMMENT 'The highest academic qualification attained by the workforce member, as recorded in the source system for role eligibility checks (e.g., Medical Monitor requires MD/PhD), regulatory submission CVs, and sponsor qualification packages.. Valid values are `high_school|associate|bachelor|master|doctorate|professional_degree`',
    `hire_date` DATE COMMENT 'The date on which the workforce member officially commenced employment or engagement with the CRO, as recorded in the source system to calculate tenure, GCP training due dates, and eligibility windows for study assignments.',
    `is_key_personnel` BOOLEAN COMMENT 'Indicates whether this workforce member is designated as key personnel on one or more active study contracts or regulatory submissions. Key personnel changes may require sponsor notification and regulatory amendment per ICH E6(R2) and FDA guidance.',
    `job_title` STRING COMMENT 'Official job title of the workforce member as defined in the source system on delegation logs, regulatory submissions, and sponsor-facing documentation. Examples: Senior Clinical Research Associate, Principal Biostatistician, Data Manager II.',
    `last_name` STRING COMMENT 'Legal family name of the workforce member as recorded in the source system in combination with first_name for full identity across regulatory submissions, delegation logs, and site monitoring documentation.',
    `nationality_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code representing the workforce members nationality. Used for visa and work authorization tracking, international study assignment eligibility, and regulatory authority jurisdiction compliance.. Valid values are `^[A-Z]{3}$`',
    `pay_grade` STRING COMMENT 'Compensation grade band assigned to the workforce member in the source system the salary range and benefits tier. Confidential HR data used for compensation equity analysis and workforce cost modeling.',
    `preferred_name` STRING COMMENT 'The name the workforce member prefers to be addressed by in operational communications and CTMS displays. May differ from legal name; does not replace legal name for regulatory documents.',
    `professional_license_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the jurisdiction that issued the workforce members professional license. Used to validate regulatory eligibility for study roles in specific geographies.. Valid values are `^[A-Z]{3}$`',
    `professional_license_number` STRING COMMENT 'Professional license or registration number for regulated roles (e.g., medical license for Medical Monitors, nursing license for CRCs). Required for regulatory submissions and delegation log validation. Confidential business data.',
    `record_created_timestamp` TIMESTAMP COMMENT 'The timestamp when the employee master record was first created in the lakehouse silver layer, sourced from the source system completion. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ principles.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'The timestamp of the most recent update to the employee master record in the lakehouse silver layer. Used for change data capture, data lineage tracking, and audit trail completeness per 21 CFR Part 11 and ALCOA+.',
    `region_assignment` STRING COMMENT 'The geographic region to which the workforce member is primarily assigned for study operations (e.g., North America, Europe, Asia-Pacific). Used for regional capacity planning, CRA territory management, and sponsor reporting.',
    `termination_date` DATE COMMENT 'The date on which the workforce members employment or engagement ended, as recorded in the source system for active employees. Triggers deprovisioning of EDC, CTMS, and eTMF system access and flags open delegation log entries for reassignment.',
    `termination_reason` STRING COMMENT 'Categorized reason for the workforce members departure from the CRO, sourced from the source system for attrition analytics, workforce planning, and audit trail completeness for regulatory inspections.. Valid values are `voluntary_resignation|involuntary_termination|contract_end|retirement|transfer|redundancy`',
    `therapeutic_area_expertise` STRING COMMENT 'Primary therapeutic area(s) in which the workforce member has documented expertise (e.g., Oncology, Cardiology, Neurology, Infectious Disease). Used for study assignment matching, resource allocation, and sponsor capability presentations.',
    `time_zone` STRING COMMENT 'IANA time zone identifier for the workforce members primary work location (e.g., America/New_York, Europe/London). Used for scheduling site monitoring visits, DSMB meetings, and regulatory submission deadlines.',
    `work_authorization_status` STRING COMMENT 'Current work authorization status of the workforce member for their primary work country. Determines eligibility for international study assignments and site visits. Managed in the source system. Valid values are `authorized|visa_required|pending_authorization|expired`',
    `work_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the workforce members primary work location. Determines applicable labor law, data privacy regulations (GDPR, HIPAA), and regulatory authority jurisdiction for GCP compliance.. Valid values are `^[A-Z]{3}$`',
    `work_email` STRING COMMENT 'Primary corporate email address for the workforce member, used for system access provisioning, eTMF notifications, EDC account creation in Medidata Rave, and regulatory correspondence routing.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `work_location_code` STRING COMMENT 'Code identifying the primary physical or virtual work location of the workforce member (e.g., office site, home-based, field-based). Used for resource allocation, travel cost planning, and site monitoring coverage mapping.',
    `work_phone` STRING COMMENT 'Primary work telephone number for the workforce member, used for site monitoring coordination, SAE escalation contact chains, and sponsor communication.',
    `workday_worker_code` STRING COMMENT 'The native worker identifier assigned by the source system for cross-system reconciliation between the lakehouse silver layer and the operational HR system of record.',
    `years_of_experience` BIGINT COMMENT 'Total number of years of clinical research industry experience for the workforce member, as recorded in the source system the CTMS resource profile. Used for study assignment eligibility, seniority-based billing rates, and sponsor qualification',
    CONSTRAINT pk_employee PRIMARY KEY(`employee_id`)
) COMMENT 'Master record for every clinical research workforce member employed by or contracted to the CRO, sourced from the source system full employee identity, job profile assignment, organizational unit, employment type (full-time, part-time, contractor)';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`workforce`.`job_profile` (
    `job_profile_id` BIGINT COMMENT 'Unique surrogate identifier for the job profile record in the workforce data product. Primary key for the job_profile entity.',
    `org_unit_id` BIGINT COMMENT 'add column org_unit_id (BIGINT) with FK to workforce.org_unit.org_unit_id — job profiles should be associated with organizational units',
    `billable_role` BOOLEAN COMMENT 'Indicates whether employees in this job profile are billable to sponsors under study contracts. Drives project accounting in the source system financial forecasting for study budgets.',
    `billing_rate_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the standard billing rate (e.g., USD, EUR). Required for multi-currency sponsor billing and financial reporting.. Valid values are `^[A-Z]{3}$`',
    `billing_rate_unit` STRING COMMENT 'Time unit basis for the standard billing rate (hourly, daily, or monthly). Ensures consistent financial calculations across study budgets and sponsor invoices.. Valid values are `hourly|daily|monthly`',
    `cdisc_role_alignment` STRING COMMENT 'Maps the job profile to a recognized CDISC role designation (e.g., SDTM Programmer, ADaM Statistician, Data Manager). Supports CDISC-compliant study team composition and submission readiness assessments.',
    `competency_framework_version` STRING COMMENT 'Version identifier of the competency framework applied to this job profile (e.g., CF-2024-v2.1). Enables tracking of competency model evolution and gap analysis over time.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this job profile record was first created in the system. Supports audit trail requirements and data lineage tracking per 21 CFR Part 11 and ALCOA+ principles.',
    `ctms_access_level` STRING COMMENT 'Standard CTMS access level assigned to employees in this job profile within the source system Controls visibility of site, subject, and monitoring data.. Valid values are `none|read_only|standard|power_user|admin`',
    `delegation_eligible` BOOLEAN COMMENT 'Indicates whether employees in this job profile are eligible to appear on a study delegation log as a delegated task performer. Critical for GCP compliance and site inspection readiness.',
    `edc_access_level` STRING COMMENT 'Standard EDC system access level assigned to employees in this job profile within Medidata Rave. Drives system access provisioning and audit trail compliance per 21 CFR Part 11.. Valid values are `none|read_only|data_entry|query_management|admin`',
    `effective_date` DATE COMMENT 'Date from which this job profile definition became active and available for workforce assignments. Used to track profile versioning and ensure historical accuracy in workforce records.',
    `employment_type` STRING COMMENT 'Defines the standard employment arrangement associated with this job profile. Drives benefits eligibility, payroll configuration, and resource allocation planning.. Valid values are `full_time|part_time|contract|temporary`',
    `exempt_status` STRING COMMENT 'Indicates whether the job profile is classified as exempt or non-exempt under the Fair Labor Standards Act (FLSA) or equivalent local labor law. Determines overtime eligibility and payroll processing rules in the source system. Valid values are `exempt|non_exempt`',
    `expiry_date` DATE COMMENT 'Date on which this job profile definition is scheduled to expire or be retired. Null indicates an open-ended profile with no planned retirement date.',
    `gcp_role_category` STRING COMMENT 'Categorizes the job profile according to its GCP-defined role in clinical trial conduct. Drives GCP training requirements, delegation log eligibility, and regulatory inspection readiness. Values align with ICH E6(R2) role definitions.',
    `gcp_training_frequency_months` BIGINT COMMENT 'Required recertification interval in months for GCP training associated with this job profile (e.g., 24 months). Used to schedule training renewals and flag compliance gaps in MasterControl.',
    `gcp_training_required` BOOLEAN COMMENT 'Indicates whether GCP training is mandatory for employees assigned to this job profile. Drives training compliance workflows in MasterControl and regulatory inspection readiness.',
    `job_category` STRING COMMENT 'Classifies the job profile as an individual contributor, people manager, director, or executive. Used for span-of-control analysis and leadership pipeline planning.. Valid values are `individual_contributor|manager|director|executive`',
    `job_family` STRING COMMENT 'Broad functional grouping to which this job profile belongs within the clinical research organization. Drives workforce planning, competency frameworks, and organizational reporting.',
    `job_family_group` STRING COMMENT 'Higher-level grouping above job family used for workforce analytics and organizational hierarchy reporting in the source system Research & Development, Corporate Functions).',
    `job_level` STRING COMMENT 'Seniority tier of the job profile within its job family. Determines scope of responsibilities, delegation authority, and salary band eligibility. Values: Associate, Senior, Principal, Director, Executive.. Valid values are `Associate|Senior|Principal|Director|Executive`',
    `key_competencies` STRING COMMENT 'Comma-separated list of core competencies required for this job profile (e.g., Protocol Deviation Management, SDV, eCRF Review, Site Relationship Management). Used in competency gap analysis and talent development planning.',
    `last_reviewed_date` DATE COMMENT 'Date on which this job profile was last reviewed and approved by HR or the relevant business owner. Supports periodic review compliance and ensures profiles remain current with regulatory and business requirements.',
    `management_level` BIGINT COMMENT 'Numeric management tier within the organizational hierarchy (e.g., 1 = individual contributor, 2 = team lead, 3 = manager, 4 = director). Supports org chart rendering and reporting chain analysis.',
    `profile_code` STRING COMMENT 'Standardized alphanumeric code uniquely identifying the job profile across the organization. Used in workforce planning, delegation logs, and resource allocation systems.. Valid values are `^[A-Z0-9_-]{3,20}$`',
    `profile_name` STRING COMMENT 'Human-readable title of the job profile as defined in the the source system catalog (e.g., Senior Clinical Research Associate, Principal Biostatistician).',
    `profile_owner` STRING COMMENT 'Name or identifier of the HR business partner or functional leader responsible for maintaining this job profile definition. Provides accountability for profile accuracy and timely review.',
    `profile_status` STRING COMMENT 'Current lifecycle status of the job profile. active profiles are available for staffing; inactive profiles are retired from use; draft profiles are under review; archived profiles are retained for historical reference.. Valid values are `active|inactive|draft|archived`',
    `regulatory_submission_access` BOOLEAN COMMENT 'Indicates whether this job profile is authorized to access and contribute to regulatory submission documents in Veeva Vault. Supports 21 CFR Part 11 electronic records access controls.',
    `remote_eligible` BOOLEAN COMMENT 'Indicates whether this job profile is approved for remote or hybrid work arrangements. Used in workforce planning and resource allocation decisions.',
    `required_certifications` STRING COMMENT 'Comma-separated list of mandatory professional certifications for this job profile (e.g., GCP Certificate, ACRP CCRA, CCDM). Drives training compliance tracking in MasterControl and the source system',
    `required_education_level` STRING COMMENT 'Minimum academic qualification required for this job profile. Used in talent acquisition screening, competency gap analysis, and regulatory inspection readiness for GCP-critical roles.. Valid values are `high_school|associate|bachelor|master|doctorate|professional`',
    `required_years_experience` BIGINT COMMENT 'Minimum number of years of relevant professional experience required for this job profile. Used in recruitment screening and workforce planning.',
    `safety_reporting_role` BOOLEAN COMMENT 'Indicates whether this job profile carries responsibilities for adverse event (AE) or serious adverse event (SAE) reporting. Drives access provisioning in the source system and regulatory notification workflows.',
    `salary_band_code` STRING COMMENT 'Alphanumeric code identifying the compensation band assigned to this job profile (e.g., G5, M3). Determines the approved salary range for workforce planning and compensation benchmarking. Classified as confidential business data.. Valid values are `^[A-Z]{1,3}[0-9]{1,3}$`',
    `salary_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the salary range values (e.g., USD, EUR, GBP). Required for multi-currency workforce planning and financial reporting.. Valid values are `^[A-Z]{3}$`',
    `salary_range_max` DECIMAL(18,2) COMMENT 'Maximum base salary (in local currency) approved for this job profile within its salary band. Used for compensation planning, offer management, and equity analysis. Classified as confidential.',
    `salary_range_min` DECIMAL(18,2) COMMENT 'Minimum base salary (in local currency) approved for this job profile within its salary band. Used for compensation planning, offer management, and equity analysis. Classified as confidential.',
    `sop_training_curriculum` STRING COMMENT 'Identifier or name of the SOP training curriculum assigned to this job profile in MasterControl. Defines the set of SOPs that employees must complete upon onboarding and at defined intervals.',
    `standard_billing_rate` DECIMAL(18,2) COMMENT 'Standard hourly or daily billing rate for this job profile when charged to sponsor study contracts. Used in financial forecasting, budget line creation, and invoice generation in the source system as confidential.',
    `travel_requirement` STRING COMMENT 'Expected travel frequency for employees in this job profile. Particularly relevant for CRA and site monitoring roles requiring regular site visits.. Valid values are `none|occasional|frequent|extensive`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this job profile record was last modified. Supports change tracking, audit trail compliance, and Silver layer incremental load processing.',
    `work_shift` STRING COMMENT 'Standard work shift pattern associated with this job profile. Relevant for site monitoring roles and laboratory positions requiring non-standard hours.. Valid values are `standard|rotating|on_call|flexible`',
    `workday_job_profile_code` STRING COMMENT 'The native identifier assigned to this job profile within the source system catalog. Used for system-of-record traceability and integration reconciliation.',
    CONSTRAINT pk_job_profile PRIMARY KEY(`job_profile_id`)
) COMMENT 'Reference master defining standardized job profiles and role classifications used across the clinical research workforce. Captures job family (Clinical Operations, Biostatistics, Data Management, Regulatory Affairs, Medical Affairs), job level (Associate';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` (
    `gcp_training_record_id` BIGINT COMMENT 'Unique surrogate identifier for each GCP training record in the Silver Layer lakehouse. Primary key for this transactional entity. TRANSACTION_HEADER role — captures a discrete training completion event for a workforce member.',
    `electronic_signature_id` BIGINT COMMENT 'Unique identifier of the electronic signature applied to this training record in MasterControl, confirming the workforce members acknowledgment of training completion. Required for 21 CFR Part 11 compliance for electronic records.',
    `employee_id` BIGINT COMMENT 'Reference to the workforce member (CRA, CRC, biostatistician, data manager, medical monitor, regulatory specialist, etc.) who completed this GCP training. Sourced from the source system record.',
    `investigational_site_id` BIGINT COMMENT 'Reference to the clinical trial site for which this site-specific or protocol-specific GCP training was completed. Null for general GCP training not tied to a specific site. Used for site-level compliance reporting.',
    `study_assignment_id` BIGINT COMMENT 'Foreign key linking to workforce.study_assignment. Business justification: gcp_training_record already has employee_id and study_id, but linking to the specific study_assignment provides richer context — it ties the GCP training completion to the formal',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this protocol-specific GCP training was completed. Null for general GCP training not tied to a specific study. Used to verify study-specific training compliance on delegation logs.',
    `tmf_document_id` BIGINT COMMENT 'Reference to the scanned or electronic training certificate stored in Veeva Vault eTMF or MasterControl document management. Enables direct access to the source certificate for audit and inspection purposes.',
    `training_course_id` BIGINT COMMENT 'Reference to the training course master record in MasterControl that defines the course curriculum, version, and requirements for this GCP training.',
    `training_curriculum_id` BIGINT COMMENT 'Foreign key linking to workforce.training_curriculum. Business justification: gcp_training_record has is_curriculum_required (BOOLEAN) indicating it may be part of a structured curriculum, but lacks a FK to training_curriculum.',
    `assessment_score` DECIMAL(5,2) COMMENT 'Numeric score achieved by the workforce member on the GCP training assessment, expressed as a percentage (0.00–100.00). Null if no assessment was administered (read-and-acknowledge training type).',
    `assigned_date` DATE COMMENT 'The date on which this GCP training was formally assigned to the workforce member in MasterControl. Used to calculate time-to-completion and overdue status.',
    `certificate_issued_date` DATE COMMENT 'The date on which the training certificate was formally issued by the training provider. May differ from completion_date if certificate issuance involves a processing delay. Required for TMF documentation.',
    `certificate_number` STRING COMMENT 'Unique certificate or credential reference number issued upon successful completion of the GCP training. Used for regulatory inspection readiness, TMF filing, and delegation log verification. Aligns with ALCOA+ original documentation requirements.',
    `comments` STRING COMMENT 'Free-text field for additional notes or context related to this GCP training record (e.g., special circumstances, remedial training context, inspector observations). Supports ALCOA+ completeness principle.',
    `completion_date` DATE COMMENT 'The date on which the workforce member successfully completed the GCP training. This is the principal business event date for this transaction record. Used to calculate training currency and expiry.',
    `course_code` STRING COMMENT 'Alphanumeric code uniquely identifying the training course in MasterControl (e.g., TRN-GCP-001). Used for structured reporting, filtering, and integration with CTMS and eTMF systems.',
    `course_name` STRING COMMENT 'Full name of the GCP training course as defined in MasterControl (e.g., ICH E6(R2) GCP Fundamentals, GCP Refresher Training, Protocol-Specific GCP Training — Study XYZ-001). Used for reporting and compliance verification.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time at which this GCP training record was first created in the source system (MasterControl). Used for audit trail, data lineage, and ALCOA+ compliance verification.',
    `due_date` DATE COMMENT 'The deadline by which the workforce member must complete this GCP training as defined in MasterControl. Used for compliance monitoring, overdue tracking, and escalation workflows.',
    `expiry_date` DATE COMMENT 'The date on which this GCP training certification expires and a refresher training is required. Typically 2–3 years from completion date per sponsor and regulatory requirements.',
    `gcp_guideline_version` STRING COMMENT 'The specific version of the GCP guideline covered by this training (e.g., ICH E6(R2), ICH E6(R3)). Critical for regulatory compliance verification — regulators require training to be current with the applicable guideline version.. Valid values are `ICH E6(R1)|ICH E6(R2)|ICH E6(R3)|21 CFR Part 312|ISO 14155`',
    `is_curriculum_required` BOOLEAN COMMENT 'Indicates whether this training record was generated from a mandatory curriculum assignment (True) or was voluntarily completed outside of a formal curriculum (False). Used to distinguish mandatory compliance training from elective training.',
    `is_gcp_current` BOOLEAN COMMENT 'Indicates whether this training record represents a currently valid (non-expired) GCP certification (True) or has expired (False). Derived from expiry_date vs.',
    `last_updated_timestamp` TIMESTAMP COMMENT 'The date and time at which this GCP training record was most recently modified in the source system (MasterControl). Used for change tracking, audit trail, and Silver Layer incremental load processing.',
    `mastercontrol_record_code` STRING COMMENT 'The externally-known unique identifier assigned by MasterControl training management system to this training completion record. Used for cross-system traceability and audit trail back to the system of record.',
    `max_attempts_allowed` BIGINT COMMENT 'The maximum number of assessment attempts permitted for this GCP training course as configured in MasterControl. Captured at training time to preserve the applicable policy.',
    `number_of_attempts` BIGINT COMMENT 'Total number of attempts the workforce member made on the GCP training assessment before achieving a pass or exhausting allowed attempts. Used for quality monitoring and identifying personnel who may need additional support.',
    `pass_fail_status` STRING COMMENT 'Outcome of the training assessment: pass (met or exceeded minimum passing score), fail (did not meet minimum passing score — remedial training required), not_applicable (no assessment required for this training type, e.g., read-and-acknowledge only).. Valid values are `pass|fail|not_applicable`',
    `passing_score_threshold` DECIMAL(5,2) COMMENT 'The minimum assessment score percentage required to pass this GCP training course (e.g., 80.00%). Captured at the time of training completion to preserve the applicable standard even if the course threshold changes in future.',
    `regulatory_submission_flag` BOOLEAN COMMENT 'Indicates whether this training record has been included in a regulatory submission package (e.g., IND, NDA, BLA, MAA, eCTD) as evidence of GCP-trained personnel. True if included in at least one submission; False otherwise.',
    `role_at_training` STRING COMMENT 'The workforce role of the employee at the time of training completion (e.g., CRA, CRC, PI, Sub-Investigator, Data Manager, Biostatistician, Medical Monitor, Regulatory Affairs Specialist).',
    `signature_timestamp` TIMESTAMP COMMENT 'The date and time at which the workforce member applied their electronic signature to acknowledge completion of the GCP training in MasterControl. Required for 21 CFR Part 11 audit trail compliance.',
    `tmf_filing_reference` STRING COMMENT 'The TMF artifact reference number or section code where this training record is filed in the eTMF (e.g., Veeva Vault TMF section 05.01 — Curriculum Vitae and GCP Training). Enables direct traceability between training records and TMF documentation.',
    `trainer_name` STRING COMMENT 'Full name of the instructor or trainer who delivered the GCP training (for classroom, webinar, or on-the-job training types). Null for self-paced e-learning. Required for regulatory documentation per ALCOA+ attributability principle.',
    `trainer_qualification` STRING COMMENT 'Qualifications or credentials of the trainer who delivered the GCP training (e.g., Certified GCP Trainer, CCRP, MD, PhD). Documents trainer competency as required for regulatory inspection readiness.',
    `training_delivery_method` STRING COMMENT 'The modality through which the GCP training was delivered: e_learning (self-paced online module in MasterControl), classroom (in-person instructor-led), webinar (live virtual instructor-led), on_the_job (supervised practical training), blended. Valid values are `e_learning|classroom|webinar|on_the_job|blended`',
    `training_duration_hours` DECIMAL(5,2) COMMENT 'Total duration of the GCP training course in hours (e.g., 2.50 for a 2.5-hour e-learning module). Used for workforce capacity planning, training hour reporting, and regulatory documentation of training effort.',
    `training_provider` STRING COMMENT 'Name of the organization or entity that delivered the GCP training (e.g., CITI Program, TransCelerate, Internal Training Department, ACRP, SOCRA, External CRO Training Vendor). Required for regulatory documentation and audit trail.',
    `training_provider_type` STRING COMMENT 'Classification of the training provider: internal (delivered by the CROs own training department), external (third-party training vendor), sponsor (delivered by the pharmaceutical/biotech sponsor), regulatory_body (delivered by FDA, EMA, ICH, or. Valid values are `internal|external|sponsor|regulatory_body`',
    `training_status` STRING COMMENT 'Current lifecycle status of this training record: completed (training finished and passed), in_progress (training assigned and started but not yet finished), overdue (past due date without completion), waived (formally waived with documented. Valid values are `completed|in_progress|overdue|waived|cancelled`',
    `training_type` STRING COMMENT 'Classification of the training event: initial (first-time GCP certification), refresher (periodic renewal), protocol_specific (study-specific GCP requirements), role_specific (role-based GCP training for CRA, CRC, PI, etc.), remedial (corrective. Valid values are `initial|refresher|protocol_specific|role_specific|remedial`',
    `waiver_approved_by` STRING COMMENT 'Name or identifier of the authorized person (e.g., QA Manager, Training Manager) who approved the training waiver. Null if training_status is not waived. Required for regulatory accountability per ALCOA+ attributability principle.',
    `waiver_date` DATE COMMENT 'The date on which the training waiver was formally approved. Null if training_status is not waived. Required for audit trail and regulatory inspection readiness.',
    `waiver_reason` STRING COMMENT 'Documented justification for waiving this GCP training requirement (e.g., Equivalent training completed at prior employer within validity period, Regulatory authority-recognized equivalent certification held). Null if training_status is not waived.',
    CONSTRAINT pk_gcp_training_record PRIMARY KEY(`gcp_training_record_id`)
) COMMENT 'Transactional record of GCP (Good Clinical Practice) training completions for each workforce member, sourced from MasterControl training management module.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`workforce`.`certification` (
    `certification_id` BIGINT COMMENT 'Unique surrogate identifier for each professional certification record held by a clinical research workforce member. Primary key for the certification data product.',
    `employee_id` BIGINT COMMENT 'Reference to the workforce member (CRA, CRC, biostatistician, data manager, medical monitor, regulatory specialist, etc.) who holds this certification. Links to the employee/worker master record in the source system',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to.',
    `ce_credits_earned` DECIMAL(6,2) COMMENT 'Total number of continuing education (CE) credits earned by the workforce member in the current renewal cycle toward maintaining or renewing this certification. Compared against ce_credits_required to assess compliance gap.',
    `ce_credits_required` DECIMAL(6,2) COMMENT 'Total number of continuing education (CE) credits required by the issuing body to maintain or renew the certification within the current renewal cycle. Used to track workforce compliance with professional development obligations.',
    `ce_cycle_end_date` DATE COMMENT 'End date of the current continuing education (CE) credit accumulation cycle for this certification. CE credits must be earned by this date to satisfy the renewal requirement.',
    `ce_cycle_start_date` DATE COMMENT 'Start date of the current continuing education (CE) credit accumulation cycle for this certification. CE credits earned before this date do not count toward the current renewal requirement.',
    `cost_amount` DECIMAL(10,2) COMMENT 'Total monetary cost incurred by the organization for this certification, including examination fees, application fees, and renewal fees paid to the issuing body. Expressed in the currency specified by cost_currency.',
    `cost_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the cost_amount (e.g., USD, EUR, GBP, JPY). Required for multi-currency financial reporting and budget consolidation in the source system. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this certification record was first created in the system, in ISO 8601 format with timezone offset (yyyy-MM-ddTHH:mm:ss.SSSXXX). Supports ALCOA+ audit trail requirements and data lineage tracking.',
    `credential_scope` STRING COMMENT 'Geographic or organizational scope of the certifications recognition and applicability. global = recognized internationally (e.g., ICH-aligned); regional = recognized within a regulatory region (e.g., EU, Asia-Pacific); national = recognized within. Valid values are `global|regional|national|institutional`',
    `document_reference` STRING COMMENT 'Reference identifier or URL pointing to the scanned certificate document stored in the eTMF or document management system (Veeva Vault / MasterControl). Enables direct retrieval of the credential document for regulatory inspections and audit purposes.',
    `exam_date` DATE COMMENT 'Date on which the workforce member sat the certification examination. Distinct from issue_date (when the credential was formally awarded). Null if no examination was required for this credential.',
    `exam_location` STRING COMMENT 'Name or description of the testing center, proctored online platform, or venue where the certification examination was administered (e.g., Prometric Testing Center - Chicago, Online - ProctorU). Supports audit trail and verification.',
    `exam_score` DECIMAL(5,2) COMMENT 'Numeric score achieved by the workforce member on the certification examination, as reported by the issuing body. Expressed as a percentage or raw score per the issuing bodys scale. Null if the certification does not require an examination.',
    `expiry_date` DATE COMMENT 'Calendar date on which the certification expires and is no longer valid unless renewed. Null indicates a lifetime or non-expiring credential. Used for automated renewal alerts, resource allocation eligibility checks, and regulatory compliance monitoring.',
    `is_gcp_required` BOOLEAN COMMENT 'Indicates whether this certification satisfies or is required as part of the workforce members Good Clinical Practice (GCP) training and qualification obligations for study delegation.',
    `is_regulatory_required` BOOLEAN COMMENT 'Indicates whether this certification is mandated by a regulatory authority (FDA, EMA, PMDA, MHRA, Health Canada, TGA) as a prerequisite for performing specific clinical research activities.',
    `issue_date` DATE COMMENT 'Calendar date on which the certifying body officially awarded the certification to the workforce member. Establishes the start of the certifications validity period and is required for regulatory audit trails and delegation log verification.',
    `issuing_body` STRING COMMENT 'Name of the external organization that awarded and administers the certification (e.g., ACRP - Association of Clinical Research Professionals, SOCRA - Society of Clinical Research Associates, RAPS - Regulatory Affairs Professionals Society, SAS Institute',
    `issuing_body_country` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the country where the certifying body is headquartered or where the certification was issued. Relevant for multi-jurisdictional regulatory compliance (FDA, EMA, PMDA, MHRA, Health Canada).. Valid values are `^[A-Z]{3}$`',
    `certification_name` STRING COMMENT 'Full human-readable name of the professional certification or credential (e.g., Certified Clinical Research Coordinator, Certified Clinical Research Associate, Regulatory Affairs Certification, SAS Certified Base Programmer).',
    `notes` STRING COMMENT 'Free-text field for additional context, conditions, or remarks about the certification record (e.g., Renewal pending sponsor approval, Exam waived per equivalency policy, Certificate copy on file in Veeva Vault). Not used for structured data.',
    `number` STRING COMMENT 'Externally issued unique credential number assigned by the certifying body (e.g., ACRP certificate number, SOCRA CCRP number, RAC registration number). Used for verification with the issuing organization and regulatory audit purposes.',
    `passing_score` DECIMAL(5,2) COMMENT 'Minimum passing score required by the issuing body to achieve the certification. Used to contextualize the exam_score and confirm the workforce member met the threshold. Null if no examination is required.',
    `reimbursement_amount` DECIMAL(10,2) COMMENT 'Actual monetary amount reimbursed to the workforce member for this certification, in the currency specified by cost_currency. May differ from cost_amount if partial reimbursement applies per company policy.',
    `reimbursement_eligible` BOOLEAN COMMENT 'Indicates whether the organization reimburses the workforce member for the cost of obtaining or renewing this certification under the companys professional development or tuition reimbursement policy.',
    `renewal_date` DATE COMMENT 'Calendar date on which the certification was most recently renewed by the issuing body. Distinct from issue_date (original award) and expiry_date (end of validity). Tracks the renewal lifecycle for credentials that require periodic recertification.',
    `renewal_reminder_days` BIGINT COMMENT 'Number of calendar days before the expiry_date at which automated renewal reminder notifications should be triggered for the workforce member and their manager.',
    `renewal_status` STRING COMMENT 'Current status of the certification renewal process. not_due = renewal period has not yet opened; in_progress = renewal application being prepared; submitted = renewal application submitted to issuing body; renewed = renewal confirmed by issuing. Valid values are `not_due|in_progress|submitted|renewed|lapsed`',
    `source_system_record_code` STRING COMMENT 'Native record identifier from the originating operational system (the source system object ID or MasterControl record ID). Enables bidirectional traceability between the lakehouse silver layer and the system of record for reconciliation and audit.',
    `specialty_area` STRING COMMENT 'Clinical research functional specialty area covered by the certification (e.g., oncology, pharmacovigilance, biostatistics, data management, regulatory affairs, GCP monitoring, pharmacokinetics).',
    `sponsor_required` BOOLEAN COMMENT 'Indicates whether this certification is specifically required by a pharmaceutical or biotech sponsor as a contractual condition for assigning the workforce member to their study. True = sponsor-mandated credential; False = not sponsor-mandated.',
    `certification_status` STRING COMMENT 'Current lifecycle status of the certification record. active = valid and in good standing; expired = past expiry date without renewal; suspended = temporarily suspended by issuing body; revoked = permanently withdrawn by issuing body; pending =. Valid values are `active|expired|suspended|revoked|pending`',
    `certification_type` STRING COMMENT 'Classification of the professional credential by type, indicating the credential program category (e.g., clinical research coordinator, clinical research associate, regulatory affairs, biostatistics, data management).',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent modification to this certification record, in ISO 8601 format with timezone offset (yyyy-MM-ddTHH:mm:ss.SSSXXX). Required for change tracking, audit trail compliance, and incremental data pipeline processing.',
    `verification_date` DATE COMMENT 'Date on which the organization last verified the certifications validity with the issuing body. Used to determine when re-verification is due and to support regulatory inspection readiness.',
    `verification_status` STRING COMMENT 'Status of the organizations independent verification of the certification with the issuing body. unverified = not yet checked; verified = confirmed valid with issuing body; failed_verification = issuing body could not confirm. Valid values are `unverified|verified|failed_verification|pending_verification`',
    `verified_by` STRING COMMENT 'Name or identifier of the internal staff member (e.g., HR specialist, QA officer) who performed the verification of this certification with the issuing body. Supports audit trail requirements under GCP and ALCOA+ principles.',
    CONSTRAINT pk_certification PRIMARY KEY(`certification_id`)
) COMMENT 'Master record for professional certifications and credentials held by clinical research workforce members. Captures certification type (ACRP CCRC, ACRP CCRA, SOCRA CCRP, RAC, SAS Certified, etc.), issuing body, certification number, issue date, expiry';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` (
    `study_assignment_id` BIGINT COMMENT 'Unique surrogate identifier for the study assignment record. Primary key for this entity in the Silver Layer lakehouse.',
    `cost_center_id` BIGINT COMMENT 'Reference to the financial cost center to which the workforce members time on this study is charged. Links to the source system center master for project accounting and accrual processing.',
    `investigational_site_id` BIGINT COMMENT 'Reference to the primary clinical site to which this workforce member is assigned within the study. Relevant for CRAs and CRCs whose work is site-specific. Nullable for central roles (e.g., Biostatistician, Data Manager).',
    `organization_id` BIGINT COMMENT 'Reference to the pharmaceutical or biotech sponsor organization funding the study. Used for sponsor-level workforce reporting and billing reconciliation.',
    `primary_study_employee_id` BIGINT COMMENT 'Reference to the workforce member being assigned to the study. Links to the employee master record in the source system',
    `study_budget_id` BIGINT COMMENT 'Foreign key linking to finance.study_budget. Business justification: Study assignments carry billing_rate and FTE allocation that must be tracked against the study budget. Clinical trial finance uses this link for labor cost actuals vs.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study to which the workforce member is assigned. Links to the study master record in the source system',
    `workforce_delegation_log_id` BIGINT COMMENT 'Reference to the delegation of authority log entry in the site delegation log that formally authorizes this workforce members tasks on the study. Required for GCP compliance and regulatory inspection readiness.',
    `approved_timestamp` TIMESTAMP COMMENT 'The timestamp when the assignment was formally approved by the authorizing manager. Distinct from record creation; represents the business event of managerial authorization. Required for GCP delegation audit trail.',
    `assigned_role` STRING COMMENT 'The functional role the workforce member performs on this study. Drives GCP training requirements, delegation log entries, and capacity utilization calculations.',
    `assignment_number` STRING COMMENT 'Externally-known business identifier for the assignment, generated by the source system or the source system assignment module. Used for cross-system reconciliation and audit trail references.. Valid values are `^SA-[0-9]{4}-[0-9]{6}$`',
    `assignment_status` STRING COMMENT 'Current lifecycle state of the study assignment. Drives capacity utilization reporting and resource availability calculations. Active = currently working; on-hold = temporarily suspended; completed = assignment concluded; cancelled = assignment voided. Valid values are `active|on-hold|completed|cancelled|pending`',
    `assignment_type` STRING COMMENT 'Classification of the assignment nature. Primary = main role holder; backup = coverage resource; ad-hoc = short-term task-based; interim = temporary gap coverage; consultant = external contractor assignment.. Valid values are `primary|backup|ad-hoc|interim|consultant`',
    `billing_rate` DECIMAL(10,2) COMMENT 'The hourly or daily billing rate applied to this workforce member for this study assignment, in the contract currency. Used for study budget tracking and sponsor invoicing. Classified confidential as it reflects contractual pricing.',
    `billing_rate_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the billing rate (e.g., USD, EUR, GBP). Required for multi-currency study budget management and sponsor invoicing.. Valid values are `^[A-Z]{3}$`',
    `billing_rate_unit` STRING COMMENT 'The unit of measure for the billing rate (hourly, daily, monthly, or fixed fee). Determines how FTE allocation translates to billable amounts for sponsor invoicing.. Valid values are `hourly|daily|monthly|fixed`',
    `completion_reason` STRING COMMENT 'Categorized reason for assignment completion or cancellation. Used for workforce attrition analysis and study continuity risk management.. Valid values are `study-closeout|role-change|resignation|reassignment|contract-end|other`',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code representing the country where the workforce member is based for this assignment. Used for regulatory jurisdiction determination and GDPR/HIPAA compliance scoping.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this study assignment record was first created in the system. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `ctms_assignment_code` STRING COMMENT 'The native assignment identifier from the source system Used for cross-system reconciliation between the lakehouse Silver Layer and the operational CTMS source system.',
    `effective_timestamp` TIMESTAMP COMMENT 'The precise timestamp at which the assignment became operationally effective (distinct from start_date which is day-level). Used for intra-day capacity calculations and audit trail precision per 21 CFR Part 11.',
    `employment_type` STRING COMMENT 'The employment classification of the workforce member at the time of assignment. Relevant for billing rate determination, GCP oversight requirements, and regulatory inspection readiness.. Valid values are `full-time|part-time|contractor|consultant|secondment`',
    `end_date` DATE COMMENT 'The planned or actual date on which the workforce members assignment to the study concludes. Nullable for open-ended assignments. Used for capacity planning and study close-out activities.',
    `fte_allocation_pct` DECIMAL(5,2) COMMENT 'The percentage of the workforce members full-time equivalent capacity formally allocated to this study. Range 0.00–100.00. Primary input for capacity utilization calculations and resource planning.',
    `gcp_certification_expiry_date` DATE COMMENT 'The expiry date of the workforce members GCP certification. Used to trigger re-training alerts and to flag non-compliant assignments during regulatory inspections.',
    `gcp_certified` BOOLEAN COMMENT 'Indicates whether the workforce member holds a valid GCP certification at the time of assignment. Mandatory compliance check per ICH E6(R2) before assignment activation. True = certified; False = not certified or expired.',
    `geographic_region` STRING COMMENT 'The geographic region (e.g., North America, Europe, Asia-Pacific) in which the workforce member operates for this assignment. Used for regional capacity planning and regulatory jurisdiction tracking.',
    `is_pi_oversight_required` BOOLEAN COMMENT 'Indicates whether this assignment requires direct oversight by the Principal Investigator per the study delegation log. True = PI oversight required; False = independent execution permitted within delegated authority.',
    `notes` STRING COMMENT 'Free-text field for operational notes, special instructions, or contextual information related to the assignment. Not used for regulatory documentation; supplementary operational context only.',
    `on_hold_date` DATE COMMENT 'The date on which the assignment was placed on hold. Populated only when assignment_status = on-hold. Used for capacity planning and timeline impact analysis.',
    `on_hold_reason` STRING COMMENT 'Free-text description of the reason the assignment was placed on hold. Populated only when assignment_status = on-hold. Supports operational decision-making and audit trail.',
    `phase` STRING COMMENT 'The clinical development phase of the study to which the workforce member is assigned. Used for workforce competency matching and regulatory oversight level determination.. Valid values are `Phase I|Phase II|Phase III|Phase IV|Phase I/II`',
    `planned_fte_allocation_pct` DECIMAL(5,2) COMMENT 'The originally planned FTE allocation percentage at the time of assignment creation, before any revisions. Enables variance analysis between planned and actual resource utilization.',
    `protocol_version` STRING COMMENT 'The version of the study protocol in effect at the time of assignment. Ensures the workforce member is trained on the correct protocol version and supports audit trail requirements.',
    `start_date` DATE COMMENT 'The date on which the workforce member formally begins their assignment to the study. Used as the effective-from date for FTE allocation and capacity planning calculations.',
    `therapeutic_area` STRING COMMENT 'The therapeutic area of the assigned study (e.g., Oncology, Cardiology, Neurology). Captured at assignment level to support workforce competency matching and therapeutic area capacity reporting.',
    `training_completion_date` DATE COMMENT 'The date on which the workforce member completed all mandatory study-specific training requirements (protocol, ICF, EDC system) prior to or at assignment activation. Regulatory compliance prerequisite.',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this study assignment record was last modified. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles. Used for incremental data pipeline processing.',
    `workday_assignment_code` STRING COMMENT 'The native project assignment identifier from the source system for cross-system reconciliation between the lakehouse Silver Layer and the the source system system for payroll and project accounting alignment.',
    CONSTRAINT pk_study_assignment PRIMARY KEY(`study_assignment_id`)
) COMMENT 'Transactional record capturing the formal assignment of a workforce member to a clinical study in a defined role, with FTE allocation percentage. Sourced from CTMS and the source system assignments.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` (
    `workforce_delegation_log_id` BIGINT COMMENT 'Unique surrogate identifier for each delegation log record in the Silver Layer lakehouse. Primary key for this regulatory artifact.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.sop. Business justification: GCP delegation logs must reference the governing SOP under which task delegation is authorized. Regulatory inspectors verify that delegations comply with current SOPs.',
    `primary_workforce_pi_employee_id` BIGINT COMMENT 'Reference to the Principal Investigator (PI) who is delegating the trial-related duties. The PI retains overall responsibility per GCP.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this delegation of trial-related duties applies. Links the delegation log to the specific protocol and sponsor.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: ICH E6 R2 requires delegation logs to be updated when protocol amendments change task scope.',
    `study_site_id` BIGINT COMMENT 'Reference to the investigational site at which the delegation is in effect. A delegation log is site-specific per GCP requirements.',
    `superseded_log_workforce_delegation_log_id` BIGINT COMMENT 'Reference to the prior delegation log record that this entry supersedes or amends. Enables version chain traceability for regulatory inspection. Null for original entries.',
    `tertiary_workforce_qa_reviewer_employee_id` BIGINT COMMENT 'Reference to the QA staff member who reviewed and approved or rejected this delegation log entry. Null if QA review has not yet been performed or is not required.',
    `tmf_artifact_id` BIGINT COMMENT 'Reference to the corresponding document artifact stored in the Trial Master File (TMF) or electronic Trial Master File (eTMF) system (Veeva Vault). Links the transactional record to the regulatory document repository.',
    `amendment_reason` STRING COMMENT 'Free-text explanation for why this delegation log entry was created as an amendment to a prior version (e.g., staff role change, task scope expansion, personnel departure). Null for initial log entries.',
    `comments` STRING COMMENT 'Free-text field for additional notes or clarifications related to this delegation log entry, such as special conditions, limitations on the delegation, or context for an amendment.',
    `ctms_delegation_ref` STRING COMMENT 'The external reference identifier for this delegation log entry as recorded in the source Clinical Trial Management System (the source system Used for cross-system reconciliation.',
    `delegated_task_code` STRING COMMENT 'Standardized code identifying the specific trial-related task or responsibility being delegated (e.g., IC_PROCESS, AE_ASSESSMENT, SDV_CONDUCT, DRUG_DISPENSING, SAMPLE_COLLECTION). Drawn from the sites task code reference list.',
    `delegated_task_description` STRING COMMENT 'Free-text description of the specific trial-related duty or responsibility being delegated to the delegatee. Provides the full narrative of the scope of delegation as it appears on the formal delegation log document.',
    `delegatee_name` STRING COMMENT 'The full name of the delegatee as it appears on the signed delegation log document. Captured as a point-in-time regulatory artifact field required for GCP compliance and inspection readiness.',
    `delegatee_qualification_confirmed` BOOLEAN COMMENT 'Indicates whether the PI has confirmed that the delegatee possesses the necessary training, qualifications, and experience to perform the delegated task per ICH E6(R2) Section 4.1.5.',
    `delegatee_role_title` STRING COMMENT 'The formal job title or role of the delegatee at the time of delegation (e.g., Sub-Investigator, Clinical Research Coordinator (CRC), Study Nurse, Pharmacist). Captured as a point-in-time record on the delegation log.',
    `delegatee_signature_captured` BOOLEAN COMMENT 'Indicates whether the delegatees electronic or wet-ink signature has been captured and stored in the system for this delegation log entry. True = signature on file; False = pending.',
    `delegatee_signature_date` DATE COMMENT 'The date on which the delegatee signed the delegation log entry, acknowledging acceptance of the delegated responsibility. Required to confirm informed acceptance per GCP.',
    `delegation_end_date` DATE COMMENT 'The date on which the delegated task or responsibility ceases to be effective. Null indicates the delegation remains open-ended until formally withdrawn or the study closes.',
    `delegation_log_number` STRING COMMENT 'The externally-visible, human-readable identifier for the delegation log document as it appears in the TMF and on the physical or electronic document (e.g., DL-STUDY001-SITE042-001). Used for regulatory inspection and audit trail.',
    `delegation_scope` STRING COMMENT 'Categorizes the breadth of the delegation: full covers all aspects of the task, partial covers defined sub-tasks only, temporary is time-limited cover (e.g., PI absence), emergency is an unplanned urgent delegation.. Valid values are `full|partial|temporary|emergency`',
    `delegation_start_date` DATE COMMENT 'The date on which the delegated task or responsibility becomes effective for the delegatee. Must not precede the PI signature date.',
    `gcp_guideline_version` STRING COMMENT 'The version of the ICH GCP guideline under which this delegation log was prepared (e.g., ICH E6(R1), ICH E6(R2), ICH E6(R3)). Relevant for regulatory inspection and compliance assessment.',
    `gcp_training_verified` BOOLEAN COMMENT 'Indicates whether the delegatees current Good Clinical Practice (GCP) training certification has been verified and is on file at the time of delegation. Required per ICH E6(R2) and FDA regulations.',
    `inspection_ready` BOOLEAN COMMENT 'Indicates whether this delegation log entry has been reviewed and confirmed as inspection-ready for regulatory authority review (e.g., FDA, EMA inspection). Managed as part of TMF completeness and quality review.',
    `irb_iec_approval_confirmed` BOOLEAN COMMENT 'Indicates whether the relevant IRB or IEC approval was in place at the time this delegation was executed. Ensures the delegation is made within an ethically approved study context.',
    `log_status` STRING COMMENT 'Current lifecycle status of the delegation log record. Active indicates the delegation is currently in force; superseded indicates a newer version exists; withdrawn indicates the delegation was revoked.. Valid values are `draft|active|superseded|withdrawn|archived`',
    `log_version` STRING COMMENT 'Version identifier of the delegation log document (e.g., v1.0, v2.0). Incremented each time the log is formally amended and re-signed. Required for TMF version control.. Valid values are `^vd+(.d+)?$`',
    `pi_name` STRING COMMENT 'The full name of the Principal Investigator (PI) as it appears on the signed delegation log document. Captured as a point-in-time regulatory artifact field; the PIs name must appear on the document per GCP.',
    `pi_signature_captured` BOOLEAN COMMENT 'Indicates whether the PIs electronic or wet-ink signature has been captured and stored in the system for this delegation log entry. True = signature on file; False = pending.',
    `pi_signature_date` DATE COMMENT 'The date on which the Principal Investigator (PI) signed the delegation log entry, formally authorizing the delegation. This is a GCP-mandated regulatory artifact date per ICH E6(R2).',
    `protocol_training_verified` BOOLEAN COMMENT 'Indicates whether the delegatee has completed and documented protocol-specific training for the study prior to performing the delegated task.',
    `qa_review_date` DATE COMMENT 'The date on which the QA reviewer completed their review of this delegation log entry. Null if review is pending or not required.',
    `qa_review_status` STRING COMMENT 'The current Quality Assurance (QA) review status of this delegation log entry. Tracks whether the QA team has reviewed and approved the delegation for TMF completeness and GCP compliance.. Valid values are `pending|in_review|approved|rejected|not_required`',
    `record_created_timestamp` TIMESTAMP COMMENT 'The timestamp when this delegation log record was first created in the system. Supports ALCOA+ audit trail requirements for contemporaneous data capture.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this delegation log record was last modified in the system. Required for audit trail integrity and ALCOA+ compliance.',
    `regulatory_authority` STRING COMMENT 'The primary regulatory authority under whose jurisdiction this delegation log is filed (e.g., FDA, EMA, MHRA). Determines applicable GCP guidelines and inspection standards.',
    `site_number` STRING COMMENT 'The sponsor- or CRO-assigned site number as it appears on the delegation log document. Provides a direct, point-in-time site identifier on the regulatory artifact independent of system FK resolution.',
    `sponsor_protocol_number` STRING COMMENT 'The sponsor-assigned protocol number associated with the study for which this delegation applies. Captured directly on the delegation log document as a regulatory identifier.',
    `workday_worker_code` STRING COMMENT 'The the source system worker identifier for the delegatee employee. Used to cross-reference HR records, training completions, and employment status at the time of delegation.',
    CONSTRAINT pk_workforce_delegation_log PRIMARY KEY(`workforce_delegation_log_id`)
) COMMENT 'Transactional record of the formal delegation of trial-related duties from the Principal Investigator (PI) to site staff and CRO personnel, as required by ICH E6(R2) Section 8.3.25.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` (
    `workforce_resource_plan_id` BIGINT COMMENT 'Unique surrogate identifier for the workforce resource plan record in the lakehouse silver layer. Primary key for this entity.',
    `clinical_program_id` BIGINT COMMENT 'Reference to the drug development program (collection of related studies) for which this resource plan is created. Null when the plan is at study or organizational unit level.',
    `cost_center_id` BIGINT COMMENT 'Foreign key linking to finance.cost_center. Business justification: Workforce resource plans are organized by cost center for labor cost planning and budget allocation.',
    `job_profile_id` BIGINT COMMENT 'Foreign key linking to workforce.job_profile. Business justification: workforce_resource_plan.role_category and role_level are denormalized STRING fields that correspond to job_profile.job_category and job_profile.job_level.',
    `org_unit_id` BIGINT COMMENT 'Reference to the organizational unit (department, cost center, or functional group) that owns this resource plan. Sourced from the source system hierarchy.',
    `primary_workforce_employee_id` BIGINT COMMENT 'Reference to the employee record of the resource manager responsible for authoring, maintaining, and executing this workforce resource plan. Sourced from the source system',
    `program_strategic_plan_id` BIGINT COMMENT 'Foreign key linking to program.program_plan. Business justification: Workforce resource plans are built against specific program plan versions — FTE demand models reference the development plans study count, phase, and timeline assumptions.',
    `scope_of_work_id` BIGINT COMMENT 'Foreign key linking to agreement.scope_of_work. Business justification: Workforce resource plans are built directly from SOW staffing requirements in clinical trials.',
    `study_budget_id` BIGINT COMMENT 'Foreign key linking to finance.study_budget. Business justification: Workforce resource plans drive labor cost inputs to study budgets. Clinical trial finance teams reconcile planned FTE demand and labor costs against the study budget.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this resource plan is created. Null when the plan is at program or organizational unit level rather than study level.',
    `timeline_id` BIGINT COMMENT 'Foreign key linking to program.program_timeline. Business justification: Workforce resource plans are driven by program timeline milestones — FTE demand peaks are tied to specific timeline versions (e.g., enrollment ramp, database lock).',
    `actual_fte` DECIMAL(10,2) COMMENT 'Actual FTE count allocated and confirmed for the role category and time period. Sourced from the source system Compared against planned_fte_demand to derive resource gap.',
    `actual_headcount` BIGINT COMMENT 'Actual number of employees confirmed and allocated for the role category and planning period. Sourced from the source system management actuals.',
    `actual_labor_cost` DECIMAL(18,2) COMMENT 'Actual labor cost incurred for the resource plan period, sourced from the source system and project accounting actuals. Compared against planned_labor_cost for variance analysis.',
    `approval_date` DATE COMMENT 'Date on which the resource plan was formally approved by the authorized resource manager or governance body. Null for plans in draft or submitted status.',
    `budget_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for all monetary values in this resource plan (e.g., USD, EUR, GBP). Ensures consistent financial reporting across studies.. Valid values are `^[A-Z]{3}$`',
    `capacity_utilization_target_pct` DECIMAL(5,2) COMMENT 'Target percentage of available FTE capacity to be utilized for billable or productive clinical work during the planning period. Used to set workload balancing thresholds and avoid burnout or under-utilization.',
    `contractor_fte_planned` DECIMAL(10,2) COMMENT 'Planned FTE demand to be fulfilled by contract or temporary staff (CRO contractors, freelance CRAs) rather than permanent employees. Supports make-vs-buy workforce decisions.',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code for country-specific resource plans. Used when planning is scoped to a single regulatory jurisdiction (e.g., USA, GBR, JPN).. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this workforce resource plan record was first created in the source system (the source system audit trail, data lineage, and ALCOA+ compliance requirements.',
    `fiscal_quarter` STRING COMMENT 'The fiscal quarter within the fiscal year to which this resource plan applies. Used for quarterly capacity reviews and rolling forecast updates.. Valid values are `Q1|Q2|Q3|Q4`',
    `fiscal_year` BIGINT COMMENT 'The fiscal year to which this resource plan primarily belongs, used for annual budgeting, headcount approvals, and financial reporting alignment with the source system',
    `fte_gap` DECIMAL(10,2) COMMENT 'Resource gap expressed as FTE units, calculated as planned_fte_demand minus actual_fte. Positive values indicate a staffing shortfall requiring hiring or contractor engagement; negative values indicate surplus capacity.',
    `gcp_certification_required` BOOLEAN COMMENT 'Indicates whether all resources allocated under this plan must hold a valid GCP certification as mandated by ICH E6(R2). Drives training compliance checks in MasterControl.',
    `geographic_region` STRING COMMENT 'Geographic region or country cluster for which this resource plan applies (e.g., North America, EMEA, APAC). Used for regional capacity planning and regulatory jurisdiction alignment.',
    `hiring_urgency` STRING COMMENT 'Priority classification for filling open positions within this resource plan. Critical indicates study start or regulatory milestone is at risk; high indicates near-term impact; medium and low indicate planned pipeline needs.. Valid values are `critical|high|medium|low`',
    `internal_fte_planned` DECIMAL(10,2) COMMENT 'Planned FTE demand to be fulfilled by permanent internal employees. Complements contractor_fte_planned to give total planned_fte_demand when summed.',
    `last_revised_date` DATE COMMENT 'Date on which the resource plan was most recently revised. Tracks the recency of planning assumptions and triggers re-approval workflows when material changes are made.',
    `open_position_count` BIGINT COMMENT 'Number of approved but unfilled positions within this resource plan. Drives active recruiting actions and time-to-fill KPI tracking in the source system acquisition.',
    `plan_code` STRING COMMENT 'Externally-known business identifier for the resource plan, sourced from the source system planning module. Used for cross-system reference and reporting (e.g., WRP-2024-ONCO-Q3).. Valid values are `^WRP-[A-Z0-9]{4,20}$`',
    `plan_end_date` DATE COMMENT 'The date on which this workforce resource plan expires or the planning horizon concludes. Null for open-ended plans. Aligns to study close-out or fiscal year end.',
    `plan_name` STRING COMMENT 'Human-readable name describing the resource plan, typically including the organizational unit, study or program, and planning period (e.g., Oncology CRA Staffing Plan Q3 2024).',
    `plan_notes` STRING COMMENT 'Free-text field for resource manager annotations, planning assumptions, risk flags, or contextual commentary relevant to this resource plan. Not used for structured data.',
    `plan_start_date` DATE COMMENT 'The date from which this workforce resource plan becomes effective. Marks the beginning of the planning horizon for FTE demand tracking and capacity allocation.',
    `plan_status` STRING COMMENT 'Current lifecycle state of the resource plan within the planning workflow. Drives approval routing and visibility in capacity management dashboards. [ENUM-REF-CANDIDATE: draft|submitted|approved|revised|superseded|closed — promote to reference product if',
    `plan_type` STRING COMMENT 'Classification of the planning scope: study-level (single protocol), program-level (multiple related studies), organizational unit (department/function), or functional area (e.g., all CRAs globally).. Valid values are `study|program|organizational_unit|functional_area`',
    `plan_version` BIGINT COMMENT 'Monotonically incrementing version number for the resource plan. Incremented each time the plan is revised and resubmitted for approval, enabling historical comparison of staffing demand changes.',
    `planned_fte_demand` DECIMAL(10,2) COMMENT 'Total planned FTE demand for the specified role category and time period. Represents the number of full-time equivalent resources required to execute the planned scope of work. Core metric for capacity planning.',
    `planned_headcount` BIGINT COMMENT 'Planned number of individual employees (headcount) required for the role category and planning period. Distinct from FTE as it counts persons rather than effort equivalents.',
    `planned_labor_cost` DECIMAL(18,2) COMMENT 'Total planned labor cost for the resource plan in the specified budget currency, covering all FTE demand for the planning period. Used for study budget alignment and financial forecasting in the source system',
    `planning_horizon` STRING COMMENT 'Time granularity and scope of the resource plan. Study_phase aligns to clinical trial phases (Phase I–IV); quarterly and annual align to fiscal planning cycles; multi_year supports long-horizon program planning.. Valid values are `study_phase|quarterly|annual|multi_year`',
    `required_language` STRING COMMENT 'Primary language proficiency required for resources allocated under this plan, relevant for studies where site communication and regulatory submissions require specific language skills.',
    `revision_reason` STRING COMMENT 'Free-text description of the business reason for the most recent plan revision (e.g., protocol amendment, site expansion, attrition-driven replan). Supports audit trail and change management documentation.',
    `study_phase` STRING COMMENT 'Clinical development phase associated with this resource plan when plan_type is study or program. Drives staffing intensity assumptions and regulatory compliance requirements.. Valid values are `Phase_I|Phase_II|Phase_III|Phase_IV|pre_clinical|post_marketing`',
    `therapeutic_area` STRING COMMENT 'Therapeutic area or disease indication associated with the study or program (e.g., Oncology, Cardiology, Neurology). Used for resource demand segmentation and specialist skill matching.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this workforce resource plan record was most recently modified in the source system or lakehouse silver layer. Supports change tracking and audit trail requirements.',
    `workday_plan_code` STRING COMMENT 'Source system identifier for this resource plan record in the source system planning module. Used for data lineage, reconciliation, and cross-system traceability.',
    CONSTRAINT pk_workforce_resource_plan PRIMARY KEY(`workforce_resource_plan_id`)
) COMMENT 'Master record for workforce resource planning at the study, program, or organizational unit level. Captures planned FTE demand by role and time period, planned vs.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`workforce`.`training_record` (
    `training_record_id` BIGINT COMMENT 'Primary key for training_record',
    `compliance_capa_id` BIGINT COMMENT 'Identifier of the CAPA record that triggered this training assignment, if the training was assigned as a corrective or preventive action following a deviation, audit finding, or quality event. Null for routine training assignments.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.sop. Business justification: SOP training records are fundamentally about training on specific SOPs; linking to compliance.sop enables automated training assignment on SOP updates, GCP compliance gap reporting, and',
    `electronic_signature_id` BIGINT COMMENT 'Unique identifier of the 21 CFR Part 11-compliant electronic signature applied by the employee upon training completion or acknowledgement. Provides legally binding audit evidence of training completion in MasterControl.',
    `primary_training_employee_id` BIGINT COMMENT 'Identifier of the workforce member assigned to complete this SOP training. References the employee master record in the source system the PARTY_REFERENCE for this transactional record.',
    `protocol_deviation_id` BIGINT COMMENT 'Identifier of the protocol deviation or quality event that prompted this retraining assignment. Null for initial or periodic training. Supports root-cause traceability between deviations and corrective training actions.',
    `study_assignment_id` BIGINT COMMENT 'Foreign key linking to workforce.study_assignment. Business justification: training_record (SOP training) already has employee_id and study_id, but linking to study_assignment provides the formal assignment context.',
    `study_id` BIGINT COMMENT 'Identifier of the clinical study to which this training assignment is scoped, if the SOP training is study-specific (e.g., study-specific procedures). Null for SOP training not tied to a specific study.',
    `tertiary_training_assigned_by_employee_id` BIGINT COMMENT 'Identifier of the employee (typically a QA manager or training coordinator) who created and assigned this training record in MasterControl. Supports accountability and audit trail for training assignment actions.',
    `training_course_id` BIGINT COMMENT 'Foreign key linking to workforce.training_course. Business justification: Training records track SOP and general training completions but lack a FK to the training_course reference table. GCP training records already have this FK.',
    `training_curriculum_id` BIGINT COMMENT 'Identifier of the training curriculum or training plan under which this assignment was generated. A curriculum groups multiple SOP training requirements for a role or study. Supports curriculum-level completion tracking.',
    `assessment_required` BOOLEAN COMMENT 'Indicates whether a formal assessment (quiz or competency test) is required to complete this training assignment. Determined by the SOP training requirement configuration in MasterControl. Drives assessment score and pass/fail status population.',
    `assessment_score` DECIMAL(5,2) COMMENT 'Numeric score achieved by the employee on the training assessment, expressed as a percentage (0.00–100.00). Null if no assessment was required or not yet taken. Used to evaluate training effectiveness and identify knowledge gaps.',
    `assignment_date` DATE COMMENT 'Date on which the training was formally assigned to the employee in MasterControl. Represents the BUSINESS_EVENT_TIMESTAMP (date precision) for the assignment event. Used to calculate days-to-completion and overdue status.',
    `assignment_number` STRING COMMENT 'Human-readable, externally-known business identifier for this training assignment, formatted as TRN-YYYY-NNNNNN. Used in audit trails, compliance reports, and CAPA references. Serves as the BUSINESS_IDENTIFIER for this transaction.. Valid values are `^TRN-[0-9]{4}-[0-9]{6}$`',
    `assignment_status` STRING COMMENT 'Current lifecycle state of the training assignment. Drives compliance dashboards, overdue notifications, and regulatory readiness reporting. Serves as the LIFECYCLE_STATUS for this transaction.. Valid values are `assigned|in_progress|completed|overdue|waived|cancelled`',
    `attempt_number` BIGINT COMMENT 'Sequential attempt number for the training assessment (1 = first attempt, 2 = second attempt, etc.). Tracks retake history. Maximum attempts may be governed by the training SOP. Supports analysis of training effectiveness.',
    `comments` STRING COMMENT 'Free-text field for additional notes or context related to this training assignment, such as reasons for late completion, special circumstances, or instructor observations. Supports audit trail narrative.',
    `completion_date` DATE COMMENT 'Date on which the employee completed the SOP training (read-and-understand acknowledgement, e-learning module completion, or instructor sign-off). Null if training is not yet completed. Core compliance evidence field.',
    `completion_timestamp` TIMESTAMP COMMENT 'Precise date and time at which the employee completed the training, including timezone offset. Required for 21 CFR Part 11 electronic records compliance and audit trail integrity. Complements completion_date with time-level precision.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time at which this training assignment record was first created in the source system (MasterControl). Serves as the RECORD_AUDIT_CREATED field. Required for 21 CFR Part 11 audit trail and ALCOA+ compliance.',
    `days_overdue` BIGINT COMMENT 'Number of calendar days the training completion has exceeded the due date at the time of last record update. Zero or negative if on time. Used for compliance KPI reporting and escalation prioritization.',
    `department` STRING COMMENT 'Organizational department of the employee at the time of training assignment (e.g., Clinical Operations, Biostatistics, Regulatory Affairs). Snapshot value for compliance reporting and departmental training coverage analysis.',
    `due_date` DATE COMMENT 'Deadline by which the employee must complete the assigned SOP training. Used to trigger overdue notifications, compliance reporting, and escalation workflows. Typically set based on SOP effective date plus a grace period defined in the training SOP.',
    `job_role` STRING COMMENT 'Job role or title of the employee at the time of training assignment (e.g., Clinical Research Associate, Data Manager, Biostatistician). Captured as a snapshot to support role-based training compliance analysis even if the employees role changes later.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Date and time at which this training assignment record was most recently updated in the source system. Serves as the RECORD_AUDIT_UPDATED field. Required for 21 CFR Part 11 audit trail and change tracking.',
    `mastercontrol_training_code` STRING COMMENT 'External system-of-record identifier assigned by MasterControl to this training assignment. Used for cross-system traceability and audit reconciliation between the lakehouse and the source document control system.',
    `max_attempts_allowed` BIGINT COMMENT 'Maximum number of assessment attempts permitted for this training assignment as configured in MasterControl. Null if unlimited. Used to enforce training policy and trigger escalation when maximum attempts are exhausted without passing.',
    `pass_fail_status` STRING COMMENT 'Outcome of the training assessment: pass (score met or exceeded threshold), fail (score below threshold), not_assessed (no assessment required for this method), or pending (assessment not yet taken). Core compliance evidence for regulatory inspections.. Valid values are `pass|fail|not_assessed|pending`',
    `passing_score_threshold` DECIMAL(5,2) COMMENT 'Minimum assessment score percentage required to pass the training (e.g., 80.00). Defined at the SOP training requirement level and captured here for audit trail completeness. Enables pass/fail determination and historical threshold tracking.',
    `recurrence_interval_days` BIGINT COMMENT 'Number of days after completion before the next training assignment is automatically generated for this SOP. Null if recurrence_required is false. Supports periodic retraining scheduling (e.g., 365 for annual retraining).',
    `recurrence_required` BOOLEAN COMMENT 'Indicates whether this SOP training must be repeated on a periodic basis (e.g., annually). Drives the generation of future training assignments upon completion. Configured at the SOP training requirement level.',
    `signed_timestamp` TIMESTAMP COMMENT 'Date and time at which the employee applied their electronic signature to acknowledge training completion. Required for 21 CFR Part 11 audit trail. May differ slightly from completion_timestamp if signature is applied after assessment.',
    `sop_effective_date` DATE COMMENT 'Date on which the assigned SOP version became effective. Used to determine whether training was completed before or after the SOP became operative, supporting compliance gap analysis.',
    `sop_version` STRING COMMENT 'Version number of the SOP document at the time of training assignment (e.g., 1.0, 2.3). Critical for compliance to confirm training was completed on the current effective version. Supports version-specific training gap analysis.. Valid values are `^[0-9]+.[0-9]+$`',
    `training_category` STRING COMMENT 'Classification of why this training was assigned: initial (new hire or new SOP), retraining (following deviation or CAPA), periodic (scheduled refresh), change-driven (SOP version update), or role-based (role change).. Valid values are `initial|retraining|periodic|change_driven|role_based`',
    `training_method` STRING COMMENT 'Modality by which the SOP training is delivered: read-and-understand (employee reads and acknowledges), instructor-led (classroom or virtual), e-learning (online module), on-the-job (supervised practice), or blended.. Valid values are `read_and_understand|instructor_led|e_learning|on_the_job|blended`',
    `waiver_approved_by` STRING COMMENT 'Name or identifier of the QA manager or authorized approver who approved the training waiver. Captured as a string snapshot for audit trail completeness. Null if no waiver was granted.',
    `waiver_date` DATE COMMENT 'Date on which the training waiver was approved. Null if no waiver was granted. Required for audit trail and regulatory inspection readiness.',
    `waiver_reason` STRING COMMENT 'Documented justification for waiving this training assignment (e.g., employee is leaving the organization, SOP is being retired, equivalent training completed externally). Null if assignment_status is not waived. Required for audit trail integrity.',
    CONSTRAINT pk_training_record PRIMARY KEY(`training_record_id`)
) COMMENT 'Transactional record tracking the assignment and completion of SOP (Standard Operating Procedure) and controlled document training to workforce members, managed through MasterControl.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` (
    `training_curriculum_id` BIGINT COMMENT 'Unique system-generated identifier for the training curriculum record. Primary key for this entity in the Silver Layer lakehouse.',
    `approver_employee_id` BIGINT COMMENT 'the source system identifier of the individual who approved this curriculum version in MasterControl. Required for 21 CFR Part 11 electronic signature compliance and audit trail.',
    `compliance_sop_id` BIGINT COMMENT 'Foreign key linking to compliance.sop. Business justification: Training curricula with sop_training_included=true must reference the governing SOP to trigger automatic curriculum updates when SOPs are revised.',
    `job_profile_id` BIGINT COMMENT 'Foreign key linking to workforce.job_profile. Business justification: training_curriculum.target_job_profile is a denormalized STRING reference to the job profile this curriculum is designed for.',
    `organization_id` BIGINT COMMENT 'Foreign key linking to sponsor.organization. Business justification: Sponsor-specific training curricula (GCP, protocol, system) must be traceable to the sponsoring organization for inspection readiness, sponsor audit compliance, and ensuring CRO staff',
    `owner_employee_id` BIGINT COMMENT 'the source system identifier of the individual responsible for authoring, maintaining, and reviewing this curriculum (typically a Training Manager or QA Lead). Supports accountability tracking and periodic review scheduling.',
    `superseded_by_curriculum_training_curriculum_id` BIGINT COMMENT 'Reference to the training_curriculum_id of the newer curriculum version that replaced this one. Null if this is the current active version. Enables version lineage tracing for regulatory audit purposes.',
    `applicable_study_phase` STRING COMMENT 'The clinical study phase(s) for which this curriculum is applicable. Certain curricula (e.g., first-in-human safety monitoring) are phase-specific. all_phases indicates the curriculum applies across all study phases.. Valid values are `phase_1|phase_2|phase_3|phase_4|all_phases`',
    `approval_date` DATE COMMENT 'The date on which this curriculum version was formally approved in MasterControl by the designated approver. Required for regulatory audit trail and 21 CFR Part 11 electronic records compliance.',
    `change_summary` STRING COMMENT 'A brief description of the changes made in this version of the curriculum compared to the previous version (e.g., Updated GCP module to reflect ICH E6(R3) guidance; added EU CTR 536/2014 module).',
    `completion_window_days` BIGINT COMMENT 'The number of calendar days from assignment date within which all courses in the curriculum must be completed by the assigned employee. Drives compliance deadline enforcement and escalation workflows (e.g., 30 days for onboarding GCP, 14 days for',
    `curriculum_code` STRING COMMENT 'Externally-known unique alphanumeric code assigned to the curriculum in MasterControl (e.g., CURR-GCP-001). Used for cross-system reference, regulatory submissions, and audit trail identification.. Valid values are `^[A-Z0-9_-]{3,30}$`',
    `curriculum_description` STRING COMMENT 'Detailed narrative description of the curriculums purpose, scope, learning objectives, and target audience. Provides context for training administrators, QA reviewers, and regulatory inspectors.',
    `curriculum_name` STRING COMMENT 'Human-readable name of the training curriculum (e.g., GCP Onboarding Curriculum for Clinical Research Associates). Used in training assignment reports and compliance dashboards.',
    `curriculum_status` STRING COMMENT 'Current lifecycle state of the curriculum in MasterControl. Draft indicates the curriculum is being authored; active means it is currently assigned and enforced; retired means it is no longer in use; superseded means a newer version has replaced it. Valid values are `draft|active|retired|superseded|under_review`',
    `curriculum_type` STRING COMMENT 'Categorical classification of the curriculum by its primary purpose. Onboarding curricula apply to new hires; role_based to specific job profiles; protocol_specific to study-assigned staff; system_specific to EDC/CTMS/eTMF users; regulatory to GCP/ICH/FDA. Valid values are `onboarding|role_based|protocol_specific|system_specific|regulatory|refresher`',
    `delivery_method` STRING COMMENT 'The primary method by which this curriculum is delivered to employees. elearning: self-paced online modules; instructor_led: classroom or virtual instructor-led training; blended: combination of elearning and instructor-led; read_acknowledge: document. Valid values are `elearning|instructor_led|blended|read_acknowledge|on_the_job`',
    `effective_date` DATE COMMENT 'The date from which this curriculum version becomes binding and must be completed by assigned personnel. Used to trigger training assignment notifications and compliance deadline calculations.',
    `estimated_duration_hours` DECIMAL(6,2) COMMENT 'The estimated total time in hours required to complete all courses in the curriculum. Used for workforce capacity planning, onboarding scheduling, and resource allocation in the source system',
    `gcp_training_included` BOOLEAN COMMENT 'Indicates whether this curriculum includes at least one Good Clinical Practice (GCP) training course as required by ICH E6(R2). Critical flag for regulatory inspection readiness and delegation log verification.',
    `geographic_scope` STRING COMMENT 'The geographic region or country scope for which this curriculum is applicable (e.g., USA, EU, JPN, GLOBAL). Relevant for region-specific regulatory requirements such as FDA 21 CFR Part 312 (USA), EU CTR 536/2014 (EU), or PMDA guidelines (Japan).',
    `inspection_ready` BOOLEAN COMMENT 'Indicates whether this curriculum and its associated documentation are in a state ready for regulatory inspection (FDA, EMA, MHRA, PMDA, Health Canada, TGA). True means all required approvals, version controls, and audit trails are complete.',
    `language_code` STRING COMMENT 'ISO 639-1 language code (optionally with ISO 3166-1 country subtag) for the primary language in which this curriculum is authored (e.g., en, en-US, fr, ja, de). Supports multi-regional deployment and regulatory submissions to PMDA, EMA, Health Canada, TGA.. Valid values are `^[a-z]{2}(-[A-Z]{2})?$`',
    `last_review_date` DATE COMMENT 'The date on which this curriculum was last reviewed for content accuracy and regulatory currency. Supports periodic review scheduling and GCP compliance verification.',
    `mandatory_flag` BOOLEAN COMMENT 'Indicates whether completion of this curriculum is mandatory for the assigned job profile or role. Mandatory curricula trigger compliance alerts and may block system access (e.g., EDC, CTMS) if not completed within the required window.',
    `mastercontrol_curriculum_code` STRING COMMENT 'The native document or curriculum identifier assigned by MasterControl (source system of record). Used for cross-system reconciliation between the Silver Layer lakehouse and MasterControl.',
    `max_attempts_allowed` BIGINT COMMENT 'The maximum number of times an employee may attempt the curriculum assessment before escalation or remediation is required. Null if unlimited attempts are permitted.',
    `next_review_date` DATE COMMENT 'The date by which the next periodic review of this curriculum must be completed. Calculated from last_review_date plus the review cycle interval. Drives review task creation in MasterControl.',
    `passing_score_percent` DECIMAL(5,2) COMMENT 'The minimum percentage score required to pass assessments within this curriculum. Typically 80% for GCP-related curricula per industry standard. Null if the curriculum has no scored assessments (e.g., read-and-acknowledge only).',
    `protocol_training_included` BOOLEAN COMMENT 'Indicates whether this curriculum includes protocol-specific training courses. When true, the curriculum is typically linked to a specific study protocol and must be completed before site staff can perform protocol-defined activities.',
    `recertification_period_months` BIGINT COMMENT 'The interval in months after which employees must re-complete the curriculum to maintain certification (e.g., 24 months for GCP refresher). Null if the curriculum is a one-time completion requirement with no recertification cycle.',
    `record_created_timestamp` TIMESTAMP COMMENT 'The timestamp when this training curriculum record was first created in the source system (MasterControl). Supports ALCOA+ data integrity principles (Attributable, Legible, Contemporaneous, Original, Accurate) and 21 CFR Part 11 audit trail requirements.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this training curriculum record was last modified in the source system (MasterControl). Supports ALCOA+ data integrity principles and 21 CFR Part 11 audit trail requirements for electronic records.',
    `regulatory_basis` STRING COMMENT 'The primary regulatory framework or guideline mandating this curriculum (e.g., ICH E6(R2) GCP, 21 CFR Part 312, EU CTR 536/2014, ISO 14155, GDPR). Multiple references may be pipe-delimited. Supports regulatory inspection readiness and audit documentation.',
    `retirement_date` DATE COMMENT 'The date on which this curriculum version was retired or superseded. Null if the curriculum is currently active. Supports lifecycle management and historical compliance reporting.',
    `sop_training_included` BOOLEAN COMMENT 'Indicates whether this curriculum includes Standard Operating Procedure (SOP) training courses. SOP training is a GCP requirement for all clinical research personnel performing regulated activities.',
    `sponsor_specific` BOOLEAN COMMENT 'Indicates whether this curriculum was developed to meet a specific sponsors training requirements. Sponsor-specific curricula may include sponsor SOPs, sponsor EDC system training, or sponsor-mandated GCP guidelines.',
    `system_training_included` BOOLEAN COMMENT 'Indicates whether this curriculum includes training on operational systems such as EDC (Medidata Rave), CTMS (the source system (Veeva Vault), or IRT/RTSM. Required for 21 CFR Part 11 system access authorization.',
    `target_department` STRING COMMENT 'Organizational department or functional group for which this curriculum is designed (e.g., Clinical Operations, Biostatistics, Data Management, Regulatory Affairs). Enables department-level compliance reporting.',
    `therapeutic_area` STRING COMMENT 'The therapeutic area or disease indication for which this curriculum is designed (e.g., Oncology, Cardiology, Neurology, Infectious Disease). Null for general curricula applicable across all therapeutic areas.',
    `total_course_count` BIGINT COMMENT 'The total number of individual training courses included in this curriculum. Provides a quick reference for workload estimation during onboarding planning and capacity management.',
    `version_number` STRING COMMENT 'Version identifier of the curriculum following semantic versioning convention (e.g., 1.0, 2.1, 3.0.1). Incremented upon each approved revision. Critical for 21 CFR Part 11 electronic records compliance and audit trail integrity.. Valid values are `^[0-9]+.[0-9]+(.[0-9]+)?$`',
    `workday_learning_program_code` STRING COMMENT 'The corresponding learning program identifier in the source system module, if the curriculum is also managed or tracked in the source system. Enables bidirectional reconciliation between MasterControl and the source system completion records.',
    CONSTRAINT pk_training_curriculum PRIMARY KEY(`training_curriculum_id`)
) COMMENT 'Master record defining structured training curricula assigned to job profiles or roles within the clinical research organization. Captures curriculum name, target job profile or role, list of required training courses (GCP, SOP, protocol-specific';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` (
    `payroll_record_id` BIGINT COMMENT 'Unique surrogate identifier for each payroll processing record in the Databricks Silver Layer. Primary key for the payroll_record data product.',
    `cost_center_id` BIGINT COMMENT 'Reference to the financial cost center to which this payroll expense is allocated. Supports workforce cost allocation to clinical studies and SOX financial reporting controls.',
    `employee_id` BIGINT COMMENT 'Reference to the employee record for whom this payroll disbursement was processed. Links to the workforce employee master in the source system',
    `gl_account_id` BIGINT COMMENT 'Foreign key linking to finance.gl_account. Business justification: Payroll records post to specific GL accounts as part of the payroll journal entry process.',
    `reversed_record_payroll_record_id` BIGINT COMMENT 'Reference to the original payroll_record_id that this record reverses or corrects. Null if this is not a reversal record. Maintains the audit chain for payroll corrections per SOX requirements.',
    `study_budget_id` BIGINT COMMENT 'Foreign key linking to finance.study_budget. Business justification: Payroll records carry study_allocation_code indicating which study budget absorbs the labor cost.',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to.',
    `allowance_amount` DECIMAL(18,4) COMMENT 'Total allowances paid to the employee in this pay period, including travel allowances, per diem, housing allowances, and other non-salary compensation components common in clinical research field roles.',
    `bank_account_last4` STRING COMMENT 'Last four digits of the employees bank account number to which direct deposit was made. Stored as a masked reference for audit and reconciliation purposes only; full account number is not retained.. Valid values are `^[0-9]{4}$`',
    `base_salary_amount` DECIMAL(18,4) COMMENT 'The fixed base salary component of gross pay for this pay period, prorated to the pay frequency. Excludes variable pay components such as overtime, bonuses, and allowances.',
    `benefits_deduction` DECIMAL(18,4) COMMENT 'Total employee-paid benefits deductions withheld from gross pay, including health insurance premiums, dental, vision, and other voluntary benefit elections.',
    `bonus_amount` DECIMAL(18,4) COMMENT 'Discretionary or performance-based bonus pay included in this payroll record. May include study milestone bonuses, retention bonuses, or annual performance awards.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code in which all monetary amounts in this payroll record are denominated (e.g., USD, EUR, GBP, JPY).. Valid values are `^[A-Z]{3}$`',
    `department` STRING COMMENT 'The organizational department to which the employee was assigned during this pay period (e.g., Clinical Operations, Biostatistics, Regulatory Affairs). Supports workforce cost allocation reporting.',
    `employee_full_name` STRING COMMENT 'Full legal name of the employee as recorded in the source system the time of payroll processing. Retained as a point-in-time snapshot for audit and regulatory purposes.',
    `employer_benefits_contribution` DECIMAL(18,4) COMMENT 'Employer-paid portion of employee benefits costs (health insurance, dental, vision, life insurance) for this pay period. Included in total workforce cost allocation to clinical studies.',
    `employer_retirement_contribution` DECIMAL(18,4) COMMENT 'Employer matching or defined contribution to the employees retirement plan for this pay period (e.g., 401(k) match, pension contribution). Part of total compensation cost for study budget allocation.',
    `employer_tax_contribution` DECIMAL(18,4) COMMENT 'Employer-side payroll tax contributions (e.g., employer FICA/Social Security, Medicare, unemployment insurance) associated with this payroll record. Required for total labor cost allocation to clinical studies.',
    `employment_type` STRING COMMENT 'Classification of the employees employment arrangement during this pay period. Determines applicable payroll rules, benefit eligibility, and tax treatment.. Valid values are `full_time|part_time|contract|temporary`',
    `gross_pay` DECIMAL(18,4) COMMENT 'Total gross compensation earned by the employee for the pay period before any deductions. Equals the sum of all pay components (base salary, overtime, bonus, allowances). Key figure for SOX financial reporting and workforce cost allocation.',
    `hours_worked` DECIMAL(10,2) COMMENT 'Total regular hours worked by the employee during the pay period as recorded in the source system tracking. Used for hourly pay calculations and study resource utilization reporting.',
    `is_reversal` BOOLEAN COMMENT 'Indicates whether this payroll record represents a reversal of a previously processed payroll entry. True if this record corrects or voids a prior disbursement. Critical for SOX audit trail integrity.',
    `job_title` STRING COMMENT 'The employees job title at the time of payroll processing (e.g., Clinical Research Associate, Biostatistician, Data Manager). Captured as a point-in-time snapshot for workforce cost analytics.',
    `net_pay` DECIMAL(18,4) COMMENT 'The actual amount disbursed to the employee after all deductions (taxes, benefits, retirement contributions) have been subtracted from gross pay. Represents the take-home pay amount.',
    `overtime_amount` DECIMAL(18,4) COMMENT 'Total overtime pay earned by the employee during this pay period, calculated per applicable labor law (e.g., FLSA 1.5x rate). Relevant for CRAs and site staff with variable field hours.',
    `overtime_hours` DECIMAL(10,2) COMMENT 'Total overtime hours worked by the employee during the pay period beyond the standard threshold (e.g., >40 hours/week under FLSA). Drives overtime_amount calculation.',
    `pay_frequency` STRING COMMENT 'The frequency at which the employee is paid within this pay group (e.g., biweekly, monthly). Determines the number of pay periods per year for annualization calculations.. Valid values are `weekly|biweekly|semimonthly|monthly`',
    `pay_group` STRING COMMENT 'The the source system group to which the employee belongs, determining pay frequency and processing rules (e.g., US-Biweekly, EU-Monthly, APAC-Monthly). [ENUM-REF-CANDIDATE: US-Biweekly|US-Semimonthly|EU-Monthly|APAC-Monthly|CA-Biweekly|UK-Monthly —',
    `pay_period_end_date` DATE COMMENT 'The last calendar date of the pay period covered by this payroll record. Defines the end of the compensation earning window.',
    `pay_period_start_date` DATE COMMENT 'The first calendar date of the pay period covered by this payroll record. Defines the beginning of the compensation earning window.',
    `payment_date` DATE COMMENT 'The actual date on which the net pay was disbursed to the employee. Used for cash flow reporting and SOX financial controls.',
    `payment_method` STRING COMMENT 'The method by which net pay was disbursed to the employee (e.g., direct deposit, check, wire transfer). Sourced from the source system election settings.. Valid values are `direct_deposit|check|wire_transfer|cash`',
    `payroll_run_reference` STRING COMMENT 'Unique identifier for the payroll run batch in which this record was processed, as assigned by the source system traceability of all records processed in a single payroll run cycle.',
    `payroll_run_type` STRING COMMENT 'Classifies the nature of the payroll run: regular scheduled run, off-cycle correction, supplemental bonus run, or final paycheck upon termination.. Valid values are `regular|off_cycle|supplemental|correction|final`',
    `record_created_timestamp` TIMESTAMP COMMENT 'The timestamp when this payroll record was first created in the Databricks Silver Layer. Supports data lineage, audit trail, and SOX financial reporting controls.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this payroll record was last modified in the Databricks Silver Layer. Tracks data refresh cycles and supports SOX audit trail requirements.',
    `retirement_deduction` DECIMAL(18,4) COMMENT 'Employee pre-tax or post-tax retirement contribution deducted from gross pay (e.g., 401(k), pension, RRSP). Supports benefits compliance and workforce total compensation reporting.',
    `run_status` STRING COMMENT 'Current processing lifecycle status of this payroll record within the the source system run workflow. Supports SOX audit trail requirements.. Valid values are `calculated|confirmed|paid|reversed|void`',
    `study_allocation_code` STRING COMMENT 'The clinical study or project code to which this payroll expense is allocated for workforce cost tracking. Enables direct linkage of labor costs to specific clinical trials for sponsor billing and budget management.',
    `tax_jurisdiction_code` STRING COMMENT 'The primary tax jurisdiction code applicable to this payroll record (e.g., US-CA for California, UK for United Kingdom). Determines which tax tables and rates are applied during payroll calculation.',
    `tax_withholding_status` STRING COMMENT 'The employees federal/national tax filing status as declared on their withholding form (e.g., W-4 in the US), which determines the applicable tax withholding rate for this pay period.. Valid values are `single|married|head_of_household|exempt`',
    `total_tax_deduction` DECIMAL(18,4) COMMENT 'Aggregate amount withheld from gross pay for all applicable taxes (federal, state/provincial, local income tax, social security, Medicare/national insurance) during this pay period.',
    `work_country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the country where the employee performed work during this pay period. Determines applicable tax jurisdiction, labor law, and regulatory compliance requirements.. Valid values are `^[A-Z]{3}$`',
    `workday_worker_code` STRING COMMENT 'The native worker identifier assigned by the source system the employee. Used for system-of-record traceability back to the the source system',
    CONSTRAINT pk_payroll_record PRIMARY KEY(`payroll_record_id`)
) COMMENT 'Transactional record of payroll processing events for each employee, sourced from the source system module. Captures pay period start and end dates, gross pay, net pay, pay components (base salary, overtime, bonus, allowances), deductions (tax';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`workforce`.`org_unit` (
    `org_unit_id` BIGINT COMMENT 'Unique surrogate identifier for the organizational unit record in the clinical research organization hierarchy. Primary key for this entity.',
    `cost_center_id` BIGINT COMMENT 'Reference to the finance cost center associated with this organizational unit, enabling cost allocation to studies and financial reporting in the source system',
    `parent_org_unit_id` BIGINT COMMENT 'Reference to the immediate parent organizational unit in the hierarchy, enabling hierarchical rollup of headcount, FTE, and training compliance by department. Null for the root organization node.',
    `change_reason` STRING COMMENT 'Business justification or reason code for the most recent organizational change affecting this unit (e.g., restructuring, merger, new program launch). Supports organizational change management and audit trail requirements.',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code of the primary country where this organizational unit is domiciled. Supports regulatory jurisdiction determination, GDPR/HIPAA applicability, and country-level workforce reporting.. Valid values are `^[A-Z]{3}$`',
    `ctms_org_ref` STRING COMMENT 'Reference identifier for this organizational unit in the source system used for cross-system reconciliation of resource assignments, site monitoring activities, and study staffing records.',
    `effective_end_date` DATE COMMENT 'Date on which this organizational unit ceased to be operationally effective. Null for currently active units. Used for organizational change management and historical workforce analytics.',
    `effective_start_date` DATE COMMENT 'Date on which this organizational unit became operationally effective. Supports bi-temporal modeling for organizational change management and historical headcount reporting.',
    `email_address` STRING COMMENT 'Primary contact email address for the organizational unit (e.g., a shared mailbox). Classified as confidential organizational contact data.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `fte_budget` DECIMAL(10,2) COMMENT 'Approved budgeted Full-Time Equivalent (FTE) count for this organizational unit in the current planning period. Supports resource allocation to clinical studies and capacity planning analytics.',
    `functional_area` STRING COMMENT 'Primary functional area or discipline of the organizational unit within the CRO. Used for workforce capability planning, study resource allocation, and training compliance tracking.',
    `gcp_training_compliance_pct` DECIMAL(5,2) COMMENT 'Percentage of employees within this organizational unit who have current, valid GCP training certifications. Supports regulatory inspection readiness reporting and compliance dashboards per ICH E6(R2) requirements.',
    `geographic_region` STRING COMMENT 'Geographic region in which this organizational unit primarily operates. Used for regional workforce reporting, regulatory jurisdiction mapping, and multi-regional study resource allocation.. Valid values are `global|north_america|europe|asia_pacific|latin_america|middle_east_africa`',
    `headcount_budget` BIGINT COMMENT 'Approved budgeted headcount (number of positions) for this organizational unit in the current planning period. Used for workforce capacity planning and variance analysis against actual headcount.',
    `hierarchy_level` BIGINT COMMENT 'Numeric depth of this organizational unit within the enterprise hierarchy, where 1 represents the top-level entity. Enables efficient hierarchical rollup queries for headcount, FTE, and training compliance reporting.',
    `hierarchy_path` STRING COMMENT 'Materialized path string representing the full ancestry chain of the organizational unit from root to current node (e.g., /CRO-ROOT/CLINICAL-OPS/NA/MONITORING). Enables efficient subtree queries without recursive joins.',
    `is_billable` BOOLEAN COMMENT 'Indicates whether the costs and resources of this organizational unit are directly billable to sponsor contracts. Drives cost allocation logic in the source system accounting and study budget management.',
    `is_gcp_regulated` BOOLEAN COMMENT 'Indicates whether this organizational unit performs GCP-regulated activities requiring mandatory GCP training, delegation log maintenance, and regulatory inspection readiness per ICH E6(R2) and FDA 21 CFR Part 312.',
    `phone_number` STRING COMMENT 'Primary contact phone number for the organizational unit. Classified as confidential organizational contact data.. Valid values are `^+?[0-9s-().]{7,20}$`',
    `physical_location` STRING COMMENT 'Physical office location or facility name where this organizational unit is primarily based (e.g., Boston HQ – Floor 4, London Office). Used for site management, facilities planning, and regulatory inspection logistics.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this organizational unit record was first created in the data platform. Supports audit trail, data lineage, and ALCOA+ compliance requirements for clinical data management.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this organizational unit record was most recently updated in the data platform. Supports change tracking, audit trail, and ALCOA+ compliance for regulated clinical research environments.',
    `sop_owner` STRING COMMENT 'Name or identifier of the designated Standard Operating Procedure (SOP) owner for this organizational unit, responsible for maintaining and approving SOPs applicable to the units activities in MasterControl.',
    `therapeutic_area_focus` STRING COMMENT 'Primary therapeutic area specialization of the organizational unit (e.g., Oncology, Neurology, Cardiovascular, Infectious Disease). Supports study-to-resource matching and capacity planning for sponsor engagements.',
    `time_zone` STRING COMMENT 'IANA time zone identifier for the organizational units primary operating location (e.g., America/New_York, Europe/London). Used for scheduling, meeting coordination, and timestamp normalization in multi-regional studies.',
    `unit_code` STRING COMMENT 'Short alphanumeric code uniquely identifying the organizational unit, used in system integrations, cost allocation references, and reporting filters (e.g., CLIN-OPS-NA, BIOSTATS, REG-AFF).. Valid values are `^[A-Z0-9_-]{2,20}$`',
    `unit_description` STRING COMMENT 'Free-text description of the organizational units mandate, responsibilities, and scope within the CRO. Provides context for workforce planning, onboarding, and organizational change management documentation.',
    `unit_name` STRING COMMENT 'Official human-readable name of the organizational unit as defined in the source system Clinical Operations – North America, Biostatistics & Programming, Regulatory Affairs). Used in workforce reporting and organizational charts.',
    `unit_status` STRING COMMENT 'Current lifecycle status of the organizational unit. Inactive or dissolved units are retained for historical reporting and audit trail purposes per GCP and SOX requirements.. Valid values are `active|inactive|pending|dissolved|merged`',
    `unit_type` STRING COMMENT 'Classification of the organizational unit within the CRO hierarchy. Determines reporting rollup behavior and cost allocation rules. [ENUM-REF-CANDIDATE: department|division|cost_center|team|function|business_unit — promote to reference product if',
    CONSTRAINT pk_org_unit PRIMARY KEY(`org_unit_id`)
) COMMENT 'Reference master for the organizational hierarchy of the clinical research organization, sourced from the source system organizational unit name, unit type (department, division, cost center, team), parent unit, unit head employee, cost center code';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`workforce`.`position` (
    `position_id` BIGINT COMMENT 'Unique surrogate identifier for the approved headcount position record within the clinical research organization. Primary key for the position master in the the source system Management module.',
    `cost_center_id` BIGINT COMMENT 'Reference to the finance cost center in the source system which the budgeted FTE cost for this position is allocated. Enables budget-to-actual headcount cost reconciliation and SOX financial reporting controls.',
    `hiring_manager_employee_id` BIGINT COMMENT 'Reference to the employee record of the manager responsible for recruiting and onboarding the incumbent for this position. Used in the source system workflows and CTMS resource request approvals.',
    `job_profile_id` BIGINT COMMENT 'FK to workforce.job_profile',
    `org_unit_id` BIGINT COMMENT 'Reference to the organizational unit (department or cost center) to which this position is budgeted and assigned in the source system headcount reporting by department and supports budget-to-actual workforce analysis.',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to.',
    `workforce_resource_plan_id` BIGINT COMMENT 'Foreign key linking to workforce.workforce_resource_plan. Business justification: workforce_resource_plan drives headcount planning and position creation. A position is typically created to fulfill a resource plan demand.',
    `approval_status` STRING COMMENT 'Workflow approval state of the position request within the source system position must reach Approved status before recruiting activities can commence. Supports SOX headcount authorization controls.. Valid values are `Draft|Pending|Approved|Rejected|Cancelled`',
    `approved_date` DATE COMMENT 'Date on which the position received final budget and headcount approval in the source system for SOX audit trail of headcount authorization and for calculating time-to-fill from approval.',
    `budgeted_fte` DECIMAL(5,2) COMMENT 'Approved full-time equivalent headcount units budgeted for this position (e.g., 1.00 for full-time, 0.50 for half-time). Sourced from the annual headcount plan in the source system reconciled against the source system accounting budgets.',
    `clinical_role_category` STRING COMMENT 'Functional classification of the position within the clinical research organizations role taxonomy. Determines GCP training requirements, delegation eligibility, and system access provisioning in Medidata Rave, Veeva Vault, and the source system',
    `position_code` STRING COMMENT 'Externally-known alphanumeric code that uniquely identifies the position within the organizations headcount plan. Used in budget reconciliation, CTMS resource planning, and regulatory workforce reporting.',
    `country_code` STRING COMMENT 'ISO 3166-1 alpha-3 country code for the primary country of assignment for this position (e.g., USA, GBR, DEU, JPN). Determines applicable employment law, GCP guideline version, and data privacy regulations (GDPR, HIPAA).. Valid values are `^[A-Z]{3}$`',
    `effective_end_date` DATE COMMENT 'Date on which this position ceases to be active in the headcount plan. Null for open-ended permanent positions. Set when a position is eliminated, restructured, or converted to a different position type.',
    `effective_start_date` DATE COMMENT 'Date from which this position is active and authorized within the approved headcount plan. Positions may not be filled or advertised before this date. Aligns with the source system model.',
    `filled_date` DATE COMMENT 'Actual date on which the position was filled by an incumbent employee. Populated when incumbency_status transitions to Filled. Used to calculate time-to-fill KPIs and assess recruiting efficiency.',
    `freeze_reason` STRING COMMENT 'Free-text explanation for why a position has been frozen (incumbency_status = Frozen). Common reasons include budget hold, organizational restructuring, study portfolio reduction, or sponsor funding delay. Null when position is not frozen.',
    `geographic_region` STRING COMMENT 'Operational geographic region to which this position is assigned. Drives regional headcount planning, site monitoring coverage analysis, and regulatory jurisdiction alignment (FDA, EMA, PMDA, TGA, Health Canada).. Valid values are `Global|North America|EMEA|APAC|Latin America|Japan`',
    `headcount_plan_year` BIGINT COMMENT 'Fiscal year in which this position was approved in the annual headcount plan (e.g., 2024, 2025). Used to align position records with annual budget cycles in the source system the source system planning.',
    `incumbency_status` STRING COMMENT 'Current occupancy state of the position within the approved headcount plan. Filled = active employee assigned; Vacant = approved but unoccupied; Frozen = headcount approved but hiring suspended; Pending-Approval = awaiting budget authorization; Eliminated. Valid values are `Filled|Vacant|Frozen|Pending-Approval|Eliminated`',
    `is_delegation_eligible` BOOLEAN COMMENT 'Indicates whether the position is eligible to appear on a site delegation log as a delegatee for PI-authorized tasks. Determined by job profile, GCP certification status, and protocol training requirements per ICH E6(R2) and FDA guidance.',
    `is_gcp_required` BOOLEAN COMMENT 'Indicates whether the incumbent of this position is required to hold a current GCP certification as a condition of role eligibility. True for all positions with direct study involvement (CRA, CRC, Medical Monitor, PI oversight).',
    `is_pi_eligible` BOOLEAN COMMENT 'Indicates whether the position is designated as eligible to serve as a Principal Investigator (PI) on a clinical study. PI-eligible positions require medical licensure verification and are subject to enhanced regulatory scrutiny by FDA, EMA, and IRB/IEC.',
    `is_safety_reporting_role` BOOLEAN COMMENT 'Indicates whether the position carries regulatory responsibility for adverse event (AE) and serious adverse event (SAE) reporting obligations. Positions flagged True require the source system system access and SAE/SUSAR reporting training per ICH E2A',
    `job_family` STRING COMMENT 'Broad functional grouping of the position within the clinical research organizations job architecture (e.g., Clinical Operations, Biostatistics, Data Management, Regulatory Affairs, Medical Affairs, Finance).',
    `job_level` STRING COMMENT 'Career level designation for the position within the job family hierarchy. Governs pay grade eligibility, delegation authority, and GCP oversight responsibilities.',
    `pay_grade` STRING COMMENT 'Compensation grade band assigned to this position in the source system G5, G6, M1). Governs salary range eligibility and is used in budget forecasting and compensation benchmarking. Classified as confidential business data.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this position record was first created in the lakehouse silver layer. Supports ALCOA+ data integrity principles (Attributable, Legible, Contemporaneous, Original, Accurate) required for GCP-compliant audit trails.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this position record in the lakehouse silver layer. Used for incremental data pipeline processing and audit trail completeness per ALCOA+ and FDA 21 CFR Part 11.',
    `salary_currency` STRING COMMENT 'ISO 4217 three-letter currency code for the salary range values associated with this position (e.g., USD, EUR, GBP, JPY). Required for multi-currency workforce cost consolidation in the source system. Valid values are `^[A-Z]{3}$`',
    `salary_range_max` DECIMAL(15,2) COMMENT 'Maximum base salary defined for this positions pay grade in the approved compensation structure. Used in budget planning and offer management workflows in the source system as confidential.',
    `salary_range_min` DECIMAL(15,2) COMMENT 'Minimum base salary defined for this positions pay grade in the approved compensation structure. Used in budget planning and offer management workflows in the source system as confidential.',
    `target_fill_date` DATE COMMENT 'Planned date by which a vacant position should be filled with a qualified incumbent. Used in workforce planning dashboards and study resource gap analysis to flag at-risk studies due to unfilled critical roles (e.g., CRA, Medical Monitor).',
    `therapeutic_area` STRING COMMENT 'Primary therapeutic area specialization associated with this position (e.g., Oncology, Neurology, Cardiovascular, Infectious Disease, Rare Disease). Used for study-to-resource matching in CTMS and capacity planning for specialized clinical expertise.',
    `title` STRING COMMENT 'Official job title associated with the position as defined in the the source system catalog (e.g., Clinical Research Associate II, Senior Biostatistician, Medical Monitor, Regulatory Affairs Specialist).',
    `position_type` STRING COMMENT 'Employment arrangement type for the position. Determines benefits eligibility, contract terms, and workforce planning classification. Permanent and Fixed-Term positions are tracked in the source system Contractor positions may be managed via the source. Valid values are `Permanent|Fixed-Term|Contractor|Temporary|Intern`',
    `vacated_date` DATE COMMENT 'Date on which the most recent incumbent vacated the position (due to termination, transfer, or promotion), causing the incumbency_status to revert to Vacant. Supports turnover analysis and study continuity risk assessment.',
    `workday_position_code` STRING COMMENT 'The native position identifier assigned by the source system P-00012345). Used for cross-system reconciliation between the lakehouse silver layer and the the source system',
    CONSTRAINT pk_position PRIMARY KEY(`position_id`)
) COMMENT 'Master record for approved headcount positions within the clinical research organization, managed in the source system position title, job profile, org unit, position type (permanent, fixed-term, contractor), budgeted FTE, current incumbency status';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` (
    `protocol_training_record_id` BIGINT COMMENT 'Unique surrogate identifier for each protocol-specific training completion record in the clinical research workforce. Primary key for this entity.',
    `investigational_site_id` BIGINT COMMENT 'Reference to the clinical trial site to which the employee is assigned and for which this protocol training is applicable. Null for central/sponsor-side staff not assigned to a specific site.',
    `primary_protocol_employee_id` BIGINT COMMENT 'Reference to the workforce member (CRA, CRC, biostatistician, data manager, medical monitor, regulatory specialist, etc.) who completed the protocol training. Sourced from the source system',
    `protocol_id` BIGINT COMMENT 'Foreign key linking to study.protocol. Business justification: GCP/ICH E6 R2 requires proof that staff were trained on the specific protocol version in effect.',
    `study_assignment_id` BIGINT COMMENT 'Foreign key linking to workforce.study_assignment. Business justification: protocol_training_record captures protocol-specific training for workforce members assigned to studies.',
    `study_id` BIGINT COMMENT 'Reference to the clinical study for which this protocol training was completed. Links to the study master record in the CTMS.',
    `study_protocol_amendment_id` BIGINT COMMENT 'Foreign key linking to study.study_protocol_amendment. Business justification: Protocol amendments mandate staff retraining (ICH E6 R2, 21 CFR 312). Linking protocol_training_record to the triggering amendment enables automated retraining workflows, TMF',
    `tmf_artifact_id` BIGINT COMMENT 'Reference to the corresponding TMF artifact record in Veeva Vault eTMF where the training completion evidence is filed. Supports TMF completeness tracking and regulatory inspection readiness.',
    `tmf_document_id` BIGINT COMMENT 'Reference to the controlled training material or document record in the document management system (MasterControl/Veeva Vault) used for this protocol training session.',
    `workforce_delegation_log_id` BIGINT COMMENT 'Reference to the delegation log entry that this protocol training record satisfies or supports. Confirms that the delegatee has completed required protocol training before performing delegated trial tasks.',
    `assessment_score` DECIMAL(5,2) COMMENT 'Numeric score achieved by the employee on the post-training knowledge assessment or quiz, expressed as a percentage (0.00–100.00). Null if no formal assessment was administered for this training type.',
    `attempt_number` BIGINT COMMENT 'Sequential attempt number for this training record, starting at 1. Increments when an employee retakes a failed assessment. Supports tracking of re-training compliance and quality metrics.',
    `certificate_number` STRING COMMENT 'Unique certificate number issued upon successful completion of the protocol training, if a certificate was generated. Used for audit trail, TMF filing, and regulatory inspection documentation.',
    `expiry_date` DATE COMMENT 'The date on which this protocol training record expires and re-training is required, if applicable. Null for training records with no defined expiry. Triggers re-training workflows and delegation log reviews.',
    `inspection_ready` BOOLEAN COMMENT 'Indicates whether this training record is complete, signed, and filed in the TMF such that it is ready for regulatory inspection by FDA, EMA, MHRA, or other health authorities. Supports inspection readiness dashboards.',
    `mastercontrol_training_code` STRING COMMENT 'The native training record identifier from MasterControl, the source system of record for training management. Used for cross-system reconciliation and audit trail traceability.',
    `notes` STRING COMMENT 'Free-text field for additional context, observations, or remarks related to this protocol training record (e.g., special circumstances, sponsor feedback, partial completion notes). Not intended for structured data.',
    `pass_fail_status` STRING COMMENT 'Outcome of the protocol training assessment indicating whether the employee passed, failed, or was not assessed (for training types without a formal assessment). Drives re-training requirements and delegation eligibility.. Valid values are `pass|fail|not_assessed`',
    `passing_score_threshold` DECIMAL(5,2) COMMENT 'The minimum assessment score required to pass the protocol training, expressed as a percentage (e.g., 80.00). Used to determine pass/fail status and to support quality oversight of training standards.',
    `protocol_version` STRING COMMENT 'The specific version of the study protocol on which the employee was trained (e.g., v1.0, Amendment 2). Critical for ensuring staff are trained on the current approved protocol version before conducting trial activities.',
    `record_created_timestamp` TIMESTAMP COMMENT 'The timestamp when this protocol training record was first created in the data platform. Audit field supporting data lineage, ALCOA+ compliance, and Silver layer ingestion tracking.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this protocol training record was last modified in the data platform. Audit field supporting change tracking, data lineage, and regulatory inspection readiness.',
    `retraining_due_date` DATE COMMENT 'The date by which re-training must be completed when re-training is required. Null if re-training is not required. Used for compliance monitoring and escalation workflows.',
    `retraining_required` BOOLEAN COMMENT 'Indicates whether re-training is required for this employee on this protocol, either due to a failed assessment, protocol amendment, or expiry of a prior training record. Drives automated re-training assignment workflows.',
    `role_at_training` STRING COMMENT 'The workforce role of the employee at the time of protocol training completion (e.g., CRA, CRC, Data Manager, Medical Monitor, Biostatistician). Captures the role context for delegation log validation and inspection readiness.',
    `signature_captured` BOOLEAN COMMENT 'Indicates whether a compliant electronic signature (per 21 CFR Part 11) has been captured from the employee acknowledging completion of the protocol training. Required for GCP-compliant training records.',
    `signature_date` DATE COMMENT 'The date on which the employee applied their electronic or wet signature to acknowledge completion of the protocol training. Must align with training_date for ALCOA+ compliance.',
    `study_phase` STRING COMMENT 'The regulatory phase of the clinical study for which protocol training was completed. Informs the complexity and depth of training required and supports workforce competency analytics.. Valid values are `Phase I|Phase II|Phase III|Phase IV|Phase I/II`',
    `therapeutic_area` STRING COMMENT 'The therapeutic area of the clinical study for which protocol training was completed (e.g., Oncology, Cardiology, Neurology, Infectious Disease). Used for workforce competency profiling and resource planning.',
    `trainer_name` STRING COMMENT 'Name of the individual trainer (e.g., Medical Monitor, Principal Investigator, CRA trainer) or external training provider organization who delivered the protocol training. Captured for audit trail and qualification verification purposes.',
    `training_date` DATE COMMENT 'The date on which the workforce member completed the protocol training session. This is the principal real-world event date used for compliance verification and delegation log validation.',
    `training_delivery_method` STRING COMMENT 'The modality through which the protocol training was delivered. Distinguishes between in-person sessions, live webinars, e-learning modules, self-study (read and understood), and investigator/site initiation meetings.. Valid values are `in_person|webinar|e_learning|self_study|investigator_meeting`',
    `training_duration_minutes` BIGINT COMMENT 'Total duration of the protocol training session in minutes. Used for workforce capacity planning, training compliance reporting, and verification that minimum training time requirements were met.',
    `training_material_version` STRING COMMENT 'Version identifier of the training material or curriculum used for this training session (e.g., v2.1, Q3-2024). Ensures traceability between training content and the protocol version it covers.',
    `training_provider_name` STRING COMMENT 'Name of the external organization or vendor that provided the protocol training, if applicable (e.g., sponsor medical affairs team, CRO training department, third-party eLearning vendor). Null for internally delivered training.',
    `training_record_number` STRING COMMENT 'Externally-known, human-readable unique identifier for this protocol training record as assigned by the training management system (MasterControl). Used for audit trail references, TMF filing, and regulatory inspection readiness.',
    `training_status` STRING COMMENT 'Current lifecycle status of the protocol training record. Indicates whether training has been completed, is in progress, not yet started, overdue, formally waived, or has expired and requires renewal.. Valid values are `completed|in_progress|not_started|overdue|waived|expired`',
    `training_type` STRING COMMENT 'Classification of the protocol training content delivered. Distinguishes between initial protocol overview training, amendment-specific training, therapeutic area background, pharmacology/PK/PD training, safety reporting procedures, and study-specific. Valid values are `protocol_overview|protocol_amendment|therapeutic_area|pharmacology|safety_reporting|study_procedures`',
    `waiver_approved_by` STRING COMMENT 'Name or identifier of the authorized approver who granted the training waiver. Required for audit trail when training_status is waived. Supports regulatory inspection readiness.',
    `waiver_reason` STRING COMMENT 'Documented justification for waiving the protocol training requirement for this employee, if applicable (e.g., equivalent prior training on same protocol version, sponsor-approved exemption). Null if no waiver was granted.',
    `workday_worker_code` STRING COMMENT 'The the source system identifier for the employee who completed the training. Used for cross-system reconciliation between the training management system and the HR system of record.',
    CONSTRAINT pk_protocol_training_record PRIMARY KEY(`protocol_training_record_id`)
) COMMENT 'Transactional record capturing protocol-specific training completions for workforce members assigned to a clinical study. Captures study protocol number, protocol version trained on, employee, training date, training type (protocol overview, amendments';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` (
    `cra_qualification_id` BIGINT COMMENT 'Unique surrogate identifier for the CRA qualification profile record in the Databricks Silver Layer. Primary key for this master resource entity.',
    `organization_id` BIGINT COMMENT 'Foreign key linking to sponsor.organization. Business justification: Sponsor-specific CRA qualification programs (common in oncology and large pharma sponsors) require linking CRA qualifications to the issuing sponsor organization for qualification expiry',
    `primary_cra_employee_id` BIGINT COMMENT 'Reference to the employee record in the source system the CRA whose qualification profile this record describes.',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to.',
    `therapeutic_area_id` BIGINT COMMENT 'Foreign key linking to the therapeutic area reference record for which this CRA qualification applies',
    `approval_date` DATE COMMENT 'Date on which the CRA qualification profile was formally approved by the authorized approver, establishing the record as inspection-ready.',
    `country_codes` STRING COMMENT 'Pipe-delimited list of ISO 3166-1 alpha-3 country codes representing countries where the CRA is authorized to conduct site monitoring (e.g., USA|GBR|DEU|JPN). Supports country-level site assignment decisions.',
    `ctms_proficiency` STRING COMMENT 'Proficiency level of the CRA in the source system for site monitoring visit tracking, action item management, and study progress reporting.. Valid values are `none|basic|intermediate|advanced|expert`',
    `ctms_qualification_ref` STRING COMMENT 'the source system system reference identifier for the CRA qualification record, used for cross-system traceability between the Databricks Silver Layer and the operational CTMS.',
    `device_trial_experience_confirmed` BOOLEAN COMMENT 'Indicates whether the CRA has documented experience monitoring medical device clinical investigations, subject to ISO 14155 requirements distinct from pharmaceutical GCP.',
    `effective_date` DATE COMMENT 'Date from which this CRAs qualification for the specific therapeutic area became active and the CRA was eligible for assignment to studies in this TA.',
    `experience_confirmed` BOOLEAN COMMENT 'Indicates whether the CRA has confirmed, documented monitoring experience in this specific therapeutic area, as distinct from theoretical or training-based qualification. Used as a quality gate in study assignment eligibility.',
    `expiry_date` DATE COMMENT 'Date on which this CRAs qualification for the specific therapeutic area expires and requires re-assessment or renewal before further TA-specific assignments.',
    `geographic_regions` STRING COMMENT 'Pipe-delimited list of geographic regions where the CRA is qualified and authorized to conduct monitoring activities (e.g., North America|Western Europe|Asia Pacific). Used for regional site assignment planning.',
    `independent_monitoring_visits` BIGINT COMMENT 'Count of monitoring visits conducted independently (without co-monitoring oversight), distinguishing fully qualified CRAs from those still under supervised training.',
    `inspection_ready` BOOLEAN COMMENT 'Indicates whether the CRA qualification profile is complete, approved, and ready for regulatory inspection review (e.g., FDA, EMA, MHRA audit). Drives TMF completeness checks.',
    `irt_rtsm_proficiency` STRING COMMENT 'Proficiency level of the CRA in IRT/RTSM systems (e.g., Medidata RTSM) for patient randomization, drug supply management, and kit dispensation oversight during site monitoring.. Valid values are `none|basic|intermediate|advanced|expert`',
    `language_proficiencies` STRING COMMENT 'Pipe-delimited list of ISO 639-1 language codes in which the CRA is proficient for site communication and source document review (e.g., en|de|fr|ja). Critical for site assignment in non-English-speaking countries.',
    `last_qualification_review_date` DATE COMMENT 'Date of the most recent formal review and update of the CRA qualification profile by the line manager or QA function, ensuring the profile reflects current competencies.',
    `medidata_rave_proficiency` STRING COMMENT 'Self-assessed and/or verified proficiency level of the CRA in Medidata Rave Electronic Data Capture (EDC) system, including eCRF review, query management, and SDV workflows.. Valid values are `none|basic|intermediate|advanced|expert`',
    `monitoring_experience_years` DECIMAL(5,2) COMMENT 'Total years of clinical site monitoring experience accumulated by the CRA, used as a primary qualification criterion for study-phase and complexity-based assignment decisions.',
    `next_qualification_review_date` DATE COMMENT 'Scheduled date for the next periodic review of the CRA qualification profile. Drives automated reminders in CTMS and the source system ensure timely re-qualification.',
    `oncology_experience_confirmed` BOOLEAN COMMENT 'Indicates whether the CRA has confirmed, documented oncology monitoring experience, a specialized qualification required for oncology study assignments given the complexity of CTCAE adverse event grading and tumor assessment protocols.',
    `oracle_clinical_one_proficiency` STRING COMMENT 'Proficiency level of the CRA in the source system platform, covering study design navigation, site management functions, and patient randomization workflows.. Valid values are `none|basic|intermediate|advanced|expert`',
    `primary_language_code` STRING COMMENT 'ISO 639-1 two-letter code for the CRAs primary working language. Used as the default language for monitoring report generation and site communication.. Valid values are `^[a-z]{2}$`',
    `qualification_code` STRING COMMENT 'Externally-known business identifier for the qualification profile, used in the source system and the source system cross-system reference and CRA-to-study matching workflows.. Valid values are `^CRA-QUAL-[A-Z0-9]{6,12}$`',
    `qualification_effective_date` DATE COMMENT 'Date from which the CRA qualification profile became effective and the CRA was eligible for study assignment based on this profile. Represents the start of the qualification agreement period.',
    `qualification_expiry_date` DATE COMMENT 'Date on which the overall CRA qualification profile expires and requires re-assessment. Null for open-ended qualifications. Used to enforce periodic re-qualification cycles.',
    `qualification_notes` STRING COMMENT 'Free-text field for additional qualification context, exceptions, or special conditions noted by the reviewing manager (e.g., Qualified for Phase I only pending Phase II co-monitoring completion).',
    `qualification_status` STRING COMMENT 'Current lifecycle status of the CRA qualification profile. active indicates the CRA is qualified and available for study assignment; suspended indicates a temporary hold pending re-qualification; pending_review indicates the profile is under QA. Valid values are `active|inactive|suspended|pending_review|archived`',
    `qualification_type` STRING COMMENT 'Classification of the CRA qualification profile by operational role type. Determines eligibility for specific monitoring assignment categories (e.g., field vs. remote monitoring, lead CRA oversight responsibilities).. Valid values are `field_cra|remote_cra|lead_cra|senior_cra|contract_cra`',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when the CRA qualification profile record was first created in the system, in ISO 8601 format with timezone offset. Supports audit trail and ALCOA+ data integrity requirements.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to the CRA qualification profile record, in ISO 8601 format with timezone offset. Supports change tracking and ALCOA+ audit trail requirements.',
    `risk_based_monitoring_qualified` BOOLEAN COMMENT 'Indicates whether the CRA is qualified to conduct risk-based monitoring (RBM) activities, including centralized statistical monitoring review and targeted SDV, per ICH E6(R2) Addendum guidance.',
    `sdv_experience_confirmed` BOOLEAN COMMENT 'Indicates whether the CRA has confirmed, documented experience performing Source Data Verification (SDV) against source documents at clinical sites, a core GCP monitoring competency.',
    `sponsor_qualification_expiry_date` DATE COMMENT 'Date on which the most recent sponsor-specific qualification expires and requires renewal. Used to trigger re-qualification workflows and prevent assignment of expired-qualified CRAs to sponsor studies.',
    `sponsor_qualifications` STRING COMMENT 'Pipe-delimited list of sponsor names or sponsor codes for which the CRA holds sponsor-specific qualification status (e.g., sponsor-mandated training completion, sponsor-approved CRA status). Used for sponsor-restricted study assignments.',
    `cra_qualification_status` STRING COMMENT 'Current lifecycle status of this CRAs qualification for the specific therapeutic area. Drives eligibility filtering during CRA-to-study matching.',
    `study_phases_experienced` STRING COMMENT 'Pipe-delimited list of clinical study phases in which the CRA has monitoring experience (e.g., Phase I|Phase II|Phase III|Phase IV). Used to match CRAs to studies of appropriate complexity.',
    `therapeutic_areas` STRING COMMENT 'Pipe-delimited list of therapeutic areas in which the CRA has documented monitoring experience (e.g., Oncology|Cardiology|Neurology|Infectious Disease). Used for therapeutic area-based study matching.',
    `total_monitoring_visits` BIGINT COMMENT 'Cumulative count of clinical site monitoring visits (initiation, interim, close-out) conducted by the CRA across all studies. Key operational metric for experience-based qualification assessment.',
    `veeva_vault_proficiency` STRING COMMENT 'Proficiency level of the CRA in Veeva Vault for electronic Trial Master File (eTMF) management, regulatory document filing, and TMF completeness tracking.. Valid values are `none|basic|intermediate|advanced|expert`',
    `workday_worker_code` STRING COMMENT 'the source system worker identifier for the CRA, used for cross-system reconciliation between the qualification profile and HR records.',
    CONSTRAINT pk_cra_qualification PRIMARY KEY(`cra_qualification_id`)
) COMMENT 'Master record capturing the qualification profile of a Clinical Research Associate (CRA), including therapeutic area experience, monitoring experience (years, visit count), geographic coverage regions, language proficiencies, sponsor-specific';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` (
    `workforce_capa_id` BIGINT COMMENT 'Unique surrogate identifier for the workforce CAPA record. Primary key for this entity in the Databricks Silver Layer.',
    `compliance_sop_id` BIGINT COMMENT 'Reference to the SOP that was violated or that governs the process area implicated in the non-compliance. Links to compliance.sop for traceability and SOP revision tracking.',
    `initiating_audit_id` BIGINT COMMENT 'Reference to the compliance audit or inspection record that triggered this CAPA, if applicable. Links to compliance.audit or compliance.inspection for traceability.',
    `obligation_id` BIGINT COMMENT 'Foreign key linking to compliance.obligation. Business justification: Workforce CAPAs triggered by regulatory obligation non-compliance must reference the specific obligation to support regulatory commitment tracking, inspection readiness, and compliance',
    `owner_employee_id` BIGINT COMMENT 'Identifier of the employee (typically a QA manager or line manager) responsible for overseeing the CAPA to closure. Distinct from the assigned employee who is the subject of the CAPA.',
    `primary_workforce_employee_id` BIGINT COMMENT 'Identifier of the workforce member (CRA, CRC, biostatistician, data manager, medical monitor, regulatory specialist, etc.) against whom the CAPA is initiated. References the employee master in the source system',
    `prior_capa_workforce_capa_id` BIGINT COMMENT 'Reference to the previous CAPA record for the same employee and non-compliance category, if this CAPA represents a recurrence. Enables recurrence chain analysis and escalation tracking.',
    `study_assignment_id` BIGINT COMMENT 'Foreign key linking to workforce.study_assignment. Business justification: CAPAs in clinical research often arise in the context of a specific study assignment where the non-compliance occurred.',
    `study_id` BIGINT COMMENT 'Identifier of the clinical study associated with the non-compliance event that triggered this CAPA, if the CAPA is study-specific. Null for organization-wide or training-related CAPAs.',
    `tmf_artifact_id` BIGINT COMMENT 'Reference to the TMF artifact in Veeva Vault eTMF where the CAPA documentation is filed, ensuring regulatory archival compliance and inspection readiness.',
    `training_record_id` BIGINT COMMENT 'Reference to the specific GCP or SOP training record associated with the training non-compliance that triggered this CAPA. Enables linkage between CAPA and training remediation actions.',
    `capa_number` STRING COMMENT 'Human-readable, externally-known CAPA reference number assigned by MasterControl upon initiation (e.g., CAPA-WF-2024-00123). Used for cross-system referencing, audit trails, and regulatory inspection readiness.. Valid values are `^CAPA-WF-[0-9]{4}-[0-9]{5}$`',
    `capa_status` STRING COMMENT 'Current lifecycle state of the CAPA record within MasterControl workflow. Drives escalation logic, dashboard KPIs, and inspection-readiness reporting. [ENUM-REF-CANDIDATE: draft|open|in_progress|pending_review|closed|cancelled|overdue — promote to',
    `capa_type` STRING COMMENT 'Classifies whether the CAPA is corrective (addressing an existing non-compliance), preventive (proactively mitigating risk), or combined (both elements present). Drives workflow routing and reporting in MasterControl.. Valid values are `corrective|preventive|combined`',
    `closure_date` DATE COMMENT 'Date on which the CAPA was formally closed in MasterControl following satisfactory effectiveness check and QA approval. Null for open or in-progress CAPAs.',
    `closure_justification` STRING COMMENT 'Narrative justification provided by the CAPA owner and QA reviewer explaining the basis for closing the CAPA, including confirmation that actions were effective and the non-compliance is resolved.',
    `completion_date` DATE COMMENT 'Actual date on which all corrective and/or preventive actions were completed and documented. Null until actions are fully executed. Used to calculate cycle time and on-time closure metrics.',
    `corrective_action_description` STRING COMMENT 'Narrative description of the specific corrective actions planned or taken to address the identified non-compliance and prevent recurrence. Populated for corrective and combined CAPA types.',
    `due_date` DATE COMMENT 'Target date by which all CAPA actions must be completed and the record ready for closure review. Used for overdue tracking, escalation triggers, and inspection-readiness dashboards.',
    `effectiveness_check_date` DATE COMMENT 'Scheduled or actual date on which the effectiveness of the implemented CAPA actions is evaluated to confirm the non-compliance has been resolved and recurrence prevented. Required for GCP-compliant CAPA closure.',
    `effectiveness_check_description` STRING COMMENT 'Narrative description of the methodology and findings from the effectiveness check, including evidence reviewed and rationale for the effectiveness determination.',
    `effectiveness_check_result` STRING COMMENT 'Outcome of the effectiveness check evaluation. If not effective or partially effective, a new or extended CAPA may be required. Drives closure eligibility and regulatory reporting.. Valid values are `effective|partially_effective|not_effective|pending`',
    `employee_role` STRING COMMENT 'The workforce role of the employee at the time the non-compliance occurred. Captured as a denormalized snapshot to preserve historical accuracy independent of role changes.',
    `initiation_date` DATE COMMENT 'The date on which the CAPA was formally initiated and opened in MasterControl. Serves as the principal business event date for SLA and timeline calculations.',
    `inspection_ready` BOOLEAN COMMENT 'Indicates whether the CAPA record and its supporting documentation are complete and ready for regulatory inspection review. Used in inspection readiness dashboards and TMF completeness assessments.',
    `mastercontrol_capa_ref` STRING COMMENT 'Native record identifier from the MasterControl CAPA module, used for cross-system reconciliation and audit trail linkage back to the system of record.',
    `non_compliance_category` STRING COMMENT 'High-level category of the non-compliance or performance issue that triggered the CAPA. Used for trend analysis, root cause aggregation, and regulatory reporting.',
    `non_compliance_description` STRING COMMENT 'Detailed description of the GCP compliance failure, training non-compliance, or performance issue that prompted the CAPA. Captures the factual account of the event as observed during audit or inspection.',
    `notes` STRING COMMENT 'Free-text field for additional context, interim status updates, or supplementary information not captured in structured fields. Supports ALCOA+ documentation principles.',
    `preventive_action_description` STRING COMMENT 'Narrative description of the specific preventive actions planned or taken to proactively mitigate the risk of future non-compliance. Populated for preventive and combined CAPA types.',
    `priority` STRING COMMENT 'Business priority assigned to the CAPA to guide resource allocation and escalation. Derived from severity and potential patient safety or regulatory impact, but may be independently set by the CAPA owner.. Valid values are `high|medium|low`',
    `qa_review_date` DATE COMMENT 'Date on which the QA reviewer completed their review of the CAPA record and approved or rejected the closure request.',
    `qa_review_outcome` STRING COMMENT 'Outcome of the QA review of the CAPA closure package. Rejected or returned records require additional action before closure can be granted.. Valid values are `approved|rejected|pending|returned_for_revision`',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this CAPA record was first created in the data platform. Supports audit trail requirements under 21 CFR Part 11 and ALCOA+ data integrity principles.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp of the most recent update to this CAPA record in the data platform. Supports change tracking, audit trail requirements, and incremental data pipeline processing.',
    `recurrence_flag` BOOLEAN COMMENT 'Indicates whether this CAPA was initiated for a recurring non-compliance issue previously addressed by a prior CAPA for the same employee. Recurrence triggers escalated management review.',
    `regulatory_authority` STRING COMMENT 'The regulatory authority notified or implicated in the non-compliance event, if applicable. Relevant for multi-regional studies where different authorities have jurisdiction.',
    `regulatory_authority_notified` BOOLEAN COMMENT 'Indicates whether the relevant regulatory authority (FDA, EMA, MHRA, etc.) was notified of the non-compliance event associated with this CAPA. Required for critical GCP violations under applicable regulations.',
    `root_cause_category` STRING COMMENT 'Categorized root cause of the non-compliance as determined during CAPA investigation. Supports systemic trend analysis and preventive action planning across the workforce.',
    `root_cause_description` STRING COMMENT 'Detailed narrative of the identified root cause of the non-compliance or performance issue, as documented by the CAPA owner following investigation. Required for regulatory inspection readiness.',
    `severity` STRING COMMENT 'Severity classification of the non-compliance event driving the CAPA. Critical and major findings typically require expedited closure timelines and may trigger regulatory notification obligations.. Valid values are `critical|major|minor|observation`',
    `workday_worker_code` STRING COMMENT 'The the source system identifier for the employee who is the subject of the CAPA. Enables HR system cross-referencing for performance management and workforce analytics.',
    CONSTRAINT pk_workforce_capa PRIMARY KEY(`workforce_capa_id`)
) COMMENT 'Transactional record for Corrective and Preventive Actions (CAPAs) initiated against workforce members for GCP compliance failures, training non-compliance, or performance issues identified during audits or inspections. Managed through MasterControl.';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`workforce`.`program_team_member` (
    `program_team_member_id` BIGINT COMMENT 'Primary key for the program_team_member association',
    `clinical_program_id` BIGINT COMMENT 'Foreign key linking to the clinical development program to which the employee is assigned',
    `employee_id` BIGINT COMMENT 'Foreign key linking to the workforce member assigned to the clinical program team',
    `study_id` BIGINT COMMENT 'add column study_id (BIGINT) with FK to study.study.study_id — program team member should optionally reference a study when assigned at study level',
    `assignment_status` STRING COMMENT 'Current lifecycle state of this employees assignment to the clinical program. Controls access permissions, delegation authority activation, and workforce allocation reporting.',
    `delegation_authority_level` STRING COMMENT 'The regulatory delegation scope granted to this employee for this specific clinical program. Delegation authority is program-specific and role-specific — the same employee may have different delegation levels across different programs.',
    `end_date` DATE COMMENT 'The date on which the employees assignment to this clinical program team concluded. Null if the assignment is currently active. Required for historical team composition queries and regulatory audit trails.',
    `fte_allocation_percentage` DECIMAL(18,2) COMMENT 'The proportion of the employees full-time equivalent capacity dedicated to this specific clinical program assignment. Enables workforce capacity planning and cost allocation across the program portfolio.',
    `gcp_certification_status` STRING COMMENT 'The GCP certification validity status of the employee at the time of and during this program assignment. Captured per assignment because certification status may change during a long-running program and regulatory submissions require point-in-time',
    `program_role` STRING COMMENT 'The GCP-defined functional role of the employee within this specific clinical program assignment. Distinct from the employees general gcp_role — an employee may serve in different roles across different programs.',
    `start_date` DATE COMMENT 'The date on which the employees assignment to this clinical program team became effective. Used for delegation log compliance, regulatory inspection readiness, and workforce timeline reporting.',
    `therapeutic_area_expertise` STRING COMMENT 'The specific therapeutic area expertise the employee is applying in the context of this program assignment. May differ from the employees general therapeutic_area_expertise when an employee is cross-assigned to a program outside their primary TA.',
    CONSTRAINT pk_program_team_member PRIMARY KEY(`program_team_member_id`)
) COMMENT 'This association product represents the Role-based assignment between an employee and a clinical_program. It captures the operational team membership record that the CRO actively manages for each employee-program pairing, including the employees';

CREATE OR REPLACE TABLE `clinical_trials_ecm`.`workforce`.`training_course` (
    `training_course_id` BIGINT COMMENT 'Primary key for training_course',
    `prerequisite_training_course_id` BIGINT COMMENT 'Self-referencing FK on training_course (prerequisite_training_course_id)',
    `study_id` BIGINT COMMENT 'Foreign key to the study this record belongs to.',
    `training_curriculum_id` BIGINT COMMENT 'add column training_curriculum_id (BIGINT) with FK to workforce.training_curriculum.training_curriculum_id — courses belong to curricula',
    `accreditation_body` STRING COMMENT 'External organization that accredits or certifies this training course (e.g., TransCelerate, ACRP, SoCRA, BARQA).',
    `accreditation_number` STRING COMMENT 'Official accreditation or approval reference number assigned by the accrediting body for this course.',
    `applicable_region` STRING COMMENT 'Geographic region or jurisdiction for which this training is applicable or required (e.g., USA, EU, JPN, global). Supports multi-region compliance tracking.',
    `approval_date` DATE COMMENT 'Date on which the current version of the training course received formal approval for deployment.',
    `approved_by` STRING COMMENT 'Name or identifier of the quality assurance or compliance officer who approved the current version of this training course for use.',
    `assessment_required_flag` BOOLEAN COMMENT 'Indicates whether a formal assessment or examination is required for course completion, as opposed to attendance-only completion.',
    `available_languages` STRING COMMENT 'Comma-separated list of ISO 639-1 language codes for all available translations of this training course.',
    `competency_level` STRING COMMENT 'The proficiency level that the course is designed to develop, used for career development pathways and role qualification matrices.',
    `content_owner_department` STRING COMMENT 'The internal department or functional group responsible for maintaining and updating the course content (e.g., Quality Assurance, Clinical Operations, Regulatory Affairs).',
    `cost_per_participant` DECIMAL(10,2) COMMENT 'Standard cost per participant for the training course, used for budgeting and resource allocation planning.',
    `course_code` STRING COMMENT 'Externally-known unique alphanumeric code used to identify the training course across systems, catalogs, and regulatory submissions.',
    `course_type` STRING COMMENT 'Classification of the training course by subject matter category. Distinguishes Good Clinical Practice (GCP) training from Standard Operating Procedure (SOP), regulatory, therapeutic area, technical skills, and safety training.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this training course record was first created in the system.',
    `credit_units` DECIMAL(5,2) COMMENT 'Number of continuing education (CE) or continuing professional development (CPD) credit units awarded upon successful completion.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the cost_per_participant amount.',
    `delegation_log_relevance_flag` BOOLEAN COMMENT 'Indicates whether completion of this course is a prerequisite for being listed on a study delegation log per GCP requirements.',
    `delivery_method` STRING COMMENT 'The modality through which the training course is delivered to participants.',
    `training_course_description` STRING COMMENT 'Detailed narrative description of the course content, learning objectives, and scope.',
    `duration_hours` DECIMAL(5,2) COMMENT 'Total estimated duration of the training course measured in hours, used for capacity planning and compliance tracking.',
    `effective_date` DATE COMMENT 'Date from which this version of the training course becomes effective and available for enrollment.',
    `gcp_compliance_flag` BOOLEAN COMMENT 'Indicates whether this course satisfies Good Clinical Practice (GCP) training requirements per ICH E6(R2) guidelines.',
    `language` STRING COMMENT 'ISO 639-1 language code (with optional ISO 3166-1 region) indicating the primary language in which the course is delivered.',
    `last_review_date` DATE COMMENT 'Date when the course content was last reviewed for accuracy, regulatory alignment, and relevance by the content owner.',
    `lms_course_code` STRING COMMENT 'Unique identifier for this course within the organizations Learning Management System (LMS), enabling system integration and completion tracking.',
    `max_enrollment_capacity` BIGINT COMMENT 'Maximum number of participants allowed per session for instructor-led or blended courses. Null for self-paced e-learning.',
    `next_review_date` DATE COMMENT 'Scheduled date for the next periodic content review to ensure ongoing regulatory compliance and content accuracy.',
    `passing_score_percent` DECIMAL(5,2) COMMENT 'Minimum assessment score percentage required to successfully complete the course and receive certification credit.',
    `prerequisite_course_ids` STRING COMMENT 'Comma-separated list of training_course_id values that must be completed before enrolling in this course. Null if no prerequisites exist.',
    `recertification_interval_months` BIGINT COMMENT 'Number of months after which the training certification expires and recertification is required. Null if no recertification is needed.',
    `regulatory_requirement_flag` BOOLEAN COMMENT 'Indicates whether this training course is mandated by a regulatory authority (e.g., FDA, EMA, ICH) as a prerequisite for clinical trial participation.',
    `retirement_date` DATE COMMENT 'Date on which this training course version is retired and no longer available for new enrollments. Null if currently active.',
    `training_course_status` STRING COMMENT 'Current lifecycle state of the training course indicating whether it is available for enrollment, under development, or no longer offered.',
    `target_audience` STRING COMMENT 'Primary workforce role for which this training course is designed. Clinical Research Associates (CRA), Clinical Research Coordinators (CRC), biostatisticians, data managers, medical monitors, or regulatory specialists.',
    `therapeutic_area` STRING COMMENT 'The therapeutic area or disease domain to which the training course content is specific (e.g., oncology, cardiology, neurology). Null if the course is general/cross-therapeutic.',
    `title` STRING COMMENT 'Human-readable title of the training course as displayed in the learning management system and training records.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this training course record was last modified.',
    `vendor_name` STRING COMMENT 'Name of the external training vendor or provider if the course is sourced externally rather than developed in-house.',
    `version_number` STRING COMMENT 'Version identifier for the course content, incremented when material is updated to reflect regulatory changes or content improvements.',
    CONSTRAINT pk_training_course PRIMARY KEY(`training_course_id`)
) COMMENT 'Master reference table for training_course. Referenced by training_course_id.';

ALTER SCHEMA `clinical_trials_ecm`.`workforce` SET TAGS ('dbx_division' = 'corporate');

ALTER SCHEMA `clinical_trials_ecm`.`workforce` SET TAGS ('dbx_domain' = 'workforce');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ADD CONSTRAINT `fk_workforce_employee_job_profile_id` FOREIGN KEY (`job_profile_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`job_profile`(`job_profile_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ADD CONSTRAINT `fk_workforce_employee_manager_employee_id` FOREIGN KEY (`manager_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` SET TAGS ('dbx_domain' = 'workforce');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` SET TAGS ('dbx_subdomain' = 'personnel_management');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `job_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Job Profile Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `manager_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Reporting Manager Employee ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `manager_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `manager_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `manager_employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `manager_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `billing_rate_usd` SET TAGS ('dbx_business_glossary_term' = 'Billing Rate (USD)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `billing_rate_usd` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `cdisc_certified` SET TAGS ('dbx_business_glossary_term' = 'Clinical Data Interchange Standards Consortium (CDISC) Certified Flag');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `ctms_user_code` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) User ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `ctms_user_code` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `ctms_user_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `ctms_user_code` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `ctms_user_code` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `department_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `edc_user_code` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) User ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `edc_user_code` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `edc_user_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `edc_user_code` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `edc_user_code` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `employment_status` SET TAGS ('dbx_value_regex' = 'active|on_leave|terminated|suspended|pending_start');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `employment_type` SET TAGS ('dbx_value_regex' = 'full_time|part_time|contractor|consultant|intern');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `etmf_user_code` SET TAGS ('dbx_business_glossary_term' = 'Electronic Trial Master File (eTMF) User ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `etmf_user_code` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `etmf_user_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `etmf_user_code` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `etmf_user_code` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `first_name` SET TAGS ('dbx_business_glossary_term' = 'Employee First Name');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `first_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `first_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `first_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `fte_percentage` SET TAGS ('dbx_business_glossary_term' = 'Full-Time Equivalent (FTE) Percentage');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `fte_percentage` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `gcp_certification_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Certification Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `gcp_certified` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Certified Flag');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `gcp_role` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Role Designation');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `highest_education_level` SET TAGS ('dbx_value_regex' = 'high_school|associate|bachelor|master|doctorate|professional_degree');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `is_key_personnel` SET TAGS ('dbx_business_glossary_term' = 'Key Personnel Flag');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `is_key_personnel` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `last_name` SET TAGS ('dbx_business_glossary_term' = 'Employee Last Name');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `last_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `last_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `last_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `nationality_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `nationality_country_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `nationality_country_code` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `nationality_country_code` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `nationality_country_code` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `pay_grade` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `preferred_name` SET TAGS ('dbx_business_glossary_term' = 'Employee Preferred Name');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `preferred_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `preferred_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `preferred_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `professional_license_country` SET TAGS ('dbx_business_glossary_term' = 'Professional License Country Code');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `professional_license_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `professional_license_number` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `professional_license_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `professional_license_number` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `professional_license_number` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `region_assignment` SET TAGS ('dbx_business_glossary_term' = 'Regional Assignment');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `termination_reason` SET TAGS ('dbx_value_regex' = 'voluntary_resignation|involuntary_termination|contract_end|retirement|transfer|redundancy');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `time_zone` SET TAGS ('dbx_business_glossary_term' = 'Work Time Zone');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `work_authorization_status` SET TAGS ('dbx_value_regex' = 'authorized|visa_required|pending_authorization|expired');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `work_authorization_status` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `work_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `work_email` SET TAGS ('dbx_business_glossary_term' = 'Employee Work Email Address');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `work_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `work_email` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `work_email` SET TAGS ('dbx_pii_email' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `work_email` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `work_phone` SET TAGS ('dbx_business_glossary_term' = 'Employee Work Phone Number');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `work_phone` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `work_phone` SET TAGS ('dbx_pii_phone' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `work_phone` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `workday_worker_code` SET TAGS ('dbx_business_glossary_term' = 'Workday Worker ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `workday_worker_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `workday_worker_code` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `workday_worker_code` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`employee` ALTER COLUMN `years_of_experience` SET TAGS ('dbx_business_glossary_term' = 'Years of Clinical Research Experience');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ADD CONSTRAINT `fk_workforce_job_profile_org_unit_id` FOREIGN KEY (`org_unit_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`org_unit`(`org_unit_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` SET TAGS ('dbx_domain' = 'workforce');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` SET TAGS ('dbx_subdomain' = 'personnel_management');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `billing_rate_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `billing_rate_unit` SET TAGS ('dbx_value_regex' = 'hourly|daily|monthly');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `cdisc_role_alignment` SET TAGS ('dbx_business_glossary_term' = 'Clinical Data Interchange Standards Consortium (CDISC) Role Alignment');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `ctms_access_level` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Access Level');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `ctms_access_level` SET TAGS ('dbx_value_regex' = 'none|read_only|standard|power_user|admin');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `delegation_eligible` SET TAGS ('dbx_business_glossary_term' = 'Delegation Log Eligible');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `edc_access_level` SET TAGS ('dbx_business_glossary_term' = 'Electronic Data Capture (EDC) Access Level');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `edc_access_level` SET TAGS ('dbx_value_regex' = 'none|read_only|data_entry|query_management|admin');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `employment_type` SET TAGS ('dbx_value_regex' = 'full_time|part_time|contract|temporary');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `exempt_status` SET TAGS ('dbx_business_glossary_term' = 'FLSA Exempt Status');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `exempt_status` SET TAGS ('dbx_value_regex' = 'exempt|non_exempt');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `gcp_role_category` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Role Category');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `gcp_training_frequency_months` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Training Frequency (Months)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `gcp_training_required` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Training Required');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `job_category` SET TAGS ('dbx_value_regex' = 'individual_contributor|manager|director|executive');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `job_level` SET TAGS ('dbx_value_regex' = 'Associate|Senior|Principal|Director|Executive');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `management_level` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `profile_code` SET TAGS ('dbx_business_glossary_term' = 'Job Profile Code');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `profile_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{3,20}$');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `profile_name` SET TAGS ('dbx_business_glossary_term' = 'Job Profile Name');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `profile_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `profile_owner` SET TAGS ('dbx_business_glossary_term' = 'Job Profile Owner');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `profile_status` SET TAGS ('dbx_business_glossary_term' = 'Job Profile Status');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `profile_status` SET TAGS ('dbx_value_regex' = 'active|inactive|draft|archived');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `remote_eligible` SET TAGS ('dbx_business_glossary_term' = 'Remote Work Eligible');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `required_education_level` SET TAGS ('dbx_value_regex' = 'high_school|associate|bachelor|master|doctorate|professional');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `required_years_experience` SET TAGS ('dbx_business_glossary_term' = 'Required Years of Experience');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `salary_band_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{1,3}[0-9]{1,3}$');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `salary_band_code` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `salary_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `salary_currency_code` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `salary_currency_code` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `salary_range_max` SET TAGS ('dbx_business_glossary_term' = 'Salary Range Maximum');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `salary_range_max` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `salary_range_min` SET TAGS ('dbx_business_glossary_term' = 'Salary Range Minimum');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `salary_range_min` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `sop_training_curriculum` SET TAGS ('dbx_business_glossary_term' = 'Standard Operating Procedure (SOP) Training Curriculum');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `standard_billing_rate` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `travel_requirement` SET TAGS ('dbx_value_regex' = 'none|occasional|frequent|extensive');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `work_shift` SET TAGS ('dbx_value_regex' = 'standard|rotating|on_call|flexible');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`job_profile` ALTER COLUMN `workday_job_profile_code` SET TAGS ('dbx_business_glossary_term' = 'Workday Job Profile ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ADD CONSTRAINT `fk_workforce_gcp_training_record_electronic_signature_id` FOREIGN KEY (`electronic_signature_id`) REFERENCES `clinical_trials_ecm`.`document`.`signature`(`signature_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ADD CONSTRAINT `fk_workforce_gcp_training_record_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ADD CONSTRAINT `fk_workforce_gcp_training_record_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ADD CONSTRAINT `fk_workforce_gcp_training_record_study_assignment_id` FOREIGN KEY (`study_assignment_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`study_assignment`(`study_assignment_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ADD CONSTRAINT `fk_workforce_gcp_training_record_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ADD CONSTRAINT `fk_workforce_gcp_training_record_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ADD CONSTRAINT `fk_workforce_gcp_training_record_training_course_id` FOREIGN KEY (`training_course_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`training_course`(`training_course_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ADD CONSTRAINT `fk_workforce_gcp_training_record_training_curriculum_id` FOREIGN KEY (`training_curriculum_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`training_curriculum`(`training_curriculum_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` SET TAGS ('dbx_domain' = 'workforce');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` SET TAGS ('dbx_subdomain' = 'learning_development');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `gcp_training_record_id` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Training Record ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `electronic_signature_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `study_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Study Assignment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Training Certificate Document ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `training_curriculum_id` SET TAGS ('dbx_business_glossary_term' = 'Training Curriculum Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `assessment_score` SET TAGS ('dbx_business_glossary_term' = 'Training Assessment Score');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `assigned_date` SET TAGS ('dbx_business_glossary_term' = 'Training Assignment Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `certificate_issued_date` SET TAGS ('dbx_business_glossary_term' = 'Training Certificate Issued Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `certificate_number` SET TAGS ('dbx_business_glossary_term' = 'Training Certificate Reference Number');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Training Record Comments');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `completion_date` SET TAGS ('dbx_business_glossary_term' = 'Training Completion Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `course_code` SET TAGS ('dbx_business_glossary_term' = 'Training Course Code');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `course_name` SET TAGS ('dbx_business_glossary_term' = 'Training Course Name');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `course_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Training Due Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'GCP Training Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `gcp_guideline_version` SET TAGS ('dbx_business_glossary_term' = 'ICH Good Clinical Practice (GCP) Guideline Version');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `gcp_guideline_version` SET TAGS ('dbx_value_regex' = 'ICH E6(R1)|ICH E6(R2)|ICH E6(R3)|21 CFR Part 312|ISO 14155');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `is_curriculum_required` SET TAGS ('dbx_business_glossary_term' = 'Curriculum Required Flag');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `is_gcp_current` SET TAGS ('dbx_business_glossary_term' = 'GCP Training Currency Flag');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `last_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `mastercontrol_record_code` SET TAGS ('dbx_business_glossary_term' = 'MasterControl Training Record ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `max_attempts_allowed` SET TAGS ('dbx_business_glossary_term' = 'Maximum Assessment Attempts Allowed');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `number_of_attempts` SET TAGS ('dbx_business_glossary_term' = 'Number of Assessment Attempts');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `pass_fail_status` SET TAGS ('dbx_business_glossary_term' = 'Training Assessment Pass/Fail Status');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `pass_fail_status` SET TAGS ('dbx_value_regex' = 'pass|fail|not_applicable');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `passing_score_threshold` SET TAGS ('dbx_business_glossary_term' = 'Minimum Passing Score Threshold');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `regulatory_submission_flag` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Submission Inclusion Flag');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `role_at_training` SET TAGS ('dbx_business_glossary_term' = 'Workforce Role at Time of Training');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `signature_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Electronic Signature Timestamp');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `signature_timestamp` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `tmf_filing_reference` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Filing Reference');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `trainer_name` SET TAGS ('dbx_business_glossary_term' = 'Trainer / Instructor Name');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `trainer_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `trainer_qualification` SET TAGS ('dbx_business_glossary_term' = 'Trainer Qualification / Credentials');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `training_delivery_method` SET TAGS ('dbx_value_regex' = 'e_learning|classroom|webinar|on_the_job|blended');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `training_duration_hours` SET TAGS ('dbx_business_glossary_term' = 'Training Duration (Hours)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `training_provider` SET TAGS ('dbx_business_glossary_term' = 'Training Provider Name');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `training_provider_type` SET TAGS ('dbx_value_regex' = 'internal|external|sponsor|regulatory_body');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `training_status` SET TAGS ('dbx_business_glossary_term' = 'GCP Training Status');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `training_status` SET TAGS ('dbx_value_regex' = 'completed|in_progress|overdue|waived|cancelled');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `training_type` SET TAGS ('dbx_business_glossary_term' = 'GCP Training Type');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `training_type` SET TAGS ('dbx_value_regex' = 'initial|refresher|protocol_specific|role_specific|remedial');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `waiver_approved_by` SET TAGS ('dbx_business_glossary_term' = 'Training Waiver Approved By');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `waiver_date` SET TAGS ('dbx_business_glossary_term' = 'Training Waiver Approval Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`gcp_training_record` ALTER COLUMN `waiver_reason` SET TAGS ('dbx_business_glossary_term' = 'Training Waiver Reason');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ADD CONSTRAINT `fk_workforce_certification_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ADD CONSTRAINT `fk_workforce_certification_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` SET TAGS ('dbx_domain' = 'workforce');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` SET TAGS ('dbx_subdomain' = 'personnel_management');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Worker ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `ce_credits_earned` SET TAGS ('dbx_business_glossary_term' = 'Continuing Education (CE) Credits Earned');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `ce_credits_required` SET TAGS ('dbx_business_glossary_term' = 'Continuing Education (CE) Credits Required');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `ce_cycle_end_date` SET TAGS ('dbx_business_glossary_term' = 'Continuing Education (CE) Cycle End Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `ce_cycle_start_date` SET TAGS ('dbx_business_glossary_term' = 'Continuing Education (CE) Cycle Start Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `cost_amount` SET TAGS ('dbx_business_glossary_term' = 'Certification Cost Amount');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `cost_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `cost_currency` SET TAGS ('dbx_business_glossary_term' = 'Certification Cost Currency');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `cost_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `credential_scope` SET TAGS ('dbx_value_regex' = 'global|regional|national|institutional');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `document_reference` SET TAGS ('dbx_business_glossary_term' = 'Certification Document Reference');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `exam_date` SET TAGS ('dbx_business_glossary_term' = 'Certification Exam Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `exam_location` SET TAGS ('dbx_business_glossary_term' = 'Certification Exam Location');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `exam_score` SET TAGS ('dbx_business_glossary_term' = 'Certification Exam Score');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Certification Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `is_gcp_required` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Required Flag');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `is_regulatory_required` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Required Flag');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `issue_date` SET TAGS ('dbx_business_glossary_term' = 'Certification Issue Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `issuing_body_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `certification_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Certification Notes');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `number` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `number` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `number` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `passing_score` SET TAGS ('dbx_business_glossary_term' = 'Certification Passing Score');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `reimbursement_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `reimbursement_eligible` SET TAGS ('dbx_business_glossary_term' = 'Reimbursement Eligible Flag');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `renewal_date` SET TAGS ('dbx_business_glossary_term' = 'Certification Renewal Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `renewal_reminder_days` SET TAGS ('dbx_business_glossary_term' = 'Renewal Reminder Lead Days');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `renewal_status` SET TAGS ('dbx_business_glossary_term' = 'Certification Renewal Status');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `renewal_status` SET TAGS ('dbx_value_regex' = 'not_due|in_progress|submitted|renewed|lapsed');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `source_system_record_code` SET TAGS ('dbx_business_glossary_term' = 'Source System Record ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `sponsor_required` SET TAGS ('dbx_business_glossary_term' = 'Sponsor Required Flag');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `certification_status` SET TAGS ('dbx_value_regex' = 'active|expired|suspended|revoked|pending');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `verification_date` SET TAGS ('dbx_business_glossary_term' = 'Certification Verification Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `verification_status` SET TAGS ('dbx_business_glossary_term' = 'Certification Verification Status');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`certification` ALTER COLUMN `verification_status` SET TAGS ('dbx_value_regex' = 'unverified|verified|failed_verification|pending_verification');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ADD CONSTRAINT `fk_workforce_study_assignment_cost_center_id` FOREIGN KEY (`cost_center_id`) REFERENCES `clinical_trials_ecm`.`finance`.`cost_center`(`cost_center_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ADD CONSTRAINT `fk_workforce_study_assignment_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ADD CONSTRAINT `fk_workforce_study_assignment_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ADD CONSTRAINT `fk_workforce_study_assignment_primary_study_employee_id` FOREIGN KEY (`primary_study_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ADD CONSTRAINT `fk_workforce_study_assignment_study_budget_id` FOREIGN KEY (`study_budget_id`) REFERENCES `clinical_trials_ecm`.`finance`.`study_budget`(`study_budget_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ADD CONSTRAINT `fk_workforce_study_assignment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ADD CONSTRAINT `fk_workforce_study_assignment_workforce_delegation_log_id` FOREIGN KEY (`workforce_delegation_log_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`workforce_delegation_log`(`workforce_delegation_log_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` SET TAGS ('dbx_domain' = 'workforce');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` SET TAGS ('dbx_subdomain' = 'resource_allocation');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Primary Site ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Sponsor ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `primary_study_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Employee ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `primary_study_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `primary_study_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `primary_study_employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `primary_study_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `study_budget_id` SET TAGS ('dbx_business_glossary_term' = 'Study Budget Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `workforce_delegation_log_id` SET TAGS ('dbx_business_glossary_term' = 'Delegation Log Entry ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `approved_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Assignment Approved Timestamp');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `assignment_number` SET TAGS ('dbx_business_glossary_term' = 'Study Assignment Number');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `assignment_number` SET TAGS ('dbx_value_regex' = '^SA-[0-9]{4}-[0-9]{6}$');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `assignment_status` SET TAGS ('dbx_value_regex' = 'active|on-hold|completed|cancelled|pending');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `assignment_type` SET TAGS ('dbx_value_regex' = 'primary|backup|ad-hoc|interim|consultant');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `billing_rate` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `billing_rate_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `billing_rate_unit` SET TAGS ('dbx_value_regex' = 'hourly|daily|monthly|fixed');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `completion_reason` SET TAGS ('dbx_value_regex' = 'study-closeout|role-change|resignation|reassignment|contract-end|other');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `ctms_assignment_code` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Assignment ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `effective_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Assignment Effective Timestamp');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `employment_type` SET TAGS ('dbx_value_regex' = 'full-time|part-time|contractor|consultant|secondment');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `end_date` SET TAGS ('dbx_business_glossary_term' = 'Assignment End Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `fte_allocation_pct` SET TAGS ('dbx_business_glossary_term' = 'Full-Time Equivalent (FTE) Allocation Percentage');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `gcp_certification_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Certification Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `gcp_certified` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Certified');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `is_pi_oversight_required` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Oversight Required');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Assignment Notes');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `on_hold_date` SET TAGS ('dbx_business_glossary_term' = 'On-Hold Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `on_hold_reason` SET TAGS ('dbx_business_glossary_term' = 'On-Hold Reason');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `phase` SET TAGS ('dbx_business_glossary_term' = 'Study Phase');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `phase` SET TAGS ('dbx_value_regex' = 'Phase I|Phase II|Phase III|Phase IV|Phase I/II');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `planned_fte_allocation_pct` SET TAGS ('dbx_business_glossary_term' = 'Planned Full-Time Equivalent (FTE) Allocation Percentage');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `start_date` SET TAGS ('dbx_business_glossary_term' = 'Assignment Start Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `training_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Study-Specific Training Completion Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`study_assignment` ALTER COLUMN `workday_assignment_code` SET TAGS ('dbx_business_glossary_term' = 'Workday HCM Assignment ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ADD CONSTRAINT `fk_workforce_workforce_delegation_log_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ADD CONSTRAINT `fk_workforce_workforce_delegation_log_primary_workforce_pi_employee_id` FOREIGN KEY (`primary_workforce_pi_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ADD CONSTRAINT `fk_workforce_workforce_delegation_log_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ADD CONSTRAINT `fk_workforce_workforce_delegation_log_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ADD CONSTRAINT `fk_workforce_workforce_delegation_log_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ADD CONSTRAINT `fk_workforce_workforce_delegation_log_superseded_log_workforce_delegation_log_id` FOREIGN KEY (`superseded_log_workforce_delegation_log_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`workforce_delegation_log`(`workforce_delegation_log_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ADD CONSTRAINT `fk_workforce_workforce_delegation_log_tertiary_workforce_qa_reviewer_employee_id` FOREIGN KEY (`tertiary_workforce_qa_reviewer_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ADD CONSTRAINT `fk_workforce_workforce_delegation_log_tmf_artifact_id` FOREIGN KEY (`tmf_artifact_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_artifact`(`tmf_artifact_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` SET TAGS ('dbx_domain' = 'workforce');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` SET TAGS ('dbx_subdomain' = 'resource_allocation');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `primary_workforce_pi_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Employee ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `primary_workforce_pi_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `primary_workforce_pi_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `primary_workforce_pi_employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `primary_workforce_pi_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `study_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `superseded_log_workforce_delegation_log_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded Delegation Log ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `tertiary_workforce_qa_reviewer_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Quality Assurance (QA) Reviewer Employee ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `tertiary_workforce_qa_reviewer_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `tertiary_workforce_qa_reviewer_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `tertiary_workforce_qa_reviewer_employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `tertiary_workforce_qa_reviewer_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `tmf_artifact_id` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Artifact ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Delegation Log Comments');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `ctms_delegation_ref` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Delegation Reference');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `delegatee_name` SET TAGS ('dbx_business_glossary_term' = 'Delegatee Full Name');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `delegatee_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `delegatee_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `delegatee_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `delegatee_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `delegatee_qualification_confirmed` SET TAGS ('dbx_business_glossary_term' = 'Delegatee Qualification Confirmed Flag');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `delegatee_signature_captured` SET TAGS ('dbx_business_glossary_term' = 'Delegatee Signature Captured Flag');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `delegatee_signature_captured` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `delegatee_signature_date` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `delegation_scope` SET TAGS ('dbx_value_regex' = 'full|partial|temporary|emergency');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `gcp_guideline_version` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Guideline Version');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `gcp_training_verified` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Training Verified Flag');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `inspection_ready` SET TAGS ('dbx_business_glossary_term' = 'Inspection Ready Flag');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `irb_iec_approval_confirmed` SET TAGS ('dbx_business_glossary_term' = 'Institutional Review Board (IRB) / Independent Ethics Committee (IEC) Approval Confirmed Flag');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `log_status` SET TAGS ('dbx_business_glossary_term' = 'Delegation Log Status');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `log_status` SET TAGS ('dbx_value_regex' = 'draft|active|superseded|withdrawn|archived');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `log_version` SET TAGS ('dbx_business_glossary_term' = 'Delegation Log Version');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `log_version` SET TAGS ('dbx_value_regex' = '^vd+(.d+)?$');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `pi_name` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Name');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `pi_name` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `pi_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `pi_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `pi_name` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `pi_signature_captured` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Signature Captured Flag');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `pi_signature_captured` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `pi_signature_date` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Signature Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `pi_signature_date` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `protocol_training_verified` SET TAGS ('dbx_business_glossary_term' = 'Protocol Training Verified Flag');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `qa_review_date` SET TAGS ('dbx_business_glossary_term' = 'Quality Assurance (QA) Review Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `qa_review_status` SET TAGS ('dbx_business_glossary_term' = 'Quality Assurance (QA) Review Status');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `qa_review_status` SET TAGS ('dbx_value_regex' = 'pending|in_review|approved|rejected|not_required');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `workday_worker_code` SET TAGS ('dbx_business_glossary_term' = 'Workday Worker ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `workday_worker_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `workday_worker_code` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_delegation_log` ALTER COLUMN `workday_worker_code` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ADD CONSTRAINT `fk_workforce_workforce_resource_plan_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ADD CONSTRAINT `fk_workforce_workforce_resource_plan_cost_center_id` FOREIGN KEY (`cost_center_id`) REFERENCES `clinical_trials_ecm`.`finance`.`cost_center`(`cost_center_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ADD CONSTRAINT `fk_workforce_workforce_resource_plan_job_profile_id` FOREIGN KEY (`job_profile_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`job_profile`(`job_profile_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ADD CONSTRAINT `fk_workforce_workforce_resource_plan_org_unit_id` FOREIGN KEY (`org_unit_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`org_unit`(`org_unit_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ADD CONSTRAINT `fk_workforce_workforce_resource_plan_primary_workforce_employee_id` FOREIGN KEY (`primary_workforce_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ADD CONSTRAINT `fk_workforce_workforce_resource_plan_program_strategic_plan_id` FOREIGN KEY (`program_strategic_plan_id`) REFERENCES `clinical_trials_ecm`.`program`.`program_strategic_plan`(`program_strategic_plan_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ADD CONSTRAINT `fk_workforce_workforce_resource_plan_scope_of_work_id` FOREIGN KEY (`scope_of_work_id`) REFERENCES `clinical_trials_ecm`.`agreement`.`scope_of_work`(`scope_of_work_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ADD CONSTRAINT `fk_workforce_workforce_resource_plan_study_budget_id` FOREIGN KEY (`study_budget_id`) REFERENCES `clinical_trials_ecm`.`finance`.`study_budget`(`study_budget_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ADD CONSTRAINT `fk_workforce_workforce_resource_plan_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ADD CONSTRAINT `fk_workforce_workforce_resource_plan_timeline_id` FOREIGN KEY (`timeline_id`) REFERENCES `clinical_trials_ecm`.`program`.`timeline`(`timeline_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` SET TAGS ('dbx_domain' = 'workforce');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` SET TAGS ('dbx_subdomain' = 'resource_allocation');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Program ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `cost_center_id` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `job_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Job Profile Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `org_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Organizational Unit ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `primary_workforce_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Owning Resource Manager ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `primary_workforce_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `primary_workforce_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `primary_workforce_employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `primary_workforce_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `program_strategic_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Program Plan Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `scope_of_work_id` SET TAGS ('dbx_business_glossary_term' = 'Scope Of Work Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `study_budget_id` SET TAGS ('dbx_business_glossary_term' = 'Study Budget Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `timeline_id` SET TAGS ('dbx_business_glossary_term' = 'Program Timeline Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `actual_fte` SET TAGS ('dbx_business_glossary_term' = 'Actual Full-Time Equivalent (FTE)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `actual_labor_cost` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Plan Approval Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `budget_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `capacity_utilization_target_pct` SET TAGS ('dbx_business_glossary_term' = 'Capacity Utilization Target Percentage');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `capacity_utilization_target_pct` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `contractor_fte_planned` SET TAGS ('dbx_business_glossary_term' = 'Planned Contractor Full-Time Equivalent (FTE)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `fiscal_quarter` SET TAGS ('dbx_value_regex' = 'Q1|Q2|Q3|Q4');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `fte_gap` SET TAGS ('dbx_business_glossary_term' = 'Full-Time Equivalent (FTE) Gap');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `gcp_certification_required` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Certification Required');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `hiring_urgency` SET TAGS ('dbx_value_regex' = 'critical|high|medium|low');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `internal_fte_planned` SET TAGS ('dbx_business_glossary_term' = 'Planned Internal Full-Time Equivalent (FTE)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `plan_code` SET TAGS ('dbx_business_glossary_term' = 'Workforce Resource Plan Code');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `plan_code` SET TAGS ('dbx_value_regex' = '^WRP-[A-Z0-9]{4,20}$');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `plan_name` SET TAGS ('dbx_business_glossary_term' = 'Workforce Resource Plan Name');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `plan_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `plan_status` SET TAGS ('dbx_business_glossary_term' = 'Workforce Resource Plan Status');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `plan_type` SET TAGS ('dbx_business_glossary_term' = 'Workforce Resource Plan Type');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `plan_type` SET TAGS ('dbx_value_regex' = 'study|program|organizational_unit|functional_area');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `plan_version` SET TAGS ('dbx_business_glossary_term' = 'Workforce Resource Plan Version');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `planned_fte_demand` SET TAGS ('dbx_business_glossary_term' = 'Planned Full-Time Equivalent (FTE) Demand');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `planned_labor_cost` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `planning_horizon` SET TAGS ('dbx_value_regex' = 'study_phase|quarterly|annual|multi_year');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `required_language` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `study_phase` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study Phase');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `study_phase` SET TAGS ('dbx_value_regex' = 'Phase_I|Phase_II|Phase_III|Phase_IV|pre_clinical|post_marketing');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_resource_plan` ALTER COLUMN `workday_plan_code` SET TAGS ('dbx_business_glossary_term' = 'Workday HCM Workforce Plan ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ADD CONSTRAINT `fk_workforce_training_record_compliance_capa_id` FOREIGN KEY (`compliance_capa_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_capa`(`compliance_capa_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ADD CONSTRAINT `fk_workforce_training_record_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ADD CONSTRAINT `fk_workforce_training_record_electronic_signature_id` FOREIGN KEY (`electronic_signature_id`) REFERENCES `clinical_trials_ecm`.`document`.`signature`(`signature_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ADD CONSTRAINT `fk_workforce_training_record_primary_training_employee_id` FOREIGN KEY (`primary_training_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ADD CONSTRAINT `fk_workforce_training_record_protocol_deviation_id` FOREIGN KEY (`protocol_deviation_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`protocol_deviation`(`protocol_deviation_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ADD CONSTRAINT `fk_workforce_training_record_study_assignment_id` FOREIGN KEY (`study_assignment_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`study_assignment`(`study_assignment_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ADD CONSTRAINT `fk_workforce_training_record_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ADD CONSTRAINT `fk_workforce_training_record_tertiary_training_assigned_by_employee_id` FOREIGN KEY (`tertiary_training_assigned_by_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ADD CONSTRAINT `fk_workforce_training_record_training_course_id` FOREIGN KEY (`training_course_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`training_course`(`training_course_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ADD CONSTRAINT `fk_workforce_training_record_training_curriculum_id` FOREIGN KEY (`training_curriculum_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`training_curriculum`(`training_curriculum_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` SET TAGS ('dbx_domain' = 'workforce');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` SET TAGS ('dbx_subdomain' = 'learning_development');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `training_record_id` SET TAGS ('dbx_business_glossary_term' = 'Training Record Identifier');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `compliance_capa_id` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `electronic_signature_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `primary_training_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Employee ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `primary_training_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `primary_training_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `primary_training_employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `primary_training_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `study_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Study Assignment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `tertiary_training_assigned_by_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Assigned By Employee ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `tertiary_training_assigned_by_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `tertiary_training_assigned_by_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `tertiary_training_assigned_by_employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `tertiary_training_assigned_by_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `training_course_id` SET TAGS ('dbx_business_glossary_term' = 'Training Course Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `assessment_required` SET TAGS ('dbx_business_glossary_term' = 'Assessment Required Flag');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `assignment_date` SET TAGS ('dbx_business_glossary_term' = 'Training Assignment Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `assignment_number` SET TAGS ('dbx_business_glossary_term' = 'Training Assignment Number');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `assignment_number` SET TAGS ('dbx_value_regex' = '^TRN-[0-9]{4}-[0-9]{6}$');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `assignment_status` SET TAGS ('dbx_business_glossary_term' = 'Training Assignment Status');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `assignment_status` SET TAGS ('dbx_value_regex' = 'assigned|in_progress|completed|overdue|waived|cancelled');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `attempt_number` SET TAGS ('dbx_business_glossary_term' = 'Assessment Attempt Number');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `comments` SET TAGS ('dbx_business_glossary_term' = 'Training Assignment Comments');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `completion_date` SET TAGS ('dbx_business_glossary_term' = 'Training Completion Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `completion_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Training Completion Timestamp');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `department` SET TAGS ('dbx_business_glossary_term' = 'Employee Department at Assignment');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Training Due Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `job_role` SET TAGS ('dbx_business_glossary_term' = 'Employee Job Role at Assignment');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `mastercontrol_training_code` SET TAGS ('dbx_business_glossary_term' = 'MasterControl Training Record ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `max_attempts_allowed` SET TAGS ('dbx_business_glossary_term' = 'Maximum Assessment Attempts Allowed');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `pass_fail_status` SET TAGS ('dbx_business_glossary_term' = 'Training Pass/Fail Status');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `pass_fail_status` SET TAGS ('dbx_value_regex' = 'pass|fail|not_assessed|pending');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `recurrence_interval_days` SET TAGS ('dbx_business_glossary_term' = 'Recurrence Interval (Days)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `recurrence_required` SET TAGS ('dbx_business_glossary_term' = 'Recurrence Required Flag');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `signed_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Electronic Signature Timestamp');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `sop_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Standard Operating Procedure (SOP) Effective Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `sop_version` SET TAGS ('dbx_business_glossary_term' = 'Standard Operating Procedure (SOP) Version');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `sop_version` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `training_category` SET TAGS ('dbx_value_regex' = 'initial|retraining|periodic|change_driven|role_based');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `training_method` SET TAGS ('dbx_value_regex' = 'read_and_understand|instructor_led|e_learning|on_the_job|blended');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `waiver_approved_by` SET TAGS ('dbx_business_glossary_term' = 'Training Waiver Approved By');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `waiver_date` SET TAGS ('dbx_business_glossary_term' = 'Training Waiver Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_record` ALTER COLUMN `waiver_reason` SET TAGS ('dbx_business_glossary_term' = 'Training Waiver Reason');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ADD CONSTRAINT `fk_workforce_training_curriculum_approver_employee_id` FOREIGN KEY (`approver_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ADD CONSTRAINT `fk_workforce_training_curriculum_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ADD CONSTRAINT `fk_workforce_training_curriculum_job_profile_id` FOREIGN KEY (`job_profile_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`job_profile`(`job_profile_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ADD CONSTRAINT `fk_workforce_training_curriculum_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ADD CONSTRAINT `fk_workforce_training_curriculum_owner_employee_id` FOREIGN KEY (`owner_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ADD CONSTRAINT `fk_workforce_training_curriculum_superseded_by_curriculum_training_curriculum_id` FOREIGN KEY (`superseded_by_curriculum_training_curriculum_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`training_curriculum`(`training_curriculum_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` SET TAGS ('dbx_domain' = 'workforce');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` SET TAGS ('dbx_subdomain' = 'learning_development');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `approver_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Curriculum Approver Employee ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `approver_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `approver_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `approver_employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `approver_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Sop Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `job_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Job Profile Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Org Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `owner_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Curriculum Owner Employee ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `owner_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `owner_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `owner_employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `owner_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `superseded_by_curriculum_training_curriculum_id` SET TAGS ('dbx_business_glossary_term' = 'Superseded By Curriculum ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `applicable_study_phase` SET TAGS ('dbx_value_regex' = 'phase_1|phase_2|phase_3|phase_4|all_phases');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Curriculum Approval Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `change_summary` SET TAGS ('dbx_business_glossary_term' = 'Version Change Summary');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `completion_window_days` SET TAGS ('dbx_business_glossary_term' = 'Required Completion Window (Days)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `curriculum_code` SET TAGS ('dbx_business_glossary_term' = 'Training Curriculum Code');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `curriculum_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{3,30}$');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `curriculum_name` SET TAGS ('dbx_business_glossary_term' = 'Training Curriculum Name');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `curriculum_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `curriculum_status` SET TAGS ('dbx_business_glossary_term' = 'Training Curriculum Lifecycle Status');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `curriculum_status` SET TAGS ('dbx_value_regex' = 'draft|active|retired|superseded|under_review');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `curriculum_type` SET TAGS ('dbx_business_glossary_term' = 'Training Curriculum Type');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `curriculum_type` SET TAGS ('dbx_value_regex' = 'onboarding|role_based|protocol_specific|system_specific|regulatory|refresher');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `delivery_method` SET TAGS ('dbx_business_glossary_term' = 'Training Delivery Method');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `delivery_method` SET TAGS ('dbx_value_regex' = 'elearning|instructor_led|blended|read_acknowledge|on_the_job');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Curriculum Effective Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `estimated_duration_hours` SET TAGS ('dbx_business_glossary_term' = 'Estimated Total Duration (Hours)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `gcp_training_included` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Training Included');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `inspection_ready` SET TAGS ('dbx_business_glossary_term' = 'Inspection Ready Flag');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `language_code` SET TAGS ('dbx_business_glossary_term' = 'Curriculum Language Code');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `language_code` SET TAGS ('dbx_value_regex' = '^[a-z]{2}(-[A-Z]{2})?$');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `language_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `last_review_date` SET TAGS ('dbx_business_glossary_term' = 'Last Periodic Review Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `mandatory_flag` SET TAGS ('dbx_business_glossary_term' = 'Mandatory Curriculum Flag');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `mastercontrol_curriculum_code` SET TAGS ('dbx_business_glossary_term' = 'MasterControl Curriculum ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `max_attempts_allowed` SET TAGS ('dbx_business_glossary_term' = 'Maximum Assessment Attempts Allowed');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `next_review_date` SET TAGS ('dbx_business_glossary_term' = 'Next Scheduled Review Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `passing_score_percent` SET TAGS ('dbx_business_glossary_term' = 'Minimum Passing Score (Percent)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `protocol_training_included` SET TAGS ('dbx_business_glossary_term' = 'Protocol-Specific Training Included');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `recertification_period_months` SET TAGS ('dbx_business_glossary_term' = 'Recertification Period (Months)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `retirement_date` SET TAGS ('dbx_business_glossary_term' = 'Curriculum Retirement Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `sop_training_included` SET TAGS ('dbx_business_glossary_term' = 'Standard Operating Procedure (SOP) Training Included');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `sponsor_specific` SET TAGS ('dbx_business_glossary_term' = 'Sponsor-Specific Curriculum Flag');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `system_training_included` SET TAGS ('dbx_business_glossary_term' = 'System-Specific Training Included');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `version_number` SET TAGS ('dbx_business_glossary_term' = 'Curriculum Version Number');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `version_number` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+(.[0-9]+)?$');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_curriculum` ALTER COLUMN `workday_learning_program_code` SET TAGS ('dbx_business_glossary_term' = 'Workday Learning Program ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ADD CONSTRAINT `fk_workforce_payroll_record_cost_center_id` FOREIGN KEY (`cost_center_id`) REFERENCES `clinical_trials_ecm`.`finance`.`cost_center`(`cost_center_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ADD CONSTRAINT `fk_workforce_payroll_record_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ADD CONSTRAINT `fk_workforce_payroll_record_gl_account_id` FOREIGN KEY (`gl_account_id`) REFERENCES `clinical_trials_ecm`.`finance`.`gl_account`(`gl_account_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ADD CONSTRAINT `fk_workforce_payroll_record_reversed_record_payroll_record_id` FOREIGN KEY (`reversed_record_payroll_record_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`payroll_record`(`payroll_record_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ADD CONSTRAINT `fk_workforce_payroll_record_study_budget_id` FOREIGN KEY (`study_budget_id`) REFERENCES `clinical_trials_ecm`.`finance`.`study_budget`(`study_budget_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ADD CONSTRAINT `fk_workforce_payroll_record_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` SET TAGS ('dbx_domain' = 'workforce');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` SET TAGS ('dbx_subdomain' = 'personnel_management');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `gl_account_id` SET TAGS ('dbx_business_glossary_term' = 'Gl Account Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `reversed_record_payroll_record_id` SET TAGS ('dbx_business_glossary_term' = 'Reversed Payroll Record ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `study_budget_id` SET TAGS ('dbx_business_glossary_term' = 'Study Budget Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `allowance_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `allowance_amount` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `bank_account_last4` SET TAGS ('dbx_business_glossary_term' = 'Bank Account Last 4 Digits');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `bank_account_last4` SET TAGS ('dbx_value_regex' = '^[0-9]{4}$');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `bank_account_last4` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `bank_account_last4` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `bank_account_last4` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `base_salary_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `base_salary_amount` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `base_salary_amount` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `benefits_deduction` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `benefits_deduction` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `bonus_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `bonus_amount` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `employee_full_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `employee_full_name` SET TAGS ('dbx_pii_name' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `employee_full_name` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `employer_benefits_contribution` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `employer_retirement_contribution` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `employer_tax_contribution` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `employment_type` SET TAGS ('dbx_value_regex' = 'full_time|part_time|contract|temporary');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `gross_pay` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `gross_pay` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `gross_pay` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `is_reversal` SET TAGS ('dbx_business_glossary_term' = 'Is Reversal Indicator');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `net_pay` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `net_pay` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `net_pay` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `overtime_amount` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `overtime_amount` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `pay_frequency` SET TAGS ('dbx_value_regex' = 'weekly|biweekly|semimonthly|monthly');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'direct_deposit|check|wire_transfer|cash');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `payroll_run_type` SET TAGS ('dbx_value_regex' = 'regular|off_cycle|supplemental|correction|final');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `retirement_deduction` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `retirement_deduction` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `run_status` SET TAGS ('dbx_business_glossary_term' = 'Payroll Run Status');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `run_status` SET TAGS ('dbx_value_regex' = 'calculated|confirmed|paid|reversed|void');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `tax_withholding_status` SET TAGS ('dbx_value_regex' = 'single|married|head_of_household|exempt');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `total_tax_deduction` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `total_tax_deduction` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `work_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `workday_worker_code` SET TAGS ('dbx_business_glossary_term' = 'Workday Worker ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `workday_worker_code` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `workday_worker_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `workday_worker_code` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`payroll_record` ALTER COLUMN `workday_worker_code` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ADD CONSTRAINT `fk_workforce_org_unit_cost_center_id` FOREIGN KEY (`cost_center_id`) REFERENCES `clinical_trials_ecm`.`finance`.`cost_center`(`cost_center_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ADD CONSTRAINT `fk_workforce_org_unit_parent_org_unit_id` FOREIGN KEY (`parent_org_unit_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`org_unit`(`org_unit_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` SET TAGS ('dbx_data_type' = 'reference_data');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` SET TAGS ('dbx_domain' = 'workforce');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` SET TAGS ('dbx_subdomain' = 'personnel_management');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ALTER COLUMN `org_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Organizational Unit ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ALTER COLUMN `parent_org_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Parent Organizational Unit ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ALTER COLUMN `change_reason` SET TAGS ('dbx_business_glossary_term' = 'Organizational Change Reason');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ALTER COLUMN `ctms_org_ref` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Organization Reference');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ALTER COLUMN `email_address` SET TAGS ('dbx_business_glossary_term' = 'Organizational Unit Email Address');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ALTER COLUMN `email_address` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ALTER COLUMN `email_address` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ALTER COLUMN `email_address` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ALTER COLUMN `email_address` SET TAGS ('dbx_pii_address' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ALTER COLUMN `email_address` SET TAGS ('dbx_pii_email' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ALTER COLUMN `email_address` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ALTER COLUMN `fte_budget` SET TAGS ('dbx_business_glossary_term' = 'Full-Time Equivalent (FTE) Budget');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ALTER COLUMN `gcp_training_compliance_pct` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Training Compliance Percentage');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ALTER COLUMN `geographic_region` SET TAGS ('dbx_value_regex' = 'global|north_america|europe|asia_pacific|latin_america|middle_east_africa');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ALTER COLUMN `hierarchy_level` SET TAGS ('dbx_business_glossary_term' = 'Organizational Hierarchy Level');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ALTER COLUMN `hierarchy_path` SET TAGS ('dbx_business_glossary_term' = 'Organizational Hierarchy Path');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ALTER COLUMN `is_billable` SET TAGS ('dbx_business_glossary_term' = 'Billable Unit Indicator');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ALTER COLUMN `is_gcp_regulated` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Regulated Unit Indicator');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ALTER COLUMN `phone_number` SET TAGS ('dbx_business_glossary_term' = 'Organizational Unit Phone Number');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ALTER COLUMN `phone_number` SET TAGS ('dbx_value_regex' = '^+?[0-9s-().]{7,20}$');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ALTER COLUMN `phone_number` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ALTER COLUMN `phone_number` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ALTER COLUMN `phone_number` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ALTER COLUMN `phone_number` SET TAGS ('dbx_pii_phone' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ALTER COLUMN `sop_owner` SET TAGS ('dbx_business_glossary_term' = 'Standard Operating Procedure (SOP) Owner');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ALTER COLUMN `unit_code` SET TAGS ('dbx_business_glossary_term' = 'Organizational Unit Code');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ALTER COLUMN `unit_code` SET TAGS ('dbx_value_regex' = '^[A-Z0-9_-]{2,20}$');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ALTER COLUMN `unit_description` SET TAGS ('dbx_business_glossary_term' = 'Organizational Unit Description');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ALTER COLUMN `unit_name` SET TAGS ('dbx_business_glossary_term' = 'Organizational Unit Name');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ALTER COLUMN `unit_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ALTER COLUMN `unit_status` SET TAGS ('dbx_business_glossary_term' = 'Organizational Unit Status');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ALTER COLUMN `unit_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|dissolved|merged');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`org_unit` ALTER COLUMN `unit_type` SET TAGS ('dbx_business_glossary_term' = 'Organizational Unit Type');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ADD CONSTRAINT `fk_workforce_position_cost_center_id` FOREIGN KEY (`cost_center_id`) REFERENCES `clinical_trials_ecm`.`finance`.`cost_center`(`cost_center_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ADD CONSTRAINT `fk_workforce_position_hiring_manager_employee_id` FOREIGN KEY (`hiring_manager_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ADD CONSTRAINT `fk_workforce_position_job_profile_id` FOREIGN KEY (`job_profile_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`job_profile`(`job_profile_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ADD CONSTRAINT `fk_workforce_position_org_unit_id` FOREIGN KEY (`org_unit_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`org_unit`(`org_unit_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ADD CONSTRAINT `fk_workforce_position_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ADD CONSTRAINT `fk_workforce_position_workforce_resource_plan_id` FOREIGN KEY (`workforce_resource_plan_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`workforce_resource_plan`(`workforce_resource_plan_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` SET TAGS ('dbx_domain' = 'workforce');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` SET TAGS ('dbx_subdomain' = 'personnel_management');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `hiring_manager_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `hiring_manager_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `hiring_manager_employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `hiring_manager_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `job_profile_id` SET TAGS ('dbx_internal' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `org_unit_id` SET TAGS ('dbx_business_glossary_term' = 'Organizational Unit ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `workforce_resource_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Workforce Resource Plan Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Position Approval Status');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'Draft|Pending|Approved|Rejected|Cancelled');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `approved_date` SET TAGS ('dbx_business_glossary_term' = 'Position Approval Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `budgeted_fte` SET TAGS ('dbx_business_glossary_term' = 'Budgeted Full-Time Equivalent (FTE)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `effective_end_date` SET TAGS ('dbx_business_glossary_term' = 'Position Effective End Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `effective_start_date` SET TAGS ('dbx_business_glossary_term' = 'Position Effective Start Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `filled_date` SET TAGS ('dbx_business_glossary_term' = 'Position Filled Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `freeze_reason` SET TAGS ('dbx_business_glossary_term' = 'Position Freeze Reason');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `geographic_region` SET TAGS ('dbx_value_regex' = 'Global|North America|EMEA|APAC|Latin America|Japan');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `incumbency_status` SET TAGS ('dbx_business_glossary_term' = 'Position Incumbency Status');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `incumbency_status` SET TAGS ('dbx_value_regex' = 'Filled|Vacant|Frozen|Pending-Approval|Eliminated');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `is_delegation_eligible` SET TAGS ('dbx_business_glossary_term' = 'Delegation Eligibility Flag');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `is_gcp_required` SET TAGS ('dbx_business_glossary_term' = 'Good Clinical Practice (GCP) Training Required Flag');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `is_pi_eligible` SET TAGS ('dbx_business_glossary_term' = 'Principal Investigator (PI) Eligibility Flag');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `is_safety_reporting_role` SET TAGS ('dbx_business_glossary_term' = 'Safety Reporting Role Flag');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `pay_grade` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `salary_currency` SET TAGS ('dbx_business_glossary_term' = 'Salary Currency Code');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `salary_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `salary_currency` SET TAGS ('dbx_restricted' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `salary_currency` SET TAGS ('dbx_pii_financial' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `salary_range_max` SET TAGS ('dbx_business_glossary_term' = 'Salary Range Maximum');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `salary_range_max` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `salary_range_min` SET TAGS ('dbx_business_glossary_term' = 'Salary Range Minimum');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `salary_range_min` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `title` SET TAGS ('dbx_business_glossary_term' = 'Position Title');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `position_type` SET TAGS ('dbx_value_regex' = 'Permanent|Fixed-Term|Contractor|Temporary|Intern');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `vacated_date` SET TAGS ('dbx_business_glossary_term' = 'Position Vacated Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`position` ALTER COLUMN `workday_position_code` SET TAGS ('dbx_business_glossary_term' = 'Workday Position ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ADD CONSTRAINT `fk_workforce_protocol_training_record_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_ecm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ADD CONSTRAINT `fk_workforce_protocol_training_record_primary_protocol_employee_id` FOREIGN KEY (`primary_protocol_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ADD CONSTRAINT `fk_workforce_protocol_training_record_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_ecm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ADD CONSTRAINT `fk_workforce_protocol_training_record_study_assignment_id` FOREIGN KEY (`study_assignment_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`study_assignment`(`study_assignment_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ADD CONSTRAINT `fk_workforce_protocol_training_record_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ADD CONSTRAINT `fk_workforce_protocol_training_record_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_ecm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ADD CONSTRAINT `fk_workforce_protocol_training_record_tmf_artifact_id` FOREIGN KEY (`tmf_artifact_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_artifact`(`tmf_artifact_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ADD CONSTRAINT `fk_workforce_protocol_training_record_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ADD CONSTRAINT `fk_workforce_protocol_training_record_workforce_delegation_log_id` FOREIGN KEY (`workforce_delegation_log_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`workforce_delegation_log`(`workforce_delegation_log_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` SET TAGS ('dbx_domain' = 'workforce');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` SET TAGS ('dbx_subdomain' = 'learning_development');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `investigational_site_id` SET TAGS ('dbx_business_glossary_term' = 'Site ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `primary_protocol_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Employee ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `primary_protocol_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `primary_protocol_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `primary_protocol_employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `primary_protocol_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `protocol_id` SET TAGS ('dbx_business_glossary_term' = 'Protocol Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `study_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Study Assignment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `study_protocol_amendment_id` SET TAGS ('dbx_business_glossary_term' = 'Amendment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `tmf_artifact_id` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Artifact ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `tmf_document_id` SET TAGS ('dbx_business_glossary_term' = 'Training Material Document ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `workforce_delegation_log_id` SET TAGS ('dbx_business_glossary_term' = 'Delegation Log Entry ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `assessment_score` SET TAGS ('dbx_business_glossary_term' = 'Protocol Training Assessment Score');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `attempt_number` SET TAGS ('dbx_business_glossary_term' = 'Training Attempt Number');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `certificate_number` SET TAGS ('dbx_business_glossary_term' = 'Training Certificate Number');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Protocol Training Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `inspection_ready` SET TAGS ('dbx_business_glossary_term' = 'Inspection Ready Flag');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `mastercontrol_training_code` SET TAGS ('dbx_business_glossary_term' = 'MasterControl Training Record ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Training Record Notes');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `pass_fail_status` SET TAGS ('dbx_business_glossary_term' = 'Training Assessment Pass/Fail Status');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `pass_fail_status` SET TAGS ('dbx_value_regex' = 'pass|fail|not_assessed');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `retraining_due_date` SET TAGS ('dbx_business_glossary_term' = 'Re-Training Due Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `retraining_required` SET TAGS ('dbx_business_glossary_term' = 'Re-Training Required Flag');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `role_at_training` SET TAGS ('dbx_business_glossary_term' = 'Employee Role at Time of Training');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `signature_captured` SET TAGS ('dbx_business_glossary_term' = 'Electronic Signature Captured Flag');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `signature_captured` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `signature_date` SET TAGS ('dbx_business_glossary_term' = 'Employee Signature Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `signature_date` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `study_phase` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study Phase');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `study_phase` SET TAGS ('dbx_value_regex' = 'Phase I|Phase II|Phase III|Phase IV|Phase I/II');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `trainer_name` SET TAGS ('dbx_business_glossary_term' = 'Trainer or Training Provider Name');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `trainer_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `training_date` SET TAGS ('dbx_business_glossary_term' = 'Protocol Training Completion Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `training_delivery_method` SET TAGS ('dbx_value_regex' = 'in_person|webinar|e_learning|self_study|investigator_meeting');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `training_duration_minutes` SET TAGS ('dbx_business_glossary_term' = 'Training Duration (Minutes)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `training_provider_name` SET TAGS ('dbx_business_glossary_term' = 'External Training Provider Name');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `training_provider_name` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `training_status` SET TAGS ('dbx_business_glossary_term' = 'Protocol Training Status');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `training_status` SET TAGS ('dbx_value_regex' = 'completed|in_progress|not_started|overdue|waived|expired');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `training_type` SET TAGS ('dbx_business_glossary_term' = 'Protocol Training Type');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `training_type` SET TAGS ('dbx_value_regex' = 'protocol_overview|protocol_amendment|therapeutic_area|pharmacology|safety_reporting|study_procedures');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `waiver_approved_by` SET TAGS ('dbx_business_glossary_term' = 'Training Waiver Approved By');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `waiver_reason` SET TAGS ('dbx_business_glossary_term' = 'Training Waiver Reason');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `workday_worker_code` SET TAGS ('dbx_business_glossary_term' = 'Workday Worker ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `workday_worker_code` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `workday_worker_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `workday_worker_code` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`protocol_training_record` ALTER COLUMN `workday_worker_code` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ADD CONSTRAINT `fk_workforce_cra_qualification_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `clinical_trials_ecm`.`sponsor`.`organization`(`organization_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ADD CONSTRAINT `fk_workforce_cra_qualification_primary_cra_employee_id` FOREIGN KEY (`primary_cra_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ADD CONSTRAINT `fk_workforce_cra_qualification_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ADD CONSTRAINT `fk_workforce_cra_qualification_therapeutic_area_id` FOREIGN KEY (`therapeutic_area_id`) REFERENCES `clinical_trials_ecm`.`program`.`therapeutic_area`(`therapeutic_area_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` SET TAGS ('dbx_domain' = 'workforce');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` SET TAGS ('dbx_subdomain' = 'personnel_management');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `cra_qualification_id` SET TAGS ('dbx_business_glossary_term' = 'Clinical Research Associate (CRA) Qualification ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `organization_id` SET TAGS ('dbx_business_glossary_term' = 'Qualifying Org Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `primary_cra_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Employee ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `primary_cra_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `primary_cra_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `primary_cra_employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `primary_cra_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `therapeutic_area_id` SET TAGS ('dbx_business_glossary_term' = 'Cra Ta Qualification - Therapeutic Area Id');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Qualification Approval Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `country_codes` SET TAGS ('dbx_business_glossary_term' = 'Qualified Country Codes');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `ctms_proficiency` SET TAGS ('dbx_business_glossary_term' = 'Clinical Trial Management System (CTMS) Proficiency Level');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `ctms_proficiency` SET TAGS ('dbx_value_regex' = 'none|basic|intermediate|advanced|expert');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `ctms_qualification_ref` SET TAGS ('dbx_business_glossary_term' = 'CTMS Qualification Reference');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `device_trial_experience_confirmed` SET TAGS ('dbx_business_glossary_term' = 'Medical Device Trial Experience Confirmed');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'TA Qualification Effective Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `experience_confirmed` SET TAGS ('dbx_business_glossary_term' = 'TA Experience Confirmed Flag');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'TA Qualification Expiry Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `geographic_regions` SET TAGS ('dbx_business_glossary_term' = 'Geographic Coverage Regions');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `independent_monitoring_visits` SET TAGS ('dbx_business_glossary_term' = 'Independent Monitoring Visits Conducted');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `inspection_ready` SET TAGS ('dbx_business_glossary_term' = 'Inspection Ready Flag');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `irt_rtsm_proficiency` SET TAGS ('dbx_business_glossary_term' = 'Interactive Response Technology / Randomization and Trial Supply Management (IRT/RTSM) Proficiency Level');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `irt_rtsm_proficiency` SET TAGS ('dbx_value_regex' = 'none|basic|intermediate|advanced|expert');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `language_proficiencies` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `medidata_rave_proficiency` SET TAGS ('dbx_business_glossary_term' = 'Medidata Rave EDC Proficiency Level');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `medidata_rave_proficiency` SET TAGS ('dbx_value_regex' = 'none|basic|intermediate|advanced|expert');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `monitoring_experience_years` SET TAGS ('dbx_business_glossary_term' = 'Monitoring Experience (Years)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `oracle_clinical_one_proficiency` SET TAGS ('dbx_business_glossary_term' = 'Oracle Clinical One Proficiency Level');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `oracle_clinical_one_proficiency` SET TAGS ('dbx_value_regex' = 'none|basic|intermediate|advanced|expert');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `primary_language_code` SET TAGS ('dbx_value_regex' = '^[a-z]{2}$');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `primary_language_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `qualification_code` SET TAGS ('dbx_business_glossary_term' = 'CRA Qualification Code');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `qualification_code` SET TAGS ('dbx_value_regex' = '^CRA-QUAL-[A-Z0-9]{6,12}$');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `qualification_status` SET TAGS ('dbx_business_glossary_term' = 'CRA Qualification Status');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `qualification_status` SET TAGS ('dbx_value_regex' = 'active|inactive|suspended|pending_review|archived');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `qualification_type` SET TAGS ('dbx_business_glossary_term' = 'CRA Qualification Type');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `qualification_type` SET TAGS ('dbx_value_regex' = 'field_cra|remote_cra|lead_cra|senior_cra|contract_cra');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `risk_based_monitoring_qualified` SET TAGS ('dbx_business_glossary_term' = 'Risk-Based Monitoring (RBM) Qualified');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `sdv_experience_confirmed` SET TAGS ('dbx_business_glossary_term' = 'Source Data Verification (SDV) Experience Confirmed');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `sponsor_qualifications` SET TAGS ('dbx_business_glossary_term' = 'Sponsor-Specific Qualifications');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `cra_qualification_status` SET TAGS ('dbx_business_glossary_term' = 'TA Qualification Status');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `study_phases_experienced` SET TAGS ('dbx_business_glossary_term' = 'Clinical Study Phase Experience');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `therapeutic_areas` SET TAGS ('dbx_business_glossary_term' = 'Therapeutic Area Experience');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `total_monitoring_visits` SET TAGS ('dbx_business_glossary_term' = 'Total Monitoring Visits Conducted');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `veeva_vault_proficiency` SET TAGS ('dbx_business_glossary_term' = 'Veeva Vault eTMF Proficiency Level');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `veeva_vault_proficiency` SET TAGS ('dbx_value_regex' = 'none|basic|intermediate|advanced|expert');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `workday_worker_code` SET TAGS ('dbx_business_glossary_term' = 'Workday Worker ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `workday_worker_code` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `workday_worker_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `workday_worker_code` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`cra_qualification` ALTER COLUMN `workday_worker_code` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ADD CONSTRAINT `fk_workforce_workforce_capa_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ADD CONSTRAINT `fk_workforce_workforce_capa_initiating_audit_id` FOREIGN KEY (`initiating_audit_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`audit`(`audit_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ADD CONSTRAINT `fk_workforce_workforce_capa_obligation_id` FOREIGN KEY (`obligation_id`) REFERENCES `clinical_trials_ecm`.`compliance`.`obligation`(`obligation_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ADD CONSTRAINT `fk_workforce_workforce_capa_owner_employee_id` FOREIGN KEY (`owner_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ADD CONSTRAINT `fk_workforce_workforce_capa_primary_workforce_employee_id` FOREIGN KEY (`primary_workforce_employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ADD CONSTRAINT `fk_workforce_workforce_capa_prior_capa_workforce_capa_id` FOREIGN KEY (`prior_capa_workforce_capa_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`workforce_capa`(`workforce_capa_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ADD CONSTRAINT `fk_workforce_workforce_capa_study_assignment_id` FOREIGN KEY (`study_assignment_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`study_assignment`(`study_assignment_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ADD CONSTRAINT `fk_workforce_workforce_capa_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ADD CONSTRAINT `fk_workforce_workforce_capa_tmf_artifact_id` FOREIGN KEY (`tmf_artifact_id`) REFERENCES `clinical_trials_ecm`.`document`.`tmf_artifact`(`tmf_artifact_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ADD CONSTRAINT `fk_workforce_workforce_capa_training_record_id` FOREIGN KEY (`training_record_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`training_record`(`training_record_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` SET TAGS ('dbx_data_type' = 'transactional_data');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` SET TAGS ('dbx_domain' = 'workforce');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` SET TAGS ('dbx_subdomain' = 'resource_allocation');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `workforce_capa_id` SET TAGS ('dbx_business_glossary_term' = 'Workforce Corrective and Preventive Action (CAPA) ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `compliance_sop_id` SET TAGS ('dbx_business_glossary_term' = 'Related Standard Operating Procedure (SOP) ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `obligation_id` SET TAGS ('dbx_business_glossary_term' = 'Obligation Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `owner_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Owner ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `owner_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `owner_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `owner_employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `owner_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `primary_workforce_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Employee ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `primary_workforce_employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `primary_workforce_employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `primary_workforce_employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `primary_workforce_employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `prior_capa_workforce_capa_id` SET TAGS ('dbx_business_glossary_term' = 'Prior Corrective and Preventive Action (CAPA) ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `study_assignment_id` SET TAGS ('dbx_business_glossary_term' = 'Study Assignment Id (Foreign Key)');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `tmf_artifact_id` SET TAGS ('dbx_business_glossary_term' = 'Trial Master File (TMF) Artifact ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `training_record_id` SET TAGS ('dbx_business_glossary_term' = 'Related Training Record ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `capa_number` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Number');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `capa_number` SET TAGS ('dbx_value_regex' = '^CAPA-WF-[0-9]{4}-[0-9]{5}$');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `capa_status` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Status');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `capa_type` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Type');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `capa_type` SET TAGS ('dbx_value_regex' = 'corrective|preventive|combined');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `closure_date` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Closure Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `closure_justification` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Closure Justification');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `completion_date` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Completion Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Due Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `effectiveness_check_date` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Effectiveness Check Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `effectiveness_check_description` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Effectiveness Check Description');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `effectiveness_check_result` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Effectiveness Check Result');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `effectiveness_check_result` SET TAGS ('dbx_value_regex' = 'effective|partially_effective|not_effective|pending');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `employee_role` SET TAGS ('dbx_business_glossary_term' = 'Employee Role at Time of Non-Compliance');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `initiation_date` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Initiation Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `inspection_ready` SET TAGS ('dbx_business_glossary_term' = 'Inspection Ready Flag');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `mastercontrol_capa_ref` SET TAGS ('dbx_business_glossary_term' = 'MasterControl Corrective and Preventive Action (CAPA) Reference');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `non_compliance_category` SET TAGS ('dbx_business_glossary_term' = 'Non-Compliance Category');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `non_compliance_description` SET TAGS ('dbx_business_glossary_term' = 'Non-Compliance Description');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Notes');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `priority` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Priority');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `priority` SET TAGS ('dbx_value_regex' = 'high|medium|low');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `qa_review_date` SET TAGS ('dbx_business_glossary_term' = 'Quality Assurance (QA) Review Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `qa_review_outcome` SET TAGS ('dbx_business_glossary_term' = 'Quality Assurance (QA) Review Outcome');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `qa_review_outcome` SET TAGS ('dbx_value_regex' = 'approved|rejected|pending|returned_for_revision');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `regulatory_authority_notified` SET TAGS ('dbx_business_glossary_term' = 'Regulatory Authority Notified Flag');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `severity` SET TAGS ('dbx_business_glossary_term' = 'Corrective and Preventive Action (CAPA) Severity');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `severity` SET TAGS ('dbx_value_regex' = 'critical|major|minor|observation');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `workday_worker_code` SET TAGS ('dbx_business_glossary_term' = 'Workday Worker ID');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `workday_worker_code` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `workday_worker_code` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `workday_worker_code` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`workforce_capa` ALTER COLUMN `workday_worker_code` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`program_team_member` ADD CONSTRAINT `fk_workforce_program_team_member_clinical_program_id` FOREIGN KEY (`clinical_program_id`) REFERENCES `clinical_trials_ecm`.`program`.`clinical_program`(`clinical_program_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`program_team_member` ADD CONSTRAINT `fk_workforce_program_team_member_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`employee`(`employee_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`program_team_member` ADD CONSTRAINT `fk_workforce_program_team_member_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`program_team_member` SET TAGS ('dbx_data_type' = 'association_data');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`program_team_member` SET TAGS ('dbx_domain' = 'workforce');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`program_team_member` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`program_team_member` SET TAGS ('dbx_subdomain' = 'resource_allocation');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`program_team_member` SET TAGS ('dbx_association_edges' = 'workforce.employee,program.clinical_program');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`program_team_member` ALTER COLUMN `program_team_member_id` SET TAGS ('dbx_business_glossary_term' = 'Program Team Member - Program Team Member Id');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`program_team_member` ALTER COLUMN `program_team_member_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`program_team_member` ALTER COLUMN `program_team_member_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`program_team_member` ALTER COLUMN `program_team_member_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`program_team_member` ALTER COLUMN `program_team_member_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`program_team_member` ALTER COLUMN `clinical_program_id` SET TAGS ('dbx_business_glossary_term' = 'Program Team Member - Clinical Program Id');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`program_team_member` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Program Team Member - Employee Id');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`program_team_member` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`program_team_member` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`program_team_member` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii_identifier' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`program_team_member` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii_person_data' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`program_team_member` ALTER COLUMN `end_date` SET TAGS ('dbx_business_glossary_term' = 'Assignment End Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`program_team_member` ALTER COLUMN `fte_allocation_percentage` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`program_team_member` ALTER COLUMN `gcp_certification_status` SET TAGS ('dbx_business_glossary_term' = 'GCP Certification Status at Assignment');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`program_team_member` ALTER COLUMN `start_date` SET TAGS ('dbx_business_glossary_term' = 'Assignment Start Date');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`program_team_member` ALTER COLUMN `therapeutic_area_expertise` SET TAGS ('dbx_business_glossary_term' = 'Therapeutic Area Expertise for Assignment');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_course` ADD CONSTRAINT `fk_workforce_training_course_prerequisite_training_course_id` FOREIGN KEY (`prerequisite_training_course_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`training_course`(`training_course_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_course` ADD CONSTRAINT `fk_workforce_training_course_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_ecm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_course` ADD CONSTRAINT `fk_workforce_training_course_training_curriculum_id` FOREIGN KEY (`training_curriculum_id`) REFERENCES `clinical_trials_ecm`.`workforce`.`training_curriculum`(`training_curriculum_id`);

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_course` SET TAGS ('dbx_data_type' = 'master_data');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_course` SET TAGS ('dbx_domain' = 'workforce');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_course` SET TAGS ('dbx_division' = 'corporate');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_course` SET TAGS ('dbx_subdomain' = 'learning_development');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_course` ALTER COLUMN `training_course_id` SET TAGS ('dbx_business_glossary_term' = 'Training Course Identifier');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_course` ALTER COLUMN `prerequisite_training_course_id` SET TAGS ('dbx_self_ref_fk' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_course` ALTER COLUMN `available_languages` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_course` ALTER COLUMN `cost_per_participant` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_course` ALTER COLUMN `training_course_description` SET TAGS ('dbx_business_glossary_term' = 'Description');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_course` ALTER COLUMN `language` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_course` ALTER COLUMN `max_enrollment_capacity` SET TAGS ('dbx_pii' = 'true');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_course` ALTER COLUMN `training_course_status` SET TAGS ('dbx_business_glossary_term' = 'Status');

ALTER TABLE `clinical_trials_ecm`.`workforce`.`training_course` ALTER COLUMN `vendor_name` SET TAGS ('dbx_pii' = 'true');
