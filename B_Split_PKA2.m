%
%	Split ppsm-Files, that have are called 
%	"ppsm_{xvx|yvy|zvz|zEz}0034_all.txt"
%	and that are sed-edited form:
%	                                       ppsm_xvx-Frame 0034 ( 82 )/real
% ----------------------------------------------------------------------
%             -0.090091999                      -63677.053
%               0.47171839                       353439.28 ...
% 
%	Usage: octave script.m {steam|pka2} file
% 

%% ===== Needed Input for batch =====
arg_list = argv(); 
source = arg_list{1};
file = arg_list{2};

% ===== Debug =====
% source = "pka2";
% file = "ppsm_xvx0069_reallyall.dat";

%% =============================================
%% ===== Custom Variables =====
filename = file(1:end-4);
frame = file(9:12);
fileend = ".dat";
filedirectory = "";
outdirectory = [source "_results_new/"];
mkdir(outdirectory);
xstring = file(6);
vxstring = file(7:8);
fullfile = [filedirectory filename fileend];

%% ===== Custom Functions =====
outfile = @(id) [outdirectory filename "_runid" sprintf("%03d",id) ".dat" ];
header_steam = "#RunID U[V] kT[meV] q_bunch[C] sigma_0[mm] t_sigma[ps] MeshPass";
% Run ID;U;kT;q_bunch;sigma_0;t_sigma;Mesh Pass
header_pka2 = "#RunID emissiondensity q_bunch[C] MeshPass";
%% ===== Welcom =====
disp("===== Start Script =====")
%% ===== runid.txt =====
disp(sprintf("Reading %s runid.txt: ...",source))
runidtxt = dlmread([filedirectory "runid.txt"],";",1,0); 
runidtxt(1,:) %Debug
	%steam	3D Run ID;U;kT;q_bunch;sigma_0;t_sigma;Mesh Pass
	%pka2 	3D Run ID;emissiondensity;q_bunch;Mesh Pass
disp("finished!")


%% ===== mean(z) =====
disp(sprintf("Reading %s: ...",[filedirectory "0d_Frame" frame "_meanz.txt"]))
meanztxt = dlmread([filedirectory "0d_Frame" frame "_meanz.txt"],"",2,0);


%% ===== mean(vz) =====
disp(sprintf("Reading %s: ...",[filedirectory "0d_Frame" frame "_meanvz.txt"]))
meanvztxt = dlmread([filedirectory "0d_Frame" frame "_meanvz.txt"],"",2,0);


%% ===== Get columns with runid =====
disp(sprintf("Start splitting file: %s ...",file))
m = dlmread(fullfile,"",0,0);
n = length(m);
runid = [];
for i = 1:n
	if (m(i,1) == 0 && m(i,2) != 0 && m(i,3) == 0)
		runid(end+1,:) = [m(i,4), i]; % It's important, that dlmread splits correctly
	endif
endfor




%%% ===== Define single matrizes by runid =====
disp("Defining single matrizes by runid")
m_per_runid = {};
for i = 1:length(runid)
	idx = runid(i, 1);
	if idx == 0
		continue
	elseif i != length(runid)
		m_per_runid{idx} = m(runid(i,2)+2:runid(i+1,2)-1,1:2);
	elseif i == length(runid)
		m_per_runid{idx} = m(runid(i,2)+2:end,1:2);
	endif
endfor




