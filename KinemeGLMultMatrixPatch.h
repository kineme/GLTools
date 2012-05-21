

@interface KinemeGLMultMatrixPatch : QCPatch
{
	QCBooleanPort	*inputTranspose;
	QCNumberPort	*input00;
	QCNumberPort	*input01;
	QCNumberPort	*input02;
	QCNumberPort	*input03;
	QCNumberPort	*input10;
	QCNumberPort	*input11;
	QCNumberPort	*input12;
	QCNumberPort	*input13;
	QCNumberPort	*input20;
	QCNumberPort	*input21;
	QCNumberPort	*input22;
	QCNumberPort	*input23;
	QCNumberPort	*input30;
	QCNumberPort	*input31;
	QCNumberPort	*input32;
	QCNumberPort	*input33;
}

- (id)initWithIdentifier:(id)fp8;

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;
@end