#!/usr/bin/env python3
"""
Hyprland IPC socket proxy.

Translates legacy dispatch commands (sent by waybar and other tools)
to Lua-compatible format required by Hyprland's Lua config (0.55+).

Translations:
  dispatch workspace N                      → dispatch 'hl.dsp.focus({workspace=N})'
  dispatch focusworkspaceoncurrentmonitor N → dispatch 'hl.dsp.focus({workspace=N})'

Usage: start before waybar, then launch waybar with the proxy instance signature.
  HYPRLAND_INSTANCE_SIGNATURE=${real_sig}-proxy waybar
"""

import os
import re
import socket
import sys
import threading
import time

XDG = os.environ.get('XDG_RUNTIME_DIR', f'/run/user/{os.getuid()}')
REAL_SIG = os.environ.get('HYPRLAND_INSTANCE_SIGNATURE', '')
REAL_DIR = f'{XDG}/hypr/{REAL_SIG}'
FAKE_SIG = f'{REAL_SIG}-proxy'
FAKE_DIR = f'{XDG}/hypr/{FAKE_SIG}'

DISPATCH_RE = re.compile(
    rb'^dispatch (?:workspace|focusworkspaceoncurrentmonitor)(?: name:)? ?(\d+)\s*$'
)


def translate(data: bytes) -> bytes:
    m = DISPATCH_RE.match(data.rstrip())
    if m:
        n = m.group(1).decode()
        return f"dispatch hl.dsp.focus({{workspace={n}}})".encode()
    return data


def handle_cmd(client: socket.socket) -> None:
    try:
        data = b''
        client.settimeout(1.0)
        try:
            while True:
                chunk = client.recv(4096)
                if not chunk:
                    break
                data += chunk
                if len(chunk) < 4096:
                    break
        except socket.timeout:
            pass

        if not data:
            return

        translated = translate(data)
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as real:
            real.connect(f'{REAL_DIR}/.socket.sock')
            real.sendall(translated)
            resp = b''
            real.settimeout(2.0)
            try:
                while True:
                    chunk = real.recv(4096)
                    if not chunk:
                        break
                    resp += chunk
            except socket.timeout:
                pass
        client.sendall(resp)
    except Exception:
        pass
    finally:
        try:
            client.close()
        except Exception:
            pass


def pipe(src: socket.socket, dst: socket.socket) -> None:
    try:
        while True:
            data = src.recv(4096)
            if not data:
                break
            dst.sendall(data)
    except Exception:
        pass
    finally:
        try:
            src.close()
        except Exception:
            pass
        try:
            dst.close()
        except Exception:
            pass


def handle_events(client: socket.socket) -> None:
    try:
        real = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        real.connect(f'{REAL_DIR}/.socket2.sock')
        threading.Thread(target=pipe, args=(client, real), daemon=True).start()
        pipe(real, client)
    except Exception:
        try:
            client.close()
        except Exception:
            pass


def serve(path: str, handler) -> None:
    if os.path.exists(path):
        os.remove(path)
    srv = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    srv.bind(path)
    srv.listen(32)
    while True:
        try:
            client, _ = srv.accept()
            threading.Thread(target=handler, args=(client,), daemon=True).start()
        except Exception:
            pass


def main() -> None:
    if not REAL_SIG:
        print('HYPRLAND_INSTANCE_SIGNATURE not set', file=sys.stderr)
        sys.exit(1)

    os.makedirs(FAKE_DIR, exist_ok=True)

    threading.Thread(
        target=serve,
        args=(f'{FAKE_DIR}/.socket.sock', handle_cmd),
        daemon=True,
    ).start()
    threading.Thread(
        target=serve,
        args=(f'{FAKE_DIR}/.socket2.sock', handle_events),
        daemon=True,
    ).start()

    # Signal readiness
    sys.stdout.write('ready\n')
    sys.stdout.flush()

    try:
        while True:
            time.sleep(3600)
    except KeyboardInterrupt:
        pass


if __name__ == '__main__':
    main()
