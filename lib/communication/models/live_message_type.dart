enum MessageMediaType { text, image, voice }

enum LiveMessageType {
  /// User sends register request.
  /// This is not to sign up. It's
  /// more like saying I'm online.
  ///
  /// {from}
  register,

  /// Succesfully 'onlined' user
  registered,

  /// User sends meeting joining request
  /// the server should return the existing participants
  /// list. with sdp_details empty. No sharing untill
  /// joined.
  ///
  /// {from, meeting_id}
  joinRequest,

  /// User receives who are already on
  /// the meeting.
  /// {
  ///   participants:[{user_id},{user_id}]
  /// }
  participants,

  /// User receives who are already on
  /// the meeting.
  /// {
  ///   offers:{
  ///     {from,to,sdp_details:{sdp,sdpType}},
  ///     {from,to,sdp_details:{sdp,sdpType}},
  ///     ...
  ///     ...
  ///   }
  /// }
  offer,

  /// When other users join the meeting
  /// user is in.
  ///
  /// {participants:{user_id, sdp_details:{sdp,sdpType}}}
  /// when some one joins an existing meeting, their
  /// details is sent to all existing participants and
  /// they receives all remaining participants sdp_details
  participantJoined,

  /// When an Web RTC offer is received from other user
  /// user sends an answer
  ///
  /// [{from,to,sdp_details:{sdp,sdpType}}]
  answer,

  /// The users media connection details is sent thourgh
  /// the Web Socket
  ///
  /// In case of 1 to 1 call this will be:
  /// {from,to,candidate}
  ///
  /// and In case of a meeting:
  /// {from,meeting_id,candidate}
  iceCandidate,

  /// User leaves call or meeting
  /// {from}
  leave,

  /// If call was not receied
  /// from the other side.
  ///
  /// Hellooooo, It's m..
  ///
  /// I am busy
  denied,

  /// Some left the meeting user is in.
  /// {from}
  participantLeft,

  /// Server Ping to check connectivity
  ping,

  /// Client Pong to acknowledge Ping
  pong,
  chat,

  /// Something went wrong
  /// {message}
  error;

  String toMap() {
    switch (this) {
      case LiveMessageType.register:
        return 'register';
      case LiveMessageType.registered:
        return 'registered';
      case LiveMessageType.joinRequest:
        return 'join_request';
      case LiveMessageType.participants:
        return 'participants';
      case LiveMessageType.offer:
        return 'offer';
      case LiveMessageType.participantJoined:
        return 'participant_joined';
      case LiveMessageType.answer:
        return 'answer';
      case LiveMessageType.iceCandidate:
        return 'ice_candidate';
      case LiveMessageType.leave:
        return 'leave';
      case LiveMessageType.denied:
        return 'denied';
      case LiveMessageType.participantLeft:
        return 'participant_left';
      case LiveMessageType.ping:
        return 'ping';
      case LiveMessageType.pong:
        return 'pong';
      case LiveMessageType.error:
        return 'error';
      case LiveMessageType.chat:
        return 'chat';
    }
  }

  static LiveMessageType fromMap(String s) {
    switch (s) {
      case 'register':
        return LiveMessageType.register;
      case 'registered':
        return LiveMessageType.registered;
      case 'join_request':
        return LiveMessageType.joinRequest;
      case 'participants':
        return LiveMessageType.participants;
      case 'offer':
        return LiveMessageType.offer;
      case 'participant_joined':
        return LiveMessageType.participantJoined;
      case 'answer':
        return LiveMessageType.answer;
      case 'ice_candidate':
        return LiveMessageType.iceCandidate;
      case 'leave':
        return LiveMessageType.leave;
      case 'denied':
        return LiveMessageType.denied;
      case 'participant_left':
        return LiveMessageType.participantLeft;
      case 'ping':
        return LiveMessageType.ping;
      case 'pong':
        return LiveMessageType.pong;
      case 'error':
        return LiveMessageType.error;
      case 'chat':
        return LiveMessageType.chat;
      default:
        throw Exception('Unsupported LiveMessageType: $s');
    }
  }
}
