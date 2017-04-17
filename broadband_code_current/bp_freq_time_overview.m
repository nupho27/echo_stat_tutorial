% 2013 07 30  Test for generating the time domain impulse after modifying
%             the transmit signal with the fish scattering response
% 2013 08 01  Test for doing Hilbert transform on the time domain fish
%             scattering response --> see if there's imaginary part in
%             the raw response that produces warnings in Hilbert transform

tx_opt = 3;

[y,t_y] = gen_tx(tx_opt);
y_fft = fft(y);
freq_y = 1/diff(t_y(1:2))/(length(y_fft)-1)*((1:(length(y_fft)+1)/2)-1);
dt = 1/(2*freq_y(end));

Rss = conj(y_fft).*y_fft;
Rss = Rss(1:length(freq_y)).';

bp_folder = '/mnt/storage/broadband_code_current/bpir_bpf_pool';
bp_file = 'bpf_a0.054m_dtheta0.001pi_fmax1500kHz_df500Hz.mat';
BP = load([bp_folder,'/',bp_file]);
BP.bp_y = interp1(BP.freq_bp,BP.bp,freq_y);

H_scat = repmat(Rss,1,size(BP.bp_y,2)).*BP.bp_y;
H_scat(isnan(H_scat)) = 0;

h_scat = ifftshift(ifft([H_scat;flipud(conj(H_scat(2:end,:)))]),1);
h_scat_env = abs(hilbert(h_scat));

t_h = (0:size(h_scat,1)-1)*dt;


% beampattern freq response overview
figure;
imagesc(freq_y/1e3,BP.theta/pi*180,...
        20*log10(abs(BP.bp_y))');
xlabel('Frequency (kHz)');
ylabel('Polar angle (deg)');
colorbar
title('Beampattern frequency response');
saveas(gcf,'/mnt/storage/broadband_code_current/bpir_bpf_pool/bp_freq_resp_overview.png','png');
saveas(gcf,'/mnt/storage/broadband_code_current/bpir_bpf_pool/bp_freq_resp_overview.fig','fig');

% Fish time domain response overview
figure;
imagesc(t_h*1e3,BP.theta/pi*180,h_scat_env');
xlabel('Time (ms)');
ylabel('Polar angle (deg)');
colorbar
title('Beampattern time domain response (with Rss), linear color');
xlim([5.1 5.6]);
saveas(gcf,'/mnt/storage/broadband_code_current/bpir_bpf_pool/bp_time_resp_overview_linear.png','png');
saveas(gcf,'/mnt/storage/broadband_code_current/bpir_bpf_pool/bp_time_resp_overview_linear.fig','fig');

figure;
imagesc(t_h*1e3,BP.theta/pi*180,20*log10(h_scat_env'));
xlabel('Time (ms)');
ylabel('Polar angle (deg)');
colorbar
c = caxis;
caxis([-60 c(2)])
title('Beampattern time domain response (with Rss), log color');
xlim([5.1 5.6]);
saveas(gcf,'/mnt/storage/broadband_code_current/bpir_bpf_pool/bp_time_resp_overview_log.png','png');
saveas(gcf,'/mnt/storage/broadband_code_current/bpir_bpf_pool/bp_time_resp_overview_log.fig','fig');
