function AAM = train_AAM(where, folder, what, AAM)

% function AAM = train_AAM(where, folder, what, AAM)
% Training an AAM consists of the following steps
% A. Read shapes and apply Procrustes to remove similarity transforms (scale-rotation-translation)
%    This step produces: (i) the mean shape and (ii) the similarity-free shapes
% B. Create shape model by appying PCA on the similarity-free shapes
% C. Create the coordinate frame of the AAM. This is where all calculations take place.
%    We create one coordinate frame for every scale (i.e resolution)
% D. Read images and warp them to mean shape using a piecewise affine warp. This will
%    create the shape-free textures
% E. Create texture model by appying PCA on the shape-free textures

num_of_scales = length(AAM.scales);
image_list = dir([where '/' folder '/*.' what]);
txt_files = dir([where '/' folder '/*.txt']);
num_of_samples = length(image_list);


%% A.Read shapes and Apply Procrustes to remove scale-rotation-translation from shapes
shapes = zeros(AAM.num_of_points, 2, num_of_samples);
for i=1:length(image_list)
    shapes(:,:,i) = read_shape([where '/' folder '/' txt_files(i).name], AAM.num_of_points);
end
% for cnt = 1:length(image_list);
%     A = imread([where '/' folder '/' image_list(cnt).name]);
%     for i = 1:size(shapes(:,:,cnt),1)
%         x = round(shapes(i,2,cnt));
%         y = round(shapes(i,1,cnt));
%         A = drawpoint(A,x,y,'blue',3);
%     end
%     imshow(A);
% end;
% shapes_normal: the similarity-free shapes
% AAM.s0: the mean shape
shapes_normal = Procrustes_analysis(shapes);
AAM.shape.s0 = mean(shapes_normal, 3);

%% B.Create the shape model
shapes_normal = reshape(shapes_normal, [], num_of_samples);
rep_s0 = repmat(AAM.shape.s0(:), 1, num_of_samples);
% apply PCA on similarity free shapes
S  =  myPCA(shapes_normal - rep_s0, AAM.shape.max_n);
% Create similarity eigs
[AAM.shape.S AAM.shape.Q] = create_similarity_eigs(AAM.shape.s0, S);


%% C.Create the coordinate frame of the AAM
% triangulated mesh is obtained using Delauny's method on the mean shape
triangles = delaunay(AAM.shape.s0(:,1), AAM.shape.s0(:,2));
for ii = 1:num_of_scales
    AAM.coord_frame{ii}.triangles  = triangles;
end

% create base shape and base texture, and masks for each resolution
sc = 2.^(AAM.scales-1);
for ii = 1:length(sc)
    s0_sc = AAM.shape.s0/sc(ii);
    
    % Create base shape: this is the mean shape scaled (for each resolution) 
    % and shifted so that all of its coordinates are positive
    mini = min(s0_sc(:, 1));
    minj = min(s0_sc(:, 2));
    maxi = max(s0_sc(:, 1));
    maxj = max(s0_sc(:, 2));
    AAM.coord_frame{ii}.base_shape = s0_sc - repmat([mini - 2, minj - 2], [AAM.num_of_points, 1]);
    
    AAM.coord_frame{ii}.resolution  = [ceil(maxj - minj + 3) ceil(maxi - mini + 3)];
    
    % base_texture is used to index all pixels in each triangle of base_shape efficiently.
    AAM.coord_frame{ii}.base_texture = create_texture_base(AAM.coord_frame{ii}.base_shape, AAM.coord_frame{ii}.triangles, AAM.coord_frame{ii}.resolution);
    
    % Masking: This is an implementation detail, but quite important.
    % When we warp the images to the mean shape below, we may want to mask out 1
    % boundary pixel. This is because there might be error in the annotations,
    % and usually boundary pixels might belong to the background of the
    % image and not the face.
    mask = AAM.coord_frame{ii}.base_texture; mask(mask>0) = 1; mask = double(mask);
    mask = imerode(mask, strel('square',3));
    AAM.coord_frame{ii}.mask = mask;
    AAM.coord_frame{ii}.ind_in = find(mask == 1);
    AAM.coord_frame{ii}.ind_out = find(mask == 0);
    
    % Also, when we compute the Jacobian of the template from gradT * [dW_dp]
    % using derivative operator [-1 0 1]/2, the gradient at the
    % boundary will be wrong. So we have to remove it. So mask2
    % removes one extra pixel
    mask2 = imerode(mask, strel('square', 3));
    AAM.coord_frame{ii}.mask2 = mask2;
    AAM.coord_frame{ii}.ind_in2 = find(mask2 == 1);
    AAM.coord_frame{ii}.ind_out2 = find(mask2 == 0);
