

@interface KinemeGLContextInfoPatch : QCPatch
{
	QCIndexPort *outputBitsRed;
	QCIndexPort *outputBitsGreen;
	QCIndexPort *outputBitsBlue;
	QCIndexPort *outputBitsAlpha;

	QCIndexPort *outputBitsAccumRed;
	QCIndexPort *outputBitsAccumGreen;
	QCIndexPort *outputBitsAccumBlue;
	QCIndexPort *outputBitsAccumAlpha;

	QCIndexPort *outputBitsDepth;

	QCIndexPort *outputBitsStencil;
	
	QCNumberPort *outputMinPointTextureSize;
	QCNumberPort *outputMaxPointTextureSize;
	
	QCStructurePort	*outputRendererInfo;
}

- (void)enable:(QCOpenGLContext *)context;
@end