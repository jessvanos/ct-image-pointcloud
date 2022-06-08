%% Stack Adjustment-Segmentation-Point Cloud
%CODE BELOW MAY BE USED TO GENERATE A POINT CLOUD FROM A MICRO CT IMAGE
%STACK. BEGINS BY ADJUSTING IMAGES, APPLY USER DEFINED CROP, AND SAVING
%ADJUSTED IMAGES TO A DISK FOLDER. THE CROPPED ORIGINAL IMAGE IS ALSO SAVED
%TO ALLOW FOR COMPARISON LATER ON. NEXT,BONE AND TOOTH STRUCTURES ARE
%ISSOLATED AND SEGMENTED. EACH SEGMENTATION IS BASED ON PREVIOUS IMAGE IN
%STACK. FINALLY THE GENERATED BINARY IMAGE STACK IS CONVERTED TO A 3D POINT
%CLOUD WHICH CAN BE EXPORTED TO ANTHER PROGRAM OR SOFTWARE.

%Ensure the _ *Image Processing Toolbox* _ and _ *Statistics and Machine
%Learning Toolbox* _ are intalled before running! File add in "Point Cloud
%Tools for Matlab" must also be instaled and added to path

% Ensure Functions Folder with correct functions are added to path:
    %Stack_datastore Crop_BackGone USERInput BackgroundRemoval
    %Im_Adjustment Stack_datastore ToothSelector AdjBoneTEX ToothSeg
    %VisSegResult Stack_datastore PTCLOUDfrom2D

clear; close all; clc; workspace; beep on;


%% SECTION 1: INITIATE CODE & CHOOSE SETTINGS (INTERACTIVE)
%This section sets up for the segmentation process. It begins by creating
%folders and file paths for later reference. Following this the unprocessed
%stack is brought into the work space and parameters are set for further
%adjustment. These parameters include the image crop size, Wiener filter
%size, and an index of images which will be processed.
fprintf('<strong>CODE INITIALIZED</strong>\n')
fprintf('<strong>SECTION 1:</strong> SET UP & USER INPUT\n')


    %% SET UP WORKING DIRECTORIES
    %Set up folders and naming convention for output files during
    %processing

    %Tell user that process is starting using a message box, ensure correct
    %location is chosen in current folder
    message3 = sprintf('Initiating Code: \nImages will be saved to current folder path. Select proper folder and restart code if not in designated location');
    uiwait(msgbox(message3));
    clear message3

    %Enter Rec Number (in string format) here and
    RecNumString=sprintf('Please type rec number to be used in naming convention. ex: 3'); %ENTER REC NUMBER HERE%
    [RecNum] = USERInput(RecNumString);
    currentDir = pwd; %Sets current folder to directory

    %Adjusted Image File Path
    AdjPath=sprintf('AdjStack_Rec_%d',RecNum); %Path name
    mkdir(AdjPath); %Create Directory
    filePathr = fullfile(currentDir,AdjPath); %Set filepath (to be later referenced)

    %Croped Original Image File Path
    OGPath=sprintf('OGStack_Rec_%d',RecNum);
    mkdir(OGPath);
    filePathr2 = fullfile(currentDir,OGPath);

    %Binary Bone Image File Path
    BWPath=sprintf('BWStack_Rec_%d',RecNum);
    mkdir(BWPath);
    filePathr3 = fullfile(currentDir,BWPath); 

    %Binary Tooth Image File Path
    TPath=sprintf('TStack_Rec_%d',RecNum);
    mkdir(TPath);
    filePathr4 = fullfile(currentDir,TPath);
    
    %Binary Soft Tissue Image File Path
    STPath=sprintf('STStack_Rec_%d',RecNum);
    mkdir(STPath);
    filePathr5 = fullfile(currentDir,STPath);


    %% Load Image Stack & Select Sample Image Number
    %Creates datastore of .bmp files in selected folder.

    %Select Unprocessed Stack and filter the .bmp images into a datastore using
    %Stack_datastore function
    [UnprocStack]= Stack_datastore(); 


    %% Choose Image Index
    %View imagedata store & select first and last file to include in
    %segmentation. TotNumIn gives the total number of files which will be
    %selected and writen to the computer drive
    [Idx1,Idx2,TotNumIn] = ImageIdx(UnprocStack,currentDir); 
    
    %Choose Wiener2 filter size. larger size = less detail but more noise
    %reduction (better performance of range filter in segmenetation)
    FiltString=sprintf('Please enter weiner filter size. If not sure, use values below:\n18 micron - FiltSize=10 \n9 micron - FiltSize=30'); 
    FiltSize=USERInput(FiltString);

    
    %% Image Crop Size
    %Run function to crop get croping size. Also allows user
    %to specify foreground
    [CropSizeRow, CropSizeCol,BackgroundMask] = Crop_BackGone(UnprocStack,Idx1,Idx2);
    
    
