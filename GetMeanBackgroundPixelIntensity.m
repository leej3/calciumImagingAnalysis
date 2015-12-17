function [glomeruliInfo,displayPic] =                           GetMeanBackgroundPixelIntensity(reviewingStatus,lsmDescriptors, pic,glomeruliInfo)
[glomeruliInfo, displayPic, yLimOfGraph, h] = SetupBackgroundGUI(lsmDescriptors, pic,glomeruliInfo);

glomeruliInfo(1).coOrdinates = GetROIcoordinatesWithUser(h, pic, lsmDescriptors,displayPic, yLimOfGraph, 'Background');

[fluorescencePlot] = CoordinatesToFluorescencePlot(pic,glomeruliInfo(1).coOrdinates, lsmDescriptors);
glomeruliInfo(1).meanBackGround = mean(fluorescencePlot(:));
delete(h)
end  






