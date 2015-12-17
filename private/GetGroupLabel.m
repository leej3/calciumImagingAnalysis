function    [group] = GetGroupLabel(fieldOfGroup,group)
% conversion of two digit number representing concentration into %. depreciated functionality. more useful to represent concentration in ppb or ppm. not currently implemented
if strcmp(fieldOfGroup,'concentration')
	group = regexprep(group,'00','0%');
	group = regexprep(group,'14','0.01%');
	group = regexprep(group,'13','0.1%');
	group = regexprep(group,'53','0.5%');
	group = regexprep(group,'12','1%');
	group = regexprep(group,'22','2%');
	group = regexprep(group,'42','4%');
	group = regexprep(group,'52','5%');
	group = regexprep(group,'72','7%');
	group = regexprep(group,'11','10%');
end

if strcmp(fieldOfGroup,'glomerulus')
	group = upper(group);
end
