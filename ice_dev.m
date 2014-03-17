% Anisotropy scan
% Author:   gajdost
% Version:  0.a.3-dev

% Area selection %
% In this part you can select a crop size
% This is a simple split
areaUP = [200 100 699 350];
areaDW = [200 550 699 350];

% An input file
%myHome     = '/home/freeman/';
myHome     = '/home/gajdost/';
myWorkDir  = 'munka/adoptim/2013_05_30_GFPAnisData/';
myFileData = 'test1_a2_stack.tif';

% Read in
myiInfo = imfinfo([myHome, myWorkDir, myFileData], 'tif');  % Extract file headers and info
numberOfFrames = numel(myiInfo);                            % Number of images in the tif
%%
iUPSum = zeros(351,700,200,'uint16');
iDWSum = zeros(351,700,200,'uint16');
zEnd=249;
%zEnd=499;
%for lpFrames = 1:numberOfFrames
for lpFrames = 1:zEnd
    % Work with small areas
    iDat = imread([myHome, myWorkDir, myFileData], 'tif', 'Index', lpFrames, 'Info', myiInfo); % , 'CellArray', '{[200 899], [100 349]}'
    
    iUPDat = imcrop(iDat, areaUP);
    iUPSum(:,:,lpFrames) = iUPDat;
    iDWDat = imcrop(iDat, areaDW);
    iDWSum(:,:,lpFrames) = iDWDat;
end
clear iDat;
clear iUPDat;
clear iDWDat;
clear myiInfo;
%% Search Code - pre-processer
% A code part where the pixel marker works.
[mUPSum, mUPXYZZ] = iceAnalysis(iUPSum,2500,2000,zEnd,6,8);
[mDWSum, mDWXYZZ] = iceAnalysis(iDWSum,2500,2000,zEnd,6,8);
% Two cubes are retured, which include the intensity data.
%% Create a map
mapFitData = zeros(351,700,'double');
for cx = 1:700
    for cy = 1:351
        mapFitData(cy,cx) = cast(sum(mUPSum(cy,cx,:)), 'double');
    end
end
imshow(mapFitData);
%% Just a data reader. Nothing fun here.
%A(1,1,:) = iUPSum(176,339,:);
%A(1,1,:) = iUPSum(248,528,:);
%plot(A(:));
