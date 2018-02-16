## Berechnet das Limit fuer die Emittanz,
## das durch die thermische Emittanz gegeben ist.
## 
## Eingabe:
## LE(Q,T,Ekath)
## Q     = Bunchladung in pC (default: 100 pC)
## T     = Kathodentemperatur in K (default: 300 K)
## Ekath = Feldgradient auf der Kathode in MV/m (default: 1 MV/m)
## Das Ergebnis ist in [Mikrometer]
##

function [out]	= limited_emittance(Q=100,T=300,Ekath=1)
	out	= 1.2311*sqrt(Q*1e-12)*sqrt(T)*sqrt(1/Ekath)*1e3;
endfunction
