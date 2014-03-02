SCCaptureCamera
===============

A Custom Camera with AVCaptureSession to take a square picture. And the UI is patterned on Instagram.

It can work in iPad, too.

ScreenShots：
----------

iPhone4:[image](https://github.com/xhzengAIB/SCCaptureCamera/master/Screenshots/screenShot_iPhone4.png)
iPhone5:![image](https://github.com/xhzengAIB/SCCaptureCamera/master/Screenshots/screenShot_iPhone5.png)


Usage：
----------
0、Import four frameworks: 
```
CoreMedia.framework、QuartzCore.framework、AVFoundation.framework、ImmageIO.framework
```

1、Drag "SCCaptureCamera" and "SCCommon" to your project.

2、Import "SCNavigationController.h" and code like this:
```
    SCNavigationController *nav = [[SCNavigationController alloc] init];
    nav.scNaigationDelegate = self;
    [nav showCameraWithParentController:self];
```    
3、After take a picture, you can call back with delegate or a notification.

a. delegate:
```
- (void)didTakePicture:(SCNavigationController *)navigationController image:(UIImage *)image
```
b. notification:
```
add a notification whose name is kNotificationTakePicture (just search "kNotificationTakePicture" in my demo project)
```



Finally, set ```SWITCH_SHOW_DEFAULT_IMAGE_FOR_NONE_CAMERA``` which is in the file ```SCCaptureCameraController.m``` to ```0```, it is just a joke for the devices which cannot take a picture.





