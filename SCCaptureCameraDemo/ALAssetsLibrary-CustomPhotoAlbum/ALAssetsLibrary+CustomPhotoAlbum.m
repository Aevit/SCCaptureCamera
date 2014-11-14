//
//  ALAssetsLibrary category to handle a custom photo album
//
//  Created by Marin Todorov on 10/26/11.
//  Copyright (c) 2011 Marin Todorov. All rights reserved.
//

#import "ALAssetsLibrary+CustomPhotoAlbum.h"

#if !__has_feature(objc_arc)
#error This class requires automatic reference counting (ARC).
#endif

@interface ALAssetsLibrary (Private)

/*! A block wraper to be executed after asset adding process done. (Private)
 *
 * \param albumName Custom album name
 * \param completion Block to be executed when succeed to add the asset to the assets library (camera roll)
 * \param failure Block to be executed when failed to add the asset to the custom photo album
 */
- (ALAssetsLibraryWriteImageCompletionBlock)_resultBlockOfAddingToAlbum:(NSString *)albumName
                                                             completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
                                                                failure:(ALAssetsLibraryAccessFailureBlock)failure;

/*! A block wraper to be executed after |-assetForURL:resultBlock:failureBlock:| succeed.
 *  Generally, this block will be excused when user confirmed the application's access
 *    to the library.
 *
 * \param group A group to be used to add photo to the target album
 * \param assetURL The URL for the target asset
 * \param completion Block to be executed when succeed to add the asset to the assets library (camera roll)
 * \param failure Block to be executed when failed to add the asset to the custom photo album
 *
 * \return An ALAssetsLibraryAssetForURLResultBlock type block
 */
- (ALAssetsLibraryAssetForURLResultBlock)_assetForURLResultBlockWithGroup:(ALAssetsGroup *)group
                                                                 assetURL:(NSURL *)assetURL
                                                               completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
                                                                  failure:(ALAssetsLibraryAccessFailureBlock)failure;

@end


@implementation ALAssetsLibrary (CustomPhotoAlbum)

#pragma mark - Private Method

- (ALAssetsLibraryWriteImageCompletionBlock)_resultBlockOfAddingToAlbum:(NSString *)albumName
                                                             completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
                                                                failure:(ALAssetsLibraryAccessFailureBlock)failure
{
  return ^(NSURL *assetURL, NSError *error) {
    // Run the completion block for writing image to saved
    //   photos album
    //if (completion) completion(assetURL, error);
    
    // If an error occured, do not try to add the asset to
    //   the custom photo album
    if (error != nil) {
      if (failure) failure(error);
      return;
    }
    
    // Add the asset to the custom photo album
    [self addAssetURL:assetURL
              toAlbum:albumName
           completion:completion
              failure:failure];
  };
}

- (ALAssetsLibraryAssetForURLResultBlock)_assetForURLResultBlockWithGroup:(ALAssetsGroup *)group
                                                                 assetURL:(NSURL *)assetURL
                                                               completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
                                                                  failure:(ALAssetsLibraryAccessFailureBlock)failure
{
  return ^(ALAsset *asset) {
    // Add photo to the target album
    if ([group addAsset:asset]) {
      // Run the completion block if the asset was added successfully
      if (completion) completion(assetURL, nil);
    }
    // |-addAsset:| may fail (return NO) if the group is not editable,
    //   or if the asset could not be added to the group.
    else {
      NSString * message = [NSString stringWithFormat:@"ALAssetsGroup failed to add asset: %@.", asset];
      failure([NSError errorWithDomain:@"LIB_ALAssetsLibrary_CustomPhotoAlbum"
                                  code:0
                              userInfo:@{NSLocalizedDescriptionKey : message}]);
    }
  };
}

#pragma mark - Public Method

- (void)saveImage:(UIImage *)image
          toAlbum:(NSString *)albumName
       completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
          failure:(ALAssetsLibraryAccessFailureBlock)failure
{
  [self writeImageToSavedPhotosAlbum:image.CGImage
                         orientation:(ALAssetOrientation)image.imageOrientation 
                     completionBlock:[self _resultBlockOfAddingToAlbum:albumName
                                                            completion:completion
                                                               failure:failure]];
}

