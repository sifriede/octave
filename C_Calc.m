arg_list = argv(); 
%% ===== Needed Input =====
% source = arg_list{1};
% file = arg_list{2};
% ===== Debug =====
source = "pka2";
% file = "ppsm_xvx0034_all.txt";

%% ===== Custom Variables =====
filename = file(1:end-4);
frame = file(9:12);
fileend = ".txt";
outdirectory = [source "_results/"];
dirList = glob[outdirectory "ppsm*"];
xstring = file(6);
vxstring = file(7:8);
fullfile = [filedirectory filename fileend];

