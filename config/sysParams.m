%% Simulation parameters : (C&S)
L = 5;
K = 10;
M_tx_h = 5;  % Number of horizontal transmit antennas at R-BS
M_tx_v = 5;  % Number of vertical transmit antennas at R-BS
M_rx_h = 5;  % Number of horizontal receive antennas at R-BS
M_rx_v = 5;  % Number of vertical receive antennas at R-BS
Mt = M_tx_h*M_tx_v;
Mr= M_rx_h*M_rx_v;
fc = 10e9; % 10GHz  operating frequncy
C_light = physconst('LightSpeed'); % speed of light
wavelength = C_light/fc;
alpha_pathloss = 3;  % Path-loss exponent (e.g., urban environment)
invsigma2_factor = 1e11;  %sigma2 = -110dBm

beta_0 = invsigma2_factor*(wavelength / (4 * pi))^2;  % Reference channel gain at 1m scaled by standard deviation of noise variance
K_factor = 10;  % Example Rician K-factor
excessivePL = 1e-2;

B = 30e6;  % Bandwidth
gamma_BW = sqrt(pi^2/3);
Brms = B * gamma_BW;  % Root-mean-squared bandwidth
sigma2 =1; %normalized noise power -80dBm
[sigma2a, sigma2e, sigma2k, sigma2SI] = deal(sigma2);
Rc = sigma2*(1/Mr)*eye(Mr);
Sigman = (1/Mr)*(sigma2a+sigma2SI)*eye(Mr)+Rc;
RCS =0.01*(1+1j)/sqrt(2);
Pmax = 1e2;

% Thresholds on metrics
rho_ul = 0.1; rho_dl = 0.5; rho_est = 0.001; % Thresholds for penalties
epsilon = 1e-3;