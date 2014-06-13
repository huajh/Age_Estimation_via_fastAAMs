function [dW_dp, triangles_per_point] = create_warp_jacobian(coord_frame, shape)
% based on code from Octaam. Thank you for this!

base_shape = coord_frame.base_shape;
base_texture = coord_frame.base_texture;
triangles = coord_frame.triangles;
resolution = coord_frame.resolution;
num_of_points = size(base_shape, 1);

dW_dxy = zeros(resolution(1), resolution(2), num_of_points);

% for each point
for k = 1:num_of_points
    % Find triangles per each point
    [triangles_per_point{k}, ~] = find(triangles == k);
    
    % for each triangle of this point
    for i = 1:length(triangles_per_point{k})
        
        t = triangles_per_point{k}(i);
        
        % Sort the point list in order to have v0 in correspondance to the derivative of warp w.r.t. (x,y)
        tt = triangles(t,:);
        v = [tt(tt == k), tt(tt ~= k)];
        
        dx = zeros(resolution(1), resolution(2));
        
        % Identify each pixel belonging to the triangle t
        [y,x] = find(base_texture == t);
        v0x = base_shape(v(1), 1);
        v0y = base_shape(v(1), 2);
        v1x = base_shape(v(2), 1);
        v1y = base_shape(v(2), 2);
        v2x = base_shape(v(3), 1);
        v2y = base_shape(v(3), 2);
        
        % Compute dW / dx(i) and dW/dy(i)
        denominator = (v1x - v0x) * (v2y - v0y) - (v1y - v0y) * (v2x - v0x);
        alpha = (x - v0x) * (v2y - v0y) - (y - v0y) * (v2x - v0x);
        beta = (y - v0y) * (v1x - v0x) - (x - v0x) * (v1y - v0y);
        dx(sub2ind([resolution(1) resolution(2)],y,x)) = (1 - alpha/denominator - beta/denominator);
        
        dW_dxy(:, :, k) = dW_dxy(:, :, k) + dx;
    end
    
end

% Compute Wx/dp and Wy/dp
dx_dp = [shape.Q, shape.S];

Wx_dp = reshape(dW_dxy,[],num_of_points) * dx_dp(1:num_of_points,:);
Wy_dp = reshape(dW_dxy,[],num_of_points) * dx_dp(num_of_points+1:end,:);

Wx_dp = reshape(Wx_dp, resolution(1), resolution(2), size(Wx_dp, 2));
Wy_dp = reshape(Wy_dp, resolution(1), resolution(2), size(Wy_dp, 2));

dW_dp = [Wx_dp; Wy_dp];