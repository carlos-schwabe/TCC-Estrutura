%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Codigo Idealiza??o Estrutural (Cotonete)
% By: Charles
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Conven??o de eixos:
% Perfil com o bordo de ataque virado para a esquerda
% Eixo Y para CIMA
% Eixo Z para a DIREITA
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Unidades: O programa ? adimensional, porem as unidades devem ser
% coerentes. Sugere-se:
% Newton
% Milimetro
% MPa
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all
clear all
clc

load('Inputs/Estrut.mat')
load('Inputs/Geom.mat')
load('Inputs/Cargas_Unitarias.mat')

global Out Estrut Geom Cargas
%% Calcular Esfor?os Solicitantes
% disp('-------------------------------------------------------------------------')
% disp(' ')
% disp('Carregar Cargas')
% disp('	[1]. Cargas Nodais')
% disp('	[2]. Esfor?os Solicitantes ')
% disp(' ')
% disp('-------------------------------------------------------------------------')
% quest=input(' ');
% switch quest
%     case 1
%         load('Inputs/Cargas_Nodais.mat')
%         TMATRIX()
%     case 2
%         load('Inputs/Input_Dimensionamento.mat')
%         sz=length(Input_Estruturas)
%         disp('-------------------------------------------------------------------------')
%         disp(' ')
%         disp('Qual Caso de carga rodar?')
%         for i =1:sz
%             disp(strcat('	[',sprintf('%d',i),']. LC',sprintf('%04d',Input_Estruturas(i).id)))
%         end
%         disp('-------------------------------------------------------------------------')
%         quest=input(' ');
%         Out.Cargas=Input_Estruturas(quest)
%         lcname=strcat('LC',sprintf('%04d',Input_Estruturas(quest).id))
% end
for lc = 1:length(Input_Estruturas)
clearvars -except lc Outputs_Casos
clear global
load('Inputs/Estrut.mat')
load('Inputs/Geom.mat')
load('Inputs/Cargas_Unitarias.mat')
global Out Estrut Geom Cargas
Out.Cargas=Input_Estruturas(lc);
lcname=strcat('LC',sprintf('%04d',Input_Estruturas(lc).id));
%% Interpolar e dimensionalizar Perfis

for i=1:length(Geom.OS)
    disp('LC Numero')
    disp(lc)
    %Achar se??es mais proximas na asa
    for j=1:length(Geom.poscorda)-1
        if Geom.OS(i,1)>=Geom.poscorda(j,1) && Geom.OS(i,1)<=Geom.poscorda(j+1,1)
            break
        end
    end
    %Fazer a interpola??o dos perfis
    peso=(Geom.OS(i)-Geom.poscorda(j,1))/(Geom.poscorda(j+1,1)-Geom.poscorda(j,1));
    aux=Geom.perfil{j}*(1-peso) + Geom.perfil{j+1}*peso;
    %Encontar os pontos da poi??o exata da longarina
    poslong=interp1(Estrut.poslong(:,1),Estrut.poslong(:,2),Geom.OS(i));
    indexes=find(aux(:,1)<=poslong);
    curvasup=[aux(indexes(1),1),aux(indexes(1),2);aux(indexes(1)-1,1),aux(indexes(1)-1,2)];
    curvainf=[aux(indexes(length(indexes)),1),aux(indexes(length(indexes)),2);aux(indexes(length(indexes))+1,1),aux(indexes(length(indexes))+1,2)];
    yinf=interp1(curvainf(:,1),curvainf(:,2),poslong);
    ysup=interp1(curvasup(:,1),curvasup(:,2),poslong);
    %Cortar Coordenadas atras do chapeado
    aux=aux(aux(:,1)<=poslong,:);
    %Adicionar pontos da alma e mesa
    aux(length(aux)+1,1)=poslong;
    aux(length(aux),2)=yinf;
    aux(length(aux)+1,1)=poslong;
    aux(length(aux),2)=(ysup-yinf)/3+yinf;
    aux(length(aux)+1,1)=poslong;
    aux(length(aux),2)=(ysup-yinf)*2/3+yinf;
    aux(length(aux)+1,1)=poslong;
    aux(length(aux),2)=ysup;
    %Dimensionalizar perfil
    perfilaux{i}=aux(aux(:,1)<=poslong,:)*interp1(Geom.poscorda(:,1),Geom.poscorda(:,2),Geom.OS(i));
