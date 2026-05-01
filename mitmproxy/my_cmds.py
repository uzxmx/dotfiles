import datetime
from mitmproxy import command, ctx, http

SORT_REQUEST_HEADERS = True


def _focused_flow():
    f = ctx.master.view.focus.flow
    if f is None:
        ctx.log.warn("No focused flow")
    return f


def _auto_path(prefix: str) -> str:
    now = datetime.datetime.now()
    return f"{prefix}-{now:%m%d-%H%M%S}.txt"


def _fmt_headers(headers, sort: bool) -> list:
    items = list(headers.items())
    if sort:
        items = sorted(items, key=lambda kv: kv[0].lower())
    lines = []
    for k, v in items:
        if k.lower() == "cookie":
            for cookie in v.split(";"):
                cookie = cookie.strip()
                if cookie:
                    lines.append(f"Cookie: {cookie}")
        else:
            lines.append(f"{k}: {v}")
    return lines


def _fmt_request(req: http.Request) -> str:
    lines = [f"{req.method} {req.pretty_url} {req.http_version}"]
    lines.extend(_fmt_headers(req.headers, SORT_REQUEST_HEADERS))
    lines.append("")
    body = req.get_text(strict=False)
    if body:
        lines.append(body)
    return "\n".join(lines)


def _fmt_response(resp: http.Response) -> str:
    lines = [f"{resp.http_version} {resp.status_code} {resp.reason}"]
    lines.extend(_fmt_headers(resp.headers, False))
    lines.append("")
    body = resp.get_text(strict=False)
    if body:
        lines.append(body)
    return "\n".join(lines)


def _write(path: str, content: str) -> None:
    with open(path, "w", encoding="utf-8") as fp:
        fp.write(content)
    ctx.log.info(f"Dumped to {path}")


class MyCmds:

    @command.command("my.dump_req")
    def dump_req(self, path: str = "") -> None:
        """Dump focused request to file (auto: req-MMDD-HHmmss.txt)"""
        f = _focused_flow()
        if f is None:
            return
        _write(path or _auto_path("req"), _fmt_request(f.request))

    @command.command("my.dump_resp")
    def dump_resp(self, path: str = "") -> None:
        """Dump focused response to file (auto: resp-MMDD-HHmmss.txt)"""
        f = _focused_flow()
        if f is None:
            return
        if f.response is None:
            ctx.log.warn("No response for focused flow")
            return
        _write(path or _auto_path("resp"), _fmt_response(f.response))

    @command.command("my.dump")
    def dump(self, path: str = "") -> None:
        """Dump focused request + response to file (auto: full_req-MMDD-HHmmss.txt)"""
        f = _focused_flow()
        if f is None:
            return
        parts = [_fmt_request(f.request)]
        if f.response:
            parts.append(_fmt_response(f.response))
        _write(path or _auto_path("full_req"), "\n\n---\n\n".join(parts))


addons = [MyCmds()]
