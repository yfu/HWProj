function f = getTestData(folder)

slant_location = strcat(folder,"/test/slant_data.txt");
skew_location = strcat(folder,"/test/skew_data.txt");
asc_vs_desc_location = strcat(folder,"/test/asc_vs_desc_data.txt");
curvature_location = strcat(folder,"/test/curvature_data.txt");

load(slant_location);
load(skew_location);
load(asc_vs_desc_location);
load(curvature_location);

f = [data_slant, data_skew, data_asc, data_curv];

endfunction