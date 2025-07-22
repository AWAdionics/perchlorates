function [is,js] = perchlorates_palgo_ijs(n_ext,n_c,n_a)
%perchlorates_palgo_cvecmat generates vector to matrix maps
%
%   Generates 2 vectors which for each vector gives the matrix coordinates,
%   the first for rows the second for columns, in the ODE matrix.
%
%   Args:
%       n_ext : int of number of extractions
%       n_c : int of number of cations
%       n_a : int of number of anions
%
%   Returns:
%       is : array of int row indices of matrix for each entry in the vector
%       js : array of int column indices of matrix for each entry in the vector
%
%   see also 
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