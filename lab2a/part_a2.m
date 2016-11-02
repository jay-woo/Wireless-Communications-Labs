clear all;
load('2User2AntennaBS.mat');

% Calculates the time delay between Tx and Rx
training_lim = 1:20000;
[r1, lags1] = xcorr(x1(training_lim), y1(training_lim));
[r2, lags2] = xcorr(x2(training_lim), y2(training_lim));
[i, idx1] = max(r1);
[i, idx2] = max(r2);
delay1 = lags1(idx1);
delay2 = lags2(idx1);

% Estimates the channel responses
n_bits = 40 * 128;
training_lim1 = 5001:5000 + n_bits;
training_lim2 = 15121:15120 + n_bits;
delay_lim1 = training_lim1 - delay1;
delay_lim2 = training_lim2 - delay2;
h11 = mean(y1(delay_lim1) ./ x1(training_lim1));
h12 = mean(y1(delay_lim2) ./ x2(training_lim2));
h21 = mean(y2(delay_lim1) ./ x1(training_lim1));
h22 = mean(y2(delay_lim2) ./ x2(training_lim2));
h1 = [h11; h21];
h2 = [h12; h22];

% Gets covariance matrix
Y = [y1, y2]';
sigma = var(y1(1:5000));
A = h1*h1' + h2*h2' + sigma * eye(2);
w1 = inv(A) * h1;
w2 = inv(A) * h2;

x1_est = w1' * Y;
x2_est = w2' * Y;

% Smooths the signal
kernel = 1/10 * ones(10, 1);
x1_est = filter(kernel, 1, x1_est);
x2_est = filter(kernel, 1, x2_est);

% Gets the location of the payload data
payload_lim1 = 5000*3 + 40*128*2 + 1;
payload_lim2 = payload_lim1 + 40*1024;
payload_lim = payload_lim1:payload_lim2;
payload_delay1 = payload_lim - delay1;
payload_delay2 = payload_lim - delay2;

% Measures error
bits1 = sign(real(x1_est(payload_delay1)));
bits2 = sign(real(x2_est(payload_delay2)));
bits1 = (bits1(20:40:end) + 1) / 2;
bits2 = (bits2(20:40:end) + 1) / 2;
bits1 = floor(bits1); bits2 = floor(bits2);
actual_bits1 = x1(payload_lim);
actual_bits2 = x2(payload_lim);
actual_bits1 = (actual_bits1(20:40:end) + 1) / 2;
actual_bits2 = (actual_bits2(20:40:end) + 1) / 2;
actual_bits1 = floor(actual_bits1); actual_bits2 = floor(actual_bits2);

error1 = sum(xor(bits1', actual_bits1));
error2 = sum(xor(bits2', actual_bits2));