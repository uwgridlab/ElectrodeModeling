%% try DBS subject 5e0cf
preSamps = 3;
postSamps = 3;
stimChansVec = [2 3; 3 2; 3 4; 4 3; 4 5; 5 4; 5 6; 6 5; 6 7; 7 6; 4 6; 6 4];
currentMatVec = repmat([0.00005],length(stimChansVec),1);

numStimChans = size(stimChansVec,1);
numCurrents = size(currentMatVec,2);

ii = 1;
jj = 1;
counterIndex = 1;
meanMatAll = zeros(12,2,numStimChans,numCurrents);
stdMatAll =  zeros(12,2,numStimChans,numCurrents);
numberStimsAll =  zeros(numStimChans,numCurrents,1);
numRows = 4;
numColumns = 3;
stdEveryPoint = {};
extractCellAll = {};
numChansInt = 12;

sid = DBS_SIDS{1};

figTotal =  figure('units','normalized','outerposition',[0 0 1 1]);

for stimChans = stimChansVec'
    
    fprintf(['running for 5e0cf stim chans ' num2str(stimChans(1)) '\n']);
    
    %stimChans = [2 3];
    load(fullfile(DBS_DIR,sid, ['stimSpacingDBS-5e0cf-stim_' num2str(stimChans(1)) '-' num2str(stimChans(2))]));
    fs = 48828;
    % take off mean for DBS channels
    tSamps = 1:size(dataEpoched,1);
    stimChans = stimChans;
    
    for chan = 1:12
        %dataEpoched(:,chan,:) = squeeze(dataEpoched(:,chan,:))-repmat(squeeze(mean(dataEpoched(t_samps<55,chan,:))), [1,size(dataEpoched, 1)])';
        dataEpoched(:,chan,:) = squeeze(dataEpoched(:,chan,:))-repmat(mean(squeeze(mean(dataEpoched(tSamps<55,chan,:)))), [size(dataEpoched,3),size(dataEpoched, 1)])';
        
    end
    dataEpoched = dataEpoched/1e6; % the data was stored in uV, convert this to volts
    
    % calculate metrics of interest
    [meanMat,stdMat,stdCellEveryPoint,extractCell,numberStims] = voltage_extract_avg(dataEpoched,'fs',fs,'preSamps',preSamps,'postSamps',postSamps,'plotIt',0);
    
    [meanMatAll,stdMatAll,numberStimsAll,stdEveryPoint,extractCellAll,figTotal] =  DBS_subject_processing(ii,jj,...
        meanMat,stdMat,numberStims,stdCellEveryPoint,extractCell,...
        meanMatAll,stdMatAll,numberStimsAll,stdEveryPoint,extractCellAll,...
        stimChans,currentMatVec,numChansInt,sid,plotIt,OUTPUT_DIR,figTotal,numRows,numColumns,counterIndex);
    
        sidCell{counterIndex} = sid; 
        subjectNum(counterIndex) = 14;
        
    ii = ii + 1;
    %  jj = ii + 1;
    counterIndex = counterIndex + 1;
end
if plotIt
    figure(figTotal)
    legend('first phase','second phase')
    xlabel('electrode')
    ylabel('Voltage (V)')
        SaveFig(OUTPUT_DIR, sprintf(['meansAndStds_' sid ]),'png');

end

[subj_5e0cf_DBS_struct] =  convert_mats_to_struct(meanMatAll,stdMatAll,stdEveryPoint,stimChansVec,currentMatVec,numberStimsAll,extractCellAll,sidCell,subjectNum);
clearvars meanMatAll stdMatAll numberStimsAll stdEveryPoint stimChans currentMat currentMatVec stimChansVec numberStimsAll extractCellAll sidCell subjectNum sid ii jj counterIndex