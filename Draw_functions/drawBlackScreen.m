function display = drawBlackScreen(display, time)

% Black screen during "time" milisecond(s)
Screen('FillOval', display.windowPtr, display.bkColor);
Screen('Flip', display.windowPtr);
waitTill(time);

end

