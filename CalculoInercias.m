function Inercia=CalculoInercias(i,perfil);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculo dos momentos de inercia nos eixos Y e Z
% Desconsidera-se a inercia propria de elementos de chapeado e da mesa
% ( Maior Dimensao dos elementos de chapeado e mesa < 0.01*c )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global Out Geom Cargas Estrut
%Propriedades na seção de saida
Esp_Alma=interp1(Estrut.alma.espessura(:,1),Estrut.alma.espessura(:,2),Geom.OS(i),'previous');
Esp_Chap=interp1(Estrut.chap.espessura(:,1),Estrut.chap.espessura(:,2),Geom.OS(i),'previous');
Esp_Lam=interp1(Estrut.lam.espessura(:,1),Estrut.lam.espessura(:,2),Geom.OS(i),'previous');
A_Mesa=interp1(Estrut.mesa.area(:,1),Estrut.mesa.area(:,2),Geom.OS(i),'previous');
E_Alma=interp1(Estrut.alma.E(:,1),Estrut.alma.E(:,2),Geom.OS(i),'previous');
E_Chap=interp1(Estrut.chap.E(:,1),Estrut.chap.E(:,2),Geom.OS(i),'previous');
E_Lam=interp1(Estrut.lam.E(:,1),Estrut.lam.E(:,2),Geom.OS(i),'previous');
E_Mesa=interp1(Estrut.mesa.E(:,1),Estrut.mesa.E(:,2),Geom.OS(i),'previous');
CG=Out.CG(i,:);
%Calcular Inercia
%Primeiro ponto do Chapeado
deltaZ=perfil(1,1)-perfil(length(perfil),1);
deltaY=perfil(1,2)-perfil(length(perfil),2);
zcg=perfil(length(perfil),1)+deltaZ/2-CG(1,1);
ycg=perfil(length(perfil),2)+deltaY/2-CG(1,2);
EIzz=sqrt(deltaZ^2+deltaY^2)*(E_Chap*Esp_Chap*ycg^2+E_Lam*Esp_Lam*ycg^2);
EIyy=sqrt(deltaZ^2+deltaY^2)*(E_Chap*Esp_Chap*zcg^2+E_Lam*Esp_Lam*zcg^2);
EIzy=sqrt(deltaZ^2+deltaY^2)*(E_Chap*Esp_Chap*ycg*zcg+E_Lam*Esp_Lam*ycg*zcg);
%Varrer o chapeado + laminado
for k=2:length(perfil)-3
    deltaZ=perfil(k,1)-perfil(k-1,1);
    deltaY=perfil(k,2)-perfil(k-1,2);
    zcg=perfil(k-1,1)+deltaZ/2-CG(1,1);
    ycg=perfil(k-1,2)+deltaY/2-CG(1,2);
    EIzz=sqrt(deltaZ^2+deltaY^2)*(E_Chap*Esp_Chap*ycg^2+E_Lam*Esp_Lam*ycg^2)+EIzz;
    EIyy=sqrt(deltaZ^2+deltaY^2)*(E_Chap*Esp_Chap*zcg^2+E_Lam*Esp_Lam*zcg^2)+EIyy;
    EIzy=sqrt(deltaZ^2+deltaY^2)*(E_Chap*Esp_Chap*ycg*zcg+E_Lam*Esp_Lam*ycg*zcg)+EIzy;
end
%Alma
for k=length(perfil)-2:length(perfil)
    deltaZ=perfil(k,1)-perfil(k-1,1);
    deltaY=perfil(k,2)-perfil(k-1,2);
    zcg=perfil(k-1,1)+deltaZ/2-CG(1,1);
    ycg=perfil(k-1,2)+deltaY/2-CG(1,2);
    EIzz=sqrt(deltaZ^2+deltaY^2)*(E_Alma*Esp_Alma*ycg^2)+EIzz;
    EIyy=sqrt(deltaZ^2+deltaY^2)*(E_Alma*Esp_Alma*zcg^2)+EIyy;
    EIzy=sqrt(deltaZ^2+deltaY^2)*(E_Alma*Esp_Alma*ycg*zcg)+EIzy;
    EIzz=E_Alma*Esp_Alma*deltaY^3/12+EIzz;
    EIyy=E_Alma*Esp_Alma^3/12*deltaY+EIyy;
end
%Mesa Superior
zcg=perfil(length(perfil),1)-CG(1,1);
ycg=perfil(length(perfil),2)-CG(1,2);
EIzz=(E_Mesa*A_Mesa*ycg^2)+EIzz;
EIyy=(E_Mesa*A_Mesa*zcg^2)+EIyy;
EIzy=(E_Mesa*A_Mesa*ycg*zcg)+EIzy;
%Mesa Inferior
zcg=perfil(length(perfil)-3,1)-CG(1,1);
ycg=perfil(length(perfil)-3,2)-CG(1,2);
EIzz=(E_Mesa*A_Mesa*ycg^2)+EIzz;
EIyy=(E_Mesa*A_Mesa*zcg^2)+EIyy;
EIzy=(E_Mesa*A_Mesa*ycg*zcg)+EIzy;
%Calcular CG
Inercia(1)=EIzz;
Inercia(2)=EIyy;
Inercia(3)=EIzy;

end

