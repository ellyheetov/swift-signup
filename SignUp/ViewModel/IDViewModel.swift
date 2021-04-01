//
//  IDViewModel.swift
//  SignUp
//
//  Created by 박혜원 on 2021/03/31.
//

import UIKit
import Combine

protocol ValidCheckViewModel {
    associatedtype State
    typealias ControlActionClosure = (State) -> ()
    
    var isValid : State { get set }
    func checkValidation() -> Bool
    func bind(control : @escaping ControlActionClosure)
}

class IDViewModel: NSObject, ValidCheckViewModel {
    
    @IBOutlet weak var id: UITextField!
    
    typealias State = IDValidState
    
    var isValid : State
    
    private var actionHandler : ControlActionClosure?
    private var cancellable : AnyCancellable?
    
    override init(){
        isValid = State.init()
        super.init()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(idTextFieldEditingChanged(textField:)),
            name: UITextField.textDidEndEditingNotification,
            object: nil)
        
        cancellable = isValid.objectWillChange.sink {
            self.actionHandler?(self.isValid)
        }
    }
    
    // 아이디 유효검사는 "다음"버튼을 누른 시점으로 변경하기
    func checkValidation() -> Bool {
        guard let text = id.text else { return false }
        return ValidationCheckService.isValidId(input: text)
    }
    func bind(control : @escaping ControlActionClosure) {
        self.actionHandler = control
    }
    @objc func idTextFieldEditingChanged(textField : UITextField){
        if checkValidation() {
            isValid.setValid()
        } else {
            isValid.setNotValid()
        }
    }
}

