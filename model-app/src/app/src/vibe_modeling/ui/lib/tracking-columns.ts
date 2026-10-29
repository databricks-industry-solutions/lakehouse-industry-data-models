/**
 * What the agent's Housekeeping Columns and History Tracking widgets add, in
 * the words the New Run form's tooltips and the run-parameters help page
 * share. Agent 5.3.3 `step_create_logical_schema` (nb 81426-81538): the four
 * housekeeping columns go on every product; the two history columns only on
 * MASTER data products (`'master' in data_type`, nb 81509).
 */

export const HOUSEKEEPING_COLUMNS = ["created_by", "creation_date", "changed_by", "change_date"] as const;
export const HISTORY_TRACKING_COLUMNS = ["valid_from", "valid_to"] as const;

export const HOUSEKEEPING_COLUMNS_HINT =
  `Yes adds ${HOUSEKEEPING_COLUMNS.join(", ")} columns to every product.`;

export const HISTORY_TRACKING_HINT =
  `Yes adds ${HISTORY_TRACKING_COLUMNS.join(" and ")} columns to every master data product.`;
