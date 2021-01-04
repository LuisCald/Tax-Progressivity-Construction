function [mtrQ,allagiQ]=fun_getmtrQ(agifloor,ret,allagi,mtr,DD)


                    avagi       = allagi./ret;
                    [avagi,I]   = sort(avagi);
                    mtr         = mtr(I);
                    ret         = ret(I);
                    cs          = cumsum(ret./sum(ret)); 
                    
                    PP          = 1:length(mtr);
                    PPP         = 1:length(DD.cs); 
                    posh        = PP(cumsum(avagi>agifloor)==1);
                    if isempty(posh)==1;  posh=max(PP); end
                                        
                        if posh<max(PP);                                                                                          
                          for j=[1 2];
                          Dposh  = PPP((DD.cs(:,1)<=cs(posh-j+1))&([DD.cs(2:end);1]>cs(posh-j+1)))+1;                           
                          braf   = DD.bra(Dposh,1); brac = DD.bra(Dposh,2);
                          a      = DD.dis(Dposh,1); b = DD.dis(Dposh,2);
                          fbarh=(cs(posh-j+1)-DD.cs(Dposh-1))/(DD.cs(Dposh)-DD.cs(Dposh-1));
                              if b>0
                                            avagi_cutoff(3-j) = braf+ betaincinv(fbarh,a,b)*(brac-braf);
                              else 

                                            avagi_cutoff(3-j) = ((1+fbarh*(braf^a-brac^a)/brac^a)/braf^a)^(-1/a);                               
                              end
                          end
                       
                                             
                        elseif posh==max(PP);
                        avagi_cutoff(2) = DD.bra(end,2);
                        Dposh  = PPP((DD.cs(:,1)<=cs(posh-1))&([DD.cs(2:end);1]>cs(posh-1)))+1;
                        braf   = DD.bra(Dposh,1); brac = DD.bra(Dposh,2);
                        a      = DD.dis(Dposh,1); b = DD.dis(Dposh,2);
                          fbarh=(cs(posh-1)-DD.cs(Dposh-1))/(DD.cs(Dposh)-DD.cs(Dposh-1));
                              if b>0
                                            avagi_cutoff(1) = braf+ betaincinv(fbarh,a,b)*(brac-braf);
                              else 

                                            avagi_cutoff(1) = ((1+fbarh*(braf^a-brac^a)/brac^a)/braf^a)^(-1/a);                               
                              end

                        end
                        
                            if agifloor>avagi_cutoff(1)
                            L      = agifloor;
                            H      = avagi_cutoff(2);
                            allagiQ   = [fun_Dintegrate(L,H,DD) allagi(PP>posh)];
                            mtrQ   = mtr(PP>=posh);
                            else 
                            L1      = agifloor;
                            H1      = avagi_cutoff(1);
                            L2      = avagi_cutoff(1);
                            H2      = avagi_cutoff(2);                           
                            allagiQ   = [fun_Dintegrate(L1,H1,DD) fun_Dintegrate(L2,H2,DD) allagi(PP>posh)]; 
                            mtrQ   = mtr(PP>=posh-1);
                            end





% 
%                             PP         =  1:length(avagi);
%                             posh       =  PP(cumsum(avagi>agifloor)==1);
% %                             avagih     =  avagi(posh);
% %                             poshh      =  PP(cumsum(avagi>agifloor)==2);
% %                             avagihh    =  avagi(poshh);
%                         
%                             if (posh~=max(PP))& isempty(posh)==0;
%                             PPP    = 1:length(DD.cs);
%                             
%                                 Dposh  = PPP((DD.cs(:,1)<=cs(posh))&([DD.cs(2:end);1]>cs(posh)))+1;                           
%                                 braf   = DD.bra(Dposh,1); brac = DD.bra(Dposh,2);
%                                 if DD.dis(Dposh)==0
%                                     avagi_cutoffh = braf+(cs(posh)-DD.cs(Dposh-1))/(DD.cs(Dposh)-DD.cs(Dposh-1))*(brac-braf);
%                                 else a = DD.dis(Dposh);
%                                     fbarh=(cs(posh)-DD.cs(Dposh-1))/(DD.cs(Dposh)-DD.cs(Dposh-1));
%                                     avagi_cutoffh = ((1+fbarh*(braf^a-brac^a)/brac^a)/braf^a)^(-1/a);                               
%                                 end
%                                 
%                                 
%                                 Dposh  = PPP((DD.cs(:,1)<=cs(posh-1))&([DD.cs(2:end);1]>cs(posh-1)))+1;                           
%                                 braf   = DD.bra(Dposh,1); brac = DD.bra(Dposh,2);
%                                 if DD.dis(Dposh)==0
%                                     avagi_cutoffl = braf+(cs(posh)-DD.cs(Dposh-1))/(DD.cs(Dposh)-DD.cs(Dposh-1))*(brac-braf);
%                                 else a = DD.dis(Dposh);
%                                     fbarh=(cs(posh-1)-DD.cs(Dposh-1))/(DD.cs(Dposh)-DD.cs(Dposh-1));
%                                     avagi_cutoffl = ((1+fbarh*(braf^a-brac^a)/brac^a)/braf^a)^(-1/a);                               
%                                 end
%                             
%                             else  (posh==max(PP)) | isempty(posh)==0;
%                                posh=max(PP);
%                                PPP    = 1:length(DD.cs);
%                                Dposh  = max(PPP);
%                                avagi_cutoffh = max(DD.bra(:,2)); 
%                                                                
%                                 braf   = DD.bra(Dposh-1,1); brac = DD.bra(Dposh-1,2);
%                                 if DD.dis(Dposh-1)==0
%                                     avagi_cutoffl = braf+(cs(posh-1)-DD.cs(Dposh-2))/(DD.cs(Dposh-1)-DD.cs(Dposh-2))*(brac-braf);
%                                 else a = DD.dis(Dposh);
%                                     fbarh=(cs(posh-1)-DD.cs(Dposh-2))/(DD.cs(Dposh-1)-DD.cs(Dposh-2));
%                                     avagi_cutoffl = ((1+fbarh*(braf^a-brac^a)/brac^a)/braf^a)^(-1/a);                               
%                                 end
%                             end
%                            
%                             if agifloor>avagi_cutoffl
%                             L      = agifloor;
%                             H      = avagi_cutoffh;
%                             agiQ   = [fun_Dintegrate(L,H,DD) allagi(PP>posh)];
%                             mtrQ   = mtr(PP>=posh);
%                             else 
%                             L1      = agifloor;
%                             H1      = avagi_cutoffl;
%                             L2      = avagi_cutoffl;
%                             H2      = avagi_cutoffh;    
%                             agiQ   = [fun_Dintegrate(L1,H1,DD) fun_Dintegrate(L2,H2,DD) allagi(PP>posh)]; 
%                             mtrQ   = mtr(PP>=posh-1);
%                             end
