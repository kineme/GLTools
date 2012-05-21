#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/CGLMacro.h>

#import "KinemeGLCubeStructurePatch.h"

@implementation KinemeGLCubeStructurePatch : QCPatch

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
		[inputDefaultSize setDoubleValue:0.1];
		[inputColor1 setRed:0.7 green:0.4 blue:0.4 alpha:0.9];
		[inputColor2 setRed:0.2 green:0.8 blue:0.6 alpha:0.75];
		
		[inputDepth setIndexValue:1];	// set normal read/write depth testing
		[inputBlending setIndexValue:3];	// set Alpha blend mode by default
		[[self userInfo] setObject:@"Kineme GL Cube Structure" forKey:@"name"];
	}
	return self;
}

- (void)cleanup:(QCOpenGLContext *)context
{
	CGLContextObj cgl_ctx = [context CGLContextObj];
	if(cube)
	{
		glDeleteLists(cube, 1);
		cube = 0;
	}
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	unsigned int count;
	
	CGFloat red, green, blue, alpha;
	CGFloat dRed,dGreen,dBlue,dAlpha;
	
	QCStructure *pointStruct = [inputPoints structureValue];
	count = [pointStruct count];

	if(!pointStruct)
		return YES;	// no points -- do nothing
	if(count == 0)
		return YES;	// no points -- do nothing
	if([inputDefaultSize doubleValue] <= 0.0)
		return YES;	// invisible -- do nothing
	
	[inputColor1 getRed:&red green:&green blue:&blue alpha:&alpha];
	[inputColor2 getRed:&dRed green:&dGreen blue:&dBlue alpha:&dAlpha];
	
	/* CGLMacros use 'cgl_ctx' */
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	[inputBlending setOnOpenGLContext:context];
	[inputDepth setOnOpenGLContext:context];
	[inputCulling setOnOpenGLContext:context];
	
	float cubeSize = [inputDefaultSize doubleValue] * 0.5f;
	if(cube == 0 || [inputDefaultSize wasUpdated])
	{
		// (re)build display list
		if(cube == 0)
			cube = glGenLists(1);
		GLfloat vec[8][3] =
		{
			{+cubeSize,+cubeSize,+cubeSize},//0
			{+cubeSize,+cubeSize,-cubeSize},//1
			{+cubeSize,-cubeSize,+cubeSize},//2
			{+cubeSize,-cubeSize,-cubeSize},//3
			{-cubeSize,+cubeSize,+cubeSize},//4
			{-cubeSize,+cubeSize,-cubeSize},//5
			{-cubeSize,-cubeSize,+cubeSize},//6
			{-cubeSize,-cubeSize,-cubeSize}//7
		};
		static const GLfloat normals[6][3] =
		{
			{0,1,0},
			{0,-1,0},
			{0,0,1},
			{0,0,-1},
			{-1,0,0},
			{1,0,0}			
		};
		glNewList(cube, GL_COMPILE);
		{
			glBegin(GL_QUADS);
			glNormal3fv(normals[0]);
			glVertex3fv(vec[0]);
			glVertex3fv(vec[1]);
			glVertex3fv(vec[5]);
			glVertex3fv(vec[4]);
			// bottom
			glNormal3fv(normals[1]);
			glVertex3fv(vec[6]);
			glVertex3fv(vec[7]);
			glVertex3fv(vec[3]);
			glVertex3fv(vec[2]);
			// front
			glNormal3fv(normals[2]);
			glVertex3fv(vec[4]);
			glVertex3fv(vec[6]);
			glVertex3fv(vec[2]);
			glVertex3fv(vec[0]);
			// back
			glNormal3fv(normals[3]);
			glVertex3fv(vec[1]);
			glVertex3fv(vec[3]);
			glVertex3fv(vec[7]);
			glVertex3fv(vec[5]);
			// left
			glNormal3fv(normals[4]);
			glVertex3fv(vec[4]);
			glVertex3fv(vec[5]);
			glVertex3fv(vec[7]);
			glVertex3fv(vec[6]);
			// right
			glNormal3fv(normals[5]);
			glVertex3fv(vec[2]);
			glVertex3fv(vec[3]);
			glVertex3fv(vec[1]);
			glVertex3fv(vec[0]);
			glEnd();
		}
		glEndList();
	}
		
	dRed -= red;
	dRed /= count;
	dGreen -= green;
	dGreen /= count;
	dBlue -= blue;
	dBlue /= count;
	dAlpha -= alpha;
	dAlpha /= count;
	
	Class QCStructureClass = [QCStructure class];
	Class NSArrayClass = [NSArray class];

	BOOL keyed = (count && [[pointStruct memberAtIndex:0] isKindOfClass:QCStructureClass] && 
				  [[pointStruct memberAtIndex:0] memberForKey:@"X"] != nil);
	//glBegin(GL_QUADS);
	
	float (*floatValue)() = (float (*)())[NSNumber instanceMethodForSelector:@selector(floatValue)];
	
	for(id point in (GFList*)[pointStruct _list])
	{
		CGFloat outColor[4] = {red, green, blue, alpha};
		
		glPushMatrix();

		if([point isKindOfClass: QCStructureClass])
		{
			float x, y, z;
			if(keyed)
			{
				id val;
				if(val = [point memberForKey:@"R"])
					//outColor[0] *= [val floatValue];
					outColor[0] *= floatValue(val, nil);
				if(val = [point memberForKey:@"G"])
					//outColor[1] *= [val floatValue];
					outColor[1] *= floatValue(val, nil);
				if(val = [point memberForKey:@"B"])
					//outColor[2] *= [val floatValue];
					outColor[2] *= floatValue(val, nil);
				if(val = [point memberForKey:@"A"])
					//outColor[3] *= [val floatValue];
					outColor[3] *= floatValue(val, nil);
				
				x = floatValue([point memberForKey:@"X"],nil);
				y = floatValue([point memberForKey:@"Y"],nil);
				z = floatValue([point memberForKey:@"Z"],nil);
				//x = [[point memberForKey:@"X"] floatValue];
				//y = [[point memberForKey:@"Y"] floatValue];
				//z = [[point memberForKey:@"Z"] floatValue];
			}
			else
			{
				id val;
				if(val = [point memberAtIndex:3])
					//outColor[0] *= [val floatValue];
					outColor[0] *= floatValue(val, nil);
				if(val = [point memberAtIndex:4])
					//outColor[1] *= [val floatValue];
					outColor[1] *= floatValue(val, nil);
				if(val = [point memberAtIndex:5])
					//outColor[2] *= [val floatValue];
					outColor[2] *= floatValue(val, nil);
				if(val = [point memberAtIndex:6])
					//outColor[3] *= [val floatValue];
					outColor[3] *= floatValue(val, nil);

				x = floatValue([point memberAtIndex:0]);
				y = floatValue([point memberAtIndex:1]);
				z = floatValue([point memberAtIndex:2]);
				//x = [[point memberAtIndex:0] floatValue];
				//y = [[point memberAtIndex:1] floatValue];
				//z = [[point memberAtIndex:2] floatValue];
			}
			glTranslatef(x, y, z);
		}
		else if( [point isKindOfClass:NSArrayClass] )
		{
			glTranslatef(floatValue([(NSArray *)point objectAtIndex:0]),
						 floatValue([(NSArray *)point objectAtIndex:1]),
						 floatValue([(NSArray *)point objectAtIndex:2]));
		}
		KIGLColor4v(outColor);
		
		glCallList(cube);
		glPopMatrix();
		
		// sadly, this is about 15% faster than multiplication (which is ok, since we're using fast enumeration now
		// anyway)
		red += dRed;
		green += dGreen;
		blue += dBlue;
		alpha += dAlpha;
	}
	//glEnd();

	[inputCulling unsetOnOpenGLContext:context];
	[inputDepth unsetOnOpenGLContext:context];
	[inputBlending unsetOnOpenGLContext:context];

	return YES;
}

@end
