#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/CGLMacro.h>

#import "KinemeGLMultMatrixPatch.h"


@implementation KinemeGLMultMatrixPatch : QCPatch

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
		[input00 setDoubleValue:1.0];
		[input11 setDoubleValue:1.0];
		[input22 setDoubleValue:1.0];
		[input33 setDoubleValue:1.0];
		[[self userInfo] setObject:@"Kineme GL Matrix Mult" forKey:@"name"];
	}
	return self;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	CGLContextObj cgl_ctx = [context CGLContextObj];

	double m[16] =
	{
		[input00 doubleValue],
		[input01 doubleValue],
		[input02 doubleValue],
		[input03 doubleValue],

		[input10 doubleValue],
		[input11 doubleValue],
		[input12 doubleValue],
		[input13 doubleValue],

		[input20 doubleValue],
		[input21 doubleValue],
		[input22 doubleValue],
		[input23 doubleValue],

		[input30 doubleValue],
		[input31 doubleValue],
		[input32 doubleValue],
		[input33 doubleValue],
	};

	glPushMatrix();
	{
		if([inputTranspose booleanValue])
			glMultTransposeMatrixd(m);
		else
			glMultMatrixd(m);
		[self executeSubpatches:time arguments:arguments];
	}
	glPopMatrix();

	return YES;
}

@end
