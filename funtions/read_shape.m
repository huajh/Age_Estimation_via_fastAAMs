function [shape] = read_shape(shape_path, n_vertices)

filename = shape_path;
fid=fopen(filename, 'r');
str = fread(fid);
str = char(str);
str = str';
fclose(fid);

num = readnumber(str);
shape = zeros(n_vertices,2);
for i = 1:floor(n_vertices)
    shape(i,2) = num(2*i);
    shape(i,1) = num(2*i-1);    
end;