# Analysis pipeline in Matlab for live-imaging.

This Matlab code which provides:
*   a convenient workflow to turn raw fluorescent time-series objects, generated from live imaging experiments in  biology, into systematically processed data.
* an intuitive user-interface to assess the data according to many descriptive variables.

![first image](https://raw.github.com/leej3/calciumImagingAnalysis/overiewOfGUI.png)
    
<!-- \caption[Menu to navigate through different time-series image files in custom analysis program.]{\textbf{Menu to navigate through different time-series image files}} -->

## Data storage 
The output of the data-acquisition software, Zen 2008, is a proprietary tiff file with the '.lsm' file extension. The 'tiffread' function downloaded from the Matlab file exchange was used to import the fluorescent time-series into Matlab. Additionally, other useful technical information contained within the lsm file were accessed using the 'LSM file toolbox' also downloaded from the Matlab file exchange. Subsequently all data was stored in the Matlab file format. A primary file holds all of the image-stack data (each individual pixel at each time-point) along with additional descriptive variables including technical data acquired by the Zeiss software during data acquisition, user-defined labels for the data file, and the ROI data in the form of coordinates and mean fluorescence at each time point. A compiled-data file summarises all the primary files within a given directory.

<!-- ![alt text](https://github.com/leej3/calciumImagingAnalysis/scriptOverview -->
    
Caption: Schematic of workflow using the custom-written Matlab program for analysis of fluorescent time-series

The analysis program is divided into three principle stages. The first stage consists of importing the time-series, selecting the regions of interest for analysis and storing this data in the native Matlab format. The second stage compiles the data from these files required for subsequent analysis into a single file. The third stage allows the user to filter and plot the data using any of the data-labels.


The data storage is performed in this manner for a number of reasons:

* Storage efficiency and performance. All image data converted from the proprietary '.lsm' format to the Matlab format stores the same information in less than 50\% of the original file size. Loading and saving in the native Matlab format increased the speed of these processes by 3- 5-fold which caused a significant improvement in the user-experience: the files, of approximately 50MB in size, loaded in approximately 1 second.
* Subsequent reassessment and analysis of the data was aided by the fact that any comments and ROI coordinates created by the user were all kept together with the raw image data. 
* Ease of compatibility in the event of upgrades to the program. The only time-consuming part of the analysis for a user is the selection of ROIs. Once performed, this information is stored in the primary file and is not altered. Furthermore, the format of this file is not altered: all changes in the code-base are made downstream therefore preserving backwards compatibility.
*  The compiled-data file containing all the descriptive variables and glomerular fluorescence curves for each file within an experiment is typically less than 1MB in size. Provided no changes to ROI coordinates were required, which requires the primary files, this compiled-data file could be stored and transferred by email etc. or exported to other programs, e.g. Microsoft Excel, with ease for subsequent reanalysis of the dataset as desired.    

The name of the primary file is defined by the user upon acquisition. This contains certain labels to define various aspects of the data point. As well as providing a system to easily discern the exact parameters of the data-collection for each data point by simply looking at the name, these labels are extracted by the program automatically to generate the descriptive variables for each time-series. e.g.'f03r02a dm5r dm2r dm1rs 52ebt t25C 15minsExposed John Grp3 2012\05\24.lsm'

The different labels include:

* unique code for each time-series on a given date - e.g: 'f01r01a'. This was defined by the fly (denoted by f and a 2-digit number ), each run (denoted by r and a 2-digit number)  and each sub-run (denoted by a letter) allowing complexity to the structure of the experiment.
* glomerulus - e.g: 'dm2'. Each active glomerulus for the time-series was denoted by two lower case letters followed by a number.
* odour stimulus - e.g: '10ebt'. This is defined as a 2-digit number representing concentration and a 3-letter user-defined tag for each odourant.
* temperature - e.g: 't25C'. The temperature of the perfusion saline could be recorded and entered as a 't' and a 'C' surrounding a 2-digit number.
* treatment - e.g: '15minsExposure'. A user-defined tag would be detected as the treatment. Files in a directory without this tag were defined as not treated.
* group - e.g: 'Grp1'. For blinding the experiments each genotype or treatment could be assigned a group number each day. Upon compilation these group numbers could be decoded so that the appropriate label could be assigned to each file.
* Date - e.g: '2012\11\28'. A 6-digit number, with or without a separator, in the format YYYY MM DD.
    



## User-interface 
<!-- ![alt text](./images/lth/analysisScript/analysisScriptGlomerularSelection} -->

Caption: Graphical User Interface for selecting a region of interest (ROI) Each ROI (which delineates an individual glomerulus) was selected by the user by using mouse clicks to define the outline upon a merged projection of the time-series (leftmost image). To aid in identification of glomeruli a heat-map displays regions of the antennal lobe that were activated by the odour pulse (top right image). Upon ROI selection the mean fluorescence within the ROI is displayed for each time-point of data collection (bottom right image). To aid in glomerular identification the entire time-series can be viewed in a separate window.


The user-interface generated by the program allows each time-series within a directory to be reviewed as depicted in Figure~\ref{fig:analysisScriptReviewPic}. This includes a list of ROIs previously selected by the user with the ROI's peak \%  change in fluorescence over the time-series. In addition to this textual summary, a graphical representation of the ROIs, including a square ROI for calculation of background fluorescence, are superimposed on a summary image. This image is constructed using a maximum intensity projection of the image-stack when the fluorescence is at its peak as well as the 3 time points before and after this. This image typically gave a good overview of the file; however, sometimes a more in-depth examination is required. This is provided by viewing the full image stack (a slider allows the user to move forwards and backwards to each image within the time-series). For time-series that had very low levels of fluorescence a high intensity version of the stack can be viewed. The user can navigate between different files by choosing a specific file or viewing the next or previous time-series within the directory. Comments can be saved with each file.
In the menu presented in Figure~\ref{fig:analysisScriptReviewPic} the 'Select This File' option allows the user to add/delete or edit specific ROIs for that time-series as depicted in Figure~\ref{fig:glomerularSelection}. Upon completion of ROI selection for all files within a directory a compiled-data file may be generated. At this point the codes assigned to the data on each day for the purposes of blinding are decoded using user-input and the appropriate group labels are assigned to each file.
 
 ![This is the caption\label{mylabel}](/url/of/image.png)
See figure \ref{mylabel}.

<!-- ./images/lth/analysisScript/analysisScriptPlottingMenu2} -->
    Caption: Menu to define variables for figure output


The compiled-data file contains the \%$\Delta$F(t) values for each ROI as well as the associated labels for the data. The program enables the user to output a variety of plots using this file (Examples of these plots can be seen in Chapter~\ref{cha:establishing_an_assay_for_observing_sth} in Figure~\ref{fig:firstExposure} and Figure~\ref{fig:firstExposureDiffSummary}). With the menu depicted in Figure~\ref{fig:analysisScriptPlottingMenu}, the user can define the grouping variables to categorise the data with and the grouping variable to compare across. Accordingly the program cycles through each unique value available for each grouping variable generating an additional plot for each. In addition to this functionality, the user can filter out certain data-points according to these grouping variables. With this range of functionality the program presents a powerful way to assess the data across multiple relevant grouping variables via a graphical user interface. 
