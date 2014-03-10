%% Returns the volume under the 2D Gaussian.
% Currently running in fake-Riemann mode.
% author:  gajdost
% package: ice-storm
% version: 0.d.1 % dummy
function [I] = iceGaussian(bgs, stack)
% stack -> first-2 and last-2 are considered backdround
%       -> this must be from the real picture
%       -> the main script must do the wrapping
%       -> does not think about trajectories

% Collected references:
% www.exelisvis.com/docs/GAUSS2DFIT.html
% http://jila.colorado.edu/bec/BEC_for_everyone/matlabfitting.htm
% https://uqu.edu.sa/files2/tiny_mce/plugins/filemanager/files/4282164/Gaussian%20function.pdf
% http://www.weizmann.ac.il/home/eofek/matlab/FitFun/fit_gauss2d.m
% http://www.igorexchange.com/node/1553

% Get the size of the stack
[Sx,Sy,Sz] = size(stack);

% check background
% mean of a matrix is a vector
switch bgs
    case 0
        SMean = cast((mean(mean(stack(:,:,Sz-1))) + mean(mean(stack(:,:,Sz))))/2, 'uint32');
        dze = 0;
        dzb = 0;
    case 1
        SMean = cast((mean(mean(stack(:,:,1))) + mean(mean(stack(:,:,Sz))))/4, 'uint32');
        dze = 1;
        dzb = 1;
    case 2
        SMean = cast((mean(mean(stack(:,:,1))) + mean(mean(stack(:,:,2)))+mean(mean(stack(:,:,Sz-1))) + mean(mean(stack(:,:,Sz))))/4, 'uint32');
        dze = 2;
        dzb = 2;
    otherwise
        SMean = cast((mean(mean(stack(:,:,1))) + mean(mean(stack(:,:,2)))+mean(mean(stack(:,:,Sz-1))) + mean(mean(stack(:,:,Sz))))/4, 'uint32');
        dze = 2;
        dzb = 2;
end

% Dummy - Riemann
for Si = (1+dzb):(Sz-dze)
    smeany = Sx*Sy*SMean;
    stacky = stack(:,:,Si);
    sumy = sum(stacky);
    summy = sum(sumy);
    I(Si-dzb) = summy - smeany;
end
