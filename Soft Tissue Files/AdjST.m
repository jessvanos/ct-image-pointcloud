function [STMaskNew] = AdjST(IMadj,TMask,BMask)
%FURTHER REFINE THE BONE MASK BASED ON THE TOOTH AND PREVIOUS IMAGE
%   INPUT: IMadj gives the image read from the stack, TMask is the Tooth
%       mask of the current image, and BMask is the bone mask from the previous
%       image
%   OUTPUT: AdjBone is the binary image of selected bone area
    
    %The tooth and Bone cannot be included, convert to locial to compare & ensure the tooth is not in bone mask
    TMask=logical(TMask); 
    BMask=logical(BMask);
    
    %Use multithresh to collect 2 levels, roughly seperates bone and soft
    %tissue
    [levels,metric]=multithresh(IMadj,2); 
    
    %Binarize Shape
    %Take the second level and binarize it to get bone level. 
    BWst=imbinarize(IMadj,levels(1));
    
    %Set untrue regions
   % BWst(~STMask)=0; %If the mask from previous is not true, this one is not either (keep area confined)
    SE=strel('disk',15);
    TMaskDil=imdilate(TMask,SE); %Dialate tooth mask over the edges so it gets a good region
    
    %Set regions where bone and tooth are true to zero
    BWst(TMaskDil)=0; %Do not allow mask to be true in the tooth region
    BWst(BMask)=0; %Do not allow mask to be true in the tooth region
    
    STMaskNew=activecontour(IMadj,BWst,'Chan-Vese','SmoothFactor',0.1,'ContractionBias',0.2); 
    STMaskNew(TMask)=0; %Again make sure no tooth is in the final mask! (**MAY NEED EDIT**)

    se=strel('disk',3);
    STMaskNew=imclose(STMaskNew,se);
    STMaskNew=bwareaopen(STMaskNew,1000); %Remove small areas to later improve point cloud
    STMaskNew=imfill(STMaskNew,'holes'); %Fill the small holes
    
end

