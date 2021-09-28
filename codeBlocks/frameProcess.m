function [sResults, miny0, Lcsum0, L0, l_end0, BLine, ma_L0, cell_id, cent_y0, ncid, cLast0, ncell0] = frameProcess(disableCellId, c, NumberImages, fid20, IM, sParams, i, k, bottom_line, miny0, Lcsum0, L0, l_end0, BLine, ma_L0, cell_id, cent_y0, ncid, cLast0, ncell0, l_sum, calBLineFlag)

sResults.IM = IM;

time=(k-1)*sParams.dt;


%fprintf(' >>>>>>>>>>> time = %d\n',k)
%fprintf('**************************************************\n')

%%%%%%%%%%%%%%% open frame specific files here if needed %%%%%%%%%%%%%%%


%fid100=fopen(['../data/whatever_channel_no_',num2str(i,'%03d'),'_frame_no_',num2str(k,'%03d'),'.txt'],'w');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% ANALYSIS ON EACH FRAME %%%%%%%%%%%%%%%%%%%%%%%%%%%IM%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[n1,n2] = size(IM);



%%%%%%%%%%%%%%%%%% IMAGE ENHANCEMENT %%%%%%%%%%%%%%%
[~, imth, imPreThr] = imageEnhancement(IM, bottom_line, n1,k, sParams);
sResults.imPreThr = imPreThr;


%%%%%%%% Projection along channel length %%%%%%%%%%%
% create an 1D average intensity profile of the channel
[miny, negch_y, x_mid, meanxav, xr_1, xr_2, m1] = findMiny(imth, sParams);




%%%%%%%%%%%%%%%%% 1st Segmentation to create binary image %%%%%%%%%%%
% after segmentation each connected component in CC represents a cell

[imbw] = channel_segment(miny,imth,sParams.mincellsize,sParams.eps,m1);

imbw0=imbw;


% [nlength,Lstart,Lend,Lcsum] = length_calculation(imbw,x_mid);


CC = bwconncomp(imbw,sParams.bwn);


%%%%%%%%%%%%%%%%%%% Adavptive minima search  %%%%%%%%%%%%%%%%



[imth] = segmentation_cleanup(CC,imth,sParams.min_std,sParams.Theta_cutoff,sParams.max_Xshift,x_mid,sParams.min_area_ratio,n1);

%[miny] = division_loss(CC,miny,nlength,LRaw0,agf,divf,min_lb,m1,m2);

[miny] = min_search(imth,xr_1,xr_2,sParams.pk_dist,sParams.pk_prom);

[imbw] = channel_segment(miny,imth,sParams.mincellsize,sParams.eps,m1);

[nlength,~,~,Lcsum] = length_calculation(imbw,x_mid);

%LRaw = nlength;


[miny] = adaptive_min_search(imth,CC,miny,miny0,negch_y,sParams.agf,sParams.divf,sParams.pdelta,nlength,Lcsum0,Lcsum,sParams.pk_prom,sParams.pk_dist,xr_1,xr_2,meanxav,k,n1);


[imbw] = channel_segment(miny,imth,sParams.mincellsize,sParams.eps,m1);
[nlength,Lstart,Lend,~] = length_calculation(imbw,x_mid);


CC = bwconncomp(imbw,sParams.bwn);

s  = regionprops(CC,'Centroid');
centroids = cat(1, s.Centroid);
cent_y=centroids(:,2);
cent_y=sort(cent_y);

%%%%%%%%%%%%%%%% check end cell division and cell intrusion %%%%%%%%%%%%%%%

[endCellDiv, endExt, cellIntrusion] = end_cell_check(nlength,Lstart,Lend,cent_y,L0,l_end0,sParams.divf,sParams.pdelta,sParams.max_dl_tot,k);


%%%%%%%%%%%%%%%% Remove cell intrusion %%%%%%%%%%%%%%%

if (cellIntrusion > sParams.eps)
    [imth] = end_channel_clear(imth,Lend(end-1),n1,k);
end

%%%%%%%%%%%%%%%% Re-calibrate bottom line %%%%%%%%%%%%%%%

if ( cent_y(end) <= n1 - BLine )
    calBLineFlag = 0;
 %   fprintf('BLine -> bottom_line. cY= %d, line = %d \n', cent_y(end), BLine)
end

if ( calBLineFlag > eps )
    L_check = n1 - BLine;
else
    L_check = Lend(end);
end

%fprintf('check for boundary cell : Lcheck = %d, calBLineFlag = %d \n', L_check, calBLineFlag)

if( (L_check + sParams.pdelta >= bottom_line)  && calBLineFlag < eps  || ( calBLineFlag > sParams.eps && cent_y(end) > n1 - BLine ) )

    %fprintf('New BLine calculation \n')

    if ( calBLineFlag < eps  &&  endCellDiv < sParams.eps )

        BLine = n1 - Lstart(end);

    elseif ( calBLineFlag < eps  &&  endCellDiv > sParams.eps )

        if (endExt < eps)
            BLine = n1 - Lstart(end-1);
        else
            BLine = n1 - Lstart(end);
        end

    end

    [imth,BLine,~,~] = determine_BLine(imth,Lend,Lstart,BLine,sParams.pdelta,bottom_line,calBLineFlag,l_sum,sParams.max_dbline,endCellDiv,n1,k);

end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% Final binarization and length calculation %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[imbw] = channel_segment(miny,imth,sParams.mincellsize,sParams.eps,m1);

[nlength,~,Lend,Lcsum] = length_calculation(imbw,x_mid);

%------- y-position of last cell centroid --------

