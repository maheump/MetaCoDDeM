Loops = 10;
Fit_quality = zeros(1, Loops);
for Loop = 1:Loops
    MxM_test_OptimDesign;
    Fit_quality(:,Loop) = transpose(Error);
end