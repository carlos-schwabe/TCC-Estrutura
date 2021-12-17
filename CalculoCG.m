function [CG] = CalculoCG(i,perfil)
%Ponderação com o ponto de redução em (0,0)
global Out Estrut Geom
%Propriedades na seção de saida
Esp_Alma=interp1(Estrut.alma.espessura(:,1),Estrut.alma.espessura(:,2),Geom.OS(i),'previous');
Esp_Chap=interp1(Estrut.chap.espessura(:,1),Estrut.chap.espessura(:,2),Geom.OS(i),'previous');
Esp_Lam=interp1(Estrut.lam.espessura(:,1),Estrut.lam.espessura(:,2),Geom.OS(i),'previous');
A_Mesa=interp1(Estrut.mesa.area(:,1),Estrut.mesa.area(:,2),Geom.OS(i),'previous');
E_Alma=interp1(Estrut.alma.E(:,1),Estrut.alma.E(:,2),Geom.OS(i),'previous');
E_Chap=interp1(Estrut.chap.E(:,1),Estrut.chap.E(:,2),Geom.OS(i),'previous');
E_Lam=interp1(Estrut.lam.E(:,1),Estrut.lam.E(:,2),Geom.OS(i),'previous');
E_Mesa=interp1(Estrut.mesa.E(:,1),Estrut.mesa.E(:,2),Geom.OS(i),'previous');
%Primeiro ponto do Chapeado
deltaZ=perfil(1,1)-perfil(length(perfil),1);
deltaY=perfil(1,2)-perfil(length(perfil),2);
zcg=perfil(length(perfil),1)+deltaZ/2;
ycg=perfil(length(perfil),2)+deltaY/2;
AE=sqrt(deltaZ^2+deltaY^2)*(E_Chap*Esp_Chap+E_Lam*Esp_Lam);
zcgAE=sqrt(deltaZ^2+deltaY^2)*(E_Chap*Esp_Chap+E_Lam*Esp_Lam)*zcg;
ycgAE=sqrt(deltaZ^2+deltaY^2)*(E_Chap*Esp_Chap+E_Lam*Esp_Lam)*ycg;
%Varrer o chapeado + laminado
for k=2:length(perfil)-3
    deltaZ=perfil(k,1)-perfil(k-1,1);
    deltaY=perfil(k,2)-perfil(k-1,2);
    zcg=perfil(k-1,1)+deltaZ/2;
    ycg=perfil(k-1,2)+deltaY/2;
    AE=sqrt(deltaZ^2+deltaY^2)*(E_Chap*Esp_Chap+E_Lam*Esp_Lam)+AE;
    zcgAE=sqrt(deltaZ^2+deltaY^2)*(E_Chap*Esp_Chap+E_Lam*Esp_Lam)*zcg+zcgAE;
    ycgAE=sqrt(deltaZ^2+deltaY^2)*(E_Chap*Esp_Chap+E_Lam*Esp_Lam)*ycg+ycgAE;
end
%Alma
for k=length(perfil)-2:length(perfil)
    deltaZ=perfil(k,1)-perfil(k-1,1);
    deltaY=perfil(k,2)-perfil(k-1,2);
    zcg=perfil(k-1,1)+deltaZ/2;
    ycg=perfil(k-1,2)+deltaY/2;
    AE=sqrt(deltaZ^2+deltaY^2)*(E_Alma*Esp_Alma)+AE;
    zcgAE=sqrt(deltaZ^2+deltaY^2)*(E_Alma*Esp_Alma)*zcg+zcgAE;
    ycgAE=sqrt(deltaZ^2+deltaY^2)*(E_Alma*Esp_Alma)*ycg+ycgAE;
end
%Mesa Superior
AE=A_Mesa*E_Mesa+AE;
zcgAE=(E_Mesa*A_Mesa)*perfil(length(perfil),1)+zcgAE;
ycgAE=(E_Mesa*A_Mesa)*perfil(length(perfil),2)+ycgAE;
%Mesa Inferior
AE=A_Mesa*E_Mesa+AE;
zcgAE=(E_Mesa*A_Mesa)*perfil(length(perfil)-3,1)+zcgAE;
ycgAE=(E_Mesa*A_Mesa)*perfil(length(perfil)-3,2)+ycgAE;
%Calcular CG
CG(1,1)=zcgAE/AE;
CG(1,2)=ycgAE/AE;
end

