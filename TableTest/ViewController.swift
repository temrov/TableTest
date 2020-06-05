//
//  ViewController.swift
//  TableTest
//
//  Created by Vadim Temnogrudov on 04.06.2020.
//  Copyright © 2020 temrov. All rights reserved.
//

import UIKit

class SpyScrollView:UIScrollView, UIGestureRecognizerDelegate {
    
    var skipPanTop: CGFloat = 0
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // disable pan gesture in empty inset space
        return touch.location(in: self).y > skipPanTop - contentOffset.y
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        guard hitView == self else { return hitView }
        let scrollPoint = convert(point, to: self)
        if scrollPoint.y > skipPanTop  {
            return hitView
        }
        return nil
    }
}

class ViewController: UIViewController {
    enum Constants {
        static let topOffset: CGFloat = 100
    }
    
    @IBOutlet weak var thisButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    unowned var spyScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.reloadData()
        tableViewTopConstraint.constant = Constants.topOffset
        tableView.showsVerticalScrollIndicator = true
        
        
        let spyScrollView = SpyScrollView()
        spyScrollView.verticalScrollIndicatorInsets = UIEdgeInsets(top: Constants.topOffset, left: 0, bottom: 0, right: 0)
        spyScrollView.skipPanTop = Constants.topOffset
        view.addSubview(spyScrollView)
        self.spyScrollView = spyScrollView
        
        let contentView = UIView()
       // contentView.backgroundColor = UIColor.blue.withAlphaComponent(0.2)
        contentView.isUserInteractionEnabled = false
        spyScrollView.addSubview(contentView)
        spyScrollView.delegate = self
        spyScrollView.panGestureRecognizer.delegate = (spyScrollView as UIGestureRecognizerDelegate)
    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let contentSize = CGSize(width: tableView.contentSize.width, height: tableView.contentSize.height + Constants.topOffset)
        if contentSize != spyScrollView.contentSize {
            spyScrollView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.width, height: view.frame.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
            let contentView = spyScrollView.subviews.first
            contentView?.frame = CGRect(origin: .zero, size: contentSize)
            spyScrollView.contentSize = contentSize
        }
    }
    
    @IBAction func tappedThisButton(_ sender: Any) {
        print("this button tapped!")
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("\(scrollView.contentOffset)")
        var collapseProgress: CGFloat = (scrollView.contentOffset.y * 2) / Constants.topOffset
        collapseProgress = max(collapseProgress, 0)
        collapseProgress = min(collapseProgress, 1)
        thisButton.alpha = 1 - collapseProgress
        if scrollView.contentOffset.y > Constants.topOffset {
            tableViewTopConstraint.constant = 0
            tableView.contentOffset = CGPoint(x: 0, y: scrollView.contentOffset.y - Constants.topOffset)
        } else {
            tableViewTopConstraint.constant = Constants.topOffset - scrollView.contentOffset.y
            tableView.contentOffset = .zero
        }
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return false
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let label = cell.viewWithTag(111) as? UILabel
        label?.text = "\(indexPath.row)."
        return cell
    }
}
