function [In1,In2,In3,In4] = ToothSelector(AdjStack,filePathr)
%DISPLAY ADJUSTED STACK AND ALLOW FOR USER TO SELECT THE IMAGES WHICH
%CONTAIN TEETH SO THEY MAY BE SEPARATED FROM BONE SEGMENTATIONS
%   INPUT: AdjStack brings in the datastore of adjusted images to be
%       displayed, filePathr bring up the correct filepath to the adjusted stack so the folder can be called for
%   OUTPUT: In1 and In2 give the index for the first and second tooth
%   images, while In3 and In4 give the index for the beginning and end of the second tooth


    dlgQuestion = 'Does image stack contain 2 teeth to remove?'; %Set Question
    dlgtitle='Tooth Selection'; %Set Title
    choice = questdlg(dlgQuestion,dlgtitle,'Yes','No, only 1','Yes'); %Two choices

    if strcmpi(choice,'Yes')
        %Set a ROI for the tooth that will grow based on previous
        message1 = sprintf('Select the 2 teeth in image by browsing stack. The first and last image with teeth will be used!');
        uiwait(msgbox(message1)); %Show message box

        winopen(filePathr) %Load image browser to view all files
        pause(0.1);
        
        %Promt box for user input image number 
        promt={'Enter Image # where first Tooth is visible (I1):','Enter the last Image # where first tooth is visible','Enter Image # where second Tooth is visible , choose closest image from stack start (I3):','Enter final Image # where Second Tooth is visible (I4):'};
        dlgtitle='View images, Double click to See Number'; %Input Box Title
        dims=[1 50]; %Size of box
        definput={'1','496','1700','2510'}; %Preset vaues of greyscale

        opts.Resize='on'; %Allow user to move and resize window
        opts.WindowStyle='normal'; %Allows user to interact with images and histogram before input

        INPUT=inputdlg(promt,dlgtitle,dims,definput,opts); %Display user box

        %Store User input threshold values. Convert to double from string
        In1=str2double(INPUT{1}); 
        In2=str2double(INPUT{2});
        In3=str2double(INPUT{3});
        In4=str2double(INPUT{4});

        close all;
    else
        %Set values so that loop will itterate through full stack. 
        In1=1;
        In2=0;
        In3=1; %Will initiate loop start
        In4=10000;
    end
    
    fprintf('\tTooth selection complete, proceeding to ROI selection\n');
    
end

