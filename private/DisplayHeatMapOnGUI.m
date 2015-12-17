function [] = DisplayHeatMapOnGUI(heatmap)
global figHandles
subplot(figHandles.heatMapFigure)
imagesc(uint8(heatmap*10)),colormap('jet')
set(gca,'xtick',[],'ytick',[])
freezeColors