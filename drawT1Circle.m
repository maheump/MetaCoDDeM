function   display = drawT1Circle(display)

% Calculate sizes in screen-coordinates
sz_circle = angle2pix(display, display.T1.circle.size);
sz_line = angle2pix(display, display.T1.line.size);
sz_triangle = angle2pix(display, (display.T1.triangle.size/100));

% Calculate the circle coordinates
circ_coordinates = [display.center(1) - (sz_circle/2), display.center(2) - (sz_circle/2), display.center(1) + (sz_circle/2), display.center(2) + (sz_circle/2)];

% Calculate the line coordinates
lxa = (display.center(1) - (sz_line/2) * cos(degtorad(display.T1.line.angle)));
lya = (display.center(2) + (sz_line/2) * sin(degtorad(display.T1.line.angle)));
lxb = (display.center(1) + (sz_line/2) * cos(degtorad(display.T1.line.angle)));
lyb = (display.center(2) - (sz_line/2) * sin(degtorad(display.T1.line.angle)));

% Calculate the triangle coordinates
txa = lxb;
tya = lyb;
txb = (display.center(1) + ((sz_line - (sz_line*(sz_triangle/50)))/2) * cos(degtorad(display.T1.line.angle + sz_triangle)));
tyb = (display.center(2) - ((sz_line - (sz_line*(sz_triangle/50)))/2) * sin(degtorad(display.T1.line.angle + sz_triangle)));%en fonction aire cercle
txc = (display.center(1) + ((sz_line - (sz_line*(sz_triangle/50)))/2) * cos(degtorad(display.T1.line.angle - sz_triangle)));
tyc = (display.center(2) - ((sz_line - (sz_line*(sz_triangle/50)))/2) * sin(degtorad(display.T1.line.angle - sz_triangle)));

% Display instructions
drawText(display, [0, (display.T1.circle.size - display.T1.circle.size/4)], 'Veuillez indiquer la direction du mouvement', [255 255 255], 40);
drawText(display, [0, (display.T1.circle.size - display.T1.circle.size/4)*-1], '(Appuyer sur ESPACE pour valider votre choix)', [255 255 255], 20);

% Draw marks
mark_size = 2*(sz_circle/100);
Screen('DrawLine', display.windowPtr, display.T1.circle.color, (display.center(1) - sz_circle/2 - sz_circle/10), display.center(2), (display.center(1) - sz_circle/2 - sz_circle/10 - mark_size), display.center(2), [display.T1.tick]);
Screen('DrawLine', display.windowPtr, display.T1.circle.color, (display.center(1) + sz_circle/2 + sz_circle/10), display.center(2), (display.center(1) + sz_circle/2 + sz_circle/10 + mark_size), display.center(2), [display.T1.tick]);
Screen('DrawLine', display.windowPtr, display.T1.circle.color, display.center(1), (display.center(2) - sz_circle/2 - sz_circle/10), display.center(1), (display.center(2) - sz_circle/2 - sz_circle/10 - mark_size), [display.T1.tick]);
Screen('DrawLine', display.windowPtr, display.T1.circle.color, display.center(1), (display.center(2) + sz_circle/2 + sz_circle/10), display.center(1), (display.center(2) + sz_circle/2 + sz_circle/10 + mark_size), [display.T1.tick]);

% Draw the entire form
Screen('FrameArc', display.windowPtr, display.T1.circle.color, circ_coordinates, 0, 360, [display.T1.tick], [display.T1.tick]);
Screen('DrawLine', display.windowPtr, display.T1.line.color, lxa, lya, lxb, lyb, [display.T1.tick]);
Screen('FillPoly', display.windowPtr, display.T1.triangle.color, [txa, tya; txb, tyb; txc, tyc]);

% Flip it
Screen('Flip',display.windowPtr);