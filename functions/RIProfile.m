function Feature = RIProfile(I, ord)

[om,on,~]=size(I);

%%Extract rotation-invariant features
binSize1 = 2;
binSize2 = 4;
binSize3 = 6;

binSize = 4;
padSize = (binSize * 6);
prepareKernel(binSize,4,1);

global chKERNEL triKERNEL triKERNEL2

for i=1:size(I,3)
    I(:,:,i)=conv2(I(:,:,i), triKERNEL, 'same');
end
 
I1 = zeros(size(I));
I2 = zeros(size(I));
I3 = zeros(size(I));

[x, y] = meshgrid(-binSize1+1:binSize1-1, -binSize1+1:binSize1-1);
z = complex(x, y);
triKERNEL1 = max(binSize1 - (abs(z)),0);
triKERNEL1 = triKERNEL1 / sum(abs(triKERNEL1(:)));
for i=1:size(I,3)
    I1(:,:,i)=conv2(I(:,:,i), triKERNEL1, 'same');
end

[x,y] = meshgrid(-binSize2+1:binSize2-1, -binSize2+1:binSize2-1);%11*11
z = complex(x, y);
triKERNEL3 = max(binSize2 - (abs(z)),0);
triKERNEL3 = triKERNEL3 / sum(abs(triKERNEL3(:)));
for i=1:size(I,3)
    I2(:,:,i)=conv2(I(:,:,i), triKERNEL3, 'same');
end

[x,y] = meshgrid(-binSize3+1:binSize3-1, -binSize3+1:binSize3-1);%11*11
z = complex(x,y);
triKERNEL4 = max(binSize3 - (abs(z)),0);
triKERNEL4 = triKERNEL4 / sum(abs(triKERNEL4(:)));
 for i=1:size(I,3)
       I3(:,:,i)=conv2(I(:,:,i), triKERNEL4, 'same');
 end
 
%% spatial aggregation e.g., with superpixel segmentation (SLIC)
II = cat(3, I1, I2);
III = cat(3, II, I3);
FF = mean(III, 3);
[l, N] = superpixels(FF, 30000,'Compactness',20);
New_I = zeros(size(I));

for i = 1 : N
    
    [x, y] = find(l == i);
     New_M = zeros(length(x), size(I, 3));
     
    for j = 1 : length(x)
        New_M(j, :) = I(x(j), y(j), :);
    end
    for k = 1 : length(x)
        New_I(x(k), y(k), :) = mean(New_M, 1);
    end
end

%% get gradient
if(size(I, 3)>=2)
    [DX, DY, ~] = gradient(I);
    mag = DX .^ 2 + DY .^ 2;
    [~, channel] = max(mag, [], 3);
    dx = 0;
    dy = 0;
    for i = 1 : size(I, 3)
        dx = dx + DX(:, :, i) .* (channel == i);% + DX(:,:, 2) .* (channel == 2) + DX(:,:, 3) .* (channel == 3);
        dy = dy + DY(:, :, i) .* (channel == i);% + DY(:,:, 2) .* (channel == 2) + DY(:,:, 3) .* (channel == 3);
    end
    complex_g = complex(dx, dy);
else
    [dx, dy] = gradient(I);
    complex_g = complex(dx, dy);
end
complex_g = padarray(complex_g, [padSize, padSize], 0);

%% project to fourier space
[m, n] = size(complex_g);
order = 0 : 1 : ord;
f_g = zeros([m, n, numel(order)]);
phase_g = angle(complex_g);
mag_g = abs(complex_g);

% local gradient magnitude normalization, scale = sigma * 2
local_mag_g = sqrt(conv2(mag_g.^2, triKERNEL2, 'same'));
mag_g = mag_g ./ (local_mag_g + 0.00001);

for j = 1:numel(order)
    f_g(:, :, j) = exp(-1i * (order(j)) * phase_g).* mag_g;
end
f_g(:, :, 1) = f_g(:, :, 1) * 0.5;
local_mag_g = unPad(local_mag_g, [om, on]);

%% compute regional description by convolutions
center_f_g = zeros(om, on, numel(order));
template = triKERNEL;
c_featureDetail = [];
maxFreq=3;
maxFreqSum=3;

% count output feature channels
nScale = size(chKERNEL,1);
featureDetail = [];
for s = 1 : nScale
    featureDim = 0;
    for freq = -maxFreq:maxFreq
        for j = 1 : numel(order)
            ff = -(order(j)) + freq;
            if(ff >= -maxFreqSum && ff <= maxFreqSum && ~(order(j) == 0 && freq < 0))
                featureDim = featureDim + 1;%10
                featureDetail = [featureDetail; [s, -1, -order(j), freq, ff]];%30*5
            end
        end
    end
end

% compute convolutions
fHoG = zeros([om, on, featureDim * nScale]);
cnt = 0;
for s = 1 : nScale
    for freq = -maxFreq : maxFreq
        template = chKERNEL{s, abs(freq) + 1};
        if(freq < 0)
            template = conj(template);
        end
        for j = 1 : numel(order)
            ff = -(order(j)) + freq;
            if(ff >= -maxFreqSum && ff <= maxFreqSum && ~(order(j)==0 && freq < 0))
                cnt = cnt + 1;
                fHoG(:, :, cnt) = unPad(conv2(f_g(:, :, j), template, 'valid'), [om, on]);
            end
        end
    end
end

fHoG = reshape(fHoG, om * on, size(fHoG, 3));
center_f_g = reshape(center_f_g, om * on, size(center_f_g, 3));

iF_index = featureDetail(:, end) == 0;
iF = fHoG(:, iF_index);

% for complex number
ifreal = false(1, size(iF,2));
for i = 1 : size(iF, 2)
    ifreal(i) = isreal(iF(:, i));
end

iF = [real(iF), imag(iF(:, ~ifreal))];
mF = abs([fHoG(:, ~iF_index) center_f_g local_mag_g(:)]);

%% final output including three parts: orignial features, SIFs, and FIFs.
Feature = [reshape(I,om*on,size(I,3)) reshape(New_I, om*on,size(New_I, 3)) iF mF];

end