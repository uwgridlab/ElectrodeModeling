function fitStruct = fit_individual_coords_spherical(subStruct,plotIt,saveIt)
% David.J.Caldwell 9.5.2018

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% optimization for 1 layer

bins = (repmat([1:8],2,1)+[0;1])';
binCenter = mean(bins,2);
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
    locs = locs(1:64,:);
    
    centerSpace = mean([locs(stimChans(1),:);locs(stimChans(2),:)],1);
    distances = vecnorm((locs-repmat(centerSpace,64,1)),2,2)./10;
    % perform 1d optimization
    % extract measured data and calculate theoretical ones
    
    rFixed = subStruct.rFixed{index}/1000;
    [l1,correctionFactor,l1Dot,correctionFactorDot,l1DotScaled,correctionFactorDotScaled]= compute_1layer_theory_coords_spherical(locs,stimChans,rFixed);
    scaleA=(i0*rhoA)/(4*pi);
    l1 = scaleA*l1;
    
    [rhoAoutput,MSE,subjectResiduals,offset,bestVals] = distance_selection_MSE_bins_fitlm(dataInt,l1,bins,distances);
    
    tempStruct = struct;
    
    tempStruct.bestVals = bestVals;
    tempStruct.MSEind = MSE;
    tempStruct.rhoAcalc = rhoAoutput;
    tempStruct.offset = offset;
    
    tempStruct.MSE = sqrt((1/sum(~isnan(tempStruct.bestVals)))*nansum((tempStruct.bestVals - dataInt).^2));
    
    fitStruct.calc{index} = tempStruct;
    
    fprintf(['complete for subject ' num2str(index) ' rhoA = ' num2str(rhoAoutput) ' offset = ' num2str(offset) ' \n ']);
    
end

%% plot

if plotIt
    
    figInd = figure;
    figInd.Units = "Inches";
    figInd.Position = [1 1 4 4];
    hold on
    
    for index = 1:numIndices
        plot(binCenter(1:5),fitStruct.calc{index}.rhoAcalc(1:5),'-o','linewidth',2)
    end
    legend({'1','2','3','4','5','6','7'})
    xlabel('bin')
    ylabel('rhoA (ohm-m)')
    title('one layer apparent resistivity by subject and bin')
    set(gca,'fontsize',14)
    
    if saveIt
    end
    
end

%%

if plotIt
    
    figTotal = figure;
    figTotal.Units = "Inches";
    figTotal.Position = [1 1 8 5];
    
    for index = 1:numIndices
        
        subplot(2,4,index)
        plot(binCenter(1:5),fitStruct.calc{index}.rhoAcalc(1:5),'-o','linewidth',2)
        
        title(['subject ' num2str(index)])
        set(gca,'fontsize',12)
        ylim([0 6])
        xlim([0 6])
        yticks([0 1 2 3 4 5 6])
        xticks([0 1 2 3 4 5 6])
        
    end
    xlabel('Bin (cm)')
    ylabel('\rho_a (ohm-m)')
    sgtitle('Spherical One Layer Apparent Resistivity by Subject and Bin','fontsize',18)
    
    if saveIt
        
    end
    
end

end