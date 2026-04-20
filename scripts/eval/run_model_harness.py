#!/usr/bin/env python3
"""
Evaluate model benchmark runs against the sizing-matrix thresholds.

Input files:
- Spec (YAML): lane definitions and thresholds
- Results (YAML or JSON): measured metrics for lane/model runs

Results format:
runs:
  - lane_id: domain_assistant_small
    model: Qwen2.5-1.5B-Instruct
    metrics:
      grounded_answer_rate: 0.91
      hallucination_rate: 0.07
      sme_score: 3.9
      p50_ttft_seconds: 2.4
      decode_tokens_per_second: 8.3
"""

from __future__ import annotations

import argparse
import json
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Tuple


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


def load_data(path: Path) -> Dict[str, Any]:
    suffix = path.suffix.lower()
    if suffix == ".json":
        with path.open("r", encoding="utf-8") as f:
            data = json.load(f)
        if not isinstance(data, dict):
            raise ValueError(f"Expected JSON object at root of {path}")
        return data
    return load_yaml(path)


def compare(direction: str, value: float, threshold: float) -> bool:
    if direction == "gte":
        return value >= threshold
    if direction == "lte":
        return value <= threshold
    raise ValueError(f"Unsupported direction: {direction}")


def evaluate_run(
    lane: Dict[str, Any], run: Dict[str, Any]
) -> Tuple[str, bool, bool, List[Dict[str, Any]], List[str]]:
    metrics = run.get("metrics", {})
    if not isinstance(metrics, dict):
        raise ValueError("run.metrics must be a mapping")

    details: List[Dict[str, Any]] = []
    all_go = True
    any_no_go_trigger = False
    missing: List[str] = []

    for spec_metric in lane.get("metrics", []):
        key = spec_metric["key"]
        direction = spec_metric["direction"]
        go_threshold = float(spec_metric["go_threshold"])
        no_go_threshold = float(spec_metric["no_go_threshold"])

        raw_value = metrics.get(key)
        if raw_value is None:
            all_go = False
            missing.append(key)
            details.append(
                {
                    "metric": key,
                    "status": "missing",
                    "value": None,
                    "go_threshold": go_threshold,
                    "no_go_threshold": no_go_threshold,
                    "direction": direction,
                    "go_pass": False,
                    "no_go_trigger": False,
                }
            )
            continue

        value = float(raw_value)
        go_pass = compare(direction, value, go_threshold)

        if direction == "gte":
            no_go_trigger = value < no_go_threshold
        else:
            no_go_trigger = value > no_go_threshold

        if not go_pass:
            all_go = False
        if no_go_trigger:
            any_no_go_trigger = True

        details.append(
            {
                "metric": key,
                "status": "ok",
                "value": value,
                "go_threshold": go_threshold,
                "no_go_threshold": no_go_threshold,
                "direction": direction,
                "go_pass": go_pass,
                "no_go_trigger": no_go_trigger,
            }
        )

    if any_no_go_trigger:
        decision = "NO-GO"
    elif all_go:
        decision = "GO"
    else:
        decision = "HOLD"

    return decision, all_go, any_no_go_trigger, details, missing


def main() -> int:
    parser = argparse.ArgumentParser(description="Run model benchmark harness evaluation")
    parser.add_argument("--spec", required=True, help="Path to YAML spec")
    parser.add_argument("--results", required=True, help="Path to measured results (YAML or JSON)")
    parser.add_argument("--out", required=True, help="Path to scorecard JSON output")
    parser.add_argument("--run-id", default="manual", help="Run identifier")
    args = parser.parse_args()

    spec_path = Path(args.spec)
    results_path = Path(args.results)
    out_path = Path(args.out)

    spec = load_data(spec_path)
    results = load_data(results_path)

    lane_index = {lane["lane_id"]: lane for lane in spec.get("lanes", [])}

    runs = results.get("runs", [])
    if not isinstance(runs, list):
        raise ValueError("results.runs must be a list")

    evaluated = []
    go_count = 0
    hold_count = 0
    no_go_count = 0

    for run in runs:
        lane_id = run.get("lane_id")
        model = run.get("model", "unknown")
        if lane_id not in lane_index:
            evaluated.append(
                {
                    "lane_id": lane_id,
                    "model": model,
                    "decision": "INVALID",
                    "reason": f"Unknown lane_id: {lane_id}",
                    "metric_results": [],
                }
            )
            hold_count += 1
            continue

        lane = lane_index[lane_id]
        decision, all_go, any_no_go_trigger, metric_details, missing = evaluate_run(lane, run)

        if decision == "GO":
            go_count += 1
        elif decision == "NO-GO":
            no_go_count += 1
        else:
            hold_count += 1

        evaluated.append(
            {
                "lane_id": lane_id,
                "task": lane.get("task", ""),
                "model": model,
                "decision": decision,
                "all_go_thresholds_passed": all_go,
                "no_go_triggered": any_no_go_trigger,
                "missing_metrics": missing,
                "metric_results": metric_details,
            }
        )

    payload = {
        "run_id": args.run_id,
        "profile": spec.get("profile", {}),
        "generated_at_utc": datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC"),
        "summary": {
            "total": len(evaluated),
            "go": go_count,
            "hold": hold_count,
            "no_go": no_go_count,
        },
        "evaluated_runs": evaluated,
    }

    out_path.parent.mkdir(parents=True, exist_ok=True)
    with out_path.open("w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2)

    print(f"Wrote scorecard JSON: {out_path}")
    print(json.dumps(payload["summary"], indent=2))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        raise
