"""Highlight the entire focused flow row with a background color."""
import urwid
from mitmproxy import ctx

FH_PREFIX = "_fh_"
FOCUS_BG = "dark blue"
FOCUS_BG_HIGH = "#006"

_focus_map: dict = {}


def _build_focus_map():
    screen = ctx.master.ui
    m = {}
    for name, entry in list(screen._palette.items()):
        if name is None or (isinstance(name, str) and name.startswith(FH_PREFIX)):
            continue
        fg = entry[0].foreground  # low-color AttrSpec foreground
        new_name = FH_PREFIX + str(name)
        screen.register_palette_entry(new_name, fg, FOCUS_BG, "standout", fg, FOCUS_BG_HIGH)
        m[name] = new_name
    # unattributed text
    default_name = FH_PREFIX + "_default"
    screen.register_palette_entry(default_name, "white", FOCUS_BG, "standout", "white", FOCUS_BG_HIGH)
    m[None] = default_name
    return m


def _patch():
    from mitmproxy.tools.console.flowlist import FlowItem
    if getattr(FlowItem, "_focus_highlight_patched", False):
        return

    orig_init = FlowItem.__init__

    def new_init(self, master, flow):
        orig_init(self, master, flow)
        if _focus_map:
            self._wrapped_widget = urwid.AttrMap(
                self._wrapped_widget,
                None,
                _focus_map,
            )

    FlowItem.__init__ = new_init
    FlowItem._focus_highlight_patched = True


class FocusHighlight:
    async def running(self):
        global _focus_map
        if not hasattr(ctx.master, "ui"):
            return
        _focus_map = _build_focus_map()
        _patch()


addons = [FocusHighlight()]
