Pod::Spec.new do |s|
  s.name         = "SCCaptureCamera"
  s.version      = "0.1"
  s.homepage     = "https://github.com/LacieJiang/SCCaptureCamera"
  s.license      = "MIT"
  s.source       = { :git => "https://github.com/LacieJiang/SCCaptureCamera.git", :tag => "v0.1" }
  s.frameworks   = 'Foundation', 'CoreGraphics', 'UIKit'
  s.platform     = :ios, '5.0'
  s.source_files = 'SCCaptureCameraDemo/SCCaptureCamera/*.{h,m}', 'SCCaptureCameraDemo/SCCaptureCamera/images/SCCamera/*','SCCaptureCameraDemo/Vendor/**/*','SCCaptureCameraDemo/SCCommon/*','SCCaptureCameraDemo/ALAssetsLibrary-CustomPhotoAlbum/*'
  s.requires_arc = true
end
