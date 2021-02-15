function [h4]=generateDome_shruthi(Rs,xsm,ysm,zsm, r,xOm,yOm,zOm, xP1o,yP1o,zP1o, x0,y0,x1,y1,x2,y2,h4)

disp('Using generateDome_shruthi modified by AJC on shruthiBranch');

% THREE ISSUES:
% 1. Why does calibration have sudden nonlinear changes in output?
% -> Needs to explicitly set xlim ylim... once I do this I don't see
% nonlinear changes in output? Can anyone else provide examples?
% 2. Why is FlyVR reading output file and putting it in wrong position?
% 3. Output file conserves DEGREES but we want to conserve LENGTH

% For comments, Ctrl+F "AJC"





%%DomeProjection.m
% Stephan Thiberge 
% Princeton University - 02/08/2018
% This is the matlab version of the code used for Virmen. We  rewrote
% this code in C++ and compiled it to have a Mex file of the function 
% DomeProjection running much faster than the Matlab version.


% General idea:
% Creating correctly warped images given a particular projector, mirror, 
%and dome arrangement requires finding the point on the projector frustum 
%for any point on the dome. The problem is three-dimensional but can be 
%turned into a simpler two dimensional problem by firstly translating the 
%geometry so the spherical mirror is at the origin and then rotating the 
%geometry so that the point on the mirror, dome, and projector lies in a 
%single plane
% The projector is located at P1, the mirror is of radius r, and the 
%position on the dome is P2. The path length from the projector to the 
%mirror is L1, the path length from the dome to the mirror is L2.
% Fermat�s principle states that light travels by the shortest route, so 
%the reflection point on the mirror can be found by minimising the total 
%light path length from the projector to the position on the dome, namely 
%minimising (L1^2 + L2^2)^1/2
% It is quite simple in the case of a spherical mirror: the line at 
% mid-angle between the vectors OP1 and OP2 and its interection with the
% surface of the mirror defines the reflection point.

% profile on

%%creating a (almost) full screen figure
% scrsz = get(groot,'ScreenSize');
% h4=figure('OuterPosition',scrsz);
% h4=figure('OuterPosition',[10 10 608 684]);

if ~exist('h4','var')
    % AJC: SHOULD THIS BE [1 684 1 608] ?
    h4=figure('OuterPosition',[10 10 684 608]);
else
    clf(h4);
    figure(h4);
end

% Get rid of tool bar and pulldown menus that are along top of figure.
set(gcf, 'Toolbar', 'none', 'Menu', 'none');
set(h4,'color','black')
ax = gca;
ax.Position=[0 0 1 1];
plot(0,0,'o'); hold on;
axis off;

XProjectorMax = 684;
XProjectorMin = 1;
YProjectorMax = 608;
YProjectorMin = 1;


XProjectorMax = 1;
XProjectorMin = -1;
YProjectorMax = 0;
YProjectorMin = -1;

% AJC: EXPLICITLY SET XLIM AND YLIM
xlim([XProjectorMin XProjectorMax])
ylim([YProjectorMin YProjectorMax])

% Point M is the mouse 
% Point O is the center of the spherical mirror ((xom,yom,zom) in ref to M)
% Point S is the center of the spherical screen ((xsm,ysm,zsm) in ref to M)
% Point P1 is the projector focal point 
% ----> M, O, S and P1 are all the same vertical plane (Mxz).
% point P2 is a projected point on the sphere

% Oprime is the distance from the edge of the mirror to the 'center' of
% the mirror (ROC = 30.9 mm, diameter=50.8 mm)
% Oprime 

%Spherical Screen radius and coordinates relative to the animal head
% Rs=77; %mm
% xsm=0;  ysm=0;  zsm=0;

%Spherical Mirror position and radius relative to the animal, and relative
%to the spherical screen center.
% OM=7.5; %distance OM is between 7.25" and 7.75" 
% OMx=58; % Angle between line OM and axis Ox is 58 +/- 1 degrees respectively
% xOm=OM*cosd(OMx); yOm=0;  zOm=-OM*sind(OMx);

% xOm=20; yOm=0; zOm=75;
% xOs=xOm-xsm; yOs=yOm-ysm;  zOs=zOm-zsm;

