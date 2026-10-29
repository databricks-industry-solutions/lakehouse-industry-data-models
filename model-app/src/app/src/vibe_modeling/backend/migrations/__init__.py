"""Boot-time schema migrations.

Re-exports the public surface (``reconcile_schema``, the lifecycle
constants, the error type) from :mod:`registry`, and registers each
``v_X_Y_Z.MIGRATION`` into the module-level ``MIGRATIONS`` list in
ascending order. Add a new migration by importing it here and appending
it to the list — reconcile depends on the order.
"""

from . import (
    v_0_1_0,
    v_0_2_0,
    v_0_3_0,
    v_0_4_0,
    v_0_5_0,
    v_0_6_0,
    v_0_6_1,
    v_0_6_2,
    v_0_6_3,
    v_0_6_4,
    v_0_6_6,
    v_0_7_0,
    v_0_7_1,
    v_0_7_3,
    v_0_8_0,
    v_0_9_0,
    v_0_9_0_1,
    v_0_9_0_2,
    v_0_9_0_3,
    v_0_9_0_4,
    v_0_9_1,
)
from .registry import (
    INSTALL_POLICY,
    MIGRATIONS,
    PRE_PROD_DESTRUCTIVE_RESET,
    LakebaseInstallError,
    Migration,
    reconcile_schema,
)

# Append in version order. reconcile_schema treats the last entry as the
# "latest known" version — re-order at your peril.
MIGRATIONS.append(v_0_1_0.MIGRATION)
MIGRATIONS.append(v_0_2_0.MIGRATION)
MIGRATIONS.append(v_0_3_0.MIGRATION)
MIGRATIONS.append(v_0_4_0.MIGRATION)
MIGRATIONS.append(v_0_5_0.MIGRATION)
MIGRATIONS.append(v_0_6_0.MIGRATION)
MIGRATIONS.append(v_0_6_1.MIGRATION)
MIGRATIONS.append(v_0_6_2.MIGRATION)
MIGRATIONS.append(v_0_6_3.MIGRATION)
MIGRATIONS.append(v_0_6_4.MIGRATION)
MIGRATIONS.append(v_0_6_6.MIGRATION)
MIGRATIONS.append(v_0_7_0.MIGRATION)
MIGRATIONS.append(v_0_7_1.MIGRATION)
MIGRATIONS.append(v_0_7_3.MIGRATION)
MIGRATIONS.append(v_0_8_0.MIGRATION)
MIGRATIONS.append(v_0_9_0.MIGRATION)
MIGRATIONS.append(v_0_9_0_1.MIGRATION)
MIGRATIONS.append(v_0_9_0_2.MIGRATION)
MIGRATIONS.append(v_0_9_0_3.MIGRATION)
MIGRATIONS.append(v_0_9_0_4.MIGRATION)
MIGRATIONS.append(v_0_9_1.MIGRATION)


__all__ = [
    "INSTALL_POLICY",
    "MIGRATIONS",
    "PRE_PROD_DESTRUCTIVE_RESET",
    "LakebaseInstallError",
    "Migration",
    "reconcile_schema",
]
