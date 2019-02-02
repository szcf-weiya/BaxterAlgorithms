function oInside = InsideAxes(aAxes, aX, aY)
% Checks if a certain point is inside an axes object.
%
% The point is given in the coordinate system of the axes. The function is
% used to determine if the user clicked inside or outside an axes object.
% The coordinate inputs to the function can be generated by getting the
% 'CurrentPoint' property of the axes object.
%
% Inputs:
% aAxes - Axes object that the user may have clicked in.
% aX - x-coordinate in the coordinate system of the axes.
% aY - y-coordinate in the coordinate system of the axes.
%
% Outputs:
% oInside - True if the user clicked in the axes.

oInside = false;

xLimits = get(aAxes, 'xlim');
if aX < xLimits(1) || aX > xLimits(2)
    return
end

yLimits = get(aAxes, 'ylim');
if aY < yLimits(1) || aY > yLimits(2)
    return
end

oInside = true;
end