function [cyclingGroup] = SortGroupForCycling(fieldUsedForCycling,cyclingGroup)
     orderedSet = cyclingGroup;


    if strcmp(fieldUsedForCycling,'concentration')
        orderedSet = {'00','14','13','53','12','22','42','52','72','11'};
    end
%     if strcmp(fieldUsedForCycling,'glomerulus') && 	mislabelledDatasets
%     	orderedSet = {'dm1','dm2','dm3','dm6','dd0'};
%     end
	if strcmp(fieldUsedForCycling,'treatedOrNot')
		orderedSet = {'Pre','Post'};
	end

	for ii = 1:length(cyclingGroup)
		sortingVal = regexpcell(orderedSet,cyclingGroup{ii});
		if isempty(sortingVal)
			sortingIndex(ii) = 0;
        else
            sortingIndex(ii) = sortingVal;
		end
	end
	[~,permutationMat] = sort(sortingIndex);
	cyclingGroup = cyclingGroup(permutationMat);
