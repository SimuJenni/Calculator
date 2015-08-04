//
//  ViewController.swift
//  Calculator
//
//  Created by simon jenni on 20/06/2015.
//  Copyright (c) 2015 me. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    var userIsTyping = false
    var isFloat = false
    
    var brain = CalculatorBrain()
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsTyping {
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsTyping = true
        }
    }
    
    @IBAction func makeFloat(sender: UIButton) {
        if userIsTyping {
            if (!isFloat) {
                display.text = display.text!+"."
                isFloat = true
            }
        } else {
            display.text = "0."
        }
    }
    
    
    @IBAction func operation(sender: UIButton) {
        if(userIsTyping){
            enter()
        }
        if let operand = sender.currentTitle {
            if let result = brain.performOperation(operand){
                displayValue = result
            } else {
                displayValue = 0
            }
        }
    }
    
    private func specialValue(value: String, symbol: String) {
        display.text = value
        enter()
    }
    
    
    @IBAction func enter() {
        userIsTyping = false
        isFloat = false
        if let result = brain.pushOperand(displayValue) {
            displayValue = result
        } else {
            displayValue = 0
        }
    }
    
    var displayValue: Double? {
        get{
            return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
        }
        set {
            display.text = "\(newValue!)"
            userIsTyping = false
        }
    }
    
}

