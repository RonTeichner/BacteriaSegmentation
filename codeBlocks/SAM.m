function sAllFilesResults = SAM(disableCellId, tiffFileName)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%	MAIN CODE FOR SEGMENTATION AND ANALYSIS OF MOTHER MACHINE DATA (SAM)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%clc;
%clear all;

sParams = SAM_parameters();



%%%%%%%%%%%%%%% open files %%%%%%%%%%%%%%%
fid1=fopen('../data/divtime.txt','w');


%%%%%%%%%%%%%%% initialize %%%%%%%%%%%%%%%
cell_size = [];
divcount = 1;


%======================== DATA HANDLING MODULE =================================

%%%%%%%%%%%%%% get file names %%%%%%%%%%%%%%%%%
%fid = fopen('dataname');
%txt = textscan(fid,'%s','delimiter','\n');
%c = txt{1} ;

c{1} = tiffFileName;

fprintf(['number of channels to be analysed ',int2str(numel(c))])
ndata=numel(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% LOOP ON DATA (TIF FILES) %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:ndata

    [tau, divcount, sSingleFileResults] = tifFileProcessing(sParams,c,i,disableCellId,divcount);
    sAllFilesResults{i} = sSingleFileResults;

end	%---------------------------- loop on data ENDs



for kk=1:numel(tau)
    fprintf(fid1,'%f\n', tau(kk) );
end

mean_divtime = mean(tau);

%plot_channel(CC2, IM,imbw0,bottom_line,BLine,k,NumberImages,i,c);

%plot_data(k);				%% only use with script file run

%fprintf('number of detected cell div, mean div time = %d %f\n',divcount,mean_divtime)
%fprintf('frames analyzed = %d, total frames = %d \n',k,NumberImages)
%fprintf('---------------- END OF CODE --------------\n')

end