end
Out.perfil=corrigeperfil(perfilaux);
clear  curvainf curvasup i indexes j i peso poslong yinf ysup x1 y1

%% Demonstrar Conven??o de eixos
% perfil=Out.perfil{1};
% corda=Geom.poscorda(1,2);
% ConvEixos(perfil,corda);
% clear perfil corda

%% Calculo do CG da se??o
for i=1:length(Geom.OS)
    % Calcular CG
    CG=CalculoCG(i,Out.perfil{i});
    Out.CG(i,:)=CG;
end
clear CG i

%% Calculo ddos momentos de in?rcia
for i=1:length(Geom.OS)
    Inercia=CalculoInercias(i,Out.perfil{i});
    Out.EIzz(i)=Inercia(1);
    Out.EIyy(i)=Inercia(2);
    Out.EIzy(i)=Inercia(3);
end
clear Inercia i

%% Idealiza??o de areas
%Utilizaremos uma matriz 3d de tamanho k x 5 x i aonde:
%i= numero de se?oes de saida
%k= numero de pontos do aerofolio
%coluna 1 coordenada Z,
%coluna 2 coordenada Y,
%coluna 3 sigma/E (tes?o adimensionalizada por MF e E)
%coluna 4 area idealizada

for i=1:length(Geom.OS)
    MatrizIdeal(:,:,i)=IdealizacaoVy(i);
end
clear i

%% C?lculo de Momentos Est?ticos

for i=1:length(Geom.OS)
    %Define-se a se??o de referncia como o centro da alma (MS=0)
    %Tem-se a Matriz FluxCis iniciando na se??o de corte e varrendo o perfil no
    %sentido anti-horario.
    %coluna 1 = Comprimento da se??o idealizada,
    %coluna 2 = Momento estatico em Z,
    %coluna 3 = Momento estatico em Y,
    %coluna 4 = Espessura equivalente da se??o idelizada (tchap+tlam)
    %coluna 5 = momento gerado ( ponto de redu??o mesa inferior) por unidade de fluxo de cisalhamento
    %coluna 6 = For?a em Z por unidade de flux cis
    %coluna 7 = For?a em Y por unidade de flux cis
    %coluna 8 = G equivalente (Gchap*tchap+Glam*tlam)/(tchap+tlam)
    %coluna 9 = Fluxo de Cisalhamento do trecho ( calculado na prox etapa do
    %codigo)
    
    matrizideal=MatrizIdeal(:,:,i);
    FluxCis(:,:,i)=CalculoMS(i,matrizideal);
end
clear i matrizideal

%% C?lculo do CC
%Montar e resolver o sistema linear que nos d? a posi??o do CC
for i=1:length(Geom.OS)
    fluxcis=FluxCis(:,:,i);
    [A,B]=MontarSistemaCC( i,fluxcis);
    sol=linsolve(A,B);
    Out.CC(i,1)=Out.perfil{i}(end-3,1)+sol(end);
end
clear A B fluxcis sol i

%% Calcular Giros e Fluxos
for i=1:length(Geom.OS)
    fluxcis=FluxCis(:,:,i);
    [A,B]=MontarSistemaGiros( i,fluxcis);
    sol=linsolve(A,B);
    integrais(i,1)=Geom.OS(i);
    integrais(i,2)=0.5*sol(end)/polyarea(Out.perfil{i}(:,1),Out.perfil{i}(:,2));
    Out.GJ(i)=Out.Cargas.Mt(i)/integrais(i,2);
    FluxCis(:,9,i)=sol(1:end-1);
    if i>1
        Out.Giro(i)=rad2deg(trapz(integrais(1:i,1),integrais(1:i,2)));
    else
        Out.Giro(i)=0;
    end
end
clear A B fluxcis sol i integrais

%% Flexao geral ( sem acoplar tor??o, quem sabe se eu me animar no futuro)

