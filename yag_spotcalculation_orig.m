# WERTE, DIE REIN GEHEN
daten = imread("2015-12-12 17.01.26 200ms ild 51.5ma.png");
################

[A,B] = size(daten);

y = sum(daten(:, 450:550), 2);


daten = [(1:length(y))', y];
save "yag_ild51.5ma.dat" daten

bla = plot (y);
set(bla, "linewidth", 2); 
set(bla, "color", "blue");
set(bla, "markersize", 9);
axis ([1, 1024]);
xlabel ("Pixel number ", "fontweight", "bold");
ylabel ("Integrated Value", "fontweight", "bold");
bla = text (205, 5500, sprintf("FWHM = %.04g  %.03f", f ));
set(bla, "fontsize", 18, "fontweight", "bold");
set(gca(), "fontsize", 18, "fontweight", "bold");
set(get(gca(), "xlabel"), "fontsize", 18);
set(get(gca(), "ylabel"), "fontsize", 18);
print ("test.pdf",'-dpdf','-FTimes-Roman:18','-color', '-landscape');