%load('usborder.mat','x','y','xx','yy');
%rng(3,'twister')

nStops = 22; % You can use any number, but the problem size scales as N^2
lonList = [32.3895645 33.4677415 28.104897 33.1225678 33.0588435 30.6307191 30.9518734 33.7440023 30.2853231 31.7140272 34.2001086 34.4798123 33.5829154 32.9053466 30.721413 32.3618738 26.8495948 33.1796344 32.4827796 31.2698358 34.4348071 30.785589];
% Allocate x-coordinates of nStops
latList = [-86.3050869 -88.7891262 -81.631729 -89.0535044 -89.5903167 -84.4146814 -85.5125157 -90.7248187 -81.405824 -86.2643253 -90.5709323 -87.7340372 -86.632742 -86.7085767 -86.5662155 -86.299616 -80.0583981 -87.5531051 -85.5596159 -86.2433576 -86.9329862 -86.121099];
capList = [15 23 30 15 30 16 18 29 25 15 26 30 19 22 27 16 17 19 12 11 19];

stopsLon = zeros(nStops,1); % Allocate x-coordinates of nStops
stopsLat = stopsLon; % Allocate y-coordinates
n = 1;

while (n <= nStops)
    xp = latList(n);
    yp = lonList(n);
    
    stopsLon(n) = xp;
    stopsLat(n) = yp;
    n = n+1;
    
end

idxs = nchoosek(1:nStops,2);
dist1 = [184 477 202 236 188 125 314 392 53 336 198 97 47 142 2 605 101 48 88 158 124 661 32 58 371 308 132 575 233 145 109 152 145 324 185 788 83 231 258 158 290 678 734 296 368 833 180 457 854 717 600 536 425 488 152 588 444 427 677 404 36 380 312 129 581 225 142 144 169 163 297 203 804 103 249 252 193 284 445 338 99 636 251 112 178 212 206 309 234 860 143 281 277 226 309 81 500 198 152 523 385 284 234 138 187 422 287 177 140 345 116 438 271 80 460 322 221 172 76 124 494 224 140 57 282 46 733 363 37 224 281 275 405 315 956 213 361 389 272 440 359 756 619 502 438 327 390 275 490 347 329 579 306 386 248 147 98 84 50 583 149 99 35 208 71 186 261 294 421 337 981 225 382 421 234 457 123 156 337 199 844 101 245 284 50 319 55 236 98 727 69 144 182 83 218 187 48 651 61 94 133 115 169 141 552 237 187 50 297 36 610 101 47 85 159 121 714 570 553 802 530 147 184 122 220 113 204 143 241 38 279];

dist = dist1';
%dist = hypot(stopsLat(idxs(:,1)) - stopsLat(idxs(:,2)), ...
             %stopsLon(idxs(:,1)) - stopsLon(idxs(:,2)));
%dist = dist2;
%imagesc(dist)
lendist = length(dist);
G = graph(idxs(:,1),idxs(:,2));
figure
hGraph = plot(G,'XData',stopsLon,'YData',stopsLat,'LineStyle','none','NodeLabel',{});
hold on
% Draw the outside border
%plot(x,y,'r-')
%hold off

Aeq = spalloc(nStops,length(idxs),nStops*(nStops-1)); % Allocate a sparse matrix
for ii = 1:nStops
    whichIdxs = (idxs == ii); % Find the trips that include stop ii
    whichIdxs = sparse(sum(whichIdxs,2)); % Include trips where ii is at either end
    Aeq(ii,:) = whichIdxs'; % Include in the constraint matrix
end
beq = 2*ones(nStops,1);

intcon = 1:lendist;
lb = zeros(lendist,1);
ub = ones(lendist,1);

opts = optimoptions('intlinprog','Display','off');
[x_tsp,costopt,exitflag,output] = intlinprog(dist,intcon,[],[],Aeq,beq,lb,ub,opts);

x_tsp = logical(round(x_tsp));
Gsol = graph(idxs(x_tsp,1),idxs(x_tsp,2),[],numnodes(G));
% Gsol = graph(idxs(x_tsp,1),idxs(x_tsp,2)); % Also works in most cases

hold on
highlight(hGraph,Gsol,'LineStyle','-')
title('Solution with Subtours')

tourIdxs = conncomp(Gsol);
numtours = max(tourIdxs); % number of subtours
%fprintf('# of subtours: %d\n',numtours);

A = spalloc(0,lendist,0); % Allocate a sparse linear inequality constraint matrix
b = [];
while numtours > 1 % Repeat until there is just one subtour
    % Add the subtour constraints
    b = [b;zeros(numtours,1)]; % allocate b
    A = [A;spalloc(numtours,lendist,nStops)]; % A guess at how many nonzeros to allocate
    for ii = 1:numtours
        rowIdx = size(A,1) + 1; % Counter for indexing
        subTourIdx = find(tourIdxs == ii); % Extract the current subtour
%         The next lines find all of the variables associated with the
%         particular subtour, then add an inequality constraint to prohibit
%         that subtour and all subtours that use those stops.
        variations = nchoosek(1:length(subTourIdx),2);
        for jj = 1:length(variations)
            whichVar = (sum(idxs==subTourIdx(variations(jj,1)),2)) & ...
                       (sum(idxs==subTourIdx(variations(jj,2)),2));
            A(rowIdx,whichVar) = 1;
        end
        b(rowIdx) = length(subTourIdx) - 1; % One less trip than subtour stops
    end

    % Try to optimize again
    [x_tsp,costopt,exitflag,output] = intlinprog(dist,intcon,A,b,Aeq,beq,lb,ub,opts);
    x_tsp = logical(round(x_tsp));
    Gsol = graph(idxs(x_tsp,1),idxs(x_tsp,2),[],numnodes(G));
    % Gsol = graph(idxs(x_tsp,1),idxs(x_tsp,2)); % Also works in most cases
    
    % Visualize result
    hGraph.LineStyle = 'none'; % Remove the previous highlighted path
    highlight(hGraph,Gsol,'LineStyle','-')
    drawnow
    
    % How many subtours this time?
    tourIdxs = conncomp(Gsol);
    numtours = max(tourIdxs); % number of subtours
    %fprintf('# of subtours: %d\n',numtours)
    
end

arr = [idxs(x_tsp) idxs(x_tsp, 2)];
coords = zeros(22, 2);

count = 2;


coords(1) = arr(1);
coords(23) = arr(23);
arr(1) = NaN;
arr(23) = NaN;

loc = coords(23);

% search = find(arr == loc);
% temp = count + 21;
% temp = temp + 1;
% coords(temp) = arr(search);
while count < 22
     search = find(arr == loc);
     
     if search > 22
         search = search - 22;
     else
         search = search + 22;
     end
     coords(count) = loc;
     temp = count + 22;
     coords(temp) = arr(search);
     
     arr(search) = NaN;
     if search > 22
         temp2 = search - 22;
         arr(temp2) = NaN;
     else
         temp3 = search + 22;
         arr(temp3) = NaN;
     end
     
     loc = coords(temp);
     count = count + 1;
end
    
%disp(idxs(x_tsp, 1));
%disp(idxs(x_tsp, 2));
disp(coords);
disp(capList');
title('Route');
hold off