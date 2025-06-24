package main

# ✅ Do Not store secrets in ENV variables
secrets_env := [
    "passwd",
    "password",
    "pass",
    "secret",
    "key",
    "access",
    "api_key",
    "apikey",
    "token",
    "tkn"
]

deny contains msg if {
    i := input[_]
    i.Cmd == "env"
    val := i.Value
    contains(lower(val[_]), secrets_env[_])
    msg := sprintf("Line %d: Potential secret in ENV key found: %s", [i.StartLine, val])
}

# ✅ Only use trusted base images
deny contains msg if {
    i := input[_]
    i.Cmd == "from"
    val := split(i.Value[0], "/")
    count(val) > 1
    msg := sprintf("Line %d: use a trusted base image", [i.StartLine])
}

# ✅ Do not use 'latest' tag for base image
deny contains msg if {
    i := input[_]
    i.Cmd == "from"
    val := split(i.Value[0], ":")
    count(val) > 1
    contains(lower(val[1]), "latest")
    msg := sprintf("Line %d: do not use 'latest' tag for base images", [i.StartLine])
}

# ✅ Avoid curl bashing
deny contains msg if {
    i := input[_]
    i.Cmd == "run"
    val := concat(" ", i.Value)
    matches := regex.find_n("(curl|wget)[^|>]*[|>]", lower(val), -1)
    count(matches) > 0
    msg := sprintf("Line %d: Avoid curl bashing", [i.StartLine])
}

# ✅ Do not upgrade your system packages
warn contains msg if {
    i := input[_]
    i.Cmd == "run"
    val := concat(" ", i.Value)
    regex.match(".*?(apk|yum|dnf|apt|pip).+?(install|dist-upgrade|groupupdate|upgrade|update).*"," +
        " lower(val))
    msg := sprintf("Line %d: Do not upgrade your system packages: %s", [i.StartLine, val])
}

# ✅ Do not use ADD if possible
deny contains msg if {
    i := input[_]
    i.Cmd == "add"
    msg := sprintf("Line %d: Use COPY instead of ADD", [i.StartLine])
}

# ✅ Ensure USER is declared
any_user if {
    some i
    input[i].Cmd == "user"
}

deny contains msg if {
    not any_user
    msg := "Do not run as root, use USER instead"
}

# ✅ Forbid specific users (like root)
forbidden_users := [
    "root",
    "toor",
    "0"
]

deny contains msg if {
    users := [name | i := input[_]; i.Cmd == "user"; name := i.Value[0]]
    count(users) > 0
    lastuser := users[count(users)-1]
    contains(lower(lastuser), forbidden_users[_])
    msg := sprintf("Last USER directive (USER %s) is forbidden", [lastuser])
}

# ✅ Do not use sudo
deny contains msg if {
    i := input[_]
    i.Cmd == "run"
    val := concat(" ", i.Value)
    contains(lower(val), "sudo")
    msg := sprintf("Line %d: Do not use 'sudo' command", [i.StartLine])
}

# ✅ Use multi-stage builds
default multi_stage = false

multi_stage if {
    some i
    input[i].Cmd == "copy"
    val := concat(" ", input[i].Flags)
    contains(lower(val), "--from=")
}

deny contains msg if {
    not multi_stage
    msg := "You COPY, but do not appear to use multi-stage builds..."
}