//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by simon jenni on 07/07/2015.
//  Copyright (c) 2015 me. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private var opStack = [Op]();
    private var knownOps = [String:Op]()
    var variableValues = [String: Double]()

    private enum Op: Printable {
        case Operand(Double)
        case UnaryOperation(String, Double ->Double)
        case BinaryOperation(String, (Double, Double)->Double)
        case SpecialOp(String, Double)
        case Variable(String)
        case ClearOperand()
        
        var description: String {
            get {
                switch self {
                case .Operand(let value):
                    return "\(value)"
                case .BinaryOperation(let symbol, _ ):
                    return symbol
                case .SpecialOp(let symbol, _ ):
                    return symbol
                case .UnaryOperation(let symbol, _ ):
                    return symbol
                case .Variable(let name):
                    return name
                case .ClearOperand():
                    return "CLEAR"
                }
            }
        }
    }
    
    init() {
        knownOps["×"] = Op.BinaryOperation("×", *)
        knownOps["÷"] = Op.BinaryOperation("÷", {$1 / $0})
        knownOps["+"] = Op.BinaryOperation("+", +)
        knownOps["−"] = Op.BinaryOperation("−", {$1 - $0})
        knownOps["√"] = Op.UnaryOperation("√", sqrt)
        knownOps["sin"] = Op.UnaryOperation("sin", sin)
        knownOps["cos"] = Op.UnaryOperation("cos", cos)
        knownOps["C"] = Op.ClearOperand()
        knownOps["π"] = Op.SpecialOp("π", M_PI)
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_ , let operation):
                let evalRemain = evaluate(remainingOps)
                if let operand = evalRemain.result {
                    return (operation(operand), evalRemain.remainingOps)
                }
            case .BinaryOperation(_ , let operation):
                let evalRemain1 = evaluate(remainingOps)
                if let operand1 = evalRemain1.result {
                    var evalRemain2 = evaluate(evalRemain1.remainingOps)
                    if let operand2 = evalRemain2.result {
                        return (operation(operand1, operand2), evalRemain2.remainingOps)
                    }
                }
            case .SpecialOp(_ , let value):
                return (value, remainingOps)
            case .Variable(let name):
                if let value = variableValues[name] {
                    return (value, remainingOps)
                } else {
                    return (nil, remainingOps)
                }
            case .ClearOperand():
                opStack = [Op]();
                variableValues = [String: Double]()
                return (0, opStack)
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainStack) = evaluate(opStack)
        println("\(opStack) = \(result) with remainder \(remainStack)")
        println("\(variableValues)")
        return result
    }
    
    func pushOperand(value: Double?) -> Double? {
        opStack.append(Op.Operand(value!))
        return evaluate()
    }
    
    
    func pushOperand(value: String) -> Double? {
        opStack.append(Op.Variable(value))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    var description: String {
        get {
            var (result, ops) = ("", opStack)
            do {
                var current: String?
                (current, ops) = description(ops)
                result = (result == "") ? current! : "\(current!), \(result)"
            } while ops.count>0
            return result
        }
    }
    
    private func description(ops: [Op]) -> (result: String?, remainingOps: [Op]) {
        var remainingOps = ops
        
        if !ops.isEmpty {
            let op = remainingOps.removeLast()
            
            switch op {
            case .Operand(let operand):
                return (operand.description , remainingOps)
            case .UnaryOperation(_ , let operation):
                let evalRemain = description(remainingOps)
                if let operand = evalRemain.result {
                    return (op.description+"("+operand+")", evalRemain.remainingOps)
                }
            case .BinaryOperation(_ , let operation):
                let evalRemain1 = description(remainingOps)
                if let operand1 = evalRemain1.result {
                    var evalRemain2 = description(evalRemain1.remainingOps)
                    if let operand2 = evalRemain2.result {
                        var op2 = operand2
                        if evalRemain1.remainingOps.count > 2 {
                            op2 = "("+op2+")"
                        }
                        var result = op2+op.description+operand1
                        if evalRemain2.remainingOps.count > 0 {
                            result = "("+result+")"
                        }
                        return (result, evalRemain2.remainingOps)
                    }
                }
            case .SpecialOp(_ , let value):
                return (op.description, remainingOps)
            case .Variable(let name):
                if let value = variableValues[name] {
                    return (op.description, remainingOps)
                }
            case .ClearOperand():
                return ("", opStack)
                
            }
        }
        return ("?", remainingOps)
    }
    
}