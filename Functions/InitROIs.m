function [BackgroundMaskTooth,BackgroundMaskBone] = InitROIs(I1)
%CHOOSE INITAL ROI'S FOR THE FIRST IMAGE IN STACK.
%   INPUT: I1, image to draw mask on
%   OUTPUT: BackgroundMaskTooth gives the tooth initial mask, BackgroundMaskBone gives the bone initial mask

while (1)
    
    figure; %create figure
    F1=imshow(I1); %Show input image 
    hold on;

    L = superpixels(I1,14000); %Populate labels
    
    
    %TOOTH SELECTION
        %Prompt user to draw ROI around tooth
        message1 = sprintf('Use drawfreehand To Choose the tooth. \nClick and move cursor to draw region. Will auto snap to edges');
        uiwait(msgbox(message1)); %Show message box
        T1=images.roi.AssistedFreehand(gca,'Color','g'); %Draws freehand in green for tooth
        draw(T1);

        %Promt that process is going foreward
        message2 = sprintf('ROI for Tooth Has Been Selected!');
        uiwait(msgbox(message2)); %Show message box

        %Set foreground as selected area
        Tooth=T1.createMask();
        
    
    %BONE SELECTION
        message3 = sprintf('Use drawfreehand To Choose bright areas of bone. \nClick and hold to draw region as accuratly as possible');
        uiwait(msgbox(message3));
        B0=images.roi.AssistedFreehand(gca,'Color','b'); %Draws shape in blue
        draw(B0)

        %Set foreground as selected area
        Bone=B0.createMask();
        
        choice1 ='Yes'; %Set deault to 'Yes' so the loop runs 

        while strcmpi(choice1,'Yes')
                
                %Ask if they need to select another region
                dlgQuestion1 = 'Select Another Bone Region?';
                dlgtitle1='Bone ROI';
                choice1 = questdlg(dlgQuestion1,dlgtitle1,'Yes','No', 'Yes');

                if strcmpi(choice1,'No') %Check input, if good - break code
                    break
                else
                    BOther=images.roi.AssistedFreehand(gca,'Color','b'); %Draws polygon
                    draw(BOther);
                    BTemp=BOther.createMask(); %Create mask based on drawn shape
                    Bone=Bone+BTemp; %Add mask to previous
                end
        end
        
        %Promt that process is going foreward
        message4 = sprintf('All ROI''s for Bone Has Been Selected!');
        uiwait(msgbox(message4));
        
        %Ensure Normalized (ie: no values greater than 1)
        Bone(Bone>1)=1;
        
        close(ancestor(F1,'figure')); %Close image with ROI drawings, all have been saved as masks
        
    %MAKE MASKS
        %Save mask that only covers region of intrest. Lazy snaping will
        %move to active contour correct areas
        %BackgroundMaskTooth = lazysnapping(I1,L,Tooth,Bone); %Graph based segmentation method. Uses seed contraints given by user
        BackgroundMaskTooth = activecontour(I1,Tooth,'Chan-Vese','SmoothFactor',0.5,'ContractionBias',-0.1);
        BackgroundMaskBone = activecontour(I1,Bone,'Chan-Vese','SmoothFactor',0,'ContractionBias',-0.1); %Slight Outwards contraction to get the full area in question
            BackgroundMaskBone(BackgroundMaskTooth)=0; %Ensure there is no tooth in the bone mask

        %Show the mask overtop of image for user to view
        figure;
        F2=labeloverlay(I1,BackgroundMaskTooth,'Colormap',[0 1 0]); %Overlays the mask as a label on the original image
        F3=labeloverlay(I1,BackgroundMaskBone,'Colormap',[0 0 1]);
        
        LETSEE=imshowpair(F2,F3,'montage');
        title('Tooth Starting Mask (Left) and Bone Starting Mask (Right)');
        
        
    %OPTION TO RESTART
        %Ask user if they would like to try again using a dialog question
        dlgQuestion3 = 'Does Mask Contain All Regions of Intrest?';
        dlgtitle2='ROI Select Again?';
        choice2 = questdlg(dlgQuestion3,dlgtitle2,'Yes','No, Select Again', 'Yes');

        if strcmpi(choice2,'Yes') %Check input, if good - break code
            fprintf('\tInitial Mask selection complete, masks will be used to start stack itterations\n');
            break
        else
            close(ancestor(LETSEE,'figure')); %Close the mask visual
            clearvars -except I1 %Clear variables in case user runs again
            
            continue %Allow to re-draw region & run again
            
        end
end

end