for i=1:length(Geom.OS)
    [A,B,derivz,derivy]=Flex_Ger(Out.EIzz(i),Out.EIyy(i),Out.EIzy(i),Out.Cargas.Mz(i),Out.Cargas.My(i));
    %Deflexoes (Integrais numericas)
    if i==1
        Out.Deriv(i,1)=derivz; %Segunda derivada do deslocamento em  Y
        Out.Deriv(i,2)=derivy; %Segunda derivada do deslocamento em  Z
        Out.Giro_Flex(i,1)=0; %Giro em Y
        Out.Giro_Flex(i,2)=0; %Giro em Z
        Out.Flecha(i,1)=0; %Flecha em Y
        Out.Flecha(i,2)=0; %Flecha em Z
    else
        Out.Deriv(i,1)=derivz; %Segunda derivada do deslocamento em Z
        Out.Deriv(i,2)=derivy; %Segunda derivada do deslocamento em  Y
        Out.Giro_Flex(i,1)=trapz(Geom.OS(1:i,1),Out.Deriv(:,1)); %Giro em Y
        Out.Giro_Flex(i,2)=trapz(Geom.OS(1:i,1),Out.Deriv(:,2)); %Giro em Z
        Out.Flecha(i,1)=trapz(Geom.OS(1:i,1),Out.Giro_Flex(:,1)); %Flecha em Z
        Out.Flecha(i,2)=trapz(Geom.OS(1:i,1),Out.Giro_Flex(:,2)); %Flecha em Y
    end
    %Tensoes normais
    [alma,mesa,chap,lam]=sigma(i,A,B);
    Out.Sigma.Alma{i}=alma;
    Out.Sigma.Mesa{i}=mesa;
    Out.Sigma.Chap{i}=chap;
    Out.Sigma.Lam{i}=lam;
    clear alma mesa chap lam
    %Tensoes cisalhamento
    [alma,chap,lam]=tau(i,FluxCis(:,9,i));
    Out.Tau.Alma{i}=alma;
    Out.Tau.Chap{i}=chap;
    Out.Tau.Lam{i}=lam;
    clear A B alma mesa chap lam derivy derivz
    %Von Mises
    Out.VM.Alma{i}=Out.Sigma.Alma{i};
    Out.VM.Mesa{i}=Out.Sigma.Mesa{i};
    Out.VM.Chap{i}=Out.Sigma.Chap{i};
    Out.VM.Lam{i}=Out.Sigma.Lam{i};
    Out.VM.Alma{i}(:,3)=sqrt(Out.Sigma.Alma{i}(:,3).^2+3.*Out.Tau.Alma{i}(:,3).^2);
    Out.VM.Chap{i}(:,3)=sqrt(Out.Sigma.Chap{i}(:,3).^2+3.*Out.Tau.Chap{i}(:,3).^2);
    Out.VM.Lam{i}(:,3)=sqrt(Out.Sigma.Lam{i}(:,3).^2+3.*Out.Tau.Lam{i}(:,3).^2);
    
end


%% Desenhar Posi??o dos CCs
for i=1:length(Geom.OS)
    desenho(i,1)=Geom.OS(i); %Posi??es
    desenho(i,2)=interp1(Geom.poscorda(:,1),Geom.poscorda(:,2),Geom.OS(i)); %Cordas
    desenho(i,3)=interp1(Geom.posCA(:,1),Geom.posCA(:,2),Geom.OS(i))+desenho(i,2)*0.25;%BA
    desenho(i,4)=desenho(i,3)-desenho(i,2);%BF
    desenho(i,5)=desenho(i,3)-Out.CC(i,1); %CC
    desenho(i,6)=desenho(i,3)-Out.CG(i,1); %CG
end
%Calcular CA
desenho(:,7)=CalcCA(desenho(:,1),desenho(:,2) ,desenho(:,3));
% %Plotar BA
% plot(desenho(:,1),desenho(:,3),'k','LineWidth',2)
% hold on
% plot(-desenho(:,1),desenho(:,3),'k','LineWidth',2)
% %Plotar BF
% plot(desenho(:,1),desenho(:,4),'k','LineWidth',2)
% plot(-desenho(:,1),desenho(:,4),'k','LineWidth',2)
% %Plotar pontas
% plot([desenho(end,1);desenho(end,1)],[desenho(end,3);desenho(end,4)],'k','LineWidth',2)
% plot([-desenho(end,1);-desenho(end,1)],[desenho(end,3);desenho(end,4)],'k','LineWidth',2)
% %Plotar CC
% scatter(desenho(:,1),desenho(:,5),15,'b','filled')
% scatter(-desenho(:,1),desenho(:,5),15,'b','filled')
% %Plotar CG
% scatter(desenho(:,1),desenho(:,6),15,'g','filled')
% scatter(-desenho(:,1),desenho(:,6),15,'g','filled')
% %Plotar CA
% plot(desenho(:,1),desenho(:,7),'r')
% plot(-desenho(:,1),desenho(:,7),'r')
% 
% axis equal
clear i

