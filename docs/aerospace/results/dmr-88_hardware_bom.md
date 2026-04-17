# Hardware BOM: dmr-88

- Captured: 2026-04-17 16:59:56 UTC
- Hostname: dmr-88
- OS: CentOS Stream 10 (Coughlan)
- Kernel: 6.18.0-dmr.bkc.6.18.3.8.3.x86_64

## Compute

- CPU model: Genuine Intel(R) 0000
- Sockets: 1
- Cores per socket: 88
- Threads per core: 1
- Total logical CPUs: 88
- NUMA nodes: 1

## Memory

- Installed memory (OS view): 755Gi
- Populated DIMMs found: 8

| Locator | Size | Speed | Manufacturer | Part Number |
|---|---|---|---|---|
| CPU0_DIMM_CH0S0 | 96 GB | 8000 MT/s | Samsung | MDRRWM4QEBC2-5P200 |
| CPU0_DIMM_CH1S0 | 96 GB | 8000 MT/s | Samsung | MDRRWM4QEBC2-5P200 |
| CPU0_DIMM_CH2S0 | 96 GB | 8000 MT/s | Samsung | MDRRWM4QEBC2-5P200 |
| CPU0_DIMM_CH3S0 | 96 GB | 8000 MT/s | Samsung | MDRRWM4QEBC2-5P200 |
| CPU0_DIMM_CH8S0 | 96 GB | 8000 MT/s | Micron | MTC40F204WS1RC80BCA M3FF |
| CPU0_DIMM_CH9S0 | 96 GB | 8000 MT/s | Micron | MTC40F204WS1RC80BCA M3FF |
| CPU0_DIMM_CH10S0 | 96 GB | 8000 MT/s | Micron | MTC40F204WS1RC80BCA M3FF |
| CPU0_DIMM_CH11S0 | 96 GB | 8000 MT/s | Micron | MTC40F204WS1RC80BCA M3FF |

## Storage Devices

| Name | Model | Size | Rotational | Type |
|---|---|---|---|---|
| nvme0n1 | Micron_7450_MTFDKBG1T9TFR | 1.7T | 0 | disk |

## Network Interfaces

| Interface | Speed | Duplex | Driver | MAC |
|---|---|---|---|---|
| sit0@NONE | unknown | unknown | unknown | unknown |
| ens12 | 1000Mb/s | Full | igb | 98:4f:ee:1a:d8:5c |

## PCI Devices of Interest

- 0000:02:00.0 VGA compatible controller: ASPEED Technology, Inc. ASPEED Graphics Family (rev 52)
- 0000:04:00.0 Ethernet controller: Intel Corporation I210 Gigabit Network Connection (rev 03)

## GPU Inventory

- No NVIDIA GPUs detected via nvidia-smi.

## Platform / Firmware

- BIOS vendor: Intel Corporation
- BIOS version: OKSDCRB1.IPC.0033.D87.2603311940
- Baseboard vendor: Intel Corporation
- Baseboard model: JohnsonCity1SPCRP
- Chassis type: Rack Mount Chassis

## Notes for Fine-Tuning Planning

- This BOM captures physical and logical node capabilities for sizing model training and fine-tuning jobs.
- For multi-node planning, pair this with interconnect topology, sustained all-reduce benchmarks, and storage throughput characterization.
