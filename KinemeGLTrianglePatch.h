

@interface KinemeGLTrianglePatch : QCPatch
{
	QCOpenGLPort_Image	*inputImage;
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

	QCNumberPort	*inputX3;
	QCNumberPort	*inputY3;
	QCNumberPort	*inputZ3;
	QCNumberPort	*inputU3;
	QCNumberPort	*inputV3;
	QCColorPort		*inputColor3;
	
	/* special control ports.  we don't need to handle them in the xml file. */
	QCOpenGLPort_Blending	*inputBlending;
	QCOpenGLPort_ZBuffer	*inputDepth;
	QCOpenGLPort_Culling	*inputCulling;
}

- (id)initWithIdentifier:(id)fp8;

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;
@end