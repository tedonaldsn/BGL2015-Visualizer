# BGL2015-Visualizer
https://basimulation.org/bgl2015-visualizer/

Tom Donaldson

tedonaldsn@icloud.com

# What
The BGL2015 Visualizer application is a graphical interface for a biobehavioral selectionist neural network, specifically the one described in this article:

* Burgos, José E., García-Leal, Óscar (2015). Autoshaped choice in artificial neural networks: Implications for behavioral economics and neuroeconomics. *Behavioural Processes*, **114**, 63-71. Retrieved from: https://www.ncbi.nlm.nih.gov/pubmed/25662745

The neural network model comes from the field of behavior analysis, and is intended to faithfully follow the general principles of operation of the brain, and produce behaviors that adhere to the principles of behavior analysis.

# Run Prebuilt App
Note that you will be downloading the application from GitHub, not the Apple Store. Because of this your MacOS will choke without the extra security steps listed below.

*If enough people want it to act like a normal app (which I seriously doubt will happen), I will submit the app to the App Store.*

## System Requirements
* MacOS 11.0 or later

## Steps
1. Go to https://github.com/tedonaldsn/BGL2015-Visualizer/releases
2. Click the line that says "BGL2015 Visualizer.app.zip"
3. In your downloads folder, double-click the zip file to expand it into a normal application.
4. Double click the application.
5. You will be asked if you are sure you want to open the application. Click open. **The first time you try to run it, nothing visible will happen** (unless you happen to have the Console open). 
6. Open the MacOS System Preferences, click "Security & Privacy". You will need to approve running BGL2015 Visualizer there. When you do, it should run and show the main sessions window. **You will not have to fiddle with security on subsequent runs.**



# Build & Run Debug Version

## System Requirements
* MacOS 11.0 or later
* Xcode 8.0 or later

## Steps
1. Go to https://github.com/tedonaldsn/BGL2015-Visualizer/releases
2. Download the source. This example uses the .zip file.
3. In your downloads folder, double-click the zip file to expand it into a normal folder.
4. In the BGL2015-Visualizer folder, double-click the BASimulation.xcworkspace file. This opens all of the components of the project, rather than just individual subprojects.
5. Set the Xcode scheme to BGL2015_OSX
6. In the "Product" menu, under submenu "Build For", select "Testing". Or press Shift-Command-U. All subprojects should compile without errors or warnings.
7. In the "Product" menu, select "Run". Or press Command-R. The main sessions window should appear.


# Third Party Code
In the navigator to the left of the Xcode window, note a project named CorePlot. 

CorePlot is an open source plotting framework for MacOS and iOS. You can find its license in the folder named "Resources" under CorePlot.

https://github.com/core-plot

