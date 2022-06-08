function [pc] = edge2DtoTXT(BWStack,PixSz)
%CONVERT BINARY IMAGE STACK FROM THE BW DATA STORE TO A SCALED 3D POINT
%CLOUD. UTILIZED THE "POINT CLOUD TOOLS FOR MATLAB" ADD ON
%   INPUT: BWStack - Imagedata store stack of binary images, PizSz - the
%   pixel size used to scale point cloud
%   OUTPUT: pc is a point cloud output

%Start with the first image seperatly to assist loop
I=BWStack.readimage(1); %Read in binary image
Edge=edge(I); %Get edges of binary image
[y,x]=find(Edge); %Find coordinated for the edges
z=ones(size(y,1),1)*0; %Populate the z plane at 0
XYZ=[x y z]; %Combine coordinates

n=numel(BWStack.Files); %Get number to run over


%Populate Waitbar to check time remaining for loop, added cancel button
PTWait=waitbar(0,'Loading...','Name','Generating Point Cloud','CreateCancelBtn','setappdata(gcbf,''canceled'',1)');
setappdata(PTWait,'canceled',0); %Create functionality to cancel if its taking too long

thick=1; %Start the stack on z with 1 thickness (for the second image), this counter will be added to increase it

for i=2:n
    
    waitbar(i/n,PTWait,sprintf('Point Cloud is %3.3g%% complete',i/n*100)); %Update waitbar

    
    I=BWStack.readimage(i); %Read image
    Edge=edge(I);
    [y,x]=find(Edge); %Find edge of image
    z=ones(size(y,1),1)*thick; %Set the z plane
    xyz=[x y z];%fill xyz array
    XYZ=[XYZ;xyz];
    
    thick=thick+1; %Add 1 to z place for next time
    
    if getappdata(PTWait,'canceled') %Cancel if option is chosen
        break
    end
end

    delete(PTWait) %Finally, delete the waitbar

    X=XYZ(:,1,:); %Get the x points
    Y=XYZ(:,2,:); %Get the y points
    Z=XYZ(:,3,:); %Get the z points

    pc=pointCloud([X Y Z]); %Generate poitn cloud

    pc.transform(PixSz, eye(3), zeros(3,1)); %transformation from um -> mm and re-scale
    
end