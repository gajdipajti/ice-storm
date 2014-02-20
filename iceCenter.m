function [cflag, cdx, cdy, czb, cze] = iceCenter(cx, cy)

% Ez egy durva közelítést ad a térképen, hogy mekkora kiterjedésű az adott
% felvillanás xy-ban 3*3; 5*5; 7*7;
%> Ha két pont van egymás mellett akkor azt jelzi.
% Ezekkel az értékekkel és a már korábban letárolt XYZb-Ze koordinátákkal 
% kerül a Gauss meghajtásra.

% Get the PreSearch data from
for ci=1:size(myZStack,1)
    if (( myZStack(ci,1) == cx ) && ( myZStack(ci,2) == cy ))
        CZ = [ CZ; [ myZStack(ci,3), myZStack(ci,4) ] ];
        cflag = 1;
    else
        % Did not match, possible noise cut out with myZlimit
        [cflag, cdx, cdy, czb, cze] = zeros(5);
    end
end

if (cflag > 0)
% Overlap check

% Multi max check

end
