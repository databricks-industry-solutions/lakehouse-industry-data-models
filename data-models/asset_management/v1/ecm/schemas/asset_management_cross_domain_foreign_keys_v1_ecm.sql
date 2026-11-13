-- Cross-Domain Foreign Keys for Business: Asset Management | Version: v1_ecm
-- Generated on: 2026-11-10 14:17:30
-- Total cross-domain FK constraints: 1479
--
-- EXECUTION ORDER:
--   1. Run ALL domain schema files first (any order).
--   2. Run this file LAST.
--
-- PREREQUISITE DOMAINS: actuarial, beneficiary, collateral, compliance, credit, deal, diligence, equity, esg, fee, infrastructure, manager, naturalresource, performance, portfolio, privateequity, realestate, research, risk, shared, trade, treasury, valuation

-- ========= actuarial --> beneficiary (7 constraint(s)) =========
-- Requires: actuarial schema, beneficiary schema
ALTER TABLE `asset_management`.`actuarial`.`contribution_rate_model` ADD CONSTRAINT `fk_actuarial_contribution_rate_model_contributor_pool_id` FOREIGN KEY (`contributor_pool_id`) REFERENCES `asset_management`.`beneficiary`.`contributor_pool`(`contributor_pool_id`);
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ADD CONSTRAINT `fk_actuarial_indexation_policy_contributor_pool_id` FOREIGN KEY (`contributor_pool_id`) REFERENCES `asset_management`.`beneficiary`.`contributor_pool`(`contributor_pool_id`);
ALTER TABLE `asset_management`.`actuarial`.`liability_cash_flow` ADD CONSTRAINT `fk_actuarial_liability_cash_flow_contributor_pool_id` FOREIGN KEY (`contributor_pool_id`) REFERENCES `asset_management`.`beneficiary`.`contributor_pool`(`contributor_pool_id`);
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ADD CONSTRAINT `fk_actuarial_liability_projection_contributor_pool_id` FOREIGN KEY (`contributor_pool_id`) REFERENCES `asset_management`.`beneficiary`.`contributor_pool`(`contributor_pool_id`);
ALTER TABLE `asset_management`.`actuarial`.`liability_segment` ADD CONSTRAINT `fk_actuarial_liability_segment_contributor_pool_id` FOREIGN KEY (`contributor_pool_id`) REFERENCES `asset_management`.`beneficiary`.`contributor_pool`(`contributor_pool_id`);
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ADD CONSTRAINT `fk_actuarial_plan_amendment_contributor_pool_id` FOREIGN KEY (`contributor_pool_id`) REFERENCES `asset_management`.`beneficiary`.`contributor_pool`(`contributor_pool_id`);
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ADD CONSTRAINT `fk_actuarial_plan_amendment_pension_plan_id` FOREIGN KEY (`pension_plan_id`) REFERENCES `asset_management`.`beneficiary`.`pension_plan`(`pension_plan_id`);

-- ========= actuarial --> collateral (2 constraint(s)) =========
-- Requires: actuarial schema, collateral schema
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ADD CONSTRAINT `fk_actuarial_ldi_hedge_position_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ADD CONSTRAINT `fk_actuarial_ldi_strategy_netting_agreement_id` FOREIGN KEY (`netting_agreement_id`) REFERENCES `asset_management`.`collateral`.`netting_agreement`(`netting_agreement_id`);

-- ========= actuarial --> compliance (5 constraint(s)) =========
-- Requires: actuarial schema, compliance schema
ALTER TABLE `asset_management`.`actuarial`.`actuarial_report` ADD CONSTRAINT `fk_actuarial_actuarial_report_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ADD CONSTRAINT `fk_actuarial_actuarial_valuation_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ADD CONSTRAINT `fk_actuarial_indexation_policy_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ADD CONSTRAINT `fk_actuarial_plan_amendment_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ADD CONSTRAINT `fk_actuarial_plan_amendment_regulatory_filing_id` FOREIGN KEY (`regulatory_filing_id`) REFERENCES `asset_management`.`compliance`.`regulatory_filing`(`regulatory_filing_id`);

-- ========= actuarial --> credit (1 constraint(s)) =========
-- Requires: actuarial schema, credit schema
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ADD CONSTRAINT `fk_actuarial_assumption_set_credit_yield_curve_id` FOREIGN KEY (`credit_yield_curve_id`) REFERENCES `asset_management`.`credit`.`credit_yield_curve`(`credit_yield_curve_id`);

-- ========= actuarial --> esg (1 constraint(s)) =========
-- Requires: actuarial schema, esg schema
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ADD CONSTRAINT `fk_actuarial_alm_model_climate_scenario_id` FOREIGN KEY (`climate_scenario_id`) REFERENCES `asset_management`.`esg`.`climate_scenario`(`climate_scenario_id`);

-- ========= actuarial --> manager (2 constraint(s)) =========
-- Requires: actuarial schema, manager schema
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ADD CONSTRAINT `fk_actuarial_ldi_hedge_position_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ADD CONSTRAINT `fk_actuarial_ldi_hedge_position_strategy_id` FOREIGN KEY (`strategy_id`) REFERENCES `asset_management`.`manager`.`strategy`(`strategy_id`);

-- ========= actuarial --> performance (1 constraint(s)) =========
-- Requires: actuarial schema, performance schema
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ADD CONSTRAINT `fk_actuarial_alm_model_performance_benchmark_id` FOREIGN KEY (`performance_benchmark_id`) REFERENCES `asset_management`.`performance`.`performance_benchmark`(`performance_benchmark_id`);

-- ========= actuarial --> portfolio (1 constraint(s)) =========
-- Requires: actuarial schema, portfolio schema
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` ADD CONSTRAINT `fk_actuarial_de_risking_trigger_applicable_portfolio_id` FOREIGN KEY (`applicable_portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);

-- ========= actuarial --> privateequity (3 constraint(s)) =========
-- Requires: actuarial schema, privateequity schema
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ADD CONSTRAINT `fk_actuarial_alm_model_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ADD CONSTRAINT `fk_actuarial_de_risking_event_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`actuarial`.`funded_status` ADD CONSTRAINT `fk_actuarial_funded_status_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);

-- ========= actuarial --> research (6 constraint(s)) =========
-- Requires: actuarial schema, research schema
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ADD CONSTRAINT `fk_actuarial_alm_scenario_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);
ALTER TABLE `asset_management`.`actuarial`.`assumption_set` ADD CONSTRAINT `fk_actuarial_assumption_set_capital_market_assumption_id` FOREIGN KEY (`capital_market_assumption_id`) REFERENCES `asset_management`.`research`.`capital_market_assumption`(`capital_market_assumption_id`);
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ADD CONSTRAINT `fk_actuarial_de_risking_event_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` ADD CONSTRAINT `fk_actuarial_de_risking_trigger_macro_indicator_id` FOREIGN KEY (`macro_indicator_id`) REFERENCES `asset_management`.`research`.`macro_indicator`(`macro_indicator_id`);
ALTER TABLE `asset_management`.`actuarial`.`ldi_strategy` ADD CONSTRAINT `fk_actuarial_ldi_strategy_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ADD CONSTRAINT `fk_actuarial_liability_projection_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);

-- ========= actuarial --> risk (2 constraint(s)) =========
-- Requires: actuarial schema, risk schema
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ADD CONSTRAINT `fk_actuarial_alm_scenario_risk_stress_scenario_id` FOREIGN KEY (`risk_stress_scenario_id`) REFERENCES `asset_management`.`risk`.`stress_scenario`(`stress_scenario_id`);
ALTER TABLE `asset_management`.`actuarial`.`de_risking_trigger` ADD CONSTRAINT `fk_actuarial_de_risking_trigger_limit_id` FOREIGN KEY (`limit_id`) REFERENCES `asset_management`.`risk`.`limit`(`limit_id`);

-- ========= actuarial --> shared (9 constraint(s)) =========
-- Requires: actuarial schema, shared schema
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ADD CONSTRAINT `fk_actuarial_alm_model_created_by_user_employee_id` FOREIGN KEY (`created_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ADD CONSTRAINT `fk_actuarial_alm_model_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`actuarial`.`alm_model` ADD CONSTRAINT `fk_actuarial_alm_model_updated_by_user_employee_id` FOREIGN KEY (`updated_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ADD CONSTRAINT `fk_actuarial_alm_scenario_created_by_user_employee_id` FOREIGN KEY (`created_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`actuarial`.`alm_scenario` ADD CONSTRAINT `fk_actuarial_alm_scenario_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`actuarial`.`de_risking_event` ADD CONSTRAINT `fk_actuarial_de_risking_event_created_by_employee_id` FOREIGN KEY (`created_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`actuarial`.`indexation_policy` ADD CONSTRAINT `fk_actuarial_indexation_policy_created_by_employee_id` FOREIGN KEY (`created_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`actuarial`.`plan_amendment` ADD CONSTRAINT `fk_actuarial_plan_amendment_created_by_employee_id` FOREIGN KEY (`created_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`actuarial`.`saa_constraint` ADD CONSTRAINT `fk_actuarial_saa_constraint_created_by_employee_id` FOREIGN KEY (`created_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);

-- ========= actuarial --> trade (1 constraint(s)) =========
-- Requires: actuarial schema, trade schema
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ADD CONSTRAINT `fk_actuarial_ldi_hedge_position_instrument_id` FOREIGN KEY (`instrument_id`) REFERENCES `asset_management`.`trade`.`instrument`(`instrument_id`);

-- ========= actuarial --> treasury (1 constraint(s)) =========
-- Requires: actuarial schema, treasury schema
ALTER TABLE `asset_management`.`actuarial`.`ldi_hedge_position` ADD CONSTRAINT `fk_actuarial_ldi_hedge_position_st_instrument_transaction_id` FOREIGN KEY (`st_instrument_transaction_id`) REFERENCES `asset_management`.`treasury`.`st_instrument_transaction`(`st_instrument_transaction_id`);

-- ========= actuarial --> valuation (4 constraint(s)) =========
-- Requires: actuarial schema, valuation schema
ALTER TABLE `asset_management`.`actuarial`.`actuarial_valuation` ADD CONSTRAINT `fk_actuarial_actuarial_valuation_cycle_id` FOREIGN KEY (`cycle_id`) REFERENCES `asset_management`.`valuation`.`cycle`(`cycle_id`);
ALTER TABLE `asset_management`.`actuarial`.`funded_status` ADD CONSTRAINT `fk_actuarial_funded_status_valuation_asset_valuation_id` FOREIGN KEY (`valuation_asset_valuation_id`) REFERENCES `asset_management`.`valuation`.`valuation_asset_valuation`(`valuation_asset_valuation_id`);
ALTER TABLE `asset_management`.`actuarial`.`gain_loss` ADD CONSTRAINT `fk_actuarial_gain_loss_valuation_asset_valuation_id` FOREIGN KEY (`valuation_asset_valuation_id`) REFERENCES `asset_management`.`valuation`.`valuation_asset_valuation`(`valuation_asset_valuation_id`);
ALTER TABLE `asset_management`.`actuarial`.`liability_projection` ADD CONSTRAINT `fk_actuarial_liability_projection_valuation_cycle_id` FOREIGN KEY (`valuation_cycle_id`) REFERENCES `asset_management`.`valuation`.`cycle`(`cycle_id`);

-- ========= beneficiary --> actuarial (4 constraint(s)) =========
-- Requires: beneficiary schema, actuarial schema
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ADD CONSTRAINT `fk_beneficiary_indexation_adjustment_indexation_policy_id` FOREIGN KEY (`indexation_policy_id`) REFERENCES `asset_management`.`actuarial`.`indexation_policy`(`indexation_policy_id`);
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ADD CONSTRAINT `fk_beneficiary_pensionable_service_indexation_policy_id` FOREIGN KEY (`indexation_policy_id`) REFERENCES `asset_management`.`actuarial`.`indexation_policy`(`indexation_policy_id`);
ALTER TABLE `asset_management`.`beneficiary`.`service_buyback` ADD CONSTRAINT `fk_beneficiary_service_buyback_assumption_set_id` FOREIGN KEY (`assumption_set_id`) REFERENCES `asset_management`.`actuarial`.`assumption_set`(`assumption_set_id`);
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ADD CONSTRAINT `fk_beneficiary_transfer_out_assumption_set_id` FOREIGN KEY (`assumption_set_id`) REFERENCES `asset_management`.`actuarial`.`assumption_set`(`assumption_set_id`);

-- ========= beneficiary --> compliance (4 constraint(s)) =========
-- Requires: beneficiary schema, compliance schema
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ADD CONSTRAINT `fk_beneficiary_employer_remittance_rule_breach_id` FOREIGN KEY (`rule_breach_id`) REFERENCES `asset_management`.`compliance`.`rule_breach`(`rule_breach_id`);
ALTER TABLE `asset_management`.`beneficiary`.`overpayment_recovery` ADD CONSTRAINT `fk_beneficiary_overpayment_recovery_rule_breach_id` FOREIGN KEY (`rule_breach_id`) REFERENCES `asset_management`.`compliance`.`rule_breach`(`rule_breach_id`);
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ADD CONSTRAINT `fk_beneficiary_participating_employer_kyc_record_id` FOREIGN KEY (`kyc_record_id`) REFERENCES `asset_management`.`compliance`.`kyc_record`(`kyc_record_id`);
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ADD CONSTRAINT `fk_beneficiary_participating_employer_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);

-- ========= beneficiary --> portfolio (10 constraint(s)) =========
-- Requires: beneficiary schema, portfolio schema
ALTER TABLE `asset_management`.`beneficiary`.`contributor_pool` ADD CONSTRAINT `fk_beneficiary_contributor_pool_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ADD CONSTRAINT `fk_beneficiary_employer_remittance_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`beneficiary`.`entitlement` ADD CONSTRAINT `fk_beneficiary_entitlement_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ADD CONSTRAINT `fk_beneficiary_indexation_adjustment_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`beneficiary`.`member_lifecycle_event` ADD CONSTRAINT `fk_beneficiary_member_lifecycle_event_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`beneficiary`.`member_statement` ADD CONSTRAINT `fk_beneficiary_member_statement_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`beneficiary`.`pensionable_service` ADD CONSTRAINT `fk_beneficiary_pensionable_service_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`beneficiary`.`retirement_election` ADD CONSTRAINT `fk_beneficiary_retirement_election_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ADD CONSTRAINT `fk_beneficiary_transfer_in_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ADD CONSTRAINT `fk_beneficiary_transfer_out_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);

-- ========= beneficiary --> research (1 constraint(s)) =========
-- Requires: beneficiary schema, research schema
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ADD CONSTRAINT `fk_beneficiary_indexation_adjustment_macro_indicator_id` FOREIGN KEY (`macro_indicator_id`) REFERENCES `asset_management`.`research`.`macro_indicator`(`macro_indicator_id`);

-- ========= beneficiary --> shared (6 constraint(s)) =========
-- Requires: beneficiary schema, shared schema
ALTER TABLE `asset_management`.`beneficiary`.`designated_beneficiary` ADD CONSTRAINT `fk_beneficiary_designated_beneficiary_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`beneficiary`.`member` ADD CONSTRAINT `fk_beneficiary_member_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`beneficiary`.`member` ADD CONSTRAINT `fk_beneficiary_member_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`beneficiary`.`member` ADD CONSTRAINT `fk_beneficiary_member_membership_status_updated_by_user_employee_id` FOREIGN KEY (`membership_status_updated_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`beneficiary`.`member` ADD CONSTRAINT `fk_beneficiary_member_updated_by_user_employee_id` FOREIGN KEY (`updated_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`beneficiary`.`participating_employer` ADD CONSTRAINT `fk_beneficiary_participating_employer_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);

-- ========= beneficiary --> treasury (6 constraint(s)) =========
-- Requires: beneficiary schema, treasury schema
ALTER TABLE `asset_management`.`beneficiary`.`benefit_payment` ADD CONSTRAINT `fk_beneficiary_benefit_payment_cash_transfer_id` FOREIGN KEY (`cash_transfer_id`) REFERENCES `asset_management`.`treasury`.`cash_transfer`(`cash_transfer_id`);
ALTER TABLE `asset_management`.`beneficiary`.`contribution_record` ADD CONSTRAINT `fk_beneficiary_contribution_record_net_contribution_inflow_id` FOREIGN KEY (`net_contribution_inflow_id`) REFERENCES `asset_management`.`treasury`.`net_contribution_inflow`(`net_contribution_inflow_id`);
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ADD CONSTRAINT `fk_beneficiary_employer_remittance_cash_account_id` FOREIGN KEY (`cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);
ALTER TABLE `asset_management`.`beneficiary`.`employer_remittance` ADD CONSTRAINT `fk_beneficiary_employer_remittance_fund_bank_account_id` FOREIGN KEY (`fund_bank_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);
ALTER TABLE `asset_management`.`beneficiary`.`transfer_in` ADD CONSTRAINT `fk_beneficiary_transfer_in_cash_transfer_id` FOREIGN KEY (`cash_transfer_id`) REFERENCES `asset_management`.`treasury`.`cash_transfer`(`cash_transfer_id`);
ALTER TABLE `asset_management`.`beneficiary`.`transfer_out` ADD CONSTRAINT `fk_beneficiary_transfer_out_cash_transfer_id` FOREIGN KEY (`cash_transfer_id`) REFERENCES `asset_management`.`treasury`.`cash_transfer`(`cash_transfer_id`);

-- ========= beneficiary --> valuation (1 constraint(s)) =========
-- Requires: beneficiary schema, valuation schema
ALTER TABLE `asset_management`.`beneficiary`.`indexation_adjustment` ADD CONSTRAINT `fk_beneficiary_indexation_adjustment_superseded_by_adjustment_id` FOREIGN KEY (`superseded_by_adjustment_id`) REFERENCES `asset_management`.`valuation`.`adjustment`(`adjustment_id`);

-- ========= collateral --> compliance (2 constraint(s)) =========
-- Requires: collateral schema, compliance schema
ALTER TABLE `asset_management`.`collateral`.`ccp_membership` ADD CONSTRAINT `fk_collateral_ccp_membership_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);
ALTER TABLE `asset_management`.`collateral`.`emir_trade_report` ADD CONSTRAINT `fk_collateral_emir_trade_report_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);

-- ========= collateral --> equity (3 constraint(s)) =========
-- Requires: collateral schema, equity schema
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ADD CONSTRAINT `fk_collateral_repo_transaction_repo_collateral_security_listed_security_id` FOREIGN KEY (`repo_collateral_security_listed_security_id`) REFERENCES `asset_management`.`equity`.`listed_security`(`listed_security_id`);
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ADD CONSTRAINT `fk_collateral_repo_transaction_repo_listed_security_id` FOREIGN KEY (`repo_listed_security_id`) REFERENCES `asset_management`.`equity`.`listed_security`(`listed_security_id`);
ALTER TABLE `asset_management`.`collateral`.`securities_lending` ADD CONSTRAINT `fk_collateral_securities_lending_listed_security_id` FOREIGN KEY (`listed_security_id`) REFERENCES `asset_management`.`equity`.`listed_security`(`listed_security_id`);

-- ========= collateral --> portfolio (1 constraint(s)) =========
-- Requires: collateral schema, portfolio schema
ALTER TABLE `asset_management`.`collateral`.`simm_calculation` ADD CONSTRAINT `fk_collateral_simm_calculation_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);

-- ========= collateral --> research (1 constraint(s)) =========
-- Requires: collateral schema, research schema
ALTER TABLE `asset_management`.`collateral`.`exposure` ADD CONSTRAINT `fk_collateral_exposure_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);

-- ========= collateral --> risk (3 constraint(s)) =========
-- Requires: collateral schema, risk schema
ALTER TABLE `asset_management`.`collateral`.`counterparty_stress_result` ADD CONSTRAINT `fk_collateral_counterparty_stress_result_stress_scenario_id` FOREIGN KEY (`stress_scenario_id`) REFERENCES `asset_management`.`risk`.`stress_scenario`(`stress_scenario_id`);
ALTER TABLE `asset_management`.`collateral`.`credit_limit_breach` ADD CONSTRAINT `fk_collateral_credit_limit_breach_limit_id` FOREIGN KEY (`limit_id`) REFERENCES `asset_management`.`risk`.`limit`(`limit_id`);
ALTER TABLE `asset_management`.`collateral`.`exposure` ADD CONSTRAINT `fk_collateral_exposure_stress_scenario_id` FOREIGN KEY (`stress_scenario_id`) REFERENCES `asset_management`.`risk`.`stress_scenario`(`stress_scenario_id`);

-- ========= collateral --> shared (4 constraint(s)) =========
-- Requires: collateral schema, shared schema
ALTER TABLE `asset_management`.`collateral`.`counterparty` ADD CONSTRAINT `fk_collateral_counterparty_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`collateral`.`margin_call` ADD CONSTRAINT `fk_collateral_margin_call_processed_by_employee_id` FOREIGN KEY (`processed_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ADD CONSTRAINT `fk_collateral_repo_transaction_legal_entity_id` FOREIGN KEY (`legal_entity_id`) REFERENCES `asset_management`.`shared`.`legal_entity`(`legal_entity_id`);
ALTER TABLE `asset_management`.`collateral`.`substitution` ADD CONSTRAINT `fk_collateral_substitution_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);

-- ========= collateral --> trade (4 constraint(s)) =========
-- Requires: collateral schema, trade schema
ALTER TABLE `asset_management`.`collateral`.`collateral_account` ADD CONSTRAINT `fk_collateral_collateral_account_custodian_id` FOREIGN KEY (`custodian_id`) REFERENCES `asset_management`.`trade`.`custodian`(`custodian_id`);
ALTER TABLE `asset_management`.`collateral`.`margin_call` ADD CONSTRAINT `fk_collateral_margin_call_related_trade_blotter_id` FOREIGN KEY (`related_trade_blotter_id`) REFERENCES `asset_management`.`trade`.`blotter`(`blotter_id`);
ALTER TABLE `asset_management`.`collateral`.`repo_transaction` ADD CONSTRAINT `fk_collateral_repo_transaction_broker_id` FOREIGN KEY (`broker_id`) REFERENCES `asset_management`.`trade`.`broker`(`broker_id`);
ALTER TABLE `asset_management`.`collateral`.`substitution` ADD CONSTRAINT `fk_collateral_substitution_blotter_id` FOREIGN KEY (`blotter_id`) REFERENCES `asset_management`.`trade`.`blotter`(`blotter_id`);

-- ========= collateral --> valuation (5 constraint(s)) =========
-- Requires: collateral schema, valuation schema
ALTER TABLE `asset_management`.`collateral`.`collateral_position` ADD CONSTRAINT `fk_collateral_collateral_position_valuation_asset_valuation_id` FOREIGN KEY (`valuation_asset_valuation_id`) REFERENCES `asset_management`.`valuation`.`valuation_asset_valuation`(`valuation_asset_valuation_id`);
ALTER TABLE `asset_management`.`collateral`.`csa` ADD CONSTRAINT `fk_collateral_csa_valuation_policy_id` FOREIGN KEY (`valuation_policy_id`) REFERENCES `asset_management`.`valuation`.`valuation_policy`(`valuation_policy_id`);
ALTER TABLE `asset_management`.`collateral`.`margin_call` ADD CONSTRAINT `fk_collateral_margin_call_valuation_asset_valuation_id` FOREIGN KEY (`valuation_asset_valuation_id`) REFERENCES `asset_management`.`valuation`.`valuation_asset_valuation`(`valuation_asset_valuation_id`);
ALTER TABLE `asset_management`.`collateral`.`margin_dispute` ADD CONSTRAINT `fk_collateral_margin_dispute_valuation_asset_valuation_id` FOREIGN KEY (`valuation_asset_valuation_id`) REFERENCES `asset_management`.`valuation`.`valuation_asset_valuation`(`valuation_asset_valuation_id`);
ALTER TABLE `asset_management`.`collateral`.`posting` ADD CONSTRAINT `fk_collateral_posting_valuation_asset_valuation_id` FOREIGN KEY (`valuation_asset_valuation_id`) REFERENCES `asset_management`.`valuation`.`valuation_asset_valuation`(`valuation_asset_valuation_id`);

-- ========= compliance --> beneficiary (3 constraint(s)) =========
-- Requires: compliance schema, beneficiary schema
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ADD CONSTRAINT `fk_compliance_beneficiary_disclosure_beneficiary_member_id` FOREIGN KEY (`beneficiary_member_id`) REFERENCES `asset_management`.`beneficiary`.`member`(`member_id`);
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ADD CONSTRAINT `fk_compliance_beneficiary_disclosure_member_id` FOREIGN KEY (`member_id`) REFERENCES `asset_management`.`beneficiary`.`member`(`member_id`);
ALTER TABLE `asset_management`.`compliance`.`beneficiary_disclosure` ADD CONSTRAINT `fk_compliance_beneficiary_disclosure_participating_employer_id` FOREIGN KEY (`participating_employer_id`) REFERENCES `asset_management`.`beneficiary`.`participating_employer`(`participating_employer_id`);

-- ========= compliance --> collateral (2 constraint(s)) =========
-- Requires: compliance schema, collateral schema
ALTER TABLE `asset_management`.`compliance`.`kyc_record` ADD CONSTRAINT `fk_compliance_kyc_record_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`compliance`.`sanctions_screening` ADD CONSTRAINT `fk_compliance_sanctions_screening_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);

-- ========= compliance --> deal (1 constraint(s)) =========
-- Requires: compliance schema, deal schema
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ADD CONSTRAINT `fk_compliance_conflict_of_interest_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);

-- ========= compliance --> infrastructure (2 constraint(s)) =========
-- Requires: compliance schema, infrastructure schema
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ADD CONSTRAINT `fk_compliance_ic_decision_infra_asset_id` FOREIGN KEY (`infra_asset_id`) REFERENCES `asset_management`.`infrastructure`.`infra_asset`(`infra_asset_id`);
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ADD CONSTRAINT `fk_compliance_rule_breach_infra_asset_id` FOREIGN KEY (`infra_asset_id`) REFERENCES `asset_management`.`infrastructure`.`infra_asset`(`infra_asset_id`);

-- ========= compliance --> performance (1 constraint(s)) =========
-- Requires: compliance schema, performance schema
ALTER TABLE `asset_management`.`compliance`.`gips_compliance_record` ADD CONSTRAINT `fk_compliance_gips_compliance_record_composite_id` FOREIGN KEY (`composite_id`) REFERENCES `asset_management`.`performance`.`composite`(`composite_id`);

-- ========= compliance --> privateequity (1 constraint(s)) =========
-- Requires: compliance schema, privateequity schema
ALTER TABLE `asset_management`.`compliance`.`ic_decision` ADD CONSTRAINT `fk_compliance_ic_decision_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);

-- ========= compliance --> risk (1 constraint(s)) =========
-- Requires: compliance schema, risk schema
ALTER TABLE `asset_management`.`compliance`.`regulatory_filing` ADD CONSTRAINT `fk_compliance_regulatory_filing_stress_test_result_id` FOREIGN KEY (`stress_test_result_id`) REFERENCES `asset_management`.`risk`.`stress_test_result`(`stress_test_result_id`);

-- ========= compliance --> shared (11 constraint(s)) =========
-- Requires: compliance schema, shared schema
ALTER TABLE `asset_management`.`compliance`.`audit_finding` ADD CONSTRAINT `fk_compliance_audit_finding_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`compliance`.`breach_remediation` ADD CONSTRAINT `fk_compliance_breach_remediation_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`compliance`.`certification` ADD CONSTRAINT `fk_compliance_certification_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`compliance`.`conflict_of_interest` ADD CONSTRAINT `fk_compliance_conflict_of_interest_declarant_employee_id` FOREIGN KEY (`declarant_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`compliance`.`exam_finding` ADD CONSTRAINT `fk_compliance_exam_finding_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ADD CONSTRAINT `fk_compliance_personal_account_dealing_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ADD CONSTRAINT `fk_compliance_policy_exception_approver_employee_id` FOREIGN KEY (`approver_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`compliance`.`policy_exception` ADD CONSTRAINT `fk_compliance_policy_exception_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ADD CONSTRAINT `fk_compliance_rule_breach_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ADD CONSTRAINT `fk_compliance_rule_breach_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ADD CONSTRAINT `fk_compliance_rule_breach_resolved_by_employee_id` FOREIGN KEY (`resolved_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);

-- ========= compliance --> trade (9 constraint(s)) =========
-- Requires: compliance schema, trade schema
ALTER TABLE `asset_management`.`compliance`.`personal_account_dealing` ADD CONSTRAINT `fk_compliance_personal_account_dealing_instrument_id` FOREIGN KEY (`instrument_id`) REFERENCES `asset_management`.`trade`.`instrument`(`instrument_id`);
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ADD CONSTRAINT `fk_compliance_rule_breach_blotter_id` FOREIGN KEY (`blotter_id`) REFERENCES `asset_management`.`trade`.`blotter`(`blotter_id`);
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ADD CONSTRAINT `fk_compliance_rule_breach_instrument_id` FOREIGN KEY (`instrument_id`) REFERENCES `asset_management`.`trade`.`instrument`(`instrument_id`);
ALTER TABLE `asset_management`.`compliance`.`rule_breach` ADD CONSTRAINT `fk_compliance_rule_breach_settlement_fail_id` FOREIGN KEY (`settlement_fail_id`) REFERENCES `asset_management`.`trade`.`settlement_fail`(`settlement_fail_id`);
ALTER TABLE `asset_management`.`compliance`.`trade_report` ADD CONSTRAINT `fk_compliance_trade_report_broker_id` FOREIGN KEY (`broker_id`) REFERENCES `asset_management`.`trade`.`broker`(`broker_id`);
ALTER TABLE `asset_management`.`compliance`.`trade_report` ADD CONSTRAINT `fk_compliance_trade_report_execution_id` FOREIGN KEY (`execution_id`) REFERENCES `asset_management`.`trade`.`execution`(`execution_id`);
ALTER TABLE `asset_management`.`compliance`.`trade_report` ADD CONSTRAINT `fk_compliance_trade_report_fx_trade_id` FOREIGN KEY (`fx_trade_id`) REFERENCES `asset_management`.`trade`.`fx_trade`(`fx_trade_id`);
ALTER TABLE `asset_management`.`compliance`.`trade_report` ADD CONSTRAINT `fk_compliance_trade_report_order_id` FOREIGN KEY (`order_id`) REFERENCES `asset_management`.`trade`.`order`(`order_id`);
ALTER TABLE `asset_management`.`compliance`.`trade_report` ADD CONSTRAINT `fk_compliance_trade_report_otc_derivative_id` FOREIGN KEY (`otc_derivative_id`) REFERENCES `asset_management`.`trade`.`otc_derivative`(`otc_derivative_id`);

-- ========= compliance --> treasury (2 constraint(s)) =========
-- Requires: compliance schema, treasury schema
ALTER TABLE `asset_management`.`compliance`.`trade_report` ADD CONSTRAINT `fk_compliance_trade_report_fx_forward_id` FOREIGN KEY (`fx_forward_id`) REFERENCES `asset_management`.`treasury`.`fx_forward`(`fx_forward_id`);
ALTER TABLE `asset_management`.`compliance`.`trade_report` ADD CONSTRAINT `fk_compliance_trade_report_fx_swap_id` FOREIGN KEY (`fx_swap_id`) REFERENCES `asset_management`.`treasury`.`fx_swap`(`fx_swap_id`);

-- ========= credit --> collateral (9 constraint(s)) =========
-- Requires: credit schema, collateral schema
ALTER TABLE `asset_management`.`credit`.`cds_position` ADD CONSTRAINT `fk_credit_cds_position_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`credit`.`credit_allocation` ADD CONSTRAINT `fk_credit_credit_allocation_collateral_position_id` FOREIGN KEY (`collateral_position_id`) REFERENCES `asset_management`.`collateral`.`collateral_position`(`collateral_position_id`);
ALTER TABLE `asset_management`.`credit`.`credit_position` ADD CONSTRAINT `fk_credit_credit_position_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ADD CONSTRAINT `fk_credit_maturity_schedule_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ADD CONSTRAINT `fk_credit_private_credit_drawdown_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ADD CONSTRAINT `fk_credit_private_credit_repayment_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ADD CONSTRAINT `fk_credit_private_credit_repayment_private_counterparty_id` FOREIGN KEY (`private_counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ADD CONSTRAINT `fk_credit_private_credit_repayment_private_servicer_entity_counterparty_id` FOREIGN KEY (`private_servicer_entity_counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ADD CONSTRAINT `fk_credit_private_credit_repayment_servicer_entity_counterparty_id` FOREIGN KEY (`servicer_entity_counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);

-- ========= credit --> deal (2 constraint(s)) =========
-- Requires: credit schema, deal schema
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ADD CONSTRAINT `fk_credit_private_credit_investment_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ADD CONSTRAINT `fk_credit_private_credit_investment_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);

-- ========= credit --> manager (2 constraint(s)) =========
-- Requires: credit schema, manager schema
ALTER TABLE `asset_management`.`credit`.`private_credit_facility` ADD CONSTRAINT `fk_credit_private_credit_facility_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ADD CONSTRAINT `fk_credit_private_credit_investment_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);

-- ========= credit --> portfolio (11 constraint(s)) =========
-- Requires: credit schema, portfolio schema
ALTER TABLE `asset_management`.`credit`.`cds_position` ADD CONSTRAINT `fk_credit_cds_position_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ADD CONSTRAINT `fk_credit_coupon_payment_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`credit`.`credit_position` ADD CONSTRAINT `fk_credit_credit_position_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`credit`.`default_event` ADD CONSTRAINT `fk_credit_default_event_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`credit`.`duration_convexity` ADD CONSTRAINT `fk_credit_duration_convexity_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ADD CONSTRAINT `fk_credit_maturity_schedule_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ADD CONSTRAINT `fk_credit_private_credit_drawdown_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`credit`.`private_credit_facility` ADD CONSTRAINT `fk_credit_private_credit_facility_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ADD CONSTRAINT `fk_credit_private_credit_repayment_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ADD CONSTRAINT `fk_credit_sovereign_debt_holding_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`credit`.`spread_analytics` ADD CONSTRAINT `fk_credit_spread_analytics_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);

-- ========= credit --> privateequity (2 constraint(s)) =========
-- Requires: credit schema, privateequity schema
ALTER TABLE `asset_management`.`credit`.`covenant_monitoring` ADD CONSTRAINT `fk_credit_covenant_monitoring_investment_id` FOREIGN KEY (`investment_id`) REFERENCES `asset_management`.`privateequity`.`investment`(`investment_id`);
ALTER TABLE `asset_management`.`credit`.`private_credit_facility` ADD CONSTRAINT `fk_credit_private_credit_facility_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);

