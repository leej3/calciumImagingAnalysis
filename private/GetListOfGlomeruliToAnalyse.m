function [glomeruliInfo]=                                       GetListOfGlomeruliToAnalyse(glomeruliInfo,lsmDescriptors,reviewingStatus)
% this function returns glomeruliinfo with all the names fields filled out
% with the glomeruli to be edited, or saved at least.
%. if reviewingStatus>0 past information may is saved initially
% and then the users chooses a list of glomeruli both new and old to edit.
% if old glomeruli wish to be completely reanalysed they can simply be left
% out of the first dialogue. these choices occur in GetGlomeruliToKeep and
% GetGlomsToBeAnalysedWhenReviewing
defaultUserDefinedGloms = {'dm2l','dm2r','dm5l','dm5r','dm6l','dm6r','dm3l','dm3r','va3l','va3r','va6l','va6r','va2l','da1l','da1r','xxl','xxr'};
matFileName=GetMatFileName(lsmDescriptors.lsmFileName);
global figHandles
% Displaying maxmerged image of slices around the peak for obtaining
% user-defined list of glomeruli
if reviewingStatus==0
figure(99), subplot(figHandles.mergedImage), title(matFileName(1:end-4))
%     Obtaining glomeruli for analysis.if none are found in filename a
%     default list is used
userDefinedGloms=regexp(lsmDescriptors.lsmFileName,'[a-z][a-z][0-9][l/r] ','match');
userDefinedGloms=strtrim(userDefinedGloms);
if isempty(userDefinedGloms)
userDefinedGloms= defaultUserDefinedGloms;
end

else
%     Below function gets the user to choose which glomeruli to keep
%     information for. all other structure elements are deleted out of
%     glomeruliInfo.
[glomeruliInfo]=GetGlomeruliToKeep(glomeruliInfo);
userDefinedGloms=glomeruliInfo.glomeruliToKeep;
[silentGloms] = GetSilentGlomsFromFileName(lsmDescriptors.lsmFileName);
if isempty(userDefinedGloms) & isempty(silentGloms)
    reviewingStatus = 0;
     userDefinedGloms =defaultUserDefinedGloms;

end

end
userDefinedGloms = reshape(userDefinedGloms,length(userDefinedGloms),1);
% Requesting user-defined list of glomeruli to analyse their deltaFs
if reviewingStatus ==0
    
   userDefinedGloms = GetGlomsToBeAnalysedWhenNotReviewing(userDefinedGloms);
    for ii=1:length(userDefinedGloms)
            glomeruliInfo(ii+1).names=userDefinedGloms{ii};
    end
    glomeruliInfo(1).glomeruliToBeAnalysed=userDefinedGloms;

else
   userDefinedGloms=unique([silentGloms; reshape(glomeruliInfo(1).glomeruliToKeep,length(glomeruliInfo(1).glomeruliToKeep),1)]);
   glomeruliInfo(1).glomeruliToKeep  = userDefinedGloms;
   [glomeruliInfo]=GetGlomsToBeAnalysedWhenReviewing(glomeruliInfo,lsmDescriptors);
end



% 
% if isempty(glomeruliInfo(1).glomeruliToBeAnalysed)
% userAnswer=menu('Are you sure you don''t want to edit glomeruli?' ,{'yes','no'});
% if userAnswer==2
% disp('Try again!')
% % error('Have another go and edit the glomeruli this time')
% [glomeruliInfo]=GetGlomsToBeAnalysedWhenReviewing(glomeruliInfo,lsmDescriptors);
% end
% end


end

function [glomeruliInfo]=                                       GetGlomeruliToKeep(glomeruliInfo)
%  This function Gets a list of the original glomeruli polygons to keep and
%  deletes the remaining elements of the structure
emptyGlomeruliInfoElement=GetGlomeruliInfoElement;
originalGlomeruli=glomeruliInfo(1).originalGlomeruli;
if isempty(glomeruliInfo(1).originalGlomeruli)
return
end
glomeruliToKeepIndices=listdlg('ListString',[originalGlomeruli {'Do not keep any'}],'PromptString','Glomeruli to keep information for:','ListSize',[400 400]);
if glomeruliToKeepIndices > length(originalGlomeruli)
    glomeruliInfo = [glomeruliInfo(1)];
    return
end
glomeruliToKeep=originalGlomeruli(glomeruliToKeepIndices);
glomeruliToKeep = reshape(glomeruliToKeep,length(glomeruliToKeep),1);
glomeruliInfo(1).glomeruliToKeep=glomeruliToKeep;

