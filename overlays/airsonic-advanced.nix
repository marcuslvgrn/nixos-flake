final: prev: {
  airsonic = prev.airsonic.overrideAttrs (
    old:
    let
      version = "11.0.0-SNAPSHOT.20240424015024";
      pname = "airsonic-advanced";
    in
    {
      #set variables from above
      inherit pname version;

      src = prev.fetchurl {
        url = "https://github.com/airsonic-advanced/airsonic-advanced/releases/download/${version}/airsonic.war";
        hash = "sha256-fDWstS076BeXE55aOeMSSZuuYhOLLVAfjRGZRnMksz4=";
      };
    }
  );
}
