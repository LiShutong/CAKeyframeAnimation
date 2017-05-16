//
//  OpenGLDemoViewController.m
//  IphoneMapSdkDemo
//
//  Created by wzy on 14-11-14.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//

#import "OpenGLDemoViewController.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#define MAX_SIZE 1024

char vssource[] =
"precision mediump float;\n"
"attribute vec4 aPosition;\n"
"void main() {\n"
"    gl_Position = aPosition;\n"
"}\n";

char fssource[] =
"precision mediump float;\n"
"void main() {\n"
"    gl_FragColor = vec4(1.0, 0.0, 0.0, 0.5);\n"
"}\n";


typedef struct {
    GLfloat x;
    GLfloat y;
}GLPoint;

@interface OpenGLDemoViewController () {
    GLPoint glPoint[4];
    BOOL mapDidFinishLoad;
    BMKMapPoint mapPoints[4];
    BOOL glshaderLoaded;

    GLuint program;
    GLint aLocPos;
}

@end

@implementation OpenGLDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _mapView.overlookEnabled = NO;
    _mapView.rotateEnabled = NO;
    mapDidFinishLoad = NO;
    glshaderLoaded = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}

- (void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
}

#pragma mark - BMKMapViewDelegate

/**
 *地图初始化完毕时会调用此接口
 */
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView {
    mapPoints[0] = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(39.965, 116.604));
    mapPoints[1] = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(39.865, 116.604));
    mapPoints[2] = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(39.865, 116.704));
    mapPoints[3] = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(39.965, 116.704));
    mapDidFinishLoad = YES;
    [self glRender:[mapView getMapStatus]];
    [mapView mapForceRefresh];
}

/**
 *地图渲染每一帧画面过程中，以及每次需要重绘地图时（例如添加覆盖物）都会调用此接口
 *@param mapview 地图View
 *@param status 此时地图的状态
 */
- (void)mapView:(BMKMapView *)mapView onDrawMapFrame:(BMKMapStatus *)status {
    /*
     *do openGL render
     */
    if (mapDidFinishLoad) {
        [self glRender:status];
    }
}

- (void)glRender:(BMKMapStatus *)status {
    if (glshaderLoaded == NO) {
        glshaderLoaded = [self LoadShaders:vssource fragsource:fssource program:&program];
    }
    
    BMKMapRect maprect = _mapView.visibleMapRect;
    for (NSInteger i = 0; i < 4; i++) {
        CGPoint tempPt = [_mapView glPointForMapPoint:mapPoints[i]];
        glPoint[i].x = tempPt.x * 2 / maprect.size.width;
        glPoint[i].y = tempPt.y * 2 / maprect.size.height;
    }
    
    glUseProgram(program);
    glEnableVertexAttribArray(aLocPos);
    glVertexAttribPointer(aLocPos, 2, GL_FLOAT, 0, 0, glPoint);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    glDisableVertexAttribArray(aLocPos);
}



-(BOOL)CompileShader:(char*)shadersource shader:(GLuint)shader
{
    glShaderSource(shader, 1, (const char**)&shadersource, NULL);
    glCompileShader(shader);
    
    GLint compiled = 0;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
    
    if(!compiled)
    {
        int length = MAX_SIZE;
        char log[MAX_SIZE] = {0};
        
        glGetShaderInfoLog(shader, length, &length, log);
        NSLog(@"Shader compile failed");
        NSLog(@"log: %@", [NSString stringWithUTF8String:log]);
        
        return NO;
    }
    
    return YES;
}

-(BOOL)LoadShaders:(char*)vssource fragsource:(char*)fssource program:(GLuint*)prog
{
    GLuint vs = glCreateShader(GL_VERTEX_SHADER);
    GLuint fs = glCreateShader(GL_FRAGMENT_SHADER);
    
    if (!prog)
    {
        return NO;
    }
    
    if (!(vs && fs))
    {
        NSLog(@"Create Shader failed");
        return NO;
    }
    
    if (![self CompileShader:vssource shader:vs])
    {
        return NO;
    }
    
    if (![self CompileShader:fssource shader:fs])
    {
        return NO;
    }
    
    *prog = glCreateProgram();
    
    if (!(*prog))
    {
        NSLog(@"Create program failed");
        return NO;
    }
    
    glAttachShader(*prog, vs);
    glAttachShader(*prog, fs);
    glLinkProgram(*prog);
    
    GLint linked = 0;
    glGetProgramiv(*prog, GL_LINK_STATUS, &linked);
    
    aLocPos = glGetAttribLocation(program, "aPosition");
    
    if(!linked)
    {
        NSLog(@"Link program failed");
        return NO;
    }
    
    return YES;
}

@end
