#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/CGLMacro.h>

#import "KinemeGLPointPatch.h"

@implementation KinemeGLPointPatch : QCPatch

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
		[inputSize setDoubleValue:8.0];
		[inputColor setRed:0.7 green:0.4 blue:0.4 alpha:0.9];
		
		[inputDepth setIndexValue:1];	// set normal read/write depth testing
		[inputBlending setIndexValue:3];	// set Alpha blend mode by default
		[[self userInfo] setObject:@"Kineme GL Point" forKey:@"name"];
	}
	return self;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{	
	GLboolean	smoothPoints;
	GLfloat origPointSize;
	GLfloat oldAttenuation[3];
	
	CGFloat color[4];
	
	if([inputSize doubleValue] <= 0.0)
		return YES;	// invisible -- do nothing
	
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	[inputColor getRed:&color[0] green:&color[1] blue:&color[2] alpha:&color[3]];
	
	glGetFloatv(GL_POINT_SIZE,&origPointSize);

	[inputBlending setOnOpenGLContext:context];
	[inputDepth setOnOpenGLContext:context];

	//id image = [[inputImage imageValue] createCroppedImageWithRect:[[inputImage imageValue] bounds]];
	//id f = [[inputImage imageValue] createCIImageForManager:imageManager withOptions:nil];
	//NSLog(@"f (%@) %@",[f className], f);
	//[inputImage setImageValue:f];
	
	//NSLog(@" (%f,%f), %fx%f\n", [image bounds].origin.x, [image bounds].origin.y, [image bounds].size.width, [image bounds].size.height);

	if([inputImage imageValue] != nil)
	{
		id image = [inputImage imageValue];
		[inputImage setOnOpenGLContext:context
				unit: GL_TEXTURE0
				//fromBounds: [image bounds]//NSMakeRect(0,0,500,500)//[[inputImage imageValue] bounds]
				fromBounds: [[image domainOfDefinition] bounds]
				withTarget: GL_TEXTURE_2D
				mipmappingLevels: 0
				matrix: NULL];//*/
		// This version doesn't handle non-alpha'd input correctly ... no idea why.
				/*unit: GL_TEXTURE0 
				withBounds: [[inputImage imageValue] bounds]
				transformation: nil
				target: GL_TEXTURE_2D
				mipmappingLevels: 0
				matrix: NULL];//*/
		glEnable(GL_POINT_SPRITE);
		glTexEnvf(GL_POINT_SPRITE, GL_COORD_REPLACE, GL_TRUE);
		//glPointParameterf(GL_POINT_SPRITE_COORD_ORIGIN,GL_LOWER_LEFT);
		//glTexCoord2f([image bounds].origin.x+[image bounds].size.width/2,[image bounds].origin.y+[image bounds].size.height/2);
	}
	
	smoothPoints = glIsEnabled(GL_POINT_SMOOTH);
	if(smoothPoints == FALSE)
		glEnable(GL_POINT_SMOOTH);
		
	glHint(GL_POINT_SMOOTH_HINT,GL_NICEST);

	if([inputAttenuate booleanValue])
	{
		float attenuate[3] = { 1.0, 1.0, 1.0 };	/* this may not be correct attenuation, but it looks pretty close */
		glGetFloatv(GL_POINT_DISTANCE_ATTENUATION, oldAttenuation);
		glPointParameterfv(GL_POINT_DISTANCE_ATTENUATION,attenuate);
		glPointParameterf (GL_POINT_SIZE_MAX, 128.0);
		glPointParameterf (GL_POINT_SIZE_MIN, 1.0);
	}
	
	glPointSize([inputSize doubleValue]);
	KIGLColor4v(color);

	glBegin(GL_POINTS);
		glVertex3f([inputX doubleValue],[inputY doubleValue],[inputZ doubleValue]);
	glEnd();

	glPointSize(origPointSize);
	if(!smoothPoints)
		glDisable(GL_POINT_SMOOTH);
	glDisable(GL_POINT_SPRITE);

	if([inputAttenuate booleanValue])
		glPointParameterfv(GL_POINT_DISTANCE_ATTENUATION,oldAttenuation);
	if([inputImage imageValue] != nil)
		[inputImage unsetOnOpenGLContext:context unit:GL_TEXTURE0];
	[inputDepth unsetOnOpenGLContext:context];
	[inputBlending unsetOnOpenGLContext:context];

	return YES;
}

@end
