stock = [];
for i = 1:1%3
    z = 1;
    %Fit_quality = Shuffle(Fit_quality);
    b = [];
    zoom = [];
    for beta = 3:3:300 %100
        b = [Fit_quality(beta-2,1) Fit_quality(beta-1,1) Fit_quality(beta-2,1)];
        zoom(z) = median(b);
        z = z + 1;
    end
    close all
    hist(zoom);
    stock(i) = mean(zoom);
end