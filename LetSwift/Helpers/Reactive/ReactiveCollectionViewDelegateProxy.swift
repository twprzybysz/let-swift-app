//
//  ReactiveCollectionViewDelegateProxy.swift
//  LetSwift
//
//  Created by Kinga Wilczek on 08.05.2017.
//  Copyright © 2017 Droids On Roids. All rights reserved.
//

import UIKit

final class ReactiveCollectionViewDelegateProxy: NSObject, UICollectionViewDelegate {

    lazy var itemDidSelectObservable = Observable<IndexPath>(IndexPath(row: 0, section: 0))
    lazy var scrollViewDidScrollObservable = Observable<UIScrollView?>(nil)
    lazy var scrollViewWillEndDragging = Observable<Void>()

    private enum Constants {
        static let delegateAssociatedTag = UnsafeRawPointer(UnsafeMutablePointer<UInt8>.allocate(capacity: 1))
    }

    class func assignedProxyFor(_ object: AnyObject) -> ReactiveCollectionViewDelegateProxy? {
        return objc_getAssociatedObject(object, Constants.delegateAssociatedTag) as? ReactiveCollectionViewDelegateProxy
    }

    class func assignProxy(_ proxy: AnyObject, to object: UICollectionView) {
        objc_setAssociatedObject(object, Constants.delegateAssociatedTag, proxy, .OBJC_ASSOCIATION_RETAIN)
    }

    class func currentDelegateFor(_ object: UICollectionView) -> UICollectionViewDelegate? {
        return object.delegate
    }

    static func proxyForObject(_ object: UICollectionView) -> ReactiveCollectionViewDelegateProxy {
        let maybeProxy = ReactiveCollectionViewDelegateProxy.assignedProxyFor(object)

        let proxy: ReactiveCollectionViewDelegateProxy
        if let existingProxy = maybeProxy {
            proxy = existingProxy
        } else {
            proxy = ReactiveCollectionViewDelegateProxy.createProxy(for: object) as! ReactiveCollectionViewDelegateProxy
            ReactiveCollectionViewDelegateProxy.assignProxy(proxy, to: object)
        }

        let currentDelegate: AnyObject? = ReactiveCollectionViewDelegateProxy.currentDelegateFor(object)

        if currentDelegate !== proxy {
            ReactiveCollectionViewDelegateProxy.setCurrentDelegate(proxy, to: object)
        }
        return proxy
    }

    class func createProxy(for collectionView: UICollectionView) -> AnyObject {
        return collectionView.createDelegateProxy()
    }

    class func setCurrentDelegate(_ delegate: UICollectionViewDelegate?, to collectionView: UICollectionView) {
        collectionView.delegate = delegate
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        itemDidSelectObservable.next(indexPath)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDidScrollObservable.next(scrollView)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollViewWillEndDragging.next()
    }
}