%% LOG File
% fid=fopen(strcat('Outputs/Stress_Run_log_',lcname,'.csv'),'wt');
% fprintf(fid,'----------------------------------------------\nLOG MATLAB Estruturas Copyright Charles 2020\n----------------------------------------------\n\nVIS?O GERAL POR SE??O\n--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n');
% fprintf(fid,'SE??O,POSI??O .25c,, ESFOR?OS,,,,,IN?RCIAS,,,,CENTROS GEOM?TRICOS,,,DEFLEX?OES,,,,,TENS?ES NORMAIS,,,,,,,,TENS?ES CISALHAMENTO,,,TENS?ES DE VON MISES\n');
% fprintf(fid,'NUMERO,X,Y,MFz,MFy,MTx,Vz,Vy,EIzz,EIyy,EIzy,GJ,Zcg,Ycg,Zcc,Z,Y,Z?,Y?,Theta,Sigma_Chap+,Sigma_Chap-,Sigma_Lam+,Sigma_Lam-,Sigma_Mesa+,Sigma_Mesa-,Sigma_Alma+,Sigma_Alma-,  Tau_Alma,  Tau_Chap,  Tau_Lam, Von Mises_Alma,  Von Mises_Chap,  Von Mises_Lam\n');
% fprintf(fid,'--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n');
% for i=1:length(Geom.OS)
%     fprintf(fid,[num2str(i,'%.2i') ',' num2str(Geom.OS(i),'%.5e') ',' num2str(interp1(Geom.posCA(:,1),Geom.posCA(:,2),Geom.OS(i)),'%.5e') ',' num2str(Out.Cargas.Mz(i),'%.5e') ',' num2str(Out.Cargas.My(i),'%.5e') ',' num2str(Out.Cargas.Mt(i),'%.5e') ',' num2str(Out.Cargas.Vz(i),'%.5e') ',' num2str(Out.Cargas.Vy(i),'%.5e') ',' num2str(Out.EIzz(i),'%.5e') ',' num2str(Out.EIyy(i),'%.5e') ',' num2str(Out.EIzy(i),'%.5e') ',' num2str(Out.GJ(i),'%.5e') ',' num2str(Out.CG(i,1),'%.5e') ',' num2str(Out.CG(i,2),'%.5e') ',' num2str(Out.CC(i),'%.5e') ',' num2str(Out.Flecha(i,1),'%.5e') ',' num2str(Out.Flecha(i,2),'%.5e') ',' num2str(Out.Giro_Flex(i,1),'%.5e') ',' num2str(Out.Giro_Flex(i,2),'%.5e') ',' num2str(deg2rad(Out.Giro(i)),'%.5e') ',' num2str(max(Out.Sigma.Chap{i}(:,3)),'%.5e') ',' num2str(min(Out.Sigma.Chap{i}(:,3)),'%.5e') ',' num2str(max(Out.Sigma.Lam{i}(:,3)),'%.5e') ',' num2str(min(Out.Sigma.Lam{i}(:,3)),'%.5e') ',' num2str(max(Out.Sigma.Mesa{i}(:,3)),'%.5e') ',' num2str(min(Out.Sigma.Mesa{i}(:,3)),'%.5e') ',' num2str(max(Out.Sigma.Alma{i}(:,3)),'%.5e') ',' num2str(min(Out.Sigma.Alma{i}(:,3)),'%.5e') ',' num2str(max(Out.Tau.Alma{i}(:,3)),'%.5e') ',' num2str(max(Out.Tau.Chap{i}(:,3)),'%.5e') ',' num2str(max(Out.Tau.Lam{i}(:,3)),'%.5e') ',' num2str(max(Out.VM.Alma{i}(:,3)),'%.5e') ',' num2str(max(Out.VM.Chap{i}(:,3)),'%.5e') ',' num2str(max(Out.VM.Lam{i}(:,3)),'%.5e') '\n']);
% end
% fprintf(fid,'--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n\n');
% 
% fprintf(fid,['CHAPEADO ' '\n--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n']);
% fprintf(fid,'X,Y,Z,Sigma,Tau,Von Mises\n');
% k=1;
% for i=1:length(Geom.OS)
%     for j=1:size(Out.Sigma.Chap{i},1)
%         comp(k,1)=Geom.OS(i);
%         comp(k,2)=Out.Sigma.Chap{i}(j,2);
%         comp(k,3)=Out.Sigma.Chap{i}(j,1)-desenho(i,3);
%         comp(k,4)=Out.Sigma.Chap{i}(j,3);
%         comp(k,5)=Out.Tau.Chap{i}(j,3);
%         comp(k,6)=Out.VM.Chap{i}(j,3);
%         k=k+1;
%     end
% end
% for i=1:size(comp,1)
%     fprintf(fid,[num2str(comp(i,1),'%.5e') ',' num2str(comp(i,2),'%.5e') ',' num2str(comp(i,3),'%.5e') ',' num2str(comp(i,4),'%.5e') ',' num2str(comp(i,5),'%.5e') ',' num2str(comp(i,6),'%.5e') '\n']);
% end
% PlotData.Chap.Mesh=meshingcomp(comp(:,1),comp(:,2),comp(:,3),size(comp,1)/length(Geom.OS));
% PlotData.Chap.Data=comp;
% fprintf(fid,'--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n\n');
% clear comp i j k
% 
% 
% fprintf(fid,['LAMINADO ' '\n--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n']);
% fprintf(fid,'X,Y,Z,Sigma,Tau,Von Mises\n');
% k=1;
% for i=1:length(Geom.OS)
%     for j=1:size(Out.Sigma.Lam{i},1)
%         comp(k,1)=Geom.OS(i);
%         comp(k,2)=Out.Sigma.Lam{i}(j,2);
%         comp(k,3)=Out.Sigma.Lam{i}(j,1)-desenho(i,3);
%         comp(k,4)=Out.Sigma.Lam{i}(j,3);
%         comp(k,5)=Out.Tau.Lam{i}(j,3);
%         comp(k,6)=Out.VM.Lam{i}(j,3);
%         k=k+1;
%     end
% end
% for i=1:size(comp,1)
%     fprintf(fid,[num2str(comp(i,1),'%.5e') ',' num2str(comp(i,2),'%.5e') ',' num2str(comp(i,3),'%.5e') ',' num2str(comp(i,4),'%.5e') ',' num2str(comp(i,5),'%.5e') ',' num2str(comp(i,6),'%.5e') '\n']);
% end
% PlotData.Lam.Mesh=meshingcomp(comp(:,1),comp(:,2),comp(:,3),size(comp,1)/length(Geom.OS));
% PlotData.Lam.Data=comp;
% fprintf(fid,'--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n\n');
% clear comp i j k
% 
% fprintf(fid,['ALMA ' '\n--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n']);
% fprintf(fid,'X,Y,Z,Sigma,Tau,Von Mises\n');
% k=1;
% for i=1:length(Geom.OS)
%     for j=1:size(Out.Sigma.Alma{i},1)
%         comp(k,1)=Geom.OS(i);
%         comp(k,2)=Out.Sigma.Alma{i}(j,2);
%         comp(k,3)=Out.Sigma.Alma{i}(j,1)-desenho(i,3);
%         comp(k,4)=Out.Sigma.Alma{i}(j,3);
%         comp(k,5)=Out.Tau.Alma{i}(j,3);
%         comp(k,6)=Out.VM.Alma{i}(j,3);
%         k=k+1;
%     end
% end
% for i=1:size(comp,1)
%     fprintf(fid,[num2str(comp(i,1),'%.5e') ',' num2str(comp(i,2),'%.5e') ',' num2str(comp(i,3),'%.5e') ',' num2str(comp(i,4),'%.5e') ',' num2str(comp(i,5),'%.5e') ',' num2str(comp(i,6),'%.5e') '\n']);
% end
% PlotData.Alma.Mesh=meshingcomp(comp(:,1),comp(:,2),comp(:,3),size(comp,1)/length(Geom.OS));
% PlotData.Alma.Data=comp;
% clear comp i j k
% fprintf(fid,['MESA INFERIOR ' '\n--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n']);
% fprintf(fid,'X,Y,Z,Sigma,Von Mises\n');
% for i=1:length(Geom.OS)
%     comp(i,1)=Geom.OS(i);
%     comp(i,2)=Out.Sigma.Mesa{i}(1,2);
%     comp(i,3)=Out.Sigma.Mesa{i}(1,1)-desenho(i,3);
%     comp(i,4)=Out.Sigma.Lam{i}(1,3);
%     comp(i,5)=0;
%     comp(i,6)=Out.VM.Lam{i}(1,3);
% end
% for i=1:size(comp,1)
%     fprintf(fid,[num2str(comp(i,1),'%.5e') ',' num2str(comp(i,2),'%.5e') ',' num2str(comp(i,3),'%.5e') ',' num2str(comp(i,4),'%.5e') ',' num2str(comp(i,6),'%.5e') '\n']);
% end
% fprintf(fid,'--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n\n');
% clear comp i j k
% 
% fprintf(fid,['MESA SUPERIOR ' '\n--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n']);
% fprintf(fid,'X,Y,Z,Sigma,Von Mises\n');
% for i=1:length(Geom.OS)
%     comp(i,1)=Geom.OS(i);
%     comp(i,2)=Out.Sigma.Mesa{i}(2,2);
%     comp(i,3)=Out.Sigma.Mesa{i}(2,1)-desenho(i,3);
%     comp(i,4)=Out.Sigma.Lam{i}(2,3);
%     comp(i,5)=0;
%     comp(i,6)=Out.VM.Lam{i}(2,3);
% end
% for i=1:size(comp,1)
%     fprintf(fid,[num2str(comp(i,1),'%.5e') ',' num2str(comp(i,2),'%.5e') ',' num2str(comp(i,3),'%.5e') ',' num2str(comp(i,4),'%.5e') ',' num2str(comp(i,6),'%.5e') '\n']);
% end
% fprintf(fid,'--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n\n');
% clear comp i j k
% fclose(fid);
% 
% clear i fid

