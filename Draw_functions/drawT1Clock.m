function display = drawT1Clock(display, step, phasis, gains_P1, gains_P2, gains_P3)

% Display instructions
drawText_MxM(display, [0, (display.scale/(4/3))], 'Veuillez indiquer la direction du mouvement', [255, 255, 255], (display.scale*4));
drawText_MxM(display, [0, -(display.scale/(4/3))], '(Appuyez sur ESPACE pour valider votre choix)', [255, 255, 255], (display.scale*2));

% Display gain matrix
if (phasis == 1)
    drawText_MxM(display, [0, -(display.scale/(8/5))], strcat('(', num2str(gains_P1(1, 1)), ')'), [255, 0, 0], (display.scale*2));
    drawText_MxM(display, [0, -(display.scale/(40/27))], strcat('(+', num2str(gains_P1(1, 2)), ')'), [0, 255, 0], (display.scale*2));
elseif (phasis == 2)
    drawText_MxM(display, [0, -(display.scale/(8/5))], strcat('(', num2str(gains_P2(1, 1)), ')'), [255, 0, 0], (display.scale*2));
    drawText_MxM(display, [0, -(display.scale/(40/27))], strcat('(+', num2str(gains_P2(1, 2)), ')'), [0, 255, 0], (display.scale*2));
elseif (phasis == 3)
    drawText_MxM(display, [0, -(display.scale/(8/5))], strcat('(', num2str(gains_P3(display.control, 1)), ')'), [255, 0, 0], (display.scale*2));
    drawText_MxM(display, [0, -(display.scale/(40/27))], strcat('(+', num2str(gains_P3(display.control, 2)), ')'), [0, 255, 0], (display.scale*2));
end

% Calculate sizes in screen-coordinates
sz_circle = angle2pix(display, display.scale);
sz_line = angle2pix(display, display.scale);
sz_triangle = angle2pix(display, (display.scale/100));
sz_marks_a = angle2pix(display, (display.scale + (display.scale/20)));
sz_marks_b = angle2pix(display, (display.scale + (display.scale/10)));

% Calculate the circle coordinates
cxy = [display.center(1) - (sz_circle/2), display.center(2) - (sz_circle/2), display.center(1) + (sz_circle/2), display.center(2) + (sz_circle/2)];

% Calculate the line coordinates
lax = (display.center(1) - (sz_line/2) * cos(degtorad(display.line)));
lay = (display.center(2) + (sz_line/2) * sin(degtorad(display.line)));
lbx = (display.center(1) + (sz_line/2) * cos(degtorad(display.line)));
lby = (display.center(2) - (sz_line/2) * sin(degtorad(display.line)));

% Calculate the triangle coordinates
tax = lbx;
tay = lby;
tbx = (display.center(1) + ((sz_line - (sz_line*(sz_triangle/50)))/2) * cos(degtorad(display.line + sz_triangle)));
tby = (display.center(2) - ((sz_line - (sz_line*(sz_triangle/50)))/2) * sin(degtorad(display.line + sz_triangle)));
tcx = (display.center(1) + ((sz_line - (sz_line*(sz_triangle/50)))/2) * cos(degtorad(display.line - sz_triangle)));
tcy = (display.center(2) - ((sz_line - (sz_line*(sz_triangle/50)))/2) * sin(degtorad(display.line - sz_triangle)));

% Draw marks
for i = 0:step:359
    max = (display.center(1) + (sz_marks_a/2) * cos(degtorad(i)));
    may = (display.center(2) + (sz_marks_a/2) * sin(degtorad(i)));
    mbx = (display.center(1) + (sz_marks_b/2) * cos(degtorad(i)));
    mby = (display.center(2) + (sz_marks_b/2) * sin(degtorad(i)));
    Screen('DrawLine', display.windowPtr, [255, 255, 255], max, may, mbx, mby);
end

% Draw the entire form
Screen('FrameArc', display.windowPtr, [255, 255, 255], cxy, 0, 360, [display.tick], [display.tick]);
Screen('DrawLine', display.windowPtr, [255, 0, 0], lax, lay, lbx, lby, [display.tick]);
Screen('FillPoly', display.windowPtr, [255, 0, 0], [tax, tay; tbx, tby; tcx, tcy]);

% Flip it
Screen('Flip',display.windowPtr);

end