import UIKit
import MapKit
import MRTLib

class MRTMapViewAnnotation: NSObject, MKAnnotation {
	var coordinate: CLLocationCoordinate2D
	var title: String?
	var subtitle: String?

	init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
		self.coordinate = coordinate
		self.title = title
		self.subtitle = subtitle
	}
}

private let defaultLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 25.048780, longitude: 121.500867)

class MRTMapViewController: UIViewController, MKMapViewDelegate {
	var mapView: MKMapView?
	var routeLines = [MKPolyline: String]()

	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = UIColor.systemBackground
		if mapView == nil {
			self.mapView = MKMapView()
			self.mapView!.frame = self.view.bounds
			self.mapView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
			self.mapView!.delegate = self
			self.view.addSubview(self.mapView!)
			for lineID in MRTMap.sharedMap.lines.keys {
				var coordinateArray = [CLLocationCoordinate2D]()
				let line = MRTMap.sharedMap.lines[lineID]
				for stationName in line! {
					if stationName == "小碧潭" {
						continue
					}
					let station = MRTMap.sharedMap.exits[stationName]
					let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(station!.latitude!), CLLocationDegrees(station!.logitude!))
					let annotation = MRTMapViewAnnotation(coordinate: coordinate, title: station!.name, subtitle: station!.address!)
					self.mapView!.addAnnotation(annotation)
					coordinateArray.append(coordinate)
				}
				let routeLine = MKPolyline(coordinates: &coordinateArray, count: coordinateArray.count)
				routeLines[routeLine] = lineID
				self.mapView!.add(routeLine)
			}
			let startCoord = defaultLocation
			let region = self.mapView!.regionThatFits(MKCoordinateRegionMakeWithDistance(startCoord, 25000, 25000))
			self.mapView!.setRegion(region, animated: false)
		}
	}

	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		var view = mapView.dequeueReusableAnnotationView(withIdentifier: "cell")
		if view == nil {
			view = MKAnnotationView(annotation: annotation, reuseIdentifier: "cell")
			view!.canShowCallout = true
			let imageView = UIImageView(image: UIImage(named: "metro_station"))
			imageView.frame = CGRect(x: -10, y: 0, width: 15, height: 15)
			imageView.alpha = 0.5;
			view?.addSubview(imageView)
		}
		return view
	}

	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		let route = overlay as! MKPolyline
		let routeRenderer = MKPolylineRenderer(polyline: route)
		if let lineID = self.routeLines[route] {
			if let color = MRTLineColor(lineID: lineID) {
				routeRenderer.strokeColor = color
			}
			routeRenderer.lineWidth = 3
		}
		else {
			routeRenderer.strokeColor = UIColor.label
			routeRenderer.lineWidth = 5
		}
		return routeRenderer
	}
}


class MRTRouteMapViewController: MRTMapViewController {
	var route: MRTRoute? {
		didSet {
			self.loadRoute()
		}
	}

	func loadRoute() {
		_ = self.view

		if let route = self.route {
			var coordinateArray = [CLLocationCoordinate2D]()
			let from = route.from
			let fromCoordinate = CLLocationCoordinate2DMake(CLLocationDegrees(from.latitude!), CLLocationDegrees(from.logitude!))
			coordinateArray.append(fromCoordinate)
			for link in route.links {
				let station = link.to
				let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(station.latitude!), CLLocationDegrees(station.logitude!))
				coordinateArray.append(coordinate)
			}
			let routeLine = MKPolyline(coordinates: &coordinateArray, count: coordinateArray.count)
			self.mapView!.add(routeLine)

		}
	}
}
