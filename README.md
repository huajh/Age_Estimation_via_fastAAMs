# Age recoginition via fastAAMs

A very simple approach!

## feature extraction

The code is in the `featureExtraction.m` file.

It includes two steps:

### train AAM Model 
 `featureExtraction.m`

Set 
```matlab
% featureExtraction.m

% the training data is in `morph_small/trainset/`

flag_train = 1;
flag_precalibration == 1
```

Run `featureExtraction.m` script, 

* Set `flag_train = 1;`, then `AAM.mat` file (AAM model) will be generated in the folder `morph_small/trainset/`. After that, set  `flag_train = 0;`.
*  Set `flag_precalibration == 1;`, then the calibration parameters would be computed and saved in `meanscl.mat` and `meantrans.mat`. After that, set  `flag_precalibration = 0;`.

### extract the training images using the AAM model

The training/test images are in the folder `morph_small/Images_ori/` (total 2500 images).

**dataset** the morph dataset can be download from [this website](http://www.faceaginggroup.com/morph/).

Alternatively, I upload some images [here](https://pan.baidu.com/s/1o8dkXD4) (total 10000 images) and [here](https://pan.baidu.com/s/1c1XzKPU) (total 28533 images) for academic use.

After run `featureExtraction.m`, 

+ the piecewirse affine warpped images are generated in the folder ``morph_small/Images_normalized/``, 
+ the images with extracted features are generated in the folder ``morph_small/Images_withfeatures/``, 
+ and the extracted batch features in the `.mat` form are saved in the folder  ``morph_small/features_mat0/``.


## collect all extracted features in a single `.mat` file
`append_features.m` 

If the images dataset is very large, it may take a long time to train.
So you can partition the datasets into multiple parts, and train each part separately. Just remember rename the destination folder, like `features_mat0`, `features_mat1`, `features_mat2`, `features_mat3`.

Then run the `append_features.m` script.

This script will collect all features from batch features into a single `.mat` file, `Allfeatures.mat`.

## age classification
`main.m`

After run `featureExtraction.m` and `append_features.m`, the features are generated in `Allfeatures.mat`.

Then run `main.m`.

The script `main.m` train and test a classification model using `Allfeatures.mat`.

Set `is_partition_dataset == 1` when first runs to generate `trainset.mat` and `testset.mat`. 

Set `is_svmtrain == 1` and set `svm_type= 0 or 1 or 2` to train a svr model.

Set `is_svmtest == 1`  to test the model.


## test images 

**test_images.m** script predicts the age from images.



## Report

REPORT is given: [age_estimation_report.pdf](https://github.com/huajh/Age_Estimation_via_fastAAMs/blob/master/age_estimation_report.pdf)


## Reference

[1] Xin Geng, Zhi-Hua Zhou, and Kate Smith-Miles. Automatic age estimation based on facial aging patterns. Pattern Analysis and Machine Intelligence, IEEE Transactions on, 29(12):2234–2240,2007.

[2] Georgios Tzimiropoulos and Maja Pantic. Optimization problems for fast aam fitting in-thewild. In Computer Vision (ICCV), 2013 IEEE International Conference on, pages 593–600.IEEE, 2013. http://www.mathworks.com/matlabcentral/fileexchange/44651-active-appearance-models--aams-

[3] Khoa Luu, Karl Ricanek, Tien D Bui, and Ching Y Suen. Age estimation using active appearance models and support vector machine regression. In Biometrics: Theory, Applications, and Systems, 2009. BTAS’09. IEEE 3rd International Conference on, pages 1–5.IEEE, 2009.

[4] Ricanek, Karl, and Tamirat Tesafaye. "Morph: A longitudinal image database of normal adult age-progression." Automatic Face and Gesture Recognition, 2006. FGR 2006. 7th International Conference on. IEEE, 2006.



___________

Contact: huajh7@gmail.com

2014/6/19


