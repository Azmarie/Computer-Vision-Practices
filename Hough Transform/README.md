# Image Filtering and Hough Transform

## Convolution

### Visualize test image 1 with two different kernels 

| Blur Filter (Box kernel) `kernel = ones(15)`| Sharping Filter   `kernel = [0 -1 0; -1 5 -1; 0 -1 0]` |
|-----------------------------------|-----------------------------------------|
|<img src="ec/boxblur15.png" width="450" alt="Blured Image" >|<img src="ec/sharp.png" width="450" alt="Blured Image" >|

## Edge detection 

### Visualize `myEdgeFilter` results on test image 1&2 edges and edges after threshold

|           | Image 1                                             | Image 2                                             |
|-----------|-----------------------------------------------------|-----------------------------------------------------|
| Edge      | <img src="results/img01_01edge.png" width="380" alt="Image 1 Edge" >| <img src="results/img02_01edge.png" width="380" alt="Image 2 Edge" >           |
| Threshold |  <img src="results/img01_02threshold.png" width="380" alt="Image 1 Threshold" > | <img src="results/img02_02threshold.png" width="380" alt="Image 2 Threshold" >|

## Hough Transform

### Visualize `myHoughTransform` results on test image 1&2 hough accumulator

| Image 1                                 | Image 2                                 |
|-----------------------------------------|-----------------------------------------|
| ![Image 1 H](results/img01_03hough.png) | ![Image 2 H](results/img02_03hough.png) |


## Finding lines
Here, non maximal suppression was enabled with matlab function `imregionalmax`, it returns the binary image that identifies the regional maxima in the input image. I use `H = imregionalmax(H).* H` to then zero out the non-regional maxima which considers all neighbors. 

### Visualize test image 1&3 result of peak finding 

| Image 1                                 | Image 3                                 |
|-----------------------------------------|-----------------------------------------|
| ![Image 1 peak](results/backup/img01_03houghpeak.png) | ![Image 2 peak](results/backup/img03_03houghpeak.png) |


## Fitting line segments for visualization

### Visualize test image 1&2 line segment extraction results

| Image 1                                 | Image 2                                 |
|-----------------------------------------|-----------------------------------------|
| <img src="results/img01_04lines.png" width="400" alt="Image 1 Lines" >| <img src="results/img02_04lines.png" width="400" alt="Image 2 Lines" >|


## Experiments

### Summary

1. Did your code work well on all the images with a single set of parameters?

With one set of parameters, all the images give satisfactory results, though they are not optimal. With customized set of parameters, the performance could visibly be improved.

2. How did the optimal set of parameters vary with images? 

I find that, with more details (lines, unregular shapes, and etc.), `threshold` can be set higher, for example `0.1` to rule out fuzzy and unbounded area so that the edges look neat and clean. It also helps to set `thetaRes` lower, for example `pi/120` to sample more `theta` values in the range. `Sigma = 4` seems to be blur the images well for all cases, though slightly increasing sigma for images with more details can also help to get a clean result. Setting `rhoRes` to a higher value breaks the hough line segments into smaller intervals and can help to capture short and less obvious boundaries of objects, though the results seems busy due to the small line segments all over the image. 

3. Which step of the algorithm causes the most problems? 

I think `myEdgeFilter` caused the most problems, it's mainly because the implementation of non maximum suppression requires complex conditions.

4. Did you find any changes you could make to your code or algorithm that improved performance? 

I recognize that vectorization in Matlab often runs more efficiently than the loops. In particular, in `myHoughLines.m`, I used a loop to iterate (from 1 to nLines) and fill rhos and thetas, though in hindsight, I could use `ind2sub` vectorized code in Matlab to convert linear indices to subscripts.

### A set of intermediate outputs for test image 4

| Original                                  | Gaussian Blurred                            | Sobel Filter                              | Normalized Sobel Filter                     |
|-------------------------------------------|---------------------------------------------|-------------------------------------------|---------------------------------------------|
|<img src="data/img08.jpg" width="350" alt="Image 8" >|<img src="ec/gblur-8.png" width="350" alt="Image 8" >| <img src="ec/sobel.png" width="350" alt="Image 8" > |<img src="ec/sobel-norm.png" width="350" alt="Image 8" >|
| Edge                                      | Threshold                                   | Hough Accumulator                         | Hough Lines Extraction                      |
| <img src="results/img08_01edge.png" width="350" alt="Image 8" >|<img src="results/img08_02threshold.png" width="350" alt="Image 8" > | <img src="results/img08_03hough.png" height="200" alt="Image 8" >| <img src="results/img08_04lines.png" width="350" alt="Image 8" >|

### More Results on new test images

Vancouver

```
sigma     = 5;
threshold = 0.1;
rhoRes    = 10;
thetaRes  = pi/90;
nLines    = 45;
```

| Original                                    | Edge                                     |Threshold |  Hough Accumulator         | Hough Lines Extraction                   |
|---------------------------------------------|------------------------------------------|---------------------------------------------|------------------------------------------|------------------------------------------|
| <img src="ec/vancouver.jpg" width="200">        |<img src="ec/vancouver_01edge.png" width="200"> | <img src="ec/vancouver_02threshold.png" width="200"> | <img src="ec/vancouver_03hough.png" height="200"> | <img src="ec/vancouver_04lines.png" width="200"> |

Mona Lisa

```
Parameters
sigma     = 2;
threshold = 0.2;
rhoRes    = 8;
thetaRes  = pi/60;
nLines    = 80;
```

| Original                                    | Edge                                     |Threshold |  Hough Accumulator         | Hough Lines Extraction                   |
|---------------------------------------------|------------------------------------------|---------------------------------------------|------------------------------------------|------------------------------------------|
| <img src="ec/monalisa.jpg" width="200">        |<img src="ec/monalisa_01edge.png" width="200"> | <img src="ec/monalisa_02threshold.png" width="200"> | <img src="ec/monalisa_03hough.png" height="200"> | <img src="ec/monalisa_04lines.png" width="200"> |

Pikachu, Kumamoto
```
sigma     = 4;
threshold = 0.03;
rhoRes    = 4;
thetaRes  = pi/90;
nLines    = 30;
```

Pikachu

| Original                                    | Edge                                     |Threshold |  Hough Accumulator         | Hough Lines Extraction                   |
|---------------------------------------------|------------------------------------------|---------------------------------------------|------------------------------------------|------------------------------------------|
| <img src="ec/pikac.jpg" width="200">        |<img src="ec/pikac_01edge.png" width="200"> | <img src="ec/pikac_02threshold.png" width="200"> | <img src="ec/pikac_03hough.png" height="200"> | <img src="ec/pikac_04lines.png" width="200"> |

Kumamoto

| Original                                    | Edge                                     |Threshold |  Hough Accumulator         | Hough Lines Extraction                   |
|---------------------------------------------|------------------------------------------|---------------------------------------------|------------------------------------------|------------------------------------------|
| <img src="ec/Kumamoto.jpg" width="200">        |<img src="ec/Kumamoto_01edge.png" width="200"> | <img src="ec/Kumamoto_02threshold.png" width="200"> | <img src="ec/Kumamoto_03hough.png" height="300"> | <img src="ec/Kumamoto_04lines.png" width="200"> |
