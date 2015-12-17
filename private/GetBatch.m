function thisCycleFile =                     GetBatch(thisCycleFile)
% depreciated functionality. concentrations delivered for runs 1-4 were repeated for runs 5-8 forming two `batches'
if sum(strcmp({'01','02','03','04'},thisCycleFile(1).run))
   [thisCycleFile.concentrationBatch] = deal({'01'});
elseif sum(strcmp({'05','06','07','08'},thisCycleFile(1).run))
    [thisCycleFile.concentrationBatch] = deal({'02'});
else 
    [thisCycleFile.concentrationBatch] = deal({'99'});
end