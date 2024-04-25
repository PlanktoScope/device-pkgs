# core/host
PlanktoScope host environment

This directory contains packages which are directly deployed on the host (providing systemd units
for system services, config files to be overlaid into `/etc`, etc.), without any Docker Compose
apps; and packages which consist entirely of descriptions of resources ambiently provided by the
PlanktoScope's base operating system, independently of any package deployments.
