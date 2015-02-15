#import "../PS.h"

/*CFStringRef const PreferencesNotification = CFSTR("com.PS.MyLapse.prefs");
NSString *const PREF_PATH = @"/var/mobile/Library/Preferences/com.PS.MyLapse.plist";

BOOL allowTorch;
BOOL allowElapsed;*/

//BOOL hook = NO;

%hook CAMCaptureController

+ (BOOL)isVideoMode:(NSInteger)mode
{
	return mode == 6 ? YES : %orig;
}

- (BOOL)isTorchOn
{
	NSInteger origMode = MSHookIvar<NSInteger>(self, "_cameraMode");
	if (origMode == 6) {
		MSHookIvar<NSInteger>(self, "_cameraMode") = 1;
		BOOL orig = %orig;
		MSHookIvar<NSInteger>(self, "_cameraMode") = 6;
		return orig;
	}
	return %orig;
}

- (void)_setFlashMode:(NSInteger)mode force:(BOOL)force
{
	NSInteger origMode = MSHookIvar<NSInteger>(self, "_cameraMode");
	if (origMode == 6) {
		MSHookIvar<NSInteger>(self, "_cameraMode") = 1;
		%orig;
		MSHookIvar<NSInteger>(self, "_cameraMode") = 6;
		return;
	}
	%orig;
}

%end

%hook CAMCameraView

- (BOOL)_shouldHideFlashButtonForMode:(NSInteger)mode
{
	return %orig(mode == 6 ? 1 : mode);
}

- (BOOL)_shouldHideFlashBadgeForMode:(NSInteger)mode
{
	return %orig(mode == 6 ? 1 : mode);
}

- (NSInteger)_currentFlashMode
{
	CAMCaptureController *cont = MSHookIvar<CAMCaptureController *>(self, "_cameraController");
	NSInteger origMode = MSHookIvar<NSInteger>(cont, "_cameraMode");
	if (origMode == 6) {
		MSHookIvar<NSInteger>(cont, "_cameraMode") = 1;
		NSInteger orig = %orig;
		MSHookIvar<NSInteger>(cont, "_cameraMode") = 6;
		return orig;
	}
	return %orig;
}

- (void)_setFlashMode:(NSInteger)mode
{
	CAMCaptureController *cont = MSHookIvar<CAMCaptureController *>(self, "_cameraController");
	NSInteger origMode = MSHookIvar<NSInteger>(cont, "_cameraMode");
	if (origMode == 6) {
		MSHookIvar<NSInteger>(cont, "_cameraMode") = 1;
		%orig;
		MSHookIvar<NSInteger>(cont, "_cameraMode") = 6;
		return;
	}
	%orig;
}

- (void)_showControlsForCapturingTimelapseAnimated:(BOOL)animated
{
	%orig;
	CAMElapsedTimeView *elapsedTimeView = [self._elapsedTimeView retain];
	[elapsedTimeView startTimer];
	[elapsedTimeView release];
}

- (void)_hideControlsForCapturingTimelapseAnimated:(BOOL)animated
{
	%orig;
	CAMElapsedTimeView *elapsedTimeView = [self._elapsedTimeView retain];
	[elapsedTimeView endTimer];
	[elapsedTimeView release];
}

%end

%hook CAMTopBar

- (NSMutableArray *)_allowedControlsForTimelapseMode
{
	return [self _allowedControlsForVideoMode];
}

%end

%ctor
{
	%init;
}
