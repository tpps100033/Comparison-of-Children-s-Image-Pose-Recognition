# Comparison of Deep Learning Models for Human Pose Estimation in Children — code

Companion research code for the paper. This repository is limited to the paper's **134-image real-child cohort** and six frozen pose systems: MediaPipe Pose Heavy, MoveNet Thunder, RTMPose-M, YOLO11x-Pose, Sapiens 1B COCO, and OpenPose COCO18. It provides the inference adapters, fixed evaluation runner, official COCO keypoint evaluation, child-cohort preparation, aggregate metrics, and provenance notes.

MediaPipe Heavy and MoveNet Thunder use CPU inference in the evaluated runtime. RTMPose-M, YOLO11x, Sapiens, and OpenPose can use CUDA with their compatible environments. The runtime used is recorded in each run manifest.

## Reproduction inputs

The image cohort is based on COCO 2017 validation photographs and COCO-UniHuman v2 apparent-age/keypoint annotations. It is not bundled. Obtain those sources under their respective terms, then configure local paths using `config/local.example.json`. Model checkpoints are also fetched or placed in the local ignored cache; they are not redistributed here. Read [data provenance and source terms](docs/DATA_PROVENANCE.md) before running.

## Reproduction steps

1. Use Ubuntu 24.04 (including WSL2) with Python 3.12 and a compatible host NVIDIA driver if CUDA inference is desired. MediaPipe and MoveNet's evaluated adapters are CPU-based.
2. Install OpenPose build prerequisites as listed in [`requirements/openpose.md`](requirements/openpose.md) if reproducing OpenPose.
3. Run `bash scripts/setup_wsl.sh` from the repository root. It builds isolated environments for each model under the local user cache. Use the matching lock files in `requirements/locks/`.
4. Copy `config/local.example.json` to `config/local.json` and set the local data/annotation paths. Keep the local file private if it contains personal paths.
5. Prepare the child handoff with the documented data preparation script. Confirm the resulting manifest contains the intended 134 unique crops and hashes before inference.
6. Run an actual validation, for example: `python scripts/validate_model.py --model rtmpose_m --dataset coco_unihuman_child_val134`. Use the same command with each of the six model IDs.
7. Run one model with `python scripts/run_research.py --model rtmpose_m --dataset coco_unihuman_child_val134`. To run all six in sequence, use `bash scripts/run_all_models_for_dataset.sh coco_unihuman_child_val134`. The benchmark defaults to an 85°C stop threshold.
8. After all six runs complete, regenerate the paper's summary tables with `python scripts/analyse_pose_localization_comparison.py`. Existing aggregate outputs are in `reports/`; raw predictions and logs remain local.

The frozen `fair_reference` protocol uses batch size 1, 10 warm-up images, FP32, and disables AMP, compilation, quantization, and TensorRT. Accuracy uses `pycocotools.COCOeval(iouType="keypoints")` with the default COCO keypoint OKS settings. AP is for this 134-image subset, not full COCO validation AP. The accompanying analysis defines mean OKS and bbox-normalized PCK; pose coverage is diagnostic only.

The run manifests record runtime device, package versions, latency, GPU memory/temperature when available, and inference completeness. An import check is not a successful model validation; use real image inference. See [troubleshooting](docs/TROUBLESHOOTING.md) for runtime-specific details.

## Citation

See [`CITATION.cff`](CITATION.cff). Contact the corresponding author, HsinHung Kuo, at **khh@cycu.edu.tw**.

## License status

**Proposed for the original code: MIT.** This staging package contains `LICENSE.proposed-MIT.txt`, not an operative `LICENSE`, because publication rights and coauthor/institutional ownership should be confirmed before granting reuse rights. MIT is a good default for permissive reuse of research software; Apache-2.0 is an alternative if an explicit patent grant is important. Neither applies to third-party data, photos, annotations, checkpoints, or dependencies. See [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).
