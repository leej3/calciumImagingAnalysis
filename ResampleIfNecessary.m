function [glomStructure] =                   ResampleIfNecessary(fullDataSet,  glomStructure,timeSeriesDescriptors)
% for files that are sampled at a different sampling rate to the rest of the files this function resamples them. can set timeSeriesDescriptors.timeInterval to desired interval
if length(glomStructure)>1
    timeIntervalForFile = glomStructure(2).timeVec(2);
    % this could be written better to select time-intervals within the time-series that do not match the other time-intervals. current method is adequate if the same time-interval is always used for data acquisition as it will only require definition only once.
    if timeIntervalForFile < timeSeriesDescriptors.timeInterval-0.1 ||  timeIntervalForFile > timeSeriesDescriptors.timeInterval+0.1
        h = msgbox(['File collected at wrong sampling rate : resampling file : ' glomStructure(1).fileName]);
        disp(['resampling' glomStructure(1).fileName])
        if length(fullDataSet) ~=0
            appropriateTimeInterval = fullDataSet(1).timeVec(2);
        else
            errordlg('time interval of data is incorrect. try editing default time interval (approximate) in the previous menu or in the function ''GetFileConsolidationParameters''.')
            error
        end
        %%
        for ii = 2 : length(glomStructure)

            newTimeVec = 0: appropriateTimeInterval : appropriateTimeInterval*  floor(glomStructure(ii).timeVec(end)/appropriateTimeInterval);

            ts = timeseries(glomStructure(ii).plot,glomStructure(ii).timeVec);
            newTs = resample(ts,newTimeVec );
            % timeFig = 10;
            % figure(timeFig),plot(ts),hold on,plot(newTs,'r')
            %%
            glomStructure(ii).timeVec = newTimeVec;
            glomStructure(ii).plot= newTs.Data;
        end
    end
end
if exist('h','var')
    pause(1)
    close(h)
end
