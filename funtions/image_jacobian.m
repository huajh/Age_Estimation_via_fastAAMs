function G = image_jacobian(gx, gy, j, nop)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%G = IMAGE_JACOBIAN(GX, GY, J, NOP)
% This function computes the jacobian G of warped image wrt parameters. 
% This matrix depends on the gradient of warped image, as 
% well as of the jacobian J of the warp transform wrt parameters. 
% For a detailed definition of matrix G, see Evangelidis & Psarakis paper.
%
% Input variables:
% GX:           the warped image gradient in x (horizontal) deirection,
% GY:           the warped image gradient in y (horizontal) deirection,
% J:            the jacobian matrix J of warp transform wrt parameters,
% NOP:          the number of parameters.
%
% Output:
% G:            The jacobian matrix G.
%--------------------------------------
% $ Ver: 1.0.0, 1/3/2010,  released by Georgios D. Evangelidis, Fraunhofer IAIS.
% For any comment, please contact georgios.evangelidis@iais.fraunhofer.de
% or evagelid@ceid.upatras.gr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[h,w]=size(gx);

if nargin<4
    error('Not enough input arguments');
end

gx=repmat(gx,1,nop);
gy=repmat(gy,1,nop);

G=gx.*j(1:h,:)+gy.*j(h+1:end,:);
G=reshape(G,h*w,nop);