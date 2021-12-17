function [alma,mesa,chap,lam] = sigma( i,A,B )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculo das tensções normais para viga assimetrica sujeita a flexão
% biaxial - Baseado no Coda
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global Out Estrut Geom
Esp_Alma=interp1(Estrut.alma.espessura(:,1),Estrut.alma.espessura(:,2),Geom.OS(i),'previous');
Esp_Chap=interp1(Estrut.chap.espessura(:,1),Estrut.chap.espessura(:,2),Geom.OS(i),'previous');
Esp_Lam=interp1(Estrut.lam.espessura(:,1),Estrut.lam.espessura(:,2),Geom.OS(i),'previous');
A_Mesa=interp1(Estrut.mesa.area(:,1),Estrut.mesa.area(:,2),Geom.OS(i),'previous');
E_Alma=interp1(Estrut.alma.E(:,1),Estrut.alma.E(:,2),Geom.OS(i),'previous');
E_Chap=interp1(Estrut.chap.E(:,1),Estrut.chap.E(:,2),Geom.OS(i),'previous');
E_Lam=interp1(Estrut.lam.E(:,1),Estrut.lam.E(:,2),Geom.OS(i),'previous');
E_Mesa=interp1(Estrut.mesa.E(:,1),Estrut.mesa.E(:,2),Geom.OS(i),'previous');
%Posições por componente
alma=[Out.perfil{i}(end-3:end,:)];
mesa=[Out.perfil{i}(end-3,:);Out.perfil{i}(end,:)];
chap=[Out.perfil{i}(end,:);Out.perfil{i}(1:end-4,:)];
lam=[Out.perfil{i}(end,:);Out.perfil{i}(1:end-4,:)];
%Tensoes
if Esp_Alma>0
    alma(:,3)=E_Alma*(A*(alma(:,1)-Out.CG(i,1))+B*(alma(:,2)-Out.CG(i,2)));
else
    alma(:,3)=0*(A*(alma(:,1)-Out.CG(i,1))+B*(alma(:,2)-Out.CG(i,2)));
end

if A_Mesa > 0
    mesa(:,3)=E_Mesa*(A*(mesa(:,1)-Out.CG(i,1))+B*(mesa(:,2)-Out.CG(i,2)));
else
    mesa(:,3)=0*(A*(mesa(:,1)-Out.CG(i,1))+B*(mesa(:,2)-Out.CG(i,2)));
end

if Esp_Chap>0
    chap(:,3)=E_Chap*(A*(chap(:,1)-Out.CG(i,1))+B*(chap(:,2)-Out.CG(i,2)));
else
    chap(:,3)=0*(A*(chap(:,1)-Out.CG(i,1))+B*(chap(:,2)-Out.CG(i,2)));
end

if Esp_Lam>0
    lam(:,3)=E_Lam*(A*(lam(:,1)-Out.CG(i,1))+B*(lam(:,2)-Out.CG(i,2)));
else
    lam(:,3)=0*(A*(lam(:,1)-Out.CG(i,1))+B*(lam(:,2)-Out.CG(i,2)));
end

end

