%% A plotter function for 1D stack data.
% author:  gajdost
% package: ice-storm
% license: GPLv2
% version: 0.a.1 % alpha
function iceStackPlot(lx, ly, izstack, ipath)
% Input
% lx -> matrice index
% ly -> matrice index
% izstack -> contains the Z-Stack(R) from the real image.
%
% Outputs:
% ~/ice-plot/h_ -> Z-Stack(R) histogram-Z
% ~/ice-plot/p_ -> Z-Stack(R) I-Z plot
%
% Do the Harlem Shake
% Please note the dimension name-change
% Dev output
fh = figure('Visible','off');
% [50:20:5000]
hist(izstack(:) );
saveas(fh, [ ipath, 'h_', 'X', int2str(ly), 'Y', int2str(lx), 'Zs'  ], 'png')
close(fh)
        
fh2 = figure('Visible','off');
plot(izstack(:));
saveas(fh2, [ ipath, 'p_', 'X', int2str(ly), 'Y', int2str(lx), 'Zs'  ], 'png')
close(fh2)