%
% Octave script that allows to convert the output of epics camonitor time format to seconds
%	Input should look like:
%	area:subarea:pvname	2017-06-05 10:12:35.5555 5
%
%%===== Read input =====
fprintf("Start reading file %s\n",argv(){1})
fid = fopen(argv(){1},"r");
fmt = '%*s:%*s:%*s %f-%f-%f %f:%f:%f %f';
%Alternative: fmt = '%*[0-9a-zA-Z]:%*[0-9a-zA-Z]:%*[0-9a-zA-Z] %f-%f-%f %f:%f:%f %f';
a = textscan(fid,fmt);
fclose(fid);

%%===== Calculate Time =====
Years=a{1};Months=a{2};Days=a{3};Hours=a{4};Minutes=a{5};Seconds=a{6};Values=a{7};
rawTime = 24*3600*Days+3600*Hours+60*Minutes+Seconds;
Time = rawTime-rawTime(1); %First entry

%%===== Save to formated output =====
outputfile = [argv(){1}(1:end-4) "_formated.dat"];
fprintf("Writing output file %s\n",outputfile)
f1 = fopen(outputfile,"w");
fputs(f1,"#First Line\n");
fputs(f1,"#Time in s\tValue\n");
for i = 2:numel(Time)
	fprintf(f1,'%.4f\t%.3f\n',Time(i),Values(i));
end
fclose(f1);
disp("Habe Fertig!")
