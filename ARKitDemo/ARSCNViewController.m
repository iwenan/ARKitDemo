//
//  ARSCNViewController.m
//  ARKitDemo
//
//  Created by iwenan on 2017/8/21.
//  Copyright © 2017年 iwenan. All rights reserved.
//

#import "ARSCNViewController.h"
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>

@interface ARSCNViewController ()<ARSCNViewDelegate,ARSessionDelegate> {
    
    BOOL _isGround;
}
// AR视图：展示3D界面
@property (nonatomic, strong) ARSCNView *arSCNView;

// AR会话，负责管理相机追踪配置及3D相机坐标
@property (nonatomic, strong) ARSession *arSession;

// 会话追踪配置：负责追踪相机的运动
@property (nonatomic, strong) ARSessionConfiguration *arSessionConfiguration;

@property (nonatomic, strong) SCNNode *planeNode;

@property (nonatomic, strong) SCNNode *rotatePlaneNode;

@property (nonatomic, strong) SCNNode *flowerNode;

@property (nonatomic, strong) UIButton *backeBtn;

@property (nonatomic, strong) UIButton *flowerBtn;

@property (nonatomic, strong) UIButton *planeBtn;

@property (nonatomic, strong) UIButton *rotatingBtn;


@end

@implementation ARSCNViewController

#pragma mark - Override
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.arSCNView];
    [self.view addSubview:self.backeBtn];
    [self.view addSubview:self.flowerBtn];
    [self.view addSubview:self.planeBtn];
    [self.view addSubview:self.rotatingBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // arsession开始run
    [self.arSession runWithConfiguration:self.arSessionConfiguration];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.arSession pause];
}

#pragma mark - Event

