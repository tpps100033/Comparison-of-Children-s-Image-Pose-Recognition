# Comparison of Deep Learning Models for Human Pose Estimation in Children — code

Companion research code for the paper. This repository is limited to the paper's **134-image real-child cohort** and six frozen pose systems: MediaPipe Pose Heavy, MoveNet Thunder, RTMPose-M, YOLO11x-Pose, Sapiens 1B COCO, and OpenPose COCO18. It provides the inference adapters, fixed evaluation runner, official COCO keypoint evaluation, child-cohort preparation, aggregate metrics, and provenance notes.

MediaPipe Heavy and MoveNet Thunder use CPU inference in the evaluated runtime. RTMPose-M, YOLO11x, Sapiens, and OpenPose can use CUDA with their compatible environments. The runtime used is recorded in each run manifest.

## Download and run in Ubuntu / WSL2

The setup downloads the paper's COCO-UniHuman annotations and selected COCO photographs, prepares the 134 crops, installs isolated model environments, and retrieves publicly downloadable model assets. The annotation source is for non-commercial research use; read [data provenance and source terms](docs/DATA_PROVENANCE.md) before running. No images or model weights are included in this GitHub repository.

1. Download this repository as a ZIP from GitHub or clone it inside Ubuntu 24.04 / WSL2. The environment must expose the RTX GPU through `nvidia-smi`.
2. Run `bash scripts/run_paper.sh`. It installs Ubuntu build prerequisites, creates per-model Python environments, downloads the COCO-UniHuman annotation and selected COCO photos, prepares the fixed child cohort, downloads public model assets, builds OpenPose, runs all six systems in sequence, and writes aggregate CSV/JSON output. GPU runs stop at 85°C by default.
3. The exact 17-keypoint Sapiens TorchScript checkpoint used in the paper is a separate 4.67 GB asset that is not publicly downloadable. Provide an authorized copy at `02_datasets/model_cache/sapiens_1b/sapiens_1b_coco_best_coco_AP_821_torchscript.pt2` (or set `INFANTPOSE_SAPIENS_CHECKPOINT`), then rerun the command. The runner will not substitute a different checkpoint.

For setup and data preparation without running inference, use `bash scripts/setup_vm.sh`. Once the Sapiens checkpoint is available, `bash scripts/run_paper.sh` runs inference and analysis.

The frozen `fair_reference` protocol uses batch size 1, 10 warm-up images, FP32, and disables AMP, compilation, quantization, and TensorRT. Accuracy uses `pycocotools.COCOeval(iouType="keypoints")` with the default COCO keypoint OKS settings. AP is for this 134-image subset, not full COCO validation AP. The accompanying analysis defines mean OKS and bbox-normalized PCK; pose coverage is diagnostic only.

Run the unit checks with `python -m unittest discover -s tests -v`. The run manifests record runtime device, package versions, latency, GPU memory/temperature when available, and inference completeness. A completed paper run writes predictions/manifests under `03_model_raw_outputs/`, aggregate CSV/JSON under `05_analysis_results/paper_run/`, and logs under `06_logs/`. Existing checked-in summary results remain unchanged. See [setup notes](docs/TROUBLESHOOTING.md) for runtime details.

## Citation

See [`CITATION.cff`](CITATION.cff). Contact the corresponding author, HsinHung Kuo, at **khh@cycu.edu.tw**.

## License and rights boundary

The original project code is distributed under the MIT License; see [`LICENSE`](LICENSE). MIT is a practical choice for reusable research software because it permits use, modification, and redistribution while requiring preservation of the copyright and license notice. The repository's pre-existing GitHub initialization already selected MIT.

The code license does not grant rights to COCO or COCO-UniHuman images/annotations, model checkpoints, third-party dependencies, institutional marks, or other separately owned material. Review [`DATA_AND_MODEL_LICENSES.md`](DATA_AND_MODEL_LICENSES.md) and each upstream license before use or redistribution.
