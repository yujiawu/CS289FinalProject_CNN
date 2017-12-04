kk = dir ('*image*.mat')
kk1 = dir ('*label*.mat')
N = length(kk);
for i = 1:N
    load(kk(i).name)
    load(kk1(i).name)
    if i == 1
        combined_images = allimages;
        combined_labels = disc;      
    else
        combined_images = cat(3,combined_images,allimages);
        combined_labels = cat(3,combined_labels,disc);
    end
end

allimages = combined_images;
disc = combined_labels;
save('combined_img.mat','allimages')
save('combined_lab.mat','disc')