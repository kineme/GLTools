

@interface KinemeGLFieldOfViewPatch : QCPatch
{
    QCNumberPort *inputFieldOfView;
}

- (id)initWithIdentifier:(id)fp8;

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;
@end