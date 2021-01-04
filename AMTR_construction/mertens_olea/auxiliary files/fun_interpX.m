function D = fun_interpX(D)


 % Fill in missing observations by assuming that TI is proportional to AGI; 
                        avti = D.avti';
                        ret_ti = D.ret_ti';
                       
                        avti2  = avti;
                        ret_ti2 = ret_ti;
                        pos1     = find([diff(isnan(avti))==1 0],length(avti));
                        pos2     = find([diff(isnan(avti))==-1 -1],length(avti));
                        pos2     = pos2(1:length(pos1));
                        for j=1:length(pos1)
                            w  = D.w(pos1(j):pos2(j));
                            avti2(pos1(j):pos2(j))   = avti(pos1(j))*D.avagi(pos1(j):pos2(j))/...
                              (sum(D.w(pos1(j):pos2(j)).*D.avagi(pos1(j):pos2(j)))/sum(D.w(pos1(j):pos2(j))));       
                            ret_ti2(pos1(j):pos2(j)) = ret_ti(pos1(j)).*(D.w(pos1(j):pos2(j)))/sum(D.w(pos1(j):pos2(j)));
                        end                    
                        D.avti   = avti2';
                        D.ret_ti = ret_ti2';
                  
