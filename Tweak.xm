#import <Tweak.h>

%hook SBFolderView
- (void)pageControl:(id)arg1 didRecieveTouchInDirection:(int)arg2 {
	%orig;
	[self _prepareHideLabels];
}

- (void)scrollViewDidEndDragging:(id)arg1 willDecelerate:(_Bool)arg2 {
	%orig;
	[self _prepareHideLabels];
}

- (void)scrollViewWillBeginDragging:(id)arg1 {
	%orig;
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
}

%new
-(void)_showLabels {
	animateIconLabelAlpha(1);
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
	        [iconView setIconLabelAlpha: alpha];
	    }
    }];
}
