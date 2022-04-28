%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file constructs the marginal payroll tax rates series 
% for 1946-2012 in Figure III
%
% Karel Mertens and Jose Montiel-Olea, ``Marginal Tax Rates and Income, 
%                                    New Time Series Evidence''
% August, 2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd C:\tax_progressivity\AMTR_construction\mertens_olea
clear all; close all; 

addpath('auxiliary files');

% Step 1  Load Input Data
%%%%%%%%%%%%%%%%%%%%%%%%%
TSERIES              = xlsread('data/TIME_SERIES_DATA.xlsx','SERIES');
TSERIES = TSERIES(1:72,:);
YEARS                = (1946:2017)';

data_SSA             = xlsread('data/SSA_rates_and_earnings.xlsx','ALLYEARS');
data_SSA = data_SSA(1:72,:);

OASDI_ceiling        = data_SSA(:,2);
HI_ceiling           = data_SSA(:,3);
OASDI_rate_EMPLOYEES = data_SSA(:,4)/100;
OASDI_rate_EMPLOYERS = data_SSA(:,5)/100;
HI_rate_EMPL2        = data_SSA(:,6)/100;
OASDI_rate_SELFEMPL  = data_SSA(:,7)/100;
HI_rate_SELFEMPL     = data_SSA(:,8)/100;

OASDIWAGES  = data_SSA(:,9);  % Total Wages subject to OASDI tax of those with wages below the ceiling
HIWAGES     = data_SSA(:,10); % Total Wages subject to Medicare tax of those with wages below the ceiling
OASDISEE    = data_SSA(:,11); % Total Self Employment Earnings subject to OASDI tax of those with earnings below the ceiling
HISEE       = data_SSA(:,12); % Total Self Employment Earnings subject to Medicare tax of those with earnings below the ceiling


% Step 2 Construct Aggregate Series from SSA data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TAXUNITS   = TSERIES(:,2)*1000;
TOTAGI     = TSERIES(:,12);
TAXRETURNS = TSERIES(:,13)*1000;
TOTINC     = TSERIES(:,3);

%   (A) Weighted by MARKET INCOME (SAEZ Income Concept)
MPTR1 = OASDIWAGES./TOTINC.*(OASDI_rate_EMPLOYEES+OASDI_rate_EMPLOYERS)./(1+OASDI_rate_EMPLOYERS+0.5*HI_rate_EMPL2)...
       + HIWAGES./TOTINC.* HI_rate_EMPL2./(1+OASDI_rate_EMPLOYERS+0.5*HI_rate_EMPL2)...
       + OASDISEE./TOTINC.*OASDI_rate_SELFEMPL+HISEE./TOTINC.*HI_rate_SELFEMPL;

%   (B) Weighted by Barro-Redlick Income Concept
AMIITR   = xlsread('AMIITRs');

MPTR2 = MPTR1.*AMIITR(:,3)./AMIITR(:,2);

% Step 3 Construct the MPTR Series for top percentiles for the missing years. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MPTR_BR = TSERIES(:,15); % Barro-Redlick series

% Load Tax Rates obtained from micro data
% (A)  Barro-Redlick Income Concept Weighting
MPTR_BR_new = TSERIES(:,16:19);

% (B)  Saez Income Concept Weighting
MPTR_S = TSERIES(:,20:23);

% Wage incomes
WINC  = xlsread('data/Real Average Wage Income.xls');
WINC=WINC(1:72,:);

TOTWINC  = (WINC(:,2:5)/1000.*(TSERIES(:,25)*ones(1,4))).*(TAXUNITS/1000*[1 0.01 0.05 0.10]);
% Entreprenuerial incomes
ENTPR  = xlsread('data/Real Average Entrepreneurial Income.xls');
TOTENTPR  = (ENTPR(:,2:5)/1000.*(TSERIES(:,25)*ones(1,4))).*(TAXUNITS/1000*[1 0.01 0.05 0.10]);


