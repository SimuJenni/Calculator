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
    
    private enum Op: Printable {
        case Operand(Double)
        case UnaryOperation(String, Double ->Double)
        case BinaryOperation(String, (Double, Double)->Double)
        case SpecialOp(String, Double)
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
            case .ClearOperand():
                opStack = [Op]();
                return (0, opStack)
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainStack) = evaluate(opStack)
        println("\(opStack) = \(result) with remainder \(remainStack)")
        return result
    }
    
    func pushOperand(value: Double) -> Double? {
        opStack.append(Op.Operand(value))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
}