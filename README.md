# animaiton-refresh-header

![sample](https://ws1.sinaimg.cn/large/006tNc79gy1g26kb1i7zjg30ah0j9tht.gif)

概述

- 基于 MJRefresh 实现一个动画 header


todo 

- 完整的刷新流程为 idle(1) -> pulling(2) -> refreshing(3) -> idle(4)，但1和2之间可以通过拖动屏幕实现；
- 目前只能通过 pulling percent 是否为0判断一个流程是否结束；
- 动画从 pulling -> idle 之间的过渡有问题；
- refershing 阶段应该使用更为醒目的动画；
- 性能优化，如何尽可能减少计算；
- 动画使用 CAShapeLayer 完成；
- 使用 core text 将文字拆解为贝塞尔曲线，可能有优化空间；


reference
- [Animating the Drawing of a CGPath With CAShapeLayer](https://oleb.net/blog/2010/12/animating-drawing-of-cgpath-with-cashapelayer/)
- [Controlling Animation Timing](http://ronnqvi.st/controlling-animation-timing)
- [How to pause the animation of a layer tree](https://developer.apple.com/library/archive/qa/qa1673/_index.html)
- [Low-level text rendering](https://www.codeproject.com/Articles/109729/Low-level-text-rendering)
- [Core Animation Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreAnimation_guide/BuildingaLayerHierarchy/BuildingaLayerHierarchy.html)
- [Core Text Programming Guide](https://developer.apple.com/library/archive/documentation/StringsTextFonts/Conceptual/CoreText_Programming/Overview/Overview.html)
- [CBStoreHouseRefreshControl](https://github.com/coolbeet/CBStoreHouseRefreshControl)
- [MJRefresh](https://github.com/CoderMJLee/MJRefresh)
