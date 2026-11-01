#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CACHE_ROOT="${INFANTPOSE_CACHE_ROOT:-$HOME/.local/share/infantpose}"
ENV_ROOT="${INFANTPOSE_ENV_ROOT:-$CACHE_ROOT/venvs}"
SAPIENS_SHA256="5f003282c621bdea6d67bf60926650d879bb0874351f423abbea7a0586d1db5a"
DEFAULT_SAPIENS_CHECKPOINT="$ROOT/02_datasets/model_cache/sapiens_1b/sapiens_1b_coco_best_coco_AP_821_torchscript.pt2"
SAPIENS_CHECKPOINT="${INFANTPOSE_SAPIENS_CHECKPOINT:-$DEFAULT_SAPIENS_CHECKPOINT}"

# Reuse the exact checkpoint already shared from Windows when running under WSL2.
if [[ -z "${INFANTPOSE_SAPIENS_CHECKPOINT:-}" && ! -s "$SAPIENS_CHECKPOINT" ]]; then
  shopt -s nullglob
  windows_checkpoints=(/mnt/c/Users/*/Downloads/姿態判定/sapiens_1b_coco_best_coco_AP_821_torchscript-006.pt2 \
                       /mnt/c/Users/*/Downloads/姿態判定/sapiens_1b_coco_best_coco_AP_821_torchscript-007.pt2)
  if ((${#windows_checkpoints[@]})); then
    SAPIENS_CHECKPOINT="${windows_checkpoints[0]}"
  fi
fi

if [[ ! -s "$SAPIENS_CHECKPOINT" ]]; then
  echo 'The paper checkpoint was not found. In WSL2, keep it in Windows Downloads/姿態判定 or set INFANTPOSE_SAPIENS_CHECKPOINT.' >&2
  exit 4
fi
checkpoint_sha256="$(sha256sum "$SAPIENS_CHECKPOINT" | cut -d' ' -f1)"
if [[ "$checkpoint_sha256" != "$SAPIENS_SHA256" ]]; then
  echo 'The selected Sapiens checkpoint does not match the exact COCO-17 paper checkpoint.' >&2
  echo "Selected file: $SAPIENS_CHECKPOINT" >&2
  exit 4
fi

needs_setup=0
for model_env in mediapipe movenet rtmpose yolo sapiens openpose dataset-prep; do
  if [[ ! -x "$ENV_ROOT/$model_env/bin/python" ]]; then needs_setup=1; break; fi
done
if ((needs_setup)); then
  "$ROOT/scripts/setup_vm.sh"
fi
if [[ ! -f "$ROOT/config/local.json" ]]; then cp "$ROOT/config/local.example.json" "$ROOT/config/local.json"; fi
python3.12 "$ROOT/scripts/prepare_model_assets.py"
if [[ ! -f "$ROOT/02_datasets/canonical/coco_unihuman_child_val134/dataset_manifest.json" ]]; then
  "$ENV_ROOT/dataset-prep/bin/python" "$ROOT/scripts/prepare_datasets.py" --dataset coco_unihuman_child_val134
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
