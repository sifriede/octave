%% ===== Needed Input =====
% arg_list = argv(); 
% source = arg_list{1};
% ===== Debug =====
source = "pka2";

%% ===== Custom Variables =====
outdirectory = [source "_results_new/"];
xvxdirList = strrep(glob([outdirectory "ppsm*xvx*"]),'\','/');
zEzdirList = strrep(glob([outdirectory "ppsm*zEz*"]),'\','/');
if strcmp(source,"pka2")
	U = 1e5;
	kT = 200;
	t_sigma = 100;
endif

% ===== Load file and start calculating =====
disp("Reading and writing transverse emittance...")
global_transverseemittance = {};
global_transverseemittance{1} = ...
"#runid frame q_bunch[C] U[V] kT[meV] sigma_0[mm] t_sigma[ps] \
nrmsxemittance[mm rad] beta[m] gamma[1/m] alpha meanz[mm] Particles";
temp_list = [];
disp(sprintf("Number of elements to read: %d",length(xvxdirList)))
for i = 1:length(xvxdirList)
	disp(sprintf("Element:%d, loading %s",i,xvxdirList{i}))
	clear result_*;
	load(num2str(xvxdirList{i}));
	frame = sscanf(xvxdirList{i},[outdirectory 'ppsm_%*3c%4d*']);
	disp(frame)
	idx = result_runid{2}(1);
	temp_list = [temp_list; idx frame result_emittance{2} result_meanz{2}(1) result_meanz{2}(3)];
endfor
global_transverseemittance{2} = [temp_list] ;
save([outdirectory "all_" source "_transverseemittance.dat"],"global_transverseemittance")

% ===== Load file and start energyspread =====
disp("Reading and writing energyspread...")
global_energyspread = {};
global_energyspread{1} = ...
"#runid frame q_bunch[C] U[V] kT[meV] sigma_0[mm] t_sigma[ps] \
Emax-Emin[eV] rel.Energyspread meanz[mm] Particles";
if strcmp(source,"pka2")
	U = 1e5;
	kT = 200;
	t_sigma = 100;
	sigma_0 = 0.5;
endif
temp_list = [];
disp(sprintf("Number of elements to read: %d",length(zEzdirList)))
for i = 1:length(zEzdirList)
	disp(sprintf("Element %d, loading %s",i,zEzdirList{i}))
	clear result_*;
	load(num2str(zEzdirList{i}));
	frame = sscanf(xvxdirList{i},[outdirectory 'ppsm_%*3c%4d*']);
	disp(frame)
	idx = result_runid{2}(1);
	temp_list = [temp_list; idx frame result_emittance{2} result_meanz{2}(1) result_meanz{2}(3)];
endfor
global_energyspread{2} = [temp_list] ;
save([outdirectory "all_" source "_energyspread.dat"],"global_energyspread")