# BGL2015-Visualizer
https://basimulation.org/bgl2015-visualizer/
# What
The BGL2015 Visualizer application is a graphical interface for a biobehavioral selectionist neural network, specifically the one described in this article:

* Burgos, José E., García-Leal, Óscar (2015). Autoshaped choice in artificial neural networks: Implications for behavioral economics and neuroeconomics. *Behavioural Processes*, **114**, 63-71. Retrieved from: https://www.ncbi.nlm.nih.gov/pubmed/25662745

The neural network model comes from the field of behavior analysis, and is intended to faithfully follow the general principles of operation of the brain, and produce behaviors that adhere to the principles of behavior analysis.


# System Requirements

* MacOS 11.0 or later
* Xcode 8.0 or later

# Build & Run
1. Go to https://github.com/tedonaldsn/BGL2015-Visualizer
2. Download the source. See the green "Clone or download" pull-down menu upper right of the file list.
3. If you downloaded the zip file, double-click the zip file to expand it into a normal folder.
4. In the BGL2015-Visualizer folder, double-click the BASimulation.xcworkspace file. This opens all of the components of the project, rather than just individual subprojects.
5. Set the Xcode scheme to BGL2015_OSX
6. In the "Product" menu, under submenu "Build For", select "Testing". Or press Shift-Command-U. All subprojects should compile without errors or warnings.
7. In the "Product" menu, select "Run". Or press Command-R. The main sessions window should appear.


# Third Party Code
In the navigator to the left of the Xcode window, note a project named CorePlot. 

CorePlot is an open source plotting framework for MacOS and iOS. You can find its license in the folder named "Resources" under CorePlot.

https://github.com/core-plot

