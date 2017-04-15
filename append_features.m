% collect all features from batch features

clear all; close all;
where =  'morph_small';
AllFeatures = struct('name',[], 'age',[],'gender',[],'scl', [], 'trans', [],'features', []);
ticstatusid = ticstatus('feature Extraction',[],10 );
cnt = 0;
feat_idx = 0;
total_batch = 0;
for i = 0:0 %0:4 
    file_dir = [where '/features_mat' num2str(i) '/'];
    ef_files = dir([file_dir '*.mat']);
    total_batch = total_batch + length(ef_files);
end 
for i = 0:0 %0:4    
    file_dir = [where '/features_mat' num2str(i) '/'];
    ef_files = dir([file_dir '*.mat']);
    
    for j = 1:length(ef_files)
        
        load([file_dir 'ExtractedFeatures_' num2str(j) '.mat'],'ExtractedFeatures');
        
        for k=1:length(ExtractedFeatures)
            feat_idx = feat_idx + 1;
            mixnames = ExtractedFeatures(k).name;
            idx = strfind(mixnames,'/');
            AllFeatures(feat_idx).gender = mixnames(end-6);
            AllFeatures(feat_idx).age = str2num(mixnames(end-5:end-4));            
            AllFeatures(feat_idx).name = mixnames(idx(2)+1:end-7);            
            AllFeatures(feat_idx).scl = ExtractedFeatures(k).scl;
            AllFeatures(feat_idx).trans = ExtractedFeatures(k).trans;
            AllFeatures(feat_idx).features = ExtractedFeatures(k).features;
        end        
        clear ExtractedFeatures;
        cnt = cnt + 1;
        tocstatus( ticstatusid, cnt/total_batch);    
    end
end

save Allfeatures.mat AllFeatures
