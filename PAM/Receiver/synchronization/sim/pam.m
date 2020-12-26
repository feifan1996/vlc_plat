clear all;
clc;

%-2048  2047
N = 12;
%tmp_array = [-2048:273:2047];
tmp_array = [-5 5]

for i = 1:length(tmp_array)
   x = tmp_array(i);
   if (x >= 0)
        bin_x = dec2bin(x, N)        % 正数的反码和补码都和原码一样
   else
        bin_x = dec2bin(2^N + x, N)
   end 
end
