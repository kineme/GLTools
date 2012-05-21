#import <OpenGL/CGLMacro.h>
#import "KinemeGLDepthBufferAlphaThresholdPatch.h"

@implementation KinemeGLDepthBufferAlphaThresholdPatch : QCPatch

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
		[inputThreshold setMinDoubleValue:0.0];
		[inputThreshold setMaxDoubleValue:1.0];
		[[self userInfo] setObject:@"Kineme GL Depth Buffer Alpha Threshold" forKey:@"name"];
	}

	return self;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	GLfloat oldThreshold;
	GLint   oldFunction;
	GLboolean alphaTestEnabled;
	
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	glGetFloatv(GL_ALPHA_TEST_REF,&oldThreshold);
	glGetIntegerv(GL_ALPHA_TEST_FUNC, &oldFunction);
	
	glAlphaFunc(GL_GREATER, [inputThreshold doubleValue]);
	alphaTestEnabled = glIsEnabled(GL_ALPHA_TEST);
	if(!alphaTestEnabled)
		glEnable(GL_ALPHA_TEST);
	
	[self executeSubpatches:time arguments:arguments];

	if(!alphaTestEnabled)
		glDisable(GL_ALPHA_TEST);
	glAlphaFunc(oldFunction, oldThreshold);

	return YES;
}

@end
