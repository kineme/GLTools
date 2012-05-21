#import "UnitTests.h"
#import "KinemeGLStereoEnvironmentPatch.h"
#import "KinemeGLPointPatch.h"


@implementation UnitTests
- (void) setUp
{
//	context = [[QCOpenGLContext alloc] initWithOptions:nil contextAttributes:0];
}
- (void) tearDown
{
//	[context release];
}



// ============================================================================

-(void)testStereoEnvironment
{
	QCRenderer *r = [[QCRenderer alloc] initWithComposition:[QCComposition compositionWithFile:@"tests/GLStereo2pix.qtz"] colorSpace:CGColorSpaceCreateWithName(kCGColorSpaceGenericRGBLinear)];
	STAssertNotNil(r,@"r");

	STAssertTrue([r renderAtTime:0 arguments:nil],@"render");

	{
		STAssertNotNil([r valueForOutputKey:@"Left_Image"],@"Left Image");
		NSBitmapImageRep *img = [[[r valueForOutputKey:@"Left_Image"] representations] objectAtIndex:0];
		STAssertTrue([[img colorAtX:0 y:0] brightnessComponent] > 0.9, @"In the left image, the point should be on the left.");
		STAssertTrue([[img colorAtX:1 y:0] brightnessComponent] < 0.1, @"In the left image, the point shouldn't be on the right.");
	}

	{
		STAssertNotNil([r valueForOutputKey:@"Right_Image"],@"Right Image");
		NSBitmapImageRep *img = [[[r valueForOutputKey:@"Right_Image"] representations] objectAtIndex:0];
		STAssertTrue([[img colorAtX:0 y:0] brightnessComponent] < 0.1, @"In the right image, the point shouldn't be on the left.");
		STAssertTrue([[img colorAtX:1 y:0] brightnessComponent] > 0.9, @"In the right image, the point should be on the right.");
	}

	[r release];
}

@end
