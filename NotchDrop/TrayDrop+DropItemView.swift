//
//  TrayDrop+DropItemView.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/8.
//

import Foundation
import Pow
import SwiftUI
import UniformTypeIdentifiers

struct DropItemView: View {
    let item: TrayDrop.DropItem
    @StateObject var vm: NotchViewModel
    @StateObject var tvm = TrayDrop.shared

    @State var hover = false

    var isSelected: Bool {
        tvm.isSelected(item.id)
    }

    var body: some View {
        VStack {
            Image(nsImage: item.workspacePreviewImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 64)
            Text(item.fileName)
                .multilineTextAlignment(.center)
                .font(.system(.footnote, design: .rounded))
                .frame(maxWidth: 64)
                .lineLimit(2)
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.white.opacity(0.2) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
        )
        .contentShape(Rectangle())
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .scale),
            removal: .movingParts.poof
        ))
        .onHover { hover = $0 }
        .scaleEffect(hover ? 1.05 : 1.0)
        .animation(vm.animation, value: hover)
        .animation(vm.animation, value: isSelected)
        .draggable(draggablePayload)
        .onTapGesture {
            handleTap()
        }
        .overlay {
            Image(systemName: "xmark.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(.red)
                .background(Color.white.clipShape(Circle()).padding(1))
                .frame(width: vm.spacing, height: vm.spacing)
                .opacity(vm.optionKeyPressed ? 1 : 0)
                .scaleEffect(vm.optionKeyPressed ? 1 : 0.5)
                .animation(vm.animation, value: vm.optionKeyPressed)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .offset(x: vm.spacing / 2, y: -vm.spacing / 2)
                .onTapGesture { handleDelete() }
        }
    }

    private var draggablePayload: MultipleDropItems {
        if isSelected && tvm.selectedItems.count > 1 {
            return MultipleDropItems(items: tvm.selectedDropItems)
        } else {
            return MultipleDropItems(items: [item])
        }
    }

    private func handleTap() {
        guard !vm.optionKeyPressed else { return }

        if vm.commandKeyPressed {
            tvm.toggleSelection(item.id)
        } else {
            if isSelected && tvm.selectedItems.count == 1 {
                tvm.clearSelection()
                vm.notchClose()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    NSWorkspace.shared.open(item.storageURL)
                }
            } else {
                tvm.selectOnly(item.id)
            }
        }
    }

    private func handleDelete() {
        if tvm.selectedItems.isEmpty || (tvm.selectedItems.count == 1 && isSelected) {
            tvm.delete(item.id)
        } else if isSelected {
            tvm.deleteSelected()
        } else {
            tvm.delete(item.id)
        }
    }
}
