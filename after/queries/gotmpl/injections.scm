; extends

; Treat the literal text between template actions as HTML
((text) @injection.content
  (#set! injection.language "html")
  (#set! injection.combined))
