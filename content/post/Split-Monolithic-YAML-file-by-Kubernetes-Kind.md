---
title: "Split Monolithic YAML File by Kubernetes Kind"
date: 2024-10-04T19:45:43-04:00
tags:
  - awk
  - bash
  - homelab
  - kubernetes
  - yaml
  - yq
---

# Update

It turns out the `awk` solution had a big problem I didn't notice until after I posted this.
The gist is that `awk` is only looking for `---` or `kind:`,
and it's processing the file one line at a time.
Once I inspected the contents of a file I had generated with the original script,
I realized its `apiVersion` was in a different file,
and then some other resource's `apiVersion` was at the bottom of the file I was looking at.

## What I Expected

`resources/deployments.yaml`:

```yaml
---
apiVersion: applications/v1
kind: Deployment
...
```

`resources/configmaps.yaml`:

```yaml
---
apiVersion: v1
kind: ConfigMap
...
```

## What I Got

`resources/deployments.yaml`:

```yaml
---
kind: Deployment
...
apiVersion: v1
```

`resources/configmaps.yaml`:

```yaml
---
kind: ConfigMap
...
apiVersion: applications/v1
```

This new version _does_ use `yq`,
plus I added a `case` to handle naming the files,
because I had ended up with things like `ingresss.yaml` instead of `ingresses.yaml`.

## `split-by-kind.bash` v2

```bash
#!/bin/bash

function kind_map {
    k=$(yq .kind $f)
    case $k in
    ClusterRole | ClusterRoleBinding | Role | RoleBinding)
        echo -n rbac
        return
        ;;
    PersistentVolumeClaim)
        echo -n pvcs
        return
        ;;
    Ingress)
        echo -n ingresses
        return
        ;;
    *)
        echo -n "${k}s" | tr '[:upper:]' '[:lower:]'
        ;;
    esac
}

mkdir -p resources/
mkdir -p tmp/resources/
yq -s '"tmp/resources/" + $index' ${1:-/dev/stdin}

for f in $(ls tmp/resources/*.yml); do
    k=$(kind_map $f)
    cat $f >> resources/$k.yaml
done

rm -rf tmp/resources/
```

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
