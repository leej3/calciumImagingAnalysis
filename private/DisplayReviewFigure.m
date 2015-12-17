function []=                                                    DisplayReviewFigure(glomeruliInfo) %call display review fig
global figHandles
figure(99), subplot(figHandles.mergedImage)
glomList=[];
glomNames={glomeruliInfo(2:end).names};

squareROI= imrect(gca,glomeruliInfo(1).coOrdinates);

polyStructEl=1;
    for glomCyc=1:length(glomNames)       
      glomList=[glomList ' ' glomeruliInfo(glomCyc+1).names ': ' num2str(glomeruliInfo(glomCyc+1).peakOfInterpedCurve) ', ']; 
      polyStruct{polyStructEl}= impoly(gca,glomeruliInfo(glomCyc+1).coOrdinates);
      polyStructEl=1+polyStructEl;
    end
    title([glomList])
    pause(1)
    % don't pause longer here because the file saving takes a little while so there is a natural pause from that
end    