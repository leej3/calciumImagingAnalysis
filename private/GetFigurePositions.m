function [positionOfFigure1,positionOfFigure2,positionOfFigure3]=                                          GetFigurePositions()
% Positioning the figure correctly:
% Ensure root units are pixels and get the size of the screen:
%%
set(0,'Units','pixels')
scnsize = get(0,'ScreenSize');
% Define the size and location of the figures:
 positionOfFigure1 =  [scnsize(3)*(10/100),scnsize(4)*(7/100), scnsize(3)*(91/100),scnsize(4)*(81/100)];
%  figure,set(gcf,'Position',positionOfFigure1)
 %%
  positionOfFigure2 =  [scnsize(3)*(1/100),scnsize(4)*(7/100), scnsize(3)*(48/100),scnsize(4)*(81/100)];
 positionOfFigure3 =  [scnsize(3)*(51/100),scnsize(4)*(7/100), scnsize(3)*(48/100),scnsize(4)*(81/100)];

end