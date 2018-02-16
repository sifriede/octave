filename = "free.txt";
fid = fopen (filename, "w");
fputs (fid, "This is a simple text written in a textfile");
fclose (fid);

A = [1 2; 3 4];
save myfile.txt A

B = [f(2) f(3); f(4) f(5)];
save myfile2.txt B

disp("Habe fertig!")