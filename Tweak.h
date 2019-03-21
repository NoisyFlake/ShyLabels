#import <SpringBoard/SBFolderView.h>
#import <SpringBoard/SBIconController.h>
#import <SpringBoard/SBIconViewMap.h>

@interface SBIconView : UIPageControl
-(void)setIconLabelAlpha:(double)arg1 ;
@end

@interface SBFolderView (ShyPageDots)
-(void)_prepareHideLabels;
-(void)_hideLabels;
-(void)_showLabels;
@end

static void animateIconLabelAlpha(double alpha);
