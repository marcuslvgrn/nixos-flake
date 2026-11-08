function error(message) {
    print "Error: " message > "/dev/stderr"
    failed = 1
    exit 1
}

{
    lines[NR] = $0
    if ($0 == "creation_rules:") creation_rules = NR
}

END {
    if (failed) exit 1
    if (!creation_rules) error(".sops.yaml has no top-level creation_rules section")

    for (i = 1; i < creation_rules; i++) {
        if (lines[i] ~ /^  - &[A-Za-z_][A-Za-z0-9_-]* age1[a-z0-9]+$/) {
            fields = lines[i]
            sub(/^  - &/, "", fields)
            split(fields, parts, " ")
            anchor = parts[1]
            key = parts[2]
            anchors[anchor] = key
            if (key == recipient) recipient_anchor = anchor
        }
    }

    if (recipient_anchor) {
        anchor = recipient_anchor
    } else if (host in anchors) {
        error("anchor " host " already exists for a different recipient")
    } else {
        anchor = host
        add_key = 1
    }

    for (i = creation_rules; i <= NR; i++) {
        if (lines[i] ~ /^    - age:[[:space:]]*$/) {
            age_group = i
            group_count++
        }
    }
    if (group_count != 1) error("expected exactly one age group in .sops.yaml creation_rules")

    group_end = age_group + 1
    while (group_end <= NR && lines[group_end] ~ /^      - \*[A-Za-z_][A-Za-z0-9_-]*$/) {
        alias = lines[group_end]
        sub(/^      - \*/, "", alias)
        if (alias == anchor) has_alias = 1
        group_end++
    }
    add_alias = !has_alias

    for (i = 1; i <= NR; i++) {
        if (i == creation_rules && add_key)
            print "  - &" anchor " " recipient
        if (i == group_end && add_alias)
            print "      - *" anchor
        print lines[i]
    }
    if (group_end == NR + 1 && add_alias)
        print "      - *" anchor
}
