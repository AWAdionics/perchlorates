function [real_mat,eq_mat] = perchlorates_palgo_dorgdt_mat(simulation)
    %sulfates_p_dorgdt 
    %
    % real_mat
    %
    % ext_post = (1+1/O/A_ext) Q_org/V_mix
    % rege_post = (1+1/(O/A_rege)) Q_org/V_mix
    % diag_ext = - ( k_ext a_ext + (1 + 1/O/A_ext)Q_org/V_mix)
    % diag_rege = -( k_rege a_rege + (1 + 1/O/A_rege)Q_org/V_mix)
    % ext_ak = k_ext a_ext
    % rege_ak = k_rege a_rege
    %
    % Matrix should have the form (assume 3 extractions):
    %[diag_ext  ext_post      0         0          0         0    ]
    %[   0      diag_ext  ext_post      0          0         0    ]
    %[   0          0     diag_ext   ext_post      0         0    ]
    %[   0          0         0      diag_rege rege_post     0    ]
    %[   0          0         0         0      diag_rege rege_post]
    %[rege_post     0         0         0          0     diag_rege]
    % REPEATED FOR EACH ION AS BLOCK DIAGONAL MATRIX:
    %   [ Mi1   0   0    0 ]
    %   [  0   Mi2  0    0 ]
    %   [  0    0  Mi3   0 ]
    %   [  0    0   0   Mi4]
    %
    % eq_mat
    % Matrix should have the form (assume 3 extractions):
    % [ ext_ak      0        0        0          0          0   ]
    % [    0      ext_ak     0        0          0          0   ]
    % [    0        0      ext_ak     0          0          0   ]
    % [    0        0        0      rege_ak      0          0   ]
    % [    0        0        0        0        rege_ak      0   ]
    % [    0        0        0        0          0       rege_ak]
    % REPEATED FOR EACH ION AS BLOCK DIAGONAL MATRIX:
    %   [ Mi1   0   0    0 ]
    %   [  0   Mi2  0    0 ]
    %   [  0    0  Mi3   0 ]
    %   [  0    0   0   Mi4]
    % 
    %
    %   Args :
    %       simulation : struct of simulation 
    %   
    %   Returns :
    %       real_mat : matrix to be multiplied by C_org
    %       eq_mat : matrix to be multiplied by C^eq_org
    %       feed_vec : vector to be added to dadt
    %
    % see also sulfates_p_algo_index (index)
    % sulfates_p_ode (called)
    % sulfates_p_daqdt_mat (sister)

    n_ext = simulation.input.n_ext;
    cations = simulation.constants.cations_extracted;
    anions = simulation.constants.anions_extracted;
    nc = length(cations);
    na = length(anions);
    ext_OA = simulation.input.ext_OA;
    rege_OA = simulation.input.rege_OA;
    Qorg = ConstantsPerchlorates.Qorg;
    Vmix = ConstantsPerchlorates.Vmix;
    ext_ak = simulation.input.ext_ak;
    rege_ak = simulation.input.rege_ak;

    persistent one one_in_ten
    if isempty(one)
        one = mvu(1,'');
        
    end
    %if one_in_ten()
    %    one_in_ten = mvu(1/100,'');
    %end
    one_in_ten = mvu(1/1000,'');
    ten = mvu(1,''); %2 worked
    %real terms
    %coef is in brackets [] which will be multiplied by C_org,k or k-1

    %common ext and rege terms
    common_ext = (one + one./ext_OA).*Qorg./Vmix;
    common_rege = (one + one./rege_OA).*Qorg./Vmix;

    %post stage term coeff (C_org,k-1)
    %[(1+O/A_ext) Q^ext_org/V_mix]   *   C_org,k+1
    ext_post = common_ext; %extraction
    %[(1+1/(O/A_rege)) Q^rege_org/V_mix]   *   C_org,k+1
    rege_post = common_rege; %regeneration
    
    %post stage terms are on subdiagonal
    supdiag = [repmat(ext_post,1,n_ext),... %for extraction 1, k-1 term is feed
               repmat(rege_post,1,2)];
    %this is replaced by rege feed 
    %alternatively, corresponds to post subdiag term for first rege 
    %since the same term for first extraction disappears (see above, its due 
    %to sub diag having 1 less term and 1-1 term being 0 ie outside matrix)
    %it is the n_ext th entry in the subdiag that is set to 0 which
    %corresponds to the subdiag of the n_ext+1th line

    %current term 
    %[- k_ext a_ext + (1 + O/A_ext)Q^ext_org/V_mix]   *   C_org,k 
    diag_ext = -(ext_ak+common_ext);
    %[- k_rege a_rege + (1 + O/A_rege)Q^rege_org/V_mix]   *   C_org,k 
    diag_rege = -(rege_ak+common_rege)*ten;
    
    %current stage terms are on diagonal
    ondiag = [repmat(diag_ext,1,n_ext),... %extraction
              repmat(diag_rege,1,3)];      %regeneration
    
    %assemble both to get the "real" matrix (though equilibrium is also real)
    real_mat_ion = diag(ondiag) + diag(supdiag,1);
    real_mat_ion(n_ext+3,1) = rege_post;
    %Matrix should have the form (assume 3 extractions):
    %[diag_ext  ext_post      0         0          0         0    ]
    %[   0      diag_ext  ext_post      0          0         0    ]
    %[   0          0     diag_ext   ext_post      0         0    ]
    %[   0          0         0      diag_rege rege_post     0    ]
    %[   0          0         0         0      diag_rege rege_post]
    %[rege_post     0         0         0          0     diag_rege]
    block_input = repmat({real_mat_ion},1,nc+na);
    real_mat = mavu_blkdiag(block_input{:}); 
    % REPEATED FOR EACH ION AS BLOCK DIAGONAL MATRIX:
    %   [ Mi1   0   0    0 ]
    %   [  0   Mi2  0    0 ]
    %   [  0    0  Mi3   0 ]
    %   [  0    0   0   Mi4]

    %equilibrium term
    ondiag_eq = [repmat(ext_ak,1,n_ext),...
                 repmat(rege_ak,1,3)];
    eq_mat_ion = diag(ondiag_eq);
    % Matrix should have the form (assume 3 extractions):
    % [ ext_ak      0        0        0          0          0    ]
    % [    0      ext_ak     0        0          0          0    ]
    % [    0        0      ext_ak     0          0          0    ]
    % [    0        0        0      rege_ak      0          0    ]
    % [    0        0        0        0        rege_ak      0    ]
    % [    0        0        0        0          0       rege_ak ]
    block_input = repmat({eq_mat_ion},1,nc+na);
    eq_mat = mavu_blkdiag(block_input{:});
    % REPEATED FOR EACH ION AS BLOCK DIAGONAL MATRIX:
    %   [ Mi1   0   0    0 ]
    %   [  0   Mi2  0    0 ]
    %   [  0    0  Mi3   0 ]
    %   [  0    0   0   Mi4]
end