-- Metric views for domain: deal | Business: Asset Management | Version: 1 | Generated on: 2026-11-10 14:18:58

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`deal_capital_commitment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Committed-capital KPIs — commitment volume, dry powder, target economics and vintage pacing. Central to capital deployment steering."
  source: "`asset_management`.`deal`.`deal_capital_commitment`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the capital commitment."
    - name: "Sub Asset Class"
      display_name: "Sub asset class"
      expr: sub_asset_class
      comment: "Sub-asset-class of the commitment."
    - name: "Commitment Status"
      display_name: "Commitment status"
      expr: commitment_status
      comment: "Lifecycle status of the commitment."
    - name: "Commitment Type"
      display_name: "Commitment type"
      expr: commitment_type
      comment: "Type of commitment (primary, co-invest, secondary)."
    - name: "Commitment Currency"
      display_name: "Commitment currency"
      expr: commitment_currency
      comment: "Currency of the committed amount."
    - name: "Investment Strategy"
      display_name: "Investment strategy"
      expr: investment_strategy
      comment: "Investment strategy backing the commitment."
    - name: "Risk Rating"
      display_name: "Risk rating"
      expr: risk_rating
      comment: "Risk rating of the commitment."
    - name: "ESG Rating"
      display_name: "Esg rating"
      expr: esg_rating
      comment: "ESG rating assigned to the commitment."
    - name: "Target Jurisdiction"
      display_name: "Target jurisdiction"
      expr: target_jurisdiction
      comment: "Jurisdiction of the target entity."
    - name: "Vintage Year"
      display_name: "Vintage year"
      expr: vintage_year
      comment: "Vintage year of the commitment for pacing analysis."
    - name: "IC Decision Outcome"
      display_name: "Ic decision outcome"
      expr: ic_decision_outcome
      comment: "Investment Committee decision outcome for the commitment."
    - name: "IC Approval Month"
      display_name: "Ic approval month"
      expr: DATE_TRUNC('month', ic_approval_date)
      comment: "IC approval date bucketed to month for commitment pacing."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "IC Approval Year"
      display_name: "Ic approval year"
      expr: DATE_TRUNC('year', ic_approval_date)
      comment: "IC approval date bucketed to year."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Commitment Count"
      display_name: "Commitment count"
      expr: COUNT(1)
      comment: "Number of capital commitments — deployment activity baseline."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Commitment Amount Base Currency"
      display_name: "Total commitment amount base currency"
      expr: SUM(CAST(commitment_amount_base_currency AS DOUBLE))
      comment: "Aggregate committed capital in base currency — total deployed commitment."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Commitment Amount Base Currency"
      display_name: "Avg commitment amount base currency"
      expr: AVG(CAST(commitment_amount_base_currency AS DOUBLE))
      comment: "Average commitment size in base currency."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Dry Powder Allocation"
      display_name: "Total dry powder allocation"
      expr: SUM(CAST(dry_powder_allocation AS DOUBLE))
      comment: "Aggregate undeployed capital earmarked — liquidity/pacing signal."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Target IRR Percent"
      display_name: "Avg target irr percent"
      expr: AVG(CAST(target_irr_percent AS DOUBLE))
      comment: "Average targeted IRR across commitments."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Target MOIC"
      display_name: "Avg target moic"
      expr: AVG(CAST(target_moic AS DOUBLE))
      comment: "Average targeted MOIC across commitments."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Management Fee Percent"
      display_name: "Avg management fee percent"
      expr: AVG(CAST(management_fee_percent AS DOUBLE))
      comment: "Average management fee rate — cost-of-capital lever."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Carried Interest Percent"
      display_name: "Avg carried interest percent"
      expr: AVG(CAST(carried_interest_percent AS DOUBLE))
      comment: "Average carried interest rate — GP economics benchmark."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Strategic Fit Score"
      display_name: "Avg strategic fit score"
      expr: AVG(CAST(strategic_fit_score AS DOUBLE))
      comment: "Average strategic fit score of commitments."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "ESG Excluded Commitment Count"
      display_name: "Esg excluded commitment count"
      expr: COUNT(CASE WHEN esg_exclusion_flag = TRUE THEN 1 END)
      comment: "Commitments flagged for ESG exclusion."
      format:
        type: number
        decimal_places:
          type: all
    - name: "LPA Signed Count"
      display_name: "Lpa signed count"
      expr: COUNT(CASE WHEN lpa_signed_flag = TRUE THEN 1 END)
      comment: "Commitments with executed Limited Partnership Agreements — documentation completeness."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Commitment Amount YTD"
      display_name: "Commitment amount ytd"
      expr: SUM(CAST(commitment_amount_base_currency AS DOUBLE))
      comment: "Year-to-date committed capital in base currency for pacing against annual deployment target."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: IC Approval Month
          range: cumulative
          semiadditive: last
        - order: IC Approval Year
          range: current
          semiadditive: last
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`deal_co_invest_allocation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Co-investment allocation KPIs — allocation volume, acceptance, ownership and economics with partner co-investors. Steers co-invest program performance."
  source: "`asset_management`.`deal`.`co_invest_allocation`"
  dimensions:
    - name: "Allocation Status"
      display_name: "Allocation status"
      expr: allocation_status
      comment: "Status of the co-invest allocation (offered, accepted, declined, funded)."
    - name: "Allocation Type"
      display_name: "Allocation type"
      expr: allocation_type
      comment: "Type of co-investment allocation."
    - name: "Allocation Currency"
      display_name: "Allocation currency"
      expr: allocation_currency
      comment: "Currency of the allocated amount."
    - name: "Co-Investor Type"
      display_name: "Co-investor type"
      expr: co_investor_type
      comment: "Type of co-investor entity."
    - name: "Co-Investor Jurisdiction"
      display_name: "Co-investor jurisdiction"
      expr: co_investor_jurisdiction
      comment: "Jurisdiction of the co-investor."
    - name: "KYC AML Status"
      display_name: "Kyc aml status"
      expr: kyc_aml_status
      comment: "KYC/AML status of the co-investor."
    - name: "Offer Month"
      display_name: "Offer month"
      expr: DATE_TRUNC('month', allocation_offer_date)
      comment: "Allocation offer date bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Funding Month"
      display_name: "Funding month"
      expr: DATE_TRUNC('month', allocation_funding_date)
      comment: "Allocation funding date bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Allocation Count"
      display_name: "Allocation count"
      expr: COUNT(1)
      comment: "Number of co-invest allocations — program activity baseline."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Allocated Amount"
      display_name: "Total allocated amount"
      expr: SUM(CAST(allocated_amount AS DOUBLE))
      comment: "Aggregate allocated co-investment capital."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Allocated Amount"
      display_name: "Avg allocated amount"
      expr: AVG(CAST(allocated_amount AS DOUBLE))
      comment: "Average co-invest allocation size."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Accepted Allocation Count"
      display_name: "Accepted allocation count"
      expr: COUNT(CASE WHEN allocation_acceptance_date IS NOT NULL THEN 1 END)
      comment: "Allocations accepted by co-investors — acceptance numerator."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Funded Allocation Count"
      display_name: "Funded allocation count"
      expr: COUNT(CASE WHEN allocation_funding_date IS NOT NULL THEN 1 END)
      comment: "Allocations that reached funding."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Declined Allocation Count"
      display_name: "Declined allocation count"
      expr: COUNT(CASE WHEN decline_reason IS NOT NULL THEN 1 END)
      comment: "Allocations declined by co-investors."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Ownership Percentage"
      display_name: "Avg ownership percentage"
      expr: AVG(CAST(ownership_percentage AS DOUBLE))
      comment: "Average ownership percentage granted to co-investors."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Management Fee Percent"
      display_name: "Avg management fee percent"
      expr: AVG(CAST(management_fee_percent AS DOUBLE))
      comment: "Average management fee charged on allocations."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Carried Interest Percent"
      display_name: "Avg carried interest percent"
      expr: AVG(CAST(carried_interest_percent AS DOUBLE))
      comment: "Average carried interest on allocations."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "KYC Completed Count"
      display_name: "Kyc completed count"
      expr: COUNT(CASE WHEN kyc_completion_date IS NOT NULL THEN 1 END)
      comment: "Allocations with completed KYC — compliance readiness."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`deal_fee`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Deal transaction cost KPIs — fees by category, reimbursables and capitalizable costs in USD. Steers deal cost efficiency and budgeting."
  source: "`asset_management`.`deal`.`deal_fee`"
  dimensions:
    - name: "Fee Category"
      display_name: "Fee category"
      expr: fee_category
      comment: "Category of the deal fee (advisory, legal, due diligence)."
    - name: "Fee Type"
      display_name: "Fee type"
      expr: fee_type
      comment: "Type of fee within the category."
    - name: "Fee Status"
      display_name: "Fee status"
      expr: fee_status
      comment: "Status of the fee (accrued, invoiced, paid)."
    - name: "Asset Class"
      display_name: "Asset class"
      expr: asset_class
      comment: "Asset class the fee is associated with."
    - name: "Deal Stage"
      display_name: "Deal stage"
      expr: deal_stage
      comment: "Deal stage at which the fee was incurred."
    - name: "Currency Code"
      display_name: "Currency code"
      expr: currency_code
      comment: "Original currency of the fee."
    - name: "Service Provider Type"
      display_name: "Service provider type"
      expr: service_provider_type
      comment: "Type of external service provider."
    - name: "Invoice Month"
      display_name: "Invoice month"
      expr: DATE_TRUNC('month', invoice_date)
      comment: "Invoice date bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Payment Month"
      display_name: "Payment month"
      expr: DATE_TRUNC('month', payment_date)
      comment: "Payment date bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Fee Line Count"
      display_name: "Fee line count"
      expr: COUNT(1)
      comment: "Number of fee line items — cost activity baseline."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Fee Amount USD"
      display_name: "Total fee amount usd"
      expr: SUM(CAST(amount_usd AS DOUBLE))
      comment: "Aggregate deal fees in USD — total transaction cost."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Fee Amount USD"
      display_name: "Avg fee amount usd"
      expr: AVG(CAST(amount_usd AS DOUBLE))
      comment: "Average fee per line item in USD."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Reimbursement Amount"
      display_name: "Total reimbursement amount"
      expr: SUM(CAST(reimbursement_amount AS DOUBLE))
      comment: "Aggregate reimbursable fee amounts — recoverable cost."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Capitalizable Fee Count"
      display_name: "Capitalizable fee count"
      expr: COUNT(CASE WHEN is_capitalizable = TRUE THEN 1 END)
      comment: "Fee lines that are capitalizable — accounting treatment split."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Reimbursable Fee Count"
      display_name: "Reimbursable fee count"
      expr: COUNT(CASE WHEN is_reimbursable = TRUE THEN 1 END)
      comment: "Fee lines marked reimbursable."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Fee Spend MTD"
      display_name: "Fee spend mtd"
      expr: SUM(CAST(amount_usd AS DOUBLE))
      comment: "Month-to-date fee spend in USD for current-period cost tracking."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Invoice Month
          range: current
          semiadditive: last
    - name: "Fee Spend Prior Month"
      display_name: "Fee spend prior month"
      expr: SUM(CAST(amount_usd AS DOUBLE))
      comment: "Prior-month fee spend in USD for MoM comparison."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
      window:
        - order: Invoice Month
          range: current
          semiadditive: last
          offset: -1 month
    - name: "Fee Spend MoM"
      display_name: "Fee spend mom"
      expr: (AGG(`Fee Spend MTD`) - AGG(`Fee Spend Prior Month`)) / NULLIF(AGG(`Fee Spend Prior Month`), 0)
      comment: "Month-over-month change in deal fee spend."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`deal_ic_submission`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Investment Committee governance KPIs — approval rates, requested vs approved capital, voting dynamics and expected economics. Steers capital-allocation governance."
  source: "`asset_management`.`deal`.`deal_ic_submission`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset class"
      expr: asset_class
      comment: "Asset class of the IC submission."
    - name: "IC Decision"
      display_name: "Ic decision"
      expr: ic_decision
      comment: "Investment Committee decision (approved, rejected, deferred)."
    - name: "IC Type"
      display_name: "Ic type"
      expr: ic_type
      comment: "Type of IC meeting/submission."
    - name: "Submission Status"
      display_name: "Submission status"
      expr: submission_status
      comment: "Status of the IC submission."
    - name: "DD Completion Status"
      display_name: "Dd completion status"
      expr: dd_completion_status
      comment: "Due diligence completion status at submission."
    - name: "Risk Rating"
      display_name: "Risk rating"
      expr: risk_rating
      comment: "Risk rating of the submission."
    - name: "ESG Rating"
      display_name: "Esg rating"
      expr: esg_rating
      comment: "ESG rating assigned to the submission."
    - name: "Target Geography"
      display_name: "Target geography"
      expr: target_geography
      comment: "Target geography of the proposed investment."
    - name: "Target Sector"
      display_name: "Target sector"
      expr: target_sector
      comment: "Target sector of the proposed investment."
    - name: "Sponsoring Department"
      display_name: "Sponsoring department"
      expr: sponsoring_department
      comment: "Internal department sponsoring the submission."
    - name: "Decision Month"
      display_name: "Decision month"
      expr: DATE_TRUNC('month', decision_date)
      comment: "IC decision date bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Decision Year"
      display_name: "Decision year"
      expr: DATE_TRUNC('year', decision_date)
      comment: "IC decision date bucketed to year."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Submission Count"
      display_name: "Submission count"
      expr: COUNT(1)
      comment: "Number of IC submissions — governance throughput."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Approved Submission Count"
      display_name: "Approved submission count"
      expr: COUNT(CASE WHEN ic_decision = 'Approved' THEN 1 END)
      comment: "Submissions approved by the IC — approval numerator."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Rejected Submission Count"
      display_name: "Rejected submission count"
      expr: COUNT(CASE WHEN ic_decision = 'Rejected' THEN 1 END)
      comment: "Submissions rejected by the IC."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Deferred Submission Count"
      display_name: "Deferred submission count"
      expr: COUNT(CASE WHEN ic_decision = 'Deferred' THEN 1 END)
      comment: "Submissions deferred — governance friction signal."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Requested Commitment Amount"
      display_name: "Total requested commitment amount"
      expr: SUM(CAST(requested_commitment_amount AS DOUBLE))
      comment: "Aggregate capital requested from the IC."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Approved Commitment Amount"
      display_name: "Total approved commitment amount"
      expr: SUM(CAST(approved_commitment_amount AS DOUBLE))
      comment: "Aggregate capital approved by the IC."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Expected IRR Percent"
      display_name: "Avg expected irr percent"
      expr: AVG(CAST(expected_irr_percent AS DOUBLE))
      comment: "Average expected IRR across submissions."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Expected MOIC"
      display_name: "Avg expected moic"
      expr: AVG(CAST(expected_moic AS DOUBLE))
      comment: "Average expected MOIC across submissions."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Strategic Alignment Score"
      display_name: "Avg strategic alignment score"
      expr: AVG(CAST(strategic_alignment_score AS DOUBLE))
      comment: "Average strategic alignment score of submissions."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Votes In Favor"
      display_name: "Total votes in favor"
      expr: SUM(CAST(votes_in_favor AS DOUBLE))
      comment: "Aggregate votes in favor — committee conviction signal."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Votes Against"
      display_name: "Total votes against"
      expr: SUM(CAST(votes_against AS DOUBLE))
      comment: "Aggregate votes against across submissions."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Quorum Met Count"
      display_name: "Quorum met count"
      expr: COUNT(CASE WHEN voting_quorum_met = TRUE THEN 1 END)
      comment: "Submissions where voting quorum was met — governance validity."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`deal_milestone`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Deal execution milestone KPIs — schedule variance, gate outcomes and critical-path tracking. Steers deal delivery and timeline risk."
  source: "`asset_management`.`deal`.`milestone`"
  dimensions:
    - name: "Milestone Type"
      display_name: "Milestone type"
      expr: milestone_type
      comment: "Type of milestone."
    - name: "Milestone Status"
      display_name: "Milestone status"
      expr: milestone_status
      comment: "Current status of the milestone."
    - name: "Gate Decision"
      display_name: "Gate decision"
      expr: gate_decision
      comment: "Decision recorded at a gate milestone."
    - name: "Asset Class"
      display_name: "Asset class"
      expr: asset_class
      comment: "Asset class associated with the milestone."
    - name: "Deal Type"
      display_name: "Deal type"
      expr: deal_type
      comment: "Type of deal the milestone belongs to."
    - name: "Risk Rating"
      display_name: "Risk rating"
      expr: risk_rating
      comment: "Risk rating associated with the milestone."
    - name: "Scheduled Month"
      display_name: "Scheduled month"
      expr: DATE_TRUNC('month', scheduled_date)
      comment: "Scheduled milestone date bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Milestone Count"
      display_name: "Milestone count"
      expr: COUNT(1)
      comment: "Number of milestones tracked — execution activity baseline."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Variance Days"
      display_name: "Avg variance days"
      expr: AVG(CAST(variance_days AS DOUBLE))
      comment: "Average schedule variance in days — timeline slippage indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Critical Path Milestone Count"
      display_name: "Critical path milestone count"
      expr: COUNT(CASE WHEN is_critical_path = TRUE THEN 1 END)
      comment: "Milestones on the critical path — delivery-risk focus."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Gate Milestone Count"
      display_name: "Gate milestone count"
      expr: COUNT(CASE WHEN is_gate_milestone = TRUE THEN 1 END)
      comment: "Gate milestones — governance checkpoints."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Conditions Met Count"
      display_name: "Conditions met count"
      expr: COUNT(CASE WHEN conditions_met = TRUE THEN 1 END)
      comment: "Milestones whose imposed conditions were met."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Completed Milestone Count"
      display_name: "Completed milestone count"
      expr: COUNT(CASE WHEN actual_date IS NOT NULL THEN 1 END)
      comment: "Milestones completed — progress indicator."
      format:
        type: number
        decimal_places:
          type: all
    - name: "ESG Review Required Count"
      display_name: "Esg review required count"
      expr: COUNT(CASE WHEN esg_review_required = TRUE THEN 1 END)
      comment: "Milestones requiring ESG review — responsible-investment gating."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`deal_opportunity`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Deal pipeline KPIs over sourced investment opportunities — origination throughput, conversion, target economics and strategic fit. Core deal-funnel steering layer."
  source: "`asset_management`.`deal`.`opportunity`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Primary asset class of the opportunity (public equity, private equity, real estate, infrastructure, credit, natural resources)."
    - name: "Sub Asset Class"
      display_name: "Sub asset class"
      expr: sub_asset_class
      comment: "Finer sub-asset-class classification within the asset class."
    - name: "Opportunity Status"
      display_name: "Opportunity Status"
      expr: opportunity_status
      comment: "Current pipeline status of the opportunity."
    - name: "Opportunity Type"
      display_name: "Opportunity type"
      expr: opportunity_type
      comment: "Type of opportunity (direct, co-investment, fund commitment, secondary)."
    - name: "IC Decision"
      display_name: "Ic decision"
      expr: ic_decision
      comment: "Investment Committee decision outcome on the opportunity."
    - name: "Priority Tier"
      display_name: "Priority tier"
      expr: priority_tier
      comment: "Internal prioritization tier assigned to the opportunity."
    - name: "Risk Rating"
      display_name: "Risk rating"
      expr: risk_rating
      comment: "Risk rating assigned during origination/screening."
    - name: "Sourcing Channel"
      display_name: "Sourcing channel"
      expr: sourcing_channel
      comment: "Channel through which the opportunity was sourced."
    - name: "Investment Currency"
      display_name: "Investment currency"
      expr: investment_currency
      comment: "Currency in which the expected investment is denominated."
    - name: "Vintage Year"
      display_name: "Vintage year"
      expr: vintage_year
      comment: "Vintage year associated with the opportunity."
    - name: "ESG Exclusion Flag"
      display_name: "Esg exclusion flag"
      expr: esg_exclusion_flag
      comment: "Whether the opportunity is flagged for ESG exclusion."
    - name: "Origination Month"
      display_name: "Origination month"
      expr: DATE_TRUNC('month', origination_date)
      comment: "Origination date bucketed to month for pipeline intake trending."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Origination Year"
      display_name: "Origination year"
      expr: DATE_TRUNC('year', origination_date)
      comment: "Origination date bucketed to year."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Expected Close Month"
      display_name: "Expected close month"
      expr: DATE_TRUNC('month', expected_close_date)
      comment: "Expected close date bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Opportunity Count"
      display_name: "Opportunity count"
      expr: COUNT(1)
      comment: "Count of sourced opportunities — pipeline volume baseline."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Target Entities"
      display_name: "Distinct target entities"
      expr: COUNT(DISTINCT target_entity_id)
      comment: "Distinct target companies in the pipeline — origination breadth."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Active Opportunity Count"
      display_name: "Active opportunity count"
      expr: COUNT(CASE WHEN is_active = TRUE THEN 1 END)
      comment: "Count of currently active (live) opportunities in the pipeline."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Closed Opportunity Count"
      display_name: "Closed opportunity count"
      expr: COUNT(CASE WHEN actual_close_date IS NOT NULL THEN 1 END)
      comment: "Opportunities that reached a close — conversion numerator."
      format:
        type: number
        decimal_places:
          type: all
    - name: "IC Approved Count"
      display_name: "Ic approved count"
      expr: COUNT(CASE WHEN ic_decision = 'Approved' THEN 1 END)
      comment: "Opportunities approved by the Investment Committee."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Declined Count"
      display_name: "Declined count"
      expr: COUNT(CASE WHEN decline_reason IS NOT NULL THEN 1 END)
      comment: "Opportunities declined — attrition signal."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Expected Investment Amount"
      display_name: "Total expected investment amount"
      expr: SUM(CAST(expected_investment_amount AS DOUBLE))
      comment: "Aggregate expected capital deployment across the pipeline."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Expected Investment Amount"
      display_name: "Avg expected investment amount"
      expr: AVG(CAST(expected_investment_amount AS DOUBLE))
      comment: "Average expected ticket size per opportunity."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Target IRR Percent"
      display_name: "Avg target irr percent"
      expr: AVG(CAST(target_irr_percent AS DOUBLE))
      comment: "Average targeted internal rate of return across opportunities."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Target MOIC"
      display_name: "Avg target moic"
      expr: AVG(CAST(target_moic AS DOUBLE))
      comment: "Average targeted multiple on invested capital."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Strategic Fit Score"
      display_name: "Avg strategic fit score"
      expr: AVG(CAST(strategic_fit_score AS DOUBLE))
      comment: "Average strategic fit score — portfolio alignment quality."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Expected Hold Period Years"
      display_name: "Avg expected hold period years"
      expr: AVG(CAST(expected_hold_period_years AS DOUBLE))
      comment: "Average expected holding period in years — duration profile."
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "ESG Excluded Count"
      display_name: "Esg excluded count"
      expr: COUNT(CASE WHEN esg_exclusion_flag = TRUE THEN 1 END)
      comment: "Opportunities excluded on ESG grounds — responsible-investment screening volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Opportunities MTD"
      display_name: "Opportunities mtd"
      expr: COUNT(1)
      comment: "Month-to-date count of sourced opportunities for intake trending."
      format:
        type: number
        decimal_places:
          type: all
      window:
        - order: Origination Month
          range: current
          semiadditive: last
    - name: "Opportunities Prior Month"
      display_name: "Opportunities prior month"
      expr: COUNT(1)
      comment: "Prior month opportunity count for MoM comparison."
      format:
        type: number
        decimal_places:
          type: all
      window:
        - order: Origination Month
          range: current
          semiadditive: last
          offset: -1 month
    - name: "Opportunity Intake MoM"
      display_name: "Opportunity intake mom"
      expr: (AGG(`Opportunities MTD`) - AGG(`Opportunities Prior Month`)) / NULLIF(AGG(`Opportunities Prior Month`), 0)
      comment: "Month-over-month growth in opportunity intake."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`deal_ppm_review`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "External fund (PPM) due-diligence KPIs — GP AUM, fund economics, strategic fit and red-flag detection. Steers external manager selection."
  source: "`asset_management`.`deal`.`ppm_review`"
  dimensions:
    - name: "Fund Asset Class"
      display_name: "Fund asset class"
      expr: fund_asset_class
      comment: "Asset class of the fund under review."
    - name: "Fund Strategy"
      display_name: "Fund strategy"
      expr: fund_strategy
      comment: "Investment strategy of the fund."
    - name: "Review Status"
      display_name: "Review status"
      expr: review_status
      comment: "Status of the PPM review."
    - name: "Recommendation"
      display_name: "Recommendation"
      expr: recommendation
      comment: "Review recommendation (proceed, pass, hold)."
    - name: "Risk Rating"
      display_name: "Risk rating"
      expr: risk_rating
      comment: "Risk rating assigned in the review."
    - name: "ESG Rating"
      display_name: "Esg rating"
      expr: esg_rating
      comment: "ESG rating assigned to the fund."
    - name: "Fund Vintage Year"
      display_name: "Fund vintage year"
      expr: fund_vintage_year
      comment: "Vintage year of the fund."
    - name: "Review Month"
      display_name: "Review month"
      expr: DATE_TRUNC('month', review_date)
      comment: "Review date bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Review Count"
      display_name: "Review count"
      expr: COUNT(1)
      comment: "Number of PPM reviews — external DD throughput."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total GP AUM Amount"
      display_name: "Total gp aum amount"
      expr: SUM(CAST(gp_aum_amount AS DOUBLE))
      comment: "Aggregate GP assets under management reviewed."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Target Fund Size Amount"
      display_name: "Avg target fund size amount"
      expr: AVG(CAST(target_fund_size_amount AS DOUBLE))
      comment: "Average target fund size reviewed."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Management Fee Percent"
      display_name: "Avg management fee percent"
      expr: AVG(CAST(management_fee_percent AS DOUBLE))
      comment: "Average fund management fee — cost benchmark."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Carried Interest Percent"
      display_name: "Avg carried interest percent"
      expr: AVG(CAST(carried_interest_percent AS DOUBLE))
      comment: "Average fund carried interest — GP economics benchmark."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Hurdle Rate Percent"
      display_name: "Avg hurdle rate percent"
      expr: AVG(CAST(hurdle_rate_percent AS DOUBLE))
      comment: "Average hurdle rate — preferred return benchmark."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Strategic Fit Score"
      display_name: "Avg strategic fit score"
      expr: AVG(CAST(strategic_fit_score AS DOUBLE))
      comment: "Average strategic fit score of reviewed funds."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg GP Prior Fund Count"
      display_name: "Avg gp prior fund count"
      expr: AVG(CAST(gp_prior_fund_count AS DOUBLE))
      comment: "Average number of prior funds — GP track-record depth."
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Red Flag Review Count"
      display_name: "Red flag review count"
      expr: COUNT(CASE WHEN red_flags_identified IS NOT NULL THEN 1 END)
      comment: "Reviews that identified red flags — DD risk detection."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`deal_screening_decision`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Initial screening governance KPIs — screening outcomes, concern flags, committee voting and strategic fit. Steers top-of-funnel quality control."
  source: "`asset_management`.`deal`.`screening_decision`"
  dimensions:
    - name: "Decision Outcome"
      display_name: "Decision outcome"
      expr: decision_outcome
      comment: "Screening decision outcome (advance, hold, decline)."
    - name: "Decision Status"
      display_name: "Decision status"
      expr: decision_status
      comment: "Status of the screening decision."
    - name: "Screening Type"
      display_name: "Screening type"
      expr: screening_type
      comment: "Type of screening performed."
    - name: "Risk Rating"
      display_name: "Risk rating"
      expr: risk_rating
      comment: "Risk rating assigned during screening."
    - name: "ESG Rating"
      display_name: "Esg rating"
      expr: esg_rating
      comment: "ESG rating assigned during screening."
    - name: "Decline Reason Code"
      display_name: "Decline reason code"
      expr: decline_reason_code
      comment: "Coded reason for declining at screening."
    - name: "Screening Month"
      display_name: "Screening month"
      expr: DATE_TRUNC('month', screening_date)
      comment: "Screening date bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Screening Count"
      display_name: "Screening count"
      expr: COUNT(1)
      comment: "Number of screening decisions — top-of-funnel throughput."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Opportunities Screened"
      display_name: "Distinct opportunities screened"
      expr: COUNT(DISTINCT opportunity_id)
      comment: "Distinct opportunities that passed through screening."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Strategic Fit Score"
      display_name: "Avg strategic fit score"
      expr: AVG(CAST(strategic_fit_score AS DOUBLE))
      comment: "Average strategic fit score at screening — quality of intake."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "ESG Excluded Count"
      display_name: "Esg excluded count"
      expr: COUNT(CASE WHEN esg_exclusion_flag = TRUE THEN 1 END)
      comment: "Opportunities excluded on ESG grounds at screening."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Legal Concern Count"
      display_name: "Legal concern count"
      expr: COUNT(CASE WHEN legal_concern_flag = TRUE THEN 1 END)
      comment: "Screenings flagging legal concerns."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Valuation Concern Count"
      display_name: "Valuation concern count"
      expr: COUNT(CASE WHEN valuation_concern_flag = TRUE THEN 1 END)
      comment: "Screenings flagging valuation concerns."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Operational Concern Count"
      display_name: "Operational concern count"
      expr: COUNT(CASE WHEN operational_concern_flag = TRUE THEN 1 END)
      comment: "Screenings flagging operational concerns."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Quorum Met Count"
      display_name: "Quorum met count"
      expr: COUNT(CASE WHEN quorum_met = TRUE THEN 1 END)
      comment: "Screenings where committee quorum was met — governance validity."
      format:
        type: number
        decimal_places:
          type: all
    - name: "IC Submission Required Count"
      display_name: "Ic submission required count"
      expr: COUNT(CASE WHEN ic_submission_required = TRUE THEN 1 END)
      comment: "Screenings requiring IC submission — advancement signal."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`deal_stage_transition`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Pipeline velocity and gate KPIs — stage dwell times, gate pass rates and pipeline cycle time. Steers deal-process efficiency."
  source: "`asset_management`.`deal`.`stage_transition`"
  dimensions:
    - name: "Prior Stage Name"
      display_name: "Prior stage name"
      expr: prior_stage_name
      comment: "Pipeline stage the deal transitioned from."
    - name: "New Stage Name"
      display_name: "New stage name"
      expr: new_stage_name
      comment: "Pipeline stage the deal transitioned to."
    - name: "Decision Outcome"
      display_name: "Decision outcome"
      expr: decision_outcome
      comment: "Outcome of the stage transition decision."
    - name: "Decision Type"
      display_name: "Decision type"
      expr: decision_type
      comment: "Type of decision driving the transition."
    - name: "Transition Type"
      display_name: "Transition type"
      expr: transition_type
      comment: "Classification of the transition event."
    - name: "Transition Month"
      display_name: "Transition month"
      expr: DATE_TRUNC('month', transition_date)
      comment: "Transition date bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Transition Count"
      display_name: "Transition count"
      expr: COUNT(1)
      comment: "Number of stage transitions — pipeline movement baseline."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Opportunities Moved"
      display_name: "Distinct opportunities moved"
      expr: COUNT(DISTINCT opportunity_id)
      comment: "Distinct opportunities that advanced stage — flow breadth."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Days In Prior Stage"
      display_name: "Avg days in prior stage"
      expr: AVG(CAST(days_in_prior_stage AS DOUBLE))
      comment: "Average dwell time in the prior stage — velocity indicator."
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Cumulative Days In Pipeline"
      display_name: "Avg cumulative days in pipeline"
      expr: AVG(CAST(cumulative_days_in_pipeline AS DOUBLE))
      comment: "Average cumulative time in pipeline — end-to-end cycle time."
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Gate Criteria Met Count"
      display_name: "Gate criteria met count"
      expr: COUNT(CASE WHEN gate_criteria_met = TRUE THEN 1 END)
      comment: "Transitions where gate criteria were met — gate pass numerator."
      format:
        type: number
        decimal_places:
          type: all
    - name: "IC Approval Received Count"
      display_name: "Ic approval received count"
      expr: COUNT(CASE WHEN ic_approval_received = TRUE THEN 1 END)
      comment: "Transitions with IC approval received."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Rejected Transition Count"
      display_name: "Rejected transition count"
      expr: COUNT(CASE WHEN rejection_reason IS NOT NULL THEN 1 END)
      comment: "Transitions rejected — pipeline attrition."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`deal_target_entity`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Target company universe KPIs — financial scale, ESG scoring and coverage across sectors and geographies. Steers origination targeting."
  source: "`asset_management`.`deal`.`target_entity`"
  dimensions:
    - name: "Asset Class"
      display_name: "Asset class"
      expr: asset_class
      comment: "Asset class of the target entity."
    - name: "Sub Asset Class"
      display_name: "Sub asset class"
      expr: sub_asset_class
      comment: "Sub-asset-class of the target entity."
    - name: "Industry Sector"
      display_name: "Industry sector"
      expr: industry_sector
      comment: "Industry sector of the target."
    - name: "Headquarters Country"
      display_name: "Headquarters country"
      expr: headquarters_country
      comment: "Headquarters country of the target."
    - name: "Jurisdiction Of Incorporation"
      display_name: "Jurisdiction of incorporation"
      expr: jurisdiction_of_incorporation
      comment: "Jurisdiction where the target is incorporated."
    - name: "Target Type"
      display_name: "Target type"
      expr: target_type
      comment: "Type of target entity."
    - name: "Target Status"
      display_name: "Target status"
      expr: target_status
      comment: "Current status of the target entity."
    - name: "Is Publicly Listed"
      display_name: "Is publicly listed"
      expr: is_publicly_listed
      comment: "Whether the target is publicly listed."
    - name: "Credit Rating"
      display_name: "Credit rating"
      expr: credit_rating
      comment: "External credit rating of the target."
  measures:
    - name: "Target Entity Count"
      display_name: "Target entity count"
      expr: COUNT(1)
      comment: "Number of target entities in the universe — coverage breadth."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Enterprise Value Amount"
      display_name: "Total enterprise value amount"
      expr: SUM(CAST(enterprise_value_amount AS DOUBLE))
      comment: "Aggregate enterprise value across the target universe."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Annual Revenue Amount"
      display_name: "Total annual revenue amount"
      expr: SUM(CAST(annual_revenue_amount AS DOUBLE))
      comment: "Aggregate annual revenue across targets — scale of opportunity set."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg EBITDA Amount"
      display_name: "Avg ebitda amount"
      expr: AVG(CAST(ebitda_amount AS DOUBLE))
      comment: "Average EBITDA of target entities — earnings profile."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg ESG Score"
      display_name: "Avg esg score"
      expr: AVG(CAST(esg_score AS DOUBLE))
      comment: "Average ESG score across targets — sustainability posture."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Employee Count"
      display_name: "Avg employee count"
      expr: AVG(CAST(employee_count AS DOUBLE))
      comment: "Average headcount of target entities — operational scale."
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "Publicly Listed Count"
      display_name: "Publicly listed count"
      expr: COUNT(CASE WHEN is_publicly_listed = TRUE THEN 1 END)
      comment: "Targets that are publicly listed — public vs private mix."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`deal_valuation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Deal valuation KPIs — enterprise/equity value, multiples, discount rates and valuation quality. Supports pricing discipline and investment analysis."
  source: "`asset_management`.`deal`.`deal_valuation`"
  dimensions:
    - name: "Methodology"
      display_name: "Methodology"
      expr: methodology
      comment: "Valuation methodology (DCF, comparables, precedent transactions)."
    - name: "Valuation Type"
      display_name: "Valuation type"
      expr: valuation_type
      comment: "Type of valuation performed."
    - name: "Valuation Status"
      display_name: "Valuation status"
      expr: valuation_status
      comment: "Status of the valuation record."
    - name: "Confidence Level"
      display_name: "Confidence level"
      expr: confidence_level
      comment: "Analyst confidence level in the valuation."
    - name: "Currency"
      display_name: "Currency"
      expr: currency
      comment: "Currency of the valuation figures."
    - name: "Valuation Month"
      display_name: "Valuation month"
      expr: DATE_TRUNC('month', valuation_date)
      comment: "Valuation date bucketed to month."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Valuation Year"
      display_name: "Valuation year"
      expr: DATE_TRUNC('year', valuation_date)
      comment: "Valuation date bucketed to year."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Valuation Count"
      display_name: "Valuation count"
      expr: COUNT(1)
      comment: "Number of valuations performed — analytical coverage."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Enterprise Value"
      display_name: "Total enterprise value"
      expr: SUM(CAST(enterprise_value AS DOUBLE))
      comment: "Aggregate enterprise value across valuations."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Total Equity Value"
      display_name: "Total equity value"
      expr: SUM(CAST(equity_value AS DOUBLE))
      comment: "Aggregate equity value across valuations."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Avg EBITDA Multiple"
      display_name: "Avg ebitda multiple"
      expr: AVG(CAST(ebitda_multiple AS DOUBLE))
      comment: "Average EV/EBITDA multiple — pricing benchmark."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Revenue Multiple"
      display_name: "Avg revenue multiple"
      expr: AVG(CAST(revenue_multiple AS DOUBLE))
      comment: "Average EV/Revenue multiple."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Discount Rate Percent"
      display_name: "Avg discount rate percent"
      expr: AVG(CAST(discount_rate_percent AS DOUBLE))
      comment: "Average discount rate used in valuations."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg WACC Percent"
      display_name: "Avg wacc percent"
      expr: AVG(CAST(wacc_percent AS DOUBLE))
      comment: "Average weighted average cost of capital applied."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Data Quality Score"
      display_name: "Avg data quality score"
      expr: AVG(CAST(data_quality_score AS DOUBLE))
      comment: "Average data quality score — valuation reliability indicator."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Sensitivity Analysis Count"
      display_name: "Sensitivity analysis count"
      expr: COUNT(CASE WHEN sensitivity_analysis_performed = TRUE THEN 1 END)
      comment: "Valuations with sensitivity analysis — analytical rigor coverage."
      format:
        type: number
        decimal_places:
          type: all
$$;
