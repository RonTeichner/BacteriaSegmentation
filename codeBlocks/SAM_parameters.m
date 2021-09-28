function sParams = SAM_parameters()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% global parameters etc %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sParams.dx = 50/310 ;		% pixel length in micro meter
sParams.dt = 1 ;		% frame rate in min
sParams.eps = 1E-6;		% small number : numerical tolerence
sParams.IwantPlot = 1;		% if frame-by-frame plot is not needed then put IwantPlot=1 ortherwise 0
sParams.plot_start_time = 0 ;
sParams.plot_end_time = 100;
sParams.sigma = 1;		% stn div of the gauss filter
sParams.gs = 3*sParams.sigma;		% size of gauss filter window = 3 x sigma
sParams.med_size = 3;		% size of median filter window = med_size x med_size pix
sParams.Rsharp = 4;		% Radius value used in imsharp
sParams.Asharp = 6;		% Amount of sharpness enhansement
sParams.R_imopen = 20;		% radius for imopen in background (BG) preparation
sParams.thr = 1500;		% threshold value to binarize image ~ 1500
sParams.coffthr = 0.45;		% threshold for cutoff position along-y
sParams.pk_dist = 8;		% min peak distance tolerance in FindPeaks
sParams.pk_prom = 0.5;		% min peak prominence tolerance in FindPeaks ~ 0.45
sParams.divf = 0.65;		% division length reduction parameter, L_new < divf*L_old, used in prevention of cell div loss
sParams.fil_length = 30;	% cell size >= fil_length is considered for possible filamentation
sParams.fil_div = 10;		% when cell_L > 40 pix, asymmetric cell div : L0 - L > fil_div, then div counted.
sParams.agf = 1.50;		% abnormal growth parameter, L_new > agf*L_old, used in prevention of cell div loss
sParams.min_lb = 10;		% minimal length at birth, to supress over segmentation
sParams.max_dbline = 15;	% max allowed change in new BLine(bottom line), while calculating from l_sum
sParams.max_dl_tot = 8;		% max change in total length of cells : used to check cell intrusion into MF-channel
sParams.bwn = 4; 		%connectivity for bw_conn_comp
sParams.mincellsize = 20;	%no of pixel, any smaller object is to be removed as noise/abbaration
sParams.min_std = 5;		% min value of std of intensity profile, used to determine if an  object in CC contains cells or not.
sParams.max_cell_no = 150;	% no of rows of cell_id matrix, to be fixed at some opt size
sParams.pdelta = 3;		% pix no fluctuation in level set, due to determination of level set from relative % quantities like intensity ratio, mean intensity at t, etc. << new cell size
sParams.max_Xshift = 8;		% max distance of object center_X from the image center (imcenter) to be allowd % used to remove random cell/object error from dynamic thresholding
sParams.Theta_cutoff = 30;	% objects/cells oriented with the channel are selected, any object with % orientation less than Theta_cutoff is removed
sParams.end_ch_high = 8000;	% high values representing clogging cells at channel end. Used to calculate bottom line.
sParams.min_area_ratio = 0.05;	% min area/ convex_area ratio allowed for cells