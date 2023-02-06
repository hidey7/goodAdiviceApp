import UIKit
import CLTypingLabel

class ViewController: UIViewController {
    
    var networkManager = NetworkManager()

    @IBOutlet weak var adviceLabel: CLTypingLabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.networkManager.delegate = self
        self.networkManager.fetchAdviceData()
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.networkManager.fetchAdviceData()
    }

}



//MARK: - NetworkManagerDelegate

extension ViewController: NetworkManagerDelegate {
    
    func adviceDidTranslate(advice: String) {
        DispatchQueue.main.async {
            self.adviceLabel.text = advice
        }
    }
    
    
    func didUpdateAdvice(_ networkManager: NetworkManager, advice: String) {
        networkManager.translate(advice: advice)
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
    
}
