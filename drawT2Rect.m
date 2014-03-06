function   display = drawT2Rect(display)                      

% Calculate circle size in screen-coordinates
sz_rect1 = angle2pix(display, display.rect1.size);
sz_rect2 = angle2pix(display, display.rect2.size);

% Calculate the rectangles coordinates
rect1_coordinates = [display.center(1) - (sz_rect1/2), display.center(2) - (sz_rect1/8), display.center(1) + (sz_rect1/2), display.center(2) + (sz_rect1/8)]
rect2_coordinates = [display.center(1) - (sz_rect1/2), display.center(2) - (sz_rect1/8), display.center(1) + (sz_rect2/2), display.center(2) + (sz_rect1/8)]

% Display instructions
drawText(display, [0, (display.rect1.size - display.rect1.size/4)], 'Veuillez donner votre confiance dans votre r�ponse', [255 255 255], 40);
drawText(display, [0, (display.rect1.size - display.rect1.size/4)*-1], '(Appuyer sur entrer pour valider votre choix)', [255 255 255], 20);

% Draw the circle
Screen('FillRect', display.windowPtr, display.rect2.color, rect2_coordinates, [5])
Screen('FrameRect', display.windowPtr, display.rect1.color, rect1_coordinates);

% Flip it
Screen('Flip',display.windowPtr);