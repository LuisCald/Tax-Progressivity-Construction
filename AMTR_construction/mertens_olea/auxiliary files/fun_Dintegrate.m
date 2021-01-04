function agiLH = fun_Dintegrate(L,H,Dd);


                            if sum(Dd.bra(:,1)==L)==0
                            LL = L; else LL = [];
                            end
                            if sum(Dd.bra(:,2)==H)==0
                            HH = H; else HH = [];
                            end
                                
                            BRA     = [sort([Dd.bra(:,1);LL;HH]) sort([Dd.bra(:,2);LL;HH])];

                            DDD     = fun_NewBrackets(BRA,Dd);
                            PP      = 1:length(DDD.avagi);
                            selL    = PP(DDD.bra(:,2)==L);
                            selH    = PP(DDD.bra(:,2)==H);
                            agiLH   = DDD.w(selL+1:selH)'*DDD.avagi(selL+1:selH)*Dd.TOTRET;