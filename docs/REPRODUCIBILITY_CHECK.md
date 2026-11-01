# Reproducibility check

The paper-specific analysis code was run against the locally preserved 134-image child annotations and the six complete frozen prediction runs. No image or prediction records are included in this repository.

## Verified

- The repository's unit suite passed: 4 tests, including a perfect-pose COCOeval fixture, prediction contract, batch interface, and incomplete-run handling.
- The bundled child analysis script generated the six-model summary and 102 per-joint rows from the preserved complete runs. Both generated CSV files matched the checked-in files exactly (all rows and values).
- Official `pycocotools.COCOeval(iouType="keypoints")` was rerun independently for all six model prediction sets. For every model, AP, AP50, and AP75 matched the recorded results within `1e-12`.
- The calculation is deterministic for these frozen inputs; expected image count is 134 per model.

This verifies the paper's metric and reporting path on the preserved predictions. It does not claim that all six model checkpoints or source images are bundled, nor does it substitute for running fresh inference after obtaining the upstream data and weights. To reproduce from scratch, follow `README.md`; each model's runtime device and checkpoint provenance are recorded by the runner.
