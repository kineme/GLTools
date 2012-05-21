#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/CGLMacro.h>

#import "KinemeGLQuadPatch.h"


@implementation KinemeGLQuadPatch : QCPatch

+ (QCPatchExecutionMode)executionModeWithIdentifier:(id)fp8
{
	return 1;
}
+ (BOOL)allowsSubpatchesWithIdentifier:(id)fp8
{
	return NO;
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
		/* counterclockwise for backface culling */
		/* V is inverted because images are flipped */
		[inputX1 setDoubleValue: -0.5];
		[inputY1 setDoubleValue:  0.5];
		[inputU1 setDoubleValue:  0.0];
		[inputV1 setDoubleValue:  1.0];

		[inputX2 setDoubleValue: -0.5];
		[inputY2 setDoubleValue: -0.5];
		[inputU2 setDoubleValue:  0.0];
		[inputV2 setDoubleValue:  0.0];

		[inputX3 setDoubleValue:  0.5];
		[inputY3 setDoubleValue: -0.5];
		[inputU3 setDoubleValue:  1.0];
		[inputV3 setDoubleValue:  0.0];

		[inputX4 setDoubleValue:  0.5];
		[inputY4 setDoubleValue:  0.5];
		[inputU4 setDoubleValue:  1.0];
		[inputV4 setDoubleValue:  1.0];
		
		[inputColor1 setRed:0.7 green:0.4 blue:0.4 alpha:0.7];
		[inputColor2 setRed:0.4 green:0.7 blue:0.4 alpha:0.7];
		[inputColor3 setRed:0.4 green:0.4 blue:0.7 alpha:0.7];
		[inputColor4 setRed:0.9 green:0.9 blue:0.9 alpha:0.7];
		
		[inputDepth setIndexValue:1];	// set normal read/write depth testing
		[inputCulling setIndexValue:1];	// set normal backface culling by default
		[[self userInfo] setObject:@"Kineme GL Quad" forKey:@"name"];

	}
	return self;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	CGFloat red1,green1,blue1,alpha1;
	CGFloat red2,green2,blue2,alpha2;
	CGFloat red3,green3,blue3,alpha3;
	CGFloat red4,green4,blue4,alpha4;
	
	[inputColor1 getRed:&red1 green:&green1 blue:&blue1 alpha:&alpha1];
	[inputColor2 getRed:&red2 green:&green2 blue:&blue2 alpha:&alpha2];
	[inputColor3 getRed:&red3 green:&green3 blue:&blue3 alpha:&alpha3];
	[inputColor4 getRed:&red4 green:&green4 blue:&blue4 alpha:&alpha4];
	
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	/* apply environmental changes to our CGL context. */
	[inputBlending setOnOpenGLContext: context];
	[inputImage setOnOpenGLContext: context];
	[inputDepth setOnOpenGLContext: context];
	[inputCulling setOnOpenGLContext: context];
		
	glBegin(GL_QUADS);
		glTexCoord2f([inputU1 doubleValue],[inputV1 doubleValue]);
		glColor4f(red1,green1,blue1,alpha1);
		glVertex3f([inputX1 doubleValue],[inputY1 doubleValue],[inputZ1 doubleValue]);
		glTexCoord2f([inputU2 doubleValue],[inputV2 doubleValue]);
		glColor4f(red2,green2,blue2,alpha2);
		glVertex3f([inputX2 doubleValue],[inputY2 doubleValue],[inputZ2 doubleValue]);
		glTexCoord2f([inputU3 doubleValue],[inputV3 doubleValue]);
		glColor4f(red3,green3,blue3,alpha3);
		glVertex3f([inputX3 doubleValue],[inputY3 doubleValue],[inputZ3 doubleValue]);
		glTexCoord2f([inputU4 doubleValue],[inputV4 doubleValue]);
		glColor4f(red4,green4,blue4,alpha4);
		glVertex3f([inputX4 doubleValue],[inputY4 doubleValue],[inputZ4 doubleValue]);
	glEnd();

	/* Here we undo our CGLContextObj changes.  Undoing image is mandatory; OpenGL
		stack overflows internally otherwise, giving garbage output after a couple frames.
		other are just good form.
	*/
	[inputCulling unsetOnOpenGLContext: context];
	[inputDepth unsetOnOpenGLContext: context];
	[inputImage unsetOnOpenGLContext: context unit:GL_TEXTURE0];
	[inputBlending unsetOnOpenGLContext: context];
	
	return YES;
}

@end
