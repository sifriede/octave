%%==== Matrizes/Array/Vectors =====
vector = [1,2,3,4]
matrix = [vector;2* vector]



%%==== Cell arrays ====
cellarray = {};
idx = 1;
cellarray{idx} = "String in cell array";
cellarray{end+1} = [1 2; 3 4];
cellarray{end+1} = matrix;
cellarray

