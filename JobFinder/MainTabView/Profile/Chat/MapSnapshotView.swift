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
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            VStack {
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
                .padding(.top, 70)
                .frame(width: UIScreen.main.bounds.width, height: 50)
                
                Spacer()
                
                // زر العودة إلى الموقع الأساسي
                Button(action: {
                    resetToOriginalLocation()
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "location.fill")
                            .resizable()
                            .frame(width: 20,height: 20)
                        .foregroundColor(.white)
                        
                        Text("Return to Original Location")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                        Spacer()
                    }
                    .padding(.horizontal)
                    .frame(width: UIScreen.main.bounds.width - 40)
                    .background(rgbToColor(red: 193, green: 140, blue: 70))
                    .cornerRadius(10)
                }.padding(.bottom, 70)
            }
        }
        .padding(.top, 50)
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }

    func resetToOriginalLocation() {
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
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


struct LocationPicker: UIViewControllerRepresentable {
    @Binding var selectedLocation: CLLocationCoordinate2D?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let mapView = MKMapView()
        let searchBar = UISearchBar()
        let tableView = UITableView()
        
        // Configure mapView
        mapView.mapType = .hybrid
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsUserLocation = true
        mapView.delegate = context.coordinator
        
        // Configure for Arabic
        if let languageCode = Locale.preferredLanguages.first,
           languageCode.hasPrefix("ar") {
            mapView.accessibilityLanguage = "ar"
        }
        
        // Configure searchBar
        searchBar.tintColor = .black
        searchBar.delegate = context.coordinator
        searchBar.placeholder = "Find a place"
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure table view
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = context.coordinator
        tableView.dataSource = context.coordinator
        tableView.isHidden = true
        tableView.layer.cornerRadius = 10
        tableView.clipsToBounds = true
        tableView.backgroundColor = .systemBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SearchResultCell")
        tableView.rowHeight = 44 // Standard row height
        
        // Store references in coordinator
        context.coordinator.mapView = mapView
        context.coordinator.tableView = tableView
        context.coordinator.tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 44) // Initial height for one row
        
        // Add subviews
        viewController.view.addSubview(mapView)
        viewController.view.addSubview(searchBar)
        viewController.view.addSubview(tableView)
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
        
        // Add constraints
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: -80),
            
            mapView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            mapView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: -10),
            context.coordinator.tableViewHeightConstraint
        ])
        
        // Add dismiss button
        let dismissButton = UIButton(type: .system)
        dismissButton.setTitle("closing", for: .normal)
        dismissButton.backgroundColor = .white
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
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
        var parent: LocationPicker
        var annotation: MKPointAnnotation?
        private var searchResults: [MKLocalSearchCompletion] = []
        private let searchCompleter = MKLocalSearchCompleter()
        private let locationManager = CLLocationManager()
        
        // Store view references
        weak var mapView: MKMapView?
        weak var tableView: UITableView?
        var tableViewHeightConstraint: NSLayoutConstraint!
        
        init(_ parent: LocationPicker) {
            self.parent = parent
            super.init()
            
            searchCompleter.delegate = self
            searchCompleter.resultTypes = .query
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        
        // Update table view height
        private func updateTableViewHeight() {
            let rowCount = searchResults.count + 1 // +1 for current location cell
            let newHeight = CGFloat(rowCount) * 44 // 44 is the row height
            let maxHeight = CGFloat(300) // Maximum height
            tableViewHeightConstraint.constant = min(newHeight, maxHeight)
            tableView?.layoutIfNeeded()
        }
        
        // MARK: - UISearchBarDelegate
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if searchText.isEmpty {
                searchResults = []
                tableView?.isHidden = true
                updateTableViewHeight()
                tableView?.reloadData()
            } else {
                searchCompleter.queryFragment = searchText
                tableView?.isHidden = false
            }
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
            tableView?.isHidden = true
        }
        
        // MARK: - Table View Data Source
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return searchResults.count + 1 // +1 for current location cell
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath)
            
            if indexPath.row == 0 {
                cell.textLabel?.text = "Share my current location"
                cell.imageView?.image = UIImage(systemName: "location.fill")
                cell.imageView?.tintColor = .black
            } else {
                let result = searchResults[indexPath.row - 1]
                cell.textLabel?.text = result.title
                cell.detailTextLabel?.text = result.subtitle
                cell.imageView?.image = UIImage(systemName: "mappin")
                cell.imageView?.tintColor = .black
            }
            
            return cell
        }
        
        // MARK: - Table View Delegate
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            
            if indexPath.row == 0 {
                // Handle current location selection
                locationManager.requestWhenInUseAuthorization()
                
                if let currentLocation = locationManager.location?.coordinate {
                    // Use current location directly if available
                    if let mapView = self.mapView {
                        
                        let region = MKCoordinateRegion(
                            center: currentLocation,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        )
                        mapView.setRegion(region, animated: true)
                    }
                    parent.selectedLocation = currentLocation
                    parent.presentationMode.wrappedValue.dismiss()
                } else {
                    // Start updating location if not available
                    locationManager.startUpdatingLocation()
                }
            } else {
                let result = searchResults[indexPath.row - 1]
                let searchRequest = MKLocalSearch.Request(completion: result)
                let search = MKLocalSearch(request: searchRequest)
                
                search.start { [weak self] (response, error) in
                    guard let self = self,
                          let coordinate = response?.mapItems.first?.placemark.coordinate,
                          let mapView = self.mapView else { return }
                    
                    self.addAnnotation(to: mapView, coordinate: coordinate)
                    
                    let region = MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                    mapView.setRegion(region, animated: true)
                }
            }
            
            // Hide table view after selection
            tableView.isHidden = true
        }
        
        // MARK: - Location Manager Delegate
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last,
                  let mapView = self.mapView else { return }
            
            let coordinate = location.coordinate
            
            let region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            mapView.setRegion(region, animated: true)
            
            // Update selected location and dismiss
            parent.selectedLocation = coordinate
            parent.presentationMode.wrappedValue.dismiss()
            
            locationManager.stopUpdatingLocation()
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
                title: "Confirm location",
                message: "Do you want to send this location?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "send", style: .default, handler: { _ in
                self.parent.selectedLocation = coordinate
                self.parent.presentationMode.wrappedValue.dismiss()
            }))
            
            alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
            
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
    }
}

// MARK: - MKLocalSearchCompleterDelegate Extension
extension LocationPicker.Coordinator: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        updateTableViewHeight()
        tableView?.reloadData()
    }
}

extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
