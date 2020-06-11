#import "ShyLabels.h"

BOOL isDragging = NO;
BOOL isUsingCozyBadges = NO;
BOOL overrideAlpha = NO;

NSDictionary *prefs;
BOOL enabled = YES;
BOOL enabledFolders = YES;
double delay = 2.0;

%hook SBFolderView
-(void)prepareToOpen {
	%orig;
	isDragging = YES;
	[self _shyLabelsAnimate:1];
}

-(void)prepareForTransition {
	%orig;
	[self _shyLabelsPrepareHideLabels];
}

-(void)pageControl:(id)arg1 didRecieveTouchInDirection:(int)arg2 {
	%orig;
	[self _shyLabelsPrepareHideLabels];
}

-(void)scrollViewWillEndDragging:(id)arg1 withVelocity:(id)arg2 targetContentOffset:(id)arg3 {
	%orig;
	[self _shyLabelsPrepareHideLabels];
}

-(void)scrollViewWillBeginDragging:(id)arg1 {
	%orig;
	isDragging = YES;
	[self _shyLabelsAnimate:1];
}

-(void)layoutSubviews {
	%orig;
	[self _shyLabelsPrepareHideLabels];
}

%new
-(void)_shyLabelsPrepareHideLabels {
	if([self isKindOfClass:%c(SBFloatyFolderView)] && !enabledFolders) return;

	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_shyLabelsHideLabels) object:nil];
	[self performSelector:@selector(_shyLabelsHideLabels) withObject:nil afterDelay:delay];
}

%new
-(void)_shyLabelsHideLabels {
	if([self isKindOfClass:%c(SBFloatyFolderView)] && !enabledFolders) return;

	[self _shyLabelsAnimate:0];
	isDragging = NO;
}

%new
-(void)_shyLabelsAnimate:(int)alpha {
	if([self isKindOfClass:%c(SBFloatyFolderView)] && !enabledFolders) return;

	SBIconListView *rootView = self.currentIconListView;
	[UIView animateWithDuration:0.5 animations:^{
		for(UIView *icon in rootView.subviews) {
			if ([icon isKindOfClass:%c(SBIconView)]) {
				SBIconView *iconView = (SBIconView*)icon;

				int badgeValue = (int)[iconView.icon badgeValue];
				if (!isUsingCozyBadges || badgeValue < 1) {
					[iconView _applyIconLabelAlpha:alpha];
				} else {
					[iconView _applyIconLabelAlpha:1];
				}
			}
		}
	}];
}
%end

%hook SBIconView
/*
 * If delay is 0, permanently hide the labels
 */
-(void)setLabelHidden:(BOOL)arg1 {
	%orig(!delay ? TRUE : arg1);
}

/* 
 * Explanation of the following 2 functions:
 * effectiveIconLabelAlpha is called before _applyIconLabelAlpha, by setting the overrideAlpha BOOL, we can stop iOS trying to change our alpha
 * This is used for when the context menu is invoked, the label is forced to show from a method call that originates from setContextMenuInteractionActive:
 */
-(double)effectiveIconLabelAlpha {
	overrideAlpha = !isDragging;
	return %orig;
}

-(void)_applyIconLabelAlpha:(double)arg1 {
	%orig(overrideAlpha ? 0 : arg1);
	overrideAlpha = NO;
}

/*
 * Show CozyBadges if we recieve a new notification
 */
-(void)_updateAccessoryViewWithAnimation:(BOOL)arg1 {
	%orig;

	
	if (isUsingCozyBadges && !isDragging) {
		SBIconController *controller = [%c(SBIconController) sharedInstance];
		SBRootFolderController *rootFolderController = [controller _rootFolderController];
		SBIconListView *rootView = [[rootFolderController rootFolderView] currentIconListView];

		NSArray *icons = [rootView icons];
		SBIcon *icon = [self icon];

		if (![icons containsObject:icon]) return;

		[self _applyIconLabelAlpha:![icon badgeValue]];
	} 
}
%end

static void SLReloadPrefs() {
	CFPreferencesAppSynchronize((CFStringRef)kIdentifier);

    if ([NSHomeDirectory()isEqualToString:@"/var/mobile"]) {
        CFArrayRef keyList = CFPreferencesCopyKeyList((CFStringRef)kIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);

        if (keyList) {
            prefs = (NSDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, (CFStringRef)kIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost));

            if (!prefs) {
                prefs = [NSDictionary new];
            }
            CFRelease(keyList);
        }
    } else {
        prefs = [NSDictionary dictionaryWithContentsOfFile:kSettingsPath];
    }

	enabled = [prefs objectForKey:@"enabled"] ? [[prefs valueForKey:@"enabled"] boolValue] : YES;
	enabledFolders = [prefs objectForKey:@"enabledFolders"] ? [[prefs valueForKey:@"enabledFolders"] boolValue] : YES;
	delay = [prefs objectForKey:@"delay"] ? [[prefs valueForKey:@"delay"] doubleValue] : 1;
}

%ctor {	
	SLReloadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)SLReloadPrefs, CFSTR("me.conorthedev.shylabels/ReloadPrefs"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	
	isUsingCozyBadges = [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/CozyBadges.dylib"] || [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Goodges.dylib"];
	if(enabled) {
		%init;
	}
}
