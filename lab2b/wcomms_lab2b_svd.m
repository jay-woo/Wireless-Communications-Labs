clear all;

load('H.mat');

[U, S, V] = svd(H);

num_antennas = 4;
num_bits = 1280;
bit_length = 32;
X = zeros(4, num_bits * bit_length);

for i = 1:num_antennas
    x = randi([0 1], 1, num_bits) + 1i * randi([0 1], 1, num_bits);
    x = round((x - (0.5+0.5j)) * 2);
    pulse = ones(bit_length, 1);
    x = upsample(x, bit_length);
    x = filter(pulse, 1, x);
    
    X(i, :) = x;
end

X_new = V * X;
Y = MIMOChannel4x4(X_new);

X_est = U' * Y;
for i = 1:num_antennas
    X_est(i, :) = X_est(i, :) ./ S(i,i);
end