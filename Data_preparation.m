%% Prepare dataset for predictive models
function [Input, Output, Fails,Ratio,Pr_input,year_colno]=Data_preparation(SR,WTW,Raw,Dis,Temp_scale,colno_attr,multistep,colno_step,year_1)

%% use chlorination/chloramination data only
switch Dis
case "Cl"
Cld=SR.(45)<0.25;
Clr=SR.(45)<0.3;
case "Clm"
Cld=SR.(55)<0.7;
Clr=SR.(55)<1;
end
SR=addvars(SR,Clr,Cld); U=unique(SR.(7));
%% find events per month and season
switch Temp_scale
   
    case "Month"
SRp=SR(:,[7 3 4 123 124]); 
SRp_sum=varfun(@sum,SRp,'GroupingVariables',{'TWS','Year','Month'});
for iii=7:8    
    SRp_sum.(iii)=SRp_sum.(iii-2)>=1;
    Fails(iii-6)=sum(SRp_sum.(iii));
    Ratio(iii-6)=Fails(iii-6)/length(SRp_sum.(1));
end
[~,~,Xm]=unique (SRp_sum(:,1)); 
Output=accumarray(Xm,1:size(SRp_sum,1),[],@(r){SRp_sum(r,:)});
for i=1:size(U,1)
    Output{i,1}=sortrows(Output{i,1},{'Year','Month'},'ascend'); Output{i,1}.index=(1:height(Output{i,1})).';
end
   
    case "Season"
SRp=SR(:,[7 3 122 123 124]); 
SRp_sum=varfun(@sum,SRp,'GroupingVariables',{'TWS','Year','Season'});
for iii=7:8
    SRp_sum.(iii)=SRp_sum.(iii-2)>=1;
    Fails(iii-6)=sum(SRp_sum.(iii));
    Ratio(iii-6)=Fails(iii-6)/length(SRp_sum.(1));
end
[~,~,Xs]=unique (SRp_sum(:,1)); 
Output=accumarray(Xs,1:size(SRp_sum,1),[],@(r){SRp_sum(r,:)});
for i=1:size(U,1)
    Output{i,1}=sortrows(Output{i,1},'All_season','ascend'); Output{i,1}.index=(1:height(Output{i,1})).';
end
end
%% Prepare the input AVE datasets
%% SR parameters
switch Temp_scale
    
    case "Month"
SRpars=SR(:,[76 7 3 4 19 40 41 45 47 53 54 55 65 74 96 100 110 112 114 116]); 
Rawpars=Raw(:,[660 594]); 
SRpars_AVE=varfun(@nanmean,SRpars,'GroupingVariables',{'SW_all_one','TWS','Year','Month'});
SRpars_std=varfun(@nanstd,SRpars,'GroupingVariables',{'SW_all_one','TWS','Year','Month'});
SRpars_AVE=addvars(SRpars_AVE,SRpars_std.(9),'after','nanmean_FreeCl');
SRpars_AVE=addvars(SRpars_AVE,SRpars_std.(13),'after','nanmean_TotCl');
Rawpars_AVE=varfun(@nanmean,Rawpars,'GroupingVariables',{'SW_all_one'});
Inputa=outerjoin(SRpars_AVE,Rawpars_AVE, 'LeftKeys', 'SW_all_one', 'RightKeys', 'SW_all_one', 'MergeKeys', true);
idx=all(cellfun(@isempty,Inputa{:,2}),2);
Inputa(idx,:)=[];
Inputa = sortrows(Inputa,'TWS','ascend');
Input=accumarray(Xm,1:size(Inputa,1),[],@(r){Inputa(r,:)});
for i=1:size(U,1)
    Input{i,1}=sortrows(Input{i,1},{'Year','Month'},'ascend'); Input{i,1}.index=(1:height(Input{i,1})).';
end
for i=1:size(U,1)
Input{i,1}(Input{i,1}.(3)==0,:)=[];
end    
    case "Season"