- (void)_backAction:(UIButton *)btn {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_flowerBtnAction:(UIButton *)sender {
    _isGround = YES;
    [self.planeNode removeFromParentNode];
    [self.rotatePlaneNode removeFromParentNode];
    self.planeNode = nil;
    self.rotatePlaneNode = nil;
}

- (void)_planeBtnAction:(UIButton *)sender {
    if (self.planeNode != nil) {
        return;
    }
    [self.rotatePlaneNode removeFromParentNode];
    [self.flowerNode removeFromParentNode];
    self.rotatePlaneNode = nil;
    self.flowerNode = nil;
    _isGround = NO;
        
    // 使用场景加载scn文件（scn格式文件是一个基于3D建模的文件，使用3DMax软件可以创建）
    SCNScene *scene = [SCNScene sceneNamed:@"Models.scnassets/ship.scn"];
    // 获取飞机节点（一个场景会有多个节点，飞机节点则默认是场景子节点的第一个）
    // 所有的场景有且只有一个根节点，其他所有节点都是根节点的子节点
    
    SCNNode *shipNode = scene.rootNode.childNodes[0];
    
    self.planeNode = shipNode;
    
    shipNode.scale = SCNVector3Make(0.5, 0.5, 0.5); // 缩放
    shipNode.position = SCNVector3Make(0, -15,-15);// 位置 单位m
    
    // 遍历所有子节点，修改数据
    for (SCNNode *node in shipNode.childNodes) {
        node.scale = SCNVector3Make(0.5, 0.5, 0.5);
        node.position = SCNVector3Make(0, -15,-15);
    }
    // 将飞机节点添加到当前屏幕中
    [self.arSCNView.scene.rootNode addChildNode:shipNode];
    
}

- (void)_rotatingBtnAction:(UIButton *)sender {
    if (self.rotatePlaneNode != nil) {
        return;
    }
    [self.planeNode removeFromParentNode];
    [self.flowerNode removeFromParentNode];
    self.planeNode = nil;
    self.flowerNode = nil;
    _isGround = NO;
    
    // 使用场景加载scn文件（scn格式文件是一个基于3D建模的文件，使用3DMax软件可以创建）
    SCNScene *scene = [SCNScene sceneNamed:@"Models.scnassets/ship.scn"];
    // 获取飞机节点（一个场景会有多个节点，飞机节点则默认是场景子节点的第一个）
    // 所有的场景有且只有一个根节点，其他所有节点都是根节点的子节点
    
    SCNNode *shipNode = scene.rootNode.childNodes[0];
    
    self.rotatePlaneNode = shipNode;
    
    shipNode.scale = SCNVector3Make(0.5, 0.5, 0.5); // 缩放
    shipNode.position = SCNVector3Make(0, -15,-15);// 位置 单位m
    
    // 遍历所有子节点，修改数据
    for (SCNNode *node in shipNode.childNodes) {
        node.scale = SCNVector3Make(0.5, 0.5, 0.5);
        node.position = SCNVector3Make(0, -15,-15);
    }
    
    // 飞机绕相机旋转相关
    // 在相机的位置创建一个空节点，将空节点添加到根节点上，然后将飞机添加到这个空节点，最后让这个空节点自身旋转，就可以实现飞机围绕相机旋转。
    // !!!将飞机节点作为空节点的子节点，如果不这样，那么你将看到的是飞机自己在转，而不是围着相机转
    SCNNode *emptyNode = [[SCNNode alloc] init];
    // 空节点位置与相机节点位置一致
    emptyNode.position = self.arSCNView.scene.rootNode.position;
    [self.arSCNView.scene.rootNode addChildNode:emptyNode];
    
    [emptyNode addChildNode:self.rotatePlaneNode];
    
    CABasicAnimation *rota = [CABasicAnimation animationWithKeyPath:@"rotation"];
    rota.duration = 5;
    rota.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    rota.repeatCount = HUGE_VALF;
    [emptyNode addAnimation:rota forKey:@"roatationAnimation"];
}

#pragma mark - ARSCNViewDelegate
// 添加节点时候调用（当开启平地捕捉模式之后，如果捕捉到平地，ARKit会自动添加一个平地节点）
- (void)renderer:(id <SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    if (!_isGround) {
        return;
    }
    if (self.flowerNode) {
        return;
    }
    NSLog(@"添加节点");
    // 捕捉到平地
    if ([anchor isMemberOfClass:[ARPlaneAnchor class]]) {
        
        // 添加一个3D平面模型，ARKit只有捕捉能力，锚点只是一个空间位置，为了更加清楚看到这个空间，给空间添加一个平地的3D模型来渲染他
        ARPlaneAnchor *groundAnchor = (ARPlaneAnchor *)anchor;
        // 创建一个3D物体模型    （系统捕捉到的平地是一个不规则大小的长方形，将其变成一个长方形，并且是否对平地做了一个缩放效果）
        SCNBox *box = [SCNBox boxWithWidth:groundAnchor.extent.x * 0.3 height:0 length:groundAnchor.extent.x * 0.3 chamferRadius:0];
        box.firstMaterial.diffuse.contents = [UIColor clearColor];
        
        // 创建一个基于3D物体模型的节点
        SCNNode *flowerNode = [SCNNode nodeWithGeometry:box];
        // 设置节点的位置为捕捉到的平地的锚点的中心位置  SceneKit框架中节点的位置position是一个基于3D坐标系的矢量坐标SCNVector3Make
        flowerNode.position = SCNVector3Make(groundAnchor.center.x, 0, groundAnchor.center.z);
        [node addChildNode:flowerNode];
        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            SCNScene *scene = [SCNScene sceneNamed:@"Models.scnassets/cup/cup.scn"];
            SCNNode *vaseNode = scene.rootNode.childNodes[0];
            
            // 设置花瓶节点的位置为捕捉到的平地的位置，如果不设置，则默认为原点位置，也就是相机位置
            vaseNode.position = SCNVector3Make(groundAnchor.center.x, 0, groundAnchor.center.z);
            self.flowerNode = vaseNode;

            // 将花瓶节点添加到当前屏幕中
            //!!!此处一定要注意：花瓶节点是添加到代理捕捉到的节点中，而不是AR视图的根节点。因为捕捉到的平地锚点是一个本地坐标系，而不是世界坐标系
            [node addChildNode:vaseNode];
//        });
    }
}

// 刷新时调用
- (void)renderer:(id <SCNSceneRenderer>)renderer willUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
//    NSLog(@"刷新中");
}

// 更新节点时调用
- (void)renderer:(id <SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
//    NSLog(@"节点更新");
    
}

