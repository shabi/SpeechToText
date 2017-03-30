//
//  SHTextSpeechButton.swift
//  PasswordTextField
//
//  Created by Shabi Haider Naqvi on 27/03/17.
//  Copyright © 2017 Shabi Haider Naqvi. All rights reserved.
//

import UIKit
import Speech

enum SpeechStatus {
  case ready
  case recognizing
  case unavailable
}

//textField.clearButtonMode = .whileEditing
@available(iOS 10.0, *)
class SHTextSpeechButton: UIButton {

  fileprivate let RightMargin:CGFloat = 10.0
  fileprivate let Width:CGFloat = 20.0
  fileprivate let Height:CGFloat = 20.0
  
  fileprivate let audioEngine = AVAudioEngine()
  fileprivate let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
  fileprivate let request = SFSpeechAudioBufferRecognitionRequest()
  fileprivate var recognitionTask: SFSpeechRecognitionTask?
  
  var speechRecognised:((String)->Void)? = nil
  
  var status = SpeechStatus.ready {
    didSet {
      self.setSpeechIcon(status: status)
    }
  }

  public override init(frame: CGRect) {
    
    super.init(frame: frame)
    
    setup()
    
  }
  
  public required init?(coder: NSCoder) {
    
    super.init(coder: coder)
    
    setup()
    
  }
  
  /**
   Set Up Speech Button images
   */
  func setSpeechIcon(status: SpeechStatus) {
    
    switch status {
    case .ready:
      self.setImage(#imageLiteral(resourceName: "available"), for: .normal)
    case .recognizing:
      self.setImage(#imageLiteral(resourceName: "stop"), for: .normal)
    case .unavailable:
      self.setImage(#imageLiteral(resourceName: "unavailable"), for: .normal)
    }
  }
  
  /**
   Initialize properties and values
   */
  func setup()
  {
    
      switch SFSpeechRecognizer.authorizationStatus() {
      case .notDetermined:
        askSpeechPermission()
      case .authorized:
        self.status = .ready
      case .denied, .restricted:
        self.status = .unavailable
      }
    
    
    //Initialize the frame and adds a right margin
    self.frame = CGRect(x: 0, y: -0, width: Width, height: Height)
    
    //Sets the aspect fit of the image
    self.contentMode = UIViewContentMode.scaleAspectFit
    self.backgroundColor = UIColor.clear
    
    //Sets the button target
    self.addTarget(self, action: #selector(SHTextSpeechButton.buttonTouch), for: .touchUpInside)
    
  }
  
  /// Ask permission to the user to access their speech data.
  func askSpeechPermission() {
    
      SFSpeechRecognizer.requestAuthorization { status in
        OperationQueue.main.addOperation {
          switch status {
          case .authorized:
            self.status = .ready
          default:
            self.status = .unavailable
          }
        }
      }
  }
  
  /// Start streaming the microphone data to the speech recognizer to recognize it live.
  func startRecording() {
    
    // Setup audio engine and speech recognizer
    guard let node = audioEngine.inputNode else { return }
    let recordingFormat = node.outputFormat(forBus: 0)
    node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
      self.request.append(buffer)
    }
    
    // Prepare and start recording
    audioEngine.prepare()
    do {
      try audioEngine.start()
      self.status = .recognizing
    } catch {
      return print(error)
    }
    
    // Analyze the speech
    recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
      if let result = result {
        
        if let speechRecognised = self.speechRecognised {
          
          speechRecognised(result.bestTranscription.formattedString)
        }
      } else if let error = error {
        print(error)
      }
    })
  }
  
 
  /// Stops and cancels the speech recognition.
  func cancelRecording() {
    audioEngine.stop()
    if let node = audioEngine.inputNode {
      node.removeTap(onBus: 0)
    }
    recognitionTask?.cancel()
  }
  
  /**
   Update the Speech icon
   */
  open func buttonTouch() {

    switch status {
    case .ready:
      startRecording()
      status = .recognizing
    case .recognizing:
      cancelRecording()
      status = .ready
    default:
      break
    }
  }
  
  /**
   Hide Speech recognition buttion if Textfiel is in editing mode
   */
  open func resetSpeechButton(isEditingText: Bool) {
  
    cancelRecording()
    status = .ready
    self.isHidden = false
    if isEditingText {
      self.isHidden = true
    }
  }

}
