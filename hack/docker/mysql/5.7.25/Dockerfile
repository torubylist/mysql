FROM mysql:5.7.25

COPY entrypoint.sh /run.sh

RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
