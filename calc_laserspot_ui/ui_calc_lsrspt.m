%% Latest change = 18-02-15
clear all; close all;
pkg load optim; % needed for leasqr
pkg load signal; % needed for fwhm

global img pixel2mm vec_x vec_y int_x_n int_y_n;
pixel2mm = 4.8/1280; %same as 3.6/960=0.00375
global f_x p_x cvg_x iter_x corp_x covp_x covr_x stdresid_x Z_x r2_x;
global f_y p_y cvg_y iter_y corp_y covp_y covr_y stdresid_y Z_y r2_y;

graphics_toolkit qt

## Gaussian
function [retval] = gaussianfit (x, par)
	retval = par(3) / (par(1)*sqrt(2*pi)) * exp(-1/2*((x-par(2))/par(1)).^2) + par(4);
endfunction

figurepossize = get(0,"screensize")([3,4,4,4]).*[0.5 0.5 0.625 0.625*3/4];
h.figure = figure('Position', figurepossize);
    set (h.figure, "papertype", "a4", "paperorientation", "landscape", "paperpositionmode", "auto")
    ##set (h.figure, "paperunits", "centimeters", "papersize", [29.7 21])
    set (h.figure, "defaultlinelinewidth", 2);
    set (h.figure, "defaultaxesfontname", "Arial")
    set (h.figure, "defaultaxesfontsize", 12)
    set (h.figure, "defaulttextfontname", "Arial")
    set (h.figure, "defaulttextfontsize", 12) 
    set (h.figure, 'MenuBar', 'none')
    set (findobj (gcf, "-property", "fontsize"), "fontsize", 20)