WAGES_Below_OASDI                     =  xlsread('data/Wages_below_OASDI');
share_of_wages_Below_OASDI_data       = (WAGES_Below_OASDI(:,2:4)/1000000)./TOTWINC(:,2:4);
share_of_entpr_Below_OASDI_data       = (WAGES_Below_OASDI(:,5:7)/1000000)./TOTENTPR(:,2:4);
share_of_wages_Below_HI_data          = (WAGES_Below_OASDI(:,8:10)/1000000)./TOTWINC(:,2:4);
share_of_entpr_Below_HI_data          = (WAGES_Below_OASDI(:,11:13)/1000000)./TOTENTPR(:,2:4);

% Calculate Wage Income on Tax Returns
cd 'auxiliary files'
load D
DW = D;

% Wage and Taxable SE Income for ALL returns: merge from taxable and
% nontaxable
 for year =1:1960-min(YEARS)+1;
     bra_floor = sort(unique([DW{year,1,2}.bra(:,1);D{year,1,3}.bra(:,1)]));
     bra_ceil  = [bra_floor(2:end);1.e12];   
     BRA       = [bra_floor bra_ceil];
     D1 = fun_NewBrackets(BRA,DW{year,1,2});
     D2 = fun_NewBrackets(BRA,DW{year,1,3});
     DW{year,1,1} = fun_mergeD(BRA,D1,D2);
 end
     
% Interpolate Wages and Salaries for MFJ for 1946-1953
  for year =1946-min(YEARS)+1:1953-min(YEARS)+1;
     DW{year,3,1}.avwinc       = interp1(DW{year,1,1}.avagi,DW{year,1,1}.avwinc,DW{year,3,1}.avagi);
     DW{year,3,1}.frac_retwinc = interp1(DW{1954-min(YEARS)+1,3,1}.cs,DW{1954-min(YEARS)+1,3,1}.frac_retwinc,DW{year,3,1}.cs);
     DW{year,3,1}.TOTRETWINC   = sum(DW{year,3,1}.frac_retwinc.*DW{year,3,1}.ret);
     DW{year,3,1}.TOTWINC      = sum(DW{year,3,1}.avwinc.*DW{year,3,1}.frac_retwinc.*DW{year,3,1}.ret);
  end

 % Interpolate Wages and Salaries for MFJ for 2003-2012
  for year =2003-min(YEARS)+1:2017-min(YEARS)+1;
     DW{year,3,1}.avwinc       = interp1(DW{year,1,1}.avagi,DW{year,1,1}.avwinc,DW{year,3,1}.avagi);
     DW{year,3,1}.frac_retwinc = interp1(DW{1999-min(YEARS)+1,3,1}.cs,DW{1999-min(YEARS)+1,3,1}.frac_retwinc,DW{year,3,1}.cs);
  end  
  
% Total Wages and Number of returns with Wage Income on IRS tax returns
for year =1:2017-min(YEARS)+1; 
    if isempty(DW{year,1,1}.TOTWINC)==0
    TOTWINC_SOI(year,1) = DW{year,1,1}.TOTWINC/1000;
    TOTRETWINC_SOI(year,1) =  DW{year,1,1}.TOTRETWINC/1000;
    else
        TOTWINC_SOI(year,1) =NaN;
    end
end

% Calculate Wages and Number of returns with Wage Income for Upper
% Percentiles
quan      = [0.99 0.95 0.90];
TAXUNITS  = TSERIES(:,2)*1000;
AGIFLOORS = fun_AGIFLOORS(quan,D,YEARS,TAXUNITS);
  
for year =[1946-min(YEARS)+1:1976-min(YEARS)+1 2003-min(YEARS)+1:2017-min(YEARS)+1];
    for fs = [1,3]
             DD = DW{year,fs,1};  
             bra_floor = sort(unique([DD.bra(:,1);AGIFLOORS(year,2:end)']));
             bra_ceil  = [bra_floor(2:end);DD.bra(end,2)];            
             BRA = [bra_floor bra_ceil];
             DD  = fun_NewBrackets(BRA,DD);
             allwinc  = DD.avwinc.*DD.frac_retwinc.*DD.ret;
             for j = 1:length(quan)
                sel_agi       = [DD.bra(:,1)>=AGIFLOORS(year,j)]; 
                winc(year,j,fs)     = sum(allwinc(sel_agi==1));
                retwinc(year,j,fs)  = sum(DD.frac_retwinc(sel_agi==1).*DD.ret(sel_agi==1));
             end
    end
             
end
winc(:,:,3) = min(winc(:,:,1),winc(:,:,3));
retwinc(:,:,3) = min(retwinc(:,:,1),retwinc(:,:,3));
winc(:,:,2) = winc(:,:,1)-winc(:,:,3);
retwinc(:,:,2) = retwinc(:,:,1)-retwinc(:,:,3);
avwinc1 = winc./retwinc*1000;
avwinc2 = TOTWINC(:,2:4)./retwinc(:,:,1)*1000000;

% Top Rates For 1946 - 1976: Assumptions
% 1) Primary Earners in top 10% are all above the cap
% 2) Secondary Earner in top 1%/5%/10% obtains log normal wage with
%     m=log(230%/140%/115% of average wages) and s = 0.25;
% 3) No Self-Employment Earnings below the OASDI ceiling at the top (between 1951 and 1976)

