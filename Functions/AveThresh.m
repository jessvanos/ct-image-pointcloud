function [levels, metricAvg] = AveThresh(AdjStack,ThreshNum,Seperation)
%TAKES IMAGES AND FINDS A SPECIFIED NUMBER OF AVERAGE THRESHOLDS FOR THE
%STACK
%   INPUT: AdjStack is adjusted images data store which can be taken into
%       function, allows images to be read. Seperation gives the image seperation
%       which you will use to get averages (ie: Seperation=1 would take average
%       from all images. ThreshNum gives number of thresholds which will be
%       collected. Maximum of 4
%   OUTPUT: levels, a vector containing the threshold levels for each
%   layer. metricAve is a thresholding metric calculated which gives effectivness of Otsu's method on a scale of 0 to 1. 

    PreAl=(1:Seperation:numel(AdjStack.Files)); %Get the image indiceies based on seperation chosen
    PreAlNum=numel(PreAl); %Total number of images which will be used for averages

    %Pre-allocate threshold matricies. Several if statements depending on
    %number of thresholds chosen
    if ThreshNum==1
        Thresh1=zeros(1,PreAlNum); %Pre-allocate matrix
        metricALL=zeros(1,PreAlNum); %Pre-Allocate the metric
        
        %For loop to gather all thresholds
        for i=1:PreAlNum
                I2Thresh=im2double(AdjStack.readimage(PreAl(i))); %read in image

                %multithresh tool is used to extract number of thresholds for image. Uses entire histogram.
                [level, metric]=multithresh(I2Thresh,ThreshNum); %Use multithresh with 2 levels, this will pick up the bone vs soft tissue 

                Thresh1(i)=level(1); %Save first threshold, for entire image
                metricALL(i)=metric; %Save the threshold metric
        end

        %Take Average
        Thresh1Ave=mean(Thresh1);
        
        metricAvg=mean(metricALL); %Save the threshold metric
        [metricMin, IndMin]=min(metricALL);
        [metricMax, IndMax]=max(metricALL);
        
        levels=Thresh1Ave;
        
    elseif ThreshNum==2
        Thresh1=zeros(1,PreAlNum);
        Thresh2=zeros(1,PreAlNum);
        metricALL=zeros(1,PreAlNum); %Pre-Allocate the metric

        %For loop to gather all thresholds
        for i=1:PreAlNum
                I2Thresh=im2double(AdjStack.readimage(PreAl(i))); %read in image

                %multithresh tool is used to extract number of thresholds for image. Uses entire histogram.
                [level, metric]=multithresh(I2Thresh,ThreshNum); %Use multithresh with 2 levels, this will pick up the bone vs soft tissue 

                Thresh1(i)=level(1); %Save first threshold, lower threshold. Includes soft tissue and bone
                Thresh2(i)=level(2); %Save second threshold, higher. Includes bone
                metricALL(i)=metric; %Save the threshold metric
        end

        %Take Averages for each thre
        Thresh1Ave=mean(Thresh1);
        Thresh2Ave=mean(Thresh2);
        
        metricAvg=mean(metricALL); %Save the threshold metric
        [metricMin, IndMin]=min(metricALL);
        [metricMax, IndMax]=max(metricALL);

        levels=[Thresh1Ave, Thresh2Ave];

    elseif ThreshNum==3
        Thresh1=zeros(1,PreAlNum);
        Thresh2=zeros(1,PreAlNum);
        Thresh3=zeros(1,PreAlNum);
        metricALL=zeros(1,PreAlNum); %Pre-Allocate the metric

        %For loop to gather all thresholds
        for i=1:PreAlNum
                I2Thresh=im2double(AdjStack.readimage(PreAl(i))); %read in image

                %multithresh tool is used to extract number of thresholds for image. Uses entire histogram.
                [level, metric]=multithresh(I2Thresh,ThreshNum); %Use multithresh with 2 levels, this will pick up the bone vs soft tissue 

                Thresh1(i)=level(1); 
                Thresh2(i)=level(2);
                Thresh3(i)=level(3);
                metricALL(i)=metric; %Save the threshold metric
        end

        %Take Averages for each thre
        Thresh1Ave=mean(Thresh1);
        Thresh2Ave=mean(Thresh2);
        Thresh3Ave=mean(Thresh3);
        
        metricAvg=mean(metricALL); %Save the threshold metric
        [metricMin, IndMin]=min(metricALL);
        [metricMax, IndMax]=max(metricALL);

        levels=[Thresh1Ave, Thresh2Ave, Thresh3Ave];
        
    else ThreshNum>3;
        Thresh1=zeros(1,PreAlNum);
        Thresh2=zeros(1,PreAlNum);
        Thresh3=zeros(1,PreAlNum);
        Thresh4=zeros(1,PreAlNum);
        metricALL=zeros(1,PreAlNum); %Pre-Allocate the metric
        
                %For loop to gather all thresholds
        for i=1:PreAlNum
                I2Thresh=im2double(AdjStack.readimage(PreAl(i))); %read in image

                %multithresh tool is used to extract number of thresholds for image. Uses entire histogram.
                [level, metric]=multithresh(I2Thresh,4); %Use multithresh with 2 levels, this will pick up the bone vs soft tissue 

                Thresh1(i)=level(1); 
                Thresh2(i)=level(2);
                Thresh3(i)=level(3);
                Thresh4(i)=level(4);
                metricALL(i)=metric; %Save the threshold metric
        end

        %Take Averages for each thre
        Thresh1Ave=mean(Thresh1);
        Thresh2Ave=mean(Thresh2);
        Thresh3Ave=mean(Thresh3);
        Thresh4Ave=mean(Thresh4);
        
        metricAvg=mean(metricALL); %Save the threshold metric
        [metricMin, IndMin]=min(metricALL);
        [metricMax, IndMax]=max(metricALL);

        levels=[Thresh1Ave, Thresh2Ave, Thresh3Ave,Thresh4Ave,];
        
    end
    
    fprintf('<strong>THRESHOLD METRIC INFO:</strong> \nMetric gives the effectivness of thresholds found using Otsu''s Method. \nGiven in a range from [0 1], a higher value indicates greater effectivness seperating the image into N+1 classes \n\n');
    fprintf('\t<strong>Average Metric= </strong>%4.3g \n\n\t<strong>Minimum Metric = </strong>%4.3g for Image Number %d \n\n\t<strong>Maximum Metric = </strong>%4.3g for Image Number %d \n\n',metricAvg,metricMin,IndMin,metricMax,IndMax);
    
end

