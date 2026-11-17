-- Metric views for domain: shared | Business: Asset Management | Version: 1 | Generated on: 2026-11-10 14:18:58

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`shared_auditor`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Semantic KPI layer over the auditor master supporting fund-governance and SOX oversight — monitors auditor independence, rotation due dates, PCAOB registration and ESG-audit capability across the approved auditor panel."
  source: "`asset_management`.`shared`.`auditor`"
  dimensions:
    - name: "auditor_type"
      display_name: "Auditor Type"
      expr: auditor_type
      comment: "Type of auditor for panel segmentation."
    - name: "auditor_status"
      display_name: "Auditor Status"
      expr: independence_status
      comment: "Engagement independence_status of the auditor."
    - name: "independence_status"
      display_name: "Independence Status"
      expr: independence_status
      comment: "Independence status for governance compliance monitoring."
    - name: "quality_rating"
      display_name: "Quality Rating"
      expr: quality_rating
      comment: "Quality rating of the auditor for panel-quality assessment."
    - name: "jurisdiction_country"
      display_name: "Jurisdiction Country"
      expr: jurisdiction_country_code
      comment: "Regulatory jurisdiction of the auditor."
    - name: "global_network_affiliation"
      display_name: "Global Network Affiliation"
      expr: global_network_affiliation
      comment: "Global network affiliation for concentration-risk analysis."
  measures:
    - name: "auditor_count"
      display_name: "Auditor Count"
      expr: COUNT(1)
      comment: "Total number of auditors on the panel — baseline governance capacity."
      format:
        type: number
        decimal_places:
          type: all
    - name: "pcaob_registered_pct"
      display_name: "PCAOB Registered %"
      expr: ROUND(100.0 * COUNT(CASE WHEN pcaob_registered_flag = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of PCAOB-registered auditors — key eligibility and quality assurance KPI for the audit panel."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "rotation_due_count"
      display_name: "Rotation Due Count"
      expr: COUNT(CASE WHEN rotation_due_date < CURRENT_DATE THEN 1 END)
      comment: "Count of auditors past their mandatory-rotation due date — triggers independence remediation under SOX governance."
      format:
        type: number
        decimal_places:
          type: all
    - name: "esg_capable_pct"
      display_name: "ESG Capable %"
      expr: ROUND(100.0 * COUNT(CASE WHEN esg_audit_capability_flag = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of auditors with ESG-audit capability — supports SFDR/ESG assurance sourcing decisions."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "independent_auditor_pct"
      display_name: "Independent Auditor %"
      expr: ROUND(100.0 * COUNT(CASE WHEN independence_status = 'INDEPENDENT' THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of auditors confirmed independent — core governance-integrity KPI reviewed at audit-committee level."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`shared_contract`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Semantic KPI layer over the contract master for investment management agreements (fund commitments, counterparty contracts). Enables leadership to monitor committed capital, fee economics, renewal/expiry exposure and governance clauses across the contract portfolio."
  source: "`asset_management`.`shared`.`contract`"
  dimensions:
    - name: "contract_category"
      display_name: "Contract Category"
      expr: contract_category
      comment: "Business contract_category of the contract used to segment the agreement portfolio."
    - name: "contract_type"
      display_name: "Contract Type"
      expr: contract_type
      comment: "Contract contract_type classification for grouping fee and commitment analysis."
    - name: "contract_status"
      display_name: "Contract Status"
      expr: contract_status
      comment: "Lifecycle contract_status of the contract (active, terminated, expired, etc.)."
    - name: "currency_code"
      display_name: "Currency"
      expr: currency_code
      comment: "Currency the commitment and fee amounts are denominated in."
    - name: "governing_law_country"
      display_name: "Governing Law Country"
      expr: governing_law_country
      comment: "Governing law jurisdiction for legal and regulatory exposure segmentation."
    - name: "reporting_frequency"
      display_name: "Reporting Frequency"
      expr: reporting_frequency
      comment: "Contractual reporting cadence used for operational planning."
    - name: "effective_month"
      display_name: "Effective Month"
      expr: DATE_TRUNC('month', effective_date)
      comment: "Month in which the contract becomes effective, for time-series trending."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "effective_year"
      display_name: "Effective Year"
      expr: DATE_TRUNC('year', effective_date)
      comment: "Year in which the contract becomes effective."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "expiration_year"
      display_name: "Expiration Year"
      expr: DATE_TRUNC('year', expiration_date)
      comment: "Year in which the contract expires, for renewal/rollover exposure analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "contract_count"
      display_name: "Contract Count"
      expr: COUNT(1)
      comment: "Total number of contracts — baseline portfolio size for governance and workload planning."
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_committed_capital"
      display_name: "Total Committed Capital"
      expr: SUM(CAST(total_commitment_amount AS DOUBLE))
      comment: "Total committed capital across contracts — the core allocation exposure leadership steers against undrawn and deployed capital planning."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_committed_capital"
      display_name: "Avg Commitment Size"
      expr: AVG(CAST(total_commitment_amount AS DOUBLE))
      comment: "Average commitment size per contract — informs concentration and manager-ticket-size strategy."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_management_fee_rate"
      display_name: "Avg Management Fee Rate"
      expr: AVG(CAST(management_fee_rate AS DOUBLE))
      comment: "Average management fee rate across contracts — key lever for cost-of-management and fee negotiation strategy."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "avg_performance_fee_rate"
      display_name: "Avg Performance Fee Rate"
      expr: AVG(CAST(performance_fee_rate AS DOUBLE))
      comment: "Average performance (carry) fee rate — drives net-of-fee return modelling and alignment assessment."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "avg_hurdle_rate"
      display_name: "Avg Hurdle Rate"
      expr: AVG(CAST(hurdle_rate AS DOUBLE))
      comment: "Average hurdle rate across contracts — indicates performance-fee alignment protection for the fund."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 4
    - name: "esg_compliance_required_contracts"
      display_name: "ESG-Required Contracts"
      expr: COUNT(CASE WHEN esg_compliance_required = TRUE THEN 1 END)
      comment: "Count of contracts with mandatory ESG compliance clauses — monitors SFDR/ESG integration coverage across the manager roster."
      format:
        type: number
        decimal_places:
          type: all
    - name: "esg_compliance_coverage_pct"
      display_name: "ESG Compliance Coverage %"
      expr: ROUND(100.0 * COUNT(CASE WHEN esg_compliance_required = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of contracts carrying ESG compliance obligations — tracks progress on responsible-investment policy embedding."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "auto_renewal_pct"
      display_name: "Auto-Renewal %"
      expr: ROUND(100.0 * COUNT(CASE WHEN is_auto_renewal = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of contracts set to auto-renew — flags renewal exposure that may require proactive renegotiation."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "mfn_clause_pct"
      display_name: "MFN Clause %"
      expr: ROUND(100.0 * COUNT(CASE WHEN mfn_clause_indicator = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of contracts with Most-Favoured-Nation protections — measures commercial leverage secured across the book."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`shared_department`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Semantic KPI layer over the department master enabling finance and COO to monitor operating-budget allocation, headcount budgeting and investment-team coverage across the organisational hierarchy."
  source: "`asset_management`.`shared`.`department`"
  dimensions:
    - name: "department_type"
      display_name: "Department Type"
      expr: department_type
      comment: "Type of department for organisational segmentation."
    - name: "functional_area"
      display_name: "Functional Area"
      expr: functional_area
      comment: "Functional area the department belongs to."
    - name: "asset_class_focus"
      display_name: "Asset Class Focus"
      expr: asset_class_focus
      comment: "Asset-class focus of the department for investment-coverage analysis."
    - name: "regulatory_jurisdiction"
      display_name: "Regulatory Jurisdiction"
      expr: regulatory_jurisdiction
      comment: "Regulatory jurisdiction of the department."
    - name: "budget_currency"
      display_name: "Budget Currency"
      expr: budget_currency_code
      comment: "Currency of the department operating budget."
  measures:
    - name: "department_count"
      display_name: "Department Count"
      expr: COUNT(1)
      comment: "Total number of departments — baseline organisational footprint."
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_operating_budget"
      display_name: "Total Operating Budget"
      expr: SUM(CAST(annual_operating_budget AS DOUBLE))
      comment: "Total annual operating budget across departments — primary cost-planning aggregate for finance."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_headcount_budget"
      display_name: "Total Headcount Budget"
      expr: SUM(CAST(headcount_budget AS DOUBLE))
      comment: "Total budgeted headcount across departments — workforce-planning aggregate versus actual headcount."
      format:
        type: number
        decimal_places:
          type: all
    - name: "investment_team_pct"
      display_name: "Investment Team %"
      expr: ROUND(100.0 * COUNT(CASE WHEN is_investment_team = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of departments that are investment teams — measures front-office vs support-function balance."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "avg_operating_budget"
      display_name: "Avg Operating Budget"
      expr: AVG(CAST(annual_operating_budget AS DOUBLE))
      comment: "Average operating budget per department — benchmarks resourcing across functions."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`shared_employee`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Semantic KPI layer over the employee master enabling HR and investment-leadership to monitor headcount, compensation cost, and workforce composition across departments and job levels."
  source: "`asset_management`.`shared`.`employee`"
  dimensions:
    - name: "employment_status"
      display_name: "Employment Status"
      expr: employment_status
      comment: "Current employment status (active, terminated, on-leave)."
    - name: "employment_type"
      display_name: "Employment Type"
      expr: employment_type
      comment: "Employment type (permanent, contract, part-time) for workforce mix analysis."
    - name: "job_level"
      display_name: "Job Level"
      expr: job_level
      comment: "Seniority/job level for compensation banding and span-of-control analysis."
    - name: "job_title"
      display_name: "Job Title"
      expr: job_title
      comment: "Role title for staffing composition analysis."
    - name: "salary_currency"
      display_name: "Salary Currency"
      expr: salary_currency
      comment: "Currency of compensation for cross-office normalisation."
    - name: "hire_year"
      display_name: "Hire Year"
      expr: DATE_TRUNC('year', employment_start_date)
      comment: "Year of hire for tenure cohort and attrition analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "employee_count"
      display_name: "Employee Count"
      expr: COUNT(1)
      comment: "Total employee headcount — baseline workforce size for capacity planning."
      format:
        type: number
        decimal_places:
          type: all
    - name: "active_employee_count"
      display_name: "Active Employee Count"
      expr: COUNT(CASE WHEN employment_status = 'ACTIVE' THEN 1 END)
      comment: "Count of active employees — current deployable workforce leadership steers against budget."
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_salary_cost"
      display_name: "Total Salary Cost"
      expr: SUM(CAST(salary AS DOUBLE))
      comment: "Total base salary cost — primary fixed personnel cost driver for budget decisions."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_bonus_cost"
      display_name: "Total Bonus Cost"
      expr: SUM(CAST(bonus AS DOUBLE))
      comment: "Total bonus/variable compensation cost — key lever in performance-pay and cost-management decisions."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "avg_salary"
      display_name: "Avg Salary"
      expr: AVG(CAST(salary AS DOUBLE))
      comment: "Average base salary per employee — benchmarks compensation competitiveness by segment."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`shared_fund_administrator`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Semantic KPI layer over the fund administrator master enabling operational-due-diligence teams to monitor serviced AUM, certification coverage (SOC/ISAE/ISO) and due-diligence currency across the administrator panel."
  source: "`asset_management`.`shared`.`fund_administrator`"
  dimensions:
    - name: "administrator_type"
      display_name: "Administrator Type"
      expr: administrator_type
      comment: "Type of fund administrator for panel segmentation."
    - name: "administrator_status"
      display_name: "Administrator Status"
      expr: fund_administrator_status
      comment: "Relationship fund_administrator_status of the administrator."
    - name: "service_tier"
      display_name: "Service Tier"
      expr: service_tier
      comment: "Service tier of the administrator for oversight prioritisation."
    - name: "due_diligence_rating"
      display_name: "Due Diligence Rating"
      expr: due_diligence_rating
      comment: "Operational due-diligence rating assigned to the administrator."
    - name: "domicile_country"
      display_name: "Domicile Country"
      expr: domicile_country_code
      comment: "Domicile country for jurisdictional concentration analysis."
    - name: "primary_regulator"
      display_name: "Primary Regulator"
      expr: primary_regulator
      comment: "Primary regulator overseeing the administrator."
  measures:
    - name: "administrator_count"
      display_name: "Administrator Count"
      expr: COUNT(1)
      comment: "Total number of fund administrators on the panel — baseline operational-vendor footprint."
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_serviced_aum"
      display_name: "Total Serviced AUM (USD)"
      expr: SUM(CAST(aum_usd AS DOUBLE))
      comment: "Total AUM serviced by administrators — sizes operational concentration and counterparty-reliance exposure."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "soc_certified_pct"
      display_name: "SOC Certified %"
      expr: ROUND(100.0 * COUNT(CASE WHEN soc1_certified = TRUE OR soc2_certified = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of administrators with SOC1/SOC2 certification — core control-assurance KPI for operational due diligence."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "overdue_due_diligence_count"
      display_name: "Overdue Due Diligence Count"
      expr: COUNT(CASE WHEN next_due_diligence_date < CURRENT_DATE THEN 1 END)
      comment: "Count of administrators with overdue due diligence — drives ODD remediation scheduling."
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_funds_serviced"
      display_name: "Total Funds Serviced"
      expr: SUM(CAST(number_of_funds_serviced AS DOUBLE))
      comment: "Total number of funds serviced across administrators — capacity and concentration indicator for operations."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`shared_legal_entity`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Semantic KPI layer over the legal entity master covering counterparties, issuers, investment managers and internal entities. Enables risk, compliance and ESG teams to monitor KYC status, credit/ESG quality and counterparty concentration across jurisdictions."
  source: "`asset_management`.`shared`.`legal_entity`"
  dimensions:
    - name: "entity_type"
      display_name: "Entity Type"
      expr: entity_type
      comment: "Type of legal entity for segmentation (corporate, fund, SPV, etc.)."
    - name: "entity_status"
      display_name: "Entity Status"
      expr: entity_status
      comment: "Active/inactive status of the legal entity."
    - name: "incorporation_country"
      display_name: "Incorporation Country"
      expr: incorporation_country_code
      comment: "Country of incorporation for jurisdictional concentration and risk analysis."
    - name: "aml_risk_rating"
      display_name: "AML Risk Rating"
      expr: aml_risk_rating
      comment: "AML risk tier of the entity used for compliance prioritisation."
    - name: "kyc_status"
      display_name: "KYC Status"
      expr: kyc_status
      comment: "KYC verification status for onboarding and remediation monitoring."
    - name: "credit_rating"
      display_name: "Credit Rating"
      expr: credit_rating
      comment: "External credit rating of the counterparty/issuer for credit-risk segmentation."
    - name: "esg_rating"
      display_name: "ESG Rating"
      expr: esg_rating
      comment: "ESG rating assigned to the entity for responsible-investment screening."
    - name: "industry_sector"
      display_name: "Industry Sector"
      expr: industry_sector
      comment: "Industry sector of the entity for exposure diversification analysis."
    - name: "counterparty_classification"
      display_name: "Counterparty Classification"
      expr: counterparty_classification
      comment: "Regulatory counterparty classification (e.g. for EMIR trade reporting)."
  measures:
    - name: "entity_count"
      display_name: "Legal Entity Count"
      expr: COUNT(1)
      comment: "Total number of legal entities — baseline counterparty/issuer universe size."
      format:
        type: number
        decimal_places:
          type: all
    - name: "distinct_jurisdictions"
      display_name: "Distinct Jurisdictions"
      expr: COUNT(DISTINCT incorporation_country_code)
      comment: "Number of distinct incorporation jurisdictions — measures geographic diversification of the counterparty base."
      format:
        type: number
        decimal_places:
          type: all
    - name: "kyc_verified_pct"
      display_name: "KYC Verified %"
      expr: ROUND(100.0 * COUNT(CASE WHEN kyc_status = 'VERIFIED' THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of entities with verified KYC — core AML/KYC compliance coverage KPI leadership acts on when gaps appear."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "high_aml_risk_pct"
      display_name: "High AML Risk %"
      expr: ROUND(100.0 * COUNT(CASE WHEN aml_risk_rating IN ('HIGH','VERY_HIGH') THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of entities flagged as high AML risk — triggers enhanced due diligence and exposure review."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "expired_kyc_count"
      display_name: "Expired KYC Count"
      expr: COUNT(CASE WHEN kyc_expiry_date < CURRENT_DATE THEN 1 END)
      comment: "Count of entities with lapsed KYC verification — directly drives remediation workload and regulatory risk."
      format:
        type: number
        decimal_places:
          type: all
    - name: "esg_rated_coverage_pct"
      display_name: "ESG Rating Coverage %"
      expr: ROUND(100.0 * COUNT(CASE WHEN esg_rating IS NOT NULL THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of entities with an assigned ESG rating — tracks ESG data coverage underpinning SFDR disclosures."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "investment_manager_count"
      display_name: "Investment Manager Count"
      expr: COUNT(CASE WHEN is_investment_manager = TRUE THEN 1 END)
      comment: "Count of entities acting as external investment managers — sizing the manager roster for oversight capacity."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`shared_loan_servicer`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Semantic KPI layer over the loan servicer master supporting credit/real-estate operations oversight — monitors serviced unpaid-principal balance, servicing-capacity utilisation, approval status and due-diligence currency."
  source: "`asset_management`.`shared`.`loan_servicer`"
  dimensions:
    - name: "servicer_type"
      display_name: "Servicer Type"
      expr: servicer_type
      comment: "Type of loan servicer for panel segmentation."
    - name: "servicer_status"
      display_name: "Servicer Status"
      expr: servicer_status
      comment: "Status of the loan servicer relationship."
    - name: "asset_class_specialization"
      display_name: "Asset Class Specialization"
      expr: asset_class_specialization
      comment: "Asset-class specialisation for exposure mapping."
    - name: "regulatory_rating"
      display_name: "Regulatory Rating"
      expr: regulatory_rating
      comment: "Regulatory rating of the servicer for quality assessment."
    - name: "jurisdiction_country"
      display_name: "Jurisdiction Country"
      expr: jurisdiction_country_code
      comment: "Jurisdiction of the servicer for concentration analysis."
  measures:
    - name: "servicer_count"
      display_name: "Loan Servicer Count"
      expr: COUNT(1)
      comment: "Total number of loan servicers — baseline servicing-panel size."
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_serviced_upb"
      display_name: "Total Serviced UPB (USD)"
      expr: SUM(CAST(current_portfolio_upb_usd AS DOUBLE))
      comment: "Total unpaid principal balance under servicing — primary credit-exposure concentration metric."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "total_servicing_capacity"
      display_name: "Total Servicing Capacity (USD)"
      expr: SUM(CAST(servicing_capacity_usd AS DOUBLE))
      comment: "Total servicing capacity across the panel — informs headroom for new credit originations."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "approved_servicer_pct"
      display_name: "Approved Servicer %"
      expr: ROUND(100.0 * COUNT(CASE WHEN is_approved_servicer = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of servicers that are approved — eligibility KPI for placing servicing mandates."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "avg_servicing_fee_bps"
      display_name: "Avg Servicing Fee (bps)"
      expr: AVG(CAST(servicing_fee_rate_bps AS DOUBLE))
      comment: "Average servicing fee rate in basis points — cost-of-servicing lever for credit-portfolio economics."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "overdue_due_diligence_count"
      display_name: "Overdue Due Diligence Count"
      expr: COUNT(CASE WHEN next_due_diligence_date < CURRENT_DATE THEN 1 END)
      comment: "Count of servicers with overdue due diligence — drives ODD remediation and risk escalation."
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`shared_vendor`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Semantic KPI layer over the vendor master enabling procurement, risk and ESG teams to monitor supplier risk, due-diligence currency, diversity commitments and payment terms across the vendor base."
  source: "`asset_management`.`shared`.`vendor`"
  dimensions:
    - name: "vendor_category"
      display_name: "Vendor Category"
      expr: vendor_category
      comment: "Vendor service vendor_category for spend and risk segmentation."
    - name: "vendor_status"
      display_name: "Vendor Status"
      expr: due_diligence_status
      comment: "Vendor relationship due_diligence_status (active, onboarding, terminated)."
    - name: "criticality_tier"
      display_name: "Criticality Tier"
      expr: criticality_tier
      comment: "Business-criticality tier used to prioritise resilience and oversight."
    - name: "risk_rating"
      display_name: "Risk Rating"
      expr: risk_rating
      comment: "Overall vendor risk rating for third-party risk management."
    - name: "due_diligence_status"
      display_name: "Due Diligence Status"
      expr: due_diligence_status
      comment: "Current due-diligence status of the vendor."
    - name: "headquarters_country"
      display_name: "HQ Country"
      expr: headquarters_country
      comment: "Vendor HQ country for geographic concentration analysis."
    - name: "esg_rating"
      display_name: "ESG Rating"
      expr: esg_rating
      comment: "Vendor ESG rating for responsible-sourcing screening."
  measures:
    - name: "vendor_count"
      display_name: "Vendor Count"
      expr: COUNT(1)
      comment: "Total number of vendors — baseline supplier-base size."
      format:
        type: number
        decimal_places:
          type: all
    - name: "high_risk_vendor_pct"
      display_name: "High Risk Vendor %"
      expr: ROUND(100.0 * COUNT(CASE WHEN risk_rating IN ('HIGH','VERY_HIGH') THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of vendors rated high risk — core third-party risk KPI that triggers mitigation action."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "overdue_due_diligence_count"
      display_name: "Overdue Due Diligence Count"
      expr: COUNT(CASE WHEN next_due_diligence_date < CURRENT_DATE THEN 1 END)
      comment: "Count of vendors with overdue due diligence — direct driver of compliance remediation workload."
      format:
        type: number
        decimal_places:
          type: all
    - name: "diverse_vendor_pct"
      display_name: "Diverse Vendor %"
      expr: ROUND(100.0 * COUNT(CASE WHEN is_minority_owned = TRUE OR is_women_owned = TRUE THEN 1 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Share of minority- or women-owned vendors — tracks supplier-diversity commitments reported to stakeholders."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "avg_payment_terms_days"
      display_name: "Avg Payment Terms (Days)"
      expr: AVG(CAST(payment_terms_days AS DOUBLE))
      comment: "Average payment terms in days — working-capital and cash-flow management lever."
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "critical_vendor_count"
      display_name: "Critical Vendor Count"
      expr: COUNT(CASE WHEN criticality_tier IN ('TIER_1','CRITICAL') THEN 1 END)
      comment: "Count of business-critical vendors — focuses resilience and continuity planning on highest-impact suppliers."
      format:
        type: number
        decimal_places:
          type: all
$$;
