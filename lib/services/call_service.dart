import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallService {
  RTCPeerConnection? _peerConnection;
  final firestore = FirebaseFirestore.instance;

  Future<void> makeCall(String callId) async {
    // Create RTC peer connection
    final config = <String, dynamic>{
      'iceServers': [
        {'url': 'stun:stun.l.google.com:19302'},
      ],
    };

    _peerConnection = await createPeerConnection(config);

    // Listen for ICE candidates
    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      firestore.collection('calls').doc(callId).collection('candidates').add({
        'candidate': candidate.toMap(),
      });
    };

    // Create offer
    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    // Send offer to Firebase
    await firestore.collection('calls').doc(callId).set({
      'offer': offer.toMap(),
    });

    // Listen for answer
    firestore.collection('calls').doc(callId).snapshots().listen((snapshot) {
      if (snapshot.data() != null && snapshot.data()!['answer'] != null) {
        var answer = snapshot.data()!['answer'];
        _peerConnection!.setRemoteDescription(
          RTCSessionDescription(answer['sdp'], answer['type']),
        );
      }
    });
  }

  Future<void> receiveCall(String callId) async {
    // Get call offer from Firebase
    DocumentSnapshot snapshot =
        await firestore.collection('calls').doc(callId).get();
    if (snapshot.exists) {
      var data = snapshot.data() as Map<String, dynamic>;
      var offer = data['offer'] as Map<String, dynamic>;
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(offer['sdp'] as String, offer['type'] as String),
      );

      // Create answer
      RTCSessionDescription answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      // Send answer to Firebase
      await firestore.collection('calls').doc(callId).update({
        'answer': answer.toMap(),
      });
    }
  }
}
