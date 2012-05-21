#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/CGLMacro.h>

#import "KinemeGLTriangleStructurePatch.h"


@implementation KinemeGLTriangleStructurePatch : QCPatch

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
		[[self userInfo] setObject:@"Kineme GL Triangle Structure" forKey:@"name"];
	}
	return self;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	QCStructure *triangleStruct = [inputTriangles structureValue];
	if(triangleStruct == nil)
		return YES;	// no points, do nothing
	if([triangleStruct count] == 0)
		return YES;

	CGFloat defaultRed,defaultGreen,defaultBlue,defaultAlpha;
	
	[inputColor getRed:&defaultRed green:&defaultGreen blue:&defaultBlue alpha:&defaultAlpha];
	
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	/* apply environmental changes to our CGL context. */
	[inputBlending setOnOpenGLContext: context];
	[inputImage setOnOpenGLContext: context unit:GL_TEXTURE0];
	[inputDepth setOnOpenGLContext: context];
	[inputCulling setOnOpenGLContext: context];
		
	Class QCStructureClass = [QCStructure class];
	Class NSArrayClass = [NSArray class];
	BOOL keyed = ([[triangleStruct memberAtIndex:0] isKindOfClass:QCStructureClass] && [[triangleStruct memberAtIndex:0] memberForKey:@"X"] != nil);
	BOOL hasNormals = ([[triangleStruct memberAtIndex:0] isKindOfClass:QCStructureClass]) &&
						([[triangleStruct memberAtIndex:0] memberForKey:@"NX"] != nil) && 
						([[triangleStruct memberAtIndex:0] memberForKey:@"NY"] != nil) && 
						([[triangleStruct memberAtIndex:0] memberForKey:@"NZ"] != nil);

	glPushMatrix();
	glTranslated([inputXPosition doubleValue],
				 [inputYPosition doubleValue],
				 [inputZPosition doubleValue]);
	
	glRotated([inputXRotation doubleValue],1.0,0.0,0.0);
	glRotated([inputYRotation doubleValue],0.0,1.0,0.0);
	glRotated([inputZRotation doubleValue],0.0,0.0,1.0);		
	
	if([inputType indexValue] == 1)
		glBegin(GL_TRIANGLE_STRIP);
	else
		glBegin(GL_TRIANGLES);
	
	{
		if(!keyed)
			KIGLColor4(defaultRed,defaultGreen,defaultBlue,defaultAlpha);
		
		for(id point in (GFList*)[triangleStruct _list])
		{
			if( [point isKindOfClass:QCStructureClass] )
			{
				if(keyed)
				{
					{
						CGFloat outColor[4] = {defaultRed,defaultGreen,defaultBlue,defaultAlpha};
						
						if( [point memberForKey:@"R"] )
							outColor[0] *= [[point memberForKey:@"R"] doubleValue];
						if( [point memberForKey:@"G"] )
							outColor[1] *= [[point memberForKey:@"G"] doubleValue];
						if( [point memberForKey:@"B"] )
							outColor[2] *= [[point memberForKey:@"B"] doubleValue];
						if( [point memberForKey:@"A"] )
							outColor[3] *= [[point memberForKey:@"A"] doubleValue];
						
						KIGLColor4v(outColor);
					}

					glTexCoord2f
					(
						[[point memberForKey:@"U"] doubleValue],
						[[point memberForKey:@"V"] doubleValue]
					);

					if(hasNormals)
						glNormal3f
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
	[inputImage unsetOnOpenGLContext: context unit:GL_TEXTURE0];
	[inputBlending unsetOnOpenGLContext: context];

	return YES;
}

@end