- (void)saveVideo:(NSURL *)videoUrl
          toAlbum:(NSString *)albumName
       completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
          failure:(ALAssetsLibraryAccessFailureBlock)failure
{
    [self writeVideoAtPathToSavedPhotosAlbum:videoUrl
                             completionBlock:[self _resultBlockOfAddingToAlbum:albumName
                                                                    completion:completion
                                                                       failure:failure]];
}

- (void)saveImageData:(NSData *)imageData
              toAlbum:(NSString *)albumName
             metadata:(NSDictionary *)metadata
           completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
              failure:(ALAssetsLibraryAccessFailureBlock)failure
{
  [self writeImageDataToSavedPhotosAlbum:imageData
                                metadata:metadata
                         completionBlock:[self _resultBlockOfAddingToAlbum:albumName
                                                                completion:completion
                                                                   failure:failure]];
}

- (void)addAssetURL:(NSURL *)assetURL
            toAlbum:(NSString *)albumName
         completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
            failure:(ALAssetsLibraryAccessFailureBlock)failure
{
  __block BOOL albumWasFound = NO;
  
  // Signature for the block executed when a match is found during enumeration using
  //   |-enumerateGroupsWithTypes:usingBlock:failureBlock:|.
  //
  // |group|: The current asset group in the enumeration.
  // |stop| : A pointer to a boolean value; set the value to YES to stop enumeration.
  //
  ALAssetsLibraryGroupsEnumerationResultsBlock enumerationBlock;
  enumerationBlock = ^(ALAssetsGroup *group, BOOL *stop) {
    // Compare the names of the albums
    if ([albumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
      // Target album is found
      albumWasFound = YES;
      
      // Get a hold of the photo's asset instance
      // If the user denies access to the application, or if no application is allowed to
      //   access the data, the failure block is called.
      ALAssetsLibraryAssetForURLResultBlock assetForURLResultBlock =
        [self _assetForURLResultBlockWithGroup:group
                                      assetURL:assetURL
                                    completion:completion
                                       failure:failure];
      [self assetForURL:assetURL
            resultBlock:assetForURLResultBlock
           failureBlock:failure];
      
      // Album was found, bail out of the method
      *stop = YES;
    }
    
    if (group == nil && albumWasFound == NO) {
      // Photo albums are over, target album does not exist, thus create it
      
      // Since you use the assets library inside the block,
      //   ARC will complain on compile time that there’s a retain cycle.
      //   When you have this – you just make a weak copy of your object.
      ALAssetsLibrary * __weak weakSelf = self;
      
      void(^addPhotoToLibraryBlock)(ALAssetsGroup *group) = ^void(ALAssetsGroup *group) {
        // Get the photo's instance
        //   add the photo to the newly created album
        ALAssetsLibraryAssetForURLResultBlock assetForURLResultBlock =
        [weakSelf _assetForURLResultBlockWithGroup:group
                                          assetURL:assetURL
                                        completion:completion
                                           failure:failure];
        [weakSelf assetForURL:assetURL
                  resultBlock:assetForURLResultBlock
                 failureBlock:failure];
      };
      
      // If iOS version is lower than 5.0, throw a warning message
      if (! [self respondsToSelector:@selector(addAssetsGroupAlbumWithName:resultBlock:failureBlock:)])
        NSLog(@"![WARNING][LIB:ALAssetsLibrary+CustomPhotoAlbum]: \
              |-addAssetsGroupAlbumWithName:resultBlock:failureBlock:| \
              only available on iOS 5.0 or later. \
              ASSET cannot be saved to album!");
      // Create new assets album
      else {
        // Different code for iOS 7 and 8
        // See: http://stackoverflow.com/questions/26003211/assetslibrary-framework-broken-on-ios-8
        // See: http://stackoverflow.com/questions/8867496/get-last-image-from-photos-app/8872425#8872425
        // PHPhotoLibrary_class will only be non-nil on iOS 8.x.
        Class PHPhotoLibrary_class = NSClassFromString(@"PHPhotoLibrary");
        
        if (PHPhotoLibrary_class) {
          /**
           *
           iOS 8.x. . code that has to be called dynamically at runtime and will not link on iOS 7.x.
           
          [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title];
          } completionHandler:^(BOOL success, NSError *error) {
            if (!success) {
              NSLog(@"Error creating album: %@", error);
            }
          }];
           
          */
          
          // dynamic runtime code for code chunk listed above
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
          id sharedPhotoLibrary = [PHPhotoLibrary_class performSelector:NSSelectorFromString(@"sharedPhotoLibrary")];
#pragma clang diagnostic pop
          
          SEL performChanges = NSSelectorFromString(@"performChanges:completionHandler:");
          
          NSMethodSignature *methodSig = [sharedPhotoLibrary methodSignatureForSelector:performChanges];
          
          NSInvocation* inv = [NSInvocation invocationWithMethodSignature:methodSig];
          [inv setTarget:sharedPhotoLibrary];
          [inv setSelector:performChanges];
          
          void(^firstBlock)() = ^void() {
            Class PHAssetCollectionChangeRequest_class = NSClassFromString(@"PHAssetCollectionChangeRequest");
            SEL creationRequestForAssetCollectionWithTitle = NSSelectorFromString(@"creationRequestForAssetCollectionWithTitle:");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [PHAssetCollectionChangeRequest_class performSelector:creationRequestForAssetCollectionWithTitle withObject:albumName];
#pragma clang diagnostic pop
          };
          
          void (^secondBlock)(BOOL success, NSError *error) = ^void(BOOL success, NSError *error) {
            if (success) {
              [self enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if (group) {
                  NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
                  if ([albumName isEqualToString:name]) {
                    addPhotoToLibraryBlock(group);
                  }
                }
              } failureBlock:failure];
            }
            
            if (error) {
              NSLog(@"Error creating album: %@", error);
            }
          };
          
          // Set the first and second blocks.
          [inv setArgument:&firstBlock atIndex:2];
          [inv setArgument:&secondBlock atIndex:3];
          
          [inv invoke];
          
        }
        else {
          // code that always creates an album on iOS 7.x.x but fails
          // in certain situations such as if album has been deleted
          // previously on iOS 8.x.
          [self addAssetsGroupAlbumWithName:albumName
                                resultBlock:addPhotoToLibraryBlock
                               failureBlock:failure];
        }
      }
      // Should be the last iteration anyway, but just in case
      *stop = YES;
    }
  };
  
  // Search all photo albums in the library
  [self enumerateGroupsWithTypes:ALAssetsGroupAlbum
                      usingBlock:enumerationBlock
                    failureBlock:failure];
}

