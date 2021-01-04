function D = fun_interpW(D)


 % Interpolate missing observations; 
                        avwinc = D.avwinc';
                        frac_retwinc = D.frac_retwinc';
                       
                        avwinc2  = avwinc;
                        frac_retwinc2 = frac_retwinc;
                        pos1     = find([diff(isnan(avwinc))==1 0],length(avwinc));
                        pos2     = find([diff(isnan(avwinc))==-1 -1],length(avwinc));
                        pos2     = pos2(1:length(pos1));
                        for j=1:length(pos1)
                         %   w  = D.w(pos1(j):pos2(j));
                            avwinc2(pos1(j):pos2(j))   = avwinc(pos1(j))*D.avagi(pos1(j):pos2(j))/...
                              (sum(D.w(pos1(j):pos2(j)).*D.avagi(pos1(j):pos2(j)))/sum(D.w(pos1(j):pos2(j))));       
                            frac_retwinc2(pos1(j):pos2(j)) = (frac_retwinc(pos1(j)).*D.ret(pos1(j)).*(D.w(pos1(j):pos2(j)))/sum(D.w(pos1(j):pos2(j))))./D.ret(pos1(j):pos2(j));
                                                             
                        end                    
                        D.avwinc   = avwinc2';
                        D.frac_retwinc = frac_retwinc2';