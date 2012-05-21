/*
 *  KinemeGLInverseRotation.m
 *  GLTools
 *
 *  Created by Christopher Wright on 5/25/09.
 *  Copyright (c) 2009 Kosada Incorporated. All rights reserved.
 *
 */

#import <OpenGL/CGLMacro.h>
#import "KinemeGLInverseRotation.h"
//#import "KinemeGLInverseRotationUI.h"


@implementation KinemeGLInverseRotation : QCPatch

+ (QCPatchExecutionMode)executionModeWithIdentifier:(id)fp8
{
	return 0;
}

+ (BOOL)allowsSubpatchesWithIdentifier:(id)fp8
{
	return NO;
}

+ (QCPatchTimeMode)timeModeWithIdentifier:(id)identifier
{
	return 1;
}

+ (BOOL)isSafe
{
	return YES;
}

- (id)initWithIdentifier:(id)fp8
{
	if(self=[super initWithIdentifier:fp8])
	{
		[[self userInfo] setObject:@"Kineme GL Inverse Rotation" forKey:@"name"];
	}
	
	return self;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	CGLContextObj cgl_ctx = [context CGLContextObj];

	float m[16];
	
	glGetFloatv(GL_MODELVIEW_MATRIX, (GLfloat*)&m);
	
	[outputZRotation setDoubleValue: -atan2f(m[1],m[0])*180.f/M_PI];
	[outputYRotation setDoubleValue:  asinf(m[2])*180.f/M_PI];
	[outputXRotation setDoubleValue: -atan2f(m[6],m[10])*180.f/M_PI];
	
	return YES;
}

@end
