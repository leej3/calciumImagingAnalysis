function [heatMap, heatMapMasked]=                              GetHeatMap(pic,lsmDescriptors,dispMask)
heatMap = []; heatMapMasked = [];
peakIndx=lsmDescriptors.approxMaxIndx;
timeInterval=lsmDescriptors.timeInterval;
peakPic=mean(pic(:,:,(peakIndx-1:peakIndx+1)),3);

base2PeakSlices=ceil(2/timeInterval);
numberOfSlices2Average = GetNumberOfSlicesToAverage(timeInterval,peakIndx,base2PeakSlices);
    
basePic=mean(pic(:,:,(peakIndx-base2PeakSlices-numberOfSlices2Average):(peakIndx-base2PeakSlices)  ),3);
heatMap=peakPic-basePic;
heatMapMasked=immultiply(dispMask,heatMap);


function[numberOfSlices2Average] = GetNumberOfSlicesToAverage(timeInterval,peakIndx,base2PeakSlices)
% making sure the averaged slices doesn't stretch back too early
numberOfSlices2Average= ceil(2/timeInterval);
while peakIndx-base2PeakSlices-numberOfSlices2Average<1
numberOfSlices2Average= numberOfSlices2Average-1;
end