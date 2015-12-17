function [coordinatesOut] = ConvertBetweenImpolyCoordinatesAndImrectCoordinates(coordinatesIn)
	% impoly coordinates to imrect coordinates
	%     imrect uses[left, top, width, height]
	% impoly gives coordinates as 
	% [left top
	% left bottom
	% right bottom
	% right top]
if size(coordinatesIn) == [1,4] % imrect coordinates to impoly coordinates
top= round(coordinatesIn(2));
bottom=round(coordinatesIn(2)+coordinatesIn(4));
left=round(coordinatesIn(1));
right=round(coordinatesIn(1)+coordinatesIn(3));
coordinatesOut(:,1) = [left left right right];
coordinatesOut(:,2) = [top bottom bottom top];
else %impoly coordinates to imrect coordinates
	
left = coordinatesIn(1,1);
top = coordinatesIn(1,2);
width = [coordinatesIn(3,1) - coordinatesIn(1,1)];
height = [coordinatesIn(1,2) - coordinatesIn(2,2)];

coordinatesOut = [left,top,width,height];
end