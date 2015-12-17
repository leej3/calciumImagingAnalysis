function [userInputSubset]=                     RefineDataAccordingToEliminatedSubFields(fieldsStruct,userInput)
fieldListCell=fieldnames(fieldsStruct.list);
userInputSubset=userInput;
for ii= 1 : length(fieldListCell)
  try
      if sum(strcmp(fieldnames(userInputSubset),fieldListCell{ii})) % field exists in dataset
    if sum(cellfun(@isempty,{userInputSubset.(fieldListCell{ii})}))
        errordlg([fieldListCell{ii} ' has empty elements. not using as filter'] )
    else
fieldValsToKeep = [fieldsStruct.list.(fieldListCell{ii})];
fieldValsForDataset = [userInputSubset.(fieldListCell{ii})];
elementsToDelete = false(1,length(fieldValsForDataset));
fieldValuesToDelete = setdiff(fieldValsForDataset,fieldValsToKeep);
for jj = 1: length (fieldValuesToDelete)
    indicesForThisValue = strcmp(fieldValsForDataset,fieldValuesToDelete{jj});
    elementsToDelete = indicesForThisValue | elementsToDelete;
end
    end
      else
          errordlg([fieldListCell{ii} ' doesn''t exist as a field. not using as filter'] )
          continue
      end
  catch
      keyboard
  end
    % potential issue in this bit of code when the token compared to the
    % main user data does not match because it is a cell within a cell. eg
    % {{''}}. So when checked  token = {' '} rather than token = '' . I
    % fixed this issue in all but the older consolidated files. which all
    % contain the same error and so would all be discounted and the filter
    % criteria would be ignored. So very unlikely to cause issue.
    if sum(elementsToDelete) == length(userInputSubset)
errordlg(['Criteria for filtering ignored:' fieldListCell{ii} '. (Would discount all data)'])
continue
    end
    if sum(elementsToDelete)
    userInputSubset(elementsToDelete)=[];
    end
end

end