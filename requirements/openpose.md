# OpenPose runtime

The Ubuntu VM installer provides the required development packages and downloads the upstream COCO-18 checkpoint. The paper runner builds the OpenPose v1.7.0 Python CUDA extension for the active NVIDIA GPU. For a separate build, run `bash scripts/build_openpose_cuda.sh`. Compilation uses two jobs by default; set `OPENPOSE_BUILD_JOBS` to use a different worker count.

OpenPose runs in its own isolated Python environment. Its adapter uses the compiled `pyopenpose` module and the checkpoint under `02_datasets/model_cache/openpose_coco18/`.
