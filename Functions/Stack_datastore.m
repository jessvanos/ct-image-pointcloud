function [Stack] = Stack_datastore()
%THIS FUNCTION IS USED TO CREATE A DATASTORE FROM A USER SELECTED FOLDER. A DATASTORE ALLOWS IMAEGS TO BE REFERENCED 
%IN THE WORKSPACE WITHOUT TAKING UP LARGE AMOUNTS OF MEMORY SPACE. 
%   INPUT: null, prompts for user input
%   OUTPUT: Stack is a datastore containing all the selected image data in the
%       given directory. These can be original CT files with '.bmp' file type, or processed files with any image file type. 
%       If wanting to load partially processed images into a  datastore this function may be used.

    %Dialog box to ask user for file type (unprocessed or partially processed)
    dlgQuestion = 'What files would you like to import';
    dlgtitle='File Selection'; %Set Title
    choice = questdlg(dlgQuestion,dlgtitle,'Unprocessed Stack (.bmp)','Partially Processed Stack','Unprocessed Stack (.bmp)'); %Two choices

    %If the user selects original stack (.bmp), the .bmp image files in stack will be written into
    %an image data store (Stack)
            if strcmpi(choice,'Unprocessed Stack (.bmp)')

               %Call for user input and write the images into the stack, '.bmp' file type only
               stackPath = uigetdir; %Lets user select file
               addpath(stackPath); %Add file directory to path
               Stack = imageDatastore(stackPath,'FileExtensions',{'.bmp'});
               
               %Takes number of image files using numel and prints output to Command Window
               NumImages=numel(Stack.Files);
               fprintf('\tUnprocessed stack contains %d images\n',NumImages) 
               
            %If Partially Processed Stack is selected, use else statement.
            %This will grab all files regardless of type!
            else 

               %Call for user input and write the images into the stack, any file type
               stackPath = uigetdir; 
               addpath(stackPath);
               Stack = imageDatastore(stackPath);
               
               %Takes number of image files using numel and prints output to Command Window
               NumImages=numel(Stack.Files); 
               fprintf('\tPartially processed stack contains %d images\n',NumImages) 

            end

end

