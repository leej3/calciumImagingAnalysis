function [matFile, fileEditStatus] = LoadDeltaFMatVariable(currentMatFileName)
matFile = load(currentMatFileName);
firstField=fieldnames(matFile);
if strcmp(firstField, 'stackInfo')
  fileEditStatus = 0;
  matFile = matFile.stackInfo;
else
%         accessing substructure stored within the save variable:
matFile=matFile.(firstField{1});
matFile = CheckFieldNames(matFile,0);
matFile(1).fileName=matFile(1).previousLsmInfo.lsmDescriptors.lsmFileName;
fileEditStatus = 1;
end
