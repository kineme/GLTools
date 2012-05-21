#import <OpenGL/CGLMacro.h>

#import "KinemeGLDepthSortSpritePatch.h"
#import "KinemeGLDepthSortEnvironmentPatch.h"


@implementation KinemeGLDepthSortLightweightSprite
@synthesize depth;
@synthesize width, height;
@synthesize image;
@synthesize blending, depthTesting, culling;
@synthesize imagePort;
@synthesize blendPort;
@synthesize depthPort;
@synthesize cullingPort;

-(void)setRed:(float)r green:(float)g blue:(float)b alpha:(float)a
{
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = a;
}

-(void)renderOnContext:(QCOpenGLContext*)context
{
	float w2 = width/2.0f;
	float h2 = height/2.0f;
	
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	[cullingPort setIndexValue:culling];
	[cullingPort setOnOpenGLContext:context];
	
	[depthPort setIndexValue:depthTesting];
	[depthPort setOnOpenGLContext:context];
	
	[blendPort setIndexValue:blending];
	[blendPort setOnOpenGLContext:context];
		
	[imagePort setImageValue:image];
	[imagePort setOnOpenGLContext:context unit:GL_TEXTURE0];
	
	glPushMatrix();
	glLoadMatrixd(matrix);
	
	glColor4fv(color);
	glNormal3f(0,0,1);
	
	glBegin(GL_QUADS);
	{
		glTexCoord2f(0,0);
		glVertex2f(-w2,-h2);
		glTexCoord2f(1,0);
		glVertex2f( w2,-h2);
		glTexCoord2f(1,1);
		glVertex2f( w2, h2);
		glTexCoord2f(0,1);
		glVertex2f(-w2, h2);
	}
	glEnd();
	glPopMatrix();
	
	[imagePort unsetOnOpenGLContext:context unit:GL_TEXTURE0];
	[blendPort unsetOnOpenGLContext:context];
	[depthPort unsetOnOpenGLContext:context];
	[cullingPort unsetOnOpenGLContext:context];
}

-(void)dealloc
{
	[image release];
	[super dealloc];
}

- (double*)matrix
{
	return matrix;
}
@end



@implementation KinemeGLDepthSortSpritePatch

@synthesize inputX;
@synthesize inputY;
@synthesize inputZ;
@synthesize inputXr;
@synthesize inputYr;
@synthesize inputZr;
@synthesize inputWidth;
@synthesize inputHeight;
@synthesize inputColor;
@synthesize inputImage;
//@synthesize inputMaskImage;
@synthesize inputBlending;
@synthesize inputDepthTesting;
@synthesize inputFaceCulling;

+ (QCPatchExecutionMode)executionModeWithIdentifier:(id)fp8
{
	return kQCPatchExecutionModeConsumer;
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
		[inputWidth setDoubleValue:1];
		[inputHeight setDoubleValue:1];
		[inputDepthTesting setIndexValue:1]; // Read / Write
		[[self userInfo] setObject:@"Kineme GL Depth Sort Sprite" forKey:@"name"];
	}
	
	return self;
}

- (BOOL)setup:(QCOpenGLContext *)context
{
	KinemeGLDepthSortEnvironmentPatch *p = (KinemeGLDepthSortEnvironmentPatch*)[self parentPatch];
	Class KinemeGLDepthSortEnvironmentPatchClass = [KinemeGLDepthSortEnvironmentPatch class];
	while( p && ![p isKindOfClass:KinemeGLDepthSortEnvironmentPatchClass] )
		p = (KinemeGLDepthSortEnvironmentPatch*)[p parentPatch];
	_depthSortEnvironment = p;

	// don't alloc helper ports if we're not in the environment
	if(_depthSortEnvironment)
	{
		// initWithNode assigns a parentPatch to the port, so PerformanceInspector can associate image port stats with a patch 
		// (depthSortEnv in this case)
		imagePort = [[QCOpenGLPort_Image allocWithZone:NULL] initWithNode:p arguments:nil];
		blendPort = [[QCOpenGLPort_Blending allocWithZone:NULL] initWithNode:p arguments:nil];
		depthPort = [[QCOpenGLPort_ZBuffer allocWithZone:NULL] initWithNode:p arguments:nil];
		cullingPort = [[QCOpenGLPort_Culling allocWithZone:NULL] initWithNode:p arguments:nil];
	}
	
	return YES;
}

