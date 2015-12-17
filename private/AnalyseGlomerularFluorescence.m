function [matFileName] = AnalyseGlomerularFluorescence(reviewingStatus, pic, lsmDescriptors, glomeruliInfo, displayPic,currentMatFileName)
    global figHandles

[glomeruliInfo,userDefinedGloms] =  CheckGlomeruliToBeAnalysed(glomeruliInfo);

if ~isempty(userDefinedGloms)
    for glomCycle=1:length(userDefinedGloms)

        [thisCycleGlom,glomeruliInfoElement] = InitialiseGlomerulusInformation(userDefinedGloms,glomCycle,glomeruliInfo,lsmDescriptors);
        [thisCycleGlom,dispMask] = GetGlomerulusInfo(lsmDescriptors, pic,thisCycleGlom,displayPic   );
        glomeruliInfo = WriteDataToGlomeruliInfo(pic,lsmDescriptors,glomeruliInfo, thisCycleGlom, dispMask,glomeruliInfoElement);
    end
end

[matFileName] = SaveInformationForThisImageFileAndCloseFigures(pic, lsmDescriptors, glomeruliInfo, currentMatFileName);



function [lsmDescriptors]=                                      GetUserComments(lsmDescriptors)

lsmDescriptors.comments=inputdlg('Enter any comments that you may deem fit for inclusion in the textual display lying below herewith...','Comments',[1 100],lsmDescriptors.comments);




function []=                                                    SaveActualOutput(actualOutput,matFileName)

eval([matFileName(1:end-4) '=actualOutput;']);
save(matFileName, matFileName(1:end-4))




function [thisCycleGlom,glomeruliInfoElement] = InitialiseGlomerulusInformation(userDefinedGloms,glomCycle,glomeruliInfo,lsmDescriptors)
RoiThisCycle=userDefinedGloms{glomCycle};
glomeruliInfoElement=regexpcell({glomeruliInfo(2:end).names},RoiThisCycle)+1;
thisCycleGlom=glomeruliInfo(glomeruliInfoElement);
thisCycleGlom.cycleNum=glomCycle;
thisCycleGlom.meanBackGround=glomeruliInfo(1).meanBackGround;
if isempty(thisCycleGlom.approxMaxIndx)
    thisCycleGlom.approxMaxIndx=lsmDescriptors.approxMaxIndx;
end

function [glomeruliInfo,userDefinedGloms] =  CheckGlomeruliToBeAnalysed(glomeruliInfo);
%  Provided there are glomeruli to be analysed cycle through them and get
%  all the information...
userDefinedGloms=glomeruliInfo(1).glomeruliToBeAnalysed;

%Deleting unused elements from glomeruliInfo:
glomeruliInfo(cellfun(@isempty,{glomeruliInfo.names}))=[];


function [glomeruliInfo] =  WriteDataToGlomeruliInfo(pic,lsmDescriptors,glomeruliInfo, thisCycleGlom, dispMask,glomeruliInfoElement)
%        Saving heatMap specific to each glomerulus
[heatMap, heatMapMasked]=GetHeatMap(pic,lsmDescriptors,dispMask);
thisCycleGlom.heatMap = heatMap;
% Writing to output variable:
glomeruliInfo(glomeruliInfoElement)=thisCycleGlom;
figure(gcf)

function [matFileName] = SaveInformationForThisImageFileAndCloseFigures(pic, lsmDescriptors, glomeruliInfo,currentMatFileName)
global figHandles

lsmDescriptors=GetUserComments(lsmDescriptors);
DisplayReviewFigure(glomeruliInfo);
matFileName=GetMatFileName(lsmDescriptors.lsmFileName);
glomeruliInfo(1).previousLsmInfo.lsmDescriptors=lsmDescriptors;


load('temporaryStackInfo.mat');
glomeruliInfo(1).previousLsmInfo.stackInfo=stackInfo;

SaveActualOutput(glomeruliInfo,matFileName);




disp(matFileName)
 %(20/02/2014: For older file eradication!)
if ~strcmp(matFileName,currentMatFileName)
    delete(currentMatFileName)
    disp(['deleting old file ' currentMatFileName])
end
