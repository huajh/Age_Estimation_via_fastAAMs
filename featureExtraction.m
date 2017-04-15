clear; clc; close all;
addpath funtions

%% train the model
flag_train = 0;
%When flag_train is set to 0, the training process of the AAM model will be omitted. 
flag_precalibration = 0;
%When flag_precalibration is set to 0, the precalibration process is
%omitted. 

where = 'morph_small';
what = 'jpg';
folder = 'trainset';
AAM.num_of_points = 68;
% scales refers to the resolution that fitting is taking place.
% if scale is 1, then we fit in 1/(2^(1-1)) = 1 i.e. in the original image resolution
% if scale is 2, then we fit in 1/(2^(2-1)) = 1/2 i.e. half the original resolution
% Multi-resolution fitting is a heuristic for improving fitting.
AAM.scales = [1 2];
% max_n and max_m refers to the number of components
% that we keep after we apply PCA on the similarity-free shapes and shape-free textures
AAM.shape.max_n = 136;
num_of_scales = length(AAM.scales);
AAM.texture = cell(1, num_of_scales);
for ii = 1:num_of_scales
    AAM.texture{ii}.max_m = 550;
end

% Create the AAM
if flag_train
    AAM = train_AAM(where, folder, what, AAM);
    save([where '/' folder '/AAM.mat'], 'AAM');
else
    load([where '/' folder '/AAM.mat']);
end

%% Precompute
% This step precomputes all precomputable quantities required during fitting
% should you change any of the parameters below, set flag_precompute = 1;
% The code below creates a "chopped AAM" used in Fast-SIC algorithm
% n_all and m refers to the number of model parameters
% i.e. the number of components for the shape and texture model that we use for fitting
% at each scale (these are usually much smaller than AAM.shape.max_n
% and AAM.texture{ii}.max_m). So these are the total number of
% parameters that Fast-SIC algorithm is aimed to recover. In the example below we fit
% n_all = 3+4 shapes in half resolution and n_all = 10+4 shapes in the original resolution.
% 4 is the number of similarity eigenvectors and is always fixed.
% Exactly the same applies for the texture parameters.
flag_precompute = 0;
if flag_train
    flag_precompute = 1;
end

if flag_precompute
    if ~flag_train
        load([where '/' folder '/AAM.mat']);
    end
    cAAM.shape{1}.n = 10;
    cAAM.shape{2}.n = 3;
    cAAM.shape{1}.num_of_similarity_eigs = 4;
    cAAM.shape{2}.num_of_similarity_eigs = 4;
    cAAM.shape{1}.n_all = cAAM.shape{1}.n + cAAM.shape{1}.num_of_similarity_eigs;
    cAAM.shape{2}.n_all = cAAM.shape{2}.n + cAAM.shape{2}.num_of_similarity_eigs;
    
    cAAM.texture{1}.m = 200;
    cAAM.texture{2}.m = 50;
    cAAM.num_of_points = AAM.num_of_points;
    cAAM.scales = AAM.scales;
    cAAM.coord_frame = AAM.coord_frame;
    
    for ii = 1:num_of_scales
        % shape
        cAAM.shape{ii}.s0 = AAM.shape.s0;
        cAAM.shape{ii}.S = AAM.shape.S(:, 1:cAAM.shape{ii}.n);
        cAAM.shape{ii}.Q = AAM.shape.Q;
        
        % texture
        cAAM.texture{ii}.A0 = AAM.texture{ii}.A0;
        cAAM.texture{ii}.A = AAM.texture{ii}.A(:, 1:cAAM.texture{ii}.m);
        cAAM.texture{ii}.AA0 = AAM.texture{ii}.AA0;
        cAAM.texture{ii}.AA = AAM.texture{ii}.AA(:, 1:cAAM.texture{ii}.m);
        
        % warp jacobian
        [cAAM.texture{ii}.dW_dp, cAAM.coord_frame{ii}.triangles_per_point] = create_warp_jacobian(cAAM.coord_frame{ii}, cAAM.shape{ii});
    end
    save([where '/' folder '/cAAM.mat'], 'cAAM');
    
else
    load([where '/' folder '/cAAM.mat']);
end

%% fitting related parameters
num_of_scales_used = length(cAAM.scales);
num_of_iter = [50 50];

%% get images and ground truth shapes
 where =  'morph_small';
 folder = 'trainset';

%% landmark initializations
if flag_precalibration == 1
   [meanscl, meantrans] = calculateParameters(where, folder);
   save meanscl.mat meanscl;
   save meantrans.mat meantrans;
else    
   load meanscl.mat;
   load meantrans.mat;
end

names1 = dir([where '/Images_ori/*.jpg']);
ExtractedFeatures = struct('name', [], 'scl', [], 'trans', [], 'features', []);
pts = cAAM.shape{1}.s0;
meanlandmarkcenter = mean(pts,1);
landmarksize = (max(pts(:,1)) - min(pts(:,1))) * (max(pts(:,2)) - min(pts(:,2)));

%The following is to test the AAM model fitting on the test images. 
images_idx = 0;
feature_batch = 0;

ticstatusid = ticstatus('feature Extraction',[],10 );

