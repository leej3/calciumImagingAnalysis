function [glomsToBeAnalysed] = GetGlomsToBeAnalysedWhenNotReviewing(glomsToBeAnalysed)
% could be merged with other function for reviewing but not done to avoid
% introduction of bugs in desparate times. difference in arguments passed
% though so would need to take that into account
indicesOfGlomsToAnalyse = listdlg('ListString',[ glomsToBeAnalysed;{'Add more glomeruli'}; {'Do not edit any'}]);
if find(indicesOfGlomsToAnalyse == length(glomsToBeAnalysed)+2)
    glomsToBeAnalysed = {};
    return
end
if find(indicesOfGlomsToAnalyse == length(glomsToBeAnalysed)+1)
userResponse = inputdlg({'Add more glomeruli in format [a-z][a-z]number[l | r] separated by commas eg: dm2l,dm5r'});
extraGlomeruli = regexp(userResponse,'[a-z][a-z]\d[l r]','match');
extraGlomeruli = extraGlomeruli{:};
indicesOfGlomsToAnalyse(indicesOfGlomsToAnalyse == length(glomsToBeAnalysed)+1) = [];
extraGlomeruli = reshape(extraGlomeruli,length(extraGlomeruli),1);
else 
    extraGlomeruli = {};
end
glomsToBeAnalysed =glomsToBeAnalysed(indicesOfGlomsToAnalyse);
glomsToBeAnalysed = [glomsToBeAnalysed; extraGlomeruli];
end