outputStructureElement=1;

for glomToKeepThisCyc = 1:length(glomeruliToKeep)
    indiceOfNonEmpty = ~cellfun(@isempty,{glomeruliInfo.names});
    
glomToKeepThisCycleIndx=regexpcell({glomeruliInfo(indiceOfNonEmpty).names},glomeruliToKeep{glomToKeepThisCyc});
if ~isempty(glomToKeepThisCycleIndx)
outputStructure(outputStructureElement)=glomeruliInfo(glomToKeepThisCycleIndx);
outputStructureElement=outputStructureElement+1;
end
glomToKeepThisCycleIndx=[];
end

glomeruliInfo=[glomeruliInfo(1) outputStructure];
end




function [glomeruliInfo]=                                       GetGlomsToBeAnalysedWhenReviewing(glomeruliInfo,lsmDescriptors)
% called by GetListOfGlomsToBeAnalysed.
glomeruliToKeep = reshape(glomeruliInfo(1).glomeruliToKeep, length(glomeruliInfo(1).glomeruliToKeep),1);
indicesOfGlomsToAnalysis = listdlg('ListString',[{'BackGround'} ; glomeruliToKeep;{'Add more glomeruli'}; {'Do not edit any'}]);
indicesOfGlomsToAnalysis = indicesOfGlomsToAnalysis-1;
if find(indicesOfGlomsToAnalysis==0)
    backgroundEdit = 1;
       indicesOfGlomsToAnalysis(1)=[];%remove background as a glomerulus index
else
    backgroundEdit = [];
end


if find(indicesOfGlomsToAnalysis == length(glomeruliInfo(1).glomeruliToKeep)+2)
glomeruliInfo(1).coOrdinates=glomeruliInfo(1).originalCoOrdinates;
glomeruliInfo(1).meanBackGround=glomeruliInfo(1).originalMeanBackGround;  
    glomeruliInfo(1).glomeruliToBeAnalysed='';
    return
    
end
if find(indicesOfGlomsToAnalysis == length(glomeruliInfo(1).glomeruliToKeep)+1)
userResponse = inputdlg({'Add more glomeruli in format [a-z][a-z]number[l | r] separated by commas eg: dm2l,dm5r'});
extraGlomeruli = regexp(userResponse,'[a-z][a-z]\d[l r]','match');
extraGlomeruli = extraGlomeruli{:};
indicesOfGlomsToAnalysis(indicesOfGlomsToAnalysis == length(glomeruliInfo(1).glomeruliToKeep)+1) = [];
else 
    extraGlomeruli = {};
end
userDefinedGloms =glomeruliToKeep(indicesOfGlomsToAnalysis);
userDefinedGloms = [userDefinedGloms extraGlomeruli];
% this type of process is repeated in the GetGroups function if a similar and better example of the code is required.

  
if backgroundEdit & sum(glomeruliInfo(1).coOrdinates ~= glomeruliInfo(1).originalCoOrdinates)
% remove field thats background and make sure coordiates are changed.
% otherwise change the coordinates are back to original.
userDefinedGloms=[userDefinedGloms ; glomeruliInfo(1).glomeruliToKeep];
userDefinedGloms=unique(userDefinedGloms);
else
glomeruliInfo(1).coOrdinates=glomeruliInfo(1).originalCoOrdinates;
glomeruliInfo(1).meanBackGround=glomeruliInfo(1).originalMeanBackGround;
end


glomeruliInfo(1).glomeruliToBeAnalysed=userDefinedGloms;
glomeruliInfoElement=length(glomeruliInfo)+1;
for writingGlomCyc=1:length(userDefinedGloms)
if ~strcmp(userDefinedGloms{writingGlomCyc}, {glomeruliInfo.names})
glomeruliInfo(glomeruliInfoElement).names=userDefinedGloms{writingGlomCyc};
glomeruliInfoElement=glomeruliInfoElement+1;
end
end

end
function  [silentGloms] = GetSilentGlomsFromFileName(lsmFileName) 
    silentGloms=[];
   silentGloms =  regexp(lsmFileName,'[a-z][a-z][0-9][l/r]s','match');
   for ii = 1: length(silentGloms)
       silentGloms{ii} = silentGloms{ii}(1:end-1);
   end
   silentGloms = reshape(silentGloms,length(silentGloms),1);

end