function [imth] = segmentation_cleanup(CC,imth,min_std,Theta_cutoff,max_Xshift,x_mid,min_area_ratio,n1)

%% ------------ cleanup of first segmentation result to remove objects 
%%		not containing cells ----------




  ncell = CC.NumObjects ;
 
  %---------------------- remove components without cells
  %---------------------- smaller st.dv. if cell is not present 
  

  for kk=1:ncell
  dum = imth(CC.PixelIdxList{kk});
   if(std(dum(:)) < min_std)
   %fprintf('object removed : MSD | obj_id = %d\n',kk)
   imth(CC.PixelIdxList{kk}) = 0;
   end

  end

  %---------------------- remove components without cells
  %---------------------- X-oriented cell / bg intensity removed
  %---------------------- orientation of each element/object checked if found not to be
  %                       along Y-axis then removed as BG/Passing cell

  s = regionprops(CC,'Orientation');
  ort = cat(1, s.Orientation);
  
  for kk=1:ncell
  dum = ort(kk);			% orientation of the kk-th element
  if( abs(dum)<=Theta_cutoff)
%  fprintf('object removed : orientation | obj_id = %d\n',kk)
  imth(CC.PixelIdxList{kk}) = 0;
  end
  end


  %---------------------- remove components without cells
  %---------------------- X-shifted cell / bg intensity removed
  %---------------------- centriod_X of each element/object checked if found to be shifted
  %                       away from 1st cell centroid_X then removed as BG/Passing cell

  s = regionprops(CC,'Centroid');
  cent = cat(1, s.Centroid);
  cent_x = cent(:,1); 
  imcenter = x_mid ;			% round(n2/2);		% center_X of image 

  for kk=1:ncell
  dum = cent_x(kk);			% center_X of the kk-th element
  if( abs(dum-imcenter) >= max_Xshift)
%  fprintf('object removed : x-shift | obj_id = %d\n',kk)
  imth(CC.PixelIdxList{kk}) = 0;
  end
  end


  %---------------------- area of object / area of bounding box
  %---------------------- proxy for orientation

  s = regionprops(CC,'Extent'); 
  area_ratio = cat(1, s.Extent);
 
  for kk=1:ncell
  dum = area_ratio(kk);			% area/convex area of the kk-th element
  if(dum <= min_area_ratio)
 % fprintf('object removed : area ratio | obj_id = %d\n',kk)
  imth(CC.PixelIdxList{kk}) = 0;
  end
  end











