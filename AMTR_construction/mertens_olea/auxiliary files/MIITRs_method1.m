MR.DAT   = data_MR(:,6:end);
MR.year  = data_MR(:,1);
MR.fs    = data_MR(:,3);   % Filing Status   1:ALL      2:SINGLE      3:MFJ       4:MFS       5:HOH      36: MFJ+SURV    24: MFS+SINGLE
MR.var   = data_MR(:,5);   % Variable        1:BRACKET  2: MARG RATE  3:TAXTYPE   4:NUMBER OF RETURNS   5:AGI    6: SURCHARGE    


AMTR         = zeros(length(YEARS),length(quan));
TAGI         = zeros(length(YEARS),length(quan));
TOTAGI       = zeros(length(YEARS),1);
TRET         = zeros(length(YEARS),1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for year = YEARS(1)-min(YEARS)+1:YEARS(end)-min(YEARS)+1;

        select_year = (MR.year==year+min(YEARS)-1);
        DAT         =  MR.DAT(select_year,:);
        FS          =  MR.fs(select_year,1);
        VAR         =  MR.var(select_year,1);

        ggg= 1;
        for fs = [36 2 24 4 5];
            %BRACKETS    =  DAT((FS==fs)& (VAR==1),:);
            MMTR        =  DAT((FS==fs)& (VAR==2),:);
            TAXTYPE     =  DAT((FS==fs)& (VAR==3),:);
            RETURNS     =  DAT((FS==fs)& (VAR==4),:);
            ALLAGI      =  DAT((FS==fs)& (VAR==5),:);
            SURCHARGE   =  DAT((FS==fs)& (VAR==6),:);    
            
            if isempty(ALLAGI(isnan(ALLAGI)==0))==0;         
            % 1. Select Returns under Regular Tax Rate Schedules 
                %BRA   = BRACKETS(:,TAXTYPE==0);
                MTR   = MMTR(:,TAXTYPE==0);
                SC    = SURCHARGE(:,TAXTYPE==0);
                AGI_TAXED       = ALLAGI(:,TAXTYPE==0);
                RETURNS_TAXED   = RETURNS(:,TAXTYPE==0);
                AGI_OTHERTAXED  = ALLAGI(:,TAXTYPE~=0);
                RETURNS_OTHERTAXED = RETURNS(:,TAXTYPE~=0);

                sel_MTR = isnan(MTR)==0;
                mtr = MTR(sel_MTR);
                    if isempty(SC)~=1 % Add Surcharges and Reductions
                        mtr = mtr.*(1+SC(sel_MTR));
                    end
                    
                allagi_taxed   = AGI_TAXED(sel_MTR);
                ret_taxed      = RETURNS_TAXED(sel_MTR);               
                cs_taxed       = cumsum(ret_taxed./sum(ret_taxed));
                avagi_taxed    = allagi_taxed./ret_taxed;
             
                DD  = fun_selectD(fs,year,D,1); % Select AGI Distribution

                
                allagi_untaxed = (DD.TOTAGI-sum(AGI_OTHERTAXED(isnan(AGI_OTHERTAXED)==0))-sum(allagi_taxed(mtr~=0)));
                ret_untaxed    = (DD.TOTRET-sum(RETURNS_OTHERTAXED(isnan(RETURNS_OTHERTAXED)==0))-sum(ret_taxed(mtr~=0)));
                                                
                allagi         = [allagi_untaxed allagi_taxed(mtr~=0)];
                ret            = [ret_untaxed  ret_taxed(mtr~=0)];
                mtr            = [0 mtr(mtr~=0)]; 
             
            % 2. Compute AMTRs 
                                
                AMTR(year,1)  = AMTR(year,1)*TAGI(year,1)/(TAGI(year,1)+sum(allagi))+(mtr*allagi')/(TAGI(year,1)+sum(allagi));
                TAGI(year,1)  = TAGI(year,1)+sum(allagi);
                TRET(year,1)  = TRET(year,1)+sum(ret);
                               
                for j = 2:length(quan);                                           
                    [mtrQ,allagiQ]=fun_getmtrQ(AGIFLOORS(year,j),ret,allagi,mtr,DD);
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

MIITRS_m1  = [YEARS AMTR_all AMTR_top];
save('MIITRS_m1','MIITRS_m1');



