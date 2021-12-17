function [ A,B ] = MontarSistemaCC( i,FluxCis)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculo valido para seção assimetrica sujeita a flexao no eixo Z e
% cortante alinhada com o eixo Y.
% Colunas 1 a k-1 da matriz A sao os fluxos incognitos
% A ultima coluna da matriz dos coeficientes A diz respeito a distancia do CC
% ao ponto de redução A(:,end)
% Matriz B diz Respeito A formula de equilibrio diferencial para seção
% assimetrica B(1:end-2)
% B(end-1) diz respeito ao giro nulo e B(end) diz respeito ao equilibrio de
% momentos
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global Out Geom Cargas Estrut
%Propriedades da seção
EIzz=Out.EIzz(i);
EIyy=Out.EIyy(i);
EIzy=Out.EIzy(i);
%Equilibrio diferencial

for k=1:size(FluxCis,1)-1
    A(k,1)=1; %q0
    A(k,k+1)=1; %qn
    B(k,1)=(EIyy*FluxCis(k+1,2 )-EIzy*FluxCis(k+1,3 ))/(EIzz*EIyy-EIzy*EIzy) ;
end

%Giro Nulo

k=1;
A(size(FluxCis,1),k)=-FluxCis(k,1 )/FluxCis(k,8 )/FluxCis(k,4 ); %q_i*L_i/G_i/t_i da referencia tem sentido contrario

for k=2:size(FluxCis,1) % Somatorio dos giros relativos
    A(size(FluxCis,1),k)=FluxCis(k,1 )/FluxCis(k,8 )/FluxCis(k,4 ); %q_i*L_i/G_i/t_i
end
A(size(FluxCis,1),k+1)=0; % A ultima variavel é a distancia do ponto de redução ao CC, ela nao contribui para o giro.
B(size(FluxCis,1),1)=0; % Giro=0

%Momento Nulo

for k=1:size(FluxCis,1)
    A(size(FluxCis,1)+1,k)=FluxCis(k,5 ); % Contribuição do momento de cada fluxo incognito
end
A(size(FluxCis,1)+1,k+1)=-1; % Momento da cortante é anti-horario
B(size(FluxCis,1)+1,1)=0; % Momentos=0

end

