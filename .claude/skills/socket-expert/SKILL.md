---
name: socket-expert
description: >
  Auto-invoke when working with real-time features: Socket.io on the backend (utils/socket.js,
  chatController.js, messageController.js), or socket_io_client in Flutter (chat feature,
  notification feature). Trigger on the words "socket", "real-time", "chat", "WebSocket",
  "emit", "on event", "room", "socket_io_client", or when editing files in the chat feature.
---

# Socket.io Expert Skill

You know Socket.io for this project: backend uses `socket.io ^4.7.4` initialized in `utils/socket.js`, Flutter uses `socket_io_client ^2.0.3+1`.

## Backend Socket Setup

```js
// utils/socket.js
import { Server } from 'socket.io';

let io;

export const initSocket = (httpServer) => {
  io = new Server(httpServer, {
    cors: { origin: '*' },  // restrict in production
  });

  io.on('connection', (socket) => {
    // Authenticate on connection — do not trust unauthenticated sockets
    const token = socket.handshake.auth.token;
    // verify JWT here, attach user to socket

    socket.on('join_room', (roomId) => {
      socket.join(roomId);
    });

    socket.on('disconnect', () => {
      // cleanup
    });
  });
};

export const getIO = () => {
  if (!io) throw new Error('Socket.io not initialized');
  return io;
};
```

## Emitting from a Controller

```js
import { getIO } from '../utils/socket.js';

// Inside any controller, after a write operation:
const io = getIO();

// To a specific user's room
io.to(`user_${userId}`).emit('new_message', messageData);

// To a chat room
io.to(`chat_${chatId}`).emit('message', messageData);

// To everyone except sender
socket.to(`chat_${chatId}`).emit('typing', { userId });
```

## Room Naming Conventions
- User room: `user_${userId}` — for personal notifications
- Chat room: `chat_${chatId}` — for group/direct messages
- Admin room: `admin` — for admin dashboard real-time updates

## Flutter Socket Connection

```dart
// In ChatController or a dedicated SocketService
import 'package:socket_io_client/socket_io_client.dart' as IO;

late IO.Socket socket;

void connectSocket(String token) {
  socket = IO.io(
    AppConstants.baseUrl,
    IO.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .setAuth({'token': token})  // send JWT for server-side auth
      .build(),
  );

  socket.connect();

  socket.onConnect((_) {
    socket.emit('join_room', 'user_${userId}');
  });

  socket.on('new_message', (data) {
    // handle incoming message
    messages.insert(0, MessageModel.fromJson(data));
  });

  socket.onDisconnect((_) {
    // handle disconnect — attempt reconnect if user is logged in
  });
}

// Always disconnect on controller close
@override
void onClose() {
  socket.disconnect();
  socket.dispose();
  super.onClose();
}
```

## Security Rules for Socket.io
- **Always authenticate on connection** — verify JWT from `socket.handshake.auth.token`
- **Never let users join rooms that aren't theirs** — verify ownership before `socket.join(roomId)`
- **Sanitize message content** before emitting to other clients — strip HTML/script tags
- **Rate limit message events** — prevent spam by tracking emit frequency per socket

## Common Issues
- `getIO()` called before `initSocket()` — ensure `initSocket(httpServer)` runs before any route is hit
- Flutter socket not disconnected in `onClose()` — memory leak and phantom listeners
- Messages not received after hot restart — socket connection drops, must reconnect
- `socket.to(room).emit()` does NOT send to the sender — use `io.in(room).emit()` to include sender
