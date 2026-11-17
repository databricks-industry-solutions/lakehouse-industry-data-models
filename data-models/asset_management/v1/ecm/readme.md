# Asset Management Lakehouse Data Model

**v1_ecm** generated using Vibe Modelling Agent on November 10, 2026 at 02:15 PM

This document outlines a vibed Lakehouse data model for the Asset Management business that can be deployed to Databricks Platform. The model is structured into business-aligned domains and denormalized data products, optimized for analytical workloads.

## Table of Contents

- [Output Folder Structure](#output-folder-structure)
- [Model Metrics](#model-metrics)
- [Business Summary](#business-summary)
- [Business Domains & Subdomains](#business-domains--subdomains)
  - [Collateral](#domain-collateral)
  - [Credit](#domain-credit)
  - [Deal](#domain-deal)
  - [Diligence](#domain-diligence)
  - [Equity](#domain-equity)
  - [Infrastructure](#domain-infrastructure)
  - [Naturalresource](#domain-naturalresource)
  - [Portfolio](#domain-portfolio)
  - [Privateequity](#domain-privateequity)
  - [Realestate](#domain-realestate)
  - [Research](#domain-research)
  - [Risk](#domain-risk)
  - [Trade](#domain-trade)
  - [Treasury](#domain-treasury)
  - [Valuation](#domain-valuation)
  - [Actuarial](#domain-actuarial)
  - [Beneficiary](#domain-beneficiary)
  - [Esg](#domain-esg)
  - [Fee](#domain-fee)
  - [Manager](#domain-manager)
  - [Performance](#domain-performance)
  - [Compliance](#domain-compliance)
  - [Shared](#domain-shared)
- [Metric Views](#metric-views)

## Output Folder Structure

All artifacts for version **v1_ecm** are organized as follows:

```
v1/ecm/
  schemas/          DDL SQL files (one per domain)
  metrics/          Metric view SQL files (one per domain)
  samples/          Sample data CSV files (one per data product)
  docs/             Excel workbook, model CSV, release notes
  diagram/          DBML schema
  vibes/            Current & next vibes context
  ontology/         RDF/Turtle ontology schema
  model.json        Full model with requirements, metadata, and model data
  readme.md         This file
```

| Folder | Contents |
|---|---|
| `schemas/` | `asset_management_<domain>_schema_v1_ecm.sql` (combined per-domain SQL: schemas/databases + tables with inline PKs + FKs + tags) |
| `schemas/` | `asset_management_catalogs_v1_ecm.sql` (catalog-level DDL) |
| `metrics/` | `asset_management_<domain>_metrics_v1_ecm.sql` (one file per domain) |
| `docs/` | `asset_management_model_v1_ecm.xlsx`, `asset_management_model_v1_ecm.csv`, `releasenotes.txt` |
| `diagram/` | `asset_management_dbml_v1_ecm.dbml` |
| `vibes/` | `current_vibes.txt`, `next_vibes.txt` |
| `/` | `model.json` (full model with requirements, metadata, and model data) |
| `ontology/` | `asset_management_rdf_v1_ecm.rdf` |
| `samples/` | One CSV file per data product (e.g., `customer.csv`, `order.csv`) |

## Model Metrics
| Metric | Value |
|---|---|
| Model Scope | ECM (Expanded Coverage Model) |
| Total Domains | 23 |
| Total Subdomains | 75 |
| Total Products | 566 |
| Total Attributes | 23424 |
| Primary Keys | 567 |
| Foreign Keys | 2438 |
| Avg Attributes/Product | 41.4 |
| Metric Views | 373 |

## Business Summary
| Business | Industry Alignment | Model Scope | Description | References | Version |
|---|---|---|---|---|---|
| Asset Management | Institutional-Asset-Management | ECM (Expanded Coverage Model) | An institutional asset manager that invests pension assets on behalf of several participating pension plans. As a sophisticated institutional buy-side allocator, this company conducts deep, fundamental buy-side analysis across diversified asset classes—including public equities, private equity, real estate, infrastructure, natural resources, and credit investments—with a core focus on long-term risk-adjusted returns and capital preservation. Their investment analysis is highly rigorous, utilizing proprietary macroeconomic modeling, extensive operational and financial due diligence, and comprehensive Environmental, Social, and Governance (ESG) integration to evaluate direct investments, co-investments, and external fund managers. Because they manage long-duration liabilities for pension beneficiaries, their internal research teams leverage their massive scale and permanent capital advantage to originate off-market deals globally, stress-test macroeconomic sensitivities, and actively manage portfolio assets post-acquisition to unlock operational efficiency and sustainable value. | Applicable regulators and standards vary by jurisdiction; representative bodies include: national pension regulator / superannuation authority, Securities and Exchange Commission (SEC), Financial Conduct Authority (FCA), European Securities and Markets Authority (ESMA), Alternative Investment Fund Managers Directive (AIFMD), CFA Institute Global Investment Performance Standards (GIPS), Principles for Responsible Investment (PRI), Task Force on Climate-related Financial Disclosures (TCFD), International Financial Reporting Standards (IFRS) / International Accounting Standards Board (IASB), Financial Accounting Standards Board (FASB) / US GAAP, International Organization of Securities Commissions (IOSCO), Basel Committee on Banking Supervision (counterparty exposure guidance), Financial Action Task Force (FATF - AML/KYC), International Swaps and Derivatives Association (ISDA), Global Legal Entity Identifier Foundation (GLEIF), SWIFT messaging standards, Sarbanes-Oxley Act (SOX financial controls), General Data Protection Regulation (GDPR) and applicable data privacy laws, local actuarial standards boards | 9 |

## Business Domains & Subdomains

<a id="domain-collateral"></a>

### Domain: Collateral

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| collateral | operations | 4 | Domain for collateral management and counterparty credit risk operations. Owns ISDA/CSA agreement records, margin call processing, collateral eligibility schedules, counterparty exposure tracking, LEI/BIC registry, credit limits, CCP clearing records, and | 23 |

**Subdomains:** agreement_documentation, collateral_inventory, counterparty_risk, margin_operations


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| agreement_documentation | ccp_membership | master_data | Master record for each Central Counterparty (CCP) clearing membership held by the pension fund or its clearing broker. Stores CCP name (LCH, Eurex, CME, ICE), membership type (direct clearing member, client clearing), clearing broker LEI, cleared product | 32 |
| agreement_documentation | csa | master_data | Master record for each Credit Support Annex (CSA) attached to an ISDA Master Agreement. Stores CSA type (English Law, New York Law, ISDA 2016 VM CSA), threshold amounts, minimum transfer amounts (MTA), independent amounts (IA), eligible collateral | 32 |
| agreement_documentation | eligibility_schedule | reference_data | Defines the collateral eligibility criteria and haircut schedules applicable under each CSA or CCP clearing membership. Stores eligible asset classes (government bonds, agency bonds, cash, equities, money market funds), currency eligibility, minimum | 23 |
| agreement_documentation | isda_master | master_data | Master record for each ISDA Master Agreement executed between the pension fund and a counterparty. Captures agreement version (1992 or 2002 ISDA), execution date, governing law jurisdiction, default provisions, termination event clauses, close-out netting | 34 |
| agreement_documentation | netting_agreement | master_data | Master record for each bilateral netting agreement (close-out netting or payment netting) executed with a counterparty. Captures netting type (close-out, payment, novation), governing law, effective date, product scope (rates, FX, credit, equity | 27 |
| collateral_inventory | collateral_account | master_data | Master reference table for collateral_account. Referenced by collateral_account_id. | 44 |
| collateral_inventory | collateral_position | transactional_data | Daily snapshot of the collateral inventory held or pledged with each counterparty or CCP, representing the current collateral book of record. Stores position date, counterparty or CCP, asset ISIN/CUSIP, asset type, nominal quantity, market value, haircut | 26 |
| collateral_inventory | recall | transactional_data | Transactional record of each collateral recall instruction issued to retrieve previously posted collateral from a counterparty. Captures recall date, asset ISIN/CUSIP, quantity recalled, recall reason (trade maturity, rebalancing, substitution | 24 |
| collateral_inventory | repo_transaction | transactional_data | Transactional record of each repurchase agreement (repo) or reverse repo executed for collateral transformation, liquidity management, or securities financing. | 46 |
| collateral_inventory | securities_lending | transactional_data | Transactional record of each securities lending transaction where the pension fund lends securities from its portfolio in exchange for collateral. Captures loan open date, recall date, return date, lent security ISIN/CUSIP, quantity lent, collateral type | 36 |
| collateral_inventory | ssi_registry | master_data | Master registry of Standard Settlement Instructions (SSIs) for each counterparty and asset type combination used in collateral settlement. Stores counterparty LEI, asset type, currency, custodian BIC, account number, settlement platform (Euroclear | 27 |
| collateral_inventory | substitution | transactional_data | Transactional record of each collateral substitution request and execution, where previously posted collateral is replaced with an alternative eligible asset. | 37 |
| counterparty_risk | counterparty | master_data | Master record for each counterparty entity in the pension fund's collateral and OTC derivatives ecosystem, including banks, broker-dealers, CCPs, and custodians. | 40 |
| counterparty_risk | counterparty_rating | transactional_data | Tracks the credit ratings assigned to each counterparty by external rating agencies (Moody's, S&P, Fitch) and internal credit assessment. Stores rating agency, rating type (long-term, short-term, outlook), rating value, rating date, prior rating, rating | 23 |
| counterparty_risk | counterparty_stress_result | association_data | This association product represents the stress test result for a specific counterparty under a specific stress scenario. It captures the quantified impact of applying a macroeconomic or market stress scenario to a counterparty's exposure, including | 7 |
| counterparty_risk | credit_limit | master_data | Master record defining the approved counterparty credit exposure limits set by the Investment Committee or Risk Committee for each counterparty. Stores limit type (pre-settlement, settlement, issuer, aggregate), limit currency, approved limit amount | 34 |
| counterparty_risk | credit_limit_breach | transactional_data | Transactional record of each credit limit breach event where counterparty exposure exceeds an approved credit limit. Captures breach date, counterparty, limit type breached, approved limit amount, actual exposure at breach, breach magnitude (amount and | 21 |
| counterparty_risk | exposure | transactional_data | Daily counterparty exposure record capturing gross and net MTM exposure per counterparty across all OTC derivative netting sets. Stores valuation date, gross positive exposure (GPE), net exposure after netting, collateral held, net exposure after | 40 |
| margin_operations | emir_trade_report | transactional_data | Transactional record of each EMIR trade reporting submission for OTC derivative transactions to a registered Trade Repository (TR). Captures report date, UTI (Unique Trade Identifier), UPI (Unique Product Identifier), counterparty LEI, reporting | 35 |
| margin_operations | margin_call | transactional_data | Transactional record of each margin call issued or received in the collateral management workflow. Captures call date, call direction (call issued / call received), margin type (VM — Variation Margin or IM — Initial Margin), call amount, call currency | 44 |
| margin_operations | margin_dispute | transactional_data | Transactional record of each margin call dispute raised by either party. Captures dispute date, disputing party, disputed amount, dispute reason (valuation difference, eligibility disagreement, haircut dispute), resolution status (open, resolved | 22 |
| margin_operations | posting | transactional_data | Transactional record of each collateral posting or return instruction executed to satisfy a margin call. Captures posting date, posting direction (posted / received / returned), asset type (cash, government bond, agency bond, equity), ISIN/CUSIP of posted | 29 |
| margin_operations | simm_calculation | transactional_data | Transactional record of each ISDA SIMM (Standard Initial Margin Model) calculation performed for bilateral uncleared OTC derivatives under EMIR UMR (Uncleared Margin Rules). | 33 |

<a id="domain-credit"></a>

### Domain: Credit

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| credit | operations | 4 | Domain for credit and fixed income investment operations including investment grade (IG) bonds, high yield (HY), private credit, sovereign debt, and structured products. | 27 |

**Subdomains:** benchmark_reference, fixed_income, private_credit, risk_analytics


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| benchmark_reference | benchmark_index | reference_data | Reference master for fixed income benchmark indices used for performance attribution, portfolio construction, and mandate compliance (e.g., Bloomberg Global Aggregate, Bloomberg US Corporate IG, ICE BofA HY, FTSE WGBI, Bloomberg EM USD Aggregate). | 47 |
| benchmark_reference | credit_benchmark_constituent | transactional_data | Time-series record of securities comprising each fixed income benchmark index at each rebalancing date, capturing security ISIN, index weight, market value contribution, duration contribution, yield contribution, sector classification, country, and rating | 49 |
| benchmark_reference | credit_issuer | master_data | Master record for corporate and sovereign debt issuers covered by the pension fund's credit investment universe, capturing issuer legal name, LEI, parent entity, country of domicile, country of risk, industry sector (GICS/ICB), issuer type (corporate | 46 |
| benchmark_reference | credit_mandate | master_data | Master record defining the investment mandate parameters and constraints for each credit portfolio or sub-portfolio managed by the pension fund, capturing mandate name, asset class scope (IG, HY, private credit, sovereign, structured), minimum/maximum | 52 |
| benchmark_reference | credit_yield_curve | reference_data | Reference data store for benchmark yield curves used in fixed income valuation and risk analytics, capturing curve type (government, swap, SOFR, OIS, credit spread curve), currency, tenor points, zero rates, par rates, forward rates, discount factors, and | 46 |
| benchmark_reference | sofr_rate | reference_data | Reference data time-series for SOFR (Secured Overnight Financing Rate) and related overnight/term rates (SOFR compounded in arrears, Term SOFR 1M/3M/6M/12M, SOFR OIS rates) published by the Federal Reserve Bank of New York and CME. | 30 |
| fixed_income | coupon_payment | transactional_data | Transactional record of actual coupon cash receipts and accruals for fixed income holdings, capturing payment date, coupon amount received, accrued interest at settlement, withholding tax applied, currency, FX rate used for conversion, and reconciliation | 43 |
| fixed_income | coupon_schedule | master_data | Forward-looking cash-flow schedule for each fixed income security, capturing all scheduled coupon payment dates, coupon amounts, coupon rates (fixed or floating), reference rate (SOFR, LIBOR), spread over reference rate, ex-dividend/record/payment dates | 46 |
| fixed_income | credit_allocation | association_data | This association product represents the Collateral Allocation between credit_position and collateral_position. It captures the operational record of how collateral assets are pledged or allocated against credit exposures for margin, regulatory, and risk | 7 |
| fixed_income | credit_position | transactional_data | IBOR-authoritative record of the pension fund's current and historical holdings in all credit and fixed income instruments across portfolios. Captures long/short positions, face value, book cost, market value (MTM), accrued interest, settlement date | 49 |
| fixed_income | fixed_income_security | master_data | Master record for all fixed income and credit instruments held or monitored by the pension fund, including investment grade (IG) bonds, high yield (HY) bonds, sovereign debt, T-Bills, SOFR-linked instruments, private credit notes, and structured products | 46 |
| fixed_income | maturity_schedule | master_data | Forward-looking maturity and redemption schedule for the fixed income portfolio, capturing each security's maturity date, call dates (for callable bonds), put dates (for putable bonds), sinking fund schedule, expected redemption amount, and redemption | 44 |
| fixed_income | sovereign_debt_holding | master_data | Master record for sovereign and quasi-sovereign debt holdings including government bonds, treasury bills (T-Bills), inflation-linked bonds (ILBs/TIPS), agency bonds, and supranational debt (World Bank, EIB). | 46 |
| fixed_income | structured_product | master_data | Master record for structured credit instruments including asset-backed securities (ABS), mortgage-backed securities (MBS), collateralized loan obligations (CLO), collateralized debt obligations (CDO), and covered bonds. | 47 |
| private_credit | amortization_schedule | master_data | Master reference table for amortization_schedule. Referenced by amortization_schedule_id. | 46 |
| private_credit | covenant_monitoring | transactional_data | Operational record tracking financial covenant compliance for private credit investments, capturing covenant type (leverage ratio, interest coverage ratio, LTV, DSCR, minimum liquidity), covenant threshold, actual measured value, measurement date | 39 |
| private_credit | private_credit_drawdown | transactional_data | Transactional record of capital drawdown events on private credit facilities, capturing drawdown date, drawdown amount, cumulative drawn balance, purpose of drawdown, applicable interest rate at drawdown, and funding source. | 46 |
| private_credit | private_credit_facility | master_data | Master reference table for private_credit_facility. Referenced by private_credit_facility_id. | 46 |
| private_credit | private_credit_investment | master_data | Master record for direct private credit investments including senior secured loans, mezzanine debt, unitranche facilities, distressed debt, and infrastructure debt originated or acquired by the pension fund. | 49 |
| private_credit | private_credit_repayment | transactional_data | Transactional record of principal repayments, amortization payments, and prepayments on private credit investments, capturing repayment date, principal amount repaid, prepayment premium (if any), remaining outstanding balance, and repayment type | 41 |
| risk_analytics | cds_market_data | transactional_data | Time-series of CDS market data for reference entities and indices (CDX, iTraxx), capturing CDS spread by tenor (1Y, 3Y, 5Y, 7Y, 10Y), upfront points, implied probability of default (PD), recovery rate assumption, and pricing date. | 38 |
| risk_analytics | cds_position | master_data | Master and position record for credit default swap (CDS) contracts held by the pension fund, capturing reference entity, reference obligation, CDS tenor, notional amount, protection bought/sold flag, CDS spread (running coupon in bps), upfront payment | 47 |
| risk_analytics | default_event | transactional_data | Transactional record of credit events (as defined under ISDA) affecting issuers or reference entities in the portfolio, including bankruptcy, failure to pay, restructuring, obligation acceleration, repudiation/moratorium, and governmental intervention. | 46 |
| risk_analytics | duration_convexity | transactional_data | Daily interest-rate sensitivity metrics for each fixed income security and portfolio: modified duration, Macaulay duration, effective duration, convexity, DV01 (dollar value of a basis point), PV01, and key rate durations (KRDs) across the yield curve. | 38 |
| risk_analytics | rating | master_data | SSOT for credit ratings and their full history for fixed income issuers and individual securities, from rating agencies (Moody's, S&P, Fitch) and internal credit assessment. | 39 |
| risk_analytics | rating_action | transactional_data | Transactional event record capturing each rating change, watch placement, or outlook revision for a rated issuer or security. Records the effective date, prior rating, new rating, rating agency, action type (upgrade, downgrade, CreditWatch | 36 |
| risk_analytics | spread_analytics | master_data | Daily yield and spread analytics for each fixed income security and position, capturing yield to maturity (YTM), yield to worst (YTW), yield to call, current yield, option-adjusted spread (OAS), Z-spread, G-spread, asset-swap spread (ASW), I-spread, and | 46 |

<a id="domain-deal"></a>

### Domain: Deal

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| deal | operations | 3 | Domain for deal origination, sourcing, and investment pipeline management covering both off-market and intermediated opportunities across all asset classes. | 23 |

**Subdomains:** approval_commitment, documentation_negotiation, pipeline_origination


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| approval_commitment | co_invest_allocation | master_data | Master record for co-investment allocations offered to or accepted from co-investors alongside the pension fund's direct investment. Captures the opportunity, co-investor entity name, co-investor LEI, allocated co-invest amount, co-invest currency | 45 |
| approval_commitment | deal_capital_commitment | master_data | Master record for the capital commitment approved and reserved for a deal at IC approval. Captures the opportunity, IC submission reference, approved commitment amount, commitment currency, commitment type (equity, debt, co-invest, fund commitment) | 52 |
| approval_commitment | deal_check | association_data | This association product represents the Compliance Check event between an investment opportunity and a compliance rule. It captures the operational record of each compliance verification performed during the deal pipeline process. | 7 |
| approval_commitment | deal_ic_condition | master_data | Master record for conditions attached to IC approvals. Captures the IC submission, condition description, condition type (pre-close, post-close, ongoing covenant), condition owner, due date, condition status (open, satisfied, waived, breached) | 37 |
| approval_commitment | deal_ic_submission | transactional_data | Transactional record capturing each formal Investment Committee (IC) submission for deal approval. Records the opportunity, investment memo version, submission date, IC meeting date, IC type (preliminary/full/special), requested commitment amount | 54 |
| approval_commitment | deal_valuation | transactional_data | Transactional record capturing indicative valuation estimates produced during deal origination and screening—prior to formal valuation domain ownership post-IC approval. | 47 |
| approval_commitment | investment_memo | master_data | Master record for Investment Memoranda (IM) prepared for IC submission. Captures IM version, preparation date, lead author, asset class, deal type, target company/asset name, recommended deal structure, proposed commitment amount, target IRR, target MOIC | 46 |
| approval_commitment | ppm_review | master_data | Master record for Private Placement Memorandum (PPM) reviews conducted during fund manager and co-investment screening. Captures the opportunity, PPM document version, review date, reviewer, fund strategy summary, GP track record assessment, fee structure | 48 |
| documentation_negotiation | deal_document | master_data | Master record for all deal-related documents managed within the deal pipeline. Captures document type (NDA, LOI, term sheet, IM, PPM, financial model, legal opinion, management presentation, data room index), document title, document version, upload date | 48 |
| documentation_negotiation | deal_fee | transactional_data | Transactional record for fees incurred during deal origination and execution—including advisory fees, break fees, arrangement fees, legal fees, and due diligence costs. | 47 |
| documentation_negotiation | exclusivity_agreement | master_data | Master record for exclusivity agreements negotiated with sellers or GPs during deal execution. Captures the opportunity, counterparty, exclusivity start date, exclusivity end date, exclusivity scope description, break fee amount, break fee currency | 53 |
| documentation_negotiation | loi | master_data | Master record for Letters of Intent issued during deal origination and early negotiation. Captures LOI type (binding/non-binding), issuance date, expiry date, indicative enterprise value, indicative equity value, proposed deal structure, exclusivity | 46 |
| documentation_negotiation | milestone | transactional_data | Transactional record tracking key milestones in the deal execution timeline. Captures the opportunity, milestone type (NDA signed, LOI issued, exclusivity granted, DD commenced, IC submission, IC approval, SPA signed, regulatory filing, financial close) | 45 |
| documentation_negotiation | nda | master_data | Master record for Non-Disclosure Agreements executed in connection with deal origination and due diligence. Captures NDA type (mutual/one-way), counterparty legal entity, execution date, expiry date, governing law jurisdiction, NDA status (draft | 48 |
| documentation_negotiation | term_sheet | master_data | Master record for term sheets negotiated during deal structuring. Captures term sheet version, issuance date, counterparty, proposed deal structure (equity/debt/hybrid), indicative valuation basis, key economic terms (purchase price, EBITDA multiple, IRR | 45 |
| pipeline_origination | deal_contact | master_data | Master record for external contacts associated with a deal opportunity—including sell-side advisors, management teams, GP representatives, legal counsel, and intermediaries. | 43 |
| pipeline_origination | opportunity | master_data | Core master record (SSOT) for every investment opportunity entering the pipeline—off-market/proprietary, GP-introduced, or intermediated—across all asset classes. | 50 |
| pipeline_origination | origination_source | reference_data | Reference master for external deal parties—origination sources, intermediaries, and their individual contacts—across the pipeline. Captures source/party type (proprietary/off-market, GP-introduced, investment bank, broker, co-investor referral, management | 43 |
| pipeline_origination | pipeline_stage | reference_data | Reference taxonomy defining the ordered stages of the deal pipeline lifecycle—from initial screening through IC approval and closing. Captures stage code, stage name, stage sequence order, minimum dwell days, required deliverables checklist, stage | 43 |
| pipeline_origination | screening_decision | transactional_data | Transactional record capturing the formal screening decision made at each pipeline gate review. Records the opportunity, screening date, screening type (initial/full), screening committee members, decision outcome (proceed, hold, decline), decline reason | 43 |
| pipeline_origination | stage_transition | transactional_data | Transactional audit record capturing every pipeline-gate event for an opportunity—both mechanical stage advances and formal go/no-go screening decisions. Records the opportunity, prior stage, new stage, transition date/timestamp, approving | 42 |
| pipeline_origination | target_entity | master_data | Master record for the target company, asset, or fund that is the subject of a deal opportunity. Captures target legal name, target type (operating company, real asset, infrastructure asset, fund, co-investment vehicle), jurisdiction of incorporation, LEI | 53 |
| pipeline_origination | team | association_data | Association record capturing the deal team composition for each opportunity. Records the opportunity, team member employee reference, role on deal (lead, associate, analyst, legal counsel, ESG advisor, external advisor), assignment start date, assignment | 30 |

<a id="domain-diligence"></a>

### Domain: Diligence

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| diligence | operations | 4 | Domain for comprehensive investment due diligence processes including operational due diligence (ODD), financial due diligence (FDD), commercial due diligence (CDD), legal DD, and ESG DD conducted on prospective investments and external fund managers. | 24 |

**Subdomains:** advisor_management, compliance_approval, diligence_execution, risk_assessment


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| advisor_management | advisor_engagement | master_data | Master record for a third-party advisor or specialist firm engaged to support a DD workstream — e.g., legal counsel, accounting firm (FDD), technical consultant (infrastructure/real estate), environmental consultant (ESG/natural resources), or commercial | 48 |
| advisor_management | advisor_report | transactional_data | Formal report or deliverable submitted by a third-party advisor as part of a DD engagement. Captures report type (legal opinion, FDD report, ODD report, environmental assessment, technical report, CDD report), submission date, report version, key | 47 |
| advisor_management | dd_advisor_cost | master_data | Cost and fee-accrual record for a third-party advisor engagement within a DD engagement. Captures the advisor_engagement reference, fee type (fixed, capped, hourly, success-based), budgeted amount, accrued-to-date, invoiced amount, paid amount, currency | 45 |
| advisor_management | management_interview | transactional_data | Record of a formal qualitative information-gathering engagement conducted during DD — covering both management interviews/site visits with the target and reference checks with third-party referees. | 49 |
| advisor_management | reference_check | transactional_data | Record of a reference check conducted on a target company's management team or an external fund manager's investment professionals. Captures referee name, referee organization, referee relationship to subject, check date, topics covered, key feedback | 50 |
| compliance_approval | assessment | association_data | This association product represents the compliance assessment event between a due diligence engagement and a compliance rule. It captures the outcome of evaluating a specific DD engagement against a specific compliance monitoring rule. | 7 |
| compliance_approval | diligence_ic_condition | transactional_data | Individual condition or requirement attached to an IC approval decision. Captures condition type (legal, financial, ESG, operational, regulatory), condition description, responsible party for resolution, target resolution date, actual resolution date, and | 48 |
| compliance_approval | diligence_ic_submission | transactional_data | Investment Committee (IC) submission package record representing the formal presentation of a DD-completed investment opportunity to the IC for approval. Captures submission date, IC meeting date, investment type, recommended commitment amount, deal | 54 |
| compliance_approval | kyc_aml_record | transactional_data | Know Your Customer (KYC) and Anti-Money Laundering (AML) screening record conducted on a counterparty, target company, fund manager, or beneficial owner as part of the DD and onboarding process. | 54 |
| compliance_approval | nda_record | master_data | Non-Disclosure Agreement (NDA) record executed with a target company, fund manager, or intermediary as part of the deal origination and DD process. Captures counterparty name, LEI, NDA type (mutual, one-way), execution date, expiry date, governing law | 52 |
| diligence_execution | data_room_access | transactional_data | Record of virtual data room (VDR) access granted to the investment team for a specific DD engagement. Captures VDR platform (e.g., Intralinks, Datasite, Ansarada), access grant date, access expiry date, document categories available, number of documents | 48 |
| diligence_execution | dd_checklist | master_data | Standardized or customized DD checklist template assigned to a workstream within a DD engagement. Captures the checklist version, applicable asset class (private equity, real estate, infrastructure, credit, etc.), workstream type, total item count | 48 |
| diligence_execution | dd_checklist_item | transactional_data | Individual line-item within a DD checklist representing a specific information request, verification task, or diligence question. Tracks item category, question text, response status (open, received, satisfactory, escalated), assigned analyst, due date | 50 |
| diligence_execution | dd_document | master_data | Metadata registry record for a document received, generated, or reviewed during a DD engagement (CIM, PPM, audited financials, legal opinion, technical report, ESG disclosure, management presentation, data room file). | 48 |
| diligence_execution | dd_engagement | master_data | Master record for a formal due diligence engagement initiated on a prospective investment, co-investment, or external fund manager. Captures the DD type (ODD, FDD, CDD, Legal, ESG, or combined), the target entity under review, engagement status, lead | 56 |
| diligence_execution | dd_status_event | transactional_data | Audit trail of status transitions for a DD engagement or workstream throughout its lifecycle. Captures the prior status, new status, transition timestamp, triggering event description, and the analyst or system that triggered the change. | 38 |
| diligence_execution | dd_workstream | master_data | Represents a distinct functional workstream within a DD engagement — Operational DD (ODD), Financial DD (FDD), Commercial DD (CDD), Legal DD, ESG DD, or Tax DD. | 50 |
| risk_assessment | cdd_assessment | transactional_data | Commercial Due Diligence (CDD) assessment record evaluating the market position, competitive dynamics, and commercial viability of a target investment. Captures market size and growth assessment, competitive positioning, customer concentration analysis | 49 |
| risk_assessment | dd_finding | transactional_data | Formal finding or issue identified during any DD workstream. Captures finding type (financial, operational, legal, ESG, commercial), severity rating (critical, major, minor, informational), description, root cause, potential financial impact, recommended | 51 |
| risk_assessment | dd_risk_assessment | transactional_data | Consolidated risk assessment record produced at the conclusion of a DD engagement or workstream. Captures overall risk rating, individual risk dimension scores (financial, operational, legal, ESG, market, management quality), key risk factors, mitigants | 52 |
| risk_assessment | esg_dd_assessment | transactional_data | ESG-specific due diligence assessment conducted as part of the investment DD process. Captures ESG materiality screening results, environmental risk factors (GHG emissions, climate transition risk, physical risk), social risk factors (labor practices | 58 |
| risk_assessment | fdd_assessment | transactional_data | Financial Due Diligence (FDD) assessment record capturing the financial analysis of a target investment or fund manager. Tracks quality of earnings (QoE) findings, EBITDA normalization adjustments, working capital analysis, net debt reconciliation | 50 |
| risk_assessment | legal_dd_assessment | transactional_data | Legal due diligence assessment record capturing the legal review of a target investment or fund manager. Tracks corporate structure review, title and ownership verification, material contract review (LPA terms, SPA, key commercial agreements), litigation | 53 |
| risk_assessment | odd_assessment | transactional_data | Operational Due Diligence (ODD) assessment record specific to external fund manager evaluations. Captures operational infrastructure quality ratings across key ODD dimensions: governance and organizational structure, technology and systems, valuation | 51 |

<a id="domain-equity"></a>

### Domain: Equity

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| equity | operations | 3 | Domain governing public equities investment operations including listed equity positions, equity research coverage, sector analysis, stock selection, and corporate actions. | 24 |

**Subdomains:** instrument_reference, portfolio_stewardship, research_analysis


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| instrument_reference | corporate_action | transactional_data | Corporate action event master for all equity securities in the coverage and position universe. Captures corporate action type (dividend, stock split, reverse split, rights issue, spin-off, merger, acquisition, delisting, name change, ticker change, bonus | 43 |
| instrument_reference | corporate_action_election | transactional_data | Records of the fund's elections and responses to voluntary corporate actions (e.g., tender offers, rights subscriptions, merger consideration elections, dividend reinvestment elections). | 49 |
| instrument_reference | equity_benchmark | reference_data | Reference master for equity benchmark indices used in portfolio construction, performance attribution, and risk management. Captures benchmark name, index provider (MSCI, FTSE, S&P, Russell), benchmark code, currency, rebalancing frequency, weighting | 46 |
| instrument_reference | equity_benchmark_constituent | transactional_data | Point-in-time constituent membership records for equity benchmark indices, capturing the weight of each security within a benchmark at a given rebalancing date. | 41 |
| instrument_reference | equity_issuer | master_data | Corporate issuer master data for companies whose equity securities are held or covered by the fund. Captures legal entity name, LEI, headquarters country, incorporation jurisdiction, primary stock exchange, primary listing currency, parent company | 47 |
| instrument_reference | equity_sector_classification | reference_data | Equity sector and industry classification master for listed securities using standard classification schemes. Captures classification scheme (GICS, ICB, NAICS, SIC), sector code, industry group code, industry code, sub-industry code, sector name, industry | 37 |
| instrument_reference | index_rebalance_event | transactional_data | Records of scheduled and ad-hoc index rebalancing events for equity benchmark indices tracked by the fund. Captures index provider, rebalancing type (quarterly, semi-annual, annual, ad-hoc), announcement date, effective date, additions list, deletions | 44 |
| instrument_reference | issuer_financials | transactional_data | Standardized fundamental financial data for equity issuers, capturing reported and consensus financial metrics used in equity analysis. Includes period type (annual, semi-annual, quarterly), reporting date, revenue, EBITDA, EBIT, net income, EPS (basic | 47 |
| instrument_reference | listed_security | master_data | Equity security master data for all exchange-traded equity instruments held or covered by the fund. Serves as the SSOT for equity instrument identity, capturing ISIN, CUSIP, SEDOL, ticker symbol, exchange listing, share class, par value, shares | 45 |
| instrument_reference | price_history | transactional_data | Daily end-of-day price and volume history for listed equity securities. Captures open, high, low, close, adjusted close (for corporate actions), total return index level, trading volume, VWAP, market capitalization, shares outstanding at date | 37 |
| instrument_reference | security_sector_mapping | association_data | Association table mapping listed equity securities to their sector and industry classifications under one or more classification schemes at a point in time. Captures the effective date, expiry date, primary classification flag, and classification source. | 40 |
| portfolio_stewardship | dividend_record | transactional_data | Dividend income records for equity positions held by the fund, capturing declared dividends, accrued income, and received cash flows at the security-portfolio level. | 46 |
| portfolio_stewardship | engagement_log | transactional_data | Records of the fund's direct engagement activities with equity issuers as part of active ownership and ESG stewardship. Captures engagement date, engagement type (letter, meeting, call, collaborative engagement), topic category (governance, climate | 48 |
| portfolio_stewardship | equity_position | transactional_data | IBOR equity position records representing the fund's current and historical holdings in listed equities at the portfolio-security-date level. Captures long/short indicator, quantity held, book cost, average cost basis, unrealized P&L, market value in | 51 |
| portfolio_stewardship | proxy_voting_record | transactional_data | Records of the fund's proxy voting decisions and outcomes for shareholder meetings of equity holdings. Captures meeting type (AGM, EGM), meeting date, resolution number, resolution description, resolution category (director election, executive | 48 |
| portfolio_stewardship | restriction | master_data | Investment restriction and compliance constraint records specific to equity securities and portfolios. Captures restriction type (regulatory, mandate, ESG exclusion, sanctions, internal policy), restricted security or issuer, restriction scope (buy, sell | 40 |
| portfolio_stewardship | short_interest | transactional_data | Short interest and securities-lending data for equity positions, capturing both the fund's short positions and its stock-lending activity. Short-side fields: short position quantity, short position market value, settlement status, and compliance flags for | 44 |
| research_analysis | earnings_announcement |  | Earnings announcement for a listed security including actual vs consensus EPS. | 10 |
| research_analysis | equity_coverage | master_data | Internal equity research coverage universe master, defining which listed securities are formally covered by the fund's internal equity research team. Captures coverage status (active, watch, dropped), assigned analyst, coverage initiation date, coverage | 41 |
| research_analysis | equity_factor_exposure | transactional_data | Equity factor exposure records for securities and portfolios based on Barra and CAPM factor models. Captures factor model version (Barra GEM, USE, EUE), exposure date, factor name (market beta, size, value, momentum, quality, low volatility, growth | 37 |
| research_analysis | price_target_evaluation |  | Outcome of one research price target at its horizon. | 6 |
| research_analysis | research_note | transactional_data | Internal equity research notes and investment theses produced by the fund's buy-side analysts for covered securities. Captures note type (initiation, update, earnings review, sector note, thematic), publication date, analyst, investment recommendation | 49 |
| research_analysis | stock_selection | transactional_data | Formal stock selection and portfolio-construction decision records produced by the equity investment team for securities in the coverage universe, bridging research output (research_note theses and valuation_model intrinsic values) to portfolio | 47 |
| research_analysis | valuation_model | transactional_data | Proprietary equity valuation model records maintained by the internal research team for covered securities. Captures model type (DCF, DDM, EV/EBITDA, P/E relative, sum-of-parts, NAV-based), model version, valuation date, intrinsic value estimate | 45 |

<a id="domain-infrastructure"></a>

### Domain: Infrastructure

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| infrastructure | operations | 4 | Domain for infrastructure investment operations covering direct infrastructure assets, infrastructure fund commitments, and greenfield/brownfield project investments. | 26 |

**Subdomains:** asset_ownership, capital_transactions, fund_investment, regulatory_compliance


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| asset_ownership | asset_ownership | master_data | Association record capturing the ownership and co-investment structure of each infrastructure asset: the pension fund's direct and co-invest equity stakes, co-investor and lead-sponsor stakes, GP carried-interest entitlement, and minority partner | 46 |
| asset_ownership | construction_milestone | transactional_data | Transactional record of construction and development milestones for greenfield and brownfield project investments, capturing milestone name, milestone type (financial close, construction start, mechanical completion, commissioning, COD), planned date | 34 |
| asset_ownership | infra_asset | master_data | Master record for direct infrastructure assets owned or co-owned by the pension fund, including toll roads, airports, ports, pipelines, utilities, energy transmission networks, water treatment facilities, and social infrastructure. | 63 |
| asset_ownership | infrastructure_capex_program | master_data | Master record for capital expenditure programs associated with infrastructure assets, capturing capex program name, type (maintenance capex, growth capex, regulatory capex, environmental upgrade), total approved budget, expenditure to date, forecast | 42 |
| asset_ownership | insurance_policy | master_data | Master record for insurance policies covering direct infrastructure assets, capturing insurer name, policy type (property all-risk, business interruption, third-party liability, political risk, construction all-risk, environmental liability), insured | 48 |
| asset_ownership | operator_contract | master_data | Master record for operational and management contracts with third-party operators, O&M contractors, and asset managers engaged to run infrastructure assets post-acquisition. | 47 |
| asset_ownership | ownership_agreement | master_data | Master reference table for ownership_agreement. Referenced by ownership_agreement_id. | 45 |
| capital_transactions | asset_disposition | transactional_data | Transactional record of full or partial dispositions (exits) of direct infrastructure assets or secondary sales of fund LP interests, capturing disposition date, buyer name, sale structure (full exit, partial sell-down, secondary LP sale, IPO/listing) | 49 |
| capital_transactions | availability_payment | transactional_data | Transactional record of availability payment receipts for PPP/PFI infrastructure assets where revenue is based on asset availability rather than usage. Captures payment period, contracted availability payment amount, actual availability achieved | 44 |
| capital_transactions | capital_call_notice_document | master_data | Master reference table for capital_call_notice_document. Referenced by notice_document_id. | 45 |
| capital_transactions | cashflow_projection | transactional_data | Transactional record of long-duration cash flow projections for direct infrastructure assets and project investments, capturing projection scenario (base, upside, downside, stress), projection date, forecast period (annual/quarterly), projected revenue | 35 |
| capital_transactions | distribution_event | transactional_data | Transactional record of cash distributions received from infrastructure fund GPs or direct asset operating entities. Captures distribution date, distribution amount, distribution type (return of capital, income, recallable capital, carried interest), DPI | 44 |
| capital_transactions | distribution_notice_document | master_data | Master reference table for distribution_notice_document. Referenced by distribution_notice_document_id. | 46 |
| capital_transactions | infrastructure_asset_valuation | transactional_data | Transactional record of periodic fair value assessments for direct infrastructure assets, capturing valuation date, valuation methodology (DCF, EV/EBITDA comparable, RAB multiple, independent appraisal), discount rate applied (WACC), terminal value | 44 |
| capital_transactions | infrastructure_capital_call | transactional_data | Transactional record of capital call (drawdown) notices received from infrastructure fund GPs or issued for direct co-investments. Captures call notice date, due date, called amount, cumulative PIC to date, call purpose (investment, fees, expenses | 43 |
| fund_investment | co_investment | master_data | Master record for infrastructure co-investment transactions where the pension fund invests alongside a GP or lead sponsor in a specific asset or project, outside of a fund vehicle. | 47 |
| fund_investment | fund_nav_report | transactional_data | Transactional record of periodic NAV reports received from external infrastructure fund GPs, capturing reporting period, reported NAV (total fund and fund's LP share), unrealized gain/loss, realized proceeds in period, management fee accrual, carried | 46 |
| fund_investment | infra_fund_commitment | master_data | Master record for the pension fund's LP commitments to infrastructure-focused closed-end funds and open-end vehicles managed by external GPs. Captures fund name, GP entity, vintage year, committed capital (e.g., EUR/USD), drawn capital (PIC), unfunded | 58 |
| fund_investment | infrastructure_debt_facility | master_data | Master record for project-level and asset-level debt financing facilities associated with infrastructure investments, capturing lender name, facility type (senior secured, mezzanine, subordinated, green bond, infrastructure bond), facility amount, drawn | 46 |
| fund_investment | infrastructure_ic_approval | transactional_data | Transactional record of Investment Committee approvals for infrastructure investments, capturing IC meeting date, investment name, approval type (initial approval, final approval, follow-on, disposal), approved commitment amount, approved structure | 45 |
| fund_investment | project_investment | master_data | Master record for greenfield and brownfield infrastructure project investments, capturing project name, development stage (pre-construction, construction, operational ramp-up, steady-state), project type (PPP, PFI, availability-payment, merchant), total | 52 |
| regulatory_compliance | concession_agreement | master_data | Master record for concession, license, or franchise agreements governing the right to operate regulated infrastructure assets. Captures concession grantor (government or regulatory body), concession term start and end dates, regulated return mechanism | 46 |
| regulatory_compliance | infrastructure_sector_classification | reference_data | Reference data for infrastructure sector and sub-sector classification taxonomy used to categorize assets and fund commitments. Captures sector name (Transport, Energy, Utilities, Social, Digital, Natural Resources), sub-sector (toll roads, airports | 38 |
| regulatory_compliance | regulated_return_model | master_data | Master record for the regulatory asset base (RAB) and allowed-return model applicable to regulated infrastructure assets, including the history of regulatory price determinations. | 40 |
| regulatory_compliance | regulatory_review | transactional_data | Transactional record of regulatory price reviews and determinations for regulated infrastructure assets, capturing review type (periodic determination, interim review, appeal), regulator name, review submission date, draft determination date, final | 42 |
| regulatory_compliance | tariff_schedule | master_data | Master record for tariff, toll, and user-charge schedules applicable to revenue-generating infrastructure assets, capturing tariff effective date, tariff category (vehicle class, passenger type, commodity type), base tariff rate, inflation escalation | 42 |

<a id="domain-naturalresource"></a>

### Domain: Naturalresource

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| naturalresource | operations | 4 | Domain for natural resources and commodities investment operations including timberland, farmland, mining, energy, and commodity-linked fund investments. Owns resource asset records, production data, commodity price exposures, depletion schedules, and | 24 |

**Subdomains:** asset_ownership, financial_valuation, operations_production, sustainability_compliance


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| asset_ownership | land_parcel | master_data | Geospatial and legal description master record for land parcels underlying timberland, farmland, and surface rights of mining/energy assets. Captures parcel identifier (legal land description, cadastral reference), total area (hectares), land use | 44 |
| asset_ownership | operator_agreement | master_data | Master record for operating agreements, joint venture agreements, and management contracts governing natural resource assets. Captures operator/JV partner name, LEI, agreement type (operating agreement, JV, farm-out, royalty agreement, offtake agreement) | 44 |
| asset_ownership | resource_asset | master_data | SSOT for natural resource asset identity within the naturalresource domain. Master record for each physical resource asset held by the pension fund: timberland parcels, farmland tracts, mining concessions, energy assets (upstream oil & gas, renewables) | 54 |
| asset_ownership | resource_fund_commitment | master_data | Commitment record for natural resource fund investments where the pension fund participates as an LP in a dedicated natural resource fund (timberland fund, farmland fund, commodity fund, energy fund). | 46 |
| asset_ownership | resource_holding | master_data | SSOT for the pension fund's economic interest in each natural resource vehicle — both direct asset holdings and LP/fund commitments. Tracks committed capital, invested capital (PIC), remaining unfunded commitment (dry powder), ownership percentage | 50 |
| asset_ownership | resource_vehicle | master_data | Master reference table for resource_vehicle. Referenced by resource_vehicle_id. | 46 |
| financial_valuation | capital_event | transactional_data | Records all capital flow events for natural resource holdings including capital calls (drawdowns), distributions (return of capital, income distributions), recallable distributions, and capital recycling events. | 45 |
| financial_valuation | commodity_exposure | master_data | Tracks the fund's commodity price exposure arising from natural resource holdings. Captures commodity type (lumber, wheat, corn, soy, crude oil, natural gas, copper, gold, iron ore), notional exposure in USD, exposure as % of AUM, benchmark commodity | 47 |
| financial_valuation | commodity_price_deck | reference_data | Reference price deck for commodities used in DCF valuation, budget forecasting, and stress testing of natural resource assets. Captures commodity type, scenario (base/bull/bear/stress), price per unit by horizon (short/medium/long-term), currency | 44 |
| financial_valuation | resource_budget | master_data | Annual operating and capital expenditure budget for each natural resource asset. Captures budget year, budget type (opex, capex, sustaining capex, growth capex, reclamation/closure), budget amount by category, approved production volume targets, commodity | 43 |
| financial_valuation | resource_cashflow | transactional_data | Periodic cash flow records at the asset level capturing all cash inflows and outflows from natural resource operations. Includes revenue from commodity sales, royalty payments, operating expenses, capital expenditures, reclamation fund contributions | 46 |
| financial_valuation | resource_valuation | transactional_data | Periodic fair value and NAV determination records for natural resource assets, capturing valuation methodology (DCF, comparable transaction, NAV, appraisal), discount rate (WACC), terminal value assumptions, commodity price deck used, inflation | 48 |
| financial_valuation | royalty_obligation | master_data | Tracks royalty, overriding royalty interest (ORRI), net profits interest (NPI), and government royalty obligations attached to natural resource assets. Captures royalty type, royalty rate (%), royalty holder (government, private landowner, indigenous | 44 |
| financial_valuation | royalty_payment | transactional_data | Transactional record of each royalty payment disbursed against a royalty obligation. Captures payment date, payment period covered, production volume basis, commodity price applied, gross revenue base, royalty rate applied, payment amount (local currency | 43 |
| operations_production | depletion_schedule | master_data | Asset-level depletion, amortization, and depreciation schedule for wasting natural resource assets. Captures depletion method (unit-of-production, straight-line, declining balance), total proven reserves at acquisition, cumulative depletion to date | 43 |
| operations_production | harvest_plan | master_data | Timber and agricultural harvest planning records for timberland and farmland assets. Captures plan year, harvest area (hectares), planned harvest volume by species/crop type, harvest method (clear-cut, selective, sustainable yield), planned harvest dates | 45 |
| operations_production | offtake_agreement | master_data | Master record for offtake agreements and commodity sales contracts governing the sale of production output from natural resource assets. Captures counterparty name, LEI, commodity type, contract volume (annual/total), pricing mechanism (fixed, floating | 44 |
| operations_production | operational_incident | transactional_data | Records operational incidents, disruptions, and force majeure events affecting natural resource asset operations. Captures incident type (weather event, equipment failure, regulatory shutdown, labor dispute, environmental spill, wildfire, flood), incident | 46 |
| operations_production | production_record | transactional_data | Operational production data captured at the asset level on a periodic basis (monthly/quarterly). Records physical output volumes for each resource type: timber harvest volumes (m³/MBF), crop yields (bushels/tonnes), mineral extraction tonnage, oil & gas | 43 |
| operations_production | reserve_estimate | master_data | Proven, probable, and possible (3P) reserve estimates for extractive resource assets (mining, oil & gas). Captures reserve category (1P/2P/3P per SPE-PRMS or JORC standards), commodity type, estimated recoverable quantity, unit of measure, effective date | 43 |
| sustainability_compliance | carbon_credit | master_data | Tracks carbon credits, carbon offsets, and REDD+ credits generated by or associated with natural resource assets (particularly timberland and farmland). Captures credit type (voluntary, compliance, REDD+, afforestation), registry (Gold Standard, Verra | 41 |
| sustainability_compliance | carbon_project | master_data | Master reference table for carbon_project. Referenced by project_id. | 47 |
| sustainability_compliance | environmental_permit | master_data | Registry of environmental, operating, and extraction permits required for natural resource asset operations. Captures permit type (environmental assessment, extraction license, water use, emissions, land clearing), issuing regulatory authority, permit | 45 |
| sustainability_compliance | reclamation_liability | master_data | Asset retirement obligation (ARO) and site reclamation liability records for mining, oil & gas, and other extractive resource assets. Captures estimated reclamation cost (undiscounted), discount rate applied, present value of ARO, accretion expense per | 47 |

<a id="domain-portfolio"></a>

### Domain: Portfolio

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| portfolio | operations | 4 | Authoritative domain for investment portfolio structure and construction across all asset classes—public equities, private equity, real estate, infrastructure, natural resources, and credit. | 26 |

**Subdomains:** allocation_strategy, compliance_benchmarking, portfolio_structure, position_valuation


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| allocation_strategy | asset_class_weight | transactional_data | Current actual asset class weight record for a portfolio as of a valuation date, capturing the realized allocation to each asset class (public equity, private equity, real estate, infrastructure, natural resources, credit, cash) expressed as a percentage | 38 |
| allocation_strategy | portfolio_allocation | association_data | This association product represents the Allocation event between portfolio and opportunity. It captures the formal assignment of capital from a specific investment portfolio to a specific investment opportunity, including the percentage of the deal | 7 |
| allocation_strategy | portfolio_capital_commitment | transactional_data | Record of capital committed to a portfolio or investment program from the pension fund's net contributions and asset allocation decisions. Captures committed amount, funded amount, unfunded (dry powder) balance, commitment currency, commitment date | 47 |
| allocation_strategy | portfolio_ic_approval | transactional_data | Investment Committee (IC) approval record for portfolio-level decisions including SAA changes, new mandate approvals, rebalancing authorizations, benchmark changes, and capital commitment approvals. | 52 |
| allocation_strategy | rebalancing_event | transactional_data | Transactional record capturing each portfolio rebalancing event triggered by drift from SAA/TAA targets or scheduled periodic rebalancing. Records trigger type (drift breach, scheduled, tactical decision, mandate change), target weights before and after | 44 |
| allocation_strategy | saa_target | master_data | Strategic Asset Allocation (SAA) policy record defining long-term policy weights per asset class for a portfolio or fund, together with the realized actual weight for drift monitoring. | 40 |
| allocation_strategy | taa_position | transactional_data | Tactical Asset Allocation (TAA) position record capturing the current tactical over/underweight deviation from SAA targets for each asset class within a portfolio. | 37 |
| compliance_benchmarking | benchmark_assignment | association_data | Association record linking a portfolio to its assigned benchmark(s) with effective date ranges, assignment type (primary, secondary, risk benchmark, liability benchmark), and weighting for blended benchmarks. | 26 |
| compliance_benchmarking | constraint | master_data | Business rule record defining investment constraints and guidelines applicable to a portfolio or mandate, as monitored in BlackRock Aladdin compliance engine. | 45 |
| compliance_benchmarking | constraint_breach | transactional_data | Transactional record of each investment guideline or mandate constraint breach detected during pre-trade or post-trade compliance monitoring in BlackRock Aladdin or Charles River IMS. | 46 |
| compliance_benchmarking | gips_composite | master_data | GIPS (Global Investment Performance Standards) composite master record grouping portfolios with similar investment mandates for standardized performance presentation. | 40 |
| compliance_benchmarking | portfolio_benchmark | master_data | Authoritative benchmark registry AND portfolio-benchmark assignment record. Masters each investment benchmark assigned to portfolios—market indices (MSCI World, FTSE All-World, Bloomberg Aggregate), custom blended benchmarks, and liability benchmarks for | 36 |
| compliance_benchmarking | portfolio_composite_membership | association_data | Association record tracking the inclusion of individual portfolios within GIPS composites over time, with effective start and end dates, inclusion reason, and exclusion reason (if applicable). | 38 |
| portfolio_structure | asset | master_data | Master reference table for asset. Referenced by asset_id. | 46 |
| portfolio_structure | hierarchy | master_data | Defines the parent-child structure across portfolio nodes, enabling composite/sleeve/sub-portfolio relationships in multi-asset, fund-of-funds, and sleeve-based mandates, plus consolidated reporting. | 35 |
| portfolio_structure | mandate_history | transactional_data | Audit history record tracking all changes to portfolio mandate parameters over time, including SAA target revisions, benchmark changes, constraint amendments, currency policy updates, and mandate scope expansions or restrictions. | 42 |
| portfolio_structure | portfolio | master_data | Master record for each investment portfolio managed by the fund—the authoritative IBOR/ABOR portfolio entity maintained in SimCorp Dimension. Captures portfolio identity, mandate type (SAA/TAA), asset-class scope, base currency, inception date, regulatory | 56 |
| portfolio_structure | portfolio_mandate | master_data | Authoritative master record for each investment mandate governing a portfolio or sleeve. Captures mandate type (internal, SMA, LP mandate, co-investment), investment universe constraints, permitted asset classes, geographic restrictions, currency hedging | 48 |
| portfolio_structure | sleeve | master_data | Master record for a portfolio sleeve — a ring-fenced sub-allocation within a portfolio dedicated to a specific asset class, strategy, or manager mandate. Captures sleeve name, sleeve type (asset class sleeve, manager sleeve, strategy sleeve), target | 53 |
| portfolio_structure | tax_lot | master_data | Master reference table for tax_lot. Referenced by tax_lot_id. | 44 |
| position_valuation | currency_exposure | transactional_data | Portfolio-level currency exposure record capturing the unhedged and hedged foreign currency exposures as of a valuation date. Records base currency, foreign currency, gross exposure amount, hedge ratio, hedged notional, net unhedged exposure, and FX | 39 |
| position_valuation | holding | transactional_data | IBOR (Investment Book of Record) position record representing the authoritative current holding of a security or asset within a portfolio as of a given date. | 51 |
| position_valuation | holding_snapshot | transactional_data | Point-in-time snapshot of portfolio holdings captured at end-of-day or month-end for historical analysis, regulatory reporting, and performance attribution. | 48 |
| position_valuation | liquidity_bucket | transactional_data | Portfolio liquidity classification record bucketing holdings into liquidity tiers (T+0, T+1, T+2, T+5, T+30, T+90, T+180, illiquid/locked) based on instrument type, market depth, and redemption terms. | 44 |
| position_valuation | portfolio_cash_flow | transactional_data | Portfolio-level cash flow record capturing all inflows and outflows at the portfolio level including net contributions received, capital calls paid, distributions received, dividend and coupon income, management fees paid, FX settlements, and | 48 |
| position_valuation | portfolio_nav_record | transactional_data | Net Asset Value (NAV) record for a portfolio as of a specific valuation date, representing the authoritative portfolio-level NAV as calculated by the fund administrator (State Street / Northern Trust) and reconciled against the IBOR. | 43 |

<a id="domain-privateequity"></a>

### Domain: Privateequity

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| privateequity | operations | 3 | Domain for private equity and co-investment operations including LP/GP fund structures, vintage year tracking, capital calls (drawdowns), distributions, J-Curve modeling, dry powder tracking, and carried interest waterfall calculations. | 24 |

**Subdomains:** capital_flows, fund_structure, performance_analytics


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| capital_flows | capital_account | transactional_data | LP capital account ledger record tracking the pension fund's running capital account balance within each PE fund. Captures opening balance, contributions in period, distributions in period, management fee allocations, carried interest allocations | 44 |
| capital_flows | carried_interest_waterfall | transactional_data | Transactional record tracking the carried interest waterfall calculation for each PE fund at each reporting period. Captures total fund distributions to date, return of capital tranche, preferred return accrual, GP catch-up amount, carried interest earned | 33 |
| capital_flows | distribution | transactional_data | Transactional record of each cash or in-kind distribution received from a PE fund. Captures distribution notice date, payment date, distribution amount, distribution currency, distribution type (return of capital, realized gain, dividend, in-kind) | 45 |
| capital_flows | management_fee_invoice | transactional_data | Transactional record for GP management fee invoices received against each PE fund commitment: invoice date, fee period, fee basis (committed/invested capital/NAV), fee rate applied, gross fee, fee offset credits (monitoring/transaction fees), net fee | 39 |
| capital_flows | privateequity_capital_call | transactional_data | Transactional record of each capital call (drawdown notice) issued by a GP to the pension fund as LP. Captures call notice date, due date, call amount, call currency, call sequence number, call purpose (investment, management fees, fund expenses | 45 |
| capital_flows | privateequity_cash_flow | transactional_data | Granular transactional record of all cash flows associated with PE investments — capital calls, distributions, management fees, fund expenses, and recallable distributions. | 47 |
| capital_flows | secondary_transaction | transactional_data | Transactional record for secondary market purchases or sales of LP interests in PE funds. Captures transaction type (buy/sell), counterparty, fund interest being transacted, face value of commitment, purchase/sale price, discount or premium to NAV (%) | 40 |
| fund_structure | coinvestment | master_data | Master record for co-investment opportunities where the pension fund invests directly alongside a GP in a specific portfolio company, outside the main fund vehicle. | 47 |
| fund_structure | fof_vehicle | master_data | Master reference table for fof_vehicle. Referenced by fof_vehicle_id. | 47 |
| fund_structure | fund | master_data | Master record for each private equity fund vehicle in which the pension fund holds an LP interest or manages as a GP. Captures fund name, vintage year, fund type (buyout, venture, growth, secondaries, FoF, co-invest), target size, hard cap, fund currency | 61 |
| fund_structure | fund_commitment | master_data | Records the pension fund's LP capital commitment to a specific PE fund, including committed capital amount, commitment currency, commitment date, vintage year, commitment status (active, fully drawn, terminated), total paid-in capital (PIC), remaining | 47 |
| fund_structure | fund_of_funds_allocation | master_data | Master record for Fund-of-Funds (FoF) allocations where the pension fund invests in a FoF vehicle that in turn allocates to underlying PE funds. Captures FoF vehicle name, FoF manager, total FoF commitment, the pension fund's LP interest in the FoF | 44 |
| fund_structure | gp_entity | master_data | Master record for each General Partner (GP) entity managing PE funds in which the pension fund is an LP. Captures GP legal name, LEI, domicile, AUM, fund count, strategy focus, key investment professionals, GP track record summary, GP ownership structure | 47 |
| fund_structure | investment | master_data | Master record for each direct private equity investment or fund-level portfolio company investment. Captures investment name, investment type (direct, co-invest, secondary, FoF), asset class sub-type (buyout, growth equity, venture, distressed), entry | 49 |
| fund_structure | lp_entity | master_data | Master reference table for lp_entity. Referenced by lp_entity_id. | 43 |
| fund_structure | lpa_terms | master_data | Structured record of the key economic and governance terms extracted from each Limited Partnership Agreement (LPA). Captures management fee rate, management fee basis (committed vs. | 46 |
| fund_structure | portfolio_company | master_data | Master record for each portfolio company held directly or indirectly through PE fund investments. Captures company name, LEI, jurisdiction of incorporation, sector (GICS), sub-sector, business description, revenue (latest), EBITDA (latest), enterprise | 46 |
| performance_analytics | gp_report | transactional_data | Transactional record for each GP quarterly or annual fund report received by the pension fund as LP. Captures report type (quarterly, annual, audited), reporting period, receipt date, GP fund NAV reported, portfolio company count, new investments in | 47 |
| performance_analytics | jcurve_projection | master_data | Forward-looking J-Curve cash flow projection model for each PE fund commitment, capturing projected capital call schedule by period, projected distribution schedule by period, projected NAV trajectory, expected IRR at various exit scenarios, break-even | 47 |
| performance_analytics | lp_advisory_committee | master_data | Master record for LP Advisory Committee (LPAC) membership and governance for each PE fund. Captures fund reference, LPAC member name, member organization, seat type (voting, observer), appointment date, term expiry, conflict of interest disclosure status | 35 |
| performance_analytics | nav | transactional_data | Periodic NAV (Net Asset Value) record for each PE fund commitment and direct PE investment, capturing the GP-reported fair value, gross asset value (GAV), net asset value (NAV), unrealized value, realized value, total value (NAV + distributions), TVPI | 46 |
| performance_analytics | privateequity_benchmark | reference_data | Reference data for PE performance benchmarks used to evaluate fund and portfolio performance. Captures benchmark name, benchmark provider (Cambridge Associates, Preqin, Burgiss, MSCI), benchmark type (pooled IRR, horizon IRR, PME), asset class scope | 42 |
| performance_analytics | privateequity_coverage | association_data | This association product represents the research coverage relationship between private equity funds and research reports. It captures which research publications are relevant to which fund vehicles, enabling investment professionals to retrieve all | 5 |
| performance_analytics | value_creation_plan | master_data | Master record for post-acquisition value creation plans for direct PE investments and co-investments. Captures investment reference, value creation theme (operational efficiency, revenue growth, M&A bolt-on, ESG improvement, management change | 46 |

<a id="domain-realestate"></a>

### Domain: Realestate

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| realestate | operations | 4 | Domain for real estate investment operations including direct property holdings, REIT positions, real estate fund investments, and property-level asset management. | 25 |

**Subdomains:** asset_operations, capital_transactions, fund_investments, leasing_tenancy


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| asset_operations | asset_business_plan | master_data | Annual asset business plan records for each directly held property, capturing the strategic asset management plan approved by the investment committee. Includes target NOI for the plan year, leasing strategy (target tenants, target rents, incentive | 44 |
| asset_operations | capex_expenditure | transactional_data | Individual capital expenditure transaction records within an approved capex program. Captures expenditure date, vendor/contractor, work order reference, expenditure category (hard costs, soft costs, FF&E, contingency), invoiced amount, approved amount | 49 |
| asset_operations | esg_property_assessment | transactional_data | ESG and sustainability assessment records at the property level capturing environmental certifications (LEED, BREEAM, NABERS, ENERGY STAR), GHG emissions (Scope 1, 2, 3), energy intensity (kWh/sqm), water intensity, waste diversion rate, green lease | 48 |
| asset_operations | noi_record | transactional_data | Net Operating Income (NOI) records calculated at the property level on a periodic basis (monthly, quarterly, annual). Captures gross potential rent, effective gross income, vacancy and credit loss, operating expenses (property taxes, insurance | 36 |
| asset_operations | property | master_data | Master record (SSOT) for each direct real estate asset held by the pension fund — commercial office, industrial/logistics, retail, residential, mixed-use, and specialty. | 46 |
| asset_operations | property_insurance | master_data | Insurance policy records for each property asset covering property damage, liability, business interruption, and environmental risk. Captures insurer name, policy number, coverage type, insured value, annual premium, policy inception and expiry dates | 46 |
| asset_operations | property_operating_expense | transactional_data | Detailed operating-expense line records that roll up into the property-level NOI ledger (noi_record). Captures expense date, category (property tax, insurance, utilities, maintenance, cleaning, security, management fee, leasing commission), vendor | 44 |
| asset_operations | property_valuation | transactional_data | Periodic valuation records for each property asset capturing appraised GAV, NAV, cap rate, discount rate, terminal cap rate, DCF-based valuation, independent appraiser details, valuation methodology (income approach, sales comparison, cost approach) | 41 |
| asset_operations | realestate_capex_program | master_data | Capital expenditure program records for post-acquisition value creation initiatives at the property level. Captures program name, type (repositioning, refurbishment, development, ESG retrofit, tenant improvement), approved budget, committed spend, actual | 44 |
| capital_transactions | budget_line_item | master_data | Master reference table for budget_line_item. Referenced by budget_line_item_id. | 46 |
| capital_transactions | jv_structure | master_data | Joint venture (JV) and co-investment structure records for properties held through partnership vehicles. Captures JV entity name, legal structure (LP, LLC, trust, REIT), pension fund ownership percentage, co-investor identities and ownership percentages | 46 |
| capital_transactions | ltv_dscr_covenant | transactional_data | Periodic LTV (Loan-to-Value) and DSCR (Debt Service Coverage Ratio) covenant compliance records calculated at the property and debt facility level. Captures measurement date, current property GAV, outstanding debt balance, calculated LTV ratio, LTV | 37 |
| capital_transactions | property_acquisition | transactional_data | Transaction record for each direct property acquisition executed by the pension fund. Captures acquisition date, purchase price, transaction costs (stamp duty, legal, advisory), financing structure (equity/debt split), acquisition yield (initial yield | 52 |
| capital_transactions | property_disposal | transactional_data | Transaction record for each direct property disposal (sale, partial sale, recapitalisation) executed by the pension fund. Captures disposal date, gross sale price, transaction costs, net proceeds, book value at disposal, realised gain/loss, exit cap rate | 38 |
| capital_transactions | realestate_debt_facility | master_data | Property-level debt financing records capturing mortgage and construction loan facilities secured against real estate assets. Captures lender identity, facility type (senior mortgage, mezzanine, construction loan, revolving credit), facility limit, drawn | 47 |
| fund_investments | property_allocation | association_data | This association product represents the allocation of direct real estate property ownership across investment portfolios. It captures the ownership stake, effective period, and allocation strategy for each portfolio-property combination. | 7 |
| fund_investments | re_capital_call | transactional_data | Capital call (drawdown) transaction records issued by real estate fund GPs to the pension fund as LP. Captures call notice date, due date, call amount, call purpose (acquisition, capex, fees, expenses), cumulative paid-in capital post-call, fund | 38 |
| fund_investments | re_distribution | transactional_data | Distribution transaction records received from real estate fund GPs representing return of capital, income distributions, and carried interest waterfalls. Captures distribution date, distribution type (income, return of capital, recapitalisation, carried | 43 |
| fund_investments | re_fund_commitment | master_data | Commitment records for real estate fund investments (closed-end real estate funds, open-end core funds, value-add funds, opportunistic funds) where the pension fund acts as an LP. | 46 |
| fund_investments | reit_position | master_data | Master record for listed REIT (Real Estate Investment Trust) positions held within the real estate allocation. Captures REIT name, ISIN, CUSIP, SEDOL, exchange, REIT sector (office, industrial, retail, residential, diversified, specialty), number of units | 43 |
| leasing_tenancy | lease | master_data | Master record for each tenant lease agreement at a property, capturing tenant identity, leased premises (suite, floor, GLA), lease commencement and expiry dates, lease type (gross, net, triple-net, modified gross), base rent, rent escalation schedule | 48 |
| leasing_tenancy | lease_rent_schedule | master_data | Detailed rent schedule for each lease, capturing all contractual rent payment periods, scheduled base rent amounts, rent step-up dates, CPI adjustment factors, effective rent per period, and cumulative rent to lease expiry. | 37 |
| leasing_tenancy | occupancy_record | transactional_data | Periodic occupancy and vacancy tracking records at the property and tenancy level. Captures measurement date, total GLA, occupied GLA, vacant GLA, physical occupancy rate, economic occupancy rate, vacancy type (structural, transitional, development) | 38 |
| leasing_tenancy | rent_collection | transactional_data | Transactional records of actual rent receipts collected from tenants against scheduled lease obligations. Captures invoice date, due date, payment received date, invoiced amount, received amount, arrears balance, payment method, and collection status | 40 |
| leasing_tenancy | tenant | master_data | Master record for each tenant occupying space across the real estate portfolio. Captures tenant legal name, trading name, industry sector (GICS classification), credit rating, LEI, KYC/AML status, parent entity, number of leases, total leased GLA, anchor | 46 |

<a id="domain-research"></a>

### Domain: Research

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| research | operations | 3 | Domain for macroeconomic research, market data management, and proprietary investment modeling. Owns macroeconomic indicator libraries, economic scenario definitions, market data feeds (Bloomberg Terminal, FactSet), proprietary macro models, sector and | 23 |

**Subdomains:** investment_research, macro_modeling, market_data


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| investment_research | analyst_assignment | transactional_data | Transactional record of research analyst assignments to coverage entities (issuers, sectors, geographies, asset classes) within the research coverage universe. | 49 |
| investment_research | asset_class_outlook | master_data | Master record of formal asset class outlook assessments produced by the research team covering all asset classes in the fund's SAA: public equities, private equity, real estate, infrastructure, natural resources, credit (IG, HY, private credit), and | 52 |
| investment_research | calendar | master_data | Master record of the research team's planned publication and event calendar, including scheduled macro indicator releases (e.g., CPI release dates, central bank meeting dates, earnings seasons), planned research report publication dates, IC presentation | 47 |
| investment_research | country_outlook | master_data | Master record of country and regional economic outlook assessments maintained by the research team, covering sovereign credit quality, political risk, regulatory environment, currency outlook, growth trajectory, and investment climate ratings. | 46 |
| investment_research | coverage_universe | master_data | Master record defining the research team's formally covered universe of issuers, sectors, geographies, and asset classes across ALL asset classes — including private markets, credit, and real assets — distinct from equity.coverage which is listed-equity | 42 |
| investment_research | ic_research_pack | master_data | Master record of research packages formally prepared and submitted to the Investment Committee (IC) in support of investment decisions. Captures IC meeting reference, investment opportunity reference, pack type (new investment, follow-on, divestment | 52 |
| investment_research | research_report | master_data | Master record of formal research publications produced by the internal research team across all publication types — sector, country/regional, thematic, asset-class, and macro outlooks plus IC-supporting investment memoranda. | 47 |
| investment_research | sector_outlook | master_data | Master record of formal sector and industry outlook assessments produced by the research team, covering GICS sectors and sub-industries relevant to the fund's equity, credit, and private markets portfolios. | 45 |
| investment_research | thematic_research | master_data | Master record of long-horizon thematic investment research produced by the research team covering structural trends relevant to the fund's long-duration mandate — e.g., energy transition, digital infrastructure, demographic shifts, deglobalization, AI | 42 |
| macro_modeling | capital_market_assumption | master_data | Master record of long-term capital market assumptions (CMAs) formally adopted by the research team for use in SAA optimization, ALM modeling, and actuarial liability matching. | 45 |
| macro_modeling | economic_scenario | master_data | Master record of named macroeconomic scenarios defined and maintained by the research team for use in portfolio stress testing, ALM modeling, and IC presentations. | 42 |
| macro_modeling | macro_indicator | master_data | Master library of macroeconomic indicators tracked and maintained by the research team, including GDP growth rates, inflation indices (CPI, PPI), unemployment rates, central bank policy rates, yield curves, PMI, credit spreads, and commodity price | 38 |
| macro_modeling | macro_indicator_observation | transactional_data | Transactional time-series records of macroeconomic indicator values, covering both observed/reported actuals and external consensus estimates, keyed to a macro_indicator at a point in time (daily, monthly, quarterly, annual). | 35 |
| macro_modeling | macro_model | master_data | Master record of proprietary macroeconomic models developed and maintained by the research team. Captures model name, model type (DCF, factor model, yield curve model, regression, Monte Carlo), asset class applicability, model version, methodology | 40 |
| macro_modeling | macro_model_run | transactional_data | Transactional record of each execution of a proprietary macro model, capturing the run date, input scenario reference, model version used, key output values (e.g., projected GDP, implied equity risk premium, fair value estimate, WACC), run status, and | 39 |
| macro_modeling | scenario_assumption | transactional_data | Detailed assumption records associated with each economic scenario, specifying the projected values or shocks applied to individual macroeconomic indicators within that scenario. | 37 |
| market_data | data_vendor | master_data | Reference master of external market data and research data vendors contracted by the fund, including Bloomberg, FactSet, Preqin, PitchBook, MSCI, and Refinitiv. | 44 |
| market_data | market_consensus | transactional_data | Transactional records of external market consensus estimates and forecasts collected from Bloomberg, FactSet, and sell-side aggregators for key macroeconomic indicators and security-level metrics (EPS, revenue, EBITDA, target price). | 46 |
| market_data | market_data_feed | master_data | Master catalogue of market data feed subscriptions and configurations managed by the research domain, covering Bloomberg Terminal, FactSet, Preqin, PitchBook, and MSCI data services. | 37 |
| market_data | market_data_snapshot | transactional_data | Transactional silver-layer store of normalized inbound market data values captured from external feeds at a point in time for a given security, index, instrument, or currency pair. | 45 |
| market_data | research_fx_rate | transactional_data | Transactional records of foreign exchange (FX) spot and forward rates captured from Bloomberg and treasury systems for all currency pairs relevant to the fund's global investment portfolio. | 37 |
| market_data | research_yield_curve | master_data | Master record of yield curve definitions tracked by the research team across sovereign and credit markets, including government yield curves (US Treasury, UK Gilts, German Bunds), swap curves (SOFR, SONIA), and credit spread curves by rating bucket (IG | 41 |
| market_data | yield_curve_point | transactional_data | Transactional time-series records of yield curve data points at specific tenors and observation dates. Captures yield curve reference, tenor (3M, 6M, 1Y, 2Y, 5Y, 10Y, 20Y, 30Y), observed yield or spread (bps), observation date, and data source. | 45 |

<a id="domain-risk"></a>

### Domain: Risk

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| risk | operations | 3 | Domain for enterprise risk management and macroeconomic stress testing including market risk (VaR, CVaR, DV01), liquidity risk, counterparty/credit risk, concentration risk, factor risk decomposition, scenario analysis, and sensitivity modeling. | 31 |

**Subdomains:** exposure_analytics, limit_governance, stress_testing


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| exposure_analytics | attribution | transactional_data | Transactional record of risk attribution decomposing total portfolio risk (active risk / tracking error) into contributing sources: factor risk, specific risk, asset class risk, geographic risk, and currency risk. | 40 |
| exposure_analytics | concentration_exposure | transactional_data | Transactional record of portfolio concentration risk measurements across multiple dimensions: single issuer, sector/industry, geography, asset class, currency, and counterparty. | 39 |
| exposure_analytics | factor | master_data | Master catalog of systematic risk factors used in factor-based risk decomposition and attribution across the investment portfolio. Covers equity style factors (value, momentum, quality, size, low-volatility), fixed income factors (duration, spread | 47 |
| exposure_analytics | factor_ic_correlation |  | Pairwise correlation of two factors information coefficients, one row per factor pair and period. | 6 |
| exposure_analytics | factor_ic_observation |  | Information coefficient of a factor signal, computed by the quant research team; one row per factor, period, holding period and sector. | 7 |
| exposure_analytics | factor_return | transactional_data | Transactional record of realized risk factor returns over defined periods, used for historical simulation VaR, factor model calibration, and performance attribution. | 43 |
| exposure_analytics | fx_risk_exposure | transactional_data | Transactional record of foreign exchange risk exposures across the investment portfolio, capturing unhedged and hedged currency positions by currency pair. | 42 |
| exposure_analytics | liquidity_risk_assessment | transactional_data | Transactional record of portfolio liquidity risk assessments measuring the ability to liquidate positions within defined time horizons without material market impact. | 44 |
| exposure_analytics | risk_counterparty_exposure | transactional_data | Transactional record of gross and net credit exposure to each counterparty across all OTC derivatives, repo agreements, securities lending, and unsettled trades. | 49 |
| exposure_analytics | risk_factor_exposure | transactional_data | Transactional record of a portfolio's or security's exposure to each systematic risk factor at a point in time, as computed by the risk model (MSCI Barra or BlackRock Aladdin). | 44 |
| exposure_analytics | var_calculation | transactional_data | Transactional record of each Value-at-Risk (VaR) and Conditional Value-at-Risk (CVaR) calculation run performed against a portfolio or position set. Captures calculation date, portfolio scope, risk model used, confidence level (95%, 99%), holding period | 42 |
| limit_governance | appetite_statement | master_data | Master record of the enterprise Risk Appetite Statement (RAS) defining the board-approved risk tolerance levels across risk categories: market risk, credit risk, liquidity risk, concentration risk, operational risk, and ESG risk. | 44 |
| limit_governance | calculation_run | master_data | Master reference table for calculation_run. Referenced by calculation_run_id. | 44 |
| limit_governance | credit_rating | master_data | Master record of external credit ratings assigned to issuers and instruments held in the portfolio, sourced from rating agencies (S&P, Moody's, Fitch) and internal credit assessment. | 44 |
| limit_governance | limit | master_data | Master registry of enterprise risk limits and thresholds governing investment exposures across all asset classes and portfolios. Captures limit type (VaR, CVaR, DV01, concentration, leverage, liquidity), limit value, breach tolerance bands, escalation | 40 |
| limit_governance | limit_assignment | association_data | Association record linking risk limits to specific portfolios, mandates, asset classes, or investment strategies. Captures the risk limit, the entity it applies to (portfolio, fund, asset class, manager mandate), effective start and end dates, assigned | 43 |
| limit_governance | limit_breach | transactional_data | Transactional record of each risk limit breach event detected during daily or intraday risk monitoring. Captures the breached limit, breach date and time, breached metric value vs limit threshold, breach severity (warning, soft breach, hard breach) | 44 |
| limit_governance | model | master_data | Master registry of quantitative risk models deployed across the enterprise for VaR, CVaR, factor risk, and stress testing. Records model name, model type (historical simulation, Monte Carlo, parametric), confidence level, lookback window, asset class | 36 |
| limit_governance | model_validation | master_data | Transactional record of risk model validation and backtesting activities required for model risk governance (model risk management guidance / SR 11-7 style). Captures the risk model validated, validation type (initial, periodic, backtest, benchmarking), validation date | 43 |
| limit_governance | risk_exception | transactional_data | Transactional record of formally approved exceptions to risk limits or investment policy constraints, where a portfolio is permitted to operate outside standard limits for a defined period. | 49 |
| limit_governance | risk_review | master_data | Master record of formal periodic risk reviews conducted by the Risk Management team covering portfolio-level risk assessment, limit compliance status, emerging risk identification, and risk governance actions. | 46 |
| limit_governance | validation_run | master_data | Master reference table for validation_run. Referenced by validation_run_id. | 44 |
| stress_testing | correlation_matrix | transactional_data | Transactional record of asset class and factor correlation matrices used in portfolio risk calculations. Captures matrix type (asset class, factor, currency), the set of assets or factors included, correlation coefficients, estimation methodology (rolling | 46 |
| stress_testing | dv01_sensitivity | transactional_data | Transactional record of DV01 (Dollar Value of a Basis Point) and broader interest rate sensitivity measures for fixed income and rate-sensitive positions. Captures position or portfolio identifier, DV01 amount, duration (modified, effective, key-rate) | 45 |
| stress_testing | factor_signal_prediction |  | One directional prediction of a factor signal for one security. | 10 |
| stress_testing | scenario_requirement | association_data | This association product represents the contractual requirement linking stress scenarios to compliance obligations. It captures which stress scenarios must be executed to satisfy which regulatory or policy obligations, along with execution tracking and | 9 |
| stress_testing | sensitivity_analysis | transactional_data | Transactional record of sensitivity analysis runs measuring portfolio or position value changes in response to defined single-factor shocks (e.g., equity market -10%, credit spreads +100bps, oil price -30%, inflation +50bps). | 45 |
| stress_testing | strategy_backtest_result |  | Simulated performance of a candidate strategy, one row per strategy, vintage and period. | 9 |
| stress_testing | stress_scenario | master_data | Master catalog of macroeconomic and market stress scenarios used for portfolio stress testing and sensitivity analysis. Each scenario defines a named event (e.g., 2008 GFC, COVID-19 shock, rate hike +300bps, oil price collapse), scenario type (historical | 52 |
| stress_testing | stress_test_result | transactional_data | Transactional record of the output from a stress test run applying a defined stress scenario to a portfolio or position set. Captures scenario applied, portfolio scope, stressed P&L impact (absolute and % of NAV), stressed VaR, stressed CVaR, asset class | 54 |
| stress_testing | stress_test_run | master_data | Master reference table for stress_test_run. Referenced by stress_test_run_id. | 42 |

<a id="domain-trade"></a>

### Domain: Trade

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| trade | operations | 3 | Domain for trade execution and settlement operations across all liquid asset classes—equities, fixed income, FX, and OTC derivatives. Owns order management (OMS/EMS via Charles River and Bloomberg AIM), trade blotter, execution details, T+2 settlement | 26 |

**Subdomains:** counterparty_cost, order_execution, settlement_clearing


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| counterparty_cost | broker | master_data | Master record for approved broker-dealers and execution counterparties used for trade execution across all asset classes. Captures broker legal name, LEI, BIC, regulatory registration numbers (FCA, SEC), approved asset classes, execution capabilities | 44 |
| counterparty_cost | broker_commission | transactional_data | Record of commission and transaction cost charges payable to a broker for trade execution services. Captures commission amount, commission rate (bps), commission type (explicit, soft dollar, research payment), trade reference, settlement currency, payment | 49 |
| counterparty_cost | instrument | master_data | Master reference record for all tradeable financial instruments across asset classes—equities, fixed income, FX, and OTC derivatives. Serves as the SSOT for instrument identity within the trade domain. | 47 |
| counterparty_cost | instrument_exclusion | association_data | This association product represents the application of an exclusion policy to a specific financial instrument. It captures the compliance relationship between ESG exclusion lists and tradeable instruments in the pension fund's investable universe. | 8 |
| counterparty_cost | trade_check | association_data | This association product represents the pre-trade compliance check event between an investment order and a compliance rule. It captures the result of validating each order against applicable compliance rules before execution, including the check outcome | 7 |
| counterparty_cost | transaction_cost | transactional_data | Comprehensive transaction cost SSOT capturing ALL explicit and implicit costs for a trade execution — including broker commission (with commission type: explicit, soft dollar, research payment, and soft-dollar research credit allocation per MiFID II | 49 |
| order_execution | algo_order | transactional_data | Algorithmic execution order record capturing the parameters and performance of algorithmic trading strategies used to execute large orders with minimal market impact. | 47 |
| order_execution | allocation_group | master_data | Master reference table for allocation_group. Referenced by allocation_group_id. | 41 |
| order_execution | amendment | transactional_data | Record of a post-trade amendment or correction applied to an executed trade. Captures amendment type (price correction, quantity adjustment, settlement date change, counterparty correction), original trade reference, amended field name, old value, new | 43 |
| order_execution | blotter | transactional_data | Consolidated intraday trade blotter record aggregating all executed trades across asset classes for a given trading day. Serves as the authoritative daily trade register for the investment book of record (IBOR). | 50 |
| order_execution | execution | transactional_data | Trade execution record capturing the actual fill details from the market or execution venue. Represents a single execution event against a parent order, including executed price, executed quantity, execution timestamp, execution venue (exchange, ECN | 46 |
| order_execution | execution_venue | master_data | Master reference record for approved execution venues including regulated markets (exchanges), multilateral trading facilities (MTFs), systematic internalisers (SIs), and OTC bilateral venues. | 39 |
| order_execution | fx_trade | transactional_data | Foreign exchange trade record capturing spot, forward, and swap FX transactions executed to fund investments, repatriate proceeds, or hedge currency exposure. | 51 |
| order_execution | order | transactional_data | Core order management record representing an investment order originating from portfolio managers via Charles River IMS or Bloomberg AIM across all liquid asset classes (equities, fixed income, FX, OTC derivatives). | 54 |
| order_execution | order_allocation | transactional_data | Broker and account allocation record that splits a parent order across multiple portfolios, accounts, or sub-mandates. Captures the allocation quantity, allocated notional, target portfolio, allocation percentage, allocation status, and the broker or | 41 |
| order_execution | otc_derivative | transactional_data | OTC derivative trade record for bilaterally negotiated derivative contracts including interest rate swaps, credit default swaps (CDS), total return swaps, and equity derivatives. | 52 |
| order_execution | status_history | transactional_data | Immutable trade audit and lifecycle trail capturing every change to a trade from order creation through settlement. Records both (a) status transitions — status_from, status_to, triggering event (execution, confirmation, settlement, cancellation), system | 44 |
| settlement_clearing | ccp_clearing | transactional_data | Central counterparty clearing record for exchange-traded and cleared OTC derivatives submitted to a CCP (e.g., LCH, CME Clearing, Eurex). Captures CCP name, clearing member, cleared trade reference, initial margin requirement, variation margin, clearing | 47 |
| settlement_clearing | clearing_house | master_data | Master reference table for clearing_house. Referenced by clearing_house_id. | 44 |
| settlement_clearing | confirmation | transactional_data | Trade confirmation record representing the bilateral agreement between the pension fund and its counterparty confirming trade economics. Captures confirmation type (electronic via SWIFT/FIX, verbal, written), confirmation status (unconfirmed, matched | 44 |
| settlement_clearing | custodian | master_data | Master reference table for custodian. Referenced by custodian_id. | 44 |
| settlement_clearing | custody_account | master_data | Master record for custody accounts held at custodian banks (State Street, Northern Trust) used to hold securities and cash on behalf of the pension fund's portfolios. | 48 |
| settlement_clearing | netting_set_inclusion | association_data | This association product represents the inclusion of an OTC derivative trade within a netting agreement for exposure calculation and close-out netting purposes. | 8 |
| settlement_clearing | settlement_fail | transactional_data | Record of a settlement failure event where a trade did not settle on the contractual settlement date. Captures fail date, fail reason code (insufficient securities, cash shortfall, counterparty fail, SSI mismatch), fail duration in days, buy-in risk flag | 40 |
| settlement_clearing | settlement_instruction | transactional_data | Settlement instruction record governing the delivery and payment mechanics for a trade. Captures settlement date (T+2 standard or contractual), settlement method (DVP, FOP, DFP), settlement currency, custodian account, depository (DTC, Euroclear | 44 |
| settlement_clearing | standing_settlement_instruction | master_data | Standard Settlement Instruction master record defining the standing settlement details for a counterparty and instrument combination. Captures SSI version, effective date, expiry date, counterparty LEI, custodian BIC, depository account number, settlement | 45 |

<a id="domain-treasury"></a>

### Domain: Treasury

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| treasury | operations | 3 | Domain for treasury operations, liquidity management, cash management, and FX hedging. Owns cash position records, liquidity forecasts, net contribution inflows, capital call funding workflows, FX forward/swap positions and hedge ratios, currency exposure | 26 |

**Subdomains:** cash_liquidity, currency_hedging, investment_counterparty


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| cash_liquidity | capital_call_funding | transactional_data | Operational records tracking the funding workflow for private market capital calls (drawdowns) issued by GPs across private equity, infrastructure, real estate, and natural resources funds. | 47 |
| cash_liquidity | cash_account | master_data | Master record for each cash and settlement account maintained at custodian banks (State Street, Northern Trust) and internal treasury accounts. Captures account number, BIC/SWIFT, IBAN, correspondent bank details, currency, account type (settlement | 53 |
| cash_liquidity | cash_flow_event | transactional_data | Granular record of each expected or actual cash flow event feeding into the liquidity forecast, including scheduled capital calls, LP distributions received, coupon and dividend receipts, bond maturities, FX hedge settlements, management fee payments | 52 |
| cash_liquidity | cash_position | master_data | Authoritative IBOR/ABOR cash position record for each currency account held at custodians (State Street / Northern Trust). Captures intraday and end-of-day cash balances, projected cash, ledger cash, and custody cash across all fund entities and currency | 44 |
| cash_liquidity | cash_reconciliation | transactional_data | Daily reconciliation records comparing internal IBOR cash positions (SimCorp Dimension) against custodian-reported cash balances (State Street / Northern Trust) by account and currency. | 48 |
| cash_liquidity | cash_transfer | transactional_data | Operational record for each internal and external cash movement initiated by treasury, including inter-account and overnight/threshold-triggered sweeps, custodian-to-custodian transfers, capital call wire payments, distribution receipts, and FX settlement | 50 |
| cash_liquidity | distribution_receipt | transactional_data | Records of cash distributions received from private market fund investments (private equity, infrastructure, real estate, natural resources) including return of capital, realized gain distributions, income distributions, and recallable distributions. | 49 |
| cash_liquidity | liquidity_forecast | transactional_data | Forward-looking liquidity projection records covering short-term (T+1 to T+30), medium-term (T+30 to T+90), and long-term (T+90 to T+365) horizons. Aggregates expected net contribution inflows from beneficiary pools (several participating plans | 41 |
| cash_liquidity | liquidity_reserve_policy | master_data | Master record defining the liquidity reserve policy parameters governing minimum cash buffer requirements, liquidity tier classifications, and stress liquidity thresholds. | 42 |
| cash_liquidity | net_contribution_inflow | transactional_data | Records of net pension contributions received from each beneficiary pool (one per participating plan) representing the primary source of investable capital. | 32 |
| cash_liquidity | sweep_instruction | master_data | Automated and manual cash sweep instruction records governing the movement of excess cash from operating accounts into short-term liquidity instruments or between custodian accounts. | 46 |
| currency_hedging | fx_forward | transactional_data | Transactional record for each FX forward contract executed to hedge currency exposure arising from non-base-currency investments. Captures trade date, value date, maturity date, buy currency, sell currency, notional amount, forward rate, spot rate at inception | 54 |
| currency_hedging | fx_hedge_rebalance | transactional_data | Operational records capturing each FX hedge rebalancing event triggered when currency exposures drift outside the permitted hedge ratio band defined in the hedge program. | 48 |
| currency_hedging | fx_position | master_data | Master record of the fund's aggregate foreign exchange exposure by currency pair, capturing spot exposure, forward hedge notional, net open exposure, hedge ratio, and target hedge ratio per currency. | 38 |
| currency_hedging | fx_swap | transactional_data | Transactional record for FX swap contracts used to roll FX forward hedges or manage short-term currency liquidity needs. Captures near leg and far leg details (dates, rates, notionals), currency pair, counterparty, ISDA agreement reference, purpose (hedge | 53 |
| currency_hedging | hedge_effectiveness | transactional_data | Periodic assessment records of FX hedge effectiveness under IFRS 9 hedge accounting requirements. Captures assessment date, hedge program reference, hedging instrument, hedged item, prospective effectiveness test method (regression, dollar-offset) | 45 |
| currency_hedging | hedge_program | master_data | Master record defining the FX hedging program parameters for each currency or asset class exposure. Captures target hedge ratio, permitted hedge ratio band (min/max), hedging instruments allowed (forwards, swaps, options), rebalancing trigger thresholds | 44 |
| currency_hedging | treasury_fx_rate | reference_data | Reference data table for official FX spot rates and forward points by currency pair and tenor, sourced from Bloomberg. Captures rate date, currency pair, spot rate, bid/ask spread, forward points by tenor (1W, 1M, 3M, 6M, 1Y), rate source, and rate type | 38 |
| investment_counterparty | bank_account_ssi | reference_data | Standard Settlement Instructions (SSI) reference records for each custodian bank account and counterparty settlement account used in treasury operations. Captures account name, account number, BIC/SWIFT code, IBAN, correspondent bank details, currency | 43 |
| investment_counterparty | counterparty_limit | master_data | Treasury counterparty credit limit records defining the maximum permissible exposure to each bank or dealer counterparty for FX forwards, FX swaps, and short-term instrument transactions. | 44 |
| investment_counterparty | gp_bank_account | master_data | Master reference table for gp_bank_account. Referenced by gp_bank_account_id. | 47 |
| investment_counterparty | short_term_instrument | master_data | Master record for short-term liquidity instruments held in the treasury portfolio including T-Bills, SOFR-linked instruments, commercial paper, bankers acceptances, and money market fund units. | 46 |
| investment_counterparty | sofr_benchmark | reference_data | Reference data for SOFR (Secured Overnight Financing Rate) and related overnight/term benchmark rates used to price SOFR-linked short-term instruments, calculate floating rate accruals, and benchmark treasury portfolio returns. | 32 |
| investment_counterparty | st_instrument_transaction | transactional_data | Transactional records for purchases, maturities, sales, and rollovers of short-term liquidity instruments (T-Bills, SOFR-linked, commercial paper). Captures transaction type, trade date, settlement date, instrument reference, face value, consideration | 38 |
| investment_counterparty | treasury_counterparty_exposure | transactional_data | Daily mark-to-market counterparty exposure records aggregating all outstanding FX forward, FX swap, and short-term instrument positions with each treasury counterparty. | 45 |
| investment_counterparty | treasury_policy | master_data | Master record defining the treasury investment mandate and operating parameters approved by the Investment Committee. Captures mandate version, effective date, permitted instrument types, maximum maturity for short-term instruments, counterparty | 43 |

<a id="domain-valuation"></a>

### Domain: Valuation

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| valuation | operations | 4 | Domain for asset valuation and NAV determination across liquid and illiquid asset classes. Owns mark-to-market (MTM) pricing, DCF models, WACC calculations, fair value hierarchies (Level 1/2/3), NAV/GAV computations, independent valuation agent | 29 |

**Subdomains:** fair_value, governance_oversight, market_pricing, valuation_methodology


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| fair_value | credit_instrument_valuation | transactional_data | Valuation record for credit and fixed income instruments including IG bonds, HY bonds, private credit, and sovereign debt. Captures instrument identifier (ISIN/CUSIP), face value, clean price, dirty price, accrued interest, YTM (Yield to Maturity), OAS | 47 |
| fair_value | infrastructure_valuation | transactional_data | Specialized valuation record for direct infrastructure assets (toll roads, airports, utilities, pipelines, renewable energy) capturing infrastructure-specific valuation metrics. | 46 |
| fair_value | nav_liability | transactional_data | Record of liabilities deducted in the NAV computation for a fund or investment vehicle. Captures liability type (management fees payable, carried interest accrual, redemptions payable, borrowings, derivatives MTM liability, tax provisions), liability | 47 |
| fair_value | private_asset_valuation | transactional_data | Specialized valuation record for illiquid private market assets (private equity, infrastructure, real estate, natural resources) where observable market prices are unavailable. | 47 |
| fair_value | real_estate_appraisal | transactional_data | Specialized appraisal record for direct real estate holdings capturing property-level valuation outputs from licensed appraisers. Captures property identifier, appraiser firm, appraisal date, appraisal methodology (income capitalization, discounted cash | 49 |
| fair_value | valuation_asset_valuation | transactional_data | Core master record and authoritative SSOT for the concluded fair value of an individual investment asset at a specific valuation date, across ALL asset classes (public equity, private equity, infrastructure, real estate, natural resources, credit). | 49 |
| fair_value | valuation_nav_record | transactional_data | Authoritative NAV (Net Asset Value) and GAV (Gross Asset Value) record for a fund, portfolio, or investment vehicle at a specific valuation date. Captures total gross asset value, total liabilities, net asset value, NAV per unit/share, number of units | 24 |
| governance_oversight | compliance_requirement | association_data | This association product represents the compliance contract between a valuation methodology and a compliance rule. It captures which regulatory and internal rules each valuation methodology must adhere to, along with the compliance status, effective | 12 |
| governance_oversight | cycle | master_data | Master record defining a scheduled valuation cycle or reporting period for a portfolio, fund, or asset class. Captures cycle type (monthly, quarterly, annual), cycle start and end dates, valuation reference date, cycle status (open, in-progress | 35 |
| governance_oversight | exclusion_screening | association_data | This association product represents the Exclusion Screening event between an asset valuation and an exclusion list entry. It captures the compliance screening process where each investment asset is checked against the fund's exclusion policies. | 8 |
| governance_oversight | fair_value_hierarchy | reference_data | Reference classification record defining the IFRS 13 / ASC 820 fair value hierarchy levels applied to asset valuations. Captures hierarchy level (Level 1 — quoted prices in active markets, Level 2 — observable inputs, Level 3 — unobservable/model-based | 19 |
| governance_oversight | filing_inclusion | association_data | This association product represents the inclusion of a specific asset valuation in a regulatory filing. It captures the regulatory disclosure relationship between valuations and filings, tracking which valuations were reported to which regulatory | 7 |
| governance_oversight | indep_valuation_engagement | master_data | Master record for an engagement with an independent external valuation agent or appraiser (including licensed real estate appraisers) for a specific asset or portfolio. | 45 |
| governance_oversight | valuation_document | master_data | Master reference table for valuation_document. Referenced by document_id. | 46 |
| governance_oversight | valuation_policy | master_data | Master record for the firm's formal valuation policy governing fair value determination across asset classes. Captures policy version, effective date, expiry date, asset class scope, approved methodologies, hierarchy level assignment rules, independent | 41 |
| governance_oversight | valuation_review | transactional_data | Record of a formal valuation review or challenge event conducted by the Valuation Committee, IC (Investment Committee), or external auditor for a specific asset valuation or NAV record. | 40 |
| market_pricing | broker_quote | transactional_data | Record of a broker or dealer price quote obtained for a security or instrument as a Level 2 pricing input. Captures instrument identifier (ISIN/CUSIP/SEDOL), broker/dealer name, LEI, quote date, bid price, ask price, mid price, quote type (indicative | 26 |
| market_pricing | comparable_transaction | master_data | Record of a market comparable transaction used as a valuation reference for an illiquid asset. Captures the comparable company or asset name, transaction date, transaction type (M&A, secondary sale, IPO, recapitalization), enterprise value, EBITDA | 45 |
| market_pricing | market_price_snapshot | transactional_data | Point-in-time market price record for a liquid security or instrument sourced from Bloomberg, FactSet, or exchange feeds. Captures ISIN, CUSIP, SEDOL, instrument type, exchange, bid price, ask price, mid price, last traded price, closing price, price | 47 |
| market_pricing | price_exception | master_data | Operational data-quality exception record raised during a valuation cycle when a price or NAV input fails a validation tolerance — stale price, missing price, price move beyond threshold, source disagreement (Bloomberg vs broker quote), or NAV | 43 |
| market_pricing | quote_source | master_data | Master reference table for quote_source. Referenced by quote_source_id. | 42 |
| market_pricing | valuation_fx_rate | reference_data | Reference record for foreign exchange (FX) rates used in multi-currency asset valuations and NAV translation. Captures base currency, quote currency, spot rate, forward rate (1M, 3M, 6M, 12M), rate date, rate source (Bloomberg, WM/Reuters fixing), and | 22 |
| market_pricing | valuation_yield_curve | reference_data | Reference record for a yield curve or discount rate curve used in fixed income and DCF valuations. Captures curve name, curve type (government, swap, credit spread, OAS), currency, reference date, tenor points (3M, 6M, 1Y, 2Y, 5Y, 10Y, 30Y), corresponding | 40 |
| valuation_methodology | adjustment | transactional_data | Record of a specific valuation adjustment applied to a base asset valuation. Captures adjustment type (liquidity discount, control premium, minority discount, credit risk adjustment, FX translation adjustment, model overlay), adjustment amount, adjustment | 31 |
| valuation_methodology | dcf_model | master_data | Proprietary Discounted Cash Flow (DCF) model record for an investment asset or portfolio company. Stores model version, projection horizon (years), terminal growth rate, WACC (Weighted Average Cost of Capital), discount rate, projected free cash flow | 49 |
| valuation_methodology | input | transactional_data | Granular record of a specific quantitative input used in an asset valuation model. Captures input name (revenue growth rate, terminal growth rate, cap rate, NOI, LTV, DSCR, occupancy rate, commodity price), input value, input unit, source (internal model | 27 |
| valuation_methodology | methodology | reference_data | Reference record defining approved valuation methodologies available for use across asset classes. Captures methodology name (DCF, EV/EBITDA multiple, NAV, broker quote, recent transaction price, replacement cost, income capitalization), applicable asset | 47 |
| valuation_methodology | sensitivity | transactional_data | Record of a sensitivity analysis run against a valuation model, capturing how the concluded fair value changes under alternative input assumptions. Captures the base case value, sensitivity variable (WACC, terminal growth rate, exit multiple, cap rate) | 41 |
| valuation_methodology | wacc_calculation | transactional_data | Record of a WACC (Weighted Average Cost of Capital) calculation performed for a specific asset, portfolio company, or investment vehicle at a point in time. | 31 |

<a id="domain-actuarial"></a>

### Domain: Actuarial

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| actuarial | business | 3 | Domain for actuarial liability matching and liability-driven investment (LDI) operations. Owns actuarial liability projections, ALM models, discount rate curves, mortality assumptions, funded status calculations, contribution rate modeling, and duration | 22 |

**Subdomains:** asset_hedging, benefit_funding, liability_valuation


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| asset_hedging | alm_model | master_data | Master record for each Asset-Liability Management (ALM) model configuration maintained by the actuarial team. Captures model name, model version, model type (deterministic, stochastic, scenario-based), liability benchmark used, asset universe in scope | 47 |
| asset_hedging | alm_scenario | transactional_data | Transactional record of each ALM scenario run executed against an ALM model. Captures scenario name, scenario type (base case, stress, reverse stress, stochastic path), interest rate shock applied, inflation shock, equity return assumption, credit spread | 52 |
| asset_hedging | de_risking_event | transactional_data | Transactional record of each de-risking trigger breach event and the resulting portfolio action taken. Captures trigger reference, breach date, funded ratio at breach, trigger threshold breached, action mandated, action taken date, hedge ratio before | 25 |
| asset_hedging | de_risking_trigger | master_data | Master record defining funded-status-based de-risking triggers that automatically adjust the LDI hedge ratio or asset allocation glide path. Captures trigger name, trigger type (funded ratio threshold, interest rate level, surplus amount), trigger | 24 |
| asset_hedging | ldi_hedge_position | transactional_data | Transactional record capturing the current LDI hedge position for a given strategy and measurement date. Captures strategy reference, measurement date, nominal hedge notional, interest rate DV01 of liabilities, interest rate DV01 of hedge portfolio | 24 |
| asset_hedging | ldi_strategy | master_data | Master record for each Liability-Driven Investment (LDI) strategy defined by the actuarial and investment teams. Captures strategy name, strategy type (full hedge, partial hedge, dynamic de-risking), liability hedge ratio target, interest rate hedge | 33 |
| asset_hedging | saa_constraint | master_data | Master record defining actuarially-derived constraints on the Strategic Asset Allocation (SAA) imposed by liability characteristics. Captures constraint name, constraint type (minimum duration, maximum equity allocation, minimum real asset allocation | 32 |
| benefit_funding | contribution_rate_model | master_data | Master record for each contribution rate model defining the required employer and employee contribution rates for a contributor pool. Captures model name, contributor pool, effective date, normal cost rate (employer), normal cost rate (employee), special | 24 |
| benefit_funding | indexation_policy | master_data | Master record defining the benefit indexation policy for each contributor pool, governing how pension benefits are adjusted for inflation (cost-of-living adjustments). | 35 |
| benefit_funding | plan_amendment | master_data | Master record of each formal pension plan amendment that modifies benefit terms, contribution rates, eligibility criteria, or indexation provisions. Captures amendment date, amendment type (benefit improvement, benefit reduction, contribution change | 36 |
| benefit_funding | special_payment_schedule | master_data | Master record for each special payment (deficit amortization payment) schedule established to eliminate a solvency or going-concern deficiency. Captures schedule name, deficiency type (solvency, going-concern), total deficiency amount, amortization period | 28 |
| liability_valuation | actuarial_report | master_data | Master record for each formal actuarial report produced by the internal or external actuarial team. Captures report name, report type (valuation report, experience study, ALM study, contribution rate review, regulatory filing, ad hoc analysis), reporting | 49 |
| liability_valuation | actuarial_valuation | master_data | Formal actuarial valuation record representing a full triennial or interim valuation of the pension fund AND the authoritative funded-status-at-date snapshot derived from it. | 47 |
| liability_valuation | assumption_set | master_data | Master record defining a complete, versioned, effective-dated set of actuarial assumptions used in a liability valuation or ALM run. Captures assumption set name, effective date, discount_rate_curve reference, mortality_table reference, inflation rate | 27 |
| liability_valuation | discount_rate_curve | master_data | Master record for each discount rate curve used to value pension liabilities. Captures curve name, curve type (regulator-prescribed, IAS 19 corporate bond yield, risk-free, custom blend), effective date, currency, term structure (spot rates by tenor from 1Y to | 37 |
| liability_valuation | experience_study | master_data | Master record for each actuarial experience study conducted to compare actual plan experience against assumed experience. Captures study name, study period (start/end date), experience type (mortality, termination, retirement, disability, salary) | 28 |
| liability_valuation | funded_status | transactional_data | Transactional record capturing the funded status of the pension fund at a specific measurement date. Captures measurement date, total actuarial liability (going-concern and solvency bases), total market value of assets, funded ratio (assets/liabilities) | 18 |
| liability_valuation | gain_loss | transactional_data | Transactional record capturing actuarial gains and losses arising from differences between actual and assumed experience in each valuation period. Captures measurement date, gain/loss type (demographic, economic, asset return, assumption change) | 19 |
| liability_valuation | liability_cash_flow | transactional_data | Transactional record of disaggregated projected liability by contributor pool, segment, and year, derived from the actuarial liability projection. Captures projection date, contributor pool, segment type (active, deferred, retiree, survivor), projection | 31 |
| liability_valuation | liability_projection | master_data | Core master record of actuarial liability projections for each contributor pool (one per participating plan). Captures projected benefit obligation (PBO), accumulated benefit obligation (ABO), projected cash flows by year | 46 |
| liability_valuation | liability_segment | master_data | Master record defining the segmentation of total pension liabilities for ALM and LDI purposes. Captures segment name, segment type (active members, deferred members, retirees, survivors), contributor pool, total liability amount, duration of segment | 47 |
| liability_valuation | mortality_table | master_data | Master record for each mortality table or improvement scale used in actuarial liability calculations. Captures table name, table type (base mortality, improvement scale, generational projection), source (RP-2014, Pri-2012, custom blend) | 39 |

<a id="domain-beneficiary"></a>

### Domain: Beneficiary

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| beneficiary | business | 3 | Single source of truth for all pension plan members and contributor pools, one per participating plan. Owns beneficiary identity, contribution history, entitlement records, demographic data, and member lifecycle from active | 26 |

**Subdomains:** benefit_disbursement, contribution_management, member_administration


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| benefit_disbursement | benefit_option | reference_data | Reference entity defining the menu of pension benefit options available to members at retirement within each contributor pool: single life annuity, joint and survivor annuity (50%, 60%, 66.67%, 100% survivor fractions), guaranteed period options, bridge | 42 |
| benefit_disbursement | benefit_payment | transactional_data | Transactional record of each pension benefit payment disbursed to a member or beneficiary. Captures gross pension amount, applicable deductions (tax withholding, clawbacks, overpayment recovery), net payment amount, payment method (direct deposit | 45 |
| benefit_disbursement | entitlement | master_data | Master record and authoritative source for the calculated pension entitlement owed to a member at a given point in time or benefit trigger (retirement, death, termination). | 27 |
| benefit_disbursement | indexation_adjustment | transactional_data | Transactional record of annual cost-of-living indexation adjustments applied to pension benefit payments. Captures the indexation rate applied (typically CPI-linked per plan rules), effective date, prior benefit amount, adjusted benefit amount, and the | 48 |
| benefit_disbursement | member_statement | transactional_data | Transactional record representing the annual or on-demand pension statement issued to a plan member. Captures statement period, total pensionable service to date, projected pension at normal retirement age, accrued entitlement value, total contributions | 47 |
| benefit_disbursement | overpayment_recovery | transactional_data | Transactional record tracking instances where benefit payments were made in excess of entitlement (due to death notification delays, calculation errors, or eligibility changes) and the subsequent recovery process. | 48 |
| benefit_disbursement | pension_division_order | transactional_data | Transactional record of court-ordered pension division upon marriage breakdown, capturing the division order type (equalization payment, pension sharing, deferred division), effective date, division percentage or amount, former spouse identity, actuarial | 45 |
| benefit_disbursement | retirement_election | transactional_data | Transactional record capturing a member's formal election to commence pension drawdown, including retirement date, retirement type (normal, early, deferred, disability), pension option elected (single life, joint and survivor, guaranteed period), survivor | 50 |
| benefit_disbursement | survivor_benefit | master_data | Master record of survivor pension benefits established upon the death of a plan member or retiree. Stores the surviving beneficiary identity, survivor benefit type (survivor pension, death-in-service lump sum, children's benefit), benefit amount | 50 |
| contribution_management | contribution_rate | reference_data | Reference entity defining the contribution rate schedules applicable to each contributor pool, including employee and employer rate tiers, effective date ranges, pensionable earnings thresholds, and the legislative or regulatory basis for each rate. | 36 |
| contribution_management | contribution_record | transactional_data | Transactional record of each periodic pension contribution made on behalf of or by a plan member. Captures employee contribution amount, employer contribution amount, contribution period (pay period), contribution type (regular, catch-up, voluntary | 36 |
| contribution_management | employer_remittance | transactional_data | Transactional record of bulk contribution remittances submitted by participating employers (government departments, public agencies, other participating employers) to the fund on behalf of their employees. | 49 |
| contribution_management | pensionable_service | master_data | Master record tracking the cumulative and period-level pensionable service credits accrued by a member. Records credited service years and months, service type (regular, buyback, transferred-in, military service credit), service period start and end | 43 |
| contribution_management | service_buyback | transactional_data | Transactional record of a member's election to purchase additional pensionable service credits for prior periods of non-contributory service (e.g., maternity/parental leave, prior public-sector employment, military service). | 46 |
| contribution_management | transfer_in | transactional_data | Transactional record of pension assets or service credits transferred into the fund from another pension plan or retirement account on behalf of a member. Records the source plan name, transfer type (commuted value, service credit recognition), transfer | 53 |
| contribution_management | transfer_out | transactional_data | Transactional record of commuted value or pension credit transfers out of the fund when a member terminates employment before retirement and elects to transfer their accrued entitlement to another registered plan or locked-in retirement account. | 48 |
| member_administration | contributor_pool | reference_data | Reference entity defining the four distinct contributor pools managed by the fund: the participating plans. Each pool has its own legislative framework, benefit formula, contribution rate structure, actuarial assumptions | 36 |
| member_administration | designated_beneficiary | master_data | Master record of the individuals designated by a plan member to receive survivor pension benefits or death-in-service lump sum payments. Stores beneficiary name, relationship to member (spouse, common-law partner, dependent child, estate), designation | 47 |
| member_administration | member | master_data | Core master record and single source of truth for every pension plan member across all four contributor pools (one per participating plan). | 46 |
| member_administration | member_address | master_data | Master record of all physical and mailing addresses associated with a plan member, including residential address, mailing address, and employer address. Tracks address type, full address components (street, city, province/state, postal code, country) | 43 |
| member_administration | member_contact | master_data | Master record of contact information for a plan member including phone numbers, email addresses, and preferred communication channel. Stores contact type (mobile, home, work, email), contact value, is_primary flag, opt-in/opt-out preferences for digital | 37 |
| member_administration | member_document | master_data | Master record of official documents associated with a plan member's pension file: enrollment forms, beneficiary designation forms, retirement applications, marriage certificates, divorce orders (for pension division), disability certifications, death | 47 |
| member_administration | member_enrollment | transactional_data | Transactional record capturing the formal enrollment event when an individual joins a contributor pool as an active pension plan member. Records enrollment date, plan entry type (new hire, transfer-in, re-enrollment), eligibility verification outcome | 26 |
| member_administration | member_lifecycle_event | transactional_data | Transactional record capturing significant lifecycle state transitions for a plan member: enrollment, active service, leave of absence, disability, deferred vesting, retirement commencement, death, and plan termination. | 38 |
| member_administration | participating_employer | master_data | Master record of all government departments, public agencies, and other participating employers. | 51 |
| member_administration | pension_plan | master_data | Master reference table for pension_plan. Referenced by plan_id. | 45 |

<a id="domain-esg"></a>

### Domain: Esg

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| esg | business | 3 | Domain for ESG integration, responsible investment stewardship, and sustainability reporting across the investment lifecycle. Owns ESG ratings (MSCI ESG), PRI reporting data, SFDR classifications, TCFD climate risk disclosures, GHG emissions tracking | 24 |

**Subdomains:** climate_metrics, ratings_research, regulatory_reporting


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| climate_metrics | climate_scenario | reference_data | Reference catalogue of climate transition and physical risk scenarios used in stress testing and TCFD disclosures. Stores scenario name (e.g., NGFS Net Zero 2050, IEA SDS, RCP 2.6/4.5/8.5), scenario type (transition vs. | 45 |
| climate_metrics | engagement_activity | transactional_data | Transactional record of stewardship engagement interactions between the fund and investee companies or external managers. Captures engagement type (direct, collaborative, escalation), engagement topic (climate, board diversity, executive pay, supply | 46 |
| climate_metrics | engagement_objective | master_data | Master record of structured engagement objectives and milestones set for each investee company or manager engagement program. Captures objective description, target ESG issue (E/S/G pillar), SMART milestone definition, target completion date, priority | 48 |
| climate_metrics | esg_policy | master_data | Master record of the fund's responsible investment policies and ESG integration mandates—including the Responsible Investment Policy, Exclusion Policy, Proxy Voting Policy, and Engagement Policy. | 44 |
| climate_metrics | exclusion_list | master_data | Master record of securities, issuers, sectors, and geographies formally excluded from the investable universe under the fund's Exclusion Policy. Captures exclusion type (norm-based, sector-based, product-based), exclusion reason (controversial weapons | 42 |
| climate_metrics | framework | reference_data | Reference catalogue of ESG frameworks, standards, and regulatory regimes adopted by the fund (PRI, SFDR, TCFD, UNGC, SASB, GRI, TNFD). Stores framework code, full name, governing body, applicable jurisdiction, version, effective date, and mandatory vs. | 48 |
| climate_metrics | ghg_emission_record | transactional_data | Transactional record of greenhouse gas (GHG) emissions data collected at the portfolio holding or asset level. Captures Scope 1, Scope 2 (location-based and market-based), and Scope 3 emissions in tCO2e, data source (reported vs. | 48 |
| climate_metrics | kpi_measurement | transactional_data | Transactional record of periodic ESG KPI actuals measured against targets at the holding or portfolio level. Captures measurement date, KPI reference, actual value, unit of measure, variance from target, data source, measurement methodology, data quality | 48 |
| climate_metrics | kpi_target | master_data | Master record of ESG key performance indicator (KPI) targets set at the portfolio, asset class, or individual holding level. Captures KPI name, KPI category (carbon intensity, board diversity %, renewable energy %, water intensity, employee safety rate) | 43 |
| climate_metrics | net_zero_commitment | master_data | Master record of the fund's net-zero commitments and interim decarbonization targets at the total portfolio and asset class level. Captures commitment name, commitment standard (NZAOA, SBTi, IIGCC NZIF), base year emissions, interim target year, interim | 47 |
| climate_metrics | proxy_vote_record | transactional_data | SSOT transactional record of proxy voting decisions cast at investee company shareholder meetings, including meeting date, resolution category, vote direction, and rationale. Governed by proxy_vote_policy guidelines. | 52 |
| climate_metrics | watch_list | master_data | Master record of issuers, funds, or managers placed on formal ESG watch or review status due to deteriorating ESG ratings, controversy escalation, or policy breaches. | 56 |
| ratings_research | controversy | master_data | Master record of ESG controversies, adverse-media events, and the resulting watch/escalation status flagged against investee companies or fund managers. Captures controversy type (environmental incident, labor violation, governance failure | 49 |
| ratings_research | data_provider | reference_data | Reference master of external ESG data vendors and rating agencies contracted by the fund. Captures provider name (MSCI ESG, RepRisk, Sustainalytics, ISS ESG, CDP, Bloomberg ESG), data products subscribed, coverage universe (asset class, geography, issuer | 48 |
| ratings_research | due_diligence | transactional_data | Transactional record of ESG due diligence assessments conducted during investment evaluation for new deals, co-investments, and external manager selections. | 57 |
| ratings_research | esg_benchmark | reference_data | Reference catalogue of ESG benchmarks and indices used for portfolio ESG performance comparison. Captures benchmark name, benchmark provider (MSCI, FTSE Russell, S&P), benchmark type (ESG Leaders, Paris-Aligned, Climate Transition, Best-in-Class) | 46 |
| ratings_research | integration_checklist | transactional_data | Transactional record of ESG integration checklist completions embedded within the investment lifecycle (deal screening, IC memo, annual review). Captures checklist type (pre-investment screening, annual monitoring, exit review), completion date | 52 |
| ratings_research | issuer_esg_rating | master_data | Master record of ESG ratings assigned to investable issuers (corporates, sovereigns, real assets) sourced primarily from MSCI ESG Ratings and supplemented by internal assessments. | 49 |
| regulatory_reporting | pai_indicator | master_data | Transactional/reference record of Principal Adverse Impact (PAI) indicator values tracked per issuer and per reporting period under SFDR Article 7 and the PAI Statement. | 23 |
| regulatory_reporting | pri_reporting_submission | transactional_data | Transactional record of annual PRI (Principles for Responsible Investment) Assessment submissions. Captures reporting year, module name (Strategy & Governance, Listed Equity, Private Equity, Real Estate, Infrastructure, Fixed Income), indicator code | 34 |
| regulatory_reporting | responsible_investment_report | transactional_data | Transactional record of formal responsible investment (RI) reports published by the fund for external stakeholders—beneficiaries, regulators, and the public. | 49 |
| regulatory_reporting | sfdr_classification | master_data | Master record of SFDR (Sustainable Finance Disclosure Regulation) product-level classifications for each fund vehicle and mandate managed or invested in. Stores Article classification (6, 8, or 9), classification rationale, which Principal Adverse Impact | 42 |
| regulatory_reporting | taxonomy_alignment | master_data | Record of EU Taxonomy eligibility and alignment at the economic-activity / holding level. Captures environmental objective (climate mitigation, adaptation, water, circular economy, pollution, biodiversity), eligible revenue/capex/opex %, aligned % | 46 |
| regulatory_reporting | tcfd_disclosure | transactional_data | Transactional record of annual TCFD (Task Force on Climate-related Financial Disclosures) climate risk disclosure submissions. Captures reporting period, governance narrative, strategy narrative, risk management narrative, physical risk exposure summary | 52 |

<a id="domain-fee"></a>

### Domain: Fee

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| fee | business | 2 | Domain for fee administration and carried interest management across all investment structures and external manager mandates. Owns management fee calculations, carried interest waterfall computations, hurdle rate tracking, clawback provisions, GP fee | 25 |

**Subdomains:** carry_distribution, fee_processing


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| carry_distribution | carry_distribution | transactional_data | Transactional record of carried interest distributions paid to a GP following a realized investment event (exit, recapitalization, IPO). Captures distribution date, fund/vehicle reference, realized proceeds, return of capital amount, preferred return | 42 |
| carry_distribution | carry_escrow | master_data | Master record tracking carried interest escrow accounts established to protect LP interests against potential clawback obligations. Captures escrow account reference, GP counterparty, escrow amount held, escrow percentage (of gross carry distributions) | 40 |
| carry_distribution | clawback_event | transactional_data | Transactional record of a clawback event triggered against a GP when carried interest distributions exceed the GP's entitlement based on final fund performance. | 44 |
| carry_distribution | waterfall | master_data | Master record defining the distribution waterfall structure for a private markets fund or co-investment vehicle. Captures waterfall type (European whole-fund vs American deal-by-deal), tier sequence, hurdle rate per tier, carry percentage per tier | 34 |
| carry_distribution | waterfall_tier | reference_data | Reference entity defining each sequential tier within a distribution waterfall structure. Captures tier sequence number, tier type (return of capital, preferred return/hurdle, GP catch-up, carried interest split), LP allocation percentage, GP allocation | 37 |
| fee_processing | accrual | transactional_data | Transactional record of periodic fee accruals computed for management fees, carried interest, and other investment-related fees. Captures accrual period (start/end date), fee type, accrual basis (AUM, NAV, committed capital), accrual rate applied, gross | 37 |
| fee_processing | carried_interest | master_data | Master record for each carried interest arrangement negotiated with a GP/external manager across PE, infrastructure, real estate, and natural resources structures. | 46 |
| fee_processing | clawback_provision | master_data | Master record for GP clawback provisions embedded within carried interest arrangements. Captures clawback trigger conditions (GP over-distribution relative to final fund IRR), maximum clawback amount, clawback escrow percentage, clawback calculation | 43 |
| fee_processing | dispute | transactional_data | Transactional record of fee disputes raised against external managers or GPs regarding incorrect fee calculations, unauthorized charges, or LPA non-compliance. | 45 |
| fee_processing | fee_benchmark | master_data | Master record of external manager fee benchmarks used to assess the competitiveness of management fee and carried interest terms across the fund's manager universe. | 34 |
| fee_processing | fee_calculation_run | transactional_data | Transactional record of each periodic fee calculation run executed for management fees, carried interest, or other investment-related fees. Captures calculation run date, fee type, calculation period, AUM/NAV basis used, rate applied, gross fee computed | 51 |
| fee_processing | gp_fee_rebate | master_data | Master record tracking GP fee rebates and offsets applied to management fees as required under LPA terms. Captures rebate type (transaction fee offset, monitoring fee offset, advisory fee offset), rebate percentage per LPA, gross rebate amount earned in | 41 |
| fee_processing | high_water_mark | master_data | Master record tracking the high-water mark (HWM) level for each incentive fee arrangement on liquid strategy mandates. Captures current HWM NAV level, HWM reset date, cumulative underperformance deficit (loss carryforward), last crystallization date, last | 45 |
| fee_processing | hurdle_rate | master_data | Master record tracking the preferred return (hurdle rate) applicable to each carried interest arrangement or fund structure. Captures hurdle rate percentage, compounding frequency (simple vs compound), hurdle basis (committed capital vs invested capital | 45 |
| fee_processing | incentive_fee | master_data | Master record for performance-based incentive fee arrangements applicable to external managers operating under SMA or liquid alternatives mandates. Captures incentive fee rate (percentage of outperformance), high-water mark provision, benchmark reference | 49 |
| fee_processing | invoice | transactional_data | Transactional record of fee invoices received from external managers or GPs for management fees, monitoring fees, and other mandate-related charges. Captures invoice date, invoice number, invoicing entity (GP/manager LEI), invoice period, fee type | 42 |
| fee_processing | management_fee | master_data | Master record defining the management fee arrangement for each external manager mandate or internal investment structure. Captures the fee basis (AUM percentage, flat fee, tiered), applicable rate schedule, fee calculation frequency (monthly, quarterly | 44 |
| fee_processing | monitoring_fee | master_data | Master record for portfolio company monitoring fees charged by GPs to investee companies post-acquisition. Captures monitoring fee structure (annual flat fee vs percentage of EBITDA), fee amount, billing frequency, LPA offset provision (percentage | 49 |
| fee_processing | organizational_expense | transactional_data | Transactional record of fund organizational and formation expenses charged to the fund or LP during fund launch, including legal fees, placement agent fees, regulatory filing costs, and fund formation costs. | 44 |
| fee_processing | payment | transactional_data | Transactional record of actual fee payments disbursed to external managers, GPs, or service providers. Captures payment date, fee type (management fee, carried interest, transaction fee, monitoring fee), gross payment amount, withholding tax deducted, net | 48 |
| fee_processing | placement_fee | transactional_data | Transactional record of placement agent fees paid in connection with fund capital raising activities. Captures placement agent identity, fee basis (percentage of committed capital), fee amount, payment date, retrocession arrangement (whether placement fee | 47 |
| fee_processing | rate_schedule | reference_data | Reference entity defining tiered fee rate schedules applied during fee computation. Captures rate schedule name, fee type, AUM/NAV tier breakpoints, applicable fee rate per tier (bps), blended rate calculation method, currency, and effective/expiry dates. | 48 |
| fee_processing | transaction_fee | transactional_data | Transactional record of deal-level transaction fees charged by GPs or advisors in connection with private market investment transactions (acquisition fees, disposition fees, financing fees, monitoring fees). | 46 |
| fee_processing | transparency_report | transactional_data | Transactional record of periodic fee transparency disclosures prepared for beneficiaries, regulators, and governance bodies. Captures reporting period, total management fees paid (by asset class and manager), total carried interest paid, total transaction | 47 |
| fee_processing | waiver | transactional_data | Transactional record of management fee waivers or reductions granted by a GP to the fund, typically in connection with co-investment rights, LPAC participation, or large commitment size. | 42 |

<a id="domain-manager"></a>

### Domain: Manager

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| manager | business | 4 | Domain for external fund manager selection, mandate management, and ongoing manager oversight. Owns manager profiles, RFP processes, mandate terms (LPAs, SMAs, co-investment agreements), SLA tracking, manager performance evaluation, fee schedules, and | 23 |

**Subdomains:** manager_selection, mandate_governance, relationship_engagement, risk_oversight


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| manager_selection | esg_profile | master_data | Captures the ESG credentials and responsible investment profile of each external manager, including PRI signatory status, SFDR article classification, TCFD alignment, proprietary ESG policy documentation, GHG reporting capability, exclusion list | 25 |
| manager_selection | gp_profile | master_data | Master SSOT record for each external General Partner (GP), sub-advisor, or Fund-of-Funds manager relationship. Captures manager identity, legal entity details, LEI, domicile, AUM, strategy focus, vintage coverage, and operational status, PLUS the | 55 |
| manager_selection | manager_contact | master_data | Master record for key personnel at each external manager firm, including portfolio managers, investor relations contacts, compliance officers, and operations contacts. | 47 |
| manager_selection | rfp | transactional_data | Tracks each Request for Proposal (RFP) or Request for Information (RFI) issued to external managers during the manager selection process. Records RFP type, asset class, strategy sought, issuance date, response deadline, evaluation criteria weighting | 48 |
| manager_selection | rfp_response | transactional_data | Captures each manager's formal response to an RFP, including submission date, proposed strategy details, proposed fee schedule, track record summary, team composition, AUM at time of submission, and evaluation scores assigned by the internal selection | 49 |
| manager_selection | strategy | reference_data | Reference classification of investment strategies offered by external managers, including strategy name, asset class, sub-strategy type (buyout, venture, growth, distressed, core real estate, value-add, infrastructure greenfield, etc.), geographic focus | 43 |
| mandate_governance | co_invest_right | master_data | Master record of co-investment rights negotiated within each LP mandate, specifying the co-investment allocation right (percentage or dollar cap), notice period for co-invest opportunities, approval process, exclusivity window, and historical utilization. | 48 |
| mandate_governance | fee_schedule | master_data | Defines the fee structure applicable to each mandate or manager relationship, including management fee tiers (basis points by AUM band), carried interest percentage, preferred return hurdle, fee calculation frequency, fee base (committed vs. | 50 |
| mandate_governance | manager_mandate | master_data | Authoritative record of each investment mandate awarded to an external manager, covering mandate type (LP fund commitment, SMA, co-investment agreement, FoF), asset class, strategy, target allocation, benchmark, investment guidelines, and contractual term | 54 |
| mandate_governance | mandate_amendment | transactional_data | Records each formal amendment to an existing mandate, capturing amendment date, amendment type (fee renegotiation, guideline change, term extension, side letter), the specific clause modified, prior value, revised value, and approval authority. | 49 |
| mandate_governance | mandate_term | master_data | Authoritative SSOT for the economic and governance terms of each mandate: management fee basis points (tiered by AUM band), carried interest rate, hurdle/preferred return, high-water mark, clawback terms, fee base (committed vs invested capital), fee | 51 |
| mandate_governance | sla_agreement | master_data | SSOT for all service-level commitments and individual reporting obligations between the pension fund and each external manager or fund administrator. Covers reporting delivery timelines and line-item obligations (NAV, capital account statements, audited | 50 |
| relationship_engagement | lpac_membership | master_data | Tracks the pension fund's Limited Partner Advisory Committee (LPAC) membership positions across all LP fund mandates, including seat type (voting, observer), appointment date, term expiry, representative assigned, and LPAC meeting attendance record. | 48 |
| relationship_engagement | manager_benchmark | reference_data | Defines the performance benchmarks assigned to each mandate or manager strategy, including benchmark name, benchmark provider, benchmark index code, benchmark currency, benchmark calculation methodology, and effective date range. | 45 |
| relationship_engagement | manager_document | master_data | Catalog of all legal and operational documents associated with each manager relationship, including executed LPAs, side letters, NDAs, PPMs, subscription agreements, audited financial statements, DDQs (Due Diligence Questionnaires), and regulatory | 37 |
| relationship_engagement | meeting | transactional_data | Records all formal interactions with external managers including annual reviews, quarterly update calls, on-site due diligence visits, LPAC meetings, and ad-hoc escalation meetings. | 49 |
| relationship_engagement | report_receipt | transactional_data | Transactional log of each manager report received, recording report type, reporting period covered, receipt date, delivery channel, completeness check result, data quality flags, and processing status. | 28 |
| relationship_engagement | reporting_obligation | master_data | Defines the specific reporting obligations each external manager must fulfill under their mandate, including report type (capital account statement, audited financials, quarterly investor letter, ESG report, ILPA data template), delivery frequency | 32 |
| risk_oversight | evaluation | transactional_data | Records periodic qualitative and quantitative evaluations of each external manager, covering investment process assessment, team stability, operational infrastructure, risk management quality, ESG integration maturity, and overall conviction rating. | 56 |
| risk_oversight | kyc | transactional_data | Records KYC (Know Your Customer) and AML (Anti-Money Laundering) due diligence completed for each external manager entity, including beneficial ownership verification, sanctions screening results, PEP checks, source of funds confirmation, and regulatory | 46 |
| risk_oversight | risk_assessment | transactional_data | Captures structured risk assessments of each external manager covering operational risk (ODD findings), key-man risk, concentration risk, counterparty risk, regulatory risk, and reputational risk. | 51 |
| risk_oversight | sla_breach | transactional_data | Transactional record of each SLA breach event by an external manager, capturing breach date, SLA obligation breached, severity classification, root cause, manager response, remediation plan, and resolution date. | 47 |
| risk_oversight | watchlist | transactional_data | Tracks external managers placed on formal internal watch-list status due to performance concerns, key-man departures, regulatory investigations, ODD findings, or strategic misalignment. | 48 |

<a id="domain-performance"></a>

### Domain: Performance

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| performance | business | 4 | Domain for investment performance measurement and attribution analysis across all asset classes and portfolios. Owns TWR and MWR calculations, IRR, GIPS-compliant composite construction, benchmark-relative performance, factor/sector/geographic | 28 |

**Subdomains:** benchmark_attribution, calculation_governance, composite_reporting, return_measurement


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| benchmark_attribution | active_return_attribution |  | Barra-style decomposition of active return; one row per portfolio, sector, factor and period. | 10 |
| benchmark_attribution | attribution_model | reference_data | Reference master record defining the attribution methodologies configured for use across portfolios and asset classes. Captures model name (e.g., Brinson-Hood-Beebower, Brinson-Fachler, factor-based, fixed income attribution), model type, currency | 40 |
| benchmark_attribution | attribution_result | transactional_data | Core transactional record storing the results of a performance attribution run for one portfolio and measurement period. Captures total active return decomposed into allocation, selection, interaction, and currency effects using Brinson-Hood-Beebower | 45 |
| benchmark_attribution | attribution_segment | transactional_data | Transactional record capturing attribution effects at a single segment of an attribution run. A segment is defined by a dimension (sector, geography, asset class, factor, or currency pair) and carries portfolio weight, benchmark weight, portfolio return | 44 |
| benchmark_attribution | benchmark_return | transactional_data | Transactional record of benchmark-level returns for each measurement period, aligned to the same periodicity as portfolio returns. Captures benchmark total return, price return, income return, and currency-adjusted return. | 37 |
| benchmark_attribution | currency_attribution | transactional_data | Transactional record capturing the currency effect component of performance attribution for each portfolio and measurement period. Stores currency allocation effect, currency selection effect, and hedging contribution broken down by currency pair. | 40 |
| benchmark_attribution | excess_return | transactional_data | Transactional record of benchmark-relative excess return (alpha) for each portfolio and measurement period. Captures gross excess return, net-of-fee excess return, currency-adjusted excess return, information ratio, tracking error, and Sharpe ratio. | 37 |
| benchmark_attribution | performance_benchmark | master_data | Master record for each performance benchmark used across portfolios, composites, and mandates. Stores benchmark name, benchmark type (absolute return, market index, custom blended, liability-relative), index provider (e.g., MSCI, Bloomberg, FTSE) | 40 |
| benchmark_attribution | performance_factor_exposure | transactional_data | Transactional record of portfolio-level factor exposures used in factor-based performance attribution. Captures exposure to systematic risk factors (e.g., market beta, size, value, momentum, quality, low volatility, duration, credit spread) sourced from | 31 |
| calculation_governance | notice | transactional_data | Transactional record of formal performance notices issued to external managers when their mandate performance falls below agreed thresholds (e.g., underperformance vs. benchmark over rolling 3-year period, breach of tracking error band). | 42 |
| calculation_governance | performance_calculation_run | transactional_data | Transactional record of each performance calculation batch execution, capturing run date, calculation type (daily NAV, month-end, quarter-end, GIPS annual), portfolios included, source system (SimCorp Dimension, eFront), calculation status (pending | 41 |
| calculation_governance | performance_exception | master_data | Transactional record of performance data-quality exceptions and reconciliation breaks raised during a performance_calculation_run — e.g., PBOR-vs-ABOR market value variance beyond tolerance, missing security price, stale FX rate, negative or outlier TWR | 37 |
| calculation_governance | scenario_application | association_data | This association product represents the application of economic scenarios to GIPS-compliant composites for stress testing, ALM modeling, and Investment Committee presentations. | 6 |
| composite_reporting | composite | master_data | Master record for each GIPS-compliant composite grouping portfolios with similar investment mandates and objectives. Defines composite construction rules, inclusion/exclusion criteria, composite inception date, benchmark assignment, and composite-level | 41 |
| composite_reporting | dispersion | transactional_data | Transactional record of internal dispersion statistics for each GIPS composite and annual period, measuring the spread of individual portfolio returns within the composite. | 34 |
| composite_reporting | gips_composite_report | transactional_data | Transactional record representing the annual GIPS-compliant composite presentation prepared for each composite and reporting year. Captures composite annual return, benchmark annual return, composite 3-year annualized standard deviation, benchmark 3-year | 41 |
| composite_reporting | peer_group | master_data | Master record defining peer group universes used for relative performance comparison. Captures peer group name, peer group provider (e.g., CEM Benchmarking, Preqin, Mercer), asset class scope, peer group inception date, and methodology description. | 33 |
| composite_reporting | peer_group_return | transactional_data | Transactional record of peer group return statistics for each measurement period, including median return, 25th percentile, 75th percentile, top decile, bottom decile, and number of peers in the universe. Sourced from CEM Benchmarking, Preqin, and Mercer. | 30 |
| composite_reporting | performance_composite_membership | association_data | Transactional association record tracking which portfolios are included in each GIPS composite for each measurement period. Captures inclusion start date, exclusion date, reason for exclusion (e.g., significant cash flow, mandate change), and the | 35 |
| composite_reporting | significant_cash_flow | transactional_data | Transactional record identifying significant external cash flows that trigger portfolio exclusion from GIPS composites or require sub-period return calculations. | 34 |
| return_measurement | cash_flow_record | transactional_data | Transactional record of all cash flows used in MWR and IRR calculations, including capital calls (drawdowns), distributions, income receipts, management fee payments, and net contributions from beneficiaries. | 43 |
| return_measurement | fee_hurdle | master_data | Master record defining the performance fee hurdle rate and high-water mark parameters applicable to each portfolio or mandate for performance fee calculation purposes. | 37 |
| return_measurement | holding_return | transactional_data | Transactional record of security-level or position-level return contributions within a portfolio for a given measurement period. Captures beginning market value, ending market value, income received, realized gain/loss, unrealized gain/loss, total return | 44 |
| return_measurement | ldi_return | transactional_data | Transactional record of liability-relative performance for the fund's LDI (Liability-Driven Investment) portfolios. Captures funded ratio change, liability return (discount rate-driven), asset return, surplus return, hedging ratio effectiveness, and | 50 |
| return_measurement | pbor_snapshot | master_data | Master record representing the Performance Book of Record (PBOR) snapshot for each portfolio at each valuation date. Captures total portfolio market value (GAV and NAV), accrued income, unrealized gain/loss, realized gain/loss, net contributions for the | 50 |
| return_measurement | portfolio_return | transactional_data | Core transactional record of calculated portfolio-level returns for each measurement period. Stores both Time-Weighted Return (TWR) and Money-Weighted Return (MWR/IRR), plus benchmark-relative metrics (gross and net-of-fee excess return, information | 52 |
| return_measurement | private_asset_irr | transactional_data | Transactional record of IRR (Internal Rate of Return), MOIC (Multiple on Invested Capital), TVPI, DPI, and RVPI calculations for private market investments including private equity, real estate, infrastructure, natural resources, and credit. | 40 |
| return_measurement | return_period | reference_data | Reference entity defining the standard measurement periods used across all performance calculations: daily, monthly, quarterly, fiscal year, calendar year, inception-to-date, rolling 1-year, rolling 3-year, rolling 5-year, rolling 10-year. | 23 |

<a id="domain-compliance"></a>

### Domain: Compliance

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| compliance | corporate | 3 | Domain for regulatory compliance, beneficiary reporting, and governance operations. Owns regulatory filing records (SEC, FCA, ESMA), KYC/AML documentation, trade reporting (EMIR, MiFID II), SFDR disclosures, LEI management, investment committee | 26 |

**Subdomains:** governance_ethics, monitoring_surveillance, regulatory_reporting


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| governance_ethics | certification | transactional_data | Transactional record of periodic compliance certifications completed by investment staff, officers, and committee members. Captures certification type (annual compliance attestation, AML training completion, code of ethics acknowledgement, GIPS compliance | 28 |
| governance_ethics | conflict_of_interest | master_data | Master record of declared conflicts of interest by investment professionals, committee members, and officers of the pension fund. Captures declarant name and role, conflict type (personal investment, related party, board membership, prior employment) | 45 |
| governance_ethics | ic_decision | transactional_data | Transactional record of each formal Investment Committee decision made during an IC governance session. Captures decision date, IC session reference, decision subject (investment approval, mandate change, SAA revision, policy exception), decision type | 34 |
| governance_ethics | ic_governance_record | master_data | Master record for each Investment Committee (IC) governance session managed via Diligent/BoardEffect. Captures IC meeting date, meeting type (regular IC, special IC, sub-committee), quorum status, agenda items, attendees and roles, decisions made | 27 |
| governance_ethics | personal_account_dealing | transactional_data | Transactional record of personal account dealing (PAD) disclosures and pre-clearance requests submitted by investment staff and officers. Captures employee name and role, security identifier (ISIN/CUSIP), transaction type (buy, sell, short), proposed | 37 |
| governance_ethics | policy_document | master_data | Master record for each internal compliance policy, investment policy statement, or regulatory procedure document maintained by the compliance function. Captures policy name, policy category (investment policy, AML policy, ESG policy, trading policy | 29 |
| governance_ethics | policy_exception | transactional_data | Transactional record of each formal exception granted to a compliance policy or investment guideline. Captures exception request date, policy or rule being excepted, exception requestor, business justification, exception type (temporary, permanent | 28 |
| monitoring_surveillance | breach_remediation | transactional_data | Transactional record tracking the remediation workflow for each compliance rule breach. Captures remediation plan description, assigned officer, target remediation date, remediation actions taken (trade reversal, position reduction, waiver request, policy | 36 |
| monitoring_surveillance | kyc_record | master_data | Master KYC (Know Your Customer) and AML (Anti-Money Laundering) compliance record for each counterparty, external manager, co-investor, or institutional relationship managed by the pension fund. | 39 |
| monitoring_surveillance | lei_record | master_data | Master record for each Legal Entity Identifier (LEI) managed or tracked by the pension fund, covering the fund itself, its subsidiaries, SPVs, and key counterparties. | 37 |
| monitoring_surveillance | rule | master_data | Master record defining each compliance monitoring rule configured in the rules engine (sourced from BlackRock Aladdin and Charles River IMS compliance modules). | 46 |
| monitoring_surveillance | rule_breach | transactional_data | Operational record of each compliance rule breach detected by the rules engine (Aladdin, Charles River IMS), tracked through its full breach-to-resolution lifecycle. | 38 |
| monitoring_surveillance | sanctions_screening | transactional_data | Transactional record of each sanctions and PEP screening event conducted against a counterparty, issuer, manager, or individual. Captures screening date, screened entity name and LEI, screening list(s) applied (OFAC, UN, EU, HMT), screening result (clear | 18 |
| regulatory_reporting | audit_finding | transactional_data | Transactional record of each internal or external audit finding raised against the compliance, investment, or operational functions of the pension fund. Captures audit type (internal audit, external audit, SOC 2, ISO 27001), audit period, finding category | 43 |
| regulatory_reporting | beneficiary_disclosure | transactional_data | Transactional record of each formal disclosure or regulatory report issued to pension beneficiaries, contributor pools, or sponsoring employers. Captures disclosure type (annual pension statement, benefit entitlement notice, plan amendment notice, SFDR | 32 |
| regulatory_reporting | exam_finding | transactional_data | Transactional record of each finding or observation raised by a regulatory examiner during a supervisory examination. Captures finding reference, examination reference, finding category (deficiency, observation, recommendation, violation), finding | 35 |
| regulatory_reporting | filing_submission | transactional_data | Transactional record of each individual submission event for a regulatory filing, capturing submission timestamp, submission method (portal, XBRL, API, manual), submitted by (officer/system), submission status, acknowledgement receipt reference, regulator | 20 |
| regulatory_reporting | gips_compliance_record | master_data | Master record tracking the pension fund's GIPS (Global Investment Performance Standards) compliance status at the composite and firm level. Captures GIPS compliance assertion date, compliance scope (firm-wide, composite-specific), composite reference | 44 |
| regulatory_reporting | obligation | master_data | Master record defining each specific compliance obligation the pension fund must fulfill under applicable regulations, internal policies, or mandate terms. | 41 |
| regulatory_reporting | regulatory_authority | reference_data | Reference master of all regulatory authorities and governing bodies with jurisdiction over the pension fund's operations. Captures authority name (SEC, FCA, ESMA, IOSCO, local pension regulator), authority type (prudential, conduct, market | 43 |
| regulatory_reporting | regulatory_calendar | master_data | Authoritative register of every compliance obligation the pension fund must fulfil and its scheduled due dates across all jurisdictions and regulations. Captures obligation name, obligation type (regulatory reporting, disclosure, certification, record | 27 |
| regulatory_reporting | regulatory_change | master_data | Master record tracking regulatory changes, new regulations, and amendments to existing rules that impact the pension fund's operations. Captures regulation name, issuing authority (SEC, FCA, ESMA), change type (new regulation, amendment, guidance | 28 |
| regulatory_reporting | regulatory_exam | master_data | Master record for each regulatory examination, inspection, or supervisory review conducted by a regulatory authority (SEC, FCA, ESMA) against the pension fund. | 20 |
| regulatory_reporting | regulatory_filing | master_data | Master record for each formal regulatory filing submitted to governing bodies (SEC, FCA, ESMA, IOSCO). Captures filing type, regulatory authority, reporting period, submission date, filing status (draft, submitted, acknowledged, accepted, rejected) | 27 |
| regulatory_reporting | sfdr_disclosure | transactional_data | Master record of SFDR (Sustainable Finance Disclosure Regulation) product-level and entity-level disclosures prepared and filed by the pension fund. Captures disclosure type (entity-level PAI statement, product-level pre-contractual, periodic report) | 29 |
| regulatory_reporting | trade_report | transactional_data | Transactional record of each trade report submitted to a trade repository under EMIR or MiFID II transaction reporting obligations. Captures trade report reference, reporting regime (EMIR, MiFID II), trade repository (DTCC, REGIS-TR), UTI (Unique Trade | 40 |

<a id="domain-shared"></a>

### Domain: Shared

| Domain | Division | Total Subdomains | Description | Total Products |
|---|---|---|---|---|
| shared | corporate | 3 | Cross-domain shared reference entities (currency, UoM, calendar, classification) consolidated for Single Source of Truth (SSOT). | 11 |

**Subdomains:** contractual_documentation, external_counterparties, organizational_parties


**List of Data Products**

| Subdomain | Product | Data Type | Description | Total Attributes |
|---|---|---|---|---|
| contractual_documentation | contract | master_data | Master reference table for contract. Referenced by contract_id. | 38 |
| contractual_documentation | document | master_data | Master reference table for document. Referenced by confirmation_document_id. | 34 |
| external_counterparties | auditor | master_data | Master reference table for auditor. Referenced by auditor_id. | 41 |
| external_counterparties | contractor | master_data | Master reference table for contractor. Referenced by contractor_id. | 38 |
| external_counterparties | fund_administrator | master_data | Master reference table for fund_administrator. Referenced by administrator_id. | 44 |
| external_counterparties | loan_servicer | master_data | Master reference table for loan_servicer. Referenced by servicer_id. | 43 |
| external_counterparties | vendor | master_data | Master reference table for vendor. Referenced by vendor_id. | 38 |
| organizational_parties | actor | master_data | Master reference table for actor.  | 34 |
| organizational_parties | department | master_data | Master reference table for department. Referenced by department_id. | 33 |
| organizational_parties | employee | master_data | Master reference table for employee.  | 37 |
| organizational_parties | legal_entity | master_data | Master reference table for legal_entity. Referenced by legal_entity_id. | 47 |

## Metric Views

Total metric views generated: **373**. Showing top 20.

| # | View Name | Domain | Source Table | Description |
|---|---|---|---|---|
| 1 | collateral_counterparty | collateral | counterparty | Counterparty credit-quality KPIs: default probability, recovery, ESG, credit/exposure limits and blacklist exposure. Used by Risk/CRO to steer counterparty concentration and credit discipline. |
| 2 | collateral_counterparty_exposure | collateral | exposure | Current and stressed counterparty exposure for OTC derivative risk management. |
| 3 | collateral_counterparty_rating_quality | collateral | counterparty_rating | Credit quality distribution of counterparties for concentration risk oversight. |
| 4 | collateral_counterparty_stress_impact | collateral | counterparty_stress_result | Stress-scenario loss impact on counterparty exposures for resilience assessment. |
| 5 | collateral_credit_limit_breach | collateral | credit_limit_breach | Credit-limit breach KPIs: breach volume, severity, resolution timeliness and magnitude. Used by Risk and Compliance to steer counterparty limit discipline and SOX control attestation. |
| 6 | collateral_credit_limit_breach_rate | collateral | credit_limit_breach | Counterparty credit-limit breaches and exceedance amounts. |
| 7 | collateral_credit_limit_utilization | collateral | credit_limit | Utilization of approved counterparty credit limits for exposure governance. |
| 8 | collateral_emir_trade_reporting | collateral | emir_trade_report | EMIR derivative trade reporting volume and submission status for regulatory compliance. |
| 9 | collateral_exposure | collateral | exposure | Counterparty credit-exposure KPIs: gross/net exposure, collateralization, residual exposure after collateral, and risk metrics (VaR/CVaR/DV01). Used by Risk and CRO to monitor counterparty credit risk and collateral efficiency. |
| 10 | collateral_margin_call | collateral | margin_call | Margin call lifecycle KPIs: call volume, exposure amounts, settlement timeliness and dispute-prone activity. Used by Collateral Operations and Treasury to steer liquidity and operational SLA performance. |
| 11 | collateral_margin_call_settlement | collateral | margin_call | Margin call volume, amounts, and settlement timeliness in collateral operations. |
| 12 | collateral_margin_dispute | collateral | margin_dispute | Margin-dispute KPIs: disputed amount, resolution magnitude and resolution efficiency. Used by Collateral Ops to steer dispute reduction and counterparty valuation alignment. |
| 13 | collateral_margin_dispute_rate | collateral | margin_dispute | Collateral margin disputes and amounts in dispute for operational risk tracking. |
| 14 | collateral_position | collateral | collateral_position | Collateral inventory and valuation KPIs: market value, haircut-adjusted net value, eligibility and haircut severity by asset type. Used by Collateral Management to optimize collateral quality and funding cost. |
| 15 | collateral_posting | collateral | posting | Collateral postings supporting CSA obligations across counterparties. |
| 16 | collateral_recall_volume | collateral | recall | Collateral recall activity volume and value for collateral optimization. |
| 17 | collateral_repo_financing | collateral | repo_transaction | Repo and reverse-repo activity used for liquidity and leverage management. |
| 18 | collateral_repo_transaction | collateral | repo_transaction | Repo financing KPIs: principal/collateral value, haircut, repo rate and margin amounts. Used by Treasury/Funding to steer secured-financing cost and collateral utilization. |
| 19 | collateral_securities_lending_income | collateral | securities_lending | FALLBACK: original MV failed install, replaced with minimal row-count view: no designed measure survived the column checks |
| 20 | collateral_simm_calculation | collateral | simm_calculation | SIMM initial-margin KPIs: initial margin posted, net margin, margin factor and call-required share by risk class and regulatory framework. Used by Risk/Collateral to steer IM funding under EMIR/UMR. |

*... and 353 more metric views. See the `metrics/` folder for full details.*