end


%% D. Read images and get shape-free textures textures
textures = cell(1, num_of_scales);
for ii = 1:num_of_scales
    textures{ii} = zeros(length(AAM.coord_frame{ii}.ind_in), num_of_samples);
end
zeros(num_of_scales, length(image_list));
count = 0;
for jj = 1:length(image_list)
    I = imread([where '/' folder '/' image_list(jj).name]);
    if size(I, 3) == 3
        I = double(rgb2gray(I));
    else
        I = double((I));
    end
    current_shape(:, 1) = shapes(:, 1, jj);
    current_shape(:, 2) = shapes(:, 2, jj);
    
    count = count + 1;
    for ii = 1:num_of_scales
        try
            Iw = warp_image(AAM.coord_frame{ii}, current_shape, I);
            % mask out 1 boundary pixel
            Iw(AAM.coord_frame{ii}.ind_out) = 0;
            Iw(AAM.coord_frame{ii}.ind_out) = [];
            % check if warped data is fine
            temp = sum(isnan(Iw));
            % all images should be also in the range [0, 255]
            if ((temp == 0) && max(Iw) < 256)
                textures{ii}(:, count) = Iw;
            else
                textures{ii}(:, count) = zeros(size(Iw));
            end
            
        catch me
            aa = 1;
        end
    end
    
end

%% E. Create the texture model
for ii = 1:num_of_scales
    A0 = mean(textures{ii}, 2);
    textures{ii} = textures{ii} - repmat(A0, 1, size(textures{ii}, 2));
    AAM.texture{ii}.A0 = A0;
    AAM.texture{ii}.A  = myPCA(textures{ii}, AAM.texture{ii}.max_m);
    
    % During fitting we will need the subspace defined inside mask2 (i.e. after 
    % removing 1 additional pixel). We call this subspace AA. To compute AA
    % we remove 1 pixel from A and re-othormalise such that A^T  = A^(-1), and A^T*A = I.
    t = zeros(AAM.coord_frame{ii}.resolution(1)*AAM.coord_frame{ii}.resolution(2), 1);
    t(AAM.coord_frame{ii}.ind_in) = A0;
    U = zeros(AAM.coord_frame{ii}.resolution(1)*AAM.coord_frame{ii}.resolution(2), AAM.texture{ii}.max_m);
    for kk = 1:size(U, 2)
        U(AAM.coord_frame{ii}.ind_in, kk) = AAM.texture{ii}.A(:, kk);
    end
    t(AAM.coord_frame{ii}.ind_out2) = [];
    U(AAM.coord_frame{ii}.ind_out2, :) = [];
    U = gs_orthonorm(U);
    AAM.texture{ii}.AA0 = t;
    AAM.texture{ii}.AA = U;
end


function shapes_normal = Procrustes_analysis(shapes)
% align all shapes to the mean shape
% shapes_normal : aligned shapes

% Translate each shape to the origin
shapes_normal = shapes - repmat(mean(shapes, 1), size(shapes, 1), 1);
mean_shape = mean(shapes_normal, 3);

iteration = 0;
max_iteration = 100;

while (iteration<=max_iteration)
    % Align all shapes with current mean shape
    for i=1:size(shapes,3)
        [~, shapes_normal(:,:,i)] = procrustes(mean_shape, shapes_normal(:,:,i));
    end
    
    % Update mean shape
    mean_shape_new = mean(shapes_normal, 3);
    [~, mean_shape_new] = procrustes(mean_shape, mean_shape_new);
    mean_shape = mean_shape_new;
    
    iteration = iteration + 1;
end



function base_texture = create_texture_base(vertices, triangles, resolution)
% base_texture to warp image
base_texture = zeros(resolution(1), resolution(2));

for i=1:size(triangles,1)
    % vertices for each triangle
    X = vertices(triangles(i,:),1);
    Y = vertices(triangles(i,:),2);
    % mask for each traingle
    mask = poly2mask(X,Y,resolution(1), resolution(2)) .* i;
    % the complete base texture
    base_texture = max(base_texture, mask);
end

