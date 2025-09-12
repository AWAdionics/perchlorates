function [real_mat,feed_vec,eq_mat] = perchlorates_palgo_daqdt_mat(simulation)
    %sulfates_p_daqdt 
    %
    % real_mat
    %
    % ext_prior = (1+O/A_ext) Q^ext_aq/V_mix
    % rege_prior = (1+1/(O/A_rege)) Q^rege_aq/V_mix
    % common_ext = (1 + O/A_ext)Q^ext_aq/V_mix
    % common_rege = (1 + O/A_rege)Q^rege_aq/V_mix
    % diag_ext = - (k_ext a_ext + (1 + O/A_ext)Q^ext_aq/V_mix)
    % diag_rege = - (k_rege a_rege + (1 + O/A_rege)Q^rege_aq/V_mix)
    % ext_ak = k_ext a_ext
    % rege_ak = k_rege a_rege
    %
    %
    % ALL MATRICES AND VECTORS ARE FORMED BLOCK PER BLOCK FOR EACH ION,
    % TO USE PROPERLY MAKE SURE YOU CONVERT TO VECTOR FORMAT USING
    % perchlorates_palgo_cmatvec AND THEN BACK TO MATRIX FORMAT (for ODE 
    % and eq) USING perchlorates_cvecmat
    %
    % ANIONS ARE PUT AFTER CATIONS
    %
    % Matrix for each ion should have the form (assume 3 extractions):
    % [diag_ext      0          0          0           0           0     ]
    % [ext_prior diag_ext       0          0           0           0     ]
    % [   0      ext_prior   diag_ext      0           0           0     ]
    % [   0          0          0      diag_rege       0           0     ]
    % [   0          0          0      rege_prior  diag_rege       0     ]
    % [   0          0          0         0        rege_prior  diag_rege ]
    % REPEATED FOR EACH ION :
    %   [ Mi1   0   0    0 ]
    %   [  0   Mi2  0    0 ]
    %   [  0    0  Mi3   0 ]
    %   [  0    0   0   Mi4]
    %
    % feed_vec
    % Vector for each ion should have the form (assume 3 extractions)
    % [common_ext*ext_feed ]
    % [    0    ]
    % [    0    ]
    % [common_rege*rege_feed]
    % [    0    ]
    % [    0    ]
    % REPEATED FOR EACH ION IN A COLUMN:
    % [vi1]
    % [vi2]
    % [vi3]
    % [vi4]
    %
    %
    % eq_mat
    % Matrix for each ion should have the form (assume 3 extractions):
    % [ ext_ak      0        0        0          0          0    ]
    % [    0      ext_ak     0        0          0          0    ]
    % [    0        0      ext_ak     0          0          0    ]
    % [    0        0        0      rege_ak      0          0    ]
    % [    0        0        0        0        rege_ak      0    ]
    % [    0        0        0        0          0       rege_ak ]
    % REPEATED FOR EACH ION :
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
    %       real_mat : matrix to be multiplied by C_aq
    %       feed_vec_li : vector to be added to dadt corresponding to li
    %       feed_vec_so4 : vector to be added to dadt corresponding to so4
    %       eq_mat : matrix to be multiplied by C^eq_aq
    %
    % see also sulfates_p_algo_index (index)
    % sulfates_p_ode (called)
    % sulfates_p_dorgdt_mat (sister)

    n_ext = simulation.input.n_ext;
    cations = simulation.constants.cations_extracted;
    anions = simulation.constants.anions_extracted;
    nc = length(cations);
    na = length(anions);
    ext_feed_c_is  = [1:n_ext+3:(nc-1)*(n_ext+3)+1]; %iterates of extraction input in feed vector for cations
    rege_feed_c_is = [n_ext+1:n_ext+3:(nc-1)*(n_ext+3)+n_ext+1]; %iterates of regeneration input in feed vector for cations
    ext_feed_a_is  = [nc*(n_ext+3)+1:n_ext+3:nc*(n_ext+3)+(na-1)*(n_ext+3)+1]; %iterates of extraction input in feed vector for cations
    rege_feed_a_is = [nc*(n_ext+3)+n_ext+1:n_ext+3:nc*(n_ext+3)+(na-1)*(n_ext+3)+n_ext+1]; %iterates of regeneration input in feed vector for cations
    ext_feed_c = simulation.constants.ext_feed_c(1:nc);
    ext_feed_a = simulation.constants.ext_feed_a(1:na);
    rege_feed_c = simulation.constants.rege_feed_c(1:nc);
    rege_feed_a = simulation.constants.rege_feed_a(1:na);

    ext_OA = simulation.input.ext_OA;
    rege_OA = simulation.input.rege_OA;
    Qext = simulation.constants.Qext;
    Qrege = simulation.constants.Qrege;
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
    
    %real terms
    %coef is in brackets [] which will be multiplied by C_aq,k or k-1

    %common ext and rege terms
    common_ext = (one + ext_OA).*Qext./Vmix;
    common_rege = (one + rege_OA).*Qrege./Vmix;

    %prior stage term coeff (C_aq,k-1)
    %[(1+O/A_ext) Q^ext_aq/V_mix]   *   C_aq,k-1
    ext_prior = common_ext; %extraction
    %[(1+1/(O/A_rege)) Q^rege_aq/V_mix]   *   C_aq,k-1
    rege_prior = common_rege; %regeneration
    
    %prior stage terms are on subdiagonal
    subdiag = [repmat(ext_prior,1,n_ext-1),... %for extraction 1, k-1 term is feed
               repmat(rege_prior,1,3)];
    subdiag(n_ext) = 0; %corresponds to last extraction stage to first rege flow
    %this is replaced by rege feed 
    %alternatively, corresponds to prior subdiag term for first rege 
    %since the same term for first extraction disappears (see above, its due 
    %to sub diag having 1 less term and 1-1 term being 0 ie outside matrix)
    %it is the n_ext th entry in the subdiag that is set to 0 which
    %corresponds to the subdiag of the n_ext+1th line

    %current term 
    %[- k_ext a_ext + (1 + O/A_ext)Q^ext_aq/V_mix]   *   C_aq,k 
    diag_ext = -(ext_ak+common_ext);
    %[- k_rege a_rege + (1 + O/A_rege)Q^rege_aq/V_mix]   *   C_aq,k 
    diag_rege = -(rege_ak+common_rege);
    
    %current stage terms are on diagonal
    ondiag = [repmat(diag_ext,1,n_ext),... %extraction
              repmat(diag_rege,1,3)];      %regeneration
    
    %assemble both to get the "real" matrix (though equilibrium is also real)
    real_mat_ion = diag(ondiag) + diag(subdiag,-1);
    %Matrix for each ion should have the form (assume 3 extractions):
    %[diag_ext      0          0          0           0           0     ]
    %[ext_prior diag_ext       0          0           0           0     ]
    %[   0      ext_prior   diag_ext      0           0           0     ]
    %[   0          0          0      diag_rege       0           0     ]
    %[   0          0          0      rege_prior  diag_rege       0     ]
    %[   0          0          0         0        rege_prior  diag_rege ]
    %make full block diagonal matrix
    block_input = repmat({real_mat_ion},1,nc+na);
    real_mat = mavu_blkdiag(block_input{:});
    % REPEATED FOR EACH ION AS BLOCK DIAGONAL MATRIX:
    %   [ Mi1   0   0    0 ]
    %   [  0   Mi2  0    0 ]
    %   [  0    0  Mi3   0 ]
    %   [  0    0   0   Mi4]
    

    %feed term
    feed_vec = mvu(zeros((nc+na)*(n_ext+3),1),'mmol/ L* s');
    feed_vec(ext_feed_c_is) = common_ext.*ext_feed_c;
    feed_vec(ext_feed_a_is) = common_ext.*ext_feed_a;
    feed_vec(rege_feed_c_is) = common_rege.*rege_feed_c;
    feed_vec(rege_feed_a_is) = common_rege.*rege_feed_a;
    %Vector for each ion should have the form (assume 3 extractions) 
    %[ext_feed ]
    %[    0    ]
    %[    0    ]
    %[rege_feed]
    %[    0    ]
    %[    0    ]
    %
    % REPEATED FOR EACH ION IN A COLUMN:
    % [vi1]
    % [vi2]
    % [vi3]
    % [vi4]

    %equilibrium term
    ondiag_eq = [repmat(ext_ak,1,n_ext),...
                 repmat(rege_ak,1,3)];
    eq_mat_ion = diag(ondiag_eq);
    %Matrix for each ion should have the form (assume 3 extractions):
    %[ ext_ak      0        0        0          0          0    ]
    %[    0      ext_ak     0        0          0          0    ]
    %[    0        0      ext_ak     0          0          0    ]
    %[    0        0        0      rege_ak      0          0    ]
    %[    0        0        0        0        rege_ak      0    ]
    %[    0        0        0        0          0       rege_ak ]
    %make full block diagonal matrix
    block_input = repmat({eq_mat_ion},1,nc+na);
    eq_mat = mavu_blkdiag(block_input{:});
    % REPEATED FOR EACH ION AS BLOCK DIAGONAL MATRIX:
    %   [ Mi1   0   0    0 ]
    %   [  0   Mi2  0    0 ]
    %   [  0    0  Mi3   0 ]
    %   [  0    0   0   Mi4]
end