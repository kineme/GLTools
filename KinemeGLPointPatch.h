

@interface KinemeGLPointPatch : QCPatch
{
	QCNumberPort	*inputSize;
	QCNumberPort	*inputX;
	QCNumberPort	*inputY;
	QCNumberPort	*inputZ;
	
	QCBooleanPort	*inputAttenuate;
	
	QCColorPort		*inputColor;
	
	/* special control ports.  we don't need to handle them in the xml file. */
	QCOpenGLPort_Image		*inputImage;
	QCOpenGLPort_Blending	*inputBlending;
	QCOpenGLPort_ZBuffer	*inputDepth;
}

- (id)initWithIdentifier:(id)fp8;

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;
@end