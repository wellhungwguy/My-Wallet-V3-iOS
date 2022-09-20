// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// To regenerate this file use:
/** ```swift
 let locale = NSLocale(localeIdentifier: "en_US")
 var s = "public enum Country: String, Codable {"
 for code in NSLocale.isoCountryCodes as [String] {
     var id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
     if let name = locale.displayName(forKey: NSLocale.Key.identifier, value: id) {
         s.append("\n\n\t/// \(name)")
     }
     id.removeFirst()
     s.append("\n\tcase \(id)")
 }
 print(s + "\n}")
 ```
 */

public enum Country: String, Codable {

    /// Ascension Island
    case AC

    /// Andorra
    case AD

    /// United Arab Emirates
    case AE

    /// Afghanistan
    case AF

    /// Antigua & Barbuda
    case AG

    /// Anguilla
    case AI

    /// Albania
    case AL

    /// Armenia
    case AM

    /// Angola
    case AO

    /// Antarctica
    case AQ

    /// Argentina
    case AR

    /// American Samoa
    case AS

    /// Austria
    case AT

    /// Australia
    case AU

    /// Aruba
    case AW

    /// Åland Islands
    case AX

    /// Azerbaijan
    case AZ

    /// Bosnia & Herzegovina
    case BA

    /// Barbados
    case BB

    /// Bangladesh
    case BD

    /// Belgium
    case BE

    /// Burkina Faso
    case BF

    /// Bulgaria
    case BG

    /// Bahrain
    case BH

    /// Burundi
    case BI

    /// Benin
    case BJ

    /// St. Barthélemy
    case BL

    /// Bermuda
    case BM

    /// Brunei
    case BN

    /// Bolivia
    case BO

    /// Caribbean Netherlands
    case BQ

    /// Brazil
    case BR

    /// Bahamas
    case BS

    /// Bhutan
    case BT

    /// Bouvet Island
    case BV

    /// Botswana
    case BW

    /// Belarus
    case BY

    /// Belize
    case BZ

    /// Canada
    case CA

    /// Cocos [Keeling] Islands
    case CC

    /// Congo - Kinshasa
    case CD

    /// Central African Republic
    case CF

    /// Congo - Brazzaville
    case CG

    /// Switzerland
    case CH

    /// Côte d’Ivoire
    case CI

    /// Cook Islands
    case CK

    /// Chile
    case CL

    /// Cameroon
    case CM

    /// China mainland
    case CN

    /// Colombia
    case CO

    /// Clipperton Island
    case CP

    /// Costa Rica
    case CR

    /// Cuba
    case CU

    /// Cape Verde
    case CV

    /// Curaçao
    case CW

    /// Christmas Island
    case CX

    /// Cyprus
    case CY

    /// Czechia
    case CZ

    /// Germany
    case DE

    /// Diego Garcia
    case DG

    /// Djibouti
    case DJ

    /// Denmark
    case DK

    /// Dominica
    case DM

    /// Dominican Republic
    case DO

    /// Algeria
    case DZ

    /// Ceuta & Melilla
    case EA

    /// Ecuador
    case EC

    /// Estonia
    case EE

    /// Egypt
    case EG

    /// Western Sahara
    case EH

    /// Eritrea
    case ER

    /// Spain
    case ES

    /// Ethiopia
    case ET

    /// Finland
    case FI

    /// Fiji
    case FJ

    /// Falkland Islands
    case FK

    /// Micronesia
    case FM

    /// Faroe Islands
    case FO

    /// France
    case FR

    /// Gabon
    case GA

    /// United Kingdom
    case GB

    /// Grenada
    case GD

    /// Georgia
    case GE

    /// French Guiana
    case GF

    /// Guernsey
    case GG

    /// Ghana
    case GH

    /// Gibraltar
    case GI

    /// Greenland
    case GL

    /// Gambia
    case GM

    /// Guinea
    case GN

    /// Guadeloupe
    case GP

    /// Equatorial Guinea
    case GQ

    /// Greece
    case GR

    /// So. Georgia & So. Sandwich Isl.
    case GS

    /// Guatemala
    case GT

    /// Guam
    case GU

    /// Guinea-Bissau
    case GW

    /// Guyana
    case GY

    /// Hong Kong
    case HK

    /// Heard & McDonald Islands
    case HM

    /// Honduras
    case HN

    /// Croatia
    case HR

    /// Haiti
    case HT

    /// Hungary
    case HU

    /// Canary Islands
    case IC

    /// Indonesia
    case ID

    /// Ireland
    case IE

    /// Israel
    case IL

    /// Isle of Man
    case IM

    /// India
    case IN

    /// British Indian Ocean Territory
    case IO

    /// Iraq
    case IQ

    /// Iran
    case IR

    /// Iceland
    case IS

    /// Italy
    case IT

    /// Jersey
    case JE

    /// Jamaica
    case JM

    /// Jordan
    case JO

    /// Japan
    case JP

    /// Kenya
    case KE

    /// Kyrgyzstan
    case KG

    /// Cambodia
    case KH

    /// Kiribati
    case KI

    /// Comoros
    case KM

    /// St. Kitts & Nevis
    case KN

    /// North Korea
    case KP

    /// South Korea
    case KR

    /// Kuwait
    case KW

    /// Cayman Islands
    case KY

    /// Kazakhstan
    case KZ

    /// Laos
    case LA

    /// Lebanon
    case LB

    /// St. Lucia
    case LC

    /// Liechtenstein
    case LI

    /// Sri Lanka
    case LK

    /// Liberia
    case LR

