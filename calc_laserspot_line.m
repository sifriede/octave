%% Latest change = 18-02-08
pkg load optim; % needed for leasqr
pkg load signal; % needed for fwhm
clear all; close all;
%% ===== Load Picture =====
img = uigetfile("" ,"Choose a picture");

%%===== Define pixel - mm ratio =====
pixel2mm = 4.8/1280; %same as 3.6/960=0.00375


%%%%%%%%%%%%%%%%%%%%%%%
%%===== Define gaussian fit function =====
function [retval] = gaussianfit (x, par)
	retval = par(3) / (par(1)*sqrt(2*pi)) * exp(-1/2*((x-par(2))/par(1)).^2) + par(4);
endfunction

%%===== Plot Image and draw horizontal and vertical line =====
imginfo = imfinfo(img);
imgratio = imginfo.Height/imginfo.Width;
imgdata = imread(img); %Rows(y) x Columns(x)
ch = 1; %channel of image (r,g,g,b)

%% ===== Figure environment =====
%h = figure('Position', get(0,"screensize")([3,4,3,4]).*[0.5 0.7 0.5 0.5]);
figurepossize = get(0,"screensize")([3,4,3,3]).*[0.5 0.3 0.5 0.5*imgratio];
h = figure('Position', figurepossize);
    set (h, "papertype", "a4", "paperorientation", "landscape", "paperpositionmode", "auto")
    set (h, "paperunits", "centimeters", "papersize", [29.7 21])
    set (h, "defaultlinelinewidth", 2);
    set (h, "defaultaxesfontname", "Arial")
    set (h, "defaultaxesfontsize", 12)
    set (h, "defaulttextfontname", "Arial")
    set (h, "defaulttextfontsize", 12) 
    set (h, 'MenuBar', 'none')
    set (findobj (gcf, "-property", "fontsize"), "fontsize", 20)
    %set([gca; findall(gca, 'Type','text')], 'FontSize', 12);
    % set(h, 'FontSize', 12);
     set (gca, "yaxislocation", "right");


%%===== IMAGE PLOT =====
subplot(3,3,[2 3 5 6],"align")
    image(imgdata);
    xlabel "x in pixel"; ylabel "y in pixel";
    grid minor on;
    title (img, 'Interpreter', 'none');
    hold on;
    
%%===== Choice of Distribution =====
disp('Input required:')
    msgbox('Click once on image to select the center...');
    [x1,y1]=ginput(1);
    chx = round(x1); chy = round(y1);
    [ymax, xmax, ~] = size(imgdata);
    vec_x = [1:xmax]; vec_y = [1:ymax];
    plot([chx chx], [1 ymax], 'color', 'white', 'linewidth', 2, ...   %vertical line
           [1 xmax], [chy chy], 'color', 'white', 'linewidth', 2)      %horizontal line

%%============ X ===============================================
%%===== x distribution =====
int_x = double(imgdata(chx, :, ch));
int_x_n = int_x/sum(int_x);
xcolor = 'blue';
xfitcolor = [0.9, 0.5, 0];
subplot(3,3,8:9)
    plot(vec_x*pixel2mm, int_x_n*100, 'color', xcolor);
    legend('Horizontal line'); xlabel "x in mm"; ylabel "I/I_0 in %";
    axis([1,xmax]*pixel2mm)
    grid on; hold on;

%%==== Start fit parameter estimation =====
mean_x = mean(vec_x(int_x_n == max(int_x_n)));
    sigma_x = mean_x - min(vec_x(find( max(int_x_n)*0.6 <= int_x_n & int_x_n <= max(int_x_n)*0.75)));
    amp_x = 1; %max(int_x_n);
    offset_x = min(int_x_n);
disp('Defining x start fit parameter...')
    pin_x = [sigma_x, mean_x, amp_x, offset_x]

%%===== Fit x distribution ====
cvg_x = 0;
pin_x_fit = pin_x;
%while (cvg_x != 1)
    [f_x, p_x, cvg_x, iter_x, corp_x, covp_x, covr_x, stdresid_x, Z_x, r2_x] = leasqr(vec_x, int_x_n, pin_x_fit, "gaussianfit");
   % pin_x_fit = p_x;
%endwhile
fwhm_x = fwhm(vec_x, f_x);
disp('Result x fit parameter...')
disp(p_x')
save([img(1:end-4) "_fit_x.dat"], "pixel2mm", "vec_x", "int_x_n", "f_x", "p_x", "cvg_x", "iter_x", "corp_x", "covp_x", "covr_x", "stdresid_x", "Z_x", "r2_x");
plot(vec_x*pixel2mm, f_x*100, ';x fit;', 'color', xfitcolor);

%% ===== Show x results in subplot =====
subplot(3,3,7)
    htext = text(0,0, sprintf( ...
    " x - Fit \n sigma_x = (%.2f +/- %.2f) mm\n fwhm_x  =  %.2f mm \n converged? = %d", ...
    p_x(1)*pixel2mm, covp_x(1,1)*pixel2mm, fwhm_x*pixel2mm, cvg_x));
    set(htext, 'verticalalignment', 'bottom', 'interpreter', 'none', 'clipping', 'off');
    set(htext, 'Position', [-0.5, 0], 'color', xcolor);
    axis off;


%%============================================================
%%============================================================
%%============ Y ===============================================
%%===== y distribution =====
int_y = double(imgdata(:, chy , ch));
int_y_n = int_y/sum(int_y);
ycolor = 'red';
yfitcolor = [0, 0.5, 0.9];
subplot(3,3,[1 4])
    plot(int_y_n*100, vec_y*pixel2mm, 'color', ycolor);
    legend('Vertical line','location','northeast'); ylabel "y in mm"; xlabel "I/I_0 in %";
    axis([0,Inf,0,ymax]*pixel2mm, "autox")
    set(gca(), 'ydir', 'reverse')
    grid on; hold on;

%%==== Start fit parameter estimation =====
mean_y = mean(vec_y(int_y_n == max(int_y_n)));
    sigma_y = mean_y - min(vec_y(find( max(int_y_n)*0.68 <= int_y_n & int_y_n <= max(int_y_n)*0.70)));
    amp_y = 1;
    offset_y = min(int_y_n);
disp('Defining y start fit parameter...')
    pin_y = [sigma_y, mean_y, amp_y, offset_y]

%%===== Fit y distribution ====
[f_y, p_y, cvg_y, iter_y, corp_y, covp_y, covr_y, stdresid_y, Z_y, r2_y] = leasqr(vec_y, int_y_n', pin_y, "gaussianfit");
fwhm_y = fwhm(vec_y*pixel2mm, f_y);
disp('Result y fit parameter...')
disp(p_y')
save([img(1:end-4) "_fit_y.dat"], "pixel2mm", "vec_y", "int_y_n", "f_y", "p_y", "cvg_y", "iter_y", "corp_y", "covp_y", "covr_y", "stdresid_y", "Z_y", "r2_y");
plot(f_y*100, vec_y*pixel2mm, ';y fit;', 'color', yfitcolor);

%% ===== Show y results in subplot =====
subplot(3,3,7)
    hteyt = text(0,0, sprintf( ...
    " y - Fit \n sigma_y = (%.2f +/- %.2f) mm\n fwhm_y  =  %.2f mm \n converged? = %d", ...
    p_y(1)*pixel2mm, covp_y(1,1)*pixel2mm, fwhm_y*pixel2mm, cvg_y));
    set(hteyt, 'verticalalignment', 'bottom', 'interpreter', 'none', 'clipping', 'off');
    set(hteyt, 'Position', [-0.5, .6], 'color', ycolor);