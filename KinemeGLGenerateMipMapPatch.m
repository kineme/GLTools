//
//  KinemeGLGenerateMipMapPatch.m
//  GLTools
//
//  Created by Christopher Wright on 12/17/08.
//  Copyright 2008 Kosada Incorporated. All rights reserved.
//

#import <OpenGL/CGLMacro.h>
#import "KinemeGLGenerateMipMapPatch.h"

@interface NSObject (GLToolsWarningSuppression)
-(id)provider;
-(id)imageBuffer;
-(GLint)name;
@end

@implementation KinemeGLGenerateMipMapPatch
+ (QCPatchExecutionMode)executionModeWithIdentifier:(id)fp8
{
	return 0;
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
	if(self = [super initWithIdentifier: fp8])
		[[self userInfo] setObject:@"Kineme GL Generate MipMap" forKey:@"name"];
	return self;
}

- (BOOL)setup:(QCOpenGLContext*)context
{
	double maxAniso;
	CGLContextObj cgl_ctx = [context CGLContextObj];
	glGetDoublev(GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, &maxAniso);
	[inputAniso setMaxDoubleValue: maxAniso];
	[inputAniso setMinDoubleValue: 1.0];
	return YES;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	[outputImage setImageValue: nil];
	QCImage *img;
	if(img = [inputImage imageValue])
	{
		CGLContextObj cgl_ctx = [context CGLContextObj];

		[img setMetadata:[NSNumber numberWithInt:32] forKey:@"textureLevels" shouldForward:YES];
		[img setMetadata:[NSNumber numberWithInt:GL_TEXTURE_2D] forKey:@"textureTarget" shouldForward:YES];
		
		//NSLog(@"md: %@", [[inputImage imageValue] allMetadata]);
		// Here we rely on a slight hack:
		//   * interrogating objects to get a texture name is ridiculous (with the 80 zillion qc image classes/providers out there)
		//   * we can't use the GL to ask which name is bound to which texture unit (AFAICT)
		// So, to generate mipmaps, we instead rely on the GL's state machine:  when a texture is set on a context, it's bound.
		// We take advantage of that binding, and don't manage it ourselves at all.  (no glBindTexture(...)).
		[inputImage setOnOpenGLContext:context unit:GL_TEXTURE0];	// this performs the bind for us, and GL-ifies the image if necessary.
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, [inputAniso doubleValue]);
		glGenerateMipmapEXT(GL_TEXTURE_2D);
		[inputImage unsetOnOpenGLContext: context unit:GL_TEXTURE0];
	
		[outputImage setImageValue: [inputImage imageValue]];
	}
						 
	return YES;
}


@end
