function [ T ] = meshing( X,Y,Z,pontos )
T=[];
for j=1:length(X)/pontos-1
    row1=(j-1)*pontos;
    row2=j*pontos;
    for i=1:pontos-1
        sec1=row1+i;
        sec2=row2+i;
        aux=[sec1,sec2,sec2+1,sec1+1];
        T=[T;aux];
    end
    aux=[sec1+1,sec2+1,row2+1,row1+1];
    T=[T;aux];
end