CC2 = bwconncomp(imbw,sParams.bwn);
ncell = CC2.NumObjects;
s  = regionprops(CC2,'Centroid');
centroids2 = cat(1, s.Centroid);
cent_y=centroids2(:,2);
cent_y=sort(cent_y);

cLast = max(cent_y);

%-------- major axis length calculation ----------

[ma_L] = major_axis_length(CC2);

%------------------ lower pole position of the last cell -----------------------

l_end = Lend(end);
cy_end = cent_y(end);

%fprintf(fid20,'%f %f %f\n',time,sParams.dx*nlength(1), sParams.dx*ma_L(1) );

%-------------------------------------------------------------------------------
%%%%%%%%%%%%%%% plot segmented images %%%%%%%%%%%%%%%
sResults.CC2 = CC2;
sResults.imbw0 = imbw0;
sResults.bottom_line = bottom_line;
sResults.BLine = BLine;
sResults.k = k;
sResults.NumberImages = NumberImages;
sResults.i = i;
sResults.c = c;
if(sParams.IwantPlot > sParams.eps)
    if(k >= sParams.plot_start_time && k <= sParams.plot_end_time)
        %plot_channel(CC2, IM,imbw0,bottom_line,BLine,k,NumberImages,i,c);
    end
end


%-------------------------------------------------------------------------------------------------



%----------------- for first frame : store L0 then stop the loop and continue here -------------

if(k==1)
    L0 = nlength;
    cLast0 = cLast;
    cell_id = initiate_cell(cell_id, ncell);
    ncid = ncell;
    l_end0 = l_end;
    cent_y0 = cent_y;
    %cy_end0 = cy_end;
    ncell0 = ncell;
    %LRaw0 = LRaw;
    miny0 = miny;
    Lcsum0 = Lcsum;
    ma_L0=ma_L;

else



    %===============================================================================================
    flagCellDiv=0;		% flag to indicate cell division
    flagCellExt=0;		% flag to indicate cell extrusion

    Ndiv=0;
    Next=0;


    %nlength;
    % L0;


    %-----------------------------------------------------------------------------------------------
    %%%%%%%%%%%%%%%%% Cases of cell division %%%%%%%%%%%%%%

    %--------------- check for cell division --------------
    %Lmin = min(nlength);
    %Lmin0 = min(L0);

    if(numel(nlength) > numel(L0))		% to determine normal cell div: number increases
        flagCellDiv=1;
    else
        for kk=1:numel(nlength)			% div + extrusion: number may remain same
            if(nlength(kk) < sParams.divf*L0(kk))
                flagCellDiv=1;
                break;
            end
        end
    end


    %fprintf('new and old min length = %d %d\n', Lmin, Lmin0)
    %fprintf('new and old cell no = %d %d\n', numel(nlength), numel(L0))
    % fprintf('deivcheck2 = %d\n',flagCellDiv)
    % fprintf('deivcheck = %d\n',flagCellDiv)
    %------------------------------------------------------



    %--------------- cell div has happened ----------------
    if(flagCellDiv > eps) && not(disableCellId)

   %     fprintf('cell div at time = %d\n',k)

        [cell_id, ncid, Ndiv] = cell_division(nlength, L0, ma_L, ma_L0, cell_id, time, cent_y0, ncell, ncid, sParams.divf,sParams.fil_length,sParams.fil_div, sParams.pdelta);

    end



    %-----------------------------------------------------------------------------------------------
    %%%%%%%%%%%%%%%%% Cases of cell extrusion %%%%%%%%%%%%%%

    %--------------- check for cell extrusion --------------
    if(cLast0 > cLast + sParams.pdelta && Ndiv > sParams.eps)
        flagCellExt=1;
    end

    %if(l_end < l_end0 - pdelta) flagCellExt=1; end

    if(ncell-Ndiv < ncell0)
        flagCellExt=1;
    end

    %-------------------------------------------------------

    %--------------- cell extrusion has happened ----------------
    if(flagCellExt > eps) && not(disableCellId)

    %    fprintf('cell extrusion at time = %d\n',k)

        [cell_id, Next] = cell_extrusion(cent_y, cent_y0, cell_id, ncell, Next, Ndiv,sParams.pdelta);

    end





    %%%%%%%%%%%%%%% plot %%%%%%%%%%%%%%%



    %%%%%%%%%%%%%%%%%%% Stop in case of error %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % balance cell number from division and extrusion:
if not(disableCellId)
    dum_cn_1 = ncell;
    dum_cn_2 = ncell0 + Ndiv - Next;

    % balance from cell_id structure:

    max_cell_index = max(cell_id(:,1));

    if (abs(dum_cn_1-dum_cn_2) > eps || abs(ncell - max_cell_index) > eps)

        fid90=fopen(['../data/cell_error_',char(c(i)),'.txt'],'w');
        for kk=1:sParams.max_cell_no
          %  fprintf(fid90,'%f %f %f %f %f %f %f %f\n',cell_id(kk,1),cell_id(kk,2),cell_id(kk,3),cell_id(kk,4),cell_id(kk,5),cell_id(kk,6),cell_id(kk,7),cell_id(kk,8) );
        end

     %   fprintf('cell count error at time = %d\n',k);

        return;

    end

end
    %==============================>>> STORE THE CURRENT VARIABLES FOR NEXT STEP <<<=====================================

    %L0=[];
    %LRaw0=[];
    %ma_L0=[];
    %Lcsum0=[];

    L0 = nlength;
    cLast0 = cLast;
    l_end0 = l_end;
    cent_y0 = cent_y;
    %cy_end0 = cy_end;
    ncell0 = ncell;
    %LRaw0 = LRaw;
    Lcsum0 = Lcsum;
    miny0 = miny;
    ma_L0=ma_L;

end
