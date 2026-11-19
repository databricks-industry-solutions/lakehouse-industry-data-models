#!/usr/bin/env python3
"""
Unit tests for standards_crosswalk.generate_crosswalks

Tests:
- Model loading and parsing
- Attribute extraction
- Crosswalk generation
- CSV output format and column stability
- Target validation with spec files
"""

import csv
import json
import tempfile
import unittest
from pathlib import Path

from generate_crosswalks import (
    extract_evidence,
    extract_model_attributes,
    generate_crosswalks,
    load_model,
    load_rules,
)


class TestGenerateCrosswalks(unittest.TestCase):
    """Test suite for crosswalk generation."""

    @classmethod
    def setUpClass(cls):
        """Set up test fixtures."""
        cls.fixture_dir = Path(__file__).parent / 'test_fixtures'
        cls.fixture_dir.mkdir(exist_ok=True)

        # Create a minimal test model
        cls.test_model = {
            'model': {
                'name': 'Test Clinical Trials',
                'version': 'v1_test',
                'domains': [
                    {
                        'name': 'safety',
                        'products': [
                            {
                                'name': 'adverse_event',
                                'attributes': [
                                    {
                                        'name': 'adverse_event_id',
                                        'type': 'BIGINT',
                                        'description': 'Primary key for AE',
                                        'references': 'SDTM AE domain',
                                    },
                                    {
                                        'name': 'meddra_pt_code',
                                        'type': 'STRING',
                                        'description': 'MedDRA Preferred Term code per SDTM AEPTCD',
                                        'references': 'CDISC SDTM',
                                    },
                                    {
                                        'name': 'onset_date',
                                        'type': 'DATE',
                                        'description': 'Adverse event start date',
                                        'references': '',
                                    },
                                ],
                            }
                        ],
                    },
                    {
                        'name': 'subject',
                        'products': [
                            {
                                'name': 'demographic',
                                'attributes': [
                                    {
                                        'name': 'age',
                                        'type': 'INT',
                                        'description': 'Age at baseline',
                                        'references': 'SDTM DM',
                                    },
                                    {
                                        'name': 'gender',
                                        'type': 'STRING',
                                        'description': 'Sex of subject',
                                        'references': '',
                                    },
                                ],
                            }
                        ],
                    },
                ],
            }
        }

        # Create a minimal test rules file
        cls.test_rules_content = """domain,product,attribute,standard,standard_version,target_entity,target_element,match_type,confidence,evidence,notes
safety,adverse_event,adverse_event_id,SDTM,3.4,AE,AESEQ,derived,high,model_attribute_name,Primary key test
safety,adverse_event,meddra_pt_code,SDTM,3.4,AE,AEPTCD,exact,high,model_attribute_explicit,MedDRA code
safety,adverse_event,onset_date,SDTM,3.4,AE,AESTDTC,exact,high,model_attribute_name,Start date
safety,adverse_event,meddra_pt_code,FHIR,R4,AdverseEvent,event.coding.code,derived,high,model_attribute_explicit,FHIR mapping
subject,demographic,age,SDTM,3.4,DM,AGE,exact,high,model_attribute_name,Age at baseline
subject,demographic,gender,SDTM,3.4,DM,SEX,exact,high,model_attribute_name,Sex
"""

    def test_load_model(self):
        """Test model loading."""
        with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
            json.dump(self.test_model, f)
            f.flush()

            model = load_model(f.name)
            self.assertIn('model', model)
            self.assertEqual(len(model['model']['domains']), 2)

            Path(f.name).unlink()

    def test_extract_attributes(self):
        """Test attribute extraction from model."""
        attrs = extract_model_attributes(self.test_model)

        self.assertEqual(len(attrs), 5)

        # Check structure
        for attr in attrs:
            self.assertIn('domain', attr)
            self.assertIn('product', attr)
            self.assertIn('attribute', attr)
            self.assertIn('type', attr)
            self.assertIn('description', attr)

        # Check specific attributes
        ae_id_attr = next(a for a in attrs if a['attribute'] == 'adverse_event_id')
        self.assertEqual(ae_id_attr['domain'], 'safety')
        self.assertEqual(ae_id_attr['product'], 'adverse_event')
        self.assertEqual(ae_id_attr['type'], 'BIGINT')

    def test_generate_crosswalks(self):
        """Test full crosswalk generation."""
        with tempfile.TemporaryDirectory() as tmpdir:
            # Write test model
            model_file = Path(tmpdir) / 'test_model.json'
            with open(model_file, 'w') as f:
                json.dump(self.test_model, f)

            # Write test rules
            rules_file = Path(tmpdir) / 'test_rules.csv'
            with open(rules_file, 'w') as f:
                f.write(self.test_rules_content)

            # Create empty cache dir (no spec validation for this test)
            cache_dir = Path(tmpdir) / 'cache'
            cache_dir.mkdir()

            # Generate crosswalks
            output_dir = Path(tmpdir) / 'output'
            standards_written, dropped = generate_crosswalks(
                str(model_file),
                str(rules_file),
                str(output_dir),
                str(cache_dir)
            )

            # Check output files
            self.assertIn('SDTM', standards_written)
            self.assertIn('FHIR', standards_written)

            sdtm_file, sdtm_count = standards_written['SDTM']
            self.assertEqual(sdtm_count, 5)  # 5 SDTM mappings (no spec validation)
            self.assertTrue(Path(sdtm_file).exists())

            fhir_file, fhir_count = standards_written['FHIR']
            self.assertEqual(fhir_count, 1)  # 1 FHIR mapping
            self.assertTrue(Path(fhir_file).exists())

    def test_crosswalk_csv_columns(self):
        """Test that output CSV has stable columns."""
        with tempfile.TemporaryDirectory() as tmpdir:
            # Write test model
            model_file = Path(tmpdir) / 'test_model.json'
            with open(model_file, 'w') as f:
                json.dump(self.test_model, f)

            # Write test rules
            rules_file = Path(tmpdir) / 'test_rules.csv'
            with open(rules_file, 'w') as f:
                f.write(self.test_rules_content)

            # Create empty cache dir
            cache_dir = Path(tmpdir) / 'cache'
            cache_dir.mkdir()

            # Generate crosswalks
            output_dir = Path(tmpdir) / 'output'
            generate_crosswalks(str(model_file), str(rules_file), str(output_dir), str(cache_dir))

            # Check CSV columns
            sdtm_file = output_dir / 'crosswalk_sdtm.csv'
            with open(sdtm_file) as f:
                reader = csv.DictReader(f)
                columns = reader.fieldnames

                expected_columns = [
                    'domain',
                    'product',
                    'attribute',
                    'standard',
                    'standard_version',
                    'target_entity',
                    'target_element',
                    'match_type',
                    'confidence',
                    'evidence',
                    'source_ref',
                ]

                self.assertEqual(list(columns), expected_columns)

                # Check that all rows have the same columns
                for row in reader:
                    for col in expected_columns:
                        self.assertIn(col, row)

    def test_no_empty_critical_fields(self):
        """Test that critical fields are not empty."""
        with tempfile.TemporaryDirectory() as tmpdir:
            # Write test model
            model_file = Path(tmpdir) / 'test_model.json'
            with open(model_file, 'w') as f:
                json.dump(self.test_model, f)

            # Write test rules
            rules_file = Path(tmpdir) / 'test_rules.csv'
            with open(rules_file, 'w') as f:
                f.write(self.test_rules_content)

            # Create empty cache dir
            cache_dir = Path(tmpdir) / 'cache'
            cache_dir.mkdir()

            # Generate crosswalks
            output_dir = Path(tmpdir) / 'output'
            generate_crosswalks(str(model_file), str(rules_file), str(output_dir), str(cache_dir))

            # Check SDTM file
            sdtm_file = output_dir / 'crosswalk_sdtm.csv'
            with open(sdtm_file) as f:
                reader = csv.DictReader(f)
                for row in reader:
                    # Critical fields should not be empty
                    self.assertTrue(row['domain'])
                    self.assertTrue(row['product'])
                    self.assertTrue(row['attribute'])
                    self.assertTrue(row['standard'])
                    self.assertTrue(row['target_entity'])
                    self.assertTrue(row['target_element'])

    def test_evidence_extraction(self):
        """Test evidence extraction from attributes."""
        attr = {
            'attribute': 'meddra_pt_code',
            'description': 'MedDRA Preferred Term code per SDTM specification',
            'domain': 'safety',
            'product': 'adverse_event',
            'type': 'STRING',
        }

        rule = {
            'evidence': 'model_attribute_explicit',
        }

        evidence = extract_evidence(attr, rule)
        self.assertIn('SDTM', evidence)

    def test_load_rules(self):
        """Test rules loading."""
        with tempfile.NamedTemporaryFile(mode='w', suffix='.csv', delete=False) as f:
            f.write(self.test_rules_content)
            f.flush()

            rules = load_rules(f.name)
            self.assertEqual(len(rules), 6)

            # Check structure
            for rule in rules:
                self.assertIn('domain', rule)
                self.assertIn('product', rule)
                self.assertIn('attribute', rule)
                self.assertIn('standard', rule)

            Path(f.name).unlink()


if __name__ == '__main__':
    unittest.main()
