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
%%
iUPSum = zeros(351,700,200,'uint16');

%for lpFrames = 1:numberOfFrames
for lpFrames = 1:249
    % Work with small areas
    iDat = imread([myHome, myWorkDir, myFileData], 'tif', 'Index', lpFrames, 'Info', myiInfo); % , 'CellArray', '{[200 899], [100 349]}'
    
    iUPDat = imcrop(iDat, areaUP);
    iUPSum(:,:,lpFrames) = iUPDat;
end
%% Search Code
% A code part where the pixel marker works.
mapUPSum = zeros(351,700,250,'uint8');
mapUPCount = zeros(351,700,'uint8');
for x = 1:700
    for y = 1:351
        for z = 1:249
            if (z > 1)
                if ((iUPSum(y,x,z) > 2000) && (mapUPSum(y,x,z-1) > 0))
                    mapUPSum(y,x,z) = mapUPSum(y,x,z) + 1;
                    mapUPCount(y,x) = mapUPCount(y,x) + 1;
                end
            end
            if (iUPSum(y,x,z) > 2500)
                % The first hit is not counted to the global.
                mapUPSum(y,x,z) = mapUPSum(y,x,z) + 1;
            end
        end     
    end
end