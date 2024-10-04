---
title: "Split Monolithic YAML File by Kubernetes Kind"
date: 2024-10-04T19:45:43-04:00
tags:
  - awk
  - bash
  - kubernetes
  - yaml
  - yq
---

In my [homelab](https://github.com/charlesthomas/homelab)
micro-services repos,
I organize the repos by putting all the manifests in a dir called `resources/`,
with a file for each resource `kind`.

This works well once it's done but if I used `helm` to generate them,
then I get them all at once in a single yaml file.
I went [googling](https://duckduckgo.com) for a `yq` recipe to do this,
and ended up with an `awk` based solution instead:

```bash
#!/bin/bash

# awk bits stolen from:
# https://stackoverflow.com/a/59404597

# ${1:-/dev/stdin} from:
# https://stackoverflow.com/a/7045517

mkdir -p resources/

awk '
/^kind:/{
  close(file)
  file="resources/"$NF".yaml"
}
file!="" && !/^--/{
  print > (file)
}
' ${1:-/dev/stdin}


for f in $(ls resources/*.yaml); do
    [[ "${f}" == "${1}" ]] && continue
    d="$(echo $f | cut -f 1 -d . | tr '[:upper:]' '[:lower:]')s.yaml"
    mv $f $d
done
```
