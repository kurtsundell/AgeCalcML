function [cx,cy,r]=find_inner_circle(x,y)

% make a voronoi diagram
[vx,vy]=voronoi(x,y);

% find voronoi nodes inside the polygon [x,y]
Vx=vx(:);
Vy=vy(:);
% Here, you could also use a faster version of inpolygon
IN=inpolygon(Vx,Vy, x,y);
ind=find(IN==1);
Vx=Vx(ind);
Vy=Vy(ind);

% maximize the distance of each voronoi node to the closest node on the
% polygon.
minDist=0;
minDistInd=-1;
for i=1:length(Vx)
    dx=(Vx(i)-x);
    dy=(Vy(i)-y);
    r=min(dx.*dx+dy.*dy);
    if (r>minDist)
        minDist=r;
        minDistInd=i;
    end
end

% take the center and radius
cx=Vx(minDistInd);
cy=Vy(minDistInd);
r=sqrt(minDist);

end