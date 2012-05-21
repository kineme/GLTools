/*
 *  KinemeGLRenderInImageWithDepthPatch.m
 *  GLTools
 *
 *  Created by Christopher Wright on 10/26/09.
 *  Copyright (c) 2009 Kosada Incorporated. All rights reserved.
 *
 */

#import <OpenGL/CGLMacro.h>
#import "KinemeGLRenderInImageWithDepthPatch.h"

@implementation KinemeGLRenderInImageWithDepthPatch : QCPatch

+ (QCPatchExecutionMode)executionModeWithIdentifier:(id)fp8
{
	return 3;
}

+ (BOOL)usesLocalContextForIdentifier:(id)fp8
{
	return TRUE;
}

+ (BOOL)isSafe
{
	return YES;
}

- (id)initWithIdentifier:(id)fp8
{
	if(self=[super initWithIdentifier:fp8])
	{
		[inputWidth setIndexValue:512];
		[inputHeight setIndexValue:256];
		
		[[self userInfo] setObject:@"Kineme GL Render In Image With Depth" forKey:@"name"];
	}
	
	return self;
}

- (void)cleanup:(QCOpenGLContext *)context
{
	[image release];
	image = nil;
	
	if(depthTexture)
	{
		CGLContextObj cgl_ctx = [context CGLContextObj];
		glDeleteTextures(1, &depthTexture);
		depthTexture = 0;
	}
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	QCPixelFormat *pf = [QCPixelFormat defaultClosestPixelFormat:[QCPixelFormat pixelFormatARGB8] withColorSpace:CGColorSpaceCreateDeviceRGB()];
	if( ![pf isSupportedOnContext:[context openGLContext]] )
	{
		NSLog(@"KinemeGLStereoEnvironmentPatch: Selected QCPixelFormat is not supported on this context.");
		//pf = [???? renderingPixelFormat];
		return NO;
	}
	
	unsigned int width = [inputWidth indexValue];
	unsigned int height = [inputHeight indexValue];
	
	if(!image || !depthTexture || [inputWidth wasUpdated] || [inputHeight wasUpdated])
	{
		[image release];

		NSMutableDictionary *tbOptions = [NSMutableDictionary dictionaryWithDictionary:[context imageManagerDefaultOptions]];
		[tbOptions setObject:[NSNumber numberWithUnsignedInteger:24] forKey:@"texture.depth"];

		image = [[context imageManager] createTextureBufferWithFormat:pf
															   target:GL_TEXTURE_2D
														   pixelsWide:width
														   pixelsHigh:height
															  options:tbOptions];
		if(!image)
		{
			NSLog(@"KinemeGLRenderInImageWithDepthPatch: failed to create texture buffer.");
			return NO;
		}
		
		CGLContextObj cgl_ctx = [context CGLContextObj];
		
		if(depthTexture)
			glDeleteTextures(1, &depthTexture);
		
		glGenTextures(1, &depthTexture);
		glBindTexture(GL_TEXTURE_RECTANGLE_ARB, depthTexture);
		glTexImage2D(GL_TEXTURE_RECTANGLE_ARB,
					 0,
					 GL_DEPTH_COMPONENT,
					 width,
					 height,
					 0,
					 GL_DEPTH_COMPONENT,
					 GL_FLOAT,
					 NULL);
	}
	
	QCCGLContext *newContext = [image beginRenderTexture:1
										   colorSpace:[context colorSpace]
										virtualScreen:[[context openGLContext] virtualScreen]];
	[image clearBuffer];
	
	id oldContext = [[context openGLContext] retain];
	[context setOpenGLContext: newContext];
	[context setFlipped:YES];
	bool oldResetMatrices = [context resetMatrices];
	[context setResetMatrices:YES];
	
	if([self beginLocalContext])
	{
		[self executeSubpatches:time arguments:arguments];
		[self endLocalContext];
	}	
	[context setResetMatrices:oldResetMatrices];
	[context setFlipped:YES];
	[context setOpenGLContext:oldContext];
	[oldContext release];
	
	
	CGLContextObj cgl_ctx = [newContext CGLContextObj];
	//CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
	CGColorSpaceRef cs = CGColorSpaceCreateWithName(kCGColorSpaceGenericGray);
	
	glBindTexture(GL_TEXTURE_RECTANGLE_ARB, depthTexture);
	glCopyTexSubImage2D(GL_TEXTURE_RECTANGLE_ARB, 0,
						0, 0, 0, 0, [inputWidth indexValue], [inputHeight indexValue]);

	QCImageTextureBuffer *depth = [[QCImageTextureBuffer alloc] initWithTextureName:depthTexture
																	releaseCallback:nil
																		releaseInfo:nil
																			context:newContext
																			 format:[QCPixelFormat pixelFormatIf]
																			 target:GL_TEXTURE_RECTANGLE_ARB
																			  width:width
																			 height:height
																	   mipmapLevels:0
																			flipped:YES
																		 colorSpace:cs
																			options:nil];

	CGColorSpaceRelease(cs);
	
	QCImage *img = [[QCImage alloc] initWithQCImageBuffer:depth options:nil];
	[img setMetadata:(id)kCFBooleanTrue forKey:@"disableColorMatching" shouldForward:YES];
	[outputDepthImage setImageValue:img];
	[img release];
	[depth release];
	
	[image endRenderTexture];
	
	// colorbuffer output
	img = [[QCImage alloc] initWithQCImageBuffer:image options:nil];
	[img setMetadata:(id)kCFBooleanTrue forKey:@"disableColorMatching" shouldForward:YES];
	[outputImage setImageValue:img];
	[img release];
	
	return YES;
}

@end