- (void)cleanup:(QCOpenGLContext *)context
{
	[imagePort release];
	[blendPort release];
	[depthPort release];
	[cullingPort release];
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	glPushMatrix();
	
	CGFloat matrix[16];
	
	QCGLMakeTransformationMatrix(matrix,[inputXr doubleValue],[inputYr doubleValue],[inputZr doubleValue],[inputX doubleValue],[inputY doubleValue],[inputZ doubleValue]);
	
	KIGLMultMatrix(matrix);
		
	if(_depthSortEnvironment)
	{
		KinemeGLDepthSortLightweightSprite *e = [[KinemeGLDepthSortLightweightSprite allocWithZone:NULL] init];
		[e setWidth:[inputWidth doubleValue]];
		[e setHeight:[inputHeight doubleValue]];
		CGFloat r, g, b, a;
		[inputColor getRed:&r green:&g blue:&b alpha:&a];

		// Effing pre-multiply (holy crap I hate premultiplied alpha... what sissies thought of this?
		r *= a;
		g *= a;
		b *= a;
		
		[e setRed:r green:g blue:b alpha:a];
		[e setImage:[inputImage imageValue]];
		[e setBlending:[inputBlending indexValue]];
		[e setDepthTesting:[inputDepthTesting indexValue]];
		[e setCulling:[inputFaceCulling indexValue]];
		
		[e setImagePort:imagePort];
		[e setBlendPort:blendPort];
		[e setDepthPort:depthPort];
		[e setCullingPort:cullingPort];
		
		// preserve the current matrix
		{			
			GLdouble *m = (GLdouble*)[e matrix];
			glGetDoublev(GL_MODELVIEW_MATRIX, m);
			/*GLdouble *mat = (GLdouble*)[e matrix];
			NSLog(@"Matrix: (%x)\n%f %f %f %f\n%f %f %f %f\n%f %f %f %f\n%f %f %f %f\n", self,
				  mat[0],mat[4],mat[8],mat[12],
				  mat[1],mat[5],mat[9],mat[13],
				  mat[2],mat[6],mat[10],mat[14],
				  mat[3],mat[7],mat[11],mat[15]);*/
			
			// m[12-14] are our x,y,z translation values
			double dist = m[14];
			
			[e setDepth:dist];
		}

		/* opacity's a bit tricky:
			if we are wrong, and say we're opaque when we're not, we get wrong output.
			if we are wrong, and say we're not opaque when we are, we get correct output, but a performance hit.
			Thus, we're conservative on declaring outselves opaque
		 
			we're opaque if:
				our blend mode is 0 (replace)
				our color alpha is 1.0 and our image provider says we don't have alpha
		*/
		
		BOOL isOpaque = ([inputBlending indexValue] == 0);
		if(!isOpaque)
			isOpaque = a >= 1.0 && ![[[inputImage imageValue] provider] hasAlpha];
		
		[_depthSortEnvironment addElement:e isOpaque:isOpaque];
		[e release];
	}
	else
		[self renderOnContext:context];
	
	glPopMatrix();

	return YES;
}


- (void)renderOnContext:(QCOpenGLContext *)context
{
	float w2=[inputWidth doubleValue]/2.0f;
	float h2=[inputHeight doubleValue]/2.0f;

	CGLContextObj cgl_ctx = [context CGLContextObj];

	[inputFaceCulling setOnOpenGLContext: context];
	[inputDepthTesting setOnOpenGLContext: context];
	[inputBlending setOnOpenGLContext: context];
	[inputImage setOnOpenGLContext: context unit:GL_TEXTURE0];
	
	CGFloat color[4];
	
	[inputColor getRed:&color[0] green:&color[1] blue:&color[2] alpha:&color[3]];
	// Effing pre-multiply (holy crap I hate premultiplied alpha... what sissies thought of this?
	color[0] *= color[3];
	color[1] *= color[3];
	color[2] *= color[3];
	
	KIGLColor4v(color);
	glNormal3f(0,0,1);

	glBegin(GL_QUADS);
	{
		glTexCoord2f(0,0);
		glVertex2f(-w2,-h2);
		glTexCoord2f(1,0);
		glVertex2f( w2,-h2);
		glTexCoord2f(1,1);
		glVertex2f( w2, h2);
		glTexCoord2f(0,1);
		glVertex2f(-w2, h2);
	}
	glEnd();

	[inputImage unsetOnOpenGLContext: context unit:GL_TEXTURE0];
	[inputBlending unsetOnOpenGLContext: context];
	[inputDepthTesting unsetOnOpenGLContext: context];
	[inputFaceCulling unsetOnOpenGLContext: context];
}
@end
