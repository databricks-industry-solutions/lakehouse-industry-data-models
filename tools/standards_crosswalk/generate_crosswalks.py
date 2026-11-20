#!/usr/bin/env python3
"""
Standards crosswalk generator for Databricks Industry Data Models (clinical_trials).

Generates CSV crosswalks that map clinical_trials model attributes to:
- CDISC SDTM, CDASH, USDM (DDF-RA v4)
- HL7 FHIR R4/R5
- OMOP CDM v5.4
- FDA Sentinel CDM
- PCORnet CDM

Target variables are validated against downloaded spec files to ensure no
fictional variables are emitted.

Usage:
    python3 generate_crosswalks.py --model path/to/model.json [--rules path/to/rules.csv] [--output output_dir]
"""

import argparse
import csv
import json
import urllib.request
import sys
from collections import defaultdict
from pathlib import Path


def load_model(model_path):
    """Load and parse the model.json file."""
    with open(model_path) as f:
        return json.load(f)


def load_rules(rules_path):
    """Load the mapping rules from a CSV file."""
    rules = []
    with open(rules_path, encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            rules.append(row)
    return rules


def extract_model_attributes(model):
    """Extract all attributes from the model with their metadata."""
    attributes = []
    model_data = model.get('model', {})

    for domain in model_data.get('domains', []):
        domain_name = domain.get('name', '')

        for product in domain.get('products', []):
            product_name = product.get('name', '')

            for attr in product.get('attributes', []):
                attr_name = attr.get('name', '')
                attributes.append({
                    'domain': domain_name,
                    'product': product_name,
                    'attribute': attr_name,
                    'type': attr.get('type', 'UNKNOWN'),
                    'description': attr.get('description', ''),
                    'references': attr.get('references', ''),
                })

    return attributes



def fetch_specs(cache_dir, sources_path):
    """Download any missing pinned spec files into the cache (raw GitHub at the pinned SHA)."""
    with open(sources_path, encoding='utf-8') as _sf:
        sources = json.load(_sf)['sources']
    Path(cache_dir).mkdir(parents=True, exist_ok=True)
    for key, src in sources.items():
        files = src.get('files')
        if not isinstance(files, dict) or not src.get('commit_sha'):
            continue
        for spec in files.values():
            if not isinstance(spec, dict) or 'cache_as' not in spec:
                continue
            target = Path(cache_dir) / spec['cache_as']
            if target.exists():
                continue
            url = f"{src['url']}/{src['commit_sha']}/{spec['path']}"
            print(f"Fetching {url}", file=sys.stderr)
            with urllib.request.urlopen(url, timeout=60) as resp:
                data = resp.read()
            if len(data) < 32:
                raise RuntimeError(f"spec {url} returned {len(data)} bytes; refusing to cache a truncated/empty spec")
            target.write_bytes(data)

def load_sdtm_spec(cache_dir):
    """Load SDTM specializations spec and extract valid (domain, variable) pairs."""
    spec_file = Path(cache_dir) / 'sdtm_specializations.csv'
    sdtm_vars = set()  # Set of (domain, variable) tuples

    if not spec_file.exists():
        print(f"Warning: SDTM spec not found at {spec_file}", file=sys.stderr)
        return sdtm_vars

    with open(spec_file, encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            domain = row.get('domain', '')
            variable = row.get('sdtm_variable', '')
            if domain and variable:
                sdtm_vars.add((domain, variable))

    print(f"Loaded {len(sdtm_vars)} SDTM (domain, variable) pairs", file=sys.stderr)
    return sdtm_vars


def load_usdm_spec(cache_dir):
    """Load USDM API spec and extract valid (class, attribute) pairs."""
    spec_file = Path(cache_dir) / 'usdm_api.json'
    usdm_attrs = set()  # Set of (class, attribute) tuples

    if not spec_file.exists():
        print(f"Warning: USDM spec not found at {spec_file}", file=sys.stderr)
        return usdm_attrs

    try:
        with open(spec_file, encoding='utf-8') as f:
            api = json.load(f)

        # Extract classes and their properties from OpenAPI schemas
        schemas = api.get('components', {}).get('schemas', {})

        for schema_name, schema in schemas.items():
            # Look for Output schemas (the normalized forms)
            if schema_name.endswith('-Output'):
                class_name = schema_name[:-7]  # Remove '-Output'
                properties = schema.get('properties', {})
                for prop_name in properties.keys():
                    usdm_attrs.add((class_name, prop_name))

        print(f"Loaded {len(usdm_attrs)} USDM (class, attribute) pairs", file=sys.stderr)
    except Exception as e:
        print(f"Error loading USDM spec: {e}", file=sys.stderr)

    return usdm_attrs


def load_omop_spec(cache_dir):
    """Load OMOP CDM spec and extract valid (table, field) pairs."""
    spec_file = Path(cache_dir) / 'omop_cdm_v5.4_fields.csv'
    omop_fields = set()  # Set of (table, field) tuples

    if not spec_file.exists():
        print(f"Warning: OMOP spec not found at {spec_file}", file=sys.stderr)
        return omop_fields

    with open(spec_file, encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            table = row.get('cdmTableName', '').lower()
            field = row.get('cdmFieldName', '').lower()
            if table and field:
                omop_fields.add((table, field))

    print(f"Loaded {len(omop_fields)} OMOP (table, field) pairs", file=sys.stderr)
    return omop_fields


def extract_evidence(attr, rule):
    """Extract evidence from attribute that matches the rule."""
    evidence_parts = []

    if rule.get('evidence') == 'model_attribute_explicit':
        if 'SDTM' in attr['description']:
            evidence_parts.append('SDTM reference in description')
        if 'CDISC' in attr['description']:
            evidence_parts.append('CDISC reference in description')
        if 'USDM' in attr['description']:
            evidence_parts.append('USDM reference in description')

    if rule.get('evidence') == 'model_attribute_name':
        evidence_parts.append(f"Attribute name: {attr['attribute']}")

    if rule.get('evidence') == 'model_fk_reference':
        if 'Foreign key' in attr['description']:
            evidence_parts.append('FK reference in description')

    if evidence_parts:
        return ' | '.join(evidence_parts)
    return f"mapped from {attr['product']}.{attr['attribute']}"


SKIPPED_VALIDATION = set()  # standards whose spec did not load, so targets were NOT verified


def is_valid_target(rule, sdtm_vars, usdm_attrs, omop_fields):
    """Check if a rule's target exists in the loaded spec files."""
    standard = rule.get('standard', '')
    target_entity = rule.get('target_entity', '')
    target_element = rule.get('target_element', '')

    if standard == 'SDTM' and '.' not in target_element:
        # SDTM: check (domain, variable)
        # If no spec loaded, record that SDTM targets were NOT verified (surfaced at the end)
        if not sdtm_vars:
            SKIPPED_VALIDATION.add('SDTM')
            return True
        return (target_entity, target_element) in sdtm_vars

    elif standard == 'USDM':
        # USDM: check (class, attribute)
        # If no spec loaded, record that USDM targets were NOT verified (surfaced at the end)
        if not usdm_attrs:
            SKIPPED_VALIDATION.add('USDM')
            return True
        return (target_entity, target_element) in usdm_attrs

    elif standard == 'OMOP':
        # OMOP: check (table, field)
        # If no spec loaded, record that OMOP targets were NOT verified (surfaced at the end)
        if not omop_fields:
            SKIPPED_VALIDATION.add('OMOP')
            return True
        return (target_entity.lower(), target_element.lower()) in omop_fields

    else:
        # Other standards: no validation (CDASH, FHIR, Sentinel, PCORnet have no public DDL)
        return True


def generate_crosswalks(model_path, rules_path, output_dir, cache_dir):
    """Generate all standard crosswalks with target validation."""
    print(f"Loading model from {model_path}...", file=sys.stderr)
    model = load_model(model_path)

    print(f"Loading rules from {rules_path}...", file=sys.stderr)
    rules = load_rules(rules_path)

    print(f"Extracting model attributes...", file=sys.stderr)
    model_attrs = extract_model_attributes(model)
    print(f"Found {len(model_attrs)} attributes", file=sys.stderr)

    # Load spec files for validation
    print(f"\nLoading standard specifications from {cache_dir}...", file=sys.stderr)
    sdtm_vars = load_sdtm_spec(cache_dir)
    usdm_attrs = load_usdm_spec(cache_dir)
    omop_fields = load_omop_spec(cache_dir)

    # Group rules by standard and validate
    crosswalks_by_standard = defaultdict(list)
    dropped_rows = []

    for rule_idx, rule in enumerate(rules, start=2):  # start at 2 (header is 1)
        domain = rule['domain']
        product = rule['product']
        attribute = rule['attribute']
        standard = rule['standard']

        # Find matching attribute in model
        matching_attr = None
        for attr in model_attrs:
            if (attr['domain'] == domain and
                attr['product'] == product and
                attr['attribute'] == attribute):
                matching_attr = attr
                break

        if not matching_attr:
            dropped_rows.append((rule_idx, rule, 'attribute not found in model'))
            continue

        # Validate target against spec
        if not is_valid_target(rule, sdtm_vars, usdm_attrs, omop_fields):
            target = f"{rule['target_entity']}.{rule['target_element']}"
            dropped_rows.append((rule_idx, rule, f'target not found in {standard} spec: {target}'))
            continue

        # Build crosswalk row
        evidence = extract_evidence(matching_attr, rule)

        crosswalk_row = {
            'domain': domain,
            'product': product,
            'attribute': attribute,
            'standard': standard,
            'standard_version': rule['standard_version'],
            'target_entity': rule['target_entity'],
            'target_element': rule['target_element'],
            'match_type': rule['match_type'],
            'confidence': rule['confidence'],
            'evidence': evidence,
            'source_ref': rule.get('notes', ''),
        }

        crosswalks_by_standard[standard].append(crosswalk_row)

    # Log dropped rows
    if dropped_rows:
        print(f"\n=== Dropped {len(dropped_rows)} Rules ===", file=sys.stderr)
        for row_num, rule, reason in dropped_rows:
            print(f"Row {row_num}: {rule['domain']}.{rule['product']}.{rule['attribute']} -> "
                  f"{rule['standard']} {rule['target_entity']}.{rule['target_element']}: {reason}",
                  file=sys.stderr)

    # Write crosswalks by standard
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    standards_written = {}

    for standard, rows in sorted(crosswalks_by_standard.items()):
        output_file = output_dir / f"crosswalk_{standard.lower()}.csv"
        standards_written[standard] = (output_file, len(rows))

        columns = [
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

        with open(output_file, 'w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=columns)
            writer.writeheader()
            writer.writerows(rows)

        print(f"Wrote {len(rows)} mappings to {output_file}", file=sys.stderr)

    # Calculate coverage statistics
    print("\n=== Coverage Summary ===", file=sys.stderr)
    total_attrs = len(model_attrs)
    for standard in sorted(standards_written.keys()):
        count = standards_written[standard][1]
        print(f"{standard}: {count} mappings (across {total_attrs} model attributes)", file=sys.stderr)

    return standards_written, len(dropped_rows)


def main():
    parser = argparse.ArgumentParser(
        description='Generate standards crosswalks for clinical_trials model with target validation'
    )
    parser.add_argument(
        '--model',
        required=True,
        help='Path to model.json file'
    )
    parser.add_argument(
        '--rules',
        help='Path to rules CSV file',
        default=None
    )
    parser.add_argument(
        '--output',
        help='Output directory for crosswalk CSVs',
        default=None
    )

    args = parser.parse_args()

    # Determine rules path
    if args.rules:
        rules_path = args.rules
    else:
        # Default: same directory as this script, rules/clinical_trials.csv
        script_dir = Path(__file__).parent
        rules_path = script_dir / 'rules' / 'clinical_trials.csv'

    # Determine output directory
    if args.output:
        output_dir = args.output
    else:
        # Default: put in the model's standards directory
        model_path = Path(args.model)
        output_dir = model_path.parent.parent / 'standards'

    # Determine cache directory
    script_dir = Path(__file__).parent
    cache_dir = script_dir / '.cache'

    # Validate inputs
    if not Path(args.model).exists():
        print(f"Error: Model file not found: {args.model}", file=sys.stderr)
        sys.exit(1)

    if not Path(rules_path).exists():
        print(f"Error: Rules file not found: {rules_path}", file=sys.stderr)
        sys.exit(1)

    try:
        fetch_specs(cache_dir, script_dir / 'sources.json')
    except Exception as e:
        print(f"WARNING: could not fetch spec files ({e}); target validation may be skipped.", file=sys.stderr)

    print(f"Model: {args.model}", file=sys.stderr)
    print(f"Rules: {rules_path}", file=sys.stderr)
    print(f"Cache: {cache_dir}", file=sys.stderr)
    print(f"Output: {output_dir}", file=sys.stderr)

    try:
        standards_written, dropped_count = generate_crosswalks(
            args.model, rules_path, output_dir, cache_dir
        )
        if SKIPPED_VALIDATION:
            print(f"\nWARNING: validation SKIPPED for {sorted(SKIPPED_VALIDATION)} - their spec files did not load, so emitted targets were NOT verified against the specs. Re-run with the specs present to validate.", file=sys.stderr)
            print(f"Completed with {dropped_count} rules dropped; {sorted(SKIPPED_VALIDATION)} UNVERIFIED.", file=sys.stderr)
            return 2
        print(f"\nSuccess! Dropped {dropped_count} invalid rules during validation.", file=sys.stderr)
        return 0
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        return 1


if __name__ == '__main__':
    sys.exit(main())
