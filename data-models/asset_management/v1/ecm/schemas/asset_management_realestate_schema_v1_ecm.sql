-- Schema for Domain: realestate | Business: Asset Management | Version: v1_ecm
-- Generated on: 2026-11-10 14:17:28

-- ========= DATABASE =========
CREATE DATABASE IF NOT EXISTS `asset_management`.`realestate` COMMENT 'Domain for real estate investment operations including direct property holdings, REIT positions, real estate fund investments, and property-level asset management.';
ALTER SCHEMA `asset_management`.`realestate` SET TAGS ('dbx_division' = 'operations');
ALTER SCHEMA `asset_management`.`realestate` SET TAGS ('dbx_domain' = 'realestate');

-- ========= TABLES =========
CREATE OR REPLACE TABLE `asset_management`.`realestate`.`property` (
    `property_id` BIGINT COMMENT 'Unique identifier for the direct real estate asset held by the pension fund.',
    `acquisition_date` DATE COMMENT 'The date on which the pension fund acquired ownership or controlling interest in the property.',
    `acquisition_price` DECIMAL(18,2) COMMENT 'The total purchase price paid at acquisition, including transaction costs, in the propertys functional currency.',
    `asset_class` STRING COMMENT 'The primary real estate asset class categorization for the property.. Valid values are `commercial_office|industrial_logistics|retail|residential|mixed_use|specialty`',
    `cap_rate_percent` DECIMAL(5,2) COMMENT 'The capitalization rate used in valuation, calculated as NOI divided by property value, expressed as a percentage.',
    `capex_budget_annual` DECIMAL(18,2) COMMENT 'Annual capital expenditure budget allocated for property improvements, renovations, and value creation initiatives.',
    `city` STRING COMMENT 'The city or municipality where the property is located.',
    `property_code` STRING COMMENT 'The externally-known unique identifier or asset tag for the property used in portfolio reporting and fund administration systems.',
    `country_code` STRING COMMENT 'Three-letter ISO 3166-1 alpha-3 country code where the property is located (e.g., USA, CAN, GBR).. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this property record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the propertys functional currency (e.g., USD, EUR, GBP).. Valid values are `^[A-Z]{3}$`',
    `disposition_date` DATE COMMENT 'The date on which the pension fund disposed of or sold the property, if applicable.',
    `disposition_price` DECIMAL(18,2) COMMENT 'The total sale price received upon disposition of the property, net of transaction costs, if applicable.',
    `dscr` DECIMAL(5,2) COMMENT 'Debt Service Coverage Ratio calculated as NOI divided by annual debt service obligations.',
    `energy_consumption_kwh_annual` DECIMAL(15,2) COMMENT 'Total annual energy consumption of the property measured in kilowatt-hours for ESG reporting and operational efficiency tracking.',
    `esg_certification` STRING COMMENT 'ESG or green building certification held by the property (e.g., LEED Gold, BREEAM Excellent, ENERGY STAR).',
    `gav` DECIMAL(18,2) COMMENT 'Gross Asset Value representing the total fair market value of the property before deducting any debt or liabilities.',
    `ghg_emissions_tonnes_co2e_annual` DECIMAL(12,2) COMMENT 'Total annual greenhouse gas emissions from property operations measured in tonnes of carbon dioxide equivalent for ESG and TCFD reporting.',
    `gross_leasable_area_sqft` DECIMAL(12,2) COMMENT 'Total leasable floor area of the property measured in square feet, excluding common areas and structural elements.',
    `investment_strategy` STRING COMMENT 'The investment strategy classification for the property (core, core-plus, value-add, opportunistic) based on risk-return profile.. Valid values are `core|core_plus|value_add|opportunistic`',
    `land_area_acres` DECIMAL(12,4) COMMENT 'Total land area of the property parcel measured in acres.',
    `latitude` DECIMAL(10,7) COMMENT 'Geographic latitude coordinate of the property in decimal degrees.',
    `legal_entity_identifier` STRING COMMENT 'The 20-character ISO 17442 Legal Entity Identifier for the holding entity that owns the property, if applicable.. Valid values are `^[A-Z0-9]{20}$`',
    `lifecycle_status` STRING COMMENT 'Current operational and investment lifecycle status of the property.. Valid values are `active|under_construction|under_renovation|stabilized|held_for_sale|disposed`',
    `longitude` DECIMAL(10,7) COMMENT 'Geographic longitude coordinate of the property in decimal degrees.',
    `ltv_ratio_percent` DECIMAL(5,2) COMMENT 'Loan-to-Value ratio calculated as outstanding debt divided by GAV, expressed as a percentage.',
    `manager_name` STRING COMMENT 'Name of the third-party property management firm or internal team responsible for day-to-day operations.',
    `property_name` STRING COMMENT 'The business or marketing name of the real estate asset (e.g., Tower One Office Complex, Maple Logistics Center).',
    `nav` DECIMAL(18,2) COMMENT 'Net Asset Value representing the equity value of the property after deducting outstanding debt and other liabilities from GAV.',
    `noi_annual` DECIMAL(18,2) COMMENT 'Annual Net Operating Income calculated as gross rental income less operating expenses, excluding debt service and capital expenditures.',
    `occupancy_rate_percent` DECIMAL(5,2) COMMENT 'Current physical occupancy rate of the property expressed as a percentage of gross leasable area.',
    `outstanding_debt` DECIMAL(18,2) COMMENT 'Total outstanding mortgage or loan balance secured against the property.',
    `ownership_percentage` DECIMAL(5,2) COMMENT 'The pension funds percentage ownership interest in the property, expressed as a percentage.',
    `ownership_structure` STRING COMMENT 'The legal ownership structure through which the pension fund holds the property (direct, joint venture, fund investment, REIT).. Valid values are `direct|joint_venture|fund_investment|reit`',
    `postal_code` STRING COMMENT 'The postal or ZIP code for the property location.',
    `property_type` STRING COMMENT 'Detailed property type within the asset class (e.g., Class A Office, Distribution Warehouse, Shopping Mall, Multifamily Apartment).',
    `state_province` STRING COMMENT 'The state, province, or administrative region where the property is located.',
    `street_address` STRING COMMENT 'The full street address of the property including building number and street name.',
    `tax_parcel_number` STRING COMMENT 'The local government tax parcel or assessment identifier for the property used for property tax administration.',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this property record was last modified in the system.',
    `valuation_date` DATE COMMENT 'The effective date of the most recent independent appraisal or valuation for GAV and NAV determination.',
    `valuation_method` STRING COMMENT 'The primary valuation methodology used in the most recent appraisal (e.g., income capitalization, DCF, sales comparison).. Valid values are `income_capitalization|discounted_cash_flow|sales_comparison|cost_approach`',
    `water_consumption_cubic_meters_annual` DECIMAL(12,2) COMMENT 'Total annual water consumption of the property measured in cubic meters for ESG reporting and resource management.',
    `year_built` BIGINT COMMENT 'The year in which the property was originally constructed.',
    `year_renovated` BIGINT COMMENT 'The most recent year in which the property underwent major renovation or capital improvement, if applicable.',
    `zoning_classification` STRING COMMENT 'The municipal zoning classification or land use designation for the property parcel.',
    CONSTRAINT pk_property PRIMARY KEY(`property_id`)
) COMMENT 'Master record (SSOT) for each direct real estate asset held by the pension fund — commercial office, industrial/logistics, retail, residential, mixed-use, and specialty.';

CREATE OR REPLACE TABLE `asset_management`.`realestate`.`property_valuation` (
    `property_valuation_id` BIGINT COMMENT 'Unique identifier for the property valuation record.',
    `cycle_id` BIGINT COMMENT 'Foreign key linking to valuation.cycle. Business justification: Property valuations are grouped into valuation cycles for periodic reporting and regulatory compliance.',
    `property_id` BIGINT COMMENT 'Reference to the real estate property asset being valued.',
    `valuation_asset_valuation_id` BIGINT COMMENT 'Foreign key linking to valuation.valuation_asset_valuation. Business justification: Each property_valuation must reference the formal valuation report in valuation_asset_valuation for audit and reporting.',
    `appraiser_contact_name` STRING COMMENT 'Name of the lead appraiser or valuation professional responsible for the valuation report.',
    `appraiser_firm_name` STRING COMMENT 'Name of the independent appraisal firm or valuation provider that performed the valuation.',
    `appraiser_license_number` STRING COMMENT 'Professional license or certification number of the lead appraiser.',
    `approval_date` DATE COMMENT 'Date on which the valuation was formally approved for use in portfolio reporting and financial statements.',
    `approved_by` STRING COMMENT 'Name or identifier of the internal investment professional who approved the valuation for portfolio reporting purposes.',
    `cap_rate` DECIMAL(5,4) COMMENT 'Capitalization rate applied in the income approach valuation, expressed as a decimal (e.g., 0.0650 for 6.50%).',
    `comparable_sales_count` BIGINT COMMENT 'Number of comparable sales transactions analyzed in the sales comparison approach.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this valuation record was first created in the system.',
    `deferred_maintenance_estimate` DECIMAL(18,2) COMMENT 'Estimated cost of deferred maintenance and immediate capital repairs identified during the valuation inspection.',
    `discount_rate` DECIMAL(5,4) COMMENT 'Discount rate applied in discounted cash flow (DCF) analysis, expressed as a decimal (e.g., 0.0800 for 8.00%).',
    `environmental_risk_description` STRING COMMENT 'Description of any environmental risks, contamination, or remediation requirements identified.',
    `environmental_risk_flag` BOOLEAN COMMENT 'Boolean indicator of whether environmental risks or contamination issues were identified during the valuation process.',
    `gav` DECIMAL(18,2) COMMENT 'Gross Asset Value representing the total market value of the property before deducting any debt or liabilities.',
    `highest_best_use` STRING COMMENT 'Determination of the highest and best use of the property as concluded by the appraiser (e.g., current use, alternative use, redevelopment).',
    `inspection_date` DATE COMMENT 'Date on which the physical property inspection was conducted by the appraiser.',
    `market_liquidity_assessment` STRING COMMENT 'Assessment of the liquidity of the market for this property type and location.. Valid values are `highly_liquid|liquid|moderate|illiquid|highly_illiquid`',
    `market_rent_psf` DECIMAL(10,2) COMMENT 'Estimated market rent per square foot used in the valuation analysis.',
    `nav` DECIMAL(18,2) COMMENT 'Net Asset Value representing the market value of the property after deducting associated debt and liabilities.',
    `noi` DECIMAL(18,2) COMMENT 'Net Operating Income used in the income approach valuation, representing stabilized annual income after operating expenses but before debt service.',
    `prior_valuation_amount` DECIMAL(18,2) COMMENT 'Gross Asset Value (GAV) from the most recent prior valuation for variance comparison.',
    `prior_valuation_date` DATE COMMENT 'Date of the most recent prior valuation for variance comparison purposes.',
    `property_condition_rating` STRING COMMENT 'Overall physical condition rating of the property as assessed by the appraiser (excellent, good, average, fair, or poor).. Valid values are `excellent|good|average|fair|poor`',
    `stabilized_occupancy_rate` DECIMAL(5,4) COMMENT 'Stabilized occupancy rate assumption used in the valuation, expressed as a decimal (e.g., 0.9500 for 95.00%).',
    `terminal_cap_rate` DECIMAL(5,4) COMMENT 'Terminal capitalization rate applied to calculate the reversion value at the end of the DCF projection period, expressed as a decimal.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this valuation record was last modified in the system.',
    `valuation_basis` STRING COMMENT 'The basis of value applied in the valuation (market value, fair value, investment value, liquidation value, or insurance replacement value).. Valid values are `market_value|fair_value|investment_value|liquidation_value|insurance_value`',
    `valuation_confidence_level` STRING COMMENT 'Appraisers confidence level in the valuation conclusion based on data availability and market conditions (high, medium, or low).. Valid values are `high|medium|low`',
    `valuation_currency` STRING COMMENT 'Three-letter ISO 4217 currency code in which the valuation amounts are denominated.. Valid values are `^[A-Z]{3}$`',
    `valuation_date` DATE COMMENT 'The as-of date for which the property valuation was performed.',
    `valuation_methodology` STRING COMMENT 'Primary valuation methodology applied (income approach, sales comparison approach, cost approach, discounted cash flow, residual method, or hybrid combination).. Valid values are `income_approach|sales_comparison|cost_approach|dcf|residual_method|hybrid`',
    `valuation_notes` STRING COMMENT 'Free-text notes capturing key assumptions, qualifications, or special considerations noted in the valuation report.',
    `valuation_purpose` STRING COMMENT 'The business purpose for which the valuation was commissioned (acquisition due diligence, portfolio reporting, financial statement reporting, loan collateral, disposition, or regulatory compliance).. Valid values are `acquisition|portfolio_reporting|financial_reporting|loan_collateral|disposition|regulatory_compliance`',
    `valuation_report_date` DATE COMMENT 'Date on which the formal valuation report was issued by the appraiser.',
    `valuation_report_reference` STRING COMMENT 'External reference number or identifier assigned by the appraiser to the valuation report.',
    `valuation_status` STRING COMMENT 'Current lifecycle status of the valuation record (draft, under review, approved, final, superseded, or rejected).. Valid values are `draft|under_review|approved|final|superseded|rejected`',
    `valuation_type` STRING COMMENT 'The type or scope of valuation performed (full appraisal, desktop review, automated valuation model, broker price opinion, internal assessment, or annual revaluation).. Valid values are `full_appraisal|desktop_review|automated_valuation|broker_opinion|internal_assessment|annual_revaluation`',
    `valuation_variance_pct` DECIMAL(5,4) COMMENT 'Percentage variance between current valuation and prior valuation, expressed as a decimal (e.g., 0.0350 for 3.50% increase).',
    CONSTRAINT pk_property_valuation PRIMARY KEY(`property_valuation_id`)
) COMMENT 'Periodic valuation records for each property asset capturing appraised GAV, NAV, cap rate, discount rate, terminal cap rate, DCF-based valuation, independent appraiser details, valuation methodology (income approach, sales comparison, cost approach)';

CREATE OR REPLACE TABLE `asset_management`.`realestate`.`noi_record` (
    `noi_record_id` BIGINT COMMENT 'Unique identifier for the NOI record. Primary key.',
    `property_id` BIGINT COMMENT 'Reference to the real estate property for which this NOI is calculated.',
    `administrative_expense` DECIMAL(18,2) COMMENT 'General administrative costs including office supplies, communications, and overhead.',
    `approved_by` STRING COMMENT 'Name or identifier of the individual who approved this NOI record.',
    `approved_timestamp` TIMESTAMP COMMENT 'Date and time when this NOI record was approved.',
    `calculation_method` STRING COMMENT 'Accounting method used for NOI calculation: cash basis or accrual basis.. Valid values are `cash_basis|accrual_basis`',
    `capitalization_rate` DECIMAL(5,4) COMMENT 'Market cap rate applied to NOI for property valuation purposes, expressed as a decimal.',
    `concessions_amount` DECIMAL(18,2) COMMENT 'Rental discounts, free rent periods, or other tenant incentives reducing effective rent.',
    `created_timestamp` TIMESTAMP COMMENT 'Date and time when this NOI record was first created in the system.',
    `credit_loss` DECIMAL(18,2) COMMENT 'Revenue loss due to tenant defaults, non-payment, or bad debt write-offs.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts in this record.. Valid values are `^[A-Z]{3}$`',
    `data_source` STRING COMMENT 'System or platform from which the NOI data was sourced (e.g., property management system, accounting system).',
    `effective_gross_income` DECIMAL(18,2) COMMENT 'Gross potential rent minus vacancy and credit losses, plus other income. Total revenue before operating expenses.',
    `gross_potential_rent` DECIMAL(18,2) COMMENT 'Total rental income if the property were fully leased at market rates with no vacancies.',
    `insurance_expense` DECIMAL(18,2) COMMENT 'Property insurance premiums covering casualty, liability, and other risks.',
    `legal_professional_fees` DECIMAL(18,2) COMMENT 'Legal, accounting, consulting, and other professional service fees related to property operations.',
    `marketing_leasing_expense` DECIMAL(18,2) COMMENT 'Costs for advertising, tenant acquisition, leasing commissions, and promotional activities.',
    `modified_timestamp` TIMESTAMP COMMENT 'Date and time when this NOI record was last modified.',
    `net_operating_income` DECIMAL(18,2) COMMENT 'Effective gross income minus total operating expenses. Key metric for property performance before debt service and capital expenditures.',
    `noi_margin_percent` DECIMAL(5,2) COMMENT 'NOI as a percentage of effective gross income, indicating operational efficiency.',
    `noi_status` STRING COMMENT 'Current status of the NOI record in the reporting and approval workflow.. Valid values are `draft|preliminary|final|revised|audited`',
    `notes` STRING COMMENT 'Free-text commentary on unusual items, adjustments, or context for this NOI calculation.',
    `occupancy_rate_percent` DECIMAL(5,2) COMMENT 'Percentage of leasable space occupied during the reporting period.',
    `other_income` DECIMAL(18,2) COMMENT 'Non-rental income such as parking fees, laundry, storage, antenna leases, or service charges.',
    `other_operating_expenses` DECIMAL(18,2) COMMENT 'Miscellaneous operating expenses not classified in other categories.',
    `payroll_expense` DECIMAL(18,2) COMMENT 'Salaries, wages, and benefits for on-site staff including leasing agents, maintenance, and security.',
    `property_management_fee` DECIMAL(18,2) COMMENT 'Fees paid to third-party or internal property management for day-to-day operations.',
    `property_taxes` DECIMAL(18,2) COMMENT 'Real estate taxes levied by local government authorities on the property.',
    `repairs_maintenance_expense` DECIMAL(18,2) COMMENT 'Routine maintenance, repairs, and upkeep costs to maintain property condition.',
    `reporting_frequency` STRING COMMENT 'Frequency at which NOI is calculated and reported for this property.. Valid values are `monthly|quarterly|annual`',
    `reporting_period_end_date` DATE COMMENT 'End date of the period for which NOI is calculated.',
    `reporting_period_start_date` DATE COMMENT 'Start date of the period for which NOI is calculated (monthly, quarterly, or annual).',
    `total_operating_expenses` DECIMAL(18,2) COMMENT 'Sum of all operating expenses incurred to maintain and operate the property.',
    `utilities_expense` DECIMAL(18,2) COMMENT 'Costs for electricity, water, gas, sewer, and other utilities not recovered from tenants.',
    `vacancy_loss` DECIMAL(18,2) COMMENT 'Revenue loss due to unoccupied units or spaces during the reporting period.',
    `valuation_date` DATE COMMENT 'Date on which the property was valued, used for NAV and GAV calculations referencing this NOI.',
    CONSTRAINT pk_noi_record PRIMARY KEY(`noi_record_id`)
) COMMENT 'Net Operating Income (NOI) records calculated at the property level on a periodic basis (monthly, quarterly, annual). Captures gross potential rent, effective gross income, vacancy and credit loss, operating expenses (property taxes, insurance';

CREATE OR REPLACE TABLE `asset_management`.`realestate`.`lease` (
    `lease_id` BIGINT COMMENT 'Unique identifier for the lease agreement record.',
    `actor_id` BIGINT COMMENT 'Reference to the party providing financial guarantee or credit support for tenant lease obligations.',
    `lease_employee_id` BIGINT COMMENT 'Reference to the party providing financial guarantee or credit support for tenant lease obligations.',
    `lease_property_manager_employee_id` BIGINT COMMENT 'Reference to the internal employee or external party responsible for managing this lease relationship and property operations.',
    `property_id` BIGINT COMMENT 'Reference to the real estate property asset where the leased premises are located.',
    `property_manager_actor_id` BIGINT COMMENT 'Reference to the internal employee or external party responsible for managing this lease relationship and property operations.',
    `tenant_id` BIGINT COMMENT 'Reference to the tenant party occupying the leased premises.',
    `assignment_sublease_rights` STRING COMMENT 'Tenant rights to assign the lease or sublease the premises to third parties (prohibited, permitted with landlord consent, or freely assignable).. Valid values are `prohibited|permitted-with-consent|freely-assignable`',
    `base_rent_amount` DECIMAL(15,2) COMMENT 'Initial base rent amount payable by tenant per payment period, excluding escalations, operating expenses, and additional charges.',
    `commencement_date` DATE COMMENT 'Date when the lease term begins and tenant occupancy rights commence.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this lease record was first created in the data platform.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts in the lease agreement.. Valid values are `^[A-Z]{3}$`',
    `document_uri` STRING COMMENT 'Storage location or document management system reference for the executed lease agreement and related legal documents.',
    `escalation_frequency_months` BIGINT COMMENT 'Number of months between rent escalation events (e.g., 12 for annual escalations, 24 for biennial).',
    `escalation_rate` DECIMAL(5,4) COMMENT 'Annual percentage or fixed amount by which base rent increases, expressed as a decimal (e.g., 0.0300 for 3 percent annual increase).',
    `escalation_type` STRING COMMENT 'Method by which base rent increases over the lease term (fixed amount, CPI-indexed, percentage increase, or none).. Valid values are `fixed|cpi|percentage|none`',
    `exclusivity_clause` STRING COMMENT 'Contractual provision granting tenant exclusive rights to conduct specific business activities within the property, preventing landlord from leasing to competing tenants.',
    `execution_date` DATE COMMENT 'Date when the lease agreement was signed by all parties and became legally binding.',
    `expiry_date` DATE COMMENT 'Date when the lease term ends and tenant occupancy rights expire, unless renewed or extended.',
    `floor_number` STRING COMMENT 'Floor number or level identifier where the leased premises are located within the property.',
    `free_rent_months` BIGINT COMMENT 'Number of months at lease commencement during which tenant is not required to pay base rent, used as a lease incentive.',
    `gla_square_feet` DECIMAL(12,2) COMMENT 'Total floor area of the leased premises measured in square feet, representing the space available for tenant use and the basis for rent calculations.',
    `lease_status` STRING COMMENT 'Current state of the lease agreement in its lifecycle (draft, active, expired, terminated, renewed, holdover).. Valid values are `draft|active|expired|terminated|renewed|holdover`',
    `lease_type` STRING COMMENT 'Classification of lease structure defining tenant and landlord expense responsibilities (gross, net, triple-net, modified gross, percentage, ground).. Valid values are `gross|net|triple-net|modified-gross|percentage|ground`',
    `notes` STRING COMMENT 'Free-form text field for additional lease terms, special conditions, amendments, or operational notes not captured in structured fields.',
    `number` STRING COMMENT 'Externally-known unique business identifier for the lease agreement, used in legal documents and tenant communications.',
    `operating_expense_recovery_type` STRING COMMENT 'Method by which landlord recovers property operating expenses from tenant (base-year, expense-stop, pro-rata share, or none for gross leases).. Valid values are `base-year|expense-stop|pro-rata|none`',
    `parking_rent_amount` DECIMAL(12,2) COMMENT 'Additional monthly or annual rent charged for tenant parking spaces, separate from base rent.',
    `parking_spaces_count` BIGINT COMMENT 'Number of parking spaces allocated to tenant as part of the lease agreement.',
    `percentage_rent_breakpoint` DECIMAL(15,2) COMMENT 'Annual sales revenue threshold above which percentage rent becomes payable by tenant.',
    `percentage_rent_flag` BOOLEAN COMMENT 'Indicates whether lease includes percentage rent provisions based on tenant sales revenue, common in retail leases.',
    `percentage_rent_rate` DECIMAL(5,4) COMMENT 'Percentage of tenant gross sales revenue payable as additional rent above base rent, expressed as decimal (e.g., 0.0500 for 5 percent).',
    `possession_date` DATE COMMENT 'Date when tenant takes physical possession of the leased premises, which may differ from commencement date for build-out periods.',
    `renewal_notice_days` BIGINT COMMENT 'Number of days prior to lease expiry by which tenant must notify landlord of intent to exercise renewal option.',
    `renewal_option_count` BIGINT COMMENT 'Number of renewal option periods available to the tenant beyond the initial lease term.',
    `renewal_option_term_months` BIGINT COMMENT 'Duration in months of each renewal option period if tenant exercises the renewal right.',
    `rent_commencement_date` DATE COMMENT 'Date when tenant rent payment obligations begin, which may differ from lease commencement if free rent period is granted.',
    `rent_payment_frequency` STRING COMMENT 'Frequency at which rent payments are due from the tenant (monthly, quarterly, annually, semi-annually).. Valid values are `monthly|quarterly|annually|semi-annually`',
    `rent_per_square_foot` DECIMAL(10,2) COMMENT 'Base rent amount expressed as a rate per square foot of GLA, used for market comparison and valuation analysis.',
    `security_deposit_amount` DECIMAL(15,2) COMMENT 'Refundable deposit amount held by landlord as security against tenant default or property damage.',
    `suite_number` STRING COMMENT 'Suite or unit number identifier for the specific leased premises within the property.',
    `tenant_improvement_allowance` DECIMAL(15,2) COMMENT 'Dollar amount provided by landlord to tenant for build-out and customization of leased premises.',
    `term_months` BIGINT COMMENT 'Total duration of the lease agreement expressed in months from commencement to expiry.',
    `termination_notice_days` BIGINT COMMENT 'Number of days advance notice tenant must provide to landlord to exercise early termination right.',
    `termination_option_flag` BOOLEAN COMMENT 'Indicates whether tenant has the contractual right to terminate the lease prior to expiry date.',
    `termination_penalty_amount` DECIMAL(15,2) COMMENT 'Financial penalty or fee payable by tenant to landlord upon early termination of the lease.',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp when this lease record was last modified in the data platform.',
    `use_clause` STRING COMMENT 'Contractual description of permitted business activities and uses for the leased premises, restricting tenant operations to specified purposes.',
    CONSTRAINT pk_lease PRIMARY KEY(`lease_id`)
) COMMENT 'Master record for each tenant lease agreement at a property, capturing tenant identity, leased premises (suite, floor, GLA), lease commencement and expiry dates, lease type (gross, net, triple-net, modified gross), base rent, rent escalation schedule';

