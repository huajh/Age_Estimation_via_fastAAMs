function newfiles = newfacedetect(files, meanshape , meanscl, landmarksize, meantrans, meanlandmarkcenter)

newfiles = struct('name',[], 'scl', [], 'trans', []);
flag= 0;
for i = 1:length(files)
    image_input = imread(files(i).name);    
    faceDetector = vision.CascadeObjectDetector();
    bbox= step(faceDetector, image_input);
    if length(bbox) ==4
        flag = flag+1;
        newfiles(flag).name = files(i).name;
        facesize = bbox(3)*bbox(4);
        facecenter = [bbox(1)+0.5*bbox(3) bbox(2)+0.5*bbox(4)];
        newfiles(flag).scl = sqrt(facesize*meanscl/landmarksize);
        newfiles(flag).trans = facecenter+meantrans*bbox(3)-newfiles(flag).scl*meanlandmarkcenter;
    end;
end;

