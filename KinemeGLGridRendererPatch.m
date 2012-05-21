#import <OpenGL/CGLMacro.h>
#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>
#import "KinemeGLGridRendererPatch.h"

#define LERP(p0, p1, alpha) (p0+alpha*(p1-p0))

//#define LERP4(n0, n1, n2, n3, xa, ya) LERP(LERP(n0,n1,xa),LERP(n3,n2,xa),ya)
static inline float LERP4(float n0, float n1, float n2, float n3, float xa, float ya)
{
	return LERP(LERP(n0,n1,xa),LERP(n3,n2,xa),ya);
}

@implementation KinemeGLGridRendererPatch : QCPatch

+ (QCPatchExecutionMode)executionModeWithIdentifier:(id)fp8
{
	return 1;
}
+ (BOOL)allowsSubpatchesWithIdentifier:(id)fp8
{
	return NO;
}

- (id)initWithIdentifier:(id)fp8
{
	self=[super initWithIdentifier:fp8];
	
	if(self)
	{
		/*vertexData = NULL;
		colorData = NULL;
		texData = NULL;
		currentWidth = 0;
		currentHeight = 0;*/
		[inputWireFrame setMaxIndexValue:2];
		[[self userInfo] setObject:@"Kineme GL Grid Renderer" forKey:@"name"];
	}
	
	return self;
}

/*GLfloat S [4] =
{ 1.0, 0.0, 0.0, +0.5 };


GLfloat T[14] = 
{ 0.0, 1.0, 0.0, +0.5 };*/

- (void)enable:(QCOpenGLContext*)context
{
	CGLContextObj cgl_ctx = [context CGLContextObj];
	gridList = glGenLists(1);
}

