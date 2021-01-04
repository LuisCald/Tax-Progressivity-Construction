function [AGIFLOORS] = fun_AGIFLOORS(quan,Dd,YEARS,TAXUNITS);
% Dd=D;
AGIFLOORS  = zeros(length(YEARS),length(quan));


for year =YEARS(1)-min(YEARS)+1:YEARS(end)-min(YEARS)+1;
    
    Dd{year,1,1}.ret(1) = Dd{year,1,1}.ret(1)+TAXUNITS(year)-Dd{year,1,1}.TOTRET; 
    Dd{year,1,1}.cs     = (cumsum(Dd{year,1,1}.ret./sum(Dd{year,1,1}.ret))); % cumulative frequency
    Dd{year,1,1}.w      = [1-sum(diff(Dd{year,1,1}.cs));diff(Dd{year,1,1}.cs)];
    Dd{year,1,1}.TOTRET = sum(Dd{year,1,1}.ret);
    
        for j = 1:length(quan);   
            if quan(j)~=0;
            AGIFLOORS(year,j) = fun_agifloor(quan(j),Dd{year,1,1});
            else AGIFLOORS(year,j) = -1.e12;
            end   
        end
end


function [agifloor]=fun_agifloor(quan,Dd);


        PP  = (1:length(Dd.cs))';
        pos = PP((Dd.cs>quan)&([0;Dd.cs(1:end-1)]<quan));
        
        braf = Dd.bra(pos,1);
        brac = Dd.bra(pos,2);
        a    = Dd.dis(pos,1); 
        b    = Dd.dis(pos,2);
            
        csf  = Dd.cs(pos-1);
        csc  = Dd.cs(pos);
        fbar = (quan-csf)/(csc-csf);
        
        if b>0; 
          xx = betaincinv(fbar,a,b) ; 
          agifloor =(braf+xx*(brac-braf));
        else
          agifloor = braf*((1-fbar*(1-(braf/brac)^a)))^(-1/a);
        end
        
        
        

