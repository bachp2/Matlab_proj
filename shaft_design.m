clc
clear
%v-m diagrams
x=linspace(0,750,10000)./1000;
vxz=3*(x>0)-9*(x>.5)+6*(x>.75);
vxy=4.8*(x>0)-6*(x>.15)+1.2*(x>.75);
mxz = cumtrapz(x,vxz);
mxy = cumtrapz(x,vxy);
subplot(221);
area(x,vxz);
title('V-M diagram in xz plane')
xlabel('x(m)')
ylabel('V(KN)')
y1 = ylim;
subplot(223);
area(x,mxz);
xlabel('x(m)')
ylabel('M(KN*m)')
y2 = ylim;
subplot(222);
area(x,vxy);
title('V-M diagram in xy plane')
xlabel('x(m)')
ylabel('V(KN)')
ylim(y1);
subplot(224);
area(x,mxy);
xlabel('x(m)')
ylabel('M(KN*m)')
ylim(y2);
max(mxy)
%static analysis
syms d
assume(d>0);
nstatic = 2.2;
I = pi*d^4/64;
J = pi*d^4/32;
M = 1.53;%KNm
T =  .45;%KNm
Kt = 1; Kts = 1;
for mm = 1:2
    sigmaBEND = Kt*M*d/2/I;%KPa
    tauTOR  = Kts*T*d/2/J;%KPa
    sigmax = sigmaBEND;
    tauxy  = tauTOR;
    taumax = ((sigmax/2)^2+tauxy^2)^.5;
    sigma1 = sigmax/2 + taumax;
    sigma2 = sigmax/2 - taumax;
    %using stainless steel
    Sy  = 1000*1000;Sut = 2240*1000;%kPa
    Seprime = 700*1000;
    ka = .7;
    kb = .81;
    kc = 1;
    kd = 1.018;
    Se = ka*kb*kc*kd*Seprime;
    %Se = 318.75*1000;%kPa
    sigma1 = simplify(sigma1);
    sigma2 = simplify(sigma2);
    dvalue = double(solve(sigma1-sigma2 == Sy/nstatic, d));%m
    %fillet radius
    r = 3.5e-3;
    D = dvalue+2*r;
    %since
%     r/dvalue
%     D/dvalue
    %thus
    Kt  = 1.6;
    Kts = 1.35;
end
dvalue

%%fatigue analysis
clearvars -except M T d Se Sut Sy Kt Kts sigmaBEND I
syms d;
Ma = M;
Mm = 0;
Tm = T;
Ta = 0;
q = .9;
Kf = 1 + q*(Kt-1);
Kfs= 1;
nfatigue = 1.1;
A = (4*(Kf*Ma)^2+3*(Kfs*Ta)^2)^.5;
B = (4*(Kf*Mm)^2+3*(Kfs*Tm)^2)^.5;

DEGoodman      = 1/nfatigue == 16/(pi*d^3)*(A/Se + B/Sut);
DEGerber       = 1/nfatigue == 8*A/(pi*d^3*Se)*(1+(1+(2*B*Se/(A*Sut))^2)^.5);
DEASMEElliptic = 1/nfatigue == 16/(pi*d^3)*(A^2/Se^2+B^2/Sy^2)^.5;
dvalue = double(vpa(solve(DEGerber, d)));%m
dvalue
d = dvalue;
sigmaBEND = subs(sigmaBEND);
A = pi/4*dvalue^2;
I = subs(I);
% estimate cycles to failure
f  = .773;
aa = (f*Sut)^2/Se;
bb = -1/3*log10(f*Sut/Se);
N  = int32((sigmaBEND/aa)^(1/bb))
%critical speed
E = 195*10^9;
g = 9.81;
omega = double((pi/.75)^2*sqrt(E*I/(A*7.6e3)))*30/pi*.6*.15
%%fracture analysis
KIc = 62;%MPa*m^.5
betac = 1.3;
ac = double((KIc/(betac*sigmaBEND/1000))^2/pi)*1000%mm
a  = 0.5
beta = 1.1;
KI = double(beta*sigmaBEND/1000*sqrt(pi*a/1000))
nfracture = KIc/KI
nfracture = 2;
KIc = nfracture*KI


