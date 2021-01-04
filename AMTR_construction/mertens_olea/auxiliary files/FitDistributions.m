
DAGI.DAT             = data_DAGI(:,9:end);
DAGI.year            = data_DAGI(:,1);
DAGI.fs              = data_DAGI(:,3);   % Filing Status   1:ALL      2:SINGLE     3:MFJ       4:MFS    5:HOH   6:SURV   7: MFS+HOH+SURV   36: MFJ+SURV
DAGI.type            = data_DAGI(:,5);   % Type of Return  1:ALL      2:TAXABLE    3:NONTAXABLE                  
DAGI.var             = data_DAGI(:,7);   % Variable        1:BRACKET  2:NUMBER OF RETURNS  3:AGI  4:TOTAL TAX  
                                                           %5:TAXABLE INCOME 51:NUMBER OF RETURNS WITH TAXABLE INCOME 
                                                           %6:NUMBER OF RETURNS WITH WAGE INCOME 7:WAGE INCOME
                                                           %8:NUMBER OF RETURNS WITH SE TAX 9: SE TAX 
DAGI.totals          = data_DAGI(:,8);

YEARS = (min([DAGI.year]):max([DAGI.year]))';            

for year = YEARS(1)-min(YEARS)+1:YEARS(end)-min(YEARS)+1;
        select_year = (DAGI.year==year+min(YEARS)-1);
        DAT    = DAGI.DAT(select_year,:);
        FS     = DAGI.fs(select_year,1);
           FS(FS==36)=3; %Note For 1963-1972 wage and SE income for MFJ also includes surviving spouses
                         % For the more recent years, 2015 and 2016 that
                         % is, filing status 3 and 6 are combined. So here,
                         % 36 becomes 3. 
        VAR    = DAGI.var(select_year,1);
        TYPE   = DAGI.type(select_year,1);
        TOTALS = DAGI.totals(select_year,1);
        
   for fs = [1:7];  % Indexes Filing Status                 
        for type =  1:3;   % Indexes Type of Returns             
        BRA_FLOOR       = DAT((FS==fs)& (VAR==1) & (TYPE==type),:);
        RETURNS         = DAT((FS==fs)& (VAR==2) & (TYPE==type),:); 
        AGI             = DAT((FS==fs)& (VAR==3) & (TYPE==type),:);
        RETURNS_WINC    = DAT((FS==fs)& (VAR==6) & (TYPE==type),:); 
        WINC            = DAT((FS==fs)& (VAR==7) & (TYPE==type),:);
        RETURNS_SETAX   = DAT((FS==fs)& (VAR==8) & (TYPE==type),:); 
        SETAX           = DAT((FS==fs)& (VAR==9) & (TYPE==type),:);
        
        agi             = AGI((isnan(AGI)==0)&(RETURNS~=0));
        ret             = RETURNS((isnan(AGI)==0)&(RETURNS~=0));        
        bra_floor       = BRA_FLOOR((isnan(AGI)==0)&(RETURNS~=0))/1000;
        
        
        bra_floor(bra_floor==0)= -1.e4;
        bra_ceil               = [bra_floor(2:end) 1.e12];                
        D{year ,fs,type}.bra   = [bra_floor' bra_ceil'];   % brackets
        D{year ,fs,type}.avagi = (agi./ret)';              % average AGI within bracket         
        D{year ,fs,type}.cs    = (cumsum(ret./sum(ret)))'; % cumulative frequency
        D{year ,fs,type}.w     = [1-sum(diff(D{year ,fs,type}.cs));diff(D{year ,fs,type}.cs)]; %weights
        D{year ,fs,type}.ret   = ret';                     % number of returns
        D{year ,fs, type}.TOTRET = TOTALS((FS==fs)& (VAR==2) & (TYPE==type));
        D{year ,fs, type}.TOTAGI = TOTALS((FS==fs)& (VAR==3) & (TYPE==type));        
                   
            if isempty(agi)==0              
            D{year ,fs,type}.dis   = fun_Bapprox(D{year ,fs,type}.avagi,D{year ,fs,type}.bra,D{year ,fs,type}.w);
            else D{year ,fs,type}.dis = [];
            end
            
            % Taxable Income
            if type == 2 
                    TI              = DAT((FS==fs)& (VAR==5)  & (TYPE==type),:);
                    RETURNS_TI      = DAT((FS==fs)& (VAR==51) & (TYPE==type),:);          
                    ti              = TI((isnan(AGI)==0)&(RETURNS~=0));
                    ret_ti          = RETURNS_TI((isnan(AGI)==0)&(RETURNS~=0));  
                                        
                        avti        = ti./max(ret_ti,eps);          % average TI within bracket                                   
                        D{year ,fs,type}.avti     = avti';          % average taxable income within bracket
                        D{year ,fs,type}.ret_ti   = ret_ti';        % number of returns                          
                            if sum(isnan(avti)==1)~=0
                            D{year ,fs,type}          = fun_interpX(D{year ,fs,type});    
                            end
                        D{year ,fs,type}.cs_ti    = cumsum(ret_ti./sum(ret_ti))'; % cumulative frequency
                        D{year ,fs,type}.w_ti     = [1-sum(diff(D{year ,fs,type}.cs_ti));diff(D{year ,fs,type}.cs_ti)]; %weights                                            
                        D{year ,fs, type}.TOTRET_TI = TOTALS((FS==fs)& (VAR==51) & (TYPE==type));
                        D{year ,fs, type}.TOTTI     = TOTALS((FS==fs)& (VAR==5) & (TYPE==type));                        
            else 
                        D{year ,fs, type}.TOTRET_TI = [];
                        D{year ,fs, type}.TOTTI     = [];
                        D{year ,fs, type}.avti      = [];
 
            end
            
            % Wage Income
            if isempty(WINC)==0               
            D{year ,fs, type}.TOTRETWINC  = TOTALS((FS==fs)& (VAR==6) & (TYPE==type));
            D{year ,fs, type}.TOTWINC     = TOTALS((FS==fs)& (VAR==7) & (TYPE==type));
            
            winc            = WINC((isnan(AGI)==0)&(RETURNS~=0));
            ret_winc        = RETURNS_WINC((isnan(AGI)==0)&(RETURNS~=0)); 
            avwinc          = zeros(size(winc));
            avwinc(ret_winc~=0) = winc(ret_winc~=0)./ret_winc(ret_winc~=0);
            frac_retwinc    = ret_winc./ret;
            frac_retwinc(ret_winc==0) =0;

            D{year ,fs,type}.frac_retwinc   = frac_retwinc';  % fraction of returns with wage income
            D{year ,fs,type}.avwinc         = avwinc'; % average wage income conditional on having wage income.
                            if sum(isnan(winc)==1)~=0
                            D{year ,fs,type}          = fun_interpW(D{year ,fs,type});    
                            end
            else
            D{year ,fs,type}.avwinc = [];
            D{year ,fs,type}.frac_retwinc = [];
            D{year ,fs, type}.TOTRETWINC  = [];
            D{year ,fs, type}.TOTWINC     = [];                    
            end
            
            D{year ,fs,type}.avtsee = [];
            D{year ,fs,type}.frac_rettsee = [];
            D{year ,fs, type}.TOTRETTSEE  = [];
            D{year ,fs, type}.TOTTSEE     = [];                    
                      
        end
   end
