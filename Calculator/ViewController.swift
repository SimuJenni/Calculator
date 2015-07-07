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
    
    @IBAction func Clear(sender: UIButton) {
        display.text = "0"
        history.text = "CLEAR"
        userIsTyping = false
        isFloat = false
        operandStack  = Array<Double>()
    }
    
    
    var operandStack = Array<Double>()
    
    @IBAction func operation(sender: UIButton) {
        let operand = sender.currentTitle!
        if(userIsTyping){
            enter()
        }
        switch operand{
        case "×": performOperation( {$1 * $0}, symbol: "×")
        case "÷": performOperation({$1 / $0}, symbol: "÷")
        case "+": performOperation ({$1 + $0}, symbol: "+")
        case "−": performOperation( {$1 - $0}, symbol: "−")
        case "√": performOperation({sqrt($0)}, symbol: "√")
        case "sin": performOperation({sin($0)}, symbol: "sin")
        case "cos": performOperation({cos($0)}, symbol: "cos")
        case "π": specialValue(M_PI.description, symbol: "π")
        default: break
        }
    }
    
    private func specialValue(value: String, symbol: String) {
        display.text = value
        enter()
    }
    
    private func performOperation(operation: (Double, Double) -> Double, symbol: String) {
        if operandStack.count >= 2 {
            let operand1 = operandStack.removeLast()
            let operand2 = operandStack.removeLast()
            history.text = String(format:"%.2f", operand1) + symbol +  String(format:"%.2f", operand2)
            displayValue = operation(operand1, operand2)
            enter()
        }
    }
    
    private func performOperation(operation: Double ->Double, symbol: String) {
        if operandStack.count >= 1 {
            let operand = operandStack.removeLast()
            history.text = symbol + String(format:"(%.2f)", operand)
            displayValue = operation(operand)
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

