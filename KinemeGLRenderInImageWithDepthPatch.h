

@interface KinemeGLRenderInImageWithDepthPatch : QCPatch
{
	QCIndexPort *inputWidth;
	QCIndexPort *inputHeight;
	
	QCImagePort *outputImage;
	QCImagePort *outputDepthImage;
	
	QCImageTextureBuffer *image;
	GLuint depthTexture;
}

- (id)initWithIdentifier:(id)fp8;

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;
@end