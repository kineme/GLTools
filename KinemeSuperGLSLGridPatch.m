#import <OpenGL/CGLMacro.h>
#import "KinemeSuperGLSLGridPatch.h"

@implementation KinemeSuperGLSLGridPatch : QCPatch

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
	if( self = [super initWithIdentifier:fp8])
	{
		//dict = [[NSMutableDictionary alloc] init];
		[inputWidth setDoubleValue: 1.0];
		[inputHeight setDoubleValue: 1.0];
		[inputHResolution setIndexValue: 8];
		[inputVResolution setIndexValue: 8];
		[[self userInfo] setObject:@"Kineme Super GLSL Grid" forKey:@"name"];
	}

	return self;
}

- (void)enable:(QCOpenGLContext*)context
{
	CGLContextObj cgl_ctx = [context CGLContextObj];
	glGenBuffers(2, vbo);
}

- (void)disable:(QCOpenGLContext*)context
{
	CGLContextObj cgl_ctx = [context CGLContextObj];
	glDeleteBuffers(2, vbo);
	vbo[0] = 0;
	vbo[1] = 0;	
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	if(	__builtin_expect([inputWidth doubleValue] <= 0.0 ||
		[inputHeight doubleValue] <= 0.0 ||
		[inputHResolution indexValue] == 0 ||
		[inputVResolution indexValue] == 0, 0))
		return YES;
	
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	unsigned int count, i, j, index;
	unsigned int x, y;
	GLint currentProgram, size;
	GLenum type;
	char name[128];
	float fparams[16];
	int iparams[16];

	QCStructure *uniforms = [inputParameters structureValue];

#if 1
	// build vbo if dimensions changed
	if([inputHResolution wasUpdated] || [inputVResolution wasUpdated] ||
		[inputWidth wasUpdated] || [inputHeight wasUpdated])
	{
		float width = [inputWidth doubleValue];
		float height = [inputHeight doubleValue];
		unsigned int hr = [inputHResolution indexValue], vr = [inputVResolution indexValue];
		faces = hr * vr * 2;
		{
			//NSLog(@"Generating VBO (%ix%i)...",hr,vr);
			float *texCoords, *vertices;
			//w = width;
			//h = height;
			//hres = hr;
			//vres = vr;
			unsigned int tOff = 0, vOff = 0;
			
			texCoords = (float*)malloc(sizeof(float) * faces * 3 * 2);
			vertices =  (float*)malloc(sizeof(float) * faces * 3 * 3);

			for(y=0; y < vr; ++y)
				for(x=0; x < hr; ++x)
				{
					texCoords[tOff++] = (float)x/hr;
					texCoords[tOff++] = (float)y/vr;
					vertices[vOff++] =  (width*(float)x/hr) - width/2.f;
					vertices[vOff++] =  (height*(float)y/vr) - height/2.f;
					vertices[vOff++] = 0.0;
					texCoords[tOff++] = ((float)x+1.f)/hr;
					texCoords[tOff++] = (float)y/vr;
					vertices[vOff++] =  (width*((float)x+1.f)/hr) - width/2.f;
					vertices[vOff++] =  (height*(float)y/vr) - height/2.f;
					vertices[vOff++] = 0.0;
					texCoords[tOff++] = (float)x/hr;
					texCoords[tOff++] = ((float)y+1.f)/vr;
					vertices[vOff++] =  (width*(float)x/hr) - width/2.f;
					vertices[vOff++] =  (height*((float)y+1.f)/vr) - height/2.f;
					vertices[vOff++] = 0.0;

					
					texCoords[tOff++] = ((float)x+1.f)/hr;
					texCoords[tOff++] = (float)y/vr;
					vertices[vOff++] =  (width*((float)x+1.f)/hr) - width/2.f;
					vertices[vOff++] =  (height*(float)y/vr) - height/2.f;
					vertices[vOff++] = 0.0;
					texCoords[tOff++] = ((float)x+1.f)/hr;
					texCoords[tOff++] = ((float)y+1.f)/vr;
					vertices[vOff++] =  (width*((float)x+1.f)/hr) - width/2.f;
					vertices[vOff++] =  (height*((float)y+1.f)/vr) - height/2.f;
					vertices[vOff++] = 0.0;
					texCoords[tOff++] = (float)x/hr;
					texCoords[tOff++] = ((float)y+1.f)/vr;
					vertices[vOff++] =  (width*(float)x/hr) - width/2.f;
					vertices[vOff++] =  (height*((float)y+1.f)/vr) - height/2.f;
					vertices[vOff++] = 0.0;					
					
					//texCoords[2*(y * (hres+1) + x)+0] = (float)x/hres;
					//texCoords[2*(y * (hres+1) + x)+1] = (float)y/vres;
					//vertices[3*(y * (hres+1) + x)+0] = ((float)x/(hres-1.0))-0.5;
					//vertices[3*(y * (hres+1) + x)+1] = ((float)y/(vres-1.0))-0.5;
					//vertices[3*(y * (hres+1) + x)+2] = 0.0;
					
					//glTexCoord2f(((float)x)/h, ((float)y)/v);
					//glVertex3f(((float)x)/h * width - width/2., ((float)y)/v * height - height/2., 0.);
					
					//glTexCoord2f(((float)x+1)/h, ((float)y)/v);
					//glVertex3f(((float)x+1)/h * width - width/2., ((float)y)/v * height - height/2., 0.);
					
					//glTexCoord2f(((float)x+1)/h, ((float)y+1)/v);
					//glVertex3f(((float)x+1)/h * width  - width/2., ((float)y+1)/v * height - height/2., 0.);
					
					//glTexCoord2f(((float)x)/h, ((float)y+1)/v);
					//glVertex3f(((float)x)/h * width - width/2., ((float)y+1)/v * height - height/2., 0.);
				}
			
			
			glBindBuffer(GL_ARRAY_BUFFER, vbo[0]);
			glBufferData(GL_ARRAY_BUFFER, sizeof(float)*faces*3*2, texCoords, GL_STATIC_DRAW_ARB);
			glBindBuffer(GL_ARRAY_BUFFER, vbo[1]);
			glBufferData(GL_ARRAY_BUFFER, sizeof(float)*faces*3*3, vertices, GL_STATIC_DRAW_ARB);
			
			free(vertices);
			free(texCoords);
		}
	}
#endif
	
	// Set Parameters
	glGetIntegerv( GL_CURRENT_PROGRAM, &currentProgram );
	if(__builtin_expect(currentProgram && uniforms,1))	// 0 if we've got no GLSL shader in place
	{
		id value;
		glGetProgramiv(currentProgram,GL_ACTIVE_UNIFORMS, (int*)&count);
		
		for(i=0; i<count; ++i)
		{
			glGetActiveUniform(currentProgram,i,127,NULL,&size, &type,name);
			value = [uniforms memberForKey:[NSString stringWithCString:name encoding:NSASCIIStringEncoding]];
			if(value)
			{
				index = glGetUniformLocation(currentProgram, name);
				//NSLog(@"matched %@ with %s",value, name);
				if([value isKindOfClass: [QCStructure class]])
				{
					int subcount = [value count];
					for(j=0; j<subcount; ++j)
					{
						id subvalue = [value memberAtIndex: j];
						if(__builtin_expect([subvalue respondsToSelector:@selector(doubleValue)],1))
						{
							fparams[j] = [subvalue doubleValue];
							iparams[j] = fparams[j];
						}
					}					
				}
				else if([value isKindOfClass: [NSNumber class]])
				{
					fparams[0] = [value doubleValue];
					iparams[0] = fparams[0];
				}
				else if([value isKindOfClass: [NSColor class]])
				{
					//NSLog(@"it's a color!");
					CGFloat r,g,b,a;
					[value	getRed:&r
							green:&g
							 blue:&b
							alpha:&a];
					iparams[0] = fparams[0] = r;
					iparams[1] = fparams[1] = g;
					iparams[2] = fparams[2] = b;
					iparams[3] = fparams[3] = a;				
				}
				
				switch(type)
				{				
					case GL_FLOAT:
						//NSLog(@"setting GL_FLOAT [%@] @ %i",key,index);
						glUniform1f(index, fparams[0]);
						break;
					case GL_FLOAT_VEC2:
						glUniform2fv(index, size, fparams);
						break;
					case GL_FLOAT_VEC3:
						glUniform3fv(index, size, fparams);
						break;
					case GL_FLOAT_VEC4:
						glUniform4fv(index, size, fparams);
						break;
					case GL_INT_VEC2:
						glUniform2iv(index, size, iparams);
						break;
					case GL_INT_VEC3:
						glUniform3iv(index, size, iparams);
						break;
					case GL_INT_VEC4:
						glUniform4iv(index, size, iparams);
						break;
					case GL_INT:
					case GL_BOOL:
					case GL_SAMPLER_1D:
					case GL_SAMPLER_2D:
						glUniform1iv(index, size, iparams);
						break;
					case GL_FLOAT_MAT2:
						glUniformMatrix2fv(index, size, 0, fparams);
						break;
					case GL_FLOAT_MAT3:
						glUniformMatrix3fv(index, size, 0, fparams);
						break;
					case GL_FLOAT_MAT4:
						//NSLog(@"setting matrix...");
						glUniformMatrix4fv(index, size, 0, fparams);
						break;
					default:	// unknown type;  do nothing for now
						//NSLog(@"type: %x", type);
						break;
				}
			}
		}
	}
	
	[inputBlending setOnOpenGLContext: context];
	[inputDepthTest setOnOpenGLContext: context];
	[inputCulling setOnOpenGLContext: context];
	
	// render the grid
	glPushMatrix();
	glTranslated(	[inputXPosition doubleValue],
					[inputYPosition doubleValue],
					[inputZPosition doubleValue]);

	glRotated([inputXRotation doubleValue],1.0,0.0,0.0);
	glRotated([inputYRotation doubleValue],0.0,1.0,0.0);
	glRotated([inputZRotation doubleValue],0.0,0.0,1.0);
	
#if 1
	// VBO renderer
	glNormal3f(0.,0.,1.);
	glColor4f(1.0,1.0,1.0,1.0);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	glBindBuffer(GL_ARRAY_BUFFER, vbo[0]);
	glTexCoordPointer(2, GL_FLOAT, 0, NULL);
	glBindBuffer(GL_ARRAY_BUFFER, vbo[1]);
	glVertexPointer(3, GL_FLOAT, 0, NULL);
	glDrawArrays( GL_TRIANGLES, 0, 3*faces);
	
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_VERTEX_ARRAY);
#endif

