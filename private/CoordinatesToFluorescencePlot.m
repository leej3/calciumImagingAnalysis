			function [fluorescencePlot] = CoordinatesToFluorescencePlot(pic, coordinates, lsmDescriptors)

if size(coordinates) == [1,4]; % for the background ROI
    coordinates = ConvertBetweenImpolyCoordinatesAndImrectCoordinates(coordinates);
end
[mask] = roipoly(pic(:,:,1),coordinates(:,1), coordinates(:,2));
try
PixelsWithinROI = pic(repmat(mask,1,1,lsmDescriptors.sliceNumber));
catch
    PixelsWithinROI = pic(repmat(mask, [1,1,lsmDescriptors.sliceNumber]));
   %older versions of repmat have different input arguments

end
PixelsWithinROI = reshape( PixelsWithinROI, [], lsmDescriptors.sliceNumber)';
fluorescencePlot = mean(PixelsWithinROI,2);
end