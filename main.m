clear all; close all; 
if_hist_age = 0;
if_partition_dataset = 0;
if_knntrain = 0;
if_knntest = 0;
if_svmtrain = 1;
if_svmtest = 1;

if if_hist_age == 1
    load('Allfeatures.mat');
    featureSize = length(AllFeatures);
    ageHist = zeros(featureSize,1);
    for i =1:featureSize
        ageHist(i) = AllFeatures(i).age;
    end
    hist(ageHist);
end
% partition the dataset into trainset and testset
if if_partition_dataset == 1
    load('Allfeatures.mat');
    featureSize = length(AllFeatures);
    for i=1:featureSize
        UserfulData.age(i) = AllFeatures(i).age;
        UserfulData.features(i,:) = AllFeatures(i).features;
    end        
    mask = 1:featureSize;
    idx = find(mod(mask,6)~=0);
    idx2 = find(mod(mask,6)==0);
    trainset.age = UserfulData.age(idx); 
    trainset.features = UserfulData.features(idx,:);
    testset.age  = UserfulData.age(idx2);    
    testset.features = UserfulData.features(idx2,:);
    save UserfulData.mat UserfulData
    save trainset.mat trainset
    save testset.mat testset
else
    load trainset.mat
    load testset.mat
end

%simplest knn train
if if_knntrain == 1
    minage = min(trainset.age);
    maxage = max(trainset.age);
    dim = size(trainset.features,2);
    feature_means = zeros(maxage-minage+1,dim);
    for i = 1:maxage-minage+1
        idx = find(trainset.age(:) == i);
        feature_means(i,:) = mean(trainset.features(idx,:));    
    end
    save('TrainedParameters','feature_means','minage','maxage');
else
    load('TrainedParameters','feature_means','minage','maxage');
end

%knntest find minimum distance
if if_knntest == 1    
    test_num = length(testset.features);
    pred_age = zeros(1,test_num);
    for i = 1:test_num
        dist = zeros(maxage-minage+1,1);
        for j=1:maxage-minage+1
            dist(j) = sum((testset.features(i,:)-feature_means(j,:)).^2);                
        end
        [~,idx] = min(dist);
        pred_age(i) = idx+minage-1;
    end    
    error = abs(pred_age-testset.age);
    mean_abs_error = mean(error);
    fprintf('mean_abs_error: %.2f\n',mean_abs_error);
    hist(error,maxage-minage+1);    
end

if if_svmtrain == 1
    train_num = length(trainset.features);
    % 0  - 20
    % 21 - 50
    % 50 - 
    [~,child_idx] = find(trainset.age<=20); 
    [~,adult_idx] = find(trainset.age>20 & trainset.age<=50 ); 
    [~,old_idx]   = find(trainset.age>50);
    trainIDX = ones(train_num,1);
    trainIDX(adult_idx) = 2;
    trainIDX(old_idx) = 3;
    
    % classifcation: chlid, adult, old
    classify_svm = svmtrain(trainIDX,trainset.features,'-t 2');
    
    %regresssion    
    child_svm = svmtrain(trainset.age(child_idx),trainset.age(child_idx,:),'-s 3 -t 2');
    adult_svm = svmtrain(trainset.age(adult_idx),trainset.age(adult_idx,:),'-s 3 -t 2');
    old_svm   = svmtrain(trainset.age(old_idx),trainset.age(old_idx,:),'-s 3 -t 2');    
    save('svm_model.mat','classify_svm','child_svm','adult_svm','old_svm');
else 
    load('svm_model.mat');
end

if if_svmtest == 1
    test_num = length(testset.features);
    
    [~,child_idx] = find(testset.age<=20); 
    [~,adult_idx] = find(testset.age>20 && testset.age<=50); 
    [~,old_idx]   = find(testset.age>50);
    testIDX = ones(test_num,1);
    testIDX(adult_idx) = 2;
    testIDX(old_idx) = 3;
    
    which_part = svmpredict(testIDX,testset.features,classify_svm);    
    [~,child_idx] = find(which_part==1);
    [~,adult_idx] = find(which_part==2);
    [~,old_idx] = find(which_part==3);
    
    pred_age = ones(test_num,1);
    pred_age(child_idx) =svmpredict(testset.age(child_idx),testset.features,child_svm); 
    pred_age(adult_idx) =svmpredict(testset.age(adult_idx),testset.features,adult_svm); 
    pred_age(old_idx) =svmpredict(testset.age(old_idx),testset.features,old_svm);             
    
    error = abs(pred_age-testset.age);
    mean_abs_error = mean(error);
    fprintf('mean_abs_error: %.2f\n',mean_abs_error);
    hist(error);
    
end






