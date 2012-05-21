#import <OpenGL/CGLMacro.h>
#import "KinemeGLLightingBypassPatch.h"

@implementation KinemeGLLightingBypassPatch : QCPatch

+ (QCPatchExecutionMode)executionModeWithIdentifier:(id)fp8
{
	return kQCPatchExecutionModeConsumer;
}

+ (BOOL)isSafe
{
	return YES;
}

- (id)initWithIdentifier:(id)fp8
{
	if(self=[super initWithIdentifier:fp8])
	{
		[inputLightingBypass setBooleanValue:YES];
		[[self userInfo] setObject:@"Kineme GL Lighting Bypass" forKey:@"name"];
	}
	
	return self;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	GLboolean mode, oldMode;
	
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	mode = ![inputLightingBypass booleanValue];
	oldMode = glIsEnabled(GL_LIGHTING);
	if(oldMode != mode)
	{
		if(mode)
			glEnable(GL_LIGHTING);
		else
			glDisable(GL_LIGHTING);
	}
	[self executeSubpatches:time arguments:arguments];
	if(oldMode != mode)
	{
		if(mode)
			glDisable(GL_LIGHTING);
		else
			glEnable(GL_LIGHTING);
	}
	
	return YES;
}

@end
