//
//  SlidingTabView.swift
//
//  Copyright (c) 2019 Quynh Nguyen
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import SwiftUI
import ViewExtractor

@available(iOS 15.0, macOS 12.0, *)
/// A customizable sliding tab view with smooth animations and full accessibility support.
///
/// SlidingTabView provides an Android-like tab interface with a sliding selection indicator.
/// It supports customizable colors, fonts, animations, and includes built-in accessibility features.
///
/// Example usage:
/// ```swift
/// @State private var selection = 0
/// SlidingTabView(selection: $selection, tabs: ["Home", "Profile"]) {
///     Text("Home Content")
///     Text("Profile Content")
/// }
/// ```
public struct SlidingTabView<Content:View>: View{

  // MARK: Required Properties

  /// Binding the selection index which will  re-render the consuming view
  @Binding var selection: Int

  /// The title of the tabs
  let tabs: [String]

  let content: () -> Content

  // MARK: View Customization Properties

  /// The font of the tab title
  let font: Font

  /// The selection bar sliding animation type
  let animation: Animation

  /// The accent color when the tab is selected
  let activeAccentColor: Color

  /// The accent color when the tab is not selected
  let inactiveAccentColor: Color

  /// The color of the selection bar
  let selectionBarColor: Color

  /// The tab color when the tab is not selected
  let inactiveTabColor: Color

  /// The tab color when the tab is  selected
  let activeTabColor: Color

  /// The height of the selection bar
  let selectionBarHeight: CGFloat

  /// The selection bar background color
  let selectionBarBackgroundColor: Color

  /// The height of the selection bar background
  let selectionBarBackgroundHeight: CGFloat

  /// Enable horizontal scrolling for overflow tabs
  let isScrollable: Bool

  /// Maximum width for each tab (nil for equal distribution)
  let maxTabWidth: CGFloat?

  /// Environment values for dynamic type and color scheme
  @Environment(\.sizeCategory) private var sizeCategory
  @Environment(\.colorScheme) private var colorScheme

  // MARK: init

  /// Creates a new SlidingTabView
  /// - Parameters:
  ///   - selection: Binding to the currently selected tab index
  ///   - tabs: Array of tab titles to display
  ///   - font: Font for tab titles (supports Dynamic Type)
  ///   - animation: Animation for tab transitions
  ///   - activeAccentColor: Color for the selected tab
  ///   - inactiveAccentColor: Color for unselected tabs
  ///   - selectionBarColor: Color of the selection indicator bar
  ///   - inactiveTabColor: Background color for unselected tabs
  ///   - activeTabColor: Background color for the selected tab
  ///   - selectionBarHeight: Height of the selection indicator
  ///   - selectionBarBackgroundColor: Background color behind the selection bar
  ///   - selectionBarBackgroundHeight: Height of the selection bar background
  ///   - isScrollable: Enable horizontal scrolling for overflow tabs
  ///   - maxTabWidth: Maximum width for each tab (nil for equal distribution)
  ///   - content: ViewBuilder containing the content views for each tab
  public init(selection: Binding<Int>,
              tabs: [String],
              font: Font = .body,
              animation: Animation = .spring(),
              activeAccentColor: Color = .blue,
              inactiveAccentColor: Color = Color.black.opacity(0.4),
              selectionBarColor: Color = .blue,
              inactiveTabColor: Color = .clear,
              activeTabColor: Color = .clear,
              selectionBarHeight: CGFloat = 2,
              selectionBarBackgroundColor: Color = Color.gray.opacity(0.2),
              selectionBarBackgroundHeight: CGFloat = 1,
              isScrollable: Bool = false,
              maxTabWidth: CGFloat? = nil,
              @ViewBuilder content: @escaping () -> Content) {
    self._selection = selection
    self.tabs = tabs
    self.font = font
    self.animation = animation
    self.activeAccentColor = activeAccentColor
    self.inactiveAccentColor = inactiveAccentColor
    self.selectionBarColor = selectionBarColor
    self.inactiveTabColor = inactiveTabColor
    self.activeTabColor = activeTabColor
    self.selectionBarHeight = selectionBarHeight
    self.selectionBarBackgroundColor = selectionBarBackgroundColor
    self.selectionBarBackgroundHeight = selectionBarBackgroundHeight
    self.isScrollable = isScrollable
    self.maxTabWidth = maxTabWidth
    self.content = content
  }

  // MARK: View Construction

