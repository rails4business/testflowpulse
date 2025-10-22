// rthtml_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["editor", "html"]

  connect() {
    console.debug("[rthtml] connect", { hasEditor: this.hasEditorTarget, hasHtml: this.hasHtmlTarget })

    // Serve SOLO l'editor per partire: l'HTML panel è opzionale
    if (!this.hasEditorTarget) return

    this.waitForContentEditable()
  }

  disconnect() {
    if (this._retry) clearTimeout(this._retry)
    if (this.ce && this.inputHandler) this.ce.removeEventListener("input", this.inputHandler)
    if (this.observer) this.observer.disconnect()
  }

  waitForContentEditable(tries = 0) {
    const candidates = [
      '[data-lexical-editor] [contenteditable="true"]',
      '.Lexical__ContentEditable',
      '[contenteditable="true"]'
    ]
    for (const sel of candidates) {
      const el = this.editorTarget.querySelector(sel)
      if (el) { this.ce = el; break }
    }

    if (!this.ce) {
      if (tries > 60) { console.warn("[rthtml] CE non trovato"); return }
      this._retry = setTimeout(() => this.waitForContentEditable(tries + 1), 100)
      return
    }

    console.debug("[rthtml] trovato contenteditable", this.ce)

    // Primo render
    this.update()

    // Aggiorna mentre scrivi / mutazioni
    this.inputHandler = () => this.update()
    this.ce.addEventListener("input", this.inputHandler)
    this.observer = new MutationObserver(() => this.update())
    this.observer.observe(this.ce, { childList: true, subtree: true, characterData: true })
  }

  update() {
    if (!this.ce || !this.hasHtmlTarget) return  // HTML panel opzionale
    const raw = this.ce.innerHTML
    const pretty = this.prettyHTML(raw)
    this.htmlTarget.textContent = pretty
  }

  copy() {
    if (!this.hasHtmlTarget) return
    const text = this.htmlTarget.textContent || ""
    navigator.clipboard?.writeText(text)
      .then(() => console.debug("[rthtml] copiato"))
      .catch(() => console.warn("[rthtml] copia fallita"))
  }

  prettyHTML(html) {
    const tokens = html.replace(/>\s+</g, '><').replace(/</g, '\n<').trim().split('\n')
    const voidTags = /^(area|base|br|col|embed|hr|img|input|link|meta|param|source|track|wbr)$/i
    const selfClose = /\/>$/
    const closeTag  = /^<\/.+>$/
    const openTag   = /^<([a-zA-Z0-9:-]+)(\s[^>]*)?>$/
    let indent = 0, out = []
    for (let line of tokens) {
      line = line.trim()
      if (!line) continue
      if (closeTag.test(line)) indent = Math.max(indent - 1, 0)
      out.push('  '.repeat(indent) + line)
      const m = line.match(openTag)
      if (m) {
        const tag = m[1]
        if (!voidTags.test(tag) && !selfClose.test(line) && !closeTag.test(line)) indent += 1
      }
    }
    return out.join('\n') + '\n'
  }
}
