# ShgCircleView
简单圆环

ShgCircleView *cView = [[ShgCircleView alloc] init];
    cView.frame = CGRectMake(0, 100, self.view.bounds.size.width, self.view.bounds.size.width);
    cView.width = 30;
    cView.circleBackGroundColor = [UIColor redColor];
    cView.font = [UIFont systemFontOfSize:50 weight:1.1];
    cView.progress = 1.0;
    cView.circleColor = [UIColor greenColor];
    cView.cutDownTime = 60;
    cView.clockwise = NO;
    [cView setText:@"2345676"];
    [cView start:^(ShgCircleView * _Nonnull circleView) {
        NSLog(@"开始执行");
    }];
    [self.view addSubview:cView];
