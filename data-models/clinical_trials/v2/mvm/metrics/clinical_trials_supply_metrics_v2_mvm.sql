-- Metric views for domain: supply | Business: Clinical_Trials | Version: 19 | Generated on: 2026-11-20 12:39:51

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`supply_destruction_record`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "IMP destruction and waste management KPIs for regulatory compliance and cost control"
  source: "`clinical_trials_mvm`.`supply`.`destruction_record`"
  dimensions:
    - name: "Destruction Status"
      display_name: "Destruction Status"
      expr: destruction_status
      comment: "Current status of the destruction record (pending, completed, certified)"
    - name: "Destruction Reason"
      display_name: "Destruction Reason"
      expr: destruction_reason
      comment: "Reason for destruction (expired, damaged, protocol deviation, study closure)"
    - name: "Destruction Method"
      display_name: "Destruction Method"
      expr: destruction_method
      comment: "Method used for destruction (incineration, chemical, landfill)"
    - name: "Blinded Destruction"
      display_name: "Blinded Destruction"
      expr: CASE WHEN is_blinded_destruction THEN 'Blinded' ELSE 'Unblinded' END
      comment: "Whether destruction was performed under blinded conditions"
    - name: "Cold Chain Maintained"
      display_name: "Cold Chain Maintained"
      expr: CASE WHEN cold_chain_maintained THEN 'Maintained' ELSE 'Broken' END
      comment: "Whether cold chain was maintained until destruction"
    - name: "Temperature Excursion Noted"
      display_name: "Temperature Excursion Noted"
      expr: CASE WHEN temperature_excursion_noted THEN 'Yes' ELSE 'No' END
      comment: "Whether temperature excursion was noted prior to destruction"
    - name: "Regulatory Notification Required"
      display_name: "Regulatory Notification Required"
      expr: CASE WHEN regulatory_notification_required THEN 'Yes' ELSE 'No' END
      comment: "Whether regulatory notification is required for this destruction"
    - name: "Reconciliation Status"
      display_name: "Reconciliation Status"
      expr: reconciliation_status
      comment: "Status of accountability reconciliation for destroyed items"
    - name: "Destruction Year"
      display_name: "Destruction Year"
      expr: DATE_TRUNC('year', destruction_date)
      comment: "Year of destruction"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Destruction Quarter"
      display_name: "Destruction Quarter"
      expr: DATE_TRUNC('quarter', destruction_date)
      comment: "Quarter of destruction"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Destruction Month"
      display_name: "Destruction Month"
      expr: DATE_TRUNC('month', destruction_date)
      comment: "Month of destruction"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Destruction Records"
      display_name: "Total Destruction Records"
      expr: COUNT(1)
      comment: "Total number of destruction records"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Qty Destroyed"
      display_name: "Total Qty Destroyed"
      expr: SUM(CAST(quantity_destroyed AS DOUBLE))
      comment: "Total quantity of IMP destroyed (waste and cost KPI)"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Kits Destroyed"
      display_name: "Total Kits Destroyed"
      expr: SUM(CAST(kit_count_destroyed AS DOUBLE))
      comment: "Total number of kits destroyed"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Weight Destroyed Kg"
      display_name: "Total Weight Destroyed (kg)"
      expr: SUM(CAST(weight_destroyed_kg AS DOUBLE))
      comment: "Total weight of IMP destroyed in kilograms (environmental impact indicator)"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Expiry Destruction Rate"
      display_name: "Expiry Destruction Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN destruction_reason = 'Expired' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of destructions due to expiry (waste management KPI)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Damage Destruction Rate"
      display_name: "Damage Destruction Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN destruction_reason = 'Damaged' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of destructions due to damage (quality and handling KPI)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Regulatory Notification Rate"
      display_name: "Regulatory Notification Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN regulatory_notification_required THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of destructions requiring regulatory notification (compliance indicator)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Reconciliation Completed Rate"
      display_name: "Reconciliation Completed Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN reconciliation_status = 'Completed' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of destructions with completed accountability reconciliation"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Certificate Issued Rate"
      display_name: "Certificate Issued Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN certificate_of_destruction_ref IS NOT NULL THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of destructions with issued certificate (documentation compliance KPI)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Blinded Destruction Rate"
      display_name: "Blinded Destruction Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN is_blinded_destruction THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of destructions performed under blinded conditions (trial integrity KPI)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Temperature Excursion Noted Rate"
      display_name: "Temperature Excursion Noted Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN temperature_excursion_noted THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of destructions where temperature excursion was noted (quality indicator)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Kits Per Destruction"
      display_name: "Avg Kits Per Destruction"
      expr: AVG(CAST(kit_count_destroyed AS DOUBLE))
      comment: "Average number of kits destroyed per destruction event"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Time To Certificate Days"
      display_name: "Avg Time To Certificate (days)"
      expr: AVG(CAST(DATEDIFF(certificate_issue_date, destruction_date) AS DOUBLE))
      comment: "Average number of days from destruction to certificate issuance (process efficiency KPI)"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`supply_dispensing_efficiency`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Dispensing volume and return KPIs for clinical trial kits"
  source: "`clinical_trials_mvm`.`supply`.`dispensing_record`"
  dimensions:
    - name: "study_id"
      display_name: "Study Id"
      expr: study_id
      comment: "Study identifier associated with the dispensing event"
    - name: "kit_definition_id"
      display_name: "Kit Definition Id"
      expr: kit_definition_id
      comment: "Kit definition identifier for the dispensed product"
    - name: "dispensing_year"
      display_name: "Dispensing Year"
      expr: DATE_TRUNC('year', dispensing_date)
      comment: "Year of dispensing"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "dispensing_month"
      display_name: "Dispensing Month"
      expr: DATE_TRUNC('month', dispensing_date)
      comment: "Month of dispensing"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_quantity_dispensed"
      display_name: "Total Quantity Dispensed"
      expr: SUM(CAST(quantity_dispensed AS DOUBLE))
      comment: "Total units of investigational product dispensed to subjects"
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_quantity_returned"
      display_name: "Total Quantity Returned"
      expr: SUM(CAST(quantity_returned AS DOUBLE))
      comment: "Total units returned from subjects back to inventory"
      format:
        type: number
        decimal_places:
          type: all
    - name: "return_rate"
      display_name: "Return Rate"
      expr: (AGG(`total_quantity_returned`) / NULLIF(AGG(`total_quantity_dispensed`), 0))
      comment: "Proportion of dispensed units that were returned"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "avg_dose_amount"
      display_name: "Average Dose Amount"
      expr: AVG(CAST(dose_amount AS DOUBLE))
      comment: "Average dose amount administered per dispensing event"
      format:
        type: currency
        currency_code: USD
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`supply_dispensing_record`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Subject dosing and IMP dispensing compliance KPIs for clinical trial execution"
  source: "`clinical_trials_mvm`.`supply`.`dispensing_record`"
  dimensions:
    - name: "Dispensing Status"
      display_name: "Dispensing Status"
      expr: dispensing_status
      comment: "Status of the dispensing event (completed, pending, cancelled)"
    - name: "Dispensing Method"
      display_name: "Dispensing Method"
      expr: dispensing_method
      comment: "Method used for dispensing (direct, IVRS, RTSM)"
    - name: "Route of Administration"
      display_name: "Route of Administration"
      expr: route_of_administration
      comment: "Route by which the IMP was administered"
    - name: "Dosage Form"
      display_name: "Dosage Form"
      expr: dosage_form
      comment: "Form of the dispensed IMP (tablet, injection, etc.)"
    - name: "Protocol Deviation Flag"
      display_name: "Protocol Deviation"
      expr: CASE WHEN protocol_deviation_flag THEN 'Deviation' ELSE 'Compliant' END
      comment: "Whether a protocol deviation occurred during dispensing"
    - name: "Cold Chain Maintained"
      display_name: "Cold Chain Status"
      expr: CASE WHEN cold_chain_maintained THEN 'Maintained' ELSE 'Broken' END
      comment: "Whether cold chain was maintained during dispensing"
    - name: "Temperature Excursion Flag"
      display_name: "Temperature Excursion"
      expr: CASE WHEN temperature_excursion_flag THEN 'Excursion' ELSE 'Compliant' END
      comment: "Whether a temperature excursion was noted during dispensing"
    - name: "Dispensing Year"
      display_name: "Dispensing Year"
      expr: DATE_TRUNC('year', dispensing_date)
      comment: "Year of dispensing"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Dispensing Quarter"
      display_name: "Dispensing Quarter"
      expr: DATE_TRUNC('quarter', dispensing_date)
      comment: "Quarter of dispensing"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Dispensing Month"
      display_name: "Dispensing Month"
      expr: DATE_TRUNC('month', dispensing_date)
      comment: "Month of dispensing"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Dispensing Events"
      display_name: "Total Dispensing Events"
      expr: COUNT(1)
      comment: "Total number of dispensing events"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Quantity Dispensed"
      display_name: "Total Quantity Dispensed"
      expr: SUM(CAST(quantity_dispensed AS DOUBLE))
      comment: "Total quantity of IMP dispensed across all events"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Quantity Returned"
      display_name: "Total Quantity Returned"
      expr: SUM(CAST(quantity_returned AS DOUBLE))
      comment: "Total quantity of IMP returned by subjects"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Subject Compliance Pct"
      display_name: "Avg Subject Compliance %"
      expr: AVG(CAST(subject_compliance_pct AS DOUBLE))
      comment: "Average subject compliance percentage across all dispensing events (critical efficacy indicator)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Protocol Deviation Rate"
      display_name: "Protocol Deviation Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN protocol_deviation_flag THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of dispensing events with protocol deviations (critical GCP compliance KPI)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Cold Chain Compliance Rate"
      display_name: "Cold Chain Compliance Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN cold_chain_maintained THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of dispensing events where cold chain was maintained"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Temperature Excursion Rate"
      display_name: "Temperature Excursion Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN temperature_excursion_flag THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of dispensing events with temperature excursions"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Accountability Reconciled Rate"
      display_name: "Accountability Reconciled Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN accountability_reconciled THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of dispensing events with completed accountability reconciliation"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Dose Amount"
      display_name: "Avg Dose Amount"
      expr: AVG(CAST(dose_amount AS DOUBLE))
      comment: "Average dose amount dispensed per event"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Return Rate"
      display_name: "Return Rate"
      expr: ROUND(100.0 * SUM(CAST(quantity_returned AS DOUBLE)) / NULLIF(SUM(CAST(quantity_dispensed AS DOUBLE)), 0), 2)
      comment: "Percentage of dispensed quantity that was returned (inverse compliance indicator)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`supply_inventory_balance`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Key inventory balance and stockout KPIs for clinical trial supplies"
  source: "`clinical_trials_mvm`.`supply`.`site_inventory`"
  dimensions:
    - name: "depot_id"
      display_name: "Depot Id"
      expr: depot_id
      comment: "Depot identifier where inventory is stored"
    - name: "inventory_status"
      display_name: "Inventory Status"
      expr: inventory_status
      comment: "Current status of the inventory record (e.g., active, quarantined)"
    - name: "year"
      display_name: "Year"
      expr: DATE_TRUNC('year', record_created_timestamp)
      comment: "Year of the inventory record creation"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "month"
      display_name: "Month"
      expr: DATE_TRUNC('month', record_created_timestamp)
      comment: "Month of the inventory record creation"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_qty_on_hand"
      display_name: "Total Quantity On Hand"
      expr: SUM(CAST(qty_on_hand AS DOUBLE))
      comment: "Total units currently on hand across inventory records"
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_qty_dispensed"
      display_name: "Total Quantity Dispensed"
      expr: SUM(CAST(qty_dispensed AS DOUBLE))
      comment: "Total units dispensed from inventory"
      format:
        type: number
        decimal_places:
          type: all
    - name: "stockout_events"
      display_name: "Stockout Events"
      expr: SUM(CASE WHEN qty_on_hand = 0 THEN 1 ELSE 0 END)
      comment: "Count of inventory records where on‑hand quantity is zero (stockout)"
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_records"
      display_name: "Inventory Records"
      expr: COUNT(1)
      comment: "Number of inventory records (rows) in the period"
      format:
        type: number
        decimal_places:
          type: all
    - name: "stockout_rate"
      display_name: "Stockout Rate"
      expr: (AGG(`stockout_events`) / NULLIF(AGG(`total_records`), 0))
      comment: "Proportion of inventory records that are stockouts"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`supply_manufacture_batch`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Manufacturing batch KPIs: batch size, available quantity, release status, recall rate, quarantine rate, and destruction metrics for investigational medicinal product manufacturing quality and inventory management."
  source: "`clinical_trials_mvm`.`supply`.`manufacture_batch`"
  dimensions:
    - name: "Batch Type"
      display_name: "Batch Type"
      expr: batch_type
      comment: "Type of manufacturing batch (e.g., Clinical, Commercial, Validation)"
    - name: "Release Status"
      display_name: "Release Status"
      expr: release_status
      comment: "Release status of the batch (e.g., Released, Pending, Rejected)"
    - name: "Blinding Type"
      display_name: "Blinding Type"
      expr: blinding_type
      comment: "Blinding type for the batch (e.g., Open-label, Single-blind, Double-blind)"
    - name: "Dosage Form"
      display_name: "Dosage Form"
      expr: dosage_form
      comment: "Dosage form of the manufactured product (e.g., Tablet, Capsule, Injection)"
    - name: "Packaging Configuration"
      display_name: "Packaging Configuration"
      expr: packaging_configuration
      comment: "Packaging configuration for the batch (e.g., Blister, Bottle, Vial)"
    - name: "Manufacturing Site Country"
      display_name: "Manufacturing Site Country"
      expr: manufacturing_site_country
      comment: "Country of the manufacturing site"
    - name: "Is Comparator"
      display_name: "Is Comparator"
      expr: is_comparator
      comment: "Indicates whether the batch is a comparator product"
    - name: "Is Placebo"
      display_name: "Is Placebo"
      expr: is_placebo
      comment: "Indicates whether the batch is a placebo"
    - name: "Recall Flag"
      display_name: "Recall Flag"
      expr: recall_flag
      comment: "Indicates whether the batch has been recalled"
    - name: "Manufacture Year"
      display_name: "Manufacture Year"
      expr: DATE_TRUNC('year', manufacture_date)
      comment: "Year of batch manufacture"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Manufacture Quarter"
      display_name: "Manufacture Quarter"
      expr: DATE_TRUNC('quarter', manufacture_date)
      comment: "Quarter of batch manufacture"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Manufacture Month"
      display_name: "Manufacture Month"
      expr: DATE_TRUNC('month', manufacture_date)
      comment: "Month of batch manufacture"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Expiry Year"
      display_name: "Expiry Year"
      expr: DATE_TRUNC('year', expiry_date)
      comment: "Year of batch expiry"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Release Year"
      display_name: "Release Year"
      expr: DATE_TRUNC('year', release_date)
      comment: "Year of batch release"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Manufacture Batch Count"
      display_name: "Manufacture Batch Count"
      expr: COUNT(1)
      comment: "Total number of manufacturing batches"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Batch Size"
      display_name: "Total Batch Size"
      expr: SUM(CAST(batch_size AS DOUBLE))
      comment: "Sum of batch size across all manufacturing batches"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Batch Size"
      display_name: "Avg Batch Size"
      expr: AVG(CAST(batch_size AS DOUBLE))
      comment: "Average batch size across manufacturing batches"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Available Quantity"
      display_name: "Total Available Quantity"
      expr: SUM(CAST(available_quantity AS DOUBLE))
      comment: "Sum of available quantity across all manufacturing batches"
      format:
        type: number
        decimal_places:
          type: all
      window:
        - order: Manufacture Month
          range: current
          semiadditive: last
    - name: "Total Quarantine Quantity"
      display_name: "Total Quarantine Quantity"
      expr: SUM(CAST(quarantine_quantity AS DOUBLE))
      comment: "Sum of quarantine quantity across all manufacturing batches"
      format:
        type: number
        decimal_places:
          type: all
      window:
        - order: Manufacture Month
          range: current
          semiadditive: last
    - name: "Total Destroyed Quantity"
      display_name: "Total Destroyed Quantity"
      expr: SUM(CAST(destroyed_quantity AS DOUBLE))
      comment: "Sum of destroyed quantity across all manufacturing batches"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Batch Release Rate"
      display_name: "Batch Release Rate %"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN release_status = 'Released' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of manufacturing batches that have been released"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Batch Recall Rate"
      display_name: "Batch Recall Rate %"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN recall_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of manufacturing batches that have been recalled"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Quarantine Rate"
      display_name: "Quarantine Rate %"
      expr: ROUND(100.0 * SUM(CAST(quarantine_quantity AS DOUBLE)) / NULLIF(SUM(CAST(batch_size AS DOUBLE)), 0), 2)
      comment: "Percentage of batch size that is quarantined"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Destruction Rate"
      display_name: "Destruction Rate %"
      expr: ROUND(100.0 * SUM(CAST(destroyed_quantity AS DOUBLE)) / NULLIF(SUM(CAST(batch_size AS DOUBLE)), 0), 2)
      comment: "Percentage of batch size that has been destroyed"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Availability Rate"
      display_name: "Availability Rate %"
      expr: ROUND(100.0 * SUM(CAST(available_quantity AS DOUBLE)) / NULLIF(SUM(CAST(batch_size AS DOUBLE)), 0), 2)
      comment: "Percentage of batch size that is available for use"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Shelf Life Months"
      display_name: "Avg Shelf Life Months"
      expr: AVG(CAST(shelf_life_months AS DOUBLE))
      comment: "Average shelf life in months across manufacturing batches"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Units Per Kit"
      display_name: "Avg Units Per Kit"
      expr: AVG(CAST(units_per_kit AS DOUBLE))
      comment: "Average units per kit across manufacturing batches"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`supply_plan`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Strategic supply planning KPIs: forecasted enrollment, buffer stock, overage, dropout rates, and manufacturing batch planning for investigational medicinal products across clinical trials."
  source: "`clinical_trials_mvm`.`supply`.`supply_plan`"
  dimensions:
    - name: "Supply Plan Number"
      display_name: "Supply Plan Number"
      expr: plan_number
      comment: "Unique identifier for the supply plan"
    - name: "Supply Plan Status"
      display_name: "Supply Plan Status"
      expr: supply_plan_status
      comment: "Current status of the supply plan (e.g., Draft, Approved, Active, Closed)"
    - name: "Blinding Type"
      display_name: "Blinding Type"
      expr: blinding_type
      comment: "Type of blinding applied to the supply (e.g., Open-label, Single-blind, Double-blind)"
    - name: "Geographic Scope"
      display_name: "Geographic Scope"
      expr: geographic_scope
      comment: "Geographic scope of the supply plan (e.g., Global, Regional, Country-specific)"
    - name: "Planning Cycle"
      display_name: "Planning Cycle"
      expr: planning_cycle
      comment: "Planning cycle frequency (e.g., Annual, Quarterly, Monthly)"
    - name: "Randomization Method"
      display_name: "Randomization Method"
      expr: randomization_method
      comment: "Randomization method used in the supply plan (e.g., Block, Stratified, Adaptive)"
    - name: "Cold Chain Required"
      display_name: "Cold Chain Required"
      expr: cold_chain_required
      comment: "Indicates whether cold chain logistics are required for this supply plan"
    - name: "Plan Year"
      display_name: "Plan Year"
      expr: DATE_TRUNC('year', plan_date)
      comment: "Year of the supply plan date"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Plan Quarter"
      display_name: "Plan Quarter"
      expr: DATE_TRUNC('quarter', plan_date)
      comment: "Quarter of the supply plan date"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Plan Month"
      display_name: "Plan Month"
      expr: DATE_TRUNC('month', plan_date)
      comment: "Month of the supply plan date"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Horizon Start Year"
      display_name: "Horizon Start Year"
      expr: DATE_TRUNC('year', horizon_start_date)
      comment: "Year of the planning horizon start date"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Supply Plan Count"
      display_name: "Supply Plan Count"
      expr: COUNT(1)
      comment: "Total number of supply plans"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Forecasted Enrollment"
      display_name: "Total Forecasted Enrollment"
      expr: SUM(CAST(forecasted_enrollment AS DOUBLE))
      comment: "Sum of forecasted patient enrollment across all supply plans"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Forecasted Enrollment"
      display_name: "Avg Forecasted Enrollment"
      expr: AVG(CAST(forecasted_enrollment AS DOUBLE))
      comment: "Average forecasted patient enrollment per supply plan"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Planned Units"
      display_name: "Total Planned Units"
      expr: SUM(CAST(total_units_planned AS DOUBLE))
      comment: "Sum of total units planned across all supply plans"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Planned Units Per Plan"
      display_name: "Avg Planned Units Per Plan"
      expr: AVG(CAST(total_units_planned AS DOUBLE))
      comment: "Average total units planned per supply plan"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Planned Manufacturing Batches"
      display_name: "Total Planned Manufacturing Batches"
      expr: SUM(CAST(planned_manufacturing_batches AS DOUBLE))
      comment: "Sum of planned manufacturing batches across all supply plans"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Dropout Rate Pct"
      display_name: "Avg Dropout Rate %"
      expr: AVG(CAST(dropout_rate_pct AS DOUBLE))
      comment: "Average dropout rate percentage across supply plans"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Overage Pct"
      display_name: "Avg Overage %"
      expr: AVG(CAST(overage_pct AS DOUBLE))
      comment: "Average overage percentage (buffer stock above forecasted need) across supply plans"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Buffer Stock Weeks"
      display_name: "Avg Buffer Stock Weeks"
      expr: AVG(CAST(buffer_stock_weeks AS DOUBLE))
      comment: "Average buffer stock duration in weeks across supply plans"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Shelf Life Months"
      display_name: "Avg Shelf Life Months"
      expr: AVG(CAST(shelf_life_months AS DOUBLE))
      comment: "Average shelf life in months for investigational products in supply plans"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Treatment Arms Count"
      display_name: "Avg Treatment Arms Count"
      expr: AVG(CAST(treatment_arms_count AS DOUBLE))
      comment: "Average number of treatment arms per supply plan"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Resupply Trigger Threshold"
      display_name: "Avg Resupply Trigger Threshold"
      expr: AVG(CAST(resupply_trigger_threshold AS DOUBLE))
      comment: "Average resupply trigger threshold (minimum stock level before reorder) across supply plans"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Resupply Quantity"
      display_name: "Avg Resupply Quantity"
      expr: AVG(CAST(resupply_quantity AS DOUBLE))
      comment: "Average resupply quantity per order across supply plans"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Cold Chain Required Pct"
      display_name: "Cold Chain Required %"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN cold_chain_required = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of supply plans requiring cold chain logistics"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Destruction Plan Included Pct"
      display_name: "Destruction Plan Included %"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN destruction_plan_included = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of supply plans that include a destruction plan for expired or unused product"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`supply_resupply_order`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Site resupply order and fulfillment KPIs for trial supply chain responsiveness and efficiency"
  source: "`clinical_trials_mvm`.`supply`.`resupply_order`"
  dimensions:
    - name: "Order Status"
      display_name: "Order Status"
      expr: order_status
      comment: "Current status of the resupply order (pending, approved, shipped, delivered, cancelled)"
    - name: "Trigger Type"
      display_name: "Trigger Type"
      expr: trigger_type
      comment: "Type of trigger that initiated the order (automatic, manual, emergency)"
    - name: "Urgency Level"
      display_name: "Urgency Level"
      expr: urgency_level
      comment: "Urgency level of the resupply order (routine, urgent, emergency)"
    - name: "Blinding Level"
      display_name: "Blinding Level"
      expr: blinding_level
      comment: "Blinding level for the resupply (single, double, open-label)"
    - name: "Cold Chain Required"
      display_name: "Cold Chain Required"
      expr: CASE WHEN cold_chain_required THEN 'Yes' ELSE 'No' END
      comment: "Whether cold chain is required for this resupply"
    - name: "Emergency Override"
      display_name: "Emergency Override"
      expr: CASE WHEN is_emergency_override THEN 'Yes' ELSE 'No' END
      comment: "Whether this is an emergency override order"
    - name: "Accountability Reconciled"
      display_name: "Accountability Reconciled"
      expr: CASE WHEN accountability_reconciled THEN 'Yes' ELSE 'No' END
      comment: "Whether accountability has been reconciled for this order"
    - name: "Order Year"
      display_name: "Order Year"
      expr: DATE_TRUNC('year', CAST(order_date AS DATE))
      comment: "Year when order was placed"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Order Quarter"
      display_name: "Order Quarter"
      expr: DATE_TRUNC('quarter', CAST(order_date AS DATE))
      comment: "Quarter when order was placed"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Order Month"
      display_name: "Order Month"
      expr: DATE_TRUNC('month', CAST(order_date AS DATE))
      comment: "Month when order was placed"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Resupply Orders"
      display_name: "Total Resupply Orders"
      expr: COUNT(1)
      comment: "Total number of resupply orders"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Qty Requested"
      display_name: "Total Qty Requested"
      expr: SUM(CAST(quantity_requested AS DOUBLE))
      comment: "Total quantity requested across all resupply orders"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Qty Approved"
      display_name: "Total Qty Approved"
      expr: SUM(CAST(quantity_approved AS DOUBLE))
      comment: "Total quantity approved for resupply"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Qty Shipped"
      display_name: "Total Qty Shipped"
      expr: SUM(CAST(quantity_shipped AS DOUBLE))
      comment: "Total quantity actually shipped"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Approval Rate"
      display_name: "Approval Rate"
      expr: ROUND(100.0 * SUM(CAST(quantity_approved AS DOUBLE)) / NULLIF(SUM(CAST(quantity_requested AS DOUBLE)), 0), 2)
      comment: "Percentage of requested quantity that was approved (demand fulfillment KPI)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Fulfillment Rate"
      display_name: "Fulfillment Rate"
      expr: ROUND(100.0 * SUM(CAST(quantity_shipped AS DOUBLE)) / NULLIF(SUM(CAST(quantity_approved AS DOUBLE)), 0), 2)
      comment: "Percentage of approved quantity that was shipped (supply chain efficiency KPI)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Emergency Order Rate"
      display_name: "Emergency Order Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN is_emergency_override THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of orders that are emergency overrides (planning effectiveness indicator)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Fulfillment Lead Time Days"
      display_name: "Avg Fulfillment Lead Time (days)"
      expr: AVG(CAST(DATEDIFF(actual_delivery_date, order_date) AS DOUBLE))
      comment: "Average number of days from order to delivery (supply chain responsiveness KPI)"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Approval Lead Time Days"
      display_name: "Avg Approval Lead Time (days)"
      expr: AVG(CAST(DATEDIFF(approval_date, order_date) AS DOUBLE))
      comment: "Average number of days from order to approval"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "On-Time Fulfillment Rate"
      display_name: "On-Time Fulfillment Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN actual_delivery_date <= expected_fulfillment_date THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(CASE WHEN actual_delivery_date IS NOT NULL THEN 1 END), 0), 2)
      comment: "Percentage of orders fulfilled on or before expected date (service level KPI)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Cancellation Rate"
      display_name: "Cancellation Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN order_status = 'Cancelled' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of resupply orders that were cancelled"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Accountability Reconciled Rate"
      display_name: "Accountability Reconciled Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN accountability_reconciled THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of resupply orders with completed accountability reconciliation"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Stock At Trigger"
      display_name: "Avg Stock At Trigger"
      expr: AVG(CAST(stock_at_trigger AS DOUBLE))
      comment: "Average stock level when resupply was triggered (reorder point optimization KPI)"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`supply_shipment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Shipment logistics and cold-chain compliance KPIs for investigational medicinal product distribution"
  source: "`clinical_trials_mvm`.`supply`.`shipment`"
  dimensions:
    - name: "Shipment Status"
      display_name: "Shipment Status"
      expr: shipment_status
      comment: "Current status of the shipment (in-transit, delivered, quarantined, etc.)"
    - name: "Shipment Type"
      display_name: "Shipment Type"
      expr: shipment_type
      comment: "Type of shipment (initial supply, resupply, return, emergency)"
    - name: "Direction"
      display_name: "Direction"
      expr: direction
      comment: "Shipment direction (inbound, outbound, inter-depot)"
    - name: "Destination Node Type"
      display_name: "Destination Node Type"
      expr: destination_node_type
      comment: "Type of destination (site, depot, sponsor, vendor)"
    - name: "Origin Node Type"
      display_name: "Origin Node Type"
      expr: origin_node_type
      comment: "Type of origin (site, depot, sponsor, vendor)"
    - name: "Cold Chain Required"
      display_name: "Customs Clearance Required"
      expr: CASE WHEN customs_clearance_required THEN 'Yes' ELSE 'No' END
      comment: "Whether customs clearance is required for this shipment"
    - name: "Temperature Excursion Flag"
      display_name: "Temperature Excursion"
      expr: CASE WHEN temperature_excursion_flag THEN 'Excursion' ELSE 'Compliant' END
      comment: "Whether a temperature excursion was detected during shipment"
    - name: "Dispatch Year"
      display_name: "Dispatch Year"
      expr: DATE_TRUNC('year', dispatch_date)
      comment: "Year of shipment dispatch"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Dispatch Quarter"
      display_name: "Dispatch Quarter"
      expr: DATE_TRUNC('quarter', dispatch_date)
      comment: "Quarter of shipment dispatch"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Dispatch Month"
      display_name: "Dispatch Month"
      expr: DATE_TRUNC('month', dispatch_date)
      comment: "Month of shipment dispatch"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Delivery Year"
      display_name: "Delivery Year"
      expr: DATE_TRUNC('year', actual_delivery_date)
      comment: "Year of actual delivery"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Delivery Month"
      display_name: "Delivery Month"
      expr: DATE_TRUNC('month', actual_delivery_date)
      comment: "Month of actual delivery"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Shipments"
      display_name: "Total Shipments"
      expr: COUNT(1)
      comment: "Total number of shipments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Kits Shipped"
      display_name: "Total Kits Shipped"
      expr: SUM(CAST(kit_count AS DOUBLE))
      comment: "Total number of IMP kits shipped across all shipments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Kits Per Shipment"
      display_name: "Avg Kits Per Shipment"
      expr: AVG(CAST(kit_count AS DOUBLE))
      comment: "Average number of kits per shipment"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Temperature Excursion Rate"
      display_name: "Temperature Excursion Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN temperature_excursion_flag THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of shipments with temperature excursions (critical cold-chain compliance KPI)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Quarantine Rate"
      display_name: "Quarantine Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN quarantine_flag THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of shipments placed in quarantine upon receipt"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Transit Days"
      display_name: "Avg Transit Days"
      expr: AVG(CAST(DATEDIFF(actual_delivery_date, dispatch_date) AS DOUBLE))
      comment: "Average number of days from dispatch to actual delivery"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "On-Time Delivery Rate"
      display_name: "On-Time Delivery Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN actual_delivery_date <= expected_delivery_date THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(CASE WHEN actual_delivery_date IS NOT NULL THEN 1 END), 0), 2)
      comment: "Percentage of shipments delivered on or before expected delivery date"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Excursion Duration Minutes"
      display_name: "Avg Excursion Duration (min)"
      expr: AVG(CAST(excursion_duration_minutes AS DOUBLE))
      comment: "Average duration of temperature excursions in minutes (for shipments with excursions)"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Customs Clearance Required Pct"
      display_name: "Customs Clearance Required %"
      expr: ROUND(100.0 * SUM(CASE WHEN customs_clearance_required THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of shipments requiring customs clearance"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`supply_shipment_performance`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Shipment timeliness and delay KPIs for clinical trial supplies"
  source: "`clinical_trials_mvm`.`supply`.`shipment`"
  dimensions:
    - name: "origin_depot_id"
      display_name: "Origin Depot Id"
      expr: origin_depot_id
      comment: "Depot from which the shipment originated"
    - name: "destination_node_type"
      display_name: "Destination Node Type"
      expr: destination_node_type
      comment: "Type of destination node (e.g., site, warehouse)"
    - name: "carrier_name"
      display_name: "Carrier Name"
      expr: carrier_name
      comment: "Name of the carrier handling the shipment"
    - name: "dispatch_year"
      display_name: "Dispatch Year"
      expr: DATE_TRUNC('year', dispatch_date)
      comment: "Year of shipment dispatch"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "dispatch_month"
      display_name: "Dispatch Month"
      expr: DATE_TRUNC('month', dispatch_date)
      comment: "Month of shipment dispatch"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_shipments"
      display_name: "Total Shipments"
      expr: COUNT(1)
      comment: "Total number of shipments dispatched"
      format:
        type: number
        decimal_places:
          type: all
    - name: "on_time_deliveries"
      display_name: "On‑Time Deliveries"
      expr: SUM(CASE WHEN actual_delivery_date <= expected_delivery_date THEN 1 ELSE 0 END)
      comment: "Count of shipments delivered on or before the expected date"
      format:
        type: number
        decimal_places:
          type: all
    - name: "delayed_shipments"
      display_name: "Delayed Shipments"
      expr: SUM(CASE WHEN actual_delivery_date > expected_delivery_date THEN 1 ELSE 0 END)
      comment: "Count of shipments delivered after the expected date"
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_delay_days"
      display_name: "Total Delay Days"
      expr: SUM(CAST(DATEDIFF(day, expected_delivery_date, actual_delivery_date) AS DOUBLE))
      comment: "Sum of days delayed across all shipments (positive values indicate lateness)"
      format:
        type: number
        decimal_places:
          type: all
    - name: "on_time_rate"
      display_name: "On‑Time Delivery Rate"
      expr: (AGG(`on_time_deliveries`) / NULLIF(AGG(`total_shipments`), 0))
      comment: "Proportion of shipments delivered on time"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "average_delay_days"
      display_name: "Average Delay (Days)"
      expr: (AGG(`total_delay_days`) / NULLIF(AGG(`total_shipments`), 0))
      comment: "Average number of days shipments are delayed"
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`supply_site_inventory`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Site-level IMP inventory and resupply trigger KPIs for trial site supply management"
  source: "`clinical_trials_mvm`.`supply`.`site_inventory`"
  dimensions:
    - name: "Inventory Status"
      display_name: "Inventory Status"
      expr: inventory_status
      comment: "Current status of site inventory (active, depleted, expired)"
    - name: "Location Type"
      display_name: "Location Type"
      expr: location_type
      comment: "Type of storage location at site (pharmacy, investigator, central)"
    - name: "Blinding Level"
      display_name: "Blinding Level"
      expr: blinding_level
      comment: "Level of blinding for this inventory (single, double, open-label)"
    - name: "Storage Condition Compliant"
      display_name: "Storage Condition Compliance"
      expr: CASE WHEN storage_condition_compliant THEN 'Compliant' ELSE 'Non-Compliant' END
      comment: "Whether storage conditions are compliant with protocol requirements"
    - name: "Resupply Triggered"
      display_name: "Resupply Triggered"
      expr: CASE WHEN resupply_triggered THEN 'Triggered' ELSE 'Not Triggered' END
      comment: "Whether a resupply order has been triggered for this inventory"
    - name: "Destruction Authorized"
      display_name: "Destruction Authorized"
      expr: CASE WHEN destruction_authorized THEN 'Authorized' ELSE 'Not Authorized' END
      comment: "Whether destruction of expired/returned inventory is authorized"
    - name: "Last Shipment Year"
      display_name: "Last Shipment Year"
      expr: DATE_TRUNC('year', last_shipment_date)
      comment: "Year of last shipment to site"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Last Shipment Month"
      display_name: "Last Shipment Month"
      expr: DATE_TRUNC('month', last_shipment_date)
      comment: "Month of last shipment to site"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Expiry Year"
      display_name: "Expiry Year"
      expr: DATE_TRUNC('year', expiry_date)
      comment: "Year of inventory expiry"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Expiry Month"
      display_name: "Expiry Month"
      expr: DATE_TRUNC('month', expiry_date)
      comment: "Month of inventory expiry"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Site Inventory Records"
      display_name: "Total Site Inventory Records"
      expr: COUNT(1)
      comment: "Total number of site inventory records"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Qty On Hand"
      display_name: "Total Qty On Hand"
      expr: SUM(CAST(qty_on_hand AS DOUBLE))
      comment: "Total quantity of IMP currently on hand at sites (closing balance)"
      format:
        type: number
        decimal_places:
          type: all
      window:
        - order: Last Shipment Month
          range: current
          semiadditive: last
    - name: "Total Qty Received"
      display_name: "Total Qty Received"
      expr: SUM(CAST(qty_received AS DOUBLE))
      comment: "Total quantity received by sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Qty Dispensed"
      display_name: "Total Qty Dispensed"
      expr: SUM(CAST(qty_dispensed AS DOUBLE))
      comment: "Total quantity dispensed to subjects at sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Qty Returned"
      display_name: "Total Qty Returned"
      expr: SUM(CAST(qty_returned AS DOUBLE))
      comment: "Total quantity returned by subjects to sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Qty Expired"
      display_name: "Total Qty Expired"
      expr: SUM(CAST(qty_expired AS DOUBLE))
      comment: "Total quantity expired at sites (waste KPI)"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Qty Destroyed"
      display_name: "Total Qty Destroyed"
      expr: SUM(CAST(qty_destroyed AS DOUBLE))
      comment: "Total quantity destroyed at sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Qty Quarantined"
      display_name: "Total Qty Quarantined"
      expr: SUM(CAST(qty_quarantined AS DOUBLE))
      comment: "Total quantity in quarantine at sites"
      format:
        type: number
        decimal_places:
          type: all
      window:
        - order: Last Shipment Month
          range: current
          semiadditive: last
    - name: "Total Qty Allocated"
      display_name: "Total Qty Allocated"
      expr: SUM(CAST(qty_allocated AS DOUBLE))
      comment: "Total quantity allocated to subjects at sites"
      format:
        type: number
        decimal_places:
          type: all
      window:
        - order: Last Shipment Month
          range: current
          semiadditive: last
    - name: "Total Qty Adjusted"
      display_name: "Total Qty Adjusted"
      expr: SUM(CAST(qty_adjusted AS DOUBLE))
      comment: "Total quantity adjusted (reconciliation adjustments)"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Dispensing Rate"
      display_name: "Dispensing Rate"
      expr: ROUND(100.0 * SUM(CAST(qty_dispensed AS DOUBLE)) / NULLIF(SUM(CAST(qty_received AS DOUBLE)), 0), 2)
      comment: "Percentage of received inventory that has been dispensed (utilization KPI)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Expiry Rate"
      display_name: "Expiry Rate"
      expr: ROUND(100.0 * SUM(CAST(qty_expired AS DOUBLE)) / NULLIF(SUM(CAST(qty_received AS DOUBLE)), 0), 2)
      comment: "Percentage of received inventory that expired at sites (critical waste and cost KPI)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Return Rate"
      display_name: "Return Rate"
      expr: ROUND(100.0 * SUM(CAST(qty_returned AS DOUBLE)) / NULLIF(SUM(CAST(qty_dispensed AS DOUBLE)), 0), 2)
      comment: "Percentage of dispensed inventory that was returned (inverse compliance indicator)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Resupply Trigger Rate"
      display_name: "Resupply Trigger Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN resupply_triggered THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of site inventory records that have triggered resupply (demand signal)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Storage Compliance Rate"
      display_name: "Storage Compliance Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN storage_condition_compliant THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of site inventory with compliant storage conditions (GCP compliance KPI)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Accountability Reconciled Rate"
      display_name: "Accountability Reconciled Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN accountability_reconciled THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of site inventory with completed accountability reconciliation"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Temperature Excursion Count"
      display_name: "Avg Temperature Excursion Count"
      expr: AVG(CAST(temperature_excursion_count AS DOUBLE))
      comment: "Average number of temperature excursions per site inventory record"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Sites Below Minimum Stock"
      display_name: "Sites Below Minimum Stock"
      expr: SUM(CAST(CASE WHEN qty_on_hand < minimum_stock_qty THEN 1 ELSE 0 END AS INT))
      comment: "Number of site inventory records below minimum stock threshold (stockout risk KPI)"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`supply_temperature_excursion`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Cold-chain temperature excursion and impact assessment KPIs for product quality and regulatory compliance"
  source: "`clinical_trials_mvm`.`supply`.`temperature_excursion`"
  dimensions:
    - name: "Excursion Status"
      display_name: "Excursion Status"
      expr: excursion_status
      comment: "Current status of the excursion (open, under investigation, closed)"
    - name: "Excursion Type"
      display_name: "Excursion Type"
      expr: excursion_type
      comment: "Type of excursion (high temperature, low temperature, duration)"
    - name: "Detection Source"
      display_name: "Detection Source"
      expr: detection_source
      comment: "Source that detected the excursion (data logger, manual inspection, courier report)"
    - name: "Location Type"
      display_name: "Location Type"
      expr: location_type
      comment: "Type of location where excursion occurred (depot, site, in-transit)"
    - name: "Root Cause Category"
      display_name: "Root Cause Category"
      expr: root_cause_category
      comment: "Category of root cause (equipment failure, human error, environmental)"
    - name: "Disposition Decision"
      display_name: "Disposition Decision"
      expr: disposition_decision
      comment: "Final disposition decision (use as is, quarantine, destroy)"
    - name: "Impact Assessment Outcome"
      display_name: "Impact Assessment Outcome"
      expr: impact_assessment_outcome
      comment: "Outcome of impact assessment (no impact, minor impact, major impact)"
    - name: "CAPA Required"
      display_name: "CAPA Required"
      expr: CASE WHEN capa_required THEN 'Yes' ELSE 'No' END
      comment: "Whether corrective and preventive action is required"
    - name: "Sponsor Notification Required"
      display_name: "Sponsor Notification Required"
      expr: CASE WHEN sponsor_notification_required THEN 'Yes' ELSE 'No' END
      comment: "Whether sponsor notification is required"
    - name: "Replacement Kits Required"
      display_name: "Replacement Kits Required"
      expr: CASE WHEN replacement_kits_required THEN 'Yes' ELSE 'No' END
      comment: "Whether replacement kits are required"
    - name: "Excursion Start Year"
      display_name: "Excursion Start Year"
      expr: DATE_TRUNC('year', CAST(excursion_start_timestamp AS DATE))
      comment: "Year when excursion started"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Excursion Start Quarter"
      display_name: "Excursion Start Quarter"
      expr: DATE_TRUNC('quarter', CAST(excursion_start_timestamp AS DATE))
      comment: "Quarter when excursion started"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Excursion Start Month"
      display_name: "Excursion Start Month"
      expr: DATE_TRUNC('month', CAST(excursion_start_timestamp AS DATE))
      comment: "Month when excursion started"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Excursions"
      display_name: "Total Excursions"
      expr: COUNT(1)
      comment: "Total number of temperature excursion events (critical cold-chain quality KPI)"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Affected Kits"
      display_name: "Total Affected Kits"
      expr: SUM(CAST(affected_kit_count AS DOUBLE))
      comment: "Total number of IMP kits affected by temperature excursions (financial impact indicator)"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Excursion Duration Minutes"
      display_name: "Avg Excursion Duration (min)"
      expr: AVG(CAST(duration_minutes AS DOUBLE))
      comment: "Average duration of temperature excursions in minutes"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Max Temp Recorded C"
      display_name: "Avg Max Temp Recorded (°C)"
      expr: AVG(CAST(max_temp_recorded_c AS DOUBLE))
      comment: "Average maximum temperature recorded during excursions"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Min Temp Recorded C"
      display_name: "Avg Min Temp Recorded (°C)"
      expr: AVG(CAST(min_temp_recorded_c AS DOUBLE))
      comment: "Average minimum temperature recorded during excursions"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Mean Kinetic Temp C"
      display_name: "Avg Mean Kinetic Temp (°C)"
      expr: AVG(CAST(mean_kinetic_temp_c AS DOUBLE))
      comment: "Average mean kinetic temperature during excursions (stability impact indicator)"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "CAPA Required Rate"
      display_name: "CAPA Required Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN capa_required THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of excursions requiring corrective and preventive action (severity indicator)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Sponsor Notification Rate"
      display_name: "Sponsor Notification Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN sponsor_notification_required THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of excursions requiring sponsor notification (escalation indicator)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Replacement Required Rate"
      display_name: "Replacement Required Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN replacement_kits_required THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of excursions requiring replacement kits (financial impact KPI)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Destroy Disposition Rate"
      display_name: "Destroy Disposition Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN disposition_decision = 'Destroy' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of excursions resulting in product destruction (waste and cost KPI)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Use As Is Rate"
      display_name: "Use As Is Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN disposition_decision = 'Use As Is' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of excursions where product was approved for use (quality assurance KPI)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Major Impact Rate"
      display_name: "Major Impact Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN impact_assessment_outcome = 'Major Impact' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of excursions with major impact assessment outcome (risk indicator)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Stability Data Reviewed Rate"
      display_name: "Stability Data Reviewed Rate"
      expr: ROUND(100.0 * SUM(CASE WHEN stability_data_reviewed THEN 1 ELSE 0 END) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of excursions where stability data was reviewed (quality process compliance)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Kits Per Excursion"
      display_name: "Avg Kits Per Excursion"
      expr: AVG(CAST(affected_kit_count AS DOUBLE))
      comment: "Average number of kits affected per excursion event"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;
