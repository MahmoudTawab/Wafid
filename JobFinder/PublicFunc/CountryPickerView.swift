//
//  CountryPickerView.swift
//  JobFinder
//
//  Created by almedadsoft on 14/01/2025.
//

import SwiftUI

struct Country: Identifiable {
    let id = UUID()
    let name: String
    let code: String
    let phoneCode: String
    
    var flag: String {
        let base: UInt32 = 127397
        var flag = ""
        for scalar in code.unicodeScalars {
            flag.unicodeScalars.append(UnicodeScalar(base + scalar.value)!)
        }
        return flag
    }
}

let countries = [
    Country(name: "Afghanistan", code: "AF", phoneCode: "+93"),
    Country(name: "Albania", code: "AL", phoneCode: "+355"),
    Country(name: "Algeria", code: "DZ", phoneCode: "+213"),
    Country(name: "Andorra", code: "AD", phoneCode: "+376"),
    Country(name: "Angola", code: "AO", phoneCode: "+244"),
    Country(name: "Argentina", code: "AR", phoneCode: "+54"),
    Country(name: "Armenia", code: "AM", phoneCode: "+374"),
    Country(name: "Australia", code: "AU", phoneCode: "+61"),
    Country(name: "Austria", code: "AT", phoneCode: "+43"),
    Country(name: "Azerbaijan", code: "AZ", phoneCode: "+994"),
    Country(name: "Bahrain", code: "BH", phoneCode: "+973"),
    Country(name: "Bangladesh", code: "BD", phoneCode: "+880"),
    Country(name: "Belarus", code: "BY", phoneCode: "+375"),
    Country(name: "Belgium", code: "BE", phoneCode: "+32"),
    Country(name: "Benin", code: "BJ", phoneCode: "+229"),
    Country(name: "Bhutan", code: "BT", phoneCode: "+975"),
    Country(name: "Bolivia", code: "BO", phoneCode: "+591"),
    Country(name: "Bosnia and Herzegovina", code: "BA", phoneCode: "+387"),
    Country(name: "Botswana", code: "BW", phoneCode: "+267"),
    Country(name: "Brazil", code: "BR", phoneCode: "+55"),
    Country(name: "Brunei", code: "BN", phoneCode: "+673"),
    Country(name: "Bulgaria", code: "BG", phoneCode: "+359"),
    Country(name: "Burkina Faso", code: "BF", phoneCode: "+226"),
    Country(name: "Burundi", code: "BI", phoneCode: "+257"),
    Country(name: "Cambodia", code: "KH", phoneCode: "+855"),
    Country(name: "Cameroon", code: "CM", phoneCode: "+237"),
    Country(name: "Canada", code: "CA", phoneCode: "+1"),
    Country(name: "Chad", code: "TD", phoneCode: "+235"),
    Country(name: "Chile", code: "CL", phoneCode: "+56"),
    Country(name: "China", code: "CN", phoneCode: "+86"),
    Country(name: "Colombia", code: "CO", phoneCode: "+57"),
    Country(name: "Comoros", code: "KM", phoneCode: "+269"),
    Country(name: "Congo", code: "CG", phoneCode: "+242"),
    Country(name: "Costa Rica", code: "CR", phoneCode: "+506"),
    Country(name: "Croatia", code: "HR", phoneCode: "+385"),
    Country(name: "Cuba", code: "CU", phoneCode: "+53"),
    Country(name: "Cyprus", code: "CY", phoneCode: "+357"),
    Country(name: "Czech Republic", code: "CZ", phoneCode: "+420"),
    Country(name: "Denmark", code: "DK", phoneCode: "+45"),
    Country(name: "Djibouti", code: "DJ", phoneCode: "+253"),
    Country(name: "Dominica", code: "DM", phoneCode: "+1767"),
    Country(name: "Dominican Republic", code: "DO", phoneCode: "+1"),
    Country(name: "Ecuador", code: "EC", phoneCode: "+593"),
    Country(name: "Egypt", code: "EG", phoneCode: "+20"),
    Country(name: "El Salvador", code: "SV", phoneCode: "+503"),
    Country(name: "Equatorial Guinea", code: "GQ", phoneCode: "+240"),
    Country(name: "Eritrea", code: "ER", phoneCode: "+291"),
    Country(name: "Estonia", code: "EE", phoneCode: "+372"),
    Country(name: "Eswatini", code: "SZ", phoneCode: "+268"),
    Country(name: "Ethiopia", code: "ET", phoneCode: "+251"),
    Country(name: "Fiji", code: "FJ", phoneCode: "+679"),
    Country(name: "Finland", code: "FI", phoneCode: "+358"),
    Country(name: "France", code: "FR", phoneCode: "+33"),
    Country(name: "Gabon", code: "GA", phoneCode: "+241"),
    Country(name: "Gambia", code: "GM", phoneCode: "+220"),
    Country(name: "Georgia", code: "GE", phoneCode: "+995"),
    Country(name: "Germany", code: "DE", phoneCode: "+49"),
    Country(name: "Ghana", code: "GH", phoneCode: "+233"),
    Country(name: "Greece", code: "GR", phoneCode: "+30"),
    Country(name: "Grenada", code: "GD", phoneCode: "+1473"),
    Country(name: "Guatemala", code: "GT", phoneCode: "+502"),
    Country(name: "Guinea", code: "GN", phoneCode: "+224"),
    Country(name: "Guyana", code: "GY", phoneCode: "+592"),
    Country(name: "Haiti", code: "HT", phoneCode: "+509"),
    Country(name: "Honduras", code: "HN", phoneCode: "+504"),
    Country(name: "Hungary", code: "HU", phoneCode: "+36"),
    Country(name: "Iceland", code: "IS", phoneCode: "+354"),
    Country(name: "India", code: "IN", phoneCode: "+91"),
    Country(name: "Indonesia", code: "ID", phoneCode: "+62"),
    Country(name: "Iran", code: "IR", phoneCode: "+98"),
    Country(name: "Iraq", code: "IQ", phoneCode: "+964"),
    Country(name: "Ireland", code: "IE", phoneCode: "+353"),
    Country(name: "Israel", code: "IL", phoneCode: "+972"),
    Country(name: "Italy", code: "IT", phoneCode: "+39"),
    Country(name: "Jamaica", code: "JM", phoneCode: "+1876"),
    Country(name: "Japan", code: "JP", phoneCode: "+81"),
    Country(name: "Jordan", code: "JO", phoneCode: "+962"),
    Country(name: "Kazakhstan", code: "KZ", phoneCode: "+7"),
    Country(name: "Kenya", code: "KE", phoneCode: "+254"),
    Country(name: "Kuwait", code: "KW", phoneCode: "+965"),
    Country(name: "Kyrgyzstan", code: "KG", phoneCode: "+996"),
    Country(name: "Laos", code: "LA", phoneCode: "+856"),
    Country(name: "Latvia", code: "LV", phoneCode: "+371"),
    Country(name: "Lebanon", code: "LB", phoneCode: "+961"),
    Country(name: "Lesotho", code: "LS", phoneCode: "+266"),
    Country(name: "Liberia", code: "LR", phoneCode: "+231"),
    Country(name: "Libya", code: "LY", phoneCode: "+218"),
    Country(name: "Lithuania", code: "LT", phoneCode: "+370"),
    Country(name: "Luxembourg", code: "LU", phoneCode: "+352"),
    Country(name: "Madagascar", code: "MG", phoneCode: "+261"),
    Country(name: "Malawi", code: "MW", phoneCode: "+265"),
    Country(name: "Malaysia", code: "MY", phoneCode: "+60"),
    Country(name: "Maldives", code: "MV", phoneCode: "+960"),
    Country(name: "Mali", code: "ML", phoneCode: "+223"),
    Country(name: "Malta", code: "MT", phoneCode: "+356"),
    Country(name: "Mauritania", code: "MR", phoneCode: "+222"),
    Country(name: "Mauritius", code: "MU", phoneCode: "+230"),
    Country(name: "Mexico", code: "MX", phoneCode: "+52"),
    Country(name: "Moldova", code: "MD", phoneCode: "+373"),
    Country(name: "Monaco", code: "MC", phoneCode: "+377"),
    Country(name: "Mongolia", code: "MN", phoneCode: "+976"),
    Country(name: "Montenegro", code: "ME", phoneCode: "+382"),
    Country(name: "Morocco", code: "MA", phoneCode: "+212"),
    Country(name: "Mozambique", code: "MZ", phoneCode: "+258"),
    Country(name: "Myanmar", code: "MM", phoneCode: "+95"),
    Country(name: "Namibia", code: "NA", phoneCode: "+264"),
    Country(name: "Nepal", code: "NP", phoneCode: "+977"),
    Country(name: "Netherlands", code: "NL", phoneCode: "+31"),
    Country(name: "New Zealand", code: "NZ", phoneCode: "+64"),
    Country(name: "Nicaragua", code: "NI", phoneCode: "+505"),
    Country(name: "Niger", code: "NE", phoneCode: "+227"),
    Country(name: "Nigeria", code: "NG", phoneCode: "+234"),
    Country(name: "North Korea", code: "KP", phoneCode: "+850"),
    Country(name: "North Macedonia", code: "MK", phoneCode: "+389"),
    Country(name: "Norway", code: "NO", phoneCode: "+47"),
    Country(name: "Oman", code: "OM", phoneCode: "+968"),
    Country(name: "Pakistan", code: "PK", phoneCode: "+92"),
    Country(name: "Palestine", code: "PS", phoneCode: "+970"),
    Country(name: "Panama", code: "PA", phoneCode: "+507"),
    Country(name: "Papua New Guinea", code: "PG", phoneCode: "+675"),
    Country(name: "Paraguay", code: "PY", phoneCode: "+595"),
    Country(name: "Peru", code: "PE", phoneCode: "+51"),
    Country(name: "Philippines", code: "PH", phoneCode: "+63"),
    Country(name: "Poland", code: "PL", phoneCode: "+48"),
    Country(name: "Portugal", code: "PT", phoneCode: "+351"),
    Country(name: "Qatar", code: "QA", phoneCode: "+974"),
    Country(name: "Romania", code: "RO", phoneCode: "+40"),
    Country(name: "Russia", code: "RU", phoneCode: "+7"),
    Country(name: "Rwanda", code: "RW", phoneCode: "+250"),
    Country(name: "Saudi Arabia", code: "SA", phoneCode: "+966"),
    Country(name: "Senegal", code: "SN", phoneCode: "+221"),
    Country(name: "Serbia", code: "RS", phoneCode: "+381"),
    Country(name: "Singapore", code: "SG", phoneCode: "+65"),
    Country(name: "Slovakia", code: "SK", phoneCode: "+421"),
    Country(name: "Slovenia", code: "SI", phoneCode: "+386"),
    Country(name: "Somalia", code: "SO", phoneCode: "+252"),
    Country(name: "South Africa", code: "ZA", phoneCode: "+27"),
    Country(name: "South Korea", code: "KR", phoneCode: "+82"),
    Country(name: "Spain", code: "ES", phoneCode: "+34"),
    Country(name: "Sri Lanka", code: "LK", phoneCode: "+94"),
    Country(name: "Sudan", code: "SD", phoneCode: "+249"),
    Country(name: "Suriname", code: "SR", phoneCode: "+597"),
    Country(name: "Sweden", code: "SE", phoneCode: "+46"),
    Country(name: "Switzerland", code: "CH", phoneCode: "+41"),
    Country(name: "Syria", code: "SY", phoneCode: "+963"),
    Country(name: "Taiwan", code: "TW", phoneCode: "+886"),
    Country(name: "Tajikistan", code: "TJ", phoneCode: "+992"),
    Country(name: "Tanzania", code: "TZ", phoneCode: "+255"),
    Country(name: "Thailand", code: "TH", phoneCode: "+66"),
    Country(name: "Togo", code: "TG", phoneCode: "+228"),
    Country(name: "Tunisia", code: "TN", phoneCode: "+216"),
    Country(name: "Turkey", code: "TR", phoneCode: "+90"),
    Country(name: "Turkmenistan", code: "TM", phoneCode: "+993"),
    Country(name: "Uganda", code: "UG", phoneCode: "+256"),
    Country(name: "Ukraine", code: "UA", phoneCode: "+380"),
    Country(name: "United Arab Emirates", code: "AE", phoneCode: "+971"),
    Country(name: "United Kingdom", code: "GB", phoneCode: "+44"),
    Country(name: "United States", code: "US", phoneCode: "+1"),
    Country(name: "Uruguay", code: "UY", phoneCode: "+598"),
    Country(name: "Uzbekistan", code: "UZ", phoneCode: "+998"),
    Country(name: "Venezuela", code: "VE", phoneCode: "+58"),
    Country(name: "Vietnam", code: "VN", phoneCode: "+84"),
    Country(name: "Yemen", code: "YE", phoneCode: "+967"),
    Country(name: "Zambia", code: "ZM", phoneCode: "+260"),
    Country(name: "Zimbabwe", code: "ZW", phoneCode: "+263")
]

struct CountryPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedCountry: Country
    @State private var searchText = ""
    
    var filteredCountries: [Country] {
        if searchText.isEmpty {
            return countries
        }
        return countries.filter { $0.name.lowercased().contains(searchText.lowercased()) }
    }
    
    var body: some View {
        NavigationView {
            List(filteredCountries) { country in
                Button(action: {
                    selectedCountry = country
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Text(country.flag)
                        Text(country.name)
                        Spacer()
                        Text(country.phoneCode)
                            .foregroundColor(.gray)
                    }
                }
            }
            .tint(.black)
            .searchable(text: $searchText, prompt: "Search country")
            .navigationTitle("Select Country")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }.foregroundColor(rgbToColor(red: 193, green: 140, blue: 70)))
        }
    }
    
}

