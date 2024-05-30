import SwiftUI

struct NavigationTabs: View {
    @Binding var selectedTab: NavigationTab

    var body: some View {
        VStack(alignment: .crossAlignment, spacing: 0) {
            HStack(spacing: 12) {
                ForEach(NavigationTab.allCases, id: \.self) { tab in
                    Button(
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                self.selectedTab = tab
                            }
                        },
                        label: {
                            Text(tab.rawValue)
                                .frame(maxWidth: .infinity)
                                .font(.body.weight(.medium))
                                .foregroundColor(tab == self.selectedTab ? .blue : .secondary)
                                .padding(.bottom, 8)
                                .padding(.top, 2)
                                .padding(.horizontal, 4)
                                .applyIf(condition: tab == self.selectedTab) {
                                    $0.alignmentGuide(.crossAlignment) { dd in
                                        dd[HorizontalAlignment.center]
                                    }
                                }
                        }
                    )
                }
            }
            Rectangle()
                .fill(Color.blue)
                .frame(maxWidth: (UIScreen.main.bounds.width / CGFloat(NavigationTab.allCases.count)) - CGFloat((NavigationTab.allCases.count - 1) * 6))
                .frame(height: 3)
                .alignmentGuide(.crossAlignment) { dd in
                    dd[HorizontalAlignment.center]
                }
        }
    }
}

extension View {
    @ViewBuilder
    func applyIf<M: View>(condition: Bool, transform: (Self) -> M) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

extension HorizontalAlignment {
    private enum CrossAlignment: AlignmentID {
        static func defaultValue(in dd: ViewDimensions) -> CGFloat {
            dd[HorizontalAlignment.center]
        }
    }

    static let crossAlignment = HorizontalAlignment(CrossAlignment.self)
}
