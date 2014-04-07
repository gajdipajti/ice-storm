% Anisotropy scan
% Author:   gajdost
% package: ice-storm
% Version:  0.a.4-dev

% Area selection %
% In this part you can select a crop size
% This is a simple split
areaUP = [200 100 699 350]; % normal, out of focus
areaDW = [200 550 699 350]; % rotated, in focus

% An input file
%myHome     = '/home/freeman/';
myHome     = '/home/gajdost/';
myWorkDir  = 'munka/adoptim/2013_05_30_GFPAnisData/';
myFileData = 'test1_a2_stack.tif';

% The registration
myDirReg  = 'Dropbox/Munka/adoptim/Diplomamunka/2013_05_30_refData/Calibration_Today/';
myFileReg = 'Cal_fluroscein_10mM_10ms_1emg_100f_r1.tif';
iReg = imread([myHome, myDirReg, myFileReg]);
imReg = flipud(iReg);
irUP = imcrop(imReg, areaUP);
irDW = imcrop(imReg, areaDW);
%cpselect(irUP, irDW);
%%
% http://www.mathworks.com/help/images/ref/cp2tform.html
% http://www.mathworks.com/help/images/ref/tformfwd.html

input_points = [89.4067524115756 297.168274383708;161.432475884244 303.170418006431;427.777599142551 305.421221864952;629.599678456592 317.425509110397;548.570739549839 31.5734190782422;52.6436227224009 33.0739549839228;229.706859592712 24.0707395498392;42.1398713826367 298.668810289389];
base_points = [95.4088960342980 298.668810289389;168.935155412647 303.170418006431;433.029474812433 299.419078242229;631.850482315112 304.670953912112;547.070203644159 24.8210075026795;53.3938906752412 36.8252947481243;227.456055734191 24.8210075026795;51.1430868167203 303.920685959271];
myTFORM = cp2tform(input_points, base_points, 'projective');
itDW = imtransform(irDW, myTFORM, 'Xdata', [1 size(irDW,2)], 'Ydata', [1 size(irDW,1)] );
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
%imshow(iDat);
%clear myiInfo;
%% Search Code - pre-processer
% A code part where the pixel marker works.
[mUP, mUPXYZZ] = iceAnalysis(iUPSum,2300,1900,zEnd,6,7);
[mDW, mDWXYZZ] = iceAnalysis(iDWSum,2300,1900,zEnd,6,7);
% Two cubes are retured, which include the intensity data.
%% Create a maps
mDWSum = zeros(351,700,'double');
mUPSum = zeros(351,700,'double');
for cx = 1:700
    for cy = 1:351
        mDWSum(cy,cx) = cast(sum(mDW(cy,cx,:)), 'double');
        mUPSum(cy,cx) = cast(sum(mUP(cy,cx,:)), 'double');
    end
end
imwrite(mUPSum,'mUPSum.tif','Compression','none','WriteMode','append');
imwrite(mDWSum,'mDWSum.tif','Compression','none','WriteMode','append');
mtUPSum = imtransform(mUPSum, myTFORM, 'Xdata', [1 size(mUPSum,2)], 'Ydata', [1 size(mUPSum,1)] );
imwrite(mtUPSum,'mtUPSum.tif','Compression','none','WriteMode','append')
%imshow(mtUPSum);
%imshow(mDWSum);

%% Match blinks
% Get maximus, as before.
% Set limit here.
maximus = 1;
deltaLOCX = 5;
deltaLOCY = 3;
mTMPSum = mUPSum;
mTMP = mUP;
mTRFSum = mDWSum;
mTRF = mDW;
while maximus > 0
    [bValue, idb] = max(mTMPSum(:));
    [by, bx] = ind2sub(size(mTMPSum),idb); %Possible dim change??? %FIXME%

% OFF: https://www.youtube.com/watch?v=CLXt3yh2g0s
%   And now you're gonna FIX ME
%   I know you're gonna FIX ME
%   I guarantee you'll FIX ME'cause you changed the way of data parsin'.

%   Our array feels wrong please revert it back
%   Our transform feels wrong can't hide the cracks
%   I guarantee you'll miss me 'cause you changed the way of data parsin'.

%    iceStackPlot(bx,by,mTMP(by,bx,:),'ice-summed/');
    % As there is no background, this will work just fine and the XYZbZe stuff is left out.
    % This way it is cleaner.
%    [bZb, bZe] = iceZZ(mTMP(by,bx,:),zEnd);
    % This will need a wrapper for multi-blinks
    [tx, ty] = tformfwd(myTFORM, bx, by);
    txb= uint16(tx) - deltaLOCX;
    txe= uint16(tx) + deltaLOCX;
    tyb= uint16(ty) - deltaLOCY;
    tye= uint16(ty) + deltaLOCY;
    
    % Find the matching needle on the carpet.
    % This solution must be upstreamed to solve the workaround in
    % iceAnalysis
    ij = 1;
    PosPair = zeros(1,4,'uint16');
    % Clear preDeltaZ
    preDeltaZ = 0;
    deltaZ = 0;
    for itx = txb:txe
        for ity = tyb:tye
            if mTRFSum(ity, itx) > 0
                % Possible pairs
                %               FOUND Y_X - TRF Y_X
                [bZb, bZe] = iceZZ(mTMP(by,bx,:),zEnd);
                [tZb, tZe] = iceZZ(mTRF(ity,itx,:),zEnd);
                if ((tZb < bZe) && (bZb < tZe))
                    % Valid match, only when there is a "segment > 0"
                    mZb = max(bZb, tZb);
                    mZe = min(bZe, tZe);
                    deltaZ = mZe - mZb;
                    % Classify the pairs with deltaZ.
                    % The longer the segment, the better the match
                    if preDeltaZ < deltaZ
                        % Store the better fit.
                        preDeltaZ = deltaZ;
                        matchY = ity;
                        matchX = itx;
                        matchZb= mZb;
                        matchZe= mZe;
                    end
                end
                PosPair(ij,:) = [ ity itx ty tx ];
                Pairs = [ bZb bZe tZb tZe  ];
                ij = ij + 1;
            end
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % Do the Harlem Shake, but on ice.
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % There is nothing to be seen here, move along...
    mTMPSum(by,bx)=0; % Remove the found maximum.
    

%   undef PosPair;
    % This will leave nobody behind, as there is no value between 1000 and 1, only zeroes.
    if bValue < 10000
       maximus = 0;
    end
end


%% Just a data reader. Nothing fun here.
%A(1,1,:) = iUPSum(176,339,:);
%A(1,1,:) = iUPSum(248,528,:);
%plot(A(:));
