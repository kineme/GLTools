/*
 *  GLClearDepth.m
 *  GLTools
 *
 *  Created by Christopher Wright on 9/17/08.
 *  Copyright (c) 2008 Kosada Incorporated. All rights reserved.
 *
 */

#import <OpenGL/CGLMacro.h>

#import "KinemeGLClearDepthPatch.h"

@implementation KinemeGLClearDepthPatch : QCPatch

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
		[inputDepth setDoubleValue: 1];
		[[self userInfo] setObject:@"Kineme GL Clear Depth" forKey:@"name"];
	}
	
	return self;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	GLdouble depth;
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	glGetDoublev(GL_DEPTH_CLEAR_VALUE, &depth);
	
	glClearDepth([inputDepth doubleValue]);
	glClear(GL_DEPTH_BUFFER_BIT);
	glClearDepth(depth);

	return YES;
}

@end
