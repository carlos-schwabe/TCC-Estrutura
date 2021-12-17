function [] = ConvEixos(perfil,corda)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Demonstrar Convenção de eixos adotada
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plotar pontos do perfil idealizado
a=figure
scatter(perfil(:,1),perfil(:,2),25,'filled','MarkerEdgeColor',[0 .5 .5])
hold on
%% Plotar Setas de fluxo de cisalhamento
for k=1:length(perfil)-3
    x1=[perfil(k+1,1),perfil(k,1)];
    y1=[perfil(k+1,2),perfil(k,2)];
    quiver( x1(1),y1(1),x1(2)-x1(1),y1(2)-y1(1),1,'Color','b','MaxHeadSize',0.5)
end
%% Indicar ponto de redução
text(x1(2),y1(2),'\leftarrow PONTO DE REDUÇÃO')
%% Plotar fluxo de referencia
k=length(perfil)-2;
x1=[perfil(k,1),perfil(k+1,1)];
y1=[perfil(k,2),perfil(k+1,2)];
quiver( x1(1),y1(1),x1(2)-x1(1),y1(2)-y1(1),1,'Color','r','MaxHeadSize',0.5)
%% Fluxo de da alma
k=length(perfil)-1;
x1=[perfil(k+1,1),perfil(k,1)];
y1=[perfil(k+1,2),perfil(k,2)];
quiver( x1(1),y1(1),x1(2)-x1(1),y1(2)-y1(1),1,'Color','b','MaxHeadSize',0.5)
x1=[perfil(1,1),perfil(end,1)];
y1=[perfil(1,2),perfil(end,2)];
quiver( x1(1),y1(1),x1(2)-x1(1),y1(2)-y1(1),1,'Color','b','MaxHeadSize',0.5)
%% Marcar ponto de redução
scatter(perfil(end-3,1),perfil(end-3,2),100,'filled','MarkerEdgeColor',[0.5 .5 .5])
x1=[corda*0.3,corda*0.3];
y1=[corda*0.05,corda*0.1];
quiver( x1(1),y1(1),x1(2)-x1(1),y1(2)-y1(1),1,'Color','k','MaxHeadSize',0.5,'LineWidth',3)
text(x1(1),y1(2),'Vy')
x1=[corda*0.3,corda*0.35];
y1=[corda*0.05,corda*0.05];
text(x1(2),y1(1),'Vz')
quiver( x1(1),y1(1),x1(2)-x1(1),y1(2)-y1(1),1,'Color','k','MaxHeadSize',0.5,'LineWidth',3)
axis equal
waitfor(a);
end

