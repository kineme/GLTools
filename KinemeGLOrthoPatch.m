#import <OpenGL/CGLMacro.h>
#import "KinemeGLOrthoPatch.h"


@implementation KinemeGLOrthoPatch : QCPatch

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
		[inputNear setDoubleValue:-10];
		[inputFar setDoubleValue:200.];
		[[self userInfo] setObject:@"Kineme GL Ortho" forKey:@"name"];
	}

	return self;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
//	double modifiedMatrix[16],t1,t2,t3;
	
	if([inputBypass booleanValue])
	{
		[self executeSubpatches:time arguments:arguments];
		return YES;
	}

	CGLContextObj cgl_ctx = [context CGLContextObj];
		
	/*for(i=1;i<15;++i)
		modifiedMatrix[i] = 0.0;//oldMatrix[i];
	
	// @@@ The math is right ...  the output is wrong though.  need to investigate more.
	
	t1 = ([inputRight doubleValue] + [inputLeft   doubleValue]) / ([inputRight doubleValue] - [inputLeft   doubleValue]);
	t2 = ([inputTop   doubleValue] + [inputBottom doubleValue]) / ([inputTop   doubleValue] - [inputBottom doubleValue]);
	t3 = ([inputFar   doubleValue] + [inputNear   doubleValue]) / ([inputFar   doubleValue] - [inputNear   doubleValue]);
	modifiedMatrix[ 0] = 2. / ([inputRight doubleValue] - [inputLeft doubleValue]);
	modifiedMatrix[ 3] = t1;
	modifiedMatrix[ 5] = 2. / ([inputTop doubleValue] - [inputBottom doubleValue]);
	modifiedMatrix[ 7] = t2;
	modifiedMatrix[10] = 2. / ([inputFar doubleValue] - [inputNear doubleValue]);
	modifiedMatrix[11] = t3;
	modifiedMatrix[15] = 1.0;*/

	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	{
		glLoadIdentity();
		glOrtho([inputLeft doubleValue],[inputRight doubleValue],
				[inputBottom doubleValue], [inputTop doubleValue],
				[inputNear doubleValue], [inputFar doubleValue]);
		//glLoadMatrixd(modifiedMatrix);
	
		glMatrixMode(GL_MODELVIEW);
		[self executeSubpatches:time arguments:arguments];
	}
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();
	glMatrixMode(GL_MODELVIEW);

	return YES;
}

@end
