% 
% cris_test1 -- compare IASI CrIS with true CrIS
% 
% reference truth: start with kcarta radiances, convolve to the 
% CrIS user grid, and call the result "true CrIS".
% 
% deconvolution: start with kcarta radiances, convolve to IASI
% radiances ("true IASI"), and translate to CrIS with iasi2cris, 
% to get "IASI CrIS".  Compare IASI CrIS to true CrIS.
%

%-----------------
% test parameters
%-----------------

addpath /home/motteler/cris/ccast/source
addpath /home/motteler/cris/airs_decon/test
addpath /home/motteler/cris/airs_decon/source

warning('off', 'MATLAB:imagesci:hdf:removalWarningHDFSD');

% test params
band = 'LW';
hapod = 1;
app   = 'noapp';

% opts for inst_params and iasi2cris
opt1 = struct;
opt1.hapod = hapod;
opt1.resmode = 'hires2';

% kcarta test data
kcdir = '/home/motteler/cris/sergio/JUNK2012/';
flist =  dir(fullfile(kcdir, 'convolved_kcart*.mat'));

% get CrIS inst and user params
wlaser = 773.1301;  % nominal value
[inst, user] = inst_params(band, wlaser, opt1);

%-----------------------------
% get true IASI and true CrIS
%-----------------------------

% loop on kcarta files
rad1 = []; rad2 = [];
for i = 1 : length(flist)
  d1 = load(fullfile(kcdir, flist(i).name));
  vkc = d1.w(:); rkc = d1.r(:);

  % kcarta to IASI channel radiances
  [rtmp, ftmp] = kc2iasi(rkc, vkc);
  rad1 = [rad1, rtmp];
  frq1 = ftmp(:);

  % kcarta to CrIS channel radiances 
  [rtmp, ftmp] = kc2cris(user, rkc, vkc);
  rad2 = [rad2, rtmp];
  frq2 = ftmp(:);

  fprintf(1, '.');
end
fprintf(1, '\n')
clear d1 vkc rkc

%------------------------
% transform IASI to CrIS
%------------------------

if ~hapod [rad4, frq4] = iasi2cris(rad1, frq1, opt1); end
if hapod [rad4_ham, frq4] = iasi2cris(rad1, frq1, opt1); end

% option to apodize true CrIS
if hapod
  app = 'hamm';
  rad2_ham = hamm_app(rad2);
end

%-----------------
% stats and plots
%-----------------

% take radiances to brightness temps
bt1 = real(rad2bt(frq1, rad1));   % true IASI
bt2 = real(rad2bt(frq2, rad2));   % true CrIS
bt4 = real(rad2bt(frq4, rad4));   % IASI CrIS
bt2_ham = real(rad2bt(frq2, rad2_ham));
bt4_ham = real(rad2bt(frq4, rad4_ham));

% plot parameters
[i2, i4] = seq_match(frq2, frq4); 
pv1 = min(frq2(i2)) - 10; 
pv2 = max(frq2(i2)) + 10;

% IASI and CrIS spectra
figure(1); clf; j = 1; 
plot(frq1, bt1(:,j), frq2, bt2(:,j), frq4, bt4(:,j))
ax(1)=pv1; ax(2)=pv2; ax(3)=200; ax(4)=300; axis(ax)
legend('true IASI', 'true CrIS', 'IASI CrIS', ...
       'location', 'southeast')
xlabel('wavenumber'); ylabel('brighness temp')
title(sprintf('IASI and CrIS %s profile %d, %s', band, j, app));
grid on; zoom on
% saveas(gcf, sprintf('iasi_cris_spec_%s_%s_%s', band,opt1.resmode,app), 'png')

% IASI CrIS minus true CrIS mean
figure(4); clf
h1=subplot(2,1,1);
[i2, i4] = seq_match(frq2, frq4);
%plot(frq2(i2), mean(bt4(i4,:) - bt2(i2,:), 2),'LineWidth',1); hold on;
plot(frq2(i2), 1000*mean(bt4_ham(i4,:) - bt2_ham(i2,:),2),'LineWidth',1.5);
%ax = axis; ax(1)=pv1; ax(2)=pv2; axis(ax); xlabel('wavenumber'); 
axis([pv1 pv2 -0.045 4.5]);ylabel('dBT (mK)')
%title(sprintf('IASI CrIS - true CrIS %s mean & stdev %s', band,app));
grid on; zoom on

% IASI CrIS minus true CrIS std
h2=subplot(2,1,2);
%plot(frq2(i2), std(bt4(i4,:) - bt2(i2,:), 0, 2),'LineWidth',1); hold on;
plot(frq2(i2), 1000*std(bt4_ham(i4,:) - bt2_ham(i2,:), 0, 2),'LineWidth',1.5)
%ax = axis; ax(1)=pv1; ax(2)=pv2; axis(ax);
axis([pv1 pv2 0 1]);
xlabel('wavenumber (cm^{-1})'); ylabel('dBT (mK)')
%title(sprintf('IASI CrIS minus true CrIS %s std', band));
grid on; zoom on
% saveas(gcf, sprintf('iasi_cris_diff_%s', band), 'png')
% aslprint(sprintf('iasi_cris_diff_%s_%s_%s.png', band,opt1.resmode,app));
  linkaxes([h1 h2],'x');set(h1,'xticklabel','');
  pp1=get(h1,'position');set(h1,'position',[pp1(1) pp1(2)-pp1(4)*0.1 pp1(3) pp1(4)*1.1])
  pp2=get(h2,'position');set(h2,'position',[pp2(1) pp2(2)+pp2(4)*0.1 pp2(3) pp2(4)*1.1])
>
