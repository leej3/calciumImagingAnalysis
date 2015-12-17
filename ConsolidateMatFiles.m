function [fullDataSet] = ConsolidateMatFiles()
% Naming the file:
% EXAMPLE: GH146Gal4UASGC5trpA1 f##R##X t##C GrpS ##OCT FLt2GC5 s1trpA1p
% DM5l DM5r DM6l DM3r DM3l VA6r 2012-03-03 DM2ls DM2rs.lsm where # is a number
% Fly,Run and Sub-Run helps to provide some structure to the data collection.
 % This should be in the format f03r02a where the run is each train of stimuli
% given(these will be averaged for an n value) and each subrun (if it is necessary in describing
% the organisation of the data collected) is described by a lower
% case letter.
% Genotype: a label that precedes the fly and run number
% Date: found by 8 consecutive numbers (ignoring spaces,'.' and '-'). the
% format should be yyyy-mm-dd
% Fluorophore: Recognised by FL followed by t or s,a number and 3 more characters.
% the first character is the effector sequence (t for pLot or s for UAS).
 % the second character is the number of copies expressed.
% Temperature: t##C defines the temp the reservoir was at.
% TrpA1: s1trpA1d is recognised as trpA1 being driven in the fly. again s
% or t denote the construct type and 1 is the number of transgenes
% expressed

% Odours are defined using three letters (see the GetOdours function) The concentration
% is represented as 2 numbers after the odour giving the two numbers for scientific notation)
% The Glomeruli will also be listed, followed by t or b
% TODO: 
%  add in alternative get display pic

% Defining the directory to work in and matfile-list
[baseDir,files,saveName]=GetFiles;


% Filtering filenames
files= FilterFiles(files);

%Filter out all but runs 1-8
% disp('Filtering out all runs but 1-8')
% files= files(regexpcell(files,'f\d\dr0[1-8][a-z]'));

fullDataSet = GetFullDataSet(files);

fullDataSet = DecodeGroups(fullDataSet);

save(saveName , 'fullDataSet')

if ishandle(999)
    close(999)
end
%  ebtResponses=fullDataSet(regexpcell([fullDataSet.odour],'ebt'));
%  OneConcentrationResponse=fullDataSet(regexpcell([fullDataSet.concentration],'52'));

%
%=========================================
function [fullDataSet] =                    GetFullDataSet(files)
onsetChoices = GetOnsetChoices;
fullDataSet=[];

odours=GetOdours;
[timeSeriesDescriptors,treatment]=          GetFileConsolidationParameters;
pause(1)

h = waitbar(0,'Please wait...');
max_count = length(files);