for cnt = 1:length(names1)
    
    tocstatus( ticstatusid, cnt/(length(names1)) ); 
    
    input_image = imread([where '/' 'Images_ori/' names1(cnt).name]);    
    faceDetector = vision.CascadeObjectDetector();
    bbox= step(faceDetector, input_image);
    %
    % feature struct(files):
    %   name
    %   scl
    %   trans
    %   features
    %
    if length(bbox) == 4
        images_idx = images_idx+1;
        ExtractedFeatures(images_idx).name = [where '/' 'Images_ori/' names1(cnt).name];
        facesize = bbox(3)*bbox(4);
        facecenter = [bbox(1)+0.5*bbox(3) bbox(2)+0.5*bbox(4)];
        ExtractedFeatures(images_idx).scl = sqrt(facesize*meanscl/landmarksize);
        ExtractedFeatures(images_idx).trans = facecenter+meantrans*bbox(3)-ExtractedFeatures(images_idx).scl*meanlandmarkcenter;
        if size(input_image, 3) == 3
            input_image = double(rgb2gray(input_image));
        else
            input_image = double(input_image);
        end

       %% initialization
        s0 = cAAM.shape{1}.s0;
        current_shape = ExtractedFeatures(images_idx).scl*reshape(s0, cAAM.num_of_points, 2) + repmat(ExtractedFeatures(images_idx).trans, cAAM.num_of_points, 1);
        input_image = imresize(input_image, 1/ExtractedFeatures(images_idx).scl);
        current_shape = (1/ExtractedFeatures(images_idx).scl)*(current_shape);

        %% Fitting an AAM using Fast-SIC algorithm
        sc = 2.^(cAAM.scales-1);
        for ii = num_of_scales_used:-1:1
            current_shape = current_shape /sc(ii);

            % indices for masking pixels out
            ind_in = cAAM.coord_frame{ii}.ind_in;
            ind_out = cAAM.coord_frame{ii}.ind_out;
            ind_in2 = cAAM.coord_frame{ii}.ind_in2;
            ind_out2 = cAAM.coord_frame{ii}.ind_out2;
            resolution = cAAM.coord_frame{ii}.resolution;

            A0 = cAAM.texture{ii}.A0;
            A = cAAM.texture{ii}.A;
            AA0 = cAAM.texture{ii}.AA0;
            AA = cAAM.texture{ii}.AA;

            for i = 1:num_of_iter(ii)
                % Warp image
                Iw = warp_image(cAAM.coord_frame{ii}, current_shape*sc(ii), input_image);
                I = Iw(:); I(ind_out) = [];
                II = Iw(:); II(ind_out2) = [];

                % compute reconstruction Irec
                if (i == 1)
                    c = A'*(I - A0) ;
                else
                    c = c + dc;
                end
                Irec = zeros(resolution(1), resolution(2));
                Irec(ind_in) = A0 + A*c;

                % compute gradients of Irec
                [Irecx Irecy] = gradient(Irec);
                Irecx(ind_out2) = 0; Irecy(ind_out2) = 0;
                Irec(ind_out2) = [];
                Irec = Irec(:);

                % compute J from the gradients of Irec
                J = image_jacobian(Irecx, Irecy, cAAM.texture{ii}.dW_dp, cAAM.shape{ii}.n_all);
                J(ind_out2, :) = [];

                % compute Jfsic and Hfsic
                Jfsic = J - AA*(AA'*J);
                Hfsic = Jfsic' * Jfsic;
                inv_Hfsic = inv(Hfsic);

                % update
                dqp = inv_Hfsic * Jfsic'*(II-AA0);
                dc = AA'*(II - Irec - J*dqp);

                % This function updates the shape in an inverse compositional fashion
                current_shape =  compute_warp_update(current_shape, dqp, cAAM.shape{ii}, cAAM.coord_frame{ii});
            end
            current_shape(:,1) = current_shape(:, 1) * sc(ii) ;
            current_shape(:,2) = current_shape(:, 2) * sc(ii) ;
        end
        Iw = warp_image(cAAM.coord_frame{ii}, current_shape*sc(ii), input_image);
        imwrite(uint8(Iw), [where,'/Images_normalized/', names1(cnt).name], 'jpeg');
        I = Iw(:); I(ind_out) = [];
        ExtractedFeatures(images_idx).features = A'*(I - A0) ;
        current_shape = current_shape*ExtractedFeatures(images_idx).scl;
        A =  imread([where '/Images_ori/' names1(cnt).name]);  
        for ii = 1:length(current_shape)
            x = round(current_shape(ii,2));
            y = round(current_shape(ii,1));
            A = drawpoint(A,x,y,'red',5);
        end
        imwrite(uint8(A),[where, '/Images_withfeatures/', names1(cnt).name], 'jpeg');        
    end;
    if(mod(cnt,200)==0)
        feature_batch = feature_batch + 1;
        save(['./',where,'/features_mat0/','ExtractedFeatures_',num2str(feature_batch),'.mat'],'ExtractedFeatures');
        clear ExtractedFeatures;
        images_idx = 0;
        ExtractedFeatures = struct('name', [], 'scl', [], 'trans', [], 'features', []);
    end
end;
