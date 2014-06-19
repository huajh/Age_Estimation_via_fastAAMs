Age Estimation based on Support Vector Regression	
===========================
machine learning homework: Age Estimation

#Code Description#

the function interface (ageestimation.m): 

	[ pred_age ] = ageestimation( image )  
	
	required files: /functions, cAAA.mat, meanscl.mat, meantrans.mat, svr_poly_model.mat


other code:

	1. featureExtraction.m & append_features.m : extract feature and modify the data structure
	
	2. main.m: train support vector regression model
	
	3. test_image.m: test the function interface
	
	4. checknumericargs.m, ticstatus.m, tocstatus.m (just for convenience) : Used to display the progress of a long process
	

#Main Reference#

[1] Xin Geng, Zhi-Hua Zhou, and Kate Smith-Miles. Automatic age estimation based on facial aging patterns. Pattern Analysis and Machine Intelligence, IEEE Transactions on, 29(12):2234–2240,2007.

[2] Georgios Tzimiropoulos and Maja Pantic. Optimization problems for fast aam fitting in-thewild.
In Computer Vision (ICCV), 2013 IEEE International Conference on, pages 593–600.IEEE, 2013.
http://www.mathworks.com/matlabcentral/fileexchange/44651-active-appearance-models--aams-

[3] Khoa Luu, Karl Ricanek, Tien D Bui, and Ching Y Suen. Age estimation using active appearance models and support vector machine regression. In Biometrics: Theory, Applications, and Systems, 2009. BTAS’09. IEEE 3rd International Conference on, pages 1–5.IEEE, 2009.

DATASET: MORPH
------

Ricanek, Karl, and Tamirat Tesafaye. "Morph: A longitudinal image database of normal adult age-progression." Automatic Face and Gesture Recognition, 2006. FGR 2006. 7th International Conference on. IEEE, 2006.

___________

Contact: huajh7@gmail.com

2014/6/19



