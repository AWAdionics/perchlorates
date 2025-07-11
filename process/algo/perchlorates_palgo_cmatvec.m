function vec = perchlorates_palgo_cmatvec(mat,vec,is,js)
%perchlorates_palgo_cvecmat 
arguments (Input)
    mat MatrixValueUnit
    vec MatrixValueUnit
    is
    js
end
    vec(:) = mat(sub2ind(size(mat), is, js));
end