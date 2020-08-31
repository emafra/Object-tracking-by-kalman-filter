clear;
clc;
close all;

%% Detecção e armazenamento das trajetória:
vid = VideoReader('1bolinha.mp4');
tamanho_video = vid.NumberOfFrames;
z = zeros(2,vid.NumberOfFrames);
for i = 1 : tamanho_video
    im = read(vid, i);

    HSV = rgb2hsv(im);  
    
    bw = HSV(:,:,1) <= 0.50 & HSV(:,:,1) >= 0.25 & HSV(:,:,2) <= 9 & ...
    HSV(:,:,2) >= 0.45 & HSV(:,:,3) <= 0.6 & HSV(:,:,3) >= 0.2;    
    
    bw = idilate(bw, ones(4),5);      
    f1 = iblobs(bw, 'area', [300 10000], 'class', 1);

    if size(f1,2) == 1
       z1(1,i) = f1(1).uc;
       z1(2,i) = f1(1).vc;
    else
       z1(1,i) = NaN;
       z1(2,i) = NaN; 
    end
      loading = (i/tamanho_video)*100
end

%% Filtro Kalman

T = 0.8;

sigma_W2 = 5;
sigma_s2 = 150;

F = [ 1 T 0 0; 0 1 0 0; 0 0 1 T; 0 0 0 1];
h = [ 1 0 0 0; 0 0 1 0]';

S_e = [0.25*T^4 0.5*T^3 0 0; 0.5*T^3 T^2 0 0; ...
    0 0 0.25*T^4 0.5*T^3; 0 0 0.5*T^3 T^2]*sigma_s2;

W_e = [1 0; 0 1]*sigma_W2;

j1 = 1;
while any(isnan(z1(:, j1)))
    j1 = j1 + 1;
end

z1 = z1(1:2,j1:length(z1));

x_e1 = zeros(4,(numel(z1)/2));
x_e1(:,1) = h*z1(:,1);

P_p1 = eye(4); % Matriz de indentidade
P_e1 = zeros(4);

[m,n] = size(z1);

tempo = [0:n-1]*T;

for k = 2:(n)    
    
    x_p1 = F * x_e1(:,k-1);
          
    [x_e1(:,k),P_e1] = f_kalman(F,h,z1(:,k),x_p1,P_e1,S_e,W_e);        
  
end
    
%     figure;
%     plot(tempo(1:20),z1(1,1:20)); hold on;
%     plot(tempo(1:20),z1(2,1:20));
%     plot(tempo(1:20),x_e1(1,1:20));
%     plot(tempo(1:20),x_e1(3,1:20));
%     
%     close all;

for i = 5 : n
    im = read(vid, i);
    pause(0.05)
    imshow(im);
    hold on;
    plot(z1(1,i-4:i),z1(2,i-4:i), 'Linewidth', 8, 'Color', 'yellow')
    plot(x_e1(1,i-4:i),x_e1(3,i-4:i), 'Linewidth', 5, 'Color', 'blue')
end    

