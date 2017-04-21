clear all; close all; 
is_hist_age = 0;
is_partition_dataset = 0;
% is_knntrain = 0;
% is_knntest = 0;
is_svmtrain = 0; 

% 0 svm_mixed
% 1 svr rbf
% 2 svr poly
svm_type = 2; 

is_svmtest = 1;


addpath funtions;
addpath svm_func;

if is_hist_age == 1
    load('Allfeatures.mat');
    featureSize = length(AllFeatures);
    ageHist = zeros(featureSize,1);
    for i =1:featureSize
        ageHist(i) = AllFeatures(i).age;
    end
    hist(ageHist);
end
% partition the dataset into trainset and testset
if is_partition_dataset == 1
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
% if is_knntrain == 1
%     minage = min(trainset.age);
%     maxage = max(trainset.age);
%     dim = size(trainset.features,2);
%     feature_means = zeros(maxage-minage+1,dim);
%     for i = 1:maxage-minage+1
%         idx = find(trainset.age(:) == i);
%         feature_means(i,:) = mean(trainset.features(idx,:));    
%     end
%     save('TrainedParameters','feature_means','minage','maxage');
% else
%     load('TrainedParameters','feature_means','minage','maxage');
% end

%knntest find minimum distance
% if is_knntest == 1    
%     test_num = length(testset.features);
%     pred_age = zeros(1,test_num);
%     for i = 1:test_num
%         dist = zeros(maxage-minage+1,1);
%         for j=1:maxage-minage+1
%             dist(j) = sum((testset.features(i,:)-feature_means(j,:)).^2);                
%         end
%         [~,idx] = min(dist);
%         pred_age(i) = idx+minage-1;
%     end    
%     error = abs(pred_age-testset.age);
%     MAE = mean(error);
%     fprintf('mean_abs_error: %.2f\n',MAE);
%     hist(error,20);  
%     title(['MAE = ',num2str(MAE)]);
%     save('knnError.mat','error','MAE');
% end

if is_svmtrain == 1    
    trainfeatures = trainset.features(1:5:end,:);
    trainage = trainset.age(1:5:end)';
    train_num = length(trainage);
    if svm_type == 0
        % 0  - 30
        % 31 - 45
        % 46 - 
        [~,child_idx] = find(trainage'<=30); 
        [~,adult_idx] = find(trainage'>30 & trainage'<=45 ); 
        [~,old_idx]   = find(trainage'>45);
        trainIDX = ones(train_num,1);
        trainIDX(adult_idx) = 2;
        trainIDX(old_idx) = 3;
 
%         LIBSVM  svmtrain Option
%         
%         -s svm_type : set type of SVM (default 0)
%         0 -- C-SVC		(multi-class classification)
%         1 -- nu-SVC		(multi-class classification)
%         2 -- one-class SVM
%         3 -- epsilon-SVR	(regression)
%         4 -- nu-SVR		(regression)
%         -t kernel_type : set type of kernel function (default 2)
%         0 -- linear: u'*v
%         1 -- polynomial: (gamma*u'*v + coef0)^degree
%         2 -- radial basis function: exp(-gamma*|u-v|^2)
%         3 -- sigmoid: tanh(gamma*u'*v + coef0)
%         4 -- precomputed kernel (kernel values in training_instance_matrix)
%         -d degree : set degree in kernel function (default 3)
%         -g gamma : set gamma in kernel function (default 1/num_features)
%         -r coef0 : set coef0 in kernel function (default 0)
%         -c cost : set the parameter C of C-SVC, epsilon-SVR, and nu-SVR (default 1)
%         -n nu : set the parameter nu of nu-SVC, one-class SVM, and nu-SVR (default 0.5)
%         -p epsilon : set the epsilon in loss function of epsilon-SVR (default 0.1)
%         -m cachesize : set cache memory size in MB (default 100)
%         -e epsilon : set tolerance of termination criterion (default 0.001)
%         -h shrinking : whether to use the shrinking heuristics, 0 or 1 (default 1)
%         -b probability_estimates : whether to train a SVC or SVR model for probability estimates, 0 or 1 (default 0)
%         -wi weight : set the parameter C of class i to weight*C, for C-SVC (default 1)
%         -v n : n-fold cross validation mode
%         -q : quiet mode (no outputs)    

        % classifcation: chlid, adult, old
        classify_svm = svmtrain(trainIDX,trainfeatures,'-t 2'); % svm, rbf 

        %regresssion    
        child_svr = svmtrain(trainage(child_idx),trainfeatures(child_idx,:),'-s 3 -t 2'); % svr, rbf
        adult_svr = svmtrain(trainage(adult_idx),trainfeatures(adult_idx,:),'-s 3 -t 2'); % svr, rbf
        old_svr   = svmtrain(trainage(old_idx),trainfeatures(old_idx,:),'-s 3 -t 2');     % svr, rbf
        save('svm_model.mat','classify_svm','child_svr','adult_svr','old_svr');
    elseif svm_type == 1
            tic;
            svr_model = svmtrain(trainage,trainfeatures,'-s 3 -t 2 -h 0');  % svr, rbf shrinking                
            toc;        
            save('svr_rbf_model.mat','svr_model');
    elseif svm_type == 2
        tic;
        svr_model = svmtrain(trainage,trainfeatures,'-s 3 -t 1');  %svr, rbf 
        toc;   
        save('svr_poly_model.mat','svr_model');
    else
        printf('no such type!\n');
    end
else     
    if svm_type == 0
        load('svm_model.mat');
    elseif svm_type == 1        
        load('svr_rbf_model.mat');
    elseif svm_type == 2
        load('svr_poly_model.mat');
    else 
        printf('no such type!\n');
    end
end

if is_svmtest == 1
    testfeatures = testset.features(1:end,:);
    testage = testset.age(1:end)';    
    test_num = length(testage);    
    if svm_type == 0
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
    testage0 = round(testage);
    error = abs(pred_age-testage0);
    MAE = mean(error);
    fprintf('mean_abs_error: %.2f\n',MAE);
    nn = hist(error,max(error)-min(error)+1);
    cuml_score = cumsum(nn)/sum(nn);
    plot(0:length(cuml_score)-1,cuml_score);
    title(['MAE = ',num2str(MAE)]);
end



