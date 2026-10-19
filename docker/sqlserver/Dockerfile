FROM mcr.microsoft.com/mssql/server:2025-CU7-ubuntu-22.04

USER root

COPY --chmod=755 init.sh /docker-init/init.sh

USER 10001

ENTRYPOINT ["/bin/bash", "/docker-init/init.sh"]
