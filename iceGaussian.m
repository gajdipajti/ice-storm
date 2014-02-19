function [I] = iceGaussian(stack)
% stack - first-2 and last-2 are considered backdround
%       - this must be from the real picture
%       - the main script does the wrapping

% Collected references:
% www.exelisvis.com/docs/GAUSS2DFIT.html
% http://jila.colorado.edu/bec/BEC_for_everyone/matlabfitting.htm
% https://uqu.edu.sa/files2/tiny_mce/plugins/filemanager/files/4282164/Gaussian%20function.pdf
% http://www.weizmann.ac.il/home/eofek/matlab/FitFun/fit_gauss2d.m
% http://www.igorexchange.com/node/1553

% Gauss 2D illesztést csinál az adatokra, és visszaad egy függvény alatti
% terület értéket.

% Get the size of the stack
[Sx,Sy,Sz] = size(stack);

% check background
% mean of a matrix is a vector
SMean = cast((mean(mean(stack(:,:,1))) + mean(mean(stack(:,:,2)))+mean(mean(stack(:,:,Sz-1))) + mean(mean(stack(:,:,Sz))))/4, 'uint32');
% case ??

% Dummy Gauss fit - Riemann
I = zeros(Sz,'uint32');
for Si = 3:(Sz-2)
    I(Si) = sum(stack(:,:,Si), 'uint32') - Sx*Sy*SMean;
end