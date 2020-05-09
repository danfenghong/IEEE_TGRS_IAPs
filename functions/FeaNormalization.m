function NormalizedFea=FeaNormalization(fea)

[m,n]=size(fea);
NormalizedFea=zeros(size(fea));

for i=1:m
    NormalizedFea(i,:)=mat2gray(fea(i,:));
%     NormalizedFea(i,:)=zscore(fea(i,:));
end

end