function [tbra,smtr,DD] = fun_selectS(fs,year,DAT,FS,VAR,YEARS,D)

              DD = D{year,fs,2};

            if fs==2 & year<=1969-min(YEARS)+1;
                TBRA        =  DAT((FS==24)& (VAR==1),:);
                MMTR        =  DAT((FS==24)& (VAR==2),:);
                SURCHARGE   =  DAT((FS==24)& (VAR==6),:);
                
            elseif fs==2; 
                TBRA        =  DAT((FS==2)& (VAR==1),:);
                MMTR        =  DAT((FS==2)& (VAR==2),:); 
                SURCHARGE   =  DAT((FS==2)& (VAR==6),:);
            end
            
            if fs==4 & year<=1969-min(YEARS)+1;
                TBRA        =  DAT((FS==24)& (VAR==1),:);
                MMTR        =  DAT((FS==24)& (VAR==2),:);
                SURCHARGE   =  DAT((FS==24)& (VAR==6),:);
            elseif fs==4; 
                TBRA        =  DAT((FS==4)& (VAR==1),:);
                MMTR        =  DAT((FS==4)& (VAR==2),:);  
                SURCHARGE   =  DAT((FS==4)& (VAR==6),:);
            end
            
            if fs==3|fs==6;
                TBRA        =  DAT((FS==36)& (VAR==1),:);
                MMTR        =  DAT((FS==36)& (VAR==2),:); 
                SURCHARGE   =  DAT((FS==36)& (VAR==6),:);
            end
            
            if fs==5;
                TBRA        =  DAT((FS==5)& (VAR==1),:);
                MMTR        =  DAT((FS==5)& (VAR==2),:);
                SURCHARGE   =  DAT((FS==5)& (VAR==6),:);
            end
            
                tbra        =  TBRA(isnan(TBRA)==0)/1000;
                smtr        =  MMTR(isnan(TBRA)==0); 
                                
                if isempty(SURCHARGE)~=1 % Add 1968-1970 Surcharge, 1946-1950, 1981 Reductions
                        SC          =  SURCHARGE(isnan(TBRA)==0);
                        smtr =smtr.*(1+SC);
                end