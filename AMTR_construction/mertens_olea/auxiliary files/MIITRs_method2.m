
AMTR         = zeros(length(YEARS),length(quan));
TAGI         = zeros(length(YEARS),length(quan));
TOTAGI       = zeros(length(YEARS),1);
TRET         = zeros(length(YEARS),1);

for year = [YEARS(1)-min(YEARS)+1:1978-min(YEARS)+1  1982-min(YEARS)+1:YEARS(end)-min(YEARS)+1]  
        if year==34
            break
        end
        select_year = (MR.year==year+min(YEARS)-1);
        DAT         =  MR.DAT(select_year,:);
        FS          =  MR.fs(select_year,1);
        VAR         =  MR.var(select_year,1);
       
        for fs = [2:6]; % Missing 7 
            
            if  isempty(D{year,fs,1}.avagi)==0
                
             [tbra,smtr,DD] = fun_selectS(fs,year,DAT,FS,VAR,YEARS,D);  
  
             % Numerically Integrate 
             disp(year)
             bra_floor = sort(unique([exp(linspace(log(DD.bra(2,1)), log(DD.bra(sum(DD.avti<max(tbra)),2)),1000)'); DD.bra(:,1);AGIFLOORS(year,2:end)']));
             bra_ceil  = [bra_floor(2:end);DD.bra(end,2)];            
             BRA = [bra_floor bra_ceil];
             DD  = fun_NewBrackets(BRA,DD);
            
             yt = DD.avti;
             yy = DD.avagi.*DD.w*DD.TOTRET;             
             pos  = sum((yt*ones(1,length(tbra))>=ones(length(yt),1)*tbra),2);            
             mtr    = [0 smtr(pos)];
             allagi = [D{year,fs,1}.TOTAGI-sum(yy) yy'];

             AMTR(year,1)  = AMTR(year,1)*TAGI(year,1)/(TAGI(year,1)+sum(allagi))+(mtr*allagi')/(TAGI(year,1)+sum(allagi));
             TAGI(year,1)  = TAGI(year,1)+sum(allagi);
             TRET(year,1)  = TRET(year,1)+D{year,fs,1}.TOTRET;
             
             for j = 2:length(quan);
                     sel_agi       = [0 ;DD.bra(:,1)>=AGIFLOORS(year,j)];
                     mtrQ          = mtr(sel_agi'==1);
                     allagiQ       = allagi(sel_agi'==1);

                     AMTR(year,j) = AMTR(year,j)*TAGI(year,j)/(TAGI(year,j)+sum(allagiQ))+(mtrQ*allagiQ')/(TAGI(year,j)+sum(allagiQ));
                     TAGI(year,j) = TAGI(year,j)+sum(allagiQ);
             end 
            end
             
        end 
             TOTAGI(year,1) = D{year,1,1}.TOTAGI;
             AMTR(year,1)   = AMTR(year,1)*TAGI(year,1)/(TAGI(year,1)+0.20*D{year,1,1}.TOTAGI./D{year,1,1}.TOTRET*(TAXUNITS(year,1)-D{year,1,1}.TOTRET));

end

AMTR(AMTR==0)=NaN;
TAGI(TAGI==0)=NaN;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AMTR_all = AMTR(:,1);

AMTR_top = AMTR(:,2:4);
TAGI_top = TAGI(:,2:4);
nn= ones(1,size(AMTR_top,2));

MIITRS_m2  = [YEARS AMTR_all AMTR_top];

save('MIITRS_m2','MIITRS_m2');


