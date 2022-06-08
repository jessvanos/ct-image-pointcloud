function [BMaskNew] = AdjBoneTEX(IMadj,TMask,BMask)
%FURTHER REFINE THE BONE MASK BASED ON THE TOOTH AND PREVIOUS IMAGE
%   INPUT: IMadj gives the image read from the stack, TMask is the Tooth
%       mask of the current image, and BMask is the bone mask from the previous
%       image
%   OUTPUT: AdjBone is the binary image of selected bone area
    
    %The tooth cannot be included, convert to locial to compare & ensure the tooth is not in bone mask
    TMask=logical(TMask); 
    
    %Apply a range filter which sorts out high texture areas (bone)
    nhood=ones(3);
    [J]=rangefilt(IMadj,nhood); 
    
    %Issolate the Bone (ie: Remove Soft Tissue)
    %Binarize to get bone region
    BW=imbinarize(J); 
    
    BW(~BMask)=0; %If the mask from previous is not true, this one is not either (keep area confined)
    SE=strel('disk',11);
    TMaskDil=imdilate(TMask,SE); %Dialate tooth mask over the edges so it gets a good region
    
        SE=strel('disk',3);
    BW2=imdilate(BW,SE); %Dilate out the mask so it covers more area & improves active contour
    BW3=bwareaopen(BW2,500); %Remove areas that we dont want in contour
    BW4=imfill(BW3,'holes'); %Fill holes to improve active contour
    BW4(TMaskDil)=0; %Do not allow mask to be true in the tooth region
    
    BMaskNew=activecontour(IMadj,BW4,'Chan-Vese','SmoothFactor',0.1,'ContractionBias',0.2); 
    BMaskNew(TMaskDil)=0; %Again make sure no tooth is in the final mask! (**MAY NEED EDIT**)
    
    se=strel('disk',3);
    BMaskNew=imclose(BMaskNew,se);
    BMaskNew=bwareaopen(BMaskNew,1500); %Remove small areas to later improve point cloud
    BMaskNew=imfill(BMaskNew,'holes'); %There should be holes but in case there are - now they are gone
    
end

