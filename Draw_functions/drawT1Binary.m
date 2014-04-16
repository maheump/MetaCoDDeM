function display = drawT1Binary(display, phasis, gains_P1, gains_P2, gains_P3)

% Display instructions
drawText_MxM(display, [0, (display.scale/(4/3))], 'Veuillez indiquer la direction du mouvement', [255, 255, 255], (display.scale*4));
drawText_MxM(display, [0, -(display.scale/(4/3))], '(Appuyer sur ESPACE pour valider votre choix)', [255, 255, 255], (display.scale*2));

% Display gain matrix
if (phasis == 1)
    drawText_MxM(display, [0, -(display.scale/(25/8))], strcat('(', num2str(gains_P1(1, 1)), ')'), [255, 0, 0], (display.scale*2));
    drawText_MxM(display, [0, -(display.scale/(100/37))], strcat('(+', num2str(gains_P1(1, 2)), ')'), [0, 255, 0], (display.scale*2));
elseif (phasis == 2)
    drawText_MxM(display, [0, -(display.scale/(25/8))], strcat('(', num2str(gains_P2(1, 1)), ')'), [255, 0, 0], (display.scale*2));
    drawText_MxM(display, [0, -(display.scale/(100/37))], strcat('(+', num2str(gains_P2(1, 2)), ')'), [0, 255, 0], (display.scale*2));
elseif (phasis == 3)
    drawText_MxM(display, [0, -(display.scale/(25/8))], strcat('(', num2str(gains_P3(display.control, 1)), ')'), [255, 0, 0], (display.scale*2));
    drawText_MxM(display, [0, -(display.scale/(100/37))], strcat('(+', num2str(gains_P3(display.control, 2)), ')'), [0, 255, 0], (display.scale*2));
end

% Draw 2AFC answers
for i = -1:2:1
    lax = display.center(1) - angle2pix(display, i*(display.scale/5));
    lay = display.center(2);
    lbx = display.center(1) - angle2pix(display, i*(2*display.scale/5));
    lby = display.center(2);
    Screen('DrawLine', display.windowPtr, [255, 255, 255], lax, lay, lbx, lby, [display.tick]);
    sz_triangle = angle2pix(display, (display.scale/20));
    tax = lbx;
    tay = lby - (sz_triangle/2);
    tbx = lbx;
    tby = lby + (sz_triangle/2);
    tcx = lbx + (-i)*(sz_triangle/2);
    tcy = lby;
    Screen('FillPoly', display.windowPtr, [255, 255, 255], [tax, tay; tbx, tby; tcx, tcy]);
end

% Draw choice rectangle
sz_rect = angle2pix(display, (display.scale/1.5));
if (display.index == 1)
    x = display.center(1) - angle2pix(display, (display.scale/3.25));
    y = display.center(2);
    rect_coordinates = [x - (sz_rect/5), y - (sz_rect/12), x + (sz_rect/5), y + (sz_rect/12)];
    Screen('FrameRect', display.windowPtr, [255, 0, 0], rect_coordinates);
elseif (display.index == 2)
    x = display.center(1) + angle2pix(display, (display.scale/3.25));
    y = display.center(2);
    rect_coordinates = [x - (sz_rect/5), y - (sz_rect/12), x + (sz_rect/5), y + (sz_rect/12)];
    Screen('FrameRect', display.windowPtr, [255, 0, 0], rect_coordinates);
end

% Flip it
Screen('Flip',display.windowPtr);

end