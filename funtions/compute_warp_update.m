function s = compute_warp_update(current_shape, delta, shape, coord_frame)

num_of_similarity_eigs = shape.num_of_similarity_eigs;
s0 = shape.s0;
S = shape.S;
Q = shape.Q; 
triangles = coord_frame.triangles;
triangles_per_point = coord_frame.triangles_per_point;

% Get dr and dp, and compute ds0
dr = -delta(1:num_of_similarity_eigs);
dp = -delta(num_of_similarity_eigs + 1:end);
ds0 =  S * dp + Q * dr;
ds0 = reshape(ds0, [], 2);

% Compose new delta with current shape
s_new = compute_warp_composition(s0, ds0, current_shape, triangles, triangles_per_point);

% Project and reconstuct to get final shape
r = Q' * (s_new(:) - s0(:));
p = S'* (s_new(:) - s0(:));
s = s0(:) + S * p + Q * r;
s = reshape(s, [], 2);


