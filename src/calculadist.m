function distMatrix = calculadist(z1,z2,x_p1,x_p2)

    distu11 = norm(z1(1,1) - x_p1(1,1));
    distv11 = norm(z1(2,1) - x_p1(3,1));
    
    dist11 = norm(distu11 - distv11);
    
    distu12 = norm(z2(1,1) - x_p1(1,1));
    distv12 = norm(z2(2,1) - x_p1(3,1));
    
    dist12 = norm(distu12 - distv12);
    
    distu21 = norm(z1(1,1) - x_p2(1,1));
    distv21 = norm(z1(2,1) - x_p2(3,1));
    
    dist21 = norm(distu21 - distv21);
    
    distu22 = norm(z2(1,1) - x_p2(1,1));
    distv22 = norm(z2(2,1) - x_p2(3,1));
    
    dist22 = norm(distu22 - distv22);    
 
   distMatrix = [dist11,dist12;dist21,dist22];
end