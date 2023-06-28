%% calculate performance metrics

function [P_TPR,P_TNR,P_MCC,P_Prec,P_F1score,V_TPR,V_TNR,V_MCC,V_Prec,V_F1score]=Metrics(Predict_output,Testing_output,...
          Val_output,Training_output)

%% Calculate TP,TN,FP,FN - Prediction output
P_TM=[];
P_S=[];

for ii=1:width(Predict_output);
for i=1:length(Predict_output.(1));
if Predict_output.(ii)(i)==Testing_output.(ii)(i);
        P_TM(i,ii)=1;
    else
        P_TM(i,ii)=0;
end

if Predict_output.(ii)(i)==1 && Testing_output.(ii)(i)==1
    P_S(i,ii)=1; %True Positive
elseif Predict_output.(ii)(i)==0 && Testing_output.(ii)(i)==0
    P_S(i,ii)=2; %True Negative
elseif Predict_output.(ii)(i)==0 && Testing_output.(ii)(i)==1
    P_S(i,ii)=3; %False Negative
else Predict_output.(ii)(i)==1 && Predict_output.(ii)(i)==0
    P_S(i,ii)=4; %False Positive
end
end
end
for ii=1:width(Predict_output);
P_TP(ii)=sum(P_S(:,ii)==1); P_TN(ii)=sum(P_S(:,ii)==2);
P_FN(ii)=sum(P_S(:,ii)==3); P_FP(ii)=sum(P_S(:,ii)==4);
end

    %% Calculate TP,TN,FP,FN - Validation output
V_TM=[];
V_S=[];
for ii=1:width(Val_output);
for i=1:length(Val_output.(1));
if Val_output.(ii)(i)==Training_output.(ii)(i);
        V_TM(i,ii)=1;
    else
        V_TM(i,ii)=0;
end

if Val_output.(ii)(i)==1 && Training_output.(ii)(i)==1
    V_S(i,ii)=1; %True Positive
elseif Val_output.(ii)(i)==0 && Training_output.(ii)(i)==0
    V_S(i,ii)=2; %True Negative
elseif Val_output.(ii)(i)==0 && Training_output.(ii)(i)==1
    V_S(i,ii)=3; %False Negative
else Val_output.(ii)(i)==1 && Training_output.(ii)(i)==0
    V_S(i,ii)=4; %False Positive
end
end
end
for ii=1:width(Val_output);
V_TP(ii)=sum(V_S(:,ii)==1); V_TN(ii)=sum(V_S(:,ii)==2);
V_FN(ii)=sum(V_S(:,ii)==3); V_FP(ii)=sum(V_S(:,ii)==4);
end

%% TPR, TNR, F1 score, MCC, Prec
%% Prediction
for ii=1:width(Val_output);
    P_TPR(ii)=P_TP(ii)/(P_TP(ii)+P_FN(ii)); %TPR
    P_TNR(ii)=P_TN(ii)/(P_FP(ii)+P_TN(ii)); %TNR
    P_Prec(ii)=P_TP(ii)/(P_TP(ii)+P_FP(ii)); %Precision
    P_MCC(ii)=(P_TP(ii)*P_TN(ii)-P_FP(ii)*P_FN(ii))/sqrt((P_TP(ii)+P_FP(ii))...
    *(P_TP(ii)+P_FN(ii))*(P_TN(ii)+P_FP(ii))*(P_TN(ii)+P_FN(ii)));
    P_F1score(ii)=2*(P_TPR(ii)*P_Prec(ii))/(P_TPR(ii)+P_Prec(ii));
end
%% Validation
for ii=1:width(Val_output);
    V_TPR(ii)=V_TP(ii)/(V_TP(ii)+V_FN(ii)); %TPR
    V_TNR(ii)=V_TN(ii)/(V_FP(ii)+V_TN(ii)); %TNR
    V_Prec(ii)=V_TP(ii)/(V_TP(ii)+V_FP(ii)); %Precision
    V_MCC(ii)=(V_TP(ii)*V_TN(ii)-V_FP(ii)*V_FN(ii))/sqrt((V_TP(ii)+V_FP(ii))...
    *(V_TP(ii)+V_FN(ii))*(V_TN(ii)+V_FP(ii))*(V_TN(ii)+V_FN(ii)));
    V_F1score(ii)=2*(V_TPR(ii)*V_Prec(ii))/(V_TPR(ii)+V_Prec(ii));
end
end