%% Asa Deformada
Xor=[];
Yor=[];
Zor=[];
Xdef=[];
Ydef=[];
Zdef=[];
Col=[];
for i=1:length(Geom.OS)
    X=Geom.OS(i)*ones(length(Out.perfil{i}),1);
    Y=Out.perfil{i}(:,2);
    Z=Out.perfil{i}(:,1);
    
    Xor=[Xor;X];
    Yor=[Yor;Y];
    Zor=[Zor;Z-desenho(i,3)];
    Zaux=Out.CC(i)-Z;
    Yaux=Out.CG(i,2)-Y;
    tet=-deg2rad(Out.Giro(i));
    Zaux=Zaux*cos(tet)-Yaux*sin(tet);
    Yaux=Zaux*sin(tet)+Yaux*cos(tet);
    Zaux=Zaux*cos(tet)-Yaux*sin(tet);
    Yaux=Zaux*sin(tet)+Yaux*cos(tet);
    Z=Out.CC(i)-Zaux-desenho(i,3)+Out.Flecha(i,1);
    Y=Out.CG(i,2)-Yaux+Out.Flecha(i,2);
    col=Out.Flecha(i,2)*Y./Y;
    Xdef=[Xdef;X];
    Ydef=[Ydef;Y];
    Zdef=[Zdef;Z];
    Col=[Col;col];