wageshareMFJ   = winc(:,:,3)./winc(:,:,1);
returnshareMFJ = retwinc(:,:,3)./retwinc(:,:,1);
RETWINC_MFJ  = returnshareMFJ.*(TAXUNITS*[0.01 0.05 0.10])/1000;
WINC_MFJ     = TOTWINC(:,2:end).*wageshareMFJ;
NEMPL        = ((1+TSERIES(:,26)./TSERIES(:,27))*ones(1,3)).*RETWINC_MFJ;
NEMPL((YEARS==1946|YEARS==1947),:) =RETWINC_MFJ((YEARS==1946|YEARS==1947),:);
%%
for j = 1:length(RETWINC_MFJ)
    if RETWINC_MFJ(j)>0
       X=(0:0.1:OASDI_ceiling(j)/1000)';
       m1 = log(TOTWINC_SOI(j,1)./TOTRETWINC_SOI(j)*2.3);
       p1=lognpdf(X,m1,0.25);
       WE1(j,1) = sum(p1.*X)/sum(p1);
       m2 = log(TOTWINC_SOI(j,1)./TOTRETWINC_SOI(j)*1.4);
       p2=lognpdf(X,m2,0.25);
       WE2(j,1) = sum(p2.*X)/sum(p2);
       m3 = log(TOTWINC_SOI(j,1)./TOTRETWINC_SOI(j)*1.15);
       p3=lognpdf(X,m3,0.25);
       WE3(j,1) = sum(p3.*X)/sum(p3);
    end
end

OASDIWAGES_TOP = (NEMPL-RETWINC_MFJ).*[WE1 WE2 WE3];
HIWAGES_TOP    =  OASDIWAGES_TOP;
INC_TOP        = TSERIES(:,4:6);


for j=1:3
MPTR_TOP_pre1976(:,j) = OASDIWAGES_TOP(:,j)./INC_TOP(:,j).*(OASDI_rate_EMPLOYEES+OASDI_rate_EMPLOYERS)./(1+OASDI_rate_EMPLOYERS+0.5*HI_rate_EMPL2)...
       + HIWAGES_TOP(:,j)./INC_TOP(:,j).* HI_rate_EMPL2./(1+OASDI_rate_EMPLOYERS+0.5*HI_rate_EMPL2);
end

% Merge Series
sel = (isnan(MPTR_S(:,1))==0)&(YEARS<1977);
Y   = MPTR_S(sel,:);
XX  = [MPTR1 MPTR_TOP_pre1976];
X   = XX(sel,:);
b = [ones(length(X),1) X]\Y;
Yhat = [ones(length(MPTR_TOP_pre1976),1) XX]*b;
MPTR_S((isnan(MPTR_S(:,1)))&(YEARS<1966),:)=Yhat((isnan(MPTR_S(:,1)))&(YEARS<1966),:);
MPTR_S((YEARS==1946)|(YEARS==1947),:)=0;

%% Top Rates For 2009-2012
%%%%%%%%%%%%%%%%%%%%%%%%%%
sel = (YEARS>1993)&(YEARS<2009);
Y = [share_of_wages_Below_OASDI_data(sel,:)];
XX = [log(TOTWINC(:,2:4)./(TAXUNITS/1000*[0.01 0.05 0.10])) log(OASDI_ceiling/1000)];
X = XX(sel,:);
b = [ones(length(X),1) X]\Y;
Y1hat = [ones(length(XX),1) XX]*b;
share_of_wages_Below_OASDI_data(YEARS>2008,:) = Y1hat(YEARS>2008,:);

