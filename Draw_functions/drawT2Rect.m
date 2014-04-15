function   display = drawT2Rect(display)

% Display instructions
drawText_MxM(display, [0, (display.T2.rect1.size - display.T2.rect1.size/4)], 'Veuillez donner votre niveau de confiance dans votre réponse', [255 255 255], display.scale*4);
drawText_MxM(display, [0, (display.T2.rect1.size - display.T2.rect1.size/4)*-1], '(Appuyer sur ESPACE pour valider votre choix)', [255 255 255], display.scale*2);

% Calculate circle size in screen-coordinates
sz_rect1 = angle2pix(display, display.T2.rect1.size);
sz_rect2 = angle2pix(display, display.T2.rect2.size);

% Calculate the rectangles coordinates
rect1_coordinates = [display.center(1) - (sz_rect1/2), display.center(2) - (sz_rect1/10), display.center(1) + (sz_rect1/2), display.center(2) + (sz_rect1/10)];
rect2_coordinates = [display.center(1) - (sz_rect1/2), display.center(2) - (sz_rect1/10), display.center(1) + (sz_rect2/2), display.center(2) + (sz_rect1/10)];

% Draw the circle
Screen('FillRect', display.windowPtr, display.T2.rect2.color, rect2_coordinates, 5);
Screen('FrameRect', display.windowPtr, display.T2.rect1.color, rect1_coordinates);

% Flip it
Screen('Flip',display.windowPtr);

end