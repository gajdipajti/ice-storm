% Fluorescence Anisotropy Evaluation and Visualisation for single molecule
% images
% Author:   gajdost
% Version:  0.0.1-dev

% Area selection %
% In this part you can select a crop size
% This is a simple split
areaUP = [200 100 699 350];
areaDW = [200 550 699 350];

% Transformation generation
flagReg = 0;
myDirReg  = '/home/freeman/Dropbox/Munka/adoptim/Diplomamunka/2013_05_30_refData/Calibration_Today/';
myFileReg = 'Cal_fluroscein_10mM_10ms_1emg_100f_r1.tif';

% G-calibration
myDirGCal  =  '/home/freeman/Dropbox/Munka/adoptim/Diplomamunka/2013_05_30_refData/Calibration_Today/';
myFileGCal = 'Cal_fluroscein_10mM_10ms_1emg_100f_r1.tif';

% An input file
myDirData  = '/home/freeman/munka/adoptim/2013_05_30_GFPAnisData/';
%myFileData = 'test1_a1_100f_10ms_200emg.tif';
myFileData = 'test1_a2_stack.tif';

if(flagReg)
    imageReg = imread([myDirReg, myFileReg]);
    % Fits file detection, and flip on detection
    if regexp(myFileReg, '.fits$', 'start')
        imageReg = flipud(imageReg);
    end

    imageUPReg = imcrop(imageReg, areaUP);
    imageDWReg = imcrop(imageReg, areaDW);

    cpselect(imageUPReg, imageDWReg);
    stop;
else
    input_points = [81.904072883172600,18.068595927116803;6.243478027867095e+02,33.073954983922760;6.303499464094318e+02,3.114233654876742e+02;90.157020364415870,2.979185423365488e+02];
    base_points = [81.153804930332340,23.320471596998914;6.220969989281886e+02,23.320471596998857;6.348515541264736e+02,2.979185423365488e+02;96.159163987138300,2.979185423365488e+02];
end
%%
% Transforme two sides
mytrfUD = cp2tform(input_points, base_points, 'projective');

% G-factor Calibration - area selection
imageGCal = imread([myDirGCal, myFileGCal]);

if regexp(myFileGCal, '.fits$', 'start')
    imageGCal = flipud(imageGCal);
end

imageUPGCal = imcrop(imageGCal, areaUP);
imageDWGCal = imcrop(imageGCal, areaDW);
%figure(1); imshow(imageUPGCal);
%figure(2); imshow(imageDWGCal);
% G-factor Calibration - Registration
%imageUPTGCal = imtransform(imageUPGCal, mytrfUD, 'Xdata', [1 size(imageDWGCal,2)], 'Ydata', [1 size(imageDWGCal,1)] );
imageUPTGCal = imtransform(imageUPGCal, mytrfUD, 'Xdata', [1 size(imageDWGCal,2)], 'Ydata', [1 size(imageDWGCal,1)] );
%figure(3); imshow(imageUPTGCal);
% G-factor Map
G = double(imageUPTGCal) ./ double(imageDWGCal);
%figure(4); imshow(G);
%figure(5); hist(G(:), [0.5:0.01:1.5]);
%%
%figure(5); hist(double(imageUPTGCal(:)), 1000);
%figure(6); hist(double(imageDWGCal(:)), 1000);

% iDat = imread([myDirData, myFileData]);
myiInfo = imfinfo([myDirData, myFileData], 'tif');  % Extract file headers and info
numberOfFrames = numel(myiInfo);                    % Number of images in the tif

if regexp(myFileData, '.fits$', 'start')
    iDat = flipud(iDat);
end
%%
sUPRed = uint16(zeros(size(imageUPGCal)));
sDWRed = uint16(zeros(size(imageDWGCal)));
%iUPSum = zeros(699,350,numberOfFrames);
for lpFrames = 1:numberOfFrames
    % Work with small areas
    iDat = imread([myDirData, myFileData], 'tif', 'Index', lpFrames, 'Info', myiInfo);
    
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
%%
figure(7); imshow(sUPRed);
%figure(8); imshow(sDWRed);

%%
B(1,:,1) = iUPSum(176,:,183);
figure(8); plot(B(:));

%%
for x = 1:700
    for z = 180:190
        A(:,1,1) = iUPSum(:,x,z);
       
        fh = figure('Visible','off');
        hist(A(:), [50:20:3000]);
        saveas(fh, [ 'ice-plot/', 'h_', 'X', int2str(x), 'Ys', 'Z', int2str(z) ], 'png')
        close(fh)
        
        fh2 = figure('Visible','off');
        plot(A(:));
        saveas(fh2, [ 'ice-plot/', 'p_', 'X', int2str(x), 'Ys', 'Z', int2str(z) ], 'png')
        close(fh2)
    end
    C(:,1,:) = iUPSum(:,x,:);
    
    fh3 = figure('Visible','off');
    imshow(C(:,:), [1000 7000]);
    saveas(fh3, [ 'ice-plot/', 'd_', 'X', int2str(x), 'Ys', 'Zs' ], 'png')
    close(fh3)
end
%%

fh3 = figure('Visible','on');
    imshow(C(:,:), [1000 7000]);
%    saveas(fh3, [ 'ice-plot/', 'd_', 'X', int2str(309), 'Ys', 'Zs' ], 'tif')
%    close(fh3)



