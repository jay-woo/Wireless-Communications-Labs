% Opens and unpacks the received signal
f1 = fopen('received.dat','r');
x = fread(f1,'float32');
realSignal = x(101:2:end);
imaginarySignal = x(102:2:end);
signal = (realSignal + imaginarySignal * 1i);
init_sig = signal(1.7e6:1.8e6);

% Finds the beginning and end of the transmission (greater than a threshold)
threshold = max(abs(init_sig))/3;
i = 1; 
j = length(init_sig);

while abs(init_sig(i)) < threshold && i < length(signal)
    i = i+1; 
end

while abs(init_sig(j)) < threshold && j > 0
    j = j-1;
end

stripped = init_sig(i:j);

% Corrects for frequency (Schmidl-Cox)
test = stripped(1+64:end);
start_idx = find_start_point_cox_schmidl(test, 20);
y_frame = test(start_idx:end);
avg_freq_error = 0;
for k = 1:64
    freq_error(k) = angle(y_frame(k+64)/y_frame(k))/64;
    avg_freq_error = avg_freq_error + angle(y_frame(k+64)/y_frame(k))/64;
end
avg_freq_error = avg_freq_error/64;

y_corrected = y_frame.*(exp(-1i*avg_freq_error*[1:length(y_frame)]'));
remaining_y = y_corrected(64*2 - 1 - start_idx +1: end);

% Calculates the channel response using known 4 known OFDM values
step1 = 1:80;
step2 = 1:64;
y_tilde = zeros(64*4, 1);
for i=1:4
    y = remaining_y(step1);
    tmp = y(end-63:end);
    y_tilde(step2) = fft(tmp);
    step1 = step1 + 80;
    step2 = step2 + 64;
end

load('variables.mat')

channel_estim = zeros(64*4, 1);
step = 1:64;
for i=1:4
    channel_estim(step) = known_seq(i, :);
    step = step + 64;
end
unavg_H = y_tilde ./ channel_estim;
avg_H = zeros(64, 1);

% Averages the channel response
for i=1:64
    avg_H(i) = (unavg_H(i) + unavg_H(i+64) + unavg_H(i+64*2) + unavg_H(i+64*3))/4;
end

% Decodes the remaining 20 OFDM sequences
limits = 17:80;
step = 1:64;
y_actual = zeros(64*20, 1);
for i = 1:20
   y_actual(step) = fft(ofdm(limits));
   limits = limits + 80;
   step = step + 64;
end

remaining_y = remaining_y(80*4+1: end);
step1 = 1:80;
step2 = 1:64;
rx_payload = zeros(64*10, 1);
for i=1:20
    y = remaining_y(step1);
    tmp = fft(y(end-63:end));
    rx_payload(step2) = tmp ./ avg_H;
    step1 = step1+80;
    step2 = step2+64;
end

% Actual bits contained in 'y_actual'
% Received/decoded bits contained in 'rx_payload'