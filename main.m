%% Main predictive model
tic;
clc;
clear all;
load SR;
load WTW;
load Raw;
%% Select parameters (type of model,ML algorithm,type of prediction (coliforms or chlorine),...
%% ... use of balancing methods (yes /no)
Temp_scale='Month' ; %% 'Season' / 'Month'
Disin="Clm";      %% "Cl" / "Clm"
Dis='Clm';        %% 'Cl' / 'Clm'
Thresh=2;       %% select threshold (0=All /1=Clr/ 2=Cld)
test_year=2021;    %% testing year
test_period=0;    %% (0 = test all year 1= W SP / 2=SMA) 
Step=1;          %% No of timestep difference between input and output 
colno_attr = [6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 25];   %select parameters for the procedure
multistep=0; %% 0= one step input data used / 1= 2 step input data (WTW and RAW input 2 steps before output)
colno_step = []; %%select parameters
Scolno=length(colno_attr); %number of parameters
Scolno_step=length(colno_step); %number of previous steps parameters
year_1='Y'; % ('Y' adding year / 'N' no adding year)
ml_ens_dec_tree='Boost'; % Select ML Ensemble Decision tree....
%... ('All' for all ML/ 'RF' for Random Forest / 'Boost' for boosting/'SVM' for SVM) 
Boost_Method='AdaBoostM1'; % if ml tree='Boost' select boost method here...
%....( AdaBoostM1 / RusBoost/LogitBoost/GentleBoost)
balancing = 'N'; %('Y' for balancing / 'N' for no balancing)
bl_method ='SMOTE'; % ('SMOTE' for SMOTE / 'ADASYN' for ADASYN / 'UNDER' for undersampling)     
%% Feature parameters' selection
% 6={'Water Age'}, 7={'HPC22'},8={'HPC37'}, 9={'FreeCl'}, 10={'FreeClstd'}, 11={'FC_ICCs'}, 12={'Temperature'}, 13={'FC_TCC'},14={'TotalCl'},
% 15={'TotalClstd'},16={'SRdailyprecipitation'}, 17={'WTWdailyprecipitation'}, 18={'FreeCl_WTW'}, 19={'ICCs_WTW'},20={'Temperature_WTW'}, 
% 21={'TCCs_WTW'}, 22={'TotalCl_WTW'},23={'TOC_WTW'}, 24={'GroupCount_Rawpars_AVE'},25={'Turbidity_Raw'} ,26={'index'}];
%% Balancing parameters to check
Mn=2; %% et parameter
%% Data preparation
SR=SR(SR.(25)==Disin,:); 
idx=all(cellfun(@isempty,SR{:,11}),2);
SR(idx,:)=[];
WTW=WTW(WTW.(10)==Disin,:);
Raw=Raw(Raw.(8)==Disin,:);
[Input, Output, Fails,Ratio,Pr_input,year_colno]=Data_preparation(SR,WTW,Raw,Dis,Temp_scale,colno_attr,multistep,colno_step,year_1);
clear WTW Raw SR colno_attr colno_step year_1 Dis Disin
%% Creating Input - Output file (check parameters inside)
[MLinout,MLtrain,MLtest]=mlinput(Input,Output,Pr_input,Thresh,Step,Temp_scale,test_year,test_period,multistep,Scolno_step);
clear Input Output Pr_input Step test_year test_period multistep
switch balancing
    case 'Y'
[Training_input,Training_output,Predict_input,Testing_output]=bal_methods(MLtrain,...
          MLtest,Scolno,bl_method,Mn,Scolno_step,year_colno);
    case 'N'
       Training_input=MLtrain(:,5:(5+Scolno+Scolno_step+year_colno-1));
       Training_output=MLtrain(:,(6+Scolno+Scolno_step+year_colno+4):end);
       Predict_input=MLtest(:,5:(5+Scolno+Scolno_step+year_colno-1));
       Testing_output=MLtest(:,(6+Scolno+Scolno_step+year_colno+4):end);
end
clear balancing Mn Scolno Scolno_step year_colno
%% Training ML method
[Val_output,Val_scores,Predict_output,P_scores]=Mlmethod(ml_ens_dec_tree,Boost_Method,Training_input,Training_output,Predict_input);
% if height(Val_scores)==height(MLtrain)
% Val_scores=addvars(Val_scores,MLtrain.WOAName,MLtrain.WTW,'before','Var1');
% end
P_scores=addvars(P_scores,MLtest.SR,MLtest.Month,'before','Var1');
P_scores=addvars(P_scores,Testing_output.Label,Predict_output.Var1,'NewVariableNames',{'Measured Data','Predicted Data'});
filename=['Clm.4 - ' ml_ens_dec_tree '_' Boost_Method '_' bl_method '_' Temp_scale '.xlsx'];
writetable(P_scores,filename);
%% Metrics
[P_TPR,P_TNR,P_MCC,P_Prec,P_F1score,V_TPR,V_TNR,V_MCC,V_Prec,V_F1score]=Metrics(Predict_output,Testing_output,...
           Val_output,Training_output);
if Thresh==0
   Metric_prall03 =[P_TPR(1) P_TNR(1) P_MCC(1) P_Prec(1) P_F1score(1)]
   Metric_prall025=[P_TPR(2) P_TNR(2) P_MCC(2) P_Prec(2) P_F1score(2)]

%     Metric_valall03=[V_TPR(1) V_TNR(1) V_MCC(1) V_Prec(1) V_F1score(1)]
%     Metric_valall025=[V_TPR(2) V_TNR(2) V_MCC(2) V_Prec(2) V_F1score(2)];

%fprintf('Prediction Metrics for 0.3 threshold = %g\n\n',Metric_prall03)
%fprintf('Prediction Metrics for 0.25 threshold = %g\n\n',Metric_prall025)

% fprintf('Validation Metrics for 0.3 threshold =  %g\n\n',Metric_valall03)
% fprintf('Validation Metrics for 0.25 threshold =  %g\n\n',Metric_valall025)
else
  Metric_prall=[P_TPR P_TNR P_MCC P_Prec P_F1score]
end    
toc;