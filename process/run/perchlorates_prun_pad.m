function out = perchlorates_prun_pad(vec, n, k)
    %sulfates_p_pad padds the vector with NaN after k such that it has n values
    %
    %   Used to make sure that all ode ouptuts have the same number of
    %   elements even with differing extraction stages.
    %   first k elements are the number of extractions of THIS iteration, n
    %   is the length of the longest vector.
    %   from ode outputs:
    %   [a1   a2   a3   a4   a5   a6   a7]
    %   [b1   b2   b3   b4   b5   b5]
    %   [c1   c2   c3   c4   c5]
    %   [d1   d2   d3   d4]
    %   Thus the final matrix has a form of type:
    %   [a1   a2   a3   a4   a5   a6   a7]
    %   [b1   b2   b3   NaN  b4   b5   b5]
    %   [c1   c2   NaN  NaN  c3   c4   c5]
    %   [d1   NaN  NaN  NaN  d2   d3   d4]
    %   This way data is correctly inputted into the right columns of excel
    %   Last 3 are regeneration, first (variable number of) columns are 
    %   extractions  
    %
    %
    %   Args :
    %       vec : mvu or vector of length l of form [v1,v2,v3,...,vl] to pad
    %       n : length of vector after padding
    %       k : index after which we padd with NaN
    %   
    %   Returns :
    %       out : mvu or vector of padded  of length n of form [v1,v2,...,vk,Nan,NaN...,Nan,v{k+1},...vl]
    %
    %   see also sulfates_p_run_index (index)
    %   sulfates_p_ode (called)

    % Validate inputs
    if k < 1 || k > n + 1
        error('k must be between 1 and n+1');
    end
    if length(vec) > n
        error('vec is longer than target length n');
    end

    % Calculate how many NaNs to insert
    numNaNs = n - size(vec,2);
    
    % If nothing to insert, just return vec
    if numNaNs <= 0
        out = vec;
        return;
    end
    
    %make nans
    nanvec = nan(size(vec,1), numNaNs);
    if isa(vec,'MatrixValueUnit')
        nanvec = mavu(nanvec,vec.unit);
    end

    % Split and insert
    a = vec(:,1:k);
    b = vec(:,k+1:length(vec));
    out = [a, nanvec,b];
end
