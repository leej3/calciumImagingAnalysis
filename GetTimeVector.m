function [timeVector] = GetTimeVector(lsmDescriptors);
	% edit this file if the time vector is not uniform and the individual time points need to be extracted from the image stack metadata
timeVector=(0:lsmDescriptors.timeInterval:(lsmDescriptors.sliceNumber-1)*lsmDescriptors.timeInterval)';