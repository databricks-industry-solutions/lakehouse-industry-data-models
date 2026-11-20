-- Generated on: 2026-11-20 12:39:50
-- EXECUTION ORDER: run this file FIRST, before every domain schema file. It drops the foreign keys of

ALTER TABLE `clinical_trials_mvm`.`site`.`initiation_visit` DROP CONSTRAINT IF EXISTS `fk_site_initiation_visit_agreement_id`;

ALTER TABLE `clinical_trials_mvm`.`site`.`site_cra_assignment` DROP CONSTRAINT IF EXISTS `fk_site_site_cra_assignment_agreement_id`;

ALTER TABLE `clinical_trials_mvm`.`site`.`closeout` DROP CONSTRAINT IF EXISTS `fk_site_closeout_agreement_id`;

ALTER TABLE `clinical_trials_mvm`.`site`.`closeout` DROP CONSTRAINT IF EXISTS `fk_site_closeout_capa_id`;

ALTER TABLE `clinical_trials_mvm`.`subject`.`enrollment` DROP CONSTRAINT IF EXISTS `fk_subject_enrollment_agreement_id`;

ALTER TABLE `clinical_trials_mvm`.`subject`.`randomization_assignment` DROP CONSTRAINT IF EXISTS `fk_subject_randomization_assignment_dispensing_subject_visit_id`;

ALTER TABLE `clinical_trials_mvm`.`subject`.`disposition` DROP CONSTRAINT IF EXISTS `fk_subject_disposition_deviation_id`;

ALTER TABLE `clinical_trials_mvm`.`subject`.`disposition` DROP CONSTRAINT IF EXISTS `fk_subject_disposition_visit_id`;

ALTER TABLE `clinical_trials_mvm`.`subject`.`eligibility_assessment` DROP CONSTRAINT IF EXISTS `fk_subject_eligibility_assessment_deviation_id`;

ALTER TABLE `clinical_trials_mvm`.`subject`.`eligibility_assessment` DROP CONSTRAINT IF EXISTS `fk_subject_eligibility_assessment_icf_version_id`;

ALTER TABLE `clinical_trials_mvm`.`subject`.`eligibility_assessment` DROP CONSTRAINT IF EXISTS `fk_subject_eligibility_assessment_lab_result_id`;

ALTER TABLE `clinical_trials_mvm`.`subject`.`eligibility_assessment` DROP CONSTRAINT IF EXISTS `fk_subject_eligibility_assessment_visit_id`;

ALTER TABLE `clinical_trials_mvm`.`subject`.`demographic` DROP CONSTRAINT IF EXISTS `fk_subject_demographic_sex_codelist_term_id`;

ALTER TABLE `clinical_trials_mvm`.`subject`.`demographic` DROP CONSTRAINT IF EXISTS `fk_subject_demographic_race_codelist_term_id`;

ALTER TABLE `clinical_trials_mvm`.`subject`.`demographic` DROP CONSTRAINT IF EXISTS `fk_subject_demographic_ethnicity_codelist_term_id`;

ALTER TABLE `clinical_trials_mvm`.`subject`.`demographic` DROP CONSTRAINT IF EXISTS `fk_subject_demographic_age_unit_codelist_term_id`;

ALTER TABLE `clinical_trials_mvm`.`subject`.`medical_history` DROP CONSTRAINT IF EXISTS `fk_subject_medical_history_visit_id`;

ALTER TABLE `clinical_trials_mvm`.`subject`.`concomitant_medication` DROP CONSTRAINT IF EXISTS `fk_subject_concomitant_medication_visit_id`;

ALTER TABLE `clinical_trials_mvm`.`subject`.`sdv_review` DROP CONSTRAINT IF EXISTS `fk_subject_sdv_review_lab_result_id`;

ALTER TABLE `clinical_trials_mvm`.`subject`.`sdv_review` DROP CONSTRAINT IF EXISTS `fk_subject_sdv_review_visit_id`;

