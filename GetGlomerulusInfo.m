function [thisCycleGlom,dispMask] =                             GetGlomerulusInfo(lsmDescriptors, pic,thisCycleGlom,displayPic)
global figHandles
fluorescencePlot=[];

[thisCycleGlom, yLimOfGraph,h,dispMask] = SetupGlomerulusSelectionGUI...
(displayPic,lsmDescriptors,pic,thisCycleGlom);

[coordinates] = GetROIcoordinatesWithUser...
(h, pic, lsmDescriptors, displayPic, yLimOfGraph, thisCycleGlom.names	);

fluorescencePlot = CoordinatesToFluorescencePlot(pic, coordinates, lsmDescriptors);


thisCycleGlom.plot= fluorescencePlot;
thisCycleGlom.timeVec=GetTimeVector(lsmDescriptors);
thisCycleGlom.coOrdinates = coordinates;
end


