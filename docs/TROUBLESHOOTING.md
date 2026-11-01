# VM setup notes

## First-time setup

From Ubuntu 24.04 or WSL2, run `bash scripts/setup_vm.sh`. It installs the required Ubuntu build packages, creates isolated model environments, downloads the cohort annotations and selected photos, and fetches the public model assets. In WSL2, install the NVIDIA driver on Windows and confirm `nvidia-smi` works inside Ubuntu before running the setup.

## Run the paper workflow

Use `bash scripts/run_paper.sh`. It runs the six models in sequence with an 85°C GPU stop limit and writes per-model predictions and manifests to `03_model_raw_outputs/`, aggregate CSV/JSON files to `05_analysis_results/paper_run/`, and logs to `06_logs/`. The COCO comparison ID/SHA-256 manifest required for child-cohort deduplication is included under `config/`.

## Sapiens checkpoint

The exact Sapiens COCO-17 TorchScript checkpoint used in the paper is a 4.67 GB asset that is not publicly downloadable. Supply an authorized copy at `02_datasets/model_cache/sapiens_1b/sapiens_1b_coco_best_coco_AP_821_torchscript.pt2`, or set `INFANTPOSE_SAPIENS_CHECKPOINT` to its path. The workflow keeps this exact checkpoint requirement so the reported model and scores remain reproducible.

## OpenPose installation

The VM setup installs OpenPose build prerequisites and downloads the upstream COCO-18 model asset. The paper runner builds the OpenPose v1.7.0 CUDA extension as part of first-time execution. To build it separately, run `bash scripts/build_openpose_cuda.sh`; compilation uses two jobs by default.

## Temperature and memory telemetry

GPU runs stop when the reported temperature exceeds 85°C. Set `INFANTPOSE_MAX_GPU_TEMP_C` to choose a lower cutoff. The run manifest records temperature, runtime device, and GPU-memory telemetry when available.
