%%
clear all;clc
load('202208new-test.mat')
%% run.def
% read run.def.txt file to a cell file
n=length(seq)


for k = 1:n

% run.def
fid = fopen('correction_bag.pl.txt','r');
i = 1;
tline = fgetl(fid);
A{i} = tline;
while ischar(tline)
    i = i+1;
    tline = fgetl(fid);
    A{i} = tline;
end
fclose(fid);


% each index in the cell file is the line number

if(isnan(qf(k)))
    qf(k)=0;
end
if(isnan(deltaO18f(k)))
    deltaO18f(k)=0;
end
if(isnan(dexcessf(k)))
    dexcessf(k)=0;
end
if(isnan(delay(k)))
    delay(k)=0;
end
if(isnan(qe(k)))
    qe(k)=0;
end
if(isnan(deltaO18e(k)))
    deltaO18e(k)=0;
end
if(isnan(dexcesse(k)))
    dexcesse(k)=0;
end
if(isnan(lambdad(k)))
    lambdad(k)=0;
end

    A{24} = ['$qf=',num2str(qf(k)),'; # g/kg'];
    A{25} = ['$deltaO18f=',num2str(deltaO18f(k)),'; # permil'];
    A{26} = ['$dexcessf=',num2str(dexcessf(k)),'; # permil'];
    A{27} = ['$delay=',num2str(delay(k)),'; # dealy of measurement, in hours'];
    A{30} = ['$qe=',num2str(qe(k)),'; # g/kg'];
    A{31} = ['$deltaO18e=',num2str(deltaO18e(k)),'; # permil'];
    A{32} = ['$dexcesse=',num2str(dexcesse(k)),'; # permil'];
    A{35} = ['$lambdad=',num2str(lambdad(k)),'; #'];
    A{80} = ['$fileout="outputs/correction_bag_',num2str(seq(k)),'_$tag.txt";'];

    % Write cell A into txt run.def

    
    nam=['correction_bag.',num2str(k),'.pl'];
        fid = fopen(nam, 'w');



    for i = 1:numel(A)
        if A{i+1} == -1
            fprintf(fid,'%s', A{i});
            break
        else
            fprintf(fid,'%s\n', A{i});
        end
    end
    
    fclose(fid);
    
    
    
    
    
    
end

