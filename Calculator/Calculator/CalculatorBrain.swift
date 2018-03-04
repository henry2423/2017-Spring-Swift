//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Henry on 27/06/2017.
//  Copyright © 2017 henry. All rights reserved.
//

import Foundation

func changeSign(operand: Double) -> Double {
    return -operand
}

func multipy(op1: Double,op2: Double) -> Double {
    return op1 * op2
}

struct CalculatorBrain {
  
    
    mutating func addUnaryOperation(named symbol: String, _ operation: @escaping (Double) -> Double ) {
        operations[symbol] = Operation.unaryOperation(operation)
    }
    
    
    private var accumulator: Double?
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "√" : Operation.unaryOperation(sqrt),      //需要定義一個新type
        "cos" : Operation.unaryOperation(cos),
        "±" : Operation.unaryOperation(changeSign),
        "×" : Operation.binaryOperation(multipy),
        "÷" : Operation.binaryOperation({ (op1, op2) -> Double in return op1 / op2 }),
        "-" : Operation.binaryOperation({ (op1, op2) in op1 - op2 }),
        "+" : Operation.binaryOperation({ $0 + $1 }),
        "=" : Operation.equals
    ]
    
    
    mutating func performOperation(_ symbol: String) {
        
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let Value):
                accumulator = Value
            case .unaryOperation(let function):
                if accumulator != nil {
                    accumulator = function(accumulator!)
                }
            case .binaryOperation(let function):
                if accumulator != nil {
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                    accumulator = nil  //waiting sceondOperand
                }
            case .equals:
                performPendingBinaryOperation()
            }
        }

        /* 舊版寫法
        switch symbol
        {
        case "π":
            accumulator = Double.pi
        //display.text = String(Double.pi)  //"\(Double.pi)"
        case "√":
            if let operand = accumulator
            {
                accumulator = sqrt(operand)
            }
            
            /*
             let operand = Double(display.text!)!
             display.text = String(sqrt(operand))
             */
        default:
            break
        }
        */
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double) {  //因為是copy vale type 所以要告訴struct有更改數值用mutating
        accumulator = operand
    }
    
    var result: Double? {
        get {
            return accumulator
        }
    }
}
