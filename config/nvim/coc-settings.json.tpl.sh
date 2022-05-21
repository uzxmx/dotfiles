{
  // \"http.proxy\": \"http://localhost:8125\",

  // \"coc.preferences.noselect\": true,
  \"coc.preferences.currentFunctionSymbolAutoUpdate\": true

  \"codeLens.enable\": false,
  \"codeLens.position\": \"eol\",
  \"codeLens.subseparator\": \"\|\",

  \"solargraph.commandPath\": \"$SOLARGRAPH_PATH\",
  \"solargraph.checkGemVersion\": false,

  // \"diagnostic.enableMessage\": \"jump\",
  // \"diagnostic.messageTarget\": \"float\",

  // Uncomment this if you want to disable coc-java.
  // \"java.enabled\": false,
  \"java.jdt.ls.vmargs\": \"-XX:+UseParallelGC -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90 -Dsun.zip.disableMemoryMapping=true -Xmx1G -Xms100m -noverify -javaagent:$LOMBOK_JAR_PATH\",
  // \"java.trace.server\": \"verbose\",
  \"java.referencesCodeLens.enabled\": true,
  \"java.implementationsCodeLens.enabled\": true,
  \"java.format.enabled\": false,
  \"java.progressReports.enabled\": true,
  \"java.foldingRange.enabled\": false,
  \"java.errors.incompleteClasspath.severity\": \"ignore\",
  \"java.completion.importOrder\": [
    \"\",
    \"javax\",
    \"java\",
    \"#\"
  ],
  \"java.completion.favoriteStaticMembers\": [
      \"org.junit.Assert.*\",
      \"org.junit.Assume.*\",
      \"org.junit.jupiter.api.Assertions.*\",
      \"org.junit.jupiter.api.Assumptions.*\",
      \"org.junit.jupiter.api.DynamicContainer.*\",
      \"org.junit.jupiter.api.DynamicTest.*\",
      \"org.mockito.Mockito.*\",
      \"org.mockito.ArgumentMatchers.*\",
      \"org.mockito.Answers.*\"
  ],
  \"java.debug.settings.hotCodeReplace\": \"auto\",

  // \"snippets.ultisnips.enable\": false,
  \"languageserver\": {
    \"golang\": {
      \"command\": \"gopls\",
      \"rootPatterns\": [\"go.mod\"],
      \"filetypes\": [\"go\"],
      \"initializationOptions\": {
        \"usePlaceholders\": true
      }
    },
    \"kotlin\": {
      // \"command\": \"kotlin-language-server\",
      \"port\": 18091,
      \"filetypes\": [\"kotlin\"]
    }
  }
}
