function [ pred_ages ] = ageestimation( features )
%AGEESTIMATION Summary of this function goes here
%
%   @author: Junhao Hua
%   @Contact: huajh7@gmail.com
%
%   2014/6/14
%   Latest update: 2014/6/23
%
%   features  N x 200 
%
    load('svr_poly_model.mat');	
	%addpath svm_func
    N = size(features,1);    
    pred_ages =svmpredict(zeros(N,1),features,svr_model);
    pred_ages = round(pred_ages);
end
