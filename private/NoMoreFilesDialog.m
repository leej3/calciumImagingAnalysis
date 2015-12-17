function [] = NoMoreFilesDialog
%%
h = msgbox('No more files!');
pause(2)
try
close(h)
end