//
//  Screen4AskScanBarcode.swift
//  eDepositBag
//
//  Created by Evan on 11/2/23.
//

import SwiftUI
import Combine

struct Screen3BagInfoEdit: View {
    @EnvironmentObject var bag: Bag
    @EnvironmentObject var imageTypeList: ImageTypeList
    @EnvironmentObject var tabModel: TabModel
    
    @State private var isScanFail = false
    
    // view tags
    enum ShowView{
        case ask, next, showBagNum
    }
    
    @State private var showView = ShowView.ask
    @State private var startScan = false
    
    var body: some View {
        NavigationView {
            VStack{
                // info selection
                ScrollView{
                    VStack(spacing: 20) {
                        // department
                        HStack {
                            Text("Department")
                                .fontWeight(.medium)
                            Spacer()
                            VStack{
                                Picker("Department", selection: $tabModel.bagDepartment) {
                                    ForEach(bag.departments, id: \.self) { dept in
                                        Text(dept)
                                    }
                                }
                                
                                .environment(\.colorScheme, .dark)
                                .pickerStyle(MenuPickerStyle())
                                .frame(width: 170)
                                .padding(.vertical,4)
                                .padding(.horizontal, 15)
                                .background(.white.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                
                                if (tabModel.bagDepartment == "Other"){
                                    TextField("Department", text: $tabModel.bagDepartmentOther)
                                        .environment(\.colorScheme, .dark)
                                        .frame(width: 170)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 15)
                                        .background(.white.opacity(0.2))
                                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                }
                            }
                        }
                        // location
                        HStack {
                            Text("Retail Location")
                                .fontWeight(.medium)
                            Spacer()
                            VStack{
                                Picker("Location", selection: $tabModel.bagRetailLocation) {
                                    ForEach(tabModel.bagRetailLocationList, id: \.self) { location in
                                        Text(location)
                                    }
                                }
                                .environment(\.colorScheme, .dark)
                                .pickerStyle(MenuPickerStyle())
                                .frame(width: 170)
                                .padding(.vertical,4)
                                .padding(.horizontal, 15)
                                .background(.white.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                if (tabModel.bagRetailLocation == "Other"){
                                    TextField("Retail Location", text: $tabModel.bagRetailLocationOther)
                                        .environment(\.colorScheme, .dark)
                                        .frame(width: 170)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 15)
                                        .background(.white.opacity(0.2))
                                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                }
                            }

                        }
                        // POS
                        HStack {
                            Text("POS Name")
                                .fontWeight(.medium)
                            Spacer()
                            TextField("POS Name", text: $tabModel.bagPOSName)
                                .environment(\.colorScheme, .dark)
                                .frame(width: 170)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 15)
                                .background(.white.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        // date
                        HStack {
                            Text("Revenue Date")
                                .fontWeight(.medium)
                            Spacer()
                            DatePicker("Select a date", selection: $tabModel.bagRevenueDatePicker, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                                .environment(\.colorScheme, .dark)
                                .frame(width: 170)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 15)
                 
                        }
                    }
                    //can not be edited
                    .disabled(showView == .next ? true : false)
                    .font(.body)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    
                    
                    // show bag num
                    if(showView == .next){
                        HStack {
                            Text("Bag Number")
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                            Spacer()

                            if let code = tabModel.bagScannedCode{
                                Text(code)
                                    .multilineTextAlignment(.center)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 200)
                                    .foregroundColor(.blue)
                            }else{
                                Text("No Bag Number")
                                    .environment(\.colorScheme, .dark)
                                    .frame(width: 170)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 15)
                                    .background(.white.opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }

                        }
                        .padding([.top, .leading, .trailing], 20)
                    }
                }

                
                Spacer()
                
                // handle scan
                VStack{
                    switch showView {
                    // ask if scan is needed
                    case .ask:
                        Text("Are you sending cash deposit to University Cashiering?")
                            .font(.title2)
                            .foregroundColor(Color.white)
                            .multilineTextAlignment(.center)

                        HStack(spacing: 40) {
                            Button(action: {
                                withAnimation{
                                    tabModel.bagScannedCode = nil
                                    showView = .next
                                }
                            }) {
                                Text("No")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                            .background(Color.red)
                            .opacity(0.8)
                            .cornerRadius(15)
                            
                            Button(action: {
                                withAnimation{
                                    showView = .showBagNum
                                }
                            }) {
                                Text("Yes")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                            .background(Color.green)
                            .opacity(0.8)
                            .cornerRadius(15)
                        }
                        .padding(.horizontal, 50.0)
                        .shadow(color: .black.opacity(0.2), radius: 10)
                        .padding(.top, 20)
    
                    // handle the scan
                    case .showBagNum:
                        Text("Please press the button below to scan the barcode on the deposit bag.")
                            .font(.title2)
                            .foregroundColor(Color.white)
                            .padding(.bottom)
                            .multilineTextAlignment(.center)
                        
                        if (isScanFail) {
                            Text("Scanning failed. Please try again.")
                                .font(.title2)
                                .foregroundColor(Color.red)
                                .padding(.bottom)
                                .multilineTextAlignment(.center)
                        }
                        
                        HStack {
                            Text("Bag Number")
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                            Spacer()
                                
                            Button(action: {
                                withAnimation {
                                    startScan = true
                                }
                            }) {
                                if let code = tabModel.bagScannedCode{
                                    Text(code)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                }else{
                                    Text("Scan")
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                }
                            }
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(15)
                            .frame(width: 200)
                            .shadow(color: .black.opacity(0.2), radius: 10)
                        }
                        .padding([.top, .leading, .trailing], 20)
                        
                    // scan finished
                    case .next:
                        HStack(spacing: 40) {
                            Button(action: {
                                withAnimation{
                                    showView = .ask
                                    
                                }
                            }) {
                                Text("Back")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                            .background(Color.red)
                            .opacity(0.8)
                            .cornerRadius(15)
                            
                            NavigationLink(destination: Screen4FileScan()
                                .environmentObject(bag)
                                .environmentObject(imageTypeList)
                                .environmentObject(tabModel)
                            ) {
                                Text("Next")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                            .background(Color.green)
                            .opacity(0.8)
                            .cornerRadius(15)
                        }
                        .padding(.horizontal, 50.0)
                        .shadow(color: .black.opacity(0.2), radius: 10)
                    }

                }

            }
            .foregroundStyle(.white)
            .padding(.horizontal,10)
            .padding(.vertical, 20)

            
            .background {
                Image("bg1")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .overlay(Color.black.opacity(0.1))
                TransparentBlur(removeAllFilters: false)
            }

            .navigationTitle("Deposit Bag Info")
            .navigationBarTitleDisplayMode(.large)
        }

        
        // barcode scan view
        .sheet(isPresented: $startScan, onDismiss: scanSheetDismissed) {
            BarcodeScan(isPresentingScanner: self.$startScan, scannedCode: self.$tabModel.bagScannedCode, isScanFail: self.$isScanFail)
        }
        
        // appearance adjustment
        .onAppear{
            UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white.withAlphaComponent(0.9)]
        }
        
        // when picker changes
        .onChange(of: tabModel.bagDepartment){ newValue in
            tabModel.bagRetailLocationList = bag.locationSelections[newValue] ?? []
            // give the location picker a default choice
            if !tabModel.bagRetailLocationList.contains(tabModel.bagRetailLocation) {
                tabModel.bagRetailLocation = tabModel.bagRetailLocationList[0]
            }
        }
        
        // submit
        .onChange(of: showView){ _ in
            //set this information for the bag, account defaults should be changed separate
            bag.department = (tabModel.bagDepartment == "Other") ?  tabModel.bagDepartmentOther : tabModel.bagDepartment
            
            bag.retailLocation = (tabModel.bagRetailLocation == "Other") ?  tabModel.bagRetailLocationOther : tabModel.bagRetailLocation

            bag.POSName = tabModel.bagPOSName
            
            // format the date string
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            bag.revenueDate = dateFormatter.string(from: tabModel.bagRevenueDatePicker)
            
            if let scanned = tabModel.bagScannedCode {
                bag.bagNum = scanned
            }else{
                bag.bagNum = "No Bag Number"
            }
            
            // save to sandbox
            let _ = bag.save()
        }
    }
    
    func scanSheetDismissed() {
        if(!isScanFail){
            showView = .next
        }
    }
}



struct Screen3BagInfoEdit_Previews: PreviewProvider {
    static var previews: some View {
        let bag = Bag()
        TabControl(selection: TabViewTag.bag)
            .environmentObject(bag)
    }
}
