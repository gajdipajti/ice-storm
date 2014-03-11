%% Analyses the maximum found by the script, and returns the pre-fit param.
% author:  gajdost
% package: ice-storm
% license: GPLv2
% version: 0.a.1 % alpha

function [lok, ldx, ldy, lzb, lze] = iceCenter(lx, ly, locZStack, izstack)
% This is a pre analizer and plotter function. 
%
% Input
% lx -> matrice index
% ly -> matrice index
% locZStack -> pre-fit data with XYZbZe in a vector found_blinks*4
% izstack -> contains the Z-Stack(R) from the real image.
%
% Returns:
% lok -> ok to be fitted
% ldx -> max_diff from lx
% ldy -> max_diff from ly
% lzb -> blink begin frame index
% lze -> blink end frame index
%
% Outputs:
% ~/ice-plot/h_ -> Z-Stack(R) histogram
% ~/ice-plot/p_ -> Z-Stack(R) plot
%
% Notes:
% -> please mind the short wires.
% -> some functions must be implemented
% -> the data processing must be rewritten to include trajectories
% -> implement enable/disable plots
% -> do a harlem shake, if success.


lok = 0;
zePuffer = 0;
% Get the PreSearch data from
for ci = 1:size(locZStack,1)
    
    if (( locZStack(ci,1) == lx ) && ( locZStack(ci,2) == ly ))
        
        if (zePuffer == 0)
            lzb = locZStack(ci,3);
            zePuffer = locZStack(ci,4);
            lok = lok + 1;
        elseif ((locZStack(ci,3)-zePuffer) < 2)
            zePuffer = locZStack(ci,4);
        else
            lze = zePuffer; % Kiírás
            if (lok < 2)
                ZC = [lzb, lze];
            else
                ztmp = [lzb lze];
                ZC = [ZC; ztmp];
            end
            % Új letárolása
            lzb = locZStack(ci,3);
            zePuffer = locZStack(ci,4);
            lok = lok + 1;
        end
    end
end
%
if (lok > 0)
    % Last writeout
    % Algorithmic design.
    lze = zePuffer;
    if (lok < 2)
        ZC = [lzb, lze];
    else
        ztmp = [lzb lze];
        ZC = [ZC; ztmp];
    end
    
    % Do the Harlem Shake
    % Please note the dimension name-change
    % Dev output
    
        fh = figure('Visible','off');
        hist(izstack(:), [50:20:5000]);
        saveas(fh, [ 'ice-plot/', 'h_', 'X', int2str(ly), 'Y', int2str(lx), 'Zs'  ], 'png')
        close(fh)
        
        fh2 = figure('Visible','off');
        plot(izstack(:));
        saveas(fh2, [ 'ice-plot/', 'p_', 'X', int2str(ly), 'Y', int2str(lx), 'Zs'  ], 'png')
        close(fh2)
    
    % Overlap check
    % Not implemented
    
    % Multi max check
    % Not implemented

    % DEV::DeArray
    % Short wired!
    deltaZC = 0;
    for zci = 1:size(ZC,1)
        if (deltaZC < (ZC(zci,1) - ZC(zci,2)))
        deltaZC = (ZC(zci,1) - ZC(zci,2));
        lzb = ZC(zci,1);
        lze = ZC(zci,2);
        end
    end
    
    % Return
    % Short wired!
        ldx = 2;
        ldy = 2;
else
    % When nothing is good.
    lok = 0;
    ldx = 0;
    ldy = 0;
    lzb = 0;
    lze = 0;
end
