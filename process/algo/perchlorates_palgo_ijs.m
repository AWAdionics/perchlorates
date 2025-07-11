function [is,js] = perchlorates_palgo_ijs(n_ext,n_c,n_a)
%perchlorates_palgo_cvecmat 
arguments (Input)
    n_ext 
    n_c 
    n_a 
end
    %get dimensions
    is = ceil((1:((n_c+n_a)*(n_ext+3)))/(n_ext+3));
    js = mod(1:(n_c+n_a)*(n_ext+3),n_ext+3);
    js(js==0) = n_ext+3;
end