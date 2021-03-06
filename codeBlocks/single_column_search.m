function [newmin_sc] = single_column_search(imth,oldmin,pdelta,pk_prom,npk,dpk,xr_1,xr_2,meanxav,k,n1)

er = 1e-4;                   
midx = round((xr_1+xr_2)/2);

ch_y = imth(:,midx)/meanxav;
negch_y = -ch_y;


%%-----------------------------------------------

  j1 = oldmin - 3*pdelta ;
  j2 = oldmin + 3*pdelta ;

  new_chy = negch_y(j1:j2);
  
  for jj=1:npk							%%----- peak find loop
  pkp = pk_prom - jj*dpk;
  [peaksize,peakpos] = findpeaks(new_chy,'MinPeakProminence',pkp);					%,'MinPeakDistance',pk_dist
  nsize = length(peakpos);


  if(abs(nsize-1)<er)
  fprintf('New single column peak at jj=%d, prominence=%f, pk_height=%f\n', jj, pkp, peaksize)
  new_miny = j1 + sort(peakpos);
  break
  end

  end								%%----- peak find loop

  if(nsize<er)
  fprintf('Failed single column search: new min = old min \n')
  new_miny = oldmin;
  end


  newmin_sc = new_miny;