sel = (YEARS>1993)&(YEARS<2009);
Y = [share_of_entpr_Below_OASDI_data(sel,:)];
XX = [log(TOTENTPR(:,2:4)./(TAXUNITS/1000*[0.01 0.05 0.10])) log(OASDI_ceiling/1000)];
X = XX(sel,:);
b = [ones(length(X),1) X]\Y;
Y2hat = [ones(length(XX),1) XX]*b;
share_of_entpr_Below_OASDI_data(YEARS>2008,:) = Y2hat(YEARS>2008,:);

sel = (YEARS>1993)&(YEARS<2009);
Y = [share_of_wages_Below_HI_data(sel,:)];
XX = [log(TOTWINC(:,2:4)./(TAXUNITS/1000*[0.01 0.05 0.10]))];
X = XX(sel,:);
b = [ones(length(X),1) X]\Y;
Y3hat = [ones(length(XX),1) XX]*b;
share_of_wages_Below_HI_data(YEARS>2008,:) = Y3hat(YEARS>2008,:);

sel = (YEARS>1993)&(YEARS<2009);
Y = [share_of_entpr_Below_HI_data(sel,:)];
XX = [log(TOTENTPR(:,2:4)./(TAXUNITS/1000*[0.01 0.05 0.10]))];
X = XX(sel,:);
b = [ones(length(X),1) X]\Y;
Y4hat = [ones(length(XX),1) XX]*b;
share_of_entpr_Below_HI_data(YEARS>2008,:) = Y4hat(YEARS>2008,:);


OASDIWAGES_TOP = share_of_wages_Below_OASDI_data.*TOTWINC(:,2:4);
HIWAGES_TOP = share_of_wages_Below_HI_data.*TOTWINC(:,2:4);
OASDISEE_TOP = share_of_entpr_Below_OASDI_data.*TOTENTPR(:,2:4);
HISEE_TOP  = share_of_entpr_Below_HI_data.*TOTENTPR(:,2:4);

for j = 1:3
MPTR_TOP_post1993(:,j) = OASDIWAGES_TOP(:,j)./INC_TOP(:,j).*(OASDI_rate_EMPLOYEES+OASDI_rate_EMPLOYERS)./(1+OASDI_rate_EMPLOYERS+0.5*HI_rate_EMPL2)...
       + HIWAGES_TOP(:,j)./INC_TOP(:,j).* HI_rate_EMPL2./(1+OASDI_rate_EMPLOYERS+0.5*HI_rate_EMPL2)...
       + OASDISEE_TOP(:,j)./INC_TOP(:,j).*OASDI_rate_SELFEMPL+HISEE_TOP(:,j)./INC_TOP(:,j).*HI_rate_SELFEMPL;
end

MPTR_S(YEARS>2008,2:4) = MPTR_TOP_post1993(YEARS>2008,1:3);


AMPTR1 = [YEARS MPTR1 MPTR_S(:,2:end)];
AMPTR2 = [YEARS MPTR2];

s1  = TSERIES(:,4)./TSERIES(:,3);
s5  = TSERIES(:,5)./TSERIES(:,3);
s10 = TSERIES(:,6)./TSERIES(:,3);

AMPTR_5to1  = (AMPTR1(:,4)-s1./s5.*AMPTR1(:,3)).*s5./(s5-s1);
AMPTR_10to5 = (AMPTR1(:,5)-s5./s10.*AMPTR1(:,4)).*s10./(s10-s5);
AMPTR_b99   = (AMPTR1(:,2)-s1./1.*AMPTR1(:,3)).*1./(1-s1);
AMPTR_b90   = (AMPTR1(:,2)-s10./1.*AMPTR1(:,5)).*1./(1-s10);


AMPTR=[AMPTR2 AMPTR1(:,2:end) AMPTR_5to1 AMPTR_10to5 AMPTR_b99 AMPTR_b90]; % BR then Saez
xlswrite('AMPTRs',AMPTR);

