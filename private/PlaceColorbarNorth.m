function  [] = PlaceColorbarNorth(axisHandle)
axes(axisHandle)            
hcol = colorbar('Location','North','Ycolor','k');
            cpos=get(hcol,'Position');
             cpos(4)=cpos(4)/2; % Halve the thickness
            cpos(2)=cpos(2) + 0.057; % Move it outside the plot
            set(hcol,'Position',cpos)