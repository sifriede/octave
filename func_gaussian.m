##
## [retval] = gaussian (x, sigma, mu, y0)
##
## par(1) = sigma
## par(2) = mu
## par(3) = offset
## par(4) = amplitude
##
## Created: 2018-01-24

function [retval] = func_gaussian (x, sigma, mu, offset=0,amp=1)
	retval = offset + amp / (sigma*sqrt(2*pi)) * exp(-1/2*((x-mu)/sigma).^2);
endfunction
