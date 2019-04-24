scenes = {'bedroom', 'corridor', 'outdoor', 'table'};
types = {'A', 'B', 'C'};

dimread=@(img) im2double(imread(img));

%% Illumination error
illum_mask = imread('quantshapes_mask.png');
true_illum = cell(1,1,1,12);
our_illum = cell(1,1,1,12);
matched_illum = cell(1,1,1,12);
khan_illum = cell(1,1,1,12);
lalonde_illum = cell(1,1,1,12);
idx=1;
for i=1:4; 
    for j=1:3;
        true_illum{idx} = dimread(['RenderedScenes/' scenes{i} '/' scenes{i} '-' types{j} '-quantshapes.png']);
        our_illum{idx} = dimread(['InsertedResults/' scenes{i} '-' types{j} '/_results/' scenes{i} '-' types{j} '-quantshapes-ours.png']);
        matched_illum{idx} = dimread(['InsertedResults/' scenes{i} '-' types{j} '/_results/' scenes{i} '-' types{j} '-quantshapes-matched.png']);
        khan_illum{idx} = dimread(['InsertedResults/' scenes{i} '-' types{j} '/_results/' scenes{i} '-' types{j} '-quantshapes-khan.png']);
        if(strcmpi(scenes{i},'outdoor'))
            lalonde_illum{idx} = dimread(['InsertedResults/' scenes{i} '-' types{j} '/_results/' scenes{i} '-' types{j} '-quantshapes-lalonde.png']);
        else
            lalonde_illum{idx} = nan(size(true_illum{idx}));
        end
        idx=idx+1;
    end
end
true_illum = cell2mat(true_illum); 
true_illum = reshape(true_illum(repmat(illum_mask,[1,1,3,12])), [], 12);
our_illum = cell2mat(our_illum); 
our_illum = reshape(our_illum(repmat(illum_mask,[1,1,3,12])), [], 12);
matched_illum = cell2mat(matched_illum); 
matched_illum = reshape(matched_illum(repmat(illum_mask,[1,1,3,12])), [], 12);
khan_illum = cell2mat(khan_illum); 
khan_illum = reshape(khan_illum(repmat(illum_mask,[1,1,3,12])), [], 12);
lalonde_illum = cell2mat(lalonde_illum); 
lalonde_illum = reshape(lalonde_illum(repmat(illum_mask,[1,1,3,12])), [], 12);
illum_metric = @(x,y) abs(x-y);
illum_errs = [mean(illum_metric(true_illum,our_illum)); 
        mean(illum_metric(true_illum,matched_illum)); 
        mean(illum_metric(true_illum,khan_illum)); 
        mean(illum_metric(true_illum,lalonde_illum))]'; 
disp('');
disp('all illum errors');
illum_errs
disp('averages per scene');
[mean(illum_errs(1:3,:)); mean(illum_errs(4:6,:)); mean(illum_errs(7:9,:)); mean(illum_errs(10:12,:))]
disp('average overall');
[mean(illum_errs(:,1:3)) mean(illum_errs(10:12,4))]


%% Depth error
%min_{t,s} ||D_true - s*(D_est+t)|| => Report for TOG depth vs ECCV depth
true_depth = cell(1,1,12);
our_depth = cell(1,1,12);
eccv_depth = cell(1,1,12);
depth_errs = zeros(12,2);
depth_metric = @(x,y) mean( ([y, ones(size(y))]*([y, ones(size(y))]\x) - x).^2 );
idx=1;
for i=1:4; 
    for j=1:3;
        true_depth{idx} = dimread(['allDepths/' scenes{i} '-true.png']);
        our_depth{idx} = dimread(['allDepths/' scenes{i} '-' types{j} '-ours.png']);
        eccv_depth{idx} = dimread(['allDepths/' scenes{i} '-' types{j} '-eccv.png']);
        true_depth_small = imresize(true_depth{idx}(:,:,1), size(our_depth{idx}), 'bilinear');
        depth_errs(idx,1) = depth_metric(true_depth_small(:), our_depth{idx}(:));
        depth_errs(idx,2) = depth_metric(true_depth_small(:), eccv_depth{idx}(:));
        idx=idx+1;
    end
end
disp('');
disp('all depth errors');
depth_errs
disp('averages per scene');
[mean(depth_errs(1:3,:)); mean(depth_errs(4:6,:)); mean(depth_errs(7:9,:)); mean(depth_errs(10:12,:))]
disp('average overall');
mean(depth_errs)
