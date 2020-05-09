function MultiChannelImshow(X)
% Usage
% MultiChannelImshow(X)
% You will be asked for the bands number in the prompt
% input
% X: A multichannel image (3D Matrix)
% Band Number: Can be a vector of the bands number otherwise press a key to
% see the bands in order
% output
% Show the image band by band after pressing a key
% 
% (c) 2013, Behnood Rasti 
% behnood.rasti@gmail.com



prompt = 'What are the Bands Number? Press Enter if you want to see all. ';
BN = input(prompt);
if isempty(BN)
    for i=1:size(X,3)
        close;figure;imagesc(X(:,:,i));colormap(gray);axis image;axis off;
        title(['Band Number=',num2str(i)]);colorbar;
        pause;
    end
else
    for i=1:length(BN)
        close;figure;imagesc(X(:,:,BN(i)));colormap(gray);axis image;axis off;
        title(['Band Number=',num2str(BN(i))]);colorbar;
        pause;
    end
end
