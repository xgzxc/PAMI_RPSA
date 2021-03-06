function A=SDPMetricLearning(X,triplet,weight,config)
%% This function implements relatively-paired  space analysis with SDP
% * Column of X is an augmented instance, which may come from any modality;
% * Ax and Ay are projection matrix so that Wx=W*Ax and Wy=W*Ay;
% * Each row of triplet is of the structure (i,j,k), which means  $distance (X_i,X_k) \ge distance (X_i,X_j)$;
% * The config contains the parameters and options;
% * W=[Wx,Wy], A=W^T*W is the projection mapping for both modalities 
global recordSDP;
N=size(triplet,1);
lb=zeros(1,N);
ub=config.param.gamma/N*weight(:,1)';
u=zeros(1,N);
Delta_ik=X(:,triplet(:,1))-X(:,triplet(:,3));
Delta_ij=X(:,triplet(:,1))-X(:,triplet(:,2));
[Delta_ik_s,Delta_ij_s]=adaptiveSparse(Delta_ik,Delta_ij);
if ~isfield(config,'numOuterIter')
    config.numOuterIter=3;
end
if config.verbose==2
    recordSDP=[];
    tSDP=tic;
    config.tSDP=tSDP;
end
if config.verbose==3
    recordSDP=[];
    tSDP=tic;
    config.tSDP=tSDP;
end
% compute pair-wise term;
Co=constructPairTerm(Delta_ij,weight(:,2)'*(config.param.gamma3/N));
u=lbfgsb(u,lb,ub,'computeObjective','computeGradient',...
           {Co,Delta_ik,Delta_ij,Delta_ik_s,Delta_ij_s,weight,config},'genericcallback','maxiter',config.numOuterIter,'m',5,'factr',1e-10,...
           'pgtol',1e-10);
global finalA;
A=double(finalA);
if config.verbose==2
    save([config.resultPath config.prefix,'recordSDP.mat'],'recordSDP');
    plot(recordSDP(:,1),recordSDP(:,2));    
end
if config.verbose==3
    save([config.resultPath config.prefix,'recordSDP.mat'],'recordSDP');
end
end