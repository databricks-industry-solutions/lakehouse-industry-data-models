-- Metric views for domain: beneficiary | Business: Asset Management | Version: 1 | Generated on: 2026-11-10 14:18:58

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_active_membership`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Count of active pension plan members by status and country, the core beneficiary population."
  source: "`asset_management`.`beneficiary`.`member`"
  dimensions:
    - name: "Membership Status"
      display_name: "Membership status"
      expr: membership_status
      comment: "Status"
    - name: "Country"
      display_name: "Country"
      expr: country_code
      comment: "Country"
    - name: "Gender"
      display_name: "Gender"
      expr: gender
      comment: "Gender"
  measures:
    - name: "Members"
      display_name: "Members"
      expr: COUNT(1)
      comment: "Members"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Active %"
      display_name: "Active %"
      expr: ROUND(100.0 * SUM(CASE WHEN membership_status = 'ACTIVE' THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Active share"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_benefit_net_to_gross`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Net-to-gross payout ratio reflecting tax withholding and deduction intensity on benefits."
  source: "`asset_management`.`beneficiary`.`benefit_payment`"
  filter: payment_approval_status = 'APPROVED'
  dimensions:
    - name: "Payment Frequency"
      display_name: "Payment frequency"
      expr: payment_frequency
      comment: "Frequency"
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency"
  measures:
    - name: "Net-to-Gross %"
      display_name: "Net-to-gross %"
      expr: ROUND(100.0 * SUM(CAST(net_amount AS DOUBLE)) / NULLIF(SUM(CAST(gross_amount AS DOUBLE)),0),2)
      comment: "Net over gross"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Payments"
      display_name: "Payments"
      expr: COUNT(1)
      comment: "Payments"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_benefit_option_mix`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Menu of retirement benefit options and commutation/indexation parameters by pool."
  source: "`asset_management`.`beneficiary`.`benefit_option`"
  filter: benefit_option_status = 'ACTIVE'
  dimensions:
    - name: "Death Benefit Type"
      display_name: "Death benefit type"
      expr: death_benefit_type
      comment: "Death benefit"
    - name: "Indexation Type"
      display_name: "Indexation type"
      expr: indexation_type
      comment: "Indexation"
  measures:
    - name: "Options"
      display_name: "Options"
      expr: COUNT(1)
      comment: "Options"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Max Commutation %"
      display_name: "Avg max commutation %"
      expr: ROUND(AVG(CAST(commutation_max_pct AS DOUBLE)),2)
      comment: "Commutation max"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Commutation Allowed %"
      display_name: "Commutation allowed %"
      expr: ROUND(100.0 * SUM(CASE WHEN commutation_allowed = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Commutation allowed"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_benefit_payment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Pension benefit disbursement KPIs: gross/net payout, tax withholding, clawback and overpayment recovery, payment timeliness and dispute exposure. Core to Beneficiary Annual Statement and payment-integrity controls."
  source: "`asset_management`.`beneficiary`.`benefit_payment`"
  dimensions:
    - name: "Payment Status"
      display_name: "Payment Status"
      expr: payment_status
      comment: "Lifecycle status of the benefit payment (e.g. paid, pending, failed, held)."
    - name: "Payment Approval Status"
      display_name: "Approval Status"
      expr: payment_approval_status
      comment: "Approval workflow state of the payment for controls segmentation."
    - name: "Payment Channel"
      display_name: "Payment Channel"
      expr: payment_channel
      comment: "Channel through which the payment was disbursed (e.g. EFT, cheque, wire)."
    - name: "Payment Method"
      display_name: "Payment Method"
      expr: payment_method
      comment: "Settlement method used for the benefit payment."
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "ISO currency code of the payment."
    - name: "Dispute Status"
      display_name: "Dispute Status"
      expr: payment_dispute_status
      comment: "Status of any dispute raised against the payment."
    - name: "Payment Month"
      display_name: "Payment Month"
      expr: DATE_TRUNC('month', payment_date)
      comment: "Payment date truncated to month for time-intelligence."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Payment Quarter"
      display_name: "Payment Quarter"
      expr: DATE_TRUNC('quarter', payment_date)
      comment: "Payment date truncated to quarter."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Payment Year"
      display_name: "Payment Year"
      expr: DATE_TRUNC('year', payment_date)
      comment: "Payment date truncated to year."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Payment Date"
      display_name: "Payment Date"
      expr: payment_date
      comment: "Raw payment date used as the order key for period-to-date windows."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Payment Count"
      display_name: "Payment Count"
      expr: COUNT(1)
      comment: "Total number of benefit payment records."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Members Paid"
      display_name: "Members Paid"
      expr: COUNT(DISTINCT member_id)
      comment: "Distinct members who received a benefit payment — beneficiary reach."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Gross Paid"
      display_name: "Total Gross Paid"
      expr: SUM(CAST(gross_amount AS DOUBLE))
      comment: "Total gross benefit amount disbursed — primary payout exposure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Net Paid"
      display_name: "Total Net Paid"
      expr: SUM(CAST(net_amount AS DOUBLE))
      comment: "Total net benefit amount paid to beneficiaries after deductions."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Tax Withheld"
      display_name: "Total Tax Withheld"
      expr: SUM(CAST(tax_withholding_amount AS DOUBLE))
      comment: "Total tax withheld on benefit payments — regulatory remittance exposure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Clawback"
      display_name: "Total Clawback"
      expr: SUM(CAST(clawback_amount AS DOUBLE))
      comment: "Total clawback amount applied against payments — recovery activity."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Overpayment Recovery"
      display_name: "Total Overpayment Recovery"
      expr: SUM(CAST(overpayment_recovery_amount AS DOUBLE))
      comment: "Total overpayment recovered via payment deductions."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Net Payment"
      display_name: "Avg Net Payment"
      expr: AVG(CAST(net_amount AS DOUBLE))
      comment: "Average net payment per record — benefit sizing signal."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Dispute Amount"
      display_name: "Total Dispute Amount"
      expr: SUM(CAST(payment_dispute_amount AS DOUBLE))
      comment: "Total monetary value under dispute — reputational and operational risk."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Effective Tax Withholding Rate"
      display_name: "Effective Tax Withholding Rate"
      expr: ROUND(100.0 * SUM(CAST(tax_withholding_amount AS DOUBLE)) / NULLIF(SUM(CAST(gross_amount AS DOUBLE)), 0), 2)
      comment: "Tax withheld as a percentage of gross paid — remittance accuracy check."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Gross Paid CM"
      display_name: "Gross Paid (Current Month)"
      expr: SUM(CAST(gross_amount AS DOUBLE))
      comment: "Gross paid for the current month bucket."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Payment Month
          range: current
          semiadditive: last
    - name: "Gross Paid PM"
      display_name: "Gross Paid (Prior Month)"
      expr: SUM(CAST(gross_amount AS DOUBLE))
      comment: "Gross paid for the prior month bucket."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Payment Month
          range: current
          semiadditive: last
          offset: -1 month
    - name: "Gross Paid MoM"
      display_name: "Gross Paid MoM %"
      expr: (AGG(`Gross Paid CM`) - AGG(`Gross Paid PM`)) / NULLIF(AGG(`Gross Paid PM`), 0)
      comment: "Month-over-month growth in gross benefit disbursement."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_benefit_payments_outflow`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Gross and net pension benefits disbursed, the primary liability-side cash outflow."
  source: "`asset_management`.`beneficiary`.`benefit_payment`"
  filter: payment_approval_status = 'APPROVED'
  dimensions:
    - name: "Payment Channel"
      display_name: "Payment channel"
      expr: payment_channel
      comment: "Channel"
    - name: "Payment Frequency"
      display_name: "Payment frequency"
      expr: payment_frequency
      comment: "Frequency"
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency"
  measures:
    - name: "Gross Paid"
      display_name: "Gross paid"
      expr: SUM(CAST(gross_amount AS DOUBLE))
      comment: "Gross benefit"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Net Paid"
      display_name: "Net paid"
      expr: SUM(CAST(net_amount AS DOUBLE))
      comment: "Net benefit"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Clawback Recovered"
      display_name: "Clawback recovered"
      expr: SUM(CAST(clawback_amount AS DOUBLE))
      comment: "Clawbacks"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Dispute Rate %"
      display_name: "Dispute rate %"
      expr: ROUND(100.0 * SUM(CASE WHEN payment_dispute_status = 'OPEN' THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Disputed share"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_contribution_fee_yield`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Fees charged on contributions as a share of contribution value, an admin-cost efficiency ratio."
  source: "`asset_management`.`beneficiary`.`contribution_record`"
  filter: contribution_approval_status = 'APPROVED'
  dimensions:
    - name: "Fee Type"
      display_name: "Fee type"
      expr: contribution_fee_type
      comment: "Fee type"
    - name: "Currency"
      display_name: "Currency"
      expr: contribution_currency_code
      comment: "Currency"
  measures:
    - name: "Total Fees"
      display_name: "Total fees"
      expr: SUM(CAST(contribution_fee_amount AS DOUBLE))
      comment: "Fees"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_contribution_rate_schedule`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Effective employee/employer contribution rate tiers and pensionable earnings bounds."
  source: "`asset_management`.`beneficiary`.`contribution_rate`"
  dimensions:
    - name: "Employment Category"
      display_name: "Employment category"
      expr: employment_category
      comment: "Category"
    - name: "Plan Type"
      display_name: "Plan type"
      expr: plan_type
      comment: "Plan"
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency"
  measures:
    - name: "Avg Max Pensionable Earnings"
      display_name: "Avg max pensionable earnings"
      expr: ROUND(AVG(CAST(max_pensionable_earnings AS DOUBLE)),2)
      comment: "Max earnings"
    - name: "Avg Indexation Rate"
      display_name: "Avg indexation rate"
      expr: ROUND(AVG(CAST(indexation_rate AS DOUBLE)),2)
      comment: "Indexation"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Rate Records"
      display_name: "Rate records"
      expr: COUNT(1)
      comment: "Records"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_contribution_record`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Member contribution inflow KPIs: employee vs employer contributions, fees, tax, approval throughput. Steers net contribution inflow and plan funding capacity."
  source: "`asset_management`.`beneficiary`.`contribution_record`"
  dimensions:
    - name: "Contribution Status"
      display_name: "Contribution Status"
      expr: contribution_status
      comment: "Processing status of the contribution record."
    - name: "Contribution Type"
      display_name: "Contribution Type"
      expr: contribution_type
      comment: "Type classification of the contribution."
    - name: "Contribution Method"
      display_name: "Contribution Method"
      expr: contribution_method
      comment: "Method by which the contribution was made."
    - name: "Approval Status"
      display_name: "Approval Status"
      expr: contribution_approval_status
      comment: "Approval workflow state of the contribution."
    - name: "Currency"
      display_name: "Currency"
      expr: contribution_currency_code
      comment: "ISO currency code of the contribution."
    - name: "Contribution Month"
      display_name: "Contribution Month"
      expr: DATE_TRUNC('month', contribution_date)
      comment: "Contribution timestamp truncated to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Contribution Year"
      display_name: "Contribution Year"
      expr: DATE_TRUNC('year', contribution_date)
      comment: "Contribution timestamp truncated to year."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Contribution Date"
      display_name: "Contribution Date"
      expr: contribution_date
      comment: "Raw contribution timestamp used as order key for period-to-date windows."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Contribution Count"
      display_name: "Contribution Count"
      expr: COUNT(1)
      comment: "Total number of contribution records."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Contributing Members"
      display_name: "Contributing Members"
      expr: COUNT(DISTINCT member_id)
      comment: "Distinct members with a contribution record."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Contribution"
      display_name: "Total Contribution"
      expr: SUM(CAST(total_contribution_amount AS DOUBLE))
      comment: "Total contribution inflow — primary funding driver."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Employee Contribution"
      display_name: "Total Employee Contribution"
      expr: SUM(CAST(employee_contribution_amount AS DOUBLE))
      comment: "Total employee-funded contribution."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Employer Contribution"
      display_name: "Total Employer Contribution"
      expr: SUM(CAST(employer_contribution_amount AS DOUBLE))
      comment: "Total employer-funded contribution."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Fees"
      display_name: "Total Fees"
      expr: SUM(CAST(contribution_fee_amount AS DOUBLE))
      comment: "Total fees charged on contributions."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Contribution"
      display_name: "Avg Contribution"
      expr: AVG(CAST(total_contribution_amount AS DOUBLE))
      comment: "Average contribution amount per record."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Employer Funding Share"
      display_name: "Employer Funding Share"
      expr: ROUND(100.0 * SUM(CAST(employer_contribution_amount AS DOUBLE)) / NULLIF(SUM(CAST(total_contribution_amount AS DOUBLE)), 0), 2)
      comment: "Employer contribution as a percentage of total — funding mix."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Contribution YTD"
      display_name: "Contribution YTD"
      expr: SUM(CAST(total_contribution_amount AS DOUBLE))
      comment: "Year-to-date cumulative contribution inflow."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Contribution Date
          range: cumulative
          semiadditive: last
        - order: Contribution Year
          range: current
          semiadditive: last
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_contribution_target_currency`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Total contributions converted to a parameterized reporting currency for consolidated funding view."
  source: "`asset_management`.`beneficiary`.`contribution_record`"
  parameters:
    - name: p_target_currency
      data_type: STRING
      default: "'USD'"
  filter: contribution_approval_status = 'APPROVED'
  dimensions:
    - name: "Currency"
      display_name: "Currency"
      expr: contribution_currency_code
      comment: "Currency"
    - name: "Method"
      display_name: "Method"
      expr: contribution_method
      comment: "Method"
  measures:
    - name: "Records"
      display_name: "Records"
      expr: COUNT(1)
      comment: "Records"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_contributor_pool_overview`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Contribution rate structure across the four contributor pools for funding policy monitoring."
  source: "`asset_management`.`beneficiary`.`contributor_pool`"
  dimensions:
    - name: "Pool Type"
      display_name: "Pool type"
      expr: contributor_pool_type
      comment: "Pool type"
    - name: "Employment Category"
      display_name: "Employment category"
      expr: employment_category
      comment: "Category"
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency"
  measures:
    - name: "Avg Contribution Rate"
      display_name: "Avg contribution rate"
      expr: ROUND(AVG(CAST(contribution_rate AS DOUBLE)),2)
      comment: "Rate"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Indexation Rate"
      display_name: "Avg indexation rate"
      expr: ROUND(AVG(CAST(indexation_rate AS DOUBLE)),2)
      comment: "Indexation"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Pools"
      display_name: "Pools"
      expr: COUNT(1)
      comment: "Pools"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_designated_beneficiary_coverage`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Designated survivor beneficiaries on file and benefit fractions designated."
  source: "`asset_management`.`beneficiary`.`designated_beneficiary`"
  dimensions:
    - name: "Benefit Type"
      display_name: "Benefit type"
      expr: benefit_type
      comment: "Type"
    - name: "Status"
      display_name: "Status"
      expr: beneficiary_status
      comment: "Status"
    - name: "Country"
      display_name: "Country"
      expr: country_code
      comment: "Country"
  measures:
    - name: "Designations"
      display_name: "Designations"
      expr: COUNT(1)
      comment: "Designations"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Benefit Fraction %"
      display_name: "Avg benefit fraction %"
      expr: ROUND(AVG(CAST(beneficiary_fraction_pct AS DOUBLE)),2)
      comment: "Fraction"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Benefit Amount"
      display_name: "Total benefit amount"
      expr: SUM(CAST(benefit_amount AS DOUBLE))
      comment: "Benefit amount"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_designated_beneficiary_deaths`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Recorded death events among beneficiaries by cause category for mortality experience."
  source: "`asset_management`.`beneficiary`.`designated_beneficiary`"
  dimensions:
    - name: "Death Cause Category"
      display_name: "Death cause category"
      expr: death_cause_category
      comment: "Cause"
    - name: "Country"
      display_name: "Country"
      expr: country_code
      comment: "Country"
  measures:
    - name: "Death Records"
      display_name: "Death records"
      expr: COUNT(death_date)
      comment: "Deaths recorded"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Beneficiaries"
      display_name: "Beneficiaries"
      expr: COUNT(1)
      comment: "Beneficiaries"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_employer_remittance`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Employer contribution remittance KPIs: total remittances, arrears, late submissions, penalties, reconciliation variance. Steers employer compliance and cash-inflow predictability."
  source: "`asset_management`.`beneficiary`.`employer_remittance`"
  dimensions:
    - name: "Remittance Status"
      display_name: "Remittance Status"
      expr: remittance_status
      comment: "Processing status of the remittance."
    - name: "Remittance Type"
      display_name: "Remittance Type"
      expr: remittance_type
      comment: "Type classification of the employer remittance."
    - name: "Reconciliation Status"
      display_name: "Reconciliation Status"
      expr: reconciliation_status
      comment: "Reconciliation outcome of the remittance."
    - name: "Remittance Channel"
      display_name: "Remittance Channel"
      expr: remittance_channel
      comment: "Channel used to submit the remittance."
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "ISO currency code of the remittance."
    - name: "Submission Month"
      display_name: "Submission Month"
      expr: DATE_TRUNC('month', submission_date)
      comment: "Remittance submission date truncated to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Submission Year"
      display_name: "Submission Year"
      expr: DATE_TRUNC('year', submission_date)
      comment: "Remittance submission date truncated to year."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Remittance Count"
      display_name: "Remittance Count"
      expr: COUNT(1)
      comment: "Total number of employer remittance records."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Employers Remitting"
      display_name: "Employers Remitting"
      expr: COUNT(DISTINCT participating_employer_id)
      comment: "Distinct participating employers that submitted remittances."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Remittance Amount"
      display_name: "Total Remittance Amount"
      expr: SUM(CAST(total_remittance_amount AS DOUBLE))
      comment: "Total contribution cash remitted by employers — core inflow."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Employer Contribution"
      display_name: "Total Employer Contribution"
      expr: SUM(CAST(employer_contribution_amount AS DOUBLE))
      comment: "Total employer-funded contribution portion."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Employee Contribution"
      display_name: "Total Employee Contribution"
      expr: SUM(CAST(employee_contribution_amount AS DOUBLE))
      comment: "Total employee-funded contribution portion within remittances."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Arrears"
      display_name: "Total Arrears"
      expr: SUM(CAST(arrears_amount AS DOUBLE))
      comment: "Total arrears owed on remittances — compliance risk."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Late Penalty"
      display_name: "Total Late Penalty"
      expr: SUM(CAST(late_penalty_amount AS DOUBLE))
      comment: "Total late-payment penalties levied on employers."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Variance Amount"
      display_name: "Total Variance Amount"
      expr: SUM(CAST(variance_amount AS DOUBLE))
      comment: "Total reconciliation variance between expected and received amounts."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Days Late"
      display_name: "Avg Days Late"
      expr: AVG(CAST(days_late AS DOUBLE))
      comment: "Average number of days remittances were submitted past due."
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Late Submission Rate"
      display_name: "Late Submission Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN is_late_submission = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of remittances submitted late — employer compliance health."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_employer_remittance_adjustment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Adjustment amounts applied to employer remittances, an operational data-quality signal."
  source: "`asset_management`.`beneficiary`.`employer_remittance`"
  dimensions:
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency"
  measures:
    - name: "Total Adjustment"
      display_name: "Total adjustment"
      expr: SUM(CAST(adjustment_amount AS DOUBLE))
      comment: "Adjustments"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Remittances"
      display_name: "Remittances"
      expr: COUNT(1)
      comment: "Remittances"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Adjusted %"
      display_name: "Adjusted %"
      expr: ROUND(100.0 * SUM(CASE WHEN adjustment_amount <> 0 THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Adjusted share"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_employer_remittance_timeliness`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "On-time versus late employer contribution remittances and arrears outstanding."
  source: "`asset_management`.`beneficiary`.`employer_remittance`"
  dimensions:
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency"
    - name: "Status"
      display_name: "Status"
      expr: remittance_status
      comment: "Status"
  measures:
    - name: "Employee Contributions"
      display_name: "Employee contributions"
      expr: SUM(CAST(employee_contribution_amount AS DOUBLE))
      comment: "Employee portion"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Employer Contributions"
      display_name: "Employer contributions"
      expr: SUM(CAST(employer_contribution_amount AS DOUBLE))
      comment: "Employer portion"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Arrears"
      display_name: "Total arrears"
      expr: SUM(CAST(arrears_amount AS DOUBLE))
      comment: "Arrears"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Days Late"
      display_name: "Avg days late"
      expr: ROUND(AVG(CAST(days_late AS DOUBLE)),2)
      comment: "Late days"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_entitlement_liability`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Total calculated pension entitlement amounts owed to members by type and status."
  source: "`asset_management`.`beneficiary`.`entitlement`"
  dimensions:
    - name: "Entitlement Type"
      display_name: "Entitlement type"
      expr: entitlement_type
      comment: "Type"
    - name: "Entitlement Status"
      display_name: "Entitlement status"
      expr: entitlement_status
      comment: "Status"
    - name: "Benefit Frequency"
      display_name: "Benefit frequency"
      expr: benefit_frequency
      comment: "Frequency"
    - name: "Currency"
      display_name: "Currency"
      expr: benefit_currency
      comment: "Currency"
  measures:
    - name: "Total Benefit Amount"
      display_name: "Total benefit amount"
      expr: SUM(CAST(benefit_amount AS DOUBLE))
      comment: "Entitlement amount"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Indexation Rate"
      display_name: "Avg indexation rate"
      expr: ROUND(AVG(CAST(indexation_rate AS DOUBLE)),2)
      comment: "Indexation"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Survivor Benefit %"
      display_name: "Avg survivor benefit %"
      expr: ROUND(AVG(CAST(survivor_benefit_percentage AS DOUBLE)),2)
      comment: "Survivor %"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_indexation_adjustment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Cost-of-living indexation KPIs: adjustment amounts, liability impact, cap/floor application, applied indexation rates. Steers inflation-linked liability growth and TCFD/actuarial reporting."
  source: "`asset_management`.`beneficiary`.`indexation_adjustment`"
  dimensions:
    - name: "Adjustment Status"
      display_name: "Adjustment Status"
      expr: adjustment_status
      comment: "Processing status of the indexation adjustment."
    - name: "Indexation Type"
      display_name: "Indexation Type"
      expr: indexation_type
      comment: "Type of indexation applied (e.g. CPI, fixed)."
    - name: "Plan Type"
      display_name: "Plan Type"
      expr: plan_type
      comment: "Plan type the adjustment applies to."
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "ISO currency code of the adjustment."
    - name: "Effective Year"
      display_name: "Effective Year"
      expr: DATE_TRUNC('year', effective_date)
      comment: "Adjustment effective date truncated to year."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Adjustment Count"
      display_name: "Adjustment Count"
      expr: COUNT(1)
      comment: "Total number of indexation adjustment records."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Members Adjusted"
      display_name: "Members Adjusted"
      expr: COUNT(DISTINCT member_id)
      comment: "Distinct members receiving an indexation adjustment."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Adjustment Amount"
      display_name: "Total Adjustment Amount"
      expr: SUM(CAST(adjustment_amount AS DOUBLE))
      comment: "Total benefit increase from indexation adjustments."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Liability Impact"
      display_name: "Total Liability Impact"
      expr: SUM(CAST(liability_impact_amount AS DOUBLE))
      comment: "Total actuarial liability impact of indexation — funding sensitivity."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Indexation Rate"
      display_name: "Avg Indexation Rate"
      expr: AVG(CAST(indexation_rate AS DOUBLE))
      comment: "Average applied indexation rate across adjustments."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "Rate Capped Rate"
      display_name: "Rate Capped Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN is_rate_capped = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of adjustments where indexation hit the cap — inflation pressure signal."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_indexation_adjustment_coverage`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Approval throughput of annual indexation adjustments across the pension book."
  source: "`asset_management`.`beneficiary`.`indexation_adjustment`"
  dimensions:
    - name: "Year"
      display_name: "Year"
      expr: adjustment_year
      comment: "Year"
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency"
  measures:
    - name: "Approved %"
      display_name: "Approved %"
      expr: ROUND(100.0 * SUM(CASE WHEN adjustment_status = 'APPROVED' THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Approved share"
    - name: "Total Adjustment"
      display_name: "Total adjustment"
      expr: SUM(CAST(adjustment_amount AS DOUBLE))
      comment: "Adjustment"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_indexation_cost`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Annual cost-of-living adjustment cost applied to pensions in payment."
  source: "`asset_management`.`beneficiary`.`indexation_adjustment`"
  dimensions:
    - name: "Adjustment Year"
      display_name: "Adjustment year"
      expr: adjustment_year
      comment: "Year"
    - name: "Status"
      display_name: "Status"
      expr: adjustment_status
      comment: "Status"
    - name: "CPI Measure"
      display_name: "Cpi measure"
      expr: cpi_measure_used
      comment: "CPI basis"
  measures:
    - name: "Total Adjustment"
      display_name: "Total adjustment"
      expr: SUM(CAST(adjustment_amount AS DOUBLE))
      comment: "Adjustment cost"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Adjusted Benefit Total"
      display_name: "Adjusted benefit total"
      expr: SUM(CAST(adjusted_benefit_amount AS DOUBLE))
      comment: "Adjusted benefit"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Records"
      display_name: "Records"
      expr: COUNT(1)
      comment: "Adjustment records"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_member`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Membership demographics and lifecycle KPIs: active membership base, status mix, plan-type distribution. Steers plan scale, actuarial population and engagement decisions."
  source: "`asset_management`.`beneficiary`.`member`"
  dimensions:
    - name: "Membership Status"
      display_name: "Membership Status"
      expr: membership_status
      comment: "Current membership status (e.g. active, deferred, retired, terminated)."
    - name: "Plan Status"
      display_name: "Plan Status"
      expr: plan_status
      comment: "Plan-level status of the member."
    - name: "Plan Type"
      display_name: "Plan Type"
      expr: plan_type
      comment: "Type of pension plan the member belongs to."
    - name: "Gender"
      display_name: "Gender"
      expr: gender
      comment: "Member gender for demographic segmentation."
    - name: "Country"
      display_name: "Country"
      expr: country_code
      comment: "Member country of residence."
    - name: "Membership Start Month"
      display_name: "Membership Start Month"
      expr: DATE_TRUNC('month', membership_start_date)
      comment: "Membership start date truncated to month (cohort entry)."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Membership Start Year"
      display_name: "Membership Start Year"
      expr: DATE_TRUNC('year', membership_start_date)
      comment: "Membership start date truncated to year."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Member Count"
      display_name: "Member Count"
      expr: COUNT(DISTINCT member_id)
      comment: "Distinct members — total plan population."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Active Members"
      display_name: "Active Members"
      expr: COUNT(DISTINCT CASE WHEN membership_status = 'active' THEN member_id END)
      comment: "Distinct members with active status — the contributing base."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Member Age"
      display_name: "Avg Member Age"
      expr: AVG(CAST(DATEDIFF(CURRENT_DATE(), date_of_birth) / 365.25 AS DOUBLE))
      comment: "Average member age in years — actuarial population aging signal."
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Active Member Rate"
      display_name: "Active Member Rate"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN membership_status = 'active' THEN member_id END) / NULLIF(COUNT(DISTINCT member_id), 0), 2)
      comment: "Active members as a percentage of total membership — engagement health."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_member_address_mailability`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Share of member addresses flagged do-not-mail or foreign for communications planning."
  source: "`asset_management`.`beneficiary`.`member_address`"
  dimensions:
    - name: "Address Type"
      display_name: "Address type"
      expr: address_type
      comment: "Type"
    - name: "Country"
      display_name: "Country"
      expr: country_code
      comment: "Country"
    - name: "Status"
      display_name: "Status"
      expr: address_status
      comment: "Status"
  measures:
    - name: "Addresses"
      display_name: "Addresses"
      expr: COUNT(1)
      comment: "Addresses"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Do-Not-Mail %"
      display_name: "Do-not-mail %"
      expr: ROUND(100.0 * SUM(CASE WHEN do_not_mail = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "DNM share"
    - name: "Foreign %"
      display_name: "Foreign %"
      expr: ROUND(100.0 * SUM(CASE WHEN foreign_address_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Foreign share"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_member_contact_consent`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Verified and consented contact channels supporting beneficiary communication SLAs."
  source: "`asset_management`.`beneficiary`.`member_contact`"
  dimensions:
    - name: "Contact Type"
      display_name: "Contact type"
      expr: contact_type
      comment: "Channel"
    - name: "Status"
      display_name: "Status"
      expr: contact_status
      comment: "Status"
    - name: "Language Pref"
      display_name: "Language pref"
      expr: language_preference
      comment: "Language"
  measures:
    - name: "Contacts"
      display_name: "Contacts"
      expr: COUNT(1)
      comment: "Contact records"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Verified %"
      display_name: "Verified %"
      expr: ROUND(100.0 * SUM(CASE WHEN is_verified = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Verified share"
    - name: "Bounce Total"
      display_name: "Bounce total"
      expr: SUM(CAST(bounce_count AS DOUBLE))
      comment: "Bounces"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_member_document_backlog`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Member document volume, status, and PII/PHI classification for records management SLA."
  source: "`asset_management`.`beneficiary`.`member_document`"
  dimensions:
    - name: "Document Category"
      display_name: "Document category"
      expr: document_category
      comment: "Category"
    - name: "Status"
      display_name: "Status"
      expr: document_status
      comment: "Status"
    - name: "Classification"
      display_name: "Classification"
      expr: data_classification
      comment: "Classification"
  measures:
    - name: "Documents"
      display_name: "Documents"
      expr: COUNT(1)
      comment: "Documents"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Contains PII %"
      display_name: "Contains pii %"
      expr: ROUND(100.0 * SUM(CASE WHEN contains_pii_flag = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "PII share"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_member_enrollment_rate`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "New enrollments and eligibility verification outcomes by status and type."
  source: "`asset_management`.`beneficiary`.`member_enrollment`"
  dimensions:
    - name: "Enrollment Status"
      display_name: "Enrollment status"
      expr: enrollment_status
      comment: "Status"
    - name: "Enrollment Type"
      display_name: "Enrollment type"
      expr: enrollment_type
      comment: "Type"
    - name: "Eligibility Outcome"
      display_name: "Eligibility outcome"
      expr: eligibility_verification_outcome
      comment: "Outcome"
  measures:
    - name: "Enrollments"
      display_name: "Enrollments"
      expr: COUNT(1)
      comment: "Enrollments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Verified %"
      display_name: "Verified %"
      expr: ROUND(100.0 * SUM(CASE WHEN eligibility_verification_outcome = 'VERIFIED' THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Verified share"
    - name: "Total Enrollment Fees"
      display_name: "Total enrollment fees"
      expr: SUM(CAST(enrollment_fee_amount AS DOUBLE))
      comment: "Fees"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_member_lifecycle_transitions`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Volume of lifecycle events (leave, disability, deferral, retirement) by reason, a demographic trend signal."
  source: "`asset_management`.`beneficiary`.`member_lifecycle_event`"
  dimensions:
    - name: "Reason Code"
      display_name: "Reason code"
      expr: event_reason_code
      comment: "Reason"
    - name: "Approval Status"
      display_name: "Approval status"
      expr: event_approval_status
      comment: "Status"
    - name: "Plan Type"
      display_name: "Plan type"
      expr: event_plan_type
      comment: "Plan"
  measures:
    - name: "Events"
      display_name: "Events"
      expr: COUNT(1)
      comment: "Lifecycle events"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Age At Event"
      display_name: "Avg age at event"
      expr: ROUND(AVG(CAST(event_member_age_at_event AS DOUBLE)),2)
      comment: "Age"
    - name: "Avg Service At Event"
      display_name: "Avg service at event"
      expr: ROUND(AVG(CAST(event_member_service_years AS DOUBLE)),2)
      comment: "Service years"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_member_statement_acknowledgement`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Share of issued member statements acknowledged, a member-engagement KPI."
  source: "`asset_management`.`beneficiary`.`member_statement`"
  dimensions:
    - name: "Delivery Channel"
      display_name: "Delivery channel"
      expr: delivery_channel
      comment: "Channel"
  measures:
    - name: "Statements"
      display_name: "Statements"
      expr: COUNT(1)
      comment: "Statements"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Acknowledged %"
      display_name: "Acknowledged %"
      expr: ROUND(100.0 * SUM(CASE WHEN acknowledgement_date IS NOT NULL THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Acknowledged share"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_member_statement_delivery`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Annual pension statement issuance and accrued pension disclosed to members."
  source: "`asset_management`.`beneficiary`.`member_statement`"
  dimensions:
    - name: "Delivery Channel"
      display_name: "Delivery channel"
      expr: delivery_channel
      comment: "Channel"
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency"
  measures:
    - name: "Statements"
      display_name: "Statements"
      expr: COUNT(1)
      comment: "Statements"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Accrued Pension"
      display_name: "Total accrued pension"
      expr: SUM(CAST(accrued_pension_annual_amount AS DOUBLE))
      comment: "Accrued pension"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Best Average Salary"
      display_name: "Avg best average salary"
      expr: ROUND(AVG(CAST(best_average_salary AS DOUBLE)),2)
      comment: "Best avg salary"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_net_contribution_inflow`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Total member and employer contributions flowing into the fund, the top-line funding line."
  source: "`asset_management`.`beneficiary`.`contribution_record`"
  filter: contribution_approval_status = 'APPROVED'
  dimensions:
    - name: "Contribution Method"
      display_name: "Contribution method"
      expr: contribution_method
      comment: "Method"
    - name: "Contribution Source"
      display_name: "Contribution source"
      expr: contribution_source
      comment: "Source"
    - name: "Currency"
      display_name: "Currency"
      expr: contribution_currency_code
      comment: "Currency"
  measures:
    - name: "Total Fees"
      display_name: "Total fees"
      expr: SUM(CAST(contribution_fee_amount AS DOUBLE))
      comment: "Fees"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Contribution Records"
      display_name: "Contribution records"
      expr: COUNT(1)
      comment: "Records"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_overpayment_recovery`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Overpayment detection and recovery KPIs: gross overpayment, amounts recovered, outstanding balances, write-offs, hardship waivers, dispute rates. Steers financial leakage control and recovery operations."
  source: "`asset_management`.`beneficiary`.`overpayment_recovery`"
  dimensions:
    - name: "Recovery Status"
      display_name: "Recovery Status"
      expr: recovery_status
      comment: "Current status of the recovery case."
    - name: "Overpayment Type"
      display_name: "Overpayment Type"
      expr: overpayment_type
      comment: "Classification of the overpayment (e.g. deceased, calculation error)."
    - name: "Overpayment Cause"
      display_name: "Overpayment Cause"
      expr: overpayment_cause
      comment: "Root cause category of the overpayment."
    - name: "Recovery Method"
      display_name: "Recovery Method"
      expr: recovery_method
      comment: "Mechanism used to recover funds (e.g. installment, lump sum, estate claim)."
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "ISO currency code of the recovery case."
    - name: "Detection Month"
      display_name: "Detection Month"
      expr: DATE_TRUNC('month', detection_date)
      comment: "Overpayment detection date truncated to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Detection Year"
      display_name: "Detection Year"
      expr: DATE_TRUNC('year', detection_date)
      comment: "Overpayment detection date truncated to year."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Recovery Case Count"
      display_name: "Recovery Case Count"
      expr: COUNT(1)
      comment: "Total number of overpayment recovery cases."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Members Affected"
      display_name: "Members Affected"
      expr: COUNT(DISTINCT member_id)
      comment: "Distinct members with an overpayment recovery case."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Gross Overpayment"
      display_name: "Total Gross Overpayment"
      expr: SUM(CAST(gross_overpayment_amount AS DOUBLE))
      comment: "Total gross value of identified overpayments — financial leakage exposure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Recovered"
      display_name: "Total Recovered"
      expr: SUM(CAST(amount_recovered_to_date AS DOUBLE))
      comment: "Total amount recovered to date across cases."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Outstanding Balance"
      display_name: "Total Outstanding Balance"
      expr: SUM(CAST(outstanding_balance AS DOUBLE))
      comment: "Total unrecovered balance still outstanding — recovery backlog."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Write-Off"
      display_name: "Total Write-Off"
      expr: SUM(CAST(write_off_amount AS DOUBLE))
      comment: "Total amount written off as unrecoverable — permanent loss."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Hardship Waiver"
      display_name: "Total Hardship Waiver"
      expr: SUM(CAST(hardship_waiver_amount AS DOUBLE))
      comment: "Total amount waived due to beneficiary hardship."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Recovery Rate"
      display_name: "Recovery Rate"
      expr: ROUND(100.0 * SUM(CAST(amount_recovered_to_date AS DOUBLE)) / NULLIF(SUM(CAST(gross_overpayment_amount AS DOUBLE)), 0), 2)
      comment: "Share of gross overpayment recovered to date — recovery effectiveness."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Write-Off Rate"
      display_name: "Write-Off Rate"
      expr: ROUND(100.0 * SUM(CAST(write_off_amount AS DOUBLE)) / NULLIF(SUM(CAST(gross_overpayment_amount AS DOUBLE)), 0), 2)
      comment: "Share of gross overpayment written off — permanent leakage ratio."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Dispute Rate"
      display_name: "Dispute Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN dispute_raised = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of recovery cases that were disputed by beneficiaries."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_overpayment_recovery_rate`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Recovery performance on benefit overpayments including waivers and disputes."
  source: "`asset_management`.`beneficiary`.`overpayment_recovery`"
  dimensions:
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency"
  measures:
    - name: "Gross Overpayment"
      display_name: "Gross overpayment"
      expr: SUM(CAST(gross_overpayment_amount AS DOUBLE))
      comment: "Overpaid"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Recovered To Date"
      display_name: "Recovered to date"
      expr: SUM(CAST(amount_recovered_to_date AS DOUBLE))
      comment: "Recovered"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Recovery %"
      display_name: "Recovery %"
      expr: ROUND(100.0 * SUM(CAST(amount_recovered_to_date AS DOUBLE)) / NULLIF(SUM(CAST(gross_overpayment_amount AS DOUBLE)),0),2)
      comment: "Recovery rate"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Waiver Granted"
      display_name: "Waiver granted"
      expr: SUM(CAST(hardship_waiver_amount AS DOUBLE))
      comment: "Waivers"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_participating_employer_base`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Count of participating employers, active member coverage, and ESG/AML risk profile."
  source: "`asset_management`.`beneficiary`.`participating_employer`"
  dimensions:
    - name: "Employer Type"
      display_name: "Employer type"
      expr: employer_type
      comment: "Type"
    - name: "Country"
      display_name: "Country"
      expr: country_code
      comment: "Country"
    - name: "AML Risk"
      display_name: "Aml risk"
      expr: aml_risk_rating
      comment: "AML risk"
  measures:
    - name: "Employers"
      display_name: "Employers"
      expr: COUNT(1)
      comment: "Employers"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Active Members"
      display_name: "Total active members"
      expr: SUM(CAST(active_member_count AS DOUBLE))
      comment: "Covered members"
      format:
        type: number
        decimal_places:
          type: all
    - name: "ESG Compliant %"
      display_name: "Esg compliant %"
      expr: ROUND(100.0 * SUM(CASE WHEN esg_policy_compliant = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "ESG compliant"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_pensionable_service_buyback_impact`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Buyback service years disclosed on member statements, reflecting liability augmentation."
  source: "`asset_management`.`beneficiary`.`member_statement`"
  dimensions:
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency"
    - name: "Benefit Formula Type"
      display_name: "Benefit formula type"
      expr: benefit_formula_type
      comment: "Formula"
  measures:
    - name: "Total Buyback Years"
      display_name: "Total buyback years"
      expr: SUM(CAST(buyback_service_years AS DOUBLE))
      comment: "Buyback years"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Accrual Rate"
      display_name: "Avg accrual rate"
      expr: ROUND(AVG(CAST(accrual_rate AS DOUBLE)),4)
      comment: "Accrual rate"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_pensionable_service_credits`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Cumulative pensionable service accrued across the membership, a liability accrual driver."
  source: "`asset_management`.`beneficiary`.`pensionable_service`"
  dimensions:
    - name: "Plan Type"
      display_name: "Plan type"
      expr: service_credits_plan_type
      comment: "Plan type"
    - name: "Lifetime Status"
      display_name: "Lifetime status"
      expr: service_credits_lifetime_status
      comment: "Status"
  measures:
    - name: "Total Service Years"
      display_name: "Total service years"
      expr: SUM(CAST(cumulative_service_years AS DOUBLE))
      comment: "Cumulative years"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Service Years"
      display_name: "Avg service years"
      expr: ROUND(AVG(CAST(cumulative_service_years AS DOUBLE)),2)
      comment: "Average years"
    - name: "Period Months Added"
      display_name: "Period months added"
      expr: SUM(CAST(period_service_months AS DOUBLE))
      comment: "Period months"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_pension_division_orders`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Court-ordered pension divisions on marriage breakdown and amounts split."
  source: "`asset_management`.`beneficiary`.`pension_division_order`"
  dimensions:
    - name: "Division Method"
      display_name: "Division method"
      expr: division_method
      comment: "Method"
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency"
    - name: "Appeal"
      display_name: "Appeal"
      expr: appeal_flag
      comment: "Appeal flag"
  measures:
    - name: "Orders"
      display_name: "Orders"
      expr: COUNT(1)
      comment: "Division orders"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Division Amount"
      display_name: "Total division amount"
      expr: SUM(CAST(division_amount AS DOUBLE))
      comment: "Divided amount"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Division %"
      display_name: "Avg division %"
      expr: ROUND(AVG(CAST(division_percentage AS DOUBLE)),2)
      comment: "Division share"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_retirement_bridge_takeup`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Take-up of bridge benefits at retirement, affecting short-term liability outflows."
  source: "`asset_management`.`beneficiary`.`retirement_election`"
  dimensions:
    - name: "Channel"
      display_name: "Channel"
      expr: election_channel
      comment: "Channel"
  measures:
    - name: "Bridge Take-up %"
      display_name: "Bridge take-up %"
      expr: ROUND(100.0 * SUM(CASE WHEN bridge_benefit_elected = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Bridge elected share"
    - name: "Total Bridge Amount"
      display_name: "Total bridge amount"
      expr: SUM(CAST(bridge_benefit_amount AS DOUBLE))
      comment: "Bridge amount"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_retirement_elections`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Retirement drawdown elections and commutation take-up, a liability-timing driver."
  source: "`asset_management`.`beneficiary`.`retirement_election`"
  dimensions:
    - name: "Election Channel"
      display_name: "Election channel"
      expr: election_channel
      comment: "Channel"
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency"
  measures:
    - name: "Elections"
      display_name: "Elections"
      expr: COUNT(1)
      comment: "Elections"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Commutation Take-up %"
      display_name: "Commutation take-up %"
      expr: ROUND(100.0 * SUM(CASE WHEN commutation_elected = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "Commutation share"
    - name: "Avg Early Retirement Reduction"
      display_name: "Avg early retirement reduction"
      expr: ROUND(AVG(CAST(early_retirement_reduction_rate AS DOUBLE)),2)
      comment: "Early reduction"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Commutation Amount"
      display_name: "Total commutation amount"
      expr: SUM(CAST(commutation_amount AS DOUBLE))
      comment: "Commutation amount"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_service_buyback`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Service buyback KPIs: actuarial cost of purchased service, member vs employer funding, outstanding balances, service credits added. Steers liability growth from buybacks."
  source: "`asset_management`.`beneficiary`.`service_buyback`"
  dimensions:
    - name: "Buyback Status"
      display_name: "Buyback Status"
      expr: buyback_status
      comment: "Processing status of the service buyback."
    - name: "Prior Service Type"
      display_name: "Prior Service Type"
      expr: prior_service_type
      comment: "Type of prior service being bought back."
    - name: "Payment Method"
      display_name: "Payment Method"
      expr: payment_method
      comment: "Method of payment for the buyback."
    - name: "Installment Frequency"
      display_name: "Installment Frequency"
      expr: installment_frequency
      comment: "Frequency of buyback installment payments."
    - name: "Election Year"
      display_name: "Election Year"
      expr: DATE_TRUNC('year', election_date)
      comment: "Buyback election date truncated to year."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Buyback Count"
      display_name: "Buyback Count"
      expr: COUNT(1)
      comment: "Total number of service buyback records."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Members with Buyback"
      display_name: "Members with Buyback"
      expr: COUNT(DISTINCT member_id)
      comment: "Distinct members electing a service buyback."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Actuarial Cost"
      display_name: "Total Actuarial Cost"
      expr: SUM(CAST(actuarial_cost_amount AS DOUBLE))
      comment: "Total actuarial cost of bought-back service — liability driver."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Member Contribution"
      display_name: "Total Member Contribution"
      expr: SUM(CAST(member_contribution_amount AS DOUBLE))
      comment: "Total member-funded buyback contribution."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Outstanding Balance"
      display_name: "Total Outstanding Balance"
      expr: SUM(CAST(outstanding_balance_amount AS DOUBLE))
      comment: "Total outstanding buyback balance still owed."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Service Credits Purchased"
      display_name: "Total Service Credits Purchased"
      expr: SUM(CAST(service_credits_purchased_years AS DOUBLE))
      comment: "Total years of service credit purchased — benefit accrual impact."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Member Funding Share"
      display_name: "Member Funding Share"
      expr: ROUND(100.0 * SUM(CAST(member_contribution_amount AS DOUBLE)) / NULLIF(SUM(CAST(actuarial_cost_amount AS DOUBLE)), 0), 2)
      comment: "Member contribution as a percentage of total actuarial cost."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_service_buyback_volume`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Member elections to purchase prior pensionable service and the actuarial cost involved."
  source: "`asset_management`.`beneficiary`.`service_buyback`"
  dimensions:
    - name: "Buyback Status"
      display_name: "Buyback status"
      expr: buyback_status
      comment: "Status"
    - name: "Currency"
      display_name: "Currency"
      expr: actuarial_cost_currency
      comment: "Currency"
  measures:
    - name: "Buybacks"
      display_name: "Buybacks"
      expr: COUNT(1)
      comment: "Buyback elections"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Actuarial Cost"
      display_name: "Total actuarial cost"
      expr: SUM(CAST(actuarial_cost_amount AS DOUBLE))
      comment: "Cost"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Employer Contribution"
      display_name: "Employer contribution"
      expr: SUM(CAST(employer_contribution_amount AS DOUBLE))
      comment: "Employer portion"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_survivor_benefit`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Survivor benefit KPIs: annual benefit exposure, actuarial present value of survivor liabilities, lump sums, KYC verification. Steers survivor liability funding and compliance."
  source: "`asset_management`.`beneficiary`.`survivor_benefit`"
  dimensions:
    - name: "Benefit Status"
      display_name: "Benefit Status"
      expr: benefit_status
      comment: "Current status of the survivor benefit."
    - name: "Benefit Type"
      display_name: "Benefit Type"
      expr: benefit_type
      comment: "Type classification of the survivor benefit."
    - name: "Survivor Relationship"
      display_name: "Survivor Relationship"
      expr: survivor_relationship_type
      comment: "Relationship of the survivor to the deceased member."
    - name: "Payment Frequency"
      display_name: "Payment Frequency"
      expr: payment_frequency
      comment: "Frequency of survivor benefit payments."
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "ISO currency code of the survivor benefit."
    - name: "Commencement Year"
      display_name: "Commencement Year"
      expr: DATE_TRUNC('year', benefit_commencement_date)
      comment: "Benefit commencement date truncated to year."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Survivor Benefit Count"
      display_name: "Survivor Benefit Count"
      expr: COUNT(1)
      comment: "Total number of survivor benefit records."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Gross Annual Benefit"
      display_name: "Total Gross Annual Benefit"
      expr: SUM(CAST(gross_annual_benefit_amount AS DOUBLE))
      comment: "Total gross annual survivor benefit obligation."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Actuarial Present Value"
      display_name: "Total Actuarial Present Value"
      expr: SUM(CAST(actuarial_present_value AS DOUBLE))
      comment: "Total actuarial present value of survivor liabilities — funding exposure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Lump Sum"
      display_name: "Total Lump Sum"
      expr: SUM(CAST(lump_sum_amount AS DOUBLE))
      comment: "Total lump-sum survivor payouts."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Paid To Date"
      display_name: "Total Paid To Date"
      expr: SUM(CAST(total_paid_to_date AS DOUBLE))
      comment: "Cumulative survivor benefit paid to date."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Gross Annual Benefit"
      display_name: "Avg Gross Annual Benefit"
      expr: AVG(CAST(gross_annual_benefit_amount AS DOUBLE))
      comment: "Average gross annual survivor benefit per record."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "KYC Verified Rate"
      display_name: "KYC Verified Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN kyc_verified = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of survivor beneficiaries with completed KYC — AML compliance."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_survivor_benefit_pv`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Actuarial present value of survivor pensions established on member death."
  source: "`asset_management`.`beneficiary`.`survivor_benefit`"
  dimensions:
    - name: "Benefit Type"
      display_name: "Benefit type"
      expr: benefit_type
      comment: "Type"
    - name: "Benefit Status"
      display_name: "Benefit status"
      expr: benefit_status
      comment: "Status"
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency"
  measures:
    - name: "Total APV"
      display_name: "Total apv"
      expr: SUM(CAST(actuarial_present_value AS DOUBLE))
      comment: "Present value"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Gross Annual Benefit"
      display_name: "Gross annual benefit"
      expr: SUM(CAST(gross_annual_benefit_amount AS DOUBLE))
      comment: "Annual benefit"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Discount Rate"
      display_name: "Avg discount rate"
      expr: ROUND(AVG(CAST(discount_rate AS DOUBLE)),2)
      comment: "Discount rate"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_transfer_in_kyc_quality`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "KYC verification completeness on inbound transfers for AML control."
  source: "`asset_management`.`beneficiary`.`transfer_in`"
  dimensions:
    - name: "Locked In"
      display_name: "Locked in"
      expr: locked_in_flag
      comment: "Locked-in"
  measures:
    - name: "Transfers"
      display_name: "Transfers"
      expr: COUNT(1)
      comment: "Transfers"
      format:
        type: number
        decimal_places:
          type: all
    - name: "KYC Verified %"
      display_name: "Kyc verified %"
      expr: ROUND(100.0 * SUM(CASE WHEN kyc_verified = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "KYC verified share"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_transfer_in_value`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Pension assets transferred into the fund including commuted value and earnings."
  source: "`asset_management`.`beneficiary`.`transfer_in`"
  dimensions:
    - name: "Locked In"
      display_name: "Locked in"
      expr: locked_in_flag
      comment: "Locked-in flag"
  measures:
    - name: "Commuted Value In"
      display_name: "Commuted value in"
      expr: SUM(CAST(commuted_value AS DOUBLE))
      comment: "Commuted value"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Member Contributions"
      display_name: "Member contributions"
      expr: SUM(CAST(member_contribution_amount AS DOUBLE))
      comment: "Member portion"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Investment Earnings"
      display_name: "Investment earnings"
      expr: SUM(CAST(investment_earnings_amount AS DOUBLE))
      comment: "Earnings"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "AML Screened %"
      display_name: "Aml screened %"
      expr: ROUND(100.0 * SUM(CASE WHEN aml_screened = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "AML screened"
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_transfer_out`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Outbound pension transfer KPIs: commuted value leaving the fund, cross-border transfers, withholding tax, AML clearance. Steers asset outflow and portability risk."
  source: "`asset_management`.`beneficiary`.`transfer_out`"
  dimensions:
    - name: "Transfer Status"
      display_name: "Transfer Status"
      expr: transfer_status
      comment: "Processing status of the outbound transfer."
    - name: "Transfer Type"
      display_name: "Transfer Type"
      expr: transfer_type
      comment: "Type classification of the outbound transfer."
    - name: "Transfer Reason"
      display_name: "Transfer Reason"
      expr: transfer_reason
      comment: "Reason the transfer-out was initiated."
    - name: "Receiving Country"
      display_name: "Receiving Country"
      expr: receiving_country_code
      comment: "Destination country of the transferred funds."
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "ISO currency code of the transfer."
    - name: "Transfer Month"
      display_name: "Transfer Month"
      expr: DATE_TRUNC('month', transfer_date)
      comment: "Transfer date truncated to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Transfer Year"
      display_name: "Transfer Year"
      expr: DATE_TRUNC('year', transfer_date)
      comment: "Transfer date truncated to year."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Transfer Out Count"
      display_name: "Transfer Out Count"
      expr: COUNT(1)
      comment: "Total number of outbound transfer records."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Members Transferring Out"
      display_name: "Members Transferring Out"
      expr: COUNT(DISTINCT member_id)
      comment: "Distinct members transferring value out of the fund — attrition signal."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Commuted Value Out"
      display_name: "Total Commuted Value Out"
      expr: SUM(CAST(commuted_value_amount AS DOUBLE))
      comment: "Total commuted value leaving the fund — asset outflow exposure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Registered Transfer Amount"
      display_name: "Total Registered Transfer Amount"
      expr: SUM(CAST(registered_transfer_amount AS DOUBLE))
      comment: "Total registered (tax-sheltered) portion transferred out."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Withholding Tax"
      display_name: "Total Withholding Tax"
      expr: SUM(CAST(withholding_tax_amount AS DOUBLE))
      comment: "Total withholding tax deducted on transfers out."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Commuted Value Out"
      display_name: "Avg Commuted Value Out"
      expr: AVG(CAST(commuted_value_amount AS DOUBLE))
      comment: "Average commuted value per outbound transfer."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Cross-Border Transfer Rate"
      display_name: "Cross-Border Transfer Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN is_cross_border = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of transfers that are cross-border — regulatory complexity exposure."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "AML Cleared Rate"
      display_name: "AML Cleared Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN aml_cleared = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of outbound transfers cleared through AML screening."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`beneficiary_transfer_out_value`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Commuted value leaving the fund when members terminate and transfer credits out."
  source: "`asset_management`.`beneficiary`.`transfer_out`"
  dimensions:
    - name: "Currency"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency"
    - name: "Cross Border"
      display_name: "Cross border"
      expr: is_cross_border
      comment: "Cross-border flag"
  measures:
    - name: "Commuted Value Out"
      display_name: "Commuted value out"
      expr: SUM(CAST(commuted_value_amount AS DOUBLE))
      comment: "Commuted value"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Service Years"
      display_name: "Avg service years"
      expr: ROUND(AVG(CAST(accrued_service_years AS DOUBLE)),2)
      comment: "Service years"
    - name: "AML Cleared %"
      display_name: "Aml cleared %"
      expr: ROUND(100.0 * SUM(CASE WHEN aml_cleared = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(1),0),2)
      comment: "AML cleared"
$$;
