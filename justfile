watch:
    watchexec -e nim nim js -o:web/loop.js src/main.nim

host:
    python3 -m http.server -d web 8000
