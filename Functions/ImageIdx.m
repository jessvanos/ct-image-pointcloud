function [Idx1,Idx2,TotNumIn] = ImageIdx(UnprocStack,currentDir)
%ALLOWS USER TO CHOOSE IF ALL IMAGES WILL BE ADJUSTED AND CARRIED ON THROUGH
%PROCESS OR IF THERE ARE SOME IMAGES WHICH MAY NOT NEED TO BE
%INCLUDED,GIVES CHANCE TO SELECT FIRST AND LAST IMAGES TO INCLUDE BY
%CREATING A TEMP FILE AND RE-NUMBERING THE FILES.
%   INPUT: Original stack inputs the datastore 
%   OUTPUT: Idx1 and Idx2 give the first adn last image which will be used,
%   TotNumIn is the total number of images to be processed

%Dialog box to ask user if they want to select all files
    dlgQuestion = 'Would you like to process all files or a selection? Note that it may take a moment to load'; %Set Question
    dlgtitle='File Selection'; %Set Title
    choice = questdlg(dlgQuestion,dlgtitle,'All files','Selection','All files'); %Two choices

%If the user wants a file selection, allow choice
    if strcmpi(choice,'Selection')

        %Adjusted Image File Path
        TempFiles=sprintf('TempStack'); %Path name
        mkdir(TempFiles); %Create Directory
        addpath(TempFiles); %Set path to temp filder
        filePathrTEMP = fullfile(currentDir,TempFiles); %Set filepath (to be later referenced)
        
        [pathstring,UnProName] = fileparts(UnprocStack.Folders{1}); %Extract the file name from the unprocessed stack datastore
        cd(pathstring); %Set workign directory to this folder loaction
        copyfile(UnProName,filePathrTEMP); %Copt files from unprocessed folder to the temp folder
        
        TempStack=imageDatastore(filePathrTEMP,'FileExtensions',{'.bmp'}); %Create an image datastore from the .bmp files in the temp folder
        cd(filePathrTEMP); %Change directories
             
        %Loop Renames the temporary files starting at 1
        for i = 1:1:numel(TempStack.Files) % For every image in that datastore, we do whatever we need to do to it (this ca
        
            Pathtemp=TempStack.Files{i};
            movefile(Pathtemp,sprintf('Im # %0.5d.bmp', i)) %Rename
            
        end
        
        winopen(filePathrTEMP) %Open folder
%         TempStack=imageDatastore(filePathrTEMP,'FileExtensions',{'.bmp'});
%         imageBrowser(TempStack) %Open the image browser to see images side by side
        
        message1 = sprintf('Select the first and last Image to include in stack:'); %Promt 
        uiwait(msgbox(message1)); %Show message box

        %Promt box for user input image number 
        promt={'Enter first image # to select:','Enter last image # to select:'};
            dlgtitle='View images, double click to see number'; %Input Box Title
            dims=[1 50]; %Size of box
            definput={'1','2000'}; %Preset vaues to select

            opts.Resize='on'; %Allow user to move and resize window
            opts.WindowStyle='normal'; %Allows user to interact with images before input

            INPUT=inputdlg(promt,dlgtitle,dims,definput,opts); %Display user box

            %Store User input image numbers
            Idx1=str2double(INPUT{1}); 
            Idx2=str2double(INPUT{2});
            
            %Get total number of images which will be analyzed
            TotNumIn=Idx2-Idx1+1;
            
            cd(currentDir);
            rmdir(TempFiles,'s');
            
    else
            %If all files are selected, indexes are first and last images
            Idx1=1;
            Idx2=numel(UnprocStack.Files);
            TotNumIn=numel(UnprocStack.Files);
            
    end
    

    fprintf('\tImage indexing is complete\n');
    
end

