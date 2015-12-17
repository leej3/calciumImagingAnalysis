function [matDir, matFileNamesSelectedByUser] =  InitialiseFiles()
% The GetMatDir function opens a user-selected
% directory and checks if a Matfiles directory exists within it.
%  If no such directory exists, one is created and populated with
% matfiles generated by the MatFileInitialisation function. These
% matfiles are of the  structure datatype (and can be generated using the
% CheckFieldNames function) that store all basic information regarding
% the fluorescence time-series and the ROIs selected by the user. The
 % MatfileInitialisation function could be edited to convert files
 % other than the .lsm file format into such a matfile.

close all

%    Asking user for folder to work with. if folder contains lsm files a
%    matDir is created and initialises matlab variables to work with
[matDir] = GetMatDir();
% Changing to matFile directory
cd(matDir)
% Getting a list of all the mat files in the directory
matFilesVar=dir('*.mat');matFileNamesSelectedByUser={matFilesVar.name};clear matFilesVar
matFileNamesSelectedByUser=FilterFiles(matFileNamesSelectedByUser);


function [matDir] = GetMatDir()
baseDir = uigetdir;
[upperPath, baseDirName, ~] = fileparts(baseDir);
if findstr(baseDirName,'MatFiles')
    %  Checking if user accidentally selected the matFile Folder
    matDir=baseDir;
else
    % Checking if there is a matfile folder. if not creating one and filling it
    cd(baseDir);
    matFileFolderVar= dir('*MatFiles');
    if isempty(matFileFolderVar)
        matDir=MatFileInitialisation(baseDir);

    else
        folderSeparatorVariable = filesep;
        matDir=[baseDir folderSeparatorVariable matFileFolderVar.name];
    end
end


function [matDir] =                                                       MatFileInitialisation(baseDir)
folderSeparatorVariable = filesep;
cd(baseDir)
[upperPath, baseDirName, ~] = fileparts(baseDir);
mkdir([baseDir folderSeparatorVariable baseDirName  ' MatFiles'])
matDir= [baseDir folderSeparatorVariable baseDirName  ' MatFiles'];
[lsmFiles]= GetLsmFiles();

matfileNames  = cellfun(@GetMatFileName,lsmFiles,'UniformOutput',0);
atypicalElementsLogical = ~cellfun(@isempty , regexp(matfileNames,'atypical'));
if sum(atypicalElementsLogical)
    atypicalElementNames =  lsmFiles(atypicalElementsLogical);
disp(reshape(atypicalElementNames,length(atypicalElementNames),1))
disp('Some files are not named in accordance with the format used by the program. These files may still be analysed but some functionality will be unavailable')
end


%     Setting up progress bar
h           = progressbar( [],0,'Please Wait','Initialising MatFiles' );
max_count   = length(lsmFiles);
%      Cycling through the lsmFiles and writing them to MatFiles in a
%      subsidiary folder.
for lsmFileListElement=1:length(lsmFiles)




    %          For Progress Bar:
    %------------------------
    fprintf( '%d\n',lsmFileListElement )';
    h = progressbar( h,1/max_count );
    %               if ~gui_active
    %                   break;
    %               end
    %-------------------------
    cd(baseDir)
    stackInfo=tiffread(lsmFiles{lsmFileListElement});

    cd(matDir)
    if regexp(version,'R2014b|201[5-9][a|b]')
          save([lsmFiles{lsmFileListElement}(1:end-4) '.mat'],'stackInfo')
    else
        eval([ 'save ''' lsmFiles{lsmFileListElement}(1:end-4) ''' stackInfo ' ])
    end
end
progressbar( h,-1 );



function [lsmFiles]=                                            GetLsmFiles()

% Getting the directory from which to analyse files
fileInfoInUserDefinedDirectory=dir;
fileNamesInUserDefinedDirectory={fileInfoInUserDefinedDirectory.name};
lsmFilesIndices=regexpcell(fileNamesInUserDefinedDirectory,'.lsm');
lsmFiles=fileNamesInUserDefinedDirectory(lsmFilesIndices);






