//
//  IntroPageViewController.swift
//  Zombies Interactive
//
//  Created by Henry Spindell on 2/27/16.
//  Copyright © 2016 Scott Cambo, Henry Spindell, & Delta Lab NU. All rights reserved.
//

import UIKit

class IntroPageViewController: UIPageViewController, UIPageViewControllerDataSource {
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                direction: .forward,
                animated: true,
                completion: nil)
        }
        stylePageControl()
        view.backgroundColor = UIColor(red:0.24, green:0.24, blue:0.25, alpha:1)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func stylePageControl() {
        let pageControl = UIPageControl.appearance()
        
        pageControl.currentPageIndicatorTintColor = UIColor.white
        pageControl.pageIndicatorTintColor = UIColor.gray
        pageControl.backgroundColor = UIColor(red:0.24, green:0.24, blue:0.25, alpha:1)
    }

    
    fileprivate(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newIntroViewController("One"),
            self.newIntroViewController("Two")]
    }()
    
    fileprivate func newIntroViewController(_ num: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "Intro\(num)VC")
    }
    
    
    // data source methods
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = orderedViewControllers.index(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }

}
