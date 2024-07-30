import Foundation
import MultipeerConnectivity

class NetworkService: NSObject {
    private var peerID: MCPeerID
    private var session: MCSession
    private var advertiser: MCNearbyServiceAdvertiser
    private var browser: MCNearbyServiceBrowser
    
    override init() {
        peerID = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "air-pong")
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: "air-pong")
        
        super.init()
        
        session.delegate = self
        advertiser.delegate = self
        browser.delegate = self
    }
    
    func startAdvertising() {
        advertiser.startAdvertisingPeer()
    }
    
    func stopAdvertising() {
        advertiser.stopAdvertisingPeer()
    }
    
    func startBrowsing() {
        browser.startBrowsingForPeers()
    }
    
    func stopBrowsing() {
        browser.stopBrowsingForPeers()
    }
    
    func send(data: Data) {
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Error sending data: \(error.localizedDescription)")
        }
    }
}

extension NetworkService: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("Peer \(peerID) changed state: \(state)")
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // Handle received data
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // Not implemented for this game
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // Not implemented for this game
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // Not implemented for this game
    }
}

extension NetworkService: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}

extension NetworkService: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer: \(peerID)")
    }
}
