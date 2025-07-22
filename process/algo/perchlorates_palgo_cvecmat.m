function mat = perchlorates_palgo_cvecmat(mat,vec,is,ks)
%perchlorates_palgo_cvecmat From the vector concentrations get matrix concentrations
%   
%   Args:
%       mat : array of matrix to put vector values into
%       vec : array of vector whose values we put into matrix
%       is : array associating row indices to vector indices
%       js : array associating column indices to vector indices
%
%   Returns:
%       mat : array of matrix to put vector values into
arguments (Input)
    mat MatrixValueUnit
    vec MatrixValueUnit
    is
    ks
end
    mat(sub2ind(size(mat),is,ks))=vec;
end