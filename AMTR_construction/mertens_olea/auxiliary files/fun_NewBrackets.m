function D = fun_NewBrackets(BRA,Dd);
    
    bra_floor    = BRA(:,1);
    bra_ceil     = BRA(:,2);
    bra_floor_Dd = Dd.bra(:,1);    
    bra_ceil_Dd  = Dd.bra(:,2); 

    
    avagi  = NaN*zeros(size(bra_floor));
    w      = NaN*zeros(size(bra_floor));
    if isempty(Dd.avti)==0
    avti   = NaN*zeros(size(bra_floor));
    w_ti   = NaN*zeros(size(bra_floor));
    end
    
        if isempty(Dd.avwinc)==0
        avwinc   = NaN*zeros(size(bra_floor));
        frac_retwinc    = NaN*zeros(size(bra_floor));
        end
        if isempty(Dd.avtsee)==0
        avtsee   = NaN*zeros(size(bra_floor));
        frac_rettsee    = NaN*zeros(size(bra_floor));
        end
        
        
     for j =1:length(bra_floor);
          PP   = 1:length(bra_floor_Dd);
          pos  = PP((bra_floor_Dd<=bra_floor(j))&(bra_ceil_Dd>bra_floor(j)));
          braf = bra_floor_Dd(pos); 
          brac = bra_ceil_Dd(pos);

          a = Dd.dis(pos,1); b = Dd.dis(pos,2);
          
        if (braf==bra_floor(j))&(brac==bra_ceil(j));
            avagi(j) = Dd.avagi(pos);
            w(j)     = Dd.w(pos);
            if isempty(Dd.avti)==0
            avti(j)  = Dd.avti(pos);
            w_ti(j)  = Dd.w_ti(pos);
            end
            
                if isempty(Dd.avwinc)==0
                avwinc(j)  = Dd.avwinc(pos);
                frac_retwinc(j)  = Dd.frac_retwinc(pos);
                end
                if isempty(Dd.avtsee)==0
                avtsee(j)  = Dd.avtsee(pos);
                frac_rettsee(j)  = Dd.frac_rettsee(pos);
                end
            
        elseif bra_floor(j)<bra_floor_Dd(1);
            avagi(j) = 0;
            w(j)     = 0;
            if isempty(Dd.avti)==0
            avti(j)  = 0;
            w_ti(j)  = 0;
            end
                if isempty(Dd.avwinc)==0
                avwinc(j)  = 0;
                frac_retwinc(j)  = 0;
                end
                if isempty(Dd.avtsee)==0
                avtsee(j)  = 0;
                frac_rettsee(j)  = 0;
                end
            
        else     
               
                if b==0 & a==0;
                avagi(j)   = 0;
                w(j)       = 0;
                elseif b>0;                    
                L = (bra_floor(j)-braf)/(brac-braf);
                H = (min(bra_ceil(j),brac)-braf)/(brac-braf);
                fbarh      =  betainc(H,a,b);
                fbarl      =  betainc(L,a,b);
                cm         =  1/(fbarh-fbarl)*(betainc(H,a+1,b)-betainc(L,a+1,b))*beta(a+1,b)/beta(a,b);
                avagi(j)   =  braf+cm*(brac-braf);
                w(j)       = (fbarh-fbarl)*Dd.w(pos);               
                                 
                else
                something = [1 2 3 4];
%                 disp(something(1))
%                 disp(a)
%                 disp(something(2))
%                 disp(braf)
%                 disp(something(3))
%                 disp(bra_ceil(j))
%                 disp(something(4))
%                 disp(brac)
                fbarh      =  (1-braf^a*min(bra_ceil(j),brac)^(-a))/(1-(braf/brac)^a);
                fbarl      =  (1-braf^a*min(bra_ceil(j),bra_floor(j))^(-a))/(1-(braf/brac)^a); 
                avagi(j)   =  1/(fbarh-fbarl)*a/(1-a)*braf^a/(1-(braf/brac)^a)*(min(bra_ceil(j),brac)^(1-a)-bra_floor(j)^(1-a));                   
                w(j)       =  (fbarh-fbarl)*Dd.w(pos);
                
               end
                
                if isempty(Dd.avti)==0
                avti(j)   = Dd.avti(pos)*avagi(j)./Dd.avagi(pos);
                w_ti(j)   = Dd.w_ti(pos)*w(j)./Dd.w(pos); 
                end 
                    if isempty(Dd.avwinc)==0
                    avwinc(j)  = Dd.avwinc(pos)*avagi(j)./Dd.avagi(pos);
                    frac_retwinc(j)  = Dd.frac_retwinc(pos)*avagi(j)./Dd.avagi(pos);
                    end
                    if isempty(Dd.avtsee)==0
                    avtsee(j)  = Dd.avtsee(pos)*avagi(j)./Dd.avagi(pos);
                    frac_rettsee(j)  = Dd.frac_rettsee(pos)*avagi(j)./Dd.avagi(pos);
                    end
                
                 jj=1;
                    while bra_ceil(j)>brac;
                        braf = bra_floor_Dd(pos+jj);
                        brac = bra_ceil_Dd(pos+jj);
                        a = Dd.dis(pos+jj,1); b = Dd.dis(pos+jj,2);    
                        
                        if b==0 && a==0;
                            ww  = 0;
                            avagi(j) = avagi(j);
                        elseif b>0
                            L = 0;
                            H = (min(bra_ceil(j),brac)-braf)/(brac-braf); 
                            fbarh      =  betainc(H,a,b);
                            fbarl      =  0;
                            cm         =  1/(fbarh-fbarl)*(betainc(H,a+1,b)-betainc(L,a+1,b))*beta(a+1,b)/beta(a,b);
                            ww         = (betainc(H,a,b)-betainc(L,a,b))*Dd.w(pos+jj);
                            avagi(j)   = (w(j)*avagi(j)+ww*(braf+cm*(brac-braf)))/max((w(j)+ww),eps);
                        else
                            fbarh    =  (1-braf^a*min(bra_ceil(j),brac)^(-a))/(1-(braf/brac)^a);
                            fbarl    = 0; 
                            ww       = (fbarh-fbarl)*Dd.w(pos+jj);
                            avagi(j) = (w(j)*avagi(j)+ww*1/(fbarh-fbarl)*(a/(1-a)*braf^a/(1-(braf/brac)^a)*(min(bra_ceil(j),brac)^(1-a)-braf^(1-a))))/max((w(j)+ww),eps);
                        end
                        
                            
                            if isempty(Dd.avti)==0
                            avti(j)  = (w(j)*avti(j)+ww*Dd.avti(pos+jj)*avagi(j)./Dd.avagi(pos+jj))/max((w(j)+ww),eps);
                            w_ti(j)  = (w(j)*w_ti(j)+ww*Dd.w_ti(pos+jj))/max((w(j)+ww),eps);
                            end
                            if isempty(Dd.avwinc)==0
                            avwinc(j)  = (w(j)*avwinc(j)+ww*Dd.avwinc(pos+jj)*avagi(j)./Dd.avagi(pos+jj))/max((w(j)+ww),eps);
                            frac_retwinc(j)  = (w(j)*frac_retwinc(j)+ww*Dd.frac_retwinc(pos+jj)*avagi(j)./Dd.avagi(pos+jj))/max((w(j)+ww),eps);
                            end
                            if isempty(Dd.avtsee)==0
                            avtsee(j)  = (w(j)*avtsee(j)+ww*Dd.avtsee(pos+jj)*avagi(j)./Dd.avagi(pos+jj))/max((w(j)+ww),eps);
                            frac_rettsee(j)  = (w(j)*frac_rettsee(j)+ww*Dd.frac_rettsee(pos+jj)*avagi(j)./Dd.avagi(pos+jj))/max((w(j)+ww),eps);
                            end
                            
                            
                            w(j)     = w(j)+ww;
                        
                        jj=jj+1;
                    end
      
                    
         end      
              
     end
    
D.bra    = BRA;
D.avagi  = avagi;
D.avagi(w==0)=0;
D.w      = w;
D.cs     = cumsum(D.w);

    if isempty(Dd.avti)==0
    D.avti   = max(avti,0);
    D.avti(w==0)=0;
    D.w_ti   = w_ti;
    D.w_ti(w==0)=0;
    D.cs_ti  = cumsum(D.w_ti);
    D.TOTRET_TI = Dd.TOTRET_TI;
    D.TOTTI  = Dd.TOTTI; 
    else 
    D.avti   = [];
    D.TOTRET_TI = [];
    D.TOTTI  = [];
    end
    
    if isempty(Dd.avwinc)==0
    D.avwinc   = max(avwinc,0);
    D.avwinc(w==0)=0;
    D.frac_retwinc   = max(frac_retwinc,0);
    D.frac_retwinc(w==0)=0;
    D.avwinc(D.frac_retwinc==0)=0;
    D.TOTRETWINC = Dd.TOTRETWINC;
    D.TOTWINC  = Dd.TOTWINC; 
    else 
    D.avwinc   = [];
    D.frac_retwinc = [];
    D.TOTRETWINC = [];
    D.TOTWINC  = []; 
    end
    
    if isempty(Dd.avtsee)==0
    D.avtsee   = max(avtsee,0);
    D.avtsee(w==0)=0;
    D.frac_rettsee   = max(frac_rettsee,0);
    D.frac_rettsee(w==0)=0;
    D.avtsee(D.frac_rettsee==0)=0;
    D.TOTRETTSEE = Dd.TOTRETTSEE;
    D.TOTTSEE  = Dd.TOTTSEE; 
    else 
    D.avtsee   = [];
    D.frac_rettsee = [];
    D.TOTRETTSEE = [];
    D.TOTTSEE  = []; 
    end

    
    
    
    
    
D.TOTRET = Dd.TOTRET;
D.TOTAGI = Dd.TOTAGI;
D.ret    = D.w*D.TOTRET;
    
    
% if abs(1-sum(D.w))> 1.e-6
%     abs(1-sum(D.w))
%     display('Problems')
%    pause 
% end



