pcol = [{'-bo'} {'-ro'} {'-ko'} {'-go'} {'-mo'} {'-co'} {'-b+'} {'-r+'} {'-k+'} {'-g+'} {'-m+'} {'-c+'} {'-bx'} {'-rx'} {'-kx'} {'-gx'} {'-mx'} {'-cx'}]

%   plot(f(j),bt(j),pcol{i})

   
for i=1:2:34
   r = find(d(1).x >= d(3).x(i) & d(1).x <= d(3).x(i+1));
   plot(d(1).x(r),d(1).y(r),pcol{1 + (i-1)/2}); if i ==1; hold on;end
%   plot(d(2).x(r),d(2).y(r),pcol{i});
end
