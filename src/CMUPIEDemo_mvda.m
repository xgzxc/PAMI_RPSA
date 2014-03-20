clc ;
clear all;
close all;
addpath(genpath(pwd));
 warning off;
%% read training dataset
path='..\..\data\cmupie.mat';
pathdir='..\..\result\';
dataset='cmupie';
trinum=4;
load(path);
Labels=[1:68]';
camera={'c02' 'c05' 'c07' 'c09' 'c11' 'c14' 'c22' 'c25' 'c27' 'c29' 'c31' 'c34' 'c37'};
trainingIndex=[1:34]';
tmp=pose(:,:,1,1);
scale=1;
tmp=imresize(tmp,1/scale);
l=size(tmp,1)*size(tmp,2);
n=34;
PHOTOS=zeros(n,l);
SKETCHS=zeros(n,l);
flag=['_demo_' num2str(trinum)];
for i=1:13  % gallery c27
  for j=i+1:13 % probe c29
      fprintf('i=%d  j=%d \n',i,j);
      testIndex=setdiff([1:68], trainingIndex);
      % prepare training and test data for both gallery and probe
      for k=1:size(pose,4)
          tmp=pose(:,:,i,k);
          tmp=imresize(tmp,1/scale);
          PHOTOS(k,:)=tmp(:)';
          tmp=pose(:,:,j,k);
          tmp=imresize(tmp,1/scale);
          SKETCHS(k,:)=tmp(:)';
      end
      [feature1]=zscore(PHOTOS);
      [feature2]=zscore(SKETCHS);
      [feature1, ~]=featureDimReduction(feature1);
      [feature2, ~]=featureDimReduction(feature2);
      trainingX=feature1(trainingIndex,:);
      trainingY=feature2(trainingIndex,:);
      trainingLabel=Labels(trainingIndex);
      testX=feature1(testIndex,:);
      testY=feature2(testIndex,:);
      testLabel=Labels(testIndex);
      % construct triplets to train model
      [X,Ax,Ay,triplet,type]=constructTriplets(trainingX',trainingY',trainingLabel,trainingLabel,[trinum 0 0 trinum]);
      N=size(triplet,1);
      coeff=1;
      % train model 
     config.method='mvda'; % cuttingPlane/SDP 
     Label=1:34;
     [X_multiview,Label_multiview]=prepareMvDA(trainingX',trainingY',Label)
      W_lda = MvDA(X_multiview,Label_multiview);
     Wx=W_lda{1}';
     Wy=W_lda{2}';
     
      %[Wx,Wy]=RPSA(X,Ax,Ay,triplet,weight,config);
      % classify test sample according to KNN
      for dimension=1:size(feature1,2)
      testX_projection=Wx(1:dimension,:)*testX';
      testY_projection=Wy(1:dimension,:)*testY'; 
      k_neigbor=1;
      Accuracy(dimension)=retrieval_kNN(testX_projection,testLabel, testY_projection,testLabel,k_neigbor);
      Accuracy1(dimension)=retrieval_kNN(testY_projection,testLabel, testX_projection,testLabel,k_neigbor);
      % fprintf('The accuracy for %s with %d-NN is %f\n',algorithm, k,Accuracy);
      end
      %save Accuracy;
      save([pathdir, dataset,camera{i},'_',camera{j},'_', config.method,'.mat'],'Accuracy');
      save([pathdir, dataset,camera{j},'_',camera{i},'_', config.method,'.mat'],'Accuracy1');
%       figure;
%       plot(Accuracy);
%       axis([1 length(Accuracy) 0 1.2]);
%       xlabel('Num. of dimensions of the learned latent space');
%       ylabel('Accuracy');
%       figure;
%       plot(Accuracy);
%       axis([1 length(Accuracy1) 0 1.2]);
%       xlabel('Num. of dimensions of the learned latent space');
%       ylabel('Accuracy1');
      
  end
end


  
     
      
     
    




