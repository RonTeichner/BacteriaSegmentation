function [ma_L] = major_axis_length(CC2)

  er = 1E-4;
  

  %%%%%% find major axis %%%%%%
  s  = regionprops(CC2,'MajorAxisLength');  
  mal = cat(1, s.MajorAxisLength);

  s  = regionprops(CC2,'Centroid');
  centroids2 = cat(1, s.Centroid);
  cent_y=centroids2(:,2);

  dum = [cent_y, mal];

  sortedmat = sortrows(dum, 1);

  ma_L = sortedmat(:,2);



%  fprintf('major axis length calculated ------ \n')
