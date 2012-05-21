/*
 *  GLShadeModel.m
 *  GLTools
 *
 *  Created by Christopher Wright on 9/17/08.
 *  Copyright (c) 2008 Kosada Incorporated. All rights reserved.
 *
 */

#import <OpenGL/CGLMacro.h>
#import "KinemeGLShadeModelPatch.h"

@implementation KinemeGLShadeModelPatch : QCPatch

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
	if(self=[super initWithIdentifier:fp8])
	{
		[inputMode setMaxIndexValue: 1];
		[[self userInfo] setObject:@"Kineme GL Shade Model" forKey:@"name"];
	}
	
	return self;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	GLint mode, oldMode;
	
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	switch([inputMode indexValue])
	{
		case 0:
			mode = GL_SMOOTH;
			break;
		case 1:
			mode = GL_FLAT;
	}
	
	glGetIntegerv(GL_SHADE_MODEL,&oldMode);
	if(oldMode != mode)
		glShadeModel(mode);
	[self executeSubpatches:time arguments:arguments];
	if(oldMode != mode)
		glShadeModel(oldMode);
	
	return YES;
}

@end
