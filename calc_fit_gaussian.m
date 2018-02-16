pkg load optim;
clear all; clf;
load result_x.dat;
vec_x=result_x_local(:,1);
vec_y=result_x_local(:,2);

function [retval] = gaussianfit (x, par)
	retval = par(3) / (par(1)*sqrt(2*pi)) * exp(-1/2*((x-par(2))/par(1)).^2) + par(4);
endfunction

pin = [250, 680, 1, 0];
[f,p,cvg,iter,corp,covp]=leasqr(vec_x,vec_y,pin,"gaussianfit");
p
covp

% Plots
%subplot(2,1,1)
%hold on;
plot(vec_x,vec_y,gaussianfit(vec_x,p))
grid on;
%
%subplot(2,1,2);
%errobar(vec_x,vec_y-gaussianfit(vec_x,p))
