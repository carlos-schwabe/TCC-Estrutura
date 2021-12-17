function [perfil]=corrigeperfil(perfilaux)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Corrigir numero de pontos do perfil
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:length(perfilaux)
    npontos(i)= length(perfilaux{i});
end
n=max(npontos)

for i=1:length(perfilaux)
    index=diff(perfilaux{i}(:,1));
    ed=perfilaux{i}(index<0,:);
    id=perfilaux{i}(index>0,:);
    long=perfilaux{i}(end-3:end,:);
    
    xed=linspace(long(end,1),ed(end,1),ceil((n-2)/2));
    xid=linspace(id(1,1),long(1,1),floor((n-2)/2));
    xed=transpose(xed);
    xid=transpose(xid);
    interped=[long(end,:);ed];
    interpid=[id;long(1,:)];
    yed=interp1(interped(:,1),interped(:,2),xed);
    yid=interp1(interpid(:,1),interpid(:,2),xid);
    perfil{i}=[xed(2:end),yed(2:end);xid(1:end-1),yid(1:end-1);long];
end
end

