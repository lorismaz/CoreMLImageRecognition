//
//  ViewController.swift
//  ImageRecognition
//
//  Created by Loris Mazloum on 7/19/17.
//  Copyright © 2017 Loris Mazloum. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var myPhoto: UIImageView!
    @IBOutlet var resultLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func detectImageContent() {
        resultLabel.text = "Thinking..."
        
        guard let model = try? VNCoreMLModel(for: SqueezeNet().model)
            else { fatalError("error loading model") }
        
        //create a vision request
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first
                else { fatalError("unexpected result") }
            for result in results {
                print(result.identifier)
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.resultLabel.isHidden = false
                self?.resultLabel.text = "\(topResult.identifier) \n with \(Int(topResult.confidence * 100))% confidence"
            }
            
        }
        
        guard let ciImage = CIImage(image: self.myPhoto.image!) else { fatalError("Can't create CIImage from UIImage") }
        
        // run the request
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global().async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func pickImage(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            myPhoto.contentMode = .scaleToFill
            myPhoto.image = pickedImage
            self.resultLabel.isHidden = true
        }
        picker.dismiss(animated: true, completion: nil)
        detectImageContent()
    }    
    
}
