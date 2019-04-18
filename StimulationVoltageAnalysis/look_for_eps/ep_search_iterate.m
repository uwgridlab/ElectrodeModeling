%%
%
% David.J.Caldwell 10.10.2018
%% initialize output and meta dir
% clear workspace, get rid of extraneous information
close all; clear all; clc
myDir = uigetdir; %gets directory
myFiles = dir(fullfile(myDir,'*.mat')); %gets all mat files in struct

numChans = 128;
stimChans = [];
preTime = 100;
postTime = 200;
saveIt = 0;
sid = '010dcb';
stimChansVec = {[5 7 8],[4 7 8],[4 5]};
%%
for ii = 1:length(myFiles)
    %for ii = [1:3]
    stimChans = stimChansVec{ii};
    baseFileName = myFiles(ii).name;
    myFolder = myFiles(ii).folder;
    fullFileName = fullfile(myFolder, baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    load(fullfile(myDir,['stimGeometry-' num2str(ii) '.mat']));
    
    for reref = 0:0
        
        %%
        
        if size(ECO1.data,1) == size(ECO3.data,1)
            data = 4.*[ECO1.data ECO2.data ECO3.data]; % add in factor of 4 10.10.2018
        else
            data = 4.*[ECO1.data(1:end-1,:) ECO2.data(1:end-1,:) ECO3.data]; % add in factor of 4 10.10.2018
            
        end
        
        data = data(:,1:99);
        dataCopy = data;
        data(:,1:16) = dataCopy(:,17:32);
        data(:,17:32) = dataCopy(:,1:16);
        fsData = ECO1.info.SamplingRateHz;
        
        % get sampling rates
        fsStim = Stim.info.SamplingRateHz;
        fsSing = Sing.info.SamplingRateHz;
        preSamps = round(preTime/1000 * fsData); % pre time in sec
        postSamps = round(postTime/1000 * fsData); % post time in sec,
        
        % stim data
        stim = Stim.data;
        
        % current data
        sing = Sing.data;
        %%
        % deal with rereferencing
        
        if reref
            rerefChans = data(:,[71 72 73 74 75 76 77 78 79 85 86 87 88 89 90 4 18]);
            rerefChans = mean(rerefChans,2);
            data = data - repmat(rerefChans,1,numChans);
        end
        
        %% stimulation voltage monitor
        plotIt = 0;
        savePlot = 0;
        [stim1Epoched,t,fs,labels,uniqueLabels] = voltage_monitor_pos_neg(Stim,Sing,plotIt,savePlot,'','','');
        
        %% extract average signals
        
        [sts,bursts] = get_epoch_indices(sing,fsData,fsSing);
        
        dataEpoched = 1e6.*squeeze(getEpochSignal(data,sts-preSamps,sts+postSamps+1));
        % set the time vector to be set by the pre and post samps
        t = (-preSamps:postSamps)*1e3/fsData;
        
        %% plot epoched signals
        %     plot_EPs_fromEpochedData(dataEpoched,t,uniqueLabels,labels,stimChans)
        
        %%
        
        for uniq = uniqueLabels
            %   if uniq >=1500
            if uniq>1500
                boolLabels = labels==uniq;
                average = 1;
                %chanIntList = 3;
                trainDuration = [];
                modePlot = 'avg';
                xlims = [-10 150];
                ylims = [-1 1];
                
                small_multiples_time_series(1e-6.*dataEpoched(:,:,boolLabels),1e-3*t,'type1',stimChans,'type2',0,'xlims',xlims,'ylims',ylims,'modePlot',modePlot,'highlightRange',trainDuration)
                sgtitle(['File ' num2str(ii) ' current ' num2str(uniq)])
            end
        end
        %%
        if saveIt
            if reref
                save([sid '_EP_' regexprep(num2str(stimChans),'  ','_','emptymatch'),'_reref'],'stim1Epoched','dataEpoched','t','uniqueLabels','labels')
            else
                save([sid '_EP_' regexprep(num2str(stimChans),'  ','_','emptymatch')],'stim1Epoched','dataEpoched','t','uniqueLabels','labels')
            end
        end
        
    end
end