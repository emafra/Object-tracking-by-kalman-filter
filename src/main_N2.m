clear;
clc;
close all;

vid = VideoReader('video2_n2.mp4');
tamanho_video = vid.NumberOfFrames;
z = zeros(2,vid.NumberOfFrames);
for i = 1 : tamanho_video
    im = read(vid, i);
    HSV = rgb2hsv(im);
    bw1 = HSV(:,:,1) <= 0.65 & HSV(:,:,1) >= 0.55 & HSV(:,:,2) <= 1 & HSV(:,:,2) >= 0.65 & HSV(:,:,3) <= 0.95 & HSV(:,:,3) >= 0.35;
    
    bw2 = HSV(:,:,1) <= 0.50 & HSV(:,:,1) >= 0.25 & HSV(:,:,2) <= 1 & HSV(:,:,2) >= 0.85 & HSV(:,:,3) <= 0.6 & HSV(:,:,3) >= 0.2;
    
    bw1 = idilate(bw1, ones(4),5);
    bw2 = idilate(bw2, ones(4),5);
    
    imagem  = bw1+bw2;
    
    %imshow(imagem)
    
    f1 = iblobs(bw1, 'area', [300 10000], 'class', 1);
    f2 = iblobs(bw2, 'area', [300 10000], 'class', 1);
    if size(f1,2) == 1
       z1(1,i) = f1(1).uc;
       z1(2,i) = f1(1).vc;
    else
       z1(1,i) = NaN;
       z1(2,i) = NaN; 
    end
     if size(f2,2) == 1
       z2(1,i) = f2(1).uc;
       z2(2,i) = f2(1).vc;
    else
       z2(1,i) = NaN;
       z2(2,i) = NaN; 
    end
      loading = (i/tamanho_video)*100
    cla
end
T = 0.2;
%% Filtro Kalman

% Pontos iniciais:
sigma_W2 = 5;
sigma_s2 = 150;

F = [1 T 0 0; 0 1 0 0; 0 0 1 T; 0 0 0 1];
h = [ 1 0 0 0; 0 0 1 0]';

j1 = 1;
while any(isnan(z2(:, j1)))
    j1 = j1 + 1;
end

j2 = 1;
while any(isnan(z2(:, j2)))
    j2 = j2 + 1;
end

z1 = z1(1:2,j1:length(z1));
z2 = z2(1:2,j2:length(z2));

x_e1 = zeros(4,(numel(z1)/2));
x_e1(:,1) = h*z1(:,1);

x_e2 = zeros(4,(numel(z2)/2));
x_e2(:,1) = h*z2(:,1);

P_p1 = eye(4); % Matriz de indentidade
P_e1 = zeros(4);

P_p2 = eye(4); % Matriz de indentidade
P_e2 = zeros(4);

S_e = [0.25*T^4 0.5*T^3 0 0; 0.5*T^3 T^2 0 0; ...
    0 0 0.25*T^4 0.5*T^3; 0 0 0.5*T^3 T^2]*sigma_s2;

W_e = [1 0; 0 1]*sigma_W2;

[m,n] = size(z1);

tempo = [0:n-1]*T;
test=[];

for k = 2: n
      
    x_p1 = F * x_e1(:,k-1);
    x_p2 = F * x_e2(:,k-1);  
    
    distMatrix = calculadist(z1(:,k),z2(:,k),x_p1,x_p2);    
        
    ordem = assignmentoptimal(distMatrix)
            
    n1 = ordem(1,1);
    n2 = ordem(2,1);
    
    if n1 == 1
        [x_e1(:,k),P_e1] = f_kalman(F,h,z1(:,k),x_p1,P_e1,S_e,W_e);
    elseif n1==2
        [x_e1(:,k),P_e1] = f_kalman(F,h,z2(:,k),x_p1,P_e1,S_e,W_e);
    elseif n1==0
         x_e1(:,k) = x_p1;
    end

    if n2 == 1
        [x_e2(:,k),P_e2] = f_kalman(F,h,z1(:,k),x_p2,P_e2,S_e,W_e);
    elseif n2 == 2
        [x_e2(:,k),P_e2] = f_kalman(F,h,z2(:,k),x_p2,P_e2,S_e,W_e);
    elseif n2 == 0
        x_e2(:,k) = x_p2;
    end  
        
end
    
%     figure;
%     plot(tempo(1:20),z1(1,1:20)); hold on;
%     plot(tempo(1:20),z1(2,1:20));
%     plot(tempo(1:20),x_e1(1,1:20));
%     plot(tempo(1:20),x_e1(3,1:20));
%     
%     close all;

for i = 5: tamanho_video
    im = read(vid, i);
    pause(0.1)
    imshow(im);
    hold on;
    %plot(z2(1,i-4:i),z2(2,i-4:i), 'Linewidth', 8, 'Color', 'yellow')
    plot(x_e2(1,i-4:i),x_e2(3,i-4:i), 'Linewidth', 5, 'Color', 'blue')
    %plot(z1(1,i-4:i),z1(2,i-4:i), 'Linewidth', 8, 'Color', 'green')
    plot(x_e1(1,i-4:i),x_e1(3,i-4:i), 'Linewidth', 5, 'Color', 'red')
end    


