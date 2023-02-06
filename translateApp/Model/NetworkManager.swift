import Foundation
import Alamofire

struct DeepLResult: Codable {
    let translations: [Translation]
    struct Translation: Codable {
        let text: String
        let detected_source_language: String
    }
}


protocol NetworkManagerDelegate {
    func didUpdateAdvice(_ networkManager: NetworkManager, advice: String)
    func didFailWithError(error: Error)
    func adviceDidTranslate(advice: String)
}



struct NetworkManager {
    
    let adviceUrlString = "https://api.adviceslip.com/advice"
    let authKey = KeyManager().getValue(key: "deepLAuthKey") as! String
    
    var delegate: NetworkManagerDelegate?
    
    func fetchAdviceData() {
        
        if let url = URL(string: self.adviceUrlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if let error = error {
                    print(error)
                }
                
                if let safeData = data {
                    let decoder = JSONDecoder()
                    do {
                        let decodeData = try decoder.decode(AdviceData.self, from: safeData)
                        let advice = decodeData.slip.advice
                        delegate?.didUpdateAdvice(self, advice: advice)
                    } catch {
                        delegate?.didFailWithError(error: error)
                    }
                }
            }
            task.resume()
        }
        
        
    }
    
    func translate(advice: String) {
         
        let parameters: [String: String] = [
            "text": advice,
            "target_lang": "JA",
            "auth_key": authKey
        ]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]

        let decoder = JSONDecoder()
        AF.request("https://api-free.deepl.com/v2/translate", method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default, headers: headers).responseDecodable(of: DeepLResult.self, decoder: decoder) { response in
            
            if case .success = response.result {
                do {
                    let result = try decoder.decode(DeepLResult.self, from: response.data!)
                    let  translatedText =  result.translations[0].text
                    delegate?.adviceDidTranslate(advice: translatedText)
                } catch {
                    debugPrint("デコード失敗")
                }
            } else {
                debugPrint("APIリクエストエラー, \(response.error)")
            }
        }
        
    }
    
}
