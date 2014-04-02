% author:  gajdost
% package: ice-storm
% license: GPLv2
% version: 0.0.1

function [bZb, bZe] = iceZZ(Zstack, zEnd)
    bZb = 0;
    bZe = 0;
    for bz = 1:zEnd
        if Zstack(bz) > 0
            if bZb == 0
                bZb = bz;
            end
        else
            if ((bZb > 0) && (bZe == 0))
                bZe = bz-1;
                % Add here store 'n' reset code, to analyse multi blinks.
            end
        end
    end
    % When there was a start, but no end. Add last frame.
    if ((bZe == 0) && (bZb > 0))
        bZe = zEnd;
    end