end
PlotData.Orig.Mesh=meshing(Xor,Yor,Zor,size(Out.perfil{1},1));
PlotData.Orig.Data=[Xor,Yor,Zor];
PlotData.Def.Mesh=meshing(Xdef,Ydef,Zdef,size(Out.perfil{1},1));
PlotData.Def.Data=[Xdef,Ydef,Zdef,Col];
clear Xor Yor Zor Xdef Ydef Zdef X Y Z T tet Xaux Yaux Zaux col Col

%% Dados gerais de execu??o
fr_trac_chap=6/max(Out.Sigma.Chap{1}(:,3));
fr_comp_chap=-6/min(Out.Sigma.Chap{1}(:,3));
fr_cis_chap=2/max(Out.Tau.Chap{1}(:,3));
fr_trac_alma=2.2/max(Out.Sigma.Alma{1}(:,3));
fr_comp_alma=-2.2/min(Out.Sigma.Alma{1}(:,3));
fr_cis_alma=1.4/max(Out.Tau.Alma{1}(:,3));
Outputs_Casos(lc).id=lcname;
Outputs_Casos(lc).TracChap=fr_trac_chap;
Outputs_Casos(lc).CompChap=fr_comp_chap;
Outputs_Casos(lc).CisChap=fr_cis_chap;
Outputs_Casos(lc).TracAlm=fr_trac_alma;
Outputs_Casos(lc).CompAlm=fr_comp_alma;
Outputs_Casos(lc).CisAlm=fr_cis_alma;
end