  private var tabsView: some View {
    VStack(alignment: .leading, spacing: 0) {

      if isScrollable {
        ScrollView(.horizontal, showsIndicators: false) {
          scrollableTabsContent
        }
      } else {
        fixedTabsContent
      }

      if !isScrollable {
        GeometryReader { geometry in
          ZStack(alignment: .leading) {
            Rectangle()
              .fill(self.selectionBarBackgroundColor)
              .frame(width: geometry.size.width, height: self.selectionBarBackgroundHeight, alignment: .leading)
            Rectangle()
              .fill(self.selectionBarColor)
              .frame(width: self.tabWidth(from: geometry.size.width), height: self.selectionBarHeight, alignment: .leading)
              .offset(x: self.selectionBarXOffset(from: geometry.size.width), y: 0)
              .padding(.vertical, 8)
          }.fixedSize(horizontal: false, vertical: true)
        }.fixedSize(horizontal: false, vertical: true)
      }
    }
  }

  private var fixedTabsContent: some View {
    HStack(spacing: 0) {
      ForEach(Array(tabs.enumerated()), id: \.element) { index, tab in
        tabButton(for: tab, at: index)
      }
    }
  }

  private var scrollableTabsContent: some View {
    HStack(spacing: 8) {
      ForEach(Array(tabs.enumerated()), id: \.element) { index, tab in
        tabButton(for: tab, at: index)
          .frame(maxWidth: maxTabWidth)
      }
    }
    .padding(.horizontal, 16)
  }

  private func tabButton(for tab: String, at index: Int) -> some View {
    Button {
      selectTab(at: index)
    } label: {
      HStack {
        if !isScrollable { Spacer() }
        Text(tab)
          .lineLimit(1)
          .font(font)
          .foregroundColor(
            isSelected(tabIdentifier: tab)
            ? activeAccentColor : inactiveAccentColor
          )
          .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        if !isScrollable { Spacer() }
      }
    }
    .frame(height: adaptiveTabHeight)
    .frame(maxWidth: isScrollable ? .infinity : nil)
    .background(
      isSelected(tabIdentifier: tab)
      ? activeTabColor : inactiveTabColor
    )
    .accessibilityElement()
    .accessibilityLabel(tab)
    .accessibilityHint(isSelected(tabIdentifier: tab) ? "Selected tab" : "Tap to select this tab")
    .accessibilityAddTraits(isSelected(tabIdentifier: tab) ? [.isSelected] : [])
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      tabsView
      Extract(content) { views in
        TabView(selection: $selection) {
          ForEach(Array(zip(views.indices, views)), id: \.1.id) { index, view in
            view.tag(index)
          }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .onChange(of: selection) { _ in
          // Handle selection change with animation
        }
      }
    }
    .accessibilityElement(children: .contain)
    .accessibilityLabel("Tab view with \(tabs.count) tabs")
  }

  // MARK: Private Helper

  /// Safely select a tab at the given index
  private func selectTab(at index: Int) {
    guard index >= 0 && index < tabs.count else { return }
    withAnimation(animation) {
      selection = index
    }
  }

  private func isSelected(tabIdentifier: String) -> Bool {
    guard selection >= 0 && selection < tabs.count else { return false }
    return tabs[selection] == tabIdentifier
  }

  private func selectionBarXOffset(from totalWidth: CGFloat) -> CGFloat {
    return tabWidth(from: totalWidth) * CGFloat(selection)
  }

  private func tabWidth(from totalWidth: CGFloat) -> CGFloat {
    guard tabs.count > 0 else { return 0 }
    return totalWidth / CGFloat(tabs.count)
  }

  /// Dynamic tab height that adapts to content size category
  private var adaptiveTabHeight: CGFloat {
    switch sizeCategory {
    case .extraSmall, .small, .medium:
      return 44
    case .large, .extraLarge:
      return 48
    case .extraExtraLarge, .extraExtraExtraLarge:
      return 52
    case .accessibilityMedium, .accessibilityLarge:
      return 56
    case .accessibilityExtraLarge, .accessibilityExtraExtraLarge, .accessibilityExtraExtraExtraLarge:
      return 60
    @unknown default:
      return 44
    }
  }
}

#if DEBUG

@available(iOS 15.0, macOS 12.0, *)
struct SlidingTabConsumerView : View {
  @State private var selectedTabIndex = 0

  var body: some View {
    SlidingTabView(selection: self.$selectedTabIndex,
                   tabs: ["First", "Second"],
                   font: .body,
                   activeAccentColor: Color.blue,
                   selectionBarColor: Color.blue) {
      Text("First View")
      Text("Second View")
    }
  }
}

@available(iOS 15.0, macOS 12.0, *)
struct SlidingTabView_Previews : PreviewProvider {
  static var previews: some View {
    SlidingTabConsumerView()
  }
}
#endif
