

@interface KinemeGLLinePatch : QCPatch
{
	QCNumberPort	*inputSize;

	QCIndexPort		*inputPattern;
	QCIndexPort		*inputRepeatCount;
	
	QCNumberPort	*inputX1;
	QCNumberPort	*inputY1;
	QCNumberPort	*inputZ1;
	QCNumberPort	*inputU1;
	QCNumberPort	*inputV1;
	QCColorPort		*inputColor1;

	QCNumberPort	*inputX2;
	QCNumberPort	*inputY2;
	QCNumberPort	*inputZ2;
	QCNumberPort	*inputU2;
	QCNumberPort	*inputV2;
	QCColorPort		*inputColor2;
	
	QCOpenGLPort_Image	*inputImage;
	
	/* special control ports.  we don't need to handle them in the xml file. */
	QCOpenGLPort_Blending	*inputBlending;
	QCOpenGLPort_ZBuffer	*inputDepth;
}

- (id)initWithIdentifier:(id)fp8;

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;
@end