f1 = fopen('received.dat','r');
x = fread(f1,'float32');
realSignal = x(101:2:end);
imaginarySignal = x(102:2:end);
kernel = 1/25 * ones(25, 1);

signal = (realSignal + imaginarySignal * 1i);
stripped = signal;
actualSignal = zeros(length(stripped), 1);
errorSum = 0;
psi_prev = 0;
P = 0.7;
I = 0.3;

for i=1:length(stripped)
    e = -real(stripped(i)) * imag(stripped(i));
    errorSum = errorSum + e;
    psi = psi_prev + P * e + I * errorSum;
    actualSignal(i) = stripped(i) * exp(1j * psi);
end

plot(real(actualSignal));

% chunkSize = 1e4;
% for i=1:chunkSize:length(stripped)
%  if i+chunkSize > length(stripped)
%  chunk = stripped(i:end);
%  else
%  chunk = stripped(i:i+chunkSize);
%  end
%  f = fftshift(fft(chunk.^2));
%  frequencies = linspace(-1, 1, length(f));
%  [foo, maxFreqIndex] = max(abs(f));
%  freqOffset = frequencies(maxFreqIndex)/2;
%  times = (0:length(chunk)-1)';
%  correctedChunk = chunk .* exp(-times*1i*pi*freqOffset);
%  
%  error = -sum(real(correctedChunk) .* imag(correctedChunk));
%  error_sum = error + errorSum;
% 
%  psi_next = psi_prev + P * error + I * errorSum;
%  psi_prev = psi_next;
%  
%  correctedChunk = correctedChunk .* exp(times*1i*psi_prev);
%  
%  if var(real(correctedChunk)) > var(imag(correctedChunk))
%  actualChunk = real(correctedChunk);
%  else
%  actualChunk = imag(correctedChunk);
%  end
%  
%  if i+chunkSize > length(stripped)
%  actualSignal(i:end) = actualChunk;
%  else
%  actualSignal(i:i+chunkSize) = actualChunk;
%  end
% end
% 
% plot(actualSignal)
% threshold = max(actualSignal)/2;
% i = 1;
% 
% while abs(actualSignal(i)) < threshold && i < length(actualSignal)
%  i = i+1;
% end
% j = length(actualSignal);
% while abs(actualSignal(j)) < threshold && j > 0
%  j = j-1;
% end
% stripped = actualSignal(i:j);
% stripped = filter(kernel, 1, stripped);
% 
% plot(stripped);