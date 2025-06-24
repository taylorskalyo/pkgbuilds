#!/usr/bin/python

import dbus
import dbus.service
from dbus.mainloop.glib import DBusGMainLoop
import json
import logging
import os
import signal
import sys
import tempfile
import threading
import time

import gi
gi.require_version("Gtk", "3.0")
gi.require_version("GdkPixbuf", "2.0")
from gi.repository import GLib, GdkPixbuf, GLib

history = []

def on_interrupt(signum, frame):
    sys.exit(0)

def on_notify(notif):
    for i, n in enumerate(history):
        if n['id'] == notif['id']:
            notif['dismissed'] = n['dismissed']
            history.pop(i)
            break

    history.insert(0, notif)
    print_state()

def print_state():
    # Escape '\'
    # https://github.com/elkowar/eww/issues/1193
    #print(json.dumps(history).replace('\\', '\\\\'), flush=True)
    print(json.dumps(history), flush=True)

class NotificationServer(dbus.service.Object):
    dbus_iface = 'org.freedesktop.Notifications'
    dbus_path = '/org/freedesktop/Notifications'
    private_hint = 'x-canonical-private-synchronous'

    def __init__(self, logger, cache_dir):
        bus = dbus.SessionBus()
        bus_name = dbus.service.BusName(self.dbus_iface, bus)
        dbus.service.Object.__init__(self, bus, self.dbus_path, bus_name)
        self.logger = logger
        self.cache_dir = cache_dir
        self.next_id = 1

    @dbus.service.method(dbus_iface, in_signature='susssasa{ss}i', out_signature='u')
    def Notify(self, app_name, replaces_id, app_icon, summary, body, actions, hints, timeout):
        id = replaces_id
        if id < 1:
            if hints.get(self.private_hint, None) != None:
                for n in history:
                    if n['hints'].get(self.private_hint, None) != None:
                        id = n['id']
                        break
        if id < 1:
            id = self.next_id
            self.next_id += 1

        data = hints.pop('image-data', [])
        if len(data) > 0:
            path = f'{self.cache_dir}/{id}.png'
            GdkPixbuf.Pixbuf.new_from_bytes(
                width=data[0],
                height=data[1],
                has_alpha=data[3],
                data=GLib.Bytes(data[6]),
                colorspace=GdkPixbuf.Colorspace.RGB,
                rowstride=data[2],
                bits_per_sample=data[4],
            ).savev(path, "png")
            hints['image-path'] = path

        colors = os.path.expanduser('~/.cache/wal/colors')
        if app_icon.endswith('.svg') and hints.pop('recolor', None):
            if os.path.exists(app_icon) and os.path.exists(colors):
                path = f"{self.cache_dir}/{id}.svg"
                with open(app_icon, 'r') as file: content = file.read()
                with open(colors, 'r') as file: color = file.readlines()[-1]
                with open(path, 'w') as file: file.write(content.replace('fill="#FFFFFF"', f'fill="{color}"'))
                app_icon = path

        n = dict(
            id = id,
            app_name = app_name,
            app_icon = app_icon,
            summary = summary,
            body = body,
            actions = [{"id": actions[i], "label": actions[i+1]} for i in range(0, len(actions), 2)], # list to list of dicts
            hints = hints,
            dismissed = False,
            timestamp = time.time()
        )
        on_notify(n)

        return id

    # Non-standard method to allow outside applications (i.e. eww) to trigger an action.
    @dbus.service.method(dbus_iface, in_signature='us', out_signature='')
    def InvokeAction(self, id, key):
        for i, n in enumerate(history):
            if n['id'] == id:
                for a in n['actions']:
                    if a['id'] == key:
                        self.ActionInvoked(id, key)
                        break

    # Non-standard method to allow outside applications to clear all notifications.
    @dbus.service.method(dbus_iface, in_signature='', out_signature='')
    def ClearNotifications(self):
        for i, n in enumerate(history):
            if not n.get('dismissed', False):
                n['dismissed'] = True
                history[i] = n
                self.NotificationClosed(id, 2)

    @dbus.service.method(dbus_iface, in_signature='u', out_signature='')
    def CloseNotification(self, id):
        for i, n in enumerate(history):
            if n['id'] == id:
                if not n.get('dismissed', False):
                    n['dismissed'] = True
                    history[i] = n
                    self.NotificationClosed(id, 2)
                break

    @dbus.service.method(dbus_iface, in_signature='', out_signature='as')
    def GetCapabilities(self):
        # action-icons, actions, body, body-hyperlinks, body-images,
        #  body-markup, icon-multi, icon-static, persistence, sound
        caps = [
            'actions',
            'body',
            'body-markup',
            'icon-static',
            'persistence',
        ]
        return sorted(caps)

    @dbus.service.method(dbus_iface, out_signature='ssss')
    def GetServerInformation(self):
        return ("Eww Notification Server", "eww", "1.0", "1.2")

    @dbus.service.signal(dbus_iface, signature='uu')
    def NotificationClosed(self, id, reason=3):
        reasons = [
            'expired',
            'dismissed',
            'closed',
            'unknown',
        ]
        self.logger.debug('NotificationClosed signal (id: %s, reason: %s)', id, reasons[reason])
        print_state()

    @dbus.service.signal(dbus_iface, signature='us')
    def ActionInvoked(self, id, key):
        self.logger.debug('ActionInvoked signal (id: %s, key: %s)', id, key)

DBusGMainLoop(set_as_default=True)

if __name__ == '__main__':
    logging.basicConfig(level=logging.WARNING)
    logger = logging.getLogger('notifications')
    DBusGMainLoop(set_as_default=True)
    with tempfile.TemporaryDirectory() as cache_dir:

        # Trap signals so that we can clean up before exit
        signal.signal(signal.SIGINT, on_interrupt)
        signal.signal(signal.SIGTERM, on_interrupt)
        NotificationServer(logger, cache_dir)
        mainloop = GLib.MainLoop()
        mainloop.run()
