import UIKit
import MapKit

class MRTMapViewAnnotation : NSObject, MKAnnotation {
	var coordinate: CLLocationCoordinate2D
	var title :String!
	var subtitle :String!

	init(coordinate:CLLocationCoordinate2D, title: String, subtitle:String) {
		self.coordinate = coordinate
		self.title = title
		self.subtitle = subtitle
	}
}

class MRTMapViewController :UIViewController, MKMapViewDelegate {
	var mapView: MKMapView?
	var routeLines = [MKPolyline: String]()

	class func colorForID(lineID :String) -> UIColor? {
		let colors = [
			"1": UIColor(hue: 0.1, saturation: 08, brightness: 0.71, alpha: 0.7),
			"2": UIColor(hue: 0.97, saturation: 1.0, brightness: 0.85, alpha: 0.7),
			"3": UIColor(hue: 0.42, saturation: 0.84, brightness: 0.42, alpha: 0.7),
			"4": UIColor(hue: 0.12, saturation: 0.75, brightness: 0.91, alpha: 0.7),
			"4A": UIColor(hue: 0.12, saturation: 0.75, brightness: 0.91, alpha: 0.7),
			"4B": UIColor(hue: 0.12, saturation: 0.75, brightness: 0.91, alpha: 0.7),
			"5": UIColor(hue: 0.58, saturation: 0.95, brightness: 0.66, alpha: 0.7)]
		return colors[lineID]
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		if mapView == nil {
			self.mapView = MKMapView()
			self.mapView!.frame = self.view.bounds
			self.mapView!.autoresizingMask = .FlexibleWidth | .FlexibleHeight
			self.mapView!.delegate = self
			self.view.addSubview(self.mapView!)
			for lineID in MRTMap.sharedMap.lines.keys {
				var coordinateArray = [CLLocationCoordinate2D]()
				var line = MRTMap.sharedMap.lines[lineID]
				for stationName in line! {
					if stationName == "小碧潭" {
						continue
					}
					var station = MRTMap.sharedMap.exits[stationName]
					var coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(station!.logitude!), CLLocationDegrees(station!.latitude!))
					var annotation = MRTMapViewAnnotation(coordinate: coordinate, title: station!.name, subtitle: station!.address!)
					self.mapView!.addAnnotation(annotation)
					coordinateArray.append(coordinate)
				}
				var routeLine = MKPolyline(coordinates: &coordinateArray, count: coordinateArray.count)
				routeLines[routeLine] = lineID
				self.mapView!.addOverlay(routeLine)
			}
			let startCoord = CLLocationCoordinate2D(latitude: 25.048780, longitude: 121.500867)
			let region = self.mapView!.regionThatFits(MKCoordinateRegionMakeWithDistance(startCoord, 25000, 25000))
			self.mapView!.setRegion(region, animated: false)
		}
	}

	func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
		var view = mapView!.dequeueReusableAnnotationViewWithIdentifier("cell")
		if view == nil {
			view = MKAnnotationView(annotation: annotation, reuseIdentifier: "cell")
			view.canShowCallout = true
			let imageView = UIImageView(image: UIImage(named: "metro_station"))
			imageView.frame = CGRectMake(-10, 0, 15, 15)
			imageView.alpha = 0.5;
			view.addSubview(imageView)
		}
		return view
	}

	func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
		if overlay.isKindOfClass(MKPolyline.self) {
			let route = overlay as! MKPolyline
			let routeRenderer = MKPolylineRenderer(polyline: route)
			let lineID = self.routeLines[route]!
			var color = MRTMapViewController.colorForID(lineID)
			routeRenderer.strokeColor = color ?? UIColor(white: 0.0, alpha: 0.5)
			routeRenderer.lineWidth = color != nil ? 4 : 7
			return routeRenderer
		}
		return nil
	}
}


class MRTRouteMapViewController :MRTMapViewController {
	var route :MRTRoute? {
	didSet {
		self.loadRoute()
	}
	}

	func loadRoute() {
		var aView = self.view

		if let route = self.route {
			var coordinateArray = [CLLocationCoordinate2D]()
			var from = route.from
			var fromCoordinate = CLLocationCoordinate2DMake(CLLocationDegrees(from.logitude!), CLLocationDegrees(from.latitude!))
			coordinateArray.append(fromCoordinate)
			for link in route.links {
				var station = link.to
				var coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(station.logitude!), CLLocationDegrees(station.latitude!))
				coordinateArray.append(coordinate)
			}
			var routeLine = MKPolyline(coordinates: &coordinateArray, count: coordinateArray.count)
			self.mapView!.addOverlay(routeLine)

		}
	}
}
