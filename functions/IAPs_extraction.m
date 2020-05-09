function IAPs = IAPs_extraction(HSI3d, num_group, order)

HSI2d = hyperConvert2d(HSI3d);

%% grouping
opts = statset('Display','final');
rng(1);
idx = kmeans(HSI2d,num_group,'Start','uniform','distance','cosine','Replicates',10,'MaxIter',10000,'Options',opts);

%% 
IAPs = [];

for i = 1 : num_group
    
    index = find(idx == i);
    IAPs = [IAPs, RIProfile(HSI3d(:, :, index),order)];
    
end

end