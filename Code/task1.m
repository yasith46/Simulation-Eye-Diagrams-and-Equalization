% Parameters
fs = 10;                                    % Sample freq
nSymbols = 1000;                            % No of symbols
t = -10*fs:1/fs:9.99*fs;                    % time
ts = 0:1/fs:9999/fs;


% Generating BPSK symbols
symbols = 2*(rand(1,nSymbols)>0.5)-1;
symbols_upsampled = [symbols;zeros(fs-1,length(symbols))];
symbols_upsampled = symbols_upsampled(:).';

stem(ts, symbols_upsampled); xlabel('Time'); ylabel('Amplitude');
title('BPSK Impulse Train');
axis([0 100 -1.2 1.2]); grid on; 


% Sinc filter convolution
sinc_num = sin(pi*t);
sinc_den = (pi*t); 
sinc_zero = find(abs(sinc_den) < 10^-10);   % Finding the t=0 position
sinc_filter = sinc_num./sinc_den; 
sinc_filter(sinc_zero) = 1; 

tx_signal_sinc = conv(symbols_upsampled, sinc_filter, 'same');
tx_signal_sinc_trimmed = tx_signal_sinc(1:10000);


% Raised cosine filter (RO = 0.5)
roll_off = 0.5;
cos_num= cos(roll_off*pi*t);
cos_den = (1 - (2 * roll_off * t).^2);
cos_zero = abs(cos_den)<10^-10;
Raised_cosine = cos_num./cos_den;
Raised_cosine(cos_zero) = pi/4;
rc_roll05 = sinc_filter.*Raised_cosine;

tx_signal_rcroll05 = conv(symbols_upsampled, rc_roll05, 'same');
tx_signal_rcroll05_trimmed = tx_signal_rcroll05(1:10000);

% Raised cosine filter (RO = 1)
roll_off = 1;
cos_num= cos(roll_off*pi*t);
cos_den = (1 - (2 * roll_off * t).^2);
cos_zero = abs(cos_den)<10^-10;
Raised_cosine = cos_num./cos_den;
Raised_cosine(cos_zero) = pi/4;
rc_roll1 = sinc_filter.*Raised_cosine;

tx_signal_rcroll1 = conv(symbols_upsampled, rc_roll1, 'same');
tx_signal_rcroll1_trimmed = tx_signal_rcroll1(1:10000);


% Eye diagrams
conv_tx_sinc_reshape = reshape(tx_signal_sinc_trimmed, fs*2, nSymbols*fs/20).';
conv_tx_rcroll05_reshape = reshape(tx_signal_rcroll05_trimmed, fs*2, nSymbols*fs/20).';
conv_tx_rcroll1_reshape = reshape(tx_signal_rcroll1_trimmed, fs*2, nSymbols*fs/20).';

% Sinc
figure;
subplot(6,2,[1,3]);
plot(t, sinc_filter);
title('Sinc Pulse shape');
xlabel('Time'); ylabel('Amplitude');
axis([-fs fs -0.5 1.2]); 
grid on;

subplot(6,2,[2,4]);
plot(0:1/fs:1.99, real(conv_tx_sinc_reshape).', 'b');
title('Eye diagram with sinc pulse');
xlabel('Time'); ylabel('Amplitude');
axis([0 2 -3 3]);
grid on;

% Raised Cosine RO=0.5
subplot(6,2,[5,7]);
plot(t, rc_roll05);
title('Raised Cosine (RO=0.5) Pulse shape');
xlabel('Time'); ylabel('Amplitude');
axis([-fs fs -0.5 1.2]); 
grid on;

subplot(6,2,[6,8]);
plot(0:1/fs:1.99, real(conv_tx_rcroll05_reshape).', 'b');
title('Eye diagram with raised cosine (RO=0.5) pulse');
xlabel('Time'); ylabel('Amplitude');
axis([0 2 -3 3]);
grid on;

% Raised Cosine RO=1
subplot(6,2,[9,11]); % Adjusted the index for the first subplot of RO=1
plot(t, rc_roll1);
title('Raised Cosine (RO=1) Pulse shape');
xlabel('Time'); ylabel('Amplitude');
axis([-fs fs -0.5 1.2]); 
grid on;

subplot(6,2,[10,12]); % Adjusted the index for the second subplot of RO=1
plot(0:1/fs:1.99, real(conv_tx_rcroll1_reshape).', 'b');
title('Eye diagram with raised cosine (RO=1) pulse');
xlabel('Time'); ylabel('Amplitude');
axis([0 2 -3 3]);
grid on;

% Adjust the vertical position of the subplots to add spacing
h = gcf;
h.Position(2) = h.Position(2)  - 10;