%% SECTION 2: PRE-PROCESSING %% 
%This section does not require any input. Files will be run through a loop
%which applies a filter to adjust contrast and remove noise (wiener) as
%well as crop images. For each iteration, two images will be saved; the
%adjusted image, and the original image with applied crop. The original
%image is saved for later comparison only. This section is completed by
%creating data stores for the adjusted files (AdjStack) and original files
%(OGStack) and displaying a montage image of an adjusted image.
fprintf('<strong>SECTION 2:</strong> IMAGE STACK ADJUSTMENT/PRE-PROCESSING SECTION\n')

    
    %% Stack Image Adjustment Loop

    %Pre allocate the image number counter for naming convention
    ii=1;
    
    %Populate first Waitbar to display progess
    Waiting1=waitbar(0,'Loading...','Name','Adjusting Data','CreateCancelBtn','setappdata(gcbf,''canceled'',1)');
    setappdata(Waiting1,'canceled',0); %Create functionality to cancel if its taking too long

    for i = Idx1:1:Idx2 %Run throuh entire data store

        %Read Image into memory, overwritten each time
        FRead = im2double(readimage(UnprocStack,i)); %Avoid rounding error

        %Image Adjustments
        [MaskedImage] = BackgroundRemoval(FRead,CropSizeRow, CropSizeCol,BackgroundMask); %Crop & Remove background
        [IAdjusted] = Im_Adjustment(MaskedImage,FiltSize); %adjust, & filter noise

        %Save file to DISK
        FName = sprintf('AdjIm_%05d.tif', ii); % File Name
        fullName = fullfile(filePathr, FName); % Write to the current directory
        imwrite(IAdjusted, fullName); % Save it to DISK permanently

        %Now crop original Image
        OGcrop=FRead(CropSizeRow, CropSizeCol);
        
        %Save croped image
        FName2 = sprintf('OGIm_%05d.tif', ii); % File Name
        fullName2 = fullfile(filePathr2, FName2); % Write to the current directory
        imwrite(OGcrop, fullName2); % Save it to DISK again

        waitbar((i-Idx1)/TotNumIn,Waiting1,sprintf('%3.3g%% Images Adjusted',(i-Idx1)/TotNumIn*100)); %Display Progress

        ii=ii+1;
        
        if getappdata(Waiting1,'canceled') %Cancel if option is chosen
            delete(Waiting1) %Delete the waitbar
            break
        end

    end

    delete(Waiting1)
    fprintf('\tAdjustment Status:%d/%d Adjusted Images Have Been Saved\n',i,numel(UnprocStack.Files))

    
    %% Save Result to Data Store & Check Result

    AdjStack = imageDatastore(filePathr); %New Data Store for adjusted stack
    OGStack = imageDatastore(filePathr2); %New Data Store for original stack
    
    %Display adjustment results. Same for each image to the number does not
    %matter, the middle stack image rounded to the nearest whole number is taken for consistancy. Could be
    %changed by edidting the value in lines 146 and 147
    figure;
    imshowpair(OGStack.readimage(round(numel(AdjStack.Files)/2)),AdjStack.readimage(round(numel(AdjStack.Files)/2)),'montage');
    STRINGNUM=sprintf('Original and Adjusted Image Number %g',(numel(AdjStack.Files)/2));
    title(STRINGNUM);

    fprintf('\tImage Adjustment Complete, proceeding to segmentation\n'); beep
    
    
