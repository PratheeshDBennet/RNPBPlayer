# RNPBPlayer:  A sample project React Native - iOS Native Component Bridging
This sample project explains a simple bridging between React Native and iOS Native components. So the background is though there are many common components readily available in React Native framework certain solutions needs platforms specific implementations. In order to achieve this, we technically have to bridge React Native to the components developed in native iOS.

![alt text](https://github.com/PratheeshDBennet/RNPBPlayer/blob/main/Screenshot%202021-09-09%20at%205.08.34%20PM.png)

# RCTBridge

In order to bridge the native components to RN has provided a class called RCTBridge. It is an async batched bridge used to communicate with the JavaScript application. The RCTBridgeModule provides the RCTViewManager interface needed to register a bridge module. So the class that has this RCTViewManager interface is manipulates the view hierarchy and send events back to the JS context. 

# RCTViewManager 

RCTViewManager has the view property which instantiates a native view to be managed by the module. Override this to return a custom view instance, which may be preconfigured with default properties, subviews, etc. 

Let’s take a sample use case. We have a video player app in RN. But the native player components are developed in Swift using AVFoundation. So to communicate between the RN components and the native player component in Swift, we are going to use RCTBridge. 

In our example we have class PBPlayerView which has the AVPlayer implementation that needs to be bridged to JS exporting certain properties and functions over to the JS so that the JS can communicate to the native components. 

Class PBPlayer is the bridging module that has the RCTViewManager interface and instantiates the PBPlayerView to be exported to JS. 

# Exporting Properties and functions

We have to provide an Objective-C file that exposes our Swift to the React Native Objective-C framework. Create the file “PBPlayer.m” by selecting “New File” as before and choose Objective-C file. 

PBPlayer.m native module includes a RCT_EXPORT_MODULE macro, which exports and registers the native module class with React Native. React Native will not expose any function or properties of PBPlayerView to React JavaScript unless explicitly done. To do so we have used RCT_EXPORT_METHOD() and RCT_EXPORT_VIEW_PROPERTY() macro. These macros exports the properties and methods of the view instantiated by the bridge module PBPlayer.swift.