- (void)loadImagesFromAlbum:(NSString *)albumName
                 completion:(void (^)(NSMutableArray *, NSError *))completion
{
  ALAssetsLibraryGroupsEnumerationResultsBlock block = ^(ALAssetsGroup *group, BOOL *stop) {
    // Checking if library exists
    if (group == nil) *stop = YES;
    
    // If we have found library with given title we enumerate it
    if ([albumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
      NSMutableArray * images = [[NSMutableArray alloc] init];
      [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        // Checking if group isn't empty
        if (! result) return;
        
        // Getting the image from the asset
        UIImageOrientation orientation =
          (UIImageOrientation)[[result valueForProperty:@"ALAssetPropertyOrientation"] intValue];
        UIImage * image = [UIImage imageWithCGImage:[[result defaultRepresentation] fullScreenImage]
                                              scale:1.0
                                        orientation:orientation];
        // Saving this image to the array
        [images addObject:image];
      }];
      
      // Execute the |completion| block
      if (completion) completion(images, nil);
      
      // Album was found, bail out of the method
      *stop = YES;
    }
  };
  
  ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
    if (completion) completion(nil, error);
  };
  
  [self enumerateGroupsWithTypes:ALAssetsGroupAll
                      usingBlock:block
                    failureBlock:failureBlock];
}

@end
