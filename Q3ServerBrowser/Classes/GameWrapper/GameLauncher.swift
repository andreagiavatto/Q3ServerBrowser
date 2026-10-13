//
//  GameLauncher.swift
//  Q3ServerBrowser
//
//  Launches the player's game client with `+connect <address>`. The app is
//  sandboxed, so the client is chosen once with an open panel and remembered
//  as a security-scoped bookmark (one per game).
//

import AppKit
import UniformTypeIdentifiers
import GameServerQueryLibrary

@MainActor
enum GameLauncher {

    static func connect(to server: Server, game: SupportedGames) {
        guard let appURL = storedApplicationURL(for: game) ?? chooseApplication(for: game) else { return }
        launch(appURL, arguments: [game.launchArguments, server.hostname])
    }

    /// Asks the user to pick the game client and remembers it. Returns nil if cancelled.
    @discardableResult
    static func chooseApplication(for game: SupportedGames) -> URL? {
        let panel = NSOpenPanel()
        panel.title = "Choose \(game.name)"
        panel.message = "Choose the application you play \(game.name) with (for example ioquake3)."
        panel.prompt = "Choose"
        panel.allowedContentTypes = [.application]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.directoryURL = URL(fileURLWithPath: "/Applications")

        guard panel.runModal() == .OK, let url = panel.url else { return nil }
        if let bookmark = try? url.bookmarkData(options: .withSecurityScope,
                                                includingResourceValuesForKeys: nil,
                                                relativeTo: nil) {
            UserDefaults.standard.set(bookmark, forKey: defaultsKey(for: game))
        }
        return url
    }

    // MARK: - Private

    private static func storedApplicationURL(for game: SupportedGames) -> URL? {
        guard let bookmark = UserDefaults.standard.data(forKey: defaultsKey(for: game)) else { return nil }
        var isStale = false
        guard let url = try? URL(resolvingBookmarkData: bookmark,
                                 options: .withSecurityScope,
                                 relativeTo: nil,
                                 bookmarkDataIsStale: &isStale) else { return nil }
        if isStale, let fresh = try? url.bookmarkData(options: .withSecurityScope,
                                                      includingResourceValuesForKeys: nil,
                                                      relativeTo: nil) {
            UserDefaults.standard.set(fresh, forKey: defaultsKey(for: game))
        }
        return url
    }

    private static func launch(_ appURL: URL, arguments: [String]) {
        let didAccess = appURL.startAccessingSecurityScopedResource()
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.arguments = arguments
        configuration.activates = true
        NSWorkspace.shared.openApplication(at: appURL, configuration: configuration) { _, error in
            if didAccess { appURL.stopAccessingSecurityScopedResource() }
            if let error {
                NSLog("Q3ServerBrowser: failed to launch game client: %@", error.localizedDescription)
            }
        }
    }

    private static func defaultsKey(for game: SupportedGames) -> String {
        "GameApplicationBookmark.\(game.name)"
    }
}
