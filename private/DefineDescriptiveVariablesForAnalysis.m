function [userInput, fieldsStruct] = DefineDescriptiveVariablesForAnalysis(userFolder,userInput)
    fieldsStruct=getFields;
    fieldsStruct= GetUserFieldChoice('cycle2',fieldsStruct);
    fieldsStruct= GetUserFieldChoice('cycle1',fieldsStruct);

    fieldsStruct= GetUserFieldChoice('compare',fieldsStruct);
% Get rid of rows that are not included in the users choice of fields
fieldsStruct=defineFieldsToInclude(fieldsStruct,userInput);
cellForGUI= fieldsToCell(fieldsStruct.list);
% % Messiness at this point. mainly because i didnt want to rewrite
% fieldGUI. so  i've converted the list of fields in fieldsStruct into a
% cell (cellForGUI) passed it to FieldsGUI and then remove the appropriate
% subFields from fieldsStruct. then i remove the corresponding elements
% from the data structure userInput.
[cellForGUI,additionalFieldNames] = RemoveFieldsWith1Element(cellForGUI);
userDefinedFields=FieldsGUI(cellForGUI);
userDefinedFields=[userDefinedFields additionalFieldNames];
fieldsStruct = extractUserDefinedFields(userDefinedFields , fieldsStruct);
userInput=RefineDataAccordingToEliminatedSubFields(fieldsStruct,userInput);
save('fieldsStruct.mat','fieldsStruct')
end
function [fieldsStruct]=                              getFields()
fieldsStruct.list=struct(...
'glomerulus',[],...
'odour',[],...
'concentration',[],...
'groupCode',[],...
'treatedOrNot',[],...
'date',[],...
'fluorophore',[],...
'decodedGroup',[],...
'trpActivity',[],...
'temperature',[],...
'dissecter',[],...
'endTag',[],...
'concentrationBatch',[],...
'fly',[],...
'run',[],...
'genotype',[],...
'subRun',[]);


end
function [fieldsStruct]=                              GetUserFieldChoice(modeVar,fieldsStruct)


userChoiceList=[fieldnames(fieldsStruct.list)];

switch lower(modeVar)
   case 'compare'
    titleString = 'Choose a field to compare:';
   case 'cycle1'
      titleString = 'Choose a field to cycle through:';
   case 'cycle2'
      titleString = 'Choose a field to cycle through:';
end





indexOfChoice=menu(titleString,userChoiceList);

userChoice=userChoiceList{indexOfChoice};

switch lower(modeVar)
   case 'compare'
    fieldsStruct.fieldToCompare=userChoice;
   case 'cycle1'
      fieldsStruct.fieldForCycling=userChoice;
  case 'cycle2'
  fieldsStruct.fieldForCycling2=userChoice;
end



end
function [fieldsStruct]=                              defineFieldsToInclude(fieldsStruct,userInput)
% return the field structure with all possible values for each field
 fieldListCell=fieldnames(fieldsStruct.list);
    for ii=1:length(fieldListCell)

            if sum(strcmp(fieldListCell{ii},fieldnames(userInput)))
        fieldsStruct.list.(fieldListCell{ii})=unique([userInput.(fieldListCell{ii})]);
            else
               fieldsStruct.list.(fieldListCell{ii}) = [];
               [userInput.(fieldListCell{ii})] = deal([]);
            end

    end
end
function [cellForGUI] =                         fieldsToCell(fields)
% made a change here and said cellForGUI to make it slightly clearer.
% hoping fieldsToCell isn't used elsewhere...
fieldListCell=fieldnames(fields);
cellForGUIElement=1;
    for ii = 1:length(fieldListCell)
        cellForGUI{cellForGUIElement}=['Field:' fieldListCell{ii}];
        cellForGUIElement=cellForGUIElement+1;

        subFields = fields.(fieldListCell{ii});
        for jj = 1: length(subFields)
          try
            cellForGUI{cellForGUIElement}= subFields{jj};
          catch
              keyboard
          end
            cellForGUIElement=cellForGUIElement+1;
        end
    end
end
function [cellForGUI, additionalFieldNames] = RemoveFieldsWith1Element(cellForGUI)
fieldTitles = find(~cellfun(@isempty, regexp(cellForGUI,'Field')));
fieldsWith1Element=[diff(fieldTitles)==2 , 0];
% last field is displayed even if it has just one value
fieldListEL=1;
elementsToDelete=[];
       while fieldListEL ~= length(cellForGUI)

           isElementOfTitleList = findstr(fieldListEL,fieldTitles);
          if isElementOfTitleList == length(fieldTitles)

%               elementsToDelete=[elementsToDelete fieldTitles(end):length(cellForGUI)];
%               fieldListEL = length(cellForGUI);
%               continue
%bizarre bit of coding here. not sure what happened but for some reason i
%was insisting on deleting the last field. i've now insisted on keeping
%it...

          end

          if isElementOfTitleList

              if fieldsWith1Element(isElementOfTitleList)
                  elementsToDelete= [elementsToDelete fieldTitles(isElementOfTitleList):(fieldTitles(isElementOfTitleList+1)-1)];
                  fieldListEL=fieldTitles(isElementOfTitleList+1);
                  continue
              end


          end
          fieldListEL=fieldListEL+1;
       end
       additionalFieldNames=cellForGUI(elementsToDelete);
       cellForGUI(elementsToDelete)=[];
    end


function [fieldsStruct ] =                      extractUserDefinedFields(userDefinedFields, fieldsStruct)
fieldTitleElements=regexpcell(userDefinedFields,'Field');
fieldListCell=userDefinedFields(fieldTitleElements);%still includes 'Field' but removed in loop

for fieldListElement = 1: length(fieldListCell)
try
    fieldListCell{fieldListElement}=fieldListCell{fieldListElement}(7:end);
    if fieldListElement == length(fieldListCell)
     fieldsStruct.list.(fieldListCell{fieldListElement})=userDefinedFields(fieldTitleElements(fieldListElement)+1:end);
    else
        fieldsStruct.list.(fieldListCell{fieldListElement})=userDefinedFields(fieldTitleElements(fieldListElement)+1:fieldTitleElements(fieldListElement+1)-1);
    end
catch
    keyboard
end
end
end


function [userDefinedFields]=                   deleteUnneededCatTitles(userDefinedFields)
% Obtaining the indices of all the field headers and checking where they
% are not followed by subfields. An array is created to list the
% indices that arent so they can be deleted
catTitles=strmatch('Field',userDefinedFields);
catTitlesToDelete=[];
catTitlesToDeleteEL=1;
for catTitleEL=2:length(catTitles)
    if catTitles(catTitleEL-1)==catTitles(catTitleEL)-1
        catTitlesToDelete(catTitlesToDeleteEL)=catTitles(catTitleEL-1);
        catTitlesToDeleteEL=catTitlesToDeleteEL+1;
    end

end
% Making sure the last element of userDefinedFields is not a title.
if catTitles(end)==length(userDefinedFields)
    catTitlesToDelete(catTitlesToDeleteEL)=length(userDefinedFields);
end

userDefinedFields(catTitlesToDelete)=[];
end
