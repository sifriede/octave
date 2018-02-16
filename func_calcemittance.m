%
%	Calculate normalized rms emittance
%	Parameter: func_calcemittance(x,xp,U=1e5)
%	Outputparameter: [nemittancenrms,beta,gamma,alpha]
%
function [nemittancenrms,beta,gamma,alpha] = func_calcemittance(x,xp,U=1e5)
	warning ("off", "Octave:divide-by-zero");
	emittancerms = sqrt(mean(x.^2)*mean(xp.^2)-mean(x.*xp)^2);
	nemittancenrms = sqrt((U+511000)^2/511000^2-1) * emittancerms;
	beta = mean(x.^2)/emittancerms;
	gamma = mean(xp.^2)/emittancerms;
	alpha = -mean(x.*xp)/emittancerms;
endfunction