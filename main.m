clear all; close all; 
if_hist_age = 0;
if_partition_dataset = 0;
if_knntrain = 0;
if_knntest = 0;
if_svmtrain =0;
if_svmtest = 0;
if_svm_mixed = 0;
if_test_image = 1;

addpath funtions;

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
    MAE = mean(error);
    fprintf('mean_abs_error: %.2f\n',MAE);
    hist(error,20);  
    title(['MAE = ',num2str(MAE)]);
    save('knnError.mat','error','MAE');
end

if if_svmtrain == 1    
    trainfeatures = trainset.features(1:5:end,:);
    trainage = trainset.age(1:5:end)';
    train_num = length(trainage);
    if if_svm_mixed == 1
        % 0  - 30
        % 31 - 45
        % 46 - 
        [~,child_idx] = find(trainage'<=30); 
        [~,adult_idx] = find(trainage'>30 & trainage'<=45 ); 
        [~,old_idx]   = find(trainage'>45);
        trainIDX = ones(train_num,1);
        trainIDX(adult_idx) = 2;
        trainIDX(old_idx) = 3;

        % classifcation: chlid, adult, old
        classify_svm = svmtrain(trainIDX,trainfeatures,'-t 2');

        %regresssion    
        child_svr = svmtrain(trainage(child_idx),trainfeatures(child_idx,:),'-s 3 -t 2');
        adult_svr = svmtrain(trainage(adult_idx),trainfeatures(adult_idx,:),'-s 3 -t 2');
        old_svr   = svmtrain(trainage(old_idx),trainfeatures(old_idx,:),'-s 3 -t 2');    
        save('svm_model.mat','classify_svm','child_svr','adult_svr','old_svr');
    else
        tic
        svr_model = svmtrain(trainage,trainfeatures,'-s 3 -t 2 -h 0');
        toc
        save('svr_rbf_model.mat','svr_model');
    end
else 
    load('svr_rbf_model.mat');
    %load('svr_poly_model.mat');
end

if if_svmtest == 1
    testfeatures = testset.features(1:end,:);
    testage = testset.age(1:end)';    
    test_num = length(testage);    
    if if_svm_mixed ==1
        [~,child_idx] = find(testage'<=30); 
        [~,adult_idx] = find(testage'>30 & testage'<=45); 
        [~,old_idx]   = find(testage'>45);
        testIDX = ones(test_num,1);
        testIDX(adult_idx) = 2;
        testIDX(old_idx) = 3;

        which_part = svmpredict(testIDX,testfeatures,classify_svm);    
        [~,child_idx] = find(which_part==1);
        [~,adult_idx] = find(which_part==2);
        [~,old_idx] = find(which_part==3);

        pred_age = ones(test_num,1);
        age1 =svmpredict(testage(child_idx),testfeatures(child_idx,:),child_svr); 
        age2 =svmpredict(testage(adult_idx),testfeatures(adult_idx,:),adult_svr); 
        age3 =svmpredict(testage(old_idx),testfeatures(old_idx,:),old_svr);       
        pred_age(child_idx) = age1;
        pred_age(adult_idx) = age2;
        pred_age(old_idx)   = age3;
    else     
        tic;
        pred_age =svmpredict(testage,testfeatures,svr_model); 
        toc;
    end
    
    error = abs(pred_age-testage);
    MAE = mean(error);
    fprintf('mean_abs_error: %.2f\n',MAE);
    hist(error,20);
    title(['MAE = ',num2str(MAE)]);
   % save('svr_poly_Error.mat','error','MAE');
    save('svr_rbf_Error.mat','error','MAE');
end

if if_test_image == 1
    where = 'morph_small';    
    names1 = dir([where '/test_images/*.jpg']);    
    image_num = length(names1)
    error = zeros(image_num,1);
    for i = 1:image_num
		tic;
        input_image = imread([where '/' 'test_images/' names1(i).name]);
        trueage = str2num(names1(i).name(end-5:end-4));        
        pred_age = ageestimation(input_image);
        error(i) = abs(pred_age-trueage);
		toc;
    end
    hist(error);
    MAE = mean(error);
    title(['MAE = ',num2str(MAE)]);
    save('svr_test_error.mat','error','MAE');
end




