clear all; close all; 
if_hist_age = 0;
if_partition_dataset = 0;
if_knntrain = 0;
if_knntest = 1;

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
    hist(error,maxage-minage+1);
end






