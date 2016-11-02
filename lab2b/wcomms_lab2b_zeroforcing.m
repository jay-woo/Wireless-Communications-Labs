clear all;

num_antennas = 4;
num_bits = 128;
bit_length = 32;
zero_space = 1000;
X = zeros(4, num_bits * bit_length * num_antennas);
limits = 1:num_bits * bit_length;

for i = 1:num_antennas
    x = randi([0 1], 1, num_bits) + j*randi([0 1], 1, num_bits);
    x = round((x - (0.5+0.5j)) * 2);
    pulse = ones(bit_length, 1);
    x = upsample(x, bit_length);
    x = filter(pulse, 1, x);
    
    X(i, limits) = x;
    limits = limits + num_bits * bit_length;
end

Y = MIMOChannel4x4(X);

% Estimates the channel responses
limits = 1:num_bits * bit_length;
H = zeros(num_antennas);
for i = 1:num_antennas
    x = X(i, limits);
    for j = 1:num_antennas
        y = Y(j, limits);
        H(j, i) = mean(y ./ x);
    end
    limits = limits + num_bits * bit_length;
end

% Estimates the original two signals
W_dag1 = [1, 0, 0, 0] / H;
W_dag2 = [0, 1, 0, 0] / H;
W_dag3 = [0, 0, 1, 0] / H;
W_dag4 = [0, 0, 0, 1] / H;

x1_est = W_dag1 * Y;
x2_est = W_dag2 * Y;
x3_est = W_dag3 * Y;
x4_est = W_dag4 * Y;
X_est = [x1_est; x2_est; x3_est; x4_est];

save('H');