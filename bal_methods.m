%% Use of  balancing method
function [Training_input,Training_output,Predict_input,Testing_output]=bal_methods(MLtrain,...
          MLtest,Scolno,bl_method,Mn,Scolno_step,year_colno);


Training_input_check=MLtrain(:,[5:(5+Scolno+Scolno_step+year_colno-1) (6+Scolno+Scolno_step+year_colno+4):end]);
Categorical_input=categorical(MLtrain.SR); 
Categorical_input_check=table(Categorical_input);
Ysum=sum(Training_input_check.Label);
Training_input_check.Label=string(Training_input_check.Label);
Categorical_input_check=addvars(Categorical_input_check,Training_input_check.Label);
uniqueLabels=unique(Training_input_check.Label);

%% Parameters to check
AD=Mn*Ysum;
k=5; % number of neighbors
AD=Ysum*Mn;   % select percentage of extra data
num2Add = [0,AD]; %number of adding data
%%-------parameters end
newdata = table;
visdataset = cell(length(uniqueLabels),1);
    switch bl_method
        case "SMOTE"
for ii=1:length(uniqueLabels)
            [tmp,visdata,newcatdata] = mySMOTE(Training_input_check,Categorical_input_check,...
                uniqueLabels(ii),num2Add(ii),"NumNeighbors",k, "Standardize", true);

    newdata = [newdata; tmp];
    visdataset{ii} = visdata;
    newcatdata=newcatdata;
end
Training_input_check=[Training_input_check; newdata];
        case "ADASYN"
for ii=1:length(uniqueLabels)
            [tmp,visdata,newcatdata]  = myADASYN(Training_input_check,Categorical_input_check,...
                uniqueLabels(ii),num2Add(ii),"NumNeighbors",k, "Standardize", true);

    newdata = [newdata; tmp];
    visdataset{ii} = visdata;
    newcatdata=newcatdata; 
end
Training_input_check=[Training_input_check; newdata];
        case 'UNDER' 
    zerodata=Training_input_check(Training_input_check.Label=='false',:);    
    onedata=Training_input_check(Training_input_check.Label=='true',:);
    zerodata=datasample(zerodata,AD);
Training_input_check=[zerodata;onedata];     
    end

%% final inputs outputs
Training_input=Training_input_check(:,1:Scolno+Scolno_step+year_colno);
Training_output=Training_input_check(:,(Scolno+Scolno_step+year_colno+1):end);
f=zeros(size(Training_output.(width(Training_output)))); f(strcmp(Training_output.(width(Training_output)),"true")) = 1;
Training_output.(width(Training_output))=f;
Predict_input=MLtest(:,5:(5+Scolno+Scolno_step+year_colno-1));
Testing_output=MLtest(:,(6+Scolno+Scolno_step+year_colno+4):end);
end    