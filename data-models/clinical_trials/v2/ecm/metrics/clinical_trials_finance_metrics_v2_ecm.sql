-- Metric views for domain: finance | Business: Clinical_Trials | Version: 13 | Generated on: 2026-11-19 16:37:37

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`finance_accrual`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Financial accruals tracking for revenue recognition, cost matching, and period-end adjustments across studies, sites, and vendors"
  source: "`clinical_trials_ecm`.`finance`.`accrual`"
  parameters:
    - name: p_reporting_currency
      data_type: STRING
      default: "'USD'"
  dimensions:
    - name: "accrual_type"
      display_name: "Accrual Type"
      expr: accrual_type
      comment: "Type of accrual (revenue, expense, pass-through, etc.)"
    - name: "accrual_status"
      display_name: "Accrual Status"
      expr: accrual_status
      comment: "Current status of the accrual (pending, approved, posted, reversed)"
    - name: "fiscal_year"
      display_name: "Fiscal Year"
      expr: fiscal_year
      comment: "Fiscal year of the accrual"
    - name: "period"
      display_name: "Fiscal Period"
      expr: period
      comment: "Fiscal period of the accrual"
    - name: "is_pass_through"
      display_name: "Pass-Through Flag"
      expr: is_pass_through
      comment: "Whether this accrual represents pass-through costs"
    - name: "is_sox_controlled"
      display_name: "SOX Controlled"
      expr: is_sox_controlled
      comment: "Whether this accrual is subject to SOX controls"
    - name: "posting_month"
      display_name: "Posting Month"
      expr: DATE_TRUNC('month', posting_date)
      comment: "Month when the accrual was posted"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "posting_quarter"
      display_name: "Posting Quarter"
      expr: DATE_TRUNC('quarter', posting_date)
      comment: "Quarter when the accrual was posted"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "posting_year"
      display_name: "Posting Year"
      expr: DATE_TRUNC('year', posting_date)
      comment: "Year when the accrual was posted"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_accrual_amount"
      display_name: "Total Accrual Amount"
      expr: SUM(CAST(amount AS DOUBLE))
      comment: "Total accrual amount in transaction currency"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_accrual_amount_usd"
      display_name: "Total Accrual Amount (USD)"
      expr: SUM(CAST(amount_usd AS DOUBLE))
      comment: "Total accrual amount converted to USD"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "cumulative_accrual_amount"
      display_name: "Cumulative Accrual Amount"
      expr: SUM(CAST(cumulative_accrual_amount AS DOUBLE))
      comment: "Cumulative accrual balance across periods"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "variance_amount"
      display_name: "Accrual Variance"
      expr: SUM(CAST(variance_amount AS DOUBLE))
      comment: "Total variance between accrued and actual amounts"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "accrual_count"
      display_name: "Accrual Count"
      expr: COUNT(accrual_id)
      comment: "Number of accrual transactions"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_accrual_amount"
      display_name: "Average Accrual Amount"
      expr: AVG(CAST(amount_usd AS DOUBLE))
      comment: "Average accrual amount per transaction in USD"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "accrual_reversal_count"
      display_name: "Reversal Count"
      expr: COUNT(CASE WHEN reversal_date IS NOT NULL THEN accrual_id END)
      comment: "Number of accruals that have been reversed"
      format:
        type: number
        decimal_places:
          type: all
    - name: "accrual_reversal_rate"
      display_name: "Accrual Reversal Rate"
      expr: COUNT(CASE WHEN reversal_date IS NOT NULL THEN accrual_id END) / NULLIF(CAST(COUNT(accrual_id) AS DOUBLE), 0)
      comment: "Percentage of accruals that have been reversed"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`finance_budget_line`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Budget line-item performance tracking for planned vs actual spend, commitments, and variance analysis across studies and cost categories"
  source: "`clinical_trials_ecm`.`finance`.`budget_line`"
  dimensions:
    - name: "cost_category"
      display_name: "Cost Category"
      expr: cost_category
      comment: "Primary cost category for the budget line"
    - name: "cost_subcategory"
      display_name: "Cost Subcategory"
      expr: cost_subcategory
      comment: "Detailed cost subcategory"
    - name: "activity_type"
      display_name: "Activity Type"
      expr: activity_type
      comment: "Type of activity being budgeted"
    - name: "line_status"
      display_name: "Line Status"
      expr: line_status
      comment: "Current status of the budget line"
    - name: "is_milestone_based"
      display_name: "Milestone-Based"
      expr: is_milestone_based
      comment: "Whether this budget line is tied to milestone completion"
    - name: "is_pass_through"
      display_name: "Pass-Through"
      expr: is_pass_through
      comment: "Whether this represents pass-through costs"
    - name: "fiscal_year"
      display_name: "Fiscal Year"
      expr: fiscal_year
      comment: "Fiscal year of the budget line"
    - name: "fiscal_period"
      display_name: "Fiscal Period"
      expr: fiscal_period
      comment: "Fiscal period of the budget line"
    - name: "period_month"
      display_name: "Period Month"
      expr: DATE_TRUNC('month', period_start_date)
      comment: "Month of the budget period start"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_planned_amount"
      display_name: "Total Planned Amount"
      expr: SUM(CAST(planned_amount AS DOUBLE))
      comment: "Total planned budget amount"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_actual_amount"
      display_name: "Total Actual Amount"
      expr: SUM(CAST(actual_amount AS DOUBLE))
      comment: "Total actual spend against budget"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_committed_amount"
      display_name: "Total Committed Amount"
      expr: SUM(CAST(committed_amount AS DOUBLE))
      comment: "Total committed but not yet spent amount"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_accrual_amount"
      display_name: "Total Accrual Amount"
      expr: SUM(CAST(accrual_amount AS DOUBLE))
      comment: "Total accrued amount for the budget line"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "budget_variance"
      display_name: "Budget Variance"
      expr: SUM((CAST(planned_amount AS DOUBLE)) - (CAST(actual_amount AS DOUBLE)))
      comment: "Total variance between planned and actual (positive = under budget)"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "budget_utilization_rate"
      display_name: "Budget Utilization Rate"
      expr: SUM(CAST(actual_amount AS DOUBLE)) / NULLIF(SUM(CAST(planned_amount AS DOUBLE)), 0)
      comment: "Percentage of planned budget actually spent"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "commitment_rate"
      display_name: "Commitment Rate"
      expr: SUM(CAST(committed_amount AS DOUBLE)) / NULLIF(SUM(CAST(planned_amount AS DOUBLE)), 0)
      comment: "Percentage of planned budget committed"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "budget_line_count"
      display_name: "Budget Line Count"
      expr: COUNT(budget_line_id)
      comment: "Number of budget line items"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_line_planned_amount"
      display_name: "Average Planned Amount"
      expr: AVG(CAST(planned_amount AS DOUBLE))
      comment: "Average planned amount per budget line"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`finance_financial_forecast`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Financial forecasting and projection metrics tracking revenue, cost, and margin forecasts with variance analysis"
  source: "`clinical_trials_ecm`.`finance`.`financial_forecast`"
  dimensions:
    - name: "forecast_status"
      display_name: "Forecast Status"
      expr: forecast_status
      comment: "Current status of the financial forecast"
    - name: "forecast_type"
      display_name: "Forecast Type"
      expr: forecast_type
      comment: "Type of forecast (budget, reforecast, projection, etc.)"
    - name: "forecast_basis"
      display_name: "Forecast Basis"
      expr: forecast_basis
      comment: "Basis for the forecast (historical, statistical, judgmental, etc.)"
    - name: "scope_level"
      display_name: "Scope Level"
      expr: scope_level
      comment: "Scope level of the forecast (study, program, portfolio, etc.)"
    - name: "confidence_level"
      display_name: "Confidence Level"
      expr: confidence_level
      comment: "Confidence level of the forecast"
    - name: "is_baseline_forecast"
      display_name: "Baseline Forecast"
      expr: is_baseline_forecast
      comment: "Whether this is the baseline forecast"
    - name: "sponsor_submitted_flag"
      display_name: "Sponsor Submitted"
      expr: sponsor_submitted_flag
      comment: "Whether this forecast has been submitted to sponsor"
    - name: "fiscal_year"
      display_name: "Fiscal Year"
      expr: fiscal_year
      comment: "Fiscal year of the forecast"
    - name: "fiscal_period"
      display_name: "Fiscal Period"
      expr: fiscal_period
      comment: "Fiscal period of the forecast"
    - name: "forecast_version"
      display_name: "Forecast Version"
      expr: forecast_version
      comment: "Version number of the forecast"
  measures:
    - name: "total_revenue_forecast"
      display_name: "Total Revenue Forecast"
      expr: SUM(CAST(revenue_forecast_amount AS DOUBLE))
      comment: "Total forecasted revenue"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_direct_cost_forecast"
      display_name: "Total Direct Cost Forecast"
      expr: SUM(CAST(direct_cost_forecast_amount AS DOUBLE))
      comment: "Total forecasted direct costs"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_indirect_cost_forecast"
      display_name: "Total Indirect Cost Forecast"
      expr: SUM(CAST(indirect_cost_forecast_amount AS DOUBLE))
      comment: "Total forecasted indirect costs"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_pass_through_cost_forecast"
      display_name: "Total Pass-Through Cost Forecast"
      expr: SUM(CAST(pass_through_cost_forecast_amount AS DOUBLE))
      comment: "Total forecasted pass-through costs"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_gross_margin_forecast"
      display_name: "Total Gross Margin Forecast"
      expr: SUM(CAST(gross_margin_forecast_amount AS DOUBLE))
      comment: "Total forecasted gross margin"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_gross_margin_forecast_pct"
      display_name: "Average Gross Margin %"
      expr: AVG(CAST(gross_margin_forecast_pct AS DOUBLE))
      comment: "Average forecasted gross margin percentage"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "total_revenue_variance"
      display_name: "Total Revenue Variance"
      expr: SUM(CAST(revenue_variance_amount AS DOUBLE))
      comment: "Total variance between forecasted and actual revenue"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_cost_variance"
      display_name: "Total Cost Variance"
      expr: SUM(CAST(cost_variance_amount AS DOUBLE))
      comment: "Total variance between forecasted and actual costs"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_cash_inflow_forecast"
      display_name: "Total Cash Inflow Forecast"
      expr: SUM(CAST(cash_inflow_forecast_amount AS DOUBLE))
      comment: "Total forecasted cash inflows"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_cash_outflow_forecast"
      display_name: "Total Cash Outflow Forecast"
      expr: SUM(CAST(cash_outflow_forecast_amount AS DOUBLE))
      comment: "Total forecasted cash outflows"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "forecast_count"
      display_name: "Forecast Count"
      expr: COUNT(financial_forecast_id)
      comment: "Number of financial forecasts"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_milestone_completion_pct"
      display_name: "Average Milestone Completion %"
      expr: AVG(CAST(milestone_completion_pct AS DOUBLE))
      comment: "Average milestone completion percentage"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "avg_enrolled_subjects_assumption"
      display_name: "Average Enrolled Subjects Assumption"
      expr: AVG(CAST(enrolled_subjects_assumption AS DOUBLE))
      comment: "Average enrolled subjects assumption in forecasts"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`finance_purchase_order`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Purchase order management and procurement metrics tracking PO amounts, approval status, and goods receipt performance"
  source: "`clinical_trials_ecm`.`finance`.`purchase_order`"
  dimensions:
    - name: "po_status"
      display_name: "PO Status"
      expr: po_status
      comment: "Current status of the purchase order"
    - name: "po_type"
      display_name: "PO Type"
      expr: po_type
      comment: "Type of purchase order"
    - name: "approval_status"
      display_name: "Approval Status"
      expr: approval_status
      comment: "Approval status of the purchase order"
    - name: "goods_receipt_status"
      display_name: "Goods Receipt Status"
      expr: goods_receipt_status
      comment: "Status of goods receipt against the PO"
    - name: "invoice_status"
      display_name: "Invoice Status"
      expr: invoice_status
      comment: "Invoice status for the purchase order"
    - name: "pass_through_flag"
      display_name: "Pass-Through"
      expr: pass_through_flag
      comment: "Whether this PO represents pass-through costs"
    - name: "sponsor_billable_flag"
      display_name: "Sponsor Billable"
      expr: sponsor_billable_flag
      comment: "Whether this PO is billable to sponsor"
    - name: "po_month"
      display_name: "PO Month"
      expr: DATE_TRUNC('month', po_date)
      comment: "Month when the PO was created"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "po_quarter"
      display_name: "PO Quarter"
      expr: DATE_TRUNC('quarter', po_date)
      comment: "Quarter when the PO was created"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_po_gross_amount"
      display_name: "Total PO Gross Amount"
      expr: SUM(CAST(po_gross_amount AS DOUBLE))
      comment: "Total gross purchase order amount"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_po_net_amount"
      display_name: "Total PO Net Amount"
      expr: SUM(CAST(net_amount AS DOUBLE))
      comment: "Total net purchase order amount"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_tax_amount"
      display_name: "Total Tax Amount"
      expr: SUM(CAST(tax_amount AS DOUBLE))
      comment: "Total tax amount on purchase orders"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_invoiced_amount"
      display_name: "Total Invoiced Amount"
      expr: SUM(CAST(invoiced_amount AS DOUBLE))
      comment: "Total amount invoiced against purchase orders"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_accrual_amount"
      display_name: "Total Accrual Amount"
      expr: SUM(CAST(accrual_amount AS DOUBLE))
      comment: "Total accrual amount for purchase orders"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "purchase_order_count"
      display_name: "Purchase Order Count"
      expr: COUNT(purchase_order_id)
      comment: "Number of purchase orders"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_po_amount"
      display_name: "Average PO Amount"
      expr: AVG(CAST(po_gross_amount AS DOUBLE))
      comment: "Average gross purchase order amount"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "po_invoice_match_rate"
      display_name: "PO Invoice Match Rate"
      expr: SUM(CAST(invoiced_amount AS DOUBLE)) / NULLIF(SUM(CAST(po_gross_amount AS DOUBLE)), 0)
      comment: "Percentage of PO amount that has been invoiced"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "goods_received_po_count"
      display_name: "Goods Received PO Count"
      expr: COUNT(CASE WHEN goods_receipt_date IS NOT NULL THEN purchase_order_id END)
      comment: "Number of POs with goods received"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_days_to_goods_receipt"
      display_name: "Average Days to Goods Receipt"
      expr: AVG(DATEDIFF(goods_receipt_date, po_date))
      comment: "Average number of days from PO creation to goods receipt"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "avg_days_to_delivery"
      display_name: "Average Days to Delivery"
      expr: AVG(DATEDIFF(delivery_date, po_date))
      comment: "Average number of days from PO creation to delivery"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`finance_revenue_recognition`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Revenue recognition and earned value metrics tracking completion percentage, recognized revenue, and deferred revenue balances"
  source: "`clinical_trials_ecm`.`finance`.`revenue_recognition`"
  dimensions:
    - name: "recognition_status"
      display_name: "Recognition Status"
      expr: recognition_status
      comment: "Current status of the revenue recognition entry"
    - name: "recognition_method"
      display_name: "Recognition Method"
      expr: recognition_method
      comment: "Method used for revenue recognition (percentage-of-completion, milestone, etc.)"
    - name: "phase"
      display_name: "Phase"
      expr: phase
      comment: "Study phase for the revenue recognition"
    - name: "service_line"
      display_name: "Service Line"
      expr: service_line
      comment: "Service line generating the revenue"
    - name: "therapeutic_area"
      display_name: "Therapeutic Area"
      expr: therapeutic_area
      comment: "Therapeutic area of the study"
    - name: "accrual_flag"
      display_name: "Accrual Flag"
      expr: accrual_flag
      comment: "Whether this recognition entry is accrual-based"
    - name: "reversal_flag"
      display_name: "Reversal Flag"
      expr: reversal_flag
      comment: "Whether this is a reversal entry"
    - name: "contract_modification_flag"
      display_name: "Contract Modification Flag"
      expr: contract_modification_flag
      comment: "Whether this relates to a contract modification"
    - name: "fiscal_year"
      display_name: "Fiscal Year"
      expr: fiscal_year
      comment: "Fiscal year of revenue recognition"
    - name: "fiscal_period"
      display_name: "Fiscal Period"
      expr: fiscal_period
      comment: "Fiscal period of revenue recognition"
    - name: "recognition_month"
      display_name: "Recognition Month"
      expr: DATE_TRUNC('month', recognition_date)
      comment: "Month when revenue was recognized"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "recognition_quarter"
      display_name: "Recognition Quarter"
      expr: DATE_TRUNC('quarter', recognition_date)
      comment: "Quarter when revenue was recognized"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_recognized_amount"
      display_name: "Total Recognized Revenue"
      expr: SUM(CAST(recognized_amount AS DOUBLE))
      comment: "Total revenue recognized in the period"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_cumulative_recognized_amount"
      display_name: "Total Cumulative Recognized Revenue"
      expr: SUM(CAST(cumulative_recognized_amount AS DOUBLE))
      comment: "Total cumulative revenue recognized to date"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_deferred_revenue_balance"
      display_name: "Total Deferred Revenue Balance"
      expr: SUM(CAST(deferred_revenue_balance AS DOUBLE))
      comment: "Total deferred revenue balance not yet recognized"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_unbilled_receivable"
      display_name: "Total Unbilled Receivable"
      expr: SUM(CAST(unbilled_receivable_amount AS DOUBLE))
      comment: "Total unbilled receivable (revenue recognized but not yet invoiced)"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_contract_value"
      display_name: "Total Contract Value"
      expr: SUM(CAST(contract_value AS DOUBLE))
      comment: "Total contract value across all revenue recognition entries"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_completion_percentage"
      display_name: "Average Completion Percentage"
      expr: AVG(CAST(completion_percentage AS DOUBLE))
      comment: "Average completion percentage across contracts"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "revenue_recognition_count"
      display_name: "Revenue Recognition Count"
      expr: COUNT(revenue_recognition_id)
      comment: "Number of revenue recognition entries"
      format:
        type: number
        decimal_places:
          type: all
    - name: "revenue_recognition_rate"
      display_name: "Revenue Recognition Rate"
      expr: SUM(CAST(cumulative_recognized_amount AS DOUBLE)) / NULLIF(SUM(CAST(contract_value AS DOUBLE)), 0)
      comment: "Percentage of total contract value recognized to date"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "avg_recognized_amount"
      display_name: "Average Recognized Amount"
      expr: AVG(CAST(recognized_amount AS DOUBLE))
      comment: "Average revenue recognized per entry"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`finance_site_payment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Site payment processing and disbursement metrics tracking payment amounts, timing, and reconciliation status"
  source: "`clinical_trials_ecm`.`finance`.`site_payment`"
  dimensions:
    - name: "payment_status"
      display_name: "Payment Status"
      expr: payment_status
      comment: "Current status of the site payment"
    - name: "payment_type"
      display_name: "Payment Type"
      expr: payment_type
      comment: "Type of site payment (milestone, per-patient, startup, etc.)"
    - name: "payment_method"
      display_name: "Payment Method"
      expr: payment_method
      comment: "Method used for payment (wire, check, ACH, etc.)"
    - name: "is_advance_payment"
      display_name: "Advance Payment"
      expr: is_advance_payment
      comment: "Whether this is an advance payment"
    - name: "is_pass_through"
      display_name: "Pass-Through"
      expr: is_pass_through
      comment: "Whether this is a pass-through payment"
    - name: "reconciliation_status"
      display_name: "Reconciliation Status"
      expr: reconciliation_status
      comment: "Reconciliation status of the payment"
    - name: "reversal_indicator"
      display_name: "Reversal Indicator"
      expr: reversal_indicator
      comment: "Whether this payment has been reversed"
    - name: "payment_month"
      display_name: "Payment Month"
      expr: DATE_TRUNC('month', payment_date)
      comment: "Month when the payment was made"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "payment_quarter"
      display_name: "Payment Quarter"
      expr: DATE_TRUNC('quarter', payment_date)
      comment: "Quarter when the payment was made"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_payment_amount"
      display_name: "Total Payment Amount"
      expr: SUM(CAST(payment_amount AS DOUBLE))
      comment: "Total gross payment amount to sites"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_net_payment_amount"
      display_name: "Total Net Payment Amount"
      expr: SUM(CAST(net_payment_amount AS DOUBLE))
      comment: "Total net payment amount after withholding"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_withholding_tax_amount"
      display_name: "Total Withholding Tax Amount"
      expr: SUM(CAST(withholding_tax_amount AS DOUBLE))
      comment: "Total withholding tax amount on site payments"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "site_payment_count"
      display_name: "Site Payment Count"
      expr: COUNT(site_payment_id)
      comment: "Number of site payments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_payment_amount"
      display_name: "Average Payment Amount"
      expr: AVG(CAST(payment_amount AS DOUBLE))
      comment: "Average payment amount per site payment"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_withholding_tax_rate"
      display_name: "Average Withholding Tax Rate"
      expr: AVG(CAST(withholding_tax_rate AS DOUBLE))
      comment: "Average withholding tax rate across site payments"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "reconciled_payment_count"
      display_name: "Reconciled Payment Count"
      expr: COUNT(CASE WHEN reconciliation_date IS NOT NULL THEN site_payment_id END)
      comment: "Number of site payments that have been reconciled"
      format:
        type: number
        decimal_places:
          type: all
    - name: "reconciliation_rate"
      display_name: "Reconciliation Rate"
      expr: COUNT(CASE WHEN reconciliation_date IS NOT NULL THEN site_payment_id END) / NULLIF(CAST(COUNT(site_payment_id) AS DOUBLE), 0)
      comment: "Percentage of site payments reconciled"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "avg_days_to_reconciliation"
      display_name: "Average Days to Reconciliation"
      expr: AVG(DATEDIFF(reconciliation_date, payment_date))
      comment: "Average number of days from payment to reconciliation"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`finance_sponsor_invoice`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Sponsor billing and revenue collection metrics tracking invoice amounts, payment status, and accounts receivable aging"
  source: "`clinical_trials_ecm`.`finance`.`sponsor_invoice`"
  dimensions:
    - name: "payment_status"
      display_name: "Payment Status"
      expr: payment_status
      comment: "Current payment status of the invoice"
    - name: "document_type"
      display_name: "Document Type"
      expr: document_type
      comment: "Type of billing document (invoice, credit memo, etc.)"
    - name: "is_pass_through"
      display_name: "Pass-Through"
      expr: is_pass_through
      comment: "Whether this invoice includes pass-through costs"
    - name: "revenue_recognition_method"
      display_name: "Revenue Recognition Method"
      expr: revenue_recognition_method
      comment: "Method used for revenue recognition"
    - name: "invoice_month"
      display_name: "Invoice Month"
      expr: DATE_TRUNC('month', invoice_date)
      comment: "Month when the invoice was issued"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "invoice_quarter"
      display_name: "Invoice Quarter"
      expr: DATE_TRUNC('quarter', invoice_date)
      comment: "Quarter when the invoice was issued"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "invoice_year"
      display_name: "Invoice Year"
      expr: DATE_TRUNC('year', invoice_date)
      comment: "Year when the invoice was issued"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "aging_bucket"
      display_name: "Aging Bucket"
      expr: CASE WHEN payment_received_date IS NOT NULL THEN 'Paid' WHEN DATEDIFF(CURRENT_DATE(), due_date) <= 0 THEN 'Current' WHEN DATEDIFF(CURRENT_DATE(), due_date) <= 30 THEN '1-30 Days' WHEN DATEDIFF(CURRENT_DATE(), due_date) <= 60 THEN '31-60 Days' WHEN DATEDIFF(CURRENT_DATE(), due_date) <= 90 THEN '61-90 Days' ELSE '90+ Days' END
      comment: "Aging bucket for accounts receivable analysis"
  measures:
    - name: "total_gross_amount"
      display_name: "Total Gross Amount"
      expr: SUM(CAST(gross_amount AS DOUBLE))
      comment: "Total gross invoice amount before discounts and taxes"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_net_amount"
      display_name: "Total Net Amount"
      expr: SUM(CAST(net_amount AS DOUBLE))
      comment: "Total net invoice amount after discounts"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_tax_amount"
      display_name: "Total Tax Amount"
      expr: SUM(CAST(tax_amount AS DOUBLE))
      comment: "Total tax amount on invoices"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_amount_paid"
      display_name: "Total Amount Paid"
      expr: SUM(CAST(amount_paid AS DOUBLE))
      comment: "Total amount received from sponsors"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_outstanding_balance"
      display_name: "Total Outstanding Balance"
      expr: SUM(CAST(outstanding_balance AS DOUBLE))
      comment: "Total outstanding accounts receivable balance"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_pass_through_amount"
      display_name: "Total Pass-Through Amount"
      expr: SUM(CAST(pass_through_amount AS DOUBLE))
      comment: "Total pass-through costs billed to sponsors"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "invoice_count"
      display_name: "Invoice Count"
      expr: COUNT(sponsor_invoice_id)
      comment: "Number of sponsor invoices"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_invoice_amount"
      display_name: "Average Invoice Amount"
      expr: AVG(CAST(net_amount AS DOUBLE))
      comment: "Average net invoice amount"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "collection_rate"
      display_name: "Collection Rate"
      expr: SUM(CAST(amount_paid AS DOUBLE)) / NULLIF(SUM(CAST(net_amount AS DOUBLE)), 0)
      comment: "Percentage of invoiced amount collected"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "avg_days_to_payment"
      display_name: "Average Days to Payment"
      expr: AVG(DATEDIFF(payment_received_date, invoice_date))
      comment: "Average number of days from invoice to payment receipt"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "paid_invoice_count"
      display_name: "Paid Invoice Count"
      expr: COUNT(CASE WHEN payment_received_date IS NOT NULL THEN sponsor_invoice_id END)
      comment: "Number of invoices that have been paid"
      format:
        type: number
        decimal_places:
          type: all
    - name: "overdue_invoice_count"
      display_name: "Overdue Invoice Count"
      expr: COUNT(CASE WHEN payment_received_date IS NULL AND due_date < CURRENT_DATE() THEN sponsor_invoice_id END)
      comment: "Number of invoices past due date"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`finance_study_budget`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Study-level budget planning and control metrics tracking total budget, cost categories, and budget version management"
  source: "`clinical_trials_ecm`.`finance`.`study_budget`"
  dimensions:
    - name: "budget_status"
      display_name: "Budget Status"
      expr: budget_status
      comment: "Current status of the study budget"
    - name: "budget_type"
      display_name: "Budget Type"
      expr: budget_type
      comment: "Type of budget (original, revised, forecast, etc.)"
    - name: "approval_status"
      display_name: "Approval Status"
      expr: approval_status
      comment: "Approval status of the budget"
    - name: "cost_category"
      display_name: "Cost Category"
      expr: cost_category
      comment: "Primary cost category for the budget"
    - name: "is_pass_through_billable"
      display_name: "Pass-Through Billable"
      expr: is_pass_through_billable
      comment: "Whether pass-through costs are billable to sponsor"
    - name: "is_sox_controlled"
      display_name: "SOX Controlled"
      expr: is_sox_controlled
      comment: "Whether this budget is subject to SOX controls"
    - name: "fiscal_year"
      display_name: "Fiscal Year"
      expr: fiscal_year
      comment: "Fiscal year of the budget"
    - name: "budget_version"
      display_name: "Budget Version"
      expr: budget_version
      comment: "Version number of the budget"
  measures:
    - name: "total_budget_amount"
      display_name: "Total Budget Amount"
      expr: SUM(CAST(total_budget_amount AS DOUBLE))
      comment: "Total study budget amount across all cost categories"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_direct_cost"
      display_name: "Total Direct Cost"
      expr: SUM(CAST(direct_cost_amount AS DOUBLE))
      comment: "Total direct cost budget"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_indirect_cost"
      display_name: "Total Indirect Cost"
      expr: SUM(CAST(indirect_cost_amount AS DOUBLE))
      comment: "Total indirect cost budget"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_overhead_amount"
      display_name: "Total Overhead Amount"
      expr: SUM(CAST(overhead_amount AS DOUBLE))
      comment: "Total overhead budget allocation"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_contingency_amount"
      display_name: "Total Contingency Amount"
      expr: SUM(CAST(contingency_amount AS DOUBLE))
      comment: "Total contingency reserve budget"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_pass_through_estimate"
      display_name: "Total Pass-Through Estimate"
      expr: SUM(CAST(pass_through_estimate_amount AS DOUBLE))
      comment: "Total estimated pass-through costs"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_investigator_grant_amount"
      display_name: "Total Investigator Grant Amount"
      expr: SUM(CAST(investigator_grant_amount AS DOUBLE))
      comment: "Total investigator grant budget"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_patient_stipend_amount"
      display_name: "Total Patient Stipend Amount"
      expr: SUM(CAST(patient_stipend_amount AS DOUBLE))
      comment: "Total patient stipend budget"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "study_budget_count"
      display_name: "Study Budget Count"
      expr: COUNT(study_budget_id)
      comment: "Number of study budgets"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_budget_per_study"
      display_name: "Average Budget per Study"
      expr: AVG(CAST(total_budget_amount AS DOUBLE))
      comment: "Average total budget amount per study"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_planned_site_count"
      display_name: "Average Planned Site Count"
      expr: AVG(CAST(planned_site_count AS DOUBLE))
      comment: "Average number of planned sites per study"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "avg_planned_subject_count"
      display_name: "Average Planned Subject Count"
      expr: AVG(CAST(planned_subject_count AS DOUBLE))
      comment: "Average number of planned subjects per study"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "contingency_rate"
      display_name: "Contingency Rate"
      expr: SUM(CAST(contingency_amount AS DOUBLE)) / NULLIF(SUM(CAST(total_budget_amount AS DOUBLE)), 0)
      comment: "Contingency reserve as percentage of total budget"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "overhead_rate"
      display_name: "Overhead Rate"
      expr: SUM(CAST(overhead_amount AS DOUBLE)) / NULLIF(SUM(CAST(direct_cost_amount AS DOUBLE)), 0)
      comment: "Overhead as percentage of direct costs"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`finance_vendor_invoice`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Vendor payables and cost management metrics tracking invoice processing, payment timing, and accounts payable performance"
  source: "`clinical_trials_ecm`.`finance`.`vendor_invoice`"
  dimensions:
    - name: "invoice_status"
      display_name: "Invoice Status"
      expr: invoice_status
      comment: "Current processing status of the vendor invoice"
    - name: "invoice_type"
      display_name: "Invoice Type"
      expr: invoice_type
      comment: "Type of vendor invoice"
    - name: "is_pass_through"
      display_name: "Pass-Through"
      expr: is_pass_through
      comment: "Whether this is a pass-through cost to be rebilled"
    - name: "payment_method"
      display_name: "Payment Method"
      expr: payment_method
      comment: "Method used for payment"
    - name: "three_way_match_status"
      display_name: "Three-Way Match Status"
      expr: three_way_match_status
      comment: "Status of three-way match (PO, receipt, invoice)"
    - name: "sponsor_reimbursement_status"
      display_name: "Sponsor Reimbursement Status"
      expr: sponsor_reimbursement_status
      comment: "Status of sponsor reimbursement for pass-through costs"
    - name: "invoice_month"
      display_name: "Invoice Month"
      expr: DATE_TRUNC('month', invoice_date)
      comment: "Month when the invoice was received"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "invoice_quarter"
      display_name: "Invoice Quarter"
      expr: DATE_TRUNC('quarter', invoice_date)
      comment: "Quarter when the invoice was received"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "payment_aging_bucket"
      display_name: "Payment Aging Bucket"
      expr: CASE WHEN payment_date IS NOT NULL THEN 'Paid' WHEN DATEDIFF(CURRENT_DATE(), due_date) <= 0 THEN 'Current' WHEN DATEDIFF(CURRENT_DATE(), due_date) <= 30 THEN '1-30 Days' WHEN DATEDIFF(CURRENT_DATE(), due_date) <= 60 THEN '31-60 Days' ELSE '60+ Days' END
      comment: "Aging bucket for accounts payable analysis"
  measures:
    - name: "total_gross_amount"
      display_name: "Total Gross Amount"
      expr: SUM(CAST(gross_amount AS DOUBLE))
      comment: "Total gross invoice amount from vendors"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_net_amount"
      display_name: "Total Net Amount"
      expr: SUM(CAST(net_amount AS DOUBLE))
      comment: "Total net invoice amount after discounts"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_tax_amount"
      display_name: "Total Tax Amount"
      expr: SUM(CAST(tax_amount AS DOUBLE))
      comment: "Total tax amount on vendor invoices"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_early_payment_discount"
      display_name: "Total Early Payment Discount"
      expr: SUM(CAST(early_payment_discount_amount AS DOUBLE))
      comment: "Total early payment discounts captured"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "vendor_invoice_count"
      display_name: "Vendor Invoice Count"
      expr: COUNT(vendor_invoice_id)
      comment: "Number of vendor invoices"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_invoice_amount"
      display_name: "Average Invoice Amount"
      expr: AVG(CAST(net_amount AS DOUBLE))
      comment: "Average net invoice amount per vendor invoice"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_days_to_payment"
      display_name: "Average Days to Payment"
      expr: AVG(DATEDIFF(payment_date, invoice_date))
      comment: "Average number of days from invoice receipt to payment"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "early_payment_discount_capture_rate"
      display_name: "Early Payment Discount Capture Rate"
      expr: SUM(CAST(early_payment_discount_amount AS DOUBLE)) / NULLIF(SUM(CAST(gross_amount AS DOUBLE)), 0)
      comment: "Percentage of potential early payment discounts captured"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "three_way_match_success_rate"
      display_name: "Three-Way Match Success Rate"
      expr: COUNT(CASE WHEN three_way_match_status = 'Matched' THEN vendor_invoice_id END) / NULLIF(CAST(COUNT(vendor_invoice_id) AS DOUBLE), 0)
      comment: "Percentage of invoices successfully three-way matched"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "paid_invoice_count"
      display_name: "Paid Invoice Count"
      expr: COUNT(CASE WHEN payment_date IS NOT NULL THEN vendor_invoice_id END)
      comment: "Number of vendor invoices that have been paid"
      format:
        type: number
        decimal_places:
          type: all
    - name: "overdue_invoice_count"
      display_name: "Overdue Invoice Count"
      expr: COUNT(CASE WHEN payment_date IS NULL AND due_date < CURRENT_DATE() THEN vendor_invoice_id END)
      comment: "Number of vendor invoices past due date"
      format:
        type: number
        decimal_places:
          type: all
$$;
