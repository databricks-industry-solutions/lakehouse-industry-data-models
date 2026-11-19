-- Metric views for domain: agreement | Business: Clinical_Trials | Version: 13 | Generated on: 2026-11-19 16:37:37

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`agreement_billing_milestone`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Financial milestone tracking for study contracts: milestone value, payment status, enrollment and visit targets, and revenue recognition performance."
  source: "`clinical_trials_ecm`.`agreement`.`agreement_billing_milestone`"
  parameters:
    - name: p_target_currency
      data_type: STRING
      default: "'USD'"
  dimensions:
    - name: "milestone_type"
      display_name: "Milestone Type"
      expr: milestone_type
      comment: "Type of billing milestone (enrollment, visit, deliverable, regulatory, etc.)"
    - name: "billing_status"
      display_name: "Billing Status"
      expr: billing_status
      comment: "Current billing status (pending, invoiced, paid, disputed, etc.)"
    - name: "approval_status"
      display_name: "Approval Status"
      expr: approval_status
      comment: "Approval status of the milestone (pending, approved, rejected)"
    - name: "functional_area"
      display_name: "Functional Area"
      expr: functional_area
      comment: "Functional area responsible for the milestone (clinical ops, data management, regulatory, etc.)"
    - name: "revenue_recognition_method"
      display_name: "Revenue Recognition Method"
      expr: revenue_recognition_method
      comment: "Method used for revenue recognition (milestone, percentage-of-completion, etc.)"
    - name: "planned_trigger_year"
      display_name: "Planned Trigger Year"
      expr: DATE_TRUNC('year', planned_trigger_date)
      comment: "Year when milestone is planned to trigger"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "planned_trigger_quarter"
      display_name: "Planned Trigger Quarter"
      expr: DATE_TRUNC('quarter', planned_trigger_date)
      comment: "Quarter when milestone is planned to trigger"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "planned_trigger_month"
      display_name: "Planned Trigger Month"
      expr: DATE_TRUNC('month', planned_trigger_date)
      comment: "Month when milestone is planned to trigger"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "invoice_year"
      display_name: "Invoice Year"
      expr: DATE_TRUNC('year', invoice_date)
      comment: "Year when milestone was invoiced"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "invoice_month"
      display_name: "Invoice Month"
      expr: DATE_TRUNC('month', invoice_date)
      comment: "Month when milestone was invoiced"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "milestone_count"
      display_name: "Milestone Count"
      expr: COUNT(1)
      comment: "Total number of billing milestones"
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_milestone_amount"
      display_name: "Total Milestone Amount"
      expr: SUM(CAST(milestone_amount AS DOUBLE))
      comment: "Sum of all milestone amounts in contract currency"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_adjusted_amount"
      display_name: "Total Adjusted Amount"
      expr: SUM(CAST(adjusted_amount AS DOUBLE))
      comment: "Sum of adjusted milestone amounts after change orders or disputes"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_milestone_amount"
      display_name: "Average Milestone Amount"
      expr: AVG(CAST(milestone_amount AS DOUBLE))
      comment: "Average milestone value across all milestones"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_enrollment_target"
      display_name: "Total Enrollment Target"
      expr: SUM(CAST(enrollment_target_count AS DOUBLE))
      comment: "Sum of enrollment targets across enrollment-based milestones"
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_visit_target"
      display_name: "Total Visit Target"
      expr: SUM(CAST(visit_count_target AS DOUBLE))
      comment: "Sum of visit count targets across visit-based milestones"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_percent_complete"
      display_name: "Average Percent Complete"
      expr: AVG(CAST(percent_complete AS DOUBLE))
      comment: "Average completion percentage across all milestones"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "milestone_value_at_risk"
      display_name: "Milestone Value at Risk"
      expr: SUM(CASE WHEN billing_status = 'disputed' THEN CAST(milestone_amount AS DOUBLE) ELSE 0 END)
      comment: "Total value of milestones currently in dispute"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "overdue_milestone_count"
      display_name: "Overdue Milestone Count"
      expr: COUNT(CASE WHEN payment_due_date < CURRENT_DATE() AND billing_status NOT IN ('paid', 'cancelled') THEN 1 END)
      comment: "Number of milestones past their payment due date and not yet paid"
      format:
        type: number
        decimal_places:
          type: all
    - name: "paid_milestone_count"
      display_name: "Paid Milestone Count"
      expr: COUNT(CASE WHEN billing_status = 'paid' THEN 1 END)
      comment: "Number of milestones that have been paid"
      format:
        type: number
        decimal_places:
          type: all
    - name: "payment_cycle_days_avg"
      display_name: "Average Payment Cycle Days"
      expr: AVG(DATEDIFF(payment_received_date, invoice_date))
      comment: "Average number of days from invoice to payment receipt"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`agreement_change_order`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Contract change order tracking: scope changes, budget impact, timeline extensions, and approval workflow performance for study contracts."
  source: "`clinical_trials_ecm`.`agreement`.`change_order`"
  dimensions:
    - name: "change_type"
      display_name: "Change Type"
      expr: change_type
      comment: "Type of change order (scope, budget, timeline, regulatory, etc.)"
    - name: "co_status"
      display_name: "Change Order Status"
      expr: co_status
      comment: "Current status of the change order (draft, pending, approved, rejected, executed)"
    - name: "change_reason"
      display_name: "Change Reason"
      expr: change_reason
      comment: "Primary reason for the change order"
    - name: "priority"
      display_name: "Priority"
      expr: priority
      comment: "Priority level of the change order (high, medium, low)"
    - name: "regulatory_driven_flag"
      display_name: "Regulatory Driven"
      expr: regulatory_driven_flag
      comment: "Whether the change order was driven by regulatory requirements"
    - name: "initiation_year"
      display_name: "Initiation Year"
      expr: DATE_TRUNC('year', initiation_date)
      comment: "Year when change order was initiated"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "initiation_quarter"
      display_name: "Initiation Quarter"
      expr: DATE_TRUNC('quarter', initiation_date)
      comment: "Quarter when change order was initiated"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "initiation_month"
      display_name: "Initiation Month"
      expr: DATE_TRUNC('month', initiation_date)
      comment: "Month when change order was initiated"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "change_order_count"
      display_name: "Change Order Count"
      expr: COUNT(1)
      comment: "Total number of change orders"
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_delta_value"
      display_name: "Total Delta Value"
      expr: SUM(CAST(delta_value AS DOUBLE))
      comment: "Sum of all contract value changes from change orders"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_delta_value"
      display_name: "Average Delta Value"
      expr: AVG(CAST(delta_value AS DOUBLE))
      comment: "Average contract value change per change order"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_service_fee_delta"
      display_name: "Total Service Fee Delta"
      expr: SUM(CAST(service_fee_delta AS DOUBLE))
      comment: "Sum of service fee changes from change orders"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_pass_through_delta"
      display_name: "Total Pass-Through Delta"
      expr: SUM(CAST(pass_through_delta AS DOUBLE))
      comment: "Sum of pass-through cost changes from change orders"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_timeline_extension_days"
      display_name: "Total Timeline Extension Days"
      expr: SUM(CAST(timeline_extension_days AS DOUBLE))
      comment: "Sum of timeline extensions in days across all change orders"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_timeline_extension_days"
      display_name: "Average Timeline Extension Days"
      expr: AVG(CAST(timeline_extension_days AS DOUBLE))
      comment: "Average timeline extension per change order"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "total_site_count_delta"
      display_name: "Total Site Count Delta"
      expr: SUM(CAST(site_count_delta AS DOUBLE))
      comment: "Net change in site count from all change orders"
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_subject_count_delta"
      display_name: "Total Subject Count Delta"
      expr: SUM(CAST(subject_count_delta AS DOUBLE))
      comment: "Net change in subject count from all change orders"
      format:
        type: number
        decimal_places:
          type: all
    - name: "approved_co_count"
      display_name: "Approved Change Order Count"
      expr: COUNT(CASE WHEN co_status = 'approved' THEN 1 END)
      comment: "Number of change orders that have been approved"
      format:
        type: number
        decimal_places:
          type: all
    - name: "rejected_co_count"
      display_name: "Rejected Change Order Count"
      expr: COUNT(CASE WHEN co_status = 'rejected' THEN 1 END)
      comment: "Number of change orders that have been rejected"
      format:
        type: number
        decimal_places:
          type: all
    - name: "regulatory_driven_co_count"
      display_name: "Regulatory-Driven Change Order Count"
      expr: COUNT(CASE WHEN regulatory_driven_flag = TRUE THEN 1 END)
      comment: "Number of change orders driven by regulatory requirements"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_approval_cycle_days"
      display_name: "Average Approval Cycle Days"
      expr: AVG(DATEDIFF(sponsor_approval_date, initiation_date))
      comment: "Average number of days from initiation to sponsor approval"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`agreement_contract_negotiation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Contract negotiation efficiency: cycle time, round count, escalation rate, and value negotiated across study contracts and MSAs."
  source: "`clinical_trials_ecm`.`agreement`.`contract_negotiation`"
  dimensions:
    - name: "negotiation_status"
      display_name: "Negotiation Status"
      expr: negotiation_status
      comment: "Current status of the negotiation (active, completed, stalled, terminated)"
    - name: "negotiation_type"
      display_name: "Negotiation Type"
      expr: negotiation_type
      comment: "Type of negotiation (new contract, amendment, renewal, etc.)"
    - name: "priority_level"
      display_name: "Priority Level"
      expr: priority_level
      comment: "Priority level of the negotiation (high, medium, low)"
    - name: "payment_model"
      display_name: "Payment Model"
      expr: payment_model
      comment: "Payment model being negotiated (fixed-price, time-and-materials, milestone-based, etc.)"
    - name: "escalation_flag"
      display_name: "Escalation Flag"
      expr: escalation_flag
      comment: "Whether the negotiation has been escalated"
    - name: "negotiation_start_year"
      display_name: "Negotiation Start Year"
      expr: DATE_TRUNC('year', negotiation_start_date)
      comment: "Year when negotiation started"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "negotiation_start_quarter"
      display_name: "Negotiation Start Quarter"
      expr: DATE_TRUNC('quarter', negotiation_start_date)
      comment: "Quarter when negotiation started"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "negotiation_start_month"
      display_name: "Negotiation Start Month"
      expr: DATE_TRUNC('month', negotiation_start_date)
      comment: "Month when negotiation started"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "negotiation_count"
      display_name: "Negotiation Count"
      expr: COUNT(1)
      comment: "Total number of contract negotiations"
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_negotiated_value"
      display_name: "Total Negotiated Value"
      expr: SUM(CAST(negotiated_contract_value AS DOUBLE))
      comment: "Sum of negotiated contract values"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_negotiated_value"
      display_name: "Average Negotiated Value"
      expr: AVG(CAST(negotiated_contract_value AS DOUBLE))
      comment: "Average negotiated contract value per negotiation"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_service_fee_value"
      display_name: "Total Service Fee Value"
      expr: SUM(CAST(service_fee_value AS DOUBLE))
      comment: "Sum of service fee values negotiated"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_pass_through_value"
      display_name: "Total Pass-Through Value"
      expr: SUM(CAST(pass_through_value AS DOUBLE))
      comment: "Sum of pass-through values negotiated"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_negotiation_rounds"
      display_name: "Average Negotiation Rounds"
      expr: AVG(CAST(negotiation_round AS DOUBLE))
      comment: "Average number of negotiation rounds per contract"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "avg_open_issue_count"
      display_name: "Average Open Issue Count"
      expr: AVG(CAST(open_issue_count AS DOUBLE))
      comment: "Average number of open issues per negotiation"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "escalated_negotiation_count"
      display_name: "Escalated Negotiation Count"
      expr: COUNT(CASE WHEN escalation_flag = TRUE THEN 1 END)
      comment: "Number of negotiations that have been escalated"
      format:
        type: number
        decimal_places:
          type: all
    - name: "completed_negotiation_count"
      display_name: "Completed Negotiation Count"
      expr: COUNT(CASE WHEN negotiation_status = 'completed' THEN 1 END)
      comment: "Number of negotiations that have been completed"
      format:
        type: number
        decimal_places:
          type: all
    - name: "stalled_negotiation_count"
      display_name: "Stalled Negotiation Count"
      expr: COUNT(CASE WHEN negotiation_status = 'stalled' THEN 1 END)
      comment: "Number of negotiations that are currently stalled"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_negotiation_cycle_days"
      display_name: "Average Negotiation Cycle Days"
      expr: AVG(DATEDIFF(actual_execution_date, negotiation_start_date))
      comment: "Average number of days from negotiation start to execution"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "avg_round_duration_days"
      display_name: "Average Round Duration Days"
      expr: AVG(DATEDIFF(round_end_date, round_start_date))
      comment: "Average duration of a negotiation round in days"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "avg_legal_review_days"
      display_name: "Average Legal Review Days"
      expr: AVG(DATEDIFF(legal_review_end_date, legal_review_start_date))
      comment: "Average number of days for legal review"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`agreement_deliverable`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Deliverable performance tracking: on-time delivery rate, quality metrics, effort variance, and SLA compliance for contractual deliverables."
  source: "`clinical_trials_ecm`.`agreement`.`deliverable`"
  dimensions:
    - name: "deliverable_type"
      display_name: "Deliverable Type"
      expr: deliverable_type
      comment: "Type of deliverable (report, dataset, document, submission package, etc.)"
    - name: "deliverable_category"
      display_name: "Deliverable Category"
      expr: deliverable_category
      comment: "Category of deliverable (regulatory, clinical, statistical, data management, etc.)"
    - name: "delivery_status"
      display_name: "Delivery Status"
      expr: delivery_status
      comment: "Current delivery status (planned, in progress, submitted, accepted, rejected)"
    - name: "qc_review_status"
      display_name: "QC Review Status"
      expr: qc_review_status
      comment: "Quality control review status"
    - name: "priority_level"
      display_name: "Priority Level"
      expr: priority_level
      comment: "Priority level of the deliverable (high, medium, low)"
    - name: "responsible_functional_team"
      display_name: "Responsible Functional Team"
      expr: responsible_functional_team
      comment: "Functional team responsible for the deliverable"
    - name: "cdisc_compliant_flag"
      display_name: "CDISC Compliant"
      expr: cdisc_compliant_flag
      comment: "Whether the deliverable must be CDISC compliant"
    - name: "regulatory_submission_flag"
      display_name: "Regulatory Submission"
      expr: regulatory_submission_flag
      comment: "Whether the deliverable is part of a regulatory submission"
    - name: "planned_delivery_year"
      display_name: "Planned Delivery Year"
      expr: DATE_TRUNC('year', planned_delivery_date)
      comment: "Year when deliverable is planned for delivery"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "planned_delivery_quarter"
      display_name: "Planned Delivery Quarter"
      expr: DATE_TRUNC('quarter', planned_delivery_date)
      comment: "Quarter when deliverable is planned for delivery"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "planned_delivery_month"
      display_name: "Planned Delivery Month"
      expr: DATE_TRUNC('month', planned_delivery_date)
      comment: "Month when deliverable is planned for delivery"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "deliverable_count"
      display_name: "Deliverable Count"
      expr: COUNT(1)
      comment: "Total number of deliverables"
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_contracted_value"
      display_name: "Total Contracted Value"
      expr: SUM(CAST(contracted_value_usd AS DOUBLE))
      comment: "Sum of contracted value across all deliverables"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_contracted_value"
      display_name: "Average Contracted Value"
      expr: AVG(CAST(contracted_value_usd AS DOUBLE))
      comment: "Average contracted value per deliverable"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_estimated_effort_hours"
      display_name: "Total Estimated Effort Hours"
      expr: SUM(CAST(estimated_effort_hours AS DOUBLE))
      comment: "Sum of estimated effort hours across all deliverables"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "total_actual_effort_hours"
      display_name: "Total Actual Effort Hours"
      expr: SUM(CAST(actual_effort_hours AS DOUBLE))
      comment: "Sum of actual effort hours across all deliverables"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "avg_estimated_effort_hours"
      display_name: "Average Estimated Effort Hours"
      expr: AVG(CAST(estimated_effort_hours AS DOUBLE))
      comment: "Average estimated effort hours per deliverable"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "avg_actual_effort_hours"
      display_name: "Average Actual Effort Hours"
      expr: AVG(CAST(actual_effort_hours AS DOUBLE))
      comment: "Average actual effort hours per deliverable"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "on_time_delivery_count"
      display_name: "On-Time Delivery Count"
      expr: COUNT(CASE WHEN actual_delivery_date <= planned_delivery_date THEN 1 END)
      comment: "Number of deliverables delivered on or before planned date"
      format:
        type: number
        decimal_places:
          type: all
    - name: "late_delivery_count"
      display_name: "Late Delivery Count"
      expr: COUNT(CASE WHEN actual_delivery_date > planned_delivery_date THEN 1 END)
      comment: "Number of deliverables delivered after planned date"
      format:
        type: number
        decimal_places:
          type: all
    - name: "accepted_deliverable_count"
      display_name: "Accepted Deliverable Count"
      expr: COUNT(CASE WHEN delivery_status = 'accepted' THEN 1 END)
      comment: "Number of deliverables that have been accepted"
      format:
        type: number
        decimal_places:
          type: all
    - name: "rejected_deliverable_count"
      display_name: "Rejected Deliverable Count"
      expr: COUNT(CASE WHEN delivery_status = 'rejected' THEN 1 END)
      comment: "Number of deliverables that have been rejected"
      format:
        type: number
        decimal_places:
          type: all
    - name: "sla_met_count"
      display_name: "SLA Met Count"
      expr: COUNT(CASE WHEN sla_met_flag = TRUE THEN 1 END)
      comment: "Number of deliverables that met their SLA"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_days_overdue"
      display_name: "Average Days Overdue"
      expr: AVG(CAST(days_overdue AS DOUBLE))
      comment: "Average number of days overdue for late deliverables"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "avg_revision_count"
      display_name: "Average Revision Count"
      expr: AVG(CAST(revision_count AS DOUBLE))
      comment: "Average number of revisions per deliverable"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`agreement_scope_of_work`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Scope of work portfolio: service mix, geographic coverage, site and subject planning, and budget allocation across functional areas."
  source: "`clinical_trials_ecm`.`agreement`.`scope_of_work`"
  dimensions:
    - name: "sow_type"
      display_name: "SOW Type"
      expr: sow_type
      comment: "Type of scope of work (full-service, functional, hybrid, etc.)"
    - name: "approval_status"
      display_name: "Approval Status"
      expr: approval_status
      comment: "Current approval status of the SOW"
    - name: "payment_model"
      display_name: "Payment Model"
      expr: payment_model
      comment: "Payment model for the SOW (fixed-price, time-and-materials, milestone-based, etc.)"
    - name: "geographic_scope"
      display_name: "Geographic Scope"
      expr: geographic_scope
      comment: "Geographic scope of the SOW (global, regional, country-specific)"
    - name: "monitoring_included"
      display_name: "Monitoring Included"
      expr: monitoring_included
      comment: "Whether monitoring services are included in the SOW"
    - name: "data_management_included"
      display_name: "Data Management Included"
      expr: data_management_included
      comment: "Whether data management services are included in the SOW"
    - name: "biostatistics_included"
      display_name: "Biostatistics Included"
      expr: biostatistics_included
      comment: "Whether biostatistics services are included in the SOW"
    - name: "regulatory_included"
      display_name: "Regulatory Included"
      expr: regulatory_included
      comment: "Whether regulatory services are included in the SOW"
    - name: "pharmacovigilance_included"
      display_name: "Pharmacovigilance Included"
      expr: pharmacovigilance_included
      comment: "Whether pharmacovigilance services are included in the SOW"
    - name: "execution_year"
      display_name: "Execution Year"
      expr: DATE_TRUNC('year', execution_date)
      comment: "Year when SOW was executed"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "execution_quarter"
      display_name: "Execution Quarter"
      expr: DATE_TRUNC('quarter', execution_date)
      comment: "Quarter when SOW was executed"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "sow_count"
      display_name: "SOW Count"
      expr: COUNT(1)
      comment: "Total number of scopes of work"
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_contract_value"
      display_name: "Total Contract Value"
      expr: SUM(CAST(total_contract_value AS DOUBLE))
      comment: "Sum of total contract value across all SOWs"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_contract_value"
      display_name: "Average Contract Value"
      expr: AVG(CAST(total_contract_value AS DOUBLE))
      comment: "Average contract value per SOW"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_service_fee_budget"
      display_name: "Total Service Fee Budget"
      expr: SUM(CAST(service_fee_budget AS DOUBLE))
      comment: "Sum of service fee budgets across all SOWs"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_pass_through_budget"
      display_name: "Total Pass-Through Budget"
      expr: SUM(CAST(pass_through_budget AS DOUBLE))
      comment: "Sum of pass-through budgets across all SOWs"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_planned_site_count"
      display_name: "Total Planned Site Count"
      expr: SUM(CAST(planned_site_count AS DOUBLE))
      comment: "Sum of planned site counts across all SOWs"
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_planned_subject_count"
      display_name: "Total Planned Subject Count"
      expr: SUM(CAST(planned_subject_count AS DOUBLE))
      comment: "Sum of planned subject counts across all SOWs"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_planned_site_count"
      display_name: "Average Planned Site Count"
      expr: AVG(CAST(planned_site_count AS DOUBLE))
      comment: "Average planned site count per SOW"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "avg_planned_subject_count"
      display_name: "Average Planned Subject Count"
      expr: AVG(CAST(planned_subject_count AS DOUBLE))
      comment: "Average planned subject count per SOW"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "total_country_count"
      display_name: "Total Country Count"
      expr: SUM(CAST(country_count AS DOUBLE))
      comment: "Sum of countries covered across all SOWs"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_country_count"
      display_name: "Average Country Count"
      expr: AVG(CAST(country_count AS DOUBLE))
      comment: "Average number of countries per SOW"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "monitoring_included_count"
      display_name: "Monitoring Included Count"
      expr: COUNT(CASE WHEN monitoring_included = TRUE THEN 1 END)
      comment: "Number of SOWs that include monitoring services"
      format:
        type: number
        decimal_places:
          type: all
    - name: "data_management_included_count"
      display_name: "Data Management Included Count"
      expr: COUNT(CASE WHEN data_management_included = TRUE THEN 1 END)
      comment: "Number of SOWs that include data management services"
      format:
        type: number
        decimal_places:
          type: all
    - name: "biostatistics_included_count"
      display_name: "Biostatistics Included Count"
      expr: COUNT(CASE WHEN biostatistics_included = TRUE THEN 1 END)
      comment: "Number of SOWs that include biostatistics services"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`agreement_study_contract`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Study contract portfolio performance: total contracted value, pass-through vs service fee mix, negotiation efficiency, and contract lifecycle management."
  source: "`clinical_trials_ecm`.`agreement`.`study_contract`"
  parameters:
    - name: p_target_currency
      data_type: STRING
      default: "'USD'"
  dimensions:
    - name: "contract_status"
      display_name: "Contract Status"
      expr: contract_status
      comment: "Current status of the study contract (draft, negotiation, executed, active, closed, terminated)"
    - name: "contract_type"
      display_name: "Contract Type"
      expr: contract_type
      comment: "Type of study contract (full-service, FSP, functional, etc.)"
    - name: "phase"
      display_name: "Study Phase"
      expr: phase
      comment: "Clinical trial phase (Phase I, II, III, IV)"
    - name: "negotiation_status"
      display_name: "Negotiation Status"
      expr: negotiation_status
      comment: "Current negotiation status (pending, in progress, completed, stalled)"
    - name: "execution_year"
      display_name: "Execution Year"
      expr: DATE_TRUNC('year', execution_date)
      comment: "Year when contract was executed"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "execution_quarter"
      display_name: "Execution Quarter"
      expr: DATE_TRUNC('quarter', execution_date)
      comment: "Quarter when contract was executed"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "execution_month"
      display_name: "Execution Month"
      expr: DATE_TRUNC('month', execution_date)
      comment: "Month when contract was executed"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "effective_start_year"
      display_name: "Effective Start Year"
      expr: DATE_TRUNC('year', effective_start_date)
      comment: "Year when contract became effective"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "contract_count"
      display_name: "Contract Count"
      expr: COUNT(1)
      comment: "Total number of study contracts"
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_contracted_value"
      display_name: "Total Contracted Value"
      expr: SUM(CAST(total_contracted_value AS DOUBLE))
      comment: "Sum of total contracted value across all study contracts"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_current_contracted_value"
      display_name: "Total Current Contracted Value"
      expr: SUM(CAST(current_contracted_value AS DOUBLE))
      comment: "Sum of current contracted value after change orders"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_contract_value"
      display_name: "Average Contract Value"
      expr: AVG(CAST(total_contracted_value AS DOUBLE))
      comment: "Average total contracted value per study contract"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_service_fee_budget"
      display_name: "Total Service Fee Budget"
      expr: SUM(CAST(service_fee_budget AS DOUBLE))
      comment: "Sum of service fee budgets across all contracts"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_pass_through_budget"
      display_name: "Total Pass-Through Budget"
      expr: SUM(CAST(pass_through_budget AS DOUBLE))
      comment: "Sum of pass-through budgets across all contracts"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_service_fee_budget"
      display_name: "Average Service Fee Budget"
      expr: AVG(CAST(service_fee_budget AS DOUBLE))
      comment: "Average service fee budget per contract"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_pass_through_budget"
      display_name: "Average Pass-Through Budget"
      expr: AVG(CAST(pass_through_budget AS DOUBLE))
      comment: "Average pass-through budget per contract"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_change_order_count"
      display_name: "Total Change Order Count"
      expr: SUM(CAST(change_order_count AS DOUBLE))
      comment: "Sum of change orders across all contracts"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_change_order_count"
      display_name: "Average Change Order Count"
      expr: AVG(CAST(change_order_count AS DOUBLE))
      comment: "Average number of change orders per contract"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "avg_negotiation_rounds"
      display_name: "Average Negotiation Rounds"
      expr: AVG(CAST(negotiation_round AS DOUBLE))
      comment: "Average number of negotiation rounds per contract"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "executed_contract_count"
      display_name: "Executed Contract Count"
      expr: COUNT(CASE WHEN contract_status IN ('executed', 'active') THEN 1 END)
      comment: "Number of contracts that have been executed or are active"
      format:
        type: number
        decimal_places:
          type: all
    - name: "terminated_contract_count"
      display_name: "Terminated Contract Count"
      expr: COUNT(CASE WHEN contract_status = 'terminated' THEN 1 END)
      comment: "Number of contracts that have been terminated"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_negotiation_to_execution_days"
      display_name: "Average Negotiation Delay Days"
      expr: AVG(DATEDIFF(execution_date, target_execution_date))
      comment: "Average number of days between target and actual execution date"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;
