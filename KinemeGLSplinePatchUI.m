#import "KinemeGLSplinePatch.h"
#import "KinemeGLSplinePatchUI.h"

@implementation KinemeGLSplinePatchUI

/* This method returns the NIB file to use for the inspector panel */
+ (NSString *)viewNibName
{
    return @"KinemeGLSplinePatchUI";
}

/* This method specifies the title for the inspector window */
+ (NSString *)viewTitle
{
    return @"Spline Control";
}

- (IBAction)updateControlPoints:(id)sender
{
	if([[sender title] isEqual:@"+"] == TRUE)
		[(KinemeGLSplinePatch *)[self patch] addPoint];
	else if([[sender title] isEqual:@"-"] == TRUE)
		[(KinemeGLSplinePatch *)[self patch] removePoint];
}

@end