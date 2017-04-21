
% test for extra images

% The following *.mat are required.
% cAAM.mat;
% meanscl.mat;
% meantrans.mat;
% svr_poly_model.mat
clear all;

% using svr model with polynomial kernel 
load('svr_poly_model.mat');
    
names1 = dir('test_images/*.jpg');    
image_num = length(names1);
featsize = 200;
gndtruth_ages = zeros(image_num,1);
pred_ages = zeros(image_num,1);
for i = 1:image_num
    tic;
    input_image = imread(['test_images/' names1(i).name]);
    feature = feature_extract(input_image);
    gndtruth_ages(i) = str2num(names1(i).name(end-5:end-4));
    pred_ages(i) =svmpredict(gndtruth_ages(i),feature',svr_model);    
    toc;
end
error = abs(pred_ages-gndtruth_ages);
hist(error);
MAE = mean(error);
title(['MAE = ',num2str(MAE)]);


