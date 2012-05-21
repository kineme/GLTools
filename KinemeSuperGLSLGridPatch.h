

@interface KinemeSuperGLSLGridPatch : QCPatch
{
	QCStructurePort	*inputParameters;

	QCNumberPort	*inputXPosition;
	QCNumberPort	*inputYPosition;
	QCNumberPort	*inputZPosition;
	
	QCNumberPort	*inputXRotation;
	QCNumberPort	*inputYRotation;
	QCNumberPort	*inputZRotation;
	
	QCNumberPort	*inputWidth;
	QCNumberPort	*inputHeight;
	
	QCIndexPort		*inputHResolution;
	QCIndexPort		*inputVResolution;
	
	QCOpenGLPort_Blending	*inputBlending;
	QCOpenGLPort_ZBuffer	*inputDepthTest;
	QCOpenGLPort_Culling	*inputCulling;
	
	//NSMutableDictionary *dict;	// I can't remember why this was in here... ? :)
	
	//
	unsigned int vbo[3], faces;	// vertex, normal, texture vbo
	//unsigned int hres, vres;
	//float w, h;
}

- (id)initWithIdentifier:(id)fp8;

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;
@end