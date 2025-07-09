//
//  ContentView.swift
//  PhotoSwipe
//
//  Created by Andrew Grant on 7/6/25.
//

import SwiftUI
import Photos

class PhotoLibraryObserver: NSObject, PHPhotoLibraryChangeObserver {
	var refreshCallback: (() -> Void)?
	
	func photoLibraryDidChange(_ changeInstance: PHChange) {
		DispatchQueue.main.async {
			self.refreshCallback?()
		}
	}
}

struct ContentView: View {
	@State private var allPhotos: [PHAsset] = []
	@State private var loadedImages: [UIImage] = []
	@State private var currentIndex = 0
	@State private var authorizationStatus: PHAuthorizationStatus = .notDetermined
	@State private var favoriteList: Set<Int> = []
	@State private var keepList: Set<Int> = []
	@State private var trashList: Set<Int> = []
	@State private var showingConfirmation = false
	@State private var showingDateFilter = false
	@State private var startDate: Date? = nil
	@State private var endDate: Date? = nil
	@State private var filterOption = "All Photos"
	@State private var photoLibraryObserver: PhotoLibraryObserver?
	
	private var totalPendingActions: Int {
		favoriteList.count + keepList.count + trashList.count
	}
	
	private var currentPhotoIsFavorited: Bool {
		guard currentIndex < allPhotos.count else { return false }
		let asset = allPhotos[currentIndex]
		return asset.isFavorite
	}
	
	private var shouldShowFavoriteAsFilled: Bool {
		// Show filled if either:
		// 1. The photo is already favorited in the library AND not in the toggle list
		// 2. The photo is not favorited in the library but IS in the toggle list
		let isInToggleList = favoriteList.contains(currentIndex)
		return currentPhotoIsFavorited != isInToggleList
	}
	
	private var confirmationMessage: String {
		var message = "Are you sure you want to make changes to your photo library?\n\n"
		
		if favoriteList.count > 0 {
			message += "• \(favoriteList.count) photo\(favoriteList.count == 1 ? "" : "s") will have favorite status toggled\n"
		}
		
		if trashList.count > 0 {
			message += "• \(trashList.count) photo\(trashList.count == 1 ? "" : "s") will be deleted\n"
		}
		
		if keepList.count > 0 {
			message += "• \(keepList.count) photo\(keepList.count == 1 ? "" : "s") will be kept\n"
		}
		
		return message
	}
	
