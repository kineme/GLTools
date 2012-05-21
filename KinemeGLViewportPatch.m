/*
 *  GLViewport.m
 *  GLTools
 *
 *  Created by Christopher Wright on 9/17/08.
 *  Copyright (c) 2008 Kosada Incorporated. All rights reserved.
 *
 */

#import <OpenGL/CGLMacro.h>
#import "KinemeGLViewportPatch.h"

@implementation KinemeGLViewportPatch : QCPatch

+ (QCPatchExecutionMode)executionModeWithIdentifier:(id)fp8
{
	return 1;
}

+ (BOOL)allowsSubpatchesWithIdentifier:(id)fp8
{
	return YES;
}

+ (BOOL)isSafe
{
	return YES;
}

- (id)initWithIdentifier:(id)fp8
{
	if(self = [super initWithIdentifier: fp8])
	{
		[inputW setIndexValue: 512];
		[inputH setIndexValue: 512];
		[[self userInfo] setObject:@"Kineme GL Viewport" forKey:@"name"];
	}
	return self;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	GLint dims[4];
	
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	glGetIntegerv(GL_VIEWPORT, dims);
	
	glViewport([inputX indexValue], [inputY indexValue],
			   [inputW indexValue], [inputH indexValue]);
	
	[self executeSubpatches:time arguments:arguments];
	
	glViewport(dims[0], dims[1], dims[2], dims[3]);
	

	return YES;
}

@end
