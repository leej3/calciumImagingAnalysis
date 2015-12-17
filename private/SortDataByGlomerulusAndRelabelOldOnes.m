function [userInput] = SortDataByGlomerulusAndRelabelOldOnes(userInput)
glomeruli = [userInput.glomerulus];
orderedSet = {'dm1','dm2','dm3','dm6','dd0'};

	for ii = 1:length(glomeruli)
		sortingVal = regexpcell(orderedSet,glomeruli{ii});
        
		if isempty(sortingVal)
			sortingIndex(ii) = 0;
        else
            sortingIndex(ii) = sortingVal;
		end
	end
	[~,permutationMat] = sort(sortingIndex);
	userInput = userInput(permutationMat);

% relabelling...
    glomeruli = [userInput.glomerulus];
    glomeruli =   regexprep(glomeruli,'dd0',{'DM6'});
    glomeruli =   regexprep(glomeruli,'dm6',{'DM5'});
    glomeruli =   regexprep(glomeruli,'dm1',{'DM1'});
    glomeruli =   regexprep(glomeruli,'dm2',{'DM2'});
    glomeruli =   regexprep(glomeruli,'dm3',{'DM3'});
    for ii = 1:length(userInput)
        
    userInput(ii).glomerulus = glomeruli(ii);
    end

end