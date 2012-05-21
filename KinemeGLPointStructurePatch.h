

@interface KinemeGLPointStructurePatch : QCPatch
{
	QCStructurePort	*inputPoints;
	
	QCNumberPort	*inputDefaultSize;
	
	QCBooleanPort	*inputAttenuate;
	
	QCColorPort		*inputColor1;	// start color
	QCColorPort		*inputColor2;	// end color
	
	/* special control ports.  we don't need to handle them in the xml file. */
	QCOpenGLPort_Image		*inputImage;
	QCOpenGLPort_Blending	*inputBlending;
	QCOpenGLPort_ZBuffer	*inputDepth;
}

- (id)initWithIdentifier:(id)fp8;

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;
@end