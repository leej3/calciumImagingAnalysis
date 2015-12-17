function [glomeruliInfo, displayPic, yLimOfGraph, h] = SetupBackgroundGUI(lsmDescriptors, pic,glomeruliInfo)
global figHandles
glomeruliInfo(1).names='BackGround';
displayPic=GetDisplayPic(lsmDescriptors,pic);
glomeruliInfo(1).displayPic=displayPic;

cla(figHandles.plotFigure),cla(figHandles.heatMapFigure)
figure(99), subplot(figHandles.mergedImage),imshow(displayPic)
freezeColors
% Add rectangular ROI on display pic
subplot(figHandles.mergedImage),title('Select region for background calculation')
h = imrect(gca, glomeruliInfo(1).coOrdinates);
h.setResizable(0);

% Used for setting the y-axis on the graphs
[yLimOfGraph,dispMask]=GetYLimitOfGraphAndDisplayMask(displayPic,lsmDescriptors.approxMaxIndx,pic);

% Heatmap
[heatMap, heatMapMasked]=GetHeatMap(pic,lsmDescriptors,dispMask);
glomeruliInfo(1).heatMap=heatMap;
glomeruliInfo(1).heatMapMasked=heatMapMasked;
DisplayHeatMapOnGUI(heatMapMasked)
end