function [fullDataSet] =                        DecodeGroups(fullDataSet)
groupValues =  [fullDataSet.groupCode];
if sum(cellfun(@isempty, regexp(groupValues, '[1:9]'))) 
    % no group codes assigned
    [fullDataSet.decodedGroup] = deal({'Not Assigned'});
else
groupsKeyEditedFully = 0;
% % Initialising groupsKey
if exist('groupsKey.mat','file')
    load groupsKey.mat
else groupsKey = [];
end
datesOfFullDataset = unique(cellfun(@(x) x{1},{fullDataSet.date},'UniformOutput',0));
if isempty(groupsKey) 
    groupsKey = GetGroupsKey(fullDataSet, datesOfFullDataset);
    groupsKeyEditedFully = 1;
else
    datesOfGroupsKey =  unique(cellfun(@(x) x{1},{groupsKey.date},'UniformOutput',0));
    datesNotYetEntered = unique(setdiff(datesOfFullDataset,datesOfGroupsKey));
    if ~isempty(datesNotYetEntered)
        additionalGroupsKey = GetGroupsKey(fullDataSet, datesNotYetEntered);
        groupsKey = [groupsKey, additionalGroupsKey];
    end
end

if ~groupsKeyEditedFully
    userYesNo = questdlg('Edit group codes for each date?');
    if strcmp(userYesNo,'Yes')
        groupsKey = [];
        groupsKey = GetGroupsKey(fullDataSet, datesOfFullDataset);
    end
end

%         Writing the group info to the structure:
[fullDataSet.decodedGroup] = deal({'Not Assigned'});
for dateElement = 1:length(groupsKey)
    relevantElementsForThisDate = regexpcell([fullDataSet.date],groupsKey(dateElement).date);
    for groupsOnThisDateElement = 1: length(groupsKey(dateElement).groups)
        try
            indicesForThisGroup = regexpcell([fullDataSet.groupCode],num2str(groupsOnThisDateElement));
            indicesForThisGroupAndDate = intersect(indicesForThisGroup,relevantElementsForThisDate);
        catch
            keyboard
        end
        if ~isempty(indicesForThisGroupAndDate)
            [fullDataSet(indicesForThisGroupAndDate).decodedGroup] = deal({groupsKey(dateElement).groups{groupsOnThisDateElement}});
        end

    end
end

% Not sure how the below code was particularly useful
% indicesOfUnAssignedValues = find(strcmp([fullDataSet.decodedGroup],'Not Assigned'));
% indicesOfFilledGenotypeValues = find(~strcmp([fullDataSet.genotype],'not specified'));
% indicesThatCanBeFilledIn = intersect(indicesOfUnAssignedValues,indicesOfFilledGenotypeValues);
% [fullDataSet(indicesThatCanBeFilledIn).decodedGroup] = fullDataSet(indicesThatCanBeFilledIn).genotype;
% for jj = 1:length(indicesThatCanBeFilledIn)
%     fullDataSet(indicesThatCanBeFilledIn(jj)).decodedGroup= {[fullDataSet(indicesThatCanBeFilledIn(jj)).decodedGroup{1} ', was not coded']};
% end

%  at this point it would be useful to get the user to select an indicator
%  variable that was coded so that these values can be assigned from the
%  decoded groups variable. but for now it'll be genotype
indicesOfUnFilledGenotypeValues = find(strcmp([fullDataSet.genotype],'not specified'));
indicesOfAssignedGroupValues = find(~strcmp([fullDataSet.decodedGroup],'Not Assigned'));
indicesThatCanBeFilledInGenotype = intersect(indicesOfAssignedGroupValues,indicesOfUnFilledGenotypeValues);
if ~isempty(indicesThatCanBeFilledInGenotype)

    userYesNo = questdlg(['Assign coded groups (' fullDataSet(1).decodedGroup ' etc.)  to Genotype?']);
    if strcmp(userYesNo,'Yes')
        for pp = 1:length(indicesThatCanBeFilledInGenotype)
            fullDataSet(indicesThatCanBeFilledInGenotype(pp)).genotype  = {[fullDataSet(indicesThatCanBeFilledInGenotype(pp)).decodedGroup{1}]};
        end
    end
end
end
function [groupsKey] =                          GetGroupsKey(fullDataSet, datesToDecode)
% Cycling through the dates and finding out the group identities
listOfGroups = GetGroups;
for ii = 1:size(datesToDecode,2)
    groupsKey(ii).date = datesToDecode(ii);
    groupsKey(ii).groups = [];
    endSignal = 1; groupsElement = 0;
    if length(listOfGroups) == 2
        groupsElement = groupsElement+1;
        groupsKey(ii).groups{groupsElement} = listOfGroups{1};
    else
        while endSignal ~= size(listOfGroups,1)
            groupsElement = groupsElement+1;
            userChoice = menu(['Date: ' datesToDecode(ii) ' Group' num2str(groupsElement)] , listOfGroups);
            groupsKey(ii).groups{groupsElement} = listOfGroups{userChoice};
            endSignal = userChoice;
        end
        groupsKey(ii).groups(groupsElement) = [];
    end

end
if isempty(groupsKey)
    errordlg('groupsKey not calculated')
else
    save groupsKey.mat groupsKey
end

function [listOfGroups] =                       GetGroups
listOfGroups= { ...
    'Homozygous Gh146>UASGC3';...
    'Homozygous Gh146>plotGC3';...
    'Syn Mutants';...
    'Syn Rescue in LNs';...
    'None of these'...
    };
extraGenotypes = {};
listOfGroupsIndicesToKeep = listdlg(...
    'ListString',...
    listOfGroups,...
    'PromptString',...
    'Select the required genotypes (permanent changes to this list can be made in the GetGroups function:','ListSize',[500 500]);
if sum(listOfGroupsIndicesToKeep) == length(listOfGroups)
    listOfGroups = {};
else
    listOfGroups = listOfGroups(listOfGroupsIndicesToKeep);
end
userChoice = questdlg('Add additional genotypes?','Adding more genotypes');
if strcmp(userChoice, 'Yes')
    extraGenotypesFromUser  = inputdlg('Add extra genotypes (genotypes should be placed in inverted commas and separated by commas) e.g. ''genotype 1'' , ''genotype 2''','Adding additional genotypes');
    eval(['extraGenotypes = {' extraGenotypesFromUser{1} '};'])
    extraGenotypes= reshape(extraGenotypes,length(extraGenotypes),1);
end
listOfGroups = [listOfGroups ; extraGenotypes];
if isempty(listOfGroups)
    listOfGroups = {'Undefined group coding'}
end
listOfGroups= [listOfGroups;'None'];
