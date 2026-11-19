-- Metric views for domain: sponsor | Business: Clinical_Trials | Version: 13 | Generated on: 2026-11-19 16:37:37

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`sponsor_account_plan`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Strategic account planning KPIs tracking revenue targets, relationship health, and account growth across sponsor portfolios."
  source: "`clinical_trials_ecm`.`sponsor`.`account_plan`"
  dimensions:
    - name: "Plan Status"
      display_name: "Status"
      expr: plan_status
      comment: "Current status of the account plan (draft, active, completed, archived)"
    - name: "Plan Type"
      display_name: "Type"
      expr: plan_type
      comment: "Type or category of account plan"
    - name: "Account Tier"
      display_name: "Account Tier"
      expr: account_tier
      comment: "Strategic tier classification of the account (Tier 1, Tier 2, Tier 3)"
    - name: "Preferred Provider Status"
      display_name: "Provider Status"
      expr: preferred_provider_status
      comment: "Preferred provider status for the account"
    - name: "Plan Year"
      display_name: "Plan Year"
      expr: plan_year
      comment: "Fiscal or calendar year for the account plan"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Plan Start Month"
      display_name: "Plan Start Month"
      expr: DATE_TRUNC('month', plan_start_date)
      comment: "Month bucket for plan start date"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Approval Month"
      display_name: "Approval Month"
      expr: DATE_TRUNC('month', approved_date)
      comment: "Month bucket for plan approval date"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Account Plans"
      display_name: "Total Plans"
      expr: COUNT(1)
      comment: "Total number of account plans"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Active Account Plans"
      display_name: "Active Plans"
      expr: COUNT(CASE WHEN plan_status = 'Active' THEN 1 END)
      comment: "Count of currently active account plans"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Revenue Target"
      display_name: "Total Revenue Target"
      expr: SUM(CAST(revenue_target_usd AS DOUBLE))
      comment: "Sum of revenue targets across all account plans"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Average Revenue Target"
      display_name: "Avg Revenue Target"
      expr: AVG(CAST(revenue_target_usd AS DOUBLE))
      comment: "Average revenue target per account plan"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Clinical Ops Revenue Target"
      display_name: "Clinical Ops Target"
      expr: SUM(CAST(clinical_ops_revenue_target_usd AS DOUBLE))
      comment: "Sum of clinical operations revenue targets"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Biostatistics Revenue Target"
      display_name: "Biostatistics Target"
      expr: SUM(CAST(biostatistics_revenue_target_usd AS DOUBLE))
      comment: "Sum of biostatistics revenue targets"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Data Management Revenue Target"
      display_name: "Data Mgmt Target"
      expr: SUM(CAST(data_management_revenue_target_usd AS DOUBLE))
      comment: "Sum of data management revenue targets"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Regulatory Affairs Revenue Target"
      display_name: "Regulatory Target"
      expr: SUM(CAST(regulatory_affairs_revenue_target_usd AS DOUBLE))
      comment: "Sum of regulatory affairs revenue targets"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Active Study Count Target"
      display_name: "Study Count Target"
      expr: SUM(CAST(active_study_count_target AS DOUBLE))
      comment: "Sum of active study count targets across all plans"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Pipeline Opportunity Value"
      display_name: "Pipeline Value"
      expr: SUM(CAST(pipeline_opportunity_value_usd AS DOUBLE))
      comment: "Sum of pipeline opportunity values across all plans"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Pipeline Opportunity Count"
      display_name: "Pipeline Count"
      expr: SUM(CAST(pipeline_opportunity_count AS DOUBLE))
      comment: "Sum of pipeline opportunity counts across all plans"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Average Relationship Health Score"
      display_name: "Avg Relationship Health"
      expr: AVG(CAST(relationship_health_score AS DOUBLE))
      comment: "Average relationship health score across all account plans"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Average Sponsor Satisfaction Score"
      display_name: "Avg Satisfaction Score"
      expr: AVG(CAST(sponsor_satisfaction_score AS DOUBLE))
      comment: "Average sponsor satisfaction score across all account plans"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Preferred Provider Rate"
      display_name: "Preferred Provider Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN preferred_provider_status = 'Preferred' THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of account plans with preferred provider status"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Tier 1 Account Rate"
      display_name: "Tier 1 Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN account_tier = 'Tier 1' THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of account plans classified as Tier 1"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Distinct Sponsors"
      display_name: "Distinct Sponsors"
      expr: COUNT(DISTINCT organization_id)
      comment: "Count of distinct sponsor organizations with account plans"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`sponsor_bid_request`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Bid and proposal performance KPIs tracking win rates, competitive positioning, and pipeline conversion across RFP opportunities."
  source: "`clinical_trials_ecm`.`sponsor`.`bid_request`"
  dimensions:
    - name: "Bid Status"
      display_name: "Bid Status"
      expr: bid_status
      comment: "Current status of the bid (submitted, awarded, lost, no-bid)"
    - name: "Study Phase"
      display_name: "Study Phase"
      expr: study_phase
      comment: "Clinical trial phase for the bid request"
    - name: "Study Type"
      display_name: "Study Type"
      expr: study_type
      comment: "Type of clinical study (interventional, observational, etc.)"
    - name: "Service Model"
      display_name: "Service Model"
      expr: service_model
      comment: "Service delivery model (FSP, full-service, hybrid)"
    - name: "Region Scope"
      display_name: "Region"
      expr: region_scope
      comment: "Geographic region scope for the bid"
    - name: "Is Resubmission"
      display_name: "Submission Type"
      expr: CASE WHEN is_resubmission = TRUE THEN 'Resubmission' ELSE 'Initial' END
      comment: "Whether this is a resubmission of a prior bid"
    - name: "Receipt Month"
      display_name: "Receipt Month"
      expr: DATE_TRUNC('month', receipt_date)
      comment: "Month bucket for RFP receipt date"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Award Month"
      display_name: "Award Month"
      expr: DATE_TRUNC('month', award_date)
      comment: "Month bucket for bid award date"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Receipt Year"
      display_name: "Receipt Year"
      expr: YEAR(receipt_date)
      comment: "Year the RFP was received"
      format:
        type: number
        decimal_places:
          type: all
  measures:
    - name: "Total Bid Requests"
      display_name: "Total Bids"
      expr: COUNT(1)
      comment: "Total number of bid requests received"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Bids Won"
      display_name: "Bids Won"
      expr: COUNT(CASE WHEN bid_status = 'Awarded' THEN 1 END)
      comment: "Count of bids awarded to the organization"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Bids Lost"
      display_name: "Bids Lost"
      expr: COUNT(CASE WHEN bid_status = 'Lost' THEN 1 END)
      comment: "Count of bids lost to competitors"
      format:
        type: number
        decimal_places:
          type: all
    - name: "No-Bid Count"
      display_name: "No-Bid Count"
      expr: COUNT(CASE WHEN bid_status = 'No-Bid' THEN 1 END)
      comment: "Count of RFPs declined (no-bid decision)"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Win Rate"
      display_name: "Win Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN bid_status = 'Awarded' THEN 1 END) / NULLIF(COUNT(CASE WHEN bid_status IN ('Awarded', 'Lost') THEN 1 END), 0), 2)
      comment: "Percentage of submitted bids that were won (excludes no-bids and pending)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "No-Bid Rate"
      display_name: "No-Bid Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN bid_status = 'No-Bid' THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of RFPs that resulted in a no-bid decision"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Estimated Budget"
      display_name: "Total Est. Budget"
      expr: SUM(CAST(estimated_budget_amount AS DOUBLE))
      comment: "Sum of estimated budget amounts across all bid requests"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Submitted Bid Amount"
      display_name: "Total Bid Amount"
      expr: SUM(CAST(submitted_bid_amount AS DOUBLE))
      comment: "Sum of submitted bid amounts across all proposals"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Won Bid Value"
      display_name: "Won Bid Value"
      expr: SUM(CASE WHEN bid_status = 'Awarded' THEN CAST(submitted_bid_amount AS DOUBLE) ELSE 0 END)
      comment: "Total value of bids that were awarded"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Average Bid Amount"
      display_name: "Avg Bid Amount"
      expr: AVG(CAST(submitted_bid_amount AS DOUBLE))
      comment: "Average submitted bid amount per request"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Average Win Probability"
      display_name: "Avg Win Probability"
      expr: AVG(CAST(win_probability_pct AS DOUBLE))
      comment: "Average win probability percentage across all bids"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Estimated Subject Count"
      display_name: "Total Est. Subjects"
      expr: SUM(CAST(estimated_subject_count AS DOUBLE))
      comment: "Sum of estimated subject counts across all bid requests"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Estimated Site Count"
      display_name: "Total Est. Sites"
      expr: SUM(CAST(estimated_site_count AS DOUBLE))
      comment: "Sum of estimated site counts across all bid requests"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Average Estimated Duration Months"
      display_name: "Avg Duration (Months)"
      expr: AVG(CAST(estimated_duration_months AS DOUBLE))
      comment: "Average estimated study duration in months"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Average Competing CRO Count"
      display_name: "Avg Competitors"
      expr: AVG(CAST(competing_cro_count AS DOUBLE))
      comment: "Average number of competing CROs per bid"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Distinct Sponsors"
      display_name: "Distinct Sponsors"
      expr: COUNT(DISTINCT organization_id)
      comment: "Count of distinct sponsor organizations issuing RFPs"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`sponsor_escalation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Sponsor escalation management KPIs tracking issue severity, resolution performance, and regulatory impact across sponsor relationships."
  source: "`clinical_trials_ecm`.`sponsor`.`escalation`"
  dimensions:
    - name: "Escalation Status"
      display_name: "Status"
      expr: escalation_status
      comment: "Current status of the escalation (open, in-progress, resolved, closed)"
    - name: "Severity Level"
      display_name: "Severity"
      expr: severity_level
      comment: "Severity classification of the escalation (critical, high, medium, low)"
    - name: "Priority"
      display_name: "Priority"
      expr: priority
      comment: "Priority level for resolution (urgent, high, normal, low)"
    - name: "Escalation Type"
      display_name: "Type"
      expr: escalation_type
      comment: "Type or category of escalation"
    - name: "Source"
      display_name: "Source"
      expr: source
      comment: "Source or origin of the escalation"
    - name: "Channel"
      display_name: "Channel"
      expr: channel
      comment: "Communication channel through which escalation was raised"
    - name: "Impacted Functional Area"
      display_name: "Functional Area"
      expr: impacted_functional_area
      comment: "Functional area impacted by the escalation"
    - name: "Root Cause Category"
      display_name: "Root Cause"
      expr: root_cause_category
      comment: "Root cause category classification"
    - name: "Is Safety Related"
      display_name: "Safety Flag"
      expr: CASE WHEN is_safety_related = TRUE THEN 'Safety-Related' ELSE 'Non-Safety' END
      comment: "Whether the escalation is safety-related"
    - name: "Is Regulatory Reportable"
      display_name: "Regulatory Reportable"
      expr: CASE WHEN is_regulatory_reportable = TRUE THEN 'Reportable' ELSE 'Non-Reportable' END
      comment: "Whether the escalation is regulatory reportable"
    - name: "Governance Review Required"
      display_name: "Governance Review"
      expr: CASE WHEN governance_review_required = TRUE THEN 'Required' ELSE 'Not Required' END
      comment: "Whether governance review is required"
    - name: "Escalation Month"
      display_name: "Escalation Month"
      expr: DATE_TRUNC('month', escalation_date)
      comment: "Month bucket for escalation date"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Resolution Month"
      display_name: "Resolution Month"
      expr: DATE_TRUNC('month', actual_resolution_date)
      comment: "Month bucket for actual resolution date"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Escalations"
      display_name: "Total Escalations"
      expr: COUNT(1)
      comment: "Total number of escalations raised"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Open Escalations"
      display_name: "Open Escalations"
      expr: COUNT(CASE WHEN escalation_status IN ('Open', 'In-Progress') THEN 1 END)
      comment: "Count of escalations currently open or in-progress"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Resolved Escalations"
      display_name: "Resolved Escalations"
      expr: COUNT(CASE WHEN escalation_status IN ('Resolved', 'Closed') THEN 1 END)
      comment: "Count of escalations that have been resolved or closed"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Critical Escalations"
      display_name: "Critical Escalations"
      expr: COUNT(CASE WHEN severity_level = 'Critical' THEN 1 END)
      comment: "Count of escalations with critical severity"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Safety-Related Escalations"
      display_name: "Safety Escalations"
      expr: COUNT(CASE WHEN is_safety_related = TRUE THEN 1 END)
      comment: "Count of escalations that are safety-related"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Regulatory Reportable Escalations"
      display_name: "Reportable Escalations"
      expr: COUNT(CASE WHEN is_regulatory_reportable = TRUE THEN 1 END)
      comment: "Count of escalations that are regulatory reportable"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Financial Impact"
      display_name: "Total Financial Impact"
      expr: SUM(CAST(financial_impact_usd AS DOUBLE))
      comment: "Sum of financial impact across all escalations"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Average Financial Impact"
      display_name: "Avg Financial Impact"
      expr: AVG(CAST(financial_impact_usd AS DOUBLE))
      comment: "Average financial impact per escalation"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Timeline Impact Days"
      display_name: "Total Timeline Impact (Days)"
      expr: SUM(CAST(timeline_impact_days AS DOUBLE))
      comment: "Sum of timeline impact in days across all escalations"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Average Timeline Impact Days"
      display_name: "Avg Timeline Impact (Days)"
      expr: AVG(CAST(timeline_impact_days AS DOUBLE))
      comment: "Average timeline impact in days per escalation"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Resolution Rate"
      display_name: "Resolution Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN escalation_status IN ('Resolved', 'Closed') THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of escalations that have been resolved or closed"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Critical Escalation Rate"
      display_name: "Critical Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN severity_level = 'Critical' THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of escalations classified as critical severity"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Safety-Related Rate"
      display_name: "Safety Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN is_safety_related = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of escalations that are safety-related"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Recurrence Rate"
      display_name: "Recurrence Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN recurrence_flag = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of escalations that are recurrences of prior issues"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Distinct Sponsors"
      display_name: "Distinct Sponsors"
      expr: COUNT(DISTINCT organization_id)
      comment: "Count of distinct sponsor organizations with escalations"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Studies"
      display_name: "Distinct Studies"
      expr: COUNT(DISTINCT study_id)
      comment: "Count of distinct studies with escalations"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`sponsor_master_agreement`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Master agreement performance KPIs tracking contract value, pricing effectiveness, and strategic partnership terms across sponsor relationships."
  source: "`clinical_trials_ecm`.`sponsor`.`master_agreement`"
  dimensions:
    - name: "Agreement Status"
      display_name: "Agreement Status"
      expr: agreement_status
      comment: "Current status of the master agreement (draft, active, expired, terminated)"
    - name: "Agreement Type"
      display_name: "Agreement Type"
      expr: agreement_type
      comment: "Type of master agreement (MSA, preferred provider, strategic partnership)"
    - name: "Strategic Partnership Level"
      display_name: "Partnership Level"
      expr: strategic_partnership_level
      comment: "Strategic partnership tier (platinum, gold, silver, standard)"
    - name: "Volume Commitment Tier"
      display_name: "Volume Commitment Tier"
      expr: volume_commitment_tier
      comment: "Volume commitment tier classification"
    - name: "Geographic Scope"
      display_name: "Geographic Scope"
      expr: geographic_scope
      comment: "Geographic scope of the agreement (global, regional, country-specific)"
    - name: "Effective Year"
      display_name: "Effective Year"
      expr: YEAR(effective_date)
      comment: "Year the agreement became effective"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Effective Month"
      display_name: "Effective Month"
      expr: DATE_TRUNC('month', effective_date)
      comment: "Month bucket for agreement effective date"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Master Agreements"
      display_name: "Total Master Agreements"
      expr: COUNT(1)
      comment: "Total number of master agreements"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Active Master Agreements"
      display_name: "Active Master Agreements"
      expr: COUNT(CASE WHEN agreement_status = 'Active' THEN 1 END)
      comment: "Count of active master agreements"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Minimum Volume Commitment"
      display_name: "Total Min Volume Commitment"
      expr: SUM(CAST(minimum_volume_commitment_usd AS DOUBLE))
      comment: "Sum of minimum volume commitments across all agreements"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Minimum Volume Commitment"
      display_name: "Avg Min Volume Commitment"
      expr: AVG(CAST(minimum_volume_commitment_usd AS DOUBLE))
      comment: "Average minimum volume commitment per agreement"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Preferred Pricing Discount"
      display_name: "Avg Preferred Discount %"
      expr: AVG(CAST(preferred_pricing_discount_pct AS DOUBLE))
      comment: "Average preferred pricing discount percentage across agreements"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Indemnification Cap"
      display_name: "Total Indemnification Cap"
      expr: SUM(CAST(indemnification_cap_usd AS DOUBLE))
      comment: "Sum of indemnification caps across all agreements"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Initial Term Months"
      display_name: "Avg Initial Term (Months)"
      expr: AVG(CAST(initial_term_months AS DOUBLE))
      comment: "Average initial term in months across agreements"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Renewal Term Months"
      display_name: "Avg Renewal Term (Months)"
      expr: AVG(CAST(renewal_term_months AS DOUBLE))
      comment: "Average renewal term in months across agreements"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Amendment Count"
      display_name: "Avg Amendment Count"
      expr: AVG(CAST(amendment_count AS DOUBLE))
      comment: "Average number of amendments per agreement"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Agreements With Audit Rights"
      display_name: "Audit Rights Count"
      expr: COUNT(CASE WHEN audit_rights_flag = TRUE THEN 1 END)
      comment: "Count of agreements with audit rights provisions"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Audit Rights Rate"
      display_name: "Audit Rights %"
      expr: ROUND(100.0 * COUNT(CASE WHEN audit_rights_flag = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of agreements with audit rights provisions"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Agreements With Force Majeure"
      display_name: "Force Majeure Count"
      expr: COUNT(CASE WHEN force_majeure_clause_flag = TRUE THEN 1 END)
      comment: "Count of agreements with force majeure clauses"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`sponsor_pipeline_asset`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Pipeline asset development KPIs tracking compound progression, regulatory milestones, and development phase transitions across sponsor portfolios."
  source: "`clinical_trials_ecm`.`sponsor`.`pipeline_asset`"
  dimensions:
    - name: "Asset Status"
      display_name: "Status"
      expr: asset_status
      comment: "Current development status of the pipeline asset"
    - name: "Development Phase"
      display_name: "Phase"
      expr: development_phase
      comment: "Current development phase (preclinical, Phase I, Phase II, Phase III, NDA/BLA)"
    - name: "Filing Status"
      display_name: "Filing Status"
      expr: filing_status
      comment: "Regulatory filing status of the asset"
    - name: "Drug Class"
      display_name: "Drug Class"
      expr: drug_class
      comment: "Therapeutic drug class classification"
    - name: "Modality"
      display_name: "Modality"
      expr: modality
      comment: "Drug modality (small molecule, biologic, gene therapy, etc.)"
    - name: "Route of Administration"
      display_name: "Route"
      expr: route_of_administration
      comment: "Route of administration for the asset"
    - name: "Dosage Form"
      display_name: "Dosage Form"
      expr: dosage_form
      comment: "Dosage form of the asset"
    - name: "Primary Regulatory Authority"
      display_name: "Regulatory Authority"
      expr: primary_regulatory_authority
      comment: "Primary regulatory authority overseeing the asset"
    - name: "Orphan Drug Designation"
      display_name: "Orphan Status"
      expr: CASE WHEN orphan_drug_designation = TRUE THEN 'Orphan' ELSE 'Non-Orphan' END
      comment: "Whether the asset has orphan drug designation"
    - name: "Fast Track Designation"
      display_name: "Fast Track"
      expr: CASE WHEN fast_track_designation = TRUE THEN 'Fast Track' ELSE 'Standard' END
      comment: "Whether the asset has fast track designation"
    - name: "Breakthrough Therapy Designation"
      display_name: "Breakthrough"
      expr: CASE WHEN breakthrough_therapy_designation = TRUE THEN 'Breakthrough' ELSE 'Standard' END
      comment: "Whether the asset has breakthrough therapy designation"
    - name: "Approval Year"
      display_name: "Approval Year"
      expr: YEAR(approval_date)
      comment: "Year the asset was approved"
      format:
        type: number
        decimal_places:
          type: all
    - name: "IND Submission Month"
      display_name: "IND Submission Month"
      expr: DATE_TRUNC('month', ind_submission_date)
      comment: "Month bucket for IND submission date"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Pipeline Assets"
      display_name: "Total Assets"
      expr: COUNT(1)
      comment: "Total number of pipeline assets"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Active Pipeline Assets"
      display_name: "Active Assets"
      expr: COUNT(CASE WHEN asset_status = 'Active' THEN 1 END)
      comment: "Count of currently active pipeline assets"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Approved Assets"
      display_name: "Approved Assets"
      expr: COUNT(CASE WHEN asset_status = 'Approved' THEN 1 END)
      comment: "Count of approved pipeline assets"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Discontinued Assets"
      display_name: "Discontinued Assets"
      expr: COUNT(CASE WHEN asset_status = 'Discontinued' THEN 1 END)
      comment: "Count of discontinued pipeline assets"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Phase I Assets"
      display_name: "Phase I Assets"
      expr: COUNT(CASE WHEN development_phase = 'Phase I' THEN 1 END)
      comment: "Count of assets in Phase I development"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Phase II Assets"
      display_name: "Phase II Assets"
      expr: COUNT(CASE WHEN development_phase = 'Phase II' THEN 1 END)
      comment: "Count of assets in Phase II development"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Phase III Assets"
      display_name: "Phase III Assets"
      expr: COUNT(CASE WHEN development_phase = 'Phase III' THEN 1 END)
      comment: "Count of assets in Phase III development"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Active Studies"
      display_name: "Total Active Studies"
      expr: SUM(CAST(active_study_count AS DOUBLE))
      comment: "Sum of active study counts across all pipeline assets"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Average Active Studies Per Asset"
      display_name: "Avg Studies Per Asset"
      expr: AVG(CAST(active_study_count AS DOUBLE))
      comment: "Average number of active studies per pipeline asset"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Orphan Drug Designation Rate"
      display_name: "Orphan Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN orphan_drug_designation = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of assets with orphan drug designation"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Fast Track Designation Rate"
      display_name: "Fast Track Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN fast_track_designation = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of assets with fast track designation"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Breakthrough Therapy Designation Rate"
      display_name: "Breakthrough Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN breakthrough_therapy_designation = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of assets with breakthrough therapy designation"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Accelerated Approval Rate"
      display_name: "Accelerated Approval Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN accelerated_approval = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of assets with accelerated approval"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Discontinuation Rate"
      display_name: "Discontinuation Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN asset_status = 'Discontinued' THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of assets that have been discontinued"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Distinct Sponsors"
      display_name: "Distinct Sponsors"
      expr: COUNT(DISTINCT organization_id)
      comment: "Count of distinct sponsor organizations with pipeline assets"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Therapeutic Areas"
      display_name: "Distinct Therapeutic Areas"
      expr: COUNT(DISTINCT therapeutic_area_id)
      comment: "Count of distinct therapeutic areas represented in the pipeline"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`sponsor_proposal`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Proposal and pricing performance KPIs tracking proposal volume, pricing strategy, and conversion effectiveness across sponsor opportunities."
  source: "`clinical_trials_ecm`.`sponsor`.`proposal`"
  dimensions:
    - name: "Proposal Status"
      display_name: "Status"
      expr: proposal_status
      comment: "Current status of the proposal (draft, submitted, awarded, lost)"
    - name: "Proposal Type"
      display_name: "Type"
      expr: proposal_type
      comment: "Type or category of proposal"
    - name: "Study Phase"
      display_name: "Phase"
      expr: phase
      comment: "Clinical trial phase for the proposal"
    - name: "Pricing Model"
      display_name: "Pricing Model"
      expr: pricing_model
      comment: "Pricing model used (fixed-price, time-and-materials, hybrid)"
    - name: "Payment Schedule Type"
      display_name: "Payment Schedule"
      expr: payment_schedule_type
      comment: "Type of payment schedule (milestone-based, monthly, quarterly)"
    - name: "Is Competitive Bid"
      display_name: "Bid Type"
      expr: CASE WHEN is_competitive_bid = TRUE THEN 'Competitive' ELSE 'Sole-Source' END
      comment: "Whether this is a competitive bid or sole-source"
    - name: "Is Rebid"
      display_name: "Rebid Flag"
      expr: CASE WHEN is_rebid = TRUE THEN 'Rebid' ELSE 'Initial' END
      comment: "Whether this is a rebid of a prior proposal"
    - name: "Submission Month"
      display_name: "Submission Month"
      expr: DATE_TRUNC('month', submission_date)
      comment: "Month bucket for proposal submission date"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Award Month"
      display_name: "Award Month"
      expr: DATE_TRUNC('month', award_date)
      comment: "Month bucket for proposal award date"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Submission Year"
      display_name: "Submission Year"
      expr: YEAR(submission_date)
      comment: "Year the proposal was submitted"
      format:
        type: number
        decimal_places:
          type: all
  measures:
    - name: "Total Proposals"
      display_name: "Total Proposals"
      expr: COUNT(1)
      comment: "Total number of proposals submitted"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Proposals Awarded"
      display_name: "Awarded Proposals"
      expr: COUNT(CASE WHEN proposal_status = 'Awarded' THEN 1 END)
      comment: "Count of proposals that were awarded"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Proposals Lost"
      display_name: "Lost Proposals"
      expr: COUNT(CASE WHEN proposal_status = 'Lost' THEN 1 END)
      comment: "Count of proposals that were lost"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Proposal Win Rate"
      display_name: "Win Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN proposal_status = 'Awarded' THEN 1 END) / NULLIF(COUNT(CASE WHEN proposal_status IN ('Awarded', 'Lost') THEN 1 END), 0), 2)
      comment: "Percentage of submitted proposals that were awarded (excludes pending)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Proposed Budget"
      display_name: "Total Proposed Budget"
      expr: SUM(CAST(total_proposed_budget AS DOUBLE))
      comment: "Sum of total proposed budget amounts across all proposals"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Won Proposal Value"
      display_name: "Won Proposal Value"
      expr: SUM(CASE WHEN proposal_status = 'Awarded' THEN CAST(total_proposed_budget AS DOUBLE) ELSE 0 END)
      comment: "Total value of proposals that were awarded"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Average Proposed Budget"
      display_name: "Avg Proposed Budget"
      expr: AVG(CAST(total_proposed_budget AS DOUBLE))
      comment: "Average proposed budget per proposal"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Direct Cost"
      display_name: "Total Direct Cost"
      expr: SUM(CAST(direct_cost_total AS DOUBLE))
      comment: "Sum of direct costs across all proposals"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Pass-Through Cost"
      display_name: "Total Pass-Through Cost"
      expr: SUM(CAST(pass_through_cost_total AS DOUBLE))
      comment: "Sum of pass-through costs across all proposals"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Average Win Probability"
      display_name: "Avg Win Probability"
      expr: AVG(CAST(win_probability_pct AS DOUBLE))
      comment: "Average win probability percentage across all proposals"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Proposed Subject Count"
      display_name: "Total Proposed Subjects"
      expr: SUM(CAST(proposed_subject_count AS DOUBLE))
      comment: "Sum of proposed subject counts across all proposals"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Proposed Site Count"
      display_name: "Total Proposed Sites"
      expr: SUM(CAST(proposed_site_count AS DOUBLE))
      comment: "Sum of proposed site counts across all proposals"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Average Study Duration Months"
      display_name: "Avg Duration (Months)"
      expr: AVG(CAST(study_duration_months AS DOUBLE))
      comment: "Average proposed study duration in months"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Average Proposed Country Count"
      display_name: "Avg Country Count"
      expr: AVG(CAST(proposed_country_count AS DOUBLE))
      comment: "Average number of countries per proposal"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Competitive Bid Rate"
      display_name: "Competitive Bid Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN is_competitive_bid = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of proposals that are competitive bids"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Rebid Rate"
      display_name: "Rebid Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN is_rebid = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of proposals that are rebids"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Distinct Sponsors"
      display_name: "Distinct Sponsors"
      expr: COUNT(DISTINCT organization_id)
      comment: "Count of distinct sponsor organizations receiving proposals"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`sponsor_engagement`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Strategic sponsor engagement KPIs tracking relationship health, revenue performance, and governance effectiveness across sponsor partnerships."
  source: "`clinical_trials_ecm`.`sponsor`.`sponsor_engagement`"
  parameters:
    - name: p_target_currency
      data_type: STRING
      default: "'USD'"
  dimensions:
    - name: "Engagement Code"
      display_name: "Engagement Code"
      expr: engagement_code
      comment: "Unique identifier code for the sponsor engagement"
    - name: "Engagement Type"
      display_name: "Engagement Type"
      expr: engagement_type
      comment: "Classification of engagement model (e.g., strategic partnership, transactional, preferred provider)"
    - name: "Engagement Status"
      display_name: "Status"
      expr: sponsor_engagement_status
      comment: "Current lifecycle status of the engagement (active, on-hold, closed)"
    - name: "Strategic Account Tier"
      display_name: "Account Tier"
      expr: strategic_account_tier
      comment: "Sponsor account tier classification (Tier 1 strategic, Tier 2, Tier 3)"
    - name: "Primary Geography"
      display_name: "Geography"
      expr: primary_geography
      comment: "Primary geographic region for the engagement"
    - name: "Preferred Provider Flag"
      display_name: "Provider Status"
      expr: CASE WHEN preferred_provider_flag = TRUE THEN 'Preferred' ELSE 'Standard' END
      comment: "Whether this is a preferred provider relationship"
    - name: "Start Year"
      display_name: "Start Year"
      expr: YEAR(start_date)
      comment: "Year the engagement started"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Start Month"
      display_name: "Start Month"
      expr: DATE_TRUNC('month', start_date)
      comment: "Month bucket for engagement start date"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Governance Review Month"
      display_name: "Last Governance Month"
      expr: DATE_TRUNC('month', last_governance_date)
      comment: "Month bucket for last governance review"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Engagements"
      display_name: "Total Engagements"
      expr: COUNT(1)
      comment: "Total number of sponsor engagements"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Active Engagements"
      display_name: "Active Engagements"
      expr: COUNT(CASE WHEN sponsor_engagement_status = 'Active' THEN 1 END)
      comment: "Count of currently active sponsor engagements"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Contracted Value"
      display_name: "Total Contracted Value"
      expr: SUM(CAST(total_contracted_value AS DOUBLE))
      comment: "Sum of total contracted value across all engagements"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Average Contracted Value"
      display_name: "Avg Contracted Value"
      expr: AVG(CAST(total_contracted_value AS DOUBLE))
      comment: "Average contracted value per engagement"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Revenue Target"
      display_name: "Total Revenue Target"
      expr: SUM(CAST(annual_revenue_target AS DOUBLE))
      comment: "Sum of annual revenue targets across engagements"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Average Relationship Health Score"
      display_name: "Avg Relationship Health"
      expr: AVG(CAST(relationship_health_score AS DOUBLE))
      comment: "Average relationship health score across engagements (0-100 scale)"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Average Sponsor Satisfaction Score"
      display_name: "Avg Satisfaction Score"
      expr: AVG(CAST(sponsor_satisfaction_score AS DOUBLE))
      comment: "Average sponsor satisfaction score across engagements"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Active Studies"
      display_name: "Total Active Studies"
      expr: SUM(CAST(active_study_count AS DOUBLE))
      comment: "Sum of active studies across all engagements"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Average Active Studies Per Engagement"
      display_name: "Avg Studies Per Engagement"
      expr: AVG(CAST(active_study_count AS DOUBLE))
      comment: "Average number of active studies per engagement"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Total Escalations YTD"
      display_name: "Total Escalations YTD"
      expr: SUM(CAST(escalation_count_ytd AS DOUBLE))
      comment: "Sum of year-to-date escalations across all engagements"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Escalation Rate Per Engagement"
      display_name: "Avg Escalations Per Engagement"
      expr: AVG(CAST(escalation_count_ytd AS DOUBLE))
      comment: "Average escalation count per engagement year-to-date"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Pipeline Opportunity Value"
      display_name: "Total Pipeline Value"
      expr: SUM(CAST(pipeline_opportunity_value AS DOUBLE))
      comment: "Sum of pipeline opportunity value across engagements"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Preferred Provider Engagement Rate"
      display_name: "Preferred Provider Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN preferred_provider_flag = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of engagements with preferred provider status"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Engagement Health Score Above 80 Rate"
      display_name: "Healthy Engagement Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN relationship_health_score >= 80 THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of engagements with relationship health score of 80 or above"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Distinct Sponsors"
      display_name: "Distinct Sponsors"
      expr: COUNT(DISTINCT organization_id)
      comment: "Count of distinct sponsor organizations with engagements"
      format:
        type: number
        decimal_places:
          type: all
$$;
