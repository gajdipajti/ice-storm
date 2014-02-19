function [area] = iceCenter(coord)

% Ez egy durva közelítést ad a térképen, hogy mekkora kiterjedésű az adott
% felvillanás xy-ban 3*3; 5*5; 7*7;
% Ha két pont van egymás mellett akkor azt jelzi.
% Ezekkel az értékekkel és a már korábban letárolt XYZb-Ze koordinátákkal 
% kerül a Gauss meghajtásra.

