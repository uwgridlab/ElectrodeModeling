R = 1;
rho = 1;
I = 1;
r = [10^-1:0.001:10^1];

% pt
pt = pt_function(I,rho,r);

% cc
cc = cc_function(I,rho,r,R);

% cv 
cv = cv_function(I,rho,r,R);

%%
figure
loglog(r,pt)
hold on
loglog(r,cv)
loglog(r,cc)


legend
title('Point Electrode, Constant Voltage, Constant Current Electrode Models')
xlabel('Distance in terms of electrode radius')
ylabel('Electric potential (arbitrary units)')
%%
function V = pt_function(I,rho,r)
V = zeros(size(r,2),1);

V = (I.*rho)./(2.*pi.*r);
end


function V = cv_function(I,rho,r,R)
V = zeros(size(r,2),1);
logicalR = r<=R;
V_o = I/rho;
V(logicalR) = V_o;
%V(~logicalR) = ((2.*I)./(rho.*pi).*asin(R./r(r>R)));
V(~logicalR) = ((I*rho)/(2*R).*asin(R./r(r>R)));

end



function V = cc_function(I,rho,r,R)
V = zeros(size(r,2),1);
%V(~logicalR) = ((2.*I)./(rho.*pi).*asin(R./r(r>R)));
V = ((I.*rho)/(2.*R).*(1./(r.^2)).* besselj(1,r.*R));
end