function [timeSeriesDescriptors,treatment]=                 GetFileConsolidationParameters
[timeSeriesDescriptors] = GetDefaultTimeSeriesDescriptors;
dlg_title='Arguments for time series processing';
prompt={...
'Time Interval (approximate)',...
'Trigger used for stimulus (0  or 1)',...
'Treatment (a string contained in the filenames of treated animals)'};

answer=inputdlg(prompt,dlg_title,1,{...
     num2str(timeSeriesDescriptors.timeInterval),...
     num2str(timeSeriesDescriptors.triggerUsed),...
     '15eb'});

timeSeriesDescriptors.timeInterval = str2num(answer{1});
timeSeriesDescriptors.triggerUsed = str2num(answer{2});
treatment = answer(3);
if isempty(timeSeriesDescriptors)
    error('cancelled by user')
end

function [timeSeriesDescriptors] = GetDefaultTimeSeriesDescriptors
timeSeriesDescriptors.timeInterval = 0.396381815517818;
timeSeriesDescriptors.triggerUsed = 0;
 
