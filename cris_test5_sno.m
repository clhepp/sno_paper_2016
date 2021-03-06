% 
% cris_test5 -- compare AIRS CrIS with true CrIS
% 
% reference truth: start with kcarta radiances, convolve to the 
% CrIS user grid, and call the result "true CrIS".
% 
% deconvolution: start with kcarta radiances, convolve to AIRS
% channel radiances (“true AIRS”), deconvolve to an intermediate
% grid, e.g. 0.05 1/cm spacing, and reconvolve to the CrIS user 
% grid (“AIRS Cris”).  Compare AIRS CrIS to true CrIS profiles 
% and any of the three CrIS bands
%

%-----------------
% test parameters
%-----------------

% set paths to asl libs
addpath /asl/packages/airs_decon/test        % <- original run directory
addpath /asl/packages/airs_decon/source
addpath /asl/packages/airs_decon/h4tools
addpath /asl/packages/ccast/source

warning('off','MATLAB:imagesci:hdf:removalWarningHDFSD');

% test params
band = 'MW';            % cris band {'LW','MW','SW'}
hapod = 1;              % flag for Hamming apodization
dvb = 0.1;              % deconvolution frequency step
bfile = '/asl/s1/chepplew/tmp/bconv4.mat';   % deconvolution temp file

% kcarta test data
kcdir = '/home/motteler/cris/sergio/JUNK2012/';
flist =  dir(fullfile(kcdir, 'convolved_kcart*.mat'));

% get the kcarta to AIRS convolution matrix
sfile = '/asl/matlab2012/srftest/srftables_m140f_withfake_mar08.hdf';
cfreq = load('freq2645.txt');
cfreq = trim_chans(cfreq);
dvk = 0.0025; 
[sconv, sfreq, ofreq] = mksconv2(sfile, cfreq, dvk);

% get CrIS inst and user params
opts.resmode = 'lowres';
wlaser = 773.1301;  % nominal value
[inst, user] = inst_params(band, wlaser, opts);

%-----------------------------
% get true CrIS and true AIRS
%-----------------------------

% loop on kcarta files
rad1 = []; rad2 = [];
for i = 1 : length(flist)
  d1 = load(fullfile(kcdir, flist(i).name));
  vkc = d1.w(:); rkc = d1.r(:);

  % convolve kcarta radiances to CrIS channels
  [rtmp, ftmp] = kc2cris(user, rkc, vkc);
  rad1 = [rad1, rtmp];

  % apply the AIRS convolution
  ix = interp1(vkc, 1:length(rkc), sfreq, 'nearest');
  rtmp = sconv * rkc(ix);
  rad2 = [rad2, rtmp];

  fprintf(1, '.');
end
fprintf(1, '\n')
frq1 = ftmp(:);     % from kc2cris
frq2 = ofreq(:);    % from mksconv
clear d1 vkc rkc

%------------------------
% transform AIRS to CrIS
%------------------------

opt1.dvb     = dvb;
opt1.bfile   = bfile;
opt1.hapod   = hapod;
opt1.resmode = 'lowres';  % 'hires2';

if ~hapod [rad4, frq4, opt2]    = airs2cris(rad2, frq2, sfile, opt1); end
if hapod [rad4_ham, frq4, opt2] = airs2cris(rad2, frq2, sfile, opt1); end
rad3 = opt2.brad;
bfrq = opt2.bfrq;

% option to apodize true CrIS
if hapod  rad1_ham = hamm_app(rad1);  end
if ~hapod rad1     = hamm_app(rad1);  end

%-----------------
% stats and plots
%-----------------

% take radiances to brightness temps
bt1 = real(rad2bt(frq1, rad1));                % true CrIS
bt2 = real(rad2bt(frq2, rad2));                % true AIRS
bt3 = real(rad2bt(bfrq, rad3));                % deconvolved AIRS
if ~hapod bt4 = real(rad2bt(frq4, rad4));  end % AIRS CrIS
if ~hapod bt1 = real(rad2bt(frq1, rad1));  end
if hapod bt1_ham = real(rad2bt(frq1, rad1_ham));  end
if hapod bt4_ham = real(rad2bt(frq4, rad4_ham));  end

