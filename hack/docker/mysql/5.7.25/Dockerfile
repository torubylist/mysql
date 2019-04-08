FROM mysql:5.7.25

COPY entrypoint.sh /run.sh
COPY peer-finder /usr/local/bin/

RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
