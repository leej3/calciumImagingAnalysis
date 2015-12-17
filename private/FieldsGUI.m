 function [userDefinedCatList]=FieldsGUI(organisedCatList)
% slightly messy function due to difficulty with callback functionality. it returns a list of criteria to select files by. These criteria are selected by the user via a checkbox interface


% load organisedCatList
% Positioning the figure correctly:
% Ensure root units are pixels and get the size of the screen:
set(0,'Units','pixels')
scnsize = get(0,'ScreenSize');
% Define the size and location of the figure:
positionOfFigure1 =  [scnsize(3)*(1/100),scnsize(4)*(5/100), scnsize(3)*(95/100),scnsize(4)*(91/100)];

objectWidth=scnsize(3)*0.07;
objectHeight=scnsize(4)*0.025;
userDefinedCategoriesArray=zeros(1,length(organisedCatList));

checkBoxObject = figure('units','pixels','position',positionOfFigure1,...
     'toolbar','none','menu','none');
hCheckBoxObject.object=checkBoxObject;


columnNum=-1;
topRowYPos=scnsize(4)*0.85;
 % Create checkboxes
        for catListEL= 1:length(organisedCatList)
            
%             %currently assessing if the first n characters match in
%             organised category list. if they do it will signify the start
%             of a new column and become static text. otherwise it will
%             continue to move down the gui and be a checkbox. Need to get
%             screen size and work in % of that.
            
            
            %
  if strncmp(organisedCatList(catListEL),'Field',5)
     columnNum=columnNum+1;
      userDefinedCategoriesArray(catListEL)=1;
%        [scnsize(3)*(1/100),scnsize(4)*(5/100),   left bottom
%        scnsize(3)*(95/100),scnsize(4)*(85/100)];   width height


currentColumnXPos=scnsize(3)*0.01+columnNum*110;

            hCheckBoxObject.tBox(catListEL) = uicontrol('style','Text','units','pixels',...
                'position',[currentColumnXPos,topRowYPos,objectWidth,objectHeight],...
                'string',organisedCatList{catListEL}(7:end),'value',1);
            
            rowNum=1;
            
 
  else
      
       hCheckBoxObject.cBox(catListEL) = uicontrol('style','checkbox','units','pixels',...
                'position',[currentColumnXPos,topRowYPos-40*rowNum,objectWidth,objectHeight],...
                'string',organisedCatList{catListEL},'value',1);
            rowNum=rowNum+1;
  end
        
 end
% Create yes/no checkboxes
% hCheckBoxObject.c(1) = uicontrol('style','checkbox','units','pixels',...
%     'position',[10,30,50,15],'string','yes');
% hCheckBoxObject.c(2) = uicontrol('style','checkbox','units','pixels',...
%     'position',[90,30,50,15],'string','no');
% Create OK pushbutton
hCheckBoxObject.p = uicontrol('style','pushbutton','units','pixels',...
    'position',[40,5,70,20],'string','OK','callback',@p_call);
uiwait(checkBoxObject)
userDefinedCategoriesArray=userDefinedCategoriesArray+hCheckBoxObject.tickedCBoxArray;
userDefinedCatList=organisedCatList(find(userDefinedCategoriesArray));
close(checkBoxObject)
% Pushbutton callback
    function p_call(varargin)
%         This function cycles through each checkbox and gets its value.
%         There are more checkbox elements in the  handles structure than
%         checkboxes on the figure so this necessitates a for loop to
%         initially verify that each element is not null
        for checkBoxEL=1:length(hCheckBoxObject.cBox)
          if regexp(version,'R2014b|201[5-9][a|b]')
             checkboxPresent = isgraphics(hCheckBoxObject.cBox(checkBoxEL));
          else
             checkboxPresent = hCheckBoxObject.cBox(checkBoxEL);
          end
          if checkboxPresent
            try
            vals(checkBoxEL) = get(hCheckBoxObject.cBox(checkBoxEL),'Value');
            catch
                'error in assessing checkboxes';
                keyboard
            end
       end
        end
        hCheckBoxObject.tickedCBoxArray=vals;
        guidata(checkBoxObject,hCheckBoxObject)
        uiresume(checkBoxObject)
        
        
        
    end





end