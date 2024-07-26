% optimization_experiment.m

% Main script for running optimization experiments
functions = {@F1, @F6, @F9}; % Benchmark functions
dimensions = [2, 10]; % Dimensions to test
algorithms = {@runGeneticAlgorithm, @runParticleSwarm, @runSimulatedAnnealing}; % Optimization algorithms
num_runs = 15; % Number of runs for each algorithm

% Define bounds for each function
bounds = {[-100, 100], [-100, 100], [-5, 5]}; % for F1, F6, F9 respectively

for f = 1:length(functions)
    for d = 1:length(dimensions)
        D = dimensions(d);
        lb = bounds{f}(1) * ones(1, D);
        ub = bounds{f}(2) * ones(1, D);
        
        % Initialize the function for this dimension
        func = functions{f};
        func(zeros(1, D));  % This call initializes the persistent variables
        
        for a = 1:length(algorithms)
            results = zeros(num_runs, 1);
            evals = zeros(num_runs, 1);
            all_conv_histories = cell(num_runs, 1);
            
            fprintf('Function: F%d, Dimension: %d, Algorithm: %s\n', f, D, func2str(algorithms{a}));
            fprintf('Run\tBest Value\tFunction Evaluations\n');
            
            for i = 1:num_runs
                [results(i), evals(i), conv_history] = algorithms{a}(func, D, lb, ub);
                fprintf('%d\t%.6f\t%d\n', i, results(i), evals(i));
                all_conv_histories{i} = conv_history;
            end
            
            avg = mean(results);
            std_dev = std(results);
            best = min(results);
            worst = max(results);
            avg_evals = mean(evals);
            
            % Display summary results
            fprintf('\nSummary:\n');
            fprintf('Average: %.6f\n', avg);
            fprintf('Std Dev: %.6f\n', std_dev);
            fprintf('Best: %.6f\n', best);
            fprintf('Worst: %.6f\n', worst);
            fprintf('Avg Evaluations: %.0f\n\n', avg_evals);
            
            % Plot convergence graph
            max_length = max(cellfun(@length, all_conv_histories));
            padded_histories = cellfun(@(x) [x, nan(1, max_length - length(x))], all_conv_histories, 'UniformOutput', false);
            all_histories_matrix = vertcat(padded_histories{:});
            mean_history = nanmean(all_histories_matrix, 1);
            std_history = nanstd(all_histories_matrix, 1);
            
            figure;
            x = 1:max_length;
            y = mean_history;
            std_upper = y + std_history;
            std_lower = y - std_history;
            
            hold on;
            fill([x, fliplr(x)], [std_upper, fliplr(std_lower)], 'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
            plot(x, y, 'b', 'LineWidth', 2);
            
            title(sprintf('Mean Convergence for F%d, D=%d, %s', f, D, func2str(algorithms{a})));
            xlabel('Iteration');
            ylabel('Best Fitness');
            set(gca, 'YScale', 'log');  % Set y-axis to logarithmic scale
            
            legend('Standard Deviation', 'Mean Convergence');
            
            hold off;
            
            % Save the figure
            fig_filename = sprintf('convergence_F%d_D%d_%s.png', f, D, func2str(algorithms{a}));
            saveas(gcf, fig_filename);
        end
    end
end

% Optimization algorithm functions
function [best_val, num_evals, conv_history] = runGeneticAlgorithm(func, D, lb, ub)
    global ga_history;
    ga_history = [];
    options = optimoptions('ga', 'MaxGenerations', 1000, 'PopulationSize', 50, ...
                           'FunctionTolerance', 1e-6, 'Display', 'off', ...
                           'OutputFcn', @gaOutputFcn);
    [~, best_val, ~, output] = ga(func, D, [], [], [], [], lb, ub, [], options);
    num_evals = output.funccount;
    conv_history = ga_history;
end

function [best_val, num_evals, conv_history] = runParticleSwarm(func, D, lb, ub)
    global pso_history;
    pso_history = [];
    options = optimoptions('particleswarm', 'SwarmSize', 50, 'MaxIterations', 1000, ...
                           'FunctionTolerance', 1e-6, 'Display', 'off', ...
                           'OutputFcn', @psoOutputFcn);
    [~, best_val, ~, output] = particleswarm(func, D, lb, ub, options);
    num_evals = output.funccount;
    conv_history = pso_history;
end

function [best_val, num_evals, conv_history] = runSimulatedAnnealing(func, D, lb, ub)
    global sa_history;
    sa_history = [];
    options = optimoptions('simulannealbnd', 'MaxIterations', 1000, ...
                           'FunctionTolerance', 1e-6, 'Display', 'off', ...
                           'OutputFcn', @saOutputFcn);
    [~, best_val, ~, output] = simulannealbnd(func, zeros(1,D), lb, ub, options);
    num_evals = output.funccount;
    conv_history = sa_history;
end

% Output functions for each algorithm
function [state, options, optchanged] = gaOutputFcn(options, state, flag)
    global ga_history;
    optchanged = false;
    if strcmp(flag, 'iter')
        ga_history(end+1) = min(state.Best);
    end
end

function stop = psoOutputFcn(optimValues, state)
    global pso_history;
    stop = false;
    if strcmp(state, 'iter')
        pso_history(end+1) = optimValues.bestfval;
    end
end

function [stop, options, optchanged] = saOutputFcn(options, optimValues, flag)
    global sa_history;
    stop = false;
    optchanged = false;
    if strcmp(flag, 'iter')
        sa_history(end+1) = optimValues.bestfval;
    end
end

% Benchmark functions
function y = F1(x)
    persistent o f_bias
    if isempty(o) || numel(o) ~= numel(x)
        o = 100 * ones(size(x));
        f_bias = -450;
    end
    z = x - o;
    y = sum(z.^2) + f_bias;
end

function y = F6(x)
    persistent o f_bias
    if isempty(o) || numel(o) ~= numel(x)
        o = 100 * ones(size(x));
        f_bias = 390;
    end
    z = x - o + 1;
    y = sum(100 * (z(1:end-1).^2 - z(2:end)).^2 + (z(1:end-1) - 1).^2) + f_bias;
end

function y = F9(x)
    persistent o f_bias
    if isempty(o) || numel(o) ~= numel(x)
        o = 100 * ones(size(x));
        f_bias = -330;
    end
    z = x - o;
    y = sum(z.^2 - 10*cos(2*pi*z) + 10) + f_bias;
end