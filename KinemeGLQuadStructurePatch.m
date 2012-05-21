#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/CGLMacro.h>

#import "KinemeGLQuadStructurePatch.h"


@implementation KinemeGLQuadStructurePatch : QCPatch

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
		[inputDepth setIndexValue:1];	// set normal read/write depth testing
		[inputCulling setIndexValue:1];	// set normal backface culling by default
		[inputType setMaxIndexValue: 1];
		[[self userInfo] setObject:@"Kineme GL Quad Structure" forKey:@"name"];
	}
	return self;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	QCStructure *quadStruct = [inputQuads structureValue];
	if(quadStruct == nil)
		return YES;	// no points, do nothing
	if([quadStruct count] == 0)
		return YES;

	CGFloat defaultRed,defaultGreen,defaultBlue,defaultAlpha;
	
	[inputColor getRed:&defaultRed green:&defaultGreen blue:&defaultBlue alpha:&defaultAlpha];
	
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	/* apply environmental changes to our CGL context. */
	[inputBlending setOnOpenGLContext: context];
	QCStructure *imageStructure = [inputImageStructure structureValue];
	NSUInteger imageStructureCount = [imageStructure count];

	if(imageStructureCount==0)
		[inputImage setOnOpenGLContext: context];
	else
	{
		[inputImage setImageValue:[imageStructure memberAtIndex:0]];
		[inputImage setOnOpenGLContext: context];
	}

	[inputDepth setOnOpenGLContext: context];
	[inputCulling setOnOpenGLContext: context];

	Class QCStructureClass = [QCStructure class];
	Class NSArrayClass = [NSArray class];
	BOOL keyed = ([[quadStruct memberAtIndex:0] isKindOfClass:QCStructureClass] && [[quadStruct memberAtIndex:0] memberForKey:@"X"] != nil);
	BOOL hasNormals = ([[quadStruct memberAtIndex:0] isKindOfClass:QCStructureClass]) &&
						([[quadStruct memberAtIndex:0] memberForKey:@"NX"] != nil) && 
						([[quadStruct memberAtIndex:0] memberForKey:@"NY"] != nil) && 
						([[quadStruct memberAtIndex:0] memberForKey:@"NZ"] != nil);
	glPushMatrix();
	glTranslated([inputXPosition doubleValue],
				 [inputYPosition doubleValue],
				 [inputZPosition doubleValue]);
	
	glRotated([inputXRotation doubleValue],1.0,0.0,0.0);
	glRotated([inputYRotation doubleValue],0.0,1.0,0.0);
	glRotated([inputZRotation doubleValue],0.0,0.0,1.0);		

	bool quadStrip = ([inputType indexValue] == 1);
	if(quadStrip)
		glBegin(GL_QUAD_STRIP);
	else
		glBegin(GL_QUADS);
	
	{
		if(!keyed)
			KIGLColor4(defaultRed,defaultGreen,defaultBlue,defaultAlpha);
		
		NSUInteger i=0;
		for(id point in (GFList*)[quadStruct _list])
		{
			// if we have an image structure, switch image every quad
			if(!quadStrip && imageStructureCount && i>0 && i%4==0 && i/4<imageStructureCount)
			{
				glEnd();
				[inputImage unsetOnOpenGLContext:context];
				[inputImage setImageValue:[imageStructure memberAtIndex:i/4]];
				[inputImage setOnOpenGLContext:context];
				glBegin(GL_QUADS);
			}

			if( [point isKindOfClass:QCStructureClass] )
			{
				if(keyed)
				{
					{
						float outColor[4] = {defaultRed,defaultGreen,defaultBlue,defaultAlpha};
						
						if( [point memberForKey:@"R"] )
							outColor[0] *= [[point memberForKey:@"R"] doubleValue];
						if( [point memberForKey:@"G"] )
							outColor[1] *= [[point memberForKey:@"G"] doubleValue];
						if( [point memberForKey:@"B"] )
							outColor[2] *= [[point memberForKey:@"B"] doubleValue];
						if( [point memberForKey:@"A"] )
							outColor[3] *= [[point memberForKey:@"A"] doubleValue];
						
						glColor4fv(outColor);
					}

					glTexCoord2d
					(
						[[point memberForKey:@"U"] doubleValue],
						[[point memberForKey:@"V"] doubleValue]
					);

					if(hasNormals)
						glNormal3d
						(
							[[point memberForKey:@"NX"] doubleValue],
							[[point memberForKey:@"NY"] doubleValue],
							[[point memberForKey:@"NZ"] doubleValue]
						);

					glVertex3d
					(
						[[point memberForKey:@"X"] doubleValue],
						[[point memberForKey:@"Y"] doubleValue],
						[[point memberForKey:@"Z"] doubleValue]
					);
				}
				else
					glVertex3d(
							[[point memberAtIndex:0] doubleValue],
							[[point memberAtIndex:1] doubleValue],
							[[point memberAtIndex:2] doubleValue]);
			}
			else if( [point isKindOfClass:NSArrayClass] )
				glVertex3d(
						[[(NSArray *)point objectAtIndex:0] doubleValue],
						[[(NSArray *)point objectAtIndex:1] doubleValue],
						[[(NSArray *)point objectAtIndex:2] doubleValue]);

			++i;
		}
	}
	
	glEnd();
	glPopMatrix();
	
	/* Here we undo our CGLContextObj changes.  Undoing image is mandatory; OpenGL
		stack overflows internally otherwise, giving garbage output after a couple frames.
		other are just good form.
	*/
	[inputCulling unsetOnOpenGLContext: context];
	[inputDepth unsetOnOpenGLContext: context];
	[inputImage unsetOnOpenGLContext: context];
	if(imageStructureCount)
		[inputImage setImageValue:nil];
	[inputBlending unsetOnOpenGLContext: context];

	return YES;
}

@end
