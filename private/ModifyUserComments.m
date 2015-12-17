function [] = ModifyUserComments(matFile)
            potentiallyModifiedComments=inputdlg('Enter any comments that you may deem fit for inclusion in the textual display lying below herewith...','Comments',[1 100],matFile(1).previousLsmInfo.lsmDescriptors.comments);
            if ~strcmp(potentiallyModifiedComments,matFile(1).previousLsmInfo.lsmDescriptors.comments)
                matFile(1).previousLsmInfo.lsmDescriptors.comments = potentiallyModifiedComments;
                matFileName=GetMatFileName(matFile(1).previousLsmInfo.lsmDescriptors.lsmFileName);
                eval([matFileName(1:end-4) '=matFile;']);
                save(matFileName, matFileName(1:end-4))
            end