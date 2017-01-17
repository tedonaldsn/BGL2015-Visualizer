# BGL2015-Visualizer
https://basimulation.org/bgl2015-visualizer/

Tom Donaldson

tedonaldsn@icloud.com

# What
The BGL2015 Visualizer application is a graphical interface for a biobehavioral selectionist neural network, specifically the one described in this article:

* Burgos, José E., García-Leal, Óscar (2015). Autoshaped choice in artificial neural networks: Implications for behavioral economics and neuroeconomics. *Behavioural Processes*, **114**, 63-71. Retrieved from: https://www.ncbi.nlm.nih.gov/pubmed/25662745

The neural network model comes from the field of behavior analysis, and is intended to faithfully follow the general principles of operation of the brain, and produce behaviors that adhere to the principles of behavior analysis.

# Run Prebuilt App


## System Requirements
* MacOS 11.0 or later

## Steps
1. Go to https://github.com/tedonaldsn/BGL2015-Visualizer/releases
2. Click the line that says "BGL2015 Visualizer.app.zip"
3. In your downloads folder, double-click the zip file to expand it into a normal application.
4. Double click the application.
5. You will be asked if you are sure you want to open the application. Click open.
6. You should see the main sessions window as shown on page https://basimulation.org/bgl2015-visualizer/



# Build & Run Debug Version

## Requirements
* MacOS 11.0 or later
* Xcode 8.0 or later

## Get the Source

1. Go to https://github.com/tedonaldsn/BGL2015-Visualizer/releases
2. Download the source. This example uses the .zip file.
3. In your downloads folder, double-click the zip file to expand it into a normal folder.

## Set Up

1. In the BGL2015-Visualizer folder, double-click the BASimulation.xcworkspace file. This opens all of the components of the project, rather than just individual subprojects.
2. Set the Xcode scheme to BGL2015_OSX
3. On the left side of the Xcode window is the "Project Navigator". Click on the project named "BGL2015_OSX". To the right of the navigator you should now see "General" information about the BGL2015_OSX subproject.
4. Code signing for developer identification
	1. If the Signing section says "no accounts", click button to add an account. If you do not already have an Apple ID you want to use, you can "Create Apple ID..."
	2. OR: if there is a check item title "Automatically manage signing", make sure the box is checked, then use the pulldown menu to select or add an Apple ID.


## Build
1. In the "Product" menu, under submenu "Build For", select "Testing". Or press Shift-Command-U. All subprojects should compile without errors or warnings.
2. In the "Product" menu, select "Run". Or press Command-R. The main sessions window should appear.


# Third Party Code
In the navigator to the left of the Xcode window, note a project named CorePlot. 

CorePlot is an open source plotting framework for MacOS and iOS. You can find its license in the folder named "Resources" under CorePlot.

https://github.com/core-plot

