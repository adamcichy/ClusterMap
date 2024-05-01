//
//  ClusteredMapViewDelegate.swift
//  Example-UIKit
//
//  Created by Mikhail Vospennikov on 07.02.2023.
//

import ClusterMap
import Foundation
import MapKit

final class ClusteredMapViewDelegate: NSObject, MKMapViewDelegate {
    var regionDidChange: (MKCoordinateRegion) -> Void
    var annotationType: AnnotationTypes = .count

    init(regionDidChange: @escaping (MKCoordinateRegion) -> Void) {
        self.regionDidChange = regionDidChange
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case is ClusterAnnotation:
            let identifier = "Cluster\(annotationType.rawValue)"
            switch annotationType {
            case .count:
                let annotationView = mapView.annotationView(
                    of: ClusterWithLabelAnnotationView.self,
                    annotation: annotation,
                    reuseIdentifier: identifier
                )
                annotationView.backgroundColor = .systemGreen
                annotationView.alpha = 0
                return annotationView

            case .imageCount:
                let annotationView = mapView.annotationView(
                    of: ClusterWithImageAnnotationView.self,
                    annotation: annotation,
                    reuseIdentifier: identifier
                )
                annotationView.countLabel.textColor = .systemGreen
                annotationView.image = .pin2
                annotationView.alpha = 0
                return annotationView

            case .image:
                let annotationView = mapView.annotationView(
                    of: MKAnnotationView.self,
                    annotation: annotation,
                    reuseIdentifier: identifier
                )
                annotationView.image = .pin
                annotationView.alpha = 0
                return annotationView
            }

        default:
            let identifier = "Pin"
            let annotationView = mapView.annotationView(
                of: MKPinAnnotationView.self,
                annotation: annotation,
                reuseIdentifier: identifier
            )
            annotationView.pinTintColor = .systemGreen
            annotationView.alpha = 0
            return annotationView
        }
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        regionDidChange(mapView.region)
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }

        if let cluster = annotation as? ClusterAnnotation {
            var zoomRect = MKMapRect.null
            for annotation in cluster.memberAnnotations {
                let annotationPoint = MKMapPoint(annotation.coordinate)
                let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0, height: 0)
                if zoomRect.isNull {
                    zoomRect = pointRect
                } else {
                    zoomRect = zoomRect.union(pointRect)
                }
            }
            mapView.setVisibleMapRect(zoomRect, animated: true)
        }
    }

    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        UIView.animate(
            withDuration: 0.35, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [],
            animations: {
                for view in views {
                    view.alpha = 1
                }
            },
            completion: nil
        )
    }
}
