function f = document_skew(imbw)

skew = -4;
skew_max = 0;
skew_location = 0;

for l = -4:0.5:4
	current_max = skew_energy(imbw,l);
	if current_max > skew_max
		skew_max = current_max;
		skew = l;
	endif
endfor
for l = (skew - 0.5):0.1:(skew + 0.5)
	current_max = skew_energy(imbw,l);
	if current_max > skew_max
		skew_max = current_max;
		skew = l;
	endif
endfor
for l = (skew - 0.1):0.05:(skew + 0.1)
	current_max = skew_energy(imbw,l);
	if current_max > skew_max
		skew_max = current_max;
		skew = l;
	endif
endfor
f = skew;

endfunction