-- ========= credit --> shared (12 constraint(s)) =========
-- Requires: credit schema, shared schema
ALTER TABLE `asset_management`.`credit`.`amortization_schedule` ADD CONSTRAINT `fk_credit_amortization_schedule_loan_servicer_id` FOREIGN KEY (`loan_servicer_id`) REFERENCES `asset_management`.`shared`.`loan_servicer`(`loan_servicer_id`);
ALTER TABLE `asset_management`.`credit`.`cds_market_data` ADD CONSTRAINT `fk_credit_cds_market_data_reference_entity_actor_id` FOREIGN KEY (`reference_entity_actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`credit`.`cds_position` ADD CONSTRAINT `fk_credit_cds_position_reference_entity_actor_id` FOREIGN KEY (`reference_entity_actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`credit`.`credit_position` ADD CONSTRAINT `fk_credit_credit_position_custodian_actor_id` FOREIGN KEY (`custodian_actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`credit`.`default_event` ADD CONSTRAINT `fk_credit_default_event_reference_entity_actor_id` FOREIGN KEY (`reference_entity_actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ADD CONSTRAINT `fk_credit_private_credit_drawdown_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ADD CONSTRAINT `fk_credit_private_credit_drawdown_booking_entity_actor_id` FOREIGN KEY (`booking_entity_actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ADD CONSTRAINT `fk_credit_private_credit_drawdown_borrower_actor_id` FOREIGN KEY (`borrower_actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ADD CONSTRAINT `fk_credit_private_credit_investment_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`credit`.`private_credit_investment` ADD CONSTRAINT `fk_credit_private_credit_investment_investment_manager_actor_id` FOREIGN KEY (`investment_manager_actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`credit`.`rating_action` ADD CONSTRAINT `fk_credit_rating_action_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`credit`.`sovereign_debt_holding` ADD CONSTRAINT `fk_credit_sovereign_debt_holding_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);

-- ========= credit --> trade (10 constraint(s)) =========
-- Requires: credit schema, trade schema
ALTER TABLE `asset_management`.`credit`.`amortization_schedule` ADD CONSTRAINT `fk_credit_amortization_schedule_custody_account_id` FOREIGN KEY (`custody_account_id`) REFERENCES `asset_management`.`trade`.`custody_account`(`custody_account_id`);
ALTER TABLE `asset_management`.`credit`.`amortization_schedule` ADD CONSTRAINT `fk_credit_amortization_schedule_instrument_id` FOREIGN KEY (`instrument_id`) REFERENCES `asset_management`.`trade`.`instrument`(`instrument_id`);
ALTER TABLE `asset_management`.`credit`.`coupon_payment` ADD CONSTRAINT `fk_credit_coupon_payment_custodian_id` FOREIGN KEY (`custodian_id`) REFERENCES `asset_management`.`trade`.`custodian`(`custodian_id`);
ALTER TABLE `asset_management`.`credit`.`credit_position` ADD CONSTRAINT `fk_credit_credit_position_credit_blotter_id` FOREIGN KEY (`credit_blotter_id`) REFERENCES `asset_management`.`trade`.`blotter`(`blotter_id`);
ALTER TABLE `asset_management`.`credit`.`credit_position` ADD CONSTRAINT `fk_credit_credit_position_credit_custodian_blotter_id` FOREIGN KEY (`credit_custodian_blotter_id`) REFERENCES `asset_management`.`trade`.`blotter`(`blotter_id`);
ALTER TABLE `asset_management`.`credit`.`fixed_income_security` ADD CONSTRAINT `fk_credit_fixed_income_security_instrument_id` FOREIGN KEY (`instrument_id`) REFERENCES `asset_management`.`trade`.`instrument`(`instrument_id`);
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ADD CONSTRAINT `fk_credit_maturity_schedule_custodian_id` FOREIGN KEY (`custodian_id`) REFERENCES `asset_management`.`trade`.`custodian`(`custodian_id`);
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ADD CONSTRAINT `fk_credit_private_credit_drawdown_blotter_id` FOREIGN KEY (`blotter_id`) REFERENCES `asset_management`.`trade`.`blotter`(`blotter_id`);
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ADD CONSTRAINT `fk_credit_private_credit_repayment_blotter_id` FOREIGN KEY (`blotter_id`) REFERENCES `asset_management`.`trade`.`blotter`(`blotter_id`);
ALTER TABLE `asset_management`.`credit`.`private_credit_repayment` ADD CONSTRAINT `fk_credit_private_credit_repayment_custody_account_id` FOREIGN KEY (`custody_account_id`) REFERENCES `asset_management`.`trade`.`custody_account`(`custody_account_id`);

-- ========= credit --> treasury (3 constraint(s)) =========
-- Requires: credit schema, treasury schema
ALTER TABLE `asset_management`.`credit`.`credit_position` ADD CONSTRAINT `fk_credit_credit_position_cash_position_id` FOREIGN KEY (`cash_position_id`) REFERENCES `asset_management`.`treasury`.`cash_position`(`cash_position_id`);
ALTER TABLE `asset_management`.`credit`.`maturity_schedule` ADD CONSTRAINT `fk_credit_maturity_schedule_cash_account_id` FOREIGN KEY (`cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);
ALTER TABLE `asset_management`.`credit`.`private_credit_drawdown` ADD CONSTRAINT `fk_credit_private_credit_drawdown_cash_account_id` FOREIGN KEY (`cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);

-- ========= deal --> actuarial (4 constraint(s)) =========
-- Requires: deal schema, actuarial schema
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ADD CONSTRAINT `fk_deal_deal_capital_commitment_liability_projection_id` FOREIGN KEY (`liability_projection_id`) REFERENCES `asset_management`.`actuarial`.`liability_projection`(`liability_projection_id`);
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ADD CONSTRAINT `fk_deal_deal_ic_submission_ldi_strategy_id` FOREIGN KEY (`ldi_strategy_id`) REFERENCES `asset_management`.`actuarial`.`ldi_strategy`(`ldi_strategy_id`);
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ADD CONSTRAINT `fk_deal_deal_ic_submission_liability_projection_id` FOREIGN KEY (`liability_projection_id`) REFERENCES `asset_management`.`actuarial`.`liability_projection`(`liability_projection_id`);
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ADD CONSTRAINT `fk_deal_deal_valuation_discount_rate_curve_id` FOREIGN KEY (`discount_rate_curve_id`) REFERENCES `asset_management`.`actuarial`.`discount_rate_curve`(`discount_rate_curve_id`);

-- ========= deal --> collateral (7 constraint(s)) =========
-- Requires: deal schema, collateral schema
ALTER TABLE `asset_management`.`deal`.`deal_document` ADD CONSTRAINT `fk_deal_deal_document_counterparty_legal_entity_counterparty_id` FOREIGN KEY (`counterparty_legal_entity_counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ADD CONSTRAINT `fk_deal_exclusivity_agreement_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ADD CONSTRAINT `fk_deal_exclusivity_agreement_counterparty_legal_entity_counterparty_id` FOREIGN KEY (`counterparty_legal_entity_counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`deal`.`loi` ADD CONSTRAINT `fk_deal_loi_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`deal`.`nda` ADD CONSTRAINT `fk_deal_nda_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`deal`.`nda` ADD CONSTRAINT `fk_deal_nda_counterparty_legal_entity_counterparty_id` FOREIGN KEY (`counterparty_legal_entity_counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`deal`.`term_sheet` ADD CONSTRAINT `fk_deal_term_sheet_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);

-- ========= deal --> compliance (7 constraint(s)) =========
-- Requires: deal schema, compliance schema
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ADD CONSTRAINT `fk_deal_co_invest_allocation_kyc_record_id` FOREIGN KEY (`kyc_record_id`) REFERENCES `asset_management`.`compliance`.`kyc_record`(`kyc_record_id`);
ALTER TABLE `asset_management`.`deal`.`deal_check` ADD CONSTRAINT `fk_deal_deal_check_rule_id` FOREIGN KEY (`rule_id`) REFERENCES `asset_management`.`compliance`.`rule`(`rule_id`);
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ADD CONSTRAINT `fk_deal_deal_ic_submission_ic_governance_record_id` FOREIGN KEY (`ic_governance_record_id`) REFERENCES `asset_management`.`compliance`.`ic_governance_record`(`ic_governance_record_id`);
ALTER TABLE `asset_management`.`deal`.`origination_source` ADD CONSTRAINT `fk_deal_origination_source_kyc_record_id` FOREIGN KEY (`kyc_record_id`) REFERENCES `asset_management`.`compliance`.`kyc_record`(`kyc_record_id`);
ALTER TABLE `asset_management`.`deal`.`target_entity` ADD CONSTRAINT `fk_deal_target_entity_kyc_record_id` FOREIGN KEY (`kyc_record_id`) REFERENCES `asset_management`.`compliance`.`kyc_record`(`kyc_record_id`);
ALTER TABLE `asset_management`.`deal`.`target_entity` ADD CONSTRAINT `fk_deal_target_entity_lei_record_id` FOREIGN KEY (`lei_record_id`) REFERENCES `asset_management`.`compliance`.`lei_record`(`lei_record_id`);
ALTER TABLE `asset_management`.`deal`.`target_entity` ADD CONSTRAINT `fk_deal_target_entity_sanctions_screening_id` FOREIGN KEY (`sanctions_screening_id`) REFERENCES `asset_management`.`compliance`.`sanctions_screening`(`sanctions_screening_id`);

-- ========= deal --> esg (5 constraint(s)) =========
-- Requires: deal schema, esg schema
ALTER TABLE `asset_management`.`deal`.`opportunity` ADD CONSTRAINT `fk_deal_opportunity_climate_scenario_id` FOREIGN KEY (`climate_scenario_id`) REFERENCES `asset_management`.`esg`.`climate_scenario`(`climate_scenario_id`);
ALTER TABLE `asset_management`.`deal`.`opportunity` ADD CONSTRAINT `fk_deal_opportunity_data_provider_id` FOREIGN KEY (`data_provider_id`) REFERENCES `asset_management`.`esg`.`data_provider`(`data_provider_id`);
ALTER TABLE `asset_management`.`deal`.`opportunity` ADD CONSTRAINT `fk_deal_opportunity_esg_benchmark_id` FOREIGN KEY (`esg_benchmark_id`) REFERENCES `asset_management`.`esg`.`esg_benchmark`(`esg_benchmark_id`);
ALTER TABLE `asset_management`.`deal`.`opportunity` ADD CONSTRAINT `fk_deal_opportunity_esg_policy_id` FOREIGN KEY (`esg_policy_id`) REFERENCES `asset_management`.`esg`.`esg_policy`(`esg_policy_id`);
ALTER TABLE `asset_management`.`deal`.`opportunity` ADD CONSTRAINT `fk_deal_opportunity_framework_id` FOREIGN KEY (`framework_id`) REFERENCES `asset_management`.`esg`.`framework`(`framework_id`);

-- ========= deal --> fee (3 constraint(s)) =========
-- Requires: deal schema, fee schema
ALTER TABLE `asset_management`.`deal`.`deal_fee` ADD CONSTRAINT `fk_deal_deal_fee_rate_schedule_id` FOREIGN KEY (`rate_schedule_id`) REFERENCES `asset_management`.`fee`.`rate_schedule`(`rate_schedule_id`);
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ADD CONSTRAINT `fk_deal_deal_ic_submission_fee_benchmark_id` FOREIGN KEY (`fee_benchmark_id`) REFERENCES `asset_management`.`fee`.`fee_benchmark`(`fee_benchmark_id`);
ALTER TABLE `asset_management`.`deal`.`ppm_review` ADD CONSTRAINT `fk_deal_ppm_review_fee_benchmark_id` FOREIGN KEY (`fee_benchmark_id`) REFERENCES `asset_management`.`fee`.`fee_benchmark`(`fee_benchmark_id`);

-- ========= deal --> manager (2 constraint(s)) =========
-- Requires: deal schema, manager schema
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ADD CONSTRAINT `fk_deal_deal_ic_submission_gp_manager_gp_profile_id` FOREIGN KEY (`gp_manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ADD CONSTRAINT `fk_deal_deal_ic_submission_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);

-- ========= deal --> portfolio (2 constraint(s)) =========
-- Requires: deal schema, portfolio schema
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ADD CONSTRAINT `fk_deal_deal_capital_commitment_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ADD CONSTRAINT `fk_deal_deal_ic_submission_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);

-- ========= deal --> research (6 constraint(s)) =========
-- Requires: deal schema, research schema
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ADD CONSTRAINT `fk_deal_deal_valuation_capital_market_assumption_id` FOREIGN KEY (`capital_market_assumption_id`) REFERENCES `asset_management`.`research`.`capital_market_assumption`(`capital_market_assumption_id`);
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ADD CONSTRAINT `fk_deal_deal_valuation_macro_model_run_id` FOREIGN KEY (`macro_model_run_id`) REFERENCES `asset_management`.`research`.`macro_model_run`(`macro_model_run_id`);
ALTER TABLE `asset_management`.`deal`.`opportunity` ADD CONSTRAINT `fk_deal_opportunity_asset_class_outlook_id` FOREIGN KEY (`asset_class_outlook_id`) REFERENCES `asset_management`.`research`.`asset_class_outlook`(`asset_class_outlook_id`);
ALTER TABLE `asset_management`.`deal`.`opportunity` ADD CONSTRAINT `fk_deal_opportunity_country_outlook_id` FOREIGN KEY (`country_outlook_id`) REFERENCES `asset_management`.`research`.`country_outlook`(`country_outlook_id`);
ALTER TABLE `asset_management`.`deal`.`opportunity` ADD CONSTRAINT `fk_deal_opportunity_sector_outlook_id` FOREIGN KEY (`sector_outlook_id`) REFERENCES `asset_management`.`research`.`sector_outlook`(`sector_outlook_id`);
ALTER TABLE `asset_management`.`deal`.`target_entity` ADD CONSTRAINT `fk_deal_target_entity_coverage_universe_id` FOREIGN KEY (`coverage_universe_id`) REFERENCES `asset_management`.`research`.`coverage_universe`(`coverage_universe_id`);

-- ========= deal --> shared (39 constraint(s)) =========
-- Requires: deal schema, shared schema
ALTER TABLE `asset_management`.`deal`.`co_invest_allocation` ADD CONSTRAINT `fk_deal_co_invest_allocation_relationship_manager_employee_id` FOREIGN KEY (`relationship_manager_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ADD CONSTRAINT `fk_deal_deal_capital_commitment_deal_employee_id` FOREIGN KEY (`deal_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ADD CONSTRAINT `fk_deal_deal_capital_commitment_deal_portfolio_manager_employee_id` FOREIGN KEY (`deal_portfolio_manager_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ADD CONSTRAINT `fk_deal_deal_capital_commitment_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`deal_capital_commitment` ADD CONSTRAINT `fk_deal_deal_capital_commitment_portfolio_manager_employee_id` FOREIGN KEY (`portfolio_manager_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`deal_check` ADD CONSTRAINT `fk_deal_deal_check_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`deal_document` ADD CONSTRAINT `fk_deal_deal_document_approved_by_user_employee_id` FOREIGN KEY (`approved_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`deal_document` ADD CONSTRAINT `fk_deal_deal_document_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`deal_document` ADD CONSTRAINT `fk_deal_deal_document_owner_user_employee_id` FOREIGN KEY (`owner_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`deal_fee` ADD CONSTRAINT `fk_deal_deal_fee_approver_employee_id` FOREIGN KEY (`approver_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ADD CONSTRAINT `fk_deal_deal_ic_submission_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ADD CONSTRAINT `fk_deal_deal_ic_submission_deal_employee_id` FOREIGN KEY (`deal_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ADD CONSTRAINT `fk_deal_deal_ic_submission_deal_external_advisor_employee_id` FOREIGN KEY (`deal_external_advisor_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ADD CONSTRAINT `fk_deal_deal_ic_submission_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ADD CONSTRAINT `fk_deal_deal_ic_submission_last_modified_by_user_employee_id` FOREIGN KEY (`last_modified_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`deal_ic_submission` ADD CONSTRAINT `fk_deal_deal_ic_submission_lead_investment_professional_employee_id` FOREIGN KEY (`lead_investment_professional_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ADD CONSTRAINT `fk_deal_deal_valuation_deal_employee_id` FOREIGN KEY (`deal_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ADD CONSTRAINT `fk_deal_deal_valuation_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ADD CONSTRAINT `fk_deal_deal_valuation_reviewer_employee_id` FOREIGN KEY (`reviewer_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`deal_valuation` ADD CONSTRAINT `fk_deal_deal_valuation_reviewer_id` FOREIGN KEY (`reviewer_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ADD CONSTRAINT `fk_deal_exclusivity_agreement_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`exclusivity_agreement` ADD CONSTRAINT `fk_deal_exclusivity_agreement_lead_investment_professional_employee_id` FOREIGN KEY (`lead_investment_professional_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`investment_memo` ADD CONSTRAINT `fk_deal_investment_memo_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`investment_memo` ADD CONSTRAINT `fk_deal_investment_memo_lead_author_employee_id` FOREIGN KEY (`lead_author_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`milestone` ADD CONSTRAINT `fk_deal_milestone_completed_by_user_employee_id` FOREIGN KEY (`completed_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`milestone` ADD CONSTRAINT `fk_deal_milestone_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`nda` ADD CONSTRAINT `fk_deal_nda_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`nda` ADD CONSTRAINT `fk_deal_nda_last_modified_by_user_employee_id` FOREIGN KEY (`last_modified_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`ppm_review` ADD CONSTRAINT `fk_deal_ppm_review_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`ppm_review` ADD CONSTRAINT `fk_deal_ppm_review_reviewer_employee_id` FOREIGN KEY (`reviewer_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`screening_decision` ADD CONSTRAINT `fk_deal_screening_decision_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`screening_decision` ADD CONSTRAINT `fk_deal_screening_decision_lead_reviewer_employee_id` FOREIGN KEY (`lead_reviewer_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`screening_decision` ADD CONSTRAINT `fk_deal_screening_decision_screening_employee_id` FOREIGN KEY (`screening_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`screening_decision` ADD CONSTRAINT `fk_deal_screening_decision_screening_lead_reviewer_employee_id` FOREIGN KEY (`screening_lead_reviewer_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`stage_transition` ADD CONSTRAINT `fk_deal_stage_transition_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`team` ADD CONSTRAINT `fk_deal_team_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`team` ADD CONSTRAINT `fk_deal_team_last_modified_by_user_employee_id` FOREIGN KEY (`last_modified_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`team` ADD CONSTRAINT `fk_deal_team_team_approved_by_employee_id` FOREIGN KEY (`team_approved_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`deal`.`team` ADD CONSTRAINT `fk_deal_team_team_employee_id` FOREIGN KEY (`team_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);

-- ========= deal --> valuation (1 constraint(s)) =========
-- Requires: deal schema, valuation schema
ALTER TABLE `asset_management`.`deal`.`target_entity` ADD CONSTRAINT `fk_deal_target_entity_valuation_asset_valuation_id` FOREIGN KEY (`valuation_asset_valuation_id`) REFERENCES `asset_management`.`valuation`.`valuation_asset_valuation`(`valuation_asset_valuation_id`);

-- ========= diligence --> collateral (1 constraint(s)) =========
-- Requires: diligence schema, collateral schema
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ADD CONSTRAINT `fk_diligence_kyc_aml_record_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);

-- ========= diligence --> compliance (5 constraint(s)) =========
-- Requires: diligence schema, compliance schema
ALTER TABLE `asset_management`.`diligence`.`assessment` ADD CONSTRAINT `fk_diligence_assessment_rule_id` FOREIGN KEY (`rule_id`) REFERENCES `asset_management`.`compliance`.`rule`(`rule_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ADD CONSTRAINT `fk_diligence_dd_finding_rule_id` FOREIGN KEY (`rule_id`) REFERENCES `asset_management`.`compliance`.`rule`(`rule_id`);
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ADD CONSTRAINT `fk_diligence_esg_dd_assessment_sfdr_disclosure_id` FOREIGN KEY (`sfdr_disclosure_id`) REFERENCES `asset_management`.`compliance`.`sfdr_disclosure`(`sfdr_disclosure_id`);
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ADD CONSTRAINT `fk_diligence_legal_dd_assessment_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ADD CONSTRAINT `fk_diligence_odd_assessment_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);

-- ========= diligence --> deal (39 constraint(s)) =========
-- Requires: diligence schema, deal schema
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ADD CONSTRAINT `fk_diligence_advisor_engagement_internal_deal_opportunity_id` FOREIGN KEY (`internal_deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`advisor_engagement` ADD CONSTRAINT `fk_diligence_advisor_engagement_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ADD CONSTRAINT `fk_diligence_data_room_access_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ADD CONSTRAINT `fk_diligence_data_room_access_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ADD CONSTRAINT `fk_diligence_dd_advisor_cost_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ADD CONSTRAINT `fk_diligence_dd_advisor_cost_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ADD CONSTRAINT `fk_diligence_dd_checklist_item_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ADD CONSTRAINT `fk_diligence_dd_checklist_item_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ADD CONSTRAINT `fk_diligence_dd_checklist_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ADD CONSTRAINT `fk_diligence_dd_checklist_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_document` ADD CONSTRAINT `fk_diligence_dd_document_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_document` ADD CONSTRAINT `fk_diligence_dd_document_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_document` ADD CONSTRAINT `fk_diligence_dd_document_target_entity_id` FOREIGN KEY (`target_entity_id`) REFERENCES `asset_management`.`deal`.`target_entity`(`target_entity_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ADD CONSTRAINT `fk_diligence_dd_engagement_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ADD CONSTRAINT `fk_diligence_dd_engagement_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ADD CONSTRAINT `fk_diligence_dd_finding_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ADD CONSTRAINT `fk_diligence_dd_finding_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ADD CONSTRAINT `fk_diligence_dd_risk_assessment_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ADD CONSTRAINT `fk_diligence_dd_risk_assessment_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ADD CONSTRAINT `fk_diligence_dd_status_event_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ADD CONSTRAINT `fk_diligence_dd_status_event_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ADD CONSTRAINT `fk_diligence_dd_workstream_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ADD CONSTRAINT `fk_diligence_dd_workstream_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ADD CONSTRAINT `fk_diligence_diligence_ic_condition_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ADD CONSTRAINT `fk_diligence_diligence_ic_condition_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ADD CONSTRAINT `fk_diligence_diligence_ic_submission_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ADD CONSTRAINT `fk_diligence_diligence_ic_submission_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ADD CONSTRAINT `fk_diligence_esg_dd_assessment_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ADD CONSTRAINT `fk_diligence_esg_dd_assessment_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ADD CONSTRAINT `fk_diligence_kyc_aml_record_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ADD CONSTRAINT `fk_diligence_kyc_aml_record_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ADD CONSTRAINT `fk_diligence_legal_dd_assessment_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ADD CONSTRAINT `fk_diligence_legal_dd_assessment_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`management_interview` ADD CONSTRAINT `fk_diligence_management_interview_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`management_interview` ADD CONSTRAINT `fk_diligence_management_interview_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`nda_record` ADD CONSTRAINT `fk_diligence_nda_record_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`nda_record` ADD CONSTRAINT `fk_diligence_nda_record_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`reference_check` ADD CONSTRAINT `fk_diligence_reference_check_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`diligence`.`reference_check` ADD CONSTRAINT `fk_diligence_reference_check_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);

-- ========= diligence --> esg (3 constraint(s)) =========
-- Requires: diligence schema, esg schema
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ADD CONSTRAINT `fk_diligence_esg_dd_assessment_climate_scenario_id` FOREIGN KEY (`climate_scenario_id`) REFERENCES `asset_management`.`esg`.`climate_scenario`(`climate_scenario_id`);
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ADD CONSTRAINT `fk_diligence_esg_dd_assessment_exclusion_list_id` FOREIGN KEY (`exclusion_list_id`) REFERENCES `asset_management`.`esg`.`exclusion_list`(`exclusion_list_id`);
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ADD CONSTRAINT `fk_diligence_kyc_aml_record_exclusion_list_id` FOREIGN KEY (`exclusion_list_id`) REFERENCES `asset_management`.`esg`.`exclusion_list`(`exclusion_list_id`);

-- ========= diligence --> fee (2 constraint(s)) =========
-- Requires: diligence schema, fee schema
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ADD CONSTRAINT `fk_diligence_diligence_ic_submission_fee_benchmark_id` FOREIGN KEY (`fee_benchmark_id`) REFERENCES `asset_management`.`fee`.`fee_benchmark`(`fee_benchmark_id`);
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ADD CONSTRAINT `fk_diligence_fdd_assessment_fee_benchmark_id` FOREIGN KEY (`fee_benchmark_id`) REFERENCES `asset_management`.`fee`.`fee_benchmark`(`fee_benchmark_id`);

-- ========= diligence --> infrastructure (3 constraint(s)) =========
-- Requires: diligence schema, infrastructure schema
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ADD CONSTRAINT `fk_diligence_dd_engagement_concession_agreement_id` FOREIGN KEY (`concession_agreement_id`) REFERENCES `asset_management`.`infrastructure`.`concession_agreement`(`concession_agreement_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ADD CONSTRAINT `fk_diligence_dd_engagement_infra_fund_commitment_id` FOREIGN KEY (`infra_fund_commitment_id`) REFERENCES `asset_management`.`infrastructure`.`infra_fund_commitment`(`infra_fund_commitment_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ADD CONSTRAINT `fk_diligence_dd_engagement_project_investment_id` FOREIGN KEY (`project_investment_id`) REFERENCES `asset_management`.`infrastructure`.`project_investment`(`project_investment_id`);

-- ========= diligence --> manager (39 constraint(s)) =========
-- Requires: diligence schema, manager schema
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ADD CONSTRAINT `fk_diligence_data_room_access_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ADD CONSTRAINT `fk_diligence_data_room_access_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ADD CONSTRAINT `fk_diligence_dd_advisor_cost_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ADD CONSTRAINT `fk_diligence_dd_advisor_cost_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ADD CONSTRAINT `fk_diligence_dd_checklist_item_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ADD CONSTRAINT `fk_diligence_dd_checklist_item_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ADD CONSTRAINT `fk_diligence_dd_checklist_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ADD CONSTRAINT `fk_diligence_dd_checklist_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_document` ADD CONSTRAINT `fk_diligence_dd_document_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_document` ADD CONSTRAINT `fk_diligence_dd_document_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ADD CONSTRAINT `fk_diligence_dd_engagement_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ADD CONSTRAINT `fk_diligence_dd_engagement_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ADD CONSTRAINT `fk_diligence_dd_engagement_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ADD CONSTRAINT `fk_diligence_dd_finding_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ADD CONSTRAINT `fk_diligence_dd_finding_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ADD CONSTRAINT `fk_diligence_dd_risk_assessment_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ADD CONSTRAINT `fk_diligence_dd_risk_assessment_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ADD CONSTRAINT `fk_diligence_diligence_ic_condition_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ADD CONSTRAINT `fk_diligence_diligence_ic_condition_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ADD CONSTRAINT `fk_diligence_diligence_ic_condition_risk_assessment_id` FOREIGN KEY (`risk_assessment_id`) REFERENCES `asset_management`.`manager`.`risk_assessment`(`risk_assessment_id`);
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ADD CONSTRAINT `fk_diligence_diligence_ic_submission_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ADD CONSTRAINT `fk_diligence_diligence_ic_submission_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ADD CONSTRAINT `fk_diligence_esg_dd_assessment_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ADD CONSTRAINT `fk_diligence_esg_dd_assessment_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ADD CONSTRAINT `fk_diligence_kyc_aml_record_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ADD CONSTRAINT `fk_diligence_kyc_aml_record_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ADD CONSTRAINT `fk_diligence_legal_dd_assessment_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ADD CONSTRAINT `fk_diligence_legal_dd_assessment_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`diligence`.`management_interview` ADD CONSTRAINT `fk_diligence_management_interview_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`diligence`.`management_interview` ADD CONSTRAINT `fk_diligence_management_interview_manager_contact_id` FOREIGN KEY (`manager_contact_id`) REFERENCES `asset_management`.`manager`.`manager_contact`(`manager_contact_id`);
ALTER TABLE `asset_management`.`diligence`.`management_interview` ADD CONSTRAINT `fk_diligence_management_interview_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`diligence`.`nda_record` ADD CONSTRAINT `fk_diligence_nda_record_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`diligence`.`nda_record` ADD CONSTRAINT `fk_diligence_nda_record_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ADD CONSTRAINT `fk_diligence_odd_assessment_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ADD CONSTRAINT `fk_diligence_odd_assessment_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ADD CONSTRAINT `fk_diligence_odd_assessment_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);
ALTER TABLE `asset_management`.`diligence`.`reference_check` ADD CONSTRAINT `fk_diligence_reference_check_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`diligence`.`reference_check` ADD CONSTRAINT `fk_diligence_reference_check_manager_contact_id` FOREIGN KEY (`manager_contact_id`) REFERENCES `asset_management`.`manager`.`manager_contact`(`manager_contact_id`);
ALTER TABLE `asset_management`.`diligence`.`reference_check` ADD CONSTRAINT `fk_diligence_reference_check_manager_gp_profile_id` FOREIGN KEY (`manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);

-- ========= diligence --> naturalresource (4 constraint(s)) =========
-- Requires: diligence schema, naturalresource schema
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ADD CONSTRAINT `fk_diligence_dd_advisor_cost_resource_asset_id` FOREIGN KEY (`resource_asset_id`) REFERENCES `asset_management`.`naturalresource`.`resource_asset`(`resource_asset_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_document` ADD CONSTRAINT `fk_diligence_dd_document_resource_asset_id` FOREIGN KEY (`resource_asset_id`) REFERENCES `asset_management`.`naturalresource`.`resource_asset`(`resource_asset_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ADD CONSTRAINT `fk_diligence_dd_engagement_resource_asset_id` FOREIGN KEY (`resource_asset_id`) REFERENCES `asset_management`.`naturalresource`.`resource_asset`(`resource_asset_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_finding` ADD CONSTRAINT `fk_diligence_dd_finding_resource_asset_id` FOREIGN KEY (`resource_asset_id`) REFERENCES `asset_management`.`naturalresource`.`resource_asset`(`resource_asset_id`);

-- ========= diligence --> research (5 constraint(s)) =========
-- Requires: diligence schema, research schema
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ADD CONSTRAINT `fk_diligence_cdd_assessment_country_outlook_id` FOREIGN KEY (`country_outlook_id`) REFERENCES `asset_management`.`research`.`country_outlook`(`country_outlook_id`);
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ADD CONSTRAINT `fk_diligence_cdd_assessment_sector_outlook_id` FOREIGN KEY (`sector_outlook_id`) REFERENCES `asset_management`.`research`.`sector_outlook`(`sector_outlook_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ADD CONSTRAINT `fk_diligence_dd_risk_assessment_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ADD CONSTRAINT `fk_diligence_diligence_ic_submission_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ADD CONSTRAINT `fk_diligence_fdd_assessment_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);

-- ========= diligence --> risk (2 constraint(s)) =========
-- Requires: diligence schema, risk schema
ALTER TABLE `asset_management`.`diligence`.`dd_risk_assessment` ADD CONSTRAINT `fk_diligence_dd_risk_assessment_stress_scenario_id` FOREIGN KEY (`stress_scenario_id`) REFERENCES `asset_management`.`risk`.`stress_scenario`(`stress_scenario_id`);
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ADD CONSTRAINT `fk_diligence_esg_dd_assessment_climate_stress_scenario_id` FOREIGN KEY (`climate_stress_scenario_id`) REFERENCES `asset_management`.`risk`.`stress_scenario`(`stress_scenario_id`);

-- ========= diligence --> shared (47 constraint(s)) =========
-- Requires: diligence schema, shared schema
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ADD CONSTRAINT `fk_diligence_cdd_assessment_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`cdd_assessment` ADD CONSTRAINT `fk_diligence_cdd_assessment_lead_analyst_employee_id` FOREIGN KEY (`lead_analyst_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ADD CONSTRAINT `fk_diligence_data_room_access_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`data_room_access` ADD CONSTRAINT `fk_diligence_data_room_access_lead_analyst_employee_id` FOREIGN KEY (`lead_analyst_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_advisor_cost` ADD CONSTRAINT `fk_diligence_dd_advisor_cost_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ADD CONSTRAINT `fk_diligence_dd_checklist_item_dd_employee_id` FOREIGN KEY (`dd_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ADD CONSTRAINT `fk_diligence_dd_checklist_item_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ADD CONSTRAINT `fk_diligence_dd_checklist_item_reviewer_employee_id` FOREIGN KEY (`reviewer_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_checklist_item` ADD CONSTRAINT `fk_diligence_dd_checklist_item_reviewer_id` FOREIGN KEY (`reviewer_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ADD CONSTRAINT `fk_diligence_dd_checklist_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_checklist` ADD CONSTRAINT `fk_diligence_dd_checklist_lead_analyst_employee_id` FOREIGN KEY (`lead_analyst_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_document` ADD CONSTRAINT `fk_diligence_dd_document_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_document` ADD CONSTRAINT `fk_diligence_dd_document_reviewer_employee_id` FOREIGN KEY (`reviewer_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ADD CONSTRAINT `fk_diligence_dd_engagement_dd_employee_id` FOREIGN KEY (`dd_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ADD CONSTRAINT `fk_diligence_dd_engagement_dd_ic_sponsor_employee_id` FOREIGN KEY (`dd_ic_sponsor_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ADD CONSTRAINT `fk_diligence_dd_engagement_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_engagement` ADD CONSTRAINT `fk_diligence_dd_engagement_ic_sponsor_employee_id` FOREIGN KEY (`ic_sponsor_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ADD CONSTRAINT `fk_diligence_dd_status_event_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_status_event` ADD CONSTRAINT `fk_diligence_dd_status_event_triggered_by_analyst_employee_id` FOREIGN KEY (`triggered_by_analyst_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ADD CONSTRAINT `fk_diligence_dd_workstream_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`dd_workstream` ADD CONSTRAINT `fk_diligence_dd_workstream_lead_analyst_employee_id` FOREIGN KEY (`lead_analyst_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ADD CONSTRAINT `fk_diligence_diligence_ic_condition_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_condition` ADD CONSTRAINT `fk_diligence_diligence_ic_condition_owner_analyst_employee_id` FOREIGN KEY (`owner_analyst_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ADD CONSTRAINT `fk_diligence_diligence_ic_submission_diligence_employee_id` FOREIGN KEY (`diligence_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ADD CONSTRAINT `fk_diligence_diligence_ic_submission_diligence_lead_analyst_employee_id` FOREIGN KEY (`diligence_lead_analyst_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ADD CONSTRAINT `fk_diligence_diligence_ic_submission_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`diligence_ic_submission` ADD CONSTRAINT `fk_diligence_diligence_ic_submission_lead_analyst_employee_id` FOREIGN KEY (`lead_analyst_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ADD CONSTRAINT `fk_diligence_esg_dd_assessment_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ADD CONSTRAINT `fk_diligence_esg_dd_assessment_esg_employee_id` FOREIGN KEY (`esg_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ADD CONSTRAINT `fk_diligence_esg_dd_assessment_reviewer_employee_id` FOREIGN KEY (`reviewer_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`esg_dd_assessment` ADD CONSTRAINT `fk_diligence_esg_dd_assessment_reviewer_id` FOREIGN KEY (`reviewer_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ADD CONSTRAINT `fk_diligence_fdd_assessment_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`fdd_assessment` ADD CONSTRAINT `fk_diligence_fdd_assessment_lead_fdd_analyst_employee_id` FOREIGN KEY (`lead_fdd_analyst_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ADD CONSTRAINT `fk_diligence_kyc_aml_record_compliance_officer_employee_id` FOREIGN KEY (`compliance_officer_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ADD CONSTRAINT `fk_diligence_kyc_aml_record_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ADD CONSTRAINT `fk_diligence_kyc_aml_record_kyc_compliance_officer_employee_id` FOREIGN KEY (`kyc_compliance_officer_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`kyc_aml_record` ADD CONSTRAINT `fk_diligence_kyc_aml_record_kyc_employee_id` FOREIGN KEY (`kyc_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ADD CONSTRAINT `fk_diligence_legal_dd_assessment_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`legal_dd_assessment` ADD CONSTRAINT `fk_diligence_legal_dd_assessment_lead_legal_counsel_employee_id` FOREIGN KEY (`lead_legal_counsel_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`management_interview` ADD CONSTRAINT `fk_diligence_management_interview_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`management_interview` ADD CONSTRAINT `fk_diligence_management_interview_lead_analyst_employee_id` FOREIGN KEY (`lead_analyst_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`nda_record` ADD CONSTRAINT `fk_diligence_nda_record_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`nda_record` ADD CONSTRAINT `fk_diligence_nda_record_lead_analyst_employee_id` FOREIGN KEY (`lead_analyst_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ADD CONSTRAINT `fk_diligence_odd_assessment_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`odd_assessment` ADD CONSTRAINT `fk_diligence_odd_assessment_lead_odd_analyst_employee_id` FOREIGN KEY (`lead_odd_analyst_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`reference_check` ADD CONSTRAINT `fk_diligence_reference_check_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`diligence`.`reference_check` ADD CONSTRAINT `fk_diligence_reference_check_interviewer_employee_id` FOREIGN KEY (`interviewer_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);

-- ========= equity --> collateral (2 constraint(s)) =========
-- Requires: equity schema, collateral schema
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ADD CONSTRAINT `fk_equity_corporate_action_election_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ADD CONSTRAINT `fk_equity_corporate_action_election_custodian_counterparty_id` FOREIGN KEY (`custodian_counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);

-- ========= equity --> esg (2 constraint(s)) =========
-- Requires: equity schema, esg schema
ALTER TABLE `asset_management`.`equity`.`engagement_log` ADD CONSTRAINT `fk_equity_engagement_log_engagement_controversy_id` FOREIGN KEY (`engagement_controversy_id`) REFERENCES `asset_management`.`esg`.`controversy`(`controversy_id`);
ALTER TABLE `asset_management`.`equity`.`engagement_log` ADD CONSTRAINT `fk_equity_engagement_log_engagement_related_controversy_id` FOREIGN KEY (`engagement_related_controversy_id`) REFERENCES `asset_management`.`esg`.`controversy`(`controversy_id`);

-- ========= equity --> manager (1 constraint(s)) =========
-- Requires: equity schema, manager schema
ALTER TABLE `asset_management`.`equity`.`equity_position` ADD CONSTRAINT `fk_equity_equity_position_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);

-- ========= equity --> portfolio (9 constraint(s)) =========
-- Requires: equity schema, portfolio schema
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ADD CONSTRAINT `fk_equity_corporate_action_election_holding_id` FOREIGN KEY (`holding_id`) REFERENCES `asset_management`.`portfolio`.`holding`(`holding_id`);
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ADD CONSTRAINT `fk_equity_corporate_action_election_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`equity`.`dividend_record` ADD CONSTRAINT `fk_equity_dividend_record_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ADD CONSTRAINT `fk_equity_equity_factor_exposure_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`equity`.`equity_position` ADD CONSTRAINT `fk_equity_equity_position_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ADD CONSTRAINT `fk_equity_proxy_voting_record_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`equity`.`restriction` ADD CONSTRAINT `fk_equity_restriction_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`equity`.`short_interest` ADD CONSTRAINT `fk_equity_short_interest_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`equity`.`stock_selection` ADD CONSTRAINT `fk_equity_stock_selection_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);

-- ========= equity --> research (1 constraint(s)) =========
-- Requires: equity schema, research schema
ALTER TABLE `asset_management`.`equity`.`earnings_announcement` ADD CONSTRAINT `fk_equity_earnings_announcement_market_consensus_id` FOREIGN KEY (`market_consensus_id`) REFERENCES `asset_management`.`research`.`market_consensus`(`market_consensus_id`);

-- ========= equity --> risk (2 constraint(s)) =========
-- Requires: equity schema, risk schema
ALTER TABLE `asset_management`.`equity`.`equity_factor_exposure` ADD CONSTRAINT `fk_equity_equity_factor_exposure_factor_model_id` FOREIGN KEY (`factor_model_id`) REFERENCES `asset_management`.`risk`.`model`(`model_id`);
ALTER TABLE `asset_management`.`equity`.`equity_position` ADD CONSTRAINT `fk_equity_equity_position_risk_factor_exposure_id` FOREIGN KEY (`risk_factor_exposure_id`) REFERENCES `asset_management`.`risk`.`risk_factor_exposure`(`risk_factor_exposure_id`);

-- ========= equity --> shared (25 constraint(s)) =========
-- Requires: equity schema, shared schema
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ADD CONSTRAINT `fk_equity_corporate_action_election_corporate_employee_id` FOREIGN KEY (`corporate_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ADD CONSTRAINT `fk_equity_corporate_action_election_corporate_trader_employee_id` FOREIGN KEY (`corporate_trader_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ADD CONSTRAINT `fk_equity_corporate_action_election_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ADD CONSTRAINT `fk_equity_corporate_action_election_portfolio_manager_employee_id` FOREIGN KEY (`portfolio_manager_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`equity`.`corporate_action_election` ADD CONSTRAINT `fk_equity_corporate_action_election_trader_employee_id` FOREIGN KEY (`trader_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`equity`.`engagement_log` ADD CONSTRAINT `fk_equity_engagement_log_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`equity`.`engagement_log` ADD CONSTRAINT `fk_equity_engagement_log_lead_analyst_employee_id` FOREIGN KEY (`lead_analyst_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`equity`.`equity_benchmark` ADD CONSTRAINT `fk_equity_equity_benchmark_creator_employee_id` FOREIGN KEY (`creator_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ADD CONSTRAINT `fk_equity_equity_coverage_analyst_employee_id` FOREIGN KEY (`analyst_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`equity`.`equity_coverage` ADD CONSTRAINT `fk_equity_equity_coverage_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`equity`.`equity_position` ADD CONSTRAINT `fk_equity_equity_position_trader_employee_id` FOREIGN KEY (`trader_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ADD CONSTRAINT `fk_equity_index_rebalance_event_compliance_reviewer_employee_id` FOREIGN KEY (`compliance_reviewer_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`equity`.`index_rebalance_event` ADD CONSTRAINT `fk_equity_index_rebalance_event_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ADD CONSTRAINT `fk_equity_proxy_voting_record_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`equity`.`proxy_voting_record` ADD CONSTRAINT `fk_equity_proxy_voting_record_responsible_investment_analyst_employee_id` FOREIGN KEY (`responsible_investment_analyst_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`equity`.`research_note` ADD CONSTRAINT `fk_equity_research_note_compliance_reviewer_employee_id` FOREIGN KEY (`compliance_reviewer_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`equity`.`research_note` ADD CONSTRAINT `fk_equity_research_note_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`equity`.`research_note` ADD CONSTRAINT `fk_equity_research_note_peer_review_analyst_employee_id` FOREIGN KEY (`peer_review_analyst_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`equity`.`research_note` ADD CONSTRAINT `fk_equity_research_note_research_compliance_reviewer_employee_id` FOREIGN KEY (`research_compliance_reviewer_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`equity`.`research_note` ADD CONSTRAINT `fk_equity_research_note_research_employee_id` FOREIGN KEY (`research_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`equity`.`research_note` ADD CONSTRAINT `fk_equity_research_note_research_peer_review_analyst_employee_id` FOREIGN KEY (`research_peer_review_analyst_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`equity`.`stock_selection` ADD CONSTRAINT `fk_equity_stock_selection_analyst_employee_id` FOREIGN KEY (`analyst_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`equity`.`stock_selection` ADD CONSTRAINT `fk_equity_stock_selection_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`equity`.`valuation_model` ADD CONSTRAINT `fk_equity_valuation_model_analyst_employee_id` FOREIGN KEY (`analyst_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`equity`.`valuation_model` ADD CONSTRAINT `fk_equity_valuation_model_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);

-- ========= equity --> trade (2 constraint(s)) =========
-- Requires: equity schema, trade schema
ALTER TABLE `asset_management`.`equity`.`equity_position` ADD CONSTRAINT `fk_equity_equity_position_custody_account_id` FOREIGN KEY (`custody_account_id`) REFERENCES `asset_management`.`trade`.`custody_account`(`custody_account_id`);
ALTER TABLE `asset_management`.`equity`.`equity_position` ADD CONSTRAINT `fk_equity_equity_position_instrument_id` FOREIGN KEY (`instrument_id`) REFERENCES `asset_management`.`trade`.`instrument`(`instrument_id`);

-- ========= esg --> compliance (4 constraint(s)) =========
-- Requires: esg schema, compliance schema
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ADD CONSTRAINT `fk_esg_integration_checklist_ic_decision_id` FOREIGN KEY (`ic_decision_id`) REFERENCES `asset_management`.`compliance`.`ic_decision`(`ic_decision_id`);
ALTER TABLE `asset_management`.`esg`.`pai_indicator` ADD CONSTRAINT `fk_esg_pai_indicator_sfdr_disclosure_id` FOREIGN KEY (`sfdr_disclosure_id`) REFERENCES `asset_management`.`compliance`.`sfdr_disclosure`(`sfdr_disclosure_id`);
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ADD CONSTRAINT `fk_esg_sfdr_classification_sfdr_disclosure_id` FOREIGN KEY (`sfdr_disclosure_id`) REFERENCES `asset_management`.`compliance`.`sfdr_disclosure`(`sfdr_disclosure_id`);
ALTER TABLE `asset_management`.`esg`.`watch_list` ADD CONSTRAINT `fk_esg_watch_list_rule_id` FOREIGN KEY (`rule_id`) REFERENCES `asset_management`.`compliance`.`rule`(`rule_id`);

-- ========= esg --> credit (1 constraint(s)) =========
-- Requires: esg schema, credit schema
ALTER TABLE `asset_management`.`esg`.`pai_indicator` ADD CONSTRAINT `fk_esg_pai_indicator_credit_issuer_id` FOREIGN KEY (`credit_issuer_id`) REFERENCES `asset_management`.`credit`.`credit_issuer`(`credit_issuer_id`);

-- ========= esg --> deal (4 constraint(s)) =========
-- Requires: esg schema, deal schema
ALTER TABLE `asset_management`.`esg`.`due_diligence` ADD CONSTRAINT `fk_esg_due_diligence_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`esg`.`due_diligence` ADD CONSTRAINT `fk_esg_due_diligence_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ADD CONSTRAINT `fk_esg_integration_checklist_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ADD CONSTRAINT `fk_esg_integration_checklist_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);

-- ========= esg --> diligence (2 constraint(s)) =========
-- Requires: esg schema, diligence schema
ALTER TABLE `asset_management`.`esg`.`due_diligence` ADD CONSTRAINT `fk_esg_due_diligence_dd_engagement_id` FOREIGN KEY (`dd_engagement_id`) REFERENCES `asset_management`.`diligence`.`dd_engagement`(`dd_engagement_id`);
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ADD CONSTRAINT `fk_esg_integration_checklist_dd_engagement_id` FOREIGN KEY (`dd_engagement_id`) REFERENCES `asset_management`.`diligence`.`dd_engagement`(`dd_engagement_id`);

-- ========= esg --> equity (1 constraint(s)) =========
-- Requires: esg schema, equity schema
ALTER TABLE `asset_management`.`esg`.`issuer_esg_rating` ADD CONSTRAINT `fk_esg_issuer_esg_rating_equity_issuer_id` FOREIGN KEY (`equity_issuer_id`) REFERENCES `asset_management`.`equity`.`equity_issuer`(`equity_issuer_id`);

-- ========= esg --> infrastructure (2 constraint(s)) =========
-- Requires: esg schema, infrastructure schema
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ADD CONSTRAINT `fk_esg_ghg_emission_record_infra_asset_id` FOREIGN KEY (`infra_asset_id`) REFERENCES `asset_management`.`infrastructure`.`infra_asset`(`infra_asset_id`);
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ADD CONSTRAINT `fk_esg_taxonomy_alignment_infra_asset_id` FOREIGN KEY (`infra_asset_id`) REFERENCES `asset_management`.`infrastructure`.`infra_asset`(`infra_asset_id`);

-- ========= esg --> manager (1 constraint(s)) =========
-- Requires: esg schema, manager schema
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ADD CONSTRAINT `fk_esg_sfdr_classification_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);

-- ========= esg --> naturalresource (1 constraint(s)) =========
-- Requires: esg schema, naturalresource schema
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ADD CONSTRAINT `fk_esg_ghg_emission_record_resource_asset_id` FOREIGN KEY (`resource_asset_id`) REFERENCES `asset_management`.`naturalresource`.`resource_asset`(`resource_asset_id`);

-- ========= esg --> performance (2 constraint(s)) =========
-- Requires: esg schema, performance schema
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ADD CONSTRAINT `fk_esg_responsible_investment_report_composite_id` FOREIGN KEY (`composite_id`) REFERENCES `asset_management`.`performance`.`composite`(`composite_id`);
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ADD CONSTRAINT `fk_esg_sfdr_classification_composite_id` FOREIGN KEY (`composite_id`) REFERENCES `asset_management`.`performance`.`composite`(`composite_id`);

-- ========= esg --> portfolio (8 constraint(s)) =========
-- Requires: esg schema, portfolio schema
ALTER TABLE `asset_management`.`esg`.`ghg_emission_record` ADD CONSTRAINT `fk_esg_ghg_emission_record_portfolio_holding_id` FOREIGN KEY (`portfolio_holding_id`) REFERENCES `asset_management`.`portfolio`.`holding`(`holding_id`);
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ADD CONSTRAINT `fk_esg_kpi_measurement_portfolio_holding_id` FOREIGN KEY (`portfolio_holding_id`) REFERENCES `asset_management`.`portfolio`.`holding`(`holding_id`);
ALTER TABLE `asset_management`.`esg`.`kpi_measurement` ADD CONSTRAINT `fk_esg_kpi_measurement_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`esg`.`kpi_target` ADD CONSTRAINT `fk_esg_kpi_target_holding_id` FOREIGN KEY (`holding_id`) REFERENCES `asset_management`.`portfolio`.`holding`(`holding_id`);
ALTER TABLE `asset_management`.`esg`.`kpi_target` ADD CONSTRAINT `fk_esg_kpi_target_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ADD CONSTRAINT `fk_esg_proxy_vote_record_holding_id` FOREIGN KEY (`holding_id`) REFERENCES `asset_management`.`portfolio`.`holding`(`holding_id`);
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ADD CONSTRAINT `fk_esg_taxonomy_alignment_holding_id` FOREIGN KEY (`holding_id`) REFERENCES `asset_management`.`portfolio`.`holding`(`holding_id`);
ALTER TABLE `asset_management`.`esg`.`taxonomy_alignment` ADD CONSTRAINT `fk_esg_taxonomy_alignment_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);

-- ========= esg --> privateequity (2 constraint(s)) =========
-- Requires: esg schema, privateequity schema
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ADD CONSTRAINT `fk_esg_integration_checklist_investment_id` FOREIGN KEY (`investment_id`) REFERENCES `asset_management`.`privateequity`.`investment`(`investment_id`);
ALTER TABLE `asset_management`.`esg`.`sfdr_classification` ADD CONSTRAINT `fk_esg_sfdr_classification_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);

-- ========= esg --> shared (11 constraint(s)) =========
-- Requires: esg schema, shared schema
ALTER TABLE `asset_management`.`esg`.`climate_scenario` ADD CONSTRAINT `fk_esg_climate_scenario_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`esg`.`controversy` ADD CONSTRAINT `fk_esg_controversy_assigned_analyst_employee_id` FOREIGN KEY (`assigned_analyst_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`esg`.`due_diligence` ADD CONSTRAINT `fk_esg_due_diligence_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`esg`.`due_diligence` ADD CONSTRAINT `fk_esg_due_diligence_lead_assessor_employee_id` FOREIGN KEY (`lead_assessor_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`esg`.`engagement_objective` ADD CONSTRAINT `fk_esg_engagement_objective_owner_employee_id` FOREIGN KEY (`owner_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`esg`.`esg_policy` ADD CONSTRAINT `fk_esg_esg_policy_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`esg`.`exclusion_list` ADD CONSTRAINT `fk_esg_exclusion_list_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`esg`.`integration_checklist` ADD CONSTRAINT `fk_esg_integration_checklist_assigned_to_employee_id` FOREIGN KEY (`assigned_to_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`esg`.`responsible_investment_report` ADD CONSTRAINT `fk_esg_responsible_investment_report_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`esg`.`tcfd_disclosure` ADD CONSTRAINT `fk_esg_tcfd_disclosure_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`esg`.`watch_list` ADD CONSTRAINT `fk_esg_watch_list_owner_employee_id` FOREIGN KEY (`owner_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);

-- ========= esg --> trade (2 constraint(s)) =========
-- Requires: esg schema, trade schema
ALTER TABLE `asset_management`.`esg`.`proxy_vote_record` ADD CONSTRAINT `fk_esg_proxy_vote_record_instrument_id` FOREIGN KEY (`instrument_id`) REFERENCES `asset_management`.`trade`.`instrument`(`instrument_id`);
ALTER TABLE `asset_management`.`esg`.`watch_list` ADD CONSTRAINT `fk_esg_watch_list_instrument_id` FOREIGN KEY (`instrument_id`) REFERENCES `asset_management`.`trade`.`instrument`(`instrument_id`);

-- ========= fee --> collateral (5 constraint(s)) =========
-- Requires: fee schema, collateral schema
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ADD CONSTRAINT `fk_fee_carry_escrow_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ADD CONSTRAINT `fk_fee_gp_fee_rebate_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ADD CONSTRAINT `fk_fee_organizational_expense_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`fee`.`placement_fee` ADD CONSTRAINT `fk_fee_placement_fee_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ADD CONSTRAINT `fk_fee_transaction_fee_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);

-- ========= fee --> compliance (1 constraint(s)) =========
-- Requires: fee schema, compliance schema
ALTER TABLE `asset_management`.`fee`.`transparency_report` ADD CONSTRAINT `fk_fee_transparency_report_regulatory_filing_id` FOREIGN KEY (`regulatory_filing_id`) REFERENCES `asset_management`.`compliance`.`regulatory_filing`(`regulatory_filing_id`);

-- ========= fee --> deal (2 constraint(s)) =========
-- Requires: fee schema, deal schema
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ADD CONSTRAINT `fk_fee_transaction_fee_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ADD CONSTRAINT `fk_fee_transaction_fee_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);

-- ========= fee --> manager (31 constraint(s)) =========
-- Requires: fee schema, manager schema
ALTER TABLE `asset_management`.`fee`.`accrual` ADD CONSTRAINT `fk_fee_accrual_external_manager_gp_profile_id` FOREIGN KEY (`external_manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`fee`.`accrual` ADD CONSTRAINT `fk_fee_accrual_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ADD CONSTRAINT `fk_fee_carry_distribution_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`fee`.`dispute` ADD CONSTRAINT `fk_fee_dispute_external_manager_gp_profile_id` FOREIGN KEY (`external_manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`fee`.`dispute` ADD CONSTRAINT `fk_fee_dispute_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`fee`.`dispute` ADD CONSTRAINT `fk_fee_dispute_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ADD CONSTRAINT `fk_fee_fee_calculation_run_external_manager_gp_profile_id` FOREIGN KEY (`external_manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ADD CONSTRAINT `fk_fee_fee_calculation_run_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ADD CONSTRAINT `fk_fee_fee_calculation_run_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ADD CONSTRAINT `fk_fee_gp_fee_rebate_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ADD CONSTRAINT `fk_fee_high_water_mark_external_manager_gp_profile_id` FOREIGN KEY (`external_manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ADD CONSTRAINT `fk_fee_high_water_mark_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ADD CONSTRAINT `fk_fee_high_water_mark_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ADD CONSTRAINT `fk_fee_incentive_fee_external_manager_gp_profile_id` FOREIGN KEY (`external_manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ADD CONSTRAINT `fk_fee_incentive_fee_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ADD CONSTRAINT `fk_fee_incentive_fee_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);
ALTER TABLE `asset_management`.`fee`.`invoice` ADD CONSTRAINT `fk_fee_invoice_external_manager_gp_profile_id` FOREIGN KEY (`external_manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`fee`.`invoice` ADD CONSTRAINT `fk_fee_invoice_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`fee`.`invoice` ADD CONSTRAINT `fk_fee_invoice_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);
ALTER TABLE `asset_management`.`fee`.`management_fee` ADD CONSTRAINT `fk_fee_management_fee_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ADD CONSTRAINT `fk_fee_monitoring_fee_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`fee`.`payment` ADD CONSTRAINT `fk_fee_payment_external_manager_gp_profile_id` FOREIGN KEY (`external_manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`fee`.`payment` ADD CONSTRAINT `fk_fee_payment_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`fee`.`payment` ADD CONSTRAINT `fk_fee_payment_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);
ALTER TABLE `asset_management`.`fee`.`placement_fee` ADD CONSTRAINT `fk_fee_placement_fee_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ADD CONSTRAINT `fk_fee_rate_schedule_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`fee`.`rate_schedule` ADD CONSTRAINT `fk_fee_rate_schedule_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ADD CONSTRAINT `fk_fee_transaction_fee_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`fee`.`transparency_report` ADD CONSTRAINT `fk_fee_transparency_report_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`fee`.`waiver` ADD CONSTRAINT `fk_fee_waiver_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`fee`.`waiver` ADD CONSTRAINT `fk_fee_waiver_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);

-- ========= fee --> performance (3 constraint(s)) =========
-- Requires: fee schema, performance schema
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ADD CONSTRAINT `fk_fee_fee_calculation_run_performance_calculation_run_id` FOREIGN KEY (`performance_calculation_run_id`) REFERENCES `asset_management`.`performance`.`performance_calculation_run`(`performance_calculation_run_id`);
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ADD CONSTRAINT `fk_fee_high_water_mark_performance_benchmark_id` FOREIGN KEY (`performance_benchmark_id`) REFERENCES `asset_management`.`performance`.`performance_benchmark`(`performance_benchmark_id`);
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ADD CONSTRAINT `fk_fee_incentive_fee_performance_benchmark_id` FOREIGN KEY (`performance_benchmark_id`) REFERENCES `asset_management`.`performance`.`performance_benchmark`(`performance_benchmark_id`);

-- ========= fee --> privateequity (40 constraint(s)) =========
-- Requires: fee schema, privateequity schema
ALTER TABLE `asset_management`.`fee`.`accrual` ADD CONSTRAINT `fk_fee_accrual_investment_id` FOREIGN KEY (`investment_id`) REFERENCES `asset_management`.`privateequity`.`investment`(`investment_id`);
ALTER TABLE `asset_management`.`fee`.`carried_interest` ADD CONSTRAINT `fk_fee_carried_interest_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`fee`.`carried_interest` ADD CONSTRAINT `fk_fee_carried_interest_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ADD CONSTRAINT `fk_fee_carry_distribution_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ADD CONSTRAINT `fk_fee_carry_distribution_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ADD CONSTRAINT `fk_fee_carry_distribution_investment_id` FOREIGN KEY (`investment_id`) REFERENCES `asset_management`.`privateequity`.`investment`(`investment_id`);
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ADD CONSTRAINT `fk_fee_carry_escrow_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ADD CONSTRAINT `fk_fee_carry_escrow_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`fee`.`clawback_event` ADD CONSTRAINT `fk_fee_clawback_event_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`fee`.`clawback_event` ADD CONSTRAINT `fk_fee_clawback_event_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ADD CONSTRAINT `fk_fee_clawback_provision_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`fee`.`clawback_provision` ADD CONSTRAINT `fk_fee_clawback_provision_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`fee`.`dispute` ADD CONSTRAINT `fk_fee_dispute_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`fee`.`dispute` ADD CONSTRAINT `fk_fee_dispute_investment_id` FOREIGN KEY (`investment_id`) REFERENCES `asset_management`.`privateequity`.`investment`(`investment_id`);
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ADD CONSTRAINT `fk_fee_fee_calculation_run_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ADD CONSTRAINT `fk_fee_fee_calculation_run_investment_id` FOREIGN KEY (`investment_id`) REFERENCES `asset_management`.`privateequity`.`investment`(`investment_id`);
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ADD CONSTRAINT `fk_fee_gp_fee_rebate_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ADD CONSTRAINT `fk_fee_gp_fee_rebate_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ADD CONSTRAINT `fk_fee_gp_fee_rebate_lpa_terms_id` FOREIGN KEY (`lpa_terms_id`) REFERENCES `asset_management`.`privateequity`.`lpa_terms`(`lpa_terms_id`);
ALTER TABLE `asset_management`.`fee`.`gp_fee_rebate` ADD CONSTRAINT `fk_fee_gp_fee_rebate_portfolio_company_id` FOREIGN KEY (`portfolio_company_id`) REFERENCES `asset_management`.`privateequity`.`portfolio_company`(`portfolio_company_id`);
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ADD CONSTRAINT `fk_fee_hurdle_rate_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ADD CONSTRAINT `fk_fee_hurdle_rate_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`fee`.`hurdle_rate` ADD CONSTRAINT `fk_fee_hurdle_rate_gp_gp_entity_id` FOREIGN KEY (`gp_gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`fee`.`management_fee` ADD CONSTRAINT `fk_fee_management_fee_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`fee`.`management_fee` ADD CONSTRAINT `fk_fee_management_fee_gp_gp_entity_id` FOREIGN KEY (`gp_gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ADD CONSTRAINT `fk_fee_monitoring_fee_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ADD CONSTRAINT `fk_fee_monitoring_fee_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ADD CONSTRAINT `fk_fee_monitoring_fee_investment_id` FOREIGN KEY (`investment_id`) REFERENCES `asset_management`.`privateequity`.`investment`(`investment_id`);
ALTER TABLE `asset_management`.`fee`.`monitoring_fee` ADD CONSTRAINT `fk_fee_monitoring_fee_portfolio_company_id` FOREIGN KEY (`portfolio_company_id`) REFERENCES `asset_management`.`privateequity`.`portfolio_company`(`portfolio_company_id`);
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ADD CONSTRAINT `fk_fee_organizational_expense_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`fee`.`payment` ADD CONSTRAINT `fk_fee_payment_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`fee`.`payment` ADD CONSTRAINT `fk_fee_payment_investment_id` FOREIGN KEY (`investment_id`) REFERENCES `asset_management`.`privateequity`.`investment`(`investment_id`);
ALTER TABLE `asset_management`.`fee`.`placement_fee` ADD CONSTRAINT `fk_fee_placement_fee_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`fee`.`placement_fee` ADD CONSTRAINT `fk_fee_placement_fee_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ADD CONSTRAINT `fk_fee_transaction_fee_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`fee`.`transaction_fee` ADD CONSTRAINT `fk_fee_transaction_fee_investment_id` FOREIGN KEY (`investment_id`) REFERENCES `asset_management`.`privateequity`.`investment`(`investment_id`);
ALTER TABLE `asset_management`.`fee`.`transparency_report` ADD CONSTRAINT `fk_fee_transparency_report_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`fee`.`waiver` ADD CONSTRAINT `fk_fee_waiver_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`fee`.`waiver` ADD CONSTRAINT `fk_fee_waiver_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`fee`.`waterfall` ADD CONSTRAINT `fk_fee_waterfall_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);

-- ========= fee --> research (1 constraint(s)) =========
-- Requires: fee schema, research schema
ALTER TABLE `asset_management`.`fee`.`fee_benchmark` ADD CONSTRAINT `fk_fee_fee_benchmark_data_vendor_id` FOREIGN KEY (`data_vendor_id`) REFERENCES `asset_management`.`research`.`data_vendor`(`data_vendor_id`);

-- ========= fee --> shared (16 constraint(s)) =========
-- Requires: fee schema, shared schema
ALTER TABLE `asset_management`.`fee`.`accrual` ADD CONSTRAINT `fk_fee_accrual_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`fee`.`clawback_event` ADD CONSTRAINT `fk_fee_clawback_event_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`fee`.`clawback_event` ADD CONSTRAINT `fk_fee_clawback_event_updated_by_user_employee_id` FOREIGN KEY (`updated_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`fee`.`dispute` ADD CONSTRAINT `fk_fee_dispute_assigned_to_user_employee_id` FOREIGN KEY (`assigned_to_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`fee`.`dispute` ADD CONSTRAINT `fk_fee_dispute_identified_by_user_employee_id` FOREIGN KEY (`identified_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ADD CONSTRAINT `fk_fee_fee_calculation_run_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ADD CONSTRAINT `fk_fee_incentive_fee_approved_by_user_employee_id` FOREIGN KEY (`approved_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ADD CONSTRAINT `fk_fee_incentive_fee_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ADD CONSTRAINT `fk_fee_organizational_expense_approved_by_user_employee_id` FOREIGN KEY (`approved_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ADD CONSTRAINT `fk_fee_organizational_expense_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`fee`.`transparency_report` ADD CONSTRAINT `fk_fee_transparency_report_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`fee`.`transparency_report` ADD CONSTRAINT `fk_fee_transparency_report_prepared_by_user_employee_id` FOREIGN KEY (`prepared_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`fee`.`transparency_report` ADD CONSTRAINT `fk_fee_transparency_report_transparency_employee_id` FOREIGN KEY (`transparency_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`fee`.`transparency_report` ADD CONSTRAINT `fk_fee_transparency_report_transparency_prepared_by_user_employee_id` FOREIGN KEY (`transparency_prepared_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`fee`.`waiver` ADD CONSTRAINT `fk_fee_waiver_approved_by_user_employee_id` FOREIGN KEY (`approved_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`fee`.`waiver` ADD CONSTRAINT `fk_fee_waiver_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);

-- ========= fee --> trade (1 constraint(s)) =========
-- Requires: fee schema, trade schema
ALTER TABLE `asset_management`.`fee`.`payment` ADD CONSTRAINT `fk_fee_payment_settlement_instruction_id` FOREIGN KEY (`settlement_instruction_id`) REFERENCES `asset_management`.`trade`.`settlement_instruction`(`settlement_instruction_id`);

-- ========= fee --> treasury (6 constraint(s)) =========
-- Requires: fee schema, treasury schema
ALTER TABLE `asset_management`.`fee`.`carry_distribution` ADD CONSTRAINT `fk_fee_carry_distribution_settlement_cash_account_id` FOREIGN KEY (`settlement_cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);
ALTER TABLE `asset_management`.`fee`.`carry_escrow` ADD CONSTRAINT `fk_fee_carry_escrow_cash_account_id` FOREIGN KEY (`cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);
ALTER TABLE `asset_management`.`fee`.`incentive_fee` ADD CONSTRAINT `fk_fee_incentive_fee_payment_cash_account_id` FOREIGN KEY (`payment_cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);
ALTER TABLE `asset_management`.`fee`.`organizational_expense` ADD CONSTRAINT `fk_fee_organizational_expense_cash_account_id` FOREIGN KEY (`cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);
ALTER TABLE `asset_management`.`fee`.`payment` ADD CONSTRAINT `fk_fee_payment_settlement_cash_account_id` FOREIGN KEY (`settlement_cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);
ALTER TABLE `asset_management`.`fee`.`placement_fee` ADD CONSTRAINT `fk_fee_placement_fee_cash_account_id` FOREIGN KEY (`cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);

-- ========= fee --> valuation (6 constraint(s)) =========
-- Requires: fee schema, valuation schema
ALTER TABLE `asset_management`.`fee`.`carried_interest` ADD CONSTRAINT `fk_fee_carried_interest_valuation_cycle_id` FOREIGN KEY (`valuation_cycle_id`) REFERENCES `asset_management`.`valuation`.`cycle`(`cycle_id`);
ALTER TABLE `asset_management`.`fee`.`clawback_event` ADD CONSTRAINT `fk_fee_clawback_event_valuation_cycle_id` FOREIGN KEY (`valuation_cycle_id`) REFERENCES `asset_management`.`valuation`.`cycle`(`cycle_id`);
ALTER TABLE `asset_management`.`fee`.`dispute` ADD CONSTRAINT `fk_fee_dispute_valuation_asset_valuation_id` FOREIGN KEY (`valuation_asset_valuation_id`) REFERENCES `asset_management`.`valuation`.`valuation_asset_valuation`(`valuation_asset_valuation_id`);
ALTER TABLE `asset_management`.`fee`.`fee_calculation_run` ADD CONSTRAINT `fk_fee_fee_calculation_run_valuation_cycle_id` FOREIGN KEY (`valuation_cycle_id`) REFERENCES `asset_management`.`valuation`.`cycle`(`cycle_id`);
ALTER TABLE `asset_management`.`fee`.`high_water_mark` ADD CONSTRAINT `fk_fee_high_water_mark_valuation_nav_record_id` FOREIGN KEY (`valuation_nav_record_id`) REFERENCES `asset_management`.`valuation`.`valuation_nav_record`(`valuation_nav_record_id`);
ALTER TABLE `asset_management`.`fee`.`transparency_report` ADD CONSTRAINT `fk_fee_transparency_report_valuation_cycle_id` FOREIGN KEY (`valuation_cycle_id`) REFERENCES `asset_management`.`valuation`.`cycle`(`cycle_id`);

-- ========= infrastructure --> collateral (1 constraint(s)) =========
-- Requires: infrastructure schema, collateral schema
ALTER TABLE `asset_management`.`infrastructure`.`infra_fund_commitment` ADD CONSTRAINT `fk_infrastructure_infra_fund_commitment_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);

-- ========= infrastructure --> compliance (2 constraint(s)) =========
-- Requires: infrastructure schema, compliance schema
ALTER TABLE `asset_management`.`infrastructure`.`infra_asset` ADD CONSTRAINT `fk_infrastructure_infra_asset_regulatory_calendar_id` FOREIGN KEY (`regulatory_calendar_id`) REFERENCES `asset_management`.`compliance`.`regulatory_calendar`(`regulatory_calendar_id`);
ALTER TABLE `asset_management`.`infrastructure`.`infra_asset` ADD CONSTRAINT `fk_infrastructure_infra_asset_regulatory_filing_id` FOREIGN KEY (`regulatory_filing_id`) REFERENCES `asset_management`.`compliance`.`regulatory_filing`(`regulatory_filing_id`);

-- ========= infrastructure --> credit (8 constraint(s)) =========
-- Requires: infrastructure schema, credit schema
ALTER TABLE `asset_management`.`infrastructure`.`infra_asset` ADD CONSTRAINT `fk_infrastructure_infra_asset_covenant_monitoring_id` FOREIGN KEY (`covenant_monitoring_id`) REFERENCES `asset_management`.`credit`.`covenant_monitoring`(`covenant_monitoring_id`);
ALTER TABLE `asset_management`.`infrastructure`.`infra_asset` ADD CONSTRAINT `fk_infrastructure_infra_asset_credit_issuer_id` FOREIGN KEY (`credit_issuer_id`) REFERENCES `asset_management`.`credit`.`credit_issuer`(`credit_issuer_id`);
ALTER TABLE `asset_management`.`infrastructure`.`infra_asset` ADD CONSTRAINT `fk_infrastructure_infra_asset_fixed_income_security_id` FOREIGN KEY (`fixed_income_security_id`) REFERENCES `asset_management`.`credit`.`fixed_income_security`(`fixed_income_security_id`);
ALTER TABLE `asset_management`.`infrastructure`.`infra_asset` ADD CONSTRAINT `fk_infrastructure_infra_asset_private_credit_investment_id` FOREIGN KEY (`private_credit_investment_id`) REFERENCES `asset_management`.`credit`.`private_credit_investment`(`private_credit_investment_id`);
ALTER TABLE `asset_management`.`infrastructure`.`infra_fund_commitment` ADD CONSTRAINT `fk_infrastructure_infra_fund_commitment_covenant_monitoring_id` FOREIGN KEY (`covenant_monitoring_id`) REFERENCES `asset_management`.`credit`.`covenant_monitoring`(`covenant_monitoring_id`);
ALTER TABLE `asset_management`.`infrastructure`.`infra_fund_commitment` ADD CONSTRAINT `fk_infrastructure_infra_fund_commitment_credit_issuer_id` FOREIGN KEY (`credit_issuer_id`) REFERENCES `asset_management`.`credit`.`credit_issuer`(`credit_issuer_id`);
ALTER TABLE `asset_management`.`infrastructure`.`infra_fund_commitment` ADD CONSTRAINT `fk_infrastructure_infra_fund_commitment_fixed_income_security_id` FOREIGN KEY (`fixed_income_security_id`) REFERENCES `asset_management`.`credit`.`fixed_income_security`(`fixed_income_security_id`);
ALTER TABLE `asset_management`.`infrastructure`.`project_investment` ADD CONSTRAINT `fk_infrastructure_project_investment_private_credit_investment_id` FOREIGN KEY (`private_credit_investment_id`) REFERENCES `asset_management`.`credit`.`private_credit_investment`(`private_credit_investment_id`);

-- ========= infrastructure --> deal (5 constraint(s)) =========
-- Requires: infrastructure schema, deal schema
ALTER TABLE `asset_management`.`infrastructure`.`co_investment` ADD CONSTRAINT `fk_infrastructure_co_investment_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`infrastructure`.`co_investment` ADD CONSTRAINT `fk_infrastructure_co_investment_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`infrastructure`.`infra_asset` ADD CONSTRAINT `fk_infrastructure_infra_asset_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`infrastructure`.`infra_fund_commitment` ADD CONSTRAINT `fk_infrastructure_infra_fund_commitment_deal_capital_commitment_id` FOREIGN KEY (`deal_capital_commitment_id`) REFERENCES `asset_management`.`deal`.`deal_capital_commitment`(`deal_capital_commitment_id`);
ALTER TABLE `asset_management`.`infrastructure`.`infrastructure_ic_approval` ADD CONSTRAINT `fk_infrastructure_infrastructure_ic_approval_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);

-- ========= infrastructure --> fee (3 constraint(s)) =========
-- Requires: infrastructure schema, fee schema
ALTER TABLE `asset_management`.`infrastructure`.`infra_fund_commitment` ADD CONSTRAINT `fk_infrastructure_infra_fund_commitment_carried_interest_id` FOREIGN KEY (`carried_interest_id`) REFERENCES `asset_management`.`fee`.`carried_interest`(`carried_interest_id`);
ALTER TABLE `asset_management`.`infrastructure`.`infra_fund_commitment` ADD CONSTRAINT `fk_infrastructure_infra_fund_commitment_management_fee_id` FOREIGN KEY (`management_fee_id`) REFERENCES `asset_management`.`fee`.`management_fee`(`management_fee_id`);
ALTER TABLE `asset_management`.`infrastructure`.`infra_fund_commitment` ADD CONSTRAINT `fk_infrastructure_infra_fund_commitment_waterfall_id` FOREIGN KEY (`waterfall_id`) REFERENCES `asset_management`.`fee`.`waterfall`(`waterfall_id`);

-- ========= infrastructure --> naturalresource (1 constraint(s)) =========
-- Requires: infrastructure schema, naturalresource schema
ALTER TABLE `asset_management`.`infrastructure`.`infra_asset` ADD CONSTRAINT `fk_infrastructure_infra_asset_resource_asset_id` FOREIGN KEY (`resource_asset_id`) REFERENCES `asset_management`.`naturalresource`.`resource_asset`(`resource_asset_id`);

-- ========= infrastructure --> privateequity (16 constraint(s)) =========
-- Requires: infrastructure schema, privateequity schema
ALTER TABLE `asset_management`.`infrastructure`.`asset_disposition` ADD CONSTRAINT `fk_infrastructure_asset_disposition_infrastructure_fund_id` FOREIGN KEY (`infrastructure_fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`infrastructure`.`asset_ownership` ADD CONSTRAINT `fk_infrastructure_asset_ownership_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`infrastructure`.`capital_call_notice_document` ADD CONSTRAINT `fk_infrastructure_capital_call_notice_document_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`infrastructure`.`capital_call_notice_document` ADD CONSTRAINT `fk_infrastructure_capital_call_notice_document_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`infrastructure`.`co_investment` ADD CONSTRAINT `fk_infrastructure_co_investment_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`infrastructure`.`co_investment` ADD CONSTRAINT `fk_infrastructure_co_investment_gp_sponsor_gp_entity_id` FOREIGN KEY (`gp_sponsor_gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`infrastructure`.`distribution_event` ADD CONSTRAINT `fk_infrastructure_distribution_event_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`infrastructure`.`distribution_event` ADD CONSTRAINT `fk_infrastructure_distribution_event_infrastructure_fund_id` FOREIGN KEY (`infrastructure_fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`infrastructure`.`distribution_notice_document` ADD CONSTRAINT `fk_infrastructure_distribution_notice_document_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`infrastructure`.`distribution_notice_document` ADD CONSTRAINT `fk_infrastructure_distribution_notice_document_infrastructure_fund_id` FOREIGN KEY (`infrastructure_fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`infrastructure`.`fund_nav_report` ADD CONSTRAINT `fk_infrastructure_fund_nav_report_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`infrastructure`.`fund_nav_report` ADD CONSTRAINT `fk_infrastructure_fund_nav_report_infrastructure_fund_id` FOREIGN KEY (`infrastructure_fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`infrastructure`.`infra_fund_commitment` ADD CONSTRAINT `fk_infrastructure_infra_fund_commitment_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`infrastructure`.`infrastructure_capital_call` ADD CONSTRAINT `fk_infrastructure_infrastructure_capital_call_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`infrastructure`.`infrastructure_capital_call` ADD CONSTRAINT `fk_infrastructure_infrastructure_capital_call_infrastructure_fund_id` FOREIGN KEY (`infrastructure_fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`infrastructure`.`infrastructure_ic_approval` ADD CONSTRAINT `fk_infrastructure_infrastructure_ic_approval_infrastructure_fund_id` FOREIGN KEY (`infrastructure_fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);

-- ========= infrastructure --> research (13 constraint(s)) =========
-- Requires: infrastructure schema, research schema
ALTER TABLE `asset_management`.`infrastructure`.`cashflow_projection` ADD CONSTRAINT `fk_infrastructure_cashflow_projection_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);
ALTER TABLE `asset_management`.`infrastructure`.`infra_asset` ADD CONSTRAINT `fk_infrastructure_infra_asset_asset_class_outlook_id` FOREIGN KEY (`asset_class_outlook_id`) REFERENCES `asset_management`.`research`.`asset_class_outlook`(`asset_class_outlook_id`);
ALTER TABLE `asset_management`.`infrastructure`.`infra_asset` ADD CONSTRAINT `fk_infrastructure_infra_asset_country_outlook_id` FOREIGN KEY (`country_outlook_id`) REFERENCES `asset_management`.`research`.`country_outlook`(`country_outlook_id`);
ALTER TABLE `asset_management`.`infrastructure`.`infra_asset` ADD CONSTRAINT `fk_infrastructure_infra_asset_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);
ALTER TABLE `asset_management`.`infrastructure`.`infra_asset` ADD CONSTRAINT `fk_infrastructure_infra_asset_sector_outlook_id` FOREIGN KEY (`sector_outlook_id`) REFERENCES `asset_management`.`research`.`sector_outlook`(`sector_outlook_id`);
ALTER TABLE `asset_management`.`infrastructure`.`infra_fund_commitment` ADD CONSTRAINT `fk_infrastructure_infra_fund_commitment_asset_class_outlook_id` FOREIGN KEY (`asset_class_outlook_id`) REFERENCES `asset_management`.`research`.`asset_class_outlook`(`asset_class_outlook_id`);
ALTER TABLE `asset_management`.`infrastructure`.`infra_fund_commitment` ADD CONSTRAINT `fk_infrastructure_infra_fund_commitment_country_outlook_id` FOREIGN KEY (`country_outlook_id`) REFERENCES `asset_management`.`research`.`country_outlook`(`country_outlook_id`);
ALTER TABLE `asset_management`.`infrastructure`.`infra_fund_commitment` ADD CONSTRAINT `fk_infrastructure_infra_fund_commitment_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);
ALTER TABLE `asset_management`.`infrastructure`.`infra_fund_commitment` ADD CONSTRAINT `fk_infrastructure_infra_fund_commitment_sector_outlook_id` FOREIGN KEY (`sector_outlook_id`) REFERENCES `asset_management`.`research`.`sector_outlook`(`sector_outlook_id`);
ALTER TABLE `asset_management`.`infrastructure`.`project_investment` ADD CONSTRAINT `fk_infrastructure_project_investment_asset_class_outlook_id` FOREIGN KEY (`asset_class_outlook_id`) REFERENCES `asset_management`.`research`.`asset_class_outlook`(`asset_class_outlook_id`);
ALTER TABLE `asset_management`.`infrastructure`.`project_investment` ADD CONSTRAINT `fk_infrastructure_project_investment_country_outlook_id` FOREIGN KEY (`country_outlook_id`) REFERENCES `asset_management`.`research`.`country_outlook`(`country_outlook_id`);
ALTER TABLE `asset_management`.`infrastructure`.`project_investment` ADD CONSTRAINT `fk_infrastructure_project_investment_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);
ALTER TABLE `asset_management`.`infrastructure`.`project_investment` ADD CONSTRAINT `fk_infrastructure_project_investment_sector_outlook_id` FOREIGN KEY (`sector_outlook_id`) REFERENCES `asset_management`.`research`.`sector_outlook`(`sector_outlook_id`);

-- ========= infrastructure --> risk (1 constraint(s)) =========
-- Requires: infrastructure schema, risk schema
ALTER TABLE `asset_management`.`infrastructure`.`infra_fund_commitment` ADD CONSTRAINT `fk_infrastructure_infra_fund_commitment_risk_model_id` FOREIGN KEY (`risk_model_id`) REFERENCES `asset_management`.`risk`.`model`(`model_id`);

-- ========= infrastructure --> shared (19 constraint(s)) =========
-- Requires: infrastructure schema, shared schema
ALTER TABLE `asset_management`.`infrastructure`.`asset_disposition` ADD CONSTRAINT `fk_infrastructure_asset_disposition_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`infrastructure`.`asset_disposition` ADD CONSTRAINT `fk_infrastructure_asset_disposition_advisor_entity_actor_id` FOREIGN KEY (`advisor_entity_actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`infrastructure`.`asset_disposition` ADD CONSTRAINT `fk_infrastructure_asset_disposition_legal_advisor_entity_actor_id` FOREIGN KEY (`legal_advisor_entity_actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`infrastructure`.`asset_ownership` ADD CONSTRAINT `fk_infrastructure_asset_ownership_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`infrastructure`.`capital_call_notice_document` ADD CONSTRAINT `fk_infrastructure_capital_call_notice_document_legal_entity_id` FOREIGN KEY (`legal_entity_id`) REFERENCES `asset_management`.`shared`.`legal_entity`(`legal_entity_id`);
ALTER TABLE `asset_management`.`infrastructure`.`cashflow_projection` ADD CONSTRAINT `fk_infrastructure_cashflow_projection_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`infrastructure`.`concession_agreement` ADD CONSTRAINT `fk_infrastructure_concession_agreement_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`infrastructure`.`concession_agreement` ADD CONSTRAINT `fk_infrastructure_concession_agreement_concessionaire_entity_actor_id` FOREIGN KEY (`concessionaire_entity_actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`infrastructure`.`distribution_event` ADD CONSTRAINT `fk_infrastructure_distribution_event_distribution_employee_id` FOREIGN KEY (`distribution_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`infrastructure`.`distribution_event` ADD CONSTRAINT `fk_infrastructure_distribution_event_distribution_updated_by_user_employee_id` FOREIGN KEY (`distribution_updated_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`infrastructure`.`distribution_event` ADD CONSTRAINT `fk_infrastructure_distribution_event_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`infrastructure`.`distribution_event` ADD CONSTRAINT `fk_infrastructure_distribution_event_updated_by_user_employee_id` FOREIGN KEY (`updated_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`infrastructure`.`distribution_notice_document` ADD CONSTRAINT `fk_infrastructure_distribution_notice_document_legal_entity_id` FOREIGN KEY (`legal_entity_id`) REFERENCES `asset_management`.`shared`.`legal_entity`(`legal_entity_id`);
ALTER TABLE `asset_management`.`infrastructure`.`infra_fund_commitment` ADD CONSTRAINT `fk_infrastructure_infra_fund_commitment_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`infrastructure`.`infrastructure_capital_call` ADD CONSTRAINT `fk_infrastructure_infrastructure_capital_call_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`infrastructure`.`infrastructure_capital_call` ADD CONSTRAINT `fk_infrastructure_infrastructure_capital_call_approver_employee_id` FOREIGN KEY (`approver_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`infrastructure`.`infrastructure_capital_call` ADD CONSTRAINT `fk_infrastructure_infrastructure_capital_call_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`infrastructure`.`operator_contract` ADD CONSTRAINT `fk_infrastructure_operator_contract_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`infrastructure`.`ownership_agreement` ADD CONSTRAINT `fk_infrastructure_ownership_agreement_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);

-- ========= infrastructure --> trade (1 constraint(s)) =========
-- Requires: infrastructure schema, trade schema
ALTER TABLE `asset_management`.`infrastructure`.`distribution_event` ADD CONSTRAINT `fk_infrastructure_distribution_event_custody_account_id` FOREIGN KEY (`custody_account_id`) REFERENCES `asset_management`.`trade`.`custody_account`(`custody_account_id`);

-- ========= infrastructure --> treasury (3 constraint(s)) =========
-- Requires: infrastructure schema, treasury schema
ALTER TABLE `asset_management`.`infrastructure`.`availability_payment` ADD CONSTRAINT `fk_infrastructure_availability_payment_cash_account_id` FOREIGN KEY (`cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);
ALTER TABLE `asset_management`.`infrastructure`.`distribution_event` ADD CONSTRAINT `fk_infrastructure_distribution_event_cash_flow_event_id` FOREIGN KEY (`cash_flow_event_id`) REFERENCES `asset_management`.`treasury`.`cash_flow_event`(`cash_flow_event_id`);
ALTER TABLE `asset_management`.`infrastructure`.`infrastructure_capital_call` ADD CONSTRAINT `fk_infrastructure_infrastructure_capital_call_cash_account_id` FOREIGN KEY (`cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);

-- ========= manager --> compliance (9 constraint(s)) =========
-- Requires: manager schema, compliance schema
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ADD CONSTRAINT `fk_manager_co_invest_right_ic_decision_id` FOREIGN KEY (`ic_decision_id`) REFERENCES `asset_management`.`compliance`.`ic_decision`(`ic_decision_id`);
ALTER TABLE `asset_management`.`manager`.`esg_profile` ADD CONSTRAINT `fk_manager_esg_profile_esg_policy_document_id` FOREIGN KEY (`esg_policy_document_id`) REFERENCES `asset_management`.`compliance`.`policy_document`(`policy_document_id`);
ALTER TABLE `asset_management`.`manager`.`kyc` ADD CONSTRAINT `fk_manager_kyc_kyc_record_id` FOREIGN KEY (`kyc_record_id`) REFERENCES `asset_management`.`compliance`.`kyc_record`(`kyc_record_id`);
ALTER TABLE `asset_management`.`manager`.`kyc` ADD CONSTRAINT `fk_manager_kyc_sanctions_screening_id` FOREIGN KEY (`sanctions_screening_id`) REFERENCES `asset_management`.`compliance`.`sanctions_screening`(`sanctions_screening_id`);
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ADD CONSTRAINT `fk_manager_manager_mandate_ic_approval_ic_decision_id` FOREIGN KEY (`ic_approval_ic_decision_id`) REFERENCES `asset_management`.`compliance`.`ic_decision`(`ic_decision_id`);
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ADD CONSTRAINT `fk_manager_manager_mandate_ic_decision_id` FOREIGN KEY (`ic_decision_id`) REFERENCES `asset_management`.`compliance`.`ic_decision`(`ic_decision_id`);
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ADD CONSTRAINT `fk_manager_manager_mandate_sfdr_disclosure_id` FOREIGN KEY (`sfdr_disclosure_id`) REFERENCES `asset_management`.`compliance`.`sfdr_disclosure`(`sfdr_disclosure_id`);
ALTER TABLE `asset_management`.`manager`.`meeting` ADD CONSTRAINT `fk_manager_meeting_ic_governance_record_id` FOREIGN KEY (`ic_governance_record_id`) REFERENCES `asset_management`.`compliance`.`ic_governance_record`(`ic_governance_record_id`);
ALTER TABLE `asset_management`.`manager`.`sla_breach` ADD CONSTRAINT `fk_manager_sla_breach_sla_obligation_id` FOREIGN KEY (`sla_obligation_id`) REFERENCES `asset_management`.`compliance`.`obligation`(`obligation_id`);

-- ========= manager --> deal (2 constraint(s)) =========
-- Requires: manager schema, deal schema
ALTER TABLE `asset_management`.`manager`.`meeting` ADD CONSTRAINT `fk_manager_meeting_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`manager`.`meeting` ADD CONSTRAINT `fk_manager_meeting_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);

-- ========= manager --> diligence (1 constraint(s)) =========
-- Requires: manager schema, diligence schema
ALTER TABLE `asset_management`.`manager`.`evaluation` ADD CONSTRAINT `fk_manager_evaluation_dd_engagement_id` FOREIGN KEY (`dd_engagement_id`) REFERENCES `asset_management`.`diligence`.`dd_engagement`(`dd_engagement_id`);

-- ========= manager --> esg (5 constraint(s)) =========
-- Requires: manager schema, esg schema
ALTER TABLE `asset_management`.`manager`.`esg_profile` ADD CONSTRAINT `fk_manager_esg_profile_esg_policy_id` FOREIGN KEY (`esg_policy_id`) REFERENCES `asset_management`.`esg`.`esg_policy`(`esg_policy_id`);
ALTER TABLE `asset_management`.`manager`.`esg_profile` ADD CONSTRAINT `fk_manager_esg_profile_framework_id` FOREIGN KEY (`framework_id`) REFERENCES `asset_management`.`esg`.`framework`(`framework_id`);
ALTER TABLE `asset_management`.`manager`.`gp_profile` ADD CONSTRAINT `fk_manager_gp_profile_framework_id` FOREIGN KEY (`framework_id`) REFERENCES `asset_management`.`esg`.`framework`(`framework_id`);
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ADD CONSTRAINT `fk_manager_manager_mandate_esg_policy_id` FOREIGN KEY (`esg_policy_id`) REFERENCES `asset_management`.`esg`.`esg_policy`(`esg_policy_id`);
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ADD CONSTRAINT `fk_manager_manager_mandate_exclusion_list_id` FOREIGN KEY (`exclusion_list_id`) REFERENCES `asset_management`.`esg`.`exclusion_list`(`exclusion_list_id`);

-- ========= manager --> performance (6 constraint(s)) =========
-- Requires: manager schema, performance schema
ALTER TABLE `asset_management`.`manager`.`evaluation` ADD CONSTRAINT `fk_manager_evaluation_composite_id` FOREIGN KEY (`composite_id`) REFERENCES `asset_management`.`performance`.`composite`(`composite_id`);
ALTER TABLE `asset_management`.`manager`.`evaluation` ADD CONSTRAINT `fk_manager_evaluation_performance_benchmark_id` FOREIGN KEY (`performance_benchmark_id`) REFERENCES `asset_management`.`performance`.`performance_benchmark`(`performance_benchmark_id`);
ALTER TABLE `asset_management`.`manager`.`fee_schedule` ADD CONSTRAINT `fk_manager_fee_schedule_performance_benchmark_id` FOREIGN KEY (`performance_benchmark_id`) REFERENCES `asset_management`.`performance`.`performance_benchmark`(`performance_benchmark_id`);
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ADD CONSTRAINT `fk_manager_manager_benchmark_performance_benchmark_id` FOREIGN KEY (`performance_benchmark_id`) REFERENCES `asset_management`.`performance`.`performance_benchmark`(`performance_benchmark_id`);
ALTER TABLE `asset_management`.`manager`.`rfp_response` ADD CONSTRAINT `fk_manager_rfp_response_performance_benchmark_id` FOREIGN KEY (`performance_benchmark_id`) REFERENCES `asset_management`.`performance`.`performance_benchmark`(`performance_benchmark_id`);
ALTER TABLE `asset_management`.`manager`.`rfp` ADD CONSTRAINT `fk_manager_rfp_performance_benchmark_id` FOREIGN KEY (`performance_benchmark_id`) REFERENCES `asset_management`.`performance`.`performance_benchmark`(`performance_benchmark_id`);

-- ========= manager --> portfolio (1 constraint(s)) =========
-- Requires: manager schema, portfolio schema
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ADD CONSTRAINT `fk_manager_manager_mandate_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);

-- ========= manager --> privateequity (1 constraint(s)) =========
-- Requires: manager schema, privateequity schema
ALTER TABLE `asset_management`.`manager`.`co_invest_right` ADD CONSTRAINT `fk_manager_co_invest_right_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);

-- ========= manager --> research (3 constraint(s)) =========
-- Requires: manager schema, research schema
ALTER TABLE `asset_management`.`manager`.`evaluation` ADD CONSTRAINT `fk_manager_evaluation_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);
ALTER TABLE `asset_management`.`manager`.`manager_benchmark` ADD CONSTRAINT `fk_manager_manager_benchmark_macro_indicator_id` FOREIGN KEY (`macro_indicator_id`) REFERENCES `asset_management`.`research`.`macro_indicator`(`macro_indicator_id`);
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ADD CONSTRAINT `fk_manager_risk_assessment_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);

-- ========= manager --> risk (1 constraint(s)) =========
-- Requires: manager schema, risk schema
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ADD CONSTRAINT `fk_manager_risk_assessment_risk_model_id` FOREIGN KEY (`risk_model_id`) REFERENCES `asset_management`.`risk`.`model`(`model_id`);

-- ========= manager --> shared (10 constraint(s)) =========
-- Requires: manager schema, shared schema
ALTER TABLE `asset_management`.`manager`.`evaluation` ADD CONSTRAINT `fk_manager_evaluation_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`manager`.`evaluation` ADD CONSTRAINT `fk_manager_evaluation_evaluation_employee_id` FOREIGN KEY (`evaluation_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`manager`.`evaluation` ADD CONSTRAINT `fk_manager_evaluation_evaluation_lead_analyst_employee_id` FOREIGN KEY (`evaluation_lead_analyst_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`manager`.`lpac_membership` ADD CONSTRAINT `fk_manager_lpac_membership_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`manager`.`manager_contact` ADD CONSTRAINT `fk_manager_manager_contact_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ADD CONSTRAINT `fk_manager_mandate_amendment_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`manager`.`meeting` ADD CONSTRAINT `fk_manager_meeting_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ADD CONSTRAINT `fk_manager_risk_assessment_approver_employee_id` FOREIGN KEY (`approver_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`manager`.`risk_assessment` ADD CONSTRAINT `fk_manager_risk_assessment_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`manager`.`sla_agreement` ADD CONSTRAINT `fk_manager_sla_agreement_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);

-- ========= manager --> trade (3 constraint(s)) =========
-- Requires: manager schema, trade schema
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ADD CONSTRAINT `fk_manager_manager_mandate_custodian_id` FOREIGN KEY (`custodian_id`) REFERENCES `asset_management`.`trade`.`custodian`(`custodian_id`);
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ADD CONSTRAINT `fk_manager_mandate_amendment_mandate_dealcloud_amendment_id` FOREIGN KEY (`mandate_dealcloud_amendment_id`) REFERENCES `asset_management`.`trade`.`amendment`(`amendment_id`);
ALTER TABLE `asset_management`.`manager`.`mandate_amendment` ADD CONSTRAINT `fk_manager_mandate_amendment_mandate_efront_amendment_id` FOREIGN KEY (`mandate_efront_amendment_id`) REFERENCES `asset_management`.`trade`.`amendment`(`amendment_id`);

-- ========= manager --> valuation (1 constraint(s)) =========
-- Requires: manager schema, valuation schema
ALTER TABLE `asset_management`.`manager`.`manager_mandate` ADD CONSTRAINT `fk_manager_manager_mandate_valuation_policy_id` FOREIGN KEY (`valuation_policy_id`) REFERENCES `asset_management`.`valuation`.`valuation_policy`(`valuation_policy_id`);

-- ========= naturalresource --> collateral (1 constraint(s)) =========
-- Requires: naturalresource schema, collateral schema
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ADD CONSTRAINT `fk_naturalresource_resource_cashflow_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);

-- ========= naturalresource --> compliance (5 constraint(s)) =========
-- Requires: naturalresource schema, compliance schema
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ADD CONSTRAINT `fk_naturalresource_resource_asset_audit_finding_id` FOREIGN KEY (`audit_finding_id`) REFERENCES `asset_management`.`compliance`.`audit_finding`(`audit_finding_id`);
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ADD CONSTRAINT `fk_naturalresource_resource_asset_certification_id` FOREIGN KEY (`certification_id`) REFERENCES `asset_management`.`compliance`.`certification`(`certification_id`);
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ADD CONSTRAINT `fk_naturalresource_resource_asset_gips_compliance_record_id` FOREIGN KEY (`gips_compliance_record_id`) REFERENCES `asset_management`.`compliance`.`gips_compliance_record`(`gips_compliance_record_id`);
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ADD CONSTRAINT `fk_naturalresource_resource_asset_policy_document_id` FOREIGN KEY (`policy_document_id`) REFERENCES `asset_management`.`compliance`.`policy_document`(`policy_document_id`);
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ADD CONSTRAINT `fk_naturalresource_resource_asset_sfdr_disclosure_id` FOREIGN KEY (`sfdr_disclosure_id`) REFERENCES `asset_management`.`compliance`.`sfdr_disclosure`(`sfdr_disclosure_id`);

-- ========= naturalresource --> infrastructure (1 constraint(s)) =========
-- Requires: naturalresource schema, infrastructure schema
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ADD CONSTRAINT `fk_naturalresource_resource_asset_project_investment_id` FOREIGN KEY (`project_investment_id`) REFERENCES `asset_management`.`infrastructure`.`project_investment`(`project_investment_id`);

-- ========= naturalresource --> manager (2 constraint(s)) =========
-- Requires: naturalresource schema, manager schema
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ADD CONSTRAINT `fk_naturalresource_resource_asset_asset_manager_gp_profile_id` FOREIGN KEY (`asset_manager_gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ADD CONSTRAINT `fk_naturalresource_resource_holding_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);

-- ========= naturalresource --> portfolio (8 constraint(s)) =========
-- Requires: naturalresource schema, portfolio schema
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ADD CONSTRAINT `fk_naturalresource_capital_event_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ADD CONSTRAINT `fk_naturalresource_commodity_exposure_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ADD CONSTRAINT `fk_naturalresource_harvest_plan_investment_portfolio_id` FOREIGN KEY (`investment_portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ADD CONSTRAINT `fk_naturalresource_land_parcel_investment_portfolio_id` FOREIGN KEY (`investment_portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ADD CONSTRAINT `fk_naturalresource_resource_budget_investment_portfolio_id` FOREIGN KEY (`investment_portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ADD CONSTRAINT `fk_naturalresource_resource_cashflow_investment_portfolio_id` FOREIGN KEY (`investment_portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ADD CONSTRAINT `fk_naturalresource_resource_fund_commitment_investment_portfolio_id` FOREIGN KEY (`investment_portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ADD CONSTRAINT `fk_naturalresource_resource_holding_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);

-- ========= naturalresource --> privateequity (5 constraint(s)) =========
-- Requires: naturalresource schema, privateequity schema
ALTER TABLE `asset_management`.`naturalresource`.`capital_event` ADD CONSTRAINT `fk_naturalresource_capital_event_natural_resource_investment_id` FOREIGN KEY (`natural_resource_investment_id`) REFERENCES `asset_management`.`privateequity`.`investment`(`investment_id`);
ALTER TABLE `asset_management`.`naturalresource`.`depletion_schedule` ADD CONSTRAINT `fk_naturalresource_depletion_schedule_investment_id` FOREIGN KEY (`investment_id`) REFERENCES `asset_management`.`privateequity`.`investment`(`investment_id`);
ALTER TABLE `asset_management`.`naturalresource`.`operator_agreement` ADD CONSTRAINT `fk_naturalresource_operator_agreement_investment_id` FOREIGN KEY (`investment_id`) REFERENCES `asset_management`.`privateequity`.`investment`(`investment_id`);
ALTER TABLE `asset_management`.`naturalresource`.`resource_fund_commitment` ADD CONSTRAINT `fk_naturalresource_resource_fund_commitment_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ADD CONSTRAINT `fk_naturalresource_resource_holding_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);

-- ========= naturalresource --> research (10 constraint(s)) =========
-- Requires: naturalresource schema, research schema
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ADD CONSTRAINT `fk_naturalresource_commodity_exposure_macro_indicator_id` FOREIGN KEY (`macro_indicator_id`) REFERENCES `asset_management`.`research`.`macro_indicator`(`macro_indicator_id`);
ALTER TABLE `asset_management`.`naturalresource`.`commodity_exposure` ADD CONSTRAINT `fk_naturalresource_commodity_exposure_market_consensus_id` FOREIGN KEY (`market_consensus_id`) REFERENCES `asset_management`.`research`.`market_consensus`(`market_consensus_id`);
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ADD CONSTRAINT `fk_naturalresource_commodity_price_deck_market_data_feed_id` FOREIGN KEY (`market_data_feed_id`) REFERENCES `asset_management`.`research`.`market_data_feed`(`market_data_feed_id`);
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ADD CONSTRAINT `fk_naturalresource_resource_asset_country_outlook_id` FOREIGN KEY (`country_outlook_id`) REFERENCES `asset_management`.`research`.`country_outlook`(`country_outlook_id`);
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ADD CONSTRAINT `fk_naturalresource_resource_valuation_country_outlook_id` FOREIGN KEY (`country_outlook_id`) REFERENCES `asset_management`.`research`.`country_outlook`(`country_outlook_id`);
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ADD CONSTRAINT `fk_naturalresource_resource_valuation_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ADD CONSTRAINT `fk_naturalresource_resource_valuation_research_fx_rate_id` FOREIGN KEY (`research_fx_rate_id`) REFERENCES `asset_management`.`research`.`research_fx_rate`(`research_fx_rate_id`);
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ADD CONSTRAINT `fk_naturalresource_resource_valuation_research_report_id` FOREIGN KEY (`research_report_id`) REFERENCES `asset_management`.`research`.`research_report`(`research_report_id`);
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ADD CONSTRAINT `fk_naturalresource_resource_valuation_research_yield_curve_id` FOREIGN KEY (`research_yield_curve_id`) REFERENCES `asset_management`.`research`.`research_yield_curve`(`research_yield_curve_id`);
ALTER TABLE `asset_management`.`naturalresource`.`resource_valuation` ADD CONSTRAINT `fk_naturalresource_resource_valuation_sector_outlook_id` FOREIGN KEY (`sector_outlook_id`) REFERENCES `asset_management`.`research`.`sector_outlook`(`sector_outlook_id`);

-- ========= naturalresource --> shared (16 constraint(s)) =========
-- Requires: naturalresource schema, shared schema
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ADD CONSTRAINT `fk_naturalresource_commodity_price_deck_created_by_user_employee_id` FOREIGN KEY (`created_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ADD CONSTRAINT `fk_naturalresource_commodity_price_deck_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`naturalresource`.`commodity_price_deck` ADD CONSTRAINT `fk_naturalresource_commodity_price_deck_last_modified_by_user_employee_id` FOREIGN KEY (`last_modified_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ADD CONSTRAINT `fk_naturalresource_harvest_plan_asset_manager_employee_id` FOREIGN KEY (`asset_manager_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ADD CONSTRAINT `fk_naturalresource_harvest_plan_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`naturalresource`.`harvest_plan` ADD CONSTRAINT `fk_naturalresource_harvest_plan_legal_entity_id` FOREIGN KEY (`legal_entity_id`) REFERENCES `asset_management`.`shared`.`legal_entity`(`legal_entity_id`);
ALTER TABLE `asset_management`.`naturalresource`.`land_parcel` ADD CONSTRAINT `fk_naturalresource_land_parcel_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`naturalresource`.`offtake_agreement` ADD CONSTRAINT `fk_naturalresource_offtake_agreement_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`naturalresource`.`resource_asset` ADD CONSTRAINT `fk_naturalresource_resource_asset_operator_actor_id` FOREIGN KEY (`operator_actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ADD CONSTRAINT `fk_naturalresource_resource_budget_asset_manager_employee_id` FOREIGN KEY (`asset_manager_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ADD CONSTRAINT `fk_naturalresource_resource_budget_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`naturalresource`.`resource_budget` ADD CONSTRAINT `fk_naturalresource_resource_budget_prepared_by_user_employee_id` FOREIGN KEY (`prepared_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ADD CONSTRAINT `fk_naturalresource_resource_cashflow_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ADD CONSTRAINT `fk_naturalresource_resource_holding_general_partner_actor_id` FOREIGN KEY (`general_partner_actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ADD CONSTRAINT `fk_naturalresource_royalty_payment_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ADD CONSTRAINT `fk_naturalresource_royalty_payment_record_updated_by_user_employee_id` FOREIGN KEY (`record_updated_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);

-- ========= naturalresource --> treasury (3 constraint(s)) =========
-- Requires: naturalresource schema, treasury schema
ALTER TABLE `asset_management`.`naturalresource`.`resource_cashflow` ADD CONSTRAINT `fk_naturalresource_resource_cashflow_cash_account_id` FOREIGN KEY (`cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);
ALTER TABLE `asset_management`.`naturalresource`.`resource_holding` ADD CONSTRAINT `fk_naturalresource_resource_holding_cash_account_id` FOREIGN KEY (`cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);
ALTER TABLE `asset_management`.`naturalresource`.`royalty_payment` ADD CONSTRAINT `fk_naturalresource_royalty_payment_cash_account_id` FOREIGN KEY (`cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);

-- ========= performance --> actuarial (4 constraint(s)) =========
-- Requires: performance schema, actuarial schema
ALTER TABLE `asset_management`.`performance`.`ldi_return` ADD CONSTRAINT `fk_performance_ldi_return_assumption_set_id` FOREIGN KEY (`assumption_set_id`) REFERENCES `asset_management`.`actuarial`.`assumption_set`(`assumption_set_id`);
ALTER TABLE `asset_management`.`performance`.`ldi_return` ADD CONSTRAINT `fk_performance_ldi_return_liability_projection_id` FOREIGN KEY (`liability_projection_id`) REFERENCES `asset_management`.`actuarial`.`liability_projection`(`liability_projection_id`);
ALTER TABLE `asset_management`.`performance`.`pbor_snapshot` ADD CONSTRAINT `fk_performance_pbor_snapshot_assumption_set_id` FOREIGN KEY (`assumption_set_id`) REFERENCES `asset_management`.`actuarial`.`assumption_set`(`assumption_set_id`);
ALTER TABLE `asset_management`.`performance`.`pbor_snapshot` ADD CONSTRAINT `fk_performance_pbor_snapshot_liability_projection_id` FOREIGN KEY (`liability_projection_id`) REFERENCES `asset_management`.`actuarial`.`liability_projection`(`liability_projection_id`);

-- ========= performance --> collateral (1 constraint(s)) =========
-- Requires: performance schema, collateral schema
ALTER TABLE `asset_management`.`performance`.`cash_flow_record` ADD CONSTRAINT `fk_performance_cash_flow_record_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);

-- ========= performance --> compliance (2 constraint(s)) =========
-- Requires: performance schema, compliance schema
ALTER TABLE `asset_management`.`performance`.`gips_composite_report` ADD CONSTRAINT `fk_performance_gips_composite_report_gips_compliance_record_id` FOREIGN KEY (`gips_compliance_record_id`) REFERENCES `asset_management`.`compliance`.`gips_compliance_record`(`gips_compliance_record_id`);
ALTER TABLE `asset_management`.`performance`.`notice` ADD CONSTRAINT `fk_performance_notice_rule_breach_id` FOREIGN KEY (`rule_breach_id`) REFERENCES `asset_management`.`compliance`.`rule_breach`(`rule_breach_id`);

-- ========= performance --> credit (1 constraint(s)) =========
-- Requires: performance schema, credit schema
ALTER TABLE `asset_management`.`performance`.`peer_group_return` ADD CONSTRAINT `fk_performance_peer_group_return_benchmark_index_id` FOREIGN KEY (`benchmark_index_id`) REFERENCES `asset_management`.`credit`.`benchmark_index`(`benchmark_index_id`);

-- ========= performance --> deal (1 constraint(s)) =========
-- Requires: performance schema, deal schema
ALTER TABLE `asset_management`.`performance`.`private_asset_irr` ADD CONSTRAINT `fk_performance_private_asset_irr_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);

-- ========= performance --> equity (1 constraint(s)) =========
-- Requires: performance schema, equity schema
ALTER TABLE `asset_management`.`performance`.`holding_return` ADD CONSTRAINT `fk_performance_holding_return_listed_security_id` FOREIGN KEY (`listed_security_id`) REFERENCES `asset_management`.`equity`.`listed_security`(`listed_security_id`);

-- ========= performance --> esg (2 constraint(s)) =========
-- Requires: performance schema, esg schema
ALTER TABLE `asset_management`.`performance`.`composite` ADD CONSTRAINT `fk_performance_composite_esg_benchmark_id` FOREIGN KEY (`esg_benchmark_id`) REFERENCES `asset_management`.`esg`.`esg_benchmark`(`esg_benchmark_id`);
ALTER TABLE `asset_management`.`performance`.`performance_benchmark` ADD CONSTRAINT `fk_performance_performance_benchmark_esg_benchmark_id` FOREIGN KEY (`esg_benchmark_id`) REFERENCES `asset_management`.`esg`.`esg_benchmark`(`esg_benchmark_id`);

-- ========= performance --> manager (4 constraint(s)) =========
-- Requires: performance schema, manager schema
ALTER TABLE `asset_management`.`performance`.`composite` ADD CONSTRAINT `fk_performance_composite_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`performance`.`fee_hurdle` ADD CONSTRAINT `fk_performance_fee_hurdle_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);
ALTER TABLE `asset_management`.`performance`.`notice` ADD CONSTRAINT `fk_performance_notice_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`performance`.`notice` ADD CONSTRAINT `fk_performance_notice_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);

-- ========= performance --> portfolio (19 constraint(s)) =========
-- Requires: performance schema, portfolio schema
ALTER TABLE `asset_management`.`performance`.`active_return_attribution` ADD CONSTRAINT `fk_performance_active_return_attribution_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`performance`.`attribution_result` ADD CONSTRAINT `fk_performance_attribution_result_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`performance`.`attribution_segment` ADD CONSTRAINT `fk_performance_attribution_segment_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`performance`.`cash_flow_record` ADD CONSTRAINT `fk_performance_cash_flow_record_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`performance`.`cash_flow_record` ADD CONSTRAINT `fk_performance_cash_flow_record_tax_lot_id` FOREIGN KEY (`tax_lot_id`) REFERENCES `asset_management`.`portfolio`.`tax_lot`(`tax_lot_id`);
ALTER TABLE `asset_management`.`performance`.`currency_attribution` ADD CONSTRAINT `fk_performance_currency_attribution_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`performance`.`excess_return` ADD CONSTRAINT `fk_performance_excess_return_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`performance`.`fee_hurdle` ADD CONSTRAINT `fk_performance_fee_hurdle_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`performance`.`holding_return` ADD CONSTRAINT `fk_performance_holding_return_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`performance`.`ldi_return` ADD CONSTRAINT `fk_performance_ldi_return_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`performance`.`notice` ADD CONSTRAINT `fk_performance_notice_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`performance`.`pbor_snapshot` ADD CONSTRAINT `fk_performance_pbor_snapshot_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`performance`.`peer_group_return` ADD CONSTRAINT `fk_performance_peer_group_return_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`performance`.`performance_composite_membership` ADD CONSTRAINT `fk_performance_performance_composite_membership_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`performance`.`performance_exception` ADD CONSTRAINT `fk_performance_performance_exception_event_portfolio_id` FOREIGN KEY (`event_portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`performance`.`performance_factor_exposure` ADD CONSTRAINT `fk_performance_performance_factor_exposure_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`performance`.`portfolio_return` ADD CONSTRAINT `fk_performance_portfolio_return_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`performance`.`private_asset_irr` ADD CONSTRAINT `fk_performance_private_asset_irr_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`performance`.`significant_cash_flow` ADD CONSTRAINT `fk_performance_significant_cash_flow_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);

-- ========= performance --> privateequity (3 constraint(s)) =========
-- Requires: performance schema, privateequity schema
ALTER TABLE `asset_management`.`performance`.`cash_flow_record` ADD CONSTRAINT `fk_performance_cash_flow_record_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`performance`.`cash_flow_record` ADD CONSTRAINT `fk_performance_cash_flow_record_investment_id` FOREIGN KEY (`investment_id`) REFERENCES `asset_management`.`privateequity`.`investment`(`investment_id`);
ALTER TABLE `asset_management`.`performance`.`private_asset_irr` ADD CONSTRAINT `fk_performance_private_asset_irr_investment_id` FOREIGN KEY (`investment_id`) REFERENCES `asset_management`.`privateequity`.`investment`(`investment_id`);

-- ========= performance --> research (4 constraint(s)) =========
-- Requires: performance schema, research schema
ALTER TABLE `asset_management`.`performance`.`ldi_return` ADD CONSTRAINT `fk_performance_ldi_return_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);
ALTER TABLE `asset_management`.`performance`.`portfolio_return` ADD CONSTRAINT `fk_performance_portfolio_return_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);
ALTER TABLE `asset_management`.`performance`.`private_asset_irr` ADD CONSTRAINT `fk_performance_private_asset_irr_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);
ALTER TABLE `asset_management`.`performance`.`scenario_application` ADD CONSTRAINT `fk_performance_scenario_application_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);

-- ========= performance --> risk (6 constraint(s)) =========
-- Requires: performance schema, risk schema
ALTER TABLE `asset_management`.`performance`.`active_return_attribution` ADD CONSTRAINT `fk_performance_active_return_attribution_factor_id` FOREIGN KEY (`factor_id`) REFERENCES `asset_management`.`risk`.`factor`(`factor_id`);
ALTER TABLE `asset_management`.`performance`.`ldi_return` ADD CONSTRAINT `fk_performance_ldi_return_dv01_sensitivity_id` FOREIGN KEY (`dv01_sensitivity_id`) REFERENCES `asset_management`.`risk`.`dv01_sensitivity`(`dv01_sensitivity_id`);
ALTER TABLE `asset_management`.`performance`.`notice` ADD CONSTRAINT `fk_performance_notice_limit_breach_id` FOREIGN KEY (`limit_breach_id`) REFERENCES `asset_management`.`risk`.`limit_breach`(`limit_breach_id`);
ALTER TABLE `asset_management`.`performance`.`pbor_snapshot` ADD CONSTRAINT `fk_performance_pbor_snapshot_var_calculation_id` FOREIGN KEY (`var_calculation_id`) REFERENCES `asset_management`.`risk`.`var_calculation`(`var_calculation_id`);
ALTER TABLE `asset_management`.`performance`.`performance_factor_exposure` ADD CONSTRAINT `fk_performance_performance_factor_exposure_factor_id` FOREIGN KEY (`factor_id`) REFERENCES `asset_management`.`risk`.`factor`(`factor_id`);
ALTER TABLE `asset_management`.`performance`.`performance_factor_exposure` ADD CONSTRAINT `fk_performance_performance_factor_exposure_factor_model_id` FOREIGN KEY (`factor_model_id`) REFERENCES `asset_management`.`risk`.`model`(`model_id`);

-- ========= performance --> shared (6 constraint(s)) =========
-- Requires: performance schema, shared schema
ALTER TABLE `asset_management`.`performance`.`fee_hurdle` ADD CONSTRAINT `fk_performance_fee_hurdle_legal_entity_id` FOREIGN KEY (`legal_entity_id`) REFERENCES `asset_management`.`shared`.`legal_entity`(`legal_entity_id`);
ALTER TABLE `asset_management`.`performance`.`gips_composite_report` ADD CONSTRAINT `fk_performance_gips_composite_report_approved_by_user_employee_id` FOREIGN KEY (`approved_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`performance`.`gips_composite_report` ADD CONSTRAINT `fk_performance_gips_composite_report_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`performance`.`notice` ADD CONSTRAINT `fk_performance_notice_approved_by_user_employee_id` FOREIGN KEY (`approved_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`performance`.`notice` ADD CONSTRAINT `fk_performance_notice_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`performance`.`performance_exception` ADD CONSTRAINT `fk_performance_performance_exception_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);

-- ========= performance --> trade (1 constraint(s)) =========
-- Requires: performance schema, trade schema
ALTER TABLE `asset_management`.`performance`.`holding_return` ADD CONSTRAINT `fk_performance_holding_return_instrument_id` FOREIGN KEY (`instrument_id`) REFERENCES `asset_management`.`trade`.`instrument`(`instrument_id`);

-- ========= performance --> valuation (4 constraint(s)) =========
-- Requires: performance schema, valuation schema
ALTER TABLE `asset_management`.`performance`.`ldi_return` ADD CONSTRAINT `fk_performance_ldi_return_nav_liability_id` FOREIGN KEY (`nav_liability_id`) REFERENCES `asset_management`.`valuation`.`nav_liability`(`nav_liability_id`);
ALTER TABLE `asset_management`.`performance`.`pbor_snapshot` ADD CONSTRAINT `fk_performance_pbor_snapshot_valuation_nav_record_id` FOREIGN KEY (`valuation_nav_record_id`) REFERENCES `asset_management`.`valuation`.`valuation_nav_record`(`valuation_nav_record_id`);
ALTER TABLE `asset_management`.`performance`.`performance_calculation_run` ADD CONSTRAINT `fk_performance_performance_calculation_run_valuation_cycle_id` FOREIGN KEY (`valuation_cycle_id`) REFERENCES `asset_management`.`valuation`.`cycle`(`cycle_id`);
ALTER TABLE `asset_management`.`performance`.`private_asset_irr` ADD CONSTRAINT `fk_performance_private_asset_irr_private_asset_valuation_id` FOREIGN KEY (`private_asset_valuation_id`) REFERENCES `asset_management`.`valuation`.`private_asset_valuation`(`private_asset_valuation_id`);

-- ========= portfolio --> actuarial (4 constraint(s)) =========
-- Requires: portfolio schema, actuarial schema
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ADD CONSTRAINT `fk_portfolio_portfolio_actuarial_valuation_id` FOREIGN KEY (`actuarial_valuation_id`) REFERENCES `asset_management`.`actuarial`.`actuarial_valuation`(`actuarial_valuation_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ADD CONSTRAINT `fk_portfolio_portfolio_alm_model_id` FOREIGN KEY (`alm_model_id`) REFERENCES `asset_management`.`actuarial`.`alm_model`(`alm_model_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ADD CONSTRAINT `fk_portfolio_portfolio_assumption_set_id` FOREIGN KEY (`assumption_set_id`) REFERENCES `asset_management`.`actuarial`.`assumption_set`(`assumption_set_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ADD CONSTRAINT `fk_portfolio_portfolio_ldi_strategy_id` FOREIGN KEY (`ldi_strategy_id`) REFERENCES `asset_management`.`actuarial`.`ldi_strategy`(`ldi_strategy_id`);

-- ========= portfolio --> collateral (3 constraint(s)) =========
-- Requires: portfolio schema, collateral schema
ALTER TABLE `asset_management`.`portfolio`.`currency_exposure` ADD CONSTRAINT `fk_portfolio_currency_exposure_hedge_counterparty_id` FOREIGN KEY (`hedge_counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`portfolio`.`holding` ADD CONSTRAINT `fk_portfolio_holding_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ADD CONSTRAINT `fk_portfolio_portfolio_cash_flow_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);

-- ========= portfolio --> compliance (2 constraint(s)) =========
-- Requires: portfolio schema, compliance schema
ALTER TABLE `asset_management`.`portfolio`.`constraint_breach` ADD CONSTRAINT `fk_portfolio_constraint_breach_constraint_rule_id` FOREIGN KEY (`constraint_rule_id`) REFERENCES `asset_management`.`compliance`.`rule`(`rule_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ADD CONSTRAINT `fk_portfolio_portfolio_composite_membership_gips_compliance_record_id` FOREIGN KEY (`gips_compliance_record_id`) REFERENCES `asset_management`.`compliance`.`gips_compliance_record`(`gips_compliance_record_id`);

-- ========= portfolio --> credit (3 constraint(s)) =========
-- Requires: portfolio schema, credit schema
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ADD CONSTRAINT `fk_portfolio_portfolio_mandate_benchmark_index_id` FOREIGN KEY (`benchmark_index_id`) REFERENCES `asset_management`.`credit`.`benchmark_index`(`benchmark_index_id`);
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ADD CONSTRAINT `fk_portfolio_saa_target_credit_benchmark_index_id` FOREIGN KEY (`credit_benchmark_index_id`) REFERENCES `asset_management`.`credit`.`benchmark_index`(`benchmark_index_id`);
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ADD CONSTRAINT `fk_portfolio_sleeve_credit_mandate_id` FOREIGN KEY (`credit_mandate_id`) REFERENCES `asset_management`.`credit`.`credit_mandate`(`credit_mandate_id`);

-- ========= portfolio --> deal (4 constraint(s)) =========
-- Requires: portfolio schema, deal schema
ALTER TABLE `asset_management`.`portfolio`.`portfolio_allocation` ADD CONSTRAINT `fk_portfolio_portfolio_allocation_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ADD CONSTRAINT `fk_portfolio_portfolio_capital_commitment_deal_capital_commitment_id` FOREIGN KEY (`deal_capital_commitment_id`) REFERENCES `asset_management`.`deal`.`deal_capital_commitment`(`deal_capital_commitment_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ADD CONSTRAINT `fk_portfolio_portfolio_capital_commitment_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ADD CONSTRAINT `fk_portfolio_portfolio_cash_flow_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);

-- ========= portfolio --> diligence (2 constraint(s)) =========
-- Requires: portfolio schema, diligence schema
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ADD CONSTRAINT `fk_portfolio_portfolio_capital_commitment_dd_engagement_id` FOREIGN KEY (`dd_engagement_id`) REFERENCES `asset_management`.`diligence`.`dd_engagement`(`dd_engagement_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ADD CONSTRAINT `fk_portfolio_portfolio_ic_approval_diligence_ic_submission_id` FOREIGN KEY (`diligence_ic_submission_id`) REFERENCES `asset_management`.`diligence`.`diligence_ic_submission`(`diligence_ic_submission_id`);

-- ========= portfolio --> equity (6 constraint(s)) =========
-- Requires: portfolio schema, equity schema
ALTER TABLE `asset_management`.`portfolio`.`asset` ADD CONSTRAINT `fk_portfolio_asset_equity_issuer_id` FOREIGN KEY (`equity_issuer_id`) REFERENCES `asset_management`.`equity`.`equity_issuer`(`equity_issuer_id`);
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ADD CONSTRAINT `fk_portfolio_holding_snapshot_listed_security_id` FOREIGN KEY (`listed_security_id`) REFERENCES `asset_management`.`equity`.`listed_security`(`listed_security_id`);
ALTER TABLE `asset_management`.`portfolio`.`holding` ADD CONSTRAINT `fk_portfolio_holding_listed_security_id` FOREIGN KEY (`listed_security_id`) REFERENCES `asset_management`.`equity`.`listed_security`(`listed_security_id`);
ALTER TABLE `asset_management`.`portfolio`.`liquidity_bucket` ADD CONSTRAINT `fk_portfolio_liquidity_bucket_listed_security_id` FOREIGN KEY (`listed_security_id`) REFERENCES `asset_management`.`equity`.`listed_security`(`listed_security_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ADD CONSTRAINT `fk_portfolio_portfolio_equity_benchmark_id` FOREIGN KEY (`equity_benchmark_id`) REFERENCES `asset_management`.`equity`.`equity_benchmark`(`equity_benchmark_id`);
ALTER TABLE `asset_management`.`portfolio`.`tax_lot` ADD CONSTRAINT `fk_portfolio_tax_lot_listed_security_id` FOREIGN KEY (`listed_security_id`) REFERENCES `asset_management`.`equity`.`listed_security`(`listed_security_id`);

-- ========= portfolio --> esg (1 constraint(s)) =========
-- Requires: portfolio schema, esg schema
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ADD CONSTRAINT `fk_portfolio_portfolio_mandate_exclusion_list_id` FOREIGN KEY (`exclusion_list_id`) REFERENCES `asset_management`.`esg`.`exclusion_list`(`exclusion_list_id`);

-- ========= portfolio --> infrastructure (4 constraint(s)) =========
-- Requires: portfolio schema, infrastructure schema
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ADD CONSTRAINT `fk_portfolio_holding_snapshot_infra_asset_id` FOREIGN KEY (`infra_asset_id`) REFERENCES `asset_management`.`infrastructure`.`infra_asset`(`infra_asset_id`);
ALTER TABLE `asset_management`.`portfolio`.`holding` ADD CONSTRAINT `fk_portfolio_holding_infra_asset_id` FOREIGN KEY (`infra_asset_id`) REFERENCES `asset_management`.`infrastructure`.`infra_asset`(`infra_asset_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ADD CONSTRAINT `fk_portfolio_portfolio_capital_commitment_infra_fund_commitment_id` FOREIGN KEY (`infra_fund_commitment_id`) REFERENCES `asset_management`.`infrastructure`.`infra_fund_commitment`(`infra_fund_commitment_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ADD CONSTRAINT `fk_portfolio_portfolio_cash_flow_infra_asset_id` FOREIGN KEY (`infra_asset_id`) REFERENCES `asset_management`.`infrastructure`.`infra_asset`(`infra_asset_id`);

-- ========= portfolio --> manager (4 constraint(s)) =========
-- Requires: portfolio schema, manager schema
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ADD CONSTRAINT `fk_portfolio_portfolio_ic_approval_ic_meeting_id` FOREIGN KEY (`ic_meeting_id`) REFERENCES `asset_management`.`manager`.`meeting`(`meeting_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ADD CONSTRAINT `fk_portfolio_portfolio_mandate_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ADD CONSTRAINT `fk_portfolio_portfolio_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ADD CONSTRAINT `fk_portfolio_sleeve_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);

-- ========= portfolio --> performance (5 constraint(s)) =========
-- Requires: portfolio schema, performance schema
ALTER TABLE `asset_management`.`portfolio`.`asset` ADD CONSTRAINT `fk_portfolio_asset_performance_benchmark_id` FOREIGN KEY (`performance_benchmark_id`) REFERENCES `asset_management`.`performance`.`performance_benchmark`(`performance_benchmark_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ADD CONSTRAINT `fk_portfolio_portfolio_composite_membership_composite_id` FOREIGN KEY (`composite_id`) REFERENCES `asset_management`.`performance`.`composite`(`composite_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ADD CONSTRAINT `fk_portfolio_portfolio_mandate_performance_benchmark_id` FOREIGN KEY (`performance_benchmark_id`) REFERENCES `asset_management`.`performance`.`performance_benchmark`(`performance_benchmark_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ADD CONSTRAINT `fk_portfolio_portfolio_composite_id` FOREIGN KEY (`composite_id`) REFERENCES `asset_management`.`performance`.`composite`(`composite_id`);
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ADD CONSTRAINT `fk_portfolio_sleeve_composite_id` FOREIGN KEY (`composite_id`) REFERENCES `asset_management`.`performance`.`composite`(`composite_id`);

-- ========= portfolio --> privateequity (9 constraint(s)) =========
-- Requires: portfolio schema, privateequity schema
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ADD CONSTRAINT `fk_portfolio_portfolio_capital_commitment_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ADD CONSTRAINT `fk_portfolio_portfolio_cash_flow_distribution_id` FOREIGN KEY (`distribution_id`) REFERENCES `asset_management`.`privateequity`.`distribution`(`distribution_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ADD CONSTRAINT `fk_portfolio_portfolio_cash_flow_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ADD CONSTRAINT `fk_portfolio_portfolio_cash_flow_investment_id` FOREIGN KEY (`investment_id`) REFERENCES `asset_management`.`privateequity`.`investment`(`investment_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ADD CONSTRAINT `fk_portfolio_portfolio_cash_flow_privateequity_capital_call_id` FOREIGN KEY (`privateequity_capital_call_id`) REFERENCES `asset_management`.`privateequity`.`privateequity_capital_call`(`privateequity_capital_call_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ADD CONSTRAINT `fk_portfolio_portfolio_ic_approval_coinvestment_id` FOREIGN KEY (`coinvestment_id`) REFERENCES `asset_management`.`privateequity`.`coinvestment`(`coinvestment_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ADD CONSTRAINT `fk_portfolio_portfolio_ic_approval_pe_fund_id` FOREIGN KEY (`pe_fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_ic_approval` ADD CONSTRAINT `fk_portfolio_portfolio_ic_approval_pe_investment_id` FOREIGN KEY (`pe_investment_id`) REFERENCES `asset_management`.`privateequity`.`investment`(`investment_id`);
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ADD CONSTRAINT `fk_portfolio_sleeve_pe_fund_id` FOREIGN KEY (`pe_fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);

-- ========= portfolio --> realestate (3 constraint(s)) =========
-- Requires: portfolio schema, realestate schema
ALTER TABLE `asset_management`.`portfolio`.`holding` ADD CONSTRAINT `fk_portfolio_holding_property_id` FOREIGN KEY (`property_id`) REFERENCES `asset_management`.`realestate`.`property`(`property_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_capital_commitment` ADD CONSTRAINT `fk_portfolio_portfolio_capital_commitment_re_fund_commitment_id` FOREIGN KEY (`re_fund_commitment_id`) REFERENCES `asset_management`.`realestate`.`re_fund_commitment`(`re_fund_commitment_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ADD CONSTRAINT `fk_portfolio_portfolio_cash_flow_property_id` FOREIGN KEY (`property_id`) REFERENCES `asset_management`.`realestate`.`property`(`property_id`);

-- ========= portfolio --> research (6 constraint(s)) =========
-- Requires: portfolio schema, research schema
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ADD CONSTRAINT `fk_portfolio_portfolio_asset_class_outlook_id` FOREIGN KEY (`asset_class_outlook_id`) REFERENCES `asset_management`.`research`.`asset_class_outlook`(`asset_class_outlook_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ADD CONSTRAINT `fk_portfolio_portfolio_capital_market_assumption_id` FOREIGN KEY (`capital_market_assumption_id`) REFERENCES `asset_management`.`research`.`capital_market_assumption`(`capital_market_assumption_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ADD CONSTRAINT `fk_portfolio_portfolio_country_outlook_id` FOREIGN KEY (`country_outlook_id`) REFERENCES `asset_management`.`research`.`country_outlook`(`country_outlook_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ADD CONSTRAINT `fk_portfolio_portfolio_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ADD CONSTRAINT `fk_portfolio_portfolio_macro_model_run_id` FOREIGN KEY (`macro_model_run_id`) REFERENCES `asset_management`.`research`.`macro_model_run`(`macro_model_run_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ADD CONSTRAINT `fk_portfolio_portfolio_sector_outlook_id` FOREIGN KEY (`sector_outlook_id`) REFERENCES `asset_management`.`research`.`sector_outlook`(`sector_outlook_id`);

-- ========= portfolio --> shared (15 constraint(s)) =========
-- Requires: portfolio schema, shared schema
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ADD CONSTRAINT `fk_portfolio_portfolio_composite_membership_approved_by_user_employee_id` FOREIGN KEY (`approved_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_composite_membership` ADD CONSTRAINT `fk_portfolio_portfolio_composite_membership_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ADD CONSTRAINT `fk_portfolio_portfolio_mandate_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ADD CONSTRAINT `fk_portfolio_portfolio_mandate_legal_entity_id` FOREIGN KEY (`legal_entity_id`) REFERENCES `asset_management`.`shared`.`legal_entity`(`legal_entity_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ADD CONSTRAINT `fk_portfolio_portfolio_created_by_actor_id` FOREIGN KEY (`created_by_actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ADD CONSTRAINT `fk_portfolio_portfolio_created_by_user_employee_id` FOREIGN KEY (`created_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ADD CONSTRAINT `fk_portfolio_portfolio_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ADD CONSTRAINT `fk_portfolio_portfolio_legal_entity_id` FOREIGN KEY (`legal_entity_id`) REFERENCES `asset_management`.`shared`.`legal_entity`(`legal_entity_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ADD CONSTRAINT `fk_portfolio_portfolio_manager_employee_id` FOREIGN KEY (`manager_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ADD CONSTRAINT `fk_portfolio_portfolio_modified_by_user_employee_id` FOREIGN KEY (`modified_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ADD CONSTRAINT `fk_portfolio_saa_target_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ADD CONSTRAINT `fk_portfolio_saa_target_last_modified_by_user_employee_id` FOREIGN KEY (`last_modified_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ADD CONSTRAINT `fk_portfolio_saa_target_saa_employee_id` FOREIGN KEY (`saa_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`portfolio`.`saa_target` ADD CONSTRAINT `fk_portfolio_saa_target_saa_last_modified_by_user_employee_id` FOREIGN KEY (`saa_last_modified_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`portfolio`.`sleeve` ADD CONSTRAINT `fk_portfolio_sleeve_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);

-- ========= portfolio --> trade (7 constraint(s)) =========
-- Requires: portfolio schema, trade schema
ALTER TABLE `asset_management`.`portfolio`.`asset` ADD CONSTRAINT `fk_portfolio_asset_custodian_id` FOREIGN KEY (`custodian_id`) REFERENCES `asset_management`.`trade`.`custodian`(`custodian_id`);
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ADD CONSTRAINT `fk_portfolio_holding_snapshot_custodian_id` FOREIGN KEY (`custodian_id`) REFERENCES `asset_management`.`trade`.`custodian`(`custodian_id`);
ALTER TABLE `asset_management`.`portfolio`.`holding` ADD CONSTRAINT `fk_portfolio_holding_custodian_id` FOREIGN KEY (`custodian_id`) REFERENCES `asset_management`.`trade`.`custodian`(`custodian_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_mandate` ADD CONSTRAINT `fk_portfolio_portfolio_mandate_custodian_id` FOREIGN KEY (`custodian_id`) REFERENCES `asset_management`.`trade`.`custodian`(`custodian_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ADD CONSTRAINT `fk_portfolio_portfolio_custodian_id` FOREIGN KEY (`custodian_id`) REFERENCES `asset_management`.`trade`.`custodian`(`custodian_id`);
ALTER TABLE `asset_management`.`portfolio`.`tax_lot` ADD CONSTRAINT `fk_portfolio_tax_lot_custodian_id` FOREIGN KEY (`custodian_id`) REFERENCES `asset_management`.`trade`.`custodian`(`custodian_id`);
ALTER TABLE `asset_management`.`portfolio`.`tax_lot` ADD CONSTRAINT `fk_portfolio_tax_lot_execution_id` FOREIGN KEY (`execution_id`) REFERENCES `asset_management`.`trade`.`execution`(`execution_id`);

-- ========= portfolio --> treasury (2 constraint(s)) =========
-- Requires: portfolio schema, treasury schema
ALTER TABLE `asset_management`.`portfolio`.`portfolio_cash_flow` ADD CONSTRAINT `fk_portfolio_portfolio_cash_flow_cash_account_id` FOREIGN KEY (`cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);
ALTER TABLE `asset_management`.`portfolio`.`tax_lot` ADD CONSTRAINT `fk_portfolio_tax_lot_cash_account_id` FOREIGN KEY (`cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);

-- ========= portfolio --> valuation (4 constraint(s)) =========
-- Requires: portfolio schema, valuation schema
ALTER TABLE `asset_management`.`portfolio`.`holding_snapshot` ADD CONSTRAINT `fk_portfolio_holding_snapshot_market_price_snapshot_id` FOREIGN KEY (`market_price_snapshot_id`) REFERENCES `asset_management`.`valuation`.`market_price_snapshot`(`market_price_snapshot_id`);
ALTER TABLE `asset_management`.`portfolio`.`holding` ADD CONSTRAINT `fk_portfolio_holding_fair_value_hierarchy_id` FOREIGN KEY (`fair_value_hierarchy_id`) REFERENCES `asset_management`.`valuation`.`fair_value_hierarchy`(`fair_value_hierarchy_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio_nav_record` ADD CONSTRAINT `fk_portfolio_portfolio_nav_record_valuation_nav_record_id` FOREIGN KEY (`valuation_nav_record_id`) REFERENCES `asset_management`.`valuation`.`valuation_nav_record`(`valuation_nav_record_id`);
ALTER TABLE `asset_management`.`portfolio`.`portfolio` ADD CONSTRAINT `fk_portfolio_portfolio_valuation_policy_id` FOREIGN KEY (`valuation_policy_id`) REFERENCES `asset_management`.`valuation`.`valuation_policy`(`valuation_policy_id`);

-- ========= privateequity --> collateral (1 constraint(s)) =========
-- Requires: privateequity schema, collateral schema
ALTER TABLE `asset_management`.`privateequity`.`secondary_transaction` ADD CONSTRAINT `fk_privateequity_secondary_transaction_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);

-- ========= privateequity --> deal (8 constraint(s)) =========
-- Requires: privateequity schema, deal schema
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ADD CONSTRAINT `fk_privateequity_coinvestment_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`privateequity`.`coinvestment` ADD CONSTRAINT `fk_privateequity_coinvestment_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`privateequity`.`investment` ADD CONSTRAINT `fk_privateequity_investment_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`privateequity`.`investment` ADD CONSTRAINT `fk_privateequity_investment_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ADD CONSTRAINT `fk_privateequity_privateequity_capital_call_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ADD CONSTRAINT `fk_privateequity_privateequity_capital_call_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ADD CONSTRAINT `fk_privateequity_privateequity_cash_flow_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`privateequity`.`privateequity_cash_flow` ADD CONSTRAINT `fk_privateequity_privateequity_cash_flow_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);

-- ========= privateequity --> equity (1 constraint(s)) =========
-- Requires: privateequity schema, equity schema
ALTER TABLE `asset_management`.`privateequity`.`privateequity_benchmark` ADD CONSTRAINT `fk_privateequity_privateequity_benchmark_equity_benchmark_id` FOREIGN KEY (`equity_benchmark_id`) REFERENCES `asset_management`.`equity`.`equity_benchmark`(`equity_benchmark_id`);

-- ========= privateequity --> esg (9 constraint(s)) =========
-- Requires: privateequity schema, esg schema
ALTER TABLE `asset_management`.`privateequity`.`fund` ADD CONSTRAINT `fk_privateequity_fund_climate_scenario_id` FOREIGN KEY (`climate_scenario_id`) REFERENCES `asset_management`.`esg`.`climate_scenario`(`climate_scenario_id`);
ALTER TABLE `asset_management`.`privateequity`.`fund` ADD CONSTRAINT `fk_privateequity_fund_controversy_id` FOREIGN KEY (`controversy_id`) REFERENCES `asset_management`.`esg`.`controversy`(`controversy_id`);
ALTER TABLE `asset_management`.`privateequity`.`fund` ADD CONSTRAINT `fk_privateequity_fund_engagement_activity_id` FOREIGN KEY (`engagement_activity_id`) REFERENCES `asset_management`.`esg`.`engagement_activity`(`engagement_activity_id`);
ALTER TABLE `asset_management`.`privateequity`.`fund` ADD CONSTRAINT `fk_privateequity_fund_engagement_objective_id` FOREIGN KEY (`engagement_objective_id`) REFERENCES `asset_management`.`esg`.`engagement_objective`(`engagement_objective_id`);
ALTER TABLE `asset_management`.`privateequity`.`fund` ADD CONSTRAINT `fk_privateequity_fund_esg_benchmark_id` FOREIGN KEY (`esg_benchmark_id`) REFERENCES `asset_management`.`esg`.`esg_benchmark`(`esg_benchmark_id`);
ALTER TABLE `asset_management`.`privateequity`.`fund` ADD CONSTRAINT `fk_privateequity_fund_esg_policy_id` FOREIGN KEY (`esg_policy_id`) REFERENCES `asset_management`.`esg`.`esg_policy`(`esg_policy_id`);
ALTER TABLE `asset_management`.`privateequity`.`fund` ADD CONSTRAINT `fk_privateequity_fund_exclusion_list_id` FOREIGN KEY (`exclusion_list_id`) REFERENCES `asset_management`.`esg`.`exclusion_list`(`exclusion_list_id`);
ALTER TABLE `asset_management`.`privateequity`.`fund` ADD CONSTRAINT `fk_privateequity_fund_tcfd_disclosure_id` FOREIGN KEY (`tcfd_disclosure_id`) REFERENCES `asset_management`.`esg`.`tcfd_disclosure`(`tcfd_disclosure_id`);
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ADD CONSTRAINT `fk_privateequity_portfolio_company_issuer_esg_rating_id` FOREIGN KEY (`issuer_esg_rating_id`) REFERENCES `asset_management`.`esg`.`issuer_esg_rating`(`issuer_esg_rating_id`);

-- ========= privateequity --> manager (2 constraint(s)) =========
-- Requires: privateequity schema, manager schema
ALTER TABLE `asset_management`.`privateequity`.`fund_of_funds_allocation` ADD CONSTRAINT `fk_privateequity_fund_of_funds_allocation_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`privateequity`.`gp_entity` ADD CONSTRAINT `fk_privateequity_gp_entity_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);

-- ========= privateequity --> research (5 constraint(s)) =========
-- Requires: privateequity schema, research schema
ALTER TABLE `asset_management`.`privateequity`.`fund` ADD CONSTRAINT `fk_privateequity_fund_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);
ALTER TABLE `asset_management`.`privateequity`.`fund` ADD CONSTRAINT `fk_privateequity_fund_macro_model_run_id` FOREIGN KEY (`macro_model_run_id`) REFERENCES `asset_management`.`research`.`macro_model_run`(`macro_model_run_id`);
ALTER TABLE `asset_management`.`privateequity`.`investment` ADD CONSTRAINT `fk_privateequity_investment_research_report_id` FOREIGN KEY (`research_report_id`) REFERENCES `asset_management`.`research`.`research_report`(`research_report_id`);
ALTER TABLE `asset_management`.`privateequity`.`portfolio_company` ADD CONSTRAINT `fk_privateequity_portfolio_company_country_outlook_id` FOREIGN KEY (`country_outlook_id`) REFERENCES `asset_management`.`research`.`country_outlook`(`country_outlook_id`);
ALTER TABLE `asset_management`.`privateequity`.`privateequity_coverage` ADD CONSTRAINT `fk_privateequity_privateequity_coverage_research_report_id` FOREIGN KEY (`research_report_id`) REFERENCES `asset_management`.`research`.`research_report`(`research_report_id`);

-- ========= privateequity --> risk (3 constraint(s)) =========
-- Requires: privateequity schema, risk schema
ALTER TABLE `asset_management`.`privateequity`.`fund` ADD CONSTRAINT `fk_privateequity_fund_risk_model_id` FOREIGN KEY (`risk_model_id`) REFERENCES `asset_management`.`risk`.`model`(`model_id`);
ALTER TABLE `asset_management`.`privateequity`.`fund` ADD CONSTRAINT `fk_privateequity_fund_stress_scenario_id` FOREIGN KEY (`stress_scenario_id`) REFERENCES `asset_management`.`risk`.`stress_scenario`(`stress_scenario_id`);
ALTER TABLE `asset_management`.`privateequity`.`investment` ADD CONSTRAINT `fk_privateequity_investment_risk_model_id` FOREIGN KEY (`risk_model_id`) REFERENCES `asset_management`.`risk`.`model`(`model_id`);

-- ========= privateequity --> shared (12 constraint(s)) =========
-- Requires: privateequity schema, shared schema
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ADD CONSTRAINT `fk_privateequity_capital_account_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`privateequity`.`capital_account` ADD CONSTRAINT `fk_privateequity_capital_account_fund_administrator_id` FOREIGN KEY (`fund_administrator_id`) REFERENCES `asset_management`.`shared`.`fund_administrator`(`fund_administrator_id`);
ALTER TABLE `asset_management`.`privateequity`.`distribution` ADD CONSTRAINT `fk_privateequity_distribution_approved_by_user_employee_id` FOREIGN KEY (`approved_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`privateequity`.`distribution` ADD CONSTRAINT `fk_privateequity_distribution_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`privateequity`.`fund` ADD CONSTRAINT `fk_privateequity_fund_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`privateequity`.`fund` ADD CONSTRAINT `fk_privateequity_fund_auditor_id` FOREIGN KEY (`auditor_id`) REFERENCES `asset_management`.`shared`.`auditor`(`auditor_id`);
ALTER TABLE `asset_management`.`privateequity`.`fund` ADD CONSTRAINT `fk_privateequity_fund_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`privateequity`.`fund` ADD CONSTRAINT `fk_privateequity_fund_fund_administrator_id` FOREIGN KEY (`fund_administrator_id`) REFERENCES `asset_management`.`shared`.`fund_administrator`(`fund_administrator_id`);
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ADD CONSTRAINT `fk_privateequity_jcurve_projection_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ADD CONSTRAINT `fk_privateequity_jcurve_projection_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ADD CONSTRAINT `fk_privateequity_jcurve_projection_jcurve_approved_by_employee_id` FOREIGN KEY (`jcurve_approved_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`privateequity`.`jcurve_projection` ADD CONSTRAINT `fk_privateequity_jcurve_projection_jcurve_employee_id` FOREIGN KEY (`jcurve_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);

-- ========= privateequity --> trade (1 constraint(s)) =========
-- Requires: privateequity schema, trade schema
ALTER TABLE `asset_management`.`privateequity`.`privateequity_capital_call` ADD CONSTRAINT `fk_privateequity_privateequity_capital_call_settlement_instruction_id` FOREIGN KEY (`settlement_instruction_id`) REFERENCES `asset_management`.`trade`.`settlement_instruction`(`settlement_instruction_id`);

-- ========= realestate --> beneficiary (1 constraint(s)) =========
-- Requires: realestate schema, beneficiary schema
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ADD CONSTRAINT `fk_realestate_property_acquisition_contributor_pool_id` FOREIGN KEY (`contributor_pool_id`) REFERENCES `asset_management`.`beneficiary`.`contributor_pool`(`contributor_pool_id`);

-- ========= realestate --> collateral (1 constraint(s)) =========
-- Requires: realestate schema, collateral schema
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ADD CONSTRAINT `fk_realestate_realestate_debt_facility_lender_counterparty_id` FOREIGN KEY (`lender_counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);

-- ========= realestate --> credit (1 constraint(s)) =========
-- Requires: realestate schema, credit schema
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ADD CONSTRAINT `fk_realestate_realestate_debt_facility_credit_issuer_id` FOREIGN KEY (`credit_issuer_id`) REFERENCES `asset_management`.`credit`.`credit_issuer`(`credit_issuer_id`);

-- ========= realestate --> deal (2 constraint(s)) =========
-- Requires: realestate schema, deal schema
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ADD CONSTRAINT `fk_realestate_property_acquisition_deal_opportunity_id` FOREIGN KEY (`deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ADD CONSTRAINT `fk_realestate_property_acquisition_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);

-- ========= realestate --> diligence (2 constraint(s)) =========
-- Requires: realestate schema, diligence schema
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ADD CONSTRAINT `fk_realestate_property_acquisition_dd_engagement_id` FOREIGN KEY (`dd_engagement_id`) REFERENCES `asset_management`.`diligence`.`dd_engagement`(`dd_engagement_id`);
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ADD CONSTRAINT `fk_realestate_property_disposal_dd_engagement_id` FOREIGN KEY (`dd_engagement_id`) REFERENCES `asset_management`.`diligence`.`dd_engagement`(`dd_engagement_id`);

-- ========= realestate --> infrastructure (1 constraint(s)) =========
-- Requires: realestate schema, infrastructure schema
ALTER TABLE `asset_management`.`realestate`.`budget_line_item` ADD CONSTRAINT `fk_realestate_budget_line_item_project_investment_id` FOREIGN KEY (`project_investment_id`) REFERENCES `asset_management`.`infrastructure`.`project_investment`(`project_investment_id`);

-- ========= realestate --> manager (1 constraint(s)) =========
-- Requires: realestate schema, manager schema
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ADD CONSTRAINT `fk_realestate_property_acquisition_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);

-- ========= realestate --> portfolio (6 constraint(s)) =========
-- Requires: realestate schema, portfolio schema
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ADD CONSTRAINT `fk_realestate_property_acquisition_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`realestate`.`property_allocation` ADD CONSTRAINT `fk_realestate_property_allocation_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ADD CONSTRAINT `fk_realestate_property_disposal_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ADD CONSTRAINT `fk_realestate_re_capital_call_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ADD CONSTRAINT `fk_realestate_re_distribution_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`realestate`.`reit_position` ADD CONSTRAINT `fk_realestate_reit_position_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);

-- ========= realestate --> privateequity (4 constraint(s)) =========
-- Requires: realestate schema, privateequity schema
ALTER TABLE `asset_management`.`realestate`.`budget_line_item` ADD CONSTRAINT `fk_realestate_budget_line_item_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ADD CONSTRAINT `fk_realestate_re_distribution_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ADD CONSTRAINT `fk_realestate_re_distribution_re_fund_investment_id` FOREIGN KEY (`re_fund_investment_id`) REFERENCES `asset_management`.`privateequity`.`investment`(`investment_id`);
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ADD CONSTRAINT `fk_realestate_re_fund_commitment_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);

-- ========= realestate --> shared (25 constraint(s)) =========
-- Requires: realestate schema, shared schema
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ADD CONSTRAINT `fk_realestate_asset_business_plan_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ADD CONSTRAINT `fk_realestate_asset_business_plan_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`realestate`.`budget_line_item` ADD CONSTRAINT `fk_realestate_budget_line_item_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`realestate`.`budget_line_item` ADD CONSTRAINT `fk_realestate_budget_line_item_vendor_id` FOREIGN KEY (`vendor_id`) REFERENCES `asset_management`.`shared`.`vendor`(`vendor_id`);
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ADD CONSTRAINT `fk_realestate_capex_expenditure_approver_employee_id` FOREIGN KEY (`approver_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ADD CONSTRAINT `fk_realestate_capex_expenditure_contract_id` FOREIGN KEY (`contract_id`) REFERENCES `asset_management`.`shared`.`contract`(`contract_id`);
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ADD CONSTRAINT `fk_realestate_capex_expenditure_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ADD CONSTRAINT `fk_realestate_capex_expenditure_vendor_id` FOREIGN KEY (`vendor_id`) REFERENCES `asset_management`.`shared`.`vendor`(`vendor_id`);
ALTER TABLE `asset_management`.`realestate`.`lease` ADD CONSTRAINT `fk_realestate_lease_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`realestate`.`lease` ADD CONSTRAINT `fk_realestate_lease_lease_employee_id` FOREIGN KEY (`lease_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`realestate`.`lease` ADD CONSTRAINT `fk_realestate_lease_lease_property_manager_employee_id` FOREIGN KEY (`lease_property_manager_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`realestate`.`lease` ADD CONSTRAINT `fk_realestate_lease_property_manager_actor_id` FOREIGN KEY (`property_manager_actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ADD CONSTRAINT `fk_realestate_property_acquisition_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ADD CONSTRAINT `fk_realestate_property_acquisition_seller_actor_id` FOREIGN KEY (`seller_actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ADD CONSTRAINT `fk_realestate_property_disposal_buyer_actor_id` FOREIGN KEY (`buyer_actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ADD CONSTRAINT `fk_realestate_property_operating_expense_vendor_id` FOREIGN KEY (`vendor_id`) REFERENCES `asset_management`.`shared`.`vendor`(`vendor_id`);
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ADD CONSTRAINT `fk_realestate_realestate_capex_program_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ADD CONSTRAINT `fk_realestate_realestate_capex_program_contractor_id` FOREIGN KEY (`contractor_id`) REFERENCES `asset_management`.`shared`.`contractor`(`contractor_id`);
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ADD CONSTRAINT `fk_realestate_realestate_capex_program_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ADD CONSTRAINT `fk_realestate_realestate_debt_facility_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ADD CONSTRAINT `fk_realestate_realestate_debt_facility_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ADD CONSTRAINT `fk_realestate_realestate_debt_facility_legal_entity_id` FOREIGN KEY (`legal_entity_id`) REFERENCES `asset_management`.`shared`.`legal_entity`(`legal_entity_id`);
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ADD CONSTRAINT `fk_realestate_realestate_debt_facility_loan_servicer_id` FOREIGN KEY (`loan_servicer_id`) REFERENCES `asset_management`.`shared`.`loan_servicer`(`loan_servicer_id`);
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ADD CONSTRAINT `fk_realestate_rent_collection_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ADD CONSTRAINT `fk_realestate_rent_collection_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);

-- ========= realestate --> trade (1 constraint(s)) =========
-- Requires: realestate schema, trade schema
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ADD CONSTRAINT `fk_realestate_re_fund_commitment_custodian_id` FOREIGN KEY (`custodian_id`) REFERENCES `asset_management`.`trade`.`custodian`(`custodian_id`);

-- ========= realestate --> treasury (7 constraint(s)) =========
-- Requires: realestate schema, treasury schema
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ADD CONSTRAINT `fk_realestate_capex_expenditure_cash_account_id` FOREIGN KEY (`cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ADD CONSTRAINT `fk_realestate_property_acquisition_cash_account_id` FOREIGN KEY (`cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ADD CONSTRAINT `fk_realestate_property_disposal_cash_account_id` FOREIGN KEY (`cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ADD CONSTRAINT `fk_realestate_property_operating_expense_cash_account_id` FOREIGN KEY (`cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ADD CONSTRAINT `fk_realestate_re_distribution_cash_account_id` FOREIGN KEY (`cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ADD CONSTRAINT `fk_realestate_realestate_capex_program_cash_account_id` FOREIGN KEY (`cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ADD CONSTRAINT `fk_realestate_rent_collection_cash_account_id` FOREIGN KEY (`cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);

-- ========= realestate --> valuation (2 constraint(s)) =========
-- Requires: realestate schema, valuation schema
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ADD CONSTRAINT `fk_realestate_property_valuation_cycle_id` FOREIGN KEY (`cycle_id`) REFERENCES `asset_management`.`valuation`.`cycle`(`cycle_id`);
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ADD CONSTRAINT `fk_realestate_property_valuation_valuation_asset_valuation_id` FOREIGN KEY (`valuation_asset_valuation_id`) REFERENCES `asset_management`.`valuation`.`valuation_asset_valuation`(`valuation_asset_valuation_id`);

-- ========= research --> compliance (2 constraint(s)) =========
-- Requires: research schema, compliance schema
ALTER TABLE `asset_management`.`research`.`data_vendor` ADD CONSTRAINT `fk_research_data_vendor_kyc_record_id` FOREIGN KEY (`kyc_record_id`) REFERENCES `asset_management`.`compliance`.`kyc_record`(`kyc_record_id`);
ALTER TABLE `asset_management`.`research`.`economic_scenario` ADD CONSTRAINT `fk_research_economic_scenario_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);

-- ========= research --> credit (1 constraint(s)) =========
-- Requires: research schema, credit schema
ALTER TABLE `asset_management`.`research`.`yield_curve_point` ADD CONSTRAINT `fk_research_yield_curve_point_credit_yield_curve_id` FOREIGN KEY (`credit_yield_curve_id`) REFERENCES `asset_management`.`credit`.`credit_yield_curve`(`credit_yield_curve_id`);

-- ========= research --> deal (3 constraint(s)) =========
-- Requires: research schema, deal schema
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ADD CONSTRAINT `fk_research_ic_research_pack_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`research`.`research_report` ADD CONSTRAINT `fk_research_research_report_related_deal_opportunity_id` FOREIGN KEY (`related_deal_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);
ALTER TABLE `asset_management`.`research`.`research_report` ADD CONSTRAINT `fk_research_research_report_related_opportunity_id` FOREIGN KEY (`related_opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);

-- ========= research --> equity (2 constraint(s)) =========
-- Requires: research schema, equity schema
ALTER TABLE `asset_management`.`research`.`market_consensus` ADD CONSTRAINT `fk_research_market_consensus_listed_security_id` FOREIGN KEY (`listed_security_id`) REFERENCES `asset_management`.`equity`.`listed_security`(`listed_security_id`);
ALTER TABLE `asset_management`.`research`.`market_data_snapshot` ADD CONSTRAINT `fk_research_market_data_snapshot_listed_security_id` FOREIGN KEY (`listed_security_id`) REFERENCES `asset_management`.`equity`.`listed_security`(`listed_security_id`);

-- ========= research --> esg (7 constraint(s)) =========
-- Requires: research schema, esg schema
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ADD CONSTRAINT `fk_research_asset_class_outlook_climate_scenario_id` FOREIGN KEY (`climate_scenario_id`) REFERENCES `asset_management`.`esg`.`climate_scenario`(`climate_scenario_id`);
ALTER TABLE `asset_management`.`research`.`capital_market_assumption` ADD CONSTRAINT `fk_research_capital_market_assumption_climate_scenario_id` FOREIGN KEY (`climate_scenario_id`) REFERENCES `asset_management`.`esg`.`climate_scenario`(`climate_scenario_id`);
ALTER TABLE `asset_management`.`research`.`coverage_universe` ADD CONSTRAINT `fk_research_coverage_universe_issuer_esg_rating_id` FOREIGN KEY (`issuer_esg_rating_id`) REFERENCES `asset_management`.`esg`.`issuer_esg_rating`(`issuer_esg_rating_id`);
ALTER TABLE `asset_management`.`research`.`economic_scenario` ADD CONSTRAINT `fk_research_economic_scenario_climate_scenario_id` FOREIGN KEY (`climate_scenario_id`) REFERENCES `asset_management`.`esg`.`climate_scenario`(`climate_scenario_id`);
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ADD CONSTRAINT `fk_research_ic_research_pack_due_diligence_id` FOREIGN KEY (`due_diligence_id`) REFERENCES `asset_management`.`esg`.`due_diligence`(`due_diligence_id`);
ALTER TABLE `asset_management`.`research`.`research_report` ADD CONSTRAINT `fk_research_research_report_framework_id` FOREIGN KEY (`framework_id`) REFERENCES `asset_management`.`esg`.`framework`(`framework_id`);
ALTER TABLE `asset_management`.`research`.`thematic_research` ADD CONSTRAINT `fk_research_thematic_research_framework_id` FOREIGN KEY (`framework_id`) REFERENCES `asset_management`.`esg`.`framework`(`framework_id`);

-- ========= research --> manager (4 constraint(s)) =========
-- Requires: research schema, manager schema
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ADD CONSTRAINT `fk_research_analyst_assignment_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ADD CONSTRAINT `fk_research_ic_research_pack_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ADD CONSTRAINT `fk_research_ic_research_pack_ic_meeting_id` FOREIGN KEY (`ic_meeting_id`) REFERENCES `asset_management`.`manager`.`meeting`(`meeting_id`);
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ADD CONSTRAINT `fk_research_ic_research_pack_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);

-- ========= research --> shared (21 constraint(s)) =========
-- Requires: research schema, shared schema
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ADD CONSTRAINT `fk_research_analyst_assignment_analyst_employee_id` FOREIGN KEY (`analyst_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ADD CONSTRAINT `fk_research_analyst_assignment_analyst_supervisor_employee_id` FOREIGN KEY (`analyst_supervisor_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ADD CONSTRAINT `fk_research_analyst_assignment_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`research`.`analyst_assignment` ADD CONSTRAINT `fk_research_analyst_assignment_supervisor_employee_id` FOREIGN KEY (`supervisor_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ADD CONSTRAINT `fk_research_asset_class_outlook_asset_employee_id` FOREIGN KEY (`asset_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ADD CONSTRAINT `fk_research_asset_class_outlook_asset_peer_reviewer_employee_id` FOREIGN KEY (`asset_peer_reviewer_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ADD CONSTRAINT `fk_research_asset_class_outlook_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`research`.`asset_class_outlook` ADD CONSTRAINT `fk_research_asset_class_outlook_peer_reviewer_employee_id` FOREIGN KEY (`peer_reviewer_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`research`.`calendar` ADD CONSTRAINT `fk_research_calendar_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`research`.`country_outlook` ADD CONSTRAINT `fk_research_country_outlook_analyst_employee_id` FOREIGN KEY (`analyst_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`research`.`country_outlook` ADD CONSTRAINT `fk_research_country_outlook_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`research`.`coverage_universe` ADD CONSTRAINT `fk_research_coverage_universe_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`research`.`coverage_universe` ADD CONSTRAINT `fk_research_coverage_universe_lead_analyst_employee_id` FOREIGN KEY (`lead_analyst_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`research`.`data_vendor` ADD CONSTRAINT `fk_research_data_vendor_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ADD CONSTRAINT `fk_research_ic_research_pack_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ADD CONSTRAINT `fk_research_ic_research_pack_ic_employee_id` FOREIGN KEY (`ic_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ADD CONSTRAINT `fk_research_ic_research_pack_ic_peer_reviewer_employee_id` FOREIGN KEY (`ic_peer_reviewer_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`research`.`ic_research_pack` ADD CONSTRAINT `fk_research_ic_research_pack_peer_reviewer_employee_id` FOREIGN KEY (`peer_reviewer_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`research`.`macro_model_run` ADD CONSTRAINT `fk_research_macro_model_run_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`research`.`thematic_research` ADD CONSTRAINT `fk_research_thematic_research_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`research`.`thematic_research` ADD CONSTRAINT `fk_research_thematic_research_peer_reviewer_employee_id` FOREIGN KEY (`peer_reviewer_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);

-- ========= risk --> actuarial (3 constraint(s)) =========
-- Requires: risk schema, actuarial schema
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ADD CONSTRAINT `fk_risk_dv01_sensitivity_discount_rate_curve_id` FOREIGN KEY (`discount_rate_curve_id`) REFERENCES `asset_management`.`actuarial`.`discount_rate_curve`(`discount_rate_curve_id`);
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ADD CONSTRAINT `fk_risk_liquidity_risk_assessment_liability_cash_flow_id` FOREIGN KEY (`liability_cash_flow_id`) REFERENCES `asset_management`.`actuarial`.`liability_cash_flow`(`liability_cash_flow_id`);
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ADD CONSTRAINT `fk_risk_stress_test_result_liability_projection_id` FOREIGN KEY (`liability_projection_id`) REFERENCES `asset_management`.`actuarial`.`liability_projection`(`liability_projection_id`);

-- ========= risk --> collateral (9 constraint(s)) =========
-- Requires: risk schema, collateral schema
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ADD CONSTRAINT `fk_risk_concentration_exposure_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`risk`.`credit_rating` ADD CONSTRAINT `fk_risk_credit_rating_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ADD CONSTRAINT `fk_risk_limit_assignment_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`risk`.`limit_breach` ADD CONSTRAINT `fk_risk_limit_breach_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`risk`.`limit` ADD CONSTRAINT `fk_risk_limit_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ADD CONSTRAINT `fk_risk_risk_counterparty_exposure_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ADD CONSTRAINT `fk_risk_risk_counterparty_exposure_csa_id` FOREIGN KEY (`csa_id`) REFERENCES `asset_management`.`collateral`.`csa`(`csa_id`);
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ADD CONSTRAINT `fk_risk_risk_counterparty_exposure_netting_agreement_id` FOREIGN KEY (`netting_agreement_id`) REFERENCES `asset_management`.`collateral`.`netting_agreement`(`netting_agreement_id`);
ALTER TABLE `asset_management`.`risk`.`risk_exception` ADD CONSTRAINT `fk_risk_risk_exception_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);

-- ========= risk --> compliance (6 constraint(s)) =========
-- Requires: risk schema, compliance schema
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ADD CONSTRAINT `fk_risk_appetite_statement_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);
ALTER TABLE `asset_management`.`risk`.`limit_breach` ADD CONSTRAINT `fk_risk_limit_breach_rule_id` FOREIGN KEY (`rule_id`) REFERENCES `asset_management`.`compliance`.`rule`(`rule_id`);
ALTER TABLE `asset_management`.`risk`.`limit` ADD CONSTRAINT `fk_risk_limit_rule_id` FOREIGN KEY (`rule_id`) REFERENCES `asset_management`.`compliance`.`rule`(`rule_id`);
ALTER TABLE `asset_management`.`risk`.`scenario_requirement` ADD CONSTRAINT `fk_risk_scenario_requirement_obligation_id` FOREIGN KEY (`obligation_id`) REFERENCES `asset_management`.`compliance`.`obligation`(`obligation_id`);
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ADD CONSTRAINT `fk_risk_stress_scenario_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);
ALTER TABLE `asset_management`.`risk`.`validation_run` ADD CONSTRAINT `fk_risk_validation_run_regulatory_filing_id` FOREIGN KEY (`regulatory_filing_id`) REFERENCES `asset_management`.`compliance`.`regulatory_filing`(`regulatory_filing_id`);

-- ========= risk --> credit (1 constraint(s)) =========
-- Requires: risk schema, credit schema
ALTER TABLE `asset_management`.`risk`.`credit_rating` ADD CONSTRAINT `fk_risk_credit_rating_rating_id` FOREIGN KEY (`rating_id`) REFERENCES `asset_management`.`credit`.`rating`(`rating_id`);

-- ========= risk --> equity (3 constraint(s)) =========
-- Requires: risk schema, equity schema
ALTER TABLE `asset_management`.`risk`.`attribution` ADD CONSTRAINT `fk_risk_attribution_equity_benchmark_id` FOREIGN KEY (`equity_benchmark_id`) REFERENCES `asset_management`.`equity`.`equity_benchmark`(`equity_benchmark_id`);
ALTER TABLE `asset_management`.`risk`.`factor_signal_prediction` ADD CONSTRAINT `fk_risk_factor_signal_prediction_listed_security_id` FOREIGN KEY (`listed_security_id`) REFERENCES `asset_management`.`equity`.`listed_security`(`listed_security_id`);
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ADD CONSTRAINT `fk_risk_risk_factor_exposure_listed_security_id` FOREIGN KEY (`listed_security_id`) REFERENCES `asset_management`.`equity`.`listed_security`(`listed_security_id`);

-- ========= risk --> esg (2 constraint(s)) =========
-- Requires: risk schema, esg schema
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ADD CONSTRAINT `fk_risk_appetite_statement_esg_policy_id` FOREIGN KEY (`esg_policy_id`) REFERENCES `asset_management`.`esg`.`esg_policy`(`esg_policy_id`);
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ADD CONSTRAINT `fk_risk_stress_scenario_climate_scenario_id` FOREIGN KEY (`climate_scenario_id`) REFERENCES `asset_management`.`esg`.`climate_scenario`(`climate_scenario_id`);

-- ========= risk --> manager (9 constraint(s)) =========
-- Requires: risk schema, manager schema
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ADD CONSTRAINT `fk_risk_concentration_exposure_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ADD CONSTRAINT `fk_risk_limit_assignment_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ADD CONSTRAINT `fk_risk_limit_assignment_strategy_id` FOREIGN KEY (`strategy_id`) REFERENCES `asset_management`.`manager`.`strategy`(`strategy_id`);
ALTER TABLE `asset_management`.`risk`.`limit_breach` ADD CONSTRAINT `fk_risk_limit_breach_strategy_id` FOREIGN KEY (`strategy_id`) REFERENCES `asset_management`.`manager`.`strategy`(`strategy_id`);
ALTER TABLE `asset_management`.`risk`.`limit` ADD CONSTRAINT `fk_risk_limit_strategy_id` FOREIGN KEY (`strategy_id`) REFERENCES `asset_management`.`manager`.`strategy`(`strategy_id`);
ALTER TABLE `asset_management`.`risk`.`risk_exception` ADD CONSTRAINT `fk_risk_risk_exception_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);
ALTER TABLE `asset_management`.`risk`.`risk_exception` ADD CONSTRAINT `fk_risk_risk_exception_strategy_id` FOREIGN KEY (`strategy_id`) REFERENCES `asset_management`.`manager`.`strategy`(`strategy_id`);
ALTER TABLE `asset_management`.`risk`.`risk_review` ADD CONSTRAINT `fk_risk_risk_review_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`risk`.`risk_review` ADD CONSTRAINT `fk_risk_risk_review_strategy_id` FOREIGN KEY (`strategy_id`) REFERENCES `asset_management`.`manager`.`strategy`(`strategy_id`);

-- ========= risk --> performance (3 constraint(s)) =========
-- Requires: risk schema, performance schema
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ADD CONSTRAINT `fk_risk_liquidity_risk_assessment_significant_cash_flow_id` FOREIGN KEY (`significant_cash_flow_id`) REFERENCES `asset_management`.`performance`.`significant_cash_flow`(`significant_cash_flow_id`);
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ADD CONSTRAINT `fk_risk_stress_test_result_performance_calculation_run_id` FOREIGN KEY (`performance_calculation_run_id`) REFERENCES `asset_management`.`performance`.`performance_calculation_run`(`performance_calculation_run_id`);
ALTER TABLE `asset_management`.`risk`.`validation_run` ADD CONSTRAINT `fk_risk_validation_run_performance_benchmark_id` FOREIGN KEY (`performance_benchmark_id`) REFERENCES `asset_management`.`performance`.`performance_benchmark`(`performance_benchmark_id`);

-- ========= risk --> portfolio (22 constraint(s)) =========
-- Requires: risk schema, portfolio schema
ALTER TABLE `asset_management`.`risk`.`attribution` ADD CONSTRAINT `fk_risk_attribution_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`risk`.`calculation_run` ADD CONSTRAINT `fk_risk_calculation_run_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ADD CONSTRAINT `fk_risk_concentration_exposure_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ADD CONSTRAINT `fk_risk_correlation_matrix_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ADD CONSTRAINT `fk_risk_dv01_sensitivity_holding_id` FOREIGN KEY (`holding_id`) REFERENCES `asset_management`.`portfolio`.`holding`(`holding_id`);
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ADD CONSTRAINT `fk_risk_dv01_sensitivity_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`risk`.`factor_signal_prediction` ADD CONSTRAINT `fk_risk_factor_signal_prediction_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ADD CONSTRAINT `fk_risk_fx_risk_exposure_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ADD CONSTRAINT `fk_risk_limit_assignment_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`risk`.`limit_breach` ADD CONSTRAINT `fk_risk_limit_breach_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`risk`.`limit` ADD CONSTRAINT `fk_risk_limit_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ADD CONSTRAINT `fk_risk_liquidity_risk_assessment_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ADD CONSTRAINT `fk_risk_risk_counterparty_exposure_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`risk`.`risk_exception` ADD CONSTRAINT `fk_risk_risk_exception_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ADD CONSTRAINT `fk_risk_risk_factor_exposure_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`risk`.`risk_review` ADD CONSTRAINT `fk_risk_risk_review_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ADD CONSTRAINT `fk_risk_sensitivity_analysis_holding_id` FOREIGN KEY (`holding_id`) REFERENCES `asset_management`.`portfolio`.`holding`(`holding_id`);
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ADD CONSTRAINT `fk_risk_sensitivity_analysis_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ADD CONSTRAINT `fk_risk_stress_test_result_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`risk`.`stress_test_run` ADD CONSTRAINT `fk_risk_stress_test_run_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`risk`.`validation_run` ADD CONSTRAINT `fk_risk_validation_run_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`risk`.`var_calculation` ADD CONSTRAINT `fk_risk_var_calculation_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);

-- ========= risk --> research (7 constraint(s)) =========
-- Requires: risk schema, research schema
ALTER TABLE `asset_management`.`risk`.`calculation_run` ADD CONSTRAINT `fk_risk_calculation_run_market_data_snapshot_id` FOREIGN KEY (`market_data_snapshot_id`) REFERENCES `asset_management`.`research`.`market_data_snapshot`(`market_data_snapshot_id`);
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ADD CONSTRAINT `fk_risk_dv01_sensitivity_research_yield_curve_id` FOREIGN KEY (`research_yield_curve_id`) REFERENCES `asset_management`.`research`.`research_yield_curve`(`research_yield_curve_id`);
ALTER TABLE `asset_management`.`risk`.`factor` ADD CONSTRAINT `fk_risk_factor_macro_indicator_id` FOREIGN KEY (`macro_indicator_id`) REFERENCES `asset_management`.`research`.`macro_indicator`(`macro_indicator_id`);
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ADD CONSTRAINT `fk_risk_fx_risk_exposure_research_fx_rate_id` FOREIGN KEY (`research_fx_rate_id`) REFERENCES `asset_management`.`research`.`research_fx_rate`(`research_fx_rate_id`);
ALTER TABLE `asset_management`.`risk`.`risk_review` ADD CONSTRAINT `fk_risk_risk_review_research_report_id` FOREIGN KEY (`research_report_id`) REFERENCES `asset_management`.`research`.`research_report`(`research_report_id`);
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ADD CONSTRAINT `fk_risk_stress_scenario_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ADD CONSTRAINT `fk_risk_stress_scenario_macro_indicator_id` FOREIGN KEY (`macro_indicator_id`) REFERENCES `asset_management`.`research`.`macro_indicator`(`macro_indicator_id`);

-- ========= risk --> shared (31 constraint(s)) =========
-- Requires: risk schema, shared schema
ALTER TABLE `asset_management`.`risk`.`appetite_statement` ADD CONSTRAINT `fk_risk_appetite_statement_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`risk`.`attribution` ADD CONSTRAINT `fk_risk_attribution_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`risk`.`calculation_run` ADD CONSTRAINT `fk_risk_calculation_run_approved_by_user_employee_id` FOREIGN KEY (`approved_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`risk`.`calculation_run` ADD CONSTRAINT `fk_risk_calculation_run_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`risk`.`concentration_exposure` ADD CONSTRAINT `fk_risk_concentration_exposure_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`risk`.`correlation_matrix` ADD CONSTRAINT `fk_risk_correlation_matrix_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`risk`.`credit_rating` ADD CONSTRAINT `fk_risk_credit_rating_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ADD CONSTRAINT `fk_risk_dv01_sensitivity_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`risk`.`factor_return` ADD CONSTRAINT `fk_risk_factor_return_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`risk`.`factor` ADD CONSTRAINT `fk_risk_factor_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ADD CONSTRAINT `fk_risk_fx_risk_exposure_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`risk`.`limit_assignment` ADD CONSTRAINT `fk_risk_limit_assignment_assigned_by_employee_id` FOREIGN KEY (`assigned_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`risk`.`limit_breach` ADD CONSTRAINT `fk_risk_limit_breach_acknowledged_by_employee_id` FOREIGN KEY (`acknowledged_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`risk`.`limit` ADD CONSTRAINT `fk_risk_limit_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ADD CONSTRAINT `fk_risk_liquidity_risk_assessment_assessed_by_employee_id` FOREIGN KEY (`assessed_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`risk`.`model_validation` ADD CONSTRAINT `fk_risk_model_validation_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`risk`.`model_validation` ADD CONSTRAINT `fk_risk_model_validation_job_run_user_employee_id` FOREIGN KEY (`job_run_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`risk`.`model_validation` ADD CONSTRAINT `fk_risk_model_validation_model_employee_id` FOREIGN KEY (`model_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`risk`.`model_validation` ADD CONSTRAINT `fk_risk_model_validation_model_job_run_user_employee_id` FOREIGN KEY (`model_job_run_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`risk`.`model` ADD CONSTRAINT `fk_risk_model_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`risk`.`risk_exception` ADD CONSTRAINT `fk_risk_risk_exception_requested_by_employee_id` FOREIGN KEY (`requested_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ADD CONSTRAINT `fk_risk_risk_factor_exposure_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`risk`.`risk_review` ADD CONSTRAINT `fk_risk_risk_review_lead_reviewer_employee_id` FOREIGN KEY (`lead_reviewer_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ADD CONSTRAINT `fk_risk_sensitivity_analysis_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`risk`.`stress_scenario` ADD CONSTRAINT `fk_risk_stress_scenario_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ADD CONSTRAINT `fk_risk_stress_test_result_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`risk`.`stress_test_run` ADD CONSTRAINT `fk_risk_stress_test_run_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`risk`.`stress_test_run` ADD CONSTRAINT `fk_risk_stress_test_run_approved_by_user_actor_id` FOREIGN KEY (`approved_by_user_actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`risk`.`validation_run` ADD CONSTRAINT `fk_risk_validation_run_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`risk`.`validation_run` ADD CONSTRAINT `fk_risk_validation_run_approved_by_user_actor_id` FOREIGN KEY (`approved_by_user_actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`risk`.`var_calculation` ADD CONSTRAINT `fk_risk_var_calculation_approved_by_employee_id` FOREIGN KEY (`approved_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);

-- ========= risk --> trade (8 constraint(s)) =========
-- Requires: risk schema, trade schema
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ADD CONSTRAINT `fk_risk_dv01_sensitivity_instrument_id` FOREIGN KEY (`instrument_id`) REFERENCES `asset_management`.`trade`.`instrument`(`instrument_id`);
ALTER TABLE `asset_management`.`risk`.`dv01_sensitivity` ADD CONSTRAINT `fk_risk_dv01_sensitivity_security_instrument_id` FOREIGN KEY (`security_instrument_id`) REFERENCES `asset_management`.`trade`.`instrument`(`instrument_id`);
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ADD CONSTRAINT `fk_risk_fx_risk_exposure_hedge_fx_trade_id` FOREIGN KEY (`hedge_fx_trade_id`) REFERENCES `asset_management`.`trade`.`fx_trade`(`fx_trade_id`);
ALTER TABLE `asset_management`.`risk`.`limit_breach` ADD CONSTRAINT `fk_risk_limit_breach_triggering_order_id` FOREIGN KEY (`triggering_order_id`) REFERENCES `asset_management`.`trade`.`order`(`order_id`);
ALTER TABLE `asset_management`.`risk`.`risk_counterparty_exposure` ADD CONSTRAINT `fk_risk_risk_counterparty_exposure_otc_derivative_id` FOREIGN KEY (`otc_derivative_id`) REFERENCES `asset_management`.`trade`.`otc_derivative`(`otc_derivative_id`);
ALTER TABLE `asset_management`.`risk`.`risk_factor_exposure` ADD CONSTRAINT `fk_risk_risk_factor_exposure_instrument_id` FOREIGN KEY (`instrument_id`) REFERENCES `asset_management`.`trade`.`instrument`(`instrument_id`);
ALTER TABLE `asset_management`.`risk`.`sensitivity_analysis` ADD CONSTRAINT `fk_risk_sensitivity_analysis_instrument_id` FOREIGN KEY (`instrument_id`) REFERENCES `asset_management`.`trade`.`instrument`(`instrument_id`);
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ADD CONSTRAINT `fk_risk_stress_test_result_instrument_id` FOREIGN KEY (`instrument_id`) REFERENCES `asset_management`.`trade`.`instrument`(`instrument_id`);

-- ========= risk --> treasury (2 constraint(s)) =========
-- Requires: risk schema, treasury schema
ALTER TABLE `asset_management`.`risk`.`fx_risk_exposure` ADD CONSTRAINT `fk_risk_fx_risk_exposure_fx_position_id` FOREIGN KEY (`fx_position_id`) REFERENCES `asset_management`.`treasury`.`fx_position`(`fx_position_id`);
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ADD CONSTRAINT `fk_risk_stress_test_result_hedge_program_id` FOREIGN KEY (`hedge_program_id`) REFERENCES `asset_management`.`treasury`.`hedge_program`(`hedge_program_id`);

-- ========= risk --> valuation (3 constraint(s)) =========
-- Requires: risk schema, valuation schema
ALTER TABLE `asset_management`.`risk`.`liquidity_risk_assessment` ADD CONSTRAINT `fk_risk_liquidity_risk_assessment_valuation_cycle_id` FOREIGN KEY (`valuation_cycle_id`) REFERENCES `asset_management`.`valuation`.`cycle`(`cycle_id`);
ALTER TABLE `asset_management`.`risk`.`stress_test_result` ADD CONSTRAINT `fk_risk_stress_test_result_valuation_cycle_id` FOREIGN KEY (`valuation_cycle_id`) REFERENCES `asset_management`.`valuation`.`cycle`(`cycle_id`);
ALTER TABLE `asset_management`.`risk`.`var_calculation` ADD CONSTRAINT `fk_risk_var_calculation_valuation_cycle_id` FOREIGN KEY (`valuation_cycle_id`) REFERENCES `asset_management`.`valuation`.`cycle`(`cycle_id`);

-- ========= shared --> privateequity (1 constraint(s)) =========
-- Requires: shared schema, privateequity schema
ALTER TABLE `asset_management`.`shared`.`contract` ADD CONSTRAINT `fk_shared_contract_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);

-- ========= trade --> beneficiary (1 constraint(s)) =========
-- Requires: trade schema, beneficiary schema
ALTER TABLE `asset_management`.`trade`.`broker` ADD CONSTRAINT `fk_trade_broker_finra_member_id` FOREIGN KEY (`finra_member_id`) REFERENCES `asset_management`.`beneficiary`.`member`(`member_id`);

-- ========= trade --> collateral (16 constraint(s)) =========
-- Requires: trade schema, collateral schema
ALTER TABLE `asset_management`.`trade`.`blotter` ADD CONSTRAINT `fk_trade_blotter_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ADD CONSTRAINT `fk_trade_ccp_clearing_ccp_membership_id` FOREIGN KEY (`ccp_membership_id`) REFERENCES `asset_management`.`collateral`.`ccp_membership`(`ccp_membership_id`);
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ADD CONSTRAINT `fk_trade_ccp_clearing_netting_agreement_id` FOREIGN KEY (`netting_agreement_id`) REFERENCES `asset_management`.`collateral`.`netting_agreement`(`netting_agreement_id`);
ALTER TABLE `asset_management`.`trade`.`confirmation` ADD CONSTRAINT `fk_trade_confirmation_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`trade`.`custody_account` ADD CONSTRAINT `fk_trade_custody_account_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`trade`.`execution` ADD CONSTRAINT `fk_trade_execution_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`trade`.`fx_trade` ADD CONSTRAINT `fk_trade_fx_trade_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`trade`.`fx_trade` ADD CONSTRAINT `fk_trade_fx_trade_csa_id` FOREIGN KEY (`csa_id`) REFERENCES `asset_management`.`collateral`.`csa`(`csa_id`);
ALTER TABLE `asset_management`.`trade`.`fx_trade` ADD CONSTRAINT `fk_trade_fx_trade_isda_master_id` FOREIGN KEY (`isda_master_id`) REFERENCES `asset_management`.`collateral`.`isda_master`(`isda_master_id`);
ALTER TABLE `asset_management`.`trade`.`netting_set_inclusion` ADD CONSTRAINT `fk_trade_netting_set_inclusion_netting_agreement_id` FOREIGN KEY (`netting_agreement_id`) REFERENCES `asset_management`.`collateral`.`netting_agreement`(`netting_agreement_id`);
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ADD CONSTRAINT `fk_trade_otc_derivative_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ADD CONSTRAINT `fk_trade_otc_derivative_csa_id` FOREIGN KEY (`csa_id`) REFERENCES `asset_management`.`collateral`.`csa`(`csa_id`);
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ADD CONSTRAINT `fk_trade_otc_derivative_isda_master_id` FOREIGN KEY (`isda_master_id`) REFERENCES `asset_management`.`collateral`.`isda_master`(`isda_master_id`);
ALTER TABLE `asset_management`.`trade`.`settlement_fail` ADD CONSTRAINT `fk_trade_settlement_fail_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`trade`.`standing_settlement_instruction` ADD CONSTRAINT `fk_trade_standing_settlement_instruction_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`trade`.`status_history` ADD CONSTRAINT `fk_trade_status_history_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);

-- ========= trade --> compliance (2 constraint(s)) =========
-- Requires: trade schema, compliance schema
ALTER TABLE `asset_management`.`trade`.`broker` ADD CONSTRAINT `fk_trade_broker_kyc_record_id` FOREIGN KEY (`kyc_record_id`) REFERENCES `asset_management`.`compliance`.`kyc_record`(`kyc_record_id`);
ALTER TABLE `asset_management`.`trade`.`trade_check` ADD CONSTRAINT `fk_trade_trade_check_rule_id` FOREIGN KEY (`rule_id`) REFERENCES `asset_management`.`compliance`.`rule`(`rule_id`);

-- ========= trade --> deal (1 constraint(s)) =========
-- Requires: trade schema, deal schema
ALTER TABLE `asset_management`.`trade`.`order` ADD CONSTRAINT `fk_trade_order_opportunity_id` FOREIGN KEY (`opportunity_id`) REFERENCES `asset_management`.`deal`.`opportunity`(`opportunity_id`);

-- ========= trade --> esg (3 constraint(s)) =========
-- Requires: trade schema, esg schema
ALTER TABLE `asset_management`.`trade`.`instrument_exclusion` ADD CONSTRAINT `fk_trade_instrument_exclusion_exclusion_list_id` FOREIGN KEY (`exclusion_list_id`) REFERENCES `asset_management`.`esg`.`exclusion_list`(`exclusion_list_id`);
ALTER TABLE `asset_management`.`trade`.`order` ADD CONSTRAINT `fk_trade_order_esg_policy_id` FOREIGN KEY (`esg_policy_id`) REFERENCES `asset_management`.`esg`.`esg_policy`(`esg_policy_id`);
ALTER TABLE `asset_management`.`trade`.`order` ADD CONSTRAINT `fk_trade_order_exclusion_list_id` FOREIGN KEY (`exclusion_list_id`) REFERENCES `asset_management`.`esg`.`exclusion_list`(`exclusion_list_id`);

-- ========= trade --> manager (9 constraint(s)) =========
-- Requires: trade schema, manager schema
ALTER TABLE `asset_management`.`trade`.`algo_order` ADD CONSTRAINT `fk_trade_algo_order_strategy_id` FOREIGN KEY (`strategy_id`) REFERENCES `asset_management`.`manager`.`strategy`(`strategy_id`);
ALTER TABLE `asset_management`.`trade`.`allocation_group` ADD CONSTRAINT `fk_trade_allocation_group_investment_strategy_id` FOREIGN KEY (`investment_strategy_id`) REFERENCES `asset_management`.`manager`.`strategy`(`strategy_id`);
ALTER TABLE `asset_management`.`trade`.`blotter` ADD CONSTRAINT `fk_trade_blotter_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`trade`.`blotter` ADD CONSTRAINT `fk_trade_blotter_strategy_id` FOREIGN KEY (`strategy_id`) REFERENCES `asset_management`.`manager`.`strategy`(`strategy_id`);
ALTER TABLE `asset_management`.`trade`.`broker_commission` ADD CONSTRAINT `fk_trade_broker_commission_strategy_id` FOREIGN KEY (`strategy_id`) REFERENCES `asset_management`.`manager`.`strategy`(`strategy_id`);
ALTER TABLE `asset_management`.`trade`.`confirmation` ADD CONSTRAINT `fk_trade_confirmation_strategy_id` FOREIGN KEY (`strategy_id`) REFERENCES `asset_management`.`manager`.`strategy`(`strategy_id`);
ALTER TABLE `asset_management`.`trade`.`execution` ADD CONSTRAINT `fk_trade_execution_strategy_id` FOREIGN KEY (`strategy_id`) REFERENCES `asset_management`.`manager`.`strategy`(`strategy_id`);
ALTER TABLE `asset_management`.`trade`.`fx_trade` ADD CONSTRAINT `fk_trade_fx_trade_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ADD CONSTRAINT `fk_trade_transaction_cost_strategy_id` FOREIGN KEY (`strategy_id`) REFERENCES `asset_management`.`manager`.`strategy`(`strategy_id`);

-- ========= trade --> naturalresource (3 constraint(s)) =========
-- Requires: trade schema, naturalresource schema
ALTER TABLE `asset_management`.`trade`.`blotter` ADD CONSTRAINT `fk_trade_blotter_natural_resource_asset_id` FOREIGN KEY (`natural_resource_asset_id`) REFERENCES `asset_management`.`naturalresource`.`resource_asset`(`resource_asset_id`);
ALTER TABLE `asset_management`.`trade`.`execution` ADD CONSTRAINT `fk_trade_execution_natural_resource_asset_id` FOREIGN KEY (`natural_resource_asset_id`) REFERENCES `asset_management`.`naturalresource`.`resource_asset`(`resource_asset_id`);
ALTER TABLE `asset_management`.`trade`.`order` ADD CONSTRAINT `fk_trade_order_natural_resource_asset_id` FOREIGN KEY (`natural_resource_asset_id`) REFERENCES `asset_management`.`naturalresource`.`resource_asset`(`resource_asset_id`);

-- ========= trade --> performance (2 constraint(s)) =========
-- Requires: trade schema, performance schema
ALTER TABLE `asset_management`.`trade`.`allocation_group` ADD CONSTRAINT `fk_trade_allocation_group_performance_benchmark_id` FOREIGN KEY (`performance_benchmark_id`) REFERENCES `asset_management`.`performance`.`performance_benchmark`(`performance_benchmark_id`);
ALTER TABLE `asset_management`.`trade`.`blotter` ADD CONSTRAINT `fk_trade_blotter_performance_benchmark_id` FOREIGN KEY (`performance_benchmark_id`) REFERENCES `asset_management`.`performance`.`performance_benchmark`(`performance_benchmark_id`);

-- ========= trade --> portfolio (13 constraint(s)) =========
-- Requires: trade schema, portfolio schema
ALTER TABLE `asset_management`.`trade`.`algo_order` ADD CONSTRAINT `fk_trade_algo_order_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`trade`.`blotter` ADD CONSTRAINT `fk_trade_blotter_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`trade`.`broker_commission` ADD CONSTRAINT `fk_trade_broker_commission_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ADD CONSTRAINT `fk_trade_ccp_clearing_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`trade`.`confirmation` ADD CONSTRAINT `fk_trade_confirmation_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`trade`.`custody_account` ADD CONSTRAINT `fk_trade_custody_account_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`trade`.`execution` ADD CONSTRAINT `fk_trade_execution_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`trade`.`fx_trade` ADD CONSTRAINT `fk_trade_fx_trade_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`trade`.`order_allocation` ADD CONSTRAINT `fk_trade_order_allocation_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`trade`.`order` ADD CONSTRAINT `fk_trade_order_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ADD CONSTRAINT `fk_trade_otc_derivative_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`trade`.`status_history` ADD CONSTRAINT `fk_trade_status_history_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ADD CONSTRAINT `fk_trade_transaction_cost_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);

-- ========= trade --> research (2 constraint(s)) =========
-- Requires: trade schema, research schema
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ADD CONSTRAINT `fk_trade_otc_derivative_research_yield_curve_id` FOREIGN KEY (`research_yield_curve_id`) REFERENCES `asset_management`.`research`.`research_yield_curve`(`research_yield_curve_id`);
ALTER TABLE `asset_management`.`trade`.`transaction_cost` ADD CONSTRAINT `fk_trade_transaction_cost_market_data_snapshot_id` FOREIGN KEY (`market_data_snapshot_id`) REFERENCES `asset_management`.`research`.`market_data_snapshot`(`market_data_snapshot_id`);

-- ========= trade --> shared (25 constraint(s)) =========
-- Requires: trade schema, shared schema
ALTER TABLE `asset_management`.`trade`.`algo_order` ADD CONSTRAINT `fk_trade_algo_order_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`trade`.`algo_order` ADD CONSTRAINT `fk_trade_algo_order_trader_employee_id` FOREIGN KEY (`trader_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`trade`.`allocation_group` ADD CONSTRAINT `fk_trade_allocation_group_approved_by_user_employee_id` FOREIGN KEY (`approved_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`trade`.`allocation_group` ADD CONSTRAINT `fk_trade_allocation_group_department_id` FOREIGN KEY (`department_id`) REFERENCES `asset_management`.`shared`.`department`(`department_id`);
ALTER TABLE `asset_management`.`trade`.`allocation_group` ADD CONSTRAINT `fk_trade_allocation_group_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`trade`.`allocation_group` ADD CONSTRAINT `fk_trade_allocation_group_legal_entity_id` FOREIGN KEY (`legal_entity_id`) REFERENCES `asset_management`.`shared`.`legal_entity`(`legal_entity_id`);
ALTER TABLE `asset_management`.`trade`.`amendment` ADD CONSTRAINT `fk_trade_amendment_amendment_approved_by_user_employee_id` FOREIGN KEY (`amendment_approved_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`trade`.`amendment` ADD CONSTRAINT `fk_trade_amendment_amendment_employee_id` FOREIGN KEY (`amendment_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`trade`.`amendment` ADD CONSTRAINT `fk_trade_amendment_approved_by_user_employee_id` FOREIGN KEY (`approved_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`trade`.`amendment` ADD CONSTRAINT `fk_trade_amendment_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`trade`.`blotter` ADD CONSTRAINT `fk_trade_blotter_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`trade`.`blotter` ADD CONSTRAINT `fk_trade_blotter_trader_employee_id` FOREIGN KEY (`trader_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`trade`.`broker_commission` ADD CONSTRAINT `fk_trade_broker_commission_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`trade`.`broker_commission` ADD CONSTRAINT `fk_trade_broker_commission_trader_employee_id` FOREIGN KEY (`trader_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`trade`.`fx_trade` ADD CONSTRAINT `fk_trade_fx_trade_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`trade`.`fx_trade` ADD CONSTRAINT `fk_trade_fx_trade_trader_employee_id` FOREIGN KEY (`trader_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`trade`.`order_allocation` ADD CONSTRAINT `fk_trade_order_allocation_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`trade`.`order_allocation` ADD CONSTRAINT `fk_trade_order_allocation_trader_employee_id` FOREIGN KEY (`trader_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`trade`.`order` ADD CONSTRAINT `fk_trade_order_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`trade`.`order` ADD CONSTRAINT `fk_trade_order_order_employee_id` FOREIGN KEY (`order_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`trade`.`order` ADD CONSTRAINT `fk_trade_order_order_trader_employee_id` FOREIGN KEY (`order_trader_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`trade`.`order` ADD CONSTRAINT `fk_trade_order_trader_employee_id` FOREIGN KEY (`trader_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ADD CONSTRAINT `fk_trade_otc_derivative_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`trade`.`otc_derivative` ADD CONSTRAINT `fk_trade_otc_derivative_trader_employee_id` FOREIGN KEY (`trader_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`trade`.`status_history` ADD CONSTRAINT `fk_trade_status_history_triggering_user_employee_id` FOREIGN KEY (`triggering_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);

-- ========= trade --> treasury (4 constraint(s)) =========
-- Requires: trade schema, treasury schema
ALTER TABLE `asset_management`.`trade`.`broker_commission` ADD CONSTRAINT `fk_trade_broker_commission_payment_cash_account_id` FOREIGN KEY (`payment_cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);
ALTER TABLE `asset_management`.`trade`.`ccp_clearing` ADD CONSTRAINT `fk_trade_ccp_clearing_cash_account_id` FOREIGN KEY (`cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);
ALTER TABLE `asset_management`.`trade`.`fx_trade` ADD CONSTRAINT `fk_trade_fx_trade_settlement_cash_account_id` FOREIGN KEY (`settlement_cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);
ALTER TABLE `asset_management`.`trade`.`order_allocation` ADD CONSTRAINT `fk_trade_order_allocation_cash_account_id` FOREIGN KEY (`cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);

-- ========= treasury --> actuarial (5 constraint(s)) =========
-- Requires: treasury schema, actuarial schema
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ADD CONSTRAINT `fk_treasury_hedge_effectiveness_ldi_strategy_id` FOREIGN KEY (`ldi_strategy_id`) REFERENCES `asset_management`.`actuarial`.`ldi_strategy`(`ldi_strategy_id`);
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ADD CONSTRAINT `fk_treasury_hedge_program_ldi_strategy_id` FOREIGN KEY (`ldi_strategy_id`) REFERENCES `asset_management`.`actuarial`.`ldi_strategy`(`ldi_strategy_id`);
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ADD CONSTRAINT `fk_treasury_liquidity_forecast_liability_cash_flow_id` FOREIGN KEY (`liability_cash_flow_id`) REFERENCES `asset_management`.`actuarial`.`liability_cash_flow`(`liability_cash_flow_id`);
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ADD CONSTRAINT `fk_treasury_liquidity_forecast_liability_projection_id` FOREIGN KEY (`liability_projection_id`) REFERENCES `asset_management`.`actuarial`.`liability_projection`(`liability_projection_id`);
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ADD CONSTRAINT `fk_treasury_liquidity_reserve_policy_funded_status_id` FOREIGN KEY (`funded_status_id`) REFERENCES `asset_management`.`actuarial`.`funded_status`(`funded_status_id`);

-- ========= treasury --> beneficiary (2 constraint(s)) =========
-- Requires: treasury schema, beneficiary schema
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ADD CONSTRAINT `fk_treasury_net_contribution_inflow_contributor_pool_id` FOREIGN KEY (`contributor_pool_id`) REFERENCES `asset_management`.`beneficiary`.`contributor_pool`(`contributor_pool_id`);
ALTER TABLE `asset_management`.`treasury`.`net_contribution_inflow` ADD CONSTRAINT `fk_treasury_net_contribution_inflow_participating_employer_id` FOREIGN KEY (`participating_employer_id`) REFERENCES `asset_management`.`beneficiary`.`participating_employer`(`participating_employer_id`);

-- ========= treasury --> collateral (30 constraint(s)) =========
-- Requires: treasury schema, collateral schema
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ADD CONSTRAINT `fk_treasury_bank_account_ssi_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_account` ADD CONSTRAINT `fk_treasury_cash_account_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_account` ADD CONSTRAINT `fk_treasury_cash_account_csa_agreement_csa_id` FOREIGN KEY (`csa_agreement_csa_id`) REFERENCES `asset_management`.`collateral`.`csa`(`csa_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_account` ADD CONSTRAINT `fk_treasury_cash_account_csa_id` FOREIGN KEY (`csa_id`) REFERENCES `asset_management`.`collateral`.`csa`(`csa_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ADD CONSTRAINT `fk_treasury_cash_flow_event_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ADD CONSTRAINT `fk_treasury_cash_flow_event_margin_call_id` FOREIGN KEY (`margin_call_id`) REFERENCES `asset_management`.`collateral`.`margin_call`(`margin_call_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ADD CONSTRAINT `fk_treasury_cash_transfer_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ADD CONSTRAINT `fk_treasury_cash_transfer_margin_call_id` FOREIGN KEY (`margin_call_id`) REFERENCES `asset_management`.`collateral`.`margin_call`(`margin_call_id`);
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ADD CONSTRAINT `fk_treasury_counterparty_limit_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ADD CONSTRAINT `fk_treasury_counterparty_limit_csa_agreement_csa_id` FOREIGN KEY (`csa_agreement_csa_id`) REFERENCES `asset_management`.`collateral`.`csa`(`csa_id`);
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ADD CONSTRAINT `fk_treasury_counterparty_limit_csa_id` FOREIGN KEY (`csa_id`) REFERENCES `asset_management`.`collateral`.`csa`(`csa_id`);
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ADD CONSTRAINT `fk_treasury_counterparty_limit_isda_master_agreement_isda_master_id` FOREIGN KEY (`isda_master_agreement_isda_master_id`) REFERENCES `asset_management`.`collateral`.`isda_master`(`isda_master_id`);
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ADD CONSTRAINT `fk_treasury_counterparty_limit_isda_master_id` FOREIGN KEY (`isda_master_id`) REFERENCES `asset_management`.`collateral`.`isda_master`(`isda_master_id`);
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ADD CONSTRAINT `fk_treasury_fx_forward_csa_agreement_csa_id` FOREIGN KEY (`csa_agreement_csa_id`) REFERENCES `asset_management`.`collateral`.`csa`(`csa_id`);
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ADD CONSTRAINT `fk_treasury_fx_forward_csa_id` FOREIGN KEY (`csa_id`) REFERENCES `asset_management`.`collateral`.`csa`(`csa_id`);
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ADD CONSTRAINT `fk_treasury_fx_forward_isda_master_agreement_isda_master_id` FOREIGN KEY (`isda_master_agreement_isda_master_id`) REFERENCES `asset_management`.`collateral`.`isda_master`(`isda_master_id`);
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ADD CONSTRAINT `fk_treasury_fx_forward_isda_master_id` FOREIGN KEY (`isda_master_id`) REFERENCES `asset_management`.`collateral`.`isda_master`(`isda_master_id`);
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ADD CONSTRAINT `fk_treasury_fx_forward_netting_agreement_id` FOREIGN KEY (`netting_agreement_id`) REFERENCES `asset_management`.`collateral`.`netting_agreement`(`netting_agreement_id`);
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ADD CONSTRAINT `fk_treasury_fx_forward_netting_set_netting_agreement_id` FOREIGN KEY (`netting_set_netting_agreement_id`) REFERENCES `asset_management`.`collateral`.`netting_agreement`(`netting_agreement_id`);
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ADD CONSTRAINT `fk_treasury_fx_hedge_rebalance_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ADD CONSTRAINT `fk_treasury_fx_hedge_rebalance_isda_agreement_isda_master_id` FOREIGN KEY (`isda_agreement_isda_master_id`) REFERENCES `asset_management`.`collateral`.`isda_master`(`isda_master_id`);
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ADD CONSTRAINT `fk_treasury_fx_hedge_rebalance_isda_master_id` FOREIGN KEY (`isda_master_id`) REFERENCES `asset_management`.`collateral`.`isda_master`(`isda_master_id`);
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ADD CONSTRAINT `fk_treasury_fx_swap_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ADD CONSTRAINT `fk_treasury_fx_swap_isda_agreement_isda_master_id` FOREIGN KEY (`isda_agreement_isda_master_id`) REFERENCES `asset_management`.`collateral`.`isda_master`(`isda_master_id`);
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ADD CONSTRAINT `fk_treasury_fx_swap_isda_master_id` FOREIGN KEY (`isda_master_id`) REFERENCES `asset_management`.`collateral`.`isda_master`(`isda_master_id`);
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ADD CONSTRAINT `fk_treasury_short_term_instrument_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ADD CONSTRAINT `fk_treasury_st_instrument_transaction_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ADD CONSTRAINT `fk_treasury_sweep_instruction_ssi_registry_id` FOREIGN KEY (`ssi_registry_id`) REFERENCES `asset_management`.`collateral`.`ssi_registry`(`ssi_registry_id`);
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ADD CONSTRAINT `fk_treasury_treasury_counterparty_exposure_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ADD CONSTRAINT `fk_treasury_treasury_counterparty_exposure_netting_agreement_id` FOREIGN KEY (`netting_agreement_id`) REFERENCES `asset_management`.`collateral`.`netting_agreement`(`netting_agreement_id`);

-- ========= treasury --> compliance (4 constraint(s)) =========
-- Requires: treasury schema, compliance schema
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ADD CONSTRAINT `fk_treasury_counterparty_limit_kyc_record_id` FOREIGN KEY (`kyc_record_id`) REFERENCES `asset_management`.`compliance`.`kyc_record`(`kyc_record_id`);
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ADD CONSTRAINT `fk_treasury_liquidity_reserve_policy_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ADD CONSTRAINT `fk_treasury_treasury_policy_policy_document_id` FOREIGN KEY (`policy_document_id`) REFERENCES `asset_management`.`compliance`.`policy_document`(`policy_document_id`);
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ADD CONSTRAINT `fk_treasury_treasury_policy_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);

-- ========= treasury --> diligence (1 constraint(s)) =========
-- Requires: treasury schema, diligence schema
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ADD CONSTRAINT `fk_treasury_capital_call_funding_dd_engagement_id` FOREIGN KEY (`dd_engagement_id`) REFERENCES `asset_management`.`diligence`.`dd_engagement`(`dd_engagement_id`);

-- ========= treasury --> equity (1 constraint(s)) =========
-- Requires: treasury schema, equity schema
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ADD CONSTRAINT `fk_treasury_cash_flow_event_listed_security_id` FOREIGN KEY (`listed_security_id`) REFERENCES `asset_management`.`equity`.`listed_security`(`listed_security_id`);

-- ========= treasury --> esg (4 constraint(s)) =========
-- Requires: treasury schema, esg schema
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ADD CONSTRAINT `fk_treasury_hedge_program_esg_policy_id` FOREIGN KEY (`esg_policy_id`) REFERENCES `asset_management`.`esg`.`esg_policy`(`esg_policy_id`);
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ADD CONSTRAINT `fk_treasury_short_term_instrument_issuer_esg_rating_id` FOREIGN KEY (`issuer_esg_rating_id`) REFERENCES `asset_management`.`esg`.`issuer_esg_rating`(`issuer_esg_rating_id`);
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ADD CONSTRAINT `fk_treasury_treasury_policy_esg_policy_id` FOREIGN KEY (`esg_policy_id`) REFERENCES `asset_management`.`esg`.`esg_policy`(`esg_policy_id`);
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ADD CONSTRAINT `fk_treasury_treasury_policy_framework_id` FOREIGN KEY (`framework_id`) REFERENCES `asset_management`.`esg`.`framework`(`framework_id`);

-- ========= treasury --> infrastructure (3 constraint(s)) =========
-- Requires: treasury schema, infrastructure schema
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ADD CONSTRAINT `fk_treasury_capital_call_funding_infra_fund_commitment_id` FOREIGN KEY (`infra_fund_commitment_id`) REFERENCES `asset_management`.`infrastructure`.`infra_fund_commitment`(`infra_fund_commitment_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_account` ADD CONSTRAINT `fk_treasury_cash_account_infra_fund_commitment_id` FOREIGN KEY (`infra_fund_commitment_id`) REFERENCES `asset_management`.`infrastructure`.`infra_fund_commitment`(`infra_fund_commitment_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_position` ADD CONSTRAINT `fk_treasury_cash_position_infra_fund_commitment_id` FOREIGN KEY (`infra_fund_commitment_id`) REFERENCES `asset_management`.`infrastructure`.`infra_fund_commitment`(`infra_fund_commitment_id`);

-- ========= treasury --> manager (3 constraint(s)) =========
-- Requires: treasury schema, manager schema
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ADD CONSTRAINT `fk_treasury_capital_call_funding_gp_profile_id` FOREIGN KEY (`gp_profile_id`) REFERENCES `asset_management`.`manager`.`gp_profile`(`gp_profile_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_account` ADD CONSTRAINT `fk_treasury_cash_account_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ADD CONSTRAINT `fk_treasury_cash_flow_event_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);

-- ========= treasury --> naturalresource (2 constraint(s)) =========
-- Requires: treasury schema, naturalresource schema
ALTER TABLE `asset_management`.`treasury`.`cash_account` ADD CONSTRAINT `fk_treasury_cash_account_resource_asset_id` FOREIGN KEY (`resource_asset_id`) REFERENCES `asset_management`.`naturalresource`.`resource_asset`(`resource_asset_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ADD CONSTRAINT `fk_treasury_cash_flow_event_resource_asset_id` FOREIGN KEY (`resource_asset_id`) REFERENCES `asset_management`.`naturalresource`.`resource_asset`(`resource_asset_id`);

-- ========= treasury --> performance (1 constraint(s)) =========
-- Requires: treasury schema, performance schema
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ADD CONSTRAINT `fk_treasury_distribution_receipt_distribution_notice_id` FOREIGN KEY (`distribution_notice_id`) REFERENCES `asset_management`.`performance`.`notice`(`notice_id`);

-- ========= treasury --> portfolio (8 constraint(s)) =========
-- Requires: treasury schema, portfolio schema
ALTER TABLE `asset_management`.`treasury`.`cash_account` ADD CONSTRAINT `fk_treasury_cash_account_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ADD CONSTRAINT `fk_treasury_cash_flow_event_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ADD CONSTRAINT `fk_treasury_distribution_receipt_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ADD CONSTRAINT `fk_treasury_fx_forward_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ADD CONSTRAINT `fk_treasury_fx_hedge_rebalance_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`treasury`.`fx_position` ADD CONSTRAINT `fk_treasury_fx_position_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ADD CONSTRAINT `fk_treasury_fx_swap_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ADD CONSTRAINT `fk_treasury_sweep_instruction_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);

-- ========= treasury --> privateequity (10 constraint(s)) =========
-- Requires: treasury schema, privateequity schema
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ADD CONSTRAINT `fk_treasury_capital_call_funding_fund_investment_id` FOREIGN KEY (`fund_investment_id`) REFERENCES `asset_management`.`privateequity`.`investment`(`investment_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ADD CONSTRAINT `fk_treasury_cash_flow_event_distribution_id` FOREIGN KEY (`distribution_id`) REFERENCES `asset_management`.`privateequity`.`distribution`(`distribution_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ADD CONSTRAINT `fk_treasury_cash_flow_event_investment_id` FOREIGN KEY (`investment_id`) REFERENCES `asset_management`.`privateequity`.`investment`(`investment_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ADD CONSTRAINT `fk_treasury_cash_flow_event_privateequity_capital_call_id` FOREIGN KEY (`privateequity_capital_call_id`) REFERENCES `asset_management`.`privateequity`.`privateequity_capital_call`(`privateequity_capital_call_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_position` ADD CONSTRAINT `fk_treasury_cash_position_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ADD CONSTRAINT `fk_treasury_cash_transfer_pe_investment_id` FOREIGN KEY (`pe_investment_id`) REFERENCES `asset_management`.`privateequity`.`investment`(`investment_id`);
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ADD CONSTRAINT `fk_treasury_distribution_receipt_fund_investment_id` FOREIGN KEY (`fund_investment_id`) REFERENCES `asset_management`.`privateequity`.`investment`(`investment_id`);
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ADD CONSTRAINT `fk_treasury_distribution_receipt_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);
ALTER TABLE `asset_management`.`treasury`.`gp_bank_account` ADD CONSTRAINT `fk_treasury_gp_bank_account_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);
ALTER TABLE `asset_management`.`treasury`.`gp_bank_account` ADD CONSTRAINT `fk_treasury_gp_bank_account_gp_entity_id` FOREIGN KEY (`gp_entity_id`) REFERENCES `asset_management`.`privateequity`.`gp_entity`(`gp_entity_id`);

-- ========= treasury --> research (6 constraint(s)) =========
-- Requires: treasury schema, research schema
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ADD CONSTRAINT `fk_treasury_cash_flow_event_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ADD CONSTRAINT `fk_treasury_counterparty_limit_country_outlook_id` FOREIGN KEY (`country_outlook_id`) REFERENCES `asset_management`.`research`.`country_outlook`(`country_outlook_id`);
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ADD CONSTRAINT `fk_treasury_hedge_program_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ADD CONSTRAINT `fk_treasury_liquidity_forecast_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ADD CONSTRAINT `fk_treasury_liquidity_reserve_policy_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ADD CONSTRAINT `fk_treasury_treasury_counterparty_exposure_country_outlook_id` FOREIGN KEY (`country_outlook_id`) REFERENCES `asset_management`.`research`.`country_outlook`(`country_outlook_id`);

-- ========= treasury --> risk (4 constraint(s)) =========
-- Requires: treasury schema, risk schema
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ADD CONSTRAINT `fk_treasury_counterparty_limit_risk_limit_id` FOREIGN KEY (`risk_limit_id`) REFERENCES `asset_management`.`risk`.`limit`(`limit_id`);
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ADD CONSTRAINT `fk_treasury_fx_hedge_rebalance_fx_risk_exposure_id` FOREIGN KEY (`fx_risk_exposure_id`) REFERENCES `asset_management`.`risk`.`fx_risk_exposure`(`fx_risk_exposure_id`);
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ADD CONSTRAINT `fk_treasury_hedge_program_var_limit_id` FOREIGN KEY (`var_limit_id`) REFERENCES `asset_management`.`risk`.`limit`(`limit_id`);
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ADD CONSTRAINT `fk_treasury_liquidity_forecast_liquidity_risk_assessment_id` FOREIGN KEY (`liquidity_risk_assessment_id`) REFERENCES `asset_management`.`risk`.`liquidity_risk_assessment`(`liquidity_risk_assessment_id`);

-- ========= treasury --> shared (35 constraint(s)) =========
-- Requires: treasury schema, shared schema
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ADD CONSTRAINT `fk_treasury_bank_account_ssi_approved_by_user_employee_id` FOREIGN KEY (`approved_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ADD CONSTRAINT `fk_treasury_bank_account_ssi_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ADD CONSTRAINT `fk_treasury_bank_account_ssi_legal_entity_id` FOREIGN KEY (`legal_entity_id`) REFERENCES `asset_management`.`shared`.`legal_entity`(`legal_entity_id`);
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ADD CONSTRAINT `fk_treasury_capital_call_funding_confirmation_document_id` FOREIGN KEY (`confirmation_document_id`) REFERENCES `asset_management`.`shared`.`document`(`document_id`);
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ADD CONSTRAINT `fk_treasury_capital_call_funding_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_account` ADD CONSTRAINT `fk_treasury_cash_account_legal_entity_id` FOREIGN KEY (`legal_entity_id`) REFERENCES `asset_management`.`shared`.`legal_entity`(`legal_entity_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ADD CONSTRAINT `fk_treasury_cash_flow_event_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ADD CONSTRAINT `fk_treasury_cash_reconciliation_approved_by_user_employee_id` FOREIGN KEY (`approved_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ADD CONSTRAINT `fk_treasury_cash_reconciliation_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ADD CONSTRAINT `fk_treasury_cash_reconciliation_reviewed_by_user_employee_id` FOREIGN KEY (`reviewed_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ADD CONSTRAINT `fk_treasury_cash_transfer_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ADD CONSTRAINT `fk_treasury_cash_transfer_initiated_by_user_employee_id` FOREIGN KEY (`initiated_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ADD CONSTRAINT `fk_treasury_counterparty_limit_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`treasury`.`counterparty_limit` ADD CONSTRAINT `fk_treasury_counterparty_limit_modified_by_user_employee_id` FOREIGN KEY (`modified_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ADD CONSTRAINT `fk_treasury_distribution_receipt_distribution_notice_document_id` FOREIGN KEY (`distribution_notice_document_id`) REFERENCES `asset_management`.`shared`.`document`(`document_id`);
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ADD CONSTRAINT `fk_treasury_distribution_receipt_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`treasury`.`fx_forward` ADD CONSTRAINT `fk_treasury_fx_forward_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ADD CONSTRAINT `fk_treasury_fx_hedge_rebalance_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ADD CONSTRAINT `fk_treasury_fx_hedge_rebalance_executed_by_user_employee_id` FOREIGN KEY (`executed_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ADD CONSTRAINT `fk_treasury_fx_swap_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ADD CONSTRAINT `fk_treasury_hedge_effectiveness_approved_by_user_employee_id` FOREIGN KEY (`approved_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ADD CONSTRAINT `fk_treasury_hedge_effectiveness_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ADD CONSTRAINT `fk_treasury_hedge_effectiveness_reviewed_by_user_employee_id` FOREIGN KEY (`reviewed_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`treasury`.`hedge_program` ADD CONSTRAINT `fk_treasury_hedge_program_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ADD CONSTRAINT `fk_treasury_liquidity_forecast_approved_by_user_employee_id` FOREIGN KEY (`approved_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ADD CONSTRAINT `fk_treasury_liquidity_forecast_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`treasury`.`liquidity_reserve_policy` ADD CONSTRAINT `fk_treasury_liquidity_reserve_policy_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ADD CONSTRAINT `fk_treasury_short_term_instrument_approval_user_employee_id` FOREIGN KEY (`approval_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`treasury`.`short_term_instrument` ADD CONSTRAINT `fk_treasury_short_term_instrument_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ADD CONSTRAINT `fk_treasury_st_instrument_transaction_approved_by_user_employee_id` FOREIGN KEY (`approved_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ADD CONSTRAINT `fk_treasury_st_instrument_transaction_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ADD CONSTRAINT `fk_treasury_sweep_instruction_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ADD CONSTRAINT `fk_treasury_sweep_instruction_initiated_by_user_employee_id` FOREIGN KEY (`initiated_by_user_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ADD CONSTRAINT `fk_treasury_sweep_instruction_legal_entity_id` FOREIGN KEY (`legal_entity_id`) REFERENCES `asset_management`.`shared`.`legal_entity`(`legal_entity_id`);
ALTER TABLE `asset_management`.`treasury`.`treasury_policy` ADD CONSTRAINT `fk_treasury_treasury_policy_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);

-- ========= treasury --> trade (20 constraint(s)) =========
-- Requires: treasury schema, trade schema
ALTER TABLE `asset_management`.`treasury`.`bank_account_ssi` ADD CONSTRAINT `fk_treasury_bank_account_ssi_custodian_id` FOREIGN KEY (`custodian_id`) REFERENCES `asset_management`.`trade`.`custodian`(`custodian_id`);
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ADD CONSTRAINT `fk_treasury_capital_call_funding_fx_hedge_instrument_id` FOREIGN KEY (`fx_hedge_instrument_id`) REFERENCES `asset_management`.`trade`.`instrument`(`instrument_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_account` ADD CONSTRAINT `fk_treasury_cash_account_custodian_id` FOREIGN KEY (`custodian_id`) REFERENCES `asset_management`.`trade`.`custodian`(`custodian_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ADD CONSTRAINT `fk_treasury_cash_flow_event_blotter_id` FOREIGN KEY (`blotter_id`) REFERENCES `asset_management`.`trade`.`blotter`(`blotter_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ADD CONSTRAINT `fk_treasury_cash_flow_event_custodian_id` FOREIGN KEY (`custodian_id`) REFERENCES `asset_management`.`trade`.`custodian`(`custodian_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_position` ADD CONSTRAINT `fk_treasury_cash_position_custodian_id` FOREIGN KEY (`custodian_id`) REFERENCES `asset_management`.`trade`.`custodian`(`custodian_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_position` ADD CONSTRAINT `fk_treasury_cash_position_settlement_instruction_id` FOREIGN KEY (`settlement_instruction_id`) REFERENCES `asset_management`.`trade`.`settlement_instruction`(`settlement_instruction_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ADD CONSTRAINT `fk_treasury_cash_reconciliation_custodian_id` FOREIGN KEY (`custodian_id`) REFERENCES `asset_management`.`trade`.`custodian`(`custodian_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ADD CONSTRAINT `fk_treasury_cash_transfer_destination_custodian_id` FOREIGN KEY (`destination_custodian_id`) REFERENCES `asset_management`.`trade`.`custodian`(`custodian_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ADD CONSTRAINT `fk_treasury_cash_transfer_related_trade_blotter_id` FOREIGN KEY (`related_trade_blotter_id`) REFERENCES `asset_management`.`trade`.`blotter`(`blotter_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ADD CONSTRAINT `fk_treasury_cash_transfer_source_custodian_id` FOREIGN KEY (`source_custodian_id`) REFERENCES `asset_management`.`trade`.`custodian`(`custodian_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_transfer` ADD CONSTRAINT `fk_treasury_cash_transfer_standing_settlement_instruction_id` FOREIGN KEY (`standing_settlement_instruction_id`) REFERENCES `asset_management`.`trade`.`standing_settlement_instruction`(`standing_settlement_instruction_id`);
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ADD CONSTRAINT `fk_treasury_distribution_receipt_custody_account_id` FOREIGN KEY (`custody_account_id`) REFERENCES `asset_management`.`trade`.`custody_account`(`custody_account_id`);
ALTER TABLE `asset_management`.`treasury`.`fx_hedge_rebalance` ADD CONSTRAINT `fk_treasury_fx_hedge_rebalance_fx_trade_id` FOREIGN KEY (`fx_trade_id`) REFERENCES `asset_management`.`trade`.`fx_trade`(`fx_trade_id`);
ALTER TABLE `asset_management`.`treasury`.`fx_swap` ADD CONSTRAINT `fk_treasury_fx_swap_custody_account_id` FOREIGN KEY (`custody_account_id`) REFERENCES `asset_management`.`trade`.`custody_account`(`custody_account_id`);
ALTER TABLE `asset_management`.`treasury`.`gp_bank_account` ADD CONSTRAINT `fk_treasury_gp_bank_account_custodian_id` FOREIGN KEY (`custodian_id`) REFERENCES `asset_management`.`trade`.`custodian`(`custodian_id`);
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ADD CONSTRAINT `fk_treasury_hedge_effectiveness_hedging_instrument_id` FOREIGN KEY (`hedging_instrument_id`) REFERENCES `asset_management`.`trade`.`instrument`(`instrument_id`);
ALTER TABLE `asset_management`.`treasury`.`st_instrument_transaction` ADD CONSTRAINT `fk_treasury_st_instrument_transaction_broker_id` FOREIGN KEY (`broker_id`) REFERENCES `asset_management`.`trade`.`broker`(`broker_id`);
ALTER TABLE `asset_management`.`treasury`.`sweep_instruction` ADD CONSTRAINT `fk_treasury_sweep_instruction_custodian_id` FOREIGN KEY (`custodian_id`) REFERENCES `asset_management`.`trade`.`custodian`(`custodian_id`);
ALTER TABLE `asset_management`.`treasury`.`treasury_counterparty_exposure` ADD CONSTRAINT `fk_treasury_treasury_counterparty_exposure_custodian_id` FOREIGN KEY (`custodian_id`) REFERENCES `asset_management`.`trade`.`custodian`(`custodian_id`);

-- ========= treasury --> valuation (9 constraint(s)) =========
-- Requires: treasury schema, valuation schema
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ADD CONSTRAINT `fk_treasury_capital_call_funding_adjustment_id` FOREIGN KEY (`adjustment_id`) REFERENCES `asset_management`.`valuation`.`adjustment`(`adjustment_id`);
ALTER TABLE `asset_management`.`treasury`.`capital_call_funding` ADD CONSTRAINT `fk_treasury_capital_call_funding_valuation_asset_valuation_id` FOREIGN KEY (`valuation_asset_valuation_id`) REFERENCES `asset_management`.`valuation`.`valuation_asset_valuation`(`valuation_asset_valuation_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_flow_event` ADD CONSTRAINT `fk_treasury_cash_flow_event_valuation_asset_valuation_id` FOREIGN KEY (`valuation_asset_valuation_id`) REFERENCES `asset_management`.`valuation`.`valuation_asset_valuation`(`valuation_asset_valuation_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_position` ADD CONSTRAINT `fk_treasury_cash_position_valuation_cycle_id` FOREIGN KEY (`valuation_cycle_id`) REFERENCES `asset_management`.`valuation`.`cycle`(`cycle_id`);
ALTER TABLE `asset_management`.`treasury`.`cash_reconciliation` ADD CONSTRAINT `fk_treasury_cash_reconciliation_valuation_cycle_id` FOREIGN KEY (`valuation_cycle_id`) REFERENCES `asset_management`.`valuation`.`cycle`(`cycle_id`);
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ADD CONSTRAINT `fk_treasury_distribution_receipt_adjustment_id` FOREIGN KEY (`adjustment_id`) REFERENCES `asset_management`.`valuation`.`adjustment`(`adjustment_id`);
ALTER TABLE `asset_management`.`treasury`.`distribution_receipt` ADD CONSTRAINT `fk_treasury_distribution_receipt_valuation_asset_valuation_id` FOREIGN KEY (`valuation_asset_valuation_id`) REFERENCES `asset_management`.`valuation`.`valuation_asset_valuation`(`valuation_asset_valuation_id`);
ALTER TABLE `asset_management`.`treasury`.`hedge_effectiveness` ADD CONSTRAINT `fk_treasury_hedge_effectiveness_valuation_cycle_id` FOREIGN KEY (`valuation_cycle_id`) REFERENCES `asset_management`.`valuation`.`cycle`(`cycle_id`);
ALTER TABLE `asset_management`.`treasury`.`liquidity_forecast` ADD CONSTRAINT `fk_treasury_liquidity_forecast_valuation_cycle_id` FOREIGN KEY (`valuation_cycle_id`) REFERENCES `asset_management`.`valuation`.`cycle`(`cycle_id`);

-- ========= valuation --> collateral (1 constraint(s)) =========
-- Requires: valuation schema, collateral schema
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ADD CONSTRAINT `fk_valuation_nav_liability_counterparty_id` FOREIGN KEY (`counterparty_id`) REFERENCES `asset_management`.`collateral`.`counterparty`(`counterparty_id`);

-- ========= valuation --> compliance (13 constraint(s)) =========
-- Requires: valuation schema, compliance schema
ALTER TABLE `asset_management`.`valuation`.`adjustment` ADD CONSTRAINT `fk_valuation_adjustment_audit_finding_id` FOREIGN KEY (`audit_finding_id`) REFERENCES `asset_management`.`compliance`.`audit_finding`(`audit_finding_id`);
ALTER TABLE `asset_management`.`valuation`.`adjustment` ADD CONSTRAINT `fk_valuation_adjustment_rule_breach_id` FOREIGN KEY (`rule_breach_id`) REFERENCES `asset_management`.`compliance`.`rule_breach`(`rule_breach_id`);
ALTER TABLE `asset_management`.`valuation`.`compliance_requirement` ADD CONSTRAINT `fk_valuation_compliance_requirement_rule_id` FOREIGN KEY (`rule_id`) REFERENCES `asset_management`.`compliance`.`rule`(`rule_id`);
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ADD CONSTRAINT `fk_valuation_credit_instrument_valuation_regulatory_reporting_regulatory_filing_id` FOREIGN KEY (`regulatory_reporting_regulatory_filing_id`) REFERENCES `asset_management`.`compliance`.`regulatory_filing`(`regulatory_filing_id`);
ALTER TABLE `asset_management`.`valuation`.`cycle` ADD CONSTRAINT `fk_valuation_cycle_obligation_id` FOREIGN KEY (`obligation_id`) REFERENCES `asset_management`.`compliance`.`obligation`(`obligation_id`);
ALTER TABLE `asset_management`.`valuation`.`cycle` ADD CONSTRAINT `fk_valuation_cycle_regulatory_calendar_id` FOREIGN KEY (`regulatory_calendar_id`) REFERENCES `asset_management`.`compliance`.`regulatory_calendar`(`regulatory_calendar_id`);
ALTER TABLE `asset_management`.`valuation`.`filing_inclusion` ADD CONSTRAINT `fk_valuation_filing_inclusion_regulatory_filing_id` FOREIGN KEY (`regulatory_filing_id`) REFERENCES `asset_management`.`compliance`.`regulatory_filing`(`regulatory_filing_id`);
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ADD CONSTRAINT `fk_valuation_indep_valuation_engagement_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);
ALTER TABLE `asset_management`.`valuation`.`methodology` ADD CONSTRAINT `fk_valuation_methodology_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);
ALTER TABLE `asset_management`.`valuation`.`price_exception` ADD CONSTRAINT `fk_valuation_price_exception_rule_breach_id` FOREIGN KEY (`rule_breach_id`) REFERENCES `asset_management`.`compliance`.`rule_breach`(`rule_breach_id`);
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ADD CONSTRAINT `fk_valuation_real_estate_appraisal_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);
ALTER TABLE `asset_management`.`valuation`.`valuation_nav_record` ADD CONSTRAINT `fk_valuation_valuation_nav_record_regulatory_filing_id` FOREIGN KEY (`regulatory_filing_id`) REFERENCES `asset_management`.`compliance`.`regulatory_filing`(`regulatory_filing_id`);
ALTER TABLE `asset_management`.`valuation`.`valuation_policy` ADD CONSTRAINT `fk_valuation_valuation_policy_regulatory_authority_id` FOREIGN KEY (`regulatory_authority_id`) REFERENCES `asset_management`.`compliance`.`regulatory_authority`(`regulatory_authority_id`);

-- ========= valuation --> deal (1 constraint(s)) =========
-- Requires: valuation schema, deal schema
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ADD CONSTRAINT `fk_valuation_valuation_review_origination_source_id` FOREIGN KEY (`origination_source_id`) REFERENCES `asset_management`.`deal`.`origination_source`(`origination_source_id`);

-- ========= valuation --> diligence (3 constraint(s)) =========
-- Requires: valuation schema, diligence schema
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ADD CONSTRAINT `fk_valuation_dcf_model_fdd_assessment_id` FOREIGN KEY (`fdd_assessment_id`) REFERENCES `asset_management`.`diligence`.`fdd_assessment`(`fdd_assessment_id`);
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ADD CONSTRAINT `fk_valuation_infrastructure_valuation_dd_engagement_id` FOREIGN KEY (`dd_engagement_id`) REFERENCES `asset_management`.`diligence`.`dd_engagement`(`dd_engagement_id`);
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ADD CONSTRAINT `fk_valuation_private_asset_valuation_dd_engagement_id` FOREIGN KEY (`dd_engagement_id`) REFERENCES `asset_management`.`diligence`.`dd_engagement`(`dd_engagement_id`);

-- ========= valuation --> esg (9 constraint(s)) =========
-- Requires: valuation schema, esg schema
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ADD CONSTRAINT `fk_valuation_credit_instrument_valuation_issuer_esg_rating_id` FOREIGN KEY (`issuer_esg_rating_id`) REFERENCES `asset_management`.`esg`.`issuer_esg_rating`(`issuer_esg_rating_id`);
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ADD CONSTRAINT `fk_valuation_dcf_model_climate_scenario_id` FOREIGN KEY (`climate_scenario_id`) REFERENCES `asset_management`.`esg`.`climate_scenario`(`climate_scenario_id`);
ALTER TABLE `asset_management`.`valuation`.`exclusion_screening` ADD CONSTRAINT `fk_valuation_exclusion_screening_exclusion_list_id` FOREIGN KEY (`exclusion_list_id`) REFERENCES `asset_management`.`esg`.`exclusion_list`(`exclusion_list_id`);
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ADD CONSTRAINT `fk_valuation_infrastructure_valuation_issuer_esg_rating_id` FOREIGN KEY (`issuer_esg_rating_id`) REFERENCES `asset_management`.`esg`.`issuer_esg_rating`(`issuer_esg_rating_id`);
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ADD CONSTRAINT `fk_valuation_private_asset_valuation_issuer_esg_rating_id` FOREIGN KEY (`issuer_esg_rating_id`) REFERENCES `asset_management`.`esg`.`issuer_esg_rating`(`issuer_esg_rating_id`);
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ADD CONSTRAINT `fk_valuation_real_estate_appraisal_taxonomy_alignment_id` FOREIGN KEY (`taxonomy_alignment_id`) REFERENCES `asset_management`.`esg`.`taxonomy_alignment`(`taxonomy_alignment_id`);
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ADD CONSTRAINT `fk_valuation_sensitivity_climate_scenario_id` FOREIGN KEY (`climate_scenario_id`) REFERENCES `asset_management`.`esg`.`climate_scenario`(`climate_scenario_id`);
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ADD CONSTRAINT `fk_valuation_valuation_asset_valuation_issuer_esg_rating_id` FOREIGN KEY (`issuer_esg_rating_id`) REFERENCES `asset_management`.`esg`.`issuer_esg_rating`(`issuer_esg_rating_id`);
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ADD CONSTRAINT `fk_valuation_wacc_calculation_climate_scenario_id` FOREIGN KEY (`climate_scenario_id`) REFERENCES `asset_management`.`esg`.`climate_scenario`(`climate_scenario_id`);

-- ========= valuation --> fee (1 constraint(s)) =========
-- Requires: valuation schema, fee schema
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ADD CONSTRAINT `fk_valuation_wacc_calculation_fee_calculation_run_id` FOREIGN KEY (`fee_calculation_run_id`) REFERENCES `asset_management`.`fee`.`fee_calculation_run`(`fee_calculation_run_id`);

-- ========= valuation --> infrastructure (1 constraint(s)) =========
-- Requires: valuation schema, infrastructure schema
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ADD CONSTRAINT `fk_valuation_infrastructure_valuation_infra_asset_id` FOREIGN KEY (`infra_asset_id`) REFERENCES `asset_management`.`infrastructure`.`infra_asset`(`infra_asset_id`);

-- ========= valuation --> manager (1 constraint(s)) =========
-- Requires: valuation schema, manager schema
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ADD CONSTRAINT `fk_valuation_indep_valuation_engagement_manager_mandate_id` FOREIGN KEY (`manager_mandate_id`) REFERENCES `asset_management`.`manager`.`manager_mandate`(`manager_mandate_id`);

-- ========= valuation --> portfolio (10 constraint(s)) =========
-- Requires: valuation schema, portfolio schema
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ADD CONSTRAINT `fk_valuation_credit_instrument_valuation_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ADD CONSTRAINT `fk_valuation_dcf_model_model_portfolio_id` FOREIGN KEY (`model_portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ADD CONSTRAINT `fk_valuation_infrastructure_valuation_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ADD CONSTRAINT `fk_valuation_nav_liability_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ADD CONSTRAINT `fk_valuation_private_asset_valuation_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ADD CONSTRAINT `fk_valuation_valuation_asset_valuation_asset_id` FOREIGN KEY (`asset_id`) REFERENCES `asset_management`.`portfolio`.`asset`(`asset_id`);
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ADD CONSTRAINT `fk_valuation_valuation_asset_valuation_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`valuation`.`valuation_document` ADD CONSTRAINT `fk_valuation_valuation_document_asset_id` FOREIGN KEY (`asset_id`) REFERENCES `asset_management`.`portfolio`.`asset`(`asset_id`);
ALTER TABLE `asset_management`.`valuation`.`valuation_document` ADD CONSTRAINT `fk_valuation_valuation_document_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ADD CONSTRAINT `fk_valuation_wacc_calculation_portfolio_id` FOREIGN KEY (`portfolio_id`) REFERENCES `asset_management`.`portfolio`.`portfolio`(`portfolio_id`);

-- ========= valuation --> privateequity (1 constraint(s)) =========
-- Requires: valuation schema, privateequity schema
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ADD CONSTRAINT `fk_valuation_nav_liability_fund_id` FOREIGN KEY (`fund_id`) REFERENCES `asset_management`.`privateequity`.`fund`(`fund_id`);

-- ========= valuation --> realestate (1 constraint(s)) =========
-- Requires: valuation schema, realestate schema
ALTER TABLE `asset_management`.`valuation`.`real_estate_appraisal` ADD CONSTRAINT `fk_valuation_real_estate_appraisal_property_id` FOREIGN KEY (`property_id`) REFERENCES `asset_management`.`realestate`.`property`(`property_id`);

-- ========= valuation --> research (9 constraint(s)) =========
-- Requires: valuation schema, research schema
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ADD CONSTRAINT `fk_valuation_broker_quote_data_vendor_id` FOREIGN KEY (`data_vendor_id`) REFERENCES `asset_management`.`research`.`data_vendor`(`data_vendor_id`);
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ADD CONSTRAINT `fk_valuation_credit_instrument_valuation_research_yield_curve_id` FOREIGN KEY (`research_yield_curve_id`) REFERENCES `asset_management`.`research`.`research_yield_curve`(`research_yield_curve_id`);
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ADD CONSTRAINT `fk_valuation_dcf_model_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ADD CONSTRAINT `fk_valuation_dcf_model_macro_model_id` FOREIGN KEY (`macro_model_id`) REFERENCES `asset_management`.`research`.`macro_model`(`macro_model_id`);
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ADD CONSTRAINT `fk_valuation_private_asset_valuation_economic_scenario_id` FOREIGN KEY (`economic_scenario_id`) REFERENCES `asset_management`.`research`.`economic_scenario`(`economic_scenario_id`);
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ADD CONSTRAINT `fk_valuation_sensitivity_macro_indicator_id` FOREIGN KEY (`macro_indicator_id`) REFERENCES `asset_management`.`research`.`macro_indicator`(`macro_indicator_id`);
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ADD CONSTRAINT `fk_valuation_valuation_review_analyst_assignment_id` FOREIGN KEY (`analyst_assignment_id`) REFERENCES `asset_management`.`research`.`analyst_assignment`(`analyst_assignment_id`);
ALTER TABLE `asset_management`.`valuation`.`valuation_yield_curve` ADD CONSTRAINT `fk_valuation_valuation_yield_curve_research_yield_curve_id` FOREIGN KEY (`research_yield_curve_id`) REFERENCES `asset_management`.`research`.`research_yield_curve`(`research_yield_curve_id`);
ALTER TABLE `asset_management`.`valuation`.`wacc_calculation` ADD CONSTRAINT `fk_valuation_wacc_calculation_capital_market_assumption_id` FOREIGN KEY (`capital_market_assumption_id`) REFERENCES `asset_management`.`research`.`capital_market_assumption`(`capital_market_assumption_id`);

-- ========= valuation --> risk (6 constraint(s)) =========
-- Requires: valuation schema, risk schema
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ADD CONSTRAINT `fk_valuation_credit_instrument_valuation_credit_rating_id` FOREIGN KEY (`credit_rating_id`) REFERENCES `asset_management`.`risk`.`credit_rating`(`credit_rating_id`);
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ADD CONSTRAINT `fk_valuation_dcf_model_stress_scenario_id` FOREIGN KEY (`stress_scenario_id`) REFERENCES `asset_management`.`risk`.`stress_scenario`(`stress_scenario_id`);
ALTER TABLE `asset_management`.`valuation`.`price_exception` ADD CONSTRAINT `fk_valuation_price_exception_limit_breach_id` FOREIGN KEY (`limit_breach_id`) REFERENCES `asset_management`.`risk`.`limit_breach`(`limit_breach_id`);
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ADD CONSTRAINT `fk_valuation_private_asset_valuation_model_id` FOREIGN KEY (`model_id`) REFERENCES `asset_management`.`risk`.`model`(`model_id`);
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ADD CONSTRAINT `fk_valuation_sensitivity_model_id` FOREIGN KEY (`model_id`) REFERENCES `asset_management`.`risk`.`model`(`model_id`);
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ADD CONSTRAINT `fk_valuation_valuation_asset_valuation_credit_rating_id` FOREIGN KEY (`credit_rating_id`) REFERENCES `asset_management`.`risk`.`credit_rating`(`credit_rating_id`);

-- ========= valuation --> shared (23 constraint(s)) =========
-- Requires: valuation schema, shared schema
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ADD CONSTRAINT `fk_valuation_comparable_transaction_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`valuation`.`comparable_transaction` ADD CONSTRAINT `fk_valuation_comparable_transaction_transaction_valuation_agent_legal_entity_id` FOREIGN KEY (`transaction_valuation_agent_legal_entity_id`) REFERENCES `asset_management`.`shared`.`legal_entity`(`legal_entity_id`);
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ADD CONSTRAINT `fk_valuation_credit_instrument_valuation_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`valuation`.`dcf_model` ADD CONSTRAINT `fk_valuation_dcf_model_model_created_by_employee_id` FOREIGN KEY (`model_created_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`valuation`.`exclusion_screening` ADD CONSTRAINT `fk_valuation_exclusion_screening_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`valuation`.`indep_valuation_engagement` ADD CONSTRAINT `fk_valuation_indep_valuation_engagement_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ADD CONSTRAINT `fk_valuation_infrastructure_valuation_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`valuation`.`infrastructure_valuation` ADD CONSTRAINT `fk_valuation_infrastructure_valuation_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`valuation`.`price_exception` ADD CONSTRAINT `fk_valuation_price_exception_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`valuation`.`private_asset_valuation` ADD CONSTRAINT `fk_valuation_private_asset_valuation_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`valuation`.`quote_source` ADD CONSTRAINT `fk_valuation_quote_source_vendor_id` FOREIGN KEY (`vendor_id`) REFERENCES `asset_management`.`shared`.`vendor`(`vendor_id`);
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ADD CONSTRAINT `fk_valuation_sensitivity_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`valuation`.`sensitivity` ADD CONSTRAINT `fk_valuation_sensitivity_created_by_employee_id` FOREIGN KEY (`created_by_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ADD CONSTRAINT `fk_valuation_valuation_asset_valuation_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`valuation`.`valuation_asset_valuation` ADD CONSTRAINT `fk_valuation_valuation_asset_valuation_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`valuation`.`valuation_document` ADD CONSTRAINT `fk_valuation_valuation_document_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `asset_management`.`shared`.`actor`(`actor_id`);
ALTER TABLE `asset_management`.`valuation`.`valuation_document` ADD CONSTRAINT `fk_valuation_valuation_document_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`valuation`.`valuation_document` ADD CONSTRAINT `fk_valuation_valuation_document_reviewed_by_analyst_employee_id` FOREIGN KEY (`reviewed_by_analyst_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`valuation`.`valuation_document` ADD CONSTRAINT `fk_valuation_valuation_document_superseded_document_id` FOREIGN KEY (`superseded_document_id`) REFERENCES `asset_management`.`shared`.`document`(`document_id`);
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ADD CONSTRAINT `fk_valuation_valuation_review_approver_employee_id` FOREIGN KEY (`approver_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ADD CONSTRAINT `fk_valuation_valuation_review_approver_id` FOREIGN KEY (`approver_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ADD CONSTRAINT `fk_valuation_valuation_review_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);
ALTER TABLE `asset_management`.`valuation`.`valuation_review` ADD CONSTRAINT `fk_valuation_valuation_review_valuation_employee_id` FOREIGN KEY (`valuation_employee_id`) REFERENCES `asset_management`.`shared`.`employee`(`employee_id`);

-- ========= valuation --> trade (5 constraint(s)) =========
-- Requires: valuation schema, trade schema
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ADD CONSTRAINT `fk_valuation_broker_quote_broker_id` FOREIGN KEY (`broker_id`) REFERENCES `asset_management`.`trade`.`broker`(`broker_id`);
ALTER TABLE `asset_management`.`valuation`.`broker_quote` ADD CONSTRAINT `fk_valuation_broker_quote_instrument_id` FOREIGN KEY (`instrument_id`) REFERENCES `asset_management`.`trade`.`instrument`(`instrument_id`);
ALTER TABLE `asset_management`.`valuation`.`credit_instrument_valuation` ADD CONSTRAINT `fk_valuation_credit_instrument_valuation_instrument_id` FOREIGN KEY (`instrument_id`) REFERENCES `asset_management`.`trade`.`instrument`(`instrument_id`);
ALTER TABLE `asset_management`.`valuation`.`market_price_snapshot` ADD CONSTRAINT `fk_valuation_market_price_snapshot_instrument_id` FOREIGN KEY (`instrument_id`) REFERENCES `asset_management`.`trade`.`instrument`(`instrument_id`);
ALTER TABLE `asset_management`.`valuation`.`price_exception` ADD CONSTRAINT `fk_valuation_price_exception_instrument_id` FOREIGN KEY (`instrument_id`) REFERENCES `asset_management`.`trade`.`instrument`(`instrument_id`);

-- ========= valuation --> treasury (1 constraint(s)) =========
-- Requires: valuation schema, treasury schema
ALTER TABLE `asset_management`.`valuation`.`nav_liability` ADD CONSTRAINT `fk_valuation_nav_liability_settlement_cash_account_id` FOREIGN KEY (`settlement_cash_account_id`) REFERENCES `asset_management`.`treasury`.`cash_account`(`cash_account_id`);
