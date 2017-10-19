x = load('/Users/Hepplewhite/asl.maya/gitLib/asl_sno/data/L2.chan_prop.2002.10.22.v9.5.3.mat');
cmods = unique(x.cmod);                   % <- 17 cell
for i = 1:length(cmods)
j = ismember(x.cmod,cmods{i});            % provides index to use for valid cmods{i}
ModEds(i,:) = [max(x.cfreq(j)) min(x.cfreq(j))];
end
junk = sort(reshape(ModEds,34,1));
clear ModEds; ModEds = junk;
whos ModEds
figure(2);hold on;


bias=[d1(1).y d2a(1).y];
whos bias
xwn=[d1(1).x d2a(1).x];


ind=[];
xwn = [d1.x d2a.x];
xwn(1:5)
x(end-5:end)
xwn(end-5:end)
ind = [ind find(xwn > ModEds(2) & xwn < ModEds(3))];
ind = [ind find(xwn > ModEds(4) & xwn < ModEds(5))];
ind = [ind find(xwn > ModEds(6) & xwn < ModEds(7))];
ind = [ind find(xwn > ModEds(8) & xwn < ModEds(9))];
ind = [ind find(xwn > ModEds(10) & xwn < ModEds(11))];
ind = [ind find(xwn > ModEds(12) & xwn < ModEds(13))];
ind = [ind find(xwn > ModEds(14) & xwn < ModEds(15))];
ind = [ind find(xwn > ModEds(16) & xwn < ModEds(17))];
ind = [ind find(xwn > ModEds(18) & xwn < ModEds(19))];
ind = [ind find(xwn > ModEds(20) & xwn < ModEds(21))];
ind = [ind find(xwn > ModEds(22) & xwn < ModEds(23))];
ind = [ind find(xwn > ModEds(24) & xwn < ModEds(25))];
ind = [ind find(xwn > ModEds(26) & xwn < ModEds(27))];
ind = [ind find(xwn > ModEds(28) & xwn < ModEds(29))];
ind = [ind find(xwn > ModEds(30) & xwn < ModEds(31))];


  linkaxes([h1 h2],'x');set(h1,'xticklabel','');
  pp1=get(h1,'position');set(h1,'position',[pp1(1) pp1(2)-pp1(4)*0.1 pp1(3) pp1(4)*1.1])
  pp2=get(h2,'position');set(h2,'position',[pp2(1) pp2(2)+pp2(4)*0.1 pp2(3) pp2(4)*1.1])  


textfont = 16;
axisfont = 16;
flist =  dir('*.fig');
for i = 1 : length(flist)
  [~,fname] = fileparts(flist(i).name);
  open([fname,'.fig'])
  set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
  set(findall(gcf,'type','axes'), 'fontsize', axisfont)
  set(findall(gcf,'type','text'), 'fontSize', textfont)
  export_fig([fname,'.pdf']) 
  pause(5)
  close all
end

 h=get(gcf,'children');
>> get(get(gcf,'children'),'type')
  
