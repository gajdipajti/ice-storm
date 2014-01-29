% Anisotropy scan
% Author:   gajdost
% Version:  0.0.1-dev

% Area selection %
% In this part you can select a crop size
% This is a simple split

% An input file
myHome     = '/home/freeman';
myWorkDir  = 'munka/adoptim/2013_05_30_GFPAnisData/';
myFileData = 'test1_a2_stack.tif';

%Read in
myiInfo = imfinfo([myHome, myWorkDir, myFileData], 'tif');  % Extract file headers and info
numberOfFrames = numel(myiInfo);                            % Number of images in the tif

%for lpFrames = 1:numberOfFrames
for lpFrames = 1:100
    % Work with small areas
    iDat = imread([myHome, myWorkDir, myFileData], 'tif', 'Index', lpFrames, 'Info', myiInfo, 'CellArray', '{[200 899], [100 349]}');
    
    iUPDat = imcrop(iDat, areaUP);
    iDWDat = imcrop(iDat, areaDW);
    iUPSum(:,:,lpFrames) = iUPDat;
    iUPRed = iUPDat - 1800;
    iDWRed = iDWDat - 1400;
    
    sUPRed = sUPRed + iUPRed;
    sDWRed = sDWRed + iDWRed;

    %figure(9); hist(double(iUPDat(:)), [50:20:30000]);
    %figure(10); hist(double(iDWDat(:)), 500);
end