CREATE OR REPLACE TABLE `asset_management`.`realestate`.`lease_rent_schedule` (
    `lease_rent_schedule_id` BIGINT COMMENT 'Unique identifier for the lease rent schedule record. Primary key.',
    `lease_id` BIGINT COMMENT 'Reference to the parent lease agreement for which this rent schedule applies.',
    `property_id` BIGINT COMMENT 'Reference to the real estate property asset associated with this rent schedule.',
    `abatement_amount` DECIMAL(18,2) COMMENT 'The rent amount waived or reduced during this period as a lease concession.',
    `accounting_period` STRING COMMENT 'The financial reporting period to which this rent schedule entry is allocated, in YYYY-MM format.. Valid values are `^d{4}-d{2}$`',
    `actual_payment_amount` DECIMAL(18,2) COMMENT 'The actual rent amount received for this period, which may differ from scheduled amount due to adjustments or disputes.',
    `actual_payment_date` DATE COMMENT 'The date on which the rent payment for this period was actually received.',
    `base_rent_amount` DECIMAL(18,2) COMMENT 'The contractual base rent amount for this period before any adjustments or escalations.',
    `cpi_adjusted_amount` DECIMAL(18,2) COMMENT 'The additional rent amount resulting from CPI indexation for this period.',
    `cpi_adjustment_factor` DECIMAL(10,6) COMMENT 'The inflation adjustment multiplier applied to base rent based on CPI movement for this period.',
    `created_timestamp` TIMESTAMP COMMENT 'The date and time when this rent schedule record was first created in the system.',
    `cumulative_rent_to_date` DECIMAL(18,2) COMMENT 'The sum of all rent amounts from lease commencement through the end of this period.',
    `effective_rent_per_sqft` DECIMAL(12,4) COMMENT 'The total rent amount divided by leased square footage, representing the effective rate for this period.',
    `escalation_amount` DECIMAL(18,2) COMMENT 'The incremental rent increase applied in this period due to contractual step-up provisions.',
    `escalation_rate` DECIMAL(6,4) COMMENT 'The percentage rate applied for fixed escalation calculations in this period, expressed as a decimal.',
    `escalation_type` STRING COMMENT 'The method by which rent increases are calculated for this period.. Valid values are `fixed|cpi|percentage|hybrid|none`',
    `free_rent_flag` BOOLEAN COMMENT 'Indicates whether this period is a rent abatement or free rent period per lease concessions.',
    `lease_modification_flag` BOOLEAN COMMENT 'Indicates whether this rent schedule entry was affected by a lease amendment or modification.',
    `modification_effective_date` DATE COMMENT 'The date on which a lease modification affecting this rent period became effective.',
    `noi_contribution` DECIMAL(18,2) COMMENT 'The net operating income contribution from this rent period after deducting direct property expenses.',
    `notes` STRING COMMENT 'Additional commentary or context regarding this rent schedule period, such as special adjustments or tenant negotiations.',
    `operating_expense_recovery` DECIMAL(18,2) COMMENT 'Tenant reimbursement for property operating expenses allocated to this rent period.',
    `other_charges_amount` DECIMAL(18,2) COMMENT 'Additional charges such as parking, utilities, or amenity fees for this period.',
    `payment_due_date` DATE COMMENT 'The contractual date by which the rent payment for this period must be received.',
    `payment_frequency` STRING COMMENT 'The contractual frequency at which rent payments are due for this schedule.. Valid values are `monthly|quarterly|semi-annually|annually`',
    `payment_status` STRING COMMENT 'The current status of the rent payment for this period.. Valid values are `scheduled|paid|overdue|waived|disputed|partial`',
    `percentage_rent_amount` DECIMAL(18,2) COMMENT 'Variable rent based on tenant revenue or property performance metrics for this period.',
    `period_end_date` DATE COMMENT 'The last date of the rent payment period covered by this schedule entry.',
    `period_sequence_number` BIGINT COMMENT 'Sequential ordering of the rent period within the lease term, starting from 1.',
    `period_start_date` DATE COMMENT 'The first date of the rent payment period covered by this schedule entry.',
    `rent_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all rent amounts in this schedule entry.. Valid values are `^[A-Z]{3}$`',
    `rent_type` STRING COMMENT 'The lease structure type defining which expenses are included in or excluded from base rent.. Valid values are `gross|net|modified_gross|triple_net`',
    `straight_line_rent_amount` DECIMAL(18,2) COMMENT 'The average rent amount per period calculated on a straight-line basis over the lease term for accounting purposes.',
    `tax_recovery_amount` DECIMAL(18,2) COMMENT 'Tenant reimbursement for property taxes allocated to this rent period.',
    `total_rent_amount` DECIMAL(18,2) COMMENT 'The aggregate rent amount for this period including base rent, escalations, adjustments, and recoveries.',
    `updated_timestamp` TIMESTAMP COMMENT 'The date and time when this rent schedule record was last modified.',
    `variance_amount` DECIMAL(18,2) COMMENT 'The difference between scheduled total rent and actual payment received for this period.',
    CONSTRAINT pk_lease_rent_schedule PRIMARY KEY(`lease_rent_schedule_id`)
) COMMENT 'Detailed rent schedule for each lease, capturing all contractual rent payment periods, scheduled base rent amounts, rent step-up dates, CPI adjustment factors, effective rent per period, and cumulative rent to lease expiry.';

CREATE OR REPLACE TABLE `asset_management`.`realestate`.`rent_collection` (
    `rent_collection_id` BIGINT COMMENT 'Unique identifier for the rent collection transaction record.',
    `actor_id` BIGINT COMMENT 'Identifier of the internal or external agent responsible for managing this rent collection.',
    `cash_account_id` BIGINT COMMENT 'Identifier of the bank account into which the rent payment was deposited.',
    `employee_id` BIGINT COMMENT 'Identifier of the internal or external agent responsible for managing this rent collection.',
    `lease_id` BIGINT COMMENT 'Identifier of the lease agreement under which this rent collection occurs.',
    `property_id` BIGINT COMMENT 'Identifier of the real estate property from which rent is collected.',
    `tenant_id` BIGINT COMMENT 'Identifier of the tenant responsible for the rent payment.',
    `adjustment_amount` DECIMAL(18,2) COMMENT 'Manual adjustment applied to the rent collection for reconciliation or correction purposes.',
    `arrears_balance` DECIMAL(18,2) COMMENT 'Outstanding unpaid rent balance owed by the tenant as of the collection date.',
    `billing_period_end_date` DATE COMMENT 'End date of the rental period covered by this collection transaction.',
    `billing_period_start_date` DATE COMMENT 'Start date of the rental period covered by this collection transaction.',
    `collection_notes` STRING COMMENT 'Free-text notes or comments regarding the rent collection transaction, disputes, or follow-up actions.',
    `collection_status` STRING COMMENT 'Current status of the rent collection transaction in the receivables lifecycle.. Valid values are `paid_full|paid_partial|unpaid|overdue|disputed|written_off`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the rent collection record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the rent collection transaction.. Valid values are `^[A-Z]{3}$`',
    `days_overdue` BIGINT COMMENT 'Number of days the rent payment is overdue past the due date.',
    `discount_amount` DECIMAL(18,2) COMMENT 'Discount or concession applied to the invoiced rent amount.',
    `dispute_flag` BOOLEAN COMMENT 'Indicates whether the tenant has disputed the invoiced rent amount or payment terms.',
    `dispute_reason` STRING COMMENT 'Description of the reason provided by the tenant for disputing the rent collection.',
    `due_date` DATE COMMENT 'Date by which the rent payment is contractually due from the tenant.',
    `gl_account_code` STRING COMMENT 'General ledger account code to which this rent collection is posted for financial reporting.',
    `invoice_date` DATE COMMENT 'Date on which the rent invoice was issued to the tenant.',
    `invoice_number` STRING COMMENT 'Unique invoice reference number issued to the tenant for rent due.',
    `invoiced_amount` DECIMAL(18,2) COMMENT 'Total rent amount invoiced to the tenant for the billing period.',
    `late_fee_amount` DECIMAL(18,2) COMMENT 'Additional late payment fee charged to the tenant for overdue rent.',
    `net_amount_due` DECIMAL(18,2) COMMENT 'Net rent amount due after applying discounts, late fees, and adjustments.',
    `noi_contribution` DECIMAL(18,2) COMMENT 'Contribution of this rent collection to the property-level Net Operating Income calculation.',
    `payment_channel` STRING COMMENT 'Channel or interface through which the tenant submitted the rent payment.. Valid values are `online_portal|mail|in_person|automated_clearing|lockbox`',
    `payment_method` STRING COMMENT 'Method or instrument used by the tenant to remit the rent payment.. Valid values are `wire_transfer|ach|check|direct_debit|credit_card|cash`',
    `payment_received_date` DATE COMMENT 'Actual date on which the rent payment was received from the tenant.',
    `payment_reference` STRING COMMENT 'External reference number or transaction identifier provided by the tenant or payment processor.',
    `received_amount` DECIMAL(18,2) COMMENT 'Actual amount of rent payment received from the tenant.',
    `reconciliation_date` DATE COMMENT 'Date on which the rent collection was reconciled against bank statements and ledger entries.',
    `reconciliation_status` STRING COMMENT 'Status of the rent collection transaction in the cash reconciliation process.. Valid values are `pending|reconciled|exception|under_review`',
    `tax_amount` DECIMAL(18,2) COMMENT 'Tax component included in the rent collection transaction, if applicable.',
    `tax_jurisdiction` STRING COMMENT 'Tax jurisdiction or authority under which the rent collection tax is calculated and remitted.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the rent collection record was last modified in the system.',
    `write_off_date` DATE COMMENT 'Date on which the uncollected rent was written off from accounts receivable.',
    `write_off_flag` BOOLEAN COMMENT 'Indicates whether the uncollected rent has been written off as uncollectible.',
    `write_off_reason` STRING COMMENT 'Business justification or reason for writing off the uncollected rent amount.',
    CONSTRAINT pk_rent_collection PRIMARY KEY(`rent_collection_id`)
) COMMENT 'Transactional records of actual rent receipts collected from tenants against scheduled lease obligations. Captures invoice date, due date, payment received date, invoiced amount, received amount, arrears balance, payment method, and collection status';

CREATE OR REPLACE TABLE `asset_management`.`realestate`.`tenant` (
    `tenant_id` BIGINT COMMENT 'Unique identifier for the tenant occupying space in the real estate portfolio.',
    `aml_screening_date` DATE COMMENT 'The date of the most recent AML screening performed on the tenant.',
    `aml_status` STRING COMMENT 'The current Anti-Money Laundering screening status of the tenant.. Valid values are `cleared|flagged|under_review|blocked`',
    `anchor_tenant_flag` BOOLEAN COMMENT 'Boolean indicator of whether the tenant is classified as an anchor tenant, typically occupying significant space and driving property value.',
    `annual_revenue_amount` DECIMAL(18,2) COMMENT 'The most recent annual revenue of the tenant entity in the reporting currency, used for creditworthiness assessment.',
    `annual_revenue_currency` STRING COMMENT 'The ISO 4217 three-letter currency code for the annual revenue amount.. Valid values are `^[A-Z]{3}$`',
    `business_registration_number` STRING COMMENT 'The official registration or incorporation number assigned by the jurisdiction of incorporation.',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this tenant record was first created in the system.',
    `credit_rating` STRING COMMENT 'The external credit rating assigned to the tenant by a recognized rating agency, used for tenant credit risk assessment. [ENUM-REF-CANDIDATE: AAA|AA|A|BBB|BB|B|CCC|CC|C|D|NR — 11 candidates stripped; promote to reference product]',
    `credit_rating_agency` STRING COMMENT 'The rating agency that issued the credit rating for the tenant.. Valid values are `S&P|Moodys|Fitch|DBRS|NR`',
    `credit_rating_date` DATE COMMENT 'The date on which the current credit rating was assigned or last affirmed.',
    `employee_count` BIGINT COMMENT 'The approximate number of employees of the tenant entity, used for business scale assessment.',
    `esg_rating` STRING COMMENT 'The ESG rating assigned to the tenant by a recognized ESG rating provider, used for responsible investment screening. [ENUM-REF-CANDIDATE: AAA|AA|A|BBB|BB|B|CCC|NR — 8 candidates stripped; promote to reference product]',
    `esg_rating_date` DATE COMMENT 'The date on which the current ESG rating was assigned or last updated.',
    `esg_rating_provider` STRING COMMENT 'The name of the ESG rating agency that provided the ESG rating for the tenant.',
    `headquarters_address_line1` STRING COMMENT 'The first line of the tenants corporate headquarters street address.',
    `headquarters_city` STRING COMMENT 'The city in which the tenants corporate headquarters is located.',
    `headquarters_country_code` STRING COMMENT 'The ISO 3166-1 alpha-3 country code for the tenants corporate headquarters location.. Valid values are `^[A-Z]{3}$`',
    `headquarters_postal_code` STRING COMMENT 'The postal or ZIP code of the tenants corporate headquarters address.',
    `headquarters_state_province` STRING COMMENT 'The state or province in which the tenants corporate headquarters is located.',
    `incorporation_country_code` STRING COMMENT 'The ISO 3166-1 alpha-3 country code where the tenant entity is legally incorporated.. Valid values are `^[A-Z]{3}$`',
    `industry_sector_code` STRING COMMENT 'The GICS industry sector code classifying the tenants primary business activity for concentration risk analysis.. Valid values are `^[0-9]{2,8}$`',
    `industry_sector_name` STRING COMMENT 'The human-readable name of the GICS industry sector in which the tenant operates.',
    `kyc_completion_date` DATE COMMENT 'The date on which the most recent KYC review was completed and approved.',
    `kyc_expiry_date` DATE COMMENT 'The date on which the current KYC approval expires and requires renewal.',
    `kyc_status` STRING COMMENT 'The current status of the Know Your Customer due diligence process for the tenant.. Valid values are `approved|pending|expired|rejected|not_required`',
    `legal_name` STRING COMMENT 'The full legal registered name of the tenant entity as recorded in corporate registry.',
    `lei` STRING COMMENT 'The 20-character ISO 17442 Legal Entity Identifier for the tenant, enabling global counterparty identification.. Valid values are `^[A-Z0-9]{20}$`',
    `notes` STRING COMMENT 'Free-form text field for capturing additional notes, special considerations, or historical context about the tenant.',
    `number_of_leases` BIGINT COMMENT 'The total count of active lease agreements held by this tenant across the portfolio.',
    `onboarding_date` DATE COMMENT 'The date on which the tenant was first onboarded into the real estate portfolio management system.',
    `parent_entity_lei` STRING COMMENT 'The LEI of the parent entity for consolidated credit and concentration risk monitoring.. Valid values are `^[A-Z0-9]{20}$`',
    `parent_entity_name` STRING COMMENT 'The name of the parent or ultimate beneficial owner entity if the tenant is a subsidiary, used for group exposure analysis.',
    `primary_contact_email` STRING COMMENT 'The email address of the primary tenant contact for operational communications.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `primary_contact_name` STRING COMMENT 'The name of the primary business contact person for lease administration and tenant relations.',
    `primary_contact_phone` STRING COMMENT 'The telephone number of the primary tenant contact for urgent lease matters.',
    `public_company_flag` BOOLEAN COMMENT 'Boolean indicator of whether the tenant is a publicly traded company with securities listed on a recognized exchange.',
    `relationship_manager_name` STRING COMMENT 'The name of the internal relationship manager responsible for managing the tenant relationship and lease administration.',
    `stock_exchange_code` STRING COMMENT 'The ISO 10383 Market Identifier Code for the primary stock exchange where the tenant is listed.. Valid values are `^[A-Z]{4}$`',
    `stock_ticker_symbol` STRING COMMENT 'The stock exchange ticker symbol for the tenant if publicly traded, enabling market data linkage.',
    `tax_identification_number` STRING COMMENT 'The tax identification number assigned to the tenant by the relevant tax authority for reporting and compliance.',
    `tenant_status` STRING COMMENT 'The current operational and financial status of the tenant relationship.. Valid values are `active|inactive|default|bankruptcy|terminated`',
    `tenant_type` STRING COMMENT 'Classification of tenant by strategic importance and lease characteristics within the portfolio.. Valid values are `anchor|major|standard|short_term|government|non_profit`',
    `total_leased_gla_sqft` DECIMAL(18,2) COMMENT 'The total gross leasable area in square feet currently leased by this tenant across all properties in the portfolio.',
    `trading_name` STRING COMMENT 'The commercial or trading name under which the tenant operates, if different from legal name.',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this tenant record was last modified in the system.',
    CONSTRAINT pk_tenant PRIMARY KEY(`tenant_id`)
) COMMENT 'Master record for each tenant occupying space across the real estate portfolio. Captures tenant legal name, trading name, industry sector (GICS classification), credit rating, LEI, KYC/AML status, parent entity, number of leases, total leased GLA, anchor';

CREATE OR REPLACE TABLE `asset_management`.`realestate`.`realestate_capex_program` (
    `realestate_capex_program_id` BIGINT COMMENT 'Unique identifier for the capital expenditure program record.',
    `actor_id` BIGINT COMMENT 'Reference to the asset manager or asset management team responsible for overseeing the property and its value creation initiatives.',
    `cash_account_id` BIGINT COMMENT 'Foreign key linking to treasury.cash_account. Business justification: Capex program funding originates from a cash account; the link supports budgeting, funding approvals, and cash flow forecasting.',
    `contractor_id` BIGINT COMMENT 'Reference to the contractor or vendor entity responsible for executing the capital expenditure program.',
    `employee_id` BIGINT COMMENT 'Reference to the asset manager or asset management team responsible for overseeing the property and its value creation initiatives.',
    `property_id` BIGINT COMMENT 'Reference to the property asset where the capital expenditure program is being executed.',
    `actual_completion_date` DATE COMMENT 'Actual date when all capital expenditure program activities were completed and the program was closed.',
    `actual_spend_amount` DECIMAL(18,2) COMMENT 'Total capital expenditure actually incurred and paid as of the reporting date, representing cash outflows or accrued liabilities.',
    `actual_start_date` DATE COMMENT 'Actual date when capital expenditure program activities commenced, used for schedule variance analysis.',
    `approval_authority` STRING COMMENT 'Name or identifier of the governance body or individual who approved the capital expenditure program.',
    `approval_date` DATE COMMENT 'Date when the capital expenditure program and its budget were formally approved by the Investment Committee (IC) or delegated authority.',
    `approved_budget_amount` DECIMAL(18,2) COMMENT 'Total capital expenditure budget amount approved by the Investment Committee (IC) or delegated authority for the program.',
    `budget_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the approved budget and all financial amounts in the program.. Valid values are `^[A-Z]{3}$`',
    `business_case_reference` STRING COMMENT 'Reference identifier or document number for the Investment Memorandum (IM) or business case supporting the capital expenditure program.',
    `committed_spend_amount` DECIMAL(18,2) COMMENT 'Total amount of capital expenditure committed through contracts, purchase orders, and binding agreements as of the reporting date.',
    `completion_percentage` DECIMAL(5,2) COMMENT 'Current percentage of program completion based on milestones achieved, work completed, or budget spent.',
    `contingency_amount` DECIMAL(18,2) COMMENT 'Budget contingency or reserve amount set aside to cover unforeseen costs, scope changes, or risk events during program execution.',
    `contingency_percentage` DECIMAL(5,2) COMMENT 'Contingency amount expressed as a percentage of the approved budget, indicating the risk buffer allocated.',
    `contractor_name` STRING COMMENT 'Name of the primary contractor or construction firm engaged to execute the capital expenditure program.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the capital expenditure program record was first created in the system.',
    `realestate_capex_program_description` STRING COMMENT 'Detailed narrative description of the capital expenditure program scope, objectives, and key activities.',
    `energy_efficiency_improvement_percentage` DECIMAL(5,2) COMMENT 'Expected percentage improvement in energy efficiency or reduction in energy consumption resulting from the capital expenditure program.',
    `esg_impact_category` STRING COMMENT 'Classification of the Environmental, Social, and Governance (ESG) impact or benefit delivered by the capital expenditure program.',
    `expected_irr_percentage` DECIMAL(5,2) COMMENT 'Projected Internal Rate of Return (IRR) for the capital expenditure program, used to evaluate value creation and investment efficiency.',
    `expected_nav_increase_amount` DECIMAL(18,2) COMMENT 'Projected increase in property Net Asset Value (NAV) or Gross Asset Value (GAV) resulting from the capital expenditure program.',
    `expected_noi_increase_amount` DECIMAL(18,2) COMMENT 'Projected annual increase in Net Operating Income (NOI) resulting from the capital expenditure program upon completion.',
    `forecast_completion_date` DATE COMMENT 'Latest forecast date for program completion based on current progress and known delays or accelerations.',
    `forecast_total_cost_amount` DECIMAL(18,2) COMMENT 'Latest forecast of the total capital expenditure cost at completion, including all approved changes and anticipated overruns.',
    `funding_source` STRING COMMENT 'Source of capital funding for the expenditure program, such as equity, debt, joint venture contribution, or asset-level cash flow.',
    `ghg_reduction_target_tonnes` DECIMAL(12,2) COMMENT 'Target reduction in annual Greenhouse Gas (GHG) emissions measured in tonnes of carbon dioxide equivalent resulting from the program.',
    `ic_approval_reference` STRING COMMENT 'Reference number or identifier for the Investment Committee (IC) decision or resolution approving the capital expenditure program.',
    `last_status_update_date` DATE COMMENT 'Date when the program status, forecast, or financial data was last updated in the system.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when the capital expenditure program record was last modified or updated in the system.',
    `planned_completion_date` DATE COMMENT 'Scheduled date for the completion of all capital expenditure program activities as per the original project plan.',
    `planned_start_date` DATE COMMENT 'Scheduled date for the commencement of capital expenditure program activities as per the original project plan.',
    `program_code` STRING COMMENT 'Unique business identifier or code assigned to the capital expenditure program for tracking and reference.',
    `program_manager_name` STRING COMMENT 'Name of the individual responsible for managing and delivering the capital expenditure program.',
    `program_name` STRING COMMENT 'Business name or title of the capital expenditure program for identification and reporting purposes.',
    `program_status` STRING COMMENT 'Current lifecycle status of the capital expenditure program indicating its execution stage.. Valid values are `planned|approved|in_progress|on_hold|completed|cancelled`',
    `program_type` STRING COMMENT 'Classification of the capital expenditure program by its strategic purpose and scope.. Valid values are `repositioning|refurbishment|development|esg_retrofit|tenant_improvement|infrastructure_upgrade`',
    `risk_rating` STRING COMMENT 'Overall risk assessment for the capital expenditure program considering execution, cost, schedule, and market risks.. Valid values are `low|medium|high|critical`',
    `strategic_objective` STRING COMMENT 'High-level business objective or value creation goal that the capital expenditure program is designed to achieve.',
    `variance_amount` DECIMAL(18,2) COMMENT 'Difference between the approved budget and the forecast total cost, indicating budget overrun or underrun.',
    `variance_percentage` DECIMAL(5,2) COMMENT 'Variance amount expressed as a percentage of the approved budget, used for performance monitoring and escalation triggers.',
    CONSTRAINT pk_realestate_capex_program PRIMARY KEY(`realestate_capex_program_id`)
) COMMENT 'Capital expenditure program records for post-acquisition value creation initiatives at the property level. Captures program name, type (repositioning, refurbishment, development, ESG retrofit, tenant improvement), approved budget, committed spend, actual';

CREATE OR REPLACE TABLE `asset_management`.`realestate`.`capex_expenditure` (
    `capex_expenditure_id` BIGINT COMMENT 'Unique identifier for the capital expenditure transaction record.',
    `approver_employee_id` BIGINT COMMENT 'Reference to the employee or user entity who approved this expenditure.',
    `budget_line_item_id` BIGINT COMMENT 'Reference to the specific budget line item within the capital expenditure program budget against which this expenditure is tracked.',
    `cash_account_id` BIGINT COMMENT 'Foreign key linking to treasury.cash_account. Business justification: Capex expenditure payments are made from a cash account; linking enables expense tracking and reconciliation with treasury cash balances.',
    `contract_id` BIGINT COMMENT 'Reference to the vendor contract or service agreement under which this expenditure is authorized.',
    `employee_id` BIGINT COMMENT 'Reference to the employee or user entity who approved this expenditure.',
    `property_id` BIGINT COMMENT 'Reference to the real estate property asset where the capital expenditure is being deployed.',
    `realestate_capex_program_id` BIGINT COMMENT 'Reference to the approved capital expenditure program under which this expenditure is authorized.',
    `vendor_id` BIGINT COMMENT 'Reference to the vendor or contractor entity in the vendor master data.',
    `approval_date` DATE COMMENT 'Date on which the expenditure was approved by the authorized approver or investment committee.',
    `approved_amount` DECIMAL(18,2) COMMENT 'Amount approved for payment after review and validation, which may differ from the invoiced amount due to adjustments or disputes.',
    `approver_name` STRING COMMENT 'Name of the individual or committee that approved this capital expenditure transaction.',
    `asset_class` STRING COMMENT 'Fixed asset class or category to which this capitalized expenditure will be assigned (e.g., building improvements, tenant improvements, equipment).',
    `capitalization_flag` BOOLEAN COMMENT 'Indicates whether this expenditure qualifies for capitalization as a fixed asset addition under accounting standards (True) or should be expensed (False).',
    `cost_center_code` STRING COMMENT 'Cost center or business unit code responsible for this capital expenditure.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this expenditure record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code in which the expenditure amounts are denominated.. Valid values are `^[A-Z]{3}$`',
    `depreciation_method` STRING COMMENT 'Depreciation method to be applied to the capitalized expenditure: straight-line, declining balance, units of production, or other.. Valid values are `straight_line|declining_balance|units_of_production|other`',
    `capex_expenditure_description` STRING COMMENT 'Detailed narrative description of the work performed, materials purchased, or services rendered for this capital expenditure.',
    `expenditure_category` STRING COMMENT 'Classification of the capital expenditure by cost type: hard costs (construction, materials), soft costs (design, engineering), furniture fixtures and equipment, contingency reserves, professional fees, or permits and regulatory fees.. Valid values are `hard_costs|soft_costs|ffe|contingency|professional_fees|permits_fees`',
    `expenditure_date` DATE COMMENT 'The date on which the capital expenditure transaction occurred or was incurred.',
    `expenditure_reference_number` STRING COMMENT 'Business identifier for the expenditure transaction, typically a work order number, invoice number, or payment reference.',
    `expenditure_status` STRING COMMENT 'Current lifecycle status of the expenditure transaction within the approval and payment workflow.. Valid values are `pending|approved|paid|reconciled|disputed|cancelled`',
    `gl_account_code` STRING COMMENT 'General ledger account code to which this capital expenditure is posted for financial reporting.',
    `invoice_date` DATE COMMENT 'Date on which the vendor invoice was issued.',
    `invoice_number` STRING COMMENT 'Vendor invoice number associated with this expenditure transaction.',
    `invoiced_amount` DECIMAL(18,2) COMMENT 'Total amount invoiced by the vendor for this expenditure, in the transaction currency.',
    `milestone_reference` STRING COMMENT 'Reference to the project milestone or phase associated with this expenditure, used for progress tracking and payment scheduling.',
    `modified_by` STRING COMMENT 'User or system identifier of the individual who last modified this expenditure record.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this expenditure record was last modified or updated.',
    `notes` STRING COMMENT 'Additional notes, comments, or special instructions related to this capital expenditure transaction.',
    `paid_amount` DECIMAL(18,2) COMMENT 'Actual amount paid to the vendor for this expenditure transaction.',
    `payment_date` DATE COMMENT 'Date on which payment was made to the vendor for this expenditure.',
    `payment_method` STRING COMMENT 'Method used to remit payment to the vendor: wire transfer, check, automated clearing house, credit card, or other.. Valid values are `wire_transfer|check|ach|credit_card|other`',
    `payment_reference` STRING COMMENT 'Payment transaction reference number or confirmation code from the treasury or accounts payable system.',
    `project_code` STRING COMMENT 'Project or capital program code under which this expenditure is tracked for budgeting and reporting purposes.',
    `purchase_order_number` STRING COMMENT 'Purchase order number issued to the vendor authorizing the work or procurement associated with this expenditure.',
    `reconciliation_date` DATE COMMENT 'Date on which the expenditure was reconciled and confirmed as accurate in the accounting records.',
    `reconciliation_status` STRING COMMENT 'Status of the reconciliation process between the expenditure record, vendor invoice, and payment confirmation.. Valid values are `pending|reconciled|discrepancy|under_review`',
    `retainage_amount` DECIMAL(18,2) COMMENT 'Amount withheld from payment as retainage per contract terms, to be released upon project completion or milestone achievement.',
    `retainage_percentage` DECIMAL(5,4) COMMENT 'Percentage of the invoiced amount withheld as retainage, expressed as a decimal (e.g., 0.1000 for 10%).',
    `scope_of_work` STRING COMMENT 'Detailed scope of work or deliverables associated with this expenditure, often referencing contract terms or work order specifications.',
    `tax_amount` DECIMAL(18,2) COMMENT 'Total tax amount (sales tax, value-added tax, goods and services tax) included in the invoiced amount.',
    `tax_rate` DECIMAL(5,4) COMMENT 'Tax rate applied to the expenditure, expressed as a decimal (e.g., 0.0700 for 7%).',
    `useful_life_years` BIGINT COMMENT 'Estimated useful life in years for depreciation purposes if the expenditure is capitalized.',
    `variance_amount` DECIMAL(18,2) COMMENT 'Variance between the approved budget amount and the actual expenditure amount, calculated as actual minus budget.',
    `vendor_name` STRING COMMENT 'Name of the vendor, contractor, or service provider to whom the expenditure was paid.',
    `work_order_reference` STRING COMMENT 'Reference number of the work order or project task associated with this expenditure.',
    `created_by` STRING COMMENT 'User or system identifier of the individual who created this expenditure record.',
    CONSTRAINT pk_capex_expenditure PRIMARY KEY(`capex_expenditure_id`)
) COMMENT 'Individual capital expenditure transaction records within an approved capex program. Captures expenditure date, vendor/contractor, work order reference, expenditure category (hard costs, soft costs, FF&E, contingency), invoiced amount, approved amount';

CREATE OR REPLACE TABLE `asset_management`.`realestate`.`realestate_debt_facility` (
    `realestate_debt_facility_id` BIGINT COMMENT 'Unique identifier for the real estate debt facility record. Primary key.',
    `actor_id` BIGINT COMMENT 'Reference to the party providing a guarantee or credit support for the facility, if applicable.',
    `credit_issuer_id` BIGINT COMMENT 'Reference to the financial institution or counterparty providing the debt facility.',
    `employee_id` BIGINT COMMENT 'Reference to the party providing a guarantee or credit support for the facility, if applicable.',
    `legal_entity_id` BIGINT COMMENT 'Reference to the internal legal entity that is the borrower under this facility.',
    `lender_counterparty_id` BIGINT COMMENT 'Foreign key linking to collateral.counterparty. Business justification: The lender of a debt facility is a counterparty; linking facilitates loan origination, servicing, and regulatory reporting.',
    `property_id` BIGINT COMMENT 'Reference to the underlying real estate property asset securing this debt facility.',
    `loan_servicer_id` BIGINT COMMENT 'Reference to the third-party servicer administering the loan, if applicable.',
    `accrued_interest_amount` DECIMAL(18,2) COMMENT 'Interest accrued but not yet paid as of the current valuation date.',
    `amortization_period_months` BIGINT COMMENT 'Total number of months over which the loan principal is scheduled to amortize.',
    `amortization_type` STRING COMMENT 'Principal repayment structure: interest-only, amortizing, bullet, or balloon payment.. Valid values are `interest_only|amortizing|bullet|balloon`',
    `commitment_date` DATE COMMENT 'Date when the lender committed to provide the debt facility.',
    `commitment_fee_rate` DECIMAL(5,4) COMMENT 'Annual fee rate applied to the undrawn portion of the facility, expressed as a decimal.',
    `covenant_package` STRING COMMENT 'Summary description of financial and operational covenants attached to the facility.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this debt facility record was first created in the system.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the debt facility denomination.. Valid values are `^[A-Z]{3}$`',
    `data_source_system` STRING COMMENT 'Name of the source system from which this debt facility record originated (e.g., eFront, State Street).',
    `default_date` DATE COMMENT 'Date when the facility entered default status, if applicable.',
    `default_flag` BOOLEAN COMMENT 'Indicates whether the facility is currently in default or breach of covenants.',
    `drawn_amount` DECIMAL(18,2) COMMENT 'Current principal amount drawn down and outstanding under the facility.',
    `dscr` DECIMAL(5,2) COMMENT 'Debt service coverage ratio measuring property NOI relative to debt service obligations.',
    `extension_option_flag` BOOLEAN COMMENT 'Indicates whether the facility includes an option to extend the maturity date.',
    `extension_period_months` BIGINT COMMENT 'Number of months by which the facility maturity can be extended if the option is exercised.',
    `facility_identifier` STRING COMMENT 'External loan or facility reference number assigned by the lender or internal system.',
    `facility_limit_amount` DECIMAL(18,2) COMMENT 'Maximum principal amount available under the debt facility agreement.',
    `facility_status` STRING COMMENT 'Current lifecycle status of the debt facility: active, committed, drawn, matured, repaid, or defaulted.. Valid values are `active|committed|drawn|matured|repaid|defaulted`',
    `facility_type` STRING COMMENT 'Classification of the debt facility structure: senior mortgage, mezzanine, construction loan, revolving credit, bridge loan, or term loan.. Valid values are `senior_mortgage|mezzanine|construction_loan|revolving_credit|bridge_loan|term_loan`',
    `interest_rate` DECIMAL(8,5) COMMENT 'Current annual interest rate applied to the drawn balance, expressed as a decimal (e.g., 0.0450 for 4.50%).',
    `interest_rate_type` STRING COMMENT 'Classification of the interest rate structure: fixed, floating, variable, or hybrid.. Valid values are `fixed|floating|variable|hybrid`',
    `last_payment_date` DATE COMMENT 'Date of the most recent debt service payment received.',
    `loan_agreement_date` DATE COMMENT 'Date when the formal loan agreement was signed by all parties.',
    `ltv_ratio` DECIMAL(5,4) COMMENT 'Loan-to-value ratio calculated as drawn amount divided by property valuation, expressed as a decimal (e.g., 0.6500 for 65%).',
    `maturity_date` DATE COMMENT 'Scheduled date when the debt facility principal is due for full repayment.',
    `modified_by_user` STRING COMMENT 'User identifier of the person who last modified this record.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this debt facility record was last modified.',
    `next_payment_date` DATE COMMENT 'Scheduled date for the next debt service payment.',
    `origination_date` DATE COMMENT 'Date when the debt facility was originated and the loan agreement was executed.',
    `origination_fee_amount` DECIMAL(18,2) COMMENT 'One-time fee paid to the lender at facility origination.',
    `payment_frequency` STRING COMMENT 'Frequency of scheduled debt service payments: monthly, quarterly, semi-annual, or annual.. Valid values are `monthly|quarterly|semi_annual|annual`',
    `prepayment_allowed_flag` BOOLEAN COMMENT 'Indicates whether prepayment of principal is permitted under the facility terms.',
    `prepayment_penalty_rate` DECIMAL(5,4) COMMENT 'Penalty rate applied to prepayments, expressed as a decimal percentage of prepaid principal.',
    `recourse_type` STRING COMMENT 'Extent of borrower liability beyond collateral: full recourse, non-recourse, or limited recourse.. Valid values are `full_recourse|non_recourse|limited_recourse`',
    `reference_rate` DECIMAL(18,2) COMMENT 'Benchmark rate used for floating rate facilities (e.g., SOFR, LIBOR, EURIBOR).',
    `security_type` STRING COMMENT 'Type of security or collateral arrangement: first lien, second lien, unsecured, or cross-collateralized.. Valid values are `first_lien|second_lien|unsecured|cross_collateralized`',
    `seniority` STRING COMMENT 'Priority ranking of the debt facility in the capital structure: senior, subordinated, mezzanine, or junior.. Valid values are `senior|subordinated|mezzanine|junior`',
    `spread_bps` BIGINT COMMENT 'Credit spread over the reference rate, expressed in basis points (e.g., 250 for 2.50%).',
    `undrawn_amount` DECIMAL(18,2) COMMENT 'Remaining available principal amount that can be drawn under the facility limit.',
    CONSTRAINT pk_realestate_debt_facility PRIMARY KEY(`realestate_debt_facility_id`)
) COMMENT 'Property-level debt financing records capturing mortgage and construction loan facilities secured against real estate assets. Captures lender identity, facility type (senior mortgage, mezzanine, construction loan, revolving credit), facility limit, drawn';

