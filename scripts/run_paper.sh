#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CACHE_ROOT="${INFANTPOSE_CACHE_ROOT:-$HOME/.local/share/infantpose}"
ENV_ROOT="${INFANTPOSE_ENV_ROOT:-$CACHE_ROOT/venvs}"
SAPIENS_CHECKPOINT="${INFANTPOSE_SAPIENS_CHECKPOINT:-$ROOT/02_datasets/model_cache/sapiens_1b/sapiens_1b_coco_best_coco_AP_821_torchscript.pt2}"

if [[ ! -x "$ENV_ROOT/rtmpose/bin/python" || ! -x "$ENV_ROOT/openpose/bin/python" ]]; then
  "$ROOT/scripts/setup_vm.sh"
fi
if [[ ! -f "$ROOT/config/local.json" ]]; then cp "$ROOT/config/local.example.json" "$ROOT/config/local.json"; fi
python3.12 "$ROOT/scripts/prepare_model_assets.py"
if [[ ! -f "$ROOT/02_datasets/canonical/coco_unihuman_child_val134/dataset_manifest.json" ]]; then
  "$ENV_ROOT/dataset-prep/bin/python" "$ROOT/scripts/prepare_datasets.py" --dataset coco_unihuman_child_val134
fi

if [[ ! -f "$SAPIENS_CHECKPOINT" || ! -s "$SAPIENS_CHECKPOINT" ]]; then
  echo 'The exact Sapiens COCO-17 TorchScript checkpoint used in the paper is not publicly downloadable.' >&2
  echo "Provide the authorized 4.67 GB checkpoint at: $SAPIENS_CHECKPOINT" >&2
  echo 'No substitute checkpoint will be used, so the six-model paper comparison cannot run yet.' >&2
  exit 4
fi

OPENPOSE_BUILD="${CACHE_ROOT}/build/openpose-cuda-final"
if ! find "$OPENPOSE_BUILD/python/openpose" -maxdepth 1 -name 'pyopenpose*.so' -print -quit 2>/dev/null | grep -q .; then
  bash "$ROOT/scripts/build_openpose_cuda.sh"
fi

export INFANTPOSE_SAPIENS_CHECKPOINT="$SAPIENS_CHECKPOINT"
export INFANTPOSE_MAX_GPU_TEMP_C="${INFANTPOSE_MAX_GPU_TEMP_C:-85}"
bash "$ROOT/scripts/run_all_models_for_dataset.sh" coco_unihuman_child_val134
python3.12 "$ROOT/scripts/analyse_pose_localization_comparison.py" \
  --output-dir "$ROOT/05_analysis_results/paper_run"

echo
echo 'Paper run completed.'
echo "Per-model predictions and manifests: $ROOT/03_model_raw_outputs/"
echo "Recomputed paper tables (CSV/JSON): $ROOT/05_analysis_results/paper_run/"
echo "Run logs: $ROOT/06_logs/"
