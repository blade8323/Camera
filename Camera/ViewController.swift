//
//  ViewController.swift
//  Camera
//
//  Created by Владислав Соколов on 12.09.2020.
//  Copyright © 2020 Владислав Соколов. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MobileCoreServices

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var takePictureButton: UIButton!
    var avPlayerViewController: AVPlayerViewController!
    var image: UIImage?
    var movieURL: URL?
    var lastChosenMediaType: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            takePictureButton.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateDisplay()
    }
    
    func updateDisplay() {
        if let mediaType = lastChosenMediaType {
            if mediaType == (kUTTypeImage as NSString) as String {
                imageView.image = image!
                imageView.isHidden = false
                if avPlayerViewController != nil {
                    avPlayerViewController.view.isHidden = true
                }
            } else {
                if mediaType == (kUTTypeMovie as NSString) as String {
                    if avPlayerViewController == nil {
                        avPlayerViewController = AVPlayerViewController()
                        let avplayerView = avPlayerViewController.view
                        avplayerView?.frame = imageView.frame
                        avplayerView?.clipsToBounds = true
                        view.addSubview(avplayerView!)
                        setAVPlayerViewLayoutConstraints()
                    }
                    if let url = movieURL {
                        imageView.isHidden = true
                        avPlayerViewController.player = AVPlayer(url: url)
                        avPlayerViewController.view.isHidden = false
                        avPlayerViewController.player!.play()
                    }
                }
            }
        }
    }
    
    func setAVPlayerViewLayoutConstraints() {
        let avPlayerView = avPlayerViewController.view
        avPlayerView?.translatesAutoresizingMaskIntoConstraints = false
        let views = [
            "avPlayerView": avPlayerView!,
            "takePictureButton": takePictureButton!
        ]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[avPlayerView]|", options: .alignAllLeft, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[avPlayerView]-0-[takePictureButton]|", options: .alignAllLeft, metrics: nil, views: views))
    }
    
    func pickMediaFromSource(_ sourceType: UIImagePickerController.SourceType) {
        let mediaTypes = UIImagePickerController.availableMediaTypes(for: sourceType)!
        if UIImagePickerController.isSourceTypeAvailable(sourceType) && mediaTypes.count > 0 {
            let picker = UIImagePickerController()
            picker.mediaTypes = mediaTypes
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = sourceType
            present(picker, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Error accessing media", message: "Unsupported media source.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        lastChosenMediaType = info[UIImagePickerController.InfoKey.mediaType] as? String
        if let mediaType = lastChosenMediaType {
            if mediaType == (kUTTypeImage as NSString) as String {
                image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
            } else if mediaType == (kUTTypeMovie as NSString) as String {
                movieURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    @IBAction func shootPictureOrVideo(sender: UIButton) {
        pickMediaFromSource(UIImagePickerController.SourceType.camera)
    }
    
    @IBAction func selectExistingPictureOrVideo(sender: UIButton) {
        pickMediaFromSource(UIImagePickerController.SourceType.photoLibrary)
    }
}

