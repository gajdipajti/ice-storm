% Anisotropy scan
% Author:   gajdost
% Version:  0.a.3-dev

% Area selection %
% In this part you can select a crop size
% This is a simple split
areaUP = [200 100 699 350]; % rotated, in focus
areaDW = [200 550 699 350]; % normal, out of focus

% An input file
myHome     = '/home/freeman/';
%myHome     = '/home/gajdost/';
myWorkDir  = 'munka/adoptim/2013_05_30_GFPAnisData/';
myFileData = 'test1_a2_stack.tif';

% The registration
myDirReg  = '/home/freeman/Dropbox/Munka/adoptim/Diplomamunka/2013_05_30_refData/Calibration_Today/';
myFileReg = 'Cal_fluroscein_10mM_10ms_1emg_100f_r1.tif';
iReg = imread([myDirReg, myFileReg]);
imReg = flipud(iReg);
irUP = imcrop(imReg, areaUP);
irDW = imcrop(imReg, areaDW);
cpselect(irUP, irDW);
%%
% http://www.mathworks.com/help/images/ref/cp2tform.html
% http://www.mathworks.com/help/images/ref/tformfwd.html

input_points = [89.4067524115756 297.168274383708;161.432475884244 303.170418006431;427.777599142551 305.421221864952;629.599678456592 317.425509110397;548.570739549839 31.5734190782422;52.6436227224009 33.0739549839228;229.706859592712 24.0707395498392;42.1398713826367 298.668810289389];
base_points = [95.4088960342980 298.668810289389;168.935155412647 303.170418006431;433.029474812433 299.419078242229;631.850482315112 304.670953912112;547.070203644159 24.8210075026795;53.3938906752412 36.8252947481243;227.456055734191 24.8210075026795;51.1430868167203 303.920685959271];
mytform = cp2tform(input_points, base_points, 'projective');
itDW = imtransform(irDW, mytform, 'Xdata', [1 size(irDW,2)], 'Ydata', [1 size(irDW,1)] );
imshow(itDW);
%%
% Read in
myiInfo = imfinfo([myHome, myWorkDir, myFileData], 'tif');  % Extract file headers and info
numberOfFrames = numel(myiInfo);                            % Number of images in the tif
%%
zEnd=249;
iUPSum = zeros(351,700,zEnd,'uint16');
iDWSum = zeros(351,700,zEnd,'uint16');

%for lpFrames = 1:numberOfFrames
for lpFrames = 1:zEnd
    % Work with small areas
    iDat = imread([myHome, myWorkDir, myFileData], 'tif', 'Index', lpFrames, 'Info', myiInfo); % , 'CellArray', '{[200 899], [100 349]}'
    
    iUPDat = imcrop(iDat, areaUP);
    iUPSum(:,:,lpFrames) = iUPDat;
    iDWDat = imcrop(iDat, areaDW);
    iDWSum(:,:,lpFrames) = iDWDat;
end
%%
imshow(iDat);
%clear myiInfo;
%% Search Code - pre-processer
% A code part where the pixel marker works.
[mUP, mUPXYZZ] = iceAnalysis(iUPSum,2300,1900,zEnd,6,7);
[mDW, mDWXYZZ] = iceAnalysis(iDWSum,2300,1900,zEnd,6,7);
% Two cubes are retured, which include the intensity data.
%% Create a maps
mapFitData = zeros(351,700,'double');
for cx = 1:700
    for cy = 1:351
        mDWSum(cy,cx) = cast(sum(mDW(cy,cx,:)), 'double');
        mUPSum(cy,cx) = cast(sum(mUP(cy,cx,:)), 'double');
    end
end
imwrite(mUPSum,'mUPSum.tif','Compression','none','WriteMode','append')
imwrite(mDWSum,'mDWSum.tif','Compression','none','WriteMode','append')
itUPSum = imtransform(mUPSum, mytform, 'Xdata', [1 size(mapFitData,2)], 'Ydata', [1 size(mapFitData,1)] );
imwrite(itUPSum,'mtUPSum.tif','Compression','none','WriteMode','append')
imshow(itUPSum);
%% Just a data reader. Nothing fun here.
%A(1,1,:) = iUPSum(176,339,:);
%A(1,1,:) = iUPSum(248,528,:);
%plot(A(:));
