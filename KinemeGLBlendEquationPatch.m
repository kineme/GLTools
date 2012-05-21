/*
 *  GLBlendEquation.m
 *  GLTools
 *
 *  Created by Christopher Wright on 9/17/08.
 *  Copyright (c) 2008 Kosada Incorporated. All rights reserved.
 *
 */

#import <OpenGL/CGLMacro.h>
#import "KinemeGLBlendEquationPatch.h"

@implementation KinemeGLBlendEquationPatch : QCPatch

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
		[inputRGBEquation setMaxIndexValue: 4];
		[inputAlphaEquation setMaxIndexValue: 4];
		[[self userInfo] setObject:@"Kineme GL Blend Equation" forKey:@"name"];
	}
	
	return self;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	GLint rgbEqu, alphaEqu, oldRGBEqu, oldAlphaEqu;
	
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	glGetIntegerv(GL_BLEND_EQUATION_RGB, &oldRGBEqu);
	glGetIntegerv(GL_BLEND_EQUATION_ALPHA, &oldAlphaEqu);
		
	switch([inputRGBEquation indexValue])
	{
		case 0:
			rgbEqu = GL_FUNC_ADD;
			break;
		case 1:
			rgbEqu = GL_FUNC_SUBTRACT;
			break;
		case 2:
			rgbEqu = GL_FUNC_REVERSE_SUBTRACT;
			break;
		case 3:
			rgbEqu = GL_MIN;
			break;
		case 4:
			rgbEqu = GL_MAX;
	}
	switch([inputAlphaEquation indexValue])
	{
		case 0:
			alphaEqu = GL_FUNC_ADD;
			break;
		case 1:
			alphaEqu = GL_FUNC_SUBTRACT;
			break;
		case 2:
			alphaEqu = GL_FUNC_REVERSE_SUBTRACT;
			break;
		case 3:
			alphaEqu = GL_MIN;
			break;
		case 4:
			alphaEqu = GL_MAX;
	}
	
	glBlendEquationSeparate(rgbEqu, alphaEqu);
	
	[self executeSubpatches:time arguments:arguments];
	
	glBlendEquationSeparate(oldRGBEqu, oldAlphaEqu);
	
	return YES;
}

@end
