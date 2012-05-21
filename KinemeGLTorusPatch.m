/*
 *  KinemeGLTorusPatch.m
 *  GLTools
 *
 *  Created by Christopher Wright on 10/8/08.
 *  Copyright (c) 2008 Kosada Incorporated. All rights reserved.
 *
 */

#import <OpenGL/CGLMacro.h>
#import "KinemeGLTorusPatch.h"

@implementation KinemeGLTorusPatch : QCPatch

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
	if(self=[super initWithIdentifier:fp8])
	{
		// setup sane defaults, for a pretty torus
		[inputMajorRadius setDoubleValue: 0.75];
		[inputMinorRadius setDoubleValue: 0.2];
		[inputStacks setIndexValue: 50];
		[inputStacks setMaxIndexValue: 512];
		[inputSlices setIndexValue: 50];
		[inputSlices setMaxIndexValue: 512];
		[inputCulling setIndexValue: 1];
		[inputDepth setIndexValue: 1];
		[[self userInfo] setObject:@"Kineme GL Torus" forKey:@"name"];
	}
	
	return self;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	[inputCulling setOnOpenGLContext: context];
	[inputDepth setOnOpenGLContext: context];
	[inputBlending setOnOpenGLContext: context];
	[inputColor setOnOpenGLContext: context];
	[inputImage setOnOpenGLContext: context unit:GL_TEXTURE0];
	
	int numMajor = [inputSlices indexValue];
	int numMinor = [inputStacks indexValue];
	
	float minorRadius = [inputMinorRadius doubleValue];
	float majorRadius = [inputMajorRadius doubleValue];
	
	float majorStep = 2.0f * (float)M_PI / numMajor;
	float minorStep = 2.0f * (float)M_PI / numMinor;
	int i, j;
	
	glPushMatrix();
	
	CGFloat matrix[16];
	
	QCGLMakeTransformationMatrix(matrix,
								 [inputXRotation doubleValue],[inputYRotation doubleValue],[inputZRotation doubleValue],
								 [inputXPosition doubleValue],[inputYPosition doubleValue],[inputZPosition doubleValue]);
	
	KIGLMultMatrix(matrix);
		
	GLfloat recipNumMinor = 1.f / (GLfloat) numMinor;
	GLfloat recipNumMajor = 1.f / (GLfloat) numMajor;
	
	GLfloat u = 0;
	GLfloat u1 = recipNumMajor;
	float a1 = majorStep;

	GLfloat x0 = 1.0;
	GLfloat y0 = 0.0;
	
	for (i = 0; i < numMajor; ++i) {
		GLfloat x1 = cosf(a1);
		GLfloat y1 = sinf(a1);
		
		float b = 0;
		GLfloat v = 0;
		
		glBegin(GL_TRIANGLE_STRIP);
		for (j = 0; j <= numMinor; ++j) {
			GLfloat c = cosf(b);
			GLfloat r = minorRadius * c + majorRadius;
			GLfloat z = sinf(b);
			GLfloat sz = minorRadius * z;
			
			glNormal3f(x0 * c, y0 * c, z);
			glTexCoord2f(u, v);
			glVertex3f(x0 * r, y0 * r, sz);
			
			glNormal3f(x1 * c, y1 * c, z);
			glTexCoord2f(u1, v);
			glVertex3f(x1 * r, y1 * r, sz);
			
			b += minorStep;
			v += recipNumMinor;
		}
		glEnd();
		u = u1;
		u1 += recipNumMajor;
		a1 += majorStep;
		x0 = x1;
		y0 = y1;
	}
	glPopMatrix();

	[inputImage unsetOnOpenGLContext: context unit:GL_TEXTURE0];
	[inputColor unsetOnOpenGLContext: context];
	[inputBlending unsetOnOpenGLContext: context];
	[inputDepth unsetOnOpenGLContext: context];
	[inputCulling unsetOnOpenGLContext: context];
	
	return YES;
}

@end