fileIndex = 1;
for fileIndex = 1:length(files)
    [thisCycleFile, fileEditStatus] = LoadDeltaFMatVariable(files{fileIndex});
    if ~fileEditStatus
        disp(['Skipping unprocessed file :' files{fileIndex}])
        continue
    end

    %     Assigning the various salient bits of data.
    fileName=thisCycleFile(1).previousLsmInfo.lsmDescriptors.lsmFileName;
    [thisCycleFile.fileName]=           deal(fileName);
    thisCycleFile   =                   CheckStatus(thisCycleFile);
    %     [thisCycleFile] =                   AddSilentGloms(thisCycleFile);
    [fly,run,subRun]=                   GetStimID(fileName);
    [thisCycleFile.fly] =               deal(fly);
    [thisCycleFile.run] =               deal(run);
    [thisCycleFile.subRun] =            deal(subRun);
    [thisCycleFile.comments] =          deal(GetComments(thisCycleFile));
    [thisCycleFile.odour] =             deal(GetOdour(fileName,odours));
    [thisCycleFile.concentration] =     deal(GetConcentration(fileName,thisCycleFile(1).odour));
    [thisCycleFile.groupCode] =         deal(GetGroupCode(fileName));
    [thisCycleFile.treatedOrNot] =      deal(GetTreatmentStatus(fileName,treatment));
    [thisCycleFile.date] =              deal(GetDateString(fileName));
    [thisCycleFile.fluorophore] =       deal(GetFluorophore(fileName));
    [thisCycleFile.trpActivity] =       deal(GetTrpActivity(fileName));
    [thisCycleFile.temperature] =       deal(GetTemp(fileName));
    [thisCycleFile.dissecter] =         deal(GetDissecter(fileName));
    [thisCycleFile.endTag] =            deal(GetEndTag(fileName));
    [thisCycleFile.genotype] =          deal(GetGenotype(fileName));
    thisCycleFile =                     GetBatch(thisCycleFile);
    [thisCycleFile] =                   ResampleIfNecessary(fullDataSet,  thisCycleFile,timeSeriesDescriptors) ;

    %     choose onset time
    [onsetChoices, skipFile] = CheckOnsetTimeHasBeenDefinedForThisFile(files, fileIndex, thisCycleFile, onsetChoices,timeSeriesDescriptors);
    if skipFile
        continue
    end
    for fileElements= 1:length(thisCycleFile)
     %       Cycling through the glomeruli to extract curve information
        thisCycleFile(fileElements).extrapolated = {''};
        nameOfGlom = thisCycleFile(fileElements).names;
        nameOfGlom(find(isspace(nameOfGlom))) = [];
        thisCycleFile(fileElements).names = {nameOfGlom};
        if ~strcmp(thisCycleFile(fileElements).names,'BackGround')
            thisCycleFile(fileElements).glomSide = {thisCycleFile(fileElements).names{1}(4)};
            thisCycleFile(fileElements).glomerulus = {thisCycleFile(fileElements).names{1}(1:3)};
        end
    end
    clear fileElements


    %     Extracting list of named fields
     thisCycleFile= ExtractDesiredFields(thisCycleFile);
    %   Getting rid of background element
    thisCycleGloms=thisCycleFile(2:end);

    %   Attaching to end of the output.
    fullDataSet= [fullDataSet, thisCycleGloms];


    waitbar(fileIndex / max_count)
    save('onsetChoices.mat','onsetChoices')
end

close(h)
function [baseDir,files,saveName]=          GetFiles()
baseDir=uigetdir;
cd(baseDir)
[upperPath, saveName, ~] = fileparts(baseDir);
files=getfield(what,'mat');
if isempty(files)
    errordlg('Error finding matfiles','You may have chosen the wrong directory')
    pause(2)
    error('files not found')
end

function [thisCycleFile] =                  AddSilentGloms(thisCycleFile)
fileName=thisCycleFile(1).previousLsmInfo.lsmDescriptors.lsmFileName;
silentGloms = regexp(fileName, '[a-z][a-z][0-9][l/r]s', 'match');
cycleFileElement=length(thisCycleFile)+1;

for ii = 1:length(silentGloms)
    %        each silent glomerulus is assigned to a new element:
    thisCycleFile(cycleFileElement).status = 'Silent';
    thisCycleFile(cycleFileElement).names = silentGloms{1}(1:end-1);
    thisCycleFile(cycleFileElement).fileName = thisCycleFile(1).fileName;
    cycleFileElement=cycleFileElement+1;
end

function [treatmentStatus]=                 GetTreatmentStatus(fileName,treatment)
treated=[];
treated=regexp(fileName,treatment,'match');
if strcmp(treated{1},treatment)
    treatmentStatus={'Post'};
else
    treatmentStatus={'Pre'};
end

function [groupCode] =                      GetGroupCode(fileName)
groupCode=[];
groupCodeIndex=regexp(fileName,'Grp[1-9]');
groupCode = {fileName(groupCodeIndex+3)};

if isempty(groupCode{1})
    %     In case the groups are letters instead of numbers they are
    %     converted...
    groupCodeIndex=regexp(fileName,'Grp[A-Z]');
    groupCode = {fileName(groupCodeIndex+3)};
    groupCode{1} = num2str(groupCode{1}-64);
    if isempty(groupCode{1})
        groupCode={'X'};
    end
end

function [dateStr]=                         GetDateString(fileName)
dateStr=char(regexp(fileName,'20[1-2][2-9]\d\d\d\d','match'));
if isempty(dateStr)
    dateStr={'noDate'};
else
    dateStr = {[dateStr(1:4) '/' dateStr(5:6) '/' dateStr(7:8)] };