ALTER TABLE `clinical_trials_mvm`.`subject`.`subject_consent` DROP CONSTRAINT IF EXISTS `fk_subject_subject_consent_visit_id`;

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` DROP CONSTRAINT IF EXISTS `fk_safety_adverse_event_visit_id`;

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` DROP CONSTRAINT IF EXISTS `fk_safety_adverse_event_adverse_severity_codelist_term_id`;

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` DROP CONSTRAINT IF EXISTS `fk_safety_adverse_event_adverse_outcome_codelist_term_id`;

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` DROP CONSTRAINT IF EXISTS `fk_safety_adverse_event_adverse_action_taken_codelist_term_id`;

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` DROP CONSTRAINT IF EXISTS `fk_safety_serious_adverse_event_lab_result_id`;

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` DROP CONSTRAINT IF EXISTS `fk_safety_causality_assessment_lab_result_id`;

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` DROP CONSTRAINT IF EXISTS `fk_safety_causality_assessment_visit_id`;

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` DROP CONSTRAINT IF EXISTS `fk_safety_narrative_visit_id`;

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` DROP CONSTRAINT IF EXISTS `fk_safety_ae_follow_up_lab_result_id`;

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` DROP CONSTRAINT IF EXISTS `fk_safety_ae_follow_up_visit_id`;

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` DROP CONSTRAINT IF EXISTS `fk_datamanagement_ecrf_form_icf_version_id`;

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` DROP CONSTRAINT IF EXISTS `fk_datamanagement_subject_visit_data_visit_id`;

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` DROP CONSTRAINT IF EXISTS `fk_datamanagement_field_entry_lab_result_id`;

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` DROP CONSTRAINT IF EXISTS `fk_datamanagement_field_entry_visit_id`;

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` DROP CONSTRAINT IF EXISTS `fk_datamanagement_discrepancy_query_lab_result_id`;

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen` DROP CONSTRAINT IF EXISTS `fk_laboratory_specimen_icf_version_id`;

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen` DROP CONSTRAINT IF EXISTS `fk_laboratory_specimen_visit_id`;

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_collection` DROP CONSTRAINT IF EXISTS `fk_laboratory_specimen_collection_icf_version_id`;

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_collection` DROP CONSTRAINT IF EXISTS `fk_laboratory_specimen_collection_visit_id`;

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`pk_sample` DROP CONSTRAINT IF EXISTS `fk_laboratory_pk_sample_icf_version_id`;

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`pk_sample` DROP CONSTRAINT IF EXISTS `fk_laboratory_pk_sample_visit_id`;

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`bioanalytical_result` DROP CONSTRAINT IF EXISTS `fk_laboratory_bioanalytical_result_icf_version_id`;

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_query` DROP CONSTRAINT IF EXISTS `fk_laboratory_lab_query_lab_result_id`;

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_query` DROP CONSTRAINT IF EXISTS `fk_laboratory_lab_query_visit_id`;

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_aliquot` DROP CONSTRAINT IF EXISTS `fk_laboratory_specimen_aliquot_icf_version_id`;

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_aliquot` DROP CONSTRAINT IF EXISTS `fk_laboratory_specimen_aliquot_visit_id`;

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` DROP CONSTRAINT IF EXISTS `fk_supply_manufacture_batch_capa_id`;

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` DROP CONSTRAINT IF EXISTS `fk_supply_dispensing_record_icf_version_id`;

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` DROP CONSTRAINT IF EXISTS `fk_supply_dispensing_record_visit_id`;

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` DROP CONSTRAINT IF EXISTS `fk_supply_return_record_deviation_id`;

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` DROP CONSTRAINT IF EXISTS `fk_supply_return_record_visit_id`;

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` DROP CONSTRAINT IF EXISTS `fk_supply_temperature_excursion_capa_id`;

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_report` DROP CONSTRAINT IF EXISTS `fk_monitoring_visit_report_icf_version_id`;

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`sdv_record` DROP CONSTRAINT IF EXISTS `fk_monitoring_sdv_record_action_item_id`;

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`sdv_record` DROP CONSTRAINT IF EXISTS `fk_monitoring_sdv_record_icf_version_id`;

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`sdv_record` DROP CONSTRAINT IF EXISTS `fk_monitoring_sdv_record_lab_result_id`;

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`sdv_record` DROP CONSTRAINT IF EXISTS `fk_monitoring_sdv_record_visit_id`;

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_deviation_finding` DROP CONSTRAINT IF EXISTS `fk_monitoring_visit_deviation_finding_action_item_id`;

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_deviation_finding` DROP CONSTRAINT IF EXISTS `fk_monitoring_visit_deviation_finding_capa_id`;

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_deviation_finding` DROP CONSTRAINT IF EXISTS `fk_monitoring_visit_deviation_finding_deviation_id`;

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_deviation_finding` DROP CONSTRAINT IF EXISTS `fk_monitoring_visit_deviation_finding_icf_version_id`;

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_deviation_finding` DROP CONSTRAINT IF EXISTS `fk_monitoring_visit_deviation_finding_lab_result_id`;

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_deviation_finding` DROP CONSTRAINT IF EXISTS `fk_monitoring_visit_deviation_finding_visit_id`;

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_finding` DROP CONSTRAINT IF EXISTS `fk_monitoring_visit_finding_action_item_id`;

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_finding` DROP CONSTRAINT IF EXISTS `fk_monitoring_visit_finding_deviation_id`;

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_finding` DROP CONSTRAINT IF EXISTS `fk_monitoring_visit_finding_icf_version_id`;

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_finding` DROP CONSTRAINT IF EXISTS `fk_monitoring_visit_finding_lab_result_id`;

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`risk_indicator` DROP CONSTRAINT IF EXISTS `fk_monitoring_risk_indicator_icf_version_id`;

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`site_risk_assessment` DROP CONSTRAINT IF EXISTS `fk_monitoring_site_risk_assessment_capa_id`;

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`ip_accountability_log` DROP CONSTRAINT IF EXISTS `fk_monitoring_ip_accountability_log_capa_id`;

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` DROP CONSTRAINT IF EXISTS `fk_monitoring_escalation_record_action_item_id`;

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` DROP CONSTRAINT IF EXISTS `fk_monitoring_escalation_record_capa_id`;

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` DROP CONSTRAINT IF EXISTS `fk_monitoring_escalation_record_lab_result_id`;

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_checklist` DROP CONSTRAINT IF EXISTS `fk_monitoring_visit_checklist_action_item_id`;

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_checklist` DROP CONSTRAINT IF EXISTS `fk_monitoring_visit_checklist_icf_version_id`;

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` DROP CONSTRAINT IF EXISTS `fk_consent_consent_subject_consent_icf_version_id`;

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` DROP CONSTRAINT IF EXISTS `fk_consent_econsent_session_icf_version_id`;

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` DROP CONSTRAINT IF EXISTS `fk_consent_reconsent_trigger_icf_version_id`;

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` DROP CONSTRAINT IF EXISTS `fk_consent_capacity_assessment_icf_version_id`;

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` DROP CONSTRAINT IF EXISTS `fk_consent_icf_amendment_icf_version_id`;

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` DROP CONSTRAINT IF EXISTS `fk_randomization_subject_randomization_icf_version_id`;

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` DROP CONSTRAINT IF EXISTS `fk_randomization_kit_assignment_visit_id`;

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` DROP CONSTRAINT IF EXISTS `fk_randomization_blinding_config_icf_version_id`;

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` DROP CONSTRAINT IF EXISTS `fk_randomization_unblinding_request_lab_result_id`;

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` DROP CONSTRAINT IF EXISTS `fk_compliance_audit_finding_capa_id`;

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` DROP CONSTRAINT IF EXISTS `fk_compliance_inspection_finding_capa_id`;

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` DROP CONSTRAINT IF EXISTS `fk_compliance_inspection_finding_deviation_id`;

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` DROP CONSTRAINT IF EXISTS `fk_compliance_inspection_finding_lab_result_id`;

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` DROP CONSTRAINT IF EXISTS `fk_compliance_protocol_deviation_capa_id`;

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` DROP CONSTRAINT IF EXISTS `fk_compliance_protocol_deviation_visit_id`;

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` DROP CONSTRAINT IF EXISTS `fk_compliance_quality_event_capa_id`;

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` DROP CONSTRAINT IF EXISTS `fk_compliance_quality_event_deviation_id`;

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` DROP CONSTRAINT IF EXISTS `fk_compliance_quality_event_lab_result_id`;

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` DROP CONSTRAINT IF EXISTS `fk_compliance_quality_event_visit_id`;

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` DROP CONSTRAINT IF EXISTS `fk_compliance_risk_assessment_capa_id`;

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` DROP CONSTRAINT IF EXISTS `fk_compliance_ethics_submission_icf_version_id`;