	var body: some View {
		ZStack {
			Color.black.ignoresSafeArea()
			
			if authorizationStatus == .notDetermined {
				VStack {
					Image(systemName: "photo.stack")
						.font(.system(size: 50))
						.foregroundColor(.white)
					Text("Loading Photos...")
						.foregroundColor(.white)
						.font(.headline)
				}
				.onAppear {
					requestPhotoLibraryAccess()
				}
			} else if authorizationStatus == .denied || authorizationStatus == .restricted {
				VStack {
					Image(systemName: "photo.badge.exclamationmark")
						.font(.system(size: 50))
						.foregroundColor(.white)
					Text("Photo access denied")
						.foregroundColor(.white)
						.font(.headline)
					Text("Please enable photo access in Settings")
						.foregroundColor(.gray)
						.font(.subheadline)
				}
			} else if loadedImages.isEmpty {
				VStack {
					Image(systemName: "photo.stack")
						.font(.system(size: 50))
						.foregroundColor(.white)
					Text("Loading Photos...")
						.foregroundColor(.white)
						.font(.headline)
				}
			} else {
				TabView(selection: $currentIndex) {
					ForEach(Array(loadedImages.enumerated()), id: \.offset) { index, image in
						Image(uiImage: image)
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(maxWidth: .infinity, maxHeight: .infinity)
							.tag(index)
					}
				}
				.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
				.ignoresSafeArea()
				
				// Bottom toolbar
				VStack {
					Spacer()
					
					HStack {
						Spacer()
						
						Button(action: {
							toggleFavorite()
						}) {
							Image(systemName: shouldShowFavoriteAsFilled ? "heart.fill" : "heart")
								.font(.system(size: 24))
								.foregroundColor(.white)
								.frame(width: 50, height: 50)
								.background(Color.black.opacity(0.5))
								.clipShape(Circle())
						}
						
						Spacer()
						
						Button(action: {
							toggleKeep()
						}) {
							Image(systemName: keepList.contains(currentIndex) ? "checkmark.circle.fill" : "checkmark.circle")
								.font(.system(size: 24))
								.foregroundColor(.white)
								.frame(width: 50, height: 50)
								.background(Color.black.opacity(0.5))
								.clipShape(Circle())
						}
						
						Spacer()
						
						Button(action: {
							toggleTrash()
						}) {
							Image(systemName: trashList.contains(currentIndex) ? "trash.fill" : "trash")
								.font(.system(size: 24))
								.foregroundColor(.white)
								.frame(width: 50, height: 50)
								.background(Color.black.opacity(0.5))
								.clipShape(Circle())
						}
						
						Spacer()
						
						Button(action: {
							showingConfirmation = true
						}) {
							HStack(spacing: 4) {
								Image(systemName: "checkmark.square")
									.font(.system(size: 20))
									.foregroundColor(.white)
								if totalPendingActions > 0 {
									Text("(\(totalPendingActions))")
										.font(.system(size: 10))
										.foregroundColor(.white)
								}
							}
							.frame(width: 50, height: 50)
							.background(Color.black.opacity(0.5))
							.clipShape(Circle())
						}
						
						Spacer()
					}
					.padding(.bottom, 50)
				}
			}
			
			// Filter button - always visible and on top
			VStack {
				HStack {
					Button(action: {
						showingDateFilter = true
					}) {
						Image(systemName: "calendar")
							.font(.system(size: 20))
							.foregroundColor(.white)
							.frame(width: 40, height: 40)
							.background(Color.black.opacity(0.5))
							.clipShape(Circle())
					}
					
					Spacer()
					
					if !loadedImages.isEmpty {
						Text("\(currentIndex + 1) / \(loadedImages.count)")
							.foregroundColor(.white)
							.padding(.horizontal)
							.padding(.vertical, 8)
							.background(Color.black.opacity(0.5))
							.cornerRadius(20)
					}
				}
				.padding()
				
				Spacer()
			}
		}
		.onChange(of: authorizationStatus) { oldValue, newValue in
			if newValue == .authorized || newValue == .limited {
				fetchAllPhotos()
				setupPhotoLibraryObserver()
			}
		}
		.onAppear {
			setupPhotoLibraryObserver()
		}
		.onDisappear {
			removePhotoLibraryObserver()
		}
		.confirmationDialog("Confirm Changes", isPresented: $showingConfirmation) {
			Button("Apply Changes", role: .destructive) {
				applyChanges()
			}
			Button("Cancel", role: .cancel) { }
		} message: {
			Text(confirmationMessage)
		}
		.sheet(isPresented: $showingDateFilter) {
			NavigationView {
				Form {
					Section(header: Text("Filter Options")) {
						Picker("Filter", selection: $filterOption) {
							Text("All Photos").tag("All Photos")
							Text("Last 30 Days").tag("Last 30 Days")
							Text("Custom Date Range").tag("Custom")
						}
						.pickerStyle(SegmentedPickerStyle())
						
						if filterOption == "Custom" {
							DatePicker("Start Date", selection: Binding(
								get: { startDate ?? Date() },
								set: { startDate = $0 }
							), displayedComponents: .date)
							DatePicker("End Date", selection: Binding(
								get: { endDate ?? Date() },
								set: { endDate = $0 }
							), displayedComponents: .date)
						}
					}
				}
				.navigationTitle("Filter Photos")
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItem(placement: .navigationBarLeading) {
						Button("Cancel") {
							showingDateFilter = false
						}
					}
					ToolbarItem(placement: .navigationBarTrailing) {
						Button("Apply") {
							applyFilter()
							showingDateFilter = false
						}
					}
				}
			}
		}
	}
	
	private func requestPhotoLibraryAccess() {
		PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
			DispatchQueue.main.async {
				authorizationStatus = status
			}
		}
	}
	
	private func applyFilter() {
		switch filterOption {
		case "All Photos":
			startDate = nil
			endDate = nil
		case "Last 30 Days":
			let calendar = Calendar.current
			startDate = calendar.date(byAdding: .day, value: -30, to: Date())
			endDate = Date()
		case "Custom":
			// Use the selected dates - ensure they are not nil
			if startDate == nil {
				startDate = Date()
			}
			if endDate == nil {
				endDate = Date()
			}
		default:
			startDate = nil
			endDate = nil
		}
		
		print("Filter applied: \(filterOption), start: \(startDate?.description ?? "nil"), end: \(endDate?.description ?? "nil")")
		resetAndReload()
	}
	
	private func resetAndReload() {
		// Clear all pending actions
		favoriteList.removeAll()
		keepList.removeAll()
		trashList.removeAll()
		
		// Reset current index
		currentIndex = 0
		
		// Reload images based on current filter
		fetchAllPhotos()
	}
	
	private func fetchAllPhotos() {
		let fetchOptions = PHFetchOptions()
		fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
		
		// Add date filter predicate only if dates are set
		if let startDate = startDate, let endDate = endDate {
			let calendar = Calendar.current
			let startOfStartDate = calendar.startOfDay(for: startDate)
			let endOfEndDate = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endDate)) ?? endDate
			
			fetchOptions.predicate = NSPredicate(format: "creationDate >= %@ AND creationDate < %@", startOfStartDate as NSDate, endOfEndDate as NSDate)
			print("Applied date filter: \(startOfStartDate) to \(endOfEndDate)")
		} else {
			print("No date filter applied - showing all photos")
		}
		
		let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
		
		allPhotos = []
		fetchResult.enumerateObjects { asset, _, _ in
			allPhotos.append(asset)
		}
		
		print("Fetched \(allPhotos.count) photos")
		loadImagesFromAssets()
	}
	
	private func loadImagesFromAssets() {
		loadedImages = []
		let imageManager = PHImageManager.default()
		let options = PHImageRequestOptions()
		options.isSynchronous = false
		options.deliveryMode = .highQualityFormat
		
		for (index, asset) in allPhotos.enumerated() {
			imageManager.requestImage(
				for: asset,
				targetSize: CGSize(width: 1024, height: 1024),
				contentMode: .aspectFit,
				options: options
			) { image, _ in
				if let image = image {
					DispatchQueue.main.async {
						if index < self.loadedImages.count {
							self.loadedImages[index] = image
						} else {
							while self.loadedImages.count <= index {
								self.loadedImages.append(UIImage())
							}
							self.loadedImages[index] = image
						}
					}
				}
			}
		}
		
		// Initialize array with placeholder images
		loadedImages = Array(repeating: UIImage(), count: allPhotos.count)
	}
	
	private func toggleFavorite() {
		if favoriteList.contains(currentIndex) {
			favoriteList.remove(currentIndex)
		} else {
			favoriteList.insert(currentIndex)
		}
	}
	
	private func toggleKeep() {
		if keepList.contains(currentIndex) {
			keepList.remove(currentIndex)
		} else {
			keepList.insert(currentIndex)
		}
	}
	
	private func toggleTrash() {
		if trashList.contains(currentIndex) {
			trashList.remove(currentIndex)
		} else {
			trashList.insert(currentIndex)
		}
	}
	
	
	private func setupPhotoLibraryObserver() {
		guard photoLibraryObserver == nil else { return }
		
		let observer = PhotoLibraryObserver()
		observer.refreshCallback = {
			DispatchQueue.main.async {
				self.fetchAllPhotos()
			}
		}
		
		PHPhotoLibrary.shared().register(observer)
		photoLibraryObserver = observer
	}
	
	private func removePhotoLibraryObserver() {
		if let observer = photoLibraryObserver {
			PHPhotoLibrary.shared().unregisterChangeObserver(observer)
			photoLibraryObserver = nil
		}
	}
	
	private func applyChanges() {
		let dispatchGroup = DispatchGroup()
		
		// Apply favorite changes
		for index in favoriteList {
			guard index < allPhotos.count else { continue }
			let asset = allPhotos[index]
			
			dispatchGroup.enter()
			PHPhotoLibrary.shared().performChanges({
				let request = PHAssetChangeRequest(for: asset)
				request.isFavorite = !asset.isFavorite
			}) { success, error in
				if success {
					print("Photo at index \(index) favorite status toggled")
				} else if let error = error {
					print("Error toggling favorite for photo at index \(index): \(error)")
				}
				dispatchGroup.leave()
			}
		}
		
		// Apply trash changes
		let assetsToDelete = trashList.compactMap { index in
			index < allPhotos.count ? allPhotos[index] : nil
		}
		
		if !assetsToDelete.isEmpty {
			dispatchGroup.enter()
			PHPhotoLibrary.shared().performChanges({
				PHAssetChangeRequest.deleteAssets(assetsToDelete as NSArray)
			}) { success, error in
				if success {
					DispatchQueue.main.async {
						// Remove deleted photos from arrays (in reverse order to maintain indices)
						let sortedIndices = self.trashList.sorted(by: >)
						for index in sortedIndices {
							if index < self.allPhotos.count {
								self.allPhotos.remove(at: index)
								self.loadedImages.remove(at: index)
							}
						}
						
						// Adjust current index if needed
						if self.currentIndex >= self.loadedImages.count && self.currentIndex > 0 {
							self.currentIndex = self.loadedImages.count - 1
						}
					}
				} else if let error = error {
					print("Error deleting photos: \(error)")
				}
				dispatchGroup.leave()
			}
		}
		
		// Handle keep list (placeholder for now)
		for index in keepList {
			print("Keep photo at index \(index)")
		}
		
		// Wait for all operations to complete, then clear lists
		dispatchGroup.notify(queue: .main) {
			self.favoriteList.removeAll()
			self.keepList.removeAll()
			self.trashList.removeAll()
		}
	}
}

#Preview {
	ContentView()
}
