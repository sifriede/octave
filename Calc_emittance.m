zEz = dlmread("octaveoutput_STEAM_zEp_3600.txt","",1,0);
z = zEz(:,7) * 1e3; %z in mm
Ez = zEz(:,8); %Ez in eV
flaeche = [];
trapez = [];
ilist = [];
% di = 0.1;
for di = 0.01:0.01:1
	mittel = [];
	 standard = [];
	 zBin = ceil(min(z)):2*di:floor(max(z));
	 for i = zBin
		 tempEz = Ez(z > i-di & z <= i + di);
		 mittel(end + 1) = mean(tempEz);
		 standard(end + 1) = std(tempEz);
	 endfor
	
	flaeche(end + 1) = sum(2 * standard) * 2*di;
	trapez(end + 1)  = trapz(zBin, 2*standard);
	ilist(end +1) = [di];
endfor
resmatrix = [ilist' flaeche' trapez'];
plot (zBin, mittel + standard, "@", zBin, mittel - standard, "@");

save("restrapez.dat","trapez");
save("resmatrix.dat","resmatrix");

function [emittancenrms,beta,gamma,alpha] = calcemittancetwiss(a,b,U=1e5)
	warning ("off", "Octave:divide-by-zero");
	emittance	= sqrt(mean(a.^2)*mean(b.^2)-mean(a.*b)^2);
	emittancenrms	= sqrt((U+511000)^2/511000^2-1) * emittance;
	beta		= mean(a.^2)/emittance;
	gamma		= mean(b.^2)/emittance;
	alpha		= -mean(a.*b)/emittance;
endfunction

calcemittancetwiss(z,Ez)