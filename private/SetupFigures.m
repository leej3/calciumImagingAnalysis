function SetupFigures() 
%Defining figure positions. disp will always contain displayPic with
%various objects being placed on it. figHandles.plotFigure and figHandles.heatMapFigure point to subplots for a heatmap and a
%mean pixel intensity plot of the active roi.
global figHandles
positionOfFigure1=GetFigurePositions;
figure(99),clf, set(gcf,'Position',positionOfFigure1)
figHandles.mergedImage = subplot(2,2,[1 3]);
figHandles.heatMapFigure = subplot(2,2,2);
figHandles.plotFigure = subplot(2,2,4);