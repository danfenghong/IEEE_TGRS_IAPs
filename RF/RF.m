function  [res2,OA] = RF(AvBand)

% Let's AvBand be our input (AvBand must be vector, e.g. AvBand =[1 0 0 0 1 1 0 1 .............. 1]

%%
S=0;
T1=imread('IndianTE123_temp123.tif');
T=imread('IndianTR123_temp123.tif');
x=double(imread('IndianPines.tif'));

for i=1:size(AvBand,2)
    if AvBand(i)==1
        S=S+1;
        x1(:,:,S)= x(:,:,i);
    end
end

%res2=[];
%for ii=10:210
%D=PC(:,:,ii);
%D=PC(:,:,1:12);
%D=X6_9_12;
%D=XR2dall6_9_12;
%D=RFres2;

[nx,ny,nz]=size(T);
train_label=reshape(T,nx*ny,nz)';
%x1=enviread1('C:\Users\ber10\Dropbox\Pursuit\Dataset\IndianPine\Indian');
%D=D(:,:,ii);
%D=Dx_UWT11;
%D=y_est_BM4D;

%  %%
% x1=double(enviread1('C:\Users\ber10\Dropbox\Pursuit\Dataset\URBAN(JRS)\Urban\URBAN'));
% load urbantrain
% load urbantest
% T=train_set_im;
% [nx,ny,nz]=size(T);
% train_label=reshape(T,nx*ny,nz)';
% T1=test_set_im;
%  %%
%  x1=enviread1('C:\Users\ber10\Dropbox\Pursuit\Dataset\Pavia');
% load TRpavia
% load TSpavia
% T=TRpavia;
% [nx,ny,nz]=size(T);
% train_label=reshape(T,nx*ny,nz)';
% T1=TSpavia;
% %%
% xx1=enviread1('C:\Users\ber10\Dropbox\Pursuit\Dataset\Pavia');
% load TRpaviauni
% load TSpaivauni
% T=train_set_im;
% [nx,ny,nz]=size(T);
% train_label=reshape(T,nx*ny,nz)';
% T1=test_set_im;
% %%
%  D = multibandread(...
%      'C:\Users\ber10\Dropbox\Pursuit\Dataset\Envidataset\SanDiego\sandiego_reflectance.img',...
%      [400 400 224], 'int16', 0, 'bsq', 'ieee-le');
%  D=cat(3,D(:,:,1:106),D(:,:,114:152),D(:,:,167:223));
%   T=double(enviread1('C:\Users\ber10\Dropbox\Pursuit\Dataset\Envidataset\SanDiego\sandiegoTR'));
%   T1=double(enviread1('C:\Users\ber10\Dropbox\Pursuit\Dataset\Envidataset\SanDiego\sandiego_gt'));
% x1=double(255*mat2gray(D));
% %load TRsandiego
% %load TSsandiego
% %T=train_set_im;
% [nx,ny,nz]=size(T);
% train_label=reshape(T,nx*ny,nz)';
% %T1=test_set_im;
% %%
% T=imread('Centre_Training_set.bmp');
% [nx,ny,nz]=size(T);
% train_label=reshape(T,nx*ny,nz)';
% xx1=enviread1('C:\Users\ber10\Dropbox\Pursuit\Dataset\Centre\Centre');
% %D=D(:,:,ii);
% %D=Dx_UWT11;
% %D=y_est_BM4D;
% T1=imread('Centre_Ground_Truth.bmp');
% %%
% T=imread('Roi_Hekla_image_TRAINING_temp123.tif');
% [nx,ny,nz]=size(T);
% train_label=reshape(T,nx*ny,nz)';
% x1=enviread1('C:\Users\ber10\Dropbox\Pursuit\Dataset\Hekla_HSI_data\Hekla');
% %D=D(:,:,ii);
% %x1=Dx_UWT11;
% %D=y_est_BM4D;
% T1=imread('Roi_Hekla_image_TEST_temp123.tif');
%%
[s1,s2,s3]=size(x1);
Data=reshape(x1,s1*s2,s3)';

 for i=1:s3
     Data(i,:)=double(mat2gray(Data(i,:)));
 end

train_labels=double(train_label(train_label>0));
X=Data(:,train_label>0);


[nx1,ny1,nz1]=size(T1); 
test_label=reshape(T1,nx1*ny1,nz1)';
test_labels=double(test_label(test_label>0));
X2=Data(:,test_label>0);

x=X2';y=test_labels';

model = classRF_train(X',train_labels',200);

%res(:,ii) = classRF_predict(Data',model);
res = classRF_predict(Data',model);
%---------------------------

t = classRF_predict(x,model);

[sortedlabels,sidx]=sort(test_labels);

Nc=length(unique(test_labels));

for i=1:Nc
    cl=find(sortedlabels==i);
    s=cl(1);e=cl(length(cl));
    sv=t(sidx);
    pcl=sv(s:e);
    for j=1:Nc
        C(j,i)=length(find(pcl==j));
    end
    Cacc(i)=length(find(pcl==i))/length(pcl)*100;
    clear cl pcl;
end
N=sum(sum(C));
sumC=sum(C);
sumR=sum(C');
S=0;
for i=1:Nc
    acc(i)=C(i,i)/sumC(i)*100;
    S=S+sumC(i)*sumR(i);
end
trace(C);
meanacc=mean(acc);
OA=trace(C)/N*100;
Po=trace(C)/N;
Pe=S/N^2;
kappa=(Po-Pe)/(1-Pe)*100;
% %------------------------------
 res2=[];
%  figure
  res2(:,:)=reshape(res,nx,ny);
%  imagesc(res2);
%  title(['Classification using RF,meanacc=',num2str(meanacc), ',OA=',num2str(OA), ',kappa=',num2str(kappa)])
end