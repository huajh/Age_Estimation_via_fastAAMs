function [feature] = feature_extract(input_image)
    
% input: N x M x 3 or N x M gray images
% output: 200 x 1

    load cAAM.mat;
    load meanscl.mat;
    load meantrans.mat;
    
    addpath funtions    
   
    pts = cAAM.shape{1}.s0;
    meanlandmarkcenter = mean(pts,1);
    landmarksize = (max(pts(:,1)) - min(pts(:,1))) * (max(pts(:,2)) - min(pts(:,2)));

    faceDetector = vision.CascadeObjectDetector();
    bbox= step(faceDetector, input_image);
    feature = [];
    num_of_scales_used = length(cAAM.scales);
    num_of_iter = [50 50];
    
    if length(bbox) == 4
        facesize = bbox(3)*bbox(4);
        facecenter = [bbox(1)+0.5*bbox(3) bbox(2)+0.5*bbox(4)];
        scl = sqrt(facesize*meanscl/landmarksize);
        trans = facecenter+meantrans*bbox(3)-scl*meanlandmarkcenter;
        if size(input_image, 3) == 3
            input_image = double(rgb2gray(input_image));
        else
            input_image = double(input_image);
        end

        %% initialization
        s0 = cAAM.shape{1}.s0;
        current_shape = scl*reshape(s0, cAAM.num_of_points, 2) + repmat(trans, cAAM.num_of_points, 1);
        input_image = imresize(input_image, 1/scl);
        current_shape = (1/scl)*(current_shape);

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
        I = Iw(:); I(ind_out) = [];
        feature = A'*(I - A0);
    end       
end