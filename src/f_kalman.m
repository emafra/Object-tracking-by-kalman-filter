function [x_e,P_e] = f_kalman(F,h,z,x_p,P_e,S_e,W_e)

        P_p = F * P_e * F' + S_e;

        % Estimação
        e = z - h'*x_p;
        K = P_p * h * inv((h' * P_p *h + W_e));

        if  isnan(z)
            x_e = x_p;
        else
            x_e = x_p + K*e;
        end
        
        P_e = P_p - K* h' * P_p;
            
        
end