function mysave (obj)
    global img pixel2mm vec_x vec_y int_x_n int_y_n;
    global f_x p_x cvg_x iter_x corp_x covp_x covr_x stdresid_x Z_x r2_x;
    global f_y p_y cvg_y iter_y corp_y covp_y covr_y stdresid_y Z_y r2_y;
    h = guidata (obj);
    
    disp("Saving...")
    questbtn = questdlg ("Do you want to save the results?", "Save Dialog", "No", "Yes", "No");
    if (strcmp (questbtn, "Yes"))
        save_path = uigetdir(".","Choose saving path...");
        if (strcmp(img(end-4:end),'.tiff'))
            save_str = [save_path '\' img(1:end-5)];
        else 
            save_str = [save_path '\' img(1:end-4)];
        endif
        disp(['Saving results to ' save_str])
        print([save_str "_result.pdf"], "-dpdf");
        save([save_str "_fit_x.dat"], "pixel2mm", "vec_x", "int_x_n", "f_x", "p_x", "cvg_x", "iter_x", "corp_x", "covp_x", "covr_x", "stdresid_x", "Z_x", "r2_x");
        save([save_str "_fit_y.dat"], "pixel2mm", "vec_y", "int_y_n", "f_y", "p_y", "cvg_y", "iter_y", "corp_y", "covp_y", "covr_y", "stdresid_y", "Z_y", "r2_y");
        disp('... done.')
    else 
        disp('Saving aborted.');
    endif
endfunction

function update_plot (obj, init = false)
    ## Image specification
    ch = 1; %channel of image (r,g,g,b)
    global img pixel2mm vec_x vec_y int_x_n int_y_n;
    global f_x p_x cvg_x iter_x corp_x covp_x covr_x stdresid_x Z_x r2_x;
    global f_y p_y cvg_y iter_y corp_y covp_y covr_y stdresid_y Z_y r2_y;
    
    
    
    ## gcbo holds the handle of the control
    h = guidata (obj);
    choose = false;
    recalc = false;

    switch (gcbo)
        case {h.choose_pushbutton}
            disp('Choose_pushbutton pressed')
            choose = true;
        case {h.recalc_pushbutton}
            disp('Recalc_pushbutton pressed')
            recalc = true;
        case {h.close_pushbutton}
            disp('Close_pushbutton pressed')
            close(); clear all;
            return;
        case {h.pixel2mm_default}
            pixel2mm = 4.8/1280;
            recalc = true;
        case {h.pixel2mm_pi}
            #set(h.pixel2mm_default, "value", 0)
            #pixel2mm = str2num(get (gcbo, "string"));
            pixel2mm = 3.76/2592;
            recalc = true;
    endswitch

    
    if (init || choose || recalc)
        if (init) 
            disp('Initializing...'); 
        endif
        if (choose || recalc)
            clf(h.figure);
        endif
        if (choose) disp('Choose a new image...'); endif
        if (recalc) disp('Choose new center...'); endif
        

        if (init || choose)
        img = uigetfile("" ,"Choose a picture");
        sprintf("%s chosen",img)
        endif
        
        imginfo = imfinfo(img);
        imgdata = imread(img); %Rows(y) x Columns(x)
        
        h.subplot1 = subplot(3, 3, [2 3 5 6], "align");
            h.image = image(imgdata);
            % h.image = imshow(img);
            h.title = title (img, 'Interpreter', 'none');
            grid on; hold on;
        %%===== Choice of Distribution =====
        disp('Input required:')
        ##msgbox('Click once on image to select the center...', 'Choose a center');
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
        h.subplot2 = subplot(3,3,8:9);
            plot(vec_x*pixel2mm, int_x_n*100, 'color', xcolor);
            legend('Horizontal line'); xlabel "x in mm"; ylabel "I/I_0 in %";
            axis([1,xmax]*pixel2mm)
            grid on; hold on;
        
        %%==== X: Start fit parameter estimation =====
        mean_x = mean(vec_x(int_x_n == max(int_x_n)));
            sigma_x = mean_x - min(vec_x(find( max(int_x_n)*0.6 <= int_x_n & int_x_n <= max(int_x_n)*0.75)));
            amp_x = 1; %max(int_x_n);
            offset_x = min(int_x_n);
        disp('Defining x start fit parameter...')
            pin_x = [sigma_x, mean_x, amp_x, offset_x]
        
        %%===== X: Fit distribution ====
        [f_x, p_x, cvg_x, iter_x, corp_x, covp_x, covr_x, stdresid_x, Z_x, r2_x] = leasqr(vec_x, int_x_n, pin_x, "gaussianfit");
        fwhm_x = fwhm(vec_x, f_x);
        disp('Result x fit parameter...')
            disp(p_x')
        
        plot(vec_x*pixel2mm, f_x*100, ';x fit;', 'color', xfitcolor);
        
        %% ===== X: Show results in subplot =====
        h.subplot4 = subplot(3,3,7);
            h.textx = text(0,0, sprintf( ...
            " x - Fit \n sigma_x = (%.2f +/- %.2f) mm\n fwhm_x  =  %.2f mm \n converged? = %d", ...
            p_x(1)*pixel2mm, covp_x(1,1)*pixel2mm, fwhm_x*pixel2mm, cvg_x));
            set(h.textx, 'verticalalignment', 'bottom', 'interpreter', 'none', 'clipping', 'off');
            set(h.textx, 'Position', [-0.5, 0.1], 'color', xcolor);
            axis off;
        
        
        %%============================================================
        %%============================================================
        %%============ Y ===============================================
        %%===== Y: Distribution =====
        int_y = double(imgdata(:, chy , ch));
        int_y_n = int_y/sum(int_y);
        ycolor = 'red';
        yfitcolor = [0, 0.5, 0.9];
        h.subplot3 = subplot(3,3,[1 4]);
            plot(int_y_n*100, vec_y*pixel2mm, 'color', ycolor);
            legend('Vertical line','location','northeast'); ylabel "y in mm"; xlabel "I/I_0 in %";
            axis([0,Inf,0,ymax]*pixel2mm, "autox");
            set(gca(), 'ydir', 'reverse');
            grid on; hold on;
        
        %%==== Y: Start fit parameter estimation =====
        mean_y = mean(vec_y(int_y_n == max(int_y_n)));
            sigma_y = mean_y - min(vec_y(find( max(int_y_n)*0.68 <= int_y_n & int_y_n <= max(int_y_n)*0.70)));
            amp_y = 1;
            offset_y = min(int_y_n);
        disp('Defining y start fit parameter...')
            pin_y = [sigma_y, mean_y, amp_y, offset_y]
        
        %%===== Y: Fit distribution ====
        [f_y, p_y, cvg_y, iter_y, corp_y, covp_y, covr_y, stdresid_y, Z_y, r2_y] = leasqr(vec_y, int_y_n', pin_y, "gaussianfit");
        fwhm_y = fwhm(vec_y, f_y);
        disp('Result y fit parameter...')
            disp(p_y')
        plot(f_y*100, vec_y*pixel2mm, ';y fit;', 'color', yfitcolor);
        
        %% ===== Y: Show results in subplot =====
         h.subplot4 = subplot(3,3,7);
            h.texty = text(0,0, sprintf( ...
            " y - Fit \n sigma_y = (%.2f +/- %.2f) mm\n fwhm_y  =  %.2f mm \n converged? = %d", ...
            p_y(1)*pixel2mm, covp_y(1,1)*pixel2mm, fwhm_y*pixel2mm, cvg_y));
            set(h.texty, 'verticalalignment', 'bottom', 'interpreter', 'none', 'clipping', 'off');
            set(h.texty, 'Position', [-0.5, .6], 'color', ycolor);

        guidata (obj, h);
    endif

endfunction

## Button Layout calculation
n_btn = 4; 
n0 = 0.01; n=1; btn_h = 0.04; btn_w = (1-(n_btn+1)*n0)/n_btn;
d = @(m) m*n0+(m-1)*btn_w;

## Choose new image
h.choose_pushbutton = uicontrol ("style", "pushbutton",
                                "handlevisibility", "off",
                                "units", "normalized", 
                                "string", "Choose new image",
                                "callback", @update_plot,
                                "position", [d(n) 0 btn_w btn_h]);
n+=1;
## Recalc current image
h.recalc_pushbutton = uicontrol ("style", "pushbutton",
                                "handlevisibility", "off",
                                "units", "normalized", 
                                "string", "Recalc",
                                "handlevisibility", "off",
                                "callback", @update_plot,
                                "position", [d(n) 0 btn_w btn_h]);
n+=1;
## save figure and results
h.save_pushbutton = uicontrol ("style", "pushbutton",
                                "handlevisibility", "off",
                                "units", "normalized", 
                                "string", "Save results",
                                "handlevisibility", "off",
                                "callback", @mysave,
                                "position", [d(n) 0 btn_w btn_h]);
n+=1;
## close button
h.close_pushbutton = uicontrol ("style", "pushbutton",
                                "handlevisibility", "off",
                                "units", "normalized", 
                                "string", "Close",
                                "handlevisibility", "off",
                                "callback", @update_plot,
                                "position", [d(n) 0 btn_w btn_h]);




## Pixel2mm
#h.pixel2mm_label = uicontrol ("style", "text",
#                               "units", "normalized",
#                               "string", "Pixel to mm:",
#                               "handlevisibility", "off",
#                               "horizontalalignment", "left",
#                               "position", [0.17 0.1 0.18 0.02]);

h.pixel2mm_default = uicontrol ("style", "pushbutton",
                                "units", "normalized",
                                "string", "(default) \n  4.8 mm / 1280 px",
                                "handlevisibility", "off",
                                "callback", @update_plot,
                                "value", 1,
                                "position", [0.01 0.06 0.16 0.06]);
                                
h.pixel2mm_pi = uicontrol ("style", "pushbutton",
                                "units", "normalized",
                                "string", "Pi sensor \n  3.8 mm / 2592 px",
                                "handlevisibility", "off",
                                "callback", @update_plot,
                                "value", 0,
                                "position", [0.17 0.06 0.16 0.06]);
                               
%h.pixel2mm_edit = uicontrol ("style", "edit",
%                             "units", "normalized",
%                             "string", num2str(pixel2mm),
%                             "handlevisibility", "off",
%                             "callback", @update_plot,
%                             "position", [0.17 0.06 0.15 0.03]);
                             
set (gcf, "color", get(0, "defaultuicontrolbackgroundcolor"))
guidata (gcf, h)
% update_plot (gcf, true);

return;