// 移除节点时调用
- (void)renderer:(id <SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
//    NSLog(@"节点移除");
}

#pragma mark - ARSessionDelegate

//会话位置更新（监听相机的移动），此代理方法会调用非常频繁，只要相机移动就会调用，如果相机移动过快，会有一定的误差
- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame {
//    NSLog(@"相机移动");
    //移动飞机
    if (self.planeNode) {
        //捕捉相机的位置，让节点随着相机移动而移动
        //根据官方文档记录，相机的位置参数在4X4矩阵的第三列
        self.planeNode.position = SCNVector3Make(frame.camera.transform.columns[3].x,frame.camera.transform.columns[3].y,frame.camera.transform.columns[3].z);
    }
}

- (void)session:(ARSession *)session didAddAnchors:(NSArray<ARAnchor*>*)anchors {
//    NSLog(@"添加锚点");
}


- (void)session:(ARSession *)session didUpdateAnchors:(NSArray<ARAnchor*>*)anchors {
//    NSLog(@"刷新锚点");
}

- (void)session:(ARSession *)session didRemoveAnchors:(NSArray<ARAnchor*>*)anchors {
//    NSLog(@"移除锚点");
}

#pragma mark - Getter

- (ARSession *)arSession {
    if (!_arSession) {
        _arSession = [[ARSession alloc] init];
        _arSession.delegate = self;
    }
    return _arSession;
}

- (ARSCNView *)arSCNView {
    
    if (!_arSCNView) {
        _arSCNView = [[ARSCNView alloc] initWithFrame:self.view.bounds];
        _arSCNView.session = self.arSession;
        // 设置代理  捕捉到平地会在代理回调中返回
        _arSCNView.delegate = self;
        // 自动刷新灯光
        _arSCNView.automaticallyUpdatesLighting = YES;
    }
    return _arSCNView;
}

- (ARSessionConfiguration *)arSessionConfiguration {
    if (!_arSessionConfiguration) {
        // 创建世界追踪会话配置（使用ARWorldTrackingSessionConfiguration效果更加好），需要A9芯片支持
        ARWorldTrackingSessionConfiguration *configuration = [[ARWorldTrackingSessionConfiguration alloc] init];
        // 设置追踪方向（追踪平面，arSCNView的delagte会用到）
        configuration.planeDetection = ARPlaneDetectionHorizontal;
        // 自适应灯光（相机从暗到强光快速过渡效果会平缓一些）
        configuration.lightEstimationEnabled = YES;
        _arSessionConfiguration = configuration;
    }
    return _arSessionConfiguration;
}

- (UIButton *)backeBtn {
    if (!_backeBtn) {
        _backeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backeBtn setTitle:@"返回" forState:UIControlStateNormal];
        _backeBtn.frame = CGRectMake(0, 50, 50, 50);
        _backeBtn.backgroundColor = [UIColor orangeColor];
        [_backeBtn addTarget:self action:@selector(_backAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backeBtn;
}

- (UIButton *)flowerBtn {
    if (!_flowerBtn) {
        _flowerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_flowerBtn setTitle:@"平地" forState:UIControlStateNormal];
        _flowerBtn.frame = CGRectMake(60, 50, 50, 50);
        _flowerBtn.backgroundColor = [UIColor orangeColor];
        [_flowerBtn addTarget:self action:@selector(_flowerBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flowerBtn;
}

- (UIButton *)planeBtn {
    if (!_planeBtn) {
        _planeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_planeBtn setTitle:@"飞机" forState:UIControlStateNormal];
        _planeBtn.frame = CGRectMake(120, 50, 50, 50);
        _planeBtn.backgroundColor = [UIColor orangeColor];
        [_planeBtn addTarget:self action:@selector(_planeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _planeBtn;
}

- (UIButton *)rotatingBtn {
    if (!_rotatingBtn) {
        _rotatingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rotatingBtn setTitle:@"飞机旋转" forState:UIControlStateNormal];
        _rotatingBtn.frame = CGRectMake(180, 50, 100, 50);
        _rotatingBtn.backgroundColor = [UIColor orangeColor];
        [_rotatingBtn addTarget:self action:@selector(_rotatingBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rotatingBtn;
}

@end
