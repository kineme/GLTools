#import "KinemeGLCameraPatch.h"
#import <OpenGL/CGLMacro.h>

@implementation KinemeGLCameraPatch : QCPatch

+ (QCPatchExecutionMode)executionModeWithIdentifier:(id)fp8
{
	return kQCPatchExecutionModeConsumer;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glLoadIdentity();

	glTranslated(0,0,1.5);	// rotate about camera center
	glRotated([inputRoll doubleValue] ,0,0,1);
	glRotated([inputPitch doubleValue],1,0,0);
	glRotated([inputYaw doubleValue]  ,0,1,0);
	glTranslated(-[inputXPosition doubleValue], -[inputYPosition doubleValue], -[inputZPosition doubleValue]);
	
	[self executeSubpatches:time arguments:arguments];
	
	glPopMatrix();
	
	return YES;
}

@end
