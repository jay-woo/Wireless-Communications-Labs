clear all;

load('variables.mat');

f1 = fopen('received.dat','r');
x = fread(f1,'float32');
realSignal = x(101:2:end);
imagSignal = x(102:2:end);
sig = realSignal + 1j*imagSignal;
init_sig = sig(1.7e6:1.9e6);
threshold = 0.001;

for i = 1:length(init_sig)
    if abs(real(init_sig(i))) > threshold
        break; 
    end
end

for j = length(init_sig):-1:1
    if abs(real(init_sig(j))) > threshold
        break;
    end
end

y = init_sig(i+64:j);
correct_cfo_schmidl_cox;

limits = 64*2+17:64*2+80;
for i = 1:4
    known_ofdm_y(i,:) = fft(y_corrected(limits));
    limits = limits + 80;
end

H = (known_ofdm_y ./ known_seq);

for i = 1:20
    payload(i,:) = fft(y_corrected(limits));
    limits = limits + 80;
end

limits = 17:80;
for i = 1:20
    y_actual(i,:) = fft(ofdm(limits));
    limits = limits + 80;
end

hold on;
plot(sign(real(payload(5,:))));
plot(real(y_actual(5,:)));