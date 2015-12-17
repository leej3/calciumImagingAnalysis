function [displayPic]=                                          GetDisplayPic(lsmDescriptors,pic)
   
displayPic=max(pic(:,:,lsmDescriptors.approxMaxIndx-3:lsmDescriptors.approxMaxIndx+3),[],3);
% potentially different way of doing diplay pic to make it prettier
% stretchingInputs=stretchlim(displayPic, [0.61 0.99]);
% displayPic=imadjust(displayPic, stretchingInputs);
if mean(mean(displayPic))<=20

displayPic=displayPic*8;

end

if mean(mean(displayPic))<=50

displayPic=displayPic*4;

end


end