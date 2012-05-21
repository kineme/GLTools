#import <OpenGL/CGLMacro.h>
#import "KinemeGLFrustumPatch.h"


@implementation KinemeGLFrustumPatch : QCPatch

+ (QCPatchExecutionMode)executionModeWithIdentifier:(id)fp8
{
	return 1;
}

+ (BOOL)allowsSubpatchesWithIdentifier:(id)fp8
{
	return YES;
}

+ (BOOL)isSafe
{
	return YES;
}

- (id)initWithIdentifier:(id)fp8
{
	self=[super initWithIdentifier:fp8];
	if(self)
	{
		[inputLeft setDoubleValue:-1.];
		[inputRight setDoubleValue:+1.];
		[inputBottom setDoubleValue:-3./4];
		[inputTop setDoubleValue:+3./4];
		[inputNear setDoubleValue:0.1];
		[inputNear setMinDoubleValue:0.0];
		[inputFar setDoubleValue:10];
		[inputFar setMinDoubleValue:0.0];
		[[self userInfo] setObject:@"Kineme GL Frustum" forKey:@"name"];
	}

	return self;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	if([inputBypass booleanValue])
	{
		[self executeSubpatches:time arguments:arguments];
		return YES;
	}

	CGLContextObj cgl_ctx = [context CGLContextObj];
		
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	{
		glLoadIdentity();
		glFrustum([inputLeft doubleValue],[inputRight doubleValue],
				[inputBottom doubleValue], [inputTop doubleValue],
				[inputNear doubleValue], [inputFar doubleValue]);
//		glTranslatef([inputTX doubleValue], [inputTY doubleValue], [inputTZ doubleValue]);
  		glMatrixMode(GL_MODELVIEW);
		[self executeSubpatches:time arguments:arguments];
	}
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();
	glMatrixMode(GL_MODELVIEW);

	return YES;
}

@end
