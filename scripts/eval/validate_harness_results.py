#!/usr/bin/env python3
"""
Validator for model benchmark harness result files.

Checks that all required metrics are present before running evaluation.
Fails fast with a clear checklist of missing metrics per lane/model.

Usage:
  python3 scripts/eval/validate_harness_results.py \
    --spec benchmarks/harness/model_eval_spec.yaml \
    --results benchmarks/harness/example_results.yaml
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path
from typing import Any, Dict, List, Set


def load_yaml(path: Path) -> Dict[str, Any]:
    try:
        import yaml  # type: ignore
    except Exception:
        raise RuntimeError(
            "PyYAML is required for YAML files. Install with: pip install pyyaml"
        )

    with path.open("r", encoding="utf-8") as f:
        data = yaml.safe_load(f)
    if not isinstance(data, dict):
        raise ValueError(f"Expected mapping at root of {path}")
    return data


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate harness result files")
    parser.add_argument("--spec", required=True, help="Path to YAML spec")
    parser.add_argument("--results", required=True, help="Path to measured results (YAML or JSON)")
    args = parser.parse_args()

    spec_path = Path(args.spec)
    results_path = Path(args.results)

    if not spec_path.exists():
        print(f"ERROR: Spec file not found: {spec_path}", file=sys.stderr)
        return 1

    if not results_path.exists():
        print(f"ERROR: Results file not found: {results_path}", file=sys.stderr)
        return 1

    spec = load_yaml(spec_path)
    results = load_yaml(results_path)

    # Build lane index
    lane_index: Dict[str, Dict[str, Any]] = {}
    for lane in spec.get("lanes", []):
        lane_id = lane.get("lane_id")
        if lane_id:
            lane_index[lane_id] = lane

    # Validate runs
    runs = results.get("runs", [])
    if not isinstance(runs, list):
        print(
            "ERROR: results.runs must be a list",
            file=sys.stderr,
        )
        return 1

    total_runs = len(runs)
    valid_runs = 0
    invalid_runs = 0
    issues: List[str] = []

    for idx, run in enumerate(runs, start=1):
        lane_id = run.get("lane_id")
        model = run.get("model", "unknown")
        metrics = run.get("metrics", {})

        run_label = f"Run {idx}: {lane_id} / {model}"

        if lane_id not in lane_index:
            issues.append(f"{run_label}: Unknown lane_id")
            invalid_runs += 1
            continue

        if not isinstance(metrics, dict):
            issues.append(f"{run_label}: 'metrics' must be a mapping")
            invalid_runs += 1
            continue

        lane = lane_index[lane_id]
        required_metrics: Set[str] = {m["key"] for m in lane.get("metrics", [])}
        present_metrics: Set[str] = set(metrics.keys())
        missing_metrics = required_metrics - present_metrics

        if missing_metrics:
            missing_str = ", ".join(sorted(missing_metrics))
            issues.append(f"{run_label}: missing metrics: {missing_str}")
            invalid_runs += 1
        else:
            valid_runs += 1

    # Print summary
    print(f"Validation report: {results_path}")
    print(f"  Spec: {spec_path}")
    print(f"  Total runs: {total_runs}")
    print(f"  Valid: {valid_runs}")
    print(f"  Invalid: {invalid_runs}")
    print()

    if issues:
        print("Issues found:")
        for issue in sorted(issues):
            print(f"  - {issue}")
        print()
        print("Fix these issues before running the harness evaluator.")
        return 1

    print("✓ All runs valid. Ready for harness evaluation.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        raise
