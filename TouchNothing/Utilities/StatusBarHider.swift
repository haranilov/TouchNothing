import SwiftUI
import UIKit

struct StatusBarHider: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> StatusBarHiddenViewController {
        StatusBarHiddenViewController()
    }

    func updateUIViewController(_ uiViewController: StatusBarHiddenViewController, context: Context) {}
}

final class StatusBarHiddenViewController: UIViewController {
    override var prefersStatusBarHidden: Bool { true }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { .none }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        parent?.setNeedsStatusBarAppearanceUpdate()
    }
}

extension View {
    func forceHiddenStatusBar() -> some View {
        background(StatusBarHider())
    }

    func hiddenStatusBarChrome() -> some View {
        statusBarHidden(true)
            .persistentSystemOverlays(.hidden)
            .forceHiddenStatusBar()
    }
}
