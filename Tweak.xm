#import <Tweak.h>

BOOL isDragging = NO;
BOOL isUsingCozyBadges = NO;
BOOL wasPressed = NO;
BOOL alreadyProcessing = NO;

NSDictionary *prefs;
BOOL enabled;
double delay;

%hook SBFolderView
-(void)pageControl:(id)arg1 didRecieveTouchInDirection:(int)arg2 {
	%log;
	%orig;
	[self _shyLabelsPrepareHideLabels];
}

-(void)scrollViewDidEndDragging:(id)arg1 willDecelerate:(_Bool)arg2 {
	%log;
	%orig;
	[self _shyLabelsPrepareHideLabels];
}

-(void)scrollViewWillBeginDragging:(id)arg1 {
	%log;
	%orig;
	isDragging = YES;
	[self _shyLabelsAnimate:1];
}

-(void)layoutSubviews {
	%orig;
	if (delay >= 2.0) {
		[self _shyLabelsPrepareHideLabels];
	} else {
		[self _shyLabelsHideLabels];
	}
}

%new
-(void)_shyLabelsPrepareHideLabels {
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_shyLabelsHideLabels) object:nil];
	[self performSelector:@selector(_shyLabelsHideLabels) withObject:nil afterDelay:delay];
}

%new
-(void)_shyLabelsHideLabels {
	[self _shyLabelsAnimate:0];
	isDragging = NO;
}

%new
-(void)_shyLabelsAnimate:(int)alpha {
	if(delay == 0) {
		return;
	}
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
-(void)layoutSubviews {
	%orig;
	
	if (isUsingCozyBadges && !isDragging) {
		SBIconController *controller = [%c(SBIconController) sharedInstance];
		SBRootFolderController *rootFolderController = [controller _rootFolderController];
		SBIconListView *rootView = [[rootFolderController rootFolderView] currentIconListView];

		NSArray *icons = [rootView icons];
		SBIcon *icon = [self icon];

		if (![icons containsObject:icon]) return;

		[self _applyIconLabelAlpha:![icon badgeValue]];
	} else if (!isDragging && wasPressed) {
		[self _applyIconLabelAlpha:0];
		wasPressed = NO;
	}
}

-(void)setLabelHidden:(BOOL)arg1 {
	if(delay == 0) {
		arg1 = TRUE;
	}
	%orig(arg1);
}

-(void)_applyIconLabelAlpha:(double)arg1 {
	if(arg1 == 1 && wasPressed) {
		arg1 = 0;
		wasPressed = NO;
	}
	%orig(arg1);
}

-(void)contextMenuInteraction:(id)arg1 willEndForConfiguration:(id)arg2 animator:(id)arg3  { 
	%log; 
	%orig; 
	[self _applyIconLabelAlpha:0];
	wasPressed = YES; 
}


-(void)setContextMenuInteractionActive:(BOOL)arg1  { 
	%log;
	%orig;
	[self _applyIconLabelAlpha:0];
	wasPressed = YES; 
}

-(void)dismissContextMenuWithCompletion:(id)arg1  {
	%log; 
	%orig;
	[self _applyIconLabelAlpha:0];
	wasPressed = YES;  
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