    /// Lesotho
    case LS

    /// Lithuania
    case LT

    /// Luxembourg
    case LU

    /// Latvia
    case LV

    /// Libya
    case LY

    /// Morocco
    case MA

    /// Monaco
    case MC

    /// Moldova
    case MD

    /// Montenegro
    case ME

    /// St. Martin
    case MF

    /// Madagascar
    case MG

    /// Marshall Islands
    case MH

    /// North Macedonia
    case MK

    /// Mali
    case ML

    /// Myanmar [Burma]
    case MM

    /// Mongolia
    case MN

    /// Macao
    case MO

    /// Northern Mariana Islands
    case MP

    /// Martinique
    case MQ

    /// Mauritania
    case MR

    /// Montserrat
    case MS

    /// Malta
    case MT

    /// Mauritius
    case MU

    /// Maldives
    case MV

    /// Malawi
    case MW

    /// Mexico
    case MX

    /// Malaysia
    case MY

    /// Mozambique
    case MZ

    /// Namibia
    case NA

    /// New Caledonia
    case NC

    /// Niger
    case NE

    /// Norfolk Island
    case NF

    /// Nigeria
    case NG

    /// Nicaragua
    case NI

    /// Netherlands
    case NL

    /// Norway
    case NO

    /// Nepal
    case NP

    /// Nauru
    case NR

    /// Niue
    case NU

    /// New Zealand
    case NZ

    /// Oman
    case OM

    /// Panama
    case PA

    /// Peru
    case PE

    /// French Polynesia
    case PF

    /// Papua New Guinea
    case PG

    /// Philippines
    case PH

    /// Pakistan
    case PK

    /// Poland
    case PL

    /// St. Pierre & Miquelon
    case PM

    /// Pitcairn Islands
    case PN

    /// Puerto Rico
    case PR

    /// Palestinian Territories
    case PS

    /// Portugal
    case PT

    /// Palau
    case PW

    /// Paraguay
    case PY

    /// Qatar
    case QA

    /// Réunion
    case RE

    /// Romania
    case RO

    /// Serbia
    case RS

    /// Russia
    case RU

    /// Rwanda
    case RW

    /// Saudi Arabia
    case SA

    /// Solomon Islands
    case SB

    /// Seychelles
    case SC

    /// Sudan
    case SD

    /// Sweden
    case SE

    /// Singapore
    case SG

    /// St. Helena
    case SH

    /// Slovenia
    case SI

    /// Svalbard & Jan Mayen
    case SJ

    /// Slovakia
    case SK

    /// Sierra Leone
    case SL

    /// San Marino
    case SM

    /// Senegal
    case SN

    /// Somalia
    case SO

    /// Suriname
    case SR

    /// South Sudan
    case SS

    /// São Tomé & Príncipe
    case ST

    /// El Salvador
    case SV

    /// Sint Maarten
    case SX

    /// Syria
    case SY

    /// Eswatini
    case SZ

    /// Tristan da Cunha
    case TA

    /// Turks & Caicos Islands
    case TC

    /// Chad
    case TD

    /// French Southern Territories
    case TF

    /// Togo
    case TG

    /// Thailand
    case TH

    /// Tajikistan
    case TJ

    /// Tokelau
    case TK

    /// Timor-Leste
    case TL

    /// Turkmenistan
    case TM

    /// Tunisia
    case TN

    /// Tonga
    case TO

    /// Turkey
    case TR

    /// Trinidad & Tobago
    case TT

    /// Tuvalu
    case TV

    /// Taiwan
    case TW

    /// Tanzania
    case TZ

    /// Ukraine
    case UA

    /// Uganda
    case UG

    /// U.S. Outlying Islands
    case UM

    /// United States
    case US

    /// Uruguay
    case UY

    /// Uzbekistan
    case UZ

    /// Vatican City
    case VA

    /// St. Vincent & Grenadines
    case VC

    /// Venezuela
    case VE

    /// British Virgin Islands
    case VG

    /// U.S. Virgin Islands
    case VI

    /// Vietnam
    case VN

    /// Vanuatu
    case VU

    /// Wallis & Futuna
    case WF

    /// Samoa
    case WS

    /// Kosovo
    case XK

    /// Yemen
    case YE

    /// Mayotte
    case YT

    /// South Africa
    case ZA

    /// Zambia
    case ZM

    /// Zimbabwe
    case ZW
}

// MARK: - CaseIterable

extension Country: CaseIterable {
    public static let all = Country.allCases.sorted { $0.name < $1.name }
}

extension Country {

    /// The current country (from the current locale)
    public static var current: Country? {
        let locale = NSLocale.current as NSLocale
        return Country(code: locale.countryCode ?? "")
    }

    /// The name of the country
    public var name: String {
        let locale = NSLocale.current as NSLocale
        let rawCode = Self.rawCode(from: code)
        return locale.displayName(forKey: NSLocale.Key.identifier, value: rawCode) ?? ""
    }

    /// The code of the country
    public var code: String {
        rawValue
    }

    /// Initializer with country code
    public init?(code: String) {
        guard let country = Country(rawValue: code) else {
            return nil
        }
        self = country
    }

    private static func rawCode(from code: String) -> String {
        "_\(code)"
    }
}

extension Country {

    // MARK: - Flag (As Emoji Unicode Representation)

    public var flag: String {
        let base: UInt32 = 127397
        var emoji = ""
        for v in code.unicodeScalars {
            guard let scalar = UnicodeScalar(base + v.value) else { return "" }
            emoji.unicodeScalars.append(scalar)
        }
        return emoji
    }
}
