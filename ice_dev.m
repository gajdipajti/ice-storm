% Anisotropy scan
% Author:   gajdost
% Version:  0.a.3-dev

% Area selection %
% In this part you can select a crop size
% This is a simple split
areaUP = [200 100 699 350];
areaDW = [200 550 699 350];

% An input file
myHome     = '/home/freeman/';
% myHome     = '/home/gajdost/';
myWorkDir  = 'munka/adoptim/2013_05_30_GFPAnisData/';
myFileData = 'test1_a2_stack.tif';

% Read in
myiInfo = imfinfo([myHome, myWorkDir, myFileData], 'tif');  % Extract file headers and info
numberOfFrames = numel(myiInfo);                            % Number of images in the tif
%%
iUPSum = zeros(351,700,200,'uint16');
zEnd=249;
%zEnd=499;
%for lpFrames = 1:numberOfFrames
for lpFrames = 1:zEnd
    % Work with small areas
    iDat = imread([myHome, myWorkDir, myFileData], 'tif', 'Index', lpFrames, 'Info', myiInfo); % , 'CellArray', '{[200 899], [100 349]}'
    
    iUPDat = imcrop(iDat, areaUP);
    iUPSum(:,:,lpFrames) = iUPDat;
end
clear iDat;
clear iUPDat;
clear myiInfo;
%% Search Code - pre-processer
% A code part where the pixel marker works.
mapUPSum = zeros(351,700,zEnd,'uint16');
mapUPCount = zeros(351,700,'uint16');
myZBegin=zeros('uint16');
myZEnd=zeros('uint16');
myZlimit=6;
myZStack = zeros(1,4,'uint16');
str=zeros(1,4,'uint16');
% x=zeros('uint16'); % Not needed, and not working well
% y=zeros('uint16');
% z=zeros('uint16');
for x = 1:700
    for y = 1:351
        mapZflag=0;
        for z = 1:zEnd
            if (iUPSum(y,x,z) > 2500)
                % The first hit is not counted to the global.
                mapUPSum(y,x,z) = mapUPSum(y,x,z) + 1;
                if (mapZflag == 0)
                    % First match
                    mapZflag = 1;
                    myZBegin=cast(z, 'uint16');
                end
            end
            if (z > 1)
                if ((iUPSum(y,x,z) > 2000) && (mapZflag > 0))
                    mapUPSum(y,x,z) = mapUPSum(y,x,z) + 1;
                    mapUPCount(y,x) = mapUPCount(y,x) + 1;
                end
                if ((mapZflag == 1) && (mapUPSum(y,x,z) < 1))
                    % The end has been located
                    mapZflag=0;
                    myZEnd=cast(z, 'uint16');
                    if ((myZEnd - myZBegin) > myZlimit)
                        str = [ cast(y, 'uint16') cast(x, 'uint16') myZBegin myZEnd ];
                        myZStack = [myZStack; str]; 
                    end
                end
            end
        end
        if (mapZflag == 1)
            %End of stack, must be the end of the blink also
            myZEnd=cast(zEnd, 'uint16');
            if ((myZEnd - myZBegin) > myZlimit)
               str = [ cast(y, 'uint16') cast(x, 'uint16') myZBegin myZEnd ];
               myZStack = [myZStack; str]; 
            end
        end
    end
end
%% Max Value and fit
% Implement me: Missing G calculations
% http://www.mathworks.com/matlabcentral/answers/47428-to-find-the-maximum-value-in-a-matrix
% http://www.mathworks.com/matlabcentral/newsreader/view_thread/269569
mUPCount=mapUPCount;
mFlag = 1;
mLimit = 8;
%mUPSum = zeros(351,700,zEnd,'uint32');
while mFlag >0
    [mValue, idx] = max(mUPCount(:));
    [mx, my] = ind2sub(size(mUPCount),idx); % Please note here the dimension chande mx<->mx
    [ok, dx, dy, zb, ze] = iceCenter(mx, my, myZStack);
    % Only run if iceCenter reported success.
    if (ok > 0)
        % Do a data plot from the full ZStack(R)
        istack(:,1,1) = iUPSum(mx,my,:);
        iceStackPlot(mx,my,istack);
        % Generate indexes for sub
        xb=mx-dx;
        xe=mx+dx;
        yb=my-dy;
        ye=my+dy;
        if zb < 2
            % Must rework
            bgs = 0;
            tzb=zb;
            tze=ze;
        elseif zb < 3
            bgs = 1;
            tzb=zb-1;
            tze=ze+1;
        elseif ze > (zEnd-2)
            % Needs reworking
            bgs = 0;
            tzb=zb;
            tze=ze;
        else
            bgs = 2;
            tzb=zb-2;
            tze=ze+2;
        end
        if tze > zEnd
            tze = zEnd;
        end
        % End generation
        %
        % Clear area, because iceCenter reported ok.
        % Overlapping PSF warning!
        for xi = xb:xe
            for yi = yb:ye
                mUPCount(xi,yi) = 0;
            end
        end
        % Clear Complete
        %
        % Do the plot.
        % Please implement more gaussian fit+volume calculators
        mG = iceGaussian(bgs, iUPSum(xb:xe,yb:ye,tzb:tze) );
        % Plot done
        for mz = zb:ze
            mUPSum(my,mx,mz) = mG(mz-(zb-1)); 
        end
    end
    % Dump the max, it was no use.
    mUPCount(mx,my)=0;
    if mValue < mLimit
        % Hurray limit reached!
        mFlag = 0;
    end
    clear mG;
end
clear iUPSum;
clear mapUPSum;
clear mUPCount;
clear mapUPCount;
%% Create a map
mapFitData = zeros(351,700,'uint32');
for cx = 1:700
    for cy = 1:351
        mapFitData(cy,cx) = sum(mUPSum(cy,cx,:));
    end
end
%% Just a data reader. Nothing fun here.
%A(1,1,:) = iUPSum(176,339,:);
A(1,1,:) = iUPSum(248,528,:);
plot(A(:));
