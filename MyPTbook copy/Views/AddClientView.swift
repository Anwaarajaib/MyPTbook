import SwiftUI
import PhotosUI
import SwiftUICore

struct AddClientView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var dataManager: DataManager
    
    // MARK: - State Properties
    @State private var name = ""
    @State private var age = ""
    @State private var height = ""
    @State private var weight = ""
    @State private var medicalHistory = ""
    @State private var goals = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingActionSheet = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var nutritionPlan = ""
    @State private var isProcessing = false
    @State private var error: String?
    @State private var showingPopover = false
    
    // Add these constants at the top of the struct to match ClientDetailView
    private let cardPadding: CGFloat = 24
    private let contentSpacing: CGFloat = 20
    private let cornerRadius: CGFloat = 16
    private let shadowRadius: CGFloat = 10
    private let minimumTapTarget: CGFloat = 44
    
    var body: some View {
        ScrollView {
            mainContent
        }
        .background(Colors.background)
        .ignoresSafeArea()
        .navigationTitle("Add Client")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar { toolbarContent }
        .confirmationDialog("Change Profile Picture", isPresented: $showingActionSheet) {
            dialogButtons
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(
                image: $selectedImage,
                sourceType: .photoLibrary,
                showAlert: $showAlert,
                alertMessage: $alertMessage
            )
        }
        .fullScreenCover(isPresented: $showingCamera) {
            ImagePicker(
                image: $selectedImage,
                sourceType: .camera,
                showAlert: $showAlert,
                alertMessage: $alertMessage
            )
        }
        .alert("Camera Access", isPresented: $showAlert) {
            Button("OK") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(error ?? alertMessage)
        }
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        VStack(spacing: 24) {
            Color.clear.frame(height: 100)
            clientDetailsCard
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Client Details Card
    private var clientDetailsCard: some View {
        VStack(spacing: 12) {
            // Profile Image and Name Section
            HStack(alignment: .top, spacing: contentSpacing * 2) {
                // Left side - Profile Image
                ZStack {
                    if let profileImage = selectedImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 36, height: 36)
                                    .foregroundColor(Color.gray.opacity(0.5))
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    Button(action: {
                        if DesignSystem.isIPad {
                            showingPopover = true
                        } else {
                            showingActionSheet = true
                        }
                    }) {
                        Image(systemName: "camera")
                            .font(.system(size: DesignSystem.isIPad ? 24 : 18))
                            .foregroundColor(Colors.nasmBlue)
                            .padding(7)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .offset(x: DesignSystem.isIPad ? 26 : 26, 
                            y: DesignSystem.isIPad ? 26 : 26)
                    .popover(isPresented: $showingPopover,
                             attachmentAnchor: .point(.topTrailing),
                             arrowEdge: .leading) {
                        VStack(spacing: 0) {
                            Button(action: { 
                                showingPopover = false
                                showingCamera = true 
                            }) {
                                Text("Take Photo")
                                    .font(.system(size: 17))
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            }
                            
                            Divider()
                            
                            Button(action: { 
                                showingPopover = false
                                showingImagePicker = true 
                            }) {
                                Text("Choose from Library")
                                    .font(.system(size: 17))
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            }
                        }
                        .frame(width: 200)
                    }
                }
                .frame(width: minimumTapTarget, height: minimumTapTarget)
                .padding(.top, 7)
                .padding(.leading, 7)
                
                // Right side - Name and Metrics
                VStack(alignment: .leading, spacing: 16) {
                    // Name
                    TextField("Name", text: $name)
                        .font(.title2.bold())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .foregroundColor(.primary)
                        .tint(Colors.nasmBlue)
                    
                    // Metrics in horizontal layout
                    HStack(spacing: contentSpacing) {
                        MetricView(
                            title: "Age",
                            value: $age,
                            unit: "years",
                            isEditing: true
                        )
                        
                        MetricView(
                            title: "Height",
                            value: $height,
                            unit: "cm",
                            isEditing: true
                        )
                        
                        MetricView(
                            title: "Weight",
                            value: $weight,
                            unit: "kg",
                            isEditing: true
                        )
                    }
                }
                .padding(.top, -5)
            }
            .padding(.horizontal, cardPadding)
            .padding(.top, cardPadding)
            .padding(.bottom, 8)
            
            // Medical History and Goals
            HStack(alignment: .top, spacing: contentSpacing) {
                VStack(alignment: .leading, spacing: 12) {
                    InfoSection(
                        title: "Medical History",
                        text: $medicalHistory,
                        isEditing: true
                    )
                    
                    InfoSection(
                        title: "Goals",
                        text: $goals,
                        isEditing: true
                    )
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, cardPadding)
            
            // Add Client Button
            Button {
                Task {
                    await saveClient()
                }
            } label: {
                HStack {
                    Text("Add Client")
                        .fontWeight(.semibold)
                    
                    if isProcessing {
                        ProgressView()
                            .tint(.white)
                            .padding(.leading, 8)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(name.isEmpty ? Color.gray.opacity(0.3) : Colors.nasmBlue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(name.isEmpty || isProcessing)
            .padding(.horizontal, cardPadding)
            .padding(.bottom, cardPadding)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .shadow(color: .black.opacity(0.05), radius: shadowRadius, x: 0, y: 4)
    }
    
    // MARK: - Toolbar Content
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .fontWeight(.semibold)
                    Text("Back")
                        .fontWeight(.semibold)
                }
                .foregroundColor(Colors.nasmBlue)
            }
        }
    }
    
    // MARK: - Dialog Buttons
    private var dialogButtons: some View {
        Group {
            Button("Take Photo") { showingCamera = true }
            Button("Choose from Library") { showingImagePicker = true }
            Button("Cancel", role: .cancel) { }
        }
    }
    
    // MARK: - Save Function
    private func saveClient() async {
        isProcessing = true
        
        do {
            guard let userId = dataManager.getUserId() else {
                throw APIError.serverError("User ID not found")
            }
            
            // Initialize imageUrl as empty string
            var imageUrl = ""
            
            // Upload image if one is selected
            if let image = selectedImage, let processedImageData = processImageForUpload(image) {
                print("Uploading client image...")
                imageUrl = try await APIClient.shared.uploadImage(processedImageData)
                print("Image uploaded successfully:", imageUrl)
            }
            
            // Create new client with or without image URL
            let newClient = Client(
                name: name,
                age: Int(age) ?? 0,
                height: Double(height) ?? 0,
                weight: Double(weight) ?? 0,
                medicalHistory: medicalHistory,
                goals: goals,
                clientImage: imageUrl,
                userId: userId
            )
            
            print("Creating client with userId:", userId)
            let savedClient = try await dataManager.addClient(newClient)
            print("Client saved successfully:", savedClient)
            
            await MainActor.run {
                isProcessing = false
                NotificationCenter.default.post(
                    name: NSNotification.Name("RefreshClientData"),
                    object: nil
                )
                print("Posted refresh notification")
                presentationMode.wrappedValue.dismiss()
            }
        } catch {
            print("Save client error:", error)
            await MainActor.run {
                isProcessing = false
                self.error = handleError(error)
                showAlert = true
            }
        }
    }
    
    private func handleError(_ error: Error) -> String {
        switch error {
        case APIError.unauthorized:
            return "Your session has expired. Please log in again"
        case APIError.serverError(let message):
            return "Server error: \(message)"
        case APIError.networkError:
            return "Network error. Please check your connection"
        default:
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Helper Methods
    private func metricField(title: String, value: Binding<String>, unit: String, keyboardType: UIKeyboardType) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            HStack(spacing: 4) {
                TextField("0", text: value)
                    .keyboardType(keyboardType)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 60)
                    .foregroundColor(.primary)
                    .tint(Colors.nasmBlue)
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var medicalHistorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Medical History")
                .font(.headline)
                .foregroundColor(.gray)
            TextEditor(text: $medicalHistory)
                .frame(height: 100)
                .padding(4)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .tint(Colors.nasmBlue)
        }
        .padding(.top, 8)
    }
    
    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Goals")
                .font(.headline)
                .foregroundColor(.gray)
            TextEditor(text: $goals)
                .frame(height: 100)
                .padding(4)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .tint(Colors.nasmBlue)
        }
    }
    
    // MARK: - Profile Image Section
    private var profileImageSection: some View {
        VStack {
            ZStack {
                if let profileImage = selectedImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .padding(25)
                                .foregroundColor(.gray.opacity(0.3))
                        )
                }
                
                // Add Camera Button
                Button(action: { showingActionSheet = true }) {
                    Circle()
                        .fill(Colors.nasmBlue)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .offset(x: 35, y: 35)
            }
            
            // Add "Add Photo" text button
            Button(action: { showingActionSheet = true }) {
                Text(selectedImage == nil ? "Add Photo" : "Change Photo")
                    .font(.subheadline)
                    .foregroundColor(Colors.nasmBlue)
            }
            .padding(.top, 8)
        }
        .padding(.bottom, 16)
    }
    
    // Add the image processing function
    private func processImageForUpload(_ image: UIImage) -> Data? {
        // Calculate target size (20% of original)
        let scale = 0.2
        let targetSize = CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )
        
        // Resize image
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Compress to JPEG with moderate compression
        return resizedImage?.jpegData(compressionQuality: 0.7)
    }
}
