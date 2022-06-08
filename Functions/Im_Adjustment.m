function [IAdjusted] = Im_Adjustment(I,FiltSize)
%ADJUST THE IMAGE PASSED THROUGH TO INCREASE CONTRAST AND FILTER OUT NOISE
%   INPUT: I - image read in, FiltSize - wiener2 filter size
%   OUTPUT: Adjusted image

    IAdj=imadjust(I); %Adjust Image 
    IAdjusted = wiener2(IAdj,[FiltSize FiltSize]); %Filter out noise 
    
end

