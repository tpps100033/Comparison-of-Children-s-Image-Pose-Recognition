# Child cohort provenance and use

## Source and cohort

The paper evaluates 134 real photographs from COCO 2017 validation imagery. COCO-UniHuman v2 validation annotations supply COCO-17 keypoints and manually assessed apparent-age attributes. The selected cohort contains one eligible apparent-age 3–17 child per unique source image, with a person crop and a fixed context margin. These ages are visual estimates, not verified chronological ages.

The cohort was filtered to valid, non-crowd keypoint instances. All 921 source-image IDs in the project's selected adult COCO comparison subset are excluded. Source image SHA-256 values are checked to prevent exact-file overlap and duplicates within the child cohort. After cropping, labeled keypoint coordinates are translated by the crop origin; COCO-17 order and visibility values are preserved, and unlabeled points remain `(0,0,0)`.

This is an age-labeled subset of COCO imagery, not an independent child-image acquisition. Results describe this 134-crop protocol and should not be generalized to all ages, populations, or full-scene detection.

## Obtaining data

This repository does not distribute COCO photographs, COCO-UniHuman annotation files, derived crops, or model weights. The VM setup retrieves the COCO-UniHuman annotation from its project-provided public Drive link and fetches selected COCO photographs from the [official COCO source](https://cocodataset.org/#keypoints-2017). Review the COCO-UniHuman research/non-commercial terms and COCO image terms, and cite both the [COCO dataset](https://cocodataset.org/#keypoints-2017) and [COCO-UniHuman](https://github.com/lishuhuai527/COCO-UniHuman). A small ID/hash manifest for the frozen COCO comparison subset is included so the same child selection can be prepared without copying the 921 comparison images. The preprocessing code verifies the expected cohort contract and writes local manifests. Do not upload source images, derived image crops, annotations, or model predictions unless the respective rights holders' terms permit it.

COCO-UniHuman annotations are identified by the source project as CC BY 4.0; COCO image rights remain tied to the source images and their original providers. A license on this code repository does not extend to either source.
