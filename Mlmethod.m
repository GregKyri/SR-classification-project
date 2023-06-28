%% ML algorithms training and testing
function [Val_output,Val_scores,Predict_output,P_scores]=Mlmethod(ml_ens_dec_tree,Boost_Method,Training_input,Training_output,Predict_input)

%% Training
Predict_output=table; P_scores=table;
Val_output=table; Val_scores=table;
Num_trees=1000; % select number of trees
for i=1:size(Training_output,2)
switch ml_ens_dec_tree
    
    case 'RF'
rng('default') 
tallrng('default')
tMdl = TreeBagger(Num_trees,Training_input,Training_output.(i),'Method','classification','NumPredictorsToSample',3 ...
,'Surrogate','on','NumPrint',200,'OOBPrediction','on','PredictorSelection','curvature','OOBPredictorImportance','on');
% % terr = error(tMdl,Input,Y);
% view(tMdl.Trees{1},'Mode','graph')

imp = tMdl.OOBPermutedPredictorDeltaError;
figure (1);
bar(imp);
title('Curvature Test');
ylabel('Predictor importance estimates');
xlabel('Predictors');
h = gca;
h.XTickLabel =tMdl.PredictorNames;
set(gca,...
    'XTick',1:size(tMdl.PredictorNames,2),...%fix the ticks
    'fontSize',8)
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';
figure (2);
oobErrorBaggedEnsemble = oobError(tMdl);
plot(oobErrorBaggedEnsemble);
xlabel 'Number of grown trees';
ylabel 'Out-of-bag classification error';

    case 'Boost'
N = height(Training_output);  % Number of observations in the training sample
t = templateTree('MaxNumSplits',N);
rng('default') 
tallrng('default')
tMdl = fitcensemble(Training_input,Training_output.(i),'Method',Boost_Method, ...
    'NumLearningCycles',Num_trees,'Learners',t,'LearnRate',0.1,'nprint',200); %'Tree'

imp = predictorImportance(tMdl);
figure (3);
bar(imp);
title('Curvature Test');
ylabel('Predictor importance estimates');
xlabel('Predictors');
h = gca;
h.XTickLabel =tMdl.ExpandedPredictorNames;
set(gca,...
    'XTick',1:size(tMdl.PredictorNames,2),...%fix the ticks
    'fontSize',8)
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';
figure (4);
plot(loss(tMdl,Training_input,Training_output.(i),'mode','cumulative'));
grid on;
xlabel('Number of trees');
ylabel('Test classification error');
view(tMdl.Trained{1000},'Mode','graph')
view(tMdl.Trained{1},'Mode','graph')
view(tMdl.Trained{100},'Mode','graph')
view(tMdl.Trained{50},'Mode','graph')
    case 'SVM'
tMdl = fitcsvm(Training_input,Training_output.(i),'Standardize',true,'KernelFunction','RBF',...
               'KernelScale','auto');
end

[Val_output.(i),Val_scores.(i)]=predict(tMdl,Training_input);
[Predict_output.(i),P_scores.(i)] = predict(tMdl,Predict_input);

end

for ii=1:size(Training_output,2)

    if ml_ens_dec_tree == "RF"
    Predict_output.(ii)=str2double(Predict_output.(ii));
    Val_output.(ii)=str2double(Val_output.(ii));
else 
        Predict_output.(ii)=Predict_output.(ii);
    Val_output.(ii)=Val_output.(ii);
end
end
end
