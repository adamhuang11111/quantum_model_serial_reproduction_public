function U = unitary2(th,phi)
%Program for creating rotation in 2D
 U = [cos(th*pi)       -sin(th*pi)*exp(-1i*phi*pi) ;
       sin(th*pi)*exp(1i*phi*pi)         cos(th*pi)];
end