end

function [fluorophore]=                     GetFluorophore(fileName)
fluorophore=[];
fluorphore=regexp(fileName,'FL[s|t]\d...');
if isempty(fluorophore)
    fluorophore={'no info'};
end

function [trpActivity]=                     GetTrpActivity(fileName)
trpActivity=[];
trpActivity=regexp(fileName,'[t|s|q]\dtrpA1[d|p]','match');
if isempty(trpActivity)
    trpActivity = {'not present'};
end

function [temperature]=                     GetTemp(fileName)
temperature=[];
temperature=regexp(fileName,'t\d\d\C','match');
if isempty(temperature)
    temperature={'t99C'};
end

function [fly,run,subRun]=                  GetStimID(fileName)
[fly,run,subRun] = deal({'0'});
dateString=GetDateString(fileName);
sampleNum = regexp(fileName,'f\d\dr\d\d[a-z]','match');
if ~isempty(sampleNum)
    sampleNum=sampleNum{1};
    fly={[sampleNum(2:3) '.' dateString{1}]};
    run={sampleNum(5:6)};
    subRun={sampleNum(7)};
end




function [dissecter]=                       GetDissecter(fileName)
dissecter=[];
dissecters={'Adrian','Isabell', 'John'};

for dissectersEl=1:length(dissecters)

    if findstr(dissecters{dissectersEl},fileName)
        dissecter={dissecters{dissectersEl}};

    end
end
if isempty(dissecter)
    dissecter={'unknown'};
end

function [concentration]=                   GetConcentration(fileName,odour)
concentration=[];
odourStringIndx=regexp(fileName,odour);
if isempty(odourStringIndx{1})
    concentration={'00'};
else
    concentration={fileName(odourStringIndx{1}-2:odourStringIndx{1}-1)};
end

function [odour] =                          GetOdour(fileName,odours)
odour=[];
for ii=1:length(odours)

    odour= regexp(fileName, odours{ii},'match');
    if ~isempty(odour)
        break
    end
end
if isempty(odour)
    odour={'ODR'};
end

function [odours] =                         GetOdours()
odours={'bnk';'ebt';'eht';'oct';'lnl';'ipa';'e3b';'yst';'eat';'bzd';'hxl'};

function [endTag] =                         GetEndTag(fileName)
endOfDateIndx=regexp(fileName,'201[2-9]\d\d\d\d','end');
endTag=fileName(endOfDateIndx:end-4);

endTag=regexp(endTag, 'F[1-2]','match');
if isempty(endTag)
    endTag={'noInfo'};
end

function [genotype] =                       GetGenotype(fileName)
genotype=regexp(fileName,'Gen[A-Z|a-z]+\.','match');

if isempty(genotype)
    genotype={'not specified'};
else
    genotype={genotype{1}(4:end-1)};

end

function [comments] =                       GetComments(thisCycleFile)
comments = thisCycleFile(1).previousLsmInfo.lsmDescriptors.comments;

function [onsetChoices, skipFile] = CheckOnsetTimeHasBeenDefinedForThisFile(files, fileIndex, thisCycleFile, onsetChoices,timeSeriesDescriptors)
skipFile = 0;
if ~timeSeriesDescriptors.triggerUsed && length(thisCycleFile) >1
    if   isempty(onsetChoices) || ~sum(strcmp(onsetChoices(:,1), thisCycleFile(1).fileName))
            %% choose the onset time for a file
            [onsetChoices,skipFile] =   ChooseOnsetTime(files,fileIndex,onsetChoices,thisCycleFile);
    else
             %% choice already made
            if fileIndex == 1
                disp('Previously entered onset times can be removed from the ''onsetChoices.mat'' variable if required')
            end
    end
end



function [outputStructure] =                ExtractDesiredFields(thisCycleFile)
% adding fieldnames to the structure? u may want to add it to thisCycleFile
% too. go to AddExtraFieldsToThisCycleFile. might have been made obsolete and
% changed to CheckField
desiredFieldNames = {...
    'names'
    'glomerulus'
    'status'
    'meanBackGround'
    'plot'
    'timeVec'
    'odour'
    'fileName'
    'concentration'
    'groupCode'
    'genotype'
    'treatedOrNot'
    'date'
    'fluorophore'
    'trpActivity'
    'temperature'
    'endTag'
    'fly'
    'run'
    'subRun'
    'concentrationBatch' %just for the concentrations experiment
    'comments'
    'glomSide'
    'decodedGroup'
    'dissecter'};
