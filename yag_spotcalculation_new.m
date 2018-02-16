%% Latest change = 18-02-08
pkg load optim; % needed for leasqr
pkg load signal; % needed for fwhm
clf; % clear old figures
%% LOAD Picture
img = "18-02-08\_lsrspt\_cathode\_01.tiff";
%% Define pixel - mm ratio 
pixel2mm = 4.8/1280; %same as 3.6/960=0.00375



%%%%%%%%%%%%%%%%%%%%%%%
%%===== Define gaussian fit function =====
function [retval] = gaussianfit (x, par)
	retval = par(3) / (par(1)*sqrt(2*pi)) * exp(-1/2*((x-par(2))/par(1)).^2) + par(4);
endfunction

%%===== Plot Image and draw horizontal and vertical line =====
imginfo = imfinfo(img);
imgdata = imread(img); %Rows(y) x Columns(x)
figure(1,'Position',[100,100,1000,800]);
set(gcf, "defaultlinelinewidth", 3)
set([gca; findall(gca, 'Type','text')], 'FontSize', 12);
set (0, "defaultaxesfontname", "Helvetica")
set (0, "defaultaxesfontsize", 12)
set (0, "defaulttextfontname", "Helvetica")
set (0, "defaulttextfontsize", 12)

%set(gca, "linewidth", 2, "fontsize", 12)

%%===== IMAGE PLOT =====
subplot(3,3,[2 3 5 6],"align")
    image(imgdata);
    grid minor on;
    title (img, 'Interpreter', 'none');
    hold on;
    
%%===== Choice Distribution =====
disp('Input required:')
disp('Draw choice frame in image...')
[x1,y1]=ginput(3);
    choice_x=round([min(x1);max(x1);max(x1);min(x1);min(x1)]);
    choice_y=round([min(y1);min(y1);max(y1);max(y1);min(y1)]);
    plot(choice_x,choice_y, 'color', 'white', 'linewidth', 2)
    
%%===== Get X Distribution =====
int_x_glbl = sum(imgdata(:,:,1),1);
int_x_glbl_norm = int_x_glbl./sum(int_x_glbl);
int_x_loc = sum(imgdata(choice_y(1):choice_y(3),choice_x(1):choice_x(2),1),1);
int_x_loc_norm = int_x_loc./sum(int_x_loc);

tmp_x_result_glbl = [[1:columns(imgdata)]' int_x_glbl_norm'];
tmp_x_result_loc = [[choice_x(1):choice_x(2)]' int_x_loc_norm'];

%%===== X Gaussian fits =====
%%===== Estimate Startparameter =====
%%==== Standard Deviation estimation =====
    std_x_glbl = std(tmp_x_result_glbl(:,1));
    std_x_loc = std(tmp_x_result_loc(:,1));
    
%%==== Mean Value estimation ====
    mean_x_glbl=tmp_x_result_glbl(:,1)(tmp_x_result_glbl(:,2)==max(tmp_x_result_glbl(:,2)));
    mean_x_loc=tmp_x_result_loc(:,1)(tmp_x_result_loc(:,2)==max(tmp_x_result_loc(:,2)));
    
%%==== Amplitude estimation ====
    ampl_x_glbl=1;
    ampl_x_loc=1;
    
%%==== Amplitude estimation ====
    offset_x_glbl=min(tmp_x_result_glbl(:,2));
    offset_x_loc=min(tmp_x_result_loc(:,2));

%%==== Start fitting ====
%% pin = [sigma, mean, amplitude, offset]
disp('Fitting global x curve...')
    pin_x_glbl = [std_x_glbl, mean_x_glbl, ampl_x_glbl , offset_x_glbl];
    [f_x_glbl, p_x_glbl, cvg_x_glbl, iter_x_glbl, corp_x_glbl, covp_x_glbl] = leasqr(tmp_x_result_glbl(:,1),tmp_x_result_glbl(:,2),pin_x_glbl,"gaussianfit");
disp('')

disp('Fitting local x curve...')
    pin_x_loc = [std_x_loc, mean_x_loc, ampl_x_loc , offset_x_loc];
    [f_x_loc, p_x_loc, cvg_x_loc, iter_x_loc, corp_x_loc, covp_x_loc] = leasqr(tmp_x_result_loc(:,1),tmp_x_result_loc(:,2),pin_x_loc,"gaussianfit");
