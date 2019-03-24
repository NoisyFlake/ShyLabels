#import <Tweak.h>

BOOL isDragging = NO;
BOOL hasFullyLoaded = NO;
BOOL isUsingGoodges = NO;

%hook SBFolderView
-(void)pageControl:(id)arg1 didRecieveTouchInDirection:(int)arg2 {
	%orig;
	[self _prepareHideLabels];
}

-(void)scrollViewDidEndDragging:(id)arg1 willDecelerate:(_Bool)arg2 {
	%orig;
	[self _prepareHideLabels];
}

-(void)scrollViewWillBeginDragging:(id)arg1 {
	%orig;
	isDragging = YES;
	[self _showLabels];
}

-(void)layoutSubviews {
	%orig;
	[self _hideLabels];
}

%new
-(void)_prepareHideLabels {
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_hideLabels) object:nil];
	[self performSelector:@selector(_hideLabels) withObject:nil afterDelay:1.0];
}

%new
-(void)_hideLabels {
	animateIconLabelAlpha(0);
	isDragging = NO;
}

%new
-(void)_showLabels {
	animateIconLabelAlpha(1);
}
%end

%hook SBIconView
-(void)layoutSubviews {
	%orig;

	// If we are using Goodges, we have to update the visibility whenever the badgeValue changes
	if (hasFullyLoaded && isUsingGoodges && !isDragging) {
		SBIconController *controller = [%c(SBIconController) sharedInstance];
		SBRootIconListView *rootView = [controller currentRootIconList];

		NSArray *icons = [rootView icons];
		SBIcon *icon = [self icon];

		// Update only the icon page thats currently visible
		if (![icons containsObject:icon]) return;

		int badgeValue = (int)[icon badgeValue];

		if (badgeValue < 1) {
			[self setIconLabelAlpha: 0];
		} else {
			[self setIconLabelAlpha: 1];
		}
	}
}
%end

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application {
    %orig;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void) {
        hasFullyLoaded = YES;
    });
}
%end

static void animateIconLabelAlpha(double alpha) {
	SBIconController *controller = [%c(SBIconController) sharedInstance];
	SBRootIconListView *rootView = [controller currentRootIconList];

	NSArray *icons = [rootView icons];
	SBIconViewMap* map = [rootView viewMap];

	[UIView animateWithDuration:0.5 animations:^{
		for(SBIcon *icon in icons) {
			SBIconView *iconView = [map mappedIconViewForIcon:icon];

			int badgeValue = (int)[icon badgeValue];
			if (!isUsingGoodges || badgeValue < 1) {
				[iconView setIconLabelAlpha: alpha];
			} else {
				[iconView setIconLabelAlpha: 1];
			}
		}
	}];
}

%ctor {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *goodgesDylib = @"/Library/MobileSubstrate/DynamicLibraries/Goodges.dylib";
	isUsingGoodges = [fileManager fileExistsAtPath:goodgesDylib];
}
