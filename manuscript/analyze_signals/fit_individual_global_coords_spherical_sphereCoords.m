function fitStruct = fit_individual_global_coords_spherical_sphereCoords(subStruct)

% function to fit individual subject data with global rhoA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% optimization for 1 layer

rhoA = 1;
dataSelect = subStruct.dataSelect;
numIndices = size(subStruct.meanMat,3);

%%
for index = 1:numIndices
    
    dataInt = dataSelect(:,index);
    badTotal = subStruct.badTotal{index};
    dataInt(badTotal) = nan;
    
    % select particular values for constants
    
    stimChans = subStruct.stimChans(index,:);
    i0 = subStruct.currentMat(index);
    locs = subStruct.locs{index};
    % only use grid electrodes
    locs = locs(1:64,:);
    % extract measured data and calculate theoretical ones
    
    %[l1,tp] = computePotentials_1layer(jp,kp,jm,km,rhoA,i0,stimChansTotal,offset,jLength,kLength);
    [l1,correctionFactor] = compute_1layer_theory_coords_spherical_sphereCoords(locs,stimChans);
    correctionFactor(stimChans) = nan;
    
    scaleA=(i0*rhoA)/(4*pi);
    correctionFactor = correctionFactor*scaleA;
    
    l1 = scaleA*l1;
    
    intercept = true;
    tempStruct = struct;
    
    % use MSE
    if ~isempty(dataInt)
        if ~intercept
            dlm=fitlm(l1,dataInt,'intercept',false);
            tempStruct.rhoAcalc(index)=dlm.Coefficients{1,1};
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
    fitStruct.correctionFactor{index} = correctionFactor;
    
end


end


