//
//  MapSnapshotView.swift
//  Wafid
//
//  Created by almedadsoft on 26/01/2025.
//

import SwiftUI
import Foundation
import AVFoundation
import MapKit
import CoreLocation

struct MapSnapshotView: View {
    let latitude: Double
    let longitude: Double
    
    var body: some View {
        GeometryReader { geometry in
            MapSnapshot(latitude: latitude, longitude: longitude, width: geometry.size.width, height: 200)
        }
        .frame(height: 200)
    }
}

struct MapSnapshot: UIViewRepresentable {
    let latitude: Double
    let longitude: Double
    let width: CGFloat
    let height: CGFloat
    
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        
        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        options.size = CGSize(width: width, height: height)
        
        // توليد الصورة
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { (snapshot, error) in
            if let error = error {
                print("Error generating map snapshot: \(error)")
                return
            }
            if let snapshot = snapshot {
                DispatchQueue.main.async {
                    imageView.image = snapshot.image
                }
            }
        }
        
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        // يمكن إضافة أي تحديثات أخرى عند الحاجة
    }
}

struct LocationMapView: View {
    let latitude: Double
    let longitude: Double
    @Binding var isPresented: Bool
    @State private var region: MKCoordinateRegion
    @State private var tracking: MapUserTrackingMode = .none
    
    init(latitude: Double, longitude: Double, isPresented: Binding<Bool>) {
        self.latitude = latitude
        self.longitude = longitude
        self._isPresented = isPresented
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
                Map(
                    coordinateRegion: $region,
                    annotationItems: [
                        LocationAnnotation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                    ]) { location in
                        MapMarker(coordinate: location.coordinate, tint: .red)
                    }
                    .frame(width: UIScreen.main.bounds.width ,height: UIScreen.main.bounds.height)
            
            HStack {
                Button("Maps") {
                    openInMaps()
                }
                .padding()
                .background(rgbToColor(red: 193, green: 140, blue: 70))
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .padding()
                }
                .background(rgbToColor(red: 193, green: 140, blue: 70))
                .cornerRadius(10)
                .clipped()
                
            }
            .padding()
            .padding(.top,70)
            .frame(width: UIScreen.main.bounds.width ,height: 50)
                
            }
            .padding(.top,50)
            .frame(width: UIScreen.main.bounds.width ,height: UIScreen.main.bounds.height)
    }
    
    func openInMaps() {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.openInMaps(launchOptions: nil)
    }
}

struct LocationAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// New LocationPicker view
struct LocationPicker: UIViewControllerRepresentable {
    @Binding var selectedLocation: CLLocationCoordinate2D?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let mapView = MKMapView()
        let searchBar = UISearchBar()
        
        // Configure mapView for Arabic locale
        mapView.mapType = .hybrid
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsUserLocation = true
        mapView.delegate = context.coordinator
        
        // Ensure Arabic map labels
        if let languageCode = Locale.preferredLanguages.first,
           languageCode.hasPrefix("ar") {
            mapView.accessibilityLanguage = "ar"
        }
        
        // Configure searchBar
        searchBar.tintColor = .black
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = context.coordinator
        searchBar.placeholder = "Search for a location"
        
        // Add subviews
        viewController.view.addSubview(mapView)
        viewController.view.addSubview(searchBar)
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
        
        // Add constraints
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor,constant: -80),
            
            mapView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            mapView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
        ])
        
        // Add dismiss button with more visibility
        let dismissButton = UIButton(type: .system)
        dismissButton.setTitle("Close", for: .normal)
        dismissButton.backgroundColor = .clear
        dismissButton.setTitleColor(.black, for: .normal)
        dismissButton.layer.cornerRadius = 10
        dismissButton.addTarget(context.coordinator, action: #selector(Coordinator.dismissView), for: .touchUpInside)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(dismissButton)
        
        NSLayoutConstraint.activate([
            dismissButton.topAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.topAnchor, constant: 10),
            dismissButton.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: -10),
            dismissButton.widthAnchor.constraint(equalToConstant: 70),
            dismissButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update logic if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate, UISearchBarDelegate {
        var parent: LocationPicker
        var annotation: MKPointAnnotation?
        
        init(_ parent: LocationPicker) {
            self.parent = parent
        }
        
        @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            guard let mapView = gestureRecognizer.view as? MKMapView else { return }
            
            let point = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            
            addAnnotation(to: mapView, coordinate: coordinate)
        }
        
        func addAnnotation(to mapView: MKMapView, coordinate: CLLocationCoordinate2D) {
            // Remove previous annotation
            if let annotation = annotation {
                mapView.removeAnnotation(annotation)
            }
            
            // Add new annotation
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            self.annotation = annotation
            
            // Show confirmation alert
            showConfirmationAlert(for: coordinate, mapView: mapView)
        }
        
        func showConfirmationAlert(for coordinate: CLLocationCoordinate2D, mapView: MKMapView) {
            let alert = UIAlertController(
                title: "Confirm Location",
                message: "Do you want to send this location?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Send", style: .default, handler: { _ in
                self.parent.selectedLocation = coordinate
                self.parent.presentationMode.wrappedValue.dismiss()
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            // Ensure alert is presented on the correct view controller
            if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                var topViewController = rootViewController
                while let presentedViewController = topViewController.presentedViewController {
                    topViewController = presentedViewController
                }
                topViewController.present(alert, animated: true, completion: nil)
            }
        }
        
        @objc func dismissView() {
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            guard let searchText = searchBar.text, !searchText.isEmpty else { return }
            
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = searchText
            
            let search = MKLocalSearch(request: request)
            search.start { [weak self] response, error in
                guard let self = self,
                      let mapView = searchBar.superview?.subviews.first(where: { $0 is MKMapView }) as? MKMapView,
                      let coordinate = response?.mapItems.first?.placemark.coordinate else { return }
                
                // Move map to searched location
                let region = MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
                mapView.setRegion(region, animated: true)
                
                // Add annotation
                self.addAnnotation(to: mapView, coordinate: coordinate)
            }
        }
    }
}

extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
