#import "KinemeGLReadPixelsPatch.h"
#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/CGLMacro.h>

@implementation KinemeGLReadPixelsPatch : QCPatch

+ (QCPatchExecutionMode)executionModeWithIdentifier:(id)fp8
{
	return kQCPatchExecutionModeProcessor;
}
+ (BOOL)allowsSubpatchesWithIdentifier:(id)fp8
{
	return NO;
}
+ (QCPatchTimeMode)timeModeWithIdentifier:(id)fp8
{
	return kQCPatchTimeModeTimeBase;
}

+ (BOOL)isSafe
{
	return YES;
}

- (id)initWithIdentifier:(id)fp8
{
	if(self=[super initWithIdentifier:fp8])
	{
		width = 0;
		height = 0;
		[inputSource setMaxIndexValue: 1];
		[inputRecord setBooleanValue:YES];
		[[self userInfo] setObject:@"Kineme GL Read Pixels" forKey:@"name"];
	}

	return self;
}

- (void)enable:(QCOpenGLContext *)context
{
	CGLContextObj cgl_ctx = [context CGLContextObj];
	glGenTextures(1, &texture);
}

- (void)disable:(QCOpenGLContext *)context
{
	CGLContextObj cgl_ctx = [context CGLContextObj];
	glDeleteTextures(1, &texture);
	width = 0;
	height = 0;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	if([inputRecord booleanValue] == NO)
		return YES;
	
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	GLint viewPort[4];
	
	glGetIntegerv(GL_VIEWPORT, viewPort);
		
	if(width != viewPort[2] || height != viewPort[3] || [inputSource wasUpdated])
	{
		glDeleteTextures(1, &texture);
		glGenTextures(1, &texture);

		width = viewPort[2];
		height = viewPort[3];
		
		glBindTexture(GL_TEXTURE_RECTANGLE_ARB, texture);
		if([inputSource indexValue])	// depth buffer
		{
			
			glTexImage2D( GL_TEXTURE_RECTANGLE_ARB, 0, GL_DEPTH_COMPONENT, width, height, 0,
							 GL_DEPTH_COMPONENT, GL_FLOAT, NULL);
		}
		else	// color buffer
		{
			//glTexImage2D( GL_TEXTURE_RECTANGLE_ARB, 0, GL_RGBA, width, height, 0,
			//			 GL_RGBA, GL_UNSIGNED_BYTE, NULL);
			glTexImage2D( GL_TEXTURE_RECTANGLE_ARB, 0, GL_RGBA, width, height, 0,
						 GL_RGBA, GL_UNSIGNED_BYTE, NULL);
		}
	}	
	
	glBindTexture(GL_TEXTURE_RECTANGLE_ARB, texture);
	// magically copies from the bound stuff above (not sure I'm a fan of opengl anymore....)
	glCopyTexSubImage2D(GL_TEXTURE_RECTANGLE_ARB, 0, 0, 0, viewPort[0], viewPort[1], width, height);
	
	CIImage *ciimg = [[CIImage allocWithZone:NULL] initWithTexture: texture size: CGSizeMake(width, height) flipped: [inputIsFlipped booleanValue] colorSpace: nil];
	QCImage *qcglOut = [[QCImage allocWithZone:NULL] initWithCIImage: ciimg options: nil];
	/*QCImageTextureBuffer *itb = [[QCImageTextureBuffer alloc] initWithTextureName:texture 
																  releaseCallback: NULL
																	  releaseInfo: NULL
																		  context: [context openGLContext]
																		   format: [QCPixelFormat pixelFormatIf]
																		   target: GL_TEXTURE_RECTANGLE_ARB
																		  flipped: NO
																	   colorSpace: CGColorSpaceCreateWithName(kCGColorSpaceGenericGray)
																		  options: nil];*/
	//QCImage *qcglOut = [[QCImage alloc] initWithQCImageBuffer:itb options:nil];
	[qcglOut setMetadata:(NSNumber *)kCFBooleanTrue forKey:@"disableColorMatching" shouldForward:YES];
	
	[outputImage setImageValue:qcglOut];
	[qcglOut release];
	[ciimg release];
	
	return YES;
}

@end
