function  [newdata,visdata,newcatdata] = myADASYN(data,catdata,minorityLabel, num2Add, options)
% Note: Here we assume beta = 1.
% Where 0<=beta<=1 is a parameter used to specify the desired
% balance level after generation of the synthetic data. beta = 1
% means a fully balanced data set is created after the generalization
% process.

% Input
% data: table data with features and labels
% 1. The right-most variable is treated as labels
% 2. Features are expected to be numeric values
%
% minorityLabel (scalar string): Label to oversample
% num2Add (scalar numeric): Number of data to generate
% options.NumNeighbors (scalar integer): number of neighbors to consider
% options.Standardize (scalar logical):
% Standard-euclidean (true) or Euclidean distance (false) distance to search the neighbors
%
% Output
% newdata: generated dataset
% visdata: optional output for debugging
%-------------------------------------------------------------------------
% Copyright (c) 2019 Michio Inoue

arguments
    data {mustBeTableWithClassname}
    catdata 
    minorityLabel (1,1) string 
    num2Add (1,1) double {mustBeNonnegative, mustBeInteger} = 0
    options.NumNeighbors (1,1) double {mustBePositive, mustBeInteger} = 5
    options.Standardize (1,1) logical = false;
end

numNeighbors = options.NumNeighbors;
if options.Standardize
    distance = 'seuclidean';
else
    distance = 'euclidean';
end

% If N is smaller than zero, do not oversample data
if  num2Add <= 0
    newdata = table;
    newcatdata=table;
    visdata = cell(1);
    return;
end

visdata = cell(num2Add,4);
% Optional output for visualization purpose only
% 1: y, 2: nnarray, 3: y2, 4: synthetic

% labels of whote dataset
labelsAll = string(data{:,end});

% all feature dataset
featuresAll = data{:,1:end-1};
% feature dataset of the minority label
featuresMinority = data{labelsAll == minorityLabel,1:end-1};
cat_featuresMinority = table(catdata{labelsAll == minorityLabel,1:end-1}); %categorical data
cat_featuresMinority = splitvars(cat_featuresMinority);

% Number of minority data
NofMinorityData = size(featuresMinority,1);

% Number of synthetic data to generate is proportional to weights
weights = zeros(NofMinorityData,1);
% Save list of neighboring points for each minority data
nnarrays = cell(NofMinorityData,1);

for ii=1:NofMinorityData
    y = featuresMinority(ii,:); % a minority data
    [nnarray, ~] = knnsearch(featuresAll,y,'k',numNeighbors+1,...
        'Distance',distance, ...
        'SortIndices',true); % search for neighboring points
    % NOTE: this include self y, needs to omit y from nnarray
    nnarray = nnarray(2:end);
    % Note: nnarray will have a list of index of each neighboring points
    % witin the all dataset (not within the minority subset)
    idx = labelsAll(nnarray) == minorityLabel;
    NofNonMinority = sum(~idx); % number of non-minority data
    nnarrays{ii} = nnarray(idx); % keeps minority dataset only
    weights(ii) = NofNonMinority/numNeighbors; % keeps the ratio of non-minority dataset
    % Note: ADASYN generates more data when more non-minority dataset is
    % around
end

% If weights are all zero (neighboring points are all minor data)
if all(weights == 0)
    % callsmote instead (just an idea)
    %     disp('calling SMOTE instead');
    %     newdata = mySMOTE(data, minorityLabel, N, k);
else
    % Decide the number of synthetic data to genarate for each minority
    % dataset
    N2generate = ceil(num2Add*(weights/sum(weights)));
    
    newFeatures = zeros(num2Add,size(featuresAll,2));
    newCategories = zeros (num2Add,size (cat_featuresMinority,2));
    newCategories = categorical (newCategories);
     
    index = 1;
    index2= 1; 
    for ii=1:NofMinorityData % for all the minority dataset
        y = featuresMinority(ii,:); % a minority data
        [nnarray, ~] = knnsearch(featuresMinority,y,'k',numNeighbors+1,...
            'Distance',distance, ...
            'SortIndices',true); % search for neighboring points
        % NOTE: this include self y, needs to omit y from nnarray
        nnarray = nnarray(2:end);
        D=cat_featuresMinority(nnarray,:);
    
       
        for kk=1:N2generate(ii) % generate N2generate of synthetic data
        
            
           
            nn = datasample(nnarray, 1); % pick one (randomly)
            % Interpolation
            diff = featuresMinority(nn,:) - y;
            synthetic = y + rand.*diff;
            newFeatures(index,:) = synthetic;
            
            visdata{index,1} = y;
            visdata{index,2} = featuresMinority(nnarray,:);
            visdata{index,3} = featuresMinority(nn,:);
            visdata{index,4} = synthetic;
            
            index = index + 1;
         for mm=1:size(cat_featuresMinority,2)
            
            Unique{1,mm}=unique(D.(mm));
            DD{1,mm}=countcats(D.(mm));
            SS{1,mm}=DD{1,mm}((DD{1,mm}>0),:); %EE{1,mm}=DD{1,mm}(any(DD{1,mm},2),:); 
            [max_number,position]=max(SS{1,mm});
            if max_number==1;
            position = randperm(length(Unique{1,mm}),1);
            else
            position==position;
            end
            newCategories(index,mm)=Unique{1,mm}(position);
%           newCategories(index2,:)=newcat;
                
%           index2 = index2 + 1;
        
%         if index2 > num2Add
%             break;
%         end
        end
            
            if index > num2Add
                break;
            end
        end
        
    
    end
    
    
% make newFeature to table data with the same variable names
   tmp = array2table(newFeatures,'VariableNames',data.Properties.VariableNames(1:end-1));
% add label variable
   newdata = addvars(tmp,repmat(minorityLabel,height(tmp),1),...
        'NewVariableNames',data.Properties.VariableNames(end));
% make new categorical data with the same variables. 
newcatdata=table(newCategories(2:end,:)); newcatdata=splitvars(newcatdata);
newcatdata.Properties.VariableNames=catdata.Properties.VariableNames(1:end-1);
end
    
    