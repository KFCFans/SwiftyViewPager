//
//  SwiftyViewPager.swift
//  ViewPager
//
//  Created by lip on 16/12/4.
//  Copyright © 2016年 lip. All rights reserved.
//

import UIKit

class SwiftyViewPager: UIView {


    /// 图片数量
    var imageCount:Int = 0
    
    /// 图片数组
    var imageArray:[UIImage]?
    
    /// 自动滚动间隔，默认 2.5s
    var ViewPagerTimeInterval:TimeInterval = 2.5
    
    /// 定时器
    var timer:Timer?
    
    /// 指示器
    var pageIndictor:UIPageControl?
    
    /// 滚动视图
    var scrollView:UIScrollView?
    
    /// ViewPager 宽度
    let vpWidth = UIScreen.main.bounds.width
    
    /// ViewPager 高度（默认200）
    var vpHeight:CGFloat = 150
    
    /// 当前页面索引（默认第一张）(从 1 开始)
    var currentIndex:Int = 1{
        
        didSet{
            print("currentIndex\(currentIndex)")
            pageIndictor?.currentPage = currentIndex - 1
        }
        
    }
    

    // MARK: - 便利构造函数创建 ViewPager
    convenience init(viewpagerHeight:CGFloat,imageArray:[UIImage],timeInterval:TimeInterval = 2.5) {
        
        // 创建 SwiftyViewPager！
        self.init(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: viewpagerHeight))
        
        //1.赋值&初始化
        self.imageArray = imageArray
        self.imageCount = imageArray.count
        self.ViewPagerTimeInterval = timeInterval
        self.vpHeight = viewpagerHeight
        self.scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: vpWidth, height: vpHeight))
        
        //2.设置 UI
        setupUI()
        
        //3.设置指示器
        setupIndictor()
        
        //4.设置定时器
        setupTimer()
        
    }
    
    
    // MARK: - 销毁时钟
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    

}

// MARK: - UI 相关方法
extension SwiftyViewPager{
    
    
    fileprivate func setupUI(){
        
        guard let scrollView = scrollView,
              let imageArray = imageArray  else{
            return
        }

        // 设置可滚动区域
        scrollView.contentSize.width = vpWidth * CGFloat(imageCount + 2)
        
        addSubview(scrollView)

        //用字典数组设置图片
        for i in 0..<(imageCount + 2){
            
            // 设置‘前部’缓冲图片为最后一张图片
            if i == 0{
                
                let iv = UIImageView(image: imageArray[imageCount - 1])
                iv.isUserInteractionEnabled = false
                scrollView.addSubview(iv)
                iv.frame = CGRect(x: 0, y: 0, width: vpWidth, height: vpHeight)
                continue
            }
            
            // 设置‘后部’缓冲图片为第一张图片
            if i == (imageCount + 1){
                
                let iv = UIImageView(image: imageArray[0])
                scrollView.addSubview(iv)
                iv.isUserInteractionEnabled = false
                iv.frame = CGRect(x: CGFloat(imageCount + 1) * vpWidth, y: 0, width: vpWidth, height: vpHeight)
                continue
                
            }
            
            // 设置轮播图片
            let iv = UIImageView(image: imageArray[i - 1])
            iv.isUserInteractionEnabled = false
            scrollView.addSubview(iv)
            iv.frame = CGRect(x: CGFloat(i) * vpWidth, y: 0, width: vpWidth, height: vpHeight)
            
        }
        
        
        // 设置scrollerView
        scrollView.backgroundColor = UIColor.white
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.isScrollEnabled = true
        scrollView.delegate = self
        
        
        
        // 偏移一个宽度来隐藏第0张图片（即缓冲图片）
        scrollView.setContentOffset(CGPoint(x: vpWidth, y: 0), animated: false)
        
        
        
    }
    
    /// 设置指示器
    fileprivate func setupIndictor(){
        
        pageIndictor = UIPageControl(frame: CGRect(x: 0, y: 0, width: 150, height: 10))
        guard let pageIndictor = pageIndictor else{
            return
        }
        pageIndictor.numberOfPages = imageCount
        self.addSubview(pageIndictor)
        pageIndictor.center.x = scrollView?.center.x ?? self.center.x
        pageIndictor.center.y = vpHeight - 20
        
        
    }
    


}

// MARK: - 实现 ScrollView 协议
extension SwiftyViewPager:UIScrollViewDelegate{
    
    /// 停止拖动 , setContentOffSet 不会触发该方法
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        // 重启定时器
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: ViewPagerTimeInterval, target: self, selector: #selector(moveToNextPage), userInfo: nil, repeats: true)
        }
        
        
    }
    
    
    /// 正在滚动， setContentOffSet 会触发该方法
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // 页面，超过 0.5 为下一页。即＋1
        let page = Int((scrollView.contentOffset.x) / scrollView.bounds.width + 0.5)
        
        // 偏移量，100% 偏移的时候就 ＝＝ page
        let offset = (scrollView.contentOffset.x) / scrollView.bounds.width
        
        // 若没有变化，无需更多操作，直接返回即可
        if page == currentIndex{
            return
        }
        
        // 设为 == 1 在快速拖动的时候有几率直接pass。 > 0.99 几乎看不出来&可以防止拖的太快导致无法滑动
        if offset > CGFloat(imageCount) + 0.99 {
            
            scrollView.setContentOffset(CGPoint(x: vpWidth, y: 0), animated: false)
            currentIndex = 1
            
        }
        // 同上⬆️
        if offset < 0.01{

            scrollView.setContentOffset(CGPoint(x: vpWidth * CGFloat(imageCount), y: 0), animated: false)
            currentIndex = imageCount
            
        }
        
        if page == 0 {
            
            currentIndex = imageCount
            
        }
        else if page == imageCount + 1{
            
            currentIndex = 1
            
        }
        else{
            currentIndex = page
        }
    }
    
    /// 将要拖动，用于停止 Timer
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        // 停止定时器 Timer
        timer?.invalidate()
        // 销毁定时器 Timer
        timer = nil
    }
    
}

// MARK: - 定时器相关方法
extension SwiftyViewPager{
    
    /// 设置定时器
    fileprivate func setupTimer(){
        
        // 初始化 timer
        timer = Timer.scheduledTimer(timeInterval: ViewPagerTimeInterval, target: self, selector: #selector(moveToNextPage), userInfo: nil, repeats: true)
        
    }
    
    @objc fileprivate func moveToNextPage(){
        
        guard let scrollView = scrollView else {
            return
        }
        
        let x = scrollView.contentOffset.x
        let y = scrollView.contentOffset.y
        scrollView.setContentOffset(CGPoint(x: x + vpWidth, y: y), animated: true)
        
    }
    
}
