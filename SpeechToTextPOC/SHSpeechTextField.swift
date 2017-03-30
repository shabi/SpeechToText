//
//  SHSpeechTextField.swift
//  PasswordTextField
//
//  Created by Shabi Haider Naqvi on 27/03/17.
//  Copyright © 2017 Shabi Haider Naqvi. All rights reserved.
//

import UIKit

@available(iOS 10.0, *)
class SHSpeechTextField: UITextField {

  /// Enums with the values of when to show the secure or insecure text button
  public enum ShowButtonWhile: String {
    case UnlessEditing = "unlessEditing"
    case Editing = "editing"
    case Always = "always"
    case Never = "never"
    
    
    var textViewMode: UITextFieldViewMode {
      switch self{
      
      case .UnlessEditing:
        return .unlessEditing
        
      case .Editing:
        return .whileEditing
        
      case .Always:
        return .always
        
      case .Never:
        return .never
        
      }
    }
  }
  
  /**
   Default initializer for the textfield
   
   - pavareter frame: fra me of the view
   
   - returns:
   */
  public override init(frame: CGRect) {
    
    super.init(frame: frame)
    
    setup()
    
  }
  
  /**
   Default initializer for the textfield done from storyboard
   
   - parameter coder: coder
   
   - returns:
   */
  public required init?(coder: NSCoder) {
    
    super.init(coder: coder)
    
    setup()
    
  }
  
  /// When to show the button defaults to only when editing
  open var showButtonWhile = ShowButtonWhile.UnlessEditing{
    
    didSet{
      
      switch showButtonWhile {
        
      case .Editing:
        print("Show x")
      case .UnlessEditing:
        self.rightViewMode = self.showButtonWhile.textViewMode
        
      default:
        break
      }
      
    }
    
  }
  
  /**
   Initialize properties and values
   */
  func setup()
  {
    self.autocapitalizationType = .words
    self.autocorrectionType = .yes
    self.keyboardType = .asciiCapable
    self.rightViewMode = self.showButtonWhile.textViewMode
    self.clearButtonMode = .whileEditing
    self.rightView = self.speechTextButton
    self.speechTextButton.speechRecognised = { [unowned self] (speechText) in
      
      self.text = speechText
    
    }
    
  }
  open lazy var speechTextButton: SHTextSpeechButton = {
    
    return SHTextSpeechButton()
    
  }() 
}
