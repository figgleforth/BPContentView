In your viewController make a property for BPContentView. Also make sure your viewController conforms to the BPContentViewDelegate protocol.

self.contentView = [[BPContentView alloc] initWithDelegate:self superView:self.view];
[self.view addSubview:self.contentView];

Now you can add any subviews to contentView

:)