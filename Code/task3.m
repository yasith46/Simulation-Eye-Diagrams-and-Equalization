Rs =10 ;                                % Symbol rate for the signal
Ts = 1/Rs ;                             % Symbol frequency
time = 0:Ts:100000;


data_bits = randi([0 1],1,numel(time));
PAM2_data = real(pskmod(data_bits,2));  % Representing bit 1 -> +1 and bit 0 ->-1 (PAM)


% Model a 3-tap multipath channel
channel_taps = [0.3 0.7 0.4] ;

% Apply channel distortion (convolution)
received_signal = conv(PAM2_data,channel_taps,"same"); %convolving


%Calculate Bit energy
bit_energy = sum(PAM2_data.^2)/length(PAM2_data) ;

 
% creating Zero forcing equalizer
% M - tap equalizer
Eb_No_dB = 0:10 ; % dB

for M=3:2:9 % Number of equalizer taps (odd values)
    N = (M-1)/2 ;
    Po = zeros(1,M);
    Po(N+1) = 1;
    Pr = toeplitz([channel_taps(2) channel_taps(1) zeros(1,M-2)],[channel_taps(2) channel_taps(3) zeros(1,M-2)]) ; % Toeplitz matrix with filter coeffients
    C = Pr\Po' ;
    BER_ISI = zeros(1,11);

    for n=1:numel(Eb_No_dB)
        Eb_No = 10^(Eb_No_dB(n)/10);
        No = bit_energy/Eb_No ;
        sigma = sqrt(No/2);
        rs_an = received_signal + sigma*randn(1,numel(received_signal));%signal after adding noise
        rs_ae = conv(rs_an,C,"same"); % Signal after the equalizer
        received_data_bits_ISI = real(pskdemod(rs_ae,2));
        bit_errors_ISI=numel(find(received_data_bits_ISI-data_bits)); % calculation of number of bit errors
        BER_ISI(n)=bit_errors_ISI/numel(data_bits);                   % calculation of bit error rate
    end

    semilogy(Eb_No_dB,BER_ISI,'linewidth',1);
    grid on;
    hold on;
end


% plotting BER for a AWGN channel in the same figure
BER_awgn= zeros(1,11);

for n=1:numel(Eb_No_dB)
    Eb_No = 10^(Eb_No_dB(n)/10);
    No = bit_energy/Eb_No ;
    sigma = sqrt(No/2);
    
    %signal after adding noise
    rs_awgn =PAM2_data + sigma*randn(1,numel(PAM2_data));
    received_data_bits_awgn = real(pskdemod(rs_awgn,2));
    bit_errors_awgn=numel(find(received_data_bits_awgn-data_bits)); % calculating number of bit errors
    BER_awgn(n)=bit_errors_awgn/numel(data_bits);                   % calculating bit error rate
end


semilogy(Eb_No_dB,BER_awgn,'linewidth',1);
legend("3-tap","5-tap","7-tap","9-tap","AWGN channel");
title("$E_{b}/N_{o} \ vs \ BER \ performance$",'interpreter','latex');
xlabel("$E_{b}/N_{o} \ dB $",'interpreter','latex');
ylabel("$\textbf{BER}$",'interpreter','latex');
publish('script.m','pdf')