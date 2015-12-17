function [onsetChoices, skipFile] =   ChooseOnsetTime(files, fileIndex, onsetChoices, thisCycleFile)
% this function is used for datasets where no trigger and so no explicitly defined onset time. to align the different ROIs: a point in each file needs to be defined as the start. it could be the start of response in a specific ROI. Or perhaps any ROI in each image stack.
skipFile = 0;onsetPlot = 999;onsetVarSliceNumber = [];
if ishandle(onsetPlot)
    figure(onsetPlot)
    else
positionOfPlot = GetFigurePositions;
figure(onsetPlot), set(gcf, 'Position', positionOfPlot)
end
fileForViewing = thisCycleFile;
fileIndexForViewing = fileIndex;

onsetPlotAxes = gca;
while 1
    legendLabel = strcat({fileForViewing(2:end).names}, deal(' onset was : ') , cellfun(@num2str , { fileForViewing(2:end).sliceNumberOfResponseOnset},'UniformOutput', 0));
    plot(onsetPlotAxes, [fileForViewing.plot]), legend(legendLabel)

     if ~isempty(onsetChoices) && sum(strcmp(onsetChoices(:, 1), fileForViewing(1).fileName))
         potentialOffsetIndex = onsetChoices{strcmp(onsetChoices(:,1), fileForViewing(1).fileName),2};
         if length(potentialOffsetIndex)>1
             onsetChoices(potentialOffsetIndex,:) = [];
             onsetValueForCurrentFile = 'undefined';
         else
            onsetValueForCurrentFile =  num2str(potentialOffsetIndex);
         end
    else
        onsetValueForCurrentFile = 'undefined';
    end

    title({[num2str(fileIndexForViewing - fileIndex) ' : '  fileForViewing(1).fileName],['Onset slice :' onsetValueForCurrentFile]})

    userChoiceToAnalyseFile=menu('Choose onset of file' , 'Input Onset', 'Check Previous', 'Check Next', 'Skip file','View Raw File','View higher intensity','Comments For Currently Viewed File');

    switch userChoiceToAnalyseFile
        case 1
            % continue and analyse file
            figure(onsetPlot),plot([thisCycleFile.plot]), legend(legendLabel)
            legendLabel = strcat({thisCycleFile(2:end).names}, deal(' onset was : ') ,cellfun(@num2str ,{ thisCycleFile(2:end).sliceNumberOfResponseOnset},'UniformOutput',0));
            title([num2str(fileIndexForViewing - fileIndex) ' : '  thisCycleFile(1).fileName])
            break
        case 2 % previous file
            if fileIndexForViewing == 1
                NoMoreFilesDialog

            else
                fileIndexForViewing = fileIndexForViewing-1;

            end
        case 3 % next file
            if fileIndexForViewing == length(files)
                NoMoreFilesDialog

            else
                fileIndexForViewing = fileIndexForViewing+1;

            end

        case 4 % skip file

            skipFile = 1;
            break
        case 5
            pic=[fileForViewing(1).previousLsmInfo.stackInfo.data];
            pic=reshape(pic,fileForViewing(1).previousLsmInfo.stackInfo(1).width,fileForViewing(1).previousLsmInfo.stackInfo(1).height,length(fileForViewing(1).previousLsmInfo.stackInfo));
            show_stack(pic)
        case 6
            pic=[fileForViewing(1).previousLsmInfo.stackInfo.data];
            pic=reshape(pic,fileForViewing(1).previousLsmInfo.stackInfo(1).width,fileForViewing(1).previousLsmInfo.stackInfo(1).height,length(fileForViewing(1).previousLsmInfo.stackInfo));
            show_stack(pic*3)
        case 7
            ModifyUserComments(fileForViewing)
        case 0
            error('cancelled by user')
        end
 [fileForViewing] = LoadDeltaFMatVariable(files{fileIndexForViewing});

   end

if ~skipFile
while 1
    userChoice =   str2num(char(inputdlg('Enter onset slice (or 999 to skip file)')));
    if ~isempty(userChoice)
        onsetVarSliceNumber = userChoice;
        break
    end
end
end

if onsetVarSliceNumber == 999| skipFile
    skipFile =1;
else
    onsetChoices{size(onsetChoices,1)+1,1} = thisCycleFile(1).fileName;
    onsetChoices{size(onsetChoices,1),2} = onsetVarSliceNumber;
end




