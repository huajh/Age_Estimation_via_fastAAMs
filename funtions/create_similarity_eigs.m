function [S Q] = create_similarity_eigs(s0, S)

num_of_points = size(s0, 1);
num_of_similarity_eigs = 4;
Q = zeros(num_of_points*2, num_of_similarity_eigs);

% Parameterizing a global 2D similarity transform
Q(:,1) = [ s0(:,1); s0(:,2)];
Q(:,2) = [-s0(:,2); s0(:,1)];
Q(:,3) = [ones(num_of_points, 1); zeros(num_of_points, 1)];
Q(:,4) = [zeros(num_of_points, 1); ones(num_of_points, 1)];

% Orthogonalization of all eigenevectors
Q = gs_orthonorm(Q);
S_all = gs_orthonorm([Q, S]);
Q = S_all(:, 1:size(Q, 2));
S = S_all(:, size(Q, 2)+1:end);
