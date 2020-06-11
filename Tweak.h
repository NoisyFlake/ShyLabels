#import <SpringBoard/SBFolderView.h>
#import <SpringBoard/SBIcon.h>
#import <SpringBoard/SBIconController.h>
#import <SpringBoard/SBIconView.h>
#import <SpringBoard/SBIconViewMap.h>
#import <SpringBoard/SBRootFolderView.h>
#import <SpringBoard/SBRootFolderController.h>

#define kIdentifier @"me.conorthedev.shylabels"
#define kSettingsChangedNotification (CFStringRef)@"me.conorthedev.shylabels/ReloadPrefs"
#define kSettingsPath @"/var/mobile/Library/Preferences/me.conorthedev.shylabels.plist"

@interface SBIconListView : UIView
- (id)icons;
@end

@interface SBFolderView (Private)
@property (nonatomic,readonly) SBIconListView *currentIconListView;
@end

@interface SBFolderView (ShyLabels)
- (void)_shyLabelsPrepareHideLabels;
- (void)_shyLabelsHideLabels;
- (void)_shyLabelsAnimate:(int)alpha;
@end

@interface SBIconView (Private)
@property (nonatomic, readonly) float iconLabelAlpha;
- (void)_applyIconLabelAlpha:(double)arg1;
- (void)setIconLabelAlpha:(double)arg1;
@end

@interface SBRootFolderView (Private)
- (SBIconListView *)currentIconListView;
@end

@interface SBRootFolderController (Private)
- (SBRootFolderView *)rootFolderView;
@end

@interface SBIconController (Private)
- (SBRootFolderController *)rootFolderController;
@end
