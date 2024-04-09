FROM alpine:3
LABEL maintainer="Son Tran Thanh <286.trants@gmail.com>"

ARG TARGETARCH

COPY ./src/install.sh install.sh
RUN sh install.sh && rm install.sh

ENV BACKUP_FOLDER ''
ENV BACKUP_FILE_NAME ''
ENV S3_ACCESS_KEY_ID ''
ENV S3_SECRET_ACCESS_KEY ''
ENV S3_BUCKET ''
ENV S3_REGION 'us-west-1'
ENV S3_PATH 'backup'
ENV S3_ENDPOINT ''
ENV S3_S3V4 'no'
ENV SCHEDULE ''
ENV PASSPHRASE ''
ENV BACKUP_KEEP_DAYS ''

COPY ./src/run.sh run.sh
COPY ./src/env.sh env.sh
COPY ./src/backup.sh backup.sh
COPY ./src/restore.sh restore.sh

CMD ["sh", "run.sh"]