%% SECTION 3:SEGMENTATION  %%
% This is the bulk of the code. Here is where teeth can be indexed and
% marked separate from bone and the initial regions of Interest (ROIs) are
% set. Once this is complete a series of loops generates new binary images
% masking out the bone and tooth regions of each image. The segmentation is
% completed by use of a range (texture) filter and an active contour, while
% being guided by the previous image bone mask and the current tooth mask
% to constrain the area. At the end of the process, there is an opportunity
% to look through the segmentation results.
fprintf('<strong>SECTION 3:</strong> IMAGE STACK SEGMENTATION SECTION\n')


%% Select Teeth (for 2 teeth)
    %Call Tooth Selection tool. Allows for user to view all stack images
    %and visually see where the teeth begin and end
    [In1,In2,In3,In4] = ToothSelector(AdjStack,filePathr);

    %Read in the first tooth image. This is image # In1.
    T1=im2double(AdjStack.readimage(In1)); 
    
    %Read in the second tooth image. This is image # In3.
    T3=im2double(AdjStack.readimage(In3));
    
    
    %% Find the teeth to label
    %If there are teeth to select, ROI selection tool for the first tooth
    %will begin here. If there are not teeth, only the initial area for
    %bone in the first image is required.
    
    if In1~=In3


        %Call function to select ROI's for first image with tooth
        [BackgroundMaskTooth1,BackgroundMaskST1,BackgroundMaskBone1] = Init3ROIs(T1);

        %Set the initial mask at chosen locations for tooth 1
        TMask1=BackgroundMaskTooth1;
        BMask1=BackgroundMaskBone1;
    end
    
        %Set a ROI for the first tooth that will grow based on previous
        message2 = sprintf('Proceed to ROI Selection of next Tooth');
        uiwait(msgbox(message2)); 
        clear message2

        %Call function to select ROI's for second image with tooth
        [BackgroundMaskTooth2,BackgroundMaskST2,BackgroundMaskBone2] = Init3ROIs(T3);

        %Set the initial mask at chosen locations for tooth 2
        TMask2=BackgroundMaskTooth2;
        BMask2=BackgroundMaskBone2;
    
    
    %% Prepare for Loop

    %Populate Waitbar to check time remaining for loop, added cancel button
    Waiting2=waitbar(0,'Loading...','Name','Running Binarization Data','CreateCancelBtn','setappdata(gcbf,''canceled'',1)');
    setappdata(Waiting2,'canceled',0); %Create functionality to cancel if its taking too long

    %Set the total number of files to be itterated
    n=numel(AdjStack.Files);


    %% Begin First Half of Loops
    %First Loop Works from the start of stack, this will use the images
    %which are before the first tooth apears (if there are any)

    if In1>1 %If the first tooth is at image 1, this will be skipped
        
        BMask0=BMask1; %Set initial mask to bone area of first tooth, should be a realativly safe guess

        for i=1:1:(In1-1)

                waitbar(i/n,Waiting2,sprintf('%3.3g%% complete',i/n*100));

                IMadj = im2double(readimage(AdjStack,i)); %Avoid rounding error

                TMask0=logical(ones(size(T1))*0); %Add blank screens in between to maintain tooth spacing

                %Save tooth files to DISK
                FName4 = sprintf('TIm_%05.tif', i); % File Name
                fullName4 = fullfile(filePathr4, FName4); % Write to the current directory
                imwrite(TMask0, fullName4); % Save it to DISK permanently

                %Section to Mask the Bone
                [BMaskNew] = AdjBoneTEX(IMadj,TMask0,BMask0);
                BMask0=BMaskNew;

                %Save bone files to DISK
                FName3 = sprintf('BWIm_%05d.tif', i); % File Name
                fullName3 = fullfile(filePathr3, FName3); % Write to the current directory
                imwrite(BMaskNew, fullName3); % Save it to DISK permanently

                %Mask Soft Tissue
                [STMaskNew] = AdjST(IMadj,TMask0,BMask0);
                
                %Save Soft Tissue files to DISK
                FName5 = sprintf('STIm_%05d.tif', i); % File Name
                fullName5 = fullfile(filePathr5, FName5); % Write to the current directory
                imwrite(STMaskNew, fullName5); % Save it to DISK permanently
                
                if getappdata(Waiting2,'canceled') %Cancel if option is chosen
                    delete(Waiting2) %Finally, delete the waitbar
                    break
                end

        end
    end

    %The next loop works fromt he first image containing a tooth until the
    %Next Tooth
    if In3>1
        for i=In1:1:(In3-1)

                waitbar(i/n,Waiting2,sprintf('%3.3g%% complete',i/n*100));

                IMadj = im2double(readimage(AdjStack,i)); %Avoid rounding error

                %Section to Mask the Tooth (if present)
                if i>In2 || sum(TMask1,'all')<50
                    TMask1=logical(ones(size(T1))*0); %Add blank screens in between to maintain tooth spacing
                else
                    [TStack] = ToothSeg(IMadj,TMask1);
                    TMask1=TStack; %Set the mask as the current binary tooth image to use on the next itteration
                end

                %Save tooth files to DISK
                FName4 = sprintf('TIm_%05d.tif', i); % File Name
                fullName4 = fullfile(filePathr4, FName4); % Write to the current directory
                imwrite(TMask1, fullName4); % Save it to DISK permanently

                %Section to Mask the Bone
                [BMaskNew] = AdjBoneTEX(IMadj,TMask1,BMask1);
                BMask1=BMaskNew;

                %Save bone files to DISK
                FName3 = sprintf('BWIm_%05d.tif', i); % File Name
                fullName3 = fullfile(filePathr3, FName3); % Write to the current directory
                imwrite(BMaskNew, fullName3); % Save it to DISK permanently

                %Mask Soft Tissue
                [STMaskNew] = AdjST(IMadj,TMask1,BMask1);
                
                %Save Soft Tissue files to DISK
                FName5 = sprintf('STIm_%05d.tif', i); % File Name
                fullName5 = fullfile(filePathr5, FName5); % Write to the current directory
                imwrite(STMaskNew, fullName5); % Save it to DISK permanently
                
                if getappdata(Waiting2,'canceled') %Cancel if option is chosen
                    delete(Waiting2) %Finally, delete the waitbar
                    break
                end

        end
    end

    %% Begin From Second Tooth
    %The next loop, runs from the second tooth to end
    for i=In3:1:n

            waitbar(i/n,Waiting2,sprintf('%3.3g%% complete',i/n*100));

            IMadj = im2double(readimage(AdjStack,i)); %Avoid rounding error

            %Check to make sure there is a tooth. Exits if tooth exists, it
            %will be collected. Also catches program if the bone area
            %begins to calc incorectly
            if i>In4 ||  sum(TMask2,'all')<50
                TMask2=logical(ones(size(T1))*0); %Add blank screens in between to maintain tooth spacing

            else
                [TStack] = ToothSeg(IMadj,TMask2);
                TMask2=TStack; %Set the mask as the current binary tooth image to use on the next itteration

            end

            %Section to Mask the Bone
            [BMaskNew] = AdjBoneTEX(IMadj,TMask2,BMask2);
            BMask2=BMaskNew;

            %Mask Soft Tissue
            [STMaskNew] = AdjST(IMadj,TMask2,BMask2);
            
            %Save tooth files to DISK
            FName4 = sprintf('TIm_%05d.tif', i); % File Name
            fullName4 = fullfile(filePathr4, FName4); % Write to the current directory
            imwrite(TMask2, fullName4); % Save it to DISK permanently

            %Save bone files to DISK
            FName3 = sprintf('BWIm_%05d.tif', i); % File Name
            fullName3 = fullfile(filePathr3, FName3); % Write to the current directory
            imwrite(BMaskNew, fullName3); % Save it to DISK permanently
                
            %Save Soft Tissue files to DISK
            FName5 = sprintf('STIm_%05d.tif', i); % File Name
            fullName5 = fullfile(filePathr5, FName5); % Write to the current directory
            imwrite(STMaskNew, fullName5); % Save it to DISK permanently
            
            if getappdata(Waiting2,'canceled') %Cancel if option is chosen
                delete(Waiting2) %Delete the waitbar
                break
            end

    end


    %% Check Loop Completion & Write to Data Store
    delete(Waiting2) %Finally, delete the waitbar

    BWStack = imageDatastore(filePathr3); %New Data Store
    TStack = imageDatastore(filePathr4); %New Data Store
    STStack = imageDatastore(filePathr5);
    
    %rmdir(AdjPath,'s') %Remove adjusted files to save space
    
    %CHeck to make sure all files converted. Compares the number of files
    %in the adjusted stack and the binary stack
    fprintf('\tBinary Image Stack Conversion Status: ');
    if numel(AdjStack.Files)==numel(BWStack.Files)
        fprintf('Sucess, all files converted \n')
    else
        fprintf('Not all Files were converted, Check Code \n');
    end

    %Print Completion of section
    fprintf('\tImage Segmentation complete \n')
    
    
    %% Lets see some Images & Display Segmentation results
    %Get figures of bone boundary laid over original, bone area overlayed
    %on original image, and tooth area overlayed on original image. Allows
    %user to keep viewing image results till they choose not to
    %Optional as it stops code process
