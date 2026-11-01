# Comparison of Deep Learning Models for Human Pose Estimation in Children — code

Companion research code for the paper. This repository is limited to the paper's **134-image real-child cohort** and six frozen pose systems: MediaPipe Pose Heavy, MoveNet Thunder, RTMPose-M, YOLO11x-Pose, Sapiens 1B COCO, and OpenPose COCO18. It provides the inference adapters, fixed evaluation runner, official COCO keypoint evaluation, child-cohort preparation, aggregate metrics, and provenance notes.

MediaPipe Heavy and MoveNet Thunder use CPU inference in the evaluated runtime. RTMPose-M, YOLO11x, Sapiens, and OpenPose can use CUDA with their compatible environments. The runtime used is recorded in each run manifest.

## One-command setup and run — development preview

> **Development preview:** The one-click launcher is still under development and has not completed an end-to-end run in the target VM. Unexpected issues may occur.
>
> **開發預覽：** 一鍵啟動版仍在開發中，尚未完成目標 VM 的端到端測試，執行時可能發生非預期狀況。

In Ubuntu 24.04 or Ubuntu on WSL2, paste this once:

```bash
mkdir -p ~/children-pose-paper && cd ~/children-pose-paper && python3 -c 'import urllib.request; urllib.request.urlretrieve("https://github.com/tpps100033/Comparison-of-Children-s-Image-Pose-Recognition/archive/refs/heads/main.tar.gz", "/tmp/children-pose-paper.tar.gz")' && tar -xzf /tmp/children-pose-paper.tar.gz --strip-components=1 && bash START_HERE.sh
```

On Windows with Ubuntu on WSL2, download [`START_HERE.cmd`](https://raw.githubusercontent.com/tpps100033/Comparison-of-Children-s-Image-Pose-Recognition/main/START_HERE.cmd) and double-click it. It downloads the current package into Ubuntu's Linux file system and starts the same workflow.

The starter checks Ubuntu and GPU access, finds and verifies the paper's Sapiens checkpoint from `C:\\Users\\<you>\\Downloads\\姿態判定` under WSL2, prepares the isolated environments, downloads the data and public model files, runs all six systems, and writes the output tables and logs. First setup asks for the Ubuntu `sudo` password to install system packages. GPU runs stop at 85°C by default.

## Download and run in Ubuntu / WSL2

The setup downloads the paper's COCO-UniHuman annotations and selected COCO photographs, prepares the 134 crops, installs isolated model environments, and retrieves publicly downloadable model assets. The annotation source is for non-commercial research use; read [data provenance and source terms](docs/DATA_PROVENANCE.md) before running. No images or model weights are included in this GitHub repository.

For manual setup, run `bash scripts/run_paper.sh`. The exact 17-keypoint Sapiens TorchScript checkpoint is a separate 4.67 GB asset. The starter automatically finds and verifies the supplied checkpoint in the Windows Downloads folder under WSL2; on a separate Ubuntu VM, place it at `02_datasets/model_cache/sapiens_1b/sapiens_1b_coco_best_coco_AP_821_torchscript.pt2` or set `INFANTPOSE_SAPIENS_CHECKPOINT`.

For setup and data preparation without running inference, use `bash scripts/setup_vm.sh`. Once the Sapiens checkpoint is available, `bash scripts/run_paper.sh` runs inference and analysis.

The frozen `fair_reference` protocol uses batch size 1, 10 warm-up images, FP32, and disables AMP, compilation, quantization, and TensorRT. Accuracy uses `pycocotools.COCOeval(iouType="keypoints")` with the default COCO keypoint OKS settings. AP is for this 134-image subset, not full COCO validation AP. The accompanying analysis defines mean OKS and bbox-normalized PCK; pose coverage is diagnostic only.

Run the unit checks with `python -m unittest discover -s tests -v`. The run manifests record runtime device, package versions, latency, GPU memory/temperature when available, and inference completeness. A completed paper run writes predictions/manifests under `03_model_raw_outputs/`, aggregate CSV/JSON under `05_analysis_results/paper_run/`, and logs under `06_logs/`. Existing checked-in summary results remain unchanged. See [setup notes](docs/TROUBLESHOOTING.md) for runtime details.

## Citation

See [`CITATION.cff`](CITATION.cff). Contact the corresponding author, HsinHung Kuo, at **khh@cycu.edu.tw**.

## License and rights boundary

The original project code is distributed under the MIT License; see [`LICENSE`](LICENSE). MIT is a practical choice for reusable research software because it permits use, modification, and redistribution while requiring preservation of the copyright and license notice. The repository's pre-existing GitHub initialization already selected MIT.

The code license does not grant rights to COCO or COCO-UniHuman images/annotations, model checkpoints, third-party dependencies, institutional marks, or other separately owned material. Review [`DATA_AND_MODEL_LICENSES.md`](DATA_AND_MODEL_LICENSES.md) and each upstream license before use or redistribution.
