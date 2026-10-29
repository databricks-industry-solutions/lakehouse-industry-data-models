#!/usr/bin/env bash
# Shared in-flight-runs guard for any (re-)deploy of the App container.
#
# Atomic-replace container swap (Databricks Apps) cannot hand off the
# previous container's in-memory poll tasks. Refuse to deploy a new
# image while a run is active so progress isn't lost. There is no
# override: the admin waits for the run or cancels it on its run page.
#
# When the guard cannot tell whether runs are in flight (the app list can't
# be read, the App has no URL yet, its health can't be read, or python or jq
# is missing), it prints a WARNING with the reason and asks for confirmation
# (y/N, default No). ASSUME_YES=1 (the callers' --yes) proceeds without
# asking; with no terminal to ask on and no ASSUME_YES it refuses. An App that
# does not exist yet (a first install) needs no confirmation: nothing can be
# in flight. The App's boot agent upgrade also skips while a run is active.
#
# Usage (from a deploy script):
#
#   PROFILE=<profile> APP=vibe-modeling ASSUME_YES=<1 or empty> \
#     bash "$REPO_ROOT/install/in_flight_guard.sh"
#
# Vars consumed:
#   APP        - Databricks App name (e.g. vibe-modeling)
#   PROFILE    - Databricks CLI profile (optional; omit for ambient/DEFAULT auth)
#   ASSUME_YES - "1": proceed without asking when the guard cannot tell
#
# Exit codes:
#   0 - safe to proceed: no App yet, no in-flight runs, or the guard could not
#       tell and the deploy was confirmed (answer y, or ASSUME_YES=1)
#   2 - in-flight runs present (ASSUME_YES does not change that), or the guard
#       could not tell and the deploy was not confirmed

set -euo pipefail

: "${APP:?in_flight_guard.sh: APP must be set}"
PROFILE="${PROFILE:-}"
ASSUME_YES="${ASSUME_YES:-}"
PROFILE_FLAGS=()
[[ -n "$PROFILE" ]] && PROFILE_FLAGS=(--profile "$PROFILE")

# The guard could not tell whether runs are in flight: warn with the reason,
# then proceed only when confirmed.
cannot_tell() {
  echo "    WARNING: could not identify a previous App '$APP' or its health to check for in-flight runs:" >&2
  echo "             $1" >&2
  if [[ "$ASSUME_YES" == "1" ]]; then
    echo "             Continuing (--yes)." >&2
    exit 0
  fi
  if [[ ! -t 0 ]]; then
    echo "ERROR: refusing to deploy without confirmation, and there is no terminal to ask on." >&2
    echo "       Re-run with --yes to deploy anyway (a run in flight would lose its progress)." >&2
    exit 2
  fi
  local answer=""
  printf '             Deploy anyway? A run in flight would lose its progress. [y/N] ' >&2
  read -r answer || answer=""
  case "$answer" in
    y|Y|yes|YES|Yes) echo "             Continuing (confirmed)." >&2; exit 0 ;;
    *) echo "ERROR: not confirmed; nothing was deployed." >&2; exit 2 ;;
  esac
}

if ! command -v jq >/dev/null 2>&1; then
  cannot_tell "jq is not installed."
fi

# Whether the App exists, from the shared helper (the app list's exit code and
# membership): 0 exists (the app's JSON on stdout), 3 absent, anything else unknown.
PYTHON="$(command -v python || command -v python3 || true)"
if [[ -z "$PYTHON" ]]; then
  cannot_tell "python is not installed, so the app list can't be read."
fi
EXISTS_RC=0
APP_JSON="$("$PYTHON" "$(dirname "$0")/_install_common.py" app-exists "$APP" ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} \
  2>&1)" || EXISTS_RC=$?
if [[ "$EXISTS_RC" == 3 ]]; then
  echo "    No App '$APP' yet (first install) - nothing can be in flight."
  exit 0
fi
if [[ "$EXISTS_RC" != 0 ]]; then
  cannot_tell "the app list could not be read: $(printf '%s' "${APP_JSON:-exit $EXISTS_RC}" | tr '\n' ' ' | cut -c1-300)"
fi

APP_HOST_FOR_GUARD="$(printf '%s' "$APP_JSON" | jq -r '.url // empty' 2>/dev/null \
  | sed -E 's#^[A-Za-z]+://##; s#[/:?].*$##' || true)"
if [[ -z "$APP_HOST_FOR_GUARD" ]]; then
  cannot_tell "App '$APP' has no URL yet."
fi

TOKEN="$(databricks auth token ${PROFILE_FLAGS[@]:+"${PROFILE_FLAGS[@]}"} --output json 2>/dev/null \
  | jq -r '.access_token // empty' 2>/dev/null || true)"
if [[ -z "$TOKEN" ]]; then
  cannot_tell "no token for profile ${PROFILE:-<ambient>}, so the App's health can't be read."
fi

HEALTH="$(curl -sS --max-time 8 \
  "https://$APP_HOST_FOR_GUARD/api/health" \
  -H "Authorization: Bearer $TOKEN" 2>/dev/null || true)"

# The count as an integer (numeric strings accepted), or nothing when unreadable.
COUNT_FILTER='if type == "object" then (.in_flight_runs | (if type == "string" then (try tonumber catch null) else (.) end) | (if type == "number" then floor else empty end)) else empty end'
IN_FLIGHT="$(printf '%s' "$HEALTH" | jq -r "$COUNT_FILTER" 2>/dev/null || true)"

if [[ ! "$IN_FLIGHT" =~ ^-?[0-9]+$ ]]; then
  cannot_tell "could not read in-flight runs from $APP_HOST_FOR_GUARD/api/health."
fi

if [[ "$IN_FLIGHT" -le 0 ]]; then
  echo "    OK - no in-flight runs on $APP_HOST_FOR_GUARD."
  exit 0
fi

echo "ERROR: refusing to deploy: $IN_FLIGHT in-flight run(s) on $APP_HOST_FOR_GUARD." >&2
echo "       Wait for the run to finish, or cancel it on its run page (stale runs too), then re-run the installer." >&2
exit 2