#if 0
	{
	// immediate mode!? lame!  oh well, works for now	
	hres = [inputHResolution indexValue];
	vres = [inputVResolution indexValue];

	glBegin(GL_QUADS);
	glNormal3f(0.,0.,1.);
	glColor4f(1.0,1.0,1.0,1.0);
	for(y=0; y < vres; ++y)
	{
		//glBegin(GL_TRIANGLE_STRIP);
		for(x=0; x < hres; ++x)
		{
			glTexCoord2f(((float)x)/hres, ((float)y)/vres);
			glVertex3f(((float)x)/hres * width - width/2.f, ((float)y)/vres * height - height/2.f, 0.f);
			
			glTexCoord2f(((float)x+1.)/hres, ((float)y)/vres);
			glVertex3f(((float)x+1.)/hres * width - width/2.f, ((float)y)/vres * height - height/2.f, 0.f);

			glTexCoord2f(((float)x+1.)/hres, ((float)y+1.f)/vres);
			glVertex3f(((float)x+1.)/hres * width  - width/2.f, ((float)y+1.)/vres * height - height/2.f, 0.f);
						
			glTexCoord2f(((float)x)/hres, ((float)y+1.f)/vres);
			glVertex3f(((float)x)/hres * width - width/2.f, ((float)y+1)/vres * height - height/2.f, 0.f);
		}
		//glEnd();
		//glTexCoord2f(((float)x+1.)/hres, ((float)y+1.)/vres);
		//glVertex3f(((float)x)/hres * width  - width/2., ((float)y+1.)/vres * height - height/2., 0.);		
	}
	glEnd();
	}
#endif
	
	
	if(currentProgram && uniforms)	// restore values, if program's in place
	{
	}

	glPopMatrix();

	[inputBlending unsetOnOpenGLContext: context];
	[inputDepthTest unsetOnOpenGLContext: context];
	[inputCulling unsetOnOpenGLContext: context];


	return YES;
}

@end
