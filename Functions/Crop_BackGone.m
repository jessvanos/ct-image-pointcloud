function [CropSizeRow, CropSizeCol,BackgroundMask] = Crop_BackGone(UnprocStack,Idx1,Idx2)
%FUNCTION AUTOMATICALLY CROPS A SELECTED IMAGE FROM THE STACK AND THEN
%COLLECTS USER INPUT TO SPECIFY FOREGROUND AND MASK OUT OTHER BACKGROUND ARTIFACTS WHICH ARE NOT THE REGION OF INTREST
%   INPUT: UnprocStack is the original unprocessed image stack. Idx1 and
%   Idx2 are the values which specify where the start and end of stack will
%   be based on the indexing function
%   OUTPUT: CropSizeRow & CropSizeCol are dimensions used to crop other images to same size (indexed rows and
%       columns), BackgroundMask gives the region of interest mask
    
%FIND IMAGE WITH MOST NON ZERO PIXELS
    %Get image for further manipulation. Takes image with likely the largest
    %size (most non-zero pixels) to ensure crop will work for every image
    NumPix=1; %Pre-allocate Variable
        for i=Idx1:1:Idx2 %Run for length of stack images
            Im=im2double(UnprocStack.readimage(i)); %Read in image
            NonZ=nnz(Im); %Count non-zero elements

            if NumPix<NonZ %Check if image has more non-zero pixels
                NumPix=NonZ; %Replace NumPix with current non zero value
                N=i; %Save Image number i as the image number (N) to be referenced
            end
               
        end
      
    %Set image found to template image. Read in images as a double. This will prevent rounding and adverse saturation effects
    ITemplate=im2double(UnprocStack.readimage(N)); 

        
%AUTO/INITIAL CROP SECTION
    %Check for outer circle or disturbances to remove & Create temp BW image
    tempBW=wiener2(ITemplate,[10 10]);% filter to take out noise and group shapes
    tempBW2=imbinarize(tempBW,'adaptive'); %Convert to Binary image using adaptive binarization
    SE=strel('disk',7);
    tempBW3=imopen(tempBW2,SE); %Morphological opening
    tempBW4=bwareafilt(tempBW3,4); %remove any other small spots leftover
    
    CheckCirc=bwpropfilt(tempBW4,'EquivDiameter',[500 2000]); %filters out  equivalent diamters in 500 to 2000 pixel range only

    %Check input, if no circles are found,a conservative crop will be completed by triming to
    %image values of greater than 0
    if CheckCirc==0  
        
        %Find the values of the image with non 0 values
        [crop_r, crop_c]=find(ITemplate);

        %Get the cropping parameters by computing max/min from row & col
            TopRow = min(crop_r(:));
            BotRow = max(crop_r(:));
            LeftCol = min(crop_c(:));
            RightCol = max(crop_c(:));
            
        %Extract a cropped image from the original.by applying these values
            CropSizeRow = (TopRow:BotRow); 
            CropSizeCol=(LeftCol:RightCol);
    else
        %Find the non zero values of the binary image found previously
        [crop_r, crop_c]=find(tempBW4);

        %Get the cropping parameters by computing max/min from row & col
            TopRow = min(crop_r(:));
            BotRow = max(crop_r(:));
            LeftCol = min(crop_c(:));
            RightCol = max(crop_c(:));

            %Extract a cropped image from the original.by applying these values
            CropSizeRow =(TopRow:BotRow); 
            CropSizeCol=(LeftCol:RightCol);
    end
    
    %Crop template image
    I=ITemplate(CropSizeRow, CropSizeCol);
    
    %ROI SELECTION WITH TEMPLATE IMAGE
    while (1)

        figure; %create figure
        F1=imshow(I); %Show image

        %Prompt user to draw ROI, everything outside of this area will be removed
        message = sprintf('Use drawpolygon To Choose Foreground Area To Keep.\nSelect Near Outside To Avoid Loosing Image Parts For Other Files');
        uiwait(msgbox(message));
        h1=drawpolygon(gca,'Color','m'); %Draws polygon in magenta

        %Promt that process is going foreward
        message2 = sprintf('ROI Has Been Selected!');
        uiwait(msgbox(message2));
        
        %Set foreground as selected area
        Foreground=createMask(h1);
        close(ancestor(F1,'figure')); %Close figure
        
        %Set background as the opposite of foreground
        Background=~Foreground;

        figure;
        FIGSHOW=imshow(labeloverlay(I,Background,'Colormap',[0 1 0])); %Shows background that will be set to 0 in GREEN
        
        %Ask user if they would like to proceed using a dialog question
        dlgQuestion = 'Does Mask Contain All Regions of Intrest?';
        dlgtitle='ROI Selection';
        choice = questdlg(dlgQuestion,dlgtitle,'Yes','No, Select Again', 'Yes');

        if strcmpi(choice,'Yes') %Check input, if good - break code
            BackgroundMask=Foreground; %Set the background mask to be applied to other images
            close(ancestor(FIGSHOW,'figure')); %Close figure
            break
        else
            close(ancestor(FIGSHOW,'figure')); 
            continue %Allow to re-draw region & run again
        end
    end
    
    fprintf('\tCrop parameters and foreground have been selected\n');
    
end