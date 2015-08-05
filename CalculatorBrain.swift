//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by simon jenni on 07/07/2015.
//  Copyright (c) 2015 me. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    var description = ""
    private var descrList = [String]()
    private var opStack = [Op]();
    
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
    
    private var knownOps = [String:Op]()
    
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
                descrList += [operand.description]
                return (operand, remainingOps)
            case .UnaryOperation(_ , let operation):
                let evalRemain = evaluate(remainingOps)
                descrList.insert(op.description + "(", atIndex: descrList.startIndex)
                if let operand = evalRemain.result {
                    descrList += [")"]
                    return (operation(operand), evalRemain.remainingOps)
                }
            case .BinaryOperation(_ , let operation):
                let evalRemain1 = evaluate(remainingOps)
                let tmp = descrList.removeAtIndex(descrList.startIndex)
                if let operand1 = evalRemain1.result {
                    var evalRemain2 = evaluate(evalRemain1.remainingOps)
                    descrList.insert(op.description, atIndex: descrList.endIndex)
                    descrList.insert(tmp, atIndex: descrList.endIndex)
                    if let operand2 = evalRemain2.result {
                        return (operation(operand1, operand2), evalRemain2.remainingOps)
                    }
                }
            case .SpecialOp(_ , let value):
                descrList += [op.description]
                return (value, remainingOps)
            case .Variable(let name):
                if let value = variableValues[name] {
                    descrList += [op.description]
                    return (value, remainingOps)
                } else {
                    return (nil, remainingOps)
                }
            case .ClearOperand():
                descrList = [String]()
                opStack = [Op]();
                return (0, opStack)
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainStack) = evaluate(opStack)
        description = descrList.reduce("", combine: {$0 + $1})
        println("\(opStack) = \(result) with remainder \(remainStack)")
        println(description)
        descrList = [String]()
        return result
    }
    
    func pushOperand(value: Double?) -> Double? {
        opStack.append(Op.Operand(value!))
        return evaluate()
    }
    
    var variableValues = [String: Double]()
    
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
    
}