%% Plotar Coisas
% while 1
%     answer = menu('Qual Resultado Plotar?', ...
%         'Tens?o Normal','Tens?o de Cisalhamento','Von Mises','Deforma??o','Sair');
%     % Handle response
%     
%     if answer==1
%         figure
%         trisurf(PlotData.Chap.Mesh,PlotData.Chap.Data(:,1),PlotData.Chap.Data(:,2),PlotData.Chap.Data(:,3),PlotData.Chap.Data(:,4));
%         axis equal
%         shading 'interp'
%         colormap 'jet'
%         title('Normal Chapeado')
%         figure
%         trisurf(PlotData.Lam.Mesh,PlotData.Lam.Data(:,1),PlotData.Lam.Data(:,2),PlotData.Lam.Data(:,3),PlotData.Lam.Data(:,4));
%         axis equal
%         shading 'interp'
%         colormap 'jet'
%         title('Normal Laminado')
%         figure
%         trisurf(PlotData.Alma.Mesh,PlotData.Alma.Data(:,1),PlotData.Alma.Data(:,2),PlotData.Alma.Data(:,3),PlotData.Alma.Data(:,4));
%         axis equal
%         shading 'interp'
%         colormap 'jet'
%         title('Normal Alma')
%     elseif answer==2
%         figure
%         trisurf(PlotData.Chap.Mesh,PlotData.Chap.Data(:,1),PlotData.Chap.Data(:,2),PlotData.Chap.Data(:,3),PlotData.Chap.Data(:,5));
%         axis equal
%         shading 'interp'
%         colormap 'jet'
%         title('Cisalhamento Chapeado')
%         figure
%         trisurf(PlotData.Lam.Mesh,PlotData.Lam.Data(:,1),PlotData.Lam.Data(:,2),PlotData.Lam.Data(:,3),PlotData.Lam.Data(:,5));
%         axis equal
%         shading 'interp'
%         colormap 'jet'
%         title('Cisalhamento Laminado')
%         figure
%         trisurf(PlotData.Alma.Mesh,PlotData.Alma.Data(:,1),PlotData.Alma.Data(:,2),PlotData.Alma.Data(:,3),PlotData.Alma.Data(:,5));
%         axis equal
%         shading 'interp'
%         colormap 'jet'
%         title('Cisalhamento Alma')
%     elseif answer==3
%         figure
%         trisurf(PlotData.Chap.Mesh,PlotData.Chap.Data(:,1),PlotData.Chap.Data(:,2),PlotData.Chap.Data(:,3),PlotData.Chap.Data(:,6));
%         axis equal
%         shading 'interp'
%         colormap 'jet'
%         title('Von Mises Chapeado')
%         figure
%         trisurf(PlotData.Lam.Mesh,PlotData.Lam.Data(:,1),PlotData.Lam.Data(:,2),PlotData.Lam.Data(:,3),PlotData.Lam.Data(:,6));
%         axis equal
%         shading 'interp'
%         colormap 'jet'
%         title('Von Mises Laminado')
%         figure
%         trisurf(PlotData.Alma.Mesh,PlotData.Alma.Data(:,1),PlotData.Alma.Data(:,2),PlotData.Alma.Data(:,3),PlotData.Alma.Data(:,6));
%         axis equal
%         shading 'interp'
%         colormap 'jet'
%         title('Von Mises Alma')
%     elseif answer==4
%         figure
%         trisurf(PlotData.Orig.Mesh,PlotData.Orig.Data(:,1),PlotData.Orig.Data(:,2),PlotData.Orig.Data(:,3),PlotData.Orig.Data(:,3)*0);
%         axis equal
%         shading 'interp'
%         colormap 'jet'
%         hold on
%         trisurf(PlotData.Def.Mesh,PlotData.Def.Data(:,1),PlotData.Def.Data(:,2),PlotData.Def.Data(:,3),PlotData.Def.Data(:,4));
%         shading 'interp'
%         colormap 'jet'
%         title('ASA DEFORMADA')
%     else
%         break
%     end
%     
% end


