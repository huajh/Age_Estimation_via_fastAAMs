if_test_image = 1;
if if_test_image == 1
    names1 = dir(['test_images/*.jpg']);    
    image_num = length(names1);
    error = zeros(image_num,1);
    for i = 1:image_num
		tic;
        input_image = imread(['test_images/' names1(i).name]);
        trueage = str2num(names1(i).name(end-5:end-4));        
        pred_age = ageestimation(input_image);
        error(i) = abs(pred_age-trueage);
		toc;
    end
    hist(error);
    MAE = mean(error);
    title(['MAE = ',num2str(MAE)]);
    save('svr_test_error.mat','error','MAE');
end