% r=30.9; %radius of the spherical mirror (Silver coated lens LA1740-Thorlabs)
% 
% %projector position relative to the mirror center O
% xP1o=158; yP1o=-2; zP1o=25.4;   %11.3


% %Spherical Screen radius and coordinates relative to the animal head
% Rs=8; %inches
% xsm=17.5/25.4;  ysm=0;  zsm=16.5/25.4;
% 
% %Spherical Mirror position and radius relative to the animal, and relative
% %to the spherical screen center.
% OM=7.5; %distance OM is between 7.25" and 7.75" 
% OMx=58; % Angle between line OM and axis Ox is 58 +/- 1 degrees respectively
% xOm=OM*cosd(OMx); yOm=0;  zOm=-OM*sind(OMx);  
xOs=xOm-xsm; yOs=yOm-ysm;  zOs=zOm-zsm;
% 
% r=-43.8/25.4; %radius of the spherical mirror (Silver coated lens LA1740-Thorlabs)
% 
% %projector position relative to the mirror center O
% xP1o=11.30; yP1o=0; zP1o=1.25;   %11.3




%initialization of vertex locations (points in the real world the animal is
%looking at): 
%Virmen will be using cartesian coordinates witht he animal being at
%(0,0,0)
xm=[]; ym=[];
numel1 = 15;
numel2 = 34;

gridSize = [34,34];
elevatMag = [0,-90];
azimuthMag = [-150,150];

els = (pi/180)*linspace(elevatMag(1),elevatMag(2),gridSize(1));
azs = (pi/180)*linspace(azimuthMag(1),azimuthMag(2),gridSize(2));

displayEls = [0,-45,-90,-90, 0,-45,   0,-45, 0,-45, 0,-45,] * pi/180;
displayAzs = [0,  0,  0,-90, -45,-45, 45,45, 90,90, -90,-90] * pi/180;

[projGridE,projGridA] = meshgrid(els,azs);
xVals = size(projGridE);
yVals = size(projGridE);



%%%
%we will select lines of equi-azimuth (horizontal lines) and
%equi-elevation(vertical lines)
radius=1; %this value does not matter, as a rescaling will follow.
%h4=figure;

% % %timing = nan(1,34);
% % %profile on


% loop through some sets of azimuth and elevations
for jj=1:size(projGridE,2)
    % this is currently making 8 elevations and some larger number of
    % azimuths: rejigger this to make it more extensible
%     if jj<8
% 	    elevat=(pi/180)*((-30+10*(jj-1)));
%     else
%         azim=(pi/180)*((-120+10*(jj-8)));
%     end

%%%    tic 
    
    for i=1:size(projGridE,1)
