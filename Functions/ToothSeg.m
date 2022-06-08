function [TStack] = ToothSeg(IMadj,TMask)
%SEGMENTATION FOR TOOTH AREA BASED ON USER DEFINITION AND PREVIOUS MASKS
%   INPUT: IMadj gives the image read from the stack, TMask is the Tooth
%       mask of the previous image
%   OUTPUT: TStack is the binary image of selected tooth area

    TStack=activecontour(IMadj,TMask,'Chan-Vese','SmoothFactor',0.5,'ContractionBias',0.1); %Expand mask to edges of shape using region based energy model
    TStack=bwareafilt(TStack,1); %Only One tooth area will be accepted

end

