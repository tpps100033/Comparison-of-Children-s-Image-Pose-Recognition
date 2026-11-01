#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ ! -f /etc/os-release ]] || ! . /etc/os-release || [[ "${ID:-}" != ubuntu ]]; then
  echo 'This installer targets Ubuntu 24.04 (including Ubuntu under WSL2).' >&2
  exit 2
fi
if [[ "${VERSION_ID:-}" != 24.04 ]]; then
  echo "Ubuntu 24.04 is the documented environment; detected ${VERSION_ID:-unknown}." >&2
  exit 2
fi
if ! command -v sudo >/dev/null && [[ "$(id -u)" != 0 ]]; then
  echo 'System build packages require sudo on first setup.' >&2
  exit 2
fi

APT=(sudo apt-get)
if [[ "$(id -u)" == 0 ]]; then APT=(apt-get); fi
"${APT[@]}" update
DEBIAN_FRONTEND=noninteractive "${APT[@]}" install -y \
  build-essential cmake git pkg-config curl ca-certificates \
  python3.12 python3.12-dev python3.12-venv \
  protobuf-compiler libprotobuf-dev libgoogle-glog-dev libgflags-dev \
  libopencv-dev libboost-all-dev libhdf5-dev libatlas-base-dev \
  libopenblas-dev libeigen3-dev libgoogle-perftools-dev libtbb-dev

command -v nvidia-smi >/dev/null || { echo 'The VM/WSL environment does not currently expose the NVIDIA GPU.' >&2; exit 3; }
nvidia-smi -L

"$ROOT/scripts/setup_wsl.sh"
CACHE_ROOT="${INFANTPOSE_CACHE_ROOT:-$HOME/.local/share/infantpose}"
ENV_ROOT="${INFANTPOSE_ENV_ROOT:-$CACHE_ROOT/venvs}"
DATA_ENV="$ENV_ROOT/dataset-prep"
if [[ ! -x "$DATA_ENV/bin/python" ]]; then python3.12 -m venv "$DATA_ENV"; fi
"$DATA_ENV/bin/python" -m pip install --upgrade pip
"$DATA_ENV/bin/python" -m pip install -r "$ROOT/requirements/dataset-prep.txt"

if [[ ! -d "$CACHE_ROOT/src/sapiens/.git" ]]; then
  mkdir -p "$CACHE_ROOT/src"
  git clone --depth 1 https://github.com/facebookresearch/sapiens.git "$CACHE_ROOT/src/sapiens"
fi

if [[ ! -f "$ROOT/config/local.json" ]]; then
  cp "$ROOT/config/local.example.json" "$ROOT/config/local.json"
fi
python3.12 "$ROOT/scripts/prepare_model_assets.py"
"$DATA_ENV/bin/python" "$ROOT/scripts/prepare_datasets.py" --dataset coco_unihuman_child_val134

echo
echo 'Environment and child cohort are prepared.'
echo 'The 17-keypoint Sapiens checkpoint used in the paper is a separate, non-public 4.67 GB asset.'
echo "Place an authorized copy at: $ROOT/02_datasets/model_cache/sapiens_1b/sapiens_1b_coco_best_coco_AP_821_torchscript.pt2"
echo 'Then run: bash scripts/run_paper.sh'
