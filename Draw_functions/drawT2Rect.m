function display = drawT2Rect(display, gains)

% Display instructions
drawText_MxM(display, [0, (display.scale/(4/3))], 'Veuillez donner votre niveau de confiance dans votre réponse', [255 255 255], (display.scale*4));
drawText_MxM(display, [0, -(display.scale/(4/3))], '(Appuyez sur ESPACE pour valider votre choix)', [255 255 255], (display.scale*2));

% Display gain matrix
drawText_MxM(display, [0, -(display.scale/(25/8))], strcat('(', num2str(gains(1,1)), ')'), [255, 0, 0], (display.scale*2));
drawText_MxM(display, [0, -(display.scale/(100/37))], strcat('(+', num2str(gains(1,2)), ')'), [0, 255, 0], (display.scale*2));

% Calculate circle size in screen-coordinates
sz_rect1 = angle2pix(display, display.scale);
sz_rect2 = angle2pix(display, display.rect);

% Calculate the rectangles coordinates
rect1_coordinates = [display.center(1) - (sz_rect1/2), display.center(2) - (sz_rect1/10), display.center(1) + (sz_rect1/2), display.center(2) + (sz_rect1/10)];
rect2_coordinates = [display.center(1) - (sz_rect1/2), display.center(2) - (sz_rect1/10), display.center(1) + (sz_rect2/2), display.center(2) + (sz_rect1/10)];

% Draw the rectangle
Screen('FillRect', display.windowPtr, [255, 0, 0], rect2_coordinates, 5);
Screen('FrameRect', display.windowPtr, [255, 255, 255], rect1_coordinates);

% Flip it
Screen('Flip',display.windowPtr);

end