#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/CGLMacro.h>

#import "KinemeGLPolygonModePatch.h"


@implementation KinemeGLPolygonModePatch : QCPatch

+ (QCPatchExecutionMode)executionModeWithIdentifier:(id)fp8
{
	return 1;	// renders stuff
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
		[inputFrontPolygonMode setMaxIndexValue: 2];
		[inputBackPolygonMode setMaxIndexValue:  2];
		[inputSize setMinDoubleValue:  0.4];
		[inputWidth setMinDoubleValue: 0.4];
		[inputSize setDoubleValue:  1.0];
		[inputWidth setDoubleValue: 1.0];
		[inputStipplePattern setMaxIndexValue: 65535];
		[inputStipplePattern setIndexValue: 65535];
		[inputRepeatCount setMaxIndexValue: 256];
		[inputRepeatCount setIndexValue: 1];
		[[self userInfo] setObject:@"Kineme GL Polygon Mode" forKey:@"name"];
	}
	return self;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	GLint origPolygonMode[2];
	GLfloat origLineWidth;
	GLfloat origPointSize;
	GLint	oldFactor;
	GLint	oldPattern;
	GLboolean smoothPoints, smoothLines;
	
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	// store the original values
	glGetIntegerv(GL_LINE_STIPPLE_REPEAT,&oldFactor);
	glGetIntegerv(GL_LINE_STIPPLE_PATTERN,&oldPattern);
	glGetIntegerv(GL_POLYGON_MODE,origPolygonMode);
	glGetFloatv(GL_LINE_WIDTH,&origLineWidth);
	glGetFloatv(GL_POINT_SIZE, &origPointSize);

	smoothPoints = glIsEnabled(GL_POINT_SMOOTH);
	smoothLines = glIsEnabled(GL_LINE_SMOOTH);
	if([inputAntialiasPoints booleanValue] && !smoothPoints)
		glEnable(GL_POINT_SMOOTH);
	if([inputAntialiasLines booleanValue] && !smoothLines)
		glEnable(GL_LINE_SMOOTH);
	glEnable(GL_LINE_STIPPLE);
	glLineStipple([inputRepeatCount indexValue],[inputStipplePattern indexValue]);

	switch([inputFrontPolygonMode indexValue])
	{
		default:
		case 0:	// filled
			glPolygonMode(GL_FRONT, GL_FILL);
			break;
		case 1:	// wireframe
			glPolygonMode(GL_FRONT, GL_LINE);
			break;
		case 2:	// points
			glPolygonMode(GL_FRONT, GL_POINT);
			break;
	}
	switch([inputBackPolygonMode indexValue])
	{
		default:
		case 0:	// filled
			glPolygonMode(GL_BACK, GL_FILL);
			break;
		case 1:	// wireframe
			glPolygonMode(GL_BACK, GL_LINE);
			break;
		case 2:	// points
			glPolygonMode(GL_BACK, GL_POINT);
			break;
	}
	
	glLineWidth([inputWidth doubleValue]);
	glPointSize([inputSize doubleValue]);
	
	[self executeSubpatches:time arguments:arguments];
	
	// restore the previous mode
	glDisable(GL_LINE_STIPPLE);
	glLineStipple(oldFactor, oldPattern);
	if(!smoothPoints)
		glDisable(GL_POINT_SMOOTH);
	if(!smoothLines)
		glDisable(GL_LINE_SMOOTH);

	glPolygonMode(GL_FRONT,origPolygonMode[0]);
	glPolygonMode(GL_BACK,origPolygonMode[1]);
	glLineWidth(origLineWidth);
	glPointSize(origPointSize);

	return YES;
}

@end
