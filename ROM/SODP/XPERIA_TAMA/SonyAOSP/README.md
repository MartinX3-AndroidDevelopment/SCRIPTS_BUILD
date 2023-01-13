# SonyAOSP

## Links
- [XDA SonyAOSP](https://forum.xda-developers.com/xperia-xz2/development/unstable-sonyaosp-10-0r1-t3975009)

## Requirements
- [Local manifest](https://github.com/sonyxperiadev/local_manifests)

## Instructions
- [SODP instructions](https://developer.sony.com/develop/open-devices/guides/aosp-build-instructions/build-aosp-android-android-10-0-0)

# Containerfile
I provided a dockerfile, to build AOSP without installing all the dependencies on your system.
You can use it like this:
```bash
podman pod rm builder --force && podman kube play build-pod.yaml --userns=keep-id
```
