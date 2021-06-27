function varargout = mtsp_ga_multi_ch(xy,dmat,salesmen,min_tour,max_tour,tw,pop_size,num_iter,use_complex,show_prog,show_res)
% MTSP_GA_MULTI_CH Multiple Traveling Salesmen Problem (M-TSP) Genetic Algorithm (GA) using multi-chromosome representation
%   Finds a (near) optimal solution to a variation of the M-TSP by setting
%   up a GA to search for the shortest route, taking into account
%   additional constraints, and minimizing the number of salesmen.
%
% Summary:
%     1. Each salesman starts at the first location, and ends at the first
%        location, but travels to a unique set of cities in between
%     2. Except for the first, each city is visited by exactly one salesman
%     3. The algorithm uses a special, so-called multi-chromosome genetic
%        representation to code solutions into individuals.
%     4. Special genetic operators (even complex ones) are used.
%     5. The number of salesmen used is minimized during the algorithm
%     6. Additional constraints have to be satisfied
%        - minimum number of locations, what each salesmen visit
%        - maximum distane travelled by each salesmen
%     7. Time windows can be defined for each locations (e.g. packing/loading times).
%
% Note: The Fixed Start/End location is taken to be the first XY point
%
% Inputs:
%     XY (float) is an Nx2 matrix of city locations, where N is the number of cities
%     DMAT (float) is an NxN matrix of city-to-city distances or costs
%     SALESMEN (scalar integer) is the number of salesmen to visit the cities
%     MIN_TOUR (scalar integer) is the minimum number of cities for each
%				salesmen, NOT including the start/end point
%     MAX_TOUR (scalar integer) is the maximum tour length for each salesmen
%     TW (scalar_integer) is the time window for each location
%     POP_SIZE (scalar integer) is the size of the population (should be divisible by 8)
%     NUM_ITER (scalar integer) is the number of desired iterations for the algorithm to run
%     USE_COMPLEX (scalar boolen 0/1) is the flag wether to use complex mutation operators or not
%     SHOW_PROG (scalar logical) shows the GA progress if true
%     SHOW_RES (scalar logical) shows the GA results if true
%
% Outputs:
%     OPT_RTE (integer array) is the best route found by the algorithm
%     MIN_DIST (scalar float) is the total distance traveled by the salesmen
%     OPT_ITER (scalar int) is the number of iterations until the optimal solution has been found
%	  OPT_TIME (scalar float) is the time in milliseconds until the optimal solution has been found
%     DIST_HISTORY (float array) is the history of distances of best found solutions
%
% Authors: Andras Kiraly, Janos Abonyi
% Email: kiralya@fmt.uni-pannon.hu
% Release Date: 16/10/2014
% The implementation is based on the work of Joseph Kirk: mtspf_ga
%
% *************************************************************************
% --== Reference notice ==--
% If you use this implementation in your work, please cite out paper:
%
% Andras Kiraly, Janos Abonyi: Redesign of the Supply of Mobile Mechanics 
% based on a novel Genetic Optimization Algorithm using Google Maps API. 
% Engineering Applications of Artificial Intelligence, 2014.
% *************************************************************************
% Process Inputs and Initialize Defaults
nargs = 11;
for k = nargin:nargs-1
    switch k
        case 0
            xy = 40*rand(40,2);
        case 1
            N = size(xy,1);
            a = meshgrid(1:N);
            dmat = reshape(sqrt(sum((xy(a,:)-xy(a',:)).^2,2)),N,N);
        case 2
            salesmen = 8;
        case 3
            min_tour = 5;
		case 4
            max_tour = 100;
		case 5
            tw = 0;
        case 6
            pop_size = 80;
        case 7
            num_iter = 500;
        case 8
            use_complex = 0;
		case 9
            show_prog = 1;
        case 10
            show_res = 1;
        otherwise
    end
end
merging_prob = 0.3;
% Verify Inputs
[N,dims] = size(xy);
[nr,nc] = size(dmat);
if N ~= nr || N ~= nc
    error('Invalid XY or DMAT inputs!')
end
n = N - 1; % Separate Start/End City
% Sanity Checks
salesmen = max(1,min(n,round(real(salesmen(1)))));
min_tour = max(1,min(floor(n/salesmen),round(real(min_tour(1)))));
pop_size = max(8,8*ceil(pop_size(1)/8));
num_iter = max(1,round(real(num_iter(1))));
show_prog = logical(show_prog(1));
show_res = logical(show_res(1));
% Initializations for Route Break Point Selection
num_brks = salesmen-1;
dof = n - min_tour*salesmen;          % degrees of freedom
addto = ones(1,dof+1);
for k = 2:num_brks
    addto = cumsum(addto);
end
cum_prob = cumsum(addto)/sum(addto);
% Initialize the Populations
pop_rte = zeros(pop_size,n);          % population of routes
pop_brk = zeros(pop_size,num_brks);   % population of breaks
for k = 1:pop_size
    pop_rte(k,:) = randperm(n)+1;
    pop_brk(k,:) = randbreaks();
end
% Select the Colors for the Plotted Routes
clr = [1 0 0; 0 0 1; 0.67 0 1; 0 1 0; 1 0.5 0];
if salesmen > 5
    clr = hsv(salesmen);
end
% Run the GA
global_min      = Inf;
tmp_pop_8       = cell(1,8);
new_pop         = cell(1,pop_size);
total_dist      = zeros(1,pop_size);
dist_history    = zeros(1,num_iter);
if show_prog
    pfig = figure('Name','MTSPF_GA | Current Best Solution','Numbertitle','off');
end
% ----=== TARNSFORMATION --> multiple chromosome [BEGIN] ===----
pop = cell(1,pop_size);
for k = 1: pop_size
    pop{k}.ch{1} = pop_rte(k, 1:pop_brk(k,1));
    for j=2:salesmen-1
        pop{k}.ch{j} = pop_rte(k, pop_brk(k,j-1)+1:pop_brk(k,j));
    end
    pop{k}.ch{salesmen} = pop_rte(k, pop_brk(k,end)+1:n);
end
% ----=== TARNSFORMATION --> multiple chromosome [END] ===----
penalty_rate = 100;
start_time = cputime; % get actual time for performance measure
for iter = 1:num_iter
     % Evaluate Members of the Population
    for p = 1:pop_size
        d = 0;
        for s = 1:length(pop{p}.ch)
            sman = pop{p}.ch{s};
			d2 = 0;
			if ~isempty(sman)
				d2 = d2 + dmat(1,sman(1)) + tw; % Add Start Distance
				for k = 1:length(sman)-1
					d2 = d2 + dmat(sman(k),sman(k+1)) + tw;
				end
				d2 = d2 + dmat(sman(end),1); % Add End Distance
				if (d2 > max_tour)
					d2 = d2 + (d2 - max_tour) * penalty_rate;
				end
			end
			d = d + d2;
        end
        total_dist(p) = d;
    end
    % Find the Best Route in the Population
    [min_dist,index] = min(total_dist);
    dist_history(iter) = min_dist;
    if min_dist < global_min
        global_min = min_dist; % the optimal solution so far
        opt_rte = pop{index}; % the best solution so far
        opt_time = cputime - start_time; % compute the elapsed time
        opt_iter = iter; % store the iteration number
		salesmen = sum(cellfun(@(x) length(x), opt_rte.ch) > 0);
        if show_prog
            % Plot the Best Route
            figure(pfig);
            for s = 1:salesmen
                rte = [1 opt_rte.ch{s} 1];
                if dims == 3, 
                    plot3(xy(rte,1),xy(rte,2),xy(rte,3),'.-','Color',clr(s,:));
                else
                    plot(xy(rte,1),xy(rte,2),'.-','Color',clr(s,:));
                end
                title(sprintf('Total Distance = %1.4f, Iteration = %d',min_dist,iter));
                hold on
            end
            if dims == 3,
                plot3(xy(1,1),xy(1,2),xy(1,3),'ko');
            else
                plot(xy(1,1),xy(1,2),'ko'); 
            end
            hold off
        end
    end
    % Genetic Algorithm Operators
    rand_grouping = randperm(pop_size);
    for p = 8:8:pop_size
        rpop    = pop(rand_grouping(p-7:p));
        dists   = total_dist(rand_grouping(p-7:p));
        [ignore,idx] = min(dists);%#ok
        best_of_8 = rpop{idx};
		best_of_8.ch(:,cellfun(@(c) isempty(c), best_of_8.ch)) = [];
        
        for k = 1:8 % Generate New Solutions
            
            tmp_pop_8{k} = best_of_8;
			lbestch = length(best_of_8.ch);
            switch k
                case 2 % Flip
                    r = randperm(lbestch);
                    smen = r(1:ceil(rand*lbestch)); % salesmen selected for flip
                    for k2 = 1:length(smen)
						if ~isempty(best_of_8.ch{smen(k2)})
							rte_ins_pts = sort(ceil(length(best_of_8.ch{smen(k2)})*rand(1,2)));
							I = rte_ins_pts(1);
							J = rte_ins_pts(2);
							tmp_pop_8{k}.ch{smen(k2)}(I:J)   = fliplr(tmp_pop_8{k}.ch{smen(k2)}(I:J));
						end
                    end
                case 3 % Swap
                    smen = ceil(rand(1,2)*lbestch); % the 2 salesmen selected for swap
                    rte_ins_pts = sort(ceil(min(length(best_of_8.ch{smen(1)}),length(best_of_8.ch{smen(2)}))*rand(1,2)));
                    I = rte_ins_pts(1);
                    J = rte_ins_pts(2);
					if ~isempty(best_of_8.ch{smen(1)})
						tempseq = tmp_pop_8{k}.ch{smen(1)}(I:J);
						tmp_pop_8{k}.ch{smen(1)}(I:J) = tmp_pop_8{k}.ch{smen(2)}(I:J);
						tmp_pop_8{k}.ch{smen(2)}(I:J) = tempseq;
					end
                case 4 % Slide
                    r = randperm(lbestch);
                    smen = r(1:ceil(rand*lbestch)); % salesmen selected for slide
                    toslide = tmp_pop_8{k}.ch{smen(1)}(end);
                    for k2 = 2:length(smen)
						if ~isempty(best_of_8.ch{smen(k2)})
							tempgene = tmp_pop_8{k}.ch{smen(k2)}(end);
							tmp_pop_8{k}.ch{smen(k2)}(2:end) = tmp_pop_8{k}.ch{smen(k2)}(1:end-1);
							tmp_pop_8{k}.ch{smen(k2)}(1) = toslide;
							toslide = tempgene;
						end
                    end
                    tmp_pop_8{k}.ch{smen(1)}(2:end) = tmp_pop_8{k}.ch{smen(1)}(1:end-1);
                    tmp_pop_8{k}.ch{smen(1)}(1) = toslide;
                case 5 % crossover
                    if (lbestch > 1)
                        if (sum(cellfun(@(c) ~isempty(c), tmp_pop_8)) > 1)
                            offsets = crossover_op(tmp_pop_8{k});
                        end
                        tmp_pop_8{k}.ch{offsets{1}(1)} = offsets{2};
                        tmp_pop_8{k}.ch{offsets{1}(2)} = offsets{3};
                    end
                case 6 % Flip and Crossover
					if (use_complex == 1)
						r = randperm(lbestch);
						smen = r(1:ceil(rand*lbestch)); % salesmen selected for flip
						for k2 = 1:length(smen)
							rte_ins_pts = sort(ceil(length(best_of_8.ch{smen(k2)})*rand(1,2)));
							I = rte_ins_pts(1);
							J = rte_ins_pts(2);
							tmp_pop_8{k}.ch{smen(k2)}(I:J)   = fliplr(tmp_pop_8{k}.ch{smen(k2)}(I:J));
						end
					end
                    
                    % --== CROSSOVER ==--
                    if (lbestch > 1)
                        if (sum(cellfun(@(c) ~isempty(c), tmp_pop_8)) > 1)
                            offsets = crossover_op(tmp_pop_8{k});
                        end
                        tmp_pop_8{k}.ch{offsets{1}(1)} = offsets{2};
                        tmp_pop_8{k}.ch{offsets{1}(2)} = offsets{3};
                    end
                case 7 % Swap and Crossover
					if (use_complex == 1)
						smen = ceil(rand(1,2)*lbestch); % the 2 salesmen selected for swap
						rte_ins_pts = sort(ceil(min(length(best_of_8.ch{smen(1)}),length(best_of_8.ch{smen(2)}))*rand(1,2)));
						I = rte_ins_pts(1);
						J = rte_ins_pts(2);
						tempseq = tmp_pop_8{k}.ch{smen(1)}(I:J);
						tmp_pop_8{k}.ch{smen(1)}(I:J) = tmp_pop_8{k}.ch{smen(2)}(I:J);
						tmp_pop_8{k}.ch{smen(2)}(I:J) = tempseq;
					end
                    
                    % --== CROSSOVER ==--
                    if (lbestch > 1)
                        if (sum(cellfun(@(c) ~isempty(c), tmp_pop_8)) > 1)
                            offsets = crossover_op(tmp_pop_8{k});
                        end
                        tmp_pop_8{k}.ch{offsets{1}(1)} = offsets{2};
                        tmp_pop_8{k}.ch{offsets{1}(2)} = offsets{3};
                    end
                case 8 % Slide and Crossover
					if (use_complex == 1)
						r = randperm(lbestch);
						smen = r(1:ceil(rand*lbestch)); % salesmen selected for slide
						%smen = [1 2];
						toslide = tmp_pop_8{k}.ch{smen(1)}(end);
						for k2 = 2:length(smen)
							tempgene = tmp_pop_8{k}.ch{smen(k2)}(end);
							tmp_pop_8{k}.ch{smen(k2)}(2:end) = tmp_pop_8{k}.ch{smen(k2)}(1:end-1);
							tmp_pop_8{k}.ch{smen(k2)}(1) = toslide;
							toslide = tempgene;
						end
						tmp_pop_8{k}.ch{smen(1)}(2:end) = tmp_pop_8{k}.ch{smen(1)}(1:end-1);
						tmp_pop_8{k}.ch{smen(1)}(1) = toslide;
					end
                    
                    % --== CROSSOVER ==--
                    if (lbestch > 1)
                        if (sum(cellfun(@(c) ~isempty(c), tmp_pop_8)) > 1)
                            offsets = crossover_op(tmp_pop_8{k});
                        end
                        tmp_pop_8{k}.ch{offsets{1}(1)} = offsets{2};
                        tmp_pop_8{k}.ch{offsets{1}(2)} = offsets{3};
                    end
                otherwise % Do Nothing
            end
        end
        for i=1:8
% 			tmp_pop_8(:,cellfun(@(c) isempty(c), tmp_pop_8)) = []
            new_pop{p-8+i} = tmp_pop_8{i};
        end
    end
    pop = new_pop;
end
if show_res
    % Plots
    figure('Name','MTSPF_GA | Results','Numbertitle','off');
    subplot(2,2,1);
    if dims == 3, plot3(xy(:,1),xy(:,2),xy(:,3),'k.');
    else plot(xy(:,1),xy(:,2),'k.'); end
    title('City Locations');
    subplot(2,2,2);
    imagesc(dmat([1 opt_rte.ch{:}],[1 opt_rte.ch{:}]));
    title('Distance Matrix');
    subplot(2,2,3);
    for s = 1:salesmen
        rte = [1 opt_rte.ch{s} 1];
        if dims == 3, plot3(xy(rte,1),xy(rte,2),xy(rte,3),'.-','Color',clr(s,:));
        else plot(xy(rte,1),xy(rte,2),'.-','Color',clr(s,:)); end
        title(sprintf('Total Distance = %1.4f',min_dist));
        hold on;
    end
    if dims == 3, plot3(xy(1,1),xy(1,2),xy(1,3),'ko');
    else plot(xy(1,1),xy(1,2),'ko'); end
    subplot(2,2,4);
    plot(dist_history,'b','LineWidth',2);
    title('Best Solution History');
    set(gca,'XLim',[0 num_iter+1],'YLim',[0 1.1*max([1 dist_history])]);
end
% Return Outputs
if nargout
    varargout{1} = opt_rte;
    varargout{2} = min_dist;
    varargout{3} = opt_iter;
    varargout{4} = opt_time;
    varargout{5} = dist_history;
end
    % Generate Random Set of Break Points
    function breaks = randbreaks()
        if min_tour == 1 % No Constraints on Breaks
            tmp_brks = randperm(n-1);
            breaks = sort(tmp_brks(1:num_brks));
        else % Force Breaks to be at Least the Minimum Tour Length
            num_adjust = find(rand < cum_prob,1)-1;
            spaces = ceil(num_brks*rand(1,num_adjust));
            adjust = zeros(1,num_brks);
            for kk = 1:num_brks
                adjust(kk) = sum(spaces == kk);
            end
            breaks = min_tour*(1:num_brks) + cumsum(adjust);
        end
	end
	% One-point crossover
	function offsets = crossover_op(parent)
		% --== CROSSOVER ==--
		r = randperm(lbestch);
		s_men = r(1:2); % salesmen selected for crossover
		if sum(cellfun(@length, parent.ch)) < length(xy)-1
			disp('Not enough location!');
		end
		M1 = length(parent.ch{s_men(1)});
		M2 = length(parent.ch{s_men(2)});
		if M1>1
			rr = randperm(M1-1);
		else
			rr = 1;
		end
		cp(1) = rr(1); % point of the crossover in the first salesman
		q1 = max(1,cp(1)-M1+min_tour); % lower bound of the crossover point for the second salesman
		q2 = min(M2,cp(1)+M2-min_tour); % upper bound of the crossover point for the second salesman
		rr = q1-1+randperm(q2-q1+1);
		cp(2) = rr(1);
		tempseq1 = parent.ch{s_men(1)}(cp(1)+1:end);
		
		offsets = cell(1,3);
		offsets{1} = s_men;
		if (rand <= merging_prob) % Merges the two salesmen into a single one
			offsets{2} = [parent.ch{s_men(1)} parent.ch{s_men(2)}];
		else
			offsets{2} = [parent.ch{s_men(1)}(1:cp(1)) parent.ch{s_men(2)}(cp(2)+1:end)];
			offsets{3} = [parent.ch{s_men(2)}(1:cp(2)) tempseq1];
		end
	end
end

lonList = [32.3895645 33.4677415 28.104897 33.1225678 33.0588435 30.6307191 30.9518734 33.7440023 30.2853231 31.7140272 34.2001086 34.4798123 33.5829154 32.9053466 30.721413 32.3618738 26.8495948 33.1796344 32.4827796 31.2698358 34.4348071 30.785589];
% Allocate x-coordinates of nStops
latList = [-86.3050869 -88.7891262 -81.631729 -89.0535044 -89.5903167 -84.4146814 -85.5125157 -90.7248187 -81.405824 -86.2643253 -90.5709323 -87.7340372 -86.632742 -86.7085767 -86.5662155 -86.299616 -80.0583981 -87.5531051 -85.5596159 -86.2433576 -86.9329862 -86.121099];

axy = [latList;lonList];
xy = transpose(axy);
dmat = [0	185	490	203	236	188	126	315	392	52	336	199	97	48	142	2	616	101	48	85	158	122
184	0	672	33	59	370	308	134	574	232	146	109	151	144	325	184	798	82	230	258	157	290
477	661	0	677	733	295	367	829	178	456	854	717	600	524	425	483	151	576	444	427	676	403
202	32	678	0	36	378	307	129	580	225	142	144	169	162	302	202	804	103	248	252	192	284
236	58	734	36	0	447	334	99	636	252	112	178	212	205	310	235	860	143	281	278	226	310
188	371	296	380	445	0	80	501	198	152	522	385	283	234	138	182	422	286	177	140	344	116
125	308	368	312	338	81	0	438	270	80	459	322	220	171	76	120	494	224	142	62	281	46
314	132	833	129	99	500	438	0	735	362	37	225	282	274	408	314	959	212	360	388	272	440
392	575	180	580	636	198	271	732	0	359	758	620	503	438	328	386	277	490	347	330	580	306
53	233	457	225	251	152	80	363	359	0	386	248	147	98	84	50	583	149	98	33	208	70
336	145	854	142	112	523	460	37	756	386	0	187	261	293	422	336	980	225	382	419	234	456
198	109	717	144	178	385	322	224	619	248	186	0	123	156	337	199	843	101	245	282	50	318
97	152	600	169	212	284	221	281	502	147	261	123	0	55	236	98	726	68	144	181	83	217
47	145	536	163	206	234	172	275	438	98	294	156	55	0	187	48	662	61	94	131	116	168
142	324	425	297	309	138	76	405	327	84	421	337	236	187	0	141	551	237	187	50	297	32
2	185	488	203	234	187	124	315	390	50	337	199	98	48	141	0	614	101	47	83	159	120
605	788	152	804	860	422	494	956	275	583	981	844	727	651	552	610	0	703	571	554	803	530
101	83	588	103	143	287	224	213	490	149	225	101	69	61	237	101	714	0	147	182	122	219
48	231	444	249	281	177	140	361	347	99	382	245	144	94	187	47	570	147	0	111	204	144
88	258	427	252	277	140	57	389	329	35	421	284	182	133	50	85	553	184	113	0	243	38
158	158	677	193	226	345	282	272	579	208	234	50	83	115	297	159	802	122	204	241	0	278
124	290	404	284	309	116	46	440	306	71	457	319	218	169	36	121	530	220	143	38	279	0];

mtsp_ga_multi_ch(xy,dmat,salesmen,min_tour,max_tour,tw,pop_size,num_iter,use_complex,show_prog,show_res);