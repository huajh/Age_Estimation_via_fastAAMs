function [U Lambda] = myPCA(Z, K)

if size(Z, 1)<size(Z, 2)
    B = Z*(Z');
    [evec, eval] = eigen(B);
    p = min([length(eval), K, size(Z, 1), size(Z, 2)]);
    U = evec(:,1:p);  
else
    B = (Z'*Z);
    [evec, eval] = eigen(B);
    p = min([length(eval), K, size(Z, 1), size(Z, 2)]);
    U = Z*evec(:,1:p)*diag(eval(1:p).^(-1/2));
end

Lambda = eval(1:p);

end

function [U, Lambda] = eigen(A)

[U, Lambda] = eig(A);
Lambda = diag(Lambda);
[Lambda, ind] = sort(Lambda, 'descend');
U = U(:,ind);

end
