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
    
    var userIsTyping = false
    var isFloat = false
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsTyping {
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsTyping = true
        }
        println("digit = \(digit)")
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
    
    var operandStack = Array<Double>()
    
    @IBAction func operation(sender: UIButton) {
        let operand = sender.currentTitle!
        if(userIsTyping){
            enter()
        }
        switch operand{
        case "×": performOperation {$1 * $0}
        case "÷": performOperation {$1 / $0}
        case "+": performOperation {$1 + $0}
        case "−": performOperation {$1 - $0}
        case "√": performOperation {sqrt($0)}
        case "sin": performOperation {sin($0)}
        case "cos": performOperation {cos($0)}
        case "π": display.text = M_PI.description
            enter()
        default: break
        }
    }
    
    private func performOperation(operation: (Double, Double) -> Double) {
        if operandStack.count >= 2 {
            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
            enter()
        }
    }
    
    private func performOperation(operation: Double ->Double) {
        if operandStack.count >= 1 {
            displayValue = operation(operandStack.removeLast())
            enter()
        }
    }
    
    @IBAction func enter() {
        userIsTyping = false
        operandStack.append(displayValue)
        println("\(operandStack)")
        isFloat = false
    }
    
    var displayValue: Double {
        get{
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            display.text = "\(newValue)"
            userIsTyping = false
        }
    }
    
}

