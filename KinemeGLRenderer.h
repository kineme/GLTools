@protocol KinemeGLDepthRenderer
- (void)renderOnContext:(QCOpenGLContext *)context;
@property (readonly, nonatomic) double depth;
@end
