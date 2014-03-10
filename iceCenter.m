function [ok, dx, dy, zb, ze] = iceCenter(mx, my, myZStack)

% Ez egy durva közelítést ad a térképen, hogy mekkora kiterjedésű az adott
% felvillanás xy-ban 3*3; 5*5; 7*7;
% Ha két pont van egymás mellett akkor azt jelzi.
% Ezekkel az értékekkel és a már korábban letárolt XYZb-Ze koordinátákkal 
% kerül a Gauss meghajtásra.

ok = 0;
zePuffer = 0;
% Get the PreSearch data from
for ci = 1:size(myZStack,1)
    
    if (( myZStack(ci,1) == mx ) && ( myZStack(ci,2) == my ))
        
        if (zePuffer == 0)
            zb = myZStack(ci,3);
            zePuffer = myZStack(ci,4);
            ok = ok + 1;
        elseif ((myZStack(ci,3)-zePuffer) < 2)
            zePuffer = myZStack(ci,4);
        else
            ze = zePuffer; % Kiírás
            if (ok < 2)
                ZC = [zb, ze];
            else
                ztmp = [zb ze];
                ZC = [ZC; ztmp];
            end
            % Új letárolása
            zb = myZStack(ci,3);
            zePuffer = myZStack(ci,4);
            ok = ok + 1;
        end
    else
        % Did not match, possible noise cut out with myZlimit
        ok = 0;
    end
end
ze = zePuffer; % Kiírás
if (0 < ok < 2)
    ZC = [zb, ze];
else
    ztmp = [zb ze];
    ZC = [ZC; ztmp];
end
%
%
if (ok > 0)
% Overlap check
    
% Multi max check

% DEV::DeArray
% Simplification
deltaZC = 0;
    for zci = 1:size(ZC,1)
        if (deltaZC < (ZC(zci,1) - ZC(zci,2)))
        deltaZC = (ZC(zci,1) - ZC(zci,2));
        zb = ZC(zci,1)
        ze = ZC(zci,2)
        end
    end
    
    % Return
        dx = 2;
        dy = 2;
else
    ok = 0;
    dx = 0;
    dy = 0;
    zb = 0;
    ze = 0;
end
