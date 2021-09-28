function  [IM, imth, imPreThr] = imageEnhancement(IM, bottom_line, n1, k, sParams)

 %%%%%%%%%%%%%%%%%% IMAGE ENHANCEMENT %%%%%%%%%%%%%%%
   
  %--------------------------------------------------- BG substraction 
  %[IM1] = end_channel_clear(IM,bottom_line,n1,k);
  background = imopen(IM,strel('disk',sParams.R_imopen));
  IM = IM - background;
  
  %im = medfilt2(IM, [med_size med_size]);
  
  %------------------ Gaussian filter ----------------   >>> IMPORTANT <<<
  im = imfilter(double(IM),fspecial('gaussian',[sParams.gs sParams.gs], sParams.sigma));
  
  
  %------------------ Sharpening ---------------------   >>> IMPORTANT <<<
  im = imsharpen(im,'Radius',sParams.Rsharp,'Amount',sParams.Asharp);
  
  imPreThr = im;
  %%%%%%%%%%%%%%%%%%% Thresholding  %%%%%%%%%%%%%%%%%%
  %--------------------------------------------------    >>> IMPORTANT <<<
  imth=im;
  imth(im < sParams.thr) = 0;					% using fixed threshold


  %%%%%%%%%%%%%%%%%%%%% Clear end channel %%%%%%%%%%%%%%%%%%%%
  % everything below bottomline is removed

  [imth] = end_channel_clear(imth,bottom_line,n1,k);	
  
 end