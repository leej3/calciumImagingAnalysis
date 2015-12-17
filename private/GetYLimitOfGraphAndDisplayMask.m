function [yLimOfGraph,dispMask]=                                GetYLimitOfGraphAndDisplayMask(displayPic,peakIndx,pic)


se = strel('disk',12);
im=imerode(displayPic,se);
im=imdilate(im,se);
dispMask=im2bw(uint8(im),0.2);
im=immultiply(dispMask,pic(:,:,peakIndx));
values=find(im>=1);
meanvalue=sum(im(values))/length(values);
clear im values se
yLimOfGraph = meanvalue*4;

end