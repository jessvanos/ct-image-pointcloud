function [MaskedImage] = BackgroundRemoval(I,CropSizeRow, CropSizeCol,BackgroundMask)
%TAKES INPUT FROM the Crop_BackGone FUNCTION TO CROP INDIVIDUAL IMAGE AND
%REMOVE BACKGROUND
%   INPUT: I is the input image, CropSizeRow & CropSizeCol specify placement
%       and new dimensions, BackgroundMask will remove unwanted background area
%   OUTPUT: MaskedImage is the final image is returned as a masked image

    %CROP IMAGE
    I2crop=I(CropSizeRow, CropSizeCol);

    %MASK IMAGE
    MaskedImage = I2crop;
    MaskedImage(~BackgroundMask) = 0; %Everywhere that is not in the mask foreground set to zero (black)

end

