function PR = power_calculation(AP,plain2,...
    x_image,y_image,x_meters,y_meters,c_ligth,...
    PT,GT,GR,F,dbp,P_Walls,j,i,K,T,B)
    
    m = calculate_wall_count(plain2, AP, [i j]);

    D = norm([AP(1,1)*x_meters/x_image AP(1,2)*y_meters/y_image] ...
        - [i*x_meters/x_image j*y_meters/y_image]);

    % The power at each point is calculated, applying the WiFi model:
    if D <= dbp
        PR = PT + GT + GR + 20*log10(c_ligth/(4*pi)) - 20*log10(F) - 20*log10(D) - P_Walls*m;
    end
    if D > dbp
        PR = PT + GT + GR + 20*log10(c_ligth/(4*pi)) - 20*log10(F) - 20*log10(D) - P_Walls*m - 35*log10(D/dbp);
    end

    if PR == inf 
        PR = PT;
    end

    if PR <= 10*log10((K*T*B)/1e-3)
        PR = 10*log10((K*T*B)/1e-3);
    end

end
