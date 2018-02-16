%% ===== Figure environment =====
h = figure('Position', get(0,"screensize")([3,4,3,4]).*[0.5 0.7 0.5 0.4]);
    % set (0, "paperunits", "centimeters", "papersize", [21 29.7])
    set (h, "papertype", "a4", "paperorientation", "landscape", "paperpositionmode", "auto")
    set (h, "paperunits", "centimeters", "papersize", [29.7 21])
    set (h, "defaultlinelinewidth", 2);
    set (h, "defaultaxesfontname", "Helvetica")
    set (h, "defaultaxesfontsize", 12)
    set (h, "defaulttextfontname", "Helvetica")
    set (h, "defaulttextfontsize", 12) 