#!/usr/bin/env python3
"""
Render markdown scorecards from harness JSON output.
"""

from __future__ import annotations

import argparse
import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List


def load_json(path: Path) -> Dict[str, Any]:
    with path.open("r", encoding="utf-8") as f:
        data = json.load(f)
    if not isinstance(data, dict):
        raise ValueError("Scorecard root must be an object")
    return data


def fmt(v: Any) -> str:
    if isinstance(v, float):
        return f"{v:.4f}".rstrip("0").rstrip(".")
    if v is None:
        return "NA"
    return str(v)


def render(score: Dict[str, Any]) -> str:
    run_id = score.get("run_id", "unknown")
    generated = score.get("generated_at_utc", datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC"))
    summary = score.get("summary", {})
    runs: List[Dict[str, Any]] = score.get("evaluated_runs", [])

    lines: List[str] = []
    lines.append(f"# Model Harness Scorecard: {run_id}")
    lines.append("")
    lines.append(f"- Generated: {generated}")
    lines.append(f"- Total runs: {summary.get('total', 0)}")
    lines.append(f"- GO: {summary.get('go', 0)}")
    lines.append(f"- HOLD: {summary.get('hold', 0)}")
    lines.append(f"- NO-GO: {summary.get('no_go', 0)}")
    lines.append("")

    lines.append("## Decisions")
    lines.append("")
    lines.append("| Lane | Model | Decision | Missing Metrics |")
    lines.append("|---|---|---|---|")
    for r in runs:
        missing = ", ".join(r.get("missing_metrics", [])) or "none"
        lines.append(
            f"| {r.get('lane_id', 'unknown')} | {r.get('model', 'unknown')} | {r.get('decision', 'HOLD')} | {missing} |"
        )
    lines.append("")

    lines.append("## Metric Details")
    lines.append("")
    for r in runs:
        lines.append(f"### {r.get('lane_id', 'unknown')} / {r.get('model', 'unknown')}")
        lines.append("")
        lines.append("| Metric | Value | Direction | Go Threshold | No-Go Threshold | Go Pass | No-Go Trigger |")
        lines.append("|---|---:|---|---:|---:|---|---|")
        for m in r.get("metric_results", []):
            lines.append(
                "| {metric} | {value} | {direction} | {go_t} | {no_go_t} | {go_pass} | {no_go} |".format(
                    metric=m.get("metric", "unknown"),
                    value=fmt(m.get("value")),
                    direction=m.get("direction", ""),
                    go_t=fmt(m.get("go_threshold")),
                    no_go_t=fmt(m.get("no_go_threshold")),
                    go_pass="yes" if m.get("go_pass") else "no",
                    no_go="yes" if m.get("no_go_trigger") else "no",
                )
            )
        lines.append("")

    return "\n".join(lines) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate markdown report from model harness scorecard JSON")
    parser.add_argument("--scorecard", required=True, help="Input scorecard JSON path")
    parser.add_argument("--out", required=True, help="Output markdown file path")
    args = parser.parse_args()

    score = load_json(Path(args.scorecard))
    md = render(score)

    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(md, encoding="utf-8")

    print(f"Wrote markdown report: {out_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
