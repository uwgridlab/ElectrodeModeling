function fitStruct = fit_individual_global(subStruct)

% function to fit individual subject data with global rhoA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% optimization for 1 layer


rhoA = 1;
dataSelect = subStruct.dataSelect;
numIndices = size(subStruct.meanMat,3);
jLength = 8;
kLength = 8;
%%
for index = 1:numIndices
    
    dataInt = dataSelect(:,index);
    % select particular values for constants
    
    i0 = subStruct.currentMat(index);
    stimChansIndices = subStruct.stimChansIndices;
    badTotal = subStruct.badTotal{index};
    jp = stimChansIndices(1,index);
    kp = stimChansIndices(2,index);
    jm = stimChansIndices(3,index);
    km = stimChansIndices(4,index);
       
    % perform 1d optimization
    offset = 0;
    % extract measured data and calculate theoretical ones
    
    [l1,tp] = computePotentials_1layer(jp,kp,jm,km,rhoA,i0,badTotal,offset,jLength,kLength);
    
    intercept = true;
    tempStruct = struct;
    
    % use MSE
    if ~isempty(dataInt)
        if ~intercept
            dlm=fitlm(l1,dataInt,'intercept',false);
            tempStruct.rhoAcalc(index) =dlm.Coefficients{1,1};
            tempStruct.offset(index) = 0;
        else
            dlm=fitlm(l1,dataInt);
            tempStruct.rhoAcalc(index)=dlm.Coefficients{2,1};
            tempStruct.offset(index) = dlm.Coefficients{1,1};
        end
        tempStruct.MSE = dlm.RMSE;
        tempStruct.bestVals = dlm.Fitted;
        
    else
        tempStruct.rhoAcalc = nan;
        tempStruct.MSE = nan;
        tempStruct.offset = nan;
    end
    
    fitStruct.calc{index} = tempStruct;
    fprintf(['complete for subject ' num2str(index) ' rhoA = ' num2str(tempStruct.rhoAcalc(index)) ' offset = ' num2str(tempStruct.offset(index)) ' \n ']);
    
end


end