% plot parameters
[i1, i4] = seq_match(frq1, frq4); 

pv1 = min(frq1(i1)) - 10; 
pv2 = max(frq1(i1)) + 10;
if hapod,  psf = 0.2; app = 'hamm';
else psf = 2.0; app = 'noap'; end

% AIRS and CrIS spectra
figure(1); clf; j = 1; 
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
plot(frq1, bt1(:,j), frq2, bt2(:,j), bfrq, bt3(:,j), frq4, bt4_ham(:,j))
ax(1)=pv1; ax(2)=pv2; ax(3)=180; ax(4)=320; axis(ax)
legend('true CrIS', 'true AIRS', 'AIRS dec', 'AIRS CrIS', ...
       'location', 'southeast')
xlabel('wavenumber'); ylabel('brighness temp')
title(sprintf('AIRS 1C and CrIS %s profile %d', band, j));
grid on; zoom on
pname = sprintf('airs_cris_spec_%s_%s', band, app);
% saveas(gcf, pname, 'png')
% export_fig([pname, '.pdf'], '-m2', '-transparent')

% AIRS CrIS minus true CrIS mean
figure(2); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
%h3=subplot(2,2,1);
[i1, i4] = seq_match(frq1, frq4);
plot(frq1(i1), mean(bt4(i4,:) - bt1(i1,:), 2),'LineWidth',1);hold on;
plot(frq1(i1), mean(bt4_ham(i4,:) - bt1_ham(i1,:),2),'LineWidth',1)
ax(1)=pv1; ax(2)=pv2; ax(3)=-psf; ax(4)=psf; axis(ax);
axis([pv1 pv2 -1.5 1.5]); legend('unapodized','Hamming ap.','Location','NorthEast');grid on;
%xlabel('wavenumber'); 
ylabel('AIRS - CrIS dBT (K)')
%title(sprintf('AIRS CrIS minus true CrIS %s mean', band));
grid on; zoom on

% AIRS CrIS minus true CrIS std
h4=subplot(2,2,4);
plot(frq1(i1), std(bt4(i4,:) - bt1(i1,:), 0, 2), 'LineWidth',1); hold on;
plot(frq1(i1), std(bt4_ham(i4,:) - bt1_ham(i1,:),0,2), 'LineWidth',1)
ax(1)=pv1; ax(2)=pv2; ax(3)=0; ax(4)=psf/2; axis(ax);
axis([pv1 pv2 0 1.0]); legend('Unapodized','Hamming ap.','Location','North');
xlabel('wavenumber (cm^{-1})'); ylabel('AIRS - CrIS dBT (K)')
%title(sprintf('AIRS CrIS minus true CrIS %s std', band));
grid on; zoom on
pname = sprintf('airs_cris_diff_%s_%s', band, app);
% saveas(gcf, pname, 'png')
% export_fig([pname, '.pdf'], '-m2', '-transparent')
  linkaxes([h1 h2],'x');set(h1,'xticklabel','');
  pp1=get(h1,'position');set(h1,'position',[pp1(1) pp1(2)-pp1(4)*0.1 pp1(3) pp1(4)*1.1])
  pp2=get(h2,'position');set(h2,'position',[pp2(1) pp2(2)+pp2(4)*0.1 pp2(3) pp2(4)*1.1])
>
hold on;
%%% Then plot the MW band: h3 = subplot(4,2,2) and h4 = subplot(4,2,4)
  linkaxes([h3 h4],'x');set(h3,'xticklabel','');
  pp3=get(h3,'position');set(h3,'position',[pp3(1) pp3(2)-pp3(4)*0.1 pp3(3) pp3(4)*1.1])
  pp4=get(h4,'position');set(h4,'position',[pp4(1) pp4(2)+pp4(4)*0.1 pp4(3) pp4(4)*1.1])