CREATE OR REPLACE TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` (
    `ltv_dscr_covenant_id` BIGINT COMMENT 'Unique identifier for the LTV and DSCR covenant compliance record.',
    `property_id` BIGINT COMMENT 'Reference to the real estate property asset subject to covenant measurement.',
    `realestate_debt_facility_id` BIGINT COMMENT 'Reference to the debt facility or loan agreement under which the covenant is measured.',
    `annual_debt_service` DECIMAL(18,2) COMMENT 'Total annual debt service obligation including principal and interest payments for the debt facility.',
    `appraiser_name` STRING COMMENT 'Name of the independent appraiser or valuation firm that provided the property valuation.',
    `approval_date` DATE COMMENT 'Date on which the covenant compliance report was formally approved.',
    `approved_by` STRING COMMENT 'Name or identifier of the senior officer or investment committee member who approved the covenant report.',
    `covenant_notes` STRING COMMENT 'Additional notes or commentary regarding the covenant measurement, compliance status, or special circumstances.',
    `cure_action_taken` STRING COMMENT 'Description of remedial actions taken to cure a covenant breach, such as capital injection or debt paydown.',
    `cure_completion_date` DATE COMMENT 'Date on which the covenant breach was cured and compliance was restored.',
    `currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for all monetary amounts in this covenant record.. Valid values are `^[A-Z]{3}$`',
    `dscr_breach_amount` DECIMAL(18,2) COMMENT 'Monetary shortfall by which the DSCR covenant is breached, if applicable; null if compliant.',
    `dscr_compliance_status` STRING COMMENT 'Current compliance status of the DSCR covenant at the measurement date.. Valid values are `compliant|breach|waived|cured`',
    `dscr_covenant_threshold` DECIMAL(8,4) COMMENT 'Minimum required DSCR as specified in the loan agreement or debt facility covenant.',
    `dscr_ratio` DECIMAL(8,4) COMMENT 'Calculated DSCR expressed as a decimal, representing NOI divided by annual debt service.',
    `lender_notification_date` DATE COMMENT 'Date on which the lender was formally notified of the covenant measurement results.',
    `ltv_breach_amount` DECIMAL(18,2) COMMENT 'Monetary amount by which the LTV covenant is breached, if applicable; null if compliant.',
    `ltv_compliance_status` STRING COMMENT 'Current compliance status of the LTV covenant at the measurement date.. Valid values are `compliant|breach|waived|cured`',
    `ltv_covenant_threshold` DECIMAL(8,4) COMMENT 'Maximum allowable LTV ratio as specified in the loan agreement or debt facility covenant.',
    `ltv_ratio` DECIMAL(8,4) COMMENT 'Calculated LTV ratio expressed as a decimal, representing outstanding debt divided by property GAV.',
    `measurement_date` DATE COMMENT 'The date on which the LTV and DSCR covenant compliance was measured and calculated.',
    `measurement_frequency` STRING COMMENT 'Frequency at which covenant compliance must be measured and reported per the loan agreement.. Valid values are `monthly|quarterly|semi_annual|annual`',
    `next_measurement_date` DATE COMMENT 'Scheduled date for the next covenant compliance measurement as per the loan agreement.',
    `noi_trailing_twelve_months` DECIMAL(18,2) COMMENT 'Net operating income for the property over the trailing twelve months, used in DSCR calculation.',
    `outstanding_debt_balance` DECIMAL(18,2) COMMENT 'Total outstanding principal balance of the debt facility at the measurement date.',
    `overall_covenant_status` STRING COMMENT 'Aggregate compliance status considering both LTV and DSCR covenants for the measurement period.. Valid values are `compliant|breach|waived|cured|under_review`',
    `prepared_by` STRING COMMENT 'Name or identifier of the individual or team responsible for preparing the covenant compliance report.',
    `property_gav` DECIMAL(18,2) COMMENT 'Current gross asset value of the property used in the LTV calculation, typically based on the most recent appraisal or valuation.',
    `property_nav` DECIMAL(18,2) COMMENT 'Net asset value of the property after deducting liabilities, used for alternative covenant calculations.',
    `record_created_timestamp` TIMESTAMP COMMENT 'Timestamp when this covenant compliance record was first created in the system.',
    `record_updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this covenant compliance record was last updated in the system.',
    `reporting_period` STRING COMMENT 'The fiscal period for which the covenant is reported, in YYYY-QN or YYYY-MM format.. Valid values are `^d{4}-Q[1-4]$|^d{4}-d{2}$`',
    `reviewed_by` STRING COMMENT 'Name or identifier of the individual or team that reviewed and approved the covenant compliance report.',
    `valuation_date` DATE COMMENT 'Date of the most recent property valuation or appraisal used in the GAV calculation.',
    `valuation_method` STRING COMMENT 'Method used to determine the property GAV for covenant calculation purposes.. Valid values are `appraisal|dcf|comparable_sales|income_capitalization|cost_approach`',
    `waiver_expiry_date` DATE COMMENT 'Date on which the granted covenant waiver expires, if applicable.',
    `waiver_granted_flag` BOOLEAN COMMENT 'Indicates whether a covenant waiver was granted by the lender for this measurement period.',
    CONSTRAINT pk_ltv_dscr_covenant PRIMARY KEY(`ltv_dscr_covenant_id`)
) COMMENT 'Periodic LTV (Loan-to-Value) and DSCR (Debt Service Coverage Ratio) covenant compliance records calculated at the property and debt facility level. Captures measurement date, current property GAV, outstanding debt balance, calculated LTV ratio, LTV';

CREATE OR REPLACE TABLE `asset_management`.`realestate`.`reit_position` (
    `reit_position_id` BIGINT COMMENT 'Unique identifier for the REIT position record within the portfolio management system.',
    `portfolio_id` BIGINT COMMENT 'Reference to the investment portfolio that holds this REIT position.',
    `acquisition_date` DATE COMMENT 'Date when the initial position in this REIT was established, used for holding period and performance attribution calculations.',
    `annual_distribution_amount` DECIMAL(18,2) COMMENT 'Total cash distributions received from the REIT over the trailing twelve months in position currency.',
    `average_cost_per_unit` DECIMAL(18,4) COMMENT 'Weighted average acquisition cost per unit in the position currency, calculated across all purchase transactions.',
    `base_currency_market_value` DECIMAL(18,2) COMMENT 'Market value of the position converted to the fund base currency using the current foreign exchange rate for consolidated reporting.',
    `benchmark_index` STRING COMMENT 'Name of the market index used to evaluate relative performance of this REIT position, such as FTSE NAREIT All Equity REITs Index.',
    `carbon_intensity` DECIMAL(18,4) COMMENT 'Greenhouse gas emissions per unit of revenue or square footage for the REIT underlying properties, measured in metric tons CO2 equivalent.',
    `country_of_domicile` STRING COMMENT 'Three-letter ISO 3166-1 alpha-3 country code indicating the legal jurisdiction where the REIT is incorporated and regulated.. Valid values are `^[A-Z]{3}$`',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp recording when this REIT position record was first created in the investment book of record.',
    `current_market_price` DECIMAL(18,4) COMMENT 'Most recent traded price per unit as of the last market close or intraday quote, used for mark-to-market valuation.',
    `cusip` STRING COMMENT 'Nine-character alphanumeric code identifying North American securities for clearing and settlement.. Valid values are `^[0-9]{3}[A-Z0-9]{5}[0-9]$`',
    `custodian_account_number` STRING COMMENT 'Account identifier at the custodian bank where the REIT units are held in safekeeping for settlement and corporate action processing.',
    `custodian_name` STRING COMMENT 'Name of the financial institution providing custody and safekeeping services for the REIT position.',
    `dividend_yield` DECIMAL(8,6) COMMENT 'Annualized dividend income as a percentage of current market price, calculated from trailing twelve-month distributions.',
    `esg_rating` STRING COMMENT 'Third-party ESG assessment score or rating assigned to the REIT issuer, reflecting sustainability and responsible investment criteria.',
    `esg_rating_provider` STRING COMMENT 'Name of the third-party organization that assigned the ESG rating, such as MSCI, Sustainalytics, or FTSE Russell.',
    `exchange_code` STRING COMMENT 'Market Identifier Code (MIC) of the primary exchange where the REIT is listed and traded.',
    `fx_rate` DECIMAL(18,8) COMMENT 'Exchange rate used to convert position currency to base currency, expressed as units of base currency per unit of position currency.',
    `investment_committee_approval_date` DATE COMMENT 'Date on which the Investment Committee formally approved the initial investment or material increase in this REIT position.',
    `investment_strategy` STRING COMMENT 'Strategic mandate or sub-portfolio classification under which this REIT position is held, such as core real estate, opportunistic, or income-focused.',
    `isin` STRING COMMENT 'ISO 6166 standard 12-character alphanumeric code uniquely identifying the REIT security globally.. Valid values are `^[A-Z]{2}[A-Z0-9]{9}[0-9]$`',
    `last_distribution_date` DATE COMMENT 'Most recent date on which a dividend or distribution was paid to unitholders of record.',
    `last_trade_date` DATE COMMENT 'Most recent date on which a buy or sell transaction was executed for this REIT position, used for turnover and activity analysis.',
    `lei` STRING COMMENT 'ISO 17442 standard 20-character alphanumeric code uniquely identifying the REIT legal entity for regulatory reporting and counterparty identification.. Valid values are `^[A-Z0-9]{20}$`',
    `market_value` DECIMAL(18,2) COMMENT 'Current fair value of the entire position calculated as units held multiplied by current market price in position currency.',
    `next_distribution_date` DATE COMMENT 'Expected date of the next scheduled dividend or distribution payment based on the REIT declared distribution calendar.',
    `notes` STRING COMMENT 'Free-text field for portfolio manager commentary, special instructions, or qualitative observations regarding the REIT position.',
    `position_currency` STRING COMMENT 'Three-letter ISO 4217 currency code in which the REIT is denominated and traded on the primary exchange.. Valid values are `^[A-Z]{3}$`',
    `position_status` STRING COMMENT 'Current lifecycle state of the position indicating whether it is actively held, fully liquidated, temporarily suspended, or subject to trading restrictions.. Valid values are `active|closed|suspended|restricted`',
    `price_source` STRING COMMENT 'Name of the market data vendor or pricing service providing the current market price, such as Bloomberg, Reuters, or exchange feed.',
    `reit_name` STRING COMMENT 'Full legal name of the REIT issuer as registered with the exchange or regulatory authority.',
    `reit_sector` STRING COMMENT 'Primary real estate sector classification of the REIT based on underlying property holdings.. Valid values are `office|industrial|retail|residential|diversified|specialty`',
    `reit_type` STRING COMMENT 'Structural classification indicating whether the REIT primarily holds equity in properties, mortgages, or a hybrid combination.. Valid values are `equity|mortgage|hybrid`',
    `sedol` STRING COMMENT 'Seven-character alphanumeric code identifying securities traded on the London Stock Exchange and other UK exchanges.. Valid values are `^[0-9A-Z]{7}$`',
    `ticker_symbol` STRING COMMENT 'Exchange-specific trading symbol used to identify the REIT on the primary listing exchange.',
    `total_cost_basis` DECIMAL(18,2) COMMENT 'Aggregate acquisition cost of the entire position in the position currency, including transaction costs if capitalized.',
    `units_held` DECIMAL(18,4) COMMENT 'Total number of REIT shares or units currently held in the position, reflecting all purchases, sales, and corporate actions.',
    `unrealized_gain_loss` DECIMAL(18,2) COMMENT 'Difference between current market value and total cost basis, representing mark-to-market profit or loss not yet realized through sale.',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp recording the most recent modification to this REIT position record for audit and data lineage purposes.',
    `valuation_date` DATE COMMENT 'Date as of which the current market price and market value were determined for financial reporting and net asset value calculation.',
    `weight_in_portfolio` DECIMAL(8,6) COMMENT 'Position market value as a percentage of total portfolio net asset value, used for asset allocation and risk monitoring.',
    `weight_in_real_estate_allocation` DECIMAL(8,6) COMMENT 'Position market value as a percentage of the total real estate asset class allocation within the portfolio.',
    CONSTRAINT pk_reit_position PRIMARY KEY(`reit_position_id`)
) COMMENT 'Master record for listed REIT (Real Estate Investment Trust) positions held within the real estate allocation. Captures REIT name, ISIN, CUSIP, SEDOL, exchange, REIT sector (office, industrial, retail, residential, diversified, specialty), number of units';

CREATE OR REPLACE TABLE `asset_management`.`realestate`.`re_fund_commitment` (
    `re_fund_commitment_id` BIGINT COMMENT 'Unique identifier for the real estate fund commitment record. Primary key.',
    `custodian_id` BIGINT COMMENT 'Reference to the custodian bank or fund administrator responsible for holding and administering the pension funds Limited Partner (LP) interest in the real estate fund.',
    `gp_entity_id` BIGINT COMMENT 'Reference to the General Partner (GP) entity managing the real estate fund.',
    `carried_interest_rate` DECIMAL(10,6) COMMENT 'Carried interest (carry) percentage that the General Partner (GP) receives on profits above the hurdle rate, typically 20% in real estate funds.',
    `commitment_amount` DECIMAL(18,2) COMMENT 'Total capital amount committed by the pension fund to the real estate fund, representing the maximum callable capital over the funds life.',
    `commitment_currency` STRING COMMENT 'Three-letter ISO 4217 currency code in which the commitment amount is denominated.. Valid values are `^[A-Z]{3}$`',
    `commitment_date` DATE COMMENT 'Date on which the pension fund formally committed capital to the real estate fund, typically the date the Limited Partnership Agreement (LPA) was executed.',
    `commitment_number` STRING COMMENT 'Externally-known unique identifier or reference number for this fund commitment, often assigned by the General Partner (GP) or internal deal tracking system.',
    `commitment_status` STRING COMMENT 'Current lifecycle status of the fund commitment indicating whether it is pending approval, active and callable, fully funded, partially funded, cancelled, or terminated.. Valid values are `pending|active|fully_funded|partially_funded|cancelled|terminated`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this commitment record was first created in the system.',
    `distributions_received` DECIMAL(18,2) COMMENT 'Cumulative distributions received by the pension fund from the real estate fund, including both income distributions and capital returns.',
    `dpi` DECIMAL(10,4) COMMENT 'Distributions to Paid-In (DPI) multiple, calculated as cumulative distributions received divided by Paid-In Capital (PIC), measuring realized returns.',
    `esg_classification` STRING COMMENT 'Sustainable Finance Disclosure Regulation (SFDR) classification of the real estate fund: Article 6 (no sustainability focus), Article 8 (promotes ESG characteristics), Article 9 (sustainable investment objective), or not classified.. Valid values are `article_6|article_8|article_9|not_classified`',
    `expected_termination_date` DATE COMMENT 'Projected date on which the real estate fund will terminate and complete all distributions, based on fund term and extension provisions.',
    `extension_options_years` BIGINT COMMENT 'Number of additional years the General Partner (GP) may extend the fund term beyond the initial term, subject to Limited Partner (LP) approval or consent thresholds.',
    `final_close_date` DATE COMMENT 'Date of the final capital close for the real estate fund, after which no additional Limited Partner (LP) commitments are accepted.',
    `final_fund_size` DECIMAL(18,2) COMMENT 'Actual total capital commitments raised by the real estate fund at final close, representing the aggregate Limited Partner (LP) commitments.',
    `first_close_date` DATE COMMENT 'Date of the first capital close for the real estate fund, when the General Partner (GP) began accepting Limited Partner (LP) commitments and making investments.',
    `fund_manager_name` STRING COMMENT 'Name of the investment management firm or General Partner (GP) responsible for managing the real estate fund.',
    `fund_strategy` STRING COMMENT 'Investment strategy classification of the real estate fund indicating risk-return profile: core, core-plus, value-add, opportunistic, debt, open-end, or closed-end.',
    `fund_term_years` BIGINT COMMENT 'Total contractual term of the real estate fund in years, typically 10-12 years including investment period and harvest period, as specified in the Limited Partnership Agreement (LPA).',
    `fund_type` STRING COMMENT 'Structural classification of the real estate fund vehicle: commingled fund, separate account, club deal, joint venture, or fund-of-funds.. Valid values are `commingled|separate_account|club_deal|joint_venture|fund_of_funds`',
    `geographic_focus` STRING COMMENT 'Primary geographic investment focus of the real estate fund, such as North America, Europe, Asia-Pacific, or specific countries/regions.',
    `gresb_participation_flag` BOOLEAN COMMENT 'Boolean indicator of whether the real estate fund participates in Global Real Estate Sustainability Benchmark (GRESB) reporting and assessment.',
    `hurdle_rate` DECIMAL(10,6) COMMENT 'Preferred return threshold that Limited Partners (LPs) must achieve before the General Partner (GP) receives carried interest, typically 8% for real estate funds.',
    `ic_approval_date` DATE COMMENT 'Date on which the pension funds Investment Committee (IC) approved the commitment to the real estate fund.',
    `ic_approval_reference` STRING COMMENT 'Reference number or identifier for the Investment Committee (IC) decision or Investment Memorandum (IM) that approved this commitment.',
    `investment_period_years` BIGINT COMMENT 'Duration in years during which the General Partner (GP) can make new investments, typically 3-5 years from first close.',
    `irr` DECIMAL(10,4) COMMENT 'Internal Rate of Return (IRR) of the pension funds investment in the real estate fund, representing the annualized time-weighted return including all cash flows and current Net Asset Value (NAV).',
    `key_person_clause_flag` BOOLEAN COMMENT 'Boolean indicator of whether the Limited Partnership Agreement (LPA) includes a key person clause that suspends investment activity if designated key investment professionals leave the General Partner (GP).',
    `last_valuation_date` DATE COMMENT 'Date of the most recent Net Asset Value (NAV) valuation provided by the General Partner (GP) for the real estate fund.',
    `management_fee_rate` DECIMAL(10,6) COMMENT 'Annual management fee rate charged by the General Partner (GP), expressed as a percentage of committed capital or Net Asset Value (NAV) depending on fund terms.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this commitment record was last modified or updated in the system.',
    `most_favored_nation_flag` BOOLEAN COMMENT 'Boolean indicator of whether the pension fund has Most Favored Nation (MFN) rights, entitling it to the most favorable terms granted to any other Limited Partner (LP).',
    `nav` DECIMAL(18,2) COMMENT 'Current Net Asset Value (NAV) of the pension funds investment in the real estate fund, representing the fair market value of the Limited Partner (LP) interest.',
    `ownership_percentage` DECIMAL(10,6) COMMENT 'Percentage ownership interest of the pension fund in the real estate fund, calculated as the pension funds commitment divided by final fund size.',
    `pic` DECIMAL(18,2) COMMENT 'Cumulative amount of capital called and paid by the pension fund to the real estate fund to date, representing actual funded capital.',
    `pri_signatory_flag` BOOLEAN COMMENT 'Boolean indicator of whether the General Partner (GP) is a signatory to the United Nations Principles for Responsible Investment (PRI).',
    `property_type_focus` STRING COMMENT 'Primary property type or sector focus of the real estate fund, such as office, retail, industrial, multifamily, hospitality, healthcare, or mixed-use.',
    `reporting_frequency` STRING COMMENT 'Frequency at which the General Partner (GP) provides financial and operational reports to Limited Partners (LPs): monthly, quarterly, semi-annual, or annual.. Valid values are `monthly|quarterly|semi_annual|annual`',
    `rvpi` DECIMAL(10,4) COMMENT 'Residual Value to Paid-In (RVPI) multiple, calculated as Net Asset Value (NAV) divided by Paid-In Capital (PIC), measuring unrealized value remaining in the fund.',
    `side_letter_flag` BOOLEAN COMMENT 'Boolean indicator of whether the pension fund negotiated a side letter with the General Partner (GP) containing special terms, rights, or reporting requirements beyond the standard Limited Partnership Agreement (LPA).',
    `target_fund_size` DECIMAL(18,2) COMMENT 'Total target capital raise for the real estate fund as stated in the Private Placement Memorandum (PPM), representing the General Partner (GP) fundraising goal.',
    `tvpi` DECIMAL(10,4) COMMENT 'Total Value to Paid-In (TVPI) multiple, calculated as the sum of distributions received plus Net Asset Value (NAV) divided by Paid-In Capital (PIC), measuring total value creation.',
    `unfunded_commitment` DECIMAL(18,2) COMMENT 'Remaining uncalled capital commitment available for future capital calls, calculated as commitment amount minus Paid-In Capital (PIC). Also known as dry powder.',
    `vintage_year` BIGINT COMMENT 'Year in which the real estate fund was established or began making investments, used for performance benchmarking and cohort analysis.',
    CONSTRAINT pk_re_fund_commitment PRIMARY KEY(`re_fund_commitment_id`)
) COMMENT 'Commitment records for real estate fund investments (closed-end real estate funds, open-end core funds, value-add funds, opportunistic funds) where the pension fund acts as an LP.';

CREATE OR REPLACE TABLE `asset_management`.`realestate`.`re_capital_call` (
    `re_capital_call_id` BIGINT COMMENT 'Unique identifier for the real estate capital call transaction record.',
    `portfolio_id` BIGINT COMMENT 'Foreign key linking to portfolio.portfolio. Business justification: Capital calls from RE funds must link to calling portfolio for liquidity management, funding coordination with treasury, and commitment utilization tracking.',
    `re_fund_commitment_id` BIGINT COMMENT 'Reference to the Limited Partnership Agreement (LPA) commitment against which this call is drawn.',
    `acquisition_amount` DECIMAL(18,2) COMMENT 'Portion of the capital call allocated to property acquisition costs.',
    `call_amount` DECIMAL(18,2) COMMENT 'Total amount requested from the Limited Partner (LP) in this capital call, denominated in the fund currency.',
    `call_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the capital call amount.. Valid values are `^[A-Z]{3}$`',
    `call_due_date` DATE COMMENT 'Date by which the Limited Partner (LP) must fund the capital call amount per the Limited Partnership Agreement (LPA).',
    `call_notice_date` DATE COMMENT 'Date on which the General Partner (GP) issued the capital call notice to Limited Partners (LPs).',
    `call_notice_document_uri` STRING COMMENT 'Document management system URI or path to the official capital call notice document issued by the General Partner (GP).',
    `call_notice_number` STRING COMMENT 'Unique business identifier assigned by the General Partner (GP) to this capital call notice.',
    `call_purpose` STRING COMMENT 'Primary purpose for which the capital is being called: property acquisition, capital expenditure, management fees, fund expenses, working capital, or mixed use.. Valid values are `acquisition|capex|fees|expenses|working_capital|mixed`',
    `call_status` STRING COMMENT 'Current lifecycle status of the capital call transaction.. Valid values are `issued|acknowledged|funded|partially_funded|overdue|cancelled`',
    `capex_amount` DECIMAL(18,2) COMMENT 'Portion of the capital call allocated to capital expenditure programs for post-acquisition value creation.',
    `commitment_percentage_called` DECIMAL(5,2) COMMENT 'Percentage of the total Limited Partnership Agreement (LPA) commitment that will be called after this capital call is funded.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this capital call record was first created in the system.',
    `cumulative_pic_post_call` DECIMAL(18,2) COMMENT 'Total Paid-In Capital (PIC) from the Limited Partner (LP) to the fund after this capital call is funded.',
    `cumulative_pic_pre_call` DECIMAL(18,2) COMMENT 'Total Paid-In Capital (PIC) from the Limited Partner (LP) to the fund immediately before this capital call.',
    `default_interest_accrued` DECIMAL(18,2) COMMENT 'Total default interest accrued on this capital call due to late or partial funding.',
    `default_interest_rate` DECIMAL(5,4) COMMENT 'Annual interest rate applied to late or unfunded capital call amounts per the Limited Partnership Agreement (LPA), expressed as a decimal.',
    `fund_expense_amount` DECIMAL(18,2) COMMENT 'Portion of the capital call allocated to fund-level operating expenses.',
    `funded_amount` DECIMAL(18,2) COMMENT 'Actual amount funded by the Limited Partner (LP) in response to this capital call.',
    `funded_date` DATE COMMENT 'Date on which the Limited Partner (LP) transferred funds to the General Partner (GP) for this capital call.',
    `fx_rate` DECIMAL(12,6) COMMENT 'Foreign exchange rate applied if the Limited Partner (LP) funded in a currency different from the fund currency.',
    `fx_rate_date` DATE COMMENT 'Date on which the foreign exchange rate was determined for currency conversion.',
    `gp_bank_account_number` STRING COMMENT 'Bank account number of the General Partner (GP) receiving the capital call funds.',
    `gp_bank_bic` STRING COMMENT 'Bank Identifier Code (BIC) or SWIFT code for the General Partner (GP) receiving bank.. Valid values are `^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$`',
    `gp_bank_name` STRING COMMENT 'Name of the financial institution holding the General Partner (GP) receiving account.',
    `gp_contact_email` STRING COMMENT 'Email address of the General Partner (GP) representative for inquiries regarding this capital call.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `gp_contact_name` STRING COMMENT 'Name of the General Partner (GP) representative responsible for this capital call.',
    `internal_approval_date` DATE COMMENT 'Date on which internal approval was granted to fund this capital call.',
    `internal_approver_name` STRING COMMENT 'Name of the internal pension fund officer who approved funding this capital call.',
    `last_modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this capital call record was last updated in the system.',
    `management_fee_amount` DECIMAL(18,2) COMMENT 'Portion of the capital call allocated to General Partner (GP) management fees.',
    `notes` STRING COMMENT 'Free-text notes or comments regarding this capital call transaction, including any special instructions or exceptions.',
    `other_amount` DECIMAL(18,2) COMMENT 'Portion of the capital call allocated to purposes not classified in standard categories.',
    `payment_reference_number` STRING COMMENT 'Bank or treasury system reference number for the wire transfer or payment transaction funding this capital call.',
    `settlement_account_number` STRING COMMENT 'Bank account number used by the Limited Partner (LP) to settle this capital call payment.',
    `working_capital_amount` DECIMAL(18,2) COMMENT 'Portion of the capital call allocated to property-level working capital requirements.',
    CONSTRAINT pk_re_capital_call PRIMARY KEY(`re_capital_call_id`)
) COMMENT 'Capital call (drawdown) transaction records issued by real estate fund GPs to the pension fund as LP. Captures call notice date, due date, call amount, call purpose (acquisition, capex, fees, expenses), cumulative paid-in capital post-call, fund';

CREATE OR REPLACE TABLE `asset_management`.`realestate`.`re_distribution` (
    `re_distribution_id` BIGINT COMMENT 'Unique identifier for the real estate distribution transaction record.',
    `cash_account_id` BIGINT COMMENT 'Reference to the custodian bank account into which the distribution cash was settled.',
    `gp_entity_id` BIGINT COMMENT 'Reference to the General Partner entity that issued this distribution.',
    `portfolio_id` BIGINT COMMENT 'Foreign key linking to portfolio.portfolio. Business justification: RE fund distributions flow to specific portfolios for cash management, reinvestment decisions, and performance attribution.',
    `re_fund_commitment_id` BIGINT COMMENT 'Reference to the underlying real estate fund investment position from which this distribution originated.',
    `re_fund_investment_id` BIGINT COMMENT 'Reference to the underlying real estate fund investment position from which this distribution originated.',
    `underlying_property_id` BIGINT COMMENT 'Reference to the specific real estate property asset that generated this distribution, if attributable.',
    `accounting_period` STRING COMMENT 'The accounting period (YYYY-MM or YYYY-QN) to which this distribution is allocated for financial reporting.. Valid values are `^d{4}-Q[1-4]$|^d{4}-d{2}$`',
    `announcement_date` DATE COMMENT 'The date on which the GP formally announced or notified the distribution to limited partners.',
    `base_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the pension funds base reporting currency.. Valid values are `^[A-Z]{3}$`',
    `capital_gain_component` DECIMAL(18,2) COMMENT 'The portion of the distribution classified as capital gains for tax reporting purposes.',
    `carried_interest_component` DECIMAL(18,2) COMMENT 'The portion of the distribution representing carried interest or performance fees paid to the GP.',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this distribution record was first created in the system.',
    `data_source_system` STRING COMMENT 'The operational system or data feed from which this distribution record was sourced.. Valid values are `eFront|custodian_feed|gp_portal|manual_entry`',
    `distribution_amount_base` DECIMAL(18,2) COMMENT 'The gross distribution amount converted to the pension funds base reporting currency (typically USD).',
    `distribution_amount_local` DECIMAL(18,2) COMMENT 'The gross distribution amount in the funds local reporting currency before any withholding or adjustments.',
    `distribution_date` DATE COMMENT 'The date on which the distribution was paid or is scheduled to be paid by the GP to the LP.',
    `distribution_notes` STRING COMMENT 'Free-text commentary from the GP or internal investment team regarding the distribution context or special circumstances.',
    `distribution_notice_number` STRING COMMENT 'External reference number assigned by the GP on the distribution notice or capital account statement.',
    `distribution_per_unit` DECIMAL(18,6) COMMENT 'The distribution amount per LP unit or per share of fund ownership.',
    `distribution_sequence_number` BIGINT COMMENT 'Sequential numbering of distributions from this fund investment for tracking and reconciliation purposes.',
    `distribution_source` STRING COMMENT 'The underlying economic event or transaction that generated this distribution.. Valid values are `asset_sale|refinancing|operating_income|portfolio_revaluation|fund_liquidation`',
    `distribution_status` STRING COMMENT 'Current lifecycle status of the distribution transaction from announcement through settlement.. Valid values are `announced|confirmed|settled|reversed|pending_settlement`',
    `distribution_type` STRING COMMENT 'Classification of the distribution according to its economic nature and tax treatment.. Valid values are `income|return_of_capital|recapitalization|carried_interest|liquidation|special`',
    `dpi_impact` DECIMAL(8,4) COMMENT 'The incremental impact of this distribution on the DPI multiple for the fund investment.',
    `fx_rate` DECIMAL(12,6) COMMENT 'The exchange rate applied to convert local currency distribution amount to base currency.',
    `hurdle_rate_met_flag` BOOLEAN COMMENT 'Indicates whether the preferred return hurdle rate threshold has been met, triggering carried interest participation.',
    `income_component` DECIMAL(18,2) COMMENT 'The portion of the distribution classified as ordinary income for tax and accounting purposes.',
    `irr_contribution` DECIMAL(8,4) COMMENT 'The contribution of this distribution to the cumulative IRR calculation for the fund investment, expressed as a percentage.',
    `k1_schedule_reference` STRING COMMENT 'Reference to the IRS Schedule K-1 or equivalent tax document line item associated with this distribution.',
    `local_currency_code` STRING COMMENT 'Three-letter ISO 4217 currency code for the funds local reporting currency.. Valid values are `^[A-Z]{3}$`',
    `modified_timestamp` TIMESTAMP COMMENT 'The timestamp when this distribution record was last modified or updated.',
    `nav_impact_amount` DECIMAL(18,2) COMMENT 'The impact of this distribution on the fund investments Net Asset Value for valuation purposes.',
    `net_distribution_amount` DECIMAL(18,2) COMMENT 'The net cash amount received by the LP after all withholdings and adjustments.',
    `reconciliation_status` STRING COMMENT 'Status of reconciliation between GP notice, custodian cash receipt, and internal accounting records.. Valid values are `matched|unmatched|exception|pending_review`',
    `record_date` DATE COMMENT 'The date on which LP ownership is determined for eligibility to receive the distribution.',
    `reinvestment_flag` BOOLEAN COMMENT 'Indicates whether this distribution was automatically reinvested into the fund per the LPA or LP election.',
    `return_of_capital_component` DECIMAL(18,2) COMMENT 'The portion of the distribution representing a return of the LPs original invested capital.',
    `settlement_date` DATE COMMENT 'The actual date on which cash was received in the LP custodian account.',
    `tax_year` BIGINT COMMENT 'The fiscal or calendar year to which this distribution is allocated for tax reporting purposes.',
    `units_held` DECIMAL(18,6) COMMENT 'The number of LP units or shares held by the pension fund on the record date.',
    `waterfall_tier` STRING COMMENT 'The distribution waterfall tier or tranche from which this distribution was paid per the LPA.. Valid values are `tier_1_return_of_capital|tier_2_preferred_return|tier_3_catch_up|tier_4_carried_interest`',
    `withholding_tax_amount` DECIMAL(18,2) COMMENT 'Total tax withheld at source by the GP or underlying jurisdictions on the distribution.',
    CONSTRAINT pk_re_distribution PRIMARY KEY(`re_distribution_id`)
) COMMENT 'Distribution transaction records received from real estate fund GPs representing return of capital, income distributions, and carried interest waterfalls. Captures distribution date, distribution type (income, return of capital, recapitalisation, carried';

