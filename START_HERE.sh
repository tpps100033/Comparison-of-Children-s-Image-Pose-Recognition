#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f /etc/os-release ]] || ! . /etc/os-release || "${ID:-}" != ubuntu || "${VERSION_ID:-}" != 24.04; then
  echo 'Run this starter in Ubuntu 24.04 or Ubuntu 24.04 under WSL2.' >&2
  exit 2
fi
if ! command -v nvidia-smi >/dev/null; then
  echo 'The NVIDIA GPU is not visible in this Ubuntu environment. Check GPU access before starting.' >&2
  exit 3
fi

export INFANTPOSE_MAX_GPU_TEMP_C="${INFANTPOSE_MAX_GPU_TEMP_C:-85}"
echo 'Starting the six-model child-pose research workflow.'
echo "GPU temperature stop limit: ${INFANTPOSE_MAX_GPU_TEMP_C}°C"
echo 'First run prepares isolated environments, downloads data and public model files, and runs inference.'
echo 'Later runs reuse local files and environments.'
bash "$ROOT/scripts/run_paper.sh"
