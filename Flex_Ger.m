function [ A,B,derivz,derivy] = Flex_Ger(EIzz,EIyy,EIzy,Mz,My);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculo das tensções normais para viga assimetrica sujeita a flexão
% biaxial - Baseado no Coda e calculo das deformações, dado que a seção pe
% assimetrica e deve-se assumir o vetor deformação perpendicular à linha
% neutra da seção - Megson..
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
A=(My*EIzz+Mz*EIzy)/(EIyy*EIzz-EIzy^2); % Tensao dependente da coordenada z
B=-(Mz*EIyy+My*EIzy)/(EIyy*EIzz-EIzy^2); % Tensao dependente da coordenada y
sol=linsolve([EIzy,EIzz;EIyy,EIzy],[Mz;My]); % Deflexões em Z e Y são acopladas pelo produto de inercia
derivz=sol(1);
derivy=sol(2);
end