%         if jj<8
%             azim=(pi/180)*(240*(.5-(i-1)/200));
%         else
%             elevat=(pi/180)*(70*(.5-(i-1)/200));
%         end
        elevat = projGridE(i,jj);
        azim   = projGridA(i,jj);

        azimAll(i,jj) = azim;
        elevAll(i,jj) = elevat;
        
        % for the elevation and azimuth, find the x, y, and z positions on
        % some sphere
        % x,y use cosine elevation because cos(0) is maximal x,y distance
        % from the center of the sphere and sin(0) means there is no z
        % component
        % then x,y are simple cos/sin of the azimuth (again x is in the
        % direction toward the project, y is orthogonal/left of it, etc
        % [xVm,yVm,zVm]=sph2cart(azim,elevat,radius);
        [HorizPx,VerticPx] = getHorizVertFromAngles(elevat,azim,radius,Rs,r, xsm,ysm,zsm, ...
                                                        xOs,yOs,zOs,xP1o,yP1o,zP1o);
        
        
        % VerticPx=VerticPx -sinpsi; %translation of the screen coordinate center
        
        %store(end+1,1:4)=[sinalpha, theta, sinphi, zP2opsi];
        
%         xm(i)=HorizPx;
%         ym(i)=VerticPx;
        
        xVals(i,jj) = HorizPx;
        yVals(i,jj) = VerticPx;
        
        %if we make sure three predetermined orietntations are always displayed on
        %the same three pixels, we may accelerate the process of determining the
        %proper parameters.
        if (azim==0 && elevat==0)
            xm0=HorizPx; ym0=VerticPx;
        elseif (azim==0 && elevat==pi*20/180)
            xm1=HorizPx; ym1=VerticPx;
        elseif (azim==pi/2 && elevat==0)
            xm2=HorizPx; ym2=VerticPx;
        end
        
        plot(HorizPx,VerticPx,'r.')

    end
    
    
    %%% timing(jj) = toc;
    
%     figure(h4),
%     plot(xm(:),ym(:),'.'); hold on;
%     if elevat==0
%         plot(xm(:),ym(:),'b-'); hold on;
%     end
%     if azim==0
%         plot(xm(:),ym(:),'-'); hold on;
%     end
    
end

for jj=1:length(displayEls)
    elevat = displayEls(jj);
    azim = displayAzs(jj);
    
    [HorizPx,VerticPx] = getHorizVertFromAngles(elevat,azim,radius,Rs,r, xsm,ysm,zsm, ...
        xOs,yOs,zOs,xP1o,yP1o,zP1o);
    
%     [elevat,azim]
    if elevat == -90 * pi/180
%         plot(HorizPx,VerticPx,'ro','LineWidth',5)
        plot(HorizPx,VerticPx,'go','LineWidth',5)   
    elseif elevat == -45* pi/180
        plot(HorizPx,VerticPx,'yx','LineWidth',5)
    else
        plot(HorizPx,VerticPx,'b+','LineWidth',2)
        
        % Added by Shruthi
%         disp(elevat * 180/pi);
    end
end
% % % profile off
% % % profile viewer
% figure; histogram(timing)

% write out screen coordinates (x,y) [normalized -1,1],
% texture coordinate (u,v) between 0,1
% intensity value 0,1
% want to draw such that -1 = -180 degrees and 1 = 180 degrees
Yscale=ylim;
Xscale=xlim;
% [min(min(xVals(:))),max(max(xVals(:))),min(min(yVals(:))),max(max(yVals(:)))]

% AJC: changed the writing out to a function
writeCalibration(xVals,yVals,azimAll,elevAll,Xscale,Yscale);

size(xVals);
% [min(azimAll(:)),max(azimAll(:))]
% [min(elevAll(:)),max(elevAll(:))]

% take grid that we've established and homogenize the density:
% how do we do this? take difference of two closest points, assume light
% sums linearly, and normalize to lowest amount?
% xvals


% we are going to modify the limits and position of the axes so that
% M1,M2,M3 false on the same 3 sets of pixel coordinates.
% Innerposition=get(h4,'Position');

% AJC: COMMENTED THESE OUT BECAUSE I AM TESTING ON A MAC

FigPos = get(h4, 'Position');
WindowAPI(h4, 'Position', FigPos, 2);
WindowAPI(h4, 'ToMonitor');  % If 2nd monitor has different size
WindowAPI(h4, 'Position', 'full');




%the point [azim,altitude]=[0,0] needs to be at the pixel [x0,y0]. It is
%currently at pixel [xm0,ym0]
%we determined that
% x0=660; y0=417;
% x1=662; y1=449;
% x2=938; y2=404;



% x0=0; y0=0;
% x1=10; y1=0;
% x2=0; y2=0;


% 2D interpolation from XMin,YMin to XMax,YMax

% NewXscaleExtent=(Innerposition(3)-Innerposition(1))*(xm2-xm0)/(x2-x0);
% NewYscaleExtent=(Innerposition(4)-Innerposition(2))*(ym1-ym0)/(y1-y0);
% 
% NewXscalMin=(-x0+xm0*(x2-x0)/(xm2-xm0))/((x2-x0)/(xm2-xm0));
% NewYscalMin=(-y0+ym0*(y1-y0)/(ym1-ym0))/((y1-y0)/(ym1-ym0));

% xlim([NewXscalMin  NewXscalMin+NewXscaleExtent]);
% ylim([NewYscalMin  NewYscalMin+NewYscaleExtent]);

% xlim([NewXscalMin+NewXscaleExtent NewXscalMin]);
% ylim([NewYscalMin+NewYscaleExtent NewYscalMin]);

% profile viewer

end








function [HorizPx,VerticPx] = getHorizVertFromAngles(elevat,azim,radius,Rs,r, xsm,ysm,zsm, ...
                                                        xOs,yOs,zOs,xP1o,yP1o,zP1o)
    xVm = radius .* cos(elevat) .* cos(azim);
    yVm = radius .* cos(elevat) .* sin(azim);
    zVm = radius .* sin(elevat);



    % 1-
    % For a vertex V of coordinates (x,y,z) in the coordinates system in which
    % the animal is at the origin, what are the coordinates of the projected point
    % P2 on the sphere (intersection point P2 between the sphere and the line
    % MV)

    % In the coord where M is the origin, the line MV expressed in a parametic form is
    % x=xVm*t; y=yVm*t; z=zVm*t;
    % and the sphere equation is
    % (x-xsm)^2+(y-ysm)^2+(z-zsm)^2=Rs^2;
    % Substitution leads to:
    % at^2+bt+c=0
    % where
    a=xVm^2+yVm^2+zVm^2;
    b=-2*(xVm*xsm+yVm*ysm+zVm*zsm);
    c=xsm^2+ysm^2+zsm^2-Rs^2;
    % The two solutions for t are:

    t1=(-b+sqrt(b^2-4*a*c))/(2*a) ;
    t2=(-b-sqrt(b^2-4*a*c))/(2*a) ;
    %going from M to V, the parameter t should increase in value from 0 to tsol,
    % the solution is therefore the positive one.
    if t1>=0 t=t1; elseif t2>0  t=t2; end
    % reinjecting in the original parametric equation, the Line MV intercepts
    % the spherical projection screen at P2:
    xP2m=xVm*t; yP2m=yVm*t; zP2m=zVm*t;
    %[xP2m yP2m zP2m]

    %The point P2 in the coord system where the spherical screen center is
    % the origin
    xP2s=xP2m-xsm;
    yP2s=yP2m-ysm;
    zP2s=zP2m-zsm;

    % [xVm,yVm,zVm]
    % [xP2m,yP2m,zP2m]
    % [xP2s yP2s zP2s]
    % sqrt(xVm^2+yVm^2+zVm^2)
    % sqrt(xP2s^2+yP2s^2+zP2s^2)

    % 2-
    % The coordinates of P2 in the ref system where the origin is the
    % center of the spherical mirror O are:
    xP2o=xP2s-xOs;  yP2o=yP2s-yOs;  zP2o=zP2s-zOs;
    %[xP2o yP2o zP2o]

    % 2bis-
    % If P1 is not exactly on the horizontal line crossing the center O, what
    % is the angle psi between the line Ox and the line OP1?
    aab=(xP1o^2+zP1o^2)^(1/2);
    sinpsi= zP1o/aab;
    cospsi= xP1o/aab;

    % 2ter-
    % What are the coordinates of P2 in the psi-rotated coordinates system
    % centered on O?
    % Rot_Oy=[cospsi 0 sinpsi; 0 1 0; -sinpsi 0 cospsi];
    % P2xyz=Rot_Oy*[xP2o; yP2o; zP2o];
    %
    % xP2opsi=P2xyz(1);  yP2opsi=P2xyz(2);  zP2opsi=P2xyz(3);

    xP2opsi=cospsi*xP2o+sinpsi*zP2o;
    yP2opsi=yP2o;
    zP2opsi=-sinpsi*xP2o+cospsi*zP2o;
    %[xP2opsi yP2opsi zP2opsi]

    % 2quart-
    % what is the angle alpha between the plan OP1P2 and the plan Ox'z'?
    % this is equivalent to asking the angle between the vectors OP2 and Oz'
    aac=sqrt(zP2opsi^2+yP2opsi^2);
    sinalpha=yP2opsi/aac;
    cosalpha=zP2opsi/aac;
    %
    %  alpha = atan2d(norm(cross([0, yP2opsi, zP2opsi],[0, 0, 1])), dot([0, yP2opsi, zP2opsi],[0, 0, 1]));
    %  sinalpha=sind(alpha);
    %  cosalpha=cosd(alpha);


    % 3-
    % What are the coordinates of P2 in the alpha-rotated coordinates system
    % centered on O?
    % Rot_OP1axis=[1 0 0; 0 cosalpha -sinalpha; 0 sinalpha cosalpha];
    % P2xyz=Rot_OP1axis*[xP2opsi yP2opsi zP2opsi]';
    % P2x=P2xyz(1) ; P2y=P2xyz(2); P2z=P2xyz(3);

    P2x=xP2opsi;
    P2y=cosalpha*yP2opsi-sinalpha*zP2opsi;
    P2z=sinalpha*yP2opsi+ cosalpha*zP2opsi;
    % [P2x, P2y, P2z]


    % % Because P1 is not on the horizontal line crossing the center O (but
    % % slightly below), P1 coordinates are changing when we rotate the
    % % referential by psi and alpha:
    % P1opsi=Rot_Oy*[xP1o yP1o zP1o]';
    % P1xyz=Rot_OP1axis*[P1opsi(1) P1opsi(2) P1opsi(3)]';
    % P1x=P1xyz(1); P1y=P1xyz(2); P1z=P1xyz(3);

    xP1opsi=cospsi*xP1o+sinpsi*zP1o;
    yP1opsi=yP1o;
    zP1opsi=-sinpsi*xP1o+cospsi*zP1o;

    P1x=xP1opsi;
    P1y=cosalpha*yP1opsi-sinalpha*zP1opsi;
    P1z=sinalpha*yP1opsi+ cosalpha*zP1opsi;



    % [P1x, P1y, P1z]
    %the step above can be skipped and just re-written P1x=sqrt(xP1o^2+zP1o^2)

    % 4-
    % What is the associated theta (elevation in rotated ref) that minimizes
    % the optical path length?
    % It's equal to half the angle between the vectors OP1 and OP2.
    %theta =(1/2)* atan2d(norm(cross([P1x, P1y, P1z],[P2x, P2y, P2z])), dot([P1x, P1y, P1z],[P2x, P2y, P2z]));
    % xprod = [ P1y*P2z - P1z*P2y     ...
    %         , P1z*P2x - P1x*P2z     ...
    %         , P1x*P2y - P1y*P2x     ...
    %         ];
    % theta =(1/2)* atan2d(sqrt((P1y*P2z - P1z*P2y)^2+(P1z*P2x - P1x*P2z)^2+(P1x*P2y - P1y*P2x)^2), P1x*P2x + P1y*P2y + P1z*P2z);
    %  sintheta=sind(theta);
    %  costheta=cosd(theta);


    P1norm=sqrt(P1x^2+P1y^2+P1z^2);
    P2norm=sqrt(P2x^2+P2y^2+P2z^2);
    P3x=P1x/P1norm+P2x/P2norm;
    P3y=P1y/P1norm+P2y/P2norm;
    P3z=P1z/P1norm+P2z/P2norm;
    P3norm=sqrt(P3x^2+P3y^2+P3z^2);
    YY=sqrt((P1y*P3z - P1z*P3y)^2+(P1z*P3x - P1x*P3z)^2+(P1x*P3y - P1y*P3x)^2);
    XX=(P1x*P3x + P1y*P3y + P1z*P3z);
    sintheta=YY/(P1norm*P3norm);
    costheta=XX/(P1norm*P3norm);

    if sintheta<0
        disp('negat')
    end


    % 4bis-
    % what is the associated angle of the ray leaving the projector?
    %phi=atand((r*sintheta)/(P1x-r*costheta));
    sinphi=r*sintheta/((r*sintheta)^2+(P1x-r*costheta)^2)^(1/2);
    % 5-
    % Finally what are the {xm,ym} coordinates of the point on the monitor
    % screen associated with the ray leaving the projector with the angles
    % alpha and phi ?
    % phi defines a circle in the projector image plane, and alpha a line.
    % The intersection of the line and the circle defines two points, one that
    % is imaged on the spherical screen, one that is located outside the region
    % being projected. (For now, we place the pixel(0,0) at the center of the
    % projector)

    % VerticPx=sqrt((sind(phi)^2)/(1+tand(alpha)^2));
    % HorizPx=VerticPx*tand(alpha);
    
    
%     VerticPx=sinphi*cosalpha;
%     HorizPx=sinphi*sinalpha;
%     
%     
% % %     Stephan's parameter
%     VerticPx= 6.0*sinphi*cosalpha - 0.5104;   
%     HorizPx= 6.0*sinphi*sinalpha - 0.0275;
%     
% %     Megan and Shruthi's expts

% AJC: WE SHOULD GIVE THIS PARAMETER A NAME AND MAKE IT SETABLE SOMEHOW
    VerticPx= 6.7*sinphi*cosalpha + 0.11;
    HorizPx= 7.2*sinphi*sinalpha;
%     
%     
%     VerticPx= 6.0*sinphi*cosalpha+2;   
%     HorizPx= 6.0*sinphi*sinalpha;
%     
%     
%     VerticPx= 6.0*sinphi*cosalpha;   
%     HorizPx= 6.0*sinphi*sinalpha+2;
    
%     VerticPx= 0.5*sinphi*cosalpha;   
%     HorizPx= 0.5*sinphi*sinalpha;
    
end

% Old function
% function writeCalibration(xVals,yVals,azimAll,elevAll,Xscale,Yscale)
%     f = fopen('calibratedBallImage.data','w');
%     fprintf(f,'2\n');
%     fprintf(f,'%d %d\n',size(xVals,1), size(xVals,2));
% 
%     for jj=1:size(xVals,2)
%         for i=1:size(xVals,1)
%             fprintf(f,'%1.6f %1.6f %1.6f %1.6f %1.6f\n', ...
%                 ((xVals(i,jj) - Xscale(1))./(Xscale(2) - Xscale(1)) *2)-1, ((yVals(i,jj) - Yscale(1))./(Yscale(2) - Yscale(1)) *2)-1,...
%                 (pi+azimAll(i,jj))/(2*pi),(pi+elevAll(i,jj))/(2*pi), ...
%                 1);
%         end
%     end
%     
%     fclose(f);
% end


% Function modified by AJC 2/15/2021

function writeCalibration(xVals,yVals,azimAll,elevAll,Xscale,Yscale)
    % file format: http://paulbourke.net/dome/warpingfisheye/
    f = fopen('calibratedBallImage.data','w');
    fprintf(f,'2\n');
    fprintf(f,'%d %d\n',size(xVals,1), size(xVals,2));

    
    max_theta = (max(azimAll(:))-min(azimAll(:)))/2;
    
    for jj=1:size(xVals,2)
        for i=1:size(xVals,1)
            % the format is xcoords on monitor, ycoords on monitor, azimuth
            % on screen, elevation on screen, light intensity
            
            % but we don't want to map pixels -> (normalized) radians.
            % Instead we want pixels -> (length units)
            % Remember that arc length is r * theta [radians]
            % and that the radius of a small circle r is R*cos(phi), where
            % R is the radius of the sphere and phi is the elevation
            
            % so now we want to convert the units of radians to units of
            % length, scaled by the maximum width: 
            % length = R * azimuth_theta * cos(elevation_theta) /
            % (R*max_theta)
            % => length = azimuth_theta * cos(el_theta) / max_theta;
            len = azimAll(i,jj) * cos(elevAll(i,jj)) / max_theta;

            % AJC try 1:
            fprintf(f,'%1.6f %1.6f %1.6f %1.6f %1.6f\n', ...
                ((xVals(i,jj) - Xscale(1))./(Xscale(2) - Xscale(1)) *2)-1, ((yVals(i,jj) - Yscale(1))./(Yscale(2) - Yscale(1)) *2)-1,...
                (len+1)/2,(pi+elevAll(i,jj))/(2*pi), ...
                1);

            % AJC try 2:
%             fprintf(f,'%1.6f %1.6f %1.6f %1.6f %1.6f\n', ...
%                 684/608*((xVals(i,jj) - Xscale(1))./(Xscale(2) - Xscale(1)) *2)-1, ((yVals(i,jj) - Yscale(1))./(Yscale(2) - Yscale(1)) *2)-1,...
%                 (len+1)/2,(pi+elevAll(i,jj))/(2*pi), ...
%                 1);

            
%             fprintf(f,'%1.6f %1.6f %1.6f %1.6f %1.6f\n', ...
%                 ((xVals(i,jj) - Xscale(1))./(Xscale(2) - Xscale(1)) *2)-1, ((yVals(i,jj) - Yscale(1))./(Yscale(2) - Yscale(1)) *2)-1,...
%                 (pi+azimAll(i,jj))/(2*pi),(pi+elevAll(i,jj))/(2*pi), ...
%                 1);
            
            % QUESTION: should xvals be rescaled to min/max ASPECT ratio
            % (which is ~684/608, for us), rather than -1/1?
            
            % one other note here: the screen that we are going to 'draw'
            % onto will be in units from -max(azimuth):max(azimuth).
            % Similarly for elevation. So 90 degrees won't necessarily be
            % at .75 along the canvas.
        end
    end
    
    fclose(f);
end