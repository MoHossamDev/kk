function water_tank_gui()
    fig = figure('Name', 'Water Tank Calculator', ...
                'Position', [300, 300, 800, 600], ...
                'MenuBar', 'none', ...
                'NumberTitle', 'off');

    subplot(1, 2, 1);
    set(gca, 'Visible', 'off');

    uicontrol('Style', 'text', ...
             'String', 'Volume (m³):', ...
             'Position', [50, 320, 100, 20]);

    volume_input = uicontrol('Style', 'edit', ...
                            'Position', [160, 320, 100, 20]);

    uicontrol('Style', 'text', ...
             'String', 'Radius (m):', ...
             'Position', [50, 280, 100, 20]);

    radius_input = uicontrol('Style', 'edit', ...
                            'Position', [160, 280, 100, 20]);

    uicontrol('Style', 'pushbutton', ...
             'String', 'Calculate', ...
             'Position', [150, 220, 100, 30], ...
             'Callback', {@calculate_callback, volume_input, radius_input, fig});

    subplot(1, 2, 2);
    view(45, 30);
    grid on;
    xlabel('X (m)');
    ylabel('Y (m)');
    zlabel('Height (m)');
    title('Water Tank Visualization');
    axis equal;

    result_text = uicontrol('Style', 'text', ...
                           'Position', [50, 180, 300, 30], ...
                           'String', '');

    uicontrol('Style', 'pushbutton', ...
             'String', 'End', ...
             'Position', [150, 150, 100, 30], ...
             'Callback', @(~,~) close(fig));
end

function calculate_callback(~, ~, volume_input, radius_input, fig)
    V = str2double(get(volume_input, 'String'));
    r = str2double(get(radius_input, 'String'));

    if isnan(V) || V <= 0
        errordlg('Invalid volume value', 'Error');
        return;
    end

    if isnan(r) || r <= 0
        errordlg('Invalid radius value', 'Error');
        return;
    end
    tol = 1e-6;
    max_iter = 1000;
    h_initial = V / (pi * r^2);

    h = newton_raphson(V, r, tol, max_iter, h_initial);

    if isempty(h) || h <= 0
        errordlg('Calculation did not converge or resulted in invalid height', 'Error');
        return;
    end

    subplot(1, 2, 2);
    cla;
    hold on;

    % lighting
    light('Position', [1 1 1], 'Style', 'infinite');
    lighting gouraud;

    % cylinder (tank) with metallic appearance
    [X, Y, Z] = cylinder(r, 100);  %  resolution
    Z = Z * h * 1.1;  % tank slightly taller than water
    tank = surf(X, Y, Z, ...
        'FaceColor', [0.8 0.8 0.9], ...
        'FaceAlpha', 0.9, ...
        'EdgeColor', [0.7 0.7 0.8], ...
        'EdgeAlpha', 0.9, ...
        'AmbientStrength', 0.9, ...
        'SpecularStrength', 0.9);

    % Water inside tank with realistic blue
    [Xw, Yw, Zw] = cylinder(r * 0.99, 100);
    Zw = Zw * h;
    water = surf(Xw, Yw, Zw, ...
        'FaceColor', [0.2 0.4 0.8], ...
        'FaceAlpha', 0.6, ...
        'EdgeColor', 'none', ...
        'AmbientStrength', 0.4, ...
        'SpecularStrength', 0.9);

    % top and bottom circles
    t = linspace(0, 2*pi, 100);
    % Bottom circle (metallic)
    fill3(r*cos(t), r*sin(t), zeros(size(t)), [0.8 0.8 0.9], ...
        'FaceAlpha', 0.6, 'EdgeColor', [0.7 0.7 0.8]);
    % Water surface circle
    fill3(r*cos(t), r*sin(t), h*ones(size(t)), [0.2 0.4 0.8], ...
        'FaceAlpha', 0.8, 'EdgeColor', 'none');

    % measurement lines
    line([0 r], [0 0], [0 0], 'Color', 'k', 'LineStyle', '--');
    line([0 0], [0 0], [0 h], 'Color', 'k', 'LineStyle', '--');

    % labels with background
    bbox = 'white';
    text(r*1.2, 0, h/2, sprintf('Height: %.2f m', h), ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', bbox, ...
        'FontWeight', 'bold');
    text(r*1.2, 0, h/4, sprintf('Volume: %.2f m³', V), ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', bbox, ...
        'FontWeight', 'bold');
    text(r/2, -r*0.2, 0, sprintf('Radius: %.2f m', r), ...
        'HorizontalAlignment', 'center', ...
        'BackgroundColor', bbox, ...
        'FontWeight', 'bold');

    % axes appearance
    view(45, 30);
    grid on;
    set(gca, ...
        'GridAlpha', 0.2, ...
        'GridColor', [0.5 0.5 0.5], ...
        'Box', 'on', ...
        'LineWidth', 1.2);
    axis equal;
    axis([-r*1.5 r*1.5 -r*1.5 r*1.5 0 h*1.5]);

    %  3D rotation
    rotate3d on;
    camlight('headlight');
    material dull;

    % result text
    set(findobj(fig, 'Style', 'text', 'Position', [50, 180, 300, 30]), 'String', sprintf('Height: %.2f m', h));
end

% Newton-Raphson method function
function h_final = newton_raphson(V, r, tol, max_iter, h_initial)
    pi_val = pi;
    f = @(h) pi_val * r^2 * h - (2/3) * pi_val * r^3 - V;
    df = @(h) pi_val * r^2;
    h_old = h_initial;

    for i = 1:max_iter
        h_new = h_old - f(h_old) / df(h_old);
        if abs(h_new - h_old) < tol
            h_final = h_new;
            return;
        end
        h_old = h_new;
    end
    h_final = [];
end

water_tank_gui();
