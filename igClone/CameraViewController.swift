//
//  cameraViewController.swift
//  igClone
//
//  Created by Jackson Lu on 3/12/21.
//

import UIKit
import AlamofireImage

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var postText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func onCameraButton(_ sender: Any) {
        //creates an instance of this special camera picker controller
        let picker = UIImagePickerController()
        //set up the delegate
        picker.delegate = self
        picker.allowsEditing = true
        
        //if user interaction of component that a gesture recognizer is in is disabled, it wont actually call the action linked to it
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .camera
        }
        else{
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //cast the info as ui image. need cast because we are going to use this to display picture and we need to guarantee it is a uiimage
        let image = info[.editedImage] as! UIImage
        //dimension of image we want to scale down to
        let size = CGSize(width: 300, height: 300)
        //scale the image
        let scaledImage = image.af.imageScaled(to: size)
        //set the image
        imageView.image = scaledImage
        
        //dismiss the imagepicker controller we presented
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createPost(_ sender: Any) {
    }
    
}