SRpars=SR(:,[121 7 3 122 19 40 41 45 47 53 54 55 65 74]); 
WTWpars=WTW(:,[36 20 21 22 28 29 30 31]); 
Rawpars=Raw(:,[657 594]); 
SRpars_AVE=varfun(@nanmean,SRpars,'GroupingVariables',{'All_season','TWS','Year','Season'});
SRpars_std=varfun(@nanstd,SRpars,'GroupingVariables',{'All_season','TWS','Year','Season'});
SRpars_AVE=addvars(SRpars_AVE,SRpars_std.(9),'after','nanmean_FreeCl');
SRpars_AVE=addvars(SRpars_AVE,SRpars_std.(13),'after','nanmean_TotCl');
WTWpars_AVE=varfun(@nanmean,WTWpars,'GroupingVariables',{'All_season'});
Rawpars_AVE=varfun(@nanmean,Rawpars,'GroupingVariables',{'All_season'});
Inputa=outerjoin(SRpars_AVE,WTWpars_AVE, 'LeftKeys', 'All_season', 'RightKeys', 'All_season', 'MergeKeys', true);
Inputa=outerjoin(Inputa,Rawpars_AVE, 'LeftKeys', 'All_season', 'RightKeys', 'All_season', 'MergeKeys', true);
idx=all(cellfun(@isempty,Inputa{:,2}),2);
Inputa(idx,:)=[];
Inputa = sortrows(Inputa,'TWS','ascend');
Input=accumarray(Xs,1:size(Inputa,1),[],@(r){Inputa(r,:)});
for i=1:size(U,1)
    Input{i,1}=sortrows(Input{i,1},'All_season','ascend'); Input{i,1}.index=(1:height(Input{i,1})).';
    Input{i,1}(Input{i,1}.(3)==0,:)=[];
end
end

%% Creating inputs outputs sets
s=[{'All_one'}, {'SR'},{'Year'},{'Temp_scale'}, {'GroupCount_SWpar'}, {'Water Age'}, {'HPC22'},...
    {'HPC37'}, {'FreeCl'}, {'FreeClstd'}, {'FC_ICCs'}, {'Temperature'}, {'FC_TCC'},  {'TotalCl'},{'TotalClstd'},...
    {'SRdailyprecipitation'}, {'WTWdailyprecipitation'}, {'FreeCl_WTW'}, {'ICCs_WTW'},  {'Temperature_WTW'}, {'TCCs_WTW'}, ...
    {'TotalCl_WTW'},{'TOC_WTW'}, {'GroupCount_Rawpars_AVE'},{'Turbidity_Raw'} ,{'index'}];
ss=s([1 2 3 4  colno_attr 26]);
tt=s([1 2 3 4  colno_step]);
for iv=1:size(Output,1)
    Input{iv,1}= Input{iv,1}(:,[1:4 colno_attr 26]);
    Input{iv,1}.Properties.VariableNames = ss;
    if multistep==1
    Pr_input{iv,1}=Input_{iv,1}(:,[1:4 colno_step]);
    Pr_input{iv,1}.Properties.VariableNames = tt;
    else
        Pr_input=0;
    end
end
    switch year_1
        case 'Y'
       ss=find(colno_attr==9); tt=find(colno_attr==14);
       ss=isempty(ss); tt=isempty(tt);
for ii=1:size(U,1)
    for iii=1:length(Input{ii,1}.(1))
      if iii>12 && Input{ii,1}.Temp_scale(iii)==Input{ii,1}.Temp_scale(iii-12) && ss==0
      Input{ii,1}.FreeCl_1(iii)=Input{ii,1}.FreeCl(iii-12);
      else
      Input{ii,1}.FreeCl_1(iii)=nan;
      end
      if iii>12 && Input{ii,1}.Temp_scale(iii)==Input{ii,1}.Temp_scale(iii-12) && tt==0
      Input{ii,1}.TotalCl_1(iii)=Input{ii,1}.TotalCl(iii-12);
      else
      Input{ii,1}.TotalCl_1(iii)=nan;
      end
    end
Input{ii,1}=movevars(Input{ii,1},'index','after','TotalCl_1');
end
for ii=1:size(U,1)
if ss==0 && tt==0
year_colno=size(ss,1)+size(tt,1);
elseif ss==1 && tt==0
Input{ii,1}=removevars(Input{ii,1},'FreeCl_1');  
year_colno=size(tt,1);
else
Input{ii,1}=removevars(Input{ii,1},'TotalCl_1');  
year_colno=size(ss,1);
end
end
        case 'N'
            Input=Input;
            year_colno=0;
    end
end