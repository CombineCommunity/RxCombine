//
//  ViewController.swift
//  ExampleApp
//
//  Created by Shai Mishali on 11/06/2019.
//  Copyright © 2019 Combine Community. All rights reserved.
//

import UIKit
import RxCombine

class ViewController: UIViewController {
    @IBOutlet private var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = "Tap any of the buttons below ... ⬇️"
    }

    @IBAction private func tappedExample(_ sender: UIButton) {
        guard let example = Example(rawValue: sender.tag) else { return }
        example.play(with: textView)
    }
}
