function A=drawpoint(A,x,y,id,thickness)
if nargin==3
    id='red';
    thickness=1;
elseif nargin==4
    thickness=1;
end;
A=double(A);
if length(size(A))==2
    [M,N]=size(A);
    B=zeros(M,N,3);
    B(:,:,1)=A;
    B(:,:,2)=A;
    B(:,:,3)=A;
    A=B;
end;
[M,N,P]=size(A);
p1=floor((thickness-1)/2);
p2=ceil((thickness-1)/2);
leftx=max(x-p1,1);
rightx=min(x+p2,M);
lefty=max(y-p1,1);
righty=min(y+p2,N);
if strcmp(id,'red')
    for i=leftx:rightx
        for j=lefty:righty
            A(i,j,1)=255;
            A(i,j,2)=0;
            A(i,j,3)=0;
        end;
    end;
elseif strcmp(id,'green')
    for i=leftx:rightx
        for j=lefty:righty
            A(i,j,1)=0;
            A(i,j,2)=255;
            A(i,j,3)=0;
        end;
    end;
elseif strcmp(id,'blue')
    for i=leftx:rightx
        for j=lefty:righty
            A(i,j,1)=0;
            A(i,j,2)=0;
            A(i,j,3)=255;
        end;
    end;
else
    for i=leftx:rightx
        for j=lefty:righty
            A(i,j,1)=255;
            A(i,j,2)=0;
            A(i,j,3)=0;
        end;
    end;
end;
    
            
            