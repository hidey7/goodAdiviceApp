import Foundation

struct AdviceData: Decodable {
    let slip: Advice
}

struct Advice: Decodable {
    let advice: String
}