for ii= 1: length(desiredFieldNames)
        [outputStructure(1:length(thisCycleFile)).(desiredFieldNames{ii})] = deal(thisCycleFile.(desiredFieldNames{ii}));
end


function [glomNamesOfThisLoop,individualSubRunStruct]=                      CheckGlomNameAcceptability(glomNamesOfThisLoop,individualSubRunStruct,primaryField,silent)
originalGlomNames=glomNamesOfThisLoop;structureEdited=0;
if exist( 'silent', 'var');
    silentGloms=1;
else
    silentGloms=0;
end

glomNameAcceptability=regexp(glomNamesOfThisLoop,'[A-Z][A-Z]\d[t|b]');
for k=1:length(glomNameAcceptability)
    if isempty(glomNameAcceptability{k})
        prompt={'Enter acceptable Glom Name of format X X N t/b (s):'};
        dlg_title = 'Error in Glom Name';
        num_lines = 1;
        def = glomNamesOfThisLoop(k);
        glomNamesOfThisLoop(k) = inputdlg(prompt,dlg_title,num_lines,def);
        if silentGloms
            [individualSubRunStruct]=ReWriteSilentGlomsInStruct(individualSubRunStruct,primaryField,glomNamesOfThisLoop);
        else
            individualSubRunStruct=ReWriteFieldNameInStruct(individualSubRunStruct,primaryField,originalGlomNames{k},glomNamesOfThisLoop{k});
        end
        structureEdited=1;
    end
end
if structureEdited
    if silentGloms
        activeGloms=fieldnames(individualSubRunStruct.(primaryField{1}));
        saveName=[individualSubRunStruct.(primaryField{1}).(activeGloms{1}){1,1} '.mat'];
    else
        saveName=[individualSubRunStruct.(primaryField{1}).(glomNamesOfThisLoop{1}){1,1} '.mat'];
    end
eval([primaryField{1} '=individualSubRunStruct.(primaryField{1})'])
    eval(['save ' saveName ' ' primaryField{1}])
end
    

function [individualSubRunStruct]=                                          ReWriteSilentGlomsInStruct(individualSubRunStruct,primaryField,glomNamesOfThisLoop)
glomNamesOfThisLoop=reshape(glomNamesOfThisLoop,1,length(glomNamesOfThisLoop));
for k=1:length(glomNamesOfThisLoop)-1
    glomNamesOfThisLoop{k}=[glomNamesOfThisLoop{k} ' '];
end
silentGlomsString=char(cell2mat(glomNamesOfThisLoop));
fieldNames=fieldnames(individualSubRunStruct.(primaryField{1}));
individualSubRunStruct.(primaryField{1}).(fieldNames{1}){22,5}=silentGlomsString;

function [individualSubRunStruct]=                                          ReWriteFieldNameInStruct(individualSubRunStruct,primaryField,originalGlomName,glomNamesOfThisLoop)
renamedField=individualSubRunStruct.(primaryField{1}).(originalGlomName);
individualSubRunStruct.(primaryField{1}).(glomNamesOfThisLoop)=renamedField;
individualSubRunStruct.(primaryField{1})=rmfield(individualSubRunStruct.(primaryField{1}),originalGlomName);

function [lengthOfData] =                                                   GetDataLength(dataForThisGlom)
%         Length of the columns containing data
emptyCells=zeros(length(dataForThisGlom),1);
for findingdatalength=1:length(dataForThisGlom)
    emptyCells(findingdatalength,1)=isempty(dataForThisGlom{findingdatalength,2});
end
lengthOfData=find(emptyCells==0,1,'last');

function thisCycleFile   =                   CheckStatus(thisCycleFile)
%% think the 'silent' classification is now obsolete
[thisCycleFile( cellfun(@isempty,{thisCycleFile.status})).status] = deal('Active');
