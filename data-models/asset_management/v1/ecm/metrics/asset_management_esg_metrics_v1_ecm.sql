-- Metric views for domain: esg | Business: Asset Management | Version: 1 | Generated on: 2026-11-10 14:18:58

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`esg_controversy`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "ESG controversy analytics covering incident volume, severity, financial penalties, escalation and divestment recommendations. Drives risk mitigation, exclusion and divestment decisions."
  source: "`asset_management`.`esg`.`controversy`"
  dimensions:
    - name: "severity_level"
      display_name: "Severity Level"
      expr: severity_level
      comment: "Severity band of the controversy."
    - name: "controversy_status"
      display_name: "Controversy Status"
      expr: controversy_status
      comment: "Current status of the controversy case."
    - name: "controversy_type"
      display_name: "Controversy Type"
      expr: controversy_type
      comment: "Type/category of the controversy."
    - name: "sector_classification"
      display_name: "Sector"
      expr: sector_classification
      comment: "Sector of the investee involved in the controversy."
    - name: "geographic_location"
      display_name: "Geographic Location"
      expr: geographic_location
      comment: "Geographic location of the controversy incident."
    - name: "identification_month"
      display_name: "Identification Month"
      expr: DATE_TRUNC('month', identification_date)
      comment: "Month bucket of the controversy identification date for trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Controversies"
      display_name: "Controversies"
      expr: COUNT(DISTINCT controversy_id)
      comment: "Count of distinct controversies; headline ESG-risk incident volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Financial Penalties"
      display_name: "Total Financial Penalties"
      expr: SUM(CAST(financial_penalty_amount AS DOUBLE))
      comment: "Total financial penalties linked to controversies; quantifies regulatory and reputational cost."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Escalated Controversies"
      display_name: "Escalated Controversies"
      expr: COUNT(DISTINCT CASE WHEN escalation_flag = TRUE THEN controversy_id END)
      comment: "Count of escalated controversies requiring investment-committee or leadership attention."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Divestment Recommended %"
      display_name: "Divestment Recommended %"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN divestment_recommendation IS NOT NULL AND divestment_recommendation <> 'None' THEN controversy_id END) / NULLIF(COUNT(DISTINCT controversy_id), 0), 2)
      comment: "Share of controversies with a divestment recommendation; signals portfolio exit pressure."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "UNGC Violation Controversies %"
      display_name: "UNGC Violation %"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN un_global_compact_violation = TRUE THEN controversy_id END) / NULLIF(COUNT(DISTINCT controversy_id), 0), 2)
      comment: "Share of controversies involving UN Global Compact violations; flags the most severe norms breaches."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Regulatory Action %"
      display_name: "Regulatory Action %"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN regulatory_action_flag = TRUE THEN controversy_id END) / NULLIF(COUNT(DISTINCT controversy_id), 0), 2)
      comment: "Share of controversies that triggered regulatory action; compliance-risk escalation signal."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`esg_due_diligence`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "ESG due-diligence analytics for deal screening covering overall/pillar ESG scores, carbon intensity, exclusion breaches and IC recommendations. Steers investment-approval decisions at the deal level."
  source: "`asset_management`.`esg`.`due_diligence`"
  dimensions:
    - name: "asset_class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the diligence target."
    - name: "assessment_status"
      display_name: "Assessment Status"
      expr: assessment_status
      comment: "Status of the ESG due-diligence assessment."
    - name: "esg_risk_rating"
      display_name: "ESG Risk Rating"
      expr: esg_risk_rating
      comment: "Overall ESG risk rating assigned during diligence."
    - name: "sfdr_article_classification"
      display_name: "SFDR Article"
      expr: sfdr_article_classification
      comment: "SFDR article classification of the target."
    - name: "target_sector"
      display_name: "Target Sector"
      expr: target_sector
      comment: "Sector of the diligence target."
    - name: "initiation_month"
      display_name: "Initiation Month"
      expr: DATE_TRUNC('month', initiation_date)
      comment: "Month bucket of diligence initiation for pipeline trending."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Diligence Assessments"
      display_name: "Diligence Assessments"
      expr: COUNT(DISTINCT due_diligence_id)
      comment: "Count of distinct ESG diligence assessments; deal-screening volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg ESG Overall Score"
      display_name: "Avg ESG Overall Score"
      expr: AVG(CAST(esg_overall_score AS DOUBLE))
      comment: "Average overall ESG score of diligence targets; headline deal-quality screen."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Taxonomy Alignment %"
      display_name: "Avg Taxonomy Alignment %"
      expr: AVG(CAST(taxonomy_alignment_pct AS DOUBLE))
      comment: "Average taxonomy alignment of diligence targets; green-share of the deal pipeline."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Carbon Intensity"
      display_name: "Avg Carbon Intensity"
      expr: AVG(CAST(carbon_intensity_value AS DOUBLE))
      comment: "Average carbon intensity of diligence targets."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Exclusion Breach Rate %"
      display_name: "Exclusion Breach Rate %"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN exclusion_policy_breach_flag = TRUE THEN due_diligence_id END) / NULLIF(COUNT(DISTINCT due_diligence_id), 0), 2)
      comment: "Share of diligence targets breaching exclusion policy; gating KPI for deal approval."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Net Zero Commitment Rate %"
      display_name: "Net Zero Commitment Rate %"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN net_zero_commitment_flag = TRUE THEN due_diligence_id END) / NULLIF(COUNT(DISTINCT due_diligence_id), 0), 2)
      comment: "Share of diligence targets with a net-zero commitment; climate screen for new investments."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "UNGC Violation Rate %"
      display_name: "UNGC Violation Rate %"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN un_global_compact_violation_flag = TRUE THEN due_diligence_id END) / NULLIF(COUNT(DISTINCT due_diligence_id), 0), 2)
      comment: "Share of diligence targets with UN Global Compact violations; norms-based exclusion screen."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`esg_engagement_activity`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Stewardship engagement activity analytics covering engagement volume, outcomes, escalation and proxy voting across investee companies. Used to demonstrate active ownership and prioritize engagement resources."
  source: "`asset_management`.`esg`.`engagement_activity`"
  dimensions:
    - name: "engagement_topic"
      display_name: "Engagement Topic"
      expr: engagement_topic
      comment: "Primary ESG topic of the engagement (climate, governance, labor, etc.)."
    - name: "engagement_status"
      display_name: "Engagement Status"
      expr: engagement_status
      comment: "Current status of the engagement (open, ongoing, closed)."
    - name: "engagement_type"
      display_name: "Engagement Type"
      expr: engagement_type
      comment: "Type of engagement (direct dialogue, collaborative, voting)."
    - name: "escalation_level"
      display_name: "Escalation Level"
      expr: escalation_level
      comment: "Escalation level reached for the engagement."
    - name: "investee_sector"
      display_name: "Investee Sector"
      expr: investee_sector
      comment: "Sector of the investee being engaged."
    - name: "asset_class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the engaged holding."
    - name: "engagement_month"
      display_name: "Engagement Month"
      expr: DATE_TRUNC('month', engagement_date)
      comment: "Month bucket of the engagement date for stewardship activity trending."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Engagements"
      display_name: "Engagements"
      expr: COUNT(DISTINCT engagement_activity_id)
      comment: "Count of distinct engagement activities; headline active-ownership volume metric."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Investees Engaged"
      display_name: "Investees Engaged"
      expr: COUNT(DISTINCT investee_lei)
      comment: "Count of distinct investee entities engaged; measures breadth of stewardship coverage."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Holding Value Engaged"
      display_name: "Holding Value Engaged"
      expr: SUM(CAST(holding_value_at_engagement AS DOUBLE))
      comment: "Total holding value subject to engagement; shows the AUM weight of active ownership."
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
    - name: "Escalated Engagements"
      display_name: "Escalated Engagements"
      expr: COUNT(DISTINCT CASE WHEN escalation_level IS NOT NULL AND escalation_level <> 'None' THEN engagement_activity_id END)
      comment: "Count of engagements that reached escalation; signals unresolved stewardship issues needing leadership attention."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Voting Actions Taken"
      display_name: "Voting Actions Taken"
      expr: COUNT(DISTINCT CASE WHEN voting_action_taken = TRUE THEN engagement_activity_id END)
      comment: "Count of engagements where a proxy voting action was taken; links voting to engagement outcomes."
      format:
        type: number
        decimal_places:
          type: all
    - name: "UNGC Violation Engagements %"
      display_name: "UNGC Violation Engagements %"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN un_global_compact_violation_flag = TRUE THEN engagement_activity_id END) / NULLIF(COUNT(DISTINCT engagement_activity_id), 0), 2)
      comment: "Share of engagements tied to UN Global Compact violations; prioritizes the most severe stewardship cases."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Active Engagement Rate %"
      display_name: "Active Engagement Rate %"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN is_active = TRUE THEN engagement_activity_id END) / NULLIF(COUNT(DISTINCT engagement_activity_id), 0), 2)
      comment: "Share of engagements still active; measures the open workload of the stewardship team."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`esg_ghg_emission_record`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Financed and attributed greenhouse-gas emissions analytics across scopes, asset classes and reporting periods. Central to TCFD climate-risk reporting, carbon-budget steering and Paris alignment monitoring."
  source: "`asset_management`.`esg`.`ghg_emission_record`"
  dimensions:
    - name: "asset_class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the emitting holding for carbon segmentation."
    - name: "sector_classification"
      display_name: "Sector"
      expr: sector_classification
      comment: "Sector classification of the issuer for carbon hot-spot analysis."
    - name: "geographic_scope"
      display_name: "Geographic Scope"
      expr: geographic_scope
      comment: "Geographic scope of the emissions record."
    - name: "verification_status"
      display_name: "Verification Status"
      expr: verification_status
      comment: "Verification status of the emissions data for data-quality governance."
    - name: "measurement_month"
      display_name: "Measurement Month"
      expr: DATE_TRUNC('month', measurement_date)
      comment: "Month bucket of the emissions measurement date for carbon trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "measurement_year"
      display_name: "Measurement Year"
      expr: DATE_TRUNC('year', measurement_date)
      comment: "Year bucket of the emissions measurement date for YoY decarbonization tracking."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Emission Records"
      display_name: "Emission Records"
      expr: COUNT(DISTINCT ghg_emission_record_id)
      comment: "Count of distinct emission records; coverage base for carbon KPIs."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Attributed Emissions tCO2e"
      display_name: "Total Attributed Emissions (tCO2e)"
      expr: SUM(CAST(attributed_emissions_tco2e AS DOUBLE))
      comment: "Total financed/attributed emissions in tCO2e; headline financed-emissions figure for TCFD and net-zero tracking."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Scope 1 Emissions tCO2e"
      display_name: "Scope 1 (tCO2e)"
      expr: SUM(CAST(scope_1_emissions_tco2e AS DOUBLE))
      comment: "Total Scope 1 direct emissions in tCO2e."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Scope 2 Market Based Emissions tCO2e"
      display_name: "Scope 2 Market-Based (tCO2e)"
      expr: SUM(CAST(scope_2_market_based_emissions_tco2e AS DOUBLE))
      comment: "Total Scope 2 market-based emissions in tCO2e."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Scope 3 Emissions tCO2e"
      display_name: "Scope 3 (tCO2e)"
      expr: SUM(CAST(scope_3_emissions_tco2e AS DOUBLE))
      comment: "Total Scope 3 value-chain emissions in tCO2e; largest and highest-uncertainty component of financed emissions."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Carbon Footprint per Million Invested"
      display_name: "Avg Carbon Footprint / $M"
      expr: AVG(CAST(carbon_footprint_per_million_invested AS DOUBLE))
      comment: "Average carbon footprint per million invested; normalized intensity metric for comparing holdings."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Avg Emissions Intensity"
      display_name: "Avg Emissions Intensity"
      expr: AVG(CAST(emissions_intensity_value AS DOUBLE))
      comment: "Average emissions intensity value; used for weighted-average carbon intensity decomposition."
      format:
        type: number
        decimal_places:
          type: exact
          places: 4
    - name: "Paris Aligned Records %"
      display_name: "Paris Aligned %"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN paris_alignment_flag = TRUE THEN ghg_emission_record_id END) / NULLIF(COUNT(DISTINCT ghg_emission_record_id), 0), 2)
      comment: "Share of emission records flagged Paris-aligned; climate-alignment steering KPI for the investment committee."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Data Quality Score"
      display_name: "Avg Data Quality Score"
      expr: AVG(CAST(data_quality_score AS DOUBLE))
      comment: "Average emissions data-quality score; reliability guardrail for carbon reporting decisions."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Attributed Emissions CY"
      display_name: "Attributed Emissions CY"
      expr: SUM(CAST(attributed_emissions_tco2e AS DOUBLE))
      comment: "Current-year total attributed emissions used for YoY decarbonization comparison."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
      window:
        - order: measurement_year
          range: current
          semiadditive: last
    - name: "Total Attributed Emissions PY"
      display_name: "Attributed Emissions PY"
      expr: SUM(CAST(attributed_emissions_tco2e AS DOUBLE))
      comment: "Prior-year total attributed emissions used for YoY decarbonization comparison."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
      window:
        - order: measurement_year
          range: current
          semiadditive: last
          offset: -1 year
    - name: "Attributed Emissions YoY"
      display_name: "Attributed Emissions YoY"
      expr: (AGG(`Total Attributed Emissions CY`) - AGG(`Total Attributed Emissions PY`)) / NULLIF(AGG(`Total Attributed Emissions PY`), 0)
      comment: "Year-over-year change in attributed emissions; directly tracks decarbonization progress against net-zero commitments."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`esg_issuer_esg_rating`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Issuer-level ESG rating analytics covering overall ESG scores, pillar scores, controversy exposure, carbon intensity, net-zero coverage and exclusion flags. Used by the investment committee and responsible-investment teams to steer portfolio ESG quality and engagement priorities."
  source: "`asset_management`.`esg`.`issuer_esg_rating`"
  dimensions:
    - name: "asset_class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the rated issuer (public equity, credit, etc.) for ESG quality segmentation."
    - name: "esg_rating_grade"
      display_name: "ESG Rating Grade"
      expr: esg_rating_grade
      comment: "Letter/grade ESG rating assigned to the issuer; primary quality band for ESG screening."
    - name: "esg_controversy_level"
      display_name: "Controversy Level"
      expr: esg_controversy_level
      comment: "Severity band of outstanding ESG controversies for the issuer."
    - name: "gics_sector_code"
      display_name: "GICS Sector"
      expr: gics_sector_code
      comment: "GICS sector classification for sector-level ESG benchmarking."
    - name: "domicile_country_code"
      display_name: "Domicile Country"
      expr: domicile_country_code
      comment: "Country of domicile of the issuer for geographic ESG risk analysis."
    - name: "rating_provider"
      display_name: "Rating Provider"
      expr: rating_provider
      comment: "External ESG rating provider that issued the rating."
    - name: "rating_month"
      display_name: "Rating Month"
      expr: DATE_TRUNC('month', rating_date)
      comment: "Month bucket of the rating date for ESG rating trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "rating_year"
      display_name: "Rating Year"
      expr: DATE_TRUNC('year', rating_date)
      comment: "Year bucket of the rating date for year-over-year ESG rating trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Rated Issuers"
      display_name: "Rated Issuers"
      expr: COUNT(DISTINCT issuer_esg_rating_id)
      comment: "Count of distinct issuer ESG ratings; coverage base for all ESG rating KPIs."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg ESG Score"
      display_name: "Avg ESG Score"
      expr: AVG(CAST(esg_rating_score AS DOUBLE))
      comment: "Average overall ESG rating score across issuers; headline portfolio ESG quality metric that triggers reallocation or engagement when it falls."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Environmental Score"
      display_name: "Avg Environmental Score"
      expr: AVG(CAST(environmental_score AS DOUBLE))
      comment: "Average environmental pillar score; informs climate and resource stewardship steering."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Social Score"
      display_name: "Avg Social Score"
      expr: AVG(CAST(social_score AS DOUBLE))
      comment: "Average social pillar score across issuers."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Governance Score"
      display_name: "Avg Governance Score"
      expr: AVG(CAST(governance_score AS DOUBLE))
      comment: "Average governance pillar score across issuers."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Carbon Intensity"
      display_name: "Avg Carbon Intensity"
      expr: AVG(CAST(carbon_intensity AS DOUBLE))
      comment: "Average carbon intensity of rated issuers; core decarbonization steering metric."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg ESG Data Coverage %"
      display_name: "Avg ESG Data Coverage %"
      expr: AVG(CAST(esg_data_coverage_pct AS DOUBLE))
      comment: "Average ESG data coverage percentage; data-quality guardrail for the reliability of ESG decisions."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Issuers On Exclusion List"
      display_name: "Excluded Issuers"
      expr: COUNT(DISTINCT CASE WHEN on_exclusion_list = TRUE THEN issuer_esg_rating_id END)
      comment: "Count of rated issuers flagged on the exclusion list; signals divestment and compliance exposure."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Net Zero Target Issuers"
      display_name: "Net Zero Target Issuers"
      expr: COUNT(DISTINCT CASE WHEN net_zero_target_flag = TRUE THEN issuer_esg_rating_id END)
      comment: "Count of issuers with a net-zero target; tracks progress of portfolio alignment to net zero."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Net Zero Alignment %"
      display_name: "Net Zero Alignment %"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN net_zero_target_flag = TRUE THEN issuer_esg_rating_id END) / NULLIF(COUNT(DISTINCT issuer_esg_rating_id), 0), 2)
      comment: "Share of rated issuers committed to a net-zero target; headline climate-alignment KPI for board reporting."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`esg_kpi_measurement`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "ESG KPI measurement analytics tracking actual versus target performance, progress to target and on-track rates across portfolios and holdings. Drives accountability against ESG objectives."
  source: "`asset_management`.`esg`.`kpi_measurement`"
  dimensions:
    - name: "asset_class"
      display_name: "Asset Class"
      expr: asset_class
      comment: "Asset class of the KPI measurement."
    - name: "measurement_status"
      display_name: "Measurement Status"
      expr: measurement_status
      comment: "Status of the KPI measurement record."
    - name: "sfdr_pai_indicator"
      display_name: "SFDR PAI Indicator"
      expr: sfdr_pai_indicator
      comment: "SFDR Principal Adverse Impact indicator the KPI maps to."
    - name: "sector_classification"
      display_name: "Sector"
      expr: sector_classification
      comment: "Sector classification for the measured KPI."
    - name: "measurement_month"
      display_name: "Measurement Month"
      expr: DATE_TRUNC('month', measurement_date)
      comment: "Month bucket of the KPI measurement date for progress trending."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Measurements"
      display_name: "Measurements"
      expr: COUNT(DISTINCT kpi_measurement_id)
      comment: "Count of distinct KPI measurements; coverage base for KPI performance metrics."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Progress To Target %"
      display_name: "Avg Progress To Target %"
      expr: AVG(CAST(progress_to_target_percentage AS DOUBLE))
      comment: "Average progress toward ESG KPI targets; headline accountability metric for ESG objectives."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "On Track Rate %"
      display_name: "On Track Rate %"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN on_track_flag = TRUE THEN kpi_measurement_id END) / NULLIF(COUNT(DISTINCT kpi_measurement_id), 0), 2)
      comment: "Share of KPIs on track to meet their target; triggers intervention when it drops."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Variance %"
      display_name: "Avg Variance %"
      expr: AVG(CAST(variance_percentage AS DOUBLE))
      comment: "Average variance between actual and target KPI values; highlights magnitude of under/over-performance."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Exception Rate %"
      display_name: "Exception Rate %"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN exception_flag = TRUE THEN kpi_measurement_id END) / NULLIF(COUNT(DISTINCT kpi_measurement_id), 0), 2)
      comment: "Share of measurements flagged as exceptions; data-governance and escalation signal."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Data Coverage %"
      display_name: "Avg Data Coverage %"
      expr: AVG(CAST(data_coverage_percentage AS DOUBLE))
      comment: "Average data coverage percentage for KPI measurements; reliability guardrail."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`esg_proxy_vote_record`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Proxy voting analytics covering vote volume, alignment with management and proxy advisors, and ESG-relevant voting. Demonstrates active ownership and voting discipline for stewardship reporting."
  source: "`asset_management`.`esg`.`proxy_vote_record`"
  dimensions:
    - name: "vote_direction"
      display_name: "Vote Direction"
      expr: vote_direction
      comment: "Direction of the vote cast (for/against/abstain)."
    - name: "resolution_category"
      display_name: "Resolution Category"
      expr: resolution_category
      comment: "Category of the resolution voted on."
    - name: "esg_theme"
      display_name: "ESG Theme"
      expr: esg_theme
      comment: "ESG theme of the resolution."
    - name: "vote_status"
      display_name: "Vote Status"
      expr: vote_status
      comment: "Status of the vote record."
    - name: "meeting_month"
      display_name: "Meeting Month"
      expr: DATE_TRUNC('month', meeting_date)
      comment: "Month bucket of the shareholder meeting date for voting season trends."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Votes Cast"
      display_name: "Votes Cast"
      expr: COUNT(DISTINCT proxy_vote_record_id)
      comment: "Count of distinct proxy votes cast; headline voting-activity volume."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Shares Voted"
      display_name: "Total Shares Voted"
      expr: SUM(CAST(shares_voted AS DOUBLE))
      comment: "Total number of shares voted; measures voting weight exercised."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Against Management Rate %"
      display_name: "Against Management Rate %"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN vote_alignment_with_management = FALSE THEN proxy_vote_record_id END) / NULLIF(COUNT(DISTINCT proxy_vote_record_id), 0), 2)
      comment: "Share of votes cast against management recommendation; key active-ownership independence metric."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "ESG Relevant Vote %"
      display_name: "ESG Relevant Vote %"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN esg_relevance_flag = TRUE THEN proxy_vote_record_id END) / NULLIF(COUNT(DISTINCT proxy_vote_record_id), 0), 2)
      comment: "Share of votes flagged ESG-relevant; focuses stewardship reporting on material votes."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "ISS Alignment Rate %"
      display_name: "ISS Alignment Rate %"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN vote_alignment_with_iss = TRUE THEN proxy_vote_record_id END) / NULLIF(COUNT(DISTINCT proxy_vote_record_id), 0), 2)
      comment: "Share of votes aligned with ISS recommendations; benchmarks independence against proxy advisors."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `asset_management`.`_metrics`.`esg_taxonomy_alignment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "EU Taxonomy alignment analytics covering alignment percentage, eligible revenue/capex/opex and compliance status across holdings and portfolios. Core to SFDR and sustainable-investment disclosure."
  source: "`asset_management`.`esg`.`taxonomy_alignment`"
  dimensions:
    - name: "alignment_status"
      display_name: "Alignment Status"
      expr: alignment_status
      comment: "Status of the taxonomy alignment assessment."
    - name: "sector_classification"
      display_name: "Sector"
      expr: sector_classification
      comment: "Sector classification for taxonomy alignment segmentation."
    - name: "compliance_status"
      display_name: "Compliance Status"
      expr: compliance_status
      comment: "Compliance status against the taxonomy framework."
    - name: "country_code"
      display_name: "Country"
      expr: country_code
      comment: "Country of the activity for geographic taxonomy analysis."
    - name: "climate_objective"
      display_name: "Climate Objective"
      expr: climate_objective
      comment: "Climate objective the activity contributes to (mitigation/adaptation)."
    - name: "effective_month"
      display_name: "Effective Month"
      expr: DATE_TRUNC('month', effective_date)
      comment: "Month bucket of the alignment effective date for trend analysis."
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Alignment Assessments"
      display_name: "Alignment Assessments"
      expr: COUNT(DISTINCT taxonomy_alignment_id)
      comment: "Count of distinct taxonomy alignment assessments; coverage base."
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Alignment %"
      display_name: "Avg Alignment %"
      expr: AVG(CAST(alignment_percentage AS DOUBLE))
      comment: "Average EU Taxonomy alignment percentage; headline green-share metric for SFDR disclosure."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Eligible Revenue %"
      display_name: "Avg Eligible Revenue %"
      expr: AVG(CAST(eligible_revenue_pct AS DOUBLE))
      comment: "Average taxonomy-eligible revenue percentage across activities."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Eligible Capex %"
      display_name: "Avg Eligible Capex %"
      expr: AVG(CAST(eligible_capex_pct AS DOUBLE))
      comment: "Average taxonomy-eligible capex percentage; forward-looking green-investment signal."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Carbon Intensity"
      display_name: "Avg Carbon Intensity"
      expr: AVG(CAST(carbon_intensity_value AS DOUBLE))
      comment: "Average carbon intensity of aligned activities."
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Net Zero Committed Activities %"
      display_name: "Net Zero Committed %"
      expr: ROUND(100.0 * COUNT(DISTINCT CASE WHEN net_zero_commitment_flag = TRUE THEN taxonomy_alignment_id END) / NULLIF(COUNT(DISTINCT taxonomy_alignment_id), 0), 2)
      comment: "Share of activities with a net-zero commitment; links taxonomy alignment to climate commitments."
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;
