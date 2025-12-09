//
//  TrayDrop+View.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/8.
//

import Combine
import SwiftUI

struct TrayView: View {
    @StateObject var vm: NotchViewModel
    @StateObject var tvm = TrayDrop.shared

    @State private var targeting = false

    // Drag selection state
    @State private var isDragSelecting = false
    @State private var dragStartLocation: CGPoint = .zero
    @State private var dragCurrentLocation: CGPoint = .zero
    @State private var itemFrames: [TrayDrop.DropItem.ID: CGRect] = [:]

    var storageTime: String {
        switch tvm.selectedFileStorageTime {
        case .oneHour:
            return NSLocalizedString("an hour", comment: "")
        case .oneDay:
            return NSLocalizedString("a day", comment: "")
        case .twoDays:
            return NSLocalizedString("two days", comment: "")
        case .threeDays:
            return NSLocalizedString("three days", comment: "")
        case .oneWeek:
            return NSLocalizedString("a week", comment: "")
        case .never:
            return NSLocalizedString("forever", comment: "")
        case .custom:
            let localizedTimeUnit = NSLocalizedString(tvm.customStorageTimeUnit.localized.lowercased(), comment: "")
            return "\(tvm.customStorageTime) \(localizedTimeUnit)"
        }
    }

    var body: some View {
        panel
            .onDrop(of: [.data], isTargeted: $targeting) { providers in
                DispatchQueue.global().async { tvm.loadFiltered(providers) }
                return true
            }
    }

    var panel: some View {
        RoundedRectangle(cornerRadius: vm.cornerRadius)
            .strokeBorder(style: StrokeStyle(lineWidth: 4, dash: [10]))
            .foregroundStyle(.white.opacity(0.1))
            .background(loading)
            .overlay {
                content
                    .padding()
            }
            .animation(vm.animation, value: tvm.items)
            .animation(vm.animation, value: tvm.isLoading)
    }

    var loading: some View {
        RoundedRectangle(cornerRadius: vm.cornerRadius)
            .foregroundStyle(.white.opacity(0.1))
            .conditionalEffect(
                .repeat(
                    .glow(color: .blue, radius: 50),
                    every: 1.5
                ),
                condition: tvm.isLoading > 0
            )
    }

    var text: String {
        [
            String(
                format: NSLocalizedString("Drag files here to keep them for %@", comment: ""),
                storageTime
            ),
            "&",
            NSLocalizedString("Press Option to delete", comment: ""),
        ].joined(separator: " ")
    }

    private var selectionRect: CGRect {
        let minX = min(dragStartLocation.x, dragCurrentLocation.x)
        let maxX = max(dragStartLocation.x, dragCurrentLocation.x)
        let minY = min(dragStartLocation.y, dragCurrentLocation.y)
        let maxY = max(dragStartLocation.y, dragCurrentLocation.y)
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    var content: some View {
        Group {
            if tvm.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "tray.and.arrow.down.fill")
                    Text(text)
                        .multilineTextAlignment(.center)
                        .font(.system(.headline, design: .rounded))
                }
            } else {
                GeometryReader { geometry in
                    ZStack {
                        ScrollView(.horizontal) {
                            HStack(spacing: vm.spacing) {
                                ForEach(tvm.items) { item in
                                    DropItemView(item: item, vm: vm, tvm: tvm)
                                        .background(
                                            GeometryReader { itemGeometry in
                                                Color.clear
                                                    .onAppear {
                                                        let frame = itemGeometry.frame(in: .named("TrayContainer"))
                                                        itemFrames[item.id] = frame
                                                    }
                                                    .onChange(of: itemGeometry.frame(in: .named("TrayContainer"))) { newFrame in
                                                        itemFrames[item.id] = newFrame
                                                    }
                                            }
                                        )
                                }
                            }
                            .padding(vm.spacing)
                        }
                        .padding(-vm.spacing)
                        .scrollIndicators(.never)

                        // Selection box overlay
                        if isDragSelecting {
                            Rectangle()
                                .fill(Color.accentColor.opacity(0.2))
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.accentColor, lineWidth: 1)
                                )
                                .frame(width: selectionRect.width, height: selectionRect.height)
                                .position(
                                    x: selectionRect.midX,
                                    y: selectionRect.midY
                                )
                        }
                    }
                    .coordinateSpace(name: "TrayContainer")
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 5)
                            .onChanged { value in
                                if !isDragSelecting {
                                    isDragSelecting = true
                                    dragStartLocation = value.startLocation
                                    if !vm.commandKeyPressed {
                                        tvm.clearSelection()
                                    }
                                }
                                dragCurrentLocation = value.location
                                updateSelectionFromDrag()
                            }
                            .onEnded { _ in
                                isDragSelecting = false
                            }
                    )
                    .onTapGesture {
                        if !vm.commandKeyPressed {
                            tvm.clearSelection()
                        }
                    }
                }
            }
        }
    }

    private func updateSelectionFromDrag() {
        var newSelection: Set<TrayDrop.DropItem.ID> = vm.commandKeyPressed ? tvm.selectedItems : []

        for (itemId, frame) in itemFrames {
            if selectionRect.intersects(frame) {
                newSelection.insert(itemId)
            }
        }

        tvm.selectItems(newSelection)
    }
}

#Preview {
    NotchContentView(vm: .init())
        .padding()
        .frame(width: 550, height: 150, alignment: .center)
        .background(.black)
        .preferredColorScheme(.dark)
}
