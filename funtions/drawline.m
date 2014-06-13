function A=drawline(A,x1,y1,x2,y2,id,thickness)
if nargin==5
    id ='red';
    thickness=1;
elseif nargin==6
    thickness=1;
end;
a1=floor(thickness/2);
a2=thickness-1-a1;
A=double(A);
if length(size(A))==2
    [M,N]=size(A);
    P=zeros(M,N,3);
    P(:,:,1)=A(:,:);
    P(:,:,2)=A(:,:);
    P(:,:,3)=A(:,:);
    A=P;
end;
[M,N,P]=size(A);
if abs(x1-x2)>abs(y1-y2)
    if x1>x2
        a=x1;
        x1=x2;
        x2=a;
        a=y1;
        y1=y2;
        y2=a;
    end;
    slope=(y2-y1)/(x2-x1);
    for i=x1:x2
        j=round(y1+slope*(i-x1));
        if strcmp(id,'red')
            for u=i-a1:i+a2
                for v=j-a1:j+a2
                    if u>=0 & u<=M & v>=1 & v<=N
                        A(u,v,1)=255;
                        A(u,v,2)=0;
                        A(u,v,3)=0;
                    end;
                end;
            end;
        elseif strcmp(id,'green')
             for u=i-a1:i+a2
                for v=j-a1:j+a2
                    if u>=0 & u<=M & v>=1 & v<=N
                        A(u,v,1)=0;
                        A(u,v,2)=255;
                        A(u,v,3)=0;
                    end;
                end;
            end;
        elseif strcmp(id,'blue')
             for u=i-a1:i+a2
                for v=j-a1:j+a2
                    if u>=0 & u<=M & v>=1 & v<=N
                        A(u,v,1)=0;
                        A(u,v,2)=0;
                        A(u,v,3)=255;
                    end;
                end;
            end;
        else
            for u=i-a1:i+a2
                for v=j-a1:j+a2
                    if u>=0 & u<=M & v>=1 & v<=N
                        A(u,v,1)=0;
                        A(u,v,2)=0;
                        A(u,v,3)=0;
                    end;
                end;
            end;
        end;
    end;
else
    if y1>y2
        a=x1;
        x1=x2;
        x2=a;
        a=y1;
        y1=y2;
        y2=a;
    end;
    slope=(x2-x1)/(y2-y1);
    for j=y1:y2
        i=round(x1+slope*(j-y1));
        if strcmp(id,'red')
             for u=i-a1:i+a2
                for v=j-a1:j+a2
                    if u>=1 & u<=M & v>=1 & v<=N
                        A(u,v,1)=255;
                        A(u,v,2)=0;
                        A(u,v,3)=0;
                    end;
                end;
            end;
        elseif strcmp(id,'green')
             for u=i-a1:i+a2
                for v=j-a1:j+a2
                    if u>=1 & u<=M & v>=1 & v<=N
                        A(u,v,1)=0;
                        A(u,v,2)=255;
                        A(u,v,3)=0;
                    end;
                end;
            end;
        elseif strcmp(id,'blue')
            for u=i-a1:i+a2
                for v=j-a1:j+a2
                    if u>=1 & u<=M & v>=1 & v<=N
                        A(u,v,1)=0;
                        A(u,v,2)=0;
                        A(u,v,3)=255;
                    end;
                end;
            end;
        else
             for u=i-a1:i+a2
                for v=j-a1:j+a2
                    if u>=1 & u<=M & v>=1 & v<=N
                        A(u,v,1)=0;
                        A(u,v,2)=0;
                        A(u,v,3)=0;
                    end;
                end;
            end;
        end;
    end;
end;
        
    
        
            
        