CREATE OR REPLACE TABLE `asset_management`.`realestate`.`property_acquisition` (
    `property_acquisition_id` BIGINT COMMENT 'Unique identifier for each direct property acquisition transaction executed by the pension fund.',
    `cash_account_id` BIGINT COMMENT 'Foreign key linking to treasury.cash_account. Business justification: Acquisition settlement is paid from a specific cash account; the pension fund tracks the source account for accounting and reconciliation.',
    `contributor_pool_id` BIGINT COMMENT 'Foreign key linking to beneficiary.contributor_pool. Business justification: During a property acquisition, the acquisition is funded by a specific contributor pool, which must be tracked to allocate capital and calculate contribution rates.',
    `dd_engagement_id` BIGINT COMMENT 'Foreign key linking to diligence.dd_engagement. Business justification: The acquisition decision is driven by the due diligence engagement that produced findings; linking acquisition to dd_engagement_id allows tracking of the engagement that justified the',
    `deal_opportunity_id` BIGINT COMMENT 'Reference to the origination deal pipeline record that led to this acquisition.',
    `employee_id` BIGINT COMMENT 'Reference to the internal or external asset manager responsible for post-acquisition management.',
    `gp_profile_id` BIGINT COMMENT 'Reference to the internal or external asset manager responsible for post-acquisition management.',
    `opportunity_id` BIGINT COMMENT 'Reference to the origination deal pipeline record that led to this acquisition.',
    `portfolio_id` BIGINT COMMENT 'Foreign key linking to portfolio.portfolio. Business justification: Direct property acquisitions must specify target portfolio for allocation tracking, mandate compliance verification, and performance attribution.',
    `property_id` BIGINT COMMENT 'Reference to the underlying real estate asset acquired in this transaction.',
    `seller_actor_id` BIGINT COMMENT 'Foreign key linking to shared.actor. Business justification: Acquisition records need to reference the seller entity for audit and regulatory reporting; linking to actor provides a structured reference.',
    `acquisition_date` DATE COMMENT 'The date on which legal title to the property was transferred to the pension fund.',
    `acquisition_notes` STRING COMMENT 'Free-text field capturing additional context, conditions, or observations about the acquisition.',
    `acquisition_status` STRING COMMENT 'Current lifecycle status of the acquisition transaction.. Valid values are `pending|completed|cancelled|under_review`',
    `acquisition_strategy` STRING COMMENT 'Risk-return classification of the acquisition strategy employed.. Valid values are `core|core_plus|value_add|opportunistic`',
    `acquisition_structure` STRING COMMENT 'Legal structure through which the property was acquired.. Valid values are `direct|spv|joint_venture|fund`',
    `acquisition_yield` DECIMAL(5,2) COMMENT 'Initial yield calculated as first-year NOI divided by total acquisition cost, expressed as a percentage.',
    `advisory_fees` DECIMAL(18,2) COMMENT 'Investment advisory, brokerage, and consulting fees paid for the acquisition.',
    `cap_rate` DECIMAL(5,2) COMMENT 'Market capitalization rate at acquisition representing NOI divided by purchase price.',
    `co_investor_flag` BOOLEAN COMMENT 'Indicates whether the acquisition was executed with one or more co-investment partners.',
    `completion_date` DATE COMMENT 'Date on which all conditions precedent were satisfied and the transaction legally completed.',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when the acquisition record was first created in the data platform.',
    `debt_amount` DECIMAL(18,2) COMMENT 'Portion of the acquisition financed through debt or leverage.',
    `due_diligence_costs` DECIMAL(18,2) COMMENT 'Total costs incurred for operational, financial, legal, and ESG due diligence activities.',
    `environmental_risk_description` STRING COMMENT 'Narrative description of any environmental risks identified during acquisition due diligence.',
    `environmental_risk_flag` BOOLEAN COMMENT 'Indicates whether material environmental risks were identified during due diligence.',
    `equity_amount` DECIMAL(18,2) COMMENT 'Portion of the acquisition financed through pension fund equity capital.',
    `esg_rating_at_acquisition` STRING COMMENT 'ESG rating or score assigned to the property at acquisition based on due diligence assessment.',
    `going_in_irr` DECIMAL(5,2) COMMENT 'Projected internal rate of return at acquisition based on underwriting assumptions.',
    `ic_approval_date` DATE COMMENT 'Date on which the Investment Committee formally approved the acquisition.',
    `ic_approval_reference` STRING COMMENT 'Reference number of the Investment Committee approval decision or memorandum.',
    `legal_fees` DECIMAL(18,2) COMMENT 'Legal advisory and conveyancing fees incurred in the acquisition transaction.',
    `loi_date` DATE COMMENT 'Date on which the non-binding Letter of Intent was executed with the seller.',
    `ltv_ratio` DECIMAL(5,2) COMMENT 'Debt amount divided by property value at acquisition, expressed as a percentage.',
    `noi_at_acquisition` DECIMAL(18,2) COMMENT 'Trailing twelve-month Net Operating Income at the time of acquisition.',
    `occupancy_rate_at_acquisition` DECIMAL(5,2) COMMENT 'Physical occupancy rate of the property at the time of acquisition, expressed as a percentage.',
    `other_transaction_costs` DECIMAL(18,2) COMMENT 'Miscellaneous acquisition costs not captured in other specific cost categories.',
    `ownership_percentage` DECIMAL(5,2) COMMENT 'Percentage ownership stake held by the pension fund in the acquired property.',
    `portfolio_allocation` STRING COMMENT 'Strategic portfolio segment or sleeve to which this acquisition is allocated.',
    `property_city` STRING COMMENT 'City or metropolitan area where the property is located.',
    `property_country` STRING COMMENT 'Three-letter ISO country code where the property is located.. Valid values are `^[A-Z]{3}$`',
    `property_sector` STRING COMMENT 'Primary real estate sector classification of the acquired property.. Valid values are `office|retail|industrial|multifamily|hospitality|mixed_use`',
    `purchase_price` DECIMAL(18,2) COMMENT 'Total consideration paid for the property acquisition excluding transaction costs.',
    `seller_lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier of the seller if applicable.. Valid values are `^[A-Z0-9]{20}$`',
    `seller_name` STRING COMMENT 'Legal name of the entity or individual from whom the property was acquired.',
    `spa_date` DATE COMMENT 'Date on which the binding Share Purchase Agreement or Sale and Purchase Agreement was signed.',
    `stamp_duty` DECIMAL(18,2) COMMENT 'Government stamp duty or transfer tax paid on the property acquisition.',
    `target_hold_period_years` BIGINT COMMENT 'Planned investment horizon in years from acquisition to anticipated disposition.',
    `total_acquisition_cost` DECIMAL(18,2) COMMENT 'Sum of purchase price and all transaction costs representing total capital deployed.',
    `transaction_currency` STRING COMMENT 'Three-letter ISO 4217 currency code in which the acquisition was denominated.. Valid values are `^[A-Z]{3}$`',
    `transaction_reference` STRING COMMENT 'External business identifier for the acquisition transaction used in legal documents and reporting.',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp when the acquisition record was last modified in the data platform.',
    CONSTRAINT pk_property_acquisition PRIMARY KEY(`property_acquisition_id`)
) COMMENT 'Transaction record for each direct property acquisition executed by the pension fund. Captures acquisition date, purchase price, transaction costs (stamp duty, legal, advisory), financing structure (equity/debt split), acquisition yield (initial yield';

CREATE OR REPLACE TABLE `asset_management`.`realestate`.`property_disposal` (
    `property_disposal_id` BIGINT COMMENT 'Unique identifier for each property disposal transaction executed by the pension fund.',
    `buyer_actor_id` BIGINT COMMENT 'Foreign key linking to shared.actor. Business justification: Disposal transactions require a buyer entity for financial reconciliation and compliance; linking to actor ensures traceability.',
    `cash_account_id` BIGINT COMMENT 'Foreign key linking to treasury.cash_account. Business justification: Disposal proceeds are credited to a cash account; linking enables tracking of cash inflows and reconciliation with treasury records.',
    `dd_engagement_id` BIGINT COMMENT 'Foreign key linking to diligence.dd_engagement. Business justification: The disposal decision is based on the due diligence engagement that assessed the property; linking disposal to dd_engagement_id enables audit of the engagement that informed the sale.',
    `portfolio_id` BIGINT COMMENT 'Foreign key linking to portfolio.portfolio. Business justification: Property dispositions must reference owning portfolio for realized gain/loss attribution, rebalancing trigger assessment, and GIPS-compliant performance reporting.',
    `property_id` BIGINT COMMENT 'Reference to the direct property asset being disposed.',
    `advisor_firm_name` STRING COMMENT 'Name of the external advisory firm engaged to support the disposal transaction.',
    `book_value_at_disposal` DECIMAL(18,2) COMMENT 'Carrying value of the property on the balance sheet at the disposal date per accounting records.',
    `buyer_legal_name` STRING COMMENT 'Full legal name of the acquiring party or buyer entity.',
    `buyer_lei` STRING COMMENT 'Twenty-character ISO 17442 Legal Entity Identifier (LEI) of the buyer.. Valid values are `^[A-Z0-9]{20}$`',
    `buyer_type` STRING COMMENT 'Classification of the buyer entity by investor type.. Valid values are `institutional_investor|private_equity|reit|sovereign_wealth_fund|pension_fund|individual`',
    `capital_gains_tax_amount` DECIMAL(18,2) COMMENT 'Estimated or actual capital gains tax liability arising from the disposal transaction.',
    `contract_signing_date` DATE COMMENT 'Date when the Share Purchase Agreement (SPA) or sale contract was executed.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the disposal record was first created in the system.',
    `disposal_date` DATE COMMENT 'Legal completion date when ownership transferred to the buyer and proceeds were received.',
    `disposal_notes` STRING COMMENT 'Free-text field capturing additional context, special conditions, or commentary on the disposal transaction.',
    `disposal_rationale` STRING COMMENT 'Strategic business rationale for disposing of the property including portfolio rebalancing, capital recycling, or underperformance.',
    `disposal_status` STRING COMMENT 'Current lifecycle status of the disposal transaction.. Valid values are `pending|under_contract|completed|cancelled|failed`',
    `disposal_transaction_number` STRING COMMENT 'Externally-known unique transaction reference number for the disposal event.',
    `disposal_type` STRING COMMENT 'Classification of the disposal transaction structure.. Valid values are `full_sale|partial_sale|recapitalization|joint_venture_exit|portfolio_sale|asset_swap`',
    `escrow_account_flag` BOOLEAN COMMENT 'Indicates whether an escrow account was used to hold proceeds pending final settlement conditions.',
    `exit_cap_rate` DECIMAL(5,4) COMMENT 'Capitalization rate implied by the sale price calculated as Net Operating Income (NOI) divided by gross sale price.',
    `exit_noi` DECIMAL(18,2) COMMENT 'Trailing twelve-month Net Operating Income (NOI) at the time of disposal used for exit cap rate calculation.',
    `gross_sale_price` DECIMAL(18,2) COMMENT 'Total sale price agreed before deducting transaction costs and adjustments.',
    `holding_period_years` DECIMAL(5,2) COMMENT 'Total number of years the property was held from acquisition to disposal.',
    `ic_approval_date` DATE COMMENT 'Date when the Investment Committee (IC) approved the disposal transaction.',
    `ic_approval_reference` STRING COMMENT 'Reference number or identifier for the Investment Committee (IC) approval decision.',
    `irr` DECIMAL(7,4) COMMENT 'Internal Rate of Return (IRR) achieved on the investment from acquisition through disposal including all cash flows.',
    `legal_counsel_firm_name` STRING COMMENT 'Name of the law firm providing legal counsel for the disposal transaction.',
    `moic` DECIMAL(5,2) COMMENT 'Multiple on Invested Capital (MOIC) calculated as total value realized divided by total capital invested.',
    `net_proceeds` DECIMAL(18,2) COMMENT 'Net cash proceeds received after deducting all transaction costs from gross sale price.',
    `realized_gain_loss` DECIMAL(18,2) COMMENT 'Realized gain or loss calculated as net proceeds minus book value at disposal.',
    `settlement_method` STRING COMMENT 'Method used to settle the disposal transaction and transfer proceeds.. Valid values are `wire_transfer|escrow|dvp|deferred_payment`',
    `tax_jurisdiction` STRING COMMENT 'Three-letter ISO country code representing the primary tax jurisdiction for the disposal transaction.. Valid values are `^[A-Z]{3}$`',
    `transaction_costs` DECIMAL(18,2) COMMENT 'Total costs incurred to execute the disposal including legal, advisory, brokerage, and due diligence fees.',
    `transaction_currency` STRING COMMENT 'Three-letter ISO 4217 currency code in which the disposal transaction was denominated.. Valid values are `^[A-Z]{3}$`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the disposal record was last modified in the system.',
    `withholding_tax_amount` DECIMAL(18,2) COMMENT 'Withholding tax deducted at source by the buyer or intermediary per local tax regulations.',
    CONSTRAINT pk_property_disposal PRIMARY KEY(`property_disposal_id`)
) COMMENT 'Transaction record for each direct property disposal (sale, partial sale, recapitalisation) executed by the pension fund. Captures disposal date, gross sale price, transaction costs, net proceeds, book value at disposal, realised gain/loss, exit cap rate';

CREATE OR REPLACE TABLE `asset_management`.`realestate`.`occupancy_record` (
    `occupancy_record_id` BIGINT COMMENT 'Unique identifier for the occupancy measurement record.',
    `property_id` BIGINT COMMENT 'Reference to the real estate property being measured.',
    `absorption_rate` DECIMAL(18,2) COMMENT 'Net change in occupied space during the measurement period, expressed in area units.',
    `area_unit` STRING COMMENT 'Unit of measure for area calculations (square feet or square meters).. Valid values are `sqft|sqm`',
    `average_tenant_size` DECIMAL(18,2) COMMENT 'Average GLA per tenant, calculated as total occupied GLA divided by tenant count.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the occupancy record was first created in the system.',
    `data_source` STRING COMMENT 'Source system or platform from which occupancy data was extracted (e.g., property management system, lease administration system).',
    `economic_occupancy_rate` DECIMAL(5,4) COMMENT 'Percentage of potential rental income being collected, accounting for rent concessions and free rent periods.',
    `largest_tenant_gla` DECIMAL(18,2) COMMENT 'GLA occupied by the largest single tenant, used for concentration risk assessment.',
    `lease_expiry_exposure_12m` DECIMAL(18,2) COMMENT 'Total GLA with leases expiring within the next 12 months from measurement date.',
    `lease_expiry_exposure_24m` DECIMAL(18,2) COMMENT 'Total GLA with leases expiring within the next 24 months from measurement date.',
    `leasing_velocity` DECIMAL(18,2) COMMENT 'Total GLA leased during the measurement period, indicating leasing activity momentum.',
    `market_occupancy_rate` DECIMAL(5,4) COMMENT 'Average occupancy rate for comparable properties in the same submarket as of the measurement date.',
    `measurement_date` DATE COMMENT 'The date on which the occupancy measurement was taken.',
    `measurement_method` STRING COMMENT 'Method used to determine occupancy: actual (physical inspection), estimated (based on lease data), or prorated (partial period calculation).. Valid values are `actual|estimated|prorated`',
    `measurement_period` STRING COMMENT 'The reporting period for this occupancy measurement (e.g., 2024-Q1, 2024-03).',
    `measurement_status` STRING COMMENT 'Status of the occupancy measurement record in the reporting workflow.. Valid values are `draft|preliminary|final|revised|audited`',
    `notes` STRING COMMENT 'Free-text notes providing additional context, explanations for variances, or special circumstances affecting occupancy.',
    `occupancy_trend` STRING COMMENT 'Directional trend of occupancy over recent measurement periods.. Valid values are `increasing|stable|decreasing|volatile`',
    `occupancy_variance_pct` DECIMAL(7,4) COMMENT 'Variance between actual physical occupancy rate and target occupancy rate, expressed as a percentage.',
    `occupied_gla` DECIMAL(18,2) COMMENT 'Gross leasable area currently occupied by tenants in square feet or square meters.',
    `physical_occupancy_rate` DECIMAL(5,4) COMMENT 'Percentage of total GLA that is physically occupied, calculated as occupied GLA divided by total GLA.',
    `prior_period_occupancy_rate` DECIMAL(5,4) COMMENT 'Physical occupancy rate from the previous measurement period for trend analysis.',
    `renewal_rate` DECIMAL(5,4) COMMENT 'Percentage of expiring leases that were renewed during the measurement period.',
    `stabilized_occupancy_flag` BOOLEAN COMMENT 'Indicates whether the property has reached stabilized occupancy levels as defined in the investment underwriting.',
    `stabilized_occupancy_target` DECIMAL(5,4) COMMENT 'Target occupancy rate defined at acquisition or development completion for stabilized operations.',
    `tenant_count` BIGINT COMMENT 'Number of active tenants occupying space as of the measurement date.',
    `top_five_tenant_concentration` DECIMAL(5,4) COMMENT 'Percentage of total GLA occupied by the five largest tenants.',
    `total_gla` DECIMAL(18,2) COMMENT 'Total gross leasable area of the property in square feet or square meters.',
    `total_unit_count` BIGINT COMMENT 'Total number of leasable units or spaces in the property.',
    `turnover_rate` DECIMAL(5,4) COMMENT 'Percentage of GLA that experienced tenant turnover during the measurement period.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the occupancy record was last modified.',
    `vacancy_type` STRING COMMENT 'Classification of vacancy: structural (long-term market condition), transitional (between tenants), development (pre-lease), seasonal, strategic (held for repositioning), or frictional (normal turnover).. Valid values are `structural|transitional|development|seasonal|strategic|frictional`',
    `vacant_gla` DECIMAL(18,2) COMMENT 'Gross leasable area currently vacant in square feet or square meters.',
    `vacant_unit_count` BIGINT COMMENT 'Number of leasable units or spaces that are currently vacant.',
    `verification_date` DATE COMMENT 'Date on which the occupancy data was verified and approved for reporting.',
    `verified_by` STRING COMMENT 'Name or identifier of the asset manager or analyst who verified the occupancy data.',
    `weighted_average_lease_term` DECIMAL(8,2) COMMENT 'Weighted average remaining lease term across all tenants, weighted by GLA, expressed in years.',
    CONSTRAINT pk_occupancy_record PRIMARY KEY(`occupancy_record_id`)
) COMMENT 'Periodic occupancy and vacancy tracking records at the property and tenancy level. Captures measurement date, total GLA, occupied GLA, vacant GLA, physical occupancy rate, economic occupancy rate, vacancy type (structural, transitional, development)';

CREATE OR REPLACE TABLE `asset_management`.`realestate`.`property_operating_expense` (
    `property_operating_expense_id` BIGINT COMMENT 'Unique identifier for the property operating expense record.',
    `cash_account_id` BIGINT COMMENT 'Foreign key linking to treasury.cash_account. Business justification: Operating expense payments are executed from a cash account; the link supports expense accounting and cash flow management.',
    `noi_record_id` BIGINT COMMENT 'Reference to the NOI record into which this expense rolls up for property-level income calculation.',
    `property_id` BIGINT COMMENT 'Reference to the property for which this operating expense was incurred.',
    `realestate_capex_program_id` BIGINT COMMENT 'Reference to the capital expenditure project if this expense is part of a larger capital improvement or value creation program.',
    `vendor_id` BIGINT COMMENT 'Unique identifier for the vendor in the vendor master data system.',
    `accounting_period` STRING COMMENT 'The accounting period (YYYY-MM format) to which this operating expense is allocated for financial reporting and NOI calculation.. Valid values are `^d{4}-(0[1-9]|1[0-2])$`',
    `approval_date` DATE COMMENT 'The date on which this operating expense was approved for payment.',
    `approval_status` STRING COMMENT 'Current approval status of the operating expense in the expense management workflow.. Valid values are `pending|approved|rejected|paid`',
    `approved_by` STRING COMMENT 'Name or identifier of the individual who approved this operating expense for payment.',
    `base_currency_amount` DECIMAL(18,2) COMMENT 'The operating expense amount converted to the funds base reporting currency for consolidated financial reporting.',
    `base_currency_code` STRING COMMENT 'Three-letter ISO 4217 code for the funds base reporting currency.. Valid values are `^[A-Z]{3}$`',
    `budget_line_item` STRING COMMENT 'The budget line item or category against which this operating expense is tracked for variance analysis.',
    `budgeted_amount` DECIMAL(18,2) COMMENT 'The budgeted or forecasted amount for this expense category in the accounting period, used for variance analysis.',
    `capitalized_flag` BOOLEAN COMMENT 'Indicates whether this expense qualifies for capitalization as a capital expenditure rather than an operating expense under accounting standards.',
    `cost_center` STRING COMMENT 'The cost center or business unit responsible for managing and tracking this operating expense.',
    `created_timestamp` TIMESTAMP COMMENT 'The timestamp when this operating expense record was first created in the system.',
    `property_operating_expense_description` STRING COMMENT 'Detailed narrative description of the operating expense, including the nature of the goods or services provided.',
    `expense_amount` DECIMAL(18,2) COMMENT 'The gross amount of the operating expense before any adjustments, discounts, or recoveries.',
    `expense_category` STRING COMMENT 'Classification of the operating expense type: property tax, insurance, utilities, maintenance, cleaning, security, management fee, or leasing commission. [ENUM-REF-CANDIDATE',
    `expense_currency` STRING COMMENT 'Three-letter ISO 4217 currency code in which the operating expense was incurred.. Valid values are `^[A-Z]{3}$`',
    `expense_date` DATE COMMENT 'The date on which the operating expense was incurred or recognized for accounting purposes.',
    `expense_subcategory` STRING COMMENT 'Detailed subcategory within the primary expense category for granular expense tracking and analysis.',
    `fiscal_quarter` STRING COMMENT 'The fiscal quarter (Q1, Q2, Q3, Q4) to which this operating expense is allocated for quarterly performance reporting.. Valid values are `Q1|Q2|Q3|Q4`',
    `fiscal_year` BIGINT COMMENT 'The fiscal year to which this operating expense belongs for annual financial reporting and budgeting purposes.',
    `fx_rate` DECIMAL(12,6) COMMENT 'The exchange rate applied to convert the expense amount from transaction currency to base currency.',
    `gl_account_code` STRING COMMENT 'The general ledger account code to which this operating expense is posted in the accounting system.',
    `invoice_date` DATE COMMENT 'The date the vendor issued the invoice for this operating expense.',
    `invoice_number` STRING COMMENT 'The invoice or billing reference number provided by the vendor for this expense transaction.',
    `net_expense_amount` DECIMAL(18,2) COMMENT 'The net operating expense after deducting any recoverable amounts from tenants, representing the true cost to the property owner.',
    `notes` STRING COMMENT 'Additional notes, comments, or special instructions related to this operating expense for audit trail and operational reference.',
    `payment_date` DATE COMMENT 'The actual date on which payment was made to the vendor for this operating expense.',
    `payment_due_date` DATE COMMENT 'The date by which payment for this operating expense is due to the vendor.',
    `payment_method` STRING COMMENT 'The payment instrument or method used to settle this operating expense with the vendor.. Valid values are `wire_transfer|check|ach|credit_card|direct_debit`',
    `payment_reference` STRING COMMENT 'The payment transaction reference number or confirmation code from the treasury or payment system.',
    `recoverable_amount` DECIMAL(18,2) COMMENT 'The portion of the operating expense that is recoverable from tenants, reducing the net expense impact on NOI.',
    `recoverable_flag` BOOLEAN COMMENT 'Indicates whether this operating expense is recoverable from tenants through lease agreements or operating expense pass-throughs.',
    `tax_treatment` STRING COMMENT 'The tax treatment classification of this operating expense for income tax reporting purposes.. Valid values are `deductible|non_deductible|partially_deductible|exempt`',
    `updated_timestamp` TIMESTAMP COMMENT 'The timestamp when this operating expense record was last modified or updated in the system.',
    `variance_amount` DECIMAL(18,2) COMMENT 'The difference between the actual expense amount and the budgeted amount, indicating over or under budget performance.',
    `variance_percentage` DECIMAL(5,2) COMMENT 'The variance expressed as a percentage of the budgeted amount, providing a normalized measure of budget performance.',
    `vat_amount` DECIMAL(18,2) COMMENT 'The value-added tax or goods and services tax component included in the operating expense amount.',
    `vat_rate` DECIMAL(5,2) COMMENT 'The VAT or GST rate percentage applied to this operating expense.',
    `vendor_name` STRING COMMENT 'Name of the vendor or service provider who supplied the goods or services for this operating expense.',
    CONSTRAINT pk_property_operating_expense PRIMARY KEY(`property_operating_expense_id`)
) COMMENT 'Detailed operating-expense line records that roll up into the property-level NOI ledger (noi_record). Captures expense date, category (property tax, insurance, utilities, maintenance, cleaning, security, management fee, leasing commission), vendor';

CREATE OR REPLACE TABLE `asset_management`.`realestate`.`jv_structure` (
    `jv_structure_id` BIGINT COMMENT 'Unique identifier for the joint venture structure record.',
    `property_id` BIGINT COMMENT 'Reference to the property held through this joint venture structure.',
    `accounting_method` STRING COMMENT 'Accounting treatment applied to the joint venture investment: equity method, proportionate consolidation, cost method, or full consolidation.. Valid values are `equity_method|proportionate_consolidation|cost_method|full_consolidation`',
    `audit_firm_name` STRING COMMENT 'Name of the external audit firm responsible for auditing the joint ventures financial statements.',
    `carried_interest_rate_pct` DECIMAL(5,2) COMMENT 'Carried interest (carry) percentage allocated to the General Partner upon exceeding the hurdle rate.',
    `control_classification` STRING COMMENT 'Classification of the pension funds level of control or influence over the joint venture: controlled (consolidate), joint control (equity method), significant influence (equity method), or no control.. Valid values are `controlled|joint_control|significant_influence|no_control`',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this joint venture structure record was first created in the system.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the joint ventures functional currency.. Valid values are `^[A-Z]{3}$`',
    `distribution_waterfall_type` STRING COMMENT 'Type of distribution waterfall structure governing profit distributions: European (whole-fund), American (deal-by-deal), or hybrid.. Valid values are `european|american|hybrid`',
    `effective_date` DATE COMMENT 'Date when the joint venture arrangement became effective and operational.',
    `esg_policy_flag` BOOLEAN COMMENT 'Indicates whether the joint venture has adopted formal Environmental, Social, and Governance policies.',
    `extension_options_count` BIGINT COMMENT 'Number of extension options available to extend the joint venture term beyond the initial period.',
    `formation_date` DATE COMMENT 'Date when the joint venture entity was legally formed or incorporated.',
    `fund_term_years` BIGINT COMMENT 'Total term of the joint venture fund in years, including any extension periods.',
    `gp_name` STRING COMMENT 'Name of the General Partner managing the joint venture, if applicable.',
    `gp_ownership_pct` DECIMAL(5,2) COMMENT 'Percentage ownership stake held by the General Partner in the joint venture entity.',
    `hurdle_rate_pct` DECIMAL(5,2) COMMENT 'Preferred return threshold (hurdle rate) that must be achieved before carried interest is paid to the General Partner.',
    `investment_period_end_date` DATE COMMENT 'Date when the investment period for the joint venture concludes.',
    `investment_strategy` STRING COMMENT 'Investment strategy or mandate of the joint venture (e.g., core, core-plus, value-add, opportunistic).',
    `jurisdiction` STRING COMMENT 'Legal jurisdiction or country where the joint venture entity is registered and governed.',
    `jv_arrangement_type` STRING COMMENT 'Classification of the joint arrangement: joint operation (rights to assets and obligations for liabilities), joint venture (rights to net assets), or co-investment.. Valid values are `joint_operation|joint_venture|co_investment`',
    `jv_entity_code` STRING COMMENT 'Internal code or identifier for the joint venture entity.',
    `jv_entity_name` STRING COMMENT 'Legal name of the joint venture entity or partnership vehicle.',
    `jv_status` STRING COMMENT 'Current lifecycle status of the joint venture arrangement.. Valid values are `active|inactive|pending|dissolved|restructuring`',
    `last_audit_date` DATE COMMENT 'Date of the most recent external audit of the joint venture.',
    `legal_structure_type` STRING COMMENT 'Legal form of the joint venture entity (Limited Partnership, Limited Liability Company, Trust, Real Estate Investment Trust, Corporation, Partnership).. Valid values are `LP|LLC|Trust|REIT|Corporation|Partnership`',
    `lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier for the joint venture entity, enabling global identification.. Valid values are `^[A-Z0-9]{20}$`',
    `lpa_execution_date` DATE COMMENT 'Date when the Limited Partnership Agreement was executed by all parties.',
    `lpa_reference` STRING COMMENT 'Reference identifier or document number for the Limited Partnership Agreement governing the joint venture.',
    `management_fee_rate_pct` DECIMAL(5,2) COMMENT 'Annual management fee rate charged by the General Partner or asset manager, expressed as a percentage of committed capital or Net Asset Value.',
    `notes` STRING COMMENT 'Additional notes, comments, or contextual information about the joint venture structure.',
    `pension_fund_capital_commitment` DECIMAL(18,2) COMMENT 'Total capital commitment amount by the pension fund to the joint venture.',
    `pension_fund_ownership_pct` DECIMAL(5,2) COMMENT 'Percentage ownership stake held by the pension fund in the joint venture entity.',
    `pension_fund_paid_in_capital` DECIMAL(18,2) COMMENT 'Actual capital contributed by the pension fund to date (Paid-In Capital).',
    `pri_signatory_flag` BOOLEAN COMMENT 'Indicates whether the joint venture or its General Partner is a signatory to the UN Principles for Responsible Investment.',
    `primary_co_investor_name` STRING COMMENT 'Name of the primary co-investor or partner in the joint venture.',
    `primary_co_investor_ownership_pct` DECIMAL(5,2) COMMENT 'Percentage ownership stake held by the primary co-investor in the joint venture entity.',
    `primary_co_investor_type` STRING COMMENT 'Classification of the primary co-investor by investor type.. Valid values are `institutional_investor|sovereign_wealth_fund|pension_fund|private_equity|insurance_company|family_office`',
    `reporting_frequency` STRING COMMENT 'Frequency at which the joint venture provides financial and operational reports to investors.. Valid values are `monthly|quarterly|semi_annual|annual`',
    `target_irr_pct` DECIMAL(5,2) COMMENT 'Target Internal Rate of Return for the joint venture investment.',
    `target_moic` DECIMAL(5,2) COMMENT 'Target Multiple on Invested Capital for the joint venture investment.',
    `tax_identification_number` STRING COMMENT 'Tax identification number or employer identification number for the joint venture entity.',
    `termination_date` DATE COMMENT 'Date when the joint venture arrangement was terminated or dissolved, if applicable.',
    `total_co_investors_count` BIGINT COMMENT 'Total number of co-investors or partners in the joint venture structure.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this joint venture structure record was last updated in the system.',
    `valuation_frequency` STRING COMMENT 'Frequency at which the joint ventures assets are formally valued.. Valid values are `monthly|quarterly|semi_annual|annual`',
    CONSTRAINT pk_jv_structure PRIMARY KEY(`jv_structure_id`)
) COMMENT 'Joint venture (JV) and co-investment structure records for properties held through partnership vehicles. Captures JV entity name, legal structure (LP, LLC, trust, REIT), pension fund ownership percentage, co-investor identities and ownership percentages';

