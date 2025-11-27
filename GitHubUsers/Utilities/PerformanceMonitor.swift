//
//  PerformanceMonitor.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import Foundation
import os.log

/// Мониторинг производительности приложения
class PerformanceMonitor {
    static let shared = PerformanceMonitor()
    
    private let logger = Logger(subsystem: "com.cursordemoapp", category: "Performance")
    
    private init() {}
    
    /// Измерение времени выполнения операции
    func measure<T>(_ operation: String, _ block: () async throws -> T) async rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        defer {
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            logger.info("⏱️ \(operation): \(String(format: "%.3f", timeElapsed))s")
        }
        return try await block()
    }
    
    /// Измерение времени выполнения синхронной операции
    func measure<T>(_ operation: String, _ block: () throws -> T) rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        defer {
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            logger.info("⏱️ \(operation): \(String(format: "%.3f", timeElapsed))s")
        }
        return try block()
    }
    
    /// Логирование использования памяти
    func logMemoryUsage() {
        var memoryInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &memoryInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            let usedMemory = Double(memoryInfo.resident_size) / 1024.0 / 1024.0
            logger.info("💾 Memory usage: \(String(format: "%.2f", usedMemory)) MB")
        }
    }
}

// Для компиляции нужен import Darwin
import Darwin

