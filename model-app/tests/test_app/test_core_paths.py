"""Tests for core/_paths.py — Volume path builders."""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import pytest

from vibe_modeling.backend.core._paths import (
    file_in_folder,
    metamodel_root_for_business,
    model_json_volume_candidates,
    model_json_volume_path,
    version_dir_candidates,
    version_dir_in_volume,
)


class TestModelJsonVolumePath:
    """The canonical builder is NESTED (agent 4.9.8+): v{N}/{scope}/model.json."""

    def test_ecm_layout(self):
        path = model_json_volume_path("dep_cat", "Acme Retail", 3, "ecm")
        assert path == (
            "/Volumes/dep_cat/_metamodel/vol_root/business/"
            "acme_retail/v3/ecm/model.json"
        )

    def test_mvm_layout(self):
        path = model_json_volume_path("dep_cat", "Acme Retail", 1, "mvm")
        assert path == (
            "/Volumes/dep_cat/_metamodel/vol_root/business/"
            "acme_retail/v1/mvm/model.json"
        )

    def test_business_name_sanitized(self):
        # Spaces, mixed case, punctuation -> safe catalog segment.
        path = model_json_volume_path("dep_cat", "ACME!! Retail Co.", 2, "ecm")
        assert "/business/acme_retail_co/v2/ecm/model.json" in path
        # Confirm no spaces/punctuation leaked into the folder segment.
        assert " " not in path
        assert "!" not in path

    def test_invalid_scope_raises(self):
        with pytest.raises(ValueError, match="scope must be"):
            model_json_volume_path("dep_cat", "Acme", 1, "bogus")

    def test_empty_scope_raises(self):
        with pytest.raises(ValueError):
            model_json_volume_path("dep_cat", "Acme", 1, "")

    def test_uppercase_scope_normalised(self):
        path = model_json_volume_path("dep_cat", "Acme", 1, "ECM")
        assert path.endswith("/v1/ecm/model.json")

    def test_space_and_caps_business_name(self):
        # Documents the space+caps -> "terranova_copy" mapping. NOT the
        # regression guard: the old sanitize_catalog_segment produced the same
        # value for this input. The real guards are test_digit_prefixed_*
        # (which pin the agent_business_segment normalizer choice) and the
        # TestVolumePathCasing cases in test_model_sync.py (which assert the
        # loaders probe the sanitized folder, never the raw business_name).
        path = model_json_volume_path("dep_cat", "Terranova Copy", 2, "ecm")
        assert path == (
            "/Volumes/dep_cat/_metamodel/vol_root/business/"
            "terranova_copy/v2/ecm/model.json"
        )

    def test_digit_prefixed_business_name(self):
        # agent_business_segment prepends "_" for digit-leading names (legal UC
        # identifier); the path must match the agent's on-disk folder.
        path = model_json_volume_path("dep_cat", "7-Eleven", 1, "ecm")
        assert "/business/_7_eleven/v1/ecm/model.json" in path


class TestVolumeReadCandidates:
    """Reader helpers: nested probed FIRST, legacy flat as fallback."""

    def test_version_dir_candidates_order(self):
        cands = version_dir_candidates("dep_cat", "Acme Retail", 3, "ecm")
        assert cands == [
            "/Volumes/dep_cat/_metamodel/vol_root/business/acme_retail/v3/ecm",
            "/Volumes/dep_cat/_metamodel/vol_root/business/acme_retail/ecm_v3",
        ]
        # Nested is first; flat is the fallback.
        assert cands[0].endswith("/v3/ecm")
        assert cands[1].endswith("/ecm_v3")

    def test_model_json_candidates_order(self):
        cands = model_json_volume_candidates("dep_cat", "Acme", 1, "mvm")
        assert cands == [
            "/Volumes/dep_cat/_metamodel/vol_root/business/acme/v1/mvm/model.json",
            "/Volumes/dep_cat/_metamodel/vol_root/business/acme/mvm_v1/model.json",
        ]

    def test_candidates_first_matches_canonical_builder(self):
        # The nested-primary candidate must equal the write-path builder so a
        # freshly-written model.json is always the first probe.
        assert (
            version_dir_candidates("c", "Biz", 2, "ecm")[0]
            == version_dir_in_volume("c", "Biz", 2, "ecm")
        )
        assert (
            model_json_volume_candidates("c", "Biz", 2, "ecm")[0]
            == model_json_volume_path("c", "Biz", 2, "ecm")
        )

    def test_candidates_invalid_scope_raises(self):
        with pytest.raises(ValueError):
            version_dir_candidates("dep_cat", "Acme", 1, "bogus")


class TestMetamodelRootForBusiness:
    def test_layout(self):
        root = metamodel_root_for_business("dep_cat", "Acme Retail")
        assert root == "/Volumes/dep_cat/_metamodel/vol_root/business/acme_retail"

    def test_empty_segment_raises(self):
        # Non-[a-z0-9_] reduces to nothing -> agent_business_segment returns "".
        # A blank segment would compose a malformed /business//… path, so the
        # builder fails loud rather than emit it (hard failure > silent drift).
        with pytest.raises(ValueError, match="empty Volume segment"):
            metamodel_root_for_business("dep_cat", "***")

    def test_empty_business_name_raises(self):
        with pytest.raises(ValueError):
            metamodel_root_for_business("dep_cat", "")

    def test_digit_prefixed_name(self):
        root = metamodel_root_for_business("dep_cat", "7-Eleven")
        assert root.endswith("/business/_7_eleven")


class TestVersionDirInVolume:
    def test_layout(self):
        # Canonical builder is NESTED: v{N}/{scope}.
        d = version_dir_in_volume("dep_cat", "Acme", 4, "mvm")
        assert d == "/Volumes/dep_cat/_metamodel/vol_root/business/acme/v4/mvm"

    def test_invalid_scope(self):
        with pytest.raises(ValueError):
            version_dir_in_volume("dep_cat", "Acme", 4, "raw")


class TestFileInFolder:
    FOLDER = "/Volumes/dep_cat/_metamodel/vol_root/business/acme/v4/mvm"

    @pytest.mark.parametrize("path,expected", [
        (f"{FOLDER}/model.json", True),
        (f"{FOLDER}/other_name.json", True),
        ("/Volumes/DEP_CAT/_metamodel/vol_root/business/Acme/v4/MVM/model.json", True),
        (f"{FOLDER}/sub/model.json", False),
        ("/Volumes/dep_cat/_metamodel/vol_root/business/acme/v4/model.json", False),
        ("/Volumes/landing/raw/drop/model.json", False),
    ], ids=["model_json", "any_name", "case", "subfolder", "parent", "elsewhere"])
    def test_the_file_must_sit_directly_in_the_folder(self, path, expected):
        assert file_in_folder(path, self.FOLDER) is expected
        assert file_in_folder(path, f"{self.FOLDER}/") is expected
