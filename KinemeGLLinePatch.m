#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/CGLMacro.h>

#import "KinemeGLLinePatch.h"


@implementation KinemeGLLinePatch : QCPatch

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
	if(self=[super initWithIdentifier:fp8])
	{
		[inputSize setDoubleValue:1.0];
		[inputPattern setIndexValue: 65535];
		[inputPattern setMaxIndexValue: 65535];
		[inputRepeatCount setIndexValue: 1];
		[inputRepeatCount setMaxIndexValue: 256];
		[inputX1 setDoubleValue:-0.5];
		[inputX2 setDoubleValue:0.5];
		[inputColor1 setRed:0.7 green:0.4 blue:0.4 alpha:0.9];
		[inputColor2 setRed:0.4 green:0.4 blue:0.7 alpha:0.9];
		
		[inputDepth setIndexValue:1];	// set normal read/write depth testing
		[inputBlending setIndexValue:3];	// set Alpha blend mode by default
		[[self userInfo] setObject:@"Kineme GL Line" forKey:@"name"];
	}
	return self;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	GLint	smoothLines;
	GLint	oldFactor;
	GLint	oldPattern;
	GLfloat origLineWidth;
	
	CGFloat color1[4];
	CGFloat color2[4];
		
	CGLContextObj cgl_ctx = [context CGLContextObj];

	[inputColor1 getRed:&color1[0] green:&color1[1] blue:&color1[2] alpha:&color1[3]];
	[inputColor2 getRed:&color2[0] green:&color2[1] blue:&color2[2] alpha:&color2[3]];
	
	[inputBlending setOnOpenGLContext: context];
	[inputDepth setOnOpenGLContext: context];
	[inputImage setOnOpenGLContext:context unit:GL_TEXTURE0];
	
	glGetFloatv(GL_LINE_WIDTH, &origLineWidth);

	smoothLines = glIsEnabled(GL_LINE_SMOOTH);
	if(!smoothLines)
		glEnable(GL_LINE_SMOOTH);
	glHint(GL_LINE_SMOOTH_HINT,GL_NICEST);
	
	if([inputPattern indexValue] != 0xffff)
	{
		glGetIntegerv(GL_LINE_STIPPLE_REPEAT,&oldFactor);
		glGetIntegerv(GL_LINE_STIPPLE_PATTERN,&oldPattern);
		glEnable(GL_LINE_STIPPLE);
		glLineStipple([inputRepeatCount indexValue],[inputPattern indexValue]);
	}
	glLineWidth([inputSize doubleValue]);

	KIGLColor4v(color1);
	glBegin(GL_LINES);
	{
		if([inputImage imageValue])
		{
			glTexCoord2f([inputU1 doubleValue], [inputV1 doubleValue]);
			glVertex3f([inputX1 doubleValue],[inputY1 doubleValue],[inputZ1 doubleValue]);
			glTexCoord2f([inputU2 doubleValue], [inputV2 doubleValue]);
		}
		else
			glVertex3f([inputX1 doubleValue],[inputY1 doubleValue],[inputZ1 doubleValue]);

		//if(color1[0] != color2[0] || color1[1] != color2[1] || color1[2] != color2[2] || color1[3] != color2[3])
		KIGLColor4v(color2);
		
		glVertex3f([inputX2 doubleValue],[inputY2 doubleValue],[inputZ2 doubleValue]);
	}
	glEnd();
	
	if(!smoothLines)
		glDisable(GL_LINE_SMOOTH);
	glLineWidth(origLineWidth);
	if([inputPattern indexValue] != 0xffff)
		glLineStipple(oldFactor, oldPattern);

	[inputImage unsetOnOpenGLContext: context unit:GL_TEXTURE0];
	[inputDepth unsetOnOpenGLContext: context];
	[inputBlending unsetOnOpenGLContext: context];

	return YES;
}

@end
