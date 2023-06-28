%% Preparing inputs putputs for ML algorithm
function [MLinout,MLtrain,MLtest]=mlinput(Input,Output,Pr_input,Thresh,Step,Temp_scale,test_year,test_period,multistep,Scolno_step);

%% timestep & threshold
for ii=1:size(Output,1)
    Output{ii,1}.Timestep=(1-Step:height(Output{ii,1})-Step).';
    if Thresh==0
    Output{ii,1}=Output{ii,1}(:,[1:4 7:8 10]);
    elseif Thresh==1
        Output{ii,1}=Output{ii,1}(:,[1:4 7 10]);
    else 
        Output{ii,1}=Output{ii,1}(:,[1:4 8 10]);
    end
    Output{ii, 1}.Properties.VariableNames{end} = 'index';
    MLinout{ii,1}=outerjoin(Input{ii,1},Output{ii,1}, 'LeftKeys', 'index', 'RightKeys', 'index', 'MergeKeys', true);
end
if multistep==1;
for ii=1:size(Output,1)
Pr_input{ii,1}.Timestep=(1+Step:height(Pr_input{ii,1})+Step).';
Pr_input{ii,1}.Properties.VariableNames{end} = 'index';
Pr_input{ii,1}=Pr_input{ii,1}(:,[6:end]);
MLinout{ii,1}=outerjoin(MLinout{ii,1},Pr_input{ii,1}, 'LeftKeys', 'index', 'RightKeys', 'index', 'MergeKeys', true);
end
end
MLinout=vertcat(MLinout{:}); 
if multistep==1;
for c=(width(MLinout)-Scolno_step+1):width(MLinout)
t=MLinout.Properties.VariableNames{c};
MLinout=movevars(MLinout,t,'before','index');
end
end
MLinout.Properties.VariableNames{end} = 'Label';
MLinout = rmmissing(MLinout,'DataVariables',{'Temp_scale'});
MLtest=MLinout(MLinout.Year_right==test_year,:);
MLtrain=MLinout(MLinout.Year_right<test_year,:);
end