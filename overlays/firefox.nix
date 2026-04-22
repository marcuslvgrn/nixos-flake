final: prev: {
  firefox-unwrapped = prev.firefox-unwrapped.overrideAttrs (old: {
    passthru = old.passthru // {
      speechSynthesisSupport = false;
    };
  });
}
#final: prev: {
#  wrapFirefox =
#    browser: args:
#    prev.wrapFirefox browser (
#      args
#      // {
#        speechSynthesisSupport = false;
#      }
#    );
#}
