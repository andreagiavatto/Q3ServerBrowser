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
    @State private var configExpanded: Bool = true

    var body: some View {
        Group {
            if let selection = gameViewModel.currentSelectedServer,
               let server = gameViewModel.server(by: selection) {
                VStack(spacing: 0) {
                    // Fixed upper section: hero image + stat cards
                    heroSection(server: server)
                    statCards(server: server)
                        .padding(.top, 10)

                    Divider()
                        .padding(.top, 10)

                    // Scrollable lower section: players + server config
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            PlayersView(server: server)

                            Divider()

                            serverConfigSection(server: server)
                        }
                    }
                }
            } else {
                ContentUnavailableView(
                    "Select a Server",
                    systemImage: "list.bullet.rectangle",
                    description: Text("Choose a server from the list to view its details.")
                )
            }
        }
    }

    // MARK: - Hero

    @ViewBuilder
    private func heroSection(server: Server) -> some View {
        ZStack(alignment: .bottomLeading) {
            // Map image
            WebMapImageView(mapName: server.map)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()

            // Gradient scrim so text is legible over any image
            LinearGradient(
                colors: [.black.opacity(0), .black.opacity(0.82)],
                startPoint: .center,
                endPoint: .bottom
            )

            // Overlaid server identity
            VStack(alignment: .leading, spacing: 8) {
                Text(server.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 1)

                Text("\(server.map)\(server.mod.isEmpty || server.mod == "baseq3" ? "" : " · \(server.mod)")")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))

                // Gametype / mod / ping badges
                HStack(spacing: 8) {
                    if !server.gametype.isEmpty, server.gametype != "unknown" {
                        heroBadge(server.gametype.uppercased())
                    }
                    if !server.mod.isEmpty, server.mod != "baseq3" {
                        heroBadge(server.mod)
                    }
                    if server.pingInt > 0 {
                        heroBadge("\(server.pingInt) ms")
                    }
                }
            }
            .padding(12)
        }
        .frame(height: 180)
    }

    @ViewBuilder
    private func heroBadge(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.white.opacity(0.9))
            .padding(.horizontal, 7)
            .padding(.vertical, 2)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 4, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .strokeBorder(.white.opacity(0.2), lineWidth: 0.5)
            )
    }

    // MARK: - Stat cards

    @ViewBuilder
    private func statCards(server: Server) -> some View {
        HStack(spacing: 8) {
            statCard {
                playerCard(server: server)
            }
            statCard {
                pingCard(server: server)
            }
            statCard {
                timeCard(server: server)
            }
        }
        .padding(.horizontal, 12)
    }

    @ViewBuilder
    private func statCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(.quaternary.opacity(0.6),
                        in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    @ViewBuilder
    private func playerCard(server: Server) -> some View {
        let fraction: Double = {
            guard let c = Double(server.currentPlayers),
                  let m = Double(server.maxPlayers), m > 0 else { return 0 }
            return min(c / m, 1)
        }()
        let barColour: Color = fraction >= 0.9 ? .red : fraction >= 0.5 ? .orange : .green

        VStack(alignment: .leading, spacing: 4) {
            cardLabel("Players")
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(server.currentPlayers)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                Text("/ \(server.maxPlayers)")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(.quaternary)
                    if fraction > 0 {
                        Capsule()
                            .fill(barColour)
                            .frame(width: max(geo.size.width * fraction, 2))
                    }
                }
            }
            .frame(height: 3)
        }
    }

    @ViewBuilder
    private func pingCard(server: Server) -> some View {
        let colour: Color = server.pingInt <= 0  ? .secondary
            : server.pingInt < 50               ? .green
            : server.pingInt < 150              ? .orange
            : .red

        VStack(alignment: .leading, spacing: 4) {
            cardLabel("Ping")
            Text(server.pingInt > 0 ? "\(server.pingInt) ms" : "—")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(colour)
        }
    }

    @ViewBuilder
    private func timeCard(server: Server) -> some View {
        let value = server.rules.first(where: {
            let k = $0.key.lowercased()
            return k == "score_time" || k == "timelimit" || k == "g_timelimit"
        })?.value ?? "—"

        VStack(alignment: .leading, spacing: 4) {
            cardLabel("Time")
            Text(value)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .monospacedDigit()
        }
    }

    @ViewBuilder
    private func cardLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .tracking(0.6)
    }

    // MARK: - Server configuration

    @ViewBuilder
    private func serverConfigSection(server: Server) -> some View {
        VStack(spacing: .zero) {
            // Disclosure header
            Button {
                withAnimation(.easeInOut(duration: 0.18)) { configExpanded.toggle() }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(configExpanded ? .degrees(90) : .degrees(0))
                    Text("Server Configuration")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.primary)
                    Spacer()
                    if !server.rules.isEmpty {
                        Text("\(server.rules.count)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 1)
                            .background(.quaternary, in: Capsule())
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            if configExpanded {
                // Inline filter field
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 13))
                        .foregroundStyle(.tertiary)
                    TextField("Filter settings…", text: $settingsFilter)
                        .textFieldStyle(.plain)
                        .font(.system(size: 13))
                    if !settingsFilter.isEmpty {
                        Button { settingsFilter = "" } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 13))
                                .foregroundStyle(.tertiary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.quaternary.opacity(0.5),
                            in: RoundedRectangle(cornerRadius: 7, style: .continuous))
                .padding(.horizontal, 14)
                .padding(.bottom, 4)

                // Column headers
                HStack {
                    Text("Setting").frame(maxWidth: .infinity, alignment: .leading)
                    Text("Value").frame(maxWidth: .infinity, alignment: .trailing)
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.tertiary)
                .textCase(.uppercase)
                .tracking(0.5)
                .padding(.horizontal, 14)
                .padding(.vertical, 4)

                // Filtered rows
                let filtered = server.rules
                    .filter {
                        settingsFilter.isEmpty
                        || $0.key.localizedCaseInsensitiveContains(settingsFilter)
                        || $0.value.localizedCaseInsensitiveContains(settingsFilter)
                    }
                    .sorted { $0.key < $1.key }

                ForEach(filtered) { setting in
                    VStack(spacing: .zero) {
                        HStack {
                            Text(setting.key)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(setting.value)
                                .monospacedDigit()
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 4)
                        .background(.quaternary.opacity(0.25))
                        Divider().padding(.leading, 14)
                    }
                }
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
