//
//  MPConnectionManager.swift
//  KittyKatNo
//
//  Created by Julia Shen on 2/12/26.
//

import MultipeerConnectivity
internal import Combine

// string thats an identifier for service
extension String {
    static var serviceName = "KittyKatNo" // has to match whats in the bonjour service string
}

class MPConnectionManager: NSObject, ObservableObject {
    let serviceType = String.serviceName
    let session: MCSession
    let myPeerId: MCPeerID
    let nearbyServiceAdvertiser: MCNearbyServiceAdvertiser
    let nearbyServiceBrowser: MCNearbyServiceBrowser //lets us search for nearby advertisers
    
    var game: GameService?
    
    func setup(game: GameService) {
        self.game = game
    }
    
    @Published var availablePeers = [MCPeerID]()
    
    @Published var receivedInvitation: Bool = false
    @Published var receivedInviteFrom: MCPeerID? // optional
    @Published var invitationHandler: ((Bool, MCSession?) -> Void)?
    
    @Published var paired: Bool = false
    
    var isAvailable: Bool = false {
        didSet {
            if isAvailable {
                startAdvertising()
            } else {
                stopAdvertising()
            }
        }
    }
    
    init(yourName: String) {
        myPeerId = MCPeerID(displayName: yourName)
        session = MCSession(peer: myPeerId)
        nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        nearbyServiceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
        super.init()
        session.delegate = self
        nearbyServiceBrowser.delegate = self
        nearbyServiceAdvertiser.delegate = self
    }
    
    deinit {
        stopBrowsing()
        stopAdvertising()
    }
    
    func startAdvertising() {
        nearbyServiceAdvertiser.startAdvertisingPeer()
    }
    
    func stopAdvertising() {
        nearbyServiceAdvertiser.stopAdvertisingPeer()
    }
    
    func startBrowsing() {
        nearbyServiceBrowser.startBrowsingForPeers()
    }
    
    func stopBrowsing() {
        nearbyServiceBrowser.stopBrowsingForPeers()
        availablePeers.removeAll()
    }
    
    func send(gameMove: MPGameMove) {
        if !session.connectedPeers.isEmpty {
            do {
                if let data = gameMove.data() {
                    try session.send(data, toPeers: session.connectedPeers, with: .reliable)
                }
            } catch {
                print("error sending \(error.localizedDescription)")
            }
        }
    }
}

extension MPConnectionManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        // if we find a peer, add it to list
        DispatchQueue.main.async {
            if !self.availablePeers.contains(peerID) {
                self.availablePeers.append(peerID)
            }
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        // if peer stops advertising, remove them
        guard let index = availablePeers.firstIndex(of: peerID) else {return}
        DispatchQueue.main.async {
            self.availablePeers.remove(at: index)
        }
    }
}

extension MPConnectionManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // when youre advertising and you receive an invitation, and you can respond with the handler i think
        DispatchQueue.main.async {
            self.receivedInvitation = true
            self.receivedInviteFrom = peerID
            self.invitationHandler = invitationHandler
        }
    }
}

extension MPConnectionManager: MCSessionDelegate {
    // at each one we'll get a session state property that we use to update published properties
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            DispatchQueue.main.async {
                self.paired = false
                self.isAvailable = true
            }
        case .connected:
            DispatchQueue.main.async {
                self.paired = true
                self.isAvailable = false
            }
        default: // same as not connected
            DispatchQueue.main.async {
                self.paired = false
                self.isAvailable = true
            }
        }
    }
    
    // didReceive will be data our peer sent us that we need to respond to (their next move, starting, ending, resetting game)
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let gameMove = try? JSONDecoder().decode(MPGameMove.self, from: data) {
            DispatchQueue.main.async {
                switch gameMove.action {
                case .start:
                    break // will come back to later, when receiving start, will also get player name
                case .end:
                    self.session.disconnect()
                    self.isAvailable = true
                case .move:
                    if let index = gameMove.index {
                        self.game?.makeMove(at: index)
                    }
                case .reset:
                    self.game?.resetGame()
                }
            }
        }
    }
    
    // can leave other functions empty since im not passing any resources or input stream
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        <#code#>
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        <#code#>
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: (any Error)?) {
        <#code#>
    }
    
    
}
