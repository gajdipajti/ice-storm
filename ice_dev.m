% Anisotropy scan
% Author:   gajdost
% Version:  0.0.2-dev

% Area selection %
% In this part you can select a crop size
% This is a simple split
areaUP = [200 100 699 350];
areaDW = [200 550 699 350];

% An input file
myHome     = '/home/freeman/';
% myHome   = '/home/gajdost/';
myWorkDir  = 'munka/adoptim/2013_05_30_GFPAnisData/';
myFileData = 'test1_a2_stack.tif';

%Read in
myiInfo = imfinfo([myHome, myWorkDir, myFileData], 'tif');  % Extract file headers and info
numberOfFrames = numel(myiInfo);                            % Number of images in the tif

%for lpFrames = 1:numberOfFrames
iUPSum = zeros(351,700,100,'uint16');
%%
for lpFrames = 150:249
    % Work with small areas
    iDat = imread([myHome, myWorkDir, myFileData], 'tif', 'Index', lpFrames, 'Info', myiInfo); % , 'CellArray', '{[200 899], [100 349]}'
    
    iUPDat = imcrop(iDat, areaUP);
    iUPSum(:,:,lpFrames-149) = iUPDat;
end
%% Search Code
% A code part where...


