function [coordinates] = GetROIcoordinatesWithUser...
    (h, pic, lsmDescriptors,displayPic,yLimOfGraph,figTitle)
timeVector = GetTimeVector(lsmDescriptors);
figure(99), initialPosition = h.getPosition;
setappdata(99, 'pic', pic); % makes pic visible to callbacks
h.addNewPositionCallback(...
    @(pos)refreshFluorescencePlot...
    (pic, pos, lsmDescriptors, timeVector, yLimOfGraph, figTitle));


positionOfFigure1=GetFigurePositions;
topOfFig = positionOfFigure1(2)+positionOfFigure1(4);

continueButton = uicontrol(...
    'Position', [10 topOfFig-150 150 40],...
    'String', 'Tab+Space to continue',...
    'Callback', 'uiresume(gcbf)');

stackButton1 = uicontrol(...
    'Position', [10 topOfFig-200 150 40],...
    'String', 'View Stack',...
    'FontSize',10,'FontWeight','bold',...
    'BackgroundColor', [.9 .9 .9],...
    'CallBack', @displayImageStack);

 stackButton2 = uicontrol(...
    'Position', [10 topOfFig-250 150 40],...
    'String', 'View Stack in High Intensity',...
    'FontSize',10,'FontWeight','bold',...
    'BackgroundColor', [.9 .9 .9],...
    'CallBack', @displayImageStackHighIntensity);
  
refreshFluorescencePlot(pic, initialPosition, lsmDescriptors, timeVector, yLimOfGraph, figTitle);
uiwait(gcf); 
coordinates = h.getPosition ;
ClearFigureOfPushButtons(h,stackButton1, stackButton2, continueButton)
    

function displayImageStack(hObj,evnt)
show_stack(pic) %pic variable assigned to appdata property of figure 99 and so visible to this callback
% important to not that this function needs to be nested.
end
function displayImageStackHighIntensity(hObj,evnt)
show_stack(pic*3) %pic variable assigned to appdata property of figure 99 and so visible to this callback
end
 function refreshFluorescencePlot(pic, pos, lsmDescriptors, timeVector, yLimOfGraph, figTitle)
global figHandles
     [fluorescencePlot] =       CoordinatesToFluorescencePlot(pic, pos, lsmDescriptors);
        subplot(figHandles.plotFigure),plot(timeVector, fluorescencePlot,'o'...
            ,'color','red')
        grid on, xlabel('Time (secs)')
        ylabel('Mean pixel values at each time in the ROI)'), ylim([0 yLimOfGraph])
        title(figTitle)
        
    end
end



function ClearFigureOfPushButtons(h,stackButton1, stackButton2, continueButton)
delete(h);
delete(continueButton);
delete(stackButton1);
delete(stackButton2);
end
