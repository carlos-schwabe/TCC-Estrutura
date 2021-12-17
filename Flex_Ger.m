function [ A,B,derivz,derivy] = Flex_Ger(EIzz,EIyy,EIzy,Mz,My);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculo das tens��es normais para viga assimetrica sujeita a flex�o
% biaxial - Baseado no Coda e calculo das deforma��es, dado que a se��o pe
% assimetrica e deve-se assumir o vetor deforma��o perpendicular � linha
% neutra da se��o - Megson..
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
A=(My*EIzz+Mz*EIzy)/(EIyy*EIzz-EIzy^2); % Tensao dependente da coordenada z
B=-(Mz*EIyy+My*EIzy)/(EIyy*EIzz-EIzy^2); % Tensao dependente da coordenada y
sol=linsolve([EIzy,EIzz;EIyy,EIzy],[Mz;My]); % Deflex�es em Z e Y s�o acopladas pelo produto de inercia
derivz=sol(1);
derivy=sol(2);
end

