#import <substrate.h>

@interface CAMCaptureController
- (int)cameraMode;
@end

@interface CAMCameraView
- (int)cameraMode;
@end

@interface CAMTopBar
- (NSMutableArray *)_allowedControlsForVideoMode;
@end

BOOL hook = NO;

%hook CAMCaptureController

+ (BOOL)isVideoMode:(int)mode
{
	return hook && mode == 6 ? YES : %orig;
}

- (BOOL)isTorchOn
{
	int origMode = MSHookIvar<int>(self, "_cameraMode");
	if (origMode == 6) {
		MSHookIvar<int>(self, "_cameraMode") = 1;
		BOOL orig = %orig;
		MSHookIvar<int>(self, "_cameraMode") = 6;
		return orig;
	}
	return %orig;
}

- (BOOL)isTorchActive
{
	int origMode = MSHookIvar<int>(self, "_cameraMode");
	if (origMode == 6) {
		hook = YES;
		MSHookIvar<int>(self, "_cameraMode") = 1;
		BOOL orig = %orig;
		MSHookIvar<int>(self, "_cameraMode") = 6;
		hook = NO;
		return orig;
	}
	return %orig;
}

- (void)_setFlashMode:(int)mode force:(BOOL)force
{
	int origMode = MSHookIvar<int>(self, "_cameraMode");
	if (origMode == 6) {
		MSHookIvar<int>(self, "_cameraMode") = 1;
		%orig;
		MSHookIvar<int>(self, "_cameraMode") = 6;
		return;
	}
	%orig;
}

- (void)_applyTorchSettingsFromVideoRequest:(id)request
{
	int origMode = MSHookIvar<int>(self, "_cameraMode");
	if (origMode == 6) {
		MSHookIvar<int>(self, "_cameraMode") = 1;
		%orig;
		MSHookIvar<int>(self, "_cameraMode") = 6;
		return;
	}
	%orig;
}

%end

%hook CAMCameraView

- (BOOL)_shouldHideElapsedTimeViewForMode:(int)mode
{
	return %orig(mode == 6 ? 1 : mode);
}

- (BOOL)_shouldHideFlashButtonForMode:(int)mode
{
	return %orig(mode == 6 ? 1 : mode);
}

- (BOOL)_shouldHideFlashBadgeForMode:(int)mode
{
	return %orig(mode == 6 ? 1 : mode);
}

- (int)_currentFlashMode
{
	CAMCaptureController *cont = MSHookIvar<CAMCaptureController *>(self, "_cameraController");
	int origMode = MSHookIvar<int>(cont, "_cameraMode");
	if (origMode == 6) {
		MSHookIvar<int>(cont, "_cameraMode") = 1;
		int orig = %orig;
		MSHookIvar<int>(cont, "_cameraMode") = 6;
		return orig;
	}
	return %orig;
}

/*- (BOOL)_shouldApplyRotationDirectlyToTopBarForOrientation:(int)orientation cameraMode:(int)mode
{
	return mode == 6 ? YES : %orig;
}

- (void)_updateTopBarStyleForDeviceOrientation:(int)orientation
{
	hook = YES;
	%orig;
	hook = NO;
}*/

- (void)embedControlsIntoNavigationItem:(id)arg1 animated:(BOOL)animated
{
	hook = YES;
	%orig;
	hook = NO;
}

- (void)_setFlashMode:(int)mode
{
	CAMCaptureController *cont = MSHookIvar<CAMCaptureController *>(self, "_cameraController");
	int origMode = MSHookIvar<int>(cont, "_cameraMode");
	if (origMode == 6) {
		MSHookIvar<int>(cont, "_cameraMode") = 1;
		%orig;
		MSHookIvar<int>(cont, "_cameraMode") = 6;
		return;
	}
	%orig;
}

%end

%hook CAMTopBar

- (NSMutableArray *)_allowedControlsForTimelapseMode
{
	return [self _allowedControlsForVideoMode];
}

%end

%hook CAMApplicationViewController

- (BOOL)_shouldResumeTorch
{
	CAMCameraView *view = MSHookIvar<CAMCameraView *>(self, "_cameraView");
	CAMCaptureController *cont = MSHookIvar<CAMCaptureController *>(view, "_cameraController");
	hook = MSHookIvar<int>(cont, "_cameraMode") == 6;
	BOOL orig = %orig;
	hook = NO;
	return orig;
}

%end
