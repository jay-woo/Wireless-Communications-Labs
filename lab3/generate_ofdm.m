clear all;

seq = round(randi([0,1], 1, 64) - 0.5);
schmidl_cox = [seq, seq, seq];

known_ofdm = [];
known_seq = [];
for i = 1:4
    seq = round(randi([0,1], 1, 64) - 0.5);
    known_seq = [known_seq; seq];
    seq = ifft(seq);
    seq = [seq(49:end), seq] * 10;
    
    known_ofdm = [known_ofdm, seq];
end

ofdm = [];
for i = 1:20
    seq = round(randi([0,1], 1, 64) - 0.5);
    seq = ifft(seq);
    seq = [seq(49:end), seq] * 10;
    
    ofdm = [ofdm, seq];
end

zero_pad = zeros(1, 1e5);
final_seq = [zero_pad, schmidl_cox, known_ofdm, ofdm, zero_pad] / 50;

reals = real(final_seq);
imags = imag(final_seq);

file = fopen('sent.dat', 'w');
datFormat = zeros(2*length(final_seq),1);
datFormat(1:2:end) = reals;
datFormat(2:2:end) = imags;
fwrite(file, datFormat, 'float32');
fclose(file);

save('variables.mat');