CREATE OR REPLACE TABLE `asset_management`.`realestate`.`property_insurance` (
    `property_insurance_id` BIGINT COMMENT 'Unique identifier for the property insurance policy record.',
    `property_id` BIGINT COMMENT 'Reference to the real estate property asset covered by this insurance policy.',
    `additional_insured_parties` STRING COMMENT 'Other parties named on the policy who are entitled to coverage benefits, such as property managers or co-investors.',
    `aggregate_limit` DECIMAL(18,2) COMMENT 'Maximum total amount the insurer will pay for all covered losses during the policy period, capping total exposure.',
    `annual_premium` DECIMAL(18,2) COMMENT 'Total annual cost paid to the insurer for maintaining coverage, used for budgeting and expense allocation.',
    `approval_date` DATE COMMENT 'Date when the insurance policy was formally approved by internal governance for execution.',
    `approved_by` STRING COMMENT 'Name or identifier of the internal authority who approved the insurance policy purchase and terms.',
    `broker_name` STRING COMMENT 'Name of the insurance broker or intermediary who arranged the policy on behalf of the pension fund.',
    `cancellation_notice_days` BIGINT COMMENT 'Number of days advance notice required by either party to cancel the policy per contractual terms.',
    `cancellation_reason` STRING COMMENT 'Documented reason for policy cancellation if status is cancelled, required for audit and compliance reporting.',
    `certificate_of_insurance_reference` STRING COMMENT 'Reference to the certificate of insurance document provided as proof of coverage to third parties.',
    `claims_history_summary` STRING COMMENT 'Summary of prior insurance claims filed against this property impacting underwriting and premium pricing.',
    `claims_made_basis_flag` BOOLEAN COMMENT 'Indicates whether the policy covers claims made during the policy period versus occurrence-based coverage.',
    `coinsurance_percentage` DECIMAL(5,2) COMMENT 'Percentage of loss shared between the insured and insurer after deductible, typically expressed as a ratio.',
    `coverage_description` STRING COMMENT 'Detailed narrative describing the specific risks covered, exclusions, and special conditions of the insurance policy.',
    `coverage_limit` DECIMAL(18,2) COMMENT 'Maximum amount the insurer will pay for a covered loss under this policy, defining the upper bound of risk transfer.',
    `coverage_type` STRING COMMENT 'Primary category of insurance coverage provided by this policy for risk classification and portfolio management. [ENUM-REF-CANDIDATE: property_damage|liability|business_interruption|environmental|flood|earthquake|terrorism — 7 candidates stripped; promote',
    `created_timestamp` TIMESTAMP COMMENT 'System timestamp when this insurance policy record was first created in the data platform for audit trail purposes.',
    `deductible_amount` DECIMAL(18,2) COMMENT 'Amount the pension fund must pay out-of-pocket before insurance coverage applies, impacting net risk exposure.',
    `endorsements` STRING COMMENT 'Amendments or riders attached to the base policy that modify coverage terms, limits, or conditions.',
    `exclusions` STRING COMMENT 'Specific perils, conditions, or circumstances explicitly excluded from coverage under this insurance policy.',
    `expiry_date` DATE COMMENT 'Date when the insurance coverage terminates unless renewed, critical for risk management and renewal planning.',
    `inception_date` DATE COMMENT 'Date when the insurance coverage becomes effective and risk transfer begins.',
    `insured_value` DECIMAL(18,2) COMMENT 'Maximum amount of coverage provided by the policy representing the replacement cost or agreed value of the property asset.',
    `insurer_lei` STRING COMMENT 'ISO 17442 Legal Entity Identifier for the insurance carrier enabling global counterparty identification.. Valid values are `^[A-Z0-9]{20}$`',
    `insurer_name` STRING COMMENT 'Legal name of the insurance company providing coverage for the property asset.',
    `last_inspection_date` DATE COMMENT 'Date of the most recent property inspection conducted by the insurer for underwriting or renewal purposes.',
    `loss_payee` STRING COMMENT 'Entity designated to receive insurance proceeds in the event of a covered loss, often a lender or mortgagee.',
    `loss_ratio_percent` DECIMAL(5,2) COMMENT 'Ratio of claims paid to premiums collected expressed as a percentage, indicating policy profitability for the insurer.',
    `next_inspection_due_date` DATE COMMENT 'Scheduled date for the next required property inspection to maintain coverage compliance.',
    `notes` STRING COMMENT 'Free-form text field for additional comments, special conditions, or operational notes regarding the insurance policy.',
    `payment_frequency` STRING COMMENT 'Frequency at which premium payments are made to the insurer for cash flow planning and treasury management.. Valid values are `annual|semi_annual|quarterly|monthly`',
    `per_occurrence_limit` DECIMAL(18,2) COMMENT 'Maximum amount the insurer will pay for a single covered loss event, defining per-incident exposure.',
    `policy_document_reference` STRING COMMENT 'Reference identifier or file path to the complete insurance policy document for audit and compliance purposes.',
    `policy_number` STRING COMMENT 'Unique policy number assigned by the insurance carrier for identification and claims processing.',
    `policy_status` STRING COMMENT 'Current state of the insurance policy in its lifecycle for risk monitoring and compliance tracking.. Valid values are `active|pending|expired|cancelled|lapsed|renewed`',
    `policy_term_months` BIGINT COMMENT 'Duration of the insurance policy coverage period in months, typically 12 for annual policies.',
    `premium_currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for the premium and insured value amounts enabling multi-currency portfolio management.. Valid values are `^[A-Z]{3}$`',
    `renewal_date` DATE COMMENT 'Scheduled date for policy renewal negotiation and premium renegotiation with the insurer.',
    `retroactive_date` DATE COMMENT 'Earliest date for which claims will be covered under a claims-made policy, defining the lookback period.',
    `risk_assessment_rating` STRING COMMENT 'Insurers evaluation of the property risk profile used for underwriting and premium calculation.',
    `total_claims_paid_to_date` DECIMAL(18,2) COMMENT 'Cumulative amount paid by the insurer for all claims under this policy since inception for loss ratio analysis.',
    `underwriter_name` STRING COMMENT 'Name of the underwriting professional or team at the insurer who assessed and approved the policy.',
    `updated_timestamp` TIMESTAMP COMMENT 'System timestamp when this insurance policy record was most recently modified for change tracking and audit compliance.',
    `valuation_method` STRING COMMENT 'Methodology used to determine the amount payable in the event of a covered loss, impacting claim settlement.. Valid values are `replacement_cost|actual_cash_value|agreed_value|market_value`',
    `waiting_period_days` BIGINT COMMENT 'Number of days after a loss event before business interruption coverage begins paying benefits.',
    CONSTRAINT pk_property_insurance PRIMARY KEY(`property_insurance_id`)
) COMMENT 'Insurance policy records for each property asset covering property damage, liability, business interruption, and environmental risk. Captures insurer name, policy number, coverage type, insured value, annual premium, policy inception and expiry dates';

CREATE OR REPLACE TABLE `asset_management`.`realestate`.`esg_property_assessment` (
    `esg_property_assessment_id` BIGINT COMMENT 'Unique identifier for the ESG property assessment record.',
    `property_id` BIGINT COMMENT 'Reference to the real estate property being assessed.',
    `approval_date` DATE COMMENT 'Date when the ESG assessment was formally approved.',
    `approved_by` STRING COMMENT 'Name or identifier of the person or committee that approved the ESG assessment.',
    `assessment_date` DATE COMMENT 'Date when the ESG assessment was conducted.',
    `assessment_methodology` STRING COMMENT 'Description of the methodology or framework used to conduct the ESG assessment (e.g., GRESB, proprietary framework).',
    `assessment_status` STRING COMMENT 'Current status of the ESG assessment in its lifecycle.. Valid values are `draft|in_progress|completed|approved|expired`',
    `assessment_type` STRING COMMENT 'Type of ESG assessment conducted for the property.. Valid values are `initial|annual|ad_hoc|acquisition_due_diligence|post_acquisition|certification_renewal`',
    `assessor_contact_email` STRING COMMENT 'Email address of the primary assessor contact.. Valid values are `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$`',
    `assessor_contact_name` STRING COMMENT 'Primary contact person at the assessor firm responsible for this assessment.',
    `assessor_firm_name` STRING COMMENT 'Name of the third-party firm or internal team that conducted the ESG assessment.',
    `certification_date` DATE COMMENT 'Date when the environmental certification was awarded.',
    `certification_expiry_date` DATE COMMENT 'Date when the environmental certification expires and requires renewal.',
    `certification_level` STRING COMMENT 'Level or rating achieved within the certification scheme (e.g., Platinum, Gold, Silver, Bronze, or numeric rating).',
    `certification_reference_number` STRING COMMENT 'Unique reference or registration number assigned by the certifying body.',
    `climate_risk_assessment_flag` BOOLEAN COMMENT 'Indicates whether a formal climate risk assessment (physical and transition risks) has been conducted for the property.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when the ESG assessment record was first created in the system.',
    `data_quality_rating` STRING COMMENT 'Assessment of the quality and reliability of data used in the ESG assessment.. Valid values are `high|medium|low`',
    `energy_consumption_kwh` DECIMAL(18,2) COMMENT 'Total energy consumed by the property during the reporting period, measured in kilowatt-hours.',
    `energy_intensity_kwh_per_sqm` DECIMAL(12,3) COMMENT 'Energy consumption normalized by gross leasable area, expressed as kWh per square meter.',
    `environmental_certification_type` STRING COMMENT 'Type of green building certification held by the property. [ENUM-REF-CANDIDATE: LEED|BREEAM|NABERS|ENERGY_STAR|WELL|GREEN_STAR|DGNB|HQE|none — 9 candidates stripped; promote to reference product]',
    `esg_risk_rating` STRING COMMENT 'Overall ESG risk rating assigned to the property based on assessment findings.. Valid values are `low|medium|high|critical`',
    `esg_score` DECIMAL(5,2) COMMENT 'Numeric ESG score assigned to the property, typically on a 0-100 scale.',
    `ghg_emissions_intensity_kg_co2e_per_sqm` DECIMAL(12,3) COMMENT 'GHG emissions normalized by gross leasable area, expressed as kg CO2e per square meter.',
    `ghg_scope_1_emissions_tonnes_co2e` DECIMAL(18,3) COMMENT 'Direct GHG emissions from sources owned or controlled by the property (e.g., on-site fuel combustion, refrigerants).',
    `ghg_scope_2_emissions_tonnes_co2e` DECIMAL(18,3) COMMENT 'Indirect GHG emissions from purchased electricity, steam, heating, and cooling consumed by the property.',
    `ghg_scope_3_emissions_tonnes_co2e` DECIMAL(18,3) COMMENT 'Other indirect GHG emissions from value chain activities (e.g., tenant activities, waste disposal, business travel).',
    `green_lease_clause_flag` BOOLEAN COMMENT 'Indicates whether the property has green lease clauses in tenant agreements that promote sustainability practices.',
    `green_lease_coverage_percentage` DECIMAL(5,2) COMMENT 'Percentage of gross leasable area covered by leases with green lease clauses.',
    `health_safety_incidents_count` BIGINT COMMENT 'Number of health and safety incidents reported at the property during the reporting period.',
    `notes` STRING COMMENT 'Additional notes, observations, or commentary related to the ESG assessment.',
    `physical_climate_risk_level` STRING COMMENT 'Assessment of physical climate risks (flooding, extreme weather, sea level rise) facing the property.. Valid values are `low|medium|high|extreme`',
    `renewable_energy_percentage` DECIMAL(5,2) COMMENT 'Percentage of total energy consumption sourced from renewable energy (solar, wind, hydro, etc.).',
    `reporting_period_end_date` DATE COMMENT 'End date of the period covered by this ESG assessment.',
    `reporting_period_start_date` DATE COMMENT 'Start date of the period covered by this ESG assessment.',
    `social_impact_assessment_flag` BOOLEAN COMMENT 'Indicates whether a social impact assessment (community engagement, tenant wellbeing, accessibility) has been conducted.',
    `tenant_satisfaction_score` DECIMAL(5,2) COMMENT 'Tenant satisfaction score from surveys, typically on a 0-100 scale, reflecting social performance.',
    `third_party_verification_flag` BOOLEAN COMMENT 'Indicates whether the ESG assessment data has been verified by an independent third party.',
    `total_ghg_emissions_tonnes_co2e` DECIMAL(18,3) COMMENT 'Total GHG emissions across all scopes (Scope 1 + Scope 2 + Scope 3).',
    `transition_climate_risk_level` STRING COMMENT 'Assessment of transition climate risks (policy changes, carbon pricing, market shifts) affecting the property.. Valid values are `low|medium|high|extreme`',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when the ESG assessment record was last modified in the system.',
    `verification_date` DATE COMMENT 'Date when the third-party verification was completed.',
    `verification_firm_name` STRING COMMENT 'Name of the third-party firm that verified the ESG assessment data.',
    `waste_diversion_rate_percentage` DECIMAL(5,2) COMMENT 'Percentage of total waste diverted from landfill (waste diverted / waste generated * 100).',
    `waste_diverted_tonnes` DECIMAL(18,3) COMMENT 'Total waste diverted from landfill through recycling, composting, or reuse, measured in tonnes.',
    `waste_generated_tonnes` DECIMAL(18,3) COMMENT 'Total waste generated by the property during the reporting period, measured in tonnes.',
    `water_consumption_cubic_meters` DECIMAL(18,2) COMMENT 'Total water consumed by the property during the reporting period, measured in cubic meters.',
    `water_intensity_cubic_meters_per_sqm` DECIMAL(12,6) COMMENT 'Water consumption normalized by gross leasable area, expressed as cubic meters per square meter.',
    CONSTRAINT pk_esg_property_assessment PRIMARY KEY(`esg_property_assessment_id`)
) COMMENT 'ESG and sustainability assessment records at the property level capturing environmental certifications (LEED, BREEAM, NABERS, ENERGY STAR), GHG emissions (Scope 1, 2, 3), energy intensity (kWh/sqm), water intensity, waste diversion rate, green lease';

CREATE OR REPLACE TABLE `asset_management`.`realestate`.`asset_business_plan` (
    `asset_business_plan_id` BIGINT COMMENT 'Unique identifier for the asset business plan record.',
    `actor_id` BIGINT COMMENT 'Reference to the internal asset manager or team responsible for executing this business plan and managing the property.',
    `employee_id` BIGINT COMMENT 'Reference to the internal asset manager or team responsible for executing this business plan and managing the property.',
    `property_id` BIGINT COMMENT 'Reference to the directly held real estate property for which this business plan applies.',
    `capex_budget` DECIMAL(18,2) COMMENT 'Total capital expenditure budget allocated for the property during the plan year for value creation and asset improvement initiatives.',
    `capex_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the CAPEX budget amount.. Valid values are `^[A-Z]{3}$`',
    `capex_program_description` STRING COMMENT 'Detailed narrative of planned capital improvement projects and programs for the plan year, including scope, objectives, and expected value creation.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this asset business plan record was first created in the system.',
    `disposition_consideration_flag` BOOLEAN COMMENT 'Indicates whether the property is under consideration for potential disposition or sale during or following the plan year.',
    `energy_efficiency_target` DECIMAL(10,2) COMMENT 'Target percentage improvement in energy efficiency for the property during the plan year, measured in kilowatt-hours per square foot or similar metric.',
    `esg_initiatives` STRING COMMENT 'Description of planned ESG initiatives for the property during the plan year, including energy efficiency upgrades, sustainability certifications, and responsible investment stewardship activities.',
    `ghg_reduction_target` DECIMAL(10,2) COMMENT 'Target percentage reduction in greenhouse gas emissions for the property during the plan year, aligned with ESG and climate commitments.',
    `ic_approval_date` DATE COMMENT 'Date when the Investment Committee formally approved this asset business plan.',
    `ic_meeting_reference` STRING COMMENT 'Reference identifier for the IC meeting at which this business plan was reviewed and approved.',
    `lease_expiry_sqft` DECIMAL(12,2) COMMENT 'Total square footage of leases expiring during the plan year, representing rollover risk and re-leasing opportunity.',
    `leasing_strategy` STRING COMMENT 'Narrative description of the leasing strategy for the plan year, including target tenant profiles, rental rate objectives, lease term preferences, and tenant retention initiatives.',
    `major_capex_projects` STRING COMMENT 'List or description of major capital projects planned for execution during the plan year, such as renovations, system upgrades, or repositioning initiatives.',
    `market_outlook` STRING COMMENT 'Assessment of the local real estate market conditions and outlook for the plan year, including supply-demand dynamics, rental rate trends, and competitive positioning.',
    `new_leasing_target_sqft` DECIMAL(12,2) COMMENT 'Target square footage of new leasing activity planned for vacant or expiring space during the plan year.',
    `operating_expense_budget` DECIMAL(18,2) COMMENT 'Total operating expense budget for the property during the plan year, covering property management, maintenance, utilities, taxes, and insurance.',
    `plan_approved_by` STRING COMMENT 'Name or identifier of the Investment Committee member or executive who formally approved this asset business plan.',
    `plan_effective_date` DATE COMMENT 'Date from which this asset business plan becomes operationally effective and guides asset management activities.',
    `plan_expiry_date` DATE COMMENT 'Date when this asset business plan expires and is superseded by the next annual plan.',
    `plan_notes` STRING COMMENT 'Additional notes, comments, or context regarding the asset business plan, including assumptions, dependencies, or special considerations.',
    `plan_prepared_by` STRING COMMENT 'Name or identifier of the individual or team who prepared this asset business plan.',
    `plan_status` STRING COMMENT 'Current lifecycle status of the asset business plan within the approval and execution workflow.. Valid values are `draft|submitted|approved|active|revised|superseded`',
    `plan_version` STRING COMMENT 'Version number of the business plan, allowing for revisions and updates throughout the year.. Valid values are `^[0-9]+.[0-9]+$`',
    `plan_year` BIGINT COMMENT 'Calendar year for which this asset business plan is prepared and approved.',
    `property_manager_name` STRING COMMENT 'Name of the external property management firm or internal team responsible for day-to-day property operations during the plan year.',
    `renewal_target_rate` DECIMAL(5,2) COMMENT 'Target percentage of expiring leases planned to be renewed with existing tenants during the plan year.',
    `risk_factors` STRING COMMENT 'Identified risk factors and mitigation strategies for the property during the plan year, including market risks, tenant concentration, lease rollover, and operational risks.',
    `submission_date` DATE COMMENT 'Date when the business plan was formally submitted to the Investment Committee (IC) for review and approval.',
    `target_average_rent_psf` DECIMAL(10,2) COMMENT 'Planned average rental rate per square foot for the property, reflecting market positioning and leasing strategy.',
    `target_exit_date` DATE COMMENT 'Planned or target date for disposition of the property if disposition is under consideration.',
    `target_gav` DECIMAL(18,2) COMMENT 'Planned Gross Asset Value for the property at the end of the plan year, reflecting expected value appreciation from asset management activities.',
    `target_irr` DECIMAL(5,2) COMMENT 'Target Internal Rate of Return percentage for the property over the investment holding period, reflecting long-term risk-adjusted return objectives.',
    `target_nav` DECIMAL(18,2) COMMENT 'Planned Net Asset Value for the property at the end of the plan year, net of outstanding debt and liabilities.',
    `target_noi` DECIMAL(18,2) COMMENT 'Planned Net Operating Income target for the property during the plan year, representing the strategic income objective.',
    `target_noi_currency` STRING COMMENT 'Three-letter ISO 4217 currency code for the target NOI amount.. Valid values are `^[A-Z]{3}$`',
    `target_occupancy_rate` DECIMAL(5,2) COMMENT 'Planned occupancy rate percentage for the property during the plan year, reflecting leasing strategy goals.',
    `target_tenant_profile` STRING COMMENT 'Description of the ideal tenant characteristics and industry sectors targeted for new leasing activity during the plan year.',
    `tenant_incentive_budget` DECIMAL(18,2) COMMENT 'Budgeted amount allocated for tenant incentives including free rent periods, tenant improvement allowances, and leasing commissions.',
    `updated_timestamp` TIMESTAMP COMMENT 'Timestamp when this asset business plan record was last modified or updated.',
    `value_creation_strategy` STRING COMMENT 'Strategic narrative describing post-acquisition active asset management initiatives planned to unlock operational efficiency and sustainable value during the plan year.',
    CONSTRAINT pk_asset_business_plan PRIMARY KEY(`asset_business_plan_id`)
) COMMENT 'Annual asset business plan records for each directly held property, capturing the strategic asset management plan approved by the investment committee. Includes target NOI for the plan year, leasing strategy (target tenants, target rents, incentive';

CREATE OR REPLACE TABLE `asset_management`.`realestate`.`property_allocation` (
    `property_allocation_id` BIGINT COMMENT 'Unique identifier for the property allocation record',
    `portfolio_id` BIGINT COMMENT 'Foreign key linking to the investment portfolio that holds an ownership stake in the property',
    `property_id` BIGINT COMMENT 'Foreign key linking to the direct real estate property asset',
    `allocation_strategy` STRING COMMENT 'The investment strategy classification for this allocation, indicating whether it aligns with Strategic Asset Allocation (SAA), Tactical Asset Allocation (TAA), or other investment mandates',
    `effective_date` DATE COMMENT 'The date when this portfolios ownership stake in the property became effective',
    `ownership_percentage` DECIMAL(8,4) COMMENT 'The percentage of property ownership held by this portfolio. Sum of all portfolio allocations for a property should equal 100%.',
    `termination_date` DATE COMMENT 'The date when this portfolios ownership stake in the property ended. Null for active allocations.',
    CONSTRAINT pk_property_allocation PRIMARY KEY(`property_allocation_id`)
) COMMENT 'This association product represents the allocation of direct real estate property ownership across investment portfolios. It captures the ownership stake, effective period, and allocation strategy for each portfolio-property combination.';

CREATE OR REPLACE TABLE `asset_management`.`realestate`.`budget_line_item` (
    `budget_line_item_id` BIGINT COMMENT 'Primary key for budget_line_item',
    `employee_id` BIGINT COMMENT 'Reference to the user who approved this budget line item.',
    `fund_id` BIGINT COMMENT 'Reference to the investment fund that owns the property associated with this budget item.',
    `project_investment_id` BIGINT COMMENT 'Reference to the capital project associated with this budget line item if applicable.',
    `property_id` BIGINT COMMENT 'Reference to the real estate property asset associated with this budget line item.',
    `realestate_capex_program_id` BIGINT COMMENT 'Reference to the parent budget document that contains this line item.',
    `vendor_id` BIGINT COMMENT 'Reference to the preferred or contracted vendor for this budget line item.',
    `actual_amount` DECIMAL(18,2) COMMENT 'Actual expenditure or revenue amount recorded against this budget line item.',
    `approval_date` DATE COMMENT 'Date when this budget line item received final approval.',
    `approval_status` STRING COMMENT 'Current status in the budget approval workflow for governance tracking.',
    `asset_class` STRING COMMENT 'Real estate asset class classification for portfolio-level budget analysis.',
    `budget_period_end_date` DATE COMMENT 'End date of the fiscal period covered by this budget line item.',
    `budget_period_start_date` DATE COMMENT 'Start date of the fiscal period covered by this budget line item.',
    `budgeted_amount` DECIMAL(18,2) COMMENT 'Originally approved budget amount for this line item in the base currency.',
    `budget_line_item_category` STRING COMMENT 'High-level classification of the budget line item for financial reporting and analysis purposes.',
    `committed_amount` DECIMAL(18,2) COMMENT 'Amount committed through purchase orders or contracts but not yet expensed.',
    `cost_center_code` STRING COMMENT 'Organizational cost center responsible for this budget line item expenditure or revenue.',
    `created_timestamp` TIMESTAMP COMMENT 'Timestamp when this budget line item record was initially created in the system.',
    `currency_code` STRING COMMENT 'ISO 4217 three-letter currency code for all monetary amounts in this line item.',
    `budget_line_item_description` STRING COMMENT 'Detailed narrative description of the budget line item purpose and scope.',
    `effective_date` DATE COMMENT 'Date when this budget line item becomes effective for financial planning purposes.',
    `expiration_date` DATE COMMENT 'Date when this budget line item expires or is no longer applicable.',
    `fiscal_quarter` STRING COMMENT 'Fiscal quarter designation for quarterly budget tracking and variance analysis.',
    `fiscal_year` BIGINT COMMENT 'Fiscal year to which this budget line item applies for annual planning and reporting.',
    `forecast_amount` DECIMAL(18,2) COMMENT 'Latest forecast amount for this line item based on current projections and trends.',
    `gl_account_code` STRING COMMENT 'General ledger account code for proper financial statement mapping and consolidation.',
    `investment_strategy` STRING COMMENT 'Investment strategy classification aligned with institutional real estate risk-return profiles.',
    `is_capital_expenditure` BOOLEAN COMMENT 'Indicates whether this line item represents a capital expenditure requiring capitalization.',
    `is_recoverable` BOOLEAN COMMENT 'Indicates whether this expense is recoverable from tenants under lease agreements.',
    `is_recurring` BOOLEAN COMMENT 'Indicates whether this budget line item represents a recurring expense or one-time cost.',
    `justification` STRING COMMENT 'Business justification narrative supporting the budget request for approval purposes.',
    `line_item_code` STRING COMMENT 'Standardized alphanumeric code identifying the budget line item category per institutional accounting standards.',
    `line_number` BIGINT COMMENT 'Sequential ordering number of this line item within the parent budget document.',
    `modified_timestamp` TIMESTAMP COMMENT 'Timestamp when this budget line item record was last modified.',
    `notes` STRING COMMENT 'Free-form notes and comments providing additional context for this budget line item.',
    `priority_level` STRING COMMENT 'Priority classification for capital allocation and expenditure sequencing decisions.',
    `quantity` DECIMAL(18,4) COMMENT 'Quantity of units budgeted for this line item when applicable.',
    `recovery_percentage` DECIMAL(5,2) COMMENT 'Percentage of the expense amount that can be recovered from tenants.',
    `recurrence_frequency` STRING COMMENT 'Frequency of recurring expenses for cash flow planning and forecasting.',
    `revised_amount` DECIMAL(18,2) COMMENT 'Current revised budget amount after any approved amendments or reforecasts.',
    `budget_line_item_status` STRING COMMENT 'Current lifecycle status of the budget line item in the approval workflow.',
    `subcategory` STRING COMMENT 'Detailed classification within the primary category for granular expense and revenue tracking.',
    `unit_cost` DECIMAL(18,4) COMMENT 'Cost per unit for quantity-based budget calculations and analysis.',
    `unit_of_measure` STRING COMMENT 'Unit of measurement for quantity-based budget items such as square footage or units.',
    `variance_amount` DECIMAL(18,2) COMMENT 'Difference between budgeted and actual amounts for variance analysis and reporting.',
    `variance_explanation` STRING COMMENT 'Explanation of significant variances between budgeted and actual amounts.',
    CONSTRAINT pk_budget_line_item PRIMARY KEY(`budget_line_item_id`)
) COMMENT 'Master reference table for budget_line_item. Referenced by budget_line_item_id.';

-- ========= FOREIGN KEYS =========
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ADD CONSTRAINT `fk_realestate_property_valuation_property_id` FOREIGN KEY (`property_id`) REFERENCES `asset_management`.`realestate`.`property`(`property_id`);
ALTER TABLE `asset_management`.`realestate`.`noi_record` ADD CONSTRAINT `fk_realestate_noi_record_property_id` FOREIGN KEY (`property_id`) REFERENCES `asset_management`.`realestate`.`property`(`property_id`);
ALTER TABLE `asset_management`.`realestate`.`lease` ADD CONSTRAINT `fk_realestate_lease_property_id` FOREIGN KEY (`property_id`) REFERENCES `asset_management`.`realestate`.`property`(`property_id`);
ALTER TABLE `asset_management`.`realestate`.`lease` ADD CONSTRAINT `fk_realestate_lease_tenant_id` FOREIGN KEY (`tenant_id`) REFERENCES `asset_management`.`realestate`.`tenant`(`tenant_id`);
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ADD CONSTRAINT `fk_realestate_lease_rent_schedule_lease_id` FOREIGN KEY (`lease_id`) REFERENCES `asset_management`.`realestate`.`lease`(`lease_id`);
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ADD CONSTRAINT `fk_realestate_lease_rent_schedule_property_id` FOREIGN KEY (`property_id`) REFERENCES `asset_management`.`realestate`.`property`(`property_id`);
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ADD CONSTRAINT `fk_realestate_rent_collection_lease_id` FOREIGN KEY (`lease_id`) REFERENCES `asset_management`.`realestate`.`lease`(`lease_id`);
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ADD CONSTRAINT `fk_realestate_rent_collection_property_id` FOREIGN KEY (`property_id`) REFERENCES `asset_management`.`realestate`.`property`(`property_id`);
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ADD CONSTRAINT `fk_realestate_rent_collection_tenant_id` FOREIGN KEY (`tenant_id`) REFERENCES `asset_management`.`realestate`.`tenant`(`tenant_id`);
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ADD CONSTRAINT `fk_realestate_realestate_capex_program_property_id` FOREIGN KEY (`property_id`) REFERENCES `asset_management`.`realestate`.`property`(`property_id`);
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ADD CONSTRAINT `fk_realestate_capex_expenditure_budget_line_item_id` FOREIGN KEY (`budget_line_item_id`) REFERENCES `asset_management`.`realestate`.`budget_line_item`(`budget_line_item_id`);
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ADD CONSTRAINT `fk_realestate_capex_expenditure_property_id` FOREIGN KEY (`property_id`) REFERENCES `asset_management`.`realestate`.`property`(`property_id`);
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ADD CONSTRAINT `fk_realestate_capex_expenditure_realestate_capex_program_id` FOREIGN KEY (`realestate_capex_program_id`) REFERENCES `asset_management`.`realestate`.`realestate_capex_program`(`realestate_capex_program_id`);
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ADD CONSTRAINT `fk_realestate_realestate_debt_facility_property_id` FOREIGN KEY (`property_id`) REFERENCES `asset_management`.`realestate`.`property`(`property_id`);
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ADD CONSTRAINT `fk_realestate_ltv_dscr_covenant_property_id` FOREIGN KEY (`property_id`) REFERENCES `asset_management`.`realestate`.`property`(`property_id`);
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ADD CONSTRAINT `fk_realestate_ltv_dscr_covenant_realestate_debt_facility_id` FOREIGN KEY (`realestate_debt_facility_id`) REFERENCES `asset_management`.`realestate`.`realestate_debt_facility`(`realestate_debt_facility_id`);
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ADD CONSTRAINT `fk_realestate_re_capital_call_re_fund_commitment_id` FOREIGN KEY (`re_fund_commitment_id`) REFERENCES `asset_management`.`realestate`.`re_fund_commitment`(`re_fund_commitment_id`);
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ADD CONSTRAINT `fk_realestate_re_distribution_re_fund_commitment_id` FOREIGN KEY (`re_fund_commitment_id`) REFERENCES `asset_management`.`realestate`.`re_fund_commitment`(`re_fund_commitment_id`);
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ADD CONSTRAINT `fk_realestate_re_distribution_underlying_property_id` FOREIGN KEY (`underlying_property_id`) REFERENCES `asset_management`.`realestate`.`property`(`property_id`);
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ADD CONSTRAINT `fk_realestate_property_acquisition_property_id` FOREIGN KEY (`property_id`) REFERENCES `asset_management`.`realestate`.`property`(`property_id`);
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ADD CONSTRAINT `fk_realestate_property_disposal_property_id` FOREIGN KEY (`property_id`) REFERENCES `asset_management`.`realestate`.`property`(`property_id`);
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ADD CONSTRAINT `fk_realestate_occupancy_record_property_id` FOREIGN KEY (`property_id`) REFERENCES `asset_management`.`realestate`.`property`(`property_id`);
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ADD CONSTRAINT `fk_realestate_property_operating_expense_noi_record_id` FOREIGN KEY (`noi_record_id`) REFERENCES `asset_management`.`realestate`.`noi_record`(`noi_record_id`);
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ADD CONSTRAINT `fk_realestate_property_operating_expense_property_id` FOREIGN KEY (`property_id`) REFERENCES `asset_management`.`realestate`.`property`(`property_id`);
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ADD CONSTRAINT `fk_realestate_property_operating_expense_realestate_capex_program_id` FOREIGN KEY (`realestate_capex_program_id`) REFERENCES `asset_management`.`realestate`.`realestate_capex_program`(`realestate_capex_program_id`);
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ADD CONSTRAINT `fk_realestate_jv_structure_property_id` FOREIGN KEY (`property_id`) REFERENCES `asset_management`.`realestate`.`property`(`property_id`);
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ADD CONSTRAINT `fk_realestate_property_insurance_property_id` FOREIGN KEY (`property_id`) REFERENCES `asset_management`.`realestate`.`property`(`property_id`);
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ADD CONSTRAINT `fk_realestate_esg_property_assessment_property_id` FOREIGN KEY (`property_id`) REFERENCES `asset_management`.`realestate`.`property`(`property_id`);
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ADD CONSTRAINT `fk_realestate_asset_business_plan_property_id` FOREIGN KEY (`property_id`) REFERENCES `asset_management`.`realestate`.`property`(`property_id`);
ALTER TABLE `asset_management`.`realestate`.`property_allocation` ADD CONSTRAINT `fk_realestate_property_allocation_property_id` FOREIGN KEY (`property_id`) REFERENCES `asset_management`.`realestate`.`property`(`property_id`);
ALTER TABLE `asset_management`.`realestate`.`budget_line_item` ADD CONSTRAINT `fk_realestate_budget_line_item_property_id` FOREIGN KEY (`property_id`) REFERENCES `asset_management`.`realestate`.`property`(`property_id`);
ALTER TABLE `asset_management`.`realestate`.`budget_line_item` ADD CONSTRAINT `fk_realestate_budget_line_item_realestate_capex_program_id` FOREIGN KEY (`realestate_capex_program_id`) REFERENCES `asset_management`.`realestate`.`realestate_capex_program`(`realestate_capex_program_id`);

