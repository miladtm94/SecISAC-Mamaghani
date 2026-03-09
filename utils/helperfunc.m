function f1_val = helperfunc(x,y,x_lo,y_lo)
    % taylor(f=x^2/y, [x,y], [x0,y0], 'Order', 2)
    f1_val = (x_lo./y_lo.^2).*(2.*y_lo.*x - x_lo.*y);
end