function [DD]  = fun_selectD(fs,year,D,type)

%           % Married Filing Jointly and Surviving Spouses 
            if (fs == 36) & (isempty(D{year,3,type}.avagi)==0) & (isempty(D{year,6,type}.avagi)==0)
                     disp("top")
                     bra_floor = sort(unique([D{year,3,type}.bra(:,1);D{year,6,type}.bra(:,1)]));
                     bra_ceil  = [bra_floor(2:end);D{year,3,type}.bra(end,2)];
                     BRA       = [bra_floor bra_ceil];
                                          
                     D3 = fun_NewBrackets(BRA,D{year,3,type});                     
                     D6 = fun_NewBrackets(BRA,D{year,6,type});                    
                     DD = fun_mergeD(BRA,D3,D6);

            elseif (year==70 | year==71 | year==72) & (fs == 36)
                     disp("mid")
                     DD = D{year,3,type};  % in FitDistributions.m, fs==36 are converted to 3
                                                             
            elseif (fs == 36)  % Surviving Spouses: missing 1979-2002
                     disp("last")
                     DD = D{year,3,type};
                     DD.TOTRET = D{year,3,type}.TOTRET+D{year,6,type}.TOTRET;
                     DD.TOTAGI = D{year,3,type}.TOTAGI+D{year,6,type}.TOTAGI; 

            end       
                      
           % Singles
           if fs == 2  
               DD = Dpast(year,2,type,D);
               DD.dis    = fun_Bapprox(DD.avagi,DD.bra,DD.w);                            
           end
           
           % Singles and Married filing separately (1959-1969)
           if fs == 24 
                     bra_floor = sort(unique([D{year,2,type}.bra(:,1);D{year,4,type}.bra(:,1)]));
                     bra_ceil  = [bra_floor(2:end);D{year,2,type}.bra(end,2)];
                     BRA       = [bra_floor bra_ceil];
                     
                     D1 = fun_NewBrackets(BRA,D{year,2,type});
                     D2 = fun_NewBrackets(BRA,D{year,4,type});
                     DD = fun_mergeD(BRA,D1,D2);
           end
           
           % Married Filing Separately
           if fs == 4 & (isempty(D{year,4,type}.avagi)==0)
                DD = D{year,4,type};
           elseif  fs == 4 & (isempty(D{year,7,type}.avagi)==0) % (1979-2002)
                DD  = D{year,7,type} ;
                DD.TOTRET = D{year,4,type}.TOTRET;
                DD.TOTAGI = D{year,4,type}.TOTAGI;
           elseif fs == 4 % 1979-1981
                     DD = Dpast(year,4,type,D);
                     DD.dis    = fun_Bapprox(DD.avagi,DD.bra,DD.w);
           end
           
           % Heads of Household
           if fs == 5 & (isempty(D{year,5,type}.avagi)==0)
                DD = D{year,5,type};
           elseif  fs == 5 & (isempty(D{year,7,type}.avagi)==0) % (1979-2002)
                DD  = D{year,7,type} ;
                DD.TOTRET = D{year,5,type}.TOTRET;
                DD.TOTAGI = D{year,5,type}.TOTAGI; 
           elseif fs == 5 % 1979-1981
                     DD = Dpast(year,5,type,D);         
                     DD.dis    = fun_Bapprox(DD.avagi,DD.bra,DD.w);
           end
                      
                DD.ret    = DD.ret*DD.TOTRET/sum(DD.ret);
                DD.avagi  = DD.avagi*DD.TOTAGI./(sum(DD.avagi.*DD.ret));
end

 function DD = Dpast(year,fs,type,D)
          
                     D1 = D{year,fs,type};                     
                     BRA = D{year,fs,type}.bra;

                         j= 0;
                         ll=0;
                         while isempty(D1.avagi)==1  % Missing: 1979-1981
                         D1  = D{year-j,fs,type} ;
                         BRA = D{year-j,fs,type}.bra;
                         ll = j;
                         j=j+1;
                         end
                         D1.TOTRET = D{year-ll,fs,type}.TOTRET./D{year-ll,fs,1}.TOTRET*D{year,fs,1}.TOTRET;
                         D1.TOTAGI = D{year-ll,fs,type}.TOTAGI./D{year-ll,fs,1}.TOTAGI*D{year,fs,1}.TOTAGI;
                         creep = (D1.TOTAGI./D1.TOTRET)/(D{year-ll,fs,type}.TOTAGI./D{year-ll,fs,type}.TOTRET);
                         D1.avagi  = D1.avagi*creep;
                             D1.avwinc = D1.avwinc*creep;
                             D1.avtsee = D1.avtsee*creep;
                         D1.bra    = D1.bra*creep;
                         D1.bra(1,1) = BRA(1,1);
                         D1.bra(end,2) = BRA(end,2);
                         DD = fun_NewBrackets(BRA,D1);
                              
 end
           
           
           