/*
 *  GLLookAt.m
 *  GLTools
 *
 *  Created by Christopher Wright on 9/3/08.
 *  Copyright (c) 2008 Kosada Incorporated. All rights reserved.
 *
 */

#import "KinemeGLLookAtPatch.h"
#import <OpenGL/CGLMacro.h>
#import <OpenGL/OpenGL.h>

static inline void crossProduct(float *a, float *b, float *result)
{
	//x = y1*z2 - z1*y2
	//y = z1*x2 - x1*z2
	//z = x1*y2 - y1*x2	
	result[0] = a[1]*b[2] - a[2]*b[1];
	result[1] = a[2]*b[0] - a[0]*b[2];
	result[2] = a[0]*b[1] - a[1]*b[0];
}

@implementation KinemeGLLookAtPatch : QCPatch

+ (QCPatchExecutionMode)executionModeWithIdentifier:(id)fp8
{
	return kQCPatchExecutionModeConsumer;
}

+ (BOOL)allowsSubpatchesWithIdentifier:(id)fp8
{
	return YES;
}

- (id)initWithIdentifier:(id)fp8
{
	if(self=[super initWithIdentifier:fp8])
	{
		[inputEyeX setDoubleValue: 0.0];
		[inputEyeY setDoubleValue: 0.0];
		[inputEyeZ setDoubleValue: 0.0];
		
		[inputCenterX setDoubleValue: 0.0];
		[inputCenterY setDoubleValue: 0.0];
		[inputCenterZ setDoubleValue: -1.0];
		
		[inputUpX setDoubleValue: 0.0];
		[inputUpY setDoubleValue: 1.0];
		[inputUpZ setDoubleValue: 0.0];
		
		[[self userInfo] setObject:@"Kineme GL Look At" forKey:@"name"];
	}
	
	return self;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	// see http://pyopengl.sourceforge.net/documentation/manual/gluLookAt.3G.html for details
	
	float	m[16],
			f[3], s[3], u[3],
			eye[3] = {[inputEyeX doubleValue],[inputEyeY doubleValue],[inputEyeZ doubleValue]},
			up[3] = {[inputUpX doubleValue], [inputUpY doubleValue], [inputUpZ doubleValue]},
			center[3] = {[inputCenterX doubleValue], [inputCenterY doubleValue], [inputCenterZ doubleValue]};
	
	f[0] = center[0] - eye[0];
	f[1] = center[1] - eye[1];
	f[2] = center[2] - eye[2];
	
	float len = 1.0f/sqrtf(f[0]*f[0]+f[1]*f[1]+f[2]*f[2]);
	f[0] *= len;
	f[1] *= len;
	f[2] *= len;
	
	len = 1.0f/sqrtf(up[0]*up[0]+up[1]*up[1]+up[2]*up[2]);
	up[0] *= len;
	up[1] *= len;
	up[2] *= len;
	
	crossProduct(f, up, s);
	crossProduct(s, f, u);

	m[ 0] = s[0]; m[ 1] = u[0]; m[ 2] = -f[0];
	m[ 4] = s[1]; m[ 5] = u[1]; m[ 6] = -f[1];
	m[ 8] = s[2]; m[ 9] = u[2]; m[10] = -f[2];
	
	m[3] = m[7] = m[11] = m[12] = m[13] = m[14] = 0.0;
	m[15] = 1;
	
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glLoadIdentity();
	glLoadMatrixf(m);
	glTranslated (-eye[0], -eye[1], -eye[2]);
	
	[self executeSubpatches:time arguments:arguments];
	
	glPopMatrix();

	
	return YES;
}

@end
