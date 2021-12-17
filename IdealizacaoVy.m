function [ MatrizIdeal ] = IdealizacaoVy(i)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Idealização método Proença assumindo cortante somente no eixo Y
% Para a idealização assume-se esforços em apenas um eixo de cada vez, de
% forma que a linha elastica dependa
% apenas das caracteristicas geometricas da seção.
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
EIzz=Out.EIzz(i);
EIyy=Out.EIyy(i);
EIzy=Out.EIzy(i);
perfil=Out.perfil{i};
CG=Out.CG(i,:);
deltinha=EIzz*EIyy-(EIzy^2);
%Varrer tensao em todos os pontos
for k=1:length(perfil)
    MatrizIdeal(k,1)=perfil(k,1);
    MatrizIdeal(k,2)=perfil(k,2);
    MatrizIdeal(k,3)=(EIzy*(perfil(k,1)-CG(1,1))-EIyy*(perfil(k,2)-CG(1,2)))/deltinha;
end
%Computar areas idealizadas segundo ponto do chapeado + lam
Lin=sqrt((perfil(1,1)-perfil(length(perfil),1))^2+(perfil(1,2)-perfil(length(perfil),2))^2);
Lout=sqrt((perfil(1,1)-perfil(2,1))^2+(perfil(1,2)-perfil(2,2))^2);
MatrizIdeal(1,4)=E_Chap*Esp_Chap*Lin/6*(2+MatrizIdeal(size(MatrizIdeal,1),3)/(MatrizIdeal(1,3))); %Contribuição segmento anterior de chapeado
MatrizIdeal(1,4)=MatrizIdeal(1,4)+E_Chap*Esp_Chap*Lout/6*(2+MatrizIdeal(2,3)/(MatrizIdeal(1,3))); %Contribuição segmento posterior de chapeado
MatrizIdeal(1,4)=MatrizIdeal(1,4)+E_Lam*Esp_Lam*Lin/6*(2+MatrizIdeal(size(MatrizIdeal,1),3)/(MatrizIdeal(1,3))); %Contribuição segmento anterior de laminado
MatrizIdeal(1,4)=MatrizIdeal(1,4)+E_Lam*Esp_Lam*Lout/6*(2+MatrizIdeal(2,3)/(MatrizIdeal(1,3))); %Contribuição segmento posterior de laminado

%Computar Areas no Chapeado + Laminado
for k=2:length(perfil)-4
    Lin=sqrt((perfil(k,1)-perfil(k-1,1))^2+(perfil(k,2)-perfil(k-1,2))^2);
    Lout=sqrt((perfil(k,1)-perfil(k+1,1))^2+(perfil(k,2)-perfil(k+1,2))^2);
    MatrizIdeal(k,4)=E_Chap*Esp_Chap*Lin/6*(2+MatrizIdeal(k-1,3)/(MatrizIdeal(k,3))); %Contribuição segmento anterior de chapeado
    MatrizIdeal(k,4)=MatrizIdeal(k,4)+E_Chap*Esp_Chap*Lout/6*(2+MatrizIdeal(k+1,3)/(MatrizIdeal(k,3))); %Contribuição segmento posterior de chapeado
    MatrizIdeal(k,4)=MatrizIdeal(k,4)+E_Lam*Esp_Lam*Lin/6*(2+MatrizIdeal(k-1,3)/(MatrizIdeal(k,3))); %Contribuição segmento anterior de laminado
    MatrizIdeal(k,4)=MatrizIdeal(k,4)+E_Lam*Esp_Lam*Lout/6*(2+MatrizIdeal(k+1,3)/(MatrizIdeal(k,3))); %Contribuição segmento posterior de laminado
end

%Computar Area do ultimo ponto do chapeado + laminado
k=k+1;
Lin=sqrt((perfil(k,1)-perfil(k-1,1))^2+(perfil(k,2)-perfil(k-1,2))^2);
Lout=sqrt((perfil(k,1)-perfil(k+1,1))^2+(perfil(k,2)-perfil(k+1,2))^2);
MatrizIdeal(k,4)=E_Chap*Esp_Chap*Lin/6*(2+MatrizIdeal(k-1,3)/(MatrizIdeal(k,3))); %Contribuição segmento anterior de chapeado
MatrizIdeal(k,4)=MatrizIdeal(k,4)+E_Lam*Esp_Lam*Lin/6*(2+MatrizIdeal(k-1,3)/(MatrizIdeal(k,3))); %Contribuição segmento anterior de laminado
MatrizIdeal(k,4)=MatrizIdeal(k,4)+E_Alma*Esp_Alma*Lout/6*(2+MatrizIdeal(k+1,3)/(MatrizIdeal(k,3))); %Contribuição segmento posterior de alma
MatrizIdeal(k,4)=MatrizIdeal(k,4)+E_Mesa*A_Mesa; %Contribuição da mesa

%Computar Area no primeiro ponto da alma
k=k+1;
Lin=sqrt((perfil(k,1)-perfil(k-1,1))^2+(perfil(k,2)-perfil(k-1,2))^2);
Lout=sqrt((perfil(k,1)-perfil(k+1,1))^2+(perfil(k,2)-perfil(k+1,2))^2);
MatrizIdeal(k,4)=E_Alma*Esp_Alma*Lin/6*(2+MatrizIdeal(k-1,3)/(MatrizIdeal(k,3))); %Contribuição segmento anterior de alma
MatrizIdeal(k,4)=MatrizIdeal(k,4)+E_Alma*Esp_Alma*Lout/6*(2+MatrizIdeal(k+1,3)/(MatrizIdeal(k,3))); %Contribuição segmento posterior de alma

%Computar Area no segundo ponto da alma
k=k+1;
Lin=sqrt((perfil(k,1)-perfil(k-1,1))^2+(perfil(k,2)-perfil(k-1,2))^2);
Lout=sqrt((perfil(k,1)-perfil(k+1,1))^2+(perfil(k,2)-perfil(k+1,2))^2);
MatrizIdeal(k,4)=E_Alma*Esp_Alma*Lin/6*(2+MatrizIdeal(k-1,3)/(MatrizIdeal(k,3))); %Contribuição segmento anterior de alma
MatrizIdeal(k,4)=MatrizIdeal(k,4)+E_Alma*Esp_Alma*Lout/6*(2+MatrizIdeal(k+1,3)/(MatrizIdeal(k,3))); %Contribuição segmento posterior de alma

%Computar Area do primeiro ponto do chapeado + laminado
k=k+1;
Lin=sqrt((perfil(k,1)-perfil(k-1,1))^2+(perfil(k,2)-perfil(k-1,2))^2);
Lout=sqrt((perfil(k,1)-perfil(1,1))^2+(perfil(k,2)-perfil(1,2))^2);
MatrizIdeal(k,4)=E_Chap*Esp_Chap*Lout/6*(2+MatrizIdeal(1,3)/(MatrizIdeal(k,3))); %Contribuição segmento posterior de chapeado
MatrizIdeal(k,4)=MatrizIdeal(k,4)+E_Lam*Esp_Lam*Lout/6*(2+MatrizIdeal(1,3)/(MatrizIdeal(k,3))); %Contribuição segmento posterior de laminado
MatrizIdeal(k,4)=MatrizIdeal(k,4)+E_Alma*Esp_Alma*Lin/6*(2+MatrizIdeal(k-1,3)/(MatrizIdeal(k,3))); %Contribuição segmento anterior de alma
MatrizIdeal(k,4)=MatrizIdeal(k,4)+E_Mesa*A_Mesa; %Contribuição da mesa
end

