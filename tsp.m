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
dist1 = [8.76190476190476 26.5 20.2 18.1538461538462 12.5333333333333 6.25 26.1666666666667 26.1333333333333 4.41666666666667 19.7647058823529 7.61538461538461 4.40909090909091 2.76470588235294 14.2 0.0909090909090909 35.5882352941176 10.1 1.92 4.19047619047619 7.9 6.88888888888889 36.7222222222222 3.2 4.46153846153846 24.7333333333333 15.4 11 38.3333333333333 19.4166666666667 8.52941176470588 4.19230769230769 6.90909090909091 8.52941176470588 32.4 8.40909090909091 46.3529411764706 8.3 9.24 12.2857142857143 7.9 16.1111111111111 67.8 56.4615384615385 19.7333333333333 18.4 69.4166666666667 12 38.0833333333333 50.2352941176471 27.5769230769231 27.2727272727273 31.5294117647059 42.5 22.1818181818182 8.94117647058824 58.8 17.76 20.3333333333333 33.85 22.4444444444444 2.76923076923077 25.3333333333333 15.6 10.75 38.6666666666667 18.75 8.35294117647059 5.53846153846154 7.68181818181818 9.58823529411765 29.7 9.22727272727273 47.2941176470588 10.3 9.96 12 9.65 15.7777777777778 29.6666666666667 16.9 8.25 42.4 20.9166666666667 6.58823529411765 6.84615384615385 9.63636363636364 12.1176470588235 30.9 10.6363636363636 50.5882352941176 14.3 11.24 13.1904761904762 11.3 17.1666666666667 4.05 41.6666666666667 13.2 12.6666666666667 30.7647058823529 14.8076923076923 12.9090909090909 13.7647058823529 13.8 8.5 24.8235294117647 28.7 7.08 6.66666666666667 17.25 6.44444444444444 36.5 18.0666666666667 6.66666666666667 27.0588235294118 12.3846153846154 10.0454545454545 10.1176470588235 7.6 5.63636363636364 29.0588235294118 22.4 5.6 2.71428571428571 14.1 2.55555555555556 48.8 30.25 2.17647058823529 8.61538461538461 12.7727272727273 16.1764705882353 40.5 14.3181818181818 56.2352941176471 21.3 14.44 18.5238095238095 13.6 24.4444444444444 29.9166666666667 44.4705882352941 23.8076923076923 22.8181818181818 25.7647058823529 32.7 17.7272727272727 16.1764705882353 49 13.88 15.6666666666667 28.95 17 22.7058823529412 9.53846153846154 6.68181818181818 5.76470588235294 8.4 2.27272727272727 34.2941176470588 14.9 3.96 1.66666666666667 10.4 3.94444444444444 7.15384615384615 11.8636363636364 17.2941176470588 42.1 15.3181818181818 57.7058823529412 22.5 15.28 20.047619047619 11.7 25.3888888888889 5.59090909090909 9.17647058823529 33.7 9.04545454545454 49.6470588235294 10.1 9.8 13.5238095238095 2.5 17.7222222222222 3.23529411764706 23.6 4.45454545454545 42.7647058823529 6.9 5.76 8.66666666666667 4.15 12.1111111111111 18.7 2.18181818181818 38.2941176470588 6.1 3.76 6.33333333333333 5.75 9.38888888888889 6.40909090909091 32.4705882352941 23.7 7.48 2.38095238095238 14.85 2 35.8823529411765 10.1 1.88 4.04761904761905 7.95 6.72222222222222 71.4 22.8 26.3333333333333 40.1 29.4444444444444 5.88 8.76190476190476 6.1 12.2222222222222 5.38095238095238 10.2 7.94444444444444 12.05 2.11111111111111 15.5];
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