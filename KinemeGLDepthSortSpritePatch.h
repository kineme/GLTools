

#import "KinemeGLDepthSortEnvironmentPatch.h"
#import "KinemeGLRenderer.h"

@interface KinemeGLDepthSortLightweightSprite : NSObject <KinemeGLDepthRenderer>
{
	float width, height;
	double matrix[16];
	double depth;
	QCImage *image;
	float color[4];
	unsigned int blending, depthTesting, culling;
	QCOpenGLPort_Image *imagePort;
	QCOpenGLPort_Blending *blendPort;
	QCOpenGLPort_ZBuffer *depthPort;
	QCOpenGLPort_Culling *cullingPort;
	
}
@property (readwrite, nonatomic) double depth;
@property (readwrite, nonatomic) float width, height;
@property (readwrite, nonatomic, retain) QCImage *image;
@property (readwrite, nonatomic) unsigned int blending, depthTesting, culling;
@property (readwrite, assign, nonatomic) QCOpenGLPort_Image *imagePort;
@property (readwrite, assign, nonatomic) QCOpenGLPort_Blending *blendPort;
@property (readwrite, assign, nonatomic) QCOpenGLPort_ZBuffer *depthPort;
@property (readwrite, assign, nonatomic) QCOpenGLPort_Culling *cullingPort;

@end

@interface KinemeGLDepthSortSpritePatch : QCPatch
{
	QCNumberPort *inputX;
	QCNumberPort *inputY;
	QCNumberPort *inputZ;
	QCNumberPort *inputXr;
	QCNumberPort *inputYr;
	QCNumberPort *inputZr;
	QCNumberPort *inputWidth;
	QCNumberPort *inputHeight;
	QCOpenGLPort_Color *inputColor;
	QCOpenGLPort_Image *inputImage;
//	QCImagePort *inputMaskImage;
	QCOpenGLPort_Blending *inputBlending;
	QCOpenGLPort_ZBuffer *inputDepthTesting;
	QCOpenGLPort_Culling *inputFaceCulling;

	// given to children so they don't need to allocate ports when rendering (each lightweight sprite refers to the same one)
	QCOpenGLPort_Image *imagePort;
	QCOpenGLPort_Blending *blendPort;
	QCOpenGLPort_ZBuffer *depthPort;
	QCOpenGLPort_Culling *cullingPort;
	
	KinemeGLDepthSortEnvironmentPatch *_depthSortEnvironment;
}

@property (readonly) QCNumberPort *inputX;
@property (readonly) QCNumberPort *inputY;
@property (readonly) QCNumberPort *inputZ;
@property (readonly) QCNumberPort *inputXr;
@property (readonly) QCNumberPort *inputYr;
@property (readonly) QCNumberPort *inputZr;
@property (readonly) QCNumberPort *inputWidth;
@property (readonly) QCNumberPort *inputHeight;
@property (readonly) QCOpenGLPort_Color *inputColor;
@property (readonly) QCOpenGLPort_Image *inputImage;
//@property (readonly) QCImagePort *inputMaskImage;
@property (readonly) QCOpenGLPort_Blending *inputBlending;
@property (readonly) QCOpenGLPort_ZBuffer *inputDepthTesting;
@property (readonly) QCOpenGLPort_Culling *inputFaceCulling;

- (id)initWithIdentifier:(id)fp8;
- (void)renderOnContext:(QCOpenGLContext *)context;
- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;
@end
