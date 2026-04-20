# Model Sizing Matrix: dmr-88

Date: 2026-04-20
Host profile: dmr-88

## Hardware Profile Used for Sizing

- CPU: 88 cores, single NUMA node
- RAM: 755 GiB
- GPU: none detected
- Local storage: 1.7 TB NVMe
- Network: 1 GbE

This matrix maps common model families and parameter ranges to expected fit and practical run strategy on this host.

## Assumptions and Rules of Thumb

- Weight memory estimate (very rough):
  - FP32: ~4 bytes/parameter
  - BF16/FP16: ~2 bytes/parameter
  - INT8: ~1 byte/parameter
  - 4-bit: ~0.5 byte/parameter
- Training memory is much higher than just weights (optimizer states + activations + gradients).
- On this node, practical fine-tuning should be interpreted as CPU-based adapter methods for small-to-mid models, not full-parameter training of large LLMs.

## Sizing Matrix

| Model family | Parameter range | Expected fit on dmr-88 | Recommended run strategy | Notes |
|---|---|---|---|---|
| Decoder LLM (GPT/Llama-style) | <= 1B | Fits in FP16/BF16 and below | CPU inference + CPU LoRA/PEFT experiments | Good for pipeline validation and domain adaptation prototyping |
| Decoder LLM (GPT/Llama-style) | 1B to 3B | Fits comfortably with INT8/4-bit; FP16 possible | Prefer quantized inference; LoRA/QLoRA-style adapter tuning on CPU with small batch | Throughput will be modest; tune for latency vs batch |
| Decoder LLM (GPT/Llama-style) | 3B to 7B | Fits with 4-bit/INT8; FP16 may be memory-heavy but possible | Quantized serving/eval; selective adapter tuning only | Good candidate for retrieval-augmented workflows |
| Decoder LLM (GPT/Llama-style) | 7B to 13B | Weight fit possible in 4-bit; runtime is CPU-limited | 4-bit offline inference/evaluation; avoid full fine-tune | Suitable for benchmark baselines, not high-QPS serving |
| Decoder LLM (GPT/Llama-style) | 13B to 34B | Partial/conditional fit depending on quantization/runtime overhead | Sharded/offline experiments only; prefer smaller distilled models | Stability and wall-clock times become significant constraints |
| Decoder LLM (GPT/Llama-style) | > 34B | Generally not practical for this profile | Do not target on this node; move to GPU cluster | Use this node for data prep and evaluation harness only |
| Encoder models (BERT/RoBERTa/DeBERTa) | <= 500M | Fits well | CPU inference and CPU fine-tuning feasible | Strong fit for classification, NER, ranking, retrieval encoders |
| Encoder models (BERT/RoBERTa/DeBERTa) | 500M to 1.5B | Fits; training feasible with careful batching | CPU fine-tune with gradient accumulation and mixed precision if framework supports it | Prefer sequence length controls for throughput |
| Seq2Seq (T5/BART/UL2-family) | <= 1B | Fits well | CPU inference and targeted fine-tune feasible | Useful for summarization, translation, report generation |
| Seq2Seq (T5/BART/UL2-family) | 1B to 3B | Fits with optimization | Quantized inference; parameter-efficient tuning only | Beam search costs can dominate CPU runtime |
| Vision transformers/CNN backbones | <= 1B params equivalent | Fits well | CPU training and inference feasible for moderate datasets | IO and augmentation pipeline tuning matters most |
| ASR / Speech encoders | <= 1B | Fits well | CPU inference and selective fine-tuning feasible | Feature extraction and batch pipeline optimize results |
| Diffusion models (U-Net + text encoder + VAE) | typical SD-class | Inference can run slowly on CPU; fine-tuning impractical | Use for correctness tests only; move production fine-tune to GPU | CPU-only generation is high latency |
| Embedding models | <= 1B | Fits well | Batch embedding generation on CPU | Good use case for this node with careful thread tuning |

## Practical Run Profiles

| Workload type | Recommended profile on dmr-88 |
|---|---|
| Fast experimentation | 1B to 3B models, INT8/4-bit inference, small-batch adapter tuning |
| Reliable CPU production baseline | Encoder/embedding models <= 1.5B, batched inference |
| Large-model evaluation only | 7B to 13B in 4-bit, offline jobs, no strict latency SLO |
| Not recommended here | Full fine-tuning for >= 7B LLMs, diffusion model fine-tuning, high-QPS LLM serving |

## Data and Pipeline Guidance for Fine-Tuning

- Use this node for high-value CPU stages:
  - Data cleaning, labeling QA, tokenization, deduplication
  - Feature generation and retrieval index builds
  - Prompt/adapter evaluation harnesses
- Keep model adaptation lightweight:
  - LoRA/QLoRA-style adapter tuning for small-to-mid models
  - Distillation to smaller deployment models
- For scaling beyond this matrix:
  - Move training to GPU nodes with high-bandwidth interconnect
  - Keep dmr-88 as orchestration, preprocessing, and evaluation control node

## Capacity Planning Notes

- Effective usable RAM is lower than 755 GiB once OS page cache, dataloaders, and framework overhead are included.
- CPU-only throughput is highly sensitive to:
  - tokenization efficiency
  - dataloader parallelism
  - quantized kernel quality
- Network at 1 GbE can bottleneck multi-node distributed training and large artifact sync.
