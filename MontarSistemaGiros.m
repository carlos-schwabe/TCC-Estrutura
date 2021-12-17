function [ A,B ] = MontarSistemaGiros( i,FluxCis)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculo valido para seção assimetrica sujeita a flexao no eixo Z e
% cortante alinhada com o eixo Y.
% Colunas 1 a k-1 da matriz A sao os fluxos incognitos
% A ultima coluna da matriz dos coeficientes A diz respeito ao giro relativo A(:,end)
% Matriz B diz Respeito A formula de equilibrio diferencial para seção
% assimetrica B(1:end-2)
% B(end-1) diz respeito ao giro nulo e B(end) diz respeito ao equilibrio de
% momentos
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global Out Geom Cargas Estrut
%Propriedades da seção
Esp_Alma=interp1(Estrut.alma.espessura(:,1),Estrut.alma.espessura(:,2),Geom.OS(i),'previous');
Esp_Chap=interp1(Estrut.chap.espessura(:,1),Estrut.chap.espessura(:,2),Geom.OS(i),'previous');
Esp_Lam=interp1(Estrut.lam.espessura(:,1),Estrut.lam.espessura(:,2),Geom.OS(i),'previous');
A_Mesa=interp1(Estrut.mesa.area(:,1),Estrut.mesa.area(:,2),Geom.OS(i),'previous');
E_Alma=interp1(Estrut.alma.E(:,1),Estrut.alma.E(:,2),Geom.OS(i),'previous');
E_Chap=interp1(Estrut.chap.E(:,1),Estrut.chap.E(:,2),Geom.OS(i),'previous');
E_Lam=interp1(Estrut.lam.E(:,1),Estrut.lam.E(:,2),Geom.OS(i),'previous');
E_Mesa=interp1(Estrut.mesa.E(:,1),Estrut.mesa.E(:,2),Geom.OS(i),'previous');
EIzz=Out.EIzz(i);
EIyy=Out.EIyy(i);
EIzy=Out.EIzy(i);


%Equilibrio diferencial

for k=1:size(FluxCis,1)-1
    A(k,1)=1; %q0
    A(k,k+1)=1; %qn
    B(k,1)=Out.Cargas.Vy(i)*(EIyy*FluxCis(k+1,2 )-EIzy*FluxCis(k+1,3 ))/(EIzz*EIyy-EIzy*EIzy) ;
end

%Momento Nulo

for k=1:size(FluxCis,1)
    A(size(FluxCis,1)+1,k)=FluxCis(k,5 ); % Contribuição do momento de cada fluxo incognito
end
A(size(FluxCis,1)+1,k+1)=0; % O giro não contribui para o momento
B(size(FluxCis,1)+1,1)=-Out.Cargas.Mt(i);; % Momentos=0

%Giro Relativo
k=1;
A(size(FluxCis,1),k)=-FluxCis(k,1 )/FluxCis(k,8 )/FluxCis(k,4 ); %q_i*L_i/G_i/t_i da referencia tem sentido contrario

for k=2:size(FluxCis,1) % Somatorio dos giros relativos
    A(size(FluxCis,1),k)=FluxCis(k,1 )/FluxCis(k,8 )/FluxCis(k,4 ); %q_i*L_i/G_i/t_i
end
A(size(FluxCis,1),k+1)=-1; % A ultima variavel é o giro, que é igual a somatoria dos %q_i*L_i/G_i/t_i
B(size(FluxCis,1),1)=0; % 0



end
