 function   display = drawT1Binary(display)

% Display instructions
drawText_MxM(display, [0, (display.scale - display.scale/4)], 'Veuillez indiquer la direction du mouvement', [255, 255, 255], display.scale*4);
drawText_MxM(display, [0, (display.scale - display.scale/4)*-1], '(Appuyer sur ESPACE pour valider votre choix)', [255, 255, 255], display.scale*2);

% Draw 2AFC answers
for i = -1:2:1
    lxa = display.center(1) - angle2pix(display, i*(display.scale/5));
    lxb = display.center(1) - angle2pix(display, i*(2*display.scale/5));
    lya = display.center(2);
    lyb = display.center(2);
    Screen('DrawLine', display.windowPtr, display.T1.line.color, lxa, lya, lxb, lyb, [display.T1.tick]);
    sz_triangle = angle2pix(display, (display.T1.triangle.size/20));
    txa = lxb;
    tya = lyb - (sz_triangle/2);
    txb = lxb;
    tyb = lyb + (sz_triangle/2);
    txc = lxb + (-i)*(sz_triangle/2);
    tyc = lyb;
    Screen('FillPoly', display.windowPtr, display.T1.triangle.color, [txa, tya; txb, tyb; txc, tyc]);
end

% Draw choice rectangle
sz_rect = angle2pix(display, (display.scale/1.5));
if display.T1.line.index == 1
    x = display.center(1) - angle2pix(display, display.scale - (display.scale/1.45));
    y = display.center(2);
    rect_coordinates = [x - (sz_rect/5), y - (sz_rect/12), x + (sz_rect/5), y + (sz_rect/12)];
    Screen('FrameRect', display.windowPtr, [255, 0, 0], rect_coordinates);
elseif display.T1.line.index == 2
    x = display.center(1) + angle2pix(display, display.scale - (display.scale/1.45));
    y = display.center(2);
    rect_coordinates = [x - (sz_rect/5), y - (sz_rect/12), x + (sz_rect/5), y + (sz_rect/12)];
    Screen('FrameRect', display.windowPtr, [255, 0, 0], rect_coordinates);
end

% Flip it
Screen('Flip',display.windowPtr);

end