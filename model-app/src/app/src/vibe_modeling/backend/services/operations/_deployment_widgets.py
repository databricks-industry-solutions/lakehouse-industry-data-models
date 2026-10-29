"""Shared widget-value helpers for the Group B deployment primitives.

``install``, ``uninstall``, and ``generate_samples`` all wrap agent ops
that read the ``data_model_scopes`` widget to decide whether they're
operating on the Expanded Coverage Model or the Minimum Viable Model
(see ``../../../../../modelling_agent/docs/integration-guide.md``
§"Widget values to pass as base_parameters" — ``data_model_scopes`` is
a universal widget, not install-specific).

Before this module existed, ``install.py`` and ``generate_samples.py``
each carried an identical inline copy of :func:`scope_label`, and
``uninstall.py`` omitted the widget entirely — the agent's Model Scope
widget then fell back to its own default (MVM) regardless of which
scope was actually being uninstalled, dropping the wrong business's
schemas on a live fork (verified: an ECM uninstall dispatched without
``data_model_scopes`` wiped all 15 ``mvm_*`` schemas instead). Centralizing
here means any future Group B primitive gets the correct widget value
by construction instead of by remembering to copy the inline helper.

:data:`SCHEMA_PREFIX_PATTERN` and :data:`CATALOG_NAME_PATTERN` are the one
``schema_prefix`` and ``deployment_catalog`` widget rules every primitive's
params model validates against (generation and deployment alike).
"""

from __future__ import annotations

# A ``schema_prefix`` widget value: empty, or lowercase snake ending in ``_``.
SCHEMA_PREFIX_PATTERN = r"^[a-z][a-z0-9_]*_$|^$"

# A ``deployment_catalog`` widget value: a lowercase Unity Catalog name.
CATALOG_NAME_PATTERN = r"^[a-z][a-z0-9_]+$"


def scope_label(scope: str) -> str:
    """Long-form widget value the agent expects on ``data_model_scopes``."""
    return (
        "Expanded Coverage Model - ECM"
        if scope == "ecm"
        else "Minimum Viable Model - MVM"
    )
