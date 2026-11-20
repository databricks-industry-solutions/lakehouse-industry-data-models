-- Cross-Domain Foreign Keys for Business: Clinical_Trials | Version: v2_mvm
-- Generated on: 2026-11-20 12:39:49
-- Total cross-domain FK constraints: 166

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ADD CONSTRAINT `fk_compliance_ethics_submission_icf_version_id` FOREIGN KEY (`icf_version_id`) REFERENCES `clinical_trials_mvm`.`consent`.`icf_version`(`icf_version_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ADD CONSTRAINT `fk_compliance_capa_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ADD CONSTRAINT `fk_compliance_inspection_finding_lab_result_id` FOREIGN KEY (`lab_result_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_result`(`lab_result_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ADD CONSTRAINT `fk_compliance_capa_bioanalytical_assay_id` FOREIGN KEY (`bioanalytical_assay_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`bioanalytical_assay`(`bioanalytical_assay_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ADD CONSTRAINT `fk_compliance_capa_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_lab_result_id` FOREIGN KEY (`lab_result_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_result`(`lab_result_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ADD CONSTRAINT `fk_compliance_capa_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ADD CONSTRAINT `fk_compliance_capa_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ADD CONSTRAINT `fk_compliance_capa_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`capa` ADD CONSTRAINT `fk_compliance_capa_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ADD CONSTRAINT `fk_compliance_inspection_finding_deviation_id` FOREIGN KEY (`deviation_id`) REFERENCES `clinical_trials_mvm`.`subject`.`deviation`(`deviation_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_visit_id` FOREIGN KEY (`visit_id`) REFERENCES `clinical_trials_mvm`.`subject`.`visit`(`visit_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_deviation_id` FOREIGN KEY (`deviation_id`) REFERENCES `clinical_trials_mvm`.`subject`.`deviation`(`deviation_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_visit_id` FOREIGN KEY (`visit_id`) REFERENCES `clinical_trials_mvm`.`subject`.`visit`(`visit_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ADD CONSTRAINT `fk_consent_icf_version_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ADD CONSTRAINT `fk_consent_icf_version_approval_workflow_id` FOREIGN KEY (`approval_workflow_id`) REFERENCES `clinical_trials_mvm`.`document`.`workflow`(`workflow_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ADD CONSTRAINT `fk_consent_icf_version_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ADD CONSTRAINT `fk_consent_icf_version_version_id` FOREIGN KEY (`version_id`) REFERENCES `clinical_trials_mvm`.`document`.`version`(`version_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ADD CONSTRAINT `fk_consent_icf_version_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ADD CONSTRAINT `fk_consent_icf_version_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ADD CONSTRAINT `fk_consent_icf_version_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ADD CONSTRAINT `fk_consent_icf_version_country_id` FOREIGN KEY (`country_id`) REFERENCES `clinical_trials_mvm`.`study`.`country`(`country_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ADD CONSTRAINT `fk_consent_icf_version_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ADD CONSTRAINT `fk_consent_icf_version_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_version` ADD CONSTRAINT `fk_consent_icf_version_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ADD CONSTRAINT `fk_datamanagement_ecrf_form_icf_version_id` FOREIGN KEY (`icf_version_id`) REFERENCES `clinical_trials_mvm`.`consent`.`icf_version`(`icf_version_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ADD CONSTRAINT `fk_datamanagement_field_entry_lab_result_id` FOREIGN KEY (`lab_result_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_result`(`lab_result_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ADD CONSTRAINT `fk_datamanagement_discrepancy_query_lab_result_id` FOREIGN KEY (`lab_result_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_result`(`lab_result_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ADD CONSTRAINT `fk_datamanagement_subject_visit_data_visit_id` FOREIGN KEY (`visit_id`) REFERENCES `clinical_trials_mvm`.`subject`.`visit`(`visit_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ADD CONSTRAINT `fk_datamanagement_field_entry_visit_id` FOREIGN KEY (`visit_id`) REFERENCES `clinical_trials_mvm`.`subject`.`visit`(`visit_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_result` ADD CONSTRAINT `fk_laboratory_lab_result_analysis_population_id` FOREIGN KEY (`analysis_population_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`analysis_population`(`analysis_population_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_result` ADD CONSTRAINT `fk_laboratory_lab_result_database_lock_event_id` FOREIGN KEY (`database_lock_event_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`database_lock_event`(`database_lock_event_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_result` ADD CONSTRAINT `fk_laboratory_lab_result_statistical_endpoint_id` FOREIGN KEY (`statistical_endpoint_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint`(`statistical_endpoint_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen` ADD CONSTRAINT `fk_laboratory_specimen_icf_version_id` FOREIGN KEY (`icf_version_id`) REFERENCES `clinical_trials_mvm`.`consent`.`icf_version`(`icf_version_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_result` ADD CONSTRAINT `fk_laboratory_lab_result_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_mvm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_result` ADD CONSTRAINT `fk_laboratory_lab_result_icf_version_id` FOREIGN KEY (`icf_version_id`) REFERENCES `clinical_trials_mvm`.`consent`.`icf_version`(`icf_version_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_collection` ADD CONSTRAINT `fk_laboratory_specimen_collection_icf_version_id` FOREIGN KEY (`icf_version_id`) REFERENCES `clinical_trials_mvm`.`consent`.`icf_version`(`icf_version_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`pk_sample` ADD CONSTRAINT `fk_laboratory_pk_sample_icf_version_id` FOREIGN KEY (`icf_version_id`) REFERENCES `clinical_trials_mvm`.`consent`.`icf_version`(`icf_version_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`bioanalytical_result` ADD CONSTRAINT `fk_laboratory_bioanalytical_result_icf_version_id` FOREIGN KEY (`icf_version_id`) REFERENCES `clinical_trials_mvm`.`consent`.`icf_version`(`icf_version_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_aliquot` ADD CONSTRAINT `fk_laboratory_specimen_aliquot_icf_version_id` FOREIGN KEY (`icf_version_id`) REFERENCES `clinical_trials_mvm`.`consent`.`icf_version`(`icf_version_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_result` ADD CONSTRAINT `fk_laboratory_lab_result_primary_laboratory_ehr_source_system_id` FOREIGN KEY (`primary_laboratory_ehr_source_system_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`ehr_source_system`(`ehr_source_system_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_result` ADD CONSTRAINT `fk_laboratory_lab_result_source_ehr_source_system_id` FOREIGN KEY (`source_ehr_source_system_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`ehr_source_system`(`ehr_source_system_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_result` ADD CONSTRAINT `fk_laboratory_lab_result_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_result` ADD CONSTRAINT `fk_laboratory_lab_result_principal_investigator_id` FOREIGN KEY (`principal_investigator_id`) REFERENCES `clinical_trials_mvm`.`site`.`principal_investigator`(`principal_investigator_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_result` ADD CONSTRAINT `fk_laboratory_lab_result_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_result` ADD CONSTRAINT `fk_laboratory_lab_result_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_mvm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_result` ADD CONSTRAINT `fk_laboratory_lab_result_epoch_id` FOREIGN KEY (`epoch_id`) REFERENCES `clinical_trials_mvm`.`study`.`epoch`(`epoch_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_result` ADD CONSTRAINT `fk_laboratory_lab_result_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_result` ADD CONSTRAINT `fk_laboratory_lab_result_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_result` ADD CONSTRAINT `fk_laboratory_lab_result_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_result` ADD CONSTRAINT `fk_laboratory_lab_result_study_visit_schedule_id` FOREIGN KEY (`study_visit_schedule_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_visit_schedule`(`study_visit_schedule_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen` ADD CONSTRAINT `fk_laboratory_specimen_visit_id` FOREIGN KEY (`visit_id`) REFERENCES `clinical_trials_mvm`.`subject`.`visit`(`visit_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_result` ADD CONSTRAINT `fk_laboratory_lab_result_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_result` ADD CONSTRAINT `fk_laboratory_lab_result_visit_id` FOREIGN KEY (`visit_id`) REFERENCES `clinical_trials_mvm`.`subject`.`visit`(`visit_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_collection` ADD CONSTRAINT `fk_laboratory_specimen_collection_visit_id` FOREIGN KEY (`visit_id`) REFERENCES `clinical_trials_mvm`.`subject`.`visit`(`visit_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`pk_sample` ADD CONSTRAINT `fk_laboratory_pk_sample_visit_id` FOREIGN KEY (`visit_id`) REFERENCES `clinical_trials_mvm`.`subject`.`visit`(`visit_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_query` ADD CONSTRAINT `fk_laboratory_lab_query_visit_id` FOREIGN KEY (`visit_id`) REFERENCES `clinical_trials_mvm`.`subject`.`visit`(`visit_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_aliquot` ADD CONSTRAINT `fk_laboratory_specimen_aliquot_visit_id` FOREIGN KEY (`visit_id`) REFERENCES `clinical_trials_mvm`.`subject`.`visit`(`visit_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_capa_id` FOREIGN KEY (`capa_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`capa`(`capa_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`action_item` ADD CONSTRAINT `fk_monitoring_action_item_capa_id` FOREIGN KEY (`capa_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`capa`(`capa_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`action_item` ADD CONSTRAINT `fk_monitoring_action_item_protocol_deviation_id` FOREIGN KEY (`protocol_deviation_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`protocol_deviation`(`protocol_deviation_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`site_risk_assessment` ADD CONSTRAINT `fk_monitoring_site_risk_assessment_capa_id` FOREIGN KEY (`capa_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`capa`(`capa_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`ip_accountability_log` ADD CONSTRAINT `fk_monitoring_ip_accountability_log_capa_id` FOREIGN KEY (`capa_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`capa`(`capa_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_capa_id` FOREIGN KEY (`capa_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`capa`(`capa_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_report` ADD CONSTRAINT `fk_monitoring_visit_report_icf_version_id` FOREIGN KEY (`icf_version_id`) REFERENCES `clinical_trials_mvm`.`consent`.`icf_version`(`icf_version_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_icf_version_id` FOREIGN KEY (`icf_version_id`) REFERENCES `clinical_trials_mvm`.`consent`.`icf_version`(`icf_version_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_icf_version_id` FOREIGN KEY (`icf_version_id`) REFERENCES `clinical_trials_mvm`.`consent`.`icf_version`(`icf_version_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_icf_version_id` FOREIGN KEY (`icf_version_id`) REFERENCES `clinical_trials_mvm`.`consent`.`icf_version`(`icf_version_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`action_item` ADD CONSTRAINT `fk_monitoring_action_item_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_mvm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`risk_indicator` ADD CONSTRAINT `fk_monitoring_risk_indicator_icf_version_id` FOREIGN KEY (`icf_version_id`) REFERENCES `clinical_trials_mvm`.`consent`.`icf_version`(`icf_version_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_checklist` ADD CONSTRAINT `fk_monitoring_visit_checklist_icf_version_id` FOREIGN KEY (`icf_version_id`) REFERENCES `clinical_trials_mvm`.`consent`.`icf_version`(`icf_version_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`action_item` ADD CONSTRAINT `fk_monitoring_action_item_document_sop_id` FOREIGN KEY (`document_sop_id`) REFERENCES `clinical_trials_mvm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`action_item` ADD CONSTRAINT `fk_monitoring_action_item_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_lab_result_id` FOREIGN KEY (`lab_result_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_result`(`lab_result_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_lab_result_id` FOREIGN KEY (`lab_result_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_result`(`lab_result_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_lab_result_id` FOREIGN KEY (`lab_result_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_result`(`lab_result_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`action_item` ADD CONSTRAINT `fk_monitoring_action_item_specimen_collection_id` FOREIGN KEY (`specimen_collection_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`specimen_collection`(`specimen_collection_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_lab_result_id` FOREIGN KEY (`lab_result_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_result`(`lab_result_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`action_item` ADD CONSTRAINT `fk_monitoring_action_item_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`action_item` ADD CONSTRAINT `fk_monitoring_action_item_assigned_principal_investigator_id` FOREIGN KEY (`assigned_principal_investigator_id`) REFERENCES `clinical_trials_mvm`.`site`.`principal_investigator`(`principal_investigator_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`action_item` ADD CONSTRAINT `fk_monitoring_action_item_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`action_item` ADD CONSTRAINT `fk_monitoring_action_item_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_visit_id` FOREIGN KEY (`visit_id`) REFERENCES `clinical_trials_mvm`.`subject`.`visit`(`visit_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_deviation_id` FOREIGN KEY (`deviation_id`) REFERENCES `clinical_trials_mvm`.`subject`.`deviation`(`deviation_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_visit_id` FOREIGN KEY (`visit_id`) REFERENCES `clinical_trials_mvm`.`subject`.`visit`(`visit_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_deviation_id` FOREIGN KEY (`deviation_id`) REFERENCES `clinical_trials_mvm`.`subject`.`deviation`(`deviation_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`action_item` ADD CONSTRAINT `fk_monitoring_action_item_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ADD CONSTRAINT `fk_randomization_subject_randomization_icf_version_id` FOREIGN KEY (`icf_version_id`) REFERENCES `clinical_trials_mvm`.`consent`.`icf_version`(`icf_version_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ADD CONSTRAINT `fk_randomization_blinding_config_icf_version_id` FOREIGN KEY (`icf_version_id`) REFERENCES `clinical_trials_mvm`.`consent`.`icf_version`(`icf_version_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ADD CONSTRAINT `fk_randomization_unblinding_request_lab_result_id` FOREIGN KEY (`lab_result_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_result`(`lab_result_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ADD CONSTRAINT `fk_randomization_kit_assignment_visit_id` FOREIGN KEY (`visit_id`) REFERENCES `clinical_trials_mvm`.`subject`.`visit`(`visit_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ADD CONSTRAINT `fk_safety_adverse_event_adverse_severity_codelist_term_id` FOREIGN KEY (`adverse_severity_codelist_term_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`codelist_term`(`codelist_term_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ADD CONSTRAINT `fk_safety_adverse_event_adverse_outcome_codelist_term_id` FOREIGN KEY (`adverse_outcome_codelist_term_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`codelist_term`(`codelist_term_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ADD CONSTRAINT `fk_safety_adverse_event_adverse_action_taken_codelist_term_id` FOREIGN KEY (`adverse_action_taken_codelist_term_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`codelist_term`(`codelist_term_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ADD CONSTRAINT `fk_safety_serious_adverse_event_lab_result_id` FOREIGN KEY (`lab_result_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_result`(`lab_result_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ADD CONSTRAINT `fk_safety_causality_assessment_lab_result_id` FOREIGN KEY (`lab_result_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_result`(`lab_result_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ADD CONSTRAINT `fk_safety_ae_follow_up_lab_result_id` FOREIGN KEY (`lab_result_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_result`(`lab_result_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ADD CONSTRAINT `fk_safety_adverse_event_visit_id` FOREIGN KEY (`visit_id`) REFERENCES `clinical_trials_mvm`.`subject`.`visit`(`visit_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ADD CONSTRAINT `fk_safety_causality_assessment_visit_id` FOREIGN KEY (`visit_id`) REFERENCES `clinical_trials_mvm`.`subject`.`visit`(`visit_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ADD CONSTRAINT `fk_safety_narrative_visit_id` FOREIGN KEY (`visit_id`) REFERENCES `clinical_trials_mvm`.`subject`.`visit`(`visit_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ADD CONSTRAINT `fk_safety_ae_follow_up_visit_id` FOREIGN KEY (`visit_id`) REFERENCES `clinical_trials_mvm`.`subject`.`visit`(`visit_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`agreement` ADD CONSTRAINT `fk_site_agreement_audit_id` FOREIGN KEY (`audit_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`audit`(`audit_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`closeout` ADD CONSTRAINT `fk_site_closeout_capa_id` FOREIGN KEY (`capa_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`capa`(`capa_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`agreement` ADD CONSTRAINT `fk_site_agreement_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`agreement` ADD CONSTRAINT `fk_site_agreement_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`agreement` ADD CONSTRAINT `fk_site_agreement_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`agreement` ADD CONSTRAINT `fk_site_agreement_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`agreement` ADD CONSTRAINT `fk_site_agreement_country_id` FOREIGN KEY (`country_id`) REFERENCES `clinical_trials_mvm`.`study`.`country`(`country_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`agreement` ADD CONSTRAINT `fk_site_agreement_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`agreement` ADD CONSTRAINT `fk_site_agreement_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`deviation` ADD CONSTRAINT `fk_subject_deviation_capa_id` FOREIGN KEY (`capa_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`capa`(`capa_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`deviation` ADD CONSTRAINT `fk_subject_deviation_ethics_submission_id` FOREIGN KEY (`ethics_submission_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`ethics_submission`(`ethics_submission_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`status_history` ADD CONSTRAINT `fk_subject_status_history_protocol_deviation_id` FOREIGN KEY (`protocol_deviation_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`protocol_deviation`(`protocol_deviation_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`visit` ADD CONSTRAINT `fk_subject_visit_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_mvm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`eligibility_assessment` ADD CONSTRAINT `fk_subject_eligibility_assessment_icf_version_id` FOREIGN KEY (`icf_version_id`) REFERENCES `clinical_trials_mvm`.`consent`.`icf_version`(`icf_version_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`status_history` ADD CONSTRAINT `fk_subject_status_history_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_mvm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`visit` ADD CONSTRAINT `fk_subject_visit_ecrf_form_id` FOREIGN KEY (`ecrf_form_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`ecrf_form`(`ecrf_form_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`demographic` ADD CONSTRAINT `fk_subject_demographic_sex_codelist_term_id` FOREIGN KEY (`sex_codelist_term_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`codelist_term`(`codelist_term_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`demographic` ADD CONSTRAINT `fk_subject_demographic_race_codelist_term_id` FOREIGN KEY (`race_codelist_term_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`codelist_term`(`codelist_term_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`demographic` ADD CONSTRAINT `fk_subject_demographic_ethnicity_codelist_term_id` FOREIGN KEY (`ethnicity_codelist_term_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`codelist_term`(`codelist_term_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`demographic` ADD CONSTRAINT `fk_subject_demographic_age_unit_codelist_term_id` FOREIGN KEY (`age_unit_codelist_term_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`codelist_term`(`codelist_term_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`deviation` ADD CONSTRAINT `fk_subject_deviation_document_sop_id` FOREIGN KEY (`document_sop_id`) REFERENCES `clinical_trials_mvm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`deviation` ADD CONSTRAINT `fk_subject_deviation_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`deviation` ADD CONSTRAINT `fk_subject_deviation_workflow_id` FOREIGN KEY (`workflow_id`) REFERENCES `clinical_trials_mvm`.`document`.`workflow`(`workflow_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`status_history` ADD CONSTRAINT `fk_subject_status_history_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`deviation` ADD CONSTRAINT `fk_subject_deviation_lab_result_id` FOREIGN KEY (`lab_result_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_result`(`lab_result_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`deviation` ADD CONSTRAINT `fk_subject_deviation_specimen_collection_id` FOREIGN KEY (`specimen_collection_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`specimen_collection`(`specimen_collection_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`eligibility_assessment` ADD CONSTRAINT `fk_subject_eligibility_assessment_lab_result_id` FOREIGN KEY (`lab_result_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_result`(`lab_result_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`sdv_review` ADD CONSTRAINT `fk_subject_sdv_review_lab_result_id` FOREIGN KEY (`lab_result_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_result`(`lab_result_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`deviation` ADD CONSTRAINT `fk_subject_deviation_irt_transaction_id` FOREIGN KEY (`irt_transaction_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`irt_transaction`(`irt_transaction_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`deviation` ADD CONSTRAINT `fk_subject_deviation_kit_assignment_id` FOREIGN KEY (`kit_assignment_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`kit_assignment`(`kit_assignment_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`status_history` ADD CONSTRAINT `fk_subject_status_history_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`status_history` ADD CONSTRAINT `fk_subject_status_history_treatment_arm_id` FOREIGN KEY (`treatment_arm_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`treatment_arm`(`treatment_arm_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`status_history` ADD CONSTRAINT `fk_subject_status_history_unblinding_request_id` FOREIGN KEY (`unblinding_request_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`unblinding_request`(`unblinding_request_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`visit` ADD CONSTRAINT `fk_subject_visit_regulatory_protocol_amendment_id` FOREIGN KEY (`regulatory_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment`(`regulatory_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`visit` ADD CONSTRAINT `fk_subject_visit_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`deviation` ADD CONSTRAINT `fk_subject_deviation_regulatory_protocol_amendment_id` FOREIGN KEY (`regulatory_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment`(`regulatory_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`deviation` ADD CONSTRAINT `fk_subject_deviation_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`status_history` ADD CONSTRAINT `fk_subject_status_history_regulatory_protocol_amendment_id` FOREIGN KEY (`regulatory_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment`(`regulatory_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`deviation` ADD CONSTRAINT `fk_subject_deviation_serious_adverse_event_id` FOREIGN KEY (`serious_adverse_event_id`) REFERENCES `clinical_trials_mvm`.`safety`.`serious_adverse_event`(`serious_adverse_event_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`deviation` ADD CONSTRAINT `fk_subject_deviation_susar_id` FOREIGN KEY (`susar_id`) REFERENCES `clinical_trials_mvm`.`safety`.`susar`(`susar_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`status_history` ADD CONSTRAINT `fk_subject_status_history_serious_adverse_event_id` FOREIGN KEY (`serious_adverse_event_id`) REFERENCES `clinical_trials_mvm`.`safety`.`serious_adverse_event`(`serious_adverse_event_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`status_history` ADD CONSTRAINT `fk_subject_status_history_susar_id` FOREIGN KEY (`susar_id`) REFERENCES `clinical_trials_mvm`.`safety`.`susar`(`susar_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`enrollment` ADD CONSTRAINT `fk_subject_enrollment_agreement_id` FOREIGN KEY (`agreement_id`) REFERENCES `clinical_trials_mvm`.`site`.`agreement`(`agreement_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`visit` ADD CONSTRAINT `fk_subject_visit_principal_investigator_id` FOREIGN KEY (`principal_investigator_id`) REFERENCES `clinical_trials_mvm`.`site`.`principal_investigator`(`principal_investigator_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`visit` ADD CONSTRAINT `fk_subject_visit_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`deviation` ADD CONSTRAINT `fk_subject_deviation_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`deviation` ADD CONSTRAINT `fk_subject_deviation_irb_iec_approval_id` FOREIGN KEY (`irb_iec_approval_id`) REFERENCES `clinical_trials_mvm`.`site`.`irb_iec_approval`(`irb_iec_approval_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`deviation` ADD CONSTRAINT `fk_subject_deviation_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`status_history` ADD CONSTRAINT `fk_subject_status_history_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`visit` ADD CONSTRAINT `fk_subject_visit_epoch_id` FOREIGN KEY (`epoch_id`) REFERENCES `clinical_trials_mvm`.`study`.`epoch`(`epoch_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`visit` ADD CONSTRAINT `fk_subject_visit_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`visit` ADD CONSTRAINT `fk_subject_visit_study_visit_schedule_id` FOREIGN KEY (`study_visit_schedule_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_visit_schedule`(`study_visit_schedule_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`deviation` ADD CONSTRAINT `fk_subject_deviation_eligibility_criterion_id` FOREIGN KEY (`eligibility_criterion_id`) REFERENCES `clinical_trials_mvm`.`study`.`eligibility_criterion`(`eligibility_criterion_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`deviation` ADD CONSTRAINT `fk_subject_deviation_epoch_id` FOREIGN KEY (`epoch_id`) REFERENCES `clinical_trials_mvm`.`study`.`epoch`(`epoch_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`deviation` ADD CONSTRAINT `fk_subject_deviation_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`status_history` ADD CONSTRAINT `fk_subject_status_history_epoch_id` FOREIGN KEY (`epoch_id`) REFERENCES `clinical_trials_mvm`.`study`.`epoch`(`epoch_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`status_history` ADD CONSTRAINT `fk_subject_status_history_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`deviation` ADD CONSTRAINT `fk_subject_deviation_dispensing_record_id` FOREIGN KEY (`dispensing_record_id`) REFERENCES `clinical_trials_mvm`.`supply`.`dispensing_record`(`dispensing_record_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`deviation` ADD CONSTRAINT `fk_subject_deviation_kit_inventory_id` FOREIGN KEY (`kit_inventory_id`) REFERENCES `clinical_trials_mvm`.`supply`.`kit_inventory`(`kit_inventory_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ADD CONSTRAINT `fk_supply_manufacture_batch_capa_id` FOREIGN KEY (`capa_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`capa`(`capa_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ADD CONSTRAINT `fk_supply_temperature_excursion_capa_id` FOREIGN KEY (`capa_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`capa`(`capa_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ADD CONSTRAINT `fk_supply_dispensing_record_icf_version_id` FOREIGN KEY (`icf_version_id`) REFERENCES `clinical_trials_mvm`.`consent`.`icf_version`(`icf_version_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ADD CONSTRAINT `fk_supply_dispensing_record_visit_id` FOREIGN KEY (`visit_id`) REFERENCES `clinical_trials_mvm`.`subject`.`visit`(`visit_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ADD CONSTRAINT `fk_supply_return_record_deviation_id` FOREIGN KEY (`deviation_id`) REFERENCES `clinical_trials_mvm`.`subject`.`deviation`(`deviation_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ADD CONSTRAINT `fk_supply_return_record_visit_id` FOREIGN KEY (`visit_id`) REFERENCES `clinical_trials_mvm`.`subject`.`visit`(`visit_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ADD CONSTRAINT `fk_study_protocol_document_sop_id` FOREIGN KEY (`document_sop_id`) REFERENCES `clinical_trials_mvm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ADD CONSTRAINT `fk_study_protocol_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ADD CONSTRAINT `fk_study_protocol_regulatory_binder_id` FOREIGN KEY (`regulatory_binder_id`) REFERENCES `clinical_trials_mvm`.`document`.`regulatory_binder`(`regulatory_binder_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ADD CONSTRAINT `fk_study_protocol_tmf_artifact_id` FOREIGN KEY (`tmf_artifact_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_artifact`(`tmf_artifact_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`protocol` ADD CONSTRAINT `fk_study_protocol_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ADD CONSTRAINT `fk_study_study_protocol_amendment_amendment_regulatory_binder_id` FOREIGN KEY (`amendment_regulatory_binder_id`) REFERENCES `clinical_trials_mvm`.`document`.`regulatory_binder`(`regulatory_binder_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ADD CONSTRAINT `fk_study_study_protocol_amendment_amendment_tmf_document_id` FOREIGN KEY (`amendment_tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ADD CONSTRAINT `fk_study_study_protocol_amendment_rand_scheme_id` FOREIGN KEY (`rand_scheme_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_scheme`(`rand_scheme_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ADD CONSTRAINT `fk_study_study_protocol_amendment_regulatory_protocol_amendment_id` FOREIGN KEY (`regulatory_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment`(`regulatory_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`study_protocol_amendment` ADD CONSTRAINT `fk_study_study_protocol_amendment_tmf_artifact_id` FOREIGN KEY (`tmf_artifact_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_artifact`(`tmf_artifact_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`arm` ADD CONSTRAINT `fk_study_arm_rand_scheme_id` FOREIGN KEY (`rand_scheme_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_scheme`(`rand_scheme_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`study_visit_schedule` ADD CONSTRAINT `fk_study_study_visit_schedule_codelist_id` FOREIGN KEY (`codelist_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`codelist`(`codelist_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`epoch` ADD CONSTRAINT `fk_study_epoch_codelist_id` FOREIGN KEY (`codelist_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`codelist`(`codelist_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ADD CONSTRAINT `fk_study_country_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ADD CONSTRAINT `fk_study_country_cta_regulatory_binder_id` FOREIGN KEY (`cta_regulatory_binder_id`) REFERENCES `clinical_trials_mvm`.`document`.`regulatory_binder`(`regulatory_binder_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ADD CONSTRAINT `fk_study_country_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`country` ADD CONSTRAINT `fk_study_country_rand_scheme_id` FOREIGN KEY (`rand_scheme_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_scheme`(`rand_scheme_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ADD CONSTRAINT `fk_study_investigational_product_country_registration_id` FOREIGN KEY (`country_registration_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`country_registration`(`country_registration_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ADD CONSTRAINT `fk_study_investigational_product_imp_tmf_document_id` FOREIGN KEY (`imp_tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ADD CONSTRAINT `fk_study_investigational_product_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`investigational_product` ADD CONSTRAINT `fk_study_investigational_product_nda_bla_application_id` FOREIGN KEY (`nda_bla_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`nda_bla_application`(`nda_bla_application_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ADD CONSTRAINT `fk_study_dosing_regimen_codelist_id` FOREIGN KEY (`codelist_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`codelist`(`codelist_id`);

ALTER TABLE `clinical_trials_mvm`.`study`.`dosing_regimen` ADD CONSTRAINT `fk_study_dosing_regimen_treatment_arm_id` FOREIGN KEY (`treatment_arm_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`treatment_arm`(`treatment_arm_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`investigational_site` ADD CONSTRAINT `fk_site_investigational_site_local_lab_facility_id` FOREIGN KEY (`local_lab_facility_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`feasibility_assessment` ADD CONSTRAINT `fk_site_feasibility_assessment_country_id` FOREIGN KEY (`country_id`) REFERENCES `clinical_trials_mvm`.`study`.`country`(`country_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`feasibility_assessment` ADD CONSTRAINT `fk_site_feasibility_assessment_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`feasibility_assessment` ADD CONSTRAINT `fk_site_feasibility_assessment_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`feasibility_assessment` ADD CONSTRAINT `fk_site_feasibility_assessment_sample_size_calc_id` FOREIGN KEY (`sample_size_calc_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`sample_size_calc`(`sample_size_calc_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`feasibility_assessment` ADD CONSTRAINT `fk_site_feasibility_assessment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`feasibility_assessment` ADD CONSTRAINT `fk_site_feasibility_assessment_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`selection` ADD CONSTRAINT `fk_site_selection_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`selection` ADD CONSTRAINT `fk_site_selection_country_id` FOREIGN KEY (`country_id`) REFERENCES `clinical_trials_mvm`.`study`.`country`(`country_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`selection` ADD CONSTRAINT `fk_site_selection_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`selection` ADD CONSTRAINT `fk_site_selection_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`selection` ADD CONSTRAINT `fk_site_selection_risk_assessment_id` FOREIGN KEY (`risk_assessment_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`risk_assessment`(`risk_assessment_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`selection` ADD CONSTRAINT `fk_site_selection_sample_size_calc_id` FOREIGN KEY (`sample_size_calc_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`sample_size_calc`(`sample_size_calc_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`selection` ADD CONSTRAINT `fk_site_selection_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`selection` ADD CONSTRAINT `fk_site_selection_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`study_site` ADD CONSTRAINT `fk_site_study_site_audit_id` FOREIGN KEY (`audit_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`audit`(`audit_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`study_site` ADD CONSTRAINT `fk_site_study_site_central_lab_facility_id` FOREIGN KEY (`central_lab_facility_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`study_site` ADD CONSTRAINT `fk_site_study_site_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`study_site` ADD CONSTRAINT `fk_site_study_site_country_id` FOREIGN KEY (`country_id`) REFERENCES `clinical_trials_mvm`.`study`.`country`(`country_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`study_site` ADD CONSTRAINT `fk_site_study_site_primary_depot_id` FOREIGN KEY (`primary_depot_id`) REFERENCES `clinical_trials_mvm`.`supply`.`depot`(`depot_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`study_site` ADD CONSTRAINT `fk_site_study_site_rand_list_id` FOREIGN KEY (`rand_list_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_list`(`rand_list_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`study_site` ADD CONSTRAINT `fk_site_study_site_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`activation` ADD CONSTRAINT `fk_site_activation_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`activation` ADD CONSTRAINT `fk_site_activation_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`activation` ADD CONSTRAINT `fk_site_activation_country_id` FOREIGN KEY (`country_id`) REFERENCES `clinical_trials_mvm`.`study`.`country`(`country_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`activation` ADD CONSTRAINT `fk_site_activation_ethics_approval_id` FOREIGN KEY (`ethics_approval_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`ethics_approval`(`ethics_approval_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`activation` ADD CONSTRAINT `fk_site_activation_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`activation` ADD CONSTRAINT `fk_site_activation_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`activation` ADD CONSTRAINT `fk_site_activation_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`activation` ADD CONSTRAINT `fk_site_activation_rand_scheme_id` FOREIGN KEY (`rand_scheme_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_scheme`(`rand_scheme_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`activation` ADD CONSTRAINT `fk_site_activation_regulatory_approval_id` FOREIGN KEY (`regulatory_approval_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`approval`(`approval_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`activation` ADD CONSTRAINT `fk_site_activation_sample_size_calc_id` FOREIGN KEY (`sample_size_calc_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`sample_size_calc`(`sample_size_calc_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`activation` ADD CONSTRAINT `fk_site_activation_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`activation` ADD CONSTRAINT `fk_site_activation_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`irb_iec_approval` ADD CONSTRAINT `fk_site_irb_iec_approval_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`irb_iec_approval` ADD CONSTRAINT `fk_site_irb_iec_approval_ethics_approval_id` FOREIGN KEY (`ethics_approval_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`ethics_approval`(`ethics_approval_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`irb_iec_approval` ADD CONSTRAINT `fk_site_irb_iec_approval_ethics_committee_id` FOREIGN KEY (`ethics_committee_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`ethics_committee`(`ethics_committee_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`irb_iec_approval` ADD CONSTRAINT `fk_site_irb_iec_approval_ethics_submission_id` FOREIGN KEY (`ethics_submission_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`ethics_submission`(`ethics_submission_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`irb_iec_approval` ADD CONSTRAINT `fk_site_irb_iec_approval_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`irb_iec_approval` ADD CONSTRAINT `fk_site_irb_iec_approval_regulatory_protocol_amendment_id` FOREIGN KEY (`regulatory_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment`(`regulatory_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`irb_iec_approval` ADD CONSTRAINT `fk_site_irb_iec_approval_site_file_id` FOREIGN KEY (`site_file_id`) REFERENCES `clinical_trials_mvm`.`document`.`site_file`(`site_file_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`irb_iec_approval` ADD CONSTRAINT `fk_site_irb_iec_approval_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`regulatory_submission_site` ADD CONSTRAINT `fk_site_regulatory_submission_site_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`regulatory_submission_site` ADD CONSTRAINT `fk_site_regulatory_submission_site_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`regulatory_submission_site` ADD CONSTRAINT `fk_site_regulatory_submission_site_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`regulatory_submission_site` ADD CONSTRAINT `fk_site_regulatory_submission_site_country_id` FOREIGN KEY (`country_id`) REFERENCES `clinical_trials_mvm`.`study`.`country`(`country_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`regulatory_submission_site` ADD CONSTRAINT `fk_site_regulatory_submission_site_ethics_committee_id` FOREIGN KEY (`ethics_committee_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`ethics_committee`(`ethics_committee_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`regulatory_submission_site` ADD CONSTRAINT `fk_site_regulatory_submission_site_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`regulatory_submission_site` ADD CONSTRAINT `fk_site_regulatory_submission_site_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`regulatory_submission_site` ADD CONSTRAINT `fk_site_regulatory_submission_site_regulatory_binder_id` FOREIGN KEY (`regulatory_binder_id`) REFERENCES `clinical_trials_mvm`.`document`.`regulatory_binder`(`regulatory_binder_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`regulatory_submission_site` ADD CONSTRAINT `fk_site_regulatory_submission_site_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`regulatory_submission_site` ADD CONSTRAINT `fk_site_regulatory_submission_site_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`regulatory_submission_site` ADD CONSTRAINT `fk_site_regulatory_submission_site_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`initiation_visit` ADD CONSTRAINT `fk_site_initiation_visit_audit_id` FOREIGN KEY (`audit_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`audit`(`audit_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`initiation_visit` ADD CONSTRAINT `fk_site_initiation_visit_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`initiation_visit` ADD CONSTRAINT `fk_site_initiation_visit_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`initiation_visit` ADD CONSTRAINT `fk_site_initiation_visit_ethics_approval_id` FOREIGN KEY (`ethics_approval_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`ethics_approval`(`ethics_approval_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`initiation_visit` ADD CONSTRAINT `fk_site_initiation_visit_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`initiation_visit` ADD CONSTRAINT `fk_site_initiation_visit_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`initiation_visit` ADD CONSTRAINT `fk_site_initiation_visit_monitoring_visit_schedule_id` FOREIGN KEY (`monitoring_visit_schedule_id`) REFERENCES `clinical_trials_mvm`.`monitoring`.`monitoring_visit_schedule`(`monitoring_visit_schedule_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`initiation_visit` ADD CONSTRAINT `fk_site_initiation_visit_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`initiation_visit` ADD CONSTRAINT `fk_site_initiation_visit_regulatory_protocol_amendment_id` FOREIGN KEY (`regulatory_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment`(`regulatory_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`initiation_visit` ADD CONSTRAINT `fk_site_initiation_visit_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`initiation_visit` ADD CONSTRAINT `fk_site_initiation_visit_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`enrollment_performance` ADD CONSTRAINT `fk_site_enrollment_performance_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_mvm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`enrollment_performance` ADD CONSTRAINT `fk_site_enrollment_performance_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`enrollment_performance` ADD CONSTRAINT `fk_site_enrollment_performance_country_id` FOREIGN KEY (`country_id`) REFERENCES `clinical_trials_mvm`.`study`.`country`(`country_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`enrollment_performance` ADD CONSTRAINT `fk_site_enrollment_performance_dmp_id` FOREIGN KEY (`dmp_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`dmp`(`dmp_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`enrollment_performance` ADD CONSTRAINT `fk_site_enrollment_performance_ethics_approval_id` FOREIGN KEY (`ethics_approval_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`ethics_approval`(`ethics_approval_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`enrollment_performance` ADD CONSTRAINT `fk_site_enrollment_performance_interim_analysis_id` FOREIGN KEY (`interim_analysis_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`interim_analysis`(`interim_analysis_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`enrollment_performance` ADD CONSTRAINT `fk_site_enrollment_performance_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`enrollment_performance` ADD CONSTRAINT `fk_site_enrollment_performance_risk_assessment_id` FOREIGN KEY (`risk_assessment_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`risk_assessment`(`risk_assessment_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`enrollment_performance` ADD CONSTRAINT `fk_site_enrollment_performance_site_risk_assessment_id` FOREIGN KEY (`site_risk_assessment_id`) REFERENCES `clinical_trials_mvm`.`monitoring`.`site_risk_assessment`(`site_risk_assessment_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`enrollment_performance` ADD CONSTRAINT `fk_site_enrollment_performance_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`enrollment_performance` ADD CONSTRAINT `fk_site_enrollment_performance_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`site_cra_assignment` ADD CONSTRAINT `fk_site_site_cra_assignment_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`site_cra_assignment` ADD CONSTRAINT `fk_site_site_cra_assignment_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`site_cra_assignment` ADD CONSTRAINT `fk_site_site_cra_assignment_dmp_id` FOREIGN KEY (`dmp_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`dmp`(`dmp_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`site_cra_assignment` ADD CONSTRAINT `fk_site_site_cra_assignment_monitoring_cra_assignment_id` FOREIGN KEY (`monitoring_cra_assignment_id`) REFERENCES `clinical_trials_mvm`.`monitoring`.`monitoring_cra_assignment`(`monitoring_cra_assignment_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`site_cra_assignment` ADD CONSTRAINT `fk_site_site_cra_assignment_monitoring_plan_id` FOREIGN KEY (`monitoring_plan_id`) REFERENCES `clinical_trials_mvm`.`monitoring`.`monitoring_plan`(`monitoring_plan_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`site_cra_assignment` ADD CONSTRAINT `fk_site_site_cra_assignment_risk_assessment_id` FOREIGN KEY (`risk_assessment_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`risk_assessment`(`risk_assessment_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`site_cra_assignment` ADD CONSTRAINT `fk_site_site_cra_assignment_site_file_id` FOREIGN KEY (`site_file_id`) REFERENCES `clinical_trials_mvm`.`document`.`site_file`(`site_file_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`site_cra_assignment` ADD CONSTRAINT `fk_site_site_cra_assignment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`closeout` ADD CONSTRAINT `fk_site_closeout_audit_id` FOREIGN KEY (`audit_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`audit`(`audit_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`closeout` ADD CONSTRAINT `fk_site_closeout_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`closeout` ADD CONSTRAINT `fk_site_closeout_database_lock_event_id` FOREIGN KEY (`database_lock_event_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`database_lock_event`(`database_lock_event_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`closeout` ADD CONSTRAINT `fk_site_closeout_dmp_id` FOREIGN KEY (`dmp_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`dmp`(`dmp_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`closeout` ADD CONSTRAINT `fk_site_closeout_dsmb_recommendation_id` FOREIGN KEY (`dsmb_recommendation_id`) REFERENCES `clinical_trials_mvm`.`safety`.`dsmb_recommendation`(`dsmb_recommendation_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`closeout` ADD CONSTRAINT `fk_site_closeout_dsmb_review_id` FOREIGN KEY (`dsmb_review_id`) REFERENCES `clinical_trials_mvm`.`safety`.`dsmb_review`(`dsmb_review_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`closeout` ADD CONSTRAINT `fk_site_closeout_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`closeout` ADD CONSTRAINT `fk_site_closeout_ip_accountability_log_id` FOREIGN KEY (`ip_accountability_log_id`) REFERENCES `clinical_trials_mvm`.`monitoring`.`ip_accountability_log`(`ip_accountability_log_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`closeout` ADD CONSTRAINT `fk_site_closeout_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`closeout` ADD CONSTRAINT `fk_site_closeout_monitoring_plan_id` FOREIGN KEY (`monitoring_plan_id`) REFERENCES `clinical_trials_mvm`.`monitoring`.`monitoring_plan`(`monitoring_plan_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`closeout` ADD CONSTRAINT `fk_site_closeout_monitoring_visit_schedule_id` FOREIGN KEY (`monitoring_visit_schedule_id`) REFERENCES `clinical_trials_mvm`.`monitoring`.`monitoring_visit_schedule`(`monitoring_visit_schedule_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`closeout` ADD CONSTRAINT `fk_site_closeout_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`site`.`closeout` ADD CONSTRAINT `fk_site_closeout_visit_report_id` FOREIGN KEY (`visit_report_id`) REFERENCES `clinical_trials_mvm`.`monitoring`.`visit_report`(`visit_report_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`trial_subject` ADD CONSTRAINT `fk_subject_trial_subject_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_mvm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`trial_subject` ADD CONSTRAINT `fk_subject_trial_subject_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`trial_subject` ADD CONSTRAINT `fk_subject_trial_subject_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`trial_subject` ADD CONSTRAINT `fk_subject_trial_subject_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`trial_subject` ADD CONSTRAINT `fk_subject_trial_subject_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`enrollment` ADD CONSTRAINT `fk_subject_enrollment_activation_id` FOREIGN KEY (`activation_id`) REFERENCES `clinical_trials_mvm`.`site`.`activation`(`activation_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`enrollment` ADD CONSTRAINT `fk_subject_enrollment_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_mvm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`enrollment` ADD CONSTRAINT `fk_subject_enrollment_blinding_config_id` FOREIGN KEY (`blinding_config_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`blinding_config`(`blinding_config_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`enrollment` ADD CONSTRAINT `fk_subject_enrollment_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`enrollment` ADD CONSTRAINT `fk_subject_enrollment_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_mvm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`enrollment` ADD CONSTRAINT `fk_subject_enrollment_ethics_approval_id` FOREIGN KEY (`ethics_approval_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`ethics_approval`(`ethics_approval_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`enrollment` ADD CONSTRAINT `fk_subject_enrollment_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`enrollment` ADD CONSTRAINT `fk_subject_enrollment_irb_iec_approval_id` FOREIGN KEY (`irb_iec_approval_id`) REFERENCES `clinical_trials_mvm`.`site`.`irb_iec_approval`(`irb_iec_approval_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`enrollment` ADD CONSTRAINT `fk_subject_enrollment_monitoring_cra_assignment_id` FOREIGN KEY (`monitoring_cra_assignment_id`) REFERENCES `clinical_trials_mvm`.`monitoring`.`monitoring_cra_assignment`(`monitoring_cra_assignment_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`enrollment` ADD CONSTRAINT `fk_subject_enrollment_monitoring_plan_id` FOREIGN KEY (`monitoring_plan_id`) REFERENCES `clinical_trials_mvm`.`monitoring`.`monitoring_plan`(`monitoring_plan_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`enrollment` ADD CONSTRAINT `fk_subject_enrollment_principal_investigator_id` FOREIGN KEY (`principal_investigator_id`) REFERENCES `clinical_trials_mvm`.`site`.`principal_investigator`(`principal_investigator_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`enrollment` ADD CONSTRAINT `fk_subject_enrollment_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`enrollment` ADD CONSTRAINT `fk_subject_enrollment_rand_scheme_id` FOREIGN KEY (`rand_scheme_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_scheme`(`rand_scheme_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`enrollment` ADD CONSTRAINT `fk_subject_enrollment_regulatory_protocol_amendment_id` FOREIGN KEY (`regulatory_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment`(`regulatory_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`enrollment` ADD CONSTRAINT `fk_subject_enrollment_stratification_factor_id` FOREIGN KEY (`stratification_factor_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`stratification_factor`(`stratification_factor_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`enrollment` ADD CONSTRAINT `fk_subject_enrollment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`enrollment` ADD CONSTRAINT `fk_subject_enrollment_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`enrollment` ADD CONSTRAINT `fk_subject_enrollment_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`enrollment` ADD CONSTRAINT `fk_subject_enrollment_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`randomization_assignment` ADD CONSTRAINT `fk_subject_randomization_assignment_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_mvm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`randomization_assignment` ADD CONSTRAINT `fk_subject_randomization_assignment_blinding_config_id` FOREIGN KEY (`blinding_config_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`blinding_config`(`blinding_config_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`randomization_assignment` ADD CONSTRAINT `fk_subject_randomization_assignment_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_mvm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`randomization_assignment` ADD CONSTRAINT `fk_subject_randomization_assignment_dispensing_record_id` FOREIGN KEY (`dispensing_record_id`) REFERENCES `clinical_trials_mvm`.`supply`.`dispensing_record`(`dispensing_record_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`randomization_assignment` ADD CONSTRAINT `fk_subject_randomization_assignment_dosing_regimen_id` FOREIGN KEY (`dosing_regimen_id`) REFERENCES `clinical_trials_mvm`.`study`.`dosing_regimen`(`dosing_regimen_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`randomization_assignment` ADD CONSTRAINT `fk_subject_randomization_assignment_epoch_id` FOREIGN KEY (`epoch_id`) REFERENCES `clinical_trials_mvm`.`study`.`epoch`(`epoch_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`randomization_assignment` ADD CONSTRAINT `fk_subject_randomization_assignment_irt_transaction_id` FOREIGN KEY (`irt_transaction_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`irt_transaction`(`irt_transaction_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`randomization_assignment` ADD CONSTRAINT `fk_subject_randomization_assignment_kit_inventory_id` FOREIGN KEY (`kit_inventory_id`) REFERENCES `clinical_trials_mvm`.`supply`.`kit_inventory`(`kit_inventory_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`randomization_assignment` ADD CONSTRAINT `fk_subject_randomization_assignment_rand_code_id` FOREIGN KEY (`rand_code_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_code`(`rand_code_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`randomization_assignment` ADD CONSTRAINT `fk_subject_randomization_assignment_rand_list_id` FOREIGN KEY (`rand_list_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_list`(`rand_list_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`randomization_assignment` ADD CONSTRAINT `fk_subject_randomization_assignment_rand_scheme_id` FOREIGN KEY (`rand_scheme_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_scheme`(`rand_scheme_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`randomization_assignment` ADD CONSTRAINT `fk_subject_randomization_assignment_randomization_treatment_arm_id` FOREIGN KEY (`randomization_treatment_arm_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`treatment_arm`(`treatment_arm_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`randomization_assignment` ADD CONSTRAINT `fk_subject_randomization_assignment_regulatory_protocol_amendment_id` FOREIGN KEY (`regulatory_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment`(`regulatory_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`randomization_assignment` ADD CONSTRAINT `fk_subject_randomization_assignment_stratification_factor_id` FOREIGN KEY (`stratification_factor_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`stratification_factor`(`stratification_factor_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`randomization_assignment` ADD CONSTRAINT `fk_subject_randomization_assignment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`randomization_assignment` ADD CONSTRAINT `fk_subject_randomization_assignment_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`randomization_assignment` ADD CONSTRAINT `fk_subject_randomization_assignment_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`randomization_assignment` ADD CONSTRAINT `fk_subject_randomization_assignment_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`disposition` ADD CONSTRAINT `fk_subject_disposition_adverse_event_id` FOREIGN KEY (`adverse_event_id`) REFERENCES `clinical_trials_mvm`.`safety`.`adverse_event`(`adverse_event_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`disposition` ADD CONSTRAINT `fk_subject_disposition_analysis_population_id` FOREIGN KEY (`analysis_population_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`analysis_population`(`analysis_population_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`disposition` ADD CONSTRAINT `fk_subject_disposition_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_mvm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`disposition` ADD CONSTRAINT `fk_subject_disposition_codelist_id` FOREIGN KEY (`codelist_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`codelist`(`codelist_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`disposition` ADD CONSTRAINT `fk_subject_disposition_database_lock_event_id` FOREIGN KEY (`database_lock_event_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`database_lock_event`(`database_lock_event_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`disposition` ADD CONSTRAINT `fk_subject_disposition_ecrf_form_id` FOREIGN KEY (`ecrf_form_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`ecrf_form`(`ecrf_form_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`disposition` ADD CONSTRAINT `fk_subject_disposition_protocol_deviation_id` FOREIGN KEY (`protocol_deviation_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`protocol_deviation`(`protocol_deviation_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`disposition` ADD CONSTRAINT `fk_subject_disposition_serious_adverse_event_id` FOREIGN KEY (`serious_adverse_event_id`) REFERENCES `clinical_trials_mvm`.`safety`.`serious_adverse_event`(`serious_adverse_event_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`disposition` ADD CONSTRAINT `fk_subject_disposition_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`disposition` ADD CONSTRAINT `fk_subject_disposition_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`disposition` ADD CONSTRAINT `fk_subject_disposition_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`disposition` ADD CONSTRAINT `fk_subject_disposition_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`disposition` ADD CONSTRAINT `fk_subject_disposition_susar_id` FOREIGN KEY (`susar_id`) REFERENCES `clinical_trials_mvm`.`safety`.`susar`(`susar_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`disposition` ADD CONSTRAINT `fk_subject_disposition_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`disposition` ADD CONSTRAINT `fk_subject_disposition_unblinding_request_id` FOREIGN KEY (`unblinding_request_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`unblinding_request`(`unblinding_request_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`disposition` ADD CONSTRAINT `fk_subject_disposition_withdrawal_id` FOREIGN KEY (`withdrawal_id`) REFERENCES `clinical_trials_mvm`.`consent`.`withdrawal`(`withdrawal_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`eligibility_assessment` ADD CONSTRAINT `fk_subject_eligibility_assessment_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_mvm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`eligibility_assessment` ADD CONSTRAINT `fk_subject_eligibility_assessment_document_sop_id` FOREIGN KEY (`document_sop_id`) REFERENCES `clinical_trials_mvm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`eligibility_assessment` ADD CONSTRAINT `fk_subject_eligibility_assessment_ecrf_form_id` FOREIGN KEY (`ecrf_form_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`ecrf_form`(`ecrf_form_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`eligibility_assessment` ADD CONSTRAINT `fk_subject_eligibility_assessment_eligibility_criterion_id` FOREIGN KEY (`eligibility_criterion_id`) REFERENCES `clinical_trials_mvm`.`study`.`eligibility_criterion`(`eligibility_criterion_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`eligibility_assessment` ADD CONSTRAINT `fk_subject_eligibility_assessment_ethics_approval_id` FOREIGN KEY (`ethics_approval_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`ethics_approval`(`ethics_approval_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`eligibility_assessment` ADD CONSTRAINT `fk_subject_eligibility_assessment_rand_scheme_id` FOREIGN KEY (`rand_scheme_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_scheme`(`rand_scheme_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`eligibility_assessment` ADD CONSTRAINT `fk_subject_eligibility_assessment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`eligibility_assessment` ADD CONSTRAINT `fk_subject_eligibility_assessment_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`eligibility_assessment` ADD CONSTRAINT `fk_subject_eligibility_assessment_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`eligibility_assessment` ADD CONSTRAINT `fk_subject_eligibility_assessment_validation_rule_id` FOREIGN KEY (`validation_rule_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`validation_rule`(`validation_rule_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`demographic` ADD CONSTRAINT `fk_subject_demographic_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_mvm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`demographic` ADD CONSTRAINT `fk_subject_demographic_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_mvm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`demographic` ADD CONSTRAINT `fk_subject_demographic_randomization_treatment_arm_id` FOREIGN KEY (`randomization_treatment_arm_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`treatment_arm`(`treatment_arm_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`demographic` ADD CONSTRAINT `fk_subject_demographic_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`demographic` ADD CONSTRAINT `fk_subject_demographic_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`medical_history` ADD CONSTRAINT `fk_subject_medical_history_ecrf_form_id` FOREIGN KEY (`ecrf_form_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`ecrf_form`(`ecrf_form_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`medical_history` ADD CONSTRAINT `fk_subject_medical_history_stratification_factor_id` FOREIGN KEY (`stratification_factor_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`stratification_factor`(`stratification_factor_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`medical_history` ADD CONSTRAINT `fk_subject_medical_history_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`medical_history` ADD CONSTRAINT `fk_subject_medical_history_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`concomitant_medication` ADD CONSTRAINT `fk_subject_concomitant_medication_adverse_event_id` FOREIGN KEY (`adverse_event_id`) REFERENCES `clinical_trials_mvm`.`safety`.`adverse_event`(`adverse_event_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`concomitant_medication` ADD CONSTRAINT `fk_subject_concomitant_medication_codelist_id` FOREIGN KEY (`codelist_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`codelist`(`codelist_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`concomitant_medication` ADD CONSTRAINT `fk_subject_concomitant_medication_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`concomitant_medication` ADD CONSTRAINT `fk_subject_concomitant_medication_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`concomitant_medication` ADD CONSTRAINT `fk_subject_concomitant_medication_treatment_arm_id` FOREIGN KEY (`treatment_arm_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`treatment_arm`(`treatment_arm_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`sdv_review` ADD CONSTRAINT `fk_subject_sdv_review_monitoring_cra_assignment_id` FOREIGN KEY (`monitoring_cra_assignment_id`) REFERENCES `clinical_trials_mvm`.`monitoring`.`monitoring_cra_assignment`(`monitoring_cra_assignment_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`sdv_review` ADD CONSTRAINT `fk_subject_sdv_review_monitoring_visit_schedule_id` FOREIGN KEY (`monitoring_visit_schedule_id`) REFERENCES `clinical_trials_mvm`.`monitoring`.`monitoring_visit_schedule`(`monitoring_visit_schedule_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`sdv_review` ADD CONSTRAINT `fk_subject_sdv_review_specimen_collection_id` FOREIGN KEY (`specimen_collection_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`specimen_collection`(`specimen_collection_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`sdv_review` ADD CONSTRAINT `fk_subject_sdv_review_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`sdv_review` ADD CONSTRAINT `fk_subject_sdv_review_subject_visit_data_id` FOREIGN KEY (`subject_visit_data_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`subject_visit_data`(`subject_visit_data_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`sdv_review` ADD CONSTRAINT `fk_subject_sdv_review_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`sdv_review` ADD CONSTRAINT `fk_subject_sdv_review_visit_report_id` FOREIGN KEY (`visit_report_id`) REFERENCES `clinical_trials_mvm`.`monitoring`.`visit_report`(`visit_report_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`subject_consent` ADD CONSTRAINT `fk_subject_subject_consent_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`subject_consent` ADD CONSTRAINT `fk_subject_subject_consent_ethics_approval_id` FOREIGN KEY (`ethics_approval_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`ethics_approval`(`ethics_approval_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`subject_consent` ADD CONSTRAINT `fk_subject_subject_consent_irb_iec_approval_id` FOREIGN KEY (`irb_iec_approval_id`) REFERENCES `clinical_trials_mvm`.`site`.`irb_iec_approval`(`irb_iec_approval_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`subject_consent` ADD CONSTRAINT `fk_subject_subject_consent_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`subject_consent` ADD CONSTRAINT `fk_subject_subject_consent_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`subject_consent` ADD CONSTRAINT `fk_subject_subject_consent_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`subject_consent` ADD CONSTRAINT `fk_subject_subject_consent_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`subject_consent` ADD CONSTRAINT `fk_subject_subject_consent_version_id` FOREIGN KEY (`version_id`) REFERENCES `clinical_trials_mvm`.`document`.`version`(`version_id`);

ALTER TABLE `clinical_trials_mvm`.`subject`.`subject_consent` ADD CONSTRAINT `fk_subject_subject_consent_workflow_id` FOREIGN KEY (`workflow_id`) REFERENCES `clinical_trials_mvm`.`document`.`workflow`(`workflow_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ADD CONSTRAINT `fk_safety_adverse_event_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_mvm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ADD CONSTRAINT `fk_safety_adverse_event_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_mvm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ADD CONSTRAINT `fk_safety_adverse_event_dosing_regimen_id` FOREIGN KEY (`dosing_regimen_id`) REFERENCES `clinical_trials_mvm`.`study`.`dosing_regimen`(`dosing_regimen_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ADD CONSTRAINT `fk_safety_adverse_event_ecrf_form_id` FOREIGN KEY (`ecrf_form_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`ecrf_form`(`ecrf_form_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ADD CONSTRAINT `fk_safety_adverse_event_imp_master_id` FOREIGN KEY (`imp_master_id`) REFERENCES `clinical_trials_mvm`.`supply`.`imp_master`(`imp_master_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ADD CONSTRAINT `fk_safety_adverse_event_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ADD CONSTRAINT `fk_safety_adverse_event_manufacture_batch_id` FOREIGN KEY (`manufacture_batch_id`) REFERENCES `clinical_trials_mvm`.`supply`.`manufacture_batch`(`manufacture_batch_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ADD CONSTRAINT `fk_safety_adverse_event_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ADD CONSTRAINT `fk_safety_adverse_event_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ADD CONSTRAINT `fk_safety_adverse_event_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ADD CONSTRAINT `fk_safety_adverse_event_subject_visit_data_id` FOREIGN KEY (`subject_visit_data_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`subject_visit_data`(`subject_visit_data_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`adverse_event` ADD CONSTRAINT `fk_safety_adverse_event_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ADD CONSTRAINT `fk_safety_serious_adverse_event_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_mvm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ADD CONSTRAINT `fk_safety_serious_adverse_event_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ADD CONSTRAINT `fk_safety_serious_adverse_event_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_mvm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ADD CONSTRAINT `fk_safety_serious_adverse_event_dosing_regimen_id` FOREIGN KEY (`dosing_regimen_id`) REFERENCES `clinical_trials_mvm`.`study`.`dosing_regimen`(`dosing_regimen_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ADD CONSTRAINT `fk_safety_serious_adverse_event_ecrf_form_id` FOREIGN KEY (`ecrf_form_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`ecrf_form`(`ecrf_form_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ADD CONSTRAINT `fk_safety_serious_adverse_event_imp_master_id` FOREIGN KEY (`imp_master_id`) REFERENCES `clinical_trials_mvm`.`supply`.`imp_master`(`imp_master_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ADD CONSTRAINT `fk_safety_serious_adverse_event_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ADD CONSTRAINT `fk_safety_serious_adverse_event_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ADD CONSTRAINT `fk_safety_serious_adverse_event_irb_iec_approval_id` FOREIGN KEY (`irb_iec_approval_id`) REFERENCES `clinical_trials_mvm`.`site`.`irb_iec_approval`(`irb_iec_approval_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ADD CONSTRAINT `fk_safety_serious_adverse_event_manufacture_batch_id` FOREIGN KEY (`manufacture_batch_id`) REFERENCES `clinical_trials_mvm`.`supply`.`manufacture_batch`(`manufacture_batch_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ADD CONSTRAINT `fk_safety_serious_adverse_event_protocol_deviation_id` FOREIGN KEY (`protocol_deviation_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`protocol_deviation`(`protocol_deviation_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ADD CONSTRAINT `fk_safety_serious_adverse_event_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ADD CONSTRAINT `fk_safety_serious_adverse_event_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ADD CONSTRAINT `fk_safety_serious_adverse_event_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ADD CONSTRAINT `fk_safety_serious_adverse_event_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ADD CONSTRAINT `fk_safety_serious_adverse_event_subject_visit_data_id` FOREIGN KEY (`subject_visit_data_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`subject_visit_data`(`subject_visit_data_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ADD CONSTRAINT `fk_safety_serious_adverse_event_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ADD CONSTRAINT `fk_safety_serious_adverse_event_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ADD CONSTRAINT `fk_safety_serious_adverse_event_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`serious_adverse_event` ADD CONSTRAINT `fk_safety_serious_adverse_event_withdrawal_id` FOREIGN KEY (`withdrawal_id`) REFERENCES `clinical_trials_mvm`.`consent`.`withdrawal`(`withdrawal_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ADD CONSTRAINT `fk_safety_susar_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_mvm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ADD CONSTRAINT `fk_safety_susar_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ADD CONSTRAINT `fk_safety_susar_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_mvm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ADD CONSTRAINT `fk_safety_susar_dosing_regimen_id` FOREIGN KEY (`dosing_regimen_id`) REFERENCES `clinical_trials_mvm`.`study`.`dosing_regimen`(`dosing_regimen_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ADD CONSTRAINT `fk_safety_susar_ethics_submission_id` FOREIGN KEY (`ethics_submission_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`ethics_submission`(`ethics_submission_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ADD CONSTRAINT `fk_safety_susar_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ADD CONSTRAINT `fk_safety_susar_imp_master_id` FOREIGN KEY (`imp_master_id`) REFERENCES `clinical_trials_mvm`.`supply`.`imp_master`(`imp_master_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ADD CONSTRAINT `fk_safety_susar_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ADD CONSTRAINT `fk_safety_susar_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ADD CONSTRAINT `fk_safety_susar_irb_iec_approval_id` FOREIGN KEY (`irb_iec_approval_id`) REFERENCES `clinical_trials_mvm`.`site`.`irb_iec_approval`(`irb_iec_approval_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ADD CONSTRAINT `fk_safety_susar_manufacture_batch_id` FOREIGN KEY (`manufacture_batch_id`) REFERENCES `clinical_trials_mvm`.`supply`.`manufacture_batch`(`manufacture_batch_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ADD CONSTRAINT `fk_safety_susar_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ADD CONSTRAINT `fk_safety_susar_regulatory_binder_id` FOREIGN KEY (`regulatory_binder_id`) REFERENCES `clinical_trials_mvm`.`document`.`regulatory_binder`(`regulatory_binder_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ADD CONSTRAINT `fk_safety_susar_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ADD CONSTRAINT `fk_safety_susar_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ADD CONSTRAINT `fk_safety_susar_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ADD CONSTRAINT `fk_safety_susar_subject_visit_data_id` FOREIGN KEY (`subject_visit_data_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`subject_visit_data`(`subject_visit_data_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ADD CONSTRAINT `fk_safety_susar_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ADD CONSTRAINT `fk_safety_susar_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`susar` ADD CONSTRAINT `fk_safety_susar_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ADD CONSTRAINT `fk_safety_ae_meddra_coding_discrepancy_query_id` FOREIGN KEY (`discrepancy_query_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`discrepancy_query`(`discrepancy_query_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ADD CONSTRAINT `fk_safety_ae_meddra_coding_ecrf_field_id` FOREIGN KEY (`ecrf_field_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`ecrf_field`(`ecrf_field_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ADD CONSTRAINT `fk_safety_ae_meddra_coding_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ADD CONSTRAINT `fk_safety_ae_meddra_coding_subject_visit_data_id` FOREIGN KEY (`subject_visit_data_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`subject_visit_data`(`subject_visit_data_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_meddra_coding` ADD CONSTRAINT `fk_safety_ae_meddra_coding_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ADD CONSTRAINT `fk_safety_causality_assessment_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_mvm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ADD CONSTRAINT `fk_safety_causality_assessment_dispensing_record_id` FOREIGN KEY (`dispensing_record_id`) REFERENCES `clinical_trials_mvm`.`supply`.`dispensing_record`(`dispensing_record_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ADD CONSTRAINT `fk_safety_causality_assessment_dosing_regimen_id` FOREIGN KEY (`dosing_regimen_id`) REFERENCES `clinical_trials_mvm`.`study`.`dosing_regimen`(`dosing_regimen_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ADD CONSTRAINT `fk_safety_causality_assessment_enrollment_id` FOREIGN KEY (`enrollment_id`) REFERENCES `clinical_trials_mvm`.`subject`.`enrollment`(`enrollment_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ADD CONSTRAINT `fk_safety_causality_assessment_investigational_product_id` FOREIGN KEY (`investigational_product_id`) REFERENCES `clinical_trials_mvm`.`study`.`investigational_product`(`investigational_product_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ADD CONSTRAINT `fk_safety_causality_assessment_protocol_deviation_id` FOREIGN KEY (`protocol_deviation_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`protocol_deviation`(`protocol_deviation_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ADD CONSTRAINT `fk_safety_causality_assessment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ADD CONSTRAINT `fk_safety_causality_assessment_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ADD CONSTRAINT `fk_safety_causality_assessment_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ADD CONSTRAINT `fk_safety_causality_assessment_subject_visit_data_id` FOREIGN KEY (`subject_visit_data_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`subject_visit_data`(`subject_visit_data_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ADD CONSTRAINT `fk_safety_causality_assessment_treatment_arm_id` FOREIGN KEY (`treatment_arm_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`treatment_arm`(`treatment_arm_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`causality_assessment` ADD CONSTRAINT `fk_safety_causality_assessment_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ADD CONSTRAINT `fk_safety_narrative_ecrf_form_id` FOREIGN KEY (`ecrf_form_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`ecrf_form`(`ecrf_form_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ADD CONSTRAINT `fk_safety_narrative_enrollment_id` FOREIGN KEY (`enrollment_id`) REFERENCES `clinical_trials_mvm`.`subject`.`enrollment`(`enrollment_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ADD CONSTRAINT `fk_safety_narrative_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ADD CONSTRAINT `fk_safety_narrative_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ADD CONSTRAINT `fk_safety_narrative_safety_narrative_tmf_document_id` FOREIGN KEY (`safety_narrative_tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ADD CONSTRAINT `fk_safety_narrative_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ADD CONSTRAINT `fk_safety_narrative_subject_visit_data_id` FOREIGN KEY (`subject_visit_data_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`subject_visit_data`(`subject_visit_data_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ADD CONSTRAINT `fk_safety_narrative_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`narrative` ADD CONSTRAINT `fk_safety_narrative_withdrawal_id` FOREIGN KEY (`withdrawal_id`) REFERENCES `clinical_trials_mvm`.`consent`.`withdrawal`(`withdrawal_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ADD CONSTRAINT `fk_safety_icsr_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ADD CONSTRAINT `fk_safety_icsr_dispensing_record_id` FOREIGN KEY (`dispensing_record_id`) REFERENCES `clinical_trials_mvm`.`supply`.`dispensing_record`(`dispensing_record_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ADD CONSTRAINT `fk_safety_icsr_document_sop_id` FOREIGN KEY (`document_sop_id`) REFERENCES `clinical_trials_mvm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ADD CONSTRAINT `fk_safety_icsr_ecrf_form_id` FOREIGN KEY (`ecrf_form_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`ecrf_form`(`ecrf_form_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ADD CONSTRAINT `fk_safety_icsr_enrollment_id` FOREIGN KEY (`enrollment_id`) REFERENCES `clinical_trials_mvm`.`subject`.`enrollment`(`enrollment_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ADD CONSTRAINT `fk_safety_icsr_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ADD CONSTRAINT `fk_safety_icsr_imp_master_id` FOREIGN KEY (`imp_master_id`) REFERENCES `clinical_trials_mvm`.`supply`.`imp_master`(`imp_master_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ADD CONSTRAINT `fk_safety_icsr_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ADD CONSTRAINT `fk_safety_icsr_investigational_product_id` FOREIGN KEY (`investigational_product_id`) REFERENCES `clinical_trials_mvm`.`study`.`investigational_product`(`investigational_product_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ADD CONSTRAINT `fk_safety_icsr_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ADD CONSTRAINT `fk_safety_icsr_manufacture_batch_id` FOREIGN KEY (`manufacture_batch_id`) REFERENCES `clinical_trials_mvm`.`supply`.`manufacture_batch`(`manufacture_batch_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ADD CONSTRAINT `fk_safety_icsr_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ADD CONSTRAINT `fk_safety_icsr_regulatory_binder_id` FOREIGN KEY (`regulatory_binder_id`) REFERENCES `clinical_trials_mvm`.`document`.`regulatory_binder`(`regulatory_binder_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ADD CONSTRAINT `fk_safety_icsr_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`icsr` ADD CONSTRAINT `fk_safety_icsr_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ADD CONSTRAINT `fk_safety_signal_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ADD CONSTRAINT `fk_safety_signal_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_mvm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ADD CONSTRAINT `fk_safety_signal_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ADD CONSTRAINT `fk_safety_signal_imp_master_id` FOREIGN KEY (`imp_master_id`) REFERENCES `clinical_trials_mvm`.`supply`.`imp_master`(`imp_master_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ADD CONSTRAINT `fk_safety_signal_investigational_product_id` FOREIGN KEY (`investigational_product_id`) REFERENCES `clinical_trials_mvm`.`study`.`investigational_product`(`investigational_product_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ADD CONSTRAINT `fk_safety_signal_lab_panel_id` FOREIGN KEY (`lab_panel_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_panel`(`lab_panel_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ADD CONSTRAINT `fk_safety_signal_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ADD CONSTRAINT `fk_safety_signal_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal` ADD CONSTRAINT `fk_safety_signal_treatment_arm_id` FOREIGN KEY (`treatment_arm_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`treatment_arm`(`treatment_arm_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ADD CONSTRAINT `fk_safety_signal_evaluation_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_mvm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ADD CONSTRAINT `fk_safety_signal_evaluation_endpoint_id` FOREIGN KEY (`endpoint_id`) REFERENCES `clinical_trials_mvm`.`study`.`endpoint`(`endpoint_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ADD CONSTRAINT `fk_safety_signal_evaluation_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ADD CONSTRAINT `fk_safety_signal_evaluation_interim_analysis_id` FOREIGN KEY (`interim_analysis_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`interim_analysis`(`interim_analysis_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ADD CONSTRAINT `fk_safety_signal_evaluation_investigational_product_id` FOREIGN KEY (`investigational_product_id`) REFERENCES `clinical_trials_mvm`.`study`.`investigational_product`(`investigational_product_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ADD CONSTRAINT `fk_safety_signal_evaluation_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ADD CONSTRAINT `fk_safety_signal_evaluation_regulatory_protocol_amendment_id` FOREIGN KEY (`regulatory_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment`(`regulatory_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ADD CONSTRAINT `fk_safety_signal_evaluation_sdtm_dataset_id` FOREIGN KEY (`sdtm_dataset_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset`(`sdtm_dataset_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ADD CONSTRAINT `fk_safety_signal_evaluation_statistical_endpoint_id` FOREIGN KEY (`statistical_endpoint_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint`(`statistical_endpoint_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ADD CONSTRAINT `fk_safety_signal_evaluation_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ADD CONSTRAINT `fk_safety_signal_evaluation_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ADD CONSTRAINT `fk_safety_signal_evaluation_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`signal_evaluation` ADD CONSTRAINT `fk_safety_signal_evaluation_treatment_arm_id` FOREIGN KEY (`treatment_arm_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`treatment_arm`(`treatment_arm_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ADD CONSTRAINT `fk_safety_dsmb_review_analysis_population_id` FOREIGN KEY (`analysis_population_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`analysis_population`(`analysis_population_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ADD CONSTRAINT `fk_safety_dsmb_review_blinding_config_id` FOREIGN KEY (`blinding_config_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`blinding_config`(`blinding_config_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ADD CONSTRAINT `fk_safety_dsmb_review_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ADD CONSTRAINT `fk_safety_dsmb_review_database_lock_event_id` FOREIGN KEY (`database_lock_event_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`database_lock_event`(`database_lock_event_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ADD CONSTRAINT `fk_safety_dsmb_review_dmp_id` FOREIGN KEY (`dmp_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`dmp`(`dmp_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ADD CONSTRAINT `fk_safety_dsmb_review_epoch_id` FOREIGN KEY (`epoch_id`) REFERENCES `clinical_trials_mvm`.`study`.`epoch`(`epoch_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ADD CONSTRAINT `fk_safety_dsmb_review_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ADD CONSTRAINT `fk_safety_dsmb_review_interim_analysis_id` FOREIGN KEY (`interim_analysis_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`interim_analysis`(`interim_analysis_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ADD CONSTRAINT `fk_safety_dsmb_review_investigational_product_id` FOREIGN KEY (`investigational_product_id`) REFERENCES `clinical_trials_mvm`.`study`.`investigational_product`(`investigational_product_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ADD CONSTRAINT `fk_safety_dsmb_review_primary_dsmb_tmf_document_id` FOREIGN KEY (`primary_dsmb_tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ADD CONSTRAINT `fk_safety_dsmb_review_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ADD CONSTRAINT `fk_safety_dsmb_review_rand_scheme_id` FOREIGN KEY (`rand_scheme_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_scheme`(`rand_scheme_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ADD CONSTRAINT `fk_safety_dsmb_review_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ADD CONSTRAINT `fk_safety_dsmb_review_sdtm_dataset_id` FOREIGN KEY (`sdtm_dataset_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset`(`sdtm_dataset_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ADD CONSTRAINT `fk_safety_dsmb_review_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ADD CONSTRAINT `fk_safety_dsmb_review_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_review` ADD CONSTRAINT `fk_safety_dsmb_review_treatment_arm_id` FOREIGN KEY (`treatment_arm_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`treatment_arm`(`treatment_arm_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ADD CONSTRAINT `fk_safety_dsmb_recommendation_affected_treatment_arm_id` FOREIGN KEY (`affected_treatment_arm_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`treatment_arm`(`treatment_arm_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ADD CONSTRAINT `fk_safety_dsmb_recommendation_interim_analysis_id` FOREIGN KEY (`interim_analysis_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`interim_analysis`(`interim_analysis_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ADD CONSTRAINT `fk_safety_dsmb_recommendation_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ADD CONSTRAINT `fk_safety_dsmb_recommendation_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ADD CONSTRAINT `fk_safety_dsmb_recommendation_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsmb_recommendation` ADD CONSTRAINT `fk_safety_dsmb_recommendation_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ADD CONSTRAINT `fk_safety_dsur_analysis_population_id` FOREIGN KEY (`analysis_population_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`analysis_population`(`analysis_population_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ADD CONSTRAINT `fk_safety_dsur_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ADD CONSTRAINT `fk_safety_dsur_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ADD CONSTRAINT `fk_safety_dsur_database_lock_event_id` FOREIGN KEY (`database_lock_event_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`database_lock_event`(`database_lock_event_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ADD CONSTRAINT `fk_safety_dsur_dmp_id` FOREIGN KEY (`dmp_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`dmp`(`dmp_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ADD CONSTRAINT `fk_safety_dsur_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ADD CONSTRAINT `fk_safety_dsur_imp_master_id` FOREIGN KEY (`imp_master_id`) REFERENCES `clinical_trials_mvm`.`supply`.`imp_master`(`imp_master_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ADD CONSTRAINT `fk_safety_dsur_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ADD CONSTRAINT `fk_safety_dsur_investigational_product_id` FOREIGN KEY (`investigational_product_id`) REFERENCES `clinical_trials_mvm`.`study`.`investigational_product`(`investigational_product_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ADD CONSTRAINT `fk_safety_dsur_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ADD CONSTRAINT `fk_safety_dsur_reconciliation_id` FOREIGN KEY (`reconciliation_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`reconciliation`(`reconciliation_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ADD CONSTRAINT `fk_safety_dsur_regulatory_binder_id` FOREIGN KEY (`regulatory_binder_id`) REFERENCES `clinical_trials_mvm`.`document`.`regulatory_binder`(`regulatory_binder_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ADD CONSTRAINT `fk_safety_dsur_safety_report_submission_id` FOREIGN KEY (`safety_report_submission_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`safety_report_submission`(`safety_report_submission_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ADD CONSTRAINT `fk_safety_dsur_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ADD CONSTRAINT `fk_safety_dsur_sdtm_dataset_id` FOREIGN KEY (`sdtm_dataset_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset`(`sdtm_dataset_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ADD CONSTRAINT `fk_safety_dsur_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`dsur` ADD CONSTRAINT `fk_safety_dsur_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ADD CONSTRAINT `fk_safety_ae_follow_up_dispensing_record_id` FOREIGN KEY (`dispensing_record_id`) REFERENCES `clinical_trials_mvm`.`supply`.`dispensing_record`(`dispensing_record_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ADD CONSTRAINT `fk_safety_ae_follow_up_ecrf_form_id` FOREIGN KEY (`ecrf_form_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`ecrf_form`(`ecrf_form_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ADD CONSTRAINT `fk_safety_ae_follow_up_enrollment_id` FOREIGN KEY (`enrollment_id`) REFERENCES `clinical_trials_mvm`.`subject`.`enrollment`(`enrollment_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ADD CONSTRAINT `fk_safety_ae_follow_up_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ADD CONSTRAINT `fk_safety_ae_follow_up_manufacture_batch_id` FOREIGN KEY (`manufacture_batch_id`) REFERENCES `clinical_trials_mvm`.`supply`.`manufacture_batch`(`manufacture_batch_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ADD CONSTRAINT `fk_safety_ae_follow_up_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ADD CONSTRAINT `fk_safety_ae_follow_up_safety_report_submission_id` FOREIGN KEY (`safety_report_submission_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`safety_report_submission`(`safety_report_submission_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ADD CONSTRAINT `fk_safety_ae_follow_up_specimen_collection_id` FOREIGN KEY (`specimen_collection_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`specimen_collection`(`specimen_collection_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ADD CONSTRAINT `fk_safety_ae_follow_up_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ADD CONSTRAINT `fk_safety_ae_follow_up_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ADD CONSTRAINT `fk_safety_ae_follow_up_subject_visit_data_id` FOREIGN KEY (`subject_visit_data_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`subject_visit_data`(`subject_visit_data_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ADD CONSTRAINT `fk_safety_ae_follow_up_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ADD CONSTRAINT `fk_safety_ae_follow_up_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`safety`.`ae_follow_up` ADD CONSTRAINT `fk_safety_ae_follow_up_withdrawal_id` FOREIGN KEY (`withdrawal_id`) REFERENCES `clinical_trials_mvm`.`consent`.`withdrawal`(`withdrawal_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ADD CONSTRAINT `fk_datamanagement_ecrf_field_endpoint_id` FOREIGN KEY (`endpoint_id`) REFERENCES `clinical_trials_mvm`.`study`.`endpoint`(`endpoint_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ADD CONSTRAINT `fk_datamanagement_ecrf_field_imp_master_id` FOREIGN KEY (`imp_master_id`) REFERENCES `clinical_trials_mvm`.`supply`.`imp_master`(`imp_master_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ADD CONSTRAINT `fk_datamanagement_ecrf_field_lab_panel_id` FOREIGN KEY (`lab_panel_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_panel`(`lab_panel_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_field` ADD CONSTRAINT `fk_datamanagement_ecrf_field_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ADD CONSTRAINT `fk_datamanagement_define_document_audit_finding_id` FOREIGN KEY (`audit_finding_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`audit_finding`(`audit_finding_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ADD CONSTRAINT `fk_datamanagement_define_document_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ADD CONSTRAINT `fk_datamanagement_define_document_regulatory_binder_id` FOREIGN KEY (`regulatory_binder_id`) REFERENCES `clinical_trials_mvm`.`document`.`regulatory_binder`(`regulatory_binder_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ADD CONSTRAINT `fk_datamanagement_define_document_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ADD CONSTRAINT `fk_datamanagement_define_document_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ADD CONSTRAINT `fk_datamanagement_define_document_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`define_document` ADD CONSTRAINT `fk_datamanagement_define_document_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_source_system` ADD CONSTRAINT `fk_datamanagement_ehr_source_system_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_source_system` ADD CONSTRAINT `fk_datamanagement_ehr_source_system_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_data_transfer` ADD CONSTRAINT `fk_datamanagement_ehr_data_transfer_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_mvm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_data_transfer` ADD CONSTRAINT `fk_datamanagement_ehr_data_transfer_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_data_transfer` ADD CONSTRAINT `fk_datamanagement_ehr_data_transfer_study_visit_schedule_id` FOREIGN KEY (`study_visit_schedule_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_visit_schedule`(`study_visit_schedule_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ehr_data_transfer` ADD CONSTRAINT `fk_datamanagement_ehr_data_transfer_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ADD CONSTRAINT `fk_datamanagement_ecrf_form_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ADD CONSTRAINT `fk_datamanagement_ecrf_form_lab_panel_id` FOREIGN KEY (`lab_panel_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_panel`(`lab_panel_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ADD CONSTRAINT `fk_datamanagement_ecrf_form_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ADD CONSTRAINT `fk_datamanagement_ecrf_form_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ADD CONSTRAINT `fk_datamanagement_ecrf_form_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`ecrf_form` ADD CONSTRAINT `fk_datamanagement_ecrf_form_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ADD CONSTRAINT `fk_datamanagement_subject_visit_data_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_mvm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ADD CONSTRAINT `fk_datamanagement_subject_visit_data_database_lock_event_id` FOREIGN KEY (`database_lock_event_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`database_lock_event`(`database_lock_event_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ADD CONSTRAINT `fk_datamanagement_subject_visit_data_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ADD CONSTRAINT `fk_datamanagement_subject_visit_data_study_visit_schedule_id` FOREIGN KEY (`study_visit_schedule_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_visit_schedule`(`study_visit_schedule_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ADD CONSTRAINT `fk_datamanagement_subject_visit_data_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ADD CONSTRAINT `fk_datamanagement_subject_visit_data_treatment_arm_id` FOREIGN KEY (`treatment_arm_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`treatment_arm`(`treatment_arm_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`subject_visit_data` ADD CONSTRAINT `fk_datamanagement_subject_visit_data_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ADD CONSTRAINT `fk_datamanagement_field_entry_demographic_id` FOREIGN KEY (`demographic_id`) REFERENCES `clinical_trials_mvm`.`subject`.`demographic`(`demographic_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ADD CONSTRAINT `fk_datamanagement_field_entry_dispensing_record_id` FOREIGN KEY (`dispensing_record_id`) REFERENCES `clinical_trials_mvm`.`supply`.`dispensing_record`(`dispensing_record_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ADD CONSTRAINT `fk_datamanagement_field_entry_enrollment_id` FOREIGN KEY (`enrollment_id`) REFERENCES `clinical_trials_mvm`.`subject`.`enrollment`(`enrollment_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ADD CONSTRAINT `fk_datamanagement_field_entry_irt_transaction_id` FOREIGN KEY (`irt_transaction_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`irt_transaction`(`irt_transaction_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ADD CONSTRAINT `fk_datamanagement_field_entry_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ADD CONSTRAINT `fk_datamanagement_field_entry_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ADD CONSTRAINT `fk_datamanagement_field_entry_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`field_entry` ADD CONSTRAINT `fk_datamanagement_field_entry_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ADD CONSTRAINT `fk_datamanagement_discrepancy_query_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_mvm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ADD CONSTRAINT `fk_datamanagement_discrepancy_query_demographic_id` FOREIGN KEY (`demographic_id`) REFERENCES `clinical_trials_mvm`.`subject`.`demographic`(`demographic_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ADD CONSTRAINT `fk_datamanagement_discrepancy_query_dispensing_record_id` FOREIGN KEY (`dispensing_record_id`) REFERENCES `clinical_trials_mvm`.`supply`.`dispensing_record`(`dispensing_record_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ADD CONSTRAINT `fk_datamanagement_discrepancy_query_enrollment_id` FOREIGN KEY (`enrollment_id`) REFERENCES `clinical_trials_mvm`.`subject`.`enrollment`(`enrollment_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ADD CONSTRAINT `fk_datamanagement_discrepancy_query_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ADD CONSTRAINT `fk_datamanagement_discrepancy_query_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ADD CONSTRAINT `fk_datamanagement_discrepancy_query_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`discrepancy_query` ADD CONSTRAINT `fk_datamanagement_discrepancy_query_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ADD CONSTRAINT `fk_datamanagement_validation_rule_bioanalytical_assay_id` FOREIGN KEY (`bioanalytical_assay_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`bioanalytical_assay`(`bioanalytical_assay_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ADD CONSTRAINT `fk_datamanagement_validation_rule_document_sop_id` FOREIGN KEY (`document_sop_id`) REFERENCES `clinical_trials_mvm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ADD CONSTRAINT `fk_datamanagement_validation_rule_endpoint_id` FOREIGN KEY (`endpoint_id`) REFERENCES `clinical_trials_mvm`.`study`.`endpoint`(`endpoint_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ADD CONSTRAINT `fk_datamanagement_validation_rule_lab_panel_id` FOREIGN KEY (`lab_panel_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_panel`(`lab_panel_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ADD CONSTRAINT `fk_datamanagement_validation_rule_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ADD CONSTRAINT `fk_datamanagement_validation_rule_rand_scheme_id` FOREIGN KEY (`rand_scheme_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_scheme`(`rand_scheme_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ADD CONSTRAINT `fk_datamanagement_validation_rule_reference_range_id` FOREIGN KEY (`reference_range_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`reference_range`(`reference_range_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ADD CONSTRAINT `fk_datamanagement_validation_rule_risk_assessment_id` FOREIGN KEY (`risk_assessment_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`risk_assessment`(`risk_assessment_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ADD CONSTRAINT `fk_datamanagement_validation_rule_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`validation_rule` ADD CONSTRAINT `fk_datamanagement_validation_rule_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ADD CONSTRAINT `fk_datamanagement_dmp_audit_id` FOREIGN KEY (`audit_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`audit`(`audit_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ADD CONSTRAINT `fk_datamanagement_dmp_blinding_config_id` FOREIGN KEY (`blinding_config_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`blinding_config`(`blinding_config_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ADD CONSTRAINT `fk_datamanagement_dmp_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ADD CONSTRAINT `fk_datamanagement_dmp_document_sop_id` FOREIGN KEY (`document_sop_id`) REFERENCES `clinical_trials_mvm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ADD CONSTRAINT `fk_datamanagement_dmp_ethics_approval_id` FOREIGN KEY (`ethics_approval_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`ethics_approval`(`ethics_approval_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ADD CONSTRAINT `fk_datamanagement_dmp_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ADD CONSTRAINT `fk_datamanagement_dmp_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ADD CONSTRAINT `fk_datamanagement_dmp_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ADD CONSTRAINT `fk_datamanagement_dmp_rand_scheme_id` FOREIGN KEY (`rand_scheme_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_scheme`(`rand_scheme_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ADD CONSTRAINT `fk_datamanagement_dmp_regulatory_binder_id` FOREIGN KEY (`regulatory_binder_id`) REFERENCES `clinical_trials_mvm`.`document`.`regulatory_binder`(`regulatory_binder_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ADD CONSTRAINT `fk_datamanagement_dmp_regulatory_protocol_amendment_id` FOREIGN KEY (`regulatory_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment`(`regulatory_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ADD CONSTRAINT `fk_datamanagement_dmp_risk_assessment_id` FOREIGN KEY (`risk_assessment_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`risk_assessment`(`risk_assessment_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ADD CONSTRAINT `fk_datamanagement_dmp_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ADD CONSTRAINT `fk_datamanagement_dmp_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ADD CONSTRAINT `fk_datamanagement_dmp_tmf_artifact_id` FOREIGN KEY (`tmf_artifact_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_artifact`(`tmf_artifact_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`dmp` ADD CONSTRAINT `fk_datamanagement_dmp_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ADD CONSTRAINT `fk_datamanagement_coding_assignment_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ADD CONSTRAINT `fk_datamanagement_coding_assignment_endpoint_id` FOREIGN KEY (`endpoint_id`) REFERENCES `clinical_trials_mvm`.`study`.`endpoint`(`endpoint_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ADD CONSTRAINT `fk_datamanagement_coding_assignment_enrollment_id` FOREIGN KEY (`enrollment_id`) REFERENCES `clinical_trials_mvm`.`subject`.`enrollment`(`enrollment_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ADD CONSTRAINT `fk_datamanagement_coding_assignment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ADD CONSTRAINT `fk_datamanagement_coding_assignment_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`coding_assignment` ADD CONSTRAINT `fk_datamanagement_coding_assignment_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ADD CONSTRAINT `fk_datamanagement_sdtm_dataset_lab_panel_id` FOREIGN KEY (`lab_panel_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_panel`(`lab_panel_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ADD CONSTRAINT `fk_datamanagement_sdtm_dataset_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ADD CONSTRAINT `fk_datamanagement_sdtm_dataset_risk_assessment_id` FOREIGN KEY (`risk_assessment_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`risk_assessment`(`risk_assessment_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ADD CONSTRAINT `fk_datamanagement_sdtm_dataset_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ADD CONSTRAINT `fk_datamanagement_sdtm_dataset_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ADD CONSTRAINT `fk_datamanagement_sdtm_dataset_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ADD CONSTRAINT `fk_datamanagement_sdtm_dataset_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset` ADD CONSTRAINT `fk_datamanagement_sdtm_dataset_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ADD CONSTRAINT `fk_datamanagement_sdtm_mapping_bioanalytical_assay_id` FOREIGN KEY (`bioanalytical_assay_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`bioanalytical_assay`(`bioanalytical_assay_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ADD CONSTRAINT `fk_datamanagement_sdtm_mapping_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ADD CONSTRAINT `fk_datamanagement_sdtm_mapping_endpoint_id` FOREIGN KEY (`endpoint_id`) REFERENCES `clinical_trials_mvm`.`study`.`endpoint`(`endpoint_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ADD CONSTRAINT `fk_datamanagement_sdtm_mapping_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ADD CONSTRAINT `fk_datamanagement_sdtm_mapping_reference_range_id` FOREIGN KEY (`reference_range_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`reference_range`(`reference_range_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ADD CONSTRAINT `fk_datamanagement_sdtm_mapping_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ADD CONSTRAINT `fk_datamanagement_sdtm_mapping_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`sdtm_mapping` ADD CONSTRAINT `fk_datamanagement_sdtm_mapping_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ADD CONSTRAINT `fk_datamanagement_reconciliation_accountability_reconciliation_id` FOREIGN KEY (`accountability_reconciliation_id`) REFERENCES `clinical_trials_mvm`.`supply`.`accountability_reconciliation`(`accountability_reconciliation_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ADD CONSTRAINT `fk_datamanagement_reconciliation_audit_finding_id` FOREIGN KEY (`audit_finding_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`audit_finding`(`audit_finding_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ADD CONSTRAINT `fk_datamanagement_reconciliation_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_mvm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ADD CONSTRAINT `fk_datamanagement_reconciliation_database_lock_event_id` FOREIGN KEY (`database_lock_event_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`database_lock_event`(`database_lock_event_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ADD CONSTRAINT `fk_datamanagement_reconciliation_destruction_record_id` FOREIGN KEY (`destruction_record_id`) REFERENCES `clinical_trials_mvm`.`supply`.`destruction_record`(`destruction_record_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ADD CONSTRAINT `fk_datamanagement_reconciliation_dispensing_record_id` FOREIGN KEY (`dispensing_record_id`) REFERENCES `clinical_trials_mvm`.`supply`.`dispensing_record`(`dispensing_record_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ADD CONSTRAINT `fk_datamanagement_reconciliation_document_sop_id` FOREIGN KEY (`document_sop_id`) REFERENCES `clinical_trials_mvm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ADD CONSTRAINT `fk_datamanagement_reconciliation_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ADD CONSTRAINT `fk_datamanagement_reconciliation_protocol_deviation_id` FOREIGN KEY (`protocol_deviation_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`protocol_deviation`(`protocol_deviation_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ADD CONSTRAINT `fk_datamanagement_reconciliation_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ADD CONSTRAINT `fk_datamanagement_reconciliation_return_record_id` FOREIGN KEY (`return_record_id`) REFERENCES `clinical_trials_mvm`.`supply`.`return_record`(`return_record_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ADD CONSTRAINT `fk_datamanagement_reconciliation_shipment_id` FOREIGN KEY (`shipment_id`) REFERENCES `clinical_trials_mvm`.`supply`.`shipment`(`shipment_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ADD CONSTRAINT `fk_datamanagement_reconciliation_specimen_shipment_id` FOREIGN KEY (`specimen_shipment_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`specimen_shipment`(`specimen_shipment_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ADD CONSTRAINT `fk_datamanagement_reconciliation_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ADD CONSTRAINT `fk_datamanagement_reconciliation_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ADD CONSTRAINT `fk_datamanagement_reconciliation_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ADD CONSTRAINT `fk_datamanagement_reconciliation_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ADD CONSTRAINT `fk_datamanagement_reconciliation_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ADD CONSTRAINT `fk_datamanagement_reconciliation_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`datamanagement`.`reconciliation` ADD CONSTRAINT `fk_datamanagement_reconciliation_workflow_id` FOREIGN KEY (`workflow_id`) REFERENCES `clinical_trials_mvm`.`document`.`workflow`(`workflow_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_panel` ADD CONSTRAINT `fk_laboratory_lab_panel_document_sop_id` FOREIGN KEY (`document_sop_id`) REFERENCES `clinical_trials_mvm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_panel` ADD CONSTRAINT `fk_laboratory_lab_panel_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_facility` ADD CONSTRAINT `fk_laboratory_lab_facility_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_facility` ADD CONSTRAINT `fk_laboratory_lab_facility_qualification_tmf_document_id` FOREIGN KEY (`qualification_tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_facility` ADD CONSTRAINT `fk_laboratory_lab_facility_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen` ADD CONSTRAINT `fk_laboratory_specimen_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_mvm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen` ADD CONSTRAINT `fk_laboratory_specimen_shipment_id` FOREIGN KEY (`shipment_id`) REFERENCES `clinical_trials_mvm`.`supply`.`shipment`(`shipment_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen` ADD CONSTRAINT `fk_laboratory_specimen_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen` ADD CONSTRAINT `fk_laboratory_specimen_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen` ADD CONSTRAINT `fk_laboratory_specimen_study_visit_schedule_id` FOREIGN KEY (`study_visit_schedule_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_visit_schedule`(`study_visit_schedule_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen` ADD CONSTRAINT `fk_laboratory_specimen_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_collection` ADD CONSTRAINT `fk_laboratory_specimen_collection_adverse_event_id` FOREIGN KEY (`adverse_event_id`) REFERENCES `clinical_trials_mvm`.`safety`.`adverse_event`(`adverse_event_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_collection` ADD CONSTRAINT `fk_laboratory_specimen_collection_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_mvm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_collection` ADD CONSTRAINT `fk_laboratory_specimen_collection_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_collection` ADD CONSTRAINT `fk_laboratory_specimen_collection_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_mvm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_collection` ADD CONSTRAINT `fk_laboratory_specimen_collection_ecrf_form_id` FOREIGN KEY (`ecrf_form_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`ecrf_form`(`ecrf_form_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_collection` ADD CONSTRAINT `fk_laboratory_specimen_collection_epoch_id` FOREIGN KEY (`epoch_id`) REFERENCES `clinical_trials_mvm`.`study`.`epoch`(`epoch_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_collection` ADD CONSTRAINT `fk_laboratory_specimen_collection_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_collection` ADD CONSTRAINT `fk_laboratory_specimen_collection_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_collection` ADD CONSTRAINT `fk_laboratory_specimen_collection_regulatory_protocol_amendment_id` FOREIGN KEY (`regulatory_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment`(`regulatory_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_collection` ADD CONSTRAINT `fk_laboratory_specimen_collection_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_collection` ADD CONSTRAINT `fk_laboratory_specimen_collection_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_collection` ADD CONSTRAINT `fk_laboratory_specimen_collection_study_visit_schedule_id` FOREIGN KEY (`study_visit_schedule_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_visit_schedule`(`study_visit_schedule_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_collection` ADD CONSTRAINT `fk_laboratory_specimen_collection_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_collection` ADD CONSTRAINT `fk_laboratory_specimen_collection_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_collection` ADD CONSTRAINT `fk_laboratory_specimen_collection_withdrawal_id` FOREIGN KEY (`withdrawal_id`) REFERENCES `clinical_trials_mvm`.`consent`.`withdrawal`(`withdrawal_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_shipment` ADD CONSTRAINT `fk_laboratory_specimen_shipment_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_shipment` ADD CONSTRAINT `fk_laboratory_specimen_shipment_document_sop_id` FOREIGN KEY (`document_sop_id`) REFERENCES `clinical_trials_mvm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_shipment` ADD CONSTRAINT `fk_laboratory_specimen_shipment_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_shipment` ADD CONSTRAINT `fk_laboratory_specimen_shipment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_shipment` ADD CONSTRAINT `fk_laboratory_specimen_shipment_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_shipment` ADD CONSTRAINT `fk_laboratory_specimen_shipment_study_visit_schedule_id` FOREIGN KEY (`study_visit_schedule_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_visit_schedule`(`study_visit_schedule_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_shipment` ADD CONSTRAINT `fk_laboratory_specimen_shipment_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`reference_range` ADD CONSTRAINT `fk_laboratory_reference_range_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_mvm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`reference_range` ADD CONSTRAINT `fk_laboratory_reference_range_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`reference_range` ADD CONSTRAINT `fk_laboratory_reference_range_epoch_id` FOREIGN KEY (`epoch_id`) REFERENCES `clinical_trials_mvm`.`study`.`epoch`(`epoch_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`reference_range` ADD CONSTRAINT `fk_laboratory_reference_range_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`reference_range` ADD CONSTRAINT `fk_laboratory_reference_range_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`reference_range` ADD CONSTRAINT `fk_laboratory_reference_range_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`reference_range` ADD CONSTRAINT `fk_laboratory_reference_range_treatment_arm_id` FOREIGN KEY (`treatment_arm_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`treatment_arm`(`treatment_arm_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`pk_sample` ADD CONSTRAINT `fk_laboratory_pk_sample_adverse_event_id` FOREIGN KEY (`adverse_event_id`) REFERENCES `clinical_trials_mvm`.`safety`.`adverse_event`(`adverse_event_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`pk_sample` ADD CONSTRAINT `fk_laboratory_pk_sample_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_mvm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`pk_sample` ADD CONSTRAINT `fk_laboratory_pk_sample_blinding_config_id` FOREIGN KEY (`blinding_config_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`blinding_config`(`blinding_config_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`pk_sample` ADD CONSTRAINT `fk_laboratory_pk_sample_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`pk_sample` ADD CONSTRAINT `fk_laboratory_pk_sample_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_mvm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`pk_sample` ADD CONSTRAINT `fk_laboratory_pk_sample_epoch_id` FOREIGN KEY (`epoch_id`) REFERENCES `clinical_trials_mvm`.`study`.`epoch`(`epoch_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`pk_sample` ADD CONSTRAINT `fk_laboratory_pk_sample_manufacture_batch_id` FOREIGN KEY (`manufacture_batch_id`) REFERENCES `clinical_trials_mvm`.`supply`.`manufacture_batch`(`manufacture_batch_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`pk_sample` ADD CONSTRAINT `fk_laboratory_pk_sample_shipment_id` FOREIGN KEY (`shipment_id`) REFERENCES `clinical_trials_mvm`.`supply`.`shipment`(`shipment_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`pk_sample` ADD CONSTRAINT `fk_laboratory_pk_sample_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`pk_sample` ADD CONSTRAINT `fk_laboratory_pk_sample_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`pk_sample` ADD CONSTRAINT `fk_laboratory_pk_sample_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`pk_sample` ADD CONSTRAINT `fk_laboratory_pk_sample_study_visit_schedule_id` FOREIGN KEY (`study_visit_schedule_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_visit_schedule`(`study_visit_schedule_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`pk_sample` ADD CONSTRAINT `fk_laboratory_pk_sample_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`pk_sample` ADD CONSTRAINT `fk_laboratory_pk_sample_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`bioanalytical_assay` ADD CONSTRAINT `fk_laboratory_bioanalytical_assay_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`bioanalytical_assay` ADD CONSTRAINT `fk_laboratory_bioanalytical_assay_blinding_config_id` FOREIGN KEY (`blinding_config_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`blinding_config`(`blinding_config_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`bioanalytical_assay` ADD CONSTRAINT `fk_laboratory_bioanalytical_assay_document_sop_id` FOREIGN KEY (`document_sop_id`) REFERENCES `clinical_trials_mvm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`bioanalytical_assay` ADD CONSTRAINT `fk_laboratory_bioanalytical_assay_imp_master_id` FOREIGN KEY (`imp_master_id`) REFERENCES `clinical_trials_mvm`.`supply`.`imp_master`(`imp_master_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`bioanalytical_assay` ADD CONSTRAINT `fk_laboratory_bioanalytical_assay_investigational_product_id` FOREIGN KEY (`investigational_product_id`) REFERENCES `clinical_trials_mvm`.`study`.`investigational_product`(`investigational_product_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`bioanalytical_assay` ADD CONSTRAINT `fk_laboratory_bioanalytical_assay_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`bioanalytical_assay` ADD CONSTRAINT `fk_laboratory_bioanalytical_assay_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`bioanalytical_assay` ADD CONSTRAINT `fk_laboratory_bioanalytical_assay_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`bioanalytical_assay` ADD CONSTRAINT `fk_laboratory_bioanalytical_assay_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`bioanalytical_assay` ADD CONSTRAINT `fk_laboratory_bioanalytical_assay_validation_tmf_document_id` FOREIGN KEY (`validation_tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`bioanalytical_result` ADD CONSTRAINT `fk_laboratory_bioanalytical_result_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_mvm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`bioanalytical_result` ADD CONSTRAINT `fk_laboratory_bioanalytical_result_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`bioanalytical_result` ADD CONSTRAINT `fk_laboratory_bioanalytical_result_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_mvm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`bioanalytical_result` ADD CONSTRAINT `fk_laboratory_bioanalytical_result_database_lock_event_id` FOREIGN KEY (`database_lock_event_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`database_lock_event`(`database_lock_event_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`bioanalytical_result` ADD CONSTRAINT `fk_laboratory_bioanalytical_result_epoch_id` FOREIGN KEY (`epoch_id`) REFERENCES `clinical_trials_mvm`.`study`.`epoch`(`epoch_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`bioanalytical_result` ADD CONSTRAINT `fk_laboratory_bioanalytical_result_manufacture_batch_id` FOREIGN KEY (`manufacture_batch_id`) REFERENCES `clinical_trials_mvm`.`supply`.`manufacture_batch`(`manufacture_batch_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`bioanalytical_result` ADD CONSTRAINT `fk_laboratory_bioanalytical_result_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`bioanalytical_result` ADD CONSTRAINT `fk_laboratory_bioanalytical_result_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`bioanalytical_result` ADD CONSTRAINT `fk_laboratory_bioanalytical_result_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`bioanalytical_result` ADD CONSTRAINT `fk_laboratory_bioanalytical_result_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`bioanalytical_result` ADD CONSTRAINT `fk_laboratory_bioanalytical_result_study_visit_schedule_id` FOREIGN KEY (`study_visit_schedule_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_visit_schedule`(`study_visit_schedule_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`bioanalytical_result` ADD CONSTRAINT `fk_laboratory_bioanalytical_result_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`bioanalytical_result` ADD CONSTRAINT `fk_laboratory_bioanalytical_result_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_kit` ADD CONSTRAINT `fk_laboratory_lab_kit_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_kit` ADD CONSTRAINT `fk_laboratory_lab_kit_document_sop_id` FOREIGN KEY (`document_sop_id`) REFERENCES `clinical_trials_mvm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_kit` ADD CONSTRAINT `fk_laboratory_lab_kit_epoch_id` FOREIGN KEY (`epoch_id`) REFERENCES `clinical_trials_mvm`.`study`.`epoch`(`epoch_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_kit` ADD CONSTRAINT `fk_laboratory_lab_kit_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_kit` ADD CONSTRAINT `fk_laboratory_lab_kit_regulatory_protocol_amendment_id` FOREIGN KEY (`regulatory_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment`(`regulatory_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_kit` ADD CONSTRAINT `fk_laboratory_lab_kit_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_kit` ADD CONSTRAINT `fk_laboratory_lab_kit_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_kit` ADD CONSTRAINT `fk_laboratory_lab_kit_treatment_arm_id` FOREIGN KEY (`treatment_arm_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`treatment_arm`(`treatment_arm_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_query` ADD CONSTRAINT `fk_laboratory_lab_query_adverse_event_id` FOREIGN KEY (`adverse_event_id`) REFERENCES `clinical_trials_mvm`.`safety`.`adverse_event`(`adverse_event_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_query` ADD CONSTRAINT `fk_laboratory_lab_query_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_query` ADD CONSTRAINT `fk_laboratory_lab_query_database_lock_event_id` FOREIGN KEY (`database_lock_event_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`database_lock_event`(`database_lock_event_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_query` ADD CONSTRAINT `fk_laboratory_lab_query_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_query` ADD CONSTRAINT `fk_laboratory_lab_query_principal_investigator_id` FOREIGN KEY (`principal_investigator_id`) REFERENCES `clinical_trials_mvm`.`site`.`principal_investigator`(`principal_investigator_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_query` ADD CONSTRAINT `fk_laboratory_lab_query_quality_event_id` FOREIGN KEY (`quality_event_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`quality_event`(`quality_event_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_query` ADD CONSTRAINT `fk_laboratory_lab_query_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_query` ADD CONSTRAINT `fk_laboratory_lab_query_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_query` ADD CONSTRAINT `fk_laboratory_lab_query_study_visit_schedule_id` FOREIGN KEY (`study_visit_schedule_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_visit_schedule`(`study_visit_schedule_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`lab_query` ADD CONSTRAINT `fk_laboratory_lab_query_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_aliquot` ADD CONSTRAINT `fk_laboratory_specimen_aliquot_blinding_config_id` FOREIGN KEY (`blinding_config_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`blinding_config`(`blinding_config_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_aliquot` ADD CONSTRAINT `fk_laboratory_specimen_aliquot_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_aliquot` ADD CONSTRAINT `fk_laboratory_specimen_aliquot_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_mvm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_aliquot` ADD CONSTRAINT `fk_laboratory_specimen_aliquot_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_aliquot` ADD CONSTRAINT `fk_laboratory_specimen_aliquot_shipment_id` FOREIGN KEY (`shipment_id`) REFERENCES `clinical_trials_mvm`.`supply`.`shipment`(`shipment_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_aliquot` ADD CONSTRAINT `fk_laboratory_specimen_aliquot_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_aliquot` ADD CONSTRAINT `fk_laboratory_specimen_aliquot_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`specimen_aliquot` ADD CONSTRAINT `fk_laboratory_specimen_aliquot_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`protocol_lab_schedule` ADD CONSTRAINT `fk_laboratory_protocol_lab_schedule_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_mvm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`protocol_lab_schedule` ADD CONSTRAINT `fk_laboratory_protocol_lab_schedule_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`protocol_lab_schedule` ADD CONSTRAINT `fk_laboratory_protocol_lab_schedule_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`protocol_lab_schedule` ADD CONSTRAINT `fk_laboratory_protocol_lab_schedule_epoch_id` FOREIGN KEY (`epoch_id`) REFERENCES `clinical_trials_mvm`.`study`.`epoch`(`epoch_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`protocol_lab_schedule` ADD CONSTRAINT `fk_laboratory_protocol_lab_schedule_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`protocol_lab_schedule` ADD CONSTRAINT `fk_laboratory_protocol_lab_schedule_regulatory_protocol_amendment_id` FOREIGN KEY (`regulatory_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment`(`regulatory_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`protocol_lab_schedule` ADD CONSTRAINT `fk_laboratory_protocol_lab_schedule_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`laboratory`.`protocol_lab_schedule` ADD CONSTRAINT `fk_laboratory_protocol_lab_schedule_treatment_arm_id` FOREIGN KEY (`treatment_arm_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`treatment_arm`(`treatment_arm_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ADD CONSTRAINT `fk_supply_imp_master_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ADD CONSTRAINT `fk_supply_imp_master_audit_id` FOREIGN KEY (`audit_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`audit`(`audit_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ADD CONSTRAINT `fk_supply_imp_master_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ADD CONSTRAINT `fk_supply_imp_master_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ADD CONSTRAINT `fk_supply_imp_master_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ADD CONSTRAINT `fk_supply_imp_master_investigational_product_id` FOREIGN KEY (`investigational_product_id`) REFERENCES `clinical_trials_mvm`.`study`.`investigational_product`(`investigational_product_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ADD CONSTRAINT `fk_supply_imp_master_regulatory_binder_id` FOREIGN KEY (`regulatory_binder_id`) REFERENCES `clinical_trials_mvm`.`document`.`regulatory_binder`(`regulatory_binder_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ADD CONSTRAINT `fk_supply_imp_master_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`imp_master` ADD CONSTRAINT `fk_supply_imp_master_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ADD CONSTRAINT `fk_supply_kit_definition_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_mvm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ADD CONSTRAINT `fk_supply_kit_definition_investigational_product_id` FOREIGN KEY (`investigational_product_id`) REFERENCES `clinical_trials_mvm`.`study`.`investigational_product`(`investigational_product_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ADD CONSTRAINT `fk_supply_kit_definition_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_definition` ADD CONSTRAINT `fk_supply_kit_definition_treatment_arm_id` FOREIGN KEY (`treatment_arm_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`treatment_arm`(`treatment_arm_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ADD CONSTRAINT `fk_supply_kit_inventory_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_mvm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ADD CONSTRAINT `fk_supply_kit_inventory_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ADD CONSTRAINT `fk_supply_kit_inventory_document_sop_id` FOREIGN KEY (`document_sop_id`) REFERENCES `clinical_trials_mvm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ADD CONSTRAINT `fk_supply_kit_inventory_dosing_regimen_id` FOREIGN KEY (`dosing_regimen_id`) REFERENCES `clinical_trials_mvm`.`study`.`dosing_regimen`(`dosing_regimen_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ADD CONSTRAINT `fk_supply_kit_inventory_enrollment_id` FOREIGN KEY (`enrollment_id`) REFERENCES `clinical_trials_mvm`.`subject`.`enrollment`(`enrollment_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ADD CONSTRAINT `fk_supply_kit_inventory_rand_code_id` FOREIGN KEY (`rand_code_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_code`(`rand_code_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ADD CONSTRAINT `fk_supply_kit_inventory_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ADD CONSTRAINT `fk_supply_kit_inventory_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ADD CONSTRAINT `fk_supply_kit_inventory_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`kit_inventory` ADD CONSTRAINT `fk_supply_kit_inventory_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ADD CONSTRAINT `fk_supply_depot_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ADD CONSTRAINT `fk_supply_depot_document_sop_id` FOREIGN KEY (`document_sop_id`) REFERENCES `clinical_trials_mvm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ADD CONSTRAINT `fk_supply_depot_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ADD CONSTRAINT `fk_supply_depot_regulatory_binder_id` FOREIGN KEY (`regulatory_binder_id`) REFERENCES `clinical_trials_mvm`.`document`.`regulatory_binder`(`regulatory_binder_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ADD CONSTRAINT `fk_supply_depot_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`depot` ADD CONSTRAINT `fk_supply_depot_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ADD CONSTRAINT `fk_supply_site_inventory_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_mvm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ADD CONSTRAINT `fk_supply_site_inventory_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ADD CONSTRAINT `fk_supply_site_inventory_document_sop_id` FOREIGN KEY (`document_sop_id`) REFERENCES `clinical_trials_mvm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ADD CONSTRAINT `fk_supply_site_inventory_site_file_id` FOREIGN KEY (`site_file_id`) REFERENCES `clinical_trials_mvm`.`document`.`site_file`(`site_file_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ADD CONSTRAINT `fk_supply_site_inventory_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ADD CONSTRAINT `fk_supply_site_inventory_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`site_inventory` ADD CONSTRAINT `fk_supply_site_inventory_treatment_arm_id` FOREIGN KEY (`treatment_arm_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`treatment_arm`(`treatment_arm_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ADD CONSTRAINT `fk_supply_supply_plan_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ADD CONSTRAINT `fk_supply_supply_plan_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ADD CONSTRAINT `fk_supply_supply_plan_dosing_regimen_id` FOREIGN KEY (`dosing_regimen_id`) REFERENCES `clinical_trials_mvm`.`study`.`dosing_regimen`(`dosing_regimen_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ADD CONSTRAINT `fk_supply_supply_plan_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ADD CONSTRAINT `fk_supply_supply_plan_interim_analysis_id` FOREIGN KEY (`interim_analysis_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`interim_analysis`(`interim_analysis_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ADD CONSTRAINT `fk_supply_supply_plan_investigational_product_id` FOREIGN KEY (`investigational_product_id`) REFERENCES `clinical_trials_mvm`.`study`.`investigational_product`(`investigational_product_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ADD CONSTRAINT `fk_supply_supply_plan_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ADD CONSTRAINT `fk_supply_supply_plan_rand_list_id` FOREIGN KEY (`rand_list_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_list`(`rand_list_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ADD CONSTRAINT `fk_supply_supply_plan_rand_scheme_id` FOREIGN KEY (`rand_scheme_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_scheme`(`rand_scheme_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ADD CONSTRAINT `fk_supply_supply_plan_regulatory_binder_id` FOREIGN KEY (`regulatory_binder_id`) REFERENCES `clinical_trials_mvm`.`document`.`regulatory_binder`(`regulatory_binder_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ADD CONSTRAINT `fk_supply_supply_plan_risk_assessment_id` FOREIGN KEY (`risk_assessment_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`risk_assessment`(`risk_assessment_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ADD CONSTRAINT `fk_supply_supply_plan_sample_size_calc_id` FOREIGN KEY (`sample_size_calc_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`sample_size_calc`(`sample_size_calc_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ADD CONSTRAINT `fk_supply_supply_plan_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`supply_plan` ADD CONSTRAINT `fk_supply_supply_plan_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ADD CONSTRAINT `fk_supply_manufacture_batch_approval_id` FOREIGN KEY (`approval_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`approval`(`approval_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ADD CONSTRAINT `fk_supply_manufacture_batch_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ADD CONSTRAINT `fk_supply_manufacture_batch_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ADD CONSTRAINT `fk_supply_manufacture_batch_investigational_product_id` FOREIGN KEY (`investigational_product_id`) REFERENCES `clinical_trials_mvm`.`study`.`investigational_product`(`investigational_product_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ADD CONSTRAINT `fk_supply_manufacture_batch_rand_scheme_id` FOREIGN KEY (`rand_scheme_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_scheme`(`rand_scheme_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ADD CONSTRAINT `fk_supply_manufacture_batch_regulatory_binder_id` FOREIGN KEY (`regulatory_binder_id`) REFERENCES `clinical_trials_mvm`.`document`.`regulatory_binder`(`regulatory_binder_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ADD CONSTRAINT `fk_supply_manufacture_batch_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`manufacture_batch` ADD CONSTRAINT `fk_supply_manufacture_batch_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ADD CONSTRAINT `fk_supply_shipment_audit_finding_id` FOREIGN KEY (`audit_finding_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`audit_finding`(`audit_finding_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ADD CONSTRAINT `fk_supply_shipment_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ADD CONSTRAINT `fk_supply_shipment_country_id` FOREIGN KEY (`country_id`) REFERENCES `clinical_trials_mvm`.`study`.`country`(`country_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ADD CONSTRAINT `fk_supply_shipment_irb_iec_approval_id` FOREIGN KEY (`irb_iec_approval_id`) REFERENCES `clinical_trials_mvm`.`site`.`irb_iec_approval`(`irb_iec_approval_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ADD CONSTRAINT `fk_supply_shipment_site_file_id` FOREIGN KEY (`site_file_id`) REFERENCES `clinical_trials_mvm`.`document`.`site_file`(`site_file_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ADD CONSTRAINT `fk_supply_shipment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ADD CONSTRAINT `fk_supply_shipment_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment` ADD CONSTRAINT `fk_supply_shipment_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` ADD CONSTRAINT `fk_supply_shipment_line_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_mvm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` ADD CONSTRAINT `fk_supply_shipment_line_rand_code_id` FOREIGN KEY (`rand_code_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_code`(`rand_code_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` ADD CONSTRAINT `fk_supply_shipment_line_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`shipment_line` ADD CONSTRAINT `fk_supply_shipment_line_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ADD CONSTRAINT `fk_supply_dispensing_record_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ADD CONSTRAINT `fk_supply_dispensing_record_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_mvm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ADD CONSTRAINT `fk_supply_dispensing_record_document_sop_id` FOREIGN KEY (`document_sop_id`) REFERENCES `clinical_trials_mvm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ADD CONSTRAINT `fk_supply_dispensing_record_dosing_regimen_id` FOREIGN KEY (`dosing_regimen_id`) REFERENCES `clinical_trials_mvm`.`study`.`dosing_regimen`(`dosing_regimen_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ADD CONSTRAINT `fk_supply_dispensing_record_enrollment_id` FOREIGN KEY (`enrollment_id`) REFERENCES `clinical_trials_mvm`.`subject`.`enrollment`(`enrollment_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ADD CONSTRAINT `fk_supply_dispensing_record_irt_transaction_id` FOREIGN KEY (`irt_transaction_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`irt_transaction`(`irt_transaction_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ADD CONSTRAINT `fk_supply_dispensing_record_kit_assignment_id` FOREIGN KEY (`kit_assignment_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`kit_assignment`(`kit_assignment_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ADD CONSTRAINT `fk_supply_dispensing_record_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ADD CONSTRAINT `fk_supply_dispensing_record_site_file_id` FOREIGN KEY (`site_file_id`) REFERENCES `clinical_trials_mvm`.`document`.`site_file`(`site_file_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ADD CONSTRAINT `fk_supply_dispensing_record_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ADD CONSTRAINT `fk_supply_dispensing_record_study_visit_schedule_id` FOREIGN KEY (`study_visit_schedule_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_visit_schedule`(`study_visit_schedule_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ADD CONSTRAINT `fk_supply_dispensing_record_subject_visit_data_id` FOREIGN KEY (`subject_visit_data_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`subject_visit_data`(`subject_visit_data_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ADD CONSTRAINT `fk_supply_dispensing_record_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`dispensing_record` ADD CONSTRAINT `fk_supply_dispensing_record_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ADD CONSTRAINT `fk_supply_return_record_document_sop_id` FOREIGN KEY (`document_sop_id`) REFERENCES `clinical_trials_mvm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ADD CONSTRAINT `fk_supply_return_record_enrollment_id` FOREIGN KEY (`enrollment_id`) REFERENCES `clinical_trials_mvm`.`subject`.`enrollment`(`enrollment_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ADD CONSTRAINT `fk_supply_return_record_quality_event_id` FOREIGN KEY (`quality_event_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`quality_event`(`quality_event_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ADD CONSTRAINT `fk_supply_return_record_rand_code_id` FOREIGN KEY (`rand_code_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_code`(`rand_code_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ADD CONSTRAINT `fk_supply_return_record_site_file_id` FOREIGN KEY (`site_file_id`) REFERENCES `clinical_trials_mvm`.`document`.`site_file`(`site_file_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ADD CONSTRAINT `fk_supply_return_record_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ADD CONSTRAINT `fk_supply_return_record_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ADD CONSTRAINT `fk_supply_return_record_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ADD CONSTRAINT `fk_supply_return_record_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ADD CONSTRAINT `fk_supply_return_record_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ADD CONSTRAINT `fk_supply_return_record_visit_report_id` FOREIGN KEY (`visit_report_id`) REFERENCES `clinical_trials_mvm`.`monitoring`.`visit_report`(`visit_report_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`return_record` ADD CONSTRAINT `fk_supply_return_record_withdrawal_id` FOREIGN KEY (`withdrawal_id`) REFERENCES `clinical_trials_mvm`.`consent`.`withdrawal`(`withdrawal_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ADD CONSTRAINT `fk_supply_destruction_record_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ADD CONSTRAINT `fk_supply_destruction_record_document_sop_id` FOREIGN KEY (`document_sop_id`) REFERENCES `clinical_trials_mvm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ADD CONSTRAINT `fk_supply_destruction_record_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ADD CONSTRAINT `fk_supply_destruction_record_monitoring_plan_id` FOREIGN KEY (`monitoring_plan_id`) REFERENCES `clinical_trials_mvm`.`monitoring`.`monitoring_plan`(`monitoring_plan_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ADD CONSTRAINT `fk_supply_destruction_record_quality_event_id` FOREIGN KEY (`quality_event_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`quality_event`(`quality_event_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ADD CONSTRAINT `fk_supply_destruction_record_site_file_id` FOREIGN KEY (`site_file_id`) REFERENCES `clinical_trials_mvm`.`document`.`site_file`(`site_file_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ADD CONSTRAINT `fk_supply_destruction_record_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ADD CONSTRAINT `fk_supply_destruction_record_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`destruction_record` ADD CONSTRAINT `fk_supply_destruction_record_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ADD CONSTRAINT `fk_supply_temperature_excursion_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ADD CONSTRAINT `fk_supply_temperature_excursion_inspection_finding_id` FOREIGN KEY (`inspection_finding_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`inspection_finding`(`inspection_finding_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ADD CONSTRAINT `fk_supply_temperature_excursion_monitoring_plan_id` FOREIGN KEY (`monitoring_plan_id`) REFERENCES `clinical_trials_mvm`.`monitoring`.`monitoring_plan`(`monitoring_plan_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ADD CONSTRAINT `fk_supply_temperature_excursion_quality_event_id` FOREIGN KEY (`quality_event_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`quality_event`(`quality_event_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ADD CONSTRAINT `fk_supply_temperature_excursion_safety_report_submission_id` FOREIGN KEY (`safety_report_submission_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`safety_report_submission`(`safety_report_submission_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ADD CONSTRAINT `fk_supply_temperature_excursion_specimen_id` FOREIGN KEY (`specimen_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`specimen`(`specimen_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ADD CONSTRAINT `fk_supply_temperature_excursion_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ADD CONSTRAINT `fk_supply_temperature_excursion_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`temperature_excursion` ADD CONSTRAINT `fk_supply_temperature_excursion_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ADD CONSTRAINT `fk_supply_accountability_reconciliation_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ADD CONSTRAINT `fk_supply_accountability_reconciliation_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_mvm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ADD CONSTRAINT `fk_supply_accountability_reconciliation_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ADD CONSTRAINT `fk_supply_accountability_reconciliation_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ADD CONSTRAINT `fk_supply_accountability_reconciliation_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ADD CONSTRAINT `fk_supply_accountability_reconciliation_inspection_finding_id` FOREIGN KEY (`inspection_finding_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`inspection_finding`(`inspection_finding_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ADD CONSTRAINT `fk_supply_accountability_reconciliation_monitoring_plan_id` FOREIGN KEY (`monitoring_plan_id`) REFERENCES `clinical_trials_mvm`.`monitoring`.`monitoring_plan`(`monitoring_plan_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ADD CONSTRAINT `fk_supply_accountability_reconciliation_monitoring_visit_schedule_id` FOREIGN KEY (`monitoring_visit_schedule_id`) REFERENCES `clinical_trials_mvm`.`monitoring`.`monitoring_visit_schedule`(`monitoring_visit_schedule_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ADD CONSTRAINT `fk_supply_accountability_reconciliation_protocol_deviation_id` FOREIGN KEY (`protocol_deviation_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`protocol_deviation`(`protocol_deviation_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ADD CONSTRAINT `fk_supply_accountability_reconciliation_quality_event_id` FOREIGN KEY (`quality_event_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`quality_event`(`quality_event_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ADD CONSTRAINT `fk_supply_accountability_reconciliation_rand_scheme_id` FOREIGN KEY (`rand_scheme_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_scheme`(`rand_scheme_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ADD CONSTRAINT `fk_supply_accountability_reconciliation_site_cra_assignment_id` FOREIGN KEY (`site_cra_assignment_id`) REFERENCES `clinical_trials_mvm`.`site`.`site_cra_assignment`(`site_cra_assignment_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ADD CONSTRAINT `fk_supply_accountability_reconciliation_site_file_id` FOREIGN KEY (`site_file_id`) REFERENCES `clinical_trials_mvm`.`document`.`site_file`(`site_file_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ADD CONSTRAINT `fk_supply_accountability_reconciliation_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ADD CONSTRAINT `fk_supply_accountability_reconciliation_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`accountability_reconciliation` ADD CONSTRAINT `fk_supply_accountability_reconciliation_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ADD CONSTRAINT `fk_supply_resupply_order_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ADD CONSTRAINT `fk_supply_resupply_order_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_mvm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ADD CONSTRAINT `fk_supply_resupply_order_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ADD CONSTRAINT `fk_supply_resupply_order_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ADD CONSTRAINT `fk_supply_resupply_order_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ADD CONSTRAINT `fk_supply_resupply_order_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ADD CONSTRAINT `fk_supply_resupply_order_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`supply`.`resupply_order` ADD CONSTRAINT `fk_supply_resupply_order_treatment_arm_id` FOREIGN KEY (`treatment_arm_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`treatment_arm`(`treatment_arm_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`monitoring_plan` ADD CONSTRAINT `fk_monitoring_monitoring_plan_blinding_config_id` FOREIGN KEY (`blinding_config_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`blinding_config`(`blinding_config_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`monitoring_plan` ADD CONSTRAINT `fk_monitoring_monitoring_plan_dmp_id` FOREIGN KEY (`dmp_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`dmp`(`dmp_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`monitoring_plan` ADD CONSTRAINT `fk_monitoring_monitoring_plan_document_sop_id` FOREIGN KEY (`document_sop_id`) REFERENCES `clinical_trials_mvm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`monitoring_plan` ADD CONSTRAINT `fk_monitoring_monitoring_plan_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`monitoring_plan` ADD CONSTRAINT `fk_monitoring_monitoring_plan_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`monitoring_plan` ADD CONSTRAINT `fk_monitoring_monitoring_plan_investigational_product_id` FOREIGN KEY (`investigational_product_id`) REFERENCES `clinical_trials_mvm`.`study`.`investigational_product`(`investigational_product_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`monitoring_plan` ADD CONSTRAINT `fk_monitoring_monitoring_plan_lab_panel_id` FOREIGN KEY (`lab_panel_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_panel`(`lab_panel_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`monitoring_plan` ADD CONSTRAINT `fk_monitoring_monitoring_plan_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`monitoring_plan` ADD CONSTRAINT `fk_monitoring_monitoring_plan_rand_scheme_id` FOREIGN KEY (`rand_scheme_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_scheme`(`rand_scheme_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`monitoring_plan` ADD CONSTRAINT `fk_monitoring_monitoring_plan_risk_assessment_id` FOREIGN KEY (`risk_assessment_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`risk_assessment`(`risk_assessment_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`monitoring_plan` ADD CONSTRAINT `fk_monitoring_monitoring_plan_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`monitoring_plan` ADD CONSTRAINT `fk_monitoring_monitoring_plan_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`monitoring_plan` ADD CONSTRAINT `fk_monitoring_monitoring_plan_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`monitoring_plan` ADD CONSTRAINT `fk_monitoring_monitoring_plan_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_report` ADD CONSTRAINT `fk_monitoring_visit_report_audit_id` FOREIGN KEY (`audit_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`audit`(`audit_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_report` ADD CONSTRAINT `fk_monitoring_visit_report_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_report` ADD CONSTRAINT `fk_monitoring_visit_report_dmp_id` FOREIGN KEY (`dmp_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`dmp`(`dmp_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_report` ADD CONSTRAINT `fk_monitoring_visit_report_epoch_id` FOREIGN KEY (`epoch_id`) REFERENCES `clinical_trials_mvm`.`study`.`epoch`(`epoch_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_report` ADD CONSTRAINT `fk_monitoring_visit_report_principal_investigator_id` FOREIGN KEY (`principal_investigator_id`) REFERENCES `clinical_trials_mvm`.`site`.`principal_investigator`(`principal_investigator_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_report` ADD CONSTRAINT `fk_monitoring_visit_report_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_report` ADD CONSTRAINT `fk_monitoring_visit_report_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_report` ADD CONSTRAINT `fk_monitoring_visit_report_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_report` ADD CONSTRAINT `fk_monitoring_visit_report_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_adverse_event_id` FOREIGN KEY (`adverse_event_id`) REFERENCES `clinical_trials_mvm`.`safety`.`adverse_event`(`adverse_event_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_ae_follow_up_id` FOREIGN KEY (`ae_follow_up_id`) REFERENCES `clinical_trials_mvm`.`safety`.`ae_follow_up`(`ae_follow_up_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_bioanalytical_result_id` FOREIGN KEY (`bioanalytical_result_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`bioanalytical_result`(`bioanalytical_result_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_causality_assessment_id` FOREIGN KEY (`causality_assessment_id`) REFERENCES `clinical_trials_mvm`.`safety`.`causality_assessment`(`causality_assessment_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_mvm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_discrepancy_query_id` FOREIGN KEY (`discrepancy_query_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`discrepancy_query`(`discrepancy_query_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_ecrf_field_id` FOREIGN KEY (`ecrf_field_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`ecrf_field`(`ecrf_field_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_ecrf_form_id` FOREIGN KEY (`ecrf_form_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`ecrf_form`(`ecrf_form_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_field_entry_id` FOREIGN KEY (`field_entry_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`field_entry`(`field_entry_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_irt_transaction_id` FOREIGN KEY (`irt_transaction_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`irt_transaction`(`irt_transaction_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_pk_sample_id` FOREIGN KEY (`pk_sample_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`pk_sample`(`pk_sample_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_protocol_deviation_id` FOREIGN KEY (`protocol_deviation_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`protocol_deviation`(`protocol_deviation_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_quality_event_id` FOREIGN KEY (`quality_event_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`quality_event`(`quality_event_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_serious_adverse_event_id` FOREIGN KEY (`serious_adverse_event_id`) REFERENCES `clinical_trials_mvm`.`safety`.`serious_adverse_event`(`serious_adverse_event_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_specimen_collection_id` FOREIGN KEY (`specimen_collection_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`specimen_collection`(`specimen_collection_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_specimen_shipment_id` FOREIGN KEY (`specimen_shipment_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`specimen_shipment`(`specimen_shipment_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_study_visit_schedule_id` FOREIGN KEY (`study_visit_schedule_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_visit_schedule`(`study_visit_schedule_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_subject_visit_data_id` FOREIGN KEY (`subject_visit_data_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`subject_visit_data`(`subject_visit_data_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`sdv_record` ADD CONSTRAINT `fk_monitoring_sdv_record_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_adverse_event_id` FOREIGN KEY (`adverse_event_id`) REFERENCES `clinical_trials_mvm`.`safety`.`adverse_event`(`adverse_event_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_mvm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_compliance_protocol_deviation_id` FOREIGN KEY (`compliance_protocol_deviation_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`protocol_deviation`(`protocol_deviation_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_mvm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_eligibility_criterion_id` FOREIGN KEY (`eligibility_criterion_id`) REFERENCES `clinical_trials_mvm`.`study`.`eligibility_criterion`(`eligibility_criterion_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_irt_transaction_id` FOREIGN KEY (`irt_transaction_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`irt_transaction`(`irt_transaction_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_serious_adverse_event_id` FOREIGN KEY (`serious_adverse_event_id`) REFERENCES `clinical_trials_mvm`.`safety`.`serious_adverse_event`(`serious_adverse_event_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_specimen_collection_id` FOREIGN KEY (`specimen_collection_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`specimen_collection`(`specimen_collection_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_specimen_shipment_id` FOREIGN KEY (`specimen_shipment_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`specimen_shipment`(`specimen_shipment_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_subject_visit_data_id` FOREIGN KEY (`subject_visit_data_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`subject_visit_data`(`subject_visit_data_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_deviation_finding` ADD CONSTRAINT `fk_monitoring_visit_deviation_finding_validation_rule_id` FOREIGN KEY (`validation_rule_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`validation_rule`(`validation_rule_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_adverse_event_id` FOREIGN KEY (`adverse_event_id`) REFERENCES `clinical_trials_mvm`.`safety`.`adverse_event`(`adverse_event_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_ae_follow_up_id` FOREIGN KEY (`ae_follow_up_id`) REFERENCES `clinical_trials_mvm`.`safety`.`ae_follow_up`(`ae_follow_up_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_causality_assessment_id` FOREIGN KEY (`causality_assessment_id`) REFERENCES `clinical_trials_mvm`.`safety`.`causality_assessment`(`causality_assessment_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_mvm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_discrepancy_query_id` FOREIGN KEY (`discrepancy_query_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`discrepancy_query`(`discrepancy_query_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_ecrf_form_id` FOREIGN KEY (`ecrf_form_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`ecrf_form`(`ecrf_form_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_eligibility_criterion_id` FOREIGN KEY (`eligibility_criterion_id`) REFERENCES `clinical_trials_mvm`.`study`.`eligibility_criterion`(`eligibility_criterion_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_protocol_deviation_id` FOREIGN KEY (`protocol_deviation_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`protocol_deviation`(`protocol_deviation_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_quality_event_id` FOREIGN KEY (`quality_event_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`quality_event`(`quality_event_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_serious_adverse_event_id` FOREIGN KEY (`serious_adverse_event_id`) REFERENCES `clinical_trials_mvm`.`safety`.`serious_adverse_event`(`serious_adverse_event_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_specimen_collection_id` FOREIGN KEY (`specimen_collection_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`specimen_collection`(`specimen_collection_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_subject_visit_data_id` FOREIGN KEY (`subject_visit_data_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`subject_visit_data`(`subject_visit_data_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_temperature_excursion_id` FOREIGN KEY (`temperature_excursion_id`) REFERENCES `clinical_trials_mvm`.`supply`.`temperature_excursion`(`temperature_excursion_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_finding` ADD CONSTRAINT `fk_monitoring_visit_finding_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`risk_indicator` ADD CONSTRAINT `fk_monitoring_risk_indicator_bioanalytical_assay_id` FOREIGN KEY (`bioanalytical_assay_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`bioanalytical_assay`(`bioanalytical_assay_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`risk_indicator` ADD CONSTRAINT `fk_monitoring_risk_indicator_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`risk_indicator` ADD CONSTRAINT `fk_monitoring_risk_indicator_endpoint_id` FOREIGN KEY (`endpoint_id`) REFERENCES `clinical_trials_mvm`.`study`.`endpoint`(`endpoint_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`risk_indicator` ADD CONSTRAINT `fk_monitoring_risk_indicator_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`risk_indicator` ADD CONSTRAINT `fk_monitoring_risk_indicator_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`risk_indicator` ADD CONSTRAINT `fk_monitoring_risk_indicator_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`risk_indicator` ADD CONSTRAINT `fk_monitoring_risk_indicator_lab_panel_id` FOREIGN KEY (`lab_panel_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_panel`(`lab_panel_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`risk_indicator` ADD CONSTRAINT `fk_monitoring_risk_indicator_rand_scheme_id` FOREIGN KEY (`rand_scheme_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_scheme`(`rand_scheme_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`risk_indicator` ADD CONSTRAINT `fk_monitoring_risk_indicator_risk_assessment_id` FOREIGN KEY (`risk_assessment_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`risk_assessment`(`risk_assessment_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`risk_indicator` ADD CONSTRAINT `fk_monitoring_risk_indicator_statistical_endpoint_id` FOREIGN KEY (`statistical_endpoint_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint`(`statistical_endpoint_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`risk_indicator` ADD CONSTRAINT `fk_monitoring_risk_indicator_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`risk_indicator` ADD CONSTRAINT `fk_monitoring_risk_indicator_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`risk_indicator` ADD CONSTRAINT `fk_monitoring_risk_indicator_validation_rule_id` FOREIGN KEY (`validation_rule_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`validation_rule`(`validation_rule_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`site_risk_assessment` ADD CONSTRAINT `fk_monitoring_site_risk_assessment_audit_finding_id` FOREIGN KEY (`audit_finding_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`audit_finding`(`audit_finding_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`site_risk_assessment` ADD CONSTRAINT `fk_monitoring_site_risk_assessment_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`site_risk_assessment` ADD CONSTRAINT `fk_monitoring_site_risk_assessment_document_sop_id` FOREIGN KEY (`document_sop_id`) REFERENCES `clinical_trials_mvm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`site_risk_assessment` ADD CONSTRAINT `fk_monitoring_site_risk_assessment_dsmb_review_id` FOREIGN KEY (`dsmb_review_id`) REFERENCES `clinical_trials_mvm`.`safety`.`dsmb_review`(`dsmb_review_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`site_risk_assessment` ADD CONSTRAINT `fk_monitoring_site_risk_assessment_endpoint_id` FOREIGN KEY (`endpoint_id`) REFERENCES `clinical_trials_mvm`.`study`.`endpoint`(`endpoint_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`site_risk_assessment` ADD CONSTRAINT `fk_monitoring_site_risk_assessment_inspection_finding_id` FOREIGN KEY (`inspection_finding_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`inspection_finding`(`inspection_finding_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`site_risk_assessment` ADD CONSTRAINT `fk_monitoring_site_risk_assessment_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`site_risk_assessment` ADD CONSTRAINT `fk_monitoring_site_risk_assessment_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`site_risk_assessment` ADD CONSTRAINT `fk_monitoring_site_risk_assessment_principal_investigator_id` FOREIGN KEY (`principal_investigator_id`) REFERENCES `clinical_trials_mvm`.`site`.`principal_investigator`(`principal_investigator_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`site_risk_assessment` ADD CONSTRAINT `fk_monitoring_site_risk_assessment_risk_assessment_id` FOREIGN KEY (`risk_assessment_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`risk_assessment`(`risk_assessment_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`site_risk_assessment` ADD CONSTRAINT `fk_monitoring_site_risk_assessment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`site_risk_assessment` ADD CONSTRAINT `fk_monitoring_site_risk_assessment_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`site_risk_assessment` ADD CONSTRAINT `fk_monitoring_site_risk_assessment_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`monitoring_cra_assignment` ADD CONSTRAINT `fk_monitoring_monitoring_cra_assignment_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`monitoring_cra_assignment` ADD CONSTRAINT `fk_monitoring_monitoring_cra_assignment_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`monitoring_cra_assignment` ADD CONSTRAINT `fk_monitoring_monitoring_cra_assignment_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`monitoring_cra_assignment` ADD CONSTRAINT `fk_monitoring_monitoring_cra_assignment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`monitoring_cra_assignment` ADD CONSTRAINT `fk_monitoring_monitoring_cra_assignment_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`monitoring_visit_schedule` ADD CONSTRAINT `fk_monitoring_monitoring_visit_schedule_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`monitoring_visit_schedule` ADD CONSTRAINT `fk_monitoring_monitoring_visit_schedule_epoch_id` FOREIGN KEY (`epoch_id`) REFERENCES `clinical_trials_mvm`.`study`.`epoch`(`epoch_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`monitoring_visit_schedule` ADD CONSTRAINT `fk_monitoring_monitoring_visit_schedule_ethics_approval_id` FOREIGN KEY (`ethics_approval_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`ethics_approval`(`ethics_approval_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`monitoring_visit_schedule` ADD CONSTRAINT `fk_monitoring_monitoring_visit_schedule_interim_analysis_id` FOREIGN KEY (`interim_analysis_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`interim_analysis`(`interim_analysis_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`monitoring_visit_schedule` ADD CONSTRAINT `fk_monitoring_monitoring_visit_schedule_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`monitoring_visit_schedule` ADD CONSTRAINT `fk_monitoring_monitoring_visit_schedule_protocol_lab_schedule_id` FOREIGN KEY (`protocol_lab_schedule_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`protocol_lab_schedule`(`protocol_lab_schedule_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`monitoring_visit_schedule` ADD CONSTRAINT `fk_monitoring_monitoring_visit_schedule_reconsent_trigger_id` FOREIGN KEY (`reconsent_trigger_id`) REFERENCES `clinical_trials_mvm`.`consent`.`reconsent_trigger`(`reconsent_trigger_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`monitoring_visit_schedule` ADD CONSTRAINT `fk_monitoring_monitoring_visit_schedule_signal_id` FOREIGN KEY (`signal_id`) REFERENCES `clinical_trials_mvm`.`safety`.`signal`(`signal_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`monitoring_visit_schedule` ADD CONSTRAINT `fk_monitoring_monitoring_visit_schedule_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`monitoring_visit_schedule` ADD CONSTRAINT `fk_monitoring_monitoring_visit_schedule_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`monitoring_visit_schedule` ADD CONSTRAINT `fk_monitoring_monitoring_visit_schedule_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`monitoring_visit_schedule` ADD CONSTRAINT `fk_monitoring_monitoring_visit_schedule_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`ip_accountability_log` ADD CONSTRAINT `fk_monitoring_ip_accountability_log_accountability_reconciliation_id` FOREIGN KEY (`accountability_reconciliation_id`) REFERENCES `clinical_trials_mvm`.`supply`.`accountability_reconciliation`(`accountability_reconciliation_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`ip_accountability_log` ADD CONSTRAINT `fk_monitoring_ip_accountability_log_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_mvm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`ip_accountability_log` ADD CONSTRAINT `fk_monitoring_ip_accountability_log_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_mvm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`ip_accountability_log` ADD CONSTRAINT `fk_monitoring_ip_accountability_log_destruction_record_id` FOREIGN KEY (`destruction_record_id`) REFERENCES `clinical_trials_mvm`.`supply`.`destruction_record`(`destruction_record_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`ip_accountability_log` ADD CONSTRAINT `fk_monitoring_ip_accountability_log_document_sop_id` FOREIGN KEY (`document_sop_id`) REFERENCES `clinical_trials_mvm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`ip_accountability_log` ADD CONSTRAINT `fk_monitoring_ip_accountability_log_dosing_regimen_id` FOREIGN KEY (`dosing_regimen_id`) REFERENCES `clinical_trials_mvm`.`study`.`dosing_regimen`(`dosing_regimen_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`ip_accountability_log` ADD CONSTRAINT `fk_monitoring_ip_accountability_log_investigational_product_id` FOREIGN KEY (`investigational_product_id`) REFERENCES `clinical_trials_mvm`.`study`.`investigational_product`(`investigational_product_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`ip_accountability_log` ADD CONSTRAINT `fk_monitoring_ip_accountability_log_irt_transaction_id` FOREIGN KEY (`irt_transaction_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`irt_transaction`(`irt_transaction_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`ip_accountability_log` ADD CONSTRAINT `fk_monitoring_ip_accountability_log_kit_inventory_id` FOREIGN KEY (`kit_inventory_id`) REFERENCES `clinical_trials_mvm`.`supply`.`kit_inventory`(`kit_inventory_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`ip_accountability_log` ADD CONSTRAINT `fk_monitoring_ip_accountability_log_randomization_kit_assignment_id` FOREIGN KEY (`randomization_kit_assignment_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`kit_assignment`(`kit_assignment_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`ip_accountability_log` ADD CONSTRAINT `fk_monitoring_ip_accountability_log_reconciliation_id` FOREIGN KEY (`reconciliation_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`reconciliation`(`reconciliation_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`ip_accountability_log` ADD CONSTRAINT `fk_monitoring_ip_accountability_log_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`ip_accountability_log` ADD CONSTRAINT `fk_monitoring_ip_accountability_log_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`ip_accountability_log` ADD CONSTRAINT `fk_monitoring_ip_accountability_log_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_adverse_event_id` FOREIGN KEY (`adverse_event_id`) REFERENCES `clinical_trials_mvm`.`safety`.`adverse_event`(`adverse_event_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_mvm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_audit_finding_id` FOREIGN KEY (`audit_finding_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`audit_finding`(`audit_finding_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_bioanalytical_result_id` FOREIGN KEY (`bioanalytical_result_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`bioanalytical_result`(`bioanalytical_result_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_mvm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_discrepancy_query_id` FOREIGN KEY (`discrepancy_query_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`discrepancy_query`(`discrepancy_query_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_dsmb_review_id` FOREIGN KEY (`dsmb_review_id`) REFERENCES `clinical_trials_mvm`.`safety`.`dsmb_review`(`dsmb_review_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_ethics_committee_id` FOREIGN KEY (`ethics_committee_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`ethics_committee`(`ethics_committee_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_icsr_id` FOREIGN KEY (`icsr_id`) REFERENCES `clinical_trials_mvm`.`safety`.`icsr`(`icsr_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_inspection_finding_id` FOREIGN KEY (`inspection_finding_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`inspection_finding`(`inspection_finding_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_protocol_deviation_id` FOREIGN KEY (`protocol_deviation_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`protocol_deviation`(`protocol_deviation_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_quality_event_id` FOREIGN KEY (`quality_event_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`quality_event`(`quality_event_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_reconsent_trigger_id` FOREIGN KEY (`reconsent_trigger_id`) REFERENCES `clinical_trials_mvm`.`consent`.`reconsent_trigger`(`reconsent_trigger_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_safety_report_submission_id` FOREIGN KEY (`safety_report_submission_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`safety_report_submission`(`safety_report_submission_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_serious_adverse_event_id` FOREIGN KEY (`serious_adverse_event_id`) REFERENCES `clinical_trials_mvm`.`safety`.`serious_adverse_event`(`serious_adverse_event_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_signal_id` FOREIGN KEY (`signal_id`) REFERENCES `clinical_trials_mvm`.`safety`.`signal`(`signal_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_specimen_collection_id` FOREIGN KEY (`specimen_collection_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`specimen_collection`(`specimen_collection_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_specimen_shipment_id` FOREIGN KEY (`specimen_shipment_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`specimen_shipment`(`specimen_shipment_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_susar_id` FOREIGN KEY (`susar_id`) REFERENCES `clinical_trials_mvm`.`safety`.`susar`(`susar_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_unblinding_request_id` FOREIGN KEY (`unblinding_request_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`unblinding_request`(`unblinding_request_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`escalation_record` ADD CONSTRAINT `fk_monitoring_escalation_record_withdrawal_id` FOREIGN KEY (`withdrawal_id`) REFERENCES `clinical_trials_mvm`.`consent`.`withdrawal`(`withdrawal_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_checklist` ADD CONSTRAINT `fk_monitoring_visit_checklist_audit_finding_id` FOREIGN KEY (`audit_finding_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`audit_finding`(`audit_finding_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_checklist` ADD CONSTRAINT `fk_monitoring_visit_checklist_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_checklist` ADD CONSTRAINT `fk_monitoring_visit_checklist_document_sop_id` FOREIGN KEY (`document_sop_id`) REFERENCES `clinical_trials_mvm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_checklist` ADD CONSTRAINT `fk_monitoring_visit_checklist_ethics_approval_id` FOREIGN KEY (`ethics_approval_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`ethics_approval`(`ethics_approval_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_checklist` ADD CONSTRAINT `fk_monitoring_visit_checklist_lab_kit_id` FOREIGN KEY (`lab_kit_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_kit`(`lab_kit_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_checklist` ADD CONSTRAINT `fk_monitoring_visit_checklist_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_checklist` ADD CONSTRAINT `fk_monitoring_visit_checklist_protocol_lab_schedule_id` FOREIGN KEY (`protocol_lab_schedule_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`protocol_lab_schedule`(`protocol_lab_schedule_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_checklist` ADD CONSTRAINT `fk_monitoring_visit_checklist_specimen_collection_id` FOREIGN KEY (`specimen_collection_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`specimen_collection`(`specimen_collection_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_checklist` ADD CONSTRAINT `fk_monitoring_visit_checklist_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_checklist` ADD CONSTRAINT `fk_monitoring_visit_checklist_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_checklist` ADD CONSTRAINT `fk_monitoring_visit_checklist_study_visit_schedule_id` FOREIGN KEY (`study_visit_schedule_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_visit_schedule`(`study_visit_schedule_id`);

ALTER TABLE `clinical_trials_mvm`.`monitoring`.`visit_checklist` ADD CONSTRAINT `fk_monitoring_visit_checklist_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ADD CONSTRAINT `fk_biostatistics_sap_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ADD CONSTRAINT `fk_biostatistics_sap_audit_finding_id` FOREIGN KEY (`audit_finding_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`audit_finding`(`audit_finding_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ADD CONSTRAINT `fk_biostatistics_sap_blinding_config_id` FOREIGN KEY (`blinding_config_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`blinding_config`(`blinding_config_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ADD CONSTRAINT `fk_biostatistics_sap_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ADD CONSTRAINT `fk_biostatistics_sap_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ADD CONSTRAINT `fk_biostatistics_sap_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ADD CONSTRAINT `fk_biostatistics_sap_rand_scheme_id` FOREIGN KEY (`rand_scheme_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_scheme`(`rand_scheme_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ADD CONSTRAINT `fk_biostatistics_sap_regulatory_protocol_amendment_id` FOREIGN KEY (`regulatory_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment`(`regulatory_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ADD CONSTRAINT `fk_biostatistics_sap_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ADD CONSTRAINT `fk_biostatistics_sap_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap` ADD CONSTRAINT `fk_biostatistics_sap_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ADD CONSTRAINT `fk_biostatistics_sap_amendment_audit_finding_id` FOREIGN KEY (`audit_finding_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`audit_finding`(`audit_finding_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ADD CONSTRAINT `fk_biostatistics_sap_amendment_blinding_config_id` FOREIGN KEY (`blinding_config_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`blinding_config`(`blinding_config_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ADD CONSTRAINT `fk_biostatistics_sap_amendment_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ADD CONSTRAINT `fk_biostatistics_sap_amendment_icf_amendment_id` FOREIGN KEY (`icf_amendment_id`) REFERENCES `clinical_trials_mvm`.`consent`.`icf_amendment`(`icf_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ADD CONSTRAINT `fk_biostatistics_sap_amendment_inspection_finding_id` FOREIGN KEY (`inspection_finding_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`inspection_finding`(`inspection_finding_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ADD CONSTRAINT `fk_biostatistics_sap_amendment_rand_scheme_id` FOREIGN KEY (`rand_scheme_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_scheme`(`rand_scheme_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ADD CONSTRAINT `fk_biostatistics_sap_amendment_regulatory_protocol_amendment_id` FOREIGN KEY (`regulatory_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment`(`regulatory_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ADD CONSTRAINT `fk_biostatistics_sap_amendment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ADD CONSTRAINT `fk_biostatistics_sap_amendment_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sap_amendment` ADD CONSTRAINT `fk_biostatistics_sap_amendment_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ADD CONSTRAINT `fk_biostatistics_analysis_population_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ADD CONSTRAINT `fk_biostatistics_analysis_population_rand_scheme_id` FOREIGN KEY (`rand_scheme_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_scheme`(`rand_scheme_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ADD CONSTRAINT `fk_biostatistics_analysis_population_regulatory_protocol_amendment_id` FOREIGN KEY (`regulatory_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment`(`regulatory_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ADD CONSTRAINT `fk_biostatistics_analysis_population_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`analysis_population` ADD CONSTRAINT `fk_biostatistics_analysis_population_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ADD CONSTRAINT `fk_biostatistics_sample_size_calc_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_mvm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ADD CONSTRAINT `fk_biostatistics_sample_size_calc_endpoint_id` FOREIGN KEY (`endpoint_id`) REFERENCES `clinical_trials_mvm`.`study`.`endpoint`(`endpoint_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ADD CONSTRAINT `fk_biostatistics_sample_size_calc_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ADD CONSTRAINT `fk_biostatistics_sample_size_calc_rand_scheme_id` FOREIGN KEY (`rand_scheme_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_scheme`(`rand_scheme_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`sample_size_calc` ADD CONSTRAINT `fk_biostatistics_sample_size_calc_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ADD CONSTRAINT `fk_biostatistics_adam_dataset_spec_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ADD CONSTRAINT `fk_biostatistics_adam_dataset_spec_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ADD CONSTRAINT `fk_biostatistics_adam_dataset_spec_sdtm_dataset_id` FOREIGN KEY (`sdtm_dataset_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset`(`sdtm_dataset_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ADD CONSTRAINT `fk_biostatistics_adam_dataset_spec_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ADD CONSTRAINT `fk_biostatistics_adam_dataset_spec_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ADD CONSTRAINT `fk_biostatistics_adam_dataset_spec_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`adam_dataset_spec` ADD CONSTRAINT `fk_biostatistics_adam_dataset_spec_treatment_arm_id` FOREIGN KEY (`treatment_arm_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`treatment_arm`(`treatment_arm_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ADD CONSTRAINT `fk_biostatistics_tlf_shell_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_mvm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ADD CONSTRAINT `fk_biostatistics_tlf_shell_blinding_config_id` FOREIGN KEY (`blinding_config_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`blinding_config`(`blinding_config_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ADD CONSTRAINT `fk_biostatistics_tlf_shell_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ADD CONSTRAINT `fk_biostatistics_tlf_shell_endpoint_id` FOREIGN KEY (`endpoint_id`) REFERENCES `clinical_trials_mvm`.`study`.`endpoint`(`endpoint_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ADD CONSTRAINT `fk_biostatistics_tlf_shell_randomization_treatment_arm_id` FOREIGN KEY (`randomization_treatment_arm_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`treatment_arm`(`treatment_arm_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_shell` ADD CONSTRAINT `fk_biostatistics_tlf_shell_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ADD CONSTRAINT `fk_biostatistics_tlf_output_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ADD CONSTRAINT `fk_biostatistics_tlf_output_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`tlf_output` ADD CONSTRAINT `fk_biostatistics_tlf_output_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ADD CONSTRAINT `fk_biostatistics_interim_analysis_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ADD CONSTRAINT `fk_biostatistics_interim_analysis_blinding_config_id` FOREIGN KEY (`blinding_config_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`blinding_config`(`blinding_config_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ADD CONSTRAINT `fk_biostatistics_interim_analysis_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ADD CONSTRAINT `fk_biostatistics_interim_analysis_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ADD CONSTRAINT `fk_biostatistics_interim_analysis_epoch_id` FOREIGN KEY (`epoch_id`) REFERENCES `clinical_trials_mvm`.`study`.`epoch`(`epoch_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ADD CONSTRAINT `fk_biostatistics_interim_analysis_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ADD CONSTRAINT `fk_biostatistics_interim_analysis_rand_list_id` FOREIGN KEY (`rand_list_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_list`(`rand_list_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ADD CONSTRAINT `fk_biostatistics_interim_analysis_sdtm_dataset_id` FOREIGN KEY (`sdtm_dataset_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset`(`sdtm_dataset_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ADD CONSTRAINT `fk_biostatistics_interim_analysis_stratification_factor_id` FOREIGN KEY (`stratification_factor_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`stratification_factor`(`stratification_factor_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ADD CONSTRAINT `fk_biostatistics_interim_analysis_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ADD CONSTRAINT `fk_biostatistics_interim_analysis_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ADD CONSTRAINT `fk_biostatistics_interim_analysis_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`interim_analysis` ADD CONSTRAINT `fk_biostatistics_interim_analysis_treatment_arm_id` FOREIGN KEY (`treatment_arm_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`treatment_arm`(`treatment_arm_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ADD CONSTRAINT `fk_biostatistics_database_lock_event_audit_id` FOREIGN KEY (`audit_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`audit`(`audit_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ADD CONSTRAINT `fk_biostatistics_database_lock_event_blinding_config_id` FOREIGN KEY (`blinding_config_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`blinding_config`(`blinding_config_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ADD CONSTRAINT `fk_biostatistics_database_lock_event_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ADD CONSTRAINT `fk_biostatistics_database_lock_event_dmp_id` FOREIGN KEY (`dmp_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`dmp`(`dmp_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ADD CONSTRAINT `fk_biostatistics_database_lock_event_monitoring_plan_id` FOREIGN KEY (`monitoring_plan_id`) REFERENCES `clinical_trials_mvm`.`monitoring`.`monitoring_plan`(`monitoring_plan_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ADD CONSTRAINT `fk_biostatistics_database_lock_event_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ADD CONSTRAINT `fk_biostatistics_database_lock_event_rand_list_id` FOREIGN KEY (`rand_list_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`rand_list`(`rand_list_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ADD CONSTRAINT `fk_biostatistics_database_lock_event_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ADD CONSTRAINT `fk_biostatistics_database_lock_event_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ADD CONSTRAINT `fk_biostatistics_database_lock_event_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`database_lock_event` ADD CONSTRAINT `fk_biostatistics_database_lock_event_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ADD CONSTRAINT `fk_biostatistics_statistical_endpoint_lab_panel_id` FOREIGN KEY (`lab_panel_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_panel`(`lab_panel_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ADD CONSTRAINT `fk_biostatistics_statistical_endpoint_protocol_endpoint_id` FOREIGN KEY (`protocol_endpoint_id`) REFERENCES `clinical_trials_mvm`.`study`.`endpoint`(`endpoint_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ADD CONSTRAINT `fk_biostatistics_statistical_endpoint_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`biostatistics`.`statistical_endpoint` ADD CONSTRAINT `fk_biostatistics_statistical_endpoint_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ADD CONSTRAINT `fk_consent_consent_subject_consent_ethics_approval_id` FOREIGN KEY (`ethics_approval_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`ethics_approval`(`ethics_approval_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ADD CONSTRAINT `fk_consent_consent_subject_consent_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ADD CONSTRAINT `fk_consent_consent_subject_consent_irb_iec_approval_id` FOREIGN KEY (`irb_iec_approval_id`) REFERENCES `clinical_trials_mvm`.`site`.`irb_iec_approval`(`irb_iec_approval_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ADD CONSTRAINT `fk_consent_consent_subject_consent_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ADD CONSTRAINT `fk_consent_consent_subject_consent_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ADD CONSTRAINT `fk_consent_consent_subject_consent_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`consent_subject_consent` ADD CONSTRAINT `fk_consent_consent_subject_consent_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ADD CONSTRAINT `fk_consent_econsent_session_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ADD CONSTRAINT `fk_consent_econsent_session_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ADD CONSTRAINT `fk_consent_econsent_session_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`econsent_session` ADD CONSTRAINT `fk_consent_econsent_session_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ADD CONSTRAINT `fk_consent_reconsent_trigger_compliance_protocol_deviation_id` FOREIGN KEY (`compliance_protocol_deviation_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`protocol_deviation`(`protocol_deviation_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ADD CONSTRAINT `fk_consent_reconsent_trigger_country_id` FOREIGN KEY (`country_id`) REFERENCES `clinical_trials_mvm`.`study`.`country`(`country_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ADD CONSTRAINT `fk_consent_reconsent_trigger_dsmb_recommendation_id` FOREIGN KEY (`dsmb_recommendation_id`) REFERENCES `clinical_trials_mvm`.`safety`.`dsmb_recommendation`(`dsmb_recommendation_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ADD CONSTRAINT `fk_consent_reconsent_trigger_enrollment_id` FOREIGN KEY (`enrollment_id`) REFERENCES `clinical_trials_mvm`.`subject`.`enrollment`(`enrollment_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ADD CONSTRAINT `fk_consent_reconsent_trigger_irb_iec_approval_id` FOREIGN KEY (`irb_iec_approval_id`) REFERENCES `clinical_trials_mvm`.`site`.`irb_iec_approval`(`irb_iec_approval_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ADD CONSTRAINT `fk_consent_reconsent_trigger_safety_report_submission_id` FOREIGN KEY (`safety_report_submission_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`safety_report_submission`(`safety_report_submission_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ADD CONSTRAINT `fk_consent_reconsent_trigger_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ADD CONSTRAINT `fk_consent_reconsent_trigger_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ADD CONSTRAINT `fk_consent_reconsent_trigger_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ADD CONSTRAINT `fk_consent_reconsent_trigger_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ADD CONSTRAINT `fk_consent_reconsent_trigger_susar_id` FOREIGN KEY (`susar_id`) REFERENCES `clinical_trials_mvm`.`safety`.`susar`(`susar_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ADD CONSTRAINT `fk_consent_reconsent_trigger_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`reconsent_trigger` ADD CONSTRAINT `fk_consent_reconsent_trigger_triggering_submission_id` FOREIGN KEY (`triggering_submission_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ADD CONSTRAINT `fk_consent_capacity_assessment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ADD CONSTRAINT `fk_consent_capacity_assessment_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ADD CONSTRAINT `fk_consent_capacity_assessment_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`capacity_assessment` ADD CONSTRAINT `fk_consent_capacity_assessment_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ADD CONSTRAINT `fk_consent_withdrawal_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ADD CONSTRAINT `fk_consent_withdrawal_subject_randomization_id` FOREIGN KEY (`subject_randomization_id`) REFERENCES `clinical_trials_mvm`.`randomization`.`subject_randomization`(`subject_randomization_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ADD CONSTRAINT `fk_consent_withdrawal_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`withdrawal` ADD CONSTRAINT `fk_consent_withdrawal_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ADD CONSTRAINT `fk_consent_lar_representative_legal_authority_tmf_document_id` FOREIGN KEY (`legal_authority_tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ADD CONSTRAINT `fk_consent_lar_representative_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ADD CONSTRAINT `fk_consent_lar_representative_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`lar_representative` ADD CONSTRAINT `fk_consent_lar_representative_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ADD CONSTRAINT `fk_consent_icf_amendment_clinpal_workflow_id` FOREIGN KEY (`clinpal_workflow_id`) REFERENCES `clinical_trials_mvm`.`document`.`workflow`(`workflow_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ADD CONSTRAINT `fk_consent_icf_amendment_country_id` FOREIGN KEY (`country_id`) REFERENCES `clinical_trials_mvm`.`study`.`country`(`country_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ADD CONSTRAINT `fk_consent_icf_amendment_ethics_approval_id` FOREIGN KEY (`ethics_approval_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`ethics_approval`(`ethics_approval_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ADD CONSTRAINT `fk_consent_icf_amendment_ethics_submission_id` FOREIGN KEY (`ethics_submission_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`ethics_submission`(`ethics_submission_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ADD CONSTRAINT `fk_consent_icf_amendment_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ADD CONSTRAINT `fk_consent_icf_amendment_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ADD CONSTRAINT `fk_consent_icf_amendment_regulatory_binder_id` FOREIGN KEY (`regulatory_binder_id`) REFERENCES `clinical_trials_mvm`.`document`.`regulatory_binder`(`regulatory_binder_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ADD CONSTRAINT `fk_consent_icf_amendment_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ADD CONSTRAINT `fk_consent_icf_amendment_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ADD CONSTRAINT `fk_consent_icf_amendment_susar_id` FOREIGN KEY (`susar_id`) REFERENCES `clinical_trials_mvm`.`safety`.`susar`(`susar_id`);

ALTER TABLE `clinical_trials_mvm`.`consent`.`icf_amendment` ADD CONSTRAINT `fk_consent_icf_amendment_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ADD CONSTRAINT `fk_randomization_rand_scheme_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ADD CONSTRAINT `fk_randomization_rand_scheme_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ADD CONSTRAINT `fk_randomization_rand_scheme_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ADD CONSTRAINT `fk_randomization_rand_scheme_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_scheme` ADD CONSTRAINT `fk_randomization_rand_scheme_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ADD CONSTRAINT `fk_randomization_rand_list_document_sop_id` FOREIGN KEY (`document_sop_id`) REFERENCES `clinical_trials_mvm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ADD CONSTRAINT `fk_randomization_rand_list_epoch_id` FOREIGN KEY (`epoch_id`) REFERENCES `clinical_trials_mvm`.`study`.`epoch`(`epoch_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ADD CONSTRAINT `fk_randomization_rand_list_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ADD CONSTRAINT `fk_randomization_rand_list_regulatory_protocol_amendment_id` FOREIGN KEY (`regulatory_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment`(`regulatory_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ADD CONSTRAINT `fk_randomization_rand_list_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_list` ADD CONSTRAINT `fk_randomization_rand_list_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ADD CONSTRAINT `fk_randomization_rand_code_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ADD CONSTRAINT `fk_randomization_rand_code_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ADD CONSTRAINT `fk_randomization_rand_code_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`rand_code` ADD CONSTRAINT `fk_randomization_rand_code_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ADD CONSTRAINT `fk_randomization_treatment_arm_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_mvm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ADD CONSTRAINT `fk_randomization_treatment_arm_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ADD CONSTRAINT `fk_randomization_treatment_arm_investigational_product_id` FOREIGN KEY (`investigational_product_id`) REFERENCES `clinical_trials_mvm`.`study`.`investigational_product`(`investigational_product_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`treatment_arm` ADD CONSTRAINT `fk_randomization_treatment_arm_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ADD CONSTRAINT `fk_randomization_stratification_factor_regulatory_protocol_amendment_id` FOREIGN KEY (`regulatory_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment`(`regulatory_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`stratification_factor` ADD CONSTRAINT `fk_randomization_stratification_factor_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ADD CONSTRAINT `fk_randomization_subject_randomization_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_mvm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ADD CONSTRAINT `fk_randomization_subject_randomization_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ADD CONSTRAINT `fk_randomization_subject_randomization_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ADD CONSTRAINT `fk_randomization_subject_randomization_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ADD CONSTRAINT `fk_randomization_subject_randomization_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ADD CONSTRAINT `fk_randomization_subject_randomization_study_visit_schedule_id` FOREIGN KEY (`study_visit_schedule_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_visit_schedule`(`study_visit_schedule_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`subject_randomization` ADD CONSTRAINT `fk_randomization_subject_randomization_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ADD CONSTRAINT `fk_randomization_irt_transaction_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ADD CONSTRAINT `fk_randomization_irt_transaction_depot_id` FOREIGN KEY (`depot_id`) REFERENCES `clinical_trials_mvm`.`supply`.`depot`(`depot_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ADD CONSTRAINT `fk_randomization_irt_transaction_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ADD CONSTRAINT `fk_randomization_irt_transaction_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ADD CONSTRAINT `fk_randomization_irt_transaction_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ADD CONSTRAINT `fk_randomization_irt_transaction_study_visit_schedule_id` FOREIGN KEY (`study_visit_schedule_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_visit_schedule`(`study_visit_schedule_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`irt_transaction` ADD CONSTRAINT `fk_randomization_irt_transaction_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ADD CONSTRAINT `fk_randomization_kit_assignment_kit_inventory_id` FOREIGN KEY (`kit_inventory_id`) REFERENCES `clinical_trials_mvm`.`supply`.`kit_inventory`(`kit_inventory_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ADD CONSTRAINT `fk_randomization_kit_assignment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ADD CONSTRAINT `fk_randomization_kit_assignment_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ADD CONSTRAINT `fk_randomization_kit_assignment_study_visit_schedule_id` FOREIGN KEY (`study_visit_schedule_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_visit_schedule`(`study_visit_schedule_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`kit_assignment` ADD CONSTRAINT `fk_randomization_kit_assignment_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ADD CONSTRAINT `fk_randomization_blinding_config_document_sop_id` FOREIGN KEY (`document_sop_id`) REFERENCES `clinical_trials_mvm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`blinding_config` ADD CONSTRAINT `fk_randomization_blinding_config_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ADD CONSTRAINT `fk_randomization_unblinding_request_clinical_trial_authorization_id` FOREIGN KEY (`clinical_trial_authorization_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization`(`clinical_trial_authorization_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ADD CONSTRAINT `fk_randomization_unblinding_request_document_sop_id` FOREIGN KEY (`document_sop_id`) REFERENCES `clinical_trials_mvm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ADD CONSTRAINT `fk_randomization_unblinding_request_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ADD CONSTRAINT `fk_randomization_unblinding_request_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ADD CONSTRAINT `fk_randomization_unblinding_request_principal_investigator_id` FOREIGN KEY (`principal_investigator_id`) REFERENCES `clinical_trials_mvm`.`site`.`principal_investigator`(`principal_investigator_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ADD CONSTRAINT `fk_randomization_unblinding_request_protocol_deviation_id` FOREIGN KEY (`protocol_deviation_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`protocol_deviation`(`protocol_deviation_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ADD CONSTRAINT `fk_randomization_unblinding_request_quality_event_id` FOREIGN KEY (`quality_event_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`quality_event`(`quality_event_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ADD CONSTRAINT `fk_randomization_unblinding_request_serious_adverse_event_id` FOREIGN KEY (`serious_adverse_event_id`) REFERENCES `clinical_trials_mvm`.`safety`.`serious_adverse_event`(`serious_adverse_event_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ADD CONSTRAINT `fk_randomization_unblinding_request_sop_version_id` FOREIGN KEY (`sop_version_id`) REFERENCES `clinical_trials_mvm`.`document`.`version`(`version_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ADD CONSTRAINT `fk_randomization_unblinding_request_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ADD CONSTRAINT `fk_randomization_unblinding_request_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ADD CONSTRAINT `fk_randomization_unblinding_request_susar_id` FOREIGN KEY (`susar_id`) REFERENCES `clinical_trials_mvm`.`safety`.`susar`(`susar_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ADD CONSTRAINT `fk_randomization_unblinding_request_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_request` ADD CONSTRAINT `fk_randomization_unblinding_request_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ADD CONSTRAINT `fk_randomization_unblinding_approval_document_sop_id` FOREIGN KEY (`document_sop_id`) REFERENCES `clinical_trials_mvm`.`document`.`document_sop`(`document_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ADD CONSTRAINT `fk_randomization_unblinding_approval_electronic_signature_id` FOREIGN KEY (`electronic_signature_id`) REFERENCES `clinical_trials_mvm`.`document`.`signature`(`signature_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ADD CONSTRAINT `fk_randomization_unblinding_approval_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ADD CONSTRAINT `fk_randomization_unblinding_approval_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ADD CONSTRAINT `fk_randomization_unblinding_approval_serious_adverse_event_id` FOREIGN KEY (`serious_adverse_event_id`) REFERENCES `clinical_trials_mvm`.`safety`.`serious_adverse_event`(`serious_adverse_event_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ADD CONSTRAINT `fk_randomization_unblinding_approval_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ADD CONSTRAINT `fk_randomization_unblinding_approval_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ADD CONSTRAINT `fk_randomization_unblinding_approval_susar_id` FOREIGN KEY (`susar_id`) REFERENCES `clinical_trials_mvm`.`safety`.`susar`(`susar_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ADD CONSTRAINT `fk_randomization_unblinding_approval_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`randomization`.`unblinding_approval` ADD CONSTRAINT `fk_randomization_unblinding_approval_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ADD CONSTRAINT `fk_regulatory_submission_controlled_terminology_codelist_id` FOREIGN KEY (`controlled_terminology_codelist_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`codelist`(`codelist_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ADD CONSTRAINT `fk_regulatory_submission_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission` ADD CONSTRAINT `fk_regulatory_submission_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ADD CONSTRAINT `fk_regulatory_application_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`application` ADD CONSTRAINT `fk_regulatory_application_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ADD CONSTRAINT `fk_regulatory_submission_sequence_regulatory_binder_id` FOREIGN KEY (`regulatory_binder_id`) REFERENCES `clinical_trials_mvm`.`document`.`regulatory_binder`(`regulatory_binder_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`submission_sequence` ADD CONSTRAINT `fk_regulatory_submission_sequence_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ADD CONSTRAINT `fk_regulatory_regulatory_protocol_amendment_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ADD CONSTRAINT `fk_regulatory_regulatory_protocol_amendment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`regulatory_protocol_amendment` ADD CONSTRAINT `fk_regulatory_regulatory_protocol_amendment_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ADD CONSTRAINT `fk_regulatory_approval_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`approval` ADD CONSTRAINT `fk_regulatory_approval_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ADD CONSTRAINT `fk_regulatory_ind_application_audit_id` FOREIGN KEY (`audit_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`audit`(`audit_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ADD CONSTRAINT `fk_regulatory_ind_application_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`ind_application` ADD CONSTRAINT `fk_regulatory_ind_application_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ADD CONSTRAINT `fk_regulatory_nda_bla_application_audit_id` FOREIGN KEY (`audit_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`audit`(`audit_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ADD CONSTRAINT `fk_regulatory_nda_bla_application_regulatory_binder_id` FOREIGN KEY (`regulatory_binder_id`) REFERENCES `clinical_trials_mvm`.`document`.`regulatory_binder`(`regulatory_binder_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`nda_bla_application` ADD CONSTRAINT `fk_regulatory_nda_bla_application_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ADD CONSTRAINT `fk_regulatory_safety_report_submission_icsr_id` FOREIGN KEY (`icsr_id`) REFERENCES `clinical_trials_mvm`.`safety`.`icsr`(`icsr_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ADD CONSTRAINT `fk_regulatory_safety_report_submission_sdtm_dataset_id` FOREIGN KEY (`sdtm_dataset_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`sdtm_dataset`(`sdtm_dataset_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ADD CONSTRAINT `fk_regulatory_safety_report_submission_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`safety_report_submission` ADD CONSTRAINT `fk_regulatory_safety_report_submission_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ADD CONSTRAINT `fk_regulatory_clinical_trial_authorization_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`clinical_trial_authorization` ADD CONSTRAINT `fk_regulatory_clinical_trial_authorization_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ADD CONSTRAINT `fk_regulatory_country_registration_ethics_approval_id` FOREIGN KEY (`ethics_approval_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`ethics_approval`(`ethics_approval_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ADD CONSTRAINT `fk_regulatory_country_registration_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`regulatory`.`country_registration` ADD CONSTRAINT `fk_regulatory_country_registration_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ADD CONSTRAINT `fk_document_tmf_document_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_document` ADD CONSTRAINT `fk_document_tmf_document_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`document`.`tmf_artifact` ADD CONSTRAINT `fk_document_tmf_artifact_compliance_sop_id` FOREIGN KEY (`compliance_sop_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`compliance_sop`(`compliance_sop_id`);

ALTER TABLE `clinical_trials_mvm`.`document`.`version` ADD CONSTRAINT `fk_document_version_controlled_terminology_codelist_id` FOREIGN KEY (`controlled_terminology_codelist_id`) REFERENCES `clinical_trials_mvm`.`datamanagement`.`codelist`(`codelist_id`);

ALTER TABLE `clinical_trials_mvm`.`document`.`document_sop` ADD CONSTRAINT `fk_document_document_sop_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ADD CONSTRAINT `fk_document_workflow_audit_id` FOREIGN KEY (`audit_id`) REFERENCES `clinical_trials_mvm`.`compliance`.`audit`(`audit_id`);

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ADD CONSTRAINT `fk_document_workflow_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`document`.`workflow` ADD CONSTRAINT `fk_document_workflow_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ADD CONSTRAINT `fk_document_signature_principal_investigator_id` FOREIGN KEY (`principal_investigator_id`) REFERENCES `clinical_trials_mvm`.`site`.`principal_investigator`(`principal_investigator_id`);

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ADD CONSTRAINT `fk_document_signature_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`document`.`signature` ADD CONSTRAINT `fk_document_signature_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ADD CONSTRAINT `fk_document_site_file_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`document`.`site_file` ADD CONSTRAINT `fk_document_site_file_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`document`.`regulatory_binder` ADD CONSTRAINT `fk_document_regulatory_binder_submission_id` FOREIGN KEY (`submission_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`submission`(`submission_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ADD CONSTRAINT `fk_compliance_audit_investigational_site_id` FOREIGN KEY (`investigational_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`investigational_site`(`investigational_site_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ADD CONSTRAINT `fk_compliance_audit_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ADD CONSTRAINT `fk_compliance_audit_principal_investigator_id` FOREIGN KEY (`principal_investigator_id`) REFERENCES `clinical_trials_mvm`.`site`.`principal_investigator`(`principal_investigator_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ADD CONSTRAINT `fk_compliance_audit_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit` ADD CONSTRAINT `fk_compliance_audit_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ADD CONSTRAINT `fk_compliance_audit_finding_bioanalytical_assay_id` FOREIGN KEY (`bioanalytical_assay_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`bioanalytical_assay`(`bioanalytical_assay_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ADD CONSTRAINT `fk_compliance_audit_finding_lab_panel_id` FOREIGN KEY (`lab_panel_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_panel`(`lab_panel_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ADD CONSTRAINT `fk_compliance_audit_finding_principal_investigator_id` FOREIGN KEY (`principal_investigator_id`) REFERENCES `clinical_trials_mvm`.`site`.`principal_investigator`(`principal_investigator_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ADD CONSTRAINT `fk_compliance_audit_finding_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ADD CONSTRAINT `fk_compliance_audit_finding_specimen_shipment_id` FOREIGN KEY (`specimen_shipment_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`specimen_shipment`(`specimen_shipment_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ADD CONSTRAINT `fk_compliance_audit_finding_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ADD CONSTRAINT `fk_compliance_audit_finding_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ADD CONSTRAINT `fk_compliance_audit_finding_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`audit_finding` ADD CONSTRAINT `fk_compliance_audit_finding_version_id` FOREIGN KEY (`version_id`) REFERENCES `clinical_trials_mvm`.`document`.`version`(`version_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ADD CONSTRAINT `fk_compliance_inspection_finding_adverse_event_id` FOREIGN KEY (`adverse_event_id`) REFERENCES `clinical_trials_mvm`.`safety`.`adverse_event`(`adverse_event_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ADD CONSTRAINT `fk_compliance_inspection_finding_application_id` FOREIGN KEY (`application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`application`(`application_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ADD CONSTRAINT `fk_compliance_inspection_finding_bioanalytical_assay_id` FOREIGN KEY (`bioanalytical_assay_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`bioanalytical_assay`(`bioanalytical_assay_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ADD CONSTRAINT `fk_compliance_inspection_finding_eligibility_assessment_id` FOREIGN KEY (`eligibility_assessment_id`) REFERENCES `clinical_trials_mvm`.`subject`.`eligibility_assessment`(`eligibility_assessment_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ADD CONSTRAINT `fk_compliance_inspection_finding_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ADD CONSTRAINT `fk_compliance_inspection_finding_lab_panel_id` FOREIGN KEY (`lab_panel_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_panel`(`lab_panel_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ADD CONSTRAINT `fk_compliance_inspection_finding_principal_investigator_id` FOREIGN KEY (`principal_investigator_id`) REFERENCES `clinical_trials_mvm`.`site`.`principal_investigator`(`principal_investigator_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ADD CONSTRAINT `fk_compliance_inspection_finding_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ADD CONSTRAINT `fk_compliance_inspection_finding_serious_adverse_event_id` FOREIGN KEY (`serious_adverse_event_id`) REFERENCES `clinical_trials_mvm`.`safety`.`serious_adverse_event`(`serious_adverse_event_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ADD CONSTRAINT `fk_compliance_inspection_finding_specimen_collection_id` FOREIGN KEY (`specimen_collection_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`specimen_collection`(`specimen_collection_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ADD CONSTRAINT `fk_compliance_inspection_finding_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ADD CONSTRAINT `fk_compliance_inspection_finding_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ADD CONSTRAINT `fk_compliance_inspection_finding_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`inspection_finding` ADD CONSTRAINT `fk_compliance_inspection_finding_version_id` FOREIGN KEY (`version_id`) REFERENCES `clinical_trials_mvm`.`document`.`version`(`version_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_arm_id` FOREIGN KEY (`arm_id`) REFERENCES `clinical_trials_mvm`.`study`.`arm`(`arm_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_dosing_regimen_id` FOREIGN KEY (`dosing_regimen_id`) REFERENCES `clinical_trials_mvm`.`study`.`dosing_regimen`(`dosing_regimen_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_eligibility_criterion_id` FOREIGN KEY (`eligibility_criterion_id`) REFERENCES `clinical_trials_mvm`.`study`.`eligibility_criterion`(`eligibility_criterion_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_pk_sample_id` FOREIGN KEY (`pk_sample_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`pk_sample`(`pk_sample_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_principal_investigator_id` FOREIGN KEY (`principal_investigator_id`) REFERENCES `clinical_trials_mvm`.`site`.`principal_investigator`(`principal_investigator_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_protocol_lab_schedule_id` FOREIGN KEY (`protocol_lab_schedule_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`protocol_lab_schedule`(`protocol_lab_schedule_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_sap_id` FOREIGN KEY (`sap_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`sap`(`sap_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_shipment_id` FOREIGN KEY (`shipment_id`) REFERENCES `clinical_trials_mvm`.`supply`.`shipment`(`shipment_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_specimen_collection_id` FOREIGN KEY (`specimen_collection_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`specimen_collection`(`specimen_collection_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`protocol_deviation` ADD CONSTRAINT `fk_compliance_protocol_deviation_trial_subject_id` FOREIGN KEY (`trial_subject_id`) REFERENCES `clinical_trials_mvm`.`subject`.`trial_subject`(`trial_subject_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_adverse_event_id` FOREIGN KEY (`adverse_event_id`) REFERENCES `clinical_trials_mvm`.`safety`.`adverse_event`(`adverse_event_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_bioanalytical_assay_id` FOREIGN KEY (`bioanalytical_assay_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`bioanalytical_assay`(`bioanalytical_assay_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_consent_subject_consent_id` FOREIGN KEY (`consent_subject_consent_id`) REFERENCES `clinical_trials_mvm`.`subject`.`subject_consent`(`subject_consent_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_database_lock_event_id` FOREIGN KEY (`database_lock_event_id`) REFERENCES `clinical_trials_mvm`.`biostatistics`.`database_lock_event`(`database_lock_event_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_dsmb_recommendation_id` FOREIGN KEY (`dsmb_recommendation_id`) REFERENCES `clinical_trials_mvm`.`safety`.`dsmb_recommendation`(`dsmb_recommendation_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_lab_panel_id` FOREIGN KEY (`lab_panel_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_panel`(`lab_panel_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_manufacture_batch_id` FOREIGN KEY (`manufacture_batch_id`) REFERENCES `clinical_trials_mvm`.`supply`.`manufacture_batch`(`manufacture_batch_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_pk_sample_id` FOREIGN KEY (`pk_sample_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`pk_sample`(`pk_sample_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_principal_investigator_id` FOREIGN KEY (`principal_investigator_id`) REFERENCES `clinical_trials_mvm`.`site`.`principal_investigator`(`principal_investigator_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_reference_range_id` FOREIGN KEY (`reference_range_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`reference_range`(`reference_range_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_sdv_review_id` FOREIGN KEY (`sdv_review_id`) REFERENCES `clinical_trials_mvm`.`subject`.`sdv_review`(`sdv_review_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_serious_adverse_event_id` FOREIGN KEY (`serious_adverse_event_id`) REFERENCES `clinical_trials_mvm`.`safety`.`serious_adverse_event`(`serious_adverse_event_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_signal_id` FOREIGN KEY (`signal_id`) REFERENCES `clinical_trials_mvm`.`safety`.`signal`(`signal_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_specimen_aliquot_id` FOREIGN KEY (`specimen_aliquot_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`specimen_aliquot`(`specimen_aliquot_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_specimen_collection_id` FOREIGN KEY (`specimen_collection_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`specimen_collection`(`specimen_collection_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_specimen_shipment_id` FOREIGN KEY (`specimen_shipment_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`specimen_shipment`(`specimen_shipment_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_subject_consent_consent_subject_consent_id` FOREIGN KEY (`subject_consent_consent_subject_consent_id`) REFERENCES `clinical_trials_mvm`.`consent`.`consent_subject_consent`(`consent_subject_consent_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`quality_event` ADD CONSTRAINT `fk_compliance_quality_event_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ADD CONSTRAINT `fk_compliance_risk_assessment_bioanalytical_assay_id` FOREIGN KEY (`bioanalytical_assay_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`bioanalytical_assay`(`bioanalytical_assay_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ADD CONSTRAINT `fk_compliance_risk_assessment_depot_id` FOREIGN KEY (`depot_id`) REFERENCES `clinical_trials_mvm`.`supply`.`depot`(`depot_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ADD CONSTRAINT `fk_compliance_risk_assessment_health_authority_id` FOREIGN KEY (`health_authority_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`health_authority`(`health_authority_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ADD CONSTRAINT `fk_compliance_risk_assessment_imp_master_id` FOREIGN KEY (`imp_master_id`) REFERENCES `clinical_trials_mvm`.`supply`.`imp_master`(`imp_master_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ADD CONSTRAINT `fk_compliance_risk_assessment_investigational_product_id` FOREIGN KEY (`investigational_product_id`) REFERENCES `clinical_trials_mvm`.`study`.`investigational_product`(`investigational_product_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ADD CONSTRAINT `fk_compliance_risk_assessment_lab_facility_id` FOREIGN KEY (`lab_facility_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_facility`(`lab_facility_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ADD CONSTRAINT `fk_compliance_risk_assessment_lab_panel_id` FOREIGN KEY (`lab_panel_id`) REFERENCES `clinical_trials_mvm`.`laboratory`.`lab_panel`(`lab_panel_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ADD CONSTRAINT `fk_compliance_risk_assessment_signal_id` FOREIGN KEY (`signal_id`) REFERENCES `clinical_trials_mvm`.`safety`.`signal`(`signal_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ADD CONSTRAINT `fk_compliance_risk_assessment_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`risk_assessment` ADD CONSTRAINT `fk_compliance_risk_assessment_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_committee` ADD CONSTRAINT `fk_compliance_ethics_committee_country_id` FOREIGN KEY (`country_id`) REFERENCES `clinical_trials_mvm`.`study`.`country`(`country_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ADD CONSTRAINT `fk_compliance_ethics_submission_ind_application_id` FOREIGN KEY (`ind_application_id`) REFERENCES `clinical_trials_mvm`.`regulatory`.`ind_application`(`ind_application_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ADD CONSTRAINT `fk_compliance_ethics_submission_principal_investigator_id` FOREIGN KEY (`principal_investigator_id`) REFERENCES `clinical_trials_mvm`.`site`.`principal_investigator`(`principal_investigator_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ADD CONSTRAINT `fk_compliance_ethics_submission_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ADD CONSTRAINT `fk_compliance_ethics_submission_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ADD CONSTRAINT `fk_compliance_ethics_submission_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ADD CONSTRAINT `fk_compliance_ethics_submission_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_submission` ADD CONSTRAINT `fk_compliance_ethics_submission_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ADD CONSTRAINT `fk_compliance_ethics_approval_country_id` FOREIGN KEY (`country_id`) REFERENCES `clinical_trials_mvm`.`study`.`country`(`country_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ADD CONSTRAINT `fk_compliance_ethics_approval_protocol_id` FOREIGN KEY (`protocol_id`) REFERENCES `clinical_trials_mvm`.`study`.`protocol`(`protocol_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ADD CONSTRAINT `fk_compliance_ethics_approval_study_id` FOREIGN KEY (`study_id`) REFERENCES `clinical_trials_mvm`.`study`.`study`(`study_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ADD CONSTRAINT `fk_compliance_ethics_approval_study_protocol_amendment_id` FOREIGN KEY (`study_protocol_amendment_id`) REFERENCES `clinical_trials_mvm`.`study`.`study_protocol_amendment`(`study_protocol_amendment_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ADD CONSTRAINT `fk_compliance_ethics_approval_study_site_id` FOREIGN KEY (`study_site_id`) REFERENCES `clinical_trials_mvm`.`site`.`study_site`(`study_site_id`);

ALTER TABLE `clinical_trials_mvm`.`compliance`.`ethics_approval` ADD CONSTRAINT `fk_compliance_ethics_approval_tmf_document_id` FOREIGN KEY (`tmf_document_id`) REFERENCES `clinical_trials_mvm`.`document`.`tmf_document`(`tmf_document_id`);
