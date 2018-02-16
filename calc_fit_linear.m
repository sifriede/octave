pkg load optim;
clear all; clf;
 
% Function that will be fit
function [y]=line_func(x,par)
  y=par(1)*x+par(2);
end
 
% Generate a line
m=2;
b=1;
x=[0:0.1:10]';
y=m*x+b;
 
% Add some noise to the line
sigma=0.1;
weights=ones(size(x))/sigma;
y=y+randn(size(x))*sigma;
 
% Perform the fit
pin=[m,b];
[f,p,cvg,iter,corp,covp]=leasqr(x,y,pin,"line_func",.0001,20,weights);
 
% Print out the results
p
covp
sum((y-line_func(x,p)).^2.*weights.^2)
 
% Plots
subplot(2,1,1)
hold on;
errorbar(x,y,1./weights);
plot(x,line_func(x,p));
 
subplot(2,1,2);
errorbar(x,y-line_func(x,p),1./weights);