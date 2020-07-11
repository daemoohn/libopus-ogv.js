workflow "Build libopus" {
  on = "deployment"
  resolves = ["libopusBuildActions"]
}

action "libopusBuildActions" {
  uses = "./"
}
