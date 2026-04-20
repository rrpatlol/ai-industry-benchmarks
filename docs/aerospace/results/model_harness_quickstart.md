# Model Harness Quickstart

This quickstart runs the benchmark harness against measured results and generates a markdown scorecard for review.

## Inputs

- Spec file:
  - benchmarks/harness/model_eval_spec.yaml
- Measured run results:
  - benchmarks/harness/example_results.yaml (replace with real outputs)

## Recommended Workflow

### Step 1: Validate results file

python3 scripts/eval/validate_harness_results.py \
  --spec benchmarks/harness/model_eval_spec.yaml \
  --results benchmarks/harness/example_results.yaml

This checks that all required metrics are present and reports missing fields.

### Step 2: Run one-command pipeline

bash scripts/eval/run_model_harness_pipeline.sh \
  --spec benchmarks/harness/model_eval_spec.yaml \
  --results benchmarks/harness/example_results.yaml \
  --out-dir docs/aerospace/results/generated \
  --run-id dmr88_eval_example

If --run-id is omitted, a timestamped run ID is generated automatically.

## Manual Steps (if needed)

### Manual Step 1: Run evaluator

python3 scripts/eval/run_model_harness.py \
  --spec benchmarks/harness/model_eval_spec.yaml \
  --results benchmarks/harness/example_results.yaml \
  --out docs/aerospace/results/generated/model_harness_scorecard_example.json \
  --run-id dmr88_eval_example

### Manual Step 2: Render markdown report

python3 scripts/eval/generate_markdown_report.py \
  --scorecard docs/aerospace/results/generated/model_harness_scorecard_example.json \
  --out docs/aerospace/results/generated/model_harness_scorecard_example.md

## Outputs

- JSON scorecard:
  - docs/aerospace/results/generated/model_harness_scorecard_<run-id>.json
- Markdown report:
  - docs/aerospace/results/generated/model_harness_scorecard_<run-id>.md

## Interpreting decisions

- GO: all go-threshold checks pass, and no no-go trigger was hit.
- HOLD: at least one go-threshold check failed, but no no-go trigger fired.
- NO-GO: one or more no-go triggers fired.

## Dependency note

If YAML parsing is unavailable, install PyYAML:

pip install pyyaml