disp('')
%p
%covp
sigma_x_glbl = p_x_glbl(2)*pixel2mm;
sigma_x_loc = p_x_loc(2)*pixel2mm;
fwhm_x_glbl = fwhm(tmp_x_result_glbl(:,1)*pixel2mm, gaussianfit(tmp_x_result_glbl(:,1),p_x_glbl));
fwhm_x_loc =  fwhm(tmp_x_result_loc(:,1)*pixel2mm, gaussianfit(tmp_x_result_loc(:,1),p_x_loc));

%%===== X Plot =====
xcolor = 'blue';
subplot(3,3,8:9)
    plot(...
        tmp_x_result_glbl(:,1)*pixel2mm, tmp_x_result_glbl(:,2),'color',xcolor, ...
        tmp_x_result_loc(:,1)*pixel2mm, tmp_x_result_loc(:,2),'color','cyan',...
        tmp_x_result_glbl(:,1)*pixel2mm, gaussianfit(tmp_x_result_glbl(:,1),p_x_glbl), 'color', [0 .5 1], ...
        tmp_x_result_loc(:,1)*pixel2mm, gaussianfit(tmp_x_result_loc(:,1),p_x_loc), 'color', [0 0.5 0.5])
    legend("global-x","local-x", ...
        sprintf("global gauss, sigma= %.2f, fwhm = %.2f, conv = %d",sigma_x_glbl, fwhm_x_glbl, cvg_x_glbl), ...
        sprintf("local gauss, sigma= %.2f, fwhm = %.2f, conv = %d",sigma_x_loc, fwhm_x_loc, cvg_x_loc))
    legend('location','south')

    axis([1,columns(imgdata)]*pixel2mm)
    xlabel ('x in mm', 'fontsize', 12);
    ylabel ('I / sum(I)', 'fontsize', 12);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%===== Get Y Distribution =====
    int_y_glbl = sum(imgdata(:,:,1),2);
    int_y_glbl_norm = int_y_glbl./sum(int_y_glbl);
    int_y_loc = sum(imgdata(choice_y(1):choice_y(3),choice_x(1):choice_x(2),1),2);
    int_y_loc_norm = int_y_loc./sum(int_y_loc);
    
    tmp_y_result_glbl = [[1:rows(imgdata)]; int_y_glbl_norm'];
    tmp_y_result_loc = [[choice_y(1):choice_y(3)]; int_y_loc_norm'];
    
%%===== Y Gaussian fits =====
%%===== Estimate Startparameter =====
%%==== Standard Deviation estimation =====
    std_y_glbl = std(tmp_y_result_glbl(1,:));
    std_y_loc = std(tmp_y_result_loc(1,:));
    
%%==== Mean Value estimation ====
    mean_y_glbl=tmp_y_result_glbl(1,:)(tmp_y_result_glbl(2,:)==max(tmp_y_result_glbl(2,:)));
    mean_y_loc=tmp_y_result_loc(1,:)(tmp_y_result_loc(2,:)==max(tmp_y_result_loc(2,:)));
    
%%==== Amplitude estimation ====
    ampl_y_glbl=1;
    ampl_y_loc=1;
    
%%==== Amplitude estimation ====
    offset_y_glbl=min(tmp_y_result_glbl(2,:));
    offset_y_loc=min(tmp_y_result_loc(2,:));

%%==== Start fitting ====
%% pin = [sigma, mean, amplitude, offset]
disp('Fitting global y curve...')
pin_y_glbl = [std_y_glbl, mean_y_glbl, ampl_y_glbl , offset_y_glbl];
[f_y_glbl, p_y_glbl, cvg_y_glbl, iter_y_glbl, corp_y_glbl, covp_y_glbl] = leasqr(tmp_y_result_glbl(1,:),tmp_y_result_glbl(2,:),pin_y_glbl,"gaussianfit");
disp('')

disp('Fitting local y curve...')
pin_y_loc = [std_y_loc, mean_y_loc, ampl_y_loc , offset_y_loc];
[f_y_loc, p_y_loc, cvg_y_loc, iter_y_loc, corp_y_loc, covp_y_loc] = leasqr(tmp_y_result_loc(1,:),tmp_y_result_loc(2,:),pin_y_loc,"gaussianfit");
disp('')
%p
%covp
sigma_y_glbl = p_y_glbl(2)*pixel2mm;
sigma_y_loc = p_y_loc(2)*pixel2mm;
fwhm_y_glbl = fwhm(tmp_y_result_glbl(1,:)*pixel2mm, gaussianfit(tmp_y_result_glbl(1,:),p_y_glbl));
fwhm_y_loc =  fwhm(tmp_y_result_loc(1,:)*pixel2mm, gaussianfit(tmp_y_result_loc(1,:),p_y_loc));

%%===== Y Distribution =====
ycolor = 'red';
subplot(3,3,[1 4])
  
    plot(...
        tmp_y_result_glbl(2,:), tmp_y_result_glbl(1,:)*pixel2mm, 'color', ycolor, ...
        tmp_y_result_loc(2,:), tmp_y_result_loc(1,:) *pixel2mm, 'color', 'magenta', ...
        gaussianfit(tmp_y_result_glbl(1,:),p_y_glbl), tmp_y_result_glbl(1,:)*pixel2mm , 'color', [1 .5 0], ...
        gaussianfit(tmp_y_result_loc(1,:),p_y_loc), tmp_y_result_loc(1,:)*pixel2mm, 'color', [0.5 0.5 0])
        
    legend("global-y","local-y", ...
        sprintf("global gauss, sigma= %.2f, fwhm = %.2f, conv = %d",sigma_y_glbl, fwhm_y_glbl, cvg_y_glbl), ...
        sprintf("local gauss, sigma= %.2f, fwhm = %.2f, conv = %d",sigma_y_loc, fwhm_y_loc, cvg_y_loc))
    legend('location','east')

    axis([0,Inf,0,rows(imgdata)]*pixel2mm, "autox")
    set (gca, "yaxislocation", "right");
    set(gca(), 'ydir', 'reverse', 'xdir', 'reverse')
    ylabel ('y in mm', 'fontsize', 12);
    xlabel ('I / sum(I)', 'fontsize', 12);
    
return;

%%===== Save results =====
if (yes_or_no("Save the result?")==1)
    result_x_glbl = [[1:columns(imgdata)]' int_x_glbl_norm'];
    result_x_loc = [[choice_x(1):choice_x(2)]' int_x_loc_norm'];
    save 'result_x.dat' result_x_glbl result_x_loc;
    result_y_glbl = [[1:rows(imgdata)]' int_y_glbl_norm];
    result_y_loc = [[choice_y(1):choice_y(3)]' int_y_loc_norm];
    save 'result_y.dat' result_y_glbl result_y_loc;
endif













%%===== IMAGE Zoom =====
% subplot(3,3,7)
    % imshow(imgdata,"xdata", [choice_x(1) choice_x(2)],"ydata",  [choice_y(1) choice_y(3)]);
    % axis ([choice_x(1):choice_x(2)], [choice_y(1):choice_y(3)]);
    % grid minor on;
    % title ('Zoom');
% i = 0;
% while (i <= 3)
% [x1,y1]=ginput(2);
    % plot(x1,[y1(1);y1(1)],'linewidth',2,'color',xcolor)
    % xint = sum(
    % imgdata(round(y1(1)),round(x1(1):x1(2)))
    % ,2);    
% subplot(3,3,4)    
    % xplot = plot(xint, 'linewidth', 2,'color', xcolor,'markersize', 9);
    % xlabel ('Pixel number ', 'fontweight', 'bold');
    % ylabel ('Integrated Value', 'fontweight', 'bold');
    % hold on;
% i++;
% endwhile    
%===== YPLOT =====
% subplot(3,3,2)
% ycolor = 'red';
% [x2,y2]=ginput(2);
    % ymatrix = [[x2(1);x2(1)],y2];
    % plot(ymatrix,'linewidth',2,'color',ycolor)
    % yint = sum(imgdata(:,round(x2(1):x2(2))),2);    
% subplot(3,3,1)    
    % yplot = plot(yint, 'linewidth', 2,'color', ycolor,'markersize', 9);
    % xlabel ('Pixel number ', 'fontweight', 'bold');
    % ylabel ('Integrated Value', 'fontweight', 'bold');







% [A,B] = size(rawdata);
% y = sum(rawdata(:, 400:550), 2);
% daten = [(1:length(y))', y];
% disp("Saving Data")
% save "output_test.dat" daten

% bla = plot (y);
% set(bla, "linewidth", 2); 
% set(bla, "color", "blue");
% set(bla, "markersize", 9);
% axis ([1, 1024]);
% xlabel ("Pixel number ", "fontweight", "bold");
% ylabel ("Integrated Value", "fontweight", "bold");
% # bla = text (205, 5500, sprintf("FWHM = %.04g  %.03f", f ));
% # set(bla, "fontsize", 18, "fontweight", "bold");
% set(gca(), "fontsize", 18, "fontweight", "bold");
% set(get(gca(), "xlabel"), "fontsize", 18);
% set(get(gca(), "ylabel"), "fontsize", 18);
% print ("test.pdf",'-dpdf','-FTimes-Roman:18','-color', '-landscape');