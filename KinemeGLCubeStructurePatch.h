

@interface KinemeGLCubeStructurePatch : QCPatch
{
	QCStructurePort	*inputPoints;
	
	QCNumberPort	*inputDefaultSize;
		
	QCColorPort		*inputColor1;	// start color
	QCColorPort		*inputColor2;	// end color
	
	/* special control ports.  we don't need to handle them in the xml file. */
	//QCOpenGLPort_Image		*inputImage;
	QCOpenGLPort_Blending	*inputBlending;
	QCOpenGLPort_ZBuffer	*inputDepth;
	QCOpenGLPort_Culling	*inputCulling;
	
	GLuint	cube;
}

- (id)initWithIdentifier:(id)fp8;

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;
@end