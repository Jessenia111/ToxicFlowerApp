//
//  ViewController.swift
//  ToxicFlower
//
//  Created by Jessenia Tsenkman on 23.11.2024.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
           
           let appearance = UINavigationBarAppearance()
           appearance.configureWithOpaqueBackground()
           appearance.backgroundColor = view.backgroundColor
           appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
           
           navigationController?.navigationBar.standardAppearance = appearance
           navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .camera
    
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            if let resizedImage = resizeImage(image: userPickedImage, targetSize: CGSize(width: 224, height: 224)) {
                guard let convertedCIImage = CIImage(image: resizedImage) else {
                    fatalError("Cannot convert to CIImage.")
                }
                detect(image: convertedCIImage)
                imageView.image = resizedImage
            }
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: trained_model_2().model) else {
            fatalError("Cannot import model")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            if let results = request.results as? [VNCoreMLFeatureValueObservation],
               let multiArray = results.first?.featureValue.multiArrayValue {
                let probabilities: [Float] = {
                    var array: [Float] = []
                    let count = multiArray.count
                    for i in 0..<count {
                        array.append(multiArray[i].floatValue)
                    }
                    return array
                }()

                if let maxIndex = probabilities.firstIndex(of: probabilities.max() ?? 0) {
                    
                    let labels = [
                        "Anthurium",
                        "Chinese Evergreen",
                        "Chinese Money Plant",
                        "Christmas Cactus",
                        "Daffodils",
                        "Dumb Cane",
                        "Elephant Ear",
                        "Hyacinth",
                        "Lilium",
                        "Lily of the Valley",
                        "Monstera Deliciosa",
                        "Prayer Plant",
                        "Snake Plant",
                        "ZZ Plant"
                    ]
                    
                    let toxicityInfo: [String: String] = [
                        "Anthurium": "Toxic to Cats",
                        "Chinese Evergreen": "Toxic to Cats",
                        "Chinese Money Plant": "Non-Toxic to Cats",
                        "Christmas Cactus": "Non-Toxic to Cats",
                        "Daffodils": "Toxic to Cats",
                        "Dumb Cane": "Toxic to Cats",
                        "Elephant Ear": "Toxic to Cats",
                        "Hyacinth": "Toxic to Cats",
                        "Lilium": "Toxic to Cats",
                        "Lily of the Valley": "Toxic to Cats",
                        "Monstera Deliciosa": "Toxic to Cats",
                        "Prayer Plant": "Non-Toxic to Cats",
                        "Snake Plant": "Toxic to Cats",
                        "ZZ Plant": "Toxic to Cats"
                    ]
                    
                    let className = labels[maxIndex]
                    let toxicity = toxicityInfo[className] ?? "Unknown Toxicity"
                    
                    DispatchQueue.main.async {
                        self.navigationItem.title = "\(className) - \(toxicity)"
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.navigationItem.title = "No results found"
                }
                print("No results found")
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print("Error performing request: \(error)")
        }
    }


    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    

}
