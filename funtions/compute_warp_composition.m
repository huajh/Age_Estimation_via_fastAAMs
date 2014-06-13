function s_new = compute_warp_composition(s0, ds0, current_shape, triangles, triangles_per_point)
% based on code from Octaam. Thank you for this! 

s_new = zeros(size(s0));

for i = 1:size(s0, 1)
    tx = s0(i, 1) + ds0(i, 1);
    ty = s0(i, 2) + ds0(i, 2);
    
    this_triangle = triangles_per_point{i};
    
    if (isempty(this_triangle))
        continue;
    end
    
    v = zeros(length(this_triangle),2);
    
    for j = 1:length(this_triangle)
        trij = this_triangle(j);
        
        U = s0(triangles(trij, :), 1);
        V = s0(triangles(trij, :), 2);
        
        % X and Y coordinates of three vertices of each triangle in current_shape
        X = current_shape(triangles(trij, :), 1);
        Y = current_shape(triangles(trij, :), 2);
        
        denominator = (U(2) - U(1)) * (V(3) - V(1)) - (V(2) - V(1)) * (U(3) - U(1));
        
        a(1) = X(1) + ((V(1) * (U(3) - U(1)) - U(1)*(V(3) - V(1))) * (X(2) - X(1)) + (U(1) * (V(2) - V(1)) - V(1)*(U(2) - U(1))) * (X(3) - X(1))) / denominator;
        a(2) = ((V(3) - V(1)) * (X(2) - X(1)) - (V(2) - V(1)) * (X(3) - X(1))) / denominator;
        a(3) = ((U(2) - U(1)) * (X(3) - X(1)) - (U(3) - U(1)) * (X(2) - X(1))) / denominator;
        
        a(4) = Y(1) + ((V(1) * (U(3) - U(1)) - U(1) * (V(3) - V(1))) * (Y(2) - Y(1)) + (U(1) * (V(2) - V(1)) - V(1)*(U(2) - U(1))) * (Y(3) - Y(1))) / denominator;
        a(5) = ((V(3) - V(1)) * (Y(2) - Y(1)) - (V(2) - V(1)) * (Y(3) - Y(1))) / denominator;
        a(6) = ((U(2) - U(1)) * (Y(3) - Y(1)) - (U(3) - U(1)) * (Y(2) - Y(1))) / denominator;
        
        v(j,1) = a(1) + a(2) .* tx + a(3) .* ty;
        v(j,2) = a(4) + a(5) .* tx + a(6) .* ty;
        
        
    end
    s_new(i, :) = median(v);
end