-- ========= TAGS =========
ALTER TABLE `asset_management`.`realestate`.`property` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`realestate`.`property` SET TAGS ('dbx_domain' = 'realestate');
ALTER TABLE `asset_management`.`realestate`.`property` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`realestate`.`property` SET TAGS ('dbx_subdomain' = 'asset_operations');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `property_id` SET TAGS ('dbx_business_glossary_term' = 'Property Identifier');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `acquisition_date` SET TAGS ('dbx_business_glossary_term' = 'Acquisition Date');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `acquisition_price` SET TAGS ('dbx_business_glossary_term' = 'Acquisition Price');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `acquisition_price` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `asset_class` SET TAGS ('dbx_value_regex' = 'commercial_office|industrial_logistics|retail|residential|mixed_use|specialty');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `cap_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Capitalization Rate (Percent)');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `capex_budget_annual` SET TAGS ('dbx_business_glossary_term' = 'Capital Expenditure (CapEx) Budget Annual');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `capex_budget_annual` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `city` SET TAGS ('dbx_business_glossary_term' = 'City');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `property_code` SET TAGS ('dbx_business_glossary_term' = 'Property Code');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `country_code` SET TAGS ('dbx_business_glossary_term' = 'Country Code');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `disposition_date` SET TAGS ('dbx_business_glossary_term' = 'Disposition Date');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `disposition_price` SET TAGS ('dbx_business_glossary_term' = 'Disposition Price');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `disposition_price` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `dscr` SET TAGS ('dbx_business_glossary_term' = 'Debt Service Coverage Ratio (DSCR)');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `energy_consumption_kwh_annual` SET TAGS ('dbx_business_glossary_term' = 'Energy Consumption (Kilowatt-Hours Annual)');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `esg_certification` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Certification');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `gav` SET TAGS ('dbx_business_glossary_term' = 'Gross Asset Value (GAV)');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `gav` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `ghg_emissions_tonnes_co2e_annual` SET TAGS ('dbx_business_glossary_term' = 'Greenhouse Gas (GHG) Emissions (Tonnes CO2e Annual)');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `gross_leasable_area_sqft` SET TAGS ('dbx_business_glossary_term' = 'Gross Leasable Area (Square Feet)');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `investment_strategy` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `investment_strategy` SET TAGS ('dbx_value_regex' = 'core|core_plus|value_add|opportunistic');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `land_area_acres` SET TAGS ('dbx_business_glossary_term' = 'Land Area (Acres)');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `latitude` SET TAGS ('dbx_business_glossary_term' = 'Latitude');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `latitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `latitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `legal_entity_identifier` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `legal_entity_identifier` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `lifecycle_status` SET TAGS ('dbx_business_glossary_term' = 'Lifecycle Status');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `lifecycle_status` SET TAGS ('dbx_value_regex' = 'active|under_construction|under_renovation|stabilized|held_for_sale|disposed');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `longitude` SET TAGS ('dbx_business_glossary_term' = 'Longitude');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `longitude` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `longitude` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `ltv_ratio_percent` SET TAGS ('dbx_business_glossary_term' = 'Loan-to-Value (LTV) Ratio (Percent)');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `manager_name` SET TAGS ('dbx_business_glossary_term' = 'Property Manager Name');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `property_name` SET TAGS ('dbx_business_glossary_term' = 'Property Name');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `nav` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV)');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `nav` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `noi_annual` SET TAGS ('dbx_business_glossary_term' = 'Net Operating Income (NOI) Annual');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `noi_annual` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `occupancy_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Occupancy Rate (Percent)');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `outstanding_debt` SET TAGS ('dbx_business_glossary_term' = 'Outstanding Debt');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `outstanding_debt` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `ownership_percentage` SET TAGS ('dbx_business_glossary_term' = 'Ownership Percentage');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `ownership_structure` SET TAGS ('dbx_business_glossary_term' = 'Ownership Structure');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `ownership_structure` SET TAGS ('dbx_value_regex' = 'direct|joint_venture|fund_investment|reit');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `postal_code` SET TAGS ('dbx_business_glossary_term' = 'Postal Code');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `property_type` SET TAGS ('dbx_business_glossary_term' = 'Property Type');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `state_province` SET TAGS ('dbx_business_glossary_term' = 'State or Province');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `state_province` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `state_province` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `street_address` SET TAGS ('dbx_business_glossary_term' = 'Street Address');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `street_address` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `street_address` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `tax_parcel_number` SET TAGS ('dbx_business_glossary_term' = 'Tax Parcel Identifier');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `valuation_method` SET TAGS ('dbx_value_regex' = 'income_capitalization|discounted_cash_flow|sales_comparison|cost_approach');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `water_consumption_cubic_meters_annual` SET TAGS ('dbx_business_glossary_term' = 'Water Consumption (Cubic Meters Annual)');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `year_built` SET TAGS ('dbx_business_glossary_term' = 'Year Built');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `year_renovated` SET TAGS ('dbx_business_glossary_term' = 'Year Renovated');
ALTER TABLE `asset_management`.`realestate`.`property` ALTER COLUMN `zoning_classification` SET TAGS ('dbx_business_glossary_term' = 'Zoning Classification');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` SET TAGS ('dbx_domain' = 'realestate');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` SET TAGS ('dbx_subdomain' = 'asset_operations');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `property_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Property Valuation Identifier (ID)');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `cycle_id` SET TAGS ('dbx_business_glossary_term' = 'Cycle Id (Foreign Key)');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `property_id` SET TAGS ('dbx_business_glossary_term' = 'Property Identifier (ID)');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `valuation_asset_valuation_id` SET TAGS ('dbx_business_glossary_term' = 'Valuation Asset Valuation Id (Foreign Key)');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `appraiser_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Appraiser Contact Name');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `appraiser_contact_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `appraiser_firm_name` SET TAGS ('dbx_business_glossary_term' = 'Appraiser Firm Name');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `appraiser_license_number` SET TAGS ('dbx_business_glossary_term' = 'Appraiser License Number');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `approved_by` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `cap_rate` SET TAGS ('dbx_business_glossary_term' = 'Capitalization Rate (Cap Rate)');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `comparable_sales_count` SET TAGS ('dbx_business_glossary_term' = 'Comparable Sales Count');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `deferred_maintenance_estimate` SET TAGS ('dbx_business_glossary_term' = 'Deferred Maintenance Estimate');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `discount_rate` SET TAGS ('dbx_business_glossary_term' = 'Discount Rate');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `environmental_risk_description` SET TAGS ('dbx_business_glossary_term' = 'Environmental Risk Description');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `environmental_risk_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Risk Flag');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `gav` SET TAGS ('dbx_business_glossary_term' = 'Gross Asset Value (GAV)');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `highest_best_use` SET TAGS ('dbx_business_glossary_term' = 'Highest and Best Use');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `inspection_date` SET TAGS ('dbx_business_glossary_term' = 'Property Inspection Date');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `market_liquidity_assessment` SET TAGS ('dbx_business_glossary_term' = 'Market Liquidity Assessment');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `market_liquidity_assessment` SET TAGS ('dbx_value_regex' = 'highly_liquid|liquid|moderate|illiquid|highly_illiquid');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `market_rent_psf` SET TAGS ('dbx_business_glossary_term' = 'Market Rent Per Square Foot (PSF)');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `nav` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV)');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `noi` SET TAGS ('dbx_business_glossary_term' = 'Net Operating Income (NOI)');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `prior_valuation_amount` SET TAGS ('dbx_business_glossary_term' = 'Prior Valuation Amount');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `prior_valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Prior Valuation Date');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `property_condition_rating` SET TAGS ('dbx_business_glossary_term' = 'Property Condition Rating');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `property_condition_rating` SET TAGS ('dbx_value_regex' = 'excellent|good|average|fair|poor');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `stabilized_occupancy_rate` SET TAGS ('dbx_business_glossary_term' = 'Stabilized Occupancy Rate');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `terminal_cap_rate` SET TAGS ('dbx_business_glossary_term' = 'Terminal Capitalization Rate (Terminal Cap Rate)');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `valuation_basis` SET TAGS ('dbx_business_glossary_term' = 'Valuation Basis');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `valuation_basis` SET TAGS ('dbx_value_regex' = 'market_value|fair_value|investment_value|liquidation_value|insurance_value');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `valuation_confidence_level` SET TAGS ('dbx_business_glossary_term' = 'Valuation Confidence Level');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `valuation_confidence_level` SET TAGS ('dbx_value_regex' = 'high|medium|low');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `valuation_currency` SET TAGS ('dbx_business_glossary_term' = 'Valuation Currency Code');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `valuation_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `valuation_methodology` SET TAGS ('dbx_business_glossary_term' = 'Valuation Methodology');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `valuation_methodology` SET TAGS ('dbx_value_regex' = 'income_approach|sales_comparison|cost_approach|dcf|residual_method|hybrid');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `valuation_notes` SET TAGS ('dbx_business_glossary_term' = 'Valuation Notes');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `valuation_purpose` SET TAGS ('dbx_business_glossary_term' = 'Valuation Purpose');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `valuation_purpose` SET TAGS ('dbx_value_regex' = 'acquisition|portfolio_reporting|financial_reporting|loan_collateral|disposition|regulatory_compliance');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `valuation_report_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Report Date');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `valuation_report_reference` SET TAGS ('dbx_business_glossary_term' = 'Valuation Report Reference Number');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `valuation_status` SET TAGS ('dbx_business_glossary_term' = 'Valuation Status');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `valuation_status` SET TAGS ('dbx_value_regex' = 'draft|under_review|approved|final|superseded|rejected');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `valuation_type` SET TAGS ('dbx_business_glossary_term' = 'Valuation Type');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `valuation_type` SET TAGS ('dbx_value_regex' = 'full_appraisal|desktop_review|automated_valuation|broker_opinion|internal_assessment|annual_revaluation');
ALTER TABLE `asset_management`.`realestate`.`property_valuation` ALTER COLUMN `valuation_variance_pct` SET TAGS ('dbx_business_glossary_term' = 'Valuation Variance Percentage');
ALTER TABLE `asset_management`.`realestate`.`noi_record` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`realestate`.`noi_record` SET TAGS ('dbx_domain' = 'realestate');
ALTER TABLE `asset_management`.`realestate`.`noi_record` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`realestate`.`noi_record` SET TAGS ('dbx_subdomain' = 'asset_operations');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `noi_record_id` SET TAGS ('dbx_business_glossary_term' = 'Net Operating Income (NOI) Record Identifier');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `property_id` SET TAGS ('dbx_business_glossary_term' = 'Property Identifier');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `administrative_expense` SET TAGS ('dbx_business_glossary_term' = 'Administrative Expense');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `approved_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Approved Timestamp');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `calculation_method` SET TAGS ('dbx_business_glossary_term' = 'Calculation Method');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `calculation_method` SET TAGS ('dbx_value_regex' = 'cash_basis|accrual_basis');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `capitalization_rate` SET TAGS ('dbx_business_glossary_term' = 'Capitalization Rate (Cap Rate)');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `concessions_amount` SET TAGS ('dbx_business_glossary_term' = 'Concessions Amount');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `credit_loss` SET TAGS ('dbx_business_glossary_term' = 'Credit Loss');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `effective_gross_income` SET TAGS ('dbx_business_glossary_term' = 'Effective Gross Income (EGI)');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `gross_potential_rent` SET TAGS ('dbx_business_glossary_term' = 'Gross Potential Rent (GPR)');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `insurance_expense` SET TAGS ('dbx_business_glossary_term' = 'Insurance Expense');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `legal_professional_fees` SET TAGS ('dbx_business_glossary_term' = 'Legal and Professional Fees');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `marketing_leasing_expense` SET TAGS ('dbx_business_glossary_term' = 'Marketing and Leasing Expense');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `net_operating_income` SET TAGS ('dbx_business_glossary_term' = 'Net Operating Income (NOI)');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `noi_margin_percent` SET TAGS ('dbx_business_glossary_term' = 'Net Operating Income (NOI) Margin Percentage');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `noi_status` SET TAGS ('dbx_business_glossary_term' = 'Net Operating Income (NOI) Status');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `noi_status` SET TAGS ('dbx_value_regex' = 'draft|preliminary|final|revised|audited');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `occupancy_rate_percent` SET TAGS ('dbx_business_glossary_term' = 'Occupancy Rate Percentage');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `other_income` SET TAGS ('dbx_business_glossary_term' = 'Other Income');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `other_operating_expenses` SET TAGS ('dbx_business_glossary_term' = 'Other Operating Expenses');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `payroll_expense` SET TAGS ('dbx_business_glossary_term' = 'Payroll Expense');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `property_management_fee` SET TAGS ('dbx_business_glossary_term' = 'Property Management Fee');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `property_taxes` SET TAGS ('dbx_business_glossary_term' = 'Property Taxes');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `repairs_maintenance_expense` SET TAGS ('dbx_business_glossary_term' = 'Repairs and Maintenance Expense');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_business_glossary_term' = 'Reporting Frequency');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|annual');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `reporting_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period End Date');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `reporting_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period Start Date');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `total_operating_expenses` SET TAGS ('dbx_business_glossary_term' = 'Total Operating Expenses');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `utilities_expense` SET TAGS ('dbx_business_glossary_term' = 'Utilities Expense');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `vacancy_loss` SET TAGS ('dbx_business_glossary_term' = 'Vacancy Loss');
ALTER TABLE `asset_management`.`realestate`.`noi_record` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`realestate`.`lease` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`realestate`.`lease` SET TAGS ('dbx_domain' = 'realestate');
ALTER TABLE `asset_management`.`realestate`.`lease` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`realestate`.`lease` SET TAGS ('dbx_subdomain' = 'leasing_tenancy');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `lease_id` SET TAGS ('dbx_business_glossary_term' = 'Lease Identifier (ID)');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `actor_id` SET TAGS ('dbx_business_glossary_term' = 'Guarantor Identifier (ID)');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `lease_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Guarantor Identifier (ID)');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `lease_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `lease_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `lease_property_manager_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Property Manager Identifier (ID)');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `lease_property_manager_employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `lease_property_manager_employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `property_id` SET TAGS ('dbx_business_glossary_term' = 'Property Identifier (ID)');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `property_manager_actor_id` SET TAGS ('dbx_business_glossary_term' = 'Property Manager Identifier (ID)');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `tenant_id` SET TAGS ('dbx_business_glossary_term' = 'Tenant Identifier (ID)');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `assignment_sublease_rights` SET TAGS ('dbx_business_glossary_term' = 'Assignment and Sublease Rights');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `assignment_sublease_rights` SET TAGS ('dbx_value_regex' = 'prohibited|permitted-with-consent|freely-assignable');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `base_rent_amount` SET TAGS ('dbx_business_glossary_term' = 'Base Rent Amount');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `commencement_date` SET TAGS ('dbx_business_glossary_term' = 'Lease Commencement Date');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code (ISO 4217)');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `document_uri` SET TAGS ('dbx_business_glossary_term' = 'Lease Document Uniform Resource Identifier (URI)');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `document_uri` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `escalation_frequency_months` SET TAGS ('dbx_business_glossary_term' = 'Escalation Frequency in Months');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `escalation_rate` SET TAGS ('dbx_business_glossary_term' = 'Rent Escalation Rate');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `escalation_type` SET TAGS ('dbx_business_glossary_term' = 'Rent Escalation Type');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `escalation_type` SET TAGS ('dbx_value_regex' = 'fixed|cpi|percentage|none');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `exclusivity_clause` SET TAGS ('dbx_business_glossary_term' = 'Exclusivity Clause Description');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `execution_date` SET TAGS ('dbx_business_glossary_term' = 'Lease Execution Date');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Lease Expiry Date');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `floor_number` SET TAGS ('dbx_business_glossary_term' = 'Leased Floor Number');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `free_rent_months` SET TAGS ('dbx_business_glossary_term' = 'Free Rent Period in Months');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `gla_square_feet` SET TAGS ('dbx_business_glossary_term' = 'Gross Leasable Area (GLA) in Square Feet');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `lease_status` SET TAGS ('dbx_business_glossary_term' = 'Lease Lifecycle Status');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `lease_status` SET TAGS ('dbx_value_regex' = 'draft|active|expired|terminated|renewed|holdover');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `lease_type` SET TAGS ('dbx_business_glossary_term' = 'Lease Type Classification');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `lease_type` SET TAGS ('dbx_value_regex' = 'gross|net|triple-net|modified-gross|percentage|ground');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Lease Agreement Notes');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `number` SET TAGS ('dbx_business_glossary_term' = 'Lease Agreement Number');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `operating_expense_recovery_type` SET TAGS ('dbx_business_glossary_term' = 'Operating Expense Recovery Type');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `operating_expense_recovery_type` SET TAGS ('dbx_value_regex' = 'base-year|expense-stop|pro-rata|none');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `parking_rent_amount` SET TAGS ('dbx_business_glossary_term' = 'Parking Rent Amount');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `parking_spaces_count` SET TAGS ('dbx_business_glossary_term' = 'Parking Spaces Count');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `percentage_rent_breakpoint` SET TAGS ('dbx_business_glossary_term' = 'Percentage Rent Breakpoint Amount');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `percentage_rent_flag` SET TAGS ('dbx_business_glossary_term' = 'Percentage Rent Flag');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `percentage_rent_rate` SET TAGS ('dbx_business_glossary_term' = 'Percentage Rent Rate');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `possession_date` SET TAGS ('dbx_business_glossary_term' = 'Tenant Possession Date');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `renewal_notice_days` SET TAGS ('dbx_business_glossary_term' = 'Renewal Notice Period in Days');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `renewal_option_count` SET TAGS ('dbx_business_glossary_term' = 'Renewal Option Count');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `renewal_option_term_months` SET TAGS ('dbx_business_glossary_term' = 'Renewal Option Term in Months');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `rent_commencement_date` SET TAGS ('dbx_business_glossary_term' = 'Rent Commencement Date');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `rent_payment_frequency` SET TAGS ('dbx_business_glossary_term' = 'Rent Payment Frequency');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `rent_payment_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|annually|semi-annually');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `rent_per_square_foot` SET TAGS ('dbx_business_glossary_term' = 'Rent Per Square Foot');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `security_deposit_amount` SET TAGS ('dbx_business_glossary_term' = 'Security Deposit Amount');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `suite_number` SET TAGS ('dbx_business_glossary_term' = 'Leased Suite Number');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `tenant_improvement_allowance` SET TAGS ('dbx_business_glossary_term' = 'Tenant Improvement (TI) Allowance');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `term_months` SET TAGS ('dbx_business_glossary_term' = 'Lease Term Duration in Months');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `termination_notice_days` SET TAGS ('dbx_business_glossary_term' = 'Termination Notice Period in Days');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `termination_option_flag` SET TAGS ('dbx_business_glossary_term' = 'Termination Option Flag');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `termination_penalty_amount` SET TAGS ('dbx_business_glossary_term' = 'Termination Penalty Amount');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`realestate`.`lease` ALTER COLUMN `use_clause` SET TAGS ('dbx_business_glossary_term' = 'Permitted Use Clause');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` SET TAGS ('dbx_domain' = 'realestate');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` SET TAGS ('dbx_subdomain' = 'leasing_tenancy');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `lease_rent_schedule_id` SET TAGS ('dbx_business_glossary_term' = 'Lease Rent Schedule ID');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `lease_id` SET TAGS ('dbx_business_glossary_term' = 'Lease ID');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `property_id` SET TAGS ('dbx_business_glossary_term' = 'Property ID');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `abatement_amount` SET TAGS ('dbx_business_glossary_term' = 'Abatement Amount');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `accounting_period` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `accounting_period` SET TAGS ('dbx_value_regex' = '^d{4}-d{2}$');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `actual_payment_amount` SET TAGS ('dbx_business_glossary_term' = 'Actual Payment Amount');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `actual_payment_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Payment Date');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `base_rent_amount` SET TAGS ('dbx_business_glossary_term' = 'Base Rent Amount');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `cpi_adjusted_amount` SET TAGS ('dbx_business_glossary_term' = 'Consumer Price Index (CPI) Adjusted Amount');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `cpi_adjustment_factor` SET TAGS ('dbx_business_glossary_term' = 'Consumer Price Index (CPI) Adjustment Factor');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `cumulative_rent_to_date` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Rent To Date');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `effective_rent_per_sqft` SET TAGS ('dbx_business_glossary_term' = 'Effective Rent Per Square Foot');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `escalation_amount` SET TAGS ('dbx_business_glossary_term' = 'Escalation Amount');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `escalation_rate` SET TAGS ('dbx_business_glossary_term' = 'Escalation Rate');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `escalation_type` SET TAGS ('dbx_business_glossary_term' = 'Escalation Type');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `escalation_type` SET TAGS ('dbx_value_regex' = 'fixed|cpi|percentage|hybrid|none');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `free_rent_flag` SET TAGS ('dbx_business_glossary_term' = 'Free Rent Flag');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `lease_modification_flag` SET TAGS ('dbx_business_glossary_term' = 'Lease Modification Flag');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `modification_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Modification Effective Date');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `noi_contribution` SET TAGS ('dbx_business_glossary_term' = 'Net Operating Income (NOI) Contribution');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `operating_expense_recovery` SET TAGS ('dbx_business_glossary_term' = 'Operating Expense Recovery');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `other_charges_amount` SET TAGS ('dbx_business_glossary_term' = 'Other Charges Amount');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `payment_due_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Due Date');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_business_glossary_term' = 'Payment Frequency');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi-annually|annually');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `payment_status` SET TAGS ('dbx_business_glossary_term' = 'Payment Status');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `payment_status` SET TAGS ('dbx_value_regex' = 'scheduled|paid|overdue|waived|disputed|partial');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `percentage_rent_amount` SET TAGS ('dbx_business_glossary_term' = 'Percentage Rent Amount');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Period End Date');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `period_sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Period Sequence Number');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Period Start Date');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `rent_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Rent Currency Code');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `rent_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `rent_type` SET TAGS ('dbx_business_glossary_term' = 'Rent Type');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `rent_type` SET TAGS ('dbx_value_regex' = 'gross|net|modified_gross|triple_net');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `straight_line_rent_amount` SET TAGS ('dbx_business_glossary_term' = 'Straight-Line Rent Amount');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `tax_recovery_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Recovery Amount');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `total_rent_amount` SET TAGS ('dbx_business_glossary_term' = 'Total Rent Amount');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`realestate`.`lease_rent_schedule` ALTER COLUMN `variance_amount` SET TAGS ('dbx_business_glossary_term' = 'Variance Amount');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` SET TAGS ('dbx_domain' = 'realestate');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` SET TAGS ('dbx_subdomain' = 'leasing_tenancy');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `rent_collection_id` SET TAGS ('dbx_business_glossary_term' = 'Rent Collection ID');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `actor_id` SET TAGS ('dbx_business_glossary_term' = 'Collection Agent ID');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Bank Account ID');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Collection Agent ID');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `lease_id` SET TAGS ('dbx_business_glossary_term' = 'Lease ID');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `property_id` SET TAGS ('dbx_business_glossary_term' = 'Property ID');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `tenant_id` SET TAGS ('dbx_business_glossary_term' = 'Tenant ID');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `adjustment_amount` SET TAGS ('dbx_business_glossary_term' = 'Adjustment Amount');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `arrears_balance` SET TAGS ('dbx_business_glossary_term' = 'Arrears Balance');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `billing_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Billing Period End Date');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `billing_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Billing Period Start Date');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `collection_notes` SET TAGS ('dbx_business_glossary_term' = 'Collection Notes');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `collection_status` SET TAGS ('dbx_business_glossary_term' = 'Collection Status');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `collection_status` SET TAGS ('dbx_value_regex' = 'paid_full|paid_partial|unpaid|overdue|disputed|written_off');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `days_overdue` SET TAGS ('dbx_business_glossary_term' = 'Days Overdue');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `discount_amount` SET TAGS ('dbx_business_glossary_term' = 'Discount Amount');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `dispute_flag` SET TAGS ('dbx_business_glossary_term' = 'Dispute Flag');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `dispute_reason` SET TAGS ('dbx_business_glossary_term' = 'Dispute Reason');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `due_date` SET TAGS ('dbx_business_glossary_term' = 'Due Date');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `invoice_date` SET TAGS ('dbx_business_glossary_term' = 'Invoice Date');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `invoice_number` SET TAGS ('dbx_business_glossary_term' = 'Invoice Number');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `invoiced_amount` SET TAGS ('dbx_business_glossary_term' = 'Invoiced Amount');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `late_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Late Fee Amount');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `net_amount_due` SET TAGS ('dbx_business_glossary_term' = 'Net Amount Due');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `noi_contribution` SET TAGS ('dbx_business_glossary_term' = 'Net Operating Income (NOI) Contribution');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `payment_channel` SET TAGS ('dbx_business_glossary_term' = 'Payment Channel');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `payment_channel` SET TAGS ('dbx_value_regex' = 'online_portal|mail|in_person|automated_clearing|lockbox');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'wire_transfer|ach|check|direct_debit|credit_card|cash');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `payment_received_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Received Date');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `payment_reference` SET TAGS ('dbx_business_glossary_term' = 'Payment Reference');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `received_amount` SET TAGS ('dbx_business_glossary_term' = 'Received Amount');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `reconciliation_date` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Date');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Status');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_value_regex' = 'pending|reconciled|exception|under_review');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Amount');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `tax_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Tax Jurisdiction');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `write_off_date` SET TAGS ('dbx_business_glossary_term' = 'Write-Off Date');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `write_off_flag` SET TAGS ('dbx_business_glossary_term' = 'Write-Off Flag');
ALTER TABLE `asset_management`.`realestate`.`rent_collection` ALTER COLUMN `write_off_reason` SET TAGS ('dbx_business_glossary_term' = 'Write-Off Reason');
ALTER TABLE `asset_management`.`realestate`.`tenant` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`realestate`.`tenant` SET TAGS ('dbx_domain' = 'realestate');
ALTER TABLE `asset_management`.`realestate`.`tenant` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`realestate`.`tenant` SET TAGS ('dbx_subdomain' = 'leasing_tenancy');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `tenant_id` SET TAGS ('dbx_business_glossary_term' = 'Tenant Identifier (ID)');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `aml_screening_date` SET TAGS ('dbx_business_glossary_term' = 'Anti-Money Laundering (AML) Screening Date');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `aml_status` SET TAGS ('dbx_business_glossary_term' = 'Anti-Money Laundering (AML) Status');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `aml_status` SET TAGS ('dbx_value_regex' = 'cleared|flagged|under_review|blocked');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `anchor_tenant_flag` SET TAGS ('dbx_business_glossary_term' = 'Anchor Tenant Flag');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `annual_revenue_amount` SET TAGS ('dbx_business_glossary_term' = 'Annual Revenue Amount');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `annual_revenue_amount` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `annual_revenue_currency` SET TAGS ('dbx_business_glossary_term' = 'Annual Revenue Currency Code');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `annual_revenue_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `business_registration_number` SET TAGS ('dbx_business_glossary_term' = 'Business Registration Number');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `credit_rating` SET TAGS ('dbx_business_glossary_term' = 'Tenant Credit Rating');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `credit_rating_agency` SET TAGS ('dbx_business_glossary_term' = 'Credit Rating Agency');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `credit_rating_agency` SET TAGS ('dbx_value_regex' = 'S&P|Moodys|Fitch|DBRS|NR');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `credit_rating_date` SET TAGS ('dbx_business_glossary_term' = 'Credit Rating Date');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `employee_count` SET TAGS ('dbx_business_glossary_term' = 'Employee Count');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `employee_count` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `esg_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Rating');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `esg_rating_date` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Rating Date');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `esg_rating_provider` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Rating Provider');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `headquarters_address_line1` SET TAGS ('dbx_business_glossary_term' = 'Headquarters Address Line 1');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `headquarters_address_line1` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `headquarters_address_line1` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `headquarters_city` SET TAGS ('dbx_business_glossary_term' = 'Headquarters City');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `headquarters_city` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `headquarters_city` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `headquarters_country_code` SET TAGS ('dbx_business_glossary_term' = 'Headquarters Country Code');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `headquarters_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `headquarters_postal_code` SET TAGS ('dbx_business_glossary_term' = 'Headquarters Postal Code');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `headquarters_postal_code` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `headquarters_postal_code` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `headquarters_state_province` SET TAGS ('dbx_business_glossary_term' = 'Headquarters State or Province');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `headquarters_state_province` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `headquarters_state_province` SET TAGS ('dbx_pii_address' = 'true');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `incorporation_country_code` SET TAGS ('dbx_business_glossary_term' = 'Incorporation Country Code');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `incorporation_country_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `industry_sector_code` SET TAGS ('dbx_business_glossary_term' = 'Global Industry Classification Standard (GICS) Sector Code');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `industry_sector_code` SET TAGS ('dbx_value_regex' = '^[0-9]{2,8}$');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `industry_sector_name` SET TAGS ('dbx_business_glossary_term' = 'Industry Sector Name');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `kyc_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Completion Date');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `kyc_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Expiry Date');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `kyc_status` SET TAGS ('dbx_business_glossary_term' = 'Know Your Customer (KYC) Status');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `kyc_status` SET TAGS ('dbx_value_regex' = 'approved|pending|expired|rejected|not_required');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `legal_name` SET TAGS ('dbx_business_glossary_term' = 'Tenant Legal Name');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `lei` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Tenant Notes');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `number_of_leases` SET TAGS ('dbx_business_glossary_term' = 'Number of Leases');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `onboarding_date` SET TAGS ('dbx_business_glossary_term' = 'Tenant Onboarding Date');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `parent_entity_lei` SET TAGS ('dbx_business_glossary_term' = 'Parent Entity Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `parent_entity_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `parent_entity_name` SET TAGS ('dbx_business_glossary_term' = 'Parent Entity Name');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Email Address');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `primary_contact_email` SET TAGS ('dbx_pii_email' = 'true');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Name');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `primary_contact_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_business_glossary_term' = 'Primary Contact Phone Number');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `primary_contact_phone` SET TAGS ('dbx_pii_phone' = 'true');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `public_company_flag` SET TAGS ('dbx_business_glossary_term' = 'Public Company Flag');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `relationship_manager_name` SET TAGS ('dbx_business_glossary_term' = 'Relationship Manager Name');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `stock_exchange_code` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Market Identifier Code (MIC)');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `stock_exchange_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{4}$');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `stock_ticker_symbol` SET TAGS ('dbx_business_glossary_term' = 'Stock Ticker Symbol');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_business_glossary_term' = 'Tax Identification Number (TIN)');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `tenant_status` SET TAGS ('dbx_business_glossary_term' = 'Tenant Status');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `tenant_status` SET TAGS ('dbx_value_regex' = 'active|inactive|default|bankruptcy|terminated');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `tenant_type` SET TAGS ('dbx_business_glossary_term' = 'Tenant Type Classification');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `tenant_type` SET TAGS ('dbx_value_regex' = 'anchor|major|standard|short_term|government|non_profit');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `total_leased_gla_sqft` SET TAGS ('dbx_business_glossary_term' = 'Total Leased Gross Leasable Area (GLA) in Square Feet');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `trading_name` SET TAGS ('dbx_business_glossary_term' = 'Tenant Trading Name');
ALTER TABLE `asset_management`.`realestate`.`tenant` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` SET TAGS ('dbx_domain' = 'realestate');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` SET TAGS ('dbx_subdomain' = 'asset_operations');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `realestate_capex_program_id` SET TAGS ('dbx_business_glossary_term' = 'Real Estate Capital Expenditure (CapEx) Program Identifier');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `actor_id` SET TAGS ('dbx_business_glossary_term' = 'Asset Manager Identifier');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Cash Account Id (Foreign Key)');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `contractor_id` SET TAGS ('dbx_business_glossary_term' = 'Contractor Identifier');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Asset Manager Identifier');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `property_id` SET TAGS ('dbx_business_glossary_term' = 'Property Identifier');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `actual_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Completion Date');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `actual_spend_amount` SET TAGS ('dbx_business_glossary_term' = 'Actual Spend Amount');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `actual_start_date` SET TAGS ('dbx_business_glossary_term' = 'Actual Start Date');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `approval_authority` SET TAGS ('dbx_business_glossary_term' = 'Approval Authority');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `approved_budget_amount` SET TAGS ('dbx_business_glossary_term' = 'Approved Budget Amount');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `budget_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Budget Currency Code');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `budget_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `business_case_reference` SET TAGS ('dbx_business_glossary_term' = 'Business Case Reference');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `committed_spend_amount` SET TAGS ('dbx_business_glossary_term' = 'Committed Spend Amount');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `completion_percentage` SET TAGS ('dbx_business_glossary_term' = 'Completion Percentage');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `contingency_amount` SET TAGS ('dbx_business_glossary_term' = 'Contingency Amount');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `contingency_percentage` SET TAGS ('dbx_business_glossary_term' = 'Contingency Percentage');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `contractor_name` SET TAGS ('dbx_business_glossary_term' = 'Contractor Name');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `contractor_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `contractor_name` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `realestate_capex_program_description` SET TAGS ('dbx_business_glossary_term' = 'Program Description');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `energy_efficiency_improvement_percentage` SET TAGS ('dbx_business_glossary_term' = 'Energy Efficiency Improvement Percentage');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `esg_impact_category` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Impact Category');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `expected_irr_percentage` SET TAGS ('dbx_business_glossary_term' = 'Expected Internal Rate of Return (IRR) Percentage');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `expected_nav_increase_amount` SET TAGS ('dbx_business_glossary_term' = 'Expected Net Asset Value (NAV) Increase Amount');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `expected_noi_increase_amount` SET TAGS ('dbx_business_glossary_term' = 'Expected Net Operating Income (NOI) Increase Amount');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `forecast_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Forecast Completion Date');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `forecast_total_cost_amount` SET TAGS ('dbx_business_glossary_term' = 'Forecast Total Cost Amount');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `funding_source` SET TAGS ('dbx_business_glossary_term' = 'Funding Source');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `ghg_reduction_target_tonnes` SET TAGS ('dbx_business_glossary_term' = 'Greenhouse Gas (GHG) Reduction Target Tonnes');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `ic_approval_reference` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Reference');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `last_status_update_date` SET TAGS ('dbx_business_glossary_term' = 'Last Status Update Date');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `planned_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Planned Completion Date');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `planned_start_date` SET TAGS ('dbx_business_glossary_term' = 'Planned Start Date');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `program_code` SET TAGS ('dbx_business_glossary_term' = 'Capital Expenditure (CapEx) Program Code');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `program_manager_name` SET TAGS ('dbx_business_glossary_term' = 'Program Manager Name');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `program_name` SET TAGS ('dbx_business_glossary_term' = 'Capital Expenditure (CapEx) Program Name');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `program_status` SET TAGS ('dbx_business_glossary_term' = 'Capital Expenditure (CapEx) Program Status');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `program_status` SET TAGS ('dbx_value_regex' = 'planned|approved|in_progress|on_hold|completed|cancelled');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `program_type` SET TAGS ('dbx_business_glossary_term' = 'Capital Expenditure (CapEx) Program Type');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `program_type` SET TAGS ('dbx_value_regex' = 'repositioning|refurbishment|development|esg_retrofit|tenant_improvement|infrastructure_upgrade');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Risk Rating');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `strategic_objective` SET TAGS ('dbx_business_glossary_term' = 'Strategic Objective');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `variance_amount` SET TAGS ('dbx_business_glossary_term' = 'Variance Amount');
ALTER TABLE `asset_management`.`realestate`.`realestate_capex_program` ALTER COLUMN `variance_percentage` SET TAGS ('dbx_business_glossary_term' = 'Variance Percentage');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` SET TAGS ('dbx_domain' = 'realestate');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` SET TAGS ('dbx_subdomain' = 'asset_operations');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `capex_expenditure_id` SET TAGS ('dbx_business_glossary_term' = 'Capital Expenditure (CapEx) Expenditure ID');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `approver_employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approver ID');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `budget_line_item_id` SET TAGS ('dbx_business_glossary_term' = 'Budget Line Item ID');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Cash Account Id (Foreign Key)');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `contract_id` SET TAGS ('dbx_business_glossary_term' = 'Contract ID');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Approver ID');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `property_id` SET TAGS ('dbx_business_glossary_term' = 'Property ID');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `realestate_capex_program_id` SET TAGS ('dbx_business_glossary_term' = 'Capital Expenditure (CapEx) Program ID');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `vendor_id` SET TAGS ('dbx_business_glossary_term' = 'Vendor ID');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `approved_amount` SET TAGS ('dbx_business_glossary_term' = 'Approved Amount');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `approver_name` SET TAGS ('dbx_business_glossary_term' = 'Approver Name');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `asset_class` SET TAGS ('dbx_business_glossary_term' = 'Asset Class');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `capitalization_flag` SET TAGS ('dbx_business_glossary_term' = 'Capitalization Flag');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `cost_center_code` SET TAGS ('dbx_business_glossary_term' = 'Cost Center Code');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `depreciation_method` SET TAGS ('dbx_business_glossary_term' = 'Depreciation Method');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `depreciation_method` SET TAGS ('dbx_value_regex' = 'straight_line|declining_balance|units_of_production|other');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `capex_expenditure_description` SET TAGS ('dbx_business_glossary_term' = 'Expenditure Description');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `expenditure_category` SET TAGS ('dbx_business_glossary_term' = 'Expenditure Category');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `expenditure_category` SET TAGS ('dbx_value_regex' = 'hard_costs|soft_costs|ffe|contingency|professional_fees|permits_fees');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `expenditure_date` SET TAGS ('dbx_business_glossary_term' = 'Expenditure Date');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `expenditure_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Expenditure Reference Number');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `expenditure_status` SET TAGS ('dbx_business_glossary_term' = 'Expenditure Status');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `expenditure_status` SET TAGS ('dbx_value_regex' = 'pending|approved|paid|reconciled|disputed|cancelled');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `invoice_date` SET TAGS ('dbx_business_glossary_term' = 'Invoice Date');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `invoice_number` SET TAGS ('dbx_business_glossary_term' = 'Invoice Number');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `invoiced_amount` SET TAGS ('dbx_business_glossary_term' = 'Invoiced Amount');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `milestone_reference` SET TAGS ('dbx_business_glossary_term' = 'Milestone Reference');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `modified_by` SET TAGS ('dbx_business_glossary_term' = 'Modified By');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `paid_amount` SET TAGS ('dbx_business_glossary_term' = 'Paid Amount');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Date');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'wire_transfer|check|ach|credit_card|other');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `payment_reference` SET TAGS ('dbx_business_glossary_term' = 'Payment Reference');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `project_code` SET TAGS ('dbx_business_glossary_term' = 'Project Code');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `purchase_order_number` SET TAGS ('dbx_business_glossary_term' = 'Purchase Order (PO) Number');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `reconciliation_date` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Date');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Status');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_value_regex' = 'pending|reconciled|discrepancy|under_review');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `retainage_amount` SET TAGS ('dbx_business_glossary_term' = 'Retainage Amount');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `retainage_percentage` SET TAGS ('dbx_business_glossary_term' = 'Retainage Percentage');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `scope_of_work` SET TAGS ('dbx_business_glossary_term' = 'Scope of Work');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Tax Amount');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `tax_rate` SET TAGS ('dbx_business_glossary_term' = 'Tax Rate');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `useful_life_years` SET TAGS ('dbx_business_glossary_term' = 'Useful Life Years');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `variance_amount` SET TAGS ('dbx_business_glossary_term' = 'Variance Amount');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `vendor_name` SET TAGS ('dbx_business_glossary_term' = 'Vendor Name');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `work_order_reference` SET TAGS ('dbx_business_glossary_term' = 'Work Order Reference');
ALTER TABLE `asset_management`.`realestate`.`capex_expenditure` ALTER COLUMN `created_by` SET TAGS ('dbx_business_glossary_term' = 'Created By');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` SET TAGS ('dbx_domain' = 'realestate');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` SET TAGS ('dbx_subdomain' = 'capital_transactions');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `realestate_debt_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Real Estate Debt Facility Identifier (ID)');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `actor_id` SET TAGS ('dbx_business_glossary_term' = 'Guarantor Identifier (ID)');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `credit_issuer_id` SET TAGS ('dbx_business_glossary_term' = 'Lender Identifier (ID)');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Guarantor Identifier (ID)');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `legal_entity_id` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (ID)');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `lender_counterparty_id` SET TAGS ('dbx_business_glossary_term' = 'Lender Counterparty Id (Foreign Key)');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `property_id` SET TAGS ('dbx_business_glossary_term' = 'Property Identifier (ID)');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `loan_servicer_id` SET TAGS ('dbx_business_glossary_term' = 'Servicer Identifier (ID)');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `accrued_interest_amount` SET TAGS ('dbx_business_glossary_term' = 'Accrued Interest Amount');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `amortization_period_months` SET TAGS ('dbx_business_glossary_term' = 'Amortization Period (Months)');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `amortization_type` SET TAGS ('dbx_business_glossary_term' = 'Amortization Type');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `amortization_type` SET TAGS ('dbx_value_regex' = 'interest_only|amortizing|bullet|balloon');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `commitment_date` SET TAGS ('dbx_business_glossary_term' = 'Commitment Date');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `commitment_fee_rate` SET TAGS ('dbx_business_glossary_term' = 'Commitment Fee Rate');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `covenant_package` SET TAGS ('dbx_business_glossary_term' = 'Covenant Package');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `data_source_system` SET TAGS ('dbx_business_glossary_term' = 'Data Source System');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `default_date` SET TAGS ('dbx_business_glossary_term' = 'Default Date');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `default_flag` SET TAGS ('dbx_business_glossary_term' = 'Default Flag');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `drawn_amount` SET TAGS ('dbx_business_glossary_term' = 'Drawn Amount');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `dscr` SET TAGS ('dbx_business_glossary_term' = 'Debt Service Coverage Ratio (DSCR)');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `extension_option_flag` SET TAGS ('dbx_business_glossary_term' = 'Extension Option Flag');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `extension_period_months` SET TAGS ('dbx_business_glossary_term' = 'Extension Period (Months)');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `facility_identifier` SET TAGS ('dbx_business_glossary_term' = 'Facility Identifier');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `facility_limit_amount` SET TAGS ('dbx_business_glossary_term' = 'Facility Limit Amount');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `facility_status` SET TAGS ('dbx_business_glossary_term' = 'Facility Status');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `facility_status` SET TAGS ('dbx_value_regex' = 'active|committed|drawn|matured|repaid|defaulted');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `facility_type` SET TAGS ('dbx_business_glossary_term' = 'Facility Type');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `facility_type` SET TAGS ('dbx_value_regex' = 'senior_mortgage|mezzanine|construction_loan|revolving_credit|bridge_loan|term_loan');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `interest_rate` SET TAGS ('dbx_business_glossary_term' = 'Interest Rate');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `interest_rate_type` SET TAGS ('dbx_business_glossary_term' = 'Interest Rate Type');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `interest_rate_type` SET TAGS ('dbx_value_regex' = 'fixed|floating|variable|hybrid');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `last_payment_date` SET TAGS ('dbx_business_glossary_term' = 'Last Payment Date');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `loan_agreement_date` SET TAGS ('dbx_business_glossary_term' = 'Loan Agreement Date');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `ltv_ratio` SET TAGS ('dbx_business_glossary_term' = 'Loan-to-Value (LTV) Ratio');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `maturity_date` SET TAGS ('dbx_business_glossary_term' = 'Maturity Date');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `modified_by_user` SET TAGS ('dbx_business_glossary_term' = 'Modified By User');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `next_payment_date` SET TAGS ('dbx_business_glossary_term' = 'Next Payment Date');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `origination_date` SET TAGS ('dbx_business_glossary_term' = 'Origination Date');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `origination_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Origination Fee Amount');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_business_glossary_term' = 'Payment Frequency');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `prepayment_allowed_flag` SET TAGS ('dbx_business_glossary_term' = 'Prepayment Allowed Flag');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `prepayment_penalty_rate` SET TAGS ('dbx_business_glossary_term' = 'Prepayment Penalty Rate');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `recourse_type` SET TAGS ('dbx_business_glossary_term' = 'Recourse Type');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `recourse_type` SET TAGS ('dbx_value_regex' = 'full_recourse|non_recourse|limited_recourse');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `reference_rate` SET TAGS ('dbx_business_glossary_term' = 'Reference Rate');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `security_type` SET TAGS ('dbx_business_glossary_term' = 'Security Type');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `security_type` SET TAGS ('dbx_value_regex' = 'first_lien|second_lien|unsecured|cross_collateralized');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `seniority` SET TAGS ('dbx_business_glossary_term' = 'Seniority');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `seniority` SET TAGS ('dbx_value_regex' = 'senior|subordinated|mezzanine|junior');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `spread_bps` SET TAGS ('dbx_business_glossary_term' = 'Spread Basis Points (bps)');
ALTER TABLE `asset_management`.`realestate`.`realestate_debt_facility` ALTER COLUMN `undrawn_amount` SET TAGS ('dbx_business_glossary_term' = 'Undrawn Amount');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` SET TAGS ('dbx_domain' = 'realestate');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` SET TAGS ('dbx_subdomain' = 'capital_transactions');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `ltv_dscr_covenant_id` SET TAGS ('dbx_business_glossary_term' = 'Loan-to-Value (LTV) Debt Service Coverage Ratio (DSCR) Covenant ID');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `property_id` SET TAGS ('dbx_business_glossary_term' = 'Property ID');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `realestate_debt_facility_id` SET TAGS ('dbx_business_glossary_term' = 'Debt Facility ID');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `annual_debt_service` SET TAGS ('dbx_business_glossary_term' = 'Annual Debt Service');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `appraiser_name` SET TAGS ('dbx_business_glossary_term' = 'Appraiser Name');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `covenant_notes` SET TAGS ('dbx_business_glossary_term' = 'Covenant Notes');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `cure_action_taken` SET TAGS ('dbx_business_glossary_term' = 'Cure Action Taken');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `cure_completion_date` SET TAGS ('dbx_business_glossary_term' = 'Cure Completion Date');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `dscr_breach_amount` SET TAGS ('dbx_business_glossary_term' = 'Debt Service Coverage Ratio (DSCR) Breach Amount');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `dscr_compliance_status` SET TAGS ('dbx_business_glossary_term' = 'Debt Service Coverage Ratio (DSCR) Compliance Status');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `dscr_compliance_status` SET TAGS ('dbx_value_regex' = 'compliant|breach|waived|cured');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `dscr_covenant_threshold` SET TAGS ('dbx_business_glossary_term' = 'Debt Service Coverage Ratio (DSCR) Covenant Threshold');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `dscr_ratio` SET TAGS ('dbx_business_glossary_term' = 'Debt Service Coverage Ratio (DSCR)');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `lender_notification_date` SET TAGS ('dbx_business_glossary_term' = 'Lender Notification Date');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `ltv_breach_amount` SET TAGS ('dbx_business_glossary_term' = 'Loan-to-Value (LTV) Breach Amount');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `ltv_compliance_status` SET TAGS ('dbx_business_glossary_term' = 'Loan-to-Value (LTV) Compliance Status');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `ltv_compliance_status` SET TAGS ('dbx_value_regex' = 'compliant|breach|waived|cured');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `ltv_covenant_threshold` SET TAGS ('dbx_business_glossary_term' = 'Loan-to-Value (LTV) Covenant Threshold');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `ltv_ratio` SET TAGS ('dbx_business_glossary_term' = 'Loan-to-Value (LTV) Ratio');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `measurement_date` SET TAGS ('dbx_business_glossary_term' = 'Covenant Measurement Date');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `measurement_frequency` SET TAGS ('dbx_business_glossary_term' = 'Measurement Frequency');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `measurement_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `next_measurement_date` SET TAGS ('dbx_business_glossary_term' = 'Next Measurement Date');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `noi_trailing_twelve_months` SET TAGS ('dbx_business_glossary_term' = 'Net Operating Income (NOI) Trailing Twelve Months');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `outstanding_debt_balance` SET TAGS ('dbx_business_glossary_term' = 'Outstanding Debt Balance');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `overall_covenant_status` SET TAGS ('dbx_business_glossary_term' = 'Overall Covenant Status');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `overall_covenant_status` SET TAGS ('dbx_value_regex' = 'compliant|breach|waived|cured|under_review');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `prepared_by` SET TAGS ('dbx_business_glossary_term' = 'Prepared By');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `property_gav` SET TAGS ('dbx_business_glossary_term' = 'Property Gross Asset Value (GAV)');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `property_nav` SET TAGS ('dbx_business_glossary_term' = 'Property Net Asset Value (NAV)');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `record_created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `record_updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `reporting_period` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `reporting_period` SET TAGS ('dbx_value_regex' = '^d{4}-Q[1-4]$|^d{4}-d{2}$');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `reviewed_by` SET TAGS ('dbx_business_glossary_term' = 'Reviewed By');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Property Valuation Date');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Valuation Method');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `valuation_method` SET TAGS ('dbx_value_regex' = 'appraisal|dcf|comparable_sales|income_capitalization|cost_approach');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `waiver_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Waiver Expiry Date');
ALTER TABLE `asset_management`.`realestate`.`ltv_dscr_covenant` ALTER COLUMN `waiver_granted_flag` SET TAGS ('dbx_business_glossary_term' = 'Waiver Granted Flag');
ALTER TABLE `asset_management`.`realestate`.`reit_position` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`realestate`.`reit_position` SET TAGS ('dbx_domain' = 'realestate');
ALTER TABLE `asset_management`.`realestate`.`reit_position` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`realestate`.`reit_position` SET TAGS ('dbx_subdomain' = 'fund_investments');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `reit_position_id` SET TAGS ('dbx_business_glossary_term' = 'Real Estate Investment Trust (REIT) Position Identifier');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Identifier');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `acquisition_date` SET TAGS ('dbx_business_glossary_term' = 'Acquisition Date');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `annual_distribution_amount` SET TAGS ('dbx_business_glossary_term' = 'Annual Distribution Amount');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `average_cost_per_unit` SET TAGS ('dbx_business_glossary_term' = 'Average Cost Per Unit');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `base_currency_market_value` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Market Value');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `benchmark_index` SET TAGS ('dbx_business_glossary_term' = 'Benchmark Index');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `carbon_intensity` SET TAGS ('dbx_business_glossary_term' = 'Carbon Intensity');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `country_of_domicile` SET TAGS ('dbx_business_glossary_term' = 'Country of Domicile');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `country_of_domicile` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `current_market_price` SET TAGS ('dbx_business_glossary_term' = 'Current Market Price');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `cusip` SET TAGS ('dbx_business_glossary_term' = 'Committee on Uniform Securities Identification Procedures (CUSIP)');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `cusip` SET TAGS ('dbx_value_regex' = '^[0-9]{3}[A-Z0-9]{5}[0-9]$');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `custodian_account_number` SET TAGS ('dbx_business_glossary_term' = 'Custodian Account Number');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `custodian_account_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `custodian_name` SET TAGS ('dbx_business_glossary_term' = 'Custodian Name');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `dividend_yield` SET TAGS ('dbx_business_glossary_term' = 'Dividend Yield');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `esg_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Rating');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `esg_rating_provider` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Rating Provider');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `exchange_code` SET TAGS ('dbx_business_glossary_term' = 'Exchange Code');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `fx_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `investment_committee_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Date');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `investment_strategy` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `isin` SET TAGS ('dbx_business_glossary_term' = 'International Securities Identification Number (ISIN)');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `isin` SET TAGS ('dbx_value_regex' = '^[A-Z]{2}[A-Z0-9]{9}[0-9]$');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `last_distribution_date` SET TAGS ('dbx_business_glossary_term' = 'Last Distribution Date');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `last_trade_date` SET TAGS ('dbx_business_glossary_term' = 'Last Trade Date');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `lei` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `market_value` SET TAGS ('dbx_business_glossary_term' = 'Market Value');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `next_distribution_date` SET TAGS ('dbx_business_glossary_term' = 'Next Distribution Date');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `position_currency` SET TAGS ('dbx_business_glossary_term' = 'Position Currency');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `position_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `position_status` SET TAGS ('dbx_business_glossary_term' = 'Position Status');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `position_status` SET TAGS ('dbx_value_regex' = 'active|closed|suspended|restricted');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `price_source` SET TAGS ('dbx_business_glossary_term' = 'Price Source');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `reit_name` SET TAGS ('dbx_business_glossary_term' = 'Real Estate Investment Trust (REIT) Name');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `reit_sector` SET TAGS ('dbx_business_glossary_term' = 'Real Estate Investment Trust (REIT) Sector');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `reit_sector` SET TAGS ('dbx_value_regex' = 'office|industrial|retail|residential|diversified|specialty');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `reit_type` SET TAGS ('dbx_business_glossary_term' = 'Real Estate Investment Trust (REIT) Type');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `reit_type` SET TAGS ('dbx_value_regex' = 'equity|mortgage|hybrid');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `sedol` SET TAGS ('dbx_business_glossary_term' = 'Stock Exchange Daily Official List (SEDOL)');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `sedol` SET TAGS ('dbx_value_regex' = '^[0-9A-Z]{7}$');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `ticker_symbol` SET TAGS ('dbx_business_glossary_term' = 'Ticker Symbol');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `total_cost_basis` SET TAGS ('dbx_business_glossary_term' = 'Total Cost Basis');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `units_held` SET TAGS ('dbx_business_glossary_term' = 'Units Held');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `unrealized_gain_loss` SET TAGS ('dbx_business_glossary_term' = 'Unrealized Gain or Loss');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Valuation Date');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `weight_in_portfolio` SET TAGS ('dbx_business_glossary_term' = 'Weight in Portfolio');
ALTER TABLE `asset_management`.`realestate`.`reit_position` ALTER COLUMN `weight_in_real_estate_allocation` SET TAGS ('dbx_business_glossary_term' = 'Weight in Real Estate Allocation');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` SET TAGS ('dbx_domain' = 'realestate');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` SET TAGS ('dbx_subdomain' = 'fund_investments');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `re_fund_commitment_id` SET TAGS ('dbx_business_glossary_term' = 'Real Estate (RE) Fund Commitment Identifier (ID)');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `custodian_id` SET TAGS ('dbx_business_glossary_term' = 'Custodian Entity Identifier (ID)');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `gp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Entity Identifier (ID)');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `carried_interest_rate` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest Rate');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `commitment_amount` SET TAGS ('dbx_business_glossary_term' = 'Commitment Amount');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `commitment_currency` SET TAGS ('dbx_business_glossary_term' = 'Commitment Currency');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `commitment_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `commitment_date` SET TAGS ('dbx_business_glossary_term' = 'Commitment Date');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `commitment_number` SET TAGS ('dbx_business_glossary_term' = 'Commitment Number');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `commitment_status` SET TAGS ('dbx_business_glossary_term' = 'Commitment Status');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `commitment_status` SET TAGS ('dbx_value_regex' = 'pending|active|fully_funded|partially_funded|cancelled|terminated');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `distributions_received` SET TAGS ('dbx_business_glossary_term' = 'Distributions Received');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `dpi` SET TAGS ('dbx_business_glossary_term' = 'Distributions to Paid-In (DPI)');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `esg_classification` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Classification');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `esg_classification` SET TAGS ('dbx_value_regex' = 'article_6|article_8|article_9|not_classified');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `expected_termination_date` SET TAGS ('dbx_business_glossary_term' = 'Expected Termination Date');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `extension_options_years` SET TAGS ('dbx_business_glossary_term' = 'Extension Options Years');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `final_close_date` SET TAGS ('dbx_business_glossary_term' = 'Final Close Date');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `final_fund_size` SET TAGS ('dbx_business_glossary_term' = 'Final Fund Size');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `first_close_date` SET TAGS ('dbx_business_glossary_term' = 'First Close Date');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `fund_manager_name` SET TAGS ('dbx_business_glossary_term' = 'Fund Manager Name');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `fund_strategy` SET TAGS ('dbx_business_glossary_term' = 'Fund Strategy');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `fund_term_years` SET TAGS ('dbx_business_glossary_term' = 'Fund Term Years');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `fund_type` SET TAGS ('dbx_business_glossary_term' = 'Fund Type');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `fund_type` SET TAGS ('dbx_value_regex' = 'commingled|separate_account|club_deal|joint_venture|fund_of_funds');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `geographic_focus` SET TAGS ('dbx_business_glossary_term' = 'Geographic Focus');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `gresb_participation_flag` SET TAGS ('dbx_business_glossary_term' = 'Global Real Estate Sustainability Benchmark (GRESB) Participation Flag');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `hurdle_rate` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `ic_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Date');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `ic_approval_reference` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Reference');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `investment_period_years` SET TAGS ('dbx_business_glossary_term' = 'Investment Period Years');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `irr` SET TAGS ('dbx_business_glossary_term' = 'Internal Rate of Return (IRR)');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `key_person_clause_flag` SET TAGS ('dbx_business_glossary_term' = 'Key Person Clause Flag');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `last_valuation_date` SET TAGS ('dbx_business_glossary_term' = 'Last Valuation Date');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `management_fee_rate` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Rate');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `most_favored_nation_flag` SET TAGS ('dbx_business_glossary_term' = 'Most Favored Nation (MFN) Flag');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `nav` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV)');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `ownership_percentage` SET TAGS ('dbx_business_glossary_term' = 'Ownership Percentage');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `pic` SET TAGS ('dbx_business_glossary_term' = 'Paid-In Capital (PIC)');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `pri_signatory_flag` SET TAGS ('dbx_business_glossary_term' = 'Principles for Responsible Investment (PRI) Signatory Flag');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `property_type_focus` SET TAGS ('dbx_business_glossary_term' = 'Property Type Focus');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_business_glossary_term' = 'Reporting Frequency');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `rvpi` SET TAGS ('dbx_business_glossary_term' = 'Residual Value to Paid-In (RVPI)');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `side_letter_flag` SET TAGS ('dbx_business_glossary_term' = 'Side Letter Flag');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `target_fund_size` SET TAGS ('dbx_business_glossary_term' = 'Target Fund Size');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `tvpi` SET TAGS ('dbx_business_glossary_term' = 'Total Value to Paid-In (TVPI)');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `unfunded_commitment` SET TAGS ('dbx_business_glossary_term' = 'Unfunded Commitment');
ALTER TABLE `asset_management`.`realestate`.`re_fund_commitment` ALTER COLUMN `vintage_year` SET TAGS ('dbx_business_glossary_term' = 'Vintage Year');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` SET TAGS ('dbx_domain' = 'realestate');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` SET TAGS ('dbx_subdomain' = 'fund_investments');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `re_capital_call_id` SET TAGS ('dbx_business_glossary_term' = 'Real Estate Capital Call Identifier (ID)');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Id (Foreign Key)');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `re_fund_commitment_id` SET TAGS ('dbx_business_glossary_term' = 'Real Estate Commitment Identifier (ID)');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `acquisition_amount` SET TAGS ('dbx_business_glossary_term' = 'Acquisition Amount');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `call_amount` SET TAGS ('dbx_business_glossary_term' = 'Capital Call Amount');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `call_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Capital Call Currency Code');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `call_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `call_due_date` SET TAGS ('dbx_business_glossary_term' = 'Capital Call Due Date');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `call_notice_date` SET TAGS ('dbx_business_glossary_term' = 'Capital Call Notice Date');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `call_notice_document_uri` SET TAGS ('dbx_business_glossary_term' = 'Capital Call Notice Document Uniform Resource Identifier (URI)');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `call_notice_number` SET TAGS ('dbx_business_glossary_term' = 'Capital Call Notice Number');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `call_purpose` SET TAGS ('dbx_business_glossary_term' = 'Capital Call Purpose');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `call_purpose` SET TAGS ('dbx_value_regex' = 'acquisition|capex|fees|expenses|working_capital|mixed');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `call_status` SET TAGS ('dbx_business_glossary_term' = 'Capital Call Status');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `call_status` SET TAGS ('dbx_value_regex' = 'issued|acknowledged|funded|partially_funded|overdue|cancelled');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `capex_amount` SET TAGS ('dbx_business_glossary_term' = 'Capital Expenditure (CapEx) Amount');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `commitment_percentage_called` SET TAGS ('dbx_business_glossary_term' = 'Commitment Percentage Called');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `cumulative_pic_post_call` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Paid-In Capital (PIC) Post-Call');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `cumulative_pic_pre_call` SET TAGS ('dbx_business_glossary_term' = 'Cumulative Paid-In Capital (PIC) Pre-Call');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `default_interest_accrued` SET TAGS ('dbx_business_glossary_term' = 'Default Interest Accrued');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `default_interest_rate` SET TAGS ('dbx_business_glossary_term' = 'Default Interest Rate');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `fund_expense_amount` SET TAGS ('dbx_business_glossary_term' = 'Fund Expense Amount');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `funded_amount` SET TAGS ('dbx_business_glossary_term' = 'Funded Amount');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `funded_date` SET TAGS ('dbx_business_glossary_term' = 'Funded Date');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `fx_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `fx_rate_date` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate Date');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `gp_bank_account_number` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Bank Account Number');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `gp_bank_account_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `gp_bank_account_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `gp_bank_bic` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Bank Identifier Code (BIC)');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `gp_bank_bic` SET TAGS ('dbx_value_regex' = '^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `gp_bank_name` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Bank Name');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `gp_contact_email` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Contact Email Address');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `gp_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `gp_contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `gp_contact_name` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Contact Name');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `gp_contact_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `gp_contact_name` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `internal_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Internal Approval Date');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `internal_approver_name` SET TAGS ('dbx_business_glossary_term' = 'Internal Approver Name');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `last_modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Modified Timestamp');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `management_fee_amount` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Amount');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Capital Call Notes');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `other_amount` SET TAGS ('dbx_business_glossary_term' = 'Other Amount');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `payment_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Payment Reference Number');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `settlement_account_number` SET TAGS ('dbx_business_glossary_term' = 'Settlement Account Number');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `settlement_account_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `settlement_account_number` SET TAGS ('dbx_pii_financial' = 'true');
ALTER TABLE `asset_management`.`realestate`.`re_capital_call` ALTER COLUMN `working_capital_amount` SET TAGS ('dbx_business_glossary_term' = 'Working Capital Amount');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` SET TAGS ('dbx_domain' = 'realestate');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` SET TAGS ('dbx_subdomain' = 'fund_investments');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `re_distribution_id` SET TAGS ('dbx_business_glossary_term' = 'Real Estate Distribution ID');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Custodian Account ID');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `gp_entity_id` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Entity ID');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Id (Foreign Key)');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `re_fund_commitment_id` SET TAGS ('dbx_business_glossary_term' = 'Real Estate Fund Investment ID');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `re_fund_investment_id` SET TAGS ('dbx_business_glossary_term' = 'Real Estate Fund Investment ID');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `underlying_property_id` SET TAGS ('dbx_business_glossary_term' = 'Underlying Property ID');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `accounting_period` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `accounting_period` SET TAGS ('dbx_value_regex' = '^d{4}-Q[1-4]$|^d{4}-d{2}$');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `announcement_date` SET TAGS ('dbx_business_glossary_term' = 'Announcement Date');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Code');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `capital_gain_component` SET TAGS ('dbx_business_glossary_term' = 'Capital Gain Component');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `carried_interest_component` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest Component');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `data_source_system` SET TAGS ('dbx_business_glossary_term' = 'Data Source System');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `data_source_system` SET TAGS ('dbx_value_regex' = 'eFront|custodian_feed|gp_portal|manual_entry');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `distribution_amount_base` SET TAGS ('dbx_business_glossary_term' = 'Distribution Amount Base Currency');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `distribution_amount_local` SET TAGS ('dbx_business_glossary_term' = 'Distribution Amount Local Currency');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `distribution_date` SET TAGS ('dbx_business_glossary_term' = 'Distribution Date');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `distribution_notes` SET TAGS ('dbx_business_glossary_term' = 'Distribution Notes');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `distribution_notice_number` SET TAGS ('dbx_business_glossary_term' = 'Distribution Notice Number');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `distribution_per_unit` SET TAGS ('dbx_business_glossary_term' = 'Distribution Per Unit');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `distribution_sequence_number` SET TAGS ('dbx_business_glossary_term' = 'Distribution Sequence Number');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `distribution_source` SET TAGS ('dbx_business_glossary_term' = 'Distribution Source');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `distribution_source` SET TAGS ('dbx_value_regex' = 'asset_sale|refinancing|operating_income|portfolio_revaluation|fund_liquidation');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `distribution_status` SET TAGS ('dbx_business_glossary_term' = 'Distribution Status');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `distribution_status` SET TAGS ('dbx_value_regex' = 'announced|confirmed|settled|reversed|pending_settlement');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `distribution_type` SET TAGS ('dbx_business_glossary_term' = 'Distribution Type');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `distribution_type` SET TAGS ('dbx_value_regex' = 'income|return_of_capital|recapitalization|carried_interest|liquidation|special');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `dpi_impact` SET TAGS ('dbx_business_glossary_term' = 'Distributions to Paid-In (DPI) Impact');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `fx_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `hurdle_rate_met_flag` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate Met Flag');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `income_component` SET TAGS ('dbx_business_glossary_term' = 'Income Component');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `irr_contribution` SET TAGS ('dbx_business_glossary_term' = 'Internal Rate of Return (IRR) Contribution');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `k1_schedule_reference` SET TAGS ('dbx_business_glossary_term' = 'K-1 Schedule Reference');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `local_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Local Currency Code');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `local_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `modified_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Modified Timestamp');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `nav_impact_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Asset Value (NAV) Impact Amount');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `net_distribution_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Distribution Amount');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_business_glossary_term' = 'Reconciliation Status');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `reconciliation_status` SET TAGS ('dbx_value_regex' = 'matched|unmatched|exception|pending_review');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `record_date` SET TAGS ('dbx_business_glossary_term' = 'Record Date');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `reinvestment_flag` SET TAGS ('dbx_business_glossary_term' = 'Reinvestment Flag');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `return_of_capital_component` SET TAGS ('dbx_business_glossary_term' = 'Return of Capital Component');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `settlement_date` SET TAGS ('dbx_business_glossary_term' = 'Settlement Date');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `tax_year` SET TAGS ('dbx_business_glossary_term' = 'Tax Year');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `units_held` SET TAGS ('dbx_business_glossary_term' = 'Units Held');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `waterfall_tier` SET TAGS ('dbx_business_glossary_term' = 'Waterfall Tier');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `waterfall_tier` SET TAGS ('dbx_value_regex' = 'tier_1_return_of_capital|tier_2_preferred_return|tier_3_catch_up|tier_4_carried_interest');
ALTER TABLE `asset_management`.`realestate`.`re_distribution` ALTER COLUMN `withholding_tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Withholding Tax Amount');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` SET TAGS ('dbx_domain' = 'realestate');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` SET TAGS ('dbx_subdomain' = 'capital_transactions');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `property_acquisition_id` SET TAGS ('dbx_business_glossary_term' = 'Property Acquisition Identifier (ID)');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Cash Account Id (Foreign Key)');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `contributor_pool_id` SET TAGS ('dbx_business_glossary_term' = 'Contributor Pool Id (Foreign Key)');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `dd_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Dd Engagement Id (Foreign Key)');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `deal_opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Identifier (ID)');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Asset Manager Identifier (ID)');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `gp_profile_id` SET TAGS ('dbx_business_glossary_term' = 'Asset Manager Identifier (ID)');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `opportunity_id` SET TAGS ('dbx_business_glossary_term' = 'Deal Identifier (ID)');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Id (Foreign Key)');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `property_id` SET TAGS ('dbx_business_glossary_term' = 'Property Identifier (ID)');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `seller_actor_id` SET TAGS ('dbx_business_glossary_term' = 'Seller Actor Id (Foreign Key)');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `acquisition_date` SET TAGS ('dbx_business_glossary_term' = 'Acquisition Date');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `acquisition_notes` SET TAGS ('dbx_business_glossary_term' = 'Acquisition Notes');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `acquisition_status` SET TAGS ('dbx_business_glossary_term' = 'Acquisition Status');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `acquisition_status` SET TAGS ('dbx_value_regex' = 'pending|completed|cancelled|under_review');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `acquisition_strategy` SET TAGS ('dbx_business_glossary_term' = 'Acquisition Strategy');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `acquisition_strategy` SET TAGS ('dbx_value_regex' = 'core|core_plus|value_add|opportunistic');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `acquisition_structure` SET TAGS ('dbx_business_glossary_term' = 'Acquisition Structure');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `acquisition_structure` SET TAGS ('dbx_value_regex' = 'direct|spv|joint_venture|fund');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `acquisition_yield` SET TAGS ('dbx_business_glossary_term' = 'Acquisition Yield');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `advisory_fees` SET TAGS ('dbx_business_glossary_term' = 'Advisory Fees');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `cap_rate` SET TAGS ('dbx_business_glossary_term' = 'Capitalization (Cap) Rate');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `co_investor_flag` SET TAGS ('dbx_business_glossary_term' = 'Co-Investor Flag');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `completion_date` SET TAGS ('dbx_business_glossary_term' = 'Completion Date');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `debt_amount` SET TAGS ('dbx_business_glossary_term' = 'Debt Amount');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `due_diligence_costs` SET TAGS ('dbx_business_glossary_term' = 'Due Diligence (DD) Costs');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `environmental_risk_description` SET TAGS ('dbx_business_glossary_term' = 'Environmental Risk Description');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `environmental_risk_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental Risk Flag');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `equity_amount` SET TAGS ('dbx_business_glossary_term' = 'Equity Amount');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `esg_rating_at_acquisition` SET TAGS ('dbx_business_glossary_term' = 'Environmental Social and Governance (ESG) Rating at Acquisition');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `going_in_irr` SET TAGS ('dbx_business_glossary_term' = 'Going-In Internal Rate of Return (IRR)');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `ic_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Date');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `ic_approval_reference` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Reference');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `legal_fees` SET TAGS ('dbx_business_glossary_term' = 'Legal Fees');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `loi_date` SET TAGS ('dbx_business_glossary_term' = 'Letter of Intent (LOI) Date');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `ltv_ratio` SET TAGS ('dbx_business_glossary_term' = 'Loan to Value (LTV) Ratio');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `noi_at_acquisition` SET TAGS ('dbx_business_glossary_term' = 'Net Operating Income (NOI) at Acquisition');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `occupancy_rate_at_acquisition` SET TAGS ('dbx_business_glossary_term' = 'Occupancy Rate at Acquisition');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `other_transaction_costs` SET TAGS ('dbx_business_glossary_term' = 'Other Transaction Costs');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `ownership_percentage` SET TAGS ('dbx_business_glossary_term' = 'Ownership Percentage');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `portfolio_allocation` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Allocation');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `property_city` SET TAGS ('dbx_business_glossary_term' = 'Property City');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `property_country` SET TAGS ('dbx_business_glossary_term' = 'Property Country');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `property_country` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `property_sector` SET TAGS ('dbx_business_glossary_term' = 'Property Sector');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `property_sector` SET TAGS ('dbx_value_regex' = 'office|retail|industrial|multifamily|hospitality|mixed_use');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `purchase_price` SET TAGS ('dbx_business_glossary_term' = 'Purchase Price');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `seller_lei` SET TAGS ('dbx_business_glossary_term' = 'Seller Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `seller_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `seller_name` SET TAGS ('dbx_business_glossary_term' = 'Seller Name');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `seller_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `spa_date` SET TAGS ('dbx_business_glossary_term' = 'Share Purchase Agreement (SPA) Date');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `stamp_duty` SET TAGS ('dbx_business_glossary_term' = 'Stamp Duty');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `target_hold_period_years` SET TAGS ('dbx_business_glossary_term' = 'Target Hold Period (Years)');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `total_acquisition_cost` SET TAGS ('dbx_business_glossary_term' = 'Total Acquisition Cost');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `transaction_currency` SET TAGS ('dbx_business_glossary_term' = 'Transaction Currency');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `transaction_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `transaction_reference` SET TAGS ('dbx_business_glossary_term' = 'Transaction Reference Number');
ALTER TABLE `asset_management`.`realestate`.`property_acquisition` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` SET TAGS ('dbx_domain' = 'realestate');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` SET TAGS ('dbx_subdomain' = 'capital_transactions');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `property_disposal_id` SET TAGS ('dbx_business_glossary_term' = 'Property Disposal Identifier (ID)');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `buyer_actor_id` SET TAGS ('dbx_business_glossary_term' = 'Buyer Actor Id (Foreign Key)');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Cash Account Id (Foreign Key)');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `dd_engagement_id` SET TAGS ('dbx_business_glossary_term' = 'Dd Engagement Id (Foreign Key)');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `portfolio_id` SET TAGS ('dbx_business_glossary_term' = 'Portfolio Id (Foreign Key)');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `property_id` SET TAGS ('dbx_business_glossary_term' = 'Property Identifier (ID)');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `advisor_firm_name` SET TAGS ('dbx_business_glossary_term' = 'Advisor Firm Name');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `book_value_at_disposal` SET TAGS ('dbx_business_glossary_term' = 'Book Value at Disposal');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `buyer_legal_name` SET TAGS ('dbx_business_glossary_term' = 'Buyer Legal Name');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `buyer_legal_name` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `buyer_lei` SET TAGS ('dbx_business_glossary_term' = 'Buyer Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `buyer_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `buyer_type` SET TAGS ('dbx_business_glossary_term' = 'Buyer Type');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `buyer_type` SET TAGS ('dbx_value_regex' = 'institutional_investor|private_equity|reit|sovereign_wealth_fund|pension_fund|individual');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `capital_gains_tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Capital Gains Tax Amount');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `contract_signing_date` SET TAGS ('dbx_business_glossary_term' = 'Contract Signing Date');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `disposal_date` SET TAGS ('dbx_business_glossary_term' = 'Disposal Date');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `disposal_notes` SET TAGS ('dbx_business_glossary_term' = 'Disposal Notes');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `disposal_rationale` SET TAGS ('dbx_business_glossary_term' = 'Disposal Rationale');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `disposal_status` SET TAGS ('dbx_business_glossary_term' = 'Disposal Status');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `disposal_status` SET TAGS ('dbx_value_regex' = 'pending|under_contract|completed|cancelled|failed');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `disposal_transaction_number` SET TAGS ('dbx_business_glossary_term' = 'Disposal Transaction Number');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `disposal_type` SET TAGS ('dbx_business_glossary_term' = 'Disposal Type');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `disposal_type` SET TAGS ('dbx_value_regex' = 'full_sale|partial_sale|recapitalization|joint_venture_exit|portfolio_sale|asset_swap');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `escrow_account_flag` SET TAGS ('dbx_business_glossary_term' = 'Escrow Account Flag');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `exit_cap_rate` SET TAGS ('dbx_business_glossary_term' = 'Exit Capitalization (Cap) Rate');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `exit_noi` SET TAGS ('dbx_business_glossary_term' = 'Exit Net Operating Income (NOI)');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `gross_sale_price` SET TAGS ('dbx_business_glossary_term' = 'Gross Sale Price');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `holding_period_years` SET TAGS ('dbx_business_glossary_term' = 'Holding Period in Years');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `ic_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Date');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `ic_approval_reference` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Reference');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `irr` SET TAGS ('dbx_business_glossary_term' = 'Internal Rate of Return (IRR)');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `legal_counsel_firm_name` SET TAGS ('dbx_business_glossary_term' = 'Legal Counsel Firm Name');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `moic` SET TAGS ('dbx_business_glossary_term' = 'Multiple on Invested Capital (MOIC)');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `net_proceeds` SET TAGS ('dbx_business_glossary_term' = 'Net Proceeds');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `realized_gain_loss` SET TAGS ('dbx_business_glossary_term' = 'Realized Gain or Loss');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `settlement_method` SET TAGS ('dbx_business_glossary_term' = 'Settlement Method');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `settlement_method` SET TAGS ('dbx_value_regex' = 'wire_transfer|escrow|dvp|deferred_payment');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `tax_jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Tax Jurisdiction');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `tax_jurisdiction` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `transaction_costs` SET TAGS ('dbx_business_glossary_term' = 'Transaction Costs');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `transaction_currency` SET TAGS ('dbx_business_glossary_term' = 'Transaction Currency');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `transaction_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`realestate`.`property_disposal` ALTER COLUMN `withholding_tax_amount` SET TAGS ('dbx_business_glossary_term' = 'Withholding Tax Amount');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` SET TAGS ('dbx_domain' = 'realestate');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` SET TAGS ('dbx_subdomain' = 'leasing_tenancy');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `occupancy_record_id` SET TAGS ('dbx_business_glossary_term' = 'Occupancy Record Identifier (ID)');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `property_id` SET TAGS ('dbx_business_glossary_term' = 'Property Identifier (ID)');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `absorption_rate` SET TAGS ('dbx_business_glossary_term' = 'Net Absorption Rate');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `area_unit` SET TAGS ('dbx_business_glossary_term' = 'Area Unit of Measure');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `area_unit` SET TAGS ('dbx_value_regex' = 'sqft|sqm');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `average_tenant_size` SET TAGS ('dbx_business_glossary_term' = 'Average Tenant Size');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `data_source` SET TAGS ('dbx_business_glossary_term' = 'Data Source System');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `economic_occupancy_rate` SET TAGS ('dbx_business_glossary_term' = 'Economic Occupancy Rate');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `largest_tenant_gla` SET TAGS ('dbx_business_glossary_term' = 'Largest Tenant Gross Leasable Area (GLA)');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `lease_expiry_exposure_12m` SET TAGS ('dbx_business_glossary_term' = 'Lease Expiry Exposure 12 Months (12M)');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `lease_expiry_exposure_24m` SET TAGS ('dbx_business_glossary_term' = 'Lease Expiry Exposure 24 Months (24M)');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `leasing_velocity` SET TAGS ('dbx_business_glossary_term' = 'Leasing Velocity');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `market_occupancy_rate` SET TAGS ('dbx_business_glossary_term' = 'Market Occupancy Rate');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `measurement_date` SET TAGS ('dbx_business_glossary_term' = 'Occupancy Measurement Date');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `measurement_method` SET TAGS ('dbx_business_glossary_term' = 'Measurement Method');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `measurement_method` SET TAGS ('dbx_value_regex' = 'actual|estimated|prorated');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `measurement_period` SET TAGS ('dbx_business_glossary_term' = 'Measurement Period');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `measurement_status` SET TAGS ('dbx_business_glossary_term' = 'Measurement Status');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `measurement_status` SET TAGS ('dbx_value_regex' = 'draft|preliminary|final|revised|audited');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Occupancy Record Notes');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `occupancy_trend` SET TAGS ('dbx_business_glossary_term' = 'Occupancy Trend Classification');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `occupancy_trend` SET TAGS ('dbx_value_regex' = 'increasing|stable|decreasing|volatile');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `occupancy_variance_pct` SET TAGS ('dbx_business_glossary_term' = 'Occupancy Variance Percentage');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `occupied_gla` SET TAGS ('dbx_business_glossary_term' = 'Occupied Gross Leasable Area (GLA)');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `physical_occupancy_rate` SET TAGS ('dbx_business_glossary_term' = 'Physical Occupancy Rate');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `prior_period_occupancy_rate` SET TAGS ('dbx_business_glossary_term' = 'Prior Period Occupancy Rate');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `renewal_rate` SET TAGS ('dbx_business_glossary_term' = 'Tenant Renewal Rate');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `stabilized_occupancy_flag` SET TAGS ('dbx_business_glossary_term' = 'Stabilized Occupancy Flag');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `stabilized_occupancy_target` SET TAGS ('dbx_business_glossary_term' = 'Stabilized Occupancy Target Rate');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `tenant_count` SET TAGS ('dbx_business_glossary_term' = 'Active Tenant Count');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `top_five_tenant_concentration` SET TAGS ('dbx_business_glossary_term' = 'Top Five Tenant Concentration Rate');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `total_gla` SET TAGS ('dbx_business_glossary_term' = 'Total Gross Leasable Area (GLA)');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `total_unit_count` SET TAGS ('dbx_business_glossary_term' = 'Total Unit Count');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `turnover_rate` SET TAGS ('dbx_business_glossary_term' = 'Tenant Turnover Rate');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `vacancy_type` SET TAGS ('dbx_business_glossary_term' = 'Vacancy Type Classification');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `vacancy_type` SET TAGS ('dbx_value_regex' = 'structural|transitional|development|seasonal|strategic|frictional');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `vacant_gla` SET TAGS ('dbx_business_glossary_term' = 'Vacant Gross Leasable Area (GLA)');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `vacant_unit_count` SET TAGS ('dbx_business_glossary_term' = 'Vacant Unit Count');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `verification_date` SET TAGS ('dbx_business_glossary_term' = 'Verification Date');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `verified_by` SET TAGS ('dbx_business_glossary_term' = 'Verified By User');
ALTER TABLE `asset_management`.`realestate`.`occupancy_record` ALTER COLUMN `weighted_average_lease_term` SET TAGS ('dbx_business_glossary_term' = 'Weighted Average Lease Term (WALT)');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` SET TAGS ('dbx_domain' = 'realestate');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` SET TAGS ('dbx_subdomain' = 'asset_operations');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `property_operating_expense_id` SET TAGS ('dbx_business_glossary_term' = 'Property Operating Expense ID');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `cash_account_id` SET TAGS ('dbx_business_glossary_term' = 'Cash Account Id (Foreign Key)');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `noi_record_id` SET TAGS ('dbx_business_glossary_term' = 'Net Operating Income (NOI) Record ID');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `property_id` SET TAGS ('dbx_business_glossary_term' = 'Property ID');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `realestate_capex_program_id` SET TAGS ('dbx_business_glossary_term' = 'Capital Expenditure (CAPEX) Project ID');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `vendor_id` SET TAGS ('dbx_business_glossary_term' = 'Vendor ID');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `accounting_period` SET TAGS ('dbx_business_glossary_term' = 'Accounting Period');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `accounting_period` SET TAGS ('dbx_value_regex' = '^d{4}-(0[1-9]|1[0-2])$');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `approval_status` SET TAGS ('dbx_business_glossary_term' = 'Approval Status');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `approval_status` SET TAGS ('dbx_value_regex' = 'pending|approved|rejected|paid');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `base_currency_amount` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Amount');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Base Currency Code');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `base_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `budget_line_item` SET TAGS ('dbx_business_glossary_term' = 'Budget Line Item');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `budgeted_amount` SET TAGS ('dbx_business_glossary_term' = 'Budgeted Amount');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `capitalized_flag` SET TAGS ('dbx_business_glossary_term' = 'Capitalized Flag');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `cost_center` SET TAGS ('dbx_business_glossary_term' = 'Cost Center');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `property_operating_expense_description` SET TAGS ('dbx_business_glossary_term' = 'Expense Description');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `expense_amount` SET TAGS ('dbx_business_glossary_term' = 'Expense Amount');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `expense_category` SET TAGS ('dbx_business_glossary_term' = 'Expense Category');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `expense_currency` SET TAGS ('dbx_business_glossary_term' = 'Expense Currency');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `expense_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `expense_date` SET TAGS ('dbx_business_glossary_term' = 'Expense Date');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `expense_subcategory` SET TAGS ('dbx_business_glossary_term' = 'Expense Subcategory');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `fiscal_quarter` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Quarter');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `fiscal_quarter` SET TAGS ('dbx_value_regex' = 'Q1|Q2|Q3|Q4');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `fiscal_year` SET TAGS ('dbx_business_glossary_term' = 'Fiscal Year');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `fx_rate` SET TAGS ('dbx_business_glossary_term' = 'Foreign Exchange (FX) Rate');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `gl_account_code` SET TAGS ('dbx_business_glossary_term' = 'General Ledger (GL) Account Code');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `invoice_date` SET TAGS ('dbx_business_glossary_term' = 'Invoice Date');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `invoice_number` SET TAGS ('dbx_business_glossary_term' = 'Invoice Number');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `net_expense_amount` SET TAGS ('dbx_business_glossary_term' = 'Net Expense Amount');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `payment_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Date');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `payment_due_date` SET TAGS ('dbx_business_glossary_term' = 'Payment Due Date');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `payment_method` SET TAGS ('dbx_business_glossary_term' = 'Payment Method');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `payment_method` SET TAGS ('dbx_value_regex' = 'wire_transfer|check|ach|credit_card|direct_debit');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `payment_reference` SET TAGS ('dbx_business_glossary_term' = 'Payment Reference');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `recoverable_amount` SET TAGS ('dbx_business_glossary_term' = 'Recoverable Amount');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `recoverable_flag` SET TAGS ('dbx_business_glossary_term' = 'Recoverable Flag');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `tax_treatment` SET TAGS ('dbx_business_glossary_term' = 'Tax Treatment');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `tax_treatment` SET TAGS ('dbx_value_regex' = 'deductible|non_deductible|partially_deductible|exempt');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `tax_treatment` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `tax_treatment` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `variance_amount` SET TAGS ('dbx_business_glossary_term' = 'Variance Amount');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `variance_percentage` SET TAGS ('dbx_business_glossary_term' = 'Variance Percentage');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `vat_amount` SET TAGS ('dbx_business_glossary_term' = 'Value Added Tax (VAT) Amount');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `vat_rate` SET TAGS ('dbx_business_glossary_term' = 'Value Added Tax (VAT) Rate');
ALTER TABLE `asset_management`.`realestate`.`property_operating_expense` ALTER COLUMN `vendor_name` SET TAGS ('dbx_business_glossary_term' = 'Vendor Name');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` SET TAGS ('dbx_domain' = 'realestate');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` SET TAGS ('dbx_subdomain' = 'capital_transactions');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `jv_structure_id` SET TAGS ('dbx_business_glossary_term' = 'Joint Venture (JV) Structure ID');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `property_id` SET TAGS ('dbx_business_glossary_term' = 'Property ID');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `accounting_method` SET TAGS ('dbx_business_glossary_term' = 'Accounting Method');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `accounting_method` SET TAGS ('dbx_value_regex' = 'equity_method|proportionate_consolidation|cost_method|full_consolidation');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `audit_firm_name` SET TAGS ('dbx_business_glossary_term' = 'Audit Firm Name');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `carried_interest_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Carried Interest (Carry) Rate Percentage');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `control_classification` SET TAGS ('dbx_business_glossary_term' = 'Control Classification');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `control_classification` SET TAGS ('dbx_value_regex' = 'controlled|joint_control|significant_influence|no_control');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `currency_code` SET TAGS ('dbx_business_glossary_term' = 'Currency Code');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `distribution_waterfall_type` SET TAGS ('dbx_business_glossary_term' = 'Distribution Waterfall Type');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `distribution_waterfall_type` SET TAGS ('dbx_value_regex' = 'european|american|hybrid');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Effective Date');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `esg_policy_flag` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Policy Flag');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `extension_options_count` SET TAGS ('dbx_business_glossary_term' = 'Extension Options Count');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `formation_date` SET TAGS ('dbx_business_glossary_term' = 'Formation Date');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `fund_term_years` SET TAGS ('dbx_business_glossary_term' = 'Fund Term Years');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `gp_name` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Name');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `gp_ownership_pct` SET TAGS ('dbx_business_glossary_term' = 'General Partner (GP) Ownership Percentage');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `hurdle_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Hurdle Rate Percentage');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `investment_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Period End Date');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `investment_strategy` SET TAGS ('dbx_business_glossary_term' = 'Investment Strategy');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `jurisdiction` SET TAGS ('dbx_business_glossary_term' = 'Jurisdiction');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `jv_arrangement_type` SET TAGS ('dbx_business_glossary_term' = 'Joint Venture (JV) Arrangement Type');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `jv_arrangement_type` SET TAGS ('dbx_value_regex' = 'joint_operation|joint_venture|co_investment');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `jv_entity_code` SET TAGS ('dbx_business_glossary_term' = 'Joint Venture (JV) Entity Code');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `jv_entity_name` SET TAGS ('dbx_business_glossary_term' = 'Joint Venture (JV) Entity Name');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `jv_status` SET TAGS ('dbx_business_glossary_term' = 'Joint Venture (JV) Status');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `jv_status` SET TAGS ('dbx_value_regex' = 'active|inactive|pending|dissolved|restructuring');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `last_audit_date` SET TAGS ('dbx_business_glossary_term' = 'Last Audit Date');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `legal_structure_type` SET TAGS ('dbx_business_glossary_term' = 'Legal Structure Type');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `legal_structure_type` SET TAGS ('dbx_value_regex' = 'LP|LLC|Trust|REIT|Corporation|Partnership');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `lei` SET TAGS ('dbx_business_glossary_term' = 'Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `lpa_execution_date` SET TAGS ('dbx_business_glossary_term' = 'Limited Partnership Agreement (LPA) Execution Date');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `lpa_reference` SET TAGS ('dbx_business_glossary_term' = 'Limited Partnership Agreement (LPA) Reference');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `management_fee_rate_pct` SET TAGS ('dbx_business_glossary_term' = 'Management Fee Rate Percentage');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Notes');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `pension_fund_capital_commitment` SET TAGS ('dbx_business_glossary_term' = 'Pension Fund Capital Commitment');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `pension_fund_ownership_pct` SET TAGS ('dbx_business_glossary_term' = 'Pension Fund Ownership Percentage');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `pension_fund_paid_in_capital` SET TAGS ('dbx_business_glossary_term' = 'Pension Fund Paid-In Capital (PIC)');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `pri_signatory_flag` SET TAGS ('dbx_business_glossary_term' = 'Principles for Responsible Investment (PRI) Signatory Flag');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `primary_co_investor_name` SET TAGS ('dbx_business_glossary_term' = 'Primary Co-Investor Name');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `primary_co_investor_ownership_pct` SET TAGS ('dbx_business_glossary_term' = 'Primary Co-Investor Ownership Percentage');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `primary_co_investor_type` SET TAGS ('dbx_business_glossary_term' = 'Primary Co-Investor Type');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `primary_co_investor_type` SET TAGS ('dbx_value_regex' = 'institutional_investor|sovereign_wealth_fund|pension_fund|private_equity|insurance_company|family_office');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_business_glossary_term' = 'Reporting Frequency');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `reporting_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `target_irr_pct` SET TAGS ('dbx_business_glossary_term' = 'Target Internal Rate of Return (IRR) Percentage');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `target_moic` SET TAGS ('dbx_business_glossary_term' = 'Target Multiple on Invested Capital (MOIC)');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_business_glossary_term' = 'Tax Identification Number');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `tax_identification_number` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Termination Date');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `total_co_investors_count` SET TAGS ('dbx_business_glossary_term' = 'Total Co-Investors Count');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `valuation_frequency` SET TAGS ('dbx_business_glossary_term' = 'Valuation Frequency');
ALTER TABLE `asset_management`.`realestate`.`jv_structure` ALTER COLUMN `valuation_frequency` SET TAGS ('dbx_value_regex' = 'monthly|quarterly|semi_annual|annual');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` SET TAGS ('dbx_domain' = 'realestate');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` SET TAGS ('dbx_subdomain' = 'asset_operations');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `property_insurance_id` SET TAGS ('dbx_business_glossary_term' = 'Property Insurance Identifier (ID)');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `property_id` SET TAGS ('dbx_business_glossary_term' = 'Property Identifier (ID)');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `additional_insured_parties` SET TAGS ('dbx_business_glossary_term' = 'Additional Insured Parties');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `aggregate_limit` SET TAGS ('dbx_business_glossary_term' = 'Aggregate Coverage Limit');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `annual_premium` SET TAGS ('dbx_business_glossary_term' = 'Annual Insurance Premium');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Approval Date');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Policy Approval Authority');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `broker_name` SET TAGS ('dbx_business_glossary_term' = 'Insurance Broker Name');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `cancellation_notice_days` SET TAGS ('dbx_business_glossary_term' = 'Cancellation Notice Period in Days');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `cancellation_reason` SET TAGS ('dbx_business_glossary_term' = 'Policy Cancellation Reason');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `certificate_of_insurance_reference` SET TAGS ('dbx_business_glossary_term' = 'Certificate of Insurance Reference');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `claims_history_summary` SET TAGS ('dbx_business_glossary_term' = 'Claims History Summary');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `claims_made_basis_flag` SET TAGS ('dbx_business_glossary_term' = 'Claims Made Basis Flag');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `coinsurance_percentage` SET TAGS ('dbx_business_glossary_term' = 'Coinsurance Percentage');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `coverage_description` SET TAGS ('dbx_business_glossary_term' = 'Coverage Description');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `coverage_limit` SET TAGS ('dbx_business_glossary_term' = 'Coverage Limit Amount');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `coverage_type` SET TAGS ('dbx_business_glossary_term' = 'Insurance Coverage Type');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Creation Timestamp');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `deductible_amount` SET TAGS ('dbx_business_glossary_term' = 'Policy Deductible Amount');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `endorsements` SET TAGS ('dbx_business_glossary_term' = 'Policy Endorsements');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `exclusions` SET TAGS ('dbx_business_glossary_term' = 'Policy Exclusions');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Expiry Date');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `inception_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Inception Date');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `insured_value` SET TAGS ('dbx_business_glossary_term' = 'Total Insured Value');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `insurer_lei` SET TAGS ('dbx_business_glossary_term' = 'Insurer Legal Entity Identifier (LEI)');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `insurer_lei` SET TAGS ('dbx_value_regex' = '^[A-Z0-9]{20}$');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `insurer_name` SET TAGS ('dbx_business_glossary_term' = 'Insurance Carrier Name');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `last_inspection_date` SET TAGS ('dbx_business_glossary_term' = 'Last Property Inspection Date');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `loss_payee` SET TAGS ('dbx_business_glossary_term' = 'Loss Payee Name');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `loss_ratio_percent` SET TAGS ('dbx_business_glossary_term' = 'Loss Ratio Percentage');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `next_inspection_due_date` SET TAGS ('dbx_business_glossary_term' = 'Next Inspection Due Date');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Policy Notes');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_business_glossary_term' = 'Premium Payment Frequency');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `payment_frequency` SET TAGS ('dbx_value_regex' = 'annual|semi_annual|quarterly|monthly');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `per_occurrence_limit` SET TAGS ('dbx_business_glossary_term' = 'Per Occurrence Coverage Limit');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `policy_document_reference` SET TAGS ('dbx_business_glossary_term' = 'Policy Document Reference');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `policy_number` SET TAGS ('dbx_business_glossary_term' = 'Insurance Policy Number');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `policy_status` SET TAGS ('dbx_business_glossary_term' = 'Policy Lifecycle Status');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `policy_status` SET TAGS ('dbx_value_regex' = 'active|pending|expired|cancelled|lapsed|renewed');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `policy_term_months` SET TAGS ('dbx_business_glossary_term' = 'Policy Term Duration in Months');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `premium_currency_code` SET TAGS ('dbx_business_glossary_term' = 'Premium Currency Code');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `premium_currency_code` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `renewal_date` SET TAGS ('dbx_business_glossary_term' = 'Policy Renewal Date');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `retroactive_date` SET TAGS ('dbx_business_glossary_term' = 'Retroactive Coverage Date');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `risk_assessment_rating` SET TAGS ('dbx_business_glossary_term' = 'Property Risk Assessment Rating');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `total_claims_paid_to_date` SET TAGS ('dbx_business_glossary_term' = 'Total Claims Paid to Date');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `underwriter_name` SET TAGS ('dbx_business_glossary_term' = 'Insurance Underwriter Name');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Last Update Timestamp');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `valuation_method` SET TAGS ('dbx_business_glossary_term' = 'Loss Valuation Method');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `valuation_method` SET TAGS ('dbx_value_regex' = 'replacement_cost|actual_cash_value|agreed_value|market_value');
ALTER TABLE `asset_management`.`realestate`.`property_insurance` ALTER COLUMN `waiting_period_days` SET TAGS ('dbx_business_glossary_term' = 'Waiting Period in Days');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` SET TAGS ('dbx_data_type' = 'transactional_data');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` SET TAGS ('dbx_domain' = 'realestate');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` SET TAGS ('dbx_subdomain' = 'asset_operations');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `esg_property_assessment_id` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Property Assessment Identifier');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `property_id` SET TAGS ('dbx_business_glossary_term' = 'Property Identifier');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `approval_date` SET TAGS ('dbx_business_glossary_term' = 'Approval Date');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `approved_by` SET TAGS ('dbx_business_glossary_term' = 'Approved By');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `assessment_date` SET TAGS ('dbx_business_glossary_term' = 'Assessment Date');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `assessment_methodology` SET TAGS ('dbx_business_glossary_term' = 'Assessment Methodology');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `assessment_status` SET TAGS ('dbx_business_glossary_term' = 'Assessment Status');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `assessment_status` SET TAGS ('dbx_value_regex' = 'draft|in_progress|completed|approved|expired');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `assessment_type` SET TAGS ('dbx_business_glossary_term' = 'Assessment Type');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `assessment_type` SET TAGS ('dbx_value_regex' = 'initial|annual|ad_hoc|acquisition_due_diligence|post_acquisition|certification_renewal');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `assessor_contact_email` SET TAGS ('dbx_business_glossary_term' = 'Assessor Contact Email Address');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `assessor_contact_email` SET TAGS ('dbx_value_regex' = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `assessor_contact_email` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `assessor_contact_name` SET TAGS ('dbx_business_glossary_term' = 'Assessor Contact Name');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `assessor_contact_name` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `assessor_contact_name` SET TAGS ('dbx_pii_identifier' = 'true');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `assessor_firm_name` SET TAGS ('dbx_business_glossary_term' = 'Assessor Firm Name');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `certification_date` SET TAGS ('dbx_business_glossary_term' = 'Certification Date');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `certification_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Certification Expiry Date');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `certification_level` SET TAGS ('dbx_business_glossary_term' = 'Certification Level');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `certification_reference_number` SET TAGS ('dbx_business_glossary_term' = 'Certification Reference Number');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `climate_risk_assessment_flag` SET TAGS ('dbx_business_glossary_term' = 'Climate Risk Assessment Flag');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Created Timestamp');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `data_quality_rating` SET TAGS ('dbx_business_glossary_term' = 'Data Quality Rating');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `data_quality_rating` SET TAGS ('dbx_value_regex' = 'high|medium|low');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `energy_consumption_kwh` SET TAGS ('dbx_business_glossary_term' = 'Energy Consumption in Kilowatt-Hours (kWh)');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `energy_intensity_kwh_per_sqm` SET TAGS ('dbx_business_glossary_term' = 'Energy Intensity in Kilowatt-Hours (kWh) per Square Meter');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `environmental_certification_type` SET TAGS ('dbx_business_glossary_term' = 'Environmental Certification Type');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `esg_risk_rating` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Risk Rating');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `esg_risk_rating` SET TAGS ('dbx_value_regex' = 'low|medium|high|critical');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `esg_score` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Score');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `ghg_emissions_intensity_kg_co2e_per_sqm` SET TAGS ('dbx_business_glossary_term' = 'Greenhouse Gas (GHG) Emissions Intensity in Kilograms Carbon Dioxide Equivalent (CO2e) per Square Meter');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `ghg_scope_1_emissions_tonnes_co2e` SET TAGS ('dbx_business_glossary_term' = 'Greenhouse Gas (GHG) Scope 1 Emissions in Tonnes Carbon Dioxide Equivalent (CO2e)');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `ghg_scope_2_emissions_tonnes_co2e` SET TAGS ('dbx_business_glossary_term' = 'Greenhouse Gas (GHG) Scope 2 Emissions in Tonnes Carbon Dioxide Equivalent (CO2e)');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `ghg_scope_3_emissions_tonnes_co2e` SET TAGS ('dbx_business_glossary_term' = 'Greenhouse Gas (GHG) Scope 3 Emissions in Tonnes Carbon Dioxide Equivalent (CO2e)');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `green_lease_clause_flag` SET TAGS ('dbx_business_glossary_term' = 'Green Lease Clause Flag');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `green_lease_coverage_percentage` SET TAGS ('dbx_business_glossary_term' = 'Green Lease Coverage Percentage');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `health_safety_incidents_count` SET TAGS ('dbx_business_glossary_term' = 'Health and Safety Incidents Count');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `health_safety_incidents_count` SET TAGS ('dbx_restricted' = 'true');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `health_safety_incidents_count` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `notes` SET TAGS ('dbx_business_glossary_term' = 'Assessment Notes');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `physical_climate_risk_level` SET TAGS ('dbx_business_glossary_term' = 'Physical Climate Risk Level');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `physical_climate_risk_level` SET TAGS ('dbx_value_regex' = 'low|medium|high|extreme');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `renewable_energy_percentage` SET TAGS ('dbx_business_glossary_term' = 'Renewable Energy Percentage');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `reporting_period_end_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period End Date');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `reporting_period_start_date` SET TAGS ('dbx_business_glossary_term' = 'Reporting Period Start Date');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `social_impact_assessment_flag` SET TAGS ('dbx_business_glossary_term' = 'Social Impact Assessment Flag');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `tenant_satisfaction_score` SET TAGS ('dbx_business_glossary_term' = 'Tenant Satisfaction Score');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `third_party_verification_flag` SET TAGS ('dbx_business_glossary_term' = 'Third-Party Verification Flag');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `total_ghg_emissions_tonnes_co2e` SET TAGS ('dbx_business_glossary_term' = 'Total Greenhouse Gas (GHG) Emissions in Tonnes Carbon Dioxide Equivalent (CO2e)');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `transition_climate_risk_level` SET TAGS ('dbx_business_glossary_term' = 'Transition Climate Risk Level');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `transition_climate_risk_level` SET TAGS ('dbx_value_regex' = 'low|medium|high|extreme');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Record Updated Timestamp');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `verification_date` SET TAGS ('dbx_business_glossary_term' = 'Verification Date');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `verification_firm_name` SET TAGS ('dbx_business_glossary_term' = 'Verification Firm Name');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `waste_diversion_rate_percentage` SET TAGS ('dbx_business_glossary_term' = 'Waste Diversion Rate Percentage');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `waste_diverted_tonnes` SET TAGS ('dbx_business_glossary_term' = 'Waste Diverted in Tonnes');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `waste_generated_tonnes` SET TAGS ('dbx_business_glossary_term' = 'Waste Generated in Tonnes');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `water_consumption_cubic_meters` SET TAGS ('dbx_business_glossary_term' = 'Water Consumption in Cubic Meters');
ALTER TABLE `asset_management`.`realestate`.`esg_property_assessment` ALTER COLUMN `water_intensity_cubic_meters_per_sqm` SET TAGS ('dbx_business_glossary_term' = 'Water Intensity in Cubic Meters per Square Meter');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` SET TAGS ('dbx_domain' = 'realestate');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` SET TAGS ('dbx_subdomain' = 'asset_operations');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `asset_business_plan_id` SET TAGS ('dbx_business_glossary_term' = 'Asset Business Plan ID');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `actor_id` SET TAGS ('dbx_business_glossary_term' = 'Asset Manager ID');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `employee_id` SET TAGS ('dbx_business_glossary_term' = 'Asset Manager ID');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `employee_id` SET TAGS ('dbx_confidential' = 'true');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `employee_id` SET TAGS ('dbx_pii' = 'true');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `property_id` SET TAGS ('dbx_business_glossary_term' = 'Property ID');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `capex_budget` SET TAGS ('dbx_business_glossary_term' = 'Capital Expenditure (CAPEX) Budget');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `capex_currency` SET TAGS ('dbx_business_glossary_term' = 'Capital Expenditure (CAPEX) Currency');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `capex_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `capex_program_description` SET TAGS ('dbx_business_glossary_term' = 'Capital Expenditure (CAPEX) Program Description');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `created_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Created Timestamp');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `disposition_consideration_flag` SET TAGS ('dbx_business_glossary_term' = 'Disposition Consideration Flag');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `energy_efficiency_target` SET TAGS ('dbx_business_glossary_term' = 'Energy Efficiency Target');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `esg_initiatives` SET TAGS ('dbx_business_glossary_term' = 'Environmental, Social, and Governance (ESG) Initiatives');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `ghg_reduction_target` SET TAGS ('dbx_business_glossary_term' = 'Greenhouse Gas (GHG) Reduction Target');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `ic_approval_date` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Approval Date');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `ic_meeting_reference` SET TAGS ('dbx_business_glossary_term' = 'Investment Committee (IC) Meeting Reference');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `lease_expiry_sqft` SET TAGS ('dbx_business_glossary_term' = 'Lease Expiry Square Footage');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `leasing_strategy` SET TAGS ('dbx_business_glossary_term' = 'Leasing Strategy');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `major_capex_projects` SET TAGS ('dbx_business_glossary_term' = 'Major Capital Expenditure (CAPEX) Projects');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `market_outlook` SET TAGS ('dbx_business_glossary_term' = 'Market Outlook');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `new_leasing_target_sqft` SET TAGS ('dbx_business_glossary_term' = 'New Leasing Target Square Footage');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `operating_expense_budget` SET TAGS ('dbx_business_glossary_term' = 'Operating Expense Budget');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `plan_approved_by` SET TAGS ('dbx_business_glossary_term' = 'Plan Approved By');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `plan_effective_date` SET TAGS ('dbx_business_glossary_term' = 'Plan Effective Date');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `plan_expiry_date` SET TAGS ('dbx_business_glossary_term' = 'Plan Expiry Date');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `plan_notes` SET TAGS ('dbx_business_glossary_term' = 'Plan Notes');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `plan_prepared_by` SET TAGS ('dbx_business_glossary_term' = 'Plan Prepared By');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `plan_status` SET TAGS ('dbx_business_glossary_term' = 'Plan Status');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `plan_status` SET TAGS ('dbx_value_regex' = 'draft|submitted|approved|active|revised|superseded');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `plan_version` SET TAGS ('dbx_business_glossary_term' = 'Plan Version');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `plan_version` SET TAGS ('dbx_value_regex' = '^[0-9]+.[0-9]+$');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `plan_year` SET TAGS ('dbx_business_glossary_term' = 'Plan Year');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `property_manager_name` SET TAGS ('dbx_business_glossary_term' = 'Property Manager Name');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `renewal_target_rate` SET TAGS ('dbx_business_glossary_term' = 'Renewal Target Rate');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `risk_factors` SET TAGS ('dbx_business_glossary_term' = 'Risk Factors');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `submission_date` SET TAGS ('dbx_business_glossary_term' = 'Submission Date');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `target_average_rent_psf` SET TAGS ('dbx_business_glossary_term' = 'Target Average Rent Per Square Foot (PSF)');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `target_exit_date` SET TAGS ('dbx_business_glossary_term' = 'Target Exit Date');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `target_gav` SET TAGS ('dbx_business_glossary_term' = 'Target Gross Asset Value (GAV)');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `target_irr` SET TAGS ('dbx_business_glossary_term' = 'Target Internal Rate of Return (IRR)');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `target_nav` SET TAGS ('dbx_business_glossary_term' = 'Target Net Asset Value (NAV)');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `target_noi` SET TAGS ('dbx_business_glossary_term' = 'Target Net Operating Income (NOI)');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `target_noi_currency` SET TAGS ('dbx_business_glossary_term' = 'Target Net Operating Income (NOI) Currency');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `target_noi_currency` SET TAGS ('dbx_value_regex' = '^[A-Z]{3}$');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `target_occupancy_rate` SET TAGS ('dbx_business_glossary_term' = 'Target Occupancy Rate');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `target_tenant_profile` SET TAGS ('dbx_business_glossary_term' = 'Target Tenant Profile');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `tenant_incentive_budget` SET TAGS ('dbx_business_glossary_term' = 'Tenant Incentive Budget');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `updated_timestamp` SET TAGS ('dbx_business_glossary_term' = 'Updated Timestamp');
ALTER TABLE `asset_management`.`realestate`.`asset_business_plan` ALTER COLUMN `value_creation_strategy` SET TAGS ('dbx_business_glossary_term' = 'Value Creation Strategy');
ALTER TABLE `asset_management`.`realestate`.`property_allocation` SET TAGS ('dbx_data_type' = 'association_data');
ALTER TABLE `asset_management`.`realestate`.`property_allocation` SET TAGS ('dbx_domain' = 'realestate');
ALTER TABLE `asset_management`.`realestate`.`property_allocation` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`realestate`.`property_allocation` SET TAGS ('dbx_subdomain' = 'fund_investments');
ALTER TABLE `asset_management`.`realestate`.`property_allocation` SET TAGS ('dbx_association_edges' = 'portfolio.portfolio,realestate.property');
ALTER TABLE `asset_management`.`realestate`.`property_allocation` ALTER COLUMN `property_allocation_id` SET TAGS ('dbx_business_glossary_term' = 'Property Allocation ID');
ALTER TABLE `asset_management`.`realestate`.`property_allocation` ALTER COLUMN `allocation_strategy` SET TAGS ('dbx_business_glossary_term' = 'Allocation Strategy');
ALTER TABLE `asset_management`.`realestate`.`property_allocation` ALTER COLUMN `effective_date` SET TAGS ('dbx_business_glossary_term' = 'Allocation Effective Date');
ALTER TABLE `asset_management`.`realestate`.`property_allocation` ALTER COLUMN `ownership_percentage` SET TAGS ('dbx_business_glossary_term' = 'Ownership Percentage');
ALTER TABLE `asset_management`.`realestate`.`property_allocation` ALTER COLUMN `termination_date` SET TAGS ('dbx_business_glossary_term' = 'Allocation Termination Date');
ALTER TABLE `asset_management`.`realestate`.`budget_line_item` SET TAGS ('dbx_data_type' = 'master_data');
ALTER TABLE `asset_management`.`realestate`.`budget_line_item` SET TAGS ('dbx_domain' = 'realestate');
ALTER TABLE `asset_management`.`realestate`.`budget_line_item` SET TAGS ('dbx_division' = 'operations');
ALTER TABLE `asset_management`.`realestate`.`budget_line_item` SET TAGS ('dbx_subdomain' = 'capital_transactions');
ALTER TABLE `asset_management`.`realestate`.`budget_line_item` ALTER COLUMN `budget_line_item_id` SET TAGS ('dbx_business_glossary_term' = 'Budget Line Item Identifier');
