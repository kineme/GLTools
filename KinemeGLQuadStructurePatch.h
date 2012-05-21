

@interface KinemeGLQuadStructurePatch : QCPatch
{
	QCOpenGLPort_Image	*inputImage;
	QCStructurePort     *inputImageStructure;
	QCStructurePort		*inputQuads;
	QCColorPort			*inputColor;
	
	QCIndexPort			*inputType;
	
	QCNumberPort	*inputXPosition;
	QCNumberPort	*inputYPosition;
	QCNumberPort	*inputZPosition;
	QCNumberPort	*inputXRotation;
	QCNumberPort	*inputYRotation;
	QCNumberPort	*inputZRotation;	

	/* special control ports.  we don't need to handle them in the xml file. */
	QCOpenGLPort_Blending	*inputBlending;
	QCOpenGLPort_ZBuffer	*inputDepth;
	QCOpenGLPort_Culling	*inputCulling;
}

- (id)initWithIdentifier:(id)fp8;

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;
@end