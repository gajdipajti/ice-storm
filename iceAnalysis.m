%% 
%
% author:  gajdost
% package: ice-storm
% license: GPLv2
% version: 0.d.1 % dummy
function [mUPSum, myZStack] = iceAnalysis(iSum, upperTrigger, lowerTrigger, zEnd, myZlimit, mLimit, localGCal)

mapUPSum = zeros(351,700,zEnd,'uint16');
mapUPCount = zeros(351,700,'uint16');
myZBegin=zeros('uint16');
myZEnd=zeros('uint16');
myZStack = zeros(1,4,'uint16');
str=zeros(1,4,'uint16');
% x=zeros('uint16'); % Not needed, and not working well
% y=zeros('uint16');
% z=zeros('uint16');
for x = 1:700
    for y = 1:351
        mapZflag=0;
        for z = 1:zEnd
            if (iSum(y,x,z) > upperTrigger)
                % The first hit is not counted to the global.
                mapUPSum(y,x,z) = mapUPSum(y,x,z) + 1;
                if (mapZflag == 0)
                    % First match
                    mapZflag = 1;
                    myZBegin=cast(z, 'uint16');
                end
            end
            if (z > 1)
                if ((iSum(y,x,z) > lowerTrigger) && (mapZflag > 0))
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
mUPSum = zeros(351,700,zEnd,'uint32');
while mFlag >0
    [mValue, idx] = max(mUPCount(:));
    [mx, my] = ind2sub(size(mUPCount),idx); % Please note here the dimension chande mx<->mx
    [ok, dx, dy, zb, ze] = iceCenter(mx, my, myZStack);
    % Only run if iceCenter reported success.
    if (ok > 0)
        % Do a data plot from the full ZStack(R)
%        istack(:,1,1) = iSum(mx,my,:);
%        iceStackPlot(mx,my,istack,'ice-plot/');
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
        mG = iceGaussian(localGCal(xb:xe,yb:ye), bgs, iSum(xb:xe,yb:ye,tzb:tze) );
        % Plot done
        for mz = zb:ze
            mUPSum(mx,my,mz) = mG(mz-(zb-1)); 
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
%clear mapUPSum;
clear mUPCount;