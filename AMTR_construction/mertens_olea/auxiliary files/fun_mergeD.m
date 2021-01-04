function D = fun_mergeD(BRA,D1,D2);

    we1 = D1.w*D1.TOTRET;
    we2 = D2.w*D2.TOTRET;
        
    w1  = we1./(we1+we2);
    w2  = we2./(we1+we2);
    avagi = (D1.avagi.*w1+D2.avagi.*w2);
  
    cs    = (D1.cs*D1.TOTRET+D2.cs*D2.TOTRET)...
                                       ./(D1.TOTRET+D2.TOTRET);    
    ret   = (we1+we2);
         
     D.bra    = BRA;
     D.avagi  = avagi;
     D.cs     = cs;
     D.w      = [1-sum(diff(D.cs));diff(D.cs)];
     D.dis    = fun_Bapprox(D.avagi,D.bra,D.w);
     D.ret    = ret;
     D.TOTRET = D1.TOTRET+D2.TOTRET;
     D.TOTAGI = D1.TOTAGI+D2.TOTAGI;
     
     D.TOTRETWINC = D1.TOTRETWINC+D2.TOTRETWINC;
     D.TOTWINC = D1.TOTWINC+D2.TOTWINC;
     D.TOTRETTSEE = D1.TOTRETTSEE+D2.TOTRETTSEE;
     D.TOTTSEE = D1.TOTTSEE+D2.TOTTSEE;
     
 
     D.avti = [];
     
     if (isempty(D1.avwinc)==0)&&(isempty(D2.avwinc)==0)
     D.frac_retwinc = w1.*D1.frac_retwinc+w2.*D2.frac_retwinc; 
     D.avwinc = (D1.avwinc.*D1.frac_retwinc.*we1+D2.avwinc.*D2.frac_retwinc.*we2)./(D1.frac_retwinc.*we1+D2.frac_retwinc.*we2);
     else
     D.avwinc = [];
     D.frac_retwinc = [];
     end
     
     if (isempty(D1.avtsee)==0)&&(isempty(D2.avtsee)==0)
     D.frac_rettsee = w1.*D1.frac_rettsee+w2.*D2.frac_rettsee;
     D.avtsee = (D1.avtsee.*D1.frac_rettsee.*we1+D2.avtsee.*D2.frac_rettsee.*we2)./(D1.frac_rettsee.*we1+D2.frac_rettsee.*we2);
     else
     D.avtsee = [];
     D.frac_rettsee = [];
     end

