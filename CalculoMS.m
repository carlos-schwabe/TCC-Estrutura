function [ FluxCis ] = CalculoMS(i,MatrizIdeal)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calculo dos Momentos estaticos e contribuições adimensionalizadas de
% forças e momento de cada fluxo idealizado
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global Out Geom Cargas Estrut
%Propriedades da seção
G_Alma=interp1(Estrut.alma.G(:,1),Estrut.alma.G(:,2),Geom.OS(i),'previous');
Esp_Alma=interp1(Estrut.alma.espessura(:,1),Estrut.alma.espessura(:,2),Geom.OS(i),'previous');
G_Chap=interp1(Estrut.chap.G(:,1),Estrut.chap.G(:,2),Geom.OS(i),'previous');
Esp_Chap=interp1(Estrut.chap.espessura(:,1),Estrut.chap.espessura(:,2),Geom.OS(i),'previous');
G_Lam=interp1(Estrut.lam.G(:,1),Estrut.lam.G(:,2),Geom.OS(i),'previous');
Esp_Lam=interp1(Estrut.lam.espessura(:,1),Estrut.lam.espessura(:,2),Geom.OS(i),'previous');
perfil=Out.perfil{i};
CG=Out.CG(i,:);
%Fluxo de referencia
k=1;
VetorDelta=-[perfil(end-2,1)-perfil(end-1,1),perfil(end-2,2)-perfil(end-1,2),0];
VetorR=[perfil(end-2,1)-perfil(end-3,1),perfil(end-2,2)-perfil(end-3,2),0];
VetorM=cross(VetorR,VetorDelta);
FluxCis(k,1)=sqrt((perfil(end-1,1)-perfil(end-2,1))^2+(perfil(end-1,2)-perfil(end-2,2))^2);
FluxCis(k,2)=0;
FluxCis(k,3)=0;
FluxCis(k,4)=Esp_Alma;
FluxCis(k,5)=VetorM(3);
FluxCis(k,6)=VetorDelta(1);
FluxCis(k,7)=VetorDelta(2);
FluxCis(k,8)=G_Alma;

%Fluxo na alma superior
k=k+1;
VetorDelta=-[perfil(end,1)-perfil(end-1,1),perfil(end,2)-perfil(end-1,2),0];
VetorR=[perfil(end-1,1)-perfil(end-3,1),perfil(end-1,2)-perfil(end-3,2),0];
VetorM=cross(VetorR,VetorDelta);
FluxCis(k,1)=sqrt((perfil(end,1)-perfil(end-1,1))^2+(perfil(end,2)-perfil(end-1,2))^2);
FluxCis(k,2)=MatrizIdeal(end-1,4)*(perfil(end-1,2)-CG(1,2))+FluxCis(k-1,2);
FluxCis(k,3)=MatrizIdeal(end-1,4)*(perfil(end-1,1)-CG(1,1))+FluxCis(k-1,3);
FluxCis(k,4)=Esp_Alma;
FluxCis(k,5)=VetorM(3);
FluxCis(k,6)=VetorDelta(1);
FluxCis(k,7)=VetorDelta(2);
FluxCis(k,8)=G_Alma;

%Fluxo primeiro ponto do chapeado
k=k+1;
VetorDelta=-[perfil(k-2,1)-perfil(end,1),perfil(k-2,2)-perfil(end,2),0];
VetorR=[perfil(end,1)-perfil(end-3,1),perfil(end,2)-perfil(end-3,2),0];
VetorM=cross(VetorR,VetorDelta);
FluxCis(k,1)=sqrt((perfil(k-2,1)-perfil(end,1))^2+(perfil(k-2,2)-perfil(end,2))^2);
FluxCis(k,2)=MatrizIdeal(end,4)*(perfil(end,2)-CG(1,2))+FluxCis(k-1,2);
FluxCis(k,3)=MatrizIdeal(end,4)*(perfil(end,1)-CG(1,1))+FluxCis(k-1,3);
FluxCis(k,4)=Esp_Chap+Esp_Lam;
FluxCis(k,5)=VetorM(3);
FluxCis(k,6)=VetorDelta(1);
FluxCis(k,7)=VetorDelta(2);
FluxCis(k,8)=(G_Chap*Esp_Chap+G_Lam*Esp_Lam)/(Esp_Lam+Esp_Chap);

%Fluxo no resto do chapeado
for k=4:length(perfil)-1
    VetorDelta=-[perfil(k-2,1)-perfil(k-3,1),perfil(k-2,2)-perfil(k-3,2),0];
    VetorR=[perfil(k-3,1)-perfil(end-3,1),perfil(k-3,2)-perfil(end-3,2),0];
    VetorM=cross(VetorR,VetorDelta);
    FluxCis(k,1)=sqrt((perfil(k-2,1)-perfil(k-3,1))^2+(perfil(k-2,2)-perfil(k-3,2))^2);
    FluxCis(k,2)=MatrizIdeal(k-3,4)*(perfil(k-3,2)-CG(1,2))+FluxCis(k-1,2);
    FluxCis(k,3)=MatrizIdeal(k-3,4)*(perfil(k-3,1)-CG(1,1))+FluxCis(k-1,3);
    FluxCis(k,4)=Esp_Chap+Esp_Lam;
    FluxCis(k,5)=VetorM(3);
    FluxCis(k,6)=VetorDelta(1);
    FluxCis(k,7)=VetorDelta(2);
    FluxCis(k,8)=(G_Chap*Esp_Chap+G_Lam*Esp_Lam)/(Esp_Lam+Esp_Chap);
end

%Fluxo na alma inferior
k=k+1;
VetorDelta=-[perfil(k-2,1)-perfil(k-3,1),perfil(k-2,2)-perfil(k-3,2),0];
VetorR=[perfil(k-3,1)-perfil(end-3,1),perfil(k-3,2)-perfil(end-3,2),0];
VetorM=cross(VetorR,VetorDelta);
FluxCis(k,1)=sqrt((perfil(k-2,1)-perfil(k-3,1))^2+(perfil(k-2,2)-perfil(k-3,2))^2);
FluxCis(k,2)=MatrizIdeal(k-3,4)*(perfil(k-3,2)-CG(1,2))+FluxCis(k-1,2);
FluxCis(k,3)=MatrizIdeal(k-3,4)*(perfil(k-3,1)-CG(1,1))+FluxCis(k-1,3);
FluxCis(k,4)=Esp_Alma;
FluxCis(k,5)=VetorM(3);
FluxCis(k,6)=VetorDelta(1);
FluxCis(k,7)=VetorDelta(2);
FluxCis(k,8)=G_Alma;

end

