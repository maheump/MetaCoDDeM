Loops = 100;
Fit_quality = zeros(Loops, 2);
for Loop = 1:Loops
    fprintf('Loop n°%g.\n', Loop);
    MxM_test_OptimDesign;
    Fit_quality(Loop,:) = transpose(Error);
end
clearvars -except Loop Loops Fit_quality;