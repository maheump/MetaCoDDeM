function   display = drawT3Info(display, choice, gains)

% Display instructions
drawText_MxM(display, [0, (display.scale - display.scale/4)], 'Veuillez indiquer si vous voulez disposer de nouvelles informations', [255, 255, 255], (display.scale*4));
drawText_MxM(display, [0, (display.scale - display.scale/4)*-1], '(Appuyer sur ESPACE pour valider votre choix)', [255, 255, 255], (display.scale*2));

% Display proactive information seeking levels
drawText_MxM(display, [0, (display.scale - display.scale/1.25)], 'Répondre maintenant', [255, 255, 255], (display.scale*3));
drawText_MxM(display, [0, -(display.scale - display.scale/1.11111)], 'Revoir les points avec une augmentation du niveau de facilité de ...', [255, 255, 255], (display.scale*3));
drawText_MxM(display, [-(display.scale - display.scale/2.5), -(display.scale - display.scale/1.25)], '+0%', [255, 255, 255], (display.scale*3));
drawText_MxM(display, [-(display.scale - display.scale/1.25), -(display.scale - display.scale/1.25)], '+5%', [255, 255, 255], (display.scale*3));
drawText_MxM(display, [(display.scale - display.scale/1.25), -(display.scale - display.scale/1.25)], '+10%', [255, 255, 255], (display.scale*3));
drawText_MxM(display, [(display.scale - display.scale/2.5), -(display.scale - display.scale/1.25)], '+15%', [255, 255, 255], (display.scale*3));

% Display gain matrix
drawText_MxM(display, [0, (display.scale - display.scale/1.25) - 1], strcat('(', num2str(gains(1,1)), ')'), [255, 0, 0], (display.scale*2));
drawText_MxM(display, [0, (display.scale - display.scale/1.25) - 1.5], strcat('(+', num2str(gains(1,2)), ')'), [0, 255, 0], (display.scale*2));
drawText_MxM(display, [-(display.scale - display.scale/2.5), -(display.scale - display.scale/1.25) - 1], strcat('(', num2str(gains(2,1)), ')'), [255, 0, 0], (display.scale*2));
drawText_MxM(display, [-(display.scale - display.scale/2.5), -(display.scale - display.scale/1.25) - 1.5], strcat('(+', num2str(gains(2,2)), ')'), [0, 255, 0], (display.scale*2));
drawText_MxM(display, [-(display.scale - display.scale/1.25), -(display.scale - display.scale/1.25) - 1], strcat('(', num2str(gains(3,1)), ')'), [255, 0, 0], (display.scale*2));
drawText_MxM(display, [-(display.scale - display.scale/1.25), -(display.scale - display.scale/1.25) - 1.5], strcat('(+', num2str(gains(3,2)), ')'), [0, 255, 0], (display.scale*2));
drawText_MxM(display, [(display.scale - display.scale/1.25), -(display.scale - display.scale/1.25) - 1], strcat('(', num2str(gains(4,1)), ')'), [255, 0, 0], (display.scale*2));
drawText_MxM(display, [(display.scale - display.scale/1.25), -(display.scale - display.scale/1.25) - 1.5], strcat('(+', num2str(gains(4,2)), ')'), [0, 255, 0], (display.scale*2));
drawText_MxM(display, [(display.scale - display.scale/2.5), -(display.scale - display.scale/1.25) - 1], strcat('(', num2str(gains(5,1)), ')'), [255, 0, 0], (display.scale*2));
drawText_MxM(display, [(display.scale - display.scale/2.5), -(display.scale - display.scale/1.25) - 1.5], strcat('(+', num2str(gains(5,2)), ')'), [0, 255, 0], (display.scale*2));

% Draw choice rectangle
sz_rect = angle2pix(display, (display.scale/1.5));
if choice == 1
    x = display.center(1);
    y = display.center(2) - angle2pix(display, display.scale - (display.scale/1.25));
elseif choice == 2
    x = display.center(1) - angle2pix(display, display.scale - (display.scale/2.5));
    y = display.center(2) + angle2pix(display, display.scale - (display.scale/1.25));
elseif choice == 3
    x = display.center(1) - angle2pix(display, display.scale - (display.scale/1.25));
    y = display.center(2) + angle2pix(display, display.scale - (display.scale/1.25));
elseif choice == 4
    x = display.center(1) + angle2pix(display, display.scale - (display.scale/1.25));
    y = display.center(2) + angle2pix(display, display.scale - (display.scale/1.25));
elseif choice == 5
    x = display.center(1) + angle2pix(display, display.scale - (display.scale/2.5));
    y = display.center(2) + angle2pix(display, display.scale - (display.scale/1.25));
end
if choice == 1
    rect_coordinates = [x - (sz_rect/2), y - (sz_rect/12), x + (sz_rect/2), y + (sz_rect/12)];
elseif choice == 2 || 3 || 4 || 5
    rect_coordinates = [x - (sz_rect/5), y - (sz_rect/12), x + (sz_rect/5), y + (sz_rect/12)];
end
Screen('FrameRect', display.windowPtr, [255, 0, 0], rect_coordinates);

% Flip the all
Screen('Flip',display.windowPtr);