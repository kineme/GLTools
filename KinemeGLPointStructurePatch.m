#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/CGLMacro.h>

#import "KinemeGLPointStructurePatch.h"

@implementation KinemeGLPointStructurePatch : QCPatch

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
		[inputDefaultSize setDoubleValue:8.0];
		[inputColor1 setRed:0.7 green:0.4 blue:0.4 alpha:0.9];
		[inputColor2 setRed:0.2 green:0.8 blue:0.6 alpha:0.75];
		
		[inputDepth setIndexValue:1];	// set normal read/write depth testing
		[inputBlending setIndexValue:3];	// set Alpha blend mode by default
		[[self userInfo] setObject:@"Kineme GL Point Structure" forKey:@"name"];
	}
	return self;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	GLboolean	smoothPoints;
	GLfloat origPointSize;
	GLfloat oldAttenuation[3];
	unsigned int count;
	
	CGFloat red, green, blue, alpha;
	CGFloat dRed,dGreen,dBlue,dAlpha;
	
	if(![inputPoints structureValue])
		return YES;	// no points -- do nothing
	if([inputDefaultSize doubleValue] <= 0.0)
		return YES;	// invisible -- do nothing
	
	QCStructure *pointStruct = [inputPoints structureValue];
	if((count = [pointStruct count]) == 0)
		return YES;	// no points
	
	[inputColor1 getRed:&red green:&green blue:&blue alpha:&alpha];
	[inputColor2 getRed:&dRed green:&dGreen blue:&dBlue alpha:&dAlpha];
	
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	glGetFloatv(GL_POINT_SIZE,&origPointSize);

	[inputBlending setOnOpenGLContext:context];
	[inputDepth setOnOpenGLContext:context];

	//id image = [QCPlugInInputImage initWithImage:[inputImage imageValue] context:cgl_ctx];
	//[image bindTextureRepresentationToCGLContext:cgl_ctx textureUnit:GL_TEXTURE0 normalizeCoordinates:YES];

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
	
	glPointSize([inputDefaultSize doubleValue]);
	
	Class QCStructureClass = [QCStructure class];
	Class NSArrayClass = [NSArray class];

	dRed -= red;
	dRed /= count;
	dGreen -= green;
	dGreen /= count;
	dBlue -= blue;
	dBlue /= count;
	dAlpha -= alpha;
	dAlpha /= count;
	BOOL keyed = (count && [[pointStruct memberAtIndex:0] isKindOfClass:QCStructureClass] && 
				  [[pointStruct memberAtIndex:0] memberForKey:@"X"] != nil);
	glNormal3f(0,0,0);
	glBegin(GL_POINTS);
	
	for(id point in (GFList*)[pointStruct _list])
	{
		CGFloat outColor[4] = {red, green, blue, alpha};

		if( [point isKindOfClass:QCStructureClass] )
		{
			GFList *pointData = [point _list];

			if(keyed)
			{
				id val;
				if(val = [pointData objectAtIndex:[pointData indexOfKey:@"R"]])
					outColor[0] *= [val floatValue];
				if(val = [pointData objectAtIndex:[pointData indexOfKey:@"G"]])
					outColor[1] *= [val floatValue];
				if(val = [pointData objectAtIndex:[pointData indexOfKey:@"B"]])
					outColor[2] *= [val floatValue];
				if(val = [pointData objectAtIndex:[pointData indexOfKey:@"A"]])
					outColor[3] *= [val floatValue];
				
				KIGLColor4v(outColor);

				glVertex3d(
						   [[pointData objectAtIndex:[pointData indexOfKey:@"X"]] doubleValue],
						   [[pointData objectAtIndex:[pointData indexOfKey:@"Y"]] doubleValue],
						   [[pointData objectAtIndex:[pointData indexOfKey:@"Z"]] doubleValue]);
			}
			else
			{
				id val; 
				if(val = [pointData objectAtIndex:3])
					outColor[0] *= [val floatValue];
				if(val = [pointData objectAtIndex:4])
					outColor[1] *= [val floatValue];
				if(val = [pointData objectAtIndex:5])
					outColor[2] *= [val floatValue];
				if(val = [pointData objectAtIndex:6])
					outColor[3] *= [val floatValue];

				KIGLColor4v(outColor);

				glVertex3d(
					[[pointData objectAtIndex: 0] doubleValue],
					[[pointData objectAtIndex: 1] doubleValue],
					[[pointData objectAtIndex: 2] doubleValue]);
			}
		}
		else if( [point isKindOfClass:NSArrayClass] )
		{
			KIGLColor4v(outColor);

			glVertex3d(
				[[(NSArray *)point objectAtIndex:0] doubleValue],
				[[(NSArray *)point objectAtIndex:1] doubleValue],
				[[(NSArray *)point objectAtIndex:2] doubleValue]);
		}

		// sadly, this is about 15% faster than multiplication (which is ok, since we're using fast enumeration now
		// anyway)
		red += dRed;
		green += dGreen;
		blue += dBlue;
		alpha += dAlpha;
	}
	glEnd();

	glPointSize(origPointSize);
	if(!smoothPoints)
		glDisable(GL_POINT_SMOOTH);
	glDisable(GL_POINT_SPRITE);

	//[image unbindTextureRepresentationFromCGLContext:cgl_ctx textureUnit:GL_TEXTURE0];

	if([inputAttenuate booleanValue])
		glPointParameterfv(GL_POINT_DISTANCE_ATTENUATION,oldAttenuation);
	if([inputImage imageValue] != nil)
		[inputImage unsetOnOpenGLContext:context unit:GL_TEXTURE0];
	[inputDepth unsetOnOpenGLContext:context];
	[inputBlending unsetOnOpenGLContext:context];

	return YES;
}

@end
