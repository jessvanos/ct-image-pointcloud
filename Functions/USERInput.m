function [NumOut] = USERInput(StringIn)
%THIS FUNCTION ALLOWS FOR A NUMERICAL ENTRY BY THE USER WHICH CAN BE OUTPUT BACK INTO
%THE SCRIPT.
%   INPUT: StringIn is the prompt for the numbered entry
%   OUTPUT: NumOut is the resulting number entered

        promt={StringIn}; %Describes what the entry is required for
        dlgtitle='Number Selection'; %Input Box Title
        dims=[1 50]; %Size of box
        definput={'30'}; %Preset value for entry number

        opts.Resize='on'; %Allow user to move and resize window
        opts.WindowStyle='normal'; %Allows user to interact with images and histogram before input

        INPUT=inputdlg(promt,dlgtitle,dims,definput,opts); %Display user box

        %Store User input threshold values. Convert to double from string
        NumOut=str2double(INPUT{1}); 

end

