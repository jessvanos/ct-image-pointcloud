function VisSegResult2(OGStack,BWStack,TStack,STStack)
%FUNCTION TO VISUALIZE BONE SEGMENTAION RESULTS BASED ON INPUT IMAGE
%NUMBER. DISPLAYS A FIGURE WITH 3 SIDE BY SIDE IMAGES
%   INPUT: OGstack - original cropped image stack, BWStack - binary bone image stack, TStack - Binary Tooth image stack
%   OUTPUT: n/a

    %Image Number to Visualize during process
    imNumString=sprintf('Please enter image # to view segmentation results'); 
    imNUM=USERInput(imNumString); %Get image number
    
    choice='Yes'; %Pre-set to yes t the loop may run
    
    while strcmpi(choice,'Yes')

        %Read in the images specified by the input number
        OG=im2double(OGStack.readimage(imNUM));
        BW=im2double(BWStack.readimage(imNUM));
        T=im2double(TStack.readimage(imNUM));
        ST=im2double(STStack.readimage(imNUM));

        FG=figure('units','normalized','outerposition',[0 0 1 1]); %Create a figure that spans the fullscreen
        F1=tiledlayout(1,4,'TileSpacing','compact','Padding','compact'); %Tile layout, 3 images side by side
        title(F1,'Segmentation Visuals','fontweight','bold','fontsize',20) %Title Figure
        
        %Boundary Figure
        nexttile;
        imshow(OG); hold on;%Show the final ones
        visboundaries(BW,'Color','b'); %Outline the bianry area
        STRINGNUM=sprintf('Bone Mask Outline Over Image %g',imNUM);
        title(STRINGNUM);axis off;

        %Overlayed soft tissue mask figure
        nexttile;
        imshowpair(OG,ST)
        STRINGNUMV3=sprintf('Overlayed Soft Tissue Mask Region For Image %g',imNUM);
        title(STRINGNUMV3); 
        
        %Overlayed bone mask figure
        nexttile;
        imshowpair(OG,BW)
        STRINGNUMV3=sprintf('Overlayed Bone Mask Region For Image %g',imNUM);
        title(STRINGNUMV3); 

        %OVerlayed Tooth mask figure
        nexttile;
        imshowpair(OG,T)
        STRINGNUMV3=sprintf('Overlayed Tooth Mask Region For Image %g',imNUM);
        title(STRINGNUMV3);
        
        %Dialog box to ask user if they want to select all files
        dlgQuestion = 'Would you like to view another Image?'; %Set Question
        dlgtitle='Boundary Visualization'; %Set Title
        choice = questdlg(dlgQuestion,dlgtitle,'Yes','No','Yes'); %Two choices
        
        if strcmpi(choice,'No')
            break %Exit loop
        end
        
        close(ancestor(FG,'figure')); %Close figure so new one can be opened
        
        %Image Number to Visualize during next process
        imNumString=sprintf('Please enter image # to view segmentation results'); 
        imNUM=USERInput(imNumString);
        
    end
end
