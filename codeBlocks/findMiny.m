function [miny, negch_y, x_mid, meanxav, xr_1, xr_2, m1] = findMiny(imth, sParams)
 
 [n1,n2] = size(imth);
 
 x_av=mean(imth,2);
  y_av=mean(imth,1);
  x_av = x_av/mean(x_av);
  y_av = y_av/mean(y_av);

  
  [m1,m2]=cutoff_pos(x_av,sParams.coffthr);
  [m3,m4]=cutoff_pos(y_av,sParams.coffthr);

  x_mid = find(y_av==max(y_av));				

  % correct for global up/down shift in detection 
  %---- extracted part contain image ~ from 1st pole to last pole ------- 

  if (m3 - sParams.pdelta > 1)
  xr_1 = m3 - sParams.pdelta;
  else
  xr_1 = m3;
  end

  if (m4 + sParams.pdelta < n2)
  xr_2 = m4 + sParams.pdelta;
  else
  xr_2 = m4;
  end 

  x_av=mean(imth(:,xr_1:xr_2),2);
  meanxav = mean(x_av);
  ch_y = x_av/mean(x_av);	
  
  %----------------------------------------------------------------------
   




  %%%%%%%%%%%%%%%%%%% Local max and min of average column  %%%%%%%%%%%
  
  % average intensity profile is inverted and up-shifted to find intensity minima as a peaks

  %%--------------------------------------------------------

  negch_y = -ch_y + max(ch_y) + 0.1;
  [dps,dpy] = findpeaks(negch_y,'MinPeakDistance',sParams.pk_dist,'MinPeakProminence',sParams.pk_prom);	

  miny = dpy;				% position of the minima
  
  end