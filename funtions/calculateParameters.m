function [meanscl, meantrans] = calculateParameters(where, folder)

names1 = dir([where '/' folder '/*.jpg']);
names2 = dir([where '/' folder '/*.txt']);
facecenter = zeros(length(names1),2);
landmarkcenter = zeros(length(names2),2);
facesize = zeros(1,length(names1));
landmarksize = zeros(1,length(names2));
names1 = dir([where '/' folder '/*.jpg']);
names2 = dir([where '/' folder '/*.txt']);
scl  = [];
trans = [];
for i = 1:length(names1)
    image_input = imread([where '/' folder '/' names1(i).name]);    
    faceDetector = vision.CascadeObjectDetector();
    bbox= step(faceDetector, image_input);
    if length(bbox) == 4
        facesize = bbox(3)*bbox(4);
        facecenter = [bbox(1)+0.5*bbox(3) bbox(2)+0.5*bbox(4)];
        pts = read_shape([where '/' folder '/' names2(i).name], 68);
%     figure;
%     image_output = drawsquare2(double(image_input), bbox(2), bbox(1), bbox(2)+bbox(4), bbox(1)+bbox(3),  'red', 3);
%     imshow(uint8(image_output));
%     hold on;
%     plot(pts(:,1),pts(:,2),'o');
        landmarkcenter = mean(pts,1);
        landmarksize = (max(pts(:,1)) - min(pts(:,1))) * (max(pts(:,2)) - min(pts(:,2)));
        scl = [scl, landmarksize/facesize];
        trans = [trans, (landmarkcenter - facecenter)'/bbox(3)];
    end;
end
trans = trans';
meanscl = mean(scl,2);
meantrans = mean(trans,1);