### 
### Be sure to address
- Value added by features  
- Value added by models
**Note**: Make sure that you are combining different feature sets and classifiers, and also the comparisons make sense (So that you know what works)

### Organizing the GitHub folders
#### train.r &
- Baseline
- Yours

#### test.r  
- folder of input feature objects
- input "model" object from train.r
- output predicted labels  
  
## Eval
- new set of 2000 images
- each team will have 30 minutes to process them into features chosen
- submit processed features as a folder of feature objects file. featured shoule be readable by train.r test.r.
- Eval on eval.r
- 40% in presentation (methodology; interpretability; presentation)
- 40% in new images (train error vs test; stability;consistancy)
- peer 20%

## Submit
- train.r & test.r , work out 2000 individual files of features and two r file (r files before class) and do not need to come up with predictions. TA wil do it...

```{r}
library(EBImage)
img0 <- readImage('/Users/Bianbian/Downloads/images/Abyssinian_1.jpg')
img0
```
1. img0 is a three dimensional matrix for we have R G B.
2. Yes to RESIZE
3. Some research groups have separate feature sets for faces and body


*BLUR*
Basically utilied a moving window. Gaussian filtering means you are weighing the pixels in a certain graph by it's distance to the center point.
*LAPLACE*
Detecting the edges or sharpen the image by taking the difference.

*Segmenting*
THRESH: 毛色！
1. Morphological operations:????


*  **Outline Analysis**(with threshhold)(Might not be accurate)
* Local Curvature(You can define the curvatures by 1st 2nd derivative and plot using different colors)


Histogram feature extraction (tune number of bins)
HSV(Saturation) features

*Note if we only do color histogram, we are losing the spatial features, like how many colors are concentrated on which part of the graph*
:Partition and do individually .

? OUTDOOR INDOOR
? Imbalanced 
=======
Visual classification Challenges
- View Point
- Schle 
- Occlusion: Articulated entities; 3D scene layout
- Intra-class Difference: type and age

Bags of words: Note: Spatial Features 可能也有问题