- (void)disable:(QCOpenGLContext*)context
{
	CGLContextObj cgl_ctx = [context CGLContextObj];
	glDeleteLists(gridList, 1);
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	QCStructure *mesh = [inputStructure structureValue];
	QCStructure *vertex;

	unsigned int x, y;
	unsigned int width, height;
	
	if(mesh == nil)
		return YES;

	width = [[mesh memberForKey:@"width"] intValue];
	height = [[mesh memberForKey:@"height"] intValue];
	
	if(width <= 0 || height <= 0)
		return YES;	
		
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	if([inputStructure wasUpdated] || [inputSubdivisionAmount wasUpdated] || [inputColor wasUpdated])
	{
		CGFloat r, g, b, a;
		[inputColor getRed:&r green:&g blue:&b alpha:&a];

		unsigned int subdivisions = [inputSubdivisionAmount indexValue];
		
		glNewList(gridList, GL_COMPILE); // rebuild list
		{
			glBegin(GL_QUADS/*_STRIP*/);

			for(y = 0; y < height; ++y)
			{
				//glBegin(GL_LINE_STRIP);
				for(x = 0; x < width; ++x)
				{
					/*glColor4f(colorData[index*4+0], colorData[index*4+1], colorData[index*4+2], colorData[index*4+3]);
					glTexCoord2f(texData[index*2+0], texData[index*2+1]);
					glVertex3f(vertexData[index*3+0], vertexData[index*3+0], vertexData[index*3+0]);

					glColor4f(colorData[index*4+0], colorData[index*4+1], colorData[index*4+2], colorData[index*4+3]);
					glTexCoord2f(texData[index*2+0], texData[index*2+1]);
					glVertex3f(vertexData[index*3+0], vertexData[index*3+0], vertexData[index*3+0]);

					glColor4f(colorData[index*4+0], colorData[index*4+1], colorData[index*4+2], colorData[index*4+3]);
					glTexCoord2f(texData[index*2+0], texData[index*2+1]);
					glVertex3f(vertexData[index*3+0], vertexData[index*3+0], vertexData[index*3+0]);

					glColor4f(colorData[index*4+0], colorData[index*4+1], colorData[index*4+2], colorData[index*4+3]);
					glTexCoord2f(texData[index*2+0], texData[index*2+1]);
					glVertex3f(vertexData[index*3+0], vertexData[index*3+0], vertexData[index*3+0]);*/

					
					/*glColor4fv(colorData+4 * (y*(width+1)+x));
					glTexCoord2fv(texData+2 * (y*(width+1)+x));
					glVertex3fv(vertexData+3 * (y*(width+1)+x));

					glColor4fv(colorData+4 * (y*(width+1)+x+1));
					glTexCoord2fv(texData+2 * (y*(width+1)+x+1));
					glVertex3fv(vertexData+3 * (y*(width+1)+x+1));

					glColor4fv(colorData+4 * ((y+1)*(width+1)+x+1));
					glTexCoord2fv(texData+2 * ((y+1)*(width+1)+x+1));
					glVertex3fv(vertexData+3 * ((y+1)*(width+1)+x+1));

					glColor4fv(colorData+4 * ((y+1)*(width+1)+x));
					glTexCoord2fv(texData+2 * ((y+1)*(width+1)+x));
					glVertex3fv(vertexData+3 * ((y+1)*(width+1)+x));*/

					float color[4][4];
					float vert[4][3];
					float tex[4][2];
					
					/* top, bottom, for each column. first index is 1+x (stupid structure constructor), then width+1+x, */
					vertex = [mesh memberForKey:[NSString stringWithFormat:@"vertex_%i",1+y*(width+1)+x]];
					color[0][0] = [[vertex memberForKey:@"r"] floatValue];
					color[0][1] = [[vertex memberForKey:@"g"] floatValue];
					color[0][2] = [[vertex memberForKey:@"b"] floatValue];
					color[0][3] = [[vertex memberForKey:@"a"] floatValue];
					tex[0][0] = [[vertex memberForKey:@"u"] floatValue];
					tex[0][1] = [[vertex memberForKey:@"v"] floatValue];
					vert[0][0] = [[vertex memberForKey:@"x"] floatValue];
					vert[0][1] = [[vertex memberForKey:@"y"] floatValue];
					vert[0][2] = [[vertex memberForKey:@"z"] floatValue];
					/*glColor4f(
						[[vertex memberForKey:@"r"] floatValue],
						[[vertex memberForKey:@"g"] floatValue],
						[[vertex memberForKey:@"b"] floatValue],
						[[vertex memberForKey:@"a"] floatValue]);
					glTexCoord2f([[vertex memberForKey:@"u"] floatValue],[[vertex memberForKey:@"v"] floatValue]);
					glVertex3f(
						[[vertex memberForKey:@"x"] floatValue],
						[[vertex memberForKey:@"y"] floatValue],
						[[vertex memberForKey:@"z"] floatValue]);*/
						
					vertex = [mesh memberForKey:[NSString stringWithFormat:@"vertex_%i",1+y*(width+1)+x+1]];
					color[1][0] = [[vertex memberForKey:@"r"] floatValue];
					color[1][1] = [[vertex memberForKey:@"g"] floatValue];
					color[1][2] = [[vertex memberForKey:@"b"] floatValue];
					color[1][3] = [[vertex memberForKey:@"a"] floatValue];
					tex[1][0] = [[vertex memberForKey:@"u"] floatValue];
					tex[1][1] = [[vertex memberForKey:@"v"] floatValue];
					vert[1][0] = [[vertex memberForKey:@"x"] floatValue];
					vert[1][1] = [[vertex memberForKey:@"y"] floatValue];
					vert[1][2] = [[vertex memberForKey:@"z"] floatValue];
					/*glColor4f(
						[[vertex memberForKey:@"r"] floatValue],
						[[vertex memberForKey:@"g"] floatValue],
						[[vertex memberForKey:@"b"] floatValue],
						[[vertex memberForKey:@"a"] floatValue]);
					glTexCoord2f([[vertex memberForKey:@"u"] floatValue],[[vertex memberForKey:@"v"] floatValue]);
					glVertex3f(
						[[vertex memberForKey:@"x"] floatValue],
						[[vertex memberForKey:@"y"] floatValue],
						[[vertex memberForKey:@"z"] floatValue]);*/
						
					vertex = [mesh memberForKey:[NSString stringWithFormat:@"vertex_%i",1+(y+1)*(width+1)+x+1]];
					color[2][0] = [[vertex memberForKey:@"r"] floatValue];
					color[2][1] = [[vertex memberForKey:@"g"] floatValue];
					color[2][2] = [[vertex memberForKey:@"b"] floatValue];
					color[2][3] = [[vertex memberForKey:@"a"] floatValue];
					tex[2][0] = [[vertex memberForKey:@"u"] floatValue];
					tex[2][1] = [[vertex memberForKey:@"v"] floatValue];
					vert[2][0] = [[vertex memberForKey:@"x"] floatValue];
					vert[2][1] = [[vertex memberForKey:@"y"] floatValue];
					vert[2][2] = [[vertex memberForKey:@"z"] floatValue];			
					/*glColor4f(
						[[vertex memberForKey:@"r"] floatValue],
						[[vertex memberForKey:@"g"] floatValue],
						[[vertex memberForKey:@"b"] floatValue],
						[[vertex memberForKey:@"a"] floatValue]);
					glTexCoord2f([[vertex memberForKey:@"u"] floatValue],[[vertex memberForKey:@"v"] floatValue]);
					glVertex3f(
						[[vertex memberForKey:@"x"] floatValue],
						[[vertex memberForKey:@"y"] floatValue],
						[[vertex memberForKey:@"z"] floatValue]);*/
				
					vertex = [mesh memberForKey:[NSString stringWithFormat:@"vertex_%i",1+(y+1)*(width+1)+x]];
					color[3][0] = [[vertex memberForKey:@"r"] floatValue];
					color[3][1] = [[vertex memberForKey:@"g"] floatValue];
					color[3][2] = [[vertex memberForKey:@"b"] floatValue];
					color[3][3] = [[vertex memberForKey:@"a"] floatValue];
					tex[3][0] = [[vertex memberForKey:@"u"] floatValue];
					tex[3][1] = [[vertex memberForKey:@"v"] floatValue];
					vert[3][0] = [[vertex memberForKey:@"x"] floatValue];
					vert[3][1] = [[vertex memberForKey:@"y"] floatValue];
					vert[3][2] = [[vertex memberForKey:@"z"] floatValue];			
					/*glColor4f(
						[[vertex memberForKey:@"r"] floatValue],
						[[vertex memberForKey:@"g"] floatValue],
						[[vertex memberForKey:@"b"] floatValue],
						[[vertex memberForKey:@"a"] floatValue]);
					glTexCoord2f([[vertex memberForKey:@"u"] floatValue],[[vertex memberForKey:@"v"] floatValue]);
					glVertex3f(
						[[vertex memberForKey:@"x"] floatValue],
						[[vertex memberForKey:@"y"] floatValue],
						[[vertex memberForKey:@"z"] floatValue]);*/
					
					// simple case -- save a ton of math + code
					if(subdivisions == 0)
					{
						int coord;
						for(coord = 0; coord < 4; ++coord)
						{
							color[coord][0] *= r;
							color[coord][1] *= g;
							color[coord][2] *= b;
							color[coord][3] *= a;
							glColor4fv(color[coord]);
							glTexCoord2fv(tex[coord]);
							glVertex3fv(vert[coord]);
						}
					}
					else // greater than zero (subdivide the above quad into subdivisions*subdivisions equally sized quads)
					{
						float substep = 1.0f / (subdivisions+1.f);
						int xTile, yTile;
						float yAlpha = 0;
						for(yTile = 0; yTile <= subdivisions; ++yTile)
						{
							float xAlpha = 0;
							for(xTile = 0; xTile <= subdivisions; ++xTile)
							{
								glColor4f(r * LERP4(color[0][0],color[1][0],color[2][0], color[3][0], xAlpha, yAlpha),
										  g * LERP4(color[0][1],color[1][1],color[2][1], color[3][1], xAlpha, yAlpha),
										  b * LERP4(color[0][2],color[1][2],color[2][2], color[3][2], xAlpha, yAlpha),
										  a * LERP4(color[0][3],color[1][3],color[2][3], color[3][3], xAlpha, yAlpha));
								glTexCoord2f(LERP4(tex[0][0],tex[1][0],tex[2][0], tex[3][0], xAlpha, yAlpha),
											 LERP4(tex[0][1],tex[1][1],tex[2][1], tex[3][1], xAlpha, yAlpha));
								glVertex3f(LERP4(vert[0][0],vert[1][0],vert[2][0], vert[3][0], xAlpha, yAlpha),
										   LERP4(vert[0][1],vert[1][1],vert[2][1], vert[3][1], xAlpha, yAlpha),
										   LERP4(vert[0][2],vert[1][2],vert[2][2], vert[3][2], xAlpha, yAlpha));

								glColor4f(r * LERP4(color[0][0],color[1][0],color[2][0], color[3][0], xAlpha+substep, yAlpha),
										  g * LERP4(color[0][1],color[1][1],color[2][1], color[3][1], xAlpha+substep, yAlpha),
										  b * LERP4(color[0][2],color[1][2],color[2][2], color[3][2], xAlpha+substep, yAlpha),
										  a * LERP4(color[0][3],color[1][3],color[2][3], color[3][3], xAlpha+substep, yAlpha));
								glTexCoord2f(LERP4(tex[0][0],tex[1][0],tex[2][0], tex[3][0], xAlpha+substep, yAlpha),
											 LERP4(tex[0][1],tex[1][1],tex[2][1], tex[3][1], xAlpha+substep, yAlpha));
								glVertex3f(LERP4(vert[0][0],vert[1][0],vert[2][0], vert[3][0], xAlpha+substep, yAlpha),
										   LERP4(vert[0][1],vert[1][1],vert[2][1], vert[3][1], xAlpha+substep, yAlpha),
										   LERP4(vert[0][2],vert[1][2],vert[2][2], vert[3][2], xAlpha+substep, yAlpha));
								
								glColor4f(r * LERP4(color[0][0],color[1][0],color[2][0], color[3][0], xAlpha+substep, yAlpha+substep),
										  g * LERP4(color[0][1],color[1][1],color[2][1], color[3][1], xAlpha+substep, yAlpha+substep),
										  b * LERP4(color[0][2],color[1][2],color[2][2], color[3][2], xAlpha+substep, yAlpha+substep),
										  a * LERP4(color[0][3],color[1][3],color[2][3], color[3][3], xAlpha+substep, yAlpha+substep));
								glTexCoord2f(LERP4(tex[0][0],tex[1][0],tex[2][0], tex[3][0], xAlpha+substep, yAlpha+substep),
											 LERP4(tex[0][1],tex[1][1],tex[2][1], tex[3][1], xAlpha+substep, yAlpha+substep));
								glVertex3f(LERP4(vert[0][0],vert[1][0],vert[2][0], vert[3][0], xAlpha+substep, yAlpha+substep),
										   LERP4(vert[0][1],vert[1][1],vert[2][1], vert[3][1], xAlpha+substep, yAlpha+substep),
										   LERP4(vert[0][2],vert[1][2],vert[2][2], vert[3][2], xAlpha+substep, yAlpha+substep));
								
								glColor4f(r * LERP4(color[0][0],color[1][0],color[2][0], color[3][0], xAlpha, yAlpha+substep),
										  g * LERP4(color[0][1],color[1][1],color[2][1], color[3][1], xAlpha, yAlpha+substep),
										  b * LERP4(color[0][2],color[1][2],color[2][2], color[3][2], xAlpha, yAlpha+substep),
										  a * LERP4(color[0][3],color[1][3],color[2][3], color[3][3], xAlpha, yAlpha+substep));
								glTexCoord2f(LERP4(tex[0][0],tex[1][0],tex[2][0], tex[3][0], xAlpha, yAlpha+substep),
											 LERP4(tex[0][1],tex[1][1],tex[2][1], tex[3][1], xAlpha, yAlpha+substep));
								glVertex3f(LERP4(vert[0][0],vert[1][0],vert[2][0], vert[3][0], xAlpha, yAlpha+substep),
										   LERP4(vert[0][1],vert[1][1],vert[2][1], vert[3][1], xAlpha, yAlpha+substep),
										   LERP4(vert[0][2],vert[1][2],vert[2][2], vert[3][2], xAlpha, yAlpha+substep));
								
								xAlpha += substep;
							}
							yAlpha += substep;
						}
					}
				}
			}
			glEnd();
		}
		glEndList();
	}
	
	[inputImage setOnOpenGLContext: context unit:GL_TEXTURE0];
	[inputDepth setOnOpenGLContext: context];
	[inputBlending setOnOpenGLContext:context];
	[inputCulling setOnOpenGLContext:context];
	
	glEnable(GL_POINT_SMOOTH);
	glEnable(GL_LINE_SMOOTH);
	
	glCallList(gridList);
	
	[inputCulling unsetOnOpenGLContext:context];
	[inputBlending unsetOnOpenGLContext:context];
	[inputImage unsetOnOpenGLContext: context unit:GL_TEXTURE0];
	
	if([inputWireFrame indexValue] == 1)	// triangles
	{
		glColor4f(1.0,1.0,1.0,1.0);
		for(y = 0; y < height; ++y)
		{
			for(x = 0; x < width; ++x)
			{
				// same as above, but start at 3, and end at 2 (2 extra points) to complete the wireframe
				/* top, bottom, for each columb. first index is 1+x (stupid structure constructor), then width+1+x, */
				glBegin(GL_LINE_STRIP);
				vertex = [mesh memberForKey:[NSString stringWithFormat:@"vertex_%i",1+y*(width+1)+x+1]];
				glVertex3f(
					[[vertex memberForKey:@"x"] floatValue],
					[[vertex memberForKey:@"y"] floatValue],
					[[vertex memberForKey:@"z"] floatValue]);
				vertex = [mesh memberForKey:[NSString stringWithFormat:@"vertex_%i",1+y*(width+1)+x]];
				glVertex3f(
					[[vertex memberForKey:@"x"] floatValue],
					[[vertex memberForKey:@"y"] floatValue],
					[[vertex memberForKey:@"z"] floatValue]);
				vertex = [mesh memberForKey:[NSString stringWithFormat:@"vertex_%i",1+(y+1)*(width+1)+x]];
				glVertex3f(
					[[vertex memberForKey:@"x"] floatValue],
					[[vertex memberForKey:@"y"] floatValue],
					[[vertex memberForKey:@"z"] floatValue]);
				vertex = [mesh memberForKey:[NSString stringWithFormat:@"vertex_%i",1+y*(width+1)+x+1]];
				glVertex3f(
					[[vertex memberForKey:@"x"] floatValue],
					[[vertex memberForKey:@"y"] floatValue],
					[[vertex memberForKey:@"z"] floatValue]);
				vertex = [mesh memberForKey:[NSString stringWithFormat:@"vertex_%i",1+(y+1)*(width+1)+x+1]];
				glVertex3f(
					[[vertex memberForKey:@"x"] floatValue],
					[[vertex memberForKey:@"y"] floatValue],
					[[vertex memberForKey:@"z"] floatValue]);
				vertex = [mesh memberForKey:[NSString stringWithFormat:@"vertex_%i",1+(y+1)*(width+1)+x]];
				glVertex3f(
					[[vertex memberForKey:@"x"] floatValue],
					[[vertex memberForKey:@"y"] floatValue],
					[[vertex memberForKey:@"z"] floatValue]);
				glEnd();
			}
		}
	}
	else if ([inputWireFrame indexValue] == 2)	// quad
	{
		glColor4f(1.0,1.0,1.0,1.0);
		for(y = 0; y < height; ++y)
		{
			for(x = 0; x < width; ++x)
			{
				glBegin(GL_LINE_STRIP);
				vertex = [mesh memberForKey:[NSString stringWithFormat:@"vertex_%i",1+y*(width+1)+x]];
				glVertex3f(
					[[vertex memberForKey:@"x"] floatValue],
					[[vertex memberForKey:@"y"] floatValue],
					[[vertex memberForKey:@"z"] floatValue]);
				vertex = [mesh memberForKey:[NSString stringWithFormat:@"vertex_%i",1+(y+1)*(width+1)+x]];
				glVertex3f(
					[[vertex memberForKey:@"x"] floatValue],
					[[vertex memberForKey:@"y"] floatValue],
					[[vertex memberForKey:@"z"] floatValue]);
				vertex = [mesh memberForKey:[NSString stringWithFormat:@"vertex_%i",1+(y+1)*(width+1)+x+1]];
				glVertex3f(
					[[vertex memberForKey:@"x"] floatValue],
					[[vertex memberForKey:@"y"] floatValue],
					[[vertex memberForKey:@"z"] floatValue]);
				vertex = [mesh memberForKey:[NSString stringWithFormat:@"vertex_%i",1+y*(width+1)+x+1]];
				glVertex3f(
					[[vertex memberForKey:@"x"] floatValue],
					[[vertex memberForKey:@"y"] floatValue],
					[[vertex memberForKey:@"z"] floatValue]);
				vertex = [mesh memberForKey:[NSString stringWithFormat:@"vertex_%i",1+y*(width+1)+x]];
				glVertex3f(
					[[vertex memberForKey:@"x"] floatValue],
					[[vertex memberForKey:@"y"] floatValue],
					[[vertex memberForKey:@"z"] floatValue]);

				/*vertex = [mesh memberForKey:[NSString stringWithFormat:@"vertex_%i",1+y*(width+1)+x]];
				glVertex3f(
					[[vertex memberForKey:@"x"] floatValue],
					[[vertex memberForKey:@"y"] floatValue],
					[[vertex memberForKey:@"z"] floatValue]);
				vertex = [mesh memberForKey:[NSString stringWithFormat:@"vertex_%i",1+(y+1)*(width+1)+x]];
				glVertex3f(
					[[vertex memberForKey:@"x"] floatValue],
					[[vertex memberForKey:@"y"] floatValue],
					[[vertex memberForKey:@"z"] floatValue]);
				vertex = [mesh memberForKey:[NSString stringWithFormat:@"vertex_%i",1+y*(width+1)+x+1]];
				glVertex3f(
					[[vertex memberForKey:@"x"] floatValue],
					[[vertex memberForKey:@"y"] floatValue],
					[[vertex memberForKey:@"z"] floatValue]);
				vertex = [mesh memberForKey:[NSString stringWithFormat:@"vertex_%i",1+(y+1)*(width+1)+x+1]];
				glVertex3f(
					[[vertex memberForKey:@"x"] floatValue],
					[[vertex memberForKey:@"y"] floatValue],
					[[vertex memberForKey:@"z"] floatValue]);
				vertex = [mesh memberForKey:[NSString stringWithFormat:@"vertex_%i",1+(y+1)*(width+1)+x]];
				glVertex3f(
					[[vertex memberForKey:@"x"] floatValue],
					[[vertex memberForKey:@"y"] floatValue],
					[[vertex memberForKey:@"z"] floatValue]);*/
				glEnd();
			}
		}
	}

	if([inputHighlightSelection booleanValue] == TRUE)
	{
		GLfloat origPointSize;
		glGetFloatv(GL_POINT_SIZE,&origPointSize);
		glPointSize(8.0);
		glBegin(GL_POINTS);
		glColor4f(1.0,0.1,0.1,1.0);
				vertex = [mesh memberForKey:[NSString stringWithFormat:@"vertex_%i",[inputSelection indexValue]+1]];
				glVertex3f(
					[[vertex memberForKey:@"x"] floatValue],
					[[vertex memberForKey:@"y"] floatValue],
					[[vertex memberForKey:@"z"] floatValue]);
		glEnd();
		
		glPointSize(origPointSize);
	}

	[inputDepth unsetOnOpenGLContext: context];

	//currentStructure = mesh;

	return YES;
}

@end