end

% Merge Distributions for Each Filing Status:  Taxable and Nontaxable 1950-1969;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 for year =YEARS(1)-min(YEARS)+1:1969-min(YEARS)+1;
  for fs = 2:6;
     
      if isempty(D{year,fs,2}.avagi)~=1
     bra_floor = sort(unique([D{year,fs,2}.bra(:,1);D{year,fs,3}.bra(:,1)]));
     bra_ceil  = [bra_floor(2:end);1.e12];
     BRA       = [bra_floor bra_ceil];
     D1 = fun_NewBrackets(BRA,D{year,fs,2});
     D2 = fun_NewBrackets(BRA,D{year,fs,3});
     D{year ,fs,1} = fun_mergeD(BRA,D1,D2);
     D{year ,fs,1}.dis    = fun_Bapprox(D{year ,fs,1}.avagi,D{year ,fs,1}.bra,D{year ,fs,1}.w);
      end
      
  end         
 end
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 for year =1979-min(YEARS)+1:1981-min(YEARS)+1; % interpolate missing totals 1979-1981
  for fs = 2:6;
    if isnan(D{year ,fs,2}.TOTRET)        
        D{year ,fs,2}.TOTRET = D{year ,fs,1}.TOTRET*D{year,1,2}.TOTRET/D{year,1,1}.TOTRET;
        D{year ,fs,2}.TOTAGI = D{year ,fs,1}.TOTAGI*D{year,1,2}.TOTAGI/D{year,1,1}.TOTAGI;
    end
  end         
 end 

 for year =1982-min(YEARS)+1:2002-min(YEARS)+1;  % interpolate missing totals 1982-2002
  for fs = [4 5 6];
    if isnan(D{year ,fs,2}.TOTRET)        
        D{year ,fs,2}.TOTRET = D{year ,fs,1}.TOTRET*D{year,7,2}.TOTRET/D{year ,7,1}.TOTRET;
        D{year ,fs,2}.TOTAGI = D{year ,fs,1}.TOTAGI*D{year,7,2}.TOTAGI/D{year ,7,1}.TOTAGI;
    end
  end         
 end 
 
 save('D','D');
 

