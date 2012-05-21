#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/CGLMacro.h>

#import "KinemeGLLineStructurePatch.h"

@implementation KinemeGLLineStructurePatch : QCPatch

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
	self=[super initWithIdentifier:fp8];
	if(self)
	{
		[inputSize setDoubleValue:1.0];
		[inputSize setMinDoubleValue:0.01];
		[inputPattern setIndexValue: 65535];
		[inputPattern setMaxIndexValue: 65535];
		[inputRepeatCount setIndexValue: 1];
		[inputRepeatCount setMaxIndexValue: 256];
		[inputColor1 setRed:0.7 green:0.4 blue:0.4 alpha:0.9];
		[inputColor2 setRed:0.4 green:0.4 blue:0.7 alpha:0.9];
		[inputType setMaxIndexValue:1];
		
		[inputDepth setIndexValue:1];	// set normal read/write depth testing
		[inputBlending setIndexValue:3];	// set Alpha blend mode by default
		[[self userInfo] setObject:@"Kineme GL Line Structure" forKey:@"name"];
	}
	return self;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	GLint	smoothLines;
	GLint	oldFactor;
	GLint	oldPattern;
	GLfloat origLineWidth;
	
	CGFloat red1,green1,blue1,alpha1;
	CGFloat red2,green2,blue2,alpha2;
	
	QCStructure *lineStruct = [inputLines structureValue];
	if(lineStruct == nil)
		return YES;	// no points, do nothing
	
	unsigned int count = [lineStruct count];
	if(count == 0)
		return YES;
	
	[inputColor1 getRed:&red1 green:&green1 blue:&blue1 alpha:&alpha1];
	[inputColor2 getRed:&red2 green:&green2 blue:&blue2 alpha:&alpha2];
	
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	[inputBlending setOnOpenGLContext: context];
	[inputDepth setOnOpenGLContext: context];
	//[inputImage setOnOpenGLContext:context];
	
	glGetFloatv(GL_LINE_WIDTH, &origLineWidth);
	
	double lineWidth = [inputSize doubleValue];
	if(lineWidth != origLineWidth)
		glLineWidth([inputSize doubleValue]);

	smoothLines = glIsEnabled(GL_LINE_SMOOTH);
	if(!smoothLines)
		glEnable(GL_LINE_SMOOTH);
	glHint(GL_LINE_SMOOTH_HINT,GL_NICEST);
	
	int stipple = [inputPattern indexValue];
	if(stipple != 0xffff)
	{
		glGetIntegerv(GL_LINE_STIPPLE_REPEAT,&oldFactor);
		glGetIntegerv(GL_LINE_STIPPLE_PATTERN,&oldPattern);
		glEnable(GL_LINE_STIPPLE);
		glLineStipple([inputRepeatCount indexValue], stipple);
	}
		
	Class QCStructureClass = [QCStructure class];
	Class NSArrayClass = [NSArray class];

	BOOL keyed = (count && 
				  [[lineStruct memberAtIndex:0] isKindOfClass:QCStructureClass] && 
				  [[lineStruct memberAtIndex:0] memberForKey:@"X"] != nil);

	if([inputType indexValue])
	{
		unsigned char end = 0;
		glBegin(GL_LINES);
		for(id point in (GFList*)[lineStruct _list])
		{
			if(end++&1)
				KIGLColor4(red1,green1,blue1,alpha1);
			else
				KIGLColor4(red2,green2,blue2,alpha2);

			if([point isKindOfClass: QCStructureClass])
			{
				GFList *pointData = [point _list];
				if(keyed)
					glVertex3d(
							   [[point memberForKey:@"X"] doubleValue],
							   [[point memberForKey:@"Y"] doubleValue],
							   [[point memberForKey:@"Z"] doubleValue]);
				else
					glVertex3d(
							   [[pointData objectAtIndex:0] doubleValue],
							   [[pointData objectAtIndex:1] doubleValue],
							   [[pointData objectAtIndex:2] doubleValue]);
			}
			else if([point isKindOfClass:NSArrayClass])
			{
				glVertex3d(
						   [[(NSArray *)point objectAtIndex:0] doubleValue],
						   [[(NSArray *)point objectAtIndex:1] doubleValue],
						   [[(NSArray *)point objectAtIndex:2] doubleValue]);
			}
		}
	}
	else
	{
		glBegin(GL_LINE_STRIP);
		CGFloat dRed, dGreen, dBlue, dAlpha;
		dRed = (red2 - red1) / count;
		dGreen = (green2 - green1) / count;
		dBlue = (blue2 - blue1) / count;
		dAlpha = (alpha2 - alpha1) / count;
		for(id point in (GFList*)[lineStruct _list])
		{
			KIGLColor4(red1,green1,blue1,alpha1);
			if([point isKindOfClass: QCStructureClass])
			{
				GFList *pointData = [point _list];
				if(keyed)
					glVertex3d(
							[[point memberForKey:@"X"] doubleValue],
							[[point memberForKey:@"Y"] doubleValue],
							[[point memberForKey:@"Z"] doubleValue]);
				else
					glVertex3d(
							   [[pointData objectAtIndex:0] doubleValue],
							   [[pointData objectAtIndex:1] doubleValue],
							   [[pointData objectAtIndex:2] doubleValue]);
			}
			else if([point isKindOfClass:NSArrayClass])
			{
				glVertex3d(
						   [[(NSArray *)point objectAtIndex:0] doubleValue],
						   [[(NSArray *)point objectAtIndex:1] doubleValue],
						   [[(NSArray *)point objectAtIndex:2] doubleValue]);
			}
			red1 += dRed;
			green1 += dGreen;
			blue1 += dBlue;
			alpha1 += dAlpha;
		}
	}
	glEnd();
	
	if(!smoothLines)
		glDisable(GL_LINE_SMOOTH);
	if(lineWidth != origLineWidth)
		glLineWidth(origLineWidth);
	if(stipple != 0xffff)
	{
		glLineStipple(oldFactor, oldPattern);
		glDisable(GL_LINE_STIPPLE);
	}

	[inputDepth unsetOnOpenGLContext: context];
	[inputBlending unsetOnOpenGLContext: context];

	return YES;
}

@end
