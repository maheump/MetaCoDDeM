function   display = drawT2Rect(display)                      

% Calculate circle size in screen-coordinates
sz_rect1 = angle2pix(display, display.rect1.size);
sz_rect2 = angle2pix(display, display.rect2.size);

% Calculate the rectangles coordinates
rect1_coordinates = [display.center(1) - (sz_rect1/2), display.center(2) - (sz_rect1/8), display.center(1) + (sz_rect1/2), display.center(2) + (sz_rect1/8)];
rect2_coordinates = [display.center(1) - (sz_rect1/2), display.center(2) - (sz_rect1/8), display.center(1) + (sz_rect2/2), display.center(2) + (sz_rect1/8)];

% Draw the circle
Screen('FillRect', display.windowPtr, display.rect2.color, rect2_coordinates, [5]);
Screen('FrameRect', display.windowPtr, display.rect1.color, rect1_coordinates);

% Flip it
Screen('Flip',display.windowPtr);