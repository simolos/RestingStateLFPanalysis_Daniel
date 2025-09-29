function save_open_figures()

    figures = findobj('Type', 'figure');
    
    % Loop over all figures and save them
    for i = 1:length(figures)
        % Create a filename based on the figure number
        filename = sprintf('figure_%d.jpg', i);  % Change format if needed (.jpg, .pdf, etc.)
        
        % Save the figure
        saveas(figures(i), filename);
    end


end
