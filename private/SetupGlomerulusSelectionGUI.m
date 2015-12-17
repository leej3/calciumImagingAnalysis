function [thisCycleGlom, yLimOfGraph, h, dispMask] = SetupGlomerulusSelectionGUI...
(displayPic,lsmDescriptors,pic,thisCycleGlom)
% Image to display and figure positions
global figHandles
figure(99)
% Used for setting the y-axis on the graphs
[yLimOfGraph,dispMask]=GetYLimitOfGraphAndDisplayMask(displayPic,lsmDescriptors.approxMaxIndx,pic);
% Making heatmap

[heatMap, heatMapMasked]=GetHeatMap(pic,lsmDescriptors,dispMask);
thisCycleGlom.heatMap=heatMap;
thisCycleGlom.heatMapMasked=heatMapMasked;

 figure(99),subplot(figHandles.heatMapFigure), imagesc(uint8(heatMap*10)),colormap('jet')
 set(gca,'xticklabel','','yticklabel','')
subplot(figHandles.mergedImage),title(thisCycleGlom.names)

% Load glomerular coordinates or get from user...
if ~isempty(thisCycleGlom.coOrdinates)
	h = impoly(gca, thisCycleGlom.coOrdinates);
else
h = impoly;
end

