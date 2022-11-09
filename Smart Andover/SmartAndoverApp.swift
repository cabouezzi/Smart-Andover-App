//
//  Smart_AndoverApp.swift
//  Smart Andover
//
//  Created by Chaniel Ezzi on 8/12/21.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        DatabaseController.configure()
        UIScrollView.appearance().bounces = true
        
        return true
        
    }
    
}

@main
struct SmartAndoverApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State var user: User? = nil
    
    //For logo animation in login/register view
    @Namespace var namespace
    
    @State var currentPage: NavigationPages = .home
    
    @State var keychainLoaded: Bool = false
    
    var body: some Scene {
        
        WindowGroup {
            
            //Tutorial
            if UserDefaults.IsFirstLaunch() {
                
                TutorialView()
                
            }
            
            //Main
            else if user != nil {
                
                VStack(spacing: 0) {
                    
                    HStack {
                        
                        currentPage.label()
                            .font(.system(.title3, design: .serif))
                            .foregroundColor(.themeDark)
                            .transition(.opacity)
                            .padding()
                            .background(Color.systemBackground.ignoresSafeArea())
                        
                        Spacer()
                        
                        
                    }
                    .frame(height: 50)
                    .padding(.horizontal)
                    
                    ZStack {
                        
                        MasterView(selectedTab: $currentPage)
                            .onAppear {
                                currentPage = .home
                            }
                        
                    }
                        
                }
                //After matching the design to the OG, dark mode looks disgusting
                .preferredColorScheme(.light)
                .statusBar(hidden: false)
                .environment(\.currentUser, $user)
                .onAppear {
                    DatabaseController.database
                        .collection("Users")
                        .document(user!.email)
                        .addSnapshotListener { query, error in
                            
                            guard let query = query else { return }
                            
                            user?.points =  query.get("points") as! Int
                            
                        }
                }
                
            }
            
            //Login
            else {
                
                VStack(spacing: 10) {
                    
                    Spacer()
                    
                    SmartAndoverLogo()
                        .matchedGeometryEffect(id: "LOGO", in: namespace)
                        .scaleEffect(1.5)
                    
                    if keychainLoaded {
                        LoginView(user: $user)
                    }
                    else {
                        ProgressView()
                            .onAppear {
                                do {
                                    try Keychain.autoSignIn($user) {
                                        keychainLoaded = true
                                    }
                                }
                                catch {
                                    withAnimation {
                                        keychainLoaded = true
                                    }
                                }
                            }
                    }
                    
                    Spacer()
                    
                }
                .animation(.easeInOut)
                .environment(\.currentUser, $user)
                
            }
            
        }
        
    }
    
}
