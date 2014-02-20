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
% myHome     = '/home/gajdost/';
myWorkDir  = 'munka/adoptim/2013_05_30_GFPAnisData/';
myFileData = 'test1_a2_stack.tif';

%Read in
myiInfo = imfinfo([myHome, myWorkDir, myFileData], 'tif');  % Extract file headers and info
numberOfFrames = numel(myiInfo);                            % Number of images in the tif
%%
iUPSum = zeros(351,700,200,'uint16');
zEnd=249;
%for lpFrames = 1:numberOfFrames
for lpFrames = 1:zEnd
    % Work with small areas
    iDat = imread([myHome, myWorkDir, myFileData], 'tif', 'Index', lpFrames, 'Info', myiInfo); % , 'CellArray', '{[200 899], [100 349]}'
    
    iUPDat = imcrop(iDat, areaUP);
    iUPSum(:,:,lpFrames) = iUPDat;
end
clear iDat;
clear iUPDat;
%% Search Code
% A code part where the pixel marker works.
mapUPSum = zeros(351,700,zEnd,'uint16');
mapUPCount = zeros(351,700,'uint16');
myZBegin=zeros('uint16');
myZEnd=zeros('uint16');
myZlimit=8;
myZStack = zeros(1,4,'uint16');
str=zeros(1,4,'uint16');
% x=zeros('uint16');
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
%% Max Value
% http://www.mathworks.com/matlabcentral/answers/47428-to-find-the-maximum-value-in-a-matrix
% http://www.mathworks.com/matlabcentral/newsreader/view_thread/269569
mUPCount=mapUPCount;
mFlag = 1;
mLimit = 8;
mUPSum = zeros(351,700,zEnd,'uint32');
while mFlag >0
    [mValue, idx] = max(mUPCount(:));
    [mx, my] = ind2sub(size(mUPCount),idx);
    [ok, dx, dy, zb, ze] = iceCenter(mx,my);
    % 
    % mG = iceGaussian( iUpSum(xb:xe,yb:ye,zb:ze) );
%    for mz = zb:ze
%        mUPSum(my,mx,mz) = mG(mz); 
%    end
    mUPCount(mx,my)=0;
    if mValue < mLimit
        mFlag = 0;
    end
%    clear mG;
end   
%%
A(1,1,:) = mapUPSum(176,339,:);
plot(A(:));