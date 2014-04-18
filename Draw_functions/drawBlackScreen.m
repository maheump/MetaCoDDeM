function display = drawBlackScreen(display)

Screen('FillOval', display.windowPtr, display.bkColor);
Screen('Flip', display.windowPtr);

end

