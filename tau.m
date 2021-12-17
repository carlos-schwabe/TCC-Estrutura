function [alma,chap,lam] = tau( i,fluxcis)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculo das tensções de cisalhamento atuantes, divisão do fluxo entre
% chapeado e laminado foi calculada supondo-se compatibilidade de distorção
% diferencial entre os componentes.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global Out Estrut Geom
Esp_Alma=interp1(Estrut.alma.espessura(:,1),Estrut.alma.espessura(:,2),Geom.OS(i),'previous');
Esp_Chap=interp1(Estrut.chap.espessura(:,1),Estrut.chap.espessura(:,2),Geom.OS(i),'previous');
Esp_Lam=interp1(Estrut.lam.espessura(:,1),Estrut.lam.espessura(:,2),Geom.OS(i),'previous');
G_Alma=interp1(Estrut.alma.G(:,1),Estrut.alma.G(:,2),Geom.OS(i),'previous');
G_Chap=interp1(Estrut.chap.G(:,1),Estrut.chap.G(:,2),Geom.OS(i),'previous');
G_Lam=interp1(Estrut.lam.G(:,1),Estrut.lam.G(:,2),Geom.OS(i),'previous');
%Posições por componente
alma=[Out.perfil{i}(end-3:end,:)];
chap=[Out.perfil{i}(end,:);Out.perfil{i}(1:end-4,:)];
lam=[Out.perfil{i}(end,:);Out.perfil{i}(1:end-4,:)];
%Tensoes
if Esp_Alma>0
    alma(:,3)=abs([fluxcis(end,:);fluxcis(1,:);fluxcis(1,:);fluxcis(2,:)]/Esp_Alma);
else
    alma(:,3)=0*[fluxcis(end,:);fluxcis(1:2,:)];
end

if Esp_Chap>0
    chap(:,3)=abs(fluxcis(3:end-1,:)/(Esp_Chap+G_Lam*Esp_Lam/G_Chap));
else
    chap(:,3)=0*fluxcis(3:end-1,:);
end

if Esp_Lam>0
    lam(:,3)=abs(fluxcis(3:end-1,:)/(Esp_Lam+G_Chap*Esp_Chap/G_Lam));
else
    lam(:,3)=0*fluxcis(3:end-1,:);
end

end