%     beep;
%     VisSegResult(OGStack,BWStack,TStack);
%     
    
%% SECTION 4: BINARY TO 3D POINT CLOUD
fprintf('<strong>SECTION 4:</strong> IMAGE STACK TO POINT CLOUD SECTION\n')


    %% Generate Point Cloud and Save to Disk
    %ENABLE PC ADD ON Call function to contour and convert binary slices to
    %point cloud assume distance of 1 beteern slices, may been to edit
    %later for voxel size

    %USING TOOLBOX
    PixSz=8.90290e-3; %PixelSize taken from rec log, in mm
    [ptCloudB] = edge2DtoTXT(BWStack,PixSz);
    
    %Export the scaled pointcloud
    PCName2=sprintf('ptCloud_Rec_%d.ply',RecNum); %Point Cloud File Name, .ply is built for 3D data storage
    PCName3=sprintf('ptCloud_Rec_%d.txt',RecNum); %Point Cloud File Name, .txt is built for platforms such as solidworks to read
    
    ptCloudB.export(PCName2); %Export a .ply file verion of the point cloud that is scaled
    ptCloudB.export(PCName3); %Export a .txt file verion of the point cloud
    
    
    %% Tooth Point Cloud & Complete Section
    %Get tooth point Cloud
    [ptCloudT]= edge2DtoTXT(TStack,PixSz);
    
    %Display message to show code completion
    fprintf('\tPoint cloud has been generated\n')
    
    %% Soft Tissue Point Cloud & Complete Section
    %Get tooth point Cloud
    [ptCloudST]= edge2DtoTXT(STStack,PixSz);
    
    %Display message to show code completion
    fprintf('\tPoint cloud has been generated\n')
    
    %% Show it all in one point cloud
    ptCloudB.plot('Color', 'blue');
    ptCloudT.plot('Color', 'green');
    ptCloudST.plot('Color', 'magenta');

    [lgd] = legend({'Bone','Tooth','Soft Tissue'},'Location','northeast','Color',[1 1 1]);
    lgd.FontSize = 10;
    
%% END OF CODE
fprintf('<strong>CODE FINISHED</strong>\n\n')






