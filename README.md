### add /etc/portage/package.use/rocm 
###### dev-util/amd-rocm-meta hip profiling science

# then emerge amd-rocm-meta

Yay!

To upstream[^1]:

[1]: e.g. 5.5 -> 5.6

run 
```
for f in `tree -P '*5.5.0*.ebuild' -i -n  | grep ebuild `;do cp `find -name "${f}"` `find -name "${f}"|sed -e 's|5.5|5.6|'`;done

```
