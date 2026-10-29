"""Drift-test foundation: a recording fake of the Unity Catalog side and a
consistency checker between Lakebase and that fake.

- :mod:`.fake_uc` - :class:`FakeUC`, the ``_metamodel`` registry rows, Volume
  files, schemas and volumes per catalog, plus a fake ``WorkspaceClient``.
- :mod:`.consistency` - :func:`assert_lakebase_metamodel_consistent`.
- :mod:`.fixtures` - the opt-in ``fake_uc`` pytest fixture. Import it into the
  test module that uses it; ``conftest.py`` and ``mock_ws`` are not changed.
"""
