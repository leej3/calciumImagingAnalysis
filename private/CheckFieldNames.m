function [outputStructure]...
  = CheckFieldNames(inputStructure,structureType)
%  this function checks two specific structures (used by the scripts)
% to assess whether all the appropriate fieldnames are present. if
% extra fieldnames have been added to the structures (within the 
% initialising functions) they will be added to the inputStructure
% here so that old reloaded structures get resaved with the 
% correct list of fields in them.
if structureType==1
comparisonStruct= InitialiseLsmDescriptors;
else
comparisonStruct= GetGlomeruliInfoElement;
end
comparisonStructFieldNames=fieldnames(comparisonStruct);
extraFieldsRecentlyAdded=setdiff(comparisonStructFieldNames,fieldnames(inputStructure));

for jj=1:length(extraFieldsRecentlyAdded)
inputStructure(1).(extraFieldsRecentlyAdded{jj})=[];
end
outputStructure=inputStructure;