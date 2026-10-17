return {
  "AstroNvim/astrolsp",
  opts = function(_, opts)
    -- Replace the inherited list rather than deep-merging an empty list into
    -- it. Projects can opt in with GOFLAGS or their own gopls configuration.
    opts.config.gopls.settings.gopls.buildFlags = {}
  end,
}
