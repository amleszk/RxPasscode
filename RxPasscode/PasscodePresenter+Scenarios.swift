
extension PasscodePresenter {

    func presentWithBlurBackground() {
        screenshotAndPresentPasscodeObstructionIfNeeded()
    }
    
    func presentWithValidatePasscode(allowCancel: Bool = false, completion: PresentationCompletion? = nil) {
        screenshotAndPresentPasscodeObstructionIfNeeded()
        guard let passcodeDatasource = passcodeDatasource else {
            return
        }
        var numberOfTries = 0
        let existingPasscode: [Int] = passcodeDatasource.passcode()
        passcodeLockViewController = PasscodeLockViewController(validateCode: { passcode in
            return self.passcodeValidateHandler(existingPasscode, nextPasscode: passcode, numberOfTries: &numberOfTries)
            }, dismiss: passcodeDismiss(completion))
        passcodeLockViewController.cancelButtonEnabled = allowCancel
        passcodeView.pinView(passcodeLockViewController.view)
    }
    
    func presentWithNewPasscode(completion: PresentationCompletion? = nil) {
        screenshotAndPresentPasscodeObstructionIfNeeded()
        var newPasscode: [Int] = []
        passcodeLockViewController = PasscodeLockViewController(validateCode: { passcode in
            return self.passcodeSetNewHandler(passcode, capturedPasscode: &newPasscode)
            }, dismiss: passcodeDismiss(completion))
        passcodeLockViewController.cancelButtonEnabled = true
        passcodeView.pinView(passcodeLockViewController.view)
    }
    
    func presentWithChangePasscode(completion: PresentationCompletion? = nil) {
        screenshotAndPresentPasscodeObstructionIfNeeded()
        guard let passcodeDatasource = passcodeDatasource else {
            return
        }
        let existingPasscode: [Int] = passcodeDatasource.passcode()
        var validated = false
        var newPasscode: [Int] = []
        var numberOfTries = 0
        passcodeLockViewController = PasscodeLockViewController(validateCode: { passcode in
            if !validated {
                return self.passcodeEnterNewHandler(existingPasscode, nextPasscode: passcode, numberOfTries: &numberOfTries, validated: &validated)
            } else {
                return self.passcodeSetNewHandler(passcode, capturedPasscode: &newPasscode)
            }
            }, dismiss: passcodeDismiss(completion))
        passcodeLockViewController.cancelButtonEnabled = true
        passcodeView.pinView(passcodeLockViewController.view)
    }
    
    //MARK: Callbacks
    
    func passcodeDismiss(completion: PresentationCompletion? = nil) -> PresentationCompletion {
        return { didCancel in
            self.dismissAnimated(true) {
                completion?(didCancel)
            }
        }
    }
    
    func passcodeSetNewHandler(nextPasscode: [Int], inout capturedPasscode: [Int]) -> PasscodeLockViewController.PasscodeResponse {
        if capturedPasscode.count == 0 {
            capturedPasscode = nextPasscode
            return .ReEnter
        } else if capturedPasscode == nextPasscode {
            passcodeDatasource?.didSetNewPasscode(capturedPasscode)
            return .Accepted
        } else {
            return .Invalid
        }
    }
    
    func passcodeValidateHandler(existingPasscode: [Int], nextPasscode: [Int], inout numberOfTries: Int) -> PasscodeLockViewController.PasscodeResponse {
        if nextPasscode == existingPasscode {
            return .Accepted
        } else {
            numberOfTries += 1
            if numberOfTries >= passcodeMaxNumberTries {
                passcodeDatasource?.didFailAllPasscodeAttempts()
            }
            return .Invalid
        }
    }
    
    func passcodeEnterNewHandler(existingPasscode: [Int], nextPasscode: [Int], inout numberOfTries: Int, inout validated: Bool) -> PasscodeLockViewController.PasscodeResponse {
        var value = self.passcodeValidateHandler(existingPasscode, nextPasscode: nextPasscode, numberOfTries: &numberOfTries)
        if(value == .Accepted) {
            validated = true
            value = .EnterNew
        }
        return value
    }
}
