function dis = fun_Bapprox(yy,bra,w) 

a = zeros(size(yy));
b = zeros(size(yy));
L = bra(:,1);
H = bra(:,2);

% Beta Distribution PDF = x^(a-1)*(1-x)^(b-1)/beta(a,b) for x in [0,1]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nb   = length(yy)-1;
xx   = (yy(1:nb)-L(1:nb))./(H(1:nb)-L(1:nb));
ww   = w(1:nb);

sel = (xx>=0.5)&(ww>0);
b(sel==1)    = 1;
a(sel==1)    = b(sel==1).*xx(sel==1)./(1-xx(sel==1));

sel = (xx<0.5)&(ww>0);
a(sel==1) = 1;
b(sel==1) = a(sel==1).*(1-xx(sel==1))./xx(sel==1);

% Bounded Pareto PDF =  for x in [L,H]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sel = (ww>0)&(b(1:nb)>1.25);
%[yy(1:nb) (L(1:nb)+H(1:nb))/2]
if sum(sel)> 0
[sol,rc]=csolve(@fun_BPareto,2.5*ones(size(a(sel==1))),[],1.e-6,100,L(sel==1),H(sel==1),yy(sel==1));
if rc==0
a(sel==1)=sol;
b(sel==1)=0;
end
end

% Pareto Tail PDF = a*L^a/x^(a+1) for x in [L,inf]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
a(end) = yy(end)/(yy(end)-L(end));

dis = [a b];

function [z,a] = fun_BPareto(x,L,H,mm);
[rows,cols]=size(x);
ncounter=1;
while ncounter<=cols; 
a     = x(:,ncounter);
z(:,ncounter) = mm - a./(a-1).*(L.^a.*H.^(1-a)-L)./((L./H).^a-1);

ncounter=ncounter+1; 
end

