%% Returns the volume under the 2D Gaussian.
% Currently running in fake-Riemann mode.
% author:  gajdost
% package: ice-storm
% license: GPLv2
% version: 0.d.1 % dummy

function [I] = iceGaussian(lgc, bg, stack)
% stack -> first-[0,1,2] and last-[0,1,2] are considered backdround
%       -> this must be from the real picture
%       -> the main script must do the wrapping
%       -> does not think about trajectories
%       -> TODO>>implement a background evaluator and checker
%       -> TODO>>implement a background source generator for the 0 case

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
switch bg
    case 0
        % When the blink is too long to get a background.
        SMean = cast((mean(mean(stack(:,:,Sz-1))) + mean(mean(stack(:,:,Sz))))/2, 'uint32');
        dze = 0;
        dzb = 0;
    case 1
        % When only the first and last is background.
        SMean = cast((mean(mean(stack(:,:,1))) + mean(mean(stack(:,:,Sz))))/4, 'uint32');
        dze = 1;
        dzb = 1;
    case 2
        % Whent the first two and last two is background. 
        SMean = cast((mean(mean(stack(:,:,1))) + mean(mean(stack(:,:,2)))+mean(mean(stack(:,:,Sz-1))) + mean(mean(stack(:,:,Sz))))/4, 'uint32');
        dze = 2;
        dzb = 2;
    otherwise
        % Default option.
        SMean = cast((mean(mean(stack(:,:,1))) + mean(mean(stack(:,:,2)))+mean(mean(stack(:,:,Sz-1))) + mean(mean(stack(:,:,Sz))))/4, 'uint32');
        dze = 2;
        dzb = 2;
end

% Dummy - Riemann
% Can be reused in the future for gaussian fit check.
% TODO>>implement the gaussian way.
for Si = (1+dzb):(Sz-dze)
    smeany = Sx*Sy*SMean;
    stacky = double(stack(:,:,Si)) .* double(lgc);
    sumy = sum(stacky);
    summy = sum(sumy);
    I(Si-dzb) = summy - smeany;
end
