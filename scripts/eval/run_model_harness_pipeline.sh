#!/usr/bin/env bash
set -euo pipefail

SPEC="benchmarks/harness/model_eval_spec.yaml"
RESULTS="benchmarks/harness/example_results.yaml"
OUT_DIR="docs/aerospace/results/generated"
RUN_ID=""

usage() {
  cat <<'EOF'
Usage:
  bash scripts/eval/run_model_harness_pipeline.sh [options]

Options:
  --spec <path>       Path to harness spec YAML
  --results <path>    Path to measured results YAML/JSON
  --out-dir <path>    Output directory for generated scorecards
  --run-id <id>       Optional run identifier (default: host_utcTimestamp)
  -h, --help          Show this help

Example:
  bash scripts/eval/run_model_harness_pipeline.sh \
    --spec benchmarks/harness/model_eval_spec.yaml \
    --results benchmarks/harness/example_results.yaml \
    --out-dir docs/aerospace/results/generated \
    --run-id dmr88_eval_001
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --spec)
      SPEC="$2"
      shift 2
      ;;
    --results)
      RESULTS="$2"
      shift 2
      ;;
    --out-dir)
      OUT_DIR="$2"
      shift 2
      ;;
    --run-id)
      RUN_ID="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 2
      ;;
  esac
done

if [[ ! -f "$SPEC" ]]; then
  echo "Spec file not found: $SPEC" >&2
  exit 1
fi

if [[ ! -f "$RESULTS" ]]; then
  echo "Results file not found: $RESULTS" >&2
  exit 1
fi

if [[ -z "$RUN_ID" ]]; then
  RUN_ID="$(hostname -s)_$(date -u +%Y%m%d_%H%M%S)"
fi

mkdir -p "$OUT_DIR"

JSON_OUT="$OUT_DIR/model_harness_scorecard_${RUN_ID}.json"
MD_OUT="$OUT_DIR/model_harness_scorecard_${RUN_ID}.md"

python3 scripts/eval/run_model_harness.py \
  --spec "$SPEC" \
  --results "$RESULTS" \
  --out "$JSON_OUT" \
  --run-id "$RUN_ID"

python3 scripts/eval/generate_markdown_report.py \
  --scorecard "$JSON_OUT" \
  --out "$MD_OUT"

echo "Pipeline complete"
echo "- JSON scorecard: $JSON_OUT"
echo "- Markdown report: $MD_OUT"
