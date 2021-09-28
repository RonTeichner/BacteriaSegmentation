function [tau, divcount, sResults] = tifFileProcessing(sParams,c,i,disableCellId,divcount)

%%%%%%%%%%%%%%% define parameters %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% open channel specific files here %%%%%%%%%%%%%%%

fid10=fopen(['../data/cell_id_',char(c(i)),'.txt'],'w');
fid20=fopen(['../data/cellone_time_',char(c(i)),'.txt'],'w');


%-----------------------------------------------------------------------------
%%%%%%%%%%%%%% extracting images %%%%%%%%%%%%%
FileTif=['../im/', char(c(i)),'.tif'];
InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
NumberImages=length(InfoImage);

FinalImage=zeros(nImage,mImage,NumberImages,'uint16');

TifLink = Tiff(FileTif, 'r');
%-----------------------------------------------------------------------------
fprintf('Number of frames in this tif file : %d', NumberImages)
%-----------------------------------------------------------------------------
%%%%%%%%%%%%% image reading loop %%%%%%%%%%%%%%

for k=1:NumberImages
    TifLink.setDirectory(k);
    FinalImage(:,:,k)=TifLink.read();

end
%------------------------------------------------------------- Image loop ends
TifLink.close();
%-----------------------------------------------------------------------------

%===================== DATA HANDLING MODULE : END ============================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


n1 = nImage ;		% row = y-axis
%n2 = mImage ;		% column = x-axis

fprintf('tif images extracted : OK \n')
fprintf('**************************************************\n')
fprintf('data = %s\n',char(c(i)))
fprintf('**************************************************\n')


%%%%%%%%%%%%%%% initialization for every channel %%%%%%%%%%%%%%%

cell_id = zeros(sParams.max_cell_no,8);
ncid = 0;
L0 = [];
%LRaw0 = [];
ma_L0 = [];
cent_y0 = [];
l_end0 = 0;
%cy_end0 = 0;
BLine = 0;
calBLineFlag = 0;
%endCellDiv = 0;
l_sum = 0;
Lcsum0 = 0;
miny0 = [];


%%%%%%%%%%%%% Calibrate bottom line %%%%%%%%%%%%%%

dum = [];
ndum = 1;

for k=1:NumberImages

    IM = FinalImage(:,:,k);
    x_av = mean(IM,2);
    high_x = x_av > sParams.end_ch_high ;

    for kk=1:numel(high_x)
        if ( high_x(kk) > eps )
            dum(ndum)=kk;
            ndum = ndum + 1;
            break;
        end
    end

end

if (~isempty(dum))
    bottom_line = min(dum);
else
    bottom_line = n1 - 3*sParams.pdelta;
end





%>>>>>>>>>>>>>>>>>>>>>>>>>>  TIME LOOP  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% ANALYSIS ON STACK  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%% initialize %%%%%%%%%%%%%%%

%flagLastCell=0;
%flagLastCellDiv=0;
cLast0 = [];
ncell0 = [];
for k=1:NumberImages              % --------------------------- time loop
    IM = FinalImage(:,:,k);
    %--------------------------------------------------- IM = current frame
    display(['starting frame ',int2str(k),' out of ',int2str(NumberImages)])
	[sResults(k), miny0, Lcsum0, L0, l_end0, BLine, ma_L0, cell_id, cent_y0, ncid, cLast0, ncell0] = frameProcess(disableCellId, c, NumberImages, fid20, IM, sParams, i, k, bottom_line, miny0, Lcsum0, L0, l_end0, BLine, ma_L0, cell_id, cent_y0, ncid, cLast0, ncell0, l_sum, calBLineFlag);


end     %---------------------------- time loop on frames END

%==============================>>> WRITE THE CELL EVOLUTION DATA FOR ONE CHANNEL IN FILE <<<=====================================
tau=[];divcount=[];
[cidl,~]=size(cell_id);
for kk=1:cidl
    if (cell_id(kk,2)*cell_id(kk,3) > eps)
        tau(divcount) = cell_id(kk,3) - cell_id(kk,2);
        divcount = divcount + 1;
    end
    fprintf(fid10,'%f %f %f %f %f %f %f %f\n',cell_id(kk,1),cell_id(kk,2),cell_id(kk,3),cell_id(kk,4),cell_id(kk,5),cell_id(kk,6),cell_id(kk,7),cell_id(kk,8) );
end
