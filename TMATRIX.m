function [  ] = TMATRIX()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cálculo da matriz de transformação de cargas nodais para esforços
% solicitantes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global Out Geom Cargas Estrut
%Criar TMATrix
for i=1:size(Geom.OS)
    Out.Cargas.Vy(i)=0;
    Out.Cargas.Vz(i)=0;
    Out.Cargas.My(i)=0;
    Out.Cargas.Mz(i)=0;
    Out.Cargas.Mt(i)=0;
    for k=1:size(Cargas.Flift)
        if Cargas.Flift(k,1)>Geom.OS(i)
            deltax=interp1(Geom.posCA(:,1),Geom.posCA(:,2),Geom.OS(i))-interp1(Geom.posCA(:,1),Geom.posCA(:,2),Cargas.Flift(k,1))-interp1(Geom.poscorda(:,1),Geom.poscorda(:,2),Geom.OS(i))*(0.25-interp1(Estrut.poslong(:,1),Estrut.poslong(:,2),Geom.OS(i)));
            deltay=Cargas.Flift(k,1)-Geom.OS(i);
            Out.Cargas.Vy(i)=Out.Cargas.Vy(i)+Cargas.Flift(k,2);
            Out.Cargas.Vz(i)=Out.Cargas.Vz(i)+Cargas.Fdrag(k,2);
            Out.Cargas.My(i)=Out.Cargas.My(i)-Cargas.Fdrag(k,2)*deltay;
            Out.Cargas.Mz(i)=Out.Cargas.Mz(i)+Cargas.Flift(k,2)*deltay;
            Out.Cargas.Mt(i)=Out.Cargas.Mt(i)+Cargas.Torsor(k,2)+Cargas.Flift(k,2)*deltax;
        end
    end
end
clear deltax deltay k i
