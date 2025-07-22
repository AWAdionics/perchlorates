function vec = perchlorates_palgo_cmatvec(mat,vec,is,js)
%perchlorates_palgo_cmatvec From the matrix concentrations get vector concentrations
%   
%   Args:
%       mat : array of matrix to put vector values into
%       vec : array of vector whose values we put into matrix
%       is : array associating row indices to vector indices
%       js : array associating column indices to vector indices
%
%   Returns:
%       vec : array of vector whose values we put into matrix
arguments (Input)
    mat MatrixValueUnit
    vec MatrixValueUnit
    is
    js
end
    vec(:) = mat(sub2ind(size(mat), is, js));
end