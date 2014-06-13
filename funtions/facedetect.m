function files = facedetect(where, folder, meanshape, names3)

names1 = dir([where '/' folder '/*.jpg']);
names2 = dir([where '/' folder '/*.txt']);
facecenter = zeros(length(names1),2);
landmarkcenter = zeros(length(names2),2);
facesize = zeros(1,length(names1));
landmarksize = zeros(1,length(names2));
scl  = [];
trans = [];
for i = 1:length(names1)
    image_input = imread([where '/' folder '/' names1(i).name]);    
    faceDetector = vision.CascadeObjectDetector();
    bbox= step(faceDetector, image_input);
    if length(bbox) == 4
        facesize(i) = bbox(3)*bbox(4);
        facecenter(i,:) = [bbox(1)+0.5*bbox(3) bbox(2)+0.5*bbox(4)];
        pts = read_shape([where '/' folder '/' names2(i).name], 68);
%     figure;
%     image_output = drawsquare2(double(image_input), bbox(2), bbox(1), bbox(2)+bbox(4), bbox(1)+bbox(3),  'red', 3);
%     imshow(uint8(image_output));
%     hold on;
%     plot(pts(:,1),pts(:,2),'o');
        landmarkcenter(i,:) = mean(pts,1);
        landmarksize(i) = (max(pts(:,1)) - min(pts(:,1))) * (max(pts(:,2)) - min(pts(:,2)));
        scl = [scl, landmarksize(i)/facesize(i)];
        trans = [trans, (landmarkcenter(i,:) - facecenter(i,:))'/bbox(3)];
    end;
end
trans = trans';
meanscl = mean(scl,2);
meantrans = mean(trans,1);

files = struct('name', [], 'scl', [], 'trans', []);
pts = meanshape;
scl = zeros(1,length(names3));
trans = zeros(length(names3),2);
meanlandmarkcenter = mean(pts,1);
landmarksize = (max(pts(:,1)) - min(pts(:,1))) * (max(pts(:,2)) - min(pts(:,2)));
flag = 0;
for i = 1:length(names3)
    i
    image_input = imread([where '/' 'testset/' names3(i).name]);    
    faceDetector = vision.CascadeObjectDetector();
    bbox= step(faceDetector, image_input);
    if length(bbox) == 4
        flag = flag+1;
        files(flag).name = [where '/' 'testset/' names3(i).name];
        facesize(i) = bbox(3)*bbox(4);
        facecenter(i,:) = [bbox(1)+0.5*bbox(3) bbox(2)+0.5*bbox(4)];
        files(flag).scl = sqrt(facesize(i)*meanscl/landmarksize);
        files(flag).trans = facecenter(i,:)+meantrans*bbox(3)-scl(i)*meanlandmarkcenter;
    end;
end


%     image_output = drawsquare2(double(image_input), bbox(2), bbox(1), bbox(2)+bbox(4), bbox(1)+bbox(3),  'red', 3);
%     imwrite(uint8(image_output),names1(i).name,'jpg');
%     imshow(uint8(image_output));

