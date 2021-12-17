function [ CA ] = CalcCA( pos,corda,Xba)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calcular a linha do CA da asa 3D
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=size(pos):-1:1
    diff1(i,1)=-corda(i)*Xba(i)+corda(i)^2/4;
    diff2(i,1)=-corda(i);
end


for i=size(pos)-1:-1:1
    int1(i,1)=trapz(pos(i:size(pos)),diff1(i:size(diff1)));
    int2(i,1)=trapz(pos(i:size(pos)),diff2(i:size(diff2)));
end
CA(:,1)=int1./int2;
CA(end+1,1)=-corda(end)/4+Xba(end);
end