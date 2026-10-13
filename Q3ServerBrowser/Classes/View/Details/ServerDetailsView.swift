//
//  ServerDetailsView.swift
//  Q3ServerBrowser
//
//  Created by Andrea G on 15/04/2022.
//

import SwiftUI
import WebKit
import GameServerQueryLibrary

struct ServerDetailsView: View {
    @ObservedObject var gameViewModel: GameViewModel

    @State private var settingsFilter: String = ""
    @State private var configExpanded: Bool = false
    @State private var didCopyAddress: Bool = false

    var body: some View {
        if let server = gameViewModel.server(by: gameViewModel.currentSelectedServer) {
            VStack(spacing: 0) {
                // Fixed upper section: map, identity and the Connect action stay visible.
                hero(server: server)
                header(server: server)

                Divider()

                // Scrollable lower section: score, players, configuration.
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        if server.hasTeamScores {
                            scoreboard(server: server)
                            Divider()
                        }

                        PlayersView(server: server)

                        Divider()
                            .padding(.top, 8)

                        serverConfigSection(server: server)
                    }
                }
            }
        } else {
            ContentUnavailableView(
                "Select a Server",
                systemImage: "list.bullet.rectangle",
                description: Text("Choose a server from the list to see who is playing.")
            )
        }
    }

    // MARK: - Hero

    private func hero(server: Server) -> some View {
        // The placeholder shows until the levelshot fades in (or if it never loads).
        ZStack {
            Rectangle()
                .fill(.quaternary)
            Image(systemName: "photo")
                .font(.title2)
                .foregroundStyle(.tertiary)
            WebMapImageView(mapName: server.map)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .clipped()
    }

    // MARK: - Header

    private func header(server: Server) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(server.displayName)
                        .font(.title3.weight(.semibold))
                        .lineLimit(2)
                        .textSelection(.enabled)
                    if server.isPasswordProtected {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(.secondary)
                            .help("Password protected")
                    }
                }
                Text(summaryLine(server: server))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            statsLine(server: server)

            HStack(spacing: 8) {
                Button {
                    GameLauncher.connect(to: server, game: gameViewModel.currentGameType)
                } label: {
                    Text("Connect")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button {
                    copyAddress(of: server)
                } label: {
                    Label(didCopyAddress ? "Copied" : server.hostname,
                          systemImage: didCopyAddress ? "checkmark" : "doc.on.doc")
                        .font(.callout.monospaced())
                }
                .controlSize(.large)
                .help("Copy address")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
    }

    private func summaryLine(server: Server) -> String {
        [server.modeLabel == "—" ? "" : server.modeLabel, server.map, server.displayMod]
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }

    private func statsLine(server: Server) -> some View {
        HStack(spacing: 14) {
            stat("\(server.currentPlayerCount)",
                 suffix: "/\(server.maxPlayerCount) players",
                 style: server.isFullServer ? AnyShapeStyle(Color.red) : AnyShapeStyle(HierarchicalShapeStyle.primary))
            if server.pingInt > 0 {
                stat("\(server.pingInt)",
                     suffix: " ms",
                     style: Color.pingWarning(for: server.pingInt).map { AnyShapeStyle($0) }
                        ?? AnyShapeStyle(HierarchicalShapeStyle.primary))
            }
            if let timeLimit = server.timeLimit {
                stat("\(timeLimit)", suffix: " min")
            }
            if let limit = server.scoreLimit {
                stat("\(limit.value)", suffix: " \(limit.label)")
            }
        }
        .monospacedDigit()
    }

    private func stat(_ value: String,
                      suffix: String,
                      style: AnyShapeStyle = AnyShapeStyle(HierarchicalShapeStyle.primary)) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(style)
            Text(suffix)
                .foregroundStyle(.secondary)
        }
    }

    private func copyAddress(of server: Server) {
        Pasteboard.copy(server.hostname)
        didCopyAddress = true
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            didCopyAddress = false
        }
    }

    // MARK: - Scoreboard

    private func scoreboard(server: Server) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("Red")
                .fontWeight(.semibold)
                .foregroundStyle(.red)
            Text(server.teamRed?.score ?? "–")
                .font(.title.weight(.semibold))
            Spacer()
            Text(server.teamBlue?.score ?? "–")
                .font(.title.weight(.semibold))
            Text("Blue")
                .fontWeight(.semibold)
                .foregroundStyle(.blue)
        }
        .monospacedDigit()
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - Server configuration

    private func serverConfigSection(server: Server) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            CollapsibleHeader(title: "Server Configuration",
                              count: server.rules.count,
                              isExpanded: $configExpanded)

            if configExpanded {
                TextField("Filter settings", text: $settingsFilter)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 6)

                let filtered = server.rules
                    .filter {
                        settingsFilter.isEmpty
                        || $0.key.localizedCaseInsensitiveContains(settingsFilter)
                        || $0.value.localizedCaseInsensitiveContains(settingsFilter)
                    }
                    .sorted { $0.key < $1.key }

                ForEach(filtered) { setting in
                    HStack(alignment: .firstTextBaseline) {
                        Text(setting.key)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(setting.value.cleanedQ3Name)
                            .monospacedDigit()
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .font(.callout)
                    .textSelection(.enabled)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 3)
                }
                .padding(.bottom, 8)
            }
        }
    }
}

// MARK: - WebMapImageView

/// Loads a map levelshot from ws.q3df.org, which sits behind Cloudflare.
///
/// Cloudflare blocks plain URLSession / AsyncImage requests because they cannot execute the JS
/// challenge. WKWebView can run the challenge, but Cloudflare will not redirect back to a bare
/// image URL after solving it — only to HTML pages. The fix is a two-step load:
///
///   1. **Warm-up**: navigate to the map's HTML page on ws.q3df.org. WKWebView runs the
///      Cloudflare challenge, receives the `cf_clearance` cookie, and lands on the real page.
///   2. **Image load**: once the warm-up page finishes (title ≠ "Just a moment…"), navigate to
///      the image URL. The cookie is now present, so the server returns the JPEG with HTTP 200.
///
/// The WKWebView is kept fully transparent (alphaValue 0) during the warm-up so the user never
/// sees the intermediate HTML page. It fades in once the image is ready.
private struct WebMapImageView: NSViewRepresentable {
    let mapName: String

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.setValue(false, forKey: "drawsBackground")
        webView.alphaValue = 0
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        let c = context.coordinator
        guard c.currentMap != mapName else { return }
        c.currentMap = mapName
        c.imageURL   = "https://ws.q3df.org/images/authorshots/512x384/\(mapName).jpg"
        c.stage      = .warmingUp
        webView.alphaValue = 0
        // Step 1: load the map's HTML page to acquire the Cloudflare clearance cookie.
        if let url = URL(string: "https://ws.q3df.org/map/\(mapName)/") {
            webView.load(URLRequest(url: url))
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var currentMap = ""
        var imageURL   = ""
        var stage      = Stage.idle

        enum Stage { case idle, warmingUp, loadingImage, done }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            switch stage {
            case .warmingUp:
                // The Cloudflare challenge page title is "Just a moment...".
                // Wait until the real page loads before proceeding to the image.
                webView.evaluateJavaScript("document.title") { [weak self, weak webView] result, _ in
                    guard let self, let webView else { return }
                    let title = (result as? String) ?? ""
                    guard !title.isEmpty, title != "Just a moment..." else { return }
                    self.stage = .loadingImage
                    if let url = URL(string: self.imageURL) {
                        webView.load(URLRequest(url: url))
                    }
                }

            case .loadingImage:
                // WebKit wraps a bare JPEG in minimal HTML: <html><body><img …></body></html>.
                // Inject CSS so the image fills the frame. If there is no <img> yet (still getting
                // an HTML challenge redirect), return false and wait for the next didFinish.
                let js = """
                    (function() {
                        var img = document.querySelector('img');
                        if (!img) return false;
                        document.documentElement.style.cssText =
                            'margin:0;padding:0;width:100%;height:100%;overflow:hidden;background:transparent;';
                        document.body.style.cssText =
                            'margin:0;padding:0;width:100%;height:100%;background:transparent;';
                        img.style.cssText =
                            'width:100%;height:100vh;object-fit:cover;display:block;';
                        return true;
                    })()
                """
                webView.evaluateJavaScript(js) { [weak self, weak webView] result, _ in
                    guard let self, let webView, result as? Bool == true else { return }
                    self.stage = .done
                    NSAnimationContext.runAnimationGroup { ctx in
                        ctx.duration = 0.35
                        webView.animator().alphaValue = 1
                    }
                }

            default:
                break
            }
        }

        // Warm-up page unavailable (map not listed on ws.q3df.org, network error, etc.) —
        // try the image directly; the Cloudflare cookie may be valid from a prior session.
        func webView(_ webView: WKWebView, didFailProvisionalNavigation _: WKNavigation!, withError _: Error) {
            skipWarmup(webView)
        }
        func webView(_ webView: WKWebView, didFail _: WKNavigation!, withError _: Error) {
            skipWarmup(webView)
        }
        private func skipWarmup(_ webView: WKWebView) {
            guard stage == .warmingUp else { return }
            stage = .loadingImage
            if let url = URL(string: imageURL) { webView.load(URLRequest(url: url)) }
        }
    }
}
