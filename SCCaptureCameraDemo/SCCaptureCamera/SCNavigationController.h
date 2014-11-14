//
//  SCNavigationController.h
//  SCCaptureCameraDemo
//
//  Created by Aevitx on 14-1-17.
//  Copyright (c) 2014年 Aevitx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCDefines.h"

@protocol SCNavigationControllerDelegate;

@interface SCNavigationController : UINavigationController
@property(nonatomic, copy)NSString *customAlbumName;

- (void)showCameraWithParentController:(UIViewController*)parentController;

@property (nonatomic, assign) id <SCNavigationControllerDelegate> scNaigationDelegate;

@end



@protocol SCNavigationControllerDelegate <NSObject>
@optional
- (BOOL)willDismissNavigationController:(SCNavigationController*)navigatonController;

- (void)didTakePicture:(SCNavigationController*)navigationController image:(UIImage*)image;

@end