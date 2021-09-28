function [imth] = end_channel_clear(imth,bottom_line,n1,k)

  er = 1E-4;
  nr = 5;

  %%%%%% first frame manually cleared %%%%%%
  if(k == 1) 			%---------- IF(1)
  imth=imth;
  return
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  kstart = bottom_line;

  for kk = kstart:n1
  imth(kk,:) = 0;
  end

  %fprintf('channel below l_end cleared from = %d \n',kstart)