%%% ===== Save m_per_runid to outfile(frame,runid)=====
disp("Start saving m_per_runid")
for i = 1:length(runid)
	idx = runid(i,1);
	idx_match = find(runidtxt(:,1) == idx);
	disp(sprintf("source = %s, runidtxt(%d,end)=%d, idx = %d",source,idx_match,runidtxt(idx_match,end),idx))
	if idx == 0
		continue
	elseif strcmp(source,"steam") && runidtxt(idx_match,end) != 2
		continue
	elseif strcmp(source,"pka2") && runidtxt(idx_match,end) != 3
		continue
	endif
	disp(sprintf("file: %s; Saving m_per_runid{%d}",filename,idx))
	temp_outfile = outfile(idx); % Save the following results to temp_outfile
	%% ===== Which source =====
	if strcmp(source,"steam")
		result_runid{1} = header_steam;
		U = runidtxt(idx_match,2);
		kT = runidtxt(idx_match,3);
		q_bunch = runidtxt(idx_match,4);
		sigma_0 = runidtxt(idx_match,5);
		t_sigma = runidtxt(idx_match,6);
	elseif strcmp(source,"pka2")
		result_runid{1} = header_pka2;
		U = 1e5;
		kT = 200;
		q_bunch = runidtxt(idx_match,3);
		disp(sprintf("q_bunch(%d)_pka2 = %e",idx,q_bunch))
		sigma_0 = 0.5;
		t_sigma = 100;
	endif
	%% ==== Result runid ====
	result_runid{2} = [runidtxt(idx_match,:)];
	
	%% ==== Result meanz and number of particles ====
	matching_meanz = meanztxt(find(meanztxt(:,1) == idx), 2);
	matching_meanvz = meanvztxt(find(meanvztxt(:,1) == idx), 2);
	number_of_particles = length(m_per_runid{idx});
	result_meanz{1} = ["#meanz[mm] meanvz[m/s] Particles frame"];
	result_meanz{2} = [matching_meanz, matching_meanvz, number_of_particles,str2num(frame)];
	
	%% ==== Result matrix, prime values and emittance or energy spread ====
	if strcmp(vxstring(1),"v")
		result_values{1} = sprintf("#%s[mm] %s[m/s] %s[mm] %s",...
						xstring, vxstring, ["d" xstring], ["d" xstring "p"]);
		dx = m_per_runid{idx}(:,1) - mean(m_per_runid{idx}(:,1)) ; %%[??dx oder x??]
		% x = m_per_runid{idx}(:,1);
		dxp = (m_per_runid{idx}(:,2) - mean(m_per_runid{idx}(:,2)))/matching_meanvz ;
		% xp = m_per_runid{idx}(:,2)/matching_meanvz*1000;
		result_values{2} = [m_per_runid{idx} dx dxp];
		
		%%=== Emittance ===
		[temp_nrmsemittance, temp_beta, temp_gamma, temp_alpha] = func_calcemittance(dx,dxp,U);
		% [temp_nrmsemittance, temp_beta, temp_gamma, temp_alpha] = func_calcemittance(x,xp,U);
		result_emittance{1} = "#q_bunch[C] U[V] kT[meV] sigma_0[mm] t_sigma[ps] nrmsxemittance[mm mrad] beta[m] gamma[1/m] alpha";
		result_emittance{2} = [q_bunch,U,kT,sigma_0,t_sigma,temp_nrmsemittance, temp_beta, temp_gamma, temp_alpha];		
		
	elseif strcmp(vxstring(1),"E")
		result_values{1} = sprintf("#%s[mm] %s[eV] %s[mm] %s[eV]",...
						xstring, vxstring, ["d" xstring], ["d" vxstring]);
		dz = m_per_runid{idx}(:,1) - mean(m_per_runid{idx}(:,1)) ;
		dEz = m_per_runid{idx}(:,2) - mean(m_per_runid{idx}(:,2)) ;
		result_values{2} = [m_per_runid{idx} dz dEz];
		
		%%=== Energy spread ===
		Emax_Emin = (max(m_per_runid{idx}(:,2))-min(m_per_runid{idx}(:,2)));
		relative_energyspread = Emax_Emin / (U+511e3);
		result_emittance{1} = "#q_bunch[C] U[V] kT[meV] sigma_0[mm] t_sigma[ps] Emax-Emin[eV] rel.Energyspread";
		result_emittance{2} = [q_bunch,U,kT,sigma_0,t_sigma,Emax_Emin,relative_energyspread];		
	endif
	%% ==== Save everything!! ====
	save(temp_outfile,'result_*');
endfor




disp(sprintf("Habe fertig! file: %s ...\n",file))