function mat = perchlorates_palgo_cvecmat(mat,vec,is,ks)
%perchlorates_palgo_cvecmat 
arguments (Input)
    mat MatrixValueUnit
    vec MatrixValueUnit
    is
    ks
end
    mat(sub2ind(size(mat),is,ks))=vec;
end