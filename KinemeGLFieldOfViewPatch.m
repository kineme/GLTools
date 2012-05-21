#import <OpenGL/gl.h>
#import <OpenGL/glu.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/CGLMacro.h>
#import <OpenGL/gluContext.h>

#import "KinemeGLFieldOfViewPatch.h"


@implementation KinemeGLFieldOfViewPatch : QCPatch

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
	self = [super initWithIdentifier:fp8];
	
	if(self)
	{
		// This is the default FOV, as stored in the default QC Model View Matrix
		[inputFieldOfView setDoubleValue: 90.0];
		[[self userInfo] setObject:@"Kineme GL Field of View" forKey:@"name"];
	}

	return self;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	CGLContextObj cgl_ctx = [context CGLContextObj];
	float fovy = [inputFieldOfView doubleValue];
	GLint viewPort[4];
	
	glGetIntegerv(GL_VIEWPORT, viewPort);
	
	float aspect = (float)viewPort[2]/(float)viewPort[3];
	
	if(fovy < 0.5f)
		fovy = 0.5f;
	if(fovy > 180.f)
		fovy = 180.f;
		
	float f = 1.0f / tanf(fovy * (float)M_PI / 360.0f);
	
	// populated according to gluPerspective specs where f (fovy) is used
	// see http://pyopengl.sourceforge.net/documentation/manual/gluPerspective.3G.html
	float fovMatrix[16];
	glGetFloatv(GL_PROJECTION_MATRIX, fovMatrix);
	
	bzero(fovMatrix, sizeof(float)*16);
	fovMatrix[ 0] = f / aspect;
	fovMatrix[ 5] = f;
	fovMatrix[10] = 1;	// normally there's some other aspect/left/right-top/bottom-near/far clip malarkey here --
	fovMatrix[15] = 1;	// we don't deal with that though (because the present projection has it built-in already)

	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glMultMatrixf(fovMatrix);
	{
		glMatrixMode(GL_MODELVIEW);
		[self executeSubpatches:time arguments:arguments];
	}
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();
	glMatrixMode(GL_MODELVIEW);

	return YES;
}

@end
