function outputValueLabel = GetOutputValueLabel(analysisArgs)
switch analysisArgs.plotType
    case 1
   outputValueLabel =  'F(t)';
case 2
   outputValueLabel =  'F(t)-F(0)';
case 3
   outputValueLabel =   '$\frac{F(t)-F(0)}{F(0)}$';
end