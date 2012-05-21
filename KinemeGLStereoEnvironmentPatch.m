#import <OpenGL/CGLMacro.h>
#import "KinemeGLStereoEnvironmentPatch.h"

@implementation KinemeGLStereoEnvironmentPatch : QCPatch

+ (QCPatchExecutionMode)executionModeWithIdentifier:(id)fp8
{
	return kQCPatchExecutionModeRII1050;
}

+ (QCPatchTimeMode)timeModeWithIdentifier:(id)fp8
{
	return kQCPatchTimeModeTimeBase;
}

+ (BOOL)usesLocalContextForIdentifier:(id)fp8
{
	return TRUE;
}

+ (BOOL)supportsOptimizedExecutionForIdentifier:(id)identifier
{
	return YES;
}

+ (BOOL)isSafe
{
	return YES;
}

- (id)initWithIdentifier:(id)fp8
{
	self=[super initWithIdentifier:fp8];
	if(self)
	{
		[inputZObject setDoubleValue:-10];

		[inputYFov setDoubleValue:45];
		[inputYFov setMinDoubleValue:0.000001];
		[inputZNear setDoubleValue:3];
		[inputZNear setMinDoubleValue:0.000001];
		[inputZScreen setDoubleValue:10];
		[inputZScreen setMinDoubleValue:0.000001];
		[inputZFar setDoubleValue:30];
		[inputZFar setMinDoubleValue:0.000001];

		[inputIOD setDoubleValue:0.1];

		[inputWidth setIndexValue:512];
		[inputHeight setIndexValue:256];
		[[self userInfo] setObject:@"Kineme GL Stereo Environment" forKey:@"name"];
	}

	return self;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	[outputImageLeft setImageValue:nil];
	[outputImageRight setImageValue:nil];

	if([inputBypass booleanValue])
	{
		[self executeSubpatches:time arguments:arguments];
		return YES;
	}

	int pw = [inputWidth indexValue];
	int ph = [inputHeight indexValue];
	if( pw == 0 || ph == 0)
		return YES;

	double IOD = [inputIOD doubleValue];


	QCPixelFormat *pf = [QCPixelFormat defaultClosestPixelFormat:[QCPixelFormat pixelFormatARGB8] withColorSpace:CGColorSpaceCreateDeviceRGB()];
	if( ![pf isSupportedOnContext:[context openGLContext]] )
	{
		NSLog(@"KinemeGLStereoEnvironmentPatch: QCPixelFormat %@ is not supported on this context.",pf);
		//pf = [???? renderingPixelFormat];
		return NO;
	}
	
	NSMutableDictionary *tbOptions = [NSMutableDictionary dictionaryWithDictionary:[context imageManagerDefaultOptions]];
	[tbOptions setObject:[NSNumber numberWithUnsignedInteger:24] forKey:@"texture.depth"];
	[tbOptions setObject:[NSNumber numberWithUnsignedInteger:0] forKey:@"texture.mipmapping"];


	float depthZ = [inputZObject doubleValue];
	double fovy = [inputYFov doubleValue];
	double aspect = (double)pw/(double)ph;
	double nearZ = [inputZNear doubleValue];
	double screenZ = [inputZScreen doubleValue];
	double farZ = [inputZFar doubleValue];

    double top = nearZ*tan((2.*M_PI/360.)*fovy/2.);
    double right = aspect*top;
    double frustumshift = (IOD/2.)*nearZ/screenZ;

	CGColorSpaceRef contextColorspace = [context colorSpace];

	bool invalidateDOD = [self respondsToSelector:@selector(invalidateDodForSubpatches)];
	if(invalidateDOD)
		[self invalidateDodForSubpatches];

	// left
	{
		QCImageTextureBuffer *leftImage = [[context imageManager] createTextureBufferWithFormat:pf
																   target:GL_TEXTURE_2D
															   pixelsWide:pw
															   pixelsHigh:ph
																  options:tbOptions];
		if(!leftImage)
		{
			NSLog(@"KinemeGLStereoEnvironmentPatch: Failed to create QCImageTextureBuffer.");
			return NO;
		}
		QCCGLContext *rt=[leftImage beginRenderTexture:1
											colorSpace:contextColorspace
										 virtualScreen:[[context openGLContext] virtualScreen]];

		if(!rt)
		{
			NSLog(@"KinemeGLStereoEnvironmentPatch: Failed to create QCCGLContext.");
			return NO;
		}
//		[leftImage clearBuffer];
		bool imageFlipped = [leftImage isFlipped];



		id oldOpenGLContext = [[context openGLContext] retain];
		[context setOpenGLContext:rt];
		bool oldFlipped = [context isFlipped];
		[context setFlipped:NO];
		bool oldResetMatrices = [context resetMatrices];
		[context setResetMatrices:YES];

		if( [self beginLocalContext] )
		{
			CGLContextObj cgl_ctx = [context CGLContextObj];
			glMatrixMode(GL_PROJECTION);
			glLoadIdentity();
			glFrustum(-right + frustumshift, right + frustumshift, imageFlipped?top:-top, imageFlipped?-top:top, nearZ, farZ);
			glTranslatef(IOD/2., 0, 0);
			glMatrixMode(GL_MODELVIEW);
			glPushMatrix();
			glLoadIdentity();
				glTranslatef(0, 0, depthZ);
				[self executeSubpatches:time arguments:arguments];
			glPopMatrix();
			[self endLocalContext];
		}

		[context setResetMatrices:oldResetMatrices];
		[context setFlipped:oldFlipped];
		[context setOpenGLContext:oldOpenGLContext];
		[oldOpenGLContext release];

		[leftImage endRenderTexture];
		{
			QCImage *im=[[QCImage alloc] initWithQCImageBuffer:leftImage options:0];
//			[im setMetadata:(id)kCFBooleanTrue forKey:@"disableColorMatching" shouldForward:YES];
			[outputImageLeft setImageValue:im];
			[im release];
		}
		[leftImage release];
	}

	if(invalidateDOD)
	{
		// this pattern is copied from QCReplicator's execute method.
		id rm = object_getIvar(self, class_getInstanceVariable([QCPatch class], "_renderingManager"));
		[rm _nextFrame];
	}


	// right
	{
		QCImageTextureBuffer *rightImage = [[context imageManager] createTextureBufferWithFormat:pf
																	target:GL_TEXTURE_2D
																pixelsWide:pw
																pixelsHigh:ph
																   options:tbOptions];
		if(!rightImage)
		{
			NSLog(@"KinemeGLStereoEnvironmentPatch: Failed to create QCImageTextureBuffer.");
			return NO;
		}
		QCCGLContext *rt=[rightImage beginRenderTexture:1
											 colorSpace:contextColorspace
										  virtualScreen:[[context openGLContext] virtualScreen]];

		if(!rt)
		{
			NSLog(@"KinemeGLStereoEnvironmentPatch: Failed to create QCCGLContext.");
			return NO;
		}
//		[rightImage clearBuffer];
		bool imageFlipped = [rightImage isFlipped];

		id oldOpenGLContext = [[context openGLContext] retain];
		[context setOpenGLContext:rt];
		bool oldFlipped = [context isFlipped];
		[context setFlipped:NO];
		bool oldResetMatrices = [context resetMatrices];
		[context setResetMatrices:YES];

		if( [self beginLocalContext] )
		{
			CGLContextObj cgl_ctx = [context CGLContextObj];
			glMatrixMode(GL_PROJECTION);
			glLoadIdentity();
			glFrustum(-right - frustumshift, right - frustumshift, imageFlipped?top:-top, imageFlipped?-top:top, nearZ, farZ);
			glTranslatef(-IOD/2., 0.0, 0.0);
			glMatrixMode(GL_MODELVIEW);
			glPushMatrix();
			glLoadIdentity();
				glTranslatef(0.0, 0.0, depthZ);
				[self executeSubpatches:time arguments:arguments];
			glPopMatrix();
			[self endLocalContext];
		}

		[context setResetMatrices:oldResetMatrices];
		[context setFlipped:oldFlipped];
		[context setOpenGLContext:oldOpenGLContext];
		[oldOpenGLContext release];

		[rightImage endRenderTexture];
		{
			QCImage *im=[[QCImage alloc] initWithQCImageBuffer:rightImage options:nil];
//			[im setMetadata:(id)kCFBooleanTrue forKey:@"disableColorMatching" shouldForward:YES];
			[outputImageRight setImageValue:im];
			[im release];
		}
		[rightImage release];
	}

	return YES;
}

@end
