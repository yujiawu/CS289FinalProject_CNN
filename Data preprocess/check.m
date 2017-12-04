[~, ~ , zh] = size(allimages);
figure(1)
for i = 1:zh
    subplot(1,2,1), imshow(uint8(allimages(:,:,i)))
    subplot(1,2,2), imshow(uint8(disc(:,:,i)),[])
    pause
end
    