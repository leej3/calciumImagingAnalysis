function [reviewingStatus, pic,lsmDescriptors, glomeruliInfo,userChoiceToAnalyseFile]...
    = LoadImageFile(currentMatFileName)

lsmDescriptors=InitialiseLsmDescriptors();
reviewingStatus=0; % default state unless a previous analysis is discovered
    [thisCycleFile, fileEditStatus] = LoadDeltaFMatVariable(currentMatFileName);
if ~fileEditStatus
    [glomeruliInfo] = InitialiseGlomeruliInfoStructure;
    [lsmDescriptors] = PopulateLsmDescriptors(thisCycleFile,lsmDescriptors);
    [pic] = ConvertStackInfoToPic(thisCycleFile);
    [lsmDescriptors] = GetApproxMaxIndx(pic,reviewingStatus,lsmDescriptors);
    %     [glomeruliInfo, displayPic, yLimOfGraph, h] =
    %     Display the unprocessed file to get a choice from the user
    [~,~,~,h] = SetupBackgroundGUI(lsmDescriptors, pic,glomeruliInfo);
    global figHandles,delete(h),axes(figHandles.mergedImage),title({'Unprocessed file';lsmDescriptors.lsmFileName})
    userChoiceToAnalyseFile = GetUsersChoiceForDeltaF;
else
    reviewingStatus = 2; % there was originally a 1
    % Loading previous data into the final output
    [lsmDescriptors, glomeruliInfo,pic,userChoiceToAnalyseFile] = LoadPreviousInfoAndDisplayReview(thisCycleFile,lsmDescriptors);
end



function [lsmDescriptors]...
    = PopulateLsmDescriptors(stackInfo,lsmDescriptors)
%returns lsmDescriptors: timeInterval sliceNumber originalLength,
lsmInfo=stackInfo.lsm;
lsmDescriptors.timeInterval=lsmInfo.TimeInterval;
lsmDescriptors.sliceNumber=length(stackInfo);
lsmDescriptors.originalLength=lsmDescriptors.sliceNumber;
% Extracting file name for purposes of saving and finding previous runs.
folderSeparatorVariable = filesep;
slashes =find(stackInfo(1).filename==folderSeparatorVariable);
lastslash =slashes(end);
lsmDescriptors.lsmFileName=stackInfo(1).filename(lastslash+1:end);


function [lsmDescriptors,glomeruliInfo,pic,userChoiceToAnalyseFile]...
    =  LoadPreviousInfoAndDisplayReview(previousGlomeruliInfo,lsmDescriptors)
% glomeruliInfo, the main structure for data in the code, is reloaded here.
global figHandles
glomList=[];
%     Loading previous matFile into glomeruliInfo. loading glomNames.
glomNames={previousGlomeruliInfo(2:end).names};
previousGlomeruliInfo(1).originalGlomeruli=glomNames;
previousGlomeruliInfo=CheckFieldNames(previousGlomeruliInfo,2);
glomeruliInfo=previousGlomeruliInfo;

%     To extract lsmDescriptors and stackInfo variables.
stackInfo=glomeruliInfo(1).previousLsmInfo.stackInfo;
[pic] = ConvertStackInfoToPic(stackInfo);
lsmDescriptors=glomeruliInfo(1).previousLsmInfo.lsmDescriptors;
lsmDescriptors= CheckFieldNames(lsmDescriptors,1);
if isempty(lsmDescriptors.comments)
    lsmDescriptors.comments={' '};
end
% Original position of Background
glomeruliInfo(1).originalCoOrdinates=glomeruliInfo.coOrdinates;
glomeruliInfo(1).originalMeanBackGround=glomeruliInfo(1).meanBackGround;

%   More details for cropping information
lsmDescriptors.originalMaxIndx=lsmDescriptors.approxMaxIndx;%all gloms reedited if not the same later
lsmDescriptors.originalSlicesCroppedFromStart=lsmDescriptors.slicesCroppedFromStart;

[~,~,~,h] = SetupBackgroundGUI(lsmDescriptors, pic,glomeruliInfo);
% if previous glom info exist then plot it
axes(figHandles.heatMapFigure), xlabel(lsmDescriptors.comments)
onsetChoices = GetOnsetChoices;
if   ~isempty(onsetChoices) && sum(strcmp(onsetChoices(:,1), lsmDescriptors.lsmFileName))
    onsetChoicesForThisFile = onsetChoices{strcmp(onsetChoices(:,1), lsmDescriptors.lsmFileName),2};
else onsetChoicesForThisFile = 'undefined';
end
axes(figHandles.plotFigure), cla
plot([glomeruliInfo.plot])
legendLabel = strcat({glomeruliInfo(2:end).names}, deal(' onset was : ') ,cellfun(@num2str ,{ glomeruliInfo(2:end).sliceNumberOfResponseOnset},'UniformOutput',0));
legend(legendLabel)
xlabel('SliceNumber'),ylabel('Raw Fluorescence')
title(['(onset time : ' num2str(onsetChoicesForThisFile)  ')'])

%    Extracting info for each glom and adding ROIs to review image.
axes(figHandles.mergedImage)
polyStructEl=1;
for glomCyc=1:length(glomNames)
    glomList=[glomList ' ' glomeruliInfo(glomCyc+1).names ': ' num2str(glomeruliInfo(glomCyc+1).peakOfInterpedCurve) ', '];


    if isempty(glomeruliInfo(glomCyc+1).coOrdinates)
        glomeruliInfo(glomCyc+1) = [];
        errordlg(['Info not saved on' glomeruliInfo(glomCyc+1).names])
        continue
    end

    polyStruct{polyStructEl}= impoly(gca,glomeruliInfo(glomCyc+1).coOrdinates);
    polyStructEl=1+polyStructEl;


end

%     Adding title and labels to the review image
figure(99), subplot(figHandles.mergedImage),title([glomList]),xlabel(lsmDescriptors.lsmFileName)
drawnow
[ userChoiceToAnalyseFile] = GetUsersChoiceForDeltaF;
disp(glomList)
delete(h)
for pStructCyc=(polyStructEl-1):-1:1
    delete(polyStruct{pStructCyc})
end


function [lsmDescriptors]...
    = GetApproxMaxIndx(pic,reviewingStatus,lsmDescriptors)
lsmDescriptors.meanOfSlices=squeeze(mean(mean(pic)));
if reviewingStatus==0
    [lsmDescriptors.approxMax,lsmDescriptors.approxMaxIndx]=max(lsmDescriptors.meanOfSlices);
end

if lsmDescriptors.approxMaxIndx<8 | lsmDescriptors.approxMaxIndx>lsmDescriptors.sliceNumber-8
    lsmDescriptors.approxMaxIndx=ceil(lsmDescriptors.sliceNumber/2);
end



function [pic] = ConvertStackInfoToPic(stackInfo)
pic=[stackInfo.data];
pic=reshape(pic,stackInfo(1).width,stackInfo(1).height,length(stackInfo));
save('temporaryStackInfo.mat', 'stackInfo')

function   [glomeruliInfo] = InitialiseGlomeruliInfoStructure
emptyGlomeruliInfoElement= GetGlomeruliInfoElement;
glomeruliInfo=repmat(emptyGlomeruliInfoElement,1,10);
glomeruliInfo(1).coOrdinates